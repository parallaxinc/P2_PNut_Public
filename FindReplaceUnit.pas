unit FindReplaceUnit;

interface

uses Classes, Forms, Controls, StdCtrls, ExtCtrls;

type
  TFindReplaceForm = class(TForm)
    FindBevel: TBevel;
    ReplaceBevel: TBevel;
    DividerBevel: TBevel;
    FindMemo: TMemo;
    ReplaceMemo: TMemo;
    StartCheckBox: TCheckBox;
    WordCheckBox: TCheckBox;
    FindButton: TButton;
    ReplaceButton: TButton;
    AllButton: TButton;
    CancelButton: TButton;
    procedure FormActivate(Sender: TObject);
    procedure UpdateControls(Sender: TObject);
  private
  public
  end;

var                                                  
  FindReplaceForm: TFindReplaceForm;

implementation

uses GlobalUnit;

{$R *.DFM}

procedure TFindReplaceForm.FormActivate(Sender: TObject);
begin
  UpdateControls(Self);
  FindMemo.SelectAll;
  ReplaceMemo.SelectAll;
  ActiveControl := FindMemo;
end;

procedure TFindReplaceForm.UpdateControls(Sender: TObject);
var
  Mode: boolean;
  i: integer;
begin
  Mode := Length(FindMemo.Text) <> 0;
  FindButton.Enabled := Mode;
  AllButton.Enabled := Mode;
  if Mode then
    for i := 0 to Length(FindMemo.Text) - 1 do
      Mode := Mode and IsWordChr(PChar(FindMemo.Text)[i]);
  WordCheckBox.Enabled := Mode;
end;

end.

