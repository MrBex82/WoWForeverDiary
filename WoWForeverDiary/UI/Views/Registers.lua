-- The registers on the travel desk: everyone you talked to, and every quest. One line each, in groups, with chips,
-- a name filter and an order; a person's calling card opens in the column beside the list.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local max, format = math.max, string.format

-- (labels are keys, translated when the view is built:
-- L["Trainers"] L["Merchants"] L["Flight masters"] L["Quest givers"] L["Regulars"] L["A to Z"] L["By area"]
-- L["Most spoken to"] L["Met last"] L["Open"] L["Done"] L["Given up"] L["Newest first"] L["All"])

local function matches(q, ...)
    if not q or q == "" then return true end
    for i = 1, select("#", ...) do
        local s = select(i, ...)
        if s and tostring(s):lower():find(q, 1, true) then return true end
    end
    return false
end

local function groupBy(list, keyFn)
    local out, by = {}, {}
    for _, e in ipairs(list) do
        local k = keyFn(e) or "?"
        local g = by[k]
        if not g then
            g = { title = k, items = {} }
            by[k] = g
            out[#out + 1] = g
        end
        g.items[#g.items + 1] = e
    end
    for _, g in ipairs(out) do g.right = tostring(#g.items) end
    return out
end

-- the day of a moment, and its page in the diary
local function dayOf(t) return t and WFD:DayIndex(t) end
local function openDay(day) UI:OpenDay(day) end

-- one line: an icon in a ring, a name, a line below it, two figures on the right
local function makeRow(parent)
    local r = K.Box(parent, nil, nil, "Button")
    r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    r.ring = UI.Circle(r, 28, { 1, 1, 1, 1 }, "ARTWORK", 0)
    r.ring:SetPoint("LEFT", 8, 0)
    r.icon = r:CreateTexture(nil, "ARTWORK", nil, 2)
    r.icon:SetSize(22, 22)
    r.icon:SetPoint("CENTER", r.ring, "CENTER")
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    UI.Round(r.icon, r)
    r.mark = K.Glyph(r, "check", 14, "pos")
    r.mark:SetPoint("CENTER", r.ring, "CENTER")
    r.right = K.Text(r, "strong", "soft", "RIGHT")
    r.right:SetPoint("TOPRIGHT", -10, -6)
    r.right2 = K.Text(r, "small", "muted", "RIGHT")
    r.right2:SetPoint("TOPRIGHT", r.right, "BOTTOMRIGHT", 0, -2)
    r.name = K.Text(r, "strong", "ink")
    r.name:SetPoint("TOPLEFT", r.ring, "TOPRIGHT", 10, 2)
    r.name:SetWordWrap(false)
    r.sub = K.Text(r, "small", "muted")
    r.sub:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -2)
    r.sub:SetWordWrap(false)
    r:SetScript("OnEnter", function(self)
        self:SetSurface("hover")
        if self.tip then self.tip(self) else K.ShowFull(self, "ANCHOR_RIGHT", self.name, self.sub) end
    end)
    r:SetScript("OnLeave", function(self) self:SetSurface(nil) GameTooltip:Hide() end)
    r:SetScript("OnClick", function(self, button) if self.go then self.go(button) end end)
    function r:Set(o)
        self.icon:SetTexture(o.icon)
        self.icon:SetShown(o.icon ~= nil)
        self.mark:SetShown(o.mark ~= nil)
        if o.mark then self.mark:SetShape(o.mark) self.mark:SetColorKey(o.markKey or "pos") end
        local col = o.ring or { 0.4, 0.3, 0.2 }
        self.ring:SetVertexColor(col[1], col[2], col[3], o.icon and 1 or 0.35)
        self.right:SetText(o.right or "")
        self.right2:SetText(o.right2 or "")
        local room = self:GetWidth() - 56 - max(self.right:GetStringWidth(), self.right2:GetStringWidth()) - 20
        self.name:SetWidth(max(40, room))
        self.sub:SetWidth(max(40, room))
        -- new since the part was last looked at: a small gold NEW before the name (once, see UI.IsNew)
        local tag = o.new and ("|cff" .. UI.Hex({ UI.Tok("gold") }) .. L["NEW"] .. "|r  ") or ""
        self.name:SetText(tag .. (o.name or "?"))
        K.Recolor(self.name, o.nameKey or "ink")
        self.sub:SetText(o.sub or "")
        self.go, self.tip = o.go, o.tip
    end
    return r
end

------------------------------------------------------------------------
-- People
------------------------------------------------------------------------
UI.PART_VIEW.people = "people"

local REGULAR = 10        -- spoken to this often: a regular

local function mainRole(n)
    for _, r in ipairs(UI.ROLE_ORDER) do
        if n.roles and n.roles[r] then return r end
    end
    return "talk"
end

local function rolesText(n)
    local roles = {}
    for _, r in ipairs(UI.ROLE_ORDER) do
        if n.roles and n.roles[r] and r ~= "talk" then roles[#roles + 1] = WFD:RoleName(r) end
    end
    return table.concat(roles, ", ")
end

local function letterOf(name)
    local l = (name or "?"):match("^[%z\1-\127\194-\244][\128-\191]*") or "?"
    return l:upper()
end

local function peopleData(state)
    local list = {}
    for key, n in pairs(WFD.C.npcs or {}) do
        if not n.obj then
            local chip = state.chip
            local ok = chip == "all" or (chip == "regular" and (n.talks or 0) >= REGULAR)
                or (chip ~= "regular" and n.roles and n.roles[chip])
            if ok and matches(state.q, n.name, n.zone, rolesText(n)) then list[#list + 1] = { key = key, n = n } end
        end
    end
    local sort = state.sort
    if sort == "zone" then
        table.sort(list, function(a, b)
            if (a.n.zone or "") ~= (b.n.zone or "") then return (a.n.zone or "") < (b.n.zone or "") end
            return (a.n.name or "") < (b.n.name or "")
        end)
        return groupBy(list, function(e) return e.n.zone or L["Other"] end)
    elseif sort == "talks" then
        table.sort(list, function(a, b) return (a.n.talks or 0) > (b.n.talks or 0) end)
        return { { items = list } }
    elseif sort == "new" then
        table.sort(list, function(a, b) return (a.n.first or 0) > (b.n.first or 0) end)
        return { { items = list } }
    end
    table.sort(list, function(a, b) return (a.n.name or "") < (b.n.name or "") end)
    return groupBy(list, function(e) return letterOf(e.n.name) end)
end

-- the calling card of a person, written for the width of the column: portrait, trades, figures, places, quests
local function personReport(rp, key)
    local C = WFD.C
    local n = C.npcs and C.npcs[key]
    if not n then return end
    local R = UI.Router
    rp:Kicker(L["Acquaintance"])
    rp:Title(n.name or "?")
    local roles = {}
    for _, r in ipairs(UI.ROLE_ORDER or {}) do
        if n.roles and n.roles[r] and r ~= "talk" then roles[#roles + 1] = { WFD:RoleName(r), "gold" } end
    end
    if #roles > 0 then rp:Chips(roles) end
    rp:Model(type(key) == "number" and key or nil, 170)
    local quests = {}
    for id, q in pairs(C.quests or {}) do
        if q.giver == key or q.turnin == key then quests[#quests + 1] = { id = id, q = q } end
    end
    table.sort(quests, function(a, b) return (a.q.acc or a.q.done or 0) < (b.q.acc or b.q.done or 0) end)
    local firstDay = n.first and WFD:DayIndex(n.first)
    rp:Tiles({ { n.talks or 0, L["Conversations"], nil, (n.talks or 0) >= REGULAR and "gold" or nil }, { #quests, L["Quests"] },
        { firstDay and format(L["Day %d"], firstDay) or "-", L["First met"] } }, 3)
    if n.zone then rp:Text(n.zone .. ((n.sub and n.sub ~= "") and ("  -  " .. n.sub) or ""), "soft", "body") end
    rp:DayLink(firstDay, n.first, L["First met"])
    if n.last and n.last ~= n.first then rp:DayLink(WFD:DayIndex(n.last), n.last, L["Last met"]) end
    if n.map then rp:Link(L["Show on the world map"], n.zone, function() R.Go({ view = "world", map = n.map }) end) end
    rp:Head(L["Quests"], tostring(#quests))
    if #quests == 0 then rp:Text(L["No quests recorded."], "muted", "body") end
    for i, e in ipairs(quests) do
        if i > 8 then
            rp:Link(format(L["All %d quests"], #quests), nil, function() R.Go({ view = "quests", q = (n.name or ""):lower() }) end)
            break
        end
        local q = e.q
        rp:Line({ name = q.title or "?", mark = q.done and "check" or "right", markKey = "white",
            col = q.done and { 0.30, 0.62, 0.30 } or { 0.55, 0.40, 0.16 },
            go = function() R.Go({ view = "quests", key = e.id }) end,
            tip = { q.title or "?", { L["Click: the report."], 0.5, 0.8, 1 } } })
    end
end

UI.CollectionView({
    key = "people", label = "People", group = "people",
    chips = { { "all", "All" }, { "trainer", "Trainers" }, { "merchant", "Merchants" }, { "flight", "Flight masters" },
        { "quest", "Quest givers" }, { "regular", "Regulars" } },
    sorts = { { "name", "A to Z" }, { "zone", "By area" }, { "talks", "Most spoken to" }, { "new", "Met last" } },
    summary = function()
        local total, regulars, talks = 0, 0, 0
        for _, n in pairs(WFD.C.npcs or {}) do
            if not n.obj then
                total = total + 1
                talks = talks + (n.talks or 0)
                if (n.talks or 0) >= REGULAR then regulars = regulars + 1 end
            end
        end
        return { { total, L["People"] }, { regulars, L["Regulars"] }, { WFD:Int(talks), L["Conversations"] } }
    end,
    data = peopleData,
    row = {
        h = 44,
        make = makeRow,
        fill = function(r, item)
            local e = item.entry
            local n = e.n
            local role = mainRole(n)
            local regular = (n.talks or 0) >= REGULAR
            local day = dayOf(n.first)
            local sub = rolesText(n)
            if n.zone then sub = sub ~= "" and (sub .. "  -  " .. n.zone) or n.zone end
            r:Set({
                icon = UI.IconPath(UI.ROLE_ICONS[role]),
                ring = regular and { 0.93, 0.73, 0.22 } or { 0.55, 0.42, 0.24 },
                name = n.name, sub = sub,
                right = (n.talks or 0) .. "x", right2 = day and format(L["Day %d"], day) or nil, new = UI.IsNew("people", n.first),
                go = function() UI.SelectIn("people", e.key) end,
            })
        end,
    },
    detail = personReport,
    keyOf = function(e) return e.key end,
    empty = function()
        if next(WFD.C.npcs or {}) == nil then return { icon = UI.Icon("people"), title = L["You have not talked to anyone yet."], hint = L["Talk to a merchant, a trainer or a quest giver: everyone you speak to gets a calling card."] } end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- Quest book
------------------------------------------------------------------------
UI.PART_VIEW.quests = "quests"

local function questState(q)
    if q.done then return "done" end
    if q.abandoned then return "gaveup" end
    return "open"
end

local function questData(state)
    local C = WFD.C
    local list = {}
    for id, q in pairs(C.quests or {}) do
        local st = questState(q)
        local giver = q.giver and C.npcs[q.giver]
        local gname = giver and not giver.obj and giver.name or nil
        if (state.chip == "all" or state.chip == st) and matches(state.q, q.title, q.zone, gname) then
            list[#list + 1] = { id = id, q = q, st = st, giver = gname }
        end
    end
    local function when(e) return e.q.done or e.q.acc or 0 end
    if state.sort == "new" then
        table.sort(list, function(a, b) return when(a) > when(b) end)
        return { { items = list } }
    elseif state.sort == "name" then
        table.sort(list, function(a, b) return (a.q.title or "") < (b.q.title or "") end)
        return groupBy(list, function(e) return letterOf(e.q.title) end)
    end
    -- by area, the areas in the order of their first quest; a quest from before the diary has no area
    table.sort(list, function(a, b) return (a.q.acc or a.q.done or 0) < (b.q.acc or b.q.done or 0) end)
    local out = groupBy(list, function(e) return e.q.zone or L["Before the diary"] end)
    for _, g in ipairs(out) do
        local done = 0
        for _, e in ipairs(g.items) do if e.st == "done" then done = done + 1 end end
        g.right = done .. " / " .. #g.items
        g.frac = done / #g.items
    end
    return out
end

-- a person of the register as a link to their card
local function personLink(rp, key, label)
    local n = key and WFD.C.npcs and WFD.C.npcs[key]
    if not n or n.obj or not n.name then return end
    rp:Link(n.name, label, function() UI.Router.Go({ view = "people", key = key }) end, L["Click for the calling card."], UI.Icon("people"))
end
UI.PersonLink = personLink

-- the report of one quest in the column beside the book
local function questReport(rp, id)
    local C = WFD.C
    local q = C.quests and C.quests[id]
    if not q then return end
    local st = questState(q)
    rp:Kicker(st == "done" and L["Done"] or (st == "open" and L["Open"] or L["Given up"]),
        st == "done" and "pos" or (st == "open" and "gold" or "neg"))
    rp:Title(q.title or ("#" .. tostring(id)))
    if q.zone then rp:Text(q.zone, "soft", "body") end
    if q.quote and q.quote ~= "" then rp:Paragraph('"' .. q.quote .. '"', "soft", false, true) end
    local tiles = {}
    if q.xp and q.xp > 0 then tiles[#tiles + 1] = { WFD:Int(q.xp), L["Experience"] } end
    if q.money and q.money > 0 then tiles[#tiles + 1] = { WFD:CoinText(q.money), L["Gold"] } end
    if q.done and q.acc and q.done >= q.acc then tiles[#tiles + 1] = { WFD:DurationText(q.done - q.acc), L["Took"] } end
    if #tiles > 0 then rp:Tiles(tiles) end
    if q.reward then
        rp:Head(L["Reward"])
        rp:Icons({ { WFD:ItemIcon(q.reward) or UI.Icon("loot"), nil, q.reward } })
    end
    rp:Head(L["Days"])
    if q.acc then rp:DayLink(dayOf(q.acc), q.acc, L["Accepted"]) end
    if q.done then rp:DayLink(dayOf(q.done), q.done, L["Handed in"]) end
    if not q.acc and not q.done then rp:Text(L["Before the diary"], "muted", "body") end
    local giver, turnin = q.giver, q.turnin
    if (giver and C.npcs[giver]) or (turnin and C.npcs[turnin]) then
        rp:Head(L["People"])
        personLink(rp, giver, L["Received from"])
        if turnin ~= giver then personLink(rp, turnin, L["Handed in to"]) end
    end
    local map = q.dmap or q.map
    if map then
        rp:Gap(4)
        rp:Link(L["Show on the world map"], q.zone, function() UI.Router.Go({ view = "world", map = map }) end)
    end
end

local STATE_LOOK = {
    done = { mark = "check", key = "pos", name = "ink" },
    open = { mark = "right", key = "gold", name = "ink" },
    gaveup = { mark = "close", key = "neg", name = "muted" },
}

UI.CollectionView({
    key = "quests", label = "Quest Book", group = "diary",
    chips = { { "all", "All" }, { "open", "Open" }, { "done", "Done" }, { "gaveup", "Given up" } },
    sorts = { { "zone", "By area" }, { "new", "Newest first" }, { "name", "A to Z" } },
    summary = function()
        local done, open, gaveUp = 0, 0, 0
        for _, q in pairs(WFD.C.quests or {}) do
            local st = questState(q)
            if st == "done" then done = done + 1 elseif st == "open" then open = open + 1 else gaveUp = gaveUp + 1 end
        end
        return { { done, L["done"] }, { open, L["open"] }, { gaveUp, L["given up"] } }
    end,
    data = questData,
    row = {
        h = 40,
        make = makeRow,
        fill = function(r, item)
            local e = item.entry
            local q = e.q
            local look = STATE_LOOK[e.st]
            local day = dayOf(q.done or q.acc)
            local sub = e.giver and (L["Received from"] .. " " .. e.giver) or (q.zone or "")
            r:Set({
                mark = look.mark, markKey = look.key, name = q.title or ("#" .. tostring(e.id)), nameKey = look.name,
                sub = sub, right = day and format(L["Day %d"], day) or nil, new = UI.IsNew("quests", q.done),
                right2 = (q.xp and q.xp > 0) and ("+" .. WFD:Int(q.xp) .. " XP") or nil,
                -- a click opens the report beside the list, a right-click the day straight away
                go = function(button)
                    if button == "RightButton" and day then openDay(day) return end
                    local v = UI.ViewInstance("quests")
                    if v then v:Select(e.id) end
                end,
                tip = function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    if q.reward and pcall(GameTooltip.SetHyperlink, GameTooltip, q.reward) then
                        GameTooltip:AddLine(" ")
                    else
                        GameTooltip:SetText(q.title or "?", 1, 0.86, 0.5)
                    end
                    if e.giver then GameTooltip:AddLine(L["Received from"] .. ": " .. e.giver, 0.9, 0.9, 0.9) end
                    if q.done and q.acc and q.done >= q.acc then
                        GameTooltip:AddLine(L["Took"] .. ": " .. WFD:DurationText(q.done - q.acc), 0.9, 0.9, 0.9)
                    end
                    GameTooltip:AddLine(L["Click: the report. Right-click: the day."], 0.5, 0.8, 1)
                    GameTooltip:Show()
                end,
            })
        end,
    },
    detail = questReport,
    keyOf = function(e) return e.id end,
    empty = function()
        if next(WFD.C.quests or {}) == nil then return { icon = UI.Icon("quests"), title = L["No quests recorded yet."], hint = L["Accept a quest: it is written down with who gave it, where, and what it brought."] } end
        return L["Nothing matches this choice."]
    end,
})

-- for the other lists of the travel desk (UI/Views/Reports.lua, UI/Views/People.lua)
UI.ListRow, UI.ListMatches, UI.ListGroupBy = makeRow, matches, groupBy
