-- Honours and landmarks: a collection that always has a next step.
-- Every honour climbs through up to five tiers (bronze to legend), some stay secret until earned,
-- and a list of famous places waits to be found. New tiers and places become milestones.
local ADDON, WFD = ...
local L = WFD.L
local floor, max, min, format = math.floor, math.max, math.min, string.format

------------------------------------------------------------------------
-- Tiers
------------------------------------------------------------------------
WFD.METALS = {
    { name = "Bronze",  col = { 0.72, 0.45, 0.22, 1 } },
    { name = "Silver",  col = { 0.72, 0.74, 0.78, 1 } },
    { name = "Gold",    col = { 0.93, 0.73, 0.22, 1 } },
    { name = "Mithril", col = { 0.42, 0.68, 0.86, 1 } },
    { name = "Legend",  col = { 0.66, 0.28, 0.78, 1 } },
}
local POINTS = { 10, 15, 25, 40, 60 }

-- honour points for tier i of an honour with n tiers
function WFD:TierPoints(i, n)
    if n == 1 then return 25 end
    return POINTS[min(5, i)]
end

-- the honour definition with this key
function WFD:HonourDef(key)
    for _, h in ipairs(self.HONOURS) do if h.key == key then return h end end
end

-- The title of a character: the name of an honour it has earned, chosen in the book of honour (a click on the
-- honour). Returns the name and the key, or nil if none is chosen or it is not (yet) earned.
function WFD:Title()
    local C = self.C
    local key = C and C.title
    local h = key and self:HonourDef(key)
    if not h then return nil end
    for _, e in ipairs(self:HonourState()) do
        if e.def.key == key then
            if e.tier > 0 then return L[h.name], key end
            return nil
        end
    end
end

local function refreshAll()
    local UI = WFD.UI
    WFD.dirty = true
    if UI then
        if UI.RefreshCover then UI:RefreshCover() end
        if UI.bookFrame and UI.bookFrame:IsShown() and UI.spread then UI:ShowSpread(UI.spread) end
    end
    if WFD.UpdateFamily then WFD.UpdateFamily() end
end

function WFD:ToggleTitle(key)
    local C = self.C
    if not C then return end
    C.title = (C.title ~= key) and key or nil
    refreshAll()
end

-- up to three honours on show: the showcase of the goals page
WFD.SHOWCASE_MAX = 3
function WFD:ToggleShowcase(key)
    local C = self.C
    if not C then return end
    C.showcase = C.showcase or {}
    for i, k in ipairs(C.showcase) do
        if k == key then table.remove(C.showcase, i) refreshAll() return true end
    end
    if #C.showcase >= self.SHOWCASE_MAX then table.remove(C.showcase, 1) end
    C.showcase[#C.showcase + 1] = key
    refreshAll()
    return true
end

function WFD:InShowcase(key)
    for _, k in ipairs(self.C and self.C.showcase or {}) do if k == key then return true end end
    return false
end

-- metal of tier i of an honour with n tiers (a single-tier honour is gold)
function WFD:MetalOf(i, n)
    if n == 1 then return self.METALS[3] end
    return self.METALS[min(5, i)]
end

------------------------------------------------------------------------
-- Landmarks: area IDs, so the names come from the game in every language
------------------------------------------------------------------------
WFD.LANDMARKS = {
    { key = "capitals", label = "Capitals", icon = "Spell_Arcane_TeleportStormWind", list = {
        { 1519, "Spell_Arcane_TeleportStormWind" }, { 1537, "Spell_Arcane_TeleportIronForge" },
        { 1657, "Spell_Arcane_TeleportDarnassus" }, { 1637, "Spell_Arcane_TeleportOrgrimmar" },
        { 1638, "Spell_Arcane_TeleportThunderBluff" }, { 1497, "Spell_Arcane_TeleportUnderCity" },
    } },
    { key = "ek", label = "Towns of the Eastern Kingdoms", icon = "INV_Misc_Rune_01", cont = 1415, list = {
        { 9 }, { 87 }, { 132 }, { 131 }, { 154 }, { 159 }, { 228 }, { 108 }, { 20 }, { 69 }, { 42 }, { 144 },
        { 150 }, { 271 }, { 272 }, { 320 }, { 321 }, { 75 }, { 117 }, { 35 }, { 1446 }, { 2268 },
    } },
    { key = "kalimdor", label = "Towns of Kalimdor", icon = "INV_Misc_Rune_01", cont = 1414, list = {
        { 188 }, { 186 }, { 702 }, { 442 }, { 415 }, { 363 }, { 362 }, { 367 }, { 220 }, { 222 }, { 380 },
        { 392 }, { 378 }, { 431 }, { 460 }, { 467 }, { 484 }, { 513 }, { 496 }, { 608 }, { 2408 }, { 1116 },
        { 1099 }, { 976 }, { 493 }, { 2255 }, { 3425 },
    } },
    { key = "dungeons", label = "Dungeons", icon = "INV_Misc_Key_03", list = {
        { 2437 }, { 1581 }, { 718 }, { 209 }, { 717 }, { 719 }, { 721 }, { 491 }, { 796 }, { 722 }, { 1337 },
        { 1176 }, { 2100 }, { 1477 }, { 1584 }, { 1583 }, { 2557 }, { 2057 }, { 2017 },
    } },
    { key = "raids", label = "Raids", icon = "INV_Misc_Head_Dragon_01", list = {
        { 2717 }, { 2159 }, { 1977 }, { 2677 }, { 3429 }, { 3428 }, { 3456 },
    } },
}

local nameToId, idName
local function areaName(id)
    local fn = C_Map and C_Map.GetAreaInfo
    if not fn then return nil end
    local ok, name = pcall(fn, id)
    if ok and type(name) == "string" and name ~= "" then return name end
end

local function buildNames()
    if nameToId then return end
    nameToId, idName = {}, {}
    for _, g in ipairs(WFD.LANDMARKS) do
        for _, e in ipairs(g.list) do
            local n = areaName(e[1])
            if n then
                idName[e[1]] = n
                nameToId[n] = nameToId[n] or e[1]
            end
        end
    end
end

-- When (if ever) a place name shows up in the character's travels.
local function seenAt(C, name)
    local z = C.zones and C.zones[name]
    if z then return z.first end
    for _, zz in pairs(C.zones or {}) do
        local t = zz.sub and zz.sub[name]
        if t then return t end
    end
    local inst = C.instances and C.instances[name]
    if inst then return inst end
end

-- groups = { { def, found, total, items = { { id, name, icon, found, t, day } } } }, found, total
function WFD:LandmarkState()
    buildNames()
    local C = self.C
    local groups, found, total = {}, 0, 0
    for _, g in ipairs(self.LANDMARKS) do
        local grp = { def = g, found = 0, total = 0, items = {} }
        for _, e in ipairs(g.list) do
            local name = idName[e[1]]
            if name then
                local t = (C.landmarks and C.landmarks[e[1]]) or seenAt(C, name)
                local it = { id = e[1], name = name, icon = e[2] or g.icon, found = t ~= nil, t = t,
                    day = t and self:DayIndex(t) or nil }
                grp.items[#grp.items + 1] = it
                grp.total = grp.total + 1
                if it.found then grp.found = grp.found + 1 end
            end
        end
        if grp.total > 0 then
            groups[#groups + 1] = grp
            found, total = found + grp.found, total + grp.total
        end
    end
    return groups, found, total
end

------------------------------------------------------------------------
-- Atlas: every region of both continents, explored or not
------------------------------------------------------------------------
WFD.CONTINENTS = { 1415, 1414 }     -- Eastern Kingdoms, Kalimdor

-- { { id, name, visited, total, secs, zones = { { id, name, visited, day, secs } } } }, visited, total
function WFD:AtlasState()
    local C = self.C
    local out, visited, total = {}, 0, 0
    local get = C_Map and C_Map.GetMapChildrenInfo
    if not get then return out, 0, 0 end
    local zoneType = (Enum and Enum.UIMapType and Enum.UIMapType.Zone) or 3
    local secs = {}
    for _, d in pairs(C.days) do
        for z, t in pairs(d.zones or {}) do secs[z] = (secs[z] or 0) + t end
    end
    -- lands on record by their map: a land counts as seen even when its stored name differs from the map's
    local byMap = {}
    for name, id in pairs(C.zoneMaps or {}) do
        if C.zones[name] and type(id) == "number" then byMap[id] = byMap[id] or name end
    end
    for _, cont in ipairs(self.CONTINENTS) do
        local ok, kids = pcall(get, cont, zoneType, false)
        if ok and type(kids) == "table" and #kids > 0 then
            local e = { id = cont, name = self:MapName(cont), zones = {}, visited = 0, secs = 0 }
            local seen = {}
            for _, k in ipairs(kids) do
                local name = k.name and self:MapName(k.mapID)
                if name and not seen[name] then
                    seen[name] = true
                    local stored = C.zones[name] and name or byMap[k.mapID]
                    local z = stored and C.zones[stored]
                    local it = { id = k.mapID, name = name, visited = z ~= nil, day = z and z.day, secs = secs[stored or name] or 0 }
                    e.zones[#e.zones + 1] = it
                    if it.visited then e.visited = e.visited + 1 end
                    e.secs = e.secs + it.secs
                end
            end
            table.sort(e.zones, function(a, b)
                if a.visited ~= b.visited then return a.visited end
                if a.visited and (a.day or 0) ~= (b.day or 0) then return (a.day or 0) < (b.day or 0) end
                return a.name < b.name
            end)
            e.total = #e.zones
            visited, total = visited + e.visited, total + e.total
            out[#out + 1] = e
        end
    end
    return out, visited, total
end

------------------------------------------------------------------------
-- Honours: { key, category, name, description (%d = goal), metric, tiers, icons, secret hint }
------------------------------------------------------------------------
WFD.HONOUR_CATS = {
    { key = "combat", label = "Combat" },
    { key = "explore", label = "Exploration" },
    { key = "people", label = "Encounters" },
    { key = "adventure", label = "Adventure" },
    { key = "fortune", label = "Fortune and craft" },
    { key = "secret", label = "Curiosities" },
}

WFD.HONOURS = {
    -- combat
    { key = "slayer", cat = "combat", name = "Slayer", desc = "Slay %d creatures.", m = "kills",
      tiers = { 100, 500, 2000, 5000, 15000 }, icon = { "INV_Sword_04" } },
    { key = "specialist", cat = "combat", name = "Specialist", desc = "Slay %d of a single kind.", m = "maxKind",
      tiers = { 50, 150, 400, 1000 }, icon = { "INV_Misc_MonsterClaw_04", "Ability_Hunter_MarkedForDeath" } },
    { key = "naturalist", cat = "combat", name = "Naturalist", desc = "Collect %d kinds of creatures.", m = "kinds",
      tiers = { 25, 75, 150, 300, 500 }, icon = { "Ability_Hunter_BeastTaming" } },
    { key = "versatile", cat = "combat", name = "Versatile Hunter", desc = "Slay creatures of %d different types.", m = "ctypes",
      tiers = { 4, 6, 8 }, icon = { "Ability_Hunter_Pet_Wolf", "Ability_Hunter_BeastTaming" } },
    { key = "connoisseur", cat = "combat", name = "Connoisseur", desc = "Slay 50 of each of %d kinds.", m = "connoisseur",
      tiers = { 1, 5, 15, 30 }, icon = { "INV_Misc_Book_11", "INV_Misc_Book_09" } },
    { key = "giants", cat = "combat", name = "Giant Slayer", desc = "Defeat %d bosses.", m = "bosses",
      tiers = { 3, 15, 40, 80 }, icon = { "INV_Misc_Head_Dragon_01" } },
    { key = "rarehunter", cat = "combat", name = "Rare Hunter", desc = "Slay %d rare creatures.", m = "rares",
      tiers = { 2, 8, 20, 40 }, icon = { "Ability_Hunter_SniperShot" } },
    { key = "elites", cat = "combat", name = "Elite Slayer", desc = "Slay %d elite creatures.", m = "elites",
      tiers = { 10, 50, 200, 500 }, icon = { "INV_Misc_Bone_ElfSkull_01", "INV_Misc_Bone_HumanSkull_01" } },
    { key = "bloodbath", cat = "combat", name = "Bloodbath", desc = "Slay %d creatures in a single day.", m = "dayKills",
      tiers = { 100, 250, 500 }, icon = { "Ability_Warrior_Charge" } },
    { key = "untouchable", cat = "combat", name = "Untouchable", desc = "Play %d days in a row without dying.", m = "streak",
      tiers = { 5, 14, 30, 60 }, icon = { "Spell_Holy_DivineIntervention", "Spell_Holy_SurgeOfLight" } },
    -- exploration
    { key = "wanderer", cat = "explore", name = "Wanderer", desc = "Visit %d regions.", m = "zones",
      tiers = { 5, 10, 20, 30, 40 }, icon = { "INV_Misc_Map_01" } },
    { key = "explorer", cat = "explore", name = "Explorer", desc = "Discover %d places.", m = "subzones",
      tiers = { 25, 75, 200, 400, 700 }, icon = { "INV_Misc_Spyglass_02", "INV_Misc_Map02" } },
    { key = "sightseer", cat = "explore", name = "Sightseer", desc = "Find %d landmarks.", m = "landmarks",
      tiers = { 10, 25, 45, 65, 81 }, icon = { "INV_Misc_Spyglass_03", "INV_Misc_Spyglass_02", "INV_Misc_Map_01" } },
    { key = "capitals", cat = "explore", name = "Capital Tourist", desc = "Visit %d capital cities.", m = "capitals",
      tiers = { 1, 3, 6 }, icon = { "Spell_Arcane_TeleportStormWind", "Spell_Arcane_TeleportOrgrimmar" } },
    { key = "depths", cat = "explore", name = "Into the Depths", desc = "Enter %d dungeons.", m = "dungeons",
      tiers = { 3, 8, 15, 25 }, icon = { "INV_Misc_Key_03" } },
    { key = "pathfinder", cat = "explore", name = "Pathfinder", desc = "Walk %d kilometres.", m = "km",
      tiers = { 25, 100, 300, 750, 1500 }, icon = { "Ability_Tracking" } },
    { key = "flyer", cat = "explore", name = "Frequent Flyer", desc = "Take %d flights.", m = "flights",
      tiers = { 5, 25, 75, 150 }, icon = { "Ability_Mount_Wyvern_01", "Ability_Mount_Gryphon_01", "Spell_Nature_Swiftness" } },
    { key = "wings", cat = "explore", name = "Wings of the World", desc = "Discover %d flight paths.", m = "flightPaths",
      tiers = { 5, 12, 20, 30 }, icon = { "Ability_Mount_Gryphon_01", "Ability_Mount_Wyvern_01", "INV_Misc_Map_01" } },
    -- encounters
    { key = "sociable", cat = "people", name = "Sociable", desc = "Meet %d people.", m = "people",
      tiers = { 50, 150, 400, 800 }, icon = { "Ability_Warrior_RallyingCry" } },
    { key = "fellowship", cat = "people", name = "Fellowship", desc = "Group with %d other adventurers.", m = "companions",
      tiers = { 5, 25, 75, 150 }, icon = { "Spell_Holy_PrayerOfFortitude" } },
    { key = "haggler", cat = "people", name = "Haggler", desc = "Do business with %d merchants.", m = "merchants",
      tiers = { 15, 50, 120 }, icon = { "INV_Misc_Bag_10", "INV_Misc_Coin_02" } },
    { key = "student", cat = "people", name = "Eager Student", desc = "Visit %d trainers.", m = "trainers",
      tiers = { 5, 15, 30 }, icon = { "INV_Misc_Book_11", "INV_Misc_Book_09" } },
    { key = "barterer", cat = "people", name = "Barterer", desc = "Trade with %d players.", m = "traders",
      tiers = { 3, 10, 30 }, icon = { "INV_Letter_15" } },
    -- adventure
    { key = "helping", cat = "adventure", name = "Helping Hand", desc = "Complete %d quests.", m = "quests",
      tiers = { 25, 100, 300, 600, 1000 }, icon = { "INV_Scroll_03" } },
    { key = "busybee", cat = "adventure", name = "Busy Bee", desc = "Complete %d quests in a single day.", m = "dayQuests",
      tiers = { 10, 20, 35 }, icon = { "INV_Misc_Note_01" } },
    { key = "seasoned", cat = "adventure", name = "Seasoned", desc = "Reach level %d.", m = "level",
      tiers = { 20, 30, 40, 50, 60 }, icon = { "Spell_Holy_SurgeOfLight" } },
    { key = "chronicler", cat = "adventure", name = "Faithful Chronicler", desc = "Keep this diary for %d days.", m = "days",
      tiers = { 7, 30, 100, 365 }, icon = { "INV_Misc_Book_09" } },
    { key = "bookworm", cat = "adventure", name = "Bookworm", desc = "Read %d books, notes and plaques.", m = "books",
      tiers = { 1, 5, 15, 40, 100 }, icon = { "INV_Misc_Book_09", "INV_Misc_Book_11" } },
    { key = "scholar", cat = "adventure", name = "Scholar", desc = "Read %d books to the last page.", m = "booksComplete",
      tiers = { 1, 5, 15, 40 }, icon = { "INV_Misc_Book_11", "INV_Misc_Book_09" } },
    { key = "devoted", cat = "adventure", name = "Devoted", desc = "Spend %d hours in the world.", m = "hours",
      tiers = { 24, 100, 250, 500 }, icon = { "INV_Misc_PocketWatch_01" } },
    { key = "phoenix", cat = "adventure", name = "Phoenix", desc = "Die %d times and rise again.", m = "deaths",
      tiers = { 10, 50, 150 }, icon = { "Spell_Holy_Resurrection" } },
    { key = "stubborn", cat = "adventure", name = "Stubborn", desc = "Defeat a foe that has defeated you three times.",
      m = "revenge", tiers = { 1 }, icon = { "Ability_Warrior_Revenge", "INV_Misc_Bone_HumanSkull_01" } },
    { key = "crawler", cat = "adventure", name = "Dungeon Crawler", desc = "Finish %d dungeon runs.", m = "runs",
      tiers = { 3, 15, 40, 80 }, icon = { "INV_Misc_Key_04", "INV_Misc_Key_03" } },
    { key = "diligent", cat = "adventure", name = "Diligent", desc = "Do all tasks of the day on %d days.", m = "challengeDays",
      tiers = { 7, 30, 100, 250 }, icon = { "INV_Misc_Note_02", "INV_Misc_Note_01" } },
    { key = "dutiful", cat = "adventure", name = "Dutiful", desc = "Do all tasks of the day %d days in a row.", m = "challengeRun",
      tiers = { 5, 14, 30 }, icon = { "INV_Misc_PocketWatch_02", "INV_Misc_PocketWatch_01" } },
    { key = "weekly", cat = "adventure", name = "Week by Week", desc = "Complete %d tasks of the week.", m = "weeks",
      tiers = { 2, 8, 20, 52 }, icon = { "INV_Misc_Note_06", "INV_Misc_Note_02" } },
    -- fortune and craft
    { key = "thrifty", cat = "fortune", name = "Thrifty", desc = "Own %d gold.", m = "gold",
      tiers = { 10, 100, 500, 1000 }, icon = { "INV_Misc_Coin_01" } },
    { key = "treasure", cat = "fortune", name = "Treasure Hunter", desc = "Find %d rare items.", m = "rareItems",
      tiers = { 5, 20, 60, 120 }, icon = { "INV_Misc_Gem_Variety_01" } },
    { key = "epic", cat = "fortune", name = "Epic Fortune", desc = "Find %d epic items.", m = "epics",
      tiers = { 1, 5, 15 }, icon = { "INV_Misc_Gem_Pearl_05" } },
    { key = "hoarder", cat = "fortune", name = "Hoarder", desc = "Loot %d items.", m = "items",
      tiers = { 500, 2000, 6000, 15000 }, icon = { "INV_Misc_Bag_08" } },
    { key = "craft", cat = "fortune", name = "Master of a Craft", desc = "Raise a skill to %d.", m = "skillMax",
      tiers = { 75, 150, 225, 300 }, icon = { "Trade_Mining", "INV_Pick_02" } },
    { key = "angler", cat = "fortune", name = "Angler", desc = "Raise Fishing to %d.", m = "fishing",
      tiers = { 75, 150, 225, 300 }, icon = { "Trade_Fishing", "INV_Fishingpole_02" } },
    { key = "catch", cat = "fortune", name = "Big Catch", desc = "Catch %d fish.", m = "fish",
      tiers = { 25, 100, 400, 1000 }, icon = { "INV_Misc_Fish_02", "INV_Misc_Fish_03" } },
    { key = "fishlore", cat = "fortune", name = "Fish Lore", desc = "Land %d different catches.", m = "catchKinds",
      tiers = { 5, 15, 30, 60 }, icon = { "INV_Misc_Fish_03", "INV_Misc_Fish_02" } },
    { key = "medic", cat = "fortune", name = "Field Medic", desc = "Raise First Aid to %d.", m = "firstAid",
      tiers = { 75, 150, 225, 300 }, icon = { "Spell_Holy_SealOfSacrifice", "INV_Misc_Bandage_15" } },
    { key = "cook", cat = "fortune", name = "Camp Cook", desc = "Raise Cooking to %d.", m = "cooking",
      tiers = { 75, 150, 225, 300 }, icon = { "INV_Misc_Food_15", "INV_Misc_Food_14" } },
    -- curiosities: secret until earned
    { key = "bouncy", cat = "secret", name = "Bouncy", desc = "Jump %d times.", m = "jumps",
      tiers = { 1000, 10000, 50000 }, icon = { "Ability_Rogue_Sprint" }, secret = "Up, up and away ..." },
    { key = "nightowl", cat = "secret", name = "Night Owl", desc = "Be on the road between midnight and four o'clock.",
      m = "nightOwl", tiers = { 1 }, icon = { "Spell_Nature_Starfall", "Spell_Nature_Sleep" },
      secret = "When the moon stands highest ..." },
    { key = "earlybird", cat = "secret", name = "Early Bird", desc = "Be on the road before seven in the morning.",
      m = "earlyBird", tiers = { 1 }, icon = { "Spell_Holy_HolyBolt" }, secret = "The early bird catches the worm ..." },
    { key = "regular", cat = "secret", name = "Regular", desc = "Talk to the same person %d times.", m = "maxTalks",
      tiers = { 25, 60 }, icon = { "INV_Drink_05", "INV_Misc_Note_01" }, secret = "A familiar face ..." },
    { key = "homesick", cat = "secret", name = "Homesick", desc = "Use your hearthstone %d times.", m = "hearth",
      tiers = { 25, 100, 250 }, icon = { "INV_Misc_Rune_01" }, secret = "There is no place like home ..." },
    { key = "badday", cat = "secret", name = "Bad Day", desc = "Die %d times in a single day.", m = "dayDeaths",
      tiers = { 5 }, icon = { "Ability_Rogue_FeignDeath", "INV_Misc_Bone_HumanSkull_01" },
      secret = "Not every day is a good day ..." },
    { key = "marathon", cat = "secret", name = "Marathon", desc = "Spend %d hours in the world on a single day.",
      m = "dayHours", tiers = { 6, 10 }, icon = { "Spell_Nature_Swiftness", "Ability_Rogue_Sprint" },
      secret = "Just one more quest ..." },
    { key = "rested", cat = "secret", name = "Well Rested", desc = "Rest at %d places.", m = "rests",
      tiers = { 15, 60 }, icon = { "Spell_Nature_Sleep" }, secret = "Every journey needs a pause ..." },
    { key = "globetrot", cat = "secret", name = "Globetrotter's Day", desc = "Visit %d regions in a single day.",
      m = "dayZones", tiers = { 5, 8 }, icon = { "INV_Misc_Map02", "INV_Misc_Map_01" },
      secret = "So many roads, so little time ..." },
}

------------------------------------------------------------------------
-- Measuring a life
------------------------------------------------------------------------
local function count(t) local n = 0 for _ in pairs(t or {}) do n = n + 1 end return n end

function WFD:HonourMetrics()
    local C = self.C
    local m = {
        kills = 0, quests = 0, km = 0, jumps = 0, days = 0, hours = 0, flights = 0, deaths = 0,
        kinds = 0, bosses = 0, rares = 0, elites = 0, maxKind = 0,
        zones = count(C.zones), subzones = 0, dungeons = count(C.instances), rareItems = count(C.rares),
        people = 0, flightmasters = 0, merchants = 0, trainers = 0, maxTalks = 0,
        companions = count(C.companions), traders = count(C.traders), rests = #(C.rests or {}),
        hearth = C.hearthCount or 0, items = C.itemTotal or 0, gold = floor((C.wealth or 0) / 10000),
        level = UnitLevel and UnitLevel("player") or 1, skillMax = 0, epics = 0,
        dayKills = 0, dayQuests = 0, dayDeaths = 0, dayHours = 0, dayZones = 0,
        nightOwl = 0, earlyBird = 0, streak = 0,
    }
    for lvl in pairs(C.levelTimes or {}) do if lvl > m.level then m.level = lvl end end
    local types = {}
    m.ctypes, m.connoisseur = 0, 0
    for _, mob in pairs(C.mobs or {}) do
        m.kinds = m.kinds + 1
        if mob.boss then m.bosses = m.bosses + 1 end
        if mob.rare or mob.cls == "rare" or mob.cls == "rareelite" then m.rares = m.rares + 1 end
        if mob.cls == "elite" or mob.cls == "rareelite" or mob.cls == "worldboss" then m.elites = m.elites + (mob.kills or 0) end
        if (mob.kills or 0) > m.maxKind then m.maxKind = mob.kills end
        if mob.ctype and not types[mob.ctype] then types[mob.ctype] = true; m.ctypes = m.ctypes + 1 end
        if (mob.kills or 0) >= WFD.STAGE_MASTER then m.connoisseur = m.connoisseur + 1 end
    end
    for _, z in pairs(C.zones or {}) do m.subzones = m.subzones + count(z.sub) end
    -- foes that defeated you three times or more and fell to you after that
    local slainLast = {}
    for _, mob in pairs(C.mobs or {}) do
        if mob.name and (mob.kills or 0) > 0 and mob.last then slainLast[mob.name] = max(slainLast[mob.name] or 0, mob.last) end
    end
    m.revenge = 0
    for name, n in pairs(C.nemesis or {}) do
        if (n.n or 0) >= 3 and n.last and slainLast[name] and slainLast[name] > n.last then m.revenge = m.revenge + 1 end
    end
    for _, n in pairs(C.npcs or {}) do
        m.people = m.people + 1
        local r = n.roles or {}
        if r.flight then m.flightmasters = m.flightmasters + 1 end
        if r.merchant then m.merchants = m.merchants + 1 end
        if r.trainer then m.trainers = m.trainers + 1 end
        if (n.talks or 0) > m.maxTalks then m.maxTalks = n.talks end
    end
    -- once the skill list was read, only professions count as a craft (not swords or languages)
    local crafts = C.crafts and next(C.crafts) and C.crafts
    for name, rank in pairs(C.skills or {}) do
        if type(rank) == "number" and rank > m.skillMax and (not crafts or crafts[name]) then m.skillMax = rank end
    end
    local function skillOf(spell)
        local n = WFD:SpellName(spell)
        return n and tonumber(C.skills and C.skills[n]) or 0
    end
    m.fishing, m.firstAid, m.cooking = skillOf(7620), skillOf(3273), skillOf(2550)
    m.fish = C.fishCaught or 0
    -- the texts of the library this character has read, and how many of them to the last page
    m.books, m.booksComplete = 0, 0
    for id in pairs(C.booksRead or {}) do
        local b = self.Book and self:Book(id)
        if b then
            m.books = m.books + 1
            if self:BookComplete(b) then m.booksComplete = m.booksComplete + 1 end
        end
    end
    m.catchKinds = 0
    for _ in pairs(C.catch or {}) do m.catchKinds = m.catchKinds + 1 end
    local epicIds, run, steps = {}, 0, 0
    for d = 1, self:NumDays() do
        local day = C.days[d]
        if day then
            m.days = m.days + 1
            m.kills = m.kills + day.killTotal
            m.quests = m.quests + #day.qd
            m.deaths = m.deaths + day.deaths
            m.flights = m.flights + (day.flights or 0)
            m.jumps = m.jumps + (day.jumps or 0)
            steps = steps + (day.steps or 0)
            m.hours = m.hours + (day.online or 0) / 3600
            m.dayKills = max(m.dayKills, day.killTotal)
            m.dayQuests = max(m.dayQuests, #day.qd)
            m.dayDeaths = max(m.dayDeaths, day.deaths)
            m.dayHours = max(m.dayHours, (day.online or 0) / 3600)
            m.dayZones = max(m.dayZones, count(day.zones))
            for h, v in pairs(day.hours or {}) do
                if v > 60 then
                    if h < 4 then m.nightOwl = 1 elseif h >= 4 and h < 7 then m.earlyBird = 1 end
                end
            end
            for id, e in pairs(day.loot or {}) do if (e.q or 0) >= 4 then epicIds[id] = true end end
            if day.deaths == 0 and day.killTotal > 0 then
                run = run + 1
                if run > m.streak then m.streak = run end
            elseif day.deaths > 0 then
                run = 0
            end
        end
    end
    m.km = steps * 0.9144 / 1000
    m.hours = floor(m.hours)
    m.dayHours = floor(m.dayHours)
    m.epics = count(epicIds)
    local groups, found = self:LandmarkState()
    m.landmarks = found
    for _, g in ipairs(groups) do
        if g.def.key == "capitals" then m.capitals = g.found end
    end
    m.capitals = m.capitals or 0
    -- dungeon bosses come from encounters, outdoor bosses from the kill list: count each name once
    local bossNames = {}
    for _, mob in pairs(C.mobs or {}) do if mob.boss and mob.name then bossNames[mob.name] = true end end
    for name in pairs(C.encounters or {}) do bossNames[name] = true end
    m.bosses = max(m.bosses, count(bossNames))
    m.runs = #(C.runs or {})
    m.flightPaths = count(C.taxiNodes)
    m.weeks = self.WeeksDone and self:WeeksDone() or 0
    if self.ChallengeStats then
        local full, _, best = self:ChallengeStats()
        m.challengeDays, m.challengeRun = full, best
    else
        m.challengeDays, m.challengeRun = 0, 0
    end
    return m
end

-- One entry per honour: { def, value, tier (tiers reached), next (goal or nil), points, hidden }
function WFD:HonourState()
    local m = self:HonourMetrics()
    local list = {}
    local sum = { points = 0, maxPoints = 0, tiers = 0, totalTiers = 0, metals = { 0, 0, 0, 0, 0 } }
    for _, h in ipairs(self.HONOURS) do
        local v = m[h.m] or 0
        local n = #h.tiers
        local tier = 0
        for i, g in ipairs(h.tiers) do if v >= g then tier = i end end
        local pts = 0
        for i = 1, n do
            local p = (n == 1) and 25 or POINTS[min(5, i)]
            sum.maxPoints = sum.maxPoints + p
            if i <= tier then
                pts = pts + p
                local metal = (n == 1) and 3 or min(5, i)
                sum.metals[metal] = sum.metals[metal] + 1
            end
        end
        sum.points = sum.points + pts
        sum.tiers = sum.tiers + tier
        sum.totalTiers = sum.totalTiers + n
        list[#list + 1] = {
            def = h, value = v, tier = tier, n = n, next = h.tiers[tier + 1], prev = h.tiers[tier] or 0,
            points = pts, hidden = h.secret and tier == 0,
        }
    end
    return list, sum, m
end

-- for a goal of one the sentence has its own words (no "1 rare items")
local ONE = {
    giants = "Defeat a boss.", rarehunter = "Slay a rare creature.", elites = "Slay an elite creature.",
    capitals = "Visit a capital city.", depths = "Enter a dungeon.", flyer = "Take a flight.",
    fellowship = "Group with another adventurer.", student = "Visit a trainer.", barterer = "Trade with another player.",
    helping = "Complete a quest.", phoenix = "Die once and rise again.", crawler = "Finish a dungeon run.",
    diligent = "Do all tasks of the day on one day.", weekly = "Complete a task of the week.",
    treasure = "Find a rare item.", epic = "Find an epic item.", connoisseur = "Slay 50 of one kind.",
    bookworm = "Read a book, a note or a plaque.", scholar = "Read a book to the last page.",
}

function WFD:HonourText(h, goal)
    goal = goal or h.tiers[1]
    if goal == 1 and ONE[h.key] then return L[ONE[h.key]] end
    local d = L[h.desc]
    if d:find("%%d") then return format(d, goal or h.tiers[1]) end
    return d
end

------------------------------------------------------------------------
-- Watching for new tiers and new landmarks
------------------------------------------------------------------------
local function checkHonours(silent)
    local C = WFD.C
    if not C or WFD.paused or WFD.demo then return end
    local first = C.honourTiers == nil
    C.honourTiers = C.honourTiers or {}
    local list = WFD:HonourState()
    for _, e in ipairs(list) do
        local had = C.honourTiers[e.def.key] or 0
        if e.tier > had then
            C.honourTiers[e.def.key] = e.tier
            if not first and not silent then
                local name = L[e.def.name]
                local text
                if e.n == 1 then
                    text = format(L["Honour earned: %s"], name)
                else
                    text = format(L["Honour earned: %s (%s)"], name, L[WFD:MetalOf(e.tier, e.n).name])
                end
                WFD:Milestone("honour", text, e.tier >= 3 or e.n == 1, { honour = e.def.key, tier = e.tier })
            end
        end
    end
end

local function checkLandmark()
    local C = WFD.C
    if not C or WFD.paused or WFD.demo then return end
    -- a landmark seen from a flight path is not visited; the place you land at is checked when the flight ends
    if UnitOnTaxi and UnitOnTaxi("player") then return end
    buildNames()
    if not C.landmarks then return end   -- filled once at login, see below
    for _, name in ipairs({ GetRealZoneText and GetRealZoneText() or "", GetSubZoneText and GetSubZoneText() or "" }) do
        local id = name ~= "" and nameToId[name]
        if id and not C.landmarks[id] then
            C.landmarks[id] = time()
            WFD:Milestone("landmark", format(L["Landmark discovered: %s"], name), true, { landmark = id })
        end
    end
end

WFD:OnInit(function()
    local C = WFD.C
    -- places found before the diary knew about landmarks count, but quietly
    if not C.landmarks then
        C.landmarks = {}
        buildNames()
        for id, name in pairs(idName) do
            local t = seenAt(C, name)
            if t then C.landmarks[id] = t end
        end
    end
    -- the tiers were raised (version 2): the tiers reached so far are taken over quietly, without a toast for each
    if C.honourScheme ~= 2 then
        C.honourTiers = nil
        C.honourScheme = 2
    end
    checkHonours(C.honourTiers == nil or WFD.quietHonours)
    if C_Timer and C_Timer.NewTicker then
        C_Timer.NewTicker(12, function()
            local ok, err = pcall(checkHonours)
            if not ok then WFD:Error("honours", err) end
        end)
    end
end)

for _, ev in ipairs({ "ZONE_CHANGED", "ZONE_CHANGED_INDOORS", "ZONE_CHANGED_NEW_AREA", "PLAYER_ENTERING_WORLD" }) do
    WFD:On(ev, function() checkLandmark() end)
end
WFD:OnSignal("landed", function() checkLandmark() end)
