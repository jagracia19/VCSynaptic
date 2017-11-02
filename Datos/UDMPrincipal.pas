unit UDMPrincipal;

interface

uses
  SysUtils, Classes, FIBDatabase, pFIBDatabase;

type
  TDMPrincipal = class(TDataModule)
    Database: TpFIBDatabase;
    Transaction: TpFIBTransaction;
    TransactionUpdate: TpFIBTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
  public
    procedure Conectar(const ADBName: string);
    procedure Desconectar;
  end;

var
  DMPrincipal: TDMPrincipal;

implementation

uses
  FIBUtils.Interf,
  VCSynaptic.Database;

{$R *.dfm}

{ TDMPrincipal }

procedure TDMPrincipal.Conectar(const ADBName: string);
begin
  FIBUtils.Interf.Connect(Database, ADBName, TVCSynapticDatabase.UserName,
      TVCSynapticDatabase.Password, TVCSynapticDatabase.UserRole);
end;

procedure TDMPrincipal.DataModuleCreate(Sender: TObject);
begin
  Database.LibraryName := FIBUtils.Interf.GetFirebirdLibrary;
end;

procedure TDMPrincipal.Desconectar;
begin
  FIBUtils.Interf.Disconnect(Database);
end;

end.
