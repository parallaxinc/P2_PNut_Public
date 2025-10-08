unit DebugUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls,
  SerialUnit, DebugDisplayUnit, DebuggerUnit;

type
  TDebugForm = class(TForm)

  procedure FormCreate(Sender: TObject);
  procedure FormResize(Sender: TObject);
  procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure FormClose(Sender: TObject; var Action: TCloseAction);

  procedure ResetDisplays;
  procedure CloseDisplays;
  procedure ResizeDisplay;
  procedure CloseLogFile;
  procedure ChrIn(x: byte);
  procedure NewChr(x: byte);
  procedure NewLine;
end;

var
  DebugForm             : TDebugForm;

  LogFile               : TextFile;
  LogFileOpen           : boolean;
  LogFileSize           : integer;

  DebuggerForm          : array[0..7] of TDebuggerForm;
  DebuggerEna           : integer;      // 8 bitwise enables

  DisplayForm           : array[0..31] of TDebugDisplayForm;
  DisplayStrFlag        : boolean;
  DisplayStrLen         : integer;

  LineChrs              : array[0..4095] of byte;

  SrcRect               : TRect;
  DstRect               : TRect;

  TextLeft              : integer;
  TextTop               : integer;

  Cols                  : integer;
  Col                   : integer;

implementation

uses GlobalUnit;

{$R *.dfm}

//////////////////////
//  Event Routines  //
//////////////////////

procedure TDebugForm.FormCreate(Sender: TObject);
var i: integer;
begin
  // Hide the 'minimize' button
  i := GetWindowLongA(Self.Handle, GWL_STYLE);
  i := SetWindowLongA(Self.Handle, GWL_STYLE, i and not WS_MINIMIZEBOX);
  // Set initial size
  Left   := Screen.Width div 4;
  Top    := Screen.Height * 3 div 4;
  Width  := Screen.Width div 2;
  Height := Screen.Height * 3 div 16;
  // Disable debugger
  DebuggerEna := 0;
  LastDebugTick := 0;
  RequestCOGBRK := 0;
end;

procedure TDebugForm.FormResize(Sender: TObject);
begin
  ResizeDisplay;
end;

procedure TDebugForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Close;
end;

procedure TDebugForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CloseDisplays;
  CloseLogFile;
  DebugActive := False;
end;

////////////////////////
//  Display Routines  //
////////////////////////

// Reset display variables
procedure TDebugForm.ResetDisplays;
begin
  // Close any open displays and reset state
  CloseDisplays;
  P2ResetDebugSymbols;
  DisplayStrFlag := False;
  // Set window position and size
  if P2.DebugLeft   >= 0 then Left   := P2.DebugLeft;
  if P2.DebugTop    >= 0 then Top    := P2.DebugTop;
  if P2.DebugWidth  >= 0 then Width  := P2.DebugWidth;
  if P2.DebugHeight >= 0 then Height := P2.DebugHeight;
  ResizeDisplay;
  // Start log file?
  if P2.DebugLogSize > 0 then
  begin
    CloseLogFile;
    AssignFile(LogFile, 'DEBUG.log');
    ReWrite(LogFile);
    LogFileOpen := True;
    LogFileSize := 0;
  end;
  Show;
end;

// Close any open display/debugger windows
procedure TDebugForm.CloseDisplays;
var i: integer;
begin
  // Close any open displays
  for i := 0 to 31 do if P2.DebugDisplayEna shr i and 1 = 1 then DisplayForm[i].Free;
  P2.DebugDisplayEna := 0;
  // Close any open debuggers
  for i := 0 to 7 do if DebuggerEna shr i and 1 = 1 then DebuggerForm[i].Free;
  DebuggerEna := 0;
end;

// Resize display
procedure TDebugForm.ResizeDisplay;
var
  ChrWidth, ChrHeight, ColIndent, RowIndent, Rows: integer;
begin
  // Set font properties
  Canvas.Font.Name := FontName;
  Canvas.Font.Size := FontSize;
  Canvas.Font.Color := clLime;
  Canvas.Font.Style := [];
  Canvas.Brush.Color := clBlack;
  // Get text metrics
  ChrWidth := Canvas.TextWidth('X');
  ChrHeight := Canvas.TextHeight('X');
  // Compute column and row indents
  ColIndent := ChrWidth shr 1;
  RowIndent := ChrHeight shr 2;
  // Compute columns and rows
  Cols := (ClientWidth - ColIndent) div ChrWidth;
  Rows := (ClientHeight - RowIndent * 2) div ChrHeight;
  MinLimit(Cols, 0);
  MinLimit(Rows, 0);
  // Clear display
  Canvas.FillRect(Rect(0, 0, ClientWidth, ClientHeight));
  // Make source and destination rectangles for scrolling
  DstRect := Rect(0, RowIndent, ClientWidth, RowIndent + (Rows - 1) * ChrHeight);
  SrcRect := Rect(0, RowIndent + ChrHeight, ClientWidth, RowIndent + Rows * ChrHeight);
  // Make text output coordinates
  TextLeft := ColIndent;
  TextTop := DstRect.Bottom;
  // Reset column
  Col := 0;
end;

procedure TDebugForm.CloseLogFile;
begin
  if LogFileOpen then CloseFile(LogFile);
  LogFileOpen := False;
end;

// Receive character
procedure TDebugForm.ChrIn(x: byte);
var
  i, j: integer;
begin
  // start of debugger message or end of session?
  if x < 8 then
  begin
    ReturnRByte;
    if DebuggerEna shr x and 1 = 0 then
    begin
      DebuggerID := x;
      DebuggerForm[x] := TDebuggerForm.Create(Application);
      DebuggerEna := DebuggerEna or 1 shl x;
    end;
    LastDebugTick := GetTickCount;
    DebuggerForm[x].Breakpoint;
    Exit;
  end;
  // end if debug session?
  if x = 27 then
  begin
    DebugActive := False;
    Close;
    Exit;
  end;
  // start of display string?
  if (x = $60) and not DisplayStrFlag then
  begin
    DisplayStrLen := 0;
    DisplayStrFlag := True;
  end
  // body of display string?
  else if DisplayStrFlag then
  begin
    if DisplayStrLen < DebugStringLimit then
    begin
      if x <> 13 then
      begin
        P2.DebugDisplayStr[DisplayStrLen] := x;
        Inc(DisplayStrLen);
      end
      else
      begin
        P2.DebugDisplayStr[DisplayStrLen] := 0;
        P2ParseDebugString;
        DisplayStrFlag := False;
        // start new debug display?
        if P2.DebugDisplayType[0] = 1 then
        begin
          DisplayForm[P2.DebugDisplayNew] := TDebugDisplayForm.Create(Application);
          SetFocus;             // return focus to this form
        end
        else
        // update existing debug display(s)?
        if P2.DebugDisplayType[0] = 2 then
        begin
          for i := 0 to P2.DebugDisplayTargs - 1 do
          begin
            j := P2.DebugDisplayValue[i];
            DisplayForm[j].UpdateDisplay(P2.DebugDisplayTargs);
            if P2.DebugDisplayEna shr j and 1 = 0 then DisplayForm[j].Close;     // free display if closed by command
          end;
        end;
      end;
    end
    else if x = 13 then DisplayStrFlag := False;
  end;
  // Update window
  if (x >= $20) and (x <= $7F) then NewChr(x)
  else if x = 13 then NewLine
  else if x = 9 then repeat NewChr($20) until (Col and 7) = 0;
  // Update log file
  if LogFileOpen then
  begin
    Write(LogFile, Chr(x));
    Inc(LogFileSize);
    if LogFileSize >= P2.DebugLogSize then CloseLogFile;
  end;
end;

// Output new character to screen
procedure TDebugForm.NewChr(x: byte);
begin
  LineChrs[Col] := x;
  Col := Col + 1;
  if Col = Cols then NewLine;
end;

// Output new line to screen
procedure TDebugForm.NewLine;
begin
  FillChar(LineChrs[Col], Cols - Col + 1, $20);         // fill remainder of line + 1 with spaces
  LineChrs[Cols + 1] := 0;                              // ready to print one extra space to overwrite text dithering
  Canvas.CopyRect(DstRect, Canvas, SrcRect);            // scroll image on canvas
  Canvas.TextOut(TextLeft, TextTop, PChar(@LineChrs));  // print new bottom line
  Col := 0;                                             // reset column
end;

end.
