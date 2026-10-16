-- Gathering: where herbs were picked, ore mined and hides skinned, and what came of it.
-- A finished gathering cast marks the spot; the loot that follows names the find.
local ADDON, WFD = ...
local floor = math.floor

-- spells by kind; every rank shares the name of the first, so names are compared
WFD.GATHER_KINDS = {
    { key = "herb", spell = 2366, label = "Herbalism", col = { 0.36, 0.72, 0.30, 1 }, icon = { "Trade_Herbalism", "INV_Misc_Flower_02" } },
    { key = "ore",  spell = 2575, label = "Mining",    col = { 0.72, 0.62, 0.50, 1 }, icon = { "Trade_Mining", "INV_Pick_02" } },
    { key = "skin", spell = 8613, label = "Skinning",  col = { 0.78, 0.46, 0.24, 1 }, icon = { "INV_Misc_Pelt_Wolf_01", "INV_Misc_LeatherScrap_03" } },
    { key = "fish", spell = 7620, label = "Fishing",   col = { 0.34, 0.58, 0.86, 1 }, icon = { "Trade_Fishing", "INV_Misc_Fish_02" } },
}
-- each map keeps its latest spots; the counts per kind are kept apart and never shrink
local MAX_PER_MAP = 500
-- a fish bites long after the line was cast, other finds come right away
local LOOT_WINDOW = { fish = 30 }

local byName
local function names()
    if byName then return byName end
    byName = {}
    for _, k in ipairs(WFD.GATHER_KINDS) do
        local n = WFD:SpellName(k.spell)
        if n then byName[n] = k.key end
    end
    return byName
end

-- map -> kind -> how often; built once from the spots for diaries written before it was kept
local function tallyOf(C)
    if C.gatherTally then return C.gatherTally end
    local tally = {}
    for map, list in pairs(C.gather or {}) do
        local t = {}
        for _, s in ipairs(list) do t[s.k] = (t[s.k] or 0) + 1 end
        tally[map] = t
    end
    C.gatherTally = tally
    return tally
end

local last          -- the spot just gathered, waiting for its loot

WFD:On("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
    if unit ~= "player" or WFD.paused or WFD.demo or not WFD.C or not spellID then return end
    local name = WFD:SpellName(spellID)
    local kind = name and names()[name]
    if not kind then return end
    local map, x, y = WFD:PlayerPos()
    if not map then return end
    local C = WFD.C
    local tally = tallyOf(C)
    C.gather = C.gather or {}
    local list = C.gather[map]
    if not list then
        list = {}
        C.gather[map] = list
    end
    C.gatherCount = (C.gatherCount or 0) + 1
    tally[map] = tally[map] or {}
    tally[map][kind] = (tally[map][kind] or 0) + 1
    last = { x = floor(x * 1000) / 1000, y = floor(y * 1000) / 1000, k = kind, t = time(), day = WFD:DayIndex() }
    list[#list + 1] = last
    while #list > MAX_PER_MAP do table.remove(list, 1) end
    WFD.dirty = true
end)

WFD:OnSignal("loot", function(link)
    if last and time() - last.t <= (LOOT_WINDOW[last.k] or 6) and not last.item then
        last.item = WFD:ItemName(link)
        if last.k == "fish" and WFD.C then WFD.C.fishCaught = (WFD.C.fishCaught or 0) + 1 end
    end
end)

-- totals per kind and the maps with gathering spots, most used first
function WFD:GatherSummary()
    local C = self.C
    local per, maps = {}, {}
    for map, kinds in pairs(tallyOf(C)) do
        local m = { id = map, n = 0, kinds = {} }
        for k, n in pairs(kinds) do
            per[k] = (per[k] or 0) + n
            m.kinds[k] = n
            m.n = m.n + n
        end
        if m.n > 0 and C.gather and C.gather[map] and #C.gather[map] > 0 then maps[#maps + 1] = m end
    end
    table.sort(maps, function(a, b) return a.n > b.n end)
    return per, maps
end
