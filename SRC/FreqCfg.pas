unit FreqCfg;

{$I DEFINE.INC}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, mGrids, Recs;

type
  TFreqCfgForm = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    PageControl: TPageControl;
    pGeneral: TTabSheet;
    gDirs: TAdvGrid;
    Aliases: TTabSheet;
    gAls: TAdvGrid;
    cbRecursive: TCheckBox;
    cbMasks: TCheckBox;
    cbDisable: TCheckBox;
    cbSRIF: TCheckBox;
    lSRIF: TEdit;
    llSRIF: TLabel;
    llGrid: TLabel;
    llAls: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbSRIFClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    Activated: Boolean;
    OldOptions: TFreqOptions;
    CommonCrc: DWORD;
    procedure SetData;
    procedure UpdateSRIF;
    function NoDupes(AC: Pointer; G: TAdvGrid; Cap: string): Boolean;
  end;

function SetupFileRequests: Boolean;

implementation uses xBase, LngTools;

{$R *.DFM}

function Crc: DWORD;
begin with Cfg.FreqData do begin
  Result := Misc.Crc32(pnPaths.Crc32(pnPsw.Crc32(alNames.Crc32(alPaths.Crc32(alPsw.Crc32(CRC32_INIT))))));
end end;

procedure TFreqCfgForm.FormActivate(Sender: TObject);
begin
  if not Activated then
  begin
    GridFillColLng(gDirs, rsFreqDirs);
    GridFillColLng(gAls, rsFreqAls);
    Activated := True;
  end;
end;

function SetupFileRequests;
var
  FreqCfgForm: TFreqCfgForm;
begin
  FreqCfgForm := TFreqCfgForm.Create(Application);
  FreqCfgForm.SetData;
  Result := FreqCfgForm.ShowModal = mrOK;
  FreeObject(FreqCfgForm);
end;


procedure TFreqCfgForm.SetData;
begin
  with Cfg.FreqData do
  begin
    cbDisable.Checked := foDisable in Options;
    cbRecursive.Checked := foRecursive in Options;
    cbMasks.Checked := foMasks in Options;
    cbSRIF.Checked := foSRIF in Options;
    if Misc.Count > 0 then lSRIF.Text := Misc[0];
    gDirs.SetData([pnPaths, pnPsw]);
    gAls.SetData([alNames, alPaths, alPsw]);
    OldOptions := Options;
    CommonCrc := Crc;
  end;
  UpdateSRIF;
end;

procedure TFreqCfgForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  with Cfg.FreqData do
  begin
    CfgEnter;
    gDirs.GetData([pnPaths, pnPsw]);
    gAls.GetData([alNames, alPaths, alPsw]);
    Options := [];
    if cbDisable.Checked then Include(Options, foDisable);
    if cbRecursive.Checked then Include(Options, foRecursive);
    if cbMasks.Checked then Include(Options, foMasks);
    if cbSRIF.Checked then Include(Options, foSRIF);
    Misc[0] := lSRIF.Text;
    CfgLeave;
    if (Options = OldOptions) and (CommonCrc = Crc) then Exit;
  end;
  StoreConfig(Handle);
end;

procedure TFreqCfgForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TFreqCfgForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsFreqCfgForm);
  gDirs.PasswordCol := 2;
  gAls.PasswordCol := 3;
end;

procedure TFreqCfgForm.UpdateSRIF;
var
  B: Boolean;
begin
  B := cbSRIF.Checked;
  lSRIF.Enabled := B;
  llSRIF.Enabled := B;
  B := not B;
  llGrid.Enabled := B;
  llAls.Enabled := B;
  gDirs.Enabled := B;
  gAls.Enabled := B;
  cbRecursive.Enabled := B;
  cbMasks.Enabled := B;
end;


procedure TFreqCfgForm.cbSRIFClick(Sender: TObject);
begin
  UpdateSRIF;
end;

function HaveDuplicates(C: TStringColl; var F, L: Integer): Boolean;
var
  i, j, m: Integer;
  s: string;
begin
  Result := False;
  m := CollMax(C);
  for i := 0 to m do C[i] := UpperCase(C[i]);
  for i := 0 to m do
  begin
    s := C[i];
    for j := i+1 to m do
    begin
      if s = C[j] then
      begin
        Result := True;
        F := i;
        L := j;
        Break;
      end;
    end;
    if Result then Break;
  end;
end;

function TFreqCfgForm.NoDupes(AC: Pointer; G: TAdvGrid; Cap: string): Boolean;
var
  FR, F, L: Integer;
  C: TStringColl;
begin
  C := AC;
  Result := not HaveDuplicates(C, F, L);
  if Result then Exit;
  PageControl.ActivePage := G.Parent as TTabSheet;
  FR := G.FixedRows;
  if G.Enabled then
  begin
    G.SetFocus;
    G.Row := L + FR;
  end;
  DisplayError(Format('%s on line %d is already specified on line %d', [Cap, L+FR, F+FR]), Handle);
end;

procedure TFreqCfgForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  pnPaths, pnPsw, alNames, alPaths, alPsw: TStringColl;
begin
  pnPaths  := TStringColl.Create;
  pnPsw    := TStringColl.Create;
  alNames  := TStringColl.Create;
  alPaths  := TStringColl.Create;
  alPsw    := TStringColl.Create;
  gDirs.GetData([pnPaths, pnPsw]);
  gAls.GetData([alNames, alPaths, alPsw]);
  CanClose := (NoDupes(pnPaths, gDirs, gDirs[1, 0])) and (NoDupes(alNames, gAls, gAls[1, 0]));
  FreeObject(pnPaths);
  FreeObject(pnPsw);
  FreeObject(alNames);
  FreeObject(alPaths);
  FreeObject(alPsw);
end;

end.
