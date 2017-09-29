; ================================================================
; Variables
; ================================================================

if !def(incVars)
incVars	set	1

SECTION	"Variables",WRAM0

; ================================================================
; Global variables
; ================================================================

sys_RNGSeed:			ds	1	; must be at $c000
sys_CurrentFrame:		ds	1
sys_btnPress:			ds	1
sys_btnHold:			ds	1
ShowLogo:				ds	1
VBlankFlag:				ds	1
TempBGP:				ds	1

CurZoomScaleTmp:		ds	1
CurZoomScale:			ds	1
CurZoomSCY:				ds	2
CurZoomPixel:			ds	2

wram_scroller:			macro
\1:
\1TablePos:				ds	1
\1XPos:					ds	1
\1YPos:					ds	1
endm

ScrollLYCTable:			ds	3
CurScrollId:			ds	1
ScrollerPointer:		ds	2
ScrollerTextPtr:		ds	2
ScrollerTextTimer:		ds	1
	wram_scroller		Scroll1
Scroll2Delay:			ds	1
	wram_scroller		Scroll2
Scroll3Delay:			ds	1
	wram_scroller		Scroll3
	
StarFadeDone			ds	1
LogoOscPos				ds	1
DoOAMDMA				ds	1

SECTION	"Variables 2",WRAM0[$c100]
Sprites:				ds  160

wram_star:				macro
\1YPos					ds	1
\1XPos					ds	1
\1Tile					ds	1
\1Attr					ds	1
endm

; god what a mess, somebody should clean this up
; god what a mess, somebody should clean this up
	wram_star			Star1
	wram_star			Star2
	wram_star			Star3
	wram_star			Star4
	wram_star			Star5
	wram_star			Star6
	wram_star			Star7
	wram_star			Star8
	wram_star			Star9
	wram_star			Star10
	wram_star			Star11
	wram_star			Star12
	wram_star			Star13
	wram_star			Star14
	wram_star			Star15
	wram_star			Star16
	wram_star			Star17
	wram_star			Star18
	wram_star			Star19
	wram_star			Star20
	wram_star			Star21
	wram_star			Star22
	wram_star			Star23
	wram_star			Star24
	wram_star			Star25
	wram_star			Star26
	wram_star			Star27
	wram_star			Star28
	wram_star			Star29
	wram_star			Star30
	wram_star			Star31
	wram_star			Star32
	wram_star			Star33
	wram_star			Star34
	wram_star			Star35
	wram_star			Star36
	wram_star			Star37
	wram_star			Star38
	wram_star			Star39
	wram_star			Star40
	
VBlank:					ds  3
LCDStat:				ds  93	; currently padded to $c200
	
TempGFXBuffer:
EmergencyNintendoLogo:

; ================================================================
; Project-specific variables
; ================================================================

; Insert project-specific variables here.

; ================================================================

SECTION "Temporary register storage space",HRAM

OAM_DMA:			ds	10
tempAF				ds	2
tempBC				ds	2
tempDE				ds	2
tempHL				ds	2
tempSP				ds	2
tempPC				ds	2
tempIF				ds	1
tempIE				ds	1

endc
