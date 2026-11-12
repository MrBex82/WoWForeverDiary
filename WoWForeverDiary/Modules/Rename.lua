-- Renaming: creatures, people, places, quests and items are stored with the names the game client gave them.
-- When the client now runs in another language, they are looked up again by their IDs and replaced -
-- in the records and inside the stored sentences. Whatever the game first has to fetch from the server
-- is asked again a little later; what is still missing at the end is tried again at the next login.
local ADDON, WFD = ...

local renames = {}           -- old name -> new name
local function remember(old, new)
    if type(old) == "string" and type(new) == "string" and old ~= "" and new ~= "" and old ~= new then
        renames[old] = new
        return true
    end
end
local function rn(v) return (type(v) == "string" and renames[v]) or v end

------------------------------------------------------------------------
-- Looking names up by ID
------------------------------------------------------------------------
local tip
local function creatureName(id)
    if not tip then tip = CreateFrame("GameTooltip", "WoWForeverDiaryScanTip", nil, "GameTooltipTemplate") end
    tip:SetOwner(WorldFrame, "ANCHOR_NONE")
    tip:ClearLines()
    if not pcall(tip.SetHyperlink, tip, ("unit:Creature-0-0-0-0-%d-0000000000"):format(id)) then return nil end
    local fs = _G["WoWForeverDiaryScanTipTextLeft1"]
    local name = fs and fs:GetText()
    tip:Hide()
    -- placeholders while the game still asks the server do not count as names
    if not name or name == "" or name == UNKNOWNOBJECT or name == UNKNOWN or name == RETRIEVING_DATA
        or name == RETRIEVING_ITEM_INFO or name:find("%.%.%.$") then
        return nil
    end
    return name
end

local function questTitle(id)
    local QL = C_QuestLog
    if QL and QL.GetTitleForQuestID then
        local ok, t = pcall(QL.GetTitleForQuestID, id)
        if ok and type(t) == "string" and t ~= "" then return t end
    end
    if QL and QL.GetQuestInfo then
        local ok, t = pcall(QL.GetQuestInfo, id)
        if ok and type(t) == "string" and t ~= "" then return t end
    end
    if QL and QL.RequestLoadQuestByID then pcall(QL.RequestLoadQuestByID, id) end
end

local function itemName(id)
    -- newer clients moved the item functions to C_Item
    local get = (C_Item and C_Item.GetItemNameByID) or (C_Item and C_Item.GetItemInfo) or GetItemInfo
    if not get then return end
    local ok, name = pcall(get, id)
    if ok and type(name) == "string" and name ~= "" then return name end
    if C_Item and C_Item.RequestLoadItemDataByID then pcall(C_Item.RequestLoadItemDataByID, id) end
end

------------------------------------------------------------------------
-- Places: zone names are stored without an ID, but people, quests and days know the map they were on
------------------------------------------------------------------------
local function zoneNames(C)
    local votes = {}
    local function vote(zone, map, w)
        if type(zone) ~= "string" or zone == "" or not map then return end
        votes[zone] = votes[zone] or {}
        votes[zone][map] = (votes[zone][map] or 0) + (w or 1)
    end
    for zone, map in pairs(C.zoneMaps or {}) do vote(zone, map, 100) end
    for _, n in pairs(C.npcs or {}) do vote(n.zone, n.map) end
    for _, q in pairs(C.quests or {}) do vote(q.zone, q.map) end
    for _, r in ipairs(C.rests or {}) do vote(r.zone, r.map) end
    for _, d in pairs(C.days or {}) do
        local zs, ms = {}, {}
        for z in pairs(d.zones or {}) do zs[#zs + 1] = z end
        for m in pairs(d.path or {}) do ms[#ms + 1] = m end
        if #zs == 1 and #ms == 1 then vote(zs[1], ms[1], 3) end
    end
    local function isZone(m)
        local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(m)
        if not info then return false end
        -- 0 cosmic, 1 world, 2 continent: too big to name a place
        return not (info.mapType and info.mapType <= 2), info
    end
    local out = {}
    for zone, maps in pairs(votes) do
        local bv, bestInfo = 0, nil
        for m, v in pairs(maps) do
            local ok, info = isZone(m)
            if ok and v > bv then bv, bestInfo = v, info end
        end
        if bestInfo and type(bestInfo.name) == "string" and bestInfo.name ~= "" then out[zone] = bestInfo.name end
    end
    return out
end

------------------------------------------------------------------------
-- Replacing names inside sentences, as whole words only
------------------------------------------------------------------------
local function wordByte(b) return b and (b >= 128 or (b >= 48 and b <= 57) or (b >= 65 and b <= 90) or (b >= 97 and b <= 122)) end
local function replaceWhole(s, old, new)
    if not s:find(old, 1, true) then return s end
    local out, i = {}, 1
    while true do
        local a, b = s:find(old, i, true)
        if not a then break end
        if not wordByte(s:byte(a - 1)) and not wordByte(s:byte(b + 1)) then
            out[#out + 1] = s:sub(i, a - 1)
            out[#out + 1] = new
        else
            out[#out + 1] = s:sub(i, b)
        end
        i = b + 1
    end
    out[#out + 1] = s:sub(i)
    return table.concat(out)
end

local olds
local function retext(s)
    if type(s) ~= "string" or s == "" then return s end
    for _, old in ipairs(olds) do s = replaceWhole(s, old, renames[old]) end
    return s
end

-- a table keyed by names: move every entry to its new name (merging with fn when both exist)
local function rekey(tbl, merge)
    if type(tbl) ~= "table" then return end
    local moves = {}
    for k in pairs(tbl) do if renames[k] then moves[#moves + 1] = k end end
    for _, k in ipairs(moves) do
        local new = renames[k]
        if tbl[new] ~= nil and merge then tbl[new] = merge(tbl[new], tbl[k]) elseif tbl[new] == nil then tbl[new] = tbl[k] end
        tbl[k] = nil
    end
end
local function sum(a, b) return (tonumber(a) or 0) + (tonumber(b) or 0) end
local function earlier(a, b) if type(a) == "number" and type(b) == "number" then return math.min(a, b) end return a end

------------------------------------------------------------------------
-- Writing the new names everywhere
------------------------------------------------------------------------
local function applyAll(C)
    olds = {}
    for old in pairs(renames) do olds[#olds + 1] = old end
    table.sort(olds, function(a, b) return #a > #b end)
    if #olds == 0 then return end
    -- records keyed by name
    rekey(C.zones, function(a, b)
        a.first = earlier(a.first, b.first)
        a.visits = (a.visits or 0) + (b.visits or 0)
        for s, t in pairs(b.sub or {}) do a.sub[s] = a.sub[s] or t end
        return a
    end)
    rekey(C.zoneMaps)
    -- announced lands keep their old name too: inside an inn or a cave the map may still give it
    C.announced = C.announced or {}
    for old, new in pairs(renames) do
        if C.announced[old] then C.announced[new] = true end
    end
    rekey(C.instances, earlier)
    rekey(C.encounters, sum)
    rekey(C.nemesis, function(a, b) a.n = (a.n or 0) + (b.n or 0) return a end)
    C.startZone = rn(C.startZone)
    for _, m in pairs(C.mobs or {}) do m.zone = rn(m.zone) end
    for _, s in pairs(C.sighted or {}) do s.z = rn(s.z) end
    for _, n in pairs(C.npcs or {}) do n.zone = rn(n.zone) end
    for _, n in pairs(C.nemesis or {}) do n.zone = rn(n.zone) end
    for _, f in ipairs(C.fates or {}) do
        f.zone = rn(f.zone)
        f.by = rn(f.by)
    end
    for _, q in pairs(C.quests or {}) do
        q.zone = rn(q.zone)
        q.giverName = rn(q.giverName)
    end
    for _, e in pairs(C.companions or {}) do e.zone = rn(e.zone) end
    for _, e in pairs(C.traders or {}) do e.zone = rn(e.zone) end
    for _, r in ipairs(C.rests or {}) do r.zone = rn(r.zone) end
    for _, f in pairs(C.firsts or {}) do
        f.zone = rn(f.zone)
        f.s = retext(f.s)
    end
    for _, ch in pairs(C.challenges or {}) do
        for _, t in ipairs(ch.list or {}) do t.name = rn(t.name) end
    end
    for _, r in ipairs(C.runs or {}) do
        r.name = rn(r.name)
        for i, b in ipairs(r.bosses or {}) do r.bosses[i] = rn(b) end
        for _, dth in ipairs(r.deaths or {}) do dth.by = rn(dth.by) end
        if r.last then r.last.name = rn(r.last.name) end
        for i, link in ipairs(r.loot or {}) do r.loot[i] = retext(link) end
    end
    if C.obituary then
        C.obituary.zone = rn(C.obituary.zone)
        C.obituary.by = rn(C.obituary.by)
    end
    -- the days
    for _, d in pairs(C.days or {}) do
        rekey(d.zones, sum)
        rekey(d.instances)
        for i, by in ipairs(d.deathBy or {}) do d.deathBy[i] = rn(by) end
        for _, pos in ipairs(d.dpos or {}) do pos[4] = rn(pos[4]) end
        for _, e in pairs(d.loot or {}) do
            e.src = rn(e.src)
            e.link = retext(e.link)
        end
    end
    for _, q in pairs(C.quests or {}) do q.reward = retext(q.reward) end
    -- the angler's log, the tackle and the gathering spots keep item names of their own
    for _, tbl in ipairs({ C.catch or {}, C.tackle or {} }) do
        for _, e in pairs(tbl) do
            e.name = rn(e.name)
            e.link = retext(e.link)
        end
    end
    for _, list in pairs(C.gather or {}) do
        for _, s in ipairs(list) do s.item = rn(s.item) end
    end
    for _, ev in ipairs(C.events or {}) do ev.s = retext(ev.s) end
end

------------------------------------------------------------------------
-- The run: look everything up in small portions, then write the new names
------------------------------------------------------------------------
local queue, failed, ticker

local function finish(C)
    for old, new in pairs(zoneNames(C)) do remember(old, new) end
    local ok, err = pcall(applyAll, C)
    if not ok then WFD:Error("rename", err) end
    if failed == 0 then C.renameTries = nil else C.renameTries = (C.renameTries or 0) + 1 end
    if failed == 0 or C.renameTries >= 3 then
        C.nameLang = GetLocale()
        C.renameTries = nil
    end
    if next(renames) then
        WFD.dirty = true
        if WFD.UI and WFD.UI.ClearCaches then WFD.UI.ClearCaches() end
        if WFD.UI and WFD.UI.bookFrame and WFD.UI.bookFrame:IsShown() and WFD.UI.Reflow then WFD.UI:Reflow() end
    end
end

-- one lookup; what the server still has to send is asked again a few seconds later
local function try(C, task, now)
    local new
    if task.k == "mob" or task.k == "npc" or task.k == "sight" then new = creatureName(task.id)
    elseif task.k == "quest" then new = questTitle(task.id)
    elseif task.k == "item" then new = itemName(task.id) end
    if new then
        remember(task.old, new)
        if task.k == "mob" then C.mobs[task.id].name = new
        elseif task.k == "npc" then C.npcs[task.id].name = new
        elseif task.k == "sight" and C.sighted and C.sighted[task.id] then C.sighted[task.id].n = new
        elseif task.k == "quest" then C.quests[task.id].title = new end
        return
    end
    task.tries = (task.tries or 0) + 1
    if task.tries < 6 then
        task.later = now + 2 * task.tries
        queue[#queue + 1] = task
    else
        failed = failed + 1
    end
end

local function step()
    local C = WFD.C
    if not C or WFD.demo or not queue then
        if ticker then ticker:Cancel() ticker = nil end
        return
    end
    local now = GetTime()
    for _ = 1, 12 do
        local task = table.remove(queue, 1)
        if not task then
            if ticker then ticker:Cancel() ticker = nil end
            queue = nil
            finish(C)
            return
        end
        if task.later and task.later > now then
            queue[#queue + 1] = task          -- still waiting for the server
        else
            try(C, task, now)
        end
    end
end

local function start()
    local C = WFD.C
    if not C or WFD.demo or C.nameLang == GetLocale() then return end
    queue, failed = {}, 0
    for id, m in pairs(C.mobs or {}) do
        if type(id) == "number" and m.name then queue[#queue + 1] = { k = "mob", id = id, old = m.name } end
    end
    for id, s in pairs(C.sighted or {}) do
        if type(id) == "number" and s.n then queue[#queue + 1] = { k = "sight", id = id, old = s.n } end
    end
    for id, n in pairs(C.npcs or {}) do
        if type(id) == "number" and n.name then queue[#queue + 1] = { k = "npc", id = id, old = n.name } end
    end
    for id, q in pairs(C.quests or {}) do
        if type(id) == "number" and q.title then queue[#queue + 1] = { k = "quest", id = id, old = q.title } end
    end
    -- items: every link the diary keeps
    local items = {}
    local function addLink(link)
        local id = type(link) == "string" and tonumber(link:match("item:(%d+)"))
        if id and not items[id] then items[id] = WFD:ItemName(link) end
    end
    for _, d in pairs(C.days or {}) do for _, e in pairs(d.loot or {}) do addLink(e.link) end end
    for _, r in ipairs(C.runs or {}) do for _, link in ipairs(r.loot or {}) do addLink(link) end end
    for _, q in pairs(C.quests or {}) do addLink(q.reward) end
    for _, tbl in ipairs({ C.catch or {}, C.tackle or {} }) do
        for id, e in pairs(tbl) do
            if type(id) == "number" and e.name and not items[id] then items[id] = e.name end
        end
    end
    for id, old in pairs(items) do queue[#queue + 1] = { k = "item", id = id, old = old } end
    -- landmarks know their area: their names come straight from the game, no waiting
    if C_Map and C_Map.GetAreaInfo then
        for _, ev in ipairs(C.events or {}) do
            if ev.k == "landmark" and ev.landmark and ev.s then
                local ok, name = pcall(C_Map.GetAreaInfo, ev.landmark)
                if ok then remember(ev.s:match(":%s*(.+)$"), name) end
            end
        end
    end
    if #queue == 0 then
        C.nameLang = GetLocale()
        return
    end
    ticker = C_Timer.NewTicker(0.25, function()
        local ok, err = pcall(step)
        if not ok then
            WFD:Error("rename", err)
            if ticker then ticker:Cancel() ticker = nil end
        end
    end)
end

-- A zone stored under a name the client's map gave in the wrong language ("Stormwind" for "Sturmwind"):
-- renamed everywhere once, as soon as the right name is known. Does nothing when no such zone is stored.
function WFD:FixZoneName(old, new)
    local C = self.C
    if not C or self.demo or type(old) ~= "string" or type(new) ~= "string" or old == new then return end
    local stored = (C.zones and C.zones[old]) or C.startZone == old
    if not stored then
        for _, d in pairs(C.days or {}) do
            if d.zones and d.zones[old] then stored = true break end
        end
    end
    if not stored or not remember(old, new) then return end
    C.zoneAlias = C.zoneAlias or {}
    C.zoneAlias[old] = new
    C.announced = C.announced or {}
    if C.announced[old] or C.announced[new] then C.announced[old], C.announced[new] = true, true end
    local ok, err = pcall(applyAll, C)
    if not ok then self:Error("rename", err) end
    self.dirty = true
    if self.UI and self.UI.ClearCaches then self.UI.ClearCaches() end
end

-- Lands stored under the name of a building (an inn, a town hall: the game names the building as the zone
-- inside it) are moved back to the zone the map puts them in. Names that point the wrong way are forgotten.
function WFD:RepairZoneNames()
    local C = self.C
    if not C or self.demo or not (C_Map and C_Map.GetMapInfo) or not C.zones then return end
    local fix = self.loc and self.loc.zoneFix or {}
    for old, new in pairs(C.zoneAlias or {}) do
        if fix[old] ~= new then C.zoneAlias[old] = nil end
    end
    local found = false
    for name, id in pairs(C.zoneMaps or {}) do
        local info = type(id) == "number" and C_Map.GetMapInfo(id)
        if info and info.mapType == 3 and type(info.name) == "string" and info.name ~= "" then
            local real = fix[info.name] or info.name
            if real ~= name and C.zones[name] and remember(name, real) then found = true end
        end
    end
    -- a building inside a dungeon or battleground ("Sägewerk der Warsong" in Warsongschlucht): a stored land that
    -- is no instance, no land of the atlas and has no map of a zone, and that shares a sub-area with an instance
    -- (the same named spot was recorded under both), belongs to that instance
    local atlas = {}
    for _, cont in ipairs(self.CONTINENTS or {}) do
        local ok, kids = pcall(C_Map.GetMapChildrenInfo, cont, 3, false)
        for _, k in ipairs(ok and kids or {}) do
            if k.name then atlas[k.name] = true atlas[fix[k.name] or k.name] = true end
        end
    end
    for name, z in pairs(C.zones) do
        local id = C.zoneMaps and C.zoneMaps[name]
        local info = type(id) == "number" and C_Map.GetMapInfo(id)
        local zoneMap = info and info.mapType and info.mapType >= 3
        if type(z) == "table" and type(z.sub) == "table" and not zoneMap and not atlas[name]
            and not (C.instances and C.instances[name]) and not renames[name] then
            local only, n = nil, 0
            for inst in pairs(C.instances or {}) do
                local iz = C.zones[inst]
                if inst ~= name and type(iz) == "table" and type(iz.sub) == "table" then
                    for sub in pairs(z.sub) do
                        if iz.sub[sub] then only, n = inst, n + 1 break end
                    end
                end
            end
            if n == 1 and remember(name, only) then found = true end
        end
    end
    if not found then return end
    local ok, err = pcall(applyAll, C)
    if not ok then self:Error("rename", err) end
    self.dirty = true
    if self.UI and self.UI.ClearCaches then self.UI.ClearCaches() end
end

WFD:OnInit(function()
    if C_Timer and C_Timer.After then
        C_Timer.After(8, function() pcall(start) end)
        C_Timer.After(10, function()
            for old, new in pairs(WFD.loc and WFD.loc.zoneFix or {}) do WFD:FixZoneName(old, new) end
            local ok, err = pcall(WFD.RepairZoneNames, WFD)
            if not ok then WFD:Error("rename", err) end
        end)
    end
end)
