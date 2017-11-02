object DMItemVersion: TDMItemVersion
  OldCreateOrder = False
  Height = 196
  Width = 407
  object Transaction: TpFIBTransaction
    TimeoutAction = TARollback
    TRParams.Strings = (
      'read'
      'nowait'
      'rec_version'
      'read_committed')
    TPBMode = tpbDefault
    Left = 72
    Top = 56
  end
  object TransactionUpdate: TpFIBTransaction
    TimeoutAction = TARollback
    TRParams.Strings = (
      'write'
      'nowait'
      'rec_version'
      'read_committed')
    TPBMode = tpbDefault
    Left = 72
    Top = 128
  end
  object DataSet: TpFIBDataSet
    UpdateSQL.Strings = (
      '')
    DeleteSQL.Strings = (
      '')
    InsertSQL.Strings = (
      '')
    RefreshSQL.Strings = (
      '')
    SelectSQL.Strings = (
      '')
    Transaction = Transaction
    UpdateTransaction = TransactionUpdate
    Left = 192
    Top = 56
  end
  object DataSource: TDataSource
    DataSet = DataSet
    Left = 312
    Top = 56
  end
end
