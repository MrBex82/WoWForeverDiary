-- Comfort on the travel desk: the notifications, the own bookmarks, the keys, the size and place of the window,
-- and what is new since the diary was last read.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

------------------------------------------------------------------------
-- Notifications: everything, only what matters, or nothing
------------------------------------------------------------------------
local IMPORTANT = {
    level = true, boss = true, rare = true, epic = true, rareitem = true, death = true, dungeon = true,
    capsule = true, honour = true, weekly = true,
}
function WFD:ShouldNotify(kind)
    local level = self.S and self.S.notify or "all"
    if level == "quiet" then return false end
    if level == "important" then return IMPORTANT[kind] == true end
    return true
end

------------------------------------------------------------------------
-- Own bookmarks: a day of the diary ({ day = n }) or a place on the desk ({ route = { ... } }). Marks of the old
-- book ({ section = key, offset = n }) lead to their part. The register lists them under its groups.
------------------------------------------------------------------------
local MARK_COLS = {
    { 0.18, 0.40, 0.62 }, { 0.22, 0.48, 0.24 }, { 0.66, 0.48, 0.12 }, { 0.44, 0.20, 0.56 }, { 0.10, 0.46, 0.46 }, { 0.62, 0.26, 0.10 },
}

-- the name of a bookmark, written when it is read so that it follows the language: "Diary, day 9"
local function markTitle(mk)
    if mk.day then return L["Diary"] .. ", " .. format(L["Day %d"], mk.day) end
    local key = mk.section or (mk.route and mk.route.view)
    local part = key and UI.PartLabel and UI.PartLabel(key) or L["Bookmark"]
    if mk.label then return part .. ", " .. mk.label end
    return part
end

-- the bookmarks with their names and the way to their place
function UI.MarkList()
    local out = {}
    for i, m in ipairs(WFD.C and WFD.C.marks or {}) do
        out[#out + 1] = { i = i, title = markTitle(m), col = MARK_COLS[((i - 1) % #MARK_COLS) + 1],
            go = function()
                if m.day then UI:OpenShell({ view = "diary", day = m.day }) return end
                if m.route then UI:OpenShell(m.route) return end
                UI:OpenShell(m.section and UI.PartRoute(m.section) or { view = "start" })
            end }
    end
    return out
end

function UI.RemoveMark(i)
    if WFD.C and WFD.C.marks then table.remove(WFD.C.marks, i) end
    if UI.OnMarksChanged then UI:OnMarksChanged() end
end

------------------------------------------------------------------------
-- Keys, while the mouse is over the window (so walking and fighting stay untouched)
------------------------------------------------------------------------
-- a view that can be leafed through (the diary) turns its days
local function flip(dir)
    return function()
        local cur = UI.Router and UI.Router.cur
        local v = cur and UI.ViewInstance and UI.ViewInstance(cur.view)
        if v and v.Turn and v.host and v.host:IsShown() then v:Turn(dir) end
    end
end
local KEYS = {
    LEFT = flip(-1), PAGEUP = flip(-1), RIGHT = flip(1), PAGEDOWN = flip(1),
    HOME = function() UI:OpenStart() end,
    END = function() UI:OpenShell({ view = "diary", day = WFD:NumDays() }) end,
    BACKSPACE = function() if UI.ShellBack then UI:ShellBack() end end,
    ["CTRL-F"] = function() if UI.FocusSearch then UI:FocusSearch() end end,
}
local function propagate(frame, v)
    if frame.SetPropagateKeyboardInput and not (InCombatLockdown and InCombatLockdown()) then
        pcall(frame.SetPropagateKeyboardInput, frame, v)
    end
end
-- Escape closes what lies on top first (a question, a list, the search, a card); the window only after that
local function closeLayer()
    if UI.Kit and (UI.Kit.CloseDialog() or UI.Kit.CloseMenu()) then return true end
    if UI.ShellCloseLayer and UI:ShellCloseLayer() then return true end
    if UI.replayBox and UI.replayBox:IsReplaying() then UI.replayBox:StopReplay() return true end
    if UI.card and UI.card:IsShown() and not UI.card.docked then UI.card:Hide() return true end
    return false
end

local function setupKeys(holder)
    if not holder.EnableKeyboard then return end
    holder:EnableKeyboard(true)
    propagate(holder, true)
    holder:SetScript("OnKeyDown", function(self, key)
        local fn = (IsControlKeyDown() and KEYS["CTRL-" .. key]) or KEYS[key]
        local typing = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
        if key == "ESCAPE" then
            if not typing and not (InCombatLockdown and InCombatLockdown()) and closeLayer() then
                propagate(self, false)
                C_Timer.After(0, function() propagate(self, true) end)
            else
                propagate(self, true)
            end
            return
        end
        if fn and not typing and UI.inShell and self:IsMouseOver() and not (InCombatLockdown and InCombatLockdown()) then
            propagate(self, false)
            fn()
            -- hand the keyboard straight back to the game
            C_Timer.After(0, function() propagate(self, true) end)
        else
            propagate(self, true)
        end
    end)
end

------------------------------------------------------------------------
-- Size (Ctrl + mouse wheel) and place of the window
------------------------------------------------------------------------
local sizeLabel, relayout
function UI:StepScale(delta)
    local S = WFD.S
    local s = floor(((S.scale or 0.9) + (delta > 0 and 0.05 or -0.05)) * 100 + 0.5) / 100
    s = max(0.6, min(1.4, s))
    S.scale = s
    self.holder:SetScale(s)
    if not sizeLabel then
        sizeLabel = UI.Text(self.holder, 16, c.gold, "CENTER", UI.HEAD, true)
        sizeLabel:SetPoint("TOP", self.holder, "BOTTOM", 0, -6)
    end
    sizeLabel:SetText(format(L["Size: %d%%"], floor(s * 100 + 0.5)))
    sizeLabel:Show()
    relayout = (relayout or 0) + 1
    local mine = relayout
    C_Timer.After(0.4, function() if mine == relayout then UI.ClearCaches() end end)
    C_Timer.After(1.5, function() if mine == relayout and sizeLabel then sizeLabel:Hide() end end)
end

function UI:SavePosition()
    local h = self.holder
    if not h then return end
    local p, _, rp, x, y = h:GetPoint(1)
    if p then WFD.S.pos = { p, rp, x, y } end
end

function UI:ResetPosition()
    WFD.S.pos = nil
    if self.holder then
        self.holder:ClearAllPoints()
        self.holder:SetPoint("CENTER")
    end
end

local function restorePosition(h)
    local p = WFD.S.pos
    if not p then return end
    h:ClearAllPoints()
    h:SetPoint(p[1], UIParent, p[2], p[3], p[4])
end

------------------------------------------------------------------------
-- New since the diary was last read
------------------------------------------------------------------------
local function newCounts(since)
    local C = WFD.C
    local n = {}
    local function add(k) n[k] = (n[k] or 0) + 1 end
    for _, m in pairs(C.mobs or {}) do if (m.first or 0) > since then add("bestiary") end end
    for _, p in pairs(C.npcs or {}) do if not p.obj and (p.first or 0) > since then add("people") end end
    for _, q in pairs(C.quests or {}) do if (q.done or 0) > since then add("quests") end end
    for _, t in pairs(C.rares or {}) do if type(t) == "number" and t > since then add("treasures") end end
    for _, e in pairs(C.catch or {}) do if (e.first or 0) > since then add("fishbook") end end
    for _, z in pairs(C.zones or {}) do if (z.first or 0) > since then add("atlas") end end
    for _, e in ipairs(C.events or {}) do
        if (e.t or 0) > since then
            if e.k == "honour" then add("honour") elseif e.k == "first" then add("firsts") end
        end
    end
    return n
end

-- what is new since the window was last put away, per part ({} in the demo)
function UI.NewCounts()
    local since = UI.readSince
    if not since or WFD.demo then return {} end
    return newCounts(since)
end

------------------------------------------------------------------------
-- Hooks into the window
------------------------------------------------------------------------
local build0 = UI.Build
function UI:Build()
    local fresh = not self.holder
    build0(self)
    if not fresh then return end
    setupKeys(self.holder)
    restorePosition(self.holder)
    -- the moment the window is put away counts as "read until now"
    self.holder:HookScript("OnHide", function()
        if WFD.C and not WFD.demo then WFD.C.seenAt = time() end
    end)
end
