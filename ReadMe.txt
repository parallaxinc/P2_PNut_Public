HOW TO COMPILE PNUT.EXE
-----------------------

A new batch file automates the entire build:

	crank.bat

You will need to download SmallBASIC, which is used
to translate assembled binaries into define-byte
files for inclusion into the p2com.asm file:

	https://smallbasic.github.io/

Finally, Delphi 6 (not included) is used to compile the
PNut.dpr project file, which will involve the .pas and
.dfm files, along with the big obj file assembled from
the p2com.asm file.