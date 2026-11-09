-- More of the appendix: in memoriam, book of honour, treasure album, companions
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

local GREEN = UI.c.good

local function emptyText(pool, canvas, tx, tw, y, text)
    local e = pool:Text(14, c.inkFaint, UI.FONT, "CENTER")
    e:SetText(text)
    e:SetWidth(tw)
    e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
end

------------------------------------------------------------------------
-- In memoriam (hardcore): the book closes with an obituary
------------------------------------------------------------------------
UI:RegisterSection({
    key = "memoriam", label = "In memoriam", icon = "skull", order = 1, thumb = false,
    enabled = function() return WFD.C and WFD.C.obituary ~= nil end,
    build = function(book)
        book:Add({ kind = "obituary", numbered = true })
    end,
})

UI:RegisterRenderer("obituary", function(pool, page, side, canvas)
    local C = WFD.C
    local o = C.obituary
    if not o then return end
    local tx, tw = UI.TextX(side), UI.TextW()
    local cx = tx + tw / 2
    local frame = pool:Get("blackframe", function(p)
        local f = UI.Frame(p)
        UI.Backdrop(f, "tooltip", 14, 4, { 0, 0, 0, 0 }, { 0.62, 0.58, 0.55, 1 })
        return f
    end)
    frame:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx - 12, -34)
    frame:SetSize(tw + 24, UI.PH - 34 - 44)
    frame:SetFrameLevel(canvas:GetFrameLevel() + 1)

    local t = pool:Text(30, c.ink, UI.HEAD, "CENTER")
    t:SetText(L["In memoriam"])
    t:SetPoint("TOP", canvas, "TOPLEFT", cx, -56)
    local n = pool:Text(24, c.ink, UI.HEAD, "CENTER")
    n:SetText(C.name or "?")
    n:SetPoint("TOP", canvas, "TOPLEFT", cx, -96)
    local who = pool:Text(10, c.inkSoft, UI.FONT, "CENTER")
    who:SetText(((C.race or "") .. "  -  " .. (C.class or "") .. "  -  " .. format(L["Level %d"], o.level or 0)):upper())
    who:SetPoint("TOP", canvas, "TOPLEFT", cx, -128)
    local dates = pool:Text(14, c.ink, UI.FONT, "CENTER")
    dates:SetText(date(WFD.loc.date, C.born) .. "  -  " .. date(WFD.loc.date, o.t))
    dates:SetPoint("TOP", canvas, "TOPLEFT", cx, -146)
    UI.PageDivider(pool, canvas, cx, -172, 220)

    -- the last moment
    local killerId
    if o.by then
        for id, m in pairs(C.mobs) do if m.name == o.by then killerId = id break end end
    end
    local pic = pool:Painting(tw, 132)
    pic:SetSize(tw, 132)
    pic:SetFrameLevel(canvas:GetFrameLevel() + 2)
    pic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, -186)
    pic:Paint({ npc = killerId, gear = o.gear, s = o.by and format(L["Killed by %s"], o.by) or L["The last moment"] })

    local place = pool:Text(14, c.ink, UI.FONT, "CENTER")
    place:SetWidth(tw)
    place:SetText(format(L["Fell in %s"], (o.sub and o.sub ~= "" and (o.sub .. ", ") or "") .. (o.zone or "?"))
        .. (o.by and ("\n" .. format(L["Slain by %s"], o.by)) or ""))
    place:SetPoint("TOP", canvas, "TOPLEFT", cx, -332)
    local tt = WFD:Totals()
    local life = pool:Text(12, c.inkSoft, UI.FONT, "CENTER")
    life:SetWidth(tw)
    life:SetText(WFD:Count("%d days of life, %d creatures slain, %d quests completed", tt.days, tt.kills, tt.quests))
    life:SetPoint("TOP", canvas, "TOPLEFT", cx, -378)
    local ep = pool:Text(14, c.inkFaint, UI.HEAD, "CENTER")
    ep:SetWidth(tw)
    ep:SetText(L["\"Here the journey ends, but not the story.\""])
    ep:SetPoint("TOP", canvas, "TOPLEFT", cx, -414)
    local seal = pool:Seal(40, c.black, "skull")
    seal:SetPoint("CENTER", canvas, "TOPLEFT", cx, -470)
end)

------------------------------------------------------------------------
-- Book of honour: achievements Classic never had, climbing from bronze to legend
------------------------------------------------------------------------
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"
local LOCKED = { 0.46, 0.39, 0.30, 1 }

local function progressText(e)
    local v = e.value
    if e.def.m == "km" then v = WFD:Dec(floor(v * 10) / 10) end
    return tostring(v) .. " / " .. tostring(e.next or e.def.tiers[e.n])
end

-- red caps heading with a diamond, an optional count on the right and a fading rule
local function sectionHead(...) return UI.SectionHead(...) end

local function honourTip(e)
    local h = e.def
    if e.hidden then
        return { "???", L[h.secret], L["A secret honour. Keep exploring!"] }
    end
    local lines = { L[h.name] }
    if WFD.C and WFD.C.title == h.key then lines[#lines + 1] = "|cffffd100" .. L["Your title"] .. "|r" end
    if WFD:InShowcase(h.key) then lines[#lines + 1] = "|cffffd100" .. L["In the showcase"] .. "|r" end
    for i, g in ipairs(h.tiers) do
        local m = WFD:MetalOf(i, e.n)
        local mark = (i <= e.tier) and ("|cff40c040" .. L["earned"] .. "|r") or ("|cffb0a080" .. progressText({ value = e.value, def = h, n = e.n, next = g }) .. "|r")
        lines[#lines + 1] = "|cff" .. UI.Hex(m.col) .. L[m.name] .. "|r  " .. WFD:HonourText(h, g) .. "  " .. mark
    end
    if e.tier > 0 then
        lines[#lines + 1] = (WFD.C and WFD.C.title == h.key) and L["Click to give up this title."] or L["Click to make this your title."]
        lines[#lines + 1] = WFD:InShowcase(h.key) and L["Right-click to take it out of the showcase."] or L["Right-click to put it in the showcase."]
    end
    return lines
end

-- (the book of honour is a view of the travel desk now: UI/Views/Trophies.lua)

------------------------------------------------------------------------
-- Landmarks: famous places waiting to be found
------------------------------------------------------------------------
UI:RegisterSection({
    key = "landmarks", label = "Landmarks", icon = "sight", order = 13, thumb = false,
    build = function(book)
        local groups, found, total = WFD:LandmarkState()
        book.landmarks = { found = found, total = total }
        local list = {}
        if total == 0 then list[1] = { h = 40, empty = L["This game client knows none of the landmarks."] } end
        for _, g in ipairs(groups) do
            list[#list + 1] = { h = 36, header = L[g.def.label], count = g.found .. " / " .. g.total, keep = 38 }
            -- only what has been found is named: the places still waiting stay a secret, they are counted
            local seen = {}
            for _, it in ipairs(g.items) do if it.found then seen[#seen + 1] = it end end
            for i = 1, #seen, 2 do list[#list + 1] = { h = 38, pair = { seen[i], seen[i + 1] } } end
            if g.found < g.total then list[#list + 1] = { h = 26, pending = g.total - g.found } end
        end
        book:AddRows("landmarks", list, { head = L["Landmarks"] })
    end,
})

UI:RegisterRenderer("landmarks", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local lm = UI.book.landmarks or { found = 0, total = 0 }
    if page.first then
        local y = UI.PageTitle(pool, canvas, side, L["Landmarks"], format(L["%d of %d landmarks found"], lm.found, lm.total), -56)
        local bw = tw * 0.6
        local track = pool:Rect(c.inkFaint, 0.22)
        track:SetSize(bw, 4)
        track:SetPoint("TOP", canvas, "TOPLEFT", tx + tw / 2, y + 12)
        if lm.found > 0 then
            local bar = pool:Grad("HORIZONTAL", { 0.12, 0.40, 0.40, 1 }, { 0.30, 0.62, 0.55, 1 })
            bar:SetSize(max(2, bw * lm.found / max(1, lm.total)), 4)
            bar:SetPoint("TOPLEFT", track, "TOPLEFT")
        end
    end
    local top = -UI.TOP
    local GAP_X = 12
    local colW = (tw - GAP_X) / 2
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.empty then
            emptyText(pool, canvas, tx, tw, y - 6, r.empty)
        elseif r.header then
            sectionHead(pool, canvas, tx, tw, y, r.h, r.header, r.count)
        elseif r.pending then
            local t = pool:Text(11, c.inkFaint, UI.FONT)
            t:SetText(format(L["%d still to find"], r.pending))
            t:SetWordWrap(false)
            t:SetWidth(tw - 8)
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 4)
        elseif r.pair then
            for k = 1, 2 do
                local it = r.pair[k]
                if it then
                    local x = tx + (k - 1) * (colW + GAP_X)
                    pool:Plaque(x + 14, y - 16, 24, UI.IconPath({ it.icon }, "sight"),
                        it.found and WFD.METALS[3].col or LOCKED, it.found)
                    local n = pool:Text(12, it.found and c.ink or c.inkFaint, UI.FONT)
                    n:SetText(it.name)
                    n:SetWordWrap(false)
                    n:SetWidth(colW - 36)
                    n:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 33, y - 4)
                    local sub = pool:Text(9, it.found and c.redInk or c.inkFaint, UI.FONT)
                    sub:SetText(it.found and (format(L["Day %d"], it.day) .. "  -  " .. date(WFD.loc.date, it.t)) or L["not yet found"])
                    sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 33, y - 19)
                    local p = it.found and UI.book.dayPage[it.day]
                    local hot = pool:Hot(it.found and { it.name, date(WFD.loc.date .. " %H:%M", it.t), L["Click to read this day."] }
                        or { it.name, L["not yet found"] }, p and function() UI:GoToPage(p) end)
                    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y + 1)
                    hot:SetSize(colW, r.h - 4)
                end
            end
        end
    end
end)

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

-- the doll: one place per slot, with the game's empty-slot picture; some kinds share a place
local DOLL = {
    { "head", "INVTYPE_HEAD", "Head" }, { "neck", "INVTYPE_NECK", "Neck" }, { "shoulder", "INVTYPE_SHOULDER", "Shoulder" },
    { "back", "INVTYPE_CLOAK", "Chest" }, { "chest", "INVTYPE_CHEST", "Chest" }, { "wrist", "INVTYPE_WRIST", "Wrists" },
    { "hand", "INVTYPE_HAND", "Hands" }, { "waist", "INVTYPE_WAIST", "Waist" },
    { "legs", "INVTYPE_LEGS", "Legs" }, { "feet", "INVTYPE_FEET", "Feet" }, { "finger", "INVTYPE_FINGER", "Finger" },
    { "trinket", "INVTYPE_TRINKET", "Trinket" }, { "main", "INVTYPE_WEAPONMAINHAND", "MainHand" },
    { "off", "INVTYPE_SHIELD", "SecondaryHand" }, { "ranged", "INVTYPE_RANGED", "Ranged" },
}
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
-- Companions and trading partners
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

UI:RegisterSection({
    key = "companions", label = "Companions", icon = "party", order = 45,
    build = function(book)
        local C = WFD.C
        local list = {}
        local comp = {}
        for key, e in pairs(C.companions or {}) do comp[#comp + 1] = { key = key, e = e } end
        table.sort(comp, function(a, b) return (a.e.kills + a.e.groups * 10) > (b.e.kills + b.e.groups * 10) end)
        list[#list + 1] = { h = 36, header = L["Fellow adventurers"], count = tostring(#comp), keep = 44 }
        for _, x in ipairs(comp) do list[#list + 1] = { h = 46, comp = x } end
        if #comp == 0 then list[#list + 1] = { h = 30, empty = L["You have not grouped with anyone yet."] } end
        local tr = {}
        for name, t in pairs(C.traders or {}) do tr[#tr + 1] = { name = name, t = t } end
        table.sort(tr, function(a, b) return a.t.count > b.t.count end)
        list[#list + 1] = { h = 44, header = L["Trading partners"], count = tostring(#tr), keep = 28 }
        for i, x in ipairs(tr) do list[#list + 1] = { h = 28, trade = x } end
        if #tr == 0 then list[#list + 1] = { h = 30, empty = L["No trades yet."] } end
        book:AddRows("companions", list, { head = L["Companions"] })
    end,
})

UI:RegisterRenderer("companions", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then UI.PageTitle(pool, canvas, side, L["Companions"], L["Who walked beside me"], -56) end
    local top = -UI.TOP
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.header then
            UI.SectionHead(pool, canvas, tx, tw, y, r.h, r.header, r.count)
        elseif r.empty then
            local e = pool:Text(12, c.inkFaint, UI.FONT)
            e:SetText(r.empty)
            e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 6)
        elseif r.comp then
            local e = r.comp.e
            local col = UI.ClassColor(e.classFile)
            local dark = UI.THEME == "parchment" and UI.Deep(col, 0.3) or { col[1] * 0.6, col[2] * 0.6, col[3] * 0.6, 1 }
            local path, coords = classCrest(e.classFile)
            pool:Plaque(tx + 17, y - 20, 30, path, col, true, e.level and tostring(e.level) or nil, coords)
            local n = pool:Text(15, dark, UI.HEAD)
            n:SetText(e.name or r.comp.key)
            n:SetWordWrap(false)
            n:SetWidth(tw - 42 - 110)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 42, y - 3)
            local days = 0
            for _ in pairs(e.days or {}) do days = days + 1 end
            -- kills and days together, as two small figures on the right
            local stats = { { e.kills or 0, (e.kills == 1) and L["kill"] or L["kills"] }, { days, (days == 1) and L["day"] or L["days"] } }
            local x = tx + tw
            for i = #stats, 1, -1 do
                local v = pool:Text(14, c.ink, UI.HEAD, "RIGHT")
                v:SetText(tostring(stats[i][1]))
                v:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x, y - 1)
                local l = pool:Text(9, c.inkSoft, UI.FONT, "RIGHT")
                l:SetText(stats[i][2]:upper())
                l:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x, y - 16)
                x = x - max(34, l:GetStringWidth() + 10)
            end
            -- the line below the name ends where the figures begin
            local sub = pool:Text(9, c.inkFaint, UI.FONT)
            local met = format(L["first met %s"], date(WFD.loc.date, e.first))
            local room = x - tx - 42
            for _, s in ipairs({ (e.class or "") .. "  -  " .. met .. (e.zone and ("  -  " .. e.zone) or ""),
                (e.class or "") .. "  -  " .. met, met }) do
                sub:SetText(s:upper())
                if sub:GetStringWidth() <= room then break end
            end
            sub:SetWidth(room)
            sub:SetWordWrap(false)
            sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 42, y - 23)
            local p = UI.book.dayPage[WFD:DayIndex(e.first)]
            local hot = pool:Hot({ e.name or "?", (e.class or "") .. (e.zone and ("  -  " .. e.zone) or ""),
                WFD:Count("%d times grouped", e.groups),
                WFD:Count("%d kills together", e.kills or 0) }, p and function() UI:GoToPage(p) end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
            hot:SetSize(tw, r.h - 4)
        elseif r.trade then
            local t = r.trade.t
            local ic = pool:Icon(UI.IconPath({ "INV_Misc_Coin_02" }, "coin"), 18)
            ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 5)
            local n = pool:Text(12, c.ink, UI.FONT)
            n:SetText(r.trade.name .. "  |cff" .. UI.Hex(c.inkFaint) .. format(L["%dx traded"], t.count) .. "|r")
            n:SetWordWrap(false)
            n:SetWidth(tw - 30 - 120)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 28, y - 8)
            local money = {}
            if (t.got or 0) > 0 then money[#money + 1] = "|cff" .. UI.Hex(c.good) .. "+" .. UI.CoinIcons(t.got, 10) .. "|r" end
            if (t.gave or 0) > 0 then money[#money + 1] = "|cff" .. UI.Hex(c.bad) .. "-" .. UI.CoinIcons(t.gave, 10) .. "|r" end
            local m = pool:Text(11, c.inkSoft, UI.FONT, "RIGHT")
            m:SetText(#money > 0 and table.concat(money, "  ") or "-")
            m:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw - 4, y - 8)
        end
    end
end)

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
