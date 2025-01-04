unit EditorUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls, Printers,
  Menus, Dialogs, ComCtrls, Math, AppEvnts;

const
  FormatPC = 0;
  FormatLinux = 1;
  FormatMac = 2;
  MinFontSize = 1;
  MaxFontSize = 72;
  ClickTime = 500;

  cObjOn = True;       // Compile flags
  cObjOff = False;
  cListOn = True;
  cListOff = False;
  cDocOn = True;
  cDocOff = False;

type
  TEditorForm = class(TForm)

    MainMenu: TMainMenu;
      FileMenu: TMenuItem;
        FileNewItem: TMenuItem;
        FileOpenItem: TMenuItem;
        FileSaveItem: TMenuItem;
        FileSaveAsItem: TMenuItem;
                FileN1: TMenuItem;
        FileSelectTopIFiletem: TMenuItem;
                FileN2: TMenuItem;
        FileListToggleItem: TMenuItem;
        FileListToggleDebugItem: TMenuItem;
        FileDocToggleItem: TMenuItem;
                FileN3: TMenuItem;
        FilePrintItem: TMenuItem;
                FileN4: TMenuItem;
        FileExitItem: TMenuItem;
      EditMenu: TMenuItem;
        EditCutItem: TMenuItem;
        EditCopyItem: TMenuItem;
        EditPasteItem: TMenuItem;
        EditSelectAllItem: TMenuItem;
                EditN1: TMenuItem;
        EditFindReplaceItem: TMenuItem;
        EditFindItem: TMenuItem;
        EditReplaceItem: TMenuItem;
                EditN2: TMenuItem;
        EditTextBiggerItem: TMenuItem;
        EditTextSmallerItem: TMenuItem;
      RunMenu: TMenuItem;
        RunCompileItem: TMenuItem;
        RunCompileDebugItem: TMenuItem;
        RunCompileLoadItem: TMenuItem;
        RunCompileLoadDebugItem: TMenuItem;
        RunCompileProgramItem: TMenuItem;
        RunCompileProgramDebugItem: TMenuItem;
        RunDebugToggleItem: TMenuItem;
                RunN1: TMenuItem;
        RunAutoSaveItem: TMenuItem;
        RunGenerateBinaryItem: TMenuItem;
                RunN2: TMenuItem;
        RunGetHardwareItem: TMenuItem;
        RunChangePortItem: TMenuItem;
                RunN3: TMenuItem;
        RunComposeRomItem: TMenuItem;
      HelpMenu: TMenuItem;
        HelpAboutItem: TMenuItem;

    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    StatusBar: TStatusBar;
    CursorTimer: TTimer;
    SelectTimer: TTimer;
    DebugTimer: TTimer;

  procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
  procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;

  procedure FormCreate(Sender: TObject);
  procedure FormDestroy(Sender: TObject);
  procedure FormShow(Sender: TObject);
  procedure FormResize(Sender: TObject);
  procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
  procedure FormKeyPress(Sender: TObject; var Key: Char);
  procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  procedure FormPaint(Sender: TObject);
  procedure ShowHint(Sender: TObject);
  procedure CursorTimerTick(Sender: TObject);
  procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
  procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  procedure SelectTimerTick(Sender: TObject);

  procedure FileNew(Sender: TObject);
  procedure FileOpenItemClick(Sender: TObject);
  procedure FileSave(Sender: TObject);
  procedure FileSaveAs(Sender: TObject);
  procedure FileSelectTopIFiletemClick(Sender: TObject);
  procedure FileListToggle(Sender: TObject);
  procedure FileListToggleDebug(Sender: TObject);
  procedure FileDocToggle(Sender: TObject);
  procedure FilePrint(Sender: TObject);
  procedure FileExit(Sender: TObject);
  procedure EditCut(Sender: TObject);
  procedure EditCopy(Sender: TObject);
  procedure EditPaste(Sender: TObject);
  procedure EditSelectAll(Sender: TObject);
  procedure EditFindReplace(Sender: TObject);
  procedure EditFind(Sender: TObject);
  procedure EditReplace(Sender: TObject);
  procedure EditTextBigger(Sender: TObject);
  procedure EditTextSmaller(Sender: TObject);
  procedure RunMenuClick(Sender: TObject);
  procedure RunCompile(Sender: TObject);
  procedure RunCompileDebug(Sender: TObject);
  procedure RunCompileLoad(Sender: TObject);
  procedure RunCompileLoadDebug(Sender: TObject);
  procedure RunCompileProgram(Sender: TObject);
  procedure RunCompileProgramDebug(Sender: TObject);
  procedure RunDebugToggle(Sender: TObject);
  procedure RunAutoSave(Sender: TObject);
  procedure RunGenerateBinary(Sender: TObject);
  procedure RunGetHardware(Sender: TObject);
  procedure RunChangePort(Sender: TObject);
  procedure RunComposeRom(Sender: TObject);
  procedure HelpAbout(Sender: TObject);

  function  GoLeft: boolean;
  function  GoRight: boolean;
  procedure GoUp;
  procedure GoDown;
  procedure GoHome;
  procedure GoEnd;
  procedure SetMark;
  function  IsWord: boolean;
  function  EditRead: byte;
  procedure EditDelete(Start, Finish: integer);
  function  GetColumn: integer;
  procedure MatchColumn;
  procedure DecFlags;

  procedure EditInsert(b: byte);
  procedure EditInsertString(s: string);
  procedure EditSlice;

  procedure MakeDisplayLine(var Position: integer);
  function  DisplayLineChanged(Line: integer): boolean;
  procedure MakeTextRect(Line: integer; var Column: integer; var Style: byte; var Rectangle: TRect; var Left: integer; var Top: integer);

  procedure ResetColumn;
  procedure ResizeDisplay;

  procedure ShowCursor;
  procedure HideCursor;
  procedure ToggleCursor;

  function  DeleteSelection: boolean;
  function  GetSelection(var Start, Finish: integer): boolean;
  function  IsSelection: boolean;

  function  MouseInColumns(X: integer; var Column: integer): boolean;
  function  MouseInRows(Y: integer; var Row: integer): boolean;

  procedure NewFile;
  procedure LoadEditorFile(const Filename: string);
  procedure SaveEditorFile(const Filename: string);
  procedure AdjustInputFileCRLF;
  procedure AdjustOutputFileCRLF;

  procedure SetFilename(const NewFilename: string);
  procedure SetExtFileMode(Ext: string; EditBuffer: pointer; Limit, Length: integer);
  procedure CancelExtFileMode;
  function  CheckFileSave: boolean;

  function  GetErrorLine: integer;
  procedure WriteErrorFile(s: string);

  procedure DoPrint;
  function  PrintPage(Finish: integer): boolean;

  procedure CutToClipBoard;
  procedure CopyToClipBoard;
  procedure PasteFromClipBoard;

  function  Find: boolean;
  function  Replace: boolean;

  procedure SetDirectories;
  procedure Compile(cObj, cList, cDoc: boolean);
  procedure CompileRecursively(Filename: string; Level: integer; cObj, cList, cDoc: boolean);
  procedure CompilerError(ErrorMsg: string);
  procedure LoadCompilerFile(Filename: string);
  procedure SaveFile(Filename: string; Start: Pointer; Bytes: integer);
  procedure ComposeRAM(ProgramFlash, DownloadToRAM: boolean);
  procedure ComposeROM;
  procedure LoadObj(Filename: string);
  procedure LoadBin(Filename: string);

  function  NeedToStopDebugFirst: boolean;
  procedure DebugTimerTick(Sender: TObject);
end;

var
  EditorForm: TEditorForm;

  FileFormat: integer;

  CurrentFilename: string;
  TopFilename: string;

  TopDir: string;
  CurrentDir: string;
  LibraryDir: string;

  ExtFileMode: boolean;

  Edit: PByteArray;
  EditLimit: integer;
  EditPos: integer;
  EditLength: integer;
  EditSplit: integer;

  EditMark: integer;
  EditMarkFlag: byte;

  EditTop: integer;
  EditPan: integer;

  ActiveColumns: integer;
  ActiveRows: integer;

  DrawnColumns: integer;
  DrawnRows: integer;

  EditColumn: integer;
  EditColumnFlag: byte;

  CursorColumn: integer;
  CursorRow: integer;
  CursorState: byte;
  CursorEnabled: boolean;

  EditFlag: boolean;

  DrawnData: PByteArray;
  DrawnDataSize: integer;

  EditorRect: TRect;

  ChrWidth: integer;
  ChrHeight: integer;

  ColumnIndent: integer;
  RowIndent: integer;

  SelectColumns: integer;
  SelectRows: integer;

  MouseIsDown: boolean;
  Click1: cardinal;
  Click2: cardinal;
  Click3: cardinal;

  UpdateAll: boolean;
  UpdateEditor: boolean;

  SourceLength: integer;
  SourceSplit: integer;
  SourceFilename: string;

  SourceEditPos: integer;
  SourceEditTop: integer;
  SourceEditPan: integer;

  DebugPostActive: boolean;
  DebugPost: procedure(Sender: TObject) of object;


implementation

uses ShellAPI, GlobalUnit, PrintUnit, PrintStatusUnit, FindReplaceUnit,
     AboutUnit, ProgressUnit, SerialUnit, ComUnit, DebugUnit, InfoUnit;

{$R *.DFM}

procedure TEditorForm.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  inherited;
  Msg.Result := Msg.Result or DLGC_WANTTAB;
end;

procedure TEditorForm.WMDropFiles(var Msg: TWMDropFiles);
var
  Filename: array[0..MAX_PATH] of Char;
begin
  try
    if DragQueryFile(Msg.Drop, 0, Filename, MAX_PATH) > 0 then
    begin
      CheckFileSave;
      LoadEditorFile(Filename);
      Msg.Result := 0;
    end;
  finally
    DragFinish(Msg.Drop);
  end;
end;

procedure TEditorForm.FormCreate(Sender: TObject);
begin
  DrawnData := nil;

  P2 := P2InitStruct;
  P2.List := @ListBuffer;
  P2.ListLimit := ListLimit;
  P2.Doc := @DocBuffer;
  P2.DocLimit := DocLimit;

  Edit := @SourceBuffer;
  EditLimit := SourceLimit;

  FileFormat := FormatPC;

  UpdateEditor := True;
  ExtFileMode := False;

  CommOpen := False;
  CommPort := 1;

  BeginTimeBase;

  Application.OnHint := ShowHint;
end;

procedure TEditorForm.FormDestroy(Sender: TObject);
begin
  EndTimeBase;
end;

procedure TEditorForm.FormShow(Sender: TObject);
begin
  BatchMode := False;
  ExitCode := 0;

  Click1 := ClickTime * 0;
  Click2 := ClickTime * 1;
  Click3 := ClickTime * 2;

  PrintForm.FontSize := 9;

  FontName := 'Consolas';
  if FontName <> 'Consolas' then FontName := 'Courier New';
  FontSize := 10;

  SetBounds(0, 0, Screen.Width * 3 div 4, Screen.Height * 3 div 4);

  ResizeDisplay;

  DragAcceptFiles(Handle, True);

  if (ParamCount = 1) and (ParamStr(1) = '-rom') then
  begin
    RunN3.Visible := True;
    RunComposeRomItem.Visible := True;
  end
  else if (ParamCount = 2) and (FileExists(ParamStr(1) + '.bin') or FileExists(ParamStr(1))) and
    ((ParamStr(2) = '-b') or (ParamStr(2) = '-bd')) then
  begin
    if FileExists(ParamStr(1) + '.bin') then
      LoadBin(ExpandFilename(ParamStr(1) + '.bin'))
    else
      LoadBin(ExpandFilename(ParamStr(1)));
    P2.DebugMode := (ParamStr(2) = '-bd');      // establish debug settings
    P2.DebugBaud := P2.DownloadBaud;
    P2.DebugLeft := 0;
    P2.DebugTop := 0;
    P2.DebugWidth := Screen.Width;
    P2.DebugHeight := 200;
    P2.DebugDisplayLeft := 0;
    P2.DebugDisplayTop := 210;
    P2.DebugLogSize := 0;
    try
      LoadHardware;
    except
      WriteErrorFile('serial_error');
      ExitCode := 1;
      Close;
      Exit;
    end;
    WriteErrorFile('okay');
    Close;
    Exit;
  end
  else if (ParamCount >= 1) and (FileExists(ParamStr(1) + '.spin2') or FileExists(ParamStr(1))) then
  begin
    if FileExists(ParamStr(1) + '.spin2') then
      TopFilename := ExpandFilename(ParamStr(1) + '.spin2')
    else
      TopFilename := ExpandFilename(ParamStr(1));
    LoadEditorFile(TopFilename);
    if (ParamCount = 2) and ( (ParamStr(2) = '-c' ) or
                              (ParamStr(2) = '-cd') or
                              (ParamStr(2) = '-cf') or
                              (ParamStr(2) = '-cb') or
                              (ParamStr(2) = '-r' ) or
                              (ParamStr(2) = '-rd') or
                              (ParamStr(2) = '-f' ) or
                              (ParamStr(2) = '-fd') ) then
    begin
      BatchMode := True;
      try
        P2.DebugMode := (ParamStr(2) = '-cd') or
                        (ParamStr(2) = '-cb') or
                        (ParamStr(2) = '-rd') or
                        (ParamStr(2) = '-fd');
        Compile(cObjOn, cListOn, cDocOff); // aborts if error
      except
        WriteErrorFile(CurrentFilename + ':' + IntToStr(GetErrorLine) + ':error:' + P2.ErrorMsg);
        ExitCode := 1;
        Close;
        Exit;
      end;
      try
        RunGenerateBinaryItem.Checked := True;
        ComposeRAM(
          (ParamStr(2) = '-cf') or (ParamStr(2) = '-cb') or (ParamStr(2) = '-f') or (ParamStr(2) = '-fd'),
          (ParamStr(2) = '-r')  or (ParamStr(2) = '-rd') or (ParamStr(2) = '-f') or (ParamStr(2) = '-fd'));
      except
        WriteErrorFile('serial_error');
        ExitCode := 1;
        Close;
        Exit;
      end;
      WriteErrorFile('okay');
      Close;
      Exit;
    end
    else
      WriteErrorFile('okay');
  end
  else if (ParamCount >= 1) and (ParamStr(1) = '-debug') then
  begin
    BatchMode := True;
    if (ParamCount >= 2) then                   // get CommPort?
      CommPort := StrToInt(ParamStr(2));
    P2.DownloadBaud := DefaultBaud;             // get DebugBaud?
    if (ParamCount >= 3) then
      P2.DownloadBaud := StrToInt(ParamStr(3));
    P2.DebugBaud := P2.DownloadBaud;            // establish other debug settings
    P2.DebugLeft := 0;
    P2.DebugTop := 0;
    P2.DebugWidth := Screen.Width;
    P2.DebugHeight := 200;
    P2.DebugDisplayLeft := 0;
    P2.DebugDisplayTop := 210;
    P2.DebugLogSize := 0;
    try
      StartDebug;
    except
      WriteErrorFile('serial_error');
      ExitCode := 1;
      Close;
      Exit;
    end;
    WriteErrorFile('okay');
    Close;
    Exit;
  end
  else
  begin
    WriteErrorFile('okay');
    TopFilename := '';
    FileNew(Sender);
  end;
end;

procedure TEditorForm.FormResize(Sender: TObject);
begin
  if ComponentState <> [csDestroying] then ResizeDisplay
  else if DrawnData <> nil then FreeMem(DrawnData);
end;

procedure TEditorForm.FormPaint(Sender: TObject);
begin
  UpdateAll := True;
  ShowCursor;
end;

procedure TEditorForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  DebugActive := False;         // end debug thread

  CancelExtFileMode;            // file need saving?
  try
    CheckFileSave;
  except
    CanClose := False;
  end;
end;

procedure TEditorForm.ShowHint(Sender: TObject);
begin
  if Length(Application.Hint) > 0 then
    StatusBar.SimpleText := Application.Hint
  else StatusBar.SimpleText := '';
end;

procedure TEditorForm.FormKeyPress(Sender: TObject; var Key: Char);
var
  k: byte;
begin
  // if mouse select in progress, exit
  if MouseIsDown then Exit;

  k := Byte(Key);
  if (k in [kTab, kEnter, kSpace..$7E, $80..$FF]) then
  begin
    DeleteSelection;
    EditInsert(k);
    DecFlags;
    HideCursor;
    ShowCursor;
  end;
end;

procedure TEditorForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  i, j: integer;
  sNone, sCtrl, sShift, sCtrlShift: boolean;
begin
  // if mouse select in progress, exit
  if MouseIsDown then Exit;

  // Make shift-state booleans
  sNone := not(ssShift in Shift) and not(ssCtrl in Shift);
  sCtrl := not(ssShift in Shift) and (ssCtrl in Shift);
  sShift := (ssShift in Shift) and not(ssCtrl in Shift);
  sCtrlShift := (ssShift in Shift) and (ssCtrl in Shift);

  // Process editor key
  case Key of

    // BackSpace key
    kBackSpace:
    begin
      // Delete marked text?
      if not DeleteSelection then
      begin
        // BackSpace?
        if sNone then if GoLeft then EditDelete(EditPos, EditPos + 1);
        // Delete to line start?
        if sShift then
        begin
          //i := EditPos;
          //GoHome;
          //if EditPos <> i then EditDelete(EditPos, i);
        end;
        // Delete line?
        if sCtrl then
        begin
          //GoHome;
          //i := EditPos;
          //GoEnd;
          //GoRight;
          //if EditPos <> i then EditDelete(i, EditPos);
        end;
        // Delete to file start?
        //if sCtrlShift then if GoLeft then EditDelete(0, EditPos + 1);
      end;
    end;

    // Delete key
    kDelete:
    begin
      // Delete marked text?
      if not DeleteSelection then
      begin
        // Delete?
        if sNone and (EditPos <> EditLength) then EditDelete(EditPos, EditPos + 1);
        // Delete to line end?
        if sShift then
        begin
          //i := EditPos;
          //GoEnd;
          //if EditPos <> i then EditDelete(i, EditPos);
        end;
        // Delete line?
        if sCtrl then
        begin
          //GoHome;
          //i := EditPos;
          //GoEnd;
          //GoRight;
          //if EditPos <> i then EditDelete(i, EditPos);
        end;
        // Delete to file end?
        //if sCtrlShift then if EditPos <> EditLength then EditDelete(EditPos, EditLength);
      end;
    end;

    // Left key
    kLeft:
    begin
      // Mark?
      if sShift or sCtrlShift then SetMark;
      // Left?
      if sNone or sShift then GoLeft
      // Left word
      else
      begin
        i := EditPos;
        repeat
          if IsWord then
          begin
            j := EditPos;
            EditPos := EditMark;
            EditMark := j;
            if EditPos <> i then Break;
          end;
          if not GoLeft then
          begin
            EditMarkFlag := 0;
            Break;
          end;
        until False;
      end;
    end;

    // Right key
    kRight:
    begin
      // Mark?
      if sShift or sCtrlShift then SetMark;
      // Right?
      if sNone or sShift then GoRight
      // right word
      else
      begin
        i := EditPos;
        repeat
          if IsWord then if EditPos <> i then Break;
          if not GoRight then
          begin
            EditMarkFlag := 0;
            Break;
          end;
        until False;
      end;
    end;

    // Up key
    kUp:
    begin
      // Mark?
      if sShift then SetMark;
      // Up?
      if sNone or sShift then
      begin
        if EditColumnFlag = 0 then EditColumn := GetColumn;
        EditColumnFlag := 2;
        GoUp;
        MatchColumn;
      end;
      // Invalid?
      if sCtrl or sCtrlShift then Exit;
    end;

    // Down key
    kDown:
    begin
      // Mark?
      if sShift then SetMark;
      // Down?
      if sNone or sShift then
      begin
        if EditColumnFlag = 0 then EditColumn := GetColumn;
        EditColumnFlag := 2;
        GoDown;
        MatchColumn;
      end;
      // Invalid?
      if sCtrl or sCtrlShift then Exit;
    end;

    // Home key
    kHome:
    begin
      // Mark?
      if sShift or sCtrlShift then SetMark;
      // Home?
      if sNone or sShift then GoHome
      // File start
      else EditPos := 0;
    end;

    // End key
    kEnd:
    begin
      // Mark?
      if sShift or sCtrlShift then SetMark;
      // End?
      if sNone or sShift then GoEnd
      // File end
      else EditPos := EditLength;
    end;

    // PageUp key
    kPageUp:
    begin
      // Mark?
      if sShift or sCtrlShift then SetMark;
      // PageUp?
      if sNone or sShift then
      begin
        if EditPos <> EditTop then EditPos := EditTop
        else for i := 1 to ActiveRows do GoUp;
      end
      // File start
      else EditPos := 0;
    end;

    // PageDown key
    kPageDown:
    begin
      // Mark?
      if sShift or sCtrlShift then SetMark;
      // PageDown?
      if sNone or sShift then
      begin
        i := EditPos;
        EditPos := EditTop;
        for j := 1 to ActiveRows - 1 do GoDown;
        if EditPos <= i then for j := 1 to ActiveRows do GoDown;
      end
      // File end
      else EditPos := EditLength;
    end

    // if none of the above, exit
    else Exit;
  end;

  // else, update display
  DecFlags;
  HideCursor;
  ShowCursor;
end;

//////////////////////
//  Menu Responses  //
//////////////////////

procedure TEditorForm.FileNew(Sender: TObject);
begin
  CancelExtFileMode;
  CheckFileSave;
  NewFile;
  SetFilename(IncludeTrailingPathDelimiter(GetCurrentDir) + 'Untitled.spin2');
end;

procedure TEditorForm.FileOpenItemClick(Sender: TObject);
begin
  CancelExtFileMode;
  CheckFileSave;
  OpenDialog.Title := 'Open File';
  if OpenDialog.Execute then LoadEditorFile(OpenDialog.Filename);
end;

procedure TEditorForm.FileSave(Sender: TObject);
begin
  if CurrentFilename = 'Untitled.spin2' then FileSaveAs(Sender)
    else SaveEditorFile(CurrentFilename);
end;

procedure TEditorForm.FileSaveAs(Sender: TObject);
begin
  if not SaveDialog.Execute then Exit;
  if FileExists(SaveDialog.Filename) then
    if MessageDlg('OK to overwrite ' + SaveDialog.Filename, mtConfirmation, mbYesNoCancel, 0) <> idYes then Exit;
  SaveEditorFile(SaveDialog.Filename);
  SetFilename(SaveDialog.Filename);
end;

procedure TEditorForm.FileSelectTopIFiletemClick(Sender: TObject);
begin
  OpenDialog.Title := 'Select Top File';
  if OpenDialog.Execute then TopFilename := OpenDialog.Filename;
  SetFilename(CurrentFilename);
end;

procedure TEditorForm.FileListToggle(Sender: TObject);
begin
  if ExtFileMode then CancelExtFileMode
  else
  begin
    P2.DebugMode := False;
    Compile(cObjOff, cListOn, cDocOff);  // aborts if error
    SetExtFileMode('lst', @ListBuffer, ListLimit, P2.ListLength);
    FileListToggleItem.Checked := True;
    Hint := 'List Mode - Type Ctrl+L to return to source';
  end;
end;

procedure TEditorForm.FileListToggleDebug(Sender: TObject);
begin
  if ExtFileMode then CancelExtFileMode
  else
  begin
    P2.DebugMode := True;
    Compile(cObjOff, cListOn, cDocOff);  // aborts if error
    SetExtFileMode('lst', @ListBuffer, ListLimit, P2.ListLength);
    FileListToggleDebugItem.Checked := True;
    Hint := 'List Mode - Type Ctrl+L to return to source';
  end;
end;

procedure TEditorForm.FileDocToggle(Sender: TObject);
begin
  if ExtFileMode then CancelExtFileMode
  else
  begin
    P2.DebugMode := False;
    Compile(cObjOff, cListOff, cDocOn);  // aborts if error
    SetExtFileMode('txt', @DocBuffer, DocLimit, P2.DocLength);
    FileDocToggleItem.Checked := True;
    Hint := 'Documentation Mode - Type Ctrl+D to return to source';
  end;
end;

procedure TEditorForm.FilePrint(Sender: TObject);
begin
  DoPrint;
end;

procedure TEditorForm.FileExit(Sender: TObject);
begin
  Close;
end;

procedure TEditorForm.EditCut(Sender: TObject);
begin
  HideCursor;
  CutToClipBoard;
  ShowCursor;
end;

procedure TEditorForm.EditCopy(Sender: TObject);
begin
  HideCursor;
  CopyToClipBoard;
  ShowCursor;
end;

procedure TEditorForm.EditPaste(Sender: TObject);
begin
  HideCursor;
  PasteFromClipBoard;
  ShowCursor;
end;

procedure TEditorForm.EditSelectAll(Sender: TObject);
begin
  EditPos := 0;
  EditMark := EditLength;
  EditMarkFlag := 1;
  HideCursor;
  ShowCursor;
end;

procedure TEditorForm.EditFindReplace(Sender: TObject);
begin
  FindReplaceForm.ReplaceButton.Enabled := IsSelection;
  case FindReplaceForm.ShowModal of
    mrOk:
    begin
      if FindReplaceForm.StartCheckBox.Checked then EditPos := 0;
      EditFind(Sender);
    end;
    mrRetry: EditReplace(Sender);
    mrAll:
    begin
      HideCursor;
      if FindReplaceForm.StartCheckBox.Checked then EditPos := 0;
      if Find then
      begin
        repeat
          Replace;
        until not Find;
        ResetColumn;
      end
      else MessageDlg('Nothing Found', mtInformation, [mbOK], 0);
      ShowCursor;
    end;
    mrCancel: {nothing};
  end;
end;

procedure TEditorForm.EditFind(Sender: TObject);
begin
  HideCursor;
  if Length(FindReplaceForm.FindMemo.Text) = 0 then MessageDlg('Nothing to Find', mtInformation, [mbOK], 0)
  else if Find then ResetColumn else MessageDlg('Nothing Found', mtInformation, [mbOK], 0);
  ShowCursor;
end;

procedure TEditorForm.EditReplace(Sender: TObject);
begin
  HideCursor;
  if Replace then ResetColumn else MessageDlg('Nothing Selected', mtInformation, [mbOK], 0);
  ShowCursor;
end;

procedure TEditorForm.EditTextBigger(Sender: TObject);
begin
  Inc(FontSize);
  MaxLimit(FontSize, MaxFontSize);
  ResizeDisplay;
end;

procedure TEditorForm.EditTextSmaller(Sender: TObject);
begin
  Dec(FontSize);
  MinLimit(FontSize, MinFontSize);
  ResizeDisplay;
end;

procedure TEditorForm.RunMenuClick(Sender: TObject);
begin
  RunChangePortItem.Caption := 'C&hange from Port ' + CommString;
end;

procedure TEditorForm.RunCompile(Sender: TObject);
begin
  P2.DebugMode := False;
  Compile(cObjOff, cListOff, cDocOff); // aborts if error
  ComposeRAM(False, False);
  InfoForm.ShowModal;
end;

procedure TEditorForm.RunCompileDebug(Sender: TObject);
begin
  P2.DebugMode := True;
  Compile(cObjOff, cListOff, cDocOff); // aborts if error
  ComposeRAM(False, False);
  InfoForm.ShowModal;
end;

procedure TEditorForm.RunCompileLoad(Sender: TObject);
begin
  DebugPost := RunCompileLoad;
  DebugPostActive := True;
  if NeedToStopDebugFirst then Exit;
  P2.DebugMode := False;
  Compile(cObjOff, cListOff, cDocOff); // aborts if error
  ComposeRAM(False, True)
end;

procedure TEditorForm.RunCompileLoadDebug(Sender: TObject);
begin
  DebugPost := RunCompileLoadDebug;
  DebugPostActive := True;
  if NeedToStopDebugFirst then Exit;
  P2.DebugMode := True;
  Compile(cObjOff, cListOff, cDocOff); // aborts if error
  ComposeRAM(False, True)
end;

procedure TEditorForm.RunCompileProgram(Sender: TObject);
begin
  DebugPost := RunCompileProgram;
  DebugPostActive := True;
  if NeedToStopDebugFirst then Exit;
  P2.DebugMode := False;
  Compile(cObjOff, cListOff, cDocOff); // aborts if error
  ComposeRAM(True, True);
end;

procedure TEditorForm.RunCompileProgramDebug(Sender: TObject);
begin
  DebugPost := RunCompileProgramDebug;
  DebugPostActive := True;
  if NeedToStopDebugFirst then Exit;
  P2.DebugMode := True;
  Compile(cObjOff, cListOff, cDocOff); // aborts if error
  ComposeRAM(True, True);
end;

procedure TEditorForm.RunDebugToggle(Sender: TObject);
begin
  DebugPostActive := False;
  if NeedToStopDebugFirst then Exit;
  StartDebug;
end;

procedure TEditorForm.RunAutoSave(Sender: TObject);
begin
  RunAutoSaveItem.Checked := not RunAutoSaveItem.Checked;
end;

procedure TEditorForm.RunGenerateBinary(Sender: TObject);
begin
  RunGenerateBinaryItem.Checked := not RunGenerateBinaryItem.Checked;
end;

procedure TEditorForm.RunGetHardware(Sender: TObject);
begin
  GetHardwareVersion;
end;

procedure TEditorForm.RunChangePort(Sender: TObject);
begin
  ComForm.ShowModal;
end;

procedure TEditorForm.RunComposeRom(Sender: TObject);
begin
  FileNew(Sender);
  SetDirectories;
  LoadEditorFile(LibraryDir + 'ROM_Booter.spin2');
  P2.DebugMode := False;
  Compile(cObjOn, cListOff, cDocOff); //aborts if error
  FileNew(Sender);
  ComposeROM;
end;

procedure TEditorForm.HelpAbout(Sender: TObject);
begin
  SetDirectories;
  AboutForm.TopPathLabel.Caption := TopDir;
  AboutForm.CurrentPathLabel.Caption := CurrentDir;
  AboutForm.LibraryPathLabel.Caption := LibraryDir;
  AboutForm.ShowModal;
end;

////////////////////////
//  Support Routines  //
////////////////////////

function TEditorForm.GoLeft: boolean;
begin
  Result := EditPos <> 0;
  if Result then Dec(EditPos);
end;

function TEditorForm.GoRight: boolean;
begin
  Result := EditPos <> EditLength;
  if Result then Inc(EditPos);
end;

procedure TEditorForm.GoUp;
begin
  GoHome;
  GoLeft;
  GoHome;
end;

procedure TEditorForm.GoDown;
begin
  GoEnd;
  GoRight;
  GoHome;
end;

procedure TEditorForm.GoHome;
begin
  while GoLeft do
    if EditRead = 13 then
    begin
      GoRight;
      Break;
    end;
end;

procedure TEditorForm.GoEnd;
begin
  while EditRead <> 13 do
    if not GoRight then Break;
end;

procedure TEditorForm.SetMark;
begin
  if EditMarkFlag = 0 then EditMark := EditPos;
  EditMarkFlag := 2;
end;

function TEditorForm.IsWord: boolean;
begin
  Result := IsWordChr(Chr(EditRead));
  if not Result then Exit;
  while GoLeft do
    if not IsWordChr(Chr(EditRead)) then
    begin
      GoRight;
      Break;
    end;
  EditMark := EditPos;
  while GoRight do
   if not IsWordChr(Chr(EditRead)) then Break;
end;

function TEditorForm.GetColumn: integer;
var
  i: integer;
begin
  i := EditPos;
  GoHome;
  Result := 0;
  while EditPos <> i do
  begin
    if EditRead = 9 then Result := Result or 7;
    Inc(Result);
    GoRight;
  end;
end;

procedure TEditorForm.MatchColumn;
var
  x: integer;
  b: byte;
begin
  GoHome;
  x := 0;
  while EditColumn > x do
  begin
    b := EditRead;
    if b = 13 then Break;
    if b = 9 then x := x or 7;
    Inc(x);
    GoRight;
  end;
  if EditColumn < x then GoLeft;
end;

procedure TEditorForm.ResetColumn;
begin
  EditPan := 0;
  EditColumnFlag := 0;
end;

procedure TEditorForm.DecFlags;
begin
  EditMarkFlag := EditMarkFlag shr 1;
  EditColumnFlag := EditColumnFlag shr 1;
end;

///////////////////////
//  Buffer Routines  //
///////////////////////

function TEditorForm.EditRead: byte;
begin
  if EditPos < EditSplit then
    Result := Edit[EditPos]
  else
    Result := Edit[EditLimit - EditLength + EditPos];
end;

procedure TEditorForm.EditInsert(b: byte);
begin
  if (EditLength = EditLimit) {or ExtFileMode} then Exit;
  EditSlice;
  Edit[EditPos] := b;
  Inc(EditSplit);
  Inc(EditLength);
  Inc(EditPos);
  EditFlag := True;
end;

procedure TEditorForm.EditInsertString(s: string);
var
  i: integer;
begin
  for i := 1 to Length(s) do EditInsert(Byte(s[i]));
end;

procedure TEditorForm.EditDelete(Start, Finish: integer);
begin
  {if ExtFileMode then Exit;}
  EditPos := Start;
  EditSlice;
  Dec(EditLength, Finish - Start);
  EditMarkFlag := 0;
  EditFlag := True;
end;

procedure TEditorForm.EditSlice;
begin
  asm
               push    ebx
               push    esi
               push    edi

               mov     ebx,[Edit]              // get number of bytes to move
               mov     esi,[EditPos]
               mov     edi,[EditSplit]
               mov     ecx,esi
               sub     ecx,edi
               jz      @done                   // if nothing to move, done
               jb      @reverse                // forward or reverse move?

               mov     esi,[EditLimit]         // forward move
               sub     esi,[EditLength]
               add     esi,edi
               add     esi,ebx
               add     edi,ebx
               mov     eax,ecx
               shr     ecx,2
          rep  movsd
               mov     ecx,eax
               and     ecx,3
          rep  movsb
               jmp     @update

@reverse:      neg     ecx                     // reverse move
               mov     edi,[EditLimit]
               sub     edi,[EditLength]
               add     edi,esi
               add     ebx,ecx
               sub     ebx,4
               add     esi,ebx
               add     edi,ebx
               mov     eax,ecx
               shr     ecx,2
               std
          rep  movsd
               add     esi,3
               add     edi,3
               mov     ecx,eax
               and     ecx,3
          rep  movsb
               cld

@update:       mov     eax,[EditPos]           // update split
               mov     [EditSplit],eax

@done:         pop     edi
               pop     esi
               pop     ebx
  end;
end;

////////////////////////
//  Display Routines  //
////////////////////////

// Resize display
procedure TEditorForm.ResizeDisplay;
begin
  // Rectify rectangle dimensions
  EditorRect := Rect(1, 1, ClientWidth - 1, ClientHeight - StatusBar.Height - 1);
  MinLimit(EditorRect.Left, 0);
  MinLimit(EditorRect.Right, EditorRect.Left);
  MinLimit(EditorRect.Top, 0);
  MinLimit(EditorRect.Bottom, EditorRect.Top);

  // Get text metrics
  Canvas.Font.Name := FontName;
  Canvas.Font.Size := FontSize;
  ChrWidth := Canvas.TextWidth('X');
  ChrHeight := Canvas.TextHeight('X');

  // Compute column and row indents
  ColumnIndent := ChrWidth * 3 shr 3;
  MaxLimit(ColumnIndent, EditorRect.Right - EditorRect.Left);
  RowIndent := ChrHeight * 3 shr 4;
  MaxLimit(RowIndent, EditorRect.Bottom - EditorRect.Top);

  // Compute active columns and rows
  ActiveColumns := (EditorRect.Right - EditorRect.Left - ColumnIndent) div ChrWidth;
  ActiveRows := (EditorRect.Bottom - EditorRect.Top - RowIndent) div ChrHeight;

  // Compute drawn columns (even for ???sd) and rows
  DrawnColumns := ActiveColumns and $FFFFFFFE + 2;
  DrawnRows := ActiveRows + 1;

  // (Re)allocate drawn data buffer
  if DrawnData <> nil then FreeMem(DrawnData);
  DrawnDataSize := DrawnColumns * (1 + DrawnRows) * 2;
  GetMem(DrawnData, DrawnDataSize);

  // Insure active row
  MinLimit(ActiveRows, 1);

  // Update all
  UpdateAll := True;
  ShowCursor;
end;

// Update display and show cursor
procedure TEditorForm.ShowCursor;
const
//  BrushColor: array[0..1] of integer = (clHighlight, clWindow);
//  FontColor: array[0..1] of integer = (clHighlightText, clWindowText);
//  FontStyle: array[0..1] of TFontStyles = ([fsBold], [fsBold]);
  BrushColor: array[0..1] of integer = (clWindow, clHighlight);
  FontColor: array[0..1] of integer = (clWindowText, clHighlightText);
  FontStyle: array[0..1] of TFontStyles = ([fsBold], [fsBold]);
//  FontStyle: array[0..1] of TFontStyles = ([], []);
var
  Position, Line, Column, Left, Top: integer;
  Style: byte;
  Rectangle: TRect;
begin
  if not UpdateEditor then Exit;
  // Adjust top to contain cursor
  Position := EditPos;
  GoHome;
  if EditTop > EditPos then EditTop := EditPos
  else
  begin
    for Line := 0 to ActiveRows - 2 do GoUp;
    MinLimit(EditTop, EditPos);
  end;
  // Determine cursor row
  EditPos := EditTop;
  CursorRow := 0;
  for Line := 0 to ActiveRows - 1 do
  begin
    CursorRow := Line;
    GoEnd;
    if EditPos >= Position then Break;
    GoRight;
    GoHome;
  end;
  EditPos := Position;
  // Adjust pan to contain cursor
  Column := GetColumn;
  if Column < EditPan then EditPan := Column
  else
  if Column > EditPan + ActiveColumns then EditPan := Column - ActiveColumns;
  // Determine cursor column
  CursorColumn := Column - EditPan;
  // If update all, draw static data
  if UpdateAll then
  begin
    // Draw frame
    Canvas.Pen.Color := clBtnShadow;
    Canvas.MoveTo(EditorRect.Right, EditorRect.Top - 1);
    Canvas.LineTo(EditorRect.Left - 1, EditorRect.Top - 1);
    Canvas.LineTo(EditorRect.Left - 1, EditorRect.Bottom);
    Canvas.Pen.Color := clBtnHighLight;
    Canvas.LineTo(EditorRect.Right, EditorRect.Bottom);
    Canvas.LineTo(EditorRect.Right, EditorRect.Top - 1);
  end;
  // Draw text
  Position := EditTop;
  for Line := 0 to DrawnRows - 1 do
  begin
    MakeDisplayLine(Position);
    if DisplayLineChanged(Line) or UpdateAll then
    begin
      Column := 0;
      repeat
        MakeTextRect(Line, Column, Style, Rectangle, Left, Top);
        Canvas.Brush.Color := BrushColor[Style];
        Canvas.Font.Color := FontColor[Style];
        Canvas.Font.Style := FontStyle[Style];
        Canvas.TextRect(Rectangle, Left, Top, PChar(DrawnData));
      until Rectangle.Right = EditorRect.Right;
    end;
  end;
  // Show cursor
  ToggleCursor;
  CursorState := 4;
  CursorEnabled := True;
  // Cancel update all
  UpdateAll := False;
end;

// Hide cursor
procedure TEditorForm.HideCursor;
begin
  if not UpdateEditor then Exit;
  CursorEnabled := False;
  if CursorState and 4 <> 0 then ToggleCursor;
end;

// Cursor timer tick
procedure TEditorForm.CursorTimerTick(Sender: TObject);
begin
  if not UpdateEditor then Exit;
  if CursorEnabled then
  begin
    Inc(CursorState);
    if CursorState and 3 = 0 then ToggleCursor;
  end;
end;

// Toggle cursor
procedure TEditorForm.ToggleCursor;
var
  x, y1, y2, i: integer;
begin
  x := EditorRect.Left + ColumnIndent + CursorColumn * ChrWidth - (ChrWidth + 8) shr 4;
  y1 := EditorRect.Top + RowIndent + CursorRow * ChrHeight;
  y2 := y1 + ChrHeight;
  MaxLimit(y1, EditorRect.Bottom);
  MaxLimit(y2, EditorRect.Bottom);
  Canvas.Pen.Mode := pmNot;
  for i := 0 to ChrWidth shr 3 do
  begin
    if (x + i >= EditorRect.Left) and (x + i < EditorRect.Right) then
    begin
      Canvas.MoveTo(x + i, y1);
      Canvas.LineTo(x + i, y2);
    end;
  end;
  Canvas.Pen.Mode := pmCopy;
end;

// Make display line in first record of DrawnData
procedure TEditorForm.MakeDisplayLine(var Position: integer);
var
  MarkLow, MarkHigh: integer;
begin
  asm
               push    ebx
               push    esi
               push    edi

               mov     eax,[EditPos]           // get mark low/high
               mov     ebx,[EditMark]
               cmp     eax,ebx
               jb      @mark
               xchg    eax,ebx
@mark:         cmp     [EditMarkFlag],0
               jne     @mark2
               mov     eax,ebx
@mark2:        mov     [MarkLow],eax
               mov     [MarkHigh],ebx

               mov     ebx,[Edit]              // init registers
               mov     ecx,[DrawnColumns]
               xor     edx,edx
               mov     esi,Position
               mov     esi,[esi]
               mov     edi,[DrawnData]

@loop:         cmp     esi,[EditSplit]         // handle split
               jb      @style
               mov     ebx,[EditLimit]
               sub     ebx,[EditLength]
               add     ebx,[Edit]

@style:        xor     eax,eax                 // get style
               cmp     esi,[EditLength]        // eof?
               je      @eof
               cmp     esi,[MarkLow]
               jb      @chr
               cmp     esi,[MarkHigh]
               jae     @chr
               mov     ah,1

@chr:          mov     al,[ebx + esi]          // get chr
               inc     esi

               cmp     al,13                   // eol?
               je      @eol

               cmp     al,9                    // tab?
               je      @tab

               call    @fit                    // chr, fit style:chr to line
               jmp     @loop

@tab:          mov     al,' '                  // tab, space to next tab stop
@tab2:         call    @fit
               test    dl,7
               jnz     @tab2
               jmp     @loop

@fit:          cmp     edx,[EditPan]           // fit style:chr to line
               jb      @fit2
               jecxz   @fit2
               stosw
               dec     ecx
@fit2:         inc     edx
               ret

@eol:          mov     al,0                    // eol/eof, fill remainder of line with style:0
@eof:          shr     ecx,1
               jnc     @fill
               stosw
@fill:         mov     ebx,eax
               shl     eax,16
               mov     ax,bx
          rep  stosd

               mov     eax,Position            // update display position
               mov     [eax],esi

               pop     edi
               pop     esi
               pop     ebx
  end;
end;

// Test for display line change and maintain history
function TEditorForm.DisplayLineChanged(Line: integer): boolean;
begin
  asm
               push    esi
               push    edi

               mov     eax,[Line]              // get line size and pointers
               inc     eax
               mov     ecx,[DrawnColumns]
               mul     ecx                     // (edx = 0)
               shr     ecx,1
               mov     esi,[DrawnData]
               lea     edi,[esi + eax * 2]

               push    ecx                     // check for line difference
               push    esi
               push    edi
         repe  cmpsd
               pop     edi
               pop     esi
               pop     ecx

               je      @same                   // if different, copy line to history
          rep  movsd
               inc     edx                     // (visible edx usage stops Delphi bug)

@same:         mov     [Result],dl

               pop     edi
               pop     esi
  end;
end;

// Make text rectangle from display line
procedure TEditorForm.MakeTextRect(Line: integer; var Column: integer; var Style: byte; var Rectangle: TRect; var Left: integer; var Top: integer);
begin
  asm
               push    ebx
               push    esi
               push    edi

               mov     esi,Column              // get starting column
               mov     esi,[esi]

               mov     ecx,[DrawnColumns]      // get remaining columns
               sub     ecx,esi

               mov     edi,[DrawnData]         // set pointers
               add     esi,esi
               add     esi,edi

               lodsw                           // get initial style:chr
               mov     edx,Style
               mov     [edx],ah
               mov     dl,ah

@loop:         stosb                           // gather style:chr until style changes or done
               lodsw
               cmp     ah,dl
               loope   @loop

               mov     al,0                    // zero-terminate string
               stosb

               sub     esi,[DrawnData]         // update starting column
               shr     esi,1
               dec     esi
               mov     edi,Column
               xchg    [edi],esi

               mov     eax,esi                 // set Left
               mul     [ChrWidth]
               mov     ebx,[EditorRect.Left]
               add     eax,ebx
               mov     esi,[ColumnIndent]
               mov     edx,Left
               mov     [edx],eax
               add     [edx],esi

               cmp     eax,ebx                 // set Rectangle.Left
               je      @noindent
               add     eax,esi
@noindent:     mov     ecx,Rectangle
               mov     [ecx + 0],eax

               mov     eax,[edi]               // set Rectangle.Right
               mul     [ChrWidth]
               add     eax,ebx
               add     eax,esi
               mov     edx,[EditorRect.Right]
               cmp     eax,edx
               jbe     @ok
               mov     eax,edx
@ok:           mov     [ecx + 8],eax

               mov     eax,[Line]              // set Top
               mul     [ChrHeight]
               mov     ebx,[EditorRect.Top]
               add     eax,ebx
               mov     esi,[RowIndent]
               mov     edx,Top
               mov     [edx],eax
               add     [edx],esi

               mov     [ecx + 4],eax           // set Rectangle.Top
               cmp     eax,ebx
               je      @noindent2
               add     [ecx + 4],esi
@noindent2:
               add     eax,esi                 // set Rectangle.Bottom
               add     eax,[ChrHeight]
               mov     edx,[EditorRect.Bottom]
               cmp     eax,edx
               jbe     @ok2
               mov     eax,edx
@ok2:          mov     [ecx + 12],eax

               pop     edi
               pop     esi
               pop     ebx
  end;
end;

/////////////////////////
//  File I/O Routines  //
/////////////////////////

procedure TEditorForm.NewFile;
begin
  EditPos := 0;
  EditSplit := 0;
  EditLength := 0;
  EditMark := 0;
  EditMarkFlag := 0;
  EditTop := 0;
  EditPan := 0;
  EditColumn := 0;
  EditColumnFlag := 0;
  EditFlag := False;
  MouseIsDown := False;
  HideCursor;
  ShowCursor;
end;

procedure TEditorForm.LoadEditorFile(const Filename: string);
var
  f: file;
  Size: Integer;
begin
  NewFile;
  HideCursor;
  AssignFile(f, Filename);
  Size := 0;
  try
    try
      Reset(f, 1);
      Size := FileSize(f);
      BlockRead(f, Edit^, Size);
    except
      UpdateEditor := True;
    end;
  finally
    CloseFile(f);
    SetFilename(Filename);
    EditLength := Size;
    EditSplit := Size;
    AdjustInputFileCRLF;
    EditFlag := False;
    EditPos := 0;
    ShowCursor;
  end;
end;

procedure TEditorForm.SaveEditorFile(const Filename: string);
var
  f: file;
  i: Integer;
begin
  i := EditPos;
  AdjustOutputFileCRLF;
  EditPos := EditLength;
  EditSlice;
  AssignFile(f, Filename);
  try
    Rewrite(f, 1);
    BlockWrite(f, Edit^, EditLength);
  finally
    CloseFile(f);
    AdjustInputFileCRLF;
    EditFlag := False;
    EditPos := i;
  end;
end;

procedure TEditorForm.AdjustInputFileCRLF;
var
  old, new: byte;
begin
  new := 0;
  EditPos := 0;
  while EditPos <> EditLength do
  begin
    old := new;
    new := EditRead;
    if new in [9, 32..255] then
    begin       // Tab and printable chrs
      Inc(EditPos);
    end
    else if (old = 13) and (new = 10) then
    begin       // PC mode
      EditDelete(EditPos, EditPos + 1);
      FileFormat := FormatPC;
    end
    else if (old <> 13) and (new = 10) then
    begin       // Linux mode
      EditDelete(EditPos, EditPos + 1);
      EditInsert(13);
      FileFormat := FormatLinux;
    end
    else if (old = 13) and (new <> 10) then
    begin       // Mac mode
      Inc(EditPos);
      FileFormat := FormatMac;
    end
    else
      if (new <> 10) and (new <> 13) then EditDelete(EditPos, EditPos + 1);
  end;
end;

procedure TEditorForm.AdjustOutputFileCRLF;
begin
  EditPos := 0;
  while EditPos <> EditLength do
  begin
    if EditRead = 13 then
    begin
      if FileFormat = FormatPC then
      begin
        Inc(EditPos);
        EditInsert(10);
      end
      else if FileFormat = FormatLinux then
      begin
        EditDelete(EditPos, EditPos + 1);
        EditInsert(10);
      end
      else if FileFormat = FormatMac then
      begin
        Inc(EditPos);
      end;
    end
    else
      Inc(EditPos);
  end;
end;

procedure TEditorForm.SetFilename(const NewFilename: string);
begin
  CurrentFilename := NewFilename;
  OpenDialog.InitialDir := ExtractFileDir(CurrentFilename);
  SaveDialog.InitialDir := ExtractFileDir(CurrentFilename);
  SaveDialog.Filename := ExtractFilename(CurrentFilename);
  if TopFilename = '' then
  begin
    Caption := Application.Title + ' - <NoTopFile> ' + ExtractFilename(CurrentFilename);
  end
  else
  begin
    Caption := Application.Title + ' - <' + ExtractFilename(TopFilename) + '> ' + ExtractFilename(CurrentFilename);
  end
end;

procedure TEditorForm.SetExtFileMode(Ext: string; EditBuffer: pointer; Limit, Length: integer);
begin
  // Save source pointers
  SourceSplit := EditSplit;
  SourceLength := EditLength;
  SourceEditPos := EditPos;
  SourceEditTop := EditTop;
  SourceEditPan := EditPan;
  // Set new pointers
  Edit := EditBuffer;
  EditLimit := Limit;
  EditSplit := Length;
  EditLength := Length;
  EditPos := 0;
  EditTop := 0;
  EditPan := 0;
  // Set ext file mode
  ExtFileMode := True;
  RunMenu.Enabled := False;
  StatusBar.SimpleText := Hint;
  // Set new filename
  SourceFilename := CurrentFilename;
  SetFilename(ExtFilename(CurrentFilename, Ext));
  // Reset flags
  EditColumnFlag := 0;
  EditMarkFlag := 0;
  // Update display
  HideCursor;
  ShowCursor;
end;

procedure TEditorForm.CancelExtFileMode;
begin
  if ExtFileMode then
  begin
    // Restore source pointers
    Edit := @SourceBuffer;
    EditLimit := SourceLimit;
    EditSplit := SourceSplit;
    EditLength := SourceLength;
    EditPos := SourceEditPos;
    EditTop := SourceEditTop;
    EditPan := SourceEditPan;
    // Cancel ext file mode
    ExtFileMode := False;
    RunMenu.Enabled := True;
    StatusBar.SimpleText := Hint;
    Hint := '';
    FileListToggleItem.Checked := False;
    FileListToggleDebugItem.Checked := False;
    FileDocToggleItem.Checked := False;
    // Restore source filename
    SetFilename(SourceFilename);
    // Reset flags
    EditColumnFlag := 0;
    EditMarkFlag := 0;
    // Update display
    HideCursor;
    ShowCursor;
  end;
end;

function TEditorForm.CheckFileSave: boolean;
begin
  Result := True;
  if EditFlag then
  case MessageDlg('Save changes to ' + CurrentFilename + '?', mtConfirmation, mbYesNoCancel, 0) of
    idYes:    SaveEditorFile(CurrentFilename);
    idNo:     Result := False;
    idCancel: Abort;
  end;
end;

function TEditorForm.GetErrorLine: integer;
begin
  Result := 1;
  EditPos := 0;
  while (EditPos <> EditLength) and (EditPos < EditMark) do
  begin
    if EditRead = 13 then Inc(Result);
    Inc(EditPos);
  end;
end;

procedure TEditorForm.WriteErrorFile(s: string);
var
  f: TextFile;
begin
  AssignFile(f, 'Error.txt');
  ReWrite(f);
  WriteLn(f, s);
  CloseFile(f);
end;

//////////////////////////
//  Clipboard Routines  //
//////////////////////////

// Cut selection to clipboard
procedure TEditorForm.CutToClipBoard;
begin
  CopyToClipBoard;
  DeleteSelection;
end;

// Copy selection to clipboard
procedure TEditorForm.CopyToClipBoard;
var
  DataHandle: THandle;
  DataPointer: PByte;
  Start, Finish, Linefeeds, i: integer;
  b: byte;
begin
  // If no selection, exit
  if not GetSelection(Start, Finish) then Exit;
  // Count linefeeds required
  i := EditPos;
  Linefeeds := 0;
  EditPos := Start;
  while EditPos <> Finish do
  begin
    if EditRead = 13 then Inc(Linefeeds);
    Inc(EditPos);
  end;
  // Allocate buffer and copy data + linefeeds + #0
  DataHandle := GlobalAlloc(GMEM_DDESHARE or GMEM_MOVEABLE, Finish - Start + Linefeeds + 1);
  DataPointer := GlobalLock(DataHandle);
  EditPos := Start;
  while EditPos <> Finish do
  begin
    b := EditRead;
    Inc(EditPos);
    DataPointer^ := b;
    Inc(DataPointer);
    if b = 13 then
    begin
      DataPointer^ := 10;
      Inc(DataPointer);
    end;
  end;
  DataPointer^ := 0;
  GlobalUnlock(DataHandle);
  EditPos := i;
  // Assign buffer to ClipBoard
  OpenClipBoard(Handle);
  EmptyClipBoard;
  SetClipBoardData(CF_TEXT, DataHandle);
  CloseClipBoard;
end;

// Paste text from clipboard
procedure TEditorForm.PasteFromClipBoard;
var
  DataHandle: THandle;
  DataPointer: PByte;
  b: byte;
begin
  DeleteSelection;
  OpenClipBoard(Handle);
  DataHandle := GetClipBoardData(CF_TEXT);
  if DataHandle <> 0 then
  begin
    DataPointer := GlobalLock(DataHandle);
    repeat
      b := DataPointer^;
      if b in [kTab, kEnter, kSpace..$FF] then EditInsert(b);
      Inc(DataPointer);
    until b = 0;
    GlobalUnlock(DataHandle);
  end;
  CloseClipBoard;
end;

// Delete selection
function TEditorForm.DeleteSelection: boolean;
var
  Start, Finish: integer;
begin
  Result := GetSelection(Start, Finish);
  if Result then EditDelete(Start, Finish);
  EditMarkFlag := 0;
end;

// Get selection start and finish
function TEditorForm.GetSelection(var Start, Finish: integer): boolean;
begin
  if EditPos < EditMark then
  begin
    Start := EditPos;
    Finish := EditMark;
  end
  else
  begin
    Start := EditMark;
    Finish := EditPos;
  end;
  Result := IsSelection;
end;

function TEditorForm.IsSelection: boolean;
begin
  Result := (EditMarkFlag <> 0) and (EditPos <> EditMark);
end;

/////////////////////////////
//  Find/Replace Routines  //
/////////////////////////////

function TEditorForm.Find: boolean;
var
  Find, f: PByte;
  p, m, i, p2, m2: integer;
  b1, b2: byte;
begin
  Result := False;
  Find := PByte(FindReplaceForm.FindMemo.Text);
  p := EditPos;
  m := EditMark;
  i := p;
  repeat
    f := Find;
    EditPos := i;
    EditMark := i;
    while (f^ <> 0) and (EditPos <> EditLength) do
    begin
      b1 := f^;
      b2 := EditRead;
      if b1 in [Byte('a')..Byte('z')] then Dec(b1, $20);
      if b2 in [Byte('a')..Byte('z')] then Dec(b2, $20);
      if b1 in [kTab, kEnter, kSpace..$FF] then if b1 = b2 then Inc(EditPos) else Break;
      Inc(f);
    end;
    if f^ = 0 then
    begin
      if FindReplaceForm.WordCheckBox.Enabled and FindReplaceForm.WordCheckBox.Checked then
      begin
        p2 := EditPos;
        m2 := EditMark;
        EditPos := m2;
        IsWord;
        if (EditPos = p2) and (EditMark = m2) then
        begin
          EditMarkFlag := 1;
          Result := True;
          Exit;
        end;
      end
      else
      begin
        EditMarkFlag := 1;
        Result := True;
        Exit;
      end;
    end;
    if i <> EditLength then Inc(i);
  until i = EditLength;
  EditPos := p;
  EditMark := m;
end;

function TEditorForm.Replace: boolean;
var
  Replace: PByte;
begin
  Result := False;
  if not DeleteSelection then Exit;
  Replace := PByte(FindReplaceForm.ReplaceMemo.Text);
  if Replace <> nil then
  begin
    while Replace^ <> 0 do
    begin
      if Replace^ in [kTab, kEnter, kSpace..$FF] then EditInsert(Replace^);
      Inc(Replace);
    end;
  end;
  Result := True;
end;

//////////////////////
//  Mouse Routines  //
//////////////////////

procedure TEditorForm.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: boolean);
var
  Key: word;
  i: integer;
begin
  if WheelDelta > 0 then Key := kUp else Key := kDown;
  for i := 0 to ActiveRows shr 3 do FormKeyDown(Self, Key, []);
end;

// Determine mouse column or column pull
function TEditorForm.MouseInColumns(X: integer; var Column: integer): boolean;
var
  RectRight: integer;
begin
  RectRight := EditorRect.Left + ColumnIndent + ActiveColumns * ChrWidth;
  Result := (X >= EditorRect.Left) and (X < RectRight);
  if Result then
  // Mouse inside columns, determine column
  begin
    Column := X - EditorRect.Left - ColumnIndent + ChrWidth shr 1;
    MinLimit(Column, 0);
    Column := Column div ChrWidth + EditPan
  end
  // Mouse outside columns, determine column pull
  else if X < EditorRect.Left then Column := -((EditorRect.Left - X) div ChrWidth + 1)
    else Column := (X - RectRight + 1) div ChrWidth + 1;
end;

// Determine mouse row or row pull
function TEditorForm.MouseInRows(Y: integer; var Row: integer): boolean;
var
  RectBottom: integer;
begin
  RectBottom := EditorRect.Top + RowIndent + ActiveRows * ChrHeight;
  Result := (Y >= EditorRect.Top) and (Y < RectBottom);
  if Result then
  // Mouse inside rows, determine row
  begin
    Row := Y - EditorRect.Top - RowIndent;
    MinLimit(Row, 0);
    Row := Row div ChrHeight;
  end
  // Mouse outside rows, determine row pull
  else if Y < EditorRect.Top then Row := -((EditorRect.Top - Y) div ChrHeight + 1)
    else Row := (Y - RectBottom + 1) div ChrHeight + 1;
end;

procedure TEditorForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Column, Row, i: integer;
  ClickNumber: integer;
begin
  // Update click history
  Click3 := Click2;
  Click2 := Click1;
  Click1 := GetTickCount;
  ClickNumber := Ord(Click1 - Click2 < ClickTime) shl Ord(Click2 - Click3 < ClickTime) + 1;

  // Editor select?
  if (Button = mbLeft) and MouseInColumns(X, Column) and MouseInRows(Y, Row) then
  begin
    // Position cursor to mouse
    EditPos := EditTop;
    for i := 1 to Row do GoDown;
    EditColumn := Column;
    MatchColumn;

    case ClickNumber of
      // 1st click - begin mouse select
      1:
      begin
        EditColumnFlag := 0;
        EditMarkFlag := 1;
        EditMark := EditPos;
        MouseIsDown := True;
      end;
      // 2nd click - select word
      2:
      EditMarkFlag := Ord(IsWord);
      // 3rd click - select line
      3:
      begin
        GoHome;
        EditMark := EditPos;
        GoEnd;
        GoRight;
        EditMarkFlag := 1;
      end;
    end;
    HideCursor;
    ShowCursor;
  end;
end;

procedure TEditorForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  Column, Row, i: integer;
  TimerOn: boolean;
begin
  if (X >= EditorRect.Left) and (X < EditorRect.Right)
    and (Y >= EditorRect.Top) and (Y < EditorRect.Bottom)
    then Cursor := crIBeam else Cursor := crDefault;
  if MouseIsDown then
  begin
    TimerOn := False;
    if MouseInRows(Y, Row) then
    begin
      EditColumn := GetColumn;
      EditPos := EditTop;
      for i := 1 to Row do GoDown;
      MatchColumn;
      SelectRows := 0;
    end
    else
    begin
      SelectRows := Row;
      TimerOn := True;
    end;
    if MouseInColumns(X, Column) then
    begin
      EditColumn := Column;
      MatchColumn;
      SelectColumns := 0;
    end
    else
    begin
      SelectColumns := Column;
      TimerOn := True;
    end;
    if not TimerOn then
    begin
      HideCursor;
      ShowCursor;
    end;
    if SelectTimer.Enabled <> TimerOn then SelectTimer.Enabled := TimerOn;
  end;
end;

procedure TEditorForm.SelectTimerTick(Sender: TObject);
var
  i: integer;
begin
  if SelectColumns < 0 then for i := 1 to -SelectColumns do if GoLeft then if EditRead = 13 then GoRight;
  if SelectColumns > 0 then for i := 1 to SelectColumns do if EditRead <> 13 then GoRight;
  if SelectColumns <> 0 then EditColumn := GetColumn;

  if SelectRows < 0 then for i := 1 to -SelectRows do GoUp;
  if SelectRows > 0 then for i := 1 to SelectRows do GoDown;
  if SelectRows <> 0 then MatchColumn;

  HideCursor;
  ShowCursor;
end;

procedure TEditorForm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    MouseIsDown := False;
    SelectTimer.Enabled := False;
  end;
end;

//////////////////////
//  Print Routines  //
//////////////////////

// Do print
procedure TEditorForm.DoPrint;
var
  Start, Finish, i: integer;
begin
  i := EditPos;
  // Count all lines
  PrintForm.AllLines := Ord(EditLength <> 0);
  EditPos := 0;
  while EditPos <> EditLength do
  begin
    if EditRead = 13 then Inc(PrintForm.AllLines);
    Inc(EditPos);
  end;
  EditPos := i;
  // Count (whole) selection lines
  PrintForm.SelectedLines := Ord(GetSelection(Start, Finish));
  if PrintForm.SelectedLines = 1 then
  begin
    EditPos := Finish - 1;
    GoEnd;
    Finish := EditPos;
    EditPos := Start;
    GoHome;
    Start := EditPos;
    while EditPos <> Finish do
    begin
      if EditRead = 13 then Inc(PrintForm.SelectedLines);
      Inc(EditPos);
    end;
  end;
  // Execute print dialog
  if PrintForm.ShowModal = mrOK then
  begin
    // Okay, determine what range to print
    EditPos := 0;
    if PrintForm.PrintSelection then EditPos := Start else Finish := EditLength;
    // Print page(s) while showing print status form
    PrintStatusForm.Show;
    Printer.Title := Application.Title;
    Printer.BeginDoc;
    while not PrintPage(Finish) do Printer.NewPage;
    if PrintStatusForm.Cancelled then Printer.Abort else Printer.EndDoc;
    PrintStatusForm.Hide;
  end;
  EditPos := i;
end;

// Print page
function TEditorForm.PrintPage(Finish: integer): boolean;
var
  Column, Line, X, Y, Tab: integer;
  LineBuffer: PByteArray;
  b: byte;
begin
  GetMem(LineBuffer, PrintForm.Columns + 1);
  // Increment page number on print status form
  PrintStatusForm.NextPage;
  // If multiple sections, draw dividers
  Printer.Canvas.Pen.Width := PrintForm.ChrWidth shr 3 + 1;
  if PrintForm.Sections > 1 then
    for Column := 0 to PrintForm.Sections do
    begin
      X := PrintForm.XOffset + (1 + PrintForm.Columns) * PrintForm.ChrWidth * Column + PrintForm.ChrWidth shr 1;
      Printer.Canvas.MoveTo(X, PrintForm.YOffset);
      Printer.Canvas.LineTo(X, PrintForm.YOffset + PrintForm.Rows * PrintForm.ChrHeight);
    end;
  // Draw lines until page filled, finished, or cancelled
  Printer.Canvas.Font.Color := clBlack;
  Printer.Canvas.Brush.Style := bsClear;
  for Line := 0 to PrintForm.Sections * PrintForm.Rows - 1 do
  begin
    X := PrintForm.XOffset + (Line div PrintForm.Rows * (1 + PrintForm.Columns) + 1) * PrintForm.ChrWidth;
    Y := PrintForm.YOffset + Line mod PrintForm.Rows * PrintForm.ChrHeight;
    Column := 0;
    repeat
      b := EditRead;
      Result := (EditPos = Finish) or PrintStatusForm.Cancelled;
      if not Result then Inc(EditPos);
      if (b = 13) or Result then b := 0;
      Tab := 7;
      if b = 9 then b := 32 else Tab := 0;
      repeat
        if Column < PrintForm.Columns then LineBuffer[Column] := b;
        Inc(Column);
      until Column and Tab = 0
    until b = 0;
    LineBuffer[PrintForm.Columns] := 0;
    Printer.Canvas.TextOut(X, Y, PChar(LineBuffer));
    if Result then Break;
  end;
  FreeMem(LineBuffer);
end;

/////////////////////
//  Tool Routines  //
/////////////////////

procedure TEditorForm.SetDirectories;
begin
  if TopFilename = '' then
    TopDir := '<none>'
  else
    TopDir := IncludeTrailingPathDelimiter(ExtractFileDir(TopFilename));
  CurrentDir := IncludeTrailingPathDelimiter(ExtractFileDir(CurrentFilename));
  LibraryDir := IncludeTrailingPathDelimiter(ExtractFileDir(Application.ExeName));
end;

procedure TEditorForm.Compile(cObj, cList, cDoc: boolean);
var
  CurrentPos, CurrentTop, CurrentPan, Level, i: integer;
  CurrentFile: string;
begin
  // save current file
  CurrentFile := CurrentFilename;
  if EditFlag or (ExtractFilename(CurrentFile) = 'Untitled.spin2') then
    if RunAutoSaveItem.Checked then
      SaveEditorFile(CurrentFile)
    else if not CheckFileSave then Abort;
  // Disable edit
  HideCursor;
  UpdateEditor := False;
  // save edit parameters
  CurrentPos := EditPos;
  CurrentTop := EditTop;
  CurrentPan := EditPan;
  // show progress form
  ProgressForm.Caption := 'Compiler';
  ProgressForm.StatusLabel.Caption := '';
  ProgressForm.Show;
  // perform nested compilation
  SetDirectories;
  if TopFilename = '' then Level := 2 else Level := 1;
  if Level = 1 then TopFile := TopFilename else TopFile := CurrentFilename;
  P2.DistilledBytes := 0;                       // reset distilled byte count
  P2.DownloadBaud := DefaultBaud;               // set default download baud
  PWordArray(@P2.DebugData)[0] := $200;         // reset debug data
  for i := 1 to 255 do PWordArray(@P2.DebugData)[i] := 0;
  P2.ObjStackPtr := 0;
  P2.Params := 0;
  ObjFilePtr := 0;
  ObjFileCount := 0;
  CompileRecursively(TopFile, Level, cObj, cList, cDoc);      // aborts if error
  ProgressForm.Hide;
  StatusBar.SimpleText := 'Compilation Successful';
  // reload current file
  LoadEditorFile(CurrentFile);
  // restore edit parameters
  EditPos := CurrentPos;
  EditTop := CurrentTop;
  EditPan := CurrentPan;
  // update display
  UpdateEditor := True;
  UpdateAll := True;
  ShowCursor;
end;

procedure TEditorForm.CompileRecursively(Filename: string; Level: integer; cObj, cList, cDoc: boolean);
var
  i, j, p, s: integer;

  Params: integer;
  ParamNames: array[0..ParamLimit*32-1] of byte;
  ParamTypes: array[0..ParamLimit-1] of byte;
  ParamValues: array[0..ParamLimit-1] of integer;

  ObjFiles: integer;
  ObjFilename: string;
  ObjFilenames: array[0..FileLimit-1] of string[32];
  ObjFilenamesStart: array[0..FileLimit-1] of integer;
  ObjFilenamesFinish: array[0..FileLimit-1] of integer;
  ObjFileIndex: array[0..FileLimit-1] of integer;

  ObjParams: array[0..FileLimit-1] of integer;
  ObjParamNames: array[0..FileLimit*ParamLimit*32-1] of byte;
  ObjParamTypes: array[0..FileLimit*ParamLimit-1] of byte;
  ObjParamValues: array[0..FileLimit*ParamLimit-1] of integer;

  ObjTitle: PChar;

  DatFiles: integer;
  DatFilename: string;

  f: file;
begin
  // update progress form
  ProgressForm.StatusLabel.Caption := ExtractFilename(Filename);
  ProgressForm.StatusLabel.Repaint;
  // increment stack pointer and check for overflow (possible circular reference)
  Inc(P2.ObjStackPtr);
  if P2.ObjStackPtr > ObjStackLimit then
    CompilerError('Object nesting exceeds ' + IntToStr(ObjStackLimit) + ' levels - illegal circular reference may exist');
  // load source file and perform first pass of compilation
  LoadCompilerFile(Filename);
  P2Compile0;
  if P2.Error then
  begin
    LoadCompilerFile(Filename); //reload file because preprocessor (P2Compile0) modified it
    CompilerError(P2.ErrorMsg); //aborts
  end;
  P2Compile1;
  if P2.Error then CompilerError(P2.ErrorMsg); //aborts if error
  if P2.PasmMode and (P2.ObjStackPtr > 1) then CompilerError(Filename + ' is a PASM file and cannot be used as a Spin2 object'); // aborts if error
  ObjFiles := P2.ObjFiles;
  DatFiles := P2.DatFiles;
  // generate any sub-objects' obj files
  if ObjFiles > 0 then
  begin
    // save current parameters
    Params := P2.Params;
    Move(P2.ParamNames, ParamNames, SizeOf(ParamNames));
    Move(P2.ParamTypes, ParamTypes, SizeOf(ParamTypes));
    Move(P2.ParamValues, ParamValues, SizeOf(ParamValues));
    // save sub-objects' parameters
    Move(P2.ObjParams, ObjParams, SizeOf(ObjParams));
    Move(P2.ObjParamNames, ObjParamNames, SizeOf(ObjParamNames));
    Move(P2.ObjParamTypes, ObjParamTypes, SizeOf(ObjParamTypes));
    Move(P2.ObjParamValues, ObjParamValues, SizeOf(ObjParamValues));
    // get sub-objects' filenames
    for i := 0 to ObjFiles-1 do
    begin
      ObjFilenames[i] := PChar(@P2.ObjFilenames[i shl 8]);
      ObjFilenamesStart[i] := P2.ObjFilenamesStart[i];
      ObjFilenamesFinish[i] := P2.ObjFilenamesFinish[i];
    end;
    // compile sub-objects' .spin2 files to generate obj files
    for i := 0 to ObjFiles-1 do
    begin
      // set sub-object's parameters
      P2.Params := ObjParams[i];
      Move(ObjParamNames[i*ParamLimit*32], P2.ParamNames, ParamLimit*32);
      Move(ObjParamTypes[i*ParamLimit], P2.ParamTypes, ParamLimit);
      Move(ObjParamValues[i*ParamLimit], P2.ParamValues, ParamLimit*4);
      // compile sub-object
      if (Level = 1) and FileExists(TopDir + ObjFilenames[i] + '.spin2') then
        CompileRecursively(TopDir + ObjFilenames[i] + '.spin2', 1, cObjOff, cListOff, cDocOff)
      else if (Level <> 3) and FileExists(CurrentDir + ObjFilenames[i] + '.spin2') then
        CompileRecursively(CurrentDir + ObjFilenames[i] + '.spin2', 2, cObjOff, cListOff, cDocOff)
      else if FileExists(LibraryDir + ObjFilenames[i] + '.spin2') then
        CompileRecursively(LibraryDir + ObjFilenames[i] + '.spin2', 3, cObjOff, cListOff, cDocOff)
      else
      // error, .spin2 file not found
      begin
        LoadCompilerFile(Filename);
        P2.SourceStart := ObjFilenamesStart[i];
        P2.SourceFinish := ObjFilenamesFinish[i];
        CompilerError('Cannot find ' + ObjFilenames[i] + '.spin2');
      end;
      // get sub-object's obj file index
      ObjFileIndex[i] := ObjFileCount - 1;
    end;
    // restore current parameters
    P2.Params := Params;
    Move(ParamNames, P2.ParamNames, SizeOf(ParamNames));
    Move(ParamTypes, P2.ParamTypes, SizeOf(ParamTypes));
    Move(ParamValues, P2.ParamValues, SizeOf(ParamValues));
  end;
  // reload source file and reperform first pass of compilation
  LoadCompilerFile(Filename);
  P2Compile0;
  if P2.Error then
  begin
    LoadCompilerFile(Filename); //reload file because preprocessor (P2Compile0) modified it
    CompilerError(P2.ErrorMsg); //aborts
  end;
  if p2.PreprocessorUsed then SaveFile(ChangeFileExt(Filename,'') + '_pre.spin2', Edit, EditLength);     // save post-preprocessor file
  P2Compile1;
  if P2.Error then CompilerError(P2.ErrorMsg); //aborts if error
  // load sub-objects' .obj files
  p := 0;
  if ObjFiles > 0 then
    for i := 0 to ObjFiles-1 do
    begin
      j := ObjFileIndex[i];
      s := ObjFileLength[j];
      Move(ObjFileBuff[ObjFileOffset[j]], P2.ObjData[p], s);
      P2.ObjOffsets[i] := p;
      P2.ObjLengths[i] := s;
      p := p + s;
    end;
  // load any data files
  p := 0;
  if DatFiles > 0 then
    for i := 0 to DatFiles-1 do
    begin
      DatFilename := PChar(@P2.DatFilenames[i shl 8]);
      if (Level = 1) and FileExists(TopDir + DatFilename) then DatFilename := TopDir + DatFilename
      else if (Level <> 3) and FileExists(CurrentDir + DatFilename) then DatFilename := CurrentDir + DatFilename
      else DatFilename := LibraryDir + DatFilename;
      AssignFile(f, DatFilename);
      try
        try
          Reset(f, 1);
          s := FileSize(f);
          if p + s > ObjLimit then CompilerError('DAT files exceed ' + IntToStr(ObjLimit div 1024) + 'k limit');
          BlockRead(f, P2.DatData[p], s);
          P2.DatOffsets[i] := p;
          P2.DatLengths[i] := s;
          p := p + s;
        except
          CompilerError('Failure reading file ' + DatFilename); //aborts if error
        end;
      finally
        CloseFile(f);
      end;
    end;
  // perform second pass of compilation
  ObjTitle := @P2.ObjTitle;
  StrCopy(ObjTitle, PChar(ExtractFilename(Filename)));
  P2Compile2;
  if P2.Error then CompilerError(P2.ErrorMsg); //aborts if error
  // Save obj file into memory
  if ObjFilePtr + P2.ObjLength > ObjLimit then
    CompilerError('OBJ data exceeds ' + IntToStr(ObjLimit div 1024) + 'k limit');
  Move(P2.Obj, ObjFileBuff[ObjFilePtr], P2.ObjLength);
  ObjFileOffset[ObjFileCount] := ObjFilePtr;
  ObjFileLength[ObjFileCount] := P2.ObjLength;
  Inc(ObjFilePtr, P2.ObjLength);
  Inc(ObjFileCount);
  // save obj/list/doc file(s), only happens at top level
  if cList then SaveFile(ExtFilename(CurrentFilename, 'lst'), P2.List, P2.ListLength);
  if cDoc then SaveFile(ExtFilename(CurrentFilename, 'txt'), P2.Doc, P2.DocLength);
  if cObj then SaveFile(ExtFilename(CurrentFilename, 'obj'), @P2.Obj, P2.ObjLength);
  // decrement stack pointer
  Dec(P2.ObjStackPtr);
end;

procedure TEditorForm.CompilerError(ErrorMsg: string);
begin
  ProgressForm.Hide;
  UpdateEditor := True;
  StatusBar.SimpleText := 'ERROR: ' + ErrorMsg + '.';
  EditMark := P2.SourceStart;
  EditPos := P2.SourceFinish;
  EditMarkFlag := 1;
  ResetColumn;
  UpdateAll := True;
  ShowCursor;
  if not BatchMode then MessageDlg(ErrorMsg + '.', mtError, [mbOK], 0);
  EditMarkFlag := 0;
  Abort;
end;

procedure TEditorForm.LoadCompilerFile(Filename: string);
begin
  LoadEditorFile(Filename);
  EditPos := EditLength;
  EditSlice;
  Edit[EditLength] := 0;
  P2.Source := Edit;
end;

procedure TEditorForm.SaveFile(Filename: string; Start: Pointer; Bytes: integer);
var
  f: file;
begin
  AssignFile(f, Filename);
  try
    Rewrite(f, 1);
    BlockWrite(f, Start^, Bytes);
  finally
    CloseFile(f);
  end;
end;

procedure TEditorForm.ComposeRAM(ProgramFlash, DownloadToRAM: boolean);
var
  s: integer;
begin
  // insert interpreter?
  if not P2.PasmMode then
  begin
    P2InsertInterpreter;
    if P2.Error then CompilerError(P2.ErrorMsg);  //aborts if error
  end;
  // check to make sure program fits into hub
  s := P2.SizeObj;
  if P2.DebugMode then s := s + $4000;  // account for debugger
  if not P2.PasmMode then s := s + P2.SizeInterpreter + P2.SizeVar + $400;
  if s > HubLimit then
    CompilerError('Program requirement exceeds ' + IntToStr(HubLimit div 1024)
      + 'KB hub RAM by ' + IntToStr(s - HubLimit) + ' bytes');  //aborts if error
  // insert debugger?
  if P2.DebugMode then
  begin
    P2InsertDebugger;
    if P2.Error then CompilerError(P2.ErrorMsg);  //aborts if error
  end;
  // insert clock setter?
  if not P2.DebugMode and P2.PasmMode and (P2.ClkMode <> 0) then
  begin
    P2InsertClockSetter;
    if P2.Error then CompilerError(P2.ErrorMsg);  //aborts if error
  end;
  // insert flash loader?
  if ProgramFlash then
  begin
    if (P2.SizeFlashLoader + P2.SizeObj) > HubLimit then
      CompilerError('Need to reduce program by ' + IntToStr(P2.SizeFlashLoader
        + P2.SizeObj - HubLimit) + ' bytes, in order to fit flash loader into hub RAM download');
    P2InsertFlashLoader;
    if P2.Error then CompilerError(P2.ErrorMsg);  //aborts if error
  end;
  // save binary file?
  if RunGenerateBinaryItem.Checked then
    SaveFile(ExtFilename(CurrentFilename, 'bin'), @P2.Obj, P2.ObjLength);
  // download to RAM?
  if DownloadToRAM then LoadHardware;
end;

procedure TEditorForm.ComposeROM;
begin
  LoadObj('ROM_Booter.obj');
  SaveFile('ROM', @P2.Obj[$FC000], $4000);
end;

procedure TEditorForm.LoadObj(Filename: string);
var
  f: file;
  Size, i: Integer;
begin
  AssignFile(f, Filename);
  try
    Reset(f, 1);
    Size := Smaller(FileSize(f), ObjLimit);
    BlockRead(f, P2.Obj, Size);
    if Size < ObjLimit then for i := Size to ObjLimit-1 do P2.Obj[i] := 0;
  finally
    CloseFile(f);
  end;
end;

procedure TEditorForm.LoadBin(Filename: string);
var
  f: file;
begin
  AssignFile(f, Filename);
  try
    Reset(f, 1);
    P2.ObjLength := Smaller(FileSize(f), ObjLimit);
    BlockRead(f, P2.Obj, P2.ObjLength);
  finally
    CloseFile(f);
  end;
end;

//////////////////////
//  Debug Shutdown  //
//////////////////////

function TEditorForm.NeedToStopDebugFirst: boolean;
begin
  if CommOpen then                  // comm port open?
  begin
    DebugActive := False;           // disable debug so that the port will close soon
    DebugTimer.Interval := 10;      // set timer for 10ms
    DebugTimer.Enabled := True;     // enable timer to go off soon
    Result := True;                 // return true, download will be stalled
  end
  else Result := False;             // comm port closed, download/debug can proceed
end;

procedure TEditorForm.DebugTimerTick(Sender: TObject);
begin
  if CommOpen then Exit;                        // if comm port still open, will check again soon
  DebugTimer.Enabled := False;                  // comm closed, disable timer
  if DebugPostActive then DebugPost(Self)       // if command stalled, execute
  else DebugForm.Close;                         // else, close debug windows
end;

end.

