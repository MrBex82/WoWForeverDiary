-- Usage: lua tools/gen_cover.lua WoWForeverDiary/Media/cover.tga   (preview: lua tools/tga2bmp.lua <tga> <bmp>)
-- Renders the leather cover of the diary into a 512x1024 TGA (art in the top-left 450x596).
-- Height map + lighting for leather grain, tooling and metal.
local OUT = arg[1]
local TW, TH = 512, 1024
local W, H = 450, 596
local floor, sqrt, abs, max, min, exp, sin, cos = math.floor, math.sqrt, math.abs, math.max, math.min, math.exp, math.sin, math.cos

---------------------------------------------------------------- noise
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

---------------------------------------------------------------- layout (pixels, y down)
local CX = 245                         -- visual centre (right of the spine)
local SPINE = 42
local CY = 250                         -- medallion centre
local function rectDist(x, y, x0, y0, x1, y1)  -- signed distance to a rectangle (negative inside)
    local dx = max(x0 - x, x - x1)
    local dy = max(y0 - y, y - y1)
    if dx <= 0 and dy <= 0 then return max(dx, dy) end
    return sqrt(max(dx, 0) ^ 2 + max(dy, 0) ^ 2)
end
local function lozDist(x, y, hx, hy)    -- distance to the outline of a lozenge around (CX, CY)
    local u, v = abs(x - CX) / hx, abs(y - CY) / hy
    local s = u + v - 1                   -- 0 on the outline
    return s / sqrt(1 / hx ^ 2 + 1 / hy ^ 2)
end

-- tooling: returns depth (positive = pressed in) and gold coverage 0..1
local function tooling(x, y)
    local depth, gold = 0, 0
    local function line(d, wd, g)       -- a tooled line of width wd at distance d
        local t = 1 - abs(d) / wd
        if t > 0 then
            depth = max(depth, min(1, t * 1.6))
            if g then gold = max(gold, min(1, t * 2.2)) end
        end
    end
    -- blind groove and the two gold fillets of the frame
    line(rectDist(x, y, SPINE + 18, 18, W - 18, H - 18), 1.6, false)
    line(rectDist(x, y, SPINE + 26, 28, W - 28, H - 28), 1.3, true)
    line(rectDist(x, y, SPINE + 42, 44, W - 44, H - 44), 1.1, true)
    -- a row of stamped diamonds between the fillets
    local mx0, my0, mx1, my1 = SPINE + 34, 36, W - 36, H - 36
    local onH = (abs(y - my0) < 4 or abs(y - my1) < 4) and x > mx0 and x < mx1
    local onV = (abs(x - mx0) < 4 or abs(x - mx1) < 4) and y > my0 and y < my1
    if onH or onV then
        local p = onH and (x - mx0) or (y - my0)
        local cyc = (p % 14) - 7
        local q = onH and (y - (abs(y - my0) < 4 and my0 or my1)) or (x - (abs(x - mx0) < 4 and mx0 or mx1))
        local dd = abs(cyc) + abs(q) - 3.2
        if dd < 0 then depth = max(depth, 0.9) end
    end
    -- lozenge: double gold outline
    line(lozDist(x, y, 106, 124), 1.6, true)
    line(lozDist(x, y, 96, 112), 1.0, true)
    -- fleurons in the inner corners: small gold diamonds
    for _, p in ipairs({ { SPINE + 58, 60, 1, 1 }, { W - 60, 60, -1, 1 }, { SPINE + 58, H - 60, 1, -1 }, { W - 60, H - 60, -1, -1 } }) do
        local function dia(px, py, r)
            local dd = abs(x - px) + abs(y - py) - r
            if dd < 0 then depth = max(depth, 0.8); gold = max(gold, min(1, -dd / 1.2)) end
        end
        dia(p[1], p[2], 8)
        dia(p[1] + 15 * p[3], p[2], 4)
        dia(p[1], p[2] + 15 * p[4], 4)
        dia(p[1] + 10 * p[3], p[2] + 10 * p[4], 3)
    end
    -- lozenge tips
    for _, t in ipairs({ { CX, CY - 124 }, { CX + 106, CY }, { CX, CY + 124 }, { CX - 106, CY } }) do
        local dd = abs(x - t[1]) + abs(y - t[2]) - 6
        if dd < 0 then depth = max(depth, 0.8); gold = max(gold, min(1, -dd / 1.2)) end
    end
    -- gold rule around the title field and the name plate
    line(rectDist(x, y, CX - 130, 58, CX + 130, 124), 1.2, true)
    line(rectDist(x, y, CX - 131, 382, CX + 131, 482), 1.1, true)
    -- gold fillets on both sides of every spine band
    if x > 5 and x < SPINE - 3 then
        for i = 0, 4 do
            local by = 44 + i * ((H - 100) / 4) + 6
            for _, o in ipairs({ -14, 14 }) do
                local t = 1 - abs(y - by - o) / 1.2
                if t > 0 then depth = max(depth, t); gold = max(gold, min(1, t * 2)) end
            end
        end
    end
    return depth, gold
end

-- recessed fields (title, name plate) and the medallion
local function relief(x, y)
    local h = 0
    local function panel(x0, y0, x1, y1)
        local d = rectDist(x, y, x0, y0, x1, y1)
        if d < 0 then h = h - min(1, -d / 3) * 2.2 end
    end
    panel(CX - 124, 64, CX + 124, 118)
    panel(CX - 125, 388, CX + 125, 476)
    -- medallion: raised gold ring, sunken disc inside
    local r = sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
    local ring = 0
    if r < 78 and r > 62 then
        local t = 1 - abs(r - 70) / 8
        h = h + 3.2 * t
        ring = min(1, t * 3)
    elseif r <= 62 then
        h = h - 1.8 * min(1, (62 - r) / 3)
    end
    -- raised bands on the spine
    if x < SPINE then
        for i = 0, 4 do
            local by = 44 + i * ((H - 100) / 4)
            local d = abs(y - by - 6)
            if d < 10 then h = h + 4 * cos(d / 10 * math.pi / 2) end
        end
    end
    return h, ring, r
end

---------------------------------------------------------------- brass corners
local function brass(x, y)
    for _, cnr in ipairs({ { 0, 0, 1, 1 }, { W, 0, -1, 1 }, { 0, H, 1, -1 }, { W, H, -1, -1 } }) do
        local u, v = (x - cnr[1]) * cnr[3], (y - cnr[2]) * cnr[4]   -- distance into the cover from that corner
        if u >= 0 and v >= 0 and u + v < 50 then
            local edge = 50 - (u + v)
            local hgt = min(1, edge / 4) * 2 + min(1, min(u, v) / 3)
            -- rivets
            local rv = 0
            for _, r in ipairs({ { 30, 9 }, { 9, 30 } }) do
                local d = sqrt((u - r[1]) ^ 2 + (v - r[2]) ^ 2)
                if d < 4.5 then rv = max(rv, cos(d / 4.5 * math.pi / 2)) end
            end
            return true, hgt + rv * 3, rv, u, v
        end
    end
    return false
end

---------------------------------------------------------------- render
local px = {}
local function light(hfn, x, y)
    -- normal from central differences of the height function, light from the upper left
    local hx = hfn(x + 1, y) - hfn(x - 1, y)
    local hy = hfn(x, y + 1) - hfn(x, y - 1)
    local nx, ny, nz = -hx, -hy, 2
    local l = sqrt(nx * nx + ny * ny + nz * nz)
    nx, ny, nz = nx / l, ny / l, nz / l
    local lx, ly, lz = -0.55, -0.55, 0.63
    local diff = nx * lx + ny * ly + nz * lz
    -- specular for metal and gold
    local hxv, hyv, hzv = lx, ly, lz + 1
    local hl = sqrt(hxv * hxv + hyv * hyv + hzv * hzv)
    local spec = max(0, (nx * hxv + ny * hyv + nz * hzv) / hl) ^ 24
    return diff, spec
end

-- total height of the leather at a point (grain, wrinkles, tooling, relief)
local function height(x, y)
    local g = fbm(x / 2.2, y / 2.2, 3, 3) * 0.9          -- fine grain
    local w = fbm(x / 18, y / 14, 11, 4)                  -- soft wrinkles
    local wr = abs(w - 0.5) * 2.4
    local d = tooling(x, y)
    local rh = relief(x, y)
    return g + wr * 1.4 - d * 2.6 + rh
end

local function brassHeight(x, y)
    local ok, h = brass(x, y)
    return ok and h or 0
end

local t0 = os.clock()
local HM, BM = {}, {}
for y = -1, H do
    local hr, br = {}, {}
    for x = -1, W do
        hr[x] = height(x, y)
        br[x] = brassHeight(x, y)
    end
    HM[y], BM[y] = hr, br
end
local function mapFn(M) return function(x, y) return M[y][x] end end
local heightAt, brassAt = mapFn(HM), mapFn(BM)
io.stderr:write(("height maps %.1fs\n"):format(os.clock() - t0))
for y = 0, TH - 1 do
    local row = {}
    for x = 0, TW - 1 do
        local r, g, b, a = 0, 0, 0, 0
        if x < W and y < H then
            a = 255
            local isBrass, _, rv, bu, bv = brass(x, y)
            if isBrass then
                local diff, spec = light(brassAt, x, y)
                local scratch = fbm(x / 1.5, y / 9, 41, 2)
                local base = 0.62 + 0.25 * scratch
                local sh = 0.35 + 0.95 * max(0, diff)
                r = (0.78 * base) * sh + spec * 0.9
                g = (0.58 * base) * sh + spec * 0.8
                b = (0.26 * base) * sh + spec * 0.5
                -- dark patina in the seam against the leather
                local seam = 50 - (bu + bv)
                if seam < 2 then r, g, b = r * 0.5, g * 0.5, b * 0.5 end
            else
                local diff, spec = light(heightAt, x, y)
                local depth, gold = tooling(x, y)
                local _, ring, rr = relief(x, y)
                -- leather colour: deep brown, varying a little, darker toward the edges
                local tone = fbm(x / 60, y / 60, 5, 3)
                local lr, lg, lb = 0.205 + 0.06 * tone, 0.105 + 0.035 * tone, 0.055 + 0.02 * tone
                if x < SPINE then lr, lg, lb = lr * 0.72, lg * 0.72, lb * 0.72 end
                local ex = min(x, W - 1 - x, 9999) ; local ey = min(y, H - 1 - y)
                local edge = min(ex, ey)
                local vign = 0.55 + 0.45 * min(1, edge / 70)
                -- rubbed, lighter leather along edges and corners
                local wear = max(0, 1 - edge / 22) * fbm(x / 7, y / 7, 23, 3)
                lr, lg, lb = lr + wear * 0.16, lg + wear * 0.09, lb + wear * 0.04
                -- inside the recessed fields the leather is darker
                local inField = rectDist(x, y, CX - 124, 64, CX + 124, 118) < 0 or rectDist(x, y, CX - 125, 388, CX + 125, 476) < 0
                if inField then lr, lg, lb = lr * 0.62, lg * 0.62, lb * 0.62 end
                if rr < 62 then lr, lg, lb = lr * 0.55, lg * 0.55, lb * 0.55 end
                local sh = (0.45 + 0.85 * max(0, diff)) * vign
                r, g, b = lr * sh, lg * sh, lb * sh
                -- leather sheen
                r, g, b = r + spec * 0.05, g + spec * 0.04, b + spec * 0.03
                -- gold leaf in the tooling and on the medallion ring, worn in places
                local gl = max(gold, ring)
                if gl > 0 then
                    local worn = fbm(x / 3, y / 3, 61, 2)
                    gl = gl * ((worn > 0.32 or ring > gold) and 1 or 0.35)
                    local gs = 0.45 + 0.75 * max(0, diff)
                    local gr, gg, gb = 0.95 * gs + spec * 0.9, 0.74 * gs + spec * 0.8, 0.34 * gs + spec * 0.45
                    r, g, b = r + (gr - r) * gl, g + (gg - g) * gl, b + (gb - b) * gl
                end
                -- the hinge between spine and board
                if x >= SPINE and x < SPINE + 3 then r, g, b = r * 0.35, g * 0.35, b * 0.35 end
            end
            -- outer edge slightly darker
            if x < 2 or y < 2 or x > W - 3 or y > H - 3 then r, g, b = r * 0.5, g * 0.5, b * 0.5 end
        end
        row[x] = { r, g, b, a }
    end
    px[y] = row
    if y % 128 == 0 then io.stderr:write(("row %d  %.1fs\n"):format(y, os.clock() - t0)) end
end

---------------------------------------------------------------- write TGA (32 bit, top-left origin)
local f = assert(io.open(OUT, "wb"))
f:write(string.char(0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, TW % 256, TW // 256, TH % 256, TH // 256, 32, 0x28))
local function clamp(v) v = floor(v * 255 + 0.5) if v < 0 then return 0 elseif v > 255 then return 255 end return v end
for y = 0, TH - 1 do
    local parts = {}
    local row = px[y]
    for x = 0, TW - 1 do
        local p = row[x]
        parts[#parts + 1] = string.char(clamp(p[3]), clamp(p[2]), clamp(p[1]), p[4])
    end
    f:write(table.concat(parts))
end
f:close()
io.stderr:write(("done %.1fs\n"):format(os.clock() - t0))
