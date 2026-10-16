-- Usage: lua tools/gen_page.lua WoWForeverDiary/Media/page.tga
--        lua tools/gen_page.lua WoWForeverDiary/Media/binding.tga binding
-- Renders a seamless 512x512 leather texture.
-- "page" (default): the leaf behind the writing, kept quiet on purpose so text stays easy to read.
-- "binding": the coarser, livelier leather of the binding around the pages (like the cover).
local OUT, STYLE = arg[1], arg[2] or "page"
local S = ({
    page    = { col = { 0.150, 0.105, 0.068 }, pebbles = 80, pebble = 0.22, crease = 0.25, bump = 2.2, amb = 0.86, dif = 0.24, stain = 0.12 },
    binding = { col = { 0.215, 0.110, 0.058 }, pebbles = 56, pebble = 0.32, crease = 0.45, bump = 3.0, amb = 0.62, dif = 0.62, stain = 0.30 },
})[STYLE]
local N = 512
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt

---------------------------------------------------------------- periodic noise (tiles every N pixels)
local function hash(x, y, s)
    local h = (x * 374761393 + y * 668265263 + s * 2147483647) & 0xffffffff
    h = ((h ~ (h >> 13)) * 1274126177) & 0xffffffff
    return ((h ~ (h >> 16)) & 0xffff) / 65535
end
-- value noise on a grid of `cells` per tile, wrapped so the tile repeats without seams
local function pnoise(x, y, cells, s)
    local fx, fy = x / N * cells, y / N * cells
    local xi, yi = floor(fx), floor(fy)
    local tx, ty = fx - xi, fy - yi
    tx = tx * tx * (3 - 2 * tx)
    ty = ty * ty * (3 - 2 * ty)
    local x0, x1 = xi % cells, (xi + 1) % cells
    local y0, y1 = yi % cells, (yi + 1) % cells
    local a, b = hash(x0, y0, s), hash(x1, y0, s)
    local c, d = hash(x0, y1, s), hash(x1, y1, s)
    return (a + (b - a) * tx) * (1 - ty) + (c + (d - c) * tx) * ty
end
local function pfbm(x, y, cells, s, oct)
    local v, amp, sum = 0, 0.5, 0
    for o = 1, oct do
        v = v + amp * pnoise(x, y, cells, s + o * 31)
        sum = sum + amp
        amp, cells = amp * 0.5, cells * 2
    end
    return v / sum
end

-- periodic cellular noise: distance to the nearest of one jittered point per cell (pebbled leather)
local function cells(x, y, n, s)
    local fx, fy = x / N * n, y / N * n
    local xi, yi = floor(fx), floor(fy)
    local d1, d2 = 9, 9
    for oy = -1, 1 do
        for ox = -1, 1 do
            local cx, cy = xi + ox, yi + oy
            local wx, wy = cx % n, cy % n
            local px = cx + 0.15 + 0.7 * hash(wx, wy, s)
            local py = cy + 0.15 + 0.7 * hash(wx, wy, s + 5)
            local d = sqrt((px - fx) ^ 2 + (py - fy) ^ 2)
            if d < d1 then d1, d2 = d, d1 elseif d < d2 then d2 = d end
        end
    end
    return d1, d2
end

---------------------------------------------------------------- height map: pebbled grain, soft mottling, creases, pores
local Hm = {}
for y = 0, N - 1 do
    local row = {}
    for x = 0, N - 1 do
        local mott = pfbm(x, y, 6, 3, 3)                      -- broad, cloudy unevenness
        local d1, d2 = cells(x, y, S.pebbles, 71)                     -- little pebbles, separated by fine valleys
        local pebble = min(1, (d2 - d1) * 3)
        local crease = pfbm(x, y, 14, 83, 3)                    -- a few soft wrinkles
        crease = max(0, 0.06 - math.abs(crease - 0.5)) * 8
        local fine = pnoise(x, y, 256, 11)                     -- fine tooth of the surface
        local pore = pnoise(x, y, 128, 19)
        pore = pore > 0.88 and (pore - 0.88) * 4 or 0          -- a few small pits
        row[x] = mott * 0.8 + pebble * S.pebble - crease * S.crease + fine * 0.10 - pore * 0.5
    end
    Hm[y] = row
end
local function h(x, y) return Hm[y % N][x % N] end

---------------------------------------------------------------- shade
local px = {}
for y = 0, N - 1 do
    local row = {}
    for x = 0, N - 1 do
        -- light from the top left
        local dx = h(x + 1, y) - h(x - 1, y)
        local dy = h(x, y + 1) - h(x, y - 1)
        local nx, ny, nz = -dx * S.bump, -dy * S.bump, 1
        local l = sqrt(nx * nx + ny * ny + nz * nz)
        local diff = (nx * -0.5 + ny * -0.5 + nz * 0.7) / l
        -- base colour (the page: UI.c.paper), varied a little by stains
        local stain = pfbm(x, y, 5, 43, 3)
        local tone = 1 - S.stain / 2 + S.stain * stain
        local r, g, b = S.col[1] * tone, S.col[2] * tone, S.col[3] * tone
        -- warmer patches
        local warm = max(0, pfbm(x, y, 8, 57, 2) - 0.55) * 0.25
        r, g, b = r + warm * 0.10, g + warm * 0.05, b + warm * 0.01
        local sh = S.amb + S.dif * diff
        row[x] = { r * sh, g * sh, b * sh }
    end
    px[y] = row
end

---------------------------------------------------------------- write TGA (32 bit, top-left origin)
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
