unit UDMItemVersion;

interface

uses
  SysUtils, Classes, DB, FIBDataSet, pFIBDataSet, FIBDatabase, pFIBDatabase;

type
  TDMItemVersion = class(TDataModule)
    Transaction: TpFIBTransaction;
    TransactionUpdate: TpFIBTransaction;
    DataSet: TpFIBDataSet;
    DataSource: TDataSource;
  private
    FDatabase: TpFIBDatabase;
    FConnected: Boolean;
    FSelectWhere: string;
    procedure InitDataSetSQLs;
    procedure SetDatabase(const Value: TpFIBDatabase);
    procedure SetSelectWhere(const Value: string);
  public
    procedure Connect;
    procedure Disconnect;
    property Database: TpFIBDatabase read FDatabase write SetDatabase;
    property Connected: Boolean read FConnected;
    property SelectWhere: string read FSelectWhere write SetSelectWhere;
  end;

var
  DMItemVersion: TDMItemVersion;

implementation

uses
  FIBUtils.Interf;

{$R *.dfm}

{ TDMItemVersion }

procedure TDMItemVersion.Connect;
begin
  Transaction.StartTransaction;
  //TransactionUpdate.StartTransaction;

  DataSet.Active := True;

  FConnected := True;
end;

procedure TDMItemVersion.Disconnect;
begin
  DataSet.Active := False;

  //if TransactionUpdate.InTransaction then
  //  TransactionUpdate.Commit;
  if Transaction.InTransaction then
    Transaction.Commit;

  FConnected := False;
end;

procedure TDMItemVersion.InitDataSetSQLs;
var where: string;
begin
  if Length(SelectWhere) <> 0 then
      where := ' where ' + SelectWhere
  else where := '';
  DataSet.SQLs.SelectSQL.Text :=
      'select * from item_version ' +
      where +
      'order by item_name, version_order';

  DataSet.SQLs.InsertSQL.Text :=
      GetSQLInsertFromRelation(Database, Transaction, 'item_version',
      'version_order');

  DataSet.SQLs.UpdateSQL.Text :=
      GetSQLUpdateFromRelation(Database, Transaction, 'item_version',
      '(item_name=:old_item_name) and (version_order=:old_version_order)');

  DataSet.SQLs.DeleteSQL.Text :=
      'delete from item_version ' +
      'where (item_name=:old_item_name) and (version_order=:old_version_order)';

  DataSet.SQLs.RefreshSQL.Text :=
      'select * from item_version ' +
      'where (item_name=:old_item_name) and (version_order=:old_version_order)';
end;

procedure TDMItemVersion.SetDatabase(const Value: TpFIBDatabase);
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

  InitDataSetSQLs;
  //InitFields;
end;

procedure TDMItemVersion.SetSelectWhere(const Value: string);
begin
  if FSelectWhere <> Value then
  begin
    FSelectWhere := Value;
    InitDataSetSQLs;
    //InitFields;
  end;
end;

end.
