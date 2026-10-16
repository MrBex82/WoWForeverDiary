-- Usage: lua tools/gen_marble.lua WoWForeverDiary/Media/marble.tga
-- Renders 512x512 of marbled endpaper, as glued inside the covers of old books:
-- combed colour bands (oxblood, deep teal, ochre) bent by swirls, with fine light veins between them. Kept dark.
local OUT = arg[1]
local N = 512
local floor, max, min, sqrt, sin, cos, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.cos, math.abs

local function hash(x, y, s)
    local h = (x * 374761393 + y * 668265263 + s * 2147483647) & 0xffffffff
    h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
    return ((h ~ (h >> 16)) & 0xffff) / 65535
end
local function vnoise(x, y, s)
    local xi, yi = floor(x), floor(y)
    local fx, fy = x - xi, y - yi
    fx = fx * fx * (3 - 2 * fx)
    fy = fy * fy * (3 - 2 * fy)
    local a, b = hash(xi, yi, s), hash(xi + 1, yi, s)
    local c, d = hash(xi, yi + 1, s), hash(xi + 1, yi + 1, s)
    return (a + (b - a) * fx) * (1 - fy) + (c + (d - c) * fx) * fy
end
local function fbm(x, y, s, oct)
    local v, amp, f, sum = 0, 0.5, 1, 0
    for o = 1, oct do
        v = v + amp * vnoise(x * f, y * f, s + o * 17)
        sum = sum + amp
        amp, f = amp * 0.5, f * 2.03
    end
    return v / sum
end

-- colours of the bands, from dark to light, repeated
-- { colour, width of its band }
local PALETTE = {
    { { 0.19, 0.045, 0.035 }, 3 },   -- oxblood
    { { 0.06, 0.03, 0.022 }, 2 },    -- near black
    { { 0.05, 0.12, 0.13 }, 3 },     -- deep teal
    { { 0.10, 0.045, 0.03 }, 2 },    -- dark brown
    { { 0.33, 0.21, 0.08 }, 1 },     -- ochre, a thin seam
    { { 0.08, 0.035, 0.028 }, 2 },
    { { 0.24, 0.055, 0.045 }, 2 },   -- red
    { { 0.035, 0.08, 0.10 }, 3 },    -- blue-black
}
local WSUM = 0
for _, e in ipairs(PALETTE) do WSUM = WSUM + e[2] end

local function lerp(a, b, t) return a + (b - a) * t end

local px = {}
for y = 0, N - 1 do
    local row = {}
    for x = 0, N - 1 do
        local u, v = x / N, y / N
        -- two rounds of domain warping give the swirls of stone marbling
        local wx = fbm(u * 3, v * 3, 5, 4) - 0.5
        local wy = fbm(u * 3 + 7.3, v * 3 + 2.1, 9, 4) - 0.5
        local qx = u + wx * 0.45
        local qy = v + wy * 0.45
        local w2 = fbm(qx * 6, qy * 6, 13, 3) - 0.5
        -- finely combed bands running mostly across, bent by the warp
        local band = (qy * 12 + w2 * 2.4 + 0.22 * sin(qx * 20)) % 1
        local t = band * WSUM
        local i, acc = 0, 0
        while i < #PALETTE - 1 and acc + PALETTE[i + 1][2] <= t do acc = acc + PALETTE[i + 1][2]; i = i + 1 end
        local f = min(1, (t - acc) / PALETTE[i + 1][2])
        local c1 = PALETTE[i + 1][1]
        local c2 = PALETTE[(i + 1) % #PALETTE + 1][1]
        -- mostly flat colour with a soft edge into the next band
        local blend = max(0, (f - 0.82) / 0.18)
        local r, g, b = lerp(c1[1], c2[1], blend), lerp(c1[2], c2[2], blend), lerp(c1[3], c2[3], blend)
        -- fine light veins where the bands meet
        local vein = max(0, 1 - abs(f - 0.82) * 60) * 0.55 + max(0, 1 - abs(f - 0.05) * 90) * 0.25
        r, g, b = r + vein * 0.42, g + vein * 0.32, b + vein * 0.18
        -- tiny drops of colour, as flicked onto the size bath
        local drop = vnoise(x / 3.2, y / 3.2, 31)
        if drop > 0.93 then
            local k = (drop - 0.93) * 6
            r, g, b = r + k * 0.30, g + k * 0.22, b + k * 0.10
        end
        -- paper grain and a little unevenness
        local grain = 0.92 + 0.12 * vnoise(x / 1.3, y / 1.3, 41) + 0.10 * (fbm(u * 6, v * 6, 47, 2) - 0.5)
        grain = grain * 0.88
        row[x] = { r * grain, g * grain, b * grain }
    end
    px[y] = row
end

local f = assert(io.open(OUT, "wb"))
f:write(string.char(0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, N % 256, N // 256, N % 256, N // 256, 32, 0x28))
local function clamp(v) v = floor(v * 255 + 0.5) if v < 0 then return 0 elseif v > 255 then return 255 end return v end
for y = 0, N - 1 do
    local parts = {}
    for x = 0, N - 1 do
        local p = px[y][x]
        parts[#parts + 1] = string.char(clamp(p[3]), clamp(p[2]), clamp(p[1]), 255)
    end
    f:write(table.concat(parts))
end
f:close()
