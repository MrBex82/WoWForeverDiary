-- The diary itself: chapters, day entries flowing over pages, margin notes and glued-in keepsakes.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, format, concat = math.floor, math.max, string.format, table.concat

local NOTE_W = 66                    -- margin column for notes
local FONT_SIZE, SPACING = 13, 3
local H_CHAPTER, H_DAY, H_FLOURISH, GAP = 196, 58, 30, 8
local CAP_SIZE, CAP_LINES = 40, 2    -- illuminated initial at the start of every day
local ITEM_SLOT, MOMENT_H = 80, 34  -- width of a taped item card, height of a moment card (with its gap)

local function textColW() return UI.TextW() - NOTE_W end

------------------------------------------------------------------------
-- Chapters
------------------------------------------------------------------------
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV",
    "XVI", "XVII", "XVIII", "XIX", "XX" }
local function roman(n) return ROMAN[n] or tostring(n) end

local TITLES = {
    { s = "Arrival in %s", case = "in" }, { s = "The roads of %s", case = "in" }, { s = "Under the skies of %s", case = "over" },
    { s = "Shadows over %s", case = "over" }, { s = "Days in %s", case = "in" },
}

function UI.Chapters()
    local C = WFD.C
    local list, cur = {}, nil
    for day = 1, WFD:NumDays() do
        local d = C.days[day]
        if d then
            local zone = WFD:MainZone(d) or (cur and cur.zone) or C.startZone or "?"
            if not cur or zone ~= cur.zone then
                cur = { zone = zone, days = {} }
                list[#list + 1] = cur
            end
            cur.days[#cur.days + 1] = day
        end
    end
    local seen = {}
    for i, ch in ipairs(list) do
        ch.roman = roman(i)
        if i == 1 then
            ch.title = format(L["Awakening in %s"], WFD:Place(ch.zone, "in"))
        elseif seen[ch.zone] then
            ch.title = format(L["Return to %s"], WFD:Place(ch.zone, "to"))
        else
            local tpl = TITLES[((i - 2) % #TITLES) + 1]
            ch.title = format(L[tpl.s], WFD:Place(ch.zone, tpl.case))
        end
        seen[ch.zone] = true
        local d1, d2 = ch.days[1], ch.days[#ch.days]
        local l1 = WFD:LevelAt(WFD:DayTime(d1) - 43200)
        local l2 = WFD:LevelAt(WFD:DayTime(d2) + 43200)
        local lv = (l1 == l2) and format(L["Level %d"], l1) or format(L["Level %d-%d"], l1, l2)
        local dy = (d1 == d2) and format(L["Day %d"], d1) or format(L["Days %d-%d"], d1, d2)
        ch.sub = lv .. "   |   " .. dy
    end
    return list
end

------------------------------------------------------------------------
-- Pagination of the entries
------------------------------------------------------------------------
local function story(day)
    local s = UI.storyCache[day]
    if not s then
        s = WFD:Narrate(day)
        if day < WFD:NumDays() then UI.storyCache[day] = s end
    end
    return s
end

local SKULL = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:11:11:0:-1|t "

local function marginNotes(f)
    local d = f.d
    local notes = {}
    for _, lv in ipairs(d.levels) do notes[#notes + 1] = { format(L["Level %d!"], lv), UI.Deep({ 0.93, 0.75, 0.35, 1 }, 0.62) } end
    if d.killTotal > 0 then notes[#notes + 1] = { WFD:Count("%d kills", d.killTotal), c.inkSoft } end
    if #d.qd > 0 then notes[#notes + 1] = { WFD:Count("%d quests", #d.qd), UI.Deep({ 0.60, 0.76, 1.00, 1 }, 0.45) } end
    if f.net ~= 0 then
        notes[#notes + 1] = { (f.net > 0 and "+" or "-") .. UI.CoinIcons(f.net, 11), f.net > 0 and c.good or c.bad }
    end
    if d.deaths > 0 then notes[#notes + 1] = { SKULL .. d.deaths .. "x", c.bad } end
    if f.km >= 0.5 then notes[#notes + 1] = { WFD:Dec(f.km) .. " km", c.inkFaint } end
    return notes
end

-- when in the day it happened, and what that felt like
local MOODS = {
    { 5, 9, "early in the morning" }, { 9, 12, "in the morning" }, { 12, 14, "around noon" },
    { 14, 18, "in the afternoon" }, { 18, 22, "in the evening" },
}
local function timeLine(d)
    if not d.t0 then return nil end
    local best, bestV
    for h, v in pairs(d.hours or {}) do
        if not bestV or v > bestV then best, bestV = h, v end
    end
    best = best or tonumber(date("%H", d.t0))
    local mood = "late at night"
    for _, m in ipairs(MOODS) do
        if best >= m[1] and best < m[2] then mood = m[3] end
    end
    return date("%H:%M", d.t0) .. " - " .. date("%H:%M", d.t1 or d.t0) .. ",  " .. L[mood]
end

-- "on this day": a look back from the newest entry
local function flashback(day)
    local C = WFD.C
    for _, n in ipairs({ 365, 30, 7 }) do
        local old = day - n
        local d = old >= 1 and C.days[old]
        if d then
            local f = WFD:DayFacts(old)
            local evText
            for _, ev in ipairs(f.events) do
                if ev.k == "boss" or ev.k == "rare" or ev.k == "level" or ev.k == "dungeon" or ev.k == "zone" or ev.k == "epic" then
                    evText = ev.s
                    break
                end
            end
            local txt = format(L["I was in %s."], WFD:Place(f.mainZone or "?", "in"))
            if evText then
                txt = txt .. " " .. evText
            elseif d.killTotal > 0 then
                txt = txt .. " " .. WFD:Count("%d enemies fell that day.", d.killTotal)
            end
            return { n = n, day = old, text = txt }
        end
    end
end

-- the most remarkable moment of a day that can be painted
local PAINT_ORDER = { boss = 1, rare = 2, dungeon = 3, level = 4, epic = 5, first = 5, landmark = 6, zone = 6, honour = 7,
    rareitem = 7, weekly = 7, quest = 8 }
local function paintable(f)
    local best
    for _, ev in ipairs(f.events) do
        if ev.gear and PAINT_ORDER[ev.k] and (not best or PAINT_ORDER[ev.k] < PAINT_ORDER[best.k]) then best = ev end
    end
    return best
end

-- a moment card: one line for its subject, or two when it is too long for one (the card grows with it)
local function momentSubject(ev) return (ev.k ~= "level" and ev.s and ev.s:match(":%s*(.+)$")) or ev.s or "" end
local function momentTwoLines(ev)
    return UI.MeasureWidth(momentSubject(ev), UI.FS(13), UI.FONT) > textColW() - 38 - 44
end
-- the kind on top, the subject below it; both grow with the size of the writing
local function momentH(ev)
    local h = max(MOMENT_H, UI.FS(9) + UI.FS(13) + 10)
    return momentTwoLines(ev) and (h + UI.FS(12) + 2) or h
end

-- the line of figures under the date: "Level 5!  ·  40 kills  ·  3 quests ..."
-- the figures in a row, broken into lines by hand: a line never starts with a separator dot
local FACT_SEP = "   |cff8a7a5c·|r   "
local function factsText(list, width)
    local size = UI.FS(12)
    local sepW = UI.MeasureWidth("   ·   ", size, UI.FONT)
    local lines, line, lineW = {}, nil, 0
    for _, n in ipairs(list) do
        local k = n[2]
        local part = format("|cff%02x%02x%02x%s|r", floor(k[1] * 255), floor(k[2] * 255), floor(k[3] * 255), n[1])
        local w = UI.MeasureWidth(n[1], size, UI.FONT)
        if not line then
            line, lineW = part, w
        elseif lineW + sepW + w > width - 4 then
            lines[#lines + 1] = line
            line, lineW = part, w
        else
            line, lineW = line .. FACT_SEP .. part, lineW + sepW + w
        end
    end
    lines[#lines + 1] = line
    return concat(lines, "\n")
end

local function keepsakes(f)
    local items = {}
    for _, it in ipairs(f.items) do
        if it.q >= 2 and #items < 3 then items[#items + 1] = it end
    end
    local moments = {}
    for _, ev in ipairs(f.events) do
        if UI.SEAL[ev.k] and (ev.k ~= "challenge" or ev.all) and #moments < 6 then moments[#moments + 1] = ev end
    end
    if #items == 0 and #moments == 0 then return nil end
    -- label, the taped item cards, then one line per moment
    local h = 24 + (#items > 0 and 100 or 0)
    for _, ev in ipairs(moments) do h = h + momentH(ev) end
    return { items = items, moments = moments, h = h }
end

-- the height of each task line (a long task takes two lines) and of the whole box
local function taskRowHeights(list, w)
    local rows, sum = {}, 0
    for i, task in ipairs(list) do
        rows[i] = max(17, UI.Measure(WFD:ChallengeText(task), UI.FS(11), w, 0, UI.FONT) + 5)
        sum = sum + rows[i]
    end
    return rows, 22 + sum + 6
end

function UI.LayoutDiary(book, chapters)
    if WFD.TodayChallenges then WFD:TodayChallenges() end     -- pick today's tasks before laying out today
    local AREA = UI.AREA_H
    local TCW = textColW()
    -- measured at the size the page will draw (the writing can be made larger in the settings)
    local FS, CAP = UI.FS(FONT_SIZE), UI.FS(CAP_SIZE)
    -- languages written without spaces (Chinese) are broken between any two characters
    local SEP = (WFD.loc.sentenceSep == "") and "" or " "
    local WORD = SEP == "" and "[%z\1-\127\194-\244][\128-\191]*" or "%S+"
    local page, y

    local function newPage(head)
        page = book:Add({ kind = "diary", items = {}, notes = {}, head = head, numbered = true })
        y = 0
    end
    local function put(it, h)
        it.y = y
        page.items[#page.items + 1] = it
        y = y + h
    end

    if #chapters == 0 then
        newPage(nil)
        put({ t = "empty" }, 60)
        return
    end

    for _, ch in ipairs(chapters) do
        local head = ch.roman .. ".  " .. ch.title
        newPage(nil)
        ch.page = page.index
        put({ t = "chapter", ch = ch }, H_CHAPTER)
        for _, day in ipairs(ch.days) do
            local f = WFD:DayFacts(day)
            if y + H_DAY + 70 > AREA then newPage(head) end
            book.dayPage[day] = page.index
            local dayY = y
            put({ t = "day", day = day, place = f and f.mainZone or ch.zone, time = f and timeLine(f.d) }, H_DAY)
            -- the facts of the day in one line under the date (they stood small in the margin before)
            local facts = f and marginNotes(f)
            -- a full day takes two lines of figures rather than losing the last ones
            if facts and #facts > 0 then
                put({ t = "facts", list = facts }, max(22, UI.Measure(factsText(facts, TCW), UI.FS(12), TCW, 0, UI.FONT) + 8))
            end
            if day == WFD:NumDays() then
                local fb = flashback(day)
                if fb then put({ t = "flashback", fb = fb }, 62) end
            end
            -- the tasks of that day, ticked off
            local tasks = WFD.C.challenges and WFD.C.challenges[day]
            if tasks and #tasks.list > 0 then
                local _, th = taskRowHeights(tasks.list, TCW - 26 - 52)
                if y + th > AREA then newPage(head) end
                put({ t = "tasks", day = day, ch = tasks }, th + GAP)
            end

            local paras, kinds = {}, {}
            for p in (story(day) .. "\n\n"):gmatch("(.-)\n\n") do
                if p ~= "" then paras[#paras + 1] = p end
            end
            local own = WFD.C.dayNotes and WFD.C.dayNotes[day]
            if own and own ~= "" then
                local firstOwn = true
                for p in (own .. "\n"):gmatch("(.-)\n") do
                    if p:find("%S") then
                        paras[#paras + 1] = (firstOwn and ("|cffc2a880" .. L["My own thoughts:"] .. "|r  ") or "") .. p
                        kinds[#paras] = "mynote"
                        firstOwn = false
                    end
                end
            end
            for pi, text in ipairs(paras) do
                local kind = kinds[pi] or "para"
                local words = {}
                for w in text:gmatch(WORD) do words[#words + 1] = w end
                local from = 1
                local first = (pi == 1)
                if first and kind == "para" and #words > 0 then
                    -- illuminated initial: a big red letter, the first lines indented beside it
                    local letter = words[1]:match("^[%z\1-\127\194-\244][\128-\191]*")
                    if letter and (#letter > 1 or letter:find("%w")) then
                        if y + CAP_LINES * (FS + SPACING) + 4 > AREA then newPage(head) end
                        local rest = words[1]:sub(#letter + 1)
                        local capW = UI.MeasureWidth(letter, CAP, UI.HEAD) + (rest == "" and 8 or 3)
                        local tw2 = TCW - 8 - capW
                        local limit = CAP_LINES * FS + (CAP_LINES - 1) * SPACING + 4
                        local w1 = { rest }
                        local n = 1
                        for k = 2, #words do
                            w1[#w1 + 1] = words[k]
                            if UI.Measure(concat(w1, SEP), FS, tw2, SPACING, UI.FONT) > limit then
                                w1[#w1] = nil
                                break
                            end
                            n = k
                        end
                        local text = concat(w1, SEP):gsub("^ ", "")
                        local h = CAP_LINES * (FS + SPACING)
                        put({ t = "dropcap", letter = letter, text = text, capW = capW }, n >= #words and (h + GAP) or h)
                        from = n + 1
                        first = false
                    end
                end
                while from <= #words do
                    local rest = concat(words, SEP, from)
                    local h = UI.Measure(rest, FS, TCW - 8, SPACING, UI.FONT)
                    if y + h <= AREA then
                        put({ t = kind, text = rest, first = first }, h + GAP)
                        break
                    end
                    local remaining = AREA - y
                    local lo, hi, best = from, #words, from - 1
                    while lo <= hi do
                        local mid = floor((lo + hi) / 2)
                        if UI.Measure(concat(words, SEP, from, mid), FS, TCW - 8, SPACING, UI.FONT) <= remaining then
                            best = mid
                            lo = mid + 1
                        else
                            hi = mid - 1
                        end
                    end
                    if best >= from then
                        local part = concat(words, SEP, from, best)
                        put({ t = kind, text = part, first = first }, UI.Measure(part, FS, TCW - 8, SPACING, UI.FONT))
                        from = best + 1
                        first = false
                    end
                    newPage(head)
                end
            end

            local pic = f and paintable(f)
            if pic then
                if y + 156 > AREA then newPage(head) end
                put({ t = "picture", ev = pic }, 156)
            end
            local keep = f and keepsakes(f)
            if keep then
                if y + keep.h > AREA then newPage(head) end
                put({ t = "keep", keep = keep, day = day }, keep.h + GAP)
            end
            if y + H_FLOURISH <= AREA then
                put({ t = "flourish" }, H_FLOURISH)
            end
        end
    end
end

------------------------------------------------------------------------
-- Rendering
------------------------------------------------------------------------
local function redFirstSentence(text)
    local s, e = text:find("^.-[%.!%?]%s")
    if s and e <= 60 then
        return "|cff" .. (UI.THEME == "parchment" and UI.Hex(c.redInk) or "e8c26a") .. text:sub(1, e - 1) .. "|r" .. text:sub(e)
    end
    return text
end

local function qualityColor(q)
    local col = WFD.qualityColors[q or 1] or WFD.qualityColors[1]
    if q == 1 then return { 0.55, 0.50, 0.42 } end
    return col
end

local function drawKeep(pool, canvas, x, top, keep, w)
    local cx = x
    for _, it in ipairs(keep.items) do
        local shadow = pool:Rect({ 0, 0, 0 }, 0.25, "ARTWORK", 0)
        shadow:SetSize(58, 64)
        shadow:SetPoint("TOPLEFT", canvas, "TOPLEFT", cx + 3, top - 5)
        local card = pool:Rect({ 0.11, 0.08, 0.05 }, 1, "ARTWORK", 1)
        card:SetSize(58, 64)
        card:SetPoint("TOPLEFT", canvas, "TOPLEFT", cx, top - 2)
        local q = qualityColor(it.q)
        local frame = pool:Rect(q, 1, "ARTWORK", 2)
        frame:SetSize(40, 40)
        frame:SetPoint("TOP", card, "TOP", 0, -8)
        local icon = pool:Icon(WFD:ItemIcon(it.link) or UI.Icon("loot"), 37, "ARTWORK", 3)
        icon:SetPoint("CENTER", frame, "CENTER")
        local tape = pool:Rect({ 0.90, 0.78, 0.50 }, 0.45, "ARTWORK", 4)
        tape:SetSize(34, 10)
        tape:SetRotation(((cx % 3) - 1) * 0.18)
        tape:SetPoint("CENTER", card, "TOP", 0, 0)
        local cap = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
        cap:SetText(WFD:ItemName(it.link))
        cap:SetWidth(74)
        if cap.SetMaxLines then cap:SetMaxLines(2) end
        cap:SetPoint("TOP", card, "BOTTOM", 0, -3)
        local hot = pool:Hot(nil, nil, it.link)
        hot:SetPoint("TOPLEFT", card, "TOPLEFT")
        hot:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT")
        cx = cx + ITEM_SLOT
    end
    if #keep.items > 0 then top = top - 100 end      -- card and a name of up to two lines
    -- one small card per moment: accent stripe and icon in the colour of its kind, the kind, the text, the time
    local my = top
    for _, ev in ipairs(keep.moments) do
        local two = momentTwoLines(ev)
        local ch = momentH(ev) - 4
        local icon, col = UI.MomentIcon(ev)
        -- the kind colour lifted toward cream, so it reads on dark leather
        local light = UI.THEME == "parchment" and { col[1] * 0.6, col[2] * 0.6, col[3] * 0.6, 1 }
            or { col[1] * 0.45 + 0.55, col[2] * 0.45 + 0.55, col[3] * 0.45 + 0.55, 1 }
        local bg = pool:Rect(c.paperDk, 0.40)
        bg:SetSize(w, ch)
        bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, my)
        local stripe = pool:Rect(light, 0.85)
        stripe:SetSize(3, ch)
        stripe:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, my)
        local lvl = ev.k == "level" and ev.s and ev.s:match("(%d+)")
        pool:Plaque(x + 20, my - ch / 2, 22, icon, col, true, lvl)
        local kind = pool:Text(9, light, UI.FONT)
        kind:SetText(L[UI.SEAL_LABEL[ev.k] or "Moment"]:upper())
        kind:SetWordWrap(false)
        kind:SetWidth(w - 40 - 50)
        kind:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 38, my - 3)
        local t = pool:Text(two and 12 or 13, c.ink, UI.FONT)
        t:SetText(momentSubject(ev))
        t:SetWidth(w - 38 - 44)
        if t.SetMaxLines then t:SetMaxLines(2) end
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 38, my - 4 - UI.FS(9))
        local tm = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
        tm:SetText(date("%H:%M", ev.t))
        tm:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x + w - 6, my - 4)
        local lines = { ev.s, date("%H:%M", ev.t) }
        if ev.shot then lines[#lines + 1] = L["Screenshot:"] .. " " .. ev.shot end
        local go
        if ev.k == "honour" or ev.k == "landmark" then
            local key = ev.k == "honour" and "honour" or "landmarks"
            go = function() local p = UI.book and UI.book.sectionStart[key] if p then UI:GoToPage(p) end end
        end
        local hot = pool:Hot(lines, go)
        hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, my)
        hot:SetSize(w, ch)
        my = my - ch - 4
    end
end

UI:RegisterRenderer("diary", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local TCW = textColW()
    local textX = (side == "left") and (tx + NOTE_W) or tx
    local noteX = (side == "left") and tx or (tx + TCW + 10)
    local top = -UI.TOP

    for _, it in ipairs(page.items) do
        local y = top - it.y
        if it.t == "chapter" then
            local ch = it.ch
            local k = pool:Text(11, c.redInk, UI.FONT, "CENTER")
            k:SetText((L["Chapter"] .. " " .. ch.roman):upper())
            k:SetWidth(tw)
            k:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 20)
            local kw = k:GetStringWidth() / 2 + 10
            for s = -1, 1, 2 do
                local fl = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, s < 0 and 0 or 0.6 }, { 0.91, 0.76, 0.42, s < 0 and 0.6 or 0 })
                fl:SetSize(46, 1)
                fl:SetPoint(s < 0 and "RIGHT" or "LEFT", canvas, "TOPLEFT", tx + tw / 2 + s * kw, y - 25)
                local dm = pool:Diamond(4, c.redInk)
                dm:SetPoint("CENTER", canvas, "TOPLEFT", tx + tw / 2 + s * (kw - 5), y - 25)
            end
            local t = pool:Text(28, c.ink, UI.HEAD, "CENTER")
            t:SetText(ch.title)
            t:SetWidth(tw - 20)
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 10, y - 42)
            local s = pool:Text(10, c.inkFaint, UI.FONT, "CENTER")
            s:SetText(ch.sub:upper())
            s:SetWidth(tw)
            s:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 118)
            UI.PageDivider(pool, canvas, tx + tw / 2, y - 144, 260)
        elseif it.t == "day" then
            -- small red tab with the day number, right aligned
            local n = pool:Text(10, c.redInk, UI.HEAD, "CENTER")
            n:SetText(format(L["Day %d"], it.day):upper())
            local tabW = n:GetStringWidth() + 14
            local tab = pool:Rect(c.redInk, 0)      -- room for the day number, drawn as gold text only
            tab:SetSize(tabW, 15)
            tab:SetPoint("TOPRIGHT", canvas, "TOPLEFT", textX + TCW, y - 4)
            n:SetPoint("CENTER", tab, "CENTER", 0, 0)
            local d = pool:Text(17, c.redInk, UI.HEAD)
            d:SetText(WFD:LongDate(it.day))
            UI.FitText(d, TCW - tabW - 6, 17, 13, UI.HEAD)   -- a long date shrinks instead of being cut
            d:SetWordWrap(false)
            d:SetWidth(TCW - tabW - 6)
            d:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y - 2)
            local has = WFD.C.dayNotes and WFD.C.dayNotes[it.day]
            -- a quill in front of the words makes it read as a button
            local quill = "|T" .. UI.Icon("quill") .. ":15:15:0:-2:64:64:5:59:5:59|t "
            local ln = pool:Link(quill .. (has and L["edit note"] or L["+ note"]), function() UI:EditDayNote(it.day) end, 13, c.redInk)
            ln:SetJustifyH("RIGHT")
            ln:SetPoint("TOPRIGHT", canvas, "TOPLEFT", textX + TCW, y - 25)
            local p = pool:Text(9, c.inkSoft, UI.FONT)
            p:SetText((it.place or ""):upper() .. (it.time and ("   |cffc2a880" .. it.time .. "|r") or ""))
            p:SetWordWrap(false)
            local pw = TCW - ln:GetStringWidth() - 12
            -- the place alone, if place and time together are too wide for the line
            if it.time and p.GetUnboundedStringWidth and p:GetUnboundedStringWidth() > pw then
                p:SetText((it.place or ""):upper())
            end
            p:SetWidth(pw)
            p:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y - 26)
            local r = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.6 }, { 0.91, 0.76, 0.42, 0.04 })
            r:SetSize(TCW, 1)
            r:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y - 41)
            local r2 = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, 0.25 }, { 0.91, 0.76, 0.42, 0 })
            r2:SetSize(TCW * 0.6, 1)
            r2:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y - 44)
            local hot = pool:Hot({ WFD:LongDate(it.day), L["Click to read this day aloud in chat."] }, function()
                print("|cffffd100" .. WFD:LongDate(it.day) .. ":|r " .. story(it.day):gsub("\n\n", " "))
            end)
            hot:SetPoint("TOPLEFT", d, "TOPLEFT", -4, 4)
            hot:SetPoint("BOTTOMRIGHT", tab, "BOTTOMRIGHT", 2, -2)
        elseif it.t == "facts" then
            local fs = pool:Text(12, c.inkSoft, UI.FONT)
            fs:SetWidth(TCW)
            fs:SetText(factsText(it.list, TCW))
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y - 2)
        elseif it.t == "para" then
            local fs = pool:Text(FONT_SIZE, c.ink, UI.FONT)
            fs:SetSpacing(SPACING)
            fs:SetWidth(TCW - 8)           -- the same width the layout measured with
            fs:SetText(it.first and redFirstSentence(it.text) or it.text)
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y)
        elseif it.t == "dropcap" then
            -- a large gold initial standing free, its top level with the first line, close to the rest of the word
            local cap = pool:Text(CAP_SIZE, c.redInk, UI.HEAD, "LEFT")
            cap:SetShadowColor(0, 0, 0, 0.8)
            cap:SetShadowOffset(1, -1)
            cap:SetText(it.letter)
            cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX - 1, y + 5)
            local fs = pool:Text(FONT_SIZE, c.ink, UI.FONT)
            fs:SetSpacing(SPACING)
            fs:SetWidth(TCW - 8 - it.capW)
            fs:SetText(redFirstSentence(it.text))
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX + it.capW, y)
        elseif it.t == "tasks" then
            local rows, th = taskRowHeights(it.ch.list, TCW - 26 - 52)
            local bg = pool:Rect(c.paperDk, 0.40)
            bg:SetSize(TCW, th)
            bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y)
            local bar = pool:Rect(c.good, 0.85)
            bar:SetSize(3, th)
            bar:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y)
            local cap = pool:Text(9, c.good, UI.FONT)
            cap:SetText(L["Tasks of the day"]:upper())
            cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX + 10, y - 7)
            local today = it.day == WFD:NumDays()
            local offset = 22
            for i, task in ipairs(it.ch.list) do
                local ry = y - offset
                offset = offset + rows[i]
                local done = it.ch.done[i]
                local box = pool:Rect(c.inkSoft, 0.9)
                box:SetSize(11, 11)
                box:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX + 10, ry - 1)
                local inner = pool:Rect(UI.THEME == "parchment" and { 0.95, 0.90, 0.76 } or { 0.10, 0.07, 0.04 }, 1, "ARTWORK", 1)
                inner:SetSize(9, 9)
                inner:SetPoint("CENTER", box, "CENTER")
                if done then
                    local tick = pool:Icon("Interface\\Buttons\\UI-CheckBox-Check", 19, "ARTWORK", 2)
                    tick:SetTexCoord(0, 1, 0, 1)
                    tick:SetVertexColor(unpack(UI.THEME == "parchment" and { 0.16, 0.40, 0.10, 1 } or { 0.58, 0.80, 0.45, 1 }))
                    tick:SetPoint("CENTER", box, "CENTER", 2, 2)
                end
                local t = pool:Text(11, done and c.inkSoft or c.ink, UI.FONT)
                t:SetText(WFD:ChallengeText(task))
                t:SetWidth(TCW - 26 - 52)
                t:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX + 26, ry)
                local v, g
                if today and not done then v, g = WFD:ChallengeProgress(it.day, task) end
                if g and g > 1 then
                    local pv = pool:Text(10, c.inkFaint, UI.FONT, "RIGHT")
                    pv:SetText(WFD:TaskValueText(task, v) .. " / " .. g)
                    pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", textX + TCW - 6, ry)
                end
            end
        elseif it.t == "flashback" then
            local bg = pool:Rect(c.paperDk, 0.40)
            bg:SetSize(TCW, 54)
            bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y)
            local bar = pool:Rect(c.redInk, 0.8)
            bar:SetSize(3, 54)
            bar:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y)
            local cap = pool:Text(9, c.redInk, UI.FONT)
            cap:SetText(format(L["Today, %d days ago"], it.fb.n):upper())
            cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX + 10, y - 6)
            local t = pool:Text(12, c.ink, UI.FONT)
            t:SetWidth(TCW - 18)
            if t.SetMaxLines then t:SetMaxLines(2) end
            t:SetText(it.fb.text)
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX + 10, y - 20)
            local p = UI.book and UI.book.dayPage[it.fb.day]
            local hot = pool:Hot({ format(L["Today, %d days ago"], it.fb.n), L["Click to read this day."] }, p and function() UI:GoToPage(p) end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y)
            hot:SetSize(TCW, 54)
        elseif it.t == "picture" then
            local lab = pool:Text(9, c.inkFaint, UI.FONT)
            lab:SetText(L["A painted memory"]:upper())
            lab:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y - 2)
            local pic = pool:Painting(TCW, 132)
            pic:SetSize(TCW, 132)
            pic:SetFrameLevel(canvas:GetFrameLevel() + 2)
            pic:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y - 16)
            pic:Paint(it.ev)
        elseif it.t == "mynote" then
            local fs = pool:Text(FONT_SIZE, UI.NoteInk(), UI.FONT)
            fs:SetSpacing(SPACING)
            fs:SetWidth(TCW - 8)
            fs:SetText(it.text)
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", textX, y)
            local bar = pool:Rect(UI.NoteInk(), 0.35)
            bar:SetSize(2, fs:GetStringHeight())
            bar:SetPoint("TOPRIGHT", fs, "TOPLEFT", -5, 0)
        elseif it.t == "keep" then
            -- the day the keepsakes belong to: they may stand beside the next day's entry
            UI.SectionHead(pool, canvas, textX, TCW, y - 2, 18, L["Kept as a memory"], it.day and format(L["Day %d"], it.day) or nil)
            drawKeep(pool, canvas, textX, y - 24, it.keep, TCW)
        elseif it.t == "flourish" then
            local cx = textX + TCW / 2
            for i = -1, 1 do
                local dmd = pool:Diamond(i == 0 and 6 or 4, i == 0 and c.redInk or c.inkFaint)
                dmd:SetPoint("CENTER", canvas, "TOPLEFT", cx + i * 14, y - 14)
            end
        elseif it.t == "empty" then
            local e = pool:Text(15, c.inkFaint, UI.FONT, "CENTER")
            e:SetText(L["The pages are still empty. Go and live an adventure!"])
            e:SetWidth(tw)
            e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 120)
        end
    end

    -- margin notes, stacked so they never overlap
    local lastBottom = 0
    for _, group in ipairs(page.notes) do
        local ny = max(group.y, lastBottom)
        for _, note in ipairs(group.list) do
            if ny + 15 > UI.AREA_H then break end
            local fs = pool:Text(10, note[2], UI.FONT, side == "left" and "RIGHT" or "LEFT")
            fs:SetText(note[1])
            UI.FitText(fs, NOTE_W - 18, 10, 8, UI.FONT)   -- long words in some languages shrink instead of being cut
            fs:SetWidth(NOTE_W - 18)          -- keeps clear of the margin rule and the text
            fs:SetWordWrap(false)
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", noteX, top - ny)
            ny = ny + 15
        end
        lastBottom = ny + 8
    end
    -- a faint margin rule, starting below a chapter heading and fading out at both ends
    local ruleY = 0
    for _, it in ipairs(page.items) do
        if it.t == "chapter" then ruleY = it.y + H_CHAPTER - 6 end
    end
    local ruleX = side == "left" and (textX - 8) or (textX + TCW + 4)
    local ruleH = UI.AREA_H - ruleY
    if ruleH > 40 then
        local fadeTop = pool:Grad("VERTICAL", { 0.78, 0.60, 0.26, 0.35 }, { 0.78, 0.60, 0.26, 0 })
        fadeTop:SetSize(1, 24)
        fadeTop:SetPoint("TOPLEFT", canvas, "TOPLEFT", ruleX, top - ruleY)
        local rule = pool:Rect({ 0.78, 0.60, 0.26 }, 0.35)
        rule:SetSize(1, ruleH - 48)
        rule:SetPoint("TOPLEFT", canvas, "TOPLEFT", ruleX, top - ruleY - 24)
        local fadeBot = pool:Grad("VERTICAL", { 0.78, 0.60, 0.26, 0 }, { 0.78, 0.60, 0.26, 0.35 })
        fadeBot:SetSize(1, 24)
        fadeBot:SetPoint("TOPLEFT", canvas, "TOPLEFT", ruleX, top - UI.AREA_H + 24)
    end
end)

------------------------------------------------------------------------
-- Writing your own thoughts into a day
------------------------------------------------------------------------
function UI:EditDayNote(day)
    local pop = self.dayNotePop
    if not pop then
        pop = UI.Frame(UIParent, 440, 300)
        pop:SetPoint("CENTER")
        pop:SetFrameStrata("DIALOG")
        pop:EnableMouse(true)
        pop:SetMovable(true)
        pop:RegisterForDrag("LeftButton")
        pop:SetScript("OnDragStart", pop.StartMoving)
        pop:SetScript("OnDragStop", pop.StopMovingOrSizing)
        UI.Backdrop(pop, "dialog", 32, 11, c.paper, { 1, 0.92, 0.80, 1 })
        _G.WoWForeverDiaryDayNote = pop
        tinsert(UISpecialFrames, "WoWForeverDiaryDayNote")
        pop.title = UI.Text(pop, 20, c.ink, "CENTER", UI.HEAD)
        pop.title:SetPoint("TOP", 0, -24)
        pop.sub = UI.Caps(pop, L["My own thoughts:"], 9, c.redInk)
        pop.sub:SetJustifyH("CENTER")
        pop.sub:SetPoint("TOP", 0, -52)
        local inset = UI.Inset(pop, 396, 170)
        inset:SetPoint("TOP", 0, -70)
        local sf = CreateFrame("ScrollFrame", nil, inset)
        sf:SetPoint("TOPLEFT", 10, -10)
        sf:SetPoint("BOTTOMRIGHT", -10, 10)
        local eb = CreateFrame("EditBox", nil, sf)
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false)
        eb:SetMaxLetters(2000)
        eb:SetFont(UI.FONT, 13, "")
        eb:SetTextColor(unpack(UI.NoteInk()))
        eb:SetShadowOffset(0, 0)
        eb:SetWidth(372)
        sf:SetScrollChild(eb)
        eb:SetScript("OnEscapePressed", function() pop:Hide() end)
        local hot = CreateFrame("Button", nil, inset)
        hot:SetAllPoints()
        hot:SetScript("OnClick", function() eb:SetFocus() end)
        sf:SetFrameLevel(hot:GetFrameLevel() + 1)
        pop.edit = eb
        local save = UI.InkButton(pop, L["Save"], function()
            local C = WFD.C
            C.dayNotes = C.dayNotes or {}
            local text = pop.edit:GetText() or ""
            C.dayNotes[pop.day] = text:find("%S") and text or nil
            pop:Hide()
            UI:Reflow()
        end, 16, c.redInk)
        save:SetPoint("BOTTOMRIGHT", -40, 24)
        local cancel = UI.InkButton(pop, L["Cancel"], function() pop:Hide() end, 16, c.inkSoft)
        cancel:SetPoint("BOTTOMLEFT", 40, 24)
        self.dayNotePop = pop
    end
    pop.day = day
    pop.title:SetText(WFD:LongDate(day))
    pop.edit:SetText(WFD.C.dayNotes and WFD.C.dayNotes[day] or "")
    pop:Show()
    pop.edit:SetFocus()
end
