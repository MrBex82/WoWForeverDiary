-- The family book: a short summary of every character on this account, kept in the account-wide settings,
-- so each diary can show its brothers and sisters - and who got where first.
local ADDON, WFD = ...

function WFD:FamilyKey()
    local C = self.C
    return (C and C.realm or GetRealmName() or "?") .. "-" .. (C and C.name or UnitName("player") or "?")
end

local function update()
    local C, S = WFD.C, WFD.S
    if not C or not S or WFD.demo or WFD.paused then return end
    S.family = S.family or {}
    local kills, deaths, steps, online = 0, 0, 0, 0
    for _, d in pairs(C.days) do
        kills = kills + (d.killTotal or 0)
        deaths = deaths + (d.deaths or 0)
        steps = steps + (d.steps or 0)
        online = online + (d.online or 0)
    end
    local _, sum = WFD:HonourState()
    -- on which diary day each first time and every tenth level came
    local firsts, levels = {}, {}
    for k, f in pairs(C.firsts or {}) do firsts[k] = f.day end
    for lvl, t in pairs(C.levelTimes or {}) do
        if lvl % 10 == 0 then levels[lvl] = WFD:DayIndex(t) end
    end
    S.family[WFD:FamilyKey()] = {
        name = C.name, realm = C.realm, class = C.class, classFile = C.classFile, race = C.race,
        faction = UnitFactionGroup and UnitFactionGroup("player"), level = UnitLevel("player"),
        born = C.born, days = WFD:NumDays(), kills = kills, deaths = deaths, quests = C.questTotal or 0,
        km = steps * 0.9144 / 1000, online = online, points = sum and sum.points or 0,
        firsts = firsts, levels = levels, dead = C.obituary and true or nil, last = time(),
        titleKey = select(2, WFD:Title()),
    }
end
WFD.UpdateFamily = function() pcall(update) end

WFD:OnInit(function()
    if C_Timer and C_Timer.After then
        C_Timer.After(15, function() pcall(update) end)
        C_Timer.NewTicker(300, function() pcall(update) end)
    end
end)
WFD:On("PLAYER_LOGOUT", function() pcall(update) end)
WFD:On("PLAYER_LEVEL_UP", function()
    if C_Timer and C_Timer.After then C_Timer.After(2, function() pcall(update) end) end
end)

-- every character, the current one first, then by level
function WFD:Family()
    local list = {}
    local me = self:FamilyKey()
    local family = self.demo and (self.C and self.C.demoFamily) or (self.S and self.S.family) or {}
    for key, e in pairs(family) do
        list[#list + 1] = { key = key, e = e, me = (key == me) }
    end
    table.sort(list, function(a, b)
        if a.me ~= b.me then return a.me end
        if (a.e.level or 0) ~= (b.e.level or 0) then return (a.e.level or 0) > (b.e.level or 0) end
        return (a.e.name or "") < (b.e.name or "")
    end)
    return list
end
