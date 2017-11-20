inherited WItem: TWItem
  Caption = 'Item'
  ClientHeight = 312
  ClientWidth = 258
  OnDestroy = FormDestroy
  ExplicitWidth = 274
  ExplicitHeight = 350
  PixelsPerInch = 96
  TextHeight = 13
  inherited PanelControls: TPanel
    Width = 258
    Height = 285
    ExplicitWidth = 258
    ExplicitHeight = 209
    object LabelName: TLabel
      Left = 16
      Top = 13
      Width = 27
      Height = 13
      Caption = 'Name'
    end
    object LabelAlias: TLabel
      Left = 16
      Top = 59
      Width = 22
      Height = 13
      Caption = 'Alias'
    end
    object LabelType: TLabel
      Left = 16
      Top = 105
      Width = 24
      Height = 13
      Caption = 'Type'
    end
    object LabelPath: TLabel
      Left = 16
      Top = 151
      Width = 22
      Height = 13
      Caption = 'Path'
    end
    object LabelOwner: TLabel
      Left = 16
      Top = 197
      Width = 32
      Height = 13
      Caption = 'Owner'
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
    object EditOwner: TDBEdit
      Left = 16
      Top = 216
      Width = 161
      Height = 21
      DataField = 'OWNER'
      DataSource = DataSource
      TabOrder = 4
    end
  end
  inherited PanelTools: TPanel
    Top = 285
    Width = 258
    ExplicitTop = 209
    ExplicitWidth = 258
    inherited ButtonOk: TButton
      Left = 131
      ExplicitLeft = 131
    end
    inherited ButtonCancel: TButton
      Left = 197
      ExplicitLeft = 197
    end
  end
  object DataSource: TDataSource
    Left = 200
    Top = 40
  end
end
