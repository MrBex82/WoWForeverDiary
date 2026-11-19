-- The chronicle on the travel desk, to be read rather than turned: the milestones as a timeline by day, the first
-- times, the records, the level timeline, the year book and the gallery of painted moments.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local max, format = math.max, string.format

-- (labels are keys, translated when the view is built:
-- L["All"] L["Levels"] L["Bosses and rares"] L["Finds"] L["Honours"] L["Places"] L["Newest first"] L["Oldest first"]
-- L["Experienced"] L["Still to come"])

local function dayGo(day) return UI.DayGo(day) end

------------------------------------------------------------------------
-- Milestones: a timeline, day by day
------------------------------------------------------------------------
-- which kinds of moment a chip shows
local KINDS = {
    level = { level = true },
    fight = { boss = true, rare = true, dungeon = true, kills = true, death = true },
    find = { epic = true, rareitem = true, wealth = true, catch = true },
    honour = { honour = true, challenge = true, weekly = true, first = true, capsule = true },
    place = { zone = true, landmark = true },
}

local function milestoneData(state)
    local list = {}
    for _, ev in ipairs(WFD.C.events or {}) do
        if UI.SEAL[ev.k] and (ev.k ~= "challenge" or ev.all) then
            local ok = state.chip == "all" or (KINDS[state.chip] and KINDS[state.chip][ev.k])
            if ok and UI.ListMatches(state.q, ev.s) then list[#list + 1] = ev end
        end
    end
    local old = state.sort == "old"
    table.sort(list, function(a, b) if old then return a.t < b.t end return a.t > b.t end)
    -- one group per day, with its date
    local out, cur = {}, nil
    for _, ev in ipairs(list) do
        local day = ev.day or WFD:DayIndex(ev.t)
        if not cur or cur.day ~= day then
            cur = { day = day, title = format(L["Day %d"], day) .. "  -  " .. WFD:LongDate(day), items = {} }
            out[#out + 1] = cur
        end
        cur.items[#cur.items + 1] = ev
    end
    for _, g in ipairs(out) do g.right = tostring(#g.items) end
    return out
end

-- a moment is known by its time and kind
local function momentKey(ev) return tostring(ev.t) .. ":" .. tostring(ev.k) end
local function momentBy(key)
    for _, ev in ipairs(WFD.C.events or {}) do if momentKey(ev) == key then return ev end end
end

-- where a moment can be read further: its card, its part, its map
local function momentLinks(rp, ev)
    local R = UI.Router
    if ev.npc and (ev.k == "boss" or ev.k == "rare") then
        rp:Link(L["Bestiary"], nil, function() R.Go({ view = "bestiary", key = ev.npc }) end, L["Click for the wanted poster."], UI.Icon("bestiary"))
    end
    local PART = { level = "levels", dungeon = "runs", landmark = "landmarks", honour = "honour", first = "firsts",
        capsule = "capsule", weekly = "tasks", challenge = "tasks", catch = "fishbook" }
    local part = PART[ev.k]
    if part and UI.PART_VIEW[part] then
        local route = UI.PartRoute(part)
        if ev.k == "catch" and ev.item then route.key = ev.item end
        rp:Link(UI.PartLabel(part), nil, function() R.Go(route) end, L["Click to open."])
    end
    if ev.map then
        rp:Link(L["Show on the world map"], nil, function() R.Go({ view = "world", map = ev.map }) end)
    end
end

local function momentReport(rp, key)
    local ev = momentBy(key)
    if not ev then return end
    rp:Kicker(L[UI.SEAL_LABEL[ev.k] or "Moment"])
    rp:Title(ev.s or "?")
    if ev.gear and next(ev.gear) then rp:Picture(ev, 140) end
    rp:DayLink(ev.day or WFD:DayIndex(ev.t), ev.t)
    rp:Text(date("%H:%M", ev.t), "muted", "small")
    if ev.shot then rp:Text(L["Screenshot:"] .. " " .. ev.shot, "muted", "small") end
    rp:Gap(4)
    momentLinks(rp, ev)
end
UI.MomentLinks = momentLinks

UI.CollectionView({
    key = "milestones", label = "Milestones", group = "chronicle",
    chips = { { "all", "All" }, { "level", "Levels" }, { "fight", "Bosses and rares" }, { "find", "Finds" },
        { "honour", "Honours" }, { "place", "Places" } },
    sorts = { { "new", "Newest first" }, { "old", "Oldest first" } },
    summary = function()
        local n, days = 0, {}
        local nd = 0
        for _, ev in ipairs(WFD.C.events or {}) do
            if UI.SEAL[ev.k] and (ev.k ~= "challenge" or ev.all) then
                n = n + 1
                if ev.day and not days[ev.day] then days[ev.day] = true nd = nd + 1 end
            end
        end
        return { { n, L["Milestones"] }, { nd, L["Days"] } }
    end,
    data = milestoneData,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local ev = item.entry
            local path, col = UI.MomentIcon(ev)
            local lines = { ev.s, date(WFD.loc.date .. " %H:%M", ev.t) }
            if ev.shot then lines[#lines + 1] = L["Screenshot:"] .. " " .. ev.shot end
            lines[#lines + 1] = { L["Click: the report. Right-click: the day."], 0.5, 0.8, 1 }
            local day = dayGo(ev.day)
            row:Set({ icon = path, ring = { col[1], col[2], col[3] }, name = ev.s or "?",
                sub = UI.Upper(L[UI.SEAL_LABEL[ev.k] or "Moment"]), right = date("%H:%M", ev.t),
                go = function(button)
                    if button == "RightButton" then if day then day() end return end
                    UI.SelectIn("milestones", momentKey(ev))
                end,
                tip = function(r) K.ShowTip(r, lines[1], { select(2, unpack(lines)) }, "ANCHOR_RIGHT") end })
        end,
    },
    detail = momentReport,
    keyOf = momentKey,
    empty = function()
        if #(WFD.C.events or {}) == 0 then return L["No milestones yet."] end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- First times
------------------------------------------------------------------------
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"

UI.CollectionView({
    key = "firsts", label = "First times", group = "chronicle",
    chips = { { "all", "All" }, { "done", "Experienced" }, { "open", "Still to come" } },
    summary = function()
        local got = 0
        for _, def in ipairs(WFD.FIRSTS or {}) do if WFD.C.firsts and WFD.C.firsts[def.key] then got = got + 1 end end
        return { { got .. " / " .. #(WFD.FIRSTS or {}), L["First times"] } }
    end,
    data = function(state)
        local C = WFD.C
        local done, open = {}, {}
        for i, def in ipairs(WFD.FIRSTS or {}) do
            local f = C.firsts and C.firsts[def.key]
            if UI.ListMatches(state.q, L[def.label], f and f.s, f and f.zone) then
                if f then done[#done + 1] = { def = def, f = f } else open[#open + 1] = { def = def, i = i } end
            end
        end
        table.sort(done, function(a, b) return a.f.t < b.f.t end)
        local out = {}
        if state.chip ~= "open" and #done > 0 then out[#out + 1] = { title = L["Experienced"], right = tostring(#done), items = done } end
        -- under All, what is still to come is one dense line (its own chip lists them one by one)
        if state.chip == "all" and #open > 0 then
            out[#out + 1] = { title = L["Still to come"], right = tostring(#open), items = { { openAll = open } } }
        elseif state.chip == "open" and #open > 0 then
            out[#out + 1] = { title = L["Still to come"], right = tostring(#open), items = open }
        end
        return out
    end,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local e = item.entry
            if e.openAll then
                local names = {}
                for _, o in ipairs(e.openAll) do names[#names + 1] = L[o.def.label] end
                row:Set({ icon = QUESTION, ring = { 0.46, 0.39, 0.30 }, name = format(L["%d still to come"], #names), nameKey = "muted",
                    sub = table.concat(names, ", "),
                    go = function() UI.Router.Go({ view = "firsts", chip = "open" }) end,
                    tip = function(r)
                        K.ShowTip(r, format(L["%d still to come"], #names), { table.concat(names, ", "),
                            { L["Click to show them one by one."], 0.5, 0.8, 1 } }, "ANCHOR_RIGHT")
                    end })
                return
            end
            if not e.f then
                row:Set({ icon = QUESTION, ring = { 0.46, 0.39, 0.30 }, name = L[e.def.label], nameKey = "muted",
                    go = function() UI.SelectIn("firsts", e.def.key) end })
                return
            end
            local f = e.f
            local parts = {}
            if f.s and f.s ~= "" then parts[#parts + 1] = f.s end
            if f.zone and f.zone ~= f.s then parts[#parts + 1] = f.zone end
            row:Set({ icon = UI.IconPath(e.def.icon, "first"), ring = { 0.86, 0.62, 0.18 }, name = L[e.def.label],
                sub = table.concat(parts, "  -  "), right = format(L["Day %d"], f.day or 1),
                right2 = f.t and date(WFD.loc.date, f.t) or nil, go = function(button)
                    if button == "RightButton" then local g = dayGo(f.day) if g then g() end return end
                    UI.SelectIn("firsts", e.def.key)
                end })
        end,
    },
    -- the report of a first time: when and where, and the moment it is kept as
    detail = function(rp, key)
        local def
        for _, d in ipairs(WFD.FIRSTS or {}) do if d.key == key then def = d break end end
        if not def then return end
        local f = WFD.C.firsts and WFD.C.firsts[key]
        rp:Kicker(f and L["Experienced"] or L["Still to come"], f and "pos" or "muted")
        rp:Title(L[def.label])
        rp:Icons({ { UI.IconPath(def.icon, "first") } })
        if not f then
            rp:Text(L["It is written down by itself the first time it happens."], "soft", "body")
            return
        end
        if f.s and f.s ~= "" then rp:Text(f.s, "ink", "body") end
        if f.zone then rp:Text(f.zone, "soft", "body") end
        rp:DayLink(f.day, f.t)
        for _, ev in ipairs(WFD.C.events or {}) do
            if ev.k == "first" and ev.first == key then
                if ev.gear and next(ev.gear) then rp:Picture(ev, 140) end
                momentLinks(rp, ev)
                break
            end
        end
    end,
    keyOf = function(e) return e.def and e.def.key end,
    empty = function(state)
        if state.chip == "done" and state.q == "" and next(WFD.C.firsts or {}) == nil then
            return L["No first time yet. They come by themselves while you play."]
        end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- Records
------------------------------------------------------------------------
local function records()
    local C = WFD.C
    local best = {}
    local function consider(key, v, day)
        if not v or v <= 0 then return end
        local b = best[key]
        if not b or v > b.v then best[key] = { v = v, day = day } end
    end
    local places, people = {}, {}
    for _, z in pairs(C.zones or {}) do
        for _, t in pairs(z.sub or {}) do
            local d = WFD:DayIndex(t)
            places[d] = (places[d] or 0) + 1
        end
    end
    for _, n in pairs(C.npcs or {}) do
        if n.first then
            local d = WFD:DayIndex(n.first)
            people[d] = (people[d] or 0) + 1
        end
    end
    local run, runStart, bestRun = 0, nil, nil
    for d = 1, WFD:NumDays() do
        local day = C.days[d]
        if day then
            consider("kills", day.killTotal, d)
            consider("quests", #day.qd, d)
            consider("income", WFD:Sum(day.income), d)
            consider("online", day.online, d)
            consider("km", (day.steps or 0) * 0.9144 / 1000, d)
            consider("xp", day.xp, d)
            consider("places", places[d], d)
            consider("people", people[d], d)
            consider("deaths", day.deaths, d)
            if day.deaths == 0 and day.killTotal > 0 then
                if run == 0 then runStart = d end
                run = run + 1
                if not bestRun or run > bestRun.v then bestRun = { v = run, day = runStart, to = d } end
            elseif day.deaths > 0 then
                run = 0
            end
        end
    end
    for _, s in ipairs(WFD:LevelSteps()) do
        if not s.running and s.secs > 60 then
            if not best.fast or s.secs < best.fast.v then best.fast = { v = s.secs, day = s.day, level = s.level } end
            if not best.slow or s.secs > best.slow.v then best.slow = { v = s.secs, day = s.day, level = s.level } end
        end
    end
    best.streak = bestRun
    local defs = {
        { "kills", "INV_Sword_04", L["Most creatures slain in a day"], function(b) return tostring(b.v) end },
        { "quests", "INV_Scroll_03", L["Most quests in a day"], function(b) return tostring(b.v) end },
        { "income", "INV_Misc_Coin_01", L["Richest day"], function(b) return UI.CoinIcons(b.v, 13) end },
        { "xp", "Spell_Holy_SurgeOfLight", L["Most experience in a day"], function(b) return WFD:Int(b.v) .. " XP" end },
        { "online", "INV_Misc_PocketWatch_01", L["Longest day in the world"], function(b) return WFD:DurationText(b.v) end },
        { "km", "Ability_Tracking", L["Longest walk in a day"], function(b) return WFD:Dec(b.v) .. " km" end },
        { "places", "INV_Misc_Spyglass_02", L["Most places discovered in a day"], function(b) return tostring(b.v) end },
        { "people", "Ability_Warrior_RallyingCry", L["Most new faces in a day"], function(b) return tostring(b.v) end },
        { "fast", "Spell_Nature_Swiftness", L["Fastest level"], function(b)
            return format(L["Level %d"], b.level) .. "  -  " .. WFD:DurationText(b.v) end },
        { "slow", "Spell_Nature_TimeStop", L["Slowest level"], function(b)
            return format(L["Level %d"], b.level) .. "  -  " .. WFD:DurationText(b.v) end },
        { "streak", "Spell_Holy_DivineIntervention", L["Longest run without dying"], function(b)
            return WFD:Count("%d days", b.v) end },
        { "deaths", "INV_Misc_Bone_HumanSkull_01", L["Darkest day"], function(b) return WFD:Count("died %dx", b.v) end, true },
    }
    local list = {}
    for _, d in ipairs(defs) do
        local b = best[d[1]]
        list[#list + 1] = { icon = d[2], label = d[3], value = b and d[4](b) or nil, day = b and b.day, dark = d[5] }
    end
    return list
end

UI.ReportView({
    key = "records", label = "Records", group = "chronicle",
    fill = function(rp)
        rp:Kicker(L["Chronicle"])
        rp:Title(L["Records"], "display")
        rp:Text(L["The best and the worst of days"], "soft", "small", 12)
        for _, r in ipairs(records()) do
            local go = r.day and dayGo(r.day)
            rp:Line({ name = r.value or L["Not set yet"], nameKey = r.value and (r.dark and "neg" or "ink") or "muted",
                sub = UI.Upper(r.label), subKey = r.dark and "neg" or "gold",
                icon = UI.IconPath({ r.icon }, "records"), col = r.dark and { 0.75, 0.16, 0.10 } or { 0.86, 0.62, 0.18 },
                right = r.day and format(L["Day %d"], r.day) or nil, go = go,
                tip = go and { r.label, r.value, WFD:DateStr(r.day), L["Click to read this day."] } or nil })
        end
    end,
})

------------------------------------------------------------------------
-- The level timeline
------------------------------------------------------------------------
UI.ReportView({
    key = "levels", label = "Level timeline", group = "chronicle",
    fill = function(rp)
        local steps = WFD:LevelSteps()
        local total, n, longest = 0, 0, 1
        local fast, slow
        for _, s in ipairs(steps) do
            if not s.running then total, n = total + s.secs, n + 1 end
            longest = max(longest, s.secs)
            if not s.running and s.secs > 60 then
                if not fast or s.secs < fast.secs then fast = s end
                if not slow or s.secs > slow.secs then slow = s end
            end
        end
        rp:Kicker(L["Chronicle"])
        rp:Title(L["Level timeline"], "display")
        rp:Text(L["How long each level took"], "soft", "small", 12)
        rp:Tiles({
            { WFD:DurationText(total), L["Played for these levels"] },
            { n, L["Levels"] },
            { n > 0 and WFD:DurationText(total / n) or "-", L["Per level"] },
        }, 3)
        if #steps == 0 then rp:Text(L["No level-ups recorded yet."], "soft", "body") return end
        rp:Head(L["Levels"], tostring(#steps))
        for _, s in ipairs(steps) do
            local col = { 0.86, 0.62, 0.18 }
            local note
            if s.running then col, note = { 0.62, 0.55, 0.44 }, L["Still on the way."]
            elseif s == fast then col, note = { 0.30, 0.66, 0.30 }, L["Fastest level"]
            elseif s == slow then col, note = { 0.75, 0.24, 0.16 }, L["Slowest level"] end
            local go = s.day and dayGo(s.day)
            rp:Line({ name = format(L["Level %d"], s.level), num = s.level, col = col, sub = note,
                right = WFD:DurationText(s.secs) .. (s.running and "  ..." or ""), frac = s.secs / longest, barCol = col,
                go = go, tip = s.day and { format(L["Level %d"], s.level), format(L["Reached the next level on day %d."], s.day) } or nil })
        end
    end,
})

------------------------------------------------------------------------
-- The year book
------------------------------------------------------------------------
local function years()
    local C = WFD.C
    local out = {}
    for idx, d in pairs(C.days) do
        local dt = date("*t", WFD:DayTime(idx))
        local y = out[dt.year]
        if not y then
            y = { year = dt.year, days = 0, kills = 0, quests = 0, steps = 0, income = 0, deaths = 0, online = 0, levels = 0,
                  months = {}, moods = {} }
            for m = 1, 12 do y.months[m] = { kills = 0, days = 0 } end
            out[dt.year] = y
        end
        local k = d.killTotal or 0
        y.days = y.days + 1
        y.kills = y.kills + k
        y.quests = y.quests + #(d.qd or {})
        y.steps = y.steps + (d.steps or 0)
        y.income = y.income + WFD:Sum(d.income)
        y.deaths = y.deaths + (d.deaths or 0)
        y.online = y.online + (d.online or 0)
        local mood = WFD:DayMood(d)
        if mood then y.moods[mood] = (y.moods[mood] or 0) + 1 end
        local mo = y.months[dt.month]
        mo.kills = mo.kills + k
        mo.days = mo.days + 1
        if k > 0 and (not y.busiest or k > y.busiest.kills) then y.busiest = { kills = k, day = idx } end
    end
    local first = C.startLevel or 1
    for lvl, t in pairs(C.levelTimes or {}) do
        local y = out[date("*t", t).year]
        if y and lvl > first then y.levels = y.levels + 1 end
    end
    local list = {}
    for _, y in pairs(out) do
        for m = 1, 12 do
            if y.months[m].kills > 0 and (not y.bestMonth or y.months[m].kills > y.months[y.bestMonth].kills) then y.bestMonth = m end
        end
        list[#list + 1] = y
    end
    table.sort(list, function(a, b) return a.year > b.year end)
    return list
end

UI.ReportView({
    key = "yearbook", label = "Year book", group = "chronicle",
    fill = function(rp)
        rp:Kicker(L["Chronicle"])
        rp:Title(L["Year book"], "display")
        rp:Text(L["A year of travel in figures"], "soft", "small", 12)
        local list = years()
        if #list == 0 then rp:Text(L["The first year is still being written."], "soft", "body") return end
        for _, y in ipairs(list) do
            rp:Head(format(L["Year %d"], y.year))
            rp:Tiles({
                { y.days, L["Days"] }, { y.kills, L["Kills"] }, { y.quests, L["Quests"] },
                { WFD:Dec(y.steps * 0.9144 / 1000), L["Kilometres"] }, { UI.CoinIcons(y.income, 12), L["Income"], nil, "pos" },
                { y.deaths, L["Deaths"], nil, y.deaths > 0 and "neg" or nil },
            }, 3)
            local lines = {}
            if y.busiest then
                rp:Line({ name = format(L["Busiest day: %s with %d kills"], WFD:DateStr(y.busiest.day), y.busiest.kills), wrap = true,
                    icon = UI.Icon("bestiary"), col = { 0.62, 0.10, 0.06 }, go = dayGo(y.busiest.day) })
            end
            if y.bestMonth then lines[#lines + 1] = format(L["Best month: %s with %d kills"], WFD.loc.months[y.bestMonth], y.months[y.bestMonth].kills) end
            local topMood, topN
            for k, n in pairs(y.moods) do
                if not topN or n > topN or (n == topN and k < topMood) then topMood, topN = k, n end
            end
            if topMood then lines[#lines + 1] = format(L["Most days were: %s (%d)"], L[topMood], topN) end
            local steps = WFD.RepSteps and WFD:RepSteps(y.year) or 0
            if steps > 0 then lines[#lines + 1] = format(L["Reputation steps up: %d"], steps) end
            if y.levels > 0 then lines[#lines + 1] = WFD:Count("%d levels gained", y.levels) end
            if y.online > 0 then lines[#lines + 1] = format(L["Time online: %s"], WFD:DurationText(y.online)) end
            rp:Bullets(lines)
            -- month by month
            rp:Gap(4)
            rp:Kicker(L["Month by month"], "soft")
            local most = 1
            for m = 1, 12 do most = max(most, y.months[m].kills) end
            -- the first day of every month with entries: a month leads to it
            local firstOf = {}
            for d = 1, WFD:NumDays() do
                if WFD.C.days[d] then
                    local t = date("*t", WFD:DayTime(d))
                    if t.year == y.year and not firstOf[t.month] then firstOf[t.month] = d end
                end
            end
            for m = 1, 12 do
                local mo = y.months[m]
                if mo.days > 0 then
                    local col = (m == y.bestMonth) and { 0.86, 0.62, 0.18 } or { 0.62, 0.30, 0.20 }
                    local go = firstOf[m] and dayGo(firstOf[m])
                    rp:Line({ name = WFD.loc.months[m], sub = WFD:Count("%d days with entries", mo.days), right = WFD:Count("%d kills", mo.kills),
                        num = m, col = col, frac = mo.kills / most, barCol = col, go = go,
                        tip = go and { WFD.loc.months[m], { L["Click to read the first day of this month."], 0.5, 0.8, 1 } } or nil })
                end
            end
            rp:Gap(14)
        end
    end,
})

------------------------------------------------------------------------
-- The gallery: every great moment painted in the gear of its day
------------------------------------------------------------------------
local GALLERY_KINDS = { level = true, boss = true, rare = true, dungeon = true, epic = true, landmark = true, challenge = true,
    first = true, weekly = true }
local PIC_W, PIC_H = 250, 140

local function galleryList()
    local all = {}
    for _, ev in ipairs(WFD.C.events or {}) do
        if GALLERY_KINDS[ev.k] and ev.gear and next(ev.gear) then all[#all + 1] = ev end
    end
    table.sort(all, function(a, b) return a.t < b.t end)
    -- a picture in the same gear as the one before shows the same figure again: the small moments of a day only
    -- get one when the gear has changed; levels, bosses and dungeons always do
    local function sameGear(a, b)
        for slot, id in pairs(a) do if b[slot] ~= id then return false end end
        for slot in pairs(b) do if a[slot] == nil then return false end end
        return true
    end
    local evs, last = {}, nil
    for _, ev in ipairs(all) do
        local great = ev.k == "level" or ev.k == "boss" or ev.k == "dungeon"
        if great or not last or not sameGear(ev.gear, last.gear) then
            evs[#evs + 1] = ev
            last = ev
        end
    end
    return evs
end

UI.CollectionView({
    key = "gallery", label = "Gallery", group = "chronicle",
    chips = { { "all", "All" }, { "level", "Levels" }, { "fight", "Bosses and rares" }, { "place", "Places" } },
    sorts = { { "new", "Newest first" }, { "old", "Oldest first" } },
    summary = function() return { { #galleryList(), L["Gallery"] } } end,
    data = function(state)
        local list = {}
        for _, ev in ipairs(galleryList()) do
            local ok = state.chip == "all" or (KINDS[state.chip] and KINDS[state.chip][ev.k])
            if ok and UI.ListMatches(state.q, ev.s) then list[#list + 1] = ev end
        end
        if state.sort ~= "old" then
            local rev = {}
            for i = #list, 1, -1 do rev[#rev + 1] = list[i] end
            list = rev
        end
        return { { items = list } }
    end,
    cell = {
        w = PIC_W, h = PIC_H + 44, gap = 14,
        make = function(parent)
            local f = CreateFrame("Button", nil, parent)
            f.pic = UI.Painting(f, PIC_W, PIC_H)
            f.pic:SetPoint("TOPLEFT")
            f.pic.plaque:Hide()
            f.title = K.Text(f, "strong", "ink", "CENTER")
            f.title:SetPoint("TOP", f.pic, "BOTTOM", 0, -5)
            f.title:SetWidth(PIC_W)
            f.title:SetWordWrap(false)
            f.sub = K.Text(f, "small", "muted", "CENTER")
            f.sub:SetPoint("TOP", f.title, "BOTTOM", 0, -2)
            f:SetScript("OnClick", function(s) if s.go then s.go() end end)
            f:SetScript("OnEnter", function(s)
                K.ShowTip(s, s.ev and s.ev.s or "?", { L["Click to read this day."] }, "ANCHOR_RIGHT")
            end)
            f:SetScript("OnLeave", function() GameTooltip:Hide() end)
            return f
        end,
        fill = function(f, item)
            local ev = item.entry
            f.ev = ev
            f.pic:Paint(ev)
            f.pic.plaque:Hide()
            f.title:SetText(ev.k == "level" and ev.s or (ev.s and ev.s:match(":%s*(.+)$")) or ev.s or "?")
            f.sub:SetText(UI.Upper(format(L["Day %d"], ev.day or 0) .. "  -  " .. date(WFD.loc.date, ev.t)))
            f.go = dayGo(ev.day)
        end,
    },
    empty = function()
        if #galleryList() == 0 then return L["The first painting waits for your first great moment."] end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- The week in review: a calendar week, with the week before and after
------------------------------------------------------------------------
UI.ReportView({
    key = "recap", label = "The week in review", group = "chronicle",
    fill = function(rp, v)
        local R = UI.Router
        local week = v.route and v.route.week or 1
        if week < 0 then week = 0 end
        local from, to = WFD:WeekRange(week)
        local s = UI.WeekStats(from, to)
        rp:Kicker(L["Chronicle"])
        rp:Title(L["The week in review"], "display")
        rp:Text(UI.WeekTitle(from, to), "soft", "small", 10)
        rp:Tiles({
            { s.kills, L["Creatures slain"] }, { s.quests, L["Quests"] },
            { #s.levels > 0 and ("+" .. #s.levels) or "0", L["Levels"] },
            { WFD:Dec(s.km), L["Kilometres"] }, { s.places, L["New places"] },
            { s.deaths, L["Deaths"], nil, s.deaths > 0 and "neg" or nil },
        }, 3)
        if s.days == 0 then rp:Text(L["The book waits for new stories."], "soft", "body") end
        if s.best then
            rp:Line({ name = L["Best day"], sub = format(L["Day %d"], s.best) .. "  -  " .. WFD:Count("%d kills", s.bestK),
                icon = UI.Icon("bestiary"), col = { 0.62, 0.10, 0.06 }, go = UI.DayGo(s.best) })
        end
        -- every one of them, nothing is cut off
        if #s.zones > 0 then rp:Head(L["New regions"], tostring(#s.zones)) rp:Bullets(s.zones) end
        if #s.marks > 0 then rp:Head(L["Landmarks"], tostring(#s.marks)) rp:Bullets(s.marks) end
        if #s.honours > 0 then rp:Head(L["Honours"], tostring(#s.honours)) rp:Bullets(s.honours) end
        rp:Gap(10)
        rp:Button(L["Week before"], function() R.Go({ view = "recap", week = week + 1 }, { noHistory = true }) end, "ghost")
        if week > 0 then
            rp:Button(L["Week after"], function() R.Go({ view = "recap", week = week - 1 }, { noHistory = true }) end, "ghost")
        end
        -- the week as one line in the chat's input field: it is only sent when you press Enter yourself
        if ChatFrame_OpenChat then
            rp:Button(L["Into the chat"], function()
                ChatFrame_OpenChat(format(L["My week: %d kills, %d quests, %s km, %d levels, %d new places."],
                    s.kills, s.quests, WFD:Dec(s.km), #s.levels, s.places))
            end, "ghost")
        end
    end,
})

