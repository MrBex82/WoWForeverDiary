-- The angler's log: every thing the line brought up (fish, junk, crates, rings), where it bit,
-- and the tackle that was used.
--
-- What is known about the clients (researched, see the notes at each place):
--  * the Forever client (interface 16001) shows a catch with LOOT_READY + IsFishingLoot(), the item from
--    GetLootSlotLink; the older Classic clients know IsFishingLoot since 1.13.2 as well
--  * a lure is read with GetWeaponEnchantInfo(): enchant 263 Shiny Bauble, 264 Nightcrawlers,
--    265 Bright Baubles, 266 Aquadynamic Fish Attractor (the Fish Lens and the Flesh Eating Worm share a tier)
--  * putting a lure on is a spell of its own, with the id listed in LURE_SPELL
--  * a fishing pole is a weapon of item class 2, subclass 20
local ADDON, WFD = ...
local L = WFD.L
local time, format = time, string.format

-- a cast and its catch belong together this long (a bite can take half a minute)
local WINDOW = 60
local FISH_SPELL = 7620

local cur            -- the cast waiting for its catch

local nameOfFishing
local function isFishing(spellID)
    nameOfFishing = nameOfFishing or WFD:SpellName(FISH_SPELL)
    local n = WFD:SpellName(spellID)
    return n ~= nil and n == nameOfFishing
end

local function instant(id)
    local fn = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
    if not fn then return nil end
    -- itemID, itemType, itemSubType, itemEquipLoc, icon, classID, subClassID
    local ok, _, _, _, _, icon, class, sub = pcall(fn, id)
    if ok then return icon, class, sub end
end

-- fish, junk, treasure or odds and ends. Raw fish are consumables (class 0) in the item data of the
-- classic clients and trade goods (class 7) in newer ones; weapons and armour are always a treasure.
function WFD:CatchKind(id, quality)
    local _, class = instant(id)
    if (quality or 1) <= 0 then return "junk" end
    if class == 2 or class == 4 or (quality or 1) >= 2 then return "treasure" end
    if class == 0 or class == 7 then return "fish" end
    return "other"
end

-- Lures: the spell that puts each on the pole, and the temporary enchant it leaves there.
-- (classicdb: Shiny Bauble 8087 -> 263, Nightcrawlers 8088 -> 264, Aquadynamic Fish Attractor 8089 -> 266,
-- Bright Baubles 8090 -> 265; the Fish Lens 8532 and the Flesh Eating Worm 9092 are listed by their items.)
local LURE_SPELL = { [8087] = 6529, [8088] = 6530, [8089] = 6533, [8090] = 6532, [8532] = 6811, [9092] = 7307 }
local LURE_ENCHANT = { [6529] = 263, [6530] = 264, [6532] = 265, [6533] = 266 }
-- gear that adds to fishing: Lucky Fishing Hat, Nat Pagle's Extreme Anglin' Boots (+5 Fishing each)
local GEAR = { [19972] = true, [19969] = true }
local lastLure                  -- the lure put on last

local function equipped(slot)
    if not GetInventoryItemID then return nil end
    local ok, id = pcall(GetInventoryItemID, "player", slot)
    return ok and id or nil
end

-- the rod in hand (main hand: item class 2, subclass 20 is the fishing pole)
local function rodNow()
    local id = equipped(16)
    if not id then return nil end
    local _, class, sub = instant(id)
    if class == 2 and sub == 20 then return id end
end

-- the enchant on the pole: false if none, else its id (true when the game does not tell it)
local function lureNow()
    if not GetWeaponEnchantInfo then return false end
    local ok, has, _, _, enchantID = pcall(GetWeaponEnchantInfo)
    if not (ok and has) then return false end
    return enchantID or true
end

local function linkOf(id)
    local info = (C_Item and C_Item.GetItemInfo) or GetItemInfo
    local ok, _, link = pcall(info, id)
    return ok and link or nil
end

local function tackleEntry(C, id, kind)
    C.tackle = C.tackle or {}
    local e = C.tackle[id]
    if not e then
        e = { n = 0, kind = kind, first = time() }
        C.tackle[id] = e
    end
    -- item data may arrive a moment after the first cast
    if not e.link then
        local link = linkOf(id)
        if link then e.link, e.name = link, WFD:ItemName(link) end
    end
    return e
end

local function gearNow()
    local out = {}
    for _, slot in ipairs({ 1, 8 }) do
        local id = equipped(slot)
        if id and GEAR[id] then out[#out + 1] = id end
    end
    return out
end

-- a line is cast: the water, the pole, the lure and the gear are noted
local function noteCast()
    local C = WFD.C
    local map = WFD:PlayerPos()
    cur = { t = time(), map = map }
    C.catchCasts = (C.catchCasts or 0) + 1
    if map then
        C.catchZone = C.catchZone or {}
        local z = C.catchZone[map]
        if not z then
            z = { casts = 0, loot = 0 }
            C.catchZone[map] = z
        end
        z.casts = z.casts + 1
    end
    local rod = rodNow()
    if rod then
        local e = tackleEntry(C, rod, "rod")
        e.n = e.n + 1
        e.last = time()
    end
    local lure = lureNow()
    if lure then
        cur.lure = true
        C.catchLured = (C.catchLured or 0) + 1
        -- the lure put on last, if the enchant on the pole is the one it leaves
        local want = lastLure and LURE_ENCHANT[lastLure]
        if lastLure and (not want or lure == true or lure == want) then
            local le = tackleEntry(C, lastLure, "lure")
            le.n = le.n + 1
            le.last = time()
        end
    end
    for _, id in ipairs(gearNow()) do
        local ge = tackleEntry(C, id, "gear")
        ge.n = ge.n + 1
        ge.last = time()
    end
    WFD.dirty = true
end

WFD:On("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
    if unit ~= "player" or WFD.paused or WFD.demo or not WFD.C or not spellID then return end
    local lureId = LURE_SPELL[spellID]
    if lureId then
        lastLure = lureId
        tackleEntry(WFD.C, lureId, "lure")
        WFD.dirty = true
        return
    end
    if isFishing(spellID) then noteCast() end
end)

-- a thing was landed: counted for its kind, its water, the account and the diary
local function landed(id, link, quality, count)
    local C = WFD.C
    count = count or 1
    C.catch = C.catch or {}
    local e = C.catch[id]
    local isNew = false
    if not e then
        isNew = true
        e = { n = 0, q = quality or 1, first = time(), kind = WFD:CatchKind(id, quality), zones = {} }
        C.catch[id] = e
    end
    e.link = link
    e.name = WFD:ItemName(link)
    e.icon = e.icon or instant(id)
    e.q = quality or e.q
    e.n = e.n + count
    e.last = time()
    e.day = e.day or WFD:DayIndex()
    if cur.map then
        e.zones[cur.map] = (e.zones[cur.map] or 0) + count
        local z = C.catchZone and C.catchZone[cur.map]
        if z and not cur.got then z.loot = z.loot + 1 end
    end
    cur.got = true
    if cur.lure then e.lured = (e.lured or 0) + 1 end
    C.catchTotal = (C.catchTotal or 0) + count
    -- the account's log: your other characters see a covered card with the water where it bit
    local S = WFD.S
    if S then
        S.catches = S.catches or {}
        local a = S.catches[id]
        if not a then
            a = { z = cur.map and WFD:MapName(cur.map) or nil, q = e.q, kind = e.kind, who = C.name }
            S.catches[id] = a
        end
        a.n = e.name or a.n
    end
    -- only the first catch is a moment of the diary; the ranks and the honour "Fish Lore" tell the rest
    -- (and a rare find is noted by the loot tracker)
    if isNew and e.kind ~= "junk" and not C.catchFirstNoted then
        C.catchFirstNoted = true
        WFD:Milestone("catch", format(L["New catch: %s"], e.name or "?"), false, { item = id })
    end
    WFD.dirty = true
end

-- The loot window of a catch: LOOT_READY with IsFishingLoot() (it can fire twice for one catch,
-- so a second one within seconds is the same catch).
local lootAt
WFD:On("LOOT_READY", function()
    if WFD.paused or WFD.demo or not WFD.C then return end
    if not (IsFishingLoot and IsFishingLoot()) then return end
    local now = GetTime and GetTime() or time()
    if lootAt and now - lootAt < 3 then return end
    lootAt = now
    -- one loot window is one catch: with no cast seen for it (or one that has its catch already, or an
    -- old one) the catch makes the cast it came from
    if not cur or cur.got or time() - cur.t > WINDOW then noteCast() end
    local slots = GetNumLootItems and GetNumLootItems() or 0
    for slot = 1, slots do
        local link = GetLootSlotLink and GetLootSlotLink(slot)
        local id = link and tonumber(link:match("item:(%d+)"))
        if id then
            -- the third value of GetLootSlotInfo is the quantity in every client
            local qty = GetLootSlotInfo and select(3, GetLootSlotInfo(slot))
            landed(id, link, WFD:ItemQuality(link, id), tonumber(qty) or 1)
        end
    end
end)

-- a client without IsFishingLoot: the first loot within a minute of the cast, unless a corpse gave it
WFD:OnSignal("loot", function(link, quality, count, id)
    if IsFishingLoot or WFD.paused or WFD.demo or not WFD.C or not id then return end
    if not cur or cur.got or time() - cur.t > WINDOW then return end
    local kill = WFD.LastKill and WFD:LastKill()
    if kill and kill.t and kill.t >= cur.t then return end
    landed(id, link, quality, count)
end)

-- what the other characters of the account landed and this one has not, grouped by water:
-- { id, hint = true, h = { n, z, q, kind, who }, zone }
function WFD:CatchHints()
    local S, C = self.S, self.C
    local byZone, n = {}, 0
    local function put(id, a)
        local zone = a.z or "?"
        byZone[zone] = byZone[zone] or {}
        table.insert(byZone[zone], { id = id, hint = true, h = a, zone = zone })
        n = n + 1
    end
    if self.demo then
        local z = self:MapName(1429) or "?"
        put(-1, { n = "?", z = z, kind = "fish", who = "Mirelle" })
        put(-2, { n = "?", z = z, kind = "treasure", who = "Tobin" })
        return byZone, n
    end
    for id, a in pairs(S and S.catches or {}) do
        if not (C.catch and C.catch[id]) and a.who ~= C.name then put(id, a) end
    end
    for _, list in pairs(byZone) do
        table.sort(list, function(a, b)
            if (a.h.kind or "") ~= (b.h.kind or "") then return (a.h.kind or "") < (b.h.kind or "") end
            return (a.h.n or "") < (b.h.n or "")
        end)
    end
    return byZone, n
end

-- counts for the pages and the honours
function WFD:CatchSummary()
    local C = self.C
    local kinds, species, total = { fish = 0, junk = 0, treasure = 0, other = 0 }, 0, 0
    for _, e in pairs(C.catch or {}) do
        species = species + 1
        total = total + (e.n or 0)
        kinds[e.kind or "other"] = (kinds[e.kind or "other"] or 0) + 1
    end
    return { species = species, total = total, kinds = kinds, casts = C.catchCasts or 0 }
end
