-- The settings: one schema, four sections. The view on the travel desk and the entry in the game's own options
-- are both built from it, so they always offer the same. A change takes effect at once; only the language
-- needs the interface reloaded, and asks first.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

local function S() return WFD.S end
local function flag(key, after)
    return function() return S()[key] and true or false end,
        function(v) S()[key] = v and true or false if after then after(v) end end
end

-- (the texts are looked up when they are shown: the language is only known once the addon has loaded)
local function themeName(key)
    return ({ codex = L["Leather and gold"], parchment = L["Parchment"], modern = L["Modern"], contrast = L["Strong contrast"] })[key]
end
local LANG_NAMES = {
    deDE = "German", enUS = "English", enGB = "English", frFR = "French", esES = "Spanish", esMX = "Spanish",
    ptBR = "Portuguese", ruRU = "Russian", koKR = "Korean", zhTW = "Chinese (traditional)",
}

local function languages()
    local game = WFD.GetGameLanguage and WFD:GetGameLanguage() or GetLocale()
    local list = { { "game", format(L["Game language (%s)"], L[LANG_NAMES[game] or game]) } }
    for _, code in ipairs(WFD.languages) do
        if code ~= game then list[#list + 1] = { code, L[LANG_NAMES[code] or code] } end
    end
    return list
end

local function setLanguage(code)
    local cur = WFDiaryDB.language or "game"
    if code == cur then return end
    UI:Confirm({
        title = L["Change the language?"],
        text = L["The diary will reload the interface to switch the language."],
        ok = L["Reload now"],
        reload = true,
        onOk = function()
            WFDiaryDB.language = (code ~= "game") and code or nil
        end,
    })
end

local function resetWindow()
    S().shellSize = nil
    UI:ResetPosition()
    if UI.holder and UI.inShell then UI:SetHolderMode("shell") end
end

------------------------------------------------------------------------
-- The schema
------------------------------------------------------------------------
-- item types: toggle (get, set), choice (options), stepper, dropdown, theme, buttons, copy, note
local function notifyGet() return S().notify or "all" end
local function notifySet(v) S().notify = v end

function UI.SettingsSchema()
    if UI.SETTINGS then return UI.SETTINGS end
    UI.SETTINGS = {
    {
        key = "general", label = L["General"], sub = L["Notifications, minimap, pictures"],
        items = {
            { type = "choice", label = L["Notifications"], get = notifyGet, set = notifySet,
                options = { { "all", L["All"] }, { "important", L["Important only"] }, { "quiet", L["Quiet"] } },
                hint = L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."] },
            { type = "toggle", label = L["Show a note for new discoveries"], flag = "toasts" },
            { type = "toggle", label = L["Weekly look back at login"], flag = "recap" },
            { type = "toggle", label = L["A memory on Start"], flag = "memoryPage" },
            { type = "toggle", label = L["A memory as a note at login"], flag = "memoryToast" },
            { type = "toggle", label = L["Show when an item was first found in its tooltip"], flag = "itemTip" },
            { type = "toggle", label = L["Take a screenshot at milestones"], flag = "screenshots" },
            { type = "toggle", label = L["Show minimap button"], flag = "minimap", after = function() UI:UpdateMinimapButton() end },
            { type = "toggle", label = L["Show the cover when the book is first opened"], flag = "cover" },
        },
    },
    {
        key = "look", label = L["Appearance"], sub = L["Style, writing, window"],
        items = {
            { type = "theme", label = L["Style of the book"],
                hint = L["Leather and gold is the classic book. Modern is flat and calm, strong contrast makes all writing brighter."] .. " "
                    .. L["Parchment is bright, like old quest paper."] },
            { type = "choice", label = L["Size of the writing"],
                options = { { 1, "100%" }, { 1.1, "110%" }, { 1.2, "120%" } },
                get = function() return S().fontScale or 1 end, set = function(v) UI.SetFontScale(v) end },
            { type = "stepper", label = L["Size of the window"], lo = 0.6, hi = 1.4, step = 0.05,
                get = function() return S().scale or 0.9 end,
                set = function(v) UI:SetScale(floor(v * 100 + 0.5) / 100) if UI.LayoutShell then UI.LayoutShell() end end,
                fmt = function(v) return floor(v * 100 + 0.5) .. "%" end,
                hint = L["Also with Ctrl + mouse wheel. Drag the corner at the bottom right for a wider or taller window."] },
            { type = "toggle", label = L["Turn the leaves visibly"],
                get = function() return S().turnAnim ~= false end, set = function(v) S().turnAnim = (not v) and false or nil end },
            { type = "toggle", label = L["Show the companion beside the game"],
                get = function() return S().companion and true or false end, set = function(v) UI:ShowCompanion(v) end,
                hint = L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."] },
        },
    },
    {
        key = "handling", label = L["Handling"], sub = L["Window, notes, keys"],
        items = {
            { type = "toggle", label = L["Lock the window"], flag = "locked",
                hint = L["It can no longer be moved or resized by mistake."] },
            { type = "buttons", label = L["The window"], buttons = {
                { L["Reset the position and size"], resetWindow },
            } },
            { type = "buttons", label = L["Pop-up notes"], buttons = {
                { L["Show a note to move it"], function()
                    UI:Toast({ k = "memory", jubilee = true, when = L["Anniversary"], title = L["The diary's birthday"],
                        hint = L["Drag to move."], day = 1, t = time(), quiet = true }, true)
                end },
                { L["Put the notes back at the top"], function()
                    UI:ResetToastPlace()
                    print("|cffffd100WoW Forever Diary:|r " .. L["The notes are back at the top of the screen."])
                end },
            } },
            { type = "buttons", label = L["Keys"], buttons = {
                { L["Show all keys and commands"], function() R.Go({ view = "help" }) end },
            }, hint = L["A key to open the book can be set in the game's key bindings, under AddOns."] },
        },
    },
    {
        key = "data", label = L["Data"], sub = L["Language, export, moving, demo"],
        items = {
            { type = "dropdown", label = L["Language"], options = languages,
                get = function() return WFDiaryDB.language or "game" end, set = setLanguage,
                hint = L["Names from the game (places, creatures, items) stay in the language of the game client."] .. " "
                    .. L["Korean and Chinese text needs a game client with those fonts."] },
            { type = "buttons", label = L["Transcript"], buttons = {
                { L["Copy the diary as text"], function() UI:ShowTranscript("text") end },
                { L["Copy the diary as JSON"], function() UI:ShowTranscript("json") end },
                { L["Copy for forum or Discord (Markdown)"], function() UI:ShowTranscript("markdown") end },
            } },
            { type = "buttons", label = L["Moving to another computer"], buttons = {
                { L["Make a moving code"], function() UI:ShowMovingExport() end },
                { L["Read a moving code"], function() UI:ShowMovingImport() end },
            }, hint = L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."] },
            { type = "buttons", label = L["Demo"], buttons = {
                { function() return WFD.demo and L["Leave demo mode"] or L["Start demo mode"] end, function() WFD:ToggleDemo() end },
            } },
            { type = "copy", label = L["Support"], value = "https://ko-fi.com/mrbex",
                hint = L["If you enjoy the diary, you can support its development:"] },
        },
    },
}
    for _, sec in ipairs(UI.SETTINGS) do
        for _, it in ipairs(sec.items) do
            if it.flag then it.get, it.set = flag(it.flag, it.after) end
        end
    end
    return UI.SETTINGS
end

------------------------------------------------------------------------
-- Controls for the view
------------------------------------------------------------------------
local function caption(parent, text)
    local h = K.SectionHead(parent, text)
    return h
end

-- the four styles, each shown in its own colours
local function themeCards(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.cards = {}
    for i, key in ipairs(UI.THEME_ORDER) do
        local tk = UI.TOKENS[key]
        local b = K.Box(f, "card", "line", "Button")
        b.key = key
        b.sample = b:CreateTexture(nil, "ARTWORK", nil, 0)
        b.sample:SetTexture(UI.WHITE)
        b.sample:SetVertexColor(tk.card[1], tk.card[2], tk.card[3], 1)
        b.accent = b:CreateTexture(nil, "ARTWORK", nil, 1)
        b.accent:SetTexture(UI.WHITE)
        b.accent:SetVertexColor(tk.gold[1], tk.gold[2], tk.gold[3], 1)
        b.ink1 = b:CreateTexture(nil, "ARTWORK", nil, 1)
        b.ink1:SetTexture(UI.WHITE)
        b.ink1:SetVertexColor(tk.ink[1], tk.ink[2], tk.ink[3], 1)
        b.ink2 = b:CreateTexture(nil, "ARTWORK", nil, 1)
        b.ink2:SetTexture(UI.WHITE)
        b.ink2:SetVertexColor(tk.soft[1], tk.soft[2], tk.soft[3], 1)
        b.name = K.Text(b, "strong", "ink")
        b.name:SetText(themeName(key))
        b:SetScript("OnClick", function(self)
            if (UI.THEME or "codex") ~= self.key then UI.SetTheme(self.key) end
        end)
        b:SetScript("OnEnter", function(self) self.hover = true f:Refresh() end)
        b:SetScript("OnLeave", function(self) self.hover = nil f:Refresh() end)
        f.cards[i] = b
    end
    function f:Refresh()
        for _, b in ipairs(self.cards) do
            local on = (UI.THEME or "codex") == b.key
            b:SetSurface(on and "hover" or "card", (on or b.hover) and "gold" or "line")
            K.Recolor(b.name, on and "title" or "ink")
        end
    end
    function f:Measure(w)
        local n = #self.cards
        local per = (w >= 560 * math.max(1, UI.FONT_SCALE or 1)) and n or 2
        local cw = (w - (per - 1) * 10) / per
        local nameH = 0
        for _, b in ipairs(self.cards) do
            b.name:SetWidth(cw - 20)
            nameH = math.max(nameH, b.name:GetStringHeight())
        end
        local ch = 8 + 50 + 9 + nameH + 10
        for i, b in ipairs(self.cards) do
            local row, col = floor((i - 1) / per), (i - 1) % per
            b:SetSize(cw, ch)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", self, "TOPLEFT", col * (cw + 10), -row * (ch + 10))
            b.sample:ClearAllPoints()
            b.sample:SetPoint("TOPLEFT", 8, -8)
            b.sample:SetPoint("TOPRIGHT", -8, -8)
            b.sample:SetHeight(50)
            b.accent:SetSize(cw * 0.45, 7)
            b.accent:SetPoint("TOPLEFT", b.sample, "TOPLEFT", 10, -10)
            b.ink1:SetSize(cw * 0.6, 4)
            b.ink1:SetPoint("TOPLEFT", b.accent, "BOTTOMLEFT", 0, -8)
            b.ink2:SetSize(cw * 0.45, 4)
            b.ink2:SetPoint("TOPLEFT", b.ink1, "BOTTOMLEFT", 0, -6)
            b.name:SetPoint("TOPLEFT", b.sample, "BOTTOMLEFT", 2, -9)
        end
        local rows = floor((n - 1) / per) + 1
        local h = rows * (ch + 10) - 10
        self:SetSize(w, h)
        return h
    end
    UI.Skin.Add(f, function(s) s:Refresh() end)
    return f
end

local function buttonRow(parent, list)
    local f = CreateFrame("Frame", nil, parent)
    f.buttons = {}
    for i, b in ipairs(list) do
        local label = type(b[1]) == "function" and b[1]() or b[1]
        local btn = K.Button(f, label, "secondary", function(self)
            b[2]()
            if type(b[1]) == "function" then self:SetLabel(b[1]()) end
        end)
        btn.labelFn = type(b[1]) == "function" and b[1] or nil
        f.buttons[i] = btn
    end
    function f:Measure(w)
        local x, y, h = 0, 0, 0
        for _, btn in ipairs(self.buttons) do
            if btn.labelFn then btn:SetLabel(btn.labelFn()) end
            local bw = btn:GetWidth()
            if x > 0 and x + bw > w then x, y = 0, y + h + 8 end
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", self, "TOPLEFT", x, -y)
            x = x + bw + 8
            h = btn:GetHeight()
        end
        self:SetSize(w, y + h)
        return y + h
    end
    return f
end

local function copyField(parent, value)
    local e = K.Box(parent, "inset", "line", "EditBox")
    e:SetHeight(30)
    e:SetAutoFocus(false)
    e:SetTextInsets(8, 8, 0, 0)
    e:SetFontObject(ChatFontNormal)
    UI.Skin.Add(e, function(s)
        local font, size = UI.TypeFont("body")
        s:SetFont(font, size, "")
        s:SetTextColor(UI.Tok("soft"))
    end)
    e:SetText(value)
    e:SetCursorPosition(0)
    -- the text stays as it is, it can only be selected and copied
    e:SetScript("OnTextChanged", function(s, user) if user then s:SetText(value) s:HighlightText() end end)
    e:SetScript("OnEditFocusGained", function(s) s:HighlightText() end)
    e:SetScript("OnEditFocusLost", function(s) s:HighlightText(0, 0) end)
    e:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
    e:SetScript("OnEnterPressed", function(s) s:ClearFocus() end)
    return e
end

-- one item of the schema as a control with its caption and hint: { frame, Measure(w) -> height }
local function control(parent, it)
    local c = { frames = {} }
    if it.type == "toggle" then
        local t = K.Toggle(parent, it.label, it.get, it.set, it.hint)
        c.frames[1] = t
        function c:Measure(w, y)
            t:SetWidth(w)
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", parent, "TOPLEFT", self.x, -y)
            t:Refresh()
            return t:Measure(w)
        end
        function c:Refresh() t:Refresh() end
        return c
    end
    local cap = caption(parent, it.label)
    local hint
    if it.hint then
        hint = K.Text(parent, "small", "muted")
        hint:SetText(it.hint)
        hint:SetSpacing(2)
    end
    local body, fixed
    if it.type == "choice" then
        body = K.Segmented(parent, it.options, it.get, it.set)
    elseif it.type == "stepper" then
        body = K.Stepper(parent, it.get, it.set, it.lo, it.hi, it.step, it.fmt)
        fixed = true
    elseif it.type == "dropdown" then
        body = K.Dropdown(parent, it.options(), it.get, it.set, 280)
        fixed = true
    elseif it.type == "theme" then
        body = themeCards(parent)
    elseif it.type == "buttons" then
        body = buttonRow(parent, it.buttons)
    elseif it.type == "copy" then
        body = copyField(parent, it.value)
    end
    function c:Measure(w, y)
        local y0 = y
        cap:SetWidth(w)
        cap:ClearAllPoints()
        cap:SetPoint("TOPLEFT", parent, "TOPLEFT", self.x, -y)
        y = y + 24
        if hint and it.type == "copy" then
            hint:SetWidth(w)
            hint:ClearAllPoints()
            hint:SetPoint("TOPLEFT", parent, "TOPLEFT", self.x, -y)
            y = y + hint:GetStringHeight() + 8
        end
        body:ClearAllPoints()
        body:SetPoint("TOPLEFT", parent, "TOPLEFT", self.x, -y)
        local bh
        if body.Measure then
            bh = body:Measure(w)
        elseif it.type == "copy" then
            body:SetWidth(min(w, 360))
            bh = 30
        else
            if body.Refresh then body:Refresh() end
            bh = body:GetHeight()
        end
        y = y + bh
        if hint and it.type ~= "copy" then
            y = y + 8
            hint:SetWidth(min(w, 620))
            hint:ClearAllPoints()
            hint:SetPoint("TOPLEFT", parent, "TOPLEFT", self.x, -y)
            y = y + hint:GetStringHeight()
        end
        return y - y0
    end
    function c:Refresh() if body.Refresh then body:Refresh() end end
    c.frames = { cap, body, hint }
    return c
end

------------------------------------------------------------------------
-- The view: the sections on the left, the chosen one on the right
------------------------------------------------------------------------
UI:RegisterView({
    key = "settings",
    build = function(host)
        local v = { section = 1, panes = {} }
        local tabs = CreateFrame("Frame", nil, host)
        tabs:SetPoint("TOPLEFT", 0, 0)
        tabs:SetPoint("BOTTOMLEFT", 0, 0)
        tabs:SetWidth(200)
        local line = K.Fill(tabs, "line", "ARTWORK", 0)
        line:SetWidth(1)
        line:SetPoint("TOPRIGHT")
        line:SetPoint("BOTTOMRIGHT")
        v.tabs = {}
        for i, sec in ipairs(UI.SettingsSchema()) do
            local b = K.Box(tabs, nil, nil, "Button")
            b:SetHeight(58)
            b:SetPoint("TOPLEFT", tabs, "TOPLEFT", 10, -16 - (i - 1) * 62)
            b:SetPoint("RIGHT", tabs, "RIGHT", -10, 0)
            b.title = K.Text(b, "strong", "ink")
            b.title:SetPoint("TOPLEFT", 12, -9)
            b.title:SetText(sec.label)
            b.sub = K.Text(b, "small", "muted")
            b.sub:SetPoint("TOPLEFT", b.title, "BOTTOMLEFT", 0, -3)
            b.sub:SetWidth(200 - 20 - 20)
            b.sub:SetText(sec.sub)
            if b.sub.SetMaxLines then b.sub:SetMaxLines(2) end
            b:SetScript("OnEnter", function(self) if v.section ~= i then self:SetSurface("hover") end end)
            b:SetScript("OnLeave", function(self) v:PaintTabs() end)
            b:SetScript("OnClick", function() R.Go({ view = "settings", section = i }) end)
            v.tabs[i] = b
        end
        function v:PaintTabs()
            for i, b in ipairs(self.tabs) do
                b:SetSurface(i == self.section and "hover" or nil)
                K.Recolor(b.title, i == self.section and "title" or "ink")
            end
        end

        local scroll = K.Scroll(host)
        scroll:SetPoint("TOPLEFT", tabs, "TOPRIGHT", 0, 0)
        scroll:SetPoint("BOTTOMRIGHT", 0, 0)

        local function pane(i)
            if v.panes[i] then return v.panes[i] end
            local sec = UI.SETTINGS[i]
            local p = CreateFrame("Frame", nil, scroll.content)
            p:SetAllPoints(scroll.content)
            p.title = K.Text(p, "display", "title")
            p.title:SetText(sec.label)
            p.controls = {}
            for k, it in ipairs(sec.items) do p.controls[k] = control(p, it) end
            v.panes[i] = p
            return p
        end

        function v:Arrange()
            local p = self.panes[self.section]
            if not p then return end
            local w = min(720, ((self.w and self.w - 200) or scroll:GetWidth() or 0) - 2 * 28)
            if w <= 0 then return end
            p.title:ClearAllPoints()
            p.title:SetPoint("TOPLEFT", p, "TOPLEFT", 28, -22)
            local y = 22 + p.title:GetStringHeight() + 20
            for _, c in ipairs(p.controls) do
                c.x = 28
                y = y + c:Measure(w, y) + 22
            end
            scroll:SetContentHeight(y + 10)
        end

        function v:Show(route)
            self.section = route.section or self.section or 1
            for i, p in pairs(self.panes) do p:SetShown(i == self.section) end
            local p = pane(self.section)
            p:Show()
            for _, c in ipairs(p.controls) do if c.Refresh then c:Refresh() end end
            self:PaintTabs()
            scroll:ScrollTo(0)
            self:Arrange()
        end
        function v:Layout(w, h) self.w = w self:Arrange() end
        scroll.onResize = function(sf) v.w = sf:GetWidth() + 200 v:Arrange() end
        UI.OnRestyle(function() if host:IsShown() then v:PaintTabs() v:Arrange() end end)
        function v:Head() return L["Settings"], nil end
        return v
    end,
})

------------------------------------------------------------------------
-- The entry in the game's options (Interface -> AddOns): the switches of the schema, and the way to the rest
------------------------------------------------------------------------
local function buildOptions()
    local p = CreateFrame("Frame")
    p.name = "WoW Forever Diary"
    local title = p:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("WoW Forever Diary")
    local sub = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(560)
    sub:SetJustifyH("LEFT")
    sub:SetText(L["Just play, I'll write along. Every day you play becomes a page in this book."])

    local function closeOptions()
        for _, f in ipairs({ _G.SettingsPanel, _G.InterfaceOptionsFrame }) do
            if f and f:IsShown() then pcall(HideUIPanel, f) end
        end
    end
    local function button(text, x, y, fn)
        local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        b:SetSize(220, 24)
        b:SetPoint("TOPLEFT", x, y)
        b:SetText(text)
        b:SetScript("OnClick", fn)
        return b
    end
    button(L["Open the diary"], 16, -64, function() closeOptions() UI:Toggle() end)
    button(L["Open the settings"], 246, -64, function() closeOptions() UI:OpenSettings() end)

    local boxes = {}
    local y = -104
    for _, sec in ipairs(UI.SettingsSchema()) do
        local any = false
        for _, it in ipairs(sec.items) do if it.type == "toggle" then any = true end end
        if any then
            local h = p:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            h:SetPoint("TOPLEFT", 16, y)
            h:SetText(sec.label)
            y = y - 20
            for _, it in ipairs(sec.items) do
                if it.type == "toggle" then
                    local cb = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
                    cb:SetPoint("TOPLEFT", 16, y)
                    local tl = rawget(cb, "Text") or rawget(cb, "text")
                    if type(tl) ~= "table" or not tl.SetText then tl = nil end
                    local label = tl or cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                    if not tl then label:SetPoint("LEFT", cb, "RIGHT", 4, 0) end
                    label:SetText(it.label)
                    cb:SetScript("OnClick", function(s) it.set(s:GetChecked() and true or false) end)
                    boxes[#boxes + 1] = { cb, it }
                    y = y - 26
                end
            end
            y = y - 10
        end
    end
    local more = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    more:SetPoint("TOPLEFT", 16, y)
    more:SetWidth(560)
    more:SetJustifyH("LEFT")
    more:SetText(L["Style, size of the writing, language and data are in the settings of the diary."])

    p:SetScript("OnShow", function()
        for _, b in ipairs(boxes) do b[1]:SetChecked(b[2].get() and true or false) end
    end)

    if type(Settings) == "table" and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local cat = Settings.RegisterCanvasLayoutCategory(p, p.name)
        Settings.RegisterAddOnCategory(cat)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(p)
    end
end

WFD:OnInit(function()
    local ok, err = pcall(buildOptions)
    if not ok then WFD:Error("options", err) end
end)
