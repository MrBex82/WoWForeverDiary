-- The diary on the travel desk: one day at a time, like a page that is read rather than turned. On the left the
-- chapters and the days of the open chapter, "Go to day" below them; in the middle the day - the chapter, the
-- date, the figures of the day as small boxes, the story with its initial, my own note, a painted moment, what
-- was kept as a memory, the tasks; below it the day before, the day after and the bookmark.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

local INDEX_MIN, INDEX_MAX = 230, 290
local PAGE_W = 620              -- the page at its widest (60 to 75 letters in a line of the story)

UI.PART_VIEW.diary = "diary"
UI.VIEW_PLACE.diary = { "diary", "diary" }

------------------------------------------------------------------------
-- What a day holds
------------------------------------------------------------------------
-- (when in the day it happened: L["early in the morning"] L["in the morning"] L["around noon"]
-- L["in the afternoon"] L["in the evening"] L["late at night"])
local MOODS = {
    { 5, 9, "early in the morning" }, { 9, 12, "in the morning" }, { 12, 14, "around noon" },
    { 14, 18, "in the afternoon" }, { 18, 22, "in the evening" },
}
local function timeLine(d)
    if not d.t0 then return nil end
    local best, bestV
    for h, v in pairs(d.hours or {}) do
        if not bestV or v > bestV then best, bestV = h, v end
    end
    best = best or tonumber(date("%H", d.t0))
    local mood = "late at night"
    for _, m in ipairs(MOODS) do
        if best >= m[1] and best < m[2] then mood = m[3] end
    end
    return date("%H:%M", d.t0) .. " - " .. date("%H:%M", d.t1 or d.t0) .. ",  " .. L[mood]
end

local function icon(key, size) return "|T" .. UI.Icon(key) .. ":" .. (size or 13) .. ":" .. (size or 13) .. ":0:0:64:64:5:59:5:59|t " end
local SKULL = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:13:13:0:0|t "

-- the figures of a day as small boxes; money and death carry a sign or a skull, never only a colour
local function factChips(f)
    local d = f.d
    local list = {}
    for _, lv in ipairs(d.levels or {}) do list[#list + 1] = { icon("level") .. format(L["Level %d!"], lv), "gold" } end
    if (d.killTotal or 0) > 0 then list[#list + 1] = { icon("bestiary") .. WFD:Count("%d kills", d.killTotal), "ink" } end
    if #(d.qd or {}) > 0 then list[#list + 1] = { icon("quests") .. WFD:Count("%d quests", #d.qd), "ink" } end
    if f.km >= 0.5 then list[#list + 1] = { icon("map") .. WFD:Dec(f.km) .. " km", "ink" } end
    if f.net ~= 0 then
        list[#list + 1] = { (f.net > 0 and "+" or "-") .. UI.CoinIcons(f.net, 12), f.net > 0 and "pos" or "neg",
            { L["Gold today"], "+" .. UI.CoinIcons(f.income, 11), "-" .. UI.CoinIcons(f.spend, 11) } }
    end
    if (d.deaths or 0) > 0 then list[#list + 1] = { SKULL .. d.deaths .. "x", "neg" } end
    return list
end

-- "on this day": a look back from the newest entry
local function flashback(day)
    local C = WFD.C
    for _, n in ipairs({ 365, 30, 7 }) do
        local old = day - n
        local d = old >= 1 and C.days[old]
        if d then
            local f = WFD:DayFacts(old)
            local evText
            for _, ev in ipairs(f.events) do
                if ev.k == "boss" or ev.k == "rare" or ev.k == "level" or ev.k == "dungeon" or ev.k == "zone" or ev.k == "epic" then
                    evText = ev.s
                    break
                end
            end
            local txt = format(L["I was in %s."], WFD:Place(f.mainZone or "?", "in"))
            if evText then txt = txt .. " " .. evText
            elseif d.killTotal > 0 then txt = txt .. " " .. WFD:Count("%d enemies fell that day.", d.killTotal) end
            return { n = n, day = old, text = txt }
        end
    end
end

-- the most remarkable moment of a day that can be painted
local PAINT_ORDER = { boss = 1, rare = 2, dungeon = 3, level = 4, epic = 5, first = 5, landmark = 6, zone = 6, honour = 7,
    rareitem = 7, weekly = 7, quest = 8 }
local function paintable(f)
    local best
    for _, ev in ipairs(f.events) do
        if ev.gear and PAINT_ORDER[ev.k] and (not best or PAINT_ORDER[ev.k] < PAINT_ORDER[best.k]) then best = ev end
    end
    return best
end

local function story(day)
    UI.storyCache = UI.storyCache or {}
    local s = UI.storyCache[day]
    if not s then
        s = WFD:Narrate(day) or ""
        if day < WFD:NumDays() then UI.storyCache[day] = s end
    end
    return s
end

local function momentSubject(ev) return (ev.k ~= "level" and ev.s and ev.s:match(":%s*(.+)$")) or ev.s or "" end

local function qualityColour(q)
    local col = WFD.qualityColors and WFD.qualityColors[q or 1]
    if not col or q == 1 then return { 0.55, 0.50, 0.42 } end
    return { col[1], col[2], col[3] }
end

-- the chapter a day belongs to, and its number among the chapters
local function chapterOf(chapters, day)
    for i, ch in ipairs(chapters) do
        if day >= ch.days[1] and day <= ch.days[#ch.days] then return ch, i end
    end
end

-- the days with an entry, in order
local function dayList()
    local list = {}
    local C = WFD.C
    for day = 1, WFD:NumDays() do if C.days[day] then list[#list + 1] = day end end
    return list
end

-- a day of the diary opens here (the old page numbers of the book are gone)
function UI.DayGo(day)
    if not (day and WFD.C and WFD.C.days[day]) then return nil end
    return function() UI:OpenShell({ view = "diary", day = day }) end
end
function UI:OpenDay(day) local go = UI.DayGo(day) if go then go() end end
function UI:GoToDay(day) self:OpenDay(day) end

------------------------------------------------------------------------
-- The view
------------------------------------------------------------------------
UI:RegisterView({
    key = "diary",
    build = function(host)
        local v = {}

        -- the chapters and days
        v.index = K.Card(host)
        v.list = K.Report(v.index)
        v.list:SetPoint("TOPLEFT", v.index, "TOPLEFT", 0, 0)
        v.list:SetPoint("BOTTOMRIGHT", v.index, "BOTTOMRIGHT", 0, 52)
        v.list.fill = function() v:FillIndex() end
        v.jump = K.Button(v.index, L["Go to day"], "secondary", function()
            UI:Ask({
                title = L["Go to day"], ok = L["Go to day"],
                input = { value = tostring(v.day or ""), numeric = true, max = 5 },
                onOk = function(text)
                    local want = tonumber(text)
                    if not want then return end
                    -- the nearest day with an entry
                    local best
                    for _, d in ipairs(dayList()) do
                        if not best or math.abs(d - want) < math.abs(best - want) then best = d end
                    end
                    if best then R.Go({ view = "diary", day = best }) end
                end,
            })
        end)
        v.jump:SetPoint("BOTTOMLEFT", v.index, "BOTTOMLEFT", 14, 12)

        -- the page
        v.page = K.Card(host)
        v.read = K.Report(v.page)
        v.read:SetPoint("TOPLEFT", v.page, "TOPLEFT", 14, -8)
        v.read:SetPoint("BOTTOMRIGHT", v.page, "BOTTOMRIGHT", -14, 8)
        v.read.fill = function() v:FillPage() end

        -- below the page: the day before and after, where you are, the bookmark
        v.foot = CreateFrame("Frame", nil, host)
        v.prev = K.Button(v.foot, L["Day before"], "secondary", function() v:Turn(-1) end)
        v.prev:AddArrow("left")
        v.nextB = K.Button(v.foot, L["Day after"], "secondary", function() v:Turn(1) end)
        v.nextB:AddArrow("right")
        v.mark = K.Button(v.foot, L["Bookmark"], "ghost", function() v:ToggleMark() end)
        v.where = K.Text(v.foot, "small", "muted", "CENTER")
        v.where:SetWordWrap(false)

        function v:Days()
            self.days = self.days or dayList()
            return self.days
        end

        -- one day on, or back
        function v:Turn(dir)
            local days = self:Days()
            for i, d in ipairs(days) do
                if d == self.day then
                    local to = days[i + dir]
                    if to then R.Go({ view = "diary", day = to }, { noHistory = true }) end
                    return
                end
            end
        end

        function v:Marked()
            for i, m in ipairs(WFD.C.marks or {}) do if m.day == self.day then return i end end
        end
        function v:ToggleMark()
            local C = WFD.C
            C.marks = C.marks or {}
            local i = self:Marked()
            if i then
                table.remove(C.marks, i)
            elseif #C.marks >= 12 then
                print("|cffffd100WoW Forever Diary:|r " .. format(L["All %d bookmarks are in use. Remove one first."], 12))
                return
            else
                C.marks[#C.marks + 1] = { day = self.day }
            end
            self:PaintFoot()
            if UI.OnMarksChanged then UI:OnMarksChanged() end
        end

        function v:PaintFoot()
            local days = self:Days()
            local at
            for i, d in ipairs(days) do if d == self.day then at = i end end
            self.prev:SetEnabled(at ~= nil and at > 1)
            self.nextB:SetEnabled(at ~= nil and at < #days)
            self.mark:SetLabel(self:Marked() and L["Remove the bookmark"] or L["Set a bookmark"])
            self.where:SetText(self.day and format(L["Day %d of %d"], self.day, days[#days] or self.day) or "")
        end

        ------------------------------------------------------------------------
        -- the index: every chapter, the days of the open one
        ------------------------------------------------------------------------
        function v:FillIndex()
            local rp = self.list
            rp:Begin()
            local chapters = self.chapters or {}
            local open = self.day and chapterOf(chapters, self.day)
            rp:Head(L["Chapters"], tostring(#chapters))
            for _, ch in ipairs(chapters) do
                local first, last = ch.days[1], ch.days[#ch.days]
                local here = ch == open
                rp:Line({ name = ch.roman .. ".  " .. ch.title, nameKey = here and "title" or "ink", wrap = true,
                    sub = (first == last) and format(L["Day %d"], first) or format(L["Days %d-%d"], first, last),
                    col = here and { 0.85, 0.66, 0.24 } or nil, num = nil,
                    go = function() R.Go({ view = "diary", day = here and self.day or first }) end })
                if here then
                    for _, day in ipairs(ch.days) do
                        local cur = day == self.day
                        rp:Line({ name = "      " .. format(L["Day %d"], day), right = date(WFD.loc.dayMonth, WFD:DayTime(day)),
                            nameKey = cur and "title" or "soft", mark = cur and "right" or nil, markKey = "gold",
                            go = function() R.Go({ view = "diary", day = day }, { noHistory = true }) end })
                    end
                    rp:Gap(6)
                end
            end
            if #chapters == 0 then rp:Text(L["The pages are still empty. Go and live an adventure!"], "soft", "body") end
            rp:End()
        end

        ------------------------------------------------------------------------
        -- the page of a day
        ------------------------------------------------------------------------
        function v:FillPage()
            local rp = self.read
            rp:Begin()
            local day = self.day
            local f = day and WFD:DayFacts(day)
            if not f then
                rp:Gap(40)
                rp:Text(L["The pages are still empty. Go and live an adventure!"], "soft", "body")
                rp:End()
                return
            end
            local ch = chapterOf(self.chapters or {}, day)
            -- a new chapter begins with its title
            if ch and ch.days[1] == day then
                rp:Gap(6)
                rp:Kicker(L["Chapter"] .. " " .. ch.roman)
                rp:Title(ch.title, "display")
                rp:Text(ch.sub, "muted", "small", 10)
                rp:Flourish()
            elseif ch then
                rp:Kicker(L["Chapter"] .. " " .. ch.roman .. "  -  " .. ch.title)
            end
            rp:Title(WFD:LongDate(day), "title")
            local where = f.mainZone or ""
            local tl = timeLine(f.d)
            rp:Text(format(L["Day %d"], day) .. (where ~= "" and ("  -  " .. where) or "") .. (tl and ("  -  " .. tl) or ""), "soft", "small", 10)
            rp:Chips(factChips(f))

            -- the newest day looks back
            if day == WFD:NumDays() then
                local fb = flashback(day)
                if fb then
                    rp:Line({ name = fb.text, sub = UI.Upper(format(L["Today, %d days ago"], fb.n)), subKey = "gold", wrap = true,
                        icon = UI.Icon("time"), col = { 0.55, 0.40, 0.16 }, go = UI.DayGo(fb.day),
                        tip = { format(L["Today, %d days ago"], fb.n), L["Click to read this day."] } })
                    rp:Gap(6)
                end
            end

            -- the story, with an initial
            local first = true
            for p in (story(day) .. "\n\n"):gmatch("(.-)\n\n") do
                if p:find("%S") then
                    rp:Paragraph(p, "ink", first)
                    first = false
                end
            end

            -- my own thoughts
            local own = WFD.C.dayNotes and WFD.C.dayNotes[day]
            if own and own:find("%S") then
                rp:Kicker(L["My own thoughts:"])
                for p in (own .. "\n"):gmatch("(.-)\n") do
                    if p:find("%S") then rp:Paragraph(p, "soft", false, true) end
                end
            end
            rp:Button(own and own:find("%S") and L["edit note"] or L["+ note"], function() UI:EditDayNote(day) end, "ghost")

            -- a painted moment
            local pic = paintable(f)
            if pic then
                rp:Head(L["A painted memory"])
                rp:Picture(pic, 150)
            end

            -- what was kept: the finer finds and the moments of the day
            local items, moments = {}, {}
            for _, it in ipairs(f.items) do
                if (it.q or 1) >= 2 then items[#items + 1] = { WFD:ItemIcon(it.link) or UI.Icon("loot"), qualityColour(it.q), it.link } end
            end
            for _, ev in ipairs(f.events) do
                if UI.SEAL[ev.k] and (ev.k ~= "challenge" or ev.all) then moments[#moments + 1] = ev end
            end
            if #items > 0 or #moments > 0 then
                rp:Head(L["Kept as a memory"], tostring(#items + #moments))
                rp:Icons(items)
                for _, ev in ipairs(moments) do
                    local path, col = UI.MomentIcon(ev)
                    local go
                    if ev.k == "honour" then go = function() R.Go(UI.PartRoute("honour")) end
                    elseif ev.k == "landmark" then go = function() R.Go(UI.PartRoute("landmarks")) end end
                    rp:Line({ name = momentSubject(ev), wrap = true, icon = path, col = { col[1], col[2], col[3] },
                        sub = UI.Upper(L[UI.SEAL_LABEL[ev.k] or "Moment"]), subKey = "gold", right = date("%H:%M", ev.t),
                        go = go, tip = { ev.s, date("%H:%M", ev.t), ev.shot and (L["Screenshot:"] .. " " .. ev.shot) or nil } })
                end
                rp:Gap(6)
            end

            -- the tasks of that day, ticked off
            local tasks = WFD.C.challenges and WFD.C.challenges[day]
            if tasks and #tasks.list > 0 then
                local doneN = 0
                for i in ipairs(tasks.list) do if tasks.done[i] then doneN = doneN + 1 end end
                rp:Head(L["Tasks of the day"], doneN .. " / " .. #tasks.list)
                for i, task in ipairs(tasks.list) do
                    local done = tasks.done[i] and true or false
                    local right
                    if day == WFD:NumDays() and not done then
                        local val, gl = WFD:ChallengeProgress(day, task)
                        if gl and gl > 1 then right = WFD:TaskValueText(task, val) .. " / " .. gl end
                    end
                    rp:Line({ name = WFD:ChallengeText(task), wrap = true, nameKey = done and "soft" or "ink",
                        mark = done and "check" or nil, markKey = "white", col = done and { 0.30, 0.62, 0.30 } or nil, right = right })
                end
            end
            rp:Flourish()
            rp:End()
        end

        ------------------------------------------------------------------------
        -- the layout
        ------------------------------------------------------------------------
        function v:Arrange()
            local W, H = self.w or host:GetWidth() or 0, self.h or host:GetHeight() or 0
            if W <= 0 or H <= 0 then return end
            local k = max(1, UI.FONT_SCALE or 1)
            local iw = max(INDEX_MIN, min(INDEX_MAX, floor(W * 0.26)))
            local narrow = W < 760
            self.index:SetShown(not narrow)
            local left = narrow and 12 or (iw + 24)
            self.index:ClearAllPoints()
            self.index:SetPoint("TOPLEFT", host, "TOPLEFT", 12, -12)
            self.index:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 12, 12)
            self.index:SetWidth(iw)
            local footH = 44
            local avail = W - left - 12
            local pw = min(avail, floor(PAGE_W * k))
            self.page:ClearAllPoints()
            self.page:SetPoint("TOPLEFT", host, "TOPLEFT", left + floor((avail - pw) / 2), -12)
            self.page:SetSize(pw, max(100, H - 24 - footH))
            self.foot:ClearAllPoints()
            self.foot:SetPoint("TOPLEFT", self.page, "BOTTOMLEFT", 0, -8)
            self.foot:SetSize(pw, footH - 8)
            self.prev:ClearAllPoints()
            self.prev:SetPoint("LEFT", self.foot, "LEFT", 0, 0)
            self.nextB:ClearAllPoints()
            self.nextB:SetPoint("RIGHT", self.foot, "RIGHT", 0, 0)
            self.mark:ClearAllPoints()
            self.mark:SetPoint("RIGHT", self.nextB, "LEFT", -6, 0)
            self.where:ClearAllPoints()
            self.where:SetPoint("LEFT", self.prev, "RIGHT", 8, 0)
            self.where:SetPoint("RIGHT", self.mark, "LEFT", -8, 0)
            self.where:SetShown(pw >= 520)
        end

        function v:Refresh()
            self.days = nil
            local ok, err = pcall(function()
                self.chapters = UI.Chapters()
                local days = self:Days()
                if not self.day or not WFD.C.days[self.day] then self.day = days[#days] end
            end)
            if not ok then WFD:Error("diary", err) end
            self:Arrange()
            ok, err = pcall(self.FillIndex, self)
            if not ok then WFD:Error("diary index", err) end
            ok, err = pcall(self.FillPage, self)
            if not ok then WFD:Error("diary page", err) end
            self:PaintFoot()
        end

        function v:Show(route)
            local C = WFD.C
            self.day = route.day or (self.day) or C.readDay
            self:Refresh()
            route.day = self.day          -- the way back returns to this very day
            C.readDay = self.day
            self.read.scroll:ScrollTo(0)
            -- the open chapter in sight in the index
            if WFD.dirty then WFD.dirty = false end
        end
        function v:Layout(w, h)
            self.w, self.h = w, h
            self:Arrange()
        end
        UI.OnRestyle(function() if host:IsShown() then v:Refresh() end end)

        function v:Head()
            local ch = self.day and chapterOf(self.chapters or {}, self.day)
            local g = UI.NAV_GROUP.diary
            local title = self.day and format(L["Day %d"], self.day) or L["Diary"]
            if ch then title = title .. "  -  " .. ch.roman .. ". " .. ch.title end
            return title, L[g.label], UI.GroupRoute(g)
        end
        return v
    end,
})
