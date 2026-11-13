-- Goals on the travel desk: the tasks (day, week, month and your own goals) and the collection (how far each
-- collection has come). Cards like on Start, every line leads on.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local max, min, format = math.max, math.min, string.format

local PAD, GAP = 16, 14
local MAX_GOALS = 10

-- a card with a heading; lines are added by the view
local function card(parent, title)
    local c = K.Card(parent)
    c.head = K.SectionHead(c, title)
    c.head:SetPoint("TOPLEFT", PAD, -PAD)
    c.head:SetPoint("RIGHT", c, "RIGHT", -PAD, 0)
    return c
end

-- one task: a box (ticked when done), the text, below it a bar with the figures
local function taskLine(parent)
    local r = CreateFrame("Frame", nil, parent)
    r.box = K.Box(r, nil, "muted")
    r.box:SetSize(18, 18)
    r.box:SetPoint("TOPLEFT", 0, 0)
    r.tick = K.Glyph(r.box, "check", 14, "pos")
    r.tick:SetPoint("CENTER")
    r.text = K.Text(r, "body", "ink")
    r.text:SetPoint("TOPLEFT", r.box, "TOPRIGHT", 10, 0)
    r.text:SetSpacing(2)
    r.value = K.Text(r, "small", "soft", "RIGHT")
    r.bar = K.Bar(r, 6)
    function r:Set(text, done, value, frac, fill)
        self.text:SetText(text)
        self.tick:SetShown(done)
        self.box.borderKey = done and "pos" or "muted"
        K.Repaint(self.box)
        K.Recolor(self.text, done and "soft" or "ink")
        self.value:SetText(done and L["done"] or (value or ""))
        K.Recolor(self.value, done and "pos" or "soft")
        self.showBar = not done and frac ~= nil
        self.bar:SetValue(frac or 0)
        self.bar:SetFill(fill or "gold")
    end
    function r:Measure(w)
        self:SetWidth(w)
        self.text:SetWidth(w - 28)
        local y = max(18, self.text:GetStringHeight()) + 6
        self.value:ClearAllPoints()
        self.value:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -y)
        self.bar:ClearAllPoints()
        self.bar:SetShown(self.showBar)
        if self.showBar then
            self.bar:SetPoint("TOPLEFT", self, "TOPLEFT", 28, -y - 4)
            self.bar:SetWidth(max(20, w - 28 - self.value:GetStringWidth() - 12))
        end
        local h = y + max(14, self.value:GetStringHeight()) + 2
        self:SetHeight(h)
        return h
    end
    return r
end

-- figures in a row of tiles
local function tilesRow(parent, n)
    local f = CreateFrame("Frame", nil, parent)
    f.tiles = {}
    for i = 1, n do
        local t = K.Box(f, "inset", nil)
        t.value = K.Text(t, "value", "ink")
        t.value:SetPoint("TOPLEFT", 10, -8)
        t.label = K.Text(t, "small", "muted")
        t.label:SetPoint("TOPLEFT", t.value, "BOTTOMLEFT", 0, -3)
        f.tiles[i] = t
    end
    function f:Set(list)
        for i, t in ipairs(self.tiles) do
            t.value:SetText(list[i] and list[i][1] or "")
            t.label:SetText(list[i] and list[i][2] or "")
        end
    end
    function f:Measure(w)
        local n = #self.tiles
        local tw = (w - (n - 1) * 10) / n
        local th = 0
        for i, t in ipairs(self.tiles) do
            t.label:SetWidth(tw - 16)
            th = max(th, 8 + t.value:GetStringHeight() + 3 + t.label:GetStringHeight() + 9)
        end
        for i, t in ipairs(self.tiles) do
            t:SetSize(tw, th)
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", self, "TOPLEFT", (i - 1) * (tw + 10), 0)
        end
        self:SetSize(w, th)
        return th
    end
    return f
end

-- lays cards out in one or two columns; rows = { { card, card }, { card } ... } (a single card spans the row)
local function arrange(scroll, rows, W)
    local area = scroll.content
    local y = 20
    local inner = W - 40
    for _, row in ipairs(rows) do
        local two = #row == 2 and inner >= 760
        if two then
            local cw = (inner - GAP) / 2
            local h1, h2 = row[1]:Measure(cw), row[2]:Measure(cw)
            local h = max(h1, h2)
            for i, cd in ipairs(row) do
                cd:ClearAllPoints()
                cd:SetPoint("TOPLEFT", area, "TOPLEFT", 20 + (i - 1) * (cw + GAP), -y)
                cd:SetHeight(h)
            end
            y = y + h + GAP
        else
            for _, cd in ipairs(row) do
                local h = cd:Measure(min(inner, 900))
                cd:ClearAllPoints()
                cd:SetPoint("TOPLEFT", area, "TOPLEFT", 20, -y)
                cd:SetHeight(h)
                y = y + h + GAP
            end
        end
    end
    scroll:SetContentHeight(y + 6)
end

------------------------------------------------------------------------
-- Tasks
------------------------------------------------------------------------
UI.PART_VIEW.tasks = "tasks"
UI.VIEW_PLACE.tasks = { "goals", "tasks" }
UI.PART_LABEL.tasks = "Tasks"

UI:RegisterView({
    key = "tasks",
    build = function(host)
        local v = {}
        local scroll = K.Scroll(host)
        scroll:SetAllPoints(host)
        local area = scroll.content

        -- the day
        local day = card(area, L["Tasks of the day"])
        day.lines = {}
        day.tiles = tilesRow(day, 3)
        function day:Fill()
            local tasks = WFD.TodayChallenges and WFD:TodayChallenges()
            local list = tasks and tasks.list or {}
            local today = WFD:DayIndex()
            local doneN = 0
            for i, task in ipairs(list) do
                local l = self.lines[i] or taskLine(self)
                self.lines[i] = l
                local done = tasks.done[i] and true or false
                if done then doneN = doneN + 1 end
                local val, gl = WFD:ChallengeProgress(today, task)
                l:Set(WFD:ChallengeText(task), done, gl > 1 and (WFD:TaskValueText(task, val) .. " / " .. gl) or nil,
                    gl > 1 and val / max(1, gl) or nil, "pos")
                l:Show()
            end
            for i = #list + 1, #self.lines do self.lines[i]:Hide() end
            self.n = #list
            self.head:Set(L["Tasks of the day"], #list > 0 and (doneN .. " / " .. #list) or nil)
            local full, total, best = WFD:ChallengeStats()
            self.tiles:Set({ { full, L["Perfect days"] }, { best, L["Longest run"] }, { total, L["Tasks done"] } })
        end
        function day:Measure(w)
            self:SetWidth(w)
            local y = PAD + 18 + 12
            for i = 1, self.n or 0 do
                local l = self.lines[i]
                l:ClearAllPoints()
                l:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                y = y + l:Measure(w - 2 * PAD) + 8
            end
            y = y + 6
            self.tiles:ClearAllPoints()
            self.tiles:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            return y + self.tiles:Measure(w - 2 * PAD) + PAD
        end

        -- the week and the month
        local long = card(area, L["Task of the week"])
        long.week = taskLine(long)
        long.monthHead = K.SectionHead(long, L["Task of the month"])
        long.month = taskLine(long)
        long.tiles = tilesRow(long, 2)
        function long:Fill()
            local wk, w
            if WFD.ThisWeek then wk, w = WFD:ThisWeek() end
            self.hasWeek = wk and wk.task and true or false
            if self.hasWeek then
                local from, to = WFD:WeekDays(w)
                self.head:Set(L["Task of the week"], format(L["Days %d-%d"], from, to))
                local val, gl = WFD:WeeklyProgress(w, wk.task)
                self.week:Set(WFD:WeeklyText(wk.task), wk.done, WFD:TaskValueText(wk.task, val) .. " / " .. gl, val / max(1, gl), "gold")
            end
            self.week:SetShown(self.hasWeek)
            local mo, m
            if WFD.ThisMonth then mo, m = WFD:ThisMonth() end
            self.hasMonth = mo and mo.task and true or false
            if self.hasMonth then
                local from, to = WFD:MonthDays(m)
                self.monthHead:Set(L["Task of the month"], format(L["Days %d-%d"], from, to))
                local val, gl = WFD:MonthlyProgress(m, mo.task)
                self.month:Set(WFD:MonthlyText(mo.task), mo.done, WFD:TaskValueText(mo.task, val) .. " / " .. gl, val / max(1, gl), "gold")
            end
            self.monthHead:SetShown(self.hasMonth)
            self.month:SetShown(self.hasMonth)
            local months = 0
            for _, e in pairs(WFD.C and WFD.C.monthly or {}) do if e.done then months = months + 1 end end
            self.tiles:Set({ { WFD:WeeksDone(), L["Weeks done"] }, { months, L["Months done"] } })
        end
        function long:Measure(w)
            self:SetWidth(w)
            local y = PAD + 18 + 12
            if self.hasWeek then
                self.week:ClearAllPoints()
                self.week:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                y = y + self.week:Measure(w - 2 * PAD) + 14
            end
            if self.hasMonth then
                self.monthHead:ClearAllPoints()
                self.monthHead:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                self.monthHead:SetWidth(w - 2 * PAD)
                y = y + 30
                self.month:ClearAllPoints()
                self.month:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                y = y + self.month:Measure(w - 2 * PAD) + 14
            end
            self.tiles:ClearAllPoints()
            self.tiles:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            return y + self.tiles:Measure(w - 2 * PAD) + PAD
        end

        -- your own goals
        local own = card(area, L["My own goals"])
        own.rows = {}
        own.none = K.Text(own, "body", "soft")
        own.none:SetText(L["Write down what you want to do next, and tick it off when it is done."])
        own.add = K.Button(own, L["Add a goal"], "primary", function()
            UI:Ask({
                title = L["What do you want to do next?"], ok = L["Add a goal"], input = { max = 48 },
                onOk = function(text)
                    text = strtrim(text or "")
                    local C = WFD.C
                    if text == "" then return end
                    C.myGoals = C.myGoals or {}
                    if #C.myGoals < MAX_GOALS then C.myGoals[#C.myGoals + 1] = { text = text } end
                    v:Refresh()
                end,
            })
        end)
        own.full = K.Text(own, "small", "muted")
        own.full:SetText(format(L["%d goals at most: tick one off or remove it first."], MAX_GOALS))
        function own:Fill()
            local list = WFD.C.myGoals or {}
            local doneN = 0
            for i, g in ipairs(list) do
                if g.done then doneN = doneN + 1 end
                local r = self.rows[i]
                if not r then
                    r = CreateFrame("Button", nil, self)
                    r.box = K.Box(r, nil, "muted")
                    r.box:SetSize(18, 18)
                    r.box:SetPoint("LEFT", 0, 0)
                    r.box:EnableMouse(false)
                    r.tick = K.Glyph(r.box, "check", 14, "pos")
                    r.tick:SetPoint("CENTER")
                    r.text = K.Text(r, "body", "ink")
                    r.text:SetPoint("LEFT", r.box, "RIGHT", 10, 0)
                    r.text:SetWordWrap(false)
                    r.del = K.IconButton(r, "close", { L["Remove this goal"] }, function(b)
                        table.remove(WFD.C.myGoals, b.index)
                        v:Refresh()
                    end, 24)
                    r.del:SetFlat(true)
                    r.del:SetPoint("RIGHT", 0, 0)
                    r:SetHeight(28)
                    r:SetScript("OnClick", function(b)
                        local gg = WFD.C.myGoals[b.index]
                        if gg then gg.done = not gg.done or nil end
                        v:Refresh()
                    end)
                    self.rows[i] = r
                end
                r.index, r.del.index = i, i
                r.text:SetText(g.text)
                r.tick:SetShown(g.done and true or false)
                r.box.borderKey = g.done and "pos" or "muted"
                K.Repaint(r.box)
                K.Recolor(r.text, g.done and "soft" or "ink")
                r:Show()
            end
            for i = #list + 1, #self.rows do self.rows[i]:Hide() end
            self.n = #list
            self.head:Set(L["My own goals"], #list > 0 and (doneN .. " / " .. #list) or nil)
            self.add:SetEnabled(#list < MAX_GOALS)
        end
        function own:Measure(w)
            self:SetWidth(w)
            local y = PAD + 18 + 12
            for i = 1, self.n or 0 do
                local r = self.rows[i]
                r:ClearAllPoints()
                r:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                r:SetWidth(w - 2 * PAD)
                r.text:SetWidth(w - 2 * PAD - 28 - 30)
                y = y + 30
            end
            self.none:SetShown((self.n or 0) == 0)
            if (self.n or 0) == 0 then
                self.none:SetWidth(w - 2 * PAD)
                self.none:ClearAllPoints()
                self.none:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                y = y + self.none:GetStringHeight() + 10
            end
            y = y + 6
            self.add:ClearAllPoints()
            self.add:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            self.full:SetShown(not self.add:IsEnabled())
            self.full:ClearAllPoints()
            self.full:SetPoint("LEFT", self.add, "RIGHT", 12, 0)
            self.full:SetWidth(max(60, w - 2 * PAD - self.add:GetWidth() - 12))
            return y + self.add:GetHeight() + PAD
        end

        local cards = { day, long, own }
        function v:Arrange()
            local W = self.w or scroll:GetWidth() or 0
            if W <= 0 then return end
            arrange(scroll, { { day, long }, { own } }, W)
        end
        function v:Refresh()
            for _, cd in ipairs(cards) do
                local ok, err = pcall(cd.Fill, cd)
                if not ok then WFD:Error("tasks", err) end
            end
            self:Arrange()
        end
        function v:Show() self:Refresh() end
        function v:Layout(w, h) self.w = w self:Arrange() end
        scroll.onResize = function(sf) v.w = sf:GetWidth() v:Arrange() end
        UI.OnRestyle(function() if host:IsShown() then v:Arrange() end end)
        function v:Head()
            local g = UI.NAV_GROUP.goals
            return L["Tasks"], L[g.label], UI.GroupRoute(g)
        end
        return v
    end,
})

------------------------------------------------------------------------
-- Collection
------------------------------------------------------------------------
UI.PART_VIEW.collection = "collection"
UI.VIEW_PLACE.collection = { "goals", "collection" }
UI.PART_LABEL.collection = "Collection"

local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"

UI:RegisterView({
    key = "collection",
    build = function(host)
        local v = { rows = {} }
        local scroll = K.Scroll(host)
        scroll:SetAllPoints(host)
        local area = scroll.content

        local function makeRow()
            local r = K.Box(area, "card", "line", "Button")
            r.ring = UI.Circle(r, 40, { 1, 1, 1, 1 }, "ARTWORK", 0)
            r.ring:SetPoint("LEFT", 14, 0)
            r.icon = r:CreateTexture(nil, "ARTWORK", nil, 2)
            r.icon:SetSize(32, 32)
            r.icon:SetPoint("CENTER", r.ring, "CENTER")
            r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            UI.Round(r.icon, r)
            r.name = K.Text(r, "heading", "title")
            r.name:SetPoint("TOPLEFT", r.ring, "TOPRIGHT", 14, 6)
            r.count = K.Text(r, "value", "ink", "RIGHT")
            r.count:SetPoint("TOPRIGHT", -16, -12)
            r.sub = K.Text(r, "small", "soft")
            r.sub:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3)
            r.bar = K.Bar(r, 6)
            r.bar:SetPoint("BOTTOMLEFT", r.ring, "BOTTOMRIGHT", 14, -4)
            r.bar:SetPoint("RIGHT", r, "RIGHT", -16, 0)
            r:SetHeight(72)
            r:SetScript("OnEnter", function(self) self:SetSurface("hover", "gold") end)
            r:SetScript("OnLeave", function(self) self:SetSurface("card", "line") end)
            r:SetScript("OnClick", function(self) if self.key then R.Go(UI.PartRoute(self.key)) end end)
            return r
        end

        function v:Fill()
            local g = UI.CollectionState()
            local beast = g.nextTier or g.lastTier or { 10, "Bronze" }
            local fish = g.nextFish or g.lastFish or { 5 }
            self.items = {
                { L["Book of honour"], g.sum.tiers, g.sum.totalTiers, UI.Icon("honour"), { 0.86, 0.62, 0.18 },
                    format(L["%d honour points"], g.sum.points), "honour" },
                { L["Landmarks"], g.lmFound, g.lmTotal, UI.Icon("sight"), { 0.30, 0.66, 0.62 }, L["Famous places of Azeroth"], "landmarks" },
                { L["Atlas"], g.zVisited, g.zTotal, UI.Icon("map"), { 0.40, 0.72, 0.35 }, L["Regions explored"], "atlas" },
                { L["Bestiary"], g.kinds, beast[1], UI.Icon("bestiary"), { 0.85, 0.40, 0.32 },
                    g.nextTier and format(L["Next rank: %s"], L[g.nextTier[2]]) or L["Complete!"], "bestiary" },
                { L["Angler's log"], g.catches, fish[1], UI.Icon("fish"), { 0.30, 0.58, 0.86 },
                    g.nextFish and format(L["Next rank: %s"], L[g.nextFish[2]]) or L["Complete!"], "fishbook" },
                { L["Dungeons"] .. " & " .. L["Raids"], g.dFound, g.dTotal, UI.Icon("key"), { 0.78, 0.42, 0.08 },
                    L["Dark places, rich rewards"], "landmarks" },
                { L["Secrets"], g.sFound, g.sTotal, QUESTION, { 0.70, 0.45, 0.85 },
                    L["Some honours stay hidden until you find them."], "honour" },
            }
            for i, it in ipairs(self.items) do
                local r = self.rows[i] or makeRow()
                self.rows[i] = r
                local total = max(1, it[3])
                local frac = min(1, it[2] / total)
                local col = it[2] > 0 and it[5] or { 0.46, 0.39, 0.30 }
                r.ring:SetVertexColor(col[1], col[2], col[3], 1)
                r.icon:SetTexture(it[4])
                r.icon:SetDesaturated(it[2] == 0)
                r.name:SetText(it[1])
                r.count:SetText(it[2] .. " / " .. it[3])
                r.sub:SetText(it[6])
                r.bar:SetValue(frac)
                r.bar:SetFill(nil, it[5])
                r.key = it[7]
                r:Show()
            end
        end
        function v:Arrange()
            local W = self.w or scroll:GetWidth() or 0
            if W <= 0 then return end
            local w = min(W - 40, 820)
            local y = 20
            for i, r in ipairs(self.rows) do
                r:ClearAllPoints()
                r:SetPoint("TOPLEFT", area, "TOPLEFT", 20, -y)
                r:SetWidth(w)
                r.name:SetWidth(w - 80 - r.count:GetStringWidth() - 30)
                r.sub:SetWidth(w - 80 - 30)
                y = y + 72 + 10
            end
            scroll:SetContentHeight(y + 10)
        end
        function v:Refresh()
            local ok, err = pcall(self.Fill, self)
            if not ok then WFD:Error("collection", err) end
            self:Arrange()
        end
        function v:Show() self:Refresh() end
        function v:Layout(w, h) self.w = w self:Arrange() end
        scroll.onResize = function(sf) v.w = sf:GetWidth() v:Arrange() end
        UI.OnRestyle(function() if host:IsShown() then v:Arrange() end end)
        function v:Head()
            local g = UI.NAV_GROUP.goals
            return L["Collection"], L[g.label], UI.GroupRoute(g)
        end
        return v
    end,
})
