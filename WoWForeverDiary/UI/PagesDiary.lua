-- The chapters of the diary, and writing your own thoughts into a day.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, format, concat = math.floor, math.max, string.format, table.concat

local NOTE_W = 66                    -- margin column for notes
local FONT_SIZE, SPACING = 13, 3
local H_CHAPTER, H_DAY, H_FLOURISH, GAP = 196, 58, 30, 8
local CAP_SIZE, CAP_LINES = 40, 2    -- illuminated initial at the start of every day
local ITEM_SLOT, MOMENT_H = 80, 34  -- width of a taped item card, height of a moment card (with its gap)

local function textColW() return UI.TextW() - NOTE_W end

------------------------------------------------------------------------
-- Chapters
------------------------------------------------------------------------
local ROMAN = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV",
    "XVI", "XVII", "XVIII", "XIX", "XX" }
local function roman(n) return ROMAN[n] or tostring(n) end

local TITLES = {
    { s = "Arrival in %s", case = "in" }, { s = "The roads of %s", case = "in" }, { s = "Under the skies of %s", case = "over" },
    { s = "Shadows over %s", case = "over" }, { s = "Days in %s", case = "in" },
}

function UI.Chapters()
    local C = WFD.C
    local list, cur = {}, nil
    for day = 1, WFD:NumDays() do
        local d = C.days[day]
        if d then
            local zone = WFD:MainZone(d) or (cur and cur.zone) or C.startZone or "?"
            if not cur or zone ~= cur.zone then
                cur = { zone = zone, days = {} }
                list[#list + 1] = cur
            end
            cur.days[#cur.days + 1] = day
        end
    end
    local seen = {}
    for i, ch in ipairs(list) do
        ch.roman = roman(i)
        if i == 1 then
            ch.title = format(L["Awakening in %s"], WFD:Place(ch.zone, "in"))
        elseif seen[ch.zone] then
            ch.title = format(L["Return to %s"], WFD:Place(ch.zone, "to"))
        else
            local tpl = TITLES[((i - 2) % #TITLES) + 1]
            ch.title = format(L[tpl.s], WFD:Place(ch.zone, tpl.case))
        end
        seen[ch.zone] = true
        local d1, d2 = ch.days[1], ch.days[#ch.days]
        local l1 = WFD:LevelAt(WFD:DayTime(d1) - 43200)
        local l2 = WFD:LevelAt(WFD:DayTime(d2) + 43200)
        local lv = (l1 == l2) and format(L["Level %d"], l1) or format(L["Level %d-%d"], l1, l2)
        local dy = (d1 == d2) and format(L["Day %d"], d1) or format(L["Days %d-%d"], d1, d2)
        ch.sub = lv .. "   |   " .. dy
    end
    return list
end

-- (the days are read on the travel desk now: UI/Views/Diary.lua)

------------------------------------------------------------------------
-- Writing your own thoughts into a day
------------------------------------------------------------------------
function UI:EditDayNote(day)
    local pop = self.dayNotePop
    if not pop then
        pop = UI.Frame(UIParent, 440, 300)
        pop:SetPoint("CENTER")
        pop:SetFrameStrata("DIALOG")
        pop:EnableMouse(true)
        pop:SetMovable(true)
        pop:RegisterForDrag("LeftButton")
        pop:SetScript("OnDragStart", pop.StartMoving)
        pop:SetScript("OnDragStop", pop.StopMovingOrSizing)
        UI.Backdrop(pop, "dialog", 32, 11, c.paper, { 1, 0.92, 0.80, 1 })
        _G.WoWForeverDiaryDayNote = pop
        tinsert(UISpecialFrames, "WoWForeverDiaryDayNote")
        pop.title = UI.Text(pop, 20, c.ink, "CENTER", UI.HEAD)
        pop.title:SetPoint("TOP", 0, -24)
        pop.sub = UI.Caps(pop, L["My own thoughts:"], 9, c.redInk)
        pop.sub:SetJustifyH("CENTER")
        pop.sub:SetPoint("TOP", 0, -52)
        local inset = UI.Inset(pop, 396, 170)
        inset:SetPoint("TOP", 0, -70)
        local sf = CreateFrame("ScrollFrame", nil, inset)
        sf:SetPoint("TOPLEFT", 10, -10)
        sf:SetPoint("BOTTOMRIGHT", -10, 10)
        local eb = CreateFrame("EditBox", nil, sf)
        eb:SetMultiLine(true)
        eb:SetAutoFocus(false)
        eb:SetMaxLetters(2000)
        eb:SetFont(UI.FONT, 13, "")
        eb:SetTextColor(unpack(UI.NoteInk()))
        eb:SetShadowOffset(0, 0)
        eb:SetWidth(372)
        sf:SetScrollChild(eb)
        eb:SetScript("OnEscapePressed", function() pop:Hide() end)
        local hot = CreateFrame("Button", nil, inset)
        hot:SetAllPoints()
        hot:SetScript("OnClick", function() eb:SetFocus() end)
        sf:SetFrameLevel(hot:GetFrameLevel() + 1)
        pop.edit = eb
        local save = UI.InkButton(pop, L["Save"], function()
            local C = WFD.C
            C.dayNotes = C.dayNotes or {}
            local text = pop.edit:GetText() or ""
            C.dayNotes[pop.day] = text:find("%S") and text or nil
            pop:Hide()
            UI:Reflow()
            local v = UI.ViewInstance and UI.ViewInstance("diary")
            if v and v.host:IsShown() then v:Refresh() end
        end, 16, c.redInk)
        save:SetPoint("BOTTOMRIGHT", -40, 24)
        local cancel = UI.InkButton(pop, L["Cancel"], function() pop:Hide() end, 16, c.inkSoft)
        cancel:SetPoint("BOTTOMLEFT", 40, 24)
        self.dayNotePop = pop
    end
    pop.day = day
    pop.title:SetText(WFD:LongDate(day))
    pop.edit:SetText(WFD.C.dayNotes and WFD.C.dayNotes[day] or "")
    pop:Show()
    pop.edit:SetFocus()
end
