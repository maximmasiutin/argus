unit ModemCfg;

interface

{$I DEFINE.INC}


uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls, 
  StdCtrls, ExtCtrls, Forms, ComCtrls, 
  MClasses, xBase, mGrids, Recs, xFido;

type
  TModemEditor = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    pg: TPageControl;
    General: TTabSheet;
    llName: TLabel;
    lName: TEdit;
    gCmd: TAdvGrid;
    llCmds: TLabel;
    Responses: TTabSheet;
    gStd: TAdvGrid;
    Flags: TTabSheet;
    gFlg: TAdvGrid;
    tsFax: TTabSheet;
    gbIntFax: TGroupBox;
    cbDTE: TCheckBox;
    gbExt: TGroupBox;
    lFax: TEdit;
    lExtR: TLabel;
    rgExt: TRadioGroup;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure rgExtClick(Sender: TObject);
  private
    OldStrs: array[0..MaxModemCmdIdx] of string;
    Activated: Boolean;
    Modem: TModemRec;
    procedure SetData;
    procedure InvalidateCbExt;
  end;


function EditModem(Modem: Pointer): Boolean;

implementation uses LngTools;

{$R *.DFM}

procedure TModemEditor.FormActivate(Sender: TObject);
begin
  if not Activated then
  begin
    GridFillRowLng(gStd, rsMdmCfgStd);
    GridFillRowLng(gCmd, rsMdmCfgCmd);
    GridFillColLng(gFlg, rsMdmCfgFlg);
    Activated := True;
  end;
end;

function EditModem(Modem: Pointer): Boolean;
var
  ModemEditor: TModemEditor;
begin
  ModemEditor := TModemEditor.Create(Application);
  ModemEditor.Modem := Modem;
  ModemEditor.SetData;
  Result := ModemEditor.ShowModal = mrOK;
  FreeObject(ModemEditor);
end;

procedure TModemEditor.SetData;
var
  i: Integer;
begin
  lName.Text := Modem.FName;
  lFax.Text := Modem.FaxApp;
  if moUseExternal in Modem.Options then rgExt.ItemIndex := 0 else rgExt.ItemIndex := 1;
  cbDTE.Checked := moSwitchDTE in Modem.Options;
  InvalidateCbExt;
  gCmd.SetData([Modem.Cmds]);
  gStd.SetData([Modem.StdResp]);
  gFlg.SetData([Modem.FlagsA, Modem.FlagsB]);
  for i := Low(OldStrs) to High(OldStrs) do OldStrs[i] := Modem.Cmds[i];
end;


procedure TModemEditor.FormClose(Sender: TObject; var Action: TCloseAction);
var
  o : TModemOptions;
begin
  if ModalResult <> mrOK then Exit;
  Modem.FName := lName.Text;
  Modem.FaxApp := lFax.Text;
  o := [];
  if rgExt.ItemIndex = 0 then Include(o, moUseExternal);
  if cbDTE.Checked then Include(o, moSwitchDTE);
  Modem.Options := o;
  gCmd.GetData([Modem.Cmds]);
  gStd.GetData([Modem.StdResp]);
  gFlg.GetData([Modem.FlagsA, Modem.FlagsB]);
end;

procedure TModemEditor.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TModemEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;
  z: string;
begin
  if ModalResult <> mrOK then Exit;
  CanClose := False;
  for i := 0 to MaxModemCmdIdx do
  begin
    z := gCmd[1, i];
    if z = OldStrs[i] then Continue;
    if not ValidModemCmd(i, z, Format('%s String', [_DelSpaces(gCmd[0, i])]), Handle) then Exit;
    OldStrs[i] := z;     
  end;
  CanClose := True;
end;



procedure TModemEditor.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsModemEditor);
end;


procedure TModemEditor.InvalidateCbExt;
const
  ER: array[Boolean] of Integer = (rsMdmCPPS, rsMdmERS);
var
  B: Boolean;
begin
  B := rgExt.ItemIndex = 0;

  gbExt.Caption := LngStr(ER[B]);

  gbIntFax.Enabled := not B;
  cbDTE.Enabled := not B;
end;


procedure TModemEditor.rgExtClick(Sender: TObject);
begin
  InvalidateCbExt;
end;

end.
