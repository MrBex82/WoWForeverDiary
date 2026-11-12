-- The time behind the chronicle: played time at a moment, and how long each level took.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

local GOLD = { 0.86, 0.62, 0.18, 1 }
local RED = { 0.75, 0.24, 0.16, 1 }
local GREEN = UI.c.good

local function empty(pool, canvas, tx, tw, y, text)
    local e = pool:Text(13, c.inkFaint, UI.FONT, "CENTER")
    e:SetText(text)
    e:SetWidth(tw)
    e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
end

-- a row of figures in light boxes: { value, label, colour }
local function tiles(...) return UI.Tiles(...) end

local function caption(pool, canvas, x, y, text)
    local t = pool:Text(9, c.redInk, UI.FONT)
    t:SetText(text:upper())
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
end

------------------------------------------------------------------------
-- Time in the world when a moment happened (played seconds)
------------------------------------------------------------------------
function WFD:PlayedAt(t)
    local C = self.C
    local di = self:DayIndex(t)
    local total = 0
    for d = 1, di - 1 do
        local day = C.days[d]
        if day then total = total + (day.online or 0) end
    end
    local day = C.days[di]
    if day and day.t0 and day.t1 and day.t1 > day.t0 then
        total = total + (day.online or 0) * max(0, min(1, (t - day.t0) / (day.t1 - day.t0)))
    end
    return total
end

-- { { level, secs, day, running } } for every level whose start and end are known
function WFD:LevelSteps()
    local C = self.C
    local reach, levels = {}, {}
    for lvl, t in pairs(C.levelTimes or {}) do
        reach[lvl] = (C.levelPlayed and C.levelPlayed[lvl]) or self:PlayedAt(t)
        levels[#levels + 1] = lvl
    end
    table.sort(levels)
    local steps = {}
    for i = 1, #levels - 1 do
        local a, b = levels[i], levels[i + 1]
        if b == a + 1 then
            steps[#steps + 1] = { level = a, secs = max(0, reach[b] - reach[a]), day = self:DayIndex(C.levelTimes[b]) }
        end
    end
    local top = levels[#levels]
    if top then
        local total = 0
        for _, day in pairs(C.days) do total = total + (day.online or 0) end
        steps[#steps + 1] = { level = top, secs = max(0, total - reach[top]), running = true }
    end
    return steps
end

-- (records, the level timeline and the gallery are views of the travel desk now: UI/Views/Chronicle.lua)
