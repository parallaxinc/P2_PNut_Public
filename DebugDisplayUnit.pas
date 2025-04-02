{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J-,K-,L+,M-,N+,O+,P+,Q-,R-,S-,T-,U-,V+,W-,X+,Y+,Z1}
{$MINSTACKSIZE $00400000}
{$MAXSTACKSIZE $00400000}
{$IMAGEBASE $00400000}
{$APPTYPE GUI}
unit DebugDisplayUnit;

interface

uses
  Windows, Messages, SysUtils, ExtCtrls, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Math, SerialUnit;

const
  ele_end               = 0;    // elements
  ele_dis               = 1;
  ele_nam               = 2;
  ele_key               = 3;
  ele_num               = 4;
  ele_str               = 5;

  dis_logic             = 0;    // displays
  dis_scope             = 1;
  dis_scope_xy          = 2;
  dis_fft               = 3;
  dis_spectro           = 4;
  dis_plot              = 5;
  dis_term              = 6;
  dis_bitmap            = 7;
  dis_midi              = 8;

  key_black             = 0;    // color group
  key_white             = 1;                                                         
  key_orange            = 2;
  key_blue              = 3;
  key_green             = 4;
  key_cyan              = 5;
  key_red               = 6;
  key_magenta           = 7;
  key_yellow            = 8;
  key_gray              = 9;

  key_lut1              = 10;   // color-mode group
  key_lut2              = 11;
  key_lut4              = 12;
  key_lut8              = 13;
  key_luma8             = 14;
  key_luma8w            = 15;
  key_luma8x            = 16;
  key_hsv8              = 17;
  key_hsv8w             = 18;
  key_hsv8x             = 19;
  key_rgbi8             = 20;
  key_rgbi8w            = 21;
  key_rgbi8x            = 22;
  key_rgb8              = 23;
  key_hsv16             = 24;
  key_hsv16w            = 25;
  key_hsv16x            = 26;
  key_rgb16             = 27;
  key_rgb24             = 28;

  key_longs_1bit        = 29;   // packed-data group
  key_longs_2bit        = 30;
  key_longs_4bit        = 31;
  key_longs_8bit        = 32;
  key_longs_16bit       = 33;
  key_words_1bit        = 34;
  key_words_2bit        = 35;
  key_words_4bit        = 36;
  key_words_8bit        = 37;
  key_bytes_1bit        = 38;
  key_bytes_2bit        = 39;
  key_bytes_4bit        = 40;

  key_alt               = 41;   // keywords
  key_auto              = 42;
  key_backcolor         = 43;
  key_box               = 44;
  key_cartesian         = 45;
  key_channel           = 46;
  key_circle            = 47;
  key_clear             = 48;
  key_close             = 49;
  key_color             = 50;
  key_crop              = 51;
  key_depth             = 52;
  key_dot               = 53;
  key_dotsize           = 54;
  key_hidexy            = 55;
  key_holdoff           = 56;
  key_layer             = 57;
  key_line              = 58;
  key_linesize          = 59;
  key_logscale          = 60;
  key_lutcolors         = 61;
  key_mag               = 62;
  key_obox              = 63;
  key_opacity           = 64;
  key_origin            = 65;
  key_oval              = 66;
  key_pc_key            = 67;
  key_pc_mouse          = 68;
  key_polar             = 69;
  key_pos               = 70;
  key_precise           = 71;
  key_range             = 72;
  key_rate              = 73;
  key_samples           = 74;
  key_save              = 75;
  key_scroll            = 76;
  key_set               = 77;
  key_signed            = 78;
  key_size              = 79;
  key_spacing           = 80;
  key_sparse            = 81;
  key_sprite            = 82;
  key_spritedef         = 83;
  key_text              = 84;
  key_textangle         = 85;
  key_textsize          = 86;
  key_textstyle         = 87;
  key_title             = 88;
  key_trace             = 89;
  key_trigger           = 90;
  key_update            = 91;
  key_window            = 92;

  TypeName              : array [dis_logic..dis_midi] of string = (
                          'LOGIC',
                          'SCOPE',
                          'SCOPE_XY',
                          'FFT',
                          'SPECTRO',
                          'PLOT',
                          'TERM',
                          'BITMAP',
                          'MIDI' );

  PackDef               : array [key_longs_1bit..key_bytes_4bit] of integer = (
                          0 shl 16 +  1 shl 8 + 32,   // key_longs_1bit
                          0 shl 16 +  2 shl 8 + 16,   // key_longs_2bit
                          0 shl 16 +  4 shl 8 + 8,    // key_longs_4bit
                          0 shl 16 +  8 shl 8 + 4,    // key_longs_8bit
                          0 shl 16 + 16 shl 8 + 2,    // key_longs_16bit
                          0 shl 16 +  1 shl 8 + 16,   // key_words_1bit
                          0 shl 16 +  2 shl 8 + 8,    // key_words_2bit
                          0 shl 16 +  4 shl 8 + 4,    // key_words_4bit
                          0 shl 16 +  8 shl 8 + 2,    // key_words_8bit
                          0 shl 16 +  1 shl 8 + 8,    // key_bytes_1bit
                          0 shl 16 +  2 shl 8 + 4,    // key_bytes_2bit
                          0 shl 16 +  4 shl 8 + 2);   // key_bytes_4bit

  DataSetsExp           = 11;
  DataSets              = 1 shl DataSetsExp;

  Channels              = 8;

  LogicChannels         = 32;

  LogicSets             = DataSets;
  LogicPtrMask          = LogicSets - 1;

  FFTexpMax             = DataSetsExp;
  FFTmax                = DataSets;

  Y_SetSize             = Channels;
  Y_Sets                = DataSets;
  Y_PtrMask             = Y_Sets - 1;

  XY_Elements           = 2;
  XY_SetSize            = Channels * XY_Elements;
  XY_Sets               = DataSets;
  XY_PtrMask            = XY_Sets - 1;

  SPECTRO_Samples       = DataSets;
  SPECTRO_PtrMask       = SPECTRO_Samples - 1;

  clRed                 = $FF0000;
  clLime                = $00FF00;
  clBlue                = $7F7FFF;
  clYellow              = $FFFF00;
  clMagenta             = $FF00FF;
  clCyan                = $00FFFF;
  clOrange              = $FF7F00;
  clOlive               = $7F7F00;
  clWhite               = $FFFFFF;
  clBlack               = $000000;
  clGray                = $404040;
  clGray2               = $808080;
  clGray3               = $D0D0D0;
  
  DefaultBackColor      = clBlack;
  DefaultGridColor      = clGray;
  DefaultPlotColor      = clCyan;
  DefaultTextColor      = clWhite;

  DefaultLineSize       = 1;
  DefaultDotSize        = 1;
  DefaultTextSize       = 10;
  DefaultTextStyle      = 1;

  DefaultCols           = 40;
  DefaultRows           = 20;

  fft_default           = 512;

  SmoothFillMax         = DataSets;

  scope_wmin            = 32;
  scope_wmax            = SmoothFillMax;
  scope_hmin            = 32;
  scope_hmax            = SmoothFillMax;

  scope_xy_wmin         = 32;
  scope_xy_wmax         = SmoothFillMax;

  plot_wmin             = 32;
  plot_wmax             = SmoothFillMax;
  plot_hmin             = 32;
  plot_hmax             = SmoothFillMax;
  plot_layermax         = 8;

  term_colmin           = 1;
  term_colmax           = 256;
  term_rowmin           = 1;
  term_rowmax           = 256;

  bitmap_wmin           = 1;
  bitmap_wmax           = SmoothFillMax;
  bitmap_hmin           = 1;
  bitmap_hmax           = SmoothFillMax;

  MidiSizeBase          = 8;
  MidiSizeFactor        = 4;

  SpriteMax             = 256;
  SpriteMaxX            = 32;
  SpriteMaxY            = 32;

  DefaultScopeColors    : array[0..7] of integer = (clLime, clRed, clCyan, clYellow, clMagenta, clBlue, clOrange, clOlive);
  DefaultTermColors     : array[0..7] of integer = (clOrange, clBlack, clBlack, clOrange, clLime, clBlack, clBlack, clLime);

type
  TDebugDisplayForm     = class(TForm)

    MouseWheelTimer     : TTimer;
    KeyTimer            : TTimer;

private

  DisplayType           : integer;

  ChrHeight             : integer;
  ChrWidth              : integer;

  Bitmap                : array [0..1] of TBitmap;
  BitmapLine            : array [0..SmoothFillMax - 1] of Pointer;

  DesktopDC             : HDC;
  DesktopBitmap         : TBitmap;

  CursorMask            : TBitmap;
  CursorColor           : TBitmap;
  CursorInfo            : TIconInfo;
  CursorWidth           : integer;
  CursorHeight          : integer;

  CaptionStr            : string;
  CaptionPos            : boolean;

  vBitmapWidth          : integer;
  vBitmapHeight         : integer;
  vClientWidth          : integer;
  vClientHeight         : integer;
  vWidth                : integer;
  vHeight               : integer;
  vMarginLeft           : integer;
  vMarginRight          : integer;
  vMarginTop            : integer;
  vMarginBottom         : integer;
  vRange                : integer;
  vSamples              : integer;
  vRate                 : integer;
  vRateCount            : integer;
  vSpacing              : integer;
  vTriggerMask          : integer;
  vTriggerMatch         : integer;
  vTriggerChannel       : integer;
  vTriggerAuto          : boolean;
  vTriggerArm           : integer;
  vTriggerFire          : integer;
  vTriggerOffset        : integer;
  vArmed                : boolean;
  vTriggered            : boolean;
  vHoldOff              : integer;
  vHoldOffCount         : integer;
  vToggle               : boolean;
  vLogicIndex           : integer;
  vLogicLabel           : array [0..LogicChannels - 1] of string;
  vLogicColor           : array [0..LogicChannels - 1] of integer;
  vLogicBits            : array [0..LogicChannels - 1] of byte;
  vLabel                : array [0..Channels - 1] of string;
  vAuto                 : array [0..Channels - 1] of boolean;
  vHigh                 : array [0..Channels - 1] of integer;
  vLow                  : array [0..Channels - 1] of integer;
  vMag                  : array [0..Channels - 1] of integer;
  vTall                 : array [0..Channels - 1] of integer;
  vBase                 : array [0..Channels - 1] of integer;
  vGrid                 : array [0..Channels - 1] of integer;
  vColor                : array [0..Channels - 1] of integer;
  vLut                  : array [0..255] of integer;
  vColorTune            : integer;
  vPolar                : boolean;
  vTwoPi                : int64;
  vTheta                : integer;
  vBackColor            : integer;
  vGridColor            : integer;
  vPlotColor            : integer;
  vTextAngle            : integer;
  vTextColor            : integer;
  vTextBackColor        : integer;
  vUpdate               : boolean;
  vUpdateFlag           : boolean;
  vLogScale             : boolean;
  vDirX                 : boolean;
  vDirY                 : boolean;
  vHideXY               : boolean;
  vOffsetX              : integer;
  vOffsetY              : integer;
  vColorMode            : integer;
  vTrace                : integer;
  vPixelX               : integer;
  vPixelY               : integer;
  vLineSize             : integer;
  vDotSize              : integer;
  vDotSizeY             : integer;
  vSparse               : integer;
  vTextSize             : integer;
  vTextStyle            : integer;
  vOpacity              : byte;
  vPrecise              : byte;
  vCols                 : integer;
  vRows                 : integer;
  vCol                  : integer;
  vRow                  : integer;
  vIndex                : integer;
  vScale                : extended;
  vMouseWheel           : integer;
  vKeyPress             : byte;
  vPackAlt              : boolean;
  vPackSignx            : boolean;
  vPackMask             : integer;
  vPackShift            : integer;
  vPackCount            : integer;

  ptr                   : integer;
  val                   : integer;

  LogicSampleBuff       : array [0..LogicSets - 1] of integer;
  Y_SampleBuff          : array [0..Y_Sets * Y_SetSize - 1] of integer;
  XY_SampleBuff         : array [0..XY_Sets * XY_SetSize - 1] of integer;
  SPECTRO_SampleBuff    : array [0..SPECTRO_Samples - 1] of integer;

  PolarColors           : array [0..255] of integer;

  PlotBitmap            : array [0..plot_layermax - 1] of TBitmap;

  MidiSize              : integer;
  MidiKeySize           : integer;
  MidiKeyFirst          : integer;
  MidiKeyLast           : integer;
  MidiOffset            : integer;
  MidiChannel           : integer;
  MidiState             : integer;
  MidiNote              : integer;
  MidiBlack             : array [0..127] of boolean;
  MidiLeft              : array [0..127] of integer;
  MidiRight             : array [0..127] of integer;
  MidiBottom            : array [0..127] of integer;
  MidiNumX              : array [0..127] of integer;
  MidiVelocity          : array [0..127] of integer;

  FFTexp                : integer;
  FFTmag                : integer;
  FFTfirst              : integer;
  FFTlast               : integer;
  FFTsin                : array [0..FFTmax - 1] of int64;
  FFTcos                : array [0..FFTmax - 1] of int64;
  FFTwin                : array [0..FFTmax - 1] of int64;
  FFTreal               : array [0..FFTmax - 1] of int64;
  FFTimag               : array [0..FFTmax - 1] of int64;
  FFTsamp               : array [0..FFTmax - 1] of integer;
  FFTpower              : array [0..FFTmax div 2 - 1] of integer;
  FFTangle              : array [0..FFTmax div 2 - 1] of integer;

  SpritePixels          : array [0..SpriteMax * SpriteMaxX * SpriteMaxY - 1] of byte;
  SpriteColors          : array [0..SpriteMax * 256 - 1] of integer;
  SpriteSizeX           : array [0..SpriteMax - 1] of byte;
  SpriteSizeY           : array [0..SpriteMax - 1] of byte;

  SamplePtr             : integer;
  SamplePop             : integer;

  FontAngle             : integer;
  OldFontHandle         : hFont;
  NewFontHandle         : hFont;
  NewLogFont            : TLogFont;

  SmoothFillSize        : integer;
  SmoothFillColor       : integer;
  SmoothFillBuff        : array [0..SmoothFillMax * 3 - 1] of byte;

published

  procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;

  procedure FormCreate(Sender: TObject);
  procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
  procedure FormMouseWheelTimerTick(Sender: TObject);
  procedure FormKeyPress(Sender: TObject; var Key: Char);
  procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure FormKeyTimerTick(Sender: TObject);
  procedure FormPaint(Sender: TObject);
  procedure FormMove(var Msg: TWMMove); message WM_WINDOWPOSCHANGED;
  procedure FormDestroy(Sender: TObject);

  procedure UpdateDisplay(Index: integer);

  procedure LOGIC_Configure;
  procedure LOGIC_Update;
  procedure LOGIC_Draw;

  procedure SCOPE_Configure;
  procedure SCOPE_Update;
  procedure SCOPE_Draw;
  procedure SCOPE_Range(channel: integer; var low, high: integer);

  procedure SCOPE_XY_Configure;
  procedure SCOPE_XY_Update;
  procedure SCOPE_XY_Plot(x, y, color: integer; opacity: byte);

  procedure FFT_Configure;
  procedure FFT_Update;
  procedure FFT_Draw;

  procedure SPECTRO_Configure;
  procedure SPECTRO_Update;
  procedure SPECTRO_Draw;

  procedure PLOT_Configure;
  procedure PLOT_Update;
  procedure PLOT_GetXY(var x, y: integer);
  procedure PLOT_Close;

  procedure TERM_Configure;
  procedure TERM_Update;
  procedure TERM_Chr(c: Char);

  procedure BITMAP_Configure;
  procedure BITMAP_Update;

  procedure MIDI_Configure;
  procedure MIDI_Update;
  procedure MIDI_Draw(Clear: boolean);
  procedure MIDI_DrawKey(i, OffColor, OnColor, r: integer);

  procedure KeyTitle;
  function  KeyVal(var v: integer): boolean;
  function  KeyBool(var v: boolean): boolean;
  function  KeyValWithin(var v: integer; bottom, top: integer): boolean;
  procedure KeyPos;
  procedure KeySize(var x, y: integer; wmin, wmax, hmin, hmax: integer);
  function  KeyIs(keyval: integer): boolean;
  procedure KeyTwoPi;
  function  KeyColor(var c: integer): boolean;
  procedure KeyColorMode;
  procedure KeyLutColors;
  procedure KeyPack;
  procedure KeyTextSize;
  procedure KeySave;

  procedure SetCaption(s: string);
  procedure SetDefaults;
  procedure SetTextMetrics;
  procedure SetSize(MarginLeft, MarginTop, MarginRight, MarginBottom: integer);
  procedure SetTrace(Path: integer; ModifyRate: boolean);
  procedure StepTrace;
  procedure PolarToCartesian(var rho_x, theta_y: integer);
  procedure MakeTextAngle(var a: integer);
  function  RateCycle: boolean;
  function  TranslateColor(p, mode: integer): integer;
  function  WinRGB(p: integer): integer;
  function  GetBackground: integer;
  procedure SetPolarColors;

  procedure ClearBitmap;
  function  AlphaBlend(a, b: integer; x: byte): integer;
  procedure DrawLineDot(x, y, color: integer; first: boolean);
  procedure PlotPixel(p: integer);
  procedure ScrollBitmap(x, y: integer);
  procedure AngleTextOut(x, y: integer; s: string; style, angle: integer);
  procedure BitmapToCanvas(Level: integer);

  procedure SendMousePos;
  procedure SendKeyPress;

  procedure SmoothShape(xc, yc, xs, ys, xro, yro, thick, color: integer; opacity: byte);
  procedure SmoothFillSetup(size, color: integer);
  procedure SmoothRect(x, y, xs, ys: integer; opacity: byte);
  procedure SmoothFill(x, y, count: integer; opacity: byte);
  procedure SmoothPlot(x, y: integer; opacity: byte);

  procedure SmoothDot(x, y, radius, color: integer; opacity: byte);
  procedure SmoothLine(x1, y1, x2, y2, radius, color: integer; opacity: byte);
  procedure SmoothPixel(swapxy: boolean; x, y, color: integer; opacity, opacity2: byte);
  function  SmoothClip(var x1, y1, x2, y2: integer): boolean;
  function  SmoothClipTest(x, y, lft, rgt, bot, top: integer): integer;

  function  NextKey: boolean;
  function  NextNum: boolean;
  function  NextStr: boolean;
  function  NextEnd: boolean;
  function  NextElement(Element: integer): boolean;

  procedure SetPack(val: integer; alt, signx: boolean);
  function  NewPack: integer;
  function  UnPack(var v: integer): integer;

  procedure PrepareFFT;
  procedure PerformFFT;
  function  Rev32(i: integer): int64;

public

  constructor Create(AOwner: TComponent); override;
  destructor Destroy; override;

end;

implementation

uses GlobalUnit, DebugUnit;


//////////////////////
//  Event Routines  //
//////////////////////

constructor TDebugDisplayForm.Create(AOwner: TComponent);
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
  OnMouseWheel := FormMouseWheel;
  OnKeyPress := FormKeyPress;
  OnKeyDown := FormKeyDown;
  OnPaint := FormPaint;
  OnDestroy := FormDestroy;
  MouseWheelTimer := TTimer.Create(Self);
  MouseWheelTimer.OnTimer := FormMouseWheelTimerTick;
  MouseWheelTimer.Enabled := False;
  KeyTimer := TTimer.Create(Self);
  KeyTimer.OnTimer := FormKeyTimerTick;
  KeyTimer.Enabled := False;
end;

destructor TDebugDisplayForm.Destroy;
begin
  MouseWheelTimer.Free;
  KeyTimer.Free;
  inherited Destroy;
end;

procedure TDebugDisplayForm.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := Msg.Result or DLGC_WANTTAB;
end;

procedure TDebugDisplayForm.FormCreate(Sender: TObject);
var
  i: integer;
begin
  // Set up display bitmaps
  Bitmap[0] := TBitmap.Create;
  Bitmap[0].PixelFormat := pf24bit;
  Bitmap[1] := TBitmap.Create;
  Bitmap[1].PixelFormat := pf24bit;
  Bitmap[0].Canvas.Font.Name := FontName;
  vTextSize := FontSize;
  SetTextMetrics;
  // Set up cursor bitmaps
  CursorMask := TBitmap.Create;
  CursorMask.PixelFormat := pf24bit;
  CursorColor := TBitmap.Create;
  CursorColor.PixelFormat := pf24bit;
  CursorColor.Canvas.Font.Name := FontName;
  CursorColor.Canvas.Font.Size := FontSize;
  CursorColor.Canvas.Font.Style := [];
  CursorWidth := CursorColor.Canvas.TextWidth('-2147483648,-2147483648') + 16;     // assure maximum values will fit
  CursorHeight := CursorColor.Canvas.TextHeight('X') + 16;                         // no need to resize, faster
  CursorMask.Width := CursorWidth;
  CursorMask.Height := CursorHeight;
  CursorColor.Width := CursorWidth;
  CursorColor.Height := CursorHeight;
  // Set up screen-capture bitmap and handle
  DesktopBitmap := TBitmap.Create;
  DesktopDC := GetWindowDC(GetDesktopWindow);
  // Set up polar colors
  SetPolarColors;
  // Init font angle
  FontAngle := 0;
  // Determine mode
  DisplayType := P2.DebugDisplayValue[0];
  SetCaption(PChar(P2.DebugDisplayValue[1]) + ' - ' + TypeName[DisplayType]);
  // Set initial position
  Left := P2.DebugDisplayLeft;
  Top := P2.DebugDisplayTop;
  // Configure DEBUG display window
  SetDefaults;
  ptr := 2;
  case DisplayType of
    dis_logic           : LOGIC_Configure;
    dis_scope           : SCOPE_Configure;
    dis_scope_xy        : SCOPE_XY_Configure;
    dis_fft             : FFT_Configure;
    dis_spectro         : SPECTRO_Configure;
    dis_plot            : PLOT_Configure;
    dis_term            : TERM_Configure;
    dis_bitmap          : BITMAP_Configure;
    dis_midi            : MIDI_Configure;
  end;
  Show;
end;

procedure TDebugDisplayForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
const
  DebugCursor = 5;    // user cursors are positive, system cursors are negative
var
  Str: string;
  Rf, Tf, Xf, Yf: extended;
  ScaledX, ScaledY, Bias: int64;
  StrW, StrH, W, H: integer;
  Quadrant: integer;
  TextX, TextY, CursX, CursY: integer;
begin
  Str := '';
  case DisplayType of
    dis_logic:
    begin
      if (X >= vMarginLeft) and (X < vMarginLeft + vWidth)
      and (Y >= vMarginTop) and (Y < vMarginTop + vHeight) then
        Str := IntToStr(-(vMarginLeft + vWidth - 1 - X) div vSpacing) + ',' + IntToStr((vMarginTop + vHeight - 1 - Y) div ChrHeight)
      else
        Str := '';
    end;
    dis_fft, dis_scope:
    begin
      if (X >= vMarginLeft) and (X < vMarginLeft + vWidth)
      and (Y >= vMarginTop) and (Y < vMarginTop + vHeight) then
        Str := IntToStr(X - vMarginLeft) + ',' + IntToStr(vMarginTop + vHeight - 1 - Y)
      else
        Str := '';
    end;
    dis_scope_xy:
    if not vPolar then
    begin
      ScaledX := X - ClientWidth div 2;
      ScaledY := ClientWidth div 2 - Y;
      if vLogScale then
      begin
        Rf := Power(2, Hypot(ScaledX, ScaledY) / (vWidth div 2) * Log2(Int64(vRange) + 1)) - 1;
        Tf := ArcTan2(ScaledX, ScaledY);
        SinCos(Tf, Xf, Yf);
        ScaledX := Round(Rf * Xf);
        ScaledY := Round(Rf * Yf);
      end
      else
      begin
        Bias := Round(vWidth / vRange / 4);  // Bias centers values spanning multiple pixels
        if ScaledX < 0 then Dec(ScaledX, Bias) else Inc(ScaledX, Bias);
        if ScaledY < 0 then Dec(ScaledY, Bias) else Inc(ScaledY, Bias);
        ScaledX := Round(ScaledX / vScale);
        ScaledY := Round(ScaledY / vScale);
      end;
      Str := IntToStr(ScaledX) + ',' + IntToStr(ScaledY);
    end
    else
    begin
      ScaledX := X - ClientWidth div 2;
      ScaledY := ClientWidth div 2 - Y;
      Rf := Hypot(ScaledX, ScaledY);
      if vLogScale then
        Rf := Power(2, Rf / (vWidth div 2) * Log2(Int64(vRange) + 1)) - 1
      else
        Rf := Round(Rf / vScale);
      Tf := ArcTan2(ScaledY, ScaledX) / (Pi * 2);
      ScaledX := Round(Rf);
      ScaledY := Round(Tf * vTwoPi) - vTheta;
      if (vTwoPi = $100000000) or (vTwoPi = -$100000000) then
        Str := IntToStr(ScaledX) + ',$' + IntToHex(ScaledY and $FFFFFFFF, 8) + '*'
      else
      begin
        if ScaledY < 0 then Inc(ScaledY, Abs(vTwoPi));
        Str := IntToStr(ScaledX) + ',' + IntToStr(ScaledY) + '*';
      end;
    end;
    dis_plot:
    begin
      if vDirX then TextX := (ClientWidth - X) else TextX := X;
      if vDirY then TextY := Y else TextY := (ClientHeight - Y);
      Str := IntToStr(TextX div vDotSize) + ',' + IntToStr(TextY div vDotSizeY);
    end;
    dis_term:
    begin
      if (X >= vMarginLeft) and (X < vMarginLeft + ChrWidth * vCols)
      and (Y >= vMarginTop) and (Y < vMarginTop + ChrHeight * vRows) then
        Str := IntToStr((X - vMarginLeft) div ChrWidth) + ',' + IntToStr((Y - vMarginTop) div ChrHeight)
      else
        Str := '';
    end;
    dis_spectro, dis_bitmap:
      Str := IntToStr(X div vDotSize) + ',' + IntToStr(Y div vDotSizeY);
  end;
  // Get measurement cursor dimensions
  if vHideXY then Str := '';
  StrW := CursorColor.Canvas.TextWidth(Str) + 1;    // + 1 prevents cursor rendering glitch
  StrH := CursorHeight - 16;                        // computed in FormCreate
  W := StrW + 16;
  H := CursorHeight;
  // Handle justification
  if X >= ClientWidth div 2 then Quadrant := 1 else Quadrant := 0;
  if Y >= ClientHeight div 2 then Quadrant := Quadrant or 2;
  case Quadrant of
    0:  begin
          TextX := 16;
          TextY := 16;
          CursX := 9;
          CursY := 9;
        end;
    1:  begin
          TextX := 0;
          TextY := 16;
          CursX := W - 9;
          CursY := 9;
        end;
    2:  begin
          TextX := 16;
          TextY := 0;
          CursX := 9;
          CursY := H - 9;
        end;
    3:  begin
          TextX := 0;
          TextY := 0;
          CursX := W - 9;
          CursY := H - 9;
        end;
  end;
  // Clear color bitmap
  CursorColor.Canvas.Brush.Color := clBlack;
  CursorColor.Canvas.FillRect(Rect(0, 0, CursorWidth, CursorHeight));
  // Clear mask bitmap
  CursorMask.Canvas.Brush.Color := clWhite;
  CursorMask.Canvas.FillRect(Rect(0, 0, CursorWidth, CursorHeight));
  // If text present, add to bitmaps
  if Str <> '' then
  begin
    // Draw text on color bitmap
    CursorColor.Canvas.Brush.Color := WinRGB(vBackColor);
    CursorColor.Canvas.Font.Color := WinRGB(vGridColor); //vBackColor xor $FFFFFF;
    CursorColor.Canvas.TextRect(Rect(TextX, TextY, TextX + StrW, TextY + StrH), TextX, TextY, Str);
    // Draw text rectangle on mask bitmap
    CursorMask.Canvas.Brush.Color := clBlack;
    CursorMask.Canvas.FillRect(Rect(TextX, TextY, TextX + StrW, TextY + StrH));
  end;
  // Draw cross on color bitmap
  CursorColor.Canvas.Pen.Color := WinRGB(vBackColor) xor $FFFFFF;
  CursorColor.Canvas.MoveTo(CursX + 0, CursY - 8);
  CursorColor.Canvas.LineTo(CursX + 0, CursY + 8);
  CursorColor.Canvas.MoveTo(CursX - 8, CursY + 0);
  CursorColor.Canvas.LineTo(CursX + 8, CursY + 0);
  // Draw cross on mask bitmap
  CursorMask.Canvas.Pen.Color := clBlack;
  CursorMask.Canvas.MoveTo(CursX + 0, CursY - 8);
  CursorMask.Canvas.LineTo(CursX + 0, CursY + 8);
  CursorMask.Canvas.MoveTo(CursX - 8, CursY + 0);
  CursorMask.Canvas.LineTo(CursX + 8, CursY + 0);
  // Set up cursor
  CursorInfo.fIcon := False;
  CursorInfo.xHotSpot := CursX;
  CursorInfo.yHotSpot := CursY;
  CursorInfo.hbmMask := CursorMask.Handle;
  CursorInfo.hbmColor := CursorColor.Handle;
  Screen.Cursors[DebugCursor] := CreateIconIndirect(CursorInfo);
  Cursor := DebugCursor;
  Perform(CM_CURSORCHANGED, 0, 0);
end;

procedure TDebugDisplayForm.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
begin
  if WheelDelta > 0 then vMouseWheel := 1 else vMouseWheel := -1;
  MouseWheelTimer.Enabled := False;  // reset timer to cancel vMouseWheel in case it's not used in 100ms
  MouseWheelTimer.Interval := 100;
  MouseWheelTimer.Enabled := True;
end;

procedure TDebugDisplayForm.FormMouseWheelTimerTick(Sender: TObject);
begin
  MouseWheelTimer.Enabled := False;  // 100ms reached, disable timer and cancel vMouseWheel
  vMouseWheel := 0;
end;

procedure TDebugDisplayForm.FormKeyPress(Sender: TObject; var Key: Char);
begin
  vKeyPress := Byte(Key);            // capture keys from OnKeyPress
  KeyTimer.Enabled := False;         // reset timer to cancel vKeyPress in case it's not used in 100ms
  KeyTimer.Interval := 100;
  KeyTimer.Enabled := True;
end;

procedure TDebugDisplayForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
  FormKeyPress(Self, k); Exit;
end;

procedure TDebugDisplayForm.FormKeyTimerTick(Sender: TObject);
begin
  KeyTimer.Enabled := False;         // 100ms reached, disable timer and cancel vKeyPress
  vKeyPress := 0;
end;

procedure TDebugDisplayForm.FormPaint(Sender: TObject);
begin
  BitmapToCanvas(1);
end;

procedure TDebugDisplayForm.FormMove(var Msg: TWMMove);
begin
  inherited;
  Caption := CaptionStr + ' (' + IntToStr(Left) + ', ' + IntToStr(Top) + ')';
  CaptionPos := True;
end;

procedure TDebugDisplayForm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  Bitmap[0].Free;
  Bitmap[1].Free;
  CursorColor.Free;
  CursorMask.Free;
  ReleaseDC(GetDesktopWindow, DesktopDC);
  DesktopBitmap.Free;
  case DisplayType of
//  dis_logic           : LOGIC_Close;
//  dis_scope           : SCOPE_Close;
//  dis_scope_xy        : SCOPE_XY_Close;
//  dis_fft             : FFT_Close;
//  dis_spectro         : SPECTRO_Close;
    dis_plot            : PLOT_Close;
//  dis_term            : TERM_Close;
//  dis_bitmap          : BITMAP_Close;
//  dis_midi            : MIDI_Close;
  end;
end;


//////////////////////
//  Update Display  //
//////////////////////

procedure TDebugDisplayForm.UpdateDisplay(Index: integer);
begin
  ptr := Index;
  case DisplayType of
    dis_logic           : LOGIC_Update;
    dis_scope           : SCOPE_Update;
    dis_scope_xy        : SCOPE_XY_Update;
    dis_fft             : FFT_Update;
    dis_spectro         : SPECTRO_Update;
    dis_plot            : PLOT_Update;
    dis_term            : TERM_Update;
    dis_bitmap          : BITMAP_Update;
    dis_midi            : MIDI_Update;
  end;
  // Restore caption if showing window position
  if CaptionPos then
  begin
    Caption := CaptionStr;
    CaptionPos := False;
  end;
end;


/////////////
//  LOGIC  //
/////////////

procedure TDebugDisplayForm.LOGIC_Configure;
var
  i, v, color: integer;
  s: string;
  isRange: boolean;
begin
  // Set unique defaults
  vSamples := 32;
  vSpacing := 8;
  vRate := 1;
  vLogicIndex := 0;
  vDotSize := 0;
  vLineSize := 3;
  vTextSize := FontSize;
  // Process any parameters
  while not NextEnd do
  begin
    if NextNum then Break;   // number not allowed
    if NextKey then
    case val of
      key_title:
        KeyTitle;
      key_pos:
        KeyPos;
      key_samples:
        KeyValWithin(vSamples, 4, LogicSets - 1);
      key_spacing:
        KeyValWithin(vSpacing, 2-1, 32);
      key_rate:
        KeyValWithin(vRate, 1, LogicSets);
      key_dotsize:
        KeyValWithin(vDotSize, 0, 32);
      key_linesize:
        KeyValWithin(vLineSize, 1, 32);
      key_textsize:
        KeyTextSize;
      key_color:
        if KeyColor(vBackColor)
          then KeyColor(vGridColor);
      key_hidexy:
        vHideXY := True;
      key_longs_1bit..key_bytes_4bit:
        KeyPack;
    end
    else
    if NextStr then
    begin
      // new channel(s) name
      s := PChar(val);
      if vLogicIndex < LogicChannels then
      begin
        vLogicLabel[vLogicIndex] := s;
        if not KeyValWithin(v, 1, LogicChannels) then v := 1;
        MaxLimit(v, LogicChannels - vLogicIndex);
        isRange := KeyIs(key_range);
        if not KeyColor(color) then color := DefaultScopeColors[vLogicIndex mod 8];
        for i := 0 to v - 1 do
        begin
          vLogicColor[vLogicIndex + i] := color;
          if isRange then
          begin
            vLogicBits[vLogicIndex + i] := v;
            if i = 1 then
            begin
               vLogicLabel[vLogicIndex + 1] := IntToStr(v);
               vLogicColor[vLogicIndex + 1] := vLogicColor[vLogicIndex + 1] shr 2 and $3F3F3F;
            end;
            if i > 1 then vLogicLabel[vLogicIndex + i] := '';
          end
          else
          begin
            vLogicBits[vLogicIndex + i] := 1;
            if v > 1 then
              if i = 0 then vLogicLabel[vLogicIndex] := s + ' 0'
              else vLogicLabel[vLogicIndex + i] := IntToStr(i);
          end;
        end;
        Inc(vLogicIndex, v);
      end;
    end;
  end;
  // If no labels specified, do 32 channels
  if vLogicIndex = 0 then
  begin
    for i := 0 to LogicChannels - 1 do
    begin
      vLogicLabel[i] := IntToStr(i);
      vLogicColor[i] := DefaultScopeColors[0];
      vLogicBits[i] := 1;
    end;
    vLogicIndex := LogicChannels;
  end
  else MaxLimit(vLogicIndex, LogicChannels);
  // Reset trigger data
  vTriggerMask := 0;
  vTriggerMatch := 1;
  vTriggerOffset := vSamples div 2;
  vHoldOff := vSamples;
  // Set channel metrics
  v := 0;
  for i := 0 to vLogicIndex - 1 do MinLimit(v, Length(vLogicLabel[i]) + 2);
  // Set form metrics
  SetTextMetrics;
  vWidth := vSamples * vSpacing;
  vHeight := vLogicIndex * ChrHeight;
  SetSize(v * ChrWidth, ChrHeight, ChrHeight, ChrHeight);
end;

procedure TDebugDisplayForm.LOGIC_Update;
var
  i, t, v: integer;
begin
  while not NextEnd do
  begin
    if NextStr then Break;   // string not allowed
    if NextKey then
    case val of
      key_trigger:
      begin
        vArmed := False;
        if not KeyVal(vTriggerMask) then Continue;
        if not KeyVal(vTriggerMatch) then Continue;
        KeyValWithin(vTriggerOffset, 0, vSamples - 1);
      end;
      key_holdoff:
        if KeyValWithin(vHoldOff, 2, LogicSets) then vHoldOffCount := 0;
      key_clear:
      begin
        vTriggered := False;    // don't draw trigger indicator
        ClearBitmap;
        BitmapToCanvas(0);
        SamplePop := 0;
        vRateCount := 0;
      end;
      key_save:
        KeySave;
      key_pc_key:
        SendKeyPress;
      key_pc_mouse:
        SendMousePos;
    end
    else
    while NextNum do
    begin
      // Get channel sample(s)
      v := NewPack;
      for i := 1 to vPackCount do
      begin
        // Enter sample into buffer
        LogicSampleBuff[SamplePtr] := UnPack(v);
        SamplePtr := (SamplePtr + 1) and LogicPtrMask;
        if SamplePop < vSamples then Inc(SamplePop);
        // Trigger enabled?
        vTriggered := False;
        if vTriggerMask <> 0 then
        begin
          if SamplePop <> vSamples then Continue;    // if sample buffer not full, exit
          t := LogicSampleBuff[(SamplePtr - vTriggerOffset) and LogicPtrMask];
          if vArmed then
          begin
            if ((t xor vTriggerMatch) and vTriggerMask) = 0 then
            begin
              vTriggered := True;
              vArmed := False;
            end;
          end
          else
          begin
            if ((t xor vTriggerMatch) and vTriggerMask) <> 0 then vArmed := True;
          end;
          if vHoldOffCount > 0 then Dec(vHoldOffCount);
          if not vTriggered or (vHoldOffCount > 0) then Continue;
          vHoldOffCount := vHoldOff;
          if RateCycle then LOGIC_Draw;
        end
        // Trigger not enabled
        else if RateCycle then LOGIC_Draw;
      end;
    end;
  end;
end;

procedure TDebugDisplayForm.LOGIC_Draw;
var
  j, k, x, top, bot, color, colordim: integer;
  mask, v, y: int64;
  first, last: boolean;
begin
  ClearBitmap;
  j := 0;
  while j < vLogicIndex do
  begin
    // Set waveform attributes
    color := vLogicColor[j];
    colordim := color shr 2 and $3F3F3F;
    bot := (vMarginTop + vHeight - ChrHeight * j                       - ChrHeight *  3 shr 4) shl 8;
    top := (vMarginTop + vHeight - ChrHeight * (j + vLogicBits[j] - 1) - ChrHeight * 13 shr 4) shl 8;
    mask := Int64(1) shl vLogicBits[j] - 1;
    // If range waveform, draw top and bottom boundary lines
    if vLogicBits[j] > 1 then
    begin
      SmoothLine((vMarginLeft + 1) shl 8, top, (vMarginLeft + vWidth - 1) shl 8, top, $80, colordim, 255);
      SmoothLine((vMarginLeft + 1) shl 8, bot, (vMarginLeft + vWidth - 1) shl 8, bot, $80, colordim, 255);
    end;
    // Plot waveform
    for k := SamplePop - 1 downto 0 do
    begin
      first := k = SamplePop - 1;
      last := k = 0;
      x := (vMarginLeft + vWidth - (k + 1) * vSpacing) shl 8;
      v := (LogicSampleBuff[(SamplePtr - k - 1) and LogicPtrMask] shr j) and mask;
      y := v * (top - bot) div mask + bot;
      DrawLineDot(x + Ord(first) shl 8, y, color, first);
      DrawLineDot(x + (vSpacing - Ord(last)) shl 8, y, color, false);
    end;
    Inc(j, vLogicBits[j]);
  end;
  BitmapToCanvas(0);
end;


/////////////
//  SCOPE  //
/////////////

procedure TDebugDisplayForm.SCOPE_Configure;
var
  i: integer;
begin
  // Set unique defaults
  vRate := 1;
  vDotSize := 0;
  vLineSize := 3;
  vTextSize := FontSize;
  // Process any parameters
  while NextKey do
  case val of
    key_title:
      KeyTitle;
    key_pos:
      KeyPos;
    key_size:
      KeySize(vWidth, vHeight, scope_wmin, scope_wmax, scope_hmin, scope_hmax);
    key_samples:
      KeyValWithin(vSamples, 16, Y_Sets);
    key_rate:
      KeyValWithin(vRate, 1, Y_Sets);
    key_dotsize:
      KeyValWithin(vDotSize, 0, 32);
    key_linesize:
      KeyValWithin(vLineSize, 0, 32);
    key_textsize:
      KeyTextSize;
    key_color:
      if KeyColor(vBackColor)
        then KeyColor(vGridColor);
    key_hidexy:
      vHideXY := True;
    key_longs_1bit..key_bytes_4bit:
      KeyPack;
  end;
  // Set defaults
  if (vDotSize = 0) and (vLineSize = 0) then vDotSize := 1;
  for i := 0 to Channels - 1 do
  begin
    vAuto[i] := False;
    vLow[i]  := -$80000000;
    vHigh[i] := $7FFFFFFF;
    vTall[i] := vHeight;
    vBase[i] := 0;
    vGrid[i] := 0;
  end;
  vTriggerChannel := -1;
  vTriggerAuto := False;
  vTriggerArm := -1;
  vTriggerFire := 0;
  vTriggerOffset := vSamples div 2;
  vHoldOff := vSamples;
  // Set form metrics
  SetTextMetrics;
  SetSize(ChrWidth, ChrHeight * 2, ChrWidth, ChrWidth);
end;

procedure TDebugDisplayForm.SCOPE_Update;
var
  ch, i, t, v, low, high: integer;
  samp: array[0..Y_SetSize - 1] of integer;
begin
  ch := 0;
  while not NextEnd do
  begin
    if NextStr then
    begin
      if vIndex <> Channels then Inc(vIndex);
      vLabel[vIndex - 1] := PChar(val);
      if KeyIs(key_auto) then
        vAuto[vIndex - 1] := True
      else
      begin
        if not KeyVal( vLow[vIndex - 1]) then Continue;
        if not KeyVal(vHigh[vIndex - 1]) then Continue;
      end;
      if not KeyVal(vTall[vIndex - 1]) then Continue;
      if not KeyVal(vBase[vIndex - 1]) then Continue;
      if not KeyVal(vGrid[vIndex - 1]) then Continue;
      KeyColor(vColor[vIndex - 1]);
    end
    else
    if NextKey then
    case val of
      key_trigger:
      begin
        vArmed := False;
        if not KeyValWithin(vTriggerChannel, -1, 7) then Continue;
        if KeyIs(key_auto) then
          vTriggerAuto := True
        else
        begin
          vTriggerAuto := False;
          if not KeyVal(vTriggerArm) then Continue;
          if not KeyVal(vTriggerFire) then Continue;
        end;
        KeyValWithin(vTriggerOffset, 0, vSamples - 1);
      end;
      key_holdoff:
        if KeyValWithin(vHoldOff, 2, Y_Sets) then vHoldOffCount := 0;
      key_clear:
      begin
        vTriggered := False;    // don't draw trigger indicator
        ClearBitmap;
        BitmapToCanvas(0);
        SamplePop := 0;
        vRateCount := 0;
      end;
      key_save:
        KeySave;
      key_pc_key:
        SendKeyPress;
      key_pc_mouse:
        SendMousePos;
    end
    else
    while NextNum do
    begin
      // Get channel sample(s)
      v := NewPack;
      for i := 1 to vPackCount do
      begin
        // Enter sample into local buffer
        samp[ch] := UnPack(v);
        Inc(ch);
        if ch = vIndex then
        begin
          // Enter sample set into main buffer
          ch := 0;
          Move(samp, Y_SampleBuff[SamplePtr * Y_SetSize], Y_SetSize shl 2);
          SamplePtr := (SamplePtr + 1) and Y_PtrMask;
          if SamplePop < vSamples then Inc(SamplePop);
          // Trigger enabled?
          vTriggered := False;
          if vTriggerChannel >= 0 then
          begin
            if SamplePop <> vSamples then Continue;      // if sample buffer not full, exit
            if vTriggerAuto then
            begin
              SCOPE_Range(vTriggerChannel, low, high);
              vTriggerArm := (high - low) div 3 + low;
              vTriggerFire := (high - low) div 2 + low;
            end;
            t := Y_SampleBuff[((SamplePtr - vTriggerOffset - 1) and Y_PtrMask) * Y_SetSize + vTriggerChannel];
            if vArmed then
            begin
              if vTriggerFire >= vTriggerArm then
              begin
                if t >= vTriggerFire then
                begin
                  vTriggered := True;
                  vArmed := False;
                end;
              end
              else
              begin
                if t <= vTriggerFire then
                begin
                  vTriggered := True;
                  vArmed := False;
                end;
              end;
            end
            else
            begin
              if vTriggerFire >= vTriggerArm then
              begin
                if t <= vTriggerArm then vArmed := True;
              end
              else
              begin
                if t >= vTriggerArm then vArmed := True;
              end;
            end;
            if vHoldOffCount > 0 then Dec(vHoldOffCount);
            if not vTriggered or (vHoldOffCount > 0) then Continue;
            vHoldOffCount := vHoldOff;
            if RateCycle then SCOPE_Draw;
          end
          // Trigger not enabled
          else if RateCycle then SCOPE_Draw;
        end;
      end;
    end;
  end;
end;

procedure TDebugDisplayForm.SCOPE_Draw;
var
  j, k, x, y, color, offset: integer;
  v: int64;
  fScale: Extended;
begin
  // autoscale enabled channels
  for j := vIndex - 1 downto 0 do if vAuto[j] then SCOPE_Range(j, vLow[j], vHigh[j]);
  // draw scope
  ClearBitmap;
  for j := vIndex - 1 downto 0 do
  begin
    if vHigh[j] = vLow[j] then fscale := 0    // prevent divide by zero
    else fScale := (vTall[j] - 1) / (Abs(Int64(vHigh[j]) - Int64(vLow[j]))) * $100;
    if vHigh[j] > vLow[j] then offset := vLow[j] else offset := vHigh[j];
    color := vColor[j];
    for k := SamplePop - 1 downto 0 do
    begin
      v := Y_SampleBuff[((SamplePtr - k - 1) and Y_PtrMask) * Y_SetSize + j];
      x := (vMarginLeft + vWidth - 1) shl 8 - Round(k / vSamples * vWidth * $100);
      y := (vMarginTop + vHeight - 1 - vBase[j]) shl 8 - Round((v - offset) * fScale);
      DrawLineDot(x, y, color, k = SamplePop - 1)
    end;
  end;
  BitmapToCanvas(0);
end;

procedure TDebugDisplayForm.SCOPE_Range(channel: integer; var low, high: integer);
var
  k: integer;
  v: int64;
begin
  low := $7FFFFFFF;
  high := -$80000000;
  for k := SamplePop - 1 downto 0 do
  begin
    v := Y_SampleBuff[((SamplePtr - k - 1) and Y_PtrMask) * Y_SetSize + channel];
    if v < low then low := v;
    if v > high then high := v;
  end;
end;


////////////////
//  SCOPE_XY  //
////////////////

procedure TDebugDisplayForm.SCOPE_XY_Configure;
begin
  // Set unique defaults
  vRange := $7FFFFFFF;
  vRate := 1;
  vDotSize := 6;
  vTextSize := FontSize;
  // Process any parameters
  while not NextEnd do
  begin
    if NextKey then
    case val of
      key_title:
        KeyTitle;
      key_pos:
        KeyPos;
      key_size:
      begin
        if NextNum then vWidth := Within(val * 2, scope_xy_wmin, scope_xy_wmax) else Continue;
        vHeight := vWidth;
      end;
      key_range:
        KeyValWithin(vRange, 1, $7FFFFFFF);
      key_samples:
        KeyValWithin(vSamples, 0, XY_Sets);
      key_rate:
        KeyValWithin(vRate, 1, XY_Sets);
      key_dotsize:
        KeyValWithin(vDotSize, 2, 20);
      key_textsize:
        KeyTextSize;
      key_color:
        if KeyColor(vBackColor)
          then KeyColor(vGridColor);
      key_polar:
        KeyTwoPi;
      key_logscale:
        vLogScale := True;
      key_hidexy:
        vHideXY := True;
      key_longs_1bit..key_bytes_4bit:
        KeyPack;
    end
    else if NextStr then
    begin
      if vIndex <> Channels then Inc(vIndex);
      vLabel[vIndex - 1] := PChar(val);
      KeyColor(vColor[vIndex - 1]);
    end;
  end;
  // Set scale factor
  vScale := vWidth / 2 / vRange;
  // Set form metrics
  SetTextMetrics;
  SetSize(ChrHeight * 2, ChrHeight * 2, ChrHeight * 2, ChrHeight * 2);
end;

procedure TDebugDisplayForm.SCOPE_XY_Update;
var
  i, j, k, v, ch, ptr, opa: integer;
  samp: array[0..XY_SetSize - 1] of integer;
begin
  ch := 0;
  while not NextEnd do
  begin
    if NextStr then Break;   // string not allowed
    if NextKey then
    case val of
      key_clear:
      begin
        ClearBitmap;
        BitmapToCanvas(0);
        SamplePop := 0;
        vRateCount := 0;
      end;
      key_save:
        KeySave;
      key_pc_key:
        SendKeyPress;
      key_pc_mouse:
        SendMousePos;
    end
    else
    while NextNum do
    begin
      // Get channel sample(s)
      v := NewPack;
      for i := 1 to vPackCount do
      begin
        samp[ch] := UnPack(v);
        Inc(ch);
        if ch = vIndex shl 1 then
        begin
          ch := 0;
          if vSamples = 0 then
          begin
            // Persistent display
            for j := vIndex - 1 downto 0 do SCOPE_XY_Plot(samp[j shl 1 + 0], samp[j shl 1 + 1], vColor[j], 255);
            if RateCycle then BitmapToCanvas(0);
          end
          else
          begin
            // Fading display
            Move(samp, XY_SampleBuff[SamplePtr * XY_SetSize], XY_SetSize shl 2);
            SamplePtr := (SamplePtr + 1) and XY_PtrMask;
            if SamplePop < vSamples then Inc(SamplePop);
            if RateCycle then
            begin
              ClearBitmap;
              for j := vIndex - 1 downto 0 do
                for k := SamplePop - 1 downto 0 do
                begin
                  ptr := ((SamplePtr - k - 1) and XY_PtrMask) * XY_SetSize + j * 2;
                  opa := 255 - (k * 255 div vSamples);
                  SCOPE_XY_Plot(XY_SampleBuff[ptr + 0], XY_SampleBuff[ptr + 1], vColor[j], opa);
                end;
              BitmapToCanvas(0);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TDebugDisplayForm.SCOPE_XY_Plot(x, y, color: integer; opacity: byte);
var
  Rf, Tf, Xf, Yf: extended;
begin
  if not vPolar then
  begin
    if vLogScale then
    begin
      Rf := (Log2(Hypot(x, y) + 1) / Log2(Int64(vRange) + 1)) * (vWidth div 2);
      Tf := ArcTan2(x, y);
      SinCos(Tf, Xf, Yf);
      X := Round(Rf * Xf * $100);
      Y := Round(Rf * Yf * $100);
    end
    else
    begin
      X := Round(x * vScale * $100);
      Y := Round(y * vScale * $100);
    end;
  end
  else
  begin
    if vLogScale then
      if x <> 0 then Rf := (Log2(x) / Log2(vRange)) * (vWidth div 2) else Rf := 0
    else
      Rf := x * vScale;
    Tf := Pi / 2 - (y + vTheta) / vTwoPi * Pi * 2;
    SinCos(Tf, Xf, Yf);
    x := Round(Rf * Xf * $100);
    y := Round(Rf * Yf * $100);
  end;
  x := vBitmapWidth shl 7 + x;
  y := vBitmapHeight shl 7 - y;
  SmoothDot(x, y, vDotSize shl 6, color, opacity);
end;


///////////
//  FFT  //
///////////

procedure TDebugDisplayForm.FFT_Configure;
var
  i: integer;
begin
  // Set unique defaults
  vSamples := fft_default;
  FFTexp := Trunc(Log2(fft_default));
  FFTfirst := 0;
  FFTlast := fft_default div 2 - 1;
  vDotSize := 0;
  vLineSize := 3;
  vTextSize := FontSize;
  // Process any parameters
  while NextKey do
  case val of
    key_title:
      KeyTitle;
    key_pos:
      KeyPos;
    key_size:
      KeySize(vWidth, vHeight, scope_wmin, scope_wmax, scope_hmin, scope_hmax);
    key_samples:
    begin
      if not NextNum then Continue;
      FFTexp := Trunc(Log2(Within(val, 4, FFTmax)));
      vSamples := 1 shl FFTexp;
      FFTfirst := 0;
      FFTlast := vSamples div 2 - 1;
      if KeyValWithin(FFTfirst, 0, vSamples div 2 - 2) then
        KeyValWithin(FFTlast, FFTfirst + 1, vSamples div 2 - 1);
    end;
    key_rate:
      KeyValWithin(vRate, 1, FFTmax);
    key_dotsize:
      KeyValWithin(vDotSize, 0, 32);
    key_linesize:
      KeyValWithin(vLineSize, -32, 32);
    key_textsize:
      KeyTextSize;
    key_color:
      if KeyColor(vBackColor)
        then KeyColor(vGridColor);
    key_logscale:
      vLogScale := True;
    key_hidexy:
      vHideXY := True;
    key_longs_1bit..key_bytes_4bit:
      KeyPack;
  end;
  // Prepare
  PrepareFFT;
  if vRate = 0 then vRate := vSamples;
  vRateCount := vRate - 1;
  // Set defaults
  if (vDotSize = 0) and (vLineSize = 0) then vDotSize := 1;
  for i := 0 to Channels - 1 do
  begin
    vMag[i]  := 0;
    vHigh[i] := $7FFFFFFF;
    vTall[i] := vHeight;
    vBase[i] := 0;
    vGrid[i] := 0;
  end;
  // Set form metrics
  SetTextMetrics;
  SetSize(ChrWidth, ChrHeight * 2, ChrWidth, ChrWidth);
end;

procedure TDebugDisplayForm.FFT_Update;
var
  i, ch, v: integer;
  samp: array[0..Y_SetSize - 1] of integer;
begin
  ch := 0;
  while not NextEnd do
  begin
    if NextStr then
    begin
      if vIndex <> Channels then Inc(vIndex);
      vLabel[vIndex - 1] := PChar(val);
      if not KeyValWithin(vMag[vIndex - 1], 0, 11) then Continue;
      if not KeyValWithin(vHigh[vIndex - 1], 1, $7FFFFFFF) then Continue;
      if not KeyVal(vTall[vIndex - 1]) then Continue;
      if not KeyVal(vBase[vIndex - 1]) then Continue;
      if not KeyVal(vGrid[vIndex - 1]) then Continue;
      KeyColor(vColor[vIndex - 1]);
    end
    else
    if NextKey then
    case val of
      key_clear:
      begin
        ClearBitmap;
        BitmapToCanvas(0);
        SamplePop := 0;
        vRateCount := vRate - 1;
      end;
      key_save:
        KeySave;
      key_pc_key:
        SendKeyPress;
      key_pc_mouse:
        SendMousePos;
    end
    else
    while NextNum do
    begin
      // Get channel sample(s)
      v := NewPack;
      for i := 1 to vPackCount do
      begin
        // Enter sample into local buffer
        samp[ch] := UnPack(v);
        Inc(ch);
        if ch = vIndex then
        begin
          // Enter sample set into main buffer
          ch := 0;
          Move(samp, Y_SampleBuff[SamplePtr * Y_SetSize], Y_SetSize shl 2);
          SamplePtr := (SamplePtr + 1) and Y_PtrMask;
          if SamplePop < vSamples then Inc(SamplePop);
          if SamplePop <> vSamples then Continue;     // if sample buffer not full, exit
          if RateCycle then FFT_Draw;
        end;
      end;
    end;
  end;
end;

procedure TDebugDisplayForm.FFT_Draw;
var
  j, k, x, y, color: integer;
  v: int64;
  fScale: Extended;
begin
  ClearBitmap;
  for j := vIndex - 1 downto 0 do
  begin
    fScale := (vTall[j] - 1) / vHigh[j] * $100;
    color := vColor[j];
    for x := 0 to vSamples - 1 do
      FFTsamp[x] := Y_SampleBuff[((SamplePtr - vSamples + x) and Y_PtrMask) * Y_SetSize + j];
    FFTmag := vMag[j];
    PerformFFT;
    for k := FFTfirst to FFTlast do
    begin
      v := FFTpower[k];
      if vLogScale then v := Round(Log2(Int64(v) + 1) / Log2(Int64(vHigh[j]) + 1) * vHigh[j]);
      x := vMarginLeft shl 8 + Trunc((k - FFTfirst) / (FFTlast - FFTfirst) * (vWidth - 1) * $100);
      y := (vMarginTop + vHeight - 1 - vBase[j]) shl 8 - Round(v * fScale);
      if vLineSize >= 0 then DrawLineDot(x, y, color, k = FFTfirst)
      else
      begin
        SmoothLine(x, (vMarginTop + vHeight - 1 - vBase[j]) shl 8, x, y, -vLineSize shl 6, color, $FF);
        if vDotSize > 0 then
          SmoothDot(x, y, vDotSize shl 7, color, $FF);
      end
    end;
  end;
  BitmapToCanvas(0);
end;


///////////////
//  SPECTRO  //
///////////////

procedure TDebugDisplayForm.SPECTRO_Configure;
var
  i: integer;
begin
  // Set unique defaults
  vTrace := $F;
  vColorMode := key_luma8x;
  vSamples := fft_default;
  FFTexp := Trunc(Log2(fft_default));
  FFTfirst := 0;
  FFTlast := fft_default div 2 - 1;
  FFTmag := 0;
  vDotSize := 1;
  vDotSizeY := 1;
  vRange := $7FFFFFFF;
  // Process any parameters
  while NextKey do
  case val of
    key_title:
      KeyTitle;
    key_pos:
      KeyPos;
    key_samples:
    begin
      if not NextNum then Continue;
      FFTexp := Trunc(Log2(Within(val, 4, FFTmax)));
      vSamples := 1 shl FFTexp;
      FFTfirst := 0;
      FFTlast := vSamples div 2 - 1;
      if KeyValWithin(FFTfirst, 0, vSamples div 2 - 2) then
        KeyValWithin(FFTlast, FFTfirst + 1, vSamples div 2 - 1);
    end;
    key_depth:
      KeyValWithin(vWidth, 1, FFTmax);
    key_mag:
      KeyValWithin(FFTmag, 0, FFTexpMax);
    key_range:
      KeyValWithin(vRange, 1, $7FFFFFFF);
    key_rate:
      KeyValWithin(vRate, 1, FFTmax);
    key_trace:
      KeyVal(vTrace);
    key_dotsize:
      if KeyValWithin(vDotSize, 1, 16) then
      begin
        vDotSizeY := vDotSize;
        KeyValWithin(vDotSizeY, 1, 16);
      end;
    key_luma8..key_luma8x, key_hsv16..key_hsv16x:
      KeyColorMode;
    key_logscale:
      vLogScale := True;
    key_hidexy:
      vHideXY := True;
    key_longs_1bit..key_bytes_4bit:
      KeyPack;
  end;
  // Prepare
  PrepareFFT;
  if vRate = 0 then vRate := vSamples div 8;
  vRateCount := vRate - 1;
  // Set form metrics
  vHeight := FFTlast - FFTfirst + 1;
  if vTrace and $4 = 0 then
  begin
    i := vWidth;
    vWidth := vHeight;
    vHeight := i;
  end;
  SetSize(0, 0, 0, 0);
  SetTrace(vTrace, False);
end;

procedure TDebugDisplayForm.SPECTRO_Update;
var
  i, v: integer;
begin
  while not NextEnd do
  begin
    if NextStr then Break;   // string not allowed
    if NextKey then
    case val of
      key_clear:
      begin
        ClearBitmap;
        BitmapToCanvas(0);
        SamplePop := 0;
        vRateCount := vRate - 1;
        SetTrace(vTrace, False);
      end;
      key_save:
        KeySave;
      key_pc_key:
        SendKeyPress;
      key_pc_mouse:
        SendMousePos;
    end
    else
    begin
      while NextNum do
      begin
        // Get sample(s)
        v := NewPack;
        for i := 1 to vPackCount do
        begin
          // Enter sample into buffer
          SPECTRO_SampleBuff[SamplePtr] := UnPack(v);
          SamplePtr := (SamplePtr + 1) and SPECTRO_PtrMask;
          if SamplePop < vSamples then Inc(SamplePop);
          if SamplePop <> vSamples then Continue;     // if sample buffer not full, exit
          if RateCycle then SPECTRO_Draw;
        end;
      end;
    end;
  end;
end;

procedure TDebugDisplayForm.SPECTRO_Draw;
var
  x, p: integer;
  v: int64;
  fScale: Extended;
begin
  for x := 0 to vSamples - 1 do
    FFTsamp[x] := SPECTRO_SampleBuff[(SamplePtr - vSamples + x) and SPECTRO_PtrMask];
  PerformFFT;
  fScale := 255 / vRange;
  for x := FFTfirst to FFTlast do
  begin
    v := FFTpower[x];
    if vLogScale then v := Round(Log2(Int64(v) + 1) / Log2(Int64(vRange) + 1) * vRange);
    p := Round(v * fScale);
    if p > $FF then p := $FF;
    if vColorMode in [key_hsv16..key_hsv16x] then p := p or FFTangle[x] shr 16 and $FF00;
    PlotPixel(p);
    if x = FFTlast then BitmapToCanvas(0);    // capture bitmap just before StepTrace scrolls it
    StepTrace;
  end;
end;


////////////
//  PLOT  //
////////////

procedure TDebugDisplayForm.PLOT_Configure;
var
  i: integer;
begin
  // Set unique defaults
  vDirX := False;
  vDirY := False;
  vOffsetX := 0;
  vOffsetY := 0;
  vPixelX := 0;
  vPixelY := 0;
  vDotSize := 1;
  vDotSizeY := 1;
  vPlotColor := DefaultPlotColor;
  vTextColor := DefaultTextColor;
  vOpacity := $FF;
  vPrecise := 8;
  // Process any parameters
  while NextKey do
  case val of
    key_title:                                        // TITLE 'string'
      KeyTitle;
    key_pos:                                          // POS left top
      KeyPos;
    key_size:                                         // SIZE width height
      KeySize(vWidth, vHeight, plot_wmin, plot_wmax, plot_hmin, plot_hmax);
    key_dotsize:                                      // DOTSIZE x_y y
      if KeyValWithin(vDotSize, 1, 256) then
      begin
        vDotSizeY := vDotSize;
        KeyValWithin(vDotSizeY, 1, 256);
      end;
    key_lut1..key_rgb24:                              // lut1..rgb24
      KeyColorMode;
    key_lutcolors:                                    // LUTCOLORS
      KeyLutColors;
    key_backcolor:                                    // BACKCOLOR color
      KeyColor(vBackColor);
    key_update:                                       // UPDATE
      vUpdate := True;
    key_hidexy:                                       // HIDEXY
      vHideXY := True;
  end;
  // Set up layer bitmaps
  for i := 0 to plot_layermax - 1 do PlotBitmap[i] := TBitmap.Create;
  // Clear sprite data
  FillChar(SpritePixels, SizeOf(SpritePixels), 0);
  FillChar(SpriteColors, SizeOf(SpriteColors), 0);
  FillChar(SpriteSizeX, SizeOf(SpriteSizeX), 0);
  FillChar(SpriteSizeY, SizeOf(SpriteSizeY), 0);
  // Set initial form size
  SetSize(0, 0, 0, 0);
end;

procedure TDebugDisplayForm.PLOT_Update;
var
  t1, t2, t3, t4, t5, t6, t7, t8, t, i, x, y, c, opa: integer;
  a: array [0..4] of integer;
  s: PChar;
  ppixel: PByte;
  pcolor: PIntegerArray;
begin
  while NextKey do
  case val of
    key_lut1..key_rgb24:                              // lut1..rgb24
      KeyColorMode;
    key_lutcolors:                                    // LUTCOLORS rgb24...
      KeyLutColors;
    key_backcolor:                                    // BACKCOLOR color
      KeyColor(vBackColor);
    key_color, key_black..key_gray:                   // COLOR color -or- BLACK..GRAY {brightness}
    begin
      if val <> key_color then Dec(ptr);
      if KeyColor(vPlotColor) then
       if NextKey then    // if TEXT next, set text color
       begin
         Dec(ptr);
         if val = key_text then vTextColor := vPlotColor;
       end;
    end;
    key_opacity:                                      // OPACITY byte
      if NextNum then vOpacity := val;
    key_precise:                                      // PRECISE
      vPrecise := vPrecise xor 8;
    key_linesize:                                     // LINESIZE size
      KeyVal(vLineSize);
    key_origin:                                       // ORIGIN {x y}
      if KeyVal(vOffsetX) then KeyVal(vOffsetY)
      else
      begin
        vOffsetX := vPixelX;
        vOffsetY := vPixelY;
      end;
    key_set:                                          // SET x_rho y_theta
    begin
      if not KeyVal(t1) then Break;
      if not KeyVal(t2) then Break;
      if vPolar then PolarToCartesian(t1, t2);
      vPixelX := t1;
      vPixelY := t2;
    end;
    key_dot:                                          // DOT {linesize {opacity}}
    begin
      t1 := vLineSize;
      t2 := vOpacity;
      if KeyVal(t1) then KeyVal(t2);
      if vDirX then     // handle direction
        t3 := (vWidth - 1 - vOffsetX) shl 8 - vPixelX shl vPrecise
      else
        t3 := vOffsetX shl 8 + vPixelX shl vPrecise;
      if vDirY then
        t4 := vOffsetY shl 8 + vPixelY shl vPrecise
      else
        t4 := (vHeight - 1 - vOffsetY) shl 8 - vPixelY shl vPrecise;
      SmoothDot(t3, t4, t1 shl vPrecise shr 1, vPlotColor, t2);
    end;
    key_line:                                         // LINE x_rho y_theta {linesize {opacity}}
    begin
      if not KeyVal(t1) then Break;
      if not KeyVal(t2) then Break;
      t3 := vLineSize;
      t4 := vOpacity;
      if KeyVal(t3) then KeyVal(t4);
      if vPolar then PolarToCartesian(t1, t2);
      if vDirX then     // handle direction
      begin
        t5 := (vWidth - 1 - vOffsetX) shl 8 - vPixelX shl vPrecise;
        t7 := (vWidth - 1 - vOffsetX) shl 8 -      t1 shl vPrecise;
      end
      else
      begin
        t5 := vOffsetX shl 8 + vPixelX shl vPrecise;
        t7 := vOffsetX shl 8 +      t1 shl vPrecise;
      end;
      if vDirY then
      begin
        t6 := vOffsetY shl 8 + vPixelY shl vPrecise;
        t8 := vOffsetY shl 8 +      t2 shl vPrecise;
      end
      else
      begin
        t6 := (vHeight - 1 - vOffsetY) shl 8 - vPixelY shl vPrecise;
        t8 := (vHeight - 1 - vOffsetY) shl 8 -      t2 shl vPrecise;
      end;
      SmoothLine(t5, t6, t7, t8, t3 shl vPrecise shr 1, vPlotColor, t4);
      vPixelX := t1;
      vPixelY := t2;
    end;
    key_circle,                                       // CIRCLE width {linesize {opacity}}
    key_oval,                                         // OVAL width height {linesize {opacity}}
    key_box,                                          // BOX width height {linesize {opacity}}
    key_obox:                                         // OBOX width height xradius yradius {linesize {opacity}}
    begin
      t := val;
      PLOT_GetXY(t1, t2);
      if not KeyVal(t3) then Break;
      if t <> key_circle then
        if not KeyVal(t4) then Break;
      if t = key_obox then
      begin
        if not KeyVal(t5) then Break;
        if not KeyVal(t6) then Break;
      end;
      t7 := 0;
      t8 := vOpacity;
      if KeyVal(t7) then KeyVal(t8);
      case t of
        key_circle: SmoothShape(t1, t2, t3, t3, t3 shr 1, t3 shr 1, t7, vPlotColor, t8);
        key_oval:   SmoothShape(t1, t2, t3, t4, t3 shr 1, t4 shr 1, t7, vPlotColor, t8);
        key_box:    SmoothShape(t1, t2, t3, t4, 0, 0, t7, vPlotColor, t8);
        key_obox:   SmoothShape(t1, t2, t3, t4, t5, t6, t7, vPlotColor, t8);
      end;
    end;
    key_textsize:                                     // TEXTSIZE size
      KeyTextSize;
    key_textstyle:                                    // TEXTSTYLE style
      KeyVal(vTextStyle);
    key_textangle:                                    // TEXTANGLE angle
      if KeyVal(vTextAngle) then MakeTextAngle(vTextAngle);
    key_text:                                         // TEXT {size {style {angle}}} 'string'
    begin
      a[0] := vTextSize;
      a[1] := vTextStyle;
      a[2] := vTextAngle;
      for i := 0 to 2 do if not KeyVal(a[i]) then Break else if i=2 then MakeTextAngle(a[2]);
      if NextStr then s := PChar(val) else Break;
      Bitmap[0].Canvas.Font.Size := a[0];
      Bitmap[0].Canvas.Brush.Style := bsClear;
      Bitmap[0].Canvas.Font.Color := WinRGB(vTextColor);
      PLOT_GetXY(t1, t2);
      AngleTextOut(t1, t2, s, a[1], a[2]);
    end;
    key_layer:                                        // LAYER layer 'filename.bmp'
    begin
      if not KeyValWithin(t1, 1, plot_layermax) then Break;
      if not NextStr then Break;
      if not (FileExists(pChar(val)) and (ExtractFileExt(pChar(val)) = '.bmp')) then Break;
      PlotBitmap[t1 - 1].LoadFromFile(PChar(val));
    end;
    key_crop:                                         // CROP layer {left top width height {x y}}
    begin                                             // CROP layer AUTO x y
      if not KeyValWithin(t1, 1, plot_layermax) then Break;
      t2 := 0;              // layer-bitmap source coordinates
      t3 := 0;
      t4 := PlotBitmap[t1 - 1].Width;
      t5 := PlotBitmap[t1 - 1].Height;
      t6 := 0;              // plot-bitmap destination coordinates
      t7 := 0;
      if KeyIs(key_auto) then
      begin
        if not KeyValWithin(t6, 0, vBitMapWidth) then Break;
        if not KeyValWithin(t7, 0, vBitmapHeight) then Break;
      end
      else
      if KeyValWithin(t2, 0, PlotBitmap[t1 - 1].Width) then
      begin
        if not KeyValWithin(t3, 0, PlotBitmap[t1 - 1].Height) then Break;
        if not KeyValWithin(t4, 0, PlotBitmap[t1 - 1].Width) then Break;
        if not KeyValWithin(t5, 0, PlotBitmap[t1 - 1].Height) then Break;
        t6 := t2;
        t7 := t3;
        if KeyValWithin(t6, 0, vBitMapWidth) then
          if not KeyValWithin(t7, 0, vBitMapHeight) then Break;
      end;
      Bitmap[0].Canvas.CopyRect(Rect(t6, t7, t6 + t4, t7 + t5), PlotBitmap[t1 - 1].Canvas, Rect(t2, t3, t2 + t4, t3 + t5));
    end;
    key_spritedef:                                    // SPRITEDEF id xsize ysize pixels... colors...
    begin
      if not KeyValWithin(t1, 0, SpriteMax - 1) then Break;
      if not KeyValWithin(t2, 1, SpriteMaxX) then Break;
      if not KeyValWithin(t3, 1, SpriteMaxY) then Break;
      SpriteSizeX[t1] := t2;
      SpriteSizeY[t1] := t3;
      for i := 0 to t2 * t3 - 1 do
        if not KeyVal(t4) then Break else SpritePixels[t1 * SpriteMaxX * SpriteMaxY + i] := t4;
      for i := 0 to 255 do
        if not KeyVal(SpriteColors[t1 * 256 + i]) then Break;
    end;
    key_sprite:                                       // SPRITE id {orientation {scale {opacity}}}
    begin
      PLOT_GetXY(t1, t2);
      if not KeyValWithin(t3, 0, SpriteMax - 1) then Break;
      t4 := 0;          // orientation
      t5 := 1;          // scale
      t6 := vOpacity;   // opacity
      if KeyValWithin(t4, 0, 7) then if KeyValWithin(t5, 1, 64) then KeyValWithin(t6, 0, 255);
      t7 := SpriteSizeX[t3];
      t8 := SpriteSizeY[t3];
      if (t7 = 0) or (t8 = 0) then Continue;
      ppixel := PByte(@SpritePixels[t3 * SpriteMaxX * SpriteMaxY]);
      pcolor := PIntegerArray(@SpriteColors[t3 * 256]);
      Inc(t1, t5 shr 1);
      Inc(t2, t5 shr 1);
      for y := 1 to t8 do
        for x := 1 to t7 do
        begin
          c := pcolor[ppixel^]; Inc(ppixel);
          opa := ((c shr 24 and $FF) * t6 + $FF) shr 8;
          if opa <> 0 then
            case t4 of
              0: SmoothShape(t1 +  (x - 1) * t5, t2 +  (y - 1) * t5, t5, t5, 0, 0, 0, c, opa);
              1: SmoothShape(t1 + (t7 - x) * t5, t2 +  (y - 1) * t5, t5, t5, 0, 0, 0, c, opa);
              2: SmoothShape(t1 +  (x - 1) * t5, t2 + (t8 - y) * t5, t5, t5, 0, 0, 0, c, opa);
              3: SmoothShape(t1 + (t7 - x) * t5, t2 + (t8 - y) * t5, t5, t5, 0, 0, 0, c, opa);
              4: SmoothShape(t1 +  (y - 1) * t5, t2 +  (x - 1) * t5, t5, t5, 0, 0, 0, c, opa);
              5: SmoothShape(t1 +  (y - 1) * t5, t2 + (t7 - x) * t5, t5, t5, 0, 0, 0, c, opa);
              6: SmoothShape(t1 + (t8 - y) * t5, t2 +  (x - 1) * t5, t5, t5, 0, 0, 0, c, opa);
              7: SmoothShape(t1 + (t8 - y) * t5, t2 + (t7 - x) * t5, t5, t5, 0, 0, 0, c, opa);
            end;
        end;
    end;
    key_polar:                                        // POLAR {twopi theta}
      KeyTwoPi;
    key_cartesian:                                    // CARTESIAN {flipy {flipx}}
    begin
      vPolar := False;
      if not KeyBool(vDirY) then Continue;
      KeyBool(vDirX);
    end;
    key_clear:                                        // CLEAR
      ClearBitmap;
    key_update:                                       // UPDATE
      BitmapToCanvas(0);
    key_save:                                         // SAVE
      KeySave;
    key_pc_key:                                       // PC_KEY
      SendKeyPress;
    key_pc_mouse:                                     // PC_MOUSE
      SendMousePos;
  end;
  if not vUpdate then BitmapToCanvas(0);
end;

procedure TDebugDisplayForm.PLOT_GetXY(var x, y: integer);
begin
  if vDirX then         // handle direction
    x := vWidth - 1 - vOffsetX - vPixelX
  else
    x := vOffsetX + vPixelX;
  if vDirY then
    y := vOffsetY + vPixelY
  else
    y := vHeight - 1 - vOffsetY - vPixelY;
end;

procedure TDebugDisplayForm.PLOT_Close;
var
  i: integer;
begin
  for i := 0 to plot_layermax - 1 do PlotBitmap[i].Free;
end;


////////////
//  TERM  //
////////////

procedure TDebugDisplayForm.TERM_Configure;
var
  i: integer;
begin
  // Set unique defaults
  vTextSize := FontSize;
  vCols := DefaultCols;
  vRows := DefaultRows;
  vCol := 0;
  vRow := 0;
  for i := 0 to 7 do vColor[i] := DefaultTermColors[i];
  // Process any parameters
  while NextKey do
  case val of
    key_title:
      KeyTitle;
    key_pos:
      KeyPos;
    key_size:
      KeySize(vCols, vRows, term_colmin, term_colmax, term_rowmin, term_rowmax);
    key_textsize:
      KeyTextSize;
    key_color:
      for i := 0 to 7 do if not KeyColor(vColor[i]) then Break;
    key_backcolor:
      KeyColor(vBackColor);
    key_update:
      vUpdate := True;
    key_hidexy:
      vHideXY := True;
  end;
  // Set initial colors
  vTextColor := vColor[0];
  vTextBackColor := vColor[1];
  // Set form metrics
  SetTextMetrics;
  vWidth := vCols * ChrWidth;
  vHeight := vRows * ChrHeight;
  i := ChrWidth div 2;
  SetSize(i, i, i, i);
end;

procedure TDebugDisplayForm.TERM_Update;
var
  i, j: integer;
begin
  vUpdateFlag := False;
  while not NextEnd do
  begin
    if NextKey then
    case val of
      key_clear:                // clear screen and home
      begin
        ClearBitmap;
        vUpdateFlag := True;
        vCol := 0;
        vRow := 0;
      end;
      key_update:               // update bitmap
        BitmapToCanvas(0);
      key_save:                 // save bitmap
        KeySave;
      key_pc_key:               // get key
        SendKeyPress;
      key_pc_mouse:             // get mouse
        SendMousePos;
    end
    else
    begin
      if NextNum then
      case val of
        0:                      // clear screen and home
        begin
          ClearBitmap;
          vUpdateFlag := True;
          vCol := 0;
          vRow := 0;
        end;
        1:                      // home
        begin
          vCol := 0;
          vRow := 0;
        end;
        2:                      // set column
          KeyValWithin(vCol, 0, vCols - 1);
        3:                      // set row
          KeyValWithin(vRow, 0, vRows - 1);
        4..7:                   // set colors
        begin
          vTextColor := vColor[(val - 4) * 2 + 0];
          vTextBackColor := vColor[(val - 4) * 2 + 1];
        end;
        8:                      // backspace
          if (vCol <> 0) or (vRow <> 0) then
          begin
            Dec(vCol);
            if vCol < 0 then
            begin
              vCol := vCols - 1;
              Dec(vRow);
            end;
          end;
        9:                      // tab
        begin
          TERM_Chr(' ');
          while vCol and 7 <> 0 do TERM_Chr(' ');
        end;
        10:                     // new line (10)
          TERM_Chr(Chr(13));
        13:                     // new line (13), ignore trailing linefeed (10)
        begin
          TERM_Chr(Chr(13));
          if NextNum then if val <> 10 then Dec(ptr)
        end;
        32..255:                // printable chr
          TERM_Chr(Chr(val));
      end
      else
      if NextStr then
      begin                     // string
        j := Length(PChar(val));
        if j <> 0 then for i := 0 to j - 1 do TERM_Chr(PChar(val)[i]);
      end;
    end;
  end;
  if not vUpdate and vUpdateFlag then BitmapToCanvas(0);
end;

procedure TDebugDisplayForm.TERM_Chr(c: Char);
var
  x, y: integer;
  r, r2: TRect;
begin
  if c = Chr(13) then
  begin
    if vRow <> vRows - 1 then
      Inc(vRow)
    else
    begin
      r := Rect(vMarginLeft, vMarginTop, vMarginLeft + vCols * ChrWidth, vMarginTop + (vRows - 1) * ChrHeight);
      r2 := Rect(r.Left, r.Top + ChrHeight, r.Right, r.Bottom + ChrHeight);
      Bitmap[0].Canvas.CopyRect(r, Bitmap[0].Canvas, r2);
      Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
      r := Rect(r.Left, r.Bottom, r.Right, r2.Bottom);
      Bitmap[0].Canvas.FillRect(r);
      vUpdateFlag := True;
    end;
    vCol := 0;
  end
  else
  begin
    if vCol = vCols then TERM_Chr(Chr(13));
    x := vMarginLeft + vCol * ChrWidth;
    y := vMarginTop + vRow * ChrHeight;
    r := Rect(x, y, x + ChrWidth, y + ChrHeight);
    Bitmap[0].Canvas.Font.Color := WinRGB(vTextColor);
    Bitmap[0].Canvas.Brush.Color := WinRGB(vTextBackColor);
    Bitmap[0].Canvas.TextRect(r, x, y, c);
    Inc(vCol);
    if not vUpdate then   // if not update mode then copy Bitmap[0] rectangle to Bitmap[1] and Canvas
    begin
      Bitmap[1].Canvas.CopyRect(r, Bitmap[0].Canvas, r);
      Canvas.CopyRect(r, Bitmap[0].Canvas, r);
    end;
  end;
end;


//////////////
//  BITMAP  //
//////////////

// Trace modes
// ---------------------------------------------------------------------
// %000: top line, left-to-right      x++, y++      +%1000: scroll down
// %001: top line, right-to left      x--, y++      +%1000: scroll down
// %010: bottom line, left-to-right   x++, y--      +%1000: scroll up
// %011: bottom line, right-to-left   x--, y--      +%1000: scroll up
// %100: left line, top-to-bottom     y++, x++      +%1000: scroll right
// %101: left line, bottom-to-top     y--, x++      +%1000: scroll right
// %110: right line, top-to-bottom    y++, x--      +%1000: scroll left
// %111: right line, bottom-to-top    y--, x--      +%1000: scroll left

procedure TDebugDisplayForm.BITMAP_Configure;
begin
  // Set unique defaults
  vTrace := 0;
  vDotSize := 1;
  vDotSizeY := 1;
  // Process any parameters
  while NextKey do
  case val of
    key_title:
      KeyTitle;
    key_pos:
      KeyPos;
    key_size:
      KeySize(vWidth, vHeight, bitmap_wmin, bitmap_wmax, bitmap_hmin, bitmap_hmax);
    key_dotsize:
      if KeyValWithin(vDotSize, 1, 256) then
      begin
        vDotSizeY := vDotSize;
        KeyValWithin(vDotSizeY, 1, 256);
      end;
    key_sparse:
      KeyColor(vSparse);
    key_lut1..key_rgb24:
      KeyColorMode;
    key_lutcolors:
      KeyLutColors;
    key_trace:
      KeyVal(vTrace);
    key_rate:
      KeyVal(vRate);
    key_longs_1bit..key_bytes_4bit:
      KeyPack;
    key_update:
      vUpdate := True;
    key_hidexy:
      vHideXY := True;
  end;
  // Set form metrics
  SetSize(0, 0, 0, 0);
  SetTrace(vTrace, vRate = 0);
  if vRate = -1 then vRate := vWidth * vHeight;
end;

procedure TDebugDisplayForm.BITMAP_Update;
var
  i, v, x, y: integer;
begin
  while not NextEnd do
  begin
    if NextStr then Break;   // string not allowed
    if NextKey then
    case val of
      key_lut1..key_rgb24:
        KeyColorMode;
      key_lutcolors:
        KeyLutColors;
      key_trace:
        if NextNum then SetTrace(val, True);
      key_rate:
        KeyVal(vRate);
      key_set:
      begin
        vTrace := vTrace and 7;   // cancel scrolling
        if KeyValWithin(vPixelX, 0, vWidth - 1) then
          KeyValWithin(vPixelY, 0, vHeight - 1);
      end;
      key_scroll:
        if KeyValWithin(x, -vWidth, vWidth) then
          if KeyValWithin(y, -vHeight, vHeight) then
            ScrollBitmap(x, y);
      key_clear:
      begin
        ClearBitmap;
        if not vUpdate then BitmapToCanvas(0);
        SetTrace(vTrace, True);
      end;
      key_update:
        BitmapToCanvas(0);
      key_save:
        KeySave;
      key_pc_key:
        SendKeyPress;
      key_pc_mouse:
        SendMousePos;
    end
    else
    while NextNum do
    begin
      // Get channel sample(s)
      v := NewPack;
      for i := 1 to vPackCount do
      begin
        // Plot sample
        if vSparse = -1 then
          PlotPixel(UnPack(v))                          // normal pixel
        else
        begin
          x := vPixelX * vDotSize + vDotSize shr 1;     // sparse pixel
          y := vPixelY * vDotSizeY + vDotSizeY shr 1;
          SmoothShape(x, y,
                      vDotSize, vDotSizeY,
                      0, 0, 0, vSparse, 255);
          SmoothShape(x, y,
                      vDotSize - vDotSize shr 2, vDotSizeY - vDotSizeY shr 2,
                      vDotSize, vDotSizeY,
                      0, TranslateColor(UnPack(v), vColorMode), 255);
        end;
        if RateCycle and not vUpdate then BitmapToCanvas(0);
        StepTrace;
      end;
    end;
  end;
end;


////////////
//  MIDI  //
////////////

procedure TDebugDisplayForm.MIDI_Configure;
var
  border, i, x, note, whitekeys, tweak, left, right, bottom: integer;
  black: boolean;
begin
  // Set unique defaults
  MidiSize := 4;
  MidiKeyFirst := 21;
  MidiKeyLast := 108;
  MidiChannel := 0;
  vColor[0] := clCyan;
  vColor[1] := clMagenta;
  MidiState := 0;
  // Process any parameters
  while NextKey do
  case val of
    key_title:
      KeyTitle;
    key_pos:
      KeyPos;
    key_size:
      KeyValWithin(MidiSize, 1, 50);
    key_range:
      if KeyValWithin(MidiKeyFirst, 0, 127) then
      begin
        MidiKeyLast := MidiKeyFirst;
        KeyValWithin(MidiKeyLast, MidiKeyFirst, 127);
      end;
    key_channel:
      KeyValWithin(MidiChannel, 0, 15);
    key_color:
      if KeyColor(vColor[0]) then
        KeyColor(vColor[1]);
  end;
  // Set piano keyboard metrics
  MidiKeySize := MidiSizeBase + MidiSize * MidiSizeFactor;
  vTextSize := MidiKeySize div 3;
  SetTextMetrics;
  border := MidiKeySize div ((MidiSizeBase + MidiSizeFactor) div 2);   // border >= 2
  x := border;
  note := 0;
  whitekeys := 0;
  for i := 0 to 127 do
  begin
    case note of
      0:   tweak := 10;    // C  white
      1:   tweak := -2;    // C# black
      2:   tweak := 16;    // D  white
      3:   tweak :=  2;    // D# black
      4:   tweak := 22;    // E  white
      5:   tweak :=  9;    // F  white
      6:   tweak := -4;    // F# black
      7:   tweak := 14;    // G  white
      8:   tweak :=  0;    // G# black
      9:   tweak := 18;    // A  white
      10:  tweak :=  4;    // A# black
      11:  tweak := 23;    // B  white
    end;
    black := note in [1, 3, 6, 8, 10];
    if black then
    begin
      left := x - (MidiKeySize * (10 - tweak) + 16) div 32;
      right := left + MidiKeySize * 20 div 32;
      bottom := MidiKeySize * 4;
      MidiNumX[i] := (left + right + 1) div 2;
    end
    else
    begin
      left := x;
      right := left + MidiKeySize;
      bottom := MidiKeySize * 6;
      MidiNumX[i] := x + (MidiKeySize * tweak + 16) div 32;
      Inc(x, MidiKeySize);
    end;
    MidiBlack[i] := black;
    MidiLeft[i] := left;
    MidiRight[i] := right;
    MidiBottom[i] := bottom;
    if note = 11 then note := 0 else Inc(note);
    if not black and (i in [MidiKeyFirst..MidiKeyLast]) then Inc(whitekeys);
  end;
  // if first key black, make white-key space to its left
  if MidiBlack[MidiKeyFirst] then
  begin
    MidiOffset := MidiLeft[MidiKeyFirst - 1] - border;
    Inc(whitekeys);
  end
  else
    MidiOffset := MidiLeft[MidiKeyFirst] - border;
  // if last key black, make white-key space to its right
  if MidiBlack[MidiKeyLast] then Inc(whitekeys);
  // Set form metrics
  vWidth := MidiKeySize * whitekeys + border * 2;
  vHeight := MidiKeySize * 6 + border;
  SetSize(0, 0, 0, 0);
  MIDI_Draw(True);
end;

procedure TDebugDisplayForm.MIDI_Update;
begin
  while not NextEnd do
  begin
    if NextStr then Break;      // string not allowed
    if NextKey then
    case val of
      key_clear:
        MIDI_Draw(True);
      key_save:
        KeySave;
      key_pc_key:
        SendKeyPress;
      key_pc_mouse:
        SendMousePos;
    end
    else
    while NextNum do
    begin
      // Process byte, msb forces command state
      val := val and $FF;
      if val and $80 <> 0 then MidiState := 0;
      case MidiState of
        0:   // wait for note-on or note-off event
        begin
          if (val and $F0 = $90) and (val and $0F = MidiChannel) then MidiState := 1;    // note-on event
          if (val and $F0 = $80) and (val and $0F = MidiChannel) then MidiState := 3;    // note-off event
        end;
        1:   // note-on, get note
        begin
          MidiNote := val;
          MidiState := 2;
        end;
        2:   // note-on, get velocity
        begin
          MidiVelocity[MidiNote] := val;
          MidiState := 1;
          MIDI_Draw(False);
        end;
        3:   // note-off, get note
        begin
          MidiNote := val;
          MidiState := 4;
        end;
        4:   // note-off, get velocity
        begin
          MidiVelocity[MidiNote] := -val;
          MidiState := 3;
          MIDI_Draw(False);
        end;
      end;
    end;
  end;
end;

procedure TDebugDisplayForm.MIDI_Draw(Clear: boolean);
var
  i, r: integer;
begin
  if Clear then for i := 0 to 127 do MidiVelocity[i] := 0;
  Bitmap[0].Canvas.Pen.Width := 1;
  Bitmap[0].Canvas.Pen.Color := clGray2;
  Bitmap[0].Canvas.Brush.Color := clInactiveCaption;
  Bitmap[0].Canvas.FillRect(Rect(0, 0, vWidth, vHeight));
  r := MidiKeySize div 4;
  // draw white keys first
  Bitmap[0].Canvas.Font.Color := clGray3;
  for i := MidiKeyFirst to MidiKeyLast do
    if not MidiBlack[i] then MIDI_DrawKey(i, clWhite, vColor[0], r);
  // draw black keys last since they overlap white keys
  Bitmap[0].Canvas.Font.Color := clGray2;
  for i := MidiKeyFirst to MidiKeyLast do
    if MidiBlack[i] then MIDI_DrawKey(i, clBlack, vColor[1], r);
  // update display
  BitmapToCanvas(0);
end;

procedure TDebugDisplayForm.MIDI_DrawKey(i, OffColor, OnColor, r: integer);
begin
  // draw plain key
  Bitmap[0].Canvas.Brush.Color := WinRGB(OffColor);
  Bitmap[0].Canvas.RoundRect(MidiLeft[i] - MidiOffset, -r, MidiRight[i] - MidiOffset, MidiBottom[i], r, r);
  // colorize key to show velocity
  if MidiVelocity[i] > 0 then
  begin
    Bitmap[0].Canvas.Brush.Color := WinRGB(OnColor);
    Bitmap[0].Canvas.RoundRect(MidiLeft[i] - MidiOffset,
      MidiBottom[i] - r - (MidiBottom[i] - r) * MidiVelocity[i] div 127,
      MidiRight[i] - MidiOffset, MidiBottom[i], r, r);
  end;
  Bitmap[0].Canvas.Brush.Style := bsClear;
  AngleTextOut(MidiNumX[i] - MidiOffset, ChrWidth, IntToStr(i), $20, -900);
end;


/////////////////
//  Key Helps  //
/////////////////

procedure TDebugDisplayForm.KeyTitle;
begin
  if NextStr then SetCaption(PChar(val));
end;

function TDebugDisplayForm.KeyVal(var v: integer): boolean;
begin
  Result := True;
  if NextNum then v := val else Result := False;
end;

function TDebugDisplayForm.KeyBool(var v: boolean): boolean;
begin
  Result := True;
  if NextNum then v := val <> 0 else Result := False;
end;

function TDebugDisplayForm.KeyValWithin(var v: integer; bottom, top: integer): boolean;
begin
  Result := True;
  if NextNum then v := Within(val, bottom, top) else Result := False;
end;

procedure TDebugDisplayForm.KeyPos;
begin
  if NextNum then Left := val + P2.DebugDisplayLeft else Exit;
  if NextNum then Top := val + P2.DebugDisplayTop;
end;

procedure TDebugDisplayForm.KeySize(var x, y: integer; wmin, wmax, hmin, hmax: integer);
begin
  if KeyValWithin(x, wmin, wmax) then
    KeyValWithin(y, hmin, hmax);
end;

function TDebugDisplayForm.KeyIs(keyval: integer): boolean;
begin
  Result := False;
  if NextKey then
  begin
    if val = keyval then
      Result := True
    else
      Dec(ptr);
  end;
end;

procedure TDebugDisplayForm.KeyTwoPi;
begin
  vPolar := True;
  vTwoPi := $100000000;
  vTheta := 0;
  if NextNum then
  begin
    case val of
       -1: vTwoPi := -$100000000;
        0: vTwoPi := $100000000;
      else vTwoPi := val;
    end;
    KeyVal(vTheta);
  end;
end;

function TDebugDisplayForm.KeyColor(var c: integer): boolean;
var
  h, p: integer;
begin
  Result := False;
  if NextKey then
  begin
    if not (val in [key_black..key_gray]) then
    begin
      Dec(ptr);
      Exit;
    end;
    if val = key_black then
      c := $000000
    else
    if val = key_white then
      c := $FFFFFF
    else
    begin
      h := val - key_orange;
      p := 8;
      if NextNum then p := val and 15;
      c := TranslateColor(h shl 5 or p shl 1, key_rgbi8x);
    end;
  end
  else
  begin
    if not NextNum then Exit;
    c := TranslateColor(val, vColorMode);
  end;
  Result := True;
end;

procedure TDebugDisplayForm.KeyColorMode;
begin
  vColorMode := val;
  if val in [key_luma8..key_luma8x] then
  begin
    if NextKey then
    begin
      if not (val in [key_orange..key_gray]) then
      begin
        Dec(ptr);
        Exit;
      end;
      vColorTune := val - key_orange;
    end
    else
      KeyVal(vColorTune);
  end
  else if val in [key_hsv8..key_hsv8x, key_hsv16..key_hsv16x] then
    KeyVal(vColorTune);
end;

procedure TDebugDisplayForm.KeyLutColors;
var
  m, i: integer;
begin
  m := vColorMode;           // save color mode
  vColorMode := key_rgb24;   // lut colors are rgb24 values
  for i := 0 to $FF do       // get lut colors
    if not KeyColor(vLut[i]) then Break;
  vColorMode := m;           // restore color mode
end;

procedure TDebugDisplayForm.KeyPack;
var
  v: integer;
  alt, signx: boolean;
begin
  v := val;
  alt := False;
  signx := False;
  if NextKey and (val in [key_alt, key_signed]) then
  begin
    if val = key_alt then alt := True else signx := True;
    if NextKey and (val in [key_alt, key_signed]) then
      if val = key_alt then alt := True else signx := True;
  end;
  SetPack(v, alt, signx);
end;

procedure TDebugDisplayForm.KeyTextSize;
begin
  KeyValWithin(vTextSize, 6, 200);
end;

procedure TDebugDisplayForm.KeySave;
var
  l, t, w, h: integer;
begin
  if NextStr then Bitmap[1].SaveToFile(PChar(val) + '.bmp')
  else
  begin
    if NextKey then
    begin
      if val <> key_window then Exit;
      l := Left;
      t := Top;
      w := Width;
      h := Height;
    end
    else
    begin
      if not KeyVal(l) then Exit;
      if not KeyVal(t) then Exit;
      if not KeyVal(w) then Exit;
      if not KeyVal(h) then Exit;
    end;
    DesktopBitmap.Width := w;
    DesktopBitmap.Height := h;
    BitBlt(DesktopBitmap.Canvas.Handle, 0, 0, w, h, DesktopDC, l, t, SRCCOPY);
    if NextStr then DesktopBitmap.SaveToFile(PChar(val) + '.bmp');
  end;
end;


/////////////////////////////
//  Display Configuration  //
/////////////////////////////

procedure TDebugDisplayForm.SetCaption(s: string);
begin
  Caption := s;
  CaptionStr := s;
  CaptionPos := False;
end;

procedure TDebugDisplayForm.SetDefaults;
var
  i: integer;
begin
  vWidth := 256;
  vHeight := 256;
  vSamples := 256;
  vIndex := 0;
  for i := 0 to Channels - 1 do vColor[i] := DefaultScopeColors[i];
  vColorMode := key_rgb24;
  vColorTune := 0;
  vBackColor := DefaultBackColor;
  vGridColor := DefaultGridColor;
  vLineSize := DefaultLineSize;
  vTextSize := DefaultTextSize;
  vTextStyle := DefaultTextStyle;
  vTextAngle := 0;
  vLogScale := False;
  vUpdate := False;
  vHideXY := False;
  vPixelX := 0;
  vPixelY := 0;
  vRate := 0;
  vRateCount := 0;
  vHoldOff := 0;
  vHoldOffCount := 0;
  SamplePtr := 0;
  SamplePop := 0;
  vPolar := False;
  vTwoPi := $100000000;
  vTheta := 0;
  vSparse := -1;
  vMouseWheel := 0;
  vKeyPress := 0;
  for i := 0 to Channels - 1 do vLabel[i] := '';
  SetPack(0, False, False);
  SmoothFillSize := -1;
end;

procedure TDebugDisplayForm.SetTextMetrics;
begin
  Bitmap[0].Canvas.Font.Size := vTextSize;
  ChrWidth := Bitmap[0].Canvas.TextWidth('X');
  ChrHeight := Bitmap[0].Canvas.TextHeight('X');
end;

procedure TDebugDisplayForm.SetSize(MarginLeft, MarginTop, MarginRight, MarginBottom: integer);
var
  i: integer;
begin
  vMarginLeft := MarginLeft;
  vMarginTop := MarginTop;
  vMarginRight := MarginRight;
  vMarginBottom := MarginBottom;
  if DisplayType in [dis_spectro, dis_plot, dis_bitmap] then
  begin
    ClientWidth := vWidth * vDotSize;
    ClientHeight := vHeight * vDotSizeY;
    if (vSparse <> -1) and (vDotSize >= 4) and (vDotSizeY >= 4) then
    begin
      Bitmap[1].Width := ClientWidth;
      Bitmap[1].Height := ClientHeight;
      Bitmap[0].Width := ClientWidth;
      Bitmap[0].Height := ClientHeight;
    end
    else
    begin
      vSparse := -1;
      Bitmap[1].Width := vWidth;
      Bitmap[1].Height := vHeight;
      Bitmap[0].Width := vWidth;
      Bitmap[0].Height := vHeight;
    end
  end
  else
  begin
    ClientWidth := vMarginLeft + vWidth + vMarginRight;
    ClientHeight := vMarginTop + vHeight + vMarginBottom;
    Bitmap[1].Width := ClientWidth;
    Bitmap[1].Height := ClientHeight;
    Bitmap[0].Width := ClientWidth;
    Bitmap[0].Height := ClientHeight;
  end;
  vBitmapWidth := Bitmap[0].Width;
  vBitmapHeight := Bitmap[0].Height;
  vClientWidth := ClientWidth;
  vClientHeight := ClientHeight;
  for i := 0 to vBitmapHeight - 1 do BitmapLine[i] := Bitmap[0].ScanLine[i];
  // Clear bitmap
  vTriggered := False;    // don't draw trigger indicator
  ClearBitmap;
end;

procedure TDebugDisplayForm.SetTrace(Path: integer; ModifyRate: boolean);
begin
  if Path and 7 in [0, 2, 4, 5] then vPixelX := 0 else vPixelX := vWidth - 1;
  if Path and 7 in [0, 1, 4, 6] then vPixelY := 0 else vPixelY := vHeight - 1;
  if ModifyRate then
    if Path and 7 in [0, 1, 2, 3] then vRate := vWidth else vRate := vHeight;
  vTrace := Path and $F;
end;

procedure TDebugDisplayForm.StepTrace;
var
  Scroll: boolean;
begin
  Scroll := vTrace and 8 <> 0;
  case vTrace and 7 of
    0:
    begin
      if vPixelX <> vWidth - 1 then Inc(vPixelX) else
      begin
        vPixelX := 0;
        if Scroll then ScrollBitmap(0, 1)
        else if vPixelY <> vHeight - 1 then Inc(vPixelY) else vPixelY := 0;
      end;
    end;
    1:
    begin
      if vPixelX <> 0 then Dec(vPixelX) else
      begin
        vPixelX := vWidth - 1;
        if Scroll then ScrollBitmap(0, 1)
        else if vPixelY <> vHeight - 1 then Inc(vPixelY) else vPixelY := 0;
      end;
    end;
    2:
    begin
      if vPixelX <> vWidth - 1 then Inc(vPixelX) else
      begin
        vPixelX := 0;
        if Scroll then ScrollBitmap(0, -1)
        else if vPixelY <> 0 then Dec(vPixelY) else vPixelY := vHeight - 1;
      end;
    end;
    3:
    begin
      if vPixelX <> 0 then Dec(vPixelX) else
      begin
        vPixelX := vWidth - 1;
        if Scroll then ScrollBitmap(0, -1)
        else if vPixelY <> 0 then Dec(vPixelY) else vPixelY := vHeight - 1;
      end;
    end;
    4:
    begin
      if vPixelY <> vHeight - 1 then Inc(vPixelY) else
      begin
        vPixelY := 0;
        if Scroll then ScrollBitmap(1, 0)
        else if vPixelX <> vWidth - 1 then Inc(vPixelX) else vPixelX := 0;
      end;
    end;
    5:
    begin
      if vPixelY <> 0 then Dec(vPixelY) else
      begin
        vPixelY := vHeight - 1;
        if Scroll then ScrollBitmap(1, 0)
        else if vPixelX <> vWidth - 1 then Inc(vPixelX) else vPixelX := 0;
      end;
    end;
    6:
    begin
      if vPixelY <> vHeight - 1 then Inc(vPixelY) else
      begin
        vPixelY := 0;
        if Scroll then ScrollBitmap(-1, 0)
        else if vPixelX <> 0 then Dec(vPixelX) else vPixelX := vWidth - 1;
      end;
    end;
    7:
    begin
      if vPixelY <> 0 then Dec(vPixelY) else
      begin
        vPixelY := vHeight - 1;
        if Scroll then ScrollBitmap(-1, 0)
        else if vPixelX <> 0 then Dec(vPixelX) else vPixelX := vWidth - 1;
      end;
    end;
  end;
end;

procedure TDebugDisplayForm.PolarToCartesian(var rho_x, theta_y: integer);
var
  Tf, Xf, Yf: extended;
begin
  Tf := (Int64(theta_y) + Int64(vTheta)) / vTwoPi * Pi * 2;
  SinCos(Tf, Yf, Xf);
  theta_y := Round(Yf * rho_x);
  rho_x := Round(Xf * rho_x);
end;

procedure TDebugDisplayForm.MakeTextAngle(var a: integer);
begin
  if vPolar then a := Round(val mod vTwoPi / vTwoPi * 3600)
  else a := val mod 360 * 10;
end;

function TDebugDisplayForm.RateCycle: boolean;
begin
  Inc(vRateCount);
  if vRateCount = vRate then
  begin
    vRateCount := 0;
    Result := True;
  end
  else Result := False;
end;

function TDebugDisplayForm.TranslateColor(p, mode: integer): integer;
var
  v: integer;
  w: boolean;
begin
  // translate pixel to rgb24
  case mode of
    key_lut1:
      p := vLut[p and $01];
    key_lut2:
      p := vLut[p and $03];
    key_lut4:
      p := vLut[p and $0F];
    key_lut8:
      p := vLut[p and $FF];
    key_luma8,
    key_luma8w,
    key_luma8x,
    key_rgbi8,
    key_rgbi8w,
    key_rgbi8x:
    begin
      if mode in [key_luma8, key_luma8w, key_luma8x] then
      begin
        v := vColorTune and 7;
        p := p and $FF;
      end
      else
      begin
        v := p shr 5 and 7;
        p := p and $1F shl 3 or p and $1C shr 2;
      end;
      w := (mode in [key_luma8w, key_rgbi8w]) or (mode in [key_luma8x, key_rgbi8x]) and (v <> 7) and (p >= $80);
      if (mode in [key_luma8x, key_rgbi8x]) and (v <> 7) then if (p >= $80) then p := not p and $7F shl 1 else p := p shl 1;
      if w then
      begin   // from white to color
        if v = 0 then p := (p shl 7 and $007F00 or p) xor $FFFFFF    // orange
        else
        begin
          if v <> 7 then v := v xor 7;
          p := (v shr 2 and 1 * p shl 16 or
                v shr 1 and 1 * p shl 8  or
                v shr 0 and 1 * p shl 0) xor $FFFFFF;
        end;
      end
      else
      begin  // from black to color
        if v = 0 then p := p shl 16 or p shl 7 and $007F00    // orange
        else p := v shr 2 and 1 * p shl 16 or
                  v shr 1 and 1 * p shl 8  or
                  v shr 0 and 1 * p shl 0;
      end;
    end;
    key_hsv8,
    key_hsv8w,
    key_hsv8x,
    key_hsv16,
    key_hsv16w,
    key_hsv16x:
    begin
      if mode in [key_hsv8, key_hsv8w, key_hsv8x] then p := p and $F0 * $110 or p and $0F * $11;
      v := PolarColors[(p shr 8 + vColorTune) and $FF];
      p := p and $FF;
      w := (mode in [key_hsv8w, key_hsv16w]) or (mode in [key_hsv8x, key_hsv16x]) and (p >= $80);
      if mode in [key_hsv8x, key_hsv16x] then if (p >= $80) then p := p and $7F shl 1 xor $FE else p := p shl 1;
      if w then v := v xor $FFFFFF;
      p := (v shr 16 and $FF * p + $FF) shr 8 shl 16 or
           (v shr  8 and $FF * p + $FF) shr 8 shl  8 or
           (v shr  0 and $FF * p + $FF) shr 8 shl  0;
      if w then p := p xor $FFFFFF;
    end;
    key_rgb8:
      p := p and $E0 * $1236E and $FF0000 or
           p and $1C *   $91C and $00FF00 or
           p and $03 *    $55 and $0000FF;
    key_rgb16:
      p := p and $F800 shl 8 or p and $E000 shl 3 or
           p and $07E0 shl 5 or p and $0600 shr 1 or
           p and $001F shl 3 or p and $001C shr 2;
    key_rgb24:
      p := p and $00FFFFFF;
  end;
  Result := p;
end;

function TDebugDisplayForm.WinRGB(p: integer): integer;
begin
  Result := (p and $FF0000 shr 16) or (p and $00FF00) or (p and $0000FF shl 16);
end;

function TDebugDisplayForm.GetBackground: integer;
begin
  if DisplayType in [dis_spectro, dis_bitmap] then
  case vColorMode of
    key_lut1..key_lut8:
      Result := vLut[0];
    key_luma8,
    key_luma8x,
    key_hsv8,
    key_hsv8x,
    key_rgbi8,
    key_rgbi8x,
    key_rgb8,
    key_hsv16,
    key_hsv16x,
    key_rgb16,
    key_rgb24:
      Result := clBlack;
    key_luma8w,
    key_hsv8w,
    key_rgbi8w,
    key_hsv16w:
      Result := clWhite;
  end
  else Result := vBackColor;
end;

procedure TDebugDisplayForm.SetPolarColors;
const
  tuning = -7.2;  // starts colors exactly at red
var
  i, j: integer;
  k: extended;
  v: array [0..2] of integer;
begin
  for i := 0 to 255 do
  begin
    for j := 0 to 2 do
    begin
      k := i + tuning + j * 256 / 3;
      if k >= 256 then k := k - 256;
      if      k < 256 * 2/6 then v[j] := 0
      else if k < 256 * 3/6 then v[j] := Round((k - 256 * 2/6) / (256 * 3/6 - 256 * 2/6) * 255)
      else if k < 256 * 5/6 then v[j] := 255
      else                       v[j] := Round((256 * 6/6 - k) / (256 * 6/6 - 256 * 5/6) * 255);
    end;
    PolarColors[i] := v[2] shl 16 or v[1] shl 8 or v[0];
  end;
end;


////////////////////////
//  Display Routines  //
////////////////////////

procedure TDebugDisplayForm.ClearBitmap;
var
  i, x, y, w, color: integer;
  s: string;
begin
  Bitmap[0].Canvas.Brush.Color := WinRGB(GetBackground);
  Bitmap[0].Canvas.FillRect(Rect(0, 0, vBitmapWidth, vBitmapHeight));
  Bitmap[0].Canvas.Pen.Color := WinRGB(vGridColor);
  Bitmap[0].Canvas.Pen.Width := 1;
  case DisplayType of
    dis_logic:
    begin
      // Draw frame
      Bitmap[0].Canvas.Brush.Color := WinRGB(vGridColor);
      Bitmap[0].Canvas.FrameRect(Rect(vMarginLeft, vMarginTop - ChrHeight shr 3 + 1,
        vMarginLeft + vWidth + 1, vMarginTop + vHeight + ChrHeight shr 3 + 1));
      // Draw individual channel labels
      Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
      Bitmap[0].Canvas.Font.Style := [fsBold, fsItalic];
      y := vMarginTop + vHeight - ChrHeight;
      for i := 0 to vLogicIndex - 1 do
      begin
        x := vMarginLeft - (Length(vLogicLabel[i]) + 1) * ChrWidth;
        Bitmap[0].Canvas.Font.Color := WinRGB(vLogicColor[i]);
        Bitmap[0].Canvas.TextOut(x, y, vLogicLabel[i]);
        Dec(y, ChrHeight);
      end;
      // Draw trigger indicator
      if vTriggered then
      begin
        Bitmap[0].Canvas.Pen.Width := 1;
        Bitmap[0].Canvas.Pen.Style := psDot;
        vToggle := not vToggle;
        if vToggle then
        begin
          Bitmap[0].Canvas.Pen.Color := WinRGB(vGridColor);
          Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
        end
        else
        begin
          Bitmap[0].Canvas.Pen.Color := WinRGB(vBackColor);
          Bitmap[0].Canvas.Brush.Color := WinRGB(vGridColor);
        end;
        x := vBitmapWidth - vMarginRight - vTriggerOffset * vSpacing;
        Bitmap[0].Canvas.MoveTo(x, vMarginTop + 1);
        Bitmap[0].Canvas.LineTo(x, vMarginTop + vHeight);
        Bitmap[0].Canvas.Pen.Style := psSolid;
      end;
    end;
    dis_scope, dis_fft:
    begin
      // Draw frame
      Bitmap[0].Canvas.Brush.Color := WinRGB(vGridColor);
      Bitmap[0].Canvas.FrameRect(Rect(vMarginLeft - 1, vMarginTop - 1,
        vMarginLeft + vWidth + 1, vMarginTop + vHeight + 1));
      // Draw gridlines
      for i := 0 to Channels - 1 do if vGrid[i] <> 0 then
      begin
        color := AlphaBlend(vColor[i], vBackColor, $40);
        Bitmap[0].Canvas.Pen.Width := 1;
        Bitmap[0].Canvas.Pen.Style := psDot;
        Bitmap[0].Canvas.Pen.Color := WinRGB(color);
        Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
        if (vGrid[i] and 1) <> 0 then
        begin
          y := vMarginTop + vHeight - vBase[i] - 1;
          Bitmap[0].Canvas.MoveTo(vMarginLeft, y);
          Bitmap[0].Canvas.LineTo(vMarginLeft + vWidth, y);
        end;
        if (vGrid[i] and 2) <> 0 then
        begin
          y := vMarginTop + vHeight - vBase[i] - vTall[i];
          Bitmap[0].Canvas.MoveTo(vMarginLeft, y);
          Bitmap[0].Canvas.LineTo(vMarginLeft + vWidth, y);
        end;
        if (vGrid[i] and 4) <> 0 then
        begin
          y := vMarginTop + vHeight - vBase[i] - 1;
          Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
          Bitmap[0].Canvas.Font.Color := WinRGB(color);
          Bitmap[0].Canvas.Font.Style := [];
          if vLow[i] < vHigh[i] then x := vLow[i] else x := vHigh[i];
          if x >= 0 then s := '+' + IntToStr(x) else s := IntToStr(x);
          w := Bitmap[0].Canvas.TextWidth(s);
          Bitmap[0].Canvas.FillRect(Rect(vMarginLeft, y - 1, vMarginLeft + w + ChrWidth, y + 1));
          Bitmap[0].Canvas.TextOut(vMarginLeft + ChrWidth div 2, y - ChrHeight div 2, s)
        end;
        if (vGrid[i] and 8) <> 0 then
        begin
          y := vMarginTop + vHeight - vBase[i] - vTall[i];
          Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
          Bitmap[0].Canvas.Font.Color := WinRGB(color);
          Bitmap[0].Canvas.Font.Style := [];
          if vLow[i] < vHigh[i] then x := vHigh[i] else x := vLow[i];
          if x >= 0 then s := '+' + IntToStr(x) else s := IntToStr(x);
          w := Bitmap[0].Canvas.TextWidth(s);
          Bitmap[0].Canvas.FillRect(Rect(vMarginLeft, y - 1, vMarginLeft + w + ChrWidth, y + 1));
          Bitmap[0].Canvas.TextOut(vMarginLeft + ChrWidth div 2, y - ChrHeight div 2, s)
        end;
        Bitmap[0].Canvas.Pen.Style := psSolid;
      end;
      // Draw trigger indicator for scope
      if (DisplayType = dis_scope) and vTriggered then
      begin
        Bitmap[0].Canvas.Pen.Width := 1;
        Bitmap[0].Canvas.Pen.Style := psDot;
        i := AlphaBlend(vColor[vTriggerChannel], vBackColor, $80);
        vToggle := not vToggle;
        if vToggle then
        begin
          Bitmap[0].Canvas.Pen.Color := WinRGB(i);
          Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
        end
        else
        begin
          Bitmap[0].Canvas.Pen.Color := WinRGB(vBackColor);
          Bitmap[0].Canvas.Brush.Color := WinRGB(i);
        end;
        x := vBitmapWidth - vMarginRight - Round((vTriggerOffset + 1) / vSamples * vWidth);
        Bitmap[0].Canvas.MoveTo(x, vMarginTop);
        Bitmap[0].Canvas.LineTo(x, vMarginTop + vHeight);
        Bitmap[0].Canvas.Pen.Style := psSolid;
      end;
      // Draw logscale for FFT
      if (DisplayType = dis_fft) and vLogScale then
      begin
        Bitmap[0].Canvas.Font.Style := [];
        Bitmap[0].Canvas.Font.Color := WinRGB(vGridColor);
        s := 'logscale';
        Bitmap[0].Canvas.TextOut(vBitmapWidth - 1 - vMarginRight - Length(s) * ChrWidth, ChrHeight div 2, s);
      end;
      // Draw channel names
      Bitmap[0].Canvas.Brush.Color := WinRGB(vBackColor);
      Bitmap[0].Canvas.Font.Style := [fsBold, fsItalic];
      x := vMarginLeft;
      y := ChrHeight div 2;
      for i := 0 to Channels - 1 do if vLabel[i] <> '' then
      begin
        w := Bitmap[0].Canvas.TextWidth(vLabel[i]);
        if x + w > vMarginLeft + vWidth then
        begin
          x := vMarginLeft;
          y := y + vMarginTop + vHeight;
        end;
        Bitmap[0].Canvas.Font.Color := WinRGB(vColor[i]);
        Bitmap[0].Canvas.TextOut(x, y, vLabel[i]);
        x := x + w + ChrWidth * 2;
      end;
    end;
    dis_scope_xy:
    begin
      // Draw grid
      SmoothShape(vMarginLeft + vWidth shr 1, vMarginTop + vHeight shr 1,
        vWidth + 1, vHeight + 1, vWidth, vHeight, 1, vGridColor, 255);
      Bitmap[0].Canvas.MoveTo(vMarginLeft + vWidth div 2, 0);
      Bitmap[0].Canvas.LineTo(vMarginLeft + vWidth div 2, vBitmapHeight);
      Bitmap[0].Canvas.MoveTo(0, vMarginTop + vHeight div 2);
      Bitmap[0].Canvas.LineTo(vBitmapWidth, vMarginTop + vHeight div 2);
      // Draw type and range
      Bitmap[0].Canvas.Font.Style := [];
      Bitmap[0].Canvas.Font.Color := WinRGB(vGridColor);
      s := 'r=' + IntToStr(vRange);
      if vLogScale then s := s + ' logscale';
      Bitmap[0].Canvas.TextOut(vBitmapWidth div 2 + ChrWidth * 2, ChrHeight div 2, s);
      // Draw channel names
      Bitmap[0].Canvas.Font.Style := [fsBold, fsItalic];
      for i := 0 to Channels - 1 do if vLabel[i] <> '' then
      begin
        if (i and 2) = 0 then x := ChrWidth else x := vBitmapWidth - ChrWidth - Bitmap[0].Canvas.TextWidth(vLabel[i]);
        if i < 4 then y := ChrWidth else y := vBitmapHeight - ChrWidth - ChrHeight * 2;
        if (i and 1) <> 0 then y := y + ChrHeight;
        Bitmap[0].Canvas.Font.Color := WinRGB(vColor[i]);
        Bitmap[0].Canvas.TextOut(x, y, vLabel[i]);
      end;
    end;
  end;
  Bitmap[1].Canvas.Draw(0, 0, Bitmap[0]);
end;

function TDebugDisplayForm.AlphaBlend(a, b: integer; x: byte): integer;
begin
  Result :=
    // Gamma-corrected alpha blending
    Round(Power((Power(a shr 16 and $FF, 2.0) * x + Power(b shr 16 and $FF, 2.0) * ($FF - x)) / $100, 0.5)) shl 16 or
    Round(Power((Power(a shr 08 and $FF, 2.0) * x + Power(b shr 08 and $FF, 2.0) * ($FF - x)) / $100, 0.5)) shl 08 or
    Round(Power((Power(a shr 00 and $FF, 2.0) * x + Power(b shr 00 and $FF, 2.0) * ($FF - x)) / $100, 0.5)) shl 00;
end;

procedure TDebugDisplayForm.DrawLineDot(x, y, color: integer; first: boolean);
begin
  if (vLineSize > 0) and not first then
    SmoothLine(vPixelX, vPixelY, x, y, vLineSize shl 6, color, $FF);
  if (vDotSize > 0) then
    SmoothDot(x, y, vDotSize shl 7, color, $FF);
  vPixelX := x;
  vPixelY := y;
end;

procedure TDebugDisplayForm.PlotPixel(p: integer);
var
  v: integer;
  line: PByteArray;
begin
  p := TranslateColor(p, vColorMode);
  line := BitmapLine[vPixelY];
  v := vPixelX * 3;
  line[v+0] := p shr 0;
  line[v+1] := p shr 8;
  line[v+2] := p shr 16;
end;

procedure TDebugDisplayForm.ScrollBitmap(x, y: integer);
var
  xm, ym: integer;
  src, dst: TRect;
begin
  if vSparse = -1 then
  begin
    xm := 1;
    ym := 1;
  end
  else
  begin
    xm := vDotSize;
    ym := vDotSizeY;
  end;
  src := Rect(0, 0, vWidth * xm, vHeight * ym);
  dst := Rect(x * xm, y * ym, (vWidth + x) * xm, (vHeight + y) * ym);
  Bitmap[0].Canvas.CopyRect(dst, Bitmap[0].Canvas, src);
  Bitmap[0].Canvas.Brush.Color := WinRGB(GetBackground);
  if x <> 0 then
  begin
    if x < 0 then
      dst := Rect((vWidth + x) * xm, 0, vWidth * xm, vHeight * ym)
    else
      dst := Rect(0, 0, x * xm, vHeight * ym);
    Bitmap[0].Canvas.FillRect(dst);
  end;
  if y <> 0 then
  begin
    if y < 0 then
      dst := Rect(0, (vHeight + y) * ym, vWidth * xm, vHeight * ym)
    else
      dst := Rect(0, 0, vWidth * xm, y * ym);
    Bitmap[0].Canvas.FillRect(dst);
  end;
end;

procedure TDebugDisplayForm.AngleTextOut(x, y: integer; s: string; style, angle: integer);
const
  weight: array [0..3] of integer = (100, 400, 700, 900);
var
  w, h, rx, ry: integer;
  tx, ty, ta: extended;
begin
  // Make new logical font
  GetObject(Bitmap[0].Canvas.Font.Handle, SizeOf(NewLogFont), Addr(NewLogFont));
  NewLogFont.lfEscapement := angle;
  NewLogFont.lfOrientation := angle;
  NewLogFont.lfWeight := weight[style and 3];
  NewLogFont.lfItalic := style and $04 shr 2;
  NewLogFont.lfUnderline := style and $08 shr 3;
  NewFontHandle := CreateFontIndirect(NewLogFont);
  OldFontHandle := SelectObject(Bitmap[0].Canvas.Handle, NewFontHandle);
  // Compute metrics
  w := Bitmap[0].Canvas.TextWidth(s);
  h := Bitmap[0].Canvas.TextHeight(s);
  case style and $30 shr 4 of
    0, 1: tx := -w / 2;
    2:    tx := 0;
    3:    tx := -w;
  end;
  case style and $C0 shr 6 of
    0, 1: ty := h / 2;
    2:    ty := h;
    3:    ty := 0;
  end;
  ta := angle / 3600 * 2 * Pi;
  rx := Round(tx * cos(ta) - ty * sin(ta));
  ry := Round(tx * sin(ta) + ty * cos(ta));
  // Output text
  Bitmap[0].Canvas.TextOut(x + rx, y - ry, s);
  // Delete logical font
  NewFontHandle := SelectObject(Bitmap[0].Canvas.Handle, OldFontHandle);
  DeleteObject(NewFontHandle);
end;

procedure TDebugDisplayForm.BitmapToCanvas(Level: integer);
begin
  if Level = 0 then
    Bitmap[1].Canvas.Draw(0, 0, Bitmap[0]);
  if DisplayType in [dis_spectro, dis_plot, dis_bitmap] then
    Canvas.StretchDraw(Rect(0, 0, vClientWidth, vClientHeight), Bitmap[1])
  else
    Canvas.Draw(0, 0, Bitmap[1]);
end;


/////////////////////////////////
//  Mouse & Keyboard Feedback  //
/////////////////////////////////

procedure TDebugDisplayForm.SendMousePos;
var
  p: tPoint;
  v, c: cardinal;
begin
  p := ScreenToClient(Mouse.CursorPos);
  if (p.x < 0) or (p.x >= ClientWidth) or (p.y < 0) or (p.y >= ClientHeight) or
     (DisplayType = dis_term) and
     ((p.x < vMarginLeft) or (p.x >= ClientWidth - vMarginLeft) or
     (p.y < vMarginTop) or (p.y >= ClientHeight - vMarginTop)) then
  begin
    v := $03FFFFFF;
    c := $FFFFFFFF;
  end
  else
  begin
    c := Canvas.Pixels[p.x, p.y];
    c := c and $0000FF shl 16 or c and $00FF00 or c and $FF0000 shr 16; 
    case DisplayType of
      dis_spectro, dis_plot, dis_bitmap:
      begin
        if vDirX then p.x := ClientWidth - p.x;
        if not vDirY then p.y := ClientHeight - p.y;
        p.x := p.x div vDotSize;
        p.y := p.y div vDotSizeY;
      end;
      dis_term:
      begin
        p.x := (p.x - vMarginLeft) div ChrWidth;
        p.y := (p.y - vMarginTop) div ChrHeight;
      end;
    end;
    v := vMouseWheel and 3 shl 26 or p.y and $1FFF shl 13 or p.x and $1FFF;
    if GetAsyncKeyState(VK_LBUTTON) and $8000 <> 0 then v := v or $10000000;
    if GetAsyncKeyState(VK_MBUTTON) and $8000 <> 0 then v := v or $20000000;
    if GetAsyncKeyState(VK_RBUTTON) and $8000 <> 0 then v := v or $40000000;
  end;
  TLong(v);
  TLong(c);
  vMouseWheel := 0;   // vMouseWheel has been used, clear it
end;

procedure TDebugDisplayForm.SendKeyPress;
begin
  TLong(integer(vKeyPress));
  vKeyPress := 0;     // vKeyPress has been used, clear it
end;


//////////////////////////////////
//  Anti-Aliased Shape Drawing  //
//////////////////////////////////

procedure TDebugDisplayForm.SmoothShape(xc, yc, xs, ys, xro, yro, thick, color: integer; opacity: byte);
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
  if (xc < -SmoothFillMax) or (xc > vBitmapWidth + SmoothFillMax) or
     (yc < -SmoothFillMax) or (yc > vBitmapHeight + SmoothFillMax) or
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

procedure TDebugDisplayForm.SmoothFillSetup(size, color: integer);
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

procedure TDebugDisplayForm.SmoothRect(x, y, xs, ys: integer; opacity: byte);
var
  i: integer;
begin
  if (xs = 0) or (ys = 0) then Exit;
  for i := y to y + ys - 1 do
    SmoothFill(x, i, xs - 1, opacity);
end;

procedure TDebugDisplayForm.SmoothFill(x, y, count: integer; opacity: byte);
var
  src, dst: PByte;
  i: integer;
begin
  // make sure y within bitmap
  if (y < 0) or (y >= vBitmapHeight) then Exit;
  // reduce count if x < 0 or x + count >= width
  if (x < 0) then
  begin
    Inc(count, x);
    if count < 0 then Exit;
    x := 0;
  end;
  if x >= vBitmapWidth then Exit;
  if x + count >= vBitmapWidth then count := vBitmapWidth - 1 - x;
  // fill pixels in line
  if opacity = $FF then         // fast fill?
    Move(SmoothFillBuff, PByteArray(BitmapLine[y])[x * 3], (count + 1) * 3)
  else if opacity <> 0 then     // blended fill?
  begin
    src := @SmoothFillBuff;
    dst := @PByteArray(BitmapLine[y])[x * 3];
    for i := 1 to (count + 1) * 3 do
    begin
      // Gamma-corrected alpha blending
      dst^ := Round(Power((Power(dst^, 2.0) * ($FF - opacity) + Power(src^, 2.0) * opacity) / $100, 0.5));
      Inc(dst);
      Inc(src);
    end;
  end;
end;

procedure TDebugDisplayForm.SmoothPlot(x, y: integer; opacity: byte);
var
  p: PByte;
begin
  if opacity = 0 then Exit;
  if (x < 0) or (x >= vBitmapWidth) or
     (y < 0) or (y >= vBitmapHeight) then Exit;
  p := @PByteArray(BitmapLine[y])[x * 3];
  if opacity = $FF then
  begin
    p^ := SmoothFillColor shr 00; Inc(p);
    p^ := SmoothFillColor shr 08; Inc(p);
    p^ := SmoothFillColor shr 16;
  end
  else
  begin
    // Gamma-corrected alpha blending
    p^ := Round(Power((Power(p^, 2.0) * ($FF - opacity) + Power(SmoothFillColor shr 00 and $FF, 2.0) * opacity) / $100, 0.5)); Inc(p);
    p^ := Round(Power((Power(p^, 2.0) * ($FF - opacity) + Power(SmoothFillColor shr 08 and $FF, 2.0) * opacity) / $100, 0.5)); Inc(p);
    p^ := Round(Power((Power(p^, 2.0) * ($FF - opacity) + Power(SmoothFillColor shr 16 and $FF, 2.0) * opacity) / $100, 0.5));
  end;
end;


/////////////////////////////////
//  Anti-Aliased Line Drawing  //
//    x/y/radius in 256th's    //
/////////////////////////////////

procedure TDebugDisplayForm.SmoothDot(x, y, radius, color: integer; opacity: byte);
begin
  SmoothLine(x, y, x, y, radius, color, opacity);
end;

procedure TDebugDisplayForm.SmoothLine(x1, y1, x2, y2, radius, color: integer; opacity: byte);
const
  maxr = 128;
  limr = maxr + 1;
var
  radius1, radius2, span, dx, dy,
  x1f, y1f, x2f, y2f, xleft, xright,
  slice, lt, lb, rt, rb, x, y,
  xp, yp, yl, yr, yt, yb, yn: integer;
  yd, ym: int64;
  xo, yo: byte;
  th: extended;
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
  Inc(y1, $80);
  Inc(x2, $80);
  Inc(y2, $80);
  // clip line and exit if outside bitmap
  if not SmoothClip(x1, y1, x2, y2) then Exit;
  // get radius and span
  radius1 := Min(radius, maxr shl 8);
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
    y1_lut1[xp] := Round(Sqrt(Power(radius1, 2.0) - Power((Min(Abs(xp shl 8 + x1f), radius1)), 2.0)));
    y2_lut1[xp] := Round(Sqrt(Power(radius1, 2.0) - Power((Min(Abs(xp shl 8 + x2f), radius1)), 2.0)));
    // 2D-slice lookups, radius+$80 reduces to actual radius after 2D opacity modulation
    x1_lut2[xp] := Round(Sqrt(Power(radius1 + $80, 2.0) - Power((Min(Abs(xp shl 8 + y1f), radius1)), 2.0)));
    y1_lut2[xp] := Round(Sqrt(Power(radius1 + $80, 2.0) - Power((Min(Abs(xp shl 8 + x1f), radius1)), 2.0)));
    x2_lut2[xp] := Round(Sqrt(Power(radius1 + $80, 2.0) - Power((Min(Abs(xp shl 8 + y2f), radius1)), 2.0)));
    y2_lut2[xp] := Round(Sqrt(Power(radius1 + $80, 2.0) - Power((Min(Abs(xp shl 8 + x2f), radius1)), 2.0)));
  end;
  // register xleft and xright to pixel centers
  xleft := (x1 - radius1) and $FFFFFF00 + $80;
  xright := (x2 + radius1) and $FFFFFF00 + $80;
  // get angle metrics
  yd := Int64($10000) * (y2 - y1) div Max(x2 - x1, 1);       // get 16-bit slope, prevent divide-by-zero
  ym := yd * (xleft - x1) div $100 + y1 * $100;              // get initial y with 16-bit fraction at x1
  th := ArcTan2(y2 - y1, x2 - x1);                           // get angle
  dx := Round(radius1 * Sin(th));                            // get semicircle departure/arrival points
  lt := x1 + dx;
  lb := x1 - dx;
  rt := x2 + dx;
  rb := x2 - dx;
  slice := (radius1 * $10000) div Round(Cos(th) * $10000);   // get slice size
  // draw complete line with left and right endpoint semicircles
  x := xleft;
  while x <= xright do
  begin
    // if in left semicircle before line departure, draw 2D slice
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
    // if in right semicircle after line arrival, draw 2D slice
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
    // between semicircles, draw 1D slice of line
    else
    begin
      // get slice metrics
      yl := y1_lut1[x1 div $100 - x div $100];
      yr := y2_lut1[x2 div $100 - x div $100];
      y := ym div $100;
      // determine top
      if x <= lt then yb := y1 - yl
      else if x >= rt then yb := y2 - yr
      else yb := y - slice;
      // determine bottom
      if x <= lb then yt := y1 + yl
      else if x >= rb then yt := y2 + yr
      else yt := y + slice;
      // draw bottom-to-top slice at x
      while yb < yt do
      begin
        yn := (yb or $FF) + 1;
        if yt < yn then
          yo := yt - yb
        else
          yo := not yb;
        SmoothPixel(swapxy, x shr 8, yb shr 8, color, yo, opacity);
        yb := yn;
      end;
    end;
    // step x and y
    Inc(x, $100);
    Inc(ym, yd);
  end;
end;

procedure TDebugDisplayForm.SmoothPixel(swapxy: boolean; x, y, color: integer; opacity, opacity2: byte);
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
  if (x < 0) or (x >= vBitmapWidth) or
     (y < 0) or (y >= vBitmapHeight) then Exit;
  p := @PByteArray(BitmapLine[y])[x * 3];
  if opacity = $FF then
  begin
    p^ := color shr 00; Inc(p);
    p^ := color shr 08; Inc(p);
    p^ := color shr 16;
  end
  else
  begin
    // Gamma-corrected alpha blending
    p^ := Round(Power((Power(p^, 2.0) * ($FF - opacity) + Power(color shr 00 and $FF, 2.0) * opacity) / $100, 0.5)); Inc(p);
    p^ := Round(Power((Power(p^, 2.0) * ($FF - opacity) + Power(color shr 08 and $FF, 2.0) * opacity) / $100, 0.5)); Inc(p);
    p^ := Round(Power((Power(p^, 2.0) * ($FF - opacity) + Power(color shr 16 and $FF, 2.0) * opacity) / $100, 0.5));
  end;
end;

function TDebugDisplayForm.SmoothClip(var x1, y1, x2, y2: integer): boolean;
var
  lft, rgt, bot, top, out1, out2, outx: integer;
  fx1, fy1, fx2, fy2, fx, fy: double;
begin
  // Cohen-Sutherland clipping algorithm
  lft := 0;
  rgt := vBitmapWidth shl 8 - 1;
  bot := 0;
  top := vBitmapHeight shl 8 - 1;
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

function TDebugDisplayForm.SmoothClipTest(x, y, lft, rgt, bot, top: integer): integer;
begin
  Result := 0;
  if      x < lft then Result := Result or 1
  else if x > rgt then Result := Result or 2;
  if      y < bot then Result := Result or 4
  else if y > top then Result := Result or 8;
end;


////////////////////
//  Get Elements  //
////////////////////

function TDebugDisplayForm.NextKey: boolean;
begin
  Result := NextElement(ele_key);
end;

function TDebugDisplayForm.NextNum: boolean;
begin
  Result := NextElement(ele_num);
end;

function TDebugDisplayForm.NextStr: boolean;
begin
  Result := NextElement(ele_str);
end;

function TDebugDisplayForm.NextEnd: boolean;
begin
  Result := P2.DebugDisplayType[ptr] = ele_end;
end;

function TDebugDisplayForm.NextElement(Element: integer): boolean;
begin
  if P2.DebugDisplayType[ptr] = Element then
  begin
    val := P2.DebugDisplayValue[ptr];
    Inc(ptr);
    Result := True;
  end
  else
    Result := False;
end;


///////////////////
//  Packed Data  //
///////////////////

procedure TDebugDisplayForm.SetPack(val: integer; alt, signx: boolean);
var
  i: integer;
begin
  vPackAlt := alt;
  vPackSignx := signx;
  if val = 0 then i := 32 shl 8 + 1 else i := PackDef[val];
  if val = 0 then vPackMask := $FFFFFFFF else vPackMask := 1 shl (i shr 8 and $FF) - 1;
  vPackShift := i shr 8 and $FF;
  vPackCount := i and $FF;
end;

function TDebugDisplayForm.NewPack: integer;
begin
  Result := val;
  if vPackAlt and (vPackShift <= 1) then Result := Result shr 1 and $55555555 or Result shl 1 and $AAAAAAAA;
  if vPackAlt and (vPackShift <= 2) then Result := Result shr 2 and $33333333 or Result shl 2 and $CCCCCCCC;
  if vPackAlt and (vPackShift <= 4) then Result := Result shr 4 and $0F0F0F0F or Result shl 4 and $F0F0F0F0;
end;

function TDebugDisplayForm.UnPack(var v: integer): integer;
begin
  Result := v and vPackMask;
  v := v shr vPackShift;
  if vPackSignx and (Result shr (vPackShift - 1) and 1 = 1) then Result := Result or ($FFFFFFFF xor vPackMask);
end;


//////////////////////////////
//  Fast Fourier Transform  //
//////////////////////////////

procedure TDebugDisplayForm.PrepareFFT;
var
  i: integer;
  Tf, Xf, Yf: extended;
begin
  for i := 0 to 1 shl FFTexp - 1 do
  begin
    Tf := Rev32(i) / $100000000 * Pi;
    SinCos(Tf, Yf, Xf);
    FFTsin[i] := Round(Yf * $1000);
    FFTcos[i] := Round(Xf * $1000);
    FFTwin[i] := Round((1 - Cos((i / (1 shl FFTexp)) * Pi * 2)) * $1000)
  end;
end;

procedure TDebugDisplayForm.PerformFFT;
var
  i1, i2, i3, i4, c1, c2, th, ptra, ptrb: integer;
  ax, ay, bx, by, rx, ry: int64;
begin
  // Load samples into (real,imag) with Hanning window applied
  for i1 := 0 to 1 shl FFTexp - 1 do
  begin
    FFTreal[i1] := FFTsamp[i1] * FFTwin[i1];
    FFTimag[i1] := 0
  end;
  // Perform FFT on (real,imag)
  i1 := 1 shl (FFTexp - 1);
  i2 := 1;
  while i1 <> 0 do
  begin
    th := 0;
    i3 := 0;
    i4 := i1;
    c1 := i2;
    while c1 <> 0 do
    begin
      ptra := i3;
      ptrb := ptra + i1;
      c2 := i4 - i3;
      while c2 <> 0 do
      begin
        ax := FFTreal[ptra];
        ay := FFTimag[ptra];
        bx := FFTreal[ptrb];
        by := FFTimag[ptrb];
        rx := (bx * FFTcos[th] - by * FFTsin[th]) div $1000;
        ry := (bx * FFTsin[th] + by * FFTcos[th]) div $1000;
        FFTreal[ptra] := ax + rx;
        FFTimag[ptra] := ay + ry;
        FFTreal[ptrb] := ax - rx;
        FFTimag[ptrb] := ay - ry;
        ptra := ptra + 1;
        ptrb := ptrb + 1;
        c2 := c2 - 1;
      end;
      th := th + 1;
      i3 := i3 + i1 shl 1;
      i4 := i4 + i1 shl 1;
      c1 := c1 - 1;
    end;
    i1 := i1 shr 1;
    i2 := i2 shl 1;
  end;
  // Convert (real,imag) to (power,angle)
  for i1 := 0 to 1 shl (FFTexp - 1) - 1 do
  begin
    i2 := Rev32(i1) shr (32 - FFTexp);
    rx := FFTreal[i2];
    ry := FFTimag[i2];
    FFTpower[i1] := Round(Hypot(rx, ry) / ($800 shl FFTexp shr FFTmag));
    FFTangle[i1] := Round(ArcTan2(rx, ry) / (Pi * 2) * $100000000) and $FFFFFFFF;
  end;
end;

function TDebugDisplayForm.Rev32(i: integer): int64;
const
  Rev4: array [0..15] of integer = ($0,$8,$4,$C,$2,$A,$6,$E,$1,$9,$5,$D,$3,$B,$7,$F);
begin
  Result := (Rev4[i shr 0 and $F] shl 28 or
             Rev4[i shr 4 and $F] shl 24 or
             Rev4[i shr 8 and $F] shl 20) and $FFF00000;
end;

end.

