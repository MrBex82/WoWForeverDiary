-- A report: a scrolling column written from the top down - a title, figures in tiles, headings, lines with a
-- badge, places with a diamond, item icons, a painting. The chronicle of a region beside the world map and the
-- report of a dungeon run are written with it. Every piece is taken from a stock and handed back on the next
-- Begin(), so a report can be written again as often as needed (a new size, a new choice).
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local floor, max, min = math.floor, math.max, math.min

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

    function rp:Begin()
        for _, s in pairs(st) do s.n = 0 end
        for _, p in pairs(pictures) do p:Hide() end
        self.y = PAD
        self.w = self:Width()
        return self.w
    end

    function rp:Title(text)
        local t = st.title:Take(area)
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

    function rp:End()
        for _, s in pairs(st) do s:Done() end
        self.scroll:SetContentHeight(self.y + PAD)
    end

    -- the report is written again when its width changes (fill: the function that writes it)
    rp.scroll.onResize = function()
        if rp.fill and rp:IsShown() then
            local w = rp:Width()
            if not rp.w or math.abs(w - rp.w) > 1 then rp.fill() end
        end
    end
    return rp
end
