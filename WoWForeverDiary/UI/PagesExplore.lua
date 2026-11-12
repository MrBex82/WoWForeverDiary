-- Exploring and collecting: the collection overview with next goals, and the atlas of both continents.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

local LOCKED = { 0.46, 0.39, 0.30, 1 }
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"
local TEAL = { 0.30, 0.66, 0.62, 1 }
local GREEN = UI.c.good
local GOLD = { 0.86, 0.62, 0.18, 1 }

local function goTo(key)
    return function()
        local p = UI.book and UI.book.sectionStart[key]
        if p then UI:GoToPage(p) end
    end
end

------------------------------------------------------------------------
-- Everything worth collecting, counted once per build of the book
------------------------------------------------------------------------
local function gather()
    local honours, sum = WFD:HonourState()
    local groups, lmFound, lmTotal = WFD:LandmarkState()
    local conts, zVisited, zTotal = WFD:AtlasState()
    local kinds = 0
    for _ in pairs(WFD.C.mobs) do kinds = kinds + 1 end
    local tiers = UI.BESTIARY_TIERS or {}
    local nextTier
    for _, t in ipairs(tiers) do
        if kinds < t[1] then nextTier = t break end
    end
    local catches = 0
    for _ in pairs(WFD.C.catch or {}) do catches = catches + 1 end
    local nextFish
    for _, t in ipairs(UI.FISH_TIERS or {}) do
        if catches < t[1] then nextFish = t break end
    end
    local dFound, dTotal = 0, 0
    for _, g in ipairs(groups) do
        if g.def.key == "dungeons" or g.def.key == "raids" then
            dFound, dTotal = dFound + g.found, dTotal + g.total
        end
    end
    local sFound, sTotal = 0, 0
    for _, e in ipairs(honours) do
        if e.def.secret then
            sTotal = sTotal + 1
            if not e.hidden then sFound = sFound + 1 end
        end
    end
    return {
        honours = honours, sum = sum, groups = groups, lmFound = lmFound, lmTotal = lmTotal,
        conts = conts, zVisited = zVisited, zTotal = zTotal, kinds = kinds, nextTier = nextTier,
        catches = catches, nextFish = nextFish, lastFish = (UI.FISH_TIERS or {})[#(UI.FISH_TIERS or {})],
        lastTier = tiers[#tiers], dFound = dFound, dTotal = dTotal, sFound = sFound, sTotal = sTotal,
    }
end

UI.CollectionState = gather       -- the "Today" page shows the next goals too

------------------------------------------------------------------------
-- The collection: one bar per collection, and what to do next
------------------------------------------------------------------------
-- (the collection is a view of the travel desk now: UI/Views/Goals.lua)

-- a place you have not seen yet, the same one all day long
local function destination(g)
    local mainCont, best = nil, -1
    for _, e in ipairs(g.conts) do
        if e.secs > best then mainCont, best = e.id, e.secs end
    end
    local cand = {}
    for _, grp in ipairs(g.groups) do
        local cont = grp.def.cont
        if grp.def.key ~= "raids" and (cont == nil or cont == mainCont) then
            for _, it in ipairs(grp.items) do
                if not it.found then cand[#cand + 1] = { it = it, grp = grp } end
            end
        end
    end
    if #cand == 0 then return nil end
    return cand[(WFD:NumDays() * 7919) % #cand + 1], mainCont
end

-- the map a landmark can be pointed to on: its own map (a zone or a city), or the zone around a dungeon.
-- Small places inside a zone have no map and no known position: nothing is guessed for them.
local landmarkMaps
-- the zone around the entrance of a dungeon, as the area ID of that zone (names then come from the game in every
-- language). Only entrances that lie in one clear zone: Blackrock Mountain lies between two and is left out.
local DUNGEON_ZONE = {
    [2437] = 1637,  -- Ragefire Chasm: Orgrimmar
    [1581] = 40,    -- The Deadmines: Westfall
    [718] = 17,     -- Wailing Caverns: The Barrens
    [209] = 130,    -- Shadowfang Keep: Silverpine Forest
    [717] = 1519,   -- The Stockade: Stormwind City
    [719] = 331,    -- Blackfathom Deeps: Ashenvale
    [721] = 1,      -- Gnomeregan: Dun Morogh
    [491] = 17,     -- Razorfen Kraul: The Barrens
    [796] = 85,     -- Scarlet Monastery: Tirisfal Glades
    [722] = 17,     -- Razorfen Downs: The Barrens
    [1337] = 3,     -- Uldaman: Badlands
    [1176] = 440,   -- Zul'Farrak: Tanaris
    [2100] = 405,   -- Maraudon: Desolace
    [1477] = 8,     -- The Temple of Atal'Hakkar: Swamp of Sorrows
    [2557] = 357,   -- Dire Maul: Feralas
    [2057] = 139,   -- Stratholme: Eastern Plaguelands
    [2017] = 28,    -- Scholomance: Western Plaguelands
}
local function landmarkMap(it)
    if not (C_Map and C_Map.GetMapChildrenInfo and C_Map.SetUserWaypoint) then return nil end
    if not landmarkMaps then
        landmarkMaps = {}
        for _, cont in ipairs(WFD.CONTINENTS) do
            local ok, kids = pcall(C_Map.GetMapChildrenInfo, cont, nil, true)
            if ok and type(kids) == "table" then
                for _, k in ipairs(kids) do
                    if k.name and k.mapID and not landmarkMaps[k.name] then landmarkMaps[k.name] = k.mapID end
                end
            end
        end
    end
    -- the map of a name: the same name, or the only map whose name contains it ("Brachland" - "Das Brachland")
    local function find(name)
        if not name or name == "" then return nil end
        if landmarkMaps[name] then return landmarkMaps[name] end
        local found, count = nil, 0
        for n, mid in pairs(landmarkMaps) do
            if n:find(name, 1, true) then found, count = mid, count + 1 end
        end
        return count == 1 and found or nil
    end
    local id = landmarkMaps[it.name]
    if not id and DUNGEON_ZONE[it.id] and C_Map.GetAreaInfo then
        local ok, zoneName = pcall(C_Map.GetAreaInfo, DUNGEON_ZONE[it.id])
        id = ok and find(zoneName) or nil
    end
    if id and C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(id) then return nil end
    return id
end

-- the waypoint of the game, in the middle of the map: the arrow shows the way into the area
local function setWaypoint(mapID)
    local ok = pcall(function()
        local pt = UiMapPoint and UiMapPoint.CreateFromCoordinates and UiMapPoint.CreateFromCoordinates(mapID, 0.5, 0.5)
            or { uiMapID = mapID, position = CreateVector2D(0.5, 0.5) }
        C_Map.SetUserWaypoint(pt)
        if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
    end)
    if ok then
        print("|cffffd100WoW Forever Diary:|r " .. format(L["Waypoint set: %s"], WFD:MapName(mapID)))
    end
    return ok
end

-- (the atlas is the world map of the travel desk now: UI/Views/World.lua)

------------------------------------------------------------------------
-- Tasks: the day, the week and the month on one spread, every text in full
------------------------------------------------------------------------
-- (the tasks are a view of the travel desk now: UI/Views/Goals.lua)

-- for Start on the travel desk: the destination of the day (nil when every landmark was seen) and the way to it
UI.DayDestination = function(g)
    g = g or gather()
    local dest = destination(g)
    if not dest then return nil end
    local mapID = landmarkMap(dest.it)
    return { name = dest.it.name, icon = UI.IconPath({ dest.it.icon }, "sight"), group = WFD.L[dest.grp.def.label],
        go = mapID and function() return setWaypoint(mapID) end or nil }
end
