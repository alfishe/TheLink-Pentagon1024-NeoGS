; The Link (invdemo, 2009) - release loader (sjasmplus)
;
; Replaces the author's start through the assembler (THELINK.B -> ALASM -> GO). Run from
; THELINK.B after CLEAR 24575 at #6000:
;   1. checks the machine: Pentagon 1024 paging and a NeoGS card; anything else gets an
;      error screen saying what was found, a key returns to BASIC;
;   2. loads the title picture to the screen, the demo's main block to #7800 (src/THELINK.asm)
;      and every page file to #C000 of its page (the table at PageFiles, the ORG #C000,page +
;      INCBIN lines of THELINK.asm); the rest of each page is zeroed, as ALASM left it. A
;      progress bar under the title gets one segment per page file; a missing file turns it
;      into a message naming the file, and a key returns to BASIC;
;   3. selects page 7 and jumps to GO (#7800), as ALASM's RUN did.
;
; TR-DOS from code: #3D13 with the function in C. #0A finds the file named at #5CDD (9 bytes
; compared: name and type, #5D06), #08 reads its descriptor to #5CDD, #05 reads B sectors from
; track D sector E to HL.

        DEVICE NOSLOT64K

TRDOS     EQU #3D13
DESC      EQU #5CDD   ; descriptor: name 8, type 1, start 2, length 2, sectors 1, sector 1, track 1
DESC_LEN  EQU DESC+11
DESC_SECS EQU DESC+13
DESC_SEC  EQU DESC+14
CMP_LEN   EQU #5D06   ; how many descriptor bytes #0A compares

GO        EQU #7800   ; src/THELINK.asm
MAIN_END  EQU #B155   ; end of the main block (tools/release.asm checks it)
RESBUF    EQU #BD00   ; GO's own area starts here

GSCOM     EQU #BB
GSDAT     EQU #B3
GSCTR     EQU #33
GSCFG0    EQU #0F     ; card port, read through GS command #11

        ORG #6000
Start
        JR Begin
        ; The check's result at fixed addresses (tests and debuggers read them)
memoryKind DB #FF       ; #6002: 0 = 1024K paging, 1 = 128K, 2 = 512K
soundKind  DB #FF       ; #6003: 0 = NeoGS, 1 = GS that is not a NeoGS, 3 = no card
Begin
        LD IY,#5C3A
        CALL CheckMemory
        LD (memoryKind),A
        CALL FindNeoGS
        LD (soundKind),A
        LD A,(memoryKind)
        LD B,A
        LD A,(soundKind)
        OR B
        JP NZ,MachineError

        ; Title while the rest loads, a progress bar under it
        LD HL,NameTitle
        LD DE,#4000
        CALL LoadFile
        JP C,FileError
        CALL ProgressInit

        LD HL,NameMain
        LD DE,GO
        CALL LoadFile
        JP C,FileError
        LD HL,MAIN_END          ; the last sector's padding: zero up to GO's area
        LD BC,RESBUF-MAIN_END
        CALL ZeroArea

        LD IX,PageFiles
.page
        LD A,(IX+0)
        OR A
        JR Z,.started
        LD BC,#7FFD
        OUT (C),A
        PUSH IX
        POP HL
        INC HL
        LD DE,#C000
        CALL LoadFile
        JP C,FileError
        ; HL = the end of the file: zero the rest of the page (none when it ends at #FFFF)
        LD A,H
        OR L
        JR Z,.next
        LD B,H
        LD C,L
        XOR A
        SUB C
        LD C,A
        LD A,0
        SBC A,B
        LD B,A                  ; BC = #10000 - HL
        CALL ZeroArea
.next
        CALL ProgressStep       ; one segment per page file
        LD DE,10
        ADD IX,DE
        JR .page
.started
        ; GO clears #D800-#DAFF of the page at #C000 (it loads A with #17 for screen 1's attributes
        ; but never OUTs it), and the last page loaded is the music: page 7 there, as the author meant
        LD A,#17
        LD BC,#7FFD
        OUT (C),A
        JP GO

; HL -> 9-byte name and type, DE = address. Loads the whole file; HL = address + length.
; Carry set: not found (HL -> the name).
LoadFile
        PUSH DE
        PUSH HL
        LD DE,DESC
        LD BC,9
        LDIR
        LD A,9
        LD (CMP_LEN),A
        LD C,#0A
        CALL TRDOS
        POP HL
        LD A,C
        CP #FF
        JR NZ,.found
        POP DE
        SCF
        RET
.found
        LD C,#08                ; A = the catalog entry
        CALL TRDOS
        POP HL
        PUSH HL
        LD A,(DESC_SECS)
        LD B,A
        LD DE,(DESC_SEC)        ; E = sector, D = track
        LD C,#05
        CALL TRDOS
        POP HL
        LD BC,(DESC_LEN)
        ADD HL,BC
        OR A
        RET

; ---------------------------------------------------------------------------------------------
; The progress bar: under the title, a black box (attribute rows 20-22, columns 1-30) with a
; white frame, and one white segment per page file (28: screen columns 2-29, 6 pixels of each
; byte, 12 lines). Every segment is a whole byte, so a segment is one write per line.

BAR_TOP   EQU 166                 ; the first pixel line of the segments
BAR_LINES EQU 12
BAR_COL   EQU 2                   ; the screen column of segment 0

ProgressInit
        LD A,#47                  ; the box: bright white ink on black paper
        CALL BarBox
        LD A,163                  ; the frame: lines 163 and 180, x = 12..243
        CALL FrameLine
        LD A,180
        CALL FrameLine
        LD A,164                  ; and x = 12 and x = 243 on the lines between
.side
        PUSH AF
        LD C,1
        CALL PixelAddress
        LD A,(HL)
        OR #08                    ; x = 12: column 1, bit 3
        LD (HL),A
        POP AF
        PUSH AF
        LD C,30
        CALL PixelAddress
        LD A,(HL)
        OR #10                    ; x = 243: column 30, bit 4
        LD (HL),A
        POP AF
        INC A
        CP 180
        JR NZ,.side
        XOR A
        LD (segment),A
        INC A
        LD (barShown),A
        RET

; The box under the title in attribute A: rows 20-22, columns 1-30, its pixels cleared
BarBox
        LD C,A
        LD HL,#5800+20*32+1
        LD B,3
.attr
        PUSH BC
        PUSH HL
        LD (HL),C
        LD D,H
        LD E,L
        INC DE
        LD BC,29
        LDIR
        POP HL
        LD DE,32
        ADD HL,DE
        POP BC
        DJNZ .attr
        LD A,160                  ; lines 160-183
.clear
        PUSH AF
        LD C,1
        CALL PixelAddress
        LD (HL),0
        LD D,H
        LD E,L
        INC DE
        LD BC,29
        LDIR
        POP AF
        INC A
        CP 184
        JR NZ,.clear
        RET

; A file did not load after the bar appeared (HL -> its name): the bar gives way to the
; message, in the same box, under the title
BarError
        PUSH HL
        LD IY,#5C3A
        LD A,#57                  ; bright white ink on red paper
        CALL BarBox
        LD (IY+#31),0             ; DF_SZ = 0: the upper screen has all 24 lines (row 22 is the box's)
        LD A,2
        CALL #1601                ; channel 'S'
        LD HL,TxtBarFail
        CALL Print
        POP HL
        CALL PrintName
        LD HL,TxtBarKey
        CALL Print
        JP WaitKey

; Pixel line A, x = 12..243
FrameLine
        LD C,1
        CALL PixelAddress
        LD (HL),#0F
        INC L
        LD B,28
.byte
        LD (HL),#FF
        INC L
        DJNZ .byte
        LD (HL),#F0
        RET

; The next segment
ProgressStep
        LD A,(segment)
        LD C,A
        INC A
        LD (segment),A
        LD A,C
        ADD A,BAR_COL
        LD C,A
        LD A,BAR_TOP
        LD B,BAR_LINES
.line
        PUSH AF
        CALL PixelAddress
        LD (HL),%01111110
        POP AF
        INC A
        DJNZ .line
        RET

; HL = the screen address of pixel line A (0-191) at column C (0-31); keeps B, C, DE
PixelAddress
        LD H,A
        AND 7
        OR #40
        LD L,A
        LD A,H
        AND #C0
        RRCA
        RRCA
        RRCA
        OR L
        LD L,A                    ; the high byte: #40 + the third + the line in the cell
        LD A,H
        AND #38
        RLCA
        RLCA
        OR C                      ; the low byte: the character row + the column
        LD H,L
        LD L,A
        RET

segment  DB 0                     ; segments drawn
barShown DB 0                     ; 1 once the bar is on screen: a failure shows in its box

; Zero BC bytes from HL (BC >= 1)
ZeroArea
        LD (HL),0
        DEC BC
        LD A,B
        OR C
        RET Z
        LD D,H
        LD E,L
        INC DE
        LDIR
        RET

; ---------------------------------------------------------------------------------------------
; The machine

; A = 0: Pentagon 1024 paging; 1: 128K; 2: 512K.
; One marker per page at #C000, pages 0, 8, 16, 24 (#7FFD bits 6, 7) and then 32 (bit 5, the
; Pentagon 1024 bit; on a 512K Pentagon it is the paging lock, so it is tried last).
CheckMemory
        LD BC,#EFF7
        XOR A
        OUT (C),A               ; #EFF7 bit 2 = 0: 1024K paging on a Pentagon 1024SL
        LD HL,MemProbe+3
        LD E,4
.write
        LD A,(HL)
        LD BC,#7FFD
        OUT (C),A
        LD A,E
        LD (#C000),A
        DEC HL
        DEC E
        JR NZ,.write
        LD HL,MemProbe
        LD E,1
.read
        LD A,(HL)
        LD BC,#7FFD
        OUT (C),A
        LD A,(#C000)
        CP E
        LD A,1
        JR NZ,.done             ; pages 0..24 are not apart: 128K
        INC HL
        INC E
        LD A,E
        CP 5
        JR NZ,.read
        LD A,#30                ; page 32
        LD BC,#7FFD
        OUT (C),A
        LD A,5
        LD (#C000),A
        LD A,#10                ; page 0 must still hold its own marker
        OUT (C),A
        LD A,(#C000)
        CP 1
        LD A,2
        JR NZ,.done             ; bit 5 did not select page 32: 512K
        XOR A
.done
        LD BC,#7FFD
        LD E,#10
        OUT (C),E
        RET
MemProbe
        DB #10,#50,#90,#D0      ; pages 0, 8, 16, 24

; A = 0: NeoGS; 1: a General Sound that is not NeoGS; 3: no card.
; As the NeoGS flasher's FINDNGS (neogs/z80/flasher/flasher.a80): reset the card, command #F3,
; wait for the command to be taken (the flasher waits 48 frames; a classic GS needs longer), then command #11 reads card port GSCFG0:
; #FF there is not a NeoGS.
FindNeoGS
        LD A,#80
        OUT (GSCTR),A
        EI
        HALT
        HALT
        LD A,#F3
        OUT (GSCOM),A
        HALT
        HALT
        LD B,150                ; classic GS: #F3 reboots through its 0.3-1.1 s POST
.wait
        HALT
        DEC B
        JR Z,.none
        IN A,(GSCOM)
        RRA
        JR C,.wait
        LD A,GSCFG0
        OUT (GSDAT),A
        LD A,#11
        OUT (GSCOM),A
.wc
        IN A,(GSCOM)
        RRCA
        JR C,.wc
        IN A,(GSDAT)
        INC A
        LD A,1
        RET Z
        XOR A
        RET
.none
        LD A,3
        RET

; ---------------------------------------------------------------------------------------------
; Error screens

MachineError
        CALL ErrorBox
        LD HL,TxtNeeds
        CALL Print
        LD A,(memoryKind)
        LD HL,TxtMem1024
        OR A
        JR Z,.mem
        LD HL,TxtMem128
        DEC A
        JR Z,.mem
        LD HL,TxtMem512
.mem
        CALL Print
        LD A,(soundKind)
        LD HL,TxtNeoGS
        OR A
        JR Z,.snd
        LD HL,TxtGS
        DEC A
        JR Z,.snd
        LD HL,TxtNoGS
.snd
        CALL Print
        JR WaitKeyAndLeave

FileError
        LD A,(barShown)
        OR A
        JP NZ,BarError
        PUSH HL
        CALL ErrorBox
        LD HL,TxtNoFile
        CALL Print
        POP HL
        CALL PrintName

WaitKeyAndLeave
        LD HL,TxtKey
        CALL Print
WaitKey
        EI
.release
        XOR A
        IN A,(#FE)
        CPL
        AND #1F
        JR NZ,.release
.press
        XOR A
        IN A,(#FE)
        CPL
        AND #1F
        JR Z,.press
        LD BC,#7FFD
        LD A,#10
        OUT (C),A
        LD A,7
        OUT (#FE),A
        LD (#5C48),A            ; BORDCR: white border, black ink
        LD A,#38
        LD (#5C8D),A            ; ATTR_P: black on white
        LD (IY+#31),2           ; DF_SZ back to BASIC's 2 lines (the bar's message set it to 0)
        CALL #0D6B              ; CLS
        RET                     ; back to BASIC

; Black screen, a red frame and a blue box (attributes), the title, the print channel open
ErrorBox
        LD IY,#5C3A
        XOR A
        OUT (#FE),A
        LD HL,#4000
        LD BC,#1800
        CALL ZeroArea
        LD HL,#5800
        LD BC,#300
        CALL ZeroArea
        LD HL,#5800+3*32+2      ; frame: rows 3-19, columns 2-29
        LD A,#50                ; bright red paper
        LD B,17
.frame
        PUSH BC
        PUSH HL
        LD B,28
.frow
        LD (HL),A
        INC HL
        DJNZ .frow
        POP HL
        LD DE,32
        ADD HL,DE
        POP BC
        DJNZ .frame
        LD HL,#5800+4*32+3      ; box: rows 4-18, columns 3-28
        LD A,#4F                ; bright blue paper, white ink
        LD B,15
.box
        PUSH BC
        PUSH HL
        LD B,26
.brow
        LD (HL),A
        INC HL
        DJNZ .brow
        POP HL
        LD DE,32
        ADD HL,DE
        POP BC
        DJNZ .box
        LD A,2
        CALL #1601              ; channel 'S'
        LD HL,TxtTitle
        ; fall through

; HL -> a 9-character TR-DOS name and type: printed as name.T (the name without its trailing blanks)
PrintName
        LD D,H
        LD E,L                    ; DE = the name
        LD B,8
.char
        LD A,(HL)
        CP 33
        JR C,.type                ; a blank ends the name
        PUSH HL
        PUSH BC
        PUSH DE
        RST #10
        POP DE
        POP BC
        POP HL
        INC HL
        DJNZ .char
.type
        PUSH DE
        LD A,'.'
        RST #10
        POP HL
        LD BC,8
        ADD HL,BC
        LD A,(HL)                 ; the type, the 9th byte
        RST #10
        RET

; HL -> text with control codes, #FF ends it
Print
        LD A,(HL)
        CP #FF
        RET Z
        PUSH HL
        RST #10
        POP HL
        INC HL
        JR Print

        MACRO TXT row,col
        DB 22,row,col,16,7,17,1,19,1
        ENDM

TxtTitle  DB 22,6,11,16,6,17,1,19,1,"THE  LINK",#FF
TxtNeeds  TXT 8,4
          DB "This demo needs a"
          TXT 9,4
          DB "Pentagon 1024 + NeoGS.",#FF
TxtMem1024 TXT 11,4
          DB "Memory: 1024K",16,4," ok",#FF
TxtMem512 TXT 11,4
          DB "Memory: 512K",16,6," too small",#FF
TxtMem128 TXT 11,4
          DB "Memory: 128K",16,6," too small",#FF
TxtNeoGS  TXT 12,4
          DB "Sound:  NeoGS",16,4," ok",#FF
TxtGS     TXT 12,4
          DB "Sound:  GS",16,6," not NeoGS",#FF
TxtNoGS   TXT 12,4
          DB "Sound:  ",16,6,"no GS card",#FF
TxtNoFile TXT 8,4
          DB "A file is missing:"
          TXT 10,6
          DB 16,6,#FF                 ; the name follows here, in yellow
TxtBarFail DB 22,20,9,16,7,17,2,19,1,"LOADING FAILED"
          DB 22,21,3,"File not found: ",#FF
TxtBarKey  DB 22,22,9,"Press any key",#FF
TxtKey    TXT 16,4
          DB "Press any key.",#FF

        ; 9-byte TR-DOS names: 8 characters and the type
NameTitle DB "thelink$C"
NameMain  DB "thelink C"

        ; #7FFD value, name and type (THELINK.asm: ORG #C000,page + INCBIN)
        MACRO PAGEFILE pg,name
        DB pg
        DB name
        ENDM
PageFiles
        PAGEFILE #90,"kishki  C"   ; card data 1..10
        PAGEFILE #91,"baba    C"
        PAGEFILE #92,"baba    0"   ; + zeros to #FFFF: DS -$ in THELINK.asm (the mask)
        PAGEFILE #94,"mill    C"
        PAGEFILE #95,"mill    0"
        PAGEFILE #96,"girl13  2"
        PAGEFILE #97,"blugr   C"
        PAGEFILE #11,"blugr   0"
        PAGEFILE #13,"blugr   1"
        PAGEFILE #14,"blugr   2"
        PAGEFILE #52,"ROTPREGSC"   ; card code 1..9 (10 is GO's GSRESET)
        PAGEFILE #55,"ROBPREGSC"
        PAGEFILE #30,"TUNNELGSC"
        PAGEFILE #31,"ROTATEGSC"
        PAGEFILE #32,"ROTBARGSC"
        PAGEFILE #33,"MULBARGSC"
        PAGEFILE #34,"HEDGEGS C"
        PAGEFILE #35,"BABAGS  C"
        PAGEFILE #36,"TEXGS   C"
        PAGEFILE #B0,"TUNNELZXC"   ; the ZX halves of the effects
        PAGEFILE #B1,"ROTATEZXC"
        PAGEFILE #B2,"ROTBARZXC"
        PAGEFILE #B3,"MULBARZXC"
        PAGEFILE #B4,"HEDGEZX1C"
        PAGEFILE #B5,"HEDGEZX2C"
        PAGEFILE #B6,"BABAZX  C"
        PAGEFILE #B7,"TEXZX   C"
        PAGEFILE #54,"thelinkmC"   ; music (TurboSound FM)
        DB 0
LoaderEnd

        ASSERT LoaderEnd < GO
        SAVEBIN "loader.bin",Start,LoaderEnd-Start
