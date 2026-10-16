-- Appendix at the back of the book: milestones, maps, bestiary, people register, ledger, quests, notes.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, ceil, format = math.floor, math.max, math.min, math.ceil, string.format

local TITLE_H = 116      -- space the section title takes on its first page
local GREEN = UI.c.good

local function pageRef(book, day)
    local p = day and book.dayPage[day]
    return p, p and format(L["p. %d"], UI.PageNumber(p)) or ""
end

-- Spread rows of different heights over as many pages as needed.
local function paginateRows(book, kind, rows, extra)
    local page, y
    local function newPage(first)
        page = book:Add({ kind = kind, rows = {}, first = first, numbered = true, head = extra and extra.head })
        if extra then for k, v in pairs(extra) do if page[k] == nil then page[k] = v end end end
        y = first and TITLE_H or 0
    end
    newPage(true)
    for _, r in ipairs(rows) do
        if y + r.h + (r.keep or 0) > UI.AREA_H then newPage(false) end   -- keep headings with their rows
        r.y = y
        page.rows[#page.rows + 1] = r
        y = y + r.h
    end
    return page
end

local function title(pool, canvas, side, page, text, sub)
    if page.first then UI.PageTitle(pool, canvas, side, text, sub, -56) end
end

local function hotRow(pool, canvas, x, y, w, h, lines, onClick, link)
    local hot = pool:Hot(lines, onClick, link)
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x - 4, y + 2)
    hot:SetSize(w + 8, h - 2)
    return hot
end

------------------------------------------------------------------------
-- Milestones: a vertical timeline of wax seals
------------------------------------------------------------------------
UI:RegisterSection({
    key = "milestones", label = "Milestones", icon = "level", order = 10,
    build = function(book)
        local rows = {}
        local evs = {}
        -- single tasks of the day stay out of the timeline; a day with all of them done is a milestone
        for _, ev in ipairs(WFD.C.events) do
            if UI.SEAL[ev.k] and (ev.k ~= "challenge" or ev.all) then evs[#evs + 1] = ev end
        end
        table.sort(evs, function(a, b) return a.t < b.t end)
        local lastDay
        for _, ev in ipairs(evs) do
            if ev.day and ev.day ~= lastDay then
                lastDay = ev.day
                rows[#rows + 1] = { h = 34, dayHead = ev.day, t = ev.t, keep = 50 }
            end
            rows[#rows + 1] = { h = 50, ev = ev }
        end
        if #rows == 0 then rows[1] = { h = 40, empty = true } end
        paginateRows(book, "timeline", rows, { head = L["Milestones"] })
    end,
})

UI:RegisterRenderer("timeline", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    title(pool, canvas, side, page, L["Milestones"], L["The great moments of a life"])
    local top = -UI.TOP
    local SX = tx + 22          -- x of the timeline
    -- the thread that ties the seals together, from the first to the last seal on this page
    local firstY, lastY
    for _, r in ipairs(page.rows) do
        if r.ev then
            firstY = firstY or r.y
            lastY = r.y
        end
    end
    if firstY and lastY > firstY then
        local line = pool:Grad("VERTICAL", { 0.78, 0.60, 0.26, 0.2 }, { 0.78, 0.60, 0.26, 0.6 })
        line:SetSize(2, lastY - firstY)
        line:SetPoint("TOP", canvas, "TOPLEFT", SX, top - firstY - 20)
    end
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.empty then
            local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
            e:SetText(L["No milestones yet."])
            e:SetWidth(tw)
            e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 10)
        elseif r.dayHead then
            -- "Day 1" chip and the date, with a fading rule
            local n = pool:Text(10, c.redInk, UI.HEAD, "CENTER")
            n:SetText(format(L["Day %d"], r.dayHead):upper())
            local cw = max(44, n:GetStringWidth() + 14)
            local chip = pool:Rect(c.redInk, 0)          -- the day number stands as gold text
            chip:SetSize(cw, 15)
            chip:SetPoint("LEFT", canvas, "TOPLEFT", SX - 22, y - 18)
            n:SetPoint("CENTER", chip, "CENTER", 0, 0)
            local d = pool:Text(13, c.redInk, UI.HEAD)
            d:SetText(WFD:LongDate(r.dayHead))
            d:SetWordWrap(false)
            d:SetPoint("LEFT", chip, "RIGHT", 8, 0)
            local ln = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.45 }, { 0.91, 0.76, 0.42, 0 })
            ln:SetSize(max(10, tx + tw - (SX - 22 + cw + 16 + d:GetStringWidth())), 1)
            ln:SetPoint("LEFT", d, "RIGHT", 8, 0)
        else
            local ev = r.ev
            local def = UI.SEAL[ev.k]
            local lvl = ev.k == "level" and ev.s and ev.s:match("(%d+)")
            -- the moment's icon in a frame of its colour (an honour shows its own icon and metal)
            local icon, col = UI.Icon(def.icon), def.col
            if ev.k == "honour" and ev.honour and WFD.HonourDef then
                local h = WFD:HonourDef(ev.honour)
                if h then icon, col = UI.IconPath(h.icon, "honour"), WFD:MetalOf(ev.tier or 1, #h.tiers).col end
            end
            pool:Plaque(SX, y - 20, 28, icon, col, true, lvl)
            local tm = pool:Text(10, c.inkFaint, UI.FONT)
            tm:SetText(date("%H:%M", ev.t))
            tm:SetPoint("TOPLEFT", canvas, "TOPLEFT", SX + 28, y - 6)
            local t = pool:Text(13, c.ink, UI.FONT)
            t:SetText(ev.s)
            t:SetWidth(tw - (SX - tx) - 28 - 44)
            if t.SetMaxLines then t:SetMaxLines(2) end
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", SX + 28, y - 19)
            local p, ref = pageRef(UI.book, ev.day)
            local pr = pool:Text(11, c.inkFaint, UI.FONT, "RIGHT")
            pr:SetText(ref)
            pr:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 6)
            local lines = { ev.s, date(WFD.loc.date .. " %H:%M", ev.t) }
            if ev.shot then lines[#lines + 1] = L["Screenshot:"] .. " " .. ev.shot end
            hotRow(pool, canvas, tx + 40, y, tw - 40, r.h, lines, p and function() UI:GoToPage(p) end)
        end
    end
end)

------------------------------------------------------------------------
-- Maps: one spread per area. Left: the map, glued in like a photograph. Right: the chronicle of the area.
------------------------------------------------------------------------
UI:RegisterSection({
    key = "maps", label = "Maps", icon = "map", order = 20, leftStart = true,
    build = function(book)
        local C = WFD.C
        local t = {}
        for d, day in pairs(C.days) do
            for mapID, p in pairs(day.path) do
                local e = t[mapID] or { id = mapID, sec = 0, kills = 0, first = d }
                t[mapID] = e
                e.sec = e.sec + WFD:SumCells(p) * 2
                if d < e.first then e.first = d end
            end
            for mapID, kc in pairs(day.kcells) do
                local e = t[mapID] or { id = mapID, sec = 0, kills = 0, first = d }
                t[mapID] = e
                e.kills = e.kills + WFD:SumCells(kc)
                if d < e.first then e.first = d end
            end
        end
        local list = {}
        for _, e in pairs(t) do list[#list + 1] = e end
        table.sort(list, function(a, b) return a.first < b.first or (a.first == b.first and a.sec > b.sec) end)
        if #list == 0 then
            book:Add({ kind = "map", numbered = true, empty = true, head = L["Maps"] })
            return
        end
        for i, e in ipairs(list) do
            if i > 1 then book:PadToLeft("map" .. e.id) end
            e.zone = WFD:MapName(e.id)
            book.mapPage = book.mapPage or {}
            book.mapPage[e.id] = book:Add({ kind = "map", numbered = true, entry = e, head = L["Maps"] }).index
            book:Add({ kind = "mapinfo", numbered = true, entry = e, head = L["Maps"] })
        end
    end,
})

UI:RegisterRenderer("map", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.empty then
        UI.PageTitle(pool, canvas, side, L["Maps"], nil, -56)
        local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
        e:SetText(L["No travels recorded yet."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, -200)
        return
    end
    local e = page.entry
    local y = UI.PageTitle(pool, canvas, side, e.zone, format(L["%s spent here"], WFD:DurationText(e.sec)), -56)

    -- cream mount with a soft shadow, the map on top, photo corners holding it
    local MAT = 9
    local mw = tw - MAT * 2
    local mh = floor(mw / 1.5)
    local shadow = pool:Rect({ 0, 0, 0 }, 0.30, "ARTWORK", 0)
    shadow:SetSize(tw, mh + MAT * 2)
    shadow:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 5)
    local mat = pool:Rect({ 0.08, 0.055, 0.035 }, 1, "ARTWORK", 1)
    mat:SetSize(tw, mh + MAT * 2)
    mat:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    local m = pool:Map(mw, mh)
    m:SetSize(mw, mh)
    m:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + MAT, y - MAT)
    m:SetFrameLevel(canvas:GetFrameLevel() + 2)
    local legend = m:Draw(e.id) or {}
    -- photo corners (drawn above the map)
    local cl = canvas:GetFrameLevel() + 20
    local holder = pool:Get("corners", function(p)
        local f = CreateFrame("Frame", nil, p)
        f.parts = {}
        for i = 1, 8 do
            f.parts[i] = f:CreateTexture(nil, "OVERLAY")
            f.parts[i]:SetTexture(UI.WHITE)
            f.parts[i]:SetVertexColor(0.78, 0.60, 0.26, 1)
        end
        return f
    end)
    holder:SetFrameLevel(cl)
    holder:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    holder:SetSize(tw, mh + MAT * 2)
    local L1, T1 = 26, 6
    local corners = { { "TOPLEFT", 1, -1 }, { "TOPRIGHT", -1, -1 }, { "BOTTOMLEFT", 1, 1 }, { "BOTTOMRIGHT", -1, 1 } }
    for i, cdef in ipairs(corners) do
        local a, b = holder.parts[i * 2 - 1], holder.parts[i * 2]
        a:ClearAllPoints()
        b:ClearAllPoints()
        a:SetSize(L1, T1)
        b:SetSize(T1, L1)
        a:SetPoint(cdef[1], holder, cdef[1], cdef[2] * 0, 0)
        b:SetPoint(cdef[1], holder, cdef[1], 0, 0)
    end
    y = y - mh - MAT * 2 - 14

    -- legend header: caption on the left, the map key on the right, a red rule beneath
    local capD = pool:Diamond(6, c.redInk)
    capD:SetPoint("CENTER", canvas, "TOPLEFT", tx + 3, y - 5)
    local cap = pool:Text(10, c.redInk, UI.FONT)
    cap:SetText(L["Places of note"]:upper())
    cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 12, y)
    local sym = { { L["Route"], { 0.55, 0.08, 0.05, 1 } }, { L["Kill sites"], { 0.80, 0.72, 0.60, 1 } } }
    local sx = tx + tw
    for i = #sym, 1, -1 do
        local t = pool:Text(9, c.inkSoft, UI.FONT, "RIGHT")
        t:SetText(sym[i][1])
        t:SetPoint("TOPRIGHT", canvas, "TOPLEFT", sx, y - 1)
        local d = pool:Diamond(6, sym[i][2])
        d:SetPoint("RIGHT", t, "LEFT", -5, 0)
        sx = sx - t:GetStringWidth() - 24
    end
    local rule = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.55 }, { 0.91, 0.76, 0.42, 0.05 })
    rule:SetSize(tw, 1)
    rule:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 15)
    y = y - 24
    if #legend == 0 then
        local n = pool:Text(12, c.inkFaint, UI.FONT, "CENTER")
        n:SetText(L["Nobody was met here yet."])
        n:SetWidth(tw)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 6)
    end

    -- two columns of entries: a pin badge like the one on the map, the name, and who they were
    local C = WFD.C
    local GAP_X, ROW_H = 14, 28
    local colW = (tw - GAP_X) / 2
    local rowsFit = max(1, floor((UI.PH - UI.BOTTOM + y + 2) / ROW_H))
    for i, it in ipairs(legend) do
        local col = (i - 1) % 2
        local row = floor((i - 1) / 2)
        if row >= rowsFit then break end
        local x = tx + col * (colW + GAP_X)
        local ly = y - row * ROW_H
        local grave = it.kind == "grave"
        -- faint card behind every other row keeps the columns readable
        if row % 2 == 0 then
            local band = pool:Rect(c.paperDk, 0.35)
            band:SetSize(colW, ROW_H - 3)
            band:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, ly + 2)
        end
        local rim = pool:Circle(19, { 0.08, 0.04, 0.02, 1 }, "ARTWORK", 1)
        rim:SetPoint("CENTER", canvas, "TOPLEFT", x + 12, ly - 10)
        local dot = pool:Circle(15, grave and { 0.55, 0.04, 0.04, 1 } or { 0.80, 0.55, 0.12, 1 }, "ARTWORK", 2)
        dot:SetPoint("CENTER", rim, "CENTER")
        local num = pool:Text(10, { 1, 1, 1, 1 }, UI.FONT, "CENTER")
        num:SetShadowColor(0, 0, 0, 0.9)
        num:SetShadowOffset(1, -1)
        num:SetText(tostring(it.num))
        num:SetPoint("CENTER", rim, "CENTER", 0, 0)

        local t = pool:Text(12, grave and c.bad or c.ink, UI.FONT)
        t:SetWordWrap(false)
        t:SetWidth(colW - 30)
        t:SetText(grave and L["Grave"] or (it.name or "?"))
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 27, ly - 2)
        local subText
        if grave then
            subText = (it.by and (format(L["Killed by %s"], it.by) .. "  -  ") or "") .. format(L["Day %d"], it.day or 0)
        else
            local npc = C.npcs[it.key]
            local roles = {}
            for role in pairs(npc and npc.roles or {}) do roles[#roles + 1] = WFD:RoleName(role) end
            table.sort(roles)
            subText = roles[1] or format(L["Spoken to %d times"], npc and npc.talks or 0)
        end
        local sub = pool:Text(9, c.inkFaint, UI.FONT)
        sub:SetWordWrap(false)
        sub:SetWidth(colW - 30)
        sub:SetText(subText)
        sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 27, ly - 16)

        local hot
        if it.kind == "npc" then
            hot = pool:Hot({ it.name, subText, L["Click for the portrait."] }, function() UI:ShowCard("person", it.key) end)
        else
            local p = UI.book.dayPage[it.day]
            hot = pool:Hot({ L["You died here"], format(L["Day %d"], it.day) }, p and function() UI:GoToPage(p) end)
        end
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, ly + 2)
        hot:SetSize(colW, ROW_H - 3)
    end
end)

-- the chronicle of one area
UI:RegisterRenderer("mapinfo", function(pool, page, side, canvas)
    local C = WFD.C
    local e = page.entry
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Chronicle of the region"], e.zone, -56)

    local z = C.zones[e.zone]
    local deaths, quests, people, rests = 0, 0, 0, 0
    for _, r in ipairs(C.rests or {}) do if r.map == e.id then rests = rests + 1 end end
    for _, d in pairs(C.days) do
        for _, pos in ipairs(d.dpos) do if pos[1] == e.id then deaths = deaths + 1 end end
    end
    for _, q in pairs(C.quests) do if q.done and q.zone == e.zone then quests = quests + 1 end end
    for _, n in pairs(C.npcs) do if n.map == e.id then people = people + 1 end end
    local p = pageRef(UI.book, e.first)
    local function go(pg) return pg and function() UI:GoToPage(pg) end end
    -- the area in eight figures
    UI.Tiles(pool, canvas, tx, y, tw, {
        { WFD:DurationText(e.sec), L["Time spent"], c.ink },
        { z and z.visits or 1, L["Visits"], c.ink },
        { e.kills, L["Creatures slain here"], c.ink },
        { quests, L["Quests completed here"], c.ink },
    })
    UI.Tiles(pool, canvas, tx, y - 50, tw, {
        { format(L["Day %d"], e.first), L["First visit"], c.redInk, go(p) },
        { people, L["Acquaintances here"], c.ink },
        { rests, L["Times rested here"], c.ink },
        { deaths, L["Deaths here"], deaths > 0 and c.bad or c.ink },
    })
    y = y - 104

    -- the most hunted creatures of this area, as a small ranking
    local mobs = {}
    for id, m in pairs(C.mobs) do if m.zone == e.zone then mobs[#mobs + 1] = { id = id, m = m } end end
    table.sort(mobs, function(a, b) return a.m.kills > b.m.kills end)
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Most hunted here"], tostring(#mobs))
    y = y - 20
    if #mobs == 0 then
        local n = pool:Text(12, c.inkFaint, UI.FONT)
        n:SetText("-")
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - 18
    end
    for i = 1, min(4, #mobs) do
        local mob = mobs[i]
        local rk = pool:Text(13, c.redInk, UI.HEAD)
        rk:SetText(tostring(i))
        rk:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 2, y - 1)
        local n = pool:Text(12, c.ink, UI.FONT)
        n:SetText(mob.m.name or "?")
        n:SetWordWrap(false)
        n:SetWidth(tw * 0.48)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 18, y - 2)
        local bx = tx + 18 + tw * 0.5
        UI.ProgressBar(pool, canvas, bx, y - 6, tx + tw - 40 - bx, 5, mob.m.kills / mobs[1].m.kills, c.redInk)
        local k = pool:Text(11, c.inkSoft, UI.FONT, "RIGHT")
        k:SetText(mob.m.kills .. "x")
        k:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
        local hot = pool:Hot({ mob.m.name or "?", format(L["Slain %d times"], mob.m.kills), L["Click for the wanted poster."] },
            function() UI:ShowCard("creature", mob.id) end)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, 20)
        y = y - 22
    end

    -- places discovered
    y = y - 4
    local subs = {}
    if z and z.sub then
        for name, t in pairs(z.sub) do subs[#subs + 1] = { name = name, t = t } end
        table.sort(subs, function(a, b) return a.t < b.t end)
    end
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Places discovered"], tostring(#subs))
    y = y - 22
    if #subs == 0 then
        local n = pool:Text(12, c.inkFaint, UI.FONT)
        n:SetText("-")
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        return
    end
    -- two columns of places, each with a small ink diamond; what does not fit is counted
    local ROW = 18
    local colW = (tw - 16) / 2
    local rowsFit = max(1, floor((UI.PH - UI.BOTTOM + y - 4) / ROW))
    local cap3 = rowsFit * 2
    local shown = #subs <= cap3 and #subs or (cap3 - 1)
    for i = 1, shown do
        local col = (i - 1) % 2
        local row = floor((i - 1) / 2)
        local x = tx + col * (colW + 16)
        local ry = y - row * ROW
        local dm = pool:Diamond(5, c.redInk)
        dm:SetPoint("CENTER", canvas, "TOPLEFT", x + 4, ry - 7)
        local t = pool:Text(12, c.ink, UI.FONT)
        t:SetText(subs[i].name)
        t:SetWordWrap(false)
        t:SetWidth(colW - 14)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 13, ry - 1)
    end
    if shown < #subs then
        local i = shown + 1
        local more = pool:Text(12, c.inkFaint, UI.FONT)
        more:SetText(format("+ %d ...", #subs - shown))
        more:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + ((i - 1) % 2) * (colW + 16) + 13, y - floor((i - 1) / 2) * ROW - 1)
    end
end)

------------------------------------------------------------------------
-- Bestiary as a collector's album: every creature is a trading card
------------------------------------------------------------------------
local function levelText(m)
    if not m.level then return "?" end
    if m.level == -1 then return "??" end
    return tostring(m.level)
end

local RARITY = {
    normal = { border = { 0.62, 0.58, 0.52, 1 }, bg1 = { 0.12, 0.10, 0.08, 1 }, bg2 = { 0.30, 0.26, 0.21, 1 } },
    elite  = { border = { 1.00, 0.80, 0.32, 1 }, bg1 = { 0.16, 0.10, 0.03, 1 }, bg2 = { 0.42, 0.30, 0.10, 1 } },
    rare   = { border = { 0.72, 0.84, 1.00, 1 }, bg1 = { 0.06, 0.09, 0.18, 1 }, bg2 = { 0.22, 0.30, 0.48, 1 } },
    boss   = { border = { 0.95, 0.30, 0.16, 1 }, bg1 = { 0.16, 0.03, 0.02, 1 }, bg2 = { 0.48, 0.10, 0.06, 1 } },
}
local function rarityOf(m)
    if m.boss then return "boss" end
    if m.rare or m.cls == "rare" or m.cls == "rareelite" then return "rare" end
    if m.cls == "elite" then return "elite" end
    return "normal"
end
UI.BESTIARY_RARITY, UI.RarityOf = RARITY, rarityOf
local RARITY_TAG = { elite = "Elite", rare = "Rare", boss = "Boss" }
local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"

local TIERS = {           -- collector ranks of the bestiary (also shown on the collection page)
    { 10, "Bronze", { 0.70, 0.42, 0.20, 1 } }, { 25, "Silver", { 0.70, 0.72, 0.76, 1 } },
    { 50, "Gold", { 0.92, 0.72, 0.22, 1 } }, { 100, "Mithril", { 0.45, 0.70, 0.85, 1 } },
    { 200, "Legend", { 0.62, 0.22, 0.70, 1 } },
}
UI.BESTIARY_TIERS = TIERS
-- trophy icons for the ranks: metal bars, and a dragon's head for the legend
local function tierIcon(i)
    local list = {}
    for _, n in ipairs(UI.METAL_ICONS[i] or {}) do list[#list + 1] = "Interface\\Icons\\" .. n end
    return UI.Pick(list) or UI.Icon("bestiary")
end

local CARD_W, CARD_H, CARD_GAP, ROW_GAP = 108, 136, 12, 10
local PER_PAGE = 9

-- collection order: first kill first, numbered like an album
local function collection()
    local arr = {}
    for id, m in pairs(WFD.C.mobs) do arr[#arr + 1] = { id = id, m = m } end
    table.sort(arr, function(a, b)
        if (a.m.first or 0) ~= (b.m.first or 0) then return (a.m.first or 0) < (b.m.first or 0) end
        return (a.m.name or "") < (b.m.name or "")
    end)
    for i, e in ipairs(arr) do e.num = i end
    return arr
end

-- every footstep on a map, all days added up. Days gone by do not change any more,
-- so their sum is kept for the session; only today is added each time.
local pastCells, pastFor, pastDay = {}, nil, nil
local function walkedCells(map)
    local C, today = WFD.C, WFD:DayIndex()
    if pastFor ~= C or pastDay ~= today then pastCells, pastFor, pastDay = {}, C, today end
    local past = pastCells[map]
    if not past then
        past = {}
        for idx, d in pairs(C.days) do
            local path = idx < today and d.path and WFD:PathCells(d.path[map])
            if path then
                for key, v in pairs(path) do past[key] = (past[key] or 0) + v end
            end
        end
        pastCells[map] = past
    end
    local cells = {}
    for key, v in pairs(past) do cells[key] = v end
    local now = C.days[today]
    local path = now and now.path and WFD:PathCells(now.path[map])
    if path then
        for key, v in pairs(path) do cells[key] = (cells[key] or 0) + v end
    end
    return cells
end

-- the parts of an area you walked least (but did walk: the sea is no hint), least first
local function quietCorners(map)
    if not map then return nil end
    local cells = walkedCells(map)
    local per = {}
    for key, v in pairs(cells) do
        local x, y = (floor(key / 100) + 0.5) / 100, (key % 100 + 0.5) / 100
        local dir = WFD:Direction(x, y)
        if dir then
            local e = per[dir] or { dir = dir, v = 0, sx = 0, sy = 0, n = 0 }
            per[dir] = e
            e.v, e.sx, e.sy, e.n = e.v + v, e.sx + x, e.sy + y, e.n + 1
        end
    end
    local list = {}
    for _, e in pairs(per) do list[#list + 1] = e end
    if #list < 2 then return nil end
    table.sort(list, function(a, b) return a.v < b.v end)
    local out = {}
    for i = 1, math.min(3, #list) do
        local e = list[i]
        out[i] = { dir = e.dir, map = map, x = e.sx / e.n, y = e.sy / e.n }
    end
    return out
end

-- the map an area of the album lies on
local function mapOfZone(z, list)
    local C = WFD.C
    if C.zoneMaps and C.zoneMaps[z] then return C.zoneMaps[z] end
    for _, e in ipairs(list) do
        local m = (e.m and e.m.map) or (e.h and e.h.m)
        if m then return m end
    end
end

UI:RegisterSection({
    key = "bestiary", label = "Bestiary", icon = "beast", order = 30,
    build = function(book)
        local arr = collection()
        -- group by area, areas in order of their first creature
        local zones, byZone = {}, {}
        for _, e in ipairs(arr) do
            local z = e.m.zone or "?"
            if not byZone[z] then
                byZone[z] = {}
                zones[#zones + 1] = z
            end
            table.insert(byZone[z], e)
        end
        -- kinds your other characters already know: covered cards with a hint where to look
        local hints = WFD.CreatureHints and WFD:CreatureHints() or {}
        local own = {}
        for _, z in ipairs(zones) do own[z] = #byZone[z] end
        local extra = {}
        for z, list in pairs(hints) do
            if byZone[z] then
                for _, h in ipairs(list) do table.insert(byZone[z], h) end
            else
                byZone[z] = list
                own[z] = 0
                extra[#extra + 1] = { z = z, lv = list[1] and list[1].h.lv or 0 }
            end
        end
        table.sort(extra, function(a, b) return (a.lv or 0) < (b.lv or 0) end)
        for _, e in ipairs(extra) do zones[#zones + 1] = e.z end
        local intro = book:Add({ kind = "albumintro", numbered = true, head = L["Bestiary"], zoneIndex = {} })
        if next(WFD.C.mobs) then book:Add({ kind = "albumkinds", numbered = true, head = L["Bestiary"] }) end
        book.nextPage = nil
        if next(WFD.C.mobs) or next(WFD.C.sighted or {}) then
            book.nextPage = book:Add({ kind = "albumnext", numbered = true, head = L["Bestiary"] }).index
        end
        local grounds = {}
        for _, z in ipairs(zones) do
            local map = mapOfZone(z, byZone[z])
            if map then grounds[#grounds + 1] = { zone = z, map = map } end
        end
        book.huntZones = {}
        if #grounds > 0 then
            book.huntPage = book:Add({ kind = "huntmap", numbered = true, head = L["Bestiary"], grounds = grounds }).index
            for _, g in ipairs(grounds) do book.huntZones[g.zone] = true end
        end
        book.albumPage = {}
        for _, z in ipairs(zones) do
            local list = byZone[z]
            -- your own cards; what you only saw and what your other characters know goes in a list after them
            local mine, hints = {}, {}
            for _, e in ipairs(list) do
                if e.hint then hints[#hints + 1] = e else mine[#mine + 1] = e end
            end
            -- what is worth hunting first; critters and what is grey to you at the end, each part by level
            local lvl = UnitLevel("player") or 1
            local function minor(h)
                return h.cls == "trivial" or h.cls == "minus" or (h.lv and h.lv > 0 and h.lv < lvl - 7) or false
            end
            table.sort(hints, function(a, b)
                local ma, mb = minor(a.h), minor(b.h)
                if ma ~= mb then return mb end
                if (a.h.lv or 0) ~= (b.h.lv or 0) then return (a.h.lv or 0) < (b.h.lv or 0) end
                return (a.h.n or "") < (b.h.n or "")
            end)
            local hidden = #hints
            local first
            local pages = math.ceil(#mine / PER_PAGE)
            for p = 1, pages do
                local cards = {}
                for i = (p - 1) * PER_PAGE + 1, math.min(#mine, p * PER_PAGE) do cards[#cards + 1] = mine[i] end
                local pg = book:Add({ kind = "album", numbered = true, head = L["Bestiary"], zone = z, cards = cards,
                    part = (pages > 1) and p or nil, count = own[z], hidden = hidden })
                if #cards < PER_PAGE and hidden == 0 then pg.fill = quietCorners(mapOfZone(z, list)) end
                first = first or pg.index
            end
            local hpages = math.ceil(#hints / UI.HINT_ROWS)
            for p = 1, hpages do
                local rows = {}
                for i = (p - 1) * UI.HINT_ROWS + 1, math.min(#hints, p * UI.HINT_ROWS) do rows[#rows + 1] = hints[i] end
                local pg = book:Add({ kind = "albumhints", numbered = true, head = L["Bestiary"], zone = z, hints = rows,
                    part = (hpages > 1) and p or nil, count = own[z], hidden = hidden })
                first = first or pg.index
            end
            if first then
                intro.zoneIndex[#intro.zoneIndex + 1] = { zone = z, page = first, count = own[z], hidden = hidden }
                book.albumPage[z] = first
            end
        end
        for _, g in ipairs(grounds) do g.page = book.albumPage[g.zone] end
    end,
})

-- the name on the plate of a card: two lines at most, a smaller size before anything is cut, and a word
-- too long for one line broken at its hyphen (else in the middle, never inside a letter)
local NAME_W = CARD_W - 20
local function fitName(fs, text)
    local function px(s) return UI.FS and UI.FS(s) or s end
    local function fits(s, t)
        for w in t:gmatch("[^%s]+") do
            if UI.MeasureWidth(w, px(s), UI.FONT) > NAME_W then return false end
        end
        return UI.Measure(t, px(s), NAME_W, 0, UI.FONT) <= px(s) * 2.7
    end
    local function set(s, t)
        fs:SetFont(UI.FONT, px(s), "")
        fs:SetText(t)
    end
    for s = 10, 8, -1 do
        if fits(s, text) then return set(s, text) end
    end
    local long, lw = nil, 0
    for w in text:gmatch("[^%s]+") do
        local ww = UI.MeasureWidth(w, px(8), UI.FONT)
        if ww > lw then long, lw = w, ww end
    end
    if not long then return set(8, text) end
    local a, b = long:match("^(.+%-)(.+)$")
    if not a then
        local mid = math.floor(#long / 2)
        while mid > 1 and long:byte(mid + 1) and long:byte(mid + 1) >= 128 and long:byte(mid + 1) < 192 do mid = mid - 1 end
        a, b = long:sub(1, mid) .. "-", long:sub(mid + 1)
    end
    local i = text:find(long, 1, true)
    text = text:sub(1, i - 1) .. a .. "\n" .. b .. text:sub(i + #long)
    for s = 10, 8, -1 do
        if fits(s, text) or s == 8 then return set(s, text) end
    end
end

-- one trading card, built once per pool slot
local function newCard(parent)
    local f = UI.Frame(parent, CARD_W, CARD_H, "Button")
    f.shadow = f:CreateTexture(nil, "BACKGROUND", nil, -7)
    f.shadow:SetTexture(UI.WHITE)
    f.shadow:SetVertexColor(0, 0, 0, 0.35)
    f.shadow:SetPoint("TOPLEFT", 3, -4)
    f.shadow:SetPoint("BOTTOMRIGHT", 3, -4)
    f.bg = f:CreateTexture(nil, "BACKGROUND", nil, -6)
    f.bg:SetPoint("TOPLEFT", 3, -3)
    f.bg:SetPoint("BOTTOMRIGHT", -3, 3)
    f.edge = UI.Frame(f)
    f.edge:SetAllPoints()
    f.window = UI.Frame(f, CARD_W - 16, 78)
    f.window:SetPoint("TOP", 0, -18)
    UI.Backdrop(f.window, nil, 1, 0, { 0, 0, 0, 0.35 }, { 0, 0, 0, 0.8 })
    f.model = CreateFrame("PlayerModel", nil, f.window)
    f.model:SetPoint("TOPLEFT", 1, -1)
    f.model:SetPoint("BOTTOMRIGHT", -1, 1)
    f.num = UI.Text(f, 10, { 1, 0.92, 0.75, 1 }, "LEFT", UI.FONT, true)
    f.num:SetPoint("TOPLEFT", 7, -5)
    f.lvl = UI.Text(f, 10, { 1, 0.92, 0.75, 1 }, "RIGHT", UI.FONT, true)
    f.lvl:SetPoint("TOPRIGHT", -7, -5)
    f.plate = f:CreateTexture(nil, "ARTWORK", nil, 1)
    f.plate:SetTexture(UI.WHITE)
    f.plate:SetVertexColor(0.16, 0.12, 0.08, 1)
    f.plate:SetPoint("TOPLEFT", 6, -100)
    f.plate:SetPoint("BOTTOMRIGHT", -6, 6)
    f.name = UI.Text(f, 10, c.ink, "CENTER", UI.FONT)
    f.name:SetPoint("TOPLEFT", f.plate, "TOPLEFT", 3, -2)
    f.name:SetPoint("BOTTOMRIGHT", f.plate, "BOTTOMRIGHT", -3, 2)
    f.name:SetJustifyV("MIDDLE")
    if f.name.SetMaxLines then f.name:SetMaxLines(2) end
    -- how many were slain: a small badge stuck on the lower corner of the picture
    f.badge = UI.CountBadge(f, 20)
    f.badge:SetPoint("RIGHT", f.window, "BOTTOMRIGHT", 4, 0)
    f.badge:SetFrameLevel(f:GetFrameLevel() + 4)
    f.new = UI.Text(f, 10, { 1, 0.95, 0.6, 1 }, "CENTER", UI.HEAD, true)
    f.new:SetPoint("TOPRIGHT", f.window, "TOPRIGHT", -2, -2)
    -- the rarity: a word at the top and a diamond in each corner
    f.tag = UI.Text(f, 8, { 1, 1, 1, 1 }, "CENTER", UI.HEAD, true)
    f.tag:SetPoint("TOP", 0, -5)
    f.corners = {}
    for i, pt in ipairs({ { "TOPLEFT", 4, -4 }, { "TOPRIGHT", -4, -4 }, { "BOTTOMLEFT", 4, 4 }, { "BOTTOMRIGHT", -4, 4 } }) do
        local d = UI.Diamond(f, 9, { 1, 1, 1, 1 }, "OVERLAY", 2)
        d:SetPoint("CENTER", f, pt[1], pt[2], pt[3])
        f.corners[i] = d
    end
    -- a sketch until ten are slain: the picture lies under a wash of paper
    f.over = CreateFrame("Frame", nil, f.window)
    f.over:SetAllPoints()
    f.over:SetFrameLevel(f.model:GetFrameLevel() + 3)
    f.wash = f.over:CreateTexture(nil, "ARTWORK", nil, 0)
    f.wash:SetTexture(UI.WHITE)
    f.wash:SetPoint("TOPLEFT", 1, -1)
    f.wash:SetPoint("BOTTOMRIGHT", -1, 1)
    UI.Gradient(f.wash, "VERTICAL", { 0.62, 0.50, 0.32, 0.62 }, { 0.80, 0.68, 0.46, 0.50 })
    -- a connoisseur's card: gold rim and a word on the picture
    f.rim = UI.Frame(f.over)
    f.rim:SetPoint("TOPLEFT", -2, 2)
    f.rim:SetPoint("BOTTOMRIGHT", 2, -2)
    UI.Backdrop(f.rim, "tooltip", 8, 2, { 0, 0, 0, 0 }, { 1, 0.82, 0.30, 1 })
    f.master = UI.Text(f.over, 8, { 1, 0.86, 0.36, 1 }, "LEFT", UI.HEAD, true)
    f.master:SetPoint("BOTTOMLEFT", 4, 3)
    -- this one has killed you
    f.skull = f.over:CreateTexture(nil, "OVERLAY")
    f.skull:SetTexture(SKULL)
    f.skull:SetSize(14, 14)
    f.skull:SetPoint("TOPLEFT", 3, -3)
    -- the "new" mark and the count stay above the wash
    f.new:SetParent(f.over)
    f.badge:SetFrameLevel(f.over:GetFrameLevel() + 2)
    f.sil = UI.Text(f.window, 34, { 0.55, 0.45, 0.30, 0.55 }, "CENTER", UI.HEAD)
    f.sil:SetPoint("CENTER", 0, 0)
    f.sil:SetText("?")
    f.q = UI.Text(f, 40, { 0.55, 0.45, 0.30, 0.6 }, "CENTER", UI.HEAD)
    f.q:SetPoint("CENTER", 0, 8)
    f.qsub = UI.Text(f, 10, { 0.88, 0.76, 0.54, 1 }, "CENTER", UI.FONT, true)
    f.qsub:SetPoint("BOTTOM", 0, 14)
    f.hl = f:CreateTexture(nil, "OVERLAY")
    f.hl:SetTexture(UI.WHITE)
    f.hl:SetVertexColor(1, 0.9, 0.6, 0.12)
    f.hl:SetAllPoints()
    f.hl:Hide()
    local function lift(self, up)
        if (self.lifted and true or false) == up or not self.AdjustPointsOffset then return end
        self.lifted = up or nil
        pcall(self.AdjustPointsOffset, self, 0, up and 3 or -3)
        self.shadow:SetVertexColor(0, 0, 0, up and 0.55 or 0.35)
    end
    f:SetScript("OnEnter", function(self)
        if not self.entry then
            local fill = self.spot
            if not fill then return end
            self.hl:Show()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Not yet discovered"], 1, 0.86, 0.5)
            GameTooltip:AddLine(format(L["You have been %s of this area least of all. Something may still be waiting there."],
                L[fill.dir]), 0.9, 0.9, 0.9, true)
            GameTooltip:AddLine(L["Click to set a marker on the map."], 0.5, 0.8, 1)
            GameTooltip:Show()
            return
        end
        self.hl:Show()
        if self.entry.hint then
            local h = self.entry.h
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.entry.sighted then
                GameTooltip:SetText(L["Sighted, not yet slain"], 1, 0.86, 0.5)
                if h.n then GameTooltip:AddLine(h.n, 1, 1, 1) end
            else
                GameTooltip:SetText(L["Not yet discovered"], 1, 0.86, 0.5)
            end
            local where = self.entry.zone
            local dir = WFD:Direction(h.x, h.y)
            if dir then where = where .. "  -  " .. L[dir] end
            GameTooltip:AddLine(where, 0.9, 0.9, 0.9, true)
            if h.lv then GameTooltip:AddLine(format(L["Level %s"], h.lv == -1 and "??" or tostring(h.lv)), 0.8, 0.8, 0.8) end
            local kind = (h.boss and L["Boss"]) or (h.rare and L["Rare"]) or ((h.cls == "elite" or h.cls == "rareelite") and L["Elite"])
            if kind then GameTooltip:AddLine(kind, 1, 0.75, 0.3) end
            if h.who then GameTooltip:AddLine(format(L["Known to %s"], h.who), 0.6, 0.75, 1) end
            if h.m and h.x then
                GameTooltip:AddLine(L["Click to set a marker on the map."], 0.5, 0.8, 1)
                GameTooltip:AddLine(L["Right-click for the map of this region."], 0.5, 0.8, 1)
            elseif h.m then
                GameTooltip:AddLine(L["Click for the map of this region."], 0.5, 0.8, 1)
            end
            GameTooltip:Show()
            return
        end
        local m = self.entry.m
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(m.name or "?", 1, 0.86, 0.5)
        local kind = m.ctype and (m.fam and (m.ctype .. "  -  " .. m.fam) or m.ctype)
        if kind then GameTooltip:AddLine(kind, 0.75, 0.75, 0.75) end
        GameTooltip:AddLine("\"" .. WFD:MarginNote(self.entry.id, m) .. "\"", 0.95, 0.85, 0.65, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format(L["Slain %d times"], m.kills), 0.9, 0.9, 0.9)
        local stage = WFD:MobStage(m)
        if stage == 1 then
            GameTooltip:AddLine(format(L["A sketch - %d more and it is in colour."], WFD.STAGE_COLOUR - m.kills), 0.75, 0.65, 0.45, true)
        elseif stage == 2 then
            GameTooltip:AddLine(format(L["%d more to become a connoisseur."], WFD.STAGE_MASTER - m.kills), 0.75, 0.65, 0.45, true)
        else
            GameTooltip:AddLine(L["Connoisseur of this kind"], 1, 0.82, 0.3)
        end
        if m.first then
            local day = WFD:DayIndex(m.first)
            local line = format(L["First slain on day %d"], day)
            local where = m.fz or m.zone
            if where then line = line .. "  -  " .. where end
            if m.fpl then line = line .. "  -  " .. format(L["at level %d"], m.fpl) end
            GameTooltip:AddLine(line, 0.7, 0.7, 0.7, true)
        end
        if m.best then GameTooltip:AddLine(L["Best loot"] .. ": " .. m.best, 0.7, 0.7, 0.7) end
        local nem = WFD.C.nemesis[m.name or ""]
        if nem and nem.n > 0 then
            GameTooltip:AddLine(nem.n == 1 and L["Got you once."] or format(L["Got you %d times."], nem.n), 1, 0.35, 0.25)
        end
        GameTooltip:AddLine(L["Click for the wanted poster."], 0.5, 0.8, 1)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function(self)
        self.hl:Hide()
        GameTooltip:Hide()
        lift(self, false)
    end)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:HookScript("OnEnter", function(self) lift(self, true) end)
    f:SetScript("OnClick", function(self, button)
        if not self.entry then
            local fill = self.spot
            if fill then WFD:SetMapMarker(fill.map, fill.x, fill.y, self.zone) end
            return
        end
        if self.entry.hint then
            local h = self.entry.h
            if h.m and h.x and button ~= "RightButton" then
                -- only a creature you saw yourself is named; the others stay a secret
                WFD:SetMapMarker(h.m, h.x, h.y, (self.entry.sighted and h.n) or self.entry.zone)
            elseif h.m then
                UI:ShowMapOf(h.m)
            end
            return
        end
        UI:ShowCard("creature", self.entry.id)
    end)

    function f:SetEntry(e, fill, zone)
        self.lifted = nil          -- the card was placed anew
        self.entry = e
        self.spot = (not e) and fill or false     -- false, not nil: the field must exist on the frame
        self.zone = zone
        local fillDir = self.spot and self.spot.dir
        if e and e.hint then
            -- a covered card: no name, no picture - only the level and where to look
            local h = e.h
            self.window:Hide()
            self.num:Hide()
            self.plate:Hide()
            self.name:Hide()
            self.badge:Hide()
            self.tag:SetText("")
            for _, d in ipairs(self.corners) do d:Hide() end
            self.shadow:Show()
            self.lvl:Show()
            self.lvl:SetText(h.lv and format(L["Lv %s"], h.lv == -1 and "??" or tostring(h.lv)) or "")
            self.q:Show()
            self.qsub:Show()
            local edge = (h.boss and { 0.75, 0.25, 0.15, 0.8 }) or (h.rare and { 0.45, 0.60, 0.95, 0.8 })
                or ((h.cls == "elite" or h.cls == "rareelite") and { 0.90, 0.70, 0.25, 0.8 }) or { 0.62, 0.48, 0.24, 0.7 }
            UI.Backdrop(self.edge, "tooltip", 12, 3, { 0, 0, 0, 0 }, edge)
            UI.Gradient(self.bg, "VERTICAL", { 0.06, 0.04, 0.03, 0.9 }, { 0.16, 0.11, 0.07, 0.9 })
            self.q:SetText("?")
            local dir = WFD:Direction(h.x, h.y)
            self.qsub:SetText(dir and L[dir] or "")
            UI.FitText(self.qsub, CARD_W - 12, 10, 8, UI.FONT)
            self.new:SetText("")
            self.model:ClearModel()
            self.modelId = nil
            return
        end
        local filled = e ~= nil
        self.window:SetShown(filled)
        self.num:SetShown(filled)
        self.lvl:SetShown(filled)
        self.plate:SetShown(filled)
        self.name:SetShown(filled)
        self.badge:SetShown(filled)
        self.q:SetShown(not filled)
        self.qsub:SetShown(not filled)
        self.shadow:SetShown(filled)
        if not filled then
            self.tag:SetText("")
            for _, d in ipairs(self.corners) do d:Hide() end
            UI.Backdrop(self.edge, "tooltip", 12, 3, { 0, 0, 0, 0 }, { 0.45, 0.32, 0.16, 0.45 })
            self.bg:SetTexture(UI.WHITE)
            self.bg:SetVertexColor(0.55, 0.42, 0.22, 0.10)
            self.q:SetText("?")
            self.qsub:SetText(fillDir and format(L["perhaps %s"], L[fillDir]) or L["not yet found"])
            UI.FitText(self.qsub, CARD_W - 12, 10, 8, UI.FONT)
            self.new:SetText("")
            self.model:ClearModel()
            self.modelId = nil
            return
        end
        local m = e.m
        local rk = rarityOf(m)
        local r = RARITY[rk]
        UI.Backdrop(self.edge, "tooltip", rk == "normal" and 12 or 14, 3, { 0, 0, 0, 0 }, r.border)
        UI.Gradient(self.bg, "VERTICAL", r.bg1, r.bg2)
        self.tag:SetText(RARITY_TAG[rk] and L[RARITY_TAG[rk]]:upper() or "")
        self.tag:SetTextColor(col4(r.border))
        for _, d in ipairs(self.corners) do
            d:SetShown(rk ~= "normal")
            d:SetVertexColor(col4(r.border))
        end
        local stage = WFD:MobStage(m)
        self.wash:SetShown(stage == 1)
        self.rim:SetShown(stage == 3)
        self.master:SetText(stage == 3 and L["CONNOISSEUR"] or "")
        local nem = WFD.C.nemesis[m.name or ""]
        self.skull:SetShown(nem ~= nil and (nem.n or 0) > 0)
        self.num:SetText(format("#%03d", e.num))
        self.lvl:SetText(format(L["Lv %s"], levelText(m)))
        fitName(self.name, m.name or "?")
        self.badge:SetCount(UI.ShortCount(m.kills), UI.BADGE_COLOURS[rarityOf(m)] or UI.BADGE_COLOURS.normal)
        local isNew = m.first and WFD:DayIndex(m.first) == WFD:NumDays()
        self.new:SetText(isNew and L["NEW"] or "")
        if self.modelId ~= e.id then
            self.modelId = e.id
            UI.LoadCreature(self.model, e.id, 0.65, self.sil)
        end
    end
    return f
end

local function kindsText(n) return n == 1 and L["1 kind"] or format(L["%d kinds"], n) end

-- the head of an album page: the area (a click leads to its hunting grounds), how many kinds, a thin bar
function UI.AlbumHead(pool, canvas, tx, tw, page)
    local top = -UI.TOP
    local h = pool:Text(17, c.redInk, UI.HEAD)
    h:SetText(page.zone .. (page.part and ("  (" .. page.part .. ")") or ""))
    h:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, top + 4)
    local b = UI.book
    if b and b.huntPage and b.huntZones and b.huntZones[page.zone] then
        local hot = pool:Hot({ page.zone, L["Click for the hunting grounds of this area."] }, function()
            UI.huntArea = page.zone
            UI:GoToPage(b.huntPage)
        end)
        hot:SetPoint("TOPLEFT", h, "TOPLEFT", -3, 3)
        hot:SetPoint("BOTTOMRIGHT", h, "BOTTOMRIGHT", 3, -3)
    end
    local cnt = pool:Text(10, c.inkFaint, UI.FONT, "RIGHT")
    cnt:SetText(kindsText(page.count)
        .. ((page.hidden or 0) > 0 and ("  -  " .. format(L["%d to discover"], page.hidden)) or ""))
    cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, top)
    local rule = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.6 }, { 0.91, 0.76, 0.42, 0 })
    rule:SetSize(tw, 1)
    rule:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, top - 16)
    local known = (page.count or 0) + (page.hidden or 0)
    if known > 0 then
        local done = page.count >= known
        local bar = pool:Rect(done and c.goldDk or c.redInk, 0.85)
        bar:SetSize(max(1, tw * page.count / known), 2)
        bar:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, top - 15)
    end
end

UI:RegisterRenderer("album", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local top = -UI.TOP
    UI.AlbumHead(pool, canvas, tx, tw, page)

    local gridX = tx + (tw - (CARD_W * 3 + CARD_GAP * 2)) / 2
    -- with a list of what is still to discover after these cards, empty slots stay empty
    local slots = ((page.hidden or 0) > 0) and #page.cards or PER_PAGE
    for i = 1, slots do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local card = pool:Get("albumcard", newCard)
        card:SetFrameLevel(canvas:GetFrameLevel() + 2)
        card:SetPoint("TOPLEFT", canvas, "TOPLEFT", gridX + col * (CARD_W + CARD_GAP), top - 24 - row * (CARD_H + ROW_GAP))
        local fill = page.fill
        card:SetEntry(page.cards[i], fill and fill[((i - #page.cards - 1) % #fill) + 1], page.zone)
    end
end)

UI:RegisterRenderer("albumintro", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Bestiary"], L["A collector's album of every creature slain"], -56)
    local kinds, kills, bosses, rares, elites, masters = 0, 0, 0, 0, 0, 0
    for _, m in pairs(C.mobs) do
        kinds = kinds + 1
        if WFD:MobStage(m) == 3 then masters = masters + 1 end
        kills = kills + m.kills
        local r = rarityOf(m)
        if r == "boss" then bosses = bosses + 1 elseif r == "rare" then rares = rares + 1 elseif r == "elite" then elites = elites + 1 end
    end
    -- the rank reached so far and the next one to aim for
    local n = #TIERS
    local cur, nextT = 0, nil
    for i, t in ipairs(TIERS) do
        if kinds >= t[1] then cur = i elseif not nextT then nextT = i end
    end

    -- big count with the next goal beside it, centred together
    local big = pool:Text(44, c.ink, UI.HEAD)
    big:SetText(tostring(kinds))
    local goal = pool:Text(18, c.inkFaint, UI.HEAD)
    goal:SetText(nextT and (" / " .. TIERS[nextT][1]) or "")
    local bw, gw = big:GetStringWidth(), goal:GetStringWidth()
    local bx = tx + (tw - bw - gw) / 2
    big:SetPoint("TOPLEFT", canvas, "TOPLEFT", bx, y + 2)
    goal:SetPoint("BOTTOMLEFT", big, "BOTTOMRIGHT", 0, 6)
    local bl = pool:Text(10, c.inkSoft, UI.FONT, "CENTER")
    bl:SetText(format(L["kinds collected  -  %d creatures slain"], kills):upper())
    bl:SetWidth(tw)
    bl:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 46)
    y = y - 78

    -- collector ranks: a shelf of trophies on a thread that fills up as the album grows
    local step = tw / n
    local MY = y - 24                         -- y of the plaque centres
    local function mx(i) return tx + step * (i - 0.5) end
    local track = pool:Rect(c.inkFaint, 0.35, "BORDER", 0)
    track:SetSize(mx(n) - mx(1), 2)
    track:SetPoint("LEFT", canvas, "TOPLEFT", mx(1), MY)
    if cur >= 1 then
        local fillX = mx(n)
        if cur < n then
            local a, b = TIERS[cur][1], TIERS[cur + 1][1]
            fillX = mx(cur) + step * (kinds - a) / (b - a)
        end
        local fill = pool:Rect(c.redInk, 0.85, "BORDER", 1)
        fill:SetSize(max(1, fillX - mx(1)), 2)
        fill:SetPoint("LEFT", canvas, "TOPLEFT", mx(1), MY)
    end
    for i, t in ipairs(TIERS) do
        local reached = kinds >= t[1]
        local x = mx(i)
        local size = (i == cur) and 38 or 32
        local plaque = pool:Plaque(x, MY, size, tierIcon(i), t[3], reached, tostring(t[1]))
        local lab = pool:Text(9, i == cur and c.redInk or (reached and c.ink or c.inkFaint), UI.FONT, "CENTER")
        lab:SetText(L[t[2]]:upper())
        lab:SetPoint("TOP", canvas, "TOPLEFT", x, MY - 27)
        if i == nextT then
            -- how far along the way to the next trophy
            local prev = cur >= 1 and TIERS[cur][1] or 0
            local bw = min(step - 16, 48)
            local bt = pool:Rect(c.inkFaint, 0.25)
            bt:SetSize(bw, 3)
            bt:SetPoint("TOP", lab, "BOTTOM", 0, -4)
            local bf = pool:Rect(c.redInk, 0.9)
            bf:SetSize(max(1, bw * (kinds - prev) / (t[1] - prev)), 3)
            bf:SetPoint("TOPLEFT", bt, "TOPLEFT")
        end
        local hot = pool:Hot({ L[t[2]], format(L["Collect %d kinds of creatures."], t[1]),
            reached and L["Reached!"] or format(L["%d still missing."], t[1] - kinds) })
        hot:SetPoint("CENTER", plaque, "CENTER", 0, -10)
        hot:SetSize(step - 4, 64)
    end
    y = y - 86

    -- four tiles once there is something to count; before that, the creature closest to its next stage
    local nearest
    if bosses + rares + elites + masters == 0 then
        for id, m in pairs(C.mobs) do
            local stage = WFD:MobStage(m)
            local left = (stage == 1 and WFD.STAGE_COLOUR or WFD.STAGE_MASTER) - (m.kills or 0)
            if not nearest or left < nearest.left then nearest = { m = m, left = left, stage = stage } end
        end
    end
    local nextPage = UI.book and UI.book.nextPage
    if nearest and nextPage then
        local lead = pool:Text(10, c.redInk, UI.FONT)
        lead:SetText(L["Almost there"]:upper())
        lead:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 4)
        local what = format(nearest.stage == 1 and L["%d more, then in colour"] or L["%d more, then a connoisseur"], nearest.left)
        local line = pool:Link((nearest.m.name or "?") .. "  -  " .. what .. "  >", function() UI:GoToPage(nextPage) end, 13)
        line:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 20)
        line:SetWidth(tw)
        line:SetWordWrap(false)
    else
        UI.Tiles(pool, canvas, tx, y, tw, {
            { bosses, L["Bosses"], bosses > 0 and RARITY.boss.border or c.ink },
            { rares, L["Rare creatures"], rares > 0 and { 0.22, 0.38, 0.66, 1 } or c.ink },
            { elites, L["Elite"], elites > 0 and { 0.74, 0.54, 0.14, 1 } or c.ink },
            { masters, L["Connoisseur"], masters > 0 and c.goldDk or c.ink },
        })
    end
    y = y - 54

    -- the album pages, one row per area with how many kinds live there
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Album pages"], tostring(#page.zoneIndex))
    y = y - 22
    local mapIcon = UI.Icon("map")
    for _, z in ipairs(page.zoneIndex) do
        if y < -(UI.PH - UI.BOTTOM - 22) then break end
        -- the area you are in: a soft band, its name in the accent colour and a marker behind it
        local here = (z.zone == WFD.zoneName)
        if here then
            local band = pool:Rect(c.redInk, 0.10)
            band:SetSize(tw + 6, 20)
            band:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 3, y + 2)
        end
        local ic = pool:Icon(mapIcon, 16)
        ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 1, y - 1)
        local n = pool:Text(12, here and c.redInk or c.ink, UI.FONT)
        n:SetText(z.zone)
        n:SetWordWrap(false)
        n:SetWidth(tw * 0.45 - (here and 12 or 0))
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 22, y - 2)
        if here then
            local dm = pool:Diamond(7, c.redInk)
            dm:SetPoint("CENTER", canvas, "TOPLEFT", tx + 22 + min(n:GetStringWidth(), tw * 0.45 - 12) + 8, y - 8)
        end
        -- from the right: page reference, number of kinds, then the bar fills the room that is left
        local pr = pool:Text(10, c.inkFaint, UI.FONT, "RIGHT")
        pr:SetText(format(L["p. %d"], UI.PageNumber(z.page)))
        pr:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
        local cntRight = tx + tw - max(30, pr:GetStringWidth() + 10)
        local cnt = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        -- an area only your other characters know: how much waits there
        local known = z.count + (z.hidden or 0)
        local what = (z.hidden or 0) > 0 and format("%d / %d", z.count, known) or kindsText(z.count)
        cnt:SetText(what)
        cnt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", cntRight, y - 2)
        local bx = tx + 26 + tw * 0.45
        local bw = cntRight - max(56, cnt:GetStringWidth() + 10) - bx
        -- every kind known there collected: a golden bar
        local full = (z.hidden or 0) == 0 and z.count > 0
        if bw > 12 then UI.ProgressBar(pool, canvas, bx, y - 6, bw, 5, z.count / max(1, known), full and c.goldDk or c.redInk) end
        local tip = { z.zone, kindsText(z.count) }
        if (z.hidden or 0) > 0 then tip[3] = format(L["%d to discover"], z.hidden) else tip[3] = L["Every kind known here is collected."] end
        if here then tip[#tip + 1] = L["You are here."] end
        local hot = pool:Hot(tip, function() UI:GoToPage(z.page) end)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        hot:SetSize(tw, 20)
        y = y - 22
    end
    if #page.zoneIndex == 0 then
        local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
        e:SetText(L["No creature has fallen yet."])
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 10)
    end
end)

------------------------------------------------------------------------
-- People register: alphabetical, each person with the icon of their trade
------------------------------------------------------------------------
-- most telling role first
local ROLE_ORDER = { "flight", "trainer", "bank", "auction", "stable", "merchant", "quest", "petition", "talk" }
local ROLE_ICONS = {
    flight = { "Ability_Mount_Gryphon_01", "Ability_Mount_Wyvern_01", "Spell_Nature_Swiftness" },
    trainer = { "INV_Misc_Book_11", "INV_Misc_Book_09" }, bank = { "INV_Misc_Coin_01" },
    auction = { "INV_Misc_Coin_02" }, stable = { "Ability_Hunter_BeastTaming" }, merchant = { "INV_Misc_Bag_10" },
    quest = { "INV_Scroll_03" }, petition = { "INV_Letter_15" }, talk = { "INV_Misc_Note_01" },
}
UI.ROLE_ORDER, UI.ROLE_ICONS = ROLE_ORDER, ROLE_ICONS      -- the person cards use them too
local function mainRole(n)
    for _, r in ipairs(ROLE_ORDER) do
        if n.roles and n.roles[r] then return r end
    end
    return "talk"
end

UI:RegisterSection({
    key = "people", label = "People", icon = "people", order = 40,
    build = function(book)
        local arr, tally = {}, {}
        for key, n in pairs(WFD.C.npcs) do
            if not n.obj then
                arr[#arr + 1] = { key = key, n = n }
                for role in pairs(n.roles or {}) do tally[role] = (tally[role] or 0) + 1 end
            end
        end
        table.sort(arr, function(a, b) return (a.n.name or "") < (b.n.name or "") end)
        local rows = { { h = 74, summary = true, total = #arr, tally = tally } }
        -- count per letter, for the headings
        local perLetter = {}
        for _, e in ipairs(arr) do
            local l = (e.n.name or "?"):match("^[%z\1-\127\194-\244][\128-\191]*") or "?"
            l = l:upper()
            e.letter = l
            perLetter[l] = (perLetter[l] or 0) + 1
        end
        local letter
        for _, e in ipairs(arr) do
            if e.letter ~= letter then
                letter = e.letter
                rows[#rows + 1] = { h = 34, letter = letter, count = perLetter[letter], keep = 30 }
            end
            rows[#rows + 1] = { h = 30, e = e }
        end
        if #arr == 0 then rows[#rows + 1] = { h = 40, empty = true } end
        paginateRows(book, "people", rows, { head = L["People"] })
    end,
})

UI:RegisterRenderer("people", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    title(pool, canvas, side, page, L["People"], L["Everyone I met on my way"])
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.summary then
            -- how many, and of which trade
            local big = pool:Text(30, c.ink, UI.HEAD)
            big:SetText(tostring(r.total))
            big:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
            local lab = pool:Text(9, c.inkSoft, UI.FONT)
            lab:SetText(L["People met"]:upper())
            lab:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 1, y - 34)
            local x = tx + tw
            for i = #ROLE_ORDER, 1, -1 do
                local role = ROLE_ORDER[i]
                local n = r.tally[role]
                if n and n > 0 and x - 36 > tx + 90 then
                    local cx = x - 15
                    local pl = pool:Plaque(cx, y - 12, 18, UI.IconPath(ROLE_ICONS[role]), { 0.72, 0.54, 0.22, 1 }, true)
                    local t = pool:Text(11, c.ink, UI.HEAD, "CENTER")
                    t:SetText(tostring(n))
                    t:SetPoint("TOP", pl, "BOTTOM", 0, -3)
                    local hot = pool:Hot({ WFD:RoleName(role), tostring(n) })
                    hot:SetPoint("CENTER", pl, "CENTER", 0, -8)
                    hot:SetSize(28, 40)
                    x = x - 34
                end
            end
            local rule = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0 }, { 0.78, 0.60, 0.26, 0.5 })
            rule:SetSize(tw, 1)
            rule:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 56)
        elseif r.empty then
            local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
            e:SetText(L["You have not talked to anyone yet."])
            e:SetWidth(tw)
            e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 10)
        elseif r.letter then
            -- the letter in gold on a faint gold tab, like a register
            local box = pool:Rect(c.redInk, 0.12)
            box:SetSize(22, 22)
            box:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 8)
            local l = pool:Text(18, c.redInk, UI.HEAD, "CENTER")
            l:SetText(r.letter)
            l:SetWidth(22)
            l:SetPoint("CENTER", box, "CENTER", 0, 0)
            local ln = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.5 }, { 0.91, 0.76, 0.42, 0.04 })
            ln:SetSize(tw - 30, 1)
            ln:SetPoint("LEFT", box, "RIGHT", 8, -6)
            local cnt = pool:Text(9, c.inkFaint, UI.FONT, "RIGHT")
            cnt:SetText(tostring(r.count))
            cnt:SetPoint("BOTTOMRIGHT", canvas, "TOPLEFT", tx + tw, y - 18)
        else
            local n = r.e.n
            local key = r.e.key
            local role = mainRole(n)
            local regular = (n.talks or 0) >= 10
            pool:Plaque(tx + 12, y - 14, 20, UI.IconPath(ROLE_ICONS[role]), regular and { 0.93, 0.73, 0.22, 1 } or { 0.66, 0.50, 0.28, 1 }, true)
            local nm = pool:Text(12, c.ink, UI.FONT)
            nm:SetText(n.name or "?")
            nm:SetWordWrap(false)
            nm:SetWidth(tw - 30 - 56)
            nm:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 3)
            local roles = {}
            for _, rr in ipairs(ROLE_ORDER) do
                if n.roles and n.roles[rr] and rr ~= "talk" then roles[#roles + 1] = WFD:RoleName(rr) end
            end
            local sub = pool:Text(9, c.inkFaint, UI.FONT)
            sub:SetText(table.concat(roles, ", ") .. ((#roles > 0 and n.zone) and "  -  " or "") .. (n.zone or ""))
            sub:SetWordWrap(false)
            sub:SetWidth(tw - 30 - 56)
            sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 30, y - 17)
            local talks = pool:Text(11, regular and c.redInk or c.inkSoft, UI.HEAD, "RIGHT")
            talks:SetText((n.talks or 0) .. "x")
            talks:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 3)
            local day = n.first and WFD:DayIndex(n.first)
            local _, ref = pageRef(UI.book, day)
            local pr = pool:Text(9, c.inkFaint, UI.FONT, "RIGHT")
            pr:SetText(ref)
            pr:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 17)
            local all = {}
            for rr in pairs(n.roles or {}) do all[#all + 1] = WFD:RoleName(rr) end
            table.sort(all)
            local hot = pool:Hot({ n.name or "?", table.concat(all, ", "), format(L["Spoken to %d times"], n.talks or 0),
                L["Click for the portrait."] }, function() UI:ShowCard("person", key) end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
            hot:SetSize(tw, r.h - 2)
        end
    end
end)

------------------------------------------------------------------------
-- Ledger (money): three tiles, where the coins came from and went to, the purse over the days,
-- then one line per day
------------------------------------------------------------------------
local CAT_ICONS = {
    loot = { "INV_Misc_Bag_08" }, quest = { "INV_Scroll_03" }, sell = { "INV_Misc_Coin_02" },
    mail = { "INV_Letter_15" }, trade = { "INV_Misc_Coin_03", "INV_Misc_Coin_01" }, ah = { "INV_Misc_Coin_01" },
    repair = { "Trade_BlackSmithing", "INV_Hammer_20", "INV_Pick_02" }, vendor = { "INV_Misc_Bag_10" },
    training = { "INV_Misc_Book_11", "INV_Misc_Book_09" },
    flight = { "Ability_Mount_Gryphon_01", "Ability_Mount_Wyvern_01", "Spell_Nature_Swiftness" },
    bank = { "INV_Misc_Bag_10" }, other = { "INV_Misc_QuestionMark" },
}

UI:RegisterSection({
    key = "ledger", label = "Ledger", icon = "stats", order = 50, leftStart = true,
    build = function(book)
        local C = WFD.C
        local days, saldo = {}, 0
        for day = 1, WFD:NumDays() do
            local d = C.days[day]
            if d then
                local inc, sp = WFD:Sum(d.income), WFD:Sum(d.spend)
                saldo = saldo + inc - sp
                days[#days + 1] = { day = day, inc = inc, sp = sp, saldo = saldo }
            end
        end
        book:Add({ kind = "ledgersum", numbered = true, head = L["Ledger"], days = days })
        -- a few telling figures for the top of the day list
        local facts
        if #days > 0 then
            local best, worst, net = nil, nil, 0
            for _, r in ipairs(days) do
                local n = r.inc - r.sp
                net = net + n
                if not best or n > best.n then best = { n = n, day = r.day } end
                if not worst or n < worst.n then worst = { n = n, day = r.day } end
            end
            facts = { best = best, worst = worst, avg = net / #days }
        end
        local page, y = nil, 0
        local HEAD_H, FACTS_H = 34, 60
        for i, r in ipairs(days) do
            if not page or y + 26 > UI.AREA_H then
                local first = page == nil
                page = book:Add({ kind = "ledger", rows = {}, numbered = true, head = L["Ledger"], facts = first and facts or nil })
                y = HEAD_H + (first and FACTS_H or 0)
            end
            page.rows[#page.rows + 1] = { y = y, h = 26, d = r, alt = (i % 2 == 0) }
            y = y + 26
        end
        if not page then book:Add({ kind = "ledger", rows = {}, numbered = true, head = L["Ledger"], empty = true }) end
    end,
})

-- The purse over the days: a dark panel with a soft area under a glowing line,
-- gold while there is money, red below zero; the last day stands out with its value.
local function purseChart(pool, canvas, x, y, w, h, days)
    local n = #days
    if n == 0 then return end
    -- at most about 60 points, the last day always included
    local step = math.ceil(n / 60)
    local pts = {}
    for i = 1, n, step do pts[#pts + 1] = days[i] end
    if pts[#pts] ~= days[n] then pts[#pts + 1] = days[n] end
    local np = #pts
    local hi, lo = 0, 0
    for _, r in ipairs(pts) do
        if r.saldo > hi then hi = r.saldo end
        if r.saldo < lo then lo = r.saldo end
    end
    local span = max(1, hi - lo)
    local top, bottom = hi + span * 0.15, lo - (lo < 0 and span * 0.12 or 0)
    local range = max(1, top - bottom)

    local GOLD_C = { 0.95, 0.76, 0.36 }
    local RED_C = { 0.90, 0.40, 0.30 }

    -- the panel: darker than the page, a fine gold frame
    local panel = pool:Rect({ 0.04, 0.025, 0.015 }, 0.55)
    panel:SetSize(w, h)
    panel:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    local shine = pool:Grad("VERTICAL", { 1, 0.85, 0.55, 0 }, { 1, 0.85, 0.55, 0.05 })
    shine:SetSize(w, h * 0.5)
    shine:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    for _, e in ipairs({ { 0, 0, w, 1 }, { 0, -h + 1, w, 1 }, { 0, 0, 1, h }, { w - 1, 0, 1, h } }) do
        local r = pool:Rect(c.redInk, 0.30)
        r:SetSize(e[3], e[4])
        r:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + e[1], y + e[2])
    end

    local PL, PR, PT, PB = 10, 14, 18, 10
    local ix, iw, iy, ih = x + PL, w - PL - PR, y - PT, h - PT - PB
    local function py(v) return iy - ih * (top - v) / range end
    local function px(i) return np == 1 and (ix + iw / 2) or (ix + (i - 1) / (np - 1) * iw) end
    local zeroY = py(0)

    -- guide lines with their values on the left
    for g = 0, 3 do
        local v = bottom + (top - bottom) * (g + 0.5) / 4
        local gy = py(v)
        local gl = pool:Rect(c.redInk, 0.07)
        gl:SetSize(iw, 1)
        gl:SetPoint("TOPLEFT", canvas, "TOPLEFT", ix, gy)
    end
    local maxLabel = pool:Text(9, c.inkSoft, UI.FONT)
    maxLabel:SetText(UI.CoinIcons(hi, 9))
    maxLabel:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", ix, py(hi) + 3)
    local hiLine = pool:Rect(c.redInk, 0.18)
    hiLine:SetSize(iw, 1)
    hiLine:SetPoint("TOPLEFT", canvas, "TOPLEFT", ix, py(hi))

    -- the soft area between the line and zero, in thin vertical slices
    local function valueAt(sx)
        if np == 1 then return pts[1].saldo end
        local f = sx / iw * (np - 1)
        local i = math.min(np - 1, floor(f))
        local t = f - i
        return pts[i + 1].saldo + (pts[i + 2].saldo - pts[i + 1].saldo) * t
    end
    local SW = 3
    for sx = 0, iw - 1, SW do
        local v = valueAt(math.min(iw, sx + SW / 2))
        local ly = py(v)
        local hgt = math.abs(ly - zeroY)
        if hgt >= 1 then
            local g
            if v >= 0 then
                g = pool:Grad("VERTICAL", { GOLD_C[1], GOLD_C[2], GOLD_C[3], 0.03 }, { GOLD_C[1], GOLD_C[2], GOLD_C[3], 0.30 }, "ARTWORK", 0)
                g:SetPoint("BOTTOMLEFT", canvas, "TOPLEFT", ix + sx, zeroY)
            else
                g = pool:Grad("VERTICAL", { RED_C[1], RED_C[2], RED_C[3], 0.30 }, { RED_C[1], RED_C[2], RED_C[3], 0.03 }, "ARTWORK", 0)
                g:SetPoint("TOPLEFT", canvas, "TOPLEFT", ix + sx, zeroY)
            end
            g:SetSize(math.min(SW, iw - sx), hgt)
        end
    end
    -- zero: a firm line, labelled when the purse went below it
    local zero = pool:Rect(c.inkSoft, lo < 0 and 0.55 or 0.35)
    zero:SetSize(iw, 1)
    zero:SetPoint("TOPLEFT", canvas, "TOPLEFT", ix, zeroY)
    if lo < 0 then
        local zl = pool:Text(9, c.inkFaint, UI.FONT, "RIGHT")
        zl:SetText("0")
        zl:SetPoint("RIGHT", canvas, "TOPLEFT", ix - 2, zeroY)
    end

    -- the line: a soft glow under a crisp stroke
    for i = 2, np do
        local a, b = pts[i - 1].saldo, pts[i].saldo
        local col = (a >= 0 and b >= 0) and GOLD_C or RED_C
        pool:Line(px(i - 1), py(a), px(i), py(b), col, 0.16, 7)
        pool:Line(px(i - 1), py(a), px(i), py(b), col, 1, 2)
    end
    -- small dots on the days (when there is room), the last day larger, with its value
    for i, r in ipairs(pts) do
        local col = r.saldo >= 0 and GOLD_C or RED_C
        if i == np then
            local glow = pool:Circle(18, { col[1], col[2], col[3], 0.22 }, "ARTWORK", 5)
            glow:SetPoint("CENTER", canvas, "TOPLEFT", px(i), py(r.saldo))
            local rim = pool:Circle(9, { 0.08, 0.05, 0.02, 1 }, "ARTWORK", 6)
            rim:SetPoint("CENTER", canvas, "TOPLEFT", px(i), py(r.saldo))
            local dot = pool:Circle(6, { col[1], col[2], col[3], 1 }, "ARTWORK", 7)
            dot:SetPoint("CENTER", canvas, "TOPLEFT", px(i), py(r.saldo))
        elseif np <= 30 then
            local rim = pool:Circle(6, { 0.08, 0.05, 0.02, 1 }, "ARTWORK", 6)
            rim:SetPoint("CENTER", canvas, "TOPLEFT", px(i), py(r.saldo))
            local dot = pool:Circle(4, { col[1], col[2], col[3], 1 }, "ARTWORK", 7)
            dot:SetPoint("CENTER", canvas, "TOPLEFT", px(i), py(r.saldo))
        end
        -- hover: the day and its balance
        local x0 = (i == 1) and ix or (px(i - 1) + px(i)) / 2
        local x1 = (i == np) and (ix + iw) or (px(i) + px(i + 1)) / 2
        local hot = pool:Hot({ format(L["Day %d"], r.day) .. "  -  " .. WFD:DateStr(r.day),
            L["Balance"] .. ": " .. (r.saldo < 0 and "-" or "") .. UI.CoinIcons(r.saldo, 12) })
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x0, y)
        hot:SetSize(max(2, x1 - x0), h)
        hot.hl:SetAlpha(0.05)
    end
    local last = pts[np]
    local lv = pool:Text(11, last.saldo < 0 and c.bad or c.ink, UI.FONT, "RIGHT")
    lv:SetText((last.saldo < 0 and "-" or "") .. UI.CoinIcons(last.saldo, 11))
    local ly = py(last.saldo)
    -- the value sits above the last dot, or below it when the dot is near the top
    if ly > y - 26 then
        lv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x + w - 4, ly - 9)
    else
        lv:SetPoint("BOTTOMRIGHT", canvas, "TOPLEFT", x + w - 4, ly + 9)
    end

    -- days along the bottom: first, middle and last, with small ticks
    local marks = { 1 }
    if np >= 5 then marks[#marks + 1] = floor((np + 1) / 2) end
    if np > 1 then marks[#marks + 1] = np end
    for k, i in ipairs(marks) do
        local tick = pool:Rect(c.redInk, 0.45)
        tick:SetSize(1, 4)
        tick:SetPoint("TOPLEFT", canvas, "TOPLEFT", px(i), y - h)
        local just = (k == 1) and "LEFT" or ((i == np) and "RIGHT" or "CENTER")
        local t = pool:Text(9, c.inkFaint, UI.FONT, just)
        t:SetText(format(L["Day %d"], pts[i].day))
        local anchor = (just == "LEFT") and "TOPLEFT" or ((just == "RIGHT") and "TOPRIGHT" or "TOP")
        local ax = (just == "LEFT") and x or ((just == "RIGHT") and (x + w) or px(i))
        t:SetPoint(anchor, canvas, "TOPLEFT", ax, y - h - 5)
    end
end

UI:RegisterRenderer("ledgersum", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Ledger"], L["Every coin, in and out"], -56)
    local t = WFD:Totals()
    local bal = t.income - t.spend

    -- three tiles
    local tileW = (tw - 16) / 3
    local tiles = {
        { L["Income"], "+" .. UI.CoinIcons(t.income, 12), GREEN },
        { L["Expenses"], "-" .. UI.CoinIcons(t.spend, 12), c.bad },
        { L["Balance"], (bal < 0 and "-" or "") .. UI.CoinIcons(bal, 12), bal < 0 and c.bad or c.ink },
    }
    for i, def in ipairs(tiles) do
        local x = tx + (i - 1) * (tileW + 8)
        local bg = pool:Rect(c.paperDk, 0.45)
        bg:SetSize(tileW, 48)
        bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
        local bar = pool:Rect(def[3], 0.9)
        bar:SetSize(tileW, 2)
        bar:SetPoint("TOPLEFT", bg, "TOPLEFT")
        local lab = pool:Text(9, def[3], UI.FONT, "CENTER")
        lab:SetText(def[1]:upper())
        lab:SetWidth(tileW)
        lab:SetPoint("TOP", bg, "TOP", 0, -9)
        local v = pool:Text(13, c.ink, UI.FONT, "CENTER")
        v:SetText(def[2])
        v:SetWidth(tileW)
        v:SetWordWrap(false)
        v:SetPoint("TOP", lab, "BOTTOM", 0, -6)
    end
    y = y - 64

    -- where it came from, where it went
    local inc, spend = {}, {}
    for _, day in pairs(C.days) do
        for cat, v in pairs(day.income) do inc[cat] = (inc[cat] or 0) + v end
        for cat, v in pairs(day.spend) do spend[cat] = (spend[cat] or 0) + v end
    end
    local colW = (tw - 20) / 2
    for ci, def in ipairs({ { L["Came from"], inc, GREEN }, { L["Went to"], spend, c.bad } }) do
        local x = tx + (ci - 1) * (colW + 20)
        local h = pool:Text(9, def[3], UI.FONT)
        h:SetText(def[1]:upper())
        h:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
        local list, total = {}, 0
        for _, cat in ipairs(WFD.moneyCats) do
            local v = def[2][cat]
            if v and v > 0 then list[#list + 1] = { cat = cat, v = v }; total = total + v end
        end
        table.sort(list, function(a, b) return a.v > b.v end)
        for i = 1, min(4, #list) do
            local e = list[i]
            local ry = y - 16 - (i - 1) * 30
            local ic = pool:Icon(UI.IconPath(CAT_ICONS[e.cat], "coin"), 20)
            ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, ry - 2)
            local n = pool:Text(12, c.ink, UI.FONT)
            n:SetText(WFD:CatName(e.cat))
            n:SetWordWrap(false)
            n:SetWidth(colW - 26 - 32)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 26, ry - 2)
            local pc = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
            pc:SetText(floor(e.v * 100 / max(1, total) + 0.5) .. "%")
            pc:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x + colW, ry - 3)
            UI.ProgressBar(pool, canvas, x + 26, ry - 18, colW - 26, 4, e.v / list[1].v, def[3])
            hotRow(pool, canvas, x, ry, colW, 26, { WFD:CatName(e.cat), UI.CoinIcons(e.v, 12) })
        end
        if #list == 0 then
            local n = pool:Text(12, c.inkFaint, UI.FONT)
            n:SetText("-")
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y - 18)
        end
    end
    y = y - 16 - 4 * 30 - 8

    -- the purse over the days
    local cap = pool:Text(9, c.redInk, UI.FONT)
    cap:SetText(L["The purse over the days"]:upper())
    cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    local chartTop = y - 26
    local chartH = max(40, (UI.PH - UI.BOTTOM) + chartTop - 18)
    purseChart(pool, canvas, tx, chartTop, tw, chartH, page.days or {})
end)

UI:RegisterRenderer("ledger", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local top = -UI.TOP
    local rowTop = top        -- row positions already leave room for the figures above the list
    local R = { tx + 100, tx + 190, tx + 276, tx + tw }      -- right edges of the four columns
    -- best day, worst day and the average, above the list on its first page
    local f = page.facts
    if f then
        local function signed(v) return (v < 0 and "-" or "+") .. UI.CoinIcons(v, 12) end
        UI.Tiles(pool, canvas, tx, top, tw, {
            { signed(f.best.n), format(L["Best day: day %d"], f.best.day), f.best.n >= 0 and c.good or c.bad,
              UI.book.dayPage[f.best.day] and function() UI:GoToPage(UI.book.dayPage[f.best.day]) end },
            { signed(f.worst.n), format(L["Worst day: day %d"], f.worst.day), f.worst.n >= 0 and c.good or c.bad,
              UI.book.dayPage[f.worst.day] and function() UI:GoToPage(UI.book.dayPage[f.worst.day]) end },
            { signed(f.avg), L["Per day"], f.avg >= 0 and c.good or c.bad },
        })
        top = top - 60
    end
    local heads = { L["Day"], L["Income"], L["Expenses"], L["Balance"] }
    for i, h in ipairs(heads) do
        local t = pool:Text(9, c.redInk, UI.FONT, i == 1 and "LEFT" or "RIGHT")
        t:SetText(h:upper())
        if i == 1 then
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, top - 10)
        else
            t:SetPoint("TOPRIGHT", canvas, "TOPLEFT", R[i] - 4, top - 10)
        end
    end
    local r1 = pool:Rect(c.redInk, 0.7)
    r1:SetSize(tw, 1)
    r1:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, top - 25)
    local r2 = pool:Rect(c.redInk, 0.35)
    r2:SetSize(tw, 1)
    r2:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, top - 28)
    if page.empty then
        local e = pool:Text(13, c.inkFaint, UI.FONT, "CENTER")
        e:SetText("-")
        e:SetWidth(tw)
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, top - 50)
        return
    end
    local C = WFD.C
    for _, r in ipairs(page.rows) do
        local y = rowTop - r.y
        local d = r.d
        if r.alt then
            local band = pool:Rect(c.paperDk, 0.35)
            band:SetSize(tw, r.h)
            band:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        end
        -- a small diamond: green for a day with profit, red for a loss
        local net = d.inc - d.sp
        local mark = pool:Diamond(6, net > 0 and c.good or (net < 0 and c.bad or c.inkFaint))
        mark:SetPoint("CENTER", canvas, "TOPLEFT", tx + 6, y - 13)
        local dn = pool:Text(12, c.ink, UI.FONT)
        dn:SetText(format(L["Day %d"], d.day))
        dn:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 14, y - 7)
        local dt = pool:Text(9, c.inkFaint, UI.FONT)
        dt:SetText(date(WFD.loc.dayMonth, WFD:DayTime(d.day)))
        dt:SetPoint("BOTTOMLEFT", dn, "BOTTOMRIGHT", 6, 1)
        local vals = {
            { d.inc, d.inc > 0 and GREEN or c.inkFaint, d.inc > 0 and ("+" .. UI.CoinIcons(d.inc, 10)) or "-" },
            { d.sp, d.sp > 0 and c.bad or c.inkFaint, d.sp > 0 and ("-" .. UI.CoinIcons(d.sp, 10)) or "-" },
            { d.saldo, d.saldo < 0 and c.bad or c.ink, (d.saldo < 0 and "-" or "") .. UI.CoinIcons(d.saldo, 11) },
        }
        for i, v in ipairs(vals) do
            local t = pool:Text(i == 3 and 12 or 11, v[2], UI.FONT, "RIGHT")
            t:SetText(v[3])
            t:SetPoint("TOPRIGHT", canvas, "TOPLEFT", R[i + 1] - 4, y - 7)
        end
        -- tooltip: the day's money by category
        local day = C.days[d.day]
        local lines = { format(L["Day %d"], d.day) .. "  -  " .. WFD:DateStr(d.day) }
        if day then
            for _, cat in ipairs(WFD.moneyCats) do
                local a, b = day.income[cat], day.spend[cat]
                if a and a > 0 then lines[#lines + 1] = "|cff60c060+" .. UI.CoinIcons(a, 11) .. "|r  " .. WFD:CatName(cat) end
                if b and b > 0 then lines[#lines + 1] = "|cffe06050-" .. UI.CoinIcons(b, 11) .. "|r  " .. WFD:CatName(cat) end
            end
        end
        lines[#lines + 1] = L["Click to read this day."]
        local p = UI.book.dayPage[d.day]
        hotRow(pool, canvas, tx, y, tw, r.h, lines, p and function() UI:GoToPage(p) end)
    end
end)

------------------------------------------------------------------------
-- Quest book: grouped by region, in the order the regions were reached
------------------------------------------------------------------------
UI:RegisterSection({
    key = "quests", label = "Quest Book", icon = "quests", order = 60,
    build = function(book)
        local zones, byZone = {}, {}
        local done, open, gaveUp = 0, 0, 0
        for id, q in pairs(WFD.C.quests) do
            local z = q.zone or L["Already in the quest log"]
            local e = byZone[z]
            if not e then
                e = { zone = z, list = {}, t = math.huge, done = 0 }
                byZone[z] = e
                zones[#zones + 1] = e
            end
            e.list[#e.list + 1] = { id = id, q = q }
            local t = q.acc or q.done or 0
            if t < e.t then e.t = t end
            if q.done then
                e.done = e.done + 1
                done = done + 1
            elseif q.abandoned then
                gaveUp = gaveUp + 1
            else
                open = open + 1
            end
        end
        table.sort(zones, function(a, b) return a.t < b.t end)
        local list = { { h = 58, summary = true, done = done, open = open, gaveUp = gaveUp } }
        if #zones == 0 then list[#list + 1] = { h = 40, empty = true } end
        for _, z in ipairs(zones) do
            table.sort(z.list, function(a, b) return (a.q.acc or a.q.done or 0) < (b.q.acc or b.q.done or 0) end)
            list[#list + 1] = { h = 36, header = z.zone, count = z.done .. " / " .. #z.list, keep = 24 }
            for _, e in ipairs(z.list) do list[#list + 1] = { h = 24, id = e.id, q = e.q } end
        end
        paginateRows(book, "quests", list, { head = L["Quest Book"] })
    end,
})

UI:RegisterRenderer("quests", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    title(pool, canvas, side, page, L["Quest Book"], L["Tasks taken and done"])
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.summary then
            -- three counters: done, open, given up
            local stats = { { r.done, L["done"], GREEN }, { r.open, L["open"], c.ink }, { r.gaveUp, L["given up"], c.bad } }
            local w3 = tw / 3
            for i, s in ipairs(stats) do
                local cx = tx + w3 * (i - 0.5)
                local n = pool:Text(24, s[3], UI.HEAD, "CENTER")
                n:SetText(tostring(s[1]))
                n:SetPoint("TOP", canvas, "TOPLEFT", cx, y - 2)
                local l = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
                l:SetText(s[2]:upper())
                l:SetPoint("TOP", canvas, "TOPLEFT", cx, y - 32)
                if i > 1 then
                    local sep = pool:Diamond(5, c.inkFaint)
                    sep:SetPoint("CENTER", canvas, "TOPLEFT", tx + w3 * (i - 1), y - 20)
                end
            end
        elseif r.empty then
            local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
            e:SetText(L["No quests recorded yet."])
            e:SetWidth(tw)
            e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 10)
        elseif r.header then
            UI.SectionHead(pool, canvas, tx, tw, y, r.h, r.header, r.count)
        else
            local q = r.q
            local box = pool:Rect(c.inkSoft, 0.9)
            box:SetSize(13, 13)
            box:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 5)
            local inner = pool:Rect({ 0.10, 0.07, 0.04 }, 1, "ARTWORK", 1)
            inner:SetSize(11, 11)
            inner:SetPoint("CENTER", box, "CENTER")
            if q.done then
                local tick = pool:Icon("Interface\\Buttons\\UI-CheckBox-Check", 22, "ARTWORK", 2)
                tick:SetTexCoord(0, 1, 0, 1)
                tick:SetVertexColor(0.95, 0.80, 0.40, 1)
                tick:SetPoint("CENTER", box, "CENTER", 2, 2)
            elseif q.abandoned then
                local x = pool:Text(15, c.bad, UI.FONT, "CENTER")
                x:SetText("x")
                x:SetPoint("CENTER", box, "CENTER", 0, -2)
            end
            local giver = q.giver and C.npcs[q.giver]
            local t = pool:Text(12, q.abandoned and c.inkFaint or c.ink, UI.FONT)
            t:SetText((q.title or ("#" .. r.id)) .. (giver and ("  |cffc2a880" .. giver.name .. "|r") or ""))
            t:SetWidth(tw - 26 - 44)
            t:SetWordWrap(false)
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 26, y - 5)
            local day = (q.done or q.acc) and WFD:DayIndex(q.done or q.acc)
            local p, ref = pageRef(UI.book, day)
            local pr = pool:Text(10, c.inkFaint, UI.FONT, "RIGHT")
            pr:SetText(ref)
            pr:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 6)
            local lines = { q.title or "?" }
            if giver then lines[#lines + 1] = L["Received from"] .. ": " .. giver.name end
            if q.xp and q.xp > 0 then lines[#lines + 1] = "+" .. q.xp .. " XP" end
            if q.done and q.acc and q.done >= q.acc then lines[#lines + 1] = L["Took"] .. ": " .. WFD:DurationText(q.done - q.acc) end
            hotRow(pool, canvas, tx, y, tw, r.h, lines, p and function() UI:GoToPage(p) end, q.reward)
        end
    end
end)

------------------------------------------------------------------------
-- The scribe's notes: settings and transcript
------------------------------------------------------------------------
UI:RegisterSection({
    key = "notes", label = "Scribe's notes", icon = "settings", order = 90,
    build = function(book)
        book:Add({ kind = "settings", numbered = true, head = L["Scribe's notes"] })
        book:Add({ kind = "handling", numbered = true, head = L["Scribe's notes"] })
        book:Add({ kind = "appearance", numbered = true, head = L["Scribe's notes"] })
    end,
})

-- languages the diary can be read in (names are translated into the current language)
local LANG_NAMES = {
    deDE = "German", enUS = "English", enGB = "English", frFR = "French", esES = "Spanish", esMX = "Spanish",
    ptBR = "Portuguese", ruRU = "Russian", koKR = "Korean", zhTW = "Chinese (traditional)",
}
local DEFAULT_LANGS = { "deDE", "enUS", "frFR", "esES", "ptBR", "ruRU", "koKR", "zhTW" }

local function gameLanguage()
    return WFD.GetGameLanguage and WFD:GetGameLanguage() or GetLocale()
end

local function setLanguage(code)
    WFDiaryDB.language = code    -- nil = follow the game
    ReloadUI()
end

UI:RegisterRenderer("settings", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Scribe's notes"], L["How this book is kept"], -56)
    local S = WFD.S

    local function caption(text)
        local t = pool:Text(10, c.redInk, UI.FONT)
        t:SetText(text:upper())
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - 18
    end
    -- a row of ink links that wraps onto the next line
    local function linkRow(items, size)
        local x = tx
        for _, it in ipairs(items) do
            local fs = pool:Link(it.text, it.fn, size or 14, it.active and c.redInk or c.inkSoft)
            local w = fs:GetStringWidth()
            if x > tx and x + w > tx + tw then
                x = tx
                y = y - 20
            end
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
            if it.active then
                local u = pool:Rect(c.redInk, 1)
                u:SetSize(w, 1)
                u:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
            end
            x = x + w + 16
        end
        y = y - 22
    end

    -- switches
    local checks = {
        { L["Take a screenshot at milestones"], "screenshots" },
        { L["Announce milestones in chat"], "chat" },
        { L["Show minimap button"], "minimap", function() UI:UpdateMinimapButton() end },
        { L["Show a note for new discoveries"], "toasts" },
        { L["Weekly look back at login"], "recap" },
    }
    for _, ch in ipairs(checks) do
        local cb = pool:Check(ch[1], function() return S[ch[2]] end, function(v)
            S[ch[2]] = v
            if ch[3] then ch[3]() end
        end)
        cb:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - 21
    end
    y = y - 6

    -- language
    caption(L["Language"])
    local chosen = WFDiaryDB and WFDiaryDB.language
    local game = gameLanguage()
    local items = { {
        text = format(L["Game language (%s)"], L[LANG_NAMES[game] or game]),
        active = chosen == nil,
        fn = function() if chosen ~= nil then setLanguage(nil) end end,
    } }
    for _, code in ipairs(WFD.languages or DEFAULT_LANGS) do
        items[#items + 1] = {
            text = L[LANG_NAMES[code] or code],
            active = chosen == code,
            fn = function() if chosen ~= code then setLanguage(code) end end,
        }
    end
    linkRow(items, 13)
    local note = pool:Text(11, c.inkSoft, UI.FONT)
    note:SetWidth(tw)
    note:SetText(L["The diary will reload the interface to switch the language."] .. " "
        .. L["Korean and Chinese text needs a game client with those fonts."])
    note:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 4)
    y = y - note:GetStringHeight() - 10

    -- size
    caption(L["Size of the book"])
    local sizes = {}
    -- a size set with Ctrl + mouse wheel joins the row, so the current one is always marked
    local cur, steps = S.scale or 0.9, { 0.75, 0.8, 0.9, 1, 1.1 }
    local known = false
    for _, s in ipairs(steps) do if math.abs(cur - s) < 0.001 then known = true end end
    if not known then
        steps[#steps + 1] = cur
        table.sort(steps)
    end
    for _, s in ipairs(steps) do
        sizes[#sizes + 1] = {
            text = floor(s * 100 + 0.5) .. "%",
            active = math.abs(cur - s) < 0.001,
            fn = function()
                UI:SetScale(s)
                UI:ShowSpread(UI.spread)
            end,
        }
    end
    linkRow(sizes, 14)

    -- transcript and demo
    caption(L["Transcript"] .. "  &  " .. L["Demo"])
    local t1 = pool:Link(L["Copy the diary as text"] .. "  >", function() UI:ShowTranscript("text") end, 14)
    t1:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    local t2 = pool:Link(L["Copy the diary as JSON"] .. "  >", function() UI:ShowTranscript("json") end, 14)
    t2:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 18)
    local t3 = pool:Link(L["Copy for forum or Discord (Markdown)"] .. "  >", function() UI:ShowTranscript("markdown") end, 14)
    t3:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 36)
    local dl = pool:Link((WFD.demo and L["Leave demo mode"] or L["Start demo mode"]) .. "  >", function() WFD:ToggleDemo() end, 14)
    dl:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 54)
end)
