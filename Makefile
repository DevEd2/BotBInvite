PY := python3

%.asm: ;
%.inc: ;
%.bin: ;
BotBInvite.gb: %.asm %.inc %.bin
	rgbasm -o BotBInvite.obj -p 255 Main.asm
	rgblink -p 255 -o BotBInvite.gb -n BotBInvite.sym BotBInvite.obj
	rgbfix -v -p 255 BotBInvite.gb

BotBInvite.gbs: BotBInvite.gb
	$(PY) makegbs.py