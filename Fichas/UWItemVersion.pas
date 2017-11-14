unit UWItemVersion;

interface

uses
  VCSynaptic.Classes,
  pFIBDatabase, pFIBDataSet,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UWMasterEdit, StdCtrls, ExtCtrls, DB, DBClient, DBCtrls, Mask,
  ShellAPI, StrUtils;

type
  TWItemVersion = class(TWMasterEdit)
    LabelItemName: TLabel;
    LabelVerOrder: TLabel;
    LabelVerDate: TLabel;
    EditItemName: TDBEdit;
    EditVerOrder: TDBEdit;
    EditVerDate: TDBEdit;
    DataSource: TDataSource;
    LabelVerNumber: TLabel;
    EditVerNumber: TDBEdit;
    LabelVerHash: TLabel;
    EditVerHash: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDataSet: TDataSet;
    FDatabase: TpFIBDatabase;
    FTransaction: TpFIBTransaction;
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure SetDataSet(const Value: TDataSet);
    procedure SetDatabase(const Value: TpFIBDatabase);
    procedure SetTransaction(const Value: TpFIBTransaction);
  public
    procedure UpdateLanguage; override;
    procedure InitFromItemName(const ItemName: string);
    procedure DropFileName(const Filename: string);
    property Database: TpFIBDatabase read FDatabase write SetDatabase;
    property Transaction: TpFIBTransaction read FTransaction write SetTransaction;
    property DataSet: TDataSet read FDataSet write SetDataSet;
  end;

var
  WItemVersion: TWItemVersion;

implementation

uses
  UHash,
  VCSynaptic.Database,
  Language.Interf;

{$R *.dfm}

{ TWItem }

procedure TWItemVersion.DropFileName(const Filename: string);
var itemAlias : string;
    itemName  : string;
begin
  itemAlias := TItem.GetAliasFilename(Filename);
  itemName := TItemRelation.GetNameFromAlias(Database, Transaction, itemAlias);
  if Length(itemName) = 0 then
    raise Exception.Create(Format('Alias item %s not found', [itemAlias]));
  InitFromItemName(itemName);
  DataSet.FieldByName('version_hash').AsString :=
      LowerCase(HashFileSHA1(Filename));
end;

procedure TWItemVersion.FormCreate(Sender: TObject);
begin
  inherited;
  DragAcceptFiles(Handle, True);
end;

procedure TWItemVersion.FormDestroy(Sender: TObject);
begin
  inherited;
  DragAcceptFiles(Handle, False);
end;

procedure TWItemVersion.InitFromItemName(const ItemName: string);
begin
  DataSet.FieldByName('item_name').AsString := ItemName;
  DataSet.FieldByName('version_order').AsInteger :=
      TItemVersionRelation.GetNextOrder(Database, Transaction, ItemName);
  DataSet.FieldByName('version_number'). Clear;
  DataSet.FieldByName('version_date').AsDateTime := Date;
  DataSet.FieldByName('version_hash').Clear;
end;

procedure TWItemVersion.SetDatabase(const Value: TpFIBDatabase);
begin
  FDatabase := Value;
end;

procedure TWItemVersion.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
  DataSource.DataSet := FDataSet;
end;

procedure TWItemVersion.SetTransaction(const Value: TpFIBTransaction);
begin
  FTransaction := Value;
end;

procedure TWItemVersion.UpdateLanguage;
begin
  inherited;
  Caption := Cpt('Item');
end;

procedure TWItemVersion.WMDropFiles(var Msg: TMessage);
var hDrop     : THandle;
    fileCount : Integer;
    nameLen   : Integer;
    index     : Integer;
    st        : string;
begin
  hDrop:= Msg.wParam;
  fileCount:= DragQueryFile(hDrop, $FFFFFFFF, nil, 0);
  if fileCount > 0 then
  begin
    index := 0;
    nameLen := DragQueryFile(hDrop, index, nil, 0) + 1;
    SetLength(st, nameLen);
    DragQueryFile(hDrop, index, Pointer(st), nameLen);
    while EndsStr(#0, st) do
      Delete(st, Length(st), 1);
    DropFilename(st);
  end;
  DragFinish(hDrop);
end;

end.
