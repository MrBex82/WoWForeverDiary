-- /wfd layoutcheck: opens Start, every group and part, every section of the settings and the help in turn and
-- lists writing that runs over the edge of the area it lies in (the window, a box that clips, the width of a
-- scrolling list) or lies on other writing. The findings go to the chat (a short count) and into
-- WFDiaryDB.layoutCheck, one run per size of the writing and style, so that they can be read after a /reload.
-- A tool for testing big writing, not for players.
local ADDON, WFD = ...
local UI = WFD.UI
local floor, max, min, format = math.floor, math.max, math.min, string.format

local SLACK = 2          -- points of overlap that do not count (shadows, rounding)

-- the rectangle the letters of a font string really cover, in the coordinates of the screen
local function inkRect(fs)
    local l, r, t, b = fs:GetLeft(), fs:GetRight(), fs:GetTop(), fs:GetBottom()
    if not (l and r and t and b) then return end
    local s = fs:GetEffectiveScale()
    local w = min(fs:GetStringWidth() or 0, r - l)
    if w <= 0 then return end
    local h = min(fs:GetStringHeight() or 0, max(t - b, fs:GetStringHeight() or 0))
    local j = fs:GetJustifyH()
    if j == "CENTER" then
        l = (l + r) / 2 - w / 2
    elseif j == "RIGHT" then
        l = r - w
    end
    local v = fs:GetJustifyV()
    if v == "BOTTOM" then t = b + h elseif v == "MIDDLE" then t = (t + b) / 2 + h / 2 end
    return l * s, (l + w) * s, t * s, (t - h) * s
end

local function rectOf(f)
    local l, r, t, b = f:GetLeft(), f:GetRight(), f:GetTop(), f:GetBottom()
    if not (l and r and t and b) then return end
    local s = f:GetEffectiveScale()
    return { l = l * s, r = r * s, t = t * s, b = b * s }
end

-- every visible font string with the area it must stay in: the nearest frame that clips (a scroll frame
-- only to the sides, its writing may run on below), else the window
local function collect(frame, area, out)
    if frame ~= UI.holder and (frame:GetObjectType() == "ScrollFrame" or (frame.DoesClipChildren and frame:DoesClipChildren())) then
        local rc = rectOf(frame)
        if rc then area = { rc = rc, scroll = frame:GetObjectType() == "ScrollFrame", frame = frame } end
    end
    for _, r in ipairs({ frame:GetRegions() }) do
        if r:GetObjectType() == "FontString" and r:IsVisible() and (r:GetText() or "") ~= "" and r:GetAlpha() > 0.05 then
            out[#out + 1] = { fs = r, area = area }
        end
    end
    for _, ch in ipairs({ frame:GetChildren() }) do
        if ch:IsVisible() then collect(ch, area, out) end
    end
end

local function short(fs)
    local t = (fs:GetText() or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("|A.-|a", ""):gsub("\n", " ")
    return t:sub(1, 28)
end

local stats
local function checkView(tag, issues)
    local root = UI.holder
    local win = rectOf(root)
    if not win then return end
    local list = {}
    collect(root, { rc = win, frame = root }, list)
    stats.views = stats.views + 1
    stats.strings = stats.strings + #list
    local rects = {}
    for _, e in ipairs(list) do
        local fs, a = e.fs, e.area.rc
        local l, r, t, b = inkRect(fs)
        -- writing scrolled out of its list is not seen and does not count
        if l and not (b >= a.t or t <= a.b or r <= a.l or l >= a.r) then
            rects[#rects + 1] = { fs = fs, area = e.area, l = l, r = r, t = t, b = b }
            local over = max(a.l - l, r - a.r)
            if not e.area.scroll then over = max(over, t - a.t, a.b - b) end
            if over > SLACK then
                issues[#issues + 1] = format("%s: über den Rand (%d) '%s'", tag, floor(over), short(fs))
            end
            if fs.IsTruncated and fs:IsTruncated() and fs:CanWordWrap() and (fs:GetMaxLines() or 0) == 0 then
                issues[#issues + 1] = format("%s: abgeschnitten '%s'", tag, short(fs))
            end
        end
    end
    -- overlaps only between writing in the same area (a menu or a tip over a list is meant to cover it)
    for i = 1, #rects do
        local a = rects[i]
        for j = i + 1, #rects do
            local b = rects[j]
            if a.area.frame == b.area.frame then
                local w = min(a.r, b.r) - max(a.l, b.l)
                local h = min(a.t, b.t) - max(a.b, b.b)
                -- a single letter or sign (an initial, a counter, "?") may lie on other writing
                local single = #short(a.fs) <= 2 or #short(b.fs) <= 2
                if w > SLACK and h > SLACK and not single then
                    issues[#issues + 1] = format("%s: überdeckt '%s' / '%s'", tag, short(a.fs), short(b.fs))
                end
            end
        end
    end
end

-- the round: the same places ui_sim opens
local function stops()
    local list = { { "start", function() UI:OpenStart() end } }
    for _, g in ipairs(UI.NAV or {}) do
        list[#list + 1] = { "group " .. g.key, function() UI.Router.Go(UI.GroupRoute(g)) end }
        for _, key in ipairs(UI.PartsOf(g)) do
            list[#list + 1] = { "part " .. key, function() UI.Router.Go(UI.PartRoute(key)) end }
        end
    end
    for i = 1, #UI.SettingsSchema() do
        list[#list + 1] = { "settings " .. i, function() UI.Router.Go({ view = "settings", section = i }) end }
    end
    list[#list + 1] = { "help", function() UI.Router.Go({ view = "help" }) end }
    return list
end

function UI:LayoutCheck()
    if not self.inShell then
        if self.OpenStart then self:OpenStart() end
        C_Timer.After(0.5, function() if self.inShell then self:LayoutCheck() end end)
        return
    end
    local issues, list = {}, stops()
    stats = { views = 0, strings = 0, errors = {} }
    local fontPct = floor((UI.FONT_SCALE or 1) * 100 + 0.5)
    local w, h = self.holder:GetSize()
    local p = "|cffffd100WoW Forever Diary:|r "
    print(p .. format("Prüfe %d Ansichten bei %d %% Schrift, Fenster %dx%d ...", #list, fontPct, floor(w), floor(h)))
    local i = 0
    local ticker
    -- each place is opened, then checked one tick later, when the game has laid it out
    ticker = C_Timer.NewTicker(0.1, function()
        if i > 0 then
            local ok, err = pcall(checkView, list[i][1], issues)
            if not ok and #stats.errors < 5 then stats.errors[#stats.errors + 1] = tostring(err) end
        end
        i = i + 1
        if i > #list then
            ticker:Cancel()
            if type(WFD.S.layoutCheck) ~= "table" or WFD.S.layoutCheck.issues then WFD.S.layoutCheck = {} end
            WFD.S.layoutCheck[format("%d %s %dx%d", fontPct, UI.THEME or "codex", floor(w), floor(h))] = {
                t = time(), views = #list, issues = issues, stats = stats }
            self:OpenStart()
            print(p .. format("%d Funde, gespeichert in WFDiaryDB.layoutCheck (nach /reload lesbar).", #issues))
            for k = 1, min(8, #issues) do print("  " .. issues[k]) end
            for _, e in ipairs(stats.errors) do print("  Fehler: " .. e) end
            return
        end
        local ok, err = pcall(list[i][2])
        if not ok and #stats.errors < 5 then stats.errors[#stats.errors + 1] = list[i][1] .. ": " .. tostring(err) end
    end)
end
