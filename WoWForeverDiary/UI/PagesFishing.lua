-- The angler's log: a collector's album of everything the line brought up, by water, with the waters
-- and the tackle on a last page. Built like the bestiary, but its cards are drawn straight on the page.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local max, min, ceil, format = math.max, math.min, math.ceil, string.format

local CARD_W, CARD_H, GAP_X, GAP_Y = 108, 118, 12, 10
local PER_PAGE = 9

local TIERS = {           -- ranks of the log, by the number of different catches
    { 5, "Bronze", { 0.70, 0.42, 0.20, 1 } }, { 15, "Silver", { 0.70, 0.72, 0.76, 1 } },
    { 30, "Gold", { 0.92, 0.72, 0.22, 1 } }, { 60, "Mithril", { 0.45, 0.70, 0.85, 1 } },
    { 100, "Legend", { 0.62, 0.22, 0.70, 1 } },
}
UI.FISH_TIERS = TIERS

local KINDS = {
    fish     = { label = "Fish", col = { 0.30, 0.62, 0.80, 1 } },
    junk     = { label = "Junk", col = { 0.58, 0.56, 0.52, 1 } },
    treasure = { label = "Treasure", col = { 0.92, 0.72, 0.22, 1 } },
    other    = { label = "Odds and ends", col = { 0.70, 0.55, 0.38, 1 } },
}
UI.FISH_KINDS = KINDS

-- quality colours that read on the dark card
local QCOL = {
    [0] = { 0.62, 0.62, 0.62, 1 }, [1] = { 0.95, 0.92, 0.84, 1 }, [2] = { 0.40, 0.90, 0.30, 1 },
    [3] = { 0.45, 0.66, 1.00, 1 }, [4] = { 0.75, 0.45, 0.95, 1 }, [5] = { 1.00, 0.60, 0.15, 1 },
}
UI.FISH_QCOL = QCOL

local TACKLE_ICONS = {
    rod  = { "INV_Fishingpole_02", "INV_Fishingpole_01" },
    lure = { "INV_Misc_Food_15", "INV_Misc_Bait_01", "INV_Misc_Gem_Pearl_03" },
    gear = { "INV_Misc_Cape_06", "INV_Misc_Bag_08" },
}
local TACKLE_LABEL = { rod = "Fishing pole", lure = "Lure", gear = "Fishing gear" }

local function kindOf(e) return KINDS[e.kind or "other"] or KINDS.other end

-- when the game cannot tell the icon: one that suits the kind, never a fish for a chest
local KIND_ICONS = {
    fish     = { "INV_Misc_Fish_02", "INV_Misc_Fish_03" },
    junk     = { "INV_Misc_Bag_09", "INV_Misc_Rune_01" },
    treasure = { "INV_Box_01", "INV_Misc_Gem_Pearl_05" },
    other    = { "INV_Misc_Bag_08", "INV_Misc_Note_01" },
}

-- the item's own picture: kept at the catch, else asked from the game by the item number (no link needed)
local function instantIcon(id)
    local fn = GetItemInfoInstant or (C_Item and C_Item.GetItemInfoInstant)
    if fn and id then
        local ok, _, _, _, _, icon = pcall(fn, id)
        if ok and icon then return icon end
    end
end

local function iconOf(e, id)
    if e.icon then return e.icon end
    local inst = instantIcon(id)
    if inst then return inst end
    local path = e.link and WFD:ItemIcon(e.link)
    if path then return path end
    return UI.IconPath(KIND_ICONS[e.kind or "other"] or KIND_ICONS.other, "loot")
end
UI.FishIcon = iconOf

-- collection order: first catch first, numbered like an album; each catch lives on the water that gave most
local function collection()
    local arr = {}
    for id, e in pairs(WFD.C.catch or {}) do
        local best, bn = nil, -1
        for map, n in pairs(e.zones or {}) do
            if n > bn then best, bn = map, n end
        end
        arr[#arr + 1] = { id = id, e = e, map = best, zone = best and WFD:MapName(best) or "?" }
    end
    table.sort(arr, function(a, b)
        if (a.e.first or 0) ~= (b.e.first or 0) then return (a.e.first or 0) < (b.e.first or 0) end
        return (a.e.name or "") < (b.e.name or "")
    end)
    for i, a in ipairs(arr) do a.num = i end
    return arr
end

-- for the album on the travel desk
UI.CatchCollection = collection
UI.CATCH_CARD_W, UI.CATCH_CARD_H = CARD_W, CARD_H

------------------------------------------------------------------------
-- One card, drawn on the page
------------------------------------------------------------------------
-- a covered card: a catch another character made - only the kind and who knows it
local function drawHint(pool, canvas, x, y, a)
    local h = a.h
    local kind = KINDS[h.kind or "other"] or KINDS.other
    local sh = pool:Rect({ 0, 0, 0 }, 0.20, "BACKGROUND", -3)
    sh:SetSize(CARD_W, CARD_H)
    sh:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 3, y - 4)
    local rim = pool:Rect(kind.col, 0.55, "BACKGROUND", -2)
    rim:SetSize(CARD_W, CARD_H)
    rim:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    local body = pool:Grad("VERTICAL", { 0.06, 0.04, 0.03, 0.9 }, { 0.16, 0.11, 0.07, 0.9 }, "BACKGROUND", -1)
    body:SetPoint("TOPLEFT", rim, "TOPLEFT", 2, -2)
    body:SetPoint("BOTTOMRIGHT", rim, "BOTTOMRIGHT", -2, 2)
    local tag = pool:Text(8, kind.col, UI.HEAD, "CENTER")
    tag:SetText(L[kind.label]:upper())
    tag:SetWidth(CARD_W)
    tag:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y - 7)
    local q = pool:Text(40, { 0.55, 0.45, 0.30, 0.7 }, UI.HEAD, "CENTER")
    q:SetText("?")
    q:SetWidth(CARD_W)
    q:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y - 36)
    local who = pool:Text(9, { 0.88, 0.76, 0.54, 1 }, UI.FONT, "CENTER")
    who:SetText(h.who and format(L["Known to %s"], h.who) or L["not yet found"])
    who:SetWidth(CARD_W - 12)
    who:SetHeight(24)
    if who.SetMaxLines then who:SetMaxLines(2) end
    who:SetJustifyV("MIDDLE")
    who:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 6, y - CARD_H + 30)
    local hot = pool:Hot({ L["Not yet discovered"], a.zone, h.who and format(L["Known to %s"], h.who) or "" })
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    hot:SetSize(CARD_W, CARD_H)
end

local function drawCard(pool, canvas, x, y, a)
    if a.hint then return drawHint(pool, canvas, x, y, a) end
    local e = a.e
    local kind = kindOf(e)
    local qc = QCOL[min(5, e.q or 1)] or QCOL[1]
    -- shadow, body, rim
    local sh = pool:Rect({ 0, 0, 0 }, 0.30, "BACKGROUND", -3)
    sh:SetSize(CARD_W, CARD_H)
    sh:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 3, y - 4)
    local rim = pool:Rect(kind.col, 1, "BACKGROUND", -2)
    rim:SetSize(CARD_W, CARD_H)
    rim:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    local body = pool:Grad("VERTICAL", { 0.08, 0.06, 0.04, 1 }, { 0.24, 0.19, 0.13, 1 }, "BACKGROUND", -1)
    body:SetPoint("TOPLEFT", rim, "TOPLEFT", 2, -2)
    body:SetPoint("BOTTOMRIGHT", rim, "BOTTOMRIGHT", -2, 2)
    -- number and kind
    local num = pool:Text(9, { 1, 0.92, 0.75, 1 }, UI.FONT, "LEFT")
    num:SetText(format("#%03d", a.num))
    num:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 7, y - 6)
    local tag = pool:Text(8, kind.col, UI.HEAD, "RIGHT")
    tag:SetText(L[kind.label]:upper())
    tag:SetWordWrap(false)
    -- a long kind in a long language: first in small letters, then without the number
    local room = CARD_W - 14 - num:GetStringWidth() - 6
    if tag:GetStringWidth() > room then tag:SetText(L[kind.label]) end
    if tag:GetStringWidth() > room then
        num:SetText("")
        room = CARD_W - 14
    end
    tag:SetWidth(room)
    tag:SetPoint("TOPRIGHT", canvas, "TOPLEFT", x + CARD_W - 7, y - 6)
    -- the picture
    local pl = pool:Plaque(x + CARD_W / 2, y - 48, 46, iconOf(e, a.id), qc, true, UI.ShortCount(e.n or 0))
    -- the name, two lines at most
    local nm = pool:Text(10, qc, UI.FONT, "CENTER")
    nm:SetText(e.name or "?")
    nm:SetWidth(CARD_W - 12)
    nm:SetHeight(26)
    nm:SetWordWrap(true)
    if nm.SetMaxLines then nm:SetMaxLines(2) end
    nm:SetPoint("TOPLEFT", canvas, "TOPLEFT", x + 6, y - 84)
    nm:SetJustifyV("MIDDLE")
    local isNew = e.day and e.day == WFD:NumDays()
    if isNew then
        local nw = pool:Text(9, { 1, 0.95, 0.6, 1 }, UI.HEAD, "CENTER")
        nw:SetText(L["NEW"])
        nw:SetPoint("CENTER", pl, "TOPRIGHT", -2, -2)
    end
    local hot = pool:Hot(nil, function() UI:ShowCard("catch", a.id) end, e.link)
    hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", x, y)
    hot:SetSize(CARD_W, CARD_H)
end

UI.DrawCatchCard = drawCard

-- the picture and the kind of a piece of tackle (the waters and tackle on the travel desk)
function UI.TackleLook(id, r)
    local fallback = TACKLE_ICONS[r.kind or "rod"] or TACKLE_ICONS.rod
    return instantIcon(id) or (r.link and WFD:ItemIcon(r.link)) or UI.IconPath(fallback, "loot"),
        L[TACKLE_LABEL[r.kind or "rod"] or "Fishing pole"]
end
