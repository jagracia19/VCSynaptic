unit UWItems;

interface

uses
  VCSynaptic.Classes,
  UDMItems,
  pFIBDataSet,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Grids, DBGrids, ComCtrls, ToolWin, IniFiles, Menus;

type
  TWItems = class(TForm)
    ToolBar1: TToolBar;
    ToolButtonRefresh: TToolButton;
    ToolButtonFilterModule: TToolButton;
    ToolButtonClose: TToolButton;
    DBGrid: TDBGrid;
    ActionList: TActionList;
    ActionRefresh: TAction;
    ActionClose: TAction;
    ActionFilterModule: TAction;
    ToolButtonFilterApp: TToolButton;
    ToolButtonFilterLibrary: TToolButton;
    ToolButtonFilterPackage: TToolButton;
    ToolButtonFilterFile: TToolButton;
    ActionFilterApp: TAction;
    ActionFilterLibrary: TAction;
    ActionFilterPackage: TAction;
    ActionFilterFiles: TAction;
    PopupMenuGrid: TPopupMenu;
    MICompose: TMenuItem;
    ActionCompose: TAction;
    ActionVersions: TAction;
    MIVersions: TMenuItem;
    ToolButtonAdd: TToolButton;
    ActionAdd: TAction;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure ActionRefreshExecute(Sender: TObject);
    procedure ActionCloseExecute(Sender: TObject);
    procedure ActionFilterModuleExecute(Sender: TObject);
    procedure ActionFilterAppExecute(Sender: TObject);
    procedure ActionFilterLibraryExecute(Sender: TObject);
    procedure ActionFilterPackageExecute(Sender: TObject);
    procedure ActionFilterFilesExecute(Sender: TObject);
    procedure ActionComposeExecute(Sender: TObject);
    procedure ActionVersionsExecute(Sender: TObject);
    procedure ActionAddExecute(Sender: TObject);
  private
    FDataSet: TpFIBDataSet;
    FDataModule: TDMItems;
    FOnCompose: TItemNameEvent;
    FOnEditVersion: TItemNameEvent;
    procedure DoCompose(const ItemName: string); virtual;
    procedure DoEditVersion(const ItemName: string); virtual;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure FilterItemType(bSiNo: Boolean; ItemType: TItemType);
    procedure SetDataSet(const Value: TpFIBDataSet);
    procedure SetDataModule(const Value: TDMItems);
  public
    procedure UpdateLanguage;
    property DataModule: TDMItems read FDataModule write SetDataModule;
    property DataSet: TpFIBDataSet read FDataSet write SetDataSet;
    property OnCompose: TItemNameEvent read FOnCompose write FOnCompose;
    property OnEditVersion: TItemNameEvent read FOnEditVersion write FOnEditVersion;
  end;

var
  WItems: TWItems;

implementation

uses
  VCLUtils.Interf,
  UDMImages,
  UWItem;

{$R *.dfm}

procedure LoadVCLConfig(AForm: TForm; AGrid: TDBGrid);
var F       : TIniFile;
    section : string;
    form    : TFormPosition;
begin
  F := TIniFile.Create(VCLUtils.Interf.GetFileCfgVCL);
  try
    section := AForm.Name;
    if F.SectionExists(section) then
    begin
      form := TFormPosition.Create;
      try
        form.LoadFromFile(F, section);
        form.SaveToForm(AForm);
      finally
        form.Free;
      end;
    end;

    section := AForm.Name + '_' + AGrid.Name;
    TDBGridCfg.LoadFromFile(F, section, AGrid);
  finally
    F.Free;
  end;
end;

procedure SaveVCLConfig(AForm: TForm; AGrid: TDBGrid);
var F       : TIniFile;
    form    : TFormPosition;
    section : string;
begin
  F := TIniFile.Create(VCLUtils.Interf.GetFileCfgVCL);
  try
    form := TFormPosition.Create;
    try
      form.LoadFromForm(AForm);
      form.SaveToFile(F, AForm.Name);
    finally
      form.Free;
    end;

    section := AForm.Name + '_' + AGrid.Name;
    TDBGridCfg.SaveToFile(F, section, AGrid);
    //TFontCfg.SaveToFile(Self, SecGridFont, FGridFont);
  finally
    F.Free;
  end;
end;

{ TWItems }

procedure TWItems.ActionAddExecute(Sender: TObject);
begin
  Application.CreateForm(TWItem, WItem);
  try
    WItem.DataSet := DataSet;
    DataSet.Insert;
    if WItem.ShowModal = mrOk then
      try
        DataSet.Post;
        DataSet.UpdateTransaction.CommitRetaining;
      except
        DataSet.Cancel;
        raise;
      end
    else DataSet.Cancel;
  finally
    FreeAndNil(WItem);
  end;
end;

procedure TWItems.ActionCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TWItems.ActionComposeExecute(Sender: TObject);
begin
  if DataSet.Active then
    DoCompose(DataSet.FieldByName('name').AsString);
end;

procedure TWItems.ActionFilterAppExecute(Sender: TObject);
begin
  FilterItemType(ToolButtonFilterApp.Down, itApp);
end;

procedure TWItems.ActionFilterFilesExecute(Sender: TObject);
begin
  FilterItemType(ToolButtonFilterFile.Down, itFile);
end;

procedure TWItems.ActionFilterLibraryExecute(Sender: TObject);
begin
  FilterItemType(ToolButtonFilterLibrary.Down, itLibrary);
end;

procedure TWItems.ActionFilterModuleExecute(Sender: TObject);
begin
  FilterItemType(ToolButtonFilterModule.Down, itModule);
end;

procedure TWItems.ActionFilterPackageExecute(Sender: TObject);
begin
  FilterItemType(ToolButtonFilterPackage.Down, itPackage);
end;

procedure TWItems.ActionRefreshExecute(Sender: TObject);
var fActive: Boolean;
begin
  fActive := DataSet.Active;
  try
    DataSet.Active := False;
    DataModule.RefreshDataSet;
  finally
    DataSet.Active := fActive;
  end;
end;

procedure TWItems.ActionVersionsExecute(Sender: TObject);
begin
  if DataSet.Active then
    DoEditVersion(DataSet.FieldByName('name').AsString);
end;

procedure TWItems.DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  DBGrid.DefaultDrawColumnCell(Rect, DataCol, column, State);
end;

procedure TWItems.DoCompose(const ItemName: string);
begin
  if Assigned(FOnCompose) then FOnCompose(Self, ItemName);
end;

procedure TWItems.DoEditVersion(const ItemName: string);
begin
  if Assigned(FOnEditVersion) then FOnEditVersion(Self, ItemName);
end;

procedure TWItems.FilterItemType(bSiNo: Boolean; ItemType: TItemType);
begin
  if bSiNo then
    DataModule.ItemTypes := DataModule.ItemTypes + [ItemType]
  else DataModule.ItemTypes := DataModule.ItemTypes - [ItemType];
  ActionRefreshExecute(nil);
end;

procedure TWItems.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveConfig;
  Action := caFree;
end;

procedure TWItems.FormShow(Sender: TObject);
begin
  LoadConfig;
end;

procedure TWItems.LoadConfig;
begin
  LoadVCLConfig(Self, DBGrid);
end;

procedure TWItems.SaveConfig;
begin
  SaveVCLConfig(Self, DBGrid);
end;

procedure TWItems.SetDataModule(const Value: TDMItems);
begin
  FDataModule := Value;
  DataSet := FDataModule.DataSet;
  DBGrid.DataSource := FDataModule.DataSource;
end;

procedure TWItems.SetDataSet(const Value: TpFIBDataSet);
begin
  FDataSet := Value;
end;

procedure TWItems.UpdateLanguage;
begin
end;

end.
