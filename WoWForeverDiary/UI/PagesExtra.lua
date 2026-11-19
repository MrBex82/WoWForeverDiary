-- More of the appendix: in memoriam, book of honour, treasure album, companions
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local floor = math.floor

-- (in memoriam is a view of the travel desk now: UI/Views/Keepsakes.lua)

------------------------------------------------------------------------
-- Book of honour: achievements Classic never had, climbing from bronze to legend
------------------------------------------------------------------------

local function progressText(e)
    local v = e.value
    if e.def.m == "km" then v = WFD:Dec(floor(v * 10) / 10) end
    return tostring(v) .. " / " .. tostring(e.next or e.def.tiers[e.n])
end

local function honourTip(e)
    local h = e.def
    if e.hidden then
        return { "???", L[h.secret], L["A secret honour. Keep exploring!"] }
    end
    local lines = { L[h.name] }
    if WFD.C and WFD.C.title == h.key then lines[#lines + 1] = "|cffffd100" .. L["My title"] .. "|r" end
    if WFD:InShowcase(h.key) then lines[#lines + 1] = "|cffffd100" .. L["In the showcase"] .. "|r" end
    for i, g in ipairs(h.tiers) do
        local m = WFD:MetalOf(i, e.n)
        local mark = (i <= e.tier) and ("|cff40c040" .. L["earned"] .. "|r") or ("|cffb0a080" .. progressText({ value = e.value, def = h, n = e.n, next = g }) .. "|r")
        lines[#lines + 1] = "|cff" .. UI.Hex(m.col) .. L[m.name] .. "|r  " .. WFD:HonourText(h, g) .. "  " .. mark
    end
    if e.tier > 0 then
        lines[#lines + 1] = (WFD.C and WFD.C.title == h.key) and L["Click to give up this title."] or L["Click to make this my title."]
        lines[#lines + 1] = WFD:InShowcase(h.key) and L["Right-click to take it out of the showcase."] or L["Right-click to put it in the showcase."]
    end
    return lines
end

-- (the book of honour is a view of the travel desk now: UI/Views/Trophies.lua)

-- (the landmarks are a view of the travel desk now: UI/Views/Keepsakes.lua)

------------------------------------------------------------------------
-- Treasure album: a display case of every notable find, grouped by kind (the slot it is worn in, weapons, goods)
------------------------------------------------------------------------
-- frame colours (bright) and ink colours (readable on parchment) per item quality
local QFRAME = {
    [2] = { 0.18, 0.80, 0.10, 1 }, [3] = { 0.10, 0.48, 0.92, 1 }, [4] = { 0.66, 0.25, 0.95, 1 }, [5] = { 1, 0.55, 0.05, 1 },
}
local QINK = {
    [2] = { 0.40, 0.90, 0.30, 1 }, [3] = { 0.40, 0.66, 1.0, 1 }, [4] = { 0.78, 0.50, 1.0, 1 }, [5] = { 1, 0.62, 0.20, 1 },
}
-- the same colours deepened for the light parchment (read at drawing time: the look is set after loading)
local QINK_PARCHMENT = {
    [2] = { 0.10, 0.45, 0.05, 1 }, [3] = { 0.05, 0.28, 0.65, 1 }, [4] = { 0.45, 0.12, 0.62, 1 }, [5] = { 0.68, 0.32, 0.00, 1 },
}
local function qink(q)
    if UI.THEME == "parchment" then return QINK_PARCHMENT[q] or QINK[q] end
    return QINK[q]
end
local QNAME = { [2] = "Uncommon", [3] = "Rare", [4] = "Epic", [5] = "Legendary" }

-- the game's own name for a quality ("Selten", "Rar", "Episch" ...), else ours
local function qualityName(q)
    return _G["ITEM_QUALITY" .. q .. "_DESC"] or L[QNAME[q] or "?"]
end

-- what kind of thing a find is: the slot it is worn in, in the order of the character sheet, then weapons,
-- then the other kinds of goods. Names come from the game, in the language of the client.
local SLOT_ORDER = {
    "INVTYPE_HEAD", "INVTYPE_NECK", "INVTYPE_SHOULDER", "INVTYPE_CLOAK", "INVTYPE_CHEST", "INVTYPE_BODY",
    "INVTYPE_TABARD", "INVTYPE_WRIST", "INVTYPE_HAND", "INVTYPE_WAIST", "INVTYPE_LEGS", "INVTYPE_FEET",
    "INVTYPE_FINGER", "INVTYPE_TRINKET", "weapon", "INVTYPE_SHIELD", "INVTYPE_HOLDABLE", "INVTYPE_RANGED",
    "INVTYPE_THROWN", "INVTYPE_RELIC", "INVTYPE_AMMO", "INVTYPE_QUIVER", "INVTYPE_BAG",
}
local SLOT_SAME = {
    INVTYPE_ROBE = "INVTYPE_CHEST", INVTYPE_WEAPON = "weapon", INVTYPE_2HWEAPON = "weapon",
    INVTYPE_WEAPONMAINHAND = "weapon", INVTYPE_WEAPONOFFHAND = "weapon", INVTYPE_RANGEDRIGHT = "INVTYPE_RANGED",
}
local SLOT_RANK = {}
for i, k in ipairs(SLOT_ORDER) do SLOT_RANK[k] = i end
-- the plural names of the auction house, where the client has them
local CLASS_PLURAL = {
    [0] = "AUCTION_CATEGORY_CONSUMABLES", [1] = "AUCTION_CATEGORY_CONTAINERS", [3] = "AUCTION_CATEGORY_GEMS",
    [7] = "AUCTION_CATEGORY_TRADE_GOODS", [9] = "AUCTION_CATEGORY_RECIPES", [12] = "AUCTION_CATEGORY_QUEST_ITEMS",
    [15] = "AUCTION_CATEGORY_MISCELLANEOUS",
}

-- key, heading and rank of the group a found item belongs to
local function treasureGroup(link)
    local fn = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
    local itype, loc, classID
    if fn and link then
        local ok, _, t, _, l, _, cid = pcall(fn, link)
        if ok then itype, loc, classID = t, l, cid end
    end
    loc = loc and (SLOT_SAME[loc] or loc)
    if loc and SLOT_RANK[loc] then
        local name = (loc == "weapon") and (rawget(_G, "AUCTION_CATEGORY_WEAPONS") or itype) or rawget(_G, loc)
        return loc, name or itype or L["Other"], SLOT_RANK[loc]
    end
    if classID then
        local plural = CLASS_PLURAL[classID] and rawget(_G, CLASS_PLURAL[classID])
        return "class" .. classID, plural or itype or L["Other"], 100 + classID
    end
    return "other", L["Other"], 999
end

local DOLL_OF = {
    INVTYPE_HEAD = "head", INVTYPE_NECK = "neck", INVTYPE_SHOULDER = "shoulder", INVTYPE_CLOAK = "back",
    INVTYPE_CHEST = "chest", INVTYPE_WRIST = "wrist", INVTYPE_HAND = "hand", INVTYPE_WAIST = "waist",
    INVTYPE_LEGS = "legs", INVTYPE_FEET = "feet", INVTYPE_FINGER = "finger", INVTYPE_TRINKET = "trinket",
    weapon = "main", INVTYPE_SHIELD = "off", INVTYPE_HOLDABLE = "off", INVTYPE_RANGED = "ranged", INVTYPE_THROWN = "ranged",
}

-- the items worn right now
local function wornNow()
    local set = {}
    if GetInventoryItemID then
        for slot = 1, 19 do
            local ok, id = pcall(GetInventoryItemID, "player", slot)
            if ok and id then set[id] = true end
        end
    end
    return set
end

-- a creature named as the source of a find, for its wanted poster
local function mobByName(name)
    if not name then return nil end
    for id, m in pairs(WFD.C.mobs or {}) do
        if m.name == name then return id end
    end
end

-- (the treasures are a view of the travel desk now: UI/Views/Trophies.lua)

------------------------------------------------------------------------
-- Class crests
------------------------------------------------------------------------
local CLASS_ATLAS = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"

-- class crest: the icon from the character creation atlas, if this client has it
local function classCrest(classFile)
    local tc = classFile and CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classFile]
    if tc and UI.Has(CLASS_ATLAS) then
        local inset = 0.012
        return CLASS_ATLAS, { tc[1] + inset, tc[2] - inset, tc[3] + inset, tc[4] - inset }
    end
    return UI.Icon("people"), nil
end
UI.ClassCrest = classCrest

-- (companions and trading partners are a view of the travel desk now: UI/Views/People.lua)

------------------------------------------------------------------------
-- For the views of the travel desk (UI/Views/Trophies.lua)
------------------------------------------------------------------------
-- every notable find once, with its group (the slot it is worn in, weapons, goods) and its place on the doll
function UI.TreasureList()
    local C = WFD.C
    local agg, list = {}, {}
    for d = 1, WFD:NumDays() do
        local day = C.days[d]
        if day then
            for id, e in pairs(day.loot or {}) do
                if (e.q or 1) >= 2 then
                    local a = agg[id]
                    if not a then
                        a = { id = id, link = e.link, q = e.q, n = 0, day = d, src = e.src }
                        agg[id] = a
                        list[#list + 1] = a
                    end
                    a.n = a.n + e.n
                end
            end
        end
    end
    for _, a in ipairs(list) do
        a.gkey, a.gname, a.rank = treasureGroup(a.link)
        a.slot = DOLL_OF[a.gkey]
    end
    return list
end
UI.TreasureInk, UI.TreasureFrame, UI.QualityName = qink, QFRAME, qualityName
UI.WornNow, UI.MobByName = wornNow, mobByName
UI.HonourTip, UI.HonourProgressText = honourTip, progressText
