-- Exploring and collecting: the collection overview with next goals, and the atlas of both continents.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

local TITLE_H = 116
local LOCKED = { 0.46, 0.39, 0.30, 1 }
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"
local TEAL = { 0.30, 0.66, 0.62, 1 }
local GREEN = UI.c.good
local GOLD = { 0.86, 0.62, 0.18, 1 }

-- rows of different heights over as many pages as needed (the first page leaves room for a title)
local function paginate(book, kind, list, extra)
    local page, y
    local function newPage(first)
        page = book:Add({ kind = kind, rows = {}, first = first, numbered = true })
        for k, v in pairs(extra or {}) do page[k] = v end
        y = first and TITLE_H or 0
    end
    newPage(true)
    for _, r in ipairs(list) do
        if y + r.h + (r.keep or 0) > UI.AREA_H then newPage(false) end
        r.y = y
        page.rows[#page.rows + 1] = r
        y = y + r.h
    end
end

local function goTo(key)
    return function()
        local p = UI.book and UI.book.sectionStart[key]
        if p then UI:GoToPage(p) end
    end
end

------------------------------------------------------------------------
-- Everything worth collecting, counted once per build of the book
------------------------------------------------------------------------
local function gather()
    local honours, sum = WFD:HonourState()
    local groups, lmFound, lmTotal = WFD:LandmarkState()
    local conts, zVisited, zTotal = WFD:AtlasState()
    local kinds = 0
    for _ in pairs(WFD.C.mobs) do kinds = kinds + 1 end
    local tiers = UI.BESTIARY_TIERS or {}
    local nextTier
    for _, t in ipairs(tiers) do
        if kinds < t[1] then nextTier = t break end
    end
    local catches = 0
    for _ in pairs(WFD.C.catch or {}) do catches = catches + 1 end
    local nextFish
    for _, t in ipairs(UI.FISH_TIERS or {}) do
        if catches < t[1] then nextFish = t break end
    end
    local dFound, dTotal = 0, 0
    for _, g in ipairs(groups) do
        if g.def.key == "dungeons" or g.def.key == "raids" then
            dFound, dTotal = dFound + g.found, dTotal + g.total
        end
    end
    local sFound, sTotal = 0, 0
    for _, e in ipairs(honours) do
        if e.def.secret then
            sTotal = sTotal + 1
            if not e.hidden then sFound = sFound + 1 end
        end
    end
    return {
        honours = honours, sum = sum, groups = groups, lmFound = lmFound, lmTotal = lmTotal,
        conts = conts, zVisited = zVisited, zTotal = zTotal, kinds = kinds, nextTier = nextTier,
        catches = catches, nextFish = nextFish, lastFish = (UI.FISH_TIERS or {})[#(UI.FISH_TIERS or {})],
        lastTier = tiers[#tiers], dFound = dFound, dTotal = dTotal, sFound = sFound, sTotal = sTotal,
    }
end

------------------------------------------------------------------------
-- The collection: one bar per collection, and what to do next
------------------------------------------------------------------------
UI:RegisterSection({
    key = "collection", label = "Collection", icon = "album", order = 5, leftStart = true,
    build = function(book)
        book.collection = gather()
        book:Add({ kind = "collection", numbered = true, head = L["Collection"] })
        book:Add({ kind = "nextgoals", numbered = true, head = L["Collection"] })
    end,
})

UI:RegisterRenderer("collection", function(pool, page, side, canvas)
    local g = UI.book.collection
    if not g then return end
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Collection"], L["What is left to discover"], -56)
    local beast = g.nextTier or g.lastTier or { 10, "Bronze" }
    local items = {
        { L["Book of honour"], g.sum.tiers, g.sum.totalTiers, UI.Icon("honour"), GOLD,
          format(L["%d honour points"], g.sum.points), "honour" },
        { L["Landmarks"], g.lmFound, g.lmTotal, UI.Icon("sight"), TEAL, L["Famous places of Azeroth"], "landmarks" },
        { L["Atlas"], g.zVisited, g.zTotal, UI.Icon("map"), GREEN, L["Regions explored"], "atlas" },
        { L["Bestiary"], g.kinds, beast[1], UI.Icon("bestiary"), c.bad,
          g.nextTier and format(L["Next rank: %s"], L[g.nextTier[2]]) or L["Complete!"], "bestiary" },
        { L["Angler's log"], g.catches, (g.nextFish or g.lastFish or { 5 })[1], UI.Icon("fish"), { 0.30, 0.58, 0.86, 1 },
          g.nextFish and format(L["Next rank: %s"], L[g.nextFish[2]]) or L["Complete!"], "fishbook" },
        { L["Dungeons"] .. " & " .. L["Raids"], g.dFound, g.dTotal, UI.Icon("key"), { 0.78, 0.42, 0.08, 1 },
          L["Dark places, rich rewards"], "landmarks" },
        { L["Secrets"], g.sFound, g.sTotal, QUESTION, { 0.70, 0.45, 0.85, 1 },
          L["Some honours stay hidden until you find them."], "honour" },
    }
    local ROW = 48
    for i, it in ipairs(items) do
        local ry = y - (i - 1) * ROW
        local total = max(1, it[3])
        local frac = min(1, it[2] / total)
        local done = it[2] >= it[3] and it[3] > 0
        pool:Plaque(tx + 18, ry - 20, 30, it[4], done and GOLD or (it[2] > 0 and it[5] or LOCKED), it[2] > 0)
        local n = pool:Text(15, c.ink, UI.HEAD)
        n:SetText(it[1])
        n:SetWordWrap(false)
        n:SetWidth(tw - 46 - 70)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 44, ry - 2)
        local cnt = pool:Text(14, c.ink, UI.HEAD, "RIGHT")
        cnt:SetText(it[2] .. "|cffc2a880 / " .. it[3] .. "|r")
        cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, ry - 3)
        local sub = pool:Text(9, c.inkSoft, UI.FONT)
        sub:SetText(it[6]:upper())
        sub:SetWordWrap(false)
        sub:SetWidth(tw - 44 - 40)
        sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 44, ry - 21)
        local pc = pool:Text(9, c.inkFaint, UI.FONT, "RIGHT")
        pc:SetText(floor(frac * 100 + 0.5) .. "%")
        pc:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, ry - 21)
        UI.ProgressBar(pool, canvas, tx + 44, ry - 35, tw - 44, 5, frac, it[5])
        local hot = pool:Hot({ it[1], it[2] .. " / " .. it[3], L["Click to open this part of the book."] }, goTo(it[7]))
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, ry + 2)
        hot:SetSize(tw, ROW - 6)
    end
end)

-- a place you have not seen yet, the same one all day long
local function destination(g)
    local mainCont, best = nil, -1
    for _, e in ipairs(g.conts) do
        if e.secs > best then mainCont, best = e.id, e.secs end
    end
    local cand = {}
    for _, grp in ipairs(g.groups) do
        local cont = grp.def.cont
        if grp.def.key ~= "raids" and (cont == nil or cont == mainCont) then
            for _, it in ipairs(grp.items) do
                if not it.found then cand[#cand + 1] = { it = it, grp = grp } end
            end
        end
    end
    if #cand == 0 then return nil end
    return cand[(WFD:NumDays() * 7919) % #cand + 1], mainCont
end

UI:RegisterRenderer("nextgoals", function(pool, page, side, canvas)
    local g = UI.book.collection
    if not g then return end
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Next goals"], L["Where will the road lead tomorrow?"], -56)

    -- tasks of the day, with their progress
    local tasks = WFD.TodayChallenges and WFD:TodayChallenges()
    if tasks and #tasks.list > 0 then
        local doneN = 0
        for _ in pairs(tasks.done) do doneN = doneN + 1 end
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Tasks of the day"], doneN .. " / " .. #tasks.list)
        y = y - 22
        local today = WFD:DayIndex()
        for i, task in ipairs(tasks.list) do
            local done = tasks.done[i]
            local v, gl = WFD:ChallengeProgress(today, task)
            pool:Plaque(tx + 10, y - 9, 16, UI.Icon("task"), done and GREEN or LOCKED, done and true or false)
            local t = pool:Text(12, done and c.inkSoft or c.ink, UI.FONT)
            t:SetText(WFD:ChallengeText(task))
            t:SetWordWrap(false)
            t:SetWidth(tw - 26 - 96)
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 26, y - 3)
            if done then
                local ok = pool:Text(10, GREEN, UI.FONT, "RIGHT")
                ok:SetText(L["done"])
                ok:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 3)
            else
                local pv = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
                pv:SetText(v .. " / " .. gl)
                pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 1)
                UI.ProgressBar(pool, canvas, tx + tw - 70, y - 14, 70, 3, v / max(1, gl), GREEN)
            end
            y = y - 22
        end
        y = y - 10
    end

    -- task of the week
    local wk, w
    if WFD.ThisWeek then wk, w = WFD:ThisWeek() end
    if wk and wk.task then
        local from, to = WFD:WeekDays(w)
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Task of the week"], format(L["Days %d-%d"], from, to))
        y = y - 22
        local v, gl = WFD:WeeklyProgress(w, wk.task)
        local done = wk.done
        pool:Plaque(tx + 12, y - 11, 20, UI.Icon("first"), done and GREEN or GOLD, true)
        local t = pool:Text(12, done and c.inkSoft or c.ink, UI.FONT)
        t:SetText(WFD:WeeklyText(wk.task))
        t:SetWordWrap(false)
        t:SetWidth(tw - 30 - 96)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 4)
        if done then
            local ok = pool:Text(10, GREEN, UI.FONT, "RIGHT")
            ok:SetText(L["done"])
            ok:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 4)
        else
            local pv = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
            pv:SetText((wk.task.k == "wkm" and WFD:Dec(v) or v) .. " / " .. gl)
            pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
            UI.ProgressBar(pool, canvas, tx + tw - 70, y - 15, 70, 3, v / max(1, gl), GOLD)
        end
        y = y - 34
    end

    -- destination of the day
    local dest, mainCont = destination(g)
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Destination of the day"])
    y = y - 22
    if dest then
        local it = dest.it
        pool:Plaque(tx + 24, y - 24, 40, UI.IconPath({ it.icon }, "sight"), TEAL, true)
        local n = pool:Text(19, c.ink, UI.HEAD)
        n:SetText(it.name)
        n:SetWordWrap(false)
        n:SetWidth(tw - 56)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 54, y - 4)
        local s = pool:Text(9, c.redInk, UI.FONT)
        s:SetText(L[dest.grp.def.label]:upper())
        s:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 54, y - 28)
        local h = pool:Text(11, c.inkSoft, UI.FONT)
        h:SetText(L["You have not seen this place yet."])
        h:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 54, y - 41)
        local hot = pool:Hot({ it.name, L["You have not seen this place yet."], L["Click for all landmarks."] }, goTo("landmarks"))
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
        hot:SetSize(tw, 56)
    else
        local n = pool:Text(13, c.inkSoft, UI.FONT)
        n:SetText(L["You have seen every landmark. Remarkable!"])
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 8)
    end
    y = y - 66

    -- the honours closest to their next tier
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Almost there"])
    y = y - 20
    local near = {}
    for _, e in ipairs(g.honours) do
        if e.next and not e.hidden then
            near[#near + 1] = { e = e, f = (e.value - e.prev) / max(1, e.next - e.prev) }
        end
    end
    table.sort(near, function(a, b) return a.f > b.f end)
    for i = 1, min((tasks and 2 or 4) - ((wk and wk.task) and 1 or 0), #near) do
        local e, f = near[i].e, near[i].f
        local m = WFD:MetalOf(e.tier + 1, e.n)
        local ic = pool:Icon(UI.IconPath(e.def.icon), 20)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 2, y - 2)
        local n = pool:Text(12, c.ink, UI.FONT)
        n:SetText(L[e.def.name] .. "  |cff" .. UI.Hex(m.col) .. L[m.name] .. "|r")
        n:SetWordWrap(false)
        n:SetWidth(tw - 30 - 96)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 2)
        local d = pool:Text(9, c.inkFaint, UI.FONT)
        d:SetText(WFD:HonourText(e.def, e.next))
        d:SetWordWrap(false)
        d:SetWidth(tw - 30 - 96)
        d:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 16)
        local v = e.value
        if e.def.m == "km" then v = floor(v * 10) / 10 end
        local pv = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        pv:SetText(v .. " / " .. e.next)
        pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
        UI.ProgressBar(pool, canvas, tx + tw - 88, y - 17, 88, 4, f, c.redInk)
        local hot = pool:Hot({ L[e.def.name], WFD:HonourText(e.def, e.next) }, goTo("honour"))
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, 28)
        y = y - 32
    end
    y = y - 6

    -- regions still waiting, on the continent you know best
    local cont
    for _, e in ipairs(g.conts) do if e.id == mainCont then cont = e end end
    cont = cont or g.conts[1]
    if cont then
        local open = {}
        for _, z in ipairs(cont.zones) do if not z.visited then open[#open + 1] = z end end
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Unexplored regions"], cont.visited .. " / " .. cont.total)
        y = y - 22
        local colW = (tw - 12) / 2
        local rowsLeft = max(0, floor(((UI.PH - UI.BOTTOM) + y) / 24))
        for i = 1, min(#open, rowsLeft * 2) do
            local z = open[i]
            local x = tx + ((i - 1) % 2) * (colW + 12)
            local ry = y - floor((i - 1) / 2) * 24
            local q = pool:Text(12, c.redInk, UI.HEAD)
            q:SetText("?")
            q:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 2, ry - 1)
            local n = pool:Text(12, c.inkSoft, UI.FONT)
            n:SetText(z.name)
            n:SetWordWrap(false)
            n:SetWidth(colW - 16)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 14, ry - 2)
        end
        if #open == 0 then
            local n = pool:Text(12, c.inkSoft, UI.FONT)
            n:SetText(L["Every region of this continent is explored."])
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 2)
        end
    end
end)

------------------------------------------------------------------------
-- Atlas: a spread per continent. Left the continent with the whole journey, right the checklist.
------------------------------------------------------------------------
UI:RegisterSection({
    key = "atlas", label = "Atlas", icon = "atlas", order = 19, leftStart = true,
    build = function(book)
        local conts = WFD:AtlasState()
        if #conts == 0 then
            book:Add({ kind = "atlasmap", numbered = true, head = L["Atlas"], empty = true })
            return
        end
        table.sort(conts, function(a, b) return a.secs > b.secs end)
        for i, e in ipairs(conts) do
            if i > 1 then book:PadToLeft("atlas" .. e.id) end
            book:Add({ kind = "atlasmap", numbered = true, head = L["Atlas"], cont = e })
            local list = {}
            for j = 1, #e.zones, 2 do list[#list + 1] = { h = 34, pair = { e.zones[j], e.zones[j + 1] } } end
            paginate(book, "atlaslist", list, { head = L["Atlas"], cont = e })
        end
    end,
})

local function zoneInfo(z)
    if z.visited then
        return { z.name, format(L["Day %d"], z.day or 1) .. "  -  " .. format(L["%s spent here"], WFD:DurationText(z.secs)) }
    end
    return { z.name, L["Not yet explored"] }
end

UI:RegisterRenderer("atlasmap", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.empty then
        UI.PageTitle(pool, canvas, side, L["Atlas"], nil, -56)
        local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
        e:SetText(L["No map art available for this area."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, -200)
        return
    end
    local e = page.cont
    local y = UI.PageTitle(pool, canvas, side, e.name, format(L["%d of %d regions explored"], e.visited, e.total), -56)
    -- same mount as the region maps, so the pooled map frame fits
    local MAT = 9
    local mw = tw - MAT * 2
    local mh = floor(mw / 1.5)
    local shadow = pool:Rect({ 0, 0, 0 }, 0.25, "ARTWORK", 0)
    shadow:SetSize(tw, mh + MAT * 2)
    shadow:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 5)
    local mat = pool:Rect({ 0.08, 0.055, 0.035 }, 1, "ARTWORK", 1)
    mat:SetSize(tw, mh + MAT * 2)
    mat:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    local m = pool:Map(mw, mh)
    m:SetSize(mw, mh)
    m:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + MAT, y - MAT)
    m:SetFrameLevel(canvas:GetFrameLevel() + 2)
    local zones = {}
    for _, z in ipairs(e.zones) do
        zones[#zones + 1] = { id = z.id, name = z.name, visited = z.visited, info = zoneInfo(z) }
    end
    m:DrawContinent(e.id, zones)
    y = y - mh - MAT * 2 - 16

    -- how much of the continent is known
    local frac = e.visited / max(1, e.total)
    UI.ProgressBar(pool, canvas, tx, y, tw - 44, 6, frac, GREEN)
    local pc = pool:Text(13, c.ink, UI.HEAD, "RIGHT")
    pc:SetText(floor(frac * 100 + 0.5) .. "%")
    pc:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y + 4)
    y = y - 18

    -- key and a hint
    local keys = {
        { L["Route"], { 0.55, 0.08, 0.05, 1 }, true },
        { L["Explored"], { 0.90, 0.66, 0.16, 1 } },
        { L["Not yet explored"], { 0.58, 0.52, 0.44, 1 } },
    }
    local x = tx
    for _, k in ipairs(keys) do
        local d = k[3] and pool:Diamond(6, k[2]) or pool:Circle(9, k[2])
        d:SetPoint("CENTER", canvas, "TOPLEFT", x + 4, y - 6)
        local t = pool:Text(10, c.inkSoft, UI.FONT)
        t:SetText(k[1])
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 12, y - 1)
        x = x + 12 + t:GetStringWidth() + 16
    end
    local hint = pool:Text(9, c.inkFaint, UI.FONT)
    hint:SetText(L["Mouse wheel: zoom  -  drag: move  -  right click: reset"])
    hint:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 20)
end)

UI:RegisterRenderer("atlaslist", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local e = page.cont
    if page.first then
        UI.PageTitle(pool, canvas, side, L["Explorer's checklist"], e.name, -56)
    end
    local top = -UI.TOP
    local GAP_X = 12
    local colW = (tw - GAP_X) / 2
    local mapIcon = UI.Icon("map")
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        for k = 1, 2 do
            local z = r.pair[k]
            if z then
                local x = tx + (k - 1) * (colW + GAP_X)
                pool:Plaque(x + 13, y - 15, 22, z.visited and mapIcon or QUESTION, z.visited and GOLD or LOCKED, z.visited)
                local n = pool:Text(12, z.visited and c.ink or c.inkFaint, UI.FONT)
                n:SetText(z.name)
                n:SetWordWrap(false)
                n:SetWidth(colW - 32)
                n:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 30, y - 3)
                local s = pool:Text(9, z.visited and c.redInk or c.inkFaint, UI.FONT)
                s:SetText(z.visited and (format(L["Day %d"], z.day or 1) .. "  -  " .. WFD:DurationText(z.secs)) or L["Not yet explored"])
                s:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 30, y - 18)
                local mp = z.visited and UI.book.mapPage and UI.book.mapPage[z.id]
                local lines = zoneInfo(z)
                if mp then lines[#lines + 1] = L["Click for the map of this region."] end
                local hot = pool:Hot(lines, mp and function() UI:GoToPage(mp) end)
                hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y + 1)
                hot:SetSize(colW, r.h - 4)
            end
        end
    end
end)
