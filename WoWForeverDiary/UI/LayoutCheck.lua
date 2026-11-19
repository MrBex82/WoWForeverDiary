-- /wfd layoutcheck: turns through every spread of the book and lists writing that runs over the edge of its
-- page or lies on other writing. The findings go to the chat (a short count) and into WFDiaryDB.layoutCheck,
-- so that they can be read after a /reload. A tool for testing big writing, not for players.
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

local function collect(frame, out)
    for _, r in ipairs({ frame:GetRegions() }) do
        if r:GetObjectType() == "FontString" and r:IsVisible() and (r:GetText() or "") ~= "" and r:GetAlpha() > 0.05 then
            out[#out + 1] = r
        end
    end
    for _, ch in ipairs({ frame:GetChildren() }) do
        if ch:IsVisible() then collect(ch, out) end
    end
end

local function short(fs)
    local t = (fs:GetText() or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|T.-|t", ""):gsub("\n", " ")
    return t:sub(1, 28)
end

local stats
local function checkPage(side, index, issues)
    local pg = UI.pageFrames[side]
    local cv = pg.canvas
    local s = cv:GetEffectiveScale()
    local L, R, T, B = cv:GetLeft() * s, cv:GetRight() * s, cv:GetTop() * s, cv:GetBottom() * s
    local list = {}
    collect(cv, list)
    local rects = {}
    local page = UI.book.pages[index]
    local tag = format("p%d %s [%s%s]", UI.PageNumber(index), side, page and page.kind or "?",
        page and page.flowPart and (" " .. page.flowPart) or "")
    stats.pages = stats.pages + 1
    stats.strings = stats.strings + #list
    if not stats.sample and #list > 3 then
        local fs = list[2]
        stats.sample = format("canvas %s %s %s %s eff %.2f | fs '%s' %s %s %s %s eff %.2f sw %s",
            tostring(cv:GetLeft()), tostring(cv:GetRight()), tostring(cv:GetTop()), tostring(cv:GetBottom()), s,
            short(fs), tostring(fs:GetLeft()), tostring(fs:GetRight()), tostring(fs:GetTop()), tostring(fs:GetBottom()),
            fs:GetEffectiveScale(), tostring(fs:GetStringWidth()))
    end
    for _, fs in ipairs(list) do
        local l, r, t, b = inkRect(fs)
        if l then
            rects[#rects + 1] = { fs = fs, l = l, r = r, t = t, b = b }
            stats.rects = stats.rects + 1
            local over = max(L - l, r - R, t - T, B - b)
            if over > SLACK then
                issues[#issues + 1] = format("%s: über den Rand (%d) '%s'", tag, floor(over), short(fs))
            end
            if fs.IsTruncated and fs:IsTruncated() and fs:CanWordWrap() then
                issues[#issues + 1] = format("%s: abgeschnitten '%s'", tag, short(fs))
            end
        end
    end
    for i = 1, #rects do
        local a = rects[i]
        for j = i + 1, #rects do
            local b = rects[j]
            local w = min(a.r, b.r) - max(a.l, b.l)
            local h = min(a.t, b.t) - max(a.b, b.b)
            -- a single letter (the big initial of a day, "?" on a map) may lie on other writing
            local single = #short(a.fs) <= 1 or #short(b.fs) <= 1
            if w > SLACK and h > SLACK and not single then
                issues[#issues + 1] = format("%s: überdeckt '%s' / '%s'", tag, short(a.fs), short(b.fs))
            end
        end
    end
end

function UI:LayoutCheck(again)
    if not (self.bookFrame and self.bookFrame:IsShown()) then
        if again then return end
        self:OpenBook()
        C_Timer.After(0.5, function() self:LayoutCheck(true) end)
        return
    end
    if not (self.book and self.pageFrames) then return end
    local issues, n, back = {}, self:NumSpreads(), self.spread
    stats = { pages = 0, strings = 0, rects = 0, errors = {} }
    local anim = WFD.S.turnAnim
    WFD.S.turnAnim = false
    local s = 0
    local p = "|cffffd100WoW Forever Diary:|r "
    print(p .. format("Prüfe %d Doppelseiten bei %d %% Schrift ...", n, floor((UI.FONT_SCALE or 1) * 100 + 0.5)))
    local ticker
    ticker = C_Timer.NewTicker(0.05, function()
        if s > 0 then
            for _, side in ipairs({ "left", "right" }) do
                local ok, err = pcall(checkPage, side, side == "left" and s * 2 - 1 or s * 2, issues)
                if not ok and #stats.errors < 5 then stats.errors[#stats.errors + 1] = tostring(err) end
            end
        end
        s = s + 1
        if s > n then
            ticker:Cancel()
            WFD.S.turnAnim = anim
            -- one run per size of the writing, so 100 % can be compared with 150 %
            if type(WFD.S.layoutCheck) ~= "table" or WFD.S.layoutCheck.issues then WFD.S.layoutCheck = {} end
            WFD.S.layoutCheck[format("%d", floor((UI.FONT_SCALE or 1) * 100 + 0.5))] = { t = time(),
                theme = UI.THEME or "codex", spreads = n, issues = issues, stats = stats }
            self:ShowSpread(back)
            print(p .. format("%d Funde, gespeichert in WFDiaryDB.layoutCheck (nach /reload lesbar).", #issues))
            for i = 1, min(8, #issues) do print("  " .. issues[i]) end
            return
        end
        self:ShowSpread(s)
    end)
end
