-- A line in the item tooltip: when the diary first saw you find this item, and from whom.
-- It only reads what the loot tracker has kept on the days; nothing is recorded here.
local ADDON, WFD = ...
local L = WFD.L

-- item id -> { day, src, n }, built from the days and rebuilt when something new was looted
local index, indexKey

local function build()
    local C = WFD.C
    local key = (C.itemTotal or 0) .. ":" .. WFD:NumDays()
    if index and indexKey == key then return index end
    index, indexKey = {}, key
    for idx = 1, WFD:NumDays() do
        local d = C.days[idx]
        if d and d.loot then
            for id, e in pairs(d.loot) do
                local at = index[id]
                if not at then
                    at = { day = idx, src = e.src, n = 0 }
                    index[id] = at
                end
                at.n = at.n + (e.n or 0)
            end
        end
    end
    return index
end

local function addLine(tip, id)
    local C, S = WFD.C, WFD.S
    if not (C and S) or WFD.paused or WFD.demo or S.itemTip == false or not id then return end
    local at = build()[id]
    if not at then return end
    local text = format(L["In the diary: first found on %s"], WFD:DateStr(at.day))
    if at.src then text = text .. "  -  " .. format(L["from %s"], at.src) end
    tip:AddLine(text, 0.78, 0.66, 0.36)
    tip:Show()
end

local function itemIdOf(tip)
    local _, link = tip:GetItem()
    return link and tonumber(link:match("item:(%d+)"))
end

WFD:OnInit(function()
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tip, data)
            if tip ~= GameTooltip and tip ~= ItemRefTooltip then return end
            pcall(addLine, tip, data and data.id)
        end)
    else
        for _, tip in ipairs({ GameTooltip, ItemRefTooltip }) do
            if tip and tip.HookScript then
                tip:HookScript("OnTooltipSetItem", function(self) pcall(function() addLine(self, itemIdOf(self)) end) end)
            end
        end
    end
end)
