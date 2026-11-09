-- The chronicle at the back: records, the level timeline and the gallery of moments.
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

-- (nemeses and dungeon reports are views of the travel desk now: UI/Views/Reports.lua)
