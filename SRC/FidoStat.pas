unit FidoStat;

interface

{$I DEFINE.INC}


uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, mGrids, Recs, ComCtrls;

type
  TFidoTemplateEditor = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    lTplName: TLabel;
    lName: TEdit;
    PageControl: TPageControl;
    tsEMSI: TTabSheet;
    tsBanner: TTabSheet;
    gTpl: TAdvGrid;
    eBan: TMemo;
    tsAKA: TTabSheet;
    gAKA: TAdvGrid;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Activated: Boolean;
  public
    Station: TStationRec;
    procedure SetData;
  end;


function EditStation(Station: Pointer):Boolean;


implementation uses xBase, xFido, LngTools;

{$R *.DFM}

procedure TFidoTemplateEditor.SetData;
begin
  lName.Text := Station.FName;
  gTpl.SetData([Station.Data]);
  eBan.SetTextBuf(PChar(Station.Banner));
  gAKA.SetData([Station.AkaA, Station.AkaB]);
end;

function EditStation;
var
  FidoTemplateEditor: TFidoTemplateEditor;
begin
  FidoTemplateEditor := TFidoTemplateEditor.Create(Application);
  FidoTemplateEditor.Station := Station;
  FidoTemplateEditor.SetData;
  Result := FidoTemplateEditor.ShowModal = mrOK;
  FreeObject(FidoTemplateEditor);
end;


procedure TFidoTemplateEditor.FormActivate(Sender: TObject);
begin
  if not Activated then
  begin
    GridFillRowLng(gTpl, rsStatGrid);
    GridFillColLng(gAKA, rsStatAKA); 
    Activated := True;
  end;
end;

procedure TFidoTemplateEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  Station.FName := lName.Text;
  gTpl.GetData([Station.Data]);
  Station.Banner := ControlString(eBan);
  gAKA.GetData([Station.AkaA, Station.AkaB]);
end;

procedure TFidoTemplateEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
  CanClose := False;
  if not ValidateAddrs(gTpl[1,1], Handle) then Exit;
  if not ValidAKAGrid(gAKA) then Exit;
  CanClose := True;
end;

procedure TFidoTemplateEditor.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TFidoTemplateEditor.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsFidoTemplateEditor);
end;

end.


