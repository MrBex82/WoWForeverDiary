-- Which parts are still empty, and the figure of each part (Start, the register and the group overviews show them).
local ADDON, WFD = ...
local UI = WFD.UI

------------------------------------------------------------------------
-- Parts with nothing in them yet: dimmed in the contents and on the overview pages
------------------------------------------------------------------------
local EMPTY = {
    milestones = function(C) return #(C.events or {}) == 0 end,
    firsts = function(C) return next(C.firsts or {}) == nil end,
    gallery = function(C)
        for _, ev in ipairs(C.events or {}) do if ev.gear and next(ev.gear) then return false end end
        return true
    end,
    runs = function(C) return #(C.runs or {}) == 0 end,
    gathering = function(C) return next(C.gather or {}) == nil end,
    bestiary = function(C) return next(C.mobs or {}) == nil and next(C.sighted or {}) == nil end,
    nemesis = function(C) return next(C.nemesis or {}) == nil end,
    fates = function() return #WFD:Fates() == 0 end,
    fishbook = function(C) return next(C.catch or {}) == nil end,
    companions = function(C) return next(C.companions or {}) == nil and next(C.traders or {}) == nil end,
    capsule = function(C) return #(C.capsules or {}) == 0 end,
    stable = function(C) return next(C.mounts or {}) == nil end,
    standing = function(C) return next(C.rep or {}) == nil end,
    library = function() return #WFD:Library() == 0 end,
}
function UI.IsEmptyPart(key)
    local fn, C = EMPTY[key], WFD.C
    if not fn or not C then return false end
    local ok, v = pcall(fn, C)
    return ok and v == true
end

------------------------------------------------------------------------
-- The facing page of a group overview: one figure for each part, "at a glance"
------------------------------------------------------------------------
local function countOf(t)
    local n = 0
    for _ in pairs(t or {}) do n = n + 1 end
    return n
end
-- the figure of a part, or nil when it has none (then it gets no box)
local STAT = {
    tasks = function() local _, n = WFD:ChallengeStats() return n end,
    honour = function() local _, sum = WFD:HonourState() return sum.tiers .. "/" .. sum.totalTiers end,
    milestones = function(C) return #(C.events or {}) end,
    firsts = function(C) return countOf(C.firsts) .. "/" .. #(WFD.FIRSTS or {}) end,
    levels = function() return WFD:LevelAt(time()) end,
    atlas = function() local _, v, t = WFD:AtlasState() if (t or 0) > 0 then return v .. "/" .. t end end,
    landmarks = function() local _, f, t = WFD:LandmarkState() if (t or 0) > 0 then return f .. "/" .. t end end,
    gathering = function(C) local n = 0 for _, list in pairs(C.gather or {}) do n = n + #list end return n end,
    runs = function(C) return #(C.runs or {}) end,
    bestiary = function(C) local n = 0 for _, m in pairs(C.mobs or {}) do if (m.kills or 0) > 0 then n = n + 1 end end return n end,
    fates = function() return #WFD:Fates() end,
    nemesis = function(C) return countOf(C.nemesis) end,
    fishbook = function() return WFD:CatchSummary().species end,
    people = function(C) return countOf(C.npcs) end,
    companions = function(C) return countOf(C.companions) end,
    stable = function(C) return countOf(C.mounts) end,
    standing = function(C) return countOf(C.rep) end,
    ledger = function() local t = WFD:Totals() return WFD:CoinText(t.income - t.spend) end,
    family = function() return #WFD:Family() end,
    capsule = function(C) return #(C.capsules or {}) end,
    library = function() return #WFD:Library() end,
}

-- the figure of a part (nil when it has none), for Start and the register of the travel desk
function UI.PartStat(key)
    local fn = STAT[key]
    if not fn or not WFD.C then return nil end
    local ok, v = pcall(fn, WFD.C)
    if ok then return v end
end
