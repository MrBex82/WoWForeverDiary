-- Export tab: copy your diary as text or JSON, plus settings
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local format, concat = string.format, table.concat

------------------------------------------------------------------------
-- Text export
------------------------------------------------------------------------
function WFD:ExportText()
    local C = self.C
    local out = {}
    local function add(s) out[#out + 1] = s end
    add(format("=== %s ===", format(L["Travel Diary of %s"], C.name or "?")))
    add(format("%s %s  |  %s", C.race or "", C.class or "", C.realm or ""))
    add(L["Born:"] .. " " .. date(WFD.loc.date .. " %H:%M", C.born))
    add("")
    for idx = 1, self:NumDays() do
        local f = self:DayFacts(idx)
        add(format("--- %s - %s ---", format(L["Day %d"], idx), self:DateStr(idx)))
        add(self:Narrate(idx))
        if f then
            local d = f.d
            add("")
            add(format("%s: %d | %s: %d/%d | %s: %d | XP: +%d | %s: %.1f km | %s: %s",
                L["Enemies slain"], d.killTotal, L["Quests completed"], #d.qd, #d.qa,
                L["People spoken to"], f.npcCount, d.xp, L["Distance travelled"], f.km,
                L["Time online"], self:DurationText(d.online)))
            add(format("%s: %s | %s: %s | %s: %s | %s: %d",
                L["Income"], self:CoinText(f.income), L["Expenses"], self:CoinText(f.spend),
                L["Net"], self:CoinText(f.net), L["Deaths"], d.deaths))
            if #f.mobs > 0 then
                local t = {}
                for i = 1, math.min(10, #f.mobs) do t[#t + 1] = format("%s x%d", f.mobs[i].name, f.mobs[i].n) end
                add(L["Fallen foes"] .. ": " .. concat(t, ", "))
            end
            if #f.items > 0 then
                local t = {}
                for i = 1, math.min(12, #f.items) do t[#t + 1] = format("%s x%d", self:ItemName(f.items[i].link), f.items[i].n) end
                add(L["Loot"] .. ": " .. concat(t, ", "))
            end
        end
        add("")
    end
    return concat(out, "\n")
end

------------------------------------------------------------------------
-- JSON export
------------------------------------------------------------------------
local function esc(s)
    s = tostring(s)
    s = s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", ""):gsub("\t", "\\t")
    s = s:gsub("[%c]", "")
    return '"' .. s .. '"'
end

local function isArray(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n == #t
end

local function enc(v, out)
    local tv = type(v)
    if tv == "number" then
        -- JSON knows no infinity; "%d" cuts big numbers (copper, time stamps) on some systems, "%.0f" does not
        if v ~= v or v == math.huge or v == -math.huge then
            out[#out + 1] = "null"
        else
            out[#out + 1] = (v == math.floor(v)) and format("%.0f", v) or format("%.3f", v)
        end
    elseif tv == "boolean" then
        out[#out + 1] = v and "true" or "false"
    elseif tv == "string" then
        out[#out + 1] = esc(v)
    elseif tv == "table" then
        if next(v) == nil then
            out[#out + 1] = "[]"
        elseif isArray(v) then
            out[#out + 1] = "["
            for i = 1, #v do
                if i > 1 then out[#out + 1] = "," end
                enc(v[i], out)
            end
            out[#out + 1] = "]"
        else
            out[#out + 1] = "{"
            local first = true
            local keys = {}
            for k in pairs(v) do keys[#keys + 1] = k end
            table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
            for _, k in ipairs(keys) do
                if not first then out[#out + 1] = "," end
                first = false
                out[#out + 1] = esc(k) .. ":"
                enc(v[k], out)
            end
            out[#out + 1] = "}"
        end
    else
        out[#out + 1] = "null"
    end
end

function WFD:ExportJSON()
    local C = self.C
    local data = {
        character = { name = C.name, realm = C.realm, class = C.class, race = C.race, born = C.born, startZone = C.startZone },
        totals = self:Totals(),
        days = {},
    }
    for idx = 1, self:NumDays() do
        local f = self:DayFacts(idx)
        if f then
            local d = f.d
            local day = {
                day = idx, date = self:DateStr(idx), story = self:Narrate(idx),
                kills = {}, quests = {}, npcs = {}, loot = {}, zones = {}, events = {},
                killTotal = d.killTotal, xp = d.xp, deaths = d.deaths, jumps = d.jumps or 0,
                income = d.income, spend = d.spend,
                kmWalked = f.km, levels = d.levels,
            }
            day.onlineSeconds = math.floor(d.online or 0)
            for _, m in ipairs(f.mobs) do day.kills[#day.kills + 1] = { name = m.name, count = m.n, boss = m.boss or false } end
            for _, id in ipairs(d.qd) do
                local q = C.quests[id]
                day.quests[#day.quests + 1] = { id = id, title = q and q.title or "?", xp = q and q.xp or 0 }
            end
            for _, n in ipairs(f.npcList) do day.npcs[#day.npcs + 1] = { name = n.name, talks = n.n } end
            for _, it in ipairs(f.items) do
                day.loot[#day.loot + 1] = { item = self:ItemName(it.link), count = it.n, quality = it.q }
            end
            for _, z in ipairs(f.zones) do day.zones[#day.zones + 1] = { zone = z.k, seconds = math.floor(z.v) } end
            for _, ev in ipairs(f.events) do day.events[#day.events + 1] = { kind = ev.k, text = ev.s, time = ev.t, screenshot = ev.shot } end
            data.days[#data.days + 1] = day
        end
    end
    local out = {}
    enc(data, out)
    return concat(out)
end

------------------------------------------------------------------------
-- Transcript popup (opened from the scribe's notes at the back of the book)
------------------------------------------------------------------------
function UI:ShowTranscript(kind)
    local pop = self.transcript
    if not pop then
        pop = UI.Frame(UIParent, 560, 460)
        pop:SetPoint("CENTER")
        pop:SetFrameStrata("DIALOG")
        pop:EnableMouse(true)
        pop:SetMovable(true)
        pop:RegisterForDrag("LeftButton")
        pop:SetScript("OnDragStart", pop.StartMoving)
        pop:SetScript("OnDragStop", pop.StopMovingOrSizing)
        UI.Backdrop(pop, "dialog", 32, 11, c.paper, { 1, 0.92, 0.80, 1 })
        tinsert(UISpecialFrames, "WoWForeverDiaryTranscript")
        _G.WoWForeverDiaryTranscript = pop
        local banner = pop:CreateTexture(nil, "ARTWORK")
        banner:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
        banner:SetSize(300, 64)
        banner:SetPoint("TOP", 0, 13)
        local bt = UI.Text(pop, 15, c.gold, "CENTER", UI.HEAD, true)
        bt:SetPoint("TOP", banner, "TOP", 0, -13)
        bt:SetText(L["Transcript"])
        local ok, close = pcall(CreateFrame, "Button", nil, pop, "UIPanelCloseButton")
        if ok and close then close:SetPoint("TOPRIGHT", -6, -6) end
        local hint = UI.Text(pop, 13, c.inkSoft, "CENTER", UI.HEAD)
        hint:SetPoint("TOP", 0, -34)
        hint:SetText(L["Ctrl+C copies the selection."])
        local inset = UI.Inset(pop, 520, 380)
        inset:SetPoint("TOP", 0, -56)
        local sf = CreateFrame("ScrollFrame", nil, inset)
        sf:SetPoint("TOPLEFT", 10, -10)
        sf:SetPoint("BOTTOMRIGHT", -10, 10)
        local eb = CreateFrame("EditBox", nil, sf)
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false)
        eb:SetFont(UI.FONT, 11, "")
        eb:SetTextColor(UI.col4(c.ink))
        eb:SetShadowOffset(0, 0)
        eb:SetWidth(496)
        eb:SetMaxLetters(0)
        sf:SetScrollChild(eb)
        eb:SetScript("OnEscapePressed", function(self) self:ClearFocus(); pop:Hide() end)
        eb:SetScript("OnTextChanged", function(self, user)
            if user and pop.text and self:GetText() ~= pop.text then self:SetText(pop.text) end
        end)
        sf:EnableMouseWheel(true)
        sf:SetScript("OnMouseWheel", function(self, delta)
            local range = self:GetVerticalScrollRange() or 0
            self:SetVerticalScroll(math.max(0, math.min(range, (self:GetVerticalScroll() or 0) - delta * 60)))
        end)
        pop.edit, pop.sf = eb, sf
        self.transcript = pop
    end
    local ok, text = pcall(function()
        if kind == "json" then return WFD:ExportJSON() end
        if kind == "markdown" then return WFD:ExportMarkdown() end
        return WFD:ExportText()
    end)
    if not ok then text = "Error: " .. tostring(text) end
    pop.text = text
    pop.edit:SetText(text)
    pop.sf:SetVerticalScroll(0)
    pop:Show()
    pop.edit:SetFocus()
    pop.edit:HighlightText()
end

------------------------------------------------------------------------
-- Forum / Discord export (Markdown): chapters, days, own thoughts
------------------------------------------------------------------------
function WFD:ExportMarkdown()
    local C = self.C
    local out = {}
    local function add(s) out[#out + 1] = s end
    add("# " .. format(L["Travel Diary of %s"], C.name or "?"))
    add("*" .. (C.race or "") .. " " .. (C.class or "") .. " - " .. (C.realm or "") .. "*  ")
    add("*" .. format(L["Begun on %s"], self:LongDate(1)) .. "*")
    add("")
    for _, ch in ipairs(UI.Chapters()) do
        add("## " .. L["Chapter"] .. " " .. ch.roman .. " - " .. ch.title)
        add("*" .. ch.sub .. "*")
        add("")
        for _, day in ipairs(ch.days) do
            local f = self:DayFacts(day)
            add("### " .. self:LongDate(day) .. " (" .. format(L["Day %d"], day) .. ")")
            add("")
            add((self:Narrate(day):gsub("\n\n", "\n\n")))
            local own = C.dayNotes and C.dayNotes[day]
            if own and own ~= "" then
                add("")
                add("> **" .. L["My own thoughts:"] .. "** " .. own:gsub("\n", "\n> "))
            end
            if f then
                local d = f.d
                add("")
                add(format("**%s:** %d  |  **%s:** %d  |  **XP:** +%d  |  **%s:** %s",
                    L["Enemies slain"], d.killTotal, L["Quests completed"], #d.qd, d.xp,
                    L["Net"], (f.net < 0 and "-" or "+") .. self:CoinText(math.abs(f.net))))
            end
            add("")
        end
    end
    local t = self:Totals()
    add("---")
    add(format(L["In total: %d kills  |  %d quests  |  %s online  |  %.1f km on foot  |  %d deaths  |  %d jumps"],
        t.kills, t.quests, self:DurationText(t.online), (t.steps * 0.9144) / 1000, t.deaths, t.jumps))
    return concat(out, "\n")
end
