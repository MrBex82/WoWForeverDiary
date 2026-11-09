-- Dungeon runs: who came along, which bosses fell, what dropped and who did not make it.
local ADDON, WFD = ...
local L = WFD.L
local format, max = string.format, math.max

local run            -- the run in progress (it also lives in C.runs)
local lastKillId     -- { id, t } of the most recent kill, to paint the last boss

-- everyone in the group except the player: name -> { classFile, class, level }
local function members()
    local list = {}
    local n = GetNumGroupMembers and GetNumGroupMembers() or 0
    local raid = IsInRaid and IsInRaid()
    local prefix = raid and "raid" or "party"
    local count = raid and n or max(0, n - 1)
    for i = 1, count do
        local u = prefix .. i
        if UnitExists(u) and not UnitIsUnit(u, "player") then
            local name = UnitName(u)
            local class, cf = UnitClass(u)
            if name then list[name] = { classFile = cf, class = class, level = UnitLevel(u) } end
        end
    end
    return list
end

local function addMembers()
    if not run then return end
    for k, v in pairs(members()) do run.party[k] = v end
end

local function startRun(name)
    local C = WFD.C
    C.runs = C.runs or {}
    local last = C.runs[#C.runs]
    if last and last.name == name and last.t1 and time() - last.t1 < 1800 then
        run = last              -- back inside after a short break: still the same run
        run.t1 = nil
    else
        run = { name = name, t0 = time(), day = WFD:DayIndex(), party = {}, bosses = {}, kills = 0, deaths = {}, loot = {},
            level = UnitLevel("player") }
        C.runs[#C.runs + 1] = run
    end
    addMembers()
    WFD.dirty = true
end

local function endRun()
    if run then
        run.t1 = time()
        run = nil
        WFD.dirty = true
    end
end

WFD:On("PLAYER_ENTERING_WORLD", function()
    if WFD.paused or not WFD.C then return end
    local inside, kind = IsInInstance()
    if inside and (kind == "party" or kind == "raid") then
        local name = GetInstanceInfo()
        if name and (not run or run.name ~= name) then
            endRun()
            startRun(name)
        end
    else
        endRun()
    end
end)

WFD:On("GROUP_ROSTER_UPDATE", function() if not WFD.paused then addMembers() end end)

WFD:OnSignal("kill", function(id)
    lastKillId = { id = id, t = time() }
    if run then
        run.kills = run.kills + 1
        -- the kill is reported after the end of the encounter in newer clients: the boss it belongs to
        -- gets its creature for the painting then (only if the names agree)
        local l = run.last
        local m = WFD.C and WFD.C.mobs and WFD.C.mobs[id]
        if l and not l.npc and time() - (l.t or 0) < 15 and m and m.name == l.name then l.npc = id end
    end
end)

WFD:OnSignal("death", function(by)
    if run then run.deaths[#run.deaths + 1] = { who = UnitName("player"), by = by, me = true } end
end)

WFD:OnSignal("loot", function(link, quality)
    if run and quality >= 2 and #run.loot < 30 then run.loot[#run.loot + 1] = link end
end)

-- a boss encounter won: remember it, and paint the moment
local lastBossMilestone
WFD:On("ENCOUNTER_END", function(_, encounterID, name, _, _, success)
    if WFD.paused or not WFD.C or success ~= 1 or not name then return end
    local C = WFD.C
    C.encounters = C.encounters or {}
    C.encounters[name] = (C.encounters[name] or 0) + 1
    if run then
        run.bosses[#run.bosses + 1] = name
        local npc = lastKillId and time() - lastKillId.t < 15 and lastKillId.id or nil
        if not npc then
            -- no kill reported yet: a creature of this name slain before (the boss of an earlier run)
            for id, m in pairs(C.mobs or {}) do
                if m.name == name then npc = id break end
            end
        end
        run.last = { name = name, gear = WFD:CaptureGear(), npc = npc, t = time() }
    end
    if C.encounters[name] == 1 and lastBossMilestone ~= name and WFD:FirstBossNoted(name) then
        lastBossMilestone = name
        WFD:Milestone("boss", format(L["First victory over the boss %s!"], name), true,
            { npc = lastKillId and time() - lastKillId.t < 15 and lastKillId.id or nil })
    end
    WFD.dirty = true
end)

-- fallen group members (the player's own deaths come through the "death" signal).
-- Read from the health of the group units, not the combat log: newer clients forbid the combat log to addons,
-- and merely registering for it gets the addon blocked.
local down = {}      -- name -> true while that member lies dead
WFD:On("UNIT_HEALTH", function(_, unit)
    local isSecret = issecretvalue
    if not run or type(unit) ~= "string" or (isSecret and isSecret(unit)) then return end
    if not (unit:find("^party%d") or unit:find("^raid%d")) then return end
    local name = UnitName(unit)
    if not name or (isSecret and isSecret(name)) or not run.party[name] then return end
    local dead = UnitIsDeadOrGhost(unit)
    if isSecret and isSecret(dead) then return end
    if dead and not down[name] then
        down[name] = true
        run.deaths[#run.deaths + 1] = { who = name }
        WFD.dirty = true
    elseif not dead then
        down[name] = nil
    end
end)
