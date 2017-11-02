unit UWMasterEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TWMasterEdit = class(TForm)
    PanelControls: TPanel;
    PanelTools: TPanel;
    ButtonOk: TButton;
    ButtonCancel: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
  public
    procedure UpdateLanguage; virtual;
  end;

var
  WMasterEdit: TWMasterEdit;

implementation

uses
  Language.Interf;

{$R *.dfm}

procedure TWMasterEdit.FormCreate(Sender: TObject);
begin
  UpdateLanguage;
end;

procedure TWMasterEdit.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_RETURN:
      if not (Sender is TButton) then
        PostMessage(Handle, WM_NEXTDLGCTL, 0, 0);

    VK_ESCAPE: Close;
  end;
end;

procedure TWMasterEdit.UpdateLanguage;
begin
  Caption := Application.Title;
  ButtonOk.Caption := Cpt('Aceptar');
  ButtonCancel.Caption := Cpt('Cancelar');
end;

end.
