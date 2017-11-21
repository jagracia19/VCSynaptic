unit UDMFinder;

interface

uses
  SysUtils, Classes, FIBDatabase, pFIBDatabase, pFIBDataSet;

type
  TDMFinder = class(TDataModule)
    Transaction: TpFIBTransaction;
  private
    FDatabase: TpFIBDatabase;
    FConnected: Boolean;
    procedure SetDatabase(const Value: TpFIBDatabase);
  public
    procedure Connect;
    procedure Disconnect;
    property Database: TpFIBDatabase read FDatabase write SetDatabase;
    property Connected: Boolean read FConnected;
  end;

var
  DMFinder: TDMFinder;

implementation

{$R *.dfm}

{ TDMFinder }

procedure TDMFinder.Connect;
begin
  Transaction.StartTransaction;
  FConnected := True;
end;

procedure TDMFinder.Disconnect;
begin
  if Transaction.InTransaction then
    Transaction.Commit;
  FConnected := False;
end;

procedure TDMFinder.SetDatabase(const Value: TpFIBDatabase);
var I : Integer;
    ds: TpFIBDataSet;
begin
  FDatabase := Value;

  Transaction.DefaultDatabase := Database;

  for I := 0 to ComponentCount-1 do
    if Components[I] is TpFIBDataSet then
    begin
      ds := TpFIBDataSet(Components[I]);
      ds.Database := Database;
    end;
end;

end.
