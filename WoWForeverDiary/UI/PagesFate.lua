-- Fate: every death on the way. A map of the graves, area by area, where and to whom you fall most,
-- and the list of all deaths, the latest first.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local c = UI.c
local floor, max, min, format = math.floor, math.max, math.min, string.format

local RED = { 0.75, 0.16, 0.10, 1 }
local GRAVE = { 0.62, 0.06, 0.04, 1 }
UI.fateMap = nil        -- the area shown on the map, by map ID (kept while the book is open)

local function note(pool, canvas, tx, tw, y, text)
    local e = pool:Text(13, c.inkFaint, UI.FONT, "CENTER")
    e:SetText(text)
    e:SetWidth(tw)
    e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
    return e
end

-- the deaths with a grave on a map, by area, the area with most graves first
local function graveAreas(fates)
    local by, list = {}, {}
    for _, f in ipairs(fates) do
        if f.map and f.x and f.y then
            local a = by[f.map]
            if not a then
                a = { map = f.map, name = WFD:MapName(f.map), list = {} }
                by[f.map] = a
                list[#list + 1] = a
            end
            a.list[#a.list + 1] = f
        end
    end
    table.sort(list, function(a, b)
        if #a.list ~= #b.list then return #a.list > #b.list end
        return a.name < b.name
    end)
    return list
end

local function rowHeight() return max(36, UI.FS(13) + UI.FS(10) + 14) end

------------------------------------------------------------------------
-- The part: the map, the figures, then the list
------------------------------------------------------------------------
UI:RegisterSection({
    key = "fates", label = "Fate", icon = "skull", order = 31, leftStart = true,
    build = function(book)
        book:Add({ kind = "fatemap", numbered = true, head = L["Fate"] })
        local fates = WFD:Fates()
        -- without a death there is nothing to count: the one page says so, no second page repeats it
        if #fates == 0 then return end
        book:Add({ kind = "fatestats", numbered = true, head = L["Fate"] })
        local ROW = rowHeight()
        local page, y
        local function newPage()
            page = book:Add({ kind = "fatelist", rows = {}, numbered = true, head = L["Fate"] })
            y = 0
        end
        newPage()
        page.rows[1] = { y = 0, header = true, count = #fates }
        y = 34
        for i = #fates, 1, -1 do
            if y + ROW > UI.AREA_H then newPage() end
            page.rows[#page.rows + 1] = { y = y, f = fates[i] }
            y = y + ROW
        end
    end,
})

------------------------------------------------------------------------
-- The map of the graves
------------------------------------------------------------------------
UI:RegisterRenderer("fatemap", function(pool, page, side, canvas, index)
    local C = WFD.C
    local tx, tw = UI.TextX(side), UI.TextW()
    local fates = WFD:Fates()
    local areas = graveAreas(fates)
    local pick
    for i, a in ipairs(areas) do if a.map == UI.fateMap then pick = i end end
    pick = pick or 1
    local area = areas[pick]
    UI.fateMap = area and area.map

    local y = UI.PageTitle(pool, canvas, side, L["Fate"], area and area.name or L["Every fall on the way"], -56)
    -- arrows to the other areas, beside the area name
    if #areas > 1 then
        local function arrow(text, dir, x, justify)
            local a = pool:Text(18, c.redInk, UI.HEAD, justify)
            a:SetText(text)
            a:SetPoint(justify == "LEFT" and "TOPLEFT" or "TOPRIGHT", canvas, "TOPLEFT", x, y + 44)
            local other = areas[((pick - 1 + dir) % #areas) + 1]
            local hot = pool:Hot({ other.name }, function()
                UI.fateMap = other.map
                UI:RenderPage(side, index)
            end)
            hot:SetPoint("TOPLEFT", a, "TOPLEFT", -8, 6)
            hot:SetPoint("BOTTOMRIGHT", a, "BOTTOMRIGHT", 8, -6)
        end
        arrow("<", -1, tx + 4, "LEFT")
        arrow(">", 1, tx + tw - 4, "RIGHT")
    end

    local last = fates[#fates]
    local zones = {}
    for _, f in ipairs(fates) do if f.zone then zones[f.zone] = true end end
    local nz = 0
    for _ in pairs(zones) do nz = nz + 1 end
    local th = UI.Tiles(pool, canvas, tx, y, tw, {
        { #fates, L["Deaths"], #fates > 0 and c.bad or c.ink },
        { nz, L["Places of death"], c.ink },
        { last and format(L["Day %d"], last.day or 1) or "-", L["Last death"], c.ink, last and UI.DayGo(last.day) },
    })
    y = y - th - 12

    if #fates == 0 then
        note(pool, canvas, tx, tw, y - 6, L["Nobody has defeated you yet. Long may it last!"])
        return
    end
    if not area then
        note(pool, canvas, tx, tw, y - 6, L["None of the graves has a place on a map yet."])
    else
        -- the map in a dark mount, like the hunting grounds (same size: the map frames are shared)
        local MAT = 9
        local mw = tw - MAT * 2
        local mh = floor(mw / 1.5)
        local mat = pool:Rect({ 0.08, 0.055, 0.035 }, 1, "ARTWORK", 1)
        mat:SetSize(tw, mh + MAT * 2)
        mat:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        local m = pool:Map(mw, mh)
        m:SetSize(mw, mh)
        m:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + MAT, y - MAT)
        m:SetFrameLevel(canvas:GetFrameLevel() + 2)
        local points = {}
        for _, f in ipairs(area.list) do
            local when = format(L["Day %d"], f.day or 1) .. (f.level and ("  -  " .. format(L["Level %d"], f.level)) or "")
            points[#points + 1] = { f.x, f.y, GRAVE,
                { f.by and format(L["Killed by %s"], f.by) or L["You died here"], when, L["Click to read this day."] },
                false, UI.DayGo(f.day) }
        end
        m:DrawPoints(area.map, points)
        m:SetPlayer(nil)
        y = y - mh - MAT * 2 - 10
        local n = pool:Text(11, c.inkSoft, UI.FONT, "CENTER")
        n:SetText(format(L["Graves here: %d"], #area.list))
        n:SetWidth(tw)
        n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y)
        y = y - n:GetStringHeight() - 10
    end
    -- hardcore: the death that ended it all has its own page
    local first = UI.book and UI.book.sectionStart.memoriam
    if C.obituary and first then
        local link = pool:Link(L["In memoriam"] .. "  >", function() UI:GoToPage(first) end, 13)
        link:SetPoint("TOP", canvas, "TOPLEFT", tx + tw / 2, y)
    end
end)

------------------------------------------------------------------------
-- Where, to whom, at which level
------------------------------------------------------------------------
UI:RegisterRenderer("fatestats", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local fates = WFD:Fates()
    local y = -UI.TOP
    local bottom = -(UI.PH - UI.BOTTOM)
    if #fates == 0 then
        note(pool, canvas, tx, tw, y - 20, L["Nobody has defeated you yet. Long may it last!"])
        return
    end
    local ROW = max(22, UI.FS(12) + 10)
    -- a small ranking: { label, count, onClick }
    local function ranking(title, items, limit, empty)
        if y - 22 - ROW < bottom then return end
        table.sort(items, function(a, b)
            if a[2] ~= b[2] then return a[2] > b[2] end
            return a[1] < b[1]
        end)
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, title)
        y = y - 22
        if #items == 0 then
            -- a heading never stands alone: it says why the list is empty
            local e = pool:Text(11, c.inkFaint, UI.FONT)
            e:SetText(empty or "-")
            e:SetWidth(tw - 8)
            e:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 2)
            y = y - ROW - 12
            return
        end
        local most = items[1] and items[1][2] or 1
        for i = 1, min(limit, #items) do
            if y - ROW < bottom then break end
            local it = items[i]
            local n = pool:Text(12, c.ink, UI.FONT)
            n:SetText(it[1])
            n:SetWordWrap(false)
            n:SetWidth(tw * 0.48)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 2)
            local bx = tx + tw * 0.5
            UI.ProgressBar(pool, canvas, bx, y - 7, tx + tw - 34 - bx, 5, it[2] / max(1, most), RED)
            local k = pool:Text(11, c.inkSoft, UI.FONT, "RIGHT")
            k:SetText(it[2] .. "x")
            k:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
            if it[3] then
                local hot = pool:Hot({ it[1], it[2] .. "x" }, it[3])
                hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 1)
                hot:SetSize(tw, ROW - 2)
            end
            y = y - ROW
        end
        y = y - 12
    end

    local byZone, byFoe, byLevel = {}, {}, {}
    local unknown = 0
    for _, f in ipairs(fates) do
        local z = f.zone or "?"
        byZone[z] = (byZone[z] or 0) + 1
        if f.by then byFoe[f.by] = (byFoe[f.by] or 0) + 1 else unknown = unknown + 1 end
        local band = floor((f.level or 1) / 10)
        byLevel[band] = (byLevel[band] or 0) + 1
    end
    local zones, foes, levels = {}, {}, {}
    for z, n in pairs(byZone) do zones[#zones + 1] = { z, n } end
    local nemesisPage = UI.book and UI.book.sectionStart.nemesis
    for name, n in pairs(byFoe) do
        foes[#foes + 1] = { name, n, nemesisPage and function() UI:GoToPage(nemesisPage) end }
    end
    ranking(L["Where you fall most"], zones, 5)
    ranking(L["Who defeated you most"], foes, 5, L["The diary could not tell who it was."])
    -- by level, in bands of ten, the lowest first
    for band, n in pairs(byLevel) do
        local a, b = max(1, band * 10), band * 10 + 9
        levels[#levels + 1] = { format(L["Level %d-%d"], a, b), n, band = band }
    end
    table.sort(levels, function(p, q) return p.band < q.band end)
    if #levels > 0 and y - 22 - ROW >= bottom then
        UI.SectionHead(pool, canvas, tx, tw, y + 18, 32, L["Deaths by level"])
        y = y - 22
        local most = 1
        for _, l in ipairs(levels) do most = max(most, l[2]) end
        for _, l in ipairs(levels) do
            if y - ROW < bottom then break end
            local n = pool:Text(12, c.ink, UI.FONT)
            n:SetText(l[1])
            n:SetWordWrap(false)
            n:SetWidth(tw * 0.48)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 2)
            local bx = tx + tw * 0.5
            UI.ProgressBar(pool, canvas, bx, y - 7, tx + tw - 34 - bx, 5, l[2] / most, RED)
            local k = pool:Text(11, c.inkSoft, UI.FONT, "RIGHT")
            k:SetText(l[2] .. "x")
            k:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw, y - 2)
            y = y - ROW
        end
    end
    if unknown > 0 and y - UI.FS(11) - 6 >= bottom then
        local u = pool:Text(11, c.inkFaint, UI.FONT)
        u:SetText(format(L["Foe unknown: %d"], unknown))
        u:SetWidth(tw)
        u:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 4, y - 4)
    end
end)

------------------------------------------------------------------------
-- Every death, the latest first
------------------------------------------------------------------------
UI:RegisterRenderer("fatelist", function(pool, page, side, canvas)
    local tx, tw = UI.TextX(side), UI.TextW()
    local top = -UI.TOP
    local ROW = rowHeight()
    for _, r in ipairs(page.rows) do
        local y = top - r.y
        if r.header then
            UI.SectionHead(pool, canvas, tx, tw, y + 4, 32, L["Every death"], tostring(r.count))
        else
            local f = r.f
            pool:Plaque(tx + 14, y - ROW / 2 + 2, 20, UI.Icon("skull"), GRAVE, true)
            local lv = pool:Text(11, c.inkSoft, UI.FONT, "RIGHT")
            lv:SetText(f.level and format(L["Level %d"], f.level) or "")
            lv:SetPoint("TOPRIGHT", canvas, "TOPLEFT", tx + tw - 4, y - 3)
            local n = pool:Text(13, f.by and c.bad or c.inkSoft, UI.FONT)
            n:SetText(f.by and format(L["Killed by %s"], f.by) or L["Cause unknown"])
            n:SetWordWrap(false)
            n:SetWidth(tw - 32 - lv:GetStringWidth() - 12)
            n:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 32, y - 2)
            local parts = { f.zone or "?", format(L["Day %d"], f.day or 1) }
            if f.t then parts[#parts + 1] = date("%H:%M", f.t) end
            if f.group then parts[#parts + 1] = format(L["Group: %d"], f.group) end
            local s = pool:Text(10, c.inkSoft, UI.FONT)
            s:SetText(table.concat(parts, "  -  "))
            s:SetWordWrap(false)
            s:SetWidth(tw - 32 - 4)
            s:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx + 32, y - UI.FS(13) - 6)
            local go = UI.DayGo(f.day)
            local hot = pool:Hot({ n:GetText(), table.concat(parts, "  -  "), go and L["Click to read this day."] or nil }, go)
            hot:SetPoint("TOPLEFT", canvas, "TOPLEFT", tx, y + 2)
            hot:SetSize(tw, ROW - 3)
        end
    end
end)
