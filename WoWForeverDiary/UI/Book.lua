-- The window and its cover: the closed book that greets you, the frame the travel desk lives in, the minimap button,
-- and what is shared by all views (measuring text, the order of the parts and their lines).
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, ceil, format = math.floor, math.max, math.min, math.ceil, string.format

-- geometry ------------------------------------------------------------
local PW, PH, GUT, BRD = 420, 560, 22, 18
UI.PW, UI.PH = PW, PH
UI.TOP, UI.BOTTOM = 50, 54                  -- text area inside a page
UI.AREA_H = PH - UI.TOP - UI.BOTTOM
UI.INNER, UI.OUTER = 38, 34                 -- margins at the spine / at the outer edge
local BW, BH = PW * 2 + GUT + BRD * 2, PH + BRD * 2

UI.renderers = {}
UI.sections = {}

function UI:RegisterRenderer(kind, fn) self.renderers[kind] = fn end

-- The order of the book, in one place: the parts in groups, from what you open every day to what you
-- look things up in. Each group has its own tab colour and a heading in the contents.
-- Every group but the front one has a tab of its own that leads to its overview page (PagesToday.lua).
UI.GROUPS = {
    { key = "front",     col = { 0.45, 0.28, 0.14 } },
    { key = "goals",     col = { 0.66, 0.48, 0.10 }, label = "Goals and honour", icon = "album" },
    { key = "chronicle", col = { 0.40, 0.20, 0.50 }, label = "Chronicle", icon = "records" },
    { key = "world",     col = { 0.20, 0.42, 0.20 }, label = "The world", icon = "atlas" },
    { key = "hunt",      col = { 0.56, 0.12, 0.08 }, label = "Hunt and loot", icon = "beast" },
    { key = "people",    col = { 0.16, 0.32, 0.54 }, label = "People and money", icon = "party" },
    { key = "back",      col = { 0.34, 0.27, 0.20 }, label = "Keepsakes", icon = "kin" },
}
UI.GROUP = {}
for i, g in ipairs(UI.GROUPS) do g.index = i; UI.GROUP[g.key] = g end
-- part = { group, order, line on the group's overview page }. Parts have no tab of their own:
-- the tabs are Contents, Today, Diary, Quest book and one per group.
local LAYOUT = {
    memoriam = { "front", 1 }, quests = { "front", 3, "Tasks taken and done" },
    tasks = { "goals", 4.8, "Day, week and month" },
    collection = { "goals", 5, "What is left to discover" }, honour = { "goals", 6, "Honour points" },
    milestones = { "chronicle", 10, "The great moments of a life" }, firsts = { "chronicle", 11, "Every first, with its day and place" },
    records = { "chronicle", 12, "The best and the worst of days" },
    levels = { "chronicle", 13, "How long each level took" }, yearbook = { "chronicle", 14.5, "A year of travel in figures" },
    recap = { "chronicle", 14.7, "A week of travel in figures" }, gallery = { "chronicle", 14, "Moments, painted in the gear of their day" },
    atlas = { "world", 19, "Regions explored" },
    landmarks = { "world", 21, "Famous places of Azeroth" },
    runs = { "world", 25, "Dark places, rich rewards" },
    fates = { "hunt", 31, "Every fall on the way" },
    fishwaters = { "hunt", 33, "Where the line was cast, and with what" }, treasures = { "hunt", 35, "Best find for every slot" },
    people = { "people", 40, "Everyone I met on my way" }, companions = { "people", 45, "Who walked beside me" },
    stable = { "people", 46, "Every mount, and the day it was first ridden" }, standing = { "people", 47, "How the factions came to see me" },
    ledger = { "people", 50, "Every coin, in and out" },
    family = { "back", 86, "Who got there first?" }, library = { "back", 85.7, "Books I read along the way" }, capsule = { "back", 88, "Letters to my future self" },
}

UI.LAYOUT = LAYOUT        -- the overview pages read the lines of parts that are views of the travel desk now

-- def = { key, label, icon, order, build = function(book) ... end }
function UI:RegisterSection(def)
    local lay = LAYOUT[def.key]
    if lay then
        def.group, def.order, def.sub = lay[1], lay[2], lay[3]
        if def.key ~= "quests" then def.thumb = false end
    end
    def.group = def.group or "back"
    self.sections[#self.sections + 1] = def
    table.sort(self.sections, function(a, b) return a.order < b.order end)
end

-- x of the text column on a page side
function UI.TextX(side) return side == "left" and UI.OUTER or UI.INNER end
function UI.TextW() return PW - UI.INNER - UI.OUTER end

------------------------------------------------------------------------
-- Text measuring for pagination
------------------------------------------------------------------------
local measureFrame = CreateFrame("Frame", nil, UIParent)
measureFrame:SetSize(10, 10)
measureFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
measureFrame:SetAlpha(0)
local mfs = measureFrame:CreateFontString(nil, "OVERLAY")
local measureCache = {}

function UI.Measure(text, size, width, spacing, font)
    local key = (font or UI.HEAD) .. size .. ":" .. width .. ":" .. (spacing or 0) .. ":" .. text
    local v = measureCache[key]
    if v then return v end
    mfs:SetFont(font or UI.HEAD, size, "")
    mfs:SetSpacing(spacing or 0)
    mfs:SetWidth(width)
    mfs:SetText(text)
    v = mfs:GetStringHeight() or 0
    if v <= 0 then
        -- fallback estimate if the client cannot measure hidden text
        local lines = ceil((#text * size * 0.48) / width)
        v = lines * (size + (spacing or 0))
    end
    measureCache[key] = v
    return v
end

function UI.MeasureWidth(text, size, font)
    mfs:SetFont(font or UI.HEAD, size, "")
    mfs:SetSpacing(0)
    mfs:SetWidth(0)
    mfs:SetText(text)
    local w = mfs:GetStringWidth() or 0
    if w <= 0 then w = size * 0.75 * #text end
    return w
end

function UI.ClearCaches()
    measureCache = {}
    UI.storyCache = {}
end

-- text is measured at the scale it is drawn at: the frame the pages are drawn in
function UI.MeasureAt(frame)
    measureFrame:SetParent(frame)
    measureFrame:ClearAllPoints()
    measureFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    measureFrame:SetFrameLevel(1)
    measureCache = {}
end
UI.storyCache = {}


------------------------------------------------------------------------
-- Building the frames
------------------------------------------------------------------------
local function sound(name, fallback)
    local id = SOUNDKIT and SOUNDKIT[name] or fallback
    if id and PlaySound then pcall(PlaySound, id) end
end
UI.Sound = sound

local function fadeIn(frame)
    frame:SetAlpha(0)
    frame.fadeT = 0
    frame:SetScript("OnUpdate", function(self, dt)
        self.fadeT = self.fadeT + dt
        local a = min(1, self.fadeT / 0.22)
        self:SetAlpha(a)
        if a >= 1 then self:SetScript("OnUpdate", nil) end
    end)
end

local function leather(f, inset)
    UI.Leather(f, inset, 1, 0.30)
    UI.EdgeFade(f, "LEFT", 60, { 0, 0, 0 }, 0.45, "BACKGROUND", 3, inset)
    UI.EdgeFade(f, "RIGHT", 60, { 0, 0, 0 }, 0.45, "BACKGROUND", 3, inset)
    UI.EdgeFade(f, "BOTTOM", 60, { 0, 0, 0 }, 0.45, "BACKGROUND", 3, inset)
    UI.EdgeFade(f, "TOP", 50, { 1, 0.80, 0.55 }, 0.07, "BACKGROUND", 4, inset)
end

------------------------------------------------------------------------
-- The closed cover (start screen)
------------------------------------------------------------------------
local CVW, CVH = 450, BH
local BRASS = { 0.76, 0.58, 0.26, 1 }

-- the faction emblem, gold-stamped: path, texture coordinates, whether it is a square icon
local CRESTS = {
    Alliance = {
        { "Interface\\Timer\\Alliance-Logo", { 0, 1, 0, 1 } },
        { "Interface\\FriendsFrame\\PlusManz-Alliance", { 0, 1, 0, 1 } },
        { "Interface\\Icons\\INV_BannerPVP_02", { 0.08, 0.92, 0.08, 0.92 }, true },
    },
    Horde = {
        { "Interface\\Timer\\Horde-Logo", { 0, 1, 0, 1 } },
        { "Interface\\FriendsFrame\\PlusManz-Horde", { 0, 1, 0, 1 } },
        { "Interface\\Icons\\INV_BannerPVP_01", { 0.08, 0.92, 0.08, 0.92 }, true },
    },
}

local function factionCrest()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    for _, e in ipairs(CRESTS[faction] or {}) do
        if UI.Has(e[1]) then return e[1], e[2], e[3] end
    end
    return UI.Icon("journal"), { 0.08, 0.92, 0.08, 0.92 }, true
end

-- how worn the book is: nothing on the first day, fully worn after about four months
function UI.Wear()
    return math.max(0, math.min(1, (WFD:NumDays() - 1) / 120))
end

-- the binding grows with the honours: corner studs change metal with the honour points,
-- a gem is set into the lozenge for every ten tiers, the spine gets a gold mark for every ten levels
UI.COVER_METALS = { { 150, 1 }, { 500, 2 }, { 1000, 3 }, { 1800, 4 }, { 2800, 5 } }
local GEM_COLOURS = {
    { 0.80, 0.12, 0.10 }, { 0.16, 0.38, 0.90 }, { 0.16, 0.70, 0.28 }, { 0.62, 0.22, 0.80 },
    { 0.95, 0.70, 0.12 }, { 0.20, 0.75, 0.80 }, { 0.92, 0.92, 0.95 }, { 0.95, 0.38, 0.10 },
}

function UI:CoverGrowth()
    local _, sum = WFD:HonourState()
    local metal = 0
    for _, m in ipairs(UI.COVER_METALS) do if sum.points >= m[1] then metal = m[2] end end
    local nextMetal
    for _, m in ipairs(UI.COVER_METALS) do if sum.points < m[1] then nextMetal = m break end end
    local level = UnitLevel("player") or 1
    if WFD.demo and WFD.C.level then level = WFD.C.level end
    return {
        points = sum.points, metal = metal, nextMetal = nextMetal,
        tiers = sum.tiers, gems = math.min(8, floor(sum.tiers / 10)),
        marks = math.min(6, floor(level / 10)), level = level,
    }
end

function UI:RefreshCoverGrowth()
    local cv = self.cover
    if not cv or not cv.deco then return end
    local ok, g = pcall(self.CoverGrowth, self)
    if not ok then return end
    cv.growth = g
    for _, s in ipairs(cv.studs) do
        local shown = g.metal > 0
        s.shadow:SetShown(shown)
        s.body:SetShown(shown)
        s.shine:SetShown(shown)
        if shown then s.body:SetVertexColor(col4(WFD.METALS[g.metal].col)) end
    end
    for i, gem in ipairs(cv.gems) do
        local shown = i <= g.gems
        gem.setting:SetShown(shown)
        gem.stone:SetShown(shown)
        gem.spark:SetShown(shown)
        if shown then
            local col = GEM_COLOURS[i]
            gem.stone:SetVertexColor(col[1], col[2], col[3], 1)
        end
    end
    for i, d in ipairs(cv.spine) do d:SetShown(i <= g.marks) end
    -- the wear of the days
    local w = UI.Wear()
    for _, e in ipairs(cv.wear) do
        local a = e.from and (w > e.from and e.a * w or 0) or e.a * w
        if e.edge then
            local from, to = { 1, 0.82, 0.58, a }, { 1, 0.82, 0.58, 0 }
            if e.edge == "TOP" then UI.Gradient(e.tex, "VERTICAL", to, from)
            elseif e.edge == "BOTTOM" then UI.Gradient(e.tex, "VERTICAL", from, to)
            elseif e.edge == "LEFT" then UI.Gradient(e.tex, "HORIZONTAL", from, to)
            else UI.Gradient(e.tex, "HORIZONTAL", to, from) end
        else
            e.tex:SetAlpha(a)
        end
    end
end

-- tooltip of the closed book: what the binding shows, and what comes next
function UI:CoverTooltip(owner)
    local g = self.cover and self.cover.growth
    if not g then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["The binding"], 1, 0.86, 0.5)
    local metalName = g.metal > 0 and L[WFD.METALS[g.metal].name] or L["none yet"]
    GameTooltip:AddDoubleLine(L["Corner studs"], metalName, 0.9, 0.9, 0.9, 1, 0.82, 0.4)
    if g.nextMetal then
        GameTooltip:AddLine(format(L["Next metal at %d honour points (now %d)."], g.nextMetal[1], g.points), 0.7, 0.7, 0.7, true)
    end
    GameTooltip:AddDoubleLine(L["Gems"], g.gems .. " / 8", 0.9, 0.9, 0.9, 1, 0.82, 0.4)
    if g.gems < 8 then
        GameTooltip:AddLine(format(L["One gem for every ten honour tiers (now %d)."], g.tiers), 0.7, 0.7, 0.7, true)
    end
    GameTooltip:AddDoubleLine(L["Gold marks on the spine"], g.marks .. " / 6", 0.9, 0.9, 0.9, 1, 0.82, 0.4)
    if g.marks < 6 then GameTooltip:AddLine(L["One for every ten levels."], 0.7, 0.7, 0.7, true) end
    GameTooltip:Show()
end

function UI:RefreshCover()
    local cv = self.cover
    if not cv or not WFD.C then return end
    local C = WFD.C
    self:RefreshCoverGrowth()
    cv.name:SetText(C.name or UnitName("player"))
    local title = WFD.Title and WFD:Title()
    cv.who:SetText(((C.race or "") .. "  -  " .. (C.class or "")):upper())
    if C.obituary then
        cv.since:SetText(date(WFD.loc.date, C.born) .. "  -  " .. date(WFD.loc.date, C.obituary.t))
        cv.of:SetText(L["In memoriam"])
    else
        cv.since:SetText(format(L["Begun on %s"], date(WFD.loc.date, C.born)))
        -- the title stands above the name where "of" stood: a long one shrinks to fit the plate
        cv.of:SetText(title or L["of"])
    end
    -- names and lines of any length and language fit their plate
    UI.FitText(cv.name, 230, 30, 16)
    UI.FitText(cv.who, 236, 10, 8, UI.FONT)
    UI.FitText(cv.of, 230, 14, 10)
    UI.FitText(cv.since, 300, 14, 10)
    local path, tc, isIcon = factionCrest()
    cv.crest:SetTexture(path)
    cv.crest:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
    -- emblems are stamped in gold; a square icon keeps a little of its colour
    cv.crest:SetDesaturated(true)
    if isIcon then
        cv.crest:SetSize(112, 112)
        cv.crest:SetVertexColor(1.0, 0.82, 0.45, 1)
    else
        cv.crest:SetSize(108, 108)
        cv.crest:SetVertexColor(1.0, 0.80, 0.38, 1)
    end
    cv.demo:SetShown(WFD.demo and true or false)
end

-- brass corner piece: a diamond cut by the corner of the cover, with two rivets
local function brassCorner(cv, point, dx, dy)
    local f = CreateFrame("Frame", nil, cv)
    f:SetSize(48, 48)
    f:SetPoint(point, cv, point, dx * 2, dy * 2)
    f:SetFrameLevel(cv:GetFrameLevel() + 6)
    if not f.SetClipsChildren then return end
    f:SetClipsChildren(true)
    local layers = {
        { 72, { 0.30, 0.21, 0.08 } }, { 68, BRASS }, { 58, { 0.52, 0.38, 0.14 } }, { 54, { 0.84, 0.66, 0.32 } },
    }
    for i, l in ipairs(layers) do
        local d = UI.Diamond(f, l[1], l[2], "ARTWORK", i)
        d:SetPoint("CENTER", f, point, 0, 0)
    end
    for _, r in ipairs({ { 13, 5 }, { 5, 13 } }) do
        local rx, ry = r[1] * -dx, r[2] * -dy
        local s = UI.Circle(f, 6, { 0.25, 0.17, 0.06, 1 }, "OVERLAY", 0)
        s:SetPoint("CENTER", f, point, rx + 4 * -dx, ry + 4 * -dy)
        local h = UI.Circle(f, 3, { 1, 0.90, 0.60, 1 }, "OVERLAY", 1)
        h:SetPoint("CENTER", s, "CENTER", -0.5, 0.5)
    end
end

-- a leather strap with a brass buckle over the right edge
local function strap(cv, y)
    local s = CreateFrame("Frame", nil, cv)
    s:SetSize(88, 46)
    s:SetPoint("RIGHT", cv, "RIGHT", 20, y)
    s:SetFrameLevel(cv:GetFrameLevel() + 7)
    local sh = UI.Fill(s, { 0, 0, 0 }, "BACKGROUND", 0, 0.45)
    sh:SetPoint("TOPLEFT", -3, -4)
    sh:SetPoint("BOTTOMRIGHT", 0, -4)
    local body = UI.GradRect(s, "VERTICAL", { 0.07, 0.035, 0.02, 1 }, { 0.28, 0.14, 0.07, 1 }, "ARTWORK", 0)
    body:SetAllPoints()
    local edge = UI.Frame(s)
    edge:SetAllPoints()
    UI.Backdrop(edge, nil, 1, 0, { 0, 0, 0, 0 }, { 0, 0, 0, 0.85 })
    for x = 6, 82, 9 do
        local a = UI.Fill(s, { 0.85, 0.66, 0.32 }, "OVERLAY", 0, 0.45); a:SetSize(5, 1); a:SetPoint("TOPLEFT", x, -5)
        local b = UI.Fill(s, { 0.85, 0.66, 0.32 }, "OVERLAY", 0, 0.45); b:SetSize(5, 1); b:SetPoint("BOTTOMLEFT", x, 5)
    end
    -- buckle: brass frame, dark opening, tongue
    local bk = UI.Frame(s, 32, 40)
    bk:SetPoint("LEFT", s, "LEFT", 6, 0)
    bk:SetFrameLevel(s:GetFrameLevel() + 2)
    UI.Backdrop(bk, "tooltip", 12, 3, { 0.10, 0.05, 0.02, 1 }, { 1, 0.84, 0.42, 1 })
    local tongue = UI.Fill(bk, { 1, 0.84, 0.42 }, "OVERLAY")
    tongue:SetSize(16, 3)
    tongue:SetPoint("CENTER", 2, 0)
    local hole = UI.Circle(s, 5, { 0, 0, 0, 0.8 }, "OVERLAY", 1)
    hole:SetPoint("LEFT", s, "LEFT", 52, 0)
end

local COVER_ART = "Interface\\AddOns\\" .. ADDON .. "\\Media\\cover"

local function buildCover(holder)
    local cv = UI.Frame(holder, CVW, CVH, "Button")
    cv:SetPoint("CENTER")
    -- the painted leather binding (Media folder, cover.tga); the drawn decoration below only stands in without it
    local art = cv:CreateTexture(nil, "BACKGROUND", nil, -8)
    art:SetAllPoints()
    local hasArt = art:SetTexture(COVER_ART) ~= false
    art:SetTexCoord(0, CVW / 512, 0, CVH / 1024)
    if not hasArt then
        art:Hide()
        UI.Backdrop(cv, "tooltip", 16, 4, c.leather, { 0.55, 0.40, 0.18, 1 })
        leather(cv, 4)
    end
    cv:RegisterForDrag("LeftButton")
    cv:SetScript("OnDragStart", function() holder:StartMoving() end)
    cv:SetScript("OnDragStop", function()
        holder:StopMovingOrSizing()
        if UI.SavePosition then UI:SavePosition() end
        cv.dragEnd = GetTime()
    end)
    UI.cover = cv
    local cx = 20   -- visual centre shifted right of the spine

    if not hasArt then
        -- worn leather: lighter scuffs near the edges, darker in the middle
        for _, s in ipairs({ { 70, -30, 90 }, { CVW - 40, -80, 70 }, { 90, -CVH + 40, 80 }, { CVW - 60, -CVH + 60, 100 },
                             { CVW - 20, -CVH / 2, 60 }, { 60, -CVH / 2 - 60, 50 } }) do
            local sc = UI.Circle(cv, s[3], { 1, 0.80, 0.55, 0.045 }, "BACKGROUND", 5)
            sc:SetPoint("CENTER", cv, "TOPLEFT", s[1], s[2])
        end

        -- spine with raised bands and gold fillets
        local spine = UI.GradRect(cv, "HORIZONTAL", { 0.04, 0.02, 0.01, 1 }, { 0.22, 0.11, 0.06, 1 }, "BORDER", 0)
        spine:SetPoint("TOPLEFT", 4, -4)
        spine:SetPoint("BOTTOMLEFT", 4, 4)
        spine:SetWidth(38)
        local hinge = UI.Fill(cv, { 0, 0, 0 }, "BORDER", 1, 0.65)
        hinge:SetPoint("TOPLEFT", 42, -4)
        hinge:SetPoint("BOTTOMLEFT", 42, 4)
        hinge:SetWidth(3)
        for i = 1, 5 do
            local by = -44 - (i - 1) * ((CVH - 100) / 4)
            local band = UI.GradRect(cv, "VERTICAL", { 0.06, 0.03, 0.01, 1 }, { 0.40, 0.22, 0.11, 1 }, "BORDER", 2)
            band:SetSize(38, 12)
            band:SetPoint("TOPLEFT", 4, by)
            for _, o in ipairs({ -3, 14 }) do
                local fil = UI.Fill(cv, c.gold, "BORDER", 3, 0.55)
                fil:SetSize(34, 1)
                fil:SetPoint("TOPLEFT", 6, by - o)
            end
        end

        -- tooled border: a dark blind-stamped groove, two gold fillets, a row of stamped diamonds between them
        local groove = UI.Frame(cv)
        groove:SetPoint("TOPLEFT", 40 + 18, -18)
        groove:SetPoint("BOTTOMRIGHT", -18, 18)
        UI.Backdrop(groove, nil, 2, 0, { 0, 0, 0, 0 }, { 0, 0, 0, 0.35 })
        for i, inset in ipairs({ 28, 44 }) do
            local fr = UI.Frame(cv)
            fr:SetPoint("TOPLEFT", 40 + inset - 6, -inset)
            fr:SetPoint("BOTTOMRIGHT", -inset, inset)
            UI.Backdrop(fr, "tooltip", 12, 3, { 0, 0, 0, 0 }, { 0.85, 0.66, 0.30, i == 1 and 0.80 or 0.50 })
        end
        local L0, T0, R0, B0 = 40 + 36 - 6 + 4, -36 - 4, CVW - 36 - 4, -CVH + 36 + 4
        for x = L0 + 8, R0 - 8, 15 do
            for _, yy in ipairs({ T0, B0 }) do
                local d = UI.Diamond(cv, 4, { 0, 0, 0, 0.45 }, "BORDER", 4)
                d:SetPoint("CENTER", cv, "TOPLEFT", x, yy)
            end
        end
        for y = T0 - 8, B0 + 8, -15 do
            for _, xx in ipairs({ L0, R0 }) do
                local d = UI.Diamond(cv, 4, { 0, 0, 0, 0.45 }, "BORDER", 4)
                d:SetPoint("CENTER", cv, "TOPLEFT", xx, y)
            end
        end
        -- gold fleurons in the inner corners
        for _, p in ipairs({ { L0 + 18, T0 - 18, 1, -1 }, { R0 - 18, T0 - 18, -1, -1 }, { L0 + 18, B0 + 18, 1, 1 }, { R0 - 18, B0 + 18, -1, 1 } }) do
            local big = UI.Diamond(cv, 10, c.gold, "ARTWORK", 2)
            big:SetPoint("CENTER", cv, "TOPLEFT", p[1], p[2])
            for _, o in ipairs({ { 12, 0 }, { 0, 12 } }) do
                local sm = UI.Diamond(cv, 5, c.goldDk, "ARTWORK", 2)
                sm:SetPoint("CENTER", cv, "TOPLEFT", p[1] + o[1] * p[3], p[2] + o[2] * p[4])
            end
        end
    end

    -- the title in a recessed cartouche
    local cart = UI.Frame(cv, 300, 58)
    cart:SetPoint("TOP", cv, "TOP", cx, -62)
    if not hasArt then UI.Backdrop(cart, "tooltip", 12, 3, { 0.06, 0.03, 0.015, 0.75 }, { 0.85, 0.66, 0.30, 0.9 }) end
    cv.title = UI.Text(cart, 30, c.gold, "CENTER", UI.HEAD, true)
    cv.title:SetPoint("CENTER", 0, -1)
    cv.title:SetText(L["Travel Diary"])
    UI.FitText(cv.title, 232, 30, 16)          -- the title field is 248 px wide; long titles shrink
    if not hasArt then
        for s = -1, 1, 2 do
            local d = UI.Diamond(cv, 9, c.gold, "ARTWORK", 3)
            d:SetPoint("CENTER", cart, s < 0 and "LEFT" or "RIGHT", 0, 0)
        end
    end

    -- a gold lozenge around the crest, as on old bindings
    local CY = -250
    if not hasArt and cv.CreateLine then
        for k, half in ipairs({ 122, 112 }) do
            local pts = { { 0, half }, { half * 0.86, 0 }, { 0, -half }, { -half * 0.86, 0 } }
            for i = 1, 4 do
                local a, b = pts[i], pts[i % 4 + 1]
                local ln = cv:CreateLine(nil, "ARTWORK", nil, 1)
                ln:SetColorTexture(0.85, 0.66, 0.30, k == 1 and 0.75 or 0.40)
                ln:SetThickness(k == 1 and 2 or 1)
                ln:SetStartPoint("TOP", cv, cx + a[1], CY + a[2])
                ln:SetEndPoint("TOP", cv, cx + b[1], CY + b[2])
            end
        end
        for _, t in ipairs({ { 0, 122 }, { 105, 0 }, { 0, -122 }, { -105, 0 } }) do
            local tip = UI.Diamond(cv, 10, c.gold, "ARTWORK", 3)
            tip:SetPoint("CENTER", cv, "TOP", cx + t[1], CY + t[2])
        end
    end

    -- crest in a gold medallion
    local medal = CreateFrame("Frame", nil, cv)
    medal:SetSize(160, 160)
    medal:SetPoint("CENTER", cv, "TOP", cx, CY)
    if not hasArt then
        local glow = UI.Circle(medal, 168, { 0, 0, 0, 0.55 }, "BACKGROUND")
        glow:SetPoint("CENTER", 3, -4)
        local ring = UI.Circle(medal, 150, c.goldDk, "ARTWORK", 0)
        ring:SetPoint("CENTER")
        local ring2 = UI.Circle(medal, 144, c.gold, "ARTWORK", 1)
        ring2:SetPoint("CENTER")
        local ring3 = UI.Circle(medal, 136, { 0.45, 0.30, 0.10, 1 }, "ARTWORK", 2)
        ring3:SetPoint("CENTER")
        local inner = UI.Circle(medal, 132, { 0.12, 0.06, 0.03, 1 }, "ARTWORK", 3)
        inner:SetPoint("CENTER")
    end
    cv.crest = medal:CreateTexture(nil, "ARTWORK", nil, 4)
    cv.crest:SetSize(108, 108)
    cv.crest:SetPoint("CENTER")
    UI.Round(cv.crest, medal)

    -- name plate
    local plate = UI.Frame(cv, 250, 92)
    plate:SetPoint("TOP", cv, "TOP", cx, -386)
    if not hasArt then UI.Backdrop(plate, "tooltip", 12, 3, { 0.06, 0.03, 0.015, 0.55 }, { 0.85, 0.66, 0.30, 0.7 }) end
    cv.of = UI.Text(plate, 14, c.goldDk, "CENTER", UI.HEAD, true)
    cv.of:SetPoint("TOP", 0, -10)
    cv.of:SetText(L["of"])
    cv.name = UI.Text(plate, 30, c.gold, "CENTER", UI.HEAD, true)
    cv.name:SetPoint("TOP", 0, -28)
    cv.who = UI.Caps(plate, "", 10, { 0.85, 0.68, 0.36, 1 })
    cv.who:SetJustifyH("CENTER")
    cv.who:SetPoint("TOP", 0, -66)

    cv.since = UI.Text(cv, 14, { 0.85, 0.70, 0.42, 1 }, "CENTER", UI.HEAD, true)
    cv.since:SetPoint("TOP", cv, "TOP", cx, -490)
    cv.hint = UI.Text(cv, 13, { 0.80, 0.64, 0.36, 1 }, "CENTER", UI.HEAD, true)
    cv.hint:SetPoint("BOTTOM", cv, "BOTTOM", cx, 60)
    cv.hint:SetText(L["Click to open"])
    cv.demo = UI.Text(cv, 12, { 1, 0.45, 0.35, 1 }, "CENTER", UI.HEAD, true)
    cv.demo:SetPoint("BOTTOM", cv.hint, "TOP", 0, 6)
    cv.demo:SetText(L["DEMO MODE: invented data"])

    -- what the binding gains over a life (see UI:RefreshCoverGrowth): metal studs in the corners,
    -- gems set into the lozenge, gold marks on the spine - and the wear of many days
    local deco = CreateFrame("Frame", nil, cv)
    deco:SetAllPoints()
    deco:SetFrameLevel(cv:GetFrameLevel() + 5)
    cv.deco = deco
    cv.studs = {}
    for i, p in ipairs({ { 100, 60 }, { 390, 60 }, { 100, CVH - 60 }, { 390, CVH - 60 } }) do
        local s = {}
        s.shadow = UI.Circle(deco, 20, { 0, 0, 0, 0.55 }, "ARTWORK", 0)
        s.shadow:SetPoint("CENTER", cv, "TOPLEFT", p[1] + 1, -p[2] - 2)
        s.body = UI.Circle(deco, 17, BRASS, "ARTWORK", 1)
        s.body:SetPoint("CENTER", cv, "TOPLEFT", p[1], -p[2])
        s.shine = UI.Circle(deco, 7, { 1, 1, 1, 0.55 }, "ARTWORK", 2)
        s.shine:SetPoint("CENTER", s.body, "CENTER", -3, 3)
        cv.studs[i] = s
    end
    cv.gems = {}
    for i, p in ipairs({ { 0, 124 }, { 106, 0 }, { 0, -124 }, { -106, 0 }, { 53, 62 }, { 53, -62 }, { -53, -62 }, { -53, 62 } }) do
        local g = {}
        g.setting = UI.Circle(deco, 15, { 0.55, 0.40, 0.14, 1 }, "ARTWORK", 3)
        g.setting:SetPoint("CENTER", cv, "TOP", cx + p[1], CY + p[2])
        g.stone = UI.Circle(deco, 11, c.red, "ARTWORK", 4)
        g.stone:SetPoint("CENTER", g.setting, "CENTER")
        g.spark = UI.Circle(deco, 4, { 1, 1, 1, 0.75 }, "ARTWORK", 5)
        g.spark:SetPoint("CENTER", g.stone, "CENTER", -2, 2)
        cv.gems[i] = g
    end
    cv.spine = {}
    for i = 1, 6 do
        local d = UI.Diamond(deco, 10, c.gold, "ARTWORK", 3)
        d:SetPoint("CENTER", cv, "TOPLEFT", 21, -110 - (i - 1) * 76)
        cv.spine[i] = d
    end
    -- wear: rubbed, lighter edges and corners, a few scratches
    cv.wear = {}
    for _, e in ipairs({ "TOP", "BOTTOM", "RIGHT", "LEFT" }) do
        cv.wear[#cv.wear + 1] = { tex = UI.EdgeFade(deco, e, 26, { 1, 0.82, 0.58 }, 0, "BACKGROUND", 0, 3), a = 0.10, edge = e }
    end
    for _, p in ipairs({ { 14, 14 }, { CVW - 14, 14 }, { 14, CVH - 14 }, { CVW - 14, CVH - 14 } }) do
        local rub = UI.Circle(deco, 64, { 1, 0.82, 0.58, 1 }, "BACKGROUND", 1)
        rub:SetPoint("CENTER", cv, "TOPLEFT", p[1], -p[2])
        cv.wear[#cv.wear + 1] = { tex = rub, a = 0.12 }
    end
    if deco.CreateLine then
        for i, s in ipairs({ { 150, 120, 205, 150 }, { 320, 420, 380, 404 }, { 280, 520, 300, 560 }, { 90, 300, 120, 340 },
                             { 360, 190, 410, 230 }, { 200, 470, 230, 455 } }) do
            local ln = deco:CreateLine(nil, "BACKGROUND", nil, 2)
            ln:SetColorTexture(1, 0.85, 0.62, 1)
            ln:SetThickness(1)
            ln:SetStartPoint("TOPLEFT", cv, s[1], -s[2])
            ln:SetEndPoint("TOPLEFT", cv, s[3], -s[4])
            cv.wear[#cv.wear + 1] = { tex = ln, a = 0.16, from = i / 7 }
        end
    end

    -- metal and straps on top of everything
    if not hasArt then
        brassCorner(cv, "TOPLEFT", -1, 1)
        brassCorner(cv, "TOPRIGHT", 1, 1)
        brassCorner(cv, "BOTTOMLEFT", -1, -1)
        brassCorner(cv, "BOTTOMRIGHT", 1, -1)
    end
    strap(cv, 150)
    strap(cv, -150)

    -- hover: the leather catches a little light
    local sheen = UI.Fill(cv, { 1, 0.85, 0.6 }, "OVERLAY", 7, 0.05)
    sheen:SetPoint("TOPLEFT", 4, -4)
    sheen:SetPoint("BOTTOMRIGHT", -4, 4)
    sheen:Hide()
    cv:SetScript("OnEnter", function(self)
        sheen:Show()
        cv.hint:SetTextColor(1, 0.9, 0.6, 1)
        UI:CoverTooltip(self)
    end)
    cv:SetScript("OnLeave", function()
        sheen:Hide()
        cv.hint:SetTextColor(0.80, 0.64, 0.36, 1)
        GameTooltip:Hide()
    end)
    cv:SetScript("OnClick", function()
        if cv.dragEnd and GetTime() - cv.dragEnd < 0.3 then return end
        UI:OpenStart()
    end)
end

------------------------------------------------------------------------
-- Holder, opening and closing
------------------------------------------------------------------------
function UI:Build()
    if self.holder then return end
    local h = CreateFrame("Frame", "WoWForeverDiaryFrame", UIParent)
    h:SetSize(BW, BH)
    h:SetPoint("CENTER")
    h:SetFrameStrata("HIGH")
    h:SetMovable(true)
    h:SetClampedToScreen(true)
    h:SetScale(WFD.S.scale or 0.9)
    tinsert(UISpecialFrames, "WoWForeverDiaryFrame")
    self.holder = h
    self.frame = h
    -- measure text at exactly the scale it is drawn at
    measureFrame:SetParent(h)
    measureFrame:ClearAllPoints()
    measureFrame:SetPoint("TOPLEFT", h, "TOPLEFT", 0, 0)
    measureFrame:SetFrameLevel(1)
    buildCover(h)

    h:Hide()
end

-- the view on the desk is written again (after a note was saved, a name was changed ...)
function UI:Reflow()
    WFD.dirty = false
    if self.storyCache then self.storyCache[WFD:NumDays()] = nil end
    local cur = self.Router and self.Router.cur
    local v = cur and self.ViewInstance and self.ViewInstance(cur.view)
    if v and v.Refresh and v.host and v.host:IsShown() then v:Refresh(true) end
end

function UI:Show()
    self:Build()
    if self.card then self.card:Hide() end
    self:RefreshCover()
    self.cover:Show()
    fadeIn(self.cover)
    self.holder:Show()
end

function UI:Hide()
    if self.holder then self.holder:Hide() end
end

function UI:DataSwitched()
    UI.ClearCaches()
    self:RefreshCover()
    if self.OnDataSwitched then self:OnDataSwitched() end
end

function UI:SetScale(s)
    s = max(0.6, min(1.4, s or 0.9))
    WFD.S.scale = s
    if self.holder then self.holder:SetScale(s) end
    UI.ClearCaches()
end

------------------------------------------------------------------------
-- Minimap button
------------------------------------------------------------------------
local mm

local function placeMinimap()
    if not mm then return end
    local a = math.rad(WFD.S.angle or 215)
    local x, y = math.cos(a), math.sin(a)
    local rw = (Minimap:GetWidth() / 2) + 5
    local rh = (Minimap:GetHeight() / 2) + 5
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" then
        -- push the button onto the edge of a square map
        local m = math.max(math.abs(x), math.abs(y))
        x, y = x / m, y / m
    end
    mm:ClearAllPoints()
    mm:SetPoint("CENTER", Minimap, "CENTER", x * rw, y * rh)
end

function UI:UpdateMinimapButton()
    if not mm then return end
    mm:SetShown(WFD.S.minimap)
end

WFD:OnInit(function()
    mm = CreateFrame("Button", "WoWForeverDiaryMinimapButton", Minimap)
    mm:SetSize(31, 31)
    mm:SetFrameStrata("MEDIUM")
    mm:SetFrameLevel(8)
    mm:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    mm:RegisterForDrag("LeftButton")
    local bg = mm:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(20, 20)
    bg:SetPoint("TOPLEFT", 7, -5)
    local icon = mm:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetSize(17, 17)
    icon:SetPoint("TOPLEFT", 7, -6)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local border = mm:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", 0, 0)
    mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    mm:SetScript("OnClick", function(_, button)
        if button == "RightButton" and UI.OpenSettings then UI:OpenSettings() else UI:Toggle() end
    end)
    mm:SetScript("OnDragStart", function(self)
        if WFD.S.minimapLocked then return end            -- the button stays where it is
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local s = Minimap:GetEffectiveScale()
            WFD.S.angle = math.deg(math.atan2(py / s - my, px / s - mx))
            placeMinimap()
        end)
    end)
    mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    mm:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("WoW Forever Diary", 1, 0.82, 0)
        local C = WFD.C
        if C then
            local d = C.days[WFD:DayIndex()]
            GameTooltip:AddLine(format(L["Day %d"], WFD:NumDays()), 1, 1, 1)
            if d then
                GameTooltip:AddLine(WFD:Count("%d kills today", d.killTotal) .. ", " .. WFD:Count("%d quests today", #d.qd), 0.8, 0.8, 0.8)
            end
        end
        GameTooltip:AddLine(L["Click to open the diary."], 0.5, 0.8, 1)
        GameTooltip:AddLine(L["Right-click for the settings."], 0.5, 0.8, 1)
        if not WFD.S.minimapLocked then GameTooltip:AddLine(L["Drag to move this button."], 0.5, 0.8, 1) end
        GameTooltip:Show()
    end)
    mm:SetScript("OnLeave", function() GameTooltip:Hide() end)
    placeMinimap()
    Minimap:HookScript("OnSizeChanged", placeMinimap)
    C_Timer.After(1, placeMinimap)      -- other addons may resize the map after login
    UI:UpdateMinimapButton()
    -- the drawer of addons beside the minimap, where the client has one
    if AddonCompartmentFrame and AddonCompartmentFrame.RegisterAddon then
        pcall(AddonCompartmentFrame.RegisterAddon, AddonCompartmentFrame, {
            text = "WoW Forever Diary", icon = "Interface\\Icons\\INV_Misc_Book_09", notCheckable = true,
            func = function(_, _, _, _, button)
                if button == "RightButton" and UI.OpenSettings then UI:OpenSettings() else UI:Toggle() end
            end,
        })
    end
end)

------------------------------------------------------------------------
-- Totals over the whole life of the character (used by several pages)
------------------------------------------------------------------------
function WFD:Totals()
    local C = self.C
    local t = { online = 0, kills = 0, quests = 0, deaths = 0, income = 0, spend = 0, steps = 0, xp = 0, jumps = 0, days = 0 }
    for _, d in pairs(C.days) do
        t.online = t.online + (d.online or 0)
        t.kills = t.kills + d.killTotal
        t.quests = t.quests + #d.qd
        t.deaths = t.deaths + d.deaths
        t.income = t.income + self:Sum(d.income)
        t.spend = t.spend + self:Sum(d.spend)
        t.steps = t.steps + (d.steps or 0)
        t.xp = t.xp + d.xp
        t.jumps = t.jumps + (d.jumps or 0)
        t.days = t.days + 1
    end
    return t
end

