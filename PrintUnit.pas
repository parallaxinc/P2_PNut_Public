unit PrintUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, ComCtrls, Printers, Spin;

type
  TPrintForm = class(TForm)
    PrinterComboBox: TComboBox;
    RangeGroup: TRadioGroup;
    OrientationGroup: TRadioGroup;
    FontSizeLabel: TLabel;
    FontSizeSpinEdit: TSpinEdit;
    SectionsLabel: TLabel;
    SectionsSpinEdit: TSpinEdit;
    PageLabel: TLabel;
    CharacterLabel: TLabel;
    UsageLabel: TLabel;
    OkayButton: TButton;
    CancelButton: TButton;
    procedure FormActivate(Sender: TObject);
    procedure UpdateSettings(Sender: TObject);
    procedure OkayButtonClick(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
  public
    AllLines: integer;                  // pre-written by caller
    SelectedLines: integer;             // pre-written by caller
    FontSize: integer;                  // may be pre-written by caller
    Sections: integer;                  // read by caller
    Columns, Rows: integer;             // read by caller
    ChrWidth, ChrHeight: integer;       // read by caller
    XOffset, YOffset: integer;          // read by caller
    PrintSelection: boolean;            // read by caller
    Lines: integer;                     // read by caller
    Pages: integer;                     // read by caller
  end;

var
  PrintForm: TPrintForm;
  Activating: boolean;

implementation

uses GlobalUnit;

{$R *.DFM}

procedure TPrintForm.FormActivate(Sender: TObject);
begin
  // Init controls
  Activating := True;
  PrinterComboBox.Items := Printer.Printers;
  PrinterComboBox.ItemIndex := Printer.PrinterIndex;
  RangeGroup.ItemIndex := Ord(SelectedLines <> 0);
  OrientationGroup.ItemIndex := Ord(Printer.Orientation);
  FontSizeSpinEdit.Value := FontSize;
  SectionsSpinEdit.Value := Sections;
  Activating := False;
  UpdateSettings(Self);
end;

procedure TPrintForm.UpdateSettings(Sender: TObject);
begin
  if Activating then Exit;
  // Set printer
  if Printer.PrinterIndex <> PrinterComboBox.ItemIndex then
    Printer.PrinterIndex := PrinterComboBox.ItemIndex;
  if Ord(Printer.Orientation) <> OrientationGroup.ItemIndex then
    Printer.Orientation := TPrinterOrientation(OrientationGroup.ItemIndex);
  // Set font size
  FontSize := FontSizeSpinEdit.Value;
  Printer.Canvas.Font.Name := FontName;
  Printer.Canvas.Font.Size := FontSize;
  Canvas.Font.Style := FontStyle;
  ChrWidth := Printer.Canvas.TextWidth('X');
  ChrHeight := Printer.Canvas.TextHeight('X');
  // Set sections, columns, rows, and offsets
  Sections := SectionsSpinEdit.Value;
  Columns := Printer.PageWidth div ChrWidth;
  if Sections > 1 then Columns := (Columns - (Sections + 1)) div Sections;
  if Columns < 0 then Columns := 0;
  Rows := Printer.PageHeight div ChrHeight;
  XOffset := (Printer.PageWidth - ((Sections + 1) * Ord(Sections > 1) + Sections * Columns) * ChrWidth) shr 1;
  YOffset := (Printer.PageHeight - Rows * ChrHeight) shr 1;
  // Show dimensions
  PageLabel.Caption := IntToStr(Columns) + ' Column x ' + IntToStr(Sections * Rows) + ' Line Page';
  CharacterLabel.Caption := IntToStr(ChrWidth) + ' x ' + IntToStr(ChrHeight) + ' Pixel Characters';
  // Show page usage
  if RangeGroup.ItemIndex = 0 then Lines := AllLines else Lines := SelectedLines;
  Pages := (Lines + (Sections * Rows) - 1) div (Sections * Rows);
  UsageLabel.Caption := IntToStr(Lines) + ' Lines = ' + IntToStr(Pages) + ' Page' + Chr(Byte('s') * Ord(Pages <> 1));
  // Update flags
  PrintSelection := boolean(RangeGroup.ItemIndex);
  OkayButton.Enabled := (Columns > 0) and (Lines <> 0);
end;

procedure TPrintForm.OkayButtonClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TPrintForm.CancelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.

