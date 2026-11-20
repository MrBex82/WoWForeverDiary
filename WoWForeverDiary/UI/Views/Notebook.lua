-- The notebook: pages of one's own, each with a title and as much text as one likes, kept per character.
-- On the open book the pages are listed on the left (newest change first, a new page, the open one marked), the
-- open page is written on the right: its title, then the text with the numbers of its lines at the margin, as in
-- an editor. The old notes of the groups (C.notes) became pages of their own here.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local R = UI.Router
local floor, max, min, format = math.floor, math.max, math.min, string.format

local MAX_PAGES, MAX_LETTERS = 100, 20000
local PAD = 18

------------------------------------------------------------------------
-- The pages (WFD.C.notebook = { pages = { { id, title, text, t } }, next = id, open = id })
------------------------------------------------------------------------
function UI.Notebook()
    local C = WFD.C
    if not C then return { pages = {}, next = 1 } end
    local nb = C.notebook
    if not nb then
        nb = { pages = {}, next = 1 }
        C.notebook = nb
    end
    -- a list with a gap (a page lost on the way) is closed up again
    local maxN, count = 0, 0
    for k, p in pairs(nb.pages) do
        if type(k) == "number" and k > maxN then maxN = k end
        if type(p) == "table" then count = count + 1 end
    end
    if count < maxN then
        local list = {}
        for i = 1, maxN do if type(nb.pages[i]) == "table" then list[#list + 1] = nb.pages[i] end end
        nb.pages = list
    end
    -- the notes the groups had before: each becomes a page named after its group
    if C.notes then
        for key, text in pairs(C.notes) do
            if type(text) == "string" and text:find("%S") then
                local gk = key:match("^group:(.+)$")
                if gk == "back" then gk = "keep" end          -- (the keepsakes kept the old key of their notes)
                local g = gk and UI.NAV_GROUP[gk]
                nb.pages[#nb.pages + 1] = { id = nb.next, title = g and L[g.label] or key, text = text, t = time() }
                nb.next = nb.next + 1
            end
        end
        C.notes = nil
    end
    return nb
end

local function pageById(nb, id)
    for i, p in ipairs(nb.pages) do if p.id == id then return p, i end end
end

local function newPage(nb)
    if #nb.pages >= MAX_PAGES then return end
    local p = { id = nb.next, title = L["Untitled"], text = "", t = time() }
    nb.next = nb.next + 1
    table.insert(nb.pages, 1, p)
    return p
end

------------------------------------------------------------------------
-- The view
------------------------------------------------------------------------
UI.VIEW_PLACE = UI.VIEW_PLACE or {}
UI.VIEW_PLACE.notebook = { "notebook" }

UI:RegisterView({
    key = "notebook",
    build = function(outer)
        local book, host = K.BookHost(outer)
        local v = { book = book, rows = {}, nums = {} }

        --------------------------------------------------------------------
        -- the left page: the pages
        --------------------------------------------------------------------
        local left = CreateFrame("Frame", nil, host)
        v.left = left
        v.head = K.SectionHead(left, L["Pages"])
        v.head:SetPoint("TOPLEFT", PAD, -PAD)
        v.head:SetPoint("RIGHT", left, "RIGHT", -PAD, 0)
        v.add = K.Button(left, L["New page"], "secondary", function()
            local p = newPage(UI.Notebook())
            if not p then return end
            R.Go({ view = "notebook", page = p.id }, { noHistory = true })
            v.title:SetFocus()
            v.title:HighlightText()
        end)
        v.add:SetPoint("TOPLEFT", v.head, "BOTTOMLEFT", 0, -10)
        local list = K.Scroll(left)
        v.list = list
        list:SetPoint("TOPLEFT", v.add, "BOTTOMLEFT", 0, -10)
        list:SetPoint("BOTTOMRIGHT", left, "BOTTOMRIGHT", -8, 12)

        local function row(i)
            local r = v.rows[i]
            if r then return r end
            r = K.Box(list.content, nil, nil, "Button")
            r.title = K.Text(r, "strong", "ink")
            r.title:SetPoint("TOPLEFT", 10, -7)
            r.title:SetPoint("RIGHT", r, "RIGHT", -10, 0)
            r.title:SetWordWrap(false)
            r.when = K.Text(r, "small", "muted")
            r.when:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -3)
            r:SetScript("OnEnter", function(self) if not self.active then self:SetSurface("hover") end end)
            r:SetScript("OnLeave", function(self) self:SetSurface(self.active and "hover" or nil) end)
            r:SetScript("OnClick", function(self) R.Go({ view = "notebook", page = self.id }, { noHistory = true }) end)
            v.rows[i] = r
            return r
        end

        function v:FillList()
            local nb = UI.Notebook()
            -- the page changed last on top
            table.sort(nb.pages, function(a, b) return (a.t or 0) > (b.t or 0) end)
            self.head:Set(L["Pages"], tostring(#nb.pages))
            local w = max(60, (list:GetWidth() or 200) - 4)
            local y = 0
            for i, p in ipairs(nb.pages) do
                local r = row(i)
                r.id = p.id
                r.active = (p.id == self.page)
                r.title:SetText(p.title ~= "" and p.title or L["Untitled"])
                K.Recolor(r.title, r.active and "title" or "ink")
                r.when:SetText(format(L["Changed %s"], date(WFD.loc and WFD.loc.date or "%d.%m.%Y", p.t or time())))
                r:SetSurface(r.active and "hover" or nil)
                local h = 7 + r.title:GetStringHeight() + 3 + r.when:GetStringHeight() + 8
                r:ClearAllPoints()
                r:SetPoint("TOPLEFT", list.content, "TOPLEFT", 0, -y)
                r:SetSize(w, h)
                r:Show()
                y = y + h + 2
            end
            for i = #nb.pages + 1, #self.rows do self.rows[i]:Hide() end
            list.content:SetWidth(w)
            list:SetContentHeight(y + 4)
            self.add:SetEnabled(#nb.pages < MAX_PAGES)
        end

        --------------------------------------------------------------------
        -- the right page: the title and the text with its line numbers
        --------------------------------------------------------------------
        local right = CreateFrame("Frame", nil, host)
        v.right = right
        local title = CreateFrame("EditBox", nil, right)
        v.title = title
        title:SetAutoFocus(false)
        title:SetMaxLetters(80)
        title:SetHeight(30)
        title:SetPoint("TOPLEFT", PAD, -PAD + 4)
        title:SetPoint("RIGHT", right, "RIGHT", -PAD - 40, 0)
        UI.Skin.Add(title, function(e)
            local font, size = UI.TypeFont("display")
            e:SetFont(font, size, "")
            e:SetTextColor(UI.Tok("title"))
            e:SetHeight(size + 12)
        end)
        title:SetScript("OnEscapePressed", function(e) e:ClearFocus() end)
        title:SetScript("OnEnterPressed", function() v.edit:SetFocus() end)
        title:SetScript("OnTextChanged", function(e, user)
            if not user then return end
            local p = v:Page()
            if not p then return end
            p.title = e:GetText() or ""
            p.t = time()
            v:FillList()
        end)
        v.del = K.IconButton(right, "close", { L["Remove this page"] }, function() v:Remove() end)
        v.del:SetFlat(true)
        v.del:SetPoint("TOPRIGHT", -PAD, -PAD)
        v.rule = K.GoldRule(right)
        v.rule:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
        v.rule:SetPoint("RIGHT", right, "RIGHT", -PAD, 0)

        -- the sheet to write on: a well with the numbers of the lines at its left
        local well = K.Box(right, "inset", "line")
        v.well = well
        well:SetPoint("TOPLEFT", v.rule, "BOTTOMLEFT", 0, -10)
        well:SetPoint("BOTTOMRIGHT", right, "BOTTOMRIGHT", -PAD, PAD)
        local sf = K.Scroll(well)
        v.sf = sf
        sf:SetPoint("TOPLEFT", 1, -1)
        sf:SetPoint("BOTTOMRIGHT", -1, 1)
        local area = sf.content
        v.gutter = area:CreateTexture(nil, "BACKGROUND", nil, 1)
        v.gutter:SetTexture(UI.WHITE)
        v.gutter:SetPoint("TOPLEFT")
        v.gutter:SetPoint("BOTTOMLEFT")
        v.gutterLine = area:CreateTexture(nil, "BACKGROUND", nil, 2)
        v.gutterLine:SetTexture(UI.WHITE)
        v.gutterLine:SetWidth(1)
        v.gutterLine:SetPoint("TOPLEFT", v.gutter, "TOPRIGHT")
        v.gutterLine:SetPoint("BOTTOMLEFT", v.gutter, "BOTTOMRIGHT")
        UI.Skin.Add(well, function()
            local r, g, b = UI.Tok("shade")
            v.gutter:SetVertexColor(r, g, b, 0.18)
            local lr, lg, lb, la = UI.Tok("line")
            v.gutterLine:SetVertexColor(lr, lg, lb, la or 0.3)
        end)

        local eb = CreateFrame("EditBox", nil, area)
        v.edit = eb
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false)
        eb:SetMaxLetters(MAX_LETTERS)
        eb:SetTextInsets(0, 0, 0, 0)
        -- a hidden line of the same writing measures how tall each line of the text is (long lines wrap)
        local measure = area:CreateFontString(nil, "BACKGROUND")
        measure:Hide()
        v.measure = measure
        UI.Skin.Add(eb, function(e)
            local font, size = UI.TypeFont("body")
            e:SetFont(font, size, "")
            e:SetTextColor(UI.Tok("ink"))
            measure:SetFont(font, size, "")
            for _, n in ipairs(v.nums) do n:SetFont(font, max(9, size - 1), "") end
        end)
        eb.hint = K.Text(area, "body", "muted")
        eb.hint:SetPoint("TOPLEFT", eb, "TOPLEFT", 0, 0)
        eb.hint:SetText(L["Write here ..."])
        local function hint(e) e.hint:SetShown((e:GetText() or "") == "" and not e:HasFocus()) end
        eb:SetScript("OnEditFocusGained", hint)
        eb:SetScript("OnEditFocusLost", hint)
        eb:SetScript("OnEscapePressed", function(e) e:ClearFocus() end)
        eb:SetScript("OnTextChanged", function(e, user)
            hint(e)
            if user then
                local p = v:Page()
                if p then
                    p.text = e:GetText() or ""
                    p.t = time()
                    if not v.listDirty then
                        v.listDirty = true
                        C_Timer.After(0.5, function() v.listDirty = nil if host:IsVisible() then v:FillList() end end)
                    end
                end
            end
            v:QueueNumbers()
        end)
        eb:SetScript("OnSizeChanged", function() v:QueueNumbers() end)
        -- the line with the cursor stays in sight
        eb:SetScript("OnCursorChanged", function(e, _, y, _, h)
            if not e:HasFocus() then return end
            local top = 8 - y
            local bottom = top + (h or 16) + 8
            local cur, vh = sf:GetVerticalScroll(), sf:GetHeight() or 0
            if top < cur then sf:ScrollTo(top - 8) elseif bottom > cur + vh then sf:ScrollTo(bottom - vh) end
        end)
        -- a click anywhere on the sheet writes
        well:EnableMouse(true)
        well:SetScript("OnMouseUp", function() eb:SetFocus() end)
        area:EnableMouse(true)
        area:SetScript("OnMouseUp", function() eb:SetFocus() eb:SetCursorPosition(#(eb:GetText() or "")) end)

        -- the numbers of the lines: one for each line of the text, at the height where it begins
        function v:QueueNumbers()
            if self.numPending then return end
            self.numPending = true
            C_Timer.After(0, function()
                self.numPending = nil
                if host:IsVisible() then self:Numbers() end
            end)
        end
        function v:Numbers()
            local text = eb:GetText() or ""
            local w = eb:GetWidth() or 0
            if w <= 1 then return end
            measure:SetWidth(w)
            local y, n = 0, 0
            for line in (text .. "\n"):gmatch("([^\n]*)\n") do
                n = n + 1
                local num = self.nums[n]
                if not num then
                    num = area:CreateFontString(nil, "ARTWORK")
                    local font, size = UI.TypeFont("body")
                    num:SetFont(font, max(9, size - 1), "")
                    num:SetJustifyH("RIGHT")
                    self.nums[n] = num
                end
                num:SetTextColor(UI.Tok("muted"))
                num:SetText(n)
                num:SetWidth(self.gw - 8)
                num:ClearAllPoints()
                num:SetPoint("TOPLEFT", area, "TOPLEFT", 0, -(8 + y))
                num:Show()
                measure:SetText(line ~= "" and line or " ")
                y = y + max(1, measure:GetStringHeight() or 0)
            end
            for i = n + 1, #self.nums do self.nums[i]:Hide() end
            -- a wider margin when the numbers get longer
            local digits = #tostring(n)
            if digits ~= self.digits then
                self.digits = digits
                self:Arrange()
                return
            end
            local h = max(sf:GetHeight() or 0, (eb:GetHeight() or 0) + 16, y + 16)
            area:SetHeight(h)
            sf:SetContentHeight(h)
            -- in the book the sheet is ruled: a faint line under every line of writing, down to the foot
            self.rules = self.rules or {}
            local book = K.IsBook()
            measure:SetText("Ag")
            local lh = max(8, measure:GetStringHeight() or 14)
            local count = book and floor((h - 8) / lh) or 0
            local r, g, b = UI.Tok("rubric")
            for i = 1, count do
                local t = self.rules[i]
                if not t then
                    t = area:CreateTexture(nil, "BACKGROUND", nil, 3)
                    t:SetTexture(UI.WHITE)
                    t:SetHeight(1)
                    self.rules[i] = t
                end
                t:ClearAllPoints()
                t:SetPoint("TOPLEFT", area, "TOPLEFT", self.gw + 4, -(8 + i * lh))
                t:SetPoint("RIGHT", area, "RIGHT", -6, 0)
                t:SetVertexColor(r, g, b, 0.16)
                t:Show()
            end
            for i = count + 1, #self.rules do self.rules[i]:Hide() end
        end

        function v:Page()
            return pageById(UI.Notebook(), self.page)
        end

        function v:Remove()
            local nb = UI.Notebook()
            local p, i = pageById(nb, self.page)
            if not p then return end
            table.remove(nb.pages, i)
            local back = nb.pages[1]
            self.page = back and back.id or nil
            nb.open = self.page
            R.Go({ view = "notebook", page = self.page }, { noHistory = true })
            UI:Notice(L["Page removed."], function()
                table.insert(nb.pages, min(i, #nb.pages + 1), p)
                R.Go({ view = "notebook", page = p.id }, { noHistory = true })
            end)
        end

        function v:FillPage()
            local p = self:Page()
            self.title:SetText(p and p.title or "")
            self.title:SetCursorPosition(0)
            self.edit:SetText(p and p.text or "")
            self.edit:SetCursorPosition(0)
            hint(self.edit)
            self.del:SetEnabled(p ~= nil)
            self.sf:ScrollTo(0)
            self:QueueNumbers()
        end

        --------------------------------------------------------------------
        -- the layout: the pages on the left page, the open page on the right
        --------------------------------------------------------------------
        function v:Arrange()
            local W, H = self.w or host:GetWidth() or 0, self.h or host:GetHeight() or 0
            if W <= 0 or H <= 0 then return end
            local lw = floor(max(200, min(300, W * 0.3)) * UI.FK() + 0.5)
            if W - lw < 320 then lw = max(160, W - 320) end
            book:Lay(lw)
            left:ClearAllPoints()
            left:SetPoint("TOPLEFT", host, "TOPLEFT", 0, 0)
            left:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", 0, 0)
            left:SetWidth(lw)
            right:ClearAllPoints()
            right:SetPoint("TOPLEFT", host, "TOPLEFT", lw, 0)
            right:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", 0, 0)
            -- the margin with the numbers: as wide as the longest number
            measure:SetWidth(0)
            measure:SetText(string.rep("8", max(2, self.digits or 2)))
            self.gw = floor((measure:GetStringWidth() or 16) + 16)
            self.gutter:SetWidth(self.gw)
            local ew = max(60, W - lw - 2 * PAD - 2 - self.gw - 12 - 16)
            eb:ClearAllPoints()
            eb:SetPoint("TOPLEFT", area, "TOPLEFT", self.gw + 10, -8)
            eb:SetWidth(ew)
            area:SetWidth(self.gw + 10 + ew + 6)
            self:FillList()
            self:QueueNumbers()
        end

        function v:Show(route)
            local nb = UI.Notebook()
            if #nb.pages == 0 then newPage(nb) end
            local id = route.page or nb.open
            if not pageById(nb, id) then id = nb.pages[1] and nb.pages[1].id end
            self.page = id
            nb.open = id
            route.page = id
            self:Arrange()
            self:FillPage()
        end
        function v:Hide()
            self.title:ClearFocus()
            self.edit:ClearFocus()
        end
        function v:Layout(w, h)
            self.w, self.h = w - K.BOOK_W, h - K.BOOK_H          -- inside the book
            self:Arrange()
        end
        UI.OnRestyle(function() if host:IsVisible() then v:Arrange() end end)
        function v:Head()
            local p = self:Page()
            return L["Notebook"] .. ((p and p.title ~= "") and ("  -  " .. p.title) or "")
        end
        return v
    end,
})
