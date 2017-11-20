unit Test.DataModule;

interface

uses
  SysUtils, Classes, FIBDatabase, pFIBDatabase;

type
  TDataModuleTest = class(TDataModule)
    Database: TpFIBDatabase;
    Transaction: TpFIBTransaction;
    TransactionUpdate: TpFIBTransaction;
  private
  public
  end;

var
  DataModuleTest: TDataModuleTest;

implementation

{$R *.dfm}

end.
