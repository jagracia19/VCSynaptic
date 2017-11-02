object DMCompose: TDMCompose
  OldCreateOrder = False
  Height = 210
  Width = 241
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
end
