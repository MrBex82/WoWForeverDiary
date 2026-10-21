-- Comfort while reading: the way back, a page by its number, keys, the size and place of the book,
-- marks for what is new, a short introduction, the notifications and an entry in the game's options.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format

------------------------------------------------------------------------
-- Notifications: everything, only what matters, or nothing
------------------------------------------------------------------------
local IMPORTANT = {
    level = true, boss = true, rare = true, epic = true, rareitem = true, death = true, dungeon = true,
    capsule = true, honour = true, weekly = true,
}
function WFD:ShouldNotify(kind)
    local level = self.S and self.S.notify or "all"
    if level == "quiet" then return false end
    if level == "important" then return IMPORTANT[kind] == true end
    return true
end

------------------------------------------------------------------------
-- The way back
------------------------------------------------------------------------
function UI:Back()
    local h = self.history
    if not h or #h == 0 then return end
    local s = table.remove(h)
    self:ShowSpread(s)
end

function UI:UpdateBack()
    if self.backBtn then self.backBtn:SetShown(self.history and #self.history > 0) end
end

local function buildBack(bf)
    local b = CreateFrame("Button", nil, bf)
    b:SetSize(30, 30)
    -- beside the arrow that turns back, where the hand already is
    b:SetPoint("LEFT", UI.prevBtn, "RIGHT", 6, 0)
    b:SetFrameLevel(bf:GetFrameLevel() + 20)
    local ring = UI.Circle(b, 28, { 0.10, 0.05, 0.02, 1 }, "BACKGROUND", 0)
    ring:SetPoint("CENTER")
    local rim = UI.Circle(b, 26, c.goldDk, "BORDER", 0)
    rim:SetPoint("CENTER")
    local inner = UI.Circle(b, 22, { 0.22, 0.12, 0.06, 1 }, "ARTWORK", 0)
    inner:SetPoint("CENTER")
    local arrow = b:CreateTexture(nil, "ARTWORK", nil, 1)
    arrow:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    arrow:SetSize(26, 26)
    arrow:SetPoint("CENTER", -1, 0)
    b:SetScript("OnClick", function() UI:Back() end)
    b:SetScript("OnEnter", function(s)
        rim:SetVertexColor(col4(c.gold))
        GameTooltip:SetOwner(s, "ANCHOR_TOP")
        GameTooltip:SetText(L["Back"], 1, 0.86, 0.5)
        GameTooltip:AddLine(L["To the page you came from (Backspace)."], 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function()
        rim:SetVertexColor(col4(c.goldDk))
        GameTooltip:Hide()
    end)
    b:Hide()
    UI.backBtn = b
end

------------------------------------------------------------------------
-- Go to a page by its number
------------------------------------------------------------------------
local ask
function UI:AskPage()
    local bf = self.bookFrame
    if not bf then return end
    if not ask then
        ask = UI.Frame(bf, 220, 64)
        ask:SetPoint("BOTTOM", bf, "BOTTOM", 0, 46)
        ask:SetFrameLevel(bf:GetFrameLevel() + 40)
        UI.Backdrop(ask, "tooltip", 12, 3, { 0.10, 0.07, 0.04, 0.96 }, c.goldDk)
        ask:EnableMouse(true)
        local t = UI.Text(ask, 12, c.gold, "CENTER", UI.HEAD, true)
        t:SetPoint("TOP", 0, -10)
        ask.label = t
        local ok, e = pcall(CreateFrame, "EditBox", nil, ask, "InputBoxTemplate")
        if not (ok and e) then
            e = CreateFrame("EditBox", nil, ask, BackdropTemplateMixin and "BackdropTemplate" or nil)
            UI.Backdrop(e, nil, 1, 0, { 0, 0, 0, 0.6 }, c.goldDk)
            e:SetFontObject(ChatFontNormal)
        end
        e:SetSize(70, 22)
        e:SetPoint("BOTTOM", 0, 10)
        e:SetAutoFocus(false)
        e:SetNumeric(true)
        e:SetMaxLetters(4)
        e:SetJustifyH("CENTER")
        e:SetScript("OnEnterPressed", function(s)
            local n = tonumber(s:GetText())
            s:ClearFocus()
            ask:Hide()
            if n and UI.book then UI:GoToPage(max(1, min(#UI.book.pages, n + 1))) end
        end)
        e:SetScript("OnEscapePressed", function(s) s:ClearFocus() ask:Hide() end)
        e:SetScript("OnEditFocusLost", function() ask:Hide() end)
        ask.edit = e
        ask:Hide()
    end
    local last = self.book and UI.PageNumber(#self.book.pages) or 1
    ask.label:SetText(format(L["Go to page (1 - %d):"], last))
    ask:Show()
    ask.edit:SetText("")
    ask.edit:SetFocus()
end

------------------------------------------------------------------------
-- Own bookmarks: Ctrl-click a page number to keep that page; a silk ribbon then sticks out of the top
-- of the book. Kept like the place where reading stopped (a day, or a page within its part), so they
-- follow their page while the book grows.
------------------------------------------------------------------------
local MARK_COLS = {
    { 0.18, 0.40, 0.62 }, { 0.22, 0.48, 0.24 }, { 0.66, 0.48, 0.12 }, { 0.44, 0.20, 0.56 }, { 0.10, 0.46, 0.46 }, { 0.62, 0.26, 0.10 },
}
local MAX_MARKS, MARK_W, MARK_H = 12, 20, 46
local markFrames = {}

local function placeOf(index)
    local b = UI.book
    local page = b and b.pages[index]
    if not page then return nil end
    local day
    for d, i in pairs(b.dayPage) do if i == index then day = d end end
    local start = page.section and b.sectionStart[page.section]
    -- head: what the page itself calls its place (the area of an album, the chapter of the diary)
    return { section = page.section, offset = start and (index - start) or nil, day = day, head = page.head }
end

local function resolveMark(m)
    local b = UI.book
    if not b or not m then return nil end
    if m.day and b.dayPage[m.day] then return b.dayPage[m.day] end
    local start = m.section and b.sectionStart[m.section]
    if not start then return nil end
    local idx = start + (m.offset or 0)
    local page = b.pages[idx]
    if page and page.section == m.section then return idx end
    return start
end

local function sectionLabel(key)
    if key == "toc" then return L["Contents"] end
    if key == "diary" then return L["Diary"] end
    for _, s in ipairs(UI.sections) do if s.key == key then return L[s.label] end end
    return ""
end

-- the name of a bookmark, written when it is read so that it follows the language: "Diary, day 9",
-- "Bestiary, Westfall"
local function markTitle(mk)
    local part = sectionLabel(mk.section)
    if mk.day then return part .. ", " .. format(L["Day %d"], mk.day) end
    local head = mk.head and L[mk.head]
    if head and head ~= "" and head ~= part then return part .. ", " .. head end
    return part
end

function UI:UpdateMarks()
    local bf, C = self.bookFrame, WFD.C
    if not bf then return end
    local marks = C and C.marks or {}
    local left, right = (self.spread or 1) * 2 - 1, (self.spread or 1) * 2
    for i = 1, MAX_MARKS do
        local f = markFrames[i]
        local m = marks[i]
        local idx = m and resolveMark(m)
        if f then f:Hide() end
        if idx then
            if not f then
                f = CreateFrame("Button", nil, UI.holder)
                f:SetSize(MARK_W, MARK_H)
                f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                f.body = UI.GradRect(f, "VERTICAL", { 0, 0, 0, 1 }, { 1, 1, 1, 1 }, "ARTWORK", 0)
                f.body:SetAllPoints()
                for _, side in ipairs({ "LEFT", "RIGHT" }) do
                    local g = UI.Fill(f, c.gold, "ARTWORK", 2, 0.6)
                    g:SetWidth(1)
                    g:SetPoint("TOP" .. side, f, "TOP" .. side, side == "LEFT" and 1 or -1, 0)
                    g:SetPoint("BOTTOM" .. side, f, "BOTTOM" .. side, side == "LEFT" and 1 or -1, 0)
                end
                f.num = UI.Text(f, 9, { 1, 0.95, 0.82, 1 }, "CENTER", UI.FONT, true)
                f.num:SetPoint("TOP", 0, -5)
                f:SetScript("OnClick", function(s, button)
                    if button == "RightButton" then
                        table.remove(WFD.C.marks, s.i)
                        GameTooltip:Hide()
                        UI:UpdateMarks()
                        UI:UpdateEars()
                    else
                        local to = resolveMark(WFD.C.marks[s.i])
                        if to then UI:GoToPage(to) end
                    end
                end)
                f:SetScript("OnEnter", function(s)
                    s:SetPoint("BOTTOMLEFT", bf, "TOPLEFT", s.x, s.y + 4)
                    local mk = WFD.C.marks[s.i]
                    local to = resolveMark(mk)
                    GameTooltip:SetOwner(s, "ANCHOR_TOP")
                    GameTooltip:SetText(mk and markTitle(mk) or L["Bookmark"], 1, 0.86, 0.5)
                    if to then GameTooltip:AddLine(format(L["Page %d"], UI.PageNumber(to)), 0.8, 0.8, 0.8) end
                    GameTooltip:AddLine(L["Click to open, right-click to remove."], 0.5, 0.8, 1)
                    GameTooltip:Show()
                end)
                f:SetScript("OnLeave", function(s)
                    s:SetPoint("BOTTOMLEFT", bf, "TOPLEFT", s.x, s.y)
                    GameTooltip:Hide()
                end)
                markFrames[i] = f
            end
            local col = MARK_COLS[((i - 1) % #MARK_COLS) + 1]
            UI.Gradient(f.body, "HORIZONTAL", { col[1] * 0.55, col[2] * 0.55, col[3] * 0.55, 1 }, { col[1], col[2], col[3], 1 })
            f.num:SetText(UI.PageNumber(idx))
            f.i = i
            -- the ribbon of a page that is open stands a little taller
            local open = (idx == left or idx == right)
            f.x, f.y = 60 + (i - 1) * (MARK_W + 8), open and -12 or -20
            f:SetFrameLevel(max(0, bf:GetFrameLevel() - 1))
            f:ClearAllPoints()
            f:SetPoint("BOTTOMLEFT", bf, "TOPLEFT", f.x, f.y)
            f:SetShown(bf:IsShown())
        end
    end
end

-- the dog-ear in the upper outer corner of each page: a click keeps the page, a second click lets it go
local earBtns = {}
local function pageMarked(index)
    for i, m in ipairs(WFD.C and WFD.C.marks or {}) do
        if resolveMark(m) == index then return i end
    end
end
local function paintEar(b)
    local marked = b.index and pageMarked(b.index)
    local col = marked and c.gold or { 0.42, 0.31, 0.19, 1 }
    b.flap:SetVertexColor(col[1], col[2], col[3], 1)
    b:SetAlpha((marked or b.hover) and 1 or 0.55)
end
function UI:UpdateEars()
    local s = self.spread or 1
    for side, b in pairs(earBtns) do
        local index = (side == "left") and (s * 2 - 1) or (s * 2)
        local page = self.book and self.book.pages[index]
        b.index = index
        b:SetShown(page ~= nil and page.kind ~= "endpaper")
        paintEar(b)
    end
end
local function buildEars()
    for _, side in ipairs({ "left", "right" }) do
        local pf = UI.pageFrames[side]
        local corner = side == "left" and "TOPLEFT" or "TOPRIGHT"
        local b = CreateFrame("Button", nil, pf)
        b:SetSize(30, 30)
        b:SetPoint(corner, pf, corner, 0, 0)
        b:SetFrameLevel(pf.canvas:GetFrameLevel() + 10)
        if b.SetClipsChildren then b:SetClipsChildren(true) end
        local inner = CreateFrame("Frame", nil, b)
        inner:SetAllPoints()
        b.shadow = UI.Diamond(inner, 30, { 0, 0, 0, 0.45 }, "ARTWORK", 0)
        b.shadow:SetPoint("CENTER", b, corner, 0, 0)
        b.flap = UI.Diamond(inner, 24, { 0.42, 0.31, 0.19, 1 }, "ARTWORK", 1)
        b.flap:SetPoint("CENTER", b, corner, 0, 0)
        b:SetScript("OnClick", function(s) if s.index then UI:ToggleMark(s.index) end end)
        b:SetScript("OnEnter", function(s)
            s.hover = true
            paintEar(s)
            GameTooltip:SetOwner(s, "ANCHOR_TOP")
            GameTooltip:SetText(L["Bookmark"], 1, 0.86, 0.5)
            GameTooltip:AddLine(s.index and pageMarked(s.index) and L["Click to remove the bookmark."] or L["Click to set a bookmark here."], 0.5, 0.8, 1)
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function(s) s.hover = nil paintEar(s) GameTooltip:Hide() end)
        earBtns[side] = b
    end
end

function UI:ToggleMark(index)
    local C = WFD.C
    if not C or not self.book then return end
    C.marks = C.marks or {}
    for i, m in ipairs(C.marks) do
        if resolveMark(m) == index then
            table.remove(C.marks, i)
            self:UpdateMarks()
            self:UpdateEars()
            return
        end
    end
    local p = placeOf(index)
    if not p then return end
    if #C.marks >= MAX_MARKS then
        -- no quiet loss of the oldest: say that the book is full
        print("|cffffd100WoW Forever Diary:|r " .. format(L["All %d bookmarks are in use. Remove one first."], MAX_MARKS))
        return
    end
    C.marks[#C.marks + 1] = p
    self:UpdateMarks()
    self:UpdateEars()
    UI.Sound("IG_ABILITY_PAGE_TURN", 836)
end

------------------------------------------------------------------------
-- Keys, while the mouse is over the open book (so walking and fighting stay untouched)
------------------------------------------------------------------------
local KEYS = {
    LEFT = function() UI:Flip(-1) end, PAGEUP = function() UI:Flip(-1) end,
    RIGHT = function() UI:Flip(1) end, PAGEDOWN = function() UI:Flip(1) end,
    HOME = function() if UI.book and UI.book.sectionStart.toc then UI:GoToPage(UI.book.sectionStart.toc) end end,
    END = function() UI:GoToPage(UI:TodayPage()) end,
    BACKSPACE = function() UI:Back() end,
    ["CTRL-F"] = function() if UI.ToggleSearch then UI:ToggleSearch() end end,
}
local function propagate(frame, v)
    if frame.SetPropagateKeyboardInput and not (InCombatLockdown and InCombatLockdown()) then
        pcall(frame.SetPropagateKeyboardInput, frame, v)
    end
end
-- Escape closes what lies on top of the book first (a card, the search); the book itself only after that
local function closeLayer()
    if UI.card and UI.card:IsShown() then UI.card:Hide() return true end
    if UI.kindPanel and UI.kindPanel:IsShown() then UI.kindPanel:Hide() return true end
    if UI.searchPanel and UI.searchPanel:IsShown() then UI.searchPanel:Hide() return true end
    return false
end

local function setupKeys(holder)
    if not holder.EnableKeyboard then return end
    holder:EnableKeyboard(true)
    propagate(holder, true)
    holder:SetScript("OnKeyDown", function(self, key)
        local fn = (IsControlKeyDown() and KEYS["CTRL-" .. key]) or KEYS[key]
        local typing = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
        if key == "ESCAPE" then
            if not typing and not (InCombatLockdown and InCombatLockdown()) and closeLayer() then
                propagate(self, false)
                C_Timer.After(0, function() propagate(self, true) end)
            else
                propagate(self, true)
            end
            return
        end
        if fn and not typing and UI.bookFrame:IsShown() and self:IsMouseOver() and not (InCombatLockdown and InCombatLockdown()) then
            propagate(self, false)
            fn()
            -- hand the keyboard straight back to the game
            C_Timer.After(0, function() propagate(self, true) end)
        else
            propagate(self, true)
        end
    end)
end

------------------------------------------------------------------------
-- Size (Ctrl + mouse wheel) and place of the book
------------------------------------------------------------------------
local sizeLabel, relayout
function UI:StepScale(delta)
    local S = WFD.S
    local s = floor(((S.scale or 0.9) + (delta > 0 and 0.05 or -0.05)) * 100 + 0.5) / 100
    s = max(0.6, min(1.4, s))
    S.scale = s
    self.holder:SetScale(s)
    if not sizeLabel then
        sizeLabel = UI.Text(self.bookFrame, 16, c.gold, "CENTER", UI.HEAD, true)
        sizeLabel:SetPoint("TOP", self.bookFrame, "BOTTOM", 0, -6)
    end
    sizeLabel:SetText(format(L["Size: %d%%"], floor(s * 100 + 0.5)))
    sizeLabel:Show()
    -- the pages are laid out again once the wheel rests (text is measured at the size it is drawn at)
    relayout = (relayout or 0) + 1
    local mine = relayout
    C_Timer.After(0.4, function()
        if mine ~= relayout then return end
        UI.ClearCaches()
        if UI.bookFrame:IsShown() then
            UI:Paginate()
            UI:ShowSpread(UI.spread)
        end
    end)
    C_Timer.After(1.5, function() if mine == relayout and sizeLabel then sizeLabel:Hide() end end)
end

function UI:SavePosition()
    local h = self.holder
    if not h then return end
    local p, _, rp, x, y = h:GetPoint(1)
    if p then WFD.S.pos = { p, rp, x, y } end
end

function UI:ResetPosition()
    WFD.S.pos = nil
    if self.holder then
        self.holder:ClearAllPoints()
        self.holder:SetPoint("CENTER")
    end
end

local function restorePosition(h)
    local p = WFD.S.pos
    if not p then return end
    h:ClearAllPoints()
    h:SetPoint(p[1], UIParent, p[2], p[3], p[4])
end

------------------------------------------------------------------------
-- Turning a leaf: a sheet narrows towards the spine on one side and opens out on the other
------------------------------------------------------------------------
local sheet
local TURN = 0.34
function UI:TurnSweep(dir)
    local lp, rp = self.pageFrames.left, self.pageFrames.right
    if not sheet then
        sheet = CreateFrame("Frame", nil, self.bookFrame)
        sheet.base = UI.Fill(sheet, c.paper, "ARTWORK", 0)
        sheet.base:SetAllPoints()
        if UI.THEME ~= "modern" then
            sheet.art = UI.TiledArt(sheet, UI.PAGE_ART, "ARTWORK", 1)
        end
        sheet.shade = sheet:CreateTexture(nil, "ARTWORK", nil, 2)
        sheet.shade:SetAllPoints()
        sheet.dark = UI.Fill(sheet, { 0, 0, 0 }, "ARTWORK", 3, 0)
        sheet.dark:SetAllPoints()
        sheet.edge = UI.Fill(sheet, c.goldDk, "ARTWORK", 4, 0.6)
        sheet.edge:SetWidth(1)
    end
    sheet:SetFrameLevel(lp.canvas:GetFrameLevel() + 4)
    local W, H = rp:GetWidth(), rp:GetHeight()
    local from, to = (dir > 0) and rp or lp, (dir > 0) and lp or rp
    sheet.t = 0
    sheet:SetAlpha(1)
    sheet:Show()
    local function place(page, w)
        -- the edge at the spine stays put, the free edge moves
        local spineLeft = (page == rp)
        sheet:ClearAllPoints()
        sheet:SetPoint(spineLeft and "TOPLEFT" or "TOPRIGHT", page, spineLeft and "TOPLEFT" or "TOPRIGHT", 0, 0)
        sheet:SetSize(math.max(1, w), H)
        local dark, clear = { 0, 0, 0, 0.55 }, { 0, 0, 0, 0 }
        if spineLeft then UI.Gradient(sheet.shade, "HORIZONTAL", dark, clear) else UI.Gradient(sheet.shade, "HORIZONTAL", clear, dark) end
        sheet.edge:ClearAllPoints()
        sheet.edge:SetPoint(spineLeft and "TOPRIGHT" or "TOPLEFT")
        sheet.edge:SetPoint(spineLeft and "BOTTOMRIGHT" or "BOTTOMLEFT")
    end
    place(from, W)
    sheet:SetScript("OnUpdate", function(s, dt)
        s.t = s.t + dt
        local p = math.min(1, s.t / TURN)
        p = p * p * (3 - 2 * p)                       -- slow at the start and at the end
        if p < 0.5 then
            place(from, W * (1 - p * 2))
        else
            place(to, W * (p * 2 - 1))
        end
        -- the leaf is darkest when it stands upright over the spine
        s.dark:SetAlpha(0.45 * (1 - math.abs(p * 2 - 1)))
        if p > 0.85 then s:SetAlpha((1 - p) / 0.15) end
        if s.t >= TURN then
            s:SetScript("OnUpdate", nil)
            s:Hide()
        end
    end)
end

------------------------------------------------------------------------
-- New since the book was last read: a dot on the bookmark
------------------------------------------------------------------------
local function newCounts(since)
    local C = WFD.C
    local n = {}
    local function add(k) n[k] = (n[k] or 0) + 1 end
    for _, m in pairs(C.mobs or {}) do if (m.first or 0) > since then add("bestiary") end end
    for _, p in pairs(C.npcs or {}) do if not p.obj and (p.first or 0) > since then add("people") end end
    for _, q in pairs(C.quests or {}) do if (q.done or 0) > since then add("quests") end end
    for _, t in pairs(C.rares or {}) do if type(t) == "number" and t > since then add("treasures") end end
    for _, e in pairs(C.catch or {}) do if (e.first or 0) > since then add("fishbook") end end
    for _, z in pairs(C.zones or {}) do if (z.first or 0) > since then add("maps") end end
    for _, e in ipairs(C.events or {}) do
        if (e.t or 0) > since then
            if e.k == "honour" then add("honour") elseif e.k == "first" then add("firsts") end
        end
    end
    return n
end

-- what is new since the book was last put away, per part ({} in the demo); the "Today" page lists it
function UI.NewCounts()
    local since = UI.readSince
    if not since or WFD.demo then return {} end
    return newCounts(since)
end

function UI:PaintNewDots(activeKey)
    if not self.thumbs then return end
    self.visited = self.visited or {}
    if activeKey then self.visited[activeKey] = true end
    local since = self.readSince
    local counts = (since and not WFD.demo) and newCounts(since) or {}
    -- a group's tab shows what is new in all of its parts
    for _, sec in ipairs(UI.sections) do
        local n = counts[sec.key]
        if n and sec.group and not self.visited[sec.key] then
            counts["grp_" .. sec.group] = (counts["grp_" .. sec.group] or 0) + n
        end
    end
    for _, t in ipairs(self.thumbs) do
        local n = (not self.visited[t.key]) and counts[t.key] or 0
        t.newCount = n
        if n > 0 and not rawget(t, "dot") then
            local d = CreateFrame("Frame", nil, t)
            d:SetSize(16, 16)
            d:SetFrameLevel(t:GetFrameLevel() + 5)
            local ring = UI.Circle(d, 16, { 0.12, 0.04, 0.02, 1 }, "ARTWORK", 0)
            ring:SetPoint("CENTER")
            local fill = UI.Circle(d, 13, { 0.85, 0.18, 0.12, 1 }, "ARTWORK", 1)
            fill:SetPoint("CENTER")
            d.text = UI.Text(d, 8, { 1, 1, 1, 1 }, "CENTER", UI.FONT, true)
            d.text:SetPoint("CENTER", 0, 0)
            d:SetPoint("CENTER", t, "TOPRIGHT", -6, -2)
            d:Hide()
            t.dot = d
        end
        if rawget(t, "dot") then
            local was = t.dot:IsShown()
            t.dot:SetShown(n > 0)
            if n > 0 then t.dot.text:SetText(n > 99 and "99" or tostring(n)) end
            if n > 0 and not was then
                t.dot.t = 0
                t.dot:SetScript("OnUpdate", function(d, dt)
                    d.t = d.t + dt
                    if d.t > 2.4 then d:SetAlpha(1) d:SetScript("OnUpdate", nil) return end
                    d:SetAlpha(0.55 + 0.45 * (0.5 + 0.5 * math.cos(d.t * 2 * math.pi / 0.8)))
                end)
            end
        end
    end
end

------------------------------------------------------------------------
-- A short introduction on the first opening: notes pinned beside the parts they explain
------------------------------------------------------------------------
local TOUR = {
    { "thumbs", "The tabs", "The tabs on the right lead to the parts of the book, one colour for each group. Point at them to read their names. A red dot shows how much is new since you last read." },
    { "search", "Search", "The spyglass on the spine searches the whole book: days, people, creatures, quests, places, treasures and catches. Ctrl + F opens it too." },
    { "ribbon", "Turning pages", "Turn the pages with the arrows, the mouse wheel or the arrow keys. The red ribbon below always leads to today; Backspace takes you back. Ctrl + mouse wheel changes the size of the book." },
    { "marks", "Your own bookmarks", "Click the folded corner of a page to keep it. A ribbon then sticks out of the top of the book: a click opens the page, a right-click takes the ribbon away." },
    { "companion", "The companion", "A small window beside the game shows today's figures, the tasks and the honours closest to their next tier. You can switch it on and off in the settings." },
    { "page", "Almost everything can be clicked", "Cards, names, days and maps open more. Click the page number to go to any page. The settings have a tab of their own at the bottom." },
}
local note
-- only: a single step on its own (a step added after the reader already knew the introduction)
local function tourStep(i, only)
    local bf = UI.bookFrame
    local step = TOUR[i]
    if not step or not bf:IsShown() then
        if note then note:Hide() end
        WFD.S.tourDone = true
        WFD.S.tourMarks = true
        return
    end
    if not note then
        note = UI.Frame(UI.holder, 270, 150)
        note:SetFrameStrata("DIALOG")
        UI.Backdrop(note, "tooltip", 14, 4, { 0.08, 0.05, 0.03, 0.97 }, c.gold)
        note:EnableMouse(true)
        note.title = UI.Text(note, 15, c.gold, "LEFT", UI.HEAD, true)
        note.title:SetPoint("TOPLEFT", 14, -12)
        note.text = UI.Text(note, 12, { 0.96, 0.90, 0.76, 1 }, "LEFT", UI.FONT, true)
        note.text:SetPoint("TOPLEFT", 14, -34)
        note.text:SetWidth(242)
        note.text:SetJustifyV("TOP")
        note.count = UI.Text(note, 9, { 0.75, 0.65, 0.48, 1 }, "LEFT", UI.FONT, true)
        note.count:SetPoint("BOTTOMLEFT", 14, 12)
        local function btn(text, x, fn)
            local b = CreateFrame("Button", nil, note)
            b:SetSize(90, 20)
            b:SetPoint("BOTTOMRIGHT", x, 8)
            b.t = UI.Text(b, 12, c.gold, "RIGHT", UI.HEAD, true)
            b.t:SetPoint("RIGHT")
            b.t:SetText(text)
            b:SetScript("OnClick", fn)
            b:SetScript("OnEnter", function(s) s.t:SetTextColor(1, 1, 0.85, 1) end)
            b:SetScript("OnLeave", function(s) s.t:SetTextColor(col4(c.gold)) end)
            return b
        end
        note.next = btn(L["Next"] .. "  >", -14, function() tourStep(note.only and (#TOUR + 1) or (note.i + 1)) end)
        note.skip = btn(L["Skip"], -110, function() tourStep(#TOUR + 1) end)
        -- on the companion's note: switch it on right away
        note.extra = btn(L["Show it"], -110, function()
            if UI.ShowCompanion then UI:ShowCompanion(true) end
            tourStep(note.only and (#TOUR + 1) or (note.i + 1))
        end)
        note.pin = UI.Diamond(note, 14, c.gold, "OVERLAY", 0)
    end
    note.i, note.only = i, only
    note.title:SetText(L[step[2]])
    note.text:SetText(L[step[3]])
    note.count:SetText(only and "" or (i .. " / " .. #TOUR))
    note.next.t:SetText((only or i == #TOUR) and L["Got it"] or (L["Next"] .. "  >"))
    local offer = step[1] == "companion" and not WFD.S.companion
    note.skip:SetShown(not only and i < #TOUR and not offer)
    note.extra:SetShown(offer)
    note:SetHeight(max(110, note.text:GetStringHeight() + 74))
    note:ClearAllPoints()
    note.pin:ClearAllPoints()
    if step[1] == "thumbs" and UI.thumbs and UI.thumbs[1] then
        note:SetPoint("LEFT", UI.thumbs[3] or UI.thumbs[1], "RIGHT", 40, 0)
        note.pin:SetPoint("CENTER", note, "LEFT", 0, 0)
    elseif step[1] == "search" and UI.searchButton then
        note:SetPoint("TOP", UI.searchButton, "BOTTOM", 0, -14)
        note.pin:SetPoint("CENTER", note, "TOP", 0, 0)
    elseif step[1] == "ribbon" then
        note:SetPoint("BOTTOM", bf, "BOTTOM", 0, 60)
        note.pin:SetPoint("CENTER", note, "BOTTOM", 0, 0)
    elseif step[1] == "companion" then
        note:SetPoint("RIGHT", bf, "RIGHT", -60, 40)
        note.pin:SetPoint("CENTER", note, "RIGHT", 0, 0)
    elseif step[1] == "marks" then
        -- below the top edge, where the ribbons stick out
        note:SetPoint("TOPLEFT", bf, "TOPLEFT", 50, -30)
        note.pin:SetPoint("CENTER", note, "TOPLEFT", 24, 0)
    else
        note:SetPoint("CENTER", bf, "CENTER", 0, 0)
        note.pin:SetPoint("CENTER", note, "TOP", 0, 0)
    end
    note:Show()
end
-- key: show only that step (for readers who already know the rest)
function UI:StartTour(key)
    if key then
        for i, s in ipairs(TOUR) do if s[1] == key then return tourStep(i, true) end end
    end
    tourStep(1)
end

------------------------------------------------------------------------
-- Opening the book at the scribe's notes (minimap right click, game options)
------------------------------------------------------------------------
function UI:OpenSettings()
    self:OpenBook(function(book) return book.sectionStart.notes or 1 end)
end

------------------------------------------------------------------------
-- Hooks into the book
------------------------------------------------------------------------
local build0 = UI.Build
function UI:Build()
    local fresh = not self.holder
    build0(self)
    if not fresh then return end
    buildBack(self.bookFrame)
    buildEars()
    setupKeys(self.holder)
    restorePosition(self.holder)
    -- the own bookmarks belong to the open book, like the red ribbon
    self.bookFrame:HookScript("OnHide", function() for _, f in pairs(markFrames) do f:Hide() end end)
    -- the moment the book is put away counts as "read until now"
    self.holder:HookScript("OnHide", function()
        if WFD.C and not WFD.demo then WFD.C.seenAt = time() end
        if note then note:Hide() end
        if ask then ask:Hide() end
    end)
end

-- the ribbons follow every turn of a page (their pages may have moved, the open one stands taller)
local spread0 = UI.ShowSpread
function UI:ShowSpread(s)
    spread0(self, s)
    self:UpdateMarks()
    self:UpdateEars()
end

local open0 = UI.OpenBook
function UI:OpenBook(page)
    local C = WFD.C
    if C and not C.seenAt then C.seenAt = time() end
    self.readSince = C and C.seenAt
    self.visited = {}
    open0(self, page)
    if not WFD.S.tourDone then
        C_Timer.After(0.3, function() UI:StartTour() end)
    elseif not WFD.S.tourMarks then
        -- the introduction is known, the own bookmarks came later: that one step on its own
        C_Timer.After(0.3, function() UI:StartTour("marks") end)
    end
end

------------------------------------------------------------------------
-- The page of handling: notifications, keys, the book itself
------------------------------------------------------------------------
UI:RegisterRenderer("handling", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Handling"], nil, -56, UI.SettingsTabs(2))
    local S = WFD.S
    local function caption(text)
        local t = pool:Text(10, c.redInk, UI.FONT)
        t:SetText(text:upper())
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - 18
    end
    local function links(items)
        local x = tx
        for _, it in ipairs(items) do
            local fs = pool:Link(it.text, it.fn, 13, it.active and c.redInk or c.inkSoft)
            local w = fs:GetStringWidth()
            if x > tx and x + w > tx + tw then x = tx; y = y - 20 end
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
            if it.active then
                local u = pool:Rect(c.redInk, 1)
                u:SetSize(w, 1)
                u:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
            end
            x = x + w + 16
        end
        y = y - 24
    end
    local function small(text)
        local t = pool:Text(12, c.inkSoft, UI.FONT)
        t:SetWidth(tw)
        t:SetText(text)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - t:GetStringHeight() - 10
    end
    local redraw = function() UI:ShowSpread(UI.spread) end

    caption(L["Notifications"])
    local level = S.notify or "all"
    links({
        { text = L["All"], active = level == "all", fn = function() S.notify = "all"; redraw() end },
        { text = L["Important only"], active = level == "important", fn = function() S.notify = "important"; redraw() end },
        { text = L["Quiet"], active = level == "quiet", fn = function() S.notify = "quiet"; redraw() end },
    })
    small(L["Important: levels, bosses, rare creatures and finds, dungeons, honours and letters."])

    caption(L["Companion"])
    local cb = pool:Check(L["Show the companion beside the game"], function() return S.companion end, function(v) UI:ShowCompanion(v) end)
    cb:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    y = y - 26
    small(L["A small window with today's figures, the tasks and the honours closest to their next tier. Drag it by its title, fold it with the minus."])

    caption(L["The book"])
    links({
        { text = L["Reset the position"], fn = function() UI:ResetPosition() end },
        { text = L["Show the introduction again"], fn = function() WFD.S.tourDone = nil; UI:StartTour() end },
    })

    caption(L["Moving to another computer"])
    links({
        { text = L["Make a moving code"], fn = function() UI:ShowMovingExport() end },
        { text = L["Read a moving code"], fn = function() UI:ShowMovingImport() end },
    })
    small(L["Or simply take the WTF folder of the game with you: it holds the diaries of all characters."])
end)

------------------------------------------------------------------------
-- The page of the keys: what the keyboard and the mouse do in the book
------------------------------------------------------------------------
UI:RegisterRenderer("keys", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Keys"], nil, -56, UI.SettingsTabs(3))
    local t = pool:Text(10, c.redInk, UI.FONT)
    t:SetText(L["Keys while the mouse is over the book"]:upper())
    t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    y = y - 22
    local rows = {
        { L["Arrow keys, Page up / down"], L["turn the page"] },
        { L["Home"], L["contents"] },
        { L["End"], L["today's entry"] },
        { L["Backspace"], L["back"] },
        { L["Ctrl + F"], L["search the book"] },
        { L["Ctrl + mouse wheel"], L["size of the book"] },
        { L["Click the page number"], L["go to a page"] },
        { L["Click the folded corner"], L["bookmark"] },
        { "/wfd", L["open or close the book"] },
    }
    for _, r in ipairs(rows) do UI.LeaderLine(pool, canvas, tx, y, tw, r[1], r[2], 13, c.inkSoft); y = y - 22 end
    y = y - 8
    local n = pool:Text(12, c.inkSoft, UI.FONT)
    n:SetWidth(tw)
    n:SetText(L["A key to open the book can be set in the game's key bindings, under AddOns."])
    n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
end)

------------------------------------------------------------------------
-- The page of the look: the style of the book, the size of the writing, the companion
------------------------------------------------------------------------
local THEME_NAMES = { codex = "Leather and gold", parchment = "Parchment", modern = "Modern", contrast = "Strong contrast" }
local SIZES = { 1, 1.1, 1.2 }
local function setAndReload(key, value)
    WFD.S[key] = value
    ReloadUI()
end
UI.SetAndReload = setAndReload

UI:RegisterRenderer("appearance", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local y = UI.PageTitle(pool, canvas, side, L["Appearance"], nil, -56, UI.SettingsTabs(4))
    local S = WFD.S
    local function caption(text)
        local t = pool:Text(10, c.redInk, UI.FONT)
        t:SetText(text:upper())
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - 18
    end
    local function links(items)
        local x = tx
        for _, it in ipairs(items) do
            local fs = pool:Link(it.text, it.fn, 13, it.active and c.redInk or c.inkSoft)
            local w = fs:GetStringWidth()
            if x > tx and x + w > tx + tw then x = tx; y = y - 20 end
            fs:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
            if it.active then
                local u = pool:Rect(c.redInk, 1)
                u:SetSize(w, 1)
                u:SetPoint("TOPLEFT", fs, "BOTTOMLEFT", 0, -2)
            end
            x = x + w + 16
        end
        y = y - 24
    end
    local function small(text)
        local t = pool:Text(12, c.inkSoft, UI.FONT)
        t:SetWidth(tw)
        t:SetText(text)
        t:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - t:GetStringHeight() - 10
    end

    caption(L["Style of the book"])
    local items = {}
    for _, key in ipairs(UI.THEMES) do
        local cur = UI.THEME or "codex"
        items[#items + 1] = { text = L[THEME_NAMES[key]], active = cur == key,
            fn = function() if cur ~= key then setAndReload("theme", key ~= "codex" and key or nil) end end }
    end
    links(items)
    small(L["Leather and gold is the old book. Modern is flat and calm, strong contrast makes all writing brighter."])
    small(L["Parchment is bright, like old quest paper."])

    caption(L["Size of the writing"])
    items = {}
    for _, k in ipairs(SIZES) do
        local cur = S.fontScale or 1
        items[#items + 1] = { text = floor(k * 100 + 0.5) .. "%", active = math.abs(cur - k) < 0.01,
            fn = function() if math.abs(cur - k) >= 0.01 then setAndReload("fontScale", k ~= 1 and k or nil) end end }
    end
    links(items)
    small(L["Both reload the interface. With bigger writing a few long lines may run close together."])

    caption(L["Size of the book"])
    items = {}
    -- a size set with Ctrl + mouse wheel joins the row, so the current one is always marked
    local cur, steps = S.scale or 0.9, { 0.75, 0.8, 0.9, 1, 1.1 }
    local known = false
    for _, st in ipairs(steps) do if math.abs(cur - st) < 0.001 then known = true end end
    if not known then
        steps[#steps + 1] = cur
        table.sort(steps)
    end
    for _, st in ipairs(steps) do
        items[#items + 1] = { text = floor(st * 100 + 0.5) .. "%", active = math.abs(cur - st) < 0.001,
            fn = function()
                UI:SetScale(st)
                UI:ShowSpread(UI.spread)
            end }
    end
    links(items)

    caption(L["Turning the pages"])
    local cb = pool:Check(L["Turn the leaves visibly"], function() return S.turnAnim ~= false end, function(v) if v then S.turnAnim = nil else S.turnAnim = false end end)
    cb:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
end)

------------------------------------------------------------------------
-- An entry in the game's options (Interface -> AddOns)
------------------------------------------------------------------------
local function buildOptions()
    local p = CreateFrame("Frame")
    p.name = "WoW Forever Diary"
    local title = p:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("WoW Forever Diary")
    local sub = p:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    sub:SetWidth(560)
    sub:SetJustifyH("LEFT")
    sub:SetText(L["Just play, I'll write along. Every day you play becomes a page in this book."])

    local function closeOptions()
        for _, f in ipairs({ _G.SettingsPanel, _G.InterfaceOptionsFrame }) do
            if f and f:IsShown() then pcall(HideUIPanel, f) end
        end
    end
    local function button(text, x, y, fn)
        local b = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
        b:SetSize(200, 24)
        b:SetPoint("TOPLEFT", x, y)
        b:SetText(text)
        b:SetScript("OnClick", fn)
        return b
    end
    button(L["Open the diary"], 16, -70, function() closeOptions(); UI:Show() end)
    button(L["Open the scribe's notes"], 226, -70, function() closeOptions(); UI:OpenSettings() end)

    local checks = {
        { L["Take a screenshot at milestones"], "screenshots" },
        { L["Announce milestones in chat"], "chat" },
        { L["Show minimap button"], "minimap", function() UI:UpdateMinimapButton() end },
        { L["Show a note for new discoveries"], "toasts" },
        { L["Weekly look back at login"], "recap" },
        { L["Show the cover when the book is first opened"], "cover" },
    }
    local boxes = {}
    for i, ch in ipairs(checks) do
        local cb = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 16, -110 - (i - 1) * 28)
        local tl = rawget(cb, "Text") or rawget(cb, "text")
        if type(tl) ~= "table" or not tl.SetText then tl = nil end
        local label = tl or cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        if not tl then label:SetPoint("LEFT", cb, "RIGHT", 4, 0) end
        label:SetText(ch[1])
        cb:SetScript("OnClick", function(s)
            WFD.S[ch[2]] = s:GetChecked() and true or false
            if ch[3] then ch[3]() end
        end)
        boxes[#boxes + 1] = { cb, ch[2] }
    end

    local y = -110 - #checks * 28 - 14
    local nl = p:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    nl:SetPoint("TOPLEFT", 16, y)
    nl:SetText(L["Notifications"])
    local levels = { { "all", L["All"] }, { "important", L["Important only"] }, { "quiet", L["Quiet"] } }
    local radios = {}
    for i, lv in ipairs(levels) do
        local cb = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 16 + (i - 1) * 170, y - 18)
        local tl = rawget(cb, "Text") or rawget(cb, "text")
        if type(tl) ~= "table" or not tl.SetText then tl = nil end
        local label = tl or cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        if not tl then label:SetPoint("LEFT", cb, "RIGHT", 4, 0) end
        label:SetText(lv[2])
        cb:SetScript("OnClick", function()
            WFD.S.notify = lv[1]
            for _, r in ipairs(radios) do r[1]:SetChecked(r[2] == lv[1]) end
        end)
        radios[#radios + 1] = { cb, lv[1] }
    end

    y = y - 62
    local sl = p:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sl:SetPoint("TOPLEFT", 16, y)
    local function showSize() sl:SetText(format(L["Size: %d%%"], floor((WFD.S.scale or 0.9) * 100 + 0.5))) end
    local minus = button("-", 16, y - 20, function()
        if UI.holder then UI:StepScale(-1) else WFD.S.scale = max(0.6, (WFD.S.scale or 0.9) - 0.05) end
        showSize()
    end)
    minus:SetWidth(40)
    local plus = button("+", 62, y - 20, function()
        if UI.holder then UI:StepScale(1) else WFD.S.scale = min(1.4, (WFD.S.scale or 0.9) + 0.05) end
        showSize()
    end)
    plus:SetWidth(40)
    button(L["Reset the position"], 116, y - 20, function() UI:ResetPosition() end)

    y = y - 62
    local tl = p:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    tl:SetPoint("TOPLEFT", 16, y)
    tl:SetText(L["Style of the book"] .. "  (" .. L["reloads the interface"] .. ")")
    local tx = 16
    for _, key in ipairs(UI.THEMES) do
        local b = button(L[THEME_NAMES[key]], tx, y - 20, function()
            if (UI.THEME or "codex") ~= key then UI.SetAndReload("theme", key ~= "codex" and key or nil) end
        end)
        b:SetWidth(150)
        tx = tx + 156
    end
    y = y - 52
    local fl = p:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fl:SetPoint("TOPLEFT", 16, y)
    fl:SetText(L["Size of the writing"] .. "  (" .. L["reloads the interface"] .. ")")
    tx = 16
    for _, k in ipairs(SIZES) do
        local b = button(floor(k * 100 + 0.5) .. "%", tx, y - 20, function()
            if math.abs((WFD.S.fontScale or 1) - k) >= 0.01 then UI.SetAndReload("fontScale", k ~= 1 and k or nil) end
        end)
        b:SetWidth(70)
        tx = tx + 76
    end
    y = y - 56
    local comp = CreateFrame("CheckButton", nil, p, "UICheckButtonTemplate")
    comp:SetPoint("TOPLEFT", 16, y)
    local ctl = rawget(comp, "Text") or rawget(comp, "text")
    if type(ctl) ~= "table" or not ctl.SetText then
        ctl = comp:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        ctl:SetPoint("LEFT", comp, "RIGHT", 4, 0)
    end
    ctl:SetText(L["Show the companion beside the game"])
    comp:SetScript("OnClick", function(s) UI:ShowCompanion(s:GetChecked() and true or false) end)
    boxes[#boxes + 1] = { comp, "companion" }

    p:SetScript("OnShow", function()
        for _, b in ipairs(boxes) do b[1]:SetChecked(WFD.S[b[2]] and true or false) end
        for _, r in ipairs(radios) do r[1]:SetChecked(r[2] == (WFD.S.notify or "all")) end
        showSize()
    end)

    if type(Settings) == "table" and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
        local cat = Settings.RegisterCanvasLayoutCategory(p, p.name)
        Settings.RegisterAddOnCategory(cat)
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(p)
    end
end

WFD:OnInit(function()
    local ok, err = pcall(buildOptions)
    if not ok then WFD:Error("options", err) end
end)
