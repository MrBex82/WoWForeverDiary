-- Drawing helpers of the cards (Cards.lua) and the toasts: a line with dots and a value, a heading, figures in
-- tiles, a bar, a divider.
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
    UI.titleText = text
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
        -- a long sub line takes a second line, and the ornament moves down below it
        ny = ny - max(18, (s:GetStringHeight() or 0) + 6)
    elseif tabs then
        tabs(pool, canvas, tx, tw, ny)
        ny = ny - 18
    end
    UI.PageDivider(pool, canvas, tx + tw / 2, ny - 4, 240)
    return ny - 22
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

-- The caption of a tile: one line in capitals if it fits (a point smaller if need be), else two smaller lines
-- as written. Returns the font size and whether it takes two lines.
local function tileCaption(label, tw)
    local size = UI.FS(9)
    if UI.MeasureWidth(label:upper(), size, UI.FONT) <= tw - 6 then return size, false end
    if UI.MeasureWidth(label:upper(), UI.FS(8), UI.FONT) <= tw - 6 then return UI.FS(8), false end
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
    -- one row writes all its captions alike: when one needs two lines, none is in capitals
    local anyTwo, rowSize = false, nil
    for _, t in ipairs(list) do
        local sz, two = tileCaption(t[2], tw)
        anyTwo = anyTwo or two
        rowSize = min(rowSize or sz, sz)       -- one size for the whole row, the smallest that any caption needs
    end
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
        local size = rowSize
        if anyTwo then
            -- capitals are wide: a caption on two lines is written as it is
            l:SetText(t[2])
            l:SetFont(UI.FONT, size, "")
            l:SetWordWrap(true)
            if l.SetMaxLines then l:SetMaxLines(2) end
            l:SetPoint("TOP", bg, "TOP", 0, -24)
        else
            l:SetText(t[2]:upper())
            l:SetFont(UI.FONT, size, "")
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
