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
    if K.Material then
        K.Material(c, "card")
        K.Corners(c, 5, 6)
    else
        c:SetSurface("card", "line")
    end
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
local BUTTON = {
    primary = { bg = "gold", border = "gold", text = "onGold", hoverBg = "title", hoverBorder = "title" },
    secondary = { bg = "inset", border = "line", text = "ink", hoverBg = "hover", hoverBorder = "gold" },
    ghost = { text = "gold", hoverBg = "hover", hoverText = "title" },
    danger = { bg = "danger", border = "danger", text = "onGold", hoverBg = "neg", hoverBorder = "neg" },
}

local function paintButton(b)
    local st = BUTTON[b.style] or BUTTON.secondary
    local hot = b.hover and b:IsEnabled()
    b.bgKey = hot and (st.hoverBg or st.bg) or st.bg
    b.borderKey = hot and (st.hoverBorder or st.border) or st.border
    paintBox(b)
    b.label.colorKey = hot and (st.hoverText or st.text) or st.text
    if b.style == "danger" then b.label.colorKey = "white" end
    paintText(b.label)
    if b.glyph then b.glyph:SetColorKey(b.label.colorKey) end
    b:SetAlpha(b:IsEnabled() and 1 or 0.45)
    if b.sheen then b.sheen:SetShown(b.style ~= "ghost" or hot) end
    -- the width follows the label (it changes with the size of the writing and the language)
    if not b.fixedW then
        local extra = b.glyph and 18 or 0
        b:SetWidth(floor(b.label:GetStringWidth() + 28 + extra + 0.5))
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
        local hot = self.hover and self:IsEnabled()
        self.bgKey = (self.active or hot) and "hover" or (self.flat and nil or "inset")
        self.borderKey = (self.active or hot) and "gold" or (self.flat and nil or "line")
        paintBox(self)
        local k = (self.active or hot) and "title" or "soft"
        if self.glyph then self.glyph:SetColorKey(k) end
        if self.letter then K.Recolor(self.letter, k) end
        self:SetAlpha(self:IsEnabled() and 1 or 0.4)
    end
    b.Paint = paint
    function b:SetActive(on) self.active = on paint(self) end
    function b:SetFlat(on) self.flat = on paint(self) end
    b:SetScript("OnEnter", function(self) self.hover = true paint(self) end)
    b:SetScript("OnLeave", function(self) self.hover = nil paint(self) end)
    b:SetScript("OnEnable", paint)
    b:SetScript("OnDisable", paint)
    b:SetScript("OnClick", function(self, ...) if onClick then onClick(self, ...) end end)
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
    function f:Refresh()
        local cur = get()
        local x = 0
        for _, b in ipairs(self.buttons) do
            b.style = (b.value == cur) and "primary" or "secondary"
            paintButton(b)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", self, "TOPLEFT", x, 0)
            x = x + b:GetWidth() - 1
        end
        self:SetSize(max(1, x + 1), self.buttons[1] and self.buttons[1]:GetHeight() or 30)
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
local menu
local function closeMenu()
    if menu and menu:IsShown() then menu:Hide() return true end
    return false
end
K.CloseMenu = closeMenu

local function openMenu(owner, items, cur, onPick)
    if not menu then
        menu = K.Box(UIParent, "panel", "gold")
        menu:SetFrameStrata("FULLSCREEN_DIALOG")
        menu:EnableMouse(true)
        menu.rows = {}
        menu:Hide()
    end
    if menu:IsShown() and menu.owner == owner then menu:Hide() return end
    menu.owner = owner
    menu:SetScale(owner:GetEffectiveScale() / UIParent:GetEffectiveScale())
    local w = max(owner:GetWidth(), 160)
    for i, it in ipairs(items) do
        local r = menu.rows[i]
        if not r then
            r = K.Box(menu, nil, nil, "Button")
            r:SetHeight(26)
            r.text = K.Text(r, "body", "ink")
            r.text:SetPoint("LEFT", 10, 0)
            r.text:SetPoint("RIGHT", -10, 0)
            r:SetScript("OnEnter", function(self) self:SetSurface("hover") end)
            r:SetScript("OnLeave", function(self) self:SetSurface(self.chosen and "inset" or nil) end)
            r:SetScript("OnClick", function(self)
                menu:Hide()
                if menu.onPick then menu.onPick(self.value) end
            end)
            menu.rows[i] = r
        end
        r.value, r.chosen = it[1], it[1] == cur
        r.text:SetText(it[2])
        K.Recolor(r.text, r.chosen and "title" or "ink")
        r:SetSurface(r.chosen and "inset" or nil)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -4 - (i - 1) * 26)
        r:SetWidth(w - 8)
        r:Show()
    end
    for i = #items + 1, #menu.rows do menu.rows[i]:Hide() end
    menu.onPick = onPick
    menu:SetSize(w, #items * 26 + 8)
    menu:ClearAllPoints()
    menu:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
    menu:Show()
end

function K.Dropdown(parent, items, get, set, width)
    local b = K.Button(parent, "", "secondary", nil, width or 220)
    b:AddArrow("down")
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
    f.text = K.Text(f, "section", "gold")
    f.text:SetPoint("LEFT", 12, 0)
    f.right = K.Text(f, "small", "soft", "RIGHT")
    f.right:SetPoint("RIGHT", 0, 0)
    f.rule = f:CreateTexture(nil, "ARTWORK")
    f.rule:SetTexture(UI.WHITE)
    f.rule:SetHeight(1)
    local function paint(s)
        local r, g, b = UI.Tok("gold")
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
function K.Scroll(parent)
    local sf = CreateFrame("ScrollFrame", nil, parent)
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
    d.ok = K.Button(d.box, "", "primary")
    d.cancel = K.Button(d.box, L["Cancel"], "secondary", function() d:Hide() end)
    d.input:SetScript("OnEnterPressed", function() d.ok:Click() end)
    d.input:SetScript("OnEscapePressed", function() d:Hide() end)
    d:SetScript("OnHide", function(self) self.input:ClearFocus() end)
    d:Hide()
    return d
end

-- opt = { title, text, ok, danger, onOk, input = { value, numeric, max }, cancel }
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
    d.ok.onClick = function()
        local v = opt.input and d.input:GetText()
        d:Hide()
        if opt.onOk then opt.onOk(v) end
    end
    d.title:SetWidth(380 - 36)
    local y = 16 + d.title:GetStringHeight() + 10
    if d.text:IsShown() then
        d.text:SetWidth(380 - 36)
        y = y + d.text:GetStringHeight() + 14
    end
    d.input:ClearAllPoints()
    if opt.input then
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
    d:Show()
    if opt.input then
        d.input:SetFocus()
        d.input:HighlightText()
    end
end

-- a question with two answers; onOk runs on the first
function UI:Confirm(opt) openDialog(opt) end
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
