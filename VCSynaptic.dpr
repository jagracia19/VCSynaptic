program VCSynaptic;

uses
  Forms,
  SysUtils,
  UWPrincipal in 'Fichas\UWPrincipal.pas' {WPrincipal},
  UHash in 'UHash.pas',
  UDMPrincipal in 'Datos\UDMPrincipal.pas' {DMPrincipal: TDataModule},
  UConfiguracion in 'Configuracion\UConfiguracion.pas',
  VCSynaptic.Database in 'Datos\VCSynaptic.Database.pas',
  VCSynaptic.Classes in 'Clases\VCSynaptic.Classes.pas',
  UWItems in 'Fichas\UWItems.pas' {WItems},
  UDMItems in 'Datos\UDMItems.pas' {DMItems: TDataModule},
  UDMImages in 'Fichas\UDMImages.pas' {DMImages: TDataModule},
  UDMCompose in 'Datos\UDMCompose.pas' {DMCompose: TDataModule},
  UWCompose in 'Fichas\UWCompose.pas' {WCompose},
  UCache in 'UCache.pas',
  UGrid in 'Grid\UGrid.pas',
  UWMaster in 'Fichas\UWMaster.pas' {WMaster},
  UDMItemVersion in 'Datos\UDMItemVersion.pas' {DMItemVersion: TDataModule},
  UWDlgOkCancel in 'Fichas\UWDlgOkCancel.pas' {WDlgOkCancel},
  UWMasterEdit in 'Fichas\UWMasterEdit.pas' {WMasterEdit},
  UWItemVersion in 'Fichas\UWItemVersion.pas' {WItemVersion},
  UWItem in 'Fichas\UWItem.pas' {WItem},
  UWDate in 'Fichas\UWDate.pas' {WDate},
  VCSynaptic.Functions in 'VCSynaptic.Functions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDMPrincipal, DMPrincipal);
  Application.CreateForm(TDMImages, DMImages);
  Application.CreateForm(TWPrincipal, WPrincipal);
  // database
  try
    DMPrincipal.Conectar(Configuracion.BaseDatos);
  except
    raise Exception.Create('La base de datos no existe');
    // crear base datos por defecto
    //ForceDirectories(ExtractFilePath(Configuracion.BaseDatos));
    //TOptiFlowDatabase.CreateDatabase(Configuration.OptiFlowDatabase);
    //TOptiFlowDatabase.InitDatabase(HInstance,
    //    Configuration.OptiFlowDatabase);

    //DMPrincipal.Connect(Configuration.OptiFlowDatabase);
  end;
  try
    Application.CreateForm(TWPrincipal, WPrincipal);
    Application.Run;
  finally
    DMPrincipal.Desconectar;
  end;
end.
