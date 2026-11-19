-- The design tokens of the travel desk: every colour, size and distance the new frames use, for each of the four
-- styles. Frames do not keep colours of their own: they paint themselves from UI.T and register with UI.Skin,
-- so a change of style or of the size of the writing repaints everything at once, without reloading.
local ADDON, WFD = ...
local UI = WFD.UI

------------------------------------------------------------------------
-- Colours per style ({ r, g, b } or { r, g, b, a })
------------------------------------------------------------------------
-- frame: the outer rim, edge: its gold line, shell: the desk, panel: register and head bar, card: a card on the
-- desk, inset: a sunken field (tiles, inputs), hover: what the mouse is on or what is open, line: thin rules.
-- gold: the accent, onGold: writing on the accent, title: headings, ink / soft / muted: three levels of writing.
-- pos / neg: gain and loss (always shown with a sign as well), danger: a button that destroys something.
local TOKENS = {
    codex = {
        frame = { 0.110, 0.075, 0.047 }, edge = { 0.54, 0.42, 0.18 }, shell = { 0.165, 0.118, 0.082 },
        panel = { 0.192, 0.137, 0.102 }, card = { 0.227, 0.169, 0.122 }, inset = { 0.149, 0.106, 0.075 },
        hover = { 0.290, 0.212, 0.149 }, line = { 0.83, 0.66, 0.29, 0.26 },
        gold = { 0.83, 0.66, 0.29 }, onGold = { 0.12, 0.08, 0.055 }, title = { 0.925, 0.816, 0.541 },
        ink = { 0.937, 0.890, 0.800 }, soft = { 0.824, 0.753, 0.620 }, muted = { 0.714, 0.639, 0.494 },
        pos = { 0.56, 0.82, 0.54 }, neg = { 0.94, 0.63, 0.44 }, danger = { 0.66, 0.20, 0.12 },
        shade = { 0, 0, 0, 0.55 },
    },
    parchment = {
        frame = { 0.29, 0.196, 0.125 }, edge = { 0.69, 0.54, 0.24 }, shell = { 0.902, 0.839, 0.698 },
        panel = { 0.863, 0.792, 0.627 }, card = { 0.945, 0.898, 0.790 }, inset = { 0.868, 0.796, 0.635 },
        hover = { 0.804, 0.725, 0.541 }, line = { 0.43, 0.31, 0.12, 0.30 },
        gold = { 0.54, 0.35, 0.07 }, onGold = { 0.984, 0.953, 0.863 }, title = { 0.353, 0.212, 0.031 },
        ink = { 0.150, 0.098, 0.047 }, soft = { 0.250, 0.180, 0.110 }, muted = { 0.340, 0.260, 0.170 },
        pos = { 0.18, 0.43, 0.16 }, neg = { 0.66, 0.28, 0.10 }, danger = { 0.60, 0.17, 0.09 },
        shade = { 0.2, 0.12, 0.04, 0.35 },
    },
    modern = {
        frame = { 0.050, 0.055, 0.065 }, edge = { 0.30, 0.36, 0.44 }, shell = { 0.090, 0.100, 0.115 },
        panel = { 0.115, 0.125, 0.145 }, card = { 0.140, 0.150, 0.175 }, inset = { 0.075, 0.080, 0.095 },
        hover = { 0.190, 0.210, 0.250 }, line = { 0.62, 0.80, 1.00, 0.18 },
        gold = { 0.43, 0.66, 0.91 }, onGold = { 0.05, 0.06, 0.08 }, title = { 0.85, 0.92, 1.00 },
        ink = { 0.94, 0.95, 0.97 }, soft = { 0.78, 0.81, 0.86 }, muted = { 0.62, 0.66, 0.72 },
        pos = { 0.47, 0.86, 0.56 }, neg = { 0.96, 0.56, 0.48 }, danger = { 0.72, 0.22, 0.20 },
        shade = { 0, 0, 0, 0.55 },
    },
    contrast = {
        frame = { 0, 0, 0 }, edge = { 1.00, 0.82, 0.23 }, shell = { 0.02, 0.02, 0.02 },
        panel = { 0.06, 0.06, 0.06 }, card = { 0.10, 0.10, 0.10 }, inset = { 0, 0, 0 },
        hover = { 0.22, 0.20, 0.14 }, line = { 1.00, 0.85, 0.30, 0.45 },
        gold = { 1.00, 0.82, 0.23 }, onGold = { 0, 0, 0 }, title = { 1.00, 0.90, 0.50 },
        ink = { 1, 1, 1 }, soft = { 0.94, 0.92, 0.87 }, muted = { 0.84, 0.81, 0.74 },
        pos = { 0.62, 0.95, 0.55 }, neg = { 1.00, 0.62, 0.50 }, danger = { 0.80, 0.18, 0.12 },
        shade = { 0, 0, 0, 0.6 },
    },
}

UI.TOKENS = TOKENS        -- the settings show a sample of every style in its own colours

-- the colours of the groups of the register: the same in every style, they are the colours of the old tabs
UI.GROUP_COLOURS = {
    start = { 0.48, 0.30, 0.16 }, diary = { 0.48, 0.30, 0.16 }, chronicle = { 0.40, 0.20, 0.54 },
    goals = { 0.60, 0.44, 0.09 }, world = { 0.20, 0.42, 0.20 }, hunt = { 0.56, 0.12, 0.08 },
    people = { 0.16, 0.32, 0.54 }, keep = { 0.37, 0.29, 0.20 },
}

-- the current colours: one table that is changed in place, so a closure that reads UI.T.gold always paints
-- in the style that is on now
UI.T = {}
local function copyTokens(name)
    local src = TOKENS[name] or TOKENS.codex
    for k, v in pairs(src) do
        local t = UI.T[k] or {}
        t[1], t[2], t[3], t[4] = v[1], v[2], v[3], v[4] or 1
        UI.T[k] = t
    end
    -- writing on a red danger button: white in every style
    UI.T.white = UI.T.white or { 1, 1, 1, 1 }
    -- writing on the leather of the register, the head bar and the column of a card: the writing of the page,
    -- except in Parchment, where the pages are light but the leather stays dark
    local leather = (name == "parchment") and {
        rail = { 0.93, 0.87, 0.75 }, railSoft = { 0.84, 0.76, 0.62 }, railMuted = { 0.70, 0.62, 0.50 },
        railTitle = { 0.96, 0.82, 0.50 }, railGold = { 0.88, 0.68, 0.30 },
    } or { rail = src.ink, railSoft = src.soft, railMuted = src.muted, railTitle = src.title, railGold = src.gold }
    for k, v in pairs(leather) do
        local t = UI.T[k] or {}
        t[1], t[2], t[3], t[4] = v[1], v[2], v[3], v[4] or 1
        UI.T[k] = t
    end
end
copyTokens("codex")

-- r, g, b, a of a token (a may be lowered by mul)
function UI.Tok(key, mul)
    local t = UI.T[key] or UI.T.ink
    return t[1], t[2], t[3], (t[4] or 1) * (mul or 1)
end

------------------------------------------------------------------------
-- Sizes
------------------------------------------------------------------------
-- distances: 4, 8, 12, 16, 24, 32
-- type roles: size in points (before the size of the writing is applied) and the font
-- (head = the book's display font, body = the text font). Nothing readable is smaller than 11.
UI.TYPE = {
    display = { 26, "head" }, title = { 19, "head" }, heading = { 16, "head" }, section = { 11, "body" },
    value = { 19, "body" }, strong = { 14, "body" }, body = { 13, "body" }, small = { 11, "body" },
}
-- how much bigger than at 100% a size bound to the writing is (never smaller)
function UI.FK() return math.max(1, UI.FONT_SCALE or 1) end

function UI.TypeFont(role)
    local r = UI.TYPE[role] or UI.TYPE.body
    return (r[2] == "head") and UI.HEAD or UI.FONT, UI.FS(r[1])
end

------------------------------------------------------------------------
-- The skin: everything that paints itself from the tokens
------------------------------------------------------------------------
UI.Skin = { list = setmetatable({}, { __mode = "k" }) }

-- obj is painted now and again after every change of style or size of the writing (an object may have
-- several painters: they run in the order they were added)
function UI.Skin.Add(obj, paint)
    local prev = UI.Skin.list[obj]
    UI.Skin.list[obj] = prev and function(o) prev(o) paint(o) end or paint
    paint(obj)
    return obj
end

function UI.Skin.Apply()
    for obj, paint in pairs(UI.Skin.list) do
        local ok, err = pcall(paint, obj)
        if not ok and WFD.Error then WFD:Error("skin", err) end
    end
end

------------------------------------------------------------------------
-- Old drawings that differ by style (the leaves of the book, the leather of its binding): each style is drawn
-- once, the first time it is needed, and then only shown or hidden
------------------------------------------------------------------------
local themed = setmetatable({}, { __mode = "k" })

local function asSet(list)
    local s = {}
    for _, v in ipairs(list) do s[v] = true end
    return s
end

local function paintThemed(frame, entry)
    local cur = UI.THEME or "codex"
    if not entry.parts[cur] then
        -- what the drawing adds to the frame is what is new after it ran
        local regions, children = asSet({ frame:GetRegions() }), asSet({ frame:GetChildren() })
        entry.fn(frame)
        local parts = {}
        for _, r in ipairs({ frame:GetRegions() }) do if not regions[r] then parts[#parts + 1] = r end end
        for _, ch in ipairs({ frame:GetChildren() }) do if not children[ch] then parts[#parts + 1] = ch end end
        entry.parts[cur] = parts
    end
    for name, parts in pairs(entry.parts) do
        for _, p in ipairs(parts) do p:SetShown(name == cur) end
    end
end

-- fn(frame) draws the look of the current style onto frame
function UI.Themed(frame, fn)
    local entry = { fn = fn, parts = {} }
    themed[frame] = entry
    paintThemed(frame, entry)
    return frame
end

------------------------------------------------------------------------
-- Changing the style and the size of the writing, live
------------------------------------------------------------------------
UI.THEME_ORDER = { "codex", "parchment", "modern", "contrast" }

local listeners = {}
-- fn() runs after every change of style or size of the writing (after the skin was painted)
function UI.OnRestyle(fn) listeners[#listeners + 1] = fn end

local function restyled()
    if UI.ClearCaches then UI.ClearCaches() end
    for frame, entry in pairs(themed) do paintThemed(frame, entry) end
    UI.Skin.Apply()
    for _, fn in ipairs(listeners) do
        local ok, err = pcall(fn)
        if not ok and WFD.Error then WFD:Error("restyle", err) end
    end
end

function UI.SetTheme(name)
    if not TOKENS[name] then name = "codex" end
    WFD.S.theme = (name ~= "codex") and name or nil
    UI.ApplyTheme(name)
    copyTokens(name)
    restyled()
end

function UI.SetFontScale(k)
    WFD.S.fontScale = (k ~= 1) and k or nil
    UI.FONT_SCALE = k
    restyled()
end

WFD:On("ADDON_LOADED", function(_, name)
    if name ~= ADDON or not WFD.S then return end
    copyTokens(WFD.S.theme or "codex")
end)
