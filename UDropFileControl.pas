unit UDropFileControl;

interface

uses
  Classes, ExtCtrls, Messages, Graphics, ShellAPI, StrUtils;

type
  TFileNameEvent = procedure (Sender: TObject; const Filename: string) of object;

  TDropFileControl = class(TPanel)
  private
    FOnDropFile: TFileNameEvent;
  protected
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure DoDropFile(const Filename: string);
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    property OnDropFile: TFileNameEvent read FOnDropFile write FOnDropFile;
  end;

implementation

{ TDropFileControl }

constructor TDropFileControl.Create(AOwner: TComponent);
begin
  inherited;
  Caption := 'Drop file';
  Font.Style := Font.Style + [fsBold];
  Font.Color := clSilver;
  Font.Size := 12;
end;

procedure TDropFileControl.CreateWnd;
begin
  inherited;
  DragAcceptFiles(Handle, True);
end;

procedure TDropFileControl.DestroyWnd;
begin
  DragAcceptFiles(Handle, False);
  inherited;
end;

procedure TDropFileControl.DoDropFile(const Filename: string);
begin
  if Assigned(FOnDropFile) then FOnDropFile(Self, Filename);
end;

procedure TDropFileControl.WMDropFiles(var Msg: TWMDropFiles);
var hDrop     : THandle;
    fileCount : Integer;
    nameLen   : Integer;
    I         : Integer;
    st        : string;
begin
  hDrop := Msg.Drop;
  fileCount:= DragQueryFile (hDrop , $FFFFFFFF, nil, 0);
  for I := 0 to fileCount-1 do
  begin
    nameLen:= DragQueryFile(hDrop, I, nil, 0) + 1;
    SetLength(st, nameLen);
    DragQueryFile(hDrop, I, Pointer(st), NameLen);
    while EndsStr(#0, st) do
      Delete(st, Length(st), 1);
    DoDropFile(st);
  end;
  DragFinish(hDrop);
end;

end.
