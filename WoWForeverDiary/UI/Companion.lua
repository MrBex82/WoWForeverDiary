-- The companion: a small window beside the game that shows today at a glance - the day so far,
-- the tasks of the day and the week, and the honours that are closest. A click opens the book there.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format
local unpack = unpack or table.unpack

local W = 284
local ROW = 23
local comp

local BG = { 0.045, 0.05, 0.06, 0.90 }

-- lines, tracks and highlights: light veils on the dark window, dark brown ink on the parchment of that look
local function veil(a)
    if UI.THEME == "parchment" then return { 0.28, 0.16, 0.05, min(1, a * 3.2) } end
    return { 1, 1, 1, a }
end

local function pageOf(kind)
    return function(book)
        for i, p in ipairs(book.pages) do if p.kind == kind then return i end end
        return 1
    end
end

local function openAt(fn)
    UI:OpenBook(fn)
end

------------------------------------------------------------------------
-- Building
------------------------------------------------------------------------
local function text(parent, size, col, justify)
    -- the dark shadow lifts light writing off the dark window; under dark ink on the parchment it only smudges
    local fs = UI.Text(parent, size, col, justify, UI.FONT, UI.THEME ~= "parchment")
    fs:SetWordWrap(false)
    return fs
end

local function newRow(parent)
    local r = CreateFrame("Button", nil, parent)
    r:SetSize(W - 20, ROW)
    r.hl = r:CreateTexture(nil, "BACKGROUND")
    r.hl:SetTexture(UI.WHITE)
    r.hl:SetAllPoints()
    r.hl:SetVertexColor(unpack(veil(0.06)))
    r.hl:Hide()
    r.mark = UI.Fill(r, c.redInk, "ARTWORK", 0)
    r.mark:SetSize(4, 4)
    -- the writing sits in the upper part of the row, the bar below it with room between
    r.mark:SetPoint("LEFT", 2, 3)
    r.label = text(r, 11, c.ink, "LEFT")
    r.label:SetPoint("LEFT", 12, 3)
    r.value = text(r, 11, c.inkSoft, "RIGHT")
    r.value:SetPoint("RIGHT", -2, 3)
    local tv = veil(0.08)
    r.track = UI.Fill(r, tv, "ARTWORK", 0, tv[4])
    r.track:SetHeight(2)
    r.track:SetPoint("BOTTOMLEFT", 12, 1)
    r.track:SetPoint("BOTTOMRIGHT", -2, 1)
    r.bar = UI.Fill(r, c.redInk, "ARTWORK", 1)
    r.bar:SetHeight(2)
    r.bar:SetPoint("BOTTOMLEFT", r.track, "BOTTOMLEFT")
    r:SetScript("OnEnter", function(s)
        s.hl:Show()
        if s.tip then
            GameTooltip:SetOwner(s, "ANCHOR_LEFT")
            GameTooltip:SetText(s.tip[1], 1, 0.86, 0.5, 1, true)
            for i = 2, #s.tip do GameTooltip:AddLine(s.tip[i], 0.9, 0.9, 0.9, true) end
            GameTooltip:AddLine(L["Click to open the diary there."], 0.5, 0.8, 1)
            GameTooltip:Show()
        end
    end)
    r:SetScript("OnLeave", function(s) s.hl:Hide() GameTooltip:Hide() end)
    r:SetScript("OnClick", function(s) if s.go then openAt(s.go) end end)
    return r
end

local function setRow(r, label, value, frac, done, tip, go)
    r.label:SetText(label)
    r.value:SetText(value or "")
    r.label:SetWidth(W - 20 - 14 - max(36, r.value:GetStringWidth() + 8))
    local col = done and c.good or c.redInk
    r.mark:SetVertexColor(col4(col))
    r.label:SetTextColor(col4(done and c.inkSoft or c.ink))
    r.bar:SetVertexColor(col4(col))
    local tw = W - 20 - 14
    if frac then
        r.track:Show()
        r.bar:Show()
        r.bar:SetWidth(max(1, tw * min(1, max(0, frac))))
    else
        r.track:Hide()
        r.bar:Hide()
    end
    r.tip, r.go = tip, go
    r:Show()
end

local function caption(parent)
    local t = text(parent, 10, c.redInk, "LEFT")
    local ln = UI.Fill(parent, veil(0.09), "ARTWORK", 0)
    ln:SetHeight(1)
    ln:SetPoint("LEFT", t, "RIGHT", 6, 0)
    ln:SetPoint("RIGHT", parent, "RIGHT", -10, 0)
    return t, ln
end

local function build()
    local f = CreateFrame("Frame", "WoWForeverDiaryCompanion", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(W, 100)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    if UI.THEME == "parchment" then
        -- the game's own quest paper with its torn border, a little larger than the window
        local q = f:CreateTexture(nil, "BACKGROUND", nil, 0)
        q:SetTexture("Interface\\QuestFrame\\QuestBG")
        q:SetTexCoord(0, 0.586, 0, 0.654)
        q:SetPoint("TOPLEFT", -10, 10)
        q:SetPoint("BOTTOMRIGHT", 10, -10)
        -- a light wash evens out the dark mottling of that paper behind the writing
        local wash = UI.Fill(f, { 0.96, 0.89, 0.72, 0.45 }, "BACKGROUND", 1)
        wash:SetAllPoints()
    else
        UI.Backdrop(f, nil, 1, 0, BG, veil(0.09))
    end
    local p = WFD.S.compPos
    if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("RIGHT", UIParent, "RIGHT", -40, 120) end

    -- header: the day, folding and closing; drag it to move the window
    local head = CreateFrame("Button", nil, f)
    head:SetPoint("TOPLEFT", 1, -1)
    head:SetPoint("TOPRIGHT", -1, -1)
    head:SetHeight(24)
    head:RegisterForDrag("LeftButton")
    head:SetScript("OnDragStart", function() f:StartMoving() end)
    head:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local a, _, b, x, y = f:GetPoint(1)
        WFD.S.compPos = { a, b, x, y }
    end)
    local hb = UI.Fill(head, veil(0.05), "BACKGROUND", 0)
    hb:SetAllPoints()
    local icon = head:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(UI.Icon("journal"))
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", 6, 0)
    f.title = text(head, 12, c.ink, "LEFT")
    f.title:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    local function headButton(label, x, fn, tip)
        local b = CreateFrame("Button", nil, head)
        b:SetSize(18, 18)
        b:SetPoint("RIGHT", x, 0)
        b.t = text(b, 14, c.inkSoft, "CENTER")
        b.t:SetPoint("CENTER", 0, 1)
        b.t:SetText(label)
        b:SetScript("OnClick", fn)
        b:SetScript("OnEnter", function(s)
            s.t:SetTextColor(col4(c.ink))
            GameTooltip:SetOwner(s, "ANCHOR_TOP")
            GameTooltip:SetText(tip, 1, 0.86, 0.5)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function(s) s.t:SetTextColor(col4(c.inkSoft)) GameTooltip:Hide() end)
        return b
    end
    headButton("x", -4, function()
        WFD.S.companion = false
        f:Hide()
        print("|cffffd100WoW Forever Diary:|r " .. L["The companion can be shown again in the settings or with /wfd companion."])
    end, L["Close"])
    f.fold = headButton("-", -22, function()
        WFD.S.compCollapsed = not WFD.S.compCollapsed
        UI:UpdateCompanion(true)
    end, L["Fold in or out"])
    head:SetScript("OnClick", function() openAt(function(b) return UI.TodayPage(UI) end) end)

    local body = CreateFrame("Frame", nil, f)
    body:SetPoint("TOPLEFT", 10, -30)
    body:SetPoint("TOPRIGHT", -10, -30)
    body:SetHeight(10)
    f.body = body

    -- the day so far: six figures
    f.stats = {}
    for i = 1, 6 do
        local col, row = (i - 1) % 3, floor((i - 1) / 3)
        local s = CreateFrame("Frame", nil, body)
        s:SetSize((W - 20) / 3, 32)
        s:SetPoint("TOPLEFT", col * (W - 20) / 3, -row * 34)
        s.v = text(s, 14, c.ink, "LEFT")
        s.v:SetPoint("TOPLEFT", 0, 0)
        s.l = text(s, 10, c.inkSoft, "LEFT")
        s.l:SetPoint("TOPLEFT", 0, -17)
        f.stats[i] = s
    end
    f.capTasks = { caption(body) }
    f.capWeek = { caption(body) }
    f.capHon = { caption(body) }
    f.capNext = { caption(body) }
    f.rows = {}
    for i = 1, 9 do f.rows[i] = newRow(body) end
    f:Hide()
    return f
end

------------------------------------------------------------------------
-- Filling
------------------------------------------------------------------------
local honourCache, honourAt = nil, 0
local function closestHonours()
    if honourCache and GetTime() - honourAt < 20 then return honourCache end
    local ok, list = pcall(WFD.HonourState, WFD)
    local out = {}
    if ok and list then
        for _, e in ipairs(list) do
            if e.next and not e.hidden then
                e.frac = (e.value - e.prev) / max(1, e.next - e.prev)
                out[#out + 1] = e
            end
        end
        table.sort(out, function(a, b) return a.frac > b.frac end)
    end
    honourCache, honourAt = out, GetTime()
    return out
end
WFD:OnSignal("milestone", function() honourAt = 0 end)

local function km(steps) return floor((steps or 0) * 0.9144 / 100 + 0.5) / 10 end

function UI:UpdateCompanion(relayout)
    if not comp or not comp:IsShown() then return end
    local C = WFD.C
    if not C then return end
    local today = WFD:DayIndex()
    local d = C.days[today] or {}
    comp.title:SetText(L["Today"] .. "  -  " .. format(L["Day %d"], WFD:NumDays()))
    local folded = WFD.S.compCollapsed
    comp.fold.t:SetText(folded and "+" or "-")
    comp.body:SetShown(not folded)
    if folded then comp:SetHeight(26) return end

    local net = (WFD:Sum(d.income or {}) or 0) - (WFD:Sum(d.spend or {}) or 0)
    local stats = {
        { tostring(d.killTotal or 0), L["Slain"] }, { tostring(#(d.qd or {})), L["Quests"] },
        { tostring(d.xp or 0), L["Experience"] }, { tostring(km(d.steps)), L["km"] },
        { (net < 0 and "-" or "") .. UI.CoinIcons(net, 11), L["Gold"] }, { WFD:DurationText(d.online or 0), L["Online"] },
    }
    for i, s in ipairs(stats) do
        local box = comp.stats[i]
        box.v:SetText(s[1])
        UI.FitText(box.v, (W - 20) / 3 - 4, 14, 9, UI.FONT)
        box.l:SetText(s[2]:upper())
    end

    local y = -72
    local used = 0
    for _, cap in ipairs({ comp.capTasks, comp.capWeek, comp.capHon, comp.capNext }) do cap[1]:Hide() cap[2]:Hide() end
    local function place(cap, label)
        local fs, ln = cap[1], cap[2]
        fs:ClearAllPoints()
        fs:SetPoint("TOPLEFT", comp.body, "TOPLEFT", 0, y)
        fs:SetText(label:upper())
        fs:Show()
        ln:Show()
        y = y - 14
    end
    local function row(...)
        used = used + 1
        local r = comp.rows[used]
        if not r then return end
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", comp.body, "TOPLEFT", 0, y)
        setRow(r, ...)
        y = y - ROW
    end
    local goals = pageOf("nextgoals")

    -- tasks of the day
    local tasks = WFD.TodayChallenges and WFD:TodayChallenges()
    if tasks and #tasks.list > 0 then
        local doneN = 0
        for _ in pairs(tasks.done) do doneN = doneN + 1 end
        place(comp.capTasks, L["Tasks of the day"] .. "  " .. doneN .. "/" .. #tasks.list)
        for i, t in ipairs(tasks.list) do
            local v, g = WFD:ChallengeProgress(today, t)
            local done = tasks.done[i] and true or false
            row(WFD:ChallengeText(t), done and L["done"] or (g > 1 and (WFD:TaskValueText(t, v) .. "/" .. g) or ""), done and 1 or v / max(1, g), done,
                { L["Tasks of the day"], WFD:ChallengeText(t) }, goals)
        end
        y = y - 4
    end
    -- task of the week
    local wk, w
    if WFD.ThisWeek then wk, w = WFD:ThisWeek() end
    if wk and wk.task then
        place(comp.capWeek, L["Task of the week"])
        local v, g = WFD:WeeklyProgress(w, wk.task)
        -- the bar from the number itself: "3,2" (written the German way) is no number to Lua
        row(WFD:WeeklyText(wk.task), wk.done and L["done"] or (WFD:TaskValueText(wk.task, v) .. "/" .. g), wk.done and 1 or v / max(1, g),
            wk.done, { L["Task of the week"], WFD:WeeklyText(wk.task) }, goals)
        y = y - 4
    end
    -- the honours closest to their next tier
    local hons = closestHonours()
    if #hons > 0 then
        place(comp.capHon, L["Next honours"])
        for i = 1, min(3, #hons) do
            local e = hons[i]
            row(L[e.def.name], e.value .. "/" .. e.next, e.frac, false,
                { L[e.def.name], WFD:HonourText(e.def, e.next) }, function(b) return b.sectionStart.honour or 1 end)
        end
    end
    -- the creature closest to its next stage in the bestiary
    local near
    for _, m in pairs(C.mobs or {}) do
        local stage = WFD:MobStage(m)
        if stage < 3 then
            local goal = stage == 1 and WFD.STAGE_COLOUR or WFD.STAGE_MASTER
            local left = goal - (m.kills or 0)
            if not near or left < near.left then near = { m = m, goal = goal, left = left, stage = stage } end
        end
    end
    if near then
        y = y - 4
        place(comp.capNext, L["Almost there"])
        local what = format(near.stage == 1 and L["%d more, then in colour"] or L["%d more, then a connoisseur"], near.left)
        row(near.m.name or "?", (near.m.kills or 0) .. "/" .. near.goal, (near.m.kills or 0) / near.goal, false,
            { near.m.name or "?", what }, function(b) return b.nextPage or b.sectionStart.bestiary or 1 end)
    end
    for i = used + 1, #comp.rows do comp.rows[i]:Hide() end
    comp.body:SetHeight(-y)
    comp:SetHeight(30 + (-y) + 8)
end

------------------------------------------------------------------------
-- Showing
------------------------------------------------------------------------
local ticker
function UI:ShowCompanion(show)
    if show == nil then show = not (comp and comp:IsShown()) end
    WFD.S.companion = show and true or false
    if show then
        comp = comp or build()
        comp:Show()
        honourAt = 0
        self:UpdateCompanion(true)
        if not ticker and C_Timer and C_Timer.NewTicker then
            ticker = C_Timer.NewTicker(2, function()
                local ok, err = pcall(UI.UpdateCompanion, UI)
                if not ok then WFD:Error("companion", err) end
            end)
        end
    elseif comp then
        comp:Hide()
    end
end

WFD:OnInit(function()
    -- off at first: the introduction offers it (a window nobody asked for would only be in the way)
    if WFD.S.companion == nil then WFD.S.companion = false end
    if WFD.S.companion then UI:ShowCompanion(true) end
end)
