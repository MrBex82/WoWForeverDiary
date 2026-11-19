-- What the bestiary and the people need on the travel desk: the order of the album, the trading card of a
-- creature, the roles of people.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local col4 = UI.col4
local max, format = math.max, string.format

-- (the milestones are a view of the travel desk now: UI/Views/Chronicle.lua)

-- (the maps of the regions are the world map of the travel desk now: UI/Views/World.lua)

------------------------------------------------------------------------
-- Bestiary as a collector's album: every creature is a trading card
------------------------------------------------------------------------
local function levelText(m)
    if not m.level then return "?" end
    if m.level == -1 then return "??" end
    return tostring(m.level)
end

local RARITY = {
    normal = { border = { 0.62, 0.58, 0.52, 1 }, bg1 = { 0.12, 0.10, 0.08, 1 }, bg2 = { 0.30, 0.26, 0.21, 1 } },
    elite  = { border = { 1.00, 0.80, 0.32, 1 }, bg1 = { 0.16, 0.10, 0.03, 1 }, bg2 = { 0.42, 0.30, 0.10, 1 } },
    rare   = { border = { 0.72, 0.84, 1.00, 1 }, bg1 = { 0.06, 0.09, 0.18, 1 }, bg2 = { 0.22, 0.30, 0.48, 1 } },
    boss   = { border = { 0.95, 0.30, 0.16, 1 }, bg1 = { 0.16, 0.03, 0.02, 1 }, bg2 = { 0.48, 0.10, 0.06, 1 } },
}
local function rarityOf(m)
    if m.boss then return "boss" end
    if m.rare or m.cls == "rare" or m.cls == "rareelite" then return "rare" end
    if m.cls == "elite" then return "elite" end
    return "normal"
end
UI.RarityOf, UI.LevelText = rarityOf, levelText
local RARITY_TAG = { elite = "Elite", rare = "Rare", boss = "Boss" }
local SKULL = "Interface\\TargetingFrame\\UI-TargetingFrame-Skull"

local TIERS = {           -- collector ranks of the bestiary (also shown on the collection page)
    { 10, "Bronze", { 0.70, 0.42, 0.20, 1 } }, { 25, "Silver", { 0.70, 0.72, 0.76, 1 } },
    { 50, "Gold", { 0.92, 0.72, 0.22, 1 } }, { 100, "Mithril", { 0.45, 0.70, 0.85, 1 } },
    { 200, "Legend", { 0.62, 0.22, 0.70, 1 } },
}
UI.BESTIARY_TIERS = TIERS
local CARD_W, CARD_H = 108, 136

-- collection order: first kill first, numbered like an album
local function collection()
    local arr = {}
    for id, m in pairs(WFD.C.mobs) do arr[#arr + 1] = { id = id, m = m } end
    table.sort(arr, function(a, b)
        if (a.m.first or 0) ~= (b.m.first or 0) then return (a.m.first or 0) < (b.m.first or 0) end
        return (a.m.name or "") < (b.m.name or "")
    end)
    for i, e in ipairs(arr) do e.num = i end
    return arr
end

-- every footstep on a map, all days added up. Days gone by do not change any more,
-- so their sum is kept for the session; only today is added each time.

-- (the album is a view of the travel desk now: UI/Views/Albums.lua; the hunting grounds are a layer of the
-- world map: UI/Views/World.lua)

-- for the album on the travel desk: the creatures in album order
UI.BestiaryCollection = collection

-- Where a long word may be broken: between syllables, as Latin writing does it - before a single consonant
-- between vowels, and before the letters a syllable can start with ("Wald-schreiter", "Mondpirscher-patriarch").
-- Returns the byte positions a break may come before, or an empty list for other scripts.
local VOWEL = {}
for _, v in ipairs({ "a", "e", "i", "o", "u", "y", "ä", "ö", "ü", "é", "è", "ê", "à", "á", "â", "ã", "í", "ó", "ô", "õ", "ú" }) do
    VOWEL[v] = true
end
local ONSET = {}
for _, o in ipairs({ "schr", "schl", "schw", "schm", "schn", "sch", "spr", "str", "chr", "ch", "ck", "ph", "th",
    "pf", "qu", "st", "sp", "br", "bl", "cr", "cl", "dr", "fr", "fl", "gr", "gl", "kr", "kl", "pr", "pl", "tr", "zw" }) do
    ONSET[o] = true
end
local function syllableBreaks(word)
    local chars, at = {}, {}
    for pos, ch in word:gmatch("()([%z\1-\127\194-\244][\128-\191]*)") do
        chars[#chars + 1] = ch:lower()
        at[#at + 1] = pos
    end
    local out, i = {}, 2
    while i < #chars do
        if not VOWEL[chars[i]] and VOWEL[chars[i - 1]] then
            local e = i
            while e < #chars and not VOWEL[chars[e + 1]] do e = e + 1 end
            if e < #chars and e - i <= 5 then
                local cut = e                      -- before the last consonant ...
                for len = math.min(4, e - i + 1), 2, -1 do
                    if ONSET[table.concat(chars, "", e - len + 1, e)] then cut = e - len + 1 break end
                end
                if cut > 2 and #chars - cut >= 2 then out[#out + 1] = at[cut] end
            end
            i = e + 1
        else
            i = i + 1
        end
    end
    -- the scripts this does not know (Cyrillic, Hangul ...): no breaks offered
    for _, ch in ipairs(chars) do if #ch > 1 and not VOWEL[ch] and not ch:find("^[\195]") then return {} end end
    return out
end

-- the name on the plate of a card: two lines at most, a smaller size before anything is cut, and a word
-- too long for one line broken at its hyphen, else between two syllables near its middle
local NAME_W = CARD_W - 20
local function fitName(fs, text)
    local function px(s) return UI.FS and UI.FS(s) or s end
    local function fits(s, t)
        for w in t:gmatch("[^%s]+") do
            if UI.MeasureWidth(w, px(s), UI.FONT) > NAME_W then return false end
        end
        return UI.Measure(t, px(s), NAME_W, 0, UI.FONT) <= px(s) * 2.7
    end
    local function set(s, t)
        fs:SetFont(UI.FONT, px(s), "")
        fs:SetText(t)
    end
    for s = 10, 8, -1 do
        if fits(s, text) then return set(s, text) end
    end
    local long, lw = nil, 0
    for w in text:gmatch("[^%s]+") do
        local ww = UI.MeasureWidth(w, px(8), UI.FONT)
        if ww > lw then long, lw = w, ww end
    end
    if not long then return set(8, text) end
    local a, b = long:match("^(.+%-)(.+)$")
    if not a then
        -- the syllable break after which both halves fit their line, the nearest the middle; failing that,
        -- the one that leaves the longer half shortest
        local best, bestD
        for _, pos in ipairs(syllableBreaks(long)) do
            local wa = UI.MeasureWidth(long:sub(1, pos - 1) .. "-", px(8), UI.FONT)
            local wb = UI.MeasureWidth(long:sub(pos), px(8), UI.FONT)
            local both = wa <= NAME_W and wb <= NAME_W
            local d = both and math.abs(pos - #long / 2) or (1000 + max(wa, wb))
            if not bestD or d < bestD then best, bestD = pos, d end
        end
        if best then a, b = long:sub(1, best - 1) .. "-", long:sub(best) end
    end
    if not a then
        local mid = math.floor(#long / 2)
        while mid > 1 and long:byte(mid + 1) and long:byte(mid + 1) >= 128 and long:byte(mid + 1) < 192 do mid = mid - 1 end
        a, b = long:sub(1, mid) .. "-", long:sub(mid + 1)
    end
    local i = text:find(long, 1, true)
    text = text:sub(1, i - 1) .. a .. "\n" .. b .. text:sub(i + #long)
    for s = 10, 8, -1 do
        if fits(s, text) or s == 8 then return set(s, text) end
    end
end

-- one trading card, built once per pool slot
local function newCard(parent)
    local f = UI.Frame(parent, CARD_W, CARD_H, "Button")
    f.shadow = f:CreateTexture(nil, "BACKGROUND", nil, -7)
    f.shadow:SetTexture(UI.WHITE)
    f.shadow:SetVertexColor(0, 0, 0, 0.35)
    f.shadow:SetPoint("TOPLEFT", 3, -4)
    f.shadow:SetPoint("BOTTOMRIGHT", 3, -4)
    f.bg = f:CreateTexture(nil, "BACKGROUND", nil, -6)
    f.bg:SetPoint("TOPLEFT", 3, -3)
    f.bg:SetPoint("BOTTOMRIGHT", -3, 3)
    f.edge = UI.Frame(f)
    f.edge:SetAllPoints()
    f.window = UI.Frame(f, CARD_W - 16, 78)
    f.window:SetPoint("TOP", 0, -18)
    UI.Backdrop(f.window, nil, 1, 0, { 0, 0, 0, 0.35 }, { 0, 0, 0, 0.8 })
    f.model = CreateFrame("PlayerModel", nil, f.window)
    f.model:SetPoint("TOPLEFT", 1, -1)
    f.model:SetPoint("BOTTOMRIGHT", -1, 1)
    f.num = UI.Text(f, 10, { 1, 0.92, 0.75, 1 }, "LEFT", UI.FONT, true)
    f.num:SetPoint("TOPLEFT", 7, -5)
    f.lvl = UI.Text(f, 10, { 1, 0.92, 0.75, 1 }, "RIGHT", UI.FONT, true)
    f.lvl:SetPoint("TOPRIGHT", -7, -5)
    f.plate = f:CreateTexture(nil, "ARTWORK", nil, 1)
    f.plate:SetTexture(UI.WHITE)
    f.plate:SetVertexColor(0.16, 0.12, 0.08, 1)
    f.plate:SetPoint("TOPLEFT", 6, -100)
    f.plate:SetPoint("BOTTOMRIGHT", -6, 6)
    f.name = UI.Text(f, 10, { 0.96, 0.90, 0.78, 1 }, "CENTER", UI.FONT)
    f.name:SetPoint("TOPLEFT", f.plate, "TOPLEFT", 3, -2)
    f.name:SetPoint("BOTTOMRIGHT", f.plate, "BOTTOMRIGHT", -3, 2)
    f.name:SetJustifyV("MIDDLE")
    if f.name.SetMaxLines then f.name:SetMaxLines(2) end
    -- how many were slain: a small badge inside the lower corner of the picture (across its edge it would
    -- cover the name plate and the word of a connoisseur's card)
    f.badge = UI.CountBadge(f, 20)
    f.badge:SetPoint("BOTTOMRIGHT", f.window, "BOTTOMRIGHT", -3, 3)
    f.badge:SetFrameLevel(f:GetFrameLevel() + 4)
    f.new = UI.Text(f, 10, { 1, 0.95, 0.6, 1 }, "CENTER", UI.HEAD, true)
    f.new:SetPoint("TOPRIGHT", f.window, "TOPRIGHT", -2, -2)
    -- the rarity: a word at the top and a diamond in each corner
    f.tag = UI.Text(f, 8, { 1, 1, 1, 1 }, "CENTER", UI.HEAD, true)
    f.tag:SetPoint("TOP", 0, -5)
    f.corners = {}
    for i, pt in ipairs({ { "TOPLEFT", 4, -4 }, { "TOPRIGHT", -4, -4 }, { "BOTTOMLEFT", 4, 4 }, { "BOTTOMRIGHT", -4, 4 } }) do
        local d = UI.Diamond(f, 9, { 1, 1, 1, 1 }, "OVERLAY", 2)
        d:SetPoint("CENTER", f, pt[1], pt[2], pt[3])
        f.corners[i] = d
    end
    -- a sketch until ten are slain: the picture lies under a wash of paper
    f.over = CreateFrame("Frame", nil, f.window)
    f.over:SetAllPoints()
    f.over:SetFrameLevel(f.model:GetFrameLevel() + 3)
    f.wash = f.over:CreateTexture(nil, "ARTWORK", nil, 0)
    f.wash:SetTexture(UI.WHITE)
    f.wash:SetPoint("TOPLEFT", 1, -1)
    f.wash:SetPoint("BOTTOMRIGHT", -1, 1)
    UI.Gradient(f.wash, "VERTICAL", { 0.62, 0.50, 0.32, 0.62 }, { 0.80, 0.68, 0.46, 0.50 })
    -- a connoisseur's card: gold rim and a word on the picture
    f.rim = UI.Frame(f.over)
    f.rim:SetPoint("TOPLEFT", -2, 2)
    f.rim:SetPoint("BOTTOMRIGHT", 2, -2)
    UI.Backdrop(f.rim, "tooltip", 8, 2, { 0, 0, 0, 0 }, { 1, 0.82, 0.30, 1 })
    f.master = UI.Text(f.over, 8, { 1, 0.86, 0.36, 1 }, "LEFT", UI.HEAD, true)
    f.master:SetPoint("TOP", 0, -4)         -- not at the foot: the count badge needs that corner
    -- this one has killed you
    f.skull = f.over:CreateTexture(nil, "OVERLAY")
    f.skull:SetTexture(SKULL)
    f.skull:SetSize(14, 14)
    f.skull:SetPoint("TOPLEFT", 3, -3)
    -- rare creatures and bosses are "shiny": light sweeps over the picture and stars twinkle
    f.shiny = UI.Shiny(f.window)
    -- the "new" mark and the count stay above the wash
    f.new:SetParent(f.over)
    f.badge:SetFrameLevel(f.over:GetFrameLevel() + 2)
    f.sil = UI.Text(f.window, 34, { 0.55, 0.45, 0.30, 0.55 }, "CENTER", UI.HEAD)
    f.sil:SetPoint("CENTER", 0, 0)
    f.sil:SetText("?")
    f.silNote = UI.Text(f.window, 9, { 0.85, 0.74, 0.52, 1 }, "CENTER", UI.FONT, true)
    f.silNote:SetPoint("TOP", 0, -5)
    f.silNote:SetText(L["No portrait"])
    f.silNote:Hide()
    f.q = UI.Text(f, 40, { 0.55, 0.45, 0.30, 0.6 }, "CENTER", UI.HEAD)
    f.q:SetPoint("CENTER", 0, 8)
    f.qsub = UI.Text(f, 10, { 0.88, 0.76, 0.54, 1 }, "CENTER", UI.FONT, true)
    f.qsub:SetPoint("BOTTOM", 0, 14)
    f.hl = f:CreateTexture(nil, "OVERLAY")
    f.hl:SetTexture(UI.WHITE)
    f.hl:SetVertexColor(1, 0.9, 0.6, 0.12)
    f.hl:SetAllPoints()
    f.hl:Hide()
    local function lift(self, up)
        if (self.lifted and true or false) == up or not self.AdjustPointsOffset then return end
        self.lifted = up or nil
        pcall(self.AdjustPointsOffset, self, 0, up and 3 or -3)
        self.shadow:SetVertexColor(0, 0, 0, up and 0.55 or 0.35)
    end
    f:SetScript("OnEnter", function(self)
        if not self.entry then
            local fill = self.spot
            if not fill then return end
            self.hl:Show()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L["Not yet discovered"], 1, 0.86, 0.5)
            GameTooltip:AddLine(format(L["You have been %s of this area least of all. Something may still be waiting there."],
                L[fill.dir]), 0.9, 0.9, 0.9, true)
            GameTooltip:AddLine(L["Click to set a marker on the map."], 0.5, 0.8, 1)
            GameTooltip:Show()
            return
        end
        self.hl:Show()
        if self.entry.hint then
            local h = self.entry.h
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if self.entry.sighted then
                GameTooltip:SetText(L["Sighted, not yet slain"], 1, 0.86, 0.5)
                if h.n then GameTooltip:AddLine(h.n, 1, 1, 1) end
            else
                GameTooltip:SetText(L["Not yet discovered"], 1, 0.86, 0.5)
            end
            local where = self.entry.zone
            local dir = WFD:Direction(h.x, h.y)
            if dir then where = where .. "  -  " .. L[dir] end
            GameTooltip:AddLine(where, 0.9, 0.9, 0.9, true)
            if h.lv then GameTooltip:AddLine(format(L["Level %s"], h.lv == -1 and "??" or tostring(h.lv)), 0.8, 0.8, 0.8) end
            local kind = (h.boss and L["Boss"]) or (h.rare and L["Rare"]) or ((h.cls == "elite" or h.cls == "rareelite") and L["Elite"])
            if kind then GameTooltip:AddLine(kind, 1, 0.75, 0.3) end
            if h.who then GameTooltip:AddLine(format(L["Known to %s"], h.who), 0.6, 0.75, 1) end
            if h.m and h.x then
                GameTooltip:AddLine(L["Click to set a marker on the map."], 0.5, 0.8, 1)
                GameTooltip:AddLine(L["Right-click for the map of this region."], 0.5, 0.8, 1)
            elseif h.m then
                GameTooltip:AddLine(L["Click for the map of this region."], 0.5, 0.8, 1)
            end
            GameTooltip:Show()
            return
        end
        local m = self.entry.m
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(m.name or "?", 1, 0.86, 0.5)
        local kind = m.ctype and (m.fam and (m.ctype .. "  -  " .. m.fam) or m.ctype)
        if kind then GameTooltip:AddLine(kind, 0.75, 0.75, 0.75) end
        GameTooltip:AddLine(WFD:Quote(WFD:MarginNote(self.entry.id, m)), 0.95, 0.85, 0.65, true)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(WFD:Count("Slain %d times", m.kills), 0.9, 0.9, 0.9)
        local stage = WFD:MobStage(m)
        if stage == 1 then
            GameTooltip:AddLine(format(L["A sketch: %d more and it is in colour."], WFD.STAGE_COLOUR - m.kills), 0.75, 0.65, 0.45, true)
        elseif stage == 2 then
            GameTooltip:AddLine(format(L["%d more to become a connoisseur."], WFD.STAGE_MASTER - m.kills), 0.75, 0.65, 0.45, true)
        else
            GameTooltip:AddLine(L["Connoisseur of this kind"], 1, 0.82, 0.3)
        end
        if m.first then
            local day = WFD:DayIndex(m.first)
            local line = format(L["First slain on day %d"], day)
            local where = m.fz or m.zone
            if where then line = line .. "  -  " .. where end
            if m.fpl then line = line .. "  -  " .. format(L["at level %d"], m.fpl) end
            GameTooltip:AddLine(line, 0.7, 0.7, 0.7, true)
        end
        if m.best then GameTooltip:AddLine(L["Best loot"] .. ": " .. m.best, 0.7, 0.7, 0.7) end
        local nem = WFD.C.nemesis[m.name or ""]
        if nem and nem.n > 0 then
            GameTooltip:AddLine(nem.n == 1 and L["Got you once."] or WFD:Count("Got you %d times.", nem.n), 1, 0.35, 0.25)
        end
        GameTooltip:AddLine(L["Click for the wanted poster."], 0.5, 0.8, 1)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function(self)
        self.hl:Hide()
        GameTooltip:Hide()
        lift(self, false)
    end)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    f:HookScript("OnEnter", function(self) lift(self, true) end)
    f:SetScript("OnClick", function(self, button)
        if not self.entry then
            local fill = self.spot
            if fill then WFD:SetMapMarker(fill.map, fill.x, fill.y, self.zone) end
            return
        end
        if self.entry.hint then
            local h = self.entry.h
            if h.m and h.x and button ~= "RightButton" then
                -- only a creature you saw yourself is named; the others stay a secret
                WFD:SetMapMarker(h.m, h.x, h.y, (self.entry.sighted and h.n) or self.entry.zone)
            elseif h.m then
                UI:ShowMapOf(h.m)
            end
            return
        end
        UI:ShowCard("creature", self.entry.id)
    end)

    function f:SetEntry(e, fill, zone)
        self.lifted = nil          -- the card was placed anew
        self.entry = e
        self.spot = (not e) and fill or false     -- false, not nil: the field must exist on the frame
        self.zone = zone
        local fillDir = self.spot and self.spot.dir
        if e and e.hint then
            -- a covered card: no name, no picture - only the level and where to look
            local h = e.h
            self.window:Hide()
            self.num:Hide()
            self.plate:Hide()
            self.name:Hide()
            self.badge:Hide()
            self.tag:SetText("")
            for _, d in ipairs(self.corners) do d:Hide() end
            self.shadow:Show()
            self.lvl:Show()
            self.lvl:SetText(h.lv and format(L["Lv %s"], h.lv == -1 and "??" or tostring(h.lv)) or "")
            self.q:Show()
            self.qsub:Show()
            local edge = (h.boss and { 0.75, 0.25, 0.15, 0.8 }) or (h.rare and { 0.45, 0.60, 0.95, 0.8 })
                or ((h.cls == "elite" or h.cls == "rareelite") and { 0.90, 0.70, 0.25, 0.8 }) or { 0.62, 0.48, 0.24, 0.7 }
            UI.Backdrop(self.edge, "tooltip", 12, 3, { 0, 0, 0, 0 }, edge)
            UI.Gradient(self.bg, "VERTICAL", { 0.06, 0.04, 0.03, 0.9 }, { 0.16, 0.11, 0.07, 0.9 })
            self.q:SetText("?")
            local dir = WFD:Direction(h.x, h.y)
            self.qsub:SetText(dir and L[dir] or "")
            UI.FitText(self.qsub, CARD_W - 12, 10, 8, UI.FONT)
            self.new:SetText("")
            self.model:ClearModel()
            self.modelId = nil
            self.silNote:Hide()
            return
        end
        local filled = e ~= nil
        self.window:SetShown(filled)
        self.num:SetShown(filled)
        self.lvl:SetShown(filled)
        self.plate:SetShown(filled)
        self.name:SetShown(filled)
        self.badge:SetShown(filled)
        self.q:SetShown(not filled)
        self.qsub:SetShown(not filled)
        self.shadow:SetShown(filled)
        if not filled then
            self.tag:SetText("")
            for _, d in ipairs(self.corners) do d:Hide() end
            UI.Backdrop(self.edge, "tooltip", 12, 3, { 0, 0, 0, 0 }, { 0.45, 0.32, 0.16, 0.45 })
            self.bg:SetTexture(UI.WHITE)
            self.bg:SetVertexColor(0.55, 0.42, 0.22, 0.10)
            self.q:SetText("?")
            self.qsub:SetText(fillDir and format(L["perhaps %s"], L[fillDir]) or L["not yet found"])
            UI.FitText(self.qsub, CARD_W - 12, 10, 8, UI.FONT)
            self.new:SetText("")
            self.model:ClearModel()
            self.modelId = nil
            self.silNote:Hide()
            return
        end
        local m = e.m
        local rk = rarityOf(m)
        local r = RARITY[rk]
        UI.Backdrop(self.edge, "tooltip", rk == "normal" and 12 or 14, 3, { 0, 0, 0, 0 }, r.border)
        UI.Gradient(self.bg, "VERTICAL", r.bg1, r.bg2)
        self.tag:SetText(RARITY_TAG[rk] and L[RARITY_TAG[rk]]:upper() or "")
        self.tag:SetTextColor(col4(r.border))
        for _, d in ipairs(self.corners) do
            d:SetShown(rk ~= "normal")
            d:SetVertexColor(col4(r.border))
        end
        local stage = WFD:MobStage(m)
        self.wash:SetShown(stage == 1)
        self.shiny:SetShiny(rk == "rare" or rk == "boss", r.border)
        self.rim:SetShown(stage == 3)
        self.master:SetText(stage == 3 and L["CONNOISSEUR"] or "")
        local nem = WFD.C.nemesis[m.name or ""]
        self.skull:SetShown(nem ~= nil and (nem.n or 0) > 0)
        self.num:SetText(format("#%03d", e.num))
        self.lvl:SetText(format(L["Lv %s"], levelText(m)))
        -- number left, rarity in the middle, level right: with large writing the number gives way to the rarity
        self.tag:SetFont(UI.HEAD, UI.FS(8), "")      -- a card is used again: back to the full size first
        self.tag:ClearAllPoints()
        self.tag:SetPoint("TOP", 0, -5)
        local half = self.tag:GetStringWidth() / 2
        if half > 0 then
            local mid = CARD_W / 2
            if 7 + self.num:GetStringWidth() + 3 > mid - half then self.num:SetText("") end
            if mid + half + 6 > CARD_W - 7 - self.lvl:GetStringWidth() then
                -- centred, the word would touch the level: it moves into the left corner, where the number was
                self.num:SetText("")
                self.tag:ClearAllPoints()
                self.tag:SetPoint("TOPLEFT", 7, -5)
                local room = CARD_W - 14 - self.lvl:GetStringWidth() - 6
                if half * 2 > room then UI.FitText(self.tag, room, 8, 6, UI.HEAD) end
            end
        end
        fitName(self.name, m.name or "?")
        self.badge:SetCount(UI.ShortCount(m.kills), UI.BADGE_COLOURS[rarityOf(m)] or UI.BADGE_COLOURS.normal)
        -- new since the bestiary was last looked at (shown once: the next look counts it as read)
        local isNew = UI.IsNew and UI.IsNew("bestiary", m.first)
        self.new:SetText(isNew and L["NEW"] or "")
        -- known only by its name (the game kept the ID secret in some dungeons): the picture of the same name elsewhere
        local mid = UI.ModelIdFor(e.id, m.name)
        if not mid then
            self.modelId = nil
            self.model.wantId = nil
            self.model:ClearModel()
            self.sil:SetTextColor(0.85, 0.72, 0.48, 0.9)
            self.sil:Show()
            self.silNote:Show()
        elseif self.modelId ~= mid then
            self.modelId = mid
            self.sil:SetTextColor(0.55, 0.45, 0.30, 0.55)
            self.silNote:Hide()
            UI.LoadCreature(self.model, mid, 0.65, self.sil)
        end
    end
    return f
end

-- the trading card is used by the album on the travel desk as well
UI.NewCreatureCard, UI.CREATURE_CARD_W, UI.CREATURE_CARD_H = newCard, CARD_W, CARD_H

local function kindsText(n) return n == 1 and L["1 kind"] or format(L["%d kinds"], n) end
UI.KindsText = kindsText

------------------------------------------------------------------------
-- most telling role first
local ROLE_ORDER = { "flight", "trainer", "bank", "auction", "stable", "merchant", "quest", "petition", "talk" }
local ROLE_ICONS = {
    flight = { "Ability_Mount_Gryphon_01", "Ability_Mount_Wyvern_01", "Spell_Nature_Swiftness" },
    trainer = { "INV_Misc_Book_11", "INV_Misc_Book_09" }, bank = { "INV_Misc_Coin_01" },
    auction = { "INV_Misc_Coin_02" }, stable = { "Ability_Hunter_BeastTaming" }, merchant = { "INV_Misc_Bag_10" },
    quest = { "INV_Scroll_03" }, petition = { "INV_Letter_15" }, talk = { "INV_Misc_Note_01" },
}
UI.ROLE_ORDER, UI.ROLE_ICONS = ROLE_ORDER, ROLE_ICONS      -- the person cards use them too

-- (the register of people is a view of the travel desk now: UI/Views/Registers.lua)

-- (the ledger is a view of the travel desk now: UI/Views/People.lua)

------------------------------------------------------------------------
-- Quest book: grouped by region, in the order the regions were reached
------------------------------------------------------------------------
-- (the quest book is a view of the travel desk now: UI/Views/Registers.lua)

-- (the settings are a view of the travel desk now: UI/Views/Settings.lua)
