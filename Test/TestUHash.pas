unit TestUHash;

interface

uses
  TestFramework, Windows, Forms, Dialogs, Controls, Classes, SysUtils, Variants,
  Graphics, Messages;

type
  // Test methods for class TForm1

  TestHash = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure HashSHA1;
    procedure HashMD5;
  end;

implementation

uses
  UHash;

procedure TestHash.HashMD5;
begin
  Assert(SameText(HashFileMD5('C:\VCS2\Library\SQLite\Bpl\SQLite.bpl'),
      '32aa0a72447005fb6cecc4000dfcf720'));
end;

procedure TestHash.HashSHA1;
begin
  Assert(SameText(HashFileSHA1('C:\VCS2\Library\SQLite\Bpl\SQLite.bpl'),
      'b1a69be24d5caacabc91451a6962bb7c95a889b8'));
end;

procedure TestHash.SetUp;
begin
end;

procedure TestHash.TearDown;
begin
end;

initialization
  RegisterTest(TestHash.Suite);

end.

