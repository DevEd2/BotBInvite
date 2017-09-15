; ================
; BotB Invite demo
; ================

; ================================================================
; Project includes
; ================================================================

include	"Variables.asm"
include	"Constants.asm"
include	"Macros.asm"
include	"hardware.inc"

; ================================================================
; Reset vectors (actual ROM starts here)
; ================================================================

SECTION	"Reset $00",ROM0[$00]
Reset00:
	halt
	ld	a,[VBlankFlag]
	and	a
	jr	z,Reset00
	ret

SECTION	"Reset $10",ROM0[$10]
Reset10:	ret

SECTION	"Reset $18",ROM0[$18]
Reset18:	ret

SECTION	"Reset $20",ROM0[$20]
Reset20:	ret

SECTION	"Reset $28",ROM0[$28]
Reset28:	ret

SECTION	"Reset $30",ROM0[$30]
Reset30:	ret

SECTION	"Reset $38",ROM0[$38]
Reset38:	ret

; ================================================================
; Interrupt vectors
; ================================================================

SECTION	"VBlank interrupt",ROM0[$40]
IRQ_VBlank:
	jp	VBlank

SECTION	"LCD STAT interrupt",ROM0[$48]
IRQ_STAT:
	jp	LCDStat

SECTION	"Timer interrupt",ROM0[$50]
IRQ_Timer:
	reti

SECTION	"Serial interrupt",ROM0[$58]
IRQ_Serial:
	reti

SECTION	"Joypad interrupt",ROM0[$60]
IRQ_Joypad:
	reti
	
; ================================================================
; System routines
; ================================================================

include	"SystemRoutines.asm"

; ================================================================
; ROM header
; ================================================================

SECTION	"ROM header",ROM0[$100]

EntryPoint:
	nop
	jp	ProgramStart

NintendoLogo:	; DO NOT MODIFY OR ROM WILL NOT BOOT!!!
	db	$ce,$ed,$66,$66,$cc,$0d,$00,$0b,$03,$73,$00,$83,$00,$0c,$00,$0d
	db	$00,$08,$11,$1f,$88,$89,$00,$0e,$dc,$cc,$6e,$e6,$dd,$dd,$d9,$99
	db	$bb,$bb,$67,$63,$6e,$0e,$ec,$cc,$dd,$dc,$99,$9f,$bb,$b9,$33,$3e

ROMTitle:		db	"BOTB INVITE"		; ROM title (11 bytes)
ProductCode		db	0,0,0,0				; product code (4 bytes)
GBCSupport:		db	0					; GBC support (0 = DMG only, $80 = DMG/GBC, $C0 = GBC only)
NewLicenseCode:	db	"DS"				; new license code (2 bytes)
SGBSupport:		db	0					; SGB support
CartType:		db	$19					; Cart type, see hardware.inc for a list of values
ROMSize:		ds	1					; ROM size (handled by post-linking tool)
RAMSize:		db	0					; RAM size
DestCode:		db	1					; Destination code (0 = Japan, 1 = All others)
OldLicenseCode:	db	$33					; Old license code (if $33, check new license code)
ROMVersion:		db	0					; ROM version
HeaderChecksum:	ds	1					; Header checksum (handled by post-linking tool)
ROMChecksum:	ds	2					; ROM checksum (2 bytes) (handled by post-linking tool)

; ====================
; Actual program start
; ====================

ProgramStart:
	push	af
	di
	call	ClearWRAM
	ld	a,RETI_OP	; reti
	ld	[VBlank], a
	ld	[LCDStat], a
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	ei
	
	; check for Nintendo logo in VRAM
	ld	hl,EmergencyNintendoLogo+$10
	ld	de,$8000+$10
	ld	c,$10
.logoloop
	ld	a,[hl+]
	ld	b,a
	; wait for VRAM accessibility, otherwise we may get incorrect data
.wait2
	ldh	a,[rSTAT]
	and	2
	jr	nz,.wait2
	ld	a,[de]
	inc	de
	cp	b
	jr	nz,.nologo
	dec	c
	jr	nz,.logoloop
	jr	.continue
	
.nologo
	ld	a,1
	ld	[ShowLogo],a
.continue
	
	; check for GBC
	pop	af
	cp	$11	; are we on GBC?
	jp	nz,StartDemo
	ld	a,1
	ld	[ShowLogo],a
	; disable LCD
.wait
	ldh	a,[rLY]
	cp	$90
	jr	nz,.wait
	xor	a
	ldh	[rLCDC],a
	
	CopyTileset	Font,0,64
	ld	hl,.gbctext
	call	LoadMapText
	ld	a,%11100100
	ldh	[rBGP],a
	xor	%01110101
	ldh	[rLCDC],a
	
	ei
	
.waitforbutton
	call	CheckInput
	ld	a,[sys_btnPress]
	bit	btnA,a
	jp	nz,StartDemo
	halt
	jr	.waitforbutton	
	
.gbctext
	db	"    ! WARNING !     "
	db	"                    "
	db	"   THIS DEMO WAS    "
	db	"DESIGNED TO RUN ON A"
	db	"MONOCHROME GAME BOY."
	db	"THE DEMO WILL STILL "
	db	" WORK (FOR THE MOST "
	db	"   PART), BUT WE    "
	db	" RECOMMEND RUNNING  "
	db	"   THE DEMO ON AN   "
	db	" ORIGINAL GAME BOY, "
	db	" A GAME BOY POCKET, "
	db	"OR A SUPER GAME BOY "
	db	" FOR BEST RESULTS.  "
	db	"                    "
	db	"                    "
	db	"                    "
	db	"PRESS A TO CONTINUE."
	
StartDemo:
	ld	a,[ShowLogo]
	and	a
	jr	z,.continue
	call	EmergencyBootROM
.continue
	; pigdevil2010: logo joke goes here

ShowScreen1:
	halt
	di
	xor	a
	ldh	[rLCDC],a	; disable	LCD
	ld	a,JP_OP
	ld	[VBlank],a
	ld	a,DoVBlank % $100
	ld	[VBlank+1],a
	ld	a,DoVBlank / $100
	ld	[VBlank+2],a
	CopyBytes	DoStat,LCDStat,DoStatEnd-DoStat
	ld	a,IEF_VBLANK+IEF_LCDC
	ld	[rIE],a
	ei
	CopyTileset			Logo1,0,120
	CopyTileset			StarTiles,$1000,5
	CopyTilesetInverted	Font,$800,64
	ld	hl,Logo1Map
	ld	de,_SCRN0
	call	LoadMap
	ld	a,90		; a = 01011010
	ldh	[rSCY],a
	xor	%10111110	; a = 11100100
	ldh	[rBGP],a
	ldh	[rOBP0],a
	cpl				; a = 00011011
	ldh	[rOBP1],a
	xor	%10001010	; a = 10010001
	ldh	[rLCDC],a
	
IntroAnimLoop1:
	halt
	ldh	a,[rSCY]
	sub	4
	ldh	[rSCY],a
	bit	7,a
	jr	z,IntroAnimLoop1
	
	xor	a
	ldh	[rSCY],a
	; start music here
	ld	hl,ScreenShakeTable
	
IntroAnimLoop2:
	halt
	ld	a,[hl+]
	ldh	[rSCY],a
	cp	$80
	jr	nz,IntroAnimLoop2
	xor	a
	ldh	[rSCY],a
	
	ld	a,88		; a = 01011000
	ldh	[rLYC],a
	xor	%00011000	; a = 01000000
	ldh	[rSTAT],a
	
MainLoop:
	xor	a
	ldh	[rSCX],a
	ldh	[rSCY],a
	rst	$00			; wait for VBlank
	jr	MainLoop

; =============
; Misc routines
; =============

_CopyBytes:
	inc	b
	inc	c
	dec	c
	jr	nz,.loop
	dec	b
.loop
	ld	a,[hli]
	ld	[de],a
	inc	de
	dec	c
	jr	nz,.loop
	dec	b
	jr	nz,.loop
	ret

EmergencyBootROM:
	halt
	xor	a
	ldh	[rLCDC],a
	
	call	ClearVRAM
	
	CopyTileset	EmergencyNintendoLogo,0,$1a
	
	ld	hl,EmergencyNintendoMap
	ld	de,$9904
	ld	b,$2c
.copyloop
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	b
	jr	nz,.copyloop
	
	ld	a,%000001100
	ldh	[rBGP],a
	ld	a,%10010001
	ldh	[rLCDC],a
	
	; Here comes the fun part! Simulating the GB boot ROM on a GBC
	; Most of the code was adapted from http://gbdev.gg8.se/wiki/articles/Gameboy_Bootstrap_ROM, with some minor alterations
	di
	ld	h,0			; init scroll count
	ld	a,$64		
	ld	d,a			; init loop count
	ldh	[rSCY],a
	ld	a,%10010001
	ldh	[rLCDC],a	; enable LCD
	ld	b,1			; was inc b (would break on GBA)
.addr60
	ld	e,2
.addr62
	ld	c,$c
.addr64
	ldh	a,[rLY]
	cp	$91
	jr	nz,.addr64
	dec	c
	jr	nz,.addr64
	dec	e
	jr	nz,.addr62
	
	ld	c,$13
	inc	h			; increment scroll count
	ld	a,h
	ld	e,$83
	cp	$62
	jr	z,.playtone1
	ld	e,$c1
	cp	$64
	jr	nz,.playtone2
.playtone1
	ld	a,e
	ld	[c],a	; play sound
	inc	c
	ld	a,$87
	ld	[c],a
.playtone2
	ld	a,[rSCY]
	sub	b
	ld	[rSCY],a
	dec	d
	jr	nz,.addr60
	dec	b
	jr	nz,.exit
	ld	d,$20
	jr	.addr60
	
.exit
	reti
	
; =========
; Misc data
; =========

ScreenShakeTable:
	db	3,6,3,0,3,6,3,0,2,5,3,0,2,5,3,0
	db	2,4,2,0,2,4,2,0,1,3,2,0,1,3,2,0
	db	1,2,1,0,1,2,1,0,1,1,1,0,1,1,0,0,$80
	
ScrollerBounceTable:
	db	48,49,50,52,53,54,55,56,57,59,60,61,62,63,64,65
	db	66,67,69,70,71,72,73,74,75,76,77,78,78,79,80,81
	db	82,83,84,84,85,86,87,87,88,89,89,90,90,91,91,92
	db	92,93,93,94,94,94,95,95,95,95,95,96,96,96,96,96
	db	96,96,96,96,96,96,95,95,95,95,95,94,94,94,93,93
	db	92,92,91,91,90,90,89,89,88,87,87,86,85,84,84,83
	db	82,81,80,79,78,78,77,76,75,74,73,72,71,70,69,67
	db	66,65,64,63,62,61,60,59,57,56,55,54,53,52,50,49
	db	$ff
	
; ==================
; Interrupt routines
; ==================

DoVBlank:
	ld	a,1
	ld	[VBlankFlag],a
	reti

DoStat:
	call	WaitStat
	ld	a,[ScrollTablePos]
	inc	a
	ld	[ScrollTablePos],a
.restart
	ld	hl,ScrollerBounceTable
	add	l
	ld	l,a
	jr	nz,.nocarry
	inc	h
.nocarry
	ld	a,[hl+]
	cp	$ff
	jr	nz,.noloop
	xor	a
	ld	[ScrollTablePos],a
	jr	.restart
.noloop
	add	208
	ldh	[rSCY],a
	ld	a,[ScrollerXPos]
	inc	a
	ld	[ScrollerXPos],a
	ldh	[rSCX],a
	xor	a
	ld	[VBlankFlag],a
	reti
DoStatEnd

; =================
; Graphics routines
; =================

_CopyTileset:
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,_CopyTileset
	ret
	
_CopyTileset1BPP:
	ld	a,[hl+]			; get tile
	ld	[de],a			; write tile
	inc	de				; increment destination address
	ld	[de],a			; write tile again
	inc	de				; increment destination address again
	dec	bc
	dec	bc				; since we're copying two tiles, we need to dec bc twice
	ld	a,b
	or	c
	jr	nz,_CopyTileset1BPP
	ret
	
_CopyTilesetInverted
	ld	a,[hl+]
	cpl
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,_CopyTilesetInverted
	ret
	
; =============
; Graphics data
; =============

Font:					incbin	"Font.bin"

EmergencyNintendoLogo:	incbin	"GFX/NintendoLogoGFX.bin"
EmergencyNintendoMap:	incbin	"GFX/NintendoMap.bin"

Logo1:					incbin	"GFX/Logo1.bin"
Logo1Map:				incbin	"GFX/Logo1Map.bin"

StarTiles:				incbin	"GFX/StarTiles.bin"