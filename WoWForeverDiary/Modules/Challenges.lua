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
    if t.k == "region" then return format(L["Set foot in %s."], t.name or "?") end
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

-- progress of the week's task: value, goal
function WFD:WeeklyProgress(w, t)
    local C = self.C
    local from, to = self:WeekDays(w)
    local t0, t1 = self:DayTime(from) - 43200, self:DayTime(to) + 43200
    local function inWeek(ts) return ts and ts >= t0 and ts < t1 end
    local v = 0
    if t.k == "wkills" or t.k == "wquests" or t.k == "wkm" then
        for d = from, to do
            local day = C.days[d]
            if day then
                if t.k == "wkills" then v = v + day.killTotal
                elseif t.k == "wquests" then v = v + #day.qd
                else v = v + (day.steps or 0) * 0.9144 / 1000 end
            end
        end
        if t.k == "wkm" then v = floor(v * 10) / 10 end
    elseif t.k == "wpeople" then
        for _, p in pairs(C.npcs) do if inWeek(p.first) then v = v + 1 end end
    elseif t.k == "wregions" then
        local seen = {}
        for d = from, to do
            for z in pairs(C.days[d] and C.days[d].zones or {}) do seen[z] = true end
        end
        for _ in pairs(seen) do v = v + 1 end
    elseif t.k == "whonours" then
        for _, ev in ipairs(C.events) do if ev.k == "honour" and inWeek(ev.t) then v = v + 1 end end
    elseif t.k == "wdungeon" then
        for _, r in ipairs(C.runs or {}) do if r.t1 and inWeek(r.t0) then v = v + 1 end end
    elseif t.k == "wlandmarks" then
        for _, ts in pairs(C.landmarks or {}) do if inWeek(ts) then v = v + 1 end end
    end
    return v, t.goal
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

local function check()
    checkWeek()
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
