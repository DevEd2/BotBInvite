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

SECTION	"Reset $00",HOME[$00]
Reset00:	ret

SECTION	"Reset $08",HOME[$08]
Reset08:	ret

SECTION	"Reset $10",HOME[$10]
Reset10:	ret

SECTION	"Reset $18",HOME[$18]
Reset18:	ret

SECTION	"Reset $20",HOME[$20]
Reset20:	ret

SECTION	"Reset $28",HOME[$28]
Reset28:	ret

SECTION	"Reset $30",HOME[$30]
Reset30:	ret

SECTION	"Reset $38",HOME[$38]
Reset38:	ret

; ================================================================
; Interrupt vectors
; ================================================================

SECTION	"VBlank interrupt",HOME[$40]
IRQ_VBlank:
	reti

SECTION	"LCD STAT interrupt",HOME[$48]
IRQ_STAT:
	reti

SECTION	"Timer interrupt",HOME[$50]
IRQ_Timer:
	reti

SECTION	"Serial interrupt",HOME[$58]
IRQ_Serial:
	reti

SECTION	"Joypad interrupt",Home[$60]
IRQ_Joypad:
	reti
	
; ================================================================
; System routines
; ================================================================

include	"SystemRoutines.asm"

; ================================================================
; ROM header
; ================================================================

SECTION	"ROM header",HOME[$100]

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
	ldh	a,[rSTAT]
	and	2
	jr	nz,@-4
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
	xor	a
	ldh	[rLCDC],a	; disable	LCD
	CopyTileset	Logo1,0,120
	ld	hl,Logo1Map
	ld	de,_SCRN0
	call	LoadMap
	ld	a,%11100100
	ldh	[rBGP],a
	xor	%01110101
	ldh	[rLCDC],a
	
MainLoop
	halt
	jr	MainLoop

; =============
; Misc routines
; =============

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

; =============
; Graphics data
; =============

Font:					incbin	"Font.bin"

EmergencyNintendoLogo:	incbin	"GFX/NintendoLogoGFX.bin"
EmergencyNintendoMap:	incbin	"GFX/NintendoMap.bin"

Logo1:					incbin	"GFX/Logo1.bin"
Logo1Map:				incbin	"GFX/Logo1Map.bin"