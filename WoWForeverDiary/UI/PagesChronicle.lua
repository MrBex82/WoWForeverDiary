-- The chronicle at the back: records, the level timeline, the gallery of moments, nemeses and dungeon reports.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

local GOLD = { 0.86, 0.62, 0.18, 1 }
local RED = { 0.75, 0.24, 0.16, 1 }
local GREEN = UI.c.good

local function empty(pool, canvas, tx, tw, y, text)
    local e = pool:Text(13, c.inkFaint, UI.FONT, "CENTER")
    e:SetText(text)
    e:SetWidth(tw)
    e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
end

-- a row of figures in light boxes: { value, label, colour }
local function tiles(...) return UI.Tiles(...) end

local function caption(pool, canvas, x, y, text)
    local t = pool:Text(9, c.redInk, UI.FONT)
    t:SetText(text:upper())
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
end

------------------------------------------------------------------------
-- Time in the world when a moment happened (played seconds)
------------------------------------------------------------------------
function WFD:PlayedAt(t)
    local C = self.C
    local di = self:DayIndex(t)
    local total = 0
    for d = 1, di - 1 do
        local day = C.days[d]
        if day then total = total + (day.online or 0) end
    end
    local day = C.days[di]
    if day and day.t0 and day.t1 and day.t1 > day.t0 then
        total = total + (day.online or 0) * max(0, min(1, (t - day.t0) / (day.t1 - day.t0)))
    end
    return total
end

-- { { level, secs, day, running } } for every level whose start and end are known
function WFD:LevelSteps()
    local C = self.C
    local reach, levels = {}, {}
    for lvl, t in pairs(C.levelTimes or {}) do
        reach[lvl] = (C.levelPlayed and C.levelPlayed[lvl]) or self:PlayedAt(t)
        levels[#levels + 1] = lvl
    end
    table.sort(levels)
    local steps = {}
    for i = 1, #levels - 1 do
        local a, b = levels[i], levels[i + 1]
        if b == a + 1 then
            steps[#steps + 1] = { level = a, secs = max(0, reach[b] - reach[a]), day = self:DayIndex(C.levelTimes[b]) }
        end
    end
    local top = levels[#levels]
    if top then
        local total = 0
        for _, day in pairs(C.days) do total = total + (day.online or 0) end
        steps[#steps + 1] = { level = top, secs = max(0, total - reach[top]), running = true }
    end
    return steps
end

------------------------------------------------------------------------
-- Records
------------------------------------------------------------------------
local function records()
    local C = WFD.C
    local best = {}
    local function consider(key, v, day, lower)
        if not v or v <= 0 then return end
        local b = best[key]
        if not b or (lower and v < b.v) or (not lower and v > b.v) then best[key] = { v = v, day = day } end
    end
    local places, people = {}, {}
    for _, z in pairs(C.zones) do
        for _, t in pairs(z.sub or {}) do
            local d = WFD:DayIndex(t)
            places[d] = (places[d] or 0) + 1
        end
    end
    for _, n in pairs(C.npcs) do
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
        { "income", "INV_Misc_Coin_01", L["Richest day"], function(b) return UI.CoinIcons(b.v, 14) end },
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
        list[#list + 1] = { h = 44, icon = d[2], label = d[3], value = b and d[4](b) or nil, day = b and b.day, dark = d[5] }
    end
    return list
end

UI:RegisterSection({
    key = "records", label = "Records", icon = "records", order = 14, thumb = false, leftStart = true,
    build = function(book) book:AddRows("records", records(), { head = L["Records"] }) end,
})

UI:RegisterRenderer("records", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then UI.PageTitle(pool, canvas, side, L["Records"], L["The best and the worst of days"], -56) end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        local has = r.value ~= nil
        pool:Plaque(tx + 16, y - 19, 28, UI.IconPath({ r.icon }, "records"), r.dark and RED or GOLD, has)
        local l = pool:Text(9, r.dark and c.bad or c.inkSoft, UI.FONT)
        l:SetText(r.label:upper())
        l:SetWordWrap(false)
        l:SetWidth(tw - 40 - 80)
        l:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y - 4)
        local v = pool:Text(16, has and c.ink or c.inkFaint, UI.HEAD)
        v:SetText(has and r.value or "-")
        v:SetWordWrap(false)
        v:SetWidth(tw - 40 - 80)
        v:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y - 17)
        if r.day then
            local d = pool:Text(13, c.redInk, UI.HEAD, "RIGHT")
            d:SetText(format(L["Day %d"], r.day))
            d:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 6)
            local dt = pool:Text(9, c.inkFaint, UI.FONT, "RIGHT")
            dt:SetText(WFD:DateStr(r.day))
            dt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 24)
            local hot = pool:Hot({ r.label, r.value, L["Click to read this day."] }, UI.DayGo(r.day))
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
            hot:SetSize(tw, r.h - 4)
        end
    end
end)

------------------------------------------------------------------------
-- Level timeline: how long each level took, as bars
------------------------------------------------------------------------
UI:RegisterSection({
    key = "levels", label = "Level timeline", icon = "level", order = 15, thumb = false,
    build = function(book)
        local steps = WFD:LevelSteps()
        local total, n, longest = 0, 0, 1
        for _, s in ipairs(steps) do
            if not s.running then total, n = total + s.secs, n + 1 end
            longest = max(longest, s.secs)
        end
        local fast, slow
        for _, s in ipairs(steps) do
            if not s.running and s.secs > 60 then
                if not fast or s.secs < fast.secs then fast = s end
                if not slow or s.secs > slow.secs then slow = s end
            end
        end
        local tilesH = UI.TileHeight(UI.TextW(), { L["Played for these levels"], L["Levels"], L["Per level"] })
        local list = { { h = tilesH + 16, summary = true, total = total, n = n } }
        if #steps == 0 then list[#list + 1] = { h = 40, empty = true } end
        for _, s in ipairs(steps) do
            list[#list + 1] = { h = 20, step = s, longest = longest, fast = s == fast, slow = s == slow }
        end
        book:AddRows("levels", list, { head = L["Level timeline"] })
    end,
})

UI:RegisterRenderer("levels", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then UI.PageTitle(pool, canvas, side, L["Level timeline"], L["How long each level took"], -56) end
    local top = -UI.TOP
    local BX = tx + 62
    -- the bars end where the longest time written beside them begins ("9 Std. 33 Min." is wide)
    local valueW = 56
    for _, r in ipairs(page.rows) do
        if r.step then
            local txt = WFD:DurationText(r.step.secs) .. (r.step.running and "  ..." or "")
            valueW = max(valueW, UI.MeasureWidth(txt, UI.FS(10), UI.FONT))
        end
    end
    local BW = tw - 62 - valueW - 10
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.summary then
            tiles(pool, canvas, tx, y, tw, {
                { WFD:DurationText(r.total), L["Played for these levels"], c.ink },
                { r.n, L["Levels"], c.ink },
                { r.n > 0 and WFD:DurationText(r.total / r.n) or "-", L["Per level"], c.ink },
            })
        elseif r.empty then
            empty(pool, canvas, tx, tw, y - 6, L["No level-ups recorded yet."])
        else
            local s = r.step
            local lab = pool:Text(11, s.running and c.inkFaint or c.ink, UI.FONT)
            lab:SetText(format(L["Level %d"], s.level))
            lab:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 4)
            local col = r.fast and GREEN or (r.slow and RED or GOLD)
            if s.running then col = { 0.62, 0.55, 0.44, 1 } end
            UI.ProgressBar(pool, canvas, BX, y - 6, BW, 9, s.secs / r.longest, col)
            local v = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
            v:SetText(WFD:DurationText(s.secs) .. (s.running and "  ..." or ""))
            v:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 4)
            local lines = { format(L["Level %d"], s.level), WFD:DurationText(s.secs) }
            if s.running then lines[#lines + 1] = L["Still on the way."] end
            if r.fast then lines[#lines + 1] = L["Fastest level"] end
            if r.slow then lines[#lines + 1] = L["Slowest level"] end
            if s.day then lines[#lines + 1] = format(L["Reached the next level on day %d."], s.day) end
            local hot = pool:Hot(lines, UI.DayGo(s.day))
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
            hot:SetSize(tw, r.h - 2)
        end
    end
end)

------------------------------------------------------------------------
-- Gallery: the character at every great moment, in the gear worn back then
------------------------------------------------------------------------
local GALLERY_KINDS = { level = true, boss = true, rare = true, dungeon = true, epic = true, landmark = true, challenge = true,
    first = true, weekly = true }
local PIC_H = 140

UI:RegisterSection({
    key = "gallery", label = "Gallery", icon = "gallery", order = 16, thumb = false,
    build = function(book)
        local all = {}
        for _, ev in ipairs(WFD.C.events) do
            if GALLERY_KINDS[ev.k] and ev.gear and next(ev.gear) then all[#all + 1] = ev end
        end
        table.sort(all, function(a, b) return a.t < b.t end)
        -- a picture in the same gear as the one before shows the same figure again: the small moments of a day
        -- (a place, a task) only get one when the gear has changed; levels, bosses and dungeons always do
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
        local list = {}
        if #evs == 0 then list[1] = { h = 40, empty = true } end
        for i = 1, #evs, 2 do list[#list + 1] = { h = PIC_H + 40, pair = { evs[i], evs[i + 1] } } end
        book:AddRows("gallery", list, { head = L["Gallery"] })
    end,
})

UI:RegisterRenderer("gallery", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then UI.PageTitle(pool, canvas, side, L["Gallery"], L["Moments, painted in the gear of their day"], -56) end
    local top = -UI.TOP
    local GAP_X = 12
    local pw = floor((tw - GAP_X) / 2)
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.empty then
            empty(pool, canvas, tx, tw, y - 6, L["The first painting waits for your first great moment."])
        else
            for k = 1, 2 do
                local ev = r.pair[k]
                if ev then
                    local x = tx + (k - 1) * (pw + GAP_X)
                    local pic = pool:Painting(pw, PIC_H)
                    pic:SetSize(pw, PIC_H)
                    pic:SetFrameLevel(canvas:GetFrameLevel() + 2)
                    pic:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
                    pic:Paint(ev)
                    pic.plaque:Hide()       -- the name stands below the picture, in full
                    local title = ev.k == "level" and ev.s or (ev.s and ev.s:match(":%s*(.+)$")) or ev.s or "?"
                    local t = pool:Text(12, c.ink, UI.HEAD, "CENTER")
                    t:SetText(title)
                    t:SetWidth(pw)
                    t:SetWordWrap(false)
                    t:SetPoint("TOP", canvas, "TOPLEFT", x + pw / 2, y - PIC_H - 5)
                    local s = pool:Text(9, c.inkFaint, UI.FONT, "CENTER")
                    s:SetText((format(L["Day %d"], ev.day or 0) .. "  -  " .. date(WFD.loc.date, ev.t)):upper())
                    s:SetPoint("TOP", canvas, "TOPLEFT", x + pw / 2, y - PIC_H - 21)
                    local hot = pool:Hot({ ev.s or "?", L["Click to read this day."] }, UI.DayGo(ev.day))
                    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y - PIC_H - 2)
                    hot:SetSize(pw, 32)
                end
            end
        end
    end
end)

------------------------------------------------------------------------
-- Nemeses: whoever sent you to the spirit healer, and whether you paid them back
------------------------------------------------------------------------
local function mobByName(name)
    for id, m in pairs(WFD.C.mobs) do
        if m.name == name then return id, m end
    end
end

UI:RegisterSection({
    key = "nemesis", label = "Nemeses", icon = "nemesis", order = 32, thumb = false,
    build = function(book)
        local C = WFD.C
        local arr, total = {}, 0
        for name, n in pairs(C.nemesis or {}) do
            arr[#arr + 1] = { name = name, n = n }
            total = total + (n.n or 0)
        end
        table.sort(arr, function(a, b) return (a.n.n or 0) > (b.n.n or 0) end)
        local deaths = 0
        for _, d in pairs(C.days) do deaths = deaths + d.deaths end
        local tilesH = UI.TileHeight(UI.TextW(), { L["Deaths"], L["Nemesis number one"] })
        local list = { { h = tilesH + 18, summary = true, deaths = deaths, top = arr[1] } }
        if #arr == 0 then list[#list + 1] = { h = 40, empty = true, deaths = deaths } end
        for _, e in ipairs(arr) do list[#list + 1] = { h = 50, e = e } end
        book:AddRows("nemesis", list, { head = L["Nemeses"] })
    end,
})

-- an ink stamp: text in a thin frame
local function stamp(pool, canvas, right, y, text, col)
    local t = pool:Text(9, col, UI.FONT, "CENTER")
    t:SetText(text:upper())
    local w = t:GetStringWidth() + 14
    local bg = pool:Rect(col, 0.10)
    bg:SetSize(w, 16)
    bg:SetPoint("TOPRIGHT", canvas, "TOPLEFT", right, y)
    for i, p in ipairs({ { "TOPLEFT", "TOPRIGHT" }, { "BOTTOMLEFT", "BOTTOMRIGHT" }, { "TOPLEFT", "BOTTOMLEFT" }, { "TOPRIGHT", "BOTTOMRIGHT" } }) do
        local e = pool:Rect(col, 0.9)
        e:SetPoint(p[1], bg, p[1])
        e:SetPoint(p[2], bg, p[2])
        if i <= 2 then e:SetHeight(1) else e:SetWidth(1) end
    end
    t:SetPoint("CENTER", bg, "CENTER", 0, 0)
end

UI:RegisterRenderer("nemesis", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then UI.PageTitle(pool, canvas, side, L["Nemeses"], L["They sent me to the spirit healer"], -56) end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.summary then
            tiles(pool, canvas, tx, y, tw, {
                { r.deaths, L["Deaths"], r.deaths > 0 and c.bad or c.ink },
                { r.top and r.top.name or "-", L["Nemesis number one"], c.bad },
            })
        elseif r.empty then
            empty(pool, canvas, tx, tw, y - 6, (r.deaths or 0) > 0
                and L["You have died, but who did it slipped past the diary."]
                or L["Nobody has defeated you yet. Long may it last!"])
        else
            local e = r.e
            local id, mob = mobByName(e.name)
            local revenge = mob and mob.kills > 0 and mob.last and e.n.last and mob.last > e.n.last
            pool:Plaque(tx + 16, y - 19, 28, UI.Icon("nemesis"), RED, true, tostring(e.n.n or 0))
            local n = pool:Text(15, c.bad, UI.HEAD)
            n:SetText(e.name)
            n:SetWordWrap(false)
            n:SetWidth(tw - 40 - 130)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y - 2)
            local lastDay = e.n.last and WFD:DayIndex(e.n.last)
            local sub = pool:Text(9, c.inkSoft, UI.FONT)
            sub:SetText((WFD:Count("Killed you %d times", e.n.n or 0) .. (e.n.zone and ("  -  " .. e.n.zone) or "")
                .. (lastDay and ("  -  " .. format(L["Day %d"], lastDay)) or "")):upper())
            sub:SetWordWrap(false)
            sub:SetWidth(tw - 40)
            sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 40, y - 22)
            if revenge then
                stamp(pool, canvas, tx + tw, y - 2, L["Revenge taken"], GREEN)
            else
                stamp(pool, canvas, tx + tw, y - 2, L["Score unsettled"], RED)
            end
            local lines = { e.name, WFD:Count("Killed you %d times", e.n.n or 0) }
            if mob then lines[#lines + 1] = WFD:Count("You slew them %d times.", mob.kills) end
            if id then lines[#lines + 1] = L["Click for the wanted poster."] end
            local hot = pool:Hot(lines, id and function() UI:ShowCard("creature", id) end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
            hot:SetSize(tw, r.h - 4)
        end
    end
end)

------------------------------------------------------------------------
-- Dungeon reports: one page per run
------------------------------------------------------------------------
UI:RegisterSection({
    key = "runs", label = "Dungeon reports", icon = "runs", order = 25,
    build = function(book)
        local runs = WFD.C.runs or {}
        if #runs == 0 then
            book:Add({ kind = "run", numbered = true, head = L["Dungeon reports"], empty = true })
            return
        end
        for i, r in ipairs(runs) do
            book:Add({ kind = "run", numbered = true, head = L["Dungeon reports"], run = r, num = i })
        end
    end,
})

UI:RegisterRenderer("run", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.empty then
        UI.PageTitle(pool, canvas, side, L["Dungeon reports"], nil, -56)
        empty(pool, canvas, tx, tw, -200, L["No dungeon visited yet. The depths are waiting."])
        return
    end
    local C = WFD.C
    local r = page.run
    local dur = r.t1 and (r.t1 - r.t0) or (time() - r.t0)
    local y = UI.PageTitle(pool, canvas, side, r.name,
        format(L["Day %d"], r.day or 1) .. "  -  " .. date(WFD.loc.date, r.t0) .. "  -  " .. WFD:DurationText(dur), -56)
    local myDeaths = 0
    for _, d in ipairs(r.deaths) do if d.me then myDeaths = myDeaths + 1 end end
    local th = tiles(pool, canvas, tx, y, tw, {
        { WFD:DurationText(dur), L["Duration"], c.ink },
        { r.kills, L["Kills"], c.ink },
        { #r.bosses, L["Bosses"], #r.bosses > 0 and GOLD or c.ink },
        { #r.deaths, L["Fallen"], #r.deaths > 0 and c.bad or c.ink },
    })
    y = y - th - 10

    -- the final boss, painted
    if r.last and r.last.gear and next(r.last.gear) then
        local pic = pool:Painting(tw, 110)
        pic:SetSize(tw, 110)
        pic:SetFrameLevel(canvas:GetFrameLevel() + 2)
        pic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        pic:Paint({ npc = r.last.npc, gear = r.last.gear, s = r.last.name })
        y = y - 120
    end

    -- the group
    caption(pool, canvas, tx, y, L["The group"])
    y = y - 14
    local people = { { name = C.name or UnitName("player"), classFile = C.classFile, level = r.level } }
    local names = {}
    for name in pairs(r.party) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        local p = r.party[name]
        people[#people + 1] = { name = name, classFile = p.classFile, level = p.level }
    end
    local step = tw / 5
    for i = 1, min(5, #people) do
        local p = people[i]
        local cx = tx + step * (i - 0.5)
        local path, coords = UI.ClassCrest(p.classFile)
        local pl = pool:Plaque(cx, y - 14, 24, path, UI.ClassColor(p.classFile), true, p.level and tostring(p.level) or nil, coords)
        local n = pool:Text(9, c.ink, UI.FONT, "CENTER")
        n:SetText(i == 1 and L["Me"] or p.name)
        n:SetWidth(step - 4)
        n:SetWordWrap(false)
        n:SetPoint("TOP", pl, "BOTTOM", 0, -4)
    end
    if #people > 5 then
        local more = pool:Text(10, c.inkFaint, UI.FONT, "RIGHT")
        more:SetText(format("+ %d", #people - 5))
        more:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 40)
    end
    y = y - 50

    -- bosses
    caption(pool, canvas, tx, y, L["Bosses"])
    local b = pool:Text(12, c.ink, UI.FONT)
    b:SetText(#r.bosses > 0 and table.concat(r.bosses, "  -  ") or "-")
    b:SetWidth(tw)
    if b.SetMaxLines then b:SetMaxLines(2) end
    b:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 13)
    y = y - 44

    -- loot
    caption(pool, canvas, tx, y, L["Loot"])
    if #r.loot == 0 then
        local n = pool:Text(12, c.inkFaint, UI.FONT)
        n:SetText("-")
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 13)
    end
    local per = floor(tw / 28)
    for i = 1, min(per, #r.loot) do
        local link = r.loot[i]
        -- frame in the colour of the link (the item quality)
        local col = { 0.2, 0.7, 0.2, 1 }
        local hex = link:match("|cff(%x%x%x%x%x%x)")
        local qc = not hex and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[WFD:ItemQuality(link)]
        if hex then
            col = { tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255, 1 }
        elseif qc and qc.r then
            col = { qc.r, qc.g, qc.b, 1 }
        end
        local cx = tx + 12 + (i - 1) * 28
        local pl = pool:Plaque(cx, y - 25, 20, WFD:ItemIcon(link) or UI.Icon("loot"), col, true)
        local hot = pool:Hot(nil, nil, link)
        hot:SetPoint("CENTER", pl, "CENTER")
        hot:SetSize(26, 26)
    end
    y = y - 46

    -- who fell
    caption(pool, canvas, tx, y, L["Fallen"])
    local fallen = {}
    for _, d in ipairs(r.deaths) do
        fallen[#fallen + 1] = d.me and (L["Me"] .. (d.by and (" (" .. d.by .. ")") or "")) or d.who
    end
    local f = pool:Text(12, #fallen > 0 and c.bad or c.inkSoft, UI.FONT)
    f:SetText(#fallen > 0 and table.concat(fallen, ", ") or L["Nobody fell."])
    f:SetWidth(tw)
    f:SetWordWrap(false)
    f:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 13)
end)
