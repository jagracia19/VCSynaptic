unit TestUFinder;

interface

uses
  UFinder,
  pFIBDatabase, pFIBQuery,
  Test.DataModule,
  TestFramework, SysUtils, Classes, Generics.Collections;

type
  TestFinde = class(TTestCase)
  strict private
    FDataModule: TDataModuleTest;
    FFiles: TStrings;
    FFinderItems: TFinderItemList;
  protected
    property DataModule: TDataModuleTest read FDataModule;
    property Files: TStrings read FFiles;
    property FinderItems: TFinderItemList read FFinderItems;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFinderFile;
  end;

implementation

uses
  VCSynaptic.Classes,
  VCSynaptic.Database,
  UHash;

procedure TestFinde.SetUp;
begin
  FDataModule := TDataModuleTest.Create(nil);
  FDataModule.Database.Connected := True;

  FFiles := TStringList.Create;
  FFinderItems := TFinderItemList.Create(True);
end;

procedure TestFinde.TearDown;
begin
  FreeAndNil(FFinderItems);
  FreeAndNil(FFiles);

  FDataModule.Database.Connected := False;
  FDataModule.Free;
  FDataModule := nil;
end;

procedure FindOwners(ADatabase: TpFIBDatabase; ATransaction: TpFIBTransaction;
  AFinderNode: TFinderNode; AFinderItem: TFinderItem);
var query   : TpFIBQuery;
    fCommit : Boolean;
begin
  query := TpFIBQuery.Create(nil);
  try
    query.Database := ADatabase;
    query.Transaction := ATransaction;
    query.SQL.Text :=
        'select owner_item_name, owner_version_order ' +
        'from item_link ' +
        'where ' +
        ' (child_item_name=:child_item_name) and ' +
        ' (child_version_order=:child_version_order) ' +
        'order by owner_item_name, owner_version_order';
    fCommit := not ATransaction.InTransaction;
    if fCommit then ATransaction.StartTransaction;
    try
      query.ParamByName('child_item_name').AsString := AFinderNode.ItemName;
      query.ParamByName('child_version_order').AsInteger :=
          AFinderNode.VersionOrder;
      while not query.Eof do
      begin

      end;
      query.Close;
    finally
      if fCommit then
        try
          ATransaction.Commit;
        except
          ATransaction.Rollback;
          raise;
        end;
    end;
  finally
    query.Free;
  end;
end;

procedure TestFinde.TestFinderFile;
var filename    : string;
    itemName    : string;
    versionHash : string;
    itemVersion : TItemVersion;
    auxItemName : string;
    item        : TItem;
    finderItem  : TFinderItem;
    finderNode  : TFinderNode;
begin
  Files.Add('C:\VCS2\OptiFlow2\Ausreo\Release\Win32\OptiFlowVarLog.bpl');
  Files.Add('C:\VCS2\OptiFlow2\Ausreo\Release\Win32\fbclient.dll');

  for filename in Files do
  begin
    itemVersion := TItemVersion.Create(nil);
    try
      itemName := TItem.GetCamelCaseName(ExtractFileName(filename));
      versionHash := LowerCase(HashFileSHA1(filename));

      // buscar item version
      if TItemVersionRelation.ReadItemHash(DataModule.Database,
          DataModule.Transaction, auxItemName, itemVersion, versionHash)
      then
      begin
        Assert(itemName = auxItemName);

        // buscar item
        item := TItemRelation.ReadItemName(DataModule.Database,
            DataModule.Transaction, nil, itemName);
        try
          // crear finder node
          finderItem := TFinderItem.Create(nil);
          FinderItems.Add(finderItem);
          finderItem.Filename := filename;

          finderNode := TFinderNode.Create(nil);
          finderNode.ItemName := itemName;
          finderNode.ItemType := item.ItemType;
          finderNode.VersionOrder := itemVersion.Order;
          finderItem.Root := finderNode;

          finderItem.Leaves.Add(finderNode);
        finally
          item.Free;
        end;
      end
    finally
      itemVersion.Free;
    end;
  end;
end;

initialization
  RegisterTest(TestFinde.Suite);

end.

