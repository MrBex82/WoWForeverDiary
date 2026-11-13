-- Where the travel desk can go: the register (groups and their parts, in one place), the views that can be shown,
-- and the way there and back. Every way into the diary (the minimap, slash commands, notes, the search, the
-- companion, links on the pages) ends here as a route: { view = "start" }, { view = "legacy", page = n },
-- { view = "settings", section = 2 } ...
local ADDON, WFD = ...
local UI = WFD.UI

------------------------------------------------------------------------
-- The register: the groups of the left column and the parts in them. This table is the only place that
-- orders them. A part is the key of a section of the book (UI:RegisterSection); old = the key of the group
-- overview page in the book.
------------------------------------------------------------------------
UI.NAV = {
    { key = "start", label = "Start", icon = "time", route = { view = "start" } },
    { key = "diary", label = "Diary", icon = "quill", parts = { "diary", "quests", "memoriam" } },
    { key = "chronicle", label = "Chronicle", icon = "records", old = "grp_chronicle",
        parts = { "milestones", "firsts", "records", "levels", "yearbook", "recap", "gallery" } },
    { key = "goals", label = "Goals and honour", icon = "album", old = "grp_goals", parts = { "tasks", "collection", "honour" } },
    { key = "world", label = "The world", icon = "atlas", old = "grp_world", parts = { "atlas", "landmarks", "runs" } },
    { key = "hunt", label = "Hunt and loot", icon = "beast", old = "grp_hunt", parts = { "bestiary", "fishbook", "fishwaters", "treasures", "fates" } },
    { key = "people", label = "People and money", icon = "party", old = "grp_people", parts = { "people", "companions", "stable", "standing", "ledger" } },
    { key = "keep", label = "Keepsakes", icon = "kin", old = "grp_back", parts = { "library", "family", "capsule" } },
}
UI.NAV_GROUP = {}
UI.NAV_OF_PART = {}
for _, g in ipairs(UI.NAV) do
    UI.NAV_GROUP[g.key] = g
    for _, p in ipairs(g.parts or {}) do UI.NAV_OF_PART[p] = g.key end
    if g.old then UI.NAV_OF_PART[g.old] = g.key end
end
UI.NAV_OF_PART.today = "start"

-- the name of a part as the register writes it
function UI.PartLabel(key)
    if key == "diary" then return WFD.L["Days"] end
    if UI.PART_LABEL and UI.PART_LABEL[key] then return WFD.L[UI.PART_LABEL[key]] end
    return key
end

-- the parts of a group that are there (a part that only shows when it has something asks PART_ENABLED)
function UI.PartsOf(g)
    local out = {}
    for _, key in ipairs(g.parts or {}) do
        local there = UI.PART_VIEW and UI.PART_VIEW[key] ~= nil
        local en = UI.PART_ENABLED and UI.PART_ENABLED[key]
        if there and en then there = en() and true or false end
        if there then out[#out + 1] = key end
    end
    return out
end

------------------------------------------------------------------------
-- Views: what can stand on the desk
------------------------------------------------------------------------
-- def = { key, build = function(host) return view end }; a view has Show(route), Hide(), Layout(w, h) and may
-- have Refresh(), Head(route) -> title, path, group, part
UI.Views = {}
function UI:RegisterView(def) self.Views[def.key] = def end

------------------------------------------------------------------------
-- The way there and back
------------------------------------------------------------------------
local R = { back = {}, fwd = {}, cur = nil }
UI.Router = R
local MAX = 40

local function same(a, b)
    if not a or not b or a.view ~= b.view then return false end
    return a.section == b.section and a.group == b.group and a.key == b.key and a.map == b.map and a.cont == b.cont and a.day == b.day
end

function R.Go(route, opts)
    opts = opts or {}
    if not route then return end
    if R.cur and not opts.noHistory and not same(R.cur, route) then
        R.back[#R.back + 1] = R.cur
        if #R.back > MAX then table.remove(R.back, 1) end
        R.fwd = {}
    end
    R.cur = route
    if UI.ShowRoute then UI:ShowRoute(route) end
end

function R.CanBack() return #R.back > 0 end
function R.CanForward() return #R.fwd > 0 end

function R.Back()
    local to = table.remove(R.back)
    if not to then return end
    R.fwd[#R.fwd + 1] = R.cur
    R.cur = to
    if UI.ShowRoute then UI:ShowRoute(to) end
end

function R.Forward()
    local to = table.remove(R.fwd)
    if not to then return end
    R.back[#R.back + 1] = R.cur
    R.cur = to
    if UI.ShowRoute then UI:ShowRoute(to) end
end

function R.Reset()
    R.back, R.fwd = {}, {}
end

-- the place to come back to when the window opens again
function R.Resume() return R.cur end

-- the route of a part of the book
function UI.PartRoute(key)
    -- a part with a view of its own on the desk
    -- (a view's name, or a route of its own: a layer of the world map)
    local pv = UI.PART_VIEW and UI.PART_VIEW[key]
    if type(pv) == "table" then
        local r = {}
        for k, v in pairs(pv) do r[k] = v end
        return r
    end
    if pv then return { view = pv } end
    return { view = "start" }
end

-- the route of a group: Start for Start, the days of the diary, else the overview of the group on the desk
function UI.GroupRoute(g)
    if g.route then return g.route end
    if g.key == "diary" then return UI.PartRoute("diary") end
    return { view = "group", group = g.key }
end
