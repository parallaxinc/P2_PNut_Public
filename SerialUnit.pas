unit SerialUnit;

interface

uses
  SysUtils, WinTypes, WinProcs, Classes, Forms, Messages, Dialogs, ExtCtrls, Graphics;

  procedure        LoadHardware;
  procedure        GetHardwareVersion;
  procedure        FindHardware;
  function         HardwareFound: boolean;
  procedure        ResetHardware;
  procedure        StartDebug;
  procedure        OperateDebug;
  procedure        OpenComm;
  procedure        TString(s: string);
  procedure        THex(x: byte);
  procedure        TBase64(x: byte);
  procedure        TByte(x: byte);
  procedure        TComm;
  function         RByte: byte;
  function         RCheck: boolean;
  function         RGet: byte;
  procedure        RComm;
  procedure        ReceiveDebugData;
  procedure        CloseComm;
  procedure        CommError(Msg: string);
  function         CommString: string;
  procedure        Waitms(ms: cardinal);

const
  TxBuffSize         = $1000;
  RxBuffSize         = $1000;
  DebugBuffSize      = $1000000;
  DebugBuffMask      = DebugBuffSize - 1;

var
  CommPort           : integer;
  CommHandle         : THandle;
  CommDCB            : TDCB;

  TxBuffLength       : cardinal;
  TxBuff             : array[0..TxBuffSize-1] of byte;
  RxBuffStart        : cardinal;
  RxBuffEnd          : cardinal;
  RxBuff             : array[0..RxBuffSize-1] of byte;

  DebugBuff          : array[0..DebugBuffSize-1] of byte;
  DebugBuffHead      : integer;
  DebugBuffTail      : integer;

  Version            : byte;
  VersionMode        : boolean;
  AbortMode          : boolean;

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
  TComm;
  // debug mode?
  if P2.DebugMode and (P2.DebugPinTx = 62) and (P2.DebugWindowsOff = 0) then
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
  ProgressForm.Hide;
  s := 'Unknown.';
  if Version = Byte('A') then s := 'FPGA - 8 cogs, 512KB hub, 48 smart pins 63..56, 39..0, 80MHz';
  if Version = Byte('B') then s := 'FPGA - 4 cogs, 256KB hub, 12 smart pins 63..60/7..0, 80MHz';
  if Version = Byte('C') then s := 'unsupported'; // 1 cog, 32KB hub, 8 smart pins 63..62/5..0, 80MHz, No CORDIC';
  if Version = Byte('D') then s := 'unsupported'; // 1 cog, 128KB hub, 7 smart pins 63..62/4..0, 80MHz, No CORDIC';
  if Version = Byte('E') then s := 'FPGA - 4 cogs, 512KB hub, 18 smart pins 63..62/15..0, 80MHz';
  if Version = Byte('F') then s := 'unsupported'; // 16 cogs, 1024KB hub, 7 smart pins 63..62/33..32/2..0, 80MHz';
  if Version = Byte('G') then s := 'P2X8C4M64P Rev B/C - 8 cogs, 512KB hub, 64 smart pins';
  if CommOpen then CloseComm;
  MessageDlg(('Propeller2 found on ' + CommString + '.' + Chr(13) + Chr(13) + s), mtInformation, [mbOK], 0);
end;

// Check for hardware on current comm port, then on com9..com1
procedure FindHardware;
var
  i, FirstPort: integer;
begin
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
    TComm;
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
  // generate reset pulse via dtr and wait 10ms
  Waitms(10);
  EscapeCommFunction(CommHandle, SETDTR);
  Waitms(10);
  EscapeCommFunction(CommHandle, CLRDTR);
  Waitms(10);
  // flush any previously-received bytes and clear any break
  PurgeComm(CommHandle, PURGE_RXCLEAR);
  PurgeComm(CommHandle, PURGE_TXCLEAR);
  repeat RComm until RxBuffEnd = 0;
  Waitms(10);
  repeat RComm until RxBuffEnd = 0;
end;

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
begin
  if P2.DebugBaud <> P2.DownloadBaud then
  begin
    Sleep(100);    // allow download to complete before changing baud
    GetCommState(CommHandle, CommDCB);
    CommDCB.BaudRate := P2.DebugBaud;
    CommDCB.Flags := 0;
    SetCommState(CommHandle, CommDCB);
  end;
  DebugActive := True;
  DebugBuffHead := 0;
  DebugBuffTail := 0;
  if RxBuffStart <> RxBuffEnd then
  begin
    Move(RxBuff[RxBuffStart], DebugBuff[0], RxBuffEnd - RxBuffStart);
    DebugBuffHead := RxBuffEnd - RxBuffStart;
  end;
  DebugForm.ResetDisplays;
  while DebugActive do
  begin
    ReceiveDebugData;
    for i := 1 to 100 do
      if DebugBuffHead <> DebugBuffTail then
      begin
        DebugForm.ChrIn(DebugBuff[DebugBuffTail]);
        DebugBuffTail := (DebugBuffTail + 1) and DebugBuffMask;
      end
      else Break;
    Application.ProcessMessages;
    //Sleep(50);
  end;
  CloseComm;
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
  CommOpen := False;
  CommHandle := CreateFile(PChar('\\.\' + CommString), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if CommHandle = INVALID_HANDLE_VALUE then CommError('Unable to open');
  BuildCommDCB(PChar(IntToStr(P2.DownloadBaud) + ',n,8,1'), CommDCB);
  CommDCB.Flags := 0;
  SetCommState(CommHandle, CommDCB);
  SetCommTimeouts(CommHandle, CommTimeouts);
  TxBuffLength := 0;
  RxBuffStart := 0;
  RxBuffEnd := 0;
  CommOpen := True;
end;

// Add string to comm buffer
procedure TString(s: string);
var
  i: integer;
begin
  for i := 1 to Length(s) do
    TByte(Byte(s[i]));
end;

// Add hex byte to comm buffer
procedure THex(x: byte);
const
  HexChr: array [0..15] of byte = ($30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$41,$42,$43,$44,$45,$46);
begin
  TByte(HexChr[(x shr 4) and $F]);
  TByte(HexChr[x and $F]);
  TByte($20);
end;

// Add base64 byte to comm buffer
procedure TBase64(x: byte);
const
  Base64Chr: array [0..63] of byte =
  ($41,$42,$43,$44,$45,$46,$47,$48,$49,$4A,$4B,$4C,$4D,$4E,$4F,$50,$51,$52,$53,$54,$55,$56,$57,$58,$59,$5A,
   $61,$62,$63,$64,$65,$66,$67,$68,$69,$6A,$6B,$6C,$6D,$6E,$6F,$70,$71,$72,$73,$74,$75,$76,$77,$78,$79,$7A,
   $30,$31,$32,$33,$34,$35,$36,$37,$38,$39,$2B,$2F);
begin
  TByte(Base64Chr[x]);
end;

// Add byte to comm buffer
procedure TByte(x: byte);
begin
  TxBuff[TxBuffLength] := x;
  Inc(TxBuffLength);
  if TxBuffLength = TxBuffSize then TComm;
end;

// Transmit comm buffer
procedure TComm;
var
  BytesWritten: cardinal;
begin
  if not WriteFile(CommHandle, TxBuff, TxBuffLength, BytesWritten, nil) then
    CommError('Unable to write to');
  if BytesWritten <> TxBuffLength then
    CommError('Transmit stall on');
  TxBuffLength := 0;
end;

// Receive comm byte
function RByte: byte;
var
  Ticks: cardinal;
begin
  Ticks := GetTickCount;
  while GetTickCount - Ticks < 100 do
  begin
    if RxBuffStart = RxBuffEnd then RComm;
    if RxBuffStart <> RxBuffEnd then
    begin
      Result := RxBuff[RxBuffStart];
      Inc(RxBuffStart);
      Exit;
    end;
  end;
  CommError('Hardware lost on');
end;

// Check for received byte(s)
function RCheck: boolean;
begin
  if RxBuffStart = RxBuffEnd then RComm;
  Result := RxBuffStart <> RxBuffEnd
end;

// Get received byte
function RGet : byte;
begin
  Result := RxBuff[RxBuffStart];
  Inc(RxBuffStart);
end;

// Receive any data into comm buffer
procedure RComm;
begin
  RxBuffStart := 0;
  RxBuffEnd := 0;
  if not ReadFile(CommHandle, RxBuff, RxBuffSize, RxBuffEnd, nil) then
    CommError('Unable to read from');
end;

// Receive any DEBUG data into debug buffer
procedure ReceiveDebugData;
begin
  RxBuffEnd := 0;
  if ReadFile(CommHandle, RxBuff, RxBuffSize, RxBuffEnd, nil) then
  begin
    if RxBuffEnd > 0 then
    begin
      if DebugBuffHead + RxBuffEnd > DebugBuffSize then
      begin
        Move(RxBuff[0], DebugBuff[DebugBuffHead], DebugBuffSize - DebugBuffHead);
        Move(RxBuff[DebugBuffSize - DebugBuffHead], DebugBuff[0], RxBuffEnd - (DebugBuffSize - DebugBuffHead));
      end
      else
      begin
        Move(RxBuff[0], DebugBuff[DebugBuffHead], RxBuffEnd);
      end;
      DebugBuffHead := (DebugBuffHead + RxBuffEnd) and DebugBuffMask;
    end;
  end
  else
    CommError('Unable to read from');
end;

// Comm error
procedure CommError(Msg: string);
begin
  if CommOpen then CloseComm;
  if AbortMode then
  begin
    ProgressForm.Hide;
    if not BatchMode then MessageDlg(Msg + ' ' + CommString + '.', mtError, [mbOK], 0);
  end;
  Abort;
end;

// Close comm port
procedure CloseComm;
begin
  CloseHandle(CommHandle);
  CommOpen := False;
end;

// Return comm port string
function CommString: string;
begin
  Result := 'COM' + IntToStr(CommPort);
end;

// Wait milliseconds
procedure Waitms(ms: cardinal);
var
  Ticks: cardinal;
begin
  Ticks := GetTickCount;
  while GetTickCount - Ticks < ms do;
end;

end.

