-- The parts the travel desk is built from: text, surfaces, buttons, switches, choices, bars, a scrolling area and
-- dialogs. Every part paints itself from the tokens (Tokens.lua) and repaints when the style changes.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local floor, max, min, pi = math.floor, math.max, math.min, math.pi
local BT = BackdropTemplateMixin and "BackdropTemplate" or nil
local WHITE = UI.WHITE
local Tok = UI.Tok
local Skin = UI.Skin

local K = {}
UI.Kit = K

------------------------------------------------------------------------
-- Text and plain colour
------------------------------------------------------------------------
local function paintText(fs)
    local font, size = UI.TypeFont(fs.role)
    if fs:SetFont(font, size, "") == false then fs:SetFont(UI.FONT, size, "") end
    local r, g, b, a = Tok(fs.colorKey)
    fs:SetTextColor(r, g, b, a)
    -- light writing gets a soft shadow so it stands off the background; dark writing stays crisp
    if 0.30 * r + 0.59 * g + 0.11 * b > 0.45 then
        fs:SetShadowColor(0, 0, 0, 0.6)
        fs:SetShadowOffset(1, -1)
    else
        fs:SetShadowOffset(0, 0)
    end
    if fs.onPaint then fs.onPaint(fs) end
end

-- role: display, title, heading, section, value, strong, body, small (UI.TYPE); key: a colour token
function K.Text(parent, role, key, justify)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs.role, fs.colorKey = role or "body", key or "ink"
    fs:SetJustifyH(justify or "LEFT")
    Skin.Add(fs, paintText)
    return fs
end

-- a text changes its colour or its role (and keeps it through the next change of style)
function K.Recolor(fs, key, role)
    fs.colorKey = key or fs.colorKey
    fs.role = role or fs.role
    paintText(fs)
end

function K.Fill(parent, key, layer, sub, mul)
    local t = parent:CreateTexture(nil, layer or "ARTWORK", nil, sub or 0)
    t:SetTexture(WHITE)
    t.colorKey, t.mul = key, mul
    Skin.Add(t, function(tx) tx:SetVertexColor(Tok(tx.colorKey, tx.mul)) end)
    return t
end

function K.Repaint(obj)
    local paint = Skin.list[obj]
    if paint then paint(obj) end
end

-- a thin rule
function K.Rule(parent, key)
    local t = K.Fill(parent, key or "line", "ARTWORK", 1)
    t:SetHeight(1)
    return t
end

------------------------------------------------------------------------
-- Surfaces
------------------------------------------------------------------------
local function paintBox(f)
    if not f.SetBackdrop then return end
    if not f.hasBackdrop then
        f:SetBackdrop({ bgFile = WHITE, edgeFile = WHITE, edgeSize = 1, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        f.hasBackdrop = true
    end
    if f.bgKey then f:SetBackdropColor(Tok(f.bgKey, f.bgMul)) else f:SetBackdropColor(0, 0, 0, 0) end
    if f.borderKey then f:SetBackdropBorderColor(Tok(f.borderKey)) else f:SetBackdropBorderColor(0, 0, 0, 0) end
end

-- a flat surface with a fine edge: bg and border are tokens (nil = none)
function K.Box(parent, bg, border, kind)
    local f = CreateFrame(kind or "Frame", nil, parent, BT)
    f.bgKey, f.borderKey = bg, border
    function f:SetSurface(b, e, mul)
        self.bgKey, self.borderKey, self.bgMul = b, e, mul
        paintBox(self)
    end
    Skin.Add(f, paintBox)
    return f
end

-- a card on the desk: its own surface with a soft sheen, a fine gold edge and gold corner pieces
function K.Card(parent)
    local c = K.Box(parent, nil, "line")
    K.Material(c, "card")
    K.Corners(c, 5, 6)
    return c
end

------------------------------------------------------------------------
-- Small drawn signs: arrows, a cross, a tick, plus and minus (made of rotated bars, in every style)
------------------------------------------------------------------------
local R45 = pi / 4
local SHAPES = {
    -- { centre x, centre y, length, angle } in units of the size
    close = { { 0, 0, 0.78, R45 }, { 0, 0, 0.78, -R45 } },
    left = { { 0, 0.16, 0.46, R45 }, { 0, -0.16, 0.46, -R45 } },
    right = { { 0, 0.16, 0.46, -R45 }, { 0, -0.16, 0.46, R45 } },
    down = { { -0.16, 0, 0.46, -R45 }, { 0.16, 0, 0.46, R45 } },
    up = { { -0.16, 0, 0.46, R45 }, { 0.16, 0, 0.46, -R45 } },
    check = { { -0.22, -0.08, 0.36, -R45 }, { 0.12, 0.02, 0.62, R45 } },
    plus = { { 0, 0, 0.7, 0 }, { 0, 0, 0.7, pi / 2 } },
    minus = { { 0, 0, 0.7, 0 } },
    menu = { { 0, 0.24, 0.7, 0 }, { 0, 0, 0.7, 0 }, { 0, -0.24, 0.7, 0 } },
    -- a ribbon of a bookmark: two sides, the top, and the notch at its foot
    mark = { { -0.2, 0.06, 0.72, pi / 2 }, { 0.2, 0.06, 0.72, pi / 2 }, { 0, 0.42, 0.42, 0 },
        { -0.1, -0.36, 0.3, R45 }, { 0.1, -0.36, 0.3, -R45 } },
}

function K.Glyph(parent, shape, size, key)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(size, size)
    f.colorKey = key or "soft"
    f.bars = {}
    function f:SetShape(name)
        for _, b in ipairs(self.bars) do b:Hide() end
        for i, s in ipairs(SHAPES[name] or SHAPES.close) do
            local b = self.bars[i]
            if not b then
                b = self:CreateTexture(nil, "OVERLAY")
                b:SetTexture(WHITE)
                self.bars[i] = b
            end
            b:SetSize(max(2, s[3] * size), 2)
            b:ClearAllPoints()
            b:SetPoint("CENTER", self, "CENTER", s[1] * size, s[2] * size)
            if b.SetRotation then b:SetRotation(s[4]) end
            b:SetVertexColor(Tok(self.colorKey))
            b:Show()
        end
    end
    function f:SetColorKey(k)
        self.colorKey = k
        for _, b in ipairs(self.bars) do b:SetVertexColor(Tok(k)) end
    end
    f:SetShape(shape)
    Skin.Add(f, function(g) g:SetColorKey(g.colorKey) end)
    return f
end

------------------------------------------------------------------------
-- Tooltips: always the game's own, with a title and lines
------------------------------------------------------------------------
function K.ShowTip(owner, title, lines, anchor)
    GameTooltip:SetOwner(owner, anchor or "ANCHOR_BOTTOM")
    GameTooltip:SetText(title or "", 1, 0.86, 0.5)
    for _, l in ipairs(lines or {}) do
        if type(l) == "table" then
            GameTooltip:AddLine(l[1], l[2] or 0.9, l[3] or 0.9, l[4] or 0.9, true)
        else
            GameTooltip:AddLine(l, 0.9, 0.9, 0.9, true)
        end
    end
    GameTooltip:Show()
end

-- When one of the texts of a row is cut short (it ends in "..."), the whole row is shown as a tooltip: the first
-- text as its title, the others below. Returns true when a tooltip was shown.
function K.ShowFull(owner, anchor, ...)
    local texts, cut = {}, false
    for i = 1, select("#", ...) do
        local fs = select(i, ...)
        if fs and fs:IsShown() then
            local t = fs:GetText()
            if t and t ~= "" then
                texts[#texts + 1] = t
                if fs:IsTruncated() then cut = true end
            end
        end
    end
    if not cut then return false end
    K.ShowTip(owner, texts[1], { unpack(texts, 2) }, anchor)
    return true
end

-- the same for one frame: while the mouse is on it, its texts in full when one is cut short
function K.FullTip(frame, anchor, ...)
    local list = { ... }
    frame:HookScript("OnEnter", function(self) K.ShowFull(self, anchor, unpack(list)) end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

-- frame shows a tooltip while the mouse is on it (title and lines may be functions)
function K.Tip(frame, title, lines, anchor)
    frame:HookScript("OnEnter", function(self)
        local t = type(title) == "function" and title() or title
        if not t then return end
        K.ShowTip(self, t, type(lines) == "function" and lines() or lines, anchor)
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

------------------------------------------------------------------------
-- Buttons
------------------------------------------------------------------------
-- style: primary (the main action), secondary, ghost (looks like a link), danger (destroys something)
-- (primary and danger are gilded: their surface is drawn below, hover and press only change its light)
local BUTTON = {
    primary = { text = "onGold" },
    secondary = { bg = "inset", border = "line", text = "ink", hoverBg = "hover", hoverBorder = "gold", downBg = "inset", downBorder = "gold" },
    ghost = { text = "gold", hoverBg = "hover", hoverText = "title", downBg = "inset" },
    danger = { text = "white" },
    -- tabs of a register in the styles of the book: only the word, the chosen one darker and underlined
    tab = { text = "rubric", hoverText = "title" },
    tabOn = { text = "title" },
    -- a quiet button in the styles of the book: a link in ink, underlined under the mouse
    link = { text = "rubric", hoverText = "title", downBg = nil },
}

-- a pressed button: what it carries moves down by a pixel while the mouse button is held
local function nudge(region, on)
    if not region or (region.nudged and true or false) == on then return end
    region.nudged = on or nil
    local pts = {}
    for i = 1, region:GetNumPoints() do pts[i] = { region:GetPoint(i) } end
    region:ClearAllPoints()
    for _, p in ipairs(pts) do region:SetPoint(p[1], p[2], p[3], p[4] or 0, (p[5] or 0) + (on and -1 or 1)) end
end

-- the mouse button goes down and up on a button of the kit (paint repaints it)
local function pressable(b, paint, ...)
    local carried = { ... }
    local function set(self, on)
        on = on and self:IsEnabled() and true or nil
        if self.pressed == on then return end
        self.pressed = on
        for _, key in ipairs(carried) do nudge(self[key], on and true or false) end
        paint(self)
    end
    b:HookScript("OnMouseDown", function(self, button) if button == "LeftButton" then set(self, true) end end)
    b:HookScript("OnMouseUp", function(self) set(self, false) end)
    b:HookScript("OnHide", function(self) set(self, false) end)
    b:HookScript("OnDisable", function(self) set(self, false) end)
end

-- a button that cannot be used: sunk into the desk, a fine edge, muted writing (not only paler)
local function paintOff(b)
    b.bgKey, b.borderKey = "inset", "line"          -- a whole button, sunk and muted (an empty frame looked cut off)
    paintBox(b)
    if b.gild then b.gild:Hide() b.edge:Hide() end
    if b.sheen then b.sheen:Hide() end
    b.label.colorKey = "muted"
    paintText(b.label)
    if b.glyph then b.glyph:SetColorKey("muted") end
    b:SetAlpha(0.8)
end

local function paintButton(b)
    -- in the styles of the book a quiet button is a link in ink (K.IsBook is defined further down)
    local style = b.style
    if style == "ghost" and K.IsBook and K.IsBook() then style = "link" end
    local st = BUTTON[style] or BUTTON.secondary
    local on = b:IsEnabled()
    local hot = b.hover and on
    local down = b.pressed and on
    if not on then
        paintOff(b)
    else
        b.bgKey = down and (st.downBg or st.bg) or hot and (st.hoverBg or st.bg) or st.bg
        b.borderKey = down and (st.downBorder or st.border) or hot and (st.hoverBorder or st.border) or st.border
        paintBox(b)
    end
    -- the main action is gilded: a gold that darkens towards the foot, a darker rim, a light edge at the top
    if not on then
        -- painted above
    elseif b.style == "primary" or b.style == "danger" then
        if not b.gild then
            b.gild = b:CreateTexture(nil, "BACKGROUND", nil, 1)
            b.gild:SetTexture(WHITE)
            b.gild:SetPoint("TOPLEFT", 1, -1)
            b.gild:SetPoint("BOTTOMRIGHT", -1, 1)
            b.edge = b:CreateTexture(nil, "ARTWORK", nil, 1)
            b.edge:SetTexture(WHITE)
            b.edge:SetHeight(1)
            b.edge:SetPoint("TOPLEFT", 1, -1)
            b.edge:SetPoint("TOPRIGHT", -1, -1)
        end
        local r, g, bl = Tok(b.style == "danger" and "danger" or "gold")
        -- lighter under the mouse; pressed, the light comes from below (the gilding turned over) and darker
        local k = down and 0.86 or (hot and 1.12 or 1)
        local dark = { r * 0.62 * k, g * 0.58 * k, bl * 0.55 * k, 1 }
        local light = { min(1, r * 0.98 * k), min(1, g * 0.92 * k), min(1, bl * 0.90 * k), 1 }
        if down then UI.Gradient(b.gild, "VERTICAL", light, dark) else UI.Gradient(b.gild, "VERTICAL", dark, light) end
        -- the light edge is the colour of the button itself, half way to white (pressed: no light edge)
        b.edge:SetVertexColor(r + (1 - r) * 0.5, g + (1 - g) * 0.5, bl + (1 - bl) * 0.5, down and 0 or 0.35)
        b:SetBackdropBorderColor(r * 0.5, g * 0.5, bl * 0.5, 1)
        b:SetBackdropColor(0, 0, 0, 0)          -- the flat colour would lie over the gilding
        b.gild:Show()
        b.edge:Show()
    elseif b.gild then
        b.gild:Hide()
        b.edge:Hide()
    end
    if on then
        b.label.colorKey = hot and (st.hoverText or st.text) or st.text
        paintText(b.label)
        if b.glyph then b.glyph:SetColorKey(b.label.colorKey) end
        b:SetAlpha(1)
        local tab = b.style == "tab" or b.style == "tabOn" or style == "link"
        if b.sheen then b.sheen:SetShown(not tab and not down and (b.style ~= "ghost" or hot)) end
        -- the line under a tab: under the chosen one always, under another while the mouse is on it
        if tab and not b.under then
            b.under = b:CreateTexture(nil, "ARTWORK", nil, 2)
            b.under:SetTexture(WHITE)
            b.under:SetHeight(1)
        end
        if b.under then
            b.under:ClearAllPoints()
            b.under:SetPoint("TOPLEFT", b.label, "BOTTOMLEFT", 0, -3)
            b.under:SetPoint("TOPRIGHT", b.label, "BOTTOMRIGHT", 0, -3)
            local r, g, bl = Tok(b.style == "tabOn" and "title" or "rubric")
            b.under:SetVertexColor(r, g, bl, 0.9)
            b.under:SetShown(tab and (b.style == "tabOn" or hot) or false)
        end
    end
    -- the width follows the label (it changes with the size of the writing and the language)
    if not b.fixedW then
        local extra = b.glyph and 18 or 0
        local pad = (b.style == "tab" or b.style == "tabOn" or style == "link") and 14 or 28
        b:SetWidth(floor(b.label:GetStringWidth() + pad + extra + 0.5))
    end
    local _, size = UI.TypeFont("strong")
    b:SetHeight(max(b.minH or 30, size + 16))
end

function K.Button(parent, text, style, onClick, width)
    local b = CreateFrame("Button", nil, parent, BT)
    b.style = style or "secondary"
    b.fixedW = width
    if width then b:SetWidth(width) end
    b.sheen = b:CreateTexture(nil, "ARTWORK", nil, -1)
    b.sheen:SetTexture(WHITE)
    b.sheen:SetPoint("TOPLEFT", 1, -1)
    b.sheen:SetPoint("BOTTOMRIGHT", -1, 1)
    UI.Gradient(b.sheen, "VERTICAL", { 0, 0, 0, 0.14 }, { 1, 1, 1, 0.09 })
    b.label = b:CreateFontString(nil, "OVERLAY")
    b.label.role, b.label.colorKey = "strong", "ink"
    paintText(b.label)          -- a font first: the game refuses text on a string without one
    b.label:SetPoint("CENTER", 0, 0)
    b.label:SetText(text or "")
    b:SetScript("OnEnter", function(self) self.hover = true paintButton(self) end)
    b:SetScript("OnLeave", function(self) self.hover = nil paintButton(self) end)
    b:SetScript("OnEnable", paintButton)
    b:SetScript("OnDisable", paintButton)
    b:SetScript("OnClick", function(self, ...) if self.onClick then self.onClick(self, ...) end end)
    b.onClick = onClick
    function b:SetLabel(t)
        self.label:SetText(t or "")
        paintButton(self)
    end
    pressable(b, paintButton, "label", "glyph")
    -- a small arrow behind the label (a choice that opens a list)
    function b:AddArrow(shape)
        self.glyph = K.Glyph(self, shape or "down", 12, "soft")
        self.glyph:SetPoint("RIGHT", -10, 0)
        self.label:ClearAllPoints()
        self.label:SetPoint("LEFT", 12, 0)
        self.label:SetPoint("RIGHT", -26, 0)
        self.label:SetJustifyH("LEFT")
        paintButton(self)
    end
    Skin.Add(b, paintButton)
    return b
end

-- a square button with a drawn sign (glyph = a shape of K.Glyph), an icon ("icon:<path>") or a letter ("text:?")
function K.IconButton(parent, glyph, tip, onClick, size)
    size = size or 30
    local b = CreateFrame("Button", nil, parent, BT)
    b:SetSize(size, size)
    b.bgKey, b.borderKey = "inset", "line"
    if glyph:find("^icon:") then
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetSize(size - 10, size - 10)
        b.icon:SetPoint("CENTER")
        b.icon:SetTexture(glyph:sub(6))
        b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    elseif glyph:find("^text:") then
        b.letter = K.Text(b, "heading", "soft", "CENTER")
        b.letter:SetPoint("CENTER", 0, 0)
        b.letter:SetText(glyph:sub(6))
    else
        b.glyph = K.Glyph(b, glyph, size * 0.5, "soft")
        b.glyph:SetPoint("CENTER")
    end
    local function paint(self)
        local on = self:IsEnabled()
        local hot = self.hover and on
        local down = self.pressed and on
        local lit = self.active or hot or down
        -- pressed: sunk into the desk with a gold edge; not usable: no surface, a muted sign
        self.bgKey = down and "inset" or (lit and "hover" or (self.flat and nil or (on and "inset" or nil)))
        self.borderKey = lit and "gold" or ((self.flat or not on) and nil or "line")
        paintBox(self)
        local k = not on and "muted" or (lit and "title" or "soft")
        if self.glyph then self.glyph:SetColorKey(k) end
        if self.letter then K.Recolor(self.letter, k) end
        if self.icon then self.icon:SetDesaturated(not on) end
        self:SetAlpha(on and 1 or 0.55)
    end
    b.Paint = paint
    function b:SetActive(on) self.active = on paint(self) end
    function b:SetFlat(on) self.flat = on paint(self) end
    b:SetScript("OnEnter", function(self) self.hover = true paint(self) end)
    b:SetScript("OnLeave", function(self) self.hover = nil paint(self) end)
    b:SetScript("OnEnable", paint)
    b:SetScript("OnDisable", paint)
    b:SetScript("OnClick", function(self, ...) if onClick then onClick(self, ...) end end)
    pressable(b, paint, "glyph", "icon", "letter")
    if tip then K.Tip(b, tip[1], { unpack(tip, 2) }) end
    Skin.Add(b, paint)
    return b
end

------------------------------------------------------------------------
-- Switches and choices
------------------------------------------------------------------------
-- a switch with its label: get() and set(v) read and write the setting; hint is a line below
function K.Toggle(parent, label, get, set, hint)
    local row = CreateFrame("Button", nil, parent)
    row.track = K.Box(row, "inset", "line")
    row.track:SetSize(36, 20)
    row.track:SetPoint("TOPLEFT", 0, -2)
    row.track:EnableMouse(false)
    row.knob = K.Fill(row.track, "muted", "OVERLAY", 0)
    row.knob:SetSize(14, 14)
    row.label = K.Text(row, "body", "ink")
    row.label:SetPoint("TOPLEFT", row.track, "TOPRIGHT", 12, -2)
    row.label:SetText(label)
    if hint then
        row.hint = K.Text(row, "small", "muted")
        row.hint:SetPoint("TOPLEFT", row.label, "BOTTOMLEFT", 0, -3)
        row.hint:SetText(hint)
    end
    function row:Refresh()
        local on = get() and true or false
        self.track:SetSurface(on and "gold" or "inset", on and "gold" or "line")
        self.knob.colorKey = on and "onGold" or "muted"
        K.Repaint(self.knob)
        self.knob:ClearAllPoints()
        self.knob:SetPoint("LEFT", self.track, "LEFT", on and 19 or 3, 0)
    end
    -- the height of the row at width w (the texts get their width first, so long ones wrap before measuring)
    function row:Measure(w)
        w = w or self:GetWidth() or 300
        self:SetWidth(w)
        self.label:SetWidth(max(40, w - 48))
        if self.hint then self.hint:SetWidth(max(40, w - 48)) end
        local h = max(24, self.label:GetStringHeight() + 6)
        if self.hint then h = h + self.hint:GetStringHeight() + 3 end
        self:SetHeight(h)
        return h
    end
    row:SetScript("OnClick", function(self)
        set(not get())
        self:Refresh()
    end)
    row:SetScript("OnEnter", function(self) self.track:SetSurface(self.track.bgKey, "title") end)
    row:SetScript("OnLeave", function(self) self:Refresh() end)
    Skin.Add(row, function(r) r:Refresh() end)
    return row
end

-- buttons side by side, one of them chosen: items = { { value, label }, ... }
function K.Segmented(parent, items, get, set)
    local f = CreateFrame("Frame", nil, parent)
    f.buttons = {}
    -- the buttons side by side; where they would run over maxW (big writing, a narrow page) they go on in a
    -- second row
    function f:Refresh()
        local cur = get()
        local x, y, widest = 0, 0, 0
        local bh = self.buttons[1] and self.buttons[1]:GetHeight() or 30
        for _, b in ipairs(self.buttons) do
            b.style = (b.value == cur) and "primary" or "secondary"
            paintButton(b)
            local bw = b:GetWidth()
            if self.maxW and x > 0 and x + bw > self.maxW then x, y = 0, y + bh + 6 end
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
            x = x + bw - 1
            widest = max(widest, x + 1)
        end
        self:SetSize(max(1, widest), y + bh)
    end
    function f:Measure(w)
        self.maxW = w
        self:Refresh()
        return self:GetHeight()
    end
    for i, it in ipairs(items) do
        local b = K.Button(f, it[2], "secondary", function()
            set(it[1])
            f:Refresh()
        end)
        b.value = it[1]
        f.buttons[i] = b
    end
    Skin.Add(f, function(s) s:Refresh() end)
    return f
end

-- minus, the value, plus
function K.Stepper(parent, get, set, lo, hi, step, fmt)
    local f = CreateFrame("Frame", nil, parent)
    f.minus = K.IconButton(f, "minus", nil, function() set(max(lo, get() - step)) f:Refresh() end)
    f.minus:SetPoint("LEFT", 0, 0)
    f.value = K.Text(f, "strong", "ink", "CENTER")
    f.value:SetPoint("LEFT", f.minus, "RIGHT", 4, 0)
    f.value:SetWidth(64)
    f.plus = K.IconButton(f, "plus", nil, function() set(min(hi, get() + step)) f:Refresh() end)
    f.plus:SetPoint("LEFT", f.value, "RIGHT", 4, 0)
    f:SetSize(30 + 4 + 64 + 4 + 30, 30)
    function f:Refresh()
        local v = get()
        self.value:SetText(fmt and fmt(v) or tostring(v))
        self.minus:SetEnabled(v > lo + 1e-6)
        self.plus:SetEnabled(v < hi - 1e-6)
    end
    f:Refresh()
    return f
end

------------------------------------------------------------------------
-- A choice from a list: a button that opens a small menu
------------------------------------------------------------------------
-- A frame that lies over everything (a list, the results of the search) closes when a mouse button goes down
-- anywhere else: not on the frame and not on what it belongs to (keep(): further frames that count as its own).
-- The click itself goes on to what lies there. Watched only while the frame is shown.
function K.CloseOnClickAway(frame, keep)
    local watch = CreateFrame("Frame", nil, frame)
    local wasDown = true          -- the click that opened the frame is still held
    watch:SetScript("OnShow", function() wasDown = true end)
    watch:SetScript("OnUpdate", function()
        local down = IsMouseButtonDown and (IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton"))
        if down and not wasDown then
            local inside = frame:IsMouseOver()
            for _, f in ipairs(keep and keep() or {}) do
                if f and f.IsShown and f:IsShown() and f:IsMouseOver() then inside = true end
            end
            if not inside then frame:Hide() end
        end
        wasDown = down
    end)
    return frame
end

-- Escape closes what lies on top first. The game closes the frames named in UISpecialFrames all at once when
-- Escape reaches it (the mouse is not on the window, so the window does not take the key): while a layer (a list,
-- a question, the results of the search) is open, only the layer is named there, and the window again after it.
local HOLDER = "WoWForeverDiaryFrame"
local layers = {}
local function setSpecial(name, on)
    for i = #UISpecialFrames, 1, -1 do
        if UISpecialFrames[i] == name then table.remove(UISpecialFrames, i) end
    end
    if on then tinsert(UISpecialFrames, name) end
end
local function syncLayers()
    local any = false
    for f, name in pairs(layers) do
        setSpecial(name, f:IsShown())
        any = any or f:IsShown()
    end
    if _G[HOLDER] then setSpecial(HOLDER, not any) end
end
function K.EscapeLayer(frame, gname)
    _G[gname] = frame
    layers[frame] = gname
    -- a frame later: the game may be going through the list right now
    frame:HookScript("OnShow", function() C_Timer.After(0, syncLayers) end)
    frame:HookScript("OnHide", function() C_Timer.After(0, syncLayers) end)
    return frame
end

local menu
local function closeMenu()
    if menu and menu:IsShown() then menu:Hide() return true end
    return false
end
K.CloseMenu = closeMenu

local MENU_MAX = 320          -- the list is at most this high (before the size of the writing), then it scrolls

-- the rows of the list from menu.first on, as many as fit
local function placeMenuRows()
    local m = menu
    local n, rows = #m.items, m.visible
    m.first = max(1, min(m.first or 1, n - rows + 1))
    for i = 1, max(rows, #m.rows) do
        local r = m.rows[i]
        local it = m.items[m.first + i - 1]
        if i <= rows and it then
            r.value, r.chosen = it[1], it[1] == m.cur
            r.text:SetText(it[2])
            K.Recolor(r.text, r.chosen and "title" or "ink")
            r:SetSurface(r.chosen and "inset" or (r:IsMouseOver() and "hover" or nil))
            r:Show()
        elseif r then
            r:Hide()
        end
    end
    -- a thin bar on the right shows where in the list you are
    local more = n > rows
    m.thumb:SetShown(more)
    if more then
        local h = rows * m.rowH
        local th = max(16, h * rows / n)
        m.thumb:SetHeight(th)
        m.thumb:ClearAllPoints()
        m.thumb:SetPoint("TOPRIGHT", m, "TOPRIGHT", -2, -4 - (h - th) * (m.first - 1) / (n - rows))
    end
end

local function openMenu(owner, items, cur, onPick, side)
    if not menu then
        menu = K.Box(UIParent, "panel", "gold")
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:SetClampedToScreen(true)
        menu:EnableMouse(true)
        menu:EnableMouseWheel(true)
        menu:SetScript("OnMouseWheel", function(self, delta)
            self.first = (self.first or 1) - delta * 3
            placeMenuRows()
        end)
        menu.thumb = K.Fill(menu, "gold", "OVERLAY", 2, 0.8)
        menu.thumb:SetWidth(3)
        menu.rows = {}
        K.CloseOnClickAway(menu, function() return { menu.owner } end)
        K.EscapeLayer(menu, "WoWForeverDiaryMenu")
        menu:Hide()
    end
    if menu:IsShown() and menu.owner == owner then menu:Hide() return end
    menu.owner, menu.items, menu.cur, menu.onPick = owner, items, cur, onPick
    menu:SetScale(owner:GetEffectiveScale() / UIParent:GetEffectiveScale())
    local w = max(owner:GetWidth(), side == "right" and floor(210 * max(1, UI.FONT_SCALE or 1)) or 160)
    -- a row is as high as the writing needs; the list as high as it may be, then it scrolls
    local _, size = UI.TypeFont("body")
    local rowH = max(26, floor(size + 13))
    local maxH = floor(MENU_MAX * max(1, UI.FONT_SCALE or 1))
    local visible = max(1, min(#items, floor((maxH - 8) / rowH)))
    menu.rowH, menu.visible = rowH, visible
    for i = 1, visible do
        local r = menu.rows[i]
        if not r then
            r = K.Box(menu, nil, nil, "Button")
            r.text = K.Text(r, "body", "ink")
            r.text:SetPoint("LEFT", 10, 0)
            r.text:SetPoint("RIGHT", -10, 0)
            r.text:SetWordWrap(false)
            r:SetScript("OnEnter", function(self)
                self:SetSurface("hover")
                if self.text:IsTruncated() then K.ShowTip(self, self.text:GetText(), nil, "ANCHOR_RIGHT") end
            end)
            r:SetScript("OnLeave", function(self) self:SetSurface(self.chosen and "inset" or nil) GameTooltip:Hide() end)
            r:SetScript("OnClick", function(self)
                menu:Hide()
                if menu.onPick then menu.onPick(self.value) end
            end)
            menu.rows[i] = r
        end
        r:SetHeight(rowH)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -4 - (i - 1) * rowH)
        r:SetWidth(w - (#items > visible and 14 or 8))
    end
    -- the chosen entry is in sight when the list opens
    menu.first = 1
    for i, it in ipairs(items) do if it[1] == cur then menu.first = i - floor(visible / 2) end end
    placeMenuRows()
    menu:SetSize(w, visible * rowH + 8)
    menu:ClearAllPoints()
    if side == "right" then menu:SetPoint("TOPLEFT", owner, "TOPRIGHT", 4, 0) else menu:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2) end
    menu:Show()
end

-- a small menu of choices beside a frame: items = { { value, label } }, onPick(value); side = "right" opens it to
-- the right of the frame (else below)
K.Menu = openMenu

function K.Dropdown(parent, items, get, set, width)
    local b = K.Button(parent, "", "secondary", nil, width or 220)
    b:AddArrow("down")
    -- one line, as wide as the writing needs it (it grows with the size of the writing)
    b.label:SetWordWrap(false)
    b.baseW = width or 220
    Skin.Add(b, function(s)
        s.fixedW = floor(s.baseW * max(1, UI.FONT_SCALE or 1) + 0.5)
        s:SetWidth(s.fixedW)
    end)
    function b:Refresh()
        local cur = get()
        for _, it in ipairs(items) do if it[1] == cur then self:SetLabel(it[2]) end end
    end
    b.onClick = function(self)
        openMenu(self, items, get(), function(v)
            set(v)
            self:Refresh()
        end)
    end
    b:HookScript("OnHide", function() if menu and menu.owner == b then menu:Hide() end end)
    b.menuFrame = function() return menu end          -- for the load test
    b:Refresh()
    return b
end

------------------------------------------------------------------------
-- A progress bar: the fill is a token or a colour of its own
------------------------------------------------------------------------
function K.Bar(parent, h, key)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(h or 6)
    f.track = K.Fill(f, "inset", "ARTWORK", 0)
    f.track:SetAllPoints()
    f.fill = f:CreateTexture(nil, "ARTWORK", nil, 1)
    f.fill:SetTexture(WHITE)
    f.fill:SetPoint("TOPLEFT")
    f.fill:SetPoint("BOTTOMLEFT")
    f.key, f.frac = key or "gold", 0
    local function paint(s)
        if s.rgb then s.fill:SetVertexColor(s.rgb[1], s.rgb[2], s.rgb[3], 1)
        else s.fill:SetVertexColor(Tok(s.key)) end
        local w = s:GetWidth() or 0
        s.fill:SetWidth(max(0.01, w * s.frac))
        s.fill:SetShown(s.frac > 0)
    end
    function f:SetValue(frac)
        self.frac = max(0, min(1, frac or 0))
        paint(self)
    end
    -- key: a token, or rgb: a colour of its own ({ r, g, b })
    function f:SetFill(key, rgb)
        self.key, self.rgb = key or self.key, rgb
        paint(self)
    end
    f:SetScript("OnSizeChanged", paint)
    Skin.Add(f, paint)
    return f
end

------------------------------------------------------------------------
-- A heading inside a card: small capitals in the accent colour, a figure on the right
------------------------------------------------------------------------
function K.SectionHead(parent, text, right)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(18)
    -- as in the book: a small diamond, the words in capitals, a gold line running out towards the figure
    f.dia = UI.Diamond(f, 6, { 1, 1, 1, 1 }, "ARTWORK", 1)
    f.dia:SetPoint("LEFT", 2, 0)
    f.text = K.Text(f, "section", "rubric")
    f.text:SetPoint("LEFT", 12, 0)
    f.right = K.Text(f, "small", "soft", "RIGHT")
    f.right:SetPoint("RIGHT", 0, 0)
    f.rule = f:CreateTexture(nil, "ARTWORK")
    f.rule:SetTexture(UI.WHITE)
    f.rule:SetHeight(1)
    local function paint(s)
        local r, g, b = UI.Tok("rubric")
        s.dia:SetVertexColor(r, g, b, 1)
        UI.Gradient(s.rule, "HORIZONTAL", { r, g, b, 0.55 }, { r, g, b, 0 })
    end
    function f:Set(t, r)
        self.text:SetText(UI.Upper(t or ""))
        self.right:SetText(r or "")
        self.rule:ClearAllPoints()
        self.rule:SetPoint("LEFT", self.text, "RIGHT", 8, 0)
        if (r or "") ~= "" then
            self.rule:SetPoint("RIGHT", self.right, "LEFT", -8, 0)
        else
            self.rule:SetPoint("RIGHT", self, "RIGHT", 0, 0)
        end
    end
    UI.Skin.Add(f, paint)
    f:Set(text, right)
    return f
end

------------------------------------------------------------------------
-- A scrolling area: content is the frame to fill, SetContentHeight tells how tall it is
------------------------------------------------------------------------
local scrolls = setmetatable({}, { __mode = "k" })

-- the scrolling area the keys move: the innermost one under the mouse, else the biggest one in sight inside host
function K.MainScroll(host)
    local best, area, under, underArea
    for sf in pairs(scrolls) do
        if sf:IsVisible() and (sf.contentH or 0) > (sf:GetHeight() or 0) + 1 then
            local p = sf
            while p and p ~= host do p = p:GetParent() end
            if p then
                local a = (sf:GetWidth() or 0) * (sf:GetHeight() or 0)
                if sf:IsMouseOver() and (not underArea or a < underArea) then under, underArea = sf, a end
                if not area or a > area then best, area = sf, a end
            end
        end
    end
    return under or best
end

function K.Scroll(parent)
    local sf = CreateFrame("ScrollFrame", nil, parent)
    scrolls[sf] = true
    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(10, 10)
    sf:SetScrollChild(content)
    sf.content = content
    sf.bar = K.Fill(sf, "line", "OVERLAY", 0)
    sf.bar:SetWidth(3)
    sf.thumb = CreateFrame("Frame", nil, sf)
    sf.thumb:SetWidth(6)
    sf.thumb.tex = K.Fill(sf.thumb, "gold", "OVERLAY", 1, 0.8)
    sf.thumb.tex:SetAllPoints()
    sf.thumb:EnableMouse(true)
    sf.contentH = 0

    local function range() return max(0, sf.contentH - (sf:GetHeight() or 0)) end
    local function place()
        local h = sf:GetHeight() or 0
        local r = range()
        local show = r > 1
        -- more below: the foot of the area fades into its surface, so the page does not end hard
        if sf.fade then sf.fade:SetShown(show and sf:GetVerticalScroll() < r - 2) end
        sf.bar:SetShown(show)
        sf.thumb:SetShown(show)
        if not show then return end
        sf.bar:ClearAllPoints()
        sf.bar:SetPoint("TOPRIGHT", sf, "TOPRIGHT", -2, -2)
        sf.bar:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", -2, 2)
        local th = max(24, h * h / sf.contentH)
        local y = (h - th) * (sf:GetVerticalScroll() / r)
        sf.thumb:SetHeight(th)
        sf.thumb:ClearAllPoints()
        sf.thumb:SetPoint("TOPRIGHT", sf, "TOPRIGHT", -0.5, -y)
    end
    function sf:ScrollTo(y)
        self:SetVerticalScroll(max(0, min(range(), y)))
        place()
        if self.onScroll then self.onScroll(self) end
    end
    -- key: the token of the surface below the area (its foot fades into it while there is more to scroll)
    function sf:SetFade(key)
        if not self.fade then
            local holder = CreateFrame("Frame", nil, self)
            holder:SetAllPoints(self)
            holder:SetFrameLevel(content:GetFrameLevel() + 20)
            self.fade = holder:CreateTexture(nil, "OVERLAY")
            self.fade:SetTexture(WHITE)
            self.fade:SetPoint("BOTTOMLEFT", 0, 0)
            self.fade:SetPoint("BOTTOMRIGHT", -8, 0)
            self.fade:SetHeight(36)
            Skin.Add(self.fade, function(t)
                local r, g, b = Tok(t.colorKey)
                UI.Gradient(t, "VERTICAL", { r, g, b, 1 }, { r, g, b, 0 })
            end)
        end
        self.fade.colorKey = key or "card"
        K.Repaint(self.fade)
        place()
    end
    function sf:SetContentHeight(h)
        self.contentH = h
        content:SetHeight(max(1, h))
        if self.UpdateScrollChildRect then self:UpdateScrollChildRect() end
        self:ScrollTo(self:GetVerticalScroll())
    end
    sf:EnableMouseWheel(true)
    sf:SetScript("OnMouseWheel", function(self, delta)
        if IsControlKeyDown() and UI.StepScale then UI:StepScale(delta) return end
        self:ScrollTo(self:GetVerticalScroll() - delta * 48)
    end)
    sf:SetScript("OnSizeChanged", function(self, w)
        content:SetWidth(max(1, w or self:GetWidth() or 1))
        self:ScrollTo(self:GetVerticalScroll())
        if self.onResize then self.onResize(self) end
    end)
    -- dragging the thumb
    sf.thumb:SetScript("OnMouseDown", function(self)
        local _, cy = GetCursorPosition()
        self.startY, self.startScroll = cy / self:GetEffectiveScale(), sf:GetVerticalScroll()
        self:SetScript("OnUpdate", function(t)
            local _, y = GetCursorPosition()
            local h = sf:GetHeight() or 1
            local per = range() / max(1, h - t:GetHeight())
            sf:ScrollTo(t.startScroll + (t.startY - y / t:GetEffectiveScale()) * per)
        end)
    end)
    sf.thumb:SetScript("OnMouseUp", function(self) self:SetScript("OnUpdate", nil) end)
    return sf
end

------------------------------------------------------------------------
-- Dialogs: a question to confirm, or a value to type. One at a time, over the whole window.
------------------------------------------------------------------------
local dlg
local function buildDialog()
    local d = CreateFrame("Frame", nil, UIParent)
    d:SetFrameStrata("FULLSCREEN_DIALOG")
    d:EnableMouse(true)        -- the window below waits until the question is answered
    d.shade = K.Fill(d, "shade", "BACKGROUND", 0)
    d.shade:SetAllPoints()
    d.box = K.Box(d, "panel", "gold")
    d.box:SetWidth(380)
    d.box:SetPoint("CENTER")
    d.title = K.Text(d.box, "heading", "title")
    d.title:SetPoint("TOPLEFT", 18, -16)
    d.text = K.Text(d.box, "body", "ink")
    d.text:SetPoint("TOPLEFT", d.title, "BOTTOMLEFT", 0, -10)
    d.text:SetSpacing(2)
    d.input = K.Box(d.box, "inset", "line", "EditBox")
    d.input:SetHeight(30)
    d.input:SetAutoFocus(false)
    d.input:SetTextInsets(8, 8, 0, 0)
    d.input:SetFontObject(ChatFontNormal)
    Skin.Add(d.input, function(e)
        local font, size = UI.TypeFont("body")
        e:SetFont(font, size, "")
        e:SetTextColor(Tok("ink"))
    end)
    -- a longer text: several lines, Enter makes a new line
    -- (a field of several lines grows with its text in the game: it lies in a frame of fixed height that scrolls)
    d.area = K.Box(d.box, "inset", "line")
    d.area:EnableMouse(true)
    d.areaScroll = CreateFrame("ScrollFrame", nil, d.area)
    d.areaScroll:SetPoint("TOPLEFT", 8, -8)
    d.areaScroll:SetPoint("BOTTOMRIGHT", -8, 8)
    d.multi = CreateFrame("EditBox", nil, d.areaScroll)
    d.areaScroll:SetScrollChild(d.multi)
    d.multi:SetMultiLine(true)
    d.multi:SetAutoFocus(false)
    d.multi:SetFontObject(ChatFontNormal)
    d.area:SetScript("OnMouseDown", function() d.multi:SetFocus() end)
    d.areaScroll:EnableMouseWheel(true)
    d.areaScroll:SetScript("OnMouseWheel", function(sf, delta)
        local range = max(0, (d.multi:GetHeight() or 0) - (sf:GetHeight() or 0))
        sf:SetVerticalScroll(max(0, min(range, sf:GetVerticalScroll() - delta * 20)))
    end)
    -- the line being written stays in sight
    d.multi:SetScript("OnCursorChanged", function(_, _, y, _, ch)
        local sf = d.areaScroll
        local top, h = -y, sf:GetHeight() or 0
        local cur = sf:GetVerticalScroll()
        if top < cur then sf:SetVerticalScroll(top)
        elseif top + ch > cur + h then sf:SetVerticalScroll(top + ch - h) end
    end)
    Skin.Add(d.multi, function(e)
        local font, size = UI.TypeFont("body")
        e:SetFont(font, size, "")
        e:SetTextColor(Tok("ink"))
    end)
    d.multi:SetScript("OnEscapePressed", function() d:Hide() end)
    d.ok = K.Button(d.box, "", "primary")
    d.cancel = K.Button(d.box, L["Cancel"], "secondary", function() d:Hide() end)
    d.input:SetScript("OnEnterPressed", function() d.ok:Click() end)
    d.input:SetScript("OnEscapePressed", function() d:Hide() end)
    d:SetScript("OnHide", function(self) self.input:ClearFocus() self.multi:ClearFocus() end)
    K.EscapeLayer(d, "WoWForeverDiaryDialog")
    d:Hide()
    return d
end

-- Some game clients refuse ReloadUI() from an addon. A secure button of the game that runs "/reload" like a macro
-- is always allowed: it lies over the OK button of a dialog that reloads, and onOk runs just before it.
local function secureReload(d)
    if d.reloadBtn ~= nil then return d.reloadBtn end
    local ok, b = pcall(CreateFrame, "Button", nil, d.box, "SecureActionButtonTemplate")
    if not (ok and b) then d.reloadBtn = false return false end
    b:SetAttribute("type", "macro")
    b:SetAttribute("macrotext", "/reload")
    b:RegisterForClicks("AnyUp", "AnyDown")
    b:SetAllPoints(d.ok)
    b:SetFrameLevel(d.ok:GetFrameLevel() + 5)
    b:SetScript("PreClick", function()
        local fn = d.preReload
        d.preReload = nil
        if fn then fn() end
    end)
    b:HookScript("OnEnter", function() d.ok.hover = true K.Repaint(d.ok) end)
    b:HookScript("OnLeave", function() d.ok.hover = nil K.Repaint(d.ok) end)
    d.reloadBtn = b
    return b
end

-- opt = { title, text, ok, danger, onOk, input = { value, numeric, max, lines }, cancel, reload }
-- (input.lines: a text of several lines, that many lines high)
-- reload = true: OK reloads the interface (after onOk)
local function openDialog(opt)
    dlg = dlg or buildDialog()
    local d = dlg
    local owner = UI.holder and UI.holder:IsShown() and UI.holder or UIParent
    d:ClearAllPoints()
    d:SetAllPoints(owner)
    d:SetScale(owner == UIParent and 1 or owner:GetScale())
    d.title:SetText(opt.title or "")
    d.text:SetText(opt.text or "")
    d.text:SetShown(opt.text ~= nil and opt.text ~= "")
    d.ok.style = opt.danger and "danger" or "primary"
    d.ok:SetLabel(opt.ok or OKAY or "OK")
    d.cancel:SetLabel(opt.cancel or L["Cancel"])
    local multi = opt.input and opt.input.lines
    d.ok.onClick = function()
        local v = opt.input and (multi and d.multi or d.input):GetText()
        d:Hide()
        if opt.onOk then opt.onOk(v) end
    end
    local bw = multi and 460 or 380
    d.title:SetWidth(bw - 36)
    local y = 16 + d.title:GetStringHeight() + 10
    if d.text:IsShown() then
        d.text:SetWidth(bw - 36)
        y = y + d.text:GetStringHeight() + 14
    end
    d.input:ClearAllPoints()
    d.area:ClearAllPoints()
    d.area:Hide()
    if multi then
        local _, size = UI.TypeFont("body")
        local h = floor(multi * (size + 4) + 16)
        d.area:SetPoint("TOPLEFT", d.box, "TOPLEFT", 18, -y)
        d.area:SetPoint("RIGHT", d.box, "RIGHT", -18, 0)
        d.area:SetHeight(h)
        d.multi:SetWidth(460 - 36 - 16)
        d.multi:SetMaxLetters(opt.input.max or 2000)
        d.multi:SetText(opt.input.value or "")
        d.areaScroll:SetVerticalScroll(0)
        d.area:Show()
        d.input:Hide()
        y = y + h + 14
    elseif opt.input then
        d.input:SetPoint("TOPLEFT", d.box, "TOPLEFT", 18, -y)
        d.input:SetPoint("RIGHT", d.box, "RIGHT", -18, 0)
        d.input:SetNumeric(opt.input.numeric and true or false)
        d.input:SetMaxLetters(opt.input.max or 60)
        d.input:SetText(opt.input.value or "")
        d.input:Show()
        y = y + 30 + 14
    else
        d.input:Hide()
    end
    d.ok:ClearAllPoints()
    d.ok:SetPoint("TOPRIGHT", d.box, "TOPRIGHT", -18, -y)
    d.cancel:ClearAllPoints()
    d.cancel:SetPoint("RIGHT", d.ok, "LEFT", -8, 0)
    d.box:SetHeight(y + d.ok:GetHeight() + 18)
    local fighting = InCombatLockdown and InCombatLockdown()
    local rb = not fighting and secureReload(d)
    if rb then
        if opt.reload then
            d.preReload = opt.onOk
            rb:Show()
        else
            rb:Hide()
        end
    end
    if opt.reload and not rb then
        -- no secure button (in a fight, or an old client): the player reloads by hand
        local onOk = opt.onOk
        d.ok.onClick = function()
            d:Hide()
            if onOk then onOk() end
            print("|cffffd100WoW Forever Diary:|r " .. L["Type /reload to finish."])
        end
    end
    d.box:SetWidth(multi and 460 or 380)
    d:Show()
    if multi then
        d.multi:SetFocus()
    elseif opt.input then
        d.input:SetFocus()
        d.input:HighlightText()
    end
end

-- a question with two answers; onOk runs on the first
function UI:Confirm(opt) openDialog(opt) end

-- the interface has to be reloaded to finish something: the player is asked, and the button reloads
function UI:AskReload(text)
    openDialog({ title = L["Reload the interface"], text = text, ok = L["Reload now"], reload = true })
end
-- a value to type; onOk(text) runs with what was typed
function UI:Ask(opt)
    opt.input = opt.input or {}
    openDialog(opt)
end
function K.CloseDialog()
    if dlg and dlg:IsShown() then dlg:Hide() return true end
    return false
end

------------------------------------------------------------------------
-- Materials: the leather of the binding, the dark leaf of the pages, gold leaf. Drawn once per style (the classic
-- styles use the book's own textures, Modern and Strong contrast stay flat) and swapped when the style changes.
------------------------------------------------------------------------
local CLASSIC = { codex = true, parchment = true }
local function tokenAt(key)
    local t = UI.T[key]
    return { t[1], t[2], t[3], t[4] or 1 }
end

local function leather(f, dark)
    local art = UI.TiledArt(f, UI.BINDING_ART, "BACKGROUND", 1)
    if not art then
        local g = UI.GradRect(f, "VERTICAL", { 0.08, 0.04, 0.02, 1 }, { 0.24, 0.13, 0.07, 1 }, "BACKGROUND", 1)
        g:SetAllPoints()
    end
    -- light from above, the lower part in shadow
    local shade = UI.GradRect(f, "VERTICAL", { 0, 0, 0, dark and 0.55 or 0.40 }, { 0, 0, 0, dark and 0.25 or 0 }, "BACKGROUND", 2)
    shade:SetAllPoints()
    UI.EdgeFade(f, "TOP", 30, { 1, 0.80, 0.55 }, 0.06, "BACKGROUND", 3)
end

local function leaf(f)
    if UI.THEME == "parchment" then
        local base = UI.Fill(f, tokenAt("shell"), "BACKGROUND", 1)
        base:SetAllPoints()
        UI.Grain(f, { 0.55, 0.40, 0.20 }, 0.10, "BACKGROUND", 2)
        for _, e in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do UI.EdgeFade(f, e, 60, { 0.40, 0.25, 0.08 }, 0.22, "BACKGROUND", 3) end
        return
    end
    local art = UI.TiledArt(f, UI.PAGE_ART, "BACKGROUND", 1)
    if not art then
        local base = UI.Fill(f, tokenAt("shell"), "BACKGROUND", 1)
        base:SetAllPoints()
    end
    local glow = UI.GradRect(f, "VERTICAL", { 0.03, 0.02, 0.01, 0.55 }, { 0.20, 0.13, 0.07, 0.35 }, "BACKGROUND", 2)
    glow:SetAllPoints()
    for _, e in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do UI.EdgeFade(f, e, 70, { 0, 0, 0 }, 0.45, "BACKGROUND", 3) end
end

-- kind: "leather" (the frame), "dark" (head bar and register), "leaf" (the desk), "card"
function K.Material(f, kind)
    UI.Themed(f, function(fr)
        local classic = CLASSIC[UI.THEME or "codex"]
        if kind == "card" then
            -- a soft shadow below and to the right: the card lies on the desk
            for i, off in ipairs({ { 2, 3, 0.22 }, { 4, 6, 0.10 } }) do
                local sh = UI.Fill(fr, { 0, 0, 0 }, "BACKGROUND", -2 + i, off[3])
                sh:SetPoint("TOPLEFT", fr, "TOPLEFT", off[1], -off[2])
                sh:SetPoint("BOTTOMRIGHT", fr, "BOTTOMRIGHT", off[1], -off[2])
            end
            local base = UI.Fill(fr, tokenAt("card"), "BACKGROUND", 1)
            base:SetAllPoints()
            local sheen = UI.GradRect(fr, "VERTICAL", { 0, 0, 0, classic and 0.18 or 0.06 }, { 1, 0.92, 0.75, classic and 0.06 or 0.03 }, "BACKGROUND", 2)
            sheen:SetAllPoints()
            return
        end
        if not classic then
            local key = (kind == "leaf") and "shell" or (kind == "dark" and "panel" or "frame")
            local base = UI.Fill(fr, tokenAt(key), "BACKGROUND", 1)
            base:SetAllPoints()
            local g = UI.GradRect(fr, "VERTICAL", { 0, 0, 0, 0.10 }, { 1, 1, 1, 0.025 }, "BACKGROUND", 2)
            g:SetAllPoints()
            return
        end
        if kind == "leaf" then leaf(fr) else leather(fr, kind == "dark") end
    end)
    return f
end

-- a line of gold leaf that fades out at both ends, with a small diamond in the middle (diamond = false: without)
function K.GoldRule(parent, diamond)
    local f = CreateFrame("Frame", nil, parent)
    f:SetHeight(9)
    f.l = K.Fill(f, "gold", "ARTWORK", 0)
    f.r = K.Fill(f, "gold", "ARTWORK", 0)
    f.l:SetHeight(1)
    f.r:SetHeight(1)
    f.l:SetPoint("LEFT", f, "LEFT", 0, 0)
    f.l:SetPoint("RIGHT", f, "CENTER", diamond == false and 0 or -6, 0)
    f.r:SetPoint("LEFT", f, "CENTER", diamond == false and 0 or 6, 0)
    f.r:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    local function fade(s)
        local r, g, b = UI.Tok("gold")
        UI.Gradient(s.l, "HORIZONTAL", { r, g, b, 0 }, { r, g, b, 0.75 })
        UI.Gradient(s.r, "HORIZONTAL", { r, g, b, 0.75 }, { r, g, b, 0 })
        if s.d then s.d:SetVertexColor(r, g, b, 1) end
    end
    if diamond ~= false then
        f.d = UI.Diamond(f, 6, { 1, 1, 1, 1 }, "ARTWORK", 1)
        f.d:SetPoint("CENTER")
    end
    UI.Skin.Add(f, fade)
    return f
end

-- small gold diamonds in the four corners of a frame (the old book's corner pieces)
function K.Corners(f, size, inset)
    size, inset = size or 6, inset or 5
    f.corners = {}
    for _, pt in ipairs({ { "TOPLEFT", 1, -1 }, { "TOPRIGHT", -1, -1 }, { "BOTTOMLEFT", 1, 1 }, { "BOTTOMRIGHT", -1, 1 } }) do
        local d = UI.Diamond(f, size, { 1, 1, 1, 1 }, "OVERLAY", 3)
        d:SetPoint("CENTER", f, pt[1], pt[2] * inset, pt[3] * inset)
        f.corners[#f.corners + 1] = d
    end
    UI.Skin.Add(f, function(s)
        local classic = CLASSIC[UI.THEME or "codex"]
        for _, d in ipairs(s.corners) do
            d:SetVertexColor(UI.Tok("gold", 0.85))
            d:SetShown(classic)
        end
    end)
    return f
end

------------------------------------------------------------------------
-- A floating window beside the game, in the style of the travel desk: the panel of the style with a gold edge,
-- a title that can be dragged, a close button. Its place is kept (WFD.S.floatPos[name]); Escape closes it.
-- f.body is the frame to fill (below the title).
------------------------------------------------------------------------
function K.Floating(name, w, h, title)
    local gname = "WoWForeverDiary" .. name
    local f = K.Box(UIParent, "panel", "gold")
    _G[gname] = f
    tinsert(UISpecialFrames, gname)
    f:SetSize(w, h)
    f:SetFrameStrata("DIALOG")
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    K.Material(f, "dark")
    K.Corners(f)
    -- a soft shadow below and to the right
    local sh = UI.Fill(f, { 0, 0, 0 }, "BACKGROUND", -8, 0.35)
    sh:SetPoint("TOPLEFT", 4, -6)
    sh:SetPoint("BOTTOMRIGHT", 4, -6)
    f.title = K.Text(f, "heading", "railTitle")
    f.title:SetPoint("TOPLEFT", 16, -14)
    f.title:SetPoint("RIGHT", f, "RIGHT", -46, 0)
    f.title:SetWordWrap(false)
    f.title:SetText(title or "")
    f.close = K.IconButton(f, "close", nil, function() f:Hide() end, 26)
    f.close:SetFlat(true)
    f.close:SetPoint("TOPRIGHT", -10, -9)
    f.rule = K.GoldRule(f, false)
    f.rule:SetPoint("TOPLEFT", 12, -42)
    f.rule:SetPoint("TOPRIGHT", -12, -42)
    f.body = CreateFrame("Frame", nil, f)
    f.body:SetPoint("TOPLEFT", 16, -54)
    f.body:SetPoint("BOTTOMRIGHT", -16, 14)
    -- dragged by its title
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop", function(s)
        s:StopMovingOrSizing()
        local p, _, rp, x, y = s:GetPoint(1)
        if WFD.S and p then
            WFD.S.floatPos = WFD.S.floatPos or {}
            WFD.S.floatPos[name] = { p, rp, x, y }
        end
    end)
    function f:Place(dx, dy)
        local p = WFD.S and WFD.S.floatPos and WFD.S.floatPos[name]
        self:ClearAllPoints()
        if p then self:SetPoint(p[1], UIParent, p[2], p[3], p[4])
        else self:SetPoint("CENTER", UIParent, "CENTER", dx or 0, dy or 0) end
    end
    f:Place()
    f:Hide()
    return f
end

------------------------------------------------------------------------
-- An empty place: a sign, what belongs here, how it fills, and where useful a button to start
-- (f:Set(icon, title, hint, label, onClick); f:Measure(w) lays it out and gives its height)
------------------------------------------------------------------------
function K.Empty(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.ring = UI.Circle(f, 52, { 1, 1, 1, 1 }, "ARTWORK", 0)
    f.ring:SetPoint("TOP", 0, 0)
    f.icon = f:CreateTexture(nil, "ARTWORK", nil, 2)
    f.icon:SetSize(40, 40)
    f.icon:SetPoint("CENTER", f.ring, "CENTER")
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    UI.Round(f.icon, f)
    f.title = K.Text(f, "heading", "title", "CENTER")
    f.hint = K.Text(f, "body", "soft", "CENTER")
    f.hint:SetSpacing(3)
    f.button = K.Button(f, "", "primary")
    UI.Skin.Add(f, function(s) s.ring:SetVertexColor(UI.Tok("gold", 0.55)) end)
    function f:Set(icon, title, hint, label, onClick)
        self.icon:SetTexture(icon or UI.Icon("journal"))
        self.title:SetText(title or "")
        self.title:SetShown(title ~= nil and title ~= "")
        self.hint:SetText(hint or "")
        self.button:SetShown(label ~= nil and onClick ~= nil)
        if label then self.button:SetLabel(label) self.button.onClick = function() onClick() end end
    end
    function f:Measure(w)
        w = max(120, min(w, 480))
        self:SetWidth(w)
        local y = 52 + 12
        if self.title:IsShown() then
            self.title:SetWidth(w)
            self.title:ClearAllPoints()
            self.title:SetPoint("TOP", self, "TOP", 0, -y)
            y = y + self.title:GetStringHeight() + 8
        end
        self.hint:SetWidth(w)
        self.hint:ClearAllPoints()
        self.hint:SetPoint("TOP", self, "TOP", 0, -y)
        y = y + self.hint:GetStringHeight() + 14
        if self.button:IsShown() then
            self.button:ClearAllPoints()
            self.button:SetPoint("TOP", self, "TOP", 0, -y)
            y = y + self.button:GetHeight()
        end
        self:SetHeight(y)
        return y
    end
    return f
end

-- an edit field in the style of the desk (one line)
function K.Edit(parent, w)
    local e = K.Box(parent, "inset", "line", "EditBox")
    e:SetSize(w or 200, 30)
    e:SetAutoFocus(false)
    e:SetTextInsets(8, 8, 0, 0)
    e:SetFontObject(ChatFontNormal)
    Skin.Add(e, function(s)
        local font, size = UI.TypeFont("body")
        s:SetFont(font, size, "")
        s:SetTextColor(Tok("ink"))
    end)
    e:SetScript("OnEditFocusGained", function(s) s:SetSurface("inset", "gold") end)
    e:SetScript("OnEditFocusLost", function(s) s:SetSurface("inset", "line") end)
    return e
end

-- The fold between two pages of the open book: a dark line where the leaves meet, the paper bending into it on
-- both sides (shadow towards the middle) and a little light on the curve. Place(x) puts it x points from the left of
-- its parent, over the whole height; in the flat styles it is a quiet line with a soft shadow.
function K.Gutter(parent)
    local g = CreateFrame("Frame", nil, parent)
    g:SetWidth(72)
    g:EnableMouse(false)
    UI.Themed(g, function(fr)
        local classic = CLASSIC[UI.THEME or "codex"]
        local a = classic and 1 or 0.45
        local l = UI.GradRect(fr, "HORIZONTAL", { 0, 0, 0, 0 }, { 0, 0, 0, 0.42 * a }, "OVERLAY", 1)
        l:SetPoint("TOPLEFT")
        l:SetPoint("BOTTOMRIGHT", fr, "BOTTOM", 0, 0)
        local r = UI.GradRect(fr, "HORIZONTAL", { 0, 0, 0, 0.30 * a }, { 0, 0, 0, 0 }, "OVERLAY", 1)
        r:SetPoint("TOPLEFT", fr, "TOP", 0, 0)
        r:SetPoint("BOTTOMRIGHT")
        local line = UI.Fill(fr, { 0.06, 0.035, 0.015 }, "OVERLAY", 3, classic and 0.75 or 0.35)
        line:SetWidth(2)
        line:SetPoint("TOP")
        line:SetPoint("BOTTOM")
        if classic then
            -- the light on the curve of the right leaf, a little away from the fold
            local hi = UI.GradRect(fr, "HORIZONTAL", { 1, 0.92, 0.75, 0 }, { 1, 0.92, 0.75, 0.07 }, "OVERLAY", 2)
            hi:SetPoint("TOPLEFT", fr, "TOP", 6, 0)
            hi:SetPoint("BOTTOMRIGHT", fr, "BOTTOM", 18, 0)
        end
    end)
    function g:Place(x)
        self:ClearAllPoints()
        self:SetPoint("TOP", parent, "TOPLEFT", x, 0)
        self:SetPoint("BOTTOM", parent, "BOTTOMLEFT", x, 0)
        self:Show()
    end
    g:Hide()
    return g
end

-- The open book: one sheet of paper (the surface of a card, so fades and writing match), the leaves under it at the
-- foot and the outer edges, a shadow on the desk, and the fold where the two pages meet. b.left and b.right are the
-- two pages; b:Lay(split) puts the fold split points from the left (nil: one page, b.right is the whole sheet).
function K.Spread(parent)
    local b = K.Box(parent, nil, "line")
    K.Material(b, "card")
    K.Corners(b, 5, 6)
    -- (a frame of its own: one frame keeps one drawing per style, and b already has the one of its surface)
    local under = CreateFrame("Frame", nil, parent)
    under:SetAllPoints(b)
    under:SetFrameLevel(max(0, b:GetFrameLevel() - 1))
    b.under = under
    UI.Themed(under, function(fr)
        local classic = CLASSIC[UI.THEME or "codex"]
        local c = tokenAt("card")
        -- the leaves below the top one: a little darker each, peeping out at the foot and at both sides
        for i = 3, 1, -1 do
            local k = 1 - i * (classic and 0.10 or 0.06)
            local leafTex = UI.Fill(fr, { c[1] * k, c[2] * k, c[3] * k }, "BACKGROUND", -8 + (3 - i), 1)
            leafTex:SetPoint("TOPLEFT", fr, "TOPLEFT", -i, -i * 2)
            leafTex:SetPoint("BOTTOMRIGHT", fr, "BOTTOMRIGHT", i, -i * 2)
        end
        local sh = UI.Fill(fr, { 0, 0, 0 }, "BACKGROUND", -8, classic and 0.35 or 0.22)
        sh:SetPoint("TOPLEFT", fr, "TOPLEFT", 2, -8)
        sh:SetPoint("BOTTOMRIGHT", fr, "BOTTOMRIGHT", 6, -10)
    end)
    b.left = CreateFrame("Frame", nil, b)
    b.right = CreateFrame("Frame", nil, b)
    b.fold = K.Gutter(b)
    -- the running heads at the top of the pages (the group on the left, the part on the right; one page: both)
    b.heads = {}
    for i = 1, 2 do
        local t = K.Text(b, "section", "rubric", "CENTER")
        t:SetWordWrap(false)
        b.heads[i] = t
    end
    -- the running head of the group leads to its overview (b.headRoute, set by the shell)
    b.headBtn = CreateFrame("Button", nil, b)
    b.headBtn:SetFrameLevel(b:GetFrameLevel() + 32)
    b.headBtn:SetScript("OnClick", function() if b.headRoute then UI.Router.Go(b.headRoute) end end)
    b.headBtn:SetScript("OnEnter", function() if b.headRoute then K.Recolor(b.heads[1], "title") end end)
    b.headBtn:SetScript("OnLeave", function() K.Recolor(b.heads[1], "rubric") end)
    function b:SetHeads(l, r, route)
        self.headL, self.headR, self.headRoute = l, r, route
        self:PlaceHeads()
    end
    function b:PlaceHeads()
        local l, r = self.headL, self.headR
        local h1, h2 = self.heads[1], self.heads[2]
        h1:ClearAllPoints()
        h2:ClearAllPoints()
        if self.split then
            h1:SetPoint("TOP", self.left, "TOP", 0, -7)
            h1:SetWidth(max(40, self.split - 40))
            h2:SetPoint("TOP", self.right, "TOP", 0, -7)
            h2:SetWidth(max(40, (self:GetWidth() or 400) - self.split - 40))
            h1:SetText(l and UI.Upper(l) or "")
            h2:SetText(r and UI.Upper(r) or "")
            h2:Show()
        else
            h1:SetPoint("TOP", self, "TOP", 0, -7)
            h1:SetWidth(max(40, (self:GetWidth() or 400) - 60))
            local both = (l and r and l ~= r) and (l .. "  -  " .. r) or (r or l)
            h1:SetText(both and UI.Upper(both) or "")
            h2:Hide()
        end
        self.headBtn:ClearAllPoints()
        self.headBtn:SetPoint("CENTER", h1, "CENTER")
        self.headBtn:SetSize(max(1, h1:GetStringWidth() + 8), max(1, h1:GetStringHeight() + 8))
        self.headBtn:SetShown(self.headRoute ~= nil)
    end
    -- at the foot of each page a small flourish, as printed books have (in the styles of the book only)
    b.orn = {}
    for i, side in ipairs({ b.left, b.right }) do
        local o = CreateFrame("Frame", nil, b)
        o:SetSize(40, 7)
        o:SetPoint("BOTTOM", side, "BOTTOM", 0, 3)
        o:SetFrameLevel(b:GetFrameLevel() + 1)
        o.dia = UI.Diamond(o, 5, { 1, 1, 1, 1 }, "ARTWORK", 1)
        o.dia:SetPoint("CENTER")
        o.l = o:CreateTexture(nil, "ARTWORK")
        o.l:SetTexture(UI.WHITE)
        o.l:SetSize(14, 1)
        o.l:SetPoint("RIGHT", o.dia, "LEFT", -3, 0)
        o.r = o:CreateTexture(nil, "ARTWORK")
        o.r:SetTexture(UI.WHITE)
        o.r:SetSize(14, 1)
        o.r:SetPoint("LEFT", o.dia, "RIGHT", 3, 0)
        o.text = K.Text(o, "small", "rubric", "CENTER")
        o.text:SetPoint("CENTER", 0, 1)
        b.orn[i] = o
    end
    -- the flourish only in the styles of the book; the folio (a place in the part) in every style
    function b:PaintOrn()
        for _, o in ipairs(self.orn) do
            local has = o.text:IsShown()
            o:SetShown(o.want ~= false and (o.classic or has) and true or false)
            o.l:SetShown(o.classic and true or false)
            o.r:SetShown(o.classic and true or false)
            o.dia:SetShown(o.classic and not has or false)
        end
    end
    function b:SetFolio(l, r)
        for i, t in ipairs({ l or false, r or false }) do
            local o = self.orn[i]
            local has = t and t ~= ""
            o.text:SetText(has and t or "")
            o.text:SetShown(has and true or false)
            o.l:ClearAllPoints()
            o.r:ClearAllPoints()
            o.l:SetPoint("RIGHT", has and o.text or o.dia, "LEFT", -6, 0)
            o.r:SetPoint("LEFT", has and o.text or o.dia, "RIGHT", 6, 0)
        end
        self:PaintOrn()
    end
    UI.Skin.Add(b.orn[1], function()
        local classic = CLASSIC[UI.THEME or "codex"]
        local r, g, bb = UI.Tok("rubric")
        for _, o in ipairs(b.orn) do
            o.dia:SetVertexColor(r, g, bb, 0.7)
            UI.Gradient(o.l, "HORIZONTAL", { r, g, bb, 0 }, { r, g, bb, 0.6 })
            UI.Gradient(o.r, "HORIZONTAL", { r, g, bb, 0.6 }, { r, g, bb, 0 })
            o.classic = classic
        end
        b:PaintOrn()
    end)
    function b:Lay(split)
        self.split = split
        self.left:ClearAllPoints()
        self.right:ClearAllPoints()
        if split then
            self.left:SetPoint("TOPLEFT")
            self.left:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", split, 0)
            self.right:SetPoint("TOPLEFT", self, "TOPLEFT", split, 0)
            self.right:SetPoint("BOTTOMRIGHT")
            self.left:Show()
            self.orn[1].want = true
            self:PaintOrn()
            self.fold:Place(split)
            self.fold:SetFrameLevel(self:GetFrameLevel() + 30)
            self:PlaceHeads()
        else
            self.right:SetAllPoints(self)
            self.left:Hide()
            self.orn[1].want = false
            self:PaintOrn()
            self.fold:Hide()
            if self.PlaceHeads then self:PlaceHeads() end
        end
    end
    b:Lay(nil)
    return b
end

-- A view inside the open book: the book lies on the desk (outer) with room for its shadow, and everything of the
-- view goes into host, the size of the book. K.BOOK_W and K.BOOK_H are what the book is smaller than the desk.
-- K.PAGE_HEAD and K.PAGE_FOOT are the room at the top and the foot of a page for its running head and folio.
K.PAGE_HEAD, K.PAGE_FOOT = 24, 18
K.BOOK_W, K.BOOK_H = 26, 22 + K.PAGE_HEAD + K.PAGE_FOOT
function K.BookHost(outer)
    local book = K.Spread(outer)
    book:SetPoint("TOPLEFT", outer, "TOPLEFT", 10, -8)
    book:SetPoint("BOTTOMRIGHT", outer, "BOTTOMRIGHT", -16, 14)
    local host = CreateFrame("Frame", nil, book)
    host:SetPoint("TOPLEFT", book, "TOPLEFT", 0, -K.PAGE_HEAD)
    host:SetPoint("BOTTOMRIGHT", book, "BOTTOMRIGHT", 0, K.PAGE_FOOT)
    outer.book = book          -- (the shell writes the running heads on it)
    return book, host
end

-- A ring to tick (a task, a first step): drawn from smooth round shapes, so its edge stays clean however the window
-- is scaled (a square of thin lines falls between the pixels); filled and ticked when done. It grows with the
-- writing; b:Beside(fs, x) puts it at the left of the first line of fs.
function K.CheckBox(parent)
    local b = CreateFrame("Frame", nil, parent)
    b:EnableMouse(false)
    b.ring = UI.Circle(b, 15, { 1, 1, 1, 1 }, "ARTWORK", 0)
    b.ring:SetPoint("CENTER")
    b.hole = UI.Circle(b, 11, { 1, 1, 1, 1 }, "ARTWORK", 1)
    b.hole:SetPoint("CENTER")
    b.tick = K.Glyph(b, "check", 10, "onGold")
    b.tick:SetPoint("CENTER", 0, 0)
    b.tick:SetFrameLevel(b:GetFrameLevel() + 2)
    local function paint(s)
        local done = s.done
        local r, g, bb = UI.Tok(done and "pos" or "muted")
        s.ring:SetVertexColor(r, g, bb, done and 1 or 0.9)
        local hr, hg, hb = UI.Tok("inset")
        s.hole:SetVertexColor(hr, hg, hb, 1)
        s.hole:SetShown(not done)
        s.tick:SetShown(done and true or false)
    end
    UI.Skin.Add(b, paint)
    function b:SetDone(done)
        self.done = done and true or false
        paint(self)
    end
    function b:Fit(size)
        self:SetSize(size, size)
        self.ring:SetSize(size, size)
        local th = max(2, floor(size * 0.13 + 0.5))
        self.hole:SetSize(size - 2 * th, size - 2 * th)
        self.tick:SetSize(size - 5, size - 5)
    end
    b:Fit(16)
    -- the size follows the writing; the ring stands in the middle of the first line of fs, x points from the left
    function b:Beside(fs, x)
        local size = floor(16 * UI.FK() + 0.5)
        self:Fit(size)
        local _, fsize = fs:GetFont()
        local line = (fsize or 12) * 1.15
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", fs:GetParent(), "TOPLEFT", x or 0, -floor(max(0, (line - size) / 2) + 0.5))
        return size
    end
    return b
end

-- the styles of the book (Leather and gold, Parchment) dress their controls as parts of the book: tabs instead of
-- buttons, figures without boxes; Modern and Strong contrast keep plain controls
function K.IsBook() return CLASSIC[UI.THEME or "codex"] and true or false end
