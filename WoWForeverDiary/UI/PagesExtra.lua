-- More of the appendix: in memoriam, book of honour, treasure album, companions
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format

local TITLE_H = 116
local GREEN = UI.c.good

local function rows(book, kind, list, head)
    local page, y
    local function newPage(first)
        page = book:Add({ kind = kind, rows = {}, first = first, numbered = true, head = head })
        y = first and TITLE_H or 0
    end
    newPage(true)
    for _, r in ipairs(list) do
        -- r.keep: room the next row needs, so a heading never ends up alone at the bottom of a page
        if y + r.h + (r.keep or 0) > UI.AREA_H then newPage(false) end
        r.y = y
        page.rows[#page.rows + 1] = r
        y = y + r.h
    end
end

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
    life:SetText(format(L["%d days of life  -  %d creatures slain  -  %d quests completed"], tt.days, tt.kills, tt.quests))
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

UI:RegisterSection({
    key = "honour", label = "Book of honour", icon = "honour", order = 12,
    build = function(book)
        local all, sum = WFD:HonourState()
        book.honour = sum
        local list = { { h = 78, summary = true } }
        -- the closest next steps, so there is always something to aim for
        local near = {}
        for _, e in ipairs(all) do
            if e.next and not e.hidden then
                near[#near + 1] = { e = e, f = (e.value - e.prev) / max(1, e.next - e.prev) }
            end
        end
        table.sort(near, function(a, b) return a.f > b.f end)
        if #near > 0 then
            list[#list + 1] = { h = 28, header = L["Almost there"], keep = 24 }
            for i = 1, min(3, #near) do list[#list + 1] = { h = 26, near = near[i].e, frac = near[i].f } end
        end
        for _, cat in ipairs(WFD.HONOUR_CATS) do
            local items, got, tot = {}, 0, 0
            for _, e in ipairs(all) do
                if e.def.cat == cat.key then
                    items[#items + 1] = e
                    got, tot = got + e.tier, tot + e.n
                end
            end
            if #items > 0 then
                list[#list + 1] = { h = 36, header = L[cat.label], count = got .. " / " .. tot, keep = 50 }
                for _, e in ipairs(items) do list[#list + 1] = { h = 52, entry = e } end
            end
        end
        rows(book, "honour", list, L["Book of honour"])
    end,
})

local function drawSummary(pool, canvas, tx, tw, y, s)
    -- honour points, large, with the maximum beside them
    local big = pool:Text(34, c.ink, UI.HEAD)
    big:SetText(tostring(s.points))
    big:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
    local of = pool:Text(15, c.inkFaint, UI.HEAD)
    of:SetText(" / " .. s.maxPoints)
    of:SetPoint("BOTTOMLEFT", big, "BOTTOMRIGHT", 0, 4)
    local lab = pool:Text(9, c.inkSoft, UI.FONT)
    lab:SetText(L["Honour points"]:upper())
    lab:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 1, y - 38)
    -- the medal cabinet: how many tiers of each metal
    local x = tx + tw
    for i = 5, 1, -1 do
        local m = WFD.METALS[i]
        local has = s.metals[i] > 0
        local cx = x - 15
        local pl = pool:Plaque(cx, y - 14, 18, UI.IconPath(UI.METAL_ICONS[i], "coin"), m.col, has)
        local n = pool:Text(11, has and c.ink or c.inkFaint, UI.HEAD, "CENTER")
        n:SetText(tostring(s.metals[i]))
        n:SetPoint("TOP", pl, "BOTTOM", 0, -3)
        local hot = pool:Hot({ L[m.name], format(L["%d tiers earned"], s.metals[i]) })
        hot:SetPoint("CENTER", pl, "CENTER", 0, -8)
        hot:SetSize(28, 40)
        x = x - 34
    end
    -- all tiers of all honours as one gold-leaf bar
    local track = pool:Rect(c.inkFaint, 0.22)
    track:SetSize(tw, 4)
    track:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 58)
    if s.points > 0 then
        local bar = pool:Grad("HORIZONTAL", { 0.70, 0.45, 0.16, 1 }, { 0.95, 0.75, 0.28, 1 })
        bar:SetSize(max(2, tw * s.points / max(1, s.maxPoints)), 4)
        bar:SetPoint("TOPLEFT", track, "TOPLEFT")
    end
end

local function honourTip(e)
    local h = e.def
    if e.hidden then
        return { "???", L[h.secret], L["A secret honour. Keep exploring!"] }
    end
    local lines = { L[h.name] }
    for i, g in ipairs(h.tiers) do
        local m = WFD:MetalOf(i, e.n)
        local mark = (i <= e.tier) and ("|cff40c040" .. L["earned"] .. "|r") or ("|cffb0a080" .. progressText({ value = e.value, def = h, n = e.n, next = g }) .. "|r")
        lines[#lines + 1] = "|cff" .. UI.Hex(m.col) .. L[m.name] .. "|r  " .. WFD:HonourText(h, g) .. "  " .. mark
    end
    return lines
end

UI:RegisterRenderer("honour", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local s = UI.book.honour or { points = 0, maxPoints = 0, tiers = 0, totalTiers = 0, metals = { 0, 0, 0, 0, 0 } }
    if page.first then
        UI.PageTitle(pool, canvas, side, L["Book of honour"], format(L["%d of %d honour tiers reached"], s.tiers, s.totalTiers), -56)
    end
    local top = -UI.TOP
    local NX = tx + 46
    local barW = tx + tw - NX
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.summary then
            drawSummary(pool, canvas, tx, tw, y, s)
        elseif r.header then
            sectionHead(pool, canvas, tx, tw, y, r.h, r.header, r.count)
        elseif r.near then
            local e = r.near
            local nextM = WFD:MetalOf(e.tier + 1, e.n)
            local ic = pool:Icon(UI.IconPath(e.def.icon), 18)
            ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 2, y - 2)
            local n = pool:Text(12, c.ink, UI.FONT)
            n:SetText(L[e.def.name] .. "  |cff" .. UI.Hex(nextM.col) .. L[nextM.name] .. "|r")
            n:SetWordWrap(false)
            n:SetWidth(tw - 28 - 92)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 28, y - 5)
            local pv = pool:Text(10, c.inkSoft, UI.FONT, "RIGHT")
            pv:SetText(progressText(e))
            pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
            local bt = pool:Rect(c.inkFaint, 0.22)
            bt:SetSize(84, 3)
            bt:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 16)
            local bf = pool:Rect(c.redInk, 0.9)
            bf:SetSize(max(1, 84 * min(1, r.frac)), 3)
            bf:SetPoint("TOPLEFT", bt, "TOPLEFT")
            local hot = pool:Hot(honourTip(e))
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
            hot:SetSize(tw, r.h - 2)
        elseif r.entry then
            local e = r.entry
            local h = e.def
            local earned = e.tier > 0
            local metal = earned and WFD:MetalOf(e.tier, e.n).col or LOCKED
            pool:Plaque(tx + 19, y - 22, 32, e.hidden and QUESTION or UI.IconPath(h.icon), metal, earned)
            local n = pool:Text(15, earned and c.ink or c.inkSoft, UI.HEAD)
            n:SetText(e.hidden and "???" or L[h.name])
            n:SetWordWrap(false)
            n:SetWidth(barW - e.n * 14 - 6)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", NX, y - 3)
            -- one diamond per tier, in the metal it is worth once earned
            local px = tx + tw - 4
            for i = e.n, 1, -1 do
                local got = i <= e.tier
                local col = got and WFD:MetalOf(i, e.n).col or { 0.58, 0.50, 0.38, 0.35 }
                local d = pool:Diamond(got and 10 or 8, col)
                d:SetPoint("CENTER", canvas, "TOPLEFT", px, y - 10)
                px = px - 14
            end
            local d = pool:Text(11, e.hidden and c.inkSoft or c.inkFaint, UI.FONT)
            d:SetText(e.hidden and L[h.secret] or WFD:HonourText(h, e.next or h.tiers[e.n]))
            d:SetWordWrap(false)
            d:SetWidth(barW - 70)
            d:SetPoint("TOPLEFT", canvas, "TOPLEFT", NX, y - 22)
            if not e.hidden then
                local pv = pool:Text(10, e.next and c.inkSoft or GREEN, UI.FONT, "RIGHT")
                pv:SetText(e.next and progressText(e) or L["Complete!"])
                pv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 23)
                local track = pool:Rect(c.inkFaint, 0.20)
                track:SetSize(barW, 3)
                track:SetPoint("TOPLEFT", canvas, "TOPLEFT", NX, y - 39)
                local frac = e.next and (e.value - e.prev) / max(1, e.next - e.prev) or 1
                if frac > 0 then
                    local bar
                    if e.next then
                        -- in the metal of the tier it is heading for
                        local m = WFD:MetalOf(e.tier + 1, e.n).col
                        bar = pool:Grad("HORIZONTAL", { m[1] * 0.7, m[2] * 0.7, m[3] * 0.7, 0.85 }, { m[1], m[2], m[3], 1 })
                    else
                        bar = pool:Grad("HORIZONTAL", { 0.70, 0.45, 0.16, 1 }, { 0.95, 0.75, 0.28, 1 })
                    end
                    bar:SetSize(max(2, barW * min(1, frac)), 3)
                    bar:SetPoint("TOPLEFT", track, "TOPLEFT")
                end
            else
                -- a dotted line instead of a bar: nobody knows how far it is
                for i = 0, floor(barW / 8) - 1 do
                    local dot = pool:Rect(c.inkFaint, 0.35)
                    dot:SetSize(3, 1)
                    dot:SetPoint("TOPLEFT", canvas, "TOPLEFT", NX + i * 8, y - 40)
                end
            end
            local hot = pool:Hot(honourTip(e))
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
            hot:SetSize(tw, r.h - 4)
        end
    end
end)

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
            for i = 1, #g.items, 2 do list[#list + 1] = { h = 38, pair = { g.items[i], g.items[i + 1] } } end
        end
        rows(book, "landmarks", list, L["Landmarks"])
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

local function setTreasureFilter(q)
    UI.treasureFilter = q
    UI:Paginate()
    local st = UI.book.sectionStart.treasures
    if st then UI:ShowSpread(math.ceil(st / 2)) end
end

UI:RegisterSection({
    key = "treasures", label = "Treasures", icon = "loot", order = 35,
    build = function(book)
        local C = WFD.C
        local agg = {}
        for d = 1, WFD:NumDays() do
            local day = C.days[d]
            if day then
                for id, e in pairs(day.loot) do
                    if (e.q or 1) >= 2 then
                        local a = agg[id]
                        if not a then
                            a = { id = id, link = e.link, q = e.q, n = 0, day = d, src = e.src }
                            agg[id] = a
                        end
                        a.n = a.n + e.n
                    end
                end
            end
        end
        -- grouped by kind (legs, chest, weapons, recipes ...); the quality shows in the frame and the ink.
        -- A chosen quality (a click on its gem in the display case) leaves only those in the list.
        local filter = UI.treasureFilter
        local groups, byKey, counts, total, best = {}, {}, {}, 0, {}
        for _, a in pairs(agg) do
            local key, name, rank = treasureGroup(a.link)
            a.gkey = key
            local q = math.min(5, a.q)
            counts[q] = (counts[q] or 0) + 1
            total = total + 1
            -- the best find for each slot of the doll: the highest quality, the latest of those
            local slot = DOLL_OF[key]
            if slot then
                local b = best[slot]
                if not b or a.q > b.q or (a.q == b.q and a.day > b.day) then best[slot] = a end
            end
            if not filter or q == filter then
                local g = byKey[key]
                if not g then
                    g = { key = key, name = name, rank = rank, items = {} }
                    byKey[key] = g
                    groups[#groups + 1] = g
                end
                table.insert(g.items, a)
            end
        end
        table.sort(groups, function(a, b)
            if a.rank ~= b.rank then return a.rank < b.rank end
            return a.name < b.name
        end)
        book.treasureCount = total
        local list = { { h = 76, summary = true, counts = counts } }
        if total == 0 then
            list[#list + 1] = { h = 40, empty = L["No treasures found yet."] }
        else
            list[#list + 1] = { h = 116, doll = true, best = best }
        end
        if filter then list[#list + 1] = { h = 26, filterNote = filter } end
        for _, g in ipairs(groups) do
            local items = g.items
            -- the best first, then in the order they were found
            table.sort(items, function(a, b)
                if a.q ~= b.q then return a.q > b.q end
                return a.day < b.day
            end)
            list[#list + 1] = { h = 36, header = g.name, gkey = g.key, count = tostring(#items), keep = 50 }
            for i = 1, #items, 2 do list[#list + 1] = { h = 50, pair = { items[i], items[i + 1] } } end
        end
        local before = #book.pages
        rows(book, "treasures", list, L["Treasures"])
        -- where each kind begins, for the slots of the doll
        book.treasureGroupPage = {}
        for i = before + 1, #book.pages do
            for _, r in ipairs(book.pages[i].rows or {}) do
                if r.gkey then book.treasureGroupPage[r.gkey] = i end
            end
        end
    end,
})

UI:RegisterRenderer("treasures", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    if page.first then
        UI.PageTitle(pool, canvas, side, L["Treasures"], format(L["%d treasures collected"], UI.book.treasureCount or 0), -56)
    end
    local top = -UI.TOP
    local GAP_X = 12
    local colW = (tw - GAP_X) / 2
    local worn = wornNow()
    local filter = UI.treasureFilter
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.summary then
            -- the display case: one plaque per quality with the number of finds; a click shows only those
            local n = 4
            local step = tw / n
            for i, q in ipairs({ 2, 3, 4, 5 }) do
                local cnt = r.counts[q] or 0
                local cx = tx + step * (i - 0.5)
                local icons = { [2] = "INV_Misc_Gem_Emerald_01", [3] = "INV_Misc_Gem_Sapphire_01",
                    [4] = "INV_Misc_Gem_Amethyst_01", [5] = "INV_Misc_Gem_Pearl_05" }
                local lit = cnt > 0 and (not filter or filter == q)
                local pl = pool:Plaque(cx, y - 16, 26, UI.IconPath({ icons[q], "INV_Misc_Gem_Variety_01" }, "gem"),
                    QFRAME[q], lit, tostring(cnt))
                local lab = pool:Text(9, lit and QINK[q] or c.inkFaint, UI.FONT, "CENTER")
                lab:SetText(qualityName(q):upper())
                lab:SetPoint("TOP", pl, "BOTTOM", 0, -5)
                if filter == q then
                    local u = pool:Rect(QINK[q], 1)
                    u:SetSize(lab:GetStringWidth(), 1)
                    u:SetPoint("TOP", lab, "BOTTOM", 0, -2)
                end
                if cnt > 0 then
                    local hot = pool:Hot({ qualityName(q), tostring(cnt),
                        filter == q and L["Click to show all again."] or L["Click to show only these."] },
                        function() setTreasureFilter(filter ~= q and q or nil) end)
                    hot:SetPoint("CENTER", pl, "CENTER", 0, -8)
                    hot:SetSize(step - 6, 52)
                end
            end
            local rule = pool:Grad("HORIZONTAL", { 0.78, 0.60, 0.26, 0 }, { 0.78, 0.60, 0.26, 0.5 })
            rule:SetSize(tw, 1)
            rule:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 64)
        elseif r.doll then
            -- the best find for every slot; empty slots show the game's own outline
            local cap = pool:Text(10, c.redInk, UI.FONT)
            cap:SetText(L["Best find for every slot"]:upper())
            cap:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 2)
            local key = pool:Text(9, c.inkSoft, UI.FONT, "RIGHT")
            key:SetText(L["worn right now"])
            key:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 3)
            local tick = pool:Icon("Interface\\RAIDFRAME\\ReadyCheck-Ready", 12)
            tick:SetTexCoord(0, 1, 0, 1)
            tick:SetPoint("RIGHT", key, "LEFT", -3, 0)
            local step = tw / 8
            for i, d in ipairs(DOLL) do
                local rowN = (i <= 8) and 0 or 1
                local col = (i <= 8) and (i - 1) or (i - 9)
                local cx = tx + step * (col + 0.5) + rowN * step / 2
                local cy = y - 38 - rowN * 44
                local a = r.best[d[1]]
                local slotName = rawget(_G, d[2]) or d[3]
                local hot
                if a then
                    local q = math.min(5, a.q)
                    local pl = pool:Plaque(cx, cy, 28, WFD:ItemIcon(a.link) or UI.Icon("loot"), QFRAME[q], true)
                    if worn[a.id] then
                        local t = pool:Icon("Interface\\RAIDFRAME\\ReadyCheck-Ready", 14, "OVERLAY", 2)
                        t:SetTexCoord(0, 1, 0, 1)
                        t:SetPoint("CENTER", pl, "TOPRIGHT", -2, -2)
                    end
                    local gp = UI.book.treasureGroupPage and UI.book.treasureGroupPage[a.gkey]
                    hot = pool:Hot(nil, gp and function() UI:GoToPage(gp) end, a.link)
                    hot:SetPoint("CENTER", pl, "CENTER")
                else
                    local path = "Interface\\PaperDoll\\UI-PaperDoll-Slot-" .. d[3]
                    local pl = pool:Plaque(cx, cy, 28, UI.Has(path) and path or UI.Icon("loot"), LOCKED, false)
                    -- the game's slot outline, laid once more over the dimmed one so it can be made out
                    if UI.Has(path) then
                        local outline = pool:Icon(path, 28, "ARTWORK", 5)
                        outline:SetPoint("CENTER", pl, "CENTER")
                        outline:SetVertexColor(0.80, 0.74, 0.64, 1)
                    end
                    hot = pool:Hot({ slotName, L["not yet found"] })
                    hot:SetPoint("CENTER", pl, "CENTER")
                end
                hot:SetSize(34, 34)
            end
        elseif r.filterNote then
            local t = pool:Text(11, QINK[r.filterNote], UI.FONT)
            t:SetText(format(L["Shown: %s only"], qualityName(r.filterNote)))
            t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y - 4)
            local link = pool:Link(L["Show all"] .. "  >", function() setTreasureFilter(nil) end, 12)
            link:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 4)
        elseif r.empty then
            emptyText(pool, canvas, tx, tw, y - 6, r.empty)
        elseif r.header then
            UI.SectionHead(pool, canvas, tx, tw, y, r.h, r.header, r.count)
        elseif r.pair then
            for k = 1, 2 do
                local it = r.pair[k]
                if it then
                    local q = math.min(5, it.q)
                    local x = tx + (k - 1) * (colW + GAP_X)
                    local pl = pool:Plaque(x + 18, y - 20, 32, WFD:ItemIcon(it.link) or UI.Icon("loot"), QFRAME[q], true,
                        it.n > 1 and tostring(it.n) or nil)
                    if worn[it.id] then
                        local t = pool:Icon("Interface\\RAIDFRAME\\ReadyCheck-Ready", 14, "OVERLAY", 2)
                        t:SetTexCoord(0, 1, 0, 1)
                        t:SetPoint("CENTER", pl, "TOPRIGHT", -2, -2)
                    end
                    local n = pool:Text(11, QINK[q], UI.FONT)
                    n:SetText(WFD:ItemName(it.link))
                    n:SetWidth(colW - 42)
                    if n.SetMaxLines then n:SetMaxLines(2) end
                    n:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 40, y - 3)
                    local s = pool:Text(9, c.inkFaint, UI.FONT)
                    s:SetText(format(L["Day %d"], it.day))
                    s:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 40, y - 31)
                    local p = UI.book.dayPage[it.day]
                    local hot = pool:Hot(nil, p and function() UI:GoToPage(p) end, it.link)
                    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y + 1)
                    hot:SetSize(colW, r.h - 4)
                    -- where it came from: the creature's name leads to its wanted poster
                    if it.src then
                        local mob = mobByName(it.src)
                        local src = pool:Text(9, mob and c.redInk or c.inkFaint, UI.FONT)
                        src:SetText("-  " .. it.src)
                        src:SetWordWrap(false)
                        src:SetWidth(max(10, colW - 42 - s:GetStringWidth() - 6))
                        src:SetPoint("LEFT", s, "RIGHT", 6, 0)
                        if mob then
                            local sh = pool:Hot({ it.src, L["Click for the wanted poster."] },
                                function() UI:ShowCard("creature", mob) end)
                            sh:SetPoint("TOPLEFT", src, "TOPLEFT", -2, 3)
                            sh:SetPoint("BOTTOMRIGHT", src, "BOTTOMRIGHT", 2, -3)
                            sh:SetFrameLevel(hot:GetFrameLevel() + 2)
                        end
                    end
                end
            end
        end
    end
end)

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
        for i, x in ipairs(tr) do list[#list + 1] = { h = 28, trade = x, alt = (i % 2 == 0) } end
        if #tr == 0 then list[#list + 1] = { h = 30, empty = L["No trades yet."] } end
        rows(book, "companions", list, L["Companions"])
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
            local dark = { col[1] * 0.6, col[2] * 0.6, col[3] * 0.6, 1 }
            local path, coords = classCrest(e.classFile)
            pool:Plaque(tx + 17, y - 20, 30, path, col, true, e.level and tostring(e.level) or nil, coords)
            local n = pool:Text(15, dark, UI.HEAD)
            n:SetText(e.name or r.comp.key)
            n:SetWordWrap(false)
            n:SetWidth(tw - 42 - 110)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 42, y - 3)
            local days = 0
            for _ in pairs(e.days or {}) do days = days + 1 end
            local sub = pool:Text(9, c.inkFaint, UI.FONT)
            sub:SetText(((e.class or "") .. "  -  " .. format(L["first met %s"], date(WFD.loc.date, e.first))
                .. (e.zone and ("  -  " .. e.zone) or "")):upper())
            sub:SetWidth(tw - 42)
            sub:SetWordWrap(false)
            sub:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 42, y - 23)
            -- kills and days together, as two small figures on the right
            local stats = { { e.kills or 0, L["kills"] }, { days, L["days"] } }
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
            local p = UI.book.dayPage[WFD:DayIndex(e.first)]
            local hot = pool:Hot({ e.name or "?", format(L["%d times grouped"], e.groups),
                format(L["%d kills together"], e.kills or 0) }, p and function() UI:GoToPage(p) end)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
            hot:SetSize(tw, r.h - 4)
        elseif r.trade then
            local t = r.trade.t
            if r.alt then
                local band = pool:Rect(c.paperDk, 0.35)
                band:SetSize(tw, r.h)
                band:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
            end
            local ic = pool:Icon(UI.IconPath({ "INV_Misc_Coin_02" }, "coin"), 18)
            ic:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 5)
            local n = pool:Text(12, c.ink, UI.FONT)
            n:SetText(r.trade.name .. "  |cffc2a880" .. format(L["%dx traded"], t.count) .. "|r")
            n:SetWordWrap(false)
            n:SetWidth(tw - 30 - 120)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 28, y - 8)
            local money = {}
            if (t.got or 0) > 0 then money[#money + 1] = "|cff94cc73+" .. UI.CoinIcons(t.got, 10) .. "|r" end
            if (t.gave or 0) > 0 then money[#money + 1] = "|cffe37861-" .. UI.CoinIcons(t.gave, 10) .. "|r" end
            local m = pool:Text(11, c.inkSoft, UI.FONT, "RIGHT")
            m:SetText(#money > 0 and table.concat(money, "  ") or "-")
            m:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw - 4, y - 8)
        end
    end
end)
