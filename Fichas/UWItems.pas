unit UWItems;

interface

uses
  VCSynaptic.Classes,
  UDMItems,
  pFIBDataSet,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ActnList, Grids, DBGrids, ComCtrls, ToolWin, IniFiles, Menus,
  ShellAPI, ExtCtrls, StrUtils;

type
  TFileNameEvent = procedure (Sender: TObject; const Filename: string) of object;

  TDropFileControl = class(TPanel)
  private
    FOnDropFile: TFileNameEvent;
  protected
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure DoDropFile(const Filename: string);
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    property OnDropFile: TFileNameEvent read FOnDropFile write FOnDropFile;
  end;

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
    Panel1: TPanel;
    PanelDropFile: TPanel;
    procedure FormCreate(Sender: TObject);
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
    FDropFileControl: TDropFileControl;
    procedure HandleDropFile(Sender: TObject; const Filename: string);
    function AddItem: Boolean;
    function AddItemVersion(const ItemName: string = '';
      const Filename: string = ''): Boolean;
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
  VCSynaptic.Database,
  UDMImages,
  UWItem,
  UDMItemVersion,
  UWItemVersion;

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
  AddItem;
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
    //DoEditVersion(DataSet.FieldByName('name').AsString);
    AddItemVersion(DataSet.FieldByName('name').AsString, '');
end;

function TWItems.AddItem: Boolean;
begin
  Result := False;
  Application.CreateForm(TWItem, WItem);
  try
    WItem.DataSet := DataSet;
    DataSet.Insert;
    if WItem.ShowModal = mrOk then
      try
        DataSet.Post;
        DataSet.UpdateTransaction.CommitRetaining;
        Result := True;
      except
        DataSet.Cancel;
        raise;
      end
    else DataSet.Cancel;
  finally
    FreeAndNil(WItem);
  end;
end;

function TWItems.AddItemVersion(const ItemName, Filename: string): Boolean;
var data: TDMItemVersion;
    form: TWItemVersion;

begin
  Result := False;
  data := TDMItemVersion.Create(nil);
  try
    data.Database := DataModule.Database;
    //data.SelectWhere := '(item_name=''' + ItemName + ''')';
    data.Connect;
    try
      form := TWItemVersion.Create(nil);
      try
        form.Database := data.Database;
        form.Transaction := data.Transaction;
        form.DataSet := data.DataSet;
        form.DataSource := data.DataSource;
        data.TransactionUpdate.StartTransaction;
        try
          data.DataSet.Insert;
          if Length(ItemName) <> 0 then
            form.InitFromItemName(ItemName)
          else if Length(Filename) <> 0 then
            form.DropFileName(Filename);
          if form.ShowModal = mrOk then
          begin
            data.DataSet.Post;
          end
          else data.DataSet.Cancel;
        finally
          data.TransactionUpdate.Commit;
        end;
      finally
        form.Free;
      end;
    finally
      data.Disconnect;
    end;
  finally
    data.Free;
  end;
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

procedure TWItems.FormCreate(Sender: TObject);
begin
  FDropFileControl := TDropFileControl.Create(Self);
  FDropFileControl.Parent := PanelDropFile;
  FDropFileControl.Align := alClient;
  FDropFileControl.OnDropFile := HandleDropFile;
end;

procedure TWItems.FormShow(Sender: TObject);
begin
  LoadConfig;
end;

procedure TWItems.HandleDropFile(Sender: TObject; const Filename: string);
var itemAlias : string;
    itemName  : string;
    item : TItem;
begin
  itemAlias := TItem.GetAliasFilename(Filename);
  itemName := TItemRelation.GetNameFromAlias(DataModule.Database,
      DataModule.Transaction, itemAlias);
  if Length(itemName) = 0 then
    raise Exception.Create(Format('Alias item %s not found', [itemAlias]));
  try
    item := TItemRelation.ReadItemName(DataModule.Database, DataModule.Transaction,
      nil, itemName);
    if item is TFileItem then
      AddItemVersion('', Filename);
  finally
    item.Free;
  end;
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

{ TDropFileControl }

constructor TDropFileControl.Create(AOwner: TComponent);
begin
  inherited;
  Caption := 'Drop file';
  Font.Style := Font.Style + [fsBold];
  Font.Color := clSilver;
  Font.Size := 12;
end;

procedure TDropFileControl.CreateWnd;
begin
  inherited;
  DragAcceptFiles(Handle, True);
end;

procedure TDropFileControl.DestroyWnd;
begin
  DragAcceptFiles(Handle, False);
  inherited;
end;

procedure TDropFileControl.DoDropFile(const Filename: string);
begin
  if Assigned(FOnDropFile) then FOnDropFile(Self, Filename);
end;

procedure TDropFileControl.WMDropFiles(var Msg: TWMDropFiles);
var hDrop     : THandle;
    fileCount : Integer;
    nameLen   : Integer;
    I         : Integer;
    st        : string;
begin
  hDrop := Msg.Drop;
  fileCount:= DragQueryFile (hDrop , $FFFFFFFF, nil, 0);
  for I := 0 to fileCount-1 do
  begin
    nameLen:= DragQueryFile(hDrop, I, nil, 0) + 1;
    SetLength(st, nameLen);
    DragQueryFile(hDrop, I, Pointer(st), NameLen);
    while EndsStr(#0, st) do
      Delete(st, Length(st), 1);
    DoDropFile(st);
  end;
  DragFinish(hDrop);
end;

end.
