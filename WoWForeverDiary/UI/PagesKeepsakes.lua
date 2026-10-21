-- Keepsakes: first times, the family book, the time capsule and the gatherer's map.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format

local TITLE_H = 116
local GOLD = { 0.86, 0.62, 0.18, 1 }
local LOCKED = { 0.46, 0.39, 0.30, 1 }
local WAX = { 0.55, 0.12, 0.10, 1 }
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"

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

local function dayGo(day)
    local p = day and UI.book and UI.book.dayPage[day]
    return p and function() UI:GoToPage(p) end
end

local function line(pool, canvas, x, y, w, text, size, col, font, justify)
    local t = pool:Text(size, col, font or UI.FONT, justify)
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
-- First times
------------------------------------------------------------------------
UI:RegisterSection({
    key = "firsts", label = "First times", icon = "first", order = 11,
    build = function(book)
        local C = WFD.C
        local got, list = 0, {}
        for i, def in ipairs(WFD.FIRSTS or {}) do
            local f = C.firsts and C.firsts[def.key]
            if f then got = got + 1 end
            list[#list + 1] = { h = 40, def = def, f = f, i = i }
        end
        -- what happened already in the order it happened, the rest in the order of a typical life
        table.sort(list, function(a, b)
            if (a.f ~= nil) ~= (b.f ~= nil) then return a.f ~= nil end
            if a.f then return a.f.t < b.f.t end
            return a.i < b.i
        end)
        paginate(book, "firsts", list, { head = L["First times"], got = got, total = #list })
    end,
})

UI:RegisterRenderer("firsts", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then
        UI.PageTitle(pool, canvas, side, L["First times"], format(L["%d of %d experienced"], page.got, page.total), -56)
    end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        local f, def = r.f, r.def
        pool:Plaque(tx + 16, y - 18, 28, f and UI.IconPath(def.icon, "first") or QUESTION, f and GOLD or LOCKED, f and true or false)
        line(pool, canvas, tx + 40, y - 3, tw - 40 - 86, L[def.label], 14, f and c.ink or c.inkFaint, UI.HEAD)
        local detail
        if f then
            local parts = {}
            if f.s and f.s ~= "" then parts[#parts + 1] = f.s end
            if f.zone and f.zone ~= f.s then parts[#parts + 1] = f.zone end
            detail = table.concat(parts, "  -  ")
        else
            detail = L["Not yet experienced."]
        end
        line(pool, canvas, tx + 40, y - 21, tw - 40 - 86, detail, 10, f and c.inkSoft or c.inkFaint)
        if f then
            rightText(pool, canvas, tx + tw, y - 4, format(L["Day %d"], f.day), 13, c.redInk, UI.HEAD)
            rightText(pool, canvas, tx + tw, y - 22, date(WFD.loc.date, f.t), 9, c.inkFaint)
            local tip = { L[def.label] }
            if detail ~= "" then tip[#tip + 1] = detail end
            tip[#tip + 1] = format(L["Day %d"], f.day) .. "  -  " .. date(WFD.loc.date .. " %H:%M", f.t)
            tip[#tip + 1] = L["Click to read this day."]
            local hot = pool:Hot(tip, dayGo(f.day))
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
            hot:SetSize(tw, r.h - 4)
        end
    end
end)

------------------------------------------------------------------------
-- The family book: every character of this account
------------------------------------------------------------------------
-- what can be raced for: every tenth level, and some first times
local RACES = {
    { level = 10 }, { level = 20 }, { level = 30 }, { level = 40 }, { level = 50 }, { level = 60 },
    { first = "dungeon" }, { first = "mount" }, { first = "gold" }, { first = "blue" }, { first = "epic" }, { first = "boss" },
}

local function raceLabel(r)
    if r.level then return format(L["Level %d"], r.level) end
    for _, def in ipairs(WFD.FIRSTS or {}) do
        if def.key == r.first then return L[def.label] end
    end
    return r.first
end

UI:RegisterSection({
    key = "family", label = "Family book", icon = "kin", order = 86, leftStart = true,
    -- one tab for the family book and the time capsule right after it
    thumbText = function() return L["Family book"] .. " & " .. L["Time capsule"] end,
    build = function(book)
        if WFD.UpdateFamily then WFD.UpdateFamily() end
        local fam = WFD:Family()
        local list = {}
        for _, f in ipairs(fam) do list[#list + 1] = { h = 84, fam = f } end
        if #fam < 2 then
            list[#list + 1] = { h = 60, hint = true }
        else
            local header = { h = 34, header = true, keep = 22 }
            for _, r in ipairs(RACES) do
                local best, n
                for _, f in ipairs(fam) do
                    local d = r.level and f.e.levels and f.e.levels[r.level] or (r.first and f.e.firsts and f.e.firsts[r.first])
                    if d then
                        n = (n or 0) + 1
                        if not best or d < best.day then best = { name = f.e.name, day = d, classFile = f.e.classFile } end
                    end
                end
                if best then
                    if header then list[#list + 1] = header; header = nil end
                    list[#list + 1] = { h = 22, race = r, best = best, n = n }
                end
            end
        end
        paginate(book, "family", list, { head = L["Family book"], count = #fam })
    end,
})

UI:RegisterRenderer("family", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then
        UI.PageTitle(pool, canvas, side, L["Family book"], format(L["%d characters on this account"], page.count), -56)
    end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.fam then
            local e, me = r.fam.e, r.fam.me
            local bg = pool:Rect(me and { 0.40, 0.30, 0.14 } or c.paperDk, me and 0.30 or 0.22)
            bg:SetSize(tw, r.h - 8)
            bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            local path, coords = UI.ClassCrest(e.classFile)
            local ccol = UI.ClassColor(e.classFile)
            pool:Plaque(tx + 30, y - 37, 42, path, e.dead and LOCKED or ccol, not e.dead, e.level and tostring(e.level), coords)
            local n = line(pool, canvas, tx + 62, y - 7, tw - 62 - 92, e.name or "?", 17, e.dead and c.inkFaint or ccol, UI.HEAD)
            n:SetShadowColor(0, 0, 0, 0.8)
            if me then
                local you = pool:Text(11, c.inkSoft, UI.FONT)
                you:SetText("(" .. L["you"] .. ")")
                you:SetPoint("BOTTOMLEFT", n, "BOTTOMLEFT", min(n:GetStringWidth(), tw - 62 - 92) + 6, 2)
            end
            line(pool, canvas, tx + 62, y - 28, tw - 62 - 8,
                ((e.race or "") .. " " .. (e.class or "")) .. "  -  " .. (e.realm or ""), 10, c.inkSoft)
            line(pool, canvas, tx + 62, y - 44, tw - 62 - 8,
                format(L["%d days of life  -  %d creatures slain  -  %d quests completed"], e.days or 0, e.kills or 0, e.quests or 0), 9, c.inkFaint)
            rightText(pool, canvas, tx + tw - 8, y - 8, format(L["%d honour points"], e.points or 0), 10, c.redInk)
            -- a line of its own, so it never runs into the realm
            if e.dead then
                line(pool, canvas, tx + 62, y - 59, tw - 62 - 8, L["In memoriam"], 10, c.bad)
            elseif not me and e.last then
                line(pool, canvas, tx + 62, y - 59, tw - 62 - 8, format(L["Last seen %s"], date(WFD.loc.date, e.last)), 9, c.inkFaint)
            end
            local hot = pool:Hot({
                e.name or "?", format(L["Level %d"], e.level or 0) .. "  -  " .. (e.class or ""),
                format(L["%d days of life  -  %d creatures slain  -  %d quests completed"], e.days or 0, e.kills or 0, e.quests or 0),
                L["Deaths"] .. ": " .. (e.deaths or 0) .. "   " .. L["On foot"] .. ": " .. WFD:Dec(e.km or 0) .. " km",
                L["Time online"] .. ": " .. WFD:DurationText(e.online or 0),
            })
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            hot:SetSize(tw, r.h - 8)
        elseif r.hint then
            emptyNote(pool, canvas, tx, tw, y - 8, L["Log in with your other characters once, and they will appear here."])
        elseif r.header then
            UI.SectionHead(pool, canvas, tx, tw, y + 4, 32, L["Who got there first?"])
        elseif r.race then
            line(pool, canvas, tx + 12, y - 3, tw * 0.5, raceLabel(r.race), 12, c.ink)
            local who = pool:Text(12, UI.ClassColor(r.best.classFile), UI.FONT, "RIGHT")
            who:SetText(r.best.name .. "  |cff" .. UI.Hex(c.inkFaint) .. format(L["Day %d"], r.best.day) .. "|r")
            who:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 3)
            local dot = pool:Diamond(5, c.redInk)
            dot:SetPoint("CENTER", canvas, "TOPLEFT", tx + 4, y - 9)
        end
    end
end)

------------------------------------------------------------------------
-- Time capsule: letters to yourself
------------------------------------------------------------------------
local DRAFT_H = 210
local LETTER_LINE = 17

local function letterHeight(letter)
    if letter.opened then
        return 46 + UI.Measure(letter.text or "", 12, UI.TextW() - 24, LETTER_LINE - 12, UI.FONT) + 14
    end
    return 50
end

UI:RegisterSection({
    key = "capsule", label = "Time capsule", icon = "capsule", order = 88, thumb = false,
    build = function(book)
        local C = WFD.C
        local list = { { h = DRAFT_H, draft = true } }
        local letters = {}
        for i, l in ipairs(C.capsules or {}) do letters[#letters + 1] = { l = l, i = i } end
        -- sealed letters first (soonest to open on top), then the opened ones, newest first
        table.sort(letters, function(a, b)
            local ao, bo = a.l.opened ~= nil, b.l.opened ~= nil
            if ao ~= bo then return not ao end
            if ao then return a.l.opened > b.l.opened end
            return a.i < b.i
        end)
        if #letters == 0 then list[#list + 1] = { h = 40, empty = true } end
        for _, e in ipairs(letters) do list[#list + 1] = { h = letterHeight(e.l), letter = e.l } end
        paginate(book, "capsule", list, { head = L["Time capsule"] })
    end,
})

local function sealWith(eb, kind, value)
    return function()
        local C = WFD.C
        if eb then eb:ClearFocus() end
        UI.noteFocus = false
        local text = C.capsuleDraft
        if not text or not text:find("%S") then
            if eb then eb:SetFocus() end
            return
        end
        if WFD:SealLetter(text, kind, value) then
            UI.Sound("IG_QUEST_LIST_COMPLETE", 878)
            UI:Reflow()
        end
    end
end

UI:RegisterRenderer("capsule", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then UI.PageTitle(pool, canvas, side, L["Time capsule"], L["Letters to my future self"], -56) end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.draft then
            -- a sheet of letter paper with ruled lines
            local boxH = 128
            local sheet = pool:Rect({ 0.30, 0.22, 0.13 }, 0.30)
            sheet:SetSize(tw, boxH)
            sheet:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            for ly = 8 + LETTER_LINE, boxH - 4, LETTER_LINE do
                local ln = pool:Rect({ 0.78, 0.60, 0.26 }, 0.14)
                ln:SetSize(tw - 16, 1)
                ln:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 8, y - ly)
            end
            local eb = pool:NoteEdit(tw - 16, boxH - 14, LETTER_LINE, C.capsuleDraft or "", function(text)
                C.capsuleDraft = (text ~= "") and text or nil
            end, L["Dear me, when you read this ..."])
            eb:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 8, y - 8)
            local hot = pool:Hot(nil, function() eb:SetFocus() end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            hot:SetSize(tw, boxH)
            hot.hl:SetAlpha(0)
            eb:SetFrameLevel(hot:GetFrameLevel() + 1)
            -- how to seal it
            local sy = y - boxH - 12
            line(pool, canvas, tx, sy, tw, L["Seal the letter and open it ..."]:upper(), 10, c.redInk)
            local opts = { { L["in a week"], "days", 7 }, { L["in a month"], "days", 30 } }
            local lvl, top60 = UnitLevel("player") or 1, (GetMaxPlayerLevel and GetMaxPlayerLevel()) or 60
            if lvl < top60 then
                local goal = min(top60, (floor(lvl / 10) + 1) * 10)
                opts[#opts + 1] = { format(L["at level %d"], goal), "level", goal }
            end
            local x = tx
            for _, o in ipairs(opts) do
                local fs = pool:Link(o[1], sealWith(eb, o[2], o[3]), 13, c.ink)
                fs:ClearAllPoints()
                fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 14, sy - 20)
                local d = pool:Diamond(6, WAX)
                d:SetPoint("RIGHT", fs, "LEFT", -5, 0)
                x = x + fs:GetStringWidth() + 34
            end
            line(pool, canvas, tx, sy - 44, tw, L["Until then the letter stays sealed - not even you can read it."], 10, c.inkSoft)
        elseif r.empty then
            emptyNote(pool, canvas, tx, tw, y - 6, L["No letters yet."])
        elseif r.letter then
            local l = r.letter
            local open = l.opened ~= nil
            pool:Plaque(tx + 14, y - 16, 24, UI.Icon("capsule"), open and GOLD or WAX, true)
            local head = format(L["Written on day %d, at level %d"], l.day or 0, l.level or 0)
            line(pool, canvas, tx + 36, y - 2, tw - 36, head, 13, c.ink, UI.HEAD)
            local sub
            if open then
                sub = format(L["Opened on %s"], date(WFD.loc.date, l.opened))
            elseif l.openDay then
                local left = l.openDay - WFD:DayIndex()
                sub = format(L["Sealed - opens on day %d"], l.openDay) .. (left > 0 and ("  (" .. format(L["in %d days"], left) .. ")") or "")
            else
                sub = format(L["Sealed - opens at level %d"], l.openLevel or 0)
            end
            line(pool, canvas, tx + 36, y - 20, tw - 36, sub, 10, open and c.inkSoft or c.redInk)
            if open then
                local t = pool:Text(12, { 0.80, 0.86, 0.98, 1 }, UI.FONT)
                t:SetSpacing(LETTER_LINE - 12)
                t:SetWidth(tw - 24)
                t:SetText(l.text or "")
                t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 12, y - 42)
                local bar = pool:Rect({ 0.74, 0.84, 0.98 }, 0.35)
                bar:SetSize(2, max(12, r.h - 56))
                bar:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 42)
            end
        end
    end
end)

------------------------------------------------------------------------
-- The gatherer's map
------------------------------------------------------------------------
local function kindOf(key)
    for _, k in ipairs(WFD.GATHER_KINDS or {}) do if k.key == key then return k end end
end
local function kindName(k)
    return WFD:SpellName(k.spell) or L[k.label]
end

local MAP_H

UI:RegisterSection({
    key = "gathering", label = "Gatherer's map", icon = "gather", order = 21,
    build = function(book)
        local per, maps = WFD:GatherSummary()
        local tw = UI.TextW()
        MAP_H = floor((tw - 18) / 1.5) + 18
        local list = { { h = 70, summary = true, per = per } }
        if #maps == 0 then list[#list + 1] = { h = 50, empty = true } end
        for i = 1, min(10, #maps) do list[#list + 1] = { h = MAP_H + 66, map = maps[i] } end
        paginate(book, "gathering", list, { head = L["Gatherer's map"] })
    end,
})

UI:RegisterRenderer("gathering", function(pool, page, side, canvas)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then UI.PageTitle(pool, canvas, side, L["Gatherer's map"], L["Where the good things grow"], -56) end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.summary then
            local tiles = {}
            for _, k in ipairs(WFD.GATHER_KINDS or {}) do
                tiles[#tiles + 1] = { r.per[k.key] or 0, kindName(k), (r.per[k.key] or 0) > 0 and k.col or c.inkFaint }
            end
            UI.Tiles(pool, canvas, tx, y, tw, tiles)
        elseif r.empty then
            emptyNote(pool, canvas, tx, tw, y - 6, L["Nothing gathered yet. Herbs, ore and hides show up here as soon as you gather them."])
        elseif r.map then
            local m = r.map
            -- heading: region name and what was gathered there
            local d = pool:Diamond(6, c.redInk)
            d:SetPoint("CENTER", canvas, "TOPLEFT", tx + 3, y - 7)
            line(pool, canvas, tx + 12, y - 1, tw * 0.6, WFD:MapName(m.id), 13, c.ink, UI.HEAD)
            local parts = {}
            for _, k in ipairs(WFD.GATHER_KINDS or {}) do
                if m.kinds[k.key] then parts[#parts + 1] = "|cff" .. UI.Hex(k.col) .. m.kinds[k.key] .. "|r" end
            end
            rightText(pool, canvas, tx + tw, y - 2, table.concat(parts, "  "), 11, c.inkSoft)
            -- the map with a dot for every spot
            local MAT = 9
            local mw, mh = tw - MAT * 2, MAP_H - MAT * 2
            local mat = pool:Rect({ 0.08, 0.055, 0.035 }, 1, "ARTWORK", 1)
            mat:SetSize(tw, MAP_H)
            mat:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 20)
            local map = pool:Map(mw, mh)
            map:SetSize(mw, mh)
            map:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + MAT, y - 20 - MAT)
            map:SetFrameLevel(canvas:GetFrameLevel() + 2)
            local points, items = {}, {}
            local spots = C.gather and C.gather[m.id] or {}
            -- the map holds 400 pins: the newest spots, the counts below take them all
            local from = math.max(1, #spots - 399)
            for i, s in ipairs(spots) do
                local k = kindOf(s.k)
                if k then
                    if i >= from then
                        points[#points + 1] = { s.x, s.y, k.col, { s.item or kindName(k), format(L["Day %d"], s.day or 0) } }
                    end
                    if s.item then items[s.item] = (items[s.item] or 0) + 1 end
                end
            end
            map:DrawPoints(m.id, points)
            -- the most common finds there
            local top3 = {}
            for name, n in pairs(items) do top3[#top3 + 1] = { name = name, n = n } end
            table.sort(top3, function(a, b) return a.n > b.n end)
            local finds = {}
            for i = 1, min(3, #top3) do finds[#finds + 1] = top3[i].name .. " x" .. top3[i].n end
            line(pool, canvas, tx, y - 20 - MAP_H - 6, tw, #finds > 0 and (L["Most found here"] .. ": " .. table.concat(finds, ", ")) or "", 10, c.inkSoft)
        end
    end
end)
