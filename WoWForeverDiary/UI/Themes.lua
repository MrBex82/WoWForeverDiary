-- Looks of the book: the dark codex (leather and gold), a modern one (flat slate, blue accent) and one with
-- strong contrast. The palette is changed in place, before anything is drawn, so every page follows it.
-- The size of the writing can be raised as well. Both take effect after reloading the interface.
local ADDON, WFD = ...
local UI = WFD.UI
local c = UI.c

UI.THEMES = { "codex", "modern", "contrast" }
local PALETTES = {
    modern = {
        ink = { 0.94, 0.95, 0.97 }, inkSoft = { 0.74, 0.77, 0.82 }, inkFaint = { 0.56, 0.60, 0.66 },
        redInk = { 0.42, 0.74, 1.00 }, bad = { 0.96, 0.46, 0.43 }, good = { 0.47, 0.86, 0.56 },
        paper = { 0.105, 0.115, 0.135 }, paperDk = { 0.22, 0.24, 0.28 }, paperBurn = { 0, 0, 0 },
        leather = { 0.075, 0.08, 0.095 }, leatherHi = { 0.15, 0.16, 0.19 }, leatherLo = { 0.03, 0.03, 0.04 },
        gold = { 0.62, 0.80, 1.00 }, goldDk = { 0.36, 0.52, 0.72 }, cream = { 0.95, 0.96, 0.98 },
        black = { 0.05, 0.055, 0.065 },
    },
    contrast = {
        ink = { 1, 1, 1 }, inkSoft = { 0.94, 0.92, 0.87 }, inkFaint = { 0.84, 0.81, 0.74 },
        redInk = { 1.00, 0.85, 0.38 }, bad = { 1.00, 0.52, 0.45 }, good = { 0.62, 0.95, 0.55 },
        paper = { 0.06, 0.045, 0.03 }, paperDk = { 0.28, 0.21, 0.14 },
    },
}

function UI.ApplyTheme(name)
    local p = PALETTES[name]
    UI.THEME = p and name or "codex"
    if not p then return end
    for key, col in pairs(p) do
        local t = c[key]
        if t then t[1], t[2], t[3] = col[1], col[2], col[3] end
    end
end

-- a size in points, scaled by the chosen size of the writing. The smallest sizes are raised by a point:
-- captions in 8 and 9 points were hard to read on the dark leather.
function UI.FS(size)
    if size < 10 then size = size + 1 end
    local k = UI.FONT_SCALE or 1
    if k == 1 then return size end
    return math.floor(size * k + 0.5)
end

WFD:On("ADDON_LOADED", function(_, name)
    if name ~= ADDON or not WFD.S then return end
    UI.ApplyTheme(WFD.S.theme)
    UI.FONT_SCALE = WFD.S.fontScale or 1
end)
