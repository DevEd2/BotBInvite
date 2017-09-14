; ================================================================
; DevSound song data
; ================================================================
	
; =================================================================
; Song speed table
; =================================================================

SongSpeedTable:
	db	4,3
	
SongPointerTable:
	dw	PT_Music1

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
vol_Snare:			db	$1d,$ff
vol_OHH:			db	$48,$ff
vol_CymbQ:			db	$6a,$ff
vol_CymbL:			db	$3f,$ff
				
; =================================================================
; Arpeggio sequences
; =================================================================

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

; =================================================================
; Vibrato sequences
; Must be terminated with a loop command!
; =================================================================

vib_Dummy:			db	0,0,$80,1

; =================================================================
; Wave sequences
; =================================================================

WaveTable:
	dw	DefaultWave
	dw	wave_Dummy	
	
wave_Dummy	db	$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00
	
; use $c0 to use the wave buffer
waveseq_Default:	db	0

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
	
	
	
; Instrument format: [no reset flag],[wave mode (ch3 only)],[voltable id],[arptable id],[pulsetable/wavetable id],[vibtable id]
; note that wave mode must be 0 for non-wave instruments
; !!! REMEMBER TO ADD INSTRUMENTS TO THE INSTRUMENT POINTER TABLE !!!
ins_Kick:				Instrument	0,vol_Kick,noiseseq_Kick,DummyTable,DummyTable	; pulse/waveseq and vibrato unused by noise instruments
ins_Snare:				Instrument	0,vol_Snare,noiseseq_Snare,DummyTable,DummyTable
ins_CHH:				Instrument	0,vol_Kick,noiseseq_Hat,DummyTable,DummyTable
ins_OHH:				Instrument	0,vol_OHH,noiseseq_Hat,DummyTable,DummyTable
ins_CymbQ:				Instrument	0,vol_CymbQ,noiseseq_Hat,DummyTable,DummyTable
ins_CymbL:				Instrument	0,vol_CymbL,noiseseq_Hat,DummyTable,DummyTable

_ins_Kick				equ	0
_ins_Snare				equ	1
_ins_CHH				equ	2
_ins_OHH				equ	3
_ins_CymbQ				equ	4
_ins_CymbL				equ	5

Kick				equ	_ins_Kick
Snare				equ	_ins_Snare
CHH					equ	_ins_CHH
OHH					equ	_ins_OHH
CymbQ				equ	_ins_CymbQ
CymbL				equ	_ins_CymbL

; =================================================================

PT_Music1:	dw	Music1_CH1,Music1_CH2,Music1_CH3,Music1_CH4

Music1_CH1:
	db	EndChannel
	
Music1_CH2:
	db	EndChannel
	
Music1_CH3:
	db	EndChannel
	
Music1_CH4:
	db	EndChannel