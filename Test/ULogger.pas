(*
 * Define OBJETO_LOGGER para utiliza el objeto logger
 *)
unit ULogger;

interface

uses
  SysUtils, Forms, Dialogs, Classes;

const
  LogSizeMax = 5*1024*1024;

procedure LoggerWriteRaw(const FileName, Text: string);
procedure LoggerWrite(const FileName, Text: string);
procedure LoggerClip(FileName: String; MaxSize: Cardinal = LogSizeMax);


implementation

procedure LoggerWriteRaw(const FileName, Text: string);
var F : TextFile;
begin
  AssignFile(F, FileName);
  if not FileExists(FileName) then
    Rewrite(F)
  else Append(F);
  Writeln(F, Text);
  Flush(F);
  CloseFile(F);
end;

procedure LoggerWrite(const FileName, Text: string);
var st: string;
begin
  st := FormatDateTime('dd/mm/yy hh:nn:ss', Now) + ' ' + Text;
  LoggerWriteRaw(FileName, st);
end;

procedure LoggerClip(FileName: String; MaxSize: Cardinal);
const BufferSize = 1024;
var F, FTmp : file of byte;
    size    : Cardinal;
    cnt     : Longint;
    nmTmp   : string;
    buffer  : PChar;
begin
  cnt := 0; // evitar  warning
  if FileExists(FileName) then
  begin
    // comprobar tamaño del fichero
    AssignFile(F, FileName);
    Reset(F);
    size := FileSize(F);
    if size > MaxSize then
    begin
      buffer := PChar(AllocMem(BufferSize));
      try
        // copiar mitad del fichero en fichero temporal
        nmTmp := FileName + '.$$$';
        AssignFile(FTmp, nmTmp);
        Rewrite(FTmp);                  // crear fichero temporal
        Seek(F, size div 2);            // posicionar a mitad del fichero
        while not Eof(F) do
        begin
          BlockRead(F, buffer^, BufferSize, cnt);
          BlockWrite(FTmp, buffer^, cnt);
        end;
        CloseFile(FTmp);
      finally
        FreeMem(buffer);
      end;
    end;
    CloseFile(F);

    if size > MaxSize then
    begin
      // reemplazar fichero logger por el temporal
      DeleteFile(FileName);
      RenameFile(nmTmp, FileName);
    end;
  end;
end;


end.

