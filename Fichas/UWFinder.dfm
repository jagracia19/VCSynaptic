object WFinder: TWFinder
  Left = 0
  Top = 0
  Caption = 'Finder'
  ClientHeight = 576
  ClientWidth = 738
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PanelDropFile: TPanel
    Left = 0
    Top = 38
    Width = 738
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 738
    Height = 38
    ButtonHeight = 38
    ButtonWidth = 39
    Caption = 'ToolBar1'
    Images = DMImages.ImageListToolbar
    TabOrder = 1
    object ToolButtonRefresh: TToolButton
      Left = 0
      Top = 0
      Action = ActionRefresh
    end
    object ToolButtonClose: TToolButton
      Left = 39
      Top = 0
      Action = ActionClose
    end
  end
  object Grid: TStringGrid
    Left = 0
    Top = 73
    Width = 738
    Height = 503
    Align = alClient
    DefaultColWidth = 80
    DefaultRowHeight = 18
    DoubleBuffered = False
    FixedCols = 0
    RowCount = 3
    FixedRows = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ParentDoubleBuffered = False
    TabOrder = 2
    OnDrawCell = GridDrawCell
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
  end
end
