object WDlgOkCancel: TWDlgOkCancel
  Left = 658
  Top = 325
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Di'#225'logo aceptar cancelar'
  ClientHeight = 153
  ClientWidth = 271
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PanelBotones: TPanel
    Left = 0
    Top = 126
    Width = 271
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    Color = clSilver
    TabOrder = 1
    ExplicitTop = 80
    ExplicitWidth = 155
    DesignSize = (
      271
      27)
    object BTAceptar: TButton
      Left = 144
      Top = 4
      Width = 60
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Aceptar'
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 28
    end
    object BTCancelar: TButton
      Left = 210
      Top = 4
      Width = 60
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Cancelar'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 94
    end
  end
  object PanelBg: TPanel
    Left = 0
    Top = 0
    Width = 271
    Height = 126
    Align = alClient
    Color = 15329769
    TabOrder = 0
    ExplicitWidth = 155
    ExplicitHeight = 80
  end
end
