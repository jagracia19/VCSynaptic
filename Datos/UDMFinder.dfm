object DMFinder: TDMFinder
  OldCreateOrder = False
  Height = 150
  Width = 215
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
end
