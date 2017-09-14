; ================================================================
; Variables
; ================================================================

if !def(incVars)
incVars	set	1

SECTION	"Variables",WRAM0

; ================================================================
; Global variables
; ================================================================

sys_RNGSeed			ds	1
EmuCheck			ds	1	; variable used to determine if we're running in an emulator
sys_btnPress		ds	1
sys_btnHold			ds	1
ShowLogo			ds	1
VBlankFlag			ds	1

ScrollTablePos		ds	1
ScrollerXPos		ds	1
ScrollerPointer		ds	2

; ================================================================
; Project-specific variables
; ================================================================

; Insert project-specific variables here.

; ================================================================

SECTION "Temporary register storage space",HRAM

OAM_DMA				ds	8
tempAF				ds	2
tempBC				ds	2
tempDE				ds	2
tempHL				ds	2
tempSP				ds	2
tempPC				ds	2
tempIF				ds	1
tempIE				ds	1

endc
