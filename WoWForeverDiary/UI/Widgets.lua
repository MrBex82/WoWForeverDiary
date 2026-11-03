-- Design kit: leather, parchment, ink, gold leaf and wax seals.
-- Every Blizzard texture is checked for existence first, so a missing file never shows up as a green box.
local ADDON, WFD = ...
local UI = {}
WFD.UI = UI

local floor, max, min, pi = math.floor, math.max, math.min, math.pi
local BT = BackdropTemplateMixin and "BackdropTemplate" or nil
local WHITE = "Interface\\Buttons\\WHITE8X8"

UI.WHITE = WHITE
-- the painted leaf behind every page (Media\page.tga, made by tools/gen_page.lua)
UI.PAGE_ART = "Interface\\AddOns\\" .. ADDON .. "\\Media\\page"
-- the coarser leather of the binding (Media\binding.tga, same tool, style "binding")
UI.BINDING_ART = "Interface\\AddOns\\" .. ADDON .. "\\Media\\binding"
UI.BT = BT
UI.FONT = "Fonts\\FRIZQT__.TTF"
UI.HEAD = "Fonts\\MORPHEUS.TTF"
UI.DECO = "Fonts\\SKURRI.TTF"

-- Friz, Morpheus and Skurri only carry Latin glyphs: Cyrillic and CJK text needs other fonts
-- ({ body, heading, decoration }). A font missing from this game client falls back to the game font.
local SCRIPT_FONTS = {
    ruRU = { "Fonts\\FRIZQT___CYR.TTF", "Fonts\\MORPHEUS_CYR.TTF", "Fonts\\SKURRI_CYR.TTF" },
    koKR = { "Fonts\\2002.TTF", "Fonts\\2002B.TTF", "Fonts\\2002.TTF" },
    zhTW = { "Fonts\\bLEI00D.ttf", "Fonts\\bLEI00D.ttf", "Fonts\\bHEI01B.TTF" },
}

-- Called by Core once the diary language is known (ADDON_LOADED).
function UI.ApplyScriptFonts(language)
    local alt = SCRIPT_FONTS[language] or { UI.FONT, UI.HEAD, UI.DECO }
    local probe = UIParent:CreateFontString()
    local function pick(path) return (probe:SetFont(path, 12, "") ~= false) and path or STANDARD_TEXT_FONT end
    UI.FONT, UI.HEAD, UI.DECO = pick(alt[1]), pick(alt[2]), pick(alt[3])
end

------------------------------------------------------------------------
-- Palette
------------------------------------------------------------------------
-- "Dark codex": pages of dark leather, cream text, gold accents. The names keep their roles:
-- ink = main text, inkSoft / inkFaint = quieter text, redInk = the accent (gold), bad / good = loss and gain.
UI.c = {
    ink       = { 0.96, 0.90, 0.78, 1 },
    inkSoft   = { 0.87, 0.78, 0.62, 1 },
    inkFaint  = { 0.76, 0.67, 0.53, 1 },
    redInk    = { 0.91, 0.76, 0.42, 1 },
    bad       = { 0.89, 0.47, 0.38, 1 },
    good      = { 0.58, 0.80, 0.45, 1 },
    paper     = { 0.150, 0.105, 0.068, 1 },
    paperDk   = { 0.34, 0.25, 0.16, 1 },
    paperBurn = { 0.02, 0.01, 0.00, 1 },
    leather   = { 0.17, 0.085, 0.05, 1 },
    leatherHi = { 0.31, 0.16, 0.09, 1 },
    leatherLo = { 0.08, 0.04, 0.02, 1 },
    gold      = { 1.00, 0.82, 0.38, 1 },
    goldDk    = { 0.70, 0.52, 0.20, 1 },
    cream     = { 1.00, 0.94, 0.80, 1 },
    red       = { 0.60, 0.10, 0.08, 1 },
    green     = { 0.20, 0.44, 0.15, 1 },
    blue      = { 0.16, 0.32, 0.58, 1 },
    purple    = { 0.46, 0.18, 0.60, 1 },
    orange    = { 0.78, 0.42, 0.08, 1 },
    teal      = { 0.12, 0.44, 0.44, 1 },
    grey      = { 0.36, 0.34, 0.33, 1 },
    black     = { 0.10, 0.07, 0.05, 1 },
}
local c = UI.c

local function col4(t, a) return t[1], t[2], t[3], a or t[4] or 1 end
UI.col4 = col4

------------------------------------------------------------------------
-- Texture availability
------------------------------------------------------------------------
-- Paths seen working in other Classic addons on this machine.
local TRUSTED = {
    ["interface\\buttons\\white8x8"] = true,
    ["interface\\tooltips\\ui-tooltip-border"] = true,
    ["interface\\tooltips\\ui-tooltip-background"] = true,
    ["interface\\dialogframe\\ui-dialogbox-border"] = true,
    ["interface\\dialogframe\\ui-dialogbox-gold-border"] = true,
    ["interface\\dialogframe\\ui-dialogbox-header"] = true,
    ["interface\\dialogframe\\ui-dialogbox-background-dark"] = true,
    ["interface\\buttons\\ui-checkbox-check"] = true,
    ["interface\\buttons\\ui-common-mousehilight"] = true,
    ["interface\\buttons\\ui-spellbookicon-prevpage-up"] = true,
    ["interface\\buttons\\ui-spellbookicon-nextpage-up"] = true,
    ["interface\\buttons\\ui-spellbookicon-prevpage-down"] = true,
    ["interface\\buttons\\ui-spellbookicon-nextpage-down"] = true,
}

local hasCache = {}
function UI.Has(path)
    if not path then return false end
    local v = hasCache[path]
    if v ~= nil then return v end
    if TRUSTED[path:lower()] then
        v = true
    elseif GetFileIDFromPath then
        local ok, id = pcall(GetFileIDFromPath, path)
        v = (ok and id and id ~= 0) and true or false
    else
        v = true    -- cannot check on this client: trust the first candidate
    end
    hasCache[path] = v
    return v
end

function UI.Pick(list)
    for _, p in ipairs(list) do
        if UI.Has(p) then return p end
    end
end

local I = "Interface\\Icons\\"
UI.ICONS = {
    journal  = { I .. "INV_Misc_Book_09", I .. "INV_Misc_Book_11" },
    map      = { I .. "INV_Misc_Map_01", I .. "INV_Misc_Map02" },
    bestiary = { I .. "INV_Misc_Bone_HumanSkull_01", I .. "Ability_Hunter_BeastTaming" },
    people   = { I .. "Ability_Warrior_RallyingCry", I .. "Spell_Holy_PrayerOfFortitude", I .. "INV_Misc_Note_01" },
    quests   = { I .. "INV_Scroll_03", I .. "INV_Misc_Note_01" },
    stats    = { I .. "INV_Misc_Coin_01", I .. "INV_Misc_Coin_02" },
    export   = { I .. "INV_Letter_15", I .. "INV_Scroll_05", I .. "INV_Misc_Note_01" },
    kills    = { I .. "INV_Sword_04", I .. "Ability_Warrior_Charge" },
    skull    = { I .. "INV_Misc_Bone_HumanSkull_01" },
    boss     = { I .. "INV_Misc_Head_Dragon_01", I .. "INV_Misc_Bone_HumanSkull_01" },
    rare     = { I .. "Ability_Hunter_SniperShot", I .. "Ability_Hunter_MarkedForDeath", I .. "INV_Misc_Gem_Pearl_05" },
    xp       = { I .. "Spell_Holy_HolyBolt", I .. "Spell_Holy_SurgeOfLight" },
    level    = { I .. "Spell_Holy_SurgeOfLight", I .. "Spell_Holy_HolyBolt" },
    coin     = { I .. "INV_Misc_Coin_01" },
    time     = { I .. "INV_Misc_PocketWatch_01", I .. "Spell_Nature_TimeStop" },
    steps    = { I .. "Ability_Tracking", I .. "Ability_Rogue_Sprint" },
    jump     = { I .. "Ability_Rogue_Sprint", I .. "Ability_Tracking" },
    quest    = { I .. "INV_Scroll_03" },
    gem      = { I .. "INV_Misc_Gem_Variety_01", I .. "INV_Misc_Gem_Pearl_05" },
    key      = { I .. "INV_Misc_Key_03", I .. "INV_Misc_Key_04" },
    skill    = { I .. "Trade_Mining", I .. "INV_Pick_02" },
    hearth   = { I .. "INV_Misc_Rune_01" },
    loot     = { I .. "INV_Misc_Bag_08", I .. "INV_Misc_Bag_10" },
    talk     = { I .. "INV_Letter_15", I .. "INV_Misc_Note_01" },
    days     = { I .. "INV_Misc_Book_09" },
    honour   = { I .. "INV_Misc_Ribbon_01", I .. "Spell_Holy_SurgeOfLight" },
    sight    = { I .. "INV_Misc_Spyglass_03", I .. "INV_Misc_Spyglass_02", I .. "INV_Misc_Map_01" },
    task     = { I .. "INV_Misc_Note_02", I .. "INV_Misc_Note_01" },
    records  = { I .. "INV_Misc_Book_11", I .. "INV_Misc_Book_09" },
    nemesis  = { I .. "INV_Misc_Bone_HumanSkull_01" },
    gallery  = { I .. "INV_Misc_Toy_07", I .. "INV_Chest_Cloth_17", I .. "INV_Misc_Book_09" },
    runs     = { I .. "INV_Misc_Key_04", I .. "INV_Misc_Key_03" },
    first    = { I .. "INV_Misc_Note_06", I .. "INV_Misc_Note_02", I .. "INV_Misc_Book_09" },
    capsule  = { I .. "INV_Letter_15", I .. "INV_Scroll_05", I .. "INV_Misc_Note_01" },
    family   = { I .. "Spell_Holy_PrayerOfFortitude", I .. "Ability_Warrior_RallyingCry" },
    gather   = { I .. "Trade_Herbalism", I .. "INV_Misc_Flower_02", I .. "Trade_Mining" },
    fish     = { I .. "INV_Misc_Fish_02", I .. "Trade_Fishing", I .. "INV_Misc_Fish_03" },
    search   = { I .. "INV_Misc_Spyglass_02", I .. "INV_Misc_Spyglass_03" },
    -- the bookmarks
    quill    = { I .. "INV_Feather_05", I .. "INV_Misc_Book_11" },
    album    = { I .. "INV_Misc_Gem_Variety_01", I .. "INV_Misc_Gem_Pearl_05" },
    atlas    = { I .. "INV_Misc_Map02", I .. "INV_Misc_Spyglass_02" },
    beast    = { I .. "Ability_Hunter_BeastTaming", I .. "INV_Misc_Bone_HumanSkull_01" },
    party    = { I .. "Spell_Holy_PrayerOfFortitude", I .. "Ability_Warrior_RallyingCry" },
    kin      = { I .. "Spell_Holy_DivineSpirit", I .. "INV_Misc_Book_04" },
    settings = { I .. "INV_Misc_Gear_01", I .. "Trade_Engineering" },
}

function UI.Icon(key)
    local list = UI.ICONS[key]
    -- never nil: the result is joined into texture strings ("|T" .. icon .. "|t")
    return list and UI.Pick(list) or UI.Pick(UI.ICONS.journal) or UI.ICONS.journal[1]
end

-- first existing icon of a list of bare icon names ("INV_Misc_Map_01"), else an icon key
function UI.IconPath(list, fallback)
    local paths = {}
    for _, n in ipairs(list or {}) do paths[#paths + 1] = I .. n end
    return UI.Pick(paths) or UI.Icon(fallback or "journal")
end

-- money with coin icons, short: gold and silver, or silver and copper
function UI.CoinIcons(copper, size)
    copper = floor(math.abs(copper or 0))
    size = size or 11
    local function coin(kind) return "|TInterface\\MoneyFrame\\UI-" .. kind .. "Icon:" .. size .. ":" .. size .. ":1:0|t" end
    local g, s, k = floor(copper / 10000), floor((copper % 10000) / 100), copper % 100
    if g > 0 then return g .. coin("Gold") .. (s > 0 and (" " .. s .. coin("Silver")) or "") end
    if s > 0 then return s .. coin("Silver") .. (k > 0 and (" " .. k .. coin("Copper")) or "") end
    return k .. coin("Copper")
end

------------------------------------------------------------------------
-- Basic painting
------------------------------------------------------------------------
function UI.Tex(parent, layer, sub)
    local t = parent:CreateTexture(nil, layer or "ARTWORK", nil, sub or 0)
    t:SetTexture(WHITE)
    return t
end

function UI.Rect(parent, r, g, b, a, layer, sub)
    local t = UI.Tex(parent, layer, sub)
    t:SetVertexColor(r, g, b, a or 1)
    return t
end

function UI.Fill(parent, col, layer, sub, a)
    local t = UI.Tex(parent, layer, sub)
    t:SetVertexColor(col4(col, a))
    return t
end

-- from = bottom / left colour, to = top / right colour
function UI.Gradient(t, orient, from, to)
    t:SetTexture(WHITE)
    t:SetVertexColor(1, 1, 1, 1)
    if CreateColor then
        local ok = pcall(t.SetGradient, t, orient, CreateColor(col4(from)), CreateColor(col4(to)))
        if ok then return t end
    end
    if t.SetGradientAlpha then
        local ok = pcall(t.SetGradientAlpha, t, orient,
            from[1], from[2], from[3], from[4] or 1, to[1], to[2], to[3], to[4] or 1)
        if ok then return t end
    end
    t:SetVertexColor((from[1] + to[1]) / 2, (from[2] + to[2]) / 2, (from[3] + to[3]) / 2, ((from[4] or 1) + (to[4] or 1)) / 2)
    return t
end

function UI.GradRect(parent, orient, from, to, layer, sub)
    return UI.Gradient(UI.Tex(parent, layer, sub), orient, from, to)
end

-- Soft fade along one inside edge of a frame (used for burnt paper edges, shadows, sheen)
function UI.EdgeFade(parent, edge, size, col, alpha, layer, sub, inset)
    local t = UI.Tex(parent, layer or "BORDER", sub)
    local i = inset or 0
    local solid = { col[1], col[2], col[3], alpha }
    local clear = { col[1], col[2], col[3], 0 }
    if edge == "TOP" then
        t:SetPoint("TOPLEFT", i, -i); t:SetPoint("TOPRIGHT", -i, -i); t:SetHeight(size)
        UI.Gradient(t, "VERTICAL", clear, solid)
    elseif edge == "BOTTOM" then
        t:SetPoint("BOTTOMLEFT", i, i); t:SetPoint("BOTTOMRIGHT", -i, i); t:SetHeight(size)
        UI.Gradient(t, "VERTICAL", solid, clear)
    elseif edge == "LEFT" then
        t:SetPoint("TOPLEFT", i, -i); t:SetPoint("BOTTOMLEFT", i, i); t:SetWidth(size)
        UI.Gradient(t, "HORIZONTAL", solid, clear)
    else
        t:SetPoint("TOPRIGHT", -i, -i); t:SetPoint("BOTTOMRIGHT", -i, i); t:SetWidth(size)
        UI.Gradient(t, "HORIZONTAL", clear, solid)
    end
    return t
end

------------------------------------------------------------------------
-- Round shapes (mask), with a diamond fallback
------------------------------------------------------------------------
local maskPath
function UI.CanRound()
    if maskPath == nil then
        maskPath = UI.Pick({
            "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask",
            "Interface\\CharacterFrame\\TempPortraitAlphaMask",
        }) or false
        if not (UIParent.CreateMaskTexture) then maskPath = false end
    end
    return maskPath and true or false
end

function UI.Round(t, owner)
    if not UI.CanRound() or not t.AddMaskTexture then return false end
    local m = owner.CreateMaskTexture and owner:CreateMaskTexture()
    if not m then return false end
    m:SetTexture(maskPath, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    m:SetAllPoints(t)
    t:AddMaskTexture(m)
    return true
end

function UI.Circle(parent, size, col, layer, sub)
    local t = UI.Fill(parent, col, layer, sub)
    t:SetSize(size, size)
    if not UI.Round(t, parent) then
        t:SetRotation(pi / 4)
        t:SetSize(size * 0.74, size * 0.74)
    end
    return t
end

function UI.Diamond(parent, size, col, layer, sub)
    local t = UI.Fill(parent, col, layer, sub)
    t:SetSize(size, size)
    t:SetRotation(pi / 4)
    return t
end

------------------------------------------------------------------------
-- Text
------------------------------------------------------------------------
function UI.Text(parent, size, color, justify, font, shadow)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    size = UI.FS and UI.FS(size or 12) or (size or 12)
    if fs:SetFont(font or UI.FONT, size, "") == false then
        fs:SetFont(UI.FONT, size, "")
    end
    fs:SetTextColor(col4(color or c.ink))
    fs:SetJustifyH(justify or "LEFT")
    if shadow then
        fs:SetShadowColor(0, 0, 0, 0.85)
        fs:SetShadowOffset(1, -1)
    else
        fs:SetShadowOffset(0, 0)
    end
    return fs
end

-- Shrinks a one-line text until it fits maxW (never below minSize), so titles fit in every language.
function UI.FitText(fs, maxW, size, minSize, font)
    font = font or UI.HEAD
    if UI.FS then size, minSize = UI.FS(size), minSize and UI.FS(minSize) end
    local s = size
    fs:SetFont(font, s, "")
    -- the unbounded width ignores a width the string may already have been given
    local function width() return (fs.GetUnboundedStringWidth and fs:GetUnboundedStringWidth() or fs:GetStringWidth()) or 0 end
    while s > (minSize or 10) and width() > maxW do
        s = s - 1
        fs:SetFont(font, s, "")
    end
    return s
end

-- capitals read well for a short heading only: a sentence keeps its own letters
function UI.Upper(text)
    text = text or ""
    local words = 0
    for _ in text:gmatch("%S+") do words = words + 1 end
    return words <= 3 and text:upper() or text
end

-- small caps-ish label: upper case, small, spaced
function UI.Caps(parent, text, size, color, font)
    local fs = UI.Text(parent, size or 10, color or c.inkFaint, "LEFT", font or UI.FONT)
    fs:SetText(text and text:upper() or "")
    return fs
end

------------------------------------------------------------------------
-- Frames and Blizzard edges
------------------------------------------------------------------------
UI.EDGE = {
    tooltip = "Interface\\Tooltips\\UI-Tooltip-Border",
    dialog  = "Interface\\DialogFrame\\UI-DialogBox-Border",
    gold    = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
}

function UI.Frame(parent, w, h, kind)
    local f = CreateFrame(kind or "Frame", nil, parent, BT)
    if w then f:SetSize(w, h) end
    return f
end

function UI.Backdrop(f, edge, edgeSize, inset, bg, border)
    if not f.SetBackdrop then return end
    f:SetBackdrop({
        bgFile = WHITE,
        edgeFile = edge and UI.EDGE[edge] or WHITE,
        edgeSize = edgeSize or 1,
        insets = { left = inset or 0, right = inset or 0, top = inset or 0, bottom = inset or 0 },
    })
    f:SetBackdropColor(col4(bg or { 0, 0, 0, 0 }))
    f:SetBackdropBorderColor(col4(border or { 1, 1, 1, 1 }))
end

------------------------------------------------------------------------
-- Parchment
------------------------------------------------------------------------
-- Subtle tiled grain from a Blizzard background texture (skipped if none exists).
local GRAIN = {
    "Interface\\FrameGeneral\\UI-Background-Marble",
    "Interface\\FrameGeneral\\UI-Background-Rock",
}
function UI.Grain(parent, col, alpha, layer, sub, inset)
    local path = UI.Pick(GRAIN)
    if not path or not GetFileIDFromPath then return end
    local t = parent:CreateTexture(nil, layer or "BACKGROUND", nil, sub or 0)
    t:SetTexture(path, "REPEAT", "REPEAT")
    if t.SetHorizTile then t:SetHorizTile(true); t:SetVertTile(true) end
    t:SetDesaturated(true)
    t:SetVertexColor(col[1], col[2], col[3], alpha)
    t:SetBlendMode("BLEND")
    local i = inset or 0
    t:SetPoint("TOPLEFT", i, -i)
    t:SetPoint("BOTTOMRIGHT", -i, i)
    return t
end

-- One of our seamless 512px textures, repeated at its own size over the parent (minus inset).
-- Returns nil when the file is not there (e.g. added without restarting the game).
function UI.TiledArt(parent, path, layer, sub, inset)
    local t = parent:CreateTexture(nil, layer or "BACKGROUND", nil, sub or 0)
    if t:SetTexture(path, "REPEAT", "REPEAT") == false then
        t:Hide()
        return nil
    end
    local i = inset or 0
    t:SetPoint("TOPLEFT", i, -i)
    t:SetPoint("BOTTOMRIGHT", -i, i)
    local function fit()
        local pw, ph = parent:GetSize()
        t:SetTexCoord(0, max(1, (pw or 0) - 2 * i) / 512, 0, max(1, (ph or 0) - 2 * i) / 512)
    end
    fit()
    parent:HookScript("OnSizeChanged", fit)
    return t
end

-- Dark binding leather: the painted texture shaded top to bottom, or a gradient with grain without it.
function UI.Leather(parent, inset, sub, grain)
    sub = sub or 1
    if UI.THEME == "modern" then
        local g = UI.GradRect(parent, "VERTICAL", c.leatherLo, c.leatherHi, "BACKGROUND", sub)
        g:SetPoint("TOPLEFT", inset or 0, -(inset or 0))
        g:SetPoint("BOTTOMRIGHT", -(inset or 0), inset or 0)
        return
    end
    local art = UI.TiledArt(parent, UI.BINDING_ART, "BACKGROUND", sub, inset)
    if art then
        -- light falls from above: the lower part a little darker
        local shade = UI.GradRect(parent, "VERTICAL", { 0, 0, 0, 0.45 }, { 0, 0, 0, 0 }, "BACKGROUND", sub + 1)
        shade:SetPoint("TOPLEFT", inset or 0, -(inset or 0))
        shade:SetPoint("BOTTOMRIGHT", -(inset or 0), inset or 0)
        return art
    end
    local g = UI.GradRect(parent, "VERTICAL", c.leatherLo, c.leatherHi, "BACKGROUND", sub)
    g:SetPoint("TOPLEFT", inset or 0, -(inset or 0))
    g:SetPoint("BOTTOMRIGHT", -(inset or 0), inset or 0)
    UI.Grain(parent, { 0.55, 0.32, 0.18 }, grain or 0.30, "BACKGROUND", sub + 1, inset)
end

-- An aged parchment page. spine = "left" or "right": the edge that bends into the book.
function UI.Page(parent, w, h, spine)
    local p = UI.Frame(parent, w, h)
    local base = UI.Fill(p, c.paper, "BACKGROUND", 0)
    base:SetAllPoints()
    if UI.THEME == "modern" then
        -- a calm flat sheet: a faint light from above, a soft shadow into the spine, a thin outline
        local light = UI.GradRect(p, "VERTICAL", { 1, 1, 1, 0 }, { 1, 1, 1, 0.035 }, "BACKGROUND", 1)
        light:SetAllPoints()
        if spine then UI.EdgeFade(p, spine == "left" and "LEFT" or "RIGHT", 40, { 0, 0, 0 }, 0.45, "BORDER", 1) end
        local frame = UI.Frame(p)
        frame:SetAllPoints()
        UI.Backdrop(frame, nil, 1, 0, { 0, 0, 0, 0 }, { 1, 1, 1, 0.07 })
        return p
    end
    if UI.THEME == "parchment" then
        -- the quest paper of the game itself (Interface\QuestFrame\QuestBG): one sheet with its torn border all
        -- round, the rest of the picture is transparent. There is no base colour, so the binding shows through
        -- behind the tears. At the spine the sheet is cut straight (that edge is bound, not torn).
        base:SetAlpha(0)
        -- The torn edges of the sheet are strongest at its foot and on its right, weak at the top and the left:
        -- so the page is four quarters, every one of them the lower right quarter of the sheet, mirrored as
        -- needed. Then all four edges look like the strong ones.
        local MID_U, MID_V, END_U, END_V, CUT_U = 0.293, 0.327, 0.586, 0.654, 0.55
        local rightU = (spine == "right") and CUT_U or END_U     -- the spine side is cut straight, not torn
        local leftU = (spine == "left") and CUT_U or END_U
        local hw, hh = w / 2, h / 2
        local quarters = {
            { "TOPLEFT", 0, 0, leftU, MID_U, END_V, MID_V },
            { "TOPRIGHT", hw, 0, MID_U, rightU, END_V, MID_V },
            { "BOTTOMLEFT", 0, -hh, leftU, MID_U, MID_V, END_V },
            { "BOTTOMRIGHT", hw, -hh, MID_U, rightU, MID_V, END_V },
        }
        for _, qd in ipairs(quarters) do
            local q = p:CreateTexture(nil, "BACKGROUND", nil, 1)
            q:SetTexture("Interface\\QuestFrame\\QuestBG")
            q:SetTexCoord(qd[4], qd[5], qd[6], qd[7])
            q:SetSize(hw, hh)
            q:SetPoint("TOPLEFT", p, "TOPLEFT", qd[2], qd[3])
        end
        -- the bend into the spine
        if spine then
            UI.EdgeFade(p, spine == "left" and "LEFT" or "RIGHT", 70, { 0, 0, 0 }, 0.38, "BORDER", 1)
            UI.EdgeFade(p, spine == "left" and "LEFT" or "RIGHT", 6, { 0, 0, 0 }, 0.45, "BORDER", 2)
        end
        return p
    end
    -- the painted leaf (Media\page.tga, seamless), repeated at its own size; grain drawn by hand without it
    local hasLeaf = UI.TiledArt(p, UI.PAGE_ART, "BACKGROUND", 1) ~= nil
    -- a little warmer light in the middle of the leaf
    local glow = UI.GradRect(p, "VERTICAL", { 0.05, 0.03, 0.02, 0.35 }, { 0.36, 0.25, 0.15, 0.30 }, "BACKGROUND", 2)
    glow:SetAllPoints()
    -- leather grain
    if not hasLeaf then UI.Grain(p, { 0.55, 0.38, 0.22 }, 0.18, "BACKGROUND", 3) end
    -- strong contrast: the leaf darkened, so the writing stands out
    if UI.THEME == "contrast" then
        local dim = UI.Fill(p, { 0, 0, 0 }, "BACKGROUND", 4, 0.45)
        dim:SetAllPoints()
    end
    -- darkened edges
    local k = min(1, h / 300)
    local edge = 1
    UI.EdgeFade(p, "TOP", max(8, 34 * k), c.paperBurn, 0.45 * max(0.6, k) * edge, "BORDER", 0)
    UI.EdgeFade(p, "BOTTOM", max(8, 40 * k), c.paperBurn, 0.55 * max(0.6, k) * edge, "BORDER", 0)
    UI.EdgeFade(p, spine == "left" and "RIGHT" or "LEFT", 38, c.paperBurn, 0.50 * edge, "BORDER", 0)
    if not spine then UI.EdgeFade(p, "RIGHT", 38, c.paperBurn, 0.50 * edge, "BORDER", 0) end
    -- the bend into the spine
    if spine then
        UI.EdgeFade(p, spine == "left" and "LEFT" or "RIGHT", 70, { 0, 0, 0 }, 0.60, "BORDER", 1)
        UI.EdgeFade(p, spine == "left" and "LEFT" or "RIGHT", 6, { 0, 0, 0 }, 0.7, "BORDER", 2)
    end
    -- thin gold hairline inside the edge, and a dark outline
    if h >= 120 then
        local gild = UI.Frame(p)
        gild:SetPoint("TOPLEFT", 10, -10)
        gild:SetPoint("BOTTOMRIGHT", -10, 10)
        UI.Backdrop(gild, nil, 1, 0, { 0, 0, 0, 0 }, { 0.78, 0.60, 0.26, 0.22 })
    end
    local frame = UI.Frame(p)
    frame:SetAllPoints()
    UI.Backdrop(frame, nil, 1, 0, { 0, 0, 0, 0 }, { 0, 0, 0, 0.85 })
    return p
end

-- Dark inset with a gold edge (frames, model boxes)
function UI.Inset(parent, w, h)
    local f = UI.Frame(parent, w, h)
    UI.Backdrop(f, "tooltip", 12, 3, { 0.07, 0.05, 0.03, 0.85 }, { 0.78, 0.60, 0.26, 0.9 })
    return f
end

------------------------------------------------------------------------
-- Ornaments
------------------------------------------------------------------------
-- A small count badge: a capsule with a fine coloured ring, a dark inside and a light number.
-- It grows sideways with the number ("2", "12", "1.2k"); without round masks it becomes a framed tag.
function UI.CountBadge(parent, h)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(h, h)
    local round = UI.CanRound()
    local function part(sub)
        local t = { }
        if round then
            t.l = UI.Circle(f, h, c.gold, "ARTWORK", sub)
            t.r = UI.Circle(f, h, c.gold, "ARTWORK", sub)
        end
        t.m = UI.Fill(f, c.gold, "ARTWORK", sub)
        return t
    end
    f.ring = part(0)
    f.inner = part(1)
    f.shine = UI.GradRect(f, "VERTICAL", { 1, 1, 1, 0 }, { 1, 1, 1, 0.10 }, "ARTWORK", 2)
    f.text = UI.Text(f, max(8, floor(h * 0.55)), { 1, 0.95, 0.82, 1 }, "CENTER", UI.FONT, true)
    f.text:SetPoint("CENTER", 0, 0)

    local function lay(t, w, hh, inset)
        local r = hh / 2
        if round then
            t.l:SetSize(hh, hh)
            t.l:ClearAllPoints()
            t.l:SetPoint("CENTER", f, "LEFT", inset + r, 0)
            t.r:SetSize(hh, hh)
            t.r:ClearAllPoints()
            t.r:SetPoint("CENTER", f, "RIGHT", -inset - r, 0)
            t.m:ClearAllPoints()
            t.m:SetPoint("TOPLEFT", f, "LEFT", inset + r, r)
            t.m:SetSize(max(0, w - 2 * inset - 2 * r), hh)
        else
            t.m:ClearAllPoints()
            t.m:SetPoint("TOPLEFT", f, "TOPLEFT", inset, -inset)
            t.m:SetSize(w - 2 * inset, hh)
        end
    end

    function f:SetCount(text, col)
        col = col or c.gold
        self.text:SetText(text or "")
        local w = max(h, floor(self.text:GetStringWidth() + h * 0.7 + 0.5))
        self:SetWidth(w)
        lay(self.ring, w, h, 0)
        lay(self.inner, w, h - 2, 1)
        for _, k in ipairs({ "l", "r", "m" }) do
            if self.ring[k] then self.ring[k]:SetVertexColor(col[1], col[2], col[3], 1) end
            if self.inner[k] then self.inner[k]:SetVertexColor(0.09, 0.06, 0.035, 1) end
        end
        self.shine:ClearAllPoints()
        self.shine:SetPoint("TOPLEFT", self, "TOPLEFT", h / 3, -1)
        self.shine:SetPoint("TOPRIGHT", self, "TOPRIGHT", -h / 3, -1)
        self.shine:SetHeight(h / 2 - 1)
    end
    f:SetCount("")
    return f
end

-- "Shiny", as with a rare Pokemon: now and then a band of light sweeps over the picture, and a few small
-- stars twinkle. f:SetShiny(on, colour) turns it on; the animation runs only while it is shown.
local STARS = { { 0.18, 0.28, 0 }, { 0.82, 0.22, 1.7 }, { 0.70, 0.76, 3.1 }, { 0.30, 0.72, 4.4 } }
function UI.Shiny(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetAllPoints()
    f:SetFrameLevel(parent:GetFrameLevel() + 5)
    if f.SetClipsChildren then f:SetClipsChildren(true) end
    f.band = {
        UI.GradRect(f, "HORIZONTAL", { 1, 1, 1, 0 }, { 1, 1, 1, 0.40 }, "OVERLAY", 1),
        UI.GradRect(f, "HORIZONTAL", { 1, 1, 1, 0.40 }, { 1, 1, 1, 0 }, "OVERLAY", 1),
    }
    for _, b in ipairs(f.band) do b:SetWidth(16) end
    f.stars = {}
    for i, s in ipairs(STARS) do
        local h = UI.Fill(f, { 1, 1, 1 }, "OVERLAY", 2)
        h:SetSize(11, 1)
        local v = UI.Fill(f, { 1, 1, 1 }, "OVERLAY", 2)
        v:SetSize(1, 11)
        local d = UI.Diamond(f, 4, { 1, 1, 1 }, "OVERLAY", 3)
        f.stars[i] = { h = h, v = v, d = d, fx = s[1], fy = s[2], ph = s[3] }
    end
    f.t = 0
    f:SetScript("OnUpdate", function(self, dt)
        self.t = self.t + dt
        local w, h = self:GetWidth(), self:GetHeight()
        local p = (self.t % 3.6) / 1.1                  -- the sweep takes a little over a second, then it rests
        local b1, b2 = self.band[1], self.band[2]
        if p < 1 then
            local x = -34 + (w + 34) * p
            b1:ClearAllPoints()
            b1:SetPoint("TOPLEFT", self, "TOPLEFT", x, 0)
            b1:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", x, 0)
            b2:ClearAllPoints()
            b2:SetPoint("TOPLEFT", b1, "TOPRIGHT", 0, 0)
            b2:SetPoint("BOTTOMLEFT", b1, "BOTTOMRIGHT", 0, 0)
            b1:Show()
            b2:Show()
        else
            b1:Hide()
            b2:Hide()
        end
        for _, s in ipairs(self.stars) do
            local a = math.sin(self.t * 2.2 + s.ph)
            a = a > 0 and a * a * a or 0
            for _, k in ipairs({ "h", "v", "d" }) do
                s[k]:ClearAllPoints()
                s[k]:SetPoint("CENTER", self, "TOPLEFT", s.fx * w, -s.fy * h)
                s[k]:SetAlpha(a)
            end
        end
    end)
    function f:SetShiny(on, col)
        if on and col then
            local r, g, b = math.min(1, col[1] * 0.5 + 0.5), math.min(1, col[2] * 0.5 + 0.5), math.min(1, col[3] * 0.5 + 0.5)
            for _, s in ipairs(self.stars) do
                for _, k in ipairs({ "h", "v", "d" }) do s[k]:SetVertexColor(r, g, b, 1) end
            end
        end
        self:SetShown(on and true or false)
    end
    f:Hide()
    return f
end

UI.BADGE_COLOURS = {
    normal = { 0.86, 0.66, 0.28, 1 }, elite = { 1.00, 0.82, 0.36, 1 },
    rare = { 0.45, 0.64, 1.00, 1 }, boss = { 0.92, 0.36, 0.24, 1 },
}
-- 7, 42, 999, 1.2k, 12k
function UI.ShortCount(n)
    n = tonumber(n) or 0
    if n < 1000 then return tostring(n) end
    if n < 10000 then return (string.format("%.1fk", n / 1000):gsub("%.0k", "k")) end
    return floor(n / 1000) .. "k"
end

-- Wax seal / medallion with an embossed icon or a number
function UI.Seal(parent, size, col, iconKey, emboss)
    local f = CreateFrame("Button", nil, parent)
    f:SetSize(size, size)
    f.rim = UI.Circle(f, size, { col[1] * 0.45, col[2] * 0.45, col[3] * 0.45, 1 }, "ARTWORK", 0)
    f.rim:SetPoint("CENTER")
    f.body = UI.Circle(f, size - 4, col, "ARTWORK", 1)
    f.body:SetPoint("CENTER")
    f.shine = UI.Circle(f, size * 0.5, { 1, 1, 1, 0.16 }, "ARTWORK", 2)
    f.shine:SetPoint("CENTER", -size * 0.13, size * 0.13)
    f.icon = f:CreateTexture(nil, "ARTWORK", nil, 3)
    f.icon:SetSize(size * 0.62, size * 0.62)
    f.icon:SetPoint("CENTER")
    f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    UI.Round(f.icon, f)
    f.label = UI.Text(f, max(8, floor(size * 0.45)), { 1, 0.95, 0.82, 1 }, "CENTER", UI.HEAD, true)
    f.label:SetPoint("CENTER", 0, 0)

    function f:SetSealSize(s)
        local k = UI.CanRound() and 1 or 0.74
        self:SetSize(s, s)
        self.rim:SetSize(s * k, s * k)
        self.body:SetSize((s - 4) * k, (s - 4) * k)
        self.shine:SetSize(s * 0.5 * k, s * 0.5 * k)
        self.shine:SetPoint("CENTER", -s * 0.13, s * 0.13)
        self.icon:SetSize(s * 0.62, s * 0.62)
    end

    function f:SetSeal(color, key, embossed, text)
        self.rim:SetVertexColor(color[1] * 0.45, color[2] * 0.45, color[3] * 0.45, 1)
        self.body:SetVertexColor(col4(color))
        local path = key and UI.Icon(key)
        if path and not text then
            self.icon:SetTexture(path)
            self.icon:Show()
            if embossed then
                self.icon:SetDesaturated(true)
                self.icon:SetVertexColor(min(1, color[1] * 1.9 + 0.15), min(1, color[2] * 1.9 + 0.15), min(1, color[3] * 1.9 + 0.15), 0.9)
            else
                self.icon:SetDesaturated(false)
                self.icon:SetVertexColor(1, 1, 1, 1)
            end
        else
            self.icon:Hide()
        end
        self.label:SetText(text or "")
    end
    f:SetSeal(col, iconKey, emboss)
    return f
end

------------------------------------------------------------------------
-- Buttons
------------------------------------------------------------------------
-- Leather button with gold-leaf edge (for the cover)
function UI.Button(parent, text, w, h, onClick, style)
    local b = UI.Frame(parent, w, h, "Button")
    style = style or {}
    local bg = style.bg or { 0.24, 0.12, 0.07, 1 }
    local edge = style.border or { 0.80, 0.62, 0.28, 1 }
    UI.Backdrop(b, "tooltip", 12, 3, bg, edge)
    local sheen = UI.GradRect(b, "VERTICAL", { 1, 1, 1, 0 }, { 1, 0.9, 0.7, 0.10 }, "BORDER")
    sheen:SetPoint("TOPLEFT", 3, -3)
    sheen:SetPoint("BOTTOMRIGHT", -3, 3)
    b.label = UI.Text(b, style.size or 13, style.text or c.gold, "CENTER", style.font or UI.HEAD, true)
    b.label:SetPoint("CENTER", 0, 0)
    b.label:SetText(text or "")
    local function paint(self, hover)
        if hover then
            self:SetBackdropColor(col4(style.hover or { 0.34, 0.17, 0.09, 1 }))
            self:SetBackdropBorderColor(1, 0.86, 0.45, 1)
            self.label:SetTextColor(1, 0.95, 0.75, 1)
        else
            self:SetBackdropColor(col4(bg))
            self:SetBackdropBorderColor(col4(edge))
            self.label:SetTextColor(col4(style.text or c.gold))
        end
    end
    b:SetScript("OnEnter", function(self) paint(self, true) end)
    b:SetScript("OnLeave", function(self) paint(self, false) end)
    b:SetScript("OnClick", function(self, ...) if onClick then onClick(self, ...) end end)
    function b:SetLabel(t) self.label:SetText(t) end
    paint(b, false)
    return b
end

-- Text written in ink on the page that behaves like a link
function UI.InkButton(parent, text, onClick, size, color)
    local b = CreateFrame("Button", nil, parent)
    local base = color or c.inkSoft
    b.text = UI.Text(b, size or 14, base, "CENTER", UI.HEAD)
    b.text:SetPoint("CENTER", 0, 1)
    local function paint(self, hover)
        self.text:SetTextColor(col4(hover and c.redInk or base))
    end
    function b:SetLabel(t)
        self.text:SetText(t)
        self:SetSize(self.text:GetStringWidth() + 8, (size or 14) + 10)
    end
    b:SetScript("OnEnter", function(self) paint(self, true) end)
    b:SetScript("OnLeave", function(self) paint(self, false) end)
    b:SetScript("OnClick", function(self, ...) if onClick then onClick(self, ...) end end)
    b:SetLabel(text or "")
    paint(b, false)
    return b
end

-- Spell-book page turn arrows
function UI.PageArrow(parent, kind, onClick)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(32, 32)
    local base = "Interface\\Buttons\\UI-SpellbookIcon-" .. kind .. "Page-"
    b:SetNormalTexture(base .. "Up")
    b:SetPushedTexture(base .. "Down")
    if UI.Has(base .. "Disabled") then b:SetDisabledTexture(base .. "Disabled") end
    b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    b:SetScript("OnClick", onClick)
    return b
end

function UI.ClassColor(classFile)
    local col = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if col then return { col.r, col.g, col.b, 1 } end
    return c.gold
end

-- the colour of a metal or a rarity as a hex code for written text; on the light parchment it is darkened,
-- else gold and silver would vanish on the paper
function UI.InkHex(col)
    if UI.THEME == "parchment" then
        return string.format("%02x%02x%02x", floor(col[1] * 140), floor(col[2] * 140), floor(col[3] * 140))
    end
    return string.format("%02x%02x%02x", floor(col[1] * 255), floor(col[2] * 255), floor(col[3] * 255))
end

function UI.Hex(col)
    return string.format("%02x%02x%02x", floor(col[1] * 255), floor(col[2] * 255), floor(col[3] * 255))
end
