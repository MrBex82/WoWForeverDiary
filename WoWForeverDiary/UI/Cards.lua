-- Pinned cards laid on top of the open book: a wanted poster for creatures, a portrait for people.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, min, format = math.floor, math.min, string.format

local CW, CH = 384, 540
local PAD = 40
local W = CW - PAD * 2

local levelText = UI.LevelText      -- "12", "??" for a skull, "?" when unknown (PagesAppendix.lua)

local function buildCard(self)
    local card = UI.Frame(self.holder, CW, CH)
    card:SetPoint("CENTER", self.bookFrame, "CENTER", 0, 0)
    card:SetFrameLevel(self.bookFrame:GetFrameLevel() + 60)
    card:EnableMouse(true)
    card:EnableMouseWheel(true)
    card:SetScript("OnMouseWheel", function() end)
    _G.WoWForeverDiaryCard = card
    tinsert(UISpecialFrames, "WoWForeverDiaryCard")

    local shadow = UI.Fill(card, { 0, 0, 0 }, "BACKGROUND", -8, 0.45)
    shadow:SetPoint("TOPLEFT", 8, -10)
    shadow:SetPoint("BOTTOMRIGHT", 8, -10)
    local paper = UI.Page(card, CW, CH)
    paper:SetPoint("TOPLEFT")
    paper:SetFrameLevel(card:GetFrameLevel() + 1)

    -- brass pin holding the card on the page
    local pin = CreateFrame("Frame", nil, card)
    pin:SetSize(24, 24)
    pin:SetPoint("CENTER", card, "TOP", 0, -14)
    pin:SetFrameLevel(card:GetFrameLevel() + 20)
    local ps = UI.Circle(pin, 20, { 0, 0, 0, 0.45 }, "ARTWORK", 0)
    ps:SetPoint("CENTER", 2, -3)
    local p1 = UI.Circle(pin, 18, c.goldDk, "ARTWORK", 1)
    p1:SetPoint("CENTER")
    local p2 = UI.Circle(pin, 12, c.gold, "ARTWORK", 2)
    p2:SetPoint("CENTER", -1, 1)
    local p3 = UI.Circle(pin, 4, { 1, 1, 0.9, 0.9 }, "ARTWORK", 3)
    p3:SetPoint("CENTER", -3, 3)

    local ok, close = pcall(CreateFrame, "Button", nil, card, "UIPanelCloseButton")
    if not (ok and close) then close = UI.Button(card, "X", 24, 24) end
    close:SetPoint("TOPRIGHT", -4, -4)
    close:SetFrameLevel(card:GetFrameLevel() + 20)
    close:SetScript("OnClick", function() card:Hide() end)

    local canvas = CreateFrame("Frame", nil, card)
    canvas:SetAllPoints()
    canvas:SetFrameLevel(card:GetFrameLevel() + 5)
    card.canvas = canvas
    card.pool = UI.NewPool(canvas)

    card.model = UI.ModelBox(card, W, 170)
    card.model:SetFrameLevel(card:GetFrameLevel() + 8)

    -- things that sit on top of the portrait (seal)
    card.over = CreateFrame("Frame", nil, card)
    card.over:SetAllPoints()
    card.over:SetFrameLevel(card:GetFrameLevel() + 14)
    card.overPool = UI.NewPool(card.over)

    -- the book behind the card darkens a little; a click on it puts the card away
    local shade = CreateFrame("Frame", nil, self.holder)
    shade:SetAllPoints(self.bookFrame)
    shade:SetFrameLevel(card:GetFrameLevel() - 1)
    shade:EnableMouse(true)
    local dim = shade:CreateTexture(nil, "BACKGROUND")
    dim:SetAllPoints()
    dim:SetColorTexture(0, 0, 0, 0.35)
    shade:SetScript("OnMouseDown", function() card:Hide() end)
    shade:Hide()
    card:HookScript("OnShow", function() shade:Show() end)
    card:HookScript("OnHide", function() shade:Hide() end)

    -- arrows beside the card: the previous and the next one of the same album
    local function step(dir)
        local list = UI.CardOrder(card.kind)
        for i, k in ipairs(list) do
            if k == card.key then
                local nxt = list[((i - 1 + dir) % #list) + 1]
                if nxt ~= nil then UI:ShowCard(card.kind, nxt) end
                return
            end
        end
    end
    card.prev = UI.PageArrow(card, "Prev", function() step(-1) end)
    card.prev:SetPoint("RIGHT", card, "LEFT", -6, 0)
    card.next = UI.PageArrow(card, "Next", function() step(1) end)
    card.next:SetPoint("LEFT", card, "RIGHT", 6, 0)
    card:EnableKeyboard(false)

    card:Hide()
    self.card = card
    return card
end

-- the order the cards of one kind are leafed through: as in their album
function UI.CardOrder(kind)
    local C = WFD.C
    local arr = {}
    if kind == "creature" then
        for id, m in pairs(C.mobs or {}) do arr[#arr + 1] = { k = id, t = m.first or 0, n = m.name or "" } end
    elseif kind == "catch" then
        for id, e in pairs(C.catch or {}) do arr[#arr + 1] = { k = id, t = e.first or 0, n = e.name or "" } end
    else
        for key, p in pairs(C.npcs or {}) do
            if not p.obj then arr[#arr + 1] = { k = key, t = 0, n = p.name or "" } end
        end
    end
    table.sort(arr, function(a, b)
        if a.t ~= b.t then return a.t < b.t end
        if a.n ~= b.n then return a.n < b.n end
        return tostring(a.k) < tostring(b.k)
    end)
    local out = {}
    for i, e in ipairs(arr) do out[i] = e.k end
    return out
end

-- the portrait box: position, height and a frame in the colour of the subject
local function placeModel(card, y, h, col)
    local m = card.model
    m:ClearAllPoints()
    m:SetPoint("TOP", card, "TOP", 0, y)
    m:SetSize(W, h)
    if m.SetBackdropBorderColor then m:SetBackdropBorderColor(col4(col)) end
end

-- a centred band with small caps text, e.g. "BOSS  -  LEVEL 12"
local function chip(pool, canvas, y, text, col)
    local t = pool:Text(9, { 1, 0.95, 0.85, 1 }, UI.FONT, "CENTER")
    t:SetText(text:upper())
    local bw = t:GetStringWidth() + 22
    local band = pool:Rect(col, 0.9)
    band:SetSize(bw, 16)
    band:SetPoint("TOP", canvas, "TOP", 0, y)
    t:SetPoint("CENTER", band, "CENTER", 0, 0)
    for s = -1, 1, 2 do
        local d = pool:Diamond(6, col)
        d:SetPoint("CENTER", band, s < 0 and "LEFT" or "RIGHT", 0, 0)
    end
end

-- a row of figures in light boxes: { value, label, colour }
local function tiles(pool, canvas, y, list)
    local n = #list
    local tw = (W - (n - 1) * 8) / n
    for i, t in ipairs(list) do
        local x = PAD + (i - 1) * (tw + 8)
        local bg = pool:Rect(c.paperDk, 0.45)
        bg:SetSize(tw, 42)
        bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
        local bar = pool:Rect(t[3] or c.inkSoft, 0.9)
        bar:SetSize(tw, 2)
        bar:SetPoint("TOPLEFT", bg, "TOPLEFT")
        local v = pool:Text(18, t[3] or c.ink, UI.HEAD, "CENTER")
        v:SetText(tostring(t[1]))
        v:SetWidth(tw)
        v:SetWordWrap(false)
        v:SetPoint("TOP", bg, "TOP", 0, -5)
        local l = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
        l:SetText(t[2]:upper())
        UI.FitText(l, tw - 6, 9, 7, UI.FONT)
        l:SetWidth(tw - 4)
        l:SetWordWrap(false)
        l:SetPoint("TOP", bg, "TOP", 0, -28)
    end
end

-- small ink bar chart of a per-day series
-- Kills per day: the last two weeks of the diary as slim bars in the colour of the creature's rarity,
-- in a dark panel with a fine gold frame; days without a kill are small dots, the best day carries its number.
local SLOTS = 14
local function bars(pool, canvas, y, title, values, h, col)
    h = h or 40
    col = col or { 0.91, 0.76, 0.42, 1 }
    local t = pool:Text(9, c.redInk, UI.FONT)
    t:SetText(title:upper())
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, y)
    local top = y - 14
    -- the panel
    local panel = pool:Rect({ 0.04, 0.025, 0.015 }, 0.55)
    panel:SetSize(W, h)
    panel:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, top)
    for _, e in ipairs({ { 0, 0, W, 1 }, { 0, -h + 1, W, 1 }, { 0, 0, 1, h }, { W - 1, 0, 1, h } }) do
        local r = pool:Rect(c.redInk, 0.28)
        r:SetSize(e[3], e[4])
        r:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD + e[1], top + e[2])
    end
    -- the last fourteen diary days (or the first fourteen, while the book is young)
    local last = WFD:NumDays()
    local first = math.max(1, last - SLOTS + 1)
    local peak, peakDay = 0, nil
    for d = first, first + SLOTS - 1 do
        local v = values[d] or 0
        if v > peak then peak, peakDay = v, d end
    end
    local PADX, PADT, PADB = 8, 12, 5
    local slot = (W - PADX * 2) / SLOTS
    local bw = math.max(3, math.min(10, slot * 0.55))
    local ih = h - PADT - PADB
    local baseY = top - h + PADB
    local line = pool:Rect(c.inkSoft, 0.35)
    line:SetSize(W - PADX * 2, 1)
    line:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD + PADX, baseY)
    for i = 0, SLOTS - 1 do
        local d = first + i
        local cx = PAD + PADX + (i + 0.5) * slot
        local v = values[d] or 0
        if d > last then
            -- days still to come: nothing
        elseif v > 0 then
            local bh = math.max(3, ih * v / math.max(1, peak))
            local glow = pool:Rect(col, 0.12)
            glow:SetSize(bw + 4, bh + 2)
            glow:SetPoint("BOTTOM", canvas, "TOPLEFT", cx, baseY)
            local b = pool:Grad("VERTICAL", { col[1] * 0.45, col[2] * 0.45, col[3] * 0.45, 1 }, { col[1], col[2], col[3], 1 })
            b:SetSize(bw, bh)
            b:SetPoint("BOTTOM", canvas, "TOPLEFT", cx, baseY)
            local cap = pool:Rect({ 1, 0.95, 0.80 }, 0.55)
            cap:SetSize(bw, 1)
            cap:SetPoint("TOP", b, "TOP", 0, 0)
            if d == peakDay then
                local n = pool:Text(9, c.ink, UI.FONT, "CENTER")
                n:SetText(tostring(v))
                n:SetPoint("BOTTOM", canvas, "TOPLEFT", cx, baseY + bh + 1)
            end
        else
            local dot = pool:Rect(c.inkFaint, 0.5)
            dot:SetSize(2, 2)
            dot:SetPoint("BOTTOM", canvas, "TOPLEFT", cx, baseY + 1)
        end
        if d <= last then
            local hot = pool:Hot({ format(L["Day %d"], d) .. "  -  " .. WFD:DateStr(d), tostring(v) }, function()
                UI.card:Hide()
                UI:GoToDay(d)
            end)
            hot:SetPoint("BOTTOM", canvas, "TOPLEFT", cx, top - h)
            hot:SetSize(slot, h)
            hot:SetFrameLevel(canvas:GetFrameLevel() + 6)
            hot.hl:SetAlpha(0.06)
        end
    end
    -- first and last day under the panel
    local d1 = pool:Text(8, c.inkFaint, UI.FONT)
    d1:SetText(format(L["Day %d"], first))
    d1:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, top - h - 3)
    local d2 = pool:Text(8, c.inkFaint, UI.FONT, "RIGHT")
    d2:SetText(format(L["Day %d"], first + SLOTS - 1))
    d2:SetPoint("TOPRIGHT", canvas, "TOPLEFT", PAD + W, top - h - 3)
end

local function dayLink(t)
    if not t then return "-", nil end
    local day = WFD:DayIndex(t)
    local p = UI.book and UI.book.dayPage[day]
    local txt = date(WFD.loc.date, t) .. (p and ("  (" .. format(L["p. %d"], UI.PageNumber(p)) .. ")") or "")
    return txt, p and function()
        UI.card:Hide()
        UI:GoToPage(p)
    end
end

------------------------------------------------------------------------
-- Wanted poster
------------------------------------------------------------------------
local RARITY = {
    boss   = { col = { 0.62, 0.10, 0.06, 1 }, label = "Boss" },
    rare   = { col = { 0.22, 0.38, 0.66, 1 }, label = "Rare" },
    elite  = { col = { 0.74, 0.54, 0.14, 1 }, label = "Elite" },
    normal = { col = { 0.55, 0.45, 0.32, 1 }, label = "Normal" },
}
local function rarityOf(m)
    if m.boss then return RARITY.boss end
    if m.rare or m.cls == "rare" or m.cls == "rareelite" then return RARITY.rare end
    if m.cls == "elite" then return RARITY.elite end
    return RARITY.normal
end
-- marks for one kind of creature: always one more to reach
local MARKS = { 5, 25, 100, 250, 500, 1000 }

local function renderCreature(card, id)
    local C = WFD.C
    local m = C.mobs[id]
    if not m then return end
    local pool, canvas = card.pool, card.canvas
    local r = rarityOf(m)

    -- WANTED, big, between two rules
    local wanted = pool:Text(36, c.ink, UI.HEAD, "CENTER")
    wanted:SetText(L["WANTED"])
    UI.FitText(wanted, W - 60, 36, 22)
    wanted:SetPoint("TOP", canvas, "TOP", 0, -26)
    local ww = wanted:GetStringWidth() / 2 + 14
    for s = -1, 1, 2 do
        local ln = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, s < 0 and 0 or 0.8 }, { 0.91, 0.76, 0.42, s < 0 and 0.8 or 0 })
        ln:SetSize(W / 2 - ww, 2)
        ln:SetPoint(s < 0 and "RIGHT" or "LEFT", canvas, "TOP", s * ww, -46)
    end
    chip(pool, canvas, -68, L[r.label] .. "  -  " .. format(L["Level %s"], levelText(m))
        .. (m.ctype and ("  -  " .. m.ctype) or ""), r.col)

    placeModel(card, -92, 168, r.col)
    card.model:Show3D(id)
    -- how many were slain: a badge on the corner of the portrait
    local seal = card.overPool:Get("countbadge", function(p) return UI.CountBadge(p, 30) end)
    local key = (r == RARITY.boss and "boss") or (r == RARITY.rare and "rare") or (r == RARITY.elite and "elite") or "normal"
    seal:SetCount(UI.ShortCount(m.kills), UI.BADGE_COLOURS[key])
    seal:SetPoint("RIGHT", canvas, "TOPRIGHT", -PAD + 10, -92 - 168 + 2)

    local n = pool:Text(24, c.ink, UI.HEAD, "CENTER")
    n:SetText(m.name or "?")
    UI.FitText(n, W, 24, 15)
    n:SetWidth(W)
    n:SetWordWrap(false)
    n:SetPoint("TOP", canvas, "TOP", 0, -272)
    local z = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
    z:SetText((L["Seen in"] .. " " .. (m.zone and WFD:Place(m.zone, "in") or "-")):upper())
    z:SetWidth(W)
    z:SetPoint("TOP", canvas, "TOP", 0, -298)
    -- a line the character wrote beside it
    local note = pool:Text(11, c.inkSoft, UI.FONT, "CENTER")
    note:SetText(WFD:Quote(WFD:MarginNote(id, m)))
    UI.FitText(note, W, 11, 9, UI.FONT)
    note:SetWidth(W)
    note:SetWordWrap(false)
    note:SetPoint("TOP", canvas, "TOP", 0, -312)

    local rank, count = 1, 0
    for _, o in pairs(C.mobs) do
        count = count + 1
        if o.kills > m.kills then rank = rank + 1 end
    end
    local nem = C.nemesis[m.name or ""]
    tiles(pool, canvas, -332, {
        { m.kills, L["Slain"], c.bad },
        { "#" .. rank, format(L["of %d kinds"], count), c.ink },
        { nem and nem.n or 0, L["Killed you"], nem and c.bad or c.inkSoft },
    })

    local firstTxt, firstGo = dayLink(m.first)
    local lastTxt, lastGo = dayLink(m.last)
    -- the first one: and at which level of your own
    if m.fpl then firstTxt = format(L["Level %s"], tostring(m.fpl)) .. ",  " .. firstTxt end
    UI.LeaderLine(pool, canvas, PAD, -382, W, L["First kill"], firstTxt, 13, c.inkSoft, firstGo)
    UI.LeaderLine(pool, canvas, PAD, -399, W, L["Last kill"], lastTxt, 13, c.inkSoft, lastGo)
    -- the best thing it left behind
    local _, lootV = UI.LeaderLine(pool, canvas, PAD, -416, W, L["Best loot"], m.best and WFD:ItemName(m.best) or "-", 13, c.inkSoft)
    if m.best then
        local q = WFD.qualityColors[m.bestQ or 1] or WFD.qualityColors[1]
        lootV:SetTextColor(q[1], q[2], q[3], 1)
        local hot = pool:Hot(nil, nil, m.best)
        hot:SetPoint("TOPLEFT", lootV, "TOPLEFT", -4, 4)
        hot:SetPoint("BOTTOMRIGHT", lootV, "BOTTOMRIGHT", 4, -4)
    end

    -- the next mark for this kind
    local prev, nextMark = 0, nil
    for _, mk in ipairs(MARKS) do
        if m.kills < mk then nextMark = mk break end
        prev = mk
    end
    local cap = pool:Text(9, c.redInk, UI.FONT)
    cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, -436)
    local val = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
    val:SetPoint("TOPRIGHT", canvas, "TOPLEFT", PAD + W, -435)
    if nextMark then
        cap:SetText(format(L["Next mark: %d slain"], nextMark):upper())
        val:SetText(m.kills .. " / " .. nextMark)
        UI.ProgressBar(pool, canvas, PAD, -449, W, 5, (m.kills - prev) / (nextMark - prev), r.col)
    else
        cap:SetText(L["Every mark reached"]:upper())
        val:SetText(tostring(m.kills))
        UI.ProgressBar(pool, canvas, PAD, -449, W, 5, 1, c.goldDk)
    end

    local perDay = {}
    for d, day in pairs(C.days) do perDay[d] = day.kills[id] or 0 end
    local chartCol = (r == RARITY.boss and { 0.95, 0.45, 0.32, 1 }) or (r == RARITY.rare and { 0.50, 0.70, 1.00, 1 })
        or (r == RARITY.elite and { 1.00, 0.84, 0.40, 1 }) or { 0.91, 0.76, 0.42, 1 }
    bars(pool, canvas, -462, L["KILLS PER DAY"], perDay, 38, chartCol)
end

------------------------------------------------------------------------
-- Acquaintance: a calling card
------------------------------------------------------------------------
local function renderPerson(card, key)
    local C = WFD.C
    local n = C.npcs[key]
    if not n then return end
    local pool, canvas = card.pool, card.canvas
    local k = pool:Text(10, c.redInk, UI.FONT, "CENTER")
    k:SetText(L["Acquaintance"]:upper())
    k:SetPoint("TOP", canvas, "TOP", 0, -30)
    local nm = pool:Text(26, c.ink, UI.HEAD, "CENTER")
    nm:SetText(n.name or "?")
    UI.FitText(nm, W, 26, 16)
    nm:SetWidth(W)
    nm:SetWordWrap(false)
    nm:SetPoint("TOP", canvas, "TOP", 0, -44)

    -- their trades as a row of small plaques
    local roles = {}
    for _, r in ipairs(UI.ROLE_ORDER or {}) do
        if n.roles and n.roles[r] and r ~= "talk" then roles[#roles + 1] = r end
    end
    local names = {}
    local sx = CW / 2 - (#roles * 28 - 6) / 2
    for i, r in ipairs(roles) do
        local cx = sx + (i - 1) * 28 + 11
        local pl = pool:Plaque(cx, -88, 20, UI.IconPath(UI.ROLE_ICONS[r], "people"), { 0.72, 0.54, 0.22, 1 }, true)
        local hot = pool:Hot({ WFD:RoleName(r) })
        hot:SetPoint("CENTER", pl, "CENTER")
        hot:SetSize(24, 24)
        names[#names + 1] = WFD:RoleName(r)
    end
    local rl = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
    rl:SetText((#names > 0 and table.concat(names, "  -  ") or WFD:RoleName("talk")):upper())
    rl:SetWidth(W)
    rl:SetWordWrap(false)
    rl:SetPoint("TOP", canvas, "TOP", 0, #roles > 0 and -104 or -86)

    placeModel(card, -122, 146, { 0.72, 0.54, 0.22, 1 })
    card.model:Show3D(type(key) == "number" and key or nil)

    local quests = {}
    for _, q in pairs(C.quests) do
        if q.giver == key or q.turnin == key then quests[#quests + 1] = q end
    end
    table.sort(quests, function(a, b) return (a.acc or a.done or 0) < (b.acc or b.done or 0) end)
    local firstDay = n.first and WFD:DayIndex(n.first)
    local regular = (n.talks or 0) >= 10
    tiles(pool, canvas, -280, {
        { n.talks or 0, L["Conversations"], regular and c.redInk or c.ink },
        { #quests, L["Quests"], c.ink },
        { firstDay and format(L["Day %d"], firstDay) or "-", L["First met"], c.ink },
    })

    local firstTxt, firstGo = dayLink(n.first)
    local lastTxt, lastGo = dayLink(n.last)
    UI.LeaderLine(pool, canvas, PAD, -334, W, L["Found in"], n.zone or "-", 13, c.inkSoft)
    UI.LeaderLine(pool, canvas, PAD, -354, W, L["Place"], (n.sub and n.sub ~= "") and n.sub or "-", 13, c.inkSoft)
    UI.LeaderLine(pool, canvas, PAD, -374, W, L["First met"], firstTxt, 13, c.inkSoft, firstGo)
    UI.LeaderLine(pool, canvas, PAD, -394, W, L["Last met"], lastTxt, 13, c.inkSoft, lastGo)

    local qt = pool:Text(9, c.redInk, UI.FONT)
    qt:SetText(L["QUESTS WITH THIS PERSON"])
    qt:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, -422)
    if #quests == 0 then
        local e = pool:Text(12, c.inkFaint, UI.FONT)
        e:SetText(L["No quests recorded."])
        e:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, -438)
    end
    for i = 1, min(3, #quests) do
        local q = quests[i]
        local qy = -438 - (i - 1) * 18
        local box = pool:Rect(c.inkSoft, 0.9)
        box:SetSize(10, 10)
        box:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, qy - 2)
        local inner = pool:Rect({ 0.10, 0.07, 0.04 }, 1, "ARTWORK", 1)
        inner:SetSize(8, 8)
        inner:SetPoint("CENTER", box, "CENTER")
        if q.done then
            local tick = pool:Icon("Interface\\Buttons\\UI-CheckBox-Check", 18, "ARTWORK", 2)
            tick:SetTexCoord(0, 1, 0, 1)
            tick:SetVertexColor(0.95, 0.80, 0.40, 1)
            tick:SetPoint("CENTER", box, "CENTER", 2, 2)
        end
        local t = pool:Text(12, c.ink, UI.FONT)
        t:SetText(q.title or "?")
        t:SetWidth(W - 18)
        t:SetWordWrap(false)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD + 16, qy)
    end
    if #quests > 3 then
        local more = pool:Text(10, c.inkFaint, UI.FONT)
        more:SetText(format("+ %d ...", #quests - 3))
        more:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD + 16, -438 - 3 * 18)
    end
    if n.map then
        local fs = pool:Link(L["Show on map"] .. "  >", function()
            card:Hide()
            UI:ShowMapOf(n.map)
        end, 13)
        fs:SetPoint("BOTTOMRIGHT", canvas, "BOTTOMRIGHT", -PAD, 22)
    end
end

------------------------------------------------------------------------
-- A catch: what the line brought up
------------------------------------------------------------------------
local CATCH_MARKS = { 5, 25, 100, 250, 500, 1000 }

local function renderCatch(card, id)
    local C = WFD.C
    local e = C.catch and C.catch[id]
    if not e then return end
    local pool, canvas = card.pool, card.canvas
    local k = UI.FISH_KINDS[e.kind or "other"] or UI.FISH_KINDS.other
    local qc = UI.FISH_QCOL[min(5, e.q or 1)] or UI.FISH_QCOL[1]

    local head = pool:Text(36, c.ink, UI.HEAD, "CENTER")
    head:SetText(L["CAUGHT"])
    UI.FitText(head, W - 60, 36, 22)
    head:SetPoint("TOP", canvas, "TOP", 0, -26)
    local hw = head:GetStringWidth() / 2 + 14
    for s = -1, 1, 2 do
        local ln = pool:Grad("HORIZONTAL", { 0.91, 0.76, 0.42, s < 0 and 0 or 0.8 }, { 0.91, 0.76, 0.42, s < 0 and 0.8 or 0 })
        ln:SetSize(W / 2 - hw, 2)
        ln:SetPoint(s < 0 and "RIGHT" or "LEFT", canvas, "TOP", s * hw, -46)
    end
    chip(pool, canvas, -68, L[k.label], k.col)

    local pl = pool:Plaque(CW / 2, -150, 84, UI.FishIcon(e, id), qc, true, UI.ShortCount(e.n or 0))
    local ph = pool:Hot(nil, nil, e.link)
    ph:SetPoint("CENTER", pl, "CENTER")
    ph:SetSize(96, 96)

    local n = pool:Text(24, c.ink, UI.HEAD, "CENTER")
    n:SetText(e.name or "?")
    UI.FitText(n, W, 24, 15)
    n:SetWidth(W)
    n:SetWordWrap(false)
    n:SetPoint("TOP", canvas, "TOP", 0, -214)

    -- the waters, most first
    local waters, nWaters = {}, 0
    for map, cnt in pairs(e.zones or {}) do
        nWaters = nWaters + 1
        waters[#waters + 1] = { map = map, n = cnt }
    end
    table.sort(waters, function(a, b) return a.n > b.n end)
    local z = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
    z:SetText((L["Mostly caught in"] .. " " .. (waters[1] and WFD:Place(WFD:MapName(waters[1].map) or "?", "in") or "-")):upper())
    z:SetWidth(W)
    z:SetPoint("TOP", canvas, "TOP", 0, -244)

    local share = (C.catchTotal or 0) > 0 and (e.n or 0) / C.catchTotal or 0
    tiles(pool, canvas, -270, {
        { e.n or 0, L["Caught"], c.ink },
        { format("%d%%", floor(share * 100 + 0.5)), L["Of all catches"], c.ink },
        { nWaters, L["Waters"], c.ink },
    })

    local firstTxt, firstGo = dayLink(e.first)
    local lastTxt, lastGo = dayLink(e.last)
    UI.LeaderLine(pool, canvas, PAD, -326, W, L["First catch"], firstTxt, 13, c.inkSoft, firstGo)
    UI.LeaderLine(pool, canvas, PAD, -346, W, L["Last catch"], lastTxt, 13, c.inkSoft, lastGo)
    if (e.lured or 0) > 0 then
        UI.LeaderLine(pool, canvas, PAD, -366, W, L["On a lure"], tostring(e.lured), 13, c.inkSoft)
    end

    local wt = pool:Text(9, c.redInk, UI.FONT)
    wt:SetText(L["WHERE IT BIT"])
    wt:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, -396)
    for i = 1, min(3, #waters) do
        UI.LeaderLine(pool, canvas, PAD, -412 - (i - 1) * 18, W, WFD:MapName(waters[i].map) or "?", tostring(waters[i].n), 13, c.inkSoft)
    end

    local prev, nextMark = 0, nil
    for _, mk in ipairs(CATCH_MARKS) do
        if (e.n or 0) < mk then nextMark = mk break end
        prev = mk
    end
    local cap = pool:Text(9, c.redInk, UI.FONT)
    cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", PAD, -474)
    local val = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
    val:SetPoint("TOPRIGHT", canvas, "TOPLEFT", PAD + W, -473)
    if nextMark then
        cap:SetText(format(L["Next mark: %d caught"], nextMark):upper())
        val:SetText((e.n or 0) .. " / " .. nextMark)
        UI.ProgressBar(pool, canvas, PAD, -487, W, 5, ((e.n or 0) - prev) / (nextMark - prev), k.col)
    else
        cap:SetText(L["Every mark reached"]:upper())
        val:SetText(tostring(e.n or 0))
        UI.ProgressBar(pool, canvas, PAD, -487, W, 5, 1, c.goldDk)
    end
end

function UI:ShowCard(kind, key)
    if not self.holder then return end
    local card = self.card or buildCard(self)
    card.kind, card.key = kind, key
    local many = #UI.CardOrder(kind) > 1
    card.prev:SetShown(many)
    card.next:SetShown(many)
    card.pool:Begin()
    card.overPool:Begin()
    card.model:SetShown(kind ~= "catch")
    if kind == "creature" then renderCreature(card, key)
    elseif kind == "catch" then renderCatch(card, key)
    else renderPerson(card, key) end
    card.pool:End()
    card.overPool:End()
    card:Show()
    card:SetAlpha(0)
    card.t = 0
    card:SetScript("OnUpdate", function(s, dt)
        s.t = s.t + dt
        local a = min(1, s.t / 0.18)
        s:SetAlpha(a)
        if a >= 1 then s:SetScript("OnUpdate", nil) end
    end)
end

-- open the map page of an area
function UI:ShowMapOf(mapID)
    local b = self.book
    if not b then return end
    if b.mapPage and b.mapPage[mapID] then
        self:GoToPage(b.mapPage[mapID])
        return
    end
    if b.sectionStart.maps then self:GoToPage(b.sectionStart.maps) end
end
