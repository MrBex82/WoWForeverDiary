-- Long collections on the travel desk: a scrolling area that only builds what is in view (an album of hundreds of
-- creatures with their 3D pictures stays quick), and a view made of a filter bar (chips, search, order), the
-- collection in groups and a column on the right for the card of what was chosen.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local floor, max, min = math.floor, math.max, math.min

------------------------------------------------------------------------
-- The scrolling area that builds only what is in view
------------------------------------------------------------------------
-- kinds = { [kind] = { make = function(parent) return frame end, fill = function(frame, item) end } }
-- items = { { kind, x, y, w, h, ... }, ... } with y from the top of the content
function K.Virtual(parent)
    local sf = K.Scroll(parent)
    local v = { sf = sf, kinds = {}, free = {}, active = {}, items = {} }

    local function release(item)
        local f = v.active[item]
        if not f then return end
        v.active[item] = nil
        f:Hide()
        f:ClearAllPoints()
        local list = v.free[f.vkind]
        list[#list + 1] = f
    end

    local function acquire(kind)
        v.free[kind] = v.free[kind] or {}
        local f = table.remove(v.free[kind])
        if not f then
            f = v.kinds[kind].make(sf.content)
            f.vkind = kind
        end
        return f
    end

    function v:SetKinds(kinds) self.kinds = kinds end

    -- new content: everything in view is filled again
    function v:SetItems(items, total, keepScroll)
        for item in pairs(self.active) do release(item) end
        self.items = items
        sf:SetContentHeight(total or 0)
        if not keepScroll then sf:ScrollTo(0) else sf:ScrollTo(sf:GetVerticalScroll()) end
        self:Update()
    end

    function v:Update()
        local top = sf:GetVerticalScroll() or 0
        local h = sf:GetHeight()
        if not h or h <= 0 then h = self.viewH or 700 end
        local lo, hi = top - 160, top + h + 160
        for item in pairs(self.active) do
            if item.y + item.h < lo or item.y > hi then release(item) end
        end
        for _, item in ipairs(self.items) do
            if not self.active[item] and item.y + item.h >= lo and item.y <= hi then
                local f = acquire(item.kind)
                self.active[item] = f
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", sf.content, "TOPLEFT", item.x, -item.y)
                f:SetSize(item.w, item.h)
                f:Show()
                local ok, err = pcall(self.kinds[item.kind].fill, f, item)
                if not ok then WFD:Error("list " .. tostring(item.kind), err) end
            end
        end
    end

    -- scroll so that an item is in view
    function v:Reveal(pred)
        for _, item in ipairs(self.items) do
            if pred(item) then
                local h = sf:GetHeight() or 0
                local top = sf:GetVerticalScroll() or 0
                if item.y < top or item.y + item.h > top + h then sf:ScrollTo(item.y - 40) end
                return item
            end
        end
    end

    sf.onScroll = function() v:Update() end
    return v
end

------------------------------------------------------------------------
-- A group heading inside a collection: the name, a figure and a thin bar of how much of it is found
------------------------------------------------------------------------
local function makeHead(parent)
    local f = CreateFrame("Frame", nil, parent)
    f.text = K.Text(f, "heading", "title")
    f.text:SetPoint("BOTTOMLEFT", 0, 9)
    f.text:SetWordWrap(false)
    f.right = K.Text(f, "small", "soft", "RIGHT")
    f.right:SetPoint("BOTTOMRIGHT", 0, 11)
    f.rule = K.Fill(f, "line", "ARTWORK", 0)
    f.rule:SetHeight(1)
    f.rule:SetPoint("BOTTOMLEFT", 0, 4)
    f.rule:SetPoint("BOTTOMRIGHT", 0, 4)
    f.bar = K.Fill(f, "gold", "ARTWORK", 1)
    f.bar:SetHeight(2)
    f.bar:SetPoint("BOTTOMLEFT", 0, 3)
    return f
end
local function fillHead(f, item)
    f.right:SetText(item.right or "")
    f.text:SetWidth(max(40, item.w - f.right:GetStringWidth() - 16))
    f.text:SetText(item.title or "")
    local frac = item.frac
    f.bar:SetShown(frac ~= nil and frac > 0)
    if frac then f.bar:SetWidth(max(1, item.w * min(1, frac))) end
end

------------------------------------------------------------------------
-- The collection view
------------------------------------------------------------------------
-- def = {
--   key, label (head bar), group (register group key),
--   chips = { { key, label }, ... }, sorts = { { key, label }, ... }, search = true,  (labels: English keys,
--   translated when the view is built: the language is only known after loading)
--   summary = function() return { { value, label }, ... } end,
--   data = function(state) return { { title, right, frac, items = { entry, ... } }, ... } end,
--   cell = { w, h, gap, make, fill }  (a grid of cards)   or   row = { h, make, fill }  (one line each)
--   empty = function(state) return text end,
--   cardKind = "creature" | "catch" | "person"   (the card of Cards.lua that opens on the right)
--   detail = function(report, key)              (or a report of its own in that column, see Report.lua;
--                                                V:Select(key) opens it)
--   keyOf = function(entry) return key end      (to leaf through the cards in the order shown)
--   extra = { { label, fn } }                  (buttons at the end of the filter bar)
-- }
-- the part of the register a view stands for (its route leads to the view instead of the book), its name,
-- and the place in the register a view lights up
UI.PART_VIEW, UI.PART_LABEL, UI.VIEW_PLACE = UI.PART_VIEW or {}, UI.PART_LABEL or {}, UI.VIEW_PLACE or {}

-- a click on a line of a list: its report opens in the column beside it
function UI.SelectIn(view, key)
    local v = UI.ViewInstance(view)
    if v and v.Select then v:Select(key) end
end

local PAD = 20
local DETAIL_MIN, DETAIL_MAX = 300, 420

function UI.CollectionView(def)
    UI.VIEW_PLACE[def.key] = { def.group, def.part or def.key }
    UI.PART_LABEL[def.part or def.key] = def.label        -- the name in the register (an English key)
    UI.PART_VIEW[def.part or def.key] = UI.PART_VIEW[def.part or def.key] or def.key
    UI:RegisterView({
        key = def.key,
        build = function(host)
            local CHIP0, SORT0 = def.chips and def.chips[1][1], def.sorts and def.sorts[1][1]
            local V = { state = { chip = CHIP0, sort = SORT0, q = "" } }
            -- what is chosen here is written into the place in the history (nothing while a route is laid out)
            local function note(k, v, default)
                local cur = UI.Router.cur
                if V.restoring or not cur or cur.view ~= def.key then return end
                if v == default or v == "" then v = nil end
                UI.Router.Note(k, v)
            end
            V.note = note

            -- the summary: a row of figures
            V.tiles = {}
            V.top = CreateFrame("Frame", nil, host)
            V.top:SetPoint("TOPLEFT", 0, 0)
            V.top:SetPoint("TOPRIGHT", 0, 0)

            -- the filter bar
            V.chips = {}
            for _, ch in ipairs(def.chips or {}) do
                local b = K.Button(V.top, L[ch[2]], "secondary", function(self)
                    V.state.chip = self.key
                    note("chip", self.key, CHIP0)
                    V:Refresh()
                end)
                b.key, b.minH = ch[1], 28
                V.chips[#V.chips + 1] = b
            end
            if def.search ~= false then
                local e = K.Box(V.top, "inset", "line", "EditBox")
                e:SetSize(190, 28)
                e:SetAutoFocus(false)
                e:SetTextInsets(8, 8, 0, 0)
                e:SetFontObject(ChatFontNormal)
                UI.Skin.Add(e, function(s)
                    local font, size = UI.TypeFont("body")
                    s:SetFont(font, size, "")
                    s:SetTextColor(UI.Tok("ink"))
                end)
                e.hint = K.Text(e, "body", "muted")
                e.hint:SetPoint("LEFT", 8, 0)
                e.hint:SetText(L["Filter by name"])
                e:SetScript("OnTextChanged", function(s)
                    s.hint:SetShown((s:GetText() or "") == "" and not s:HasFocus())
                    local q = (s:GetText() or ""):lower()
                    if q ~= V.state.q then
                        V.state.q = q
                        note("q", q, "")
                        V:Refresh()
                    end
                end)
                e:SetScript("OnEditFocusGained", function(s) s.hint:Hide() s:SetSurface("inset", "gold") end)
                e:SetScript("OnEditFocusLost", function(s)
                    s.hint:SetShown((s:GetText() or "") == "")
                    s:SetSurface("inset", "line")
                end)
                e:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
                e:SetScript("OnEnterPressed", function(s) s:ClearFocus() end)
                V.search = e
            end
            if def.sorts then
                local sorts = {}
                for _, so in ipairs(def.sorts) do sorts[#sorts + 1] = { so[1], L[so[2]] } end
                V.sortKeys = {}
                for _, so in ipairs(def.sorts) do V.sortKeys[#V.sortKeys + 1] = so[1] end
                V.sort = K.Dropdown(V.top, sorts, function() return V.state.sort end, function(v)
                    V.state.sort = v
                    note("sort", v, SORT0)
                    V:Refresh()
                end, 190)
            end
            -- a chip other than the first, or words in the filter: one button takes it all back
            function V:Filtered()
                return (self.state.chip ~= CHIP0) or (self.state.q or "") ~= ""
            end
            function V:ClearFilter()
                self.state.chip, self.state.q = CHIP0, ""
                note("chip", nil)
                note("q", nil)
                if self.search then
                    self.search:SetText("")
                    self.search:ClearFocus()
                    self.search.hint:Show()
                end
                self:Refresh()
            end
            V.clear = K.Button(V.top, L["Reset filter"], "ghost", function() V:ClearFilter() end)
            V.clear:AddArrow("close")
            V.clear.minH = 28
            V.emptyClear = K.Button(host, L["Reset filter"], "secondary", function() V:ClearFilter() end)
            V.extra = {}
            for _, x in ipairs(def.extra or {}) do
                V.extra[#V.extra + 1] = K.Button(V.top, L[x[1]], "ghost", function() x[2]() end)
            end
            V.rule = K.Rule(host, "line")

            -- the collection
            V.list = K.Virtual(host)
            local kinds = { head = { make = makeHead, fill = fillHead } }
            if def.cell then kinds.cell = { make = def.cell.make, fill = def.cell.fill } end
            if def.row then kinds.row = { make = def.row.make, fill = def.row.fill } end
            V.list:SetKinds(kinds)
            V.empty = K.Text(host, "body", "soft", "CENTER")
            V.empty:SetSpacing(3)

            -- the column for the card
            V.detail = K.Box(host, nil, nil)
            K.Material(V.detail, "dark")
            V.detail:SetPoint("TOPRIGHT", 0, 0)
            V.detail:SetPoint("BOTTOMRIGHT", 0, 0)
            V.detail:Hide()
            local dl = K.Fill(V.detail, "railGold", "ARTWORK", 1, 0.35)
            dl:SetWidth(1)
            dl:SetPoint("TOPLEFT")
            dl:SetPoint("BOTTOMLEFT")
            V.prev = K.IconButton(V.detail, "left", { L["Previous"] }, function() V:Step(-1) end, 28)
            V.prev:SetPoint("TOPLEFT", 12, -10)
            V.next = K.IconButton(V.detail, "right", { L["Next"] }, function() V:Step(1) end, 28)
            V.next:SetPoint("LEFT", V.prev, "RIGHT", 4, 0)
            V.pos = K.Text(V.detail, "small", "railSoft", "CENTER")
            V.pos:SetPoint("LEFT", V.next, "RIGHT", 6, 0)
            V.close = K.IconButton(V.detail, "close", { CLOSE or "Close" }, function() V:CloseDetail() end, 28)
            V.close:SetPoint("TOPRIGHT", -12, -10)
            V.close:SetFlat(true)
            V.dock = CreateFrame("Frame", nil, V.detail)
            V.dock:SetPoint("TOPLEFT", 0, -46)
            V.dock:SetPoint("BOTTOMRIGHT", 0, 0)

            -- a report of its own in the column: a card on the leather, written by def.detail
            if def.detail then
                V.sheet = K.Card(V.dock)
                V.sheet:SetPoint("TOPLEFT", 10, 0)
                V.sheet:SetPoint("BOTTOMRIGHT", -10, 10)
                V.report = K.Report(V.sheet)
                V.report:SetAllPoints(V.sheet)
                V.report.fill = function() V:FillDetail() end
            end
            function V:FillDetail()
                if self.selected == nil or not self.report then return end
                self.report:Begin()
                local ok, err = pcall(def.detail, self.report, self.selected)
                if not ok then WFD:Error("view " .. def.key, err) end
                self.report:End()
            end
            function V:Select(key)
                self.selected = key
                self:OpenDetail()
                self:FillDetail()
                self.report.scroll:ScrollTo(0)
                self:ShowingCard(key)
            end

            -- the card of Cards.lua opens in the column while this view is on the desk
            function V:OpenDetail()
                if not self.detail:IsShown() then
                    self.detail:Show()
                    self:Arrange()
                end
                return self.dock
            end
            function V:CloseDetail()
                self.selected = nil
                note("key", nil)
                self.detail:Hide()
                if UI.card and UI.card.docked then UI.card:Hide() end
                self:Arrange()
            end
            function V:DockSize()
                return self.detail:GetWidth() or DETAIL_MIN, (self.h or host:GetHeight() or 600) - 46
            end
            function V:Step(dir)
                local cur = def.detail and self.selected or (UI.card and UI.card.key)
                if cur == nil or #self.order == 0 then return end
                local at = 1
                for i, k in ipairs(self.order) do if k == cur then at = i break end end
                local key = self.order[((at - 1 + dir) % #self.order) + 1]
                if def.detail then self:Select(key) else UI:ShowCard(def.cardKind, key) end
            end
            function V:ShowingCard(key)
                note("key", key)
                local at
                for i, k in ipairs(self.order) do if k == key then at = i break end end
                self.pos:SetText(at and (at .. " / " .. #self.order) or "")
                local many = #self.order > 1
                self.prev:SetShown(many)
                self.next:SetShown(many)
                self.list:Reveal(function(item) return item.entry and def.keyOf and def.keyOf(item.entry) == key end)
            end

            function V:PlaceTop(w)
                local x, y, rowH = PAD, -12, 0
                local tiles = def.summary and def.summary() or {}
                for i, t in ipairs(tiles) do
                    local f = self.tiles[i]
                    if not f then
                        f = K.Box(self.top, "inset", nil)
                        f.value = K.Text(f, "value", "ink")
                        f.value:SetPoint("TOPLEFT", 10, -7)
                        f.label = K.Text(f, "small", "muted")
                        f.label:SetPoint("TOPLEFT", f.value, "BOTTOMLEFT", 0, -2)
                        self.tiles[i] = f
                    end
                    f.value:SetText(t[1])
                    f.label:SetText(t[2])
                    local tw = max(f.value:GetStringWidth(), f.label:GetStringWidth()) + 22
                    local th = 7 + f.value:GetStringHeight() + 2 + f.label:GetStringHeight() + 8
                    if x > PAD and x + tw > w - PAD then x, y = PAD, y - rowH - 8 end
                    f:SetSize(tw, th)
                    f:ClearAllPoints()
                    f:SetPoint("TOPLEFT", self.top, "TOPLEFT", x, y)
                    f:Show()
                    x = x + tw + 8
                    rowH = max(rowH, th)
                end
                for i = #tiles + 1, #self.tiles do self.tiles[i]:Hide() end
                if #tiles > 0 then y = y - rowH - 12 end
                -- chips, then search, order and the extra buttons; a line breaks where the room ends
                x, rowH = PAD, 0
                local function put(f, gapAfter)
                    local fw, fh = f:GetWidth(), f:GetHeight()
                    if x > PAD and x + fw > w - PAD then x, y = PAD, y - rowH - 8 rowH = 0 end
                    f:ClearAllPoints()
                    f:SetPoint("TOPLEFT", self.top, "TOPLEFT", x, y)
                    x = x + fw + (gapAfter or 6)
                    rowH = max(rowH, fh)
                end
                for _, b in ipairs(self.chips) do
                    b.style = (b.key == self.state.chip) and "primary" or "secondary"
                    K.Repaint(b)
                    put(b, 4)
                end
                if #self.chips > 0 then x = x + 12 end
                if self.search then put(self.search) end
                self.clear:SetShown(self:Filtered())
                if self.clear:IsShown() then put(self.clear) end
                if self.sort then self.sort:Refresh() put(self.sort) end
                for _, b in ipairs(self.extra) do put(b) end
                y = y - rowH - 12
                self.top:SetHeight(-y)
                return -y
            end

            -- the groups and their entries, laid out for the width of the list
            function V:Arrange()
                local W = self.w or host:GetWidth() or 0
                local H = self.h or host:GetHeight() or 0
                if W <= 0 then return end
                local dw = 0
                if self.detail:IsShown() then
                    dw = max(DETAIL_MIN, min(DETAIL_MAX, floor(W * 0.38)))
                    self.detail:SetWidth(dw)
                end
                local lw = W - dw
                self.top:ClearAllPoints()
                self.top:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
                self.top:SetWidth(lw)
                local topH = self:PlaceTop(lw)
                self.rule:ClearAllPoints()
                self.rule:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -topH)
                self.rule:SetWidth(lw)
                local sf = self.list.sf
                sf:ClearAllPoints()
                sf:SetPoint("TOPLEFT", host, "TOPLEFT", 0, -topH - 1)
                sf:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 0, 0)
                sf:SetWidth(lw)
                self.list.viewH = H - topH - 1
                sf.content:SetWidth(lw)

                local items, y = {}, 14
                local inner = lw - 2 * PAD - 8
                self.order = {}
                local n = 0
                for _, sec in ipairs(self.sections or {}) do
                    if #sec.items > 0 then
                        if sec.title then
                            items[#items + 1] = { kind = "head", x = PAD, y = y, w = inner, h = 36, title = sec.title, right = sec.right, frac = sec.frac }
                            y = y + 36 + 10
                        end
                        if def.cell then
                            local cw, ch, gap = def.cell.w, def.cell.h, def.cell.gap or 12
                            local cols = max(1, floor((inner + gap) / (cw + gap)))
                            local off = floor((inner - (cols * cw + (cols - 1) * gap)) / 2)
                            for i, e in ipairs(sec.items) do
                                local col, row = (i - 1) % cols, floor((i - 1) / cols)
                                items[#items + 1] = { kind = "cell", x = PAD + off + col * (cw + gap), y = y + row * (ch + gap), w = cw, h = ch, entry = e }
                            end
                            y = y + (floor((#sec.items - 1) / cols) + 1) * (ch + gap) + 10
                        else
                            local rh = floor(def.row.h * math.max(1, UI.FONT_SCALE or 1) + 0.5)
                            for _, e in ipairs(sec.items) do
                                items[#items + 1] = { kind = "row", x = PAD - 6, y = y, w = inner + 12, h = rh, entry = e }
                                y = y + rh
                            end
                            y = y + 14
                        end
                        for _, e in ipairs(sec.items) do
                            n = n + 1
                            local k = def.keyOf and def.keyOf(e)
                            if k ~= nil then self.order[#self.order + 1] = k end
                        end
                    end
                end
                self.list:SetItems(items, y + 20, self.keepScroll)
                self.keepScroll = nil
                self.empty:SetShown(n == 0)
                -- nothing because of a filter: the way back to everything is a button below the words
                self.emptyClear:SetShown(n == 0 and self:Filtered())
                if n == 0 then
                    self.empty:SetWidth(max(100, lw - 80))
                    self.empty:ClearAllPoints()
                    self.empty:SetPoint("TOP", sf, "TOP", 0, -50)
                    self.empty:SetText(def.empty and def.empty(self.state) or L["Nothing here yet."])
                    self.emptyClear:ClearAllPoints()
                    self.emptyClear:SetPoint("TOP", self.empty, "BOTTOM", 0, -14)
                end
                if self.detail:IsShown() and UI.card and UI.card.docked and UI.card:IsShown() then
                    UI:FitDockedCard()
                    self:ShowingCard(UI.card.key)
                elseif self.detail:IsShown() and self.selected ~= nil then
                    self:ShowingCard(self.selected)
                end
            end

            function V:Refresh(keepScroll)
                local ok, sections = pcall(def.data, self.state)
                if not ok then WFD:Error("view " .. def.key, sections) sections = {} end
                self.sections = sections
                self.keepScroll = keepScroll
                self:Arrange()
            end

            function V:Layout(w, h)
                self.w, self.h = w, h
                self:Arrange()
            end

            function V:Show(route)
                UI.cardDockProvider = function(kind)
                    if kind ~= def.cardKind then return nil end
                    return V:OpenDetail(), V
                end
                -- the route says everything: what it does not name is back at its start
                self.restoring = true
                self.state.chip = route.chip or CHIP0
                self.state.sort = route.sort or SORT0
                self.state.q = route.q or ""
                if self.search and (self.search:GetText() or "") ~= self.state.q then
                    self.search:SetText(self.state.q)
                    self.search.hint:SetShown(self.state.q == "" and not self.search:HasFocus())
                end
                self.selected = nil
                self.detail:Hide()
                if UI.card and UI.card.docked then UI.card:Hide() end
                self:Refresh()
                if route.key ~= nil and def.detail then self:Select(route.key)
                elseif route.key ~= nil and def.cardKind then UI:ShowCard(def.cardKind, route.key) end
                self.restoring = nil
            end
            function V:Hide()
                if UI.cardDockProvider then UI.cardDockProvider = nil end
                self.selected = nil
                self.detail:Hide()
                if UI.card and UI.card.docked then UI.card:Hide() end
            end
            function V:Head()
                local g = UI.NAV_GROUP[def.group]
                return L[def.label], g and L[g.label], g and UI.GroupRoute(g)
            end
            UI.OnRestyle(function() if host:IsShown() then V:Arrange() end end)
            return V
        end,
    })
end

