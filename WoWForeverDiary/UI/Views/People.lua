-- People and money on the travel desk: the companions and trading partners, the mounts, the reputation, and the
-- ledger as a dashboard - the purse, the savings goal, where the coins came from and went, the purse over the
-- days and every day in figures.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local floor, max, min, format = math.floor, math.max, math.min, string.format

-- (labels are keys, translated when the view is built:
-- L["Companions"] L["Trading partners"] L["Most together"] L["A to Z"] L["Met last"] L["First ridden"]
-- L["Most rides"] L["Highest standing"] L["Newest first"] L["All"])

local function readDay(day) local go = UI.DayGo(day) if go then go() end end

------------------------------------------------------------------------
-- Companions and trading partners
------------------------------------------------------------------------
UI.PART_VIEW.companions = "companions"

local function companionData(state)
    local C = WFD.C
    local list = {}
    if state.chip == "traders" then
        for name, t in pairs(C.traders or {}) do
            if UI.ListMatches(state.q, name) then list[#list + 1] = { trader = true, name = name, t = t } end
        end
        if state.sort == "name" then table.sort(list, function(a, b) return a.name < b.name end)
        else table.sort(list, function(a, b) return (a.t.count or 0) > (b.t.count or 0) end) end
        return { { items = list } }
    end
    for key, e in pairs(C.companions or {}) do
        if UI.ListMatches(state.q, e.name or key, e.class, e.zone) then list[#list + 1] = { key = key, e = e } end
    end
    if state.sort == "name" then
        table.sort(list, function(a, b) return (a.e.name or a.key) < (b.e.name or b.key) end)
    elseif state.sort == "new" then
        table.sort(list, function(a, b) return (a.e.first or 0) > (b.e.first or 0) end)
    else
        table.sort(list, function(a, b)
            return ((a.e.kills or 0) + (a.e.groups or 0) * 10) > ((b.e.kills or 0) + (b.e.groups or 0) * 10)
        end)
    end
    return { { items = list } }
end

-- the report of a companion ("key") or a trading partner ("t:name")
local function companionReport(rp, key)
    local C = WFD.C
    local tname = type(key) == "string" and key:match("^t:(.+)$")
    if tname then
        local t = C.traders and C.traders[tname]
        if not t then return end
        rp:Kicker(L["Trading partners"])
        rp:Title(tname)
        rp:Tiles({ { t.count or 0, L["Trades"] }, { UI.CoinIcons(t.got or 0, 12), L["Received"] }, { UI.CoinIcons(t.gave or 0, 12), L["Given"] } })
        if t.first then rp:DayLink(WFD:DayIndex(t.first), t.first, L["First trade"]) end
        if t.last and t.last ~= t.first then rp:DayLink(WFD:DayIndex(t.last), t.last, L["Last trade"]) end
        return
    end
    local e = C.companions and C.companions[key]
    if not e then return end
    rp:Kicker(e.class or L["Companions"])
    rp:Title(e.name or key)
    local days = {}
    for d in pairs(e.days or {}) do if type(d) == "number" then days[#days + 1] = d end end
    table.sort(days)
    rp:Tiles({ { e.groups or 0, L["Grouped"] }, { WFD:Int(e.kills or 0), L["Kills"] }, { #days, L["Days"] } })
    if e.level then rp:Text(format(L["Level %d"], e.level), "soft", "body") end
    if e.zone then rp:Text(e.zone, "soft", "body") end
    rp:Head(L["Days together"], tostring(#days))
    for i = #days, max(1, #days - 11), -1 do rp:DayLink(days[i]) end
    if #days > 12 then rp:Text(format(L["%d more"], #days - 12), "muted", "small") end
end

UI.CollectionView({
    key = "companions", label = "Companions", group = "people",
    chips = { { "group", "Companions" }, { "traders", "Trading partners" } },
    sorts = { { "most", "Most together" }, { "name", "A to Z" }, { "new", "Met last" } },
    lead = function()
        local n = 0
        for _ in pairs(WFD.C.companions or {}) do n = n + 1 end
        if n == 0 then return nil end
        return WFD:Count("I have travelled with %d {companion|companions}.", n)
    end,
    summary = function()
        local C = WFD.C
        local n, kills, traders, got, gave = 0, 0, 0, 0, 0
        for _, e in pairs(C.companions or {}) do n = n + 1 kills = kills + (e.kills or 0) end
        for _, t in pairs(C.traders or {}) do
            traders = traders + 1
            got, gave = got + (t.got or 0), gave + (t.gave or 0)
        end
        return { { n, L["Fellow adventurers"] }, { WFD:Int(kills), L["Kills"] }, { traders, L["Trading partners"] } }
    end,
    data = companionData,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local x = item.entry
            -- a crest of the class atlas shows a part of its texture: back to the whole icon first
            if row.coords then row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) row.coords = nil end
            if x.trader then
                local t = x.t
                local money = {}
                if (t.got or 0) > 0 then money[#money + 1] = "+" .. UI.CoinIcons(t.got, 11) end
                if (t.gave or 0) > 0 then money[#money + 1] = "-" .. UI.CoinIcons(t.gave, 11) end
                row:Set({ icon = UI.IconPath({ "INV_Misc_Coin_02" }, "coin"), ring = { 0.86, 0.66, 0.22 },
                    name = x.name, sub = format(L["%dx traded"], t.count or 0),
                    right = money[1] or "-", right2 = money[2],
                    go = function() UI.SelectIn("companions", "t:" .. x.name) end })
                return
            end
            local e = x.e
            local col = UI.ClassColor(e.classFile)
            local path, coords = UI.ClassCrest(e.classFile)
            local days = 0
            for _ in pairs(e.days or {}) do days = days + 1 end
            local bits = {}
            if e.class then bits[#bits + 1] = e.class end
            if e.first then bits[#bits + 1] = format(L["first met %s"], date(WFD.loc.date, e.first)) end
            if e.zone then bits[#bits + 1] = e.zone end
            row:Set({ icon = path, ring = { col[1], col[2], col[3] }, name = e.name or x.key,
                sub = table.concat(bits, "  -  "),
                right = WFD:Count("%d kills together", e.kills or 0), right2 = WFD:Count("%d times grouped", e.groups or 0),
                go = function(button)
                    if button == "RightButton" and e.first then readDay(WFD:DayIndex(e.first)) return end
                    UI.SelectIn("companions", x.key)
                end,
                tip = function(r)
                    K.ShowTip(r, e.name or x.key, { table.concat(bits, "  -  "), WFD:Count("%d times grouped", e.groups or 0),
                        WFD:Count("%d kills together", e.kills or 0), { L["Click: the report. Right-click: the day."], 0.5, 0.8, 1 } }, "ANCHOR_RIGHT")
                end })
            if coords then row.icon:SetTexCoord(coords[1], coords[2], coords[3], coords[4]) end
            row.coords = coords ~= nil
        end,
    },
    detail = companionReport,
    keyOf = function(x) return x.trader and ("t:" .. x.name) or x.key end,
    empty = function(state)
        if state.chip == "traders" then
            if next(WFD.C.traders or {}) == nil then return L["No trades yet."] end
        elseif next(WFD.C.companions or {}) == nil then
            return L["I have not grouped with anyone yet."]
        end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- Mounts
------------------------------------------------------------------------
UI.PART_VIEW.stable = "stable"

UI.CollectionView({
    key = "stable", part = "stable", label = "Mounts", group = "people",
    sorts = { { "first", "First ridden" }, { "rides", "Most rides" }, { "name", "A to Z" } },
    lead = function()
        local n = #WFD:Mounts()
        if n == 0 then return nil end
        return WFD:Count("%d {mount has|mounts have} carried me so far.", n)
    end,
    summary = function()
        local list = WFD:Mounts()
        local rides = 0
        for _, m in ipairs(list) do rides = rides + (m.e.rides or 0) end
        local first
        for _, m in ipairs(list) do if not first or (m.e.first or 0) < (first.first or 0) then first = m.e end end
        return { { #list, L["Mounts"] }, { WFD:Int(rides), L["Rides"] },
            { first and format(L["Day %d"], first.day or 1) or "-", L["First ride"] } }
    end,
    data = function(state)
        local list = {}
        for _, m in ipairs(WFD:Mounts()) do
            if UI.ListMatches(state.q, m.e.name, m.e.zone) then list[#list + 1] = m end
        end
        if state.sort == "rides" then
            table.sort(list, function(a, b) return (a.e.rides or 0) > (b.e.rides or 0) end)
        elseif state.sort == "name" then
            table.sort(list, function(a, b) return (a.e.name or "") < (b.e.name or "") end)
        else
            table.sort(list, function(a, b) return (a.e.first or 0) < (b.e.first or 0) end)
        end
        return { { items = list } }
    end,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local e = item.entry.e
            row:Set({ icon = e.icon or UI.Icon("mount"), ring = { 0.86, 0.62, 0.18 }, name = e.name or "?",
                sub = (e.zone and (e.zone .. "  -  ") or "") .. WFD:Count("%d rides", e.rides or 0),
                right = format(L["Day %d"], e.day or 1), right2 = e.first and date(WFD.loc.date, e.first) or nil,
                go = function(button)
                    if button == "RightButton" then readDay(e.day) return end
                    UI.SelectIn("stable", item.entry.id)
                end,
                tip = function(r)
                    K.ShowTip(r, e.name or "?", { format(L["First ridden on day %d"], e.day or 1),
                        { L["Click: the report. Right-click: the day."], 0.5, 0.8, 1 } }, "ANCHOR_RIGHT")
                end })
        end,
    },
    detail = function(rp, id)
        local e = WFD.C.mounts and WFD.C.mounts[id]
        if not e then return end
        rp:Kicker(L["Mounts"])
        rp:Title(e.name or "?")
        if e.icon then rp:Icons({ { e.icon } }) end
        rp:Tiles({ { WFD:Int(e.rides or 0), L["Rides"] }, { format(L["Day %d"], e.day or 1), L["First ride"] } })
        rp:DayLink(e.day, e.first, L["First ride"])
        if e.zone then rp:Text(e.zone, "soft", "body") end
    end,
    keyOf = function(m) return m.id end,
    empty = function()
        if #WFD:Mounts() == 0 then return L["The first ride is still to come."] end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- Reputation
------------------------------------------------------------------------
UI.PART_VIEW.standing = "standing"

-- the steps seen so far, in order, each with its day
local function stepsText(e)
    local steps = {}
    for st = 1, 8 do
        local t = e.reached and e.reached[st]
        if t then steps[#steps + 1] = WFD:StandingName(st) .. " " .. format(L["Day %d"], WFD:DayIndex(t)) end
    end
    if #steps > 0 then return table.concat(steps, "  -  ") end
    return format(L["Seen on day %d as %s"], (WFD:DayIndex(e.first or time())) or e.day or 1, WFD:StandingName(e.st0 or e.st))
end

-- the colour of a standing: red when hated, through yellow, to green and gold
local ST_COL = {
    { 0.80, 0.13, 0.13 }, { 0.80, 0.25, 0.10 }, { 0.75, 0.40, 0.10 }, { 0.85, 0.75, 0.25 },
    { 0.30, 0.70, 0.25 }, { 0.25, 0.75, 0.40 }, { 0.30, 0.70, 0.75 }, { 0.93, 0.73, 0.22 },
}

UI.CollectionView({
    key = "standing", part = "standing", label = "Reputation", group = "people",
    sorts = { { "st", "Highest standing" }, { "name", "A to Z" }, { "new", "Newest first" } },
    lead = function()
        local n = #WFD:Factions()
        if n == 0 then return nil end
        return WFD:Count("%d {faction knows|factions know} my name.", n)
    end,
    summary = function()
        local list = WFD:Factions()
        local high = 0
        for _, f in ipairs(list) do if (f.e.st or 0) >= 7 then high = high + 1 end end
        return { { #list, L["Reputation"] }, { high, WFD:StandingName(7) .. "+" } }
    end,
    data = function(state)
        local list = {}
        for _, f in ipairs(WFD:Factions()) do
            if UI.ListMatches(state.q, f.name) then list[#list + 1] = f end
        end
        if state.sort == "name" then
            table.sort(list, function(a, b) return a.name < b.name end)
        elseif state.sort == "new" then
            local function last(e)
                local t = e.first or 0
                for _, x in pairs(e.reached or {}) do if x > t then t = x end end
                return t
            end
            table.sort(list, function(a, b) return last(a.e) > last(b.e) end)
        end
        return { { items = list } }
    end,
    row = {
        h = 44,
        make = UI.ListRow,
        fill = function(row, item)
            local f = item.entry
            local col = ST_COL[f.e.st or 4] or ST_COL[4]
            row:Set({ icon = UI.Icon("banner"), ring = col, name = f.name, sub = stepsText(f.e),
                right = WFD:StandingName(f.e.st),
                go = function() UI.SelectIn("standing", f.name) end,
                tip = function(r) K.ShowTip(r, f.name, { WFD:StandingName(f.e.st), stepsText(f.e) }, "ANCHOR_RIGHT") end })
        end,
    },
    -- the report of a faction: every step reached, each leading to its day
    detail = function(rp, name)
        local e = WFD.C.rep and WFD.C.rep[name]
        if not e then return end
        rp:Kicker(L["Reputation"])
        rp:Title(name)
        local col = ST_COL[e.st or 4] or ST_COL[4]
        rp:Text("|cff" .. UI.Hex(col) .. WFD:StandingName(e.st) .. "|r", "ink", "strong")
        rp:Head(L["Steps"])
        local any = false
        for st = 1, 8 do
            local t = e.reached and e.reached[st]
            if t then
                any = true
                rp:DayLink(WFD:DayIndex(t), t, WFD:StandingName(st))
            end
        end
        if not any then
            local t = e.first
            rp:DayLink(t and WFD:DayIndex(t) or e.day, t, WFD:StandingName(e.st0 or e.st))
        end
    end,
    keyOf = function(f) return f.name end,
    empty = function()
        if #WFD:Factions() == 0 then return { icon = UI.Icon("banner"), title = L["Nothing here yet."], hint = L["A faction is noted as soon as my standing with it changes, and its steps appear here."] } end
        return L["Nothing matches this choice."]
    end,
})

------------------------------------------------------------------------
-- The ledger: a dashboard
------------------------------------------------------------------------
UI.PART_VIEW.ledger = "ledger"
UI.VIEW_PLACE.ledger = { "people", "ledger" }
UI.PART_LABEL.ledger = "Ledger"

local CAT_ICONS = {
    loot = { "INV_Misc_Bag_08" }, quest = { "INV_Scroll_03" }, sell = { "INV_Misc_Coin_02" },
    mail = { "INV_Letter_15" }, trade = { "INV_Misc_Coin_03", "INV_Misc_Coin_01" }, ah = { "INV_Misc_Coin_01" },
    repair = { "Trade_BlackSmithing", "INV_Hammer_20", "INV_Pick_02" }, vendor = { "INV_Misc_Bag_10" },
    training = { "INV_Misc_Book_11", "INV_Misc_Book_09" },
    flight = { "Ability_Mount_Gryphon_01", "Ability_Mount_Wyvern_01", "Spell_Nature_Swiftness" },
    bank = { "INV_Misc_Bag_10" }, other = { "INV_Misc_QuestionMark" },
}
local PAD, GAP = 16, 14
local DAYS_SHOWN = 14

local function signed(v) return (v < 0 and "-" or "+") .. UI.CoinIcons(v, 12) end
local function money(v) return (v < 0 and "-" or "") .. UI.CoinIcons(v, 12) end

-- every day with its income, expenses and the purse after it
local function ledgerDays()
    local C = WFD.C
    local days, saldo = {}, 0
    for day = 1, WFD:NumDays() do
        local d = C.days[day]
        if d then
            local inc, sp = WFD:Sum(d.income), WFD:Sum(d.spend)
            saldo = saldo + inc - sp
            days[#days + 1] = { day = day, inc = inc, sp = sp, saldo = saldo }
        end
    end
    return days
end

local function card(parent, title)
    local c = K.Card(parent)
    c.head = K.SectionHead(c, title)
    c.head:SetPoint("TOPLEFT", PAD, -PAD)
    c.head:SetPoint("RIGHT", c, "RIGHT", -PAD, 0)
    return c
end

-- the purse over the days: a soft area under a line, gold while there is money, red below zero
local function makeChart(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.bg = K.Fill(f, "inset", "BACKGROUND", 1)
    f.bg:SetAllPoints()
    f.tex, f.lines, f.hots, f.texts = {}, {}, {}, {}
    local function take(list, make, i)
        local t = list[i]
        if not t then t = make() list[i] = t end
        t:Show()
        return t
    end
    local function tex(i) return take(f.tex, function() local t = f:CreateTexture(nil, "ARTWORK", nil, 1) t:SetTexture(UI.WHITE) return t end, i) end
    local function line(i)
        if not f.CreateLine then return nil end
        return take(f.lines, function() return f:CreateLine(nil, "ARTWORK", nil, 3) end, i)
    end
    local function text(i) return take(f.texts, function() return K.Text(f, "small", "muted") end, i) end
    local function hot(i)
        return take(f.hots, function()
            local b = CreateFrame("Button", nil, f)
            b.hl = b:CreateTexture(nil, "OVERLAY")
            b.hl:SetTexture(UI.WHITE)
            b.hl:SetAllPoints()
            b.hl:SetVertexColor(1, 1, 1, 0.06)
            b.hl:Hide()
            b:SetScript("OnEnter", function(s)
                s.hl:Show()
                K.ShowTip(s, s.title, s.lines, "ANCHOR_TOP")
            end)
            b:SetScript("OnLeave", function(s) s.hl:Hide() GameTooltip:Hide() end)
            b:SetScript("OnClick", function(s) readDay(s.day) end)
            return b
        end, i)
    end

    function f:Draw(days, w, h)
        self:SetSize(w, h)
        -- the gold and the red of the style: they read on dark leather and on light parchment alike
        local gr, gg, gb = UI.Tok("gold")
        local rr, rg, rb = UI.Tok("neg")
        local GOLD_C, RED_C = { gr, gg, gb }, { rr, rg, rb }
        local nt, nl, nh, nx = 0, 0, 0, 0
        local n = #days
        if n > 0 then
            local step = math.ceil(n / 80)
            local pts = {}
            for i = 1, n, step do pts[#pts + 1] = days[i] end
            if pts[#pts] ~= days[n] then pts[#pts + 1] = days[n] end
            local np = #pts
            local hi, lo = 0, 0
            for _, r in ipairs(pts) do hi, lo = max(hi, r.saldo), min(lo, r.saldo) end
            local span = max(1, hi - lo)
            local top, bottom = hi + span * 0.15, lo - (lo < 0 and span * 0.12 or 0)
            local range = max(1, top - bottom)
            local PL, PR, PT, PB = 10, 14, 22, 22
            local iw, ih = w - PL - PR, h - PT - PB
            local function py(v) return -(PT + ih * (top - v) / range) end
            local function px(i) return np == 1 and (PL + iw / 2) or (PL + (i - 1) / (np - 1) * iw) end
            local zeroY = py(0)
            local function valueAt(sx)
                if np == 1 then return pts[1].saldo end
                local fr = sx / iw * (np - 1)
                -- the last point has no next one: at the right edge the step before it is read to its end
                local i = min(np - 2, floor(fr))
                return pts[i + 1].saldo + (pts[i + 2].saldo - pts[i + 1].saldo) * (fr - i)
            end
            -- the area in thin slices
            local SW = 3
            for sx = 0, iw - 1, SW do
                local v = valueAt(min(iw, sx + SW / 2))
                local hgt = math.abs(py(v) - zeroY)
                if hgt >= 1 then
                    nt = nt + 1
                    local t = tex(nt)
                    local col = v >= 0 and GOLD_C or RED_C
                    t:ClearAllPoints()
                    if v >= 0 then
                        t:SetPoint("BOTTOMLEFT", self, "TOPLEFT", PL + sx, zeroY)
                        UI.Gradient(t, "VERTICAL", { col[1], col[2], col[3], 0.04 }, { col[1], col[2], col[3], 0.32 })
                    else
                        t:SetPoint("TOPLEFT", self, "TOPLEFT", PL + sx, zeroY)
                        UI.Gradient(t, "VERTICAL", { col[1], col[2], col[3], 0.32 }, { col[1], col[2], col[3], 0.04 })
                    end
                    t:SetSize(min(SW, iw - sx), hgt)
                end
            end
            -- zero
            nt = nt + 1
            local z = tex(nt)
            UI.Gradient(z, "HORIZONTAL", { 0.6, 0.5, 0.4, 0.5 }, { 0.6, 0.5, 0.4, 0.5 })
            z:ClearAllPoints()
            z:SetPoint("TOPLEFT", self, "TOPLEFT", PL, zeroY)
            z:SetSize(iw, 1)
            -- the line, and a dot on the last day
            for i = 2, np do
                local a, b = pts[i - 1].saldo, pts[i].saldo
                local col = (a >= 0 and b >= 0) and GOLD_C or RED_C
                for _, k in ipairs({ { 0.18, 7 }, { 1, 2 } }) do
                    nl = nl + 1
                    local l = line(nl)
                    if l then
                        l:SetColorTexture(col[1], col[2], col[3], k[1])
                        l:SetThickness(k[2])
                        l:SetStartPoint("TOPLEFT", self, px(i - 1), py(a))
                        l:SetEndPoint("TOPLEFT", self, px(i), py(b))
                    end
                end
            end
            -- hover: the day and its purse; a click reads the day
            for i, r in ipairs(pts) do
                nh = nh + 1
                local b = hot(nh)
                local x0 = (i == 1) and PL or (px(i - 1) + px(i)) / 2
                local x1 = (i == np) and (PL + iw) or (px(i) + px(i + 1)) / 2
                b:ClearAllPoints()
                b:SetPoint("TOPLEFT", self, "TOPLEFT", x0, 0)
                b:SetSize(max(2, x1 - x0), h)
                b.day = r.day
                b.title = format(L["Day %d"], r.day) .. "  -  " .. WFD:DateStr(r.day)
                b.lines = { L["Balance"] .. ": " .. money(r.saldo), L["Click to read this day."] }
            end
            -- the highest purse, and the days at the foot
            nx = nx + 1
            local hiT = text(nx)
            hiT:SetText(UI.CoinIcons(hi, 10))
            hiT:ClearAllPoints()
            hiT:SetPoint("TOPLEFT", self, "TOPLEFT", PL, -4)
            local last = pts[np]
            nx = nx + 1
            local lv = text(nx)
            K.Recolor(lv, last.saldo < 0 and "neg" or "ink", "strong")
            lv:SetText(money(last.saldo))
            lv:ClearAllPoints()
            lv:SetPoint("TOPRIGHT", self, "TOPRIGHT", -PR, -4)
            for k, i in ipairs({ 1, np }) do
                if k == 1 or np > 1 then
                    nx = nx + 1
                    local t = text(nx)
                    K.Recolor(t, "muted", "small")
                    t:SetText(format(L["Day %d"], pts[i].day))
                    t:ClearAllPoints()
                    t:SetPoint(k == 1 and "BOTTOMLEFT" or "BOTTOMRIGHT", self, k == 1 and "BOTTOMLEFT" or "BOTTOMRIGHT", k == 1 and PL or -PR, 4)
                end
            end
        end
        for i = nt + 1, #self.tex do self.tex[i]:Hide() end
        for i = nl + 1, #self.lines do self.lines[i]:Hide() end
        for i = nh + 1, #self.hots do self.hots[i]:Hide() end
        for i = nx + 1, #self.texts do self.texts[i]:Hide() end
    end
    return f
end

-- one category: icon, name, share, a bar and the sum
local function makeCat(parent)
    local r = CreateFrame("Frame", nil, parent)
    r.icon = r:CreateTexture(nil, "ARTWORK")
    r.icon:SetSize(22, 22)
    r.icon:SetPoint("TOPLEFT", 0, -2)
    r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    r.name = K.Text(r, "body", "ink")
    r.name:SetPoint("TOPLEFT", 30, -1)
    r.name:SetWordWrap(false)
    r.value = K.Text(r, "small", "soft", "RIGHT")
    r.value:SetPoint("TOPRIGHT", 0, -2)
    r.bar = K.Bar(r, 4)
    r.bar:SetPoint("TOPLEFT", 30, -20)
    r.bar:SetPoint("RIGHT", r, "RIGHT", 0, 0)
    r:SetHeight(30)
    return r
end

-- one day: a diamond (green: profit, red: loss), the day, its income, expenses and the purse after it
local function makeDayRow(parent)
    local r = CreateFrame("Button", nil, parent)
    r.hl = K.Fill(r, "hover", "BACKGROUND", 1)
    r.hl:SetAllPoints()
    r.hl:Hide()
    r.dia = UI.Diamond(r, 7, { 1, 1, 1, 1 }, "ARTWORK", 1)
    r.dia:SetPoint("LEFT", 4, 0)
    r.day = K.Text(r, "body", "ink")
    r.day:SetPoint("LEFT", 16, 0)
    r.date = K.Text(r, "small", "muted")
    r.date:SetPoint("LEFT", r.day, "RIGHT", 6, 0)
    r.cols = {}
    for i = 1, 3 do r.cols[i] = K.Text(r, i == 3 and "strong" or "small", "ink", "RIGHT") end
    r:SetScript("OnEnter", function(s)
        s.hl:Show()
        K.ShowTip(s, s.title, s.lines, "ANCHOR_RIGHT")
    end)
    r:SetScript("OnLeave", function(s) s.hl:Hide() GameTooltip:Hide() end)
    r:SetScript("OnClick", function(s) readDay(s.dayIndex) end)
    return r
end

UI:RegisterView({
    key = "ledger",
    build = function(outer)
        -- one page of the open book
        local _, host = K.BookHost(outer)
        local v = { all = false }
        local scroll = K.Scroll(host)
        scroll:SetAllPoints(host)
        local area = scroll.content

        -- the purse: figures, the savings goal
        local purse = card(area, L["Ledger"])
        purse.tiles = {}
        for i = 1, 4 do
            local t = K.Box(purse, "inset", nil)
            t.value = K.Text(t, "strong", "ink")
            t.value:SetPoint("TOPLEFT", 10, -8)
            t.label = K.Text(t, "small", "muted")
            t.label:SetPoint("TOPLEFT", t.value, "BOTTOMLEFT", 0, -3)
            purse.tiles[i] = t
        end
        purse.goalHead = K.Text(purse, "small", "gold")
        purse.goalValue = K.Text(purse, "small", "soft", "RIGHT")
        purse.goalBar = K.Bar(purse, 6)
        purse.setGoal = K.Button(purse, L["Set a savings goal"], "secondary", function()
            local have = WFD.C.goldGoal
            UI:Ask({
                title = L["Savings goal in gold:"], ok = OKAY or "OK",
                input = { value = have and tostring(floor(have / 10000)) or "", numeric = true, max = 6 },
                onOk = function(text)
                    local n = tonumber(text) or 0
                    WFD.C.goldGoal = n > 0 and n * 10000 or nil
                    v:Refresh()
                end,
            })
        end)
        purse.dropGoal = K.Button(purse, L["Remove"], "ghost", function()
            local was = WFD.C.goldGoal
            WFD.C.goldGoal = nil
            v:Refresh()
            if was then
                UI:Notice(L["The savings goal is removed."], function()
                    WFD.C.goldGoal = was
                    v:Refresh()
                end)
            end
        end)
        function purse:Fill(t, days)
            local bal = t.income - t.spend
            local list = {
                { "+" .. UI.CoinIcons(t.income, 12), L["Income"], "pos" },
                { "-" .. UI.CoinIcons(t.spend, 12), L["Expenses"], "neg" },
                { money(bal), L["Balance"], bal < 0 and "neg" or "ink" },
                { signed(#days > 0 and bal / #days or 0), L["Per day"], bal < 0 and "neg" or "pos" },
            }
            for i, tl in ipairs(self.tiles) do
                tl.value:SetText(list[i][1])
                K.Recolor(tl.value, list[i][3])
                tl.label:SetText(list[i][2])
            end
            local goal = WFD.C.goldGoal
            self.hasGoal = goal and goal > 0
            self.goalHead:SetShown(self.hasGoal)
            self.goalValue:SetShown(self.hasGoal)
            self.goalBar:SetShown(self.hasGoal)
            self.dropGoal:SetShown(self.hasGoal)
            if self.hasGoal then
                local have = WFD.demo and max(0, bal) or (GetMoney and GetMoney() or 0)
                local done = have >= goal
                self.goalHead:SetText(UI.Upper(done and L["Goal reached"] or L["Savings goal"]))
                K.Recolor(self.goalHead, done and "pos" or "gold")
                self.goalValue:SetText(UI.CoinIcons(min(have, goal), 11) .. "  /  " .. UI.CoinIcons(goal, 11))
                self.goalBar:SetValue(have / goal)
                self.goalBar:SetFill(done and "pos" or "gold")
                self.setGoal:SetLabel(L["Change the goal"])
            else
                self.setGoal:SetLabel(L["Set a savings goal"])
            end
        end
        function purse:Measure(w)
            self:SetWidth(w)
            local y = PAD + 18 + 12
            local per = (w >= 520) and 4 or 2
            local tw = (w - 2 * PAD - (per - 1) * 8) / per
            local th = 0
            for _, t in ipairs(self.tiles) do
                t.value:SetWidth(tw - 16)
                t.label:SetWidth(tw - 16)
                th = max(th, 8 + t.value:GetStringHeight() + 3 + t.label:GetStringHeight() + 9)
            end
            for i, t in ipairs(self.tiles) do
                local c, r = (i - 1) % per, floor((i - 1) / per)
                t:SetSize(tw, th)
                t:ClearAllPoints()
                t:SetPoint("TOPLEFT", self, "TOPLEFT", PAD + c * (tw + 8), -(y + r * (th + 8)))
            end
            y = y + (floor((#self.tiles - 1) / per) + 1) * (th + 8) + 8
            if self.hasGoal then
                self.goalHead:ClearAllPoints()
                self.goalHead:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                self.goalValue:ClearAllPoints()
                self.goalValue:SetPoint("TOPRIGHT", self, "TOPRIGHT", -PAD, -y)
                y = y + max(self.goalHead:GetStringHeight(), self.goalValue:GetStringHeight()) + 6
                self.goalBar:ClearAllPoints()
                self.goalBar:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                self.goalBar:SetWidth(w - 2 * PAD)
                y = y + 16
            end
            self.setGoal:ClearAllPoints()
            self.setGoal:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            self.dropGoal:ClearAllPoints()
            self.dropGoal:SetPoint("LEFT", self.setGoal, "RIGHT", 8, 0)
            return y + self.setGoal:GetHeight() + PAD
        end

        -- the purse over the days
        local chart = card(area, L["The purse over the days"])
        chart.chart = makeChart(chart)
        chart.none = K.Text(chart, "body", "soft")
        chart.none:SetText(L["Every coin I earn or spend is drawn here, day by day."])
        function chart:Fill(days) self.days = days end
        function chart:Measure(w)
            self:SetWidth(w)
            local y = PAD + 18 + 12
            local h = max(140, min(260, floor(w * 0.32)))
            self.chart:ClearAllPoints()
            self.chart:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
            self.chart:Draw(self.days or {}, w - 2 * PAD, h)
            self.none:SetShown(#(self.days or {}) == 0)
            self.none:ClearAllPoints()
            self.none:SetPoint("CENTER", self.chart, "CENTER")
            return y + h + PAD
        end

        -- where it came from, where it went: every category
        local function flow(title, which, key)
            local c = card(area, title)
            c.rows = {}
            c.none = K.Text(c, "body", "muted")
            c.none:SetText(L["Nothing here yet."])
            function c:Fill()
                local sums, total = {}, 0
                for _, day in pairs(WFD.C.days or {}) do
                    for cat, val in pairs(day[which] or {}) do sums[cat] = (sums[cat] or 0) + val end
                end
                local list = {}
                for _, cat in ipairs(WFD.moneyCats or {}) do
                    local val = sums[cat]
                    if val and val > 0 then list[#list + 1] = { cat = cat, v = val } total = total + val end
                end
                table.sort(list, function(a, b) return a.v > b.v end)
                for i, e in ipairs(list) do
                    local r = self.rows[i] or makeCat(self)
                    self.rows[i] = r
                    r.icon:SetTexture(UI.IconPath(CAT_ICONS[e.cat], "coin"))
                    r.name:SetText(WFD:CatName(e.cat))
                    r.value:SetText(UI.CoinIcons(e.v, 11) .. "   " .. floor(e.v * 100 / max(1, total) + 0.5) .. "%")
                    r.bar:SetValue(e.v / list[1].v)
                    r.bar:SetFill(key)
                    r:Show()
                end
                for i = #list + 1, #self.rows do self.rows[i]:Hide() end
                self.n = #list
                self.head:Set(title, total > 0 and UI.CoinIcons(total, 11) or nil)
            end
            function c:Measure(w)
                self:SetWidth(w)
                local y = PAD + 18 + 12
                for i = 1, self.n or 0 do
                    local r = self.rows[i]
                    r:ClearAllPoints()
                    r:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                    r:SetWidth(w - 2 * PAD)
                    r.name:SetWidth(max(40, w - 2 * PAD - 30 - r.value:GetStringWidth() - 10))
                    y = y + 34
                end
                self.none:SetShown((self.n or 0) == 0)
                self.none:ClearAllPoints()
                self.none:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                if (self.n or 0) == 0 then y = y + 20 end
                return y + PAD - 4
            end
            return c
        end
        local came = flow(L["Came from"], "income", "pos")
        local went = flow(L["Went to"], "spend", "neg")

        -- the days: the best, the worst, the latest (all on request)
        local dayCard = card(area, L["Day"])
        dayCard.rows = {}
        dayCard.facts = {}
        for i = 1, 3 do
            local t = K.Box(dayCard, "inset", nil, "Button")
            t.value = K.Text(t, "strong", "ink")
            t.value:SetPoint("TOPLEFT", 10, -8)
            t.label = K.Text(t, "small", "muted")
            t.label:SetPoint("TOPLEFT", t.value, "BOTTOMLEFT", 0, -3)
            t:SetScript("OnEnter", function(s) if s.day then s:SetSurface("hover", "gold") end end)
            t:SetScript("OnLeave", function(s) s:SetSurface("inset", nil) end)
            t:SetScript("OnClick", function(s) if s.day then readDay(s.day) end end)
            dayCard.facts[i] = t
        end
        dayCard.colHeads = {}
        for i, key in ipairs({ "Income", "Expenses", "Balance" }) do
            dayCard.colHeads[i] = K.Text(dayCard, "section", "gold", "RIGHT")
            dayCard.colHeads[i]:SetText(UI.Upper(L[key]))
        end
        dayCard.more = K.Button(dayCard, "", "ghost", function()
            v.all = not v.all
            v:Refresh()
        end)
        function dayCard:Fill(days)
            local best, worst, net = nil, nil, 0
            for _, r in ipairs(days) do
                local n = r.inc - r.sp
                net = net + n
                if not best or n > best.n then best = { n = n, day = r.day } end
                if not worst or n < worst.n then worst = { n = n, day = r.day } end
            end
            local facts = {
                best and { signed(best.n), format(L["Best day: day %d"], best.day), best.n >= 0 and "pos" or "neg", best.day },
                worst and { signed(worst.n), format(L["Worst day: day %d"], worst.day), worst.n >= 0 and "pos" or "neg", worst.day },
                { signed(#days > 0 and net / #days or 0), L["Per day"], net >= 0 and "pos" or "neg" },
            }
            for i, t in ipairs(self.facts) do
                local f = facts[i]
                t:SetShown(f ~= nil and #days > 0)
                if f then
                    t.value:SetText(f[1])
                    K.Recolor(t.value, f[3])
                    t.label:SetText(f[2])
                    t.day = f[4]
                end
            end
            -- newest first
            local shown = v.all and #days or min(DAYS_SHOWN, #days)
            local C = WFD.C
            for i = 1, shown do
                local d = days[#days - i + 1]
                local r = self.rows[i] or makeDayRow(self)
                self.rows[i] = r
                local n = d.inc - d.sp
                local col = n > 0 and "pos" or (n < 0 and "neg" or "muted")
                r.dia:SetVertexColor(UI.Tok(col))
                r.day:SetText(format(L["Day %d"], d.day))
                r.date:SetText(date(WFD.loc.dayMonth, WFD:DayTime(d.day)))
                r.cols[1]:SetText(d.inc > 0 and ("+" .. UI.CoinIcons(d.inc, 11)) or "-")
                K.Recolor(r.cols[1], d.inc > 0 and "pos" or "muted", "small")
                r.cols[2]:SetText(d.sp > 0 and ("-" .. UI.CoinIcons(d.sp, 11)) or "-")
                K.Recolor(r.cols[2], d.sp > 0 and "neg" or "muted", "small")
                r.cols[3]:SetText(money(d.saldo))
                K.Recolor(r.cols[3], d.saldo < 0 and "neg" or "ink", "strong")
                -- the tooltip: the money of the day by category
                local day = C.days[d.day]
                local lines = {}
                for _, cat in ipairs(WFD.moneyCats or {}) do
                    local a, b = day and day.income[cat], day and day.spend[cat]
                    if a and a > 0 then lines[#lines + 1] = "+" .. UI.CoinIcons(a, 11) .. "  " .. WFD:CatName(cat) end
                    if b and b > 0 then lines[#lines + 1] = "-" .. UI.CoinIcons(b, 11) .. "  " .. WFD:CatName(cat) end
                end
                lines[#lines + 1] = L["Click to read this day."]
                r.title = format(L["Day %d"], d.day) .. "  -  " .. WFD:DateStr(d.day)
                r.lines, r.dayIndex = lines, d.day
                r:Show()
            end
            for i = shown + 1, #self.rows do self.rows[i]:Hide() end
            self.n = shown
            self.total = #days
            self.more:SetShown(#days > DAYS_SHOWN)
            self.more:SetLabel(v.all and L["Show fewer"] or format(L["Show all %d days"], #days))
            self.head:Set(L["Day"], tostring(#days))
        end
        function dayCard:Measure(w)
            self:SetWidth(w)
            local y = PAD + 18 + 12
            local inner = w - 2 * PAD
            if (self.total or 0) > 0 then
                local per = 3
                local tw = (inner - (per - 1) * 8) / per
                local th = 0
                for _, t in ipairs(self.facts) do
                    t.value:SetWidth(tw - 16)
                    t.label:SetWidth(tw - 16)
                    th = max(th, 8 + t.value:GetStringHeight() + 3 + t.label:GetStringHeight() + 9)
                end
                for i, t in ipairs(self.facts) do
                    t:SetSize(tw, th)
                    t:ClearAllPoints()
                    t:SetPoint("TOPLEFT", self, "TOPLEFT", PAD + (i - 1) * (tw + 8), -y)
                end
                y = y + th + 16
            end
            -- the columns: the day on the left, three sums on the right
            local cw = max(80, floor(inner * 0.2))
            local rights = { inner - 2 * cw, inner - cw, inner }
            for i, hd in ipairs(self.colHeads) do
                hd:SetShown((self.n or 0) > 0)
                hd:ClearAllPoints()
                hd:SetPoint("TOPRIGHT", self, "TOPLEFT", PAD + rights[i] - 4, -y)
            end
            if (self.n or 0) > 0 then y = y + 20 end
            local rh = floor(26 * max(1, UI.FONT_SCALE or 1) + 0.5)
            for i = 1, self.n or 0 do
                local r = self.rows[i]
                r:ClearAllPoints()
                r:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -y)
                r:SetSize(inner, rh)
                for k, t in ipairs(r.cols) do
                    t:ClearAllPoints()
                    t:SetPoint("RIGHT", r, "LEFT", rights[k] - 4, 0)
                end
                y = y + rh
            end
            if self.more:IsShown() then
                y = y + 6
                self.more:ClearAllPoints()
                self.more:SetPoint("TOPLEFT", self, "TOPLEFT", PAD - 6, -y)
                y = y + self.more:GetHeight()
            end
            return y + PAD
        end

        function v:Arrange()
            local W = self.w or scroll:GetWidth() or 0
            if W <= 0 then return end
            local inner = W - 40
            local y = 20
            local function full(cd)
                local h = cd:Measure(min(inner, 980))
                cd:ClearAllPoints()
                cd:SetPoint("TOPLEFT", area, "TOPLEFT", 20, -y)
                cd:SetHeight(h)
                y = y + h + GAP
            end
            full(purse)
            full(chart)
            if inner >= 700 then
                local cw = (min(inner, 980) - GAP) / 2
                local h = max(came:Measure(cw), went:Measure(cw))
                came:ClearAllPoints()
                came:SetPoint("TOPLEFT", area, "TOPLEFT", 20, -y)
                came:SetHeight(h)
                went:ClearAllPoints()
                went:SetPoint("TOPLEFT", area, "TOPLEFT", 20 + cw + GAP, -y)
                went:SetHeight(h)
                y = y + h + GAP
            else
                full(came)
                full(went)
            end
            full(dayCard)
            scroll:SetContentHeight(y + 6)
        end
        function v:Refresh()
            local ok, err = pcall(function()
                local days = ledgerDays()
                purse:Fill(WFD:Totals(), days)
                chart:Fill(days)
                came:Fill()
                went:Fill()
                dayCard:Fill(days)
            end)
            if not ok then WFD:Error("ledger", err) end
            self:Arrange()
        end
        function v:Show() self:Refresh() end
        function v:Layout(w, h) self.w = w - K.BOOK_W self:Arrange() end
        scroll.onResize = function(sf) v.w = sf:GetWidth() v:Arrange() end
        UI.OnRestyle(function() if host:IsVisible() then v:Refresh() end end)
        function v:Head()
            local g = UI.NAV_GROUP.people
            return L["Ledger"], L[g.label], UI.GroupRoute(g)
        end
        return v
    end,
})
