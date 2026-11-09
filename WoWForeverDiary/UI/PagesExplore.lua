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

UI:RegisterRenderer("nextgoals", function(pool, page, side, canvas)
    local g = UI.book.collection
    if not g then return end
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Next goals"], L["Where will the road lead tomorrow?"], -56)

    -- tasks of the day, with their progress
    local tasks = WFD.TodayChallenges and WFD:TodayChallenges()
    if tasks and #tasks.list > 0 then
        local doneN = 0
        for _ in pairs(tasks.done) do doneN = doneN + 1 end
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Tasks of the day"], doneN .. " / " .. #tasks.list)
        y = y - 22
        local today = WFD:DayIndex()
        for i, task in ipairs(tasks.list) do
            local done = tasks.done[i]
            local v, gl = WFD:ChallengeProgress(today, task)
            pool:Plaque(tx + 10, y - 9, 16, UI.Icon("task"), done and GREEN or LOCKED, done and true or false)
            local t = pool:Text(12, done and c.inkSoft or c.ink, UI.FONT)
            t:SetText(WFD:ChallengeText(task))
            t:SetWidth(tw - 26 - 96)       -- a long task wraps onto a second line
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 26, y - 3)
            if done then
                local ok = pool:Text(10, GREEN, UI.FONT, "RIGHT")
                ok:SetText(L["done"])
                ok:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 3)
            elseif gl > 1 then         -- a task done in one go ("travel to ...") needs no "0 / 1"
                local pv = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
                pv:SetText(WFD:TaskValueText(task, v) .. " / " .. gl)
                pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 1)
                UI.ProgressBar(pool, canvas, tx + tw - 70, y - 14, 70, 3, v / max(1, gl), GREEN)
            end
            y = y - max(22, t:GetStringHeight() + 9)
        end
        y = y - 10
    end

    -- task of the week
    local wk, w
    if WFD.ThisWeek then wk, w = WFD:ThisWeek() end
    if wk and wk.task then
        local from, to = WFD:WeekDays(w)
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Task of the week"], format(L["Days %d-%d"], from, to))
        y = y - 22
        local v, gl = WFD:WeeklyProgress(w, wk.task)
        local done = wk.done
        pool:Plaque(tx + 12, y - 11, 20, UI.Icon("first"), done and GREEN or GOLD, true)
        local t = pool:Text(12, done and c.inkSoft or c.ink, UI.FONT)
        t:SetText(WFD:WeeklyText(wk.task))
        t:SetWidth(tw - 30 - 96)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 4)
        if done then
            local ok = pool:Text(10, GREEN, UI.FONT, "RIGHT")
            ok:SetText(L["done"])
            ok:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 4)
        elseif gl > 1 then
            local pv = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
            pv:SetText(WFD:TaskValueText(wk.task, v) .. " / " .. gl)
            pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
            UI.ProgressBar(pool, canvas, tx + tw - 70, y - 15, 70, 3, v / max(1, gl), GOLD)
        end
        y = y - max(34, t:GetStringHeight() + 22)
    end

    -- destination of the day
    local dest, mainCont = destination(g)
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Destination of the day"])
    y = y - 22
    if dest then
        local it = dest.it
        pool:Plaque(tx + 24, y - 24, 40, UI.IconPath({ it.icon }, "sight"), TEAL, true)
        local n = pool:Text(19, c.ink, UI.HEAD)
        n:SetText(it.name)
        n:SetWordWrap(false)
        n:SetWidth(tw - 56)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 54, y - 4)
        local s = pool:Text(9, c.redInk, UI.FONT)
        s:SetText(L[dest.grp.def.label]:upper())
        s:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 54, y - 28)
        local h = pool:Text(11, c.inkSoft, UI.FONT)
        h:SetText(L["You have not seen this place yet."])
        h:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 54, y - 41)
        local mapID = landmarkMap(it)
        local hot
        if mapID then
            hot = pool:Hot({ it.name, L["You have not seen this place yet."], L["Click to set a waypoint on the map."] },
                function()
                    if not setWaypoint(mapID) then
                        local fallback = goTo("landmarks")
                        if fallback then fallback() end
                    end
                end)
        else
            hot = pool:Hot({ it.name, L["You have not seen this place yet."], L["Click for all landmarks."] }, goTo("landmarks"))
        end
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
        hot:SetSize(tw, 56)
    else
        local n = pool:Text(13, c.inkSoft, UI.FONT)
        n:SetText(L["You have seen every landmark. Remarkable!"])
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 8)
    end
    y = y - 66

    -- the honours closest to their next tier
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Almost there"])
    y = y - 20
    local near = {}
    for _, e in ipairs(g.honours) do
        if e.next and not e.hidden then
            near[#near + 1] = { e = e, f = (e.value - e.prev) / max(1, e.next - e.prev) }
        end
    end
    table.sort(near, function(a, b) return a.f > b.f end)
    for i = 1, min((tasks and 2 or 4) - ((wk and wk.task) and 1 or 0), #near) do
        local e, f = near[i].e, near[i].f
        local m = WFD:MetalOf(e.tier + 1, e.n)
        local ic = pool:Icon(UI.IconPath(e.def.icon), 20)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 2, y - 2)
        local n = pool:Text(12, c.ink, UI.FONT)
        n:SetText(L[e.def.name] .. "  |cff" .. UI.InkHex(m.col) .. L[m.name] .. "|r")
        n:SetWordWrap(false)
        n:SetWidth(tw - 30 - 96)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 2)
        local d = pool:Text(9, c.inkFaint, UI.FONT)
        d:SetText(WFD:HonourText(e.def, e.next))
        d:SetWordWrap(false)
        d:SetWidth(tw - 30 - 96)
        d:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 16)
        local v = e.value
        if e.def.m == "km" then v = WFD:Dec(floor(v * 10) / 10) end
        local pv = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        pv:SetText(v .. " / " .. e.next)
        pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
        UI.ProgressBar(pool, canvas, tx + tw - 88, y - 17, 88, 4, f, c.redInk)
        local hot = pool:Hot({ L[e.def.name], WFD:HonourText(e.def, e.next) }, goTo("honour"))
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, 28)
        y = y - 32
    end
    y = y - 6

    -- regions still waiting, on the continent you know best
    local cont
    for _, e in ipairs(g.conts) do if e.id == mainCont then cont = e end end
    cont = cont or g.conts[1]
    if cont then
        local open = {}
        for _, z in ipairs(cont.zones) do if not z.visited then open[#open + 1] = z end end
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Unexplored regions"], cont.visited .. " / " .. cont.total)
        y = y - 22
        local colW = (tw - 12) / 2
        local rowsLeft = max(0, floor(((UI.PH - UI.BOTTOM) + y) / 24))
        for i = 1, min(#open, rowsLeft * 2) do
            local z = open[i]
            local x = tx + ((i - 1) % 2) * (colW + 12)
            local ry = y - floor((i - 1) / 2) * 24
            local q = pool:Text(12, c.redInk, UI.HEAD)
            q:SetText("?")
            q:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 2, ry - 1)
            local n = pool:Text(12, c.inkSoft, UI.FONT)
            n:SetText(z.name)
            n:SetWordWrap(false)
            n:SetWidth(colW - 16)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 14, ry - 2)
        end
        if #open == 0 then
            local n = pool:Text(12, c.inkSoft, UI.FONT)
            n:SetText(L["Every region of this continent is explored."])
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 2)
        end
    end
end)

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
