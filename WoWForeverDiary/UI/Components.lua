-- Reusable building blocks for book pages: a widget pool, model sketches, glued-in maps.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, ceil, sqrt, pi = math.floor, math.max, math.min, math.ceil, math.sqrt, math.pi
local format = string.format

------------------------------------------------------------------------
-- Pool: every page canvas re-uses its widgets when it is redrawn
------------------------------------------------------------------------
local Pool = {}
Pool.__index = Pool

function UI.NewPool(parent)
    return setmetatable({ parent = parent, lists = {}, used = {} }, Pool)
end

-- Begin a redraw. Widgets stay visible while they are re-used, so 3D models do not reload and flicker;
-- End() hides whatever this redraw did not use again.
function Pool:Begin()
    for kind, list in pairs(self.lists) do
        for i = 1, #list do list[i]:ClearAllPoints() end
        self.used[kind] = 0
    end
end

-- Nothing on a page is cut off: a text too long for its line, or for the lines it may take, gets smaller
-- letters step by step (to about three fifths of its size). Long words in long languages and the larger
-- writing chosen in the settings then still fit.
local function truncated(fs)
    if fs.CanWordWrap and not fs:CanWordWrap() then
        local w = fs:GetWidth() or 0
        local full = fs.GetUnboundedStringWidth and fs:GetUnboundedStringWidth() or fs:GetStringWidth()
        if w > 0 and (full or 0) > w + 0.5 then return true end
    end
    return fs.IsTruncated and fs:IsTruncated() and true or false
end

function UI.Unclip(fs)
    if not fs:IsShown() or (fs:GetText() or "") == "" then return end
    local font, size, flags = fs:GetFont()
    if not (font and size) then return end
    size = floor(size + 0.5)
    local smallest = max(8, floor(size * 0.62))
    while size > smallest and truncated(fs) do
        size = size - 1
        fs:SetFont(font, size, flags or "")
    end
end

function Pool:End()
    local texts = self.lists.text
    for i = 1, (texts and self.used.text or 0) do UI.Unclip(texts[i]) end
    for kind, list in pairs(self.lists) do
        for i = (self.used[kind] or 0) + 1, #list do list[i]:Hide() end
    end
end

function Pool:Get(kind, factory)
    local n = (self.used[kind] or 0) + 1
    self.used[kind] = n
    local list = self.lists[kind]
    if not list then
        list = {}
        self.lists[kind] = list
    end
    local o = list[n]
    if not o then
        o = factory(self.parent)
        list[n] = o
    end
    o:Show()
    return o
end

function Pool:Text(size, col, font, justify)
    local fs = self:Get("text", function(p) return p:CreateFontString(nil, "OVERLAY") end)
    fs:SetFont(font or UI.HEAD, UI.FS and UI.FS(size or 14) or (size or 14), "")
    local r, g, b, a = col4(col or c.ink)
    fs:SetTextColor(r, g, b, a)
    fs:SetJustifyH(justify or "LEFT")
    fs:SetJustifyV("TOP")
    -- light writing on the dark pages gets a soft shadow so it stands off the leather;
    -- dark ink (on parchment cards) stays crisp without one
    if 0.30 * r + 0.59 * g + 0.11 * b > 0.45 then
        fs:SetShadowColor(0, 0, 0, 0.8)
        fs:SetShadowOffset(1, -1)
    else
        fs:SetShadowOffset(0, 0)
    end
    fs:SetSpacing(0)
    fs:SetWordWrap(true)
    if fs.SetMaxLines then fs:SetMaxLines(0) end   -- a pooled string must not keep the line limit of another page
    fs:SetWidth(0)
    fs:SetHeight(0)
    fs:SetAlpha(1)
    fs:SetText("")
    return fs
end

function Pool:Rect(col, a, layer, sub)
    local t = self:Get("rect", function(p) return p:CreateTexture(nil, "ARTWORK") end)
    t:SetDrawLayer(layer or "ARTWORK", sub or 0)
    t:SetTexture(UI.WHITE)
    t:SetTexCoord(0, 1, 0, 1)
    t:SetRotation(0)
    t:SetDesaturated(false)
    t:SetBlendMode("BLEND")
    -- on a texture SetAlpha and the vertex alpha are the same value: set the colour opaque, then the alpha
    local r, g, b, al = col4(col, a)
    t:SetVertexColor(r, g, b, 1)
    t:SetAlpha(al)
    return t
end

function Pool:Grad(orient, from, to, layer, sub)
    local t = self:Get("grad", function(p) return p:CreateTexture(nil, "ARTWORK") end)
    t:SetDrawLayer(layer or "ARTWORK", sub or 0)
    t:SetRotation(0)
    UI.Gradient(t, orient, from, to)
    return t
end

-- a straight line between two points of the canvas (nil on clients without line regions)
function Pool:Line(x1, y1, x2, y2, col, a, thick)
    local canvas = self.parent
    if not canvas.CreateLine then return nil end
    local l = self:Get("line", function(p) return p:CreateLine(nil, "ARTWORK") end)
    l:SetDrawLayer("ARTWORK", 3)
    l:SetColorTexture(col[1], col[2], col[3], a or 1)
    l:SetThickness(thick or 2)
    l:SetStartPoint("TOPLEFT", canvas, x1, y1)
    l:SetEndPoint("TOPLEFT", canvas, x2, y2)
    return l
end

function Pool:Diamond(size, col, layer, sub)
    local t = self:Rect(col, nil, layer, sub)
    t:SetSize(size, size)
    t:SetRotation(pi / 4)
    return t
end

function Pool:Circle(size, col, layer, sub)
    local t = self:Get("circle", function(p)
        local tex = p:CreateTexture(nil, "ARTWORK")
        tex:SetTexture(UI.WHITE)
        tex.round = UI.Round(tex, p)
        return tex
    end)
    t:SetDrawLayer(layer or "ARTWORK", sub or 0)
    -- alpha goes on the texture itself: vertex alpha is not honoured on masked textures by every client
    t:SetVertexColor(col[1], col[2], col[3], 1)
    t:SetAlpha(col[4] or 1)
    local k = t.round and 1 or 0.74
    t:SetSize(size * k, size * k)
    t:SetRotation(t.round and 0 or pi / 4)
    return t
end

function Pool:Icon(path, size, layer, sub, round)
    local kind = round and "ricon" or "icon"
    local t = self:Get(kind, function(p)
        local tex = p:CreateTexture(nil, "ARTWORK")
        if round then UI.Round(tex, p) end
        return tex
    end)
    t:SetDrawLayer(layer or "ARTWORK", sub or 0)
    t:SetTexture(path)
    t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    t:SetDesaturated(false)
    t:SetVertexColor(1, 1, 1, 1)
    t:SetAlpha(1)
    t:SetSize(size, size)
    return t
end

-- A trophy plaque: a game icon in a bevelled metal frame with a drop shadow, centred on (cx, cy).
-- Locked plaques are grey and dim, so there is always something left to win.
function Pool:Plaque(cx, cy, size, path, col, earned, count, coords)
    local canvas = self.parent
    local f = size + 6
    local metal = earned and col or { 0.46, 0.39, 0.30, 1 }
    local sh = self:Rect({ 0, 0, 0 }, earned and 0.35 or 0.15, "ARTWORK", 0)
    sh:SetSize(f, f)
    sh:SetPoint("CENTER", canvas, "TOPLEFT", cx + 2, cy - 2)
    local fr = self:Rect(metal, 1, "ARTWORK", 1)
    fr:SetSize(f, f)
    fr:SetPoint("CENTER", canvas, "TOPLEFT", cx, cy)
    -- bevel: light upper and left edge, dark lower and right edge
    local lt = { min(1, metal[1] * 1.5 + 0.15), min(1, metal[2] * 1.5 + 0.15), min(1, metal[3] * 1.5 + 0.15) }
    local dk = { metal[1] * 0.45, metal[2] * 0.45, metal[3] * 0.45 }
    for i, e in ipairs({ { "TOPLEFT", "TOPRIGHT", lt }, { "TOPLEFT", "BOTTOMLEFT", lt },
                         { "BOTTOMLEFT", "BOTTOMRIGHT", dk }, { "TOPRIGHT", "BOTTOMRIGHT", dk } }) do
        local b = self:Rect(e[3], 1, "ARTWORK", 2)
        b:SetPoint(e[1], fr, e[1])
        b:SetPoint(e[2], fr, e[2])
        if i == 1 or i == 3 then b:SetHeight(1) else b:SetWidth(1) end
    end
    local inner = self:Rect({ 0.08, 0.05, 0.03 }, 1, "ARTWORK", 3)
    inner:SetSize(size + 2, size + 2)
    inner:SetPoint("CENTER", fr, "CENTER")
    local ic = self:Icon(path, size, "ARTWORK", 4)
    ic:SetPoint("CENTER", fr, "CENTER")
    if coords then ic:SetTexCoord(coords[1], coords[2], coords[3], coords[4]) end   -- one icon of an atlas
    if not earned then
        ic:SetDesaturated(true)
        ic:SetVertexColor(0.80, 0.74, 0.64, 1)
        ic:SetAlpha(0.55)
    end
    if count and count ~= "" then
        local n = self:Text(size >= 36 and 11 or 10, { 1, 0.96, 0.85, 1 }, UI.FONT, "RIGHT")
        n:SetShadowColor(0, 0, 0, 1)
        n:SetShadowOffset(1, -1)
        n:SetText(count)
        n:SetPoint("BOTTOMRIGHT", ic, "BOTTOMRIGHT", -1, 2)
        if not earned then n:SetAlpha(0.7) end
    end
    return fr
end

function Pool:Seal(size, col, iconKey, text)
    local s = self:Get("seal", function(p) return UI.Seal(p, 20, c.red, nil, true) end)
    s:SetSealSize(size)
    s:SetAlpha(1)
    s:SetSeal(col, iconKey, true, text)
    s.label:SetFont(UI.HEAD, max(9, floor(size * 0.42)), "")
    s:SetScript("OnEnter", nil)
    s:SetScript("OnLeave", nil)
    s:SetScript("OnClick", nil)
    return s
end

-- Invisible hot spot for tooltips, item links and clicks.
-- the lines of a tooltip that tell what a click does: always written in the same blue, and a
-- clickable spot without one gets a plain "Click to open."
local CLICK_HINTS = {
    "Click for all first times.", "Click for all landmarks.", "Click for the map of this region.", "Click for the next goals.",
    "Click for the portrait.", "Click for the wanted poster.", "Click here to write your own notes ...",
    "Click to open the diary.", "Click to open this part of the book.", "Click to open today's entry.", "Click to open",
    "Click to read the letter.", "Click to read this day aloud in chat.", "Click to read this day.",
    "Click to set a marker on the map.", "Right-click for the map of this region.", "Right-click to go to a page.",
    "Click to open.", "Right-click for the settings.", "Click for the hunting grounds of this area.",
    "Click to show only these.", "Click to show all again.", "Ctrl-click to set or remove a bookmark here.",
    "Click to open, right-click to remove.", "Click to go to a page.", "Right-click for the contents.",
    "Click to set a bookmark here.", "Click to remove the bookmark.",
}
local clickSet
local function isHint(s)
    if not clickSet then
        clickSet = {}
        for _, k in ipairs(CLICK_HINTS) do clickSet[L[k]] = true end
    end
    return clickSet[s]
end
UI.IsClickHint = isHint

function Pool:Hot(lines, onClick, link)
    local b = self:Get("hot", function(p)
        local h = CreateFrame("Button", nil, p)
        h:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        h.hl = h:CreateTexture(nil, "BACKGROUND")
        h.hl:SetAllPoints()
        h.hl:SetTexture(UI.WHITE)
        h.hl:SetVertexColor(0.91, 0.76, 0.42, 1)
        h.hl:Hide()
        h:SetScript("OnEnter", function(s)
            if s.onClick then s.hl:Show() end
            if s.link then
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(s.link)
                GameTooltip:Show()
            elseif s.lines then
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(s.lines[1], 1, 0.86, 0.5, 1, true)
                local hinted = false
                for i = 2, #s.lines do
                    if isHint(s.lines[i]) then
                        hinted = true
                        GameTooltip:AddLine(s.lines[i], 0.5, 0.8, 1, true)
                    else
                        GameTooltip:AddLine(s.lines[i], 0.9, 0.9, 0.9, true)
                    end
                end
                if s.onClick and not hinted then GameTooltip:AddLine(L["Click to open."], 0.5, 0.8, 1) end
                GameTooltip:Show()
            end
        end)
        h:SetScript("OnLeave", function(s)
            s.hl:Hide()
            GameTooltip:Hide()
        end)
        h:SetScript("OnClick", function(s, button)
            if button == "RightButton" then
                if s.onRight then s.onRight() end
            elseif s.onClick then
                s.onClick()
            end
        end)
        return h
    end)
    b.lines, b.onClick, b.link, b.onRight = lines, onClick, link, nil
    b.hl:SetAlpha(0.09)          -- faint red wash on hover (the notes page sets it to 0)
    b:SetFrameLevel(self.parent:GetFrameLevel() + 6)
    return b
end

-- Ink text that acts like a link
function Pool:Link(text, onClick, size, col)
    local fs = self:Text(min(13, size or 13), col or c.redInk, UI.FONT)
    fs:SetText(text)
    local hot = self:Hot(nil, onClick)
    hot:SetPoint("TOPLEFT", fs, "TOPLEFT", -3, 3)
    hot:SetPoint("BOTTOMRIGHT", fs, "BOTTOMRIGHT", 3, -3)
    return fs, hot
end

function Pool:Check(label, getter, setter)
    local b = self:Get("check", function(p)
        local cb = CreateFrame("Button", nil, p)
        cb:SetSize(300, 22)
        local box = UI.Frame(cb, 18, 18)
        UI.Backdrop(box, "tooltip", 10, 2, { 0.10, 0.07, 0.04, 0.9 }, c.goldDk)
        box:SetPoint("LEFT", 0, 0)
        cb.tick = box:CreateTexture(nil, "OVERLAY")
        cb.tick:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        cb.tick:SetSize(24, 24)
        cb.tick:SetPoint("CENTER", 2, 1)
        cb.tick:SetVertexColor(0.95, 0.80, 0.40, 1)
        cb.txt = UI.Text(cb, 13, c.ink, "LEFT", UI.FONT)
        cb.txt:SetPoint("LEFT", box, "RIGHT", 8, 0)
        cb:SetScript("OnClick", function(s)
            s.setter(not s.getter())
            s.tick:SetShown(s.getter() and true or false)
        end)
        return cb
    end)
    b.getter, b.setter = getter, setter
    b.txt:SetText(label)
    b:SetWidth(b.txt:GetStringWidth() + 40)
    b.tick:SetShown(getter() and true or false)
    b:SetFrameLevel(self.parent:GetFrameLevel() + 6)
    return b
end

-- Multi-line handwriting field for notes, saved on every keystroke
function Pool:NoteEdit(w, h, lineH, text, onSave, hint)
    local eb = self:Get("noteedit", function(p)
        local e = CreateFrame("EditBox", nil, p)
        e:SetMultiLine(true)
        e:SetAutoFocus(false)
        e:SetMaxLetters(4000)
        e:SetShadowOffset(0, 0)
        e:SetTextColor(UI.THEME == "parchment" and 0.10 or 0.74, UI.THEME == "parchment" and 0.17 or 0.84, UI.THEME == "parchment" and 0.36 or 0.98, 1)
        e.hint = e:CreateFontString(nil, "OVERLAY")
        e.hint:SetPoint("TOPLEFT", 0, 0)
        e.hint:SetJustifyH("LEFT")
        local function updHint(s)
            s.hint:SetShown(s:GetText() == "" and not s:HasFocus())
            UI.noteFocus = s:HasFocus() and true or false
        end
        e:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
        e:SetScript("OnEditFocusGained", updHint)
        e:SetScript("OnEditFocusLost", updHint)
        e:SetScript("OnTextChanged", function(s, user)
            if user and s.onSave then s.onSave(s:GetText()) end
            updHint(s)
        end)
        return e
    end)
    eb:SetFont(UI.FONT, 14, "")
    if eb.SetSpacing then eb:SetSpacing(max(0, lineH - 14)) end
    eb:SetSize(w, h)
    eb.onSave = nil
    eb:SetText(text or "")
    eb.onSave = onSave
    eb.hint:SetFont(UI.FONT, 13, "")
    if UI.THEME == "parchment" then eb.hint:SetTextColor(0.40, 0.30, 0.18, 0.85) else eb.hint:SetTextColor(0.58, 0.64, 0.78, 0.8) end
    eb.hint:SetWidth(w)
    eb.hint:SetText(hint or "")
    eb.hint:SetShown((text or "") == "")
    return eb
end

function Pool:Model(w, h)
    local m = self:Get("model", function(p) return UI.ModelBox(p, w, h) end)
    m:SetSize(w, h)
    return m
end

function Pool:Map(w, h)
    local m = self:Get("map", function(p) return UI.MapSketch(p, w, h) end)
    return m
end

------------------------------------------------------------------------
-- Creature models load lazily when the client has not seen the creature yet:
-- try again a few times and show a placeholder if it never appears.
local function hasModel(model)
    if model.GetModelFileID then
        local id = model:GetModelFileID()
        return id ~= nil and id ~= 0
    end
    return true
end

function UI.LoadCreature(model, npcId, zoom, placeholder)
    model.wantId = npcId
    model:ClearModel()
    if placeholder then placeholder:Hide() end
    local function try(attempt)
        if model.wantId ~= npcId then return end
        local ok = pcall(function()
            model:SetCreature(npcId)
            if zoom and model.SetPortraitZoom then model:SetPortraitZoom(zoom) end
            if not zoom then
                model:SetRotation(0.35)
                -- full figure: the camera steps back, so heads and feet stay inside the low frame
                if model.SetPortraitZoom then model:SetPortraitZoom(0) end
                if model.SetCamDistanceScale then model:SetCamDistanceScale(1.45) end
                if model.SetPosition then model:SetPosition(0, 0, 0) end
            end
        end)
        if ok and hasModel(model) then
            if placeholder then placeholder:Hide() end
            return
        end
        if attempt < 4 then
            C_Timer.After(0.6 * attempt, function() try(attempt + 1) end)
        elseif placeholder then
            placeholder:Show()
        end
    end
    try(1)
end

-- A creature portrait sketched into the book (rotatable 3D model)
------------------------------------------------------------------------
function UI.ModelBox(parent, w, h)
    local box = UI.Inset(parent, w, h)
    local bg = UI.GradRect(box, "VERTICAL", { 0.10, 0.06, 0.03, 0.85 }, { 0.32, 0.22, 0.11, 0.75 }, "BACKGROUND", 1)
    bg:SetPoint("TOPLEFT", 4, -4)
    bg:SetPoint("BOTTOMRIGHT", -4, 4)
    local model = CreateFrame("PlayerModel", nil, box)
    model:SetPoint("TOPLEFT", 5, -5)
    model:SetPoint("BOTTOMRIGHT", -5, 5)
    box.model = model
    box.none = UI.Text(box, 13, { 0.80, 0.68, 0.48, 1 }, "CENTER", UI.HEAD)
    box.none:SetPoint("CENTER")
    box.none:SetText(L["No portrait"])
    box.none:Hide()
    function box:Show3D(npcId)
        if npcId ~= nil and npcId == self.current then return end
        self.current = npcId
        self.model:ClearModel()
        self.none:Hide()
        if type(npcId) ~= "number" then
            self.none:Show()
            return
        end
        UI.LoadCreature(self.model, npcId, nil, self.none)
    end
    model:EnableMouse(true)
    model:SetScript("OnMouseDown", function(self) self.dragX = GetCursorPosition() end)
    model:SetScript("OnMouseUp", function(self) self.dragX = nil end)
    model:SetScript("OnHide", function(self) self.dragX = nil end)     -- the page turned while dragging
    model:SetScript("OnUpdate", function(self)
        if not self.dragX then return end
        local x = GetCursorPosition()
        self.rot = (self.rot or 0.35) + (x - self.dragX) / 80
        self.dragX = x
        self:SetRotation(self.rot)
    end)
    return box
end

------------------------------------------------------------------------
-- A sepia map glued into the book, with the route drawn in ink
------------------------------------------------------------------------
function UI.MapSketch(parent, w, h)
    local box = UI.Frame(parent, w, h)
    UI.Backdrop(box, "tooltip", 12, 3, { 0.10, 0.07, 0.04, 1 }, { 0.78, 0.60, 0.26, 1 })
    local canvas = CreateFrame("Frame", nil, box)
    canvas:SetPoint("TOPLEFT", 4, -4)
    canvas:SetPoint("BOTTOMRIGHT", -4, 4)
    local canClip = canvas.SetClipsChildren ~= nil
    if canClip then canvas:SetClipsChildren(true) end
    local mf = CreateFrame("Frame", nil, canvas)
    mf:SetPoint("CENTER")
    box.mapFrame = mf
    box.tiles, box.cells, box.pins = {}, {}, {}
    local over = CreateFrame("Frame", nil, canvas)
    over:SetAllPoints()
    over:SetFrameLevel(mf:GetFrameLevel() + 8)
    for _, e in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        UI.EdgeFade(over, e, 20, { 0.25, 0.14, 0.04 }, 0.5, "OVERLAY")
    end
    -- compass rose in the upper right corner
    local rose = CreateFrame("Frame", nil, canvas)
    rose:SetSize(48, 48)
    rose:SetPoint("TOPRIGHT", -10, -10)
    rose:SetFrameLevel(mf:GetFrameLevel() + 9)
    local rring = UI.Circle(rose, 36, { 0.25, 0.14, 0.05, 0.75 }, "ARTWORK", 0)
    rring:SetPoint("CENTER")
    local rinner = UI.Circle(rose, 32, { 0.95, 0.88, 0.70, 0.85 }, "ARTWORK", 1)
    rinner:SetPoint("CENTER")
    local star1 = UI.Fill(rose, { 0.30, 0.18, 0.06 }, "ARTWORK", 2, 0.9)
    star1:SetSize(6, 30)
    star1:SetPoint("CENTER")
    local star2 = UI.Fill(rose, { 0.30, 0.18, 0.06 }, "ARTWORK", 2, 0.9)
    star2:SetSize(30, 6)
    star2:SetPoint("CENTER")
    local star3 = UI.Diamond(rose, 14, { 0.56, 0.09, 0.05, 1 }, "ARTWORK", 3)
    star3:SetPoint("CENTER")
    local hub = UI.Circle(rose, 6, c.gold, "ARTWORK", 4)
    hub:SetPoint("CENTER")
    local north = UI.Text(rose, 11, { 0.30, 0.18, 0.06, 1 }, "CENTER", UI.HEAD)
    north:SetPoint("BOTTOM", rose, "TOP", 0, -8)
    north:SetText("N")

    -- a small "?" under the compass rose: what the mouse can do on every map
    local help = CreateFrame("Button", nil, canvas)
    help:SetSize(20, 20)
    help:SetPoint("TOP", rose, "BOTTOM", 0, -12)
    help:SetFrameLevel(mf:GetFrameLevel() + 10)
    local hring = UI.Circle(help, 18, { 0.25, 0.14, 0.05, 0.75 }, "ARTWORK", 0)
    hring:SetPoint("CENTER")
    local hq = UI.Text(help, 12, { 0.95, 0.88, 0.70, 1 }, "CENTER", UI.HEAD)
    hq:SetPoint("CENTER", 0, 0)
    hq:SetText("?")
    help:SetScript("OnEnter", function(s)
        GameTooltip:SetOwner(s, "ANCHOR_LEFT")
        GameTooltip:SetText(L["Map controls"], 1, 0.86, 0.5)
        GameTooltip:AddLine(L["Mouse wheel: zoom"], 0.85, 0.85, 0.85)
        GameTooltip:AddLine(L["Drag: move the map"], 0.85, 0.85, 0.85)
        GameTooltip:AddLine(L["Right click: reset"], 0.85, 0.85, 0.85)
        GameTooltip:Show()
    end)
    help:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- zoom with the mouse wheel, drag to pan, right click to reset
    box.zoom, box.panX, box.panY = 1, 0, 0
    function box:ApplyZoom()
        local z = self.zoom
        local mw, mh = self.mw or (w - 8), self.mh or (h - 8)
        local mx = math.max(0, (mw * z - (w - 8)) / 2)
        local my = math.max(0, (mh * z - (h - 8)) / 2)
        self.panX = math.max(-mx, math.min(mx, self.panX))
        self.panY = math.max(-my, math.min(my, self.panY))
        mf:SetScale(z)
        mf:ClearAllPoints()
        mf:SetPoint("CENTER", canvas, "CENTER", self.panX / z, self.panY / z)
        for _, p in ipairs(self.pins) do
            if p:IsShown() and p.fx then
                p:SetScale(1 / z)
                p:ClearAllPoints()
                p:SetPoint("CENTER", mf, "TOPLEFT", p.fx * mw * z, -p.fy * mh * z)
            end
        end
        local me = rawget(self, "me")
        if me and me:IsShown() and me.fx then
            me:SetScale(1 / z)
            me:ClearAllPoints()
            me:SetPoint("CENTER", mf, "TOPLEFT", me.fx * mw * z, -me.fy * mh * z)
        end
        self:LayoutLabels()
    end
    -- names next to the pins: where two would overlap only the first is written (zooming in makes room)
    function box:LayoutLabels()
        local z = self.zoom
        local mw, mh = self.mw or (w - 8), self.mh or (h - 8)
        local taken = {}
        for _, p in ipairs(self.pins) do
            local text = p:IsShown() and p.fx and p.label:GetText()
            if text and text ~= "" then
                local x1, y1 = p.fx * mw * z + 8, p.fy * mh * z - 7
                local x2, y2 = x1 + p.label:GetStringWidth(), y1 + 14
                local free = true
                for _, r in ipairs(taken) do
                    if x1 < r[3] and x2 > r[1] and y1 < r[4] and y2 > r[2] then free = false break end
                end
                p.label:SetShown(free)
                if free then taken[#taken + 1] = { x1, y1, x2, y2 } end
            end
        end
    end
    canvas:EnableMouseWheel(true)
    canvas:SetScript("OnMouseWheel", function(_, delta)
        local z = box.zoom * (delta > 0 and 1.25 or 0.8)
        box.zoom = math.max(1, math.min(5, z))
        if box.zoom == 1 then box.panX, box.panY = 0, 0 end
        box:ApplyZoom()
    end)
    canvas:EnableMouse(true)
    canvas:SetScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            box.zoom, box.panX, box.panY = 1, 0, 0
            box:ApplyZoom()
            return
        end
        self.dragX, self.dragY = GetCursorPosition()
    end)
    canvas:SetScript("OnMouseUp", function(self) self.dragX = nil end)
    canvas:SetScript("OnHide", function(self) self.dragX = nil end)
    canvas:SetScript("OnUpdate", function(self)
        if not self.dragX then return end
        local x, y = GetCursorPosition()
        local s = self:GetEffectiveScale()
        box.panX = box.panX + (x - self.dragX) / s
        box.panY = box.panY + (y - self.dragY) / s
        self.dragX, self.dragY = x, y
        box:ApplyZoom()
    end)

    box.noArt = UI.Text(canvas, 14, { 0.85, 0.75, 0.55, 1 }, "CENTER", UI.HEAD, true)
    box.noArt:SetPoint("CENTER")
    box.noArt:SetText(L["No map art available for this area."])

    local function cell(i)
        local t = box.cells[i]
        if not t then
            t = mf:CreateTexture(nil, "ARTWORK")
            t:SetTexture(UI.WHITE)
            box.cells[i] = t
        end
        return t
    end
    local function pin(i)
        local p = box.pins[i]
        if not p then
            p = CreateFrame("Button", nil, mf)
            p:SetSize(14, 14)
            p:SetFrameLevel(mf:GetFrameLevel() + 6)
            p.rim = UI.Circle(p, 12, { 0.08, 0.04, 0.02, 1 }, "ARTWORK", 0)
            p.rim:SetPoint("CENTER")
            p.dot = UI.Circle(p, 8, c.gold, "ARTWORK", 1)
            p.dot:SetPoint("CENTER")
            p.num = UI.Text(p, 9, { 1, 1, 1, 1 }, "CENTER", UI.FONT, true)
            p.num:SetPoint("CENTER", 0, 0)
            -- a skull for graves: readable without the colour red
            p.skull = p:CreateTexture(nil, "OVERLAY", nil, 2)
            p.skull:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Skull")
            p.skull:Hide()
            -- name written next to the pin (continent atlas)
            p.label = UI.Text(p, 9, { 0.16, 0.09, 0.03, 1 }, "LEFT", UI.FONT)
            p.label:SetShadowColor(1, 0.95, 0.80, 0.9)
            p.label:SetShadowOffset(1, -1)
            p.label:SetPoint("LEFT", p, "RIGHT", 1, 0)
            p:SetScript("OnEnter", function(s)
                if not s.info then return end
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(s.info[1], 1, 0.86, 0.5)
                for k = 2, #s.info do
                    if UI.IsClickHint(s.info[k]) then GameTooltip:AddLine(s.info[k], 0.5, 0.8, 1, true)
                    else GameTooltip:AddLine(s.info[k], 0.85, 0.85, 0.85, true) end
                end
                GameTooltip:Show()
            end)
            p:SetScript("OnLeave", function() GameTooltip:Hide() end)
            p:SetScript("OnClick", function(s) local fn = rawget(s, "onClick") if fn then fn() end end)
            box.pins[i] = p
        end
        return p
    end

    -- the sepia map art of mapID, filling the box; sets mw / mh (size of the drawn map)
    local function drawArt(self, mapID)
        for _, t in ipairs(self.tiles) do t:Hide() end
        for _, t in ipairs(self.cells) do t:Hide() end
        for _, p in ipairs(self.pins) do
            if p.skull then p.skull:Hide() end
            p:Hide()
            p.label:SetText("")
            p.onClick = nil
            p.rim:SetVertexColor(0.08, 0.04, 0.02, 1)
        end
        local me0 = rawget(self, "me")
        if me0 then me0:Hide() end
        local CW, CH = w - 8, h - 8
        local layers = C_Map and C_Map.GetMapArtLayers and C_Map.GetMapArtLayers(mapID)
        local info = layers and layers[1]
        local texs = C_Map and C_Map.GetMapArtLayerTextures and C_Map.GetMapArtLayerTextures(mapID, 1)
        local mw, mh = CW, CH
        if info and texs and #texs > 0 and info.layerWidth and info.layerWidth > 0 then
            self.noArt:Hide()
            local lw, lh, tw, th = info.layerWidth, info.layerHeight, info.tileWidth, info.tileHeight
            local cols, rows = ceil(lw / tw), ceil(lh / th)
            local scale = canClip and max(CW / lw, CH / lh) or min(CW / lw, CH / lh)
            mw, mh = lw * scale, lh * scale
            local idx = 0
            for r = 0, rows - 1 do
                for col = 0, cols - 1 do
                    idx = idx + 1
                    local tex = self.tiles[idx]
                    if not tex then
                        tex = mf:CreateTexture(nil, "BACKGROUND")
                        self.tiles[idx] = tex
                    end
                    local pw = (col < cols - 1) and tw or (lw - tw * (cols - 1))
                    local ph = (r < rows - 1) and th or (lh - th * (rows - 1))
                    tex:ClearAllPoints()
                    tex:SetPoint("TOPLEFT", mf, "TOPLEFT", col * tw * scale, -r * th * scale)
                    tex:SetSize(pw * scale, ph * scale)
                    tex:SetTexture(texs[idx])
                    tex:SetTexCoord(0, pw / tw, 0, ph / th)
                    tex:SetDesaturated(true)
                    tex:SetVertexColor(1.0, 0.88, 0.66, 1)
                    tex:Show()
                end
            end
        else
            self.noArt:Show()
        end
        mf:SetSize(mw, mh)
        self.mw, self.mh = mw, mh
        self.zoom, self.panX, self.panY = 1, 0, 0
        mf:SetScale(1)
        mf:ClearAllPoints()
        mf:SetPoint("CENTER", canvas, "CENTER", 0, 0)
        return mw, mh
    end

    -- the whole continent: every step of the journey, explored regions by name, the rest as "?"
    -- zones = { { id, name, visited, info = { tooltip lines } } }
    function box:DrawContinent(contID, zones)
        local mw, mh = drawArt(self, contID)
        local C = WFD.C
        local used = 0
        local getRect = C_Map and C_Map.GetMapRectOnMap
        local np = 0
        for _, z in ipairs(zones) do
            local ok, x1, x2, y1, y2 = false
            if getRect then ok, x1, x2, y1, y2 = pcall(getRect, z.id, contID) end
            if ok and x1 and x2 and x2 > x1 then
                -- route: the zone's footstep cells moved onto the continent
                local steps = {}
                for _, d in pairs(C.days) do
                    local p = WFD:PathCells(d.path[z.id])
                    if p then for k, v in pairs(p) do steps[k] = (steps[k] or 0) + v end end
                end
                local zw, zh = (x2 - x1) * mw, (y2 - y1) * mh
                local cs = max(2, zw / 100 * 1.4)
                for key, v in pairs(steps) do
                    if used >= 5000 then break end
                    used = used + 1
                    local t = cell(used)
                    local cx, cy = floor(key / 100), key % 100
                    t:ClearAllPoints()
                    t:SetPoint("CENTER", mf, "TOPLEFT", x1 * mw + (cx + 0.5) * zw / 100, -(y1 * mh + (cy + 0.5) * zh / 100))
                    t:SetSize(cs, cs)
                    t:SetRotation(pi / 4)
                    t:SetVertexColor(0.55, 0.08, 0.05, min(1, 0.55 + 0.06 * sqrt(v)))
                    t:Show()
                end
                -- a pin in the middle of the region
                np = np + 1
                local p = pin(np)
                local size = z.visited and 12 or 10
                local k = UI.CanRound() and 1 or 0.74
                p:SetSize(size + 2, size + 2)
                p.rim:SetSize(size * k, size * k)
                p.dot:SetSize((size - 3) * k, (size - 3) * k)
                p.dot:SetVertexColor(col4(z.visited and { 0.90, 0.66, 0.16, 1 } or { 0.58, 0.52, 0.44, 1 }))
                p.num:SetText(z.visited and "" or "?")
                p.num:SetFont(UI.FONT, 8, "")
                p.label:SetText(z.visited and z.name or "")
                p.info = z.info
                p.fx, p.fy = (x1 + x2) / 2, (y1 + y2) / 2
                p:SetFrameLevel(mf:GetFrameLevel() + (z.visited and 7 or 6))
                p:SetScale(1)
                p:ClearAllPoints()
                p:SetPoint("CENTER", mf, "TOPLEFT", p.fx * mw, -p.fy * mh)
                p:Show()
            end
        end
        self:LayoutLabels()
    end

    -- the map with small coloured dots: points = { { x, y, col, { tooltip lines }, ring, onClick } }
    -- a ring is drawn hollow (something seen, not had); onClick makes the pin a button
    function box:DrawPoints(mapID, points)
        local mw, mh = drawArt(self, mapID)
        local k = UI.CanRound() and 1 or 0.74
        for i = 1, math.min(#points, 400) do
            local pt = points[i]
            local p = pin(i)
            if pt[5] then
                p:SetSize(12, 12)
                p.rim:SetSize(12 * k, 12 * k)
                p.rim:SetVertexColor(col4(pt[3]))
                p.dot:SetSize(6 * k, 6 * k)
                p.dot:SetVertexColor(0.84, 0.74, 0.56, 1)      -- the map tone: the ring looks hollow
            else
                p:SetSize(14, 14)
                p.rim:SetSize(12 * k, 12 * k)
                p.dot:SetSize(8 * k, 8 * k)
                p.dot:SetVertexColor(col4(pt[3]))
            end
            p.num:SetText("")
            p.info = pt[4]
            p.onClick = pt[6]
            p.fx, p.fy = pt[1], pt[2]
            -- what you had sits above what you only saw
            p:SetFrameLevel(mf:GetFrameLevel() + (pt[5] and 6 or 7))
            p:SetScale(1)
            p:ClearAllPoints()
            p:SetPoint("CENTER", mf, "TOPLEFT", pt[1] * mw, -pt[2] * mh)
            p:Show()
        end
    end

    -- where you stand right now: a small arrow turned the way you face (x, y: 0..1 on the drawn map)
    function box:SetPlayer(x, y, facing)
        local me = rawget(self, "me")
        if not me then
            me = CreateFrame("Frame", nil, mf)
            me:SetSize(22, 22)
            me.glow = UI.Circle(me, 20, { 1, 0.90, 0.55, 0.45 }, "ARTWORK", 0)
            me.glow:SetPoint("CENTER")
            me.arrow = me:CreateTexture(nil, "ARTWORK", nil, 1)
            me.arrow:SetTexture("Interface\\Minimap\\MinimapArrow")
            me.arrow:SetSize(20, 20)
            me.arrow:SetPoint("CENTER")
            me:EnableMouse(true)
            me:SetScript("OnEnter", function(s)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:SetText(L["You are here."], 1, 0.86, 0.5)
                GameTooltip:Show()
            end)
            me:SetScript("OnLeave", function() GameTooltip:Hide() end)
            self.me = me
        end
        if not (x and y) then me:Hide() return end
        me.fx, me.fy = x, y
        if facing and me.arrow.SetRotation then me.arrow:SetRotation(facing) end
        me:SetFrameLevel(mf:GetFrameLevel() + 9)
        me:SetScale(1 / (self.zoom or 1))
        me:ClearAllPoints()
        me:SetPoint("CENTER", mf, "TOPLEFT", x * (self.mw or w) * (self.zoom or 1), -y * (self.mh or h) * (self.zoom or 1))
        me:Show()
    end

    function box:Draw(mapID)
        local mw, mh = drawArt(self, mapID)
        local C = WFD.C
        local steps, kills = {}, {}
        for _, d in pairs(C.days) do
            local p = WFD:PathCells(d.path[mapID])
            if p then for k, v in pairs(p) do steps[k] = (steps[k] or 0) + v end end
            local kc = WFD:PathCells(d.kcells[mapID])
            if kc then for k, v in pairs(kc) do kills[k] = (kills[k] or 0) + v end end
        end
        local cw, ch = mw / 100, mh / 100
        local used = 0
        local function paint(tbl, col, aBase, aScale, grow, rot)
            for key, v in pairs(tbl) do
                if used >= 5000 then return end
                used = used + 1
                local t = cell(used)
                local cx, cy = floor(key / 100), key % 100
                t:ClearAllPoints()
                t:SetPoint("CENTER", mf, "TOPLEFT", (cx + 0.5) * cw, -(cy + 0.5) * ch)
                t:SetSize(cw * grow, ch * grow)
                t:SetRotation(rot or 0)
                t:SetVertexColor(col[1], col[2], col[3], min(1, aBase + aScale * sqrt(v)))
                t:Show()
            end
        end
        paint(steps, { 0.55, 0.08, 0.05 }, 0.45, 0.08, 0.8, pi / 4)
        paint(kills, { 0.16, 0.24, 0.62 }, 0.60, 0.12, 1.3, pi / 4)

        -- pins: the most important places get a number that matches the legend on the page
        local k = UI.CanRound() and 1 or 0.74
        local np = 0
        local legend = {}
        local placed = {}       -- numbered pins already on the map, so close ones can step aside
        local function addPin(x, y, col, infoLines, numbered, grave)
            if np >= 400 then return end
            if numbered then
                for _ = 1, 8 do
                    local clash
                    for _, q in ipairs(placed) do
                        local dx, dy = (x - q[1]) * mw, (y - q[2]) * mh
                        if dx * dx + dy * dy < 17 * 17 then clash = q break end
                    end
                    if not clash then break end
                    local dx, dy = (x - clash[1]) * mw, (y - clash[2]) * mh
                    local d = sqrt(dx * dx + dy * dy)
                    if d < 0.5 then dx, dy, d = 1, -0.6, 1.17 end
                    x = x + dx / d * 18 / mw
                    y = y + dy / d * 18 / mh
                end
                placed[#placed + 1] = { x, y }
            end
            np = np + 1
            local p = pin(np)
            local size = numbered and 18 or (grave and 14 or 9)
            p:SetSize(size + 2, size + 2)
            p.rim:SetSize(size * k, size * k)
            p.dot:SetSize((size - 3) * k, (size - 3) * k)
            p.dot:SetVertexColor(col4(col))
            p.num:SetFont(UI.FONT, 9, "")
            p.info = infoLines
            if numbered then
                legend[#legend + 1] = numbered
                p.num:SetText(tostring(numbered.num))
            else
                p.num:SetText("")
            end
            p.skull:ClearAllPoints()
            if grave and numbered then
                -- the number belongs to the legend: the skull sits on the edge of the pin
                p.skull:SetSize(15 * k, 15 * k)
                p.skull:SetPoint("CENTER", p, "TOPRIGHT", -1, -1)
                p.skull:Show()
            elseif grave then
                p.skull:SetSize((size + 2) * k, (size + 2) * k)
                p.skull:SetPoint("CENTER")
                p.skull:Show()
            else
                p.skull:Hide()
            end
            p:SetFrameLevel(mf:GetFrameLevel() + (numbered and 7 or 6))
            p.fx, p.fy = x, y
            p:SetScale(1)
            p:ClearAllPoints()
            p:SetPoint("CENTER", mf, "TOPLEFT", x * mw, -y * mh)
            p:Show()
        end
        local people = {}
        for key, npc in pairs(C.npcs) do
            if npc.map == mapID and npc.x then people[#people + 1] = { key = key, n = npc } end
        end
        table.sort(people, function(a, b) return (a.n.talks or 0) > (b.n.talks or 0) end)
        for i = #people, 1, -1 do       -- small ones first, numbered ones on top
            local e = people[i]
            addPin(e.n.x, e.n.y, { 0.80, 0.55, 0.12, 1 }, { e.n.name, format(L["Spoken to %d times"], e.n.talks or 0) },
                (i <= 6) and { kind = "npc", key = e.key, name = e.n.name, num = i } or nil)
        end
        local graves = 0
        for i, d in pairs(C.days) do
            -- older graves do not carry their killer: the list of killers only lines up when every death had one
            local aligned = #d.dpos == #d.deathBy and #d.deathBy == (d.deaths or 0)
            for j, pos in ipairs(d.dpos) do
                if pos[1] == mapID then
                    graves = graves + 1
                    local by = pos[4] or (#pos < 4 and aligned and d.deathBy[j]) or nil
                    addPin(pos[2], pos[3], { 0.55, 0.04, 0.04, 1 }, {
                        L["You died here"], by and format(L["Killed by %s"], by) or "", format(L["Day %d"], i),
                    }, (graves <= 2) and { kind = "grave", day = i, by = by, num = math.min(6, #people) + graves } or nil, true)
                end
            end
        end
        -- resting places
        for _, r in ipairs(C.rests or {}) do
            if r.map == mapID and r.x then
                addPin(r.x, r.y, { 1, 0.55, 0.15, 1 }, {
                    L["Rested here"], r.sub ~= "" and r.sub or r.zone or "", r.dur and WFD:DurationText(r.dur) or "",
                })
            end
        end
        -- numbered entries sorted by their number for the legend
        table.sort(legend, function(a, b) return a.num < b.num end)
        return legend
    end

    function box:Ping(x, y)
        -- small red ring around a spot
        if not self.ping then
            self.ping = UI.Circle(mf, 22, { 0.65, 0.08, 0.05, 0.9 }, "OVERLAY")
        end
        self.ping:ClearAllPoints()
        self.ping:SetPoint("CENTER", mf, "TOPLEFT", x * mf:GetWidth(), -y * mf:GetHeight())
        self.ping:Show()
    end

    return box
end


------------------------------------------------------------------------
-- small shared helpers
------------------------------------------------------------------------
function WFD:LongDate(idx)
    return self.loc.longDate(date("*t", self:DayTime(idx)))
end

function WFD:ItemIcon(link)
    local fn = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
    if not (link and fn) then return nil end
    local _, _, _, _, icon = fn(link)
    return icon
end

-- wax seal look for every kind of milestone
UI.SEAL = {
    level    = { col = { 0.78, 0.58, 0.16, 1 }, size = 22 },
    boss     = { col = c.red,    size = 24, icon = "boss" },
    rare     = { col = c.purple, size = 18, icon = "rare" },
    epic     = { col = c.purple, size = 20, icon = "gem" },
    rareitem = { col = c.blue,   size = 17, icon = "gem" },
    death    = { col = c.black,  size = 18, icon = "skull" },
    zone     = { col = c.green,  size = 17, icon = "map" },
    dungeon  = { col = c.orange, size = 19, icon = "key" },
    quest    = { col = c.blue,   size = 16, icon = "quest" },
    wealth   = { col = { 0.70, 0.55, 0.12, 1 }, size = 15, icon = "coin" },
    skill    = { col = c.teal,   size = 15, icon = "skill" },
    kills    = { col = c.grey,   size = 14, icon = "kills" },
    honour   = { col = { 0.78, 0.58, 0.16, 1 }, size = 18, icon = "honour" },
    landmark = { col = c.teal,   size = 17, icon = "sight" },
    challenge = { col = { 0.30, 0.46, 0.18, 1 }, size = 16, icon = "task" },
    weekly   = { col = { 0.30, 0.46, 0.18, 1 }, size = 18, icon = "task" },
    first    = { col = { 0.72, 0.45, 0.22, 1 }, size = 17, icon = "first" },
    capsule  = { col = { 0.55, 0.12, 0.10, 1 }, size = 18, icon = "capsule" },
    catch    = { col = c.teal,   size = 16, icon = "fish" },
}

-- the item of a find: kept with newer moments, looked up by its name in that day's loot for older ones
local function findItem(ev)
    if ev.item then return ev.item end
    local name = ev.s and ev.s:match(":%s*(.+)$")
    local d = name and WFD.C and WFD.C.days[ev.day]
    for id, e in pairs(d and d.loot or {}) do
        if type(e) == "table" and WFD:ItemName(e.link) == name then
            ev.item = tonumber(id)
            return ev.item
        end
    end
end

-- the icon and frame colour of a moment: an honour shows its own icon and metal, a find the item itself
function UI.MomentIcon(ev)
    local def = UI.SEAL[ev.k] or UI.SEAL.quest
    local icon, col = UI.Icon(def.icon), def.col
    if ev.k == "honour" and ev.honour and WFD.HonourDef then
        local h = WFD:HonourDef(ev.honour)
        if h then icon, col = UI.IconPath(h.icon, "honour"), WFD:MetalOf(ev.tier or 1, #h.tiers).col end
    elseif ev.k == "epic" or ev.k == "rareitem" then
        local id = findItem(ev)
        icon = (id and WFD:ItemIcon(id)) or icon
    end
    return icon, col
end

-- trophy icons for the five metals (bronze, silver, gold, mithril, legend)
UI.METAL_ICONS = {
    { "INV_Ingot_Bronze", "INV_Ingot_02", "INV_Misc_Coin_05" },
    { "INV_Ingot_01", "INV_Misc_Coin_03" },
    { "INV_Ingot_03", "INV_Misc_Coin_01" },
    { "INV_Ingot_06", "INV_Misc_Gem_Sapphire_01" },
    { "INV_Misc_Head_Dragon_01", "INV_Misc_Gem_Pearl_05" },
}


-- short caption for each kind of milestone (translated through L)
UI.SEAL_LABEL = {
    level = "Level up", boss = "Boss", rare = "Rare", epic = "Epic find", rareitem = "Rare find",
    death = "Death", zone = "New land", dungeon = "Dungeon", quest = "Quest", wealth = "Wealth",
    skill = "Skill", kills = "Hunt", honour = "Honour", landmark = "Landmark", challenge = "Task of the day",
    weekly = "Task of the week", first = "First time", capsule = "Time capsule", catch = "Catch",
}

------------------------------------------------------------------------
-- Memory painting: the character in the gear worn at that moment,
-- facing the creature of the moment, in a gilded frame.
------------------------------------------------------------------------
function UI.Painting(parent, w, h)
    local f = UI.Frame(parent, w, h)
    UI.Backdrop(f, "gold", 16, 4, { 0, 0, 0, 1 }, { 1, 0.92, 0.75, 1 })
    local sky = UI.GradRect(f, "VERTICAL", { 0.55, 0.45, 0.30, 1 }, { 0.22, 0.24, 0.32, 1 }, "BACKGROUND", 1)
    sky:SetPoint("TOPLEFT", 4, -4)
    sky:SetPoint("BOTTOMRIGHT", -4, 4)
    local ground = UI.GradRect(f, "VERTICAL", { 0.20, 0.14, 0.08, 1 }, { 0.42, 0.33, 0.20, 0 }, "BACKGROUND", 2)
    ground:SetPoint("BOTTOMLEFT", 4, 4)
    ground:SetPoint("BOTTOMRIGHT", -4, 4)
    ground:SetHeight(h * 0.45)
    -- low evening sun, kept inside the frame
    local sun = UI.Circle(f, h * 0.76, { 1, 0.85, 0.55, 0.16 }, "BACKGROUND", 3)
    sun:SetPoint("CENTER", f, "CENTER", 0, h * 0.06)
    local sunCore = UI.Circle(f, h * 0.44, { 1, 0.90, 0.65, 0.16 }, "BACKGROUND", 4)
    sunCore:SetPoint("CENTER", sun, "CENTER")

    f.hero = CreateFrame("DressUpModel", nil, f)
    f.foe = CreateFrame("PlayerModel", nil, f)
    for _, m in ipairs({ f.hero, f.foe }) do m:SetFrameLevel(f:GetFrameLevel() + 2) end

    local vignette = CreateFrame("Frame", nil, f)
    vignette:SetPoint("TOPLEFT", 4, -4)
    vignette:SetPoint("BOTTOMRIGHT", -4, 4)
    vignette:SetFrameLevel(f:GetFrameLevel() + 4)
    for _, e in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
        UI.EdgeFade(vignette, e, 26, { 0.10, 0.06, 0.02 }, 0.55, "OVERLAY")
    end
    f.plaque = UI.Frame(vignette, 160, 18)
    f.plaque:SetPoint("BOTTOM", 0, 6)
    UI.Backdrop(f.plaque, "tooltip", 8, 2, { 0.55, 0.40, 0.14, 1 }, { 1, 0.85, 0.42, 1 })
    f.plaqueText = UI.Text(f.plaque, 10, { 0.12, 0.07, 0.02, 1 }, "CENTER", UI.FONT)
    f.plaqueText:SetPoint("CENTER", 0, 0)
    f.plaqueText:SetWordWrap(false)

    function f:Paint(ev)
        if self.ev == ev then return end
        self.ev = ev
        local alone = not ev.npc
        self.hero:ClearAllPoints()
        self.foe:ClearAllPoints()
        if alone then
            self.hero:SetPoint("TOPLEFT", w * 0.2, -6)
            self.hero:SetPoint("BOTTOMRIGHT", -w * 0.2, 6)
            self.foe:Hide()
        else
            self.hero:SetPoint("TOPLEFT", 6, -6)
            self.hero:SetPoint("BOTTOMRIGHT", self, "BOTTOM", 10, 6)
            self.foe:SetPoint("TOPLEFT", self, "TOP", -10, -6)
            self.foe:SetPoint("BOTTOMRIGHT", -6, 6)
            self.foe:Show()
            UI.LoadCreature(self.foe, ev.npc, nil, nil)
            pcall(self.foe.SetRotation, self.foe, -0.7)
        end
        pcall(function()
            self.hero:SetUnit("player")
            if ev.gear and next(ev.gear) then
                self.hero:Undress()
                for _, id in pairs(ev.gear) do self.hero:TryOn("item:" .. id) end
            end
            self.hero:SetRotation(alone and 0.25 or 0.75)
            -- full figure: the camera steps back (as for the creatures), more in a low frame,
            -- so the head and the feet stay inside the picture
            if self.hero.SetPortraitZoom then self.hero:SetPortraitZoom(0) end
            if self.hero.SetCamDistanceScale then self.hero:SetCamDistanceScale(h < 120 and 1.4 or 1.15) end
            if self.hero.SetPosition then self.hero:SetPosition(0, 0, 0) end
        end)
        -- the plaque names the subject only ("Späherkuppe", not "Landmark discovered: Späherkuppe")
        -- and is never wider than the painting; a long name ends in "..." instead of running over the frame
        local txt = (ev.k ~= "level" and ev.s and ev.s:match(":%s*(.+)$")) or ev.s or ""
        local maxW = w - 30
        self.plaqueText:SetWidth(0)
        self.plaqueText:SetText(txt)
        local pw = math.min(maxW, self.plaqueText:GetStringWidth() + 20)
        self.plaque:SetWidth(pw)
        self.plaqueText:SetWidth(pw - 12)
    end
    return f
end

-- paintings are built for one size: every size gets its own pool kind
function Pool:Painting(w, h)
    local p = self:Get("painting" .. floor(w) .. "x" .. floor(h), function(parent) return UI.Painting(parent, w, h) end)
    return p
end
