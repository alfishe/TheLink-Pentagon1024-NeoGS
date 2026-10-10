; The Link - the four tables the author computed with Sinclair BASIC (materials/01-original/basic/sin+.bas, sectg.bas, sin32768.bas,
; uv256d.bas), computed the same way by Lua inside sjasmplus. Written to the folder sjasmplus runs in; the effect
; sources INCBIN them. release.asm checks them against the author's files (SHA-256).
;
;   sjasmplus tools/tables.asm         (the build scripts run it first, in build/obj)

        INCLUDELUA "lua/thelink.lua"

        LUA PASS1
            for _, t in ipairs(TheLink.tables) do
                TheLink.write(t[1], t[2]())
            end
        ENDLUA
