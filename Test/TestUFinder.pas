unit TestUFinder;

interface

uses
  UFinder,
  pFIBDatabase, pFIBQuery,
  Test.DataModule,
  TestFramework, SysUtils, Classes, Generics.Collections, Forms, Types, IOUtils;

type
  TestFinde = class(TTestCase)
  strict private
    FDataModule: TDataModuleTest;
    FFiles: TStrings;
    FFinder: TFinder;
  protected
    property DataModule: TDataModuleTest read FDataModule;
    property Files: TStrings read FFiles;
    property Finder: TFinder read FFinder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFinderFiles;
    procedure TestFinderDirectory;
  end;

implementation

uses
  VCSynaptic.Classes,
  VCSynaptic.Database,
  ULogger,
  UHash;

procedure TestFinde.SetUp;
begin
  FileLogFinder := IncludeTrailingPathDelimiter(ExtractFilePath(
      Application.ExeName)) + 'TestFinder.log';

  FDataModule := TDataModuleTest.Create(nil);
  FDataModule.Database.Connected := True;

  FFiles := TStringList.Create;
  FFinder := TFinder.Create;
end;

procedure TestFinde.TearDown;
begin
  FreeAndNil(FFinder);
  FreeAndNil(FFiles);

  FDataModule.Database.Connected := False;
  FDataModule.Free;
  FDataModule := nil;
end;

procedure TestFinde.TestFinderDirectory;
var files: TStringDynArray;
begin
  files := TDirectory.GetFiles('C:\VCS2\OptiFlow2\Ausreo\Release\Win32');
  Finder.Finder(DataModule.Database, DataModule.Transaction, files);
end;

procedure TestFinde.TestFinderFiles;
begin
  Files.Add('C:\VCS2\OptiFlow2\Ausreo\Release\Win32\OptiFlowCommon.bpl');
  Files.Add('C:\VCS2\OptiFlow2\Ausreo\Release\Win32\OptiFlowVarLog.bpl');
  Files.Add('C:\VCS2\OptiFlow2\Ausreo\Release\Win32\fbclient.dll');
  Finder.Finder(DataModule.Database, DataModule.Transaction, Files);
end;

initialization
  RegisterTest(TestFinde.Suite);

end.

