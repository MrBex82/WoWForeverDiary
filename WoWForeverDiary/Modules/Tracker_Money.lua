-- Income and expenses, sorted by what caused them
local ADDON, WFD = ...
local L = WFD.L
local GetTime, format = GetTime, string.format

local last
local ctx = {}   -- context name -> true (window open) or expiry time

local function open(name) ctx[name] = true end
local function close(name, grace)
    ctx[name] = grace and (GetTime() + grace) or nil
end
local function bump(name, secs) ctx[name] = GetTime() + secs end
local function active(name)
    local v = ctx[name]
    return v == true or (v ~= nil and v ~= false and v > GetTime())
end

local pairsToBind = {
    { "MERCHANT_SHOW", "MERCHANT_CLOSED", "merchant", 0 },
    { "MAIL_SHOW", "MAIL_CLOSED", "mail", 1 },
    { "TRADE_SHOW", "TRADE_CLOSED", "trade", 1 },
    { "AUCTION_HOUSE_SHOW", "AUCTION_HOUSE_CLOSED", "ah", 1 },
    { "TRAINER_SHOW", "TRAINER_CLOSED", "training", 0 },
    { "TAXIMAP_OPENED", "TAXIMAP_CLOSED", "flight", 4 },
    { "BANKFRAME_OPENED", "BANKFRAME_CLOSED", "bank", 0 },
    { "QUEST_COMPLETE", "QUEST_FINISHED", "quest", 4 },
    { "LOOT_OPENED", "LOOT_CLOSED", "loot", 1.5 },
}
for _, p in ipairs(pairsToBind) do
    local name, grace = p[3], p[4]
    WFD:On(p[1], function() open(name) end)
    WFD:On(p[2], function() close(name, grace > 0 and grace or nil) end)
end

WFD:On("CHAT_MSG_MONEY", function() bump("loot", 2) end)

if hooksecurefunc then
    if RepairAllItems then pcall(hooksecurefunc, "RepairAllItems", function() bump("repair", 3) end) end
    if TakeTaxiNode then
        pcall(hooksecurefunc, "TakeTaxiNode", function(i)
            bump("flight", 4)
            -- only the destination is noted here; the flight counts once the character is in the air
            WFD.flightDest = TaxiNodeName and TaxiNodeName(i) or nil
        end)
    end
end

local function classify(delta)
    if delta < 0 then
        if active("repair") then return "repair" end
        if active("flight") then return "flight" end
        if active("training") then return "training" end
        if active("merchant") then return "vendor" end
        if active("mail") then return "mail" end
        if active("trade") then return "trade" end
        if active("ah") then return "ah" end
        if active("bank") then return "bank" end
        return "other"
    end
    if active("merchant") then return "sell" end
    if active("mail") then return "mail" end
    if active("trade") then return "trade" end
    if active("ah") then return "ah" end
    if active("quest") then return "quest" end
    if active("loot") then return "loot" end
    return "other"
end

WFD.moneyCats = {
    "loot", "quest", "sell", "mail", "trade", "ah", "repair", "vendor", "training", "flight", "bank", "other",
}

local WEALTH_STEPS = { 10000, 100000, 500000, 1000000, 5000000, 10000000 }

WFD:OnInit(function()
    last = GetMoney()
    -- a character that already had money when the diary began: the steps it had passed are taken over
    -- quietly, instead of all of them at once at the first coin
    local C = WFD.C
    if C and (C.wealth or 0) == 0 and not C.fresh then
        for _, step in ipairs(WEALTH_STEPS) do
            if last >= step then C.wealth = step end
        end
    end
    -- moments written with the short coin ("50G") get the words of the game ("50 Gold"), once
    if C and not C.wealthWords and not WFD.demo then
        for _, ev in ipairs(C.events or {}) do
            if ev.k == "wealth" and type(ev.s) == "string" then
                for i = #WEALTH_STEPS, 1, -1 do
                    local short = WFD:CoinText(WEALTH_STEPS[i])
                    local a, b = ev.s:find(short, 1, true)
                    if a then
                        ev.s = ev.s:sub(1, a - 1) .. WFD:CoinWords(WEALTH_STEPS[i]) .. ev.s:sub(b + 1)
                        break
                    end
                end
            end
        end
        C.wealthWords = true
    end
end)

WFD:On("PLAYER_MONEY", function()
    if not WFD.C or not last then return end
    local now = GetMoney()
    local delta = now - last
    last = now
    if WFD.paused or delta == 0 then return end

    local d = WFD:Day()
    d.g0 = d.g0 or (now - delta)
    d.g1 = now
    local cat = classify(delta)
    if cat == "trade" and WFD.TradeMoney then WFD:TradeMoney(delta) end
    if delta > 0 then
        d.income[cat] = (d.income[cat] or 0) + delta
    else
        d.spend[cat] = (d.spend[cat] or 0) - delta
    end

    local C = WFD.C
    for _, step in ipairs(WEALTH_STEPS) do
        if now >= step and C.wealth < step then
            C.wealth = step
            WFD:Milestone("wealth", format(L["Wealth reached: %s"], WFD:CoinWords(step)), false)
        end
    end
    WFD.dirty = true
end)

-- first money snapshot of each day
WFD:On("PLAYER_ENTERING_WORLD", function()
    if not WFD.C or WFD.paused then return end
    local d = WFD:Day()
    local now = GetMoney()
    d.g0 = d.g0 or now
    d.g1 = now
    last = now
end)
