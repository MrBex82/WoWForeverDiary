-- The companion: a small window beside the game that shows today at a glance - the day so far,
-- the tasks of the day and the week, and the honours that are closest. A click opens the diary there.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format
local unpack = unpack or table.unpack

local K = UI.Kit
local W = 290
local ROW = 25
local comp

local function openAt(route) UI:OpenShell(route or { view = "start" }) end

------------------------------------------------------------------------
-- Building: the panel of the style with a gold edge, figures in tiles as on Start, lines with a bar
------------------------------------------------------------------------
local function newRow(parent)
    local r = CreateFrame("Button", nil, parent)
    r:SetSize(W - 24, ROW)
    r.hl = K.Fill(r, "hover", "BACKGROUND", 0, 0.6)
    r.hl:SetAllPoints()
    r.hl:Hide()
    r.mark = UI.Diamond(r, 5, { 1, 1, 1, 1 }, "ARTWORK", 1)
    r.mark:SetPoint("LEFT", 3, 3)
    r.label = K.Text(r, "small", "rail")
    r.label:SetPoint("LEFT", 12, 3)
    r.label:SetWordWrap(false)
    r.value = K.Text(r, "small", "railSoft", "RIGHT")
    r.value:SetPoint("RIGHT", -2, 3)
    r.bar = K.Bar(r, 3)
    r.bar:SetPoint("BOTTOMLEFT", 12, 1)
    r.bar:SetPoint("BOTTOMRIGHT", -2, 1)
    r:SetScript("OnEnter", function(s)
        s.hl:Show()
        if s.tip then
            local lines = {}
            for i = 2, #s.tip do lines[#lines + 1] = s.tip[i] end
            lines[#lines + 1] = { L["Click to open the diary there."], 0.5, 0.8, 1 }
            K.ShowTip(s, s.tip[1], lines, "ANCHOR_LEFT")
        end
    end)
    r:SetScript("OnLeave", function(s) s.hl:Hide() GameTooltip:Hide() end)
    r:SetScript("OnClick", function(s) if s.go then openAt(s.go) end end)
    return r
end

local function setRow(r, label, value, frac, done, tip, go)
    r.label:SetText(label)
    r.value:SetText(value or "")
    r.label:SetWidth(W - 24 - 14 - max(36, r.value:GetStringWidth() + 8))
    K.Recolor(r.label, done and "railMuted" or "rail")
    r.mark:SetVertexColor(UI.Tok(done and "pos" or "railGold"))
    r.bar:SetShown(frac ~= nil)
    if frac then
        r.bar:SetValue(min(1, max(0, frac)))
        r.bar:SetFill(done and "pos" or "gold")
    end
    r.tip, r.go = tip, go
    r:Show()
end

local function caption(parent)
    local h = K.SectionHead(parent, "")
    h:SetWidth(W - 24)
    UI.Skin.Add(h, function(s) K.Recolor(s.text, "railGold") end)
    return h
end

-- the size the player chose (mouse wheel over the head)
local function scale() return max(0.7, min(1.5, tonumber(WFD.S.compScale) or 1)) end

local function build()
    local f = K.Box(UIParent, "panel", "gold")
    _G.WoWForeverDiaryCompanion = f
    f:SetSize(W, 100)
    f:SetFrameStrata("MEDIUM")
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetScale(scale())
    K.Material(f, "dark")
    local p = WFD.S.compPos
    if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("RIGHT", UIParent, "RIGHT", -40, 120) end

    -- the head: the day, folding and closing; dragged to move the window (unless it is locked), the mouse wheel
    -- changes its size, a click opens Start
    local head = CreateFrame("Button", nil, f)
    head:SetPoint("TOPLEFT", 1, -1)
    head:SetPoint("TOPRIGHT", -1, -1)
    head:SetHeight(28)
    head:RegisterForDrag("LeftButton")
    head:SetScript("OnDragStart", function() if not WFD.S.compLocked then f:StartMoving() end end)
    head:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local a, _, b, x, y = f:GetPoint(1)
        WFD.S.compPos = { a, b, x, y }
    end)
    head:EnableMouseWheel(true)
    head:SetScript("OnMouseWheel", function(_, delta)
        WFD.S.compScale = floor((scale() + (delta > 0 and 0.05 or -0.05)) * 100 + 0.5) / 100
        f:SetScale(scale())
    end)
    K.Tip(head, L["Today"], { L["Click for Start."], L["Drag to move."], L["Mouse wheel changes the size."] }, "ANCHOR_TOP")
    local icon = head:CreateTexture(nil, "ARTWORK")
    icon:SetTexture(UI.Icon("journal"))
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:SetSize(18, 18)
    icon:SetPoint("LEFT", 8, 0)
    f.title = K.Text(head, "strong", "railTitle")
    f.title:SetPoint("LEFT", icon, "RIGHT", 7, 0)
    f.title:SetWordWrap(false)
    f.close = K.IconButton(head, "close", { L["Close"] }, function()
        WFD.S.companion = false
        f:Hide()
        print("|cffffd100WoW Forever Diary:|r " .. L["The companion can be shown again in the settings or with /wfd companion."])
    end, 22)
    f.close:SetFlat(true)
    f.close:SetPoint("RIGHT", -4, 0)
    f.fold = K.IconButton(head, "minus", { L["Fold in or out"] }, function()
        WFD.S.compCollapsed = not WFD.S.compCollapsed
        UI:UpdateCompanion(true)
    end, 22)
    f.fold:SetFlat(true)
    f.fold:SetPoint("RIGHT", f.close, "LEFT", -2, 0)
    head:SetScript("OnClick", function() openAt({ view = "start" }) end)
    f.rule = K.GoldRule(f, false)
    f.rule:SetPoint("TOPLEFT", 8, -29)
    f.rule:SetPoint("TOPRIGHT", -8, -29)

    local body = CreateFrame("Frame", nil, f)
    body:SetPoint("TOPLEFT", 12, -38)
    body:SetPoint("TOPRIGHT", -12, -38)
    body:SetHeight(10)
    f.body = body

    -- the day so far: six figures in tiles, as on Start
    f.stats = {}
    local tw = (W - 24 - 8) / 3
    for i = 1, 6 do
        local col, row = (i - 1) % 3, floor((i - 1) / 3)
        local t = K.Box(body, "inset", nil)
        t:SetSize(tw, 38)
        t:SetPoint("TOPLEFT", col * (tw + 4), -row * 42)
        t.v = K.Text(t, "strong", "ink")
        t.v:SetPoint("TOPLEFT", 6, -5)
        t.v:SetWordWrap(false)
        t.l = K.Text(t, "small", "muted")
        t.l:SetPoint("TOPLEFT", t.v, "BOTTOMLEFT", 0, -1)
        t.l:SetWordWrap(false)
        t.l:SetWidth(tw - 10)
        f.stats[i] = t
    end
    f.capTasks = caption(body)
    f.capWeek = caption(body)
    f.capHon = caption(body)
    f.capNext = caption(body)
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
    comp.fold.glyph:SetShape(folded and "plus" or "minus")
    comp.body:SetShown(not folded)
    comp.rule:SetShown(not folded)
    if folded then comp:SetHeight(30) return end

    local net = (WFD:Sum(d.income or {}) or 0) - (WFD:Sum(d.spend or {}) or 0)
    local stats = {
        { tostring(d.killTotal or 0), L["Slain"] }, { tostring(#(d.qd or {})), L["Quests"] },
        { tostring(d.xp or 0), L["Experience"] }, { tostring(km(d.steps)), L["km"] },
        { (net < 0 and "-" or "") .. UI.CoinIcons(net, 11), L["Gold"] }, { WFD:DurationText(d.online or 0), L["Online"] },
    }
    for i, s in ipairs(stats) do
        local box = comp.stats[i]
        box.v:SetText(s[1])
        UI.FitText(box.v, box:GetWidth() - 10, UI.FS(14), UI.FS(9), UI.FONT)
        box.l:SetText(s[2])
    end

    local y = -92
    local used = 0
    for _, cap in ipairs({ comp.capTasks, comp.capWeek, comp.capHon, comp.capNext }) do cap:Hide() end
    local function place(cap, label, right)
        cap:ClearAllPoints()
        cap:SetPoint("TOPLEFT", comp.body, "TOPLEFT", 0, y)
        cap:Set(label, right)
        cap:Show()
        y = y - 22
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
    local goals = { view = "tasks" }

    -- tasks of the day
    local tasks = WFD.TodayChallenges and WFD:TodayChallenges()
    if tasks and #tasks.list > 0 then
        local doneN = 0
        for _ in pairs(tasks.done) do doneN = doneN + 1 end
        place(comp.capTasks, L["Tasks of the day"], doneN .. " / " .. #tasks.list)
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
                { L[e.def.name], WFD:HonourText(e.def, e.next) }, { view = "honour", sort = "next" })
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
            { near.m.name or "?", what }, { view = "bestiary", sort = "next" })
    end
    for i = used + 1, #comp.rows do comp.rows[i]:Hide() end
    comp.body:SetHeight(-y)
    comp:SetHeight(38 + (-y) + 6)
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
