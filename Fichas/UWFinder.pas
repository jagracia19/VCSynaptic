unit UWFinder;

interface

uses
  UDropFileControl,
  UFinder,
  UDMFinder,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ActnList, ComCtrls, ToolWin, Grids, Math;

type
  TWFinder = class(TForm)
    PanelDropFile: TPanel;
    ActionList: TActionList;
    ActionRefresh: TAction;
    ActionClose: TAction;
    ToolBar1: TToolBar;
    ToolButtonRefresh: TToolButton;
    ToolButtonClose: TToolButton;
    Grid: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ActionRefreshExecute(Sender: TObject);
    procedure ActionCloseExecute(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure FormResize(Sender: TObject);
  private
    FDataModule: TDMFinder;
    FDropFiles: TDropFileControl;
    FFiles: TStrings;
    FFinder: TFinder;
    procedure UpdateFinder;
    procedure UpdateGrid(ARowCount, AColCount: Integer);
    procedure ResizeGrid;
    function GetColFinderNode(ACol: Integer;
      ALeaves: TFinderNodeList): TFinderNode;
    function GetRowFilename(ARow: Integer): string;
    function GetRowFinderItem(ARow: Integer): TFinderItem;
    procedure HandleDropFiles(Sender: TObject; const Filename: string);
    function GetFinder: TFinder;
  protected
    property Files: TStrings read FFiles;
    property Finder: TFinder read GetFinder;
  public
    procedure UpdateLanguage;
    property DataModule: TDMFinder read FDataModule;
  end;

var
  WFinder: TWFinder;

implementation

uses
  UDMImages;

{$R *.dfm}

const
  GRID_COL_WIDTH_MIN      = 60;
  GRID_COL_FILE_WIDTH     = 180;
  GRID_COL_VER_OR_WIDTH   = 30;
  GRID_COL_VER_NM_WIDTH   = 60;
  GRID_COL_VER_DT_WIDTH   = 70;

  GRID_ROW_ITEM   = 0;  GRID_ROW_TITLES = GRID_ROW_ITEM;
  GRID_ROW_VER_OR = 1;
  GRID_ROW_VER_NM = 2;
  GRID_ROW_VER_DT = 3;
  GRID_FIXED_ROWS = 4;

  GRID_COL_FILE   = 0;
  GRID_COL_VER_OR = 1;
  GRID_COL_VER_NM = 2;
  GRID_COL_VER_DT = 3;
  //GRID_FIXED_COLS = 4;
  GRID_FIXED_COLS = 3;

  TXT_MARG      : TPoint = (x: 4; y: 2);
  BTN_WIDTH     = 12;
  DIB_MARG_X    = 1;
  LEVEL_MARGIN  = 20;

{ TWFinder }

procedure TWFinder.ActionCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TWFinder.ActionRefreshExecute(Sender: TObject);
begin
  UpdateFinder;
  UpdateGrid(Files.Count, Finder.UnionLeaves.Count);
  ResizeGrid;
end;

procedure TWFinder.FormCreate(Sender: TObject);
begin
  FDataModule := TDMFinder.Create(nil);

  FDropFiles := TDropFileControl.Create(Self);
  FDropFiles.Parent := PanelDropFile;
  FDropFiles.Align := alClient;
  FDropFiles.OnDropFile := HandleDropFiles;
  FDropFiles.Caption := 'Drop files';

  FFiles := TStringList.Create;
end;

procedure TWFinder.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FFiles);
  FreeAndNil(FFinder);
  if FDataModule <> nil then
  begin
    FDataModule.Disconnect;
    FDataModule.Free;
    FDataModule := nil;
  end;
end;

procedure TWFinder.FormResize(Sender: TObject);
begin
  ResizeGrid;
end;

function TWFinder.GetColFinderNode(ACol: Integer;
  ALeaves: TFinderNodeList): TFinderNode;
begin
  Result := nil;
  if ACol >= GRID_FIXED_COLS then
  begin
    ACol := ACol - GRID_FIXED_COLS;
    if (Finder <> nil) and (ACol < ALeaves.Count) then
      Result := ALeaves[ACol];
  end;
end;

function TWFinder.GetFinder: TFinder;
begin
  if FFinder = nil then
    FFinder := TFinder.Create;
  Result := FFinder;
end;

function TWFinder.GetRowFilename(ARow: Integer): string;
begin
  Result := '';
  if ARow >= GRID_FIXED_ROWS then
  begin
    ARow := ARow - GRID_FIXED_ROWS;
    if (Files <> nil) and (ARow < Files.Count) then
      Result := Files[ARow];
  end;
end;

function TWFinder.GetRowFinderItem(ARow: Integer): TFinderItem;
var filename: string;
begin
  Result := nil;
  filename := GetRowFilename(ARow);
  if (Length(filename) <> 0) and (Finder <> nil) then
    Result := Finder.FinderItems.FindFilename(filename);
end;

procedure TWFinder.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

  function GetTextHeader(ACol, ARow: integer): string;
  var finderNode: TFinderNode;
  begin
    Result := '';
    if ACol < GRID_FIXED_COLS then
    begin
      if ARow = GRID_ROW_TITLES then
        case ACol of
          GRID_COL_FILE   : Result := 'Filename';
          GRID_COL_VER_OR : Result := 'Ord';
          GRID_COL_VER_NM : Result := 'Ver';
          GRID_COL_VER_DT : Result := 'Date';
        end
    end
    else
    begin
      finderNode := GetColFinderNode(ACol, Finder.UnionLeaves);
      if finderNode <> nil then
        case ARow of
          GRID_ROW_ITEM: Result := finderNode.ItemName;
          GRID_ROW_VER_OR: Result := IntToStr(finderNode.VersionOrder);
          GRID_ROW_VER_NM: Result := finderNode.VersionNumber;
          GRID_ROW_VER_DT: Result := DateToStr(finderNode.VersionDate);
        end;
    end;
  end;

  function GetTextData(ACol, ARow: integer): string;
  var filename  : string;
      finderItem: TFinderItem;
  begin
    Result := '';
    if ARow >= GRID_FIXED_ROWS then
    begin
      filename := GetRowFilename(ARow);
      if ACol < GRID_FIXED_COLS then
      begin
        case ACol of
          GRID_COL_FILE   : Result := ExtractFileName(filename);
          GRID_COL_VER_OR, GRID_COL_VER_NM, GRID_COL_VER_DT:
          begin
            finderItem := GetRowFinderItem(ARow);
            if (finderItem <> nil) and (finderItem.Root <> nil) then
              case ACol of
                GRID_COL_VER_OR: Result := IntToStr(finderItem.Root.VersionOrder);
                GRID_COL_VER_NM: Result := finderItem.Root.VersionNumber;
                GRID_COL_VER_DT: Result := DateToStr(finderItem.Root.VersionDate);
              end;
          end;
        end
      end
    end;
  end;

  function GetTextDataColor(ACol, ARow: integer): TColor;
  var itemNode    : TFinderNode;
      unionNode   : TFinderNode;
      interNode   : TFinderNode;
      finderItem  : TFinderItem;
      finderNodes : TFinderNodeList;
      ownerName   : string;
  begin
    Result := clWindow;
    if ARow >= GRID_FIXED_ROWS then
    begin
      finderItem := GetRowFinderItem(ARow);
      if finderItem <> nil then
      begin
        if ACol >= GRID_FIXED_COLS then
        begin
          unionNode := GetColFinderNode(ACol, Finder.UnionLeaves);
          if unionNode <> nil then
          begin
            itemNode := finderItem.Leaves.Find(unionNode.ItemName,
                unionNode.VersionOrder);
            interNode := Finder.InterLeaves.Find(unionNode.ItemName,
                unionNode.VersionOrder);
            if itemNode <> nil then
            begin
              if interNode <> nil then Result := clGreen
              else
              begin
                Result := clYellow;

                ownerName := finderItem.OwnerName;
                if Length(ownerName) <> 0 then
                begin
                  finderNodes := Finder.InterLeaveList[finderItem.OwnerName];
                  if finderNodes <> nil then
                  begin
                    interNode := finderNodes.Find(unionNode.ItemName,
                        unionNode.VersionOrder);
                    if (interNode <> nil) and
                       SameText(ownerName, interNode.ItemName)
                    then Result := $00b8ff;
                  end;
                end;
              end;
            end;
          end;
        end;
      end
      else Result := clBtnFace;
    end;
  end;

  procedure DrawHeader(ACol, ARow: integer; Rect: TRect);
  var txtRect : TRect;
      st      : string;
  begin
    //Textplacement:
    txtRect := Rect;
    txtRect.Left := Rect.Left + TXT_MARG.x;
    txtRect.Top := Rect.Top + TXT_MARG.y;

    //Setting canvas properties and erasing old cellcontent:
    with Grid.Canvas do
    begin
      Brush.Color := clBtnFace;
      Pen.Color := clBtnFace;
      Pen.Style := psSolid;
      Font.Style := [];
      Font.Color := clWindowText;
      Font.Name := Grid.Font.Name;
      Font.Size := Grid.Font.Size;
      FillRect(rect);
    end;

    //Drawing text:
    st := GetTextHeader(ACol, ARow);
    DrawText(Grid.Canvas.Handle, PChar(st),
             length(st), txtRect,
             DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);

    //Drawing 3D-frame:
    //with Grid.Canvas do
    //begin
    //  Pen.Style := psSolid;
    //  Pen.Width := 1;
    //  Pen.Color := clWhite;
    //  Polyline([point(rect.left, rect.bottom),
    //           rect.TopLeft, point(rect.Right, rect.top)]);
    //  Pen.Color := clBtnShadow;
    //  Polyline([point(rect.left+1, rect.bottom-1),
    //           point(rect.right-1, rect.bottom-1),
    //           point(rect.Right-1, rect.Top+1)]);
    //end;
  end;

  procedure DrawData(ACol, ARow: integer; Rect: TRect);
  var txtRect   : TRect;
      btnRect   : TRect;
      //btnState  : integer;
      st        : string;
      //tmpstr    : string;
      //tmpRect   : TRect;
      focusRect : TRect;
      //node      : TItemNode;
      cellColor : TColor;
  begin
    st := '';
    cellColor := clWindow;
    if ACol < GRID_FIXED_COLS then
      st := GetTextData(ACol, ARow)
    else cellColor := GetTextDataColor(ACol, ARow);


    //Setting canvas properties and erasing old cellcontent:
    Grid.Canvas.Brush.Color := cellColor;
    Grid.Canvas.Brush.Style := bsSolid;
    Grid.Canvas.Pen.Style := psSolid;
    Grid.Canvas.FillRect(rect);

    //Textposition:
    txtRect := Rect;
    focusRect := Rect;
    txtRect.Left := Rect.left + TXT_MARG.x;

    //Drawing selection:
    //Grid.Canvas.Font.Style := [];
    //if (gdSelected in State) then
    //begin
    //  Grid.Canvas.Brush.Color := clbtnFace;
    //  Grid.Canvas.Font.Color := clBlue;
    //end
    //else
    //begin
    //  Grid.Canvas.Brush.Color := cellColor;
    //  Grid.Canvas.Font.Color := clWindowText;
    //end;
    //Grid.canvas.FillRect(Rect);

    //Drawing text:
    st := GetTextData(ACol, ARow);
    Grid.Canvas.Font.Name := Grid.Font.Name;
    Grid.Canvas.Font.Size := Grid.Font.Size;
    DrawText(Grid.canvas.Handle, PChar(st), length(st),
             txtRect, DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);

    //If selected, draw focusrect:
    //if gdSelected in State then
    //  with Grid.canvas do
    //  begin
    //    Pen.Style := psInsideFrame;
    //    Pen.Color := clBtnShadow;
    //    Polyline([Point(focusRect.left-1, focusRect.Top),
    //              Point(focusRect.right-1, focusRect.Top)]);
    //    Polyline([Point(focusRect.left-1, focusRect.Bottom-1),
    //              Point(focusRect.right-1, focusRect.Bottom-1)]);
    //    if ACol = 0 then
    //      Polyline([Point(focusRect.left-1, focusRect.Top),
    //                Point(focusRect.left-1, focusRect.Bottom-1)])
    //    else if ACol = Grid.ColCount - 1 then
    //      Polyline([Point(focusRect.right-1, focusRect.Top),
    //                Point(focusRect.right-1, focusRect.Bottom-1)]);
    //  end;
  end;

var txtRect   : TRect;
    btnRect   : TRect;
    btnState  : integer;
    st        : string;
    tmpstr    : string;
    tmpRect   : TRect;
    focusRect : TRect;
begin
  if ARow < Grid.FixedRows then
    DrawHeader(ACol, ARow, Rect)
  else if ARow >= Grid.FixedRows then
    DrawData(ACol, ARow, Rect)
end;

procedure TWFinder.HandleDropFiles(Sender: TObject; const Filename: string);
begin
  Files.Add(Filename);
end;

procedure TWFinder.ResizeGrid;
var col : Integer;
    w   : Integer;
    wFix: Integer;
begin
  Grid.ColWidths[GRID_COL_FILE] := GRID_COL_FILE_WIDTH;
  Grid.ColWidths[GRID_COL_VER_OR] := GRID_COL_VER_OR_WIDTH;
  Grid.ColWidths[GRID_COL_VER_NM] := GRID_COL_VER_NM_WIDTH;
  Grid.ColWidths[GRID_COL_VER_DT] := GRID_COL_VER_DT_WIDTH;
  wFix := 0;
  for col := 0 to Grid.FixedCols-1 do
    wFix := wFix + Grid.ColWidths[col];
  w := Grid.ClientWidth - wFix - 30;
  w := w div (Grid.ColCount-GRID_FIXED_COLS);
  w := Max(w, GRID_COL_WIDTH_MIN);
  for col := Grid.FixedCols to Grid.ColCount-1 do
    Grid.ColWidths[col] := w;
end;

procedure TWFinder.UpdateFinder;
begin
  // reset finder
  if FFinder <> nil then
    FreeAndNil(FFinder);
  // finder from files
  Finder.Finder(DataModule.Database, DataModule.Transaction, Files);
end;

procedure TWFinder.UpdateGrid(ARowCount, AColCount: Integer);
begin
  Grid.RowCount := ARowCount + GRID_FIXED_ROWS;
  if Grid.RowCount > GRID_FIXED_ROWS then
    Grid.FixedRows := GRID_FIXED_ROWS;
  Grid.ColCount := AColCount + GRID_FIXED_COLS;
  Grid.FixedCols := GRID_FIXED_COLS;
  Grid.Invalidate;
end;

procedure TWFinder.UpdateLanguage;
begin
end;

end.
