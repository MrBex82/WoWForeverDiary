-- The moving window: copy the moving code of this character, or paste one from another computer.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local format, max = string.format, math.max

local pop

local K = UI.Kit

local function build()
    local f = K.Floating("Moving", 560, 270, "")
    f:Place(0, 80)
    f.info = K.Text(f.body, "body", "rail")
    f.info:SetPoint("TOPLEFT", 0, 0)
    f.info:SetWidth(528)
    f.info:SetJustifyV("TOP")
    f.info:SetSpacing(2)

    -- one line: very long codes are quick to copy and paste that way
    local e = K.Edit(f.body, 528)
    e:SetMaxLetters(0)
    e:SetScript("OnEscapePressed", function(s) s:ClearFocus(); f:Hide() end)
    f.edit = e

    f.status = K.Text(f.body, "small", "railGold")
    f.status:SetWidth(528)
    f.status:SetJustifyV("TOP")
    f.status:SetSpacing(2)

    f.button = K.Button(f.body, "", "primary")
    f.button:SetPoint("BOTTOMRIGHT", 0, 0)
    function f:Arrange()
        local y = self.info:GetStringHeight() + 12
        self.edit:ClearAllPoints()
        self.edit:SetPoint("TOPLEFT", self.body, "TOPLEFT", 0, -y)
        self.status:ClearAllPoints()
        self.status:SetPoint("TOPLEFT", self.edit, "BOTTOMLEFT", 0, -10)
        self:SetHeight(54 + y + 30 + 10 + max(36, self.status:GetStringHeight()) + 14 + self.button:GetHeight() + 14)
    end
    return f
end

local function open(mode)
    pop = pop or build()
    pop.mode = mode
    pop.data = nil
    pop.edit:SetScript("OnTextChanged", nil)
    pop.edit:SetScript("OnEditFocusGained", nil)
    pop.button.onClick = nil
    pop:Show()
    return pop
end

------------------------------------------------------------------------
-- Copy the code of this character
------------------------------------------------------------------------
function UI:ShowMovingExport()
    local f = open("export")
    f.title:SetText(L["Moving code"])
    f.info:SetText(L["This code holds the whole diary of this character. Copy it with Ctrl+C and keep it somewhere safe, for example in a text file. On the other computer, open the same window with \"Read a moving code\" and paste it there."])
    local ok, code = pcall(WFD.MovingCode, WFD)
    if not ok or not code then
        f.edit:SetText("")
        f.status:SetText(L["The code could not be made."] .. (ok and "" or (" " .. tostring(code))))
        K.Recolor(f.status, "neg")
        f.button:Hide()
        return
    end
    f.code = code
    f.edit:SetText(code)
    -- the code stays as it is, whatever is typed
    f.edit:SetScript("OnTextChanged", function(s, user) if user then s:SetText(f.code); s:HighlightText() end end)
    f.edit:SetScript("OnEditFocusGained", function(s) s:HighlightText() end)
    f.edit:SetFocus()
    f.edit:HighlightText()
    f.status:SetText(format(L["%d days, %d characters. Now press Ctrl+C."], WFD:NumDays(), #code))
    K.Recolor(f.status, "railGold")
    f.button:Show()
    f.button:SetLabel(L["Select all"])
    f.button:Enable()
    f.button.onClick = function() f.edit:SetFocus(); f.edit:HighlightText() end
    f:Arrange()
end

------------------------------------------------------------------------
-- Paste a code from another computer
------------------------------------------------------------------------
local function count(t) local n = 0 for _ in pairs(t or {}) do n = n + 1 end return n end

function UI:ShowMovingImport()
    local f = open("import")
    f.title:SetText(L["Read a moving code"])
    f.info:SetText(L["Paste the moving code of this character with Ctrl+V. The diary written on this computer is then replaced by the one from the code, and the interface is reloaded."])
    f.edit:SetText("")
    f.edit:SetFocus()
    f.status:SetText(L["Waiting for a code ..."])
    K.Recolor(f.status, "railSoft")
    f.button:Show()
    f.button:SetLabel(L["Replace the diary and reload"])
    f.button:Disable()
    f:Arrange()
    local pending = 0
    f.edit:SetScript("OnTextChanged", function(s)
        pending = pending + 1
        local mine = pending
        -- a long paste arrives in one go; read it once it has settled
        C_Timer.After(0.2, function()
            if mine ~= pending or f.mode ~= "import" then return end
            local text = s:GetText() or ""
            f.data = nil
            f.button:Disable()
            if text:gsub("%s", "") == "" then
                f.status:SetText(L["Waiting for a code ..."])
                K.Recolor(f.status, "railSoft")
                return
            end
            local data, why = WFD:ReadMovingCode(text)
            if not data then
                f.status:SetText(why == "format" and L["This is not a moving code of the diary."]
                    or L["The code is damaged or incomplete. Copy it again, all of it."])
                K.Recolor(f.status, "neg")
                return
            end
            local ch = data.char
            local days = 0
            for _ in pairs(ch.days or {}) do days = days + 1 end
            local lines = {
                format(L["Diary of %s (%s), %d days, %d kinds of creatures, %d people."],
                    ch.name or "?", ch.class or "?", days, count(ch.mobs), count(ch.npcs)),
            }
            local me = UnitName("player")
            if ch.name and me and ch.name ~= me then
                lines[#lines + 1] = "|cffff6650" .. format(L["Careful: this code belongs to %s, but you are playing %s."], ch.name, me) .. "|r"
            end
            lines[#lines + 1] = "|cffff6650" .. L["The diary of this character on this computer will be replaced."] .. "|r"
            f.status:SetText(table.concat(lines, "\n"))
            K.Recolor(f.status, "railGold")
            f.data = data
            f.button:Enable()
            f:Arrange()
        end)
    end)
    -- asked once more before anything is replaced; the button of the question reloads
    f.button.onClick = function()
        if not f.data then return end
        if WFD.demo then
            print("|cffffd100WoW Forever Diary:|r " .. L["Leave demo mode first."])
            return
        end
        local data = f.data
        UI:Confirm({
            title = L["Read a moving code"], danger = true, reload = true,
            text = L["The diary of this character on this computer will be replaced."], ok = L["Replace the diary and reload"],
            onOk = function()
                WFD:ApplyMovingCode(data)
                f:Hide()
            end,
        })
    end
end
