HOW TO COMPILE PNUT.EXE
-----------------------

There are three Spin2 files that get included into p2com.obj
file which gets included into the Delphi application:

	flash_loader.spin2
	Spin2_debugger.spin2
	Spin2_interpreter.spin2

Each of these must be loaded into PNut.exe and compiled with
Ctrl-L, in order to generate an .obj for each.

Then, SmallBASIC (included) must be run with the following
programs to translate the three .obj files into .inc files
that will be included into the p2com.asm file:

	Spin2_INCLUDE_debugger.bas
	Spin2_INCLUDE_flash_loader.bas
	Spin2_INCLUDE_interpreter.bas

Next, the batch file p2com.bat must be executed to assemble
the p2com.asm file, which inludes the three .inc files from
above.

Finally, Delphi 6 (not included) is used to compile the
PNut.dpr project file, which will involve the .pas and .dfm
files, along with the big obj file from the p2com.asm.