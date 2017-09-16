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
	ld	[VBlank],a
	ld	[LCDStat],a
	ld	a,IEF_VBLANK
	ldh	[rIE],a
	ei
	
	; unpack Nintendo logo from cartridge header
	ld	hl,EmergencyNintendoLogo
	ld	de,NintendoLogo
	ld	b,48
.unpackloop
	ld	a,[de]
	inc	de
	push	de
	ld	e,a
	call	.scalelogo
	swap	e
	call	.scalelogo
	pop	de
	dec	b
	jr	nz,.unpackloop
	
	; check for Nintendo logo in VRAM
	ld	hl,EmergencyNintendoLogo
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
	
.scalelogo
	xor	a
	ld	d,4
	ld	c,e
.scalelogoloop
	rlca
	rlca
	sla	c
	jr	nc,.scalelogoskip
	add	3
.scalelogoskip
	dec	d
	jr	nz,.scalelogoloop
rept 2
	ld	[hl+],a
	ld	[hl],0
	inc	hl
endr
	ret
	
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
	
StartDemo::
	ld	a,[ShowLogo]
	and	a
	jr	z,.continue
	call	EmergencyBootROM
.continue
	xor	a
	call	DS_Init

	; pigdevil2010: logo joke goes here

ShowScreen1::
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
	
IntroAnimLoop1::
	halt
	ldh	a,[rSCY]
	sub	4
	ldh	[rSCY],a
	bit	7,a
	jr	z,IntroAnimLoop1
	
	xor	a
	ldh	[rSCY],a
	ld	hl,ScreenShakeTable
	
IntroAnimLoop2::
	halt
	ld	a,[hl+]
	ldh	[rSCY],a
	cp	$80
	jr	nz,IntroAnimLoop2
	xor	a
	ldh	[rSCY],a
	ld	a,$ff
	ldh	[rLYC],a
	ld	a,STATF_LYC
	ldh	[rSTAT],a
	
	ld	a,6
	ld	[Scroll2Delay],a
	ld	a,12
	ld	[Scroll3Delay],a
	
	ld	hl,ScrollerText
	ld	a,h
	ld	[ScrollerTextPtr+1],a
	ld	a,l
	ld	[ScrollerTextPtr],a
	ld	hl,ScrollerBaseAddr
	ld	a,h
	ld	[ScrollerPointer+1],a
	ld	a,l
	ld	[ScrollerPointer],a
	ld	a,18
	ld	[ScrollerTextTimer],a
	
MainLoop::
	; TODO: Find a place where DevSound can safely be updated.
	; Either that, or DevSound will need some major optimization...
	rst	$00			; wait for VBlank
	xor	a
	ldh	[rSCX],a
	ldh	[rSCY],a
	ld	[VBlankFlag],a
	ld	a,%11100100
	ld	[rBGP],a
	
	ld	hl,Scroll1
	call	UpdateScroller
	ld	b,a
	ld	c,135
	ld	d,c
	
	ld	a,[Scroll2Delay]
	dec	a
	jr	nz,.skip
	ld	hl,Scroll2
	call	UpdateScroller
	ld	c,a
	ld	a,1
.skip
	ld	[Scroll2Delay],a
	
	ld	a,[Scroll3Delay]
	dec	a
	jr	nz,.skip2
	ld	hl,Scroll3
	call	UpdateScroller
	ld	d,a
	ld	a,1
.skip2
	ld	[Scroll3Delay],a
	
; sort which line comes first
	ld	e,0
	ld	a,b
	cp	c
	rl	e
	cp	d
	rl	e
	ld	a,c
	cp	d
	rl	e
	ld	a,d
	ld	d,0
	ld	hl,.states
	add	hl,de
	add	hl,de
	ld	e,d
	ld	d,a
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	call	_hl_
	
	ld	hl,ScrollLYCTable
	ld	a,b
	ld	[hl+],a
	ld	a,c
	ld	[hl+],a
	ld	a,d
	ld	[hl+],a
	ld	a,e
	ld	[CurScrollId],a
	
.loop
	halt
	ld	a,[CurScrollId]
	and	a
	jr	nz,.loop	
	call	UpdateScrollerText
	jr	MainLoop

; adjust the LYC values so they overlap correctly
	
.states
	dw	.cba,.bca,.bac,.bac,.cab,.cab,.acb,.abc
	
.abc
	ld	a,b
	ld	[rLYC],a
	ld	a,c
	cp	b
	ld	e,%00000001
	jr	z, .ac
	ld	e,%00001001
	cp	d
	jr	z,.abcdone
	ld	e,%00111001
	jr	.abcdone
.ac
	cp	d
	jr	z,.abcdone
	ld	e,%00001101
.abcdone
	ld	a,b
	add	8
	cp	c
	jr	c,.abcnoadjb
	ld	l,a
.abcnoadjb
	ld	a,c
	add	8
	cp	d
	jr	c,.abcnoadjc
	ld	d,a
.abcnoadjc
	ld	c,l
	ret
	
.acb
; since this case is only encountered when c is completely
; behind a and b, the loaded e value will never have 11 in it
; and b's LYC position is adjusted instead
	ld	a,b
	ld	[rLYC],a
	ld	a,d
	cp	b
	ld	e,%00000001
	jr	z,.ab
	ld	e,%00001001
	cp	c
	jr	z,.acbdone
	ld	e,%00001001
	jr	.acbdone
.ab
	cp	c
	jr	z,.acbdone
	ld	e,%00001001
.acbdone
	ld	a,b
	add	8
	cp	c
	ret	c
	ld	c,a
	ret
	
.bac
	ld	a,c
	ld	[rLYC],a
	ld	a,b
	cp	c
	ld	e,%00000001
	jr	z,.bc
	ld	e,%00000110
	cp	d
	jr	z,.bacdone
	ld	e,%00110110
	jr	.bacdone
.bc
	cp	d
	jr	z,.bacdone
	ld	e,%00001101
.bacdone
	ld	a,b
	add	8
	cp	d
	ret	c
	ld	d,a
	ret

.bca
	ld	a,c
	ld	[rLYC],a
	ld	a,d
	cp	c
	ld	e,%00000001
	jr	z,.ba
	ld	e,%00000110
	cp	b
	jr	z,.bcadone
	ld	e,%00011110
	jr	.bcadone
.ba
	cp	b
	jr	z,.bcadone
	ld	e,%00000110
.bcadone
	ld	a,c
	add	8
	cp	d
	ret	c
	ld	d,a
	ret
	
.cab
	ld	a,d
	ld	[rLYC],a
	ld	a,b
	cp	d
	ld	e,%00000001
	jr	z,.cb
	ld	e,%00000111
	cp	c
	jr	z,.cabdone
	ld	e,%00100111
	jr	.cabdone
.cb
	cp	c
	jr	z,.cabdone
	ld	e,%00001001
.cabdone
	ld	a,b
	add	8
	cp	c
	ret	c
	ld	c,a
	ret
	
.cba
	ld	a,d
	ld	[rLYC],a
	ld	a,c
	cp	d
	ld	e,%00000001
	jr	z, .ca
	ld	e,%00000111
	cp	b
	ret	z
	ld	e,%00011011
	ret
.ca
	cp	b
	ret	z
	ld	e,%00000110
	ret
	
UpdateScroller:
; returns a line number to update this scroller
	ld	a,[hl]	; \1TablePos
	inc	a
	and	$7f
	ld	[hl+],a
	inc	[hl]	; \1XPos
	inc	hl
	push	hl
	add	ScrollerBounceTable % $100
	ld	l,a
	ld	h,ScrollerBounceTable / $100
	jr	nc,.nocarry
	inc	h
.nocarry
	ld	a,[hl]
	pop	hl
	ld	[hl],a	; \1YPos
	ld	a,135
	sub	[hl]
	ret
	
	
UpdateScrollerText:
	ld	a,[ScrollerTextTimer]
	dec	a
	ld	[ScrollerTextTimer],a
	and	a
	ret	nz
	ld	a,8
	ld	[ScrollerTextTimer],a
	ld	hl,ScrollerPointer
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	ld	d,h
	ld	e,l
	ld	hl,ScrollerTextPtr
	ld	a,[hl+]
	ld	h,[hl]
	ld	l,a
	
	ldh	a,[rSTAT]	; wait for VRAM accessibility
	and	2
	jr	nz,@-4
	ld	a,[hl+]
	add	$60
	ld	[de],a
	inc	de
	ld	a,e
	cp	$40
	jr	nz,.skip
	sub	$20
	ld	e,a
.skip
	ld	a,h
	ld	[ScrollerTextPtr+1],a
	ld	a,l
	ld	[ScrollerTextPtr],a
	ld	a,d
	ld	[ScrollerPointer+1],a
	ld	a,e
	ld	[ScrollerPointer],a
	ret

ScrollerText:	incbin	"ScrollerText.txt"

; =============
; Misc routines
; =============

_hl_:
	jp	hl

_Fill:
	inc	b
	inc	c
	dec	c
	jr	nz,.loop
	dec	b
.loop
	ld	[hl+],a
	dec	c
	jr	nz,.loop
	dec	b
	jr	nz,.loop
	ret

_CopyBytes:
	inc	b
	inc	c
	dec	c
	jr	nz,.loop
	dec	b
.loop
	ld	a,[hl+]
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
	CopyTileset		EmergencyNintendoLogo,$10,$18
	ld	hl,$8190
	ld	de,BootROMRegisteredGFX
	ld	b,8
.loop
	ld	a,[de]
	inc	de
	ld	[hl+],a
	xor	a
	ld	[hl+],a
	dec	b
	jr	nz,.loop
	
	ld	a,1
	bgcoord	hl,4,8
	lb	bc,2,12
	call	GFXBlock
	ld	[$9910],a
	
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
	db	 0, 1, 2, 4, 5, 6, 7, 8, 9,11,12,13,14,15,16,17
	db	18,19,21,22,23,24,25,26,27,28,29,30,30,31,32,33
	db	34,35,36,36,37,38,39,39,40,41,41,42,42,43,43,44
	db	45,45,45,46,46,46,47,47,47,47,47,48,48,48,48,48
	db	48,48,48,48,48,48,47,47,47,47,47,46,46,46,46,45
	db	44,44,43,43,42,42,41,41,40,39,39,38,37,36,36,35
	db	34,33,32,31,30,30,29,28,27,26,25,24,23,22,21,19
	db	18,17,16,15,14,13,12,11, 9, 8, 7, 6, 5, 4, 2, 1
	
; ==================
; Interrupt routines
; ==================

DoVBlank:
	ld	a,1
	ld	[VBlankFlag],a
	reti

DoStat:
	ld	a,[rSTAT]
	and	%00000100
	jr	z,.notlyc
	ld	a,[CurScrollId]
	push	af
	srl	a
	srl	a
	ld	[CurScrollId],a
	and	3
	dec	a
	add	ScrollLYCTable % $100
	ld	l,a
	ld	h,ScrollLYCTable / $100
	jr	nc,.nocarry
	inc	h
.nocarry
	ld	a,[hl]
	ld	[rLYC],a

	pop	af
	and	3
	dec	a
	jr	z,.one
	dec	a
	jr	z,.two
	ld	a,[Scroll3XPos]
	ld	b,a
	ld	a,[Scroll3YPos]
	ld	c,%11111110
	jr	.done
.one
	ld	a,[Scroll1XPos]
	ld	b,a
	ld	a,[Scroll1YPos]
	ld	c,%11100100
	jr	.done
.two
	ld	a,[Scroll2XPos]
	ld	b,a
	ld	a,[Scroll2YPos]
	ld	c,%11111001
.done
	ld	[rSCY],a
	ld	a,b
	ld	[rSCX],a
	ld	a,c
	ld	[rBGP],a
.notlyc
	reti
DoStatEnd

; =================
; Graphics routines
; =================

_CopyTileset:
	ld	a, [rLCDC]
	bit	7,a
	jr	nz,HBlankCopy2bpp
	ld	a,[hl+]
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,_CopyTileset
	ret
	
_CopyTileset1BPP:
	ld	a, [rLCDC]
	bit	7,a
	jr	nz,HBlankCopy1bpp
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
	
_CopyTilesetInverted:
	ld	a, [rLCDC]
	bit	7,a
	jr	z,.normalcopy
	push	bc
	push	de
	ld	de,	TempGFXBuffer
	call	.normalcopy
	pop	de
	pop	bc
	ld	hl,	TempGFXBuffer
	jr	HBlankCopy2bpp
.normalcopy
	ld	a,[hl+]
	cpl
	ld	[de],a
	inc	de
	dec	bc
	ld	a,b
	or	c
	jr	nz,_CopyTilesetInverted
	ret	
	
HBlankCopy2bpp:
	call	AdjustBCForHBlankCopy
	di
	ld	[tempSP],sp
	ld	sp,hl
	ld	h,d
	ld	l,e
.loop
	pop	bc
	pop	de
	ld	a,[rLY]
	; if in line 144 - 152 (VBlank), don't wait for stat 3
	cp	144
	jr	c,.wait
	cp	153
	jr	c,.nowait
.wait
	ld	a,[rSTAT]
	and	3
	jr	z,.wait
.wait2
	ld	a,[rSTAT]
	and	2
	jr	nz,.wait2
.nowait
	ld	a,c
	ld	[hli],a
	ld	a,b
	ld	[hli],a
	ld	a,e
	ld	[hli],a
	ld	a,d
	ld	[hli],a
	pop	de
	ld	a,e
	ld	[hli],a
	ld	a,d
	ld	[hli],a
	pop	de
	ld	a,e
	ld	[hli],a
	ld	[hl],d
	inc	hl
	ld	a,[tempBC]
	dec	a
	ld	[tempBC],a
	jr	nz,.loop
	ld	a,[tempBC+1]
	dec	a
	ld	[tempBC+1],a
	jr	nz,.loop
	jr	DoneHBlankCopy
	
HBlankCopy1bpp:
	call	AdjustBCForHBlankCopy
	di
	ld	[tempSP],sp
	ld	sp,hl
	ld	h,d
	ld	l,e
.loop
	pop	bc
	pop	de
	ld	a,[rLY]
	; if in line 144 - 152 (VBlank), don't wait for stat 3
	cp	144
	jr	c,.wait
	cp	153
	jr	c,.nowait
.wait
	ld	a,[rSTAT]
	and	3
	jr	z,.wait
.wait2
	ld	a,[rSTAT]
	and	2
	jr	nz,.wait2
.nowait
	ld	a,c
	ld	[hli],a
	ld	[hli],a
	ld	a,b
	ld	[hli],a
	ld	[hli],a
	ld	a,e
	ld	[hli],a
	ld	[hli],a
	ld	a,d
	ld	[hli],a
	ld	[hli],a
	ld	a,[tempBC]
	dec	a
	ld	[tempBC],a
	jr	nz,.loop
	ld	a,[tempBC+1]
	dec	a
	ld	[tempBC+1],a
	jr	nz,.loop

DoneHBlankCopy:
	ld	a,[tempSP]
	ld	l,a
	ld	a,[tempSP+1]
	ld	h,a
	ld	sp,hl
	reti

AdjustBCForHBlankCopy:
rept 3	; bc = bc/8
	srl	b
	rr	c
endr
	inc	b
	inc	c
	dec	c
	jr	nz,.skip
	dec	b
.skip
	ld	a,c
	ld	[tempBC],a
	ld	a,b
	ld	[tempBC+1],a
	ret
	
GFXBlock:
	push	bc
	push	hl
.loop
	ld	[hl+],a
	inc	a
	dec	c
	jr	nz,.loop
	pop	hl
	ld	bc,32
	add	hl,bc
	pop	bc
	dec	b
	jr	nz, GFXBlock
	ret
	
; =============
; Graphics data
; =============

Font:					incbin	"Font.bin"

BootROMRegisteredGFX:	db	$3c,$42,$b9,$a5,$b9,$a5,$42,$3c

Logo1:					incbin	"GFX/Logo1.bin"
Logo1Map:				incbin	"GFX/Logo1Map.bin"

StarTiles:				incbin	"GFX/StarTiles.bin"

; ========
; DevSound
; ========

include	"DevSound.asm"