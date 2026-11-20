-- Start: what you want to know when you open the diary. Today in figures and a few lines, the tasks, what is new
-- since you last read, a memory, the destination of the day, the honour closest to its next tier, and how far
-- every collection has come. Every card leads on with one click.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

local PAD, GAP = 16, 14

------------------------------------------------------------------------
-- Small parts of the cards
------------------------------------------------------------------------
local function tile(parent)
    local t = K.Box(parent, "inset", "line", "Button")
    t.value = K.Text(t, "value", "ink")
    t.value:SetPoint("TOPLEFT", 10, -8)
    t.value:SetPoint("RIGHT", -8, 0)
    t.value:SetWordWrap(false)
    t.label = K.Text(t, "small", "muted")
    t.label:SetPoint("TOPLEFT", t.value, "BOTTOMLEFT", 0, -3)
    t.label:SetPoint("RIGHT", -8, 0)
    t.label:SetWordWrap(false)
    t:SetScript("OnEnter", function(self) if self.go then self:SetSurface("hover", "gold") end end)
    t:SetScript("OnLeave", function(self) self:SetSurface("inset", "line") end)
    t:SetScript("OnClick", function(self) if self.go then self.go() end end)
    function t:Height() return 8 + self.value:GetStringHeight() + 3 + self.label:GetStringHeight() + 9 end
    return t
end

-- a line that leads somewhere: a coloured dot, the text, a figure, an arrow
local function leadRow(parent)
    local r = K.Box(parent, nil, nil, "Button")
    r.dot = r:CreateTexture(nil, "ARTWORK")
    r.dot:SetTexture(UI.WHITE)
    r.dot:SetSize(8, 8)
    r.dot:SetPoint("LEFT", 6, 0)
    r.arrow = K.Glyph(r, "right", 10, "muted")
    r.arrow:SetPoint("RIGHT", -6, 0)
    r.count = K.Text(r, "strong", "gold", "RIGHT")
    r.count:SetPoint("RIGHT", r.arrow, "LEFT", -8, 0)
    r.text = K.Text(r, "body", "ink")
    r.text:SetPoint("LEFT", r.dot, "RIGHT", 10, 0)
    r.text:SetPoint("RIGHT", r.count, "LEFT", -8, 0)
    r.text:SetWordWrap(false)
    r:SetHeight(30)
    r:SetScript("OnEnter", function(self) self:SetSurface("hover") end)
    r:SetScript("OnLeave", function(self) self:SetSurface(nil) end)
    r:SetScript("OnClick", function(self) if self.go then self.go() end end)
    return r
end

-- a task with its box: ticked when done
local function taskRow(parent)
    -- a task not yet done leads to where it is taken on (UI.TaskLink, Goals.lua)
    local r = K.Box(parent, nil, nil, "Button")
    UI.TaskLink(r)
    r.box = K.CheckBox(r)
    r.text = K.Text(r, "body", "ink")
    r.value = K.Text(r, "small", "soft", "RIGHT")
    r.value:SetPoint("TOPRIGHT", 0, -1)
    function r:Set(text, done, value)
        self.text:SetText(text)
        self.box:SetDone(done)
        K.Recolor(self.text, done and "soft" or "ink")
        self.value:SetText(value or "")
    end
    function r:Measure(w)
        local size = self.box:Beside(self.text, 0)
        self.text:ClearAllPoints()
        self.text:SetPoint("TOPLEFT", self, "TOPLEFT", size + 10, 0)
        local vw = (self.value:GetText() or "") ~= "" and (self.value:GetStringWidth() + 10) or 0
        self.text:SetWidth(max(40, w - size - 10 - vw))
        local h = max(20, self.text:GetStringHeight() + 4)
        self:SetSize(w, h)
        return h
    end
    return r
end

local function head(card, text)
    card.head = K.SectionHead(card, text)
    card.head:SetPoint("TOPLEFT", PAD, -PAD)
    card.head:SetPoint("RIGHT", card, "RIGHT", -PAD, 0)
    return card.head
end

------------------------------------------------------------------------
-- The cards
------------------------------------------------------------------------
local cards = {}

-- Today: the day in four figures, its mood and its first lines
function cards.today(parent)
    local c = K.Section(parent)
    c.title = K.Text(c, "display", "title")
    c.title:SetPoint("TOPLEFT", PAD + 2, -PAD)
    c.title:SetText(L["Today"])
    c.date = K.Text(c, "body", "soft")
    c.date:SetPoint("BOTTOMLEFT", c.title, "BOTTOMRIGHT", 12, 3)
    c.mood = K.Box(c, "inset", "line")
    c.mood.text = K.Text(c.mood, "small", "soft", "CENTER")
    c.mood.text:SetPoint("CENTER", 0, 0)
    c.tiles = {}
    for i = 1, 4 do c.tiles[i] = tile(c) end
    c.margin = K.Text(c, "small", "rubric")
    c.margin:SetWordWrap(true)
    c.story = K.Text(c, "body", "ink")
    c.story:SetSpacing(3)
    if c.story.SetMaxLines then c.story:SetMaxLines(5) end
    c.read = K.Button(c, L["Read today's entry"], "primary", function() R.Go(UI.PartRoute("diary")) end)
    c.resume = K.Button(c, "", "secondary")

    function c:Fill()
        local C = WFD.C
        local day = WFD:NumDays()
        local d = C.days[day] or {}
        self.date:SetText(WFD:LongDate(day) .. "  -  " .. format(L["Day %d"], day))
        local mood = WFD.DayMood and WFD:DayMood(d)
        self.mood.text:SetText(mood and L[mood] or "")
        self.mood:SetShown(mood ~= nil)
        local net = WFD:Sum(d.income or {}) - WFD:Sum(d.spend or {})
        local vals = {
            { d.killTotal or 0, L["Kills"], "bestiary" },
            { #(d.qd or {}), L["Quests"], "quests" },
            { WFD:Dec((d.steps or 0) * 0.9144 / 1000) .. " km", L["on foot"], "atlas" },
            { (net < 0 and "-" or "+") .. UI.CoinIcons(net, 13), L["Gold today"], "ledger", net < 0 and "neg" or "pos" },
        }
        local line = {}
        for _, v in ipairs(vals) do line[#line + 1] = v[1] .. " " .. v[2] end
        self.margin:SetText(table.concat(line, "   |   "))
        -- the way to the day: a link in ink in the book, a gilded button elsewhere
        local book = K.IsBook()
        self.read.style = book and "ghost" or "primary"
        self.resume.style = book and "ghost" or "secondary"
        K.Repaint(self.read)
        K.Repaint(self.resume)
        for i, v in ipairs(vals) do
            local t = self.tiles[i]
            t.value:SetText(v[1])
            K.Recolor(t.value, v[4] or "ink")
            t.label:SetText(v[2])
            t.go = function() R.Go(UI.PartRoute(v[3])) end
        end
        local story = WFD:Narrate(day) or ""
        local paras = {}
        for p in (story .. "\n\n"):gmatch("(.-)\n\n") do
            if p ~= "" and #paras < 2 then paras[#paras + 1] = p end
        end
        self.story:SetText(table.concat(paras, " "))
        -- the day last read in the diary, when it is not the newest
        local rd = WFD.C.readDay
        local resume = rd and rd ~= day and WFD.C.days[rd]
        self.resume:SetShown(resume and true or false)
        if resume then
            self.resume:SetLabel(format(L["Continue reading: %s"], L["Diary"] .. ", " .. format(L["Day %d"], rd)))
            self.resume.onClick = function() UI:OpenShell({ view = "diary", day = rd }) end
        end
    end

    function c:Measure(w)
        self:SetWidth(w)
        local y = PAD + self.title:GetStringHeight() + 12
        self.mood:ClearAllPoints()
        self.mood:SetPoint("TOPRIGHT", self, "TOPRIGHT", -PAD, -PAD - 4)
        self.mood:SetSize(self.mood.text:GetStringWidth() + 20, 24)
        -- in the book: the figures as one line in the margin, the story right below
        local book = K.IsBook()
        self.margin:SetShown(book)
        for _, t in ipairs(self.tiles) do t:SetShown(not book) end
        if book then
            self.margin:SetWidth(w - 2 * PAD)
            self.margin:ClearAllPoints()
            self.margin:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y + 4)
            y = y + self.margin:GetStringHeight() + 10
            self.story:SetWidth(min(w - 2 * PAD, 640))
            self.story:ClearAllPoints()
            self.story:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            y = y + self.story:GetStringHeight() + 10
            self.read:ClearAllPoints()
            self.read:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 6, -y)
            self.resume:ClearAllPoints()
            self.resume:SetPoint("LEFT", self.read, "RIGHT", 6, 0)
            return y + self.read:GetHeight() + PAD
        end
        local cols = (w >= 520 * UI.FK()) and 4 or 2          -- two to a row when the writing is big or the card narrow
        local tw = (w - 2 * PAD - (cols - 1) * 10) / cols
        local th = 0
        for i, t in ipairs(self.tiles) do
            t:SetWidth(tw)
            th = max(th, t:Height())
        end
        for i, t in ipairs(self.tiles) do
            local col, row = (i - 1) % cols, floor((i - 1) / cols)
            t:SetHeight(th)
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", self, "TOPLEFT", PAD + col * (tw + 10), -y - row * (th + 10))
        end
        local rows = floor((#self.tiles - 1) / cols) + 1
        y = y + rows * th + (rows - 1) * 10 + 14
        self.story:SetWidth(min(w - 2 * PAD, 640))
        self.story:ClearAllPoints()
        self.story:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
        y = y + self.story:GetStringHeight() + 14
        self.read:ClearAllPoints()
        self.read:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
        self.resume:ClearAllPoints()
        self.resume:SetPoint("LEFT", self.read, "RIGHT", 10, 0)
        return y + self.read:GetHeight() + PAD
    end
    return c
end

-- the tasks of the day and of the week
function cards.tasks(parent)
    local c = K.Section(parent)
    head(c, L["Tasks of the day"])
    c.rows = {}
    c.rule = K.Rule(c, "line")
    c.week = K.Text(c, "small", "soft")
    c.weekBar = K.Bar(c, 8, "gold")
    c.weekValue = K.Text(c, "small", "ink", "RIGHT")
    c.none = K.Text(c, "body", "soft")
    c.all = K.Button(c, L["All tasks and own goals"], "ghost", function() R.Go(UI.PartRoute("tasks")) end)

    function c:Fill()
        local tasks = WFD.TodayChallenges and WFD:TodayChallenges()
        local list = tasks and tasks.list or {}
        local today = WFD:DayIndex()
        local doneN = 0
        for i, task in ipairs(list) do
            local r = self.rows[i] or taskRow(self)
            self.rows[i] = r
            local done = tasks.done[i] and true or false
            if done then doneN = doneN + 1 end
            local v, gl = WFD:ChallengeProgress(today, task)
            local val = (not done and gl and gl > 1) and (WFD:TaskValueText(task, v) .. " / " .. gl) or nil
            r:Set(WFD:ChallengeText(task), done, val)
            r:SetTask(not done and task or nil)
            r:Show()
        end
        for i = #list + 1, #self.rows do self.rows[i]:Hide() end
        self.count = #list
        self.head:Set(L["Tasks of the day"], #list > 0 and (doneN .. " / " .. #list) or nil)
        self.none:SetShown(#list == 0)
        self.none:SetText(L["No tasks today."])
        local wk, w
        if WFD.ThisWeek then wk, w = WFD:ThisWeek() end
        self.hasWeek = wk and wk.task and true or false
        if self.hasWeek then
            local v, gl = WFD:WeeklyProgress(w, wk.task)
            self.week:SetText(L["Task of the week"] .. ": " .. WFD:WeeklyText(wk.task))
            self.weekBar:SetValue(wk.done and 1 or (v / max(1, gl)))
            self.weekBar:SetFill("gold")
            self.weekValue:SetText(wk.done and L["done"] or (WFD:TaskValueText(wk.task, v) .. " / " .. gl))
        end
        for _, f in ipairs({ self.rule, self.week, self.weekBar, self.weekValue }) do f:SetShown(self.hasWeek) end
    end

    function c:Measure(w)
        self:SetWidth(w)
        local iw = w - 2 * PAD
        local y = PAD + 18 + 10
        for i = 1, self.count or 0 do
            local r = self.rows[i]
            local h = r:Measure(iw)
            r:ClearAllPoints()
            r:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            y = y + h + 6
        end
        if (self.count or 0) == 0 then
            self.none:SetWidth(iw)
            self.none:ClearAllPoints()
            self.none:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            y = y + self.none:GetStringHeight() + 8
        end
        if self.hasWeek then
            y = y + 4
            self.rule:ClearAllPoints()
            self.rule:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            self.rule:SetPoint("RIGHT", self, "RIGHT", -PAD, 0)
            y = y + 10
            self.week:SetWidth(iw)
            self.week:ClearAllPoints()
            self.week:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            y = y + self.week:GetStringHeight() + 8
            local vw = self.weekValue:GetStringWidth() + 10
            self.weekBar:ClearAllPoints()
            self.weekBar:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y - 3)
            self.weekBar:SetWidth(max(20, iw - vw))
            self.weekValue:ClearAllPoints()
            self.weekValue:SetPoint("TOPRIGHT", self, "TOPRIGHT", -PAD, -y)
            y = y + 20
        end
        self.all:ClearAllPoints()
        self.all:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 10, -y)
        return y + self.all:GetHeight() + PAD - 6
    end
    return c
end

-- what came into the book since it was last put away
function cards.new(parent)
    local c = K.Section(parent)
    head(c, L["New since I last read"])
    c.rows = {}
    c.none = K.Text(c, "body", "soft")
    c.none:SetText(L["Nothing new since I last read."])

    function c:Fill()
        local counts = UI.NewCounts and UI.NewCounts() or {}
        local list, total = {}, 0
        for _, g in ipairs(UI.NAV) do
            for _, key in ipairs(g.parts or {}) do
                local n = counts[key]
                if n and n > 0 and UI.PART_VIEW and UI.PART_VIEW[key] then
                    list[#list + 1] = { key = key, n = n, col = UI.GROUP_COLOURS[g.key] }
                    total = total + n
                end
            end
        end
        self.head:Set(L["New since I last read"], total > 0 and tostring(total) or nil)
        for i, e in ipairs(list) do
            local r = self.rows[i] or leadRow(self)
            self.rows[i] = r
            r.dot:SetVertexColor(e.col[1] * 1.3, e.col[2] * 1.3, e.col[3] * 1.3, 1)
            r.text:SetText(UI.PartLabel(e.key))
            r.count:SetText("+" .. e.n)
            r.go = function() R.Go(UI.PartRoute(e.key)) end
        end
        self.count = min(#list, 7)
        for i, r in ipairs(self.rows) do r:SetShown(i <= self.count) end
        self.none:SetShown(#list == 0)
    end

    function c:Measure(w)
        self:SetWidth(w)
        local y = PAD + 18 + 8
        for i = 1, self.count or 0 do
            local r = self.rows[i]
            r:ClearAllPoints()
            r:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 6, -y)
            r:SetPoint("RIGHT", self, "RIGHT", -PAD + 6, 0)
            y = y + 30
        end
        if (self.count or 0) == 0 then
            self.none:SetWidth(w - 2 * PAD)
            self.none:ClearAllPoints()
            self.none:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y - 2)
            y = y + self.none:GetStringHeight() + 6
        end
        return y + PAD
    end
    return c
end

-- this day in an earlier year, and the anniversaries that are due
function cards.memory(parent)
    local c = K.Section(parent)
    head(c, L["A memory"])
    c.jubilee = K.Text(c, "strong", "title")
    c.jubilee:SetSpacing(2)
    c.text = K.Text(c, "body", "ink")
    c.text:SetSpacing(3)
    if c.text.SetMaxLines then c.text:SetMaxLines(5) end
    c.link = K.Button(c, "", "ghost")

    function c:Fill()
        local jubilees = WFD.Jubilees and WFD:Jubilees() or {}
        local mem = WFD.OnThisDay and WFD:OnThisDay()
        self.head:Set(L["A memory"], mem and WFD:DateStr(mem.idx) or nil)
        self.jubilee:SetText(jubilees[1] and jubilees[1].text or "")
        self.jubilee:SetShown(jubilees[1] ~= nil)
        if mem then
            self.text:SetText(mem.text)
            K.Recolor(self.text, "ink")
        else
            self.text:SetText(L["Nothing to remember on this day yet. In a year, this card tells what happened today."])
            K.Recolor(self.text, "soft")
        end
        self.link:SetShown(mem ~= nil)
        if mem then
            self.link:SetLabel(format(L["Read that day (day %d)"], mem.idx))
            self.link.onClick = function()
                UI:OpenDay(mem.idx)
            end
        end
    end

    function c:Measure(w)
        self:SetWidth(w)
        local iw = w - 2 * PAD
        local y = PAD + 18 + 10
        if self.jubilee:IsShown() then
            self.jubilee:SetWidth(iw)
            self.jubilee:ClearAllPoints()
            self.jubilee:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            y = y + self.jubilee:GetStringHeight() + 8
        end
        self.text:SetWidth(iw)
        self.text:ClearAllPoints()
        self.text:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
        y = y + self.text:GetStringHeight() + 8
        if self.link:IsShown() then
            self.link:ClearAllPoints()
            self.link:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 10, -y)
            y = y + self.link:GetHeight()
        end
        return y + PAD - 4
    end
    return c
end

-- the landmark of the day: a place not seen yet
function cards.destination(parent)
    local c = K.Section(parent)
    head(c, L["Destination of the day"])
    c.icon = c:CreateTexture(nil, "ARTWORK")
    c.icon:SetSize(36, 36)
    c.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    c.name = K.Text(c, "heading", "title")
    c.name:SetWordWrap(false)
    c.kind = K.Text(c, "small", "soft")
    c.go = K.Button(c, "", "ghost")

    function c:Fill()
        local dest = UI.DayDestination and UI.DayDestination(UI.startState)
        self.dest = dest
        if dest then
            self.icon:SetTexture(dest.icon)
            self.name:SetText(dest.name)
            self.kind:SetText(dest.group .. "  -  " .. L["I have not seen this place yet."])
            self.go:SetLabel(dest.go and L["Set a waypoint"] or L["All landmarks"])
            self.go.onClick = function()
                if not (dest.go and dest.go()) then R.Go(UI.PartRoute("landmarks")) end
            end
        else
            self.icon:SetTexture(UI.Icon("sight"))
            self.name:SetText(L["Every landmark seen"])
            self.kind:SetText(L["I have seen every landmark. Remarkable!"])
            self.go:SetLabel(L["All landmarks"])
            self.go.onClick = function() R.Go(UI.PartRoute("landmarks")) end
        end
    end

    function c:Measure(w)
        self:SetWidth(w)
        local y = PAD + 18 + 10
        self.icon:ClearAllPoints()
        self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
        self.name:SetWidth(w - 2 * PAD - 46)
        self.name:ClearAllPoints()
        self.name:SetPoint("TOPLEFT", self.icon, "TOPRIGHT", 10, 1)
        self.kind:SetWidth(w - 2 * PAD - 46)
        self.kind:ClearAllPoints()
        self.kind:SetPoint("TOPLEFT", self.name, "BOTTOMLEFT", 0, -3)
        y = y + max(36, self.name:GetStringHeight() + 3 + self.kind:GetStringHeight()) + 8
        self.go:ClearAllPoints()
        self.go:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 10, -y)
        return y + self.go:GetHeight() + PAD - 6
    end
    return c
end

-- the honours closest to their next tier
function cards.almost(parent)
    local c = K.Section(parent)
    head(c, L["Almost there"])
    c.rows = {}
    for i = 1, 2 do
        local r = CreateFrame("Button", nil, c)
        r.name = K.Text(r, "strong", "ink")
        r.name:SetPoint("TOPLEFT", 0, 0)
        r.name:SetWordWrap(false)
        r.value = K.Text(r, "small", "soft", "RIGHT")
        r.value:SetPoint("TOPRIGHT", 0, -1)
        r.bar = K.Bar(r, 6)
        r.bar:SetPoint("TOPLEFT", 0, -22)
        r.bar:SetPoint("RIGHT", r, "RIGHT", 0, 0)
        r:SetHeight(30)
        r:SetScript("OnClick", function() R.Go(UI.PartRoute("honour")) end)
        c.rows[i] = r
    end
    c.none = K.Text(c, "body", "soft")
    c.none:SetText(L["Every honour is at its highest tier."])

    function c:Fill()
        local g = UI.startState
        local near = {}
        for _, e in ipairs(g and g.honours or {}) do
            if e.next and not e.hidden then
                near[#near + 1] = { e = e, f = (e.value - e.prev) / max(1, e.next - e.prev) }
            end
        end
        table.sort(near, function(a, b) return a.f > b.f end)
        self.count = min(2, #near)
        for i, r in ipairs(self.rows) do
            local n = near[i]
            r:SetShown(n ~= nil and i <= self.count)
            if n then
                local metal = WFD:MetalOf(n.e.tier + 1, n.e.n)
                r.name:SetText(L[n.e.def.name] .. "  |cff" .. UI.Hex(metal.col) .. L[metal.name] .. "|r")
                r.value:SetText(n.e.value .. " / " .. n.e.next)
                r.bar:SetValue(n.f)
                r.bar:SetFill(nil, metal.col)
            end
        end
        self.none:SetShown(self.count == 0)
    end

    function c:Measure(w)
        self:SetWidth(w)
        local y = PAD + 18 + 10
        for i = 1, self.count or 0 do
            local r = self.rows[i]
            r:ClearAllPoints()
            r:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            r:SetWidth(w - 2 * PAD)
            r.name:SetWidth(w - 2 * PAD - r.value:GetStringWidth() - 10)
            y = y + 36
        end
        if (self.count or 0) == 0 then
            self.none:SetWidth(w - 2 * PAD)
            self.none:ClearAllPoints()
            self.none:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            y = y + self.none:GetStringHeight() + 6
        end
        return y + PAD - 6
    end
    return c
end

-- how far every collection has come
local PROGRESS = { "bestiary", "atlas", "honour", "landmarks", "fishbook", "people", "runs", "library" }
function cards.progress(parent)
    local c = K.Section(parent)
    head(c, L["Collections"])
    c.tiles = {}

    function c:Fill()
        local n = 0
        for _, key in ipairs(PROGRESS) do
            local v = UI.PartStat and UI.PartStat(key)
            if v ~= nil and UI.PART_VIEW and UI.PART_VIEW[key] then
                n = n + 1
                local t = self.tiles[n] or tile(self)
                self.tiles[n] = t
                t.value:SetText(v)
                t.label:SetText(UI.PartLabel(key))
                t.go = function() R.Go(UI.PartRoute(key)) end
            end
        end
        self.count = n
        for i, t in ipairs(self.tiles) do t:SetShown(i <= n) end
    end

    function c:Measure(w)
        self:SetWidth(w)
        local y = PAD + 18 + 10
        local n = self.count or 0
        if n == 0 then return y + PAD end
        local perRow = (w >= 760 * UI.FK()) and min(n, 8) or min(n, 4)
        local tw = (w - 2 * PAD - (perRow - 1) * 10) / perRow
        local th = 0
        for i = 1, n do
            self.tiles[i]:SetWidth(tw)
            th = max(th, self.tiles[i]:Height())
        end
        for i = 1, n do
            local t = self.tiles[i]
            local row, col = floor((i - 1) / perRow), (i - 1) % perRow
            t:SetHeight(th)
            t:ClearAllPoints()
            t:SetPoint("TOPLEFT", self, "TOPLEFT", PAD + col * (tw + 10), -(y + row * (th + 10)))
        end
        local rows = floor((n - 1) / perRow) + 1
        return y + rows * (th + 10) - 10 + PAD
    end
    return c
end

-- First steps: five small things that show what the diary can do; ticked off as they are done, gone when all are
-- done or the card is put away
local FIRST_STEPS = {
    { "Read a day in the diary", function(C) return C.readDay ~= nil end, function() R.Go({ view = "diary" }) end },
    { "Set a bookmark below a day", function(C) return #(C.marks or {}) > 0 end, function() R.Go({ view = "diary" }) end },
    { "Search the diary (Ctrl + F)", function(C, S) return S.searched end, function() if UI.FocusSearch then UI:FocusSearch() end end },
    { "Choose a style that suits you", function(C, S) return S.styleChosen end, function() R.Go({ view = "settings", section = 3 }) end },
    { "Show the companion beside the game", function(C, S) return S.companion == true end, function() UI:ShowCompanion(true) end },
}
-- (L["Read a day in the diary"] L["Set a bookmark below a day"] L["Search the diary (Ctrl + F)"]
-- L["Choose a style that suits you"] L["Show the companion beside the game"])

local function stepRow(parent)
    local r = K.Box(parent, nil, nil, "Button")
    r.box = K.CheckBox(r)
    r.box:SetSize(16, 16)
    r.box:SetPoint("LEFT", 6, 0)
    r.arrow = K.Glyph(r, "right", 10, "muted")
    r.arrow:SetPoint("RIGHT", -6, 0)
    r.text = K.Text(r, "body", "ink")
    r.text:SetPoint("LEFT", r.box, "RIGHT", 10, 0)
    r.text:SetPoint("RIGHT", r.arrow, "LEFT", -8, 0)
    r.text:SetWordWrap(false)
    r:SetHeight(30)
    r:SetScript("OnEnter", function(self) self:SetSurface("hover") end)
    r:SetScript("OnLeave", function(self) self:SetSurface(nil) end)
    r:SetScript("OnClick", function(self) if self.go then self.go() end end)
    return r
end

function cards.first(parent)
    local c = K.Section(parent)
    head(c, L["First steps"])
    c.rows = {}
    for i = 1, #FIRST_STEPS do c.rows[i] = stepRow(c) end
    c.hide = K.Button(c, L["Put the card away"], "ghost", function()
        WFD.S.firstStepsHidden = true
        local v = UI.ViewInstance("start")
        if v then v:Refresh() end
    end)
    function c:Fill()
        local C, S = WFD.C, WFD.S
        local doneN = 0
        for i, st in ipairs(FIRST_STEPS) do
            local done = st[2](C, S) and true or false
            if done then doneN = doneN + 1 end
            local r = self.rows[i]
            r.text:SetText(L[st[1]])
            K.Recolor(r.text, done and "soft" or "ink")
            r.box:SetDone(done)
            r.go = st[3]
        end
        self.head:Set(L["First steps"], doneN .. " / " .. #FIRST_STEPS)
        self.off = S.firstStepsHidden or doneN == #FIRST_STEPS or WFD.demo
    end
    function c:Measure(w)
        self:SetWidth(w)
        local y = PAD + 18 + 8
        for _, r in ipairs(self.rows) do
            r:ClearAllPoints()
            r:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 6, -y)
            r:SetPoint("RIGHT", self, "RIGHT", -PAD + 6, 0)
            y = y + 30
        end
        y = y + 6
        self.hide:ClearAllPoints()
        self.hide:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 8, -y)
        return y + self.hide:GetHeight() + PAD - 6
    end
    return c
end

------------------------------------------------------------------------
-- The view: the cards in two or three columns, scrolling when they do not fit
------------------------------------------------------------------------
UI:RegisterView({
    key = "start",
    build = function(outer)
        local book, host = K.BookHost(outer)
        local v = {}
        local scroll = K.Scroll(host)
        scroll:SetPoint("TOPLEFT", 0, 0)
        scroll:SetPoint("BOTTOMRIGHT", 0, 0)
        local area = scroll.content
        local C = {}
        for _, key in ipairs({ "first", "today", "tasks", "new", "memory", "destination", "almost", "progress" }) do
            C[key] = cards[key](area)
        end
        v.cards = C

        function v:Refresh()
            UI.startState = UI.CollectionState and UI.CollectionState() or nil
            for key, card in pairs(C) do
                local ok, err = pcall(card.Fill, card)
                if not ok then WFD:Error("start " .. key, err) end
            end
            C.memory.off = WFD.S.memoryPage == false
            C.memory:SetShown(not C.memory.off)
            C.first:SetShown(not C.first.off)
            self:Arrange()
        end

        -- the open book, wide enough: today on the left page (the first steps, today, the tasks, the memory),
        -- what comes next on the right page (new, where to go, almost done, the collections)
        function v:ArrangeSpread(BW)
            local half = floor(BW / 2)
            book:Lay(half)
            C.progress:Hide()          -- (the collections stand in their album, not on the open book)
            local mem = (not C.memory.off) and C.memory or nil
            local pages = {
                { x = 20, list = { (not C.first.off) and C.first or nil, C.today, C.tasks, mem } },
                { x = half + 20, list = { C.new, C.destination, C.almost } },
            }
            local cw = half - 40
            local bottom = 0
            for _, pg in ipairs(pages) do
                local y = 20
                for i = 1, 4 do
                    local card = pg.list[i]
                    if card then
                        local h = card:Measure(cw)
                        card:ClearAllPoints()
                        card:SetPoint("TOPLEFT", area, "TOPLEFT", pg.x, -y)
                        card:SetWidth(cw)
                        card:SetHeight(h)
                        card:Show()
                        y = y + h + GAP
                    end
                end
                bottom = max(bottom, y)
            end
            scroll:SetContentHeight(bottom + 6)
        end

        -- rows of cards: { card, span } or a stack of cards in one column
        function v:Arrange()
            local BW = self.w or scroll:GetWidth() or 0
            if BW >= 780 * UI.FK() then return self:ArrangeSpread(BW) end
            book:Lay(nil)
            local W = BW - 2 * 20
            if W <= 0 then return end
            local cols = (W >= 840 * UI.FK()) and 3 or 2
            local cw = (W - (cols - 1) * GAP) / cols
            local rows
            local mem = (not C.memory.off) and C.memory or nil
            if cols == 3 then
                rows = {
                    C.first.off and {} or { { C.first, 3 } },
                    { { C.today, 2 }, { C.tasks, 1 } },
                    { { C.new, 1 }, { mem or C.destination, 1 }, { mem and { C.destination, C.almost } or C.almost, 1 } },
                    { { C.progress, 3 } },
                }
            else
                rows = {
                    C.first.off and {} or { { C.first, 2 } },
                    { { C.today, 2 } },
                    { { C.tasks, 1 }, { C.new, 1 } },
                    { { mem or C.destination, 1 }, { mem and { C.destination, C.almost } or C.almost, 1 } },
                    { { C.progress, 2 } },
                }
            end
            local y = 20
            for _, row in ipairs(rows) do
                local x, rowH = 20, 0
                local placed = {}
                for _, cell in ipairs(row) do
                    local w = cw * cell[2] + GAP * (cell[2] - 1)
                    local item = cell[1]
                    if item.Measure then
                        local h = item:Measure(w)
                        placed[#placed + 1] = { item, x, h }
                        rowH = max(rowH, h)
                    else
                        -- a stack: the cards one below the other in one column
                        local h1 = item[1]:Measure(w)
                        local h2 = item[2]:Measure(w)
                        placed[#placed + 1] = { item, x, h1, h2 }
                        rowH = max(rowH, h1 + GAP + h2)
                    end
                    x = x + w + GAP
                end
                for _, p in ipairs(placed) do
                    local item, px = p[1], p[2]
                    if item.Measure then
                        item:ClearAllPoints()
                        item:SetPoint("TOPLEFT", area, "TOPLEFT", px, -y)
                        item:SetHeight(rowH)
                        item:Show()
                    else
                        item[1]:ClearAllPoints()
                        item[1]:SetPoint("TOPLEFT", area, "TOPLEFT", px, -y)
                        item[1]:SetHeight(p[3])
                        item[2]:ClearAllPoints()
                        item[2]:SetPoint("TOPLEFT", area, "TOPLEFT", px, -(y + p[3] + GAP))
                        item[2]:SetHeight(rowH - p[3] - GAP)
                        item[1]:Show()
                        item[2]:Show()
                    end
                end
                if #row > 0 then y = y + rowH + GAP end
            end
            scroll:SetContentHeight(y + 6)
        end

        function v:Layout(w, h) self.w = w - K.BOOK_W self:Arrange() end
        scroll.onResize = function(sf) v.w = sf:GetWidth() v:Arrange() end
        UI.OnRestyle(function() if host:IsVisible() then v:Arrange() end end)

        function v:Show() self:Refresh() end

        function v:Head()
            return L["Start"] .. "  -  " .. format(L["Day %d"], WFD:NumDays())
        end
        return v
    end,
})
