inherited WItemVersion: TWItemVersion
  Caption = 'Item'
  ClientHeight = 278
  ClientWidth = 258
  OnDestroy = FormDestroy
  ExplicitWidth = 274
  ExplicitHeight = 316
  PixelsPerInch = 96
  TextHeight = 13
  inherited PanelControls: TPanel
    Width = 258
    Height = 251
    ExplicitWidth = 258
    ExplicitHeight = 251
    object LabelItemName: TLabel
      Left = 16
      Top = 13
      Width = 51
      Height = 13
      Caption = 'Item name'
    end
    object LabelVerOrder: TLabel
      Left = 16
      Top = 59
      Width = 64
      Height = 13
      Caption = 'Version order'
    end
    object LabelVerDate: TLabel
      Left = 16
      Top = 151
      Width = 23
      Height = 13
      Caption = 'Date'
    end
    object LabelVerNumber: TLabel
      Left = 16
      Top = 105
      Width = 74
      Height = 13
      Caption = 'Version number'
    end
    object LabelVerHash: TLabel
      Left = 16
      Top = 197
      Width = 61
      Height = 13
      Caption = 'Version hash'
    end
    object EditItemName: TDBEdit
      Left = 16
      Top = 32
      Width = 161
      Height = 21
      DataField = 'ITEM_NAME'
      DataSource = DataSource
      TabOrder = 0
    end
    object EditVerOrder: TDBEdit
      Left = 16
      Top = 78
      Width = 121
      Height = 21
      DataField = 'VERSION_ORDER'
      DataSource = DataSource
      TabOrder = 1
    end
    object EditVerDate: TDBEdit
      Left = 16
      Top = 170
      Width = 217
      Height = 21
      DataField = 'VERSION_DATE'
      DataSource = DataSource
      TabOrder = 2
    end
    object EditVerNumber: TDBEdit
      Left = 16
      Top = 124
      Width = 121
      Height = 21
      DataField = 'VERSION_NUMBER'
      DataSource = DataSource
      TabOrder = 3
    end
    object EditVerHash: TDBEdit
      Left = 16
      Top = 216
      Width = 217
      Height = 21
      DataField = 'VERSION_HASH'
      DataSource = DataSource
      TabOrder = 4
    end
  end
  inherited PanelTools: TPanel
    Top = 251
    Width = 258
    ExplicitTop = 251
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
