object WItems: TWItems
  Left = 0
  Top = 0
  Caption = 'Items'
  ClientHeight = 546
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 600
    Height = 38
    ButtonHeight = 38
    ButtonWidth = 39
    Caption = 'ToolBar1'
    Images = DMImages.ImageListToolbar
    TabOrder = 0
    object ToolButtonRefresh: TToolButton
      Left = 0
      Top = 0
      Action = ActionRefresh
    end
    object ToolButtonAdd: TToolButton
      Left = 39
      Top = 0
      Action = ActionAdd
    end
    object ToolButtonFilterModule: TToolButton
      Left = 78
      Top = 0
      Action = ActionFilterModule
      Style = tbsCheck
    end
    object ToolButtonFilterApp: TToolButton
      Left = 117
      Top = 0
      Action = ActionFilterApp
      Style = tbsCheck
    end
    object ToolButtonFilterLibrary: TToolButton
      Left = 156
      Top = 0
      Action = ActionFilterLibrary
      Style = tbsCheck
    end
    object ToolButtonFilterPackage: TToolButton
      Left = 195
      Top = 0
      Action = ActionFilterPackage
      Style = tbsCheck
    end
    object ToolButtonFilterFile: TToolButton
      Left = 234
      Top = 0
      Action = ActionFilterFiles
      Style = tbsCheck
    end
    object ToolButtonClose: TToolButton
      Left = 273
      Top = 0
      Action = ActionClose
    end
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 79
    Width = 600
    Height = 467
    Align = alClient
    DefaultDrawing = False
    PopupMenu = PopupMenuGrid
    ReadOnly = True
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'Tahoma'
    TitleFont.Style = []
    OnDrawColumnCell = DBGridDrawColumnCell
  end
  object Panel1: TPanel
    Left = 0
    Top = 38
    Width = 600
    Height = 41
    Align = alTop
    TabOrder = 2
    ExplicitLeft = 216
    ExplicitTop = 272
    ExplicitWidth = 185
    object PanelDropFile: TPanel
      Left = 1
      Top = 1
      Width = 598
      Height = 39
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitLeft = 208
      ExplicitTop = 0
      ExplicitWidth = 185
      ExplicitHeight = 41
    end
  end
  object ActionList: TActionList
    Images = DMImages.ImageListToolbar
    Left = 440
    Top = 272
    object ActionRefresh: TAction
      Caption = 'Refresh'
      Hint = 'Refresh'
      ImageIndex = 2
      OnExecute = ActionRefreshExecute
    end
    object ActionClose: TAction
      Caption = 'Close'
      Hint = 'Close'
      ImageIndex = 6
      OnExecute = ActionCloseExecute
    end
    object ActionFilterModule: TAction
      Caption = 'Filter module'
      ImageIndex = 8
      OnExecute = ActionFilterModuleExecute
    end
    object ActionFilterApp: TAction
      Caption = 'Filter App'
      ImageIndex = 8
      OnExecute = ActionFilterAppExecute
    end
    object ActionFilterLibrary: TAction
      Caption = 'Filter Library'
      ImageIndex = 8
      OnExecute = ActionFilterLibraryExecute
    end
    object ActionFilterPackage: TAction
      Caption = 'Filter Package'
      ImageIndex = 8
      OnExecute = ActionFilterPackageExecute
    end
    object ActionFilterFiles: TAction
      Caption = 'Filter Files'
      ImageIndex = 8
      OnExecute = ActionFilterFilesExecute
    end
    object ActionCompose: TAction
      Caption = 'Compose'
      OnExecute = ActionComposeExecute
    end
    object ActionVersions: TAction
      Caption = 'Versions'
      OnExecute = ActionVersionsExecute
    end
    object ActionAdd: TAction
      Caption = 'Add'
      ImageIndex = 0
      OnExecute = ActionAddExecute
    end
  end
  object PopupMenuGrid: TPopupMenu
    Left = 280
    Top = 296
    object MICompose: TMenuItem
      Action = ActionCompose
    end
    object MIVersions: TMenuItem
      Action = ActionVersions
    end
  end
end
