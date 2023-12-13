@echo off

set /A ERR = 0

PNut_v43 Spin2_debugger -c
set /A ERR = %ERR% + %ERRORLEVEL%
type error.txt

PNut_v43 Spin2_interpreter -c
set /A ERR = %ERR% + %ERRORLEVEL%
type error.txt

PNut_v43 flash_loader -c
set /A ERR = %ERR% + %ERRORLEVEL%
type error.txt

PNut_v43 clock_setter -c
set /A ERR = %ERR% + %ERRORLEVEL%
type error.txt

sbasic Spin2_INCLUDE_debugger.bas
set /A ERR = %ERR% + %ERRORLEVEL%

sbasic Spin2_INCLUDE_interpreter.bas
set /A ERR = %ERR% + %ERRORLEVEL%

sbasic Spin2_INCLUDE_flash_loader.bas
set /A ERR = %ERR% + %ERRORLEVEL%

sbasic Spin2_INCLUDE_clock_setter.bas
set /A ERR = %ERR% + %ERRORLEVEL%

tasm32 p2com /m /l /z /c
set /A ERR = %ERR% + %ERRORLEVEL%

SET DELPHILIB="C:\Program Files (x86)\Borland\Delphi6\Lib"

DCC32 -B -O+ -R%DELPHILIB% PNut.dpr
set /A ERR = %ERR% + %ERRORLEVEL%

if %ERR% NEQ 0 (
    set /P input="ERROR: Press enter to continue: "
) else (
    PNut
)
