unit Extrnls;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  mGrids, StdCtrls, ComCtrls;

type
  TExternalsForm = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    bImportPwd: TButton;
    PageControl: TPageControl;
    tsPP: TTabSheet;
    tsDrs: TTabSheet;
    gExt: TAdvGrid;
    gDrs: TAdvGrid;
    tsCron: TTabSheet;
    gCrn: TAdvGrid;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    Activated: Boolean;
    procedure SetData;
  public
  end;


function ConfigureExternals: Boolean;

implementation uses Recs, xBase, LngTools;

{$R *.DFM}

function ConfigureExternals: Boolean;
var
  ExternalsForm: TExternalsForm;
begin
  ExternalsForm := TExternalsForm.Create(Application);
  ExternalsForm.SetData;
  Result := ExternalsForm.ShowModal = mrOK;
  FreeObject(ExternalsForm);
end;

procedure TExternalsForm.SetData;
begin
  gExt.SetData([Cfg.ExtCollA, Cfg.ExtCollB]);
  gDrs.SetData([Cfg.DrsCollA, Cfg.DrsCollB]);
  gCrn.SetData([Cfg.CrnCollA, Cfg.CrnCollB]);
end;

procedure TExternalsForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
  if (gCrn.RowCount = 2) and (gCrn[1,1]='') and (gCrn[2,1]='') then Exit;
  CanClose := CronGridValid(gCrn); 
end;

procedure TExternalsForm.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  Activated := True;
  GridFillColLng(gExt, rsExtExt);
  GridFillColLng(gDrs, rsExtDrs);
  GridFillColLng(gCrn, rsExtCrn);
end;

procedure TExternalsForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TExternalsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  CfgEnter;
  gExt.GetData([Cfg.ExtCollA, Cfg.ExtCollB]);
  gDrs.GetData([Cfg.DrsCollA, Cfg.DrsCollB]);
  gCrn.GetData([Cfg.CrnCollA, Cfg.CrnCollB]);
  CfgLeave;
  StoreConfig(Handle);
end;

procedure TExternalsForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsExternalsForm);
end;

end.
