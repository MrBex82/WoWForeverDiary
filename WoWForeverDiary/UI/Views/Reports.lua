-- Reports on the travel desk: the dungeon runs, and fate (every death, the nemeses among them). A list on the
-- left, the report of the line chosen in the column on the right - every member of the group, every boss,
-- every piece of loot, nothing cut off.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local R = UI.Router
local floor, max, format = math.floor, math.max, string.format

-- (labels are keys, translated when the view is built:
-- L["All"] L["Nobody fell"] L["With fallen"] L["Newest first"] L["By dungeon"] L["Fastest first"] L["Most kills"]
-- L["Every death"] L["Nemeses"] L["By area"] L["By foe"] L["By level"])

local function view(key) return UI.ViewInstance(key) end
local function mobByName(name)
    if not name then return nil end
    for id, m in pairs(WFD.C.mobs or {}) do
        if m.name == name then return id, m end
    end
end
local function select(key, id) local v = view(key) if v then v:Select(id) end end
-- the key of a companion by the name in a group (with or without the realm)
local function companionKey(name)
    local list = WFD.C.companions or {}
    if not name then return nil end
    if list[name] then return name end
    for key, e in pairs(list) do if e.name == name then return key end end
end

-- the colour of an item link (its quality)
local function linkColour(link)
    local hex = link and link:match("|cff(%x%x%x%x%x%x)")
    if hex then
        return { tonumber(hex:sub(1, 2), 16) / 255, tonumber(hex:sub(3, 4), 16) / 255, tonumber(hex:sub(5, 6), 16) / 255 }
    end
    local qc = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[WFD:ItemQuality(link)]
    if qc and qc.r then return { qc.r, qc.g, qc.b } end
    return { 0.2, 0.7, 0.2 }
end

------------------------------------------------------------------------
-- Dungeon reports
------------------------------------------------------------------------
UI.PART_VIEW.runs = "runs"

-- how long a run lasted: until its end, the one in progress until now, one left open until it was last seen
local function runDur(r)
    if r.t1 then return r.t1 - (r.t0 or r.t1) end
    if WFD.CurrentRun and WFD:CurrentRun() == r then return time() - (r.t0 or time()) end
    return (r.seen or r.t0 or 0) - (r.t0 or 0)
end

local function runData(state)
    local list = {}
    for i, r in ipairs(WFD.C.runs or {}) do
        local fallen = #(r.deaths or {}) > 0
        local chip = state.chip
        local ok = chip == "all" or (chip == "fallen" and fallen) or (chip == "clean" and not fallen)
        if ok and UI.ListMatches(state.q, r.name, table.concat(r.bosses or {}, " ")) then
            list[#list + 1] = { i = i, r = r }
        end
    end
    local sort = state.sort
    if sort == "name" then
        table.sort(list, function(a, b)
            if (a.r.name or "") ~= (b.r.name or "") then return (a.r.name or "") < (b.r.name or "") end
            return (a.r.t0 or 0) > (b.r.t0 or 0)
        end)
        return UI.ListGroupBy(list, function(e) return e.r.name end)
    elseif sort == "fast" then
        table.sort(list, function(a, b) return runDur(a.r) < runDur(b.r) end)
    elseif sort == "kills" then
        table.sort(list, function(a, b) return (a.r.kills or 0) > (b.r.kills or 0) end)
    else
        table.sort(list, function(a, b) return (a.r.t0 or 0) > (b.r.t0 or 0) end)
    end
    return { { items = list } }
end

-- the report of one run
local function runReport(rp, key)
    local C = WFD.C
    local r = C.runs and C.runs[key]
    if not r then return end
    local dur = runDur(r)
    rp:Title(r.name or "?")
    local go = UI.DayGo(r.day)
    rp:Line({ name = format(L["Day %d"], r.day or 1) .. "  -  " .. date(WFD.loc.date, r.t0 or time()),
        sub = r.level and format(L["Level %d"], r.level) or nil, mark = go and "right" or nil, markKey = "white",
        col = go and { 0.55, 0.40, 0.16 } or nil, go = go, tip = go and { L["Dungeon reports"], L["Click to read this day."] } or nil })
    rp:Gap(6)
    rp:Tiles({
        { WFD:DurationText(dur), L["Duration"] },
        { r.kills or 0, L["Kills"] },
        { #(r.bosses or {}), L["Bosses"] },
        { #(r.deaths or {}), L["Fallen"], nil, #(r.deaths or {}) > 0 and "neg" or nil },
    })

    -- the final boss, painted
    if r.last and r.last.gear and next(r.last.gear) then
        rp:Picture({ npc = r.last.npc, gear = r.last.gear, s = r.last.name }, 120)
    end

    -- the whole group, however large
    local people = { { name = C.name or UnitName("player"), classFile = C.classFile, class = C.class, level = r.level, me = true } }
    local names = {}
    for name in pairs(r.party or {}) do names[#names + 1] = name end
    table.sort(names)
    for _, name in ipairs(names) do
        local p = r.party[name]
        people[#people + 1] = { name = name, classFile = p.classFile, class = p.class, level = p.level }
    end
    rp:Head(L["The group"], tostring(#people))
    for _, p in ipairs(people) do
        local path, coords = UI.ClassCrest(p.classFile)
        local col = UI.ClassColor(p.classFile)
        local bits = {}
        if p.level then bits[#bits + 1] = format(L["Level %d"], p.level) end
        if p.class then bits[#bits + 1] = p.class end
        -- a fellow adventurer leads to their place among the companions
        local ckey = not p.me and companionKey(p.name)
        rp:Line({ name = p.me and (L["Me"] .. "  -  " .. (p.name or "")) or p.name, icon = path, coords = coords,
            col = { col[1], col[2], col[3] }, sub = #bits > 0 and table.concat(bits, "  -  ") or nil,
            go = ckey and function() R.Go({ view = "companions", key = ckey }) end or nil,
            tip = ckey and { p.name, { L["Click: the report."], 0.5, 0.8, 1 } } or nil })
    end
    rp:Gap(8)

    -- the bosses, in the order they fell, each leading to its wanted poster
    rp:Head(L["Bosses"], tostring(#(r.bosses or {})))
    if #(r.bosses or {}) == 0 then rp:Text(L["No boss fell this time."], "muted", "body") end
    for _, b in ipairs(r.bosses or {}) do
        local id = mobByName(b)
        if id then
            rp:Link(b, nil, function() R.Go({ view = "bestiary", key = id }) end, L["Click for the wanted poster."], UI.Icon("bestiary"))
        else
            rp:Bullets({ b })
        end
    end
    rp:Gap(8)

    -- the loot
    rp:Head(L["Loot"], tostring(#(r.loot or {})))
    local icons = {}
    for _, link in ipairs(r.loot or {}) do
        icons[#icons + 1] = { WFD:ItemIcon(link) or UI.Icon("loot"), linkColour(link), link }
    end
    if #icons == 0 then rp:Text(L["Nothing worth keeping this time."], "muted", "body") else rp:Icons(icons) end
    rp:Gap(8)

    -- who fell
    rp:Head(L["Fallen"], tostring(#(r.deaths or {})))
    if #(r.deaths or {}) == 0 then rp:Text(L["Nobody fell."], "soft", "body") end
    for _, d in ipairs(r.deaths or {}) do
        local id = d.by and mobByName(d.by)
        rp:Line({ name = d.me and L["Me"] or (d.who or "?"), nameKey = "neg", col = { 0.62, 0.06, 0.04 }, icon = UI.Icon("skull"),
            sub = d.by and format(L["Killed by %s"], d.by) or nil,
            go = id and function() R.Go({ view = "bestiary", key = id }) end or nil,
            tip = id and { d.by, { L["Click for the wanted poster."], 0.5, 0.8, 1 } } or nil })
    end
end

UI.CollectionView({
    key = "runs", label = "Dungeon reports", group = "world",
    chips = { { "all", "All" }, { "clean", "Nobody fell" }, { "fallen", "With fallen" } },
    sorts = { { "new", "Newest first" }, { "name", "By dungeon" }, { "fast", "Fastest first" }, { "kills", "Most kills" } },
    summary = function()
        local runs = WFD.C.runs or {}
        local dungeons, bosses, secs = {}, 0, 0
        local nd = 0
        for _, r in ipairs(runs) do
            if r.name and not dungeons[r.name] then dungeons[r.name] = true nd = nd + 1 end
            bosses = bosses + #(r.bosses or {})
            secs = secs + runDur(r)
        end
        return { { #runs, L["Dungeon reports"] }, { nd, L["Dungeons"] }, { bosses, L["Bosses"] },
            { WFD:DurationText(secs), L["Time spent"] } }
    end,
    data = runData,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local e = item.entry
            local r = e.r
            local fallen = #(r.deaths or {})
            row:Set({
                icon = UI.Icon("runs"),
                ring = #(r.bosses or {}) > 0 and { 0.93, 0.73, 0.22 } or { 0.55, 0.42, 0.24 },
                name = r.name or "?",
                sub = format(L["Day %d"], r.day or 1) .. "  -  " .. WFD:Count("%d bosses", #(r.bosses or {}))
                    .. (fallen > 0 and ("  -  " .. WFD:Count("%d fallen", fallen)) or ""),
                right = WFD:DurationText(runDur(r)), right2 = r.level and format(L["Level %d"], r.level) or nil,
                go = function() select("runs", e.i) end,
            })
        end,
    },
    detail = runReport,
    keyOf = function(e) return e.i end,
    empty = function()
        if #(WFD.C.runs or {}) == 0 then return { icon = UI.Icon("runs"), title = L["No dungeon visited yet. The depths are waiting."], hint = L["Every visit to a dungeon gets its report: the group, the bosses, the loot, who fell."], button = { L["Landmarks"], UI.PartRoute("landmarks") } } end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- Fate: every death, and the nemeses
------------------------------------------------------------------------
UI.PART_VIEW.fates = "fates"
UI.PART_VIEW.nemesis = { view = "fates", chip = "nemesis" }

local function nemeses()
    local arr = {}
    for name, n in pairs(WFD.C.nemesis or {}) do arr[#arr + 1] = { name = name, n = n } end
    table.sort(arr, function(a, b)
        if (a.n.n or 0) ~= (b.n.n or 0) then return (a.n.n or 0) > (b.n.n or 0) end
        return a.name < b.name
    end)
    return arr
end

-- revenge taken: you slew them after they last slew you
local function revenge(e)
    local _, mob = mobByName(e.name)
    return mob and (mob.kills or 0) > 0 and mob.last and e.n.last and mob.last > e.n.last, mob
end

local function fateData(state)
    local fates = WFD:Fates()
    if state.chip == "nemesis" then
        local list = {}
        for _, e in ipairs(nemeses()) do
            if UI.ListMatches(state.q, e.name, e.n.zone) then list[#list + 1] = { nem = e } end
        end
        return { { items = list } }
    end
    local list = {}
    for i, f in ipairs(fates) do
        if UI.ListMatches(state.q, f.by, f.zone) then list[#list + 1] = { i = i, f = f } end
    end
    local sort = state.sort
    if sort == "zone" then
        table.sort(list, function(a, b)
            if (a.f.zone or "") ~= (b.f.zone or "") then return (a.f.zone or "") < (b.f.zone or "") end
            return a.i > b.i
        end)
        return UI.ListGroupBy(list, function(e) return e.f.zone or L["Other"] end)
    elseif sort == "foe" then
        table.sort(list, function(a, b)
            if (a.f.by or "~") ~= (b.f.by or "~") then return (a.f.by or "~") < (b.f.by or "~") end
            return a.i > b.i
        end)
        return UI.ListGroupBy(list, function(e) return e.f.by or L["Cause unknown"] end)
    elseif sort == "level" then
        table.sort(list, function(a, b)
            if (a.f.level or 0) ~= (b.f.level or 0) then return (a.f.level or 0) < (b.f.level or 0) end
            return a.i > b.i
        end)
        return UI.ListGroupBy(list, function(e)
            local band = floor((e.f.level or 1) / 10)
            return format(L["Level %d-%d"], max(1, band * 10), band * 10 + 9)
        end)
    end
    table.sort(list, function(a, b) return a.i > b.i end)
    return { { items = list } }
end

-- the report of a death, or of a nemesis
local function fateReport(rp, key)
    local C = WFD.C
    local nem = type(key) == "string" and key:match("^n:(.+)$")
    if nem then
        local e
        for _, x in ipairs(nemeses()) do if x.name == nem then e = x end end
        if not e then return end
        local took, mob = revenge(e)
        local id = mobByName(e.name)
        rp:Title(e.name)
        rp:Text(took and L["Revenge taken"] or L["Score unsettled"], took and "pos" or "neg", "strong", 10)
        local lastDay = e.n.last and WFD:DayIndex(e.n.last)
        rp:Tiles({
            { e.n.n or 0, L["Deaths"], nil, "neg" },
            { mob and mob.kills or 0, L["Kills"], id and function() R.Go({ view = "bestiary", key = id }) end },
            { e.n.zone or "-", L["Places of death"] },
            { lastDay and format(L["Day %d"], lastDay) or "-", L["Last death"], lastDay and UI.DayGo(lastDay) },
        })
        if id then
            rp:Line({ name = L["Click for the wanted poster."], mark = "right", markKey = "white", col = { 0.55, 0.40, 0.16 },
                go = function() R.Go({ view = "bestiary", key = id }) end })
        end
        -- every death they caused
        local mine = {}
        for i, f in ipairs(WFD:Fates()) do if f.by == e.name then mine[#mine + 1] = { i = i, f = f } end end
        rp:Head(L["Every death"], tostring(#mine))
        for j = #mine, 1, -1 do
            local f = mine[j].f
            local go = UI.DayGo(f.day)
            rp:Line({ name = (f.zone or "?"), sub = format(L["Day %d"], f.day or 1) .. (f.level and ("  -  " .. format(L["Level %d"], f.level)) or ""),
                icon = UI.Icon("skull"), col = { 0.62, 0.06, 0.04 }, go = go,
                tip = go and { f.zone or "?", L["Click to read this day."] } or nil })
        end
        return
    end
    local f = WFD:Fates()[key]
    if not f then return end
    rp:Title(f.by and format(L["Killed by %s"], f.by) or L["Cause unknown"])
    rp:Text(f.zone or "?", "soft", "small", 12)
    local go = UI.DayGo(f.day)
    local bits = {}
    if f.level then bits[#bits + 1] = format(L["Level %d"], f.level) end
    if f.group then bits[#bits + 1] = format(L["Group: %d"], f.group) end
    rp:Line({ name = format(L["Day %d"], f.day or 1) .. (f.t and ("  -  " .. date(WFD.loc.date, f.t) .. " " .. date("%H:%M", f.t)) or ""),
        sub = #bits > 0 and table.concat(bits, "  -  ") or nil, icon = UI.Icon("skull"), col = { 0.62, 0.06, 0.04 }, go = go,
        tip = go and { L["Fate"], L["Click to read this day."] } or nil })
    if f.map then
        local map = f.map
        rp:Line({ name = L["Show on the world map"], sub = f.zone, mark = "right", markKey = "white", col = { 0.40, 0.55, 0.30 },
            go = function() R.Go({ view = "world", map = map, layer = "graves" }) end })
    end
    if f.by then
        local id = mobByName(f.by)
        local n = C.nemesis and C.nemesis[f.by]
        if n then
            local nkey = "n:" .. f.by
            rp:Line({ name = f.by, sub = WFD:Count("Killed me %d times", n.n or 0), icon = UI.Icon("nemesis"),
                col = { 0.62, 0.06, 0.04 }, nameKey = "neg",
                go = function() R.Go({ view = "fates", chip = "nemesis", key = nkey }) end })
        elseif id then
            rp:Line({ name = f.by, sub = L["Click for the wanted poster."], icon = UI.Icon("bestiary"), col = { 0.62, 0.10, 0.06 },
                go = function() R.Go({ view = "bestiary", key = id }) end })
        end
    end
end

UI.CollectionView({
    key = "fates", label = "Fate", group = "hunt",
    chips = { { "deaths", "Every death" }, { "nemesis", "Nemeses" } },
    sorts = { { "new", "Newest first" }, { "zone", "By area" }, { "foe", "By foe" }, { "level", "By level" } },
    summary = function()
        local fates = WFD:Fates()
        local zones, nz = {}, 0
        for _, f in ipairs(fates) do
            if f.zone and not zones[f.zone] then zones[f.zone] = true nz = nz + 1 end
        end
        local top = nemeses()[1]
        local last = fates[#fates]
        return { { #fates, L["Deaths"] }, { nz, L["Places of death"] }, { top and top.name or "-", L["Nemesis number one"] },
            { last and format(L["Day %d"], last.day or 1) or "-", L["Last death"] } }
    end,
    data = fateData,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local e = item.entry
            if e.nem then
                local took = revenge(e.nem)
                local lastDay = e.nem.n.last and WFD:DayIndex(e.nem.n.last)
                local nkey = "n:" .. e.nem.name
                row:Set({
                    icon = UI.Icon("nemesis"), ring = { 0.75, 0.16, 0.10 },
                    name = e.nem.name, nameKey = "neg",
                    sub = WFD:Count("Killed me %d times", e.nem.n.n or 0) .. (e.nem.n.zone and ("  -  " .. e.nem.n.zone) or ""),
                    right = took and L["Revenge taken"] or L["Score unsettled"], right2 = lastDay and format(L["Day %d"], lastDay) or nil,
                    go = function() select("fates", nkey) end,
                })
                return
            end
            local f = e.f
            local bits = { f.zone or "?", format(L["Day %d"], f.day or 1) }
            if f.t then bits[#bits + 1] = date("%H:%M", f.t) end
            row:Set({
                icon = UI.Icon("skull"), ring = { 0.62, 0.06, 0.04 },
                name = f.by and format(L["Killed by %s"], f.by) or L["Cause unknown"], nameKey = f.by and "ink" or "soft",
                sub = table.concat(bits, "  -  "),
                right = f.level and format(L["Level %d"], f.level) or nil,
                go = function() select("fates", e.i) end,
            })
        end,
    },
    detail = fateReport,
    keyOf = function(e) if e.nem then return "n:" .. e.nem.name end return e.i end,
    empty = function(state)
        if state.chip == "nemesis" then
            if #WFD:Fates() > 0 then return L["I have died, but who did it slipped past the diary."] end
            return L["No nemesis yet: nobody has defeated me so far."]
        end
        if #WFD:Fates() == 0 then return L["Nobody has defeated me yet. Long may it last!"] end
        return L["Nothing matches this choice."]
    end,
})
