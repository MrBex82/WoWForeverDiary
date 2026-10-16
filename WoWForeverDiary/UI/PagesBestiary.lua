-- Two more pages of the bestiary: the creatures by kind, and a map of the hunting grounds.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, min, format = math.floor, math.min, string.format

local TYPE_ICONS = {
    beast      = { "Ability_Hunter_Pet_Wolf", "Ability_Hunter_BeastTaming" },
    humanoid   = { "INV_Misc_Head_Human_01", "Ability_Warrior_RallyingCry" },
    undead     = { "Spell_Shadow_RaiseDead", "INV_Misc_Bone_HumanSkull_01" },
    demon      = { "Spell_Shadow_SummonFelHunter", "Spell_Shadow_SummonImp" },
    elemental  = { "Spell_Fire_Fire", "Spell_Nature_StrengthOfEarthTotem02" },
    dragonkin  = { "INV_Misc_Head_Dragon_01" },
    giant      = { "Ability_Warrior_Bloodfrenzy", "INV_Stone_15" },
    mechanical = { "Trade_Engineering", "INV_Gizmo_01" },
    critter    = { "Ability_Hunter_Pet_Cat", "INV_Misc_Food_15" },
    other      = { "INV_Misc_QuestionMark", "INV_Misc_Book_09" },
}

------------------------------------------------------------------------
-- By kind: beasts, humanoids, undead ... each with its families
------------------------------------------------------------------------
UI:RegisterRenderer("albumkinds", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Kinds of creatures"], L["Who fell to your blade, by kind"], -56)

    local groups, byType = {}, {}
    for id, m in pairs(C.mobs) do
        local t = m.ctype or L["Unknown kind"]
        local g = byType[t]
        if not g then
            g = { name = t, key = WFD:CreatureTypeKey(m.ctype), kinds = 0, kills = 0, fams = {}, mobs = {} }
            byType[t] = g
            groups[#groups + 1] = g
        end
        g.kinds = g.kinds + 1
        g.kills = g.kills + (m.kills or 0)
        if m.fam then g.fams[m.fam] = (g.fams[m.fam] or 0) + 1 end
        g.mobs[#g.mobs + 1] = m
    end
    table.sort(groups, function(a, b)
        if a.kinds ~= b.kinds then return a.kinds > b.kinds end
        return a.name < b.name
    end)
    if #groups == 0 then
        local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
        e:SetText(L["No creature has fallen yet."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 10)
        return
    end
    local most = groups[1].kinds
    local ROW = 46
    local bottom = -(UI.PH - UI.BOTTOM)
    for i, g in ipairs(groups) do
        if y - ROW < bottom then
            local more = pool:Text(11, c.inkFaint, UI.FONT)
            more:SetText(format("+ %d ...", #groups - i + 1))
            more:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y)
            break
        end
        local ic = pool:Icon(UI.IconPath(TYPE_ICONS[g.key] or TYPE_ICONS.other, "bestiary"), 30, "ARTWORK", 1, true)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 2)
        local n = pool:Text(15, c.ink, UI.HEAD)
        n:SetText(g.name)
        n:SetWordWrap(false)
        n:SetWidth(tw * 0.5)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y - 1)
        local cnt = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        cnt:SetText(format(L["%d kinds  -  %d slain"], g.kinds, g.kills))
        cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 4)
        -- the families, else the first names
        local parts = {}
        local fams = {}
        for f, k in pairs(g.fams) do fams[#fams + 1] = { f = f, k = k } end
        table.sort(fams, function(a, b) if a.k ~= b.k then return a.k > b.k end return a.f < b.f end)
        for _, f in ipairs(fams) do parts[#parts + 1] = f.f .. " " .. f.k end
        table.sort(g.mobs, function(a, b) return (a.kills or 0) > (b.kills or 0) end)
        if #parts == 0 then
            for k = 1, min(3, #g.mobs) do parts[#parts + 1] = g.mobs[k].name or "?" end
        end
        local sub = pool:Text(10, c.inkSoft, UI.FONT)
        sub:SetText(table.concat(parts, "  -  "))
        sub:SetWordWrap(false)
        sub:SetWidth(tw - 40)
        sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y - 19)
        UI.ProgressBar(pool, canvas, tx + 40, y - 34, tw - 40, 3, g.kinds / most, c.redInk)
        -- the tooltip names them all (the most hunted first)
        local tip = { g.name, format(L["%d kinds  -  %d slain"], g.kinds, g.kills) }
        for k = 1, min(14, #g.mobs) do
            tip[#tip + 1] = (g.mobs[k].name or "?") .. "  (" .. (g.mobs[k].kills or 0) .. ")"
        end
        if #g.mobs > 14 then tip[#tip + 1] = format("+ %d ...", #g.mobs - 14) end
        local hot = pool:Hot(tip)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 1)
        hot:SetSize(tw + 4, ROW - 4)
        y = y - ROW
    end
end)

------------------------------------------------------------------------
-- Hunting grounds: where each kind fell first, area by area
------------------------------------------------------------------------
local SIGHTED_COL = { 0.55, 0.55, 0.55, 1 }
UI.huntArea = nil       -- the area shown, by name (kept while the book is open)

UI:RegisterRenderer("huntmap", function(pool, page, side, canvas, index)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local grounds = page.grounds
    -- the area: the one chosen, else the one you are in, else the first
    local pick
    for i, g in ipairs(grounds) do if g.zone == UI.huntArea then pick = i end end
    if not pick then
        for i, g in ipairs(grounds) do if g.zone == WFD.zoneName then pick = i end end
    end
    pick = pick or 1
    local g = grounds[pick]
    UI.huntArea = g.zone

    local y = UI.PageTitle(pool, canvas, side, L["Hunting grounds"], g.zone, -56)
    -- arrows to the other areas, beside the area name
    if #grounds > 1 then
        local function arrow(text, dir, x, justify)
            local a = pool:Text(18, c.redInk, UI.HEAD, justify)
            a:SetText(text)
            a:SetPoint(justify == "LEFT" and "TOPLEFT" or "TOPRIGHT", canvas, "TOPLEFT", x, y + 44)
            local other = grounds[((pick - 1 + dir) % #grounds) + 1]
            local hot = pool:Hot({ other.zone }, function()
                UI.huntArea = other.zone
                UI:RenderPage(side, index)
            end)
            hot:SetPoint("TOPLEFT", a, "TOPLEFT", -8, 6)
            hot:SetPoint("BOTTOMRIGHT", a, "BOTTOMRIGHT", 8, -6)
        end
        arrow("<", -1, tx + 4, "LEFT")
        arrow(">", 1, tx + tw - 4, "RIGHT")
    end

    -- the map in a dark mount, like the map pages (same size: the map frames are shared)
    local MAT = 9
    local mw = tw - MAT * 2
    local mh = floor(mw / 1.5)
    local mat = pool:Rect({ 0.08, 0.055, 0.035 }, 1, "ARTWORK", 1)
    mat:SetSize(tw, mh + MAT * 2)
    mat:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    local m = pool:Map(mw, mh)
    m:SetSize(mw, mh)
    m:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + MAT, y - MAT)
    m:SetFrameLevel(canvas:GetFrameLevel() + 2)

    local points, slain, seen = {}, 0, 0
    local RARITY = UI.BESTIARY_RARITY
    for id, mob in pairs(C.mobs) do
        if mob.map == g.map and mob.x then
            slain = slain + 1
            local r = UI.RarityOf(mob)
            points[#points + 1] = { mob.x, mob.y, RARITY[r].border,
                { mob.name or "?", format(L["Slain %d times"], mob.kills or 0), "\"" .. WFD:MarginNote(id, mob) .. "\"" } }
        end
    end
    for _, s in pairs(C.sighted or {}) do
        if s.m == g.map and s.x then
            seen = seen + 1
            points[#points + 1] = { s.x, s.y, SIGHTED_COL, { s.n or "?", L["Sighted, not yet slain"] } }
        end
    end
    m:DrawPoints(g.map, points)
    y = y - mh - MAT * 2 - 12

    -- legend
    local legend = {
        { RARITY.normal.border, L["Normal"] }, { RARITY.elite.border, L["Elite"] }, { RARITY.rare.border, L["Rare"] },
        { RARITY.boss.border, L["Boss"] }, { SIGHTED_COL, L["Sighted"] },
    }
    local x = tx
    local step = tw / #legend
    for _, e in ipairs(legend) do
        local d = pool:Circle(8, e[1])
        d:SetPoint("CENTER", canvas, "TOPLEFT", x + 6, y - 6)
        local t = pool:Text(10, c.inkSoft, UI.FONT)
        t:SetText(e[2])
        t:SetWordWrap(false)
        t:SetWidth(step - 16)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 14, y - 1)
        x = x + step
    end
    y = y - 26

    UI.Tiles(pool, canvas, tx, y, tw, {
        { slain, L["Kinds slain here"], c.ink },
        { seen, L["Sighted, not yet slain"], seen > 0 and c.redInk or c.ink },
        { format("%d / %d", pick, #grounds), L["Hunting grounds"], c.inkSoft },
    })
    y = y - 52
    local note = pool:Text(10, c.inkFaint, UI.FONT, "CENTER")
    note:SetText(L["Each pin marks where the first of its kind fell."])
    note:SetWidth(tw)
    note:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
end)
