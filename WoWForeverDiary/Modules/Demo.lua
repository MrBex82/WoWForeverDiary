-- /wfd demo : fills the diary with invented data so the interface can be explored.
-- Demo data lives in memory only and never touches your real diary.
local ADDON, WFD = ...
local time, floor, format = time, math.floor, string.format
local L = WFD.L

local seed = 12345
local function rnd(a, b)
    seed = (seed * 1103515245 + 12345) % 2147483648
    local r = seed / 2147483648
    if not a then return r end
    return a + floor(r * (b - a + 1))
end

local MAPS = { 1429, 1436, 1431 }   -- Elwynn Forest, Westfall, Duskwood
local MOBS = {
    { 299, "Young Wolf", 2, "normal", "Beast" }, { 69, "Timber Wolf", 5, "normal", "Beast" },
    { 113, "Stonetusk Boar", 3, "normal", "Beast" }, { 6, "Kobold Vermin", 1, "normal", "Humanoid" },
    { 46, "Murloc Forager", 6, "normal", "Humanoid" }, { 471, "Mother Fang", 8, "rare", "Beast" },
    { 448, "Hogger", 11, "elite", "Humanoid", true }, { 94, "Defias Bandit", 9, "normal", "Humanoid" },
}
local NPCS = {
    { 823, "Deputy Willem" }, { 197, "Marshal McBride" }, { 54, "Gryan Stoutmantle" },
    { 951, "Brother Neals" }, { 233, "Innkeeper Farley" }, { 1241, "Morgg Rotnose" },
}
local QUESTS = {
    "A Threat Within", "Kobold Camp Cleanup", "Wolves Across the Border", "Princess Must Die!",
    "The Fargodeep Mine", "Bounty on Garrick Padfoot", "Brotherhood of Thieves", "Lost Necklace",
    "Report to Goldshire", "Gold Dust Exchange", "Stolen Supplies", "Shipment to Stormwind",
}
local ITEMS = {
    { 2092, "Worn Dagger", 1 }, { 1181, "Scroll of Strength", 2 }, { 1179, "Ice Cold Milk", 1 },
    { 1195, "Kobold Excavation Pick", 2 }, { 2071, "Medium Quiver", 3 },
}

local function build()
    seed = 12345
    local now = time()
    local C = {
        born = now - 8 * 86400, name = UnitName("player") or "Demo", realm = GetRealmName(),
        class = UnitClass("player") or "Warrior", race = UnitRace("player") or "Human",
        classFile = select(2, UnitClass("player")), startLevel = 1, fresh = true,
        days = {}, mobs = {}, npcs = {}, quests = {}, events = {}, zones = {}, skills = {}, nemesis = {},
        wealth = 0, levelTimes = {}, killTotal = 0, questTotal = 0, npcCount = 0, itemTotal = 0,
        startZone = nil, xpTotal = 0,
    }
    local real = WFD.C
    WFD.C = C
    for i, mid in ipairs(MAPS) do
        local name = WFD:MapName(mid)
        if i == 1 then C.startZone = name end
        C.zones[name] = { first = C.born, day = i, sub = {}, visits = 2 }
    end

    local level, money, qid = 1, 0, 1000
    for day = 1, 9 do
        local d = WFD:Day(day)
        local base = WFD:DayTime(day)
        local mapID = MAPS[1 + floor((day - 1) / 3)]
        local zone = WFD:MapName(mapID)
        d.zones[zone] = rnd(5000, 12000)
        d.online = d.zones[zone]
        d.t0 = base - 43200 + rnd(8, 19) * 3600
        d.t1 = d.t0 + d.online
        d.hours = { [tonumber(date("%H", d.t0))] = d.online }
        d.steps = rnd(4000, 12000)
        d.jumps = rnd(40, 400)
        d.g0 = money

        -- footsteps: a wandering path
        local x, y, vx, vy = 0.35 + rnd() * 0.3, 0.35 + rnd() * 0.3, 0, 0
        local p, kc = {}, {}
        d.path[mapID] = p
        d.kcells[mapID] = kc
        for _ = 1, 700 do
            vx = vx * 0.85 + (rnd() - 0.5) * 0.012
            vy = vy * 0.85 + (rnd() - 0.5) * 0.012
            x = math.min(0.92, math.max(0.08, x + vx))
            y = math.min(0.92, math.max(0.08, y + vy))
            local key = WFD:CellKey(x, y)
            p[key] = (p[key] or 0) + 1
            if rnd() < 0.05 then kc[key] = (kc[key] or 0) + 1 end
        end

        -- kills
        for _ = 1, rnd(4, 9) do
            local m = MOBS[rnd(1, #MOBS)]
            local id, name, lv, cls, ctype, boss = m[1], m[2], m[3], m[4], m[5], m[6]
            if not (boss and day < 4) and not (cls == "rare" and day < 2) then
                local n = rnd(2, 14)
                if boss or cls == "rare" then n = 1 end
                d.kills[id] = (d.kills[id] or 0) + n
                d.killTotal = d.killTotal + n
                local mob = C.mobs[id]
                if not mob then
                    mob = { name = name, kills = 0, first = base, level = lv, cls = cls, ctype = ctype, zone = zone, boss = boss }
                    C.mobs[id] = mob
                    if boss then
                        C.events[#C.events + 1] = { t = base + 40000, day = day, k = "boss", s = format(L["First victory over the boss %s!"], name), npc = id, gear = WFD:CaptureGear() }
                    elseif cls == "rare" then
                        C.events[#C.events + 1] = { t = base + 30000, day = day, k = "rare", s = format(L["Rare creature slain: %s"], name), npc = id, gear = WFD:CaptureGear() }
                    end
                end
                mob.kills = mob.kills + n
                mob.last = base + 50000
                C.killTotal = C.killTotal + n
            end
        end

        -- quests
        for _ = 1, rnd(2, 4) do
            qid = qid + 1
            local title = QUESTS[((qid - 1001) % #QUESTS) + 1]
            local npc = NPCS[rnd(1, #NPCS)]
            local acc = base + rnd(30000, 40000)
            C.quests[qid] = {
                title = title, level = level, zone = zone, giver = npc[1], turnin = NPCS[rnd(1, #NPCS)][1],
                acc = acc, done = acc + rnd(600, 5000), xp = rnd(100, 900), money = rnd(30, 600),
                map = mapID, x = 0.3 + rnd() * 0.4, y = 0.3 + rnd() * 0.4,
                dmap = mapID, dx = 0.3 + rnd() * 0.4, dy = 0.3 + rnd() * 0.4,
            }
            d.qa[#d.qa + 1] = qid
            d.qd[#d.qd + 1] = qid
            C.questTotal = C.questTotal + 1
        end

        -- npcs
        for i = 1, #NPCS do
            if rnd() < 0.7 then
                local n = NPCS[i]
                local npc = C.npcs[n[1]]
                if not npc then
                    npc = { name = n[2], talks = 0, first = base, roles = { quest = true, talk = (i % 2 == 0) or nil, merchant = (i == 5) or nil },
                            zone = zone, map = mapID, x = 0.3 + rnd() * 0.4, y = 0.3 + rnd() * 0.4 }
                    C.npcs[n[1]] = npc
                end
                local t = rnd(1, 5)
                npc.talks = npc.talks + t
                npc.last = base + 60000
                d.npcs[n[1]] = t
            end
        end

        -- money
        local inc, spend = rnd(2000, 30000), rnd(200, 15000)
        d.income.loot = floor(inc * 0.5)
        d.income.quest = floor(inc * 0.3)
        d.income.sell = floor(inc * 0.2)
        d.spend.repair = floor(spend * 0.4)
        d.spend.vendor = floor(spend * 0.4)
        d.spend.training = floor(spend * 0.2)
        money = money + inc - spend
        d.g1 = money
        if money > C.wealth then C.wealth = money end

        -- loot
        for _, it in ipairs(ITEMS) do
            if rnd() < 0.6 then
                d.loot[it[1]] = { link = "|cffffffff|Hitem:" .. it[1] .. "::::::::1:::::::|h[" .. it[2] .. "]|h|r", n = rnd(1, 4), q = it[3] }
            end
        end

        -- level ups and deaths
        d.xp = rnd(800, 3000)
        C.xpTotal = C.xpTotal + d.xp
        for _ = 1, rnd(0, 2) do
            level = level + 1
            d.levels[#d.levels + 1] = level
            C.levelTimes[level] = base + rnd(20000, 60000)
            C.events[#C.events + 1] = { t = C.levelTimes[level], day = day, k = "level", s = format(L["Level %d reached!"], level), gear = WFD:CaptureGear() }
        end
        d.deaths = rnd(0, 2)
        for _ = 1, d.deaths do
            local by = MOBS[rnd(1, #MOBS)][2]
            d.deathBy[#d.deathBy + 1] = by
            d.dpos[#d.dpos + 1] = { mapID, 0.3 + rnd() * 0.4, 0.3 + rnd() * 0.4 }
            local n = C.nemesis[by] or { n = 0 }
            n.n = n.n + 1
            n.zone = zone
            n.last = base + 70000
            C.nemesis[by] = n
            C.events[#C.events + 1] = { t = base + 70000 + _ * 60, day = day, k = "death", s = format(L["Died to %s in %s"], by, zone) }
        end
        if day % 3 == 1 and day > 1 then
            C.events[#C.events + 1] = { t = base + 20000, day = day, k = "zone", s = format(L["Discovered a new land: %s"], zone) }
        end
    end
    -- companions, trading partners and resting places
    C.companions = {
        Brannok = { name = "Brannok", class = "Paladin", classFile = "PALADIN", level = 7, first = C.born + 90000, last = now,
            days = { [2] = true, [3] = true, [5] = true }, kills = 64, groups = 3, zone = WFD:MapName(MAPS[1]) },
        Lyssa = { name = "Lyssa", class = "Mage", classFile = "MAGE", level = 9, first = C.born + 300000, last = now,
            days = { [4] = true }, kills = 21, groups = 1, zone = WFD:MapName(MAPS[2]) },
    }
    C.traders = { Brannok = { first = C.born + 95000, count = 2, got = 1500, gave = 0, zone = WFD:MapName(MAPS[1]) } }
    C.rests = {
        { t = C.born + 50000, map = MAPS[1], x = 0.42, y = 0.65, zone = WFD:MapName(MAPS[1]), sub = "Goldshire", dur = 30000 },
        { t = C.born + 400000, map = MAPS[2], x = 0.56, y = 0.47, zone = WFD:MapName(MAPS[2]), sub = "Sentinel Hill", dur = 50000 },
    }
    -- a dungeon run and tasks of the day, so the newer pages have something to show
    local loot = {}
    for _, it in ipairs(ITEMS) do
        if it[3] >= 2 then loot[#loot + 1] = "|cff1eff00|Hitem:" .. it[1] .. "::::::::1:::::::|h[" .. it[2] .. "]|h|r" end
    end
    local runStart = WFD:DayTime(6) - 43200 + 19 * 3600
    local bosses = { "Rhahk'Zor", "Sneed", "Gilnid", "Mr. Smite", "Captain Greenskin", "Edwin VanCleef" }
    C.runs = { {
        name = "The Deadmines", t0 = runStart, t1 = runStart + 5400, day = 6, level = level, kills = 142,
        party = {
            Brannok = { classFile = "PALADIN", class = "Paladin", level = 17 },
            Lyssa = { classFile = "MAGE", class = "Mage", level = 18 },
            Thorgar = { classFile = "WARRIOR", class = "Warrior", level = 18 },
            Elandra = { classFile = "PRIEST", class = "Priest", level = 17 },
        },
        bosses = bosses,
        deaths = { { who = "Lyssa" }, { who = C.name, me = true, by = "Mr. Smite" } },
        loot = loot,
        last = { name = "Edwin VanCleef", gear = WFD:CaptureGear(), npc = 639, t = runStart + 5300 },
    } }
    C.instances = { ["The Deadmines"] = runStart }
    C.encounters = {}
    for _, b in ipairs(bosses) do C.encounters[b] = 1 end
    C.challenges = {}
    for day = 6, 9 do
        local list = { { k = "kills", goal = 30 }, { k = "quests", goal = 2 }, { k = "places", goal = 1 } }
        local done = { [1] = WFD:DayTime(day), [2] = WFD:DayTime(day) }
        if day < 9 then done[3] = WFD:DayTime(day) end
        C.challenges[day] = { list = list, done = done, all = day < 9 and WFD:DayTime(day) or nil }
    end
    -- first times, a task of the week, letters in the time capsule, gathering spots, quest givers' words
    local function at(day, h) return WFD:DayTime(day) - 43200 + h * 3600 end
    C.firsts = {
        kill = { t = at(1, 10), day = 1, zone = WFD:MapName(MAPS[1]), s = "Kobold Vermin" },
        quest = { t = at(1, 11), day = 1, zone = WFD:MapName(MAPS[1]), s = QUESTS[1] },
        level = { t = at(1, 12), day = 1, zone = WFD:MapName(MAPS[1]), s = format(L["Level %d reached!"], 2) },
        green = { t = at(2, 14), day = 2, zone = WFD:MapName(MAPS[1]), s = "Medium Quiver" },
        death = { t = at(2, 16), day = 2, zone = WFD:MapName(MAPS[1]), s = "Kobold Vermin" },
        group = { t = at(2, 18), day = 2, zone = WFD:MapName(MAPS[1]), s = "Brannok" },
        trade = { t = at(2, 19), day = 2, zone = WFD:MapName(MAPS[1]), s = "Brannok" },
        flight = { t = at(5, 20), day = 5, zone = WFD:MapName(MAPS[2]), s = "Stormwind" },
        dungeon = { t = runStart, day = 6, zone = WFD:MapName(MAPS[2]), s = "The Deadmines" },
        boss = { t = runStart + 600, day = 6, zone = WFD:MapName(MAPS[2]), s = "Rhahk'Zor" },
    }
    C.weekly = { [2] = { task = { k = "wkills", goal = 150 } }, [1] = { task = { k = "wquests", goal = 12 }, done = at(6, 21) } }
    C.monthly = { [1] = { task = { k = "mkills", goal = 500 } } }
    C.capsules = {
        { t = at(1, 22), day = 1, level = 1, openDay = 7, opened = at(7, 9),
          text = L["Dear me, if you are reading this, you made it through the first week. Did you ever find out who was stealing the candles in the mine?"] },
        { t = at(5, 22), day = 5, level = 8, openLevel = 20, text = "sealed" },
    }
    C.gather = {}
    local HERBS = { "Peacebloom", "Silverleaf", "Earthroot" }
    for i = 1, 40 do
        local map = MAPS[1 + (i % 2)]
        C.gather[map] = C.gather[map] or {}
        local kind = (i % 3 == 0) and "ore" or "herb"
        C.gather[map][#C.gather[map] + 1] = { x = 0.2 + rnd() * 0.6, y = 0.2 + rnd() * 0.6, k = kind, t = at(1 + i % 8, 12), day = 1 + i % 8,
            item = kind == "ore" and "Copper Ore" or HERBS[1 + i % 3] }
    end
    local n = 0
    for _, q in pairs(C.quests) do
        n = n + 1
        if n % 2 == 1 then
            q.quote = "The Defias grow bolder every day. Yesterday they robbed a supply wagon right outside our gates!"
            q.giverName = "Gryan Stoutmantle"
        end
    end
    -- seen, not slain: covered cards in the bestiary
    local elwynn = WFD:MapName(1429)
    C.sighted = {
        [30] = { n = "Forest Spider", z = elwynn, lv = 5, cls = "normal", m = 1429, x = 0.78, y = 0.42 },
        [100] = { n = "Gruff Swiftbite", z = elwynn, lv = 12, cls = "rare", m = 1429, x = 0.22, y = 0.80 },
    }
    C.fishCaught = 12
    -- an angler's log: a few catches on two waters, a rod
    local lake, shore = MAPS[1], MAPS[2]
    C.catch = {
        [6291] = { name = "Raw Brilliant Smallfish", n = 14, q = 1, kind = "fish", first = at(2, 11), last = at(8, 14), day = 2,
            zones = { [lake] = 14 } },
        [6289] = { name = "Raw Longjaw Mud Snapper", n = 9, q = 1, kind = "fish", first = at(3, 10), last = at(7, 15), day = 3,
            zones = { [lake] = 9 } },
        [6308] = { name = "Raw Bristle Whisker Catfish", n = 4, q = 1, kind = "fish", first = at(5, 12), last = at(8, 9), day = 5,
            zones = { [shore] = 4 } },
        [6309] = { name = "17 Pound Catfish", n = 1, q = 1, kind = "other", first = at(6, 13), last = at(6, 13), day = 6,
            zones = { [shore] = 1 } },
        [6362] = { name = "Raw Rockscale Cod", n = 3, q = 1, kind = "fish", first = at(7, 16), last = at(8, 17), day = 7,
            zones = { [shore] = 3 } },
        [6352] = { name = "Waterlogged Crate", n = 1, q = 1, kind = "other", first = at(2, 12), last = at(2, 12), day = 2,
            zones = { [lake] = 1 } },
        [6458] = { name = "Oil Covered Fish", n = 2, q = 0, kind = "junk", first = at(4, 13), last = at(5, 13), day = 4,
            zones = { [lake] = 2 } },
        [21228] = { name = "Mithril Bound Trunk", n = 1, q = 3, kind = "treasure", first = at(8, 18), last = at(8, 18), day = 8,
            zones = { [shore] = 1 } },
    }
    C.catchTotal, C.catchCasts, C.catchLured = 34, 52, 11
    C.catchZone = { [lake] = { casts = 30, loot = 26 }, [shore] = { casts = 22, loot = 8 } }
    C.tackle = {
        [6256] = { n = 52, kind = "rod", name = "Fishing Pole", first = at(2, 12) },
        [6529] = { n = 11, kind = "lure", name = "Shiny Bauble", first = at(5, 12) },
        [19972] = { n = 20, kind = "gear", name = "Lucky Fishing Hat", first = at(6, 13) },
    }
    -- an invented family for the family book
    local function sibling(name, race, class, classFile, level, days, kills, quests)
        return { name = name, realm = C.realm, race = race, class = class, classFile = classFile, level = level,
            days = days, kills = kills, deaths = 2, quests = quests, km = days * 4.2, online = days * 7000,
            points = level * 9, firsts = {}, levels = { [10] = 3 }, last = now - 86400 * 2 }
    end
    C.demoFamily = {
        [(C.realm or "?") .. "-" .. (C.name or "?")] = sibling(C.name, C.race, C.class, C.classFile, 12, 9, 408, 18),
        ["Mirelle"] = sibling("Mirelle", "Night Elf", "Hunter", "HUNTER", 23, 21, 1240, 64),
        ["Tobin"] = sibling("Tobin", "Dwarf", "Priest", "PRIEST", 11, 6, 233, 15),
    }
    local function skill(id, en) return WFD:SpellName(id) or en end
    C.skills[skill(7620, "Fishing")], C.skills[skill(3273, "First Aid")], C.skills[skill(2550, "Cooking")] = 82, 40, 115
    WFD.C = real
    return C
end

function WFD:ToggleDemo()
    if self.demo then
        self.C = self.realC
        self.paused = false
        self.demo = nil
        print("|cffffd100WoW Forever Diary:|r " .. WFD.L["Demo mode is off."])
    else
        local ok, C = pcall(build)
        if not ok then
            WFD.C = WFD.realC
            WFD:Error("demo", C)
            return
        end
        self.C = C
        self.paused = true
        self.demo = true
        print("|cffffd100WoW Forever Diary:|r " .. WFD.L["Demo mode is on. Nothing you do now is written into your diary - type /wfd demo again to leave."])
    end
    if self.UI then
        self.UI:DataSwitched()
        self.UI:Show()
    end
end
