@echo off
rem	Build script for BotBInvite

rem	Build ROM
echo Assembling...
rgbasm -o BotBInvite.obj -p 255 Main.asm
if errorlevel 1 goto :BuildError
echo Linking...
rgblink -p 255 -o BotBInvite.gb -n BotBInvite.sym BotBInvite.obj
if errorlevel 1 goto :BuildError
echo Fixing...
rgbfix -v -p 255 BotBInvite.gb
echo Build complete.
goto MakeGBS

rem Clean up files
del BotBInvite.obj

rem Make GBS file
:MakeGBS
echo Building GBS file...
py makegbs.py
if errorlevel 1 goto :GBSMakeError
echo GBS file built.
echo ** Build finished with no errors **
goto:eof

:BuildError
echo Build failed, aborting...
goto:eof

:GBSMakeError
echo GBS build failed, aborting...
goto:eof