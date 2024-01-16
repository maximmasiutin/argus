unit DialRest;

{$I DEFINE.INC}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, Recs, ComCtrls, mGrids;

type
  TRestrictCfgForm = class(TForm)
    lName: TEdit;
    llName: TLabel;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    p: TPageControl;
    tsRequired: TTabSheet;
    tsForbidden: TTabSheet;
    gReqd: TAdvGrid;
    gForb: TAdvGrid;
    bExplain: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure bExplainClick(Sender: TObject);
  private
    Restriction: TRestrictionRec;
    procedure SetData;
  end;

function EditRestriction(Restriction: Pointer): Boolean;

implementation uses xBase, LngTools, xFido, TracePl;

{$R *.DFM}

function EditRestriction(Restriction: Pointer): Boolean;
var
  RestrictCfgForm: TRestrictCfgForm;
begin
  RestrictCfgForm := TRestrictCfgForm.Create(Application);
  RestrictCfgForm.Restriction := Restriction;
  RestrictCfgForm.SetData;
  Result := RestrictCfgForm.ShowModal = mrOK;
  FreeObject(RestrictCfgForm);
end;

procedure TRestrictCfgForm.SetData;
begin
  lName.Text := Restriction.Name;
  Caption := Caption + ' - ' + Restriction.Name;
  gReqd.SetData(Restriction.Data.Required);
  gForb.SetData(Restriction.Data.Forbidden);
end;

procedure TRestrictCfgForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  Restriction.FName := lName.Text;
end;

procedure TRestrictCfgForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TRestrictCfgForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
  gReqd.GetData(Restriction.Data.Required);
  gForb.GetData(Restriction.Data.Forbidden);
  CanClose := ValidDialupRestrictionData(Restriction.Data, Handle);
end;

procedure TRestrictCfgForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsRestrictCfgForm);
end;


procedure TRestrictCfgForm.bExplainClick(Sender: TObject);
var
  Strs: TStringColl;
  d: TRestrictionData;
begin
  d := TRestrictionData.Create;
  gReqd.GetData(d.Required);
  gForb.GetData(d.Forbidden);
  if not ValidDialupRestrictionData(d, Handle) then
  begin
    FreeObject(d);
    Exit;
  end;
  Strs := TStringColl.Create;
  ReportRestrictionData(Strs, d);
  FreeObject(d);
  DisplayInfoFormEx(FormatLng(rsDialRestCap, [Restriction.Name]), Strs);
  FreeObject(Strs);
end;

end.
