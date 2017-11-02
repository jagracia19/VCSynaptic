unit UHash;

interface

uses
  IdHash, IdHashSHA, IdHashMessageDigest,
  SysUtils, Classes;

function HashStringSHA1(const S: string): string;
function HashFileSHA1(const Filename: string): string;

function HashStringMD5(const S: string): string;
function HashFileMD5(const Filename: string): string;

implementation

function HashString(Const S: string; ClassHash: TIdHashClass): string;
begin
  with ClassHash.Create do
  try
    Result := HashStringAsHex(S);
  finally
    Free;
  end;
end;

function HashFile(const Filename: string; ClassHash: TIdHashClass): string;
var fileStream: TFileStream;
begin
  fileStream := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
  try
    with ClassHash.Create do
    try
      Result := HashStreamAsHex(fileStream);
    finally
      Free;
    end;
  finally
    fileStream.Free;
  end;
end;

function HashStringSHA1(const S: string): string;
begin
  Result := HashString(S, TIdHashSHA1);
end;

function HashFileSHA1(const Filename: string): string;
begin
  Result := HashFile(Filename, TIdHashSHA1);
end;

function HashStringMD5(Const S: string): string;
begin
  Result := HashString(S, TIdHashMessageDigest5);
end;

function HashFileMD5(const Filename: string): string;
begin
  Result := HashFile(Filename, TIdHashMessageDigest5);
end;

end.
