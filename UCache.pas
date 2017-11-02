unit UCache;

interface

uses
  VCSynaptic.Classes,
  SysUtils;

type
  TItemCache = class(TItemList)
  public
    //function FindItemVersion(const ItemName: string;
    //  VersionOrder: Integer): TItem; override;
  end;

var
  ItemCache: TItemCache;

implementation

procedure InitCache;
begin
  ItemCache := TItemCache.Create(True);
end;

procedure FreeCache;
begin
  FreeAndNil(ItemCache);
end;

initialization
  InitCache;

finalization
  FreeCache;

end.
