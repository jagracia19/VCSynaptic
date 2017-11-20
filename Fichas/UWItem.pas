unit UWItem;

interface

uses
  VCSynaptic.Classes,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UWMasterEdit, StdCtrls, ExtCtrls, DB, DBClient, DBCtrls, Mask,
  ShellAPI, StrUtils;

type
  TWItem = class(TWMasterEdit)
    LabelName: TLabel;
    LabelAlias: TLabel;
    LabelType: TLabel;
    LabelPath: TLabel;
    EditName: TDBEdit;
    EditAlias: TDBEdit;
    EditPath: TDBEdit;
    DataSource: TDataSource;
    ComboBoxType: TDBComboBox;
    LabelOwner: TLabel;
    EditOwner: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FDataSet: TDataSet;
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
    procedure DropFileName(const AFilename: string);
    procedure InitComboBoxType;
    function IndexOfComboBoxType(AItemType: TItemType): Integer;
    procedure SetDataSet(const Value: TDataSet);
  public
    procedure UpdateLanguage; override;
    procedure SelectComboBoxType(AItemType: TItemType);
    property DataSet: TDataSet read FDataSet write SetDataSet;
  end;

var
  WItem: TWItem;

implementation

uses
  Language.Interf;

{$R *.dfm}

{ TWItem }

procedure TWItem.DropFileName(const AFilename: string);
var auxFilename: string;
begin
  auxFilename := ExtractFileName(AFileName);
  DataSet.FieldByName('NAME').AsString :=
      TItem.GetCamelCaseName(auxFilename);
  DataSet.FieldByName('ALIAS').AsString := auxFilename;
  SelectComboBoxType(itFile);
  DataSet.FieldByName('PATH').AsString := AFileName;
  DataSet.FieldByName('OWNER').Clear;
end;

procedure TWItem.FormCreate(Sender: TObject);
begin
  inherited;
  DragAcceptFiles(Handle, True);
  InitComboBoxType;
end;

procedure TWItem.FormDestroy(Sender: TObject);
begin
  inherited;
  DragAcceptFiles(Handle, False);
end;

function TWItem.IndexOfComboBoxType(AItemType: TItemType): Integer;
begin
  for Result := 0 to ComboBoxType.Items.Count-1 do
    if TItemType(ComboBoxType.Items.Objects[Result]) = AItemType then
      Exit;
  Result := -1;
end;

procedure TWItem.InitComboBoxType;
var itemType: TItemType;
begin
  ComboBoxType.Clear;
  for itemType := Low(TItemType) to High(TItemType) do
    ComboBoxType.Items.AddObject(ItemTypeToStr(itemType), TObject(itemType));
end;

procedure TWItem.SelectComboBoxType(AItemType: TItemType);
begin
  ComboBoxType.ItemIndex := IndexOfComboBoxType(AItemType);
end;

procedure TWItem.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
  DataSource.DataSet := FDataSet;
end;

procedure TWItem.UpdateLanguage;
begin
  inherited;
  Caption := Cpt('Item');
end;

procedure TWItem.WMDropFiles(var Msg: TMessage);
var hDrop     : THandle;
    fileCount : Integer;
    nameLen   : Integer;
    index     : Integer;
    st        : string;
begin
  hDrop:= Msg.wParam;
  fileCount:= DragQueryFile(hDrop, $FFFFFFFF, nil, 0);
  if fileCount > 0 then
  begin
    index := 0;
    nameLen := DragQueryFile(hDrop, index, nil, 0) + 1;
    SetLength(st, nameLen);
    DragQueryFile(hDrop, index, Pointer(st), nameLen);
    DropFilename(st);
  end;
  DragFinish(hDrop);
end;

end.
