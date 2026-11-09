-- Treasures and the book of honour on the travel desk: lists in groups, with chips and an order. A treasure shows
-- its item in the tooltip and leads to the day it was found; an honour has two visible buttons, one for your
-- title and one for the showcase (no hidden right-click any more).
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

-- (labels are keys, translated when the view is built:
-- L["Uncommon"] L["Rare"] L["Epic"] L["Legendary"] L["Best per slot"] L["Worn now"] L["By slot"] L["Best first"]
-- L["Newest first"] L["Earned"] L["In progress"] L["Secret"] L["By category"] L["Closest to the next tier"] L["All"])

local function matches(q, ...)
    if not q or q == "" then return true end
    for i = 1, select("#", ...) do
        local s = select(i, ...)
        if s and tostring(s):lower():find(q, 1, true) then return true end
    end
    return false
end

local function openDay(day)
    local p = day and UI.book and UI.book.dayPage[day]
    if p then UI:OpenBook(p) end
end

------------------------------------------------------------------------
-- Treasures
------------------------------------------------------------------------
UI.PART_VIEW.treasures = "treasures"

local function makeItemRow(parent)
    local r = K.Box(parent, nil, nil, "Button")
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r.frame = K.Box(r, nil, nil)
    r.frame:SetSize(34, 34)
    r.frame:SetPoint("LEFT", 8, 0)
    r.icon = r.frame:CreateTexture(nil, "ARTWORK")
    r.icon:SetPoint("TOPLEFT", 2, -2)
    r.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.worn = K.Glyph(r.frame, "check", 12, "pos")
    r.worn:SetPoint("TOPRIGHT", 4, 4)
    r.count = K.Text(r, "strong", "soft", "RIGHT")
    r.count:SetPoint("RIGHT", -12, 0)
    r.name = K.Text(r, "strong", "ink")
    r.name:SetPoint("TOPLEFT", r.frame, "TOPRIGHT", 10, -1)
    r.name:SetWordWrap(false)
    r.sub = K.Text(r, "small", "muted")
    r.sub:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3)
    r.sub:SetWordWrap(false)
    r:SetScript("OnEnter", function(self)
        self:SetSurface("hover")
        if self.link then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if not pcall(GameTooltip.SetHyperlink, GameTooltip, self.link) then GameTooltip:SetText(self.name:GetText() or "?") end
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["Click to read that day."], 0.5, 0.8, 1)
            if self.mob then GameTooltip:AddLine(L["Right-click for the wanted poster."], 0.5, 0.8, 1) end
            GameTooltip:Show()
        end
    end)
    r:SetScript("OnLeave", function(self) self:SetSurface(nil) GameTooltip:Hide() end)
    r:SetScript("OnClick", function(self, button)
        if button == "RightButton" and self.mob then UI:OpenShell({ view = "bestiary", key = self.mob }) return end
        openDay(self.day)
    end)
    return r
end

local function treasureData(state)
    local list = UI.TreasureList()
    local worn = UI.WornNow()
    local chip, q = state.chip, state.q
    local out = {}
    if chip == "best" then
        -- the best find for every place on the doll: the highest quality, the latest of those
        local best = {}
        for _, a in ipairs(list) do
            if a.slot then
                local b = best[a.slot]
                if not b or a.q > b.q or (a.q == b.q and a.day > b.day) then best[a.slot] = a end
            end
        end
        for _, a in pairs(best) do out[#out + 1] = a end
    else
        for _, a in ipairs(list) do
            local qq = min(5, a.q)
            local ok = chip == "all" or (chip == "worn" and worn[a.id]) or tonumber(chip) == qq
            if ok then out[#out + 1] = a end
        end
    end
    local filtered = {}
    for _, a in ipairs(out) do
        a.worn = worn[a.id]
        if matches(q, WFD:ItemName(a.link), a.src, a.gname) then filtered[#filtered + 1] = a end
    end
    if state.sort == "new" then
        table.sort(filtered, function(a, b) return a.day > b.day end)
        return { { items = filtered } }
    elseif state.sort == "best" then
        table.sort(filtered, function(a, b)
            if a.q ~= b.q then return a.q > b.q end
            return a.day > b.day
        end)
        return { { items = filtered } }
    end
    -- by slot, in the order of the character sheet; the best of a slot first
    table.sort(filtered, function(a, b)
        if a.rank ~= b.rank then return a.rank < b.rank end
        if a.q ~= b.q then return a.q > b.q end
        return a.day < b.day
    end)
    local groups, by = {}, {}
    for _, a in ipairs(filtered) do
        local g = by[a.gkey]
        if not g then
            g = { title = a.gname, items = {} }
            by[a.gkey] = g
            groups[#groups + 1] = g
        end
        g.items[#g.items + 1] = a
    end
    for _, g in ipairs(groups) do g.right = tostring(#g.items) end
    return groups
end

UI.CollectionView({
    key = "treasures", label = "Treasures", group = "hunt",
    chips = { { "all", "All" }, { "best", "Best per slot" }, { "worn", "Worn now" }, { "2", "Uncommon" }, { "3", "Rare" },
        { "4", "Epic" }, { "5", "Legendary" } },
    sorts = { { "slot", "By slot" }, { "best", "Best first" }, { "new", "Newest first" } },
    summary = function()
        local counts, total = {}, 0
        for _, a in ipairs(UI.TreasureList()) do
            local q = min(5, a.q)
            counts[q] = (counts[q] or 0) + 1
            total = total + 1
        end
        local out = { { total, L["Treasures"] } }
        for q = 2, 5 do
            local ink = UI.TreasureInk(q)
            out[#out + 1] = { "|cff" .. UI.Hex(ink) .. (counts[q] or 0) .. "|r", UI.QualityName(q) }
        end
        return out
    end,
    data = treasureData,
    row = {
        h = 46,
        make = makeItemRow,
        fill = function(r, item)
            local a = item.entry
            local q = min(5, a.q)
            local fr = UI.TreasureFrame[q] or { 0.5, 0.5, 0.5, 1 }
            r.frame.bgKey, r.frame.borderKey = "inset", nil
            K.Repaint(r.frame)
            r.frame:SetBackdropBorderColor(fr[1], fr[2], fr[3], 1)
            r.icon:SetTexture(WFD:ItemIcon(a.link) or UI.Icon("loot"))
            r.worn:SetShown(a.worn and true or false)
            r.count:SetText(a.n > 1 and ("x" .. a.n) or "")
            local room = r:GetWidth() - 60 - r.count:GetStringWidth() - 24
            r.name:SetWidth(max(40, room))
            r.sub:SetWidth(max(40, room))
            local ink = UI.TreasureInk(q) or { 1, 1, 1 }
            r.name:SetText("|cff" .. UI.Hex(ink) .. WFD:ItemName(a.link) .. "|r")
            r.sub:SetText(format(L["Day %d"], a.day) .. (a.src and ("  -  " .. a.src) or "") .. (a.worn and ("  -  " .. L["worn right now"]) or ""))
            r.link, r.day = a.link, a.day
            r.mob = a.src and UI.MobByName(a.src)
        end,
    },
    empty = function()
        if #UI.TreasureList() == 0 then return L["No treasures found yet."] end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- The book of honour
------------------------------------------------------------------------
UI.PART_VIEW.honour = "honour"

local LOCKED = { 0.46, 0.39, 0.30 }
local QUESTION = "Interface\\Icons\\INV_Misc_QuestionMark"

local function makeHonourRow(parent)
    local r = K.Box(parent, nil, nil, "Button")
    r.ring = UI.Circle(r, 36, { 1, 1, 1, 1 }, "ARTWORK", 0)
    r.ring:SetPoint("TOPLEFT", 8, -8)
    r.icon = r:CreateTexture(nil, "ARTWORK", nil, 2)
    r.icon:SetSize(28, 28)
    r.icon:SetPoint("CENTER", r.ring, "CENTER")
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    UI.Round(r.icon, r)
    r.title = K.Button(r, L["Title"], "secondary", function(self) WFD:ToggleTitle(self.key) r.refresh() end)
    r.title.minH = 26
    r.show = K.Button(r, L["Showcase"], "secondary", function(self) WFD:ToggleShowcase(self.key) r.refresh() end)
    r.show.minH = 26
    r.show:SetPoint("RIGHT", -10, 0)
    r.title:SetPoint("RIGHT", r.show, "LEFT", -6, 0)
    r.name = K.Text(r, "strong", "ink")
    r.name:SetPoint("TOPLEFT", r.ring, "TOPRIGHT", 12, 0)
    r.name:SetWordWrap(false)
    r.desc = K.Text(r, "small", "soft")
    r.desc:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -3)
    r.desc:SetWordWrap(false)
    r.value = K.Text(r, "small", "soft", "RIGHT")
    r.value:SetPoint("BOTTOMRIGHT", -12, 10)
    r.bar = K.Bar(r, 5)
    r.bar:SetPoint("BOTTOMLEFT", r.ring, "BOTTOMRIGHT", 12, -2)
    r.bar:SetPoint("RIGHT", r.value, "LEFT", -12, 0)
    r:SetScript("OnEnter", function(self)
        self:SetSurface("hover")
        local lines = self.tipLines
        if lines then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(lines[1], 1, 0.86, 0.5)
            for i = 2, #lines do GameTooltip:AddLine(lines[i], 0.9, 0.9, 0.9, true) end
            GameTooltip:Show()
        end
    end)
    r:SetScript("OnLeave", function(self) self:SetSurface(nil) GameTooltip:Hide() end)
    return r
end

-- the lines of the tooltip without the old hints about clicks (the buttons say it now)
local function tipLines(e)
    local out = {}
    for _, l in ipairs(UI.HonourTip(e)) do
        if not (l == L["Click to give up this title."] or l == L["Click to make this your title."]
            or l == L["Right-click to take it out of the showcase."] or l == L["Right-click to put it in the showcase."]) then
            out[#out + 1] = l
        end
    end
    return out
end

local function honourData(state)
    local all = WFD:HonourState()
    local chip, q = state.chip, state.q
    local list = {}
    for _, e in ipairs(all) do
        local ok = chip == "all" or (chip == "earned" and e.tier > 0) or (chip == "progress" and e.next and not e.hidden)
            or (chip == "secret" and e.def.secret)
        if ok and matches(q, not e.hidden and L[e.def.name] or nil, not e.hidden and WFD:HonourText(e.def, e.next or e.def.tiers[e.n]) or nil) then
            list[#list + 1] = e
        end
    end
    if state.sort == "next" then
        local near = {}
        for _, e in ipairs(list) do
            if e.next and not e.hidden then
                e.frac = (e.value - e.prev) / max(1, e.next - e.prev)
                near[#near + 1] = e
            end
        end
        table.sort(near, function(a, b) return a.frac > b.frac end)
        return { { items = near } }
    end
    local out = {}
    for _, cat in ipairs(WFD.HONOUR_CATS) do
        local items, got, tot = {}, 0, 0
        for _, e in ipairs(list) do
            if e.def.cat == cat.key then
                items[#items + 1] = e
                got, tot = got + e.tier, tot + e.n
            end
        end
        if #items > 0 then out[#out + 1] = { title = L[cat.label], right = got .. " / " .. tot, frac = tot > 0 and got / tot or nil, items = items } end
    end
    return out
end

UI.CollectionView({
    key = "honour", label = "Book of honour", group = "goals",
    chips = { { "all", "All" }, { "earned", "Earned" }, { "progress", "In progress" }, { "secret", "Secret" } },
    sorts = { { "cat", "By category" }, { "next", "Closest to the next tier" } },
    summary = function()
        local _, s = WFD:HonourState()
        local out = { { s.points .. " / " .. s.maxPoints, L["Honour points"] }, { s.tiers .. " / " .. s.totalTiers, L["Tiers"] } }
        for i = 1, 5 do
            local m = WFD.METALS[i]
            out[#out + 1] = { "|cff" .. UI.Hex(m.col) .. (s.metals[i] or 0) .. "|r", L[m.name] }
        end
        return out
    end,
    data = honourData,
    row = {
        h = 56,
        make = function(parent)
            local r = makeHonourRow(parent)
            r.refresh = function() local v = UI.ViewInstance("honour") if v then v:Refresh(true) end end
            return r
        end,
        fill = function(r, item)
            local e = item.entry
            local h = e.def
            local earned = e.tier > 0
            local col = earned and WFD:MetalOf(e.tier, e.n).col or LOCKED
            r.ring:SetVertexColor(col[1], col[2], col[3], 1)
            r.icon:SetTexture(e.hidden and QUESTION or UI.IconPath(h.icon))
            r.icon:SetDesaturated(not earned)
            local isTitle = WFD.C and WFD.C.title == h.key
            local inCase = WFD:InShowcase(h.key)
            r.title.key, r.show.key = h.key, h.key
            r.title.style = isTitle and "primary" or "secondary"
            r.show.style = inCase and "primary" or "secondary"
            K.Repaint(r.title)
            K.Repaint(r.show)
            r.title:SetShown(earned)
            r.show:SetShown(earned)
            local metal = earned and ("  |cff" .. UI.Hex(WFD:MetalOf(e.tier, e.n).col) .. L[WFD:MetalOf(e.tier, e.n).name] .. "|r") or ""
            local room = r:GetWidth() - 66 - (earned and (r.title:GetWidth() + r.show:GetWidth() + 26) or 12)
            r.name:SetWidth(max(40, room))
            r.name:SetText((e.hidden and "???" or L[h.name]) .. metal)
            K.Recolor(r.name, earned and "ink" or "soft")
            r.desc:SetWidth(max(40, r:GetWidth() - 66 - 12))
            r.desc:SetText(e.hidden and L[h.secret] or WFD:HonourText(h, e.next or h.tiers[e.n]))
            r.value:SetText(e.hidden and "" or (e.next and UI.HonourProgressText(e) or L["Complete!"]))
            r.value:ClearAllPoints()
            r.value:SetPoint("BOTTOMRIGHT", r, "BOTTOMRIGHT", earned and -(r.title:GetWidth() + r.show:GetWidth() + 28) or -12, 9)
            K.Recolor(r.value, e.next and "soft" or "pos")
            r.bar:SetShown(not e.hidden)
            if not e.hidden then
                local frac = e.next and (e.value - e.prev) / max(1, e.next - e.prev) or 1
                r.bar:SetValue(frac)
                local m = e.next and WFD:MetalOf(e.tier + 1, e.n).col or WFD:MetalOf(e.n, e.n).col
                r.bar:SetFill(nil, m)
            end
            r.tipLines = tipLines(e)
        end,
    },
    empty = function() return L["Nothing matches this choice."] end,
})
