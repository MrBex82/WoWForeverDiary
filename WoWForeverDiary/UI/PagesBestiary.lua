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

local LIGHT, SOFT = { 0.96, 0.90, 0.76, 1 }, { 0.80, 0.72, 0.56, 1 }

------------------------------------------------------------------------
-- Hunting grounds: where each kind fell first, area by area
------------------------------------------------------------------------
-- pin colours on the hunting map: clear apart from each other and from the sepia map
local PIN_COL = {
    normal = { 0.97, 0.95, 0.90, 1 }, elite = { 1.00, 0.78, 0.20, 1 },
    rare = { 0.45, 0.70, 1.00, 1 }, boss = { 0.92, 0.22, 0.12, 1 },
}
local SIGHTED_COL = { 0.22, 0.13, 0.06, 1 }        -- the rim of a hollow ring
local RING_INSIDE = { 0.84, 0.74, 0.56, 1 }        -- the map tone inside it
UI.huntArea = nil       -- the area shown, by name (kept while the book is open)

UI:RegisterRenderer("huntmap", function(pool, page, side, canvas, index)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local grounds = page.grounds
    -- the area: the one chosen, else the one you are in if you hunted there, else the one hunted most
    local pick
    for i, g in ipairs(grounds) do if g.zone == UI.huntArea then pick = i end end
    if not pick then
        local kills = {}
        for _, m in pairs(C.mobs or {}) do
            if m.zone then kills[m.zone] = (kills[m.zone] or 0) + (m.kills or 0) end
        end
        local most = 0
        for i, g in ipairs(grounds) do
            if g.zone == WFD.zoneName and (kills[g.zone] or 0) > 0 then pick = i break end
            if (kills[g.zone] or 0) > most then pick, most = i, kills[g.zone] end
        end
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

    -- slain: a full dot in the colour of its rank (a click opens the wanted poster);
    -- only sighted: a hollow ring, with a click setting a marker on the game's map
    local points, slain, seen = {}, 0, 0
    for id, mob in pairs(C.mobs) do
        if mob.map == g.map and mob.x then
            slain = slain + 1
            points[#points + 1] = { mob.x, mob.y, PIN_COL[UI.RarityOf(mob)] or PIN_COL.normal,
                { mob.name or "?", WFD:Count("Slain %d times", mob.kills or 0), WFD:Quote(WFD:MarginNote(id, mob)),
                  L["Click for the wanted poster."] },
                false, function() UI:ShowCard("creature", id) end }
        end
    end
    for _, s in pairs(C.sighted or {}) do
        if s.m == g.map and s.x then
            seen = seen + 1
            points[#points + 1] = { s.x, s.y, SIGHTED_COL, { s.n or "?", L["Sighted, not yet slain"],
                L["Click to set a marker on the map."] }, true, function() WFD:SetMapMarker(s.m, s.x, s.y, s.n) end }
        end
    end
    m:DrawPoints(g.map, points)
    -- you, when you are in this area right now
    local px, py, facing
    local ok, here = pcall(function() return C_Map.GetBestMapForUnit("player") end)
    if ok and here == g.map then
        local okPos, pos = pcall(C_Map.GetPlayerMapPosition, g.map, "player")
        if okPos and pos then px, py = pos:GetXY() end
        facing = GetPlayerFacing and GetPlayerFacing()
    end
    m:SetPlayer(px, py, facing)
    y = y - mh - MAT * 2 - 12

    -- legend, drawn like the pins
    local legend = {
        { PIN_COL.normal, L["Normal"] }, { PIN_COL.elite, L["Elite"] }, { PIN_COL.rare, L["Rare"] },
        { PIN_COL.boss, L["Boss"] }, { SIGHTED_COL, L["Sighted"], true },
    }
    local x = tx
    local step = tw / #legend
    for _, e in ipairs(legend) do
        local rim = pool:Circle(12, e[3] and e[1] or { 0.08, 0.04, 0.02, 1 })
        rim:SetPoint("CENTER", canvas, "TOPLEFT", x + 6, y - 6)
        local d = pool:Circle(e[3] and 6 or 8, e[3] and RING_INSIDE or e[1])
        d:SetPoint("CENTER", canvas, "TOPLEFT", x + 6, y - 6)
        local t = pool:Text(10, c.inkSoft, UI.FONT)
        t:SetText(e[2])
        t:SetWordWrap(false)
        t:SetWidth(step - 16)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 14, y - 1)
        x = x + step
    end
    y = y - 26

    local th = UI.Tiles(pool, canvas, tx, y, tw, {
        { slain, L["Kinds slain here"], c.ink },
        { seen, L["Sighted, not yet slain"], seen > 0 and c.redInk or c.ink },
        { format("%d / %d", pick, #grounds), L["Hunting grounds"], c.inkSoft },
    })
    y = y - th - 10
    local note = pool:Text(10, c.inkSoft, UI.FONT, "CENTER")
    note:SetText(L["Each pin marks where the first of its kind fell."])
    note:SetWidth(tw)
    note:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    -- on to the cards of this area; with large writing there is room for the link only, the note goes
    if g.page then
        local ly = y - note:GetStringHeight() - 8
        if ly - UI.FS(13) - 2 < -(UI.PH - UI.BOTTOM) then
            note:SetText("")
            ly = y
        end
        local link = pool:Link(L["To the album of this area"] .. "  >", function() UI:GoToPage(g.page) end, 13)
        link:SetPoint("TOP", canvas, "TOPLEFT", tx + tw / 2, ly)
    end
end)

-- (kinds, "almost there" and the lists of what is still to discover are views of the album now:
-- UI/Views/Albums.lua)
