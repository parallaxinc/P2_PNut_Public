program PNut;

uses
  Forms,
  GlobalUnit in 'GlobalUnit.pas',
  SerialUnit in 'SerialUnit.pas',
  EditorUnit in 'EditorUnit.pas' {EditorForm},
  PrintUnit in 'PrintUnit.pas' {PrintForm},
  PrintStatusUnit in 'PrintStatusUnit.pas' {PrintStatusForm},
  FindReplaceUnit in 'FindReplaceUnit.pas' {FindReplaceForm},
  AboutUnit in 'AboutUnit.pas' {AboutForm},
  ProgressUnit in 'ProgressUnit.pas' {ProgressForm},
  ComUnit in 'ComUnit.pas' {ComForm},
  DebugUnit in 'DebugUnit.pas' {DebugForm},
  InfoUnit in 'InfoUnit.pas' {InfoForm},
  DebugDisplayUnit in 'DebugDisplayUnit.pas',
  DebuggerUnit in 'DebuggerUnit.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'PNut v48';
  Application.CreateForm(TEditorForm, EditorForm);
  Application.CreateForm(TPrintForm, PrintForm);
  Application.CreateForm(TPrintStatusForm, PrintStatusForm);
  Application.CreateForm(TFindReplaceForm, FindReplaceForm);
  Application.CreateForm(TAboutForm, AboutForm);
  Application.CreateForm(TProgressForm, ProgressForm);
  Application.CreateForm(TComForm, ComForm);
  Application.CreateForm(TDebugForm, DebugForm);
  Application.CreateForm(TInfoForm, InfoForm);
  Application.Run;
end.
