unit UWDlgOkCancel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, StdCtrls,
  ExtCtrls, Forms;

type
  TWDlgOkCancel = class(TForm)
    PanelBotones: TPanel;
    BTAceptar: TButton;
    BTCancelar: TButton;
    PanelBg: TPanel;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
  public
    procedure ActualizarLenguaje; virtual;
  end;

var
  WDlgOkCancel: TWDlgOkCancel;

implementation

{$R *.DFM}

uses
  Language.Interf;

{ TWDlgOkCancel }

procedure TWDlgOkCancel.FormCreate(Sender: TObject);
begin
  ActualizarLenguaje;
end;

procedure TWDlgOkCancel.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_RETURN:
      if not (Sender is TButton) then
        PostMessage(Handle, WM_NEXTDLGCTL, 0, 0);

    VK_ESCAPE: Close;
  end;
end;

////////////////////////////////////////////////////////////
// Funciones

procedure TWDlgOkCancel.ActualizarLenguaje;
begin
  Caption := Application.Title;
  BTAceptar.Caption := Cpt('Aceptar');
  BTCancelar.Caption := Cpt('Cancelar');
end;

end.
