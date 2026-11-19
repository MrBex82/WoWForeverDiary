-- The travel desk: the window around everything. A head bar (back, forward, where you are, the search, help,
-- settings, close), the register on the left (the groups and their parts, the own bookmarks) and the desk in
-- the middle, where one view lies open: Start, the book, the settings. The window can be resized at its corner.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

local MIN_W, MIN_H = 760, 520
local DEF_W, DEF_H = 1080, 700
local TOP_H, RAIL_W, RAIL_NARROW = 48, 212, 54
local NARROW_AT = 900          -- below this width the register shows its signs only

local S          -- the shell's frames

-- the width of the register: wider with bigger writing, so the names of the groups stay whole
function UI.RailWidth() return floor(RAIL_W * math.max(1, UI.FONT_SCALE or 1) + 0.5) end
local views = {}

------------------------------------------------------------------------
-- Size of the window
------------------------------------------------------------------------
local function maxSize()
    local sc = UI.holder and UI.holder:GetScale() or 1
    return floor((UIParent:GetWidth() or 1600) / sc), floor((UIParent:GetHeight() or 900) / sc)
end

local function shellSize()
    local sz = WFD.S.shellSize
    local mw, mh = maxSize()
    local w = sz and sz[1] or DEF_W
    local h = sz and sz[2] or DEF_H
    return max(MIN_W, min(mw, w)), max(MIN_H, min(mh, h))
end

-- the holder is the size of the cover while the cover shows, the size of the desk otherwise
function UI:SetHolderMode(mode)
    local h = self.holder
    if mode == "shell" then
        self.inShell = true
        h:SetSize(shellSize())
        if S then S.frame:Show() end
        if h.SetResizable then h:SetResizable(true) end
    else
        self.inShell = false
        h:SetSize(self.CoverSize and self.CoverSize() or 450, UI.PH + 36)
        if S then S.frame:Hide() end
    end
end

------------------------------------------------------------------------
-- The register
------------------------------------------------------------------------
local function newItem(parent)
    local b = K.Box(parent, nil, nil, "Button")
    b:SetHeight(36)
    b.ring = UI.Circle(b, 28, { 1, 1, 1, 1 }, "ARTWORK", 0)
    b.ring:SetPoint("LEFT", 8, 0)
    b.icon = b:CreateTexture(nil, "ARTWORK", nil, 2)
    b.icon:SetSize(22, 22)
    b.icon:SetPoint("CENTER", b.ring, "CENTER")
    b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    UI.Round(b.icon, b)
    b.text = K.Text(b, "strong", "rail")
    b.text:SetPoint("LEFT", b.ring, "RIGHT", 10, 0)
    b.text:SetWordWrap(false)
    b.glow = b:CreateTexture(nil, "BACKGROUND", nil, 2)
    b.glow:SetTexture(UI.WHITE)
    b.glow:SetAllPoints()
    b.accent = K.Fill(b, "railGold", "ARTWORK", 3)
    b.accent:SetWidth(3)
    b.accent:SetPoint("TOPLEFT", -6, -4)
    b.accent:SetPoint("BOTTOMLEFT", -6, 4)
    b.badge = K.Box(b, "gold", nil)
    b.badge:SetSize(20, 18)
    b.badge:SetPoint("RIGHT", -8, 0)
    b.badge.text = K.Text(b.badge, "small", "onGold", "CENTER")
    b.badge.text:SetPoint("CENTER", 0, 0)
    b:SetScript("OnEnter", function(self)
        self.hover = true
        self:Paint()
        -- narrow: the name; wide: the name when it is cut short or there is news to tell
        if S.narrow or self.tip or self.text:IsTruncated() then K.ShowTip(self, self.label, self.tip, "ANCHOR_RIGHT") end
    end)
    b:SetScript("OnLeave", function(self) self.hover = nil self:Paint() GameTooltip:Hide() end)
    function b:Paint()
        local r, g, bb = UI.Tok("railGold")
        local a = self.active and 0.30 or (self.hover and 0.14 or 0)
        UI.Gradient(self.glow, "HORIZONTAL", { r, g, bb, a }, { r, g, bb, 0 })
        self.accent:SetShown(self.active and true or false)
        K.Recolor(self.text, self.active and "railTitle" or "rail")
        local col = self.col or { 0.4, 0.3, 0.2 }
        local k = (self.active or self.hover) and 1.25 or 1
        self.ring:SetVertexColor(min(1, col[1] * k), min(1, col[2] * k), min(1, col[3] * k), 1)
    end
    return b
end

local function newSub(parent)
    local b = K.Box(parent, nil, nil, "Button")
    b:SetHeight(28)
    b.dot = UI.Diamond(b, 5, { 1, 1, 1, 1 }, "ARTWORK", 1)
    b.dot:SetPoint("LEFT", 4, 0)
    b.text = K.Text(b, "body", "railSoft")
    b.text:SetPoint("LEFT", 14, 0)
    b.text:SetSpacing(1)
    b.count = K.Text(b, "small", "railGold", "RIGHT")
    b.count:SetPoint("RIGHT", -8, 0)
    b:SetScript("OnEnter", function(self) self.hover = true self:Paint() end)
    b:SetScript("OnLeave", function(self) self.hover = nil self:Paint() end)
    function b:Paint()
        if not self.glow then
            self.glow = self:CreateTexture(nil, "BACKGROUND", nil, 2)
            self.glow:SetTexture(UI.WHITE)
            self.glow:SetAllPoints()
        end
        local r, g, bb = UI.Tok("railGold")
        UI.Gradient(self.glow, "HORIZONTAL", { r, g, bb, self.active and 0.22 or (self.hover and 0.10 or 0) }, { r, g, bb, 0 })
        K.Recolor(self.text, self.active and "railTitle" or (self.empty and "railMuted" or "railSoft"))
        self.dot:SetVertexColor(UI.Tok(self.active and "railGold" or "railMuted", self.active and 1 or 0.7))
    end
    return b
end

local function newMark(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetHeight(24)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b.flag = b:CreateTexture(nil, "ARTWORK")
    b.flag:SetTexture(UI.WHITE)
    b.flag:SetSize(6, 14)
    b.flag:SetPoint("LEFT", 12, 0)
    b.text = K.Text(b, "body", "railSoft")
    b.text:SetPoint("LEFT", b.flag, "RIGHT", 8, 0)
    b.text:SetPoint("RIGHT", b, "RIGHT", -6, 0)
    b.text:SetWordWrap(false)
    b:SetScript("OnEnter", function(self)
        K.Recolor(self.text, "railTitle")
        K.ShowTip(self, self.mark.title, { { L["Click to open, right-click to remove."], 0.5, 0.8, 1 } }, "ANCHOR_RIGHT")
    end)
    b:SetScript("OnLeave", function(self) K.Recolor(self.text, "railSoft") GameTooltip:Hide() end)
    b:SetScript("OnClick", function(self, button)
        if button == "RightButton" then UI.RemoveMark(self.mark.i) else self.mark.go() end
    end)
    return b
end

-- the group and the part that are open (from the route, or from the page of the book)
local function openPlace()
    local cur = R.cur
    if not cur then return "start" end
    if cur.view == "start" then return "start" end
    if cur.view == "group" then return cur.group end
    local place = UI.VIEW_PLACE and UI.VIEW_PLACE[cur.view]
    if place then return place[1], place[2] end
    return nil
end

function UI:RefreshRail()
    if not S then return end
    local rail = S.rail
    local narrow = S.narrow
    local group, part = openPlace()
    local counts = UI.NewCounts and UI.NewCounts() or {}
    local y = -10
    local ni, si = 0, 0
    for _, g in ipairs(UI.NAV) do
        ni = ni + 1
        local b = S.items[ni] or newItem(rail)
        S.items[ni] = b
        b.col = UI.GROUP_COLOURS[g.key]
        b.icon:SetTexture(UI.Icon(g.icon))
        b.label = L[g.label]
        b.text:SetText(b.label)
        b.text:SetShown(not narrow)
        b.active = (g.key == group)
        local parts = UI.PartsOf(g)
        local new = 0
        for _, p in ipairs(parts) do new = new + (counts[p] or 0) end
        b.badge:SetShown(new > 0 and not (b.active and not narrow))
        b.badge.text:SetText(new > 99 and "99" or tostring(new))
        b.badge:SetWidth(max(20, b.badge.text:GetStringWidth() + 10))
        b.text:SetWidth(max(40, UI.RailWidth() - 12 - 8 - 28 - 10 - (b.badge:IsShown() and (b.badge:GetWidth() + 12) or 8)))
        if narrow then
            b.badge:ClearAllPoints()
            b.badge:SetPoint("TOPRIGHT", b, "TOPRIGHT", -2, -1)
        else
            b.badge:ClearAllPoints()
            b.badge:SetPoint("RIGHT", -8, 0)
        end
        b.tip = new > 0 and { { format(L["%d new since you last read"], new), 1, 0.6, 0.45 } } or nil
        b:SetScript("OnClick", function() R.Go(UI.GroupRoute(g)) end)
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", rail, "TOPLEFT", 6, y)
        b:SetPoint("RIGHT", rail, "RIGHT", -6, 0)
        b:Paint()
        b:Show()
        y = y - 38
        -- the parts of the open group, below it
        if b.active and not narrow and #parts > 1 then
            for _, key in ipairs(parts) do
                si = si + 1
                local sb = S.subs[si] or newSub(rail)
                S.subs[si] = sb
                sb.text:SetWidth(UI.RailWidth() - 44 - 6 - 14 - 30)
                sb.text:SetText(UI.PartLabel(key))
                sb.empty = UI.IsEmptyPart and UI.IsEmptyPart(key)
                sb.active = (key == part)
                local n = counts[key] or 0
                sb.count:SetText(n > 0 and ("+" .. n) or "")
                sb:SetScript("OnClick", function() R.Go(UI.PartRoute(key)) end)
                sb:ClearAllPoints()
                sb:SetPoint("TOPLEFT", rail, "TOPLEFT", 44, y)
                sb:SetPoint("RIGHT", rail, "RIGHT", -6, 0)
                sb:Paint()
                sb:Show()
                local sh = max(26, sb.text:GetStringHeight() + 10)
                sb:SetHeight(sh)
                y = y - sh
            end
            y = y - 6
        end
    end
    for i = ni + 1, #S.items do S.items[i]:Hide() end
    for i = si + 1, #S.subs do S.subs[i]:Hide() end

    -- the own bookmarks at the foot of the register
    local marks = (not narrow and UI.MarkList) and UI.MarkList() or {}
    -- the rows that fit between the groups and the button at the foot (40) below a heading (26)
    local railH = (UI.holder:GetHeight() or DEF_H) - 14 - TOP_H
    local room = floor((railH + y - 76) / 24)
    S.markHead:SetShown(#marks > 0 and room > 0)
    local shown = 0
    for i, m in ipairs(marks) do
        local b = S.marks[i] or newMark(rail)
        S.marks[i] = b
        if i <= room then
            shown = i
            b.mark = m
            b.flag:SetVertexColor(m.col[1], m.col[2], m.col[3], 1)
            b.text:SetText(m.title)
            b:ClearAllPoints()
            b:SetPoint("BOTTOMLEFT", rail, "BOTTOMLEFT", 4, 40 + (math.min(#marks, room) - i) * 24)
            b:SetPoint("RIGHT", rail, "RIGHT", -4, 0)
            b:Show()
        else
            b:Hide()
        end
    end
    for i = #marks + 1, #S.marks do S.marks[i]:Hide() end
    S.markHead:ClearAllPoints()
    S.markHead:SetPoint("BOTTOMLEFT", rail, "BOTTOMLEFT", 16, 40 + shown * 24 + 4)
    S.markHead:SetPoint("RIGHT", rail, "RIGHT", -10, 0)

    S.fold.glyph:SetShape(narrow and "right" or "left")
end
-- a bookmark set or taken away: the register, the button in the head bar and the foot of the diary follow
function UI:OnMarksChanged()
    self:RefreshRail()
    self:RefreshHead()
    local d = views.diary
    if d and d.host:IsShown() and d.PaintFoot then d:PaintFoot() end
end

------------------------------------------------------------------------
-- The head bar: back, forward, where you are
------------------------------------------------------------------------
function UI:RefreshHead()
    if not S then return end
    S.back:SetEnabled(R.CanBack() and true or false)
    S.fwd:SetEnabled(R.CanForward())
    local cur = R.cur
    local v = cur and views[cur.view]
    local title, path, pathRoute
    if v and v.Head then title, path, pathRoute = v:Head(cur) end
    S.title:SetText(title or "")
    S.path:SetText(path or "")
    S.pathBtn.route = pathRoute
    local has = path ~= nil and path ~= ""
    S.pathBtn:SetShown(has)
    S.pathBtn:SetWidth(max(1, S.path:GetStringWidth() + 4))
    S.sep:SetShown(has)
    S.title:ClearAllPoints()
    if has then S.title:SetPoint("LEFT", S.sep, "RIGHT", 6, 0) else S.title:SetPoint("LEFT", S.fwd, "RIGHT", 14, 0) end
    S.title:SetPoint("RIGHT", S.search, "LEFT", -12, 0)
    S.gear:SetActive(cur and cur.view == "settings")
    S.help:SetActive(cur and cur.view == "help")
    -- the bookmark of this place: lit when there is one; not for the settings and the help
    local markable = cur and cur.view ~= "settings" and cur.view ~= "help" and (cur.view ~= "diary" or cur.day ~= nil)
    S.mark:SetShown(markable and true or false)
    S.mark:SetActive(markable and UI.MarkOf and UI.MarkOf(cur) ~= nil)
end

------------------------------------------------------------------------
-- The search in the head bar
------------------------------------------------------------------------
local CHIPS = { { nil, "All" }, { "part", "Parts" }, { "day", "Diary" }, { "person", "Acquaintance" }, { "creature", "Bestiary" },
    { "place", "Maps" }, { "quest", "Quest" }, { "treasure", "Treasures" }, { "catch", "Angler's log" }, { "honour", "Honour" } }
local MAX_ROWS = 10
local paintChips          -- below

local function closeResults()
    if S and S.results:IsShown() then S.results:Hide() return true end
    return false
end

local function chooseRow(i)
    local res = S.results
    local n = 0
    for _, r in ipairs(res.rows) do if r:IsShown() then n = n + 1 end end
    res.sel = n > 0 and ((((i or 1) - 1) % n) + 1) or nil
    for k, r in ipairs(res.rows) do r:SetSurface(k == res.sel and "hover" or nil) end
end

-- a line between the groups of the results: the kind of what follows
local function groupHead(i)
    local res = S.results
    local fs = res.heads[i]
    if not fs then
        fs = K.Text(res, "section", "gold")
        res.heads[i] = fs
    end
    return fs
end

local function showResults()
    local res = S.results
    local text = S.search:GetText() or ""
    -- filters for days (z:, lv:, d:) search the days only: the chip of the diary is chosen while they are typed,
    -- and the chip chosen before comes back when they are gone
    local hits, q, filtered = UI.Search.Find(text, res.kind)
    if filtered and res.kind ~= "day" then
        res.before, res.kind = res.kind or false, "day"
    elseif not filtered and res.before ~= nil then
        res.kind, res.before = res.before or nil, nil
        hits, q = UI.Search.Find(text, res.kind)
    end
    local typed = #text >= 2 or #hits > 0
    if not typed then res:Hide() return end
    if WFD.S then WFD.S.searched = true end
    res:Show()
    paintChips()
    local y = res.chipsBottom or -44
    -- with all kinds, the results come in groups, each below a line with its kind
    local grouped = res.kind == nil
    local lastKind, hi = nil, 0
    for i = 1, MAX_ROWS do
        local row = res.rows[i]
        local h = hits[i]
        if h then
            local e = h.e
            if grouped and e.kind ~= lastKind then
                lastKind, hi = e.kind, hi + 1
                local head = groupHead(hi)
                head:SetText(UI.Upper(UI.Search.KindLabel(e.kind)))
                head:ClearAllPoints()
                head:SetPoint("TOPLEFT", res, "TOPLEFT", 14, y - (hi > 1 and 6 or 0))
                head:Show()
                y = y - (hi > 1 and 6 or 0) - head:GetStringHeight() - 4
            end
            row.kind:SetShown(not grouped)
            row.icon:SetTexture(e.icon)
            if e.kind == "day" and q == "" then
                row.text:SetText("|cffe8c26a" .. e.text .. "|r  " .. (e.zone or "") .. (e.level and ("  -  " .. format(L["Level %d"], e.level)) or ""))
            elseif e.kind == "day" then
                row.text:SetText("|cffe8c26a" .. e.text .. "|r  " .. UI.Search.Mark(UI.Search.Snippet(e.full, e.hay, q), q))
            else
                row.text:SetText(UI.Search.Mark(e.text, q))
            end
            row.kind:SetText(UI.Upper(UI.Search.KindLabel(e.kind)))
            row.go = e.go
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", res, "TOPLEFT", 6, y)
            row:SetPoint("RIGHT", res, "RIGHT", -6, 0)
            row:Show()
            y = y - 28
        else
            row:Hide()
        end
    end
    for i = hi + 1, #res.heads do res.heads[i]:Hide() end
    -- nothing found: what to try instead, and when other kinds have it, a button that searches them all
    res.none:SetShown(#hits == 0)
    res.widen:Hide()
    if #hits == 0 then
        local all = (res.kind and not filtered) and #UI.Search.Find(text, nil) or 0
        if all > 0 then
            res.none:SetText(format(L["Nothing found under %s."], UI.Search.KindLabel(res.kind)))
            res.widen:SetLabel(format(L["Search everywhere (%d)"], all))
        else
            res.none:SetText(filtered and L["No day fits these filters."]
                or L["Nothing found. Try a shorter word, or a name the way the diary writes it."])
        end
        res.none:ClearAllPoints()
        res.none:SetPoint("TOPLEFT", res, "TOPLEFT", 14, y - 4)
        y = y - 4 - res.none:GetStringHeight() - 8
        if all > 0 then
            res.widen:ClearAllPoints()
            res.widen:SetPoint("TOPLEFT", res, "TOPLEFT", 10, y)
            res.widen:Show()
            y = y - res.widen:GetHeight() - 4
        end
    end
    res.more:SetShown(#hits > MAX_ROWS)
    if #hits > MAX_ROWS then
        res.more:SetText(format(L["%d more results, type a little more"], #hits - MAX_ROWS))
        res.more:ClearAllPoints()
        res.more:SetPoint("TOPLEFT", res, "TOPLEFT", 14, y - 4)
        y = y - 22
    end
    res.hint:ClearAllPoints()
    res.hint:SetPoint("TOPLEFT", res, "TOPLEFT", 14, y - 8)
    res:SetHeight(-y + 8 + res.hint:GetStringHeight() + 12)
    chooseRow(1)
end

local function openRow(row)
    if not row or not row.go then return end
    local go = row.go
    closeResults()
    S.search:ClearFocus()
    go()
end

-- the chips in as many rows as they need; the results begin below them
paintChips = function()
    local res = S.results
    local x, y, rowH = 8, -8, 0
    for _, ch in ipairs(res.chips) do
        ch.style = (ch.kind == res.kind) and "primary" or "secondary"
        K.Repaint(ch)
        local w, h = ch:GetWidth(), ch:GetHeight()
        if x > 8 and x + w > res:GetWidth() - 8 then
            x, y = 8, y - rowH - 4
        end
        ch:ClearAllPoints()
        ch:SetPoint("TOPLEFT", res, "TOPLEFT", x, y)
        x = x + w + 4
        rowH = max(rowH, h)
    end
    res.chipsBottom = y - rowH - 8
end

local function buildSearch(top)
    local box = K.Box(top, "inset", "line", "EditBox")
    box:SetSize(250, 30)
    box:SetAutoFocus(false)
    box:SetTextInsets(28, 8, 0, 0)
    box:SetFontObject(ChatFontNormal)
    UI.Skin.Add(box, function(e)
        local font, size = UI.TypeFont("body")
        e:SetFont(font, size, "")
        e:SetTextColor(UI.Tok("ink"))
    end)
    local icon = box:CreateTexture(nil, "OVERLAY")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", 7, 0)
    icon:SetTexture(UI.Icon("search"))
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    box.hint = K.Text(box, "body", "muted")
    box.hint:SetPoint("LEFT", 28, 0)
    box.hint:SetPoint("RIGHT", -8, 0)
    box.hint:SetWordWrap(false)
    box.hint:SetText(L["Search the diary"] .. "  (" .. L["Ctrl + F"] .. ")")
    box:SetScript("OnEditFocusGained", function(s)
        s.hint:Hide()
        s:SetSurface("inset", "gold")
        -- back in the field with words in it: the results are there again
        if (s:GetText() or "") ~= "" and not S.results:IsShown() then showResults() end
    end)
    box:SetScript("OnEditFocusLost", function(s)
        s.hint:SetShown((s:GetText() or "") == "")
        s:SetSurface("inset", "line")
    end)
    box:SetScript("OnTextChanged", function(s)
        s.hint:SetShown((s:GetText() or "") == "" and not s:HasFocus())
        showResults()
    end)
    box:SetScript("OnEscapePressed", function(s)
        if not closeResults() then s:ClearFocus() end
    end)
    box:SetScript("OnEnterPressed", function()
        local res = S.results
        if res:IsShown() and res.sel then openRow(res.rows[res.sel]) end
    end)
    box:SetScript("OnTabPressed", function() if S.results:IsShown() then chooseRow((S.results.sel or 0) + 1) end end)
    if box.SetAltArrowKeyMode then box:SetAltArrowKeyMode(false) end
    box:SetScript("OnArrowPressed", function(_, key)
        local res = S.results
        if not res:IsShown() then return end
        if key == "DOWN" then chooseRow((res.sel or 0) + 1) elseif key == "UP" then chooseRow((res.sel or 2) - 1) end
    end)

    -- the results below the field, over everything else
    local res = K.Box(UIParent, "panel", "gold")
    res:SetFrameStrata("DIALOG")
    res:SetWidth(460)
    res:EnableMouse(true)
    res.chips = {}
    for _, ch in ipairs(CHIPS) do
        local b = K.Button(res, L[ch[2]], "secondary", function(self)
            res.kind, res.before = self.kind, nil
            paintChips()
            showResults()
            box:SetFocus()
        end)
        b.kind = ch[1]
        b.minH = 26
        res.chips[#res.chips + 1] = b
    end
    res.rows = {}
    for i = 1, MAX_ROWS do
        local row = K.Box(res, nil, nil, "Button")
        row:SetHeight(26)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(18, 18)
        row.icon:SetPoint("LEFT", 6, 0)
        row.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        row.kind = K.Text(row, "small", "muted", "RIGHT")
        row.kind:SetPoint("RIGHT", -8, 0)
        row.text = K.Text(row, "body", "ink")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
        row.text:SetPoint("RIGHT", row.kind, "LEFT", -8, 0)
        row.text:SetWordWrap(false)
        row:SetScript("OnEnter", function(self)
            chooseRow(i)
            K.ShowFull(self, "ANCHOR_RIGHT", self.text)
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)
        row:SetScript("OnClick", function(self) openRow(self) end)
        res.rows[i] = row
    end
    res.heads = {}
    res.none = K.Text(res, "body", "soft")
    res.none:SetWidth(460 - 28)
    res.widen = K.Button(res, "", "ghost", function()
        res.kind, res.before = nil, nil
        showResults()
        box:SetFocus()
    end)
    res.widen.minH = 26
    res.more = K.Text(res, "small", "soft")
    res.hint = K.Text(res, "small", "muted")
    res.hint:SetWidth(460 - 28)
    res.hint:SetText(L["Narrow down the days: z:region  lv:20-30  d:30 (the last 30 days)"])
    K.CloseOnClickAway(res, function() return { box } end)
    K.EscapeLayer(res, "WoWForeverDiarySearch")
    res:Hide()
    res:SetScript("OnShow", function(self)
        self:SetScale(box:GetEffectiveScale() / UIParent:GetEffectiveScale())
        self:ClearAllPoints()
        self:SetPoint("TOPRIGHT", box, "BOTTOMRIGHT", 0, -4)
        paintChips()
    end)
    S.results = res
    return box
end

function UI:FocusSearch()
    if not S or not self.inShell then return end
    S.search:SetFocus()
    S.search:HighlightText()
    showResults()
end

------------------------------------------------------------------------
-- Building the desk
------------------------------------------------------------------------
-- the size of the desk, worked out from the size of the window (anchored frames may not know theirs yet in the
-- moment the window opens)
local function contentSize()
    local w, h = UI.holder:GetSize()
    local rw = S.narrow and RAIL_NARROW or UI.RailWidth()
    return max(1, (w or DEF_W) - 14 - rw), max(1, (h or DEF_H) - 14 - TOP_H)
end

local function layout()
    if not S then return end
    local w = UI.holder:GetWidth() or DEF_W
    S.narrow = (w < NARROW_AT) or WFD.S.navCollapsed and true or false
    local rw = S.narrow and RAIL_NARROW or UI.RailWidth()
    S.rail:SetWidth(rw)
    S.search:SetWidth(max(160, min(300, w - rw - 556)))
    UI:RefreshRail()
    local cur = R.cur and views[R.cur.view]
    if cur and cur.Layout then cur:Layout(contentSize()) end
end
UI.LayoutShell = layout

function UI:BuildShell()
    if S then return end
    local h = self.holder
    S = { items = {}, subs = {}, marks = {} }
    UI.shell = S
    local f = K.Box(h, nil, "edge")
    K.Material(f, "leather")
    f:SetAllPoints(h)
    f:SetFrameLevel(h:GetFrameLevel())
    f:EnableMouse(true)
    S.frame = f
    local inner = K.Box(f, nil, "line")
    K.Material(inner, "leaf")
    inner:SetPoint("TOPLEFT", 7, -7)
    inner:SetPoint("BOTTOMRIGHT", -7, 7)
    inner:SetFrameLevel(f:GetFrameLevel() + 1)      -- above the leather of the rim, or the rim covers the desk
    S.inner = inner

    -- moving the window by its head bar
    local top = K.Box(inner, nil, nil)
    K.Material(top, "dark")
    top:SetPoint("TOPLEFT", 1, -1)
    top:SetPoint("TOPRIGHT", -1, -1)
    top:SetHeight(TOP_H)
    top:EnableMouse(true)
    top:RegisterForDrag("LeftButton")
    top:SetScript("OnDragStart", function() if not WFD.S.locked then h:StartMoving() end end)
    top:SetScript("OnDragStop", function()
        h:StopMovingOrSizing()
        if UI.SavePosition then UI:SavePosition() end
    end)
    local rule = K.GoldRule(top)
    rule:SetPoint("BOTTOMLEFT", 0, -4)
    rule:SetPoint("BOTTOMRIGHT", 0, -4)
    rule:SetFrameLevel(top:GetFrameLevel() + 5)
    S.top = top

    S.back = K.IconButton(top, "left", { L["Back"], L["To the page you came from (Backspace)."] }, function() R.Back() end)
    S.back:SetPoint("LEFT", 9, 0)
    S.fwd = K.IconButton(top, "right", { L["Forward"] }, function() R.Forward() end)
    S.fwd:SetPoint("LEFT", S.back, "RIGHT", 4, 0)

    -- where you are: the group as a link, then the name of what is open
    S.pathBtn = CreateFrame("Button", nil, top)
    S.path = K.Text(S.pathBtn, "body", "railSoft")
    S.path:SetPoint("LEFT", 0, 0)
    S.pathBtn:SetPoint("LEFT", S.fwd, "RIGHT", 14, 0)
    S.pathBtn:SetHeight(24)
    S.path.onPaint = function(fs) S.pathBtn:SetWidth(max(1, fs:GetStringWidth() + 4)) end
    S.pathBtn:SetScript("OnEnter", function() K.Recolor(S.path, "railTitle") end)
    S.pathBtn:SetScript("OnLeave", function() K.Recolor(S.path, "railSoft") end)
    S.pathBtn:SetScript("OnClick", function(self) if self.route then R.Go(self.route) end end)
    S.sep = K.Glyph(top, "right", 10, "railMuted")
    S.sep:SetPoint("LEFT", S.pathBtn, "RIGHT", 2, 0)
    S.title = K.Text(top, "heading", "railTitle")
    S.title:SetPoint("LEFT", S.sep, "RIGHT", 6, 0)
    S.title:SetWordWrap(false)

    S.close = K.IconButton(top, "close", { CLOSE or "Close" }, function() UI:Hide() end)
    S.close:SetPoint("RIGHT", -9, 0)
    S.close:SetFlat(true)
    S.gear = K.IconButton(top, "icon:" .. UI.Icon("settings"), { L["Settings"] }, function()
        if R.cur and R.cur.view == "settings" then R.Back() else R.Go({ view = "settings" }) end
    end)
    S.gear:SetPoint("RIGHT", S.close, "LEFT", -6, 0)
    S.help = K.IconButton(top, "text:?", { L["Help"], L["Keys, mouse and commands"] }, function()
        if R.cur and R.cur.view == "help" then R.Back() else R.Go({ view = "help" }) end
    end)
    S.help:SetPoint("RIGHT", S.gear, "LEFT", -6, 0)
    S.mark = K.IconButton(top, "mark", nil, function() UI.ToggleMarkAt(R.cur) end)
    K.Tip(S.mark, function() return UI.MarkOf(R.cur) and L["Remove the bookmark"] or L["Set a bookmark"] end,
        function() return { L["Bookmarks stand at the foot of the register."] } end)
    S.mark:SetPoint("RIGHT", S.help, "LEFT", -6, 0)
    S.search = buildSearch(top)
    S.search:SetPoint("RIGHT", S.mark, "LEFT", -10, 0)
    S.title:SetPoint("RIGHT", S.search, "LEFT", -12, 0)

    -- the register
    local rail = K.Box(inner, nil, nil)
    K.Material(rail, "dark")
    rail:SetPoint("TOPLEFT", top, "BOTTOMLEFT", 0, 0)
    rail:SetPoint("BOTTOMLEFT", 1, 1)
    rail:SetWidth(RAIL_W)
    local rr = K.Fill(rail, "railGold", "ARTWORK", 1, 0.35)
    rr:SetWidth(1)
    rr:SetPoint("TOPRIGHT")
    rr:SetPoint("BOTTOMRIGHT")
    S.rail = rail
    S.markHead = K.Text(rail, "section", "railGold")
    S.markHead:SetText(UI.Upper(L["Bookmarks"]))
    S.fold = K.IconButton(rail, "left", { L["Narrow register"], L["Shows the register as signs only."] }, function()
        WFD.S.navCollapsed = not WFD.S.navCollapsed or nil
        layout()
    end, 26)
    S.fold:SetFlat(true)
    S.fold:SetPoint("BOTTOMLEFT", 12, 8)

    -- the desk
    local content = CreateFrame("Frame", nil, inner)
    content:SetPoint("TOPLEFT", rail, "TOPRIGHT", 0, 0)
    content:SetPoint("BOTTOMRIGHT", -1, 1)
    if content.SetClipsChildren then content:SetClipsChildren(true) end
    S.content = content

    -- the grip in the corner
    local grip = CreateFrame("Button", nil, f)
    grip:SetSize(18, 18)
    grip:SetPoint("BOTTOMRIGHT", -2, 2)
    grip:SetFrameLevel(inner:GetFrameLevel() + 30)
    for i, len in ipairs({ 12, 7 }) do
        local t = K.Fill(grip, "gold", "OVERLAY", 0)
        t:SetSize(len, 2)
        t:SetPoint("CENTER", grip, "CENTER", 2 + i * 1.5, -2 + i * 1.5)
        if t.SetRotation then t:SetRotation(math.pi / 4) end
    end
    grip:SetScript("OnMouseDown", function()
        if WFD.S.locked then return end
        local mw, mh = maxSize()
        if h.SetResizeBounds then h:SetResizeBounds(MIN_W, MIN_H, mw, mh)
        elseif h.SetMinResize then h:SetMinResize(MIN_W, MIN_H) h:SetMaxResize(mw, mh) end
        h:StartSizing("BOTTOMRIGHT")
        S.sizing = true
    end)
    grip:SetScript("OnMouseUp", function()
        if not S.sizing then return end
        S.sizing = nil
        h:StopMovingOrSizing()
        local w, hh = h:GetSize()
        WFD.S.shellSize = { floor(w + 0.5), floor(hh + 0.5) }
        if UI.SavePosition then UI:SavePosition() end
        layout()
        local cur = R.cur and views[R.cur.view]
        if cur and cur.Settled then cur:Settled() end
    end)
    K.Tip(grip, L["Drag to change the size of the window."], { L["Ctrl + mouse wheel changes the size of everything."] })
    h:HookScript("OnSizeChanged", function() if UI.inShell then layout() end end)

    -- Ctrl + mouse wheel anywhere on the desk scales the window
    f:EnableMouseWheel(true)
    f:SetScript("OnMouseWheel", function(_, delta) if IsControlKeyDown() and UI.StepScale then UI:StepScale(delta) end end)

    -- keep the desk up to date while playing: when the diary changed and the mouse is not on the window
    local acc = 0
    f:SetScript("OnUpdate", function(_, dt)
        acc = acc + dt
        if acc < 10 then return end
        acc = 0
        if not WFD.dirty or h:IsMouseOver() then return end
        WFD.dirty = false
        if UI.storyCache then UI.storyCache[WFD:NumDays()] = nil end
        local v = R.cur and views[R.cur.view]
        if v and v.Refresh then v:Refresh(true) end      -- true: keep the place the reader scrolled to
        UI:RefreshRail()
    end)

    f:Hide()
    UI.OnRestyle(function() layout() UI:RefreshHead() end)
    -- what was open when the window closed is where it opens again
    h:HookScript("OnHide", function()
        UI:KeepPlace()
        closeResults()
        K.CloseMenu()
        K.CloseDialog()
    end)
end

------------------------------------------------------------------------
-- Showing a route
------------------------------------------------------------------------
local function viewFor(key)
    local v = views[key]
    if v then return v end
    local def = UI.Views[key]
    if not def then return nil end
    local host = CreateFrame("Frame", nil, S.content)
    host:SetAllPoints(S.content)
    v = def.build(host)
    v.host = host
    views[key] = v
    return v
end

function UI:ShowRoute(route)
    if not S then return end
    local v = viewFor(route.view)
    if not v then return end
    for key, other in pairs(views) do
        if other ~= v and other.host:IsShown() then
            other.host:Hide()
            if other.Hide then other:Hide() end
        end
    end
    closeResults()
    GameTooltip:Hide()
    v.host:Show()
    if v.Layout then v:Layout(contentSize()) end
    v:Show(route)
    -- the part on the desk is looked at: its count of news goes
    local place = UI.VIEW_PLACE and UI.VIEW_PLACE[route.view]
    if place and UI.PartSeen then UI.PartSeen(place[2]) end
    self:RefreshRail()
    self:RefreshHead()
end

------------------------------------------------------------------------
-- A short note at the foot of the desk (4 seconds, longer while the mouse is on it), with a button to undo
-- (fn, label: what the button does and says; without fn no button). Outside the window: in the chat.
------------------------------------------------------------------------
function UI:Notice(text, fn, label)
    if not (S and self.inShell and self.holder and self.holder:IsShown()) then
        print("|cffffd100WoW Forever Diary:|r " .. text)
        return
    end
    local n = S.notice
    if not n then
        n = K.Box(S.content, "panel", "gold")
        n:SetFrameStrata("DIALOG")
        n:EnableMouse(true)
        n.text = K.Text(n, "body", "ink")
        n.text:SetPoint("LEFT", 14, 0)
        n.act = K.Button(n, "", "ghost")
        n.act.minH = 26
        n.act:SetPoint("RIGHT", -8, 0)
        n:SetScript("OnUpdate", function(self, dt)
            if self:IsMouseOver() then return end
            self.left = (self.left or 0) - dt
            if self.left <= 0 then self:Hide() end
        end)
        S.notice = n
    end
    n.text:SetText(text)
    n.act:SetShown(fn ~= nil)
    if fn then
        n.act:SetLabel(label or L["Undo"])
        n.act.onClick = function() n:Hide() fn() end
    end
    local cw = contentSize()
    local w = max(200, min(cw - 32, 560))
    n.text:SetWidth(w - 28 - (fn and (n.act:GetWidth() + 12) or 0))
    n:SetSize(w, max(40, n.text:GetStringHeight() + 20))
    n:ClearAllPoints()
    n:SetPoint("BOTTOM", S.content, "BOTTOM", 0, 16)
    n.left = 4
    n:Show()
end

-- the view object of a key, once it was built (for the load test)
function UI.ViewInstance(key) return views[key] end

function UI:ShellCloseLayer()
    return closeResults()
end
function UI:ShellBack() R.Back() end

------------------------------------------------------------------------
-- The place where the window was left: the route and the way back, kept through closing and through /reload
-- (WFD.C.lastPlace; not in the demo). Only plain values are kept, and only routes to views that exist.
------------------------------------------------------------------------
local function plainRoute(r)
    if type(r) ~= "table" or not (r.view and UI.Views[r.view]) then return nil end
    local out = {}
    for k, v in pairs(r) do
        local t = type(v)
        if type(k) == "string" and (t == "string" or t == "number" or t == "boolean") then out[k] = v end
    end
    return out
end

function UI:KeepPlace()
    local cur = plainRoute(R.Resume())
    if not cur then return end
    local back = {}
    for _, r in ipairs(R.back) do back[#back + 1] = plainRoute(r) end
    self.lastPlace = { route = cur, back = back }
    if WFD.C and not WFD.demo then WFD.C.lastPlace = self.lastPlace end
end

-- where a fresh window opens (route: asked for), with the way back laid out
local function resumePlace(self, route)
    local saved = self.lastPlace or (WFD.C and not WFD.demo and WFD.C.lastPlace)
    local last = saved and plainRoute(saved.route)
    if saved then
        for _, r in ipairs(saved.back or {}) do
            local ok = plainRoute(r)
            if ok then R.back[#R.back + 1] = ok end
        end
    end
    -- Start / the last place / at the first opening after logging in Start, then the last place
    local mode = WFD.S.openAt or "auto"
    local toLast = last and not route and (mode == "last" or (mode == "auto" and self.lastPlace ~= nil))
    if toLast then return last end
    -- somewhere else first: Back leads to where the window was left
    if last then R.back[#R.back + 1] = last end
    while #R.back > 40 do table.remove(R.back, 1) end
    return route or { view = "start" }
end

------------------------------------------------------------------------
-- Opening and closing
------------------------------------------------------------------------
-- route: where to open (nil = where the window was left, or Start)
function UI:OpenShell(route)
    self:Build()
    self:BuildShell()
    local fresh = not (self.holder:IsShown() and self.inShell)
    if fresh then
        local C = WFD.C
        if C and not C.seenAt then C.seenAt = time() end
        self.openedOnce = true
        GameTooltip:Hide()
        self.cover:Hide()
        self:SetHolderMode("shell")
        self.holder:Show()
        UI.Sound("IG_SPELLBOOK_OPEN", 829)
        WFD.dirty = false
        if self.storyCache then self.storyCache[WFD:NumDays()] = nil end
        R.Reset()
        R.cur = nil
        layout()
        route = resumePlace(self, route)
    end
    R.Go(route or { view = "start" })
end

function UI:OpenStart() self:OpenShell({ view = "start" }) end

-- the settings, from the minimap button
function UI:OpenSettings() self:OpenShell({ view = "settings" }) end

local show0 = UI.Show
function UI:Show()
    self:Build()
    self:BuildShell()
    self:SetHolderMode("cover")
    show0(self)
end

-- the cover shows first: in the demo, else by the setting (never / once ever / at the first opening of a session)
function UI:WantsCover()
    if WFD.demo then return true end
    if self.openedOnce then return false end
    local mode = WFD.S.coverMode or "once"
    if mode == "session" then return true end
    if mode == "once" and not WFD.S.coverSeen then
        WFD.S.coverSeen = true
        return true
    end
    return false
end

function UI:Toggle()
    self:Build()
    if self.holder:IsShown() then
        self:Hide()
    elseif self:WantsCover() then
        self:Show()
    else
        self:OpenShell()
    end
end

function UI:OnDataSwitched()
    if not S or not self.inShell then return end
    self.storyCache = {}
    local v = R.cur and views[R.cur.view]
    if v and v.Refresh then v:Refresh() end
    self:RefreshRail()
    self:RefreshHead()
end
