-- The last parts of the old book on the travel desk: the landmarks, the waters and tackle, the library, the family
-- book, the time capsule and, for a hardcore character who fell, the page in memoriam.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

-- (labels are keys, translated when the view is built:
-- L["All"] L["Found"] L["Books"] L["Notes"] L["Plaques"] L["To read later"] L["Newest first"] L["A to Z"] L["By area"])

-- a part that only shows when it has something (the register asks)
UI.PART_ENABLED = UI.PART_ENABLED or {}

------------------------------------------------------------------------
-- Landmarks
------------------------------------------------------------------------
UI.CollectionView({
    key = "landmarks", label = "Landmarks", group = "world",
    chips = { { "all", "All" }, { "found", "Found" } },
    lead = function()
        local _, found, total = WFD:LandmarkState()
        if (found or 0) == 0 then return nil end
        return WFD:Count("I have found %d of %d landmarks.", found, total)
    end,
    summary = function()
        local _, found, total = WFD:LandmarkState()
        return { { found .. " / " .. total, L["Landmarks"] } }
    end,
    data = function(state)
        local groups = WFD:LandmarkState()
        local out = {}
        for _, g in ipairs(groups) do
            local items = {}
            for _, it in ipairs(g.items) do
                -- what is still waiting stays a secret: it is counted, not named
                if it.found and UI.ListMatches(state.q, it.name) then items[#items + 1] = it end
            end
            table.sort(items, function(a, b) return (a.t or 0) > (b.t or 0) end)
            if state.chip ~= "found" and g.found < g.total and (state.q or "") == "" then
                items[#items + 1] = { pending = g.total - g.found }
            end
            if #items > 0 then
                out[#out + 1] = { title = L[g.def.label], right = g.found .. " / " .. g.total, frac = g.found / max(1, g.total), items = items }
            end
        end
        return out
    end,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local it = item.entry
            if it.pending then
                row:Set({ icon = "Interface\\Icons\\INV_Misc_QuestionMark", ring = { 0.46, 0.39, 0.30 },
                    name = format(L["%d still to find"], it.pending), nameKey = "muted" })
                return
            end
            row:Set({ icon = UI.IconPath({ it.icon }, "sight"), ring = WFD.METALS and WFD.METALS[3].col or { 0.86, 0.62, 0.18 },
                name = it.name, sub = it.t and date(WFD.loc.date .. " %H:%M", it.t) or nil,
                right = it.day and format(L["Day %d"], it.day) or nil,
                go = function(button)
                    if button == "RightButton" then UI:OpenDay(it.day) return end
                    UI.SelectIn("landmarks", it.id)
                end })
        end,
    },
    -- the report of a landmark found: when, the moment it is kept as, and where on the map
    detail = function(rp, id)
        local found, group
        for _, g in ipairs((WFD:LandmarkState())) do
            for _, it in ipairs(g.items) do if it.id == id and it.found then found, group = it, g end end
        end
        if not found then return end
        rp:Kicker(L[group.def.label])
        rp:Title(found.name)
        rp:Icons({ { UI.IconPath({ found.icon }, "sight") } })
        rp:DayLink(found.day, found.t)
        for _, ev in ipairs(WFD.C.events or {}) do
            if ev.k == "landmark" and ev.landmark == id then
                if ev.gear and next(ev.gear) then rp:Picture(ev, 140) end
                if ev.map then
                    rp:Link(L["Show on the world map"], nil, function() UI.Router.Go({ view = "world", map = ev.map }) end)
                end
                break
            end
        end
    end,
    keyOf = function(it) return it.id end,
    empty = function()
        local _, _, total = WFD:LandmarkState()
        if total == 0 then return L["This game client knows none of the landmarks."] end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- Waters and tackle
------------------------------------------------------------------------
UI.PART_ENABLED.fishwaters = function()
    local C = WFD.C
    return C and (next(C.catchZone or {}) ~= nil or next(C.tackle or {}) ~= nil)
end

UI.ReportView({
    key = "fishwaters", label = "Waters and tackle", group = "hunt",
    fill = function(rp)
        local C = WFD.C
        rp:Kicker(L["Angler's log"])
        rp:Title(L["Waters and tackle"], "display")
        rp:Text(L["Where it bites, and what I fished with"], "soft", "small", 12)
        rp:Tiles({ { C.catchCasts or 0, L["Casts in all"] }, { C.catchLured or 0, L["Casts with a lure"] } }, 2)
        local waters = {}
        for map, z in pairs(C.catchZone or {}) do
            if (z.casts or 0) > 0 then waters[#waters + 1] = { map = map, z = z } end
        end
        table.sort(waters, function(a, b) return a.z.casts > b.z.casts end)
        rp:Head(L["Waters"], tostring(#waters))
        if #waters == 0 then rp:Text(L["Nothing has bitten yet."], "soft", "body") end
        for i, w in ipairs(waters) do
            local rate = min(1, (w.z.loot or 0) / max(1, w.z.casts))
            local map = w.map
            rp:Line({ name = WFD:MapName(map) or "?", num = i, col = { 0.34, 0.58, 0.86 },
                right = WFD:Count("%d caught in %d casts", w.z.loot or 0, w.z.casts), frac = rate,
                go = function() R.Go({ view = "world", map = map }) end,
                tip = { WFD:MapName(map) or "?", L["Show on the world map"] } })
        end
        rp:Gap(10)
        local rods = {}
        for id, r in pairs(C.tackle or {}) do rods[#rods + 1] = { id = id, r = r } end
        table.sort(rods, function(a, b) return (a.r.n or 0) > (b.r.n or 0) end)
        rp:Head(L["Tackle"], tostring(#rods))
        if #rods == 0 then rp:Text(L["No fishing pole seen yet."], "soft", "body") end
        for _, e in ipairs(rods) do
            local icon, label = UI.TackleLook(e.id, e.r)
            rp:Line({ name = e.r.name or "?", icon = icon, col = { 0.55, 0.45, 0.30 }, sub = label,
                right = WFD:Count("%d casts", e.r.n or 0), link = e.r.link })
        end
    end,
})

------------------------------------------------------------------------
-- The library
------------------------------------------------------------------------
local LEATHER = {
    { 0.45, 0.18, 0.12 }, { 0.16, 0.30, 0.22 }, { 0.20, 0.24, 0.42 }, { 0.42, 0.30, 0.12 }, { 0.34, 0.14, 0.30 },
    { 0.50, 0.38, 0.20 },
}
local function spine(id, b)
    if b.kind == "plaque" then return { 0.46, 0.46, 0.48 } end
    if b.kind == "note" then return { 0.78, 0.68, 0.46 } end
    local h = 0
    for i = 1, #id do h = (h * 31 + id:byte(i)) % 9973 end
    return LEATHER[h % #LEATHER + 1]
end
local function kindWord(b)
    if b.kind == "plaque" then return L["Plaque"] end
    if b.kind == "note" then return L["Note"] end
    return L["Book"]
end

UI.CollectionView({
    key = "library", label = "Library", group = "keep",
    chips = { { "all", "All" }, { "book", "Books" }, { "note", "Notes" }, { "plaque", "Plaques" }, { "later", "To read later" } },
    sorts = { { "new", "Newest first" }, { "name", "A to Z" }, { "zone", "By area" } },
    lead = function()
        local n = #WFD:Library()
        if n == 0 then return nil end
        return WFD:Count("%d {book, note or plaque stands|books, notes and plaques stand} on my shelf.", n)
    end,
    summary = function()
        local list = WFD:Library()
        local later = 0
        for _, e in ipairs(list) do if e.b.later then later = later + 1 end end
        return { { #list, L["Library"] }, { later, L["To read later"] } }
    end,
    data = function(state)
        local list = {}
        for _, e in ipairs(WFD:Library()) do
            local kind = e.b.kind or "book"
            local ok = state.chip == "all" or (state.chip == "later" and e.b.later) or kind == state.chip
            if ok and UI.ListMatches(state.q, e.b.title, e.b.zone) then list[#list + 1] = e end
        end
        if state.sort == "name" then
            table.sort(list, function(a, b) return (a.b.title or "") < (b.b.title or "") end)
        elseif state.sort == "zone" then
            table.sort(list, function(a, b)
                if (a.b.zone or "") ~= (b.b.zone or "") then return (a.b.zone or "") < (b.b.zone or "") end
                return (a.b.title or "") < (b.b.title or "")
            end)
            return UI.ListGroupBy(list, function(e) return e.b.zone or L["Other"] end)
        else
            table.sort(list, function(a, b) return (a.b.t or 0) > (b.b.t or 0) end)
        end
        return { { items = list } }
    end,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local e = item.entry
            local b = e.b
            local missing = not WFD:BookComplete(b)
            row:Set({ icon = UI.Icon("journal"), ring = spine(e.id, b), name = b.title or "?",
                sub = kindWord(b) .. (b.zone and ("  -  " .. b.zone) or "") .. (b.t and ("  -  " .. date(WFD.loc.date, b.t)) or ""),
                right = b.later and L["To read later"] or nil, right2 = missing and L["Pages are missing"] or nil,
                go = function() UI.SelectIn("library", e.id) end })
        end,
    },
    detail = function(rp, id) UI.BookReport(rp, id) end,          -- (Cards.lua)
    keyOf = function(e) return e.id end,
    empty = function()
        if #WFD:Library() == 0 then return L["The shelf is empty. Every book, note and plaque I read will stand here."] end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- The family book
------------------------------------------------------------------------
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

UI.ReportView({
    key = "family", label = "Family book", group = "keep",
    fill = function(rp)
        if WFD.UpdateFamily then WFD.UpdateFamily() end
        local fam = WFD:Family()
        rp:Kicker(L["Keepsakes"])
        rp:Title(L["Family book"], "display")
        rp:Text(WFD:Count("%d characters on this account", #fam), "soft", "small", 12)
        for _, f in ipairs(fam) do
            local e = f.e
            local path, coords = UI.ClassCrest(e.classFile)
            local col = UI.ClassColor(e.classFile)
            local bits = { (((e.race or "") .. " " .. (e.class or "")):gsub("^%s+", "")) }
            if e.realm then bits[#bits + 1] = e.realm end
            local title = e.titleKey and WFD:HonourDef(e.titleKey)
            if title then bits[#bits + 1] = L[title.name] end
            if e.dead then bits[#bits + 1] = L["In memoriam"]
            elseif not f.me and e.last then bits[#bits + 1] = format(L["Last seen %s"], date(WFD.loc.date, e.last)) end
            rp:Line({ name = (e.name or "?") .. (f.me and ("  (" .. L["me"] .. ")") or ""), nameKey = e.dead and "muted" or "ink",
                icon = path, coords = coords, col = e.dead and { 0.46, 0.39, 0.30 } or { col[1], col[2], col[3] },
                sub = table.concat(bits, "  -  "), wrap = true, right = format(L["Level %d"], e.level or 0),
                tip = { e.name or "?",
                    WFD:Count("%d days of life, %d creatures slain, %d quests completed", e.days or 0, e.kills or 0, e.quests or 0),
                    L["Deaths"] .. ": " .. (e.deaths or 0) .. "   " .. L["On foot"] .. ": " .. WFD:Dec(e.km or 0) .. " km",
                    L["Time online"] .. ": " .. WFD:DurationText(e.online or 0), format(L["%d honour points"], e.points or 0) } })
        end
        if #fam < 2 then
            rp:Gap(6)
            rp:Text(L["Once I log in with my other characters, they will appear here."], "soft", "body")
            return
        end
        -- who got there first, by calendar day
        local races = {}
        for _, r in ipairs(RACES) do
            local best
            for _, f in ipairs(fam) do
                local d = r.level and f.e.levels and f.e.levels[r.level] or (r.first and f.e.firsts and f.e.firsts[r.first])
                if d and (not best or d < best.day) then best = { name = f.e.name, day = d } end
            end
            if best then races[#races + 1] = { r = r, best = best } end
        end
        if #races > 0 then
            rp:Head(L["Who got there first?"])
            for _, x in ipairs(races) do
                rp:Line({ name = raceLabel(x.r), right = x.best.name .. "  -  " .. format(L["Day %d"], x.best.day) })
            end
        end
        -- the quickest to every tenth level, by time in the world
        local pace = {}
        for _, r in ipairs(RACES) do
            if r.level then
                local best, mine, n = nil, nil, 0
                for _, f in ipairs(fam) do
                    local secs = f.e.pace and f.e.pace[r.level]
                    if secs then
                        n = n + 1
                        if f.me then mine = secs end
                        if not best or secs < best.secs then best = { name = f.e.name, secs = secs } end
                    end
                end
                if best and n >= 2 then pace[#pace + 1] = { r = r, best = best, mine = mine } end
            end
        end
        if #pace > 0 then
            rp:Head(L["Quickest to the level"])
            for _, x in ipairs(pace) do
                rp:Line({ name = raceLabel(x.r), right = x.best.name .. "  -  " .. WFD:DurationText(x.best.secs),
                    sub = (x.mine and x.mine > x.best.secs) and (L["me"] .. ": " .. WFD:DurationText(x.mine)) or nil })
            end
        end
        -- the hall of fame: the highest tiers earned anywhere in the family
        local best = {}
        for _, f in ipairs(fam) do
            for key, tier in pairs(f.e.honours or {}) do
                if WFD:HonourDef(key) and (not best[key] or tier > best[key].tier) then best[key] = { key = key, tier = tier, who = f.e.name } end
            end
        end
        local top = {}
        for _, b in pairs(best) do top[#top + 1] = b end
        table.sort(top, function(a, b) if a.tier ~= b.tier then return a.tier > b.tier end return a.key < b.key end)
        if #top > 0 then
            rp:Head(L["Hall of fame"])
            for i = 1, min(10, #top) do
                local h = WFD:HonourDef(top[i].key)
                local metal = WFD:MetalOf(top[i].tier, #h.tiers)
                rp:Line({ name = L[h.name], sub = L[metal.name] .. "  -  " .. (top[i].who or "?"), icon = UI.IconPath(h.icon, "honour"),
                    col = { metal.col[1], metal.col[2], metal.col[3] } })
            end
        end
    end,
})

------------------------------------------------------------------------
-- The time capsule
------------------------------------------------------------------------
local function refreshCapsule()
    local v = UI.ViewInstance("capsule")
    if v then v:Refresh() end
end

local function writeLetter()
    local C = WFD.C
    UI:Ask({
        title = L["Time capsule"], text = L["Dear me, when you read this ..."], ok = L["Save"],
        input = { value = C.capsuleDraft or "", lines = 8, max = 2000 },
        onOk = function(text)
            C.capsuleDraft = (text and text:find("%S")) and text or nil
            refreshCapsule()
        end,
    })
end

local function seal(kind, value)
    local C = WFD.C
    if not (C.capsuleDraft and C.capsuleDraft:find("%S")) then writeLetter() return end
    if WFD:SealLetter(C.capsuleDraft, kind, value) then
        UI.Sound("IG_QUEST_LIST_COMPLETE", 878)
        refreshCapsule()
    end
end

UI.ReportView({
    key = "capsule", label = "Time capsule", group = "keep",
    fill = function(rp)
        local C = WFD.C
        rp:Kicker(L["Keepsakes"])
        rp:Title(L["Time capsule"], "display")
        rp:Text(L["Letters to my future self"], "soft", "small", 12)
        -- the letter being written
        rp:Head(L["Dear me, when you read this ..."])
        local draft = C.capsuleDraft
        if draft and draft:find("%S") then
            rp:Paragraph(draft, "soft", false, true)
            rp:Button(L["Change the letter"], writeLetter, "ghost")
            rp:Kicker(L["Seal the letter and open it ..."])
            rp:Button(L["in a week"], function() seal("days", 7) end, "primary")
            rp:Button(L["in a month"], function() seal("days", 30) end, "primary")
            local lvl, cap = UnitLevel("player") or 1, (GetMaxPlayerLevel and GetMaxPlayerLevel()) or 60
            if lvl < cap then
                local goal = min(cap, (floor(lvl / 10) + 1) * 10)
                rp:Button(format(L["at level %d"], goal), function() seal("level", goal) end, "primary")
            end
            rp:Text(L["Until then the letter stays sealed. Not even I can read it."], "muted", "small")
        else
            rp:Button(L["Write a letter"], writeLetter, "primary")
        end
        rp:Gap(8)
        -- the letters: sealed ones first (soonest to open on top), then the opened ones, newest first
        local letters = {}
        for i, l in ipairs(C.capsules or {}) do letters[#letters + 1] = { l = l, i = i } end
        table.sort(letters, function(a, b)
            local ao, bo = a.l.opened ~= nil, b.l.opened ~= nil
            if ao ~= bo then return not ao end
            if ao then return a.l.opened > b.l.opened end
            return a.i < b.i
        end)
        rp:Head(L["Letters to my future self"], tostring(#letters))
        if #letters == 0 then rp:Text(L["No letters yet."], "soft", "body") end
        for _, e in ipairs(letters) do
            local l = e.l
            local open = l.opened ~= nil
            local sub
            if open then
                sub = format(L["Opened on %s"], date(WFD.loc.date, l.opened))
            elseif l.openDay then
                local left = l.openDay - WFD:DayIndex()
                sub = format(L["Sealed, opens on day %d"], l.openDay) .. (left > 0 and ("  (" .. WFD:Count("in %d days", left) .. ")") or "")
            else
                sub = format(L["Sealed, opens at level %d"], l.openLevel or 0)
            end
            rp:Line({ name = format(L["Written on day %d, at level %d"], l.day or 0, l.level or 0), wrap = true, sub = sub,
                subKey = open and "muted" or "neg", icon = UI.Icon("capsule"),
                col = open and { 0.86, 0.62, 0.18 } or { 0.55, 0.12, 0.10 }, go = UI.DayGo(l.day) })
            if open then rp:Paragraph(l.text or "", "soft", false, true) end
        end
    end,
})

------------------------------------------------------------------------
-- In memoriam
------------------------------------------------------------------------
UI.PART_ENABLED.memoriam = function() return WFD.C and WFD.C.obituary ~= nil end

UI.ReportView({
    key = "memoriam", label = "In memoriam", group = "diary", width = 640,
    fill = function(rp)
        local C = WFD.C
        local o = C.obituary
        rp:Gap(10)
        rp:Kicker(L["In memoriam"], "muted")
        if not o then
            rp:Text(L["Nobody has defeated me yet. Long may it last!"], "soft", "body")
            return
        end
        rp:Title(C.name or "?", "display")
        rp:Text(UI.Upper((C.race or "") .. "  -  " .. (C.class or "") .. "  -  " .. format(L["Level %d"], o.level or 0)), "soft", "small", 4)
        rp:Text(date(WFD.loc.date, C.born) .. "  -  " .. date(WFD.loc.date, o.t), "ink", "body", 12)
        local killerId
        if o.by then for id, m in pairs(C.mobs or {}) do if m.name == o.by then killerId = id break end end end
        rp:Picture({ npc = killerId, gear = o.gear, s = o.by and format(L["Killed by %s"], o.by) or L["The last moment"] }, 150)
        rp:Text(format(L["Fell in %s"], (o.sub and o.sub ~= "" and (o.sub .. ", ") or "") .. (o.zone or "?"))
            .. (o.by and ("\n" .. format(L["Slain by %s"], o.by)) or ""), "ink", "body", 10)
        local tt = WFD:Totals()
        rp:Text(WFD:Count("%d days of life, %d creatures slain, %d quests completed", tt.days, tt.kills, tt.quests), "soft", "body", 14)
        rp:Paragraph(L["\"Here the journey ends, but not the story.\""], "muted")
        rp:Flourish()
        local last = o.t and WFD:DayIndex(o.t)
        if UI.DayGo(last) then rp:Button(L["Click to read this day."], UI.DayGo(last), "ghost") end
    end,
})
