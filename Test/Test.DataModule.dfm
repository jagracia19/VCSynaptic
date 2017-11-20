object DataModuleTest: TDataModuleTest
  OldCreateOrder = False
  Height = 225
  Width = 402
  object Database: TpFIBDatabase
    DBName = 'C:\VCS2\Utils\VCSynaptic\Db\VCSYNAPTIC.FDB'
    DBParams.Strings = (
      'user_name=SYSDBA'
      'password=masterkey'
      'lc_ctype=UTF8')
    SQLDialect = 3
    Timeout = 0
    LibraryName = 'C:\VCS2\Utils\VCSynaptic\Debug\Win32\fbclient.dll'
    WaitForRestoreConnect = 0
    Left = 40
    Top = 48
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
    Left = 128
    Top = 48
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
    Left = 128
    Top = 120
  end
end
