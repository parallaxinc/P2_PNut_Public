unit ComUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls;

type
  TComForm = class(TForm)
    Bevel1: TBevel;
    Label1: TLabel;
    ComLabel: TLabel;
    PortUpDown: TUpDown;
    OKButton: TButton;
    procedure FormActivate(Sender: TObject);
    procedure PortUpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ComForm: TComForm;

implementation

uses GlobalUnit, SerialUnit;

{$R *.dfm}

procedure TComForm.FormActivate(Sender: TObject);
begin
  PortUpDown.Position := CommPort;
  ComLabel.Caption := CommString;
end;

procedure TComForm.PortUpDownClick(Sender: TObject; Button: TUDBtnType);
begin
  CommPort := PortUpDown.Position;
  ComLabel.Caption := CommString;
end;

procedure TComForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    kUp, kSpace:
      if PortUpDown.Position = PortUpDown.Max then PortUpDown.Position := PortUpDown.Min
      else PortUpDown.Position := PortUpDown.Position + 1;
    kDown:
      if PortUpDown.Position = PortUpDown.Min then PortUpDown.Position := PortUpDown.Max
      else PortUpDown.Position := PortUpDown.Position - 1;
    kEnter:
      ModalResult := mrOK;
  end;
  CommPort := PortUpDown.Position;
  ComLabel.Caption := CommString;
end;

end.
