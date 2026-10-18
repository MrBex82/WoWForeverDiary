-- Searching the book: a spyglass at the top of the spine opens a field; typing finds days, people,
-- creatures, quests, places, honours and parts of the book. A click opens the page (or the card).
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format

local PANEL_W, ROW_H, MAX_ROWS = 380, 24, 12

-- lower case, including the common accented capitals (string.lower only knows A-Z)
local UPPER = {
    ["Ä"] = "ä", ["Ö"] = "ö", ["Ü"] = "ü", ["É"] = "é", ["È"] = "è", ["À"] = "à", ["Ç"] = "ç", ["Ñ"] = "ñ",
    ["Á"] = "á", ["Í"] = "í", ["Ó"] = "ó", ["Ú"] = "ú", ["Ê"] = "ê", ["Ô"] = "ô", ["Â"] = "â", ["Õ"] = "õ", ["Ã"] = "ã",
}
local function lower(s)
    s = (s or ""):lower()
    for k, v in pairs(UPPER) do s = s:gsub(k, v) end
    return s
end

------------------------------------------------------------------------
-- The index, built when the panel opens (and again after the book changed)
------------------------------------------------------------------------
local index, indexBook

local function pageOfQuest(book, id)
    for i, p in ipairs(book.pages) do
        if p.kind == "quests" then
            for _, r in ipairs(p.rows or {}) do if r.id == id then return i end end
        end
    end
    return book.sectionStart.quests
end

local function buildIndex()
    local book, C = UI.book, WFD.C
    local out = {}
    local function add(kind, text, icon, go, hay, rank)
        if not text or text == "" then return end
        out[#out + 1] = { kind = kind, text = text, icon = icon, go = go, hay = lower(hay or text), rank = rank or 5 }
    end
    local function toPage(p) return p and function() UI:GoToPage(p) end end
    -- parts of the book and chapters, as in the contents
    for _, p in ipairs(book.pages) do
        if p.kind == "toc" then
            for _, e in ipairs(p.entries or {}) do
                if not e.header and e.page then add("part", e.text, e.icon and UI.Icon(e.icon) or UI.Icon("journal"), toPage(e.page), nil, 1) end
            end
        elseif p.kind == "map" and p.entry and p.entry.zone then
            add("place", p.entry.zone, UI.Icon("map"), toPage(p.index), nil, 4)
        end
    end
    -- regions and the places within them: their map page, else the day you first came there
    local placed = {}
    for _, p in ipairs(book.pages) do
        if p.kind == "map" and p.entry and p.entry.zone then placed[p.entry.zone] = true end
    end
    local function dayOf(t) local d = t and WFD:DayIndex(t) return d and book.dayPage[d] end
    for name, z in pairs(C.zones or {}) do
        if not placed[name] then
            placed[name] = true
            local mp = book.mapPage and z.map and book.mapPage[z.map]
            add("place", name, UI.Icon("map"), toPage(mp or book.dayPage[z.day or 0] or dayOf(z.first)), nil, 4)
        end
        for sub, t in pairs(z.sub or {}) do
            if not placed[sub] then
                placed[sub] = true
                add("place", sub, UI.Icon("sight"), toPage(dayOf(type(t) == "number" and t or nil)), sub .. " " .. name, 5)
            end
        end
    end
    for key, n in pairs(C.npcs or {}) do
        if n.name then add("person", n.name, UI.Icon("people"), function() UI:ShowCard("person", key) end, nil, 2) end
    end
    for id, m in pairs(C.mobs or {}) do
        if m.name then add("creature", m.name, UI.Icon("bestiary"), function() UI:ShowCard("creature", id) end, nil, 3) end
    end
    for id, e in pairs(C.catch or {}) do
        if e.name then add("catch", e.name, UI.FishIcon and UI.FishIcon(e, id) or UI.Icon("loot"), function() UI:ShowCard("catch", id) end, nil, 3) end
    end
    for id, q in pairs(C.quests or {}) do
        if q.title then
            local p = pageOfQuest(book, id)
            add("quest", q.title, UI.Icon("quests"), toPage(p), q.title .. " " .. (q.quote or ""), 3)
        end
    end
    -- treasures: every notable find, leading to the page it is shown on
    local treasurePage = {}
    for _, p in ipairs(book.pages) do
        if p.kind == "treasures" then
            for _, r in ipairs(p.rows or {}) do
                for _, it in ipairs(r.pair or {}) do treasurePage[it.id] = p.index end
            end
        end
    end
    local seenItem = {}
    for _, d in pairs(C.days) do
        for id, e in pairs(d.loot or {}) do
            if (e.q or 1) >= 2 and not seenItem[id] and e.link then
                seenItem[id] = true
                add("treasure", WFD:ItemName(e.link), WFD:ItemIcon(e.link) or UI.Icon("loot"),
                    toPage(treasurePage[id] or book.sectionStart.treasures), nil, 4)
            end
        end
    end
    for _, h in ipairs(WFD.HONOURS or {}) do
        local tiers = C.honourTiers and C.honourTiers[h.key] or 0
        if not h.secret or tiers > 0 then
            add("honour", L[h.name], UI.IconPath(h.icon, "honour"), toPage(book.sectionStart.honour), nil, 4)
        end
    end
    -- every day: the told story and your own notes
    for d = 1, WFD:NumDays() do
        local p = book.dayPage[d]
        if p and C.days[d] then
            local story = UI.storyCache[d] or WFD:Narrate(d)
            local own = C.dayNotes and C.dayNotes[d] or ""
            out[#out + 1] = { kind = "day", day = d, text = format(L["Day %d"], d), full = story .. " " .. own,
                hay = lower(story .. " " .. own), icon = UI.Icon("journal"), go = toPage(p), rank = 6 }
        end
    end
    index, indexBook = out, book
end

-- a few words around the match, cut at word ends and never inside a letter
local function snippet(full, hay, q)
    local s = hay:find(q, 1, true)
    if not s then return "" end
    local a = max(1, s - 28)
    local b = min(#full, s + #q + 40)
    while a > 1 and full:byte(a) and full:byte(a) >= 128 and full:byte(a) < 192 do a = a - 1 end
    while b < #full and full:byte(b + 1) and full:byte(b + 1) >= 128 and full:byte(b + 1) < 192 do b = b + 1 end
    local text = full:sub(a, b):gsub("\n", " ")
    if a > 1 then text = "... " .. text:gsub("^%S*%s", "") end
    if b < #full then text = text:gsub("%s%S*$", "") .. " ..." end
    return text
end

local function find(q)
    q = lower(q):gsub("^%s+", ""):gsub("%s+$", "")
    if #q < 2 then return {} end
    if not index or indexBook ~= UI.book then buildIndex() end
    local hits = {}
    for _, e in ipairs(index) do
        local pos = e.hay:find(q, 1, true)
        if pos then hits[#hits + 1] = { e = e, starts = (pos == 1) } end
    end
    table.sort(hits, function(a, b)
        if a.e.rank ~= b.e.rank then return a.e.rank < b.e.rank end
        if a.starts ~= b.starts then return a.starts end
        if a.e.day and b.e.day then return a.e.day > b.e.day end
        return a.e.text < b.e.text
    end)
    return hits, q
end

------------------------------------------------------------------------
-- The panel
------------------------------------------------------------------------
local KIND_LABEL = {
    part = "Contents", person = "Acquaintance", creature = "Bestiary", quest = "Quest", place = "Maps",
    honour = "Honour", day = "Diary", treasure = "Treasures", catch = "Angler's log",
}

local panel

local function close()
    if panel then
        panel.edit:ClearFocus()
        panel:Hide()
    end
end

-- the chosen result (arrow keys, Tab or the mouse): Enter opens it
local function choose(i)
    local n = 0
    for _, row in ipairs(panel.rows) do if row:IsShown() then n = n + 1 end end
    panel.sel = n > 0 and ((((i or 1) - 1) % n) + 1) or nil
    for k, row in ipairs(panel.rows) do row.sel:SetShown(k == panel.sel) end
end

local function showResults()
    local hits, q = find(panel.edit:GetText() or "")
    panel.hits = hits
    for i, row in ipairs(panel.rows) do
        local h = hits[i]
        if h and i <= MAX_ROWS then
            local e = h.e
            row.icon:SetTexture(e.icon)
            if e.kind == "day" then
                row.text:SetText("|cffe8c26a" .. e.text .. "|r  " .. snippet(e.full, e.hay, q))
            else
                row.text:SetText(e.text)
            end
            row.kind:SetText(L[KIND_LABEL[e.kind] or "Diary"]:upper())
            row.go = e.go
            row:Show()
        else
            row:Hide()
        end
    end
    local n = min(#hits, MAX_ROWS)
    local typed = #(panel.edit:GetText() or "") >= 2
    panel.none:SetShown(typed and n == 0)
    panel.more:SetShown(#hits > MAX_ROWS)
    panel.more:SetText(format(L["%d more results - type a little more"], #hits - MAX_ROWS))
    local h = 52 + max(n, (typed and n == 0) and 1 or 0) * ROW_H + (#hits > MAX_ROWS and 18 or 0)
    panel:SetHeight(h)
    choose(1)
end

local function open(row)
    if not row.go then return end
    local go = row.go
    close()
    go()
end

local function build(bf)
    local p = UI.Frame(bf, PANEL_W, 60)      -- with the backdrop template, or the panel has no background
    p:SetPoint("TOP", bf, "TOP", 0, -34)
    p:SetFrameLevel(bf:GetFrameLevel() + 40)
    p:EnableMouse(true)
    UI.Backdrop(p, "tooltip", 14, 3, { 0.07, 0.045, 0.025, 0.97 }, { 0.90, 0.70, 0.30, 1 })

    -- the field
    local box = UI.Frame(p, PANEL_W - 24, 28)
    box:SetPoint("TOP", 0, -12)
    UI.Backdrop(box, "tooltip", 10, 2, { 0.02, 0.01, 0.005, 0.9 }, { 0.62, 0.48, 0.22, 1 })
    local glass = box:CreateTexture(nil, "ARTWORK")
    glass:SetSize(18, 18)
    glass:SetPoint("LEFT", 6, 0)
    glass:SetTexture(UI.Icon("search"))
    glass:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    local e = CreateFrame("EditBox", nil, box)
    e:SetPoint("TOPLEFT", 30, -4)
    e:SetPoint("BOTTOMRIGHT", -8, 4)
    e:SetAutoFocus(false)
    e:SetFont(UI.FONT, 13, "")
    e:SetTextColor(col4(c.ink))
    e:SetMaxLetters(60)
    local hint = UI.Text(box, 12, c.inkFaint, "LEFT", UI.FONT)
    hint:SetPoint("LEFT", 32, 0)
    hint:SetText(L["Search: a name, a quest, a place ..."])
    e:SetScript("OnTextChanged", function(s)
        hint:SetShown(s:GetText() == "")
        showResults()
    end)
    e:SetScript("OnEscapePressed", close)
    e:SetScript("OnEnterPressed", function()
        local row = p.rows[p.sel or 1]
        if row and row:IsShown() then open(row) end
    end)
    e:SetScript("OnArrowPressed", function(_, key)
        if key == "UP" then choose((p.sel or 1) - 1) elseif key == "DOWN" then choose((p.sel or 0) + 1) end
    end)
    e:SetScript("OnTabPressed", function()
        choose((p.sel or 0) + (IsShiftKeyDown() and -1 or 1))
    end)
    p.edit = e

    -- results
    p.rows = {}
    for i = 1, MAX_ROWS do
        local r = CreateFrame("Button", nil, p)
        r:SetSize(PANEL_W - 24, ROW_H - 2)
        r:SetPoint("TOPLEFT", 12, -44 - (i - 1) * ROW_H)
        r.hl = UI.Fill(r, { 0.91, 0.76, 0.42 }, "BACKGROUND", 0, 0.10)
        r.hl:SetAllPoints()
        r.hl:Hide()
        -- the chosen row: a warmer band with a gold mark at its start
        r.sel = CreateFrame("Frame", nil, r)
        r.sel:SetAllPoints()
        UI.Fill(r.sel, { 0.91, 0.76, 0.42 }, "BACKGROUND", 1, 0.16):SetAllPoints()
        local mark = UI.Fill(r.sel, c.gold, "ARTWORK", 0, 0.9)
        mark:SetPoint("TOPLEFT", -6, 0)
        mark:SetPoint("BOTTOMLEFT", -6, 0)
        mark:SetWidth(2)
        r.sel:Hide()
        r.icon = r:CreateTexture(nil, "ARTWORK")
        r.icon:SetSize(18, 18)
        r.icon:SetPoint("LEFT", 2, 0)
        r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        r.kind = UI.Text(r, 8, c.inkFaint, "RIGHT", UI.FONT)
        r.kind:SetPoint("RIGHT", -4, 0)
        r.kind:SetWidth(84)
        r.text = UI.Text(r, 12, c.ink, "LEFT", UI.FONT, true)
        r.text:SetPoint("LEFT", 26, 0)
        r.text:SetPoint("RIGHT", r.kind, "LEFT", -6, 0)
        r.text:SetWordWrap(false)
        r:SetScript("OnEnter", function(s) s.hl:Show() choose(i) end)
        r:SetScript("OnLeave", function(s) s.hl:Hide() end)
        r:SetScript("OnClick", open)
        r:Hide()
        p.rows[i] = r
    end
    p.none = UI.Text(p, 12, c.inkFaint, "CENTER", UI.FONT)
    p.none:SetPoint("TOP", 0, -48)
    p.none:SetText(L["Nothing found."])
    p.none:Hide()
    p.more = UI.Text(p, 9, c.inkFaint, "CENTER", UI.FONT)
    p.more:SetPoint("BOTTOM", 0, 10)
    p.more:Hide()
    p:SetScript("OnHide", function() e:ClearFocus() end)
    p:Hide()
    return p
end

function UI:ToggleSearch()
    local bf = self.bookFrame
    if not bf then return end
    panel = panel or build(bf)
    UI.searchPanel = panel
    if panel:IsShown() then
        close()
    else
        index = nil
        panel:Show()
        panel.edit:SetText("")
        showResults()
        panel.edit:SetFocus()
    end
end

-- the spyglass at the top of the spine
local function addButton()
    local bf = UI.bookFrame
    if not bf or UI.searchButton then return end
    local b = CreateFrame("Button", nil, bf)
    b:SetSize(28, 28)
    b:SetPoint("TOP", bf, "TOP", 0, -4)
    b:SetFrameLevel(bf:GetFrameLevel() + 30)
    local ring = UI.Circle(b, 28, { 0.10, 0.05, 0.02, 1 }, "BACKGROUND", 0)
    ring:SetPoint("CENTER")
    local rim = UI.Circle(b, 26, c.goldDk, "BORDER", 0)
    rim:SetPoint("CENTER")
    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetPoint("CENTER")
    icon:SetTexture(UI.Icon("search"))
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    UI.Round(icon, b)
    b:SetScript("OnClick", function() UI:ToggleSearch() end)
    b:SetScript("OnEnter", function(s)
        rim:SetVertexColor(col4(c.gold))
        GameTooltip:SetOwner(s, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["Search the diary"], 1, 0.86, 0.5)
        GameTooltip:AddLine(L["Days, people, creatures, quests and places."], 0.9, 0.9, 0.9, true)
        GameTooltip:AddLine(L["Ctrl + F"], 0.5, 0.8, 1)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function()
        rim:SetVertexColor(col4(c.goldDk))
        GameTooltip:Hide()
    end)
    UI.searchButton = b
end

local build0 = UI.Build
function UI:Build()
    build0(self)
    addButton()
end
