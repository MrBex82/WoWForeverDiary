-- Fates: every death with its moment, place, foe and level, for the page of fate.
-- Near misses are not kept: this client hands the player's health to addons as a secret value that cannot be
-- compared (checked in the game on 2026-10-23), so a narrow escape cannot be told from a scratch.
local ADDON, WFD = ...
local MAX_FATES = 500

-- Diaries begun before the fates were kept: the deaths of each day become entries once, with the place of the
-- grave and its killer where the day knows them (no exact time; the level is the one at the end of that day).
local function fromDays(C)
    local list, days = {}, {}
    for idx in pairs(C.days or {}) do days[#days + 1] = idx end
    table.sort(days)
    for _, idx in ipairs(days) do
        local d = C.days[idx]
        local n = d.deaths or 0
        local pos = d.dpos or {}
        -- older diaries kept the killers apart from the graves: they belong together only when both are complete
        local byList = (#(d.deathBy or {}) == n) and d.deathBy or nil
        for i = 1, n do
            local p = pos[i]
            local by = p and p[4] or (byList and byList[i]) or nil
            list[#list + 1] = {
                day = idx, map = p and p[1], x = p and p[2], y = p and p[3], by = by,
                zone = (p and p[1] and WFD:MapName(p[1])) or WFD:MainZone(d),
                level = WFD:LevelAt(WFD:DayTime(idx) + 43000), old = true,
            }
        end
    end
    while #list > MAX_FATES do table.remove(list, 1) end
    return list
end

-- all deaths, oldest first
function WFD:Fates()
    local C = self.C
    if not C then return {} end
    if not C.fates then
        local list = fromDays(C)
        if self.demo or self.paused then return list end    -- a demo builds its list each time, nothing is kept
        C.fates = list
    end
    return C.fates
end

-- a death as it happens (Tracker_Kills): the killer, if known, and the place of the grave
function WFD:NoteFate(by, map, x, y)
    local C = self.C
    if not C or self.paused or self.demo then return end
    -- not yet taken over from the days (normally done at login): the days already hold this death
    if not C.fates then self:Fates() return end
    local list = C.fates
    local group = GetNumGroupMembers and GetNumGroupMembers() or 0
    list[#list + 1] = {
        t = time(), day = self:DayIndex(), map = map, x = x, y = y, by = by,
        zone = self.zoneName, level = UnitLevel("player"), group = group > 0 and group or nil,
    }
    if #list > MAX_FATES then
        table.remove(list, 1)
        C.fatesDropped = (C.fatesDropped or 0) + 1
    end
    self.dirty = true
end

-- take the older deaths over at login, before a new one can be noted
WFD:OnInit(function() WFD:Fates() end)
