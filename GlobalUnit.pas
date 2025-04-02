unit GlobalUnit;

interface

uses
  SysUtils, WinTypes, WinProcs, Classes, Forms, Messages, Dialogs, ExtCtrls, Graphics;

const
  kBackSpace    = 8;
  kInsert       = 45;
  kDelete       = 46;
  kLeft         = 37;
  kRight        = 39;
  kUp           = 38;
  kDown         = 40;
  kHome         = 36;
  kEnd          = 35;
  kPageUp       = 33;
  kPageDown     = 34;
  kSpace        = 32;
  kTab          = 9;
  kEnter        = 13;
  kEsc          = 27;

  HubLimit              = $80000;

  ObjSizeLimit          = $100000;
  ObjDataLimit          = $200000;
  FilesLimit            = 255;
  PreSymbolsLimit       = 16;
  ObjParamsLimit        = 16;
  InfoLimit             = 2000;
  DebugDataLimit        = $4000;
  DebugStringLimit      = $8000;
  DebugDisplayLimit     = 1100;         // allows 1k data elements + some commands

  SourceLimit           = 5000000;
  ListLimit             = 10000000;
  DocLimit              = 5000000;

  ObjStackLimit         = 16;
  ObjFilesLimit         = 4000;

type
  TP2 = packed record
    Error:		boolean;
    ErrorMsg:           PChar;

    DebugMode:          boolean;
    PreprocessorUsed:   boolean;
    PasmMode:           boolean;

    Source:		PByteArray;
    SourceStart:	integer;
    SourceFinish:	integer;

    List:		PByteArray;
    ListLimit:          integer;
    ListLength:         integer;

    Doc:		PByteArray;
    DocLimit:           integer;
    DocLength:          integer;

    PreSymbols:         integer;
    PreSymbolNames:     array[0..PreSymbolsLimit*32-1] of byte;

    Params:             integer;
    ParamNames:         array[0..ObjParamsLimit*32-1] of byte;
    ParamTypes:         array[0..ObjParamsLimit-1] of byte;
    ParamValues:        array[0..ObjParamsLimit-1] of integer;

    Obj:                array[0..ObjSizeLimit-1] of byte;
    ObjLength:          integer;

    ObjFiles:           integer;
    ObjFilenames:       array[0..FilesLimit*256-1] of byte;
    ObjFilenamesStart:  array[0..FilesLimit-1] of integer;
    ObjFilenamesFinish: array[0..FilesLimit-1] of integer;
    ObjParams:          array[0..FilesLimit-1] of integer;
    ObjParamNames:      array[0..FilesLimit*ObjParamsLimit*32-1] of byte;
    ObjParamTypes:      array[0..FilesLimit*ObjParamsLimit-1] of byte;
    ObjParamValues:     array[0..FilesLimit*ObjParamsLimit-1] of integer;
    ObjOffsets:         array[0..FilesLimit-1] of integer;
    ObjLengths:         array[0..FilesLimit-1] of integer;
    ObjData:            array[0..ObjDataLimit-1] of byte;
    ObjInstances:       array[0..FilesLimit-1] of integer;
    ObjTitle:           array[0..255] of byte;

    DatFiles:           integer;
    DatFilenames:       array[0..FilesLimit*256-1] of byte;
    DatFilenamesStart:  array[0..FilesLimit-1] of integer;
    DatFilenamesFinish: array[0..FilesLimit-1] of integer;
    DatOffsets:         array[0..FilesLimit-1] of integer;
    DatLengths:         array[0..FilesLimit-1] of integer;
    DatData:            array[0..ObjSizeLimit-1] of byte;

    InfoCount:          integer;        // used by PropellerTool
    InfoStart:          array[0..InfoLimit-1] of integer;
    InfoFinish:         array[0..InfoLimit-1] of integer;
    InfoType:           array[0..InfoLimit-1] of integer;
    InfoData0:          array[0..InfoLimit-1] of integer;
    InfoData1:          array[0..InfoLimit-1] of integer;
    InfoData2:          array[0..InfoLimit-1] of integer;
    InfoData3:          array[0..InfoLimit-1] of integer;

    DownloadBaud:       integer;

    DebugPinTx:         byte;
    DebugPinRx:         byte;
    DebugBaud:          integer;
    DebugLeft:          integer;
    DebugTop:           integer;
    DebugWidth:         integer;
    DebugHeight:        integer;
    DebugDisplayLeft:   integer;
    DebugDisplayTop:    integer;
    DebugLogSize:       integer;
    DebugWindowsOff:    integer;

    DebugData:          array[0..DebugDataLimit-1] of byte;

    DebugDisplayEna:    integer;        // 32 bitwise enables
    DebugDisplayNew:    integer;
    DebugDisplayStr:    array[0..DebugStringLimit-1] of byte;
    DebugDisplayType:   array[0..DebugDisplayLimit-1] of byte;
    DebugDisplayValue:  array[0..DebugDisplayLimit-1] of integer;
    DebugDisplayTargs:  byte;

    DisassemblerInst:   integer;
    DisassemblerAddr:   integer;
    DisassemblerString: array[0..255] of byte;

    DistilledBytes:     integer;

    ClkMode:            integer;
    ClkFreq:            integer;
    XinFreq:            integer;

    SizeFlashLoader:    integer;
    SizeInterpreter:    integer;
    SizeObj:            integer;
    SizeVar:            integer;

    ObjStackPtr:        integer;        // recursion level
end;

  // Assembly interface
  function  P2InitStruct: pointer; external;
  procedure P2Compile0; external;
  procedure P2Compile1; external;
  procedure P2Compile2; external;
  procedure P2InsertInterpreter; external;
  procedure P2InsertDebugger; external;
  procedure P2InsertClockSetter; external;
  procedure P2InsertFlashLoader; external;
  procedure P2MakeFlashFile; external;
  procedure P2ResetDebugSymbols; external;
  procedure P2ParseDebugString; external;
  procedure P2Disassemble; external;

  // Support routines
  function  ExtFilename(Filename, Ext: string): string;
  procedure MinLimit(var Value: integer; Target: integer);
  procedure MaxLimit(var Value: integer; Target: integer);
  function  IsWithin(Value, Minimum, Maximum: integer): boolean;
  function  Within(Value, Minimum, Maximum: integer): integer;
  function  IsWordChr(C: Char): boolean;
  function  Smaller(x, y: Integer): integer;
  function  Greater(x, y: Integer): integer;

var
  P2: ^TP2;

  SourceBuffer       : array[0..SourceLimit] of byte; // +1 allows 0 end byte
  ListBuffer         : array[0..ListLimit] of byte; // +1 allows end reading
  DocBuffer          : array[0..DocLimit] of byte; // +1 allows end reading

  ObjFilePtr         : integer;
  ObjFileCount       : integer;
  ObjFileOffsets     : array[0..ObjFilesLimit-1] of integer;
  ObjFileLengths     : array[0..ObjFilesLimit-1] of integer;
  ObjFileLastIndex   : integer;

  FontName           : string;
  FontSize           : integer;
  FontStyle          : TFontStyles;

  TopFile            : string;

  BatchMode          : boolean;
  DebugActive        : boolean;

  DebuggerID         : integer;
  LastDebugTick      : integer;
  RequestCOGBRK      : integer;

implementation

{$L p2com.obj}

function ExtFilename(Filename, Ext: string): string;
begin
  Result := (Copy(Filename, 1, Length(Filename) - Length(ExtractFileExt(Filename))) + '.' + Ext);
end;

procedure MinLimit(var Value: integer; Target: integer);
begin
  if Value < Target then Value := Target;
end;

procedure MaxLimit(var Value: integer; Target: integer);
begin
  if Value > Target then Value := Target;
end;

function IsWithin(Value, Minimum, Maximum: integer): boolean;
begin
  Result := (Value >= Minimum) and (Value <= Maximum);
end;

function Within(Value, Minimum, Maximum: integer): integer;
begin
  if Value < Minimum then Result := Minimum
  else if Value > Maximum then Result := Maximum
  else Result := Value;
end;

function IsWordChr(C: Char): boolean;
begin
  Result := C in ['0'..'9', 'A'..'Z', 'a'..'z', '_'];
end;

function Smaller(x, y: Integer): integer;
begin
  if x < y then Result := x else Result := y;
end;
  
function Greater(x, y: Integer): integer;
begin
  if x > y then Result := x else Result := y;
end;

end.

