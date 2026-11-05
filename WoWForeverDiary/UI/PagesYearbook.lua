-- The year book: for each calendar year of the diary a spread. On the left the year in figures and its
-- highlights, on the right the months side by side.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

local GOLD = { 0.86, 0.62, 0.18, 1 }

-- everything the diary knows about each calendar year, in one pass over the days
local function collect()
    local C = WFD.C
    local years = {}
    for idx, d in pairs(C.days) do
        local t = WFD:DayTime(idx)
        local dt = date("*t", t)
        local y = years[dt.year]
        if not y then
            y = { year = dt.year, days = 0, kills = 0, quests = 0, steps = 0, income = 0, deaths = 0, online = 0, levels = 0,
                  months = {}, moods = {} }
            for m = 1, 12 do y.months[m] = { kills = 0, days = 0 } end
            years[dt.year] = y
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
        local y = years[date("*t", t).year]
        if y and lvl > first then y.levels = y.levels + 1 end
    end
    local list = {}
    for _, y in pairs(years) do
        local bestM
        for m = 1, 12 do
            if y.months[m].kills > 0 and (not bestM or y.months[m].kills > y.months[bestM].kills) then bestM = m end
        end
        y.bestMonth = bestM
        list[#list + 1] = y
    end
    table.sort(list, function(a, b) return a.year < b.year end)
    return list
end

UI:RegisterSection({
    key = "yearbook", label = "Year book", icon = "records", order = 14.5,
    build = function(book)
        local list = collect()
        for _, y in ipairs(list) do
            book:Add({ kind = "yearbook", numbered = true, head = L["Year book"], yr = y, part = 1 })
            book:Add({ kind = "yearbook", numbered = true, head = L["Year book"], yr = y, part = 2 })
        end
        if #list == 0 then book:Add({ kind = "yearbook", numbered = true, head = L["Year book"], part = 0 }) end
    end,
})

UI:RegisterRenderer("yearbook", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = page.yr
    if not y then
        UI.PageTitle(pool, canvas, side, L["Year book"], L["A year of travel in figures"], -56)
        local e = pool:Text(12, c.inkFaint, UI.FONT)
        e:SetWidth(tw)
        e:SetText(L["The first year is still being written."])
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, -120)
        return
    end
    if page.part == 1 then
        local top = UI.PageTitle(pool, canvas, side, format(L["Year %d"], y.year), L["A year of travel in figures"], -56)
        local km = floor(y.steps * 0.9144 / 100 + 0.5) / 10
        local h = UI.Tiles(pool, canvas, tx, top, tw, {
            { y.days, L["Days"], c.ink }, { y.kills, L["Kills"], c.ink }, { y.quests, L["Quests"], c.ink },
        })
        top = top - h - 8
        h = UI.Tiles(pool, canvas, tx, top, tw, {
            { km, L["Kilometres"], c.ink }, { UI.CoinIcons(y.income, 12), L["Income"], c.good }, { y.deaths, L["Deaths"], c.bad },
        })
        top = top - h - 18
        UI.SectionHead(pool, canvas, tx, tw, top + 18, 32, L["Highlights"])
        top = top - 28
        local function line(text, go)
            local fs = pool:Text(13, c.ink, UI.FONT)
            fs:SetWidth(tw - 8)
            fs:SetText(text)
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, top)
            local need = max(18, fs:GetStringHeight()) + 8
            if go then
                local hot = pool:Hot({ text }, go)
                hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, top + 3)
                hot:SetSize(tw, need)
            end
            top = top - need
        end
        if y.busiest then
            line(format(L["Busiest day: %s with %d kills"], WFD:DateStr(y.busiest.day), y.busiest.kills),
                function() UI:GoToDay(y.busiest.day) end)
        end
        if y.bestMonth then
            line(format(L["Best month: %s with %d kills"], WFD.loc.months[y.bestMonth], y.months[y.bestMonth].kills))
        end
        local topMood, topN
        for k, n in pairs(y.moods) do
            if not topN or n > topN or (n == topN and k < topMood) then topMood, topN = k, n end
        end
        if topMood then line(format(L["Most days were: %s (%d)"], L[topMood], topN)) end
        local steps = WFD.RepSteps and WFD:RepSteps(y.year) or 0
        if steps > 0 then line(format(L["Reputation steps up: %d"], steps)) end
        if y.levels > 0 then line(WFD:Count("%d levels gained", y.levels)) end
        if y.online > 0 then line(format(L["Time online: %s"], WFD:DurationText(y.online))) end
    else
        UI.PageTitle(pool, canvas, side, L["Month by month"], tostring(y.year), -56)
        local top = -118
        local most = 1
        for m = 1, 12 do most = max(most, y.months[m].kills) end
        for m = 1, 12 do
            local mo = y.months[m]
            local ry = top - (m - 1) * 32
            local n = pool:Text(12, mo.days > 0 and c.ink or c.inkFaint, UI.FONT)
            n:SetText(WFD.loc.months[m])
            n:SetWordWrap(false)
            n:SetWidth(tw - 70)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, ry)
            local v = pool:Text(11, c.inkSoft, UI.FONT, "RIGHT")
            v:SetText(mo.days > 0 and tostring(mo.kills) or "-")
            v:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, ry - 1)
            UI.ProgressBar(pool, canvas, tx, ry - 18, tw, 5, mo.kills / most, m == y.bestMonth and GOLD or c.redInk)
            if mo.days > 0 then
                local hot = pool:Hot({ WFD.loc.months[m], WFD:Count("%d days with entries", mo.days),
                    WFD:Count("%d kills", mo.kills) })
                hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, ry + 2)
                hot:SetSize(tw, 30)
            end
        end
    end
end)
