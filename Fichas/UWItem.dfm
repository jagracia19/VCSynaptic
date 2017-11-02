inherited WItem: TWItem
  Caption = 'WItem'
  ClientHeight = 236
  ClientWidth = 258
  ExplicitWidth = 274
  ExplicitHeight = 274
  PixelsPerInch = 96
  TextHeight = 13
  inherited PanelControls: TPanel
    Width = 258
    Height = 209
    ExplicitWidth = 418
    ExplicitHeight = 255
    object LabelName: TLabel
      Left = 16
      Top = 13
      Width = 52
      Height = 13
      Caption = 'LabelName'
    end
    object LabelAlias: TLabel
      Left = 16
      Top = 59
      Width = 47
      Height = 13
      Caption = 'LabelAlias'
    end
    object LabelType: TLabel
      Left = 16
      Top = 105
      Width = 49
      Height = 13
      Caption = 'LabelType'
    end
    object LabelPath: TLabel
      Left = 16
      Top = 151
      Width = 47
      Height = 13
      Caption = 'LabelPath'
    end
    object EditName: TDBEdit
      Left = 16
      Top = 32
      Width = 161
      Height = 21
      DataField = 'NAME'
      DataSource = DataSource
      TabOrder = 0
    end
    object EditAlias: TDBEdit
      Left = 16
      Top = 78
      Width = 121
      Height = 21
      DataField = 'ALIAS'
      DataSource = DataSource
      TabOrder = 1
    end
    object EditPath: TDBEdit
      Left = 16
      Top = 170
      Width = 217
      Height = 21
      DataField = 'PATH'
      DataSource = DataSource
      TabOrder = 3
    end
    object ComboBoxType: TDBComboBox
      Left = 16
      Top = 124
      Width = 121
      Height = 21
      DataField = 'ITEM_TYPE'
      DataSource = DataSource
      Items.Strings = (
        'FILE'
        'PACKAGE'
        'LIBRARY'
        'APP'
        'MODULE')
      TabOrder = 2
    end
  end
  inherited PanelTools: TPanel
    Top = 209
    Width = 258
    ExplicitTop = 255
    ExplicitWidth = 418
    inherited ButtonOk: TButton
      Left = 131
      ExplicitLeft = 291
    end
    inherited ButtonCancel: TButton
      Left = 197
      ExplicitLeft = 357
    end
  end
  object DataSource: TDataSource
    Left = 200
    Top = 40
  end
end
