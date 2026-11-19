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

-- the bookmark of a place on the desk, if there is one (a day of the diary by its day, every other place by its
-- route, with what was chosen in it)
local MAX_MARKS = 12
local function markOf(route)
    if not route then return nil end
    for i, m in ipairs(WFD.C and WFD.C.marks or {}) do
        if route.view == "diary" then
            if m.day and m.day == route.day then return i end
        elseif m.route and UI.Router.Same(m.route, route) then
            return i
        end
    end
end
UI.MarkOf = markOf

-- sets or takes away the bookmark of a place (the button in the head bar); both can be undone
function UI.ToggleMarkAt(route)
    local C = WFD.C
    if not (C and route) then return end
    C.marks = C.marks or {}
    local i = markOf(route)
    if i then UI.RemoveMark(i) return end
    if #C.marks >= MAX_MARKS then
        UI:Notice(format(L["All %d bookmarks are in use. Remove one first."], MAX_MARKS))
        return
    end
    local mk
    if route.view == "diary" then
        if not route.day then return end
        mk = { day = route.day }
    else
        local r = {}
        for k, v in pairs(route) do
            local t = type(v)
            if t == "string" or t == "number" or t == "boolean" then r[k] = v end
        end
        mk = { route = r }
    end
    C.marks[#C.marks + 1] = mk
    if UI.OnMarksChanged then UI:OnMarksChanged() end
    UI:Notice(format(L["Bookmark set: %s"], markTitle(mk)), function()
        local at = markOf(route)
        if at then
            table.remove(C.marks, at)
            if UI.OnMarksChanged then UI:OnMarksChanged() end
        end
    end)
end

-- a bookmark taken away can be put back at its place from the note at the foot of the desk
function UI.RemoveMark(i)
    local marks = WFD.C and WFD.C.marks
    local m = marks and table.remove(marks, i)
    if UI.OnMarksChanged then UI:OnMarksChanged() end
    if m and UI.Notice then
        UI:Notice(format(L["Bookmark removed: %s"], markTitle(m)), function()
            table.insert(marks, math.min(i, #marks + 1), m)
            if UI.OnMarksChanged then UI:OnMarksChanged() end
        end)
    end
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
-- the open view scrolls: by a few lines, or by what is in sight (page)
local function scroll(dir, page)
    return function()
        local cur = UI.Router and UI.Router.cur
        local v = cur and UI.ViewInstance and UI.ViewInstance(cur.view)
        local sf = v and v.host and UI.Kit.MainScroll(v.host)
        if not sf then return end
        local by = page and max(48, (sf:GetHeight() or 0) - 40) or 48
        sf:ScrollTo(sf:GetVerticalScroll() + dir * by)
    end
end
local function back() if UI.Router then UI.Router.Back() end end
local function forward() if UI.Router then UI.Router.Forward() end end
local KEYS = {
    LEFT = flip(-1), RIGHT = flip(1),
    UP = scroll(-1), DOWN = scroll(1), PAGEUP = scroll(-1, true), PAGEDOWN = scroll(1, true),
    HOME = function() UI:OpenStart() end,
    END = function() UI:OpenShell({ view = "diary", day = WFD:NumDays() }) end,
    BACKSPACE = back,
    ["ALT-LEFT"] = back, ["ALT-RIGHT"] = forward,
    ["CTRL-F"] = function() if UI.FocusSearch then UI:FocusSearch() end end,
}
UI.KEYS = KEYS          -- for the load test
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

    return false
end

-- The window takes keys only while the mouse is over it: some game clients do not let a frame hand a key on to
-- the game, and then Enter (the chat) and walking would be lost while the window is open. Escape closes what lies
-- on top, then the window itself.
local function setupKeys(holder)
    if not holder.EnableKeyboard then return end
    holder:EnableKeyboard(false)
    propagate(holder, true)
    local watch = CreateFrame("Frame", nil, holder)
    local acc = 0
    watch:SetScript("OnUpdate", function(_, dt)
        acc = acc + dt
        if acc < 0.1 then return end
        acc = 0
        if InCombatLockdown and InCombatLockdown() then
            if holder:IsKeyboardEnabled() then pcall(holder.EnableKeyboard, holder, false) end
            return
        end
        local want = UI.inShell and holder:IsMouseOver() or false
        if holder:IsKeyboardEnabled() ~= want then pcall(holder.EnableKeyboard, holder, want) end
    end)
    -- the side buttons of the mouse (4: back, 5: forward) anywhere on the window, out of a fight
    local sideDown = {}
    local mouse = CreateFrame("Frame", nil, holder)
    mouse:SetScript("OnUpdate", function()
        if not (IsMouseButtonDown and UI.inShell) then return end
        for btn, fn in pairs({ Button4 = back, Button5 = forward }) do
            local down = IsMouseButtonDown(btn) and true or false
            if down and not sideDown[btn] and holder:IsMouseOver() and not (InCombatLockdown and InCombatLockdown()) then fn() end
            sideDown[btn] = down
        end
    end)
    holder:HookScript("OnHide", function() pcall(holder.EnableKeyboard, holder, false) end)
    holder:SetScript("OnKeyDown", function(self, key)
        local mod = (IsControlKeyDown() and "CTRL-") or (IsAltKeyDown() and "ALT-") or ""
        local fn = KEYS[mod .. key]
        local typing = GetCurrentKeyBoardFocus and GetCurrentKeyBoardFocus()
        if key == "ESCAPE" then
            if typing or (InCombatLockdown and InCombatLockdown()) then
                propagate(self, true)
                return
            end
            propagate(self, false)
            if not closeLayer() then UI:Hide() end
            C_Timer.After(0, function() propagate(self, true) end)
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
    -- bigger: the window may no longer fit the screen; its size is bounded again and the desk laid out anew
    if self.inShell and self.SetHolderMode then
        self:SetHolderMode("shell")
        if UI.LayoutShell then UI.LayoutShell() end
    end
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
-- Every part counts what came after it was last looked at (C.partSeen[part]); a part never looked at since this
-- came in counts from C.seenAt, the moment the diary was first opened.
local EVENT_PART = {
    honour = "honour", first = "firsts", landmark = "landmarks", level = "levels", dungeon = "runs",
    weekly = "tasks", challenge = "tasks", capsule = "capsule",
}
local function newCounts(C)
    local base = C.seenAt or 0
    local seen = C.partSeen or {}
    local n = {}
    local function add(k, t)
        if (t or 0) > max(base, seen[k] or 0) then n[k] = (n[k] or 0) + 1 end
    end
    for _, m in pairs(C.mobs or {}) do add("bestiary", m.first) end
    for _, p in pairs(C.npcs or {}) do if not p.obj then add("people", p.first) end end
    for _, q in pairs(C.quests or {}) do add("quests", q.done) end
    for _, t in pairs(C.rares or {}) do if type(t) == "number" then add("treasures", t) end end
    for _, e in pairs(C.catch or {}) do add("fishbook", e.first) end
    for _, z in pairs(C.zones or {}) do add("atlas", z.first) end
    -- the milestones in the parts where they are read (the same moments the note "many at once" bundles)
    for _, e in ipairs(C.events or {}) do
        local part = EVENT_PART[e.k]
        if part then add(part, e.t) end
    end
    return n
end

-- what is new per part since it was last looked at ({} in the demo)
function UI.NewCounts()
    local C = WFD.C
    if not C or not C.seenAt or WFD.demo then return {} end
    return newCounts(C)
end

-- a part was looked at: its news are read
function UI.PartSeen(part)
    local C = WFD.C
    if not part or not C or WFD.demo then return end
    C.partSeen = C.partSeen or {}
    C.partSeen[part] = time()
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
end
