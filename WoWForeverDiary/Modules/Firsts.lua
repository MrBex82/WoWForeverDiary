-- First times: the first mount, the first dungeon, the first gold coin ... each with its day, place and detail.
-- Recorded as they happen; for a diary begun earlier, whatever older entries tell is filled in once.
local ADDON, WFD = ...
local L = WFD.L

-- in the order of a typical life; label = how the page names it, toast = announce it (others have a milestone already)
WFD.FIRSTS = {
    { key = "kill",     label = "First creature slain",  icon = { "INV_Sword_04" } },
    { key = "quest",    label = "First quest completed", icon = { "INV_Scroll_03" } },
    { key = "level",    label = "First level up",        icon = { "Spell_Holy_SurgeOfLight" } },
    { key = "green",    label = "First uncommon item",   icon = { "INV_Misc_Gem_Emerald_02", "INV_Misc_Gem_Emerald_01" }, toast = true },
    { key = "death",    label = "First death",           icon = { "INV_Misc_Bone_HumanSkull_01" } },
    { key = "group",    label = "First group",           icon = { "Ability_Warrior_RallyingCry" }, toast = true },
    { key = "elite",    label = "First elite slain",     icon = { "INV_Misc_Bone_ElfSkull_01" }, toast = true },
    { key = "trade",    label = "First trade",           icon = { "INV_Misc_Bag_10" }, toast = true },
    { key = "hearth",   label = "First hearthstone",     icon = { "INV_Misc_Rune_01" }, toast = true },
    { key = "landmark", label = "First landmark",        icon = { "INV_Misc_Spyglass_03", "INV_Misc_Spyglass_02" } },
    { key = "honour",   label = "First honour",          icon = { "INV_Misc_Ribbon_01" } },
    { key = "blue",     label = "First rare item",       icon = { "INV_Misc_Gem_Sapphire_02", "INV_Misc_Gem_Sapphire_01" } },
    { key = "rare",     label = "First rare creature",   icon = { "Ability_Hunter_SniperShot" } },
    { key = "flight",   label = "First flight",          icon = { "Ability_Hunter_EagleEye", "INV_Feather_05" }, toast = true },
    { key = "gold",     label = "First gold coin",       icon = { "INV_Misc_Coin_01" }, toast = true },
    { key = "dungeon",  label = "First dungeon",         icon = { "INV_Misc_Key_03", "INV_Misc_Key_04" } },
    { key = "boss",     label = "First boss",            icon = { "INV_Misc_Head_Dragon_01" } },
    { key = "skill",    label = "First skill at 75",     icon = { "Trade_BlackSmithing", "Trade_Mining" } },
    { key = "mount",    label = "First mount",           icon = { "Ability_Mount_RidingHorse", "Ability_Mount_WhiteTiger" }, toast = true, shot = true },
    { key = "epic",     label = "First epic item",       icon = { "INV_Misc_Gem_Amethyst_02", "INV_Misc_Gem_Amethyst_01" } },
}
local DEF = {}
for _, f in ipairs(WFD.FIRSTS) do DEF[f.key] = f end

local function note(key, detail, t, quiet)
    local C = WFD.C
    if not C or WFD.paused or WFD.demo then return end
    C.firsts = C.firsts or {}
    if C.firsts[key] then return end
    t = t or time()
    C.firsts[key] = { t = t, day = WFD:DayIndex(t), zone = (not quiet) and WFD.zoneName or nil, s = detail }
    WFD.dirty = true
    local def = DEF[key]
    if def and def.toast and not quiet then
        local text = L[def.label] .. ((detail and detail ~= "") and (": " .. detail) or "")
        WFD:Milestone("first", text, def.shot, { first = key })
    end
end

-- the part after "...: " of a logged moment
local function subject(s) return s and (s:match(":%s*(.+)$") or s) end

------------------------------------------------------------------------
-- As it happens
------------------------------------------------------------------------
WFD:OnSignal("kill", function(_, name, m)
    note("kill", name)
    local cls = m and m.cls
    if cls == "elite" or cls == "rareelite" or cls == "worldboss" then note("elite", name) end
end)
WFD:OnSignal("death", function(by) note("death", by) end)
WFD:OnSignal("loot", function(link, quality)
    local name = WFD:ItemName(link)
    if quality == 2 then note("green", name) elseif quality == 3 then note("blue", name) elseif quality and quality >= 4 then note("epic", name) end
end)

local FROM_MILESTONE = { level = "level", quest = "quest", dungeon = "dungeon", boss = "boss", rare = "rare",
    landmark = "landmark", honour = "honour", skill = "skill" }
WFD:OnSignal("milestone", function(ev)
    local key = FROM_MILESTONE[ev.k]
    if not key then return end
    if key == "dungeon" then
        local name = GetInstanceInfo and GetInstanceInfo()
        note(key, name or WFD.zoneName)
    elseif key == "level" then
        note(key, ev.s)
    else
        note(key, subject(ev.s))
    end
end)

WFD:On("TRADE_SHOW", function()
    note("trade", UnitName("NPC") or UnitName("npc"))
end)

-- the destination of a flight, for "first flight"
local flightTo
if hooksecurefunc and TakeTaxiNode then
    pcall(hooksecurefunc, "TakeTaxiNode", function(i)
        flightTo = TaxiNodeName and TaxiNodeName(i) or nil
    end)
end

local function poll()
    local C = WFD.C
    if not C or WFD.paused or WFD.demo then return end
    if UnitOnTaxi and UnitOnTaxi("player") then
        note("flight", flightTo and flightTo:match("^([^,]+)") or nil)
    elseif IsMounted and IsMounted() then
        note("mount")
    end
    if GetMoney and GetMoney() >= 10000 then note("gold") end
    if (GetNumGroupMembers and GetNumGroupMembers() or 0) > 1 then
        local who = UnitName("party1")
        note("group", who)
    end
    if (C.hearthCount or 0) > 0 then note("hearth", GetBindLocation and GetBindLocation() or nil) end
end

------------------------------------------------------------------------
-- From older entries (once): the day is right, the place may be unknown
------------------------------------------------------------------------
local FROM_EVENT = { level = "level", quest = "quest", dungeon = "dungeon", boss = "boss", rare = "rare",
    landmark = "landmark", honour = "honour", skill = "skill", epic = "epic", rareitem = "blue", death = "death" }

local function backfill()
    local C = WFD.C
    C.firsts = C.firsts or {}
    local events = {}
    for _, ev in ipairs(C.events or {}) do events[#events + 1] = ev end
    table.sort(events, function(a, b) return (a.t or 0) < (b.t or 0) end)
    for _, ev in ipairs(events) do
        local key = FROM_EVENT[ev.k]
        if key and ev.t then note(key, key == "level" and ev.s or subject(ev.s), ev.t, true) end
    end
    -- first kill: the creature met first
    local firstMob
    for _, m in pairs(C.mobs or {}) do
        if m.first and (not firstMob or m.first < firstMob.first) then firstMob = m end
    end
    if firstMob then note("kill", firstMob.name, firstMob.first, true) end
    for _, m in pairs(C.mobs or {}) do
        if m.first and (m.cls == "elite" or m.cls == "rareelite" or m.cls == "worldboss") then
            local e = C.firsts.elite
            if not e or m.first < e.t then C.firsts.elite = nil; note("elite", m.name, m.first, true) end
        end
    end
    -- days: the first green item, the first death, the first flight
    for d = 1, WFD:NumDays() do
        local day = C.days[d]
        if day then
            local t = day.t0 or WFD:DayTime(d)
            for _, e in pairs(day.loot or {}) do
                if e.q == 2 then note("green", WFD:ItemName(e.link), t, true) end
            end
            if (day.deaths or 0) > 0 then note("death", day.deathBy and day.deathBy[1], t, true) end
            if (day.flights or 0) > 0 then note("flight", nil, t, true) end
        end
    end
    -- people: the first group, the first trade
    local function earliest(tbl, key)
        local bestName, best
        for name, e in pairs(tbl or {}) do
            if e.first and (not best or e.first < best) then bestName, best = e.name or name, e.first end
        end
        if best then note(key, bestName, best, true) end
    end
    earliest(C.companions, "group")
    earliest(C.traders, "trade")
end

-- the first green, blue and purple item from the days' loot. Diaries filled in before the item qualities
-- were read right (Tracker_Loot sets them again first) get this once more.
local ITEM_FIRST = { [2] = "green", [3] = "blue" }
local function backfillItems()
    local C = WFD.C
    for d = 1, WFD:NumDays() do
        local day = C.days[d]
        if day then
            local t = day.t0 or WFD:DayTime(d)
            -- the best find of the day names it, when a day has several
            local list = {}
            for _, e in pairs(day.loot or {}) do
                if type(e) == "table" and type(e.q) == "number" then list[#list + 1] = e end
            end
            table.sort(list, function(a, b) return a.q > b.q end)
            for _, e in ipairs(list) do
                local key = ITEM_FIRST[e.q] or (e.q >= 4 and "epic") or nil
                if key then note(key, WFD:ItemName(e.link), t, true) end
            end
        end
    end
end

WFD:OnInit(function()
    local C = WFD.C
    if not C.firstsFilled then
        local ok, err = pcall(backfill)
        if not ok then WFD:Error("firsts", err) end
        C.firstsFilled = true
    end
    if not C.firstsItems and not WFD.demo then
        local ok, err = pcall(backfillItems)
        if not ok then WFD:Error("firsts", err) end
        C.firstsItems = true
    end
    if C_Timer and C_Timer.NewTicker then
        C_Timer.NewTicker(5, function()
            local ok, err = pcall(poll)
            if not ok then WFD:Error("firsts", err) end
        end)
    end
end)
