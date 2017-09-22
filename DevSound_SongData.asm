; ================================================================
; DevSound song data
; ================================================================
	
; =================================================================
; Song speed table
; =================================================================

SongSpeedTable:
	db	4,3
	
SongPointerTable:
	dw	PT_AllNoobz

; =================================================================
; Volume sequences
; =================================================================

; Wave volume values
w0			equ	%00000000
w1			equ	%01100000
w2			equ	%01000000
w3			equ	%00100000

; For pulse instruments, volume control is software-based by default.
; However, hardware volume envelopes may still be used by adding the
; envelope length * $10.
; Example: $3F = initial volume $F, env. length $3
; Repeat that value for the desired length.
; Note that using initial volume $F + envelope length $F will be
; interpreted as a "table end" command, use initial volume $F +
; envelope length $0 instead.
; Same applies to initial volume $F + envelope length $8 which
; is interpreted as a "loop" command, use initial volume $F +
; envelope length $0 instead.

vol_Kick:			db	$18,$ff
vol_Snare:			db	$1f,$ff
vol_OHH:			db	$48,$ff
vol_CymbQ:			db	$6a,$ff
vol_CymbL:			db	$3f,$ff

vol_Bass:			db	$2f,$ff
vol_BassEcho:		db	$75,$ff

vol_TechnoThing:	db	$19,$19,$19,$19,0,$ff
vol_WaveArp1:		db	w3,w3,w3,w3,w3,w3,w3
					db	w1,w1,w1,w1,w1,w1,w1
					db	w2,$ff
vol_WaveArp2:		db	w2,w2,w2,w1,w1,w1,w1
					db	w2,w2,w1,w1,w1,w1,w0
					db	w3,w3,w3,w2,w2,w2,w1
					db	$80,00
					
vol_Follin:			db	$5f,$ff
vol_FollinEcho:		db	$75,$ff
vol_LongFade:		db	$7f,$ff
					
; =================================================================
; Arpeggio sequences
; =================================================================

arp_Follin:			db	0,19,0,$ff
arp_PluckLong:		db	12,12,0,$ff
arp_Octave:			db	12,12,12,12,0,0,0,0,$80,0

; =================================================================
; Noise sequences
; =================================================================

; Noise values are the same as Deflemask, but with one exception:
; To convert 7-step noise values (noise mode 1 in deflemask) to a
; format usable by DevSound, take the corresponding value in the
; arpeggio macro and add s7.
; Example: db s7+32 = noise value 32 with step lengh 7
; Note that each noiseseq must be terminated with a loop command
; ($80) otherwise the noise value will reset!

s7	equ	$2d

noiseseq_Kick:	db	32,26,37,$80,2
noiseseq_Snare:	db	s7+29,s7+23,s7+20,35,$80,3
noiseseq_Hat:	db	41,43,$80,1
noiseseq_S7:	db	s7,$80,1

; =================================================================
; Pulse sequences
; =================================================================

pulse_12:			db	0,$ff
pulse_25:			db	1,$ff
pulse_50:			db	2,$ff
pulse_75:			db	3,$ff

pulse_Bass:			db	2,1,0,$ff
pulse_LongFade:		db	0,0,0,0,0,1,1,1,1,1
					db	2,2,2,2,2,3,3,3,3,3
					db	$80,0

; =================================================================
; Vibrato sequences
; Must be terminated with a loop command!
; =================================================================

vib_Dummy:			db	0,0,$80,1

vib_Follin:			db	12,1,2,1,0,-1,-2,-1,0,$80,1
vib_LongFade:		db	16,1,2,2,1,0,-1,-2,-2,-1,0,$80,1

; =================================================================
; Wave sequences
; =================================================================

WaveTable:
	dw	DefaultWave
	dw	wave_Pulse
	dw	wave_Sawtooth
	
wave_Pulse:			db	$cc,$cc,$cc,$cc,$cc,$c0,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
wave_Sawtooth:		db	$00,$11,$22,$33,$44,$55,$66,$77,$88,$99,$aa,$bb,$cc,$dd,$ee,$ff
	
; use $c0 to use the wave buffer
waveseq_Default:	db	0,$ff
waveseq_Pulse:		db	1,$ff
waveseq_Sawtooth:	db	2,$ff

; =================================================================
; Instruments
; =================================================================

InstrumentTable:	
	dw	ins_Kick
	dw	ins_Snare
	dw	ins_CHH
	dw	ins_OHH
	dw	ins_CymbQ
	dw	ins_CymbL
	
	dw	ins_Bass
	dw	ins_BassEcho
	dw	ins_TechnoThing
	dw	ins_WaveArp1
	dw	ins_WaveArp2
	dw	ins_Follin
	dw	ins_FollinEcho
	dw	ins_LongFade
	dw	ins_LongFadeArp
	
; Instrument format: [no reset flag],[wave mode (ch3 only)],[voltable id],[arptable id],[pulsetable/wavetable id],[vibtable id]
; note that wave mode must be 0 for non-wave instruments
; !!! REMEMBER TO ADD INSTRUMENTS TO THE INSTRUMENT POINTER TABLE !!!
ins_Kick:			Instrument	0,vol_Kick,noiseseq_Kick,DummyTable,DummyTable	; pulse/waveseq and vibrato unused by noise instruments
ins_Snare:			Instrument	0,vol_Snare,noiseseq_Snare,DummyTable,DummyTable
ins_CHH:			Instrument	0,vol_Kick,noiseseq_Hat,DummyTable,DummyTable
ins_OHH:			Instrument	0,vol_OHH,noiseseq_Hat,DummyTable,DummyTable
ins_CymbQ:			Instrument	0,vol_CymbQ,noiseseq_Hat,DummyTable,DummyTable
ins_CymbL:			Instrument	0,vol_CymbL,noiseseq_Hat,DummyTable,DummyTable

ins_Bass:			Instrument	0,vol_Bass,DummyTable,pulse_Bass,vib_Dummy
ins_BassEcho:		Instrument	0,vol_BassEcho,DummyTable,pulse_Bass,vib_Dummy
ins_TechnoThing:	Instrument	0,vol_TechnoThing,DummyTable,pulse_12,vib_Dummy
ins_WaveArp1:		Instrument	0,vol_WaveArp1,ArpBuffer,waveseq_Pulse,vib_Dummy
ins_WaveArp2:		Instrument	0,vol_WaveArp2,ArpBuffer,waveseq_Sawtooth,vib_Dummy
ins_Follin:			Instrument	0,vol_Follin,arp_Follin,pulse_50,vib_Follin
ins_FollinEcho:		Instrument	0,vol_FollinEcho,arp_Follin,pulse_50,vib_Follin
ins_LongFade:		Instrument	0,vol_LongFade,arp_PluckLong,pulse_LongFade,vib_LongFade
ins_LongFadeArp:	Instrument	0,vol_LongFade,arp_Octave,pulse_LongFade,vib_LongFade

_ins_Kick			equ	0
_ins_Snare			equ	1
_ins_CHH			equ	2
_ins_OHH			equ	3
_ins_CymbQ			equ	4
_ins_CymbL			equ	5

_ins_Bass			equ	6
_ins_BassEcho		equ	7
_ins_TechnoThing	equ	8
_ins_WaveArp1		equ	9
_ins_WaveArp2		equ	10
_ins_Follin			equ	11
_ins_FollinEcho		equ	12
_ins_LongFade		equ	13
_ins_LongFadeArp	equ	14

Kick				equ	_ins_Kick
Snare				equ	_ins_Snare
CHH					equ	_ins_CHH
OHH					equ	_ins_OHH
CymbQ				equ	_ins_CymbQ
CymbL				equ	_ins_CymbL

; =================================================================

PT_AllNoobz:	dw	AllNoobz_CH1,AllNoobz_CH2,AllNoobz_CH3,AllNoobz_CH4

; --------------------------------

AllNoobz_CH1:
	db	SetInstrument,_ins_Bass
	rept	3
	db	CallSection
	dw	.block1
	endr
	db	CallSection
	dw	.block2
	db	SetLoopPoint

	db	CallSection
	dw	.block3
	db	CallSection
	dw	.block4
	db	CallSection
	dw	.block3
	db	CallSection
	dw	.block5
	db	GotoLoopPoint
	

.block1
	db	E_2,4,E_3,2,E_2,2,D_3,2,E_3,2,E_2,2,C_2,4,C_3,4,C_2,2,B_2,4,C_3,4
	db	D_2,4,D_3,2,D_2,2,C_3,2,D_3,2,F#2,2,D_2,4,D_3,4,D_2,2,A_2,4,D_3,4
	ret
	
.block2
	db	E_2,4,E_3,2,E_2,2,D_3,2,E_3,2,E_2,2,C_2,4,C_3,4,C_2,2,B_2,4,C_3,4
	db	D_2,6,D_3,6,D_2,4,G_2,8,F#2,8
	ret
	
.block3
	db	E_2,4,E_3,2,E_2,2,D_3,2,E_3,2,G_2,2,E_2,4,E_3,4
	ret
	
.block4
	db	B_2,2,D_3,4,B_2,4
	ret

.block5
	db	E_2,2,E_3,4,D_3,4
	db	C_2,4,C_3,2,C_2,2,B_2,2,C_3,2,E_2,2,C_2,4,C_3,4,C_2,2,B_2,4,C_3,4
	db	D_2,4,D_3,2,D_2,2,C_3,2,D_3,2,F#2,2,D_2,4,D_3,4,D_2,2,G_3,4,F#3,4
	ret
	
; --------------------------------
	
AllNoobz_CH2:
	db	rest,128
	db	SetInstrument,_ins_TechnoThing
	rept	3
	db	CallSection
	dw	.block1
	endr
	db	SetInstrument,_ins_BassEcho
	db	C_3,4,D_2,6,D_3,6,D_2,4,G_2,8,F#2,4
	
	db	SetLoopPoint
	db	CallSection
	dw	.block2
	db	SetInstrument,_ins_LongFade
	db	CallSection
	dw	.block3
	db	A_3,8,G_3,8,F#3,4,G_3,12
	db	CallSection
	dw	.block3
	db	A_3,16,B_3,8,D_3,8	
	db	CallSection
	dw	.block2
	db	SetInstrument,_ins_LongFadeArp
	db	E_4,12,F#4,12,G_4,8,E_4,12,G_4,12,F#4,8
	db	G_4,12,A_4,12,G_4,8,F#4,16,D_4,8,B_3,4,D_4,4
	db	E_4,12,F#4,12,G_4,8,E_4,12,G_4,12,A_4,8
	db	B_4,12,G_4,12,B_4,8,A_4,16,F#4,8,D_4,8
	db	GotoLoopPoint
	
.block1
	db	E_5,2,E_4,2,E_5,2,E_4,2,E_6,2,E_5,2,E_4,2,E_5,2
	db	E_4,2,E_5,2,E_4,2,E_5,2,E_6,2,E_5,2,E_4,2,E_3,2
	ret
	
.block2
	db	SetInsAlternate,_ins_FollinEcho,_ins_Follin
	db	E_4,4,E_4,2,B_3,4,B_3,2,E_4,2,B_3,2,G_4,4,G_4,4
	db	F#4,4,F#4,4
	db	E_4,8,E_4,4,B_3,2,E_4,2,D_4,2,B_3,2,B_3,2,D_4,2,A_3,2
	db	SetInsAlternate,_ins_Follin,_ins_FollinEcho
	db	B_3,2,A_3,2,D_4,2
	db	SetInsAlternate,_ins_FollinEcho,_ins_Follin
	db	E_4,4,E_4,2,C_4,4,C_4,2,E_4,2,C_4,2
	db	G_4,2,E_4,2,A_4,2,G_4,2,G_4,2,A_4,2
	db	F#4,12,F#4,4,D_4,2,F#4,2
	db	B_3,2,D_4,2,D_4,2,B_3,2,G_4,2,D_4,2,F#4,2,G_4,2
	db	SetInsAlternate,_ins_FollinEcho,_ins_Follin
	db	E_4,4,E_4,2,B_3,4,B_3,2,E_4,2,B_3,2,G_4,4,G_4,4
	db	A_4,4,A_4,4,B_4,8,B_4,4,G_4,2,B_4,2
	db	B_4,2,G_4,2,G_4,2,B_4,2,E_4,2
	db	SetInsAlternate,_ins_Follin,_ins_FollinEcho
	db	G_4,2,E_4,2,B_4,2
	db	SetInsAlternate,_ins_FollinEcho,_ins_Follin
	db	C_5,4,C_5,2,G_4,4,G_4,2,E_4,6,E_4,2,C_4,2,E_4,2,E_4,2
	db	SetInsAlternate,_ins_Follin,_ins_FollinEcho
	db	G_4,2,E_4,2,D_4,12,D_4,22
	ret

.block3
	db	E_3,12,B_3,12,E_4,8
	db	D_4,8,B_3,8,A_3,4,G_3,12
	db	A_3,6,B_3,6,E_3,8,F#3,4,G_3,4,E_3,4
	ret

	ret
	
; --------------------------------	
	
AllNoobz_CH3:
	db	SetInstrument,_ins_WaveArp1
	
	rept	4
	db	CallSection
	dw	.block1
	endr
	db	SetInstrument,_ins_WaveArp2
	db	SetLoopPoint
	db	Arp,0,$37,E_6,32
	db	E_6,32
	db	Arp,0,$47,C_6,32
	db	D_6,32
	db	GotoLoopPoint
	
.block1
	db	Arp,1,$37,E_5,6,E_5,6,E_5,4
	db	Arp,1,$38,E_5,6,E_5,6,E_5,4
	db	Arp,1,$59,D_5,6,D_5,6,D_5,4
	db	Arp,1,$47,D_5,6,D_5,6,D_5,4
	ret
	
; --------------------------------
	
AllNoobz_CH4:
	rept	7
	db	CallSection
	dw	.block1
	endr
	rept	3
	db	CallSection
	dw	.block2
	endr
	rept	4
	Drum	Snare,2
	endr
	db	SetLoopPoint
	db	CallSection
	dw	.block1
	db	GotoLoopPoint
	
.block1
	Drum	Kick,2
	Drum	CHH,2
	Drum	OHH,2
	Drum	CHH,2
	Drum	Snare,4
	Drum	OHH,2
	Drum	Kick,2
	Drum	CHH,2
	Drum	OHH,2
	Drum	Kick,2
	Drum	CHH,2
	Drum	Snare,4
	Drum	CHH,2
	Drum	OHH,2
	ret
	
.block2
	Drum	Kick,2
	Drum	CHH,2
	Drum	OHH,2
	Drum	CHH,2
	ret
	
; --------------------------------