-- Footsteps, distance, time online and time per zone
local ADDON, WFD = ...
local sqrt, format = math.sqrt, string.format
local L = WFD.L

local lastPos
local acc = 0
local inAir = false      -- on a flight path right now

local function worldPos(map, x, y)
    if not (C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D) then return end
    local cont, pos = C_Map.GetWorldPosFromMapPos(map, CreateVector2D(x, y))
    if not pos then return end
    local px, py = pos:GetXY()
    return cont, px, py
end

local function Tick(el)
    if WFD.paused or not WFD.C then return end
    local d = WFD:Day()
    d.online = d.online + el
    -- when in the day the adventure happened (for the mood of the entry)
    local now = time()
    d.t0 = d.t0 or now
    d.t1 = now
    d.hours = d.hours or {}
    local h = tonumber(date("%H", now))
    d.hours[h] = (d.hours[h] or 0) + el
    -- time in a land counts only on the ground: the lands below a flight path are not visited
    local onTaxi = UnitOnTaxi and UnitOnTaxi("player") or false
    local zone = WFD.zoneName
    if zone and zone ~= "" and not onTaxi then
        d.zones[zone] = (d.zones[zone] or 0) + el
    end

    -- landed: the land you are in now is checked at once (it may be new)
    if inAir and not onTaxi then
        if WFD.RefreshZone then
            local ok, err = pcall(WFD.RefreshZone)
            if not ok then WFD:Error("zone", err) end
        end
        WFD:Signal("landed")
    end

    -- a flight is counted when it begins, not when a destination was clicked
    if onTaxi and not inAir then
        d.flights = (d.flights or 0) + 1
        local dest = WFD.flightDest and WFD.flightDest:gsub(",.*$", "") or "?"
        WFD:Log("flight", format(L["Took a flight to %s"], dest))
        WFD.flightDest = nil
    end
    inAir = onTaxi

    local map, x, y = WFD:PlayerPos()
    if not map then
        lastPos = nil
        return
    end
    WFD.curMap = map
    -- which map belongs to which zone name: lets the diary rename places when the game language changes
    if zone and zone ~= "" then
        local C = WFD.C
        C.zoneMaps = C.zoneMaps or {}
        C.zoneMaps[zone] = C.zoneMaps[zone] or map
    end

    local p = d.path[map]
    if type(p) == "string" then         -- a packed day walked again: back to a table
        local t = {}
        for k, v in pairs(WFD:PathCells(p)) do t[k] = v end
        p = t
        d.path[map] = p
    elseif not p then
        p = {}
        d.path[map] = p
    end
    local key = WFD:CellKey(x, y)
    p[key] = (p[key] or 0) + 1

    local ok, cont, wx, wy = pcall(worldPos, map, x, y)
    if ok and cont and lastPos and lastPos.cont == cont then
        local dx, dy = wx - lastPos.wx, wy - lastPos.wy
        local dist = sqrt(dx * dx + dy * dy)
        if dist < 600 then
            if onTaxi then
                d.flown = (d.flown or 0) + dist
            else
                d.steps = d.steps + dist
            end
        end
    end
    if ok and cont then
        lastPos = { cont = cont, wx = wx, wy = wy }
    else
        lastPos = nil
    end
    WFD.ticked = true
end

WFD:OnInit(function()
    local ok, err = pcall(WFD.PackOldDays, WFD)
    if not ok then WFD:Error("pack", err) end
    local f = CreateFrame("Frame")
    f:SetScript("OnUpdate", function(_, dt)
        acc = acc + dt
        if acc < 2 then return end
        local el = acc
        acc = 0
        if el > 10 then el = 10 end
        local ok, err = pcall(Tick, el)
        if not ok then WFD:Error("path", err) end
    end)
end)

-- Fun statistic: how often did you jump?
if hooksecurefunc then
    pcall(hooksecurefunc, "JumpOrAscendStart", function()
        if WFD.ready and not WFD.paused then
            local d = WFD:Day()
            d.jumps = d.jumps + 1
        end
    end)
end
