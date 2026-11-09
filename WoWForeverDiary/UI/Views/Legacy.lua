-- The book on the desk: the parts that have no view of their own yet are read in the book as before, laid open in
-- the middle of the desk and scaled to fit it. Its own tabs, close button, ribbon and buttons on the spine stay
-- hidden: the register and the head bar of the desk do their work.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local floor, max, min, ceil = math.floor, math.max, math.min, math.ceil

local BW, BH = UI.PW * 2 + 22 + 36, UI.PH + 36      -- the open book with its binding (see Book.lua)
local MARGIN = 18

local function hideOwnParts()
    for _, t in ipairs(UI.thumbs or {}) do
        t:Hide()
        if t.plate then t.plate:Hide() end
    end
    for _, f in ipairs({ UI.bookClose, UI.ribbon, UI.searchButton, UI.helpButton, UI.backBtn }) do
        if f then f:Hide() end
    end
    if UI.searchPanel then UI.searchPanel:Hide() end
end

UI:RegisterView({
    key = "legacy",
    build = function(host)
        local v = { scale = nil }
        -- a new style or size of the writing: the open pages are laid out and drawn again
        UI.OnRestyle(function()
            if UI.bookFrame:IsShown() then UI:Reflow() end
        end)

        function v:Fit(w, h)
            local bf = UI.bookFrame
            local k = min((w - 2 * MARGIN) / BW, (h - 2 * MARGIN) / BH)
            k = max(0.5, min(1.3, k))
            bf:ClearAllPoints()
            bf:SetPoint("CENTER", host, "CENTER", 0, 0)
            bf:SetScale(k)
            self.k = k
        end

        function v:Layout(w, h)
            if w > 0 and h > 0 then self:Fit(w, h) end
        end

        -- after the window was resized: text is measured again at the size it is drawn at
        function v:Settled()
            if not UI.bookFrame:IsShown() then return end
            if self.measuredAt and math.abs(self.measuredAt - (self.k or 1)) < 0.01 then return end
            self.measuredAt = self.k
            UI.MeasureAt(UI.bookFrame)
            UI:Reflow()
        end

        function v:Show(route)
            local bf = UI.bookFrame
            bf:SetParent(host)
            bf:SetFrameLevel(host:GetFrameLevel() + 2)
            self:Fit(host:GetWidth() or 0, host:GetHeight() or 0)
            local first = not bf:IsShown()
            bf:Show()
            hideOwnParts()
            -- laid out again when the book comes onto the desk: while it lay aside, Start may have laid it out
            -- with text measured outside the book
            if first or WFD.dirty then
                WFD.dirty = false
                self.measuredAt = self.k
                UI.MeasureAt(bf)
                UI.storyCache[WFD:NumDays()] = nil
                UI:Paginate()
            end
            local page = route.page
            if type(page) == "function" then page = page(UI.book) end
            if first then UI.spreadShownOnce = false end
            if page then
                UI:ShowSpread(ceil(page / 2))
                UI:PointAt(page % 2 == 1 and "left" or "right")
            elseif first or (UI.spread or 0) < 1 then
                UI:ShowSpread(ceil(UI:TodayPage() / 2))
            else
                UI:ShowSpread(UI.spread)
            end
            route.page = UI.spread * 2 - 1     -- the way back returns to this very spread
            UI:UpdateMarks()
        end

        function v:Hide()
            -- a wanted poster or a card lies over the book: it goes with it
            if UI.card then UI.card:Hide() end
            UI.bookFrame:Hide()
            -- the book is put aside: text for its layout is measured in the window again
            UI.MeasureAt(UI.holder)
        end

        -- the head bar: the group (a link to its overview) and the part, or the chapter of the diary
        function v:Head()
            local s = UI.spread or 1
            local page = UI.book and UI.book.pages[s * 2 - 1]
            local key = page and page.section
            local gkey = key and UI.NAV_OF_PART[key]
            local g = gkey and UI.NAV_GROUP[gkey]
            local title = key and UI.PartLabel(key) or L["Diary"]
            if key == "diary" then title = L["Diary"] end
            if key == "toc" then title = L["Contents"] end
            local sec = key and UI.SectionOf(key)
            if sec and sec.index then title = L["Overview"] end
            local head = page and page.head
            if head and head ~= "" and L[head]:lower() ~= title:lower() then
                -- in the diary the group already says "Diary": the chapter alone
                title = (key == "diary") and L[head] or (title .. "  -  " .. L[head])
            end
            if g and g.key ~= "start" then return title, L[g.label], UI.GroupRoute(g) end
            return title
        end

        return v
    end,
})
