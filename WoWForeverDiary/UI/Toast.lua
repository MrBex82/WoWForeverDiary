-- Little cards that slide in when something new happens, the memory at login and the weekly look back.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

------------------------------------------------------------------------
-- Opening the book at the right place
------------------------------------------------------------------------
function UI:OpenAt(target)
    -- today and the settings have views of their own on the travel desk
    if target == "today" and self.OpenStart then return self:OpenStart() end
    if target == "notes" then return self:OpenSettings() end
    if type(target) == "string" and UI.PART_VIEW and UI.PART_VIEW[target] then
        return self:OpenShell(UI.PartRoute(target))
    end
    -- a day: the diary
    if type(target) == "number" then
        return self:OpenShell({ view = "diary", day = UI.DayGo(target) and target or nil })
    end
    self:OpenShell({ view = "start" })
end

-- the words that open a part with "/wfd <word>": the key of the part, in English and German
local PART_WORDS = {
    today = "today", heute = "today", diary = "diary", tagebuch = "diary", contents = "toc", inhalt = "toc",
    tasks = "tasks", aufgaben = "tasks", collection = "collection", sammelalbum = "collection", honour = "honour",
    honor = "honour", ehrenbuch = "honour", ehren = "honour", milestones = "milestones", meilensteine = "milestones",
    firsts = "firsts", erstes = "firsts", records = "records", rekorde = "records", levels = "levels", stufen = "levels",
    gallery = "gallery", galerie = "gallery", atlas = "atlas", maps = "maps", karten = "maps",
    landmarks = "landmarks", sehenswuerdigkeiten = "landmarks", ["sehenswürdigkeiten"] = "landmarks",
    gathering = "gathering", fundorte = "gathering", runs = "runs", dungeons = "runs", bestiary = "bestiary",
    bestiarium = "bestiary", nemesis = "nemesis", nemeses = "nemesis", erzfeinde = "nemesis", fate = "fates", fates = "fates",
    schicksal = "fates", fishbook = "fishbook",
    fishing = "fishbook", angeln = "fishbook", anglerbuch = "fishbook", treasures = "treasures", schaetze = "treasures",
    ["schätze"] = "treasures", people = "people", personen = "people", companions = "companions",
    gefaehrten = "companions", ["gefährten"] = "companions", ledger = "ledger", kassenbuch = "ledger",
    quests = "quests", questbuch = "quests", family = "family", familie = "family", capsule = "capsule",
    zeitkapsel = "capsule", library = "library", bibliothek = "library", books = "library", buecher = "library",
    ["bücher"] = "library", settings = "notes", einstellungen = "notes", options = "notes",
}

-- opens the book at a part by one of its words, or at a diary day by its number; false if the word is unknown
function UI:OpenPart(word)
    word = strlower(strtrim(word or ""))
    local day = tonumber(word)
    if day then
        self:OpenAt(floor(day))
        return true
    end
    local key = PART_WORDS[word]
    if not key then return false end
    -- "diary" leads to today's entry, as the tab of the diary does; "today" to the page called Today
    if key == "diary" then self:OpenShell({ view = "diary", day = WFD:NumDays() }) return true end
    self:OpenAt(key)
    return true
end

-- where a milestone is best read
local TARGET = { honour = "honour", landmark = "landmarks", dungeon = "runs", challenge = "collection", weekly = "collection",
    first = "firsts", capsule = "capsule", catch = "fishbook", summary = "today" }

------------------------------------------------------------------------
-- Toasts: small cards in the style of the desk, up to three on top of each other. More than that wait; when many
-- wait at once they become one card that leads to Start, where everything new is listed.
------------------------------------------------------------------------
local K = UI.Kit
local TW, TH = 400, 104
local TX = 86                -- where the words start
local NAME_W = TW - TX - 92  -- room left of the points
local IN, HOLD, OUT = 0.35, 7, 0.6
local SCALE = 0.8            -- the cards are drawn a little smaller than laid out
local MAX_SHOWN = 3
local queue = {}
local shown = {}             -- the cards on the screen, the newest at the top
local spare = {}             -- cards put away, to be used again
local stack                  -- the frame the cards hang from: the player can drag it

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
    p.lo = UI.Fill(p, { 0, 0, 0 }, "ARTWORK", 1, 0.5)
    p.lo:SetPoint("BOTTOMLEFT")
    p.lo:SetPoint("BOTTOMRIGHT")
    p.lo:SetHeight(1)
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

-- The size the player chose (the mouse wheel over a card), as a factor of the usual size
local MIN_SIZE, MAX_SIZE = 0.6, 2
local function sizeFactor()
    local v = WFD.S and tonumber(WFD.S.toastSize) or 1
    return math.max(MIN_SIZE, math.min(MAX_SIZE, v))
end

-- where the stack stands: the place the player dragged it to, else the top of the screen
local function placeStack()
    local p = WFD.S and WFD.S.toastPos
    stack:ClearAllPoints()
    if p then stack:SetPoint(p[1], UIParent, p[2], p[3], p[4])
    else stack:SetPoint("TOP", UIParent, "TOP", 0, -140 / stack:GetScale()) end
end

local function buildStack()
    stack = CreateFrame("Frame", "WoWForeverDiaryToasts", UIParent)
    stack:SetSize(TW, TH)
    stack:SetFrameStrata("HIGH")
    stack:SetClampedToScreen(true)
    stack:SetMovable(true)
    stack:SetScale(SCALE * sizeFactor())
    placeStack()
end

local function setSize(factor)
    factor = math.max(MIN_SIZE, math.min(MAX_SIZE, factor))
    local old = stack:GetScale()
    if WFD.S then WFD.S.toastSize = factor end
    stack:SetScale(SCALE * factor)
    local p = WFD.S and WFD.S.toastPos
    if p then
        local k = old / stack:GetScale()
        p[3], p[4] = p[3] * k, p[4] * k
    end
    placeStack()
end

-- back to the top of the screen, at the usual size
function UI:ResetToastPlace()
    if WFD.S then WFD.S.toastPos, WFD.S.toastSize = nil, nil end
    if stack then
        stack:SetScale(SCALE)
        placeStack()
    end
end

-- the cards one below the other, the newest on top; a card that is sliding in comes from a little above
local function layout()
    local y = 0
    for _, f in ipairs(shown) do
        f:ClearAllPoints()
        f:SetPoint("TOP", stack, "TOP", 0, -y + (f.lift or 0))
        y = y + TH + 8
    end
end

local function closeCard(f) if f.phase ~= "out" then f.phase, f.t = "out", 0 end end

local function buildCard()
    local f = K.Box(stack, "panel", "gold", "Button")
    f:SetSize(TW, TH)
    K.Material(f, "dark")
    f:SetFrameStrata("HIGH")
    local sh = UI.Fill(f, { 0, 0, 0 }, "BACKGROUND", -8, 0.4)
    sh:SetPoint("TOPLEFT", 4, -6)
    sh:SetPoint("BOTTOMRIGHT", 4, -6)
    f.glow = UI.Circle(f, 80, c.gold, "BORDER", 0)
    f.glow:SetPoint("CENTER", f, "LEFT", 44, 0)
    f.plaque = makePlaque(f, 46)
    f.plaque:SetPoint("CENTER", f, "LEFT", 44, 0)
    f.plaque:SetFrameLevel(f:GetFrameLevel() + 2)
    f.kicker = K.Text(f, "section", "railGold")
    f.kicker:SetPoint("TOPLEFT", TX, -14)
    f.name = K.Text(f, "heading", "railTitle")
    f.name:SetPoint("TOPLEFT", TX, -30)
    f.name:SetWidth(NAME_W)
    f.name:SetWordWrap(false)
    f.metal = K.Text(f, "section", "railGold")
    f.metal:SetPoint("TOPLEFT", f.name, "BOTTOMLEFT", 0, -4)
    f.pips = {}
    for i = 1, 5 do f.pips[i] = UI.Diamond(f, 7, c.gold, "ARTWORK", 2) end
    f.hint = K.Text(f, "small", "rail")
    f.hint:SetWidth(TW - TX - 16)
    f.hint:SetJustifyV("TOP")
    if f.hint.SetMaxLines then f.hint:SetMaxLines(2) end
    f.points = K.Text(f, "title", "railGold", "RIGHT")
    f.points:SetPoint("TOPRIGHT", -42, -14)
    f.close = K.IconButton(f, "close", { L["Close"] }, function() closeCard(f) end, 22)
    f.close:SetFlat(true)
    f.close:SetPoint("TOPRIGHT", -8, -8)
    -- a click opens the diary where the moment is told; a right-click only puts the card away
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self.dragging = true stack:StartMoving() end)
    f:SetScript("OnDragStop", function(self)
        stack:StopMovingOrSizing()
        self.dragging = false
        self.dragged = GetTime()
        local a, _, b, x, y = stack:GetPoint(1)
        if WFD.S then WFD.S.toastPos = { a, b, x, y } end
    end)
    f:EnableMouseWheel(true)
    f:SetScript("OnMouseWheel", function(_, delta) setSize(sizeFactor() + (delta > 0 and 0.1 or -0.1)) end)
    f:SetScript("OnClick", function(self, button)
        GameTooltip:Hide()
        if self.dragged and GetTime() - self.dragged < 0.3 then return end     -- the end of a drag is no click
        closeCard(self)
        if button == "RightButton" then return end
        if self.go then self.go() end
    end)
    f:SetScript("OnEnter", function(self)
        K.ShowTip(self, L["Right-click to close."], { L["Drag to move."], L["Mouse wheel changes the size."] }, "ANCHOR_BOTTOM")
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f:SetScript("OnUpdate", function(self, dt)
        self.t = self.t + dt
        self.life = (self.life or 0) + dt
        self.glow:SetAlpha(0.16 + 0.10 * math.sin(self.life * 3))
        if self.dragging then self.t = 0 self:SetAlpha(1) return end
        if self.phase == "in" then
            local a = min(1, self.t / IN)
            self:SetAlpha(a)
            self.lift = (1 - a) * 24
            layout()
            if a >= 1 then self.phase, self.t, self.lift = "hold", 0, 0 end
        elseif self.phase == "hold" then
            if self:IsMouseOver() then self.t = 0 end
            if self.t >= HOLD then self.phase, self.t = "out", 0 end
        else
            local a = max(0, 1 - self.t / OUT)
            self:SetAlpha(a)
            if a <= 0 then
                self:Hide()
                for i, g in ipairs(shown) do if g == self then table.remove(shown, i) break end end
                spare[#spare + 1] = self
                layout()
                UI:NextToast()
            end
        end
    end)
    return f
end

local function fill(f, ev)
    local d = UI.DescribeMoment(ev)
    f.plaque:Set(d.icon, d.col)
    f.glow:SetVertexColor(d.col[1], d.col[2], d.col[3], 1)
    f.kicker:SetText(UI.Upper(d.kicker or ""))
    f.name:SetText(d.name or "")
    UI.FitText(f.name, NAME_W, UI.FS(16), UI.FS(12))
    f.metal:SetText(UI.Upper(d.metal or ""))
    if d.metalCol then f.metal:SetTextColor(d.metalCol[1], d.metalCol[2], d.metalCol[3], 1) else K.Recolor(f.metal, "railGold") end
    local mw = (d.metal and d.metal ~= "") and (f.metal:GetStringWidth() + 10) or 0
    for i = 1, 5 do
        local p = f.pips[i]
        if d.n and i <= d.n then
            p:ClearAllPoints()
            p:SetPoint("LEFT", f.metal, "LEFT", mw + (i - 1) * 11, 0)
            local got = i <= d.pips
            local mc = got and (d.pipCol or WFD:MetalOf(i, d.n).col) or { 0.45, 0.32, 0.18, 1 }
            p:SetVertexColor(mc[1], mc[2], mc[3], 1)
            p:SetSize(got and 8 or 6, got and 8 or 6)
            p:Show()
        else
            p:Hide()
        end
    end
    f.hint:ClearAllPoints()
    f.hint:SetPoint("TOPLEFT", (d.metal and d.metal ~= "") and f.metal or f.name, "BOTTOMLEFT", 0, -5)
    f.hint:SetText(d.hint or "")
    f.points:SetText(d.points and ("+" .. d.points) or "")
    f.go = d.go
end

function UI:NextToast()
    if #shown >= MAX_SHOWN or #queue == 0 then return end
    local ev = table.remove(queue, 1)
    -- many at once (a dungeon, a big fight): one card for all of them that leads to everything new on Start
    if #queue >= MAX_SHOWN then
        ev = { k = "summary", n = #queue + 1, t = time() }
        queue = {}
    end
    if not stack then buildStack() end
    local f = table.remove(spare) or buildCard()
    fill(f, ev)
    f.ev = ev
    f.phase, f.t, f.life, f.lift = "in", 0, 0, 24
    f:SetAlpha(0)
    table.insert(shown, 1, f)
    f:Show()
    layout()
    if not ev.quiet then
        UI.Sound(ev.k == "honour" and "IG_QUEST_LIST_COMPLETE" or "IG_ABILITY_PAGE_TURN", ev.k == "honour" and 878 or 836)
    end
    -- room for one more: the next waiting card comes right after
    if #queue > 0 and #shown < MAX_SHOWN then C_Timer.After(0.4, function() UI:NextToast() end) end
end

-- force: shown even with the notes switched off (asked for with /wfd memory); every note asks the setting of the
-- notifications (everything, only what matters, nothing)
function UI:Toast(ev, force)
    if not ev then return end
    if not force then
        if WFD.S and WFD.S.toasts == false then return end
        if ev.k ~= "memory" and ev.k ~= "recap" and WFD.ShouldNotify and not WFD:ShouldNotify(ev.k) then return end
    end
    queue[#queue + 1] = ev
    self:NextToast()
end

-- the cards on the screen and those waiting (the load test reads it)
function UI.ToastCount() return #shown, #queue end

local HONOUR_FLAVOUR = {
    combat = "Steel sharpened, name written down.", explore = "The road is longer, and so is the map.",
    people = "Strangers become faces in the book.", adventure = "Another line in the story of this life.",
    fortune = "Not every treasure shines at first.", secret = "Some pages only open for the curious.",
}

-- what to show for a milestone: icon, frame colour, kicker, name, metal line, pips, hint, points
function UI.DescribeMoment(ev)
    local subject = (ev.k ~= "level" and ev.s and ev.s:match(":%s*(.+)$")) or ev.s or ""
    local icon, col = UI.MomentIcon(ev)
    local d = {
        icon = icon, col = col, kicker = L[UI.SEAL_LABEL[ev.k] or "Moment"], name = subject,
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
            local nextText = nextGoal and (L["Next tier:"] .. " " .. WFD:HonourText(h, nextGoal)) or L["Every tier earned!"]
            -- a line of its own for the kind of honour, then what comes next
            local flavour = HONOUR_FLAVOUR[h.cat]
            d.hint = flavour and (L[flavour] .. "\n" .. nextText) or nextText
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
        d.kicker = ev.month and L["Task of the month"] or L["Task of the week"]
        d.hint = L["Click for the next goals."]
    elseif ev.k == "summary" then
        d.icon, d.col = UI.Icon("journal"), c.gold
        d.kicker = L["Diary"]
        d.name = format(L["%d new moments"], ev.n or 0)
        d.hint = L["Click to see them all on Start."]
    elseif ev.k == "memory" then
        d.icon, d.col = UI.Icon(ev.jubilee and "honour" or "time"), c.gold
        d.kicker = ev.when or L["A memory"]
        d.name = ev.title or ""
        d.hint = ev.hint or L["Click to read this day."]
    elseif ev.k == "place" then
        -- a new place inside a land you know: its name, the land below it
        d.name = ev.place or ""
        d.metal = ev.zone
        d.metalCol = c.green
        d.hint = L["Click to read this day."]
    elseif ev.k == "capsule" then
        d.kicker = L["Time capsule"]
        d.name = L["A letter from the past has opened."]
        d.hint = L["Click to read the letter."]
    elseif ev.k == "recap" then
        d.icon, d.col = UI.Icon("records"), c.gold
        d.kicker = L["The week in review"]
        d.name = ev.title or ""
        d.hint = L["Click to read the week."]
        d.go = function() UI:OpenShell({ view = "recap" }) end
    else
        d.hint = L["Click to read this day."]
    end
    d.go = d.go or function() UI:OpenAt(TARGET[ev.k] or ev.day) end
    return d
end

-- a place discovered inside a land you know: a small note of its own, without a screenshot and not kept as a
-- moment (there are many of them); only with every note switched on
WFD:OnSignal("place", function(place, zone)
    if WFD.paused or WFD.demo then return end
    if WFD.ShouldNotify and not WFD:ShouldNotify("place") then return end
    UI:Toast({ k = "place", place = place, zone = zone, t = time(), day = WFD:DayIndex() })
end)

-- a death is written into the diary, but no note pops up for it
WFD:OnSignal("milestone", function(ev)
    if ev.k == "kills" or WFD:IsDeathEvent(ev) then return end
    if not WFD.ShouldNotify or WFD:ShouldNotify(ev.k) then UI:Toast(ev) end
end)

------------------------------------------------------------------------
-- A memory at login, without a sound: an anniversary once, otherwise this day in an earlier year once a day
------------------------------------------------------------------------
local JUBILEE_TITLE = { born = "The diary's birthday", hours = "%d hours in the world", level = "Level %d", death = "A day of mourning" }

-- force: show it now, even if it was shown today or the notes are switched off
function UI:ShowMemory(force)
    local C, S = WFD.C, WFD.S
    if not (C and S and WFD.OnThisDay) then return end
    if not force and (WFD.paused or S.memoryToast == false or S.toasts == false or S.notify == "quiet") then return end
    for _, j in ipairs(WFD:Jubilees()) do
        if force or not j.shown then
            WFD:JubileeShown(j)
            local title = L[JUBILEE_TITLE[j.kind]]
            if j.kind ~= "born" and j.kind ~= "death" then title = format(title, j.kind == "level" and j.level or j.n) end
            self:Toast({ k = "memory", jubilee = true, when = L["Anniversary"], title = title, hint = j.text,
                day = j.idx, t = time(), quiet = true }, force)
            return
        end
    end
    local today = date("%Y-%m-%d")
    if not force and C.memoryDay == today then return end
    local m = WFD:OnThisDay()
    if not m then
        if force then print("|cffffd100WoW Forever Diary:|r " .. L["Nothing from earlier days to remember today."]) end
        return
    end
    if not WFD.demo then C.memoryDay = today end
    self:Toast({ k = "memory", when = m.when, title = m.title, day = m.idx, t = time(), quiet = true }, force)
end

WFD:OnInit(function()
    if not (C_Timer and C_Timer.After) then return end
    C_Timer.After(12, function()
        if UI.recapToday then return end         -- one card at login is enough: the look back came first
        local ok, err = pcall(UI.ShowMemory, UI, false)
        if not ok then WFD:Error("memory", err) end
    end)
end)

------------------------------------------------------------------------
-- The week in review: a calendar week (Monday to Sunday) as a page of the chronicle. At login, once a week, a
-- card says that last week's look back is ready.
------------------------------------------------------------------------
-- the days of a calendar week: offset 0 is this week, 1 the week before ...
function WFD:WeekRange(offset)
    local today = self:DayIndex()
    local wday = tonumber(date("%w", self:DayTime(today))) or 1      -- 0 = Sunday
    local sinceMonday = (wday + 6) % 7
    local from = today - sinceMonday - 7 * (offset or 0)
    return max(1, from), min(today, from + 6)
end

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
    table.sort(zones)
    for _, ev in ipairs(C.events) do
        if ev.day and ev.day >= from and ev.day <= to then
            if ev.k == "landmark" then marks[#marks + 1] = ev.s:match(":%s*(.+)$") or ev.s end
            if ev.k == "honour" then honours[#honours + 1] = ev.s:match(":%s*(.+)$") or ev.s end
        end
    end
    s.zones, s.marks, s.honours = zones, marks, honours
    return s
end

local function weekTitle(from, to)
    return date(WFD.loc.date, WFD:DayTime(from)) .. "  -  " .. date(WFD.loc.date, WFD:DayTime(to))
end

-- (for the page of the look back in the chronicle: UI/Views/Chronicle.lua)
UI.WeekStats, UI.WeekTitle = weekStats, weekTitle

-- force: open the look back at once (/wfd recap)
function UI:ShowRecap(force)
    if force then self:OpenShell({ view = "recap", week = 0 }) return end
    local from, to = WFD:WeekRange(1)
    if to < from or weekStats(from, to).days == 0 then return false end
    self:Toast({ k = "recap", title = weekTitle(from, to), t = time(), quiet = true })
    return true
end

-- once a calendar week, a few seconds after logging in; the memory of the day waits for another login then
WFD:OnInit(function()
    if not (C_Timer and C_Timer.After) then return end
    C_Timer.After(8, function()
        local C, S = WFD.C, WFD.S
        if not C or WFD.paused or (S and S.recap == false) then return end
        local week = date("%Y-%W")
        if C.recapWeek == week then return end
        if WFD:DayIndex() <= 1 then return end
        C.recapWeek = week
        if UI:ShowRecap(false) then UI.recapToday = true end
    end)
end)
