-- WoW Forever Diary - Core: event bus, saved data, day logic, shared helpers
local ADDON, WFD = ...
_G.WoWForeverDiary = WFD

local floor, min, format = math.floor, math.min, string.format
local time, date = time, date

WFD.version = "0.2.5"
WFD.gameLocale = GetLocale()
WFD.locale = WFD.gameLocale
WFD.isDE = (WFD.locale == "deDE")

-- Localisation: English phrases are the keys. Each Locales\*.lua fills its own tables via WFD:NewLocale();
-- the chosen language (WFDiaryDB.language, default: game language) is copied into L and WFD.loc at ADDON_LOADED.
local L = setmetatable({}, { __index = function(_, k) return k end })
WFD.L = L

-- selectable languages, in display order
WFD.languages = { "enUS", "deDE", "frFR", "esES", "ptBR", "ruRU", "koKR", "zhTW" }
local locales = {}

local loc = {
    date = "%m/%d/%Y",
    dayMonth = "%m/%d",
    weekdays = { "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" },
    months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" },
}
-- d is a date("*t") table
function loc.longDate(d)
    return format("%s, %s %d, %d", loc.weekdays[d.wday], loc.months[d.month], d.day, d.year)
end
WFD.loc = loc

-- Returns the translation table, the format table (falls back to the English formats)
-- and extra(code), a table of overrides for just one of the codes (e.g. esMX).
function WFD:NewLocale(codes)
    if type(codes) == "string" then codes = { codes } end
    local tl, tloc = {}, setmetatable({}, { __index = loc })
    for _, code in ipairs(codes) do locales[code] = { L = tl, loc = tloc, extra = {} } end
    return tl, tloc, function(code) return locales[code].extra end
end

-- the translations of one language (nil for a language without a file), and every language with a file
function WFD:LocaleStrings(code) return locales[code] and locales[code].L end
function WFD:LocaleCodes()
    local list = {}
    for code in pairs(locales) do list[#list + 1] = code end
    table.sort(list)
    return list
end

function WFD:ApplyLanguage(code)
    if not locales[code] then code = "enUS" end
    local def = locales[code]
    if def then
        for k, v in pairs(def.L) do L[k] = v end
        for k, v in pairs(def.extra) do L[k] = v end
        for k, v in pairs(def.loc) do loc[k] = v end
    end
    self.locale, self.isDE = code, (code == "deDE")
    if self.UI and self.UI.ApplyScriptFonts then self.UI.ApplyScriptFonts(code) end
end

function WFD:GetGameLanguage() return self.gameLocale end

------------------------------------------------------------------------
-- Event bus
------------------------------------------------------------------------
local handlers = {}
local initFns = {}
local evf = CreateFrame("Frame")
WFD.evf = evf

local seenErrors = {}
function WFD:Error(where, err)
    local key = tostring(err)
    if seenErrors[key] then return end
    seenErrors[key] = true
    print("|cffff5555WoW Forever Diary|r error in " .. tostring(where) .. ": " .. key)
end

-- Registers fn(event, ...) for a game event. Unknown events are ignored silently.
function WFD:On(event, fn)
    local h = handlers[event]
    if not h then
        h = {}
        handlers[event] = h
        if not pcall(evf.RegisterEvent, evf, event) then
            handlers[event] = nil
            return
        end
    end
    h[#h + 1] = fn
end

-- Internal signals between modules: "kill", "death", "loot", "milestone" ...
local signals = {}
function WFD:OnSignal(name, fn)
    local s = signals[name]
    if not s then
        s = {}
        signals[name] = s
    end
    s[#s + 1] = fn
end

function WFD:Signal(name, ...)
    local s = signals[name]
    if not s then return end
    for i = 1, #s do
        local ok, err = pcall(s[i], ...)
        if not ok then self:Error("signal " .. name, err) end
    end
end

-- Registers fn() to run once the character data is ready (PLAYER_LOGIN).
function WFD:OnInit(fn) initFns[#initFns + 1] = fn end

evf:SetScript("OnEvent", function(_, event, ...)
    local h = handlers[event]
    if not h then return end
    for i = 1, #h do
        local ok, err = pcall(h[i], event, ...)
        if not ok then WFD:Error(event, err) end
    end
end)

-- If the game refuses a call, note which one (/wfd geblockt lists them); a refused screenshot turns screenshots off.
-- Everything is kept, from the very first line on, even refusals that happen while the addons are still loading.
WFD.blockedLog = {}
local function refused(event, addon, fn)
    fn = tostring(fn or "?")
    local entry = { fn = fn, addon = tostring(addon), t = time(), event = event, loaded = WFD.S ~= nil }
    table.insert(WFD.blockedLog, 1, entry)
    while #WFD.blockedLog > 20 do table.remove(WFD.blockedLog) end
    if WFD.S then
        WFD.S.blocked = WFD.S.blocked or {}
        table.insert(WFD.S.blocked, 1, entry)
        while #WFD.S.blocked > 8 do table.remove(WFD.S.blocked) end
    end
    if addon ~= ADDON then return end
    if fn:find("Screenshot") and WFD.S then
        WFD.S.screenshots = false
        WFD.S.shotBlocked = true
        print("|cffffd100WoW Forever Diary:|r " .. L["This game client does not allow addons to take screenshots. Screenshots at milestones are now switched off."])
    else
        print("|cffffd100WoW Forever Diary:|r " .. format(L["The game blocked the function %s. Please tell the author."], fn))
    end
end
WFD:On("ADDON_ACTION_FORBIDDEN", refused)
WFD:On("ADDON_ACTION_BLOCKED", refused)

------------------------------------------------------------------------
-- Saved variables
------------------------------------------------------------------------
WFD:On("ADDON_LOADED", function(_, name)
    if name ~= ADDON then return end
    WFDiaryDB = WFDiaryDB or {}
    local S = WFDiaryDB
    if S.screenshots == nil then S.screenshots = true end
    if S.chat == nil then S.chat = false end
    if S.minimap == nil then S.minimap = true end
    if S.toasts == nil then S.toasts = true end
    if S.recap == nil then S.recap = true end
    if S.cover == nil then S.cover = true end
    if S.memoryPage == nil then S.memoryPage = true end
    if S.memoryToast == nil then S.memoryToast = true end
    S.angle = S.angle or 215
    S.scale = S.scale or 0.9
    WFD.S = S
    -- refusals that happened before the settings were loaded
    S.blocked = S.blocked or {}
    for i = #WFD.blockedLog, 1, -1 do
        local e = WFD.blockedLog[i]
        if not e.loaded then
            e.loaded = true
            table.insert(S.blocked, 1, e)
        end
    end
    WFD:ApplyLanguage(S.language or WFD.gameLocale)
    -- the key binding (Bindings.xml) as the game's key binding list shows it
    _G.BINDING_HEADER_WOWFOREVERDIARY = "WoW Forever Diary"
    _G.BINDING_NAME_WOWFOREVERDIARY_TOGGLE = (L["open or close the diary"]:gsub("^%l", string.upper))
    WFDiaryChar = WFDiaryChar or {}
end)

WFD:On("PLAYER_LOGIN", function()
    local C = WFDiaryChar
    -- A new character with the name of a deleted one finds that one's diary (the game keeps it by name).
    -- The GUID tells them apart; diaries from before it was kept are checked by class.
    -- The old diary is not thrown away but put aside (only the last one), /wfd restore brings it back.
    local guid = UnitGUID("player")
    local _, classFile = UnitClass("player")
    if C.born and ((C.guid and guid and C.guid ~= guid) or (not C.guid and C.classFile and classFile and C.classFile ~= classFile)) then
        C.previous = nil
        WFDiaryChar = { previous = C }
        C = WFDiaryChar
        WFD.startedOver = true
    end
    C.guid = C.guid or guid
    if not C.born then
        C.born = time()
        C.name = UnitName("player")
        C.realm = GetRealmName()
        C.class, C.classFile = UnitClass("player")
        C.race = UnitRace("player")
        C.startLevel = UnitLevel("player")
        C.fresh = (UnitLevel("player") == 1 and UnitXP("player") == 0)
    end
    C.days = C.days or {}
    C.mobs = C.mobs or {}
    C.npcs = C.npcs or {}
    C.quests = C.quests or {}
    C.events = C.events or {}
    C.zones = C.zones or {}
    C.skills = C.skills or {}
    C.nemesis = C.nemesis or {}
    C.wealth = C.wealth or 0
    WFD.realC = C
    WFD.C = C
    WFD.ready = true
    for i = 1, #initFns do
        local ok, err = pcall(initFns[i])
        if not ok then WFD:Error("init", err) end
    end
    if WFD.startedOver then
        print("|cffffd100WoW Forever Diary:|r " .. L["The diary found here belonged to an earlier character of the same name. It has been put aside and a new diary has been started for you. |cffffd100/wfd restore|r brings it back."])
    end
    local idx = WFD:DayIndex()
    local msg = L["Travel diary active - today is |cffffd100day %d|r. |cffffd100/wfd|r opens the diary."]
    print("|cffffd100WoW Forever Diary:|r " .. format(msg, idx))
end)

------------------------------------------------------------------------
-- Days
------------------------------------------------------------------------
local function noon(t)
    local d = date("*t", t)
    return time({ year = d.year, month = d.month, day = d.day, hour = 12, min = 0, sec = 0 })
end

-- Day 1 is the calendar day the character was born.
function WFD:DayIndex(t)
    local C = self.C
    if not C then return 1 end
    return floor((noon(t or time()) - noon(C.born)) / 86400 + 0.5) + 1
end

function WFD:DayTime(idx) return noon(self.C.born) + (idx - 1) * 86400 end

function WFD:DateStr(idx)
    return date(self.loc.date, self:DayTime(idx))
end

function WFD:Day(idx)
    local C = self.C
    idx = idx or self:DayIndex()
    local d = C.days[idx]
    if not d then
        d = {
            kills = {}, killTotal = 0, qa = {}, qd = {}, npcs = {},
            income = {}, spend = {}, loot = {}, zones = {}, deaths = 0, xp = 0,
            online = 0, steps = 0, jumps = 0, path = {}, kcells = {}, dpos = {},
            levels = {}, instances = {}, flights = 0, deathBy = {},
        }
        C.days[idx] = d
    end
    return d
end

function WFD:NumDays() return self:DayIndex() end

-- the area a day spent the longest time in
function WFD:MainZone(d)
    local best, bestT
    for z, t in pairs(d and d.zones or {}) do
        if not bestT or t > bestT then best, bestT = z, t end
    end
    return best
end

-- the level at a moment, from the times the levels were reached
function WFD:LevelAt(t)
    local C = self.C
    local lvl = C.startLevel or 1
    for l, tt in pairs(C.levelTimes or {}) do
        if tt <= t and l > lvl then lvl = l end
    end
    return lvl
end

------------------------------------------------------------------------
-- Logging
------------------------------------------------------------------------
-- Something worth a line happened. The lines themselves are not kept (no page shows them, and they made up
-- a third of the saved file); what matters is stored by the trackers in their own records.
function WFD:Log(kind, text)
    if self.paused or not self.C then return end
    self.dirty = true
end

------------------------------------------------------------------------
-- Footsteps of past days, packed into a string: five letters per map cell (cell number in three,
-- how often it was walked in two). A table of cells is about five times larger in the saved file.
------------------------------------------------------------------------
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local VAL = {}
for i = 1, 64 do VAL[B64:byte(i)] = i - 1 end
local function letter(n) return B64:sub(n + 1, n + 1) end

function WFD:PackCells(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    local out = {}
    for i, k in ipairs(keys) do
        local v = min(4095, floor((t[k] or 0) + 0.5))
        out[i] = letter(floor(k / 4096)) .. letter(floor(k / 64) % 64) .. letter(k % 64) .. letter(floor(v / 64)) .. letter(v % 64)
    end
    return table.concat(out)
end

-- the cells of a map on one day as a table, whether stored packed or not
local unpacked = setmetatable({}, { __mode = "v" })
function WFD:PathCells(p)
    if type(p) ~= "string" then return p end
    local t = unpacked[p]
    if t then return t end
    t = {}
    for i = 1, #p - 4, 5 do
        local a, b, c, d, e = p:byte(i, i + 4)
        t[VAL[a] * 4096 + VAL[b] * 64 + VAL[c]] = VAL[d] * 64 + VAL[e]
    end
    unpacked[p] = t
    return t
end

function WFD:SumCells(p)
    local n = 0
    if type(p) == "string" then
        for i = 4, #p - 1, 5 do
            local d, e = p:byte(i, i + 1)
            n = n + VAL[d] * 64 + VAL[e]
        end
    elseif type(p) == "table" then
        for _, v in pairs(p) do n = n + v end
    end
    return n
end

-- at login: days gone by are packed, their old log lines dropped. Today stays a table, it is still being walked.
function WFD:PackOldDays()
    local C = self.C
    if not C or not C.days then return end
    local today = self:DayIndex()
    for idx, d in pairs(C.days) do
        d.log = nil
        if idx < today then
            -- footsteps and the places of the kills: both cell -> count
            for _, cells in ipairs({ d.path or {}, d.kcells or {} }) do
                for map, p in pairs(cells) do
                    if type(p) == "table" then cells[map] = self:PackCells(p) end
                end
            end
        end
    end
end

-- Milestones feed the lifeline band, the narrator and (optionally) take a screenshot.
-- Remembers what the character wore, so the diary can paint the moment later.
function WFD:CaptureGear()
    local gear = {}
    if not GetInventoryItemID then return gear end
    for slot = 1, 19 do
        local id = GetInventoryItemID("player", slot)
        if id then gear[slot] = id end
    end
    return gear
end

-- a death, or the first death among the first times: kept in the diary, never announced
function WFD:IsDeathEvent(ev)
    return ev and (ev.k == "death" or (ev.k == "first" and ev.first == "death")) or false
end

function WFD:Milestone(kind, text, shot, extra)
    if self.paused or not self.C then return end
    local ev = { t = time(), day = self:DayIndex(), k = kind, s = text }
    if extra then for k, v in pairs(extra) do ev[k] = v end end
    if shot then
        ev.gear = self:CaptureGear()
        local map, x, y = self:PlayerPos()
        if map then ev.map, ev.x, ev.y = map, x, y end
    end
    local list = self.C.events
    list[#list + 1] = ev
    self:Log("milestone", text)
    self:Signal("milestone", ev)
    if self.S and self.S.chat and not self:IsDeathEvent(ev) and (not self.ShouldNotify or self:ShouldNotify(kind)) then
        print("|cffffd100[" .. L["Diary"] .. "]|r " .. text)
    end
    if shot and self.S and self.S.screenshots and not self.S.shotBlocked then
        C_Timer.After(0.8, function()
            -- the game names the file by the moment and the format chosen in its settings
            local fmt = C_CVar and C_CVar.GetCVar and C_CVar.GetCVar("screenshotFormat") or (GetCVar and GetCVar("screenshotFormat"))
            local ext = ({ jpeg = "jpg", jpg = "jpg", png = "png", tga = "tga" })[strlower(tostring(fmt or ""))] or "jpg"
            ev.shot = "WoWScrnShot_" .. date("%m%d%y_%H%M%S") .. "." .. ext
            Screenshot()
        end)
    end
    self.dirty = true
    return ev
end

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------
function WFD:CoinText(c)
    c = floor(c or 0)
    local neg = c < 0
    if neg then c = -c end
    local g, s, k = floor(c / 10000), floor((c % 10000) / 100), c % 100
    local G, S, K = GOLD_AMOUNT_SYMBOL or "g", SILVER_AMOUNT_SYMBOL or "s", COPPER_AMOUNT_SYMBOL or "c"
    -- "1G" rather than "1G 0S 0K"
    local parts = {}
    if g > 0 then parts[#parts + 1] = g .. G end
    if s > 0 then parts[#parts + 1] = s .. S end
    if k > 0 or #parts == 0 then parts[#parts + 1] = k .. K end
    return (neg and "-" or "") .. table.concat(parts, " ")
end

-- money in words for a sentence ("23 Silber 47 Kupfer"), with the game's own words; only the two largest
-- coins, so it stays readable. Without those words in the client: the short form.
function WFD:CoinWords(c)
    c = floor(math.abs(c or 0))
    local G, S, K = GOLD_AMOUNT, SILVER_AMOUNT, COPPER_AMOUNT
    if not (G and S and K) then return self:CoinText(c) end
    local g, s, k = floor(c / 10000), floor((c % 10000) / 100), c % 100
    local parts = {}
    if g > 0 then
        parts[1] = format(G, g)
        if s > 0 then parts[2] = format(S, s) end
    elseif s > 0 then
        parts[1] = format(S, s)
        if k > 0 then parts[2] = format(K, k) end
    else
        parts[1] = format(K, k)
    end
    return table.concat(parts, " ")
end

-- Counted texts: a translation may write "{Kill|Kills}" (Russian "{one|few|many}"), and each braced group takes
-- the form for the number before it (or after it, when none comes before). The English wordings live here,
-- since English keys are their own text.
local COUNTED_EN = {
    ["%d kills"] = "%d {kill|kills}",
    ["%d quests"] = "%d {quest|quests}",
    ["%d days"] = "%d {day|days}",
    ["%d casts"] = "%d {cast|casts}",
    ["%d caught in %d casts"] = "%d caught in %d {cast|casts}",
    ["%d kills today"] = "%d {kill|kills} today",
    ["%d quests today"] = "%d {quest|quests} today",
    ["%d kinds  -  %d slain"] = "%d {kind|kinds}  -  %d slain",
    ["%d days  -  %d kills  -  %d quests"] = "%d {day|days}  -  %d {kill|kills}  -  %d {quest|quests}",
    ["%d days of life  -  %d creatures slain  -  %d quests completed"] =
        "%d {day|days} of life  -  %d {creature|creatures} slain  -  %d {quest|quests} completed",
    ["%d enemies fell that day."] = "%d {enemy|enemies} fell that day.",
    ["%d kills together"] = "%d {kill|kills} together",
    ["%d treasures collected"] = "%d {treasure|treasures} collected",
    ["%d tiers earned"] = "%d {tier|tiers} earned",
    ["in %d days"] = "in %d {day|days}",
    ["%d characters on this account"] = "%d {character|characters} on this account",
    ["%d books on the shelf"] = "%d {book|books} on the shelf",
    ["Spoken to %d times"] = "Spoken to %d {time|times}",
    ["Slain %d times"] = "Slain %d {time|times}",
    ["Killed you %d times"] = "Killed you %d {time|times}",
    ["You slew them %d times."] = "You slew them %d {time|times}.",
    ["Got you %d times."] = "Got you %d {time|times}.",
    ["%d times grouped"] = "%d {time|times} grouped",
}

function WFD:Count(key, ...)
    local text = rawget(L, key) or COUNTED_EN[key] or key
    local args, out, pos, argi, lastN = { ... }, {}, 1, 0, nil
    while true do
        local a, b, tok = text:find("(%%[%-%d%.]*[dsf%%])", pos)
        local c, d = text:find("%b{}", pos)
        if not a and not c then break end
        if a and (not c or a < c) then
            out[#out + 1] = text:sub(pos, b)
            if tok ~= "%%" then
                argi = argi + 1
                if tok:sub(-1) == "d" then lastN = args[argi] end
            end
            pos = b + 1
        else
            out[#out + 1] = text:sub(pos, c - 1)
            local n = tonumber(lastN or args[argi + 1]) or 0
            local forms = {}
            for f in (text:sub(c + 1, d - 1) .. "|"):gmatch("([^|]*)|") do forms[#forms + 1] = f end
            local i = (#forms >= 3 and self.loc.plural) and self.loc.plural(n) or (n == 1 and 1 or #forms)
            out[#out + 1] = forms[i] or forms[#forms]
            pos = d + 1
        end
    end
    out[#out + 1] = text:sub(pos)
    return format(table.concat(out), ...)
end

-- a whole number with the thousands mark of the diary language (28,223 / 28.223 / 28 223)
function WFD:Int(v)
    local s = format("%.0f", math.abs(v or 0))
    local sep = (self.loc and self.loc.thousands) or ","
    s = s:reverse():gsub("(%d%d%d)", "%1" .. sep:reverse()):reverse()
    if s:sub(1, #sep) == sep then s = s:sub(#sep + 1) end
    return ((v or 0) < 0 and "-" or "") .. s
end

-- a number with one decimal, written the way the diary language writes it (3.2 or 3,2)
function WFD:Dec(v)
    local s = format("%.1f", v or 0):gsub("%.0$", "")   -- 7 km rather than 7.0 km
    local sep = self.loc and self.loc.decimal
    return sep and (s:gsub("%.", sep)) or s
end

-- a quotation in the marks of the diary language ("..." or „...")
function WFD:Quote(s)
    local q = self.loc and self.loc.quotes
    return (q and q[1] or "\"") .. tostring(s or "") .. (q and q[2] or "\"")
end

-- case: "in" (where), "to" (where to), "over" (above). Languages without loc.place keep the name as it is,
-- their sentences carry the preposition themselves.
function WFD:Place(name, case)
    local f = self.loc and self.loc.place
    if f and type(name) == "string" and name ~= "" and name ~= "?" then return f(name, case or "in") end
    return name
end

-- the name of a spell; newer clients only know C_Spell, older ones only GetSpellInfo
function WFD:SpellName(id)
    if not id then return nil end
    if C_Spell and C_Spell.GetSpellName then
        local ok, n = pcall(C_Spell.GetSpellName, id)
        if ok and type(n) == "string" and n ~= "" then return n end
    end
    if C_Spell and C_Spell.GetSpellInfo then
        local ok, info = pcall(C_Spell.GetSpellInfo, id)
        if ok and type(info) == "table" and info.name then return info.name end
    end
    if GetSpellInfo then
        local n = GetSpellInfo(id)
        if type(n) == "string" and n ~= "" then return n end
    end
end

-- A marker on the world map (the game's own map pin; TomTom too, if it is installed). Returns true if one was set.
function WFD:SetMapMarker(map, x, y, title)
    if not (map and x and y) then return false end
    local done = false
    local tt = _G.TomTom
    if tt and tt.AddWaypoint then
        done = pcall(tt.AddWaypoint, tt, map, x, y, { title = title, from = "WoW Forever Diary" }) or done
    end
    if C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates
        and (not C_Map.CanSetUserWaypointOnMap or C_Map.CanSetUserWaypointOnMap(map)) then
        local ok = pcall(C_Map.SetUserWaypoint, UiMapPoint.CreateFromCoordinates(map, x, y))
        if ok and C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
            pcall(C_SuperTrack.SetSuperTrackedUserWaypoint, true)
        end
        done = ok or done
    end
    if done then
        print("|cffffd100WoW Forever Diary:|r " .. format(L["Marker set on the map: %s (%d, %d)"],
            title or self:MapName(map), floor(x * 100 + 0.5), floor(y * 100 + 0.5)))
    else
        print("|cffffd100WoW Forever Diary:|r " .. L["No marker can be set on this map."])
    end
    return done
end

function WFD:Sum(tbl)
    local n = 0
    for _, v in pairs(tbl) do n = n + (type(v) == "number" and v or 0) end
    return n
end

function WFD:PlayerPos()
    if not (C_Map and C_Map.GetBestMapForUnit) then return end
    local map = C_Map.GetBestMapForUnit("player")
    if not map then return end
    local pos = C_Map.GetPlayerMapPosition(map, "player")
    if not pos then return end
    local x, y = pos:GetXY()
    if not x or (x == 0 and y == 0) then return end
    return map, x, y
end

function WFD:CellKey(x, y)
    return min(99, floor(x * 100)) * 100 + min(99, floor(y * 100))
end

function WFD:MapName(mapID)
    local info = C_Map and C_Map.GetMapInfo and C_Map.GetMapInfo(mapID)
    return info and info.name or ("Map " .. tostring(mapID))
end

function WFD:ParseGUID(guid)
    if not guid then return end
    local kind, _, _, _, _, id = strsplit("-", guid)
    return kind, tonumber(id)
end

function WFD:ItemName(link)
    return link and link:match("%[(.-)%]") or "?"
end

function WFD:DurationText(sec)
    sec = floor(sec or 0)
    local h, m = floor(sec / 3600), floor((sec % 3600) / 60)
    if h > 0 then return format(L["%dh %02dm"], h, m) end
    return format(L["%dm"], m)
end

-- Converts a Blizzard format string (e.g. "You receive loot: %s.") into a match pattern.
function WFD:Pattern(gs)
    if not gs then return nil end
    gs = gs:gsub("%%(%d)%$([sd])", "%%%2")   -- positional args (%1$s) as used by some locales
    local p = gs:gsub("([%(%)%.%[%]%+%-%*%?%^%$])", "%%%1")
    p = p:gsub("%%s", "(.-)")
    p = p:gsub("%%d", "(%%d+)")
    return "^" .. p .. "$"
end

-- Swaps the diary with the one put aside (an earlier character of the same name, or the diary
-- replaced by a moving code); the current one is put aside in turn, so the swap can be undone.
function WFD:RestorePrevious()
    if self.demo then
        print("|cffffd100WoW Forever Diary:|r " .. L["Leave demo mode first."])
        return
    end
    local cur = WFDiaryChar
    local old = cur and cur.previous
    if type(old) ~= "table" or not old.born then
        print("|cffffd100WoW Forever Diary:|r " .. L["No diary has been put aside."])
        return
    end
    cur.previous = nil
    old.previous = cur.born and cur or nil
    -- it belongs to this character now, or it would be put aside again at the next login
    old.guid = UnitGUID("player") or old.guid
    WFDiaryChar = old
    self.paused = true          -- nothing more is written into the diary that was just put aside
    print("|cffffd100WoW Forever Diary:|r " .. L["The diary put aside is back. The interface is reloaded."])
    ReloadUI()
end

------------------------------------------------------------------------
-- Slash commands
------------------------------------------------------------------------
SLASH_WOWFOREVERDIARY1 = "/wfd"
SLASH_WOWFOREVERDIARY2 = "/tagebuch"
SLASH_WOWFOREVERDIARY3 = "/diary"
SlashCmdList["WOWFOREVERDIARY"] = function(msg)
    msg = strlower(strtrim(msg or ""))
    if not WFD.ready then return end
    if msg == "" or msg == "show" then
        WFD.UI:Toggle()
    elseif msg == "demo" then
        WFD:ToggleDemo()
    elseif msg == "shot" then
        WFD.S.screenshots = not WFD.S.screenshots
        print("|cffffd100WoW Forever Diary:|r " .. (WFD.S.screenshots and L["Screenshots at milestones: on"] or L["Screenshots at milestones: off"]))
    elseif msg == "minimap" then
        WFD.S.minimap = not WFD.S.minimap
        WFD.UI:UpdateMinimapButton()
    elseif msg == "blocked" or msg == "geblockt" then
        local list = WFD.S.blocked or {}
        if #list == 0 then print("|cffffd100WoW Forever Diary:|r -") end
        for _, b in ipairs(list) do
            print("|cffffd100WoW Forever Diary:|r " .. date("%d.%m. %H:%M:%S", b.t) .. "  " .. tostring(b.event) .. "  " .. tostring(b.addon) .. "  " .. b.fn)
        end
    elseif msg == "recap" or msg == "woche" then
        WFD.UI:ShowRecap(true)
    elseif msg == "memory" or msg == "erinnerung" then
        WFD.UI:ShowMemory(true)
    elseif msg == "companion" and WFD.UI.ShowCompanion then
        WFD.UI:ShowCompanion()
    elseif msg == "export" and WFD.UI.ShowMovingExport then
        WFD.UI:ShowMovingExport()
    elseif msg == "import" and WFD.UI.ShowMovingImport then
        WFD.UI:ShowMovingImport()
    elseif msg == "killdebug" and WFD.KillDebug then
        WFD:KillDebug()
    elseif msg == "restore" then
        WFD:RestorePrevious()
    elseif msg == "help" then
        for _, h in ipairs({ { "/wfd", "open or close the diary" }, { "/wfd demo", "explore with invented data" },
            { "/wfd shot", "screenshots on or off" }, { "/wfd minimap", "minimap button on or off" },
            { "/wfd export", "moving code of this character" }, { "/wfd import", "read a moving code" },
            { "/wfd companion", "show or hide the companion" },
            { "/wfd memory", "show today's memory again" }, { "/wfd restore", "bring back the diary put aside" },
            { "/wfd bestiary", "open a part: today, bestiary, honour, ledger, atlas, settings ... or a day number" } }) do
            print("|cffffd100" .. h[1] .. "|r - " .. L[h[2]])
        end
    elseif WFD.UI:OpenPart(msg) then
        -- "/wfd bestiary", "/wfd 12": the book opens at that part or day
    else
        WFD.UI:Toggle()
    end
end
