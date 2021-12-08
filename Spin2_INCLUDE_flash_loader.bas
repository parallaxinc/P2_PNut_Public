' Create & Write

F=FREEFILE
OPEN "flash_loader.inc" FOR OUTPUT AS #F

F2=FREEFILE
OPEN "flash_loader.obj" FOR INPUT AS #F2

bc = 0
for a = 0 to LOF(F2)-1
  if bc = 0 then print #F,"db "; 
  hexout bgetc(F2)
  bc = bc + 1
  if (bc <> 16) and (a <> LOF(F2)-1) then print #F,",";
  if bc = 16 then print #F,chr(13) + chr(10);
  if bc = 16 then bc = 0
next a

CLOSE #F2

print #F,chr(13) + chr(10);
CLOSE #F
END


SUB hexout(b)
  print #f, "0";
  if b < 16 then print #f, "0";
  print #F, hex(b);
  print #f, "h";
END
