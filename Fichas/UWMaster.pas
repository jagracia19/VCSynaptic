unit UWMaster;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, DBCtrls, Grids, DBGrids, ComCtrls, ToolWin, IniFiles, DB,
  ActnList, ImgList;

type
  TDBGridExtOption = (dgeCheckBoolField, dgeDrawSelected);
  TDBGridExtOptions = set of TDBGridExtOption;

  TWMaster = class(TForm)
    ToolBar: TToolBar;
    DBGrid: TDBGrid;
    ToolButtonOk: TToolButton;
    ToolButtonCancel: TToolButton;
    ToolButtonRefresh: TToolButton;
    ActionList1: TActionList;
    ActionRefresh: TAction;
    ActionAccept: TAction;
    ActionCancel: TAction;
    ImageListToolbar: TImageList;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure DBGridCellClick(Column: TColumn);
    procedure DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure DBGridKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DBGridColEnter(Sender: TObject);
    procedure DBGridColExit(Sender: TObject);
    procedure ActionRefreshExecute(Sender: TObject);
    procedure ActionAcceptExecute(Sender: TObject);
    procedure ActionCancelExecute(Sender: TObject);
  private
    FDataSet: TDataSet;
    FDataSource: TDataSource;
    FVCLConfigEnabled: Boolean;
    FGridOriginalOptions: TDBGridOptions;
    FGridExtOptions: TDBGridExtOptions;
    procedure LoadVCL;
    procedure SaveVCL;
    procedure SetVCLConfigEnabled(const Value: Boolean);
    procedure SetGridExtOptions(const Value: TDBGridExtOptions);
  protected
    procedure LoadVCLConfig(AIniFile: TIniFile); virtual;
    procedure SaveVCLConfig(AIniFile: TIniFile); virtual;
    function ColumnByFieldName(const AFieldName: string): TColumn;
    function IsBoolField(AField: TField): Boolean; virtual;
    procedure ToggleBoolField(Field: TField);
    procedure BackupGridOptions;
    procedure RestoreGridOptions;
    procedure SetDataSet(const Value: TDataSet); virtual;
    function GetDataSet: TDataSet; virtual;
    procedure SetDataSource(const Value: TDataSource); virtual;
    property VCLConfigEnabled: Boolean read FVCLConfigEnabled
      write SetVCLConfigEnabled;
    property GridExtOptions: TDBGridExtOptions read FGridExtOptions
      write SetGridExtOptions;
  public
    procedure UpdateLanguage; virtual;
    property DataSet: TDataSet read GetDataSet write SetDataSet;
    property DataSource: TDataSource read FDataSource write SetDataSource;
  end;

var
  WMaster: TWMaster;

implementation

uses
  Language.Interf,
  VCLUtils.Interf;

{$R *.dfm}

{ TWMaster }

procedure TWMaster.ActionAcceptExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TWMaster.ActionCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TWMaster.ActionRefreshExecute(Sender: TObject);
begin
  DataSet.Refresh;
end;

procedure TWMaster.BackupGridOptions;
begin
  FGridOriginalOptions := DBGrid.Options;
end;

function TWMaster.ColumnByFieldName(const AFieldName: string): TColumn;
var I: Integer;
begin
  for I := 0 to DBGrid.Columns.Count-1 do
  begin
    Result := DBGrid.Columns[I];
    if SameText(Result.FieldName, AFieldName) then
      Exit;
  end;
  Result := nil;
end;

procedure TWMaster.DBGridCellClick(Column: TColumn);
begin
  if (dgeCheckBoolField in GridExtOptions) and IsBoolField(Column.Field) then
    ToggleBoolField(Column.Field);
end;

procedure TWMaster.DBGridColEnter(Sender: TObject);
begin
  if (dgeCheckBoolField in GridExtOptions) and IsBoolField(DBGrid.SelectedField)
  then
  begin
    BackupGridOptions;
    DBGrid.Options := DBGrid.Options - [dgEditing];
  end;
end;

procedure TWMaster.DBGridColExit(Sender: TObject);
begin
  if (dgeCheckBoolField in GridExtOptions) and IsBoolField(DBGrid.SelectedField)
  then RestoreGridOptions;
end;

procedure TWMaster.DBGridDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);

  procedure DrawCheckBox(ACanvas: TCanvas; ARect: TRect; AField: TField);
  const
     CtrlState: array[Boolean] of Integer =
        (DFCS_BUTTONCHECK, DFCS_BUTTONCHECK or DFCS_CHECKED);
  begin
    ACanvas.FillRect(Rect);
    if VarIsNull(AField.Value) then
      DrawFrameControl(ACanvas.Handle, ARect,
          DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_INACTIVE) // grayed
    else DrawFrameControl(ACanvas.Handle, ARect,
        DFC_BUTTON, CtrlState[AField.AsBoolean]); // checked or unchecked
  end;

  procedure DrawSelected(ACanvas: TCanvas; ARect: TRect; AState: TGridDrawState);
  begin
    if (dgeDrawSelected in GridExtOptions) and (gdSelected in AState) then
    begin
      InflateRect(ARect, -1, -1);
      ACanvas.Pen.Color := clGray;
      ACanvas.Pen.Style := psDot;
      ACanvas.Brush.Style := bsClear;
      ACanvas.Rectangle(Rect);
      ACanvas.Brush.Style := bsSolid;
      ACanvas.Pen.Style := psSolid;
    end;
  end;

begin
  if (dgeCheckBoolField in GridExtOptions) and IsBoolField(Column.Field) then
    DrawCheckBox(DBGrid.Canvas, Rect, Column.Field)
  else DBGrid.DefaultDrawColumnCell(Rect, DataCol, column, State);
  DrawSelected(DBGrid.Canvas, Rect, State);
end;

procedure TWMaster.DBGridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = VK_SPACE then
  begin
    if (dgeCheckBoolField in GridExtOptions) and IsBoolField(DBGrid.SelectedField)
    then ToggleBoolField(DBGrid.SelectedField)
  end
  else if key = VK_RETURN then
    ModalResult := mrOk
  else if key = VK_ESCAPE then
    ModalResult := mrCancel;
end;

procedure TWMaster.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveVCL;
end;

procedure TWMaster.FormCreate(Sender: TObject);
begin
  FVCLConfigEnabled := True;
  GridExtOptions := [dgeCheckBoolField, dgeDrawSelected];
end;

procedure TWMaster.FormShow(Sender: TObject);
begin
  LoadVCL;
end;

function TWMaster.GetDataSet: TDataSet;
begin
  Result := FDataSet;
end;

function TWMaster.IsBoolField(AField: TField): Boolean;
begin
  Result := AField.DataType = ftBoolean;
end;

procedure TWMaster.LoadVCL;
var F: TIniFile;
begin
  if FVCLConfigEnabled then
  begin
    F := TIniFile.Create(VCLUtils.Interf.GetFileCfgVCL);
    try
      LoadVCLConfig(F);
    finally
      F.Free;
    end;
  end;
end;

procedure TWMaster.LoadVCLConfig(AIniFile: TIniFile);
var section: string;
    form   : TFormPosition;
begin
  // Form
  section := Self.Name;
  if AIniFile.SectionExists(section) then
  begin
    form := TFormPosition.Create;
    try
      form.LoadFromFile(AIniFile, section);
      form.SaveToForm(Self);
    finally
      form.Free;
    end;
  end;

  // DBGrid
  section := Self.Name + '_' + DBGrid.Name;
  TDBGridCfg.LoadFromFile(AIniFile, section, DBGrid);
end;

procedure TWMaster.RestoreGridOptions;
begin
  DBGrid.Options := FGridOriginalOptions;
end;

procedure TWMaster.SaveVCL;
var F: TIniFile;
begin
  if FVCLConfigEnabled then
  begin
    F := TIniFile.Create(VCLUtils.Interf.GetFileCfgVCL);
    try
      SaveVCLConfig(F);
    finally
      F.Free;
    end;
  end;
end;

procedure TWMaster.SaveVCLConfig(AIniFile: TIniFile);
var form: TFormPosition;
begin
  form := TFormPosition.Create;
  try
    form.LoadFromForm(Self);
    form.SaveToFile(AIniFile, Self.Name);
  finally
    form.Free;
  end;
  TDBGridCfg.SaveToFile(AIniFile, Self.Name + '_' + DBGrid.Name, DBGrid);
  //TFontCfg.SaveToFile(Self, SecGridFont, FGridFont);
end;

procedure TWMaster.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
end;

procedure TWMaster.SetDataSource(const Value: TDataSource);
begin
  FDataSource := Value;
  DBGrid.DataSource := FDataSource;
end;

procedure TWMaster.SetGridExtOptions(const Value: TDBGridExtOptions);
begin
  FGridExtOptions := Value;
end;

procedure TWMaster.SetVCLConfigEnabled(const Value: Boolean);
begin
  FVCLConfigEnabled := Value;
end;

procedure TWMaster.ToggleBoolField(Field: TField);
var fSave: Boolean;
begin
  fSave := not (DBGrid.DataSource.DataSet.State in dsEditModes);
  try
    if fSave then DBGrid.DataSource.DataSet.Edit;
    Field.AsBoolean := not Field.AsBoolean;
  finally
    if fSave then
      try
        DBGrid.DataSource.DataSet.Post;
      except
        DBGrid.DataSource.DataSet.Cancel;
        raise;
      end;
  end;
end;

procedure TWMaster.UpdateLanguage;
begin
  Caption := Cpt('Master');
end;

end.
