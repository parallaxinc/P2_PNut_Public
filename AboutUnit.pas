unit AboutUnit;

interface

uses
  Controls, StdCtrls, Classes, Forms, ExtCtrls;

type
  TAboutForm = class(TForm)
    TitleLabel: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    TopPathLabel: TLabel;
    CurrentPathLabel: TLabel;
    LibraryPathLabel: TLabel;
    CopyrightLabel: TLabel;
    WebLabel: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    OkayButton: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.DFM}

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ModalResult := mrOk;
end;

end.
