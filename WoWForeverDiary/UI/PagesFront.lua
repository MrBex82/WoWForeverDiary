-- Drawing helpers of the cards (Cards.lua) and the toasts: a line with dots and a value,
-- a bar, a divider.
local ADDON, WFD = ...
local UI = WFD.UI
local c = UI.c
local max, min = math.max, math.min

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
