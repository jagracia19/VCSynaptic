object WCompose: TWCompose
  Left = 0
  Top = 0
  Caption = 'Compose'
  ClientHeight = 614
  ClientWidth = 628
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Grid: TStringGrid
    Left = 0
    Top = 0
    Width = 628
    Height = 614
    Align = alClient
    DefaultColWidth = 60
    DefaultRowHeight = 18
    DoubleBuffered = False
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    ParentDoubleBuffered = False
    TabOrder = 0
    OnClick = GridClick
    OnDrawCell = GridDrawCell
  end
end
