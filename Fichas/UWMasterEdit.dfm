object WMasterEdit: TWMasterEdit
  Left = 0
  Top = 0
  Caption = 'WMasterEdit'
  ClientHeight = 282
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object PanelControls: TPanel
    Left = 0
    Top = 0
    Width = 418
    Height = 255
    Align = alClient
    Color = 15329769
    TabOrder = 0
    ExplicitWidth = 155
    ExplicitHeight = 80
  end
  object PanelTools: TPanel
    Left = 0
    Top = 255
    Width = 418
    Height = 27
    Align = alBottom
    BevelOuter = bvNone
    Color = clSilver
    TabOrder = 1
    ExplicitTop = 80
    ExplicitWidth = 155
    DesignSize = (
      418
      27)
    object ButtonOk: TButton
      Left = 291
      Top = 4
      Width = 60
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&OK'
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 144
    end
    object ButtonCancel: TButton
      Left = 357
      Top = 4
      Width = 60
      Height = 21
      Anchors = [akTop, akRight]
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 210
    end
  end
end
