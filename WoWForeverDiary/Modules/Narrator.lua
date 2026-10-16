-- Turns the numbers of one day into a diary entry
local ADDON, WFD = ...
local L = WFD.L
local format, sort = string.format, table.sort

------------------------------------------------------------------------
-- Category names for money flows
------------------------------------------------------------------------
local CAT_NAMES = {
    loot = "Loot", quest = "Quest rewards", sell = "Vendor sales", mail = "Mail", trade = "Trading",
    ah = "Auction house", repair = "Repairs", vendor = "Purchases", training = "Training",
    flight = "Flights", bank = "Bank", other = "Other",
}
function WFD:CatName(cat) return L[CAT_NAMES[cat] or cat] end

local ROLE_NAMES = {
    talk = "Conversation", quest = "Quests", merchant = "Vendor", trainer = "Trainer",
    flight = "Flight master", bank = "Banker", stable = "Stable master", petition = "Petitions",
    auction = "Auctioneer",
}
function WFD:RoleName(role) return L[ROLE_NAMES[role] or role] end

------------------------------------------------------------------------
-- Templates (%s / %d are filled in by the code below).
-- Locales\*.lua may provide WFD.loc.narrator; missing entries fall back to English.
------------------------------------------------------------------------
local EN = {
    birth = {
        "Day 1. I'm a %s %s, and today I woke up in %s. What happens next? No idea.",
        "Day 1. %s, %s, freshly arrived in %s. Let's see where this goes.",
    },
    begin = {
        "Day 1. From now on I'm writing down what happens to me out there.",
    },
    open = {
        "Day %d, %s.",
        "Day %d. Today was all about %s.",
        "Day %d. Back on the road, mostly around %s.",
    },
    far = "parts unknown",
    walk = {
        "Walked about %s kilometres%s.",
        "My feet say roughly %s kilometres%s.",
        "Around %s kilometres on foot%s, and my legs know it.",
    },
    via = " (%s)",
    fly = " Flew the rest of the way.",
    kills = {
        "{One enemy|%d enemies} fell by my hand.",
        "Took down %d {creature|creatures}.",
        "{One enemy|%d enemies} fewer in the world.",
    },
    top = {
        "Most of them: %s (%dx).",
        "%s crossed my path the most (%dx).",
    },
    special = "Worth remembering: %s.",
    deaths = {
        "Died {once|%d times}.%s",
        "Ate dirt {once|%d times} today.%s",
    },
    deathBy = " The last one was courtesy of %s.",
    noDeath = {
        "Didn't die once today.",
        "Not a single death today. Not bad.",
    },
    questDone = {
        "{Finished a quest|Finished %d quests}: %s.",
        "Crossed off my list: %s.",
    },
    questAcc = {
        "And {a new one came|%d new ones came} in.",
        "And right away {another task is|%d more tasks are} waiting.",
    },
    questAccOnly = {
        "{Took on a new task, but it's not done yet.|Took on %d new tasks, none of them done yet.}",
    },
    more = "and a few more",
    quote = {
        "%s said: %s",
        "In %s's words: %s",
    },
    quoteAnon = "One line stuck with me: %s",
    npcs = {
        "{The only one I talked to was %s.|Talked to %d people, %s among them.}",
        "{One conversation, with %s.|%d conversations, for example with %s.}",
    },
    gain = {
        "My purse is %s heavier.",
        "All in all, %s more in my pocket.",
    },
    loss = {
        "My purse is %s lighter.",
        "All in all the day cost me %s.",
    },
    src = " Most of the income: %s (%s).",
    spent = " Most of it went on %s (%s).",
    item = {
        "Best find: %s.",
        "Find of the day: %s.",
    },
    levels = {
        "Reached level %s.",
        "Made it to level %s.",
        "And then: level %s!",
    },
    quiet = {
        "Quiet day. Not much to tell.",
        "Not much happened today.",
    },
    -- today, while it is still going on: nothing yet / instead of a closing line
    begun = {
        "The day has only just begun.",
        "The day is still young.",
        "The new day is just getting started.",
    },
    ongoing = {
        "The day isn't over yet.",
        "To be continued ...",
        "Let's see what else the day brings.",
    },
    close = {
        "That's it for today.",
        "Enough for today. More tomorrow.",
        "Time for a break.",
        "Let's see what tomorrow brings.",
    },
    closeLong = {
        "%s on the road. That'll do.",
        "After %s I'm pretty worn out.",
        "All in all %s on my feet. More tomorrow.",
    },
    none = "There is no entry for this day.",
}

-- The language is applied at ADDON_LOADED (after this file loads), so templates are looked up per call.
local function templates()
    local n = WFD.loc.narrator
    if not n then return EN end
    if not getmetatable(n) then setmetatable(n, { __index = EN }) end
    return n
end

local function pick(list, seed)
    return list[(seed % #list) + 1]
end

-- A template that counts something: "{one|many}" picks the singular or plural wording for n,
-- and the first %d is n (the singular may leave the number out: "{once|%d times}").
local function counted(tpl, n, ...)
    local s = tpl:gsub("{([^|{}]*)|([^|{}]*)}", n == 1 and "%1" or "%2")
    s = s:gsub("%%d", tostring(n), 1)
    return format(s, ...)
end

local function sortedByValue(tbl, limit)
    local arr = {}
    for k, v in pairs(tbl) do arr[#arr + 1] = { k = k, v = v } end
    sort(arr, function(a, b) return a.v > b.v end)
    if limit and #arr > limit then
        for i = #arr, limit + 1, -1 do arr[i] = nil end
    end
    return arr
end

-- Locales may change list commas, sentence spacing and quote marks (e.g. "、", "" and 「」 in Chinese).
local function join(list, sep)
    return table.concat(list, sep or WFD.loc.listSep or ", ")
end

-- "A, B and C", the way people write lists (languages without a word for "and" just use the separator)
local function listing(list)
    local word = WFD.loc.listAnd
    if not word or #list < 2 then return join(list) end
    local head = {}
    for i = 1, #list - 1 do head[i] = list[i] end
    return join(head) .. word .. list[#list]
end

-- a logged moment like "Rare creature slain: Mother Fang" reads better in a sentence as "Mother Fang (rare creature slain)"
local function moment(s)
    local what, name = s:match("^(.-):%s*(.+)$")
    if not name or name:find("%(") then return s end
    name = name:gsub("!$", "")
    -- lower case inside the sentence, except in languages that capitalise nouns
    local first, rest = what:match("^([%z\1-\127\194-\244][\128-\191]*)(.*)$")
    if first and not WFD.loc.nounCase then what = first:lower() .. rest end
    return name .. " (" .. what .. ")"
end

------------------------------------------------------------------------
-- Day facts, shared by the narrator and the journal
------------------------------------------------------------------------
function WFD:DayFacts(idx)
    local C = self.C
    local d = C.days[idx]
    if not d then return nil end
    local f = { d = d, idx = idx }

    f.zones = sortedByValue(d.zones or {})
    f.mainZone = f.zones[1] and f.zones[1].k or nil
    f.km = ((d.steps or 0) * 0.9144) / 1000
    f.flown = (d.flown or 0) > 500

    f.mobs = {}
    for id, n in pairs(d.kills) do
        local m = C.mobs[id]
        f.mobs[#f.mobs + 1] = { id = id, n = n, name = m and m.name or ("#" .. id), boss = m and m.boss, rare = m and m.rare }
    end
    sort(f.mobs, function(a, b) return a.n > b.n end)

    f.npcList = {}
    local npcCount = 0
    for key, n in pairs(d.npcs) do
        local npc = C.npcs[key]
        npcCount = npcCount + 1
        f.npcList[#f.npcList + 1] = { key = key, n = n, name = npc and npc.name or "?" }
    end
    sort(f.npcList, function(a, b) return a.n > b.n end)
    f.npcCount = npcCount

    f.income = self:Sum(d.income)
    f.spend = self:Sum(d.spend)
    f.net = f.income - f.spend

    f.items = {}
    local itemCount = 0
    for id, e in pairs(d.loot) do
        f.items[#f.items + 1] = { id = id, link = e.link, n = e.n, q = e.q, src = e.src }
        itemCount = itemCount + e.n
    end
    sort(f.items, function(a, b)
        if a.q ~= b.q then return a.q > b.q end
        return a.n > b.n
    end)
    f.itemCount = itemCount

    f.events = {}
    for _, ev in ipairs(C.events) do
        if ev.day == idx then f.events[#f.events + 1] = ev end
    end
    return f
end

------------------------------------------------------------------------
-- The story
------------------------------------------------------------------------
function WFD:Narrate(idx)
    local C = self.C
    local T = templates()
    local SPACE = self.loc.sentenceSep or " "
    local quotes = self.loc.quotes
    local Q1, Q2 = quotes and quotes[1] or "\"", quotes and quotes[2] or "\""
    local f = self:DayFacts(idx)
    if not f then return T.none end
    local d = f.d
    local seed = idx * 7 + (C.born % 13)
    local paras = {}
    local sections = 0

    -- opening
    local p = {}
    local zoneName = f.mainZone or C.startZone or T.far
    if idx == 1 then
        if C.fresh then
            p[#p + 1] = format(pick(T.birth, seed), C.race or "?", C.class or "?", WFD:Place(C.startZone or zoneName, "in"))
        else
            p[#p + 1] = pick(T.begin, seed)
        end
    else
        -- "<in>" in a sentence: the place with the preposition its language needs ("im Wald von Elwynn")
        local tpl = pick(T.open, seed):gsub("<in>", (WFD:Place(zoneName, "in"):gsub("%%", "%%%%")))
        p[#p + 1] = format(tpl, idx, zoneName)
    end
    if f.km >= 0.2 then
        local via = ""
        if #f.zones > 1 then
            local names = {}
            for i = 1, math.min(3, #f.zones) do names[#names + 1] = f.zones[i].k end
            via = format(T.via, listing(names))
        end
        p[#p + 1] = format(pick(T.walk, seed + 1), self:Dec(f.km), via) .. (f.flown and T.fly or "")
        sections = sections + 1
    end
    paras[#paras + 1] = join(p, SPACE)

    -- combat
    p = {}
    if d.killTotal > 0 then
        p[#p + 1] = counted(pick(T.kills, seed + 2), d.killTotal)
        if f.mobs[1] then p[#p + 1] = format(pick(T.top, seed + 3), f.mobs[1].name, f.mobs[1].n) end
        sections = sections + 1
    end
    local specials, had = {}, {}
    for _, ev in ipairs(f.events) do
        if (ev.k == "boss" or ev.k == "rare" or ev.k == "epic" or ev.k == "rareitem" or ev.k == "dungeon" or ev.k == "zone" or ev.k == "landmark")
            and ev.s and not had[ev.s] then
            had[ev.s] = true      -- the same moment twice is told once
            specials[#specials + 1] = moment(ev.s)
        end
    end
    if #specials > 0 then
        local shown = {}
        for i = 1, math.min(3, #specials) do shown[#shown + 1] = specials[i] end
        p[#p + 1] = format(T.special, listing(shown))
        sections = sections + 1
    end
    if d.deaths > 0 then
        local by = d.deathBy[#d.deathBy]
        p[#p + 1] = counted(pick(T.deaths, seed + 4), d.deaths, by and format(T.deathBy, by) or "")
        sections = sections + 1
    elseif d.killTotal >= 10 then
        p[#p + 1] = pick(T.noDeath, seed + 5)
    end
    if #p > 0 then paras[#paras + 1] = join(p, SPACE) end

    -- quests and people
    p = {}
    local nDone, nAcc = #d.qd, #d.qa
    if nDone > 0 then
        -- quests of a chain often share one title: each title is named once
        local names, seen, distinct = {}, {}, 0
        for i = 1, nDone do
            local q = C.quests[d.qd[i]]
            local title = q and q.title or "?"
            if not seen[title] then
                seen[title] = true
                distinct = distinct + 1
                if #names < 4 then names[#names + 1] = Q1 .. title .. Q2 end
            end
        end
        local list = distinct > 4 and (join(names) .. SPACE .. T.more) or listing(names)
        p[#p + 1] = counted(pick(T.questDone, seed + 6), nDone, list)
        if nAcc > 0 then p[#p + 1] = counted(pick(T.questAcc, seed + 7), nAcc) end
        sections = sections + 1
    elseif nAcc > 0 then
        p[#p + 1] = counted(pick(T.questAccOnly, seed + 7), nAcc)
        sections = sections + 1
    end
    if f.npcCount > 0 then
        local names = {}
        for i = 1, math.min(3, #f.npcList) do names[#names + 1] = f.npcList[i].name end
        p[#p + 1] = counted(pick(T.npcs, seed + 8), f.npcCount, listing(names))
        sections = sections + 1
    end
    -- a line one of the quest givers said that day
    local said = {}
    for _, id in ipairs(d.qa) do
        local q = C.quests[id]
        if q and q.quote then said[#said + 1] = q end
    end
    if #said > 0 then
        local q = said[(seed % #said) + 1]
        local line = Q1 .. q.quote .. Q2
        if q.giverName then
            p[#p + 1] = format(pick(T.quote, seed + 14), q.giverName, line)
        else
            p[#p + 1] = format(T.quoteAnon, line)
        end
    end
    if #p > 0 then paras[#paras + 1] = join(p, SPACE) end

    -- money, loot, levels
    p = {}
    if f.income > 0 or f.spend > 0 then
        local txt
        if f.net >= 0 then
            txt = format(pick(T.gain, seed + 9), self:CoinText(f.net))
        else
            txt = format(pick(T.loss, seed + 9), self:CoinText(-f.net))
        end
        local bestIn = sortedByValue(d.income, 1)[1]
        if bestIn and bestIn.v > 0 then
            txt = txt .. format(T.src, self:CatName(bestIn.k), self:CoinText(bestIn.v))
        end
        local bestOut = sortedByValue(d.spend, 1)[1]
        if bestOut and bestOut.v > 0 then
            txt = txt .. format(T.spent, self:CatName(bestOut.k), self:CoinText(bestOut.v))
        end
        p[#p + 1] = txt
        sections = sections + 1
    end
    if f.items[1] and f.items[1].q >= 2 then
        p[#p + 1] = format(pick(T.item, seed + 10), self:ItemName(f.items[1].link))
        sections = sections + 1
    end
    if #d.levels > 0 then
        local lv = {}
        for i, v in ipairs(d.levels) do lv[i] = tostring(v) end
        p[#p + 1] = format(pick(T.levels, seed + 11), listing(lv))
        sections = sections + 1
    end
    if #p > 0 then paras[#paras + 1] = join(p, SPACE) end

    -- today is still being written: no "quiet day", no "time for a break" yet
    local today = (idx == self:DayIndex()) and not self.demo
    if sections == 0 then paras[#paras + 1] = pick(today and T.begun or T.quiet, seed + 12) end

    -- closing
    if today then
        if sections > 0 then paras[#paras + 1] = pick(T.ongoing, seed + 13) end
    elseif (d.online or 0) >= 3600 then
        paras[#paras + 1] = format(pick(T.closeLong, seed + 13), self:DurationText(d.online))
    else
        paras[#paras + 1] = pick(T.close, seed + 13)
    end
    return join(paras, "\n\n")
end
