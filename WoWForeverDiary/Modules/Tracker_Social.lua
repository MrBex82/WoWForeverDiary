-- Companions (group members), trading partners, resting places and the hardcore obituary
local ADDON, WFD = ...
local L = WFD.L
local time, format = time, string.format

------------------------------------------------------------------------
-- Companions
------------------------------------------------------------------------
local current = {}      -- key -> true while grouped right now

-- battlegrounds and arenas throw strangers together by the dozen: they are no companions
local function inPvP()
    local _, kind = IsInInstance()
    if kind == "pvp" or kind == "arena" then return true end
    -- other ways the game tells a battleground apart, also while the map is still loading
    if UnitInBattleground and UnitInBattleground("player") then return true end
    if C_PvP and C_PvP.IsPVPMap and C_PvP.IsPVPMap() then return true end
    if IsActiveBattlefieldArena and IsActiveBattlefieldArena() then return true end
    return false
end

local function roster()
    if WFD.paused or not WFD.C then return end
    if inPvP() then
        current = {}
        return
    end
    local C = WFD.C
    C.companions = C.companions or {}
    local now, day = time(), WFD:DayIndex()
    local seen = {}
    local n = GetNumGroupMembers and GetNumGroupMembers() or 0
    local raid = IsInRaid and IsInRaid()
    local count = raid and n or math.max(0, n - 1)
    for i = 1, count do
        local unit = (raid and "raid" or "party") .. i
        if UnitExists(unit) and UnitIsPlayer(unit) and not UnitIsUnit(unit, "player") then
            local name, realm = UnitName(unit)
            if name and name ~= "" and name ~= UNKNOWNOBJECT then
                local key = (realm and realm ~= "") and (name .. "-" .. realm) or name
                seen[key] = true
                local e = C.companions[key]
                if not e then
                    e = { first = now, days = {}, kills = 0, groups = 0 }
                    C.companions[key] = e
                    WFD:Log("companion", format(L["Grouped with %s"], name))
                end
                if not current[key] then e.groups = e.groups + 1 end
                e.name = name
                e.class, e.classFile = UnitClass(unit)
                local lvl = UnitLevel(unit)
                if lvl and lvl > 0 then e.level = lvl end
                e.last = now
                e.days[day] = true
                e.zone = WFD.zoneName or e.zone
            end
        end
    end
    current = seen
    WFD.dirty = true
end

-- Companions gathered in battlegrounds before they were left out: they are found by the place they were last met
local PVP_PLACES = {
    "Warsong Gulch", "Arathi Basin", "Alterac Valley", "Eye of the Storm", "Strand of the Ancients", "Isle of Conquest",
    "Twin Peaks", "The Battle for Gilneas", "Blade's Edge Arena", "Nagrand Arena", "Ruins of Lordaeron",
    "Kriegshymnenschlucht", "Arathibecken", "Alteractal", "Auge des Sturms", "Strand der Uralten", "Insel der Eroberung",
    "Zwillingsgipfel", "Schlacht um Gilneas", "Arena des Schergrats", "Arena von Nagrand", "Ruinen von Lordaeron",
}

local function pvpPlaces()
    local set = {}
    for _, n in ipairs(PVP_PLACES) do set[n] = true end
    -- the game's own names for the client's language
    if GetNumBattlegroundTypes and GetBattlegroundInfo then
        for i = 1, GetNumBattlegroundTypes() do
            local name = GetBattlegroundInfo(i)
            if type(name) == "string" and name ~= "" then set[name] = true end
        end
    end
    return set
end

-- "/wfd cleanup": first only counts, "/wfd cleanup yes" removes. Friends met often elsewhere stay.
function WFD:CleanCompanions(doIt)
    local C = self.C
    if not C or not C.companions then return 0 end
    local places, drop = pvpPlaces(), {}
    for key, e in pairs(C.companions) do
        local days = 0
        for _ in pairs(e.days or {}) do days = days + 1 end
        local groups = e.groups or 0
        -- met in a battleground, or a stranger of a single group who never stood beside you for one kill
        -- (the place is that of the last meeting, which may be the city after the battleground)
        if (places[e.zone or ""] and groups <= 2) or ((e.kills or 0) == 0 and groups <= 1 and days <= 1) then
            drop[#drop + 1] = key
        end
    end
    table.sort(drop)
    if doIt then
        for _, key in ipairs(drop) do C.companions[key] = nil end
        if #drop > 0 then
            self.dirty = true
            if self.UI and self.UI.ClearCaches then self.UI.ClearCaches() end
        end
    end
    return #drop, drop
end

WFD:On("GROUP_ROSTER_UPDATE", roster)
WFD:On("PLAYER_ENTERING_WORLD", roster)

-- called by the kill tracker: every kill also counts for the people at your side
function WFD:CreditCompanions()
    local C = self.C
    if not C or not C.companions then return end
    for key in pairs(current) do
        local e = C.companions[key]
        if e then e.kills = e.kills + 1 end
    end
end

------------------------------------------------------------------------
-- Trading partners
------------------------------------------------------------------------
WFD:On("TRADE_SHOW", function()
    if WFD.paused or not WFD.C then return end
    local name = UnitName("NPC") or UnitName("npc")
    if not name then return end
    local C = WFD.C
    C.traders = C.traders or {}
    local t = C.traders[name]
    if not t then
        t = { first = time(), count = 0, got = 0, gave = 0 }
        C.traders[name] = t
    end
    t.count = t.count + 1
    t.last = time()
    t.zone = WFD.zoneName
    WFD.tradePartner = name
end)
WFD:On("TRADE_CLOSED", function()
    C_Timer.After(2, function() WFD.tradePartner = nil end)
end)

-- the money tracker reports trade money here
function WFD:TradeMoney(delta)
    local C = self.C
    local name = self.tradePartner
    if not (C and C.traders and name and C.traders[name]) then return end
    local t = C.traders[name]
    if delta > 0 then t.got = t.got + delta else t.gave = t.gave - delta end
end

------------------------------------------------------------------------
-- Resting places: where you logged out at an inn or in a city
------------------------------------------------------------------------
WFD:On("PLAYER_LOGOUT", function()
    local C = WFD.C
    if not C or WFD.paused or WFD.demo then return end
    C.lastLogout = time()
    if IsResting and IsResting() then
        C.rests = C.rests or {}
        local map, x, y = WFD:PlayerPos()
        C.rests[#C.rests + 1] = { t = time(), map = map, x = x, y = y, zone = WFD.zoneName, sub = GetSubZoneText() }
    end
end)

WFD:OnInit(function()
    local C = WFD.C
    local last = C.rests and C.rests[#C.rests]
    if last and not last.dur and C.lastLogout and last.t == C.lastLogout then
        last.dur = time() - C.lastLogout
    end
end)

------------------------------------------------------------------------
-- Hardcore: a death is final, the diary writes an obituary
------------------------------------------------------------------------
function WFD:IsHardcore()
    return C_GameRules and C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive() or false
end

function WFD:WriteObituary(by)
    local C = self.C
    if not C or C.obituary or self.paused then return end
    local map, x, y = self:PlayerPos()
    C.obituary = {
        t = time(), day = self:DayIndex(), level = UnitLevel("player"), zone = self.zoneName,
        sub = GetSubZoneText(), by = by, map = map, x = x, y = y, gear = self:CaptureGear(),
    }
    self.dirty = true
end
