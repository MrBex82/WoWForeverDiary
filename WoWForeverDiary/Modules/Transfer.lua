-- Moving to another computer: the diary of a character as one line of text (a "moving code"),
-- packed small enough to copy and paste, and read back in on the other side.
local ADDON, WFD = ...
local floor, byte, char, concat, format = math.floor, string.byte, string.char, table.concat, string.format

------------------------------------------------------------------------
-- Writing a table as text and reading it back (no code is ever run while reading)
------------------------------------------------------------------------
local function num(n)
    if n == floor(n) and n > -1e15 and n < 1e15 then return format("%.0f", n) end
    return format("%.17g", n)
end

local function write(v, out)
    local t = type(v)
    if t == "string" then
        out[#out + 1] = "s" .. #v .. ":" .. v
    elseif t == "number" then
        if v ~= v or v == math.huge or v == -math.huge then v = 0 end
        out[#out + 1] = "n" .. num(v) .. ";"
    elseif t == "boolean" then
        out[#out + 1] = v and "T" or "F"
    elseif t == "table" then
        out[#out + 1] = "{"
        for k, x in pairs(v) do
            local kt, xt = type(k), type(x)
            if (kt == "string" or kt == "number" or kt == "boolean") and
               (xt == "string" or xt == "number" or xt == "boolean" or xt == "table") then
                write(k, out)
                write(x, out)
            end
        end
        out[#out + 1] = "}"
    end
end

function WFD:Serialize(v)
    local out = {}
    write(v, out)
    return concat(out)
end

local MAX_DEPTH = 40       -- the diary nests a few levels deep; more is not a diary

function WFD:Deserialize(s)
    local pos = 1
    local read
    function read(depth)
        depth = depth or 0
        if depth > MAX_DEPTH then error("too deep") end
        local c = s:sub(pos, pos)
        if c == "s" then
            local colon = s:find(":", pos + 1, true)
            local len = colon and tonumber(s:sub(pos + 1, colon - 1))
            if not len then error("bad string") end
            local v = s:sub(colon + 1, colon + len)
            if #v ~= len then error("short string") end
            pos = colon + len + 1
            return v
        elseif c == "n" then
            local semi = s:find(";", pos + 1, true)
            local v = semi and tonumber(s:sub(pos + 1, semi - 1))
            if not v then error("bad number") end
            pos = semi + 1
            return v
        elseif c == "T" or c == "F" then
            pos = pos + 1
            return c == "T"
        elseif c == "{" then
            pos = pos + 1
            local t = {}
            while s:sub(pos, pos) ~= "}" do
                if pos > #s then error("open table") end
                local k = read(depth + 1)
                if type(k) == "table" or k ~= k then error("bad key") end
                t[k] = read(depth + 1)
            end
            pos = pos + 1
            return t
        end
        error("unexpected '" .. c .. "' at " .. pos)
    end
    local ok, v = pcall(read)
    if not ok then return nil, v end
    return v
end

------------------------------------------------------------------------
-- Packing: LZW on the bytes, the codes written into 64 plain characters (no "|", which the chat box eats)
------------------------------------------------------------------------
local ALPHA = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
local TO, FROM = {}, {}
for i = 1, 64 do
    TO[i - 1] = ALPHA:sub(i, i)
    FROM[byte(ALPHA, i)] = i - 1
end
local MAXCODE = 65535

function WFD:Pack(s)
    local dict, size = {}, 256
    for i = 0, 255 do dict[char(i)] = i end
    local out, acc, bits = {}, 0, 0
    local width = 9
    local function emit(code)
        -- little end first: the code goes into the accumulator above what is waiting
        acc = acc + code * 2 ^ bits
        bits = bits + width
        while bits >= 6 do
            local six = acc % 64
            out[#out + 1] = TO[six]
            acc = (acc - six) / 64
            bits = bits - 6
        end
    end
    local w = ""
    for i = 1, #s do
        local cc = s:sub(i, i)
        local wc = w .. cc
        if dict[wc] then
            w = wc
        else
            emit(dict[w])
            if size <= MAXCODE then
                dict[wc] = size
                size = size + 1
                if size > 2 ^ width and width < 16 then width = width + 1 end
            end
            w = cc
        end
    end
    if w ~= "" then emit(dict[w]) end
    if bits > 0 then out[#out + 1] = TO[acc % 64] end
    return concat(out)
end

function WFD:Unpack(p, rawLen)
    local dict, size = {}, 256
    for i = 0, 255 do dict[i] = char(i) end
    local out, n = {}, 0
    local acc, bits, i = 0, 0, 1
    local width = 9
    local prev
    local total = 0
    while true do
        while bits < width and i <= #p do
            local v = FROM[byte(p, i)]
            if not v then return nil, "bad character" end
            acc = acc + v * 2 ^ bits
            bits = bits + 6
            i = i + 1
        end
        if bits < width then break end
        local code = acc % 2 ^ width
        acc = (acc - code) / 2 ^ width
        bits = bits - width
        local entry
        if dict[code] then
            entry = dict[code]
        elseif code == size and prev then
            entry = prev .. prev:sub(1, 1)
        else
            return nil, "bad code"
        end
        n = n + 1
        out[n] = entry
        total = total + #entry
        if prev and size <= MAXCODE then
            dict[size] = prev .. entry:sub(1, 1)
            size = size + 1
        end
        -- the writer widens one code earlier than the reader learns the new entry
        if size + 1 > 2 ^ width and width < 16 then width = width + 1 end
        prev = entry
        if rawLen and total >= rawLen then break end
    end
    return concat(out)
end

-- a short check sum, so a code cut short when copying is noticed
local function sum(s)
    local a, b = 1, 0
    for i = 1, #s do
        a = (a + byte(s, i)) % 65521
        b = (b + a) % 65521
    end
    return b * 65536 + a
end

------------------------------------------------------------------------
-- The moving code of this character
------------------------------------------------------------------------
local HEAD = "WFD1"
-- A real diary packs to a tenth or so of its size. A code that claims far more would only freeze the game
-- while it is unpacked (a damaged or made-up code), so it is refused before.
local MAX_RAW = 16 * 1024 * 1024
local MAX_RATIO = 200

-- A code from someone else must not bring display codes into the book: textures, atlas icons, protected
-- strings and links of kinds the diary never stores are reduced to their text. Colours and the links
-- the diary keeps itself (items, quests, spells ...) stay.
local LINKS = { item = true, quest = true, spell = true, enchant = true, currency = true, achievement = true, talent = true }
local function clean(s)
    s = s:gsub("|T.-|t", ""):gsub("|A.-|a", ""):gsub("|K.-|k", "")
    s = s:gsub("|H(.-)|h(.-)|h", function(link, text)
        local kind = link:match("^(%a+):")
        if kind and LINKS[kind] then return nil end
        return text
    end)
    return s
end
local function cleanAll(v, depth)
    if depth > 40 then return end
    local fix
    for k, x in pairs(v) do
        if type(x) == "string" then
            if x:find("|", 1, true) then
                fix = fix or {}
                fix[k] = clean(x)
            end
        elseif type(x) == "table" then
            cleanAll(x, depth + 1)
        end
    end
    for k, x in pairs(fix or {}) do v[k] = x end
end

-- the parts of a diary the pages count and add up must have the right kind, or every page would fail
local function isT(v) return v == nil or type(v) == "table" end
local function isN(v) return v == nil or type(v) == "number" end
local function looksLikeDiary(C)
    if type(C) ~= "table" or type(C.born) ~= "number" then return false end
    for _, k in ipairs({ "days", "mobs", "npcs", "quests", "events", "zones", "skills", "nemesis", "companions",
        "traders", "rests", "runs", "firsts", "challenges", "capsules", "gather", "dayNotes",
        "catch", "catchZone", "tackle" }) do
        if not isT(C[k]) then return false end
    end
    for _, k in ipairs({ "wealth", "killTotal", "questTotal", "deathTotal", "itemTotal", "npcCount" }) do
        if not isN(C[k]) then return false end
    end
    for idx, d in pairs(C.days or {}) do
        if type(idx) ~= "number" or type(d) ~= "table" then return false end
        for _, k in ipairs({ "kills", "qa", "qd", "npcs", "income", "spend", "loot", "zones", "path", "kcells",
            "dpos", "levels", "deathBy", "hours" }) do
            if not isT(d[k]) then return false end
        end
        for _, k in ipairs({ "killTotal", "deaths", "xp", "online", "steps", "jumps", "flights" }) do
            if not isN(d[k]) then return false end
        end
    end
    for _, list in ipairs({ C.mobs, C.npcs, C.quests, C.zones, C.events }) do
        for _, e in pairs(list or {}) do if type(e) ~= "table" then return false end end
    end
    return true
end

function WFD:MovingCode()
    local C = WFDiaryChar
    if not C or not C.born then return nil end
    local S = self.S or {}
    -- what the account knows from this character: its line in the family book, the kinds it slew first
    local fam = S.family and S.family[self:FamilyKey()]
    local creatures = {}
    for id, e in pairs(S.creatures or {}) do
        if e.who == C.name then creatures[id] = e end
    end
    -- the diary put aside stays on this computer
    local previous, backup = C.previous, C.backup
    C.previous, C.backup = nil, nil
    local ok, raw = pcall(self.Serialize, self, { v = 1, addon = self.version, char = C, family = fam, creatures = creatures })
    C.previous, C.backup = previous, backup
    if not ok then error(raw, 0) end
    local packed = self:Pack(raw)
    return format("%s:%.0f:%.0f:%s", HEAD, #raw, sum(raw), packed), #raw
end

-- read a code: the data, or nil and why not
function WFD:ReadMovingCode(code)
    code = (code or ""):gsub("%s", "")
    local head, len, check, packed = code:match("^(%w+):(%d+):(%d+):([%w%-_]+)$")
    if head ~= HEAD then return nil, "format" end
    len, check = tonumber(len), tonumber(check)
    if not len or len > MAX_RAW or len > #packed * MAX_RATIO then return nil, "damaged" end
    local raw = self:Unpack(packed, len)
    if not raw or #raw ~= len or sum(raw) ~= check then return nil, "damaged" end
    local data = self:Deserialize(raw)
    if type(data) ~= "table" or not looksLikeDiary(data.char) then return nil, "damaged" end
    if not isT(data.family) or not isT(data.creatures) then return nil, "damaged" end
    data.char.previous, data.char.backup = nil, nil
    cleanAll(data, 0)
    return data
end

-- replace this character's diary with the one from the code (the interface is reloaded afterwards);
-- the diary written so far is put aside, /wfd restore brings it back
function WFD:ApplyMovingCode(data)
    local C = data.char
    -- the character on this computer is the same one: keep its identity so the diary is not started over
    C.guid = UnitGUID and UnitGUID("player") or C.guid
    local cur = WFDiaryChar
    if cur then cur.previous, cur.backup = nil, nil end
    C.previous = (cur and cur.born) and cur or nil
    WFDiaryChar = C
    self.paused = true          -- nothing more is written into the diary that was just put aside
    local S = self.S
    if S then
        if data.family then
            S.family = S.family or {}
            S.family[(C.realm or GetRealmName() or "?") .. "-" .. (C.name or UnitName("player") or "?")] = data.family
        end
        S.creatures = S.creatures or {}
        for id, e in pairs(data.creatures or {}) do
            if not S.creatures[id] then S.creatures[id] = e end
        end
    end
end
