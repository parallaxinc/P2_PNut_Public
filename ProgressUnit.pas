unit ProgressUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, ExtCtrls,
  Dialogs, ComCtrls, StdCtrls;

type
  TProgressForm = class(TForm)
    StatusLabel: TLabel;
  end;

var
  ProgressForm: TProgressForm;

implementation

uses ShellAPI, GlobalUnit;

{$R *.DFM}

end.

