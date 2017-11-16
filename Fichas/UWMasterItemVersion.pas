unit UWMasterItemVersion;

interface

uses
  UDropFileControl,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UWMaster, ImgList, ActnList, Grids, DBGrids, ComCtrls, ToolWin,
  ExtCtrls, DB;

type
  TWMasterItemVersion = class(TWMaster)
    PanelDropFile: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    FDropFileHash: TDropFileControl;
    procedure HandleDropFileHash(Sender: TObject; const Filename: string);
  public
  end;

var
  WMasterItemVersion: TWMasterItemVersion;

implementation

uses
  UHash;

{$R *.dfm}

procedure TWMasterItemVersion.FormCreate(Sender: TObject);
begin
  inherited;
  FDropFileHash := TDropFileControl.Create(Self);
  FDropFileHash.Parent := PanelDropFile;
  FDropFileHash.Align := alClient;
  FDropFileHash.OnDropFile := HandleDropFileHash;
end;

procedure TWMasterItemVersion.HandleDropFileHash(Sender: TObject;
  const Filename: string);
begin
  if not DataSet.Locate('version_hash', LowerCase(HashFileSHA1(Filename)),
      [loCaseInsensitive])
  then ShowMessage('Hash not found');
end;

end.
