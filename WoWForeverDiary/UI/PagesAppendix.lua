-- Appendix at the back of the book: milestones, maps, bestiary, people register, ledger, quests, notes.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format

local GREEN = UI.c.good

local function pageRef(book, day)
    local p = day and book.dayPage[day]
    return p, p and format(L["p. %d"], UI.PageNumber(p)) or ""
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
        -- the honours of a day are many small steps: two or more of them make one line, so the great moments
        -- (a level, a death, a find) are not lost among them
        local honoursOf = {}
        for _, ev in ipairs(evs) do
            if ev.k == "honour" and ev.day then
                honoursOf[ev.day] = honoursOf[ev.day] or {}
                table.insert(honoursOf[ev.day], ev)
            end
        end
        local lastDay
        for _, ev in ipairs(evs) do
            if ev.day and ev.day ~= lastDay then
                lastDay = ev.day
                rows[#rows + 1] = { h = 34, dayHead = ev.day, t = ev.t, keep = 50 }
            end
            local group = ev.k == "honour" and ev.day and honoursOf[ev.day]
            if group and #group > 1 then
                if group[1] == ev then rows[#rows + 1] = { h = 50, ev = ev, honours = group } end
            else
                rows[#rows + 1] = { h = 50, ev = ev }
            end
        end
        if #rows == 0 then rows[1] = { h = 40, empty = true } end
        -- a page that begins in the middle of a day repeats that day's heading
        book:AddRows("timeline", rows, { head = L["Milestones"] }, function(r)
            if r.ev and r.ev.day then return { h = 34, dayHead = r.ev.day, cont = true } end
        end)
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
            d:SetText(WFD:LongDate(r.dayHead) .. (r.cont and ("  |cff" .. UI.Hex(c.inkFaint) .. "(" .. L["continued"] .. ")|r") or ""))
            d:SetWordWrap(false)
            d:SetPoint("LEFT", chip, "RIGHT", 8, 0)
            local ln = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.45 }, { 0.91, 0.76, 0.42, 0 })
            ln:SetSize(max(10, tx + tw - (SX - 22 + cw + 16 + d:GetStringWidth())), 1)
            ln:SetPoint("LEFT", d, "RIGHT", 8, 0)
        else
            local ev = r.ev
            local lvl = ev.k == "level" and ev.s and ev.s:match("(%d+)")
            -- the moment's icon in a frame of its colour (an honour its own icon and metal, a find the item)
            local icon, col = UI.MomentIcon(ev)
            pool:Plaque(SX, y - 20, 28, icon, col, true, lvl)
            local tm = pool:Text(10, c.inkFaint, UI.FONT)
            tm:SetText(date("%H:%M", ev.t))
            tm:SetPoint("TOPLEFT", canvas, "TOPLEFT", SX + 28, y - 6)
            local text, lines = ev.s, { ev.s, date(WFD.loc.date .. " %H:%M", ev.t) }
            if r.honours then
                -- the honours of the day in one line: their names, each with its metal; the tooltip has them all
                local names = {}
                lines = { WFD:Count("%d honours earned: %s", #r.honours, "") }
                for _, h in ipairs(r.honours) do
                    local def = h.honour and WFD:HonourDef(h.honour)
                    local name = def and L[def.name] or (h.s and h.s:match(":%s*(.+)$")) or "?"
                    if def and #def.tiers > 1 then name = name .. " (" .. L[WFD:MetalOf(h.tier or 1, #def.tiers).name] .. ")" end
                    names[#names + 1] = name
                    lines[#lines + 1] = date("%H:%M", h.t) .. "  " .. name
                end
                -- as many names as two lines hold, the rest counted
                local W = tw - (SX - tx) - 28 - 44
                local function fits(t) return UI.Measure(t, UI.FS(13), W, 0, UI.FONT) <= UI.FS(13) * 2.6 end
                local shown = #names
                text = WFD:Count("%d honours earned: %s", #r.honours, table.concat(names, ", "))
                while shown > 1 and not fits(text) do
                    shown = shown - 1
                    text = WFD:Count("%d honours earned: %s", #r.honours,
                        table.concat(names, ", ", 1, shown) .. "  +" .. (#names - shown))
                end
            end
            local t = pool:Text(13, c.ink, UI.FONT)
            t:SetText(text)
            t:SetWidth(tw - (SX - tx) - 28 - 44)
            if t.SetMaxLines then t:SetMaxLines(2) end
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", SX + 28, y - 19)
            local p, ref = pageRef(UI.book, ev.day)
            local pr = pool:Text(11, c.inkFaint, UI.FONT, "RIGHT")
            pr:SetText(ref)
            pr:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 6)
            if ev.shot and not r.honours then lines[#lines + 1] = L["Screenshot:"] .. " " .. ev.shot end
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
        for _, e in pairs(t) do
            -- a whole continent (seen from a flight, its map open) is no area with a chronicle of its own
            local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(e.id)
            if not (info and info.mapType and info.mapType <= 2) then list[#list + 1] = e end
        end
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
    local sym = { { L["Route"], { 0.55, 0.08, 0.05, 1 } }, { L["Kill sites"], { 0.30, 0.42, 0.86, 1 } } }
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
        -- a grave: the day beside the word, the killer below (both together are too long for the narrow column)
        t:SetText(grave and (L["Grave"] .. "  -  " .. format(L["Day %d"], it.day or 0)) or (it.name or "?"))
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 27, ly - 2)
        local subText
        if grave then
            subText = it.by and format(L["Killed by %s"], it.by) or L["You died here"]
        else
            local npc = C.npcs[it.key]
            local roles = {}
            for role in pairs(npc and npc.roles or {}) do roles[#roles + 1] = WFD:RoleName(role) end
            table.sort(roles)
            subText = roles[1] or WFD:Count("Spoken to %d times", npc and npc.talks or 0)
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
            hot = pool:Hot({ L["You died here"], format(L["Day %d"], it.day), it.by and format(L["Killed by %s"], it.by) or nil },
                p and function() UI:GoToPage(p) end)
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
    -- the area in eight figures (two rows; a row grows when a caption needs two lines)
    local h1 = UI.Tiles(pool, canvas, tx, y, tw, {
        { WFD:DurationText(e.sec), L["Time spent"], c.ink },
        { z and z.visits or 1, L["Visits"], c.ink },
        { e.kills, L["Kills"], c.ink },
        { quests, L["Quests"], c.ink },
    })
    local h2 = UI.Tiles(pool, canvas, tx, y - h1 - 8, tw, {
        { format(L["Day %d"], e.first), L["First visit"], c.redInk, go(p) },
        { people, L["Acquaintances here"], c.ink },
        { rests, L["Times rested here"], c.ink },
        { deaths, L["Deaths here"], deaths > 0 and c.bad or c.ink },
    })
    y = y - h1 - h2 - 28

    -- the most hunted creatures of this area, as a small ranking
    local mobs = {}
    for id, m in pairs(C.mobs) do if m.zone == e.zone then mobs[#mobs + 1] = { id = id, m = m } end end
    table.sort(mobs, function(a, b) return a.m.kills > b.m.kills end)
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Most hunted here"], tostring(#mobs))
    y = y - 20
    if #mobs == 0 then
        local n = pool:Text(12, c.inkFaint, UI.FONT)
        n:SetText(L["Nothing slain here yet."])
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
        local hot = pool:Hot({ mob.m.name or "?", WFD:Count("Slain %d times", mob.m.kills), L["Click for the wanted poster."] },
            function() UI:ShowCard("creature", mob.id) end)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
        -- the row is as tall as its writing (the writing grows with the size chosen in the settings)
        local rowH = max(22, n:GetStringHeight() + 9)
        hot:SetSize(tw, rowH - 2)
        y = y - rowH
    end

    -- places discovered
    y = y - 10
    local subs = {}
    if z and z.sub then
        for name, t in pairs(z.sub) do subs[#subs + 1] = { name = name, t = t } end
        table.sort(subs, function(a, b) return a.t < b.t end)
    end
    UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Places discovered"], tostring(#subs))
    y = y - 22
    if #subs == 0 then
        local n = pool:Text(12, c.inkFaint, UI.FONT)
        n:SetText(L["No places discovered here yet."])
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
UI.BESTIARY_RARITY, UI.RarityOf, UI.LevelText = RARITY, rarityOf, levelText
local RARITY_TAG = { elite = "Elite", rare = "Rare", boss = "Boss" }
local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"

local TIERS = {           -- collector ranks of the bestiary (also shown on the collection page)
    { 10, "Bronze", { 0.70, 0.42, 0.20, 1 } }, { 25, "Silver", { 0.70, 0.72, 0.76, 1 } },
    { 50, "Gold", { 0.92, 0.72, 0.22, 1 } }, { 100, "Mithril", { 0.45, 0.70, 0.85, 1 } },
    { 200, "Legend", { 0.62, 0.22, 0.70, 1 } },
}
UI.BESTIARY_TIERS = TIERS
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

-- The album itself is a view of the travel desk now (UI/Views/Albums.lua). The book keeps the hunting grounds:
-- one map per area, where each kind was slain (until the map of the world takes them in).
UI:RegisterSection({
    key = "huntgrounds", label = "Hunting grounds", icon = "atlas", order = 30,
    enabled = function() return next(WFD.C.mobs) ~= nil end,
    build = function(book)
        local arr = collection()
        local zones, byZone = {}, {}
        for _, e in ipairs(arr) do
            local z = e.m.zone or "?"
            if not byZone[z] then
                byZone[z] = {}
                zones[#zones + 1] = z
            end
            table.insert(byZone[z], e)
        end
        local grounds = {}
        for _, z in ipairs(zones) do
            local map = mapOfZone(z, byZone[z])
            if map then grounds[#grounds + 1] = { zone = z, map = map } end
        end
        book.huntZones = {}
        if #grounds > 0 then
            book.huntPage = book:Add({ kind = "huntmap", numbered = true, head = L["Hunting grounds"], grounds = grounds }).index
            for _, g in ipairs(grounds) do book.huntZones[g.zone] = true end
        end
    end,
})

-- for the album on the travel desk: the creatures in album order, and the places worth a second look
UI.BestiaryCollection = collection
UI.QuietCorners = function(z, list) return quietCorners(mapOfZone(z, list or {})) end

-- Where a long word may be broken: between syllables, as Latin writing does it - before a single consonant
-- between vowels, and before the letters a syllable can start with ("Wald-schreiter", "Mondpirscher-patriarch").
-- Returns the byte positions a break may come before, or an empty list for other scripts.
local VOWEL = {}
for _, v in ipairs({ "a", "e", "i", "o", "u", "y", "ä", "ö", "ü", "é", "è", "ê", "à", "á", "â", "ã", "í", "ó", "ô", "õ", "ú" }) do
    VOWEL[v] = true
end
local ONSET = {}
for _, o in ipairs({ "schr", "schl", "schw", "schm", "schn", "sch", "spr", "str", "chr", "ch", "ck", "ph", "th",
    "pf", "qu", "st", "sp", "br", "bl", "cr", "cl", "dr", "fr", "fl", "gr", "gl", "kr", "kl", "pr", "pl", "tr", "zw" }) do
    ONSET[o] = true
end
local function syllableBreaks(word)
    local chars, at = {}, {}
    for pos, ch in word:gmatch("()([%z\1-\127\194-\244][\128-\191]*)") do
        chars[#chars + 1] = ch:lower()
        at[#at + 1] = pos
    end
    local out, i = {}, 2
    while i < #chars do
        if not VOWEL[chars[i]] and VOWEL[chars[i - 1]] then
            local e = i
            while e < #chars and not VOWEL[chars[e + 1]] do e = e + 1 end
            if e < #chars and e - i <= 5 then
                local cut = e                      -- before the last consonant ...
                for len = math.min(4, e - i + 1), 2, -1 do
                    if ONSET[table.concat(chars, "", e - len + 1, e)] then cut = e - len + 1 break end
                end
                if cut > 2 and #chars - cut >= 2 then out[#out + 1] = at[cut] end
            end
            i = e + 1
        else
            i = i + 1
        end
    end
    -- the scripts this does not know (Cyrillic, Hangul ...): no breaks offered
    for _, ch in ipairs(chars) do if #ch > 1 and not VOWEL[ch] and not ch:find("^[\195]") then return {} end end
    return out
end

-- the name on the plate of a card: two lines at most, a smaller size before anything is cut, and a word
-- too long for one line broken at its hyphen, else between two syllables near its middle
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
        -- the syllable break after which both halves fit their line, the nearest the middle; failing that,
        -- the one that leaves the longer half shortest
        local best, bestD
        for _, pos in ipairs(syllableBreaks(long)) do
            local wa = UI.MeasureWidth(long:sub(1, pos - 1) .. "-", px(8), UI.FONT)
            local wb = UI.MeasureWidth(long:sub(pos), px(8), UI.FONT)
            local both = wa <= NAME_W and wb <= NAME_W
            local d = both and math.abs(pos - #long / 2) or (1000 + max(wa, wb))
            if not bestD or d < bestD then best, bestD = pos, d end
        end
        if best then a, b = long:sub(1, best - 1) .. "-", long:sub(best) end
    end
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
    f.name = UI.Text(f, 10, { 0.96, 0.90, 0.78, 1 }, "CENTER", UI.FONT)
    f.name:SetPoint("TOPLEFT", f.plate, "TOPLEFT", 3, -2)
    f.name:SetPoint("BOTTOMRIGHT", f.plate, "BOTTOMRIGHT", -3, 2)
    f.name:SetJustifyV("MIDDLE")
    if f.name.SetMaxLines then f.name:SetMaxLines(2) end
    -- how many were slain: a small badge inside the lower corner of the picture (across its edge it would
    -- cover the name plate and the word of a connoisseur's card)
    f.badge = UI.CountBadge(f, 20)
    f.badge:SetPoint("BOTTOMRIGHT", f.window, "BOTTOMRIGHT", -3, 3)
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
    f.master:SetPoint("TOP", 0, -4)         -- not at the foot: the count badge needs that corner
    -- this one has killed you
    f.skull = f.over:CreateTexture(nil, "OVERLAY")
    f.skull:SetTexture(SKULL)
    f.skull:SetSize(14, 14)
    f.skull:SetPoint("TOPLEFT", 3, -3)
    -- rare creatures and bosses are "shiny": light sweeps over the picture and stars twinkle
    f.shiny = UI.Shiny(f.window)
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
        GameTooltip:AddLine(WFD:Quote(WFD:MarginNote(self.entry.id, m)), 0.95, 0.85, 0.65, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(WFD:Count("Slain %d times", m.kills), 0.9, 0.9, 0.9)
        local stage = WFD:MobStage(m)
        if stage == 1 then
            GameTooltip:AddLine(format(L["A sketch: %d more and it is in colour."], WFD.STAGE_COLOUR - m.kills), 0.75, 0.65, 0.45, true)
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
            GameTooltip:AddLine(nem.n == 1 and L["Got you once."] or WFD:Count("Got you %d times.", nem.n), 1, 0.35, 0.25)
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
        self.shiny:SetShiny(rk == "rare" or rk == "boss", r.border)
        self.rim:SetShown(stage == 3)
        self.master:SetText(stage == 3 and L["CONNOISSEUR"] or "")
        local nem = WFD.C.nemesis[m.name or ""]
        self.skull:SetShown(nem ~= nil and (nem.n or 0) > 0)
        self.num:SetText(format("#%03d", e.num))
        self.lvl:SetText(format(L["Lv %s"], levelText(m)))
        -- number left, rarity in the middle, level right: with large writing the number gives way to the rarity
        self.tag:SetFont(UI.HEAD, UI.FS(8), "")      -- a card is used again: back to the full size first
        self.tag:ClearAllPoints()
        self.tag:SetPoint("TOP", 0, -5)
        local half = self.tag:GetStringWidth() / 2
        if half > 0 then
            local mid = CARD_W / 2
            if 7 + self.num:GetStringWidth() + 3 > mid - half then self.num:SetText("") end
            if mid + half + 6 > CARD_W - 7 - self.lvl:GetStringWidth() then
                -- centred, the word would touch the level: it moves into the left corner, where the number was
                self.num:SetText("")
                self.tag:ClearAllPoints()
                self.tag:SetPoint("TOPLEFT", 7, -5)
                local room = CARD_W - 14 - self.lvl:GetStringWidth() - 6
                if half * 2 > room then UI.FitText(self.tag, room, 8, 6, UI.HEAD) end
            end
        end
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

-- the trading card is used by the album on the travel desk as well
UI.NewCreatureCard, UI.CREATURE_CARD_W, UI.CREATURE_CARD_H = newCard, CARD_W, CARD_H

local function kindsText(n) return n == 1 and L["1 kind"] or format(L["%d kinds"], n) end
UI.KindsText = kindsText

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

-- (the register of people is a view of the travel desk now: UI/Views/Registers.lua)

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
        -- the figures above the list grow with their captions (see the renderer)
        local HEAD_H, FACTS_H = 34, 60
        if facts then
            FACTS_H = UI.TileHeight(UI.TextW(), { format(L["Best day: day %d"], facts.best.day),
                format(L["Worst day: day %d"], facts.worst.day), L["Per day"] }) + 18
        end
        for i, r in ipairs(days) do
            if not page or y + 26 > UI.AREA_H then
                local first = page == nil
                page = book:Add({ kind = "ledger", rows = {}, numbered = true, head = L["Ledger"], facts = first and facts or nil })
                y = HEAD_H + (first and FACTS_H or 0)
            end
            page.rows[#page.rows + 1] = { y = y, h = 26, d = r }
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

    -- the savings goal: a bar of the purse towards it; click to change it, right-click to take it away
    local goal = C.goldGoal
    if goal and goal > 0 then
        local purse = WFD.demo and max(0, bal) or (GetMoney and GetMoney() or 0)
        local done = purse >= goal
        local cap = pool:Text(9, done and GREEN or c.redInk, UI.FONT)
        cap:SetText((done and L["Goal reached"] or L["Savings goal"]):upper())
        cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        local val = pool:Text(11, c.ink, UI.FONT, "RIGHT")
        val:SetText(UI.CoinIcons(min(purse, goal), 11) .. "  /  " .. UI.CoinIcons(goal, 11))
        val:SetWidth(tw - 80)
        val:SetWordWrap(false)
        val:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y + 2)
        UI.ProgressBar(pool, canvas, tx, y - 16, tw, 6, purse / goal, done and GREEN or c.gold)
        local hot = hotRow(pool, canvas, tx, y + 2, tw, 28, { L["Savings goal"], UI.CoinIcons(goal, 12),
            L["Click to change the goal."], L["Right-click to take the goal away."] }, function() UI:AskGold() end)
        hot.onRight = function() C.goldGoal = nil UI:Reflow() end
    else
        local fs = pool:Link(L["Set a savings goal"], function() UI:AskGold() end, 11, c.redInk)
        fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 2)
    end
    y = y - 34

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
        local th = UI.Tiles(pool, canvas, tx, top, tw, {
            { signed(f.best.n), format(L["Best day: day %d"], f.best.day), f.best.n >= 0 and c.good or c.bad,
              UI.book.dayPage[f.best.day] and function() UI:GoToPage(UI.book.dayPage[f.best.day]) end },
            { signed(f.worst.n), format(L["Worst day: day %d"], f.worst.day), f.worst.n >= 0 and c.good or c.bad,
              UI.book.dayPage[f.worst.day] and function() UI:GoToPage(UI.book.dayPage[f.worst.day]) end },
            { signed(f.avg), L["Per day"], f.avg >= 0 and c.good or c.bad },
        })
        top = top - th - 18
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
            { d.inc, d.inc > 0 and GREEN or c.inkFaint, d.inc > 0 and ("+" .. UI.CoinIcons(d.inc, 12)) or "-" },
            { d.sp, d.sp > 0 and c.bad or c.inkFaint, d.sp > 0 and ("-" .. UI.CoinIcons(d.sp, 12)) or "-" },
            { d.saldo, d.saldo < 0 and c.bad or c.ink, (d.saldo < 0 and "-" or "") .. UI.CoinIcons(d.saldo, 12) },
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
                if a and a > 0 then lines[#lines + 1] = "|cff" .. UI.Hex(c.good) .. "+" .. UI.CoinIcons(a, 11) .. "|r  " .. WFD:CatName(cat) end
                if b and b > 0 then lines[#lines + 1] = "|cff" .. UI.Hex(c.bad) .. "-" .. UI.CoinIcons(b, 11) .. "|r  " .. WFD:CatName(cat) end
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
-- (the quest book is a view of the travel desk now: UI/Views/Registers.lua)

-- (the settings are a view of the travel desk now: UI/Views/Settings.lua)
