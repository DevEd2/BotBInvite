; ================================================================
; Variables
; ================================================================

if !def(incVars)
incVars	set	1

SECTION	"Variables",WRAM0

; ================================================================
; Global variables
; ================================================================

Sprites:				ds  160
VBlank:					ds  3
LCDStat:				ds  93	; currently padded to $c100

sys_RNGSeed:			ds	1
EmuCheck:				ds	1	; variable used to determine if we're running in an emulator
sys_btnPress:			ds	1
sys_btnHold:			ds	1
ShowLogo:				ds	1
VBlankFlag:				ds	1

wram_scroller:	macro
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

TempGFXBuffer:
EmergencyNintendoLogo:	ds	$190

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
