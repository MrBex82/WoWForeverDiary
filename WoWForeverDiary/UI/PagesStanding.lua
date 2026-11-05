-- Mounts and reputation: two small parts of the book, both filled from what the game shows while playing.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local format = string.format

local function line(pool, canvas, x, y, w, text, size, col, font)
    local t = pool:Text(size, col, font or UI.FONT)
    t:SetText(text or "")
    t:SetWordWrap(false)
    if w then t:SetWidth(w) end
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    return t
end

local function rightText(pool, canvas, x, y, text, size, col, font)
    local t = pool:Text(size, col, font or UI.FONT, "RIGHT")
    t:SetText(text or "")
    t:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x, y)
    return t
end

local function emptyNote(pool, canvas, tx, tw, y, text)
    local e = pool:Text(12, c.inkFaint, UI.FONT, "CENTER")
    e:SetText(text)
    e:SetWidth(tw)
    e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
end

------------------------------------------------------------------------
-- Mounts
------------------------------------------------------------------------
UI:RegisterSection({
    key = "stable", label = "Mounts", icon = "mount", order = 46,
    build = function(book)
        local list = {}
        for _, m in ipairs(WFD:Mounts()) do list[#list + 1] = { h = 44, m = m } end
        book:AddRows("stable", list, { head = L["Mounts"], count = #list })
    end,
})

UI:RegisterRenderer("stable", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then
        UI.PageTitle(pool, canvas, side, L["Mounts"], WFD:Count("%d mounts", page.count), -56)
        if #page.rows == 0 then
            emptyNote(pool, canvas, tx, tw, -UI.TITLE_H - 10, L["The first ride is still to come."])
            return
        end
    end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        local e = r.m.e
        pool:Plaque(tx + 18, y - 20, 32, e.icon or UI.Icon("mount"), { 0.86, 0.62, 0.18, 1 }, true)
        line(pool, canvas, tx + 42, y - 3, tw - 42 - 90, e.name or "?", 14, c.ink, UI.HEAD)
        local where = e.zone and (e.zone .. "  -  ") or ""
        line(pool, canvas, tx + 42, y - 22, tw - 42 - 90, where .. WFD:Count("%d rides", e.rides or 0), 10, c.inkSoft)
        rightText(pool, canvas, tx + tw, y - 4, format(L["Day %d"], e.day or 1), 13, c.redInk, UI.HEAD)
        if e.first then rightText(pool, canvas, tx + tw, y - 22, date(WFD.loc.date, e.first), 9, c.inkFaint) end
        local hot = pool:Hot({ e.name or "?", format(L["First ridden on day %d"], e.day or 1), L["Click to read this day."] }, UI.DayGo(e.day))
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, r.h - 4)
    end
end)

------------------------------------------------------------------------
-- Reputation
------------------------------------------------------------------------
UI:RegisterSection({
    key = "standing", label = "Reputation", icon = "banner", order = 47,
    build = function(book)
        local list = {}
        for _, f in ipairs(WFD:Factions()) do list[#list + 1] = { h = 44, f = f } end
        book:AddRows("standing", list, { head = L["Reputation"], count = #list })
    end,
})

UI:RegisterRenderer("standing", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then
        UI.PageTitle(pool, canvas, side, L["Reputation"], WFD:Count("%d factions", page.count), -56)
        if #page.rows == 0 then
            emptyNote(pool, canvas, tx, tw, -UI.TITLE_H - 10, L["Fills as soon as there is something to tell."])
            return
        end
    end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        local e = r.f.e
        line(pool, canvas, tx + 4, y - 3, tw - 100, r.f.name, 14, c.ink, UI.HEAD)
        rightText(pool, canvas, tx + tw, y - 4, WFD:StandingName(e.st), 13, c.redInk, UI.HEAD)
        -- the steps seen so far, in order, each with its day
        local steps = {}
        for st = 1, 8 do
            local t = e.reached and e.reached[st]
            if t then steps[#steps + 1] = WFD:StandingName(st) .. " " .. format(L["Day %d"], WFD:DayIndex(t)) end
        end
        local text = #steps > 0 and table.concat(steps, "  -  ")
            or format(L["Seen on day %d as %s"], e.day or 1, WFD:StandingName(e.st0 or e.st))
        line(pool, canvas, tx + 4, y - 22, tw - 8, text, 10, c.inkSoft)
        local hot = pool:Hot({ r.f.name, WFD:StandingName(e.st), text })
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, r.h - 4)
    end
end)
