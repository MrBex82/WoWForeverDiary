-- The moving window: copy the moving code of this character, or paste one from another computer.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local col4 = UI.col4
local format = string.format

local pop

local function build()
    local f = UI.Frame(UIParent, 540, 250)
    f:SetPoint("CENTER", 0, 80)
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    UI.Backdrop(f, "tooltip", 14, 4, { 0.08, 0.05, 0.03, 0.97 }, c.gold)
    _G.WoWForeverDiaryMoving = f
    tinsert(UISpecialFrames, "WoWForeverDiaryMoving")

    f.title = UI.Text(f, 18, c.gold, "LEFT", UI.HEAD, true)
    f.title:SetPoint("TOPLEFT", 18, -16)
    local ok, close = pcall(CreateFrame, "Button", nil, f, "UIPanelCloseButton")
    if ok and close then close:SetPoint("TOPRIGHT", -2, -2) end

    f.info = UI.Text(f, 12, { 0.96, 0.90, 0.76, 1 }, "LEFT", UI.FONT, true)
    f.info:SetPoint("TOPLEFT", 18, -44)
    f.info:SetWidth(504)
    f.info:SetJustifyV("TOP")

    -- one line: very long codes are quick to copy and paste that way
    local okE, e = pcall(CreateFrame, "EditBox", nil, f, "InputBoxTemplate")
    if not (okE and e) then
        e = CreateFrame("EditBox", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
        UI.Backdrop(e, nil, 1, 0, { 0, 0, 0, 0.6 }, c.goldDk)
        e:SetFontObject(ChatFontNormal)
    end
    e:SetSize(496, 24)
    e:SetPoint("TOPLEFT", 24, -120)
    e:SetAutoFocus(false)
    e:SetMaxLetters(0)
    e:SetScript("OnEscapePressed", function(s) s:ClearFocus(); f:Hide() end)
    f.edit = e

    f.status = UI.Text(f, 12, c.gold, "LEFT", UI.FONT, true)
    f.status:SetPoint("TOPLEFT", 18, -154)
    f.status:SetWidth(504)
    f.status:SetJustifyV("TOP")

    local okB, b = pcall(CreateFrame, "Button", nil, f, "UIPanelButtonTemplate")
    if not (okB and b) then b = UI.Button(f, "", 240, 26) end
    b:SetSize(260, 26)
    b:SetPoint("BOTTOMRIGHT", -18, 16)
    f.button = b
    return f
end

local function open(mode)
    pop = pop or build()
    pop.mode = mode
    pop.data = nil
    pop.edit:SetScript("OnTextChanged", nil)
    pop.edit:SetScript("OnEditFocusGained", nil)
    pop.button:SetScript("OnClick", nil)
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
        f.status:SetTextColor(1, 0.4, 0.3, 1)
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
    f.status:SetTextColor(col4(c.gold))
    f.button:Show()
    f.button:SetText(L["Select all"])
    f.button:Enable()
    f.button:SetScript("OnClick", function() f.edit:SetFocus(); f.edit:HighlightText() end)
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
    f.status:SetTextColor(0.75, 0.65, 0.48, 1)
    f.button:Show()
    f.button:SetText(L["Replace the diary and reload"])
    f.button:Disable()
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
                f.status:SetTextColor(0.75, 0.65, 0.48, 1)
                return
            end
            local data, why = WFD:ReadMovingCode(text)
            if not data then
                f.status:SetText(why == "format" and L["This is not a moving code of the diary."]
                    or L["The code is damaged or incomplete. Copy it again, all of it."])
                f.status:SetTextColor(1, 0.4, 0.3, 1)
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
            f.status:SetTextColor(col4(c.gold))
            f.data = data
            f.button:Enable()
        end)
    end)
    f.button:SetScript("OnClick", function()
        if not f.data then return end
        if WFD.demo then
            print("|cffffd100WoW Forever Diary:|r " .. L["Leave demo mode first."])
            return
        end
        WFD:ApplyMovingCode(f.data)
        ReloadUI()
    end)
end
