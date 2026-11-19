-- Reloading the interface. Some game clients refuse ReloadUI() from an addon, even from a click. A secure button
-- of the game that runs "/reload" like a macro is always allowed: it lies over the button of a small dialog.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local floor = math.floor

local dlg

local function build()
    local k = math.max(1, UI.FONT_SCALE or 1)
    local d = CreateFrame("Frame", "WoWForeverDiaryReload", UIParent)
    d:SetFrameStrata("DIALOG")
    d:SetToplevel(true)
    d:EnableMouse(true)
    d:SetPoint("CENTER", 0, 120)
    local bg = d:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.06, 0.04, 0.96)
    local edge = d:CreateTexture(nil, "BORDER")
    edge:SetPoint("TOPLEFT", -1, 1)
    edge:SetPoint("BOTTOMRIGHT", 1, -1)
    edge:SetColorTexture(0.78, 0.60, 0.26, 0.8)
    edge:SetDrawLayer("BACKGROUND", -1)
    d.title = d:CreateFontString(nil, "ARTWORK")
    d.title:SetFont(UI.HEAD or STANDARD_TEXT_FONT, UI.FS(18), "")
    d.title:SetTextColor(1, 0.82, 0.30)
    d.title:SetPoint("TOP", 0, -16)
    d.text = d:CreateFontString(nil, "ARTWORK")
    d.text:SetFont(UI.FONT or STANDARD_TEXT_FONT, UI.FS(13), "")
    d.text:SetTextColor(0.95, 0.90, 0.80)
    d.text:SetWidth(floor(340 * k))
    d.text:SetJustifyH("CENTER")
    d.text:SetPoint("TOP", d.title, "BOTTOM", 0, -12)
    local bw, bh = floor(140 * k), floor(26 * k)
    d.ok = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
    d.ok:SetSize(bw, bh)
    d.ok:SetPoint("BOTTOMRIGHT", d, "BOTTOM", -6, 14)
    d.cancel = CreateFrame("Button", nil, d, "UIPanelButtonTemplate")
    d.cancel:SetSize(bw, bh)
    d.cancel:SetPoint("BOTTOMLEFT", d, "BOTTOM", 6, 14)
    d.cancel:SetText(L["Later"])
    d.cancel:SetScript("OnClick", function() d:Hide() end)
    for _, b in ipairs({ d.ok, d.cancel }) do
        local fs = b:GetFontString()
        if fs then fs:SetFont(UI.FONT or STANDARD_TEXT_FONT, UI.FS(12), "") end
    end
    -- the secure button over OK; without it (a client that has none) OK tries ReloadUI() and says to type /reload
    local ok, sb = pcall(CreateFrame, "Button", nil, d, "SecureActionButtonTemplate")
    if ok and sb then
        sb:SetAttribute("type", "macro")
        sb:SetAttribute("macrotext", "/reload")
        sb:RegisterForClicks("AnyUp", "AnyDown")
        sb:SetAllPoints(d.ok)
        sb:SetFrameLevel(d.ok:GetFrameLevel() + 5)
        sb:SetScript("OnEnter", function() d.ok:LockHighlight() end)
        sb:SetScript("OnLeave", function() d.ok:UnlockHighlight() end)
    else
        d.ok:SetScript("OnClick", function()
            print("|cffffd100WoW Forever Diary:|r " .. L["Type /reload to finish."])
            pcall(ReloadUI)
        end)
    end
    tinsert(UISpecialFrames, "WoWForeverDiaryReload")
    d:Hide()
    return d
end

-- text: why; the dialog offers to reload now or later (then the change waits for the next /reload or login)
function UI:AskReload(text)
    if InCombatLockdown and InCombatLockdown() then
        print("|cffffd100WoW Forever Diary:|r " .. (text or "") .. " " .. L["Type /reload to finish."])
        return
    end
    dlg = dlg or build()
    local k = math.max(1, UI.FONT_SCALE or 1)
    dlg.title:SetText(L["Reload the interface"])
    dlg.text:SetText(text or "")
    dlg.ok:SetText(L["Reload now"])
    dlg:SetSize(floor(380 * k), floor(16 + dlg.title:GetStringHeight() + 12 + dlg.text:GetStringHeight() + 20 + 26 * k + 14))
    dlg:Show()
end

function WFD:Reload(text)
    UI:AskReload(text or L["The change takes effect after the interface is reloaded."])
end
