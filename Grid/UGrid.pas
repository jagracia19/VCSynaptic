unit UGrid;

interface

uses
  Windows, Classes, Grids;

//const
//  TXT_MARG    : TPoint = (x: 4; y: 2);
//  BTN_WIDTH   = 12;
//  DIB_MARG_X  = 1;


// Obtener rectangulo boton de un grid
function GetGridBtnRect(Grid: TDrawGrid; ACol, ARow: integer; Complete: boolean;
  Alignment: TAlignment; BtnWidth: integer = 12; TxtMargX: integer  =4): TRect;


implementation

// Obtener rectangulo boton de un grid
function GetGridBtnRect(Grid: TDrawGrid; ACol, ARow: integer; Complete: boolean;
  Alignment: TAlignment; BtnWidth: integer = 12; TxtMargX: integer  =4): TRect;

  function MakeBtnRect(Alignment: TAlignment; CellRect: TRect;
    Complete: boolean): TRect;
  var rowHeight: integer;
  begin
    result := CellRect;
    rowHeight := CellRect.bottom - CellRect.top;
    case Alignment of
      taLeftJustify:
        begin
          result.Right := CellRect.left + BtnWidth + TxtMargX + (TxtMargX div 2);
          if not Complete then
          begin
            result.Top    := CellRect.Top + ((RowHeight - BtnWidth) div 2);
            result.Left   := CellRect.Left + ((RowHeight - BtnWidth) div 2);
            result.Bottom := result.Top + BtnWidth;
            result.Right  := result.Left + BtnWidth;
          end;
        end;
      taRightJustify:
        begin
          result.Left := CellRect.Right - BtnWidth - TxtMargX - TxtMargX;
          if result.left < CellRect.left then
            result.left := CellRect.left;
          if not Complete then
          begin
            result.top    := CellRect.top + ((RowHeight - BtnWidth) div 2);
            result.left   := result.left + TxtMargX;
            result.right  := Result.left + BtnWidth;
            result.Bottom := result.top + BtnWidth;
          end;
        end;
      taCenter:
        begin
          result.left := result.left + ((CellRect.Right - CellRect.left) div 2) - (BtnWidth div 2) - TxtMargX;
          if result.left < CellRect.Left then
            result.left := CellRect.left;
          result.right := result.left + BtnWidth + TxtMargX + TxtMargX;
          if not Complete then
          begin
            result.Top    := CellRect.Top + ((RowHeight - BtnWidth) div 2);
            result.Left   := result.Left + TxtMargX;
            result.Bottom := result.Top + BtnWidth;
            result.Right  := result.Left + BtnWidth;
          end;
        end;
    end;
  end;

var cellrect: TRect;
begin
  Result := Rect(0, 0, 0, 0);

  // get complete cellrect for the current cell
  cellrect := Grid.CellRect(ACol, ARow);

  // last visible row sometimes get truncated so we need to fix that
  if (cellrect.Bottom - cellrect.Top) < Grid.DefaultRowHeight then
    cellrect.Bottom := cellrect.top + Grid.DefaultRowHeight;

  {if ARow = 0 then
    // first row (header) has a rightaligned sort button:
    Result := MakeBtnRect(taRightJustify, cellrect, complete)
  else}
    // additional lines have three buttons:
    Result := MakeBtnRect(Alignment, cellrect, complete);
end;

end.
