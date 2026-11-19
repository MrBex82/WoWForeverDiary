-- The world on the travel desk: one map for the whole journey instead of the atlas, the maps of the regions, the
-- gatherer's map and the hunting grounds. A continent shows every step and the regions explored; a region shows
-- the layers you choose (route, kill sites, people, graves, resting places, finds, creatures). Beside the map:
-- the regions of the continent, or the chronicle of the region shown.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

local PAD = 16
local SIDE_MIN, SIDE_MAX = 290, 400
local OTHER = "other"          -- the "continent" of the places that lie on none (dungeons, cities of their own)

-- the parts of the old book that are layers of this map now
UI.PART_VIEW.atlas = "world"
UI.PART_VIEW.maps = "world"
UI.PART_VIEW.gathering = { view = "world", layer = "finds" }
UI.PART_VIEW.huntgrounds = { view = "world", layer = "hunt" }
UI.VIEW_PLACE.world = { "world", "atlas" }
UI.PART_LABEL.atlas = "World map"

-- (labels are keys, translated when shown:
-- L["Route"] L["Kill sites"] L["People"] L["Graves"] L["Resting places"] L["Finds"] L["Creatures"])
local LAYERS = {
    { key = "route", label = "Route", col = { 0.62, 0.10, 0.06 }, on = true },
    { key = "kills", label = "Kill sites", col = { 0.30, 0.42, 0.86 }, on = true },
    { key = "people", label = "People", col = { 0.85, 0.60, 0.14 }, on = true },
    { key = "graves", label = "Graves", col = { 0.62, 0.06, 0.04 }, on = true },
    { key = "rests", label = "Resting places", col = { 1, 0.55, 0.15 }, on = false },
    { key = "finds", label = "Finds", col = { 0.36, 0.72, 0.30 }, on = false },
    { key = "hunt", label = "Creatures", col = { 0.97, 0.95, 0.90 }, on = false },
}

-- pin colours of the creatures: clear apart from each other and from the sepia map
local PIN_COL = {
    normal = { 0.97, 0.95, 0.90, 1 }, elite = { 1.00, 0.78, 0.20, 1 },
    rare = { 0.45, 0.70, 1.00, 1 }, boss = { 0.92, 0.22, 0.12, 1 },
}
local SIGHTED_COL = { 0.22, 0.13, 0.06, 1 }

local function layerOn(key)
    local S = WFD.S
    local saved = S and S.worldLayers and S.worldLayers[key]
    if saved ~= nil then return saved end
    for _, l in ipairs(LAYERS) do if l.key == key then return l.on end end
    return false
end
local function setLayer(key, on)
    local S = WFD.S
    if not S then return end
    S.worldLayers = S.worldLayers or {}
    S.worldLayers[key] = on
end

------------------------------------------------------------------------
-- What the diary knows about the regions
------------------------------------------------------------------------
-- time, kills and the first day per map, from the footsteps
local function regionStats()
    local C = WFD.C
    local t = {}
    for d, day in pairs(C.days or {}) do
        for mapID, p in pairs(day.path or {}) do
            local e = t[mapID] or { id = mapID, sec = 0, kills = 0, first = d }
            t[mapID] = e
            e.sec = e.sec + WFD:SumCells(p) * 2
            if d < e.first then e.first = d end
        end
        for mapID, kc in pairs(day.kcells or {}) do
            local e = t[mapID] or { id = mapID, sec = 0, kills = 0, first = d }
            t[mapID] = e
            e.kills = e.kills + WFD:SumCells(kc)
            if d < e.first then e.first = d end
        end
    end
    return t
end

local function mapType(id)
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(id)
    return info and info.mapType
end

-- the continents with their regions, and the places on none of them
local function worldState()
    local conts = WFD:AtlasState()
    local stats = regionStats()
    local contOf = {}
    for _, e in ipairs(conts) do
        for _, z in ipairs(e.zones) do contOf[z.id] = e.id end
    end
    local other = { id = OTHER, name = L["Other places"], zones = {}, visited = 0, total = 0, secs = 0 }
    for id, s in pairs(stats) do
        local mt = mapType(id)
        if not contOf[id] and not (mt and mt <= 2) then
            other.zones[#other.zones + 1] = { id = id, name = WFD:MapName(id), visited = true, day = s.first, secs = s.sec }
            other.secs = other.secs + s.sec
        end
    end
    table.sort(other.zones, function(a, b) return (a.day or 0) < (b.day or 0) end)
    other.visited, other.total = #other.zones, #other.zones
    for _, z in ipairs(other.zones) do contOf[z.id] = OTHER end
    return conts, other, stats, contOf
end

-- the continent (map ID) a map lies on, by walking up its parents
local function continentOf(id, contOf)
    if contOf[id] then return contOf[id] end
    local seen = 0
    while id and seen < 8 do
        seen = seen + 1
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(id)
        if not info then return nil end
        if info.mapType == 2 then return id end
        id = info.parentMapID
    end
end

local function hereMap()
    local ok, here = pcall(function() return C_Map.GetBestMapForUnit("player") end)
    return ok and here or nil
end

-- the chronicle of a region in figures
local function chronicle(id, stat)
    local C = WFD.C
    local name = WFD:MapName(id)
    local z = C.zones and C.zones[name]
    local deaths, quests, people, rests = 0, 0, 0, 0
    for _, r in ipairs(C.rests or {}) do if r.map == id then rests = rests + 1 end end
    for _, d in pairs(C.days or {}) do
        for _, pos in ipairs(d.dpos or {}) do if pos[1] == id then deaths = deaths + 1 end end
    end
    for _, q in pairs(C.quests or {}) do if q.done and q.zone == name then quests = quests + 1 end end
    for _, n in pairs(C.npcs or {}) do if n.map == id and not n.obj then people = people + 1 end end
    local mobs = {}
    for mid, m in pairs(C.mobs or {}) do
        if m.zone == name and (m.kills or 0) > 0 then mobs[#mobs + 1] = { id = mid, m = m } end
    end
    table.sort(mobs, function(a, b) return a.m.kills > b.m.kills end)
    -- every place of the region: the ones found first, then the ones still to find
    local subs, found = WFD:ZonePlaces(name, id)
    local finds, kinds = {}, {}
    for _, s in ipairs(C.gather and C.gather[id] or {}) do
        kinds[s.k] = (kinds[s.k] or 0) + 1
        if s.item then finds[s.item] = (finds[s.item] or 0) + 1 end
    end
    local top = {}
    for item, n in pairs(finds) do top[#top + 1] = { name = item, n = n } end
    table.sort(top, function(a, b) return a.n > b.n end)
    return {
        name = name, stat = stat, visits = z and z.visits, deaths = deaths, quests = quests, people = people,
        rests = rests, mobs = mobs, subs = subs, found = found, kinds = kinds, finds = top,
    }
end

local function kindOf(key)
    for _, k in ipairs(WFD.GATHER_KINDS or {}) do if k.key == key then return k end end
end
local function kindName(k) return WFD:SpellName(k.spell) or L[k.label] end

------------------------------------------------------------------------
-- The view
------------------------------------------------------------------------
UI:RegisterView({
    key = "world",
    build = function(outer)
        -- the open book: the map on the left page, the report of the continent or the region on the right page
        local book, host = K.BookHost(outer)
        local v = { mode = "cont", book = book }

        -- the bar above the map
        v.bar = CreateFrame("Frame", nil, host)
        v.contItems = {}
        v.cont = K.Dropdown(v.bar, v.contItems, function() return v.contID end, function(id)
            R.Go({ view = "world", cont = id })
        end, 210)
        v.up = K.Button(v.bar, "", "secondary", function()
            R.Go({ view = "world", cont = v.contID })
        end)
        v.up:AddArrow("left")
        v.replay = K.Button(v.bar, L["Watch the journey grow"], "secondary", function()
            if v.map then v.map:StartReplay() end
        end)
        K.Tip(v.replay, L["Watch the journey grow"], { L["Day by day, from the first step to today."] })
        v.chips = {}
        for _, l in ipairs(LAYERS) do
            local b = K.Button(v.bar, L[l.label], "secondary", function(self)
                setLayer(self.layer, not layerOn(self.layer))
                v:PaintChips()
                v:DrawMap()
            end)
            b.layer, b.minH, b.fixedW = l.key, 28, 1
            b.dot = UI.Circle(b, 9, { l.col[1], l.col[2], l.col[3], 1 }, "OVERLAY", 2)
            b.dot:SetPoint("LEFT", 11, 0)
            b.ring = UI.Circle(b, 11, { 0.08, 0.04, 0.02, 1 }, "OVERLAY", 1)
            b.ring:SetPoint("CENTER", b.dot, "CENTER")
            b.label:ClearAllPoints()
            b.label:SetPoint("LEFT", 26, 0)
            v.chips[#v.chips + 1] = b
        end

        -- the map in a dark mount
        v.mount = CreateFrame("Frame", nil, host)
        local mbg = UI.Fill(v.mount, { 0.08, 0.055, 0.035 }, "BACKGROUND", 0, 1)
        mbg:SetAllPoints()
        v.map = UI.MapSketch(v.mount, 600, 400)
        v.map:SetPoint("CENTER")
        v.map:SetFrameLevel(v.mount:GetFrameLevel() + 2)
        v.hint = K.Text(host, "small", "muted", "CENTER")
        v.hint:SetText(L["Mouse wheel: zoom, drag: move, right click: reset"])
        v.legend = CreateFrame("Frame", nil, host)
        v.legend:SetHeight(16)
        v.legend.items = {}
        -- (L["Route"] L["Flights"] L["Explored"] L["Not yet explored"])
        for i, it in ipairs({ { "Route", { 0.62, 0.10, 0.06 }, true }, { "Flights", { 0.62, 0.10, 0.06 }, true, 0.4, 6 },
            { "Explored", { 0.90, 0.66, 0.16 } }, { "Not yet explored", { 0.58, 0.52, 0.44 } } }) do
            local e = {}
            e.dot = it[3] and UI.Diamond(v.legend, it[5] or 8, { it[2][1], it[2][2], it[2][3], it[4] or 1 }, "ARTWORK", 1)
                or UI.Circle(v.legend, 10, { it[2][1], it[2][2], it[2][3], 1 }, "ARTWORK", 1)
            e.text = K.Text(v.legend, "small", "soft")
            e.text:SetText(L[it[1]])
            v.legend.items[i] = e
        end

        -- the column beside it: a card with the report of the continent or the region
        v.side = CreateFrame("Frame", nil, host)
        v.report = K.Report(v.side)
        v.report:SetAllPoints(v.side)
        v.report.fill = function() v:FillSide() end

        ------------------------------------------------------------------------
        -- choosing what to show
        ------------------------------------------------------------------------
        function v:Load(route)
            local conts, other, stats, contOf = worldState()
            self.conts, self.other, self.stats, self.contOf = conts, other, stats, contOf
            -- the map asked for by a layer of the old book: where that layer has most
            local map = route.map
            if route.layer then
                setLayer(route.layer, true)
                if not map then map = self:BestFor(route.layer) end
            end
            local cont = route.cont
            if map then cont = continentOf(map, contOf) or cont end
            if not cont then
                local here = hereMap()
                cont = here and continentOf(here, contOf)
            end
            if not cont then
                local best
                for _, e in ipairs(conts) do if not best or e.secs > best.secs then best = e end end
                cont = best and best.id or (#other.zones > 0 and OTHER) or nil
            end
            self.contID, self.mapID = cont, map
            self.mode = map and "zone" or "cont"
            -- the list of continents for the choice above the map
            wipe(self.contItems)
            for _, e in ipairs(conts) do self.contItems[#self.contItems + 1] = { e.id, e.name } end
            if #other.zones > 0 then self.contItems[#self.contItems + 1] = { OTHER, L["Other places"] } end
            self.cont:Refresh()
            self.cont:SetShown(#self.contItems > 0)
        end

        function v:Continent(id)
            if id == OTHER then return self.other end
            for _, e in ipairs(self.conts or {}) do if e.id == id then return e end end
        end

        -- the region where a layer has the most to show
        function v:BestFor(layer)
            local C = WFD.C
            if layer == "finds" then
                local _, maps = WFD:GatherSummary()
                return maps[1] and maps[1].id
            elseif layer == "hunt" then
                local per = {}
                for _, m in pairs(C.mobs or {}) do
                    if m.map then per[m.map] = (per[m.map] or 0) + (m.kills or 0) end
                end
                local here = hereMap()
                if here and (per[here] or 0) > 0 then return here end
                local best, most = nil, 0
                for map, n in pairs(per) do if n > most then best, most = map, n end end
                return best
            end
        end

        function v:PaintChips()
            for _, b in ipairs(self.chips) do
                local on = layerOn(b.layer)
                b.style = on and "primary" or "secondary"
                K.Repaint(b)
                b:SetWidth(floor(b.label:GetStringWidth() + 26 + 14 + 0.5))
                b.dot:SetAlpha(on and 1 or 0.45)
                b.ring:SetAlpha(on and 1 or 0.45)
            end
        end

        ------------------------------------------------------------------------
        -- drawing the map
        ------------------------------------------------------------------------
        function v:DrawMap()
            local m = self.map
            if self.mode == "zone" and self.mapID then
                local id = self.mapID
                local legend = m:Draw(id, {
                    route = layerOn("route"), kills = layerOn("kills"), people = layerOn("people"),
                    graves = layerOn("graves"), rests = layerOn("rests"),
                    onPerson = function(key) R.Go({ view = "people", key = key }) end,
                    onDay = function(day) local go = UI.DayGo(day) if go then go() end end,
                }) or {}
                self.legendList = legend
                local C = WFD.C
                if layerOn("finds") then
                    local spots = C.gather and C.gather[id] or {}
                    local points = {}
                    for i = max(1, #spots - 399), #spots do
                        local s = spots[i]
                        local k = s and kindOf(s.k)
                        if k then
                            points[#points + 1] = { s.x, s.y, k.col, { s.item or kindName(k), kindName(k), format(L["Day %d"], s.day or 0) } }
                        end
                    end
                    m:AddPoints(points)
                end
                if layerOn("hunt") then
                    local points = {}
                    for mid, mob in pairs(C.mobs or {}) do
                        if mob.map == id and mob.x then
                            points[#points + 1] = { mob.x, mob.y, PIN_COL[UI.RarityOf(mob)] or PIN_COL.normal,
                                { mob.name or "?", WFD:Count("Slain %d times", mob.kills or 0), L["Click for the wanted poster."] },
                                false, function() R.Go({ view = "bestiary", key = mid }) end }
                        end
                    end
                    for _, s in pairs(C.sighted or {}) do
                        if s.m == id and s.x then
                            points[#points + 1] = { s.x, s.y, SIGHTED_COL, { s.n or "?", L["Sighted, not yet slain"],
                                L["Click to set a marker on the map."] }, true, function() WFD:SetMapMarker(s.m, s.x, s.y, s.n) end }
                        end
                    end
                    m:AddPoints(points)
                end
                -- where you stand, when you are in this region
                local px, py, facing
                if hereMap() == id then
                    local ok, pos = pcall(C_Map.GetPlayerMapPosition, id, "player")
                    if ok and pos then px, py = pos:GetXY() end
                    facing = GetPlayerFacing and GetPlayerFacing()
                end
                m:SetPlayer(px, py, facing)
                m:ApplyZoom()
                return
            end
            self.legendList = nil
            local e = self:Continent(self.contID)
            if not e or self.contID == OTHER then
                m:DrawPoints(0, {})
                m:SetPlayer(nil)
                return
            end
            local zones = {}
            for _, z in ipairs(e.zones) do
                local info
                if z.visited then
                    info = { z.name, format(L["Day %d"], z.day or 1) .. "  -  " .. format(L["%s spent here"], WFD:DurationText(z.secs)) }
                else
                    info = { z.name, L["Not yet explored"] }
                end
                info[#info + 1] = L["Click for the map of this region."]
                local zid = z.id
                zones[#zones + 1] = { id = zid, name = z.name, visited = z.visited, info = info,
                    onClick = function() R.Go({ view = "world", cont = e.id, map = zid }) end }
            end
            m:DrawContinent(e.id, zones)
            m.playButton:Hide()         -- the bar above the map has the button
            local px, py
            local ok, pos = pcall(C_Map.GetPlayerMapPosition, e.id, "player")
            if ok and pos then px, py = pos:GetXY() end
            m:SetPlayer(px, py, GetPlayerFacing and GetPlayerFacing())
        end

        ------------------------------------------------------------------------
        -- the column: the regions of a continent, or the chronicle of a region
        ------------------------------------------------------------------------
        function v:FillSide()
            local rp = self.report
            rp:Begin()
            if self.mode == "zone" and self.mapID then
                self:FillRegion(rp)
            else
                self:FillContinent(rp)
            end
            rp:End()
        end

        function v:FillRegion(rp)
            local ch = chronicle(self.mapID, self.stats[self.mapID])
            local st = ch.stat
            rp:Title(ch.name)
            rp:Text(st and (format(L["Day %d"], st.first) .. "  -  " .. format(L["%s spent here"], WFD:DurationText(st.sec)))
                or L["Not yet explored"], "soft", "small", 12)
            -- the region in eight figures; a figure with something behind it opens the list of it, filtered by the region
            local q = (ch.name or ""):lower()
            local function list(view, extra)
                return function()
                    local route = { view = view, q = q }
                    for k, x in pairs(extra or {}) do route[k] = x end
                    R.Go(route)
                end
            end
            rp:Tiles({
                { st and WFD:DurationText(st.sec) or "-", L["Time spent"] },
                { ch.visits or (st and 1 or 0), L["Visits"] },
                { st and st.kills or 0, L["Kills"], (st and (st.kills or 0) > 0) and list("bestiary", { sort = "zone" }) or nil },
                { ch.quests, L["Quests"], (ch.quests or 0) > 0 and list("quests") or nil },
                { st and format(L["Day %d"], st.first) or "-", L["First visit"], st and UI.DayGo(st.first) },
                { ch.people, L["Acquaintances here"], (ch.people or 0) > 0 and list("people", { sort = "zone" }) or nil },
                { ch.rests, L["Times rested here"] },
                { ch.deaths, L["Deaths here"], ch.deaths > 0 and list("fates") or nil, ch.deaths > 0 and "neg" or nil },
            })

            -- the numbered places on the map
            local legend = self.legendList or {}
            if #legend > 0 then
                rp:Head(L["Places of note"], tostring(#legend))
                local C = WFD.C
                for _, it in ipairs(legend) do
                    if it.kind == "npc" then
                        local npc = C.npcs[it.key]
                        local roles = {}
                        for role in pairs(npc and npc.roles or {}) do
                            if role ~= "talk" then roles[#roles + 1] = WFD:RoleName(role) end
                        end
                        table.sort(roles)
                        local key = it.key
                        rp:Line({ name = it.name, num = it.num, col = { 0.80, 0.55, 0.12 },
                            sub = roles[1] or WFD:Count("Spoken to %d times", npc and npc.talks or 0),
                            go = function() R.Go({ view = "people", key = key }) end,
                            tip = { it.name, L["Click for the portrait."] } })
                    else
                        local go = UI.DayGo(it.day)
                        rp:Line({ name = L["Grave"] .. "  -  " .. format(L["Day %d"], it.day or 0), num = it.num,
                            col = { 0.55, 0.04, 0.04 }, nameKey = "neg",
                            sub = it.by and format(L["Killed by %s"], it.by) or L["You died here"], go = go,
                            tip = go and { L["You died here"], L["Click to read this day."] } or nil })
                    end
                end
                rp:Gap(10)
            end

            -- the most hunted creatures
            rp:Head(L["Most hunted here"], tostring(#ch.mobs))
            if #ch.mobs == 0 then rp:Text(L["Nothing slain here yet."], "muted", "body") end
            local most = ch.mobs[1] and ch.mobs[1].m.kills or 1
            for i = 1, min(6, #ch.mobs) do
                local mob = ch.mobs[i]
                local id = mob.id
                rp:Line({ name = mob.m.name or "?", num = i, col = { 0.62, 0.10, 0.06 }, right = mob.m.kills .. "x",
                    frac = mob.m.kills / max(1, most),
                    go = function() R.Go({ view = "bestiary", key = id }) end,
                    tip = { mob.m.name or "?", WFD:Count("Slain %d times", mob.m.kills), L["Click for the wanted poster."] } })
            end
            rp:Gap(10)

            -- what grew here
            if next(ch.kinds) then
                local parts = {}
                for _, k in ipairs(WFD.GATHER_KINDS or {}) do
                    if ch.kinds[k.key] then parts[#parts + 1] = kindName(k) .. ": " .. ch.kinds[k.key] end
                end
                rp:Head(L["Gatherer's map"])
                rp:Text(table.concat(parts, "  -  "), "soft", "body")
                for i = 1, min(5, #ch.finds) do
                    local f = ch.finds[i]
                    rp:Line({ name = f.name, right = f.n .. "x", col = { 0.36, 0.72, 0.30 }, num = i })
                end
                rp:Gap(10)
            end

            -- places: the ones found, then the ones still to find in grey (the game's list of places and what other
            -- characters of the account found here)
            rp:Head(L["Places discovered"], #ch.subs > ch.found and (ch.found .. " / " .. #ch.subs) or tostring(ch.found))
            if ch.found == 0 then rp:Text(L["No places discovered here yet."], "muted", "body") end
            -- a place found leads to the day it was found
            for i = 1, ch.found do
                local it = ch.subs[i]
                local day = type(it.t) == "number" and WFD:DayIndex(it.t) or nil
                if day then rp:DayLink(day, nil, it.name) else rp:Bullets({ it.name }) end
            end
            for i = ch.found + 1, #ch.subs do
                local it = ch.subs[i]
                rp:Line({ name = it.name, nameKey = "muted",
                    tip = { it.name, L["Not yet discovered"],
                        it.who and format(L["%s already found this place."], it.who) or nil } })
            end
        end

        function v:FillContinent(rp)
            local e = self:Continent(self.contID)
            if not e then
                rp:Title(L["World map"])
                rp:Text(L["No travels recorded yet."], "soft", "body")
                return
            end
            rp:Title(e.name)
            if e.id ~= OTHER then
                rp:Text(format(L["%d of %d regions explored"], e.visited, e.total), "soft", "small", 8)
                local frac = e.visited / max(1, e.total)
                rp:Progress(frac, floor(frac * 100 + 0.5) .. "%")
            else
                rp:Text(L["Dungeons, cities and other places of their own"], "soft", "small", 12)
            end
            rp:Head(e.id == OTHER and L["Other places"] or L["Explorer's checklist"])
            for _, z in ipairs(e.zones) do
                local zid = z.id
                rp:Line({
                    name = z.name, nameKey = z.visited and "ink" or "muted",
                    sub = z.visited and (format(L["Day %d"], z.day or 1) .. "  -  " .. WFD:DurationText(z.secs)) or L["Not yet explored"],
                    col = z.visited and { 0.90, 0.66, 0.16 } or nil, mark = z.visited and "check" or nil, markKey = "white",
                    go = function() R.Go({ view = "world", cont = e.id, map = zid }) end,
                    tip = { z.name, L["Click for the map of this region."] },
                })
            end
        end

        ------------------------------------------------------------------------
        -- the layout
        ------------------------------------------------------------------------
        function v:Arrange()
            local W, H = self.w or host:GetWidth() or 0, self.h or host:GetHeight() or 0
            if W <= 0 or H <= 0 then return end
            local sw = max(SIDE_MIN, min(SIDE_MAX, floor(W * 0.34)))
            local narrow = W - sw < 360
            if narrow then sw = max(240, floor(W * 0.42)) end
            self.side:ClearAllPoints()
            self.side:SetPoint("TOPRIGHT", host, "TOPRIGHT", -12, -12)
            self.side:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -12, 12)
            self.side:SetWidth(sw)
            local lw = W - sw - 24
            book:Lay(W - sw - 18)

            -- the bar: the continent, the way up, the replay, then the layers (lines break where the room ends)
            local zone = self.mode == "zone"
            self.up:SetShown(zone and self.contID ~= nil)
            if zone then
                local e = self:Continent(self.contID)
                self.up:SetLabel(e and e.name or L["World map"])
            end
            self.replay:SetShown(not zone and self.contID ~= nil and self.contID ~= OTHER)
            local x, y, rowH = PAD, -12, 0
            local function put(f, gap)
                local fw, fh = f:GetWidth(), f:GetHeight()
                if x > PAD and x + fw > lw - 4 then x, y, rowH = PAD, y - rowH - 8, 0 end
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", self.bar, "TOPLEFT", x, y)
                x = x + fw + (gap or 8)
                rowH = max(rowH, fh)
            end
            if self.cont:IsShown() then put(self.cont) end
            if self.up:IsShown() then put(self.up) end
            if self.replay:IsShown() then put(self.replay) end
            for _, b in ipairs(self.chips) do b:SetShown(zone) end
            if zone then
                self:PaintChips()
                x, y, rowH = PAD, y - rowH - 10, 0
                for _, b in ipairs(self.chips) do put(b, 4) end
            end
            local barH = -y + rowH + 10
            self.bar:ClearAllPoints()
            self.bar:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
            self.bar:SetSize(lw, barH)

            -- the map: as large as fits, in the proportions of the game's maps
            local footH = 34
            local aw, ah = lw - 2 * PAD, H - barH - footH - 8
            local mw, mh = aw, floor(aw / 1.5)
            if mh > ah then mh = ah mw = floor(ah * 1.5) end
            mw, mh = max(200, mw), max(140, mh)
            local MAT = 8
            self.mount:ClearAllPoints()
            self.mount:SetPoint("TOP", host, "TOPLEFT", PAD + aw / 2, -barH)
            self.mount:SetSize(mw + MAT * 2, mh + MAT * 2)
            local resized = self.map:Resize(mw, mh)

            -- under the map: the key on a continent, the hint about the mouse
            self.legend:SetShown(not zone)
            self.hint:ClearAllPoints()
            self.hint:SetWidth(mw)
            if not zone then
                local lx = 0
                for _, e in ipairs(self.legend.items) do
                    e.dot:ClearAllPoints()
                    e.dot:SetPoint("LEFT", self.legend, "LEFT", lx + 5, 0)
                    e.text:ClearAllPoints()
                    e.text:SetPoint("LEFT", self.legend, "LEFT", lx + 14, 0)
                    lx = lx + 14 + e.text:GetStringWidth() + 18
                end
                self.legend:SetWidth(lx)
                self.legend:ClearAllPoints()
                self.legend:SetPoint("TOP", self.mount, "BOTTOM", 0, -6)
                self.hint:SetPoint("TOP", self.legend, "BOTTOM", 0, -2)
            else
                self.hint:SetPoint("TOP", self.mount, "BOTTOM", 0, -8)
            end
            return resized
        end

        -- after the size changed: the map is drawn again once the size has settled
        function v:QueueDraw()
            self.token = (self.token or 0) + 1
            local t = self.token
            C_Timer.After(0.15, function()
                if t ~= self.token or not host:IsVisible() then return end
                self:DrawMap()
                self:FillSide()
            end)
        end

        function v:Layout(w, h)
            self.w, self.h = w - K.BOOK_W, h - K.BOOK_H          -- inside the book
            if not self.loaded then return end
            if self:Arrange() then self:QueueDraw() else self:FillSide() end
        end

        function v:Show(route)
            local ok, err = pcall(self.Load, self, route)
            if not ok then WFD:Error("world", err) end
            self.loaded = true
            self:Arrange()
            ok, err = pcall(self.DrawMap, self)
            if not ok then WFD:Error("world map", err) end
            ok, err = pcall(self.FillSide, self)
            if not ok then WFD:Error("world side", err) end
            self.report.scroll:ScrollTo(0)
        end

        function v:Hide()
            if self.map and self.map:IsReplaying() then self.map:StopReplay(true) end
        end

        UI.OnRestyle(function()
            if host:IsVisible() and v.loaded then
                v:Arrange()
                v:FillSide()
            end
        end)

        function v:Head()
            local g = UI.NAV_GROUP.world
            local title = L["World map"]
            if self.mode == "zone" and self.mapID then title = WFD:MapName(self.mapID)
            else
                local e = self:Continent(self.contID)
                if e then title = e.name end
            end
            return title, L[g.label], UI.GroupRoute(g)
        end
        return v
    end,
})

-- the region of a map ID on the world map (a card, a toast or the search lead there)
function UI:ShowMapOf(mapID)
    self:OpenShell({ view = "world", map = mapID })
end
