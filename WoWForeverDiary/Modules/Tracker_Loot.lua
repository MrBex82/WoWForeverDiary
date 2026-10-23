-- Items looted, created or received
local ADDON, WFD = ...
local L = WFD.L
local time, format = time, string.format

local COLOR_QUALITY = {
    ["9d9d9d"] = 0, ["ffffff"] = 1, ["1eff00"] = 2, ["0070dd"] = 3, ["a335ee"] = 4, ["ff8000"] = 5,
}
WFD.qualityColors = {
    [0] = { 0.62, 0.62, 0.62 }, [1] = { 0.2, 0.2, 0.2 }, [2] = { 0.1, 0.55, 0.05 },
    [3] = { 0.0, 0.3, 0.75 }, [4] = { 0.55, 0.15, 0.75 }, [5] = { 0.8, 0.4, 0.0 },
}

-- The quality of an item: asked from the game first; otherwise read from the link, whose colour is written
-- "|cffa335ee" in older clients and "|cnIQ4:" in newer ones.
function WFD:ItemQuality(link, id)
    id = id or (type(link) == "string" and tonumber(link:match("item:(%d+)")))
    if id then
        local get = C_Item and C_Item.GetItemQualityByID
        if get then
            local ok, q = pcall(get, id)
            if ok and type(q) == "number" then return q end
        end
        local info = (C_Item and C_Item.GetItemInfo) or GetItemInfo
        if info then
            local ok, _, _, q = pcall(info, link or id)
            if ok and type(q) == "number" then return q end
        end
    end
    if type(link) ~= "string" then return 1 end
    local iq = tonumber(link:match("|cnIQ(%d+):"))
    if iq then return iq end
    return COLOR_QUALITY[link:match("|cff(%x%x%x%x%x%x)") or ""] or 1
end

local patterns
local function buildPatterns()
    patterns = {}
    local names = {
        "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_PUSHED_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF_MULTIPLE",
        "LOOT_ITEM_SELF", "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_CREATED_SELF",
    }
    for _, n in ipairs(names) do
        local gs = _G[n]
        if gs then
            patterns[#patterns + 1] = { WFD:Pattern(gs), n:find("MULTIPLE") ~= nil, n:find("CREATED") ~= nil }
        end
    end
end

WFD:On("CHAT_MSG_LOOT", function(_, msg)
    if WFD.paused or not WFD.C or type(msg) ~= "string" then return end
    if not patterns then buildPatterns() end
    local link, count, created
    for _, p in ipairs(patterns) do
        local a, b = msg:match(p[1])
        if a then
            link = a
            count = p[2] and tonumber(b) or 1
            created = p[3]
            break
        end
    end
    if not link then return end
    local id = tonumber(link:match("item:(%d+)"))
    if not id then return end
    local quality = WFD:ItemQuality(link, id)

    local C = WFD.C
    local d = WFD:Day()
    local entry = d.loot[id]
    if not entry then
        entry = { link = link, n = 0, q = quality }
        d.loot[id] = entry
    end
    entry.n = entry.n + (count or 1)
    local kill = WFD:LastKill()
    if kill and time() - kill.t < 20 and not created then
        entry.src = kill.name
        if WFD.NoteMobLoot then WFD:NoteMobLoot(kill.id, id, link, quality) end
    end
    C.itemTotal = (C.itemTotal or 0) + (count or 1)
    WFD:Signal("loot", link, quality, count or 1, id)

    if quality >= 2 then
        WFD:Log("loot", format(L["Found %s"], link))
    end
    if quality >= 3 then
        C.rares = C.rares or {}
        if not C.rares[id] then
            C.rares[id] = time()
            local name = WFD:ItemName(link)
            if quality >= 4 then
                WFD:Milestone("epic", format(L["Epic find: %s"], name), true, { item = id })
            else
                WFD:Milestone("rareitem", format(L["Rare find: %s"], name), true, { item = id })
            end
        end
    end
    WFD.dirty = true
end)

------------------------------------------------------------------------
-- Diaries written while the quality was read from the colour alone: newer clients write "|cnIQ2:"
-- instead of "|cff1eff00", so every item was kept as white. Once, the qualities are read again from the
-- links, and the rare finds missed are filled in quietly on their days (no chat line, no toast, no picture).
------------------------------------------------------------------------
WFD:OnInit(function()
    local C = WFD.C
    if not C or C.lootQ or WFD.demo then return end
    C.lootQ = true
    local found = {}        -- item id -> the earliest day it was found on
    for idx, d in pairs(C.days or {}) do
        for id, e in pairs(d.loot or {}) do
            if type(e) == "table" and type(e.link) == "string" then
                local q = WFD:ItemQuality(e.link, tonumber(id))
                e.q = q
                if q >= 3 then
                    local t = d.t0 or WFD:DayTime(idx)
                    if not found[id] or t < found[id].t then
                        found[id] = { t = t, day = idx, q = q, name = WFD:ItemName(e.link), item = tonumber(id) }
                    end
                end
            end
        end
    end
    for _, m in pairs(C.mobs or {}) do
        if type(m) == "table" and type(m.best) == "string" then m.bestQ = WFD:ItemQuality(m.best) end
    end
    local added = false
    C.rares = C.rares or {}
    C.events = C.events or {}
    for id, f in pairs(found) do
        if not C.rares[id] then
            C.rares[id] = f.t
            local text = format(f.q >= 4 and L["Epic find: %s"] or L["Rare find: %s"], f.name)
            C.events[#C.events + 1] = { t = f.t, day = f.day, k = f.q >= 4 and "epic" or "rareitem", s = text, item = f.item }
            added = true
        end
    end
    if added then
        table.sort(C.events, function(a, b) return (a.t or 0) < (b.t or 0) end)
        WFD.quietHonours = true     -- honours reached by these finds are taken over without a toast
    end
    WFD.dirty = true
end)
