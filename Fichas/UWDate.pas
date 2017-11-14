unit UWDate;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UWDlgOkCancel, StdCtrls, ComCtrls, ExtCtrls;

type
  TWDate = class(TWDlgOkCancel)
    DateTimePicker: TDateTimePicker;
    LabelDate: TLabel;
  private
  public
  end;

var
  WDate: TWDate;

function EditDate(var ADate: TDate): Boolean;

implementation

{$R *.dfm}

function EditDate(var ADate: TDate): Boolean;
begin
  with TWDate.Create(nil) do
  try
    if ADate <> 0 then
      DateTimePicker.Date := ADate;
    if ShowModal = mrOk then
    begin
      ADate := DateTimePicker.Date;
      Result := True;
    end
    else Result := False;
  finally
    Free;
  end;
end;

end.
