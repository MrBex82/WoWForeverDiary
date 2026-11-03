-- The account's bestiary: every kind of creature any of your characters has slain, with where it was met.
-- A character's album shows the kinds its brothers and sisters know as covered cards - a hint where to look.
local ADDON, WFD = ...

local function entryFor(id)
    local S = WFD.S
    if not S then return end
    S.creatures = S.creatures or {}
    local e = S.creatures[id]
    if not e then
        e = {}
        S.creatures[id] = e
    end
    return e
end

-- called by the kill tracker for every kill
function WFD:NoteCreature(id, m)
    if self.paused or self.demo or type(id) ~= "number" then return end
    local e = entryFor(id)
    if not e then return end
    e.n = m.name or e.n
    e.z = m.zone or e.z
    e.lv = m.level or e.lv
    e.cls = m.cls or e.cls
    e.boss = m.boss or e.boss
    e.rare = m.rare or e.rare
    if m.map and not e.m then e.m, e.x, e.y = m.map, m.x, m.y end
    e.who = e.who or (self.C and self.C.name)
end

-- creatures this character slew before the account bestiary existed
WFD:OnInit(function()
    local C = WFD.C
    if not C or C.creaturesShared or WFD.demo then return end
    for id, m in pairs(C.mobs or {}) do WFD:NoteCreature(id, m) end
    C.creaturesShared = true
end)

-- a rough direction on the map: "north-east", "middle" ...
local DIRS = { "in the east", "in the south-east", "in the south", "in the south-west", "in the west",
    "in the north-west", "in the north", "in the north-east" }
function WFD:Direction(x, y)
    if not x or not y then return nil end
    local dx, dy = x - 0.5, y - 0.5
    if dx * dx + dy * dy < 0.12 * 0.12 then return "in the middle" end
    local a = math.atan2 and math.atan2(dy, dx) or math.atan(dy, dx)     -- y grows to the south
    local i = math.floor((a / (2 * math.pi)) * 8 + 0.5) % 8
    return DIRS[i + 1]
end

-- the kinds the other characters know and this one does not, grouped by area
function WFD:CreatureHints()
    local S, C = self.S, self.C
    local byZone, n, added = {}, 0, {}
    -- seen with your own eyes: the place you saw it is the best hint
    for id, s in pairs(C.sighted or {}) do
        if not C.mobs[id] then
            local zone = s.z or (s.m and self:MapName(s.m)) or "?"
            local h = { n = s.n, lv = s.lv, cls = s.cls, m = s.m, x = s.x, y = s.y,
                rare = (s.cls == "rare" or s.cls == "rareelite") or nil, boss = (s.cls == "worldboss" or s.lv == -1) or nil }
            byZone[zone] = byZone[zone] or {}
            table.insert(byZone[zone], { id = id, hint = true, sighted = true, h = h, zone = zone })
            added[id] = true
            n = n + 1
        end
    end
    for id, e in pairs((S and not self.demo) and S.creatures or {}) do
        if not C.mobs[id] and not added[id] and (e.who ~= C.name) then
            local zone = e.z or (e.m and self:MapName(e.m)) or "?"
            byZone[zone] = byZone[zone] or {}
            table.insert(byZone[zone], { id = id, hint = true, h = e, zone = zone })
            n = n + 1
        end
    end
    for _, list in pairs(byZone) do
        table.sort(list, function(a, b) return (a.h.lv or 0) < (b.h.lv or 0) end)
    end
    return byZone, n
end

------------------------------------------------------------------------
-- Kinds of creatures: the client names them in its own language, these are the names it uses
------------------------------------------------------------------------
local TYPE_KEYS = {}
for key, names in pairs({
    beast      = { "Beast", "Wildtier", "Bête", "Bestia", "Fera", "Животное", "야수", "野獸" },
    humanoid   = { "Humanoid", "Humanoider", "Humanoïde", "Humanoide", "Гуманоид", "인간형", "人型生物" },
    -- names as warcraft.wiki.gg (API UnitCreatureType) lists them per client language
    undead     = { "Undead", "Untoter", "Mort-vivant", "No-muerto", "Morto-vivo", "Renegado", "Нежить", "언데드", "不死族" },
    demon      = { "Demon", "Dämon", "Démon", "Demonio", "Demônio", "Демон", "악마", "惡魔" },
    elemental  = { "Elemental", "Elementar", "Élémentaire", "Элементаль", "정령", "元素生物" },
    dragonkin  = { "Dragonkin", "Drachkin", "Draconien", "Dragon", "Dragón", "Dracônico", "Дракон", "용족", "龍類" },
    giant      = { "Giant", "Riese", "Géant", "Gigante", "Великан", "거인", "巨人" },
    mechanical = { "Mechanical", "Mechanisch", "Mécanique", "Machine", "Mecánico", "Mecânico", "Механизм", "기계", "機械" },
    critter    = { "Critter", "Tier", "Kleintier", "Bestiole", "Alma", "Bicho", "Существо", "동물", "小動物" },
}) do
    for _, n in ipairs(names) do TYPE_KEYS[n] = key end
end
function WFD:CreatureTypeKey(ctype) return ctype and TYPE_KEYS[ctype] or "other" end

-- a line the character wrote beside the card: always the same one for the same creature
local NOTES = {
    beast      = { "Quick on its feet, but it never looks back.", "Its pelt would fetch a fair price in town." },
    humanoid   = { "Talks big, fights small.", "Carried more coins than sense." },
    undead     = { "Smells worse than it fights.", "Dead once already. Twice is a habit." },
    demon      = { "Burning eyes, burning temper.", "Whoever summoned this one owes me an apology." },
    elemental  = { "Not alive, not dead - simply angry.", "Left nothing behind but a puddle of fury." },
    dragonkin  = { "Scales like armour. Mind the tail.", "One day I will face its big brothers." },
    giant      = { "The ground shook long after it fell.", "Big enough to have its own weather." },
    mechanical = { "Gnomish work, no doubt. Loud and leaky.", "It sparked, it whirred, it stopped." },
    critter    = { "It never stood a chance.", "Small, harmless and now a footnote." },
    other      = { "A strange creature. I made a note, just in case.", "Worth remembering, or at least worth writing down." },
}
WFD.CREATURE_NOTES = NOTES
function WFD:MarginNote(id, m)
    local list = NOTES[self:CreatureTypeKey(m and m.ctype)] or NOTES.other
    local h = tonumber(id)
    if not h then
        h = 0
        for i = 1, #tostring(id) do h = h + tostring(id):byte(i) end
    end
    return self.L[list[h % #list + 1]]
end

-- collector stages of one kind: a sketch at first, in colour from 10 slain, a connoisseur's card from 50
WFD.STAGE_COLOUR, WFD.STAGE_MASTER = 10, 50
function WFD:MobStage(m)
    local k = m and m.kills or 0
    if k >= self.STAGE_MASTER then return 3 end
    -- rare creatures and bosses are never a sketch: they are in colour from the first sighting
    if k >= self.STAGE_COLOUR or (m and (m.boss or m.rare or m.cls == "rare" or m.cls == "rareelite")) then return 2 end
    return 1
end

-- what a kind of creature left behind: up to a dozen different things, and the best of them
function WFD:NoteMobLoot(mobId, itemId, link, q)
    local m = mobId and self.C and self.C.mobs[mobId]
    if not m or not itemId then return end
    m.drops = (m.drops or 0) + 1
    m.loot = m.loot or {}
    if not m.loot[itemId] then
        local n = 0
        for _ in pairs(m.loot) do n = n + 1 end
        if n < 12 then m.loot[itemId] = true end
    end
    if link and (not m.bestQ or (q or 0) > m.bestQ) then m.best, m.bestQ = link, q or 0 end
end

-- loot noted before the bestiary kept it: the diary days know whose it was
WFD:OnInit(function()
    local C = WFD.C
    if not C or C.lootLinked or WFD.demo then return end
    local byName = {}
    for id, m in pairs(C.mobs or {}) do if m.name then byName[m.name] = id end end
    for _, d in pairs(C.days or {}) do
        for itemId, e in pairs(d.loot or {}) do
            local id = e.src and byName[e.src]
            if id then
                WFD:NoteMobLoot(id, itemId, e.link, e.q)
            end
        end
    end
    C.lootLinked = true
end)
