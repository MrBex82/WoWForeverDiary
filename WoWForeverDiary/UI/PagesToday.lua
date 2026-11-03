-- "Today": the spread the book opens at - the day so far, what is new since the book was last read,
-- and the next goals. And the overview page that opens each group of parts.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local min, max, format = math.min, math.max, string.format

local LOCKED = { 0.46, 0.39, 0.30, 1 }

------------------------------------------------------------------------
-- Parts with nothing in them yet: dimmed in the contents and on the overview pages
------------------------------------------------------------------------
local EMPTY = {
    milestones = function(C) return #(C.events or {}) == 0 end,
    firsts = function(C) return next(C.firsts or {}) == nil end,
    gallery = function(C)
        for _, ev in ipairs(C.events or {}) do if ev.gear and next(ev.gear) then return false end end
        return true
    end,
    runs = function(C) return #(C.runs or {}) == 0 end,
    gathering = function(C) return next(C.gather or {}) == nil end,
    bestiary = function(C) return next(C.mobs or {}) == nil and next(C.sighted or {}) == nil end,
    nemesis = function(C) return next(C.nemesis or {}) == nil end,
    fates = function() return #WFD:Fates() == 0 end,
    fishbook = function(C) return next(C.catch or {}) == nil end,
    companions = function(C) return next(C.companions or {}) == nil and next(C.traders or {}) == nil end,
    capsule = function(C) return #(C.capsules or {}) == 0 end,
}
function UI.IsEmptyPart(key)
    local fn, C = EMPTY[key], WFD.C
    if not fn or not C then return false end
    local ok, v = pcall(fn, C)
    return ok and v == true
end

-- where the book opens the first time in a session
function UI.TodayStart(book)
    return book.sectionStart.today or UI.PlacePage(book)
end

------------------------------------------------------------------------
-- Today
------------------------------------------------------------------------
UI:RegisterSection({
    key = "today", label = "Today", icon = "time", group = "front", order = 0.5,
    build = function(book)
        book.collection = book.collection or (UI.CollectionState and UI.CollectionState())
        book:Add({ kind = "today", numbered = true })
        book:Add({ kind = "nextgoals", numbered = true })
    end,
})

-- returns where the next block starts
local function memoryBlock(pool, canvas, tx, tw, y)
    local jubilees = WFD.Jubilees and WFD:Jubilees() or {}
    local mem = WFD.OnThisDay and WFD:OnThisDay()
    if #jubilees == 0 and not mem then return y end
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["A memory"], mem and WFD:DateStr(mem.idx) or nil)
    y = y - 22
    -- one anniversary and three lines of memory at most: the page still has to show what is new
    for i = 1, min(1, #jubilees) do
        local ic = pool:Icon(UI.Icon("honour"), 18)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 1, y)
        local t = pool:Text(13, c.redInk, UI.FONT)
        t:SetWidth(tw - 26)
        t:SetText(jubilees[i].text)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 26, y - 2)
        y = y - max(22, t:GetStringHeight() + 8)
    end
    if mem then
        local t = pool:Text(13, c.ink, UI.FONT)
        t:SetSpacing(3)
        t:SetWidth(tw)
        if t.SetMaxLines then t:SetMaxLines(3) end
        t:SetText(mem.text)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - min(t:GetStringHeight(), 3 * (UI.FS(13) + 3) + 4) - 8     -- three lines at the size chosen
        local dp = UI.book and UI.book.dayPage[mem.idx]
        if dp then
            local link = pool:Link(format(L["Read that day (day %d)"], mem.idx) .. "  >", function() UI:GoToPage(dp) end, 13)
            link:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            y = y - 20
        end
    end
    return y - 12
end

UI:RegisterRenderer("today", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local day = WFD:NumDays()
    local y = UI.PageTitle(pool, canvas, side, L["Today"], WFD:LongDate(day), -56)

    -- the day in four figures
    local d = C.days[day] or {}
    local net = WFD:Sum(d.income or {}) - WFD:Sum(d.spend or {})
    local th = UI.Tiles(pool, canvas, tx, y, tw, {
        { d.killTotal or 0, L["Kills"], c.ink },
        { #(d.qd or {}), L["Quests"], c.ink },
        { WFD:Dec((d.steps or 0) * 0.9144 / 1000), L["Kilometres"], c.ink },
        { (net < 0 and "-" or "") .. UI.CoinIcons(net, 12), L["Gold"], net < 0 and c.bad or c.ink },
    })
    y = y - th - 14

    -- the beginning of today's entry, and the way to all of it
    local story = WFD:Narrate(day) or ""
    local paras = {}
    for p in (story .. "\n\n"):gmatch("(.-)\n\n") do
        if p ~= "" and #paras < 2 then paras[#paras + 1] = p end
    end
    local t = pool:Text(13, c.ink, UI.FONT)
    t:SetSpacing(3)
    t:SetWidth(tw)
    if t.SetMaxLines then t:SetMaxLines(6) end
    t:SetText(table.concat(paras, " "))
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    y = y - min(t:GetStringHeight(), 6 * (UI.FS(13) + 3) + 4) - 10     -- six lines at the size chosen
    local dp = UI.book and UI.book.dayPage[day]
    if dp then
        local link = pool:Link(L["To today's entry"] .. "  >", function() UI:GoToPage(dp) end, 13)
        link:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    end
    -- where reading stopped last time (the start pages do not count)
    local rp, rlabel = UI.ResumePlace(UI.book)
    if rp then
        y = y - 20
        local cont = pool:Link(format(L["Continue reading: %s, p. %d"], rlabel, UI.PageNumber(rp)) .. "  >",
            function() UI:GoToPage(rp) end, 13)
        cont:SetWordWrap(false)
        cont:SetWidth(tw)
        cont:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    end
    y = y - 30

    -- this day in an earlier year, and the anniversaries that are due
    if WFD.S.memoryPage ~= false then y = memoryBlock(pool, canvas, tx, tw, y) end

    -- what came into the book since it was last put away
    -- (below a long memory there may be no room left for it)
    if y < -(UI.PH - UI.BOTTOM - 40) then return end
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["New since you last read"])
    y = y - 22
    local counts = UI.NewCounts and UI.NewCounts() or {}
    local shown = 0
    for _, sec in ipairs(UI.sections) do
        local n = counts[sec.key]
        local st = UI.book and UI.book.sectionStart[sec.key]
        if n and n > 0 and st and y > -(UI.PH - UI.BOTTOM - 20) then
            local ic = pool:Icon(UI.Icon(sec.icon), 18)
            ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 1, y)
            local name = pool:Text(13, c.ink, UI.FONT)
            name:SetText(L[sec.label])
            name:SetWordWrap(false)
            name:SetWidth(tw - 90)
            name:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 26, y - 2)
            local cnt = pool:Text(13, c.redInk, UI.HEAD, "RIGHT")
            cnt:SetText("+" .. n)
            cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 1)
            local hot = pool:Hot({ L[sec.label], format(L["%d new since you last read"], n) }, function() UI:GoToPage(st) end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 2)
            hot:SetSize(tw + 4, 22)
            y = y - 24
            shown = shown + 1
        end
    end
    if shown == 0 then
        local e = pool:Text(12, c.inkSoft, UI.FONT)
        e:SetWidth(tw)
        e:SetText(L["Nothing new since you last read."])
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 2)
    end
end)

------------------------------------------------------------------------
-- The overview page of a group: one line for each of its parts
------------------------------------------------------------------------
local GROUP_ORDER = { goals = 4.5, chronicle = 9.5, world = 18.5, hunt = 29.5, people = 39.5, back = 85.5 }
for _, g in ipairs(UI.GROUPS) do
    if g.label and GROUP_ORDER[g.key] then
        UI:RegisterSection({
            key = "grp_" .. g.key, label = g.label, icon = g.icon, group = g.key, order = GROUP_ORDER[g.key],
            index = true, leftStart = true,
            build = function(book) book:Add({ kind = "groupindex", numbered = true, group = g.key }) end,
        })
    end
end

UI:RegisterRenderer("groupindex", function(pool, page, side, canvas)
    local g = UI.GROUP[page.group]
    if not g then return end
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L[g.label], nil, -56)
    local bright = { math.min(1, g.col[1] * 1.7 + 0.1), math.min(1, g.col[2] * 1.7 + 0.1), math.min(1, g.col[3] * 1.7 + 0.1), 1 }
    local counts = UI.NewCounts and UI.NewCounts() or {}
    local ROW = 58
    for _, sec in ipairs(UI.sections) do
        local st = UI.book and UI.book.sectionStart[sec.key]
        if sec.group == g.key and not sec.index and st then
            local empty = UI.IsEmptyPart(sec.key)
            pool:Plaque(tx + 20, y - 22, 32, UI.Icon(sec.icon), empty and LOCKED or bright, not empty)
            local name = pool:Text(16, empty and c.inkSoft or c.ink, UI.HEAD)
            name:SetText(L[sec.label])
            name:SetWordWrap(false)
            name:SetWidth(tw - 46 - 70)
            name:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 46, y - 4)
            local sub = pool:Text(12, c.inkSoft, UI.FONT)
            sub:SetText(empty and L["Fills as soon as there is something to tell."] or (sec.sub and L[sec.sub] or ""))
            sub:SetWidth(tw - 46)
            if sub.SetMaxLines then sub:SetMaxLines(2) end      -- a long line takes a second one
            sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 46, y - 26)
            local pr = pool:Text(12, c.inkFaint, UI.FONT, "RIGHT")
            pr:SetText(format(L["p. %d"], UI.PageNumber(st)))
            pr:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 6)
            local n = counts[sec.key]
            if n and n > 0 then
                local nw = pool:Text(13, c.redInk, UI.HEAD, "RIGHT")
                nw:SetText("+" .. n)
                nw:SetPoint("TOPRIGHT", pr, "TOPLEFT", -10, 1)
            end
            local tip = { L[sec.label] }
            if sec.sub then tip[#tip + 1] = L[sec.sub] end
            if n and n > 0 then tip[#tip + 1] = format(L["%d new since you last read"], n) end
            tip[#tip + 1] = L["Click to open this part of the book."]
            local hot = pool:Hot(tip, function() UI:GoToPage(st) end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 2, y + 2)
            hot:SetSize(tw + 4, ROW - 6)
            y = y - ROW
        end
    end
end)
