-- Everyone you talk to: quest givers, vendors, trainers, flight masters ...
local ADDON, WFD = ...
local L = WFD.L
local time, format = time, string.format

local lastTalk = {}

local function interact(role)
    if WFD.paused or not WFD.C then return end
    local guid = UnitGUID("npc")
    local kind, id = WFD:ParseGUID(guid)
    if not id or (kind ~= "Creature" and kind ~= "GameObject") then return end
    local name = UnitName("npc")
    if not name or name == "" then return end

    local key = (kind == "Creature") and id or ("o" .. id)
    local C = WFD.C
    local n = C.npcs[key]
    local isNew = false
    if not n then
        n = { name = name, talks = 0, first = time(), roles = {}, obj = (kind == "GameObject") or nil }
        C.npcs[key] = n
        isNew = true
    end
    n.roles[role] = true
    n.last = time()
    n.zone = WFD.zoneName or n.zone
    n.sub = GetSubZoneText() or n.sub
    local map, x, y = WFD:PlayerPos()
    if map then n.map, n.x, n.y = map, x, y end

    WFD.lastNPC = { key = key, name = name, t = time() }

    if not lastTalk[key] or time() - lastTalk[key] > 60 then
        lastTalk[key] = time()
        n.talks = n.talks + 1
        local d = WFD:Day()
        d.npcs[key] = (d.npcs[key] or 0) + 1
        if isNew then
            WFD:Log("npc", format(L["Met %s (%s)"], name, n.zone or "?"))
            C.npcCount = (C.npcCount or 0) + 1
        end
        WFD.dirty = true
    end
end

local function bind(event, role)
    WFD:On(event, function() interact(role) end)
end

bind("GOSSIP_SHOW", "talk")
bind("QUEST_GREETING", "quest")
bind("QUEST_DETAIL", "quest")
bind("QUEST_PROGRESS", "quest")
bind("QUEST_COMPLETE", "quest")
bind("MERCHANT_SHOW", "merchant")
bind("TRAINER_SHOW", "trainer")
bind("TAXIMAP_OPENED", "flight")
bind("BANKFRAME_OPENED", "bank")
bind("PET_STABLE_SHOW", "stable")
bind("PETITION_SHOW", "petition")
bind("AUCTION_HOUSE_SHOW", "auction")

-- Flight paths the character knows: every flight master's map shows those of its continent.
WFD:On("TAXIMAP_OPENED", function()
    local C = WFD.C
    if WFD.paused or not C or not (NumTaxiNodes and TaxiNodeName and TaxiNodeGetType) then return end
    C.taxiNodes = C.taxiNodes or {}
    for i = 1, NumTaxiNodes() do
        local kind = TaxiNodeGetType(i)
        if kind == "CURRENT" or kind == "REACHABLE" then
            local name = TaxiNodeName(i)
            if name and name ~= "" then C.taxiNodes[name] = true end
        end
    end
    WFD.dirty = true
end)

-- Remember where the hearthstone is bound.
WFD:On("CONFIRM_BINDER", function(_, loc)
    WFD.pendingBind = loc
end)
WFD:On("CHAT_MSG_SYSTEM", function(_, msg)
    if WFD.paused or not WFD.C or type(msg) ~= "string" then return end
    local p = WFD.bindPattern
    if p == nil then
        p = ERR_DEATHBIND_SUCCESS_S and WFD:Pattern(ERR_DEATHBIND_SUCCESS_S) or false
        WFD.bindPattern = p
    end
    if p then
        local loc = msg:match(p)
        if loc then
            WFD.C.bind = loc
            WFD:Log("bind", format(L["Hearthstone bound to %s"], loc))
        end
    end
end)
