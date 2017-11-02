unit UWItem;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UWMasterEdit, StdCtrls, ExtCtrls, DB, DBClient, DBCtrls, Mask;

type
  TWItem = class(TWMasterEdit)
    LabelName: TLabel;
    LabelAlias: TLabel;
    LabelType: TLabel;
    LabelPath: TLabel;
    EditName: TDBEdit;
    EditAlias: TDBEdit;
    EditPath: TDBEdit;
    DataSource: TDataSource;
    ComboBoxType: TDBComboBox;
  private
    FDataSet: TDataSet;
    procedure SetDataSet(const Value: TDataSet);
  public
    procedure UpdateLanguage; override;
    property DataSet: TDataSet read FDataSet write SetDataSet;
  end;

var
  WItem: TWItem;

implementation

uses
  Language.Interf;

{$R *.dfm}

{ TWItem }

procedure TWItem.SetDataSet(const Value: TDataSet);
begin
  FDataSet := Value;
  DataSource.DataSet := FDataSet;
end;

procedure TWItem.UpdateLanguage;
begin
  inherited;
  Caption := Cpt('Item');
end;

end.
