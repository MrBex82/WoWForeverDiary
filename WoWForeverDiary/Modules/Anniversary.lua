-- Memories: what happened on this day in earlier years (or 30, 100, 365 days ago), and anniversaries:
-- the first page of the diary, hours in the world, a year since a milestone level. Only reads what is kept.
local ADDON, WFD = ...
local time, date = time, date

-- what makes a day worth remembering, strongest first
local RANK = { milestone = 5, first = 4, boss = 3, zone = 2, kills = 1, quests = 0.6, walk = 0.3 }
local MILESTONE = { level = true, honour = true, dungeon = true, landmark = true, wealth = true, skill = true, weekly = true }
local MOMENT = { boss = true, rare = true, epic = true, rareitem = true }
local FALLBACK_DAYS = { 365, 100, 30 }
local JUBILEE_DAYS = 7                      -- a dated anniversary is still told this many days later
local HOURS = { 100, 500, 1000 }
local LEVELS = { 10, 20, 30, 40, 50, 60 }

local function leap(y) return (y % 4 == 0 and y % 100 ~= 0) or y % 400 == 0 end

-- noon of a calendar day in local time; the 29th of February becomes the 28th in other years
local function noonOf(y, m, d)
    if m == 2 and d == 29 and not leap(y) then d = 28 end
    return time({ year = y, month = m, day = d, hour = 12, min = 0, sec = 0 })
end

-- the diary days that fall on today's date n years ago (two on the 28th of February: the 29th of leap years too)
local function sameDate(now, n)
    local t = date("*t", now)
    local y = t.year - n
    local list = { WFD:DayIndex(noonOf(y, t.month, t.day)) }
    if t.month == 2 and t.day == 28 and not leap(t.year) and leap(y) then
        list[2] = WFD:DayIndex(time({ year = y, month = 2, day = 29, hour = 12 }))
    end
    return list
end

-- the moments of each day, gathered once per look back
local function eventsByDay(C)
    local by = {}
    for _, ev in ipairs(C.events or {}) do
        if ev.day then
            local l = by[ev.day]
            if not l then l = {} by[ev.day] = l end
            l[#l + 1] = ev
        end
    end
    return by
end

-- the strongest thing that happened on a diary day, or nil if nothing on it can be counted
local function judge(C, idx, evs)
    local d = C.days[idx]
    if not d then return nil end
    local m = { idx = idx, zone = WFD:MainZone(d), d = d }
    local function take(kind, extra)
        if m.rank and RANK[kind] <= m.rank then return end
        m.rank, m.kind = RANK[kind], kind
        m.ev, m.first = extra and extra.ev, extra and extra.first
    end
    for _, ev in ipairs(evs[idx] or {}) do
        if MILESTONE[ev.k] then take("milestone", { ev = ev })
        elseif MOMENT[ev.k] then take("boss", { ev = ev })
        elseif ev.k == "zone" then take("zone", { ev = ev }) end
    end
    for key, f in pairs(C.firsts or {}) do
        if f.day == idx then take("first", { first = key }) end
    end
    if (d.killTotal or 0) > 0 then take("kills") end
    if #(d.qd or {}) > 0 then take("quests") end
    if (d.steps or 0) * 0.9144 >= 200 then take("walk") end
    return m.rank and m or nil
end

-- What today brings back: the strongest day on this date in an earlier year, otherwise 365, 100 or 30 days ago.
-- Returns { idx, years or days, kind, zone, when, title, text } or nil.
function WFD:OnThisDay(now)
    local C = self.C
    if not (C and C.born and C.days) then return nil end
    now = now or time()
    local today = self:DayIndex(now)
    local evs = eventsByDay(C)
    local best
    for n = 1, 100 do
        local list = sameDate(now, n)
        if list[1] < 1 and (not list[2] or list[2] < 1) then break end
        for _, idx in ipairs(list) do
            if idx >= 1 and idx < today then
                local m = judge(C, idx, evs)
                -- the same rank: the nearer year wins, it comes first
                if m and (not best or m.rank > best.rank) then
                    m.years = n
                    best = m
                end
            end
        end
    end
    if not best then
        for _, k in ipairs(FALLBACK_DAYS) do
            local idx = today - k
            if idx >= 1 then
                local m = judge(C, idx, evs)
                if m and (not best or m.rank > best.rank) then
                    m.days = k
                    best = m
                end
            end
        end
    end
    if not best then return nil end
    return self:NarrateMemory(best)
end

------------------------------------------------------------------------
-- Anniversaries
------------------------------------------------------------------------
-- full years from t0 to now, and whether now is within a few days of that anniversary
local function yearsSince(t0, now)
    local a, b = date("*t", t0), date("*t", now)
    local n = b.year - a.year
    if n < 1 then return nil end
    local due = noonOf(a.year + n, a.month, a.day)
    local nowNoon = noonOf(b.year, b.month, b.day)
    if nowNoon < due then return nil end
    if (nowNoon - due) / 86400 >= JUBILEE_DAYS then return nil end
    return n
end

local function played(C)
    local s = 0
    for _, d in pairs(C.days) do s = s + (d.online or 0) end
    return s
end

-- the anniversaries that are due now: { key, kind, n, level, idx, text, shown }
function WFD:Jubilees(now)
    local C = self.C
    if not (C and C.born and C.days) then return {} end
    now = now or time()
    local shown = C.anniversaryShown or {}
    local list = {}
    local function add(j)
        j.shown = shown[j.key]
        -- still told on the page for a few days after it was first announced
        if j.shown and (now - j.shown) >= JUBILEE_DAYS * 86400 then return end
        j.text = self:NarrateJubilee(j)
        list[#list + 1] = j
    end
    local n = yearsSince(C.born, now)
    if n then add({ key = "born:" .. n, kind = "born", n = n, idx = 1 }) end
    -- the highest number of hours reached; a diary that is already past several thresholds hears only of the last
    local hours = played(C) / 3600
    for i = #HOURS, 1, -1 do
        if hours >= HOURS[i] then
            add({ key = "hours:" .. HOURS[i], kind = "hours", n = HOURS[i], lower = i - 1 })
            break
        end
    end
    for _, lv in ipairs(LEVELS) do
        local t = C.levelTimes and C.levelTimes[lv]
        local years = t and yearsSince(t, now)
        if years then add({ key = "level" .. lv .. ":" .. years, kind = "level", n = years, level = lv, idx = self:DayIndex(t) }) end
    end
    -- the day of a death, a year on (one at most: the first fate whose anniversary is due)
    for _, f in ipairs(self:Fates()) do
        local years = f.day and f.day >= 1 and yearsSince(self:DayTime(f.day), now)
        if years then
            add({ key = "death:" .. f.day .. ":" .. years, kind = "death", n = years, idx = f.day, by = f.by, zone = f.zone })
            break
        end
    end
    return list
end

-- an anniversary was told: it is not announced again (nor are the lower hour thresholds it stands for)
function WFD:JubileeShown(j)
    local C = self.C
    if not C or self.demo then return end
    C.anniversaryShown = C.anniversaryShown or {}
    C.anniversaryShown[j.key] = C.anniversaryShown[j.key] or time()
    for i = 1, j.lower or 0 do
        local k = "hours:" .. HOURS[i]
        C.anniversaryShown[k] = C.anniversaryShown[k] or time()
    end
    self.dirty = true
end
