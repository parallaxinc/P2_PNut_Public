unit InfoUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  TInfoForm = class(TForm)
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Label1: TLabel;
    HubTopLabel: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    MapImage: TImage;
    ProgramLabel: TLabel;
    VariableLabel: TLabel;
    StackLabel: TLabel;
    ClockLabel: TLabel;
    FreqLabel: TLabel;
    InputFreqLabel: TLabel;
    OkButton: TButton;
    Label13: TLabel;
    InterpreterLabel: TLabel;
    Bevel7: TBevel;
    Label15: TLabel;
    Bevel8: TBevel;
    Label2: TLabel;
    DebuggerLabel: TLabel;
    Label16: TLabel;
    Bevel9: TBevel;
    procedure FormActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InfoForm: TInfoForm;

implementation

uses GlobalUnit;

{$R *.dfm}

procedure TInfoForm.FormActivate(Sender: TObject);
var
  stksize, debugsize: integer;
  objx, varx, stkx, debx: integer;
  osc: string;
begin
  Caption := ExtFilename(ExtractFilename(TopFile), 'bin');
  HubTopLabel.Caption := '$' + IntToHex(HubLimit - 1,1);

  if P2.DebugMode then debugsize := $4000 else debugsize := 0;

  stksize := HubLimit - debugsize - P2.SizeVar - P2.SizeObj - P2.SizeInterpreter;

  objx := MapImage.Width * (P2.SizeInterpreter) div HubLimit;
  varx := MapImage.Width * (P2.SizeInterpreter + P2.SizeObj) div HubLimit;
  stkx := MapImage.Width * (P2.SizeInterpreter + P2.SizeObj + P2.SizeVar) div HubLimit;
  debx := MapImage.Width * (HubLimit - debugsize) div HubLimit;

  MapImage.Canvas.Pen.Style := psClear;
  MapImage.Canvas.Brush.Style := bsSolid;

  MapImage.Canvas.Brush.Color := clWhite;
  MapImage.Canvas.Rectangle(0,0, objx+1, MapImage.Height+1);

  MapImage.Canvas.Brush.Color := clRed;
  MapImage.Canvas.Rectangle(objx,0, varx+1, MapImage.Height+1);

  MapImage.Canvas.Brush.Color := clYellow;
  MapImage.Canvas.Rectangle(varx,0, stkx+1, MapImage.Height+1);

  MapImage.Canvas.Brush.Color := clAqua;
  MapImage.Canvas.Rectangle(stkx,0, debx+1, MapImage.Height+1);

  MapImage.Canvas.Brush.Color := clBlack;
  MapImage.Canvas.Rectangle(debx,0, MapImage.Width+1, MapImage.Height+1);

  InterpreterLabel.Caption := Format('%6.0n', [StrToFloat(IntToStr(P2.SizeInterpreter))]) + ' bytes';
  ProgramLabel.Caption := Format('%6.0n', [StrToFloat(IntToStr(P2.SizeObj))]) + ' bytes';
  VariableLabel.Caption := Format('%6.0n', [StrToFloat(IntToStr(P2.SizeVar))]) + ' bytes';
  StackLabel.Caption := Format('%6.0n', [StrToFloat(IntToStr(stksize))]) + ' bytes';
  DebuggerLabel.Caption := Format('%6.0n', [StrToFloat(IntToStr(debugsize))]) + ' bytes';

  case P2.ClkMode and $C shr 2 of
    0: osc := 'XI <off>';
    1: osc := 'XINPUT';
    2: osc := '7pF XTAL';
    3: osc := '15pF XTAL';
  end;

  if P2.ClkMode and 3 = 0 then
  begin
    ClockLabel.Caption := 'RCFAST';
    FreqLabel.Caption := '> 20 MHz';
    InputFreqLabel.Caption := '<ignored>';
  end
  else
  if P2.ClkMode and 3 = 1 then
  begin
    ClockLabel.Caption := 'RCSLOW';
    FreqLabel.Caption := '~ 20 KHz';
    InputFreqLabel.Caption := '<ignored>';
  end
  else
  begin
    FreqLabel.Caption := Format('%10.0n', [StrToFloat(IntToStr(P2.ClkFreq))]) + ' Hz';
    if P2.ClkMode and 3 = 2 then
    begin
      ClockLabel.Caption := osc;
      InputFreqLabel.Caption := FreqLabel.Caption;
    end
    else
    begin
      ClockLabel.Caption := osc + ' + PLL';
      InputFreqLabel.Caption := Format('%10.0n', [StrToFloat(IntToStr(P2.XinFreq))]) + ' Hz';
    end;
  end;
end;

procedure TInfoForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ModalResult := mrOK;
end;

end.
