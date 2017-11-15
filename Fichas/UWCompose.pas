unit UWCompose;

interface

uses
  VCSynaptic.Classes,
  UDMCompose,
  pFIBDatabase, pFIBDataSet,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, Generics.Collections;

type
  TItemNode = class(TComponent)
  private
    FItem: TItem;
    FVisible: Boolean;
    FLevel: Integer;
    //FPrevious: TItemNode;
    //FNext: TItemNode;
    function GetParent: TItemNode;
    function GetChildCount: Integer;
    function GetChildren(Index: Integer): TItemNode;
    //procedure SetPrevious(const Value: TItemNode);
    //procedure SetNext(const Value: TItemNode);
  protected
    //procedure Notification(AComponent: TComponent;
    //  Operation: TOperation); override;
    procedure ValidateInsert(AComponent: TComponent); override;
  public
    constructor Create(AOwner: TItemNode); reintroduce; virtual;
    property Parent: TItemNode read GetParent;
    property ChildCount: Integer read GetChildCount;
    property Children[Index: Integer]: TItemNode read GetChildren; default;
    //property Previous: TItemNode read FPrevious write SetPrevious;
    //property Next: TItemNode read FNext write SetNext;
    property Item: TItem read FItem write FItem;
    property Visible: Boolean read FVisible write FVisible;
    property Level: Integer read FLevel write FLevel;
  end;

  TWCompose = class(TForm)
    Grid: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure GridClick(Sender: TObject);
  private
    FDataModule: TDMCompose;
    FItems: TItemList;  // reference to cache items
    FItem: TItem;       // reference to item selected
    FRoot: TItemNode;
    FVisibleItems: TList<TItemNode>;
    FItemTypes: TItemTypeSet;
    FInMouseClick: Boolean;
    FDatabase: TpFIBDatabase;
    FTransaction: TpFIBTransaction;
    FTransactionUpdate: TpFIBTransaction;
    procedure InitGrid;
    procedure InitItemTypes;
    procedure UpdateItemTree;
    procedure ActualizarVisibleItems;
    procedure UpdateGrid(ARowCount: Integer);
    function GetRowItemNode(ARow: Integer): TItemNode;
    procedure SetDataModule(const Value: TDMCompose);
    procedure SetItems(const Value: TItemList);
    procedure SetItemTypes(const Value: TItemTypeSet);
    procedure SetDatabase(const Value: TpFIBDatabase);
    procedure SetTransaction(const Value: TpFIBTransaction);
    procedure SetTransactionUpdate(const Value: TpFIBTransaction);
  protected
    property Item: TItem read FItem write FItem;
    property Root: TItemNode read FRoot write FRoot;
    property VisibleItems: TList<TItemNode> read FVisibleItems write FVisibleItems;
  public
    procedure UpdateLanguage;
    procedure Compose(const AItemName: string; AVersionOrder: Integer);
    property Database: TpFIBDatabase read FDatabase write SetDatabase;
    property Transaction: TpFIBTransaction read FTransaction write SetTransaction;
    property TransactionUpdate: TpFIBTransaction read FTransactionUpdate write SetTransactionUpdate;
    //property DataModule: TDMCompose read FDataModule write SetDataModule;
    property Items: TItemList read FItems write SetItems;
    property ItemTypes: TItemTypeSet read FItemTypes write SetItemTypes;
  end;

var
  WCompose: TWCompose;

implementation

uses
  UGrid,
  VCSynaptic.Functions,
  VCSynaptic.Database,
  UDMImages;

{$R *.dfm}

const
  TXT_MARG      : TPoint = (x: 4; y: 2);
  BTN_WIDTH     = 12;
  DIB_MARG_X    = 1;
  LEVEL_MARGIN  = 20;

  ColName     = 0;
  ColVerOrd   = 1;
  ColVerNum   = 2;
  ColDate     = 3;
  ColHash     = 4;


{
procedure TestSelectAllPackages;
var items : TItemList;
    child : TItem;
    I     : Integer;
begin
  items := TItemList.Create(True);
  try
    TItemRelation.SelectAllType(DMPrincipal.Database, DMPrincipal.Transaction,
        items, itPackage);
    WPrincipal.Memo1.Lines.Clear;
    for I := 0 to items.Count-1 do
    begin
      child := items[I];
      WPrincipal.Memo1.Lines.Add(child.Name);
    end;
  finally
    items.Free;
  end;
end;

procedure PrintItemTree(AItem: TItem; AStrings: TStrings; ATab: string);
var st: string;
    I : Integer;
begin
  st := AItem.Name;
  //if AItem.Version <> nil then
  //  st := st + ' ' + AItem.Version.Number + ' ' + IntToStr(AItem.Version.Order);
  AStrings.Add(ATab + st);

  if not (AItem is TPackageItem) then
    for I := 0 to AItem.ChildCount-1 do
      PrintItemTree(AItem.Children[I], AStrings, ATab + '    ');
end;

procedure TestReadItemRecursive;
var items : TItemList;
    item      : TItem;
    child     : TItem;
begin
  WPrincipal.Memo1.Lines.Clear;
  items := TItemList.Create(True);
  try
//    item := TDatabaseRelation.ReadItemVersion(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, 'lib2Logger', 1);
//    TDatabaseRelation.ReadItemChildren(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, item);
//    PrintItemTree(item, WPrincipal.Memo1.Lines, '');
//
//    item := TDatabaseRelation.ReadItemVersion(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, 'lib2LoggerCodeSite', 1);
//    TDatabaseRelation.ReadItemChildren(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, item);
//    PrintItemTree(item, WPrincipal.Memo1.Lines, '');
//
//    item := TDatabaseRelation.ReadItemVersion(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, 'Library2', 1);
//    TDatabaseRelation.ReadItemChildren(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, item);
//    PrintItemTree(item, WPrincipal.Memo1.Lines, '');

//    item := TDatabaseRelation.ReadItemVersion(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, 'OptiFlowLibrary', 1);
//    TDatabaseRelation.ReadItemChildren(DMPrincipal.Database,
//        DMPrincipal.Transaction, items, item);
//    PrintItemTree(item, WPrincipal.Memo1.Lines, '');

    item := TDatabaseRelation.ReadItemVersion(DMPrincipal.Database,
        DMPrincipal.Transaction, items, 'Ausreo', 1);
    TDatabaseRelation.ReadItemChildren(DMPrincipal.Database,
        DMPrincipal.Transaction, items, item);
    PrintItemTree(item, WPrincipal.Memo1.Lines, '');
  finally
    items.Free;
  end;
end;

//TestSelectAllPackages;
//TestReadItemRecursive;
}

////////////////////////////////////////////////////////////////////////////////

procedure DrawButton(AGrid: TDrawGrid; ACol, ARow: integer; const AText: string;
  AComplete: boolean; AAlignment: TAlignment; ABtnWidth: integer = 12;
  ATxtMargX: integer  =4);
var btnRect: TRect;
begin
  btnRect := GetGridBtnRect(AGrid, ACol, ARow, AComplete, AAlignment, ABtnWidth,
      ATxtMargX);

  AGrid.Canvas.Brush.Color := clBtnFace;
  AGrid.Canvas.Pen.Style := psClear;
  AGrid.Canvas.Rectangle(btnRect);
  DrawEdge(AGrid.canvas.Handle, btnRect, EDGE_RAISED,
      BF_FLAT or BF_RECT or BF_ADJUST);

  AGrid.Canvas.Font.Name := 'Arial';
  AGrid.Canvas.Font.Size := 8;
  AGrid.Canvas.Font.Color := clBlack;
  DrawText(AGrid.canvas.Handle, AText, -1, btnRect,
    DT_SINGLELINE or DT_CENTER or DT_VCENTER);
end;

{ TItemNode }

constructor TItemNode.Create(AOwner: TItemNode);
begin
  inherited Create(AOwner);
end;

function TItemNode.GetChildCount: Integer;
begin
  Result := ComponentCount;
end;

function TItemNode.GetChildren(Index: Integer): TItemNode;
begin
  Result := TItemNode(Components[Index]);
end;

function TItemNode.GetParent: TItemNode;
begin
  if Owner is TItemNode then
    Result := TItemNode(Owner)
  else Result := nil;
end;

//procedure TItemNode.Notification(AComponent: TComponent; Operation: TOperation);
//begin
//  inherited;
//  if Operation = opRemove then
//  begin
//    if AComponent = FPrevious then FPrevious := nil
//    else if AComponent = FNext then FNext := nil;
//  end;
//end;

//procedure TItemNode.SetNext(const Value: TItemNode);
//begin
//  if FNext <> nil then
//    FNext.RemoveFreeNotification(Self);
//  FNext := Value;
//  if FNext <> nil then
//    FNext.FreeNotification(Self);
//end;

//procedure TItemNode.SetPrevious(const Value: TItemNode);
//begin
//  if FPrevious <> nil then
//    FPrevious.RemoveFreeNotification(Self);
//  FPrevious := Value;
//  if FPrevious <> nil then
//    FPrevious.FreeNotification(Self);
//end;

procedure TItemNode.ValidateInsert(AComponent: TComponent);
begin
  inherited;
  if not (AComponent is TItemNode) then
    raise Exception.Create('Invalid component to insert');
end;

{ TWCompose }

procedure TWCompose.ActualizarVisibleItems;

  procedure CountVisibles(ANode: TItemNode);
  var I: Integer;
  begin
    if ANode.Visible and (ANode.Item.ItemType in ItemTypes) then
    begin
      VisibleItems.Add(ANode);
      for I := 0 to ANode.ChildCount-1 do
        CountVisibles(ANode.Children[I]);
    end;
  end;

begin
  VisibleItems.Clear;
  if FRoot = nil then Exit;
  CountVisibles(FRoot);
end;

procedure TWCompose.Compose(const AItemName: string; AVersionOrder: Integer);
begin
  Item := TDatabaseRelation.ReadItemVersion(Database,
      Transaction, Items, AItemName, AVersionOrder);
  TDatabaseRelation.ReadItemChildren(Database,
      Transaction, Items, FItem);
  UpdateItemTree;
  ActualizarVisibleItems;
  UpdateGrid(VisibleItems.Count);
end;

procedure TWCompose.FormCreate(Sender: TObject);
begin
  FRoot := nil;
  FVisibleItems := TList<TItemNode>.Create;
  InitItemTypes;
  InitGrid;
end;

procedure TWCompose.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FVisibleItems);
  FreeAndNil(FRoot);
end;

function TWCompose.GetRowItemNode(ARow: Integer): TItemNode;
begin
  if ARow >= Grid.FixedRows then
    Result := VisibleItems[ARow-Grid.FixedRows]
  else Result := nil;
end;

procedure TWCompose.GridClick(Sender: TObject);
var where     : TPoint;
    col, row  : Integer;
    btnRect   : TRect;
    node      : TItemNode;
    parentNode: TItemNode;
    item      : TItem;
    ownerItem : TItem;
    bVisible  : Boolean;
    I         : Integer;
    verOrder  : Integer;
begin
  // check to avoid recursion
  if not FInMouseClick then
  begin
    FInMouseClick := True;
    try
      // get clicked coordinates and cell
      where := Mouse.CursorPos;
      where := Grid.ScreenToClient(where);
      Grid.MouseToCell(where.x, where.y, col, row);
      if row >= Grid.FixedRows then
      begin
        node := GetRowItemNode(row);
        if node <> nil then
        begin
          parentNode := node.Parent;
          if parentNode <> nil then
          begin
            item := node.Item;
            ownerItem := parentNode.Item;
            if (item <> nil) and (ownerItem <> nil) then
            begin
              if col = ColVerOrd then
              begin
                verOrder := SelectItemVersion(Database, item.Name);
                if verOrder <> 0 then
                  TItemLinkRelation.UpdateChildVersion(
                      Database, TransactionUpdate,
                      ownerItem.Name, OwnerItem.Version.Order,
                      item.Name, item.Version.Order, verOrder);
              end;
            end;
          end;
        end;

        // get buttonrect for clicked cell
        btnRect := GetGridBtnRect(Grid, col, row, False, taLeftJustify);
        InflateRect(btnrect, 2, 2);  //Allow 2px 'error-range'...

        // check if clicked inside buttonrect:
        if PtInRect(btnRect, where) then
        begin
          case col of
            0:
            begin
              node := GetRowItemNode(row);
              if node.ChildCount <> 0 then
              begin
                bVisible := not node.Children[0].Visible;
                for I := 0 to node.ChildCount-1 do
                  node.Children[I].Visible := bVisible;
                ActualizarVisibleItems;
                UpdateGrid(VisibleItems.Count);
              end;
            end;
          end;
        end;
      end;
    finally
      FInMouseClick := False;
    end;
  end;
end;

procedure TWCompose.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

  function GetTextHeader(ACol, ARow: integer): string;
  begin
    case ACol of
      ColName: Result := 'Name';
      ColVerOrd: Result := 'Version';
      ColVerNum: Result := 'Version';
      ColDate: Result := 'Date';
      ColHash: Result := 'Hash'
    else Result := '';
    end;
  end;

  function GetTextData(ACol, ARow: integer): string;
  var node: TItemNode;
      //I   : Integer;
  begin
    if ARow >= Grid.FixedRows then
    begin
      node := GetRowItemNode(ARow);
      case ACol of
        ColName: Result := node.Item.Name;
        ColVerOrd: Result := IntToStr(node.Item.Version.Order);
        ColVerNum: Result := node.Item.Version.Number;
        ColDate: Result := DateToStr(node.Item.Version.Date);
        ColHash: Result := node.Item.Version.Hash;
      else Result := '';
      end;
    end
    else Result := '';
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
    with Grid.Canvas do
    begin
      Pen.Style := psSolid;
      Pen.Width := 1;
      Pen.Color := clWhite;
      Polyline([point(rect.left, rect.bottom),
               rect.TopLeft, point(rect.Right, rect.top)]);
      Pen.Color := clBtnShadow;
      Polyline([point(rect.left+1, rect.bottom-1),
               point(rect.right-1, rect.bottom-1),
               point(rect.Right-1, rect.Top+1)]);
    end;
  end;

  procedure DrawData(ACol, ARow: integer; Rect: TRect);
  var txtRect   : TRect;
      btnRect   : TRect;
      //btnState  : integer;
      st        : string;
      //tmpstr    : string;
      //tmpRect   : TRect;
      focusRect : TRect;
      node      : TItemNode;
  begin
    node := GetRowItemNode(ARow);

    //Setting canvas properties and erasing old cellcontent:
    Grid.Canvas.Brush.Color := clWindow;
    Grid.Canvas.Brush.Style := bsSolid;
    Grid.Canvas.Pen.Style := psSolid;
    Grid.Canvas.FillRect(rect);

    //Textposition:
    txtRect := Rect;
    focusRect := Rect;
    if ACol = 0 then
    begin
      txtRect.Left := Rect.left + BTN_WIDTH + DMImages.ImageListItemType.Width +
          4 * TXT_MARG.X + (node.Level-1) * LEVEL_MARGIN;
      focusRect.Left := txtRect.Left;
    end
//    else if ACol = 2 then
//    begin
//      txtRect.Right := Rect.Right - BTN_WIDTH - TXT_MARG.x - TXT_MARG.x;
//      txtRect.left := Rect.Left + TXT_MARG.x;
//    end
    else txtRect.Left := Rect.left + TXT_MARG.x;

    //Drawing selection:
    Grid.Canvas.Font.Style := [];
    if (gdSelected in State) then
    begin
      Grid.Canvas.Brush.Color := clbtnFace;
      Grid.Canvas.Font.Color := clBlue;
    end
    else
    begin
      Grid.Canvas.Brush.Color := clWindow;
      Grid.Canvas.Font.Color := clWindowText;
    end;
    Grid.canvas.FillRect(Rect);

    // Drawing image
    if ACol = ColName then
      DMImages.ImageListItemType.Draw(Grid.Canvas,
          txtRect.Left - DMImages.ImageListItemType.Width - TXT_MARG.X,
          txtRect.Top,
          GetItemTypeImageIndex(node.Item.ItemType));

    //Drawing text:
    st := GetTextData(ACol, ARow);
    Grid.Canvas.Font.Name := Grid.Font.Name;
    Grid.Canvas.Font.Size := Grid.Font.Size;
    DrawText(Grid.canvas.Handle, PChar(st), length(st),
             txtRect, DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);

    if ACol = 0 then
    begin
      if node.ChildCount <> 0 then
      begin
        if node.Children[0].Visible then
          st := '-'
        else st := '+';
        DrawButton(Grid, ACol, ARow, st, False, taLeftJustify, BTN_WIDTH,
            TXT_MARG.X);
      end;
    end;

    //If selected, draw focusrect:
    if gdSelected in State then
      with Grid.canvas do
      begin
        Pen.Style := psInsideFrame;
        Pen.Color := clBtnShadow;
        Polyline([Point(focusRect.left-1, focusRect.Top),
                  Point(focusRect.right-1, focusRect.Top)]);
        Polyline([Point(focusRect.left-1, focusRect.Bottom-1),
                  Point(focusRect.right-1, focusRect.Bottom-1)]);
        if ACol = 0 then
          Polyline([Point(focusRect.left-1, focusRect.Top),
                    Point(focusRect.left-1, focusRect.Bottom-1)])
        else if ACol = Grid.ColCount - 1 then
          Polyline([Point(focusRect.right-1, focusRect.Top),
                    Point(focusRect.right-1, focusRect.Bottom-1)]);
      end;
  end;

var txtRect   : TRect;
    btnRect   : TRect;
    btnState  : integer;
    st        : string;
    tmpstr    : string;
    tmpRect   : TRect;
    focusRect : TRect;
begin
  // HEADER
  if ARow < Grid.FixedRows then
    DrawHeader(ACol, ARow, Rect)

  // DATA
  else if ARow >= Grid.FixedRows then
    DrawData(ACol, ARow, Rect)

  else if ARow mod 4 = 1 then
  begin
    //Merging cell:
    rect.right := Grid.width;
    rect.Left := 0;

    //Setting canvas properties and erasing old cellcontent:
    Grid.Canvas.Brush.Color := clWindow;
    Grid.Canvas.Brush.Style := bsSolid;
    Grid.Canvas.Pen.Style := psClear;
    Grid.Canvas.FillRect(rect);

    //Textposition:
    txtRect := Rect;
    txtRect.Left := Rect.left + TXT_MARG.x;

    //Drawing text:
    st := GetTextData(ACol, ARow);
    Grid.Canvas.Font.Color := clInfoText; //clHighlightText;
    Grid.Canvas.Font.Name := Grid.Font.Name;
    Grid.Canvas.Font.Size := Grid.Font.Size;
    Grid.Canvas.Font.Style := [fsBold];
    DrawText(Grid.canvas.Handle, PChar(st),
             length(st), txtRect, DT_SINGLELINE or DT_LEFT or
             DT_VCENTER or DT_END_ELLIPSIS);

    //Drawing focusrect:
    if gdSelected in State then
    with Grid.canvas do begin
      Pen.Style := psInsideFrame;
      Pen.Color := clBtnShadow;
      Polyline([Point(Rect.left, Rect.Top),
                Point(Rect.right-1, Rect.Top)]);
      Polyline([Point(Rect.left, Rect.Bottom-1),
                Point(Rect.right-1, Rect.Bottom-1)]);
      if ACol = 0 then
        Polyline([Point(Rect.left, Rect.Top),
                  Point(Rect.left, Rect.Bottom-1)])
      else if ACol = Grid.ColCount - 1 then
        Polyline([Point(Rect.right-1, Rect.Top),
                  Point(Rect.right-1, Rect.Bottom-1)]);
    end
    else
    begin
      //If not selected, draw a line under subheading:
      Grid.Canvas.Pen.Style := psInsideFrame;
      Grid.Canvas.Pen.Color := clBlack;

      Grid.Canvas.Polyline
                ([Point(rect.Left + TXT_MARG.x, rect.bottom-1),
                 Point(rect.right, rect.bottom-1)]);
    end
  end
  //For the rest of the rows:
  else
  begin
    //Setting canvas properties and erasing old cellcontent:
    Grid.Canvas.Brush.Color := clWindow;
    Grid.Canvas.Brush.Style := bsSolid;
    Grid.Canvas.Pen.Style := psClear;
    Grid.Canvas.FillRect(rect);

    //Textposition:
    txtRect := Rect;
    focusRect := Rect;
    if ACol = 0 then
    begin
      txtRect.Left := Rect.left + BTN_WIDTH + TXT_MARG.x + TXT_MARG.x;
      focusRect.Left := txtRect.Left;
    end
    else if ACol = 2 then
    begin
      txtRect.Right := Rect.Right - BTN_WIDTH - TXT_MARG.x - TXT_MARG.x;
      txtRect.left := Rect.Left + TXT_MARG.x;
    end
    else
    begin
      txtRect.Left := Rect.left + TXT_MARG.x;
    end;


    //Drawing selection:
    Grid.Canvas.Font.Style := [];
    if (gdSelected in State) then
    begin
      Grid.Canvas.Brush.Color := clbtnFace;
      Grid.Canvas.Font.Color := clBlue;
    end
    else
    begin
      Grid.Canvas.Brush.Color := clWindow;
      Grid.Canvas.Font.Color := clWindowText;
    end;
    Grid.canvas.FillRect(Rect);
    //Drawing text:
    st := GetTextData(ACol, ARow);
    Grid.Canvas.Font.Name := Grid.Font.Name;
    Grid.Canvas.Font.Size := Grid.Font.Size;
    DrawText(Grid.canvas.Handle, PChar(st), length(st),
             txtRect, DT_SINGLELINE or DT_LEFT or DT_VCENTER or DT_END_ELLIPSIS);
    //Drawing buttons:
    if ACol = 0 then
    begin
      //Clear buttonarea:
      btnRect := GetGridBtnRect(Grid, ACol, ARow, True, taLeftJustify);
      Grid.canvas.Brush.Color := clWindow;
      Grid.canvas.FillRect(btnrect);
      //Get buttonposition and draw checkbox:
      btnRect := GetGridBtnRect(Grid, ACol, ARow, false, taLeftJustify);
      btnState := DFCS_BUTTONCHECK or DFCS_FLAT;
      if ARow mod 2 = 1 then
        btnState := btnState or DFCS_CHECKED;
      DrawFrameControl(Grid.canvas.handle, btnRect, DFC_BUTTON, btnState)
    end
    else if ACol = 2 then
    begin
      //Get buttonposition and draw button:
      btnRect := GetGridBtnRect(Grid, ACol, ARow, false, taLeftJustify);
      Grid.Canvas.Brush.Color := clBtnFace;
      Grid.Canvas.Pen.Style := psClear;
      Grid.Canvas.Rectangle(btnRect);
      DrawEdge(Grid.canvas.Handle, btnRect, EDGE_RAISED,
               BF_FLAT or BF_RECT or BF_ADJUST);
      Grid.Canvas.Font.Name := 'Arial';
      Grid.Canvas.Font.Size := 8;
      Grid.Canvas.Font.Color := clBlack;
      DrawText(Grid.canvas.Handle, '...', -1, btnRect,
               DT_SINGLELINE or DT_CENTER or DT_VCENTER);
    end
    else if ACol = 3 then
    begin
      //Get buttonposition and draw checkbox:
      btnRect := GetGridBtnRect(Grid, ACol, ARow, false, taLeftJustify);
      Grid.canvas.Brush.Color := clWindow;
      Grid.canvas.FillRect(btnrect);
      btnState := DFCS_BUTTONCHECK or DFCS_FLAT;
      DrawFrameControl(Grid.canvas.handle, btnRect, DFC_BUTTON, btnState)
    end;
    //If selected, draw focusrect:
    if gdSelected in State then
    with Grid.canvas do begin
      Pen.Style := psInsideFrame;
      Pen.Color := clBtnShadow;
      Polyline([Point(focusRect.left-1, focusRect.Top),
                Point(focusRect.right-1, focusRect.Top)]);
      Polyline([Point(focusRect.left-1, focusRect.Bottom-1),
                Point(focusRect.right-1, focusRect.Bottom-1)]);
      if ACol = 0 then
        Polyline([Point(focusRect.left-1, focusRect.Top),
                  Point(focusRect.left-1, focusRect.Bottom-1)])
      else if ACol = Grid.ColCount - 1 then
        Polyline([Point(focusRect.right-1, focusRect.Top),
                  Point(focusRect.right-1, focusRect.Bottom-1)]);
    end;
  end;
end;

procedure TWCompose.InitGrid;
begin
  Grid.ColWidths[ColName]:= 240;
  Grid.ColWidths[ColVerOrd]:= 64;
  Grid.ColWidths[ColVerNum]:= 64;
  Grid.ColWidths[ColDate]:= 64;
  Grid.ColWidths[ColHash]:= 240;
end;

procedure TWCompose.InitItemTypes;
var itemType: TItemType;
begin
  FItemTypes := [];
  for itemType := Low(TItemType) to High(TItemType) do
    FItemTypes := FItemTypes + [itemType];
end;

procedure TWCompose.SetDatabase(const Value: TpFIBDatabase);
begin
  FDatabase := Value;
end;

procedure TWCompose.SetDataModule(const Value: TDMCompose);
begin
  FDataModule := Value;
end;

procedure TWCompose.SetItems(const Value: TItemList);
begin
  FItems := Value;
end;

procedure TWCompose.SetItemTypes(const Value: TItemTypeSet);
begin
  if FItemTypes <> Value then
  begin
    FItemTypes := Value;
  end;
end;

procedure TWCompose.SetTransaction(const Value: TpFIBTransaction);
begin
  FTransaction := Value;
end;

procedure TWCompose.SetTransactionUpdate(const Value: TpFIBTransaction);
begin
  FTransactionUpdate := Value;
end;

procedure TWCompose.UpdateGrid(ARowCount: Integer);
begin
  Grid.RowCount := ARowCount + 1;
  if Grid.RowCount > 1 then
    Grid.FixedRows := 1;
  Grid.Invalidate;
end;

procedure TWCompose.UpdateItemTree;

  function UpdateItemBranch(AItem: TItem; AParentNode: TItemNode): TItemNode;
  var I: Integer;
  begin
    Result := TItemNode.Create(AParentNode);
    Result.Item := AItem;
    if AParentNode <> nil then
      Result.Level := AParentNode.Level + 1
    else Result.Level := 1;
    Result.Visible := (Result.Level <= 2);
    for I := 0 to AItem.ChildCount-1 do
      UpdateItemBranch(AItem.Children[I], Result);
  end;

begin
  if FRoot <> nil then
    FreeAndNil(FRoot);
  if FItem = nil then Exit;
  FRoot := UpdateItemBranch(FItem, nil)
end;

procedure TWCompose.UpdateLanguage;
begin
end;

end.
