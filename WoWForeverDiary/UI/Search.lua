-- Searching the diary: the field in the head bar of the travel desk finds days, people, creatures, quests,
-- places, honours and parts. A click opens the view (or the card).
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local max, min, format = math.max, math.min, string.format

local PANEL_W, ROW_H, MAX_ROWS = 380, 24, 12

-- lower case, including the common accented capitals (string.lower only knows A-Z)
local UPPER = {
    ["Ä"] = "ä", ["Ö"] = "ö", ["Ü"] = "ü", ["É"] = "é", ["È"] = "è", ["À"] = "à", ["Ç"] = "ç", ["Ñ"] = "ñ",
    ["Á"] = "á", ["Í"] = "í", ["Ó"] = "ó", ["Ú"] = "ú", ["Ê"] = "ê", ["Ô"] = "ô", ["Â"] = "â", ["Õ"] = "õ", ["Ã"] = "ã",
}
local function lower(s)
    s = (s or ""):lower()
    for k, v in pairs(UPPER) do s = s:gsub(k, v) end
    -- Cyrillic capitals: А-П (D0 90-9F) -> а-п (D0 B0-BF), Р-Я (D0 A0-AF) -> р-я (D1 80-8F), Ё -> ё
    s = s:gsub("\208([\144-\175])", function(ch)
        local b = ch:byte()
        if b < 160 then return "\208" .. string.char(b + 32) end
        return "\209" .. string.char(b - 32)
    end):gsub("\208\129", "\209\145")
    return s
end

------------------------------------------------------------------------
-- The index, built when the panel opens (and again after the book changed)
------------------------------------------------------------------------
local index, indexAt

local function buildIndex()
    local C = WFD.C
    local out = {}
    local function add(kind, text, icon, go, hay, rank)
        if not text or text == "" then return end
        out[#out + 1] = { kind = kind, text = text, icon = icon, go = go, hay = lower(hay or text), rank = rank or 5 }
    end
    -- the card beside its album or register on the travel desk
    local VIEW_OF = { creature = "bestiary", catch = "fishbook", person = "people" }
    local function toCard(kind, key)
        return function() UI:OpenShell({ view = VIEW_OF[kind], key = key }) end
    end
    local function toView(view) return function() UI:OpenShell({ view = view }) end end
    -- the parts of the travel desk
    for _, g in ipairs(UI.NAV or {}) do
        for _, key in ipairs(UI.PartsOf(g)) do
            if UI.PART_VIEW and UI.PART_VIEW[key] then
                add("part", UI.PartLabel(key), UI.Icon(g.icon or "journal"), function() UI:OpenShell(UI.PartRoute(key)) end, nil, 1)
            end
        end
    end
    -- regions and the places within them: their map page, else the day you first came there
    local placed = {}
    local function dayOf(t) return t and WFD:DayIndex(t) end
    local function toDay(d) return d and UI.DayGo(d) end
    for name, z in pairs(C.zones or {}) do
        if not placed[name] then
            placed[name] = true
            -- the map of a region is kept beside the regions (C.zoneMaps), not in its record
            local map = C.zoneMaps and C.zoneMaps[name]
            add("place", name, UI.Icon("map"), type(map) == "number" and function() UI:OpenShell({ view = "world", map = map }) end
                or toDay(z.day or dayOf(z.first)), nil, 4)
        end
        for sub, t in pairs(z.sub or {}) do
            if not placed[sub] then
                placed[sub] = true
                add("place", sub, UI.Icon("sight"), toDay(dayOf(type(t) == "number" and t or nil)), sub .. " " .. name, 5)
            end
        end
    end
    for key, n in pairs(C.npcs or {}) do
        if n.name then add("person", n.name, UI.Icon("people"), toCard("person", key), nil, 2) end
    end
    for id, m in pairs(C.mobs or {}) do
        if m.name then add("creature", m.name, UI.Icon("bestiary"), toCard("creature", id), nil, 3) end
    end
    for id, e in pairs(C.catch or {}) do
        if e.name then add("catch", e.name, UI.FishIcon and UI.FishIcon(e, id) or UI.Icon("loot"), toCard("catch", id), nil, 3) end
    end
    -- a quest leads to the day it was done (or taken)
    for _, q in pairs(C.quests or {}) do
        if q.title then
            local t = q.done or q.acc
            local d = t and WFD:DayIndex(t)
            add("quest", q.title, UI.Icon("quests"), toDay(d) or toView("quests"), q.title .. " " .. (q.quote or ""), 3)
        end
    end
    -- treasures: every notable find, leading to the day it was first found
    local firstDay = {}
    for idx, d in pairs(C.days) do
        for id, e in pairs(d.loot or {}) do
            if (e.q or 1) >= 2 and e.link and (not firstDay[id] or idx < firstDay[id].day) then
                firstDay[id] = { day = idx, link = e.link }
            end
        end
    end
    for _, f in pairs(firstDay) do
        add("treasure", WFD:ItemName(f.link), WFD:ItemIcon(f.link) or UI.Icon("loot"),
            toDay(f.day) or toView("treasures"), nil, 4)
    end
    for _, h in ipairs(WFD.HONOURS or {}) do
        local tiers = C.honourTiers and C.honourTiers[h.key] or 0
        if not h.secret or tiers > 0 then
            add("honour", L[h.name], UI.IconPath(h.icon, "honour"), toView("honour"), nil, 4)
        end
    end
    -- every day: the told story and your own notes
    for d = 1, WFD:NumDays() do
        local p = UI.DayGo(d)
        if p and C.days[d] then
            local story = UI.storyCache[d] or WFD:Narrate(d)
            local own = C.dayNotes and C.dayNotes[d] or ""
            local zone = WFD:MainZone(C.days[d])
            out[#out + 1] = { kind = "day", day = d, text = format(L["Day %d"], d), full = story .. " " .. own,
                hay = lower(story .. " " .. own), icon = UI.Icon("journal"), go = p, rank = 6,
                zone = zone, zoneLow = zone and lower(zone) or "", level = WFD:LevelAt(WFD:DayTime(d) + 43000) }
        end
    end
    index, indexAt = out, time()
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

-- the words searched for, marked in a warm colour (lower case keeps the length of every letter)
local function mark(text, q)
    local s, e = lower(text):find(q, 1, true)
    if not s then return text end
    return text:sub(1, s - 1) .. "|cffffb347" .. text:sub(s, e) .. "|r" .. text:sub(e + 1)
end

-- Filters for days, typed into the field: z:Elwynn (the region), lv:20-30 or lv:25 (the level), d:30 (the last
-- 30 days); z:"Hillsbrad Foothills" for a name with spaces. Filters alone list the days that fit.
local function parseFilters(q)
    local f = {}
    q = q:gsub('z:"([^"]*)"', function(v) f.zone = v return "" end)
    q = q:gsub("z:(%S+)", function(v) f.zone = v return "" end)
    q = q:gsub("lv:(%d+)%-(%d+)", function(a, b) f.lo, f.hi = tonumber(a), tonumber(b) return "" end)
    q = q:gsub("lv:(%d+)", function(a) f.lo, f.hi = tonumber(a), tonumber(a) return "" end)
    q = q:gsub("d:(%d+)", function(a) f.last = tonumber(a) return "" end)
    if not (f.zone or f.lo or f.last) then return nil, q end
    return f, q:gsub("^%s+", ""):gsub("%s+$", "")
end

local function find(q, kind)
    q = lower(q):gsub("^%s+", ""):gsub("%s+$", "")
    local filters
    filters, q = parseFilters(q)
    if not filters and #q < 2 then return {} end
    if filters then kind = "day" end
    -- built again when it is older than half a minute (the diary grows while you play)
    if not index or not indexAt or time() - indexAt > 30 then buildIndex() end
    local hits = {}
    local today = WFD:NumDays()
    for _, e in ipairs(index) do
        if not kind or e.kind == kind then
            local ok, pos = true, 1
            if filters then
                if filters.zone and not (e.zoneLow or ""):find(filters.zone, 1, true) then ok = false end
                if filters.lo and not (e.level and e.level >= filters.lo and e.level <= filters.hi) then ok = false end
                if filters.last and not (e.day and e.day > today - filters.last) then ok = false end
                if ok and #q > 0 then pos = e.hay:find(q, 1, true) ok = pos ~= nil end
            else
                pos = e.hay:find(q, 1, true)
                ok = pos ~= nil
            end
            if ok then hits[#hits + 1] = { e = e, starts = (pos == 1) } end
        end
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
-- What the results are called
------------------------------------------------------------------------
local KIND_LABEL = {
    part = "Contents", person = "Acquaintance", creature = "Bestiary", quest = "Quest", place = "Maps",
    honour = "Honour", day = "Diary", treasure = "Treasures", catch = "Angler's log",
}

-- for the search field in the head bar of the travel desk: the same index, the same ranking, the same marks
UI.Search = {
    Find = function(q, kind) return find(q or "", kind) end,
    Snippet = snippet,
    Mark = mark,
    KindLabel = function(kind) return L[KIND_LABEL[kind] or "Diary"] end,
    Forget = function() index = nil end,
}
