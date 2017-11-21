unit UFinder;

interface

uses
  VCSynaptic.Classes,
  pFIBDatabase, pFIBQuery,
  SysUtils, Classes, Generics.Defaults, Generics.Collections, Types;

type
  TFinderNode = class(TComponent)
  private
    FItemName: string;
    FItemType: TItemType;
    FVersionOrder: Integer;
    function GetCount: Integer;
    function GetChildrenNode(Index: Integer): TFinderNode;
  public
    constructor Create(AOwner: TFinderNode); reintroduce; virtual;
    procedure Assign(Source: TPersistent); override;
    function Find(const AItemName: string; AVersionOrder: Integer): TFinderNode;
    function ToString: string;
    property ItemName: string read FItemName write FItemName;
    property ItemType: TItemType read FItemType write FItemType;
    property VersionOrder: Integer read FVersionOrder write FVersionOrder;
    property Count: Integer read GetCount;
    property Children[index: Integer]: TFinderNode read GetChildrenNode;
  end;

  TFinderNodeList = class(TObjectList<TFinderNode>)
  public
    function ToString: string;
    function Find(const ItemName: string; VersionOrder: Integer): TFinderNode;
    procedure CopyList(Source: TFinderNodeList);
    procedure Intersect(Source: TFinderNodeList);
    procedure Union(Source: TFinderNodeList);
    procedure SortItemNameVersion;
  end;

  TFinderItem = class(TComponent)
  private
    FFilename: string;
    FRoot: TFinderNode;
    FLeaves: TFinderNodeList;
    FOwnerName: string; // item owner name
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Filename: string read FFilename write FFilename;
    property Root: TFinderNode read FRoot write FRoot;
    property Leaves: TFinderNodeList read FLeaves;
    property OwnerName: string read FOwnerName write FOwnerName;
  end;

  TFinderItemList = class(TObjectList<TFinderItem>)
  public
    function FindFilename(const AFilename: string): TFinderItem;
  end;

  TFinder = class
  private
    FFinderItems: TFinderItemList;
    FInterLeaves: TFinderNodeList;
    FUnionLeaves: TFinderNodeList;
  protected
    class procedure FindOwners(ADatabase: TpFIBDatabase;
      ATransaction: TpFIBTransaction; AFinderNode: TFinderNode;
      AFinderItem: TFinderItem);
    procedure FinderFiles(ADatabase: TpFIBDatabase;
      ATransaction: TpFIBTransaction; AFiles: TStrings);
    class procedure IntersectLeaves(AFinderItems: TFinderItemList;
      ALeaves: TFinderNodeList);
    class procedure JoinLeaves(AFinderItems: TFinderItemList;
      ALeaves: TFinderNodeList);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Finder(ADatabase: TpFIBDatabase;
      ATransaction: TpFIBTransaction; AFiles: TStrings); overload;
    procedure Finder(ADatabase: TpFIBDatabase;
      ATransaction: TpFIBTransaction; AFiles: TStringDynArray); overload;
    property FinderItems: TFinderItemList read FFinderItems;
    property InterLeaves: TFinderNodeList read FInterLeaves;
    property UnionLeaves: TFinderNodeList read FUnionLeaves;
  end;

procedure LogFinder(const S: string);

var
  FileLogFinder: string;

implementation

uses
  VCSynaptic.Database,
  {$IFDEF TEST}
  ULogger,
  {$ENDIF}
  UHash;

procedure LogFinder(const S: string);
begin
  {$IFDEF TEST}
  if Length(FileLogFinder) <> 0 then
    LoggerWriteRaw(FileLogFinder, S);
  {$ENDIF}
end;

{ TFinderNode }

procedure TFinderNode.Assign(Source: TPersistent);
var src: TFinderNode;
begin
  if Source is TFinderNode then
  begin
    src := TFinderNode(Source);
    FItemName := src.ItemName;
    FItemType := src.ItemType;
    FVersionOrder := src.VersionOrder;
    // ??? implement assign children
  end;
end;

constructor TFinderNode.Create(AOwner: TFinderNode);
begin
  inherited Create(AOwner);
end;

function TFinderNode.Find(const AItemName: string;
  AVersionOrder: Integer): TFinderNode;
var I: Integer;
begin
  if SameText(ItemName, AItemName) and (VersionOrder = AVersionOrder) then
    Result := Self
  else
  begin
    Result := nil;
    I := 0;
    while (I < Count) and (Result = nil) do
    begin
      Result := Children[I].Find(AItemName, AVersionOrder);
      if Result = nil then
        Inc(I);
    end;
  end;
end;

function TFinderNode.GetChildrenNode(Index: Integer): TFinderNode;
begin
  Result := TFinderNode(Components[Index]);
end;

function TFinderNode.GetCount: Integer;
begin
  Result := ComponentCount;
end;

function TFinderNode.ToString: string;
begin
  Result := Format('%s:%d', [ItemName, VersionOrder]);
end;

{ TFinderItem }

constructor TFinderItem.Create(AOwner: TComponent);
begin
  inherited;
  FFilename := '';
  FRoot := nil;
  FLeaves := TFinderNodeList.Create(False);
end;

destructor TFinderItem.Destroy;
begin
  FreeAndNil(FRoot);
  FreeAndNil(FLeaves);
  inherited;
end;

{ TFinderItemList }

function TFinderItemList.FindFilename(const AFilename: string): TFinderItem;
begin
  for Result in Self do
    if SameText(Result.Filename, AFilename) then
      Exit;
  Result := nil;
end;

{ TFinderNodeList }

procedure TFinderNodeList.CopyList(Source: TFinderNodeList);
var srcFinderNode: TFinderNode;
    newFinderNode: TFinderNode;
begin
  for srcFinderNode in Source do
  begin
    newFinderNode := TFinderNode.Create(nil);
    Add(newFinderNode);
    newFinderNode.Assign(srcFinderNode);
  end;
end;

function TFinderNodeList.Find(const ItemName: string;
  VersionOrder: Integer): TFinderNode;
begin
  for Result in Self do
    if SameText(Result.ItemName, ItemName) and
       (Result.VersionOrder = VersionOrder)
    then Exit;
  Result := nil;
end;

procedure TFinderNodeList.Intersect(Source: TFinderNodeList);
var auxFinderNode : TFinderNode;
    finderNode    : TFinderNode;
    I             : Integer;
begin
  I := 0;
  while I < Count do
  begin
    finderNode := Items[I];
    auxFinderNode := Source.Find(finderNode.ItemName, finderNode.VersionOrder);
    if auxFinderNode = nil then
      Delete(I)
    else Inc(I);
  end;
end;

procedure TFinderNodeList.SortItemNameVersion;
begin
  Sort(TComparer<TFinderNode>.Construct(
    function (const Node1, Node2: TFinderNode): Integer
    begin
      Result := CompareText(Node1.ItemName, Node2.ItemName);
      if Result = 0 then
      begin
        Result := Node1.VersionOrder - Node2.VersionOrder;
      end;
    end
  ));
end;

function TFinderNodeList.ToString: string;
var finderNode:  TFinderNode;
begin
  Result := '';
  for finderNode in Self do
  begin
    if Length(Result) <> 0 then Result := Result + ' ';
    Result := Result + finderNode.ToString;
  end;
end;

procedure TFinderNodeList.Union(Source: TFinderNodeList);
var auxFinderNode : TFinderNode;
    finderNode    : TFinderNode;
begin
  for finderNode in Source do
  begin
    auxFinderNode := Find(finderNode.ItemName, finderNode.VersionOrder);
    if auxFinderNode = nil then
    begin
      auxFinderNode := TFinderNode.Create(nil);
      Add(auxFinderNode);
      auxFinderNode.Assign(finderNode);
    end;
  end;
end;

{ TFinder }

constructor TFinder.Create;
begin
  inherited;
  FFinderItems := TFinderItemList.Create(True);
  FInterLeaves := TFinderNodeList.Create(True);
  FUnionLeaves := TFinderNodeList.Create(True);
end;

destructor TFinder.Destroy;
begin
  FreeAndNil(FUnionLeaves);
  FreeAndNil(FInterLeaves);
  FreeAndNil(FFinderItems);
  inherited;
end;

procedure TFinder.Finder(ADatabase: TpFIBDatabase;
  ATransaction: TpFIBTransaction; AFiles: TStrings);
begin
  FinderFiles(ADatabase, ATransaction, AFiles);
  IntersectLeaves(FinderItems, InterLeaves);
  JoinLeaves(FinderItems, UnionLeaves);
  UnionLeaves.SortItemNameVersion;
end;

procedure TFinder.Finder(ADatabase: TpFIBDatabase;
  ATransaction: TpFIBTransaction; AFiles: TStringDynArray);
var lst: TStrings;
    st : string;
begin
  lst := TStringList.Create;
  try
    for st in AFiles do
      lst.Add(st);
    Finder(ADatabase, ATransaction, lst);
  finally
    lst.Free;
  end;
end;

procedure TFinder.FinderFiles(ADatabase: TpFIBDatabase;
  ATransaction: TpFIBTransaction; AFiles: TStrings);
var filename    : string;
    itemName    : string;
    versionHash : string;
    itemVersion : TItemVersion;
    auxItemName : string;
    finderItem  : TFinderItem;
    finderNode  : TFinderNode;
begin
  for filename in AFiles do
  begin
    itemVersion := TItemVersion.Create(nil);
    try
      itemName := TItem.GetCamelCaseName(ExtractFileName(filename));
      versionHash := LowerCase(HashFileSHA1(filename));

      // buscar item version
      if TItemVersionRelation.ReadItemHash(ADatabase, ATransaction,
            auxItemName, itemVersion, versionHash)
      then
      begin
        //Assert(itemName = auxItemName);

        // crear finder item
        finderItem := TFinderItem.Create(nil);
        FinderItems.Add(finderItem);
        finderItem.Filename := filename;
        finderItem.OwnerName := TItemRelation.GetRootOwnerFromName(ADatabase,
            ATransaction, itemName);

        finderNode := TFinderNode.Create(nil);
        finderNode.ItemName := itemName;
        finderNode.ItemType := TItemRelation.GetItemTypeFromName(ADatabase,
            ATransaction, itemName);
        finderNode.VersionOrder := itemVersion.Order;
        finderItem.Root := finderNode;
        finderItem.Leaves.Add(finderNode);
        LogFinder(finderItem.Leaves.ToString);

        FindOwners(ADatabase, ATransaction, finderNode, finderItem);
      end
    finally
      itemVersion.Free;
    end;
  end;
end;

class procedure TFinder.FindOwners(ADatabase: TpFIBDatabase;
  ATransaction: TpFIBTransaction; AFinderNode: TFinderNode;
  AFinderItem: TFinderItem);
var query       : TpFIBQuery;
    fCommit     : Boolean;
    itemName    : string;
    versionOrder: Integer;
    finderNode  : TFinderNode;
begin
  query := TpFIBQuery.Create(nil);
  try
    query.Database := ADatabase;
    query.Transaction := ATransaction;
    fCommit := not ATransaction.InTransaction;
    if fCommit then ATransaction.StartTransaction;
    try
      // read items owners
      query.SQL.Text :=
          'select owner_item_name, owner_version_order ' +
          'from item_link ' +
          'where ' +
          ' (child_item_name=:child_item_name) and ' +
          ' (child_version_order=:child_version_order) ' +
          'order by owner_item_name, owner_version_order';
      query.ParamByName('child_item_name').AsString := AFinderNode.ItemName;
      query.ParamByName('child_version_order').AsInteger :=
          AFinderNode.VersionOrder;
      query.ExecQuery;
      if not query.Eof then
      begin
        // extract node from leaves
        AFinderItem.Leaves.Extract(AFinderNode);

        while not query.Eof do
        begin
          // item owner
          itemName := query.FieldByName('owner_item_name').AsString;
          versionOrder := query.FieldByName('owner_version_order').AsInteger;
          query.Next;

          // find item in tree nodes
          finderNode := AFinderItem.Root.Find(itemName, versionOrder);

          // create new node
          if finderNode = nil then
          begin
            finderNode := TFinderNode.Create(AFinderNode);
            finderNode.ItemName := itemName;
            finderNode.ItemType := TItemRelation.GetItemTypeFromName(
                ADatabase, ATransaction, itemName);
            finderNode.VersionOrder := versionOrder;
            AFinderItem.Leaves.Add(finderNode);
            LogFinder(AFinderItem.Leaves.ToString);

            FindOwners(ADatabase, ATransaction, finderNode, AFinderItem);
          end;
        end;
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

class procedure TFinder.IntersectLeaves(AFinderItems: TFinderItemList;
  ALeaves: TFinderNodeList);
var finderItem: TFinderItem;
    first     : Boolean;
begin
  ALeaves.Clear;
  first := True;
  for finderItem in AFinderItems do
  begin
    if finderItem.Root <> nil then
    begin
      if first then
      begin
        ALeaves.CopyList(finderItem.Leaves);
        first := False;
      end
      else ALeaves.Intersect(finderItem.Leaves);
    end;
    LogFinder(Format('%s -> %s', [ExtractFileName(finderItem.Filename),
        finderItem.Leaves.ToString]));
  end;
  LogFinder(Format('%s INTER %s', ['Intersect', ALeaves.ToString]));
end;

class procedure TFinder.JoinLeaves(AFinderItems: TFinderItemList;
  ALeaves: TFinderNodeList);
var finderItem: TFinderItem;
begin
  ALeaves.Clear;
  for finderItem in AFinderItems do
    ALeaves.Union(finderItem.Leaves);
  LogFinder(Format('%s UNION %s', ['Intersect', ALeaves.ToString]));
end;

end.
