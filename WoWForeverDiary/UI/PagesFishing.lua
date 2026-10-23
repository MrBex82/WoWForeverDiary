-- The angler's log: a collector's album of everything the line brought up, by water, with the waters
-- and the tackle on a last page. Built like the bestiary, but its cards are drawn straight on the page.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local max, min, ceil, format = math.max, math.min, math.ceil, string.format

local CARD_W, CARD_H, GAP_X, GAP_Y = 108, 118, 12, 10
local PER_PAGE = 9

local TIERS = {           -- ranks of the log, by the number of different catches
    { 5, "Bronze", { 0.70, 0.42, 0.20, 1 } }, { 15, "Silver", { 0.70, 0.72, 0.76, 1 } },
    { 30, "Gold", { 0.92, 0.72, 0.22, 1 } }, { 60, "Mithril", { 0.45, 0.70, 0.85, 1 } },
    { 100, "Legend", { 0.62, 0.22, 0.70, 1 } },
}
UI.FISH_TIERS = TIERS

local KINDS = {
    fish     = { label = "Fish", col = { 0.30, 0.62, 0.80, 1 } },
    junk     = { label = "Junk", col = { 0.58, 0.56, 0.52, 1 } },
    treasure = { label = "Treasure", col = { 0.92, 0.72, 0.22, 1 } },
    other    = { label = "Odds and ends", col = { 0.70, 0.55, 0.38, 1 } },
}
UI.FISH_KINDS = KINDS

-- quality colours that read on the dark card
local QCOL = {
    [0] = { 0.62, 0.62, 0.62, 1 }, [1] = { 0.95, 0.92, 0.84, 1 }, [2] = { 0.40, 0.90, 0.30, 1 },
    [3] = { 0.45, 0.66, 1.00, 1 }, [4] = { 0.75, 0.45, 0.95, 1 }, [5] = { 1.00, 0.60, 0.15, 1 },
}
UI.FISH_QCOL = QCOL

local TACKLE_ICONS = {
    rod  = { "INV_Fishingpole_02", "INV_Fishingpole_01" },
    lure = { "INV_Misc_Food_15", "INV_Misc_Bait_01", "INV_Misc_Gem_Pearl_03" },
    gear = { "INV_Misc_Cape_06", "INV_Misc_Bag_08" },
}
local TACKLE_LABEL = { rod = "Fishing pole", lure = "Lure", gear = "Fishing gear" }

local function kindOf(e) return KINDS[e.kind or "other"] or KINDS.other end

-- when the game cannot tell the icon: one that suits the kind, never a fish for a chest
local KIND_ICONS = {
    fish     = { "INV_Misc_Fish_02", "INV_Misc_Fish_03" },
    junk     = { "INV_Misc_Bag_09", "INV_Misc_Rune_01" },
    treasure = { "INV_Box_01", "INV_Misc_Gem_Pearl_05" },
    other    = { "INV_Misc_Bag_08", "INV_Misc_Note_01" },
}

-- the item's own picture: kept at the catch, else asked from the game by the item number (no link needed)
local function instantIcon(id)
    local fn = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
    if fn and id then
        local ok, _, _, _, _, icon = pcall(fn, id)
        if ok and icon then return icon end
    end
end

local function iconOf(e, id)
    if e.icon then return e.icon end
    local inst = instantIcon(id)
    if inst then return inst end
    local path = e.link and WFD:ItemIcon(e.link)
    if path then return path end
    return UI.IconPath(KIND_ICONS[e.kind or "other"] or KIND_ICONS.other, "loot")
end
UI.FishIcon = iconOf

-- collection order: first catch first, numbered like an album; each catch lives on the water that gave most
local function collection()
    local arr = {}
    for id, e in pairs(WFD.C.catch or {}) do
        local best, bn = nil, -1
        for map, n in pairs(e.zones or {}) do
            if n > bn then best, bn = map, n end
        end
        arr[#arr + 1] = { id = id, e = e, map = best, zone = best and WFD:MapName(best) or "?" }
    end
    table.sort(arr, function(a, b)
        if (a.e.first or 0) ~= (b.e.first or 0) then return (a.e.first or 0) < (b.e.first or 0) end
        return (a.e.name or "") < (b.e.name or "")
    end)
    for i, a in ipairs(arr) do a.num = i end
    return arr
end

UI:RegisterSection({
    key = "fishbook", label = "Angler's log", icon = "fish", order = 33,
    build = function(book)
        local arr = collection()
        local zones, byZone = {}, {}
        for _, a in ipairs(arr) do
            if not byZone[a.zone] then
                byZone[a.zone] = {}
                zones[#zones + 1] = a.zone
            end
            table.insert(byZone[a.zone], a)
        end
        -- what the other characters landed: covered cards after your own, in waters only they know too
        local hints = WFD.CatchHints and WFD:CatchHints() or {}
        local own = {}
        for _, z in ipairs(zones) do own[z] = #byZone[z] end
        local extra = {}
        for z, list in pairs(hints) do
            if not byZone[z] then
                byZone[z] = {}
                extra[#extra + 1] = z
            end
        end
        table.sort(extra)
        for _, z in ipairs(extra) do zones[#zones + 1] = z end
        local head = L["Angler's log"]
        local intro = book:Add({ kind = "fishintro", numbered = true, head = head, zoneIndex = {} })
        for _, z in ipairs(zones) do
            local list = {}
            for _, a in ipairs(byZone[z]) do list[#list + 1] = a end
            local hidden = hints[z] and #hints[z] or 0
            for _, h in ipairs(hints[z] or {}) do list[#list + 1] = h end
            local pages = ceil(#list / PER_PAGE)
            local first
            for p = 1, pages do
                local cards = {}
                for i = (p - 1) * PER_PAGE + 1, min(#list, p * PER_PAGE) do cards[#cards + 1] = list[i] end
                local pg = book:Add({ kind = "fishalbum", numbered = true, head = head, zone = z, cards = cards,
                    part = (pages > 1) and p or nil, count = own[z] or 0, hidden = hidden })
                first = first or pg.index
            end
            intro.zoneIndex[#intro.zoneIndex + 1] = { zone = z, page = first, count = own[z] or 0, hidden = hidden }
        end
        local C = WFD.C
        if next(C.catchZone or {}) or next(C.tackle or {}) then
            book.fishWaters = book:Add({ kind = "fishwaters", numbered = true, head = head }).index
        end
    end,
})

------------------------------------------------------------------------
-- One card, drawn on the page
------------------------------------------------------------------------
-- a covered card: a catch another character made - only the kind and who knows it
local function drawHint(pool, canvas, x, y, a)
    local h = a.h
    local kind = KINDS[h.kind or "other"] or KINDS.other
    local sh = pool:Rect({ 0, 0, 0 }, 0.20, "BACKGROUND", -3)
    sh:SetSize(CARD_W, CARD_H)
    sh:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 3, y - 4)
    local rim = pool:Rect(kind.col, 0.55, "BACKGROUND", -2)
    rim:SetSize(CARD_W, CARD_H)
    rim:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    local body = pool:Grad("VERTICAL", { 0.06, 0.04, 0.03, 0.9 }, { 0.16, 0.11, 0.07, 0.9 }, "BACKGROUND", -1)
    body:SetPoint("TOPLEFT", rim, "TOPLEFT", 2, -2)
    body:SetPoint("BOTTOMRIGHT", rim, "BOTTOMRIGHT", -2, 2)
    local tag = pool:Text(8, kind.col, UI.HEAD, "CENTER")
    tag:SetText(L[kind.label]:upper())
    tag:SetWidth(CARD_W)
    tag:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y - 7)
    local q = pool:Text(40, { 0.55, 0.45, 0.30, 0.7 }, UI.HEAD, "CENTER")
    q:SetText("?")
    q:SetWidth(CARD_W)
    q:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y - 36)
    local who = pool:Text(9, { 0.88, 0.76, 0.54, 1 }, UI.FONT, "CENTER")
    who:SetText(h.who and format(L["Known to %s"], h.who) or L["not yet found"])
    who:SetWidth(CARD_W - 12)
    who:SetHeight(24)
    if who.SetMaxLines then who:SetMaxLines(2) end
    who:SetJustifyV("MIDDLE")
    who:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 6, y - CARD_H + 30)
    local hot = pool:Hot({ L["Not yet discovered"], a.zone, h.who and format(L["Known to %s"], h.who) or "" })
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    hot:SetSize(CARD_W, CARD_H)
end

local function drawCard(pool, canvas, x, y, a)
    if a.hint then return drawHint(pool, canvas, x, y, a) end
    local e = a.e
    local kind = kindOf(e)
    local qc = QCOL[min(5, e.q or 1)] or QCOL[1]
    -- shadow, body, rim
    local sh = pool:Rect({ 0, 0, 0 }, 0.30, "BACKGROUND", -3)
    sh:SetSize(CARD_W, CARD_H)
    sh:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 3, y - 4)
    local rim = pool:Rect(kind.col, 1, "BACKGROUND", -2)
    rim:SetSize(CARD_W, CARD_H)
    rim:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    local body = pool:Grad("VERTICAL", { 0.08, 0.06, 0.04, 1 }, { 0.24, 0.19, 0.13, 1 }, "BACKGROUND", -1)
    body:SetPoint("TOPLEFT", rim, "TOPLEFT", 2, -2)
    body:SetPoint("BOTTOMRIGHT", rim, "BOTTOMRIGHT", -2, 2)
    -- number and kind
    local num = pool:Text(9, { 1, 0.92, 0.75, 1 }, UI.FONT, "LEFT")
    num:SetText(format("#%03d", a.num))
    num:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 7, y - 6)
    local tag = pool:Text(8, kind.col, UI.HEAD, "RIGHT")
    tag:SetText(L[kind.label]:upper())
    tag:SetWordWrap(false)
    -- a long kind in a long language: first in small letters, then without the number
    local room = CARD_W - 14 - num:GetStringWidth() - 6
    if tag:GetStringWidth() > room then tag:SetText(L[kind.label]) end
    if tag:GetStringWidth() > room then
        num:SetText("")
        room = CARD_W - 14
    end
    tag:SetWidth(room)
    tag:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x + CARD_W - 7, y - 6)
    -- the picture
    local pl = pool:Plaque(x + CARD_W / 2, y - 48, 46, iconOf(e, a.id), qc, true, UI.ShortCount(e.n or 0))
    -- the name, two lines at most
    local nm = pool:Text(10, qc, UI.FONT, "CENTER")
    nm:SetText(e.name or "?")
    nm:SetWidth(CARD_W - 12)
    nm:SetHeight(26)
    nm:SetWordWrap(true)
    if nm.SetMaxLines then nm:SetMaxLines(2) end
    nm:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 6, y - 84)
    nm:SetJustifyV("MIDDLE")
    local isNew = e.day and e.day == WFD:NumDays()
    if isNew then
        local nw = pool:Text(9, { 1, 0.95, 0.6, 1 }, UI.HEAD, "CENTER")
        nw:SetText(L["NEW"])
        nw:SetPoint("CENTER", pl, "TOPRIGHT", -2, -2)
    end
    local hot = pool:Hot(nil, function() UI:ShowCard("catch", a.id) end, e.link)
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    hot:SetSize(CARD_W, CARD_H)
end

UI:RegisterRenderer("fishalbum", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local top = -UI.TOP
    UI.AlbumHead(pool, canvas, tx, tw, page)
    local gridX = tx + (tw - (CARD_W * 3 + GAP_X * 2)) / 2
    for i, a in ipairs(page.cards) do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        drawCard(pool, canvas, gridX + col * (CARD_W + GAP_X), top - 24 - row * (CARD_H + GAP_Y), a)
    end
end)

------------------------------------------------------------------------
-- The first page: the rank, the numbers, the waters
------------------------------------------------------------------------
UI:RegisterRenderer("fishintro", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Angler's log"], L["A collector's album of everything the line brought up"], -56)
    local sum = WFD:CatchSummary()
    local species = sum.species

    local n = #TIERS
    local cur, nextT = 0, nil
    for i, t in ipairs(TIERS) do
        if species >= t[1] then cur = i elseif not nextT then nextT = i end
    end
    local big = pool:Text(44, c.ink, UI.HEAD)
    big:SetText(tostring(species))
    local goal = pool:Text(18, c.inkFaint, UI.HEAD)
    goal:SetText(nextT and (" / " .. TIERS[nextT][1]) or "")
    local bw, gw = big:GetStringWidth(), goal:GetStringWidth()
    big:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + (tw - bw - gw) / 2, y + 2)
    goal:SetPoint("BOTTOMLEFT", big, "BOTTOMRIGHT", 0, 6)
    local bl = pool:Text(10, c.inkSoft, UI.FONT, "CENTER")
    bl:SetText(UI.Upper(format(L["catches collected  -  %d things landed"], sum.total)))
    bl:SetWidth(tw)
    bl:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 46)
    y = y - 78

    local step = tw / n
    local MY = y - 24
    local function mx(i) return tx + step * (i - 0.5) end
    local track = pool:Rect(c.inkFaint, 0.35, "BORDER", 0)
    track:SetSize(mx(n) - mx(1), 2)
    track:SetPoint("LEFT", canvas, "TOPLEFT", mx(1), MY)
    if cur >= 1 then
        local fillX = mx(n)
        if cur < n then
            local a, b = TIERS[cur][1], TIERS[cur + 1][1]
            fillX = mx(cur) + step * (species - a) / (b - a)
        end
        local fill = pool:Rect(c.redInk, 0.85, "BORDER", 1)
        fill:SetSize(max(1, fillX - mx(1)), 2)
        fill:SetPoint("LEFT", canvas, "TOPLEFT", mx(1), MY)
    end
    for i, t in ipairs(TIERS) do
        local reached = species >= t[1]
        local x = mx(i)
        local plaque = pool:Plaque(x, MY, (i == cur) and 38 or 32, UI.IconPath(UI.METAL_ICONS[i], "loot"), t[3], reached, tostring(t[1]))
        local lab = pool:Text(9, i == cur and c.redInk or (reached and c.ink or c.inkFaint), UI.FONT, "CENTER")
        lab:SetText(L[t[2]]:upper())
        lab:SetPoint("TOP", canvas, "TOPLEFT", x, MY - 27)
        local hot = pool:Hot({ L[t[2]], format(L["Land %d different catches."], t[1]),
            reached and L["Reached!"] or format(L["%d still missing."], t[1] - species) })
        hot:SetPoint("CENTER", plaque, "CENTER", 0, -10)
        hot:SetSize(step - 4, 64)
    end
    y = y - 86

    local th = UI.Tiles(pool, canvas, tx, y, tw, {
        { sum.casts, L["Casts"], c.ink },
        { sum.kinds.fish or 0, L["Fish"], KINDS.fish.col },
        { sum.kinds.treasure or 0, L["Treasure"], KINDS.treasure.col },
        { sum.kinds.junk or 0, L["Junk"], c.ink },
    })
    y = y - th - 12

    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Album pages"], tostring(#page.zoneIndex))
    y = y - 22
    local mapIcon = UI.Icon("map")
    for _, z in ipairs(page.zoneIndex) do
        if y < -(UI.PH - UI.BOTTOM - 22) then break end
        local here = (z.zone == WFD.zoneName)
        if here then
            local band = pool:Rect(c.redInk, 0.10)
            band:SetSize(tw + 6, 20)
            band:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 3, y + 2)
        end
        local ic = pool:Icon(mapIcon, 16)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 1, y - 1)
        local nm = pool:Text(12, here and c.redInk or c.ink, UI.FONT)
        nm:SetText(z.zone)
        nm:SetWordWrap(false)
        nm:SetWidth(tw * 0.55)
        nm:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 22, y - 2)
        local pr = pool:Text(10, c.inkFaint, UI.FONT, "RIGHT")
        pr:SetText(format(L["p. %d"], UI.PageNumber(z.page)))
        pr:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
        local cnt = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        local what = (z.hidden or 0) > 0 and format("%d / %d", z.count, z.count + z.hidden)
            or (z.count == 1 and L["1 catch"] or format(L["%d catches"], z.count))
        cnt:SetText(what)
        cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw - max(30, pr:GetStringWidth() + 10), y - 2)
        local tip = { z.zone, z.count == 1 and L["1 catch"] or format(L["%d catches"], z.count) }
        if (z.hidden or 0) > 0 then tip[3] = format(L["%d to discover"], z.hidden) end
        local hot = pool:Hot(tip, function() UI:GoToPage(z.page) end)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, 20)
        y = y - 22
    end
    if #page.zoneIndex == 0 then
        local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
        e:SetText(L["Nothing has bitten yet."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 10)
    end
end)

------------------------------------------------------------------------
-- The waters (how often it bites there) and the tackle
------------------------------------------------------------------------
UI:RegisterRenderer("fishwaters", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Waters and tackle"], L["Where it bites, and what you fished with"], -56)

    local waters = {}
    for map, z in pairs(C.catchZone or {}) do
        if (z.casts or 0) > 0 then waters[#waters + 1] = { map = map, z = z } end
    end
    table.sort(waters, function(a, b) return a.z.casts > b.z.casts end)
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Waters"], tostring(#waters))
    y = y - 22
    for i = 1, min(5, #waters) do
        local w = waters[i]
        local nm = pool:Text(12, c.ink, UI.FONT)
        nm:SetText(WFD:MapName(w.map) or "?")
        nm:SetWordWrap(false)
        nm:SetWidth(tw * 0.42)
        nm:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 2, y - 2)
        local rate = min(1, (w.z.loot or 0) / max(1, w.z.casts))
        local cnt = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        cnt:SetText(WFD:Count("%d caught in %d casts", w.z.loot or 0, w.z.casts))
        cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
        local bx = tx + tw * 0.42 + 8
        local bw = tx + tw - max(90, cnt:GetStringWidth() + 8) - bx - 6
        if bw > 12 then UI.ProgressBar(pool, canvas, bx, y - 6, bw, 5, rate, c.redInk) end
        local hot = pool:Hot({ WFD:MapName(w.map) or "?", WFD:Count("%d caught in %d casts", w.z.loot or 0, w.z.casts) })
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, 20)
        y = y - 22
    end
    if #waters == 0 then
        local e = pool:Text(13, c.inkFaint, UI.FONT, "CENTER")
        e:SetText(L["Nothing has bitten yet."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 6)
        y = y - 30
    end

    y = y - 14
    local rods = {}
    for id, r in pairs(C.tackle or {}) do rods[#rods + 1] = { id = id, r = r } end
    table.sort(rods, function(a, b) return (a.r.n or 0) > (b.r.n or 0) end)
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Tackle"], tostring(#rods))
    y = y - 22
    for i = 1, min(6, #rods) do
        local r = rods[i].r
        local fallback = TACKLE_ICONS[r.kind or "rod"] or TACKLE_ICONS.rod
        local ic = pool:Icon(instantIcon(rods[i].id) or (r.link and WFD:ItemIcon(r.link)) or UI.IconPath(fallback, "loot"), 18)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 1, y)
        local cnt = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        cnt:SetText(L[TACKLE_LABEL[r.kind or "rod"] or "Fishing pole"] .. "  -  " .. WFD:Count("%d casts", r.n or 0))
        cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 3)
        -- the name takes what the kind and the casts leave free
        local nm = pool:Text(12, c.ink, UI.FONT)
        nm:SetText(r.name or "?")
        nm:SetWordWrap(false)
        nm:SetWidth(max(60, tw - 26 - cnt:GetStringWidth() - 10))
        nm:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 26, y - 2)
        local hot = pool:Hot(nil, nil, r.link)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, 22)
        y = y - 24
    end
    if #rods == 0 then
        local e = pool:Text(12, c.inkFaint, UI.FONT)
        e:SetText(L["No fishing pole seen yet."])
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 2, y - 2)
        y = y - 22
    end
    y = y - 8
    UI.LeaderLine(pool, canvas, tx, y, tw, L["Casts with a lure"], tostring(C.catchLured or 0), 13, c.inkSoft)
    UI.LeaderLine(pool, canvas, tx, y - 20, tw, L["Casts in all"], tostring(C.catchCasts or 0), 13, c.inkSoft)
end)
