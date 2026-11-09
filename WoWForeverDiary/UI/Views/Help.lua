-- Help: every key, every click and every command in one place, behind the "?" of the head bar.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local K = UI.Kit
local max, min = math.max, math.min

-- { what to press, what it does } (looked up when shown: the language is known only after loading)
local function sections()
    return {
        { L["Keys while the mouse is over the window"], {
            { L["Arrow keys, Page up / down"], L["turn the page"] },
            { L["Backspace"], L["back"] },
            { L["Home"], L["Start"] },
            { L["End"], L["today's entry"] },
            { L["Ctrl + F"], L["search the book"] },
            { L["Escape"], L["closes what lies on top, then the window"] },
        } },
        { L["Mouse"], {
            { L["Mouse wheel on the book"], L["turn the page"] },
            { L["Ctrl + mouse wheel"], L["size of the window"] },
            { L["Corner at the bottom right"], L["drag to change the size of the window"] },
            { L["Head bar"], L["drag to move the window"] },
            { L["Click the folded corner"], L["bookmark"] },
            { L["Right-click a bookmark in the register"], L["removes it"] },
        } },
        { L["Commands"], {
            { "/wfd", L["open or close the diary"] },
            { "/wfd bestiary", L["open a part: today, bestiary, honour, ledger, atlas, settings ... or a day number"] },
            { "/wfd demo", L["explore with invented data"] },
            { "/wfd companion", L["show or hide the companion"] },
            { "/wfd memory", L["show today's memory again"] },
            { "/wfd export", L["moving code of this character"] },
            { "/wfd import", L["read a moving code"] },
            { "/wfd help", L["list the commands in the chat"] },
        } },
    }
end

UI:RegisterView({
    key = "help",
    build = function(host)
        local v = {}
        local scroll = K.Scroll(host)
        scroll:SetAllPoints(host)
        local area = scroll.content
        local title = K.Text(area, "display", "title")
        title:SetText(L["Help"])
        local blocks = {}

        local function build()
            for _, sec in ipairs(sections()) do
                local b = { head = K.SectionHead(area, sec[1]), rows = {} }
                for _, r in ipairs(sec[2]) do
                    local key = K.Text(area, "strong", "title")
                    key:SetText(r[1])
                    local what = K.Text(area, "body", "ink")
                    what:SetText(r[2])
                    b.rows[#b.rows + 1] = { key, what }
                end
                blocks[#blocks + 1] = b
            end
        end

        function v:Arrange()
            local w = min(760, (self.w or scroll:GetWidth() or 0) - 56)
            if w <= 0 then return end
            title:ClearAllPoints()
            title:SetPoint("TOPLEFT", area, "TOPLEFT", 28, -22)
            local y = 22 + title:GetStringHeight() + 20
            local kw = min(280, w * 0.42)
            for _, b in ipairs(blocks) do
                b.head:SetWidth(w)
                b.head:ClearAllPoints()
                b.head:SetPoint("TOPLEFT", area, "TOPLEFT", 28, -y)
                y = y + 28
                for _, r in ipairs(b.rows) do
                    r[1]:SetWidth(kw - 12)
                    r[2]:SetWidth(w - kw)
                    r[1]:ClearAllPoints()
                    r[1]:SetPoint("TOPLEFT", area, "TOPLEFT", 28, -y)
                    r[2]:ClearAllPoints()
                    r[2]:SetPoint("TOPLEFT", area, "TOPLEFT", 28 + kw, -y)
                    y = y + max(r[1]:GetStringHeight(), r[2]:GetStringHeight()) + 10
                end
                y = y + 16
            end
            scroll:SetContentHeight(y)
        end

        function v:Show()
            if #blocks == 0 then build() end
            scroll:ScrollTo(0)
            self:Arrange()
        end
        function v:Layout(w, h) self.w = w self:Arrange() end
        scroll.onResize = function(sf) v.w = sf:GetWidth() v:Arrange() end
        UI.OnRestyle(function() if host:IsShown() then v:Arrange() end end)
        function v:Head() return L["Help"] end
        return v
    end,
})
