object WPrincipal: TWPrincipal
  Left = 0
  Top = 0
  Caption = 'VCSynaptic'
  ClientHeight = 536
  ClientWidth = 652
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PanelDock: TPanel
    Left = 0
    Top = 0
    Width = 652
    Height = 536
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PageControlDock: TPageControl
      Left = 0
      Top = 0
      Width = 652
      Height = 536
      Align = alClient
      DockSite = True
      Style = tsFlatButtons
      TabOrder = 0
    end
  end
end
