-- Little parchment notes that slide in when something new happens, and the weekly look back.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local floor, max, min, format = math.floor, math.max, math.min, string.format

------------------------------------------------------------------------
-- Opening the book at the right place
------------------------------------------------------------------------
function UI:OpenAt(target)
    self:OpenBook(function(b)
        local page
        if type(target) == "number" then
            page = b.dayPage[target]
        elseif target then
            page = b.sectionStart[target]
        end
        return page or self:TodayPage()
    end)
end

-- where a milestone is best read
local TARGET = { honour = "honour", landmark = "landmarks", dungeon = "runs", challenge = "collection", weekly = "collection",
    first = "firsts", capsule = "capsule" }

------------------------------------------------------------------------
-- Toasts
------------------------------------------------------------------------
local TW, TH = 430, 112
local TX = 92                -- where the words start
local NAME_W = TW - TX - 80  -- room left of the points
local IN, HOLD, OUT = 0.35, 6, 0.6
local SCALE = 0.8            -- the note is drawn a little smaller than laid out
local TOP_Y = -140 / SCALE   -- so it keeps its place below the top of the screen
local queue = {}
local toast

-- a trophy plaque built from plain textures: shadow, metal frame with bevel, dark inset, icon
local function makePlaque(parent, size)
    local p = CreateFrame("Frame", nil, parent)
    local f = size + 8
    p:SetSize(f, f)
    p.shadow = UI.Fill(p, { 0, 0, 0 }, "BACKGROUND", 0, 0.5)
    p.shadow:SetSize(f, f)
    p.shadow:SetPoint("CENTER", 2, -3)
    p.frame = UI.Fill(p, c.gold, "ARTWORK", 0)
    p.frame:SetAllPoints()
    p.hi = UI.Fill(p, { 1, 1, 1 }, "ARTWORK", 1, 0.45)
    p.hi:SetPoint("TOPLEFT")
    p.hi:SetPoint("TOPRIGHT")
    p.hi:SetHeight(1)
    p.hi2 = UI.Fill(p, { 1, 1, 1 }, "ARTWORK", 1, 0.45)
    p.hi2:SetPoint("TOPLEFT")
    p.hi2:SetPoint("BOTTOMLEFT")
    p.hi2:SetWidth(1)
    p.lo = UI.Fill(p, { 0, 0, 0 }, "ARTWORK", 1, 0.5)
    p.lo:SetPoint("BOTTOMLEFT")
    p.lo:SetPoint("BOTTOMRIGHT")
    p.lo:SetHeight(1)
    p.lo2 = UI.Fill(p, { 0, 0, 0 }, "ARTWORK", 1, 0.5)
    p.lo2:SetPoint("TOPRIGHT")
    p.lo2:SetPoint("BOTTOMRIGHT")
    p.lo2:SetWidth(1)
    p.inset = UI.Fill(p, { 0.06, 0.04, 0.02 }, "ARTWORK", 2)
    p.inset:SetSize(size + 2, size + 2)
    p.inset:SetPoint("CENTER")
    p.icon = p:CreateTexture(nil, "ARTWORK", nil, 3)
    p.icon:SetSize(size, size)
    p.icon:SetPoint("CENTER")
    p.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    function p:Set(path, col)
        self.icon:SetTexture(path)
        self.frame:SetVertexColor(col[1], col[2], col[3], 1)
    end
    return p
end

local function build()
    local f = CreateFrame("Button", "WoWForeverDiaryToast", UIParent)
    f:SetSize(TW, TH)
    f:SetPoint("TOP", UIParent, "TOP", 0, TOP_Y)
    f:SetScale(SCALE)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    local base = f:GetFrameLevel()

    -- dark leather with a gold edge, like the cover of the book
    local shadow = UI.Fill(f, { 0, 0, 0 }, "BACKGROUND", -8, 0.5)
    shadow:SetPoint("TOPLEFT", 5, -6)
    shadow:SetPoint("BOTTOMRIGHT", 5, -6)
    local body = CreateFrame("Frame", nil, f)
    body:SetAllPoints()
    body:SetFrameLevel(base + 1)
    UI.Leather(body, 3, 1, 0.15)
    UI.EdgeFade(body, "TOP", 30, { 1, 0.80, 0.55 }, 0.10, "BACKGROUND", 3, 3)
    local edge = UI.Frame(f)
    edge:SetAllPoints()
    edge:SetFrameLevel(base + 2)
    UI.Backdrop(edge, "tooltip", 14, 3, { 0, 0, 0, 0 }, { 0.90, 0.70, 0.30, 1 })
    -- inner gold rule
    local inner = UI.Frame(f)
    inner:SetPoint("TOPLEFT", 7, -7)
    inner:SetPoint("BOTTOMRIGHT", -7, 7)
    inner:SetFrameLevel(base + 2)
    UI.Backdrop(inner, nil, 1, 0, { 0, 0, 0, 0 }, { 0.85, 0.66, 0.30, 0.35 })

    local top = CreateFrame("Frame", nil, f)
    top:SetAllPoints()
    top:SetFrameLevel(base + 4)
    f.top = top

    -- glow behind the plaque, pulsing
    f.glow = UI.Circle(top, 86, c.gold, "BACKGROUND", 0)
    f.glow:SetPoint("CENTER", top, "LEFT", 48, 0)
    f.plaque = makePlaque(top, 50)
    f.plaque:SetPoint("CENTER", top, "LEFT", 48, 0)
    f.plaque:SetFrameLevel(base + 5)

    -- a calm dark panel behind the words, so they stand out from the grain
    local panel = UI.GradRect(body, "HORIZONTAL", { 0.02, 0.01, 0.005, 0.55 }, { 0.02, 0.01, 0.005, 0.30 }, "BACKGROUND", 4)
    panel:SetPoint("TOPLEFT", TX - 8, -10)
    panel:SetPoint("BOTTOMRIGHT", -10, 10)

    local function shade(fs)
        fs:SetShadowColor(0, 0, 0, 1)
        fs:SetShadowOffset(1, -1)
        return fs
    end
    f.kicker = shade(UI.Caps(top, "", 11, { 1, 0.82, 0.40, 1 }))
    f.kicker:SetPoint("TOPLEFT", TX, -15)
    f.name = UI.Text(top, 20, { 1, 0.96, 0.86, 1 }, "LEFT", UI.HEAD, true)
    f.name:SetPoint("TOPLEFT", TX, -30)
    f.name:SetWidth(NAME_W)
    f.name:SetWordWrap(false)
    f.metal = shade(UI.Caps(top, "", 11, c.gold))
    f.metal:SetPoint("TOPLEFT", TX, -56)
    f.pips = {}
    for i = 1, 5 do
        local d = UI.Diamond(top, 7, c.gold, "ARTWORK", 2)
        f.pips[i] = d
    end
    -- the hint may take two lines instead of being cut off
    f.hint = UI.Text(top, 12, { 0.95, 0.89, 0.76, 1 }, "LEFT", UI.FONT, true)
    f.hint:SetPoint("TOPLEFT", TX, -74)
    f.hint:SetWidth(TW - TX - 18)
    f.hint:SetJustifyV("TOP")
    f.hint:SetWordWrap(true)
    if f.hint.SetMaxLines then f.hint:SetMaxLines(2) end
    f.points = UI.Text(top, 24, { 1, 0.85, 0.40, 1 }, "RIGHT", UI.HEAD, true)
    f.points:SetPoint("TOPRIGHT", -18, -16)
    f.pointsLabel = shade(UI.Caps(top, "", 9, { 0.95, 0.80, 0.50, 1 }))
    f.pointsLabel:SetJustifyH("RIGHT")
    f.pointsLabel:SetPoint("TOPRIGHT", -18, -44)

    -- a sheen that sweeps across once
    local clip = CreateFrame("Frame", nil, f)
    clip:SetPoint("TOPLEFT", 4, -4)
    clip:SetPoint("BOTTOMRIGHT", -4, 4)
    clip:SetFrameLevel(base + 6)
    if clip.SetClipsChildren then clip:SetClipsChildren(true) end
    f.sheen = UI.GradRect(clip, "HORIZONTAL", { 1, 0.95, 0.80, 0 }, { 1, 0.95, 0.80, 0.22 }, "OVERLAY", 0)
    f.sheen:SetSize(60, TH - 8)
    f.sheen2 = UI.GradRect(clip, "HORIZONTAL", { 1, 0.95, 0.80, 0.22 }, { 1, 0.95, 0.80, 0 }, "OVERLAY", 0)
    f.sheen2:SetSize(60, TH - 8)
    f.sheen2:SetPoint("LEFT", f.sheen, "RIGHT")

    f:SetScript("OnClick", function(self)
        local ev = self.ev
        self.phase, self.t = "out", 0
        if ev then UI:OpenAt(TARGET[ev.k] or ev.day) end
    end)
    f:SetScript("OnUpdate", function(self, dt)
        self.t = self.t + dt
        self.life = (self.life or 0) + dt
        -- sheen runs once, the glow breathes
        local sx = 4 + (self.life - 0.3) * 360
        local inside = sx >= 4 and sx <= TW - 124
        self.sheen:SetShown(inside)
        self.sheen2:SetShown(inside)
        if inside then
            self.sheen:ClearAllPoints()
            self.sheen:SetPoint("TOPLEFT", self, "TOPLEFT", sx, -4)
        end
        self.glow:SetAlpha(0.18 + 0.12 * math.sin(self.life * 3))
        if self.phase == "in" then
            local a = min(1, self.t / IN)
            self:SetAlpha(a)
            self:SetPoint("TOP", UIParent, "TOP", 0, TOP_Y + (1 - a) * 28)
            if a >= 1 then self.phase, self.t = "hold", 0 end
        elseif self.phase == "hold" then
            if self:IsMouseOver() then self.t = 0 end
            if self.t >= HOLD then self.phase, self.t = "out", 0 end
        else
            local a = max(0, 1 - self.t / OUT)
            self:SetAlpha(a)
            if a <= 0 then
                self:Hide()
                UI:NextToast()
            end
        end
    end)
    f:Hide()
    return f
end

-- what to show for a milestone: icon, frame colour, kicker, name, metal line, pips, hint, points
local function describe(ev)
    local def = UI.SEAL[ev.k] or UI.SEAL.quest
    local subject = (ev.k ~= "level" and ev.s and ev.s:match(":%s*(.+)$")) or ev.s or ""
    local d = {
        icon = UI.Icon(def.icon), col = def.col, kicker = L[UI.SEAL_LABEL[ev.k] or "Moment"], name = subject,
    }
    if ev.k == "honour" and ev.honour and WFD.HonourDef then
        local h = WFD:HonourDef(ev.honour)
        if h then
            local n, tier = #h.tiers, ev.tier or 1
            local metal = WFD:MetalOf(tier, n)
            d.icon = UI.IconPath(h.icon, "honour")
            d.col = metal.col
            d.kicker = L["Honour earned"]
            d.name = L[h.name]
            d.metal = L[metal.name]
            d.metalCol = metal.col
            d.pips, d.pipsOf, d.n = tier, n, n
            d.points = WFD:TierPoints(tier, n)
            local nextGoal = h.tiers[tier + 1]
            d.hint = nextGoal and (L["Next tier:"] .. " " .. WFD:HonourText(h, nextGoal)) or L["Every tier earned - complete!"]
        end
    elseif ev.k == "landmark" then
        d.kicker = L["Landmark discovered"]
        for _, g in ipairs(WFD.LANDMARKS or {}) do
            for _, e in ipairs(g.list) do
                if e[1] == ev.landmark then
                    d.icon = UI.IconPath({ e[2] or g.icon }, "sight")
                    d.metal = L[g.label]
                end
            end
        end
        d.metalCol = { 0.45, 0.80, 0.75, 1 }
        d.hint = L["Click for all landmarks."]
    elseif ev.k == "level" then
        d.name = ev.s or ""
        d.hint = L["Click to read this day."]
    elseif ev.k == "challenge" then
        local ch = WFD.TodayChallenges and WFD:TodayChallenges()
        if ev.all or not ch then
            d.hint = ev.all and L["All tasks of the day done!"] or L["Click to read this day."]
        else
            local n = 0
            for _ in pairs(ch.done or {}) do n = n + 1 end
            -- progress pips: one diamond per task of the day
            d.metal = L["Tasks of the day"] .. ": " .. n .. "/" .. #ch.list
            d.metalCol, d.pipCol = c.gold, c.gold
            d.pips, d.n = n, min(#ch.list, 5)
            d.hint = L["Click to read this day."]
        end
    elseif ev.k == "first" then
        d.kicker = L["First time"]
        local def
        for _, f in ipairs(WFD.FIRSTS or {}) do if f.key == ev.first then def = f end end
        if def then
            d.icon = UI.IconPath(def.icon, "first")
            d.name = L[def.label]
            d.metal = ev.s and ev.s:match(":%s*(.+)$") or nil
            d.metalCol = c.gold
        end
        d.hint = L["Click for all first times."]
    elseif ev.k == "weekly" then
        d.kicker = L["Task of the week"]
        d.hint = L["Click for the next goals."]
    elseif ev.k == "capsule" then
        d.kicker = L["Time capsule"]
        d.name = L["A letter from the past has opened."]
        d.hint = L["Click to read the letter."]
    else
        d.hint = L["Click to read this day."]
    end
    return d
end

function UI:NextToast()
    local ev = table.remove(queue, 1)
    if not ev then return end
    toast = toast or build()
    local d = describe(ev)
    toast.plaque:Set(d.icon, d.col)
    toast.glow:SetVertexColor(d.col[1], d.col[2], d.col[3], 1)
    toast.kicker:SetText(d.kicker:upper())
    toast.name:SetText(d.name)
    UI.FitText(toast.name, NAME_W, 20, 14)
    toast.metal:SetText((d.metal or ""):upper())
    toast.metal:SetTextColor(UI.col4(d.metalCol or c.gold))
    -- tier diamonds after the metal name
    local mw = (d.metal and d.metal ~= "") and (toast.metal:GetStringWidth() + 10) or 0
    for i = 1, 5 do
        local p = toast.pips[i]
        if d.n and i <= d.n then
            p:ClearAllPoints()
            p:SetPoint("LEFT", toast.metal, "LEFT", mw + (i - 1) * 11, 0)
            local got = i <= d.pips
            local mc = got and (d.pipCol or WFD:MetalOf(i, d.n).col) or { 0.45, 0.32, 0.18, 1 }
            p:SetVertexColor(mc[1], mc[2], mc[3], 1)
            p:SetSize(got and 8 or 6, got and 8 or 6)
            p:Show()
        else
            p:Hide()
        end
    end
    toast.hint:SetText(d.hint or "")
    toast.points:SetText(d.points and ("+" .. d.points) or "")
    toast.pointsLabel:SetText(d.points and L["Honour points"]:upper() or "")
    toast.ev = ev
    toast.phase, toast.t, toast.life = "in", 0, 0
    toast:SetAlpha(0)
    toast:Show()
    UI.Sound(ev.k == "honour" and "IG_QUEST_LIST_COMPLETE" or "IG_ABILITY_PAGE_TURN", ev.k == "honour" and 878 or 836)
end

function UI:Toast(ev)
    if not ev or (WFD.S and WFD.S.toasts == false) then return end
    queue[#queue + 1] = ev
    if not (toast and toast:IsShown()) then self:NextToast() end
end

-- a death is written into the diary, but no note pops up for it
WFD:OnSignal("milestone", function(ev)
    if ev.k == "kills" or WFD:IsDeathEvent(ev) then return end
    if not WFD.ShouldNotify or WFD:ShouldNotify(ev.k) then UI:Toast(ev) end
end)

------------------------------------------------------------------------
-- The week in review
------------------------------------------------------------------------
local function weekStats(from, to)
    local C = WFD.C
    local s = { kills = 0, quests = 0, km = 0, deaths = 0, places = 0, levels = {}, days = 0, best = nil, bestK = 0 }
    for d = from, to do
        local day = C.days[d]
        if day and (day.online or 0) > 0 then
            s.days = s.days + 1
            s.kills = s.kills + day.killTotal
            s.quests = s.quests + #day.qd
            s.deaths = s.deaths + day.deaths
            s.km = s.km + (day.steps or 0) * 0.9144 / 1000
            for _, l in ipairs(day.levels) do s.levels[#s.levels + 1] = l end
            if day.killTotal > s.bestK then s.best, s.bestK = d, day.killTotal end
        end
    end
    local zones, marks, honours = {}, {}, {}
    for name, z in pairs(C.zones) do
        if z.day and z.day >= from and z.day <= to then zones[#zones + 1] = name end
        for _, t in pairs(z.sub or {}) do
            local d = WFD:DayIndex(t)
            if d >= from and d <= to then s.places = s.places + 1 end
        end
    end
    for _, ev in ipairs(C.events) do
        if ev.day and ev.day >= from and ev.day <= to then
            if ev.k == "landmark" then marks[#marks + 1] = ev.s:match(":%s*(.+)$") or ev.s end
            if ev.k == "honour" then honours[#honours + 1] = ev.s:match(":%s*(.+)$") or ev.s end
        end
    end
    s.zones, s.marks, s.honours = zones, marks, honours
    return s
end

local function list3(t)
    local out = {}
    for i = 1, min(3, #t) do out[#out + 1] = t[i] end
    local txt = table.concat(out, ", ")
    if #t > 3 then txt = txt .. format(" (+%d)", #t - 3) end
    return txt
end

local recap
local RW, RH = 400, 360

local function buildRecap()
    local f = UI.Frame(UIParent, RW, RH)
    f:SetPoint("CENTER", 0, 40)
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    _G.WoWForeverDiaryRecap = f
    tinsert(UISpecialFrames, "WoWForeverDiaryRecap")
    local shadow = UI.Fill(f, { 0, 0, 0 }, "BACKGROUND", -8, 0.45)
    shadow:SetPoint("TOPLEFT", 8, -10)
    shadow:SetPoint("BOTTOMRIGHT", 8, -10)
    local paper = UI.Page(f, RW, RH)
    paper:SetPoint("TOPLEFT")
    paper:SetFrameLevel(f:GetFrameLevel() + 1)
    local edge = UI.Frame(f)
    edge:SetAllPoints()
    edge:SetFrameLevel(f:GetFrameLevel() + 2)
    UI.Backdrop(edge, "gold", 16, 4, { 0, 0, 0, 0 }, { 1, 0.92, 0.75, 1 })
    local canvas = CreateFrame("Frame", nil, f)
    canvas:SetAllPoints()
    canvas:SetFrameLevel(f:GetFrameLevel() + 5)
    f.canvas = canvas
    f.pool = UI.NewPool(canvas)
    local open = UI.InkButton(canvas, L["Open the diary"], function()
        f:Hide()
        UI:OpenAt("diary")
    end, 15, c.redInk)
    open:SetPoint("BOTTOMRIGHT", -34, 20)
    local close = UI.InkButton(canvas, L["Close"], function() f:Hide() end, 15, c.inkSoft)
    close:SetPoint("BOTTOMLEFT", 34, 20)
    f:Hide()
    return f
end

-- force: show the last seven days even if this week's look back was already shown
function UI:ShowRecap(force)
    local C = WFD.C
    if not C then return end
    local today = WFD:DayIndex()
    local from, to = max(1, today - 7), force and today or (today - 1)
    if to < from then return end
    local s = weekStats(from, to)
    if s.days == 0 and not force then return end
    recap = recap or buildRecap()
    local pool, canvas = recap.pool, recap.canvas
    pool:Begin()
    local W = RW - 64

    local t = pool:Text(26, c.ink, UI.HEAD, "CENTER")
    t:SetText(L["The week in review"])
    UI.FitText(t, RW - 70, 26, 16)
    t:SetPoint("TOP", canvas, "TOP", 0, -26)
    local sub = pool:Text(9, c.redInk, UI.FONT, "CENTER")
    sub:SetText((date(WFD.loc.date, WFD:DayTime(from)) .. "  -  " .. date(WFD.loc.date, WFD:DayTime(to))):upper())
    sub:SetPoint("TOP", canvas, "TOP", 0, -60)
    UI.PageDivider(pool, canvas, RW / 2, -78, 200)

    -- six figures in two rows
    local figs = {
        { s.kills, L["Creatures slain"] }, { s.quests, L["Quests"] }, { #s.levels > 0 and ("+" .. #s.levels) or "0", L["Levels"] },
        { WFD:Dec(s.km), L["Kilometres"] }, { s.places, L["New places"] }, { s.deaths, L["Deaths"] },
    }
    local tw = (W - 16) / 3
    for i, fg in ipairs(figs) do
        local col = (i - 1) % 3
        local row = floor((i - 1) / 3)
        local x = 32 + col * (tw + 8)
        local y = -94 - row * 50
        local bg = pool:Rect(c.paperDk, 0.45)
        bg:SetSize(tw, 42)
        bg:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
        local v = pool:Text(18, (i == 6 and s.deaths > 0) and c.redInk or c.ink, UI.HEAD, "CENTER")
        v:SetText(tostring(fg[1]))
        v:SetWidth(tw)
        v:SetPoint("TOP", bg, "TOP", 0, -5)
        local l = pool:Text(9, c.inkSoft, UI.FONT, "CENTER")
        l:SetText(fg[2]:upper())
        UI.FitText(l, tw - 6, 9, 7, UI.FONT)
        l:SetWidth(tw - 4)
        l:SetWordWrap(false)
        l:SetPoint("TOP", bg, "TOP", 0, -28)
    end

    -- the highlights
    local lines = {}
    if #s.zones > 0 then lines[#lines + 1] = { L["New regions"], list3(s.zones) } end
    if #s.marks > 0 then lines[#lines + 1] = { L["Landmarks"], list3(s.marks) } end
    if #s.honours > 0 then lines[#lines + 1] = { L["Honours"], list3(s.honours) } end
    if s.best then lines[#lines + 1] = { L["Best day"], format(L["Day %d"], s.best) .. "  -  " .. format(L["%d kills"], s.bestK) } end
    if #lines == 0 then lines[1] = { L["A quiet week"], L["The book waits for new stories."] } end
    local y = -204
    for i = 1, min(4, #lines) do
        local k = pool:Text(10, c.redInk, UI.FONT)
        k:SetText(lines[i][1]:upper())
        k:SetPoint("TOPLEFT", canvas, "TOPLEFT", 32, y)
        local v = pool:Text(12, c.ink, UI.FONT)
        v:SetText(lines[i][2])
        v:SetWidth(W)
        v:SetWordWrap(false)
        v:SetPoint("TOPLEFT", canvas, "TOPLEFT", 32, y - 12)
        y = y - 30
    end
    pool:End()
    recap:Show()
    UI.Sound("IG_SPELLBOOK_OPEN", 829)
end

-- once a calendar week, a few seconds after logging in
WFD:OnInit(function()
    if not (C_Timer and C_Timer.After) then return end
    C_Timer.After(8, function()
        local C, S = WFD.C, WFD.S
        if not C or WFD.paused or (S and S.recap == false) then return end
        local week = date("%Y-%W")
        if C.recapWeek == week then return end
        local today = WFD:DayIndex()
        if today <= 1 then return end
        C.recapWeek = week
        UI:ShowRecap(false)
    end)
end)
