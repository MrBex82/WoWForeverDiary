-- Reputation: when each faction reached the next standing. The list is read from the game's reputation pane
-- (folded-up headings hide their factions), so a rise is noted when it is seen, not backdated.
-- The standing a faction had when it was first seen is kept apart, as where it began.
local ADDON, WFD = ...
local time, date = time, date

local pending
local function scan()
    pending = false
    local C = WFD.C
    if not C or WFD.paused or WFD.demo or not (GetNumFactions and GetFactionInfo) then return end
    C.rep = C.rep or {}
    local now = time()
    for i = 1, GetNumFactions() do
        local name, _, standing, _, _, _, _, _, isHeader, _, hasRep = GetFactionInfo(i)
        if name and type(standing) == "number" and standing > 0 and (not isHeader or hasRep) then
            local e = C.rep[name]
            if not e then
                C.rep[name] = { first = now, day = WFD:DayIndex(now), st0 = standing, st = standing, reached = {} }
                WFD.dirty = true
            else
                e.reached = e.reached or {}
                if standing > (e.st or 0) then
                    e.reached[standing] = e.reached[standing] or now
                    WFD.dirty = true
                end
                e.st = standing
            end
        end
    end
end

local function later(seconds)
    C_Timer.After(seconds, function()
        local ok, err = pcall(scan)
        if not ok then WFD:Error("reputation", err) end
    end)
end

WFD:On("UPDATE_FACTION", function()
    if pending or not (C_Timer and C_Timer.After) then return end
    pending = true
    later(1)
end)

WFD:OnInit(function()
    if C_Timer and C_Timer.After then later(5) end
end)

-- the game's own word for a standing (Hated ... Exalted)
function WFD:StandingName(id)
    return _G["FACTION_STANDING_LABEL" .. tostring(id)] or tostring(id)
end

-- the factions: highest standing first
function WFD:Factions()
    local list = {}
    for name, e in pairs(self.C and self.C.rep or {}) do list[#list + 1] = { name = name, e = e } end
    table.sort(list, function(a, b)
        if (a.e.st or 0) ~= (b.e.st or 0) then return (a.e.st or 0) > (b.e.st or 0) end
        return a.name < b.name
    end)
    return list
end

-- steps up seen in a calendar year
function WFD:RepSteps(year)
    local n = 0
    for _, e in pairs(self.C and self.C.rep or {}) do
        for _, t in pairs(e.reached or {}) do
            if date("*t", t).year == year then n = n + 1 end
        end
    end
    return n
end
