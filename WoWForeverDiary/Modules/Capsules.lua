-- Time capsules: letters to yourself that stay sealed until a certain day or level comes.
local ADDON, WFD = ...
local L = WFD.L

-- kind "days": opens value days from now; kind "level": opens on reaching that level
function WFD:SealLetter(text, kind, value)
    local C = self.C
    if not C or self.demo or not text or not text:find("%S") then return end
    C.capsules = C.capsules or {}
    local letter = { t = time(), day = self:DayIndex(), level = UnitLevel("player"), text = text }
    if kind == "level" then letter.openLevel = value else letter.openDay = self:DayIndex() + value end
    C.capsules[#C.capsules + 1] = letter
    C.capsuleDraft = nil
    self:Log("capsule", L["A letter for later was sealed."])
    self.dirty = true
    return letter
end

function WFD:LetterReady(letter)
    if letter.opened then return true end
    if letter.openDay then return self:DayIndex() >= letter.openDay end
    if letter.openLevel then return (UnitLevel("player") or 0) >= letter.openLevel end
    return false
end

local function check()
    local C = WFD.C
    if not C or not C.capsules or WFD.paused or WFD.demo then return end
    for i, letter in ipairs(C.capsules) do
        if not letter.opened and WFD:LetterReady(letter) then
            letter.opened = time()
            WFD:Milestone("capsule", L["A letter from the past has opened."], false, { capsule = i })
        end
    end
end

WFD:OnInit(function()
    if C_Timer and C_Timer.NewTicker then
        C_Timer.After(5, function() pcall(check) end)
        C_Timer.NewTicker(20, function()
            local ok, err = pcall(check)
            if not ok then WFD:Error("capsules", err) end
        end)
    end
end)
