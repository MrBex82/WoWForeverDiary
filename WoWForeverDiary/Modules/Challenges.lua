-- Tasks of the day: three small goals, chosen to fit how this character plays.
-- They are picked once per day, checked every few seconds, and tick off with a milestone.
local ADDON, WFD = ...
local L = WFD.L
local floor, max, min, format = math.floor, math.max, math.min, string.format

local function count(t) local n = 0 for _ in pairs(t or {}) do n = n + 1 end return n end
local function round5(v) return max(5, floor(v / 5 + 0.5) * 5) end

-- deterministic random numbers per day
local function rng(seed)
    local s = seed % 2147483647
    if s <= 0 then s = s + 2147483646 end
    return function(n)
        s = (s * 16807) % 2147483647
        return (s % n) + 1
    end
end

-- averages over the last active days, so goals grow with the character
local function averages(C, today)
    local k, q, km, n = 0, 0, 0, 0
    for d = today - 1, max(1, today - 10), -1 do
        local day = C.days[d]
        if day and (day.online or 0) > 600 then
            n = n + 1
            k, q, km = k + day.killTotal, q + #day.qd, km + (day.steps or 0) * 0.9144 / 1000
        end
    end
    if n == 0 then return 30, 3, 2 end
    return k / n, q / n, km / n
end

-- the place goals: a landmark and a region not seen yet, on the continent the character knows best
local function openPlaces()
    local groups = WFD:LandmarkState()
    local conts = WFD:AtlasState()
    local main, best = nil, -1
    for _, e in ipairs(conts) do if e.secs > best then main, best = e, e.secs end end
    local marks, regions = {}, {}
    for _, g in ipairs(groups) do
        if g.def.key ~= "raids" and (g.def.cont == nil or (main and g.def.cont == main.id)) then
            for _, it in ipairs(g.items) do if not it.found then marks[#marks + 1] = it end end
        end
    end
    if main then
        for _, z in ipairs(main.zones) do if not z.visited then regions[#regions + 1] = z end end
    end
    return marks, regions
end

local function generate(day)
    local C = WFD.C
    local avgK, avgQ, avgKm = averages(C, day)
    local r = rng(day * 7919 + (C.born or 0) % 10007)
    local pool = {
        { k = "kills", goal = min(150, round5(avgK * 0.8)) },
        { k = "quests", goal = max(2, min(8, floor(avgQ * 0.8 + 0.5))) },
        { k = "people", goal = 2 + r(2) - 1 },
        { k = "places", goal = 1 + r(2) },
        { k = "km", goal = max(1, min(10, floor(avgKm * 0.8 + 0.5))) },
        { k = "loot", goal = 1 },
    }
    local marks, regions = openPlaces()
    if #marks > 0 then
        local it = marks[r(#marks)]
        pool[#pool + 1] = { k = "landmark", goal = 1, id = it.id, name = it.name }
    end
    if #regions > 0 then
        local z = regions[r(#regions)]
        pool[#pool + 1] = { k = "region", goal = 1, name = z.name }
    end
    -- three distinct tasks; at most one of them asks to travel somewhere
    local list, travel = {}, false
    local guard = 0
    while #list < 3 and #pool > 0 and guard < 50 do
        guard = guard + 1
        local i = r(#pool)
        local t = pool[i]
        local isTravel = (t.k == "landmark" or t.k == "region")
        if not (isTravel and travel) then
            table.remove(pool, i)
            list[#list + 1] = t
            travel = travel or isTravel
        end
    end
    return { list = list, done = {} }
end

-- the text of a task, in the current language
function WFD:ChallengeText(t)
    if t.k == "kills" then return format(L["Slay %d creatures today."], t.goal) end
    if t.k == "quests" then return format(L["Complete %d quests today."], t.goal) end
    if t.k == "people" then return format(L["Meet %d new people."], t.goal) end
    if t.k == "places" then return t.goal == 1 and L["Discover a new place."] or format(L["Discover %d new places."], t.goal) end
    if t.k == "km" then return t.goal == 1 and L["Walk one kilometre today."] or format(L["Walk %d kilometres today."], t.goal) end
    if t.k == "loot" then return L["Find an uncommon or better item."] end
    if t.k == "landmark" then return format(L["Visit the landmark %s."], t.name or "?") end
    -- the region with the preposition its language needs ("Reise in die Sümpfe des Elends")
    if t.k == "region" then return format(L["Set foot in %s."], self:Place(t.name or "?", "to")) end
    return "?"
end

-- progress of task t on its day: value, goal
function WFD:ChallengeProgress(day, t)
    local C = self.C
    local d = C.days[day]
    if t.k == "kills" then return d and d.killTotal or 0, t.goal end
    if t.k == "quests" then return d and #d.qd or 0, t.goal end
    if t.k == "km" then return floor((d and d.steps or 0) * 0.9144 / 100) / 10, t.goal end
    if t.k == "loot" then
        for _, e in pairs(d and d.loot or {}) do if (e.q or 0) >= 2 then return 1, 1 end end
        return 0, 1
    end
    if t.k == "people" then
        local n = 0
        for _, p in pairs(C.npcs) do if p.first and self:DayIndex(p.first) == day then n = n + 1 end end
        return n, t.goal
    end
    if t.k == "places" then
        local n = 0
        for _, z in pairs(C.zones) do
            for _, ts in pairs(z.sub or {}) do if self:DayIndex(ts) == day then n = n + 1 end end
        end
        return n, t.goal
    end
    if t.k == "landmark" then return (C.landmarks and C.landmarks[t.id]) and 1 or 0, 1 end
    if t.k == "region" then return C.zones[t.name or ""] and 1 or 0, 1 end
    return 0, t.goal or 1
end

-- a value of a task as the pages write it: kilometres with the decimal mark of the diary language
function WFD:TaskValueText(t, v)
    if t and (t.k == "km" or t.k == "wkm" or t.k == "mkm") then return self:Dec(v) end
    return tostring(v)
end

-- today's tasks, picked on first use (never for the demo)
function WFD:TodayChallenges()
    local C = self.C
    if not C or self.paused or self.demo then return C and C.challenges and C.challenges[self:DayIndex()] end
    C.challenges = C.challenges or {}
    local day = self:DayIndex()
    if not C.challenges[day] then C.challenges[day] = generate(day) end
    return C.challenges[day]
end

-- days on which every task was done, and the longest run of such days
function WFD:ChallengeStats()
    local C = self.C
    local full, tasks, run, best = 0, 0, 0, 0
    for d = 1, self:NumDays() do
        local ch = C.challenges and C.challenges[d]
        if ch then
            local n = count(ch.done)
            tasks = tasks + n
            if n >= #ch.list and #ch.list > 0 then
                full = full + 1
                run = run + 1
                if run > best then best = run end
            elseif d < self:NumDays() then
                run = 0
            end
        elseif d < self:NumDays() then
            run = 0
        end
    end
    return full, tasks, best, run
end

------------------------------------------------------------------------
-- The task of the week: one bigger goal for seven diary days (days 1-7, 8-14, ...)
------------------------------------------------------------------------
function WFD:WeekIndex(day) return floor(((day or self:DayIndex()) - 1) / 7) + 1 end
function WFD:WeekDays(w) return (w - 1) * 7 + 1, w * 7 end

local function generateWeek(w)
    local C = WFD.C
    local first = WFD:WeekDays(w)
    local avgK, avgQ, avgKm = averages(C, first)
    local r = rng(w * 104729 + (C.born or 0) % 10007)
    local pool = {
        { k = "wkills", goal = max(50, floor(avgK * 7 * 0.5 / 25 + 0.5) * 25) },
        { k = "wquests", goal = max(8, min(60, floor(avgQ * 7 * 0.5 + 0.5))) },
        { k = "wkm", goal = max(5, min(60, floor(avgKm * 7 * 0.5 + 0.5))) },
        { k = "wpeople", goal = 10 },
        { k = "wregions", goal = 3 },
        { k = "whonours", goal = 2 },
        { k = "wdungeon", goal = 1 },
    }
    local _, _, lmTotal = WFD:LandmarkState()
    local found = 0
    for _ in pairs(C.landmarks or {}) do found = found + 1 end
    if lmTotal and found < lmTotal - 2 then pool[#pool + 1] = { k = "wlandmarks", goal = 2 } end
    return { task = pool[r(#pool)] }
end

function WFD:WeeklyText(t)
    if t.k == "wkills" then return format(L["Slay %d creatures this week."], t.goal) end
    if t.k == "wquests" then return format(L["Complete %d quests this week."], t.goal) end
    if t.k == "wkm" then return format(L["Walk %d kilometres this week."], t.goal) end
    if t.k == "wpeople" then return format(L["Meet %d new people this week."], t.goal) end
    if t.k == "wregions" then return format(L["Visit %d different regions this week."], t.goal) end
    if t.k == "whonours" then return format(L["Earn %d honour tiers this week."], t.goal) end
    if t.k == "wdungeon" then return L["Finish a dungeon run this week."] end
    if t.k == "wlandmarks" then return format(L["Find %d new landmarks this week."], t.goal) end
    return "?"
end

-- progress of a task over the diary days from..to (a week or a month); the kind is the task's key without
-- its first letter ("wkills" and "mkills" both count kills)
local function periodProgress(from, to, t)
    local C = WFD.C
    local kind = t.k:sub(2)
    local t0, t1 = WFD:DayTime(from) - 43200, WFD:DayTime(to) + 43200
    local function inPeriod(ts) return ts and ts >= t0 and ts < t1 end
    local v = 0
    if kind == "kills" or kind == "quests" or kind == "km" then
        for d = from, to do
            local day = C.days[d]
            if day then
                if kind == "kills" then v = v + day.killTotal
                elseif kind == "quests" then v = v + #day.qd
                else v = v + (day.steps or 0) * 0.9144 / 1000 end
            end
        end
        if kind == "km" then v = floor(v * 10) / 10 end
    elseif kind == "people" then
        for _, p in pairs(C.npcs) do if inPeriod(p.first) then v = v + 1 end end
    elseif kind == "regions" then
        local seen = {}
        for d = from, to do
            for z in pairs(C.days[d] and C.days[d].zones or {}) do seen[z] = true end
        end
        for _ in pairs(seen) do v = v + 1 end
    elseif kind == "honours" then
        for _, ev in ipairs(C.events) do if ev.k == "honour" and inPeriod(ev.t) then v = v + 1 end end
    elseif kind == "dungeon" then
        for _, r in ipairs(C.runs or {}) do if r.t1 and inPeriod(r.t0) then v = v + 1 end end
    elseif kind == "landmarks" then
        for _, ts in pairs(C.landmarks or {}) do if inPeriod(ts) then v = v + 1 end end
    end
    return v, t.goal
end

-- progress of the week's task: value, goal
function WFD:WeeklyProgress(w, t)
    local from, to = self:WeekDays(w)
    return periodProgress(from, to, t)
end

-- this week's task, picked on first use (never for the demo)
function WFD:ThisWeek()
    local C = self.C
    if not C then return end
    local w = self:WeekIndex()
    if self.paused or self.demo then return C.weekly and C.weekly[w], w end
    C.weekly = C.weekly or {}
    if not C.weekly[w] then C.weekly[w] = generateWeek(w) end
    return C.weekly[w], w
end

function WFD:WeeksDone()
    local n = 0
    for _, e in pairs(self.C and self.C.weekly or {}) do if e.done then n = n + 1 end end
    return n
end

local function checkWeek()
    local wk, w = WFD:ThisWeek()
    if not wk or wk.done or WFD.paused or WFD.demo then return end
    local v, g = WFD:WeeklyProgress(w, wk.task)
    if v >= g then
        wk.done = time()
        WFD:Milestone("weekly", format(L["Task of the week done: %s"], WFD:WeeklyText(wk.task)), true)
    end
end

------------------------------------------------------------------------
-- The task of the month: the biggest goal, four weeks (diary days 1-28, 29-56, ...)
------------------------------------------------------------------------
local MONTH = 28
function WFD:MonthIndex(day) return floor(((day or self:DayIndex()) - 1) / MONTH) + 1 end
function WFD:MonthDays(m) return (m - 1) * MONTH + 1, m * MONTH end

local function generateMonth(m)
    local C = WFD.C
    local first = WFD:MonthDays(m)
    local avgK, avgQ, avgKm = averages(C, first)
    local r = rng(m * 130363 + (C.born or 0) % 10007)
    local pool = {
        { k = "mkills", goal = max(200, floor(avgK * MONTH * 0.45 / 100 + 0.5) * 100) },
        { k = "mquests", goal = max(30, min(200, floor(avgQ * MONTH * 0.45 + 0.5))) },
        { k = "mkm", goal = max(20, min(200, floor(avgKm * MONTH * 0.45 + 0.5))) },
        { k = "mpeople", goal = 40 },
        { k = "mregions", goal = 8 },
        { k = "mhonours", goal = 8 },
        { k = "mdungeon", goal = 3 },
    }
    local _, _, lmTotal = WFD:LandmarkState()
    local found = 0
    for _ in pairs(C.landmarks or {}) do found = found + 1 end
    if lmTotal and found < lmTotal - 5 then pool[#pool + 1] = { k = "mlandmarks", goal = 5 } end
    return { task = pool[r(#pool)] }
end

function WFD:MonthlyText(t)
    if t.k == "mkills" then return format(L["Slay %d creatures this month."], t.goal) end
    if t.k == "mquests" then return format(L["Complete %d quests this month."], t.goal) end
    if t.k == "mkm" then return format(L["Walk %d kilometres this month."], t.goal) end
    if t.k == "mpeople" then return format(L["Meet %d new people this month."], t.goal) end
    if t.k == "mregions" then return format(L["Visit %d different regions this month."], t.goal) end
    if t.k == "mhonours" then return format(L["Earn %d honour tiers this month."], t.goal) end
    if t.k == "mdungeon" then return format(L["Finish %d dungeon runs this month."], t.goal) end
    if t.k == "mlandmarks" then return format(L["Find %d new landmarks this month."], t.goal) end
    return "?"
end

function WFD:MonthlyProgress(m, t)
    local from, to = self:MonthDays(m)
    return periodProgress(from, to, t)
end

-- this month's task, picked on first use (never for the demo)
function WFD:ThisMonth()
    local C = self.C
    if not C then return end
    local m = self:MonthIndex()
    if self.paused or self.demo then return C.monthly and C.monthly[m], m end
    C.monthly = C.monthly or {}
    if not C.monthly[m] then C.monthly[m] = generateMonth(m) end
    return C.monthly[m], m
end

local function checkMonth()
    local mo, m = WFD:ThisMonth()
    if not mo or mo.done or WFD.paused or WFD.demo then return end
    local v, g = WFD:MonthlyProgress(m, mo.task)
    if v >= g then
        mo.done = time()
        WFD:Milestone("weekly", format(L["Task of the month done: %s"], WFD:MonthlyText(mo.task)), true, { month = true })
    end
end

local function check()
    checkWeek()
    checkMonth()
    local ch = WFD:TodayChallenges()
    if not ch or WFD.paused or WFD.demo then return end
    local day = WFD:DayIndex()
    local before = count(ch.done)
    for i, t in ipairs(ch.list) do
        if not ch.done[i] then
            local v, g = WFD:ChallengeProgress(day, t)
            if v >= g then
                ch.done[i] = time()
                WFD:Milestone("challenge", format(L["Task of the day done: %s"], WFD:ChallengeText(t)), false)
            end
        end
    end
    local after = count(ch.done)
    if after > before and after >= #ch.list and not ch.all then
        ch.all = time()
        local _, _, _, run = WFD:ChallengeStats()
        WFD:Milestone("challenge", run > 1 and format(L["All tasks of the day done! %d days in a row."], run)
            or L["All tasks of the day done!"], true, { all = true })
    end
end

WFD:OnInit(function()
    if C_Timer and C_Timer.NewTicker then
        C_Timer.NewTicker(8, function()
            local ok, err = pcall(check)
            if not ok then WFD:Error("challenges", err) end
        end)
    end
end)
