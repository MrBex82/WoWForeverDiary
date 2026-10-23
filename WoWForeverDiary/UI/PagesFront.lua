-- Front matter: endpapers, "this book belongs to", table of contents, blank note pages
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local max, min, format = math.max, math.min, string.format

local PW, PH = UI.PW, UI.PH

-- dots between a label and a page number
local function leader(pool, canvas, x, y, w, label, value, size, labelCol, onClick)
    size = size or 15
    local a = pool:Text(size - 1, labelCol or c.ink, UI.FONT)
    a:SetText(label)
    a:SetWordWrap(false)
    a:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    local b = pool:Text(size - 1, c.ink, UI.FONT, "RIGHT")
    b:SetText(value or "")
    b:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x + w, y)
    if a:GetStringWidth() > w - 60 then a:SetWidth(w - 60) end
    local d = pool:Text(size - 1, c.inkFaint, UI.FONT)
    d:SetWordWrap(false)
    d:SetText(string.rep(" .", 90))
    d:SetPoint("TOPLEFT", a, "TOPRIGHT", 4, 0)
    d:SetPoint("TOPRIGHT", b, "TOPLEFT", -6, 0)
    d:SetJustifyH("LEFT")
    if onClick then
        local hot = pool:Hot(nil, onClick)
        hot:SetPoint("TOPLEFT", a, "TOPLEFT", -4, 4)
        hot:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 4, -4)
    end
    return a, b
end
UI.LeaderLine = leader

-- tabs: a function(pool, canvas, tx, tw, y) that draws a row of its own in the place of the subtitle
function UI.PageTitle(pool, canvas, side, text, sub, y, tabs)
    UI.titled = true
    local tx, tw = UI.TextX(side), UI.TextW()
    local t = pool:Text(32, c.redInk, UI.HEAD, "CENTER")
    t:SetText(text)
    UI.FitText(t, tw - 8, 32, 18)
    t:SetWidth(tw)
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y or -56)
    local ny = (y or -56) - 44
    if sub then
        local s = pool:Text(11, c.inkSoft, UI.FONT, "CENTER")
        s:SetText(UI.Upper(sub))
        s:SetWidth(tw)
        s:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, ny)
        ny = ny - 18
    elseif tabs then
        tabs(pool, canvas, tx, tw, ny)
        ny = ny - 18
    end
    UI.PageDivider(pool, canvas, tx + tw / 2, ny - 4, 240)
    return ny - 22
end

-- the four pages of the settings (general, handling, keys, appearance) lie one after the other: a row of links
-- above each of them leads to the others
function UI.SettingsTabs(current)
    return function(pool, canvas, tx, tw, y)
        local names = { L["General"], L["Handling"], L["Keys"], L["Appearance"] }
        local items, total, gap = {}, 0, 18
        for i, name in ipairs(names) do
            local on = i == current
            local fs = pool:Link(name, function()
                local first = UI.book and UI.book.sectionStart.notes
                if first then UI:GoToPage(first + i - 1) end
            end, 13, on and c.redInk or c.inkSoft)
            items[i] = { fs = fs, on = on }
        end
        -- four names in one row: in a long language (or with bigger writing) they become smaller together
        local size = 13
        while true do
            total = 0
            for _, it in ipairs(items) do
                it.fs:SetFont(UI.FONT, UI.FS(size), "")
                it.w = it.fs:GetStringWidth()
                total = total + it.w
            end
            total = total + gap * (#names - 1)
            if total <= tw or size <= 11 then break end
            size = size - 1
        end
        local x = tx + (tw - total) / 2
        for i, it in ipairs(items) do
            it.fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
            if it.on then
                local u = pool:Rect(c.redInk, 1)
                u:SetSize(it.w, 1)
                u:SetPoint("TOPLEFT", it.fs, "BOTTOMLEFT", 0, -2)
            end
            if i < #items then
                local d = pool:Diamond(4, c.inkFaint)
                d:SetPoint("CENTER", canvas, "TOPLEFT", x + it.w + gap / 2, y - 7)
            end
            x = x + it.w + gap
        end
    end
end

-- red caps heading with a diamond, an optional count on the right and a fading rule; h = row height
function UI.SectionHead(pool, canvas, tx, tw, y, h, text, count)
    local base = y - h + 18
    local dm = pool:Diamond(6, c.redInk)
    dm:SetPoint("CENTER", canvas, "TOPLEFT", tx + 3, base - 5)
    local t = pool:Text(10, c.redInk, UI.FONT)
    t:SetText(text:upper())
    t:SetWordWrap(false)
    t:SetWidth(tw - 70)
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 12, base)
    if count then
        local n = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        n:SetText(count)
        n:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, base)
    end
    local ln = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.55 }, { 0.91, 0.76, 0.42, 0.04 })
    ln:SetSize(tw, 1)
    ln:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, base - 14)
end

-- The caption of a tile: one line in capitals if it fits, else two smaller lines as written.
-- Returns the font size and whether it takes two lines.
local function tileCaption(label, tw)
    local size = UI.FS(9)
    if UI.MeasureWidth(label:upper(), size, UI.FONT) <= tw - 6 then return size, false end
    -- a long single word ("Bekanntschaften") shrinks until it fits the box, down to 9 points
    local widest = 0
    for word in label:gmatch("%S+") do widest = max(widest, UI.MeasureWidth(word, size, UI.FONT)) end
    while size > 9 and widest > tw - 6 do
        size = size - 1
        widest = widest * size / (size + 1)
    end
    return size, true
end

local function tileNeed(label, tw, h)
    local size, two = tileCaption(label, tw)
    if two then return max(h, 24 + 2 * size + 8) end
    return max(h, 28 + size + 3)
end

-- the height a row of tiles will take, for pages whose rows are laid out before they are drawn
function UI.TileHeight(w, labels, h)
    h = h or 42
    local tw = (w - (#labels - 1) * 8) / #labels
    local need = h
    for _, label in ipairs(labels) do need = max(need, tileNeed(label, tw, h)) end
    return need
end

-- a row of figures in light boxes: list = { { value, label, colour, onClick } }
-- A caption on two lines makes the whole row taller instead of running out of its box; returns the height.
function UI.Tiles(pool, canvas, x0, y, w, list, h)
    h = h or 42
    local n = #list
    local tw = (w - (n - 1) * 8) / n
    local boxes, need = {}, h
    for i, t in ipairs(list) do
        local x = x0 + (i - 1) * (tw + 8)
        local bg = pool:Rect(c.paperDk, 0.45)
        bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
        local bar = pool:Rect(t[3] or c.inkSoft, 0.9)
        bar:SetSize(tw, 2)
        bar:SetPoint("TOPLEFT", bg, "TOPLEFT")
        local v = pool:Text(17, t[3] or c.ink, UI.HEAD, "CENTER")
        v:SetText(tostring(t[1]))
        UI.FitText(v, tw - 6, 17, 11, UI.HEAD)
        v:SetWidth(tw)
        v:SetWordWrap(false)
        v:SetPoint("TOP", bg, "TOP", 0, -5)
        local l = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
        l:SetWidth(tw - 6)
        local size, two = tileCaption(t[2], tw)
        if two then
            -- capitals are wide: a caption on two lines is written as it is
            l:SetText(t[2])
            l:SetFont(UI.FONT, size, "")
            l:SetWordWrap(true)
            if l.SetMaxLines then l:SetMaxLines(2) end
            l:SetPoint("TOP", bg, "TOP", 0, -24)
        else
            l:SetText(t[2]:upper())
            l:SetWordWrap(false)
            l:SetPoint("TOP", bg, "TOP", 0, -28)
        end
        need = max(need, tileNeed(t[2], tw, h))
        boxes[#boxes + 1] = bg
        if t[4] then
            local hot = pool:Hot({ t[2], tostring(t[1]) }, t[4])
            hot:SetPoint("TOPLEFT", bg, "TOPLEFT")
            boxes[#boxes + 1] = hot
        end
    end
    for _, b in ipairs(boxes) do b:SetSize(tw, need) end
    return need
end

-- a thin progress bar: faint track, filled part as a gradient of col; returns the track
function UI.ProgressBar(pool, canvas, x, y, w, h, frac, col)
    local track = pool:Rect(c.inkFaint, 0.22)
    track:SetSize(w, h)
    track:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    frac = max(0, min(1, frac or 0))
    if frac > 0 then
        col = col or c.redInk
        local bar = pool:Grad("HORIZONTAL", { col[1] * 0.75, col[2] * 0.75, col[3] * 0.75, 1 }, { col[1], col[2], col[3], 1 })
        bar:SetSize(max(2, w * frac), h)
        bar:SetPoint("TOPLEFT", track, "TOPLEFT")
    end
    return track
end

function UI.PageDivider(pool, canvas, cx, y, width)
    local half = width / 2 - 14
    local l = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0 }, { 0.78, 0.60, 0.26, 0.85 })
    l:SetSize(half, 1)
    l:SetPoint("RIGHT", canvas, "TOPLEFT", cx - 10, y)
    local r = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0.85 }, { 0.78, 0.60, 0.26, 0 })
    r:SetSize(half, 1)
    r:SetPoint("LEFT", canvas, "TOPLEFT", cx + 10, y)
    local d = pool:Diamond(7, c.redInk)
    d:SetPoint("CENTER", canvas, "TOPLEFT", cx, y)
    local d1 = pool:Diamond(3, c.inkSoft)
    d1:SetPoint("CENTER", canvas, "TOPLEFT", cx - 8, y)
    local d2 = pool:Diamond(3, c.inkSoft)
    d2:SetPoint("CENTER", canvas, "TOPLEFT", cx + 8, y)
end

------------------------------------------------------------------------
-- Endpaper: dark paper with a gold lattice, ex-libris plate on the first one
------------------------------------------------------------------------
-- marbled endpaper (Media\marble.tga, made by tools/gen_marble.lua); one texture per page side, shown on endpapers only
local MARBLE = "Interface\\AddOns\\" .. ADDON .. "\\Media\\marble"
local marbles = {}
function UI.HideMarble(canvas) if marbles[canvas] then marbles[canvas]:Hide() end end
local function marble(canvas)
    local m = marbles[canvas]
    if m == nil then
        local t = canvas:CreateTexture(nil, "BACKGROUND", nil, 3)
        t:SetPoint("TOPLEFT", 2, -2)
        t:SetPoint("BOTTOMRIGHT", -2, 2)
        if t:SetTexture(MARBLE) == false then
            t:Hide()
            m = false
        else
            m = t
        end
        marbles[canvas] = m
    end
    return m or nil
end

UI:RegisterRenderer("endpaper", function(pool, page, side, canvas, index)
    local m = marble(canvas)
    if m then
        -- the two endpapers show different parts of the sheet
        local o = (index % 2 == 1) and 0 or 0.18
        m:SetTexCoord(o, o + 0.82, 0, 1)
        m:Show()
        -- a fine gold rule where the paper meets the board
        local I = 12
        for _, e in ipairs({ { I, -I, PW - 2 * I, 1 }, { I, -(PH - I - 1), PW - 2 * I, 1 }, { I, -I, 1, PH - 2 * I }, { PW - I - 1, -I, 1, PH - 2 * I } }) do
            local r = pool:Rect(c.redInk, 0.40, "BORDER", 1)
            r:SetSize(e[3], e[4])
            r:SetPoint("TOPLEFT", canvas, "TOPLEFT", e[1], e[2])
        end
    else
        local bg = pool:Grad("VERTICAL", { 0.16, 0.07, 0.04, 1 }, { 0.30, 0.14, 0.07, 1 }, "BACKGROUND", 4)
        bg:SetPoint("TOPLEFT", 2, -2)
        bg:SetPoint("BOTTOMRIGHT", -2, 2)
        for row = 0, 19 do
            for col = 0, 14 do
                local x = 14 + col * 28 + ((row % 2 == 1) and 14 or 0)
                local y = 14 + row * 28
                if x < PW - 8 and y < PH - 8 then
                    local d = pool:Diamond(row % 2 == 1 and 5 or 7, { 0.85, 0.66, 0.30, row % 2 == 1 and 0.18 or 0.28 }, "BORDER")
                    d:SetPoint("CENTER", canvas, "TOPLEFT", x, -y)
                end
            end
        end
    end
    local sh = pool:Grad("HORIZONTAL", side == "left" and { 0, 0, 0, 0 } or { 0, 0, 0, 0.6 }, side == "left" and { 0, 0, 0, 0.6 } or { 0, 0, 0, 0 }, "BORDER", 2)
    sh:SetSize(60, PH - 4)
    if side == "left" then sh:SetPoint("TOPRIGHT", -2, -2) else sh:SetPoint("TOPLEFT", 2, -2) end

    if index == 1 then
        local C = WFD.C
        local plate = pool:Rect(c.paper, 1, "ARTWORK", 0)
        plate:SetSize(230, 140)
        plate:SetPoint("CENTER", canvas, "CENTER", 0, 30)
        local inner = pool:Rect({ 0.40, 0.25, 0.10 }, 0.9, "ARTWORK", 1)
        inner:SetSize(214, 124)
        inner:SetPoint("CENTER", plate, "CENTER")
        local inner2 = pool:Rect(c.paper, 1, "ARTWORK", 2)
        inner2:SetSize(212, 122)
        inner2:SetPoint("CENTER", plate, "CENTER")
        local ex = pool:Text(13, c.redInk, UI.FONT, "CENTER")
        ex:SetText(L["FROM THE LIBRARY OF"])
        UI.FitText(ex, 196, 13, 9, UI.FONT)
        ex:SetPoint("TOP", plate, "TOP", 0, -24)
        local nm = pool:Text(28, c.ink, UI.HEAD, "CENTER")
        nm:SetText(C.name or "?")
        UI.FitText(nm, 196, 28, 16)
        nm:SetPoint("CENTER", plate, "CENTER", 0, -2)
        local rl = pool:Text(10, c.inkSoft, UI.FONT, "CENTER")
        rl:SetText(C.realm or "")
        rl:SetPoint("BOTTOM", plate, "BOTTOM", 0, 20)
    end
end)

------------------------------------------------------------------------
-- "This book belongs to"
------------------------------------------------------------------------
-- a saying for every day: about roads, adventure and keeping a diary (written for this book)
WFD.SAYINGS = {
    "Whoever wanders, gathers stories.",
    "Every road starts at your own door.",
    "A full pack is light when the heart is lighter.",
    "Maps show the way - only feet know it.",
    "The longest journey is the one you never write down.",
    "Ink fades slower than memory.",
    "A good campfire turns strangers into companions.",
    "The mountain does not care how tired you are - just keep going.",
    "Today's detour is tomorrow's best story.",
    "Gold comes and goes, the story stays.",
    "Count the days by friends, not by miles.",
    "Even the smallest kobold guards a candle for someone.",
    "Resting is part of the road.",
    "Fear is a map with too many blank spots.",
    "Every scar has a page in this book.",
    "Look back now and then - the view is part of the journey.",
    "The wise traveller asks the innkeeper first.",
    "Rain on the road, sunshine in the story.",
    "Whoever never falls never learns to get up.",
    "A quest half done is still a step forward.",
    "The horizon travels with you - that is why it never gets dull.",
    "Write it down, or it never happened.",
    "Old boots know more than new maps.",
    "Courage is being afraid and saddling up anyway.",
    "Tomorrow the road will still be there. Tonight the fire is warm.",
    "A traveller's purse is light, a traveller's diary is heavy.",
    "The best places are on no map.",
    "Every hero once did not know the way.",
    "Share your bread, and the road shares its secrets.",
    "The story is not over while a page is still blank.",
}

-- the same saying all day long, a different one tomorrow
function WFD:SayingOfTheDay()
    local list = self.SAYINGS
    local seed = self.C and self.C.born or 0
    return L[list[((self:DayIndex() - 1) + seed % #list) % #list + 1]]
end

UI:RegisterRenderer("owner", function(pool, page, side, canvas)
    local C = WFD.C
    local cx = UI.TextX(side) + UI.TextW() / 2
    local function center(fs, y)
        fs:SetPoint("TOP", canvas, "TOPLEFT", cx, y)
        return fs
    end
    -- one line each: in a long language or with larger writing the line gets smaller letters, it is never cut
    local function fit(fs, size, minSize, font)
        UI.FitText(fs, UI.TextW(), size, minSize, font or UI.FONT)
        fs:SetWidth(UI.TextW())
        fs:SetWordWrap(false)
    end
    local t = pool:Text(15, c.inkSoft, UI.FONT, "CENTER")
    t:SetText(L["This book belongs to"])
    center(t, -64)
    local n = pool:Text(44, c.ink, UI.HEAD, "CENTER")
    n:SetText(C.name or UnitName("player"))
    fit(n, 44, 24, UI.HEAD)
    center(n, -88)
    local lvl = UnitLevel("player")
    local w = pool:Text(10, c.redInk, UI.FONT, "CENTER")
    w:SetText(((C.race or "") .. "  -  " .. (C.class or "") .. "  -  " .. format(L["Level %d"], lvl)):upper())
    fit(w, 10, 9)
    center(w, -142)

    -- portrait in a gold medallion
    local ring = pool:Circle(132, c.goldDk)
    ring:SetPoint("CENTER", canvas, "TOPLEFT", cx, -232)
    local ring2 = pool:Circle(126, c.gold, "ARTWORK", 1)
    ring2:SetPoint("CENTER", canvas, "TOPLEFT", cx, -232)
    local inner = pool:Circle(120, c.black, "ARTWORK", 2)
    inner:SetPoint("CENTER", canvas, "TOPLEFT", cx, -232)
    local por = pool:Icon(nil, 114, "ARTWORK", 3)
    por:SetTexCoord(0, 1, 0, 1)
    if SetPortraitTexture then SetPortraitTexture(por, "player") end
    por:SetPoint("CENTER", canvas, "TOPLEFT", cx, -232)

    UI.PageDivider(pool, canvas, cx, -316, 260)

    local begun = pool:Text(14, c.ink, UI.FONT, "CENTER")
    begun:SetText(format(L["Begun on %s"], WFD:LongDate(1)))
    fit(begun, 14, 11)
    center(begun, -336)
    local where = pool:Text(14, c.ink, UI.FONT, "CENTER")
    if C.fresh then
        where:SetText(format(L["in %s, on the first day of my life"], WFD:Place(C.startZone or "?", "in")))
    else
        where:SetText(format(L["in %s, at level %d"], WFD:Place(C.startZone or "?", "in"), C.startLevel or 1))
    end
    fit(where, 14, 11)
    center(where, -358)
    local realm = pool:Text(12, c.inkSoft, UI.FONT, "CENTER")
    realm:SetText(format(L["Realm: %s"], C.realm or "?"))
    fit(realm, 12, 10)
    center(realm, -380)

    -- the saying of the day, under a small heading; a book that has just begun gets a welcome instead
    local fresh = WFD:NumDays() <= 1 and not WFD.demo
    local head = pool:Text(9, c.redInk, UI.FONT, "CENTER")
    head:SetText(fresh and L["WELCOME"] or L["SAYING OF THE DAY"])
    center(head, -404)
    for k = -1, 1, 2 do
        local d = pool:Diamond(5, c.redInk)
        d:SetPoint("CENTER", canvas, "TOPLEFT", cx + k * (head:GetStringWidth() / 2 + 10), -409)
    end
    local quotes = WFD.loc.quotes
    local Q1, Q2 = quotes and quotes[1] or "\"", quotes and quotes[2] or "\""
    local q = pool:Text(fresh and 13 or 14, c.inkSoft, UI.FONT, "CENTER")
    q:SetWidth(UI.TextW() - 40)
    if q.SetMaxLines then q:SetMaxLines(fresh and 3 or 2) end
    q:SetText(fresh and L["Just play, I'll write along. Every day you play becomes a page in this book."]
        or (Q1 .. WFD:SayingOfTheDay() .. Q2))
    center(q, -420)

    local sig = pool:Text(24, { 0.62, 0.70, 0.95, 1 }, UI.HEAD, "RIGHT")
    sig:SetText(C.name or "")
    sig:SetPoint("TOPRIGHT", canvas, "TOPLEFT", UI.TextX(side) + UI.TextW() - 10, -466)
    local line = pool:Grad("HORIZONTAL", { 0.62, 0.70, 0.95, 0 }, { 0.62, 0.70, 0.95, 0.7 })
    line:SetSize(170, 1)
    line:SetPoint("TOPRIGHT", canvas, "TOPLEFT", UI.TextX(side) + UI.TextW(), -496)

    -- two ways in: the contents, and today's entry (or, in a book that has just begun, a look at a sample book)
    local toc = UI.book and UI.book.sectionStart.toc
    if toc then
        local fs = pool:Link(L["To the contents"] .. "  >", function() UI:GoToPage(toc) end, 13, c.redInk)
        fs:SetPoint("BOTTOM", canvas, "BOTTOMLEFT", cx - 90, 24)
    end
    local other
    if fresh then
        other = pool:Link(L["See a sample book"] .. "  >", function() WFD:ToggleDemo() end, 13, c.redInk)
    else
        other = pool:Link(L["To today's entry"] .. "  >", function() UI:GoToPage(UI:TodayPage()) end, 13, c.redInk)
    end
    other:SetPoint("BOTTOM", canvas, "BOTTOMLEFT", cx + 90, 24)
end)

------------------------------------------------------------------------
-- Table of contents
------------------------------------------------------------------------
UI:RegisterRenderer("toc", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = -UI.TOP
    if page.first then
        y = UI.PageTitle(pool, canvas, side, L["Contents"], nil, -56)
    end
    for _, e in ipairs(page.entries) do
        if e.header then
            y = y - 10
            local h = pool:Text(11, c.redInk, UI.FONT, "CENTER")
            h:SetText(e.text:upper())
            h:SetWidth(tw)
            h:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            y = y - 26
        elseif e.group then
            -- a group of the appendix: a small heading with a stroke in the colour of its tabs
            local mark = pool:Rect({ e.col[1] * 1.4, e.col[2] * 1.4, e.col[3] * 1.4 }, 1)
            mark:SetSize(3, 11)
            mark:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 3)
            local h = pool:Text(10, c.inkSoft, UI.FONT)
            h:SetText(e.text:upper())
            h:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 9, y - 3)
            local rule = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0.35 }, { 0.78, 0.60, 0.26, 0 })
            rule:SetSize(max(10, tw - 16 - h:GetStringWidth()), 1)
            rule:SetPoint("LEFT", h, "RIGHT", 8, 0)
            if e.page then
                local hot = pool:Hot({ e.text, L["Click to open this part of the book."] }, function() UI:GoToPage(e.page) end)
                hot:SetPoint("TOPLEFT", h, "TOPLEFT", -12, 4)
                hot:SetPoint("BOTTOMRIGHT", h, "BOTTOMRIGHT", 6, -4)
            end
            y = y - 20
        else
            local ix = 0
            if e.icon then
                -- appendix sections carry their thumb icon
                local ic = pool:Icon(UI.Icon(e.icon), 18)
                ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
                ix = 26
            end
            -- a part with nothing in it yet is written faintly
            leader(pool, canvas, tx + ix, y, tw - ix, e.text, e.page and tostring(UI.PageNumber(e.page)) or "", 16,
                e.dim and c.inkFaint or nil, e.page and function() UI:GoToPage(e.page) end)
            if e.sub then
                local s = pool:Text(10, c.inkFaint, UI.FONT)
                s:SetText(e.sub)
                s:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 22, y - 19)
                y = y - 36
            else
                y = y - 22
            end
        end
    end
end)

------------------------------------------------------------------------
-- Blank page for notes
------------------------------------------------------------------------
-- Note pages: ruled paper you can write on. Text is kept per character.
local LINE = 26
UI:RegisterRenderer("blank", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local h = pool:Text(22, c.inkSoft, UI.HEAD, "CENTER")
    h:SetText(L["Notes"])
    h:SetWidth(tw)
    h:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, -54)
    UI.PageDivider(pool, canvas, tx + tw / 2, -84, 160)
    local top = 96
    -- ruled lines: two pixels at low alpha look the same on every line, whatever the scale
    for y = top + LINE, PH - 66, LINE do
        local ln = pool:Rect({ 0.78, 0.60, 0.26 }, 0.16)
        ln:SetSize(tw + 16, 2)
        ln:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 16, -y)
    end
    -- red margin line as in a school exercise book
    local mg = pool:Rect(c.bad, 0.40)
    mg:SetSize(1, PH - 66 - top)
    mg:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 6, -top)
    local C = WFD.C
    C.notes = C.notes or {}
    local key = page.noteKey or ("page:" .. (page.index or 0))
    local eb = pool:NoteEdit(tw, PH - top - 70, LINE, C.notes[key] or "", function(text)
        C.notes[key] = (text ~= "") and text or nil
    end, L["Click here to write your own notes ..."])
    eb:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, -(top + 7))
    local hot = pool:Hot(nil, function() eb:SetFocus() end)
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, -top)
    hot:SetSize(tw, PH - top - 66)
    hot.hl:SetAlpha(0)
    eb:SetFrameLevel(hot:GetFrameLevel() + 1)
end)
