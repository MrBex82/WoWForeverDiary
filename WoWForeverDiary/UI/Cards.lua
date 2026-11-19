-- The cards of the desk, written as reports for the column of their view: the wanted poster (bestiary), the calling
-- card (people, in Registers.lua), the catch (angler's log) and a book of the library. They flow in the width of the
-- column instead of a fixed card that is scaled down. UI:ShowCard leads every kind to its view.
local ADDON, WFD = ...
local UI = WFD.UI
local L = WFD.L
local floor, min, format = math.floor, math.min, string.format

local levelText = UI.LevelText      -- "12", "??" for a skull, "?" when unknown (PagesAppendix.lua)

------------------------------------------------------------------------
-- Wanted poster
------------------------------------------------------------------------
local RARITY = {
    boss   = { label = "Boss" },
    rare   = { label = "Rare" },
    elite  = { label = "Elite" },
    normal = { label = "Normal" },
}
local function rarityOf(m)
    if m.boss then return RARITY.boss end
    if m.rare or m.cls == "rare" or m.cls == "rareelite" then return RARITY.rare end
    if m.cls == "elite" then return RARITY.elite end
    return RARITY.normal
end
-- marks for one kind of creature: always one more to reach
local MARKS = { 5, 25, 100, 250, 500, 1000 }

-- the wanted poster as a report in the column of the bestiary, written for its width
function UI.CreatureReport(rp, id)
    local C = WFD.C
    local m = C.mobs and C.mobs[id]
    if not m then return end
    local r = rarityOf(m)
    local R = UI.Router
    rp:Kicker(L["WANTED"])
    rp:Title(m.name or "?")
    rp:Chips({ { L[r.label], "gold" }, { format(L["Level %s"], levelText(m)), "ink" }, m.ctype and { m.ctype, "soft" } or nil })
    local mid = UI.ModelIdFor(id, m.name)
    rp:Model(mid, 170, not mid and L["In this place the game keeps secret what the creatures look like."] or nil)
    rp:Text(WFD:Quote(WFD:MarginNote(id, m)), "soft", "body")
    local rank, count = 1, 0
    for _, o in pairs(C.mobs) do
        count = count + 1
        if o.kills > m.kills then rank = rank + 1 end
    end
    local nem = C.nemesis and C.nemesis[m.name or ""]
    rp:Tiles({ { m.kills, L["Slain"], nil, "neg" }, { "#" .. rank, format(L["of %d kinds"], count) },
        { nem and nem.n or 0, L["Killed me"],
            nem and function() R.Go({ view = "fates", chip = "nemesis", key = "n:" .. m.name }) end, nem and "neg" or nil } }, 3)
    -- the next mark for this kind
    local prev, nextMark = 0, nil
    for _, mk in ipairs(MARKS) do
        if m.kills < mk then nextMark = mk break end
        prev = mk
    end
    if nextMark then
        rp:Text(format(L["Next mark: %d slain"], nextMark), "gold", "small", 4)
        rp:Progress((m.kills - prev) / (nextMark - prev), m.kills .. " / " .. nextMark)
    else
        rp:Text(L["Every mark reached"], "gold", "small", 8)
    end
    -- where it lives, and when
    local map = m.zone and C.zoneMaps and C.zoneMaps[m.zone]
    if m.zone then
        rp:Link(L["Seen in"] .. " " .. m.zone, nil, type(map) == "number" and function() R.Go({ view = "world", map = map }) end or nil,
            type(map) == "number" and L["Click for the map of this region."] or nil)
    end
    local fd = m.first and WFD:DayIndex(m.first)
    rp:DayLink(fd, m.first, L["First kill"] .. (m.fpl and ("  -  " .. format(L["Level %s"], tostring(m.fpl))) or ""))
    if m.last and m.last ~= m.first then rp:DayLink(WFD:DayIndex(m.last), m.last, L["Last kill"]) end
    if m.best then
        rp:Head(L["Best loot"])
        local q = WFD.qualityColors[m.bestQ or 1] or WFD.qualityColors[1]
        rp:Icons({ { WFD:ItemIcon(m.best) or UI.Icon("loot"), { q[1], q[2], q[3] }, m.best } })
    end
end

------------------------------------------------------------------------
-- A catch: what the line brought up
------------------------------------------------------------------------
local CATCH_MARKS = { 5, 25, 100, 250, 500, 1000 }

-- the catch as a report in the column of the angler's log, written for its width
function UI.CatchReport(rp, id)
    local C = WFD.C
    local e = C.catch and C.catch[id]
    if not e then return end
    local k = UI.FISH_KINDS[e.kind or "other"] or UI.FISH_KINDS.other
    local qc = UI.FISH_QCOL[min(5, e.q or 1)] or UI.FISH_QCOL[1]
    rp:Kicker(L["CAUGHT"])
    rp:Title(e.name or "?")
    rp:Chips({ { L[k.label], "gold" } })
    rp:Icons({ { UI.FishIcon(e, id), { qc[1], qc[2], qc[3] }, e.link } })
    local waters = {}
    for map, cnt in pairs(e.zones or {}) do waters[#waters + 1] = { map = map, n = cnt } end
    table.sort(waters, function(a, b) return a.n > b.n end)
    local share = (C.catchTotal or 0) > 0 and (e.n or 0) / C.catchTotal or 0
    rp:Tiles({ { e.n or 0, L["Caught"] }, { format("%d%%", floor(share * 100 + 0.5)), L["Of all catches"] },
        { #waters, L["Waters"] } }, 3)
    local prev, nextMark = 0, nil
    for _, mk in ipairs(CATCH_MARKS) do
        if (e.n or 0) < mk then nextMark = mk break end
        prev = mk
    end
    if nextMark then
        rp:Text(format(L["Next mark: %d caught"], nextMark), "gold", "small", 4)
        rp:Progress(((e.n or 0) - prev) / (nextMark - prev), (e.n or 0) .. " / " .. nextMark)
    end
    rp:DayLink(e.first and WFD:DayIndex(e.first), e.first, L["First catch"])
    if e.last and e.last ~= e.first then rp:DayLink(WFD:DayIndex(e.last), e.last, L["Last catch"]) end
    if (e.lured or 0) > 0 then rp:Text(L["On a lure"] .. ": " .. e.lured, "soft", "body") end
    rp:Head(L["WHERE IT BIT"], tostring(#waters))
    for i = 1, min(8, #waters) do
        local w = waters[i]
        rp:Link(WFD:MapName(w.map) or "?", w.n .. "x", function() UI.Router.Go({ view = "world", map = w.map }) end,
            L["Click for the map of this region."])
    end
end

------------------------------------------------------------------------
-- A book of the library
------------------------------------------------------------------------
-- a book, note or plaque as a report in the column of the library: the whole text flows in the column and scrolls
-- with the report; "read later" is a button
function UI.BookReport(rp, id)
    local b = WFD:Book(id)
    if not b then return end
    local kind = b.kind == "plaque" and L["Plaque"] or (b.kind == "note" and L["Note"] or L["Book"])
    rp:Kicker(kind .. (b.zone and ("  -  " .. b.zone) or ""))
    rp:Title(b.title or "?")
    rp:Text(format(L["Read by %s on %s"], b.who or "?", b.t and date(WFD.loc.date, b.t) or "?"), "muted", "small", 8)
    if not WFD:BookComplete(b) then rp:Text(L["Pages are missing: read the rest to complete this book."], "neg", "small", 8) end
    rp:Button(b.later and L["No longer read later"] or L["Read later"], function()
        b.later = (not b.later) or nil
        UI.SelectIn("library", id)
        local lib = UI.ViewInstance and UI.ViewInstance("library")
        if lib and lib.host:IsShown() then lib:Refresh(true) end
    end, "ghost")
    rp:Flourish()
    for p in (WFD:BookText(b) .. "\n\n"):gmatch("(.-)\n\n") do
        if p:find("%S") then rp:Paragraph(p, "ink") end
    end
end

------------------------------------------------------------------------
-- Every way to a card (the search, the old pages, links) leads to the report in its view
------------------------------------------------------------------------
local REPORT_VIEW = { person = "people", creature = "bestiary", catch = "fishbook", book = "library" }

function UI:ShowCard(kind, key)
    if not self.holder then return end
    local view = REPORT_VIEW[kind]
    if not view then return end
    local R = UI.Router
    if R.cur and R.cur.view == view then UI.SelectIn(view, key) else self:OpenShell({ view = view, key = key }) end
end
