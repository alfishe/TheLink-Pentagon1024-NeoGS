; The Link - the release disk, and the check of everything built
;
;   sjasmplus [-DSTAGE=1|2] tools/release.asm      (the build scripts run it last, in build/obj)
;
; 0. No assembly of the build warned (the build scripts keep each one's messages in build/obj/<source>.log).
; 1. Every file built from source - the four tables, the 19 effect objects, the main block - is checked against the
;    SHA-256 of the author's file on his working disk (materials/01-original/TheLink.trd). A difference stops the build.
; 2. The release disk is written as build/TheLink-NonDirectorsCut.scl (a stage: build/TheLink-stageN.scl):
;      boot     B   10 RANDOMIZE USR VAL "15619": REM : RUN "THELINK"                 (autostart, prints nothing)
;      THELINK  B   10 CLEAR VAL "24575": RANDOMIZE USR VAL "15619": REM : LOAD "loader" CODE
;                   20 RANDOMIZE USR VAL "24576"                                      (autostart)
;      loader   C   #6000   src/loader/loader.asm
;      thelink$ C   #4000   the title picture, on screen while the rest loads
;      thelink  C   #7800   the main block (src/THELINK.asm)
;      ...      C   #C000   the 28 page files of the loader's PageFiles table, in its order
; 3. The disk's SHA-256 is compared with the one this source was published with.
;
; EXPERIMENT=1 (build.sh experiment) reports a difference instead of stopping: for changed sources.
; STAGE=1 / STAGE=2 build the earlier stages instead (materials/02-addons/README.md): the main block from the hand port
; materials/02-addons/stageN-*/thelink_main.asm, the loader of the stage, and the page files from the author's disk as they are.

        INCLUDELUA "lua/thelink.lua"

        LUA PASS1
            local T = TheLink
            local stage = sj.get_define("STAGE")
            -- EXPERIMENT: build a changed source anyway (a difference from the author's files is reported, not fatal)
            local experiment = sj.get_define("EXPERIMENT")
            local function differs(message)
                if experiment then print("differs (experiment): " .. message) else T.fail(message) end
            end
            local DATA = "../../src/data/"
            local ORIGINAL = "../../materials/01-original/TheLink.trd"

            -- SHA-256 of the author's files (materials/01-original/TheLink.trd) and of the ALASM-built main block
            local EXPECTED = {
                ["sin+"] = "e5480080f522f00bbfef4794f1cb9dff01c9cf34718ebfc95c88405662400184",
                ["sectg"] = "2d2af29ff51dcde8370578307bc5ed7f777e61c3c3773b59ff852dce5bcdcaf2",
                ["sin32768"] = "ca9ced7298ceff70ea526364c5672eb6812e1c4009343268d0ff956b76f481d7",
                ["uv256d"] = "b9ff0b9cc69bbf8f91b86b35c12af4db335da0ccbd175de9ecccf34171478a1a",
                TUNNELZX = "2ffb86c212c51a4d84d55277fdba1cb9312647a2df168c23ce07603a2a3bdf07",
                TUNNELGS = "ed184d59a9916c57f8d3fc8b28e32b961b386b3149c2aed8eea70208a381926e",
                ROTATEZX = "07f5698b33cfe39bd9bfb30484b72007598c33e01f327d618841796320e98792",
                ROTPREGS = "68aec8a29a3296e8d9aebe0f9ab7da25c3322b9a46db0bf2ccfb7b2d75945658",
                ROTATEGS = "6b7ea53341f3352e34f3deeb53668425a849292927036d6b5310c7f3cddfa0b2",
                ROTBARZX = "6570b908ee0b55dfda44e5e5399564cbb35c4b46b6f713466c9660ecefcf4acc",
                ROBPREGS = "cb3044671c5e1e55af806c326a27572dca4d5290b763cce78fb9fbe3427d040d",
                ROTBARGS = "348a2da9afe17736b0a7b484731a66954db56e3dd34602cfdc3bde4fd27a06c9",
                MULBARZX = "278dd9c03e3046c2eaabf0e152745c2a0a83e570417091403542af6e2a71c1d1",
                MULBARGS = "8890df4b71022ea30964449908c0e1028c34bcdd2d25d7bff1541f342ab0847b",
                HEDGEZX1 = "5fcfab06e91245c9ec6fd0c1540ff31fcd0517006089be8d208c978d5a8e8273",
                HEDGEZX2 = "b5a5097734cc04793de492d9b0a6cf76a4dc04b2e8223edaee852122961e0544",
                HEDGEGS = "c3e6fb279cd7a3beb36ea9a1ada81eed1245e23f46333e0c3ede258d6c0fa2a4",
                BABAZX = "f258b87c43270ddccaeff6cd6cf5bf22af77b7a09cab13a961d2998d756a949e",
                BABAGS = "26c0f35ed24bc6547a7b6b337f0c609a7a33b7d399b9d3267be76f2145a34bf4",
                TEXZX = "4955f4a3147655d9b0a5266f88d27a7a5adca03cb48a3c6fa6620a4a7a617af3",
                TEXGS = "162533e0b591fa56ad904e100cefc2e28e80fc7415d0b4bde50c145021721e18",
                -- #7800..#B154 as ALASM assembles THELINK.asm (14677 bytes)
                thelink = "d1df30757f04f5ac302bd62e1c82f6a1bee2f63c95e0238b4454ff1dd302b147",
            }
            -- The disks as published (materials/02-addons/README.md): the final build is stage 2 plus the progress bar
            local DISK = {
                final = "5102376be31748368993c275bcd9dcd834e5ed131feee115ecd3bc46a9d0af22",
                ["1"] = "ff5a446eef0fba2300d136e89721f766733229c4042f8619caf6417483851ada",
                ["2"] = "53dd7ad7a007f74adcc60316c19d3632e506a1df54a93b0943c25334f9ee704d",
            }
            -- The objects the seven effect units write (their SAVEBIN lines)
            local OBJECTS = {"TUNNELZX", "TUNNELGS", "ROTATEZX", "ROTPREGS", "ROTATEGS", "ROTBARZX", "ROBPREGS", "ROTBARGS",
                             "MULBARZX", "MULBARGS", "HEDGEZX1", "HEDGEZX2", "HEDGEGS", "BABAZX", "BABAGS", "TEXZX", "TEXGS"}
            local MAIN_ORG, MAIN_END = 0x7800, 0xB155   -- loader.asm's GO and MAIN_END

            -- The loader's PageFiles table: name and type, in its order
            local PAGE_FILES = {
                {"kishki", "C"}, {"baba", "C"}, {"baba", "0"}, {"mill", "C"}, {"mill", "0"}, {"girl13", "2"},
                {"blugr", "C"}, {"blugr", "0"}, {"blugr", "1"}, {"blugr", "2"},
                {"ROTPREGS", "C"}, {"ROBPREGS", "C"}, {"TUNNELGS", "C"}, {"ROTATEGS", "C"}, {"ROTBARGS", "C"},
                {"MULBARGS", "C"}, {"HEDGEGS", "C"}, {"BABAGS", "C"}, {"TEXGS", "C"},
                {"TUNNELZX", "C"}, {"ROTATEZX", "C"}, {"ROTBARZX", "C"}, {"MULBARZX", "C"}, {"HEDGEZX1", "C"},
                {"HEDGEZX2", "C"}, {"BABAZX", "C"}, {"TEXZX", "C"},
                {"thelinkm", "C"},
            }

            -- 0. No assembly warned: the build scripts keep each sjasmplus run's messages in <source>.log (a check here
            -- works the same on every system)
            local LOGS = stage and {"thelink_main", "loader"} or
                         {"tables", "GSTUNNE4", "GSROTAT7", "GSRBAR24", "GSMULBA3", "hedge12", "baba4", "TEX28", "THELINK", "loader"}
            for _, name in ipairs(LOGS) do
                local log = T.read(name .. ".log")
                for line in (log or ""):gmatch("[^\r\n]+") do
                    if line:lower():find("warning", 1, true) then T.fail(name .. ".asm: " .. line) end
                end
            end

            -- 1. The checks
            local function check(name, file)
                local data = T.read(file or name) or T.fail("not built: " .. (file or name))
                local digest = T.sha256(data)
                if digest ~= EXPECTED[name] then
                    differs(name .. " differs from the author's file (" .. #data .. " bytes, sha256 " .. digest .. ")")
                end
                return data
            end
            local main
            if stage then
                main = check("thelink", "thelink_main.bin")
            else
                for _, t in ipairs(T.tables) do check(t[1]) end
                for _, name in ipairs(OBJECTS) do check(name) end
                main = check("thelink")
            end
            if MAIN_ORG + #main ~= MAIN_END then
                -- the loader zeroes from MAIN_END: a longer block needs loader.asm's MAIN_END changed too
                T.fail(string.format("the main block ends at #%04X, loader.asm's MAIN_END says #%04X", MAIN_ORG + #main, MAIN_END))
            end
            local loader = T.read("loader.bin") or T.fail("not built: loader.bin")

            -- 2. The disk
            local original = stage and T.read_trd(ORIGINAL) or nil
            local function page_file(name, type)
                if original then
                    local f = T.find(original, name, type) or T.fail("not on the author's disk: " .. name .. "." .. type)
                    return f.data
                end
                -- Built objects in build/obj; data files as their INCBIN names them: "name.T", or "name" for type C
                for _, host in ipairs({name .. "." .. type, type == "C" and name or nil}) do
                    local data = T.read(host) or T.read(DATA .. host)
                    if data then return data end
                end
                T.fail("no file for " .. name .. "." .. type)
            end
            local title = T.read(DATA .. "thelink$") or T.fail("no title picture")
            local entries = {
                T.basic_file("boot", {T.basic_line(10, {"RANDOMIZE", "USR", "VAL", '"15619"', ":", "REM", ":", "RUN", '"THELINK"'})}, 10),
                T.basic_file("THELINK", {
                    T.basic_line(10, {"CLEAR", "VAL", '"24575"', ":", "RANDOMIZE", "USR", "VAL", '"15619"', ":", "REM", ":", "LOAD", '"loader"', "CODE"}),
                    T.basic_line(20, {"RANDOMIZE", "USR", "VAL", '"24576"'})}, 10),
                {name = "loader", type = "C", start = 0x6000, length = #loader, body = loader},
                {name = "thelink$", type = "C", start = 0x4000, length = #title, body = title},
                {name = "thelink", type = "C", start = MAIN_ORG, length = #main, body = main},
            }
            for _, p in ipairs(PAGE_FILES) do
                local data = page_file(p[1], p[2])
                entries[#entries + 1] = {name = p[1], type = p[2], start = 0xC000, length = #data, body = data}
            end
            local scl = T.scl(entries)
            local name = stage and ("TheLink-stage" .. stage .. ".scl") or "TheLink-NonDirectorsCut.scl"
            T.write("../" .. name, scl)

            -- 3. The disk as published
            local digest = T.sha256(scl)
            local sectors = 0
            for _, e in ipairs(entries) do sectors = sectors + (#e.body + 255) // 256 end
            print(string.format("%s: %d files, %d sectors, loader #6000..#%04X, main block #7800..#%04X",
                                name, #entries, sectors, 0x5FFF + #loader, MAIN_END - 1))
            if digest ~= DISK[stage or "final"] then
                differs(name .. " differs from the published disk (sha256 " .. digest .. ")")
            else
                print(name .. ": the published disk, byte for byte (sha256 " .. digest .. ")")
            end
        ENDLUA
