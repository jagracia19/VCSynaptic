unit UConfiguracion;

interface

uses
  SysUtils, IniFiles, Forms;

type
  TConfiguracion = class
  private
    FBaseDatos: string;
  protected
    procedure LeerDesdeIni(F: TIniFile); virtual;
    procedure EscribirEnIni(F: TIniFile); virtual;
  public
    constructor Create;
    procedure Assign(Source: TConfiguracion); virtual;
    procedure LeerDesdeFichero(const NombreFichero: string);
    procedure EscribirEnFichero(const NombreFichero: string);
    property BaseDatos: string read FBaseDatos write FBaseDatos;
  end;

var Configuracion: TConfiguracion;
    FicheroConfig: TFileName;

implementation

uses
  VCSynaptic.Database;

const
  SeccionVCSynaptic = 'VCSYNAPTIC';
  IdBaseDatos       = 'BaseDatos';

{ TConfiguracion }

procedure TConfiguracion.Assign(Source: TConfiguracion);
begin
  FBaseDatos := Source.BaseDatos;
end;

constructor TConfiguracion.Create;
begin
  inherited;
  FBaseDatos :=
      IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) +
      IncludeTrailingPathDelimiter('Db') + TVCSynapticDatabase.DatabaseName;
end;

procedure TConfiguracion.EscribirEnFichero(const NombreFichero: string);
var F: TIniFile;
begin
  F := TIniFile.Create(NombreFichero);
  try
    EscribirEnIni(F);
  finally
    F.Free;
  end;
end;

procedure TConfiguracion.EscribirEnIni(F: TIniFile);
begin
  with F do
  begin
    WriteString(SeccionVCSynaptic, IdBaseDatos, FBaseDatos);
  end;
end;

procedure TConfiguracion.LeerDesdeFichero(const NombreFichero: string);
var F: TIniFile;
begin
  F := TIniFile.Create(NombreFichero);
  try
    LeerDesdeIni(F);
  finally
    F.Free;
  end;
end;

procedure TConfiguracion.LeerDesdeIni(F: TIniFile);
begin
  with F do
  begin
    FBaseDatos := ReadString(SeccionVCSynaptic, IdBaseDatos, FBaseDatos);
  end;
end;

initialization
  FicheroConfig := ChangeFileExt(Application.ExeName, '.ini');
  Configuracion := TConfiguracion.Create;
  if FileExists(FicheroConfig) then
    Configuracion.LeerDesdeFichero(FicheroConfig)
  else Configuracion.EscribirEnFichero(FicheroConfig);

finalization
  FreeAndNil(Configuracion);

end.
