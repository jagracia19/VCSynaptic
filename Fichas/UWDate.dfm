inherited WDate: TWDate
  Caption = 'WDate'
  ClientHeight = 90
  ClientWidth = 209
  ExplicitWidth = 215
  ExplicitHeight = 118
  PixelsPerInch = 96
  TextHeight = 13
  inherited PanelBotones: TPanel
    Top = 63
    Width = 209
    inherited BTAceptar: TButton
      Left = 82
      ExplicitLeft = 144
    end
    inherited BTCancelar: TButton
      Left = 148
      ExplicitLeft = 210
    end
  end
  inherited PanelBg: TPanel
    Width = 209
    Height = 63
    ExplicitWidth = 271
    ExplicitHeight = 126
    object LabelDate: TLabel
      Left = 8
      Top = 8
      Width = 23
      Height = 13
      Caption = 'Date'
    end
    object DateTimePicker: TDateTimePicker
      Left = 8
      Top = 27
      Width = 186
      Height = 21
      Date = 43053.905601446760000000
      Time = 43053.905601446760000000
      TabOrder = 0
    end
  end
end
