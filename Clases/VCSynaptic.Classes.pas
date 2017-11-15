unit VCSynaptic.Classes;

interface

uses
  SysUtils, Classes, IOUtils, Generics.Collections, StrUtils;

///  TItemType  ////////////////////////////////////////////////////////////////

type
  TItemType = (itFile, itPackage, itLibrary, itApp, itModule);
  TItemTypeSet = set of TItemType;

function ItemTypeToStr(Value: TItemType): string;
function StrToItemType(const S: string): TItemType;

////////////////////////////////////////////////////////////////////////////////

type
  TItem = class;

  TItemNameEvent = procedure (Sender: TObject; const ItemName: string) of object;

  TItemVersion = class(TComponent)
  private
    FOrder: Integer;
    FNumber: string;
    FDate: TDate;
    FHash: string;
    function GetItemVersionOwner: TItem;
  public
    constructor Create(AOwner: TItem); reintroduce; virtual;
    procedure Assign(Source: TPersistent); override;
    property Owner: TItem read GetItemVersionOwner;
    property Order: Integer read FOrder write FOrder;
    property Number: string read FNumber write FNumber;
    property Date: TDate read FDate write FDate;
    property Hash: string read FHash write FHash;
  end;

  TItemClass = class of TItem;

  TItem = class(TComponent)
  private
    FAlias: string;
    FRelativePath: string;
    FVersion: TItemVersion;
    FItemList: TList<TItem>;
    FRefList: TList<TItem>;
    function GetItemOwner: TItem;
    function GetAbsolutePath: string;
    function GetVersion: TItemVersion;
    function GetChildCount: Integer;
    function GetChildItem(Index: Integer): TItem;
    function GetReferenceCount: Integer;
    function GetReferences(Index: Integer): TItem;
  protected
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    class function Make(AOwner: TComponent): TItem; virtual; abstract;
    class function ItemType: TItemType; virtual; abstract;
    class function GetCamelCaseName(const AFilename: string): string;
    class function GetAliasFilename(const AFilename: string): string;
    procedure InsertChild(AChild: TItem);
    procedure RemoveChild(AChild: TItem);
    procedure InsertReference(AItem: TItem);
    procedure RemoveReference(AItem: TItem);
    function HasVersion: Boolean;
    procedure RemoveVersion;
    property Owner: TItem read GetItemOwner;
    property Name;
    property Alias: string read FAlias write FAlias;
    property RelativePath: string read FRelativePath write FRelativePath;
    property AbsolutePath: string read GetAbsolutePath;
    property Version: TItemVersion read GetVersion;
    property ChildCount: Integer read GetChildCount;
    property Children[Index: Integer]: TItem read GetChildItem;
    property ReferenceCount: Integer read GetReferenceCount;
    property References[Index: Integer]: TItem read GetReferences;
  end;

  TItemList = class(TObjectList<TItem>)
  public
    function FindItemVersion(const ItemName: string;
      VersionOrder: Integer): TItem; virtual;
  end;

  TFileItem = class(TItem)
  public
    class function Make(AOwner: TComponent): TItem; override;
    class function ItemType: TItemType; override;
  end;

  TPackageItem = class(TItem)
  public
    class function Make(AOwner: TComponent): TItem; override;
    class function ItemType: TItemType; override;
  end;

  TLibraryItem = class(TItem)
  public
    class function Make(AOwner: TComponent): TItem; override;
    class function ItemType: TItemType; override;
  end;

  TAppItem = class(TItem)
  public
    class function Make(AOwner: TComponent): TItem; override;
    class function ItemType: TItemType; override;
  end;

  TModuleItem = class(TItem)
  public
    class function Make(AOwner: TComponent): TItem; override;
    class function ItemType: TItemType; override;
  end;

  TItemFactory = class
  public
    class function ClassFromType(AItemType: TItemType): TItemClass;
    class function CreateItem(AOwner: TComponent;
      AItemType: TItemType): TItem;
  end;

implementation

////////////////////////////////////////////////////////////////////////////////

function ExtractCamelExt(const FileName: string): string;
const ExtPrefix = '.';
var prefix: string;
begin
  Result := ExtractFileExt(FileName);
  if Length(Result) <> 0 then
  begin
    // extract extension prefix
    if StartsText(ExtPrefix, Result) then
    begin
      prefix := Copy(Result, 1, Length(ExtPrefix));
      Delete(Result, 1, Length(ExtPrefix));
    end
    else prefix := '';

    // convert to camel case format
    if Length(Result) <> 0 then
      Result := UpperCase(Copy(Result, 1, 1)) +
                LowerCase(Copy(Result, 2, Length(Result)-1));
  end;
end;

///  TItemType  ////////////////////////////////////////////////////////////////

const
  ItemTypeValues: array[TItemType] of string =
      ('FILE', 'PACKAGE', 'LIBRARY', 'APP', 'MODULE');

function ItemTypeToStr(Value: TItemType): string;
begin
  Result := ItemTypeValues[Value];
end;

function StrToItemType(const S: string): TItemType;
begin
  for Result := Low(TItemType) to High(TItemType) do
    if SameText(S, ItemTypeToStr(Result)) then
      Exit;
  raise Exception.Create('Invalid TItemType value');
end;

////////////////////////////////////////////////////////////////////////////////

{ TItemVersion }

procedure TItemVersion.Assign(Source: TPersistent);
var src: TItemVersion;
begin
  if Source is TItemVersion then
  begin
    src := TItemVersion(Source);
    FOrder := src.FOrder;
    FNumber := src.FNumber;
    FDate := src.FDate;
    FHash := src.FHash;
  end;
end;

constructor TItemVersion.Create(AOwner: TItem);
begin
  inherited Create(AOwner);
end;

function TItemVersion.GetItemVersionOwner: TItem;
begin
  Result := TItem(Owner);
end;

{ TItem }

constructor TItem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItemList := TList<TItem>.Create;
  FRefList:= TList<TItem>.Create;
end;

destructor TItem.Destroy;
begin
  inherited;
  FreeAndNil(FRefList);
  FreeAndNil(FItemList);
end;

function TItem.GetAbsolutePath: string;
begin
  Result := RelativePath;
  if not TPath.IsDriveRooted(Result) and Assigned(Owner) then
    Result := IncludeTrailingPathDelimiter(Owner.AbsolutePath) + Result;
end;

class function TItem.GetAliasFilename(const AFilename: string): string;
begin
  Result := ExtractFileName(AFilename);
end;

class function TItem.GetCamelCaseName(const AFilename: string): string;
begin
  Result := ChangeFileExt(AFilename, '') + ExtractCamelExt(AFilename);
end;

function TItem.GetChildCount: Integer;
begin
  Result := FItemList.Count;
end;

function TItem.GetChildItem(Index: Integer): TItem;
begin
  Result := TItem(FItemList[Index]);
end;

function TItem.GetItemOwner: TItem;
begin
  Result := TItem(inherited Owner);
end;

function TItem.GetReferenceCount: Integer;
begin
  Result := FRefList.Count;
end;

function TItem.GetReferences(Index: Integer): TItem;
begin
  Result := FRefList[Index];
end;

function TItem.GetVersion: TItemVersion;
begin
  if FVersion = nil then
    FVersion := TItemVersion.Create(Self);
  Result := FVersion;
end;

function TItem.HasVersion: Boolean;
begin
  Result := FVersion <> nil;
end;

procedure TItem.InsertChild(AChild: TItem);
begin
  FItemList.Add(AChild);
end;

procedure TItem.InsertReference(AItem: TItem);
begin
  FRefList.Add(AItem);
end;

procedure TItem.RemoveChild(AChild: TItem);
begin
  FItemList.Remove(AChild);
end;

procedure TItem.RemoveReference(AItem: TItem);
begin
  FRefList.Remove(AItem);
end;

procedure TItem.RemoveVersion;
begin
  if FVersion <> nil then
    FreeAndNil(FVersion);
end;

{ TItemList }

function TItemList.FindItemVersion(const ItemName: string;
  VersionOrder: Integer): TItem;
begin
  for Result in Self do
    if SameStr(Result.Name, ItemName) and
       (Result.Version <> nil) and (Result.Version.Order = VersionOrder)
    then Exit;
  Result := nil;
end;

{ TFileItem }

class function TFileItem.ItemType: TItemType;
begin
  Result := itFile;
end;

class function TFileItem.Make(AOwner: TComponent): TItem;
begin
  Result := TFileItem.Create(AOwner);
end;

{ TPackageItem }

class function TPackageItem.ItemType: TItemType;
begin
  Result := itPackage;
end;

class function TPackageItem.Make(AOwner: TComponent): TItem;
begin
  Result := TPackageItem.Create(AOwner);
end;

{ TLibraryItem }

class function TLibraryItem.ItemType: TItemType;
begin
  Result := itLibrary;
end;

class function TLibraryItem.Make(AOwner: TComponent): TItem;
begin
  Result := TLibraryItem.Create(AOwner);
end;

{ TAppItem }

class function TAppItem.ItemType: TItemType;
begin
  Result := itApp;
end;

class function TAppItem.Make(AOwner: TComponent): TItem;
begin
  Result := TAppItem.Create(AOwner);
end;

{ TModuleItem }

class function TModuleItem.ItemType: TItemType;
begin
  Result := itModule;
end;

class function TModuleItem.Make(AOwner: TComponent): TItem;
begin
  Result := TModuleItem.Create(AOwner);
end;

{ TItemFactory }

class function TItemFactory.ClassFromType(AItemType: TItemType): TItemClass;
begin
  if TFileItem.ItemType = AItemType then Result := TFileItem
  else if TPackageItem.ItemType = AItemType then Result := TPackageItem
  else if TLibraryItem.ItemType = AItemType then Result := TLibraryItem
  else if TAppItem.ItemType = AItemType then Result := TAppItem
  else if TModuleItem.ItemType = AItemType then Result := TModuleItem
  else raise Exception.Create('Doesn''t exist TItemClass for TItemType');
end;

class function TItemFactory.CreateItem(AOwner: TComponent;
  AItemType: TItemType): TItem;
var itemClass: TItemClass;
begin
  itemClass := ClassFromType(AItemType);
  Result := itemClass.Make(AOwner);
end;

end.
