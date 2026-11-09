-- Simulates "secret values" (WoW 12 / Midnight, inside instances) outside the game.
-- Usage:  lua tools/secret_sim.lua [addon folder]      (default: WoWForeverDiary)
--
-- Loads the addon files with a fake game API. Every unit query returns a secret value: an object that
-- throws on comparing, calculating, concatenating, indexing, calling and use as a table key, as the real
-- ones do. Then the game events are fired at the addon. Any error a handler throws is listed; exit code 1.
--
-- Limits: Lua cannot make a value that throws when merely tested in an "if" (secret booleans).
-- So `if secretBool then` passes here and may still fail in the game.

local dir = arg and arg[1] or "WoWForeverDiary"

------------------------------------------------------------------------ secret values
local SECRET = {}
local function boom(what) return function() error("attempt to " .. what .. " a secret value", 2) end end
local secretMT = {
    __index = boom("index"), __newindex = boom("index"), __call = boom("call"),
    __add = boom("perform arithmetic on"), __sub = boom("perform arithmetic on"), __mul = boom("perform arithmetic on"),
    __div = boom("perform arithmetic on"), __mod = boom("perform arithmetic on"), __unm = boom("perform arithmetic on"),
    __concat = boom("concatenate"), __len = boom("get length of"),
    __lt = boom("compare"), __le = boom("compare"),
    __eq = boom("compare"),
    __tostring = boom("convert"),
}
local function secret(kind)
    local s = setmetatable({}, secretMT)
    SECRET[s] = kind or "string"
    return s
end
local function isSecret(v) return SECRET[v] ~= nil end

------------------------------------------------------------------------ fake game
local errors, seen = {}, {}
local anyFn
local function stubObject()
    local o
    o = setmetatable({}, { __index = function() return anyFn end, __call = function() return o end })
    return o
end
anyFn = function() return stubObject() end

local env = {}
local scripts = {}                      -- frame -> script name -> fn
local realType = type
setmetatable(env, { __index = function(_, k)
    local v = _G[k]
    if v ~= nil then return v end
    -- an unknown game function: does nothing (names of constants are not guessed)
    if realType(k) == "string" and k:find("^[A-Z][A-Za-z]+$") and not k:find("^[A-Z_]+$") then return anyFn end
    return nil
end })
env.time, env.date, env.difftime = os.time, os.date, os.difftime
env.bit = { band = function(a, b) return a & b end, bor = function(a, b) return a | b end,
    bxor = function(a, b) return a ~ b end, lshift = function(a, b) return a << b end, rshift = function(a, b) return a >> b end }
env.band = env.bit.band

env._G = env
env.Enum = { TooltipDataType = { Item = 0 } }
env.WFDiaryDB, env.WFDiaryChar = {}, {}
env.issecretvalue = isSecret
env.type = function(v) if SECRET[v] then return SECRET[v] end return realType(v) end
env.GetBuildInfo = function() return "12.0.0", "1", "Jan 1 2026", 120000 end
env.GetLocale = function() return "enUS" end
env.GetTime = function() return os.clock() end
env.GetRealmName = function() return "Realm" end
env.strsplit = function(sep, s, n)
    local out, pos = {}, 1
    while true do
        local a, b = s:find(sep, pos, true)
        if not a then out[#out + 1] = s:sub(pos) break end
        out[#out + 1] = s:sub(pos, a - 1)
        pos = b + 1
    end
    return table.unpack(out)
end
env.format, env.floor, env.min, env.max = string.format, math.floor, math.min, math.max
env.wipe = function(t) for k in pairs(t) do t[k] = nil end return t end
env.tinsert, env.tremove = table.insert, table.remove
env.CreateFrame = function()
    local f = stubObject()
    local mt = getmetatable(f)
    local rawf = {}
    function rawf.SetScript(_, name, fn) scripts[f] = scripts[f] or {}; scripts[f][name] = fn end
    function rawf.HookScript(_, name, fn) scripts[f] = scripts[f] or {}; scripts[f][name] = scripts[f][name] or fn end
    function rawf.RegisterEvent() return true end
    mt.__index = function(_, k) return rawf[k] or anyFn end
    return f
end
env.C_Timer = { After = function() end, NewTicker = function() return stubObject() end }
env.hooksecurefunc = function() end
env.SlashCmdList = {}
env.IsInInstance = function() return true, "party" end
env.GetInstanceInfo = function() return "Test Dungeon" end
env.GetNumGroupMembers = function() return 3 end
env.IsInRaid = function() return false end
env.UnitExists = function() return true end
for _, fn in ipairs({ "UnitXP", "UnitXPMax", "GetMoney", "GetNumQuestLogEntries", "GetNumSkillLines", "GetXPExhaustion" }) do env[fn] = function() return 0 end end
env.GetNumQuestLogEntries = function() return 0 end
env.C_QuestLog = { GetNumQuestLogEntries = function() return 0 end }
env.TooltipDataProcessor = { AddTooltipPostCall = function() end }
env.UnitIsUnit = function() return false end
env.UnitAffectingCombat = function() return true end

-- every unit query is secret inside the instance
for _, fn in ipairs({ "UnitGUID", "UnitName", "UnitClass", "UnitLevel", "UnitClassification", "UnitCreatureType",
    "UnitCreatureFamily", "UnitIsPlayer", "UnitIsDead", "UnitIsDeadOrGhost", "UnitCanAttack", "UnitIsTapDenied",
    "UnitThreatSituation", "UnitRace", "UnitSex", "UnitHealth", "UnitHealthMax" }) do
    env[fn] = function() return secret(), secret(), secret() end
end
-- the player's own data is never secret
env.UnitGUID = (function(real) return function(unit) if unit == "player" then return "Player-1-00000001" end return real(unit) end end)(env.UnitGUID)
env.UnitName = (function(real) return function(unit) if unit == "player" then return "Tester" end return real(unit) end end)(env.UnitName)
env.UnitLevel = (function(real) return function(unit) if unit == "player" then return 10 end return real(unit) end end)(env.UnitLevel)
env.UnitClass = (function(real) return function(unit) if unit == "player" then return "Warrior", "WARRIOR", 1 end return real(unit) end end)(env.UnitClass)
env.UnitIsPlayer = (function(real) return function(unit) if unit == "player" then return true end return real(unit) end end)(env.UnitIsPlayer)

------------------------------------------------------------------------ load the addon
local WFD = {}
local toc
do
    local f = assert(io.open(dir .. "/WoWForeverDiary.toc", "r"))
    toc = f:read("a")
    f:close()
end
local skipUI = true
local loadErrors = {}
for line in toc:gmatch("[^\r\n]+") do
    if not line:find("^#") and line:find("%.lua%s*$") and not (skipUI and line:find("^UI[\\/]")) then
        local path = dir .. "/" .. line:gsub("\\", "/"):gsub("%s+$", "")
        local chunk, err = loadfile(path, "t", env)
        if not chunk then
            loadErrors[#loadErrors + 1] = line .. ": " .. tostring(err)
        else
            local ok, e = pcall(chunk, "WoWForeverDiary", WFD)
            if not ok then loadErrors[#loadErrors + 1] = line .. ": " .. tostring(e) end
        end
    end
end

-- record every error the handlers report, before any filtering by the addon
WFD.Error = function(_, where, err)
    local key = tostring(where) .. ": " .. tostring(err)
    if not seen[key] then seen[key] = true; errors[#errors + 1] = key end
end
-- handlers are called through pcall in the addon: a signal's errors go the same way
env.print = function() end

local evf = WFD.evf
local function fire(event, ...)
    local fn = scripts[evf] and scripts[evf].OnEvent
    if fn then fn(evf, event, ...) end
end

fire("ADDON_LOADED", "WoWForeverDiary")
fire("PLAYER_LOGIN")
fire("PLAYER_ENTERING_WORLD")

------------------------------------------------------------------------ the events
local units = { "target", "mouseover", "softenemy", "focus", "nameplate1", "boss1", "party1", "party2", "raid1" }
local unitEvents = { "UNIT_HEALTH", "UNIT_THREAT_LIST_UPDATE", "UNIT_FLAGS", "NAME_PLATE_UNIT_ADDED", "UNIT_AURA", "UNIT_TARGET" }
for round = 1, 2 do
    for _, ev in ipairs(unitEvents) do
        for _, u in ipairs(units) do fire(ev, u) end
        fire(ev, secret())                                    -- even the unit name can be secret
    end
    for _, u in ipairs(units) do
        fire("UNIT_COMBAT", u, "WOUND", nil, 5, 0)
        fire("UNIT_COMBAT", u, "WOUND", nil, secret("number"), 0)
        fire("UNIT_COMBAT", u, secret(), nil, secret("number"), 0)
    end
    fire("UNIT_COMBAT", secret(), "WOUND", nil, 5, 0)
    for _, ev in ipairs({ "PLAYER_TARGET_CHANGED", "UPDATE_MOUSEOVER_UNIT", "PLAYER_SOFT_ENEMY_CHANGED",
        "PLAYER_SOFT_INTERACT_CHANGED", "GROUP_ROSTER_UPDATE", "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED",
        "PLAYER_DEAD", "PLAYER_ENTERING_WORLD", "ZONE_CHANGED", "ZONE_CHANGED_NEW_AREA", "PLAYER_XP_UPDATE" }) do
        fire(ev)
    end
    for _, ev in ipairs({ "CHAT_MSG_COMBAT_XP_GAIN", "CHAT_MSG_LOOT", "CHAT_MSG_MONEY", "CHAT_MSG_SYSTEM", "CHAT_MSG_SKILL",
        "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS", "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES", "CHAT_MSG_COMBAT_FACTION_CHANGE" }) do
        fire(ev, secret())
        fire(ev, secret(), secret(), nil, nil, secret())
    end
    fire("ENCOUNTER_END", secret("number"), secret(), secret("number"), secret("number"), secret("number"))
    fire("ENCOUNTER_END", 1, "Boss", 1, 5, 1)
end

------------------------------------------------------------------------ report
for _, e in ipairs(loadErrors) do print("LOAD  " .. e) end
if #errors == 0 then
    print("OK: no handler threw an error with secret values (" .. #loadErrors .. " files did not load in the simulation)")
    os.exit(0)
end
print(#errors .. " error(s) with secret values:")
for _, e in ipairs(errors) do print("  " .. e) end
os.exit(1)
