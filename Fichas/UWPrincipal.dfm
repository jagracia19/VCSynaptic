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
  Menu = MainMenu1
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
  object MainMenu1: TMainMenu
    Left = 176
    Top = 80
    object MIMaestros: TMenuItem
      Caption = 'Maestros'
      object MIVersiones: TMenuItem
        Action = ActionVerVersiones
      end
    end
    object MITools: TMenuItem
      Caption = 'Tools'
      object MIFinder: TMenuItem
        Action = ActionFinder
        ShortCut = 16454
      end
    end
  end
  object ActionList1: TActionList
    Left = 408
    Top = 80
    object ActionVerVersiones: TAction
      Caption = 'Versiones'
      OnExecute = ActionVerVersionesExecute
    end
    object ActionFinder: TAction
      Caption = 'Finder'
      OnExecute = ActionFinderExecute
    end
  end
end
