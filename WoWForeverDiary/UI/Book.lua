-- The book: closed cover as start screen, the open book with two pages, page turning,
-- thumb index, ribbon bookmark and the pagination of all sections.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, ceil, format = math.floor, math.max, math.min, math.ceil, string.format

-- geometry ------------------------------------------------------------
local PW, PH, GUT, BRD = 420, 560, 22, 18
UI.PW, UI.PH = PW, PH
UI.TOP, UI.BOTTOM = 50, 54                  -- text area inside a page
UI.AREA_H = PH - UI.TOP - UI.BOTTOM
UI.INNER, UI.OUTER = 38, 34                 -- margins at the spine / at the outer edge
local BW, BH = PW * 2 + GUT + BRD * 2, PH + BRD * 2

UI.renderers = {}
UI.sections = {}
UI.spread = 1

function UI:RegisterRenderer(kind, fn) self.renderers[kind] = fn end

-- The order of the book, in one place: the parts in groups, from what you open every day to what you
-- look things up in. Each group has its own tab colour and a heading in the contents.
-- Every group but the front one has a tab of its own that leads to its overview page (PagesToday.lua).
UI.GROUPS = {
    { key = "front",     col = { 0.45, 0.28, 0.14 } },
    { key = "goals",     col = { 0.66, 0.48, 0.10 }, label = "Goals and honour", icon = "album" },
    { key = "chronicle", col = { 0.40, 0.20, 0.50 }, label = "Chronicle", icon = "records" },
    { key = "world",     col = { 0.20, 0.42, 0.20 }, label = "The world", icon = "atlas" },
    { key = "hunt",      col = { 0.56, 0.12, 0.08 }, label = "Hunt and loot", icon = "beast" },
    { key = "people",    col = { 0.16, 0.32, 0.54 }, label = "People and money", icon = "party" },
    { key = "back",      col = { 0.34, 0.27, 0.20 }, label = "Keepsakes", icon = "kin" },
}
UI.GROUP = {}
for i, g in ipairs(UI.GROUPS) do g.index = i; UI.GROUP[g.key] = g end
-- part = { group, order, line on the group's overview page }. Parts have no tab of their own:
-- the tabs are Contents, Today, Diary, Quest book and one per group.
local LAYOUT = {
    memoriam = { "front", 1 }, quests = { "front", 3, "Tasks taken and done" },
    tasks = { "goals", 4.8, "Day, week and month" },
    collection = { "goals", 5, "What is left to discover" }, honour = { "goals", 6, "Honour points" },
    milestones = { "chronicle", 10, "The great moments of a life" }, firsts = { "chronicle", 11, "Every first, with its day and place" },
    records = { "chronicle", 12, "The best and the worst of days" },
    levels = { "chronicle", 13, "How long each level took" }, gallery = { "chronicle", 14, "Moments, painted in the gear of their day" },
    atlas = { "world", 19, "Regions explored" }, maps = { "world", 20, "Map of my travels" },
    landmarks = { "world", 21, "Famous places of Azeroth" }, gathering = { "world", 22, "Where the good things grow" },
    runs = { "world", 25, "Dark places, rich rewards" },
    bestiary = { "hunt", 30, "A collector's album of every creature slain" },
    fates = { "hunt", 31, "Every fall on the way" }, nemesis = { "hunt", 32, "They sent me to the spirit healer" },
    fishbook = { "hunt", 33, "A collector's album of everything the line brought up" }, treasures = { "hunt", 35, "Best find for every slot" },
    people = { "people", 40, "Everyone I met on my way" }, companions = { "people", 45, "Who walked beside me" },
    ledger = { "people", 50, "Every coin, in and out" },
    family = { "back", 86, "Who got there first?" }, capsule = { "back", 88, "Letters to my future self" },
    notes = { "back", 90, "How this book is kept" },
}

-- def = { key, label, icon, order, build = function(book) ... end }
function UI:RegisterSection(def)
    local lay = LAYOUT[def.key]
    if lay then
        def.group, def.order, def.sub = lay[1], lay[2], lay[3]
        if def.key ~= "quests" then def.thumb = false end
    end
    def.group = def.group or "back"
    self.sections[#self.sections + 1] = def
    table.sort(self.sections, function(a, b) return a.order < b.order end)
end

-- x of the text column on a page side
function UI.TextX(side) return side == "left" and UI.OUTER or UI.INNER end
function UI.TextW() return PW - UI.INNER - UI.OUTER end

------------------------------------------------------------------------
-- Text measuring for pagination
------------------------------------------------------------------------
local measureFrame = CreateFrame("Frame", nil, UIParent)
measureFrame:SetSize(10, 10)
measureFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -2000, 2000)
measureFrame:SetAlpha(0)
local mfs = measureFrame:CreateFontString(nil, "OVERLAY")
local measureCache = {}

function UI.Measure(text, size, width, spacing, font)
    local key = (font or UI.HEAD) .. size .. ":" .. width .. ":" .. (spacing or 0) .. ":" .. text
    local v = measureCache[key]
    if v then return v end
    mfs:SetFont(font or UI.HEAD, size, "")
    mfs:SetSpacing(spacing or 0)
    mfs:SetWidth(width)
    mfs:SetText(text)
    v = mfs:GetStringHeight() or 0
    if v <= 0 then
        -- fallback estimate if the client cannot measure hidden text
        local lines = ceil((#text * size * 0.48) / width)
        v = lines * (size + (spacing or 0))
    end
    measureCache[key] = v
    return v
end

function UI.MeasureWidth(text, size, font)
    mfs:SetFont(font or UI.HEAD, size, "")
    mfs:SetSpacing(0)
    mfs:SetWidth(0)
    mfs:SetText(text)
    local w = mfs:GetStringWidth() or 0
    if w <= 0 then w = size * 0.75 * #text end
    return w
end

function UI.ClearCaches()
    measureCache = {}
    UI.storyCache = {}
end
UI.storyCache = {}

------------------------------------------------------------------------
-- Pagination
------------------------------------------------------------------------
local Book = {}
Book.__index = Book

function Book:Add(page)
    self.pages[#self.pages + 1] = page
    page.index = #self.pages
    page.section = page.section or self.curSection
    return page
end

-- make sure the next page is a left page
function Book:PadToLeft(key)
    if #self.pages % 2 == 1 then self:Add({ kind = "blank", noteKey = "before:" .. (key or "?") }) end
end

function Book:Start(key)
    self.sectionStart[key] = #self.pages + 1
    self.curSection = key
end

UI.TITLE_H = 116        -- the room a section title takes on its first page

-- Rows of different heights over as many pages of one kind as needed, the first page leaving room for the
-- title. A row keeps r.keep more room free below it (a heading never stays alone at the foot of a page).
-- extra goes onto every page (head, counts ...). Returns the last page.
-- A last page with only a few rows on it (one entry alone on a spread of its own) is avoided: the rows then
-- move a little closer together, by a tenth at most, if that brings them onto the pages before.
-- carry(r), if given, may return a row to repeat at the top of a page that begins with r (a day heading).
local function planRows(list, scale, carry)
    local pages, cur, y = {}, nil, 0
    local function newPage(first)
        cur = {}
        pages[#pages + 1] = cur
        y = first and UI.TITLE_H or 0
    end
    local function put(r)
        local h = floor(r.h * scale + 0.5)
        cur[#cur + 1] = { r = r, y = y, h = h }
        y = y + h
    end
    newPage(true)
    for _, r in ipairs(list) do
        local h = floor(r.h * scale + 0.5)
        if y + h + floor((r.keep or 0) * scale + 0.5) > UI.AREA_H then
            newPage(false)
            local head = carry and carry(r)
            if head then put(head) end
        end
        put(r)
    end
    return pages, y
end

function Book:AddRows(kind, list, extra, carry)
    local plan, lastY = planRows(list, 1, carry)
    if #plan > 1 and lastY <= UI.AREA_H * 0.25 then
        for _, scale in ipairs({ 0.95, 0.9 }) do
            local tighter = planRows(list, scale, carry)
            if #tighter < #plan then plan = tighter break end
        end
    end
    local page
    for i, rows in ipairs(plan) do
        page = self:Add({ kind = kind, rows = {}, first = (i == 1), numbered = true })
        for k, v in pairs(extra or {}) do if page[k] == nil then page[k] = v end end
        for _, p in ipairs(rows) do
            p.r.y, p.r.h = p.y, p.h
            page.rows[#page.rows + 1] = p.r
        end
    end
    return page
end

function UI.PageNumber(index) return index - 1 end

-- a click that turns to the page of a diary day (nil when the day has no page)
function UI.DayGo(day)
    local p = day and UI.book and UI.book.dayPage[day]
    return p and function() UI:GoToPage(p) end
end

-- What the pages show of the live diary, in one string. Many trackers set WFD.dirty for things no page
-- shows (a roster that did not change, a ticker); only a change here is worth the note "New in the diary".
function UI.Fingerprint()
    local C = WFD.C
    if not C then return "" end
    local d = WFD:Day()
    return table.concat({ #(C.events or {}), d.killTotal or 0, #(d.qd or {}), d.xp or 0, C.wealth or 0,
        C.itemTotal or 0, C.npcCount or 0, C.deathTotal or 0, C.questTotal or 0 }, ":")
end

function UI:Paginate()
    UI.shownPrint = UI.Fingerprint()
    local book =setmetatable({ pages = {}, dayPage = {}, sectionStart = {}, toc = {} }, Book)
    book:Add({ kind = "endpaper" })
    book:Add({ kind = "owner" })

    local chapters = UI.Chapters()

    -- table of contents: reserve the pages first, fill them at the end.
    -- Heights as the contents page draws them: a chapter with its sub line 36, the appendix heading 36,
    -- a part of the appendix 26; the first page loses the room of its title.
    local TOC_FIRST, TOC_NEXT = UI.AREA_H - 76, UI.AREA_H
    -- a part of the appendix 22, a group heading 20; only the parts that are in the book count,
    -- and only the groups with a heading
    local function entryH(e) return e.group and 20 or ((e.header or e.sub) and 36 or 22) end
    local present = 0
    for _, sec in ipairs(self.sections) do
        -- the overview pages of the groups are reached through their headings, "Today" is one line
        if not sec.index and (not sec.enabled or sec.enabled()) then present = present + 1 end
    end
    local headings = 0
    for _, g in ipairs(UI.GROUPS) do if g.label then headings = headings + 1 end end
    local need = 22 + #chapters * 36 + 36 + present * 22 + headings * 20
    local tocPages = 1 + max(0, ceil((need - TOC_FIRST) / TOC_NEXT))
    book:Start("toc")
    local tocList = {}
    for i = 1, tocPages do
        tocList[i] = book:Add({ kind = "toc", first = (i == 1), entries = {}, numbered = true })
    end

    -- "Today" comes right after the contents, before the diary
    for _, sec in ipairs(self.sections) do
        if sec.key == "today" then
            book:PadToLeft("today")
            book:Start("today")
            local ok, err = pcall(sec.build, book)
            if not ok then WFD:Error("section today", err) end
        end
    end

    book:PadToLeft("diary")
    book:Start("diary")
    UI.LayoutDiary(book, chapters)

    for _, sec in ipairs(self.sections) do
      if sec.key ~= "today" and (not sec.enabled or sec.enabled()) then
        -- spreads start on a left page, the rest flows on (a note page someone already wrote on stays)
        local wrote = WFD.C.notes and WFD.C.notes["before:" .. sec.key]
        if sec.leftStart or wrote then book:PadToLeft(sec.key) end
        book:Start(sec.key)
        local ok, err = pcall(sec.build, book)
        if not ok then WFD:Error("section " .. sec.key, err) end
      end
    end
    if #book.pages % 2 == 1 then book:Add({ kind = "endpaper" }) end

    -- fill the table of contents
    local all = {}
    if book.sectionStart.today then
        all[#all + 1] = { text = L["Today"], page = book.sectionStart.today, icon = "quill" }
    end
    for i, ch in ipairs(chapters) do
        all[#all + 1] = { text = ch.roman .. ".  " .. ch.title, sub = ch.sub, page = ch.page }
    end
    all[#all + 1] = { header = true, text = L["Appendix"] }
    local lastGroup
    for _, sec in ipairs(self.sections) do
        if book.sectionStart[sec.key] and not sec.index and sec.key ~= "today" then
            local g = UI.GROUP[sec.group]
            if g and g.key ~= lastGroup and g.label then
                -- the heading of a group leads to its overview page
                all[#all + 1] = { group = true, text = L[g.label], col = g.col, page = book.sectionStart["grp_" .. g.key] }
            end
            lastGroup = sec.group
            -- a part that has nothing in it yet stands dimmed
            local empty = UI.IsEmptyPart and UI.IsEmptyPart(sec.key)
            all[#all + 1] = { text = L[sec.label], page = book.sectionStart[sec.key], icon = sec.icon, dim = empty or nil }
        end
    end
    local ti, room = 1, TOC_FIRST
    for _, e in ipairs(all) do
        local h = entryH(e)
        -- a group heading never stays alone at the foot of a page
        if (h > room or (e.group and h + 22 > room)) and tocList[ti + 1] then
            ti = ti + 1
            room = TOC_NEXT
        end
        local tp = tocList[ti]
        tp.entries[#tp.entries + 1] = e
        room = room - h
    end

    self.book = book
    return book
end

------------------------------------------------------------------------
-- Navigation
------------------------------------------------------------------------
function UI:NumSpreads()
    return self.book and ceil(#self.book.pages / 2) or 1
end

function UI:GoToPage(index)
    if not index then return end
    local s = ceil(index / 2)
    local same = (s == self.spread)
    if not same and (self.spread or 0) > 0 then
        self.history = self.history or {}
        table.insert(self.history, self.spread)
        if #self.history > 30 then table.remove(self.history, 1) end
    end
    self:ShowSpread(s)
    -- show which of the two pages was meant; when the spread is already open, this is all that happens,
    -- so the page also turns in again and rustles
    self:PointAt(index % 2 == 1 and "left" or "right", same)
end

function UI:TodayPage()
    local b = self.book
    if not b then return 1 end
    local best
    for day, p in pairs(b.dayPage) do
        if not best or day > best then best = day end
    end
    return best and b.dayPage[best] or b.sectionStart.diary or 1
end

function UI:GoToDay(day)
    if self.book and self.book.dayPage[day] then self:GoToPage(self.book.dayPage[day]) end
end

-- quiet book sounds, if the client knows them
local function sound(name, fallback)
    local id = SOUNDKIT and SOUNDKIT[name] or fallback
    if id and PlaySound then pcall(PlaySound, id) end
end
UI.Sound = sound

local function fadeIn(frame)
    frame:SetAlpha(0)
    frame.fadeT = 0
    frame:SetScript("OnUpdate", function(self, dt)
        self.fadeT = self.fadeT + dt
        local a = min(1, self.fadeT / 0.22)
        self:SetAlpha(a)
        if a >= 1 then self:SetScript("OnUpdate", nil) end
    end)
end

-- traces of use on a page, more of them the older the book: a mug ring and foxing, both kept to the margins.
-- Always the same traces on the same page.
local function hash(n, salt) return ((n * 2654435761 + salt * 40503) % 997) / 997 end
-- the worn look of the parchment: stains of a hard life - blood, sweat and tears - kept to the margins, so no
-- text lies on them. The same on the same page every time. (An edge made of dots looked bad: left out.)
local function drawWornParchment(pool, canvas, side, index)
    local function R(n, salt) return hash(index * 131 + n, salt) end
    -- stains in the margins: the zone is chosen by the page, so they never sit under the writing
    local function spot(k)
        local zone = floor(R(k, 21) * 3)
        local x, y
        if zone == 0 then      -- the outer strip
            x = (side == "left") and (14 + 34 * R(k, 22)) or (PW - 14 - 34 * R(k, 22))
            y = 50 + (PH - 100) * R(k, 23)
        elseif zone == 1 then  -- the foot, away from the page number
            x = (R(k, 22) < 0.5) and (30 + 70 * R(k, 24)) or (PW - 30 - 70 * R(k, 24))
            y = PH - 22 - 30 * R(k, 23)
        else                   -- the head, away from the path
            x = (R(k, 22) < 0.5) and (30 + 60 * R(k, 24)) or (PW - 30 - 60 * R(k, 24))
            y = 14 + 16 * R(k, 23)
        end
        return x, y
    end
    -- the stains are one painted picture (Media\stains.tga, made by tools/gen_stains.py) of four cells:
    -- blood, a second blood splash, sweat and tears. Some pages are mirrored, so no two look alike.
    local STAINS = "Interface\\AddOns\\" .. ADDON .. "\\Media\\stains"
    -- reach = how far the visible stain reaches from the middle of its picture, as a part of the size: the
    -- middle is moved in so that it never lies beyond the torn edge of the paper
    local EDGE = 18
    local function stain(cellX, cellY, size, x, y, alpha, k, reach)
        local r = size * reach
        x = max(EDGE + r, min(PW - EDGE - r, x))
        y = max(EDGE + r, min(PH - EDGE - r, y))
        local t = pool:Icon(STAINS, size, "BACKGROUND", 2)
        local u0, v0 = cellX * 0.5, cellY * 0.5
        local mirrorX, mirrorY = R(k, 61) < 0.5, R(k, 62) < 0.5
        t:SetTexCoord(mirrorX and u0 + 0.5 or u0, mirrorX and u0 or u0 + 0.5, mirrorY and v0 + 0.5 or v0, mirrorY and v0 or v0 + 0.5)
        t:SetAlpha(alpha)
        t:SetPoint("CENTER", canvas, "TOPLEFT", x, -y)
    end
    -- blood: a splash with spray and a drip
    if R(1, 31) < 0.38 then
        local x, y = spot(1)
        stain(R(1, 33) < 0.5 and 0 or 1, 0, 100 + 40 * R(1, 34), x, y, 0.85, 1, 0.30)
    end
    -- sweat: salty tide marks
    if R(2, 41) < 0.42 then
        local x, y = spot(2)
        stain(0, 1, 80 + 50 * R(2, 42), x, y, 0.9, 2, 0.30)
    end
    -- tears: small rings with a paler middle
    if R(3, 51) < 0.42 then
        local x, y = spot(3)
        stain(1, 1, 90 + 40 * R(3, 52), x, y, 0.9, 3, 0.38)
    end
end

function UI.DrawWear(pool, canvas, side, index)
    if UI.THEME == "parchment" and index > 2 then drawWornParchment(pool, canvas, side, index) end
    local w = UI.Wear and UI.Wear() or 0
    if w <= 0 or index <= 2 then return end
    -- a ring left by a mug: small dots around a circle, in the lower outer corner where no text stands
    if hash(index, 1) < w * 0.30 then
        local cx = (side == "left") and (24 + 30 * hash(index, 2)) or (PW - 24 - 30 * hash(index, 2))
        local cy = PH - 30 - 24 * hash(index, 3)
        local r = 22 + 14 * hash(index, 4)
        local a = 0.06 + 0.07 * w
        for k = 0, 23 do
            local ang = k / 24 * math.pi * 2
            local wob = 1 + 0.06 * math.sin(ang * 3 + index)
            local d = pool:Circle(5 + 2 * hash(index * 31 + k, 5), { 0.32, 0.19, 0.07, a * (0.6 + 0.6 * hash(k, index)) }, "BACKGROUND", 1)
            d:SetPoint("CENTER", canvas, "TOPLEFT", cx + math.cos(ang) * r * wob, -(cy + math.sin(ang) * r * wob))
        end
    end
    -- foxing: little brown spots near the edges
    if w > 0.2 then
        for k = 1, floor(hash(index, 6) * 6 * w) do
            local x = (side == "left") and (14 + 60 * hash(index + k, 7)) or (PW - 14 - 60 * hash(index + k, 7))
            local y = 30 + (PH - 60) * hash(index * 7 + k, 8)
            local s = 2 + 4 * hash(index + k, 9)
            local d = pool:Circle(s, { 0.36, 0.22, 0.09, 0.14 + 0.10 * w }, "BACKGROUND", 1)
            d:SetPoint("CENTER", canvas, "TOPLEFT", x, -y)
        end
    end
    -- (the folded upper corner is no wear any more: it is the bookmark, see Comfort.lua)
end

-- the steps of the path above a page: the group, the part, and what the page itself adds (a chapter, an area)
function UI:CrumbItems(page, index)
    local key, b = page.section, self.book
    if not key or not b or page.kind == "endpaper" or page.kind == "owner" then return nil end
    local items = {}
    if key == "toc" then
        items[1] = { text = L["Contents"] }
    elseif key == "diary" then
        items[1] = { text = L["Diary"], page = b.sectionStart.diary }
    else
        local sec
        for _, sc in ipairs(self.sections) do if sc.key == key then sec = sc break end end
        if not sec then return nil end
        local g = UI.GROUP[sec.group]
        if g and g.label then
            items[#items + 1] = { text = L[g.label], page = b.sectionStart["grp_" .. g.key] }
        end
        if not sec.index then
            items[#items + 1] = { text = L[sec.label], page = b.sectionStart[key] }
        end
    end
    -- a chapter of the diary, an area of the albums: what the running head said
    local head = page.head
    local last = items[#items]
    if head and last and head:lower() ~= last.text:lower() and L[head]:lower() ~= last.text:lower() then
        items[#items + 1] = { text = L[head] }
    end
    return #items > 0 and items or nil
end

function UI:RenderPage(side, index)
    local pg = self.pageFrames[side]
    local pool = pg.pool
    pool:Begin()
    local page = self.book and self.book.pages[index]
    if not page then pool:End() return end
    if UI.HideMarble then UI.HideMarble(pg.canvas) end
    UI.DrawWear(pool, pg.canvas, side, index)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.numbered ~= false and page.kind ~= "endpaper" and page.kind ~= "owner" then
        local n = pool:Text(13, c.inkFaint, UI.HEAD, "CENTER")
        n:SetText("~ " .. UI.PageNumber(index) .. " ~")
        n:SetPoint("BOTTOM", pg.canvas, "BOTTOMLEFT", tx + tw / 2, 22)
        local toc = self.book.sectionStart.toc
        if toc and page.kind ~= "toc" then
            -- a click on the number asks for a page; the contents are a right-click away
            local hot = pool:Hot({ format(L["Page %d"], UI.PageNumber(index)), L["Click to go to a page."],
                L["Right-click for the contents."], L["Ctrl-click to set or remove a bookmark here."] },
                function()
                    if IsControlKeyDown() and UI.ToggleMark then UI:ToggleMark(index) return end
                    if UI.AskPage then UI:AskPage() else UI:GoToPage(toc) end
                end)
            hot.onRight = function() UI:GoToPage(toc) end
            hot:SetPoint("TOPLEFT", n, "TOPLEFT", -6, 4)
            hot:SetPoint("BOTTOMRIGHT", n, "BOTTOMRIGHT", 6, -4)
        end
    end
    local fn = self.renderers[page.kind]
    UI.titled = false          -- set by UI.PageTitle
    if fn then
        local ok, err = pcall(fn, pool, page, side, pg.canvas, index)
        if not ok then WFD:Error("page " .. page.kind, err) end
    end
    -- where this page lies: "Hunt and loot > Bestiary", each step before the current one a link
    local items = self:CrumbItems(page, index)
    if items then
        local size = UI.FS(11)
        local sep = " > "
        local function total()
            local w = 0
            for i, it in ipairs(items) do
                it.w = UI.MeasureWidth(it.text, size, UI.FONT)
                w = w + it.w + (i > 1 and UI.MeasureWidth(sep, size, UI.FONT) or 0)
            end
            return w
        end
        local width = total()
        while width > tw and #items > 1 do      -- too long for the page: the first steps drop out
            table.remove(items, 1)
            width = total()
        end
        local x = tx + max(0, (tw - width) / 2)
        for i, it in ipairs(items) do
            if i > 1 then
                local sp = pool:Text(11, c.inkFaint, UI.FONT)
                sp:SetText(sep)
                sp:SetPoint("TOPLEFT", pg.canvas, "TOPLEFT", x, -21)
                x = x + UI.MeasureWidth(sep, size, UI.FONT)
            end
            local fs
            if it.page and i < #items then
                fs = pool:Link(it.text, function() UI:GoToPage(it.page) end, 11, c.inkSoft)
            else
                fs = pool:Text(11, i == #items and c.redInk or c.inkSoft, UI.FONT)
                fs:SetText(it.text)
            end
            fs:SetWordWrap(false)
            fs:SetPoint("TOPLEFT", pg.canvas, "TOPLEFT", x, -21)
            x = x + it.w
        end
        if not UI.titled then
            local r = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0 }, { 0.78, 0.60, 0.26, 0.45 })
            r:SetSize(tw / 2, 1)
            r:SetPoint("TOPLEFT", pg.canvas, "TOPLEFT", tx, -40)
            local r2 = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0.45 }, { 0.78, 0.60, 0.26, 0 })
            r2:SetSize(tw / 2, 1)
            r2:SetPoint("TOPLEFT", pg.canvas, "TOPLEFT", tx + tw / 2, -40)
        end
    elseif page.head and not UI.titled then
        -- the running head, unless the page already carries the part's big title
        local h = pool:Text(9, c.inkFaint, UI.FONT, "CENTER")
        h:SetText(page.head:upper())
        h:SetPoint("TOP", pg.canvas, "TOPLEFT", tx + tw / 2, -24)
        local r = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0 }, { 0.78, 0.60, 0.26, 0.45 })
        r:SetSize(tw / 2, 1)
        r:SetPoint("TOPLEFT", pg.canvas, "TOPLEFT", tx, -38)
        local r2 = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0.45 }, { 0.78, 0.60, 0.26, 0 })
        r2:SetSize(tw / 2, 1)
        r2:SetPoint("TOPLEFT", pg.canvas, "TOPLEFT", tx + tw / 2, -38)
    end
    pool:End()
end

function UI:ShowSpread(s)
    if not self.bookFrame then return end
    s = max(1, min(s or 1, self:NumSpreads()))
    local changed = (s ~= self.spread)
    local old = self.spread
    self.spread = s
    self:RenderPage("left", s * 2 - 1)
    self:RenderPage("right", s * 2)
    if changed then
        local turning = self.spreadShownOnce and (old or 0) > 0 and self.TurnSweep and WFD.S.turnAnim ~= false
        if self.spreadShownOnce then sound("IG_ABILITY_PAGE_TURN", 836) end
        self.spreadShownOnce = true
        if turning then
            -- a leaf is turned over the spine: forwards from right to left, backwards the other way
            self:TurnSweep(s > old and 1 or -1)
        else
            fadeIn(self.pageFrames.left.canvas)
            fadeIn(self.pageFrames.right.canvas)
        end
    end
    self.prevBtn:SetEnabled(s > 1)
    self.nextBtn:SetEnabled(s < self:NumSpreads())
    self:RememberPlace(s)
    self:UpdateThumbs()
    if self.UpdateBack then self:UpdateBack() end
    local today = self:TodayPage()
    self.followToday = (ceil(today / 2) == s)
end

-- Where reading stopped, kept so that it survives a growing book: a diary day, or a page within its section.
-- (Page numbers alone would wander as new days are written in front of the appendix.)
function UI:RememberPlace(s)
    local b, C = self.book, WFD.C
    if not b or not C then return end
    local left = s * 2 - 1
    local page = b.pages[left]
    if not page then return end
    local day
    for d, idx in pairs(b.dayPage) do
        if (idx == left or idx == left + 1) and (not day or d < day) then day = d end
    end
    if s == 1 then
        C.lastPlace = nil
    else
        local start = page.section and b.sectionStart[page.section]
        C.lastPlace = { section = page.section, offset = start and (left - start) or nil, day = day }
        -- the place "continue reading" leads to: the start pages themselves do not count
        if page.section ~= "today" and page.section ~= "toc" then C.resumePlace = C.lastPlace end
    end
end

-- the page of a stored place, or nil if it is gone
local function placeToPage(book, p)
    if not p then return nil end
    if p.day and book.dayPage[p.day] then return book.dayPage[p.day] end
    local start = p.section and book.sectionStart[p.section]
    if start then
        local idx = start + (p.offset or 0)
        local page = book.pages[idx]
        -- still inside the same part of the book (it may have become shorter)
        if page and page.section == p.section then return idx end
        return start
    end
    return nil
end

-- the page to open at: where reading stopped, else the start
function UI.PlacePage(book)
    return placeToPage(book, WFD.C and WFD.C.lastPlace) or 1
end

-- where "continue reading" leads: the page, and in words where it is (nil if nothing was read yet)
function UI.ResumePlace(book)
    local p = WFD.C and WFD.C.resumePlace
    local page = placeToPage(book, p)
    if not page then return nil end
    local label
    if p.day and book.dayPage[p.day] == page then
        label = L["Diary"] .. ", " .. format(L["Day %d"], p.day)
    else
        for _, sec in ipairs(UI.sections) do
            if sec.key == p.section then label = L[sec.label] break end
        end
        label = label or L["Diary"]
    end
    return page, label
end

-- a soft gold glow around one page that fades away
function UI:PointAt(side, again)
    local pg = self.pageFrames and self.pageFrames[side]
    if not pg or not pg.glow then return end
    if again then
        sound("IG_ABILITY_PAGE_TURN", 836)
        fadeIn(pg.canvas)
    end
    local g = pg.glow
    g.t = 0
    g:SetAlpha(1)
    g:Show()
    g:SetScript("OnUpdate", function(self, dt)
        self.t = self.t + dt
        local a = 1 - self.t / 0.9
        if a <= 0 then
            self:SetScript("OnUpdate", nil)
            self:Hide()
        else
            self:SetAlpha(a * a)
        end
    end)
end

function UI:Flip(dir)
    -- what waited while the mouse was on the book is laid out now, with the turn of the page
    if WFD.dirty and self.bookFrame and self.bookFrame:IsShown() and not UI.noteFocus then
        WFD.dirty = false
        if self.freshNote then self.freshNote:Hide() end
        UI.storyCache[WFD:NumDays()] = nil
        local follow = self.followToday
        self:Paginate()
        if follow and dir > 0 then
            self:ShowSpread(math.ceil(self:TodayPage() / 2))
            return
        end
    end
    self:ShowSpread(self.spread + dir)
end

------------------------------------------------------------------------
-- Thumb index (coloured by the groups in UI.GROUPS)
------------------------------------------------------------------------

function UI:ThumbList()
    local list = { { key = "toc", label = L["Contents"], icon = "journal", group = "front" } }
    for _, sec in ipairs(self.sections) do
        if sec.key == "today" then list[#list + 1] = { key = "today", label = L[sec.label], icon = sec.icon, group = "front" } end
    end
    -- the diary tab leads to today's entry (the beginning is one click away in the contents)
    list[#list + 1] = { key = "diary", label = L["Diary"], icon = "quill", target = function() return UI:TodayPage() end,
        hint = L["Click to open today's entry."], group = "front" }
    for _, sec in ipairs(self.sections) do
        if sec.thumb ~= false and sec.key ~= "today" then
            list[#list + 1] = { key = sec.key, label = sec.thumbText and sec.thumbText() or L[sec.label], icon = sec.icon,
                group = sec.group }
        end
    end
    -- the settings have a tab of their own at the very end: no wandering through the keepsakes to find them
    list[#list + 1] = { key = "notes", label = L["Settings"], icon = "settings", group = "settings",
        hint = L["Click to open the settings."] }
    -- the colour of its group; neighbours within a group a shade apart
    local nth, last = 0, nil
    for _, t in ipairs(list) do
        if t.group ~= last then nth, last = 0, t.group end
        nth = nth + 1
        local g = UI.GROUP[t.group] or { col = { 0.30, 0.30, 0.34 } }
        local k = (nth % 2 == 0) and 0.80 or 1
        t.col = { g.col[1] * k, g.col[2] * k, g.col[3] * k }
    end
    return list
end

local TAB_W, TAB_H, TAB_GAP = 66, 38, 4

local function paintTab(t, on, hover)
    local k = on and 1.45 or (hover and 1.2 or 1)
    local r, g, b = min(1, t.col[1] * k), min(1, t.col[2] * k), min(1, t.col[3] * k)
    UI.Gradient(t.body, "HORIZONTAL", { r * 0.45, g * 0.45, b * 0.45, 1 }, { r, g, b, 1 })
    t.cap:SetVertexColor(r, g, b, 1)
    t.ring:SetVertexColor(col4(on and c.gold or { 0.12, 0.07, 0.03, 1 }))
    t.icon:SetDesaturated(false)
    local v = (on or hover) and 1 or 0.78
    t.icon:SetVertexColor(v, v, v)
    t.icon:SetAlpha(1)
    t.trimTop:SetAlpha(on and 0.9 or 0.45)
    t.trimBot:SetAlpha(on and 0.9 or 0.45)
end

-- a tab sticks out further when it is the open one, a little when the mouse is on it, less while pressed
local function placeTab(t)
    local out = t.on and 10 or (t.hover and 5 or 0)
    if t.down then out = out - 3 end
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", UI.bookFrame, "TOPLEFT", BW - BRD - 14 + out, t.y)
end

function UI:UpdateThumbs()
    if not self.thumbs or not self.book then return end
    -- two sections can share a spread now: the tab that was clicked wins while its section is in view,
    -- otherwise the section of the left page
    local left, right = self.spread * 2 - 1, self.spread * 2
    local activeKey, bestStart = nil, 0
    local want = self.wantTab and self.book.sectionStart[self.wantTab]
    if want and (want == left or want == right) then
        activeKey = self.wantTab
    else
        self.wantTab = nil
        for _, t in ipairs(self.thumbs) do
            local st = self.book.sectionStart[t.key]
            if st and st <= left and st > bestStart then activeKey, bestStart = t.key, st end
        end
    end
    for _, t in ipairs(self.thumbs) do
        t.on = (t.key == activeKey)
        placeTab(t)
        paintTab(t, t.on, t.hover)
    end
    if self.PaintNewDots then self:PaintNewDots(activeKey) end
    if UI.RefreshPlates then UI.RefreshPlates() end
end

-- name plates beside all tabs while the mouse is on any of them, so the whole index can be read at a glance;
-- they stay a moment when the mouse crosses the small gap between two tabs
local plateDriver = CreateFrame("Frame")
plateDriver:Hide()
local allPlatesOut = false

-- the parts of a group: a small list beside the tabs while the mouse is on the tab of the group (or on the list
-- itself), so that every part of the book is one click away from the tabs
local flyout
local FLY_W, FLY_ROW = 190, 24
local function hideFlyout() if flyout then flyout:Hide() end end

-- fills and shows the list of the group whose tab it is; false for tabs that are no group
local function showFlyout(tab, H)
    local group = tab.key and tab.key:match("^grp_(.+)$")
    local book = UI.book
    if not (group and book) then hideFlyout() return false end
    local g = UI.GROUP[group]
    local parts = {}
    for _, sec in ipairs(UI.sections) do
        if sec.group == group and not sec.index and book.sectionStart[sec.key] then parts[#parts + 1] = sec end
    end
    if #parts == 0 then hideFlyout() return false end
    if not flyout then
        flyout = UI.Frame(UI.bookFrame, FLY_W, 40)
        flyout:SetFrameLevel(UI.bookFrame:GetFrameLevel() + 30)
        flyout:EnableMouse(true)
        UI.Backdrop(flyout, "tooltip", 12, 3, { 0.06, 0.04, 0.02, 0.96 }, c.goldDk)
        flyout.title = UI.Text(flyout, 11, c.gold, "LEFT", UI.HEAD, true)
        flyout.title:SetPoint("TOPLEFT", 12, -9)
        flyout.rows = {}
        flyout:SetScript("OnEnter", function() plateDriver.hideAt = nil end)
        flyout:SetScript("OnLeave", function()
            plateDriver.hideAt = GetTime() + 0.3
            plateDriver:Show()
        end)
    end
    flyout.title:SetText(L[g.label])
    local counts = UI.NewCounts and UI.NewCounts() or {}
    for i, sec in ipairs(parts) do
        local row = flyout.rows[i]
        if not row then
            row = CreateFrame("Button", nil, flyout)
            row:SetSize(FLY_W - 12, FLY_ROW)
            row.hl = row:CreateTexture(nil, "BACKGROUND")
            row.hl:SetAllPoints()
            row.hl:SetColorTexture(1, 0.85, 0.5, 0.16)
            row.hl:Hide()
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(18, 18)
            row.icon:SetPoint("LEFT", 4, 0)
            row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            row.text = UI.Text(row, 12, { 0.92, 0.86, 0.74, 1 }, "LEFT", UI.FONT, true)
            row.text:SetPoint("LEFT", row.icon, "RIGHT", 7, 0)
            row.text:SetWidth(FLY_W - 12 - 60)
            row.text:SetWordWrap(false)
            row.new = UI.Text(row, 11, c.redInk, "RIGHT", UI.HEAD, true)
            row.new:SetPoint("RIGHT", -4, 0)
            row:SetScript("OnEnter", function(self)
                self.hl:Show()
                plateDriver.hideAt = nil
            end)
            row:SetScript("OnLeave", function(self)
                self.hl:Hide()
                plateDriver.hideAt = GetTime() + 0.3
                plateDriver:Show()
            end)
            row:SetScript("OnClick", function(self)
                local st = UI.book and UI.book.sectionStart[self.key]
                if st then UI:GoToPage(st) end
            end)
            flyout.rows[i] = row
        end
        row.key = sec.key
        row:SetPoint("TOPLEFT", flyout, "TOPLEFT", 6, -26 - (i - 1) * FLY_ROW)
        row.icon:SetTexture(UI.Icon(sec.icon))
        local empty = UI.IsEmptyPart and UI.IsEmptyPart(sec.key)
        row.text:SetText(L[sec.label])
        row.text:SetTextColor(empty and 0.60 or 0.92, empty and 0.55 or 0.86, empty and 0.48 or 0.74, 1)
        local n = counts[sec.key]
        row.new:SetText((n and n > 0) and ("+" .. n) or "")
        row:Show()
    end
    for i = #parts + 1, #flyout.rows do flyout.rows[i]:Hide() end
    flyout:SetHeight(34 + #parts * FLY_ROW)
    flyout:ClearAllPoints()
    flyout:SetPoint("LEFT", tab, "LEFT", TAB_W + H / 2 + 8 + (UI.plateWidth or 0) + 8, 0)
    flyout:Show()
    return true
end

-- the open tab keeps its name on show, the others only while the mouse is on the index
local function showActivePlate()
    for _, t in ipairs(UI.thumbs or {}) do
        local p = t.plate
        if t.on then
            p:SetWidth(p.text:GetStringWidth() + 18)
            p.text:SetTextColor(col4(c.gold))
            p:Show()
        else
            p:Hide()
        end
    end
end

plateDriver:SetScript("OnUpdate", function(self)
    if self.hideAt and GetTime() >= self.hideAt then
        self.hideAt = nil
        self:Hide()
        allPlatesOut = false
        hideFlyout()
        showActivePlate()
    end
end)

local function showPlates(keepTimer)
    allPlatesOut = true
    if not keepTimer then plateDriver.hideAt = nil end
    local widest = 0
    for _, t in ipairs(UI.thumbs) do
        local p = t.plate
        p:SetWidth(p.text:GetStringWidth() + 18)
        widest = max(widest, p:GetWidth())
        if t.on then p.text:SetTextColor(col4(c.gold))
        elseif t.hover then p.text:SetTextColor(1, 1, 1, 1)
        else p.text:SetTextColor(0.90, 0.84, 0.72, 1) end
        p:Show()
    end
    UI.plateWidth = widest
end
-- after a turn of the page the open tab changes: repaint the plates that are out
function UI.RefreshPlates()
    if not UI.thumbs then return end
    if allPlatesOut then showPlates(true) else showActivePlate() end
end

local function hidePlatesSoon()
    plateDriver.hideAt = GetTime() + 0.3
    plateDriver:Show()
end

local function buildThumbs(bf)
    UI.thumbs = {}
    bf:HookScript("OnHide", function()
        plateDriver.hideAt = nil
        plateDriver:Hide()
        allPlatesOut = false
        hideFlyout()
        for _, t in ipairs(UI.thumbs) do t.plate:Hide() end
    end)
    local list = UI:ThumbList()
    -- a small gap between the groups; tabs shrink a little when the book has many sections,
    -- so they always fit beside the pages
    local GROUP_GAP = 8
    local gaps = 0
    for i = 2, #list do if list[i].group ~= list[i - 1].group then gaps = gaps + 1 end end
    local H = min(TAB_H, floor((PH - 12 - gaps * GROUP_GAP) / #list) - TAB_GAP)
    local total = #list * (H + TAB_GAP) - TAB_GAP + gaps * GROUP_GAP
    local y = -BRD - max(10, (PH - total) / 2)
    for i, def in ipairs(list) do
        if i > 1 and def.group ~= list[i - 1].group then y = y - GROUP_GAP end
        local t = CreateFrame("Button", nil, bf)
        t:SetSize(TAB_W + H / 2, H)
        t:SetFrameLevel(bf:GetFrameLevel() + 1)
        t.col = def.col
        -- drop shadow
        local sh = UI.Fill(t, { 0, 0, 0 }, "BACKGROUND", 0, 0.4)
        sh:SetPoint("TOPLEFT", 0, -3)
        sh:SetSize(TAB_W, H)
        local shc = UI.Circle(t, H, { 0, 0, 0, 0.4 }, "BACKGROUND", 0)
        shc:SetPoint("CENTER", t, "LEFT", TAB_W, -3)
        -- body with a rounded end
        t.body = t:CreateTexture(nil, "ARTWORK", nil, 0)
        t.body:SetPoint("TOPLEFT", 0, 0)
        t.body:SetSize(TAB_W, H)
        t.cap = UI.Circle(t, H, { 1, 1, 1, 1 }, "ARTWORK", 0)
        t.cap:SetPoint("CENTER", t, "LEFT", TAB_W, 0)
        -- gold trim
        t.trimTop = UI.Fill(t, c.gold, "ARTWORK", 2)
        t.trimTop:SetSize(TAB_W - 6, 1)
        t.trimTop:SetPoint("TOPLEFT", 0, -3)
        t.trimBot = UI.Fill(t, c.gold, "ARTWORK", 2)
        t.trimBot:SetSize(TAB_W - 6, 1)
        t.trimBot:SetPoint("BOTTOMLEFT", 0, 3)
        local sheen = UI.GradRect(t, "VERTICAL", { 0, 0, 0, 0.25 }, { 1, 1, 1, 0.12 }, "ARTWORK", 1)
        sheen:SetPoint("TOPLEFT", 0, 0)
        sheen:SetSize(TAB_W, H)
        -- round icon in a ring at the visible end
        t.ring = UI.Circle(t, H - 6, c.gold, "ARTWORK", 3)
        t.ring:SetPoint("CENTER", t, "LEFT", TAB_W - 4, 0)
        t.icon = t:CreateTexture(nil, "ARTWORK", nil, 4)
        t.icon:SetSize(H - 11, H - 11)
        t.icon:SetPoint("CENTER", t.ring, "CENTER")
        t.icon:SetTexture(UI.Icon(def.icon))
        t.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        UI.Round(t.icon, t)
        t.key, t.label, t.y, t.target, t.hint = def.key, def.label, y, def.target, def.hint
        -- the name plate right of the tab end (moves with the tab as it slides out)
        local plate = UI.Frame(bf, 60, max(18, H - 10))
        plate:SetFrameLevel(bf:GetFrameLevel() + 25)
        plate:SetPoint("LEFT", t, "LEFT", TAB_W + H / 2 + 8, 0)
        plate:EnableMouse(false)
        UI.Backdrop(plate, "tooltip", 10, 2, { 0.06, 0.04, 0.02, 0.94 }, c.goldDk)
        plate.text = UI.Text(plate, 12, { 0.90, 0.84, 0.72, 1 }, "LEFT", UI.FONT, true)
        plate.text:SetPoint("LEFT", 9, 0)
        plate.text:SetText(def.label)
        plate:Hide()
        t.plate = plate
        t:SetScript("OnClick", function(self)
            local st = UI.book and (self.target and self.target() or UI.book.sectionStart[self.key])
            if st then
                UI.wantTab = self.key
                UI:GoToPage(st)
            end
        end)
        t:SetScript("OnMouseDown", function(self) self.down = true; placeTab(self) end)
        t:SetScript("OnMouseUp", function(self) self.down = nil; placeTab(self) end)
        t:SetScript("OnEnter", function(self)
            self.hover = true
            placeTab(self)
            paintTab(self, self.on, true)
            showPlates()
            if showFlyout(self, H) then return end      -- a group: the list of its parts says it all
            hideFlyout()
            -- the tooltip beside the column of name plates, not over them
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("LEFT", self, "LEFT", TAB_W + H / 2 + 8 + (UI.plateWidth or 0) + 10, 0)
            GameTooltip:SetText(self.label, 1, 0.86, 0.5)
            local st = UI.book and (self.target and self.target() or UI.book.sectionStart[self.key])
            if st then GameTooltip:AddLine(format(L["Page %d"], UI.PageNumber(st)), 0.8, 0.8, 0.8) end
            if self.newCount and self.newCount > 0 then
                GameTooltip:AddLine(format(L["%d new since you last read"], self.newCount), 1, 0.45, 0.35)
            end
            GameTooltip:AddLine(self.hint or L["Click to open this part of the book."], 0.5, 0.8, 1)
            GameTooltip:Show()
        end)
        t:SetScript("OnLeave", function(self)
            self.hover, self.down = nil, nil
            placeTab(self)
            paintTab(self, self.on, false)
            GameTooltip:Hide()
            hidePlatesSoon()
        end)
        paintTab(t, false, false)
        UI.thumbs[#UI.thumbs + 1] = t
        y = y - H - TAB_GAP
    end
end

------------------------------------------------------------------------
-- Building the frames
------------------------------------------------------------------------
local function leather(f, inset)
    UI.Leather(f, inset, 1, 0.30)
    UI.EdgeFade(f, "LEFT", 60, { 0, 0, 0 }, 0.45, "BACKGROUND", 3, inset)
    UI.EdgeFade(f, "RIGHT", 60, { 0, 0, 0 }, 0.45, "BACKGROUND", 3, inset)
    UI.EdgeFade(f, "BOTTOM", 60, { 0, 0, 0 }, 0.45, "BACKGROUND", 3, inset)
    UI.EdgeFade(f, "TOP", 50, { 1, 0.80, 0.55 }, 0.07, "BACKGROUND", 4, inset)
end

local function stitches(frame, inset, w, h, col)
    for x = inset + 8, w - inset - 14, 12 do
        local a = UI.Fill(frame, col, "BORDER", 5); a:SetSize(7, 1); a:SetPoint("TOPLEFT", x, -inset)
        local b = UI.Fill(frame, col, "BORDER", 5); b:SetSize(7, 1); b:SetPoint("TOPLEFT", x, -(h - inset - 1))
    end
    for y = inset + 8, h - inset - 14, 12 do
        local a = UI.Fill(frame, col, "BORDER", 5); a:SetSize(1, 7); a:SetPoint("TOPLEFT", inset, -y)
        local b = UI.Fill(frame, col, "BORDER", 5); b:SetSize(1, 7); b:SetPoint("TOPLEFT", w - inset - 1, -y)
    end
end

local function buildBook(holder)
    local bf = UI.Frame(holder, BW, BH)
    bf:SetPoint("CENTER")
    UI.Backdrop(bf, "tooltip", 16, 4, c.leather, { 0.78, 0.60, 0.28, 1 })
    leather(bf, 4)
    stitches(bf, 9, BW, BH, { 0.85, 0.66, 0.32, 0.4 })
    bf:EnableMouse(true)
    bf:RegisterForDrag("LeftButton")
    bf:SetScript("OnDragStart", function() holder:StartMoving() end)
    bf:SetScript("OnDragStop", function()
        holder:StopMovingOrSizing()
        if UI.SavePosition then UI:SavePosition() end
    end)
    bf:EnableMouseWheel(true)
    bf:SetScript("OnMouseWheel", function(_, delta)
        if IsControlKeyDown() and UI.StepScale then UI:StepScale(delta) return end
        UI:Flip(delta > 0 and -1 or 1)
    end)
    UI.bookFrame = bf
    local base = bf:GetFrameLevel()

    -- page stacks peeking out at the bottom
    local stack = CreateFrame("Frame", nil, bf)
    stack:SetPoint("TOPLEFT", BRD, -BRD)
    stack:SetSize(PW * 2 + GUT, PH)
    stack:SetFrameLevel(base + 2)
    local cols = { { 0.22, 0.16, 0.10 }, { 0.08, 0.05, 0.03 }, { 0.20, 0.14, 0.09 }, { 0.06, 0.04, 0.02 } }  -- dark leaves under the pages
    for i = #cols, 1, -1 do
        local l = UI.Fill(stack, cols[i], "BACKGROUND", -6 + i)
        l:SetPoint("TOPLEFT", stack, "TOPLEFT", -i, -i * 1.5)
        l:SetPoint("BOTTOMRIGHT", stack, "BOTTOMLEFT", PW, -i * 1.5)
        local r = UI.Fill(stack, cols[i], "BACKGROUND", -6 + i)
        r:SetPoint("TOPLEFT", stack, "TOPLEFT", PW + GUT, -i * 1.5)
        r:SetPoint("BOTTOMRIGHT", stack, "BOTTOMRIGHT", i, -i * 1.5)
    end
    local gutL = UI.GradRect(stack, "HORIZONTAL", { 0.22, 0.11, 0.05, 1 }, { 0.04, 0.02, 0.01, 1 }, "BACKGROUND", 4)
    gutL:SetPoint("TOPLEFT", PW, 0)
    gutL:SetSize(GUT / 2, PH)
    local gutR = UI.GradRect(stack, "HORIZONTAL", { 0.04, 0.02, 0.01, 1 }, { 0.22, 0.11, 0.05, 1 }, "BACKGROUND", 4)
    gutR:SetPoint("TOPLEFT", PW + GUT / 2, 0)
    gutR:SetSize(GUT / 2, PH)

    -- the two pages
    UI.pageFrames = {}
    for _, side in ipairs({ "left", "right" }) do
        local p = UI.Page(bf, PW, PH, side == "left" and "right" or "left")
        p:SetFrameLevel(base + 3)
        if side == "left" then p:SetPoint("TOPLEFT", BRD, -BRD) else p:SetPoint("TOPLEFT", BRD + PW + GUT, -BRD) end
        local canvas = CreateFrame("Frame", nil, p)
        canvas:SetAllPoints()
        canvas:SetFrameLevel(base + 6)

        p.canvas = canvas
        p.pool = UI.NewPool(canvas)
        -- the glow that shows which page a link or tab led to
        local glow = CreateFrame("Frame", nil, p)
        glow:SetAllPoints()
        glow:SetFrameLevel(base + 12)
        glow:EnableMouse(false)
        for _, edge in ipairs({ "TOP", "BOTTOM", "LEFT", "RIGHT" }) do
            UI.EdgeFade(glow, edge, 34, { 0.95, 0.72, 0.28 }, 0.42, "OVERLAY", 0)
        end
        UI.Fill(glow, { 1, 0.85, 0.5 }, "OVERLAY", -1, 0.06):SetAllPoints()
        glow:Hide()
        p.glow = glow
        UI.pageFrames[side] = p
    end

    -- page turning
    UI.prevBtn = UI.PageArrow(UI.pageFrames.left, "Prev", function() UI:Flip(-1) end)
    UI.prevBtn:SetPoint("BOTTOMLEFT", 12, 10)
    UI.prevBtn:SetFrameLevel(base + 12)
    UI.nextBtn = UI.PageArrow(UI.pageFrames.right, "Next", function() UI:Flip(1) end)
    UI.nextBtn:SetPoint("BOTTOMRIGHT", -12, 10)
    UI.nextBtn:SetFrameLevel(base + 12)

    -- ribbon bookmark: always leads to today's entry
    -- the ribbon bookmark: it lies inside the book and only its end shows, hanging out below the
    -- binding - muted wine red with gold edges, cut to a swallowtail
    local RW, HANG, UNDER = 12, 34, 8
    local rb = CreateFrame("Button", nil, holder)
    rb:SetFrameLevel(max(0, bf:GetFrameLevel() - 1))          -- behind the book: the binding covers its top
    rb:SetSize(RW, HANG + UNDER)
    rb:SetPoint("TOP", bf, "BOTTOMLEFT", BRD + PW + GUT / 2, UNDER)
    local DARK, MID, LIGHT = { 0.17, 0.045, 0.035 }, { 0.30, 0.08, 0.06 }, { 0.42, 0.14, 0.09 }
    local half = RW / 2
    local NOTCH = 8
    -- woven silk: darker at the edges, a soft light crease in the middle
    local l = UI.GradRect(rb, "HORIZONTAL", { DARK[1], DARK[2], DARK[3], 1 }, { LIGHT[1], LIGHT[2], LIGHT[3], 1 }, "ARTWORK", 0)
    l:SetPoint("TOPLEFT"); l:SetPoint("BOTTOMLEFT", 0, NOTCH); l:SetWidth(half)
    local r = UI.GradRect(rb, "HORIZONTAL", { MID[1], MID[2], MID[3], 1 }, { DARK[1], DARK[2], DARK[3], 1 }, "ARTWORK", 0)
    r:SetPoint("TOPRIGHT"); r:SetPoint("BOTTOMRIGHT", 0, NOTCH); r:SetWidth(half)
    -- gold threads along both edges, as on the binding
    for _, side in ipairs({ "LEFT", "RIGHT" }) do
        local g = UI.Fill(rb, c.gold, "ARTWORK", 2, 0.55)
        g:SetWidth(1)
        g:SetPoint("TOP" .. side, rb, "TOP" .. side, side == "LEFT" and 1 or -1, 0)
        g:SetPoint("BOTTOM" .. side, rb, "BOTTOM" .. side, side == "LEFT" and 1 or -1, NOTCH)
    end
    -- the swallowtail: a V cut into the end, row by row; the points sit at the outer edges
    for k = 0, NOTCH - 1 do
        local w = half * (k + 0.5) / NOTCH
        local ta = UI.Fill(rb, { (DARK[1] + LIGHT[1]) / 2, (DARK[2] + LIGHT[2]) / 2, (DARK[3] + LIGHT[3]) / 2 }, "ARTWORK", 0)
        ta:SetSize(w, 1)
        ta:SetPoint("BOTTOMLEFT", rb, "BOTTOMLEFT", 0, k)
        local tb = UI.Fill(rb, { (DARK[1] + MID[1]) / 2, (DARK[2] + MID[2]) / 2, (DARK[3] + MID[3]) / 2 }, "ARTWORK", 0)
        tb:SetSize(w, 1)
        tb:SetPoint("BOTTOMRIGHT", rb, "BOTTOMRIGHT", 0, k)
    end
    -- in the shadow of the book where it comes out
    local shade = UI.GradRect(rb, "VERTICAL", { 0, 0, 0, 0 }, { 0, 0, 0, 0.7 }, "OVERLAY", 0)
    shade:SetPoint("TOPLEFT"); shade:SetPoint("TOPRIGHT"); shade:SetHeight(UNDER + 8)
    -- it belongs to the open book: hidden with it (the closed cover has none)
    bf:HookScript("OnShow", function() rb:Show() end)
    bf:HookScript("OnHide", function() rb:Hide() end)
    rb:SetScript("OnClick", function() UI:GoToPage(UI:TodayPage()) end)
    rb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["Bookmark"], 1, 0.86, 0.5)
        GameTooltip:AddLine(L["Click to open today's entry."], 0.9, 0.9, 0.9)
        GameTooltip:Show()
    end)
    rb:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- close
    local ok, close = pcall(CreateFrame, "Button", nil, bf, "UIPanelCloseButton")
    if not (ok and close) then
        close = UI.Button(bf, "X", 24, 24)
    end
    close:SetPoint("TOPRIGHT", bf, "TOPRIGHT", 6, 6)
    close:SetFrameLevel(base + 20)
    close:SetScript("OnClick", function() holder:Hide() end)

    buildThumbs(bf)
    bf:Hide()
end

------------------------------------------------------------------------
-- The closed cover (start screen)
------------------------------------------------------------------------
local CVW, CVH = 450, BH
local BRASS = { 0.76, 0.58, 0.26, 1 }

-- the faction emblem, gold-stamped: path, texture coordinates, whether it is a square icon
local CRESTS = {
    Alliance = {
        { "Interface\\Timer\\Alliance-Logo", { 0, 1, 0, 1 } },
        { "Interface\\FriendsFrame\\PlusManz-Alliance", { 0, 1, 0, 1 } },
        { "Interface\\Icons\\INV_BannerPVP_02", { 0.08, 0.92, 0.08, 0.92 }, true },
    },
    Horde = {
        { "Interface\\Timer\\Horde-Logo", { 0, 1, 0, 1 } },
        { "Interface\\FriendsFrame\\PlusManz-Horde", { 0, 1, 0, 1 } },
        { "Interface\\Icons\\INV_BannerPVP_01", { 0.08, 0.92, 0.08, 0.92 }, true },
    },
}
local function factionCrest()
    local faction = UnitFactionGroup and UnitFactionGroup("player")
    for _, e in ipairs(CRESTS[faction] or {}) do
        if UI.Has(e[1]) then return e[1], e[2], e[3] end
    end
    return UI.Icon("journal"), { 0.08, 0.92, 0.08, 0.92 }, true
end

-- how worn the book is: nothing on the first day, fully worn after about four months
function UI.Wear()
    return math.max(0, math.min(1, (WFD:NumDays() - 1) / 120))
end

-- the binding grows with the honours: corner studs change metal with the honour points,
-- a gem is set into the lozenge for every ten tiers, the spine gets a gold mark for every ten levels
UI.COVER_METALS = { { 150, 1 }, { 500, 2 }, { 1000, 3 }, { 1800, 4 }, { 2800, 5 } }
local GEM_COLOURS = {
    { 0.80, 0.12, 0.10 }, { 0.16, 0.38, 0.90 }, { 0.16, 0.70, 0.28 }, { 0.62, 0.22, 0.80 },
    { 0.95, 0.70, 0.12 }, { 0.20, 0.75, 0.80 }, { 0.92, 0.92, 0.95 }, { 0.95, 0.38, 0.10 },
}

function UI:CoverGrowth()
    local _, sum = WFD:HonourState()
    local metal = 0
    for _, m in ipairs(UI.COVER_METALS) do if sum.points >= m[1] then metal = m[2] end end
    local nextMetal
    for _, m in ipairs(UI.COVER_METALS) do if sum.points < m[1] then nextMetal = m break end end
    local level = UnitLevel("player") or 1
    if WFD.demo and WFD.C.level then level = WFD.C.level end
    return {
        points = sum.points, metal = metal, nextMetal = nextMetal,
        tiers = sum.tiers, gems = math.min(8, floor(sum.tiers / 10)),
        marks = math.min(6, floor(level / 10)), level = level,
    }
end

function UI:RefreshCoverGrowth()
    local cv = self.cover
    if not cv or not cv.deco then return end
    local ok, g = pcall(self.CoverGrowth, self)
    if not ok then return end
    cv.growth = g
    for _, s in ipairs(cv.studs) do
        local shown = g.metal > 0
        s.shadow:SetShown(shown)
        s.body:SetShown(shown)
        s.shine:SetShown(shown)
        if shown then s.body:SetVertexColor(col4(WFD.METALS[g.metal].col)) end
    end
    for i, gem in ipairs(cv.gems) do
        local shown = i <= g.gems
        gem.setting:SetShown(shown)
        gem.stone:SetShown(shown)
        gem.spark:SetShown(shown)
        if shown then
            local col = GEM_COLOURS[i]
            gem.stone:SetVertexColor(col[1], col[2], col[3], 1)
        end
    end
    for i, d in ipairs(cv.spine) do d:SetShown(i <= g.marks) end
    -- the wear of the days
    local w = UI.Wear()
    for _, e in ipairs(cv.wear) do
        local a = e.from and (w > e.from and e.a * w or 0) or e.a * w
        if e.edge then
            local from, to = { 1, 0.82, 0.58, a }, { 1, 0.82, 0.58, 0 }
            if e.edge == "TOP" then UI.Gradient(e.tex, "VERTICAL", to, from)
            elseif e.edge == "BOTTOM" then UI.Gradient(e.tex, "VERTICAL", from, to)
            elseif e.edge == "LEFT" then UI.Gradient(e.tex, "HORIZONTAL", from, to)
            else UI.Gradient(e.tex, "HORIZONTAL", to, from) end
        else
            e.tex:SetAlpha(a)
        end
    end
end

-- tooltip of the closed book: what the binding shows, and what comes next
function UI:CoverTooltip(owner)
    local g = self.cover and self.cover.growth
    if not g then return end
    GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["The binding"], 1, 0.86, 0.5)
    local metalName = g.metal > 0 and L[WFD.METALS[g.metal].name] or L["none yet"]
    GameTooltip:AddDoubleLine(L["Corner studs"], metalName, 0.9, 0.9, 0.9, 1, 0.82, 0.4)
    if g.nextMetal then
        GameTooltip:AddLine(format(L["Next metal at %d honour points (now %d)."], g.nextMetal[1], g.points), 0.7, 0.7, 0.7, true)
    end
    GameTooltip:AddDoubleLine(L["Gems"], g.gems .. " / 8", 0.9, 0.9, 0.9, 1, 0.82, 0.4)
    if g.gems < 8 then
        GameTooltip:AddLine(format(L["One gem for every ten honour tiers (now %d)."], g.tiers), 0.7, 0.7, 0.7, true)
    end
    GameTooltip:AddDoubleLine(L["Gold marks on the spine"], g.marks .. " / 6", 0.9, 0.9, 0.9, 1, 0.82, 0.4)
    if g.marks < 6 then GameTooltip:AddLine(L["One for every ten levels."], 0.7, 0.7, 0.7, true) end
    GameTooltip:Show()
end

function UI:RefreshCover()
    local cv = self.cover
    if not cv or not WFD.C then return end
    local C = WFD.C
    self:RefreshCoverGrowth()
    cv.name:SetText(C.name or UnitName("player"))
    cv.who:SetText(((C.race or "") .. "  -  " .. (C.class or "")):upper())
    if C.obituary then
        cv.since:SetText(date(WFD.loc.date, C.born) .. "  -  " .. date(WFD.loc.date, C.obituary.t))
        cv.of:SetText(L["In memoriam"])
    else
        cv.since:SetText(format(L["Begun on %s"], date(WFD.loc.date, C.born)))
        cv.of:SetText(L["of"])
    end
    -- names and lines of any length and language fit their plate
    UI.FitText(cv.name, 230, 30, 16)
    UI.FitText(cv.who, 236, 10, 8, UI.FONT)
    UI.FitText(cv.of, 230, 14, 10)
    UI.FitText(cv.since, 300, 14, 10)
    local path, tc, isIcon = factionCrest()
    cv.crest:SetTexture(path)
    cv.crest:SetTexCoord(tc[1], tc[2], tc[3], tc[4])
    -- emblems are stamped in gold; a square icon keeps a little of its colour
    cv.crest:SetDesaturated(true)
    if isIcon then
        cv.crest:SetSize(112, 112)
        cv.crest:SetVertexColor(1.0, 0.82, 0.45, 1)
    else
        cv.crest:SetSize(108, 108)
        cv.crest:SetVertexColor(1.0, 0.80, 0.38, 1)
    end
    cv.demo:SetShown(WFD.demo and true or false)
end

-- brass corner piece: a diamond cut by the corner of the cover, with two rivets
local function brassCorner(cv, point, dx, dy)
    local f = CreateFrame("Frame", nil, cv)
    f:SetSize(48, 48)
    f:SetPoint(point, cv, point, dx * 2, dy * 2)
    f:SetFrameLevel(cv:GetFrameLevel() + 6)
    if not f.SetClipsChildren then return end
    f:SetClipsChildren(true)
    local layers = {
        { 72, { 0.30, 0.21, 0.08 } }, { 68, BRASS }, { 58, { 0.52, 0.38, 0.14 } }, { 54, { 0.84, 0.66, 0.32 } },
    }
    for i, l in ipairs(layers) do
        local d = UI.Diamond(f, l[1], l[2], "ARTWORK", i)
        d:SetPoint("CENTER", f, point, 0, 0)
    end
    for _, r in ipairs({ { 13, 5 }, { 5, 13 } }) do
        local rx, ry = r[1] * -dx, r[2] * -dy
        local s = UI.Circle(f, 6, { 0.25, 0.17, 0.06, 1 }, "OVERLAY", 0)
        s:SetPoint("CENTER", f, point, rx + 4 * -dx, ry + 4 * -dy)
        local h = UI.Circle(f, 3, { 1, 0.90, 0.60, 1 }, "OVERLAY", 1)
        h:SetPoint("CENTER", s, "CENTER", -0.5, 0.5)
    end
end

-- a leather strap with a brass buckle over the right edge
local function strap(cv, y)
    local s = CreateFrame("Frame", nil, cv)
    s:SetSize(88, 46)
    s:SetPoint("RIGHT", cv, "RIGHT", 20, y)
    s:SetFrameLevel(cv:GetFrameLevel() + 7)
    local sh = UI.Fill(s, { 0, 0, 0 }, "BACKGROUND", 0, 0.45)
    sh:SetPoint("TOPLEFT", -3, -4)
    sh:SetPoint("BOTTOMRIGHT", 0, -4)
    local body = UI.GradRect(s, "VERTICAL", { 0.07, 0.035, 0.02, 1 }, { 0.28, 0.14, 0.07, 1 }, "ARTWORK", 0)
    body:SetAllPoints()
    local edge = UI.Frame(s)
    edge:SetAllPoints()
    UI.Backdrop(edge, nil, 1, 0, { 0, 0, 0, 0 }, { 0, 0, 0, 0.85 })
    for x = 6, 82, 9 do
        local a = UI.Fill(s, { 0.85, 0.66, 0.32 }, "OVERLAY", 0, 0.45); a:SetSize(5, 1); a:SetPoint("TOPLEFT", x, -5)
        local b = UI.Fill(s, { 0.85, 0.66, 0.32 }, "OVERLAY", 0, 0.45); b:SetSize(5, 1); b:SetPoint("BOTTOMLEFT", x, 5)
    end
    -- buckle: brass frame, dark opening, tongue
    local bk = UI.Frame(s, 32, 40)
    bk:SetPoint("LEFT", s, "LEFT", 6, 0)
    bk:SetFrameLevel(s:GetFrameLevel() + 2)
    UI.Backdrop(bk, "tooltip", 12, 3, { 0.10, 0.05, 0.02, 1 }, { 1, 0.84, 0.42, 1 })
    local tongue = UI.Fill(bk, { 1, 0.84, 0.42 }, "OVERLAY")
    tongue:SetSize(16, 3)
    tongue:SetPoint("CENTER", 2, 0)
    local hole = UI.Circle(s, 5, { 0, 0, 0, 0.8 }, "OVERLAY", 1)
    hole:SetPoint("LEFT", s, "LEFT", 52, 0)
end

local COVER_ART = "Interface\\AddOns\\" .. ADDON .. "\\Media\\cover"

local function buildCover(holder)
    local cv = UI.Frame(holder, CVW, CVH, "Button")
    cv:SetPoint("CENTER")
    -- the painted leather binding (Media folder, cover.tga); the drawn decoration below only stands in without it
    local art = cv:CreateTexture(nil, "BACKGROUND", nil, -8)
    art:SetAllPoints()
    local hasArt = art:SetTexture(COVER_ART) ~= false
    art:SetTexCoord(0, CVW / 512, 0, CVH / 1024)
    if not hasArt then
        art:Hide()
        UI.Backdrop(cv, "tooltip", 16, 4, c.leather, { 0.55, 0.40, 0.18, 1 })
        leather(cv, 4)
    end
    cv:RegisterForDrag("LeftButton")
    cv:SetScript("OnDragStart", function() holder:StartMoving() end)
    cv:SetScript("OnDragStop", function()
        holder:StopMovingOrSizing()
        if UI.SavePosition then UI:SavePosition() end
        cv.dragEnd = GetTime()
    end)
    UI.cover = cv
    local cx = 20   -- visual centre shifted right of the spine

    if not hasArt then
        -- worn leather: lighter scuffs near the edges, darker in the middle
        for _, s in ipairs({ { 70, -30, 90 }, { CVW - 40, -80, 70 }, { 90, -CVH + 40, 80 }, { CVW - 60, -CVH + 60, 100 },
                             { CVW - 20, -CVH / 2, 60 }, { 60, -CVH / 2 - 60, 50 } }) do
            local sc = UI.Circle(cv, s[3], { 1, 0.80, 0.55, 0.045 }, "BACKGROUND", 5)
            sc:SetPoint("CENTER", cv, "TOPLEFT", s[1], s[2])
        end

        -- spine with raised bands and gold fillets
        local spine = UI.GradRect(cv, "HORIZONTAL", { 0.04, 0.02, 0.01, 1 }, { 0.22, 0.11, 0.06, 1 }, "BORDER", 0)
        spine:SetPoint("TOPLEFT", 4, -4)
        spine:SetPoint("BOTTOMLEFT", 4, 4)
        spine:SetWidth(38)
        local hinge = UI.Fill(cv, { 0, 0, 0 }, "BORDER", 1, 0.65)
        hinge:SetPoint("TOPLEFT", 42, -4)
        hinge:SetPoint("BOTTOMLEFT", 42, 4)
        hinge:SetWidth(3)
        for i = 1, 5 do
            local by = -44 - (i - 1) * ((CVH - 100) / 4)
            local band = UI.GradRect(cv, "VERTICAL", { 0.06, 0.03, 0.01, 1 }, { 0.40, 0.22, 0.11, 1 }, "BORDER", 2)
            band:SetSize(38, 12)
            band:SetPoint("TOPLEFT", 4, by)
            for _, o in ipairs({ -3, 14 }) do
                local fil = UI.Fill(cv, c.gold, "BORDER", 3, 0.55)
                fil:SetSize(34, 1)
                fil:SetPoint("TOPLEFT", 6, by - o)
            end
        end

        -- tooled border: a dark blind-stamped groove, two gold fillets, a row of stamped diamonds between them
        local groove = UI.Frame(cv)
        groove:SetPoint("TOPLEFT", 40 + 18, -18)
        groove:SetPoint("BOTTOMRIGHT", -18, 18)
        UI.Backdrop(groove, nil, 2, 0, { 0, 0, 0, 0 }, { 0, 0, 0, 0.35 })
        for i, inset in ipairs({ 28, 44 }) do
            local fr = UI.Frame(cv)
            fr:SetPoint("TOPLEFT", 40 + inset - 6, -inset)
            fr:SetPoint("BOTTOMRIGHT", -inset, inset)
            UI.Backdrop(fr, "tooltip", 12, 3, { 0, 0, 0, 0 }, { 0.85, 0.66, 0.30, i == 1 and 0.80 or 0.50 })
        end
        local L0, T0, R0, B0 = 40 + 36 - 6 + 4, -36 - 4, CVW - 36 - 4, -CVH + 36 + 4
        for x = L0 + 8, R0 - 8, 15 do
            for _, yy in ipairs({ T0, B0 }) do
                local d = UI.Diamond(cv, 4, { 0, 0, 0, 0.45 }, "BORDER", 4)
                d:SetPoint("CENTER", cv, "TOPLEFT", x, yy)
            end
        end
        for y = T0 - 8, B0 + 8, -15 do
            for _, xx in ipairs({ L0, R0 }) do
                local d = UI.Diamond(cv, 4, { 0, 0, 0, 0.45 }, "BORDER", 4)
                d:SetPoint("CENTER", cv, "TOPLEFT", xx, y)
            end
        end
        -- gold fleurons in the inner corners
        for _, p in ipairs({ { L0 + 18, T0 - 18, 1, -1 }, { R0 - 18, T0 - 18, -1, -1 }, { L0 + 18, B0 + 18, 1, 1 }, { R0 - 18, B0 + 18, -1, 1 } }) do
            local big = UI.Diamond(cv, 10, c.gold, "ARTWORK", 2)
            big:SetPoint("CENTER", cv, "TOPLEFT", p[1], p[2])
            for _, o in ipairs({ { 12, 0 }, { 0, 12 } }) do
                local sm = UI.Diamond(cv, 5, c.goldDk, "ARTWORK", 2)
                sm:SetPoint("CENTER", cv, "TOPLEFT", p[1] + o[1] * p[3], p[2] + o[2] * p[4])
            end
        end
    end

    -- the title in a recessed cartouche
    local cart = UI.Frame(cv, 300, 58)
    cart:SetPoint("TOP", cv, "TOP", cx, -62)
    if not hasArt then UI.Backdrop(cart, "tooltip", 12, 3, { 0.06, 0.03, 0.015, 0.75 }, { 0.85, 0.66, 0.30, 0.9 }) end
    cv.title = UI.Text(cart, 30, c.gold, "CENTER", UI.HEAD, true)
    cv.title:SetPoint("CENTER", 0, -1)
    cv.title:SetText(L["Travel Diary"])
    UI.FitText(cv.title, 232, 30, 16)          -- the title field is 248 px wide; long titles shrink
    if not hasArt then
        for s = -1, 1, 2 do
            local d = UI.Diamond(cv, 9, c.gold, "ARTWORK", 3)
            d:SetPoint("CENTER", cart, s < 0 and "LEFT" or "RIGHT", 0, 0)
        end
    end

    -- a gold lozenge around the crest, as on old bindings
    local CY = -250
    if not hasArt and cv.CreateLine then
        for k, half in ipairs({ 122, 112 }) do
            local pts = { { 0, half }, { half * 0.86, 0 }, { 0, -half }, { -half * 0.86, 0 } }
            for i = 1, 4 do
                local a, b = pts[i], pts[i % 4 + 1]
                local ln = cv:CreateLine(nil, "ARTWORK", nil, 1)
                ln:SetColorTexture(0.85, 0.66, 0.30, k == 1 and 0.75 or 0.40)
                ln:SetThickness(k == 1 and 2 or 1)
                ln:SetStartPoint("TOP", cv, cx + a[1], CY + a[2])
                ln:SetEndPoint("TOP", cv, cx + b[1], CY + b[2])
            end
        end
        for _, t in ipairs({ { 0, 122 }, { 105, 0 }, { 0, -122 }, { -105, 0 } }) do
            local tip = UI.Diamond(cv, 10, c.gold, "ARTWORK", 3)
            tip:SetPoint("CENTER", cv, "TOP", cx + t[1], CY + t[2])
        end
    end

    -- crest in a gold medallion
    local medal = CreateFrame("Frame", nil, cv)
    medal:SetSize(160, 160)
    medal:SetPoint("CENTER", cv, "TOP", cx, CY)
    if not hasArt then
        local glow = UI.Circle(medal, 168, { 0, 0, 0, 0.55 }, "BACKGROUND")
        glow:SetPoint("CENTER", 3, -4)
        local ring = UI.Circle(medal, 150, c.goldDk, "ARTWORK", 0)
        ring:SetPoint("CENTER")
        local ring2 = UI.Circle(medal, 144, c.gold, "ARTWORK", 1)
        ring2:SetPoint("CENTER")
        local ring3 = UI.Circle(medal, 136, { 0.45, 0.30, 0.10, 1 }, "ARTWORK", 2)
        ring3:SetPoint("CENTER")
        local inner = UI.Circle(medal, 132, { 0.12, 0.06, 0.03, 1 }, "ARTWORK", 3)
        inner:SetPoint("CENTER")
    end
    cv.crest = medal:CreateTexture(nil, "ARTWORK", nil, 4)
    cv.crest:SetSize(108, 108)
    cv.crest:SetPoint("CENTER")
    UI.Round(cv.crest, medal)

    -- name plate
    local plate = UI.Frame(cv, 250, 92)
    plate:SetPoint("TOP", cv, "TOP", cx, -386)
    if not hasArt then UI.Backdrop(plate, "tooltip", 12, 3, { 0.06, 0.03, 0.015, 0.55 }, { 0.85, 0.66, 0.30, 0.7 }) end
    cv.of = UI.Text(plate, 14, c.goldDk, "CENTER", UI.HEAD, true)
    cv.of:SetPoint("TOP", 0, -10)
    cv.of:SetText(L["of"])
    cv.name = UI.Text(plate, 30, c.gold, "CENTER", UI.HEAD, true)
    cv.name:SetPoint("TOP", 0, -28)
    cv.who = UI.Caps(plate, "", 10, { 0.85, 0.68, 0.36, 1 })
    cv.who:SetJustifyH("CENTER")
    cv.who:SetPoint("TOP", 0, -66)

    cv.since = UI.Text(cv, 14, { 0.85, 0.70, 0.42, 1 }, "CENTER", UI.HEAD, true)
    cv.since:SetPoint("TOP", cv, "TOP", cx, -490)
    cv.hint = UI.Text(cv, 13, { 0.80, 0.64, 0.36, 1 }, "CENTER", UI.HEAD, true)
    cv.hint:SetPoint("BOTTOM", cv, "BOTTOM", cx, 60)
    cv.hint:SetText(L["Click to open"])
    cv.demo = UI.Text(cv, 12, { 1, 0.45, 0.35, 1 }, "CENTER", UI.HEAD, true)
    cv.demo:SetPoint("BOTTOM", cv.hint, "TOP", 0, 6)
    cv.demo:SetText(L["DEMO MODE - invented data"])

    -- what the binding gains over a life (see UI:RefreshCoverGrowth): metal studs in the corners,
    -- gems set into the lozenge, gold marks on the spine - and the wear of many days
    local deco = CreateFrame("Frame", nil, cv)
    deco:SetAllPoints()
    deco:SetFrameLevel(cv:GetFrameLevel() + 5)
    cv.deco = deco
    cv.studs = {}
    for i, p in ipairs({ { 100, 60 }, { 390, 60 }, { 100, CVH - 60 }, { 390, CVH - 60 } }) do
        local s = {}
        s.shadow = UI.Circle(deco, 20, { 0, 0, 0, 0.55 }, "ARTWORK", 0)
        s.shadow:SetPoint("CENTER", cv, "TOPLEFT", p[1] + 1, -p[2] - 2)
        s.body = UI.Circle(deco, 17, BRASS, "ARTWORK", 1)
        s.body:SetPoint("CENTER", cv, "TOPLEFT", p[1], -p[2])
        s.shine = UI.Circle(deco, 7, { 1, 1, 1, 0.55 }, "ARTWORK", 2)
        s.shine:SetPoint("CENTER", s.body, "CENTER", -3, 3)
        cv.studs[i] = s
    end
    cv.gems = {}
    for i, p in ipairs({ { 0, 124 }, { 106, 0 }, { 0, -124 }, { -106, 0 }, { 53, 62 }, { 53, -62 }, { -53, -62 }, { -53, 62 } }) do
        local g = {}
        g.setting = UI.Circle(deco, 15, { 0.55, 0.40, 0.14, 1 }, "ARTWORK", 3)
        g.setting:SetPoint("CENTER", cv, "TOP", cx + p[1], CY + p[2])
        g.stone = UI.Circle(deco, 11, c.red, "ARTWORK", 4)
        g.stone:SetPoint("CENTER", g.setting, "CENTER")
        g.spark = UI.Circle(deco, 4, { 1, 1, 1, 0.75 }, "ARTWORK", 5)
        g.spark:SetPoint("CENTER", g.stone, "CENTER", -2, 2)
        cv.gems[i] = g
    end
    cv.spine = {}
    for i = 1, 6 do
        local d = UI.Diamond(deco, 10, c.gold, "ARTWORK", 3)
        d:SetPoint("CENTER", cv, "TOPLEFT", 21, -110 - (i - 1) * 76)
        cv.spine[i] = d
    end
    -- wear: rubbed, lighter edges and corners, a few scratches
    cv.wear = {}
    for _, e in ipairs({ "TOP", "BOTTOM", "RIGHT", "LEFT" }) do
        cv.wear[#cv.wear + 1] = { tex = UI.EdgeFade(deco, e, 26, { 1, 0.82, 0.58 }, 0, "BACKGROUND", 0, 3), a = 0.10, edge = e }
    end
    for _, p in ipairs({ { 14, 14 }, { CVW - 14, 14 }, { 14, CVH - 14 }, { CVW - 14, CVH - 14 } }) do
        local rub = UI.Circle(deco, 64, { 1, 0.82, 0.58, 1 }, "BACKGROUND", 1)
        rub:SetPoint("CENTER", cv, "TOPLEFT", p[1], -p[2])
        cv.wear[#cv.wear + 1] = { tex = rub, a = 0.12 }
    end
    if deco.CreateLine then
        for i, s in ipairs({ { 150, 120, 205, 150 }, { 320, 420, 380, 404 }, { 280, 520, 300, 560 }, { 90, 300, 120, 340 },
                             { 360, 190, 410, 230 }, { 200, 470, 230, 455 } }) do
            local ln = deco:CreateLine(nil, "BACKGROUND", nil, 2)
            ln:SetColorTexture(1, 0.85, 0.62, 1)
            ln:SetThickness(1)
            ln:SetStartPoint("TOPLEFT", cv, s[1], -s[2])
            ln:SetEndPoint("TOPLEFT", cv, s[3], -s[4])
            cv.wear[#cv.wear + 1] = { tex = ln, a = 0.16, from = i / 7 }
        end
    end

    -- metal and straps on top of everything
    if not hasArt then
        brassCorner(cv, "TOPLEFT", -1, 1)
        brassCorner(cv, "TOPRIGHT", 1, 1)
        brassCorner(cv, "BOTTOMLEFT", -1, -1)
        brassCorner(cv, "BOTTOMRIGHT", 1, -1)
    end
    strap(cv, 150)
    strap(cv, -150)

    -- hover: the leather catches a little light
    local sheen = UI.Fill(cv, { 1, 0.85, 0.6 }, "OVERLAY", 7, 0.05)
    sheen:SetPoint("TOPLEFT", 4, -4)
    sheen:SetPoint("BOTTOMRIGHT", -4, 4)
    sheen:Hide()
    cv:SetScript("OnEnter", function(self)
        sheen:Show()
        cv.hint:SetTextColor(1, 0.9, 0.6, 1)
        UI:CoverTooltip(self)
    end)
    cv:SetScript("OnLeave", function()
        sheen:Hide()
        cv.hint:SetTextColor(0.80, 0.64, 0.36, 1)
        GameTooltip:Hide()
    end)
    cv:SetScript("OnClick", function()
        if cv.dragEnd and GetTime() - cv.dragEnd < 0.3 then return end
        UI:OpenBook(UI.TodayStart or UI.PlacePage)
    end)
end

------------------------------------------------------------------------
-- Holder, opening and closing
------------------------------------------------------------------------
function UI:Build()
    if self.holder then return end
    local h = CreateFrame("Frame", "WoWForeverDiaryFrame", UIParent)
    h:SetSize(BW, BH)
    h:SetPoint("CENTER")
    h:SetFrameStrata("HIGH")
    h:SetMovable(true)
    h:SetClampedToScreen(true)
    h:SetScale(WFD.S.scale or 0.9)
    tinsert(UISpecialFrames, "WoWForeverDiaryFrame")
    self.holder = h
    self.frame = h
    -- measure text at exactly the scale it is drawn at
    measureFrame:SetParent(h)
    measureFrame:ClearAllPoints()
    measureFrame:SetPoint("TOPLEFT", h, "TOPLEFT", 0, 0)
    measureFrame:SetFrameLevel(1)
    buildBook(h)
    buildCover(h)

    -- refresh the open book every ten seconds while playing when something happened; the clock and the
    -- footsteps alone (WFD.ticked, every few seconds) only once a minute, laying out the book costs a moment
    local acc, sinceTick = 0, 0
    h:SetScript("OnUpdate", function(_, dt)
        acc = acc + dt
        if acc < 10 then return end
        sinceTick = sinceTick + acc
        acc = 0
        -- never while the mouse is on the book: the page would move under the reader. It waits until
        -- the mouse leaves (or a page is turned, see ShowSpread).
        if UI.bookFrame:IsShown() and UI.bookFrame:IsMouseOver() then
            -- something new is waiting: say so, and let the reader decide when the page may change
            if WFD.dirty and UI.ShowFreshNote and UI.Fingerprint() ~= UI.shownPrint then UI:ShowFreshNote() end
            return
        end
        if UI.bookFrame:IsShown() and (WFD.dirty or (WFD.ticked and sinceTick >= 60)) then
            WFD.dirty, WFD.ticked, sinceTick = false, false, 0
            UI:Reflow()
        end
    end)
    h:Hide()
end

-- a small note at the foot of the book: "New in the diary. Click to refresh."
function UI:ShowFreshNote()
    local note = self.freshNote
    if not note then
        note = UI.Frame(self.bookFrame, 100, 24, "Button")
        note:SetFrameStrata("DIALOG")
        note:SetFrameLevel(self.bookFrame:GetFrameLevel() + 100)
        UI.Backdrop(note, "tooltip", 10, 2, { 0.06, 0.04, 0.02, 0.94 }, c.goldDk)
        note.text = UI.Text(note, 12, c.gold, "CENTER", UI.FONT, true)
        note.text:SetPoint("CENTER")
        note.text:SetText(L["New in the diary. Click to refresh."])
        note:SetSize(note.text:GetStringWidth() + 28, 24)
        note:SetPoint("BOTTOM", self.bookFrame, "TOP", 0, 2)     -- above the book: the page numbers stay free
        note:SetScript("OnClick", function() UI:Reflow() end)
        self.bookFrame:HookScript("OnHide", function() note:Hide() end)
        self.freshNote = note
    end
    note:Show()
end

function UI:Reflow()
    if not self.bookFrame then return end
    if self.freshNote then self.freshNote:Hide() end
    if UI.noteFocus then
        WFD.dirty = true      -- do not disturb while the player is writing; try again later
        return
    end
    WFD.dirty = false
    local follow = self.followToday
    UI.storyCache[WFD:NumDays()] = nil
    self:Paginate()
    if follow then
        self:ShowSpread(ceil(self:TodayPage() / 2))
    else
        self:ShowSpread(self.spread)
    end
end

-- page: a page number, or a function picking one once the book is laid out; without it the book opens at the start
-- (the endpaper with the ex libris and "this book belongs to")
function UI:OpenBook(page)
    self:Build()
    self.openedOnce = true
    self.holder:Show()
    self.cover:Hide()
    GameTooltip:Hide()          -- the tooltip of the binding belongs to the cover that has just closed
    self.bookFrame:Show()
    self.spreadShownOnce = false
    sound("IG_SPELLBOOK_OPEN", 829)
    fadeIn(self.bookFrame)
    self:Paginate()
    self.spread = 0
    self.history = {}
    if type(page) == "function" then page = page(self.book) end
    page = page or 1
    self:ShowSpread(ceil(page / 2))
end

function UI:Show()
    self:Build()
    if self.card then self.card:Hide() end
    self.bookFrame:Hide()
    self:RefreshCover()
    self.cover:Show()
    fadeIn(self.cover)
    self.holder:Show()
end

function UI:Hide()
    if self.holder then self.holder:Hide() end
end

-- the cover greets once per session; after that the book opens straight at the page where reading stopped
function UI:Toggle()
    self:Build()
    if self.holder:IsShown() then
        self:Hide()
    elseif self.openedOnce and not WFD.demo then
        if self.card then self.card:Hide() end
        self:OpenBook(UI.PlacePage)
    elseif WFD.S.cover == false and not WFD.demo then
        -- no cover wanted: straight to today
        if self.card then self.card:Hide() end
        self:OpenBook(UI.TodayStart or UI.PlacePage)
    else
        self:Show()
    end
end

function UI:DataSwitched()
    UI.ClearCaches()
    if self.bookFrame and self.bookFrame:IsShown() then
        self:Paginate()
        self:ShowSpread(ceil(self:TodayPage() / 2))
    end
    self:RefreshCover()
end

function UI:SetScale(s)
    WFD.S.scale = s
    if self.holder then self.holder:SetScale(s) end
    UI.ClearCaches()
    if self.bookFrame and self.bookFrame:IsShown() then self:Paginate() end
end

------------------------------------------------------------------------
-- Minimap button
------------------------------------------------------------------------
local mm

local function placeMinimap()
    if not mm then return end
    local a = math.rad(WFD.S.angle or 215)
    local x, y = math.cos(a), math.sin(a)
    local rw = (Minimap:GetWidth() / 2) + 5
    local rh = (Minimap:GetHeight() / 2) + 5
    local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
    if shape == "SQUARE" then
        -- push the button onto the edge of a square map
        local m = math.max(math.abs(x), math.abs(y))
        x, y = x / m, y / m
    end
    mm:ClearAllPoints()
    mm:SetPoint("CENTER", Minimap, "CENTER", x * rw, y * rh)
end

function UI:UpdateMinimapButton()
    if not mm then return end
    mm:SetShown(WFD.S.minimap)
end

WFD:OnInit(function()
    mm = CreateFrame("Button", "WoWForeverDiaryMinimapButton", Minimap)
    mm:SetSize(31, 31)
    mm:SetFrameStrata("MEDIUM")
    mm:SetFrameLevel(8)
    mm:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    mm:RegisterForDrag("LeftButton")
    local bg = mm:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetSize(20, 20)
    bg:SetPoint("TOPLEFT", 7, -5)
    local icon = mm:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    icon:SetSize(17, 17)
    icon:SetPoint("TOPLEFT", 7, -6)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local border = mm:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", 0, 0)
    mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    mm:SetScript("OnClick", function(_, button)
        if button == "RightButton" and UI.OpenSettings then UI:OpenSettings() else UI:Toggle() end
    end)
    mm:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local s = Minimap:GetEffectiveScale()
            WFD.S.angle = math.deg(math.atan2(py / s - my, px / s - mx))
            placeMinimap()
        end)
    end)
    mm:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
    mm:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("WoW Forever Diary", 1, 0.82, 0)
        local C = WFD.C
        if C then
            local d = C.days[WFD:DayIndex()]
            GameTooltip:AddLine(format(L["Day %d"], WFD:NumDays()), 1, 1, 1)
            if d then
                GameTooltip:AddLine(WFD:Count("%d kills today", d.killTotal) .. ", " .. WFD:Count("%d quests today", #d.qd), 0.8, 0.8, 0.8)
            end
        end
        GameTooltip:AddLine(L["Click to open the diary."], 0.5, 0.8, 1)
        GameTooltip:AddLine(L["Right-click for the settings."], 0.5, 0.8, 1)
        GameTooltip:AddLine(L["Drag to move this button."], 0.5, 0.8, 1)
        GameTooltip:Show()
    end)
    mm:SetScript("OnLeave", function() GameTooltip:Hide() end)
    placeMinimap()
    Minimap:HookScript("OnSizeChanged", placeMinimap)
    C_Timer.After(1, placeMinimap)      -- other addons may resize the map after login
    UI:UpdateMinimapButton()
end)

------------------------------------------------------------------------
-- Totals over the whole life of the character (used by several pages)
------------------------------------------------------------------------
function WFD:Totals()
    local C = self.C
    local t = { online = 0, kills = 0, quests = 0, deaths = 0, income = 0, spend = 0, steps = 0, xp = 0, jumps = 0, days = 0 }
    for _, d in pairs(C.days) do
        t.online = t.online + (d.online or 0)
        t.kills = t.kills + d.killTotal
        t.quests = t.quests + #d.qd
        t.deaths = t.deaths + d.deaths
        t.income = t.income + self:Sum(d.income)
        t.spend = t.spend + self:Sum(d.spend)
        t.steps = t.steps + (d.steps or 0)
        t.xp = t.xp + d.xp
        t.jumps = t.jumps + (d.jumps or 0)
        t.days = t.days + 1
    end
    return t
end
