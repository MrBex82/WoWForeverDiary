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

local INDEX_MIN, INDEX_MAX = 250, 300
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
-- every chip leads to where its figure is kept (the newest first, so this day's part is on top)
local function factChips(f)
    local d = f.d
    local list = {}
    local function chip(text, key, route, title, lines)
        local tip = { title or text, unpack(lines or {}) }
        tip[#tip + 1] = { L["Click to open."], 0.5, 0.8, 1 }
        list[#list + 1] = { text, key, tip, function() R.Go(route) end }
    end
    -- the region of the day: its map
    local map = f.mainZone and WFD.C.zoneMaps and WFD.C.zoneMaps[f.mainZone]
    if type(map) == "number" then
        chip(icon("map") .. f.mainZone, "ink", { view = "world", map = map }, L["Show on the world map"])
    end
    for _, lv in ipairs(d.levels or {}) do chip(icon("level") .. format(L["Level %d!"], lv), "gold", UI.PartRoute("levels")) end
    if (d.killTotal or 0) > 0 then
        chip(icon("bestiary") .. WFD:Count("%d kills", d.killTotal), "ink", { view = "bestiary", sort = "last" }, L["Bestiary"])
    end
    if #(d.qd or {}) > 0 then
        chip(icon("quests") .. WFD:Count("%d quests", #d.qd), "ink", { view = "quests", sort = "new" }, L["Quest Book"])
    end
    if f.km >= 0.5 then
        chip(icon("map") .. WFD:Dec(f.km) .. " km", "ink", type(map) == "number" and { view = "world", map = map } or UI.PartRoute("atlas"))
    end
    if f.net ~= 0 then
        chip((f.net > 0 and "+" or "-") .. UI.CoinIcons(f.net, 12), f.net > 0 and "pos" or "neg", UI.PartRoute("ledger"),
            L["Gold today"], { "+" .. UI.CoinIcons(f.income, 11), "-" .. UI.CoinIcons(f.spend, 11) })
    end
    if (d.deaths or 0) > 0 then chip(SKULL .. d.deaths .. "x", "neg", UI.PartRoute("fates"), L["Fate"]) end
    return list
end

-- where a moment of the day is read further: the wanted poster, the report of the dungeon, its part
local function momentGo(ev, day)
    if (ev.k == "boss" or ev.k == "rare") and ev.npc then return function() R.Go({ view = "bestiary", key = ev.npc }) end end
    if ev.k == "dungeon" then
        for i, r in ipairs(WFD.C.runs or {}) do
            if r.day == day and r.name and ev.s and ev.s:find(r.name, 1, true) then
                return function() R.Go({ view = "runs", key = i }) end
            end
        end
        return function() R.Go(UI.PartRoute("runs")) end
    end
    if ev.k == "first" and ev.first then return function() R.Go({ view = "firsts", key = ev.first }) end end
    if ev.k == "catch" and ev.item then return function() R.Go({ view = "fishbook", key = ev.item }) end end
    local PART = { honour = "honour", landmark = "landmarks", level = "levels", capsule = "capsule", weekly = "tasks", challenge = "tasks" }
    if PART[ev.k] then return function() R.Go(UI.PartRoute(PART[ev.k])) end end
    return function() R.Go({ view = "milestones", key = tostring(ev.t) .. ":" .. tostring(ev.k) }) end
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

        -- the open book: the chapters and days on the left page, the day on the right page
        v.book = K.Spread(host)
        host.book = v.book
        -- in a narrow window the index lies on a card of its own over the page
        v.indexCard = K.Card(host)
        v.index = CreateFrame("Frame", nil, host)
        v.list = K.Report(v.index)
        v.list:SetPoint("TOPLEFT", v.index, "TOPLEFT", 0, 0)
        v.list:SetPoint("BOTTOMRIGHT", v.index, "BOTTOMRIGHT", 0, 52)
        v.list.fill = function() v:FillIndex() end
        v.list.scroll:SetFade("card")
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
        v.page = CreateFrame("Frame", nil, v.book)
        v.read = K.Report(v.page)
        v.read:SetPoint("TOPLEFT", v.page, "TOPLEFT", 14, -8)
        v.read:SetPoint("BOTTOMRIGHT", v.page, "BOTTOMRIGHT", -14, 8)
        v.read.fill = function() v:FillPage() end
        v.read.scroll:SetFade("card")          -- more of the day below: the foot of the page fades

        -- below the page: the day before and after, where you are, the bookmark
        v.foot = CreateFrame("Frame", nil, v.book)
        v.prev = K.Button(v.foot, L["Day before"], "secondary", function() v:Turn(-1) end)
        v.prev:AddArrow("left")
        v.nextB = K.Button(v.foot, L["Day after"], "secondary", function() v:Turn(1) end)
        v.nextB:AddArrow("right")
        v.mark = K.Button(v.foot, L["Bookmark"], "ghost", function() v:ToggleMark() end)
        v.where = K.Text(v.foot, "small", "muted", "CENTER")
        v.where:SetWordWrap(false)
        -- in a narrow window the index folds away: these two open it and ask for a day
        v.indexBtn = K.IconButton(v.foot, "menu", { L["Chapters"] }, function()
            v.indexOpen = not v.indexOpen
            v:Arrange()
        end)
        v.jumpBtn = K.IconButton(v.foot, "text:#", { L["Go to day"] }, function() v.jump:Click() end)

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
                    if to then R.Go({ view = "diary", day = to }, { noHistory = true, dir = dir }) end
                    return
                end
            end
        end

        function v:Marked()
            for i, m in ipairs(WFD.C.marks or {}) do if m.day == self.day then return i end end
        end
        function v:ToggleMark()
            -- (the same as the button in the head bar: set or taken away, with undo in the note)
            UI.ToggleMarkAt({ view = "diary", day = self.day })
            self:PaintFoot()
        end

        function v:PaintFoot()
            local days = self:Days()
            local at
            for i, d in ipairs(days) do if d == self.day then at = i end end
            -- in the book the ways to the next pages are links in ink
            local book = K.IsBook()
            for _, b in ipairs({ self.prev, self.nextB }) do
                b.style = book and "ghost" or "secondary"
                K.Repaint(b)
            end
            self.prev:SetEnabled(at ~= nil and at > 1)
            self.nextB:SetEnabled(at ~= nil and at < #days)
            self.mark:SetLabel(self:Marked() and L["Remove the bookmark"] or L["Set a bookmark"])
            self.where:SetText(self.day and format(L["Day %d of %d"], self.day, days[#days] or self.day) or "")
            -- the place in the diary stands at the foot of the page, as the number of a printed page
            self.book:SetFolio(nil, self.where:GetText())
            self.where:SetText("")
            -- shown only where it fits whole between the buttons (larger writing, a narrow window)
            local room = (self.foot:GetWidth() or 0) - self.prev:GetWidth() - self.nextB:GetWidth() - self.mark:GetWidth() - 36 - (self.narrow and 70 or 0)
            self.where:SetShown(self.where:GetStringWidth() <= room)
            -- very narrow (big writing, a small window): the bookmark stays in the head bar, its button here goes
            local fw = self.foot:GetWidth() or 0
            self.mark:SetShown(fw <= 0 or self.prev:GetWidth() + self.nextB:GetWidth() + self.mark:GetWidth() + 24
                + (self.narrow and 70 or 0) <= fw)
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
                        rp:Line({ name = format(L["Day %d"], day), right = date(WFD.loc.dayMonth, WFD:DayTime(day)), bare = not cur, indent = 14,
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
                rp:Empty(UI.Icon("journal"), L["The pages are still empty. Go and live an adventure!"], L["The diary writes itself while I play: every day gets its page, told as a story."])
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
                    local tip = { ev.s, date("%H:%M", ev.t) }
                    if ev.shot then tip[#tip + 1] = L["Screenshot:"] .. " " .. ev.shot end
                    tip[#tip + 1] = { L["Click to open."], 0.5, 0.8, 1 }
                    rp:Line({ name = momentSubject(ev), wrap = true, icon = path, col = { col[1], col[2], col[3] },
                        sub = UI.Upper(L[UI.SEAL_LABEL[ev.k] or "Moment"]), subKey = "gold", right = date("%H:%M", ev.t),
                        go = momentGo(ev, day), tip = tip })
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
            local iw = floor(max(INDEX_MIN, min(INDEX_MAX, W * 0.26)) * k + 0.5)          -- wider with bigger writing
            local narrow = W < 760
            self.narrow = narrow
            -- narrow: the index lies over the page while it is open, the foot has the buttons for it
            self.index:SetShown(not narrow or self.indexOpen)
            self.indexBtn:SetShown(narrow)
            self.jumpBtn:SetShown(narrow)
            self.indexBtn:SetActive(narrow and self.indexOpen)
            -- the book lies on the desk with a margin (room for its shadow on the right and below)
            local book = self.book
            book:ClearAllPoints()
            book:SetPoint("TOPLEFT", host, "TOPLEFT", 14, -12)
            book:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -20, 18)
            local BW, BH = W - 34, H - 30
            local split = (not narrow) and (iw + 16) or nil
            book:Lay(split)
            self.indexCard:SetShown(narrow and self.indexOpen or false)
            self.index:ClearAllPoints()
            if narrow then
                self.index:SetParent(host)
                self.index:SetPoint("TOPLEFT", host, "TOPLEFT", 14, -14)
                self.index:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 14, 56)
                self.index:SetWidth(min(iw + 40, W - 24))
                self.indexCard:ClearAllPoints()
                self.indexCard:SetAllPoints(self.index)
                self.indexCard:SetFrameLevel(host:GetFrameLevel() + 29)
            else
                self.index:SetParent(book.left)
                self.index:SetPoint("TOPLEFT", book.left, "TOPLEFT", 0, -K.PAGE_HEAD)
                self.index:SetPoint("BOTTOMRIGHT", book.left, "BOTTOMRIGHT", -6, K.PAGE_FOOT)
            end
            self.index:SetFrameLevel((narrow and host:GetFrameLevel() + 30) or (book:GetFrameLevel() + 2))
            -- the right page: the day in a column of a good length to read, the foot at the bottom of the page
            local footH = 44
            local rw = BW - (split or 0)
            local pw = min(rw - 28, floor(PAGE_W * k))
            self.page:ClearAllPoints()
            self.page:SetPoint("TOPLEFT", book.right, "TOPLEFT", floor((rw - pw) / 2), -K.PAGE_HEAD)
            self.page:SetSize(pw, max(100, BH - K.PAGE_HEAD - K.PAGE_FOOT - footH))
            self.foot:ClearAllPoints()
            self.foot:SetPoint("TOPLEFT", self.page, "BOTTOMLEFT", 0, -2)
            self.foot:SetSize(pw, footH - 8)
            self.prev:ClearAllPoints()
            self.prev:SetPoint("LEFT", self.foot, "LEFT", 0, 0)
            self.nextB:ClearAllPoints()
            self.nextB:SetPoint("RIGHT", self.foot, "RIGHT", 0, 0)
            self.mark:ClearAllPoints()
            self.mark:SetPoint("RIGHT", self.nextB, "LEFT", -6, 0)
            self.indexBtn:ClearAllPoints()
            self.indexBtn:SetPoint("LEFT", self.prev, "RIGHT", 6, 0)
            self.jumpBtn:ClearAllPoints()
            self.jumpBtn:SetPoint("LEFT", self.indexBtn, "RIGHT", 4, 0)
            self.where:ClearAllPoints()
            self.where:SetPoint("LEFT", narrow and self.jumpBtn or self.prev, "RIGHT", 8, 0)
            self.where:SetPoint("RIGHT", self.mark, "LEFT", -8, 0)
            self:PaintFoot()
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
            self.indexOpen = nil          -- a day chosen in the folded index closes it
            self.day = route.day or (self.day) or C.readDay
            self:Refresh()
            route.day = self.day          -- the way back returns to this very day
            C.readDay = self.day
            self.read.scroll:ScrollTo(0)
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
