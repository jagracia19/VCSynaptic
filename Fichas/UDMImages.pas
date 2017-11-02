unit UDMImages;

interface

uses
  VCSynaptic.Classes,
  SysUtils, Classes, ImgList, Controls;

const
  ImgItemTypeFile     = 0;
  ImgItemTypePackage  = 1;
  ImgItemTypeLibrary  = 2;
  ImgItemTypeApp      = 3;
  ImgItemTypeModule   = 4;

type
  TDMImages = class(TDataModule)
    ImageListToolbar: TImageList;
    ImageListItemType: TImageList;
  private
  public
  end;

var
  DMImages: TDMImages;

function GetItemTypeImageIndex(Value: TItemType): Integer;

implementation

{$R *.dfm}

function GetItemTypeImageIndex(Value: TItemType): Integer;
begin
  case Value of
    itFile: Result := ImgItemTypeFile;
    itPackage: Result := ImgItemTypePackage;
    itLibrary: Result := ImgItemTypeLibrary;
    itApp: Result := ImgItemTypeApp;
    itModule: Result := ImgItemTypeModule;
  else raise Exception.Create('Unknow item type image index');
  end;
end;

end.
