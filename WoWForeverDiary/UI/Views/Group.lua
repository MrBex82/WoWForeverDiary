-- The overview of a group on the travel desk: its crest and name, one card for every part (its figure, a line on
-- what it holds, what is new) and the notes you keep on the group. A click on a card opens the part.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, abs, format = math.floor, math.max, math.min, math.abs, string.format

local PAD, GAP = 18, 14
-- the old key of a group (for its notes, kept in the book as "group:<key>")
local OLD_KEY = { keep = "back" }
-- the picture of a part that has no page in the book any more, and its line
local VIEW_ICON = { bestiary = "beast", fishbook = "fish", treasures = "loot", honour = "honour", tasks = "task",
    collection = "album", people = "people", quests = "quests", atlas = "atlas", runs = "runs", fates = "skull",
    companions = "party", stable = "mount", standing = "banner", ledger = "stats", milestones = "level", firsts = "first",
    records = "records", levels = "level", yearbook = "journal", recap = "time", gallery = "gallery", landmarks = "sight", fishwaters = "fish",
    library = "journal", family = "kin", capsule = "capsule", memoriam = "skull", diary = "quill" }
local VIEW_SUB = { bestiary = "A collector's album of every creature slain",
    fishbook = "A collector's album of everything the line brought up" }

local function partInfo(key)
    local sec = UI.SectionOf(key)
    local lay = UI.LAYOUT and UI.LAYOUT[key]
    return (sec and sec.icon) or VIEW_ICON[key] or "journal", VIEW_SUB[key] or (sec and sec.sub) or (lay and lay[3])
end

local function newCard(parent)
    local c = K.Card(parent)
    c:EnableMouse(true)
    c.hl = c:CreateTexture(nil, "ARTWORK", nil, 0)
    c.hl:SetTexture(UI.WHITE)
    c.hl:SetAllPoints()
    c.hl:Hide()
    c.ring = UI.Circle(c, 44, { 1, 1, 1, 1 }, "ARTWORK", 1)
    c.ring:SetPoint("TOPLEFT", PAD, -PAD)
    c.icon = c:CreateTexture(nil, "ARTWORK", nil, 3)
    c.icon:SetSize(36, 36)
    c.icon:SetPoint("CENTER", c.ring, "CENTER")
    c.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    UI.Round(c.icon, c)
    c.stat = K.Text(c, "value", "ink", "RIGHT")
    c.stat:SetPoint("TOPRIGHT", -PAD, -PAD - 2)
    c.new = K.Text(c, "small", "gold", "RIGHT")
    c.new:SetPoint("TOPRIGHT", c.stat, "BOTTOMRIGHT", 0, -3)
    c.name = K.Text(c, "heading", "title")
    c.name:SetPoint("TOPLEFT", c.ring, "TOPRIGHT", 12, -2)
    c.name:SetWordWrap(false)
    c.sub = K.Text(c, "body", "soft")
    c.sub:SetSpacing(2)
    c:SetScript("OnEnter", function(self)
        local r, g, b = UI.Tok("gold")
        self.hl:SetVertexColor(r, g, b, 0.08)
        self.hl:Show()
        self.borderKey = "gold"
        K.Repaint(self)
    end)
    c:SetScript("OnLeave", function(self)
        self.hl:Hide()
        self.borderKey = "line"
        K.Repaint(self)
    end)
    c:SetScript("OnMouseUp", function(self) if self.key then R.Go(UI.PartRoute(self.key)) end end)
    function c:Set(key, col, counts)
        self.key = key
        local icon, sub = partInfo(key)
        local empty = UI.IsEmptyPart and UI.IsEmptyPart(key)
        self.ring:SetVertexColor(col[1], col[2], col[3], 1)
        self.icon:SetTexture(UI.Icon(icon))
        self.icon:SetDesaturated(empty and true or false)
        self.name:SetText(UI.PartLabel(key))
        self.sub:SetText(empty and L["Fills as soon as there is something to tell."] or (sub and L[sub] or ""))
        K.Recolor(self.sub, empty and "muted" or "soft")
        local v = UI.PartStat and UI.PartStat(key)
        self.stat:SetText(v ~= nil and tostring(v) or "")
        local n = counts[key] or 0
        self.new:SetText(n > 0 and format(L["%d new"], n) or "")
    end
    function c:Measure(w)
        self:SetWidth(w)
        local right = max(self.stat:GetStringWidth(), self.new:GetStringWidth())
        self.name:SetWidth(max(60, w - PAD * 2 - 56 - right - 10))
        self.sub:ClearAllPoints()
        self.sub:SetPoint("TOPLEFT", self, "TOPLEFT", PAD, -(PAD + 44 + 12))
        self.sub:SetWidth(w - 2 * PAD)
        local h = PAD + 44 + 12 + self.sub:GetStringHeight() + PAD
        return max(h, PAD + 44 + PAD)
    end
    return c
end

UI:RegisterView({
    key = "group",
    build = function(host)
        local v = { cards = {} }
        local scroll = K.Scroll(host)
        scroll:SetAllPoints(host)
        local area = scroll.content

        -- the head: the crest of the group, its name, how many parts and what is new
        v.ring = UI.Circle(area, 64, { 1, 1, 1, 1 }, "ARTWORK", 0)
        v.rim = UI.Circle(area, 70, { 1, 1, 1, 1 }, "BACKGROUND", 0)
        v.icon = area:CreateTexture(nil, "ARTWORK", nil, 2)
        v.icon:SetSize(52, 52)
        v.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        UI.Round(v.icon, area)
        v.title = K.Text(area, "display", "title")
        v.title:SetWordWrap(false)
        v.sub = K.Text(area, "body", "soft")
        v.rule = K.GoldRule(area)

        -- the notes of the group
        v.notes = K.Card(area)
        v.notes.head = K.SectionHead(v.notes, L["Notes"])
        v.notes.head:SetPoint("TOPLEFT", PAD, -PAD)
        v.notes.head:SetPoint("RIGHT", v.notes, "RIGHT", -PAD, 0)
        local eb = CreateFrame("EditBox", nil, v.notes)
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false)
        eb:SetMaxLetters(4000)
        -- only the top is fixed: the box grows with the text, and the card and the page grow with it
        eb:SetPoint("TOPLEFT", PAD, -PAD - 30)
        eb:SetPoint("TOPRIGHT", -PAD, -PAD - 30)
        UI.Skin.Add(eb, function(e)
            local font, size = UI.TypeFont("body")
            e:SetFont(font, size, "")
            e:SetTextColor(UI.Tok("ink"))
        end)
        eb.hint = K.Text(v.notes, "body", "muted")
        eb.hint:SetPoint("TOPLEFT", eb, "TOPLEFT", 0, 0)
        eb.hint:SetText(L["Click here to write your own notes ..."])
        local function hint(e) e.hint:SetShown((e:GetText() or "") == "" and not e:HasFocus()) end
        eb:SetScript("OnEditFocusGained", hint)
        eb:SetScript("OnEditFocusLost", hint)
        eb:SetScript("OnEscapePressed", function(e) e:ClearFocus() end)
        eb:SetScript("OnTextChanged", function(e, user)
            hint(e)
            if user and v.noteKey and WFD.C then
                local t = e:GetText() or ""
                WFD.C.notes = WFD.C.notes or {}
                WFD.C.notes[v.noteKey] = (t ~= "") and t or nil
            end
        end)
        -- a longer note makes the card taller (checked each frame while the box is shown, as the box grows a
        -- frame after the text), and the page follows the cursor while writing
        eb:SetScript("OnSizeChanged", function()
            if abs(v:NotesHeight() - (v.notesH or 0)) >= 1 then v:Arrange() end
        end)
        eb:SetScript("OnCursorChanged", function(e, _, y, _, h)
            if not e:HasFocus() then return end
            v.cursorY, v.cursorH = y, h
            C_Timer.After(0, function() v:KeepCursor() end)
        end)
        v.notes:EnableMouse(true)
        v.notes:SetScript("OnMouseUp", function() eb:SetFocus() end)
        v.edit = eb

        function v:NotesHeight()
            return max(170, (self.edit:GetHeight() or 0) + PAD * 2 + 30 + 10)
        end
        -- the line with the cursor stays in sight of the scrolling page
        function v:KeepCursor()
            local cy = self.cursorY
            if not cy or not self.notesY then return end
            local top = self.notesY + PAD + 30 - cy
            local bottom = top + (self.cursorH or 16) + 8
            local cur, vh = scroll:GetVerticalScroll(), scroll:GetHeight() or 0
            if top < cur then
                scroll:ScrollTo(top - 8)
            elseif bottom > cur + vh then
                scroll:ScrollTo(bottom - vh)
            end
        end

        function v:Fill()
            local g = UI.NAV_GROUP[self.group]
            if not g then return end
            local col = UI.GROUP_COLOURS[g.key] or { 0.4, 0.3, 0.2 }
            self.ring:SetVertexColor(col[1], col[2], col[3], 1)
            local r, gg, b = UI.Tok("gold")
            self.rim:SetVertexColor(r, gg, b, 1)
            self.icon:SetTexture(UI.Icon(g.icon))
            self.title:SetText(L[g.label])
            local counts = UI.NewCounts and UI.NewCounts() or {}
            local parts = UI.PartsOf(g)
            local new = 0
            for i, key in ipairs(parts) do
                local c = self.cards[i] or newCard(area)
                self.cards[i] = c
                c:Set(key, col, counts)
                c:Show()
                new = new + (counts[key] or 0)
            end
            for i = #parts + 1, #self.cards do self.cards[i]:Hide() end
            self.n = #parts
            self.sub:SetText(format(L["%d parts"], #parts) .. (new > 0 and ("  -  " .. format(L["%d new since you last read"], new)) or ""))
            self.noteKey = "group:" .. (OLD_KEY[g.key] or g.key)
            local text = WFD.C and WFD.C.notes and WFD.C.notes[self.noteKey] or ""
            if not self.edit:HasFocus() then self.edit:SetText(text) end
            hint(self.edit)
        end

        function v:Arrange()
            local W = (self.w or scroll:GetWidth() or 0) - 2 * 24
            if W <= 0 then return end
            local x0, y = 24, 22
            self.rim:ClearAllPoints()
            self.rim:SetPoint("TOPLEFT", area, "TOPLEFT", x0, -y)
            self.ring:ClearAllPoints()
            self.ring:SetPoint("CENTER", self.rim, "CENTER")
            self.icon:ClearAllPoints()
            self.icon:SetPoint("CENTER", self.rim, "CENTER")
            self.title:ClearAllPoints()
            self.title:SetPoint("TOPLEFT", self.rim, "TOPRIGHT", 16, -6)
            self.title:SetWidth(W - 90)
            self.sub:ClearAllPoints()
            self.sub:SetPoint("TOPLEFT", self.title, "BOTTOMLEFT", 2, -6)
            self.sub:SetWidth(W - 90)
            y = y + 70 + 14
            self.rule:ClearAllPoints()
            self.rule:SetPoint("TOPLEFT", area, "TOPLEFT", x0, -y)
            self.rule:SetWidth(W)
            y = y + 22
            local cols = (W >= 900) and 3 or ((W >= 560) and 2 or 1)
            local cw = (W - (cols - 1) * GAP) / cols
            for i = 1, self.n or 0, cols do
                local rowH = 0
                for k = i, min(self.n, i + cols - 1) do rowH = max(rowH, self.cards[k]:Measure(cw)) end
                for k = i, min(self.n, i + cols - 1) do
                    local c = self.cards[k]
                    c:ClearAllPoints()
                    c:SetPoint("TOPLEFT", area, "TOPLEFT", x0 + (k - i) * (cw + GAP), -y)
                    c:SetHeight(rowH)
                end
                y = y + rowH + GAP
            end
            y = y + 6
            self.notes:ClearAllPoints()
            self.notes:SetPoint("TOPLEFT", area, "TOPLEFT", x0, -y)
            self.notesY = y
            self.notesH = self:NotesHeight()
            self.notes:SetSize(W, self.notesH)
            y = y + self.notesH + 20
            scroll:SetContentHeight(y)
        end

        function v:Refresh()
            local ok, err = pcall(self.Fill, self)
            if not ok then WFD:Error("group", err) end
            self:Arrange()
        end
        function v:Show(route)
            if route.group ~= self.group then scroll:ScrollTo(0) end
            self.group = route.group
            self:Refresh()
        end
        function v:Layout(w, h) self.w = w self:Arrange() end
        scroll.onResize = function(sf) v.w = sf:GetWidth() v:Arrange() end
        UI.OnRestyle(function() if host:IsShown() then v:Refresh() end end)
        function v:Head()
            local g = UI.NAV_GROUP[self.group]
            return g and L[g.label] or "", nil
        end
        return v
    end,
})
