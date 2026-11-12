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
    local C = WFD.C
    UI:Ask({
        title = WFD:LongDate(day), text = L["My own thoughts:"], ok = L["Save"],
        input = { value = C.dayNotes and C.dayNotes[day] or "", lines = 8, max = 2000 },
        onOk = function(text)
            C.dayNotes = C.dayNotes or {}
            C.dayNotes[day] = (text and text:find("%S")) and text or nil
            UI:Reflow()
        end,
    })
end
