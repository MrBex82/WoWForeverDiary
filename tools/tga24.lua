-- Turns 32-bit TGA files whose alpha channel is fully opaque into 24-bit TGA (a quarter smaller, same picture).
-- Files that really use transparency are left alone.  Usage: lua tga24.lua file.tga [more.tga ...]
for _, path in ipairs(arg) do
    local f = assert(io.open(path, "rb"))
    local s = f:read("a")
    f:close()
    local idlen, itype, bpp, desc = s:byte(1), s:byte(3), s:byte(17), s:byte(18)
    if itype ~= 2 or bpp ~= 32 then
        print(path .. ": not an uncompressed 32-bit TGA, skipped")
    else
        local start = 19 + idlen
        local opaque = true
        for i = start + 3, #s, 4 do
            if s:byte(i) ~= 255 then opaque = false break end
        end
        if not opaque then
            print(path .. ": uses transparency, kept at 32 bit")
        else
            local out = { s:sub(1, 16), string.char(24), string.char(desc & 0xF0), s:sub(19, start - 1) }
            local pixels = {}
            for i = start, #s - 3, 4 do pixels[#pixels + 1] = s:sub(i, i + 2) end
            out[#out + 1] = table.concat(pixels)
            local w = assert(io.open(path, "wb"))
            w:write(table.concat(out))
            w:close()
            print(path .. ": now 24 bit")
        end
    end
end
