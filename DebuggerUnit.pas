unit DebuggerUnit;

interface

uses
  Windows, Messages, SysUtils, ExtCtrls, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, Math;

const
  mCOGN                 = 0;            // debugger message longs
  mBRKCZ                = 1;
  mBRKC                 = 2;
  mBRKZ                 = 3;
  mCTH2                 = 4;
  mCTL2                 = 5;
  mSTK0                 = 6;
  mSTK1                 = 7;
  mSTK2                 = 8;
  mSTK3                 = 9;
  mSTK4                 = 10;
  mSTK5                 = 11;
  mSTK6                 = 12;
  mSTK7                 = 13;
  mIRET                 = 14;
  mFPTR                 = 15;
  mPTRA                 = 16;
  mPTRB                 = 17;
  mCOND                 = 18;
  DebuggerMsgSize       = 19;

  cRed                  = $FF0000;
  cRed1                 = $BF0000;
  cRed2                 = $7F0000;
  cRed3                 = $3F0000;
  cRed4                 = $1F0000;
  cRed5                 = $0F0000;
  cGreen                = $00FF00;
  cGreen1               = $00BF00;
  cGreen2               = $007F00;
  cGreen3               = $003F00;
  cGreen4               = $001F00;
  cGreen5               = $000F00;
  cBlue                 = $0000FF;
  cBlue1                = $0000BF;
  cBlue2                = $00007F;
  cBlue3                = $00003F;
  cBlue4                = $00001F;
  cBlue5                = $00000F;
  cYellow               = $FFFF00;
  cYellow1              = $BFBF00;
  cYellow2              = $7F7F00;
  cYellow3              = $3F3F00;
  cYellow4              = $1F1F00;
  cYellow5              = $0F0F00;
  cMagenta              = $FF00FF;
  cMagenta1             = $BF00BF;
  cMagenta2             = $7F007F;
  cMagenta3             = $3F003F;
  cMagenta4             = $1F001F;
  cMagenta5             = $0F000F;
  cCyan                 = $00FFFF;
  cCyan1                = $00BFBF;
  cCyan2                = $007F7F;
  cCyan3                = $003F3F;
  cCyan4                = $001F1F;
  cCyan5                = $000F0F;
  cOrange               = $FF7F00;
  cOrange1              = $BF5F00;
  cOrange2              = $7F3F00;
  cOrange3              = $3F1F00;
  cOrange4              = $1F0F00;
  cOrange5              = $0F0700;
  cWhite                = $FFFFFF;
  cGrey1                = $BFBFBF;
  cGrey2                = $7F7F7F;
  cGrey3                = $3F3F3F;
  cGrey4                = $1F1F1F;
  cGrey5                = $0F0F0F;
  cBlack                = $000000;

  TopColor              = 20;

  ColorScheme           : array [0..TopColor] of integer =
                          (cBlack,      // cBackground
                           cYellow4,    // cBox
                           cGreen4,     // cBox2
                           cOrange2,    // cBox3
                           cWhite,      // cData
                           cGreen2,     // cData2
                           cYellow5,    // cDataDim
                           cOrange,     // cIndicator
                           cYellow,     // cName
                           cYellow3,    // cHighSame
                           cYellow5,    // cLowSame
                           cYellow,     // cHighDiff
                           cYellow2,    // cLowDiff
                           cYellow2,    // cModeButton
                           cWhite,      // cModeText
                           cYellow3,    // cModeButtonDim
                           cYellow5,    // cModeTextDim
                           cOrange1,    // cCmdButton
                           cWhite,      // cCmdText
                           cOrange3,    // cCmdButtonDim
                           cOrange4);   // cCmdTextDim

  Cols                  = 123;
  Rows                  = 77;

  q1                    = 1 shl 7;
  q2                    = 2 shl 7;
  q3                    = 3 shl 7;

  REGMAPl = 2;        REGMAPt = 1;        REGMAPw = 9;        REGMAPh   = 75;
  LUTMAPl = 13;       LUTMAPt = 1;        LUTMAPw = 9;        LUTMAPh   = 75;
  CFl     = 24;       CFt     = 1;        CFw     = 3;        CFh       = 2;
  ZFl     = 29;       ZFt     = 1;        ZFw     = 3;        ZFh       = 2;
  PCl     = 34;       PCt     = 1;        PCw     = 8;        PCh       = 2;
  SKIPl   = 44;       SKIPt   = 1;        SKIPw   = 41;       SKIPh     = 2;
  XBYTEl  = 87;       XBYTEt  = 1;        XBYTEw  = 12;       XBYTEh    = 2;
  CTl     = 101;      CTt     = 1;        CTw     = 20;       CTh       = 2;
  DISl    = 24;       DISt    = 4;        DISw    = 56;       DISh      = 32;
  WATCHl  = 82;       WATCHt  = 4;        WATCHw  = 12;       WATCHh    = 32;
  SFRl    = 96;       SFRt    = 4;        SFRw    = 18;       SFRh      = 32;
  EVENTl  = 116;      EVENTt  = 4;        EVENTw  = 5;        EVENTh    = 32;
  EXECl   = 24;       EXECt   = 35;       EXECw   = 4;        EXECh     = 4;
  STACKl  = 30;       STACKt  = 37;       STACKw  = 77;       STACKh    = 2;
  INTl    = 24;       INTt    = 40;       INTw    = 13;       INTh      = 6;
  PTRl    = 39;       PTRt    = 40;       PTRw    = 68;       PTRh      = 6;
  STATUSl = 24;       STATUSt = 47;       STATUSw = 6;        STATUSh   = 6;
  PINl    = 32;       PINt    = 47;       PINw    = 75;       PINh      = 6;
  SMARTl  = 24;       SMARTt  = 54;       SMARTw  = 97;       SMARTh    = 2;
  HUBl    = 24;       HUBt    = 57;       HUBw    = 97;       HUBh      = 16;
  HINTl   = 29;       HINTt   = 74;       HINTw   = 92;       HINTh     = 2;

  Bl      = 109;      Bt      = 37;       Bw      = 12;       Bh        = 16;
  bBREAKl = Bl+q3;    bBREAKt = Bt+q1;    bBREAKw = 5;        bBREAKh   = 2;
  bADDRl  = Bl+q3;    bADDRt  = Bt+2+q1;  bADDRw  = 5;        bADDRh    = 2;
  bINT3El = Bl+q3;    bINT3Et = Bt+4+q1;  bINT3Ew = 5;        bINT3Eh   = 2;
  bINT2El = Bl+q3;    bINT2Et = Bt+6+q1;  bINT2Ew = 5;        bINT2Eh   = 2;
  bINT1El = Bl+q3;    bINT1Et = Bt+8+q1;  bINT1Ew = 5;        bINT1Eh   = 2;
  bDEBUGl = Bl+q3;    bDEBUGt = Bt+10+q1; bDEBUGw = 5;        bDEBUGh   = 2;
  bINITl  = Bl+7+q1;  bINITt  = Bt+q1;    bINITw  = 4;        bINITh    = 2;
  bEVENTl = Bl+7+q1;  bEVENTt = Bt+2+q1;  bEVENTw = 4;        bEVENTh   = 2;
  bINT3l  = Bl+7+q1;  bINT3t  = Bt+4+q1;  bINT3w  = 4;        bINT3h    = 2;
  bINT2l  = Bl+7+q1;  bINT2t  = Bt+6+q1;  bINT2w  = 4;        bINT2h    = 2;
  bINT1l  = Bl+7+q1;  bINT1t  = Bt+8+q1;  bINT1w  = 4;        bINT1h    = 2;
  bMAINl  = Bl+7+q1;  bMAINt  = Bt+10+q1; bMAINw  = 4;        bMAINh    = 2;
  bGOl    = Bl+1;     bGOt    = Bt+13;    bGOw    = 10;       bGOh      = 2;

  DebugROM              : array [0..7] of string =
                          ('setq    #$F     ' + Chr(39) + 'DEBUG Entry',
                           'wrlong  0,#$FFF80-cog<<7',
                           'setq    #$F',
                           'rdlong  0,#$FFFC0-cog<<7',
                           'jmp     #\0',
                           'setq    #$F     ' + Chr(39) + 'DEBUG Exit',
                           'rdlong  0,#$FFF80-cog<<7',
                           'reti0');

  ModeName              : array [0..3] of string =
                          ('MAIN', 'INT1', 'INT2', 'INT3');

  EventName             : array [0..15] of string =
                          ('INT', 'CT1', 'CT2', 'CT3', 'SE1', 'SE2', 'SE3', 'SE4',
                           'PAT', 'FBW', 'XMT', 'XFI', 'XRO', 'XRL', 'ATN', 'QMT');

  RegName               : array [0..15] of string =
                          ('IJMP3', 'IRET3', 'IJMP2', 'IRET2', 'IJMP1', 'IRET1',
                           '   PA', '   PB', ' PTRA', ' PTRB',
                           ' DIRA', ' DIRB', ' OUTA', ' OUTB', '  INA', '  INB');

  dmPC                  = 0;            // disassembly modes
  dmCog                 = 1;
  dmHub                 = 2;

  DisLines              = 16;
  DisLineIdeal          = 3;
  DisScrollThreshold    = 8;

  StallCmd              = $00000800;

  HitDecayRate          = 2;

  PtrBytes              = 14;
  PtrCenter             = 6;

  CogSize               = $400;
  CogBlockSize          = $10;
  CogBlocks             = CogSize div CogBlockSize;

  HubSize               = $7C000;
  HubBlockSize          = $1000;
  HubBlocks             = HubSize div HubBlockSize;
  HubSubBlockSize       = $80;
  HubSubBlocks          = HubSize div HubSubBlockSize;
  HubBlockRatio         = HubBlockSize div HubSubBlockSize;

  HubMapWidth           = 64;
  HubMapHeight          = HubSubBlocks div HubMapWidth;

  RegWatchSize          = $1F0;
  RegWatchListSize      = 16;

  SmartPins             = 64;
  SmartWatchSize        = SmartPins;
  SmartWatchListSize    = 7;

  SmoothFillMax         = 4096;

type
  TDebuggerForm         = class(TForm)

    MouseMoveTimer      : TTimer;
    BreakpointTimer     : TTimer;

private

  CaptionStr            : string;
  CaptionPos            : boolean;

  DebuggerMsg           : array [0..DebuggerMsgSize - 1] of integer;

  cBackground           : integer;      // color scheme
  cBox                  : integer;
  cBox2                 : integer;
  cBox3                 : integer;
  cData                 : integer;
  cData2                : integer;
  cDataDim              : integer;
  cIndicator            : integer;
  cName                 : integer;
  cHighSame             : integer;
  cLowSame              : integer;
  cHighDiff             : integer;
  cLowDiff              : integer;
  cModeButton           : integer;
  cModeText             : integer;
  cModeButtonDim        : integer;
  cModeTextDim          : integer;
  cCmdButton            : integer;
  cCmdText              : integer;
  cCmdButtonDim         : integer;
  cCmdTextDim           : integer;

  TextSize              : integer;
  ChrWidth              : integer;
  ChrHeight             : integer;
  BitmapWidth           : integer;
  BitmapHeight          : integer;

  Bitmap                : array [0..2] of TBitmap;
  BitmapLine            : array [0..SmoothFillMax - 1] of PByte;

  RegMap                : TBitMap;
  RegMapLine            : array [0..$1FF] of pointer;

  LutMap                : TBitMap;
  LutMapLine            : array [0..$1FF] of pointer;

  HubMap                : TBitMap;
  HubMapLine            : array [0..$3F] of pointer;

  RegBoxLeft,         RegBoxTop,          RegBoxRight,        RegBoxBottom        : integer;
  RegMapLeft,         RegMapTop,          RegMapRight,        RegMapBottom        : integer;
  LutBoxLeft,         LutBoxTop,          LutBoxRight,        LutBoxBottom        : integer;
  LutMapLeft,         LutMapTop,          LutMapRight,        LutMapBottom        : integer;
  CFLeft,             CFTop,              CFRight,            CFBottom            : integer;
  ZFLeft,             ZFTop,              ZFRight,            ZFBottom            : integer;
  PCLeft,             PCTop,              PCRight,            PCBottom            : integer;
  SkipLeft,           SkipTop,            SkipRight,          SkipBottom          : integer;
  XBYTELeft,          XBYTETop,           XBYTERight,         XBYTEBottom         : integer;
  CTLeft,             CTTop,              CTRight,            CTBottom            : integer;
  DisLeft,            DisTop,             DisRight,           DisBottom           : integer;
  RegWatchLeft,       RegWatchTop,        RegWatchRight,      RegWatchBottom      : integer;
  SFRBoxLeft,         SFRBoxTop,          SFRBoxRight,        SFRBoxBottom        : integer;
  SFRDataLeft,        SFRDataTop,         SFRDataRight,       SFRDataBottom       : integer;
  EventsBoxLeft,      EventsBoxTop,       EventsBoxRight,     EventsBoxBottom     : integer;
  EventsLeft,         EventsTop,          EventsRight,        EventsBottom        : integer;
  ExecLeft,           ExecTop,            ExecRight,          ExecBottom          : integer;
  StackBoxLeft,       StackBoxTop,        StackBoxRight,      StackBoxBottom      : integer;
  StackDataLeft,      StackDataTop,       StackDataRight,     StackDataBottom     : integer;
  IntBoxLeft,         IntBoxTop,          IntBoxRight,        IntBoxBottom        : integer;
  PtrBoxLeft,         PtrBoxTop,          PtrBoxRight,        PtrBoxBottom        : integer;
  PtrAddrLeft,        PtrAddrTop,         PtrAddrRight,       PtrAddrBottom       : integer;
  PtrDataLeft,        PtrDataTop,         PtrDataRight,       PtrDataBottom       : integer;
  PtrChrLeft,         PtrChrTop,          PtrChrRight,        PtrChrBottom        : integer;
  StatusLeft,         StatusTop,          StatusRight,        StatusBottom        : integer;
  PinBoxLeft,         PinBoxTop,          PinBoxRight,        PinBoxBottom        : integer;
  PinDataLeft,        PinDataTop,         PinDataRight,       PinDataBottom       : integer;
  SmartWatchLeft,     SmartWatchTop,      SmartWatchRight,    SmartWatchBottom    : integer;
  HubTabLeft,         HubTabTop,          HubTabRight,        HubTabBottom        : integer;
  HubBoxLeft,         HubBoxTop,          HubBoxRight,        HubBoxBottom        : integer;
  HubAddrLeft,        HubAddrTop,         HubAddrRight,       HubAddrBottom       : integer;
  HubDataLeft,        HubDataTop,         HubDataRight,       HubDataBottom       : integer;
  HubChrLeft,         HubChrTop,          HubChrRight,        HubChrBottom        : integer;
  HubMapLeft,         HubMapTop,          HubMapRight,        HubMapBottom        : integer;
  ButtonBoxLeft,      ButtonBoxTop,       ButtonBoxRight,     ButtonBoxBottom     : integer;
  ButtonBreakLeft,    ButtonBreakTop,     ButtonBreakRight,   ButtonBreakBottom   : integer;
  ButtonAddrLeft,     ButtonAddrTop,      ButtonAddrRight,    ButtonAddrBottom    : integer;
  ButtonInt3ELeft,    ButtonInt3ETop,     ButtonInt3ERight,   ButtonInt3EBottom   : integer;
  ButtonInt2ELeft,    ButtonInt2ETop,     ButtonInt2ERight,   ButtonInt2EBottom   : integer;
  ButtonInt1ELeft,    ButtonInt1ETop,     ButtonInt1ERight,   ButtonInt1EBottom   : integer;
  ButtonDebugLeft,    ButtonDebugTop,     ButtonDebugRight,   ButtonDebugBottom   : integer;
  ButtonInitLeft,     ButtonInitTop,      ButtonInitRight,    ButtonInitBottom    : integer;
  ButtonEventLeft,    ButtonEventTop,     ButtonEventRight,   ButtonEventBottom   : integer;
  ButtonInt3Left,     ButtonInt3Top,      ButtonInt3Right,    ButtonInt3Bottom    : integer;
  ButtonInt2Left,     ButtonInt2Top,      ButtonInt2Right,    ButtonInt2Bottom    : integer;
  ButtonInt1Left,     ButtonInt1Top,      ButtonInt1Right,    ButtonInt1Bottom    : integer;
  ButtonMainLeft,     ButtonMainTop,      ButtonMainRight,    ButtonMainBottom    : integer;
  ButtonGoLeft,       ButtonGoTop,        ButtonGoRight,      ButtonGoBottom      : integer;

  MouseX                : integer;
  MouseY                : integer;

  InRegBox              : boolean;
  InRegMap              : boolean;
  InLutBox              : boolean;
  InLutMap              : boolean;
  InCF                  : boolean;
  InZF                  : boolean;
  InPC                  : boolean;
  InSkip                : boolean;
  InXBYTE               : boolean;
  InCT                  : boolean;
  InDis                 : boolean;
  InRegWatch            : boolean;
  InSFRBox              : boolean;
  InSFRData             : boolean;
  InEventsBox           : boolean;
  InEvents              : boolean;
  InExec                : boolean;
  InStackBox            : boolean;
  InStackData           : boolean;
  InIntBox              : boolean;
  InPtrBox              : boolean;
  InPtrAddr             : boolean;
  InPtrData             : boolean;
  InPtrChr              : boolean;
  InStatusBox           : boolean;
  InPinBox              : boolean;
  InPinData             : boolean;
  InSmartWatch          : boolean;
  InHubTab              : boolean;
  InHubBox              : boolean;
  InHubAddr             : boolean;
  InHubData             : boolean;
  InHubChr              : boolean;
  InHubMap              : boolean;
  InButtonBox           : boolean;
  InButtonBreak         : boolean;
  InButtonAddr          : boolean;
  InButtonInt3E         : boolean;
  InButtonInt2E         : boolean;
  InButtonInt1E         : boolean;
  InButtonDebug         : boolean;
  InButtonInit          : boolean;
  InButtonEvent         : boolean;
  InButtonInt3          : boolean;
  InButtonInt2          : boolean;
  InButtonInt1          : boolean;
  InButtonMain          : boolean;
  InButtonGo            : boolean;

  CogImage              : array [0..$3FF] of integer;
  CogImageOld           : array [0..$3FF] of integer;
  CogImageHit           : array [0..$3FF] of byte;

  CogBlock              : array [0..CogBlocks - 1] of integer;
  CogBlockOld           : array [0..CogBlocks - 1] of integer;
  HubBlock              : array [0..HubBlocks - 1] of integer;
  HubBlockOld           : array [0..HubBlocks - 1] of integer;
  HubSubBlock           : array [0..HubSubBlocks - 1] of integer;
  HubSubBlockOld        : array [0..HubSubBlocks - 1] of integer;
  HubSubBlockHit        : array [0..HubSubBlocks - 1] of byte;

  SmartBuff             : array [0..SmartPins - 1] of integer;
  SmartBuffOld          : array [0..SmartPins - 1] of integer;

  WatchReg              : array [0..RegWatchSize - 1] of word;
  WatchRegList          : array [0..RegWatchListSize - 1] of integer;

  WatchSmart            : array [0..SmartWatchSize - 1] of word;
  WatchSmartList        : array [0..SmartWatchListSize - 1] of integer;
  WatchSmartAll         : boolean;

  BreakAddr             : integer;
  BreakEvent            : integer;
  BreakValue            : integer;
  StallBrk              : integer;
  RepeatMode            : boolean;
  FirstBreak            : boolean;

  OldPC                 : integer;
  DisMode               : integer;
  CurDisMode            : integer;
  DisAddr               : integer;
  CurDisAddr            : integer;
  CogAddr               : integer;
  HubAddr               : integer;
  MapCogAddr            : integer;
  MapHubAddr            : integer;
  DisScrollTimer        : integer;
  OldTickCount          : integer;

  Hint                  : string;

  KeyShift              : TShiftState;

  SmoothFillSize        : integer;
  SmoothFillColor       : integer;
  SmoothFillBuff        : array [0..SmoothFillMax * 3 - 1] of byte;

published

  procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;

  procedure FormCreate(Sender: TObject);
  procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  procedure FormMouseMoveTimeout(Sender: TObject);
  procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
  procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure FormKeyPress(Sender: TObject; var Key: Char);
  procedure FormMove(var Msg: TWMMove); message WM_WINDOWPOSCHANGED;
  procedure FormPaint(Sender: TObject);
  procedure FormBreakpointTimeout(Sender: TObject);
  procedure FormDestroy(Sender: TObject);

  procedure Breakpoint;

  procedure DrawBaseBitmap;
  procedure DrawBox(left, top, width, height, color, rim: integer; small: boolean);
  procedure DrawText(left, top, color: integer; style: TFontStyles; str: string);
  procedure DrawCheck(left, top, color: integer);
  procedure DrawDelta(left, top, color: integer);
  procedure DrawArrowUp(left, top, color: integer);
  procedure DrawArrowRight(left, top, color: integer);
  procedure DrawRegBin(left, top, value, color: integer);
  procedure DrawPtrBytes(left, top, address: integer; buff:PByteArray);
  procedure DrawInt(left, top, int: integer);
  procedure BlendPixel(var p:PByte; a, b: integer; alpha, shade: byte);
  procedure BitmapToCanvas(Level: integer);

  procedure ResetRegWatch;
  procedure ResetSmartWatch;
  procedure BoxBoundary(var Left, Top, Right, Bottom: integer; L, T, W, H, B: integer);
  function  Frac(x, y: integer): integer;
  function  MouseWithin(Left, Top, Right, Bottom, Cadence: integer; HintStr: string): boolean;
  function  WinRGB(c: integer): integer;

  procedure SmoothShape(xc, yc, xs, ys, xro, yro, thick, color: integer; opacity: byte);
  procedure SmoothFillSetup(size, color: integer);
  procedure SmoothRect(x, y, xs, ys: integer; opacity: byte);
  procedure SmoothFill(x, y, count: integer; opacity: byte);
  procedure SmoothPlot(x, y: integer; opacity: byte);

  procedure SmoothDot(x, y, radius, color: integer; opacity: byte);
  procedure SmoothLine(x1, y1, x2, y2, radius, color: integer; opacity: byte);
  procedure SmoothSlice(swapxy: boolean; x, yb, yt, color: integer; opacity: byte);
  procedure SmoothPixel(swapxy: boolean; x, y, color: integer; opacity, opacity2: byte);
  function  SmoothClip(var x1, y1, x2, y2: integer): boolean;
  function  SmoothClipTest(x, y, lft, rgt, bot, top: integer): integer;

public

  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;

end;

implementation

uses GlobalUnit, SerialUnit;


////////////////////////
//  Low-Level Events  //
////////////////////////

constructor TDebuggerForm.Create(AOwner: TComponent);
var
  i: integer;
begin
  inherited CreateNew(AOwner);
  BorderIcons := [biSystemMenu];
  BorderStyle := bsDialog;
  Font.Charset := DEFAULT_CHARSET;
  Font.Color := clWindowText;
  Font.Height := -11;
  Font.Name := 'MS Sans Serif';
  Font.Style := [];
  PixelsPerInch := 96;
  OldCreateOrder := False;
  OnCreate := FormCreate;
  OnMouseMove := FormMouseMove;
  OnMouseDown := FormMouseDown;
  OnMouseWheel := FormMouseWheel;
  OnKeyDown := FormKeyDown;
  OnKeyPress := FormKeyPress;
  OnPaint := FormPaint;
  OnDestroy := FormDestroy;
  // Set up mouse-move timer
  MouseMoveTimer := TTimer.Create(Self);
  MouseMoveTimer.OnTimer := FormMouseMoveTimeout;
  MouseMoveTimer.Enabled := False;
  // Set up breakpoint timer
  BreakpointTimer := TTimer.Create(Self);
  BreakpointTimer.OnTimer := FormBreakpointTimeout;
  BreakpointTimer.Enabled := False;
end;

destructor TDebuggerForm.Destroy;
begin
  MouseMoveTimer.Free;
  BreakpointTimer.Free;
  inherited Destroy;
end;

procedure TDebuggerForm.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := Msg.Result or DLGC_WANTTAB;
end;


//////////////
//  Events  //
//////////////

procedure TDebuggerForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  // Init arrays
  for i := 0 to CogBlocks - 1 do CogBlock[i] := -1;
  for i := 0 to HubBlocks - 1 do HubBlock[i] := -1;
  for i := 0 to HubSubBlocks - 1 do HubSubBlockHit[i] := 255;
  for i := 0 to $3FF do CogImageHit[i] := 255;
  for i := 0 to SmartPins - 1 do SmartBuff[i] := -1;
  ResetRegWatch;
  ResetSmartWatch;
  // Init miscellaneous
  FirstBreak := True;
  BreakAddr := $00000;
  BreakEvent := 1;
  StallBrk := StallCmd;
  RepeatMode := False;
  OldPC := -9;          // -9 causes initial ideal line in disassembly window
  DisMode := dmPC;
  DisAddr := 0;
  CogAddr := 0;
  HubAddr := 0;
  MapCogAddr := 0;
  MapHubAddr := 0;
  WatchSmartAll := False;
  Hint := '';
  DisScrollTimer := 0;
  OldTickCount := 0;
  // Set up cog/lut/hub bitmaps
  RegMap := TBitmap.Create;
  RegMap.PixelFormat := pf24bit;
  RegMap.Width := 32;
  RegMap.Height := 512;
  for i := 0 to 511 do RegMapLine[i] := RegMap.ScanLine[i];
  LutMap := TBitmap.Create;
  LutMap.PixelFormat := pf24bit;
  LutMap.Width := 32;
  LutMap.Height := 512;
  for i := 0 to 511 do LutMapLine[i] := LutMap.ScanLine[i];
  HubMap := TBitmap.Create;
  HubMap.PixelFormat := pf24bit;
  HubMap.Width := HubMapWidth;
  HubMap.Height := HubMapHeight;
  for i := 0 to HubMapHeight - 1 do HubMapLine[i] := HubMap.ScanLine[i];
  // Set up display bitmaps
  for i := 0 to 2 do
  begin
    Bitmap[i] := TBitmap.Create;
    Bitmap[i].PixelFormat := pf24bit;
  end;
  // Trim text size if too large
  Bitmap[0].Canvas.Font.Name := FontName;
  TextSize := FontSize + 1;
  repeat
    Dec(TextSize);
    Bitmap[0].Canvas.Font.Size := TextSize;
    ChrWidth := Bitmap[0].Canvas.TextWidth('X');
    ChrHeight := Bitmap[0].Canvas.TextHeight('X');
    BitmapWidth := ChrWidth * Cols;
    BitmapHeight := ChrHeight * Rows shr 1;
  until BitmapWidth <= SmoothFillMax;
  // Set display bitmap metrics
  for i := 0 to 2 do
  begin
    Bitmap[i].Width := BitmapWidth;
    Bitmap[i].Height := BitmapHeight;
  end;
  for i := 0 to BitmapHeight - 1 do BitmapLine[i] := Bitmap[0].ScanLine[i];
  // Set color scheme
  for i := 0 to TopColor do PIntegerArray(@cBackground)[i] := ColorScheme[i];
  // Draw base bitmap and store for faster redraw
  DrawBaseBitmap;
  // Set window metrics
  Left := P2.DebugDisplayLeft + DebuggerID * ChrHeight * 2;
  Top := P2.DebugDisplayTop + DebuggerID * ChrHeight * 2;
  ClientWidth := BitmapWidth;
  ClientHeight := BitmapHeight;
  // Set caption
  CaptionStr := ('Debugger - Cog ' + Chr(DebuggerID + Byte('0')));
  Caption := CaptionStr;
  CaptionPos := False;
  // Reset mouse-position variables
  FormMouseMove(Self, [], 0, 0);
  // Show window
  Show;
end;

procedure TDebuggerForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  // Record mouse position here for all other mouse events
  MouseX := X;
  MouseY := Y;
  // What box is the mouse in?
  Hint := '';
  InRegBox := MouseWithin(RegBoxLeft, RegBoxTop, RegBoxRight, RegBoxBottom, 0, 'Cog Register Bitmap/Heatmap');
  InRegMap := MouseWithin(RegMapLeft, RegMapTop, RegMapRight, RegMapBottom, 0, 'Cog Register Bitmap/Heatmap | Click to lock disassembly to REG subrange');
  InLutBox := MouseWithin(LutBoxLeft, LutBoxTop, LutBoxRight, LutBoxBottom, 0, 'LUT Register Bitmap/Heatmap');
  InLutMap := MouseWithin(LutMapLeft, LutMapTop, LutMapRight, LutMapBottom, 0, 'LUT Register Bitmap/Heatmap | Click to lock disassembly to LUT subrange');
  InCF := MouseWithin(CFLeft, CFTop, CFRight, CFBottom, 0, 'Carry Flag');
  InZF := MouseWithin(ZFLeft, ZFTop, ZFRight, ZFBottom, 0, 'Zero Flag');
  InPC := MouseWithin(PCLeft, PCTop, PCRight, PCBottom, 0, 'Program Counter | Click to lock disassembly to PC');
  InSkip := MouseWithin(SkipLeft, SkipTop, SkipRight, SkipBottom, 0, 'Skip-Instruction Pattern');
  InXBYTE := MouseWithin(XBYTELeft, XBYTETop, XBYTERight, XBYTEBottom, 0, '');
  InCT := MouseWithin(CTLeft, CTTop, CTRight, CTBottom, 0, '');
  InDis := MouseWithin(DisLeft, DisTop, DisRight, DisBottom, 0, 'L-Click to lock to PC | R-Click to toggle break address | Mousewheel {+Ctrl/Shift} scrolls');
  InRegWatch := MouseWithin(RegWatchLeft, RegWatchTop, RegWatchRight, RegWatchBottom, 0, 'Register-Delta Watch List | Click or <R> to reset list');
  InSFRBox := MouseWithin(SFRBoxLeft, SFRBoxTop, SFRBoxRight, SFRBoxBottom, 0, 'Special-Function Registers');
  InSFRData := MouseWithin(SFRDataLeft, SFRDataTop, SFRDataRight, SFRDataBottom, 0, '');
  InEventsBox := MouseWithin(EventsBoxLeft, EventsBoxTop, EventsBoxRight, EventsBoxBottom, 0, 'Event Flags');
  InEvents := MouseWithin(EventsLeft, EventsTop, EventsRight, EventsBottom, 0, 'Event Flags | L-Click to break on ' + EventName[Within((MouseY - EventsTop) div ChrHeight, 0, 14) + 1] + ' event | R-Click to toggle');  // 'Within' is required since MouseY is potentially out-of-range
  InExec := MouseWithin(ExecLeft, ExecTop, ExecRight, ExecBottom, 0, 'Instruction Disassembly');
  InStackBox := MouseWithin(StackBoxLeft, StackBoxTop, StackBoxRight, StackBoxBottom, 0, 'Stack Registers (top..bottom)');
  InStackData := MouseWithin(StackDataLeft, StackDataTop, StackDataRight, StackDataBottom, 9, '');
  InIntBox := MouseWithin(IntBoxLeft, IntBoxTop, IntBoxRight, IntBoxBottom, 0, 'Interrupt Status');
  InPtrBox := MouseWithin(PtrBoxLeft, PtrBoxTop, PtrBoxRight, PtrBoxBottom, 0, 'Pointers and Data');
  InPtrAddr := MouseWithin(PtrAddrLeft, PtrAddrTop, PtrAddrRight, PtrAddrBottom, 0, '');
  InPtrData := MouseWithin(PtrDataLeft, PtrDataTop, PtrDataRight, PtrDataBottom, 3, '');
  InPtrChr := MouseWithin(PtrChrLeft, PtrChrTop, PtrChrRight, PtrChrBottom, 0, '');
  InStatusBox := MouseWithin(StatusLeft, StatusTop, StatusRight, StatusBottom, 0, 'Indicators for COGINIT, STALLI, Streamer, Color Modulator, LUT sharing');
  InPinBox := MouseWithin(PinBoxLeft, PinBoxTop, PinBoxRight, PinBoxBottom, 0, 'Pin Registers');
  InPinData := MouseWithin(PinDataLeft, PinDataTop, PinDataRight, PinDataBottom, 9, '');
  InSmartWatch := MouseWithin(SmartWatchLeft, SmartWatchTop, SmartWatchRight, SmartWatchBottom, 0, '');
  InHubTab := MouseWithin(HubTabLeft, HubTabTop, HubTabRight, HubTabBottom, 0, 'Hub Data');
  InHubBox := MouseWithin(HubBoxLeft, HubBoxTop, HubBoxRight, HubBoxBottom, 0, 'Hub Data | Mousewheel {+Ctrl/Shift} scrolls');
  InHubAddr := MouseWithin(HubAddrLeft, HubAddrTop, HubAddrRight, HubAddrBottom, 0, 'Hub Data | Mousewheel changes HUB address digit(s)');
  InHubData := MouseWithin(HubDataLeft, HubDataTop, HubDataRight, HubDataBottom, 3, '');
  InHubChr := MouseWithin(HubChrLeft, HubChrTop, HubChrRight, HubChrBottom, 0, '');
  InHubMap := MouseWithin(HubMapLeft, HubMapTop, HubMapRight, HubMapBottom, 0, 'HUB Heatmap | Click to lock HUB address');
  InButtonBox := MouseWithin(ButtonBoxLeft, ButtonBoxTop, ButtonBoxRight, ButtonBoxBottom, 0, 'Break Control | Select break condition(s) and execute code');
  InButtonBreak := MouseWithin(ButtonBreakLeft, ButtonBreakTop, ButtonBreakRight, ButtonBreakBottom, 0, 'Click or <B> to select asynchronous BREAK | Another cog must be in DEBUG for BREAK to work');
  InButtonAddr := MouseWithin(ButtonAddrLeft, ButtonAddrTop, ButtonAddrRight, ButtonAddrBottom, 0, 'L-Click to break on PC address | R-Click to toggle | R-Click in disassembly to set address');
  InButtonInt3E := MouseWithin(ButtonInt3ELeft, ButtonInt3ETop, ButtonInt3ERight, ButtonInt3EBottom, 0, 'L-Click to break on INT3 entry | R-Click to toggle');
  InButtonInt2E := MouseWithin(ButtonInt2ELeft, ButtonInt2ETop, ButtonInt2ERight, ButtonInt2EBottom, 0, 'L-Click to break on INT2 entry | R-Click to toggle');
  InButtonInt1E := MouseWithin(ButtonInt1ELeft, ButtonInt1ETop, ButtonInt1ERight, ButtonInt1EBottom, 0, 'L-Click to break on INT1 entry | R-Click to toggle');
  InButtonDebug := MouseWithin(ButtonDebugLeft, ButtonDebugTop, ButtonDebugRight, ButtonDebugBottom, 0, 'L-Click to break on DEBUG | R-Click or <D> to toggle | DEBUG is exclusive to all but INIT');
  InButtonInit := MouseWithin(ButtonInitLeft, ButtonInitTop, ButtonInitRight, ButtonInitBottom, 0, 'L-Click to break on COGINIT | R-Click or <I> to toggle | INIT is independent of all others');
  InButtonEvent := MouseWithin(ButtonEventLeft, ButtonEventTop, ButtonEventRight, ButtonEventBottom, 0, 'L-Click to break on event | R-Click to toggle | Select event by clicking on CT1..QMT');
  InButtonInt3 := MouseWithin(ButtonInt3Left, ButtonInt3Top, ButtonInt3Right, ButtonInt3Bottom, 0, 'L-Click to break on INT3 instructions (single-step) | R-Click to toggle');
  InButtonInt2 := MouseWithin(ButtonInt2Left, ButtonInt2Top, ButtonInt2Right, ButtonInt2Bottom, 0, 'L-Click to break on INT2 instructions (single-step) | R-Click to toggle');
  InButtonInt1 := MouseWithin(ButtonInt1Left, ButtonInt1Top, ButtonInt1Right, ButtonInt1Bottom, 0, 'L-Click to break on INT1 instructions (single-step) | R-Click to toggle');
  InButtonMain := MouseWithin(ButtonMainLeft, ButtonMainTop, ButtonMainRight, ButtonMainBottom, 0, 'L-Click to break on MAIN instructions (single-step) | R-Click or <M> to toggle');
  InButtonGo := MouseWithin(ButtonGoLeft, ButtonGoTop, ButtonGoRight, ButtonGoBottom, 0, '');
  // Resolve any reg map address
  if InRegMap then
    MapCogAddr := Within((MouseY - RegMapTop) shl 9 div (RegMapBottom - RegMapTop) - 8, $000, $1F0)
  // Resolve any lut map address
  else if InLutMap then
    MapCogAddr := Within((MouseY - LutMapTop) shl 9 div (LutMapBottom - LutMapTop) - 8, $000, $1F0) + $200
  // Resolve any hub map address
  else if InHubMap then
    MapHubAddr := (MouseY - HubMapTop) * HubMapHeight div (HubMapBottom - HubMapTop) * HubMapWidth * HubSubBlockSize +
                  (MouseX - HubMapLeft) * HubMapWidth div (HubMapRight - HubMapLeft) * HubSubBlockSize;
  // Reset mouse-move timer
  MouseMoveTimer.Enabled := False;
  MouseMoveTimer.Interval := 50;
  MouseMoveTimer.Enabled := True;
end;

procedure TDebuggerForm.FormMouseMoveTimeout(Sender: TObject);
var
  p: TPoint;
begin
  p := ScreenToClient(Mouse.CursorPos);         // is mouse off form?
  if (p.x < 0) or (p.x >= ClientWidth) or
     (p.y < 0) or (p.y >= ClientHeight) then
  begin
    FormMouseMove(Self, [], 0, 0);              // signal mouse is now off form
    MouseMoveTimer.Enabled := False;            // cancel mouse-move timer
  end;
end;

procedure TDebuggerForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  i, j: integer;
  LB, RB: boolean;
begin
  LB := Button = mbLeft;
  RB := Button = mbRight;
  // In Go button?
  if InButtonGo then
  begin
    // Break?
    if BreakpointTimer.Enabled = False then
    begin
      RequestCOGBRK := RequestCOGBRK or 1 shl (DebuggerMsg[mCOGN] and 7);
      StallBrk := StallCmd;
      RepeatMode := False;
    end
    // Stop?
    else if RepeatMode then
    begin
      StallBrk := StallCmd;
      RepeatMode := False;
    end
    // Go-single?
    else if LB then
      StallBrk := BreakValue
    // Go-repeat?
    else if RB then
    begin
      OldTickCount := GetTickCount;
      RepeatMode := True;
    end;
  end
  // In MAIN button?
  else if InButtonMain then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000001
    else if RB then
      BreakValue := BreakValue and $FFFFFFEF xor $00000001;
  end
  // In INT1 button?
  else if InButtonInt1 then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000002
    else if RB then
      BreakValue := BreakValue and $FFFFFFEF  xor $00000002;
  end
  // In INT2 button?
  else if InButtonInt2 then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000004
    else if RB then
      BreakValue := BreakValue and $FFFFFFEF xor $00000004;
  end
  // In INT3 button?
  else if InButtonInt3 then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000008
    else if RB then
      BreakValue := BreakValue and $FFFFFFEF xor $00000008;
  end
  // In DEBUG button?
  else if InButtonDebug then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000010
    else if RB then
      BreakValue := BreakValue and $00000110 xor $00000010;
  end
  // In INT1E button?
  else if InButtonInt1E then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000020
    else if RB then
      BreakValue := BreakValue and $FFFFFFEF xor $00000020;
  end
  // In INT2E button?
  else if InButtonInt2E then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000040
    else if RB then
      BreakValue := BreakValue and $FFFFFFEF xor $00000040;
  end
  // In INT3E button?
  else if InButtonInt3E then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000080
    else if RB then
      BreakValue := BreakValue and $FFFFFFEF xor $00000080;
  end
  // In INIT button?
  else if InButtonInit then
  begin
    if LB then
      BreakValue := BreakValue or $00000100           // bit 8 is used to convey COGINIT, but set on BRK before RETI0 to enable async break
    else if RB then
      BreakValue := BreakValue xor $00000100;
  end
  // In CT1..QMT or event button?
  else if InEvents or InButtonEvent then
  begin
    if InEvents then
      BreakEvent := (MouseY - EventsTop) div ChrHeight + 1;
    if LB then
      BreakValue := BreakValue and $00000100 or $00000200 or BreakEvent shl 12
    else if RB then
    begin
      if BreakValue and $00000200 <> 0 then
        BreakValue := BreakValue and $00000DEF
      else
        BreakValue := BreakValue and $00000BEF or $00000200 or BreakEvent shl 12;
    end;
  end
  // In address breakpoint button?
  else if inButtonAddr then
  begin
    if LB then
      BreakValue := BreakValue and $00000100 or $00000400 or BreakAddr shl 12
    else if RB then
    begin
      if BreakValue and $00000400 <> 0 then
        BreakValue := BreakValue and $00000BEF
      else
        BreakValue := BreakValue and $00000DEF or $00000400 or BreakAddr shl 12;
    end;
  end
  // In BREAK button?
  else if InButtonBreak then
    BreakValue := BreakValue and $00000100
  // In REG/LUT map?
  else if InRegMap or InLutMap then
  begin
    DisMode := dmCog;
    CogAddr := MapCogAddr;
  end
  // In PC box?
  else if InPC then
    DisMode := dmPC
  // In disassembly box?
  else if InDis then
  begin
    // Lock disassembly to PC?
    if LB then
      DisMode := dmPC
    // Set breakpoint?
    else if RB then
    begin
      i := (MouseY - DisTop) div ChrHeight;
      if (CurDisMode = dmHub) and (CurDisAddr + i shl 2 < $400) then Exit;
      if (CurDisMode = dmHub) or (CurDisAddr >= $400) then
        j := (CurDisAddr + i shl 2) and $FFFFF
      else
        j := (CurDisAddr + i) and $3FF;
      if (BreakValue and $00000400 <> 0) and (BreakAddr = j) then
        BreakValue := BreakValue and $00000BFF
      else
      begin
        BreakAddr := j;
        BreakValue := BreakValue and $00000DFF or $00000400 or BreakAddr shl 12;
      end;
    end;
  end
  // In register watch?
  else if InRegWatch then
    ResetRegWatch
  // In SFR data?
  else if InSFRData then
  begin
    i := (MouseY - SFRDataTop) div ChrHeight;
    j := CogImage[$1F0 + i] and $FFFFF;
    if (j < $400) and (i < 6) then    // treat IJMP3..IRET1 as code pointers
    begin
      DisMode := dmCog;
      CogAddr := j;
    end
    else                              // treat PA..PTRB as hub data pointers
    begin
      DisMode := dmHub;
      HubAddr := j;
    end;
  end
  // In stack data?
  else if InStackData then            // treat stack values as code pointers
  begin
    i := (MouseX - StackDataLeft) div ChrWidth;
    j := DebuggerMsg[mSTK0 + i div 9] and $FFFFF;
    if j < $400 then
    begin
      DisMode := dmCog;
      CogAddr := j;
    end
    else
    begin
      DisMode := dmHub;
      HubAddr := j;
    end;
  end
  // In pointer addresses?
  else if InPtrAddr then              // treat pointer addresses as hub data pointers
  begin
    DisMode := dmHub;
    HubAddr := DebuggerMsg[mFPTR + (MouseY - PtrAddrTop) div ChrHeight] and $FFFFF;
  end
  // In pointer data?
  else if InPtrData then
  begin
    i := (MouseX - PtrDataLeft) div ChrWidth;
    j := (DebuggerMsg[mFPTR + (MouseY - PtrDataTop) div ChrHeight] - PtrCenter) and $FFFFF;
    DisMode := dmHub;
    HubAddr := (j + i div 3) and $FFFFF;
  end
  // In pointer chr?
  else if InPtrChr then
  begin
    i := (MouseX - PtrChrLeft) div ChrWidth;
    j := (DebuggerMsg[mFPTR + (MouseY - PtrDataTop) div ChrHeight] - PtrCenter) and $FFFFF;
    DisMode := dmHub;
    HubAddr := (j + i) and $FFFFF;
  end
  // In smart pin watch?
  else if InSmartWatch then
  begin
    ResetSmartWatch;
    // Toggle smart pin watch?
    if RB then
      WatchSmartAll := not WatchSmartAll;
  end
  // In hub data or chr?
  else if InHubData or InHubChr then
  begin
    if InHubData then
      i := (MouseY - HubDataTop) div ChrHeight shl 4 +
           (MouseX - HubDataLeft) div ChrWidth div 3
    else
      i := (MouseY - HubChrTop) div ChrHeight shl 4 +
           (MouseX - HubChrLeft) div ChrWidth;
    DisMode := dmHub;
    HubAddr := (HubAddr + i) and $FFFFF;
  end
  // In hub map?
  else if InHubMap then
    HubAddr := MapHubAddr;
end;

procedure TDebuggerForm.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
const
  DisDeltas : array [0..3] of integer = (1, 4, 16, 32);
  HubDeltas : array [0..3] of integer = (16, 1, 4, 128);
var
  i, j, DisStep, HubStep: integer;
begin
  if WheelDelta > 0 then i := -1 else i := 1;
  j := Ord(ssShift in Shift) shl 1 or Ord(ssCtrl in Shift);
  DisStep := i * DisDeltas[j];
  HubStep := i * HubDeltas[j];
  // In disassembly box?
  if InDis then
  begin
    if DisMode = dmPC then           // change dmPC to dmCog or dmHub to scroll freely
    begin
      if DisAddr < $400 then
      begin
        DisMode := dmCog;
        CogAddr := DisAddr;
      end
      else
      begin
        DisMode := dmHub;
        HubAddr := DisAddr;
      end;
    end;
    case DisMode of
      dmCog: CogAddr := Within(CogAddr + DisStep, $000, $400 - DisLines);
      dmHub: HubAddr := (HubAddr + DisStep shl 2) and $FFFFF;
    end;
  end
  // In hub address?
  else if InHubAddr then
    HubAddr := (HubAddr + i shl (4 * (4 - (MouseX - HubAddrLeft) div ChrWidth))) and $FFFFF
  // In hub data?
  else if InHubBox and not InHubMap then
    HubAddr := (HubAddr + HubStep) and $FFFFF;
end;

procedure TDebuggerForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  k: Char;
begin
  case Key of                        // capture keys missed by OnKeyPress
    kLeft:     k := Chr(1);
    kRight:    k := Chr(2);
    kUp:       k := Chr(3);
    kDown:     k := Chr(4);
    kHome:     k := Chr(5);
    kEnd:      k := Chr(6);
    kDelete:   k := Chr(7);
    kInsert:   k := Chr(10);
    kPageUp:   k := Chr(11);
    kPageDown: k := Chr(12);
  else Exit;
  end;
  KeyShift := Shift;
  FormKeyPress(Self, k); Exit;
end;

procedure TDebuggerForm.FormKeyPress(Sender: TObject; var Key: Char);
var
  KeyPress: byte;
  i: integer;
begin
  // Get key
  KeyPress := Byte(Key);
  // Make uppercase
  if (KeyPress >= Byte('a')) and (KeyPress <= Byte('z')) then Dec(KeyPress, $20);
  // Process key
  case KeyPress of
    kSpace:    begin    // SPACE = left-click on Go button
                 FormMouseMove(Self, [], ButtonGoLeft, ButtonGoTop);
                 FormMouseDown(Self, mbLeft, [], 0, 0);
               end;
    kEnter:    begin    // ENTER = right-click on Go button
                 FormMouseMove(Self, [], ButtonGoLeft, ButtonGoTop);
                 FormMouseDown(Self, mbRight, [], 0, 0);
               end;
    Byte('B'): begin    // 'B' = click on BREAK button
                 FormMouseMove(Self, [], ButtonBreakLeft, ButtonBreakTop);
                 FormMouseDown(Self, mbLeft, [], 0, 0);
               end;
    Byte('I'): begin    // 'I' = right-click on INIT button
                 FormMouseMove(Self, [], ButtonInitLeft, ButtonInitTop);
                 FormMouseDown(Self, mbRight, [], 0, 0);
               end;
    Byte('D'): begin    // 'D' = right-click on DEBUG button
                 FormMouseMove(Self, [], ButtonDebugLeft, ButtonDebugTop);
                 FormMouseDown(Self, mbRight, [], 0, 0);
               end;
    Byte('M'): begin    // 'M' = right-click on MAIN button
                 FormMouseMove(Self, [], ButtonMainLeft, ButtonMainTop);
                 FormMouseDown(Self, mbRight, [], 0, 0);
               end;
    Byte('R'): begin    // 'R' = left-click on register watch box
                 FormMouseMove(Self, [], RegWatchLeft, RegWatchTop);
                 FormMouseDown(Self, mbLeft, [], 0, 0);
               end;
    3:         begin    // UP = go up one line in HUB
                 HubAddr := (HubAddr - $10) and $FFFFF;
               end;
    4:         begin    // DOWN = go down one line in HUB
                 HubAddr := (HubAddr + $10) and $FFFFF;
               end;
    11, 12:    begin    // PAGEUP/PAGEDOWN = go up one page or more in HUB
                 if ssShift in KeyShift then
                   i := $10000
                 else if ssCtrl in KeyShift then
                   i := $1000
                 else
                   i := HubSubBlockSize;
                 if KeyPress = 12 then i := -i;
                 HubAddr := (HubAddr - i) and $FFFFF;
               end;
  end;
end;

procedure TDebuggerForm.FormMove(var Msg: TWMMove);
begin
  inherited;
  Caption := CaptionStr + ' (' + IntToStr(Left) + ', ' + IntToStr(Top) + ')';
  CaptionPos := True;
end;

procedure TDebuggerForm.FormPaint(Sender: TObject);
begin
  BitmapToCanvas(1);
end;

procedure TDebuggerForm.FormBreakpointTimeout(Sender: TObject);
var
  x, y: integer;
  p: PByte;
begin
  // Disable timer
  BreakpointTimer.Enabled := False;
  // Clear hint
  DrawBox(HINTl, HINTt, HINTw, HINTh, cBox2, 3, False);
  // Dim window
  for y := 0 to BitmapHeight - 1 do
  begin
    p := PByte(BitmapLine[y]);
    for x := 0 to BitmapWidth - 1 do
    begin
      p^ := p^ shr 1; Inc(p);
      p^ := p^ shr 1; Inc(p);
      p^ := p^ shr 1; Inc(p);
    end;
  end;
  // Draw 'Break' on Go button
  DrawBox(bGOl, bGOt, bGOw, bGOh, cCmdButton, 6, False);
  DrawText(bGOl + 2 + q2, bGOt, cCmdText, [fsBold], 'Break');
  // Draw hint if no other cog has been in debug for 100ms
  if GetTickCount - LastDebugTick > 100 then
    DrawText(HINTl, HINTt, cIndicator, [fsItalic], 'To force an asynchronous break in this cog, another cog must be idling in its own debugger');
  // Update window
  BitMapToCanvas(0);
end;

procedure TDebuggerForm.FormDestroy(Sender: TObject);
begin
  RegMap.Free;
  LutMap.Free;
  HubMap.Free;
  Bitmap[0].Free;
  Bitmap[1].Free;
  Bitmap[2].Free;
end;


//////////////////
//  Breakpoint  //
//////////////////

procedure TDebuggerForm.Breakpoint;
var
  i, j, k, x, y, xs, ys, r, addr, inst: integer;
  PC, DifPC, ExecMode, cSame, cDiff, index: integer;
  CurCogAddr, CurHubAddr, CallDepth: integer;
  PCInCog, GetHubCode, SkipOn, DisCog, HiddenPC: boolean;
  ct: int64;
  h: byte;
  p: PByte;
  s: string;
  BuffDis: array [0..DisLines - 1] of integer;
  BuffFPTR: array [0..PtrBytes - 1] of byte;
  BuffPTRA: array [0..PtrBytes - 1] of byte;
  BuffPTRB: array [0..PtrBytes - 1] of byte;
  BuffHub: array [0..HubSubBlockSize - 1] of byte;
begin
  //  ------------------------------
  //   Receive initial data from P2
  //  ------------------------------

  // Receive debugger message
  for i := 0 to DebuggerMsgSize - 1 do
    DebuggerMsg[i] := RLong;
  // Receive reg/lut crc words
  for i := 0 to CogBlocks - 1 do
  begin
    CogBlockOld[i] := CogBlock[i];
    CogBlock[i] := RWord;
  end;
  // Receive hub checksum words
  for i := 0 to HubBlocks - 1 do
  begin
    HubBlockOld[i] := HubBlock[i];
    HubBlock[i] := RWord;
  end;

  //  ----------------------
  //   Process initial data
  //  ----------------------

  // Get initial break condition
  if FirstBreak then
  begin
    BreakValue := DebuggerMsg[mCOND];
    FirstBreak := False;
  end;
  // Set defaults
  CurDisMode := DisMode;
  CurCogAddr := CogAddr;
  CurHubAddr := HubAddr;
  // In REG/LUT map?
  if InRegMap or InLutMap then
  begin
    CurDisMode := dmCog;
    CurCogAddr := MapCogAddr;
  end
  // In PC?
  else if InPC then
    CurDisMode := dmPC
  // In SFR data?
  else if InSFRData then
  begin
    i := (MouseY - SFRDataTop) div ChrHeight;
    j := CogImage[$1F0 + i] and $FFFFF;
    if (j < $400) and (i < 6) then    // treat IJMP3..IRET1 as code pointers
    begin
      CurDisMode := dmCog;
      CurCogAddr := j;
    end
    else                              // treat PA..PTRB as hub data pointers
    begin
      CurDisMode := dmHub;
      CurHubAddr := j;
    end;
  end
  // In stack data?
  else if InStackData then            // treat stack values as code pointers
  begin
    i := (MouseX - StackDataLeft) div ChrWidth;
    j := DebuggerMsg[mSTK0 + i div 9] and $FFFFF;
    if j < $400 then
    begin
      CurDisMode := dmCog;
      CurCogAddr := j;
    end
    else
    begin
      CurDisMode := dmHub;
      CurHubAddr := j;
    end;
  end
  // In pointer addresses?
  else if InPtrAddr then              // treat pointer addresses as hub data pointers
  begin
    CurDisMode := dmHub;
    CurHubAddr := DebuggerMsg[mFPTR + (MouseY - PtrAddrTop) div ChrHeight] and $FFFFF;
  end
  // In hub box/map?
  else if InHubBox then
  begin
    CurDisMode := dmHub;
    if InHubMap then
      CurHubAddr := MapHubAddr;
  end;
  // Determine disassembly metrics
  PC := DebuggerMsg[mIRET] and $FFFFF;
  DifPC := Abs((PC - OldPC) shl 12 div 4096);                   // get absolute value of 20-bit difference
  OldPC := PC;
  PCInCog := PC < $400;
  if PCInCog then i := 0 else i := 2;                           // get PC scaling factor
  case CurDisMode of
    dmPC:  begin
             if DifPC > 8 shl i then                            // set PC instruction to ideal line?
               DisAddr := PC - DisLineIdeal shl i
             else if PC < DisAddr then                          // set PC instruction to top line?
               DisAddr := PC
             else if PC > DisAddr + (DisLines - 1) shl i then   // set PC instruction to bottom line?
             begin
               DisAddr := PC - (DisLines - 1) shl i;
             end
             else if PC <> DisAddr + DisLineIdeal shl i then    // scroll window towards ideal line?
             begin
               if DisScrollTimer < DisScrollThreshold then
                 Inc(DisScrollTimer)
               else
                 Inc(DisAddr, Within(PC - (DisAddr + DisLineIdeal shl i), -1, 1) shl i);
             end;
             if PCInCog then
               DisAddr := Within(DisAddr, $000, $400 - DisLines)
             else
               DisAddr := Within(DisAddr, $00000, $100000 - Dislines shl 2);
             CurDisAddr := DisAddr;
           end;
    dmCog: CurDisAddr := CurCogAddr;
    dmHub: CurDisAddr := CurHubAddr;
  end;
  // Is hub read needed for instructions?
  GetHubCode := (CurDisMode = dmPC) and not PCInCog;

  //  -----------------------------
  //   Send requests/command to P2
  //  -----------------------------

  // Send reg/lut block requests
  for i := 0 to CogBlocks - 1 do
  begin
    h := h shr 1;
    if CogBlock[i] <> CogBlockOld[i] then h := h or $80;
    if i and 7 = 7 then TByte(h);
  end;
  // Send detailed hub checksum requests (round up to 32 for full longs)
  for i := 0 to (HubBlocks + $1F) and not $1F - 1 do
  begin
    h := h shr 1;
    if HubBlock[i] <> HubBlockOld[i] then h := h or $80;
    if i and 7 = 7 then TByte(h);
  end;
  // Send hub read requests
  if GetHubCode then TLong(DisLines shl 2 shl 20 + CurDisAddr) else TLong(0);
  TLong(PtrBytes shl 20 + (DebuggerMsg[mFPTR] - PtrCenter) and $FFFFF);
  TLong(PtrBytes shl 20 + (DebuggerMsg[mPTRA] - PtrCenter) and $FFFFF);
  TLong(PtrBytes shl 20 + (DebuggerMsg[mPTRB] - PtrCenter) and $FFFFF);
  TLong(HubSubBlockSize shl 20 + CurHubAddr);
  // Send COGBRK requests
  TLong(RequestCOGBRK);
  RequestCOGBRK := 0;
  // Reset disassembly-scroll timer?
  if RepeatMode or (StallBrk <> StallCmd) then
    DisScrollTimer := 0;
  // Send STALL/BRK command
  if RepeatMode then
  begin
    i := GetTickCount;                                  // if less than 50ms since last breakpoint, do StallCmd to pause
    if i - OldTickCount < 50 then TLong(StallCmd)
    else
    begin
      TLong(BreakValue);                                // else, go to next breakpoint
      OldTickCount := i;
    end
  end
  else
  begin
    TLong(StallBrk);                                    // go to next breakpoint, then do StallCmd's to wait for new Go command
    StallBrk := StallCmd;
  end;

  //  ----------------------------
  //   Receive final data from P2
  //  ----------------------------

  // Receive reg/lut blocks
  for i := 0 to CogBlocks - 1 do
    if CogBlock[i] <> CogBlockOld[i] then
      for j := 0 to CogBlockSize - 1 do
        CogImage[i * CogBlockSize + j] := RLong;
  // Receive detailed hub checksum words
  for i := 0 to HubBlocks - 1 do
    if HubBlock[i] <> HubBlockOld[i] then
      for j := 0 to HubBlockRatio - 1 do
      begin
        k := i * HubBlockRatio + j;
        HubSubBlockOld[k] := HubSubBlock[k];
        HubSubBlock[k] := RWord;
        if HubSubBlockOld[k] = -1 then HubSubBlockOld[k] := HubSubBlock[k];
      end;
  // Receive hub reads
  if GetHubCode then
    for i := 0 to DisLines - 1        do BuffDis[i]  := RLong;
  for   i := 0 to PtrBytes - 1        do BuffFPTR[i] := RByte;
  for   i := 0 to PtrBytes - 1        do BuffPTRA[i] := RByte;
  for   i := 0 to PtrBytes - 1        do BuffPTRB[i] := RByte;
  for   i := 0 to HubSubBlockSize - 1 do BuffHub[i]  := RByte;
  // Receive smart pin data
  for i := 0 to SmartPins - 1 do
  begin
    SmartBuffOld[i] := SmartBuff[i];
    if i and 7 = 0 then j := RByte;
    if j shr (i and 7) and 1 <> 0 then
      SmartBuff[i] := RLong
    else
      SmartBuff[i] := 0;
    if SmartBuffOld[i] = -1 then SmartBuffOld[i] := SmartBuff[i];
  end;

  //  --------------------
  //   Process final data
  //  --------------------

  // Patch disassembly buffer if needed
  if not GetHubCode then
    for i := 0 to DisLines - 1 do
      case CurDisMode of
        dmPC, dmCog: BuffDis[i] := CogImage[CurDisAddr + i];
        dmHub:       BuffDis[i] := PIntegerArray(@BuffHub)[i];
      end;

  // Determine execution mode
  if      DebuggerMsg[mBRKCZ] shr 2 and 3 = 3 then ExecMode := 1
  else if DebuggerMsg[mBRKCZ] shr 4 and 3 = 3 then ExecMode := 2
  else if DebuggerMsg[mBRKCZ] shr 6 and 3 = 3 then ExecMode := 3
  else                                             ExecMode := 0;

  //  -------------------------------
  //   Update basic display elements
  //  -------------------------------

  // Start with base bitmap
  Bitmap[0].Canvas.Draw(0, 0, Bitmap[2]);
  // Draw C flag
  DrawText(CFl + 2, CFt, cData, [], Chr(DebuggerMsg[mIRET] shr 31 and 1 + Byte('0')));
  // Draw Z flag
  DrawText(ZFl + 2, ZFt, cData, [], Chr(DebuggerMsg[mIRET] shr 30 and 1 + Byte('0')));
  // Draw PC
  DrawText(PCl + 3, PCt, cData, [], IntToHex(DebuggerMsg[mIRET] and $FFFFF, 5));
  // Draw SKIP/SKIPF
  if DebuggerMsg[mBRKC] shr 27 and 1 = 0 then DrawText(SKIPl + 4, SKIPt, cName, [fsBold, fsItalic], 'F');
  CallDepth := DebuggerMsg[mBRKC] shr 28 and $F;
  SkipOn := (ExecMode = 0) and (CallDepth = 0);
  if SkipOn then i := cData else i := cDataDim;
  DrawRegBin(SKIPl + 6, SKIPt, DebuggerMsg[mBRKZ], i);
  if not SkipOn then
  begin
    if (ExecMode = 0) and (CallDepth <> 0) then s := 'CALL(' + IntToStr(i) + ')' else s := ModeName[ExecMode];
    DrawText(SKIPl + 15 - (Length(s) + 1) shr 1, SKIPt, cData, [fsBold], 'Suspended during ' + s);
  end;
  // Draw XBYTE
  DrawText(XBYTEl + 6, XBYTEt, cData, [], IntToHex(DebuggerMsg[mBRKC] shr 16 and $1FF, 3));
  if DebuggerMsg[mBRKC] shr 25 and 1 <> 0 then DrawCheck(XBYTEl + 10, XBYTEt, cIndicator);
  // Draw CT
  DrawText(CTl + 3, CTt, cData, [], IntToHex(DebuggerMsg[mCTH2], 8) + ' ' + IntToHex(DebuggerMsg[mCTL2], 8));
  // Draw special function registers
  for i := 0 to 15 do DrawText(SFRl + 10, SFRt + i shl 1, cData, [], IntToHex(CogImage[$1F0 + i], 8));
  // Draw events
  for i := 0 to 15 do DrawText(EVENTl + 4, EVENTt + i shl 1, cData, [], Chr(DebuggerMsg[mBRKC] shr i and 1 + Byte('0')));
  // Draw execution mode
  DrawText(EXECl, EXECt + 2, cData2, [], ModeName[ExecMode]);
  // Draw STACK
  for i := 0 to 7 do DrawText(STACKl + 6 + i * 9, STACKt, cData, [], IntToHex(DebuggerMsg[mSTK0 + i], 8));
  // Draw interrupts
  DrawInt(INTl, INTt + 0 shl 1, 1);
  DrawInt(INTl, INTt + 1 shl 1, 2);
  DrawInt(INTl, INTt + 2 shl 1, 3);
  // Draw RFxx/WFxx, PTRA, PTRB
  if DebuggerMsg[mBRKCZ] shr 20 and 1 <> 0 then s := 'W' else s := 'R';
  DrawText(PTRl, PTRt, cName, [fsBold, fsItalic], s);
  DrawPtrBytes(PTRl, PTRt + 0 shl 1, DebuggerMsg[mFPTR], @BuffFPTR);
  DrawPtrBytes(PTRl, PTRt + 1 shl 1, CogImage[$1F8], @BuffPTRA);
  DrawPtrBytes(PTRl, PTRt + 2 shl 1, CogImage[$1F9], @BuffPTRB);
  // Draw INIT, STALLI, STR, MOD, LUTS
  if DebuggerMsg[mBRKCZ] shr 23 and 1 <> 0 then
    DrawText(STATUSl + 1, STATUSt - 1 + q3, cIndicator, [fsBold, fsItalic], 'INIT');
  if DebuggerMsg[mBRKCZ] shr  1 and 1 <> 0 then
    DrawText(STATUSl, STATUSt + 1 + q1, cIndicator, [fsBold, fsItalic], 'STALLI');
  if DebuggerMsg[mBRKCZ] shr 21 and 1 <> 0 then
    DrawText(STATUSl - 1 + q3, STATUSt + 2 + q3, cIndicator, [fsBold, fsItalic], 'STR');
  if DebuggerMsg[mBRKCZ] shr 22 and 1 <> 0 then
    DrawText(STATUSl + 3 + q1, STATUSt + 2 + q3, cIndicator, [fsBold, fsItalic], 'MOD');
  if DebuggerMsg[mBRKC]  shr 26 and 1 <> 0 then
    DrawText(STATUSl + 1, STATUSt + 4 + q1, cIndicator, [fsBold, fsItalic], 'LUTS');
  // Draw pins in binary
  DrawRegBin(PINl + 4,  PINt + 0 shl 1, CogImage[$1FB], cData);
  DrawRegBin(PINl + 40, PINt + 0 shl 1, CogImage[$1FA], cData);
  DrawRegBin(PINl + 4,  PINt + 1 shl 1, CogImage[$1FD], cData);
  DrawRegBin(PINl + 40, PINt + 1 shl 1, CogImage[$1FC], cData);
  DrawRegBin(PINl + 4,  PINt + 2 shl 1, CogImage[$1FF], cData);
  DrawRegBin(PINl + 40, PINt + 2 shl 1, CogImage[$1FE], cData);
  // Draw hub data
  for j := 0 to 7 do
  begin
    i := (CurHubAddr + j shl 4) and $FFFFF;
    DrawText(HUBl, HUBt + j shl 1, cData, [], IntToHex(i, 5));
    for k := 0 to 15 do
    begin
      i := BuffHub[j shl 4 + k];
      DrawText(HUBl + 6 + k * 3, HUBt + j shl 1, cData2, [], IntToHex(i, 2));
      if (i < $20) or (i > $7E) then i := Byte('.');
      DrawText(HUBl + 55 + k, HUBt + j shl 1, cData2, [], Chr(i));
    end;
  end;

  //  --------------------
  //   Update disassembly
  //  --------------------

  DisCog := (CurDisMode = dmPC) and PCInCog or (CurDisMode = dmCog);
  x := (DISl + 35) * ChrWidth + ChrWidth shr 1;
  xs := ChrWidth * 42;
  ys := ChrHeight * 7 shr 3;
  r := ChrHeight shr 2;
  for i := 0 to DisLines - 1 do
  begin
    // Draw address
    if DisCog then
    begin
      addr := CurDisAddr + i;
      if addr < $200 then s := 'R' else s := 'L';
      s := s + '-' + IntToHex(addr, 3);
    end
    else
    begin
      addr := (CurDisAddr + i shl 2) and $FFFFF;
      s := IntToHex(addr, 5);
    end;
    DrawText(DISl, DISt + i shl 1, cData2, [fsBold], s);
    // Draw instruction long
    inst := BuffDis[i];
    DrawText(DISl + 6, DISt + i shl 1, cData, [], IntToHex(inst, 8));
    // Disassemble instruction long, may be register ROM
    if DisCog and (addr >= $1F8) and (addr <= $1FF) then
      s := '[ROM]        ' + DebugROM[addr and $7]
    else
    begin
      P2.DisassemblerAddr := addr;
      P2.DisassemblerInst := inst;
      P2Disassemble;
      s := PChar(@P2.DisassemblerString);
    end;
    // Prepare to draw instruction
    HiddenPC := (addr < $400) and (CurDisMode = dmHub);
    y := (DISt + 1 + i shl 1) * ChrHeight shr 1;
    // Inverse if instruction at PC
    if (addr = PC) and not HiddenPC then
    begin
      SmoothShape(x, y, xs, ys, r, r, 0, cData, 255);
      DrawText(DISl + 15, DISt + i shl 1, cBox2, [fsBold], s);
    end
    else
      DrawText(DISl + 15, DISt + i shl 1, cData2, [], s);
    // Strikethrough if instruction is to be skipped
    if addr < $400 then j := addr - PC else j := (addr - PC) div 4;
    if SkipOn and (j >= 0) and (j <= 31) and (DebuggerMsg[mBRKZ] shr j and 1 <> 0) and not HiddenPC then
      SmoothShape(x, y, xs, ys shr 1, r, r, 0, cData2, 160);
    // Highlight if breakpoint instruction
    if (BreakValue and $400 <> 0) and (BreakAddr = addr) and not HiddenPC then
      SmoothShape(x, y, xs, ys, r, r, 0, cName, 64);
  end;

  //  ----------------
  //   Update watches
  //  ----------------

  // Update reg watch
  for i := 0 to RegWatchSize - 1 do
    if WatchReg[i] = $FFFF then WatchReg[i] := 0                      // clear on first pass
    else if CogImage[i] <> CogImageOld[i] then WatchReg[i] := 1000    // set counter if changed
    else if WatchReg[i] > 1 then Dec(WatchReg[i]);                    // dec down to 1
  for i := 0 to RegWatchSize - 1 do
    if WatchReg[i] <> 0 then
    begin
      index := -1;
      for j := 0 to RegWatchListSize - 1 do       // first, look for same register in list
        if WatchRegList[j] shr 16 = i then
        begin
          index := j;
          Break;
        end;
      if index < 0 then                           // if not in list, find oldest update in list
      begin
        k := $FFFF;
        for j := RegWatchListSize - 1 downto 0 do
          if WatchRegList[j] and $FFFF <= k then
          begin
            k := WatchRegList[j] and $FFFF;
            index := j;
          end;
      end;
      WatchRegList[index] := i shl 16 + WatchReg[i];
    end;
  // Draw reg watch
  if (WatchRegList[0] and $FFFF) = 0 then
  begin
    DrawText(WATCHl + 3 + q2, WATCHt, cName, [fsBold, fsItalic], 'REG');
    DrawDelta(WATCHl + 7 + q2, WATCHt, cName);
  end
  else
    for i := 0 to RegWatchListSize - 1 do
    begin
      if (WatchRegList[i] and $FFFF) > 0 then
      begin
        y := WATCHt + i shl 1;
        DrawText(WATCHl, y, cData2, [fsBold], IntToHex(WatchRegList[i] shr 16, 3));
        DrawText(WATCHl + 4, y, cData, [], IntToHex(CogImage[WatchRegList[i] shr 16], 8));
      end;
    end;

  // Update smart pin watch
  for i := 0 to SmartWatchSize - 1 do
  begin
    if WatchSmart[i] = $FFFF then WatchSmart[i] := 0                  // if first pass, clear
    else if (WatchSmartAll or (CogImage[$1FA + i shr 5] shr (i and $1F) and 1 <> 0)) and       // else, if dir bit needed high (smart pin enabled)
            (i < 62) and                                              // ..and not tx/rx pins
            (SmartBuff[i] <> SmartBuffOld[i])                         // ..and changed
      then WatchSmart[i] := 1000                                      // ..then set counter
    else if WatchSmart[i] > 1 then Dec(WatchSmart[i]);                // else, dec down to 1
  end;

  for i := 0 to SmartWatchSize - 1 do
    if WatchSmart[i] <> 0 then
    begin
      index := -1;
      for j := 0 to SmartWatchListSize - 1 do     // first, look for same smart pin in list
        if WatchSmartList[j] shr 16 = i then
        begin
          index := j;
          Break;
        end;
      if index < 0 then                           // if not in list, find oldest update in list
      begin
        k := $FFFF;
        for j := SmartWatchListSize - 1 downto 0 do
          if WatchSmartList[j] and $FFFF <= k then
          begin
            k := WatchSmartList[j] and $FFFF;
            index := j;
          end;
      end;
      WatchSmartList[index] := i shl 16 + WatchSmart[i];
    end;
  // Draw smart pin watch
  if (WatchSmartList[0] and $FFFF) = 0 then
  begin
    DrawText(SMARTl, SMARTt, cName, [fsBold, fsItalic], 'RQPIN');
    DrawDelta(SMARTl + 6, SMARTt, cName);
  end
  else
    for i := 0 to SmartWatchListSize - 1 do
    begin
      if (WatchSmartList[i] and $FFFF) > 0 then
      begin
        x := SMARTl + q2 + i * 14;
        k := WatchSmartList[i] shr 16;
        DrawText(x, SMARTt, cData2, [fsBold], 'P' + Chr(Byte('0') + k div 10) + Chr(Byte('0') + k mod 10));
        DrawText(x + 4, SMARTt, cData, [], IntToHex(SmartBuff[k], 8));
      end;
    end;

  //  ----------------------------
  //   Update reg/lut/hub bitmaps
  //  ----------------------------

  // Update reg and lut bitmaps - updates CogImageOld, so must be done after reg watch update
  for y := 0 to $3FF do
  begin
    i := CogImage[y];
    h := CogImageHit[y];
    if h = 255 then h := 0
    else if i <> CogImageOld[y] then h := 254
    else Dec(h, Smaller(HitDecayRate, h));
    CogImageHit[y] := h;
    CogImageOld[y] := i;
    if y < $200 then
      p := PByte(RegMapLine[y])
    else
      p := PByte(LutMapLine[y - $200]);
    for x := 31 downto 0 do
    begin
      if i shr x and 1 <> 0 then
      begin
        cSame := cHighSame;
        cDiff := cHighDiff;
      end
      else
      begin
        cSame := cLowSame;
        cDiff := cLowDiff;
      end;
      if (y >= MapCogAddr) and (y < MapCogAddr + DisLines) and (InRegMap or InLutMap) or
         (y >= CurCogAddr) and (y < CurCogAddr + DisLines) and not(InRegMap or InLutMap) and (CurDisMode = dmCog) or
         (y >= CurDisAddr) and (y < CurDisAddr + DisLines) and not(InRegMap or InLutMap or InHubBox) and (CurDisMode = dmPC) then
        BlendPixel(p, cSame, cDiff, h, $40)
      else
        BlendPixel(p, cSame, cDiff, h, $00);
    end;
  end;

  // Update hub bitmap
  for y := 0 to HubSubBlocks - 1 do
  begin
    i := HubSubBlock[y];
    h := HubSubBlockHit[y];
    if h = 255 then h := 0
    else if i <> HubSubBlockOld[y] then h := 254
    else Dec(h, Smaller(HitDecayRate, h));
    HubSubBlockHit[y] := h;
    HubSubBlockOld[y] := i;
    p := HubMapLine[y shr 6];
    Inc(p, y and $3F * 3);
    BlendPixel(p, cDataDim, cYellow, h, $00);
  end;

  // Draw bitmaps
  BitMap[0].Canvas.StretchDraw(Rect(RegMapLeft, RegMapTop, RegMapRight, RegMapBottom), RegMap);
  BitMap[0].Canvas.StretchDraw(Rect(LutMapLeft, LutMapTop, LutMapRight, LutMapBottom), LutMap);
  BitMap[0].Canvas.StretchDraw(Rect(HubMapLeft, HubMapTop, HubMapRight, HubMapBottom), HubMap);

  //  ----------------
  //   Update buttons
  //  ----------------

  // Highlight MAIN button?
  if BreakValue and $00000001 <> 0 then
  begin
    DrawBox(bMAINl, bMAINt, bMAINw, bMAINh, cModeButton, 3, True);
    DrawText(bMAINl, bMAINt, cModeText, [fsBold], 'MAIN');
  end;
  // Highlight INT1 button?
  if BreakValue and $00000002 <> 0 then
  begin
    DrawBox(bINT1l, bINT1t, bINT1w, bINT1h, cModeButton, 3, True);
    DrawText(bINT1l, bINT1t, cModeText, [fsBold], 'INT1');
  end;
  // Highlight INT2 button?
  if BreakValue and $00000004 <> 0 then
  begin
    DrawBox(bINT2l, bINT2t, bINT2w, bINT2h, cModeButton, 3, True);
    DrawText(bINT2l, bINT2t, cModeText, [fsBold], 'INT2');
  end;
  // Highlight INT3 button?
  if BreakValue and $00000008 <> 0 then
  begin
    DrawBox(bINT3l, bINT3t, bINT3w, bINT3h, cModeButton, 3, True);
    DrawText(bINT3l, bINT3t, cModeText, [fsBold], 'INT3');
  end;
  // Highlight DEBUG button?
  if BreakValue and $00000010 <> 0 then
  begin
    DrawBox(bDEBUGl, bDEBUGt, bDEBUGw, bDEBUGh, cModeButton, 3, True);
    DrawText(bDEBUGl, bDEBUGt, cModeText, [fsBold], 'DEBUG');
  end;
  // Highlight INT1-Entry button?
  if BreakValue and $00000020 <> 0 then
  begin
    DrawBox(bINT1El, bINT1Et, bINT1Ew, bINT1Eh, cModeButton, 3, True);
    DrawArrowRight(bINT1El - 1 + q3, bINT1Et, cModeText);
    DrawText(bINT1El + 1, bINT1Et, cModeText, [fsBold], 'INT1');
  end;
  // Highlight INT2-Entry button?
  if BreakValue and $00000040 <> 0 then
  begin
    DrawBox(bINT2El, bINT2Et, bINT2Ew, bINT2Eh, cModeButton, 3, True);
    DrawArrowRight(bINT2El - 1 + q3, bINT2Et, cModeText);
    DrawText(bINT2El + 1, bINT2Et, cModeText, [fsBold], 'INT2');
  end;
  // Highlight INT3-Entry button?
  if BreakValue and $00000080 <> 0 then
  begin
    DrawBox(bINT3El, bINT3Et, bINT3Ew, bINT3Eh, cModeButton, 3, True);
    DrawArrowRight(bINT3El - 1 + q3, bINT3Et, cModeText);
    DrawText(bINT3El + 1, bINT3Et, cModeText, [fsBold], 'INT3');
  end;
  // Highlight INIT button?
  if BreakValue and $00000100 <> 0 then
  begin
    DrawBox(bINITl, bINITt, bINITw, bINITh, cModeButton, 3, True);
    DrawText(bINITl, bINITt, cModeText, [fsBold], 'INIT');
  end;
  // Highlight event button?
  if BreakValue and $00000200 <> 0 then
  begin
    DrawBox(bEVENTl, bEVENTt, bEVENTw, bEVENTh, cModeButton, 3, True);
    DrawText(bEVENTl - q1, bEVENTt, cModeText, [fsBold], EventName[BreakEvent]);
    DrawArrowUp(bEVENTl + 3, bEVENTt, cModeText);
  end
  else
    DrawText(bEVENTl - q1, bEVENTt, cModeTextDim, [fsBold], EventName[BreakEvent]);
  // Highlight address button?
  if BreakValue and $00000400 <> 0 then
  begin
    DrawBox(bADDRl, bADDRt, bADDRw, bADDRh, cModeButton, 3, True);
    DrawText(bADDRl, bADDRt, cModeText, [fsBold], IntToHex(BreakAddr and $FFFFF, 5));
  end
  else
    DrawText(bADDRl, bADDRt, cModeTextDim, [fsBold], IntToHex(BreakAddr and $FFFFF, 5));
  // Highlight BREAK button?
  if BreakValue and $000006FF = 0 then
  begin
    DrawBox(bBREAKl, bBREAKt, bBREAKw, bBREAKh, cModeButton, 3, True);
    DrawText(bBREAKl, bBREAKt, cModeText, [fsBold], 'BREAK');
  end;
  // Draw 'Stop' or 'Go' on Go button
  if RepeatMode then s := 'Stop' else s := ' Go';
  DrawText(bGOl + 3, bGOt, cCmdText, [fsBold], s);

  //  ---------------------------------
  //   Update any state-dependent hint
  //  ---------------------------------

  // Make hint if in XBYTE box
  if InXBYTE then
  begin
    i := DebuggerMsg[mBRKC] shr 16 and $1FF;
    if i and $0FC = $000 then
      Hint := '8-bit mode | LUT ' + IntToHex(i and $100, 3) + '..' + IntToHex(i and $100 or $0FF, 3) + ' uses full bytecode as offset'
    else if i and $00C = $000 then
      Hint := '8-bit mode | LUT ' + IntToHex(i and $100, 3) + '..' + IntToHex(i and $1F0 - 1, 3) +
              ' does 00..' + IntToHex(i and $F0 - 1, 2) + ' | LUT ' +
              IntToHex(i and $1F0, 3) + '..' + IntToHex(i and $1F0 + 15 - i shr 4 and $F, 3) +
              ' compresses ' + IntToHex(i shr 4 and $F, 1) + 'x..Fx'
    else if i and $01E = $004 then
      Hint := '7-bit mode | LUT ' + IntToHex(i and $180, 3) + '..' + IntToHex(i and $180 or $07F, 3) + ' uses bytecode.[6..0] as offset'
    else if i and $01E = $006 then
      Hint := '7-bit mode | LUT ' + IntToHex(i and $180, 3) + '..' + IntToHex(i and $180 or $07F, 3) + ' uses bytecode.[7..1] as offset'
    else if i and $01E = $014 then
      Hint := '6-bit mode | LUT ' + IntToHex(i and $1C0, 3) + '..' + IntToHex(i and $1C0 or $03F, 3) + ' uses bytecode.[5..0] as offset'
    else if i and $01E = $016 then
      Hint := '6-bit mode | LUT ' + IntToHex(i and $1C0, 3) + '..' + IntToHex(i and $1C0 or $03F, 3) + ' uses bytecode.[7..2] as offset'
    else if i and $00E = $008 then
      Hint := '5-bit mode | LUT ' + IntToHex(i and $1E0, 3) + '..' + IntToHex(i and $1E0 or $01F, 3) + ' uses bytecode.[4..0] as offset'
    else if i and $00E = $00A then
      Hint := '5-bit mode | LUT ' + IntToHex(i and $1E0, 3) + '..' + IntToHex(i and $1E0 or $01F, 3) + ' uses bytecode.[7..3] as offset'
    else if i and $00E = $00C then
      Hint := '4-bit mode | LUT ' + IntToHex(i and $1F0, 3) + '..' + IntToHex(i and $1F0 or $00F, 3) + ' uses bytecode.[3..0] as offset'
    else if i and $00E = $00E then
      Hint := '4-bit mode | LUT ' + IntToHex(i and $1F0, 3) + '..' + IntToHex(i and $1F0 or $00F, 3) + ' uses bytecode.[7..4] as offset';
    if i and $001 = $001 then
      Hint := Hint + ' | C,Z affected';
    Hint := 'XBYTE ' + Hint;
  end
  // Make hint if in CT box
  else if InCT then
  begin
    ct := DebuggerMsg[mCTH2];
    ct := ct shl 32 or DebuggerMsg[mCTL2] and $FFFFFFFF;
    Hint := 'Clock Ticks Since Reset';
    if P2.ClkFreq <> 0 then Hint := Hint + ' | ' +
      Format('%1.1n', [ct / P2.ClkFreq]) + ' seconds at ' +
      Format('%1.0n', [P2.ClkFreq * 1.0]) + ' Hz';
  end
  // Make hint if in SFR data
  else if inSFRData then
  begin
    i := (MouseY - SFRDataTop) div ChrHeight;
    j := CogImage[$1F0 + i] and $FFFFF;
    Hint := 'Special-Function Registers | Click to lock disassembly ';
    if (j < $400) and (i < 6) then      // treat IJMP3..IRET1 as code pointers
    begin
      if j < $200 then Hint := Hint + 'to R' else Hint := Hint + 'to L';
      Hint := Hint + '-' + IntToHex(j, 3);
    end
    else                                // treat PA..PTRB as hub data pointers
      Hint := Hint + 'and HUB address to ' + IntToHex(j, 5);
  end
  // Make hint if in stack data
  else if InStackData then
  begin
    i := (MouseX - StackDataLeft) div ChrWidth;
    j := DebuggerMsg[mSTK0 + i div 9] and $FFFFF;
    Hint := 'Stack Registers (top..bottom) | Click to lock disassembly ';
    if j >= $400 then Hint := Hint + 'and HUB address ';
    Hint := Hint + 'to ' + IntToHex(j, 5);
  end
  // Make hint if in pointer address, data, or chr
  else if InPtrAddr or InPtrData or InPtrChr then
  begin
    Hint := 'Pointers and Data | Click to lock disassembly and HUB address to ';
    j := (DebuggerMsg[mFPTR + (MouseY - PtrAddrTop) div ChrHeight] - PtrCenter) and $FFFFF;
    if InPtrAddr then
      i := PtrCenter
    else if InPtrData then
      i := (MouseX - PtrDataLeft) div ChrWidth div 3
    else
      i := (MouseX - PtrChrLeft) div ChrWidth;
    Hint := Hint + IntToHex((j + i) and $FFFFF, 5);
  end
  // Make hint if in pins data
  else if InPinData then
  begin
    i := (MouseX - PinDataLeft) div ChrWidth;
    j := $3F - (i div 9 shl 3 + i mod 9);
    Hint := 'Pin Registers | P' + IntToStr(j)                                  + ' | ' +
      'DIR ' + Chr(CogImage[$1FA + j shr 5] shr (j and $1F) and 1 + Byte('0')) + ' | ' +
      'OUT ' + Chr(CogImage[$1FC + j shr 5] shr (j and $1F) and 1 + Byte('0')) + ' | ' +
       'IN ' + Chr(CogImage[$1FE + j shr 5] shr (j and $1F) and 1 + Byte('0')) + ' | ' +
        'Z ' + IntToHex(SmartBuff[j], 8);
  end
  // Make hint if in smart pin watch box
  else if InSmartWatch then
  begin
    Hint := 'RQPIN-Delta Watch List | L-Click to reset list | R-Click to watch ';
    if WatchSmartAll then
      Hint := Hint + 'only pins with DIR set'
    else
      Hint := Hint + 'all pins';
  end
  // Make hint if in hub data or chr
  else if InHubData or InHubChr then
  begin
    if InHubData then
      i := (MouseY - HubDataTop) div ChrHeight shl 4 +
           (MouseX - HubDataLeft) div ChrWidth div 3
    else
      i := (MouseY - HubChrTop) div ChrHeight shl 4 +
           (MouseX - HubChrLeft) div ChrWidth;
    Hint := 'Hub Data | Mousewheel {+Ctrl/Shift} scrolls | Click to lock disassembly and HUB to ' +
             IntToHex((HubAddr + i) and $FFFFF, 5);
  end
  // Make hint if in Go button
  else if InButtonGo then
  begin
    if RepeatMode then
      Hint := 'Click or <ENTER> to stop executing through breaks'
    else
      Hint := 'L-Click or <SPACE> to execute to next break | R-Click or <ENTER> to execute through breaks';
  end;
  // Draw hint
  DrawText(HINTl, HINTt, cIndicator, [fsItalic], Hint);

  //  ------------
  //   Wrap it up
  //  ------------

  // Update display
  BitMapToCanvas(0);
  // Restore caption if showing window position
  if CaptionPos then
  begin
    Caption := CaptionStr;
    CaptionPos := False;
  end;
  // Restart breakpoint timeout timer
  BreakpointTimer.Enabled := False;
  BreakpointTimer.Interval := 250;
  BreakpointTimer.Enabled := True;
  // Process messages to keep things flowing
  Application.ProcessMessages;
end;


////////////////////////
//  Display Routines  //
////////////////////////

procedure TDebuggerForm.DrawBaseBitmap;
var
  i: integer;
begin
  // Clear working bitmap
  Bitmap[0].Canvas.Brush.Style := bsSolid;
  Bitmap[0].Canvas.Brush.Color := WinRGB(cBackground);
  Bitmap[0].Canvas.FillRect(Rect(0, 0, BitmapWidth, BitmapHeight));
  // Draw REG map box
  DrawBox(REGMAPl, REGMAPt, REGMAPw, REGMAPh, cBox, 3, False);
  DrawText(REGMAPl + 3, REGMAPt, cName, [fsBold, fsItalic], 'REG');
  // Draw LUT map box
  DrawBox(LUTMAPl, LUTMAPt, LUTMAPw, LUTMAPh, cBox, 3, False);
  DrawText(LUTMAPl + 3, LUTMAPt, cName, [fsBold, fsItalic], 'LUT');
  // Draw C flag box
  DrawBox(CFl, CFt, CFw, CFh, cBox, 3, False);
  DrawText(CFl, CFt, cName, [fsBold, fsItalic], 'C');
  // Draw Z flag box
  DrawBox(ZFl, ZFt, ZFw, ZFh, cBox, 3, False);
  DrawText(ZFl, ZFt, cName, [fsBold, fsItalic], 'Z');
  // Draw PC box
  DrawBox(PCl, PCt, PCw, PCh, cBox, 3, False);
  DrawText(PCl, PCt, cName, [fsBold, fsItalic], 'PC');
  // Draw SKIP/SKIPF box
  DrawBox(SKIPl, SKIPt, SKIPw, SKIPh, cBox, 3, False);
  DrawText(SKIPl, SKIPt, cName, [fsBold, fsItalic], 'SKIP');
  // Draw XBYTE box
  DrawBox(XBYTEl, XBYTEt, XBYTEw, XBYTEh, cBox, 3, False);
  DrawText(XBYTEl, XBYTEt, cName, [fsBold, fsItalic], 'XBYTE');
  DrawCheck(XBYTEl + 10, XBYTEt, cDataDim);
  // Draw CT box
  DrawBox(CTl, CTt, CTw, CTh, cBox3, 3, False);
  DrawText(CTl, CTt, cName, [fsBold, fsItalic], 'CT');
  // Draw execution tab and disassembly box
  DrawBox(EXECl, EXECt, EXECw, EXECh, cBox2, 3, False);
  DrawBox(DISl, DISt, DISw, DISh, cBox2, 3, False);
  // Draw register watch box
  DrawBox(WATCHl, WATCHt, WATCHw, WATCHh, cBox, 3, False);
  // Draw special function registers box
  DrawBox(SFRl, SFRt, SFRw, SFRh, cBox, 3, False);
  for i := 0 to 15 do
  begin
    DrawText(SFRl, SFRt + i shl 1, cData2, [fsBold], IntToHex($1F0 + i, 3));
    DrawText(SFRl + 4, SFRt + i shl 1, cName, [fsBold, fsItalic], RegName[i]);
  end;
  // Draw events box
  DrawBox(EVENTl, EVENTt, EVENTw, EVENTh, cBox, 3, False);
  for i := 0 to 15 do
    DrawText(EVENTl, EVENTt + i shl 1, cName, [fsBold, fsItalic], EventName[i]);
  // Draw STACK box
  DrawBox(STACKl, STACKt, STACKw, STACKh, cBox, 3, False);
  DrawText(STACKl, STACKt, cName, [fsBold, fsItalic], 'STACK');
  // Draw interrupts box
  DrawBox(INTl, INTt, INTw, INTh, cBox, 3, False);
  DrawText(INTl, INTt + 0 shl 1, cName, [fsBold, fsItalic], 'INT1');
  DrawText(INTl, INTt + 1 shl 1, cName, [fsBold, fsItalic], 'INT2');
  DrawText(INTl, INTt + 2 shl 1, cName, [fsBold, fsItalic], 'INT3');
  // Draw RFxx/WFxx, PTRA, PTRB box
  DrawBox(PTRl, PTRt, PTRw, PTRh, cBox, 3, False);
  DrawText(PTRl, PTRt + 0 shl 1, cName, [fsBold, fsItalic], ' Fxx');
  DrawText(PTRl, PTRt + 1 shl 1, cName, [fsBold, fsItalic], 'PTRA');
  DrawText(PTRl, PTRt + 2 shl 1, cName, [fsBold, fsItalic], 'PTRB');
  // Draw status box
  DrawBox(STATUSl, STATUSt, STATUSw, STATUSh, cBox, 3, False);
  DrawText(STATUSl + 1, STATUSt - 1 + q3, cDataDim, [fsBold, fsItalic], 'INIT');
  DrawText(STATUSl, STATUSt + 1 + q1, cDataDim, [fsBold, fsItalic], 'STALLI');
  DrawText(STATUSl - 1 + q3, STATUSt + 2 + q3, cDataDim, [fsBold, fsItalic], 'STR');
  DrawText(STATUSl + 3 + q1, STATUSt + 2 + q3, cDataDim, [fsBold, fsItalic], 'MOD');
  DrawText(STATUSl + 1, STATUSt + 4 + q1, cDataDim, [fsBold, fsItalic], 'LUTS');
  // Draw pins box
  DrawBox(PINl, PINt, PINw, PINh, cBox, 3, False);
  DrawText(PINl, PINt + 0 shl 1, cName, [fsBold, fsItalic], 'DIR');
  DrawText(PINl, PINt + 1 shl 1, cName, [fsBold, fsItalic], 'OUT');
  DrawText(PINl, PINt + 2 shl 1, cName, [fsBold, fsItalic], ' IN');
  // Draw smart pin watch box
  DrawBox(SMARTl, SMARTt, SMARTw, SMARTh, cBox, 3, False);
  // Draw hub tab and hub box
  DrawBox(HUBl, HUBt + HUBh - 1, 3, 4, cBox, 3, False);
  DrawBox(HUBl, HUBt, HUBw, HUBh, cBox, 3, False);
  DrawText(HUBl, HUBt + HUBh + 1, cName, [fsBold, fsItalic], 'HUB');
  // Draw hint box
  DrawBox(HINTl, HINTt, HINTw, HINTh, cBox2, 3, False);
  // Draw button box
  DrawBox(Bl, Bt, Bw, Bh, cBox, 3, False);
  // Draw mode buttons
  DrawBox(bBREAKl, bBREAKt, bBREAKw, bBREAKh, cModeButtonDim, 3, True);
  DrawText(bBREAKl, bBREAKt, cModeTextDim, [fsBold], 'BREAK');
  DrawBox(bADDRl, bADDRt, bADDRw, bADDRh, cModeButtonDim, 3, True);
  DrawBox(bINT3El, bINT3Et, bINT3Ew, bINT3Eh, cModeButtonDim, 3, True);
  DrawArrowRight(bINT3El - 1 + q3, bINT3Et, cModeTextDim);
  DrawText(bINT3El + 1, bINT3Et, cModeTextDim, [fsBold], 'INT3');
  DrawBox(bINT2El, bINT2Et, bINT2Ew, bINT2Eh, cModeButtonDim, 3, True);
  DrawArrowRight(bINT2El - 1 + q3, bINT2Et, cModeTextDim);
  DrawText(bINT2El + 1, bINT2Et, cModeTextDim, [fsBold], 'INT2');
  DrawBox(bINT1El, bINT1Et, bINT1Ew, bINT1Eh, cModeButtonDim, 3, True);
  DrawArrowRight(bINT1El - 1 + q3, bINT1Et, cModeTextDim);
  DrawText(bINT1El + 1, bINT1Et, cModeTextDim, [fsBold], 'INT1');
  DrawBox(bDEBUGl, bDEBUGt, bDEBUGw, bDEBUGh, cModeButtonDim, 3, True);
  DrawText(bDEBUGl, bDEBUGt, cModeTextDim, [fsBold], 'DEBUG');
  DrawBox(bINITl, bINITt, bINITw, bINITh, cModeButtonDim, 3, True);
  DrawText(bINITl, bINITt, cModeTextDim, [fsBold], 'INIT');
  DrawBox(bEVENTl, bEVENTt, bEVENTw, bEVENTh, cModeButtonDim, 3, True);
  DrawArrowUp(bEVENTl + 3, bEVENTt, cModeTextDim);
  DrawBox(bINT3l, bINT3t, bINT3w, bINT3h, cModeButtonDim, 3, True);
  DrawText(bINT3l, bINT3t, cModeTextDim, [fsBold], 'INT3');
  DrawBox(bINT2l, bINT2t, bINT2w, bINT2h, cModeButtonDim, 3, True);
  DrawText(bINT2l, bINT2t, cModeTextDim, [fsBold], 'INT2');
  DrawBox(bINT1l, bINT1t, bINT1w, bINT1h, cModeButtonDim, 3, True);
  DrawText(bINT1l, bINT1t, cModeTextDim, [fsBold], 'INT1');
  DrawBox(bMAINl, bMAINt, bMAINw, bMAINh, cModeButtonDim, 3, True);
  DrawText(bMAINl, bMAINt, cModeTextDim, [fsBold], 'MAIN');
  // Draw GO button
  DrawBox(bGOl, bGOt, bGOw, bGOh, cCmdButton, 6, False);
  // Copy to base bitmap
  Bitmap[2].Canvas.Draw(0, 0, Bitmap[0]);
  // Compute REG and LUT box and bitmap boundaries
  BoxBoundary(RegBoxLeft, RegBoxTop, RegBoxRight, RegBoxBottom, REGMAPl, REGMAPt, REGMAPw, REGMAPh, 1);
  BoxBoundary(RegMapLeft, RegMapTop, RegMapRight, RegMapBottom, REGMAPl + 1, REGMAPt + 3, 7, REGMAPh - 4, 1);
  BoxBoundary(LutBoxLeft, LutBoxTop, LutBoxRight, LutBoxBottom, LUTMAPl, LUTMAPt, REGMAPw, LUTMAPh, 1);
  BoxBoundary(LutMapLeft, LutMapTop, LutMapRight, LutMapBottom, LUTMAPl + 1, LUTMAPt + 3, 7, LUTMAPh - 4, 1);
  // Compute C/Z/PC/SKIP/XBYTE/CT box boundaries
  BoxBoundary(CFLeft, CFTop, CFRight, CFBottom, CFl, CFt, CFw, CFh, 1);
  BoxBoundary(ZFLeft, ZFTop, ZFRight, ZFBottom, ZFl, ZFt, ZFw, ZFh, 1);
  BoxBoundary(PCLeft, PCTop, PCRight, PCBottom, PCl, PCt, PCw, PCh, 1);
  BoxBoundary(SkipLeft, SkipTop, SkipRight, SkipBottom, SKIPl, SKIPt, SKIPw, SKIPh, 1);
  BoxBoundary(XBYTELeft, XBYTETop, XBYTERight, XBYTEBottom, XBYTEl, XBYTEt, XBYTEw, XBYTEh, 1);
  BoxBoundary(CTLeft, CTTop, CTRight, CTBottom, CTl, CTt, CTw, CTh, 1);
  // Compute disassembly line and tab box boundaries
  BoxBoundary(DisLeft, DisTop, DisRight, DisBottom, DISl, DISt, DISw, DISh, 0);
  BoxBoundary(ExecLeft, ExecTop, ExecRight, ExecBottom, EXECl, EXECt, EXECw, EXECh, 1);
  // Compute register watch box boundaries
  BoxBoundary(RegWatchLeft, RegWatchTop, RegWatchRight, RegWatchBottom, WATCHl, WATCHt, WATCHw, WATCHh, 1);
  // Compute SFR box and data boundaries
  BoxBoundary(SFRBoxLeft, SFRBoxTop, SFRBoxRight, SFRBoxBottom, SFRl, SFRt, SFRw, SFRh, 1);
  BoxBoundary(SFRDataLeft, SFRDataTop, SFRDataRight, SFRDataBottom, SFRl + 10, SFRt, 8, 10 shl 1, 0);
  // Compute event box and name boundaries
  BoxBoundary(EventsBoxLeft, EventsBoxTop, EventsBoxRight, EventsBoxBottom, EVENTl, EVENTt, EVENTw, EVENTh, 1);
  BoxBoundary(EventsLeft, EventsTop, EventsRight, EventsBottom, EVENTl, EVENTt + 1 shl 1, 3, 15 shl 1, 0);
  // Compute stack box and data boundaries
  BoxBoundary(StackBoxLeft, StackBoxTop, StackBoxRight, StackBoxBottom, STACKl, STACKt, STACKw, STACKh, 1);
  BoxBoundary(StackDataLeft, StackDataTop, StackDataRight, StackDataBottom, STACKl + 6, STACKt, 8 * 9 - 1, STACKh, 0);
  // Compute INT box boundaries
  BoxBoundary(IntBoxLeft, IntBoxTop, IntBoxRight, IntBoxBottom, INTl, INTt, INTw, INTh, 1);
  // Compute pointer box, address, and data boundaries
  BoxBoundary(PtrBoxLeft, PtrBoxTop, PtrBoxRight, PtrBoxBottom, PTRl, PTRt, PTRw, PTRh, 1);
  BoxBoundary(PtrAddrLeft, PtrAddrTop, PtrAddrRight, PtrAddrBottom, PTRl + 5, PTRt, 5, PTRh, 0);
  BoxBoundary(PtrDataLeft, PtrDataTop, PtrDataRight, PtrDataBottom, PTRl + 11, PTRt, PtrBytes * 3 - 1, PTRh, 0);
  BoxBoundary(PtrChrLeft, PtrChrTop, PtrChrRight, PtrChrBottom, PTRl + 11 + PtrBytes * 3 + 1, PTRt, PtrBytes, PTRh, 0);
  // Compute status box boundaries
  BoxBoundary(StatusLeft, StatusTop, StatusRight, StatusBottom, STATUSl, STATUSt, STATUSw, STATUSh, 1);
  // Compute pin box and data boundaries
  BoxBoundary(PinBoxLeft, PinBoxTop, PinBoxRight, PinBoxBottom, PINl, PINt, PINw, PINh, 1);
  BoxBoundary(PinDataLeft, PinDataTop, PinDataRight, PinDataBottom, PINl + 4, PINt, 8 * 9 - 1, PINh, 0);
  // Compute smart pin watch box boundaries
  BoxBoundary(SmartWatchLeft, SmartWatchTop, SmartWatchRight, SmartWatchBottom, SMARTl, SMARTt, SMARTw, SMARTh, 1);
  // Compute hub tab, box, address, data, character, and bitmap boundaries
  BoxBoundary(HubTabLeft, HubTabTop, HubTabRight, HubTabBottom, HUBl, HUBt + HUBh - 1, 3, 4, 1);
  BoxBoundary(HubBoxLeft, HubBoxTop, HubBoxRight, HubBoxBottom, HUBl, HUBt, HUBw, HUBh, 1);
  BoxBoundary(HubAddrLeft, HubAddrTop, HubAddrRight, HubAddrBottom, HUBl, HUBt, 5, HUBh, 0);
  BoxBoundary(HubDataLeft, HubDataTop, HubDataRight, HubDataBottom, HUBl + 6, HUBt, 16 * 3 - 1, HUBh, 0);
  BoxBoundary(HubChrLeft, HubChrTop, HubChrRight, HubChrBottom, HUBl + 6 + 16 * 3 + 1, HUBt, 16, HUBh, 0);
  BoxBoundary(HubMapLeft, HubMapTop, HubMapRight, HubMapBottom, HUBl + 74, HUBt + 1, 22, HUBh - 2, 1);
  // Compute button boundaries
  BoxBoundary(ButtonBoxLeft,  ButtonBoxTop,  ButtonBoxRight,  ButtonBoxBottom,  Bl,     Bt,     Bw,     Bh,     1);
  BoxBoundary(ButtonBreakLeft,ButtonBreakTop,ButtonBreakRight,ButtonBreakBottom,bBREAKl,bBREAKt,bBREAKw,bBREAKh,1);
  BoxBoundary(ButtonAddrLeft, ButtonAddrTop, ButtonAddrRight, ButtonAddrBottom, bADDRl, bADDRt, bADDRw, bADDRh, 1);
  BoxBoundary(ButtonInt3ELeft,ButtonInt3ETop,ButtonInt3ERight,ButtonInt3EBottom,bINT3El,bINT3Et,bINT3Ew,bINT3Eh,1);
  BoxBoundary(ButtonInt2ELeft,ButtonInt2ETop,ButtonInt2ERight,ButtonInt2EBottom,bINT2El,bINT2Et,bINT2Ew,bINT2Eh,1);
  BoxBoundary(ButtonInt1ELeft,ButtonInt1ETop,ButtonInt1ERight,ButtonInt1EBottom,bINT1El,bINT1Et,bINT1Ew,bINT1Eh,1);
  BoxBoundary(ButtonDebugLeft,ButtonDebugTop,ButtonDebugRight,ButtonDebugBottom,bDEBUGl,bDEBUGt,bDEBUGw,bDEBUGh,1);
  BoxBoundary(ButtonInitLeft, ButtonInitTop, ButtonInitRight, ButtonInitBottom, bINITl, bINITt, bINITw, bINITh, 1);
  BoxBoundary(ButtonEventLeft,ButtonEventTop,ButtonEventRight,ButtonEventBottom,bEVENTl,bEVENTt,bEVENTw,bEVENTh,1);
  BoxBoundary(ButtonInt3Left, ButtonInt3Top, ButtonInt3Right, ButtonInt3Bottom, bINT3l, bINT3t, bINT3w, bINT3h, 1);
  BoxBoundary(ButtonInt2Left, ButtonInt2Top, ButtonInt2Right, ButtonInt2Bottom, bINT2l, bINT2t, bINT2w, bINT2h, 1);
  BoxBoundary(ButtonInt1Left, ButtonInt1Top, ButtonInt1Right, ButtonInt1Bottom, bINT1l, bINT1t, bINT1w, bINT1h, 1);
  BoxBoundary(ButtonMainLeft, ButtonMainTop, ButtonMainRight, ButtonMainBottom, bMAINl, bMAINt, bMAINw, bMAINh, 1);
  BoxBoundary(ButtonGoLeft,   ButtonGoTop,   ButtonGoRight,   ButtonGoBottom,   bGOl,   bGOt,   bGOw,   bGOh,   1);
end;

procedure TDebuggerForm.DrawBox(left, top, width, height, color, rim: integer; small: boolean);
var
  wm, hd, t, h, c: integer;
begin
  if small then
  begin
    wm := 10;
    hd := -6;
  end
  else
  begin
    wm := 11;
    hd := 5;
  end;
  t := ChrWidth * rim shr 4;
  h := t shr 1;
  c := Smaller(color shr 16 and $FF * 3 shr 1, $FF) shl 16 or
       Smaller(color shr 08 and $FF * 3 shr 1, $FF) shl 08 or
       Smaller(color shr 00 and $FF * 3 shr 1, $FF) shl 00;
  SmoothShape(Frac(left, ChrWidth) + Frac(width, ChrWidth) shr 1, Frac(top, ChrHeight) shr 1 + Frac(height, ChrHeight) shr 2,
              Frac(width, ChrWidth) + ChrWidth * wm div 8 - h, Frac(height, ChrHeight) shr 1 + ChrHeight div hd - h,
              ChrHeight div 3 + 1, ChrHeight div 3 + 1, 0, color, 255);
  SmoothShape(Frac(left, ChrWidth) + Frac(width, ChrWidth) shr 1, Frac(top, ChrHeight) shr 1 + Frac(height, ChrHeight) shr 2,
              Frac(width, ChrWidth) + ChrWidth * wm div 8 + h, Frac(height, ChrHeight) shr 1 + ChrHeight div hd + h,
              ChrHeight div 3 + 1, ChrHeight div 3 + 1, t, c, 255);
end;

procedure TDebuggerForm.DrawText(left, top, color: integer; style: TFontStyles; str: string);
begin
  SetBkMode(Bitmap[0].Canvas.Handle, TRANSPARENT);
  Bitmap[0].Canvas.Font.Color := WinRGB(color);
  Bitmap[0].Canvas.Font.Style := style;
  Bitmap[0].Canvas.TextOut(Frac(left, ChrWidth), Frac(top, ChrHeight) shr 1, str);
end;

procedure TDebuggerForm.DrawCheck(left, top, color: integer);
var
  xl, xr, xm, yt, yb, ym, r : integer;
begin
  xl := Frac(left, ChrWidth) shl 8;
  xm := Frac(left + q2, ChrWidth) shl 8;
  xr := Frac(left + 1 + q2, ChrWidth) shl 8;
  ym := Frac(top, ChrHeight) shl (8-1) + ChrHeight shl (8-1);
  yt := ym - ChrHeight * 3 shl (8-4);
  yb := ym + ChrHeight * 3 shl (8-4);
  r := ChrWidth shl (8 - 2);
  SmoothLine(xl, ym, xm, yb, r, color, 255);
  SmoothLine(xm, yb, xr, yt, r, color, 255);
end;

procedure TDebuggerForm.DrawDelta(left, top, color: integer);
var
  xl, xr, xm, yt, yb, ym, r : integer;
begin
  xl := Frac(left, ChrWidth) shl 8;
  xr := xl + ChrWidth shl 8;
  xm := (xl + xr) shr 1;
  ym := Frac(top, ChrHeight) shl (8-1) + ChrHeight shl (8-1);
  yt := ym - ChrHeight * 7 shl (8-5);
  yb := ym + ChrHeight * 7 shl (8-5);
  r := ChrWidth shl (8 - 3);
  SmoothLine(xl, yb, xm, yt, r, color, 255);
  SmoothLine(xm, yt, xr, yb, r, color, 255);
  SmoothLine(xr, yb, xl, yb, r, color, 255);
end;

procedure TDebuggerForm.DrawArrowUp(left, top, color: integer);
var
  xl, xr, xm, yt, yb, ym, r : integer;
begin
  xm := Frac(left + q2, ChrWidth) shl 8;
  xl := xm - ChrWidth * 7 shl (8-4);
  xr := xm + ChrWidth * 7 shl (8-4);
  ym := Frac(top, ChrHeight) shl (8-1) + ChrHeight shl (8-1);
  yt := ym - ChrHeight * 7 shl (8-5);
  yb := ym + ChrHeight * 7 shl (8-5);
  r := ChrWidth shl (8 - 3);
  SmoothLine(xm, yt, xm, yb, r, color, 255);
  SmoothLine(xm, yt, xl, ym, r, color, 255);
  SmoothLine(xm, yt, xr, ym, r, color, 255);
end;

procedure TDebuggerForm.DrawArrowRight(left, top, color: integer);
var
  xl, xr, xm, yt, yb, ym, r : integer;
begin
  xl := Frac(left, ChrWidth) shl 8;
  xr := xl + ChrWidth shl 8;
  xm := (xl + xr) shr 1;
  ym := Frac(top, ChrHeight) shl (8-1) + ChrHeight shl (8-1);
  yt := ym - ChrHeight * 3 shl (8-4);
  yb := ym + ChrHeight * 3 shl (8-4);
  r := ChrWidth shl (8 - 3);
  SmoothLine(xr, ym, xl, ym, r, color, 255);
  SmoothLine(xr, ym, xm, yt, r, color, 255);
  SmoothLine(xr, ym, xm, yb, r, color, 255);
end;

procedure TDebuggerForm.DrawRegBin(left, top, value, color: integer);
var
  i: integer;
  s: string;
begin
  s := '';
  for i := 31 downto 0 do
  begin
    s := s + Chr(value shr i and 1 + Byte('0'));
    if (i and 7 = 0) and (i <> 0) then s := s + ' ';
  end;
  DrawText(left, top, color, [], s);
end;

procedure TDebuggerForm.DrawPtrBytes(left, top, address: integer; buff:PByteArray);
var
  i: integer;
  b,c: byte;
  color: integer;
  style: TFontStyles;
begin
  // Draw address
  DrawText(left + 5, top, cData, [], IntToHex(address and $FFFFF, 5));
  // Draw bytes and characters
  for i := 0 to PtrBytes - 1 do
  begin
    b := buff[i];
    if (b >= $20) and (b <= $7E) then c := b else c := Byte('.');
    color := cData2;
    style := [];
    if i = PtrCenter then
    begin
      // Draw boxes around center byte and ascii
      SmoothShape((left + 11 + i * 3 + 1) * ChrWidth, (top * ChrHeight) shr 1 + ChrHeight shr 1,
                  ChrWidth * 3, ChrHeight * 3 shr 2,
                  ChrHeight shr 2, ChrHeight shr 2,
                  0, cData2, 255);
      SmoothShape((left + 11 + PtrBytes * 3 + 1 + i) * ChrWidth + (ChrWidth - 1) shr 1, (top * ChrHeight) shr 1 + ChrHeight shr 1,
                  ChrWidth * 3 shr 1, ChrHeight * 3 shr 2,
                  ChrHeight shr 2, ChrHeight shr 2,
                  0, cData2, 255);
      color := cBox;
      style := [fsBold];
    end;
    DrawText(left + 11 + i * 3, top, color, style, IntToHex(b, 2));
    DrawText(left + 11 + PtrBytes * 3 + 1 + i, top, color, style, Chr(c));
  end;
end;

procedure TDebuggerForm.DrawInt(left, top, int: integer);
var
  i: integer;
  s: string;
begin
  i := DebuggerMsg[mBRKCZ] shr (int shl 2 + 4) and $F;
  if i = 0 then
    DrawText(left + 5, top, cData2, [fsBold], 'off')
  else
  begin
    DrawText(left + 5, top, cData, [fsBold], EventName[i]);
    i := DebuggerMsg[mBRKCZ] shr (int shl 1) and 3;
    if i = 3 then s := 'busy' else if i = 2 then s := 'wait' else s := 'idle';
    DrawText(left + 9, top, cData2, [fsBold], s);
  end;
end;

procedure TDebuggerForm.BlendPixel(var p:PByte; a, b: integer; alpha, shade: byte);
begin
  p^ := Smaller((a shr 00 and $FF * not alpha + b shr 00 and $FF * alpha + $FF) shr 8 + shade, $FF); Inc(p);
  p^ := Smaller((a shr 08 and $FF * not alpha + b shr 08 and $FF * alpha + $FF) shr 8 + shade, $FF); Inc(p);
  p^ := Smaller((a shr 16 and $FF * not alpha + b shr 16 and $FF * alpha + $FF) shr 8 + shade, $FF); Inc(p);
end;

procedure TDebuggerForm.BitmapToCanvas(Level: integer);
begin
  if Level = 0 then Bitmap[1].Canvas.Draw(0, 0, Bitmap[0]);
  Canvas.Draw(0, 0, Bitmap[1]);
end;


/////////////////////
//  Miscellaneous  //
/////////////////////

procedure TDebuggerForm.ResetRegWatch;
var
  i: integer;
begin
  for i := 0 to RegWatchSize - 1 do WatchReg[i] := $FFFF;
  for i := 0 to RegWatchListSize - 1 do WatchRegList[i] := $FFFF0000;
end;

procedure TDebuggerForm.ResetSmartWatch;
var
  i: integer;
begin
  for i := 0 to SmartWatchSize - 1 do WatchSmart[i] := $FFFF;
  for i := 0 to SmartWatchListSize - 1 do WatchSmartList[i] := $FFFF0000;
end;

procedure TDebuggerForm.BoxBoundary(var Left, Top, Right, Bottom: integer; L, T, W, H, B: integer);
begin
  Left := Frac(L, ChrWidth) - B * ChrWidth * 7 div 8;           // B=0 for text or B=1 for box
  Top := Frac(T, ChrHeight) shr 1 - B * ChrHeight div 7;
  Right := Frac(L + W, ChrWidth) + B * ChrWidth * 7 div 8;
  Bottom := Frac(T + H, ChrHeight) shr 1 + B * ChrHeight div 7;
end;

function TDebuggerForm.Frac(x, y: integer): integer;
begin
  Result := (x and $7F shl 2 + x shr 7) * y shr 2;
end;

function TDebuggerForm.MouseWithin(Left, Top, Right, Bottom, Cadence: integer; HintStr: string): boolean;
begin
  Result := (MouseX >= Left) and
            (MouseX < Right) and
            (MouseY >= Top)  and
            (MouseY < Bottom);
  if Cadence <> 0 then
    Result := Result and ((MouseX - Left) div ChrWidth mod Cadence <> Cadence - 1);
  if Result then
    Hint := HintStr;
end;

function TDebuggerForm.WinRGB(c: integer): integer;
begin
  Result := (c and $FF0000 shr 16) or (c and $00FF00) or (c and $0000FF shl 16);
end;


//////////////////////////////////
//  Anti-Aliased Shape Drawing  //
//////////////////////////////////

procedure TDebuggerForm.SmoothShape(xc, yc, xs, ys, xro, yro, thick, color: integer; opacity: byte);
var
  xf, yf, xri, yri, x, y, xl, xr, yb, yt: integer;
  rectangle, solid: boolean;
  yo_bias, yi_bias, xo_bias, xi_bias: extended;
  xo_lut: array [0..SmoothFillMax shr 1 - 1] of integer;
  yo_lut: array [0..SmoothFillMax shr 1 - 1] of integer;
  xi_lut: array [0..SmoothFillMax shr 1 - 1] of integer;
  yi_lut: array [0..SmoothFillMax shr 1 - 1] of integer;
  lft, rgt, top, bot: integer;
  xo, yo, xi, yi: integer;
  xo_above, xo_below, yo_above, yo_below: boolean;
  xi_above, xi_below, yi_above, yi_below: boolean;
  xopa, yopa, opa: byte;
begin
  // ignore bad input
  if (xc < -SmoothFillMax) or (xc > BitmapWidth + SmoothFillMax) or
     (yc < -SmoothFillMax) or (yc > BitmapHeight + SmoothFillMax) or
     (xs < 1) or (xs > SmoothFillMax) or
     (ys < 1) or (ys > SmoothFillMax) or
     (xro < 0) or (xro > SmoothFillMax shr 1) or
     (yro < 0) or (yro > SmoothFillMax shr 1) or
     (thick < 0) then Exit;
  // make fill buffer with color
  SmoothFillSetup(xs, color);
  // get solid/rectangle
  solid := (thick = 0) or (thick shl 1 >= xs) or (thick shl 1 >= ys);
  rectangle := (xro = 0) or (yro = 0);
  // rectangle?
  if rectangle then
  begin
    xl := xc - xs shr 1;
    xr := xc + (xs - xs shr 1);
    yb := yc + (ys - ys shr 1);
    yt := yc - ys shr 1;
    if solid then
      SmoothRect(xl, yt, xs, ys, opacity)    // solid
    else
    begin                                    // frame
      yf := ys - thick shl 1;
      SmoothRect(xl,         yt,         xs,    thick, opacity);    // top
      SmoothRect(xl,         yb - thick, xs,    thick, opacity);    // bottom
      SmoothRect(xl,         yt + thick, thick, yf,    opacity);    // left
      SmoothRect(xr - thick, yt + thick, thick, yf,    opacity);    // right
    end;
    Exit;
  end;
  // clamp xro/yro
  if (xro shl 1 > xs) then xro := xs shr 1;
  if (yro shl 1 > ys) then yro := ys shr 1;
  // get xri/yri
  xri := xro - thick;
  yri := yro - thick;
  if solid or (xri <= 0) or (yri <= 0) then
  begin
    solid := True;
    xri := 0;
    yri := 0;
  end;
  // get flats
  xf := xs - xro shl 1;
  yf := ys - yro shl 1;
  // get corners
  xl := xc - xf shr 1;
  xr := xc + (xf - xf shr 1);
  yb := yc + (yf - yf shr 1);
  yt := yc - yf shr 1;
  // draw any solid or frame sections
  if solid then
  begin    // solid
    SmoothRect(xl,       yt - yro, xf, yro, opacity);    // top
    SmoothRect(xl,       yb,       xf, yro, opacity);    // bottom
    SmoothRect(xl - xro, yt,       xs, yf,  opacity);    // middle
  end
  else
  begin    // frame
    SmoothRect(xl,       yt - yro, xf,        yro - yri, opacity);    // top
    SmoothRect(xl,       yb + yri, xf,        yro - yri, opacity);    // bottom
    SmoothRect(xl - xro, yt,       xro - xri, yf,        opacity);    // left
    SmoothRect(xr + xri, yt,       xro - xri, yf,        opacity);    // right
  end;
  // set biases for optimal anti-aliasing
  yo_bias :=     1 / (xro + 1);    // for small radii, 1/(r+1) improves shading
  yi_bias := 1 - 1 / (xri + 1);    // inner biases approach 1
  xo_bias :=     1 / (yro + 1);    // outer biases approach 0
  xi_bias := 1 - 1 / (yri + 1);
  // for each x, get outer and inner y values * 256
  for x := 0 to xro - 1 do
  begin
    yo_lut[x] := Trunc(Sin(ArcCos((x + yo_bias) / xro)) * yro * 256);
    if x >= xri then yi_lut[x] := 0 else
    yi_lut[x] := Trunc(Sin(ArcCos((x + yi_bias) / xri)) * yri * 256);
  end;
  // for each y, get outer and inner x values * 256
  for y := 0 to yro - 1 do
  begin
    xo_lut[y] := Trunc(Sin(ArcCos((y + xo_bias) / yro)) * xro * 256);
    if y >= yri then xi_lut[y] := 0 else
    xi_lut[y] := Trunc(Sin(ArcCos((y + xi_bias) / yri)) * xri * 256);
  end;
  // draw pixels
  lft := xl - 1;
  rgt := xr;
  for y := 0 to yro - 1 do
  begin
    top := yt - 1 - y;
    bot := yb + y;
    xo := xo_lut[y];    // lookup outer x
    xi := xi_lut[y];    // lookup inner x
    for x := xo shr 8 downto 0 do
    begin
      yo := yo_lut[x];    // lookup outer y
      yi := yi_lut[x];    // lookup inner y

      xo_above := xo shr 8 >= x + 1;    // above or below outer x?
      xo_below := xo shr 8 < x;

      xi_above := xi shr 8 >= x + 1;    // above or below inner x?
      xi_below := xi shr 8 < x;

      yo_above := yo shr 8 >= y + 1;    // above or below outer y?
      yo_below := yo shr 8 < y;

      yi_above := yi shr 8 >= y + 1;    // above or below inner y?
      yi_below := yi shr 8 < y;

      if xo_above and xi_below then xopa := $FF    // determine x opacity
      else if not xo_above and not xo_below then xopa := xo and $FF
      else if not xi_above and not xi_below then xopa := xi and $FF xor $FF
      else Break;       // x within inner radius, next y

      if yo_above and yi_below then yopa := $FF    // determine y opacity
      else if not yo_above and not yo_below then yopa := yo and $FF
      else if not yi_above and not yi_below then yopa := yi and $FF xor $FF
      else Continue;    // y beyond outer radius, next x

      opa := (xopa * yopa + $FF) shr 8;    // get pixel opacity

      if (opa = $FF) and solid then        // if opaque and solid, fill remainder
      begin
        SmoothFill(rgt,     top, x, opacity);    // line upper right
        SmoothFill(lft - x, top, x, opacity);    // line upper left
        SmoothFill(rgt,     bot, x, opacity);    // line lower right
        SmoothFill(lft - x, bot, x, opacity);    // line lower left
        Break;                                   // x done, next y
      end;

      SmoothPlot(rgt + x, top, (opa * opacity + $FF) shr 8);    // plot upper right
      SmoothPlot(lft - x, top, (opa * opacity + $FF) shr 8);    // plot upper left
      SmoothPlot(rgt + x, bot, (opa * opacity + $FF) shr 8);    // plot lower right
      SmoothPlot(lft - x, bot, (opa * opacity + $FF) shr 8);    // plot lower left
    end;
  end;
end;

procedure TDebuggerForm.SmoothFillSetup(size, color: integer);
var
  i: integer;
  b0, b1, b2: byte;
  p: PByte;
begin
  // already set up?
  if (SmoothFillSize = size) and (SmoothFillColor = color) then Exit;
  SmoothFillSize := size;
  SmoothFillColor := color;
  // fill buffer with pixels
  b0 := color shr 00;
  b1 := color shr 08;
  b2 := color shr 16;
  p := @SmoothFillBuff;
  for i := 0 to SmoothFillSize - 1 do
  begin
    p^ := b0; Inc(p);
    p^ := b1; Inc(p);
    p^ := b2; Inc(p);
  end;
end;

procedure TDebuggerForm.SmoothRect(x, y, xs, ys: integer; opacity: byte);
var
  i: integer;
begin
  if (xs = 0) or (ys = 0) then Exit;
  for i := y to y + ys - 1 do
    SmoothFill(x, i, xs - 1, opacity);
end;

procedure TDebuggerForm.SmoothFill(x, y, count: integer; opacity: byte);
var
  src, dst: PByte;
  i: integer;
begin
  // make sure y within bitmap
  if (y < 0) or (y >= BitmapHeight) then Exit;
  // reduce count if x < 0 or x + count >= width
  if (x < 0) then
  begin
    Inc(count, x);
    if count < 0 then Exit;
    x := 0;
  end;
  if x >= BitmapWidth then Exit;
  if x + count >= BitmapWidth then count := BitmapWidth - 1 - x;
  // fill pixels in line
  if opacity = $FF then         // fast fill?
    Move(SmoothFillBuff, PByteArray(BitmapLine[y])[x * 3], (count + 1) * 3)
  else if opacity <> 0 then     // blended fill?
  begin
    src := @SmoothFillBuff;
    dst := @PByteArray(BitmapLine[y])[x * 3];
    for i := 1 to (count + 1) * 3 do
    begin
      dst^ := (dst^ * not opacity + src^ * opacity + $FF) shr 8;
      Inc(dst);
      Inc(src);
    end;
  end;
end;

procedure TDebuggerForm.SmoothPlot(x, y: integer; opacity: byte);
var
  p: PByte;
begin
  if opacity = 0 then Exit;
  if (x < 0) or (x >= BitmapWidth) or
     (y < 0) or (y >= BitmapHeight) then Exit;
  p := @PByteArray(BitmapLine[y])[x * 3];
  if opacity = $FF then
  begin
    p^ := SmoothFillColor shr 00; Inc(p);
    p^ := SmoothFillColor shr 08; Inc(p);
    p^ := SmoothFillColor shr 16;
  end
  else
  begin
    p^ := ((p^ * not opacity + (SmoothFillColor shr 00 and $FF) * opacity) + $FF) shr 8; Inc(p);
    p^ := ((p^ * not opacity + (SmoothFillColor shr 08 and $FF) * opacity) + $FF) shr 8; Inc(p);
    p^ := ((p^ * not opacity + (SmoothFillColor shr 16 and $FF) * opacity) + $FF) shr 8;
  end;
end;


/////////////////////////////////
//  Anti-Aliased Line Drawing  //
//    x/y/radius in 256th's    //
/////////////////////////////////

procedure TDebuggerForm.SmoothDot(x, y, radius, color: integer; opacity: byte);
begin
  SmoothLine(x, y, x, y, radius, color, opacity);
end;

procedure TDebuggerForm.SmoothLine(x1, y1, x2, y2, radius, color: integer; opacity: byte);
const
  maxr = 128;
  limr = maxr + 1;
var
  radius1, radius2, span, dx, dy,
  x1f, y1f, x2f, y2f, xleft, xright,
  b, ym, slice, lt, lb, rt, rb, x, y,
  xp, yp, yl, yr, yt, yb: integer;
  xo, yo: byte;
  th, m: extended;
  swapxy: boolean;
  y1_lut1: array[-limr..limr] of integer;
  y2_lut1: array[-limr..limr] of integer;
  x1_lut2: array[-limr..limr] of integer;
  y1_lut2: array[-limr..limr] of integer;
  x2_lut2: array[-limr..limr] of integer;
  y2_lut2: array[-limr..limr] of integer;
begin
  // center 8-bit-fractional coordinates within pixels
  Inc(x1, $80);
  Inc(x2, $80);
  Inc(y1, $80);
  Inc(y2, $80);
  // clip line and exit if outside bitmap
  if not SmoothClip(x1, y1, x2, y2) then Exit;
  // get radius values and span
  radius1 := Min(radius, maxr shl 8);
  radius2 := radius1 + $80;
  span := radius1 shr 8 + 1;
  // get x-dominance
  swapxy := Abs(y2 - y1) > Abs(x2 - x1);
  if swapxy then
  begin
    dx := x1; dy := x2;
    x1 := y1; x2 := y2;
    y1 := dx; y2 := dy;
  end;
  // get x1 on left
  if x1 > x2 then
  begin
    dx := x1; dy := y1;
    x1 := x2; y1 := y2;
    x2 := dx; y2 := dy;
  end;
  // make lookup tables
  x1f := x1 and $FF - $80;
  y1f := y1 and $FF - $80;
  x2f := x2 and $FF - $80;
  y2f := y2 and $FF - $80;
  for xp := -span to span do
  begin
    // 1D-slice lookups, actual radius
    y1_lut1[xp] := Round(Sin(ArcCos(Max(Min(xp shl 8 + x1f, radius1), -radius1) / radius1)) * radius1);
    y2_lut1[xp] := Round(Sin(ArcCos(Max(Min(xp shl 8 + x2f, radius1), -radius1) / radius1)) * radius1);
    // 2D-slice lookups, radius+$80 reduces to actual radius after 2D opacity modulation
    x1_lut2[xp] := Round(Sin(ArcCos(Max(Min(xp shl 8 + y1f, radius1), -radius1) / radius2)) * radius2);
    y1_lut2[xp] := Round(Sin(ArcCos(Max(Min(xp shl 8 + x1f, radius1), -radius1) / radius2)) * radius2);
    x2_lut2[xp] := Round(Sin(ArcCos(Max(Min(xp shl 8 + y2f, radius1), -radius1) / radius2)) * radius2);
    y2_lut2[xp] := Round(Sin(ArcCos(Max(Min(xp shl 8 + x2f, radius1), -radius1) / radius2)) * radius2);
  end;
  // register x1 and x2 to pixel centers
  xleft := (x1 - radius1) and $FFFFFF00 + $80;
  xright := (x2 + radius1) and $FFFFFF00 + $80;
  // get angle metrics
  th := ArcTan2(y2 - y1, x2 - x1);           // get angle
  m := Tan(th);                              // get slope
  b := y1 - Round(m * x1);                   // get 8-bit-fractional y-intercept
  ym := Round(((xleft * m) + b) * $100);     // get initial y with 16-bit fraction at x1
  dy := Round(m * $10000);                   // get 16-bit-fractional delta-y
  slice := Round(radius1 / Cos(th));         // get slice size
  // get circle departure/arrival points
  dx := Round(Cos(th + Pi/2) * radius1);
  lt := x1 - dx;
  lb := x1 + dx;
  rt := x2 - dx;
  rb := x2 + dx;
  // draw complete line with left and right endpoint circles
  x := xleft;
  while x <= xright do
  begin
    // if in left circle before line departure, draw 2D slice
    if (x <= lt) and (x <= lb) then
    begin
      xp := x1 div $100 - x div $100;
      for yp := -span to span do
      begin
        if      xp < 0 then xo := Max(Min(x1_lut2[yp] + (xp shl 8 + x1f), $FF), $00)
        else if xp > 0 then xo := Max(Min(x1_lut2[yp] - (xp shl 8 + x1f), $FF), $00)
        else                xo := Max(Min(x1_lut2[yp]                   , $FF), $00);
        if      yp < 0 then yo := Max(Min(y1_lut2[xp] + (yp shl 8 + y1f), $FF), $00)
        else if yp > 0 then yo := Max(Min(y1_lut2[xp] - (yp shl 8 + y1f), $FF), $00)
        else                yo := Max(Min(y1_lut2[xp]                   , $FF), $00);
        SmoothPixel(swapxy, x shr 8, y1 shr 8 - yp, color, (xo * yo + $FF) shr 8, opacity);
      end;
    end
    // if in right circle after line arrival, draw 2D slice
    else
    if (x >= rt) and (x >= rb) then
    begin
      xp := x2 div $100 - x div $100;
      for yp := -span to span do
      begin
        if      xp < 0 then xo := Max(Min(x2_lut2[yp] + (xp shl 8 + x2f), $FF), $00)
        else if xp > 0 then xo := Max(Min(x2_lut2[yp] - (xp shl 8 + x2f), $FF), $00)
        else                xo := Max(Min(x2_lut2[yp]                   , $FF), $00);
        if      yp < 0 then yo := Max(Min(y2_lut2[xp] + (yp shl 8 + y2f), $FF), $00)
        else if yp > 0 then yo := Max(Min(y2_lut2[xp] - (yp shl 8 + y2f), $FF), $00)
        else                yo := Max(Min(y2_lut2[xp]                   , $FF), $00);
        SmoothPixel(swapxy, x shr 8, y2 shr 8 - yp, color, (xo * yo + $FF) shr 8, opacity)
      end;
    end
    // between circles, draw 1D slice of line
    else
    begin
      // get slice metrics
      yl := y1_lut1[x1 div $100 - x div $100];
      yr := y2_lut1[x2 div $100 - x div $100];
      y := ym div $100;
      // determine top
      if x <= lt then yt := yl - (y1 - y)
      else if x >= rt then yt := yr - (y2 - y)
      else yt := slice;
      // determine bottom
      if x <= lb then yb := yl + (y1 - y)
      else if x >= rb then yb := yr + (y2 - y)
      else yb := slice;
      // draw bottom-to-top slice at x
      SmoothSlice(swapxy, x div $100, y - yt, y + yb, color, opacity);
    end;
  // step x and y
  Inc(x, $100);
  Inc(ym, dy);
  end;
end;

procedure TDebuggerForm.SmoothSlice(swapxy: boolean; x, yb, yt, color: integer; opacity: byte);
var
  yn: integer;
  opa: byte;
begin
  while yb < yt do
  begin
    yn := (yb or $FF) + 1;
    if yt < yn then
      opa := yt - yb
    else
      opa := not yb;
    SmoothPixel(swapxy, x, yb shr 8, color, opa, opacity);
    yb := yn;
  end;
end;

procedure TDebuggerForm.SmoothPixel(swapxy: boolean; x, y, color: integer; opacity, opacity2: byte);
var
  i: integer;
  p: PByte;
begin
  opacity := (opacity * opacity2 + $FF) shr 8;
  if opacity = $00 then Exit;
  if swapxy then
  begin
    i := x; x := y; y := i;
  end;
  if (x < 0) or (x >= BitmapWidth) or
     (y < 0) or (y >= BitmapHeight) then Exit;
  p := @PByteArray(BitmapLine[y])[x * 3];
  if opacity = $FF then
  begin
    p^ := color shr 00; Inc(p);
    p^ := color shr 08; Inc(p);
    p^ := color shr 16;
  end
  else
  begin
    p^ := ((p^ * not opacity + (color shr 00 and $FF) * opacity) + $FF) shr 8; Inc(p);
    p^ := ((p^ * not opacity + (color shr 08 and $FF) * opacity) + $FF) shr 8; Inc(p);
    p^ := ((p^ * not opacity + (color shr 16 and $FF) * opacity) + $FF) shr 8;
  end;
end;

function TDebuggerForm.SmoothClip(var x1, y1, x2, y2: integer): boolean;
var
  lft, rgt, bot, top, out1, out2, outx: integer;
  fx1, fy1, fx2, fy2, fx, fy: double;
begin
  // Cohen-Sutherland clipping algorithm
  lft := 0;
  rgt := BitmapWidth shl 8 - 1;
  bot := 0;
  top := BitmapHeight shl 8 - 1;
  // get clipping boundaries
  out1 := SmoothClipTest(x1, y1, lft, rgt, bot, top);
  out2 := SmoothClipTest(x2, y2, lft, rgt, bot, top);
  // resolve each clipping case
  fx1 := x1;
  fy1 := y1;
  fx2 := x2;
  fy2 := y2;
  repeat
    // if points are within bitmap, exit
    if (out1 or out2) = 0 then
    begin
      Result := True;
      Break;
    end;
    // if points are in an outer zone, exit
    if (out1 and out2) <> 0 then
    begin
      Result := False;
      Break;
    end;
    // pick point to clip
    if out1 <> 0 then
      outx := out1
    else
      outx := out2;
    // get edge intersection
    if (outx and 8) <> 0 then
    begin
      fx := (fx2 - fx1) * (top - fy1) / (fy2 - fy1) + fx1;
      fy := top;
    end
    else
    if (outx and 4) <> 0 then
    begin
      fx := (fx2 - fx1) * (bot - fy1) / (fy2 - fy1) + fx1;
      fy := bot;
    end
    else
    if (outx and 2) <> 0 then
    begin
      fy := (fy2 - fy1) * (rgt - fx1) / (fx2 - fx1) + fy1;
      fx := rgt;
    end
    else
    if (outx and 1) <> 0 then
    begin
      fy := (fy2 - fy1) * (lft - fx1) / (fx2 - fx1) + fy1;
      fx := lft;
    end;
    // update clipped point
    if outx = out1 then
    begin
      fx1 := fx;
      fy1 := fy;
      x1 := Trunc(fx1);
      y1 := Trunc(fy1);
      out1 := SmoothClipTest(x1, y1, lft, rgt, bot, top);
    end
    else
    begin
      fx2 := fx;
      fy2 := fy;
      x2 := Trunc(fx2);
      y2 := Trunc(fy2);
      out2 := SmoothClipTest(x2, y2, lft, rgt, bot, top);
    end;
  until False;
end;

function TDebuggerForm.SmoothClipTest(x, y, lft, rgt, bot, top: integer): integer;
begin
  Result := 0;
  if      x < lft then Result := Result or 1
  else if x > rgt then Result := Result or 2;
  if      y < bot then Result := Result or 4
  else if y > top then Result := Result or 8;
end;

end.

