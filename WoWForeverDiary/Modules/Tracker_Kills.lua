-- Kills, bosses, rares, deaths and nemeses
local ADDON, WFD = ...
local L = WFD.L
local band, format, time = bit.band, string.format, time

local mobCache = {}   -- npcId -> { level, classification, creatureType, name }
local lastHitter      -- { name, t } : who damaged the player last
local lastThreat      -- { name, t } : the last creature seen attacking the player (it had the player as its target)
local lastKill        -- { name, t, id }
local playerGUID

local KILL_STEPS = { [100] = true, [250] = true, [500] = true, [1000] = true, [2500] = true, [5000] = true, [10000] = true }

local nameToId = {}
-- Newer clients (Interface >= 16000) restrict the combat log for addons, so
-- kills are then read from the "<creature> dies, you gain N experience" chat line.
local useCombatLog = (select(4, GetBuildInfo()) or 0) < 16000

-- A kind slain while only its name was known (read from the chat line) is kept under its name;
-- once the creature is seen, its kills move to its ID, where the bestiary and the renaming find them.
local function adoptName(name, id)
    local C = WFD.C
    local old = C and not WFD.paused and C.mobs[name]
    if type(old) ~= "table" then return end
    local m = C.mobs[id]
    if not m then
        C.mobs[id] = old
        m = old
    else
        m.kills = (m.kills or 0) + (old.kills or 0)
        m.drops = (m.drops or old.drops) and ((m.drops or 0) + (old.drops or 0)) or nil
        if old.first and (not m.first or old.first < m.first) then m.first, m.fz, m.fpl = old.first, old.fz, old.fpl end
        if old.last and (not m.last or old.last > m.last) then m.last = old.last end
        if type(old.loot) == "table" and type(m.loot) == "table" then
            for item in pairs(old.loot) do m.loot[item] = true end
        end
        for k, v in pairs(old) do if m[k] == nil then m[k] = v end end
    end
    C.mobs[name] = nil
    for _, d in pairs(C.days or {}) do
        local n = d.kills and d.kills[name]
        if n then
            d.kills[id] = (d.kills[id] or 0) + n
            d.kills[name] = nil
        end
    end
    if C.sighted then C.sighted[id] = nil end
    if WFD.NoteCreature then WFD:NoteCreature(id, m) end
    WFD.dirty = true
end

local function cacheUnit(unit)
    if not unit or not UnitExists(unit) then return end
    -- the game hides some unit details ("secret values") in certain situations: such a unit is skipped
    local isSecret = issecretvalue
    local guid = UnitGUID(unit)
    if not guid or (isSecret and isSecret(guid)) then return end
    local kind, id = WFD:ParseGUID(guid)
    if kind ~= "Creature" or not id then return end
    if UnitIsPlayer(unit) then return end
    local name = UnitName(unit)
    local level, class, ctype, family = UnitLevel(unit), UnitClassification(unit), UnitCreatureType(unit),
        UnitCreatureFamily and UnitCreatureFamily(unit) or nil
    if isSecret and (isSecret(name) or isSecret(level) or isSecret(class) or isSecret(ctype) or isSecret(family)) then return end
    mobCache[id] = { level, class, ctype, name, family }
    if name then
        nameToId[name] = id
        adoptName(name, id)
    end
    -- a creature seen but not yet slain: the bestiary shows it as a covered card with the place it was seen
    local C = WFD.C
    if C and not WFD.paused and not C.mobs[id] and name and UnitCanAttack("player", unit) then
        C.sighted = C.sighted or {}
        if not C.sighted[id] then
            local map, x, y = WFD:PlayerPos()
            C.sighted[id] = { n = name, z = WFD.zoneName, lv = UnitLevel(unit), cls = UnitClassification(unit),
                m = map, x = x, y = y, t = time() }
        end
    end
end

WFD:On("PLAYER_TARGET_CHANGED", function() cacheUnit("target") end)
WFD:On("UPDATE_MOUSEOVER_UNIT", function() cacheUnit("mouseover") end)
WFD:On("NAME_PLATE_UNIT_ADDED", function(_, unit) cacheUnit(unit) end)

function WFD:LastKill() return lastKill end

-- a raid boss is reported by its kill and by the end of the encounter: only the first report counts
local bossNoted = {}
function WFD:FirstBossNoted(name)
    if not name then return true end
    local t = bossNoted[name]
    bossNoted[name] = time()
    return not (t and time() - t < 60)
end

local function countKill(id, destName)
    if not id then return end
    local C = WFD.C
    local d = WFD:Day()
    local info = mobCache[id]
    local m = C.mobs[id]
    if not m then
        -- fz / fpl: the area and your own level when the first one fell
        m = { name = destName, kills = 0, first = time(), fz = WFD.zoneName, fpl = UnitLevel("player") }
        C.mobs[id] = m
    end
    m.kills = m.kills + 1
    m.last = time()
    if C.sighted then C.sighted[id] = nil end      -- no longer a covered card
    m.name = destName or m.name
    m.zone = WFD.zoneName or m.zone
    if info then
        m.level, m.cls, m.ctype = info[1], info[2], info[3]
        m.fam = info[5] or m.fam
    end

    d.kills[id] = (d.kills[id] or 0) + 1
    d.killTotal = d.killTotal + 1
    if WFD.CreditCompanions then WFD:CreditCompanions() end
    WFD:Signal("kill", id, destName, m)
    lastKill = { name = destName, t = time(), id = id }

    local map, x, y = WFD:PlayerPos()
    if map then
        local kc = d.kcells[map]
        if type(kc) == "string" then              -- a packed day: back to a table
            local t = {}
            for k, v in pairs(WFD:PathCells(kc)) do t[k] = v end
            kc = t
            d.kcells[map] = kc
        elseif not kc then
            kc = {}
            d.kcells[map] = kc
        end
        local key = WFD:CellKey(x, y)
        kc[key] = (kc[key] or 0) + 1
        if not m.map then m.map, m.x, m.y = map, x, y end      -- where this kind was met first
    end
    if WFD.NoteCreature then WFD:NoteCreature(id, m) end

    local boss = info and (info[2] == "worldboss" or info[1] == -1)
    local rare = info and (info[2] == "rare" or info[2] == "rareelite")
    if boss then m.boss = true end
    if rare then m.rare = true end

    if boss and m.kills == 1 and WFD:FirstBossNoted(destName) then
        WFD:Milestone("boss", format(L["First victory over the boss %s!"], destName or "?"), true, { npc = id })
    elseif rare and m.kills == 1 then
        WFD:Milestone("rare", format(L["Rare creature slain: %s"], destName or "?"), true, { npc = id })
    elseif boss then
        WFD:Log("boss", format(L["Boss %s defeated again (%dx)"], destName or "?", m.kills))
    end

    local total = (C.killTotal or 0) + 1
    C.killTotal = total
    if KILL_STEPS[total] then
        WFD:Milestone("kills", format(L["%d creatures slain in total"], total), false)
    end
    WFD.dirty = true
end

if useCombatLog then
    WFD:On("COMBAT_LOG_EVENT_UNFILTERED", function()
        if WFD.paused or not WFD.C then return end
        local _, sub, _, sGUID, sName, sFlags, _, dGUID, dName = CombatLogGetCurrentEventInfo()
        if sub == "PARTY_KILL" then
            if sGUID == playerGUID or band(sFlags or 0, COMBATLOG_OBJECT_AFFILIATION_MINE or 1) ~= 0 then
                local kind, id = WFD:ParseGUID(dGUID)
                if kind == "Creature" then countKill(id, dName) end
            end
        elseif dGUID == playerGUID and sub and sub:find("_DAMAGE$") then
            lastHitter = { name = sName, t = time() }
        end
    end)
else
    -- Chat based fallback: kills that grant experience are read from the chat line.
    -- A kill can be seen both ways (chat line and the creature dying): each one is counted once.
    local byXP, byHealth = {}, {}        -- name -> list of GetTime() of kills counted that way
    local function remember(list, name)
        if not name then return end
        list[name] = list[name] or {}
        table.insert(list[name], GetTime())
    end
    local function matched(list, name)
        local l = name and list[name]
        if not l then return false end
        local now = GetTime()
        for i = #l, 1, -1 do
            if now - l[i] > 5 then table.remove(l, i) end
        end
        if #l > 0 then table.remove(l, 1) return true end
        return false
    end
    local xpPatterns
    WFD:On("CHAT_MSG_COMBAT_XP_GAIN", function(_, msg)
        if WFD.paused or not WFD.C or type(msg) ~= "string" or (issecretvalue and issecretvalue(msg)) then return end
        if not xpPatterns then
            xpPatterns = {}
            for _, n in ipairs({ "COMBATLOG_XPGAIN_FIRSTPERSON", "COMBATLOG_XPGAIN_FIRSTPERSON_GROUP", "COMBATLOG_XPGAIN_FIRSTPERSON_RAID" }) do
                local gs = _G[n]
                if gs then
                    local p = WFD:Pattern(gs)
                    if p then xpPatterns[#xpPatterns + 1] = (p:gsub("%$$", "")) end
                end
            end
        end
        for _, p in ipairs(xpPatterns) do
            local name = msg:match(p)
            if name then
                if not matched(byHealth, name) then
                    countKill(nameToId[name] or name, name)
                    remember(byXP, name)
                end
                return
            end
        end
    end)

    -- Kills without experience (grey creatures) never reach the chat. They are seen instead:
    -- a creature you were fighting (it had you on its threat list) that dies while it is your target
    -- or shows a name plate, and that no one else had tapped.
    -- A critter (a deer, a rabbit) never fights back, so it never has you on a threat list either:
    -- your target that was alive a moment ago and dies while you are fighting counts as well.
    local engaged, counted, aliveAt = {}, {}, {}   -- guid -> GetTime() of the last fight / counted / last seen alive
    local fightEnd = 0                              -- GetTime() when the last fight ended
    local debug                                     -- /wfd killdebug: what the kill tracking sees
    local function say(...) if debug then print("|cff88ccffWFD kill|r", ...) end end
    -- your target, or the soft target newer clients pick for you without a click
    local AIMED = { target = true, softenemy = true, softinteract = true }
    local function fighting() return (UnitAffectingCombat and UnitAffectingCombat("player")) or GetTime() - fightEnd < 3 end
    -- the units a creature can be seen as; party and raid members (players) are left out at once,
    -- their health changes all the time in a group
    local function creatureUnit(unit)
        return AIMED[unit] or unit == "focus" or unit == "mouseover" or unit:find("^nameplate") or unit:find("^boss")
    end
    local function watch(unit, why)
        if WFD.paused or not WFD.C or type(unit) ~= "string" or not creatureUnit(unit) or not UnitExists(unit) then return end
        local guid = UnitGUID(unit)
        local kind, id = WFD:ParseGUID(guid)
        if kind ~= "Creature" or not id or UnitIsPlayer(unit) then return end
        if not UnitIsDead(unit) then
            if AIMED[unit] then aliveAt[guid] = GetTime() end
            local ok, st = false, nil
            if UnitThreatSituation then ok, st = pcall(UnitThreatSituation, "player", unit) end
            if ok and st and not (issecretvalue and issecretvalue(st)) then
                engaged[guid] = GetTime()
                -- 2 and 3: the creature is after you. Without a combat log that is the best guess at a killer
                if st >= 2 then lastThreat = { name = UnitName(unit), t = time() } end
            end
            return
        end
        if counted[guid] then return end
        local t = engaged[guid]
        if not t and AIMED[unit] and aliveAt[guid] and GetTime() - aliveAt[guid] < 30 and fighting() then t = GetTime() end
        say(why or "?", unit, UnitName(unit), "dead", "fight:", tostring(t ~= nil), "tapped by others:", tostring(UnitIsTapDenied and UnitIsTapDenied(unit)))
        if not t or GetTime() - t > 60 then return end
        if UnitIsTapDenied and UnitIsTapDenied(unit) then return end      -- someone else's kill
        counted[guid] = GetTime()
        engaged[guid] = nil
        cacheUnit(unit)
        local name = UnitName(unit)
        if not matched(byXP, name) then
            countKill(id, name)
            remember(byHealth, name)
        end
    end
    for _, ev in ipairs({ "UNIT_HEALTH", "UNIT_THREAT_LIST_UPDATE", "UNIT_FLAGS" }) do
        WFD:On(ev, function(_, unit) watch(unit, ev) end)
    end
    function WFD:KillDebug()
        debug = not debug
        print("|cffffd100WoW Forever Diary:|r kill debug " .. (debug and "on" or "off"))
    end
    -- a blow that kills at once never puts you on the threat list: a wound on your target or a name plate
    -- while you are fighting counts as engaged too
    WFD:On("UNIT_COMBAT", function(_, unit, action, _, amount)
        -- this client hands some combat numbers out as secret values that throw when compared:
        -- a wound of secret size is still a wound
        if issecretvalue and issecretvalue(action) then return end
        if issecretvalue and issecretvalue(amount) then amount = 1 end
        if type(unit) ~= "string" or action ~= "WOUND" or not (amount and amount > 0) then return end
        if not (AIMED[unit] or unit:find("^nameplate")) then return end
        if not (UnitAffectingCombat and UnitAffectingCombat("player")) and not UnitIsDead(unit) then return end
        local guid = UnitExists(unit) and UnitGUID(unit)
        if guid then engaged[guid] = GetTime() end
        say("UNIT_COMBAT", unit, action, amount)
        watch(unit, "UNIT_COMBAT")
    end)
    WFD:On("PLAYER_TARGET_CHANGED", function() watch("target", "TARGET") end)
    WFD:On("PLAYER_SOFT_ENEMY_CHANGED", function() watch("softenemy", "SOFT") end)
    WFD:On("PLAYER_SOFT_INTERACT_CHANGED", function() watch("softinteract", "SOFT") end)
    WFD:On("PLAYER_REGEN_ENABLED", function()
        fightEnd = GetTime()
        watch("target", "REGEN")
        -- forget fights long over
        local now = GetTime()
        for guid, t in pairs(engaged) do if now - t > 120 then engaged[guid] = nil end end
        for guid, t in pairs(counted) do if now - t > 600 then counted[guid] = nil end end
        for guid, t in pairs(aliveAt) do if now - t > 120 then aliveAt[guid] = nil end end
    end)

    local hitPatterns
    local function hit(_, msg)
        if type(msg) ~= "string" or (issecretvalue and issecretvalue(msg)) then return end
        if not hitPatterns then
            hitPatterns = {}
            for _, n in ipairs({ "COMBATHITOTHERSELF", "COMBATHITCRITOTHERSELF", "MISSEDOTHERSELF" }) do
                local gs = _G[n]
                if gs then
                    local p = WFD:Pattern(gs)
                    if p then hitPatterns[#hitPatterns + 1] = (p:gsub("%$$", "")) end
                end
            end
        end
        for _, p in ipairs(hitPatterns) do
            local name = msg:match(p)
            if name then lastHitter = { name = name, t = time() } return end
        end
    end
    WFD:On("CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", hit)
    WFD:On("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", hit)
end

WFD:On("PLAYER_DEAD", function()
    if WFD.paused or not WFD.C then return end
    local C = WFD.C
    local d = WFD:Day()
    d.deaths = d.deaths + 1
    C.deathTotal = (C.deathTotal or 0) + 1

    local by
    if lastHitter and time() - lastHitter.t < 12 then by = lastHitter.name end
    if not by and lastThreat and time() - lastThreat.t < 12 then by = lastThreat.name end
    if not by and UnitExists("target") and UnitCanAttack("player", "target") then
        by = UnitName("target")
    end
    if by then
        local n = C.nemesis[by]
        if not n then n = { n = 0 }; C.nemesis[by] = n end
        n.n = n.n + 1
        n.last = time()
        n.zone = WFD.zoneName
        d.deathBy[#d.deathBy + 1] = by
    end

    local map, x, y = WFD:PlayerPos()
    -- the killer goes with the grave: deathBy only holds the deaths whose killer is known
    if map then d.dpos[#d.dpos + 1] = { map, x, y, by } end
    if WFD.NoteFate then WFD:NoteFate(by, map, x, y) end
    WFD:Signal("death", by)

    WFD:Milestone("death", WFD:DeathText(by, WFD.zoneName), C.deathTotal == 1, { zone = WFD.zoneName, by = by })
    if WFD.IsHardcore and WFD:IsHardcore() then WFD:WriteObituary(by) end
end)

-- the line of a death, with the place in the case its language needs ("Gestorben im Wald von Elwynn")
function WFD:DeathText(by, zone)
    local place = self:Place(zone or "?", "in")
    if by then return format(L["Died to %s in %s"], by, place) end
    return format(L["Died in %s"], place)
end

WFD:OnInit(function()
    playerGUID = UnitGUID("player")
    -- deaths noted before they kept their place: the place and the foe are read back from the sentence once,
    -- and German sentences get the place with its article ("in Wald von Elwynn" read wrong)
    local C = WFD.C
    if not C or C.deathPlaces or WFD.demo then return end
    for _, ev in ipairs(C.events or {}) do
        if ev.k == "death" and not ev.zone and type(ev.s) == "string" then
            local by, zone = ev.s:match("^Getötet von (.-) in (.+)$")
            if not zone then by, zone = ev.s:match("^Gefallen durch (.-) in (.+)$") end
            if not zone then zone = ev.s:match("^Gestorben in (.+)$") end
            local german = zone ~= nil
            if not zone then by, zone = ev.s:match("^Died to (.-) in (.+)$") end
            if not zone then zone = ev.s:match("^Died in (.+)$") end
            if zone then
                ev.zone, ev.by = zone, ev.by or by
                if german == (WFD.locale == "deDE") then ev.s = WFD:DeathText(ev.by, zone) end
            end
        end
    end
    C.deathPlaces = true
end)
