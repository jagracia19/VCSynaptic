unit UDMCompose;

interface

uses
  pFIBDataSet,
  SysUtils, Classes, FIBDatabase, pFIBDatabase;

type
  TDMCompose = class(TDataModule)
    Transaction: TpFIBTransaction;
    TransactionUpdate: TpFIBTransaction;
  private
    FDatabase: TpFIBDatabase;
    FConnected: Boolean;
    procedure SetDatabase(const Value: TpFIBDatabase);
  protected
  public
    procedure Connect;
    procedure Disconnect;
    property Database: TpFIBDatabase read FDatabase write SetDatabase;
    property Connected: Boolean read FConnected;
  end;

var
  DMCompose: TDMCompose;

implementation

{$R *.dfm}

{ TDMCompose }

procedure TDMCompose.Connect;
begin
  Transaction.StartTransaction;
  //TransactionUpdate.StartTransaction;

  FConnected := True;
end;

procedure TDMCompose.Disconnect;
begin
  //if TransactionUpdate.InTransaction then
  //  TransactionUpdate.Commit;
  if Transaction.InTransaction then
    Transaction.Commit;

  FConnected := False;
end;

procedure TDMCompose.SetDatabase(const Value: TpFIBDatabase);
var I : Integer;
    ds: TpFIBDataSet;
begin
  FDatabase := Value;

  Transaction.DefaultDatabase := Database;
  TransactionUpdate.DefaultDatabase := Database;

  for I := 0 to ComponentCount-1 do
    if Components[I] is TpFIBDataSet then
    begin
      ds := TpFIBDataSet(Components[I]);
      ds.Database := Database;
    end;
end;

end.
