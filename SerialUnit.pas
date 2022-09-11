unit SerialUnit;

interface

uses
  SysUtils, WinTypes, WinProcs, Classes, Forms, Messages, Dialogs,
  ExtCtrls, Graphics, MMSystem_D10_2;

type
  TSerialThread = class(TThread)
  protected
    procedure Execute; override;
  public
    constructor Create; reintroduce;
  end;

  procedure LoadHardware;
  procedure GetHardwareVersion;
  procedure FindHardware;
  function  HardwareFound: boolean;
  procedure ResetHardware;

  procedure StartDebug;
  procedure OperateDebug;
  procedure ReturnRByte;

  procedure OpenComm;
  procedure TString(s: string);
  procedure THex(x: byte);
  procedure TBase64(x: byte);
  procedure TLong(x: integer);
  procedure TByte(x: byte);
  function  RLong: cardinal;
  function  RWord: word;
  function  RByte: byte;
  procedure CloseComm;
  procedure CommError(ErrorMsg: string);
  function  CommString: string;

  procedure BeginTimeBase;
  procedure EndTimeBase;

  procedure SerialThreadStart;
  procedure SerialThreadStop;
  procedure PumpTx;
  procedure PumpRx;

const
  DefaultBaud        = 2000000;
  TxBuffSize         = $200000;         // 2 MB, must be power-of-2
  TxBuffMask         = TxBuffSize - 1;
  RxBuffSize         = $1000000;        // 16 MB, must be power-of-2
  RxBuffMask         = RxBuffSize - 1;

var
  CommOpen           : boolean;
  CommPort           : integer;
  CommHandle         : THandle;
  CommDCB            : TDCB;

  TxBuff             : array[0..TxBuffSize - 1] of byte;
  TxHead             : integer;
  TxTail             : integer;

  RxBuff             : array[0..RxBuffSize - 1] of byte;
  RxHead             : integer;
  RxTail             : integer;

  Version            : byte;
  VersionMode        : boolean;
  AbortMode          : boolean;

  TimeBase           : cardinal;

  SerialThreadError  : boolean;
  SerialThreadString : string;
  SerialThreadActive : boolean;
  SerialThread       : TSerialThread;

implementation

uses GlobalUnit, ProgressUnit, DebugUnit;


/////////////////////////
//  Hardware Routines  //
/////////////////////////

// Load Hardware
procedure LoadHardware;
var
  LoadLimit, i, m, n: integer;
begin
  // find hardware
  VersionMode := False;
  FindHardware;
  // check version
  if (Version < Byte('A')) or (Version > Byte('G')) then
    CommError('Invalid Hardware Version ' + IntToStr(Version) + ' Found on');
  // update progress form
  ProgressForm.StatusLabel.Caption := 'Loading RAM';
  ProgressForm.StatusLabel.Repaint;
  // cap load sizes by Version
  if Version = Byte('A') then LoadLimit := Smaller(P2.ObjLength, $100000);
  if Version = Byte('B') then LoadLimit := Smaller(P2.ObjLength, $040000);
  if Version = Byte('C') then LoadLimit := Smaller(P2.ObjLength, $008000);
  if Version = Byte('D') then LoadLimit := Smaller(P2.ObjLength, $020000);
  if Version = Byte('E') then LoadLimit := Smaller(P2.ObjLength, $080000);
  if Version = Byte('F') then LoadLimit := Smaller(P2.ObjLength, $100000);
  if Version = Byte('G') then LoadLimit := Smaller(P2.ObjLength, $100000);
  // send bytes in Base64 format
  TString('Prop_Txt 0 0 0 0 ');
  n := 0;
  for i := 0 to LoadLimit - 1 do
  begin
    m := (m shl 8) + P2.Obj[i];
    n := n + 8;
    if n >= 6 then
    begin
      TBase64((m shr (n - 6)) and $3F);
      n := n - 6;
    end;
    if n >= 6 then
    begin
      TBase64((m shr (n - 6)) and $3F);
      n := n - 6;
    end;
  end;
  if n > 0 then TBase64((m shl (6 - n)) and $3F);
  TString('~');
  // debug mode?
  if P2.DebugMode and (P2.DebugWindowsOff = 0) and (P2.DebugBaud = p2.DownloadBaud) then
  begin
    ProgressForm.Hide;
    OperateDebug;
  end
  // done
  else
  begin
    CloseComm;
    ProgressForm.Hide;
  end;
end;

// Get hardware version
procedure GetHardwareVersion;
var
  s: string;
begin
  VersionMode := True;
  FindHardware;
  CloseComm;
  ProgressForm.Hide;
  s := 'Unknown.';
  if Version = Byte('A') then s := 'FPGA - 8 cogs, 512KB hub, 48 smart pins 63..56, 39..0, 80MHz';
  if Version = Byte('B') then s := 'FPGA - 4 cogs, 256KB hub, 12 smart pins 63..60/7..0, 80MHz';
  if Version = Byte('C') then s := 'unsupported'; // 1 cog, 32KB hub, 8 smart pins 63..62/5..0, 80MHz, No CORDIC';
  if Version = Byte('D') then s := 'unsupported'; // 1 cog, 128KB hub, 7 smart pins 63..62/4..0, 80MHz, No CORDIC';
  if Version = Byte('E') then s := 'FPGA - 4 cogs, 512KB hub, 18 smart pins 63..62/15..0, 80MHz';
  if Version = Byte('F') then s := 'unsupported'; // 16 cogs, 1024KB hub, 7 smart pins 63..62/33..32/2..0, 80MHz';
  if Version = Byte('G') then s := 'P2X8C4M64P Rev B/C - 8 cogs, 512KB hub, 64 smart pins';
  MessageDlg(('Propeller2 found on ' + CommString + '.' + Chr(13) + Chr(13) + s), mtInformation, [mbOK], 0);
end;

// Check for hardware on current comm port, then on com9..com1
procedure FindHardware;
var
  i, FirstPort: integer;
begin
  CloseComm;
  // show progress form
  ProgressForm.Caption := 'Hardware';
  ProgressForm.StatusLabel.Caption := '';
  ProgressForm.Show;
  // check com99..com1 for hardware
  FirstPort := CommPort;
  for i := 100 downto 1 do
  begin
    if i <> 100 then CommPort := i;
    if (i = 100) or (i <> FirstPort) then
    begin
      ProgressForm.StatusLabel.Caption := 'Checking ' + CommString;
      ProgressForm.StatusLabel.Repaint;
      if HardwareFound then Exit;
    end;
  end;
  CommPort := 99;
  CommError('No hardware found on COM1 through');
end;

// Check for hardware on current comm port
function HardwareFound: boolean;
var
  i: integer; s: string;
begin
  try
    // in case error, result is false
    Result := False;
    // disallow abort
    AbortMode := False;
    // check hardware
    OpenComm;
    ResetHardware;
    TString('> Prop_Chk 0 0 0 0 ');
    // receive version string
    s := '';
    for i := 1 to 14 do s := s + Chr(RByte);
    Version := Byte(s[12]);
    s[12] := 'X';
    if s <> String(Chr(13) + Chr(10) + 'Prop_Ver X' + Chr(13) + Chr(10)) then
      CommError('Hardware lost on');
    // if find hardware mode, send shutdown command and reset hardware to reboot
    if VersionMode then
    begin
      ResetHardware;
      CloseComm;
    end;
    // allow abort
    AbortMode := True;
    // connected, result is true
    Result := True;
  except
    // error, result is false, allow abort
    on EAbort do AbortMode := True;
  end;
end;

// Reset hardware
procedure ResetHardware;
begin
  // stop serial thread
  SerialThreadStop;
  // generate P2 reset pulse via DTR
  Sleep(1);
  EscapeCommFunction(CommHandle, SETDTR);
  Sleep(1);
  EscapeCommFunction(CommHandle, CLRDTR);
  // allow time for P2 ROM loader to start
  Sleep(15);
  // restart serial thread
  SerialThreadStart;
end;


//////////////////////
//  DEBUG Receiver  //
//////////////////////

// Start DEBUG
procedure StartDebug;
begin
  AbortMode := True;
  OpenComm;
  OperateDebug;
end;

// Operate DEBUG
procedure OperateDebug;
var
  i: integer;
  b: byte;
begin
  DebugActive := True;
  DebugForm.ResetDisplays;
  while DebugActive do
  begin
    for i := 1 to 100 do
    begin
      if SerialThreadError then CommError(SerialThreadString);
      if RxHead <> RxTail then
      begin
        b := RxBuff[RxTail];
        RxTail := (RxTail + 1) and RxBuffMask;
        DebugForm.ChrIn(b);
      end
      else Break;
    end;
    Application.ProcessMessages;        // process messages when no byte ready or after 100 consecutive bytes
  end;
  CloseComm;
end;

// Back up received byte
procedure ReturnRByte;
begin
  RxTail := (RxTail - 1) and RxBuffMask;
end;


/////////////////////
//  Comm Routines  //
/////////////////////

// Open comm port
procedure OpenComm;
const
  CommTimeouts: TCOMMTIMEOUTS = (
    ReadIntervalTimeout: MAXDWORD;
    ReadTotalTimeoutMultiplier: 0;
    ReadTotalTimeoutConstant: 0;
    WriteTotalTimeoutMultiplier: 0;
    WriteTotalTimeoutConstant: 0);
begin
  CloseComm;
  CommOpen := False;
  CommHandle := CreateFile(PChar('\\.\' + CommString), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if CommHandle = INVALID_HANDLE_VALUE then CommError('Unable to open');
  BuildCommDCB(PChar(IntToStr(P2.DownloadBaud) + ',n,8,1'), CommDCB);
  CommDCB.Flags := 0;
  SetCommState(CommHandle, CommDCB);
  SetCommTimeouts(CommHandle, CommTimeouts);
  SerialThreadStart;
  CommOpen := True;
end;

// Transmit string
procedure TString(s: string);
var
  i: integer;
begin
  for i := 1 to Length(s) do
    TByte(Byte(s[i]));
end;

// Transmit hex byte
procedure THex(x: byte);
const
  HexChr: array [0..15] of Char = '0123456789ABCDEF';
begin
  TByte(Byte(HexChr[x shr 4 and $F]));
  TByte(Byte(HexChr[x and $F]));
  TByte($20);
end;

// Transmit base64 character
procedure TBase64(x: byte);
const
  Base64Chr: array [0..63] of Char = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
begin
  TByte(Byte(Base64Chr[x]));
end;

// Transmit long
procedure TLong(x: integer);
var
  i: integer;
begin
  for i := 0 to 3 do TByte(x shr (i shl 3));
end;

// Transmit byte
procedure TByte(x: byte);
begin
  TxBuff[TxHead] := x;
  TxHead := (TxHead + 1) and TxBuffMask;
end;

// Receive long
function RLong: cardinal;
var
  i: integer;
begin
  for i := 0 to 3 do Result := Result shr 8 + RByte shl 24;
end;

// Receive word
function RWord: word;
var
  i: integer;
begin
  for i := 0 to 1 do Result := Result shr 8 + RByte shl 8;
end;

// Receive byte
function RByte: byte;
var
  Ticks: cardinal;
begin
  Ticks := GetTickCount;
  repeat
    if SerialThreadError then CommError(SerialThreadString);
    if RxHead <> RxTail then
    begin
      Result := RxBuff[RxTail];
      RxTail := (RxTail + 1) and RxBuffMask;
      Exit;
    end;
  until GetTickCount - Ticks > 500;
  CommError('Hardware lost on');
end;

// Close comm port
procedure CloseComm;
begin
  // close down debug in case active
  DebugForm.CloseDisplays;
  DebugForm.CloseLogFile;
  DebugActive := False;
  // if port open, close it
  if CommOpen then
  begin
    SerialThreadStop;
    CloseHandle(CommHandle);
    CommOpen := False;
  end;
end;

// Comm error
procedure CommError(ErrorMsg: string);
begin
  CloseComm;
  if AbortMode then
  begin
    ProgressForm.Hide;
    if not BatchMode then MessageDlg(ErrorMsg + ' ' + CommString + '.', mtError, [mbOK], 0);
  end;
  Abort;
end;

// Return comm port string
function CommString: string;
begin
  Result := 'COM' + IntToStr(CommPort);
end;


//////////////////////////////
//  Time-Base Optimization  //
//////////////////////////////

// Start time base
procedure BeginTimeBase;
var
  TimeCaps: TTimeCaps;
begin
  timeGetDevCaps(@TimeCaps, SizeOf(TimeCaps));
  TimeBase := TimeCaps.wPeriodMin;
  timeBeginPeriod(TimeBase);
end;

// End time base
procedure EndTimeBase;
begin
  timeEndPeriod(TimeBase);
end;


/////////////////////
//  Serial Thread  //
/////////////////////

procedure SerialThreadStart;
var
  x: cardinal;
begin
  // init variables
  TxHead := 0;
  TxTail := 0;
  RxHead := 0;
  RxTail := 0;
  SerialThreadError := False;
  SerialThreadString := '';
  SerialThreadActive := True;
  // read any residual Rx data to purge deep buffers
  ReadFile(CommHandle, RxBuff, RxBuffSize, x, nil);
  // start thread
  SerialThread := TSerialThread.Create;
end;

procedure SerialThreadStop;
begin
  // allow Tx buffer to finish transmitting
  if not SerialThreadError then repeat until TxHead = TxTail;
  // deactivate thread
  SerialThreadActive := False;
  // wait for confirmation
  repeat until SerialThreadString <> '';
end;

constructor TSerialThread.Create;
begin
  inherited Create(False);
  FreeOnTerminate := True;
  Priority := tpTimeCritical;
end;

procedure TSerialThread.Execute;
begin
  // keep pumping while active and no error
  while SerialThreadActive and not SerialThreadError do
  begin
    // pump data
    PumpTx;
    PumpRx;
    // yield time to the GUI thread
    Sleep(0);
  end;
  // terminating, confirm string is not empty
  if not SerialThreadError then
    SerialThreadString := 'OK';
end;

procedure PumpTx;
var
  x: cardinal;
begin
  // Exit?
  if (TxHead = TxTail) or SerialThreadError then Exit;
  // Transmit any data
  if TxHead < TxTail then x := TxBuffSize else x := TxHead;
  if WriteFile(CommHandle, TxBuff[TxTail], x - TxTail, x, nil) then
    TxTail := (TxTail + x) and TxBuffMask
  else
  begin
    SerialThreadError := True;
    SerialThreadString := 'Unable to write to';
  end;
end;

procedure PumpRx;
var
  x: cardinal;
begin
  // Exit?
  if SerialThreadError then Exit;
  // Receive any data
  if ReadFile(CommHandle, RxBuff[RxHead], RxBuffSize - RxHead, x, nil) then
    RxHead := (RxHead + x) and RxBuffMask
  else
  begin
    SerialThreadError := True;
    SerialThreadString := 'Unable to read from';
  end;
end;

end.

