-- The library: a bookshelf that fills slowly with every book, note and plaque read in the world.
-- The left page is the shelf (a spine for each text, empty places for the ones still to be found), the right
-- page the reading desk: what was added last, and what is kept for later. A click on a spine opens the text
-- on a card (Cards.lua).
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, ceil, format = math.floor, math.max, math.min, math.ceil, string.format

local SPINE_W, GAP = 17, 3
local ROW_H = 92                   -- a spine up to 76 high, the plank, some air
local PLANK_H = 7
local TOP_ROWS = 3                 -- on the page with the title; the next pages have four
local LEATHER = {
    { 0.45, 0.18, 0.12 }, { 0.16, 0.30, 0.22 }, { 0.20, 0.24, 0.42 }, { 0.42, 0.30, 0.12 }, { 0.34, 0.14, 0.30 },
    { 0.50, 0.38, 0.20 },
}
local NOTE_COL = { 0.78, 0.68, 0.46 }
local STONE_COL = { 0.46, 0.46, 0.48 }

local function perRow() return floor((UI.TextW() + GAP) / (SPINE_W + GAP)) end

-- how a text looks on the shelf: colour and height are the same every time
local function look(id, b)
    local h = 0
    for i = 1, #id do h = (h * 31 + id:byte(i)) % 9973 end
    local pages = 0
    for _ in pairs(b.pages or {}) do pages = pages + 1 end
    local col
    if b.kind == "plaque" then col = STONE_COL
    elseif b.kind == "note" then col = NOTE_COL
    else col = LEATHER[h % #LEATHER + 1] end
    local height = (b.kind == "note" and 44 or 52) + (floor(h / 7) % 16) + min(pages, 4) * 2
    return col, height
end

local function kindWord(b)
    if b.kind == "plaque" then return L["Plaque"] end
    if b.kind == "note" then return L["Note"] end
    return L["Book"]
end

UI:RegisterSection({
    key = "library", label = "Library", icon = "journal", order = 85.7, leftStart = true,
    build = function(book)
        local n = #WFD:Library()
        local per = perRow()
        local first = per * TOP_ROWS
        local more = per * 4
        local pages = 1
        if n > first then pages = 1 + ceil((n - first) / more) end
        -- the shelf, the reading desk beside it, then more shelves if there are more books than places
        local from = 1
        for i = 1, pages do
            local cap = (i == 1) and first or more
            book:Add({ kind = "shelf", numbered = true, first = (i == 1), from = from, to = from + cap - 1, rows = (i == 1) and TOP_ROWS or 4 })
            from = from + cap
            if i == 1 then book:Add({ kind = "libdesk", numbered = true }) end
        end
    end,
})

local function plank(pool, canvas, x, y, w)
    local wood = pool:Rect({ 0.30, 0.19, 0.09 }, 1)
    wood:SetSize(w, PLANK_H)
    wood:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    local lit = pool:Rect({ 0.55, 0.38, 0.20 }, 0.9, "ARTWORK", 1)
    lit:SetSize(w, 1)
    lit:SetPoint("TOPLEFT", wood, "TOPLEFT")
    local dark = pool:Rect({ 0, 0, 0 }, 0.35, "ARTWORK", 1)
    dark:SetSize(w, 2)
    dark:SetPoint("BOTTOMLEFT", wood, "BOTTOMLEFT")
end

UI:RegisterRenderer("shelf", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local list = WFD:Library()
    local y = -UI.TOP
    if page.first then
        y = UI.PageTitle(pool, canvas, side, L["Library"], WFD:Count("%d books on the shelf", #list), -56)
    end
    local per = perRow()
    local x0 = tx + floor((tw - (per * (SPINE_W + GAP) - GAP)) / 2)
    local slot = page.from
    for row = 1, page.rows do
        local top = y - (row - 1) * ROW_H
        local base = top - ROW_H + 12           -- where the plank starts
        plank(pool, canvas, tx, base, tw)
        for k = 1, per do
            local x = x0 + (k - 1) * (SPINE_W + GAP)
            local e = list[slot]
            if e then
                local col, height = look(e.id, e.b)
                local sp = pool:Rect(col, 1)
                sp:SetSize(SPINE_W, height)
                sp:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", x, base)
                local light = pool:Rect({ 1, 1, 1 }, 0.14, "ARTWORK", 1)
                light:SetSize(3, height)
                light:SetPoint("BOTTOMLEFT", sp, "BOTTOMLEFT")
                local shade = pool:Rect({ 0, 0, 0 }, 0.30, "ARTWORK", 1)
                shade:SetSize(3, height)
                shade:SetPoint("BOTTOMRIGHT", sp, "BOTTOMRIGHT")
                for _, dy in ipairs({ height - 7, 5 }) do
                    local band = pool:Rect({ 0.86, 0.68, 0.30 }, 0.65, "ARTWORK", 2)
                    band:SetSize(SPINE_W, 2)
                    band:SetPoint("BOTTOMLEFT", sp, "BOTTOMLEFT", 0, dy)
                end
                local init = (e.b.title or "?"):match("^[%z\1-\127\194-\244][\128-\191]*") or "?"
                local t = pool:Text(11, e.b.kind == "note" and { 0.25, 0.16, 0.08 } or { 0.96, 0.88, 0.68 }, UI.HEAD, "CENTER")
                t:SetText(init:upper())
                t:SetWidth(SPINE_W)
                t:SetPoint("CENTER", sp, "CENTER", 0, 2)
                -- a ribbon for a text kept for later
                if e.b.later then
                    local rb = pool:Rect(c.redInk, 1, "ARTWORK", 3)
                    rb:SetSize(5, 12)
                    rb:SetPoint("BOTTOM", sp, "TOP", 0, -2)
                end
                local tip = { e.b.title or "?", kindWord(e.b) .. (e.b.zone and ("  -  " .. e.b.zone) or "") }
                if not WFD:BookComplete(e.b) then tip[#tip + 1] = L["Pages are missing: read the rest to complete this book."] end
                local hot = pool:Hot(tip, function() UI:ShowCard("book", e.id) end)
                hot:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", x, base)
                hot:SetSize(SPINE_W, height)
            else
                -- a place still empty
                local gap = pool:Rect({ 0.95, 0.85, 0.65 }, 0.05)
                gap:SetSize(SPINE_W, 56)
                gap:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", x, base)
            end
            slot = slot + 1
        end
    end
end)

-- one line of a list on the reading desk: a click opens the text
local function deskRow(pool, canvas, tx, tw, y, id, b)
    local col = look(id, b)
    local mark = pool:Rect(col, 1)
    mark:SetSize(5, 26)
    mark:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 2, y)
    local t = pool:Text(13, c.ink, UI.FONT)
    t:SetText(b.title or "?")
    t:SetWordWrap(false)
    t:SetWidth(tw - 20)
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 14, y - 1)
    local s = pool:Text(11, c.inkSoft, UI.FONT)
    s:SetText(kindWord(b) .. (b.zone and ("  -  " .. b.zone) or "") .. (b.t and ("  -  " .. date(WFD.loc.date, b.t)) or ""))
    s:SetWordWrap(false)
    s:SetWidth(tw - 20)
    s:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 14, y - 15)
    local hot = pool:Hot({ b.title or "?" }, function() UI:ShowCard("book", id) end)
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
    hot:SetSize(tw, 30)
    return y - 34
end

UI:RegisterRenderer("libdesk", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local list = WFD:Library()
    local y = UI.PageTitle(pool, canvas, side, L["Reading desk"], nil, -56)
    if #list == 0 then
        local e = pool:Text(13, c.inkSoft, UI.FONT, "CENTER")
        e:SetText(L["The shelf is empty. Every book, note and plaque you read will stand here."])
        e:SetWidth(tw - 20)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 10, y - 20)
        return
    end
    -- the latest first
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Recently added"])
    y = y - 22
    for i = #list, max(1, #list - 4), -1 do
        y = deskRow(pool, canvas, tx, tw, y, list[i].id, list[i].b)
    end
    y = y - 14
    -- what was kept for later
    local later = {}
    for _, e in ipairs(list) do if e.b.later then later[#later + 1] = e end end
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["To read later"], tostring(#later))
    y = y - 22
    if #later == 0 then
        local e = pool:Text(12, c.inkFaint, UI.FONT)
        e:SetText(L["Nothing is kept for later."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 2)
        return
    end
    for i = 1, #later do
        if y - 34 < -(UI.PH - UI.BOTTOM) then break end
        y = deskRow(pool, canvas, tx, tw, y, later[i].id, later[i].b)
    end
end)
