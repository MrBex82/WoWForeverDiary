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
-- A list laid over the book: every creature of one kind, a click opens its wanted poster
------------------------------------------------------------------------
local LIST_ROWS, LIST_W, LIST_ROW = 16, 300, 20
local listPanel

local function buildList()
    local bf = UI.bookFrame
    local p = UI.Frame(bf, LIST_W, 100)
    p:SetFrameLevel(bf:GetFrameLevel() + 40)
    p:EnableMouse(true)
    UI.Backdrop(p, "tooltip", 14, 3, { 0.07, 0.045, 0.025, 0.97 }, { 0.90, 0.70, 0.30, 1 })
    p.icon = p:CreateTexture(nil, "ARTWORK")
    p.icon:SetSize(26, 26)
    p.icon:SetPoint("TOPLEFT", 14, -12)
    p.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    p.title = UI.Text(p, 16, c.gold, "LEFT", UI.HEAD, true)
    p.title:SetPoint("TOPLEFT", 48, -12)
    p.sub = UI.Text(p, 10, SOFT, "LEFT", UI.FONT, true)
    p.sub:SetPoint("TOPLEFT", p.title, "BOTTOMLEFT", 0, -3)
    local ok, close = pcall(CreateFrame, "Button", nil, p, "UIPanelCloseButton")
    if not (ok and close) then close = UI.Button(p, "X", 22, 22) end
    close:SetPoint("TOPRIGHT", 2, 2)
    close:SetScript("OnClick", function() p:Hide() end)
    p.rows = {}
    for i = 1, LIST_ROWS do
        local r = CreateFrame("Button", nil, p)
        r:SetSize(LIST_W - 28, LIST_ROW - 2)
        r:SetPoint("TOPLEFT", 14, -50 - (i - 1) * LIST_ROW)
        r.hl = UI.Fill(r, { 0.91, 0.76, 0.42 }, "BACKGROUND", 0, 0.12)
        r.hl:SetAllPoints()
        r.hl:Hide()
        r.right = UI.Text(r, 10, SOFT, "RIGHT", UI.FONT, true)
        r.right:SetPoint("RIGHT", -2, 0)
        r.name = UI.Text(r, 12, LIGHT, "LEFT", UI.FONT, true)
        r.name:SetPoint("LEFT", 4, 0)
        r.name:SetPoint("RIGHT", r.right, "LEFT", -8, 0)
        r.name:SetWordWrap(false)
        r:SetScript("OnEnter", function(s) s.hl:Show() end)
        r:SetScript("OnLeave", function(s) s.hl:Hide() end)
        r:SetScript("OnClick", function(s) local id = rawget(s, "id") if id then UI:ShowCard("creature", id) end end)
        p.rows[i] = r
    end
    p.more = UI.Text(p, 10, SOFT, "CENTER", UI.FONT, true)
    p.more:SetPoint("BOTTOM", 0, 10)
    bf:HookScript("OnHide", function() p:Hide() end)
    p:Hide()
    return p
end

local function showKindList(g, side)
    listPanel = listPanel or buildList()
    UI.kindPanel = listPanel
    local p = listPanel
    p.icon:SetTexture(UI.IconPath(TYPE_ICONS[g.key] or TYPE_ICONS.other, "bestiary"))
    p.title:SetText(g.name)
    p.sub:SetText(WFD:Count("%d kinds, %d slain", g.kinds, g.kills))
    for i, r in ipairs(p.rows) do
        local e = g.mobs[i]
        if e then
            r.id = e.id
            r.name:SetText(e.m.name or "?")
            r.right:SetText(format(L["Lv %s"], e.m.level == -1 and "??" or tostring(e.m.level or "?"))
                .. "   " .. UI.ShortCount(e.m.kills or 0) .. "x")
            r:Show()
        else
            r.id = nil
            r:Hide()
        end
    end
    local n = min(#g.mobs, LIST_ROWS)
    p.more:SetShown(#g.mobs > LIST_ROWS)
    p.more:SetText(format("+ %d ...", #g.mobs - LIST_ROWS))
    p:SetHeight(60 + n * LIST_ROW + (#g.mobs > LIST_ROWS and 16 or 0))
    p:ClearAllPoints()
    p:SetPoint("TOP", UI.pageFrames[side], "TOP", 0, -70)
    p:Show()
end

-- the list belongs to the spread it was opened on
local spread0 = UI.ShowSpread
function UI:ShowSpread(s)
    if listPanel and listPanel:IsShown() and s ~= self.spread then listPanel:Hide() end
    return spread0(self, s)
end

------------------------------------------------------------------------
-- By kind: beasts, humanoids, undead ... each with its families
------------------------------------------------------------------------
UI:RegisterRenderer("albumkinds", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Kinds of creatures"], L["What you have slain, by type"], -56)

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
        g.mobs[#g.mobs + 1] = { id = id, m = m }
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
        cnt:SetText(WFD:Count("%d kinds, %d slain", g.kinds, g.kills))
        cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 4)
        -- the families, else the first names
        local parts = {}
        local fams = {}
        for f, k in pairs(g.fams) do fams[#fams + 1] = { f = f, k = k } end
        table.sort(fams, function(a, b) if a.k ~= b.k then return a.k > b.k end return a.f < b.f end)
        for _, f in ipairs(fams) do parts[#parts + 1] = f.f .. " " .. f.k end
        table.sort(g.mobs, function(a, b)
            if (a.m.kills or 0) ~= (b.m.kills or 0) then return (a.m.kills or 0) > (b.m.kills or 0) end
            return (a.m.name or "") < (b.m.name or "")
        end)
        if #parts == 0 then
            for k = 1, min(3, #g.mobs) do parts[#parts + 1] = g.mobs[k].m.name or "?" end
        end
        local sub = pool:Text(10, c.inkSoft, UI.FONT)
        sub:SetText(table.concat(parts, "  -  "))
        sub:SetWordWrap(false)
        sub:SetWidth(tw - 40)
        sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y - 19)
        UI.ProgressBar(pool, canvas, tx + 40, y - 34, tw - 40, 3, g.kinds / most, c.redInk)
        -- the tooltip names them all (the most hunted first)
        local tip = { g.name, WFD:Count("%d kinds, %d slain", g.kinds, g.kills) }
        for k = 1, min(8, #g.mobs) do
            tip[#tip + 1] = (g.mobs[k].m.name or "?") .. "  (" .. (g.mobs[k].m.kills or 0) .. ")"
        end
        if #g.mobs > 8 then tip[#tip + 1] = format("+ %d ...", #g.mobs - 8) end
        local hot = pool:Hot(tip, function() showKindList(g, side) end)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 1)
        hot:SetSize(tw + 4, ROW - 4)
        y = y - ROW
    end
end)

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

------------------------------------------------------------------------
-- Almost there: the creatures closest to their next stage, and what you saw but never slew
------------------------------------------------------------------------
UI:RegisterRenderer("albumnext", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Almost there"], L["Who is closest to the next stage"], -56)
    local bottom = -(UI.PH - UI.BOTTOM)

    local near = {}
    for id, m in pairs(C.mobs) do
        local stage = WFD:MobStage(m)
        if stage < 3 then
            local goal = stage == 1 and WFD.STAGE_COLOUR or WFD.STAGE_MASTER
            near[#near + 1] = { id = id, m = m, goal = goal, left = goal - (m.kills or 0), stage = stage }
        end
    end
    table.sort(near, function(a, b)
        if a.left ~= b.left then return a.left < b.left end
        return (a.m.name or "") < (b.m.name or "")
    end)
    -- sighted ones worth hunting: no critters and nothing far below you (grey to you, like a rat in the
    -- city), the area you are in first, then those nearest your level
    local lvl = UnitLevel("player") or 1
    local seen = {}
    for _, s in pairs(C.sighted or {}) do
        local grey = s.lv and s.lv > 0 and s.lv < lvl - 7
        if s.cls ~= "trivial" and s.cls ~= "minus" and not grey then seen[#seen + 1] = s end
    end
    table.sort(seen, function(a, b)
        local ah, bh = a.z == WFD.zoneName, b.z == WFD.zoneName
        if ah ~= bh then return ah end
        local da, db = math.abs((a.lv or lvl) - lvl), math.abs((b.lv or lvl) - lvl)
        if da ~= db then return da < db end
        return (a.n or "") < (b.n or "")
    end)

    -- room: the sighted ones get up to five lines below, the rest goes to the closest ones
    local SEEN_ROW, ROW = 20, 50
    local seenN = min(#seen, 5)
    local reserve = seenN > 0 and (40 + seenN * SEEN_ROW) or 0
    local rows = math.max(0, min(#near, floor((y - bottom - reserve) / ROW)))
    for i = 1, rows do
        local e = near[i]
        local m = e.m
        local ic = pool:Icon(UI.IconPath(TYPE_ICONS[WFD:CreatureTypeKey(m.ctype)] or TYPE_ICONS.other, "bestiary"), 26, "ARTWORK", 1, true)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 4)
        -- top line: the name, and the count against the goal in plain ink on the right
        local count = pool:Text(14, c.ink, UI.HEAD, "RIGHT")
        count:SetText(format("%d / %d", m.kills or 0, e.goal))
        count:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 1)
        local n = pool:Text(13, c.ink, UI.FONT)
        n:SetText(m.name or "?")
        n:SetWordWrap(false)
        n:SetWidth(tw - 36 - count:GetStringWidth() - 10)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 36, y - 2)
        -- the bar, then in a calm light line what the next stage brings
        UI.ProgressBar(pool, canvas, tx + 36, y - 21, tw - 36, 5, (m.kills or 0) / e.goal, e.stage == 1 and c.redInk or c.goldDk)
        local what = pool:Text(11, c.inkSoft, UI.FONT)
        what:SetText(format(e.stage == 1 and L["%d more, then in colour"] or L["%d more, then a connoisseur"], e.left))
        what:SetWordWrap(false)
        what:SetWidth(tw - 36)
        what:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 36, y - 31)
        local hot = pool:Hot({ m.name or "?", format("%d / %d", m.kills or 0, e.goal), L["Click for the wanted poster."] },
            function() UI:ShowCard("creature", e.id) end)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 1)
        hot:SetSize(tw + 4, ROW - 6)
        y = y - ROW
    end

    if seenN > 0 then
        y = y - 6
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Sighted, not yet slain"], tostring(#seen))
        y = y - 22
        for i = 1, seenN do
            local s = seen[i]
            local here = s.z == WFD.zoneName
            local dir = WFD:Direction(s.x, s.y)
            local place = (s.z or "") .. (dir and ("  -  " .. L[dir]) or "")
            local where = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
            where:SetText(place)
            where:SetWordWrap(false)
            where:SetWidth(tw * 0.5)
            where:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
            local n = pool:Text(12, here and c.redInk or c.ink, UI.FONT)
            n:SetText(s.n or "?")
            n:SetWordWrap(false)
            n:SetWidth(tw * 0.5 - 8)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 1)
            local tip = { s.n or "?", place }
            if s.lv then tip[#tip + 1] = format(L["Level %s"], s.lv == -1 and "??" or tostring(s.lv)) end
            local go
            if s.m and s.x then
                tip[#tip + 1] = L["Click to set a marker on the map."]
                go = function() WFD:SetMapMarker(s.m, s.x, s.y, s.n) end
            end
            local hot = pool:Hot(tip, go)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 2)
            hot:SetSize(tw + 4, SEEN_ROW - 2)
            y = y - SEEN_ROW
        end
    end
    if rows == 0 and seenN == 0 then
        local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
        e:SetText(L["No creature has fallen yet."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 10)
    end
end)

------------------------------------------------------------------------
-- Still to discover in an area: what you only saw and what your other characters know, as one list
-- in place of pages full of covered cards
------------------------------------------------------------------------
UI.HINT_ROWS = 12
local HINT_ROW = 34

local function hintEdge(h)
    return (h.boss and { 0.75, 0.25, 0.15, 1 }) or (h.rare and { 0.45, 0.60, 0.95, 1 })
        or ((h.cls == "elite" or h.cls == "rareelite") and { 0.90, 0.70, 0.25, 1 }) or { 0.62, 0.48, 0.24, 1 }
end

-- a medallion for a hint: a question mark, or the number of kinds a line bundles
local function hintMedal(pool, canvas, x, y, h, label)
    local rim = pool:Circle(26, hintEdge(h))
    rim:SetPoint("CENTER", canvas, "TOPLEFT", x + 13, y - 13)
    local inner = pool:Circle(22, { 0.10, 0.07, 0.04, 1 })
    inner:SetPoint("CENTER", canvas, "TOPLEFT", x + 13, y - 13)
    local q = pool:Text(label and 11 or 14, { 0.88, 0.76, 0.54, 1 }, label and UI.FONT or UI.HEAD, "CENTER")
    q:SetText(label or "?")
    q:SetPoint("CENTER", canvas, "TOPLEFT", x + 13, y - 13)
end

-- what another character knows, several kinds on one line: how many, the levels, and where they are
local function bundleRow(pool, canvas, tx, tw, y, e)
    local lo, hi = nil, nil
    local tip = { WFD:Count("%d kinds %s already knows", #e.list, e.who), e.zone }
    for _, x in ipairs(e.list) do
        local lv = x.h.lv
        if lv and lv > 0 then lo, hi = math.min(lo or lv, lv), math.max(hi or lv, lv) end
        local dir = WFD:Direction(x.h.x, x.h.y)
        tip[#tip + 1] = (dir and L[dir] or "?") .. (lv and ("  -  " .. format(L["Lv %s"], lv == -1 and "??" or tostring(lv))) or "")
    end
    hintMedal(pool, canvas, tx, y, e.h, tostring(#e.list))
    local name = pool:Text(13, c.inkSoft, UI.FONT)
    name:SetText(WFD:Count("%d kinds %s already knows", #e.list, e.who))
    name:SetWordWrap(false)
    name:SetWidth(tw - 36)
    name:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 34, y - 1)
    local sub = pool:Text(10, c.inkSoft, UI.FONT)
    sub:SetText(lo and format(L["Lv %s"], lo == hi and tostring(lo) or (lo .. "-" .. hi)) or "")
    sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 34, y - 17)
    local m = e.h.m
    if m then tip[#tip + 1] = L["Click for the map of this region."] end
    local hot = pool:Hot(tip, m and function() UI:ShowMapOf(m) end)
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 2)
    hot:SetSize(tw + 4, HINT_ROW - 4)
end

UI:RegisterRenderer("albumhints", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = -UI.TOP
    for gi, g in ipairs(page.groups) do
        -- the area's heading; one below another keeps a little room above it
        if gi > 1 then y = y - 14 end
        UI.AlbumHead(pool, canvas, tx, tw, g, y)
        y = y - 28
        if gi == 1 then
            local cap = pool:Text(10, c.redInk, UI.FONT)
            cap:SetText(L["Not yet discovered"]:upper())
            cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            y = y - 20
        else
            y = y - 6
        end
        for _, e in ipairs(g.rows) do
            if e.bundle then
                bundleRow(pool, canvas, tx, tw, y, e)
            else
                UI.HintRow(pool, canvas, tx, tw, y, e)
            end
            y = y - HINT_ROW
        end
    end
end)

function UI.HintRow(pool, canvas, tx, tw, y, e)
    local h = e.h
    -- a small medallion with a question mark, its rim in the colour of the rank
    hintMedal(pool, canvas, tx, y, h)

    local name = pool:Text(13, e.sighted and c.ink or c.inkSoft, UI.FONT)
    name:SetText(e.sighted and (h.n or "?") or L["Not yet discovered"])
    name:SetWordWrap(false)
    name:SetWidth(tw - 36)
    name:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 34, y - 1)
    local parts = {}
    local dir = WFD:Direction(h.x, h.y)
    if dir then parts[#parts + 1] = L[dir] end
    if h.lv then parts[#parts + 1] = format(L["Lv %s"], h.lv == -1 and "??" or tostring(h.lv)) end
    local kind = (h.boss and L["Boss"]) or (h.rare and L["Rare"]) or ((h.cls == "elite" or h.cls == "rareelite") and L["Elite"])
    if kind then parts[#parts + 1] = kind end
    if h.who then parts[#parts + 1] = format(L["Known to %s"], h.who) end
    local sub = pool:Text(10, c.inkSoft, UI.FONT)
    sub:SetText(table.concat(parts, "  -  "))
    sub:SetWordWrap(false)
    sub:SetWidth(tw - 36)
    sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 34, y - 17)

    local tip = { e.sighted and L["Sighted, not yet slain"] or L["Not yet discovered"] }
    if e.sighted and h.n then tip[#tip + 1] = h.n end
    tip[#tip + 1] = e.zone .. (dir and ("  -  " .. L[dir]) or "")
    local go, right
    if h.m and h.x then
        tip[#tip + 1] = L["Click to set a marker on the map."]
        tip[#tip + 1] = L["Right-click for the map of this region."]
        -- only a creature you saw yourself is named; the others stay a secret
        go = function() WFD:SetMapMarker(h.m, h.x, h.y, (e.sighted and h.n) or e.zone) end
        right = function() UI:ShowMapOf(h.m) end
    elseif h.m then
        tip[#tip + 1] = L["Click for the map of this region."]
        go = function() UI:ShowMapOf(h.m) end
    end
    local hot = pool:Hot(tip, go)
    hot.onRight = right
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 2)
    hot:SetSize(tw + 4, HINT_ROW - 4)
end
