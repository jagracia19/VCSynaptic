program VCSynapticTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  TestUHash in 'TestUHash.pas',
  UHash in '..\UHash.pas',
  TestUFinder in 'TestUFinder.pas',
  VCSynaptic.Classes in '..\Clases\VCSynaptic.Classes.pas',
  VCSynaptic.Database in '..\Datos\VCSynaptic.Database.pas',
  UFinder in '..\UFinder.pas',
  Test.DataModule in 'Test.DataModule.pas' {DataModuleTest: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

