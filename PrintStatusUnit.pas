unit PrintStatusUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls;

type
  TPrintStatusForm = class(TForm)
    PrintingLabel: TLabel;
    PagesLabel: TLabel;
    CancelButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure NextPage;
  private
    Page: integer;
  public
    Cancelled: boolean;
  end;

var
  PrintStatusForm: TPrintStatusForm;

implementation

uses PrintUnit;

{$R *.DFM}

procedure TPrintStatusForm.FormShow(Sender: TObject);
begin
  Cancelled := False;
  Page := 0;
  NextPage;
end;

procedure TPrintStatusForm.FormActivate(Sender: TObject);
begin
  Refresh;
end;

procedure TPrintStatusForm.CancelButtonClick(Sender: TObject);
begin
  Cancelled := True;
end;

procedure TPrintStatusForm.NextPage;
begin
  PagesLabel.Caption := IntToStr(Page) + ' of ' + IntToStr(PrintForm.Pages);
  PagesLabel.Refresh;
  Inc(Page);
end;

end.

