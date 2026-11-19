-- The two albums on the travel desk: the bestiary and the angler's log. The trading cards are the ones of the book
-- (PagesAppendix.lua, PagesFishing.lua); what is new is how they are found: one scrolling collection in groups,
-- chips to narrow it down, a field for a name, an order, and the card of a creature or a catch beside the list.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local R = UI.Router
local format = string.format

-- (the labels of chips, orders and buttons are keys, translated when the view is built:
-- L["Rare and bosses"] L["Connoisseurs"] L["Sketches"] L["Nemeses"] L["Still to find"] L["By area"] L["By kind"]
-- L["Most slain"] L["Closest to the next card"] L["Last slain"] L["Hunting grounds"] L["Fish"] L["Treasure"] L["Junk"]
-- L["Odds and ends"] L["By water"] L["Most caught"] L["Newest first"] L["Waters and tackle"] L["All"])

local function matches(q, ...)
    if not q or q == "" then return true end
    for i = 1, select("#", ...) do
        local s = select(i, ...)
        if s and tostring(s):lower():find(q, 1, true) then return true end
    end
    return false
end

-- entries grouped by a key, the groups in the order their first entry came
local function groupBy(list, keyFn)
    local out, by = {}, {}
    for _, e in ipairs(list) do
        local k = keyFn(e) or "?"
        local g = by[k]
        if not g then
            g = { title = k, items = {} }
            by[k] = g
            out[#out + 1] = g
        end
        g.items[#g.items + 1] = e
    end
    return out, by
end

local function sortedSection(title, list, cmp)
    table.sort(list, cmp)
    return { { title = title, items = list } }
end

------------------------------------------------------------------------
-- The bestiary
------------------------------------------------------------------------
UI.PART_VIEW.bestiary = "bestiary"

local function nemesisOf(m)
    local n = WFD.C.nemesis and WFD.C.nemesis[m.name or ""]
    return n and (n.n or 0) > 0
end

local function bestiaryData(state)
    local arr = UI.BestiaryCollection()
    local hintsByZone = WFD.CreatureHints and WFD:CreatureHints() or {}
    local chip, q = state.chip, state.q
    local own = {}
    if chip ~= "find" then
        for _, e in ipairs(arr) do
            local m = e.m
            local rk, st = UI.RarityOf(m), WFD:MobStage(m)
            local ok = chip == "all" or (chip == "rare" and (rk == "rare" or rk == "boss"))
                or (chip == "master" and st == 3) or (chip == "sketch" and st == 1) or (chip == "nemesis" and nemesisOf(m))
            if ok and matches(q, m.name, m.zone, m.ctype) then
                e.zone = m.zone or "?"
                own[#own + 1] = e
            end
        end
    end
    -- covered cards: what you saw yourself under "all", every hint (other characters too) under "still to find"
    local hints, hiddenIn = {}, {}
    for z, list in pairs(hintsByZone) do
        hiddenIn[z] = #list
        if chip == "all" or chip == "find" then
            for _, h in ipairs(list) do
                if (chip == "find" or h.sighted) and matches(q, h.sighted and h.h.n, z) then hints[#hints + 1] = h end
            end
        end
    end
    table.sort(hints, function(a, b)
        if (a.sighted and 1 or 0) ~= (b.sighted and 1 or 0) then return a.sighted and true or false end
        return (a.h.lv or 0) < (b.h.lv or 0)
    end)

    local sort = state.sort
    if sort == "kills" then
        return sortedSection(nil, own, function(a, b) return (a.m.kills or 0) > (b.m.kills or 0) end)
    elseif sort == "last" then
        return sortedSection(nil, own, function(a, b) return (a.m.last or 0) > (b.m.last or 0) end)
    elseif sort == "next" then
        local list = {}
        for _, e in ipairs(own) do if WFD:MobStage(e.m) < 3 then list[#list + 1] = e end end
        local function left(m)
            return (WFD:MobStage(m) == 1 and WFD.STAGE_COLOUR or WFD.STAGE_MASTER) - (m.kills or 0)
        end
        return sortedSection(L["Almost there"], list, function(a, b) return left(a.m) < left(b.m) end)
    elseif sort == "kind" then
        local out = groupBy(own, function(e) return e.m.ctype or L["Other"] end)
        table.sort(out, function(a, b) return #a.items > #b.items end)
        for _, g in ipairs(out) do g.right = UI.KindsText(#g.items) end
        if #hints > 0 then out[#out + 1] = { title = L["Not yet discovered"], items = hints } end
        return out
    end
    -- by area, the areas in the order of their first kill; covered cards after the own ones of their area
    local all = {}
    for _, e in ipairs(own) do all[#all + 1] = e end
    for _, h in ipairs(hints) do all[#all + 1] = h end
    local out = groupBy(all, function(e) return e.zone end)
    for _, g in ipairs(out) do
        local mine = 0
        for _, e in ipairs(g.items) do if not e.hint then mine = mine + 1 end end
        local hidden = hiddenIn[g.title] or 0
        g.right = UI.KindsText(mine) .. (hidden > 0 and ("  -  " .. format(L["%d to discover"], hidden)) or "")
        g.frac = (mine + hidden > 0) and mine / (mine + hidden) or nil
    end
    return out
end

UI.CollectionView({
    key = "bestiary", label = "Bestiary", group = "hunt",
    chips = { { "all", "All" }, { "rare", "Rare and bosses" }, { "master", "Connoisseurs" },
        { "sketch", "Sketches" }, { "nemesis", "Nemeses" }, { "find", "Still to find" } },
    sorts = { { "zone", "By area" }, { "kind", "By kind" }, { "kills", "Most slain" },
        { "next", "Closest to the next card" }, { "last", "Last slain" } },
    summary = function()
        local C = WFD.C
        local kinds, kills, masters, rare = 0, 0, 0, 0
        for _, m in pairs(C.mobs) do
            kinds = kinds + 1
            kills = kills + (m.kills or 0)
            if WFD:MobStage(m) == 3 then masters = masters + 1 end
            local rk = UI.RarityOf(m)
            if rk == "rare" or rk == "boss" then rare = rare + 1 end
        end
        local _, hidden = WFD:CreatureHints()
        return { { kinds, L["Kinds"] }, { WFD:Int(kills), L["Slain"] }, { masters, L["Connoisseur"] },
            { rare, L["Rare and bosses"] }, { hidden or 0, L["To discover"] } }
    end,
    data = bestiaryData,
    cell = {
        w = UI.CREATURE_CARD_W, h = UI.CREATURE_CARD_H, gap = 12,
        make = function(parent) return UI.NewCreatureCard(parent) end,
        fill = function(f, item)
            local e = item.entry
            f:SetEntry(e, nil, e.zone)
        end,
    },
    detail = function(rp, id) UI.CreatureReport(rp, id) end,          -- (Cards.lua)
    keyOf = function(e) if not e.hint then return e.id end end,
    empty = function(state)
        if next(WFD.C.mobs) == nil then return { icon = UI.Icon("bestiary"), title = L["Nothing here yet."], hint = L["Every creature you slay gets its card here: where it lives, how often it fell, what it left behind."], button = { L["Hunting grounds"], UI.PartRoute("huntgrounds") } } end
        return L["Nothing matches this choice."]
    end,
    extra = { { "Hunting grounds", function() R.Go(UI.PartRoute("huntgrounds")) end } },
})

------------------------------------------------------------------------
-- The angler's log
------------------------------------------------------------------------
UI.PART_VIEW.fishbook = "fishbook"

local function fishData(state)
    local arr = UI.CatchCollection()
    local hintsByZone = WFD.CatchHints and WFD:CatchHints() or {}
    local chip, q = state.chip, state.q
    local own = {}
    if chip ~= "find" then
        for _, a in ipairs(arr) do
            local kind = a.e.kind or "other"
            if (chip == "all" or chip == kind) and matches(q, a.e.name, a.zone) then own[#own + 1] = a end
        end
    end
    local hints, hiddenIn = {}, {}
    for z, list in pairs(hintsByZone) do
        hiddenIn[z] = #list
        if chip == "find" then
            for _, h in ipairs(list) do
                if matches(q, z) then hints[#hints + 1] = h end
            end
        end
    end
    local sort = state.sort
    if sort == "most" then
        return sortedSection(nil, own, function(a, b) return (a.e.n or 0) > (b.e.n or 0) end)
    elseif sort == "new" then
        return sortedSection(nil, own, function(a, b) return (a.e.first or 0) > (b.e.first or 0) end)
    elseif sort == "kind" then
        local out = groupBy(own, function(a) return L[(UI.FISH_KINDS[a.e.kind or "other"] or UI.FISH_KINDS.other).label] end)
        for _, g in ipairs(out) do g.right = UI.KindsText(#g.items) end
        return out
    end
    local all = {}
    for _, a in ipairs(own) do all[#all + 1] = a end
    for _, h in ipairs(hints) do all[#all + 1] = h end
    local out = groupBy(all, function(a) return a.zone end)
    for _, g in ipairs(out) do
        local mine = 0
        for _, a in ipairs(g.items) do if not a.hint then mine = mine + 1 end end
        local hidden = hiddenIn[g.title] or 0
        g.right = UI.KindsText(mine) .. (hidden > 0 and ("  -  " .. format(L["%d to discover"], hidden)) or "")
        g.frac = (mine + hidden > 0) and mine / (mine + hidden) or nil
    end
    return out
end

UI.CollectionView({
    key = "fishbook", label = "Angler's log", group = "hunt",
    chips = { { "all", "All" }, { "fish", "Fish" }, { "treasure", "Treasure" }, { "junk", "Junk" },
        { "other", "Odds and ends" }, { "find", "Still to find" } },
    sorts = { { "zone", "By water" }, { "kind", "By kind" }, { "most", "Most caught" }, { "new", "Newest first" } },
    summary = function()
        local s = WFD:CatchSummary()
        local _, hidden = WFD:CatchHints()
        return { { s.species, L["Kinds"] }, { WFD:Int(s.total), L["Caught"] }, { WFD:Int(s.casts), L["Casts"] },
            { hidden or 0, L["To discover"] } }
    end,
    data = fishData,
    cell = {
        w = UI.CATCH_CARD_W, h = UI.CATCH_CARD_H, gap = 12,
        make = function(parent)
            local f = CreateFrame("Frame", nil, parent)
            f.pool = UI.NewPool(f)
            return f
        end,
        fill = function(f, item)
            f.pool:Begin()
            UI.DrawCatchCard(f.pool, f, 0, 0, item.entry)
            f.pool:End()
        end,
    },
    cardKind = "catch",
    keyOf = function(a) if not a.hint then return a.id end end,
    empty = function()
        if next(WFD.C.catch or {}) == nil then return { icon = UI.Icon("fish"), title = L["Nothing here yet."], hint = L["Fish with a rod anywhere: every new catch gets its card here."], button = { L["Waters and tackle"], UI.PartRoute("fishwaters") } } end
        return L["Nothing matches this choice."]
    end,
    extra = { { "Waters and tackle", function() R.Go(UI.PartRoute("fishwaters")) end } },
})
