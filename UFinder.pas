unit UFinder;

interface

uses
  VCSynaptic.Classes,
  SysUtils, Classes, Generics.Collections;

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
    property ItemName: string read FItemName write FItemName;
    property ItemType: TItemType read FItemType write FItemType;
    property VersionOrder: Integer read FVersionOrder write FVersionOrder;
    property Count: Integer read GetCount;
    property Children[index: Integer]: TFinderNode read GetChildrenNode;
  end;

  TFinderNodeList = class(TObjectList<TFinderNode>)
  end;

  TFinderItem = class(TComponent)
  private
    FFilename: string;
    FRoot: TFinderNode;
    FLeaves: TFinderNodeList;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Filename: string read FFilename write FFilename;
    property Root: TFinderNode read FRoot write FRoot;
    property Leaves: TFinderNodeList read FLeaves;
  end;

  TFinderItemList = class(TObjectList<TFinderItem>)
  public
    function FindFilename(const AFilename: string): TFinderItem;
  end;

implementation

{ TFinderNode }

constructor TFinderNode.Create(AOwner: TFinderNode);
begin
  inherited Create(AOwner);
end;

function TFinderNode.GetChildrenNode(Index: Integer): TFinderNode;
begin
  Result := TFinderNode(Components[Index]);
end;

function TFinderNode.GetCount: Integer;
begin
  Result := ComponentCount;
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

end.
