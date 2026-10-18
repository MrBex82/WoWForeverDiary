-- Retelling: moments are stored as finished sentences ("Level 12 reached!") in the language of their day.
-- When the diary language changes, every stored sentence is matched against the templates of the language
-- it was written in and told again in the new one. Names from the game (creatures, places, items, quests)
-- stay as the game client wrote them - no addon can translate those.
local ADDON, WFD = ...
local L = WFD.L
local format = string.format
local unpack = unpack or table.unpack

-- every sentence the diary stores with a moment or in its day log
local TEMPLATES = {
    "Level %d reached!", "First quest completed: %s", "%d quests completed", "Quest accepted: %s",
    "Quest abandoned: %s", "Quest completed: %s", "First victory over the boss %s!", "Rare creature slain: %s",
    "Boss %s defeated again (%dx)", "%d creatures slain in total", "Died to %s in %s", "Died in %s",
    "Found %s", "Epic find: %s", "Rare find: %s", "Took a flight to %s", "Wealth reached: %s",
    "Met %s (%s)", "Hearthstone bound to %s", "Discovered a new land: %s", "Entered %s",
    "Discovered: %s (%s)", "First visit to the dungeon %s", "Entered the dungeon %s", "%s increased to %d",
    "%s mastered up to %d", "Used the hearthstone", "Grouped with %s", "Landmark discovered: %s",
    "Honour earned: %s (%s)", "Honour earned: %s", "Task of the day done: %s", "Task of the week done: %s",
    "All tasks of the day done! %d days in a row.", "All tasks of the day done!",
    "A letter for later was sealed.", "A letter from the past has opened.", "New catch: %s",
}
-- sentences that can sit inside another one (the task in "Task of the day done: ...")
local INNER = {
    "Level %d reached!", "Slay %d creatures today.", "Complete %d quests today.", "Meet %d new people.",
    "Discover %d new places.", "Walk %d kilometres today.", "Find an uncommon or better item.",
    "Visit the landmark %s.", "Set foot in %s.", "Slay %d creatures this week.", "Complete %d quests this week.",
    "Walk %d kilometres this week.", "Meet %d new people this week.", "Visit %d different regions this week.",
    "Earn %d honour tiers this week.", "Finish a dungeon run this week.", "Find %d new landmarks this week.",
}

-- earlier wordings of a translation, so entries written before a rewording are still recognised
local LEGACY = {
    deDE = {
        ["Died to %s in %s"] = "Gefallen durch %s in %s",
        ["Met %s (%s)"] = "%s getroffen (%s)",
        ["Hearthstone bound to %s"] = "Ruhestein gebunden an %s",
        ["Took a flight to %s"] = "Flug nach %s",
        ["Wealth reached: %s"] = "Vermögen erreicht: %s",
        ["First visit to the dungeon %s"] = "Erster Besuch im Dungeon %s",
        ["%s mastered up to %d"] = "%s bis %d gemeistert",
    },
}

local function placeholders(key)
    local t = {}
    for p in key:gmatch("%%([ds])") do t[#t + 1] = p end
    return t
end

-- the templates of one language as match patterns, the most specific first
local cache = {}
local function patternsOf(code, keys, tag)
    local id = code .. tag
    if cache[id] then return cache[id] end
    local tr = WFD:LocaleStrings(code)
    local english = (code == "enUS" or code == "enGB")
    local list = {}
    for _, key in ipairs(keys) do
        local text = (tr and rawget(tr, key)) or (english and key) or nil
        if text then
            list[#list + 1] = { key = key, pat = WFD:Pattern(text), types = placeholders(key), len = #text }
        end
        local old = LEGACY[code] and LEGACY[code][key]
        if old then
            list[#list + 1] = { key = key, pat = WFD:Pattern(old), types = placeholders(key), len = #old }
        end
    end
    table.sort(list, function(a, b)
        if #a.types ~= #b.types then return #a.types > #b.types end
        return a.len > b.len
    end)
    cache[id] = list
    return list
end

-- the sentence in the current language, or nil if it matches no template
local function retell(text, codes, inner)
    if type(text) ~= "string" or text == "" then return nil end
    for _, code in ipairs(codes) do
        for _, t in ipairs(patternsOf(code, inner and INNER or TEMPLATES, inner and "#inner" or "#outer")) do
            if text:match(t.pat) then
                local caps = { text:match(t.pat) }
                local args = {}
                for i, ty in ipairs(t.types) do
                    local v = caps[i]
                    if ty == "d" then
                        v = tonumber(v) or 0
                    elseif not inner then
                        v = retell(v, codes, true) or v
                    end
                    args[i] = v
                end
                local ok, out = pcall(format, L[t.key], unpack(args))
                if ok then return out end
            end
        end
    end
end
WFD.Retell = function(_, text, codes, inner) return retell(text, codes, inner) end

-- the word for key in language code (English keys are their own word)
local function wordIn(code, key)
    local tr = WFD:LocaleStrings(code)
    return (tr and rawget(tr, key)) or ((code == "enUS" or code == "enGB") and key) or nil
end

-- "Naturkundler (Silber)": the name of an honour, maybe with its metal
local function retellHonourName(text, codes)
    local name, metal = text:match("^(.-) %((.-)%)$")
    name = name or text
    for _, h in ipairs(WFD.HONOURS or {}) do
        for _, code in ipairs(codes) do
            if wordIn(code, h.name) == name then
                if not metal then return L[h.name] end
                for _, m in ipairs(WFD.METALS or {}) do
                    for _, c2 in ipairs(codes) do
                        if wordIn(c2, m.name) == metal then return L[h.name] .. " (" .. L[m.name] .. ")" end
                    end
                end
                return L[h.name] .. " (" .. metal .. ")"
            end
        end
    end
end

-- moments that know what they are can be told from scratch
local function retellEvent(ev, codes)
    if ev.k == "honour" and ev.honour and WFD.HonourDef then
        local h = WFD:HonourDef(ev.honour)
        if h then
            local n = #h.tiers
            if n == 1 then return format(L["Honour earned: %s"], L[h.name]) end
            return format(L["Honour earned: %s (%s)"], L[h.name], L[WFD:MetalOf(ev.tier or 1, n).name])
        end
    elseif ev.k == "first" and ev.first then
        for _, def in ipairs(WFD.FIRSTS or {}) do
            if def.key == ev.first then
                local detail = ev.s and ev.s:match(":%s*(.+)$")
                if detail then detail = retell(detail, codes, true) or detail end
                return L[def.label] .. (detail and (": " .. detail) or "")
            end
        end
    end
    return retell(ev.s, codes)
end

WFD:OnInit(function()
    local C = WFD.C
    local now = WFD.locale
    if not C or C.textLang == now then return end
    -- the language the texts were written in first, then the game's, then every other
    local codes, seen = {}, {}
    local function add(code)
        if code and not seen[code] then
            seen[code] = true
            codes[#codes + 1] = code
        end
    end
    add(C.textLang)
    add(WFD.gameLocale)
    add("enUS")
    for _, code in ipairs(WFD:LocaleCodes()) do add(code) end
    local ok, err = pcall(function()
        for _, ev in ipairs(C.events or {}) do
            ev.s = retellEvent(ev, codes) or ev.s
        end
        for _, f in pairs(C.firsts or {}) do
            if f.s then
                f.s = retell(f.s, codes) or retell(f.s, codes, true) or retellHonourName(f.s, codes) or f.s
            end
        end
    end)
    if not ok then WFD:Error("retell", err) end
    C.textLang = now
end)
