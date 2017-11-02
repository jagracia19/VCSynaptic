unit UWPrincipal;

interface

uses
  UDMItems,
  UWItems,
  UDMCompose,
  UWCompose,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, IniFiles;

type
  TWPrincipal = class(TForm)
    PanelDock: TPanel;
    PageControlDock: TPageControl;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FDMItems: TDMItems;
    FFormItems: TWItems;
    FDMCompose: TDMCompose;
    FFormCompose: TWCompose;
    procedure ShowItems;
    procedure HideItems;
    procedure HandleCompose(Sender: TObject; const ItemName: string);
    procedure HandleEditVersion(Sender: TObject; const ItemName: string);
    procedure ShowCompose(const AItemName: string; AVersionOrder: Integer);
    procedure HideCompose;
    function FindTabSheet(const ACaption: string): Integer;
    function GetDMItems: TDMItems;
    function GetFormItems: TWItems;
    function GetDMCompose: TDMCompose;
    function GetFormCompose: TWCompose;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    property DMItems: TDMItems read GetDMItems;
    property FormItems: TWItems read GetFormItems;
    property DMCompose: TDMCompose read GetDMCompose;
    property FormCompose: TWCompose read GetFormCompose;
  public
  end;

var
  WPrincipal: TWPrincipal;

implementation

uses
  VCLUtils.Interf,
  VCSynaptic.Classes,
  VCSynaptic.Database,
  UCache,
  UDMPrincipal,
  UDMItemVersion,
  UWMaster;

{$R *.dfm}

////////////////////////////////////////////////////////////////////////////////

procedure LoadVCLConfig(AForm: TForm);
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
  finally
    F.Free;
  end;
end;

procedure SaveVCLConfig(AForm: TForm);
var F   : TIniFile;
    form: TFormPosition;
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
  finally
    F.Free;
  end;
end;

////////////////////////////////////////////////////////////////////////////////

function SelectItemVersion(const ItemName: string): Integer;
var data: TDMItemVersion;
    form: TWMaster;
begin
  Application.CreateForm(TDMItemVersion, data);
  try
    data.Database := DMPrincipal.Database;
    data.SelectWhere := '(item_name=''' + ItemName + ''')';
    data.Connect;
    try
      Application.CreateForm(TWMaster, form);
      try
        form.DataSet := data.DataSet;
        form.DataSource := data.DataSource;
        if form.ShowModal = mrOk then
          Result := data.DataSet.FieldByName('version_order').AsInteger
        else Result := 0;
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

////////////////////////////////////////////////////////////////////////////////

{ TWPrincipal }

function TWPrincipal.FindTabSheet(const ACaption: string): Integer;
begin
  for Result := 0 to PageControlDock.PageCount-1 do
    if SameText(PageControlDock.Pages[Result].Caption, ACaption) then
      Exit;
  Result := -1;
end;

procedure TWPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveVCLConfig(Self);
  HideItems;
  HideCompose;
end;

procedure TWPrincipal.FormShow(Sender: TObject);
begin
  LoadVCLConfig(Self);
  ShowItems;
  //ShowCompose('Ausreo', 1);
end;

function TWPrincipal.GetDMCompose: TDMCompose;
begin
  if FDMCompose = nil then
    Application.CreateForm(TDMCompose, FDMCompose);
  Result := FDMCompose;
end;

function TWPrincipal.GetDMItems: TDMItems;
begin
  if FDMItems = nil then
    Application.CreateForm(TDMItems, FDMItems);
  Result := FDMItems;
end;

function TWPrincipal.GetFormCompose: TWCompose;
begin
  if FFormCompose = nil then
  begin
    Application.CreateForm(TWCompose, FFormCompose);
    FFormCompose.FreeNotification(Self);
    FFormCompose.UpdateLanguage;
    FFormCompose.ManualDock(PageControlDock);
    //FFormCompose.ManualDock(PanelDock);
  end;
  Result := FFormCompose;
end;

function TWPrincipal.GetFormItems: TWItems;
begin
  if FFormItems = nil then
  begin
    Application.CreateForm(TWItems, FFormItems);
    FFormItems.FreeNotification(Self);
    FFormItems.UpdateLanguage;
    FFormItems.ManualDock(PageControlDock);
    //FFormItems.ManualDock(PanelDock);
  end;
  Result := FFormItems;
end;

procedure TWPrincipal.HandleCompose(Sender: TObject; const ItemName: string);
var versionOrder: Integer;
begin
  versionOrder := SelectItemVersion(ItemName);
  if versionOrder <> 0 then
  begin
    HideCompose;
    ShowCompose(ItemName, versionOrder);
    PageControlDock.TabIndex := FindTabSheet(FormCompose.Caption);
  end;
end;

procedure TWPrincipal.HandleEditVersion(Sender: TObject;
  const ItemName: string);
begin

end;

procedure TWPrincipal.HideCompose;
begin
//  FormCompose.Hide;
  DMCompose.Disconnect;
end;

procedure TWPrincipal.HideItems;
begin
//  FormItems.Hide;
  DMItems.Disconnect;
end;

procedure TWPrincipal.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if Operation = opRemove then
  begin
    if AComponent = FFormItems then
      FFormItems := nil
    else if AComponent = FDMItems then
      FDMItems := nil
  end;
end;

procedure TWPrincipal.ShowCompose(const AItemName: string;
  AVersionOrder: Integer);
begin
  DMCompose.Database := DMPrincipal.Database;
  DMCompose.Connect;

  FormCompose.DataModule := DMCompose;
  FormCompose.Items := ItemCache;
  FormCompose.Compose(AItemName, AVersionOrder);
  FormCompose.Show;
end;

procedure TWPrincipal.ShowItems;
begin
  DMItems.Database := DMPrincipal.Database;
  DMItems.Connect;

  FormItems.DataModule := DMItems;
  FormItems.OnCompose := HandleCompose;
  FormItems.OnEditVersion := HandleEditVersion;
  FormItems.Show;
end;

end.
