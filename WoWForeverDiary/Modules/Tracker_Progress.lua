-- Levels, XP, zones, skills, dungeons, hearthstone
local ADDON, WFD = ...
local L = WFD.L
local time, format = time, string.format

local st = {}   -- xp bookkeeping

------------------------------------------------------------------------
-- Zones
------------------------------------------------------------------------
local lastZone

-- Inside some inns the game names the inn as the zone ("Lion's Pride Inn"). The map knows better:
-- a small map inside a zone belongs to that zone. Dungeons keep the name the game gives them.
local function zoneNow()
    local real = GetRealZoneText()
    if IsInInstance() then
        local name = GetInstanceInfo and GetInstanceInfo()
        return (type(name) == "string" and name ~= "") and name or real
    end
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetMapInfo) then return real end
    local info = C_Map.GetMapInfo(C_Map.GetBestMapForUnit("player") or 0)
    -- standing in a zone: the map names it. Inside inns and town halls the game's text is the building
    -- ("Gasthaus Seenhain"), which is no land of its own. Map names this client gives in another language
    -- are put right by the list of the language file (Stormwind -> Sturmwind).
    if info and info.mapType == 3 then
        local fix = WFD.loc and WFD.loc.zoneFix
        local name = info.name and info.name ~= "" and ((fix and fix[info.name]) or info.name)
        return name or real
    end
    for _ = 1, 4 do
        if not info or not info.mapType then break end
        if info.mapType == 3 then return (info.name and info.name ~= "") and info.name or real end   -- a zone
        if info.mapType < 3 or info.mapType == 4 or not info.parentMapID then break end           -- continent, dungeon
        info = C_Map.GetMapInfo(info.parentMapID)
    end
    return real
end

-- the map of the zone you are in (a map of type zone, also from inside an inn or a cave)
local function zoneMapOf(id)
    if not (C_Map and C_Map.GetMapInfo) then return nil end
    local info = id and C_Map.GetMapInfo(id)
    for _ = 1, 5 do
        if not info then return nil end
        if info.mapType == 3 then return info.mapID end
        -- only small maps (a building, a cave) belong to the zone around them; dungeons are places of their own
        if info.mapType ~= 5 or not info.parentMapID then return nil end
        info = C_Map.GetMapInfo(info.parentMapID)
    end
end

-- a land on record under another name with the same map: the same land (the map may name it otherwise than
-- the game, or in another language)
local function knownAs(C, zone)
    if C.zones[zone] or IsInInstance() or not (C_Map and C_Map.GetBestMapForUnit) then return nil end
    local here = zoneMapOf(C_Map.GetBestMapForUnit("player"))
    if not here then return nil end
    for name, map in pairs(C.zoneMaps or {}) do
        if name ~= zone and C.zones[name] and zoneMapOf(map) == here then return name end
    end
end

local function refreshZone()
    local zone = zoneNow()
    -- a name the map gives for a land that is on record under the game's name (seen inside inns and caves)
    local alias = WFD.C and WFD.C.zoneAlias and zone and WFD.C.zoneAlias[zone]
    if alias then zone = alias end
    local sub = GetSubZoneText()
    if zone and zone ~= "" then WFD.zoneName = zone end
    WFD.subName = sub
    local C = WFD.C
    if not C or WFD.paused or not zone or zone == "" then return end
    -- flying over a land on a flight path is no visit: nothing is discovered or recorded until you land
    -- (the flight tracking checks the zone again as soon as the flight ends)
    if UnitOnTaxi and UnitOnTaxi("player") then return end

    if not C.startZone then C.startZone = zone end
    local same = knownAs(C, zone)
    if same then
        C.zoneAlias = C.zoneAlias or {}
        C.zoneAlias[zone] = same
        C.announced = C.announced or {}
        C.announced[zone] = true
        zone = same
        WFD.zoneName = zone
    end
    local z = C.zones[zone]
    -- a land already on record counts as announced, whatever the list says
    if z then C.announced = C.announced or {} C.announced[zone] = true end
    local freshLand = not z
    if not z then
        z = { first = time(), day = WFD:DayIndex(), sub = {}, visits = 0 }
        C.zones[zone] = z
        -- a land you have walked in on an earlier day is no new land, whatever name it carries now
        local walked = false
        for idx, d in pairs(C.days or {}) do
            if idx ~= WFD:DayIndex() and d.zones and d.zones[zone] then walked = true break end
        end
        if walked then C.announced = C.announced or {} C.announced[zone] = true end
        if zone ~= C.startZone then
            -- the same land is announced only once, even when its record was moved or renamed in between
            -- (a start building and the valley around it may carry different names for the same zone)
            -- the list of announced names is not touched by the renaming of stored names
            C.announced = C.announced or {}
            if not C.announced[zone] then
                C.announced[zone] = true
                WFD:Milestone("zone", format(L["Discovered a new land: %s"], zone), true)
            end
        end
    end
    if lastZone ~= zone then
        lastZone = zone
        z.visits = z.visits + 1
        WFD:Log("zone", format(L["Entered %s"], zone))
    end
    if sub and sub ~= "" and not z.sub[sub] then
        z.sub[sub] = time()
        C.subCount = (C.subCount or 0) + 1
        WFD:Log("sub", format(L["Discovered: %s (%s)"], sub, zone))
        WFD:NotePlace(zone, sub)
        -- a small note for the new place; not when the whole land is new (that note says enough), and not for a
        -- spot that carries the land's own name
        if not freshLand and sub ~= zone then WFD:Signal("place", sub, zone) end
    end
    WFD.dirty = true
end

WFD.RefreshZone = refreshZone

-- The places any character of the account found, by land: another character's album page shows them as places
-- still to find, with who found them.
function WFD:NotePlace(zone, sub)
    if self.paused or self.demo or not self.S or type(zone) ~= "string" or type(sub) ~= "string" then return end
    self.S.places = self.S.places or {}
    local z = self.S.places[zone]
    if not z then
        z = {}
        self.S.places[zone] = z
    end
    if not z[sub] then z[sub] = (self.C and self.C.name) or true end
end

-- the places this character found before the account knew about places
WFD:OnInit(function()
    local C = WFD.C
    if not C or C.placesShared or WFD.demo then return end
    for zone, z in pairs(C.zones or {}) do
        for sub in pairs(z.sub or {}) do WFD:NotePlace(zone, sub) end
    end
    C.placesShared = true
end)

-- Every place of a land: the ones found (with the time), then the ones still to find - from the area table of the
-- game (names in the client's language) and from what other characters of the account found there.
-- Returns a list of { name, t (found at) or nil, who (another character who knows it) or nil }.
function WFD:ZonePlaces(zone, mapID)
    local C = self.C
    local out, seen = {}, {}
    local z = C and C.zones and C.zones[zone]
    for name, t in pairs(z and z.sub or {}) do
        out[#out + 1] = { name = name, t = t }
        seen[name] = true
    end
    table.sort(out, function(a, b) return a.t < b.t end)
    local open = {}
    local mine = C and C.name
    local others = self.S and self.S.places and self.S.places[zone] or {}
    local function add(name, who)
        if type(name) ~= "string" or name == "" or name == zone or seen[name] then return end
        seen[name] = true
        open[#open + 1] = { name = name, who = (type(who) == "string" and who ~= mine) and who or nil }
    end
    for name, who in pairs(others) do add(name, who) end
    local ids = mapID and self.ZONE_PLACES and self.ZONE_PLACES[mapID]
    if ids and C_Map and C_Map.GetAreaInfo then
        for _, id in ipairs(ids) do add(C_Map.GetAreaInfo(id), nil) end
    end
    -- known by another character first, then by name
    table.sort(open, function(a, b)
        if (a.who ~= nil) ~= (b.who ~= nil) then return a.who ~= nil end
        return a.name < b.name
    end)
    local found = #out
    for _, e in ipairs(open) do out[#out + 1] = e end
    return out, found
end

for _, ev in ipairs({ "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA" }) do
    WFD:On(ev, refreshZone)
end

WFD:On("PLAYER_ENTERING_WORLD", function()
    refreshZone()
    if WFD.paused or not WFD.C then return end
    local inInstance = IsInInstance()
    if inInstance then
        local name = GetInstanceInfo()
        if name then
            local d = WFD:Day()
            if not d.instances[name] then
                d.instances[name] = true
                WFD.C.instances = WFD.C.instances or {}
                if not WFD.C.instances[name] then
                    WFD.C.instances[name] = time()
                    WFD:Milestone("dungeon", format(L["First visit to the dungeon %s"], name), true)
                else
                    WFD:Log("dungeon", format(L["Entered the dungeon %s"], name))
                end
            end
        end
    end
end)

------------------------------------------------------------------------
-- Level and XP
------------------------------------------------------------------------
WFD:OnInit(function()
    st.level, st.xp, st.max = UnitLevel("player"), UnitXP("player"), UnitXPMax("player")
    local C = WFD.C
    C.levelTimes = C.levelTimes or {}
    -- lands recorded before the list existed are not announced again
    C.announced = C.announced or {}
    for name in pairs(C.zones or {}) do C.announced[name] = true end
    if C.startZone then C.announced[C.startZone] = true end
    if C.fresh and not C.levelTimes[st.level] then C.levelTimes[st.level] = C.born end
    refreshZone()
end)

WFD:On("PLAYER_XP_UPDATE", function()
    if WFD.paused or not WFD.C or not st.level then return end
    local level, xp, mx = UnitLevel("player"), UnitXP("player"), UnitXPMax("player")
    local delta
    if level ~= st.level then
        delta = (st.max - st.xp) + xp
    else
        delta = xp - st.xp
    end
    st.level, st.xp, st.max = level, xp, mx
    if delta and delta > 0 then
        local d = WFD:Day()
        d.xp = d.xp + delta
        WFD.C.xpTotal = (WFD.C.xpTotal or 0) + delta
        WFD.dirty = true
    end
end)

WFD:On("PLAYER_LEVEL_UP", function(_, lvl)
    if WFD.paused or not WFD.C then return end
    lvl = tonumber(lvl) or UnitLevel("player")
    local C = WFD.C
    C.levelTimes = C.levelTimes or {}
    C.levelTimes[lvl] = time()
    -- time in the world when the level was reached (for the level timeline)
    local played = 0
    for _, day in pairs(C.days) do played = played + (day.online or 0) end
    C.levelPlayed = C.levelPlayed or {}
    C.levelPlayed[lvl] = played
    local d = WFD:Day()
    d.levels[#d.levels + 1] = lvl
    WFD:Milestone("level", format(L["Level %d reached!"], lvl), true)
end)

------------------------------------------------------------------------
-- Skills and professions
------------------------------------------------------------------------
local skillPattern
WFD:On("CHAT_MSG_SKILL", function(_, msg)
    if WFD.paused or not WFD.C or type(msg) ~= "string" or (issecretvalue and issecretvalue(msg)) then return end
    if skillPattern == nil then
        skillPattern = SKILL_RANK_UP and WFD:Pattern(SKILL_RANK_UP) or false
    end
    if not skillPattern then return end
    local name, rank = msg:match(skillPattern)
    rank = tonumber(rank)
    if not name or not rank then return end
    local C = WFD.C
    C.skills[name] = rank
    WFD:Log("skill", format(L["%s increased to %d"], name, rank))
    if rank % 75 == 0 then
        WFD:Milestone("skill", format(L["%s mastered up to %d"], name, rank), false)
    end
end)

-- Professions, read from the skill list: weapon skills and languages are no craft.
-- Fishing, first aid and cooking are named by their spells, so they count in every language.
local SECONDARY = { 7620, 3273, 2550 }
local function scanSkills()
    local C = WFD.C
    if not C or WFD.paused or WFD.demo or not (GetNumSkillLines and GetSkillLineInfo) then return end
    local secondary = {}
    for _, id in ipairs(SECONDARY) do
        local n = WFD:SpellName(id)
        if n then secondary[n] = true end
    end
    C.crafts = C.crafts or {}
    for i = 1, GetNumSkillLines() do
        local name, isHeader, _, rank, _, _, _, isAbandonable = GetSkillLineInfo(i)
        if name and not isHeader and (isAbandonable or secondary[name]) and type(rank) == "number" and rank > 0 then
            C.crafts[name] = true
            if (C.skills[name] or 0) < rank then C.skills[name] = rank end
        end
    end
end
WFD:On("SKILL_LINES_CHANGED", function() pcall(scanSkills) end)
WFD:OnInit(function() if C_Timer and C_Timer.After then C_Timer.After(3, function() pcall(scanSkills) end) end end)

------------------------------------------------------------------------
-- Hearthstone
------------------------------------------------------------------------
WFD:On("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
    if unit ~= "player" or spellID ~= 8690 then return end
    if WFD.paused or not WFD.C then return end
    WFD.C.hearthCount = (WFD.C.hearthCount or 0) + 1
    WFD:Log("hearth", L["Used the hearthstone"])
end)
