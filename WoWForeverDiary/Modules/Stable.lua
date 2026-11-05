-- Mounts: the first one, and every one after it, with the day and place it was first ridden and how often.
-- Classic has no list of mounts to read, so a mount is recognised by the spell that put the player on it:
-- a spell that succeeds and leaves the player mounted a moment later.
local ADDON, WFD = ...
local time = time

local lastNoted = 0

local function iconOf(spellID)
    local tex
    if C_Spell and C_Spell.GetSpellTexture then
        local ok, t = pcall(C_Spell.GetSpellTexture, spellID)
        if ok then tex = t end
    end
    if not tex and GetSpellTexture then
        local ok, t = pcall(GetSpellTexture, spellID)
        if ok then tex = t end
    end
    return tex
end

local function noteMount(spellID)
    local C = WFD.C
    if not C or WFD.paused or WFD.demo then return end
    local now = time()
    if now - lastNoted < 3 then return end       -- one ride, however many events the game sends for it
    local name = WFD:SpellName(spellID)
    if not name then return end
    lastNoted = now
    C.mounts = C.mounts or {}
    local e = C.mounts[spellID]
    if not e then
        e = { name = name, icon = iconOf(spellID), first = now, day = WFD:DayIndex(now), zone = WFD.zoneName, rides = 0 }
        C.mounts[spellID] = e
    end
    e.rides = (e.rides or 0) + 1
    e.last = now
    WFD.dirty = true
end

local function mounted() return IsMounted and IsMounted() or false end

WFD:On("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
    if unit ~= "player" or not spellID or not (C_Timer and C_Timer.After) then return end
    if mounted() or (UnitOnTaxi and UnitOnTaxi("player")) then return end
    C_Timer.After(0.6, function()
        if mounted() and not (UnitOnTaxi and UnitOnTaxi("player")) then noteMount(spellID) end
    end)
end)

-- the mounts, most ridden first
function WFD:Mounts()
    local list = {}
    for id, e in pairs(self.C and self.C.mounts or {}) do
        list[#list + 1] = { id = id, e = e }
    end
    table.sort(list, function(a, b)
        if (a.e.rides or 0) ~= (b.e.rides or 0) then return (a.e.rides or 0) > (b.e.rides or 0) end
        return (a.e.first or 0) < (b.e.first or 0)
    end)
    return list
end
