unit UDMItems;

interface

uses
  VCSynaptic.Classes,
  SysUtils, Classes, DB, FIBDataSet, pFIBDataSet, FIBDatabase, pFIBDatabase,
  StrUtils;

type
  TDMItems = class(TDataModule)
    Transaction: TpFIBTransaction;
    TransactionUpdate: TpFIBTransaction;
    DataSet: TpFIBDataSet;
    DataSource: TDataSource;
  private
    FDatabase: TpFIBDatabase;
    FConnected: Boolean;
    FItemTypes: TItemTypeSet;
    procedure InitDataSetSQLs;
    procedure InitFields;
    procedure SetDatabase(const Value: TpFIBDatabase);
    procedure SetItemTypes(const Value: TItemTypeSet);
    function GetSQLSelect: string;
    function GetSQLInsert: string;
    function GetSQLUpdate: string;
  protected
    property SQLSelect: string read GetSQLSelect;
    property SQLInsert: string read GetSQLInsert;
    property SQLUpdate: string read GetSQLUpdate;
  public
    procedure Connect;
    procedure Disconnect;
    property Database: TpFIBDatabase read FDatabase write SetDatabase;
    property Connected: Boolean read FConnected;
    property ItemTypes: TItemTypeSet read FItemTypes write SetItemTypes;
    procedure RefreshDataSet;
  end;

var
  DMItems: TDMItems;

implementation

uses
  FIBUtils.Interf;

{$R *.dfm}

const
  CSQLSelect =
      'select * ' +
      'from item ' +
      '__WHERE__ ' +
      'order by name';

{ TDMItems }

procedure TDMItems.Connect;
begin
  Transaction.StartTransaction;
  //TransactionUpdate.StartTransaction;

  DataSet.Active := True;

  FConnected := True;
end;

procedure TDMItems.Disconnect;
begin
  DataSet.Active := False;

  //if TransactionUpdate.InTransaction then
  //  TransactionUpdate.Commit;
  if Transaction.InTransaction then
    Transaction.Commit;

  FConnected := False;
end;

function TDMItems.GetSQLInsert: string;
begin
  Result := GetSQLInsertFromRelation(Database, Transaction, 'ITEM');
end;

function TDMItems.GetSQLSelect: string;
var where   : string;
    itemType: TItemType;
begin
  where := '';
  for itemType := Low(TItemType) to High(TItemType) do
    if itemType in ItemTypes then
    begin
      if Length(where) <> 0 then
        where := where + ' or ';
      where := where + '(item_type=''' + ItemTypeToStr(itemType) + ''')';
    end;
  if Length(where) <> 0 then
    where := 'where ' + where;

  Result := CSQLSelect;
  Result := ReplaceText(CSQLSelect, '__WHERE__', where);
end;

function TDMItems.GetSQLUpdate: string;
begin
  Result := GetSQLUpdateFromRelation(Database, Transaction, 'ITEM',
      'name=:name');
end;

procedure TDMItems.InitDataSetSQLs;
begin
  DataSet.SQLs.SelectSQL.Text := SQLSelect;
  DataSet.SQLs.InsertSQL.Text := SQLInsert;
  DataSet.SQLs.UpdateSQL.Text := SQLUpdate;
end;

procedure TDMItems.InitFields;
//var field: TField;
begin
//  if DataSet.FindField('shape_type_name') = nil then
//  begin
//    THackFIBDataset(DataSet).FieldDefs.Update;
//    THackFIBDataset(DataSet).CreateFields;
//
//    // create calculate field "shape_type_name"
//    field := TFIBStringField.Create(DataSet);
//    field.Name := 'DataSet_shape_type_name';
//    field.FieldKind := fkCalculated;
//    field.FieldName := 'shape_type_name';
//    field.Size := 1024;
//    field.DataSet := Self.DataSet;
//
//    // create calculate field "production_state_name"
//    field := TFIBStringField.Create(DataSet);
//    field.Name := 'DataSet_production_state_name';
//    field.FieldKind := fkCalculated;
//    field.FieldName := 'production_state_name';
//    field.Size := 1024;
//    field.DataSet := Self.DataSet;
//
//    // create calculate field "target_machine_name"
//    field := TFIBStringField.Create(DataSet);
//    field.Name := 'DataSet_target_machine_name';
//    field.FieldKind := fkCalculated;
//    field.FieldName := 'target_machine_name';
//    field.Size := 1024;
//    field.DataSet := Self.DataSet;
//
//    // create calculate field "target_bin_name"
//    field := TFIBStringField.Create(DataSet);
//    field.Name := 'DataSet_target_bin_name';
//    field.FieldKind := fkCalculated;
//    field.FieldName := 'target_bin_name';
//    field.Size := 1024;
//    field.DataSet := Self.DataSet;
//  end;
end;

procedure TDMItems.RefreshDataSet;
begin
  InitDataSetSQLs;
end;

procedure TDMItems.SetDatabase(const Value: TpFIBDatabase);
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
  InitFields;
end;

procedure TDMItems.SetItemTypes(const Value: TItemTypeSet);
begin
  FItemTypes := Value;
end;

end.
