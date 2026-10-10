-- The Link build helpers, run inside sjasmplus (Lua 5.5): the tables the author computed in BASIC, TR-DOS disk images
-- (writing SCL, reading TRD), the BASIC programs of the release disk, SHA-256 to check every built file against the author's.
-- Paths are relative to the folder sjasmplus runs in (build/obj).

local M = {}

-- ---------------------------------------------------------------------------------------------------------------
-- Files

function M.read(path)
    local f = io.open(path, "rb")
    if not f then return nil end
    local data = f:read("a")
    f:close()
    return data
end

function M.write(path, data)
    local f = assert(io.open(path, "wb"), "cannot write " .. path)
    f:write(data)
    f:close()
end

function M.fail(message)
    -- sjasmplus reports an error for the line and exits with a non-zero status
    sj.error(message)
    error(message, 0)
end

-- ---------------------------------------------------------------------------------------------------------------
-- The tables (materials/01-original/basic/*.bas). Sinclair BASIC rounds where it stores: POKE and RANDOMIZE take the nearest
-- integer of the magnitude and keep the sign; INT(x+.5) rounds up at .5.

local function poke(v)
    local r = math.floor(math.abs(v) + 0.5)
    if v < 0 then r = -r end
    return r & 0xFF
end

local function bytes(list)
    local parts = {}
    for i = 1, #list do parts[i] = string.char(list[i]) end
    return table.concat(parts)
end

-- sin+.bas: 127*SIN of the middle of each of 256 steps
function M.sin_plus()
    local t = {}
    for n = 0, 255 do t[#t + 1] = poke(127 * math.sin((n + .5) / 256 * 2 * math.pi)) end
    return bytes(t)
end

-- sectg.bas: 128/COS a and 256*TAN a for a in 0..PI/4 (128 steps), INT(x+.5) each
function M.sectg()
    local t = {}
    for n = 0, 127 do t[#t + 1] = math.floor(128 / math.cos(n / 512 * math.pi) + .5) & 0xFF end
    for n = 0, 127 do t[#t + 1] = math.floor(256 * math.tan(n / 512 * math.pi) + .5) & 0xFF end
    return bytes(t)
end

-- sin32768.bas: 32768*SIN as words, low bytes then high bytes. At 90 degrees the formula gives 32768, which a signed
-- word reads as -32768; the author's table holds #7FFF there: the signed maximum
function M.sin32768()
    local lo, hi = {}, {}
    for n = 0, 255 do
        local s = 32768 * math.sin(n / 256 * 2 * math.pi)
        local w = math.floor(math.abs(s) + 0.5)
        if s < 0 then w = -w end
        if w > 0x7FFF then w = 0x7FFF end
        w = w & 0xFFFF
        lo[#lo + 1] = w & 0xFF
        hi[#hi + 1] = w >> 8
    end
    return bytes(lo) .. bytes(hi)
end

-- uv256d.bas: the u,v texture offsets of a 64x32 quarter of the screen, from the far corner inwards
function M.uv256d()
    local t = {}
    for yi = 0, 63 do
        local y = 63.5 - yi
        for xi = 0, 31 do
            local x = 31.5 - xi
            local v = -((y / 64) * 64 * (160 - (x * x) / 64) / 8192) * 64
            local u = -((x / 64) * 64 * (160 - (y * y) / 64) / 8192) * 64
            t[#t + 1] = poke(u)
            t[#t + 1] = poke(v)
        end
    end
    return bytes(t)
end

M.tables = {{"sin+", M.sin_plus}, {"sectg", M.sectg}, {"sin32768", M.sin32768}, {"uv256d", M.uv256d}}

-- ---------------------------------------------------------------------------------------------------------------
-- SHA-256

local K = {
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
}

local function rotr(x, n) return ((x >> n) | (x << (32 - n))) & 0xFFFFFFFF end

function M.sha256(message)
    local h = {0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19}
    local length = #message
    message = message .. "\128" .. string.rep("\0", (55 - length) % 64) .. string.pack(">I8", length * 8)
    local w = {}
    for chunk = 1, #message, 64 do
        for j = 0, 15 do w[j] = string.unpack(">I4", message, chunk + j * 4) end
        for j = 16, 63 do
            local s0 = rotr(w[j - 15], 7) ~ rotr(w[j - 15], 18) ~ (w[j - 15] >> 3)
            local s1 = rotr(w[j - 2], 17) ~ rotr(w[j - 2], 19) ~ (w[j - 2] >> 10)
            w[j] = (w[j - 16] + s0 + w[j - 7] + s1) & 0xFFFFFFFF
        end
        local a, b, c, d, e, f, g, hh = h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8]
        for j = 0, 63 do
            local t1 = (hh + (rotr(e, 6) ~ rotr(e, 11) ~ rotr(e, 25)) + ((e & f) ~ (~e & g)) + K[j + 1] + w[j]) & 0xFFFFFFFF
            local t2 = ((rotr(a, 2) ~ rotr(a, 13) ~ rotr(a, 22)) + ((a & b) ~ (a & c) ~ (b & c))) & 0xFFFFFFFF
            hh, g, f, e, d, c, b, a = g, f, e, (d + t1) & 0xFFFFFFFF, c, b, a, (t1 + t2) & 0xFFFFFFFF
        end
        h[1], h[2], h[3], h[4] = (h[1] + a) & 0xFFFFFFFF, (h[2] + b) & 0xFFFFFFFF, (h[3] + c) & 0xFFFFFFFF, (h[4] + d) & 0xFFFFFFFF
        h[5], h[6], h[7], h[8] = (h[5] + e) & 0xFFFFFFFF, (h[6] + f) & 0xFFFFFFFF, (h[7] + g) & 0xFFFFFFFF, (h[8] + hh) & 0xFFFFFFFF
    end
    return string.format("%08x%08x%08x%08x%08x%08x%08x%08x", h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8])
end

-- ---------------------------------------------------------------------------------------------------------------
-- TR-DOS

-- Every file of a TRD image: {name = "kishki", type = "C", start = n, length = n, data = bytes (up to the length)}
function M.read_trd(path)
    local image = M.read(path) or M.fail("no disk image " .. path)
    local files = {}
    for i = 0, 127 do
        local e = image:sub(i * 16 + 1, i * 16 + 16)
        local first = e:byte(1)
        if first == 0 then break end
        if first ~= 1 then
            local start, length, sectors, sector, track = string.unpack("<I2I2BBB", e, 10)
            local offset = (track * 16 + sector) * 256
            files[#files + 1] = {name = e:sub(1, 8):gsub(" +$", ""), type = e:sub(9, 9), start = start, length = length,
                                 data = image:sub(offset + 1, offset + length)}
        end
    end
    return files
end

function M.find(files, name, type)
    for _, f in ipairs(files) do
        if f.name == name and f.type == type then return f end
    end
    return nil
end

local function descriptor(e, sectors)
    return (e.name .. string.rep(" ", 8)):sub(1, 8) .. e.type .. string.pack("<I2I2B", e.start, e.length, sectors)
end

-- entries: {name, type, start, length, body}
function M.scl(entries)
    local header, data = {"SINCLAIR", string.char(#entries)}, {}
    for _, e in ipairs(entries) do
        local sectors = (#e.body + 255) // 256
        header[#header + 1] = descriptor(e, sectors)
        data[#data + 1] = e.body .. string.rep("\0", sectors * 256 - #e.body)
    end
    local out = table.concat(header) .. table.concat(data)
    local sum = 0
    for i = 1, #out do sum = sum + out:byte(i) end
    return out .. string.pack("<I4", sum & 0xFFFFFFFF)
end

-- ---------------------------------------------------------------------------------------------------------------
-- BASIC (the tokens the two programs use; numbers are written as VAL "n", as the author's launcher does)

local TOKENS = {CLEAR = 0xFD, VAL = 0xB0, RANDOMIZE = 0xF9, USR = 0xC0, REM = 0xEA, LOAD = 0xEF, CODE = 0xAF, RUN = 0xF7}

function M.basic_line(number, parts)
    local body = {}
    for _, p in ipairs(parts) do body[#body + 1] = TOKENS[p] and string.char(TOKENS[p]) or p end
    local text = table.concat(body) .. "\r"
    return string.pack(">I2", number) .. string.pack("<I2", #text) .. text
end

-- A TR-DOS BASIC file: the program, then #80 #AA and the autostart line; start = length = the program's length
function M.basic_file(name, lines, autostart)
    local program = table.concat(lines)
    return {name = name, type = "B", start = #program, length = #program,
            body = program .. "\128\170" .. string.pack("<I2", autostart)}
end

TheLink = M
return M
