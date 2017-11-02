object DMPrincipal: TDMPrincipal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 330
  Width = 405
  object Database: TpFIBDatabase
    DBName = 'C:\VCS2\Utils\VCSynaptic\Db\VCSSYNAPTIC.FDB'
    DBParams.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=UTF8')
    SQLDialect = 3
    Timeout = 0
    LibraryName = 'C:\VCS2\Utils\VCSynaptic\Debug\Win32\fbclient.dll'
    WaitForRestoreConnect = 0
    Left = 48
    Top = 40
  end
  object Transaction: TpFIBTransaction
    DefaultDatabase = Database
    TimeoutAction = TARollback
    TRParams.Strings = (
      'read'
      'nowait'
      'rec_version'
      'read_committed')
    TPBMode = tpbDefault
    Left = 152
    Top = 40
  end
  object TransactionUpdate: TpFIBTransaction
    DefaultDatabase = Database
    TimeoutAction = TARollback
    TRParams.Strings = (
      'write'
      'nowait'
      'rec_version'
      'read_committed')
    TPBMode = tpbDefault
    Left = 152
    Top = 112
  end
end
