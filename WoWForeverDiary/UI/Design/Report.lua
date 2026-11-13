-- A report: a scrolling column written from the top down - a title, figures in tiles, headings, lines with a
-- badge, places with a diamond, item icons, a painting. The chronicle of a region beside the world map and the
-- report of a dungeon run are written with it. Every piece is taken from a stock and handed back on the next
-- Begin(), so a report can be written again as often as needed (a new size, a new choice).
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local floor, max, min, format = math.floor, math.max, math.min, string.format

local PAD = 16

-- a reusable set of frames: Take() hands out the next one, Done() hides the rest
local function stock(make)
    local s = { list = {}, n = 0 }
    function s:Take(parent)
        self.n = self.n + 1
        local f = self.list[self.n]
        if not f then
            f = make(parent)
            self.list[self.n] = f
        end
        f:Show()
        return f
    end
    function s:Done()
        for i = self.n + 1, #self.list do self.list[i]:Hide() end
    end
    return s
end

-- one line: a badge (a coloured disc with a number or a mark, or an icon), a name, a line below, a figure right
local function makeLine(parent)
    local r = CreateFrame("Button", nil, parent)
    r.hl = K.Fill(r, "hover", "BACKGROUND", 1)
    r.hl:SetAllPoints()
    r.hl:Hide()
    r.disc = UI.Circle(r, 20, { 1, 1, 1, 1 }, "ARTWORK", 1)
    r.disc:SetPoint("TOPLEFT", 4, -6)
    r.icon = r:CreateTexture(nil, "ARTWORK", nil, 2)
    r.icon:SetSize(18, 18)
    r.icon:SetPoint("CENTER", r.disc, "CENTER")
    r.num = K.Text(r, "small", "white", "CENTER")
    r.num:SetPoint("CENTER", r.disc, "CENTER", 0, 0)
    r.mark = K.Glyph(r, "check", 12, "pos")
    r.mark:SetPoint("CENTER", r.disc, "CENTER")
    r.right = K.Text(r, "small", "soft", "RIGHT")
    r.right:SetPoint("TOPRIGHT", -6, -7)
    r.name = K.Text(r, "body", "ink")
    r.name:SetPoint("TOPLEFT", 32, -6)
    r.name:SetWordWrap(false)
    r.sub = K.Text(r, "small", "muted")
    r.sub:SetPoint("TOPLEFT", r.name, "BOTTOMLEFT", 0, -2)
    r.bar = K.Bar(r, 4)
    r:SetScript("OnEnter", function(self)
        if self.go then self.hl:Show() end
        if self.link then
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            pcall(GameTooltip.SetHyperlink, GameTooltip, self.link)
            GameTooltip:Show()
        elseif self.tip then
            local lines = {}
            for i = 2, #self.tip do lines[#lines + 1] = self.tip[i] end
            K.ShowTip(self, self.tip[1], lines, "ANCHOR_LEFT")
        else
            K.ShowFull(self, "ANCHOR_LEFT", self.name, self.sub, self.right)
        end
    end)
    r:SetScript("OnLeave", function(self) self.hl:Hide() GameTooltip:Hide() end)
    r:SetScript("OnClick", function(self) if self.go then self.go() end end)
    -- o = { name, sub, right, col, num, mark, markKey, icon, coords, frac, barCol, nameKey, subKey, wrap, go, tip, link }
    function r:Set(o, w)
        self:SetWidth(w)
        local col = o.col or { 0.5, 0.4, 0.3 }
        self.disc:SetVertexColor(col[1], col[2], col[3], (o.col or o.icon) and 1 or 0.35)
        self.icon:SetShown(o.icon ~= nil)
        if o.icon then
            self.icon:SetTexture(o.icon)
            if o.coords then self.icon:SetTexCoord(o.coords[1], o.coords[2], o.coords[3], o.coords[4])
            else self.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) end
        end
        self.num:SetText(o.num and tostring(o.num) or "")
        self.mark:SetShown(o.mark ~= nil)
        if o.mark then self.mark:SetShape(o.mark) self.mark:SetColorKey(o.markKey or "pos") end
        self.right:SetText(o.right or "")
        local room = max(40, w - 32 - (o.right and (self.right:GetStringWidth() + 12) or 6))
        self.name:SetWordWrap(o.wrap and true or false)
        self.name:SetWidth(room)
        self.sub:SetWidth(max(40, w - 38))
        self.sub:SetWordWrap(o.wrap and true or false)
        self.name:SetText(o.name or "?")
        K.Recolor(self.name, o.nameKey or "ink")
        self.sub:SetText(o.sub or "")
        K.Recolor(self.sub, o.subKey or "muted")
        self.sub:SetShown(o.sub ~= nil)
        self.go, self.tip, self.link = o.go, o.tip, o.link
        local h = 6 + self.name:GetStringHeight() + (o.sub and (2 + self.sub:GetStringHeight()) or 0)
        self.bar:SetShown(o.frac ~= nil)
        if o.frac then
            self.bar:ClearAllPoints()
            self.bar:SetPoint("TOPLEFT", self, "TOPLEFT", 32, -(h + 4))
            self.bar:SetWidth(max(20, w - 38))
            self.bar:SetValue(o.frac)
            self.bar:SetFill(nil, o.barCol or col)
            h = h + 8
        end
        h = max(32, h + 7)
        self:SetHeight(h)
        return h
    end
    return r
end

-- a figure with its caption (a click leads on, when it can)
local function makeTile(parent)
    local t = K.Box(parent, "inset", nil, "Button")
    t.value = K.Text(t, "strong", "ink")
    t.value:SetPoint("TOPLEFT", 9, -7)
    t.label = K.Text(t, "small", "muted")
    t.label:SetPoint("TOPLEFT", t.value, "BOTTOMLEFT", 0, -2)
    t:SetScript("OnEnter", function(self) if self.go then self:SetSurface("hover", "gold") end end)
    t:SetScript("OnLeave", function(self) self:SetSurface("inset", nil) end)
    t:SetScript("OnClick", function(self) if self.go then self.go() end end)
    return t
end

-- an item, a crest or a portrait as a small framed icon
local function makeIcon(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(32, 32)
    b.rim = b:CreateTexture(nil, "ARTWORK", nil, 0)
    b.rim:SetTexture(UI.WHITE)
    b.rim:SetAllPoints()
    b.tex = b:CreateTexture(nil, "ARTWORK", nil, 1)
    b.tex:SetPoint("TOPLEFT", 2, -2)
    b.tex:SetPoint("BOTTOMRIGHT", -2, 2)
    b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    b:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        if self.link then pcall(GameTooltip.SetHyperlink, GameTooltip, self.link)
        elseif self.tip then GameTooltip:SetText(self.tip, 1, 0.86, 0.5) end
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:SetScript("OnClick", function(self)
        if self.link and IsModifiedClick and IsModifiedClick("CHATLINK") and ChatEdit_InsertLink then ChatEdit_InsertLink(self.link) end
    end)
    return b
end

function K.Report(parent)
    local rp = CreateFrame("Frame", nil, parent)
    rp.scroll = K.Scroll(rp)
    rp.scroll:SetPoint("TOPLEFT", 4, -4)
    rp.scroll:SetPoint("BOTTOMRIGHT", -4, 4)
    local area = rp.scroll.content
    rp.area = area
    local st = {
        title = stock(function(p) return K.Text(p, "title", "title") end),
        text = stock(function(p) return K.Text(p, "small", "soft") end),
        head = stock(function(p) return K.SectionHead(p, "") end),
        line = stock(makeLine),
        tile = stock(makeTile),
        icon = stock(makeIcon),
        bar = stock(function(p) return K.Bar(p, 6) end),
        bullet = stock(function(p)
            local f = CreateFrame("Frame", nil, p)
            f.dia = UI.Diamond(f, 5, { 1, 1, 1, 1 }, "ARTWORK", 1)
            f.dia:SetPoint("TOPLEFT", 2, -6)
            f.text = K.Text(f, "body", "ink")
            f.text:SetPoint("TOPLEFT", 14, 0)
            UI.Skin.Add(f, function(s) s.dia:SetVertexColor(UI.Tok("gold")) end)
            return f
        end),
        chip = stock(function(p)
            local b = K.Box(p, "inset", "line", "Button")
            b.text = K.Text(b, "small", "ink")
            b.text:SetPoint("CENTER", 0, 0)
            b:SetScript("OnEnter", function(s)
                if s.tip then K.ShowTip(s, s.tip[1], { select(2, unpack(s.tip)) }) end
            end)
            b:SetScript("OnLeave", function() GameTooltip:Hide() end)
            return b
        end),
        cap = stock(function(p)
            local t = K.Text(p, "display", "gold")
            t:SetShadowColor(0, 0, 0, 0.6)
            t:SetShadowOffset(1, -1)
            return t
        end),
        para = stock(function(p) return K.Text(p, "body", "ink") end),
        bar2 = stock(function(p) return K.Fill(p, "gold", "ARTWORK", 1, 0.5) end),
        bprimary = stock(function(p) return K.Button(p, "", "primary") end),
        bghost = stock(function(p) return K.Button(p, "", "ghost") end),
        flourish = stock(function(p)
            local f = CreateFrame("Frame", nil, p)
            f:SetSize(40, 12)
            f.d = {}
            for i = -1, 1 do
                local d = UI.Diamond(f, i == 0 and 7 or 4, { 1, 1, 1, 1 }, "ARTWORK", 1)
                d:SetPoint("CENTER", f, "CENTER", i * 14, 0)
                f.d[#f.d + 1] = d
            end
            UI.Skin.Add(f, function(s)
                for i, d in ipairs(s.d) do d:SetVertexColor(UI.Tok(i == 2 and "gold" or "muted")) end
            end)
            return f
        end),
    }
    local pictures = {}

    local function place(f, h)
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", area, "TOPLEFT", PAD, -rp.y)
        rp.y = rp.y + h
    end

    function rp:Width()
        local w = self.scroll:GetWidth()
        if not w or w < 60 then w = (self:GetWidth() or 0) - 8 end
        if not w or w < 60 then w = 300 end
        return w - 2 * PAD - 4          -- room for the scroll bar
    end

    -- (the width first: asking for it can make the game lay the window out at once, and a report that is
    -- written while it lays out would be written twice)
    function rp:Begin()
        self.busy = true
        local w = self:Width()
        for _, s in pairs(st) do s.n = 0 end
        for _, p in pairs(pictures) do p:Hide() end
        self.y = PAD
        self.w = w
        return self.w
    end

    -- role: "title" (the default) or "display" (the big letters of a day or a chapter)
    function rp:Title(text, role, key)
        local t = st.title:Take(area)
        K.Recolor(t, key or "title", role or "title")
        t:SetWidth(self.w)
        t:SetText(text or "")
        place(t, t:GetStringHeight() + 4)
        return t
    end

    -- a line of writing; role and key as for K.Text
    function rp:Text(text, key, role, gap)
        local t = st.text:Take(area)
        t.role = role or "small"
        K.Recolor(t, key or "soft", role or "small")
        t:SetWidth(self.w)
        t:SetText(text or "")
        place(t, t:GetStringHeight() + (gap or 8))
        return t
    end

    -- a bar with the figure beside it
    function rp:Progress(frac, text)
        local b = st.bar:Take(area)
        local t = st.text:Take(area)
        K.Recolor(t, "ink", "strong")
        t:SetWidth(0)
        t:SetText(text or "")
        local tw = t:GetStringWidth()
        b:SetWidth(max(20, self.w - tw - 10))
        b:SetValue(frac or 0)
        t:ClearAllPoints()
        t:SetPoint("TOPRIGHT", area, "TOPLEFT", PAD + self.w, -self.y + 4)
        place(b, 20)
    end

    function rp:Head(text, right)
        self.y = self.y + 4
        local hd = st.head:Take(area)
        hd:Set(text, right)
        hd:SetWidth(self.w)
        place(hd, 28)
    end

    function rp:Line(o)
        local r = st.line:Take(area)
        local h = r:Set(o, self.w + 8)
        r:ClearAllPoints()
        r:SetPoint("TOPLEFT", area, "TOPLEFT", PAD - 4, -self.y)
        self.y = self.y + h
        return r
    end

    -- figures: { { value, caption, go, key } }, per = tiles in a row (by default as many as fit)
    function rp:Tiles(list, per)
        per = per or ((self.w >= 420) and 4 or 2)
        per = min(per, #list)
        if per < 1 then return end
        local tw = (self.w - (per - 1) * 8) / per
        local rowH, first = 0, st.tile.n + 1
        for i, it in ipairs(list) do
            local t = st.tile:Take(area)
            t.value:SetText(tostring(it[1]))
            K.Recolor(t.value, it[4] or (it[3] and "gold") or "ink")
            t.label:SetText(it[2] or "")
            t.value:SetWidth(tw - 16)
            t.label:SetWidth(tw - 16)
            t.go = it[3]
            t:SetSurface("inset", nil)
            rowH = max(rowH, 7 + t.value:GetStringHeight() + 2 + t.label:GetStringHeight() + 8)
            if i % per == 0 or i == #list then
                -- a row of tiles is as tall as its tallest
                local from = first + (floor((i - 1) / per) * per)
                for j = from, first + i - 1 do
                    local tj = st.tile.list[j]
                    tj:SetSize(tw, rowH)
                    tj:ClearAllPoints()
                    tj:SetPoint("TOPLEFT", area, "TOPLEFT", PAD + (j - from) * (tw + 8), -self.y)
                end
                self.y = self.y + rowH + 8
                rowH = 0
            end
        end
        self.y = self.y + 4
    end

    -- places and names, one per line with a small diamond
    function rp:Bullets(list)
        for _, text in ipairs(list) do
            local f = st.bullet:Take(area)
            f.text:SetWidth(self.w - 14)
            f.text:SetText(text)
            local h = max(18, f.text:GetStringHeight() + 4)
            f:SetSize(self.w, h)
            place(f, h)
        end
    end

    -- small framed icons in rows: { { icon, col, link, tip } }
    function rp:Icons(list)
        local size, gap = 32, 6
        local per = max(1, floor((self.w + gap) / (size + gap)))
        for i, it in ipairs(list) do
            local b = st.icon:Take(area)
            local col = it[2] or { 0.5, 0.4, 0.3 }
            b.rim:SetVertexColor(col[1], col[2], col[3], 1)
            b.tex:SetTexture(it[1])
            b.link, b.tip = it[3], it[4]
            local c, r = (i - 1) % per, floor((i - 1) / per)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", area, "TOPLEFT", PAD + c * (size + gap), -(self.y + r * (size + gap)))
        end
        if #list > 0 then self.y = self.y + (floor((#list - 1) / per) + 1) * (size + gap) + 4 end
    end

    -- a painting of a moment (UI.Painting is built for one size: one per size)
    function rp:Picture(ev, h)
        local w = floor(self.w)
        h = h or 120
        local key = w .. "x" .. h
        local p = pictures[key]
        if not p then
            p = UI.Painting(area, w, h)
            pictures[key] = p
        end
        p:SetFrameLevel(area:GetFrameLevel() + 2)
        p:Show()
        p:Paint(ev)
        place(p, h + 10)
    end

    function rp:Gap(n) self.y = self.y + (n or 12) end

    ------------------------------------------------------------------------
    -- Pieces for reading (the diary and the chronicle)
    ------------------------------------------------------------------------
    -- a small line in capitals above a title ("CHAPTER III")
    function rp:Kicker(text, key)
        local t = st.text:Take(area)
        K.Recolor(t, key or "gold", "section")
        t:SetWidth(self.w)
        t:SetText(UI.Upper(text or ""))
        place(t, t:GetStringHeight() + 6)
        return t
    end

    -- small boxes in a row that breaks where the room ends: { { text, key } }
    function rp:Chips(list)
        local x, rowH = 0, 0
        for _, it in ipairs(list) do
            local b = st.chip:Take(area)
            b.text:SetText(it[1])
            K.Recolor(b.text, it[2] or "ink", "small")
            local bw, bh = b.text:GetStringWidth() + 18, b.text:GetStringHeight() + 10
            b:SetSize(bw, bh)
            if x > 0 and x + bw > self.w then x, self.y, rowH = 0, self.y + rowH + 6, 0 end
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", area, "TOPLEFT", PAD + x, -self.y)
            b.tip = it[3]
            x = x + bw + 6
            rowH = max(rowH, bh)
        end
        if #list > 0 then self.y = self.y + rowH + 12 end
    end

    -- the words of a text: by spaces, or by characters for languages written without them
    local function words(text)
        local list = {}
        local sep = (WFD.loc and WFD.loc.sentenceSep == "") and "" or " "
        local pat = sep == "" and "[%z\1-\127\194-\244][\128-\191]*" or "%S+"
        for w in text:gmatch(pat) do list[#list + 1] = w end
        return list, sep
    end
    local measure = K.Text(rp, "body", "ink")
    measure:Hide()

    -- a paragraph of reading text; cap = true: an illuminated initial, the first two lines beside it
    function rp:Paragraph(text, key, cap, bar)
        local spacing = 3
        if cap then
            local list, sep = words(text)
            local letter = list[1] and list[1]:match("^[%z\1-\127\194-\244][\128-\191]*")
            if letter and (#letter > 1 or letter:find("%w")) then
                local c = st.cap:Take(area)
                c:SetText(letter)
                local capW = c:GetStringWidth() + 4
                local inner = self.w - capW
                measure:SetSpacing(spacing)
                measure:SetWidth(inner)
                measure:SetText("Ag")
                local lineH = measure:GetStringHeight()
                local limit = lineH * 2 + spacing + 2
                local first = { list[1]:sub(#letter + 1) }
                local n = 1
                for k = 2, #list do
                    first[#first + 1] = list[k]
                    measure:SetText(table.concat(first, sep))
                    if measure:GetStringHeight() > limit then first[#first] = nil break end
                    n = k
                end
                c:ClearAllPoints()
                c:SetPoint("TOPLEFT", area, "TOPLEFT", PAD - 1, -self.y + 4)
                local t = st.para:Take(area)
                K.Recolor(t, key or "ink", "body")
                t:SetSpacing(spacing)
                t:SetWidth(inner)
                t:SetText((table.concat(first, sep):gsub("^ ", "")))
                t:ClearAllPoints()
                t:SetPoint("TOPLEFT", area, "TOPLEFT", PAD + capW, -self.y)
                local capH = max(c:GetStringHeight() - 6, t:GetStringHeight())
                if n >= #list then
                    self.y = self.y + capH + 10
                    return
                end
                self.y = self.y + max(t:GetStringHeight(), lineH * 2 + spacing) + spacing
                text = table.concat(list, sep, n + 1)
            end
        end
        local t = st.para:Take(area)
        K.Recolor(t, key or "ink", "body")
        t:SetSpacing(spacing)
        t:SetWidth(bar and (self.w - 12) or self.w)
        t:SetText(text or "")
        t:ClearAllPoints()
        t:SetPoint("TOPLEFT", area, "TOPLEFT", PAD + (bar and 12 or 0), -self.y)
        local h = t:GetStringHeight()
        if bar then
            local b = st.bar2:Take(area)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", area, "TOPLEFT", PAD, -self.y)
            b:SetSize(2, h)
        end
        self.y = self.y + h + 10
        return t
    end

    -- a button in the flow of the report
    function rp:Button(label, onClick, style)
        local b = st[style == "primary" and "bprimary" or "bghost"]:Take(area)
        b:SetLabel(label)
        b.onClick = function() onClick() end
        b:ClearAllPoints()
        b:SetPoint("TOPLEFT", area, "TOPLEFT", PAD - (style == "primary" and 0 or 8), -self.y)
        self.y = self.y + b:GetHeight() + 8
        return b
    end

    -- a line that leads somewhere: name, a line below, where to go (go), what the click does (hint, a whole
    -- sentence). The same look in every report, so a link is always recognised.
    function rp:Link(name, sub, go, hint, icon)
        return self:Line({ name = name, sub = sub, icon = icon, mark = (not icon) and "right" or nil, markKey = "white",
            col = { 0.55, 0.40, 0.16 }, go = go, tip = go and hint and { name, { hint, 0.5, 0.8, 1 } } or nil })
    end

    -- the day a thing happened, as a link to that page of the diary
    function rp:DayLink(day, t, label)
        if not day then return end
        local go = UI.DayGo(day)
        local when = format(L["Day %d"], day) .. (t and ("  -  " .. date(WFD.loc.date, t)) or "")
        if label then return self:Link(label, when, go, go and L["Click to read this day."]) end
        return self:Link(when, nil, go, go and L["Click to read this day."])
    end

    -- a few small diamonds in the middle: the end of an entry
    function rp:Flourish()
        local f = st.flourish:Take(area)
        f:ClearAllPoints()
        f:SetPoint("TOP", area, "TOPLEFT", PAD + self.w / 2, -self.y)
        self.y = self.y + 28
    end

    function rp:End()
        for _, s in pairs(st) do s:Done() end
        self.scroll:SetContentHeight(self.y + PAD)
        self.busy = false
    end

    -- the report is written again when its width changes (fill: the function that writes it)
    rp.scroll.onResize = function()
        if rp.fill and rp:IsShown() and not rp.busy then
            local w = rp:Width()
            if not rp.w or math.abs(w - rp.w) > 1 then rp.fill() end
        end
    end
    return rp
end

------------------------------------------------------------------------
-- A view that is one report on a sheet in the middle of the desk (records, the level timeline, the year book)
-- def = { key, label (English key), group, part, width, fill = function(report, view) }
------------------------------------------------------------------------
function UI.ReportView(def)
    UI.PART_VIEW[def.part or def.key] = def.key
    UI.VIEW_PLACE[def.key] = { def.group, def.part or def.key }
    UI.PART_LABEL[def.part or def.key] = def.label
    UI:RegisterView({
        key = def.key,
        build = function(host)
            local v = {}
            v.sheet = K.Card(host)
            v.report = K.Report(v.sheet)
            v.report:SetPoint("TOPLEFT", v.sheet, "TOPLEFT", 12, -6)
            v.report:SetPoint("BOTTOMRIGHT", v.sheet, "BOTTOMRIGHT", -12, 6)
            function v:Fill()
                local rp = self.report
                rp:Begin()
                local ok, err = pcall(def.fill, rp, self)
                if not ok then WFD:Error("view " .. def.key, err) end
                rp:End()
            end
            v.report.fill = function() v:Fill() end
            function v:Arrange()
                local W, H = self.w or host:GetWidth() or 0, self.h or host:GetHeight() or 0
                if W <= 0 or H <= 0 then return end
                local sw = min(W - 24, floor((def.width or 760) * max(1, UI.FONT_SCALE or 1)))
                self.sheet:ClearAllPoints()
                self.sheet:SetPoint("TOP", host, "TOP", 0, -12)
                self.sheet:SetSize(sw, H - 24)
            end
            function v:Refresh() self:Arrange() self:Fill() end
            function v:Show(route)
                self.route = route
                self:Refresh()
                self.report.scroll:ScrollTo(0)
            end
            function v:Layout(w, h) self.w, self.h = w, h self:Arrange() end
            UI.OnRestyle(function() if host:IsShown() then v:Refresh() end end)
            function v:Head()
                local g = UI.NAV_GROUP[def.group]
                return L[def.label], g and L[g.label], g and UI.GroupRoute(g)
            end
            return v
        end,
    })
end
