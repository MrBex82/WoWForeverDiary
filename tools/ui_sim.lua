-- A load test of the interface outside the game.
-- Usage:  lua tools/ui_sim.lua [addon folder]      (default: WoWForeverDiary)
--
-- Loads every file of the addon (the interface too) with a fake game: frames, textures and font strings that keep
-- their state (size, anchors, text, shown or hidden). Then it logs in, switches the demo on, opens the window and
-- goes everywhere: every group and part of the register, every section of the settings, the help, the search,
-- the four styles, three sizes of writing, a narrow and a wide window, back and forward.
-- Every error is listed; exit code 1. Like in the game, text on a font string without a font is an error.
--
-- Limits: nothing is drawn, so nothing about the look is checked; text widths are estimated; mouse-over is never
-- true. Methods the fake game does not know do nothing: they are listed at the end (a typo shows up there).

local dir = arg and arg[1] or "WoWForeverDiary"
local errors, seen = {}, {}
local function report(where, err)
    local key = tostring(where) .. ": " .. tostring(err)
    if not seen[key] then seen[key] = true errors[#errors + 1] = key end
end

------------------------------------------------------------------------ Lua 5.1 behaviour of the game
-- the game's string.format cuts a fraction for %d; Lua 5.4 refuses it
local rawformat = string.format
string.format = function(fmt, ...)
    local args = table.pack(...)
    local i = 0
    for flags, spec in tostring(fmt):gmatch("%%([%-%+ #0]*%d*%.?%d*)([%a%%])") do
        if spec ~= "%" then
            i = i + 1
            if (spec == "d" or spec == "i" or spec == "x" or spec == "X" or spec == "c") and type(args[i]) == "number" then
                args[i] = math.floor(args[i])
            end
        end
    end
    return rawformat(fmt, table.unpack(args, 1, args.n))
end

------------------------------------------------------------------------ the fake widgets
local unknown = {}
local W = {}           -- methods by widget type
local function noop() end

local function newObject(kind, parent)
    local o = { _kind = kind, _shown = true, _alpha = 1, _scale = 1, _level = 1, _points = {}, _scripts = {},
        _regions = {}, _children = {}, _parent = parent }
    if parent and parent._children and kind ~= "Texture" and kind ~= "FontString" and kind ~= "MaskTexture" then
        parent._children[#parent._children + 1] = o
        o._level = (parent._level or 0) + 1
    elseif parent and parent._regions then
        parent._regions[#parent._regions + 1] = o
    end
    return setmetatable(o, { __index = function(t, k)
        local m = W[kind] and W[kind][k] or W.Region[k]
        if m then return m end
        -- a method of the game the fake does not model: does nothing. Only names that look like the game's own
        -- (a method of the addon, probed with "if f.Measure then", must stay nil)
        if type(k) == "string" and (k:find("^Set") or k:find("^Enable") or k:find("^Disable") or k:find("^Register")
            or k:find("^Unregister") or k:find("^Clear") or k:find("^Highlight") or k:find("^Add") or k:find("^Lock")
            or k:find("^Unlock") or k:find("^Stop") or k:find("^Start") or k:find("^Raise") or k:find("^Lower")
            or k:find("^Insert") or k:find("^UpdateScrollChildRect") or k:find("^Play") or k:find("^Refresh[A-Z]")
            or k:find("^Get") or k:find("^Is") or k:find("^Can") or k:find("^Has") or k:find("^Use")
            or k:find("^Fade") or k:find("^Transform") or k:find("^ApplySpellVisual") or k:find("^Show[A-Z]")) then
            unknown[kind .. ":" .. k] = true
            return noop
        end
        return nil
    end })
end

W.Region = {}
local R = W.Region
function R:SetSize(w, h) self._w, self._h = w, h end
function R:SetWidth(w) self._w = w end
function R:SetHeight(h) self._h = h end
function R:GetWidth()
    if self._w and self._w > 0 then return self._w end
    local p = self._allPoints or (self._both and self._parent)
    if p and p.GetWidth then return p:GetWidth() end
    return self._w or 0
end
function R:GetHeight()
    if self._h and self._h > 0 then return self._h end
    local p = self._allPoints or (self._bothV and self._parent)
    if p and p.GetHeight then return p:GetHeight() end
    return self._h or 0
end
function R:GetSize() return self:GetWidth(), self:GetHeight() end
function R:SetPoint(point, rel, relPoint, x, y)
    if type(rel) == "number" then rel, relPoint, x, y = nil, nil, rel, relPoint end
    if type(rel) == "string" then rel = nil end
    self._points[#self._points + 1] = { point, rel or self._parent, relPoint or point, x or 0, y or 0 }
    local hasL, hasR, hasT, hasB = false, false, false, false
    for _, p in ipairs(self._points) do
        local pt = p[1]
        if pt:find("LEFT") then hasL = true end
        if pt:find("RIGHT") then hasR = true end
        if pt:find("TOP") then hasT = true end
        if pt:find("BOTTOM") then hasB = true end
    end
    self._both, self._bothV = hasL and hasR, hasT and hasB
end
function R:ClearAllPoints() self._points = {} self._allPoints = nil self._both, self._bothV = false, false end
function R:SetAllPoints(rel) self._allPoints = (type(rel) == "table" and rel) or self._parent end
function R:GetPoint(i)
    local p = self._points[i or 1]
    if p then return p[1], p[2], p[3], p[4], p[5] end
end
function R:GetNumPoints() return #self._points end
function R:Show()
    local was = self._shown
    self._shown = true
    if not was and self._scripts.OnShow then self._scripts.OnShow(self) end
end
function R:Hide()
    local was = self._shown
    self._shown = false
    if was and self._scripts.OnHide then self._scripts.OnHide(self) end
end
function R:SetShown(v) if v then self:Show() else self:Hide() end end
function R:IsShown() return self._shown end
function R:IsVisible()
    local o = self
    while o do
        if not o._shown then return false end
        o = o._parent
    end
    return true
end
function R:SetAlpha(a) self._alpha = a end
function R:GetAlpha() return self._alpha end
function R:SetParent(p)
    if self._parent and self._parent._children then
        for i, c in ipairs(self._parent._children) do if c == self then table.remove(self._parent._children, i) break end end
    end
    self._parent = p
    if p and p._children then p._children[#p._children + 1] = self end
end
function R:GetParent() return self._parent end
function R:SetScale(s) self._scale = s end
function R:GetScale() return self._scale end
function R:GetEffectiveScale()
    local s, o = 1, self
    while o do s = s * (o._scale or 1) o = o._parent end
    return s
end
function R:GetLeft() return 0 end
function R:GetRight() return self:GetWidth() end
function R:GetTop() return self:GetHeight() end
function R:GetBottom() return 0 end
function R:GetCenter() return self:GetWidth() / 2, self:GetHeight() / 2 end
function R:IsMouseOver() return false end
function R:GetName() return self._name end
function R:GetObjectType() return self._kind end
function R:IsObjectType(t) return self._kind == t end
function R:SetDrawLayer(l, s) self._layer = l end

W.Frame = {}
local F = W.Frame
function F:SetScript(name, fn) self._scripts[name] = fn end
function F:GetScript(name) return self._scripts[name] end
function F:HookScript(name, fn)
    local old = self._scripts[name]
    self._scripts[name] = old and function(...) old(...) fn(...) end or fn
end
function F:SetFrameLevel(l) self._level = l end
function F:GetFrameLevel() return self._level end
function F:SetFrameStrata(s) self._strata = s end
function F:GetFrameStrata() return self._strata or "MEDIUM" end
function F:CreateTexture() return newObject("Texture", self) end
function F:CreateMaskTexture() return newObject("MaskTexture", self) end
function F:CreateLine() return newObject("Texture", self) end
function F:CreateAnimationGroup()
    local g = newObject("Frame", nil)
    g.CreateAnimation = function() return newObject("Frame", nil) end
    return g
end
function F:CreateFontString(_, _, template)
    local fs = newObject("FontString", self)
    if template then fs._font, fs._size = "template", 12 end
    return fs
end
function F:GetRegions() return table.unpack(self._regions) end
function F:GetChildren() return table.unpack(self._children) end
function F:GetNumChildren() return #self._children end
function F:SetBackdrop(b) self._backdrop = b end
function F:IsMouseEnabled() return true end
function F:RegisterEvent() return true end
function F:UnregisterEvent() end
function F:RegisterUnitEvent() return true end
function F:IsEventRegistered() return true end
function F:GetFrameLevel() return self._level end

-- buttons
local function inherit(kind, base)
    W[kind] = setmetatable({}, { __index = function(_, k) return W[base] and W[base][k] or W.Frame[k] end })
    return W[kind]
end
local B = inherit("Button", "Frame")
function B:SetText(t) self._text = t end
function B:GetText() return self._text end
function B:Click(button) if self._scripts.OnClick and self:IsEnabled() then self._scripts.OnClick(self, button or "LeftButton") end end
function B:IsEnabled() return self._enabled ~= false end
function B:Enable() local was = self:IsEnabled() self._enabled = true if not was and self._scripts.OnEnable then self._scripts.OnEnable(self) end end
function B:Disable() local was = self:IsEnabled() self._enabled = false if was and self._scripts.OnDisable then self._scripts.OnDisable(self) end end
function B:SetEnabled(v) if v then self:Enable() else self:Disable() end end
function B:GetFontString() return self._fs end
local CB = inherit("CheckButton", "Button")
function CB:SetChecked(v) self._checked = v end
function CB:GetChecked() return self._checked end
local E = inherit("EditBox", "Frame")
function E:SetText(t)
    if not self._font then error("EditBox:SetText(): Font not set", 2) end
    self._text = tostring(t)
    if self._scripts.OnTextChanged then self._scripts.OnTextChanged(self, false) end
end
function E:GetText() return self._text or "" end
function E:SetFont(f, s) self._font, self._size = f, s return true end
function E:SetFontObject() self._font = self._font or "object" end
function E:SetFocus()
    self._focus = true
    if self._scripts.OnEditFocusGained then self._scripts.OnEditFocusGained(self) end
end
function E:ClearFocus()
    local was = self._focus
    self._focus = false
    if was and self._scripts.OnEditFocusLost then self._scripts.OnEditFocusLost(self) end
end
function E:HasFocus() return self._focus end
function E:GetNumber() return tonumber(self._text) or 0 end
local SF = inherit("ScrollFrame", "Frame")
function SF:SetScrollChild(c) self._child = c c:SetParent(self) end
function SF:GetScrollChild() return self._child end
function SF:SetVerticalScroll(v) self._vs = v end
function SF:GetVerticalScroll() return self._vs or 0 end
function SF:GetVerticalScrollRange() return math.max(0, (self._child and self._child:GetHeight() or 0) - self:GetHeight()) end
for _, k in ipairs({ "PlayerModel", "DressUpModel", "Model", "CinematicModel", "ModelScene", "Slider", "StatusBar", "GameTooltip", "Cooldown" }) do
    inherit(k, "Frame")
end
W.GameTooltip.GetOwner = function(self) return self._owner end
W.GameTooltip.SetOwner = function(self, o) self._owner = o end
W.GameTooltip.NumLines = function() return 0 end

local T = setmetatable({}, { __index = W.Region })
W.Texture, W.MaskTexture = T, T
function T:SetTexture(path) self._tex = path return true end
function T:GetTexture() return self._tex end
function T:SetVertexColor() end
function T:SetColorTexture() end

local FS = setmetatable({}, { __index = W.Region })
W.FontString = FS
function FS:SetFont(f, s) if not f or not s then error("FontString:SetFont(): bad font", 2) end self._font, self._size = f, s return true end
function FS:GetFont() return self._font, self._size, "" end
function FS:SetFontObject() self._font, self._size = self._font or "object", self._size or 12 end
function FS:SetText(t)
    if not self._font then error("FontString:SetText(): Font not set", 2) end
    self._text = t ~= nil and tostring(t) or nil
end
function FS:GetText() return self._text end
function FS:SetFormattedText(fmt, ...) self:SetText(string.format(fmt, ...)) end
function FS:SetWordWrap(v) self._wrap = v end
function FS:CanWordWrap() return self._wrap ~= false end
function FS:SetSpacing(s) self._spacing = s end
function FS:SetMaxLines(n) self._max = n end
local function plain(t) return (t or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", "WW") end
function FS:GetStringWidth()
    local t = plain(self._text)
    return #t * (self._size or 12) * 0.5
end
FS.GetUnboundedStringWidth = FS.GetStringWidth
function FS:GetStringHeight()
    local size = self._size or 12
    local w = self:GetWidth()
    local lines = 1
    if w and w > 0 and self._wrap ~= false then lines = math.max(1, math.ceil(self:GetStringWidth() / w)) end
    if self._max and self._max > 0 then lines = math.min(lines, self._max) end
    if (self._text or "") == "" then return 0 end
    return lines * (size + (self._spacing or 0))
end
function FS:IsTruncated() return false end
function FS:GetLineHeight() return self._size or 12 end

------------------------------------------------------------------------ the fake game
local env = {}
local realType = type
setmetatable(env, { __index = function(_, k)
    local v = _G[k]
    if v ~= nil then return v end
    return nil
end })
env._G = env
env.type = realType
env.unpack = table.unpack
env.getn = function(t) return #t end
env.format, env.floor, env.ceil, env.min, env.max, env.abs = string.format, math.floor, math.ceil, math.min, math.max, math.abs
env.strlower, env.strupper, env.strlen, env.strsub, env.strfind, env.strrep = string.lower, string.upper, string.len, string.sub, string.find, string.rep
env.gsub, env.strmatch, env.strbyte, env.strchar = string.gsub, string.match, string.byte, string.char
env.strtrim = function(s) return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", "")) end
env.strsplit = function(sep, s)
    local out, pos = {}, 1
    while true do
        local a, b = s:find(sep, pos, true)
        if not a then out[#out + 1] = s:sub(pos) break end
        out[#out + 1] = s:sub(pos, a - 1)
        pos = b + 1
    end
    return table.unpack(out)
end
env.strjoin = function(sep, ...) return table.concat({ ... }, sep) end
env.tinsert, env.tremove, env.wipe = table.insert, table.remove, function(t) for k in pairs(t) do t[k] = nil end return t end
env.sort = table.sort
env.tContains = function(t, v) for _, x in ipairs(t) do if x == v then return true end end return false end
env.time, env.date, env.difftime = os.time, os.date, os.difftime
local clock = 1000
env.GetTime = function() clock = clock + 0.1 return clock end
env.GetServerTime = os.time
env.debugprofilestop = function() return os.clock() * 1000 end
env.bit = { band = function(a, b) return a & b end, bor = function(a, b) return a | b end, bxor = function(a, b) return a ~ b end,
    lshift = function(a, b) return a << b end, rshift = function(a, b) return a >> b end, bnot = function(a) return ~a end }
env.hooksecurefunc = function(t, name, fn)
    if realType(t) == "string" then t, name, fn = env, t, name end
    local old = t[name]
    t[name] = function(...) local r = table.pack(old(...)) fn(...) return table.unpack(r, 1, r.n) end
end
env.securecall = function(fn, ...) return fn(...) end
env.issecretvalue = function() return false end

env.CreateFrame = function(kind, name, parent)
    local o = newObject(W[kind] and kind or "Frame", parent)
    o._name = name
    if name then env[name] = o end
    return o
end
env.UIParent = env.CreateFrame("Frame", "UIParent")
env.UIParent:SetSize(1600, 900)
env.WorldFrame = env.CreateFrame("Frame", "WorldFrame")
env.Minimap = env.CreateFrame("Frame", "Minimap", env.UIParent)
env.Minimap:SetSize(140, 140)
env.GameTooltip = env.CreateFrame("GameTooltip", "GameTooltip", env.UIParent)
env.ItemRefTooltip = env.CreateFrame("GameTooltip", "ItemRefTooltip", env.UIParent)
env.UISpecialFrames = {}
env.SOUNDKIT = {}
env.PlaySound = noop
env.PlaySoundFile = noop
env.RAID_CLASS_COLORS = setmetatable({}, { __index = function() return { r = 1, g = 1, b = 1, colorStr = "ffffffff" } end })
env.STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
env.ChatFontNormal, env.GameFontNormal, env.GameFontHighlight, env.GameFontHighlightSmall, env.GameFontNormalLarge = {}, {}, {}, {}, {}
env.BackdropTemplateMixin = {}
env.CreateColor = function(r, g, b, a) return { r = r, g = g, b = b, a = a } end
env.CreateVector2D = function(x, y) return { x = x, y = y } end
env.GetCursorPosition = function() return 0, 0 end
env.IsControlKeyDown, env.IsShiftKeyDown, env.IsAltKeyDown = function() return false end, function() return false end, function() return false end
env.InCombatLockdown = function() return false end
env.GetCurrentKeyBoardFocus = function() return nil end
env.GetFileIDFromPath = function() return 1 end
env.GetLocale = function() return "deDE" end
env.GetRealmName = function() return "Realm" end
env.GetBuildInfo = function() return "1.15.7", "1", "Jan 1 2026", 11507 end
env.UnitName = function() return "Tester", "Realm" end
env.UnitGUID = function(u) return u == "player" and "Player-1-00000001" or nil end
env.UnitLevel = function() return 12 end
env.UnitClass = function() return "Krieger", "WARRIOR", 1 end
env.UnitRace = function() return "Mensch", "Human" end
env.UnitSex = function() return 2 end
env.UnitFactionGroup = function() return "Alliance", "Allianz" end
env.UnitExists = function(u) return u == "player" end
env.UnitIsPlayer = function(u) return u == "player" end
env.UnitIsDeadOrGhost, env.UnitIsDead, env.UnitAffectingCombat = function() return false end, function() return false end, function() return false end
env.UnitXP, env.UnitXPMax, env.GetXPExhaustion = function() return 10 end, function() return 1000 end, function() return 0 end
env.UnitHealth, env.UnitHealthMax = function() return 100 end, function() return 100 end
env.GetMoney = function() return 123456 end
env.GetZoneText, env.GetRealZoneText, env.GetSubZoneText, env.GetMinimapZoneText = function() return "Wald von Elwynn" end,
    function() return "Wald von Elwynn" end, function() return "Goldhain" end, function() return "Goldhain" end
env.IsInInstance = function() return false, "none" end
env.GetInstanceInfo = function() return "Azeroth", "none" end
env.GetNumGroupMembers, env.IsInRaid, env.IsInGroup = function() return 0 end, function() return false end, function() return false end
env.GetNumQuestLogEntries = function() return 0, 0 end
env.GetQuestLogTitle = function() return nil end
env.GetNumSkillLines = function() return 0 end
env.GetNumFactions = function() return 0 end
env.GetBindLocation = function() return "Goldhain" end
env.GetPlayerMapPosition = function() return 0.5, 0.5 end
env.GetMinimapShape = function() return "ROUND" end
env.GetItemInfo = function() return nil end
env.GetItemQualityColor = function() return 1, 1, 1, "ffffffff" end
env.GetMouseFocus = function() return nil end
env.GetScreenWidth, env.GetScreenHeight = function() return 1600 end, function() return 900 end
env.ReloadUI = function() env.__reloaded = true end
env.Screenshot = noop
env.HideUIPanel, env.ShowUIPanel = noop, noop
env.InterfaceOptions_AddCategory = noop
env.Settings = { RegisterCanvasLayoutCategory = function() return {} end, RegisterAddOnCategory = noop }
env.C_Map = setmetatable({ GetBestMapForUnit = function() return 1429 end, GetPlayerMapPosition = function() return nil end,
    GetMapInfo = function(id) return { mapID = id, name = "Karte " .. tostring(id), mapType = 3, parentMapID = 1415 } end,
    GetMapChildrenInfo = function(id)
        if id == 1415 then return { { mapID = 1429, name = "Wald von Elwynn" }, { mapID = 1436, name = "Westfall" } } end
        if id == 1414 then return { { mapID = 1411, name = "Durotar" } } end
        return {}
    end, GetAreaInfo = function() return "Gebiet" end,
    GetMapArtLayerTextures = function() return {} end, GetMapArtLayers = function() return {} end,
    GetMapRectOnMap = function() return 0, 1, 0, 1 end, GetWorldPosFromMapPos = function() return 0, { x = 0, y = 0 } end },
    { __index = function() return noop end })
env.C_Timer = {}
local timers = {}
env.C_Timer.After = function(_, fn) timers[#timers + 1] = fn end
env.C_Timer.NewTicker = function() return { Cancel = noop, IsCancelled = function() return false end } end
env.C_Timer.NewTimer = function(_, fn) timers[#timers + 1] = fn return { Cancel = noop } end
env.TooltipDataProcessor = { AddTooltipPostCall = noop }
env.Enum = { TooltipDataType = { Item = 0 } }
env.SlashCmdList = {}
env.OKAY, env.CLOSE, env.CANCEL = "Okay", "Schließen", "Abbrechen"
env.print = function() end
env.WFDiaryDB, env.WFDiaryChar = {}, {}

local function flushTimers()
    for _ = 1, 5 do
        local list = timers
        timers = {}
        for _, fn in ipairs(list) do
            local ok, err = pcall(fn)
            if not ok then report("timer", err) end
        end
        if #timers == 0 then return end
    end
end

------------------------------------------------------------------------ load
local WFD = {}
local f = assert(io.open(dir .. "/WoWForeverDiary.toc", "r"))
local toc = f:read("a")
f:close()
for line in toc:gmatch("[^\r\n]+") do
    if not line:find("^#") and line:find("%.lua%s*$") then
        local path = dir .. "/" .. line:gsub("\\", "/"):gsub("%s+$", "")
        local chunk, err = loadfile(path, "t", env)
        if not chunk then report("load " .. line, err)
        else
            local ok, e = pcall(chunk, "WoWForeverDiary", WFD)
            if not ok then report("load " .. line, e) end
        end
    end
end
WFD.Error = function(_, where, err) report(where, err) end

local evf = WFD.evf
local function fire(event, ...)
    local fn = evf and evf:GetScript("OnEvent")
    if fn then
        local ok, err = pcall(fn, evf, event, ...)
        if not ok then report(event, err) end
    end
    flushTimers()
end

local UI = WFD.UI
local function step(name, fn)
    local ok, err = pcall(fn)
    if not ok then report(name, err) end
    flushTimers()
end

fire("ADDON_LOADED", "WoWForeverDiary")
fire("PLAYER_LOGIN")
fire("PLAYER_ENTERING_WORLD", true, false)

------------------------------------------------------------------------ go everywhere
local cardsShown, cardsDocked, reportsOpened = 0, 0, 0
do
    local show0 = UI.ShowCard
    UI.ShowCard = function(self, kind, key)
        show0(self, kind, key)
        cardsShown = cardsShown + 1
        if self.card and self.card.docked then cardsDocked = cardsDocked + 1 end
    end
end
local function everywhere(label)
    local Rt = UI.Router
    step(label .. " start", function() UI:OpenStart() end)
    for _, g in ipairs(UI.NAV) do
        step(label .. " group " .. g.key, function() Rt.Go(UI.GroupRoute(g)) end)
        for _, key in ipairs(UI.PartsOf(g)) do
            step(label .. " part " .. key, function() Rt.Go(UI.PartRoute(key)) end)
        end
    end
    for i = 1, #UI.SettingsSchema() do
        step(label .. " settings " .. i, function() Rt.Go({ view = "settings", section = i }) end)
    end
    step(label .. " help", function() Rt.Go({ view = "help" }) end)
    -- the views of the collections: every chip, every order, the first card opened and leafed through
    for part in pairs(UI.PART_VIEW or {}) do
        step(label .. " view " .. part, function()
            local route = UI.PartRoute(part)
            Rt.Go(route)
            local key = route.view
            local v = UI.ViewInstance(key)
            for _, b in ipairs(v.chips or {}) do b:Click() end
            if v.chips and v.chips[1] then v.chips[1]:Click() end
            if v.sort then
                for _, so in ipairs(v.sortKeys or {}) do v.state.sort = so v:Refresh() end
            end
            if v.search then v.search:SetText("a") v.search:SetText("") end
            for item, f in pairs(v.list and v.list.active or {}) do
                local click = f:GetScript("OnClick")
                if click and item.entry and not item.entry.hint then click(f, "LeftButton") break end
            end
            if v.report and v.selected ~= nil then reportsOpened = reportsOpened + 1 end
            if v.next and v.next:IsShown() then v.next:Click() v.prev:Click() end
            if v.detail and v.detail:IsShown() then v:CloseDetail() end
        end)
    end
    -- the world map: a continent, the replay, a region with every layer on and off, the places on no continent
    step(label .. " world", function()
        Rt.Go({ view = "world", cont = 1415 })
        local v = UI.ViewInstance("world")
        v.replay:Click()
        if v.map:IsReplaying() then v.map:StepReplay() end
        v.map:StopReplay()
        Rt.Go({ view = "world", cont = 1415, map = 1429 })
        for _, b in ipairs(v.chips) do b:Click() end
        for _, b in ipairs(v.chips) do b:Click() end
        v:Layout(700, 500)
        v:Layout(1300, 860)
        Rt.Go({ view = "world", cont = "other" })
        Rt.Go({ view = "world", layer = "hunt" })
        Rt.Go({ view = "world", layer = "finds" })
        v.up:Click()
        Rt.Back()
    end)
    -- the diary: the newest day, a day back and on, a bookmark set and taken away, a small window
    step(label .. " diary", function()
        Rt.Go({ view = "diary" })
        local v = UI.ViewInstance("diary")
        v:Turn(-1)
        v:Turn(1)
        v:ToggleMark()
        for _, m in ipairs(UI.MarkList()) do m.go() end
        Rt.Go({ view = "diary" })
        v:ToggleMark()
        v:Layout(700, 500)
        -- narrow: the index folds away and opens from the foot
        if v.index:IsShown() then error("the index stays in a narrow window") end
        v.indexBtn:Click()
        if not v.index:IsShown() then error("the index does not open from the foot") end
        v.jumpBtn:Click()
        UI.Kit.CloseDialog()
        v.indexBtn:Click()
        v:Layout(1300, 860)
        if v.day and v.day > 1 then Rt.Go({ view = "diary", day = 1 }) end
    end)
    step(label .. " back", function() for _ = 1, 6 do Rt.Back() end end)
    step(label .. " forward", function() for _ = 1, 3 do Rt.Forward() end end)
    step(label .. " search", function()
        UI:OpenStart()
        UI:FocusSearch()
        local box, res = UI.shell.search, UI.shell.results
        box:SetText("wolf")
        -- a filter for days chooses the chip of the diary, and gives the chip back when it is gone
        res.chips[4]:Click()
        local chosen = res.kind
        box:SetText("z:Elwynn")
        if res.kind ~= "day" then error("a filter for days did not choose the diary") end
        box:SetText("wolf")
        if res.kind ~= chosen then error("the chip chosen before did not come back") end
        -- nothing under one kind: the button searches everywhere
        res.chips[2]:Click()
        box:SetText("zzqx")
        res.widen:Click()
        if res.kind ~= nil then error("searching everywhere kept the chip") end
        -- out of the field and back in: the results are there again
        res:Hide()
        box:ClearFocus()
        box:SetFocus()
        if not res:IsShown() then error("the results did not come back with the focus") end
        box:SetText("")
    end)
end

step("toggle (cover)", function() UI:Toggle() end)
step("cover click", function() UI.cover:GetScript("OnClick")(UI.cover) end)
everywhere("empty")
step("close", function() UI:Hide() end)
step("demo", function() WFD:ToggleDemo() end)
everywhere("demo")
for _, theme in ipairs({ "parchment", "modern", "contrast", "codex" }) do
    step("theme " .. theme, function() UI.SetTheme(theme) end)
    step("theme " .. theme .. " book", function() UI.Router.Go(UI.PartRoute("bestiary")) end)
    step("theme " .. theme .. " start", function() UI:OpenStart() end)
end
for _, k in ipairs({ 1.1, 1.2, 1 }) do step("font " .. k, function() UI.SetFontScale(k) end) end
for _, size in ipairs({ { 760, 520 }, { 1400, 900 }, { 1080, 700 } }) do
    step("size " .. size[1], function()
        UI.holder:SetSize(size[1], size[2])
        UI.LayoutShell()
        UI.Router.Go(UI.PartRoute("diary"))
        UI.LayoutShell()
        UI:OpenStart()
        UI.LayoutShell()
    end)
end
-- every switch of the settings, twice (back to where it was)
step("settings switches", function()
    for _, sec in ipairs(UI.SettingsSchema()) do
        for _, it in ipairs(sec.items) do
            if it.type == "toggle" and it.flag ~= "locked" then
                local v = it.get()
                it.set(not v)
                it.set(v)
            end
        end
    end
end)
-- a button and a sign pressed and let go: what they carry moves down and back to the same place
step("press", function()
    local K = UI.Kit
    local b = K.Button(UI.holder, "Knopf", "primary")
    local i = K.IconButton(UI.holder, "left", nil, nil)
    for _, x in ipairs({ b, i }) do
        local part = x.label or x.glyph
        local _, _, _, _, y0 = part:GetPoint(1)
        x:GetScript("OnMouseDown")(x, "LeftButton")
        if not x.pressed then error("not pressed") end
        local _, _, _, _, y1 = part:GetPoint(1)
        x:GetScript("OnMouseUp")(x, "LeftButton")
        local _, _, _, _, y2 = part:GetPoint(1)
        if y1 ~= y0 - 1 or y2 ~= y0 then error("pressed part not moved and back: " .. tostring(y0) .. " " .. tostring(y1) .. " " .. tostring(y2)) end
        x:Disable()
        x:GetScript("OnMouseDown")(x, "LeftButton")
        if x.pressed then error("a button that cannot be used is pressed") end
        x:Enable()
    end
    -- a long list: it opens with the chosen entry in sight, scrolls, and a pick closes it
    local items, val = {}, 25
    for n = 1, 40 do items[n] = { n, "Eintrag " .. n } end
    local dd = K.Dropdown(UI.holder, items, function() return val end, function(v) val = v end)
    dd:Click()
    local menu = dd.menuFrame and dd.menuFrame()
    if not (menu and menu:IsShown()) then error("the list did not open") end
    if menu.visible >= 40 then error("a long list is not limited in height") end
    if menu.first > 25 or menu.first + menu.visible - 1 < 25 then error("the chosen entry is not in sight") end
    menu:GetScript("OnMouseWheel")(menu, -1)
    menu:GetScript("OnMouseWheel")(menu, 50)
    if menu.first ~= 1 then error("scrolling to the top did not stop at the first entry") end
    menu.rows[2]:Click()
    if val ~= 2 or menu:IsShown() then error("picking an entry: " .. tostring(val)) end
end)
-- the keys of the window: scrolling the open view, back and forward
step("keys", function()
    UI:OpenShell({ view = "help" })
    for _, k in ipairs({ "DOWN", "PAGEDOWN", "UP", "PAGEUP", "ALT-LEFT", "ALT-RIGHT", "LEFT", "RIGHT" }) do UI.KEYS[k]() end
end)
-- Escape with a question open: the game may close the question only, the window stays
local function special(name)
    for _, n in ipairs(env.UISpecialFrames) do if n == name then return true end end
    return false
end
step("escape layer open", function()
    UI:Confirm({ title = "Frage", text = "Text", ok = "Ja" })
end)
step("escape layer check", function()
    if special("WoWForeverDiaryFrame") or not special("WoWForeverDiaryDialog") then
        error("with a question open, Escape would close the window: " .. table.concat(env.UISpecialFrames, ","))
    end
    UI.Kit.CloseDialog()
end)
step("escape layer closed", function()
    if not special("WoWForeverDiaryFrame") or special("WoWForeverDiaryDialog") then
        error("the window is not closed by Escape again: " .. table.concat(env.UISpecialFrames, ","))
    end
end)
-- a chip, an order and the filter chosen in a list come back with Back, and do not make places of their own
step("route keeps the state", function()
    local Rt = UI.Router
    UI:OpenShell({ view = "fates" })
    local v = UI.ViewInstance("fates")
    local depth = #Rt.back
    v.chips[2]:Click()
    v.search:SetText("ab")
    if #Rt.back ~= depth then error("choosing a chip made a new place in the history") end
    if Rt.cur.chip ~= v.chips[2].key or Rt.cur.q ~= "ab" then error("the route did not take the chip and the filter") end
    Rt.Go({ view = "start" })
    Rt.Back()
    if v.state.chip ~= v.chips[2].key or v.search:GetText() ~= "ab" then error("Back did not bring the chip and the filter back") end
    Rt.Go({ view = "fates" })
    if v.state.chip ~= v.chips[1].key or v.search:GetText() ~= "" then error("a route without a chip kept the old one") end
    -- a bookmark's route is not changed by what is chosen after it was opened
    local mark = { view = "fates" }
    Rt.Go(mark)
    v.chips[2]:Click()
    if mark.chip then error("the route given was changed") end
    -- with a filter the button to reset it shows, and takes it all back
    v.search:SetText("zzqx")
    if not v.clear:IsShown() then error("no button to reset the filter") end
    v.emptyClear:Click()
    if v.state.chip ~= v.chips[1].key or v.state.q ~= "" or Rt.cur.chip or Rt.cur.q then error("resetting the filter left something") end
    if v.clear:IsShown() then error("the reset button stays without a filter") end
end)
-- the place where the window was left survives closing and a reload (here: the session's copy forgotten)
step("last place", function()
    local Rt = UI.Router
    local demo = WFD.demo
    if demo then WFD:ToggleDemo() end
    UI:OpenShell({ view = "fates", chip = "nemesis" })
    UI:Hide()
    UI:OpenShell()
    if Rt.cur.view ~= "fates" or Rt.cur.chip ~= "nemesis" then error("closing and opening lost the place") end
    UI:Hide()
    UI.lastPlace = nil                    -- as after /reload
    UI:OpenShell()
    if Rt.cur.view ~= "start" then error("after logging in the window did not open at Start") end
    Rt.Back()
    if Rt.cur.view ~= "fates" or Rt.cur.chip ~= "nemesis" then error("Back did not lead to the place before the reload") end
    UI:Hide()
    UI.lastPlace = nil
    WFD.S.openAt = "last"
    UI:OpenShell()
    if Rt.cur.view ~= "fates" then error("'where I left it' did not open there") end
    WFD.S.openAt = nil
    -- a place of a view that is gone is not taken
    UI:Hide()
    UI.lastPlace = nil
    WFD.C.lastPlace = { route = { view = "gone" }, back = { { view = "gone" } } }
    UI:OpenShell()
    if Rt.cur.view ~= "start" or #Rt.back ~= 0 then error("a place of a view that is gone was taken") end
    if demo then WFD:ToggleDemo() end
end)
-- news go per part: looking at one part reads its news, the others keep theirs, closing reads nothing
step("news per part", function()
    local demo = WFD.demo
    if demo then WFD:ToggleDemo() end
    local C = WFD.C
    C.seenAt, C.partSeen = os.time() - 100, nil
    C.mobs = C.mobs or {}
    C.mobs[999001] = { name = "Neuer Wolf", first = os.time() }
    C.quests = C.quests or {}
    C.quests[999002] = { title = "Neue Quest", done = os.time() }
    UI:OpenShell({ view = "start" })
    local n = UI.NewCounts()
    if (n.bestiary or 0) < 1 or (n.quests or 0) < 1 then error("the news were not counted") end
    UI:Hide()
    UI:OpenShell({ view = "start" })
    if (UI.NewCounts().bestiary or 0) < 1 then error("closing the window read the news") end
    UI.Router.Go(UI.PartRoute("bestiary"))
    n = UI.NewCounts()
    if (n.bestiary or 0) ~= 0 then error("looking at the bestiary did not read its news") end
    if (n.quests or 0) < 1 then error("looking at the bestiary read the news of the quests") end
    C.mobs[999001], C.quests[999002] = nil, nil
    if demo then WFD:ToggleDemo() end
end)
-- the settings: going through their sections makes no places in the history, the gear leaves them in one step;
-- the buttons for backups and tidying up ask or tell in the window
step("settings in one step", function()
    local Rt = UI.Router
    UI:OpenShell({ view = "start" })
    UI.shell.gear:Click()
    local v = UI.ViewInstance("settings")
    for _, b in ipairs(v.tabs) do b:Click() end
    UI.shell.gear:Click()
    if Rt.cur.view ~= "start" then error("the gear did not leave the settings in one step: " .. tostring(Rt.cur.view)) end
    for _, sec in ipairs(UI.SettingsSchema()) do
        for _, it in ipairs(sec.items) do
            if it.type == "buttons" and sec.key == "data" then
                -- (the demo button has a label that changes, a function: it is left alone)
                for _, b in ipairs(it.buttons) do
                    if type(b[1]) == "string" then
                        b[2]()
                        UI.Kit.CloseDialog()
                    end
                end
            end
        end
    end
end)
-- tasks lead where they are taken on; an own goal removed comes back with undo
step("tasks and goals", function()
    for _, k in ipairs({ "kills", "wquests", "mkm", "landmark", "region", "loot", "people", "places" }) do
        local go = UI.TaskGo({ k = k })
        if not go then error("the task " .. k .. " leads nowhere") end
        go()
    end
    WFD.C.myGoals = { { text = "Eins" }, { text = "Zwei" } }
    UI:OpenShell(UI.PartRoute("tasks"))
    local v = UI.ViewInstance("tasks")
    -- the second goal's cross, then the undo of the note
    local list = WFD.C.myGoals
    local found
    local function walk(f)
        if found then return end
        if f.del and f.index == 2 then found = f return end
        for _, ch in ipairs({ f:GetChildren() }) do walk(ch) end
    end
    walk(v.host)
    if not found then error("no row of an own goal") end
    found.del:Click()
    if #list ~= 1 then error("the goal was not removed") end
    UI.shell.notice.act:Click()
    if #list ~= 2 or list[2].text ~= "Zwei" then error("undo did not bring the goal back to its place") end
    found.box:Click()
    WFD.C.myGoals = nil
end)
-- the narrow register: a group opens a menu of its parts, a sign the bookmarks
step("narrow register", function()
    UI:OpenShell({ view = "start" })
    WFD.S.navCollapsed = true
    UI.LayoutShell()
    local hunt
    for _, b in ipairs(UI.shell.items) do if b.col == UI.GROUP_COLOURS.hunt then hunt = b end end
    hunt:Click()
    local menu = env.WoWForeverDiaryMenu
    if not (menu and menu:IsShown()) then error("the group opened no menu of its parts") end
    menu.rows[2]:Click()
    if UI.Router.cur.view == "start" then error("a part picked in the menu did not open") end
    WFD.C.marks = { { day = 1 } }
    UI:OnMarksChanged()
    if not UI.shell.markMenu:IsShown() then error("no sign for the bookmarks in the narrow register") end
    UI.shell.markMenu:Click()
    UI.Kit.CloseMenu()
    WFD.C.marks = {}
    WFD.S.navCollapsed = nil
    UI.LayoutShell()
end)
-- every place can be bookmarked from the head bar, with what was chosen in it; undo takes it away again
step("bookmark any view", function()
    local Rt = UI.Router
    WFD.C.marks = {}
    UI:OpenShell({ view = "fates", chip = "nemesis" })
    UI.shell.mark:Click()
    if #WFD.C.marks ~= 1 or not WFD.C.marks[1].route or WFD.C.marks[1].route.chip ~= "nemesis" then error("the place was not bookmarked") end
    if not UI.shell.mark.active then error("the button does not show the bookmark") end
    UI:OpenShell({ view = "start" })
    UI.MarkList()[1].go()
    if Rt.cur.view ~= "fates" or Rt.cur.chip ~= "nemesis" then error("the bookmark did not lead back with its chip") end
    UI.shell.mark:Click()
    if #WFD.C.marks ~= 0 then error("the second click did not take the bookmark away") end
    UI.shell.notice.act:Click()
    if #WFD.C.marks ~= 1 then error("undo did not bring the bookmark back") end
    WFD.C.marks = {}
    UI:OnMarksChanged()
end)
-- a text cut short shows the whole row as a tooltip, a whole one shows none
step("full text", function()
    local K = UI.Kit
    local a, b = K.Text(UI.holder, "body"), K.Text(UI.holder, "small")
    a:SetText("Ein sehr langer Name")
    b:SetText("Zeile darunter")
    if K.ShowFull(UI.holder, nil, a, b) then error("a whole text showed a tooltip") end
    a.IsTruncated = function() return true end
    if not K.ShowFull(UI.holder, nil, a, b) then error("a text cut short showed no tooltip") end
end)
step("dialog", function()
    UI:Confirm({ title = "Frage", text = "Text", ok = "Ja", onOk = function() end })
    UI.Kit.CloseDialog()
    UI:Ask({ title = "Wert", input = { value = "5", numeric = true }, onOk = function() end })
    UI.Kit.CloseDialog()
end)
-- the side windows: the toasts (more than three at once), the look back, the moving code, the transcript
step("toasts", function()
    for i = 1, 6 do UI:Toast({ k = "level", s = "Level " .. (10 + i) .. "!", t = os.time(), day = 1 }, true) end
    UI:Toast({ k = "honour", honour = "slayer", tier = 1, s = "Honour: Slayer", t = os.time(), day = 1 }, true)
    UI:Toast({ k = "memory", title = "x", when = "y", day = 1, t = os.time() }, true)
    UI:ShowRecap(false)
    UI:ShowRecap(true)
    UI.Router.Go({ view = "recap", week = 2 })
end)
step("side windows", function()
    UI:ShowTranscript("text")
    UI:ShowTranscript("json")
    UI:ShowTranscript("markdown")
    UI:ShowMovingExport()
    UI:ShowMovingImport()
end)
step("slash", function()
    for _, cmd in ipairs({ "bestiarium", "12", "einstellungen", "heute", "quatsch", "" }) do env.SlashCmdList.WOWFOREVERDIARY(cmd) end
end)
step("close again", function() UI:Hide() UI:Toggle() end)

------------------------------------------------------------------------ report
-- what was really reached, so a quiet run is not mistaken for a thorough one
local parts = 0
for _, g in ipairs(UI.NAV) do parts = parts + #UI.PartsOf(g) end
print(string.format("Reached: %d parts in the register, demo %s, theme %s, window %dx%d",
    parts, WFD.demo and "on" or "off", tostring(UI.THEME),
    UI.holder and UI.holder:GetWidth() or 0, UI.holder and UI.holder:GetHeight() or 0))
print(string.format("Cards opened: %d, in the column of a view: %d; reports opened: %d", cardsShown, cardsDocked, reportsOpened))
-- every part of the register has a name of its own, not its key
for _, g in ipairs(UI.NAV) do
    for _, key in ipairs(UI.PartsOf(g)) do
        if UI.PartLabel(key) == key then report("register", "part without a name: " .. key) end
    end
end
local names = {}
for k in pairs(unknown) do names[#names + 1] = k end
table.sort(names)
print("Methods the fake game does not know (" .. #names .. "): " .. table.concat(names, ", "))
if #errors == 0 then
    print("OK: the interface loaded and every view opened without an error")
    os.exit(0)
end
print(#errors .. " error(s):")
for _, e in ipairs(errors) do print("  " .. e) end
os.exit(1)
