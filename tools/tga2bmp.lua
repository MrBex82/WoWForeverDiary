-- crops the art (450x596) out of the 512x1024 TGA and writes a 24-bit BMP for previewing
local inp, out, W, H = arg[1], arg[2], 450, 596
local d = io.open(inp, "rb"):read("a")
local TW = d:byte(13) + d:byte(14) * 256
local rowBytes = ((W * 3 + 3) // 4) * 4
local f = io.open(out, "wb")
local size = 54 + rowBytes * H
local function le32(v) return string.char(v % 256, (v >> 8) % 256, (v >> 16) % 256, (v >> 24) % 256) end
f:write("BM", le32(size), le32(0), le32(54), le32(40), le32(W), le32(H), string.char(1, 0, 24, 0), le32(0), le32(rowBytes * H), le32(2835), le32(2835), le32(0), le32(0))
for y = H - 1, 0, -1 do
    local parts = {}
    for x = 0, W - 1 do
        local o = 18 + (y * TW + x) * 4
        parts[#parts + 1] = d:sub(o + 1, o + 3)
    end
    local row = table.concat(parts)
    f:write(row, string.rep("\0", rowBytes - #row))
end
f:close()
