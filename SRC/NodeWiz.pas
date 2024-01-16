unit NodeWiz;

{$I DEFINE.INC}

interface

uses
  Forms, StdCtrls, mGrids, Controls, Classes;

type
  TNodeWizzardForm = class(TForm)
    gbNodelist: TGroupBox;
    llStat: TLabel;
    llSysop: TLabel;
    llSite: TLabel;
    llPhn: TLabel;
    llSpd: TLabel;
    llFlags: TLabel;
    llWrkTimeUTC: TLabel;
    gbNodeOvr: TGroupBox;
    eDupOvr: TEdit;
    lDupOvr: TLabel;
    bEditDupOvr: TButton;
    lIpOvr: TLabel;
    eIpOvr: TEdit;
    bEditIpOvr: TButton;
    gbRest: TGroupBox;
    lIpRest: TLabel;
    lbDialRest: TListBox;
    bEditDialRest: TButton;
    lbIpRest: TListBox;
    bEditIpRest: TButton;
    lDialRest: TLabel;
    gbEncLink: TGroupBox;
    bElSet: TButton;
    bElChange: TButton;
    bElRemove: TButton;
    gPsw: TAdvGrid;
    lPsw: TLabel;
    gbAkas: TGroupBox;
    lIpAKA: TLabel;
    lDialAKA: TLabel;
    lbDialAKA: TListBox;
    bEditDialAKA: TButton;
    lbIpAKA: TListBox;
    bEditIpAka: TButton;
    gbAtoms: TGroupBox;
    lbAtoms: TListBox;
    bEditEvents: TButton;
    lAtoms: TLabel;
    gbFbox: TGroupBox;
    eFileBoxIn: TEdit;
    lFboxIn: TLabel;
    lFboxOut: TLabel;
    eFileBoxOut: TEdit;
    gbPoll: TGroupBox;
    lPollPer: TLabel;
    lPollExt: TLabel;
    ePollExt: TEdit;
    ePollPer: TEdit;
    lPostProc: TLabel;
    ePostProc: TEdit;
    gbCurNode: TGroupBox;
    cbCurNode: TComboBox;
    bNewNode: TButton;
    bDeleteNode: TButton;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    lStation: TEdit;
    lSysop: TEdit;
    lLocation: TEdit;
    lPhone: TEdit;
    lSpeed: TEdit;
    lWrkTimeUTC: TEdit;
    lFlags: TEdit;
    lStatus: TEdit;
    procedure cbCurNodeClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bEditDupOvrClick(Sender: TObject);
    procedure bEditIpOvrClick(Sender: TObject);
    procedure bEditEventsClick(Sender: TObject);
    procedure bEditDialRestClick(Sender: TObject);
    procedure bEditIpRestClick(Sender: TObject);
    procedure bEditDialAKAClick(Sender: TObject);
    procedure bEditIpAkaClick(Sender: TObject);
    procedure bElSetClick(Sender: TObject);
    procedure bElChangeClick(Sender: TObject);
    procedure bElRemoveClick(Sender: TObject);
    procedure bNewNodeClick(Sender: TObject);
    procedure bDeleteNodeClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    Activated: Boolean;
    Fwc: Pointer;
    Fwr: Pointer;
    procedure SetData;
    function EditOverride(var s: string; ADialup: Boolean): Boolean;
    procedure SaveFields;
    procedure ProcessChanges;
  public
  end;


function InvokeNodeWizzard: Boolean;

implementation uses

  {$IFDEF WS}
  IpCfg,
  {$ENDIF}

  Recs, xBase, xFido, NdlUtil, OvrExpl, Events, SysUtils, Windows,
  DupCfg, PwdInput, xDES, AdrIBox, Outbound, LngTools;

{$R *.DFM}

function InvokeNodeWizzard: Boolean;
var
  NodeWizzardForm: TNodeWizzardForm;
begin
  NodeWizzardForm := TNodeWizzardForm.Create(Application);
  NodeWizzardForm.SetData;
  Result := NodeWizzardForm.ShowModal = mrOK;
  FreeObject(NodeWizzardForm);
  if Result then PostMsg(WM_SETUPOK);
end;

procedure TNodeWizzardForm.SetData;
var
  wc: TNodeWizzardColl;
  i: Integer;
  r: TNodeWizzardRec;
begin
  wc := TNodeWizzardColl.Create;
  BuildNodeWizzardColl(wc, True);
  Fwc := wc;
  for i := 0 to wc.Count-1 do
  begin
    r := wc[i];
    cbCurNode.Items.Add(Addr2Str(r.A));
  end;
  if cbCurNode.Items.Count > 0 then
  begin
    cbCurNode.ItemIndex := 0;
    cbCurNode.OnClick(Self);
  end;
end;


procedure TNodeWizzardForm.cbCurNodeClick(Sender: TObject);
var
  i, j: Integer;
  wc: TNodeWizzardColl;
  r: TNodeWizzardRec;
  fn: TFidoNode;
  nm: TNamed;
begin
  SaveFields;
  i := cbCurNode.ItemIndex;
  if i < 0 then
  begin
    if cbCurNode.Items.Count = 0 then
    begin
      Fwr := nil;
      Exit;
    end else
    begin
      cbCurNode.ItemIndex := 0;
      i := 0;
    end;
  end;
  wc := Fwc;
  r := wc[i];
  if r = Fwr then Exit;
  Fwr := r;
  fn := GetListedNode(r.A);
  if fn = nil then
  begin
    lStation.Text := '';
    lSysop.Text := '';
    lLocation.Text := '';
    lPhone.Text := '';
    lSpeed.Text := '';
    lFlags.Text := '';
    lWrkTimeUTC.Text := '';
    lWrkTimeUTC.Hint := '';
    llWrkTimeUTC.Hint := '';
    lStatus.Text := '';
  end else
  begin
    lStation.Text := fn.Station;
    lSysop.Text := fn.Sysop;
    lLocation.Text := fn.Location;
    lPhone.Text := fn.Phone;
    lSpeed.Text := IntToStr(fn.Speed);
    lFlags.Text := fn.Flags;
    lStatus.Text := cNodePrefixFlag[fn.PrefixFlag];
    lWrkTimeUTC.Text := FSC62TimeToStr(NodeFSC62TimeEx(fn.Flags, fn.Addr, False));
    lWrkTimeUTC.Hint := 'Time (Local): '+FSC62TimeToStr(NodeFSC62TimeEx(fn.Flags, fn.Addr, True));
    llWrkTimeUTC.Hint := lWrkTimeUTC.Hint;
  end;
  lbAtoms.Items.Clear;
  for i := 0 to CollMax(r.EvtIds) do
  begin
    j := Integer(r.EvtIds[i]);
    nm := TNamed(Cfg.Events.GetRecById(j));
    lbAtoms.Items.Add(nm.Name);
  end;

  lbDialRest.Items.Clear;
  for i := 0 to CollMax(r.DialRestIds) do
  begin
    j := Integer(r.DialRestIds[i]);
    nm := TNamed(Cfg.Restrictions.GetRecById(j));
    lbDialRest.Items.Add(nm.Name);
  end;

  lbDialAKA.Items.Clear;
  for i := 0 to CollMax(r.AkaStationIds) do
  begin
    j := Integer(r.AkaStationIds[i]);
    nm := TNamed(Cfg.Station.GetRecById(j));
    lbDialAKA.Items.Add(nm.Name);
  end;

  lbIpRest.Items.Clear;
  if r.IsDaemonRest then lbIpRest.Items.Add('Daemon');

  lbIpAKA.Items.Clear;
  if r.IsDaemonAKA then lbIpAKA.Items.Add('Daemon');

  eDupOvr.Text := r.DupOvr;
  eIpOvr.Text := r.IpOvr;
  eFileBoxIn.Text := r.FBoxIn;
  eFileBoxOut.Text := r.FBoxOut;
  ePollPer.Text := r.PollPer;
  ePollExt.Text := r.PollExt;
  ePostProc.Text := r.PostProc;

  gPsw.Cells[0,0] := r.Password;

  bElSet.Enabled := not r.IsEncryptedLink;
  bElChange.Enabled := r.IsEncryptedLink;
  bElRemove.Enabled := r.IsEncryptedLink;

end;

procedure TNodeWizzardForm.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  Activated := True;
  gPsw.PasswordCol := 0;
  gPsw.DefaultColWidth := gPsw.ClientWidth;
  gPsw.ClientHeight := gPsw.DefaultRowHeight;
  lbIpRest.ClientHeight := lbIpRest.ItemHeight;
  lbIpAka.ClientHeight := lbIpAka.ItemHeight;
end;

procedure TNodeWizzardForm.FormDestroy(Sender: TObject);
begin
  FreeObject(Fwc);
end;

function TNodeWizzardForm.EditOverride(var s: string; ADialup: Boolean): Boolean;
var
  C: TColl;
  Msg, Item: string;
  wr: TNodeWizzardRec;
begin
  Result := False;
  wr := Fwr;
  C := ParseOverride(s, Msg, Item, ADialup);
  if Msg <> '' then
  begin
    WinDlgCap(Msg, MB_OK or MB_ICONERROR, Handle, Item);
  end else
  begin
    Result := EditOverrideEx(C, ADialup, wr.A);
    if Result then s := OvrColl2Str(C);
  end;
  FreeObject(C);
end;


procedure TNodeWizzardForm.bEditDupOvrClick(Sender: TObject);
var
  s: string;
begin
  s := eDupOvr.Text;
  if EditOverride(s, True) then eDupOvr.Text := s;
end;

procedure TNodeWizzardForm.bEditIpOvrClick(Sender: TObject);
var
  s: string;
begin
  s := eIpOvr.Text;
  if EditOverride(s, False) then eIpOvr.Text := s;
end;

procedure TNodeWizzardForm.SaveFields;
var
  r: TNodeWizzardRec;
begin
  if Fwr = nil then Exit;
  r := Fwr;
  r.Password := Trim(gPsw.Cells[0,0]);
  r.DupOvr := Trim(eDupOvr.Text);
  r.IpOvr := Trim(eIpOvr.Text);
  r.FBoxIn := Trim(eFileBoxIn.Text);
  r.FBoxOut := Trim(eFileBoxOut.Text);
  r.PollPer := Trim(ePollPer.Text);
  r.PollExt := Trim(ePollExt.Text);
  r.PostProc := Trim(ePostProc.Text);
end;


procedure TNodeWizzardForm.ProcessChanges;
begin
  BuildNodeWizzardColl(Fwc, False);
  Fwr := nil;
  cbCurNode.OnClick(Self);
end;

procedure TNodeWizzardForm.bEditEventsClick(Sender: TObject);
begin
  if SetupEvents then ProcessChanges;
end;

procedure TNodeWizzardForm.bEditDialRestClick(Sender: TObject);
begin
  if DialupSetup(4) then ProcessChanges;
end;

procedure TNodeWizzardForm.bEditIpRestClick(Sender: TObject);
begin
  {$IFDEF WS}
  if SetupIp(4) then ProcessChanges;
  {$ENDIF}
end;

procedure TNodeWizzardForm.bEditDialAKAClick(Sender: TObject);
begin
  if DialupSetup(1) then ProcessChanges;
end;

procedure TNodeWizzardForm.bEditIpAkaClick(Sender: TObject);
begin
  {$IFDEF WS}
  if SetupIp(2) then ProcessChanges;
  {$ENDIF}
end;

procedure TNodeWizzardForm.bElSetClick(Sender: TObject);
var
  en: TEncryptedNodeData;
  r: TNodeWizzardRec;
  s: string;
begin
  r := Fwr;
  if r = nil then Exit;
  s := Addr2Str(r.A);
  if r.IsEncryptedLink then GlobalFail('%s is already encrypted', [s]);
  en := TEncryptedNodeData.Create;
  en.Addr := r.A;
  if not InputNewPwd(en.Key, FormatLng(rsNWStElP, [s]), True, IDH_BINKPENC) then
  begin
    FreeObject(en);
    Exit;
  end;
  CfgEnter;
  Cfg.EncryptedNodes.Insert(en);
  CfgLeave;
  if StoreConfig(Handle) then ProcessChanges else PostCloseMessage;
end;

procedure TNodeWizzardForm.bElChangeClick(Sender: TObject);
var
  en: TEncryptedNodeData;
  r: TNodeWizzardRec;
  s: string;
  Key: TDesBlock;
  i: Integer;
begin
  r := Fwr;
  if r = nil then Exit;
  s := Addr2Str(r.A);
  if not r.IsEncryptedLink then GlobalFail('%s is not encrypted', [s]);
  if not InputNewPwd(Key, FormatLng(rsNWChElP, [s]), True, IDH_BINKPENC) then Exit;
  CfgEnter;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    en := Cfg.EncryptedNodes[i];
    if CompareAddrs(r.A, en.Addr) = 0 then
    begin
      en.Key := Key;
      Break;
    end;
  end;
  CfgLeave;
  if StoreConfig(Handle) then ProcessChanges else PostCloseMessage;
end;

procedure TNodeWizzardForm.bElRemoveClick(Sender: TObject);
var
  en: TEncryptedNodeData;
  r: TNodeWizzardRec;
  s: string;
  i: Integer;
begin
  r := Fwr;
  if r = nil then Exit;
  s := Addr2Str(r.A);
  if not r.IsEncryptedLink then GlobalFail('%s is not encrypted', [s]);
  if not YesNoConfirm(FormatLng(rsNWCfmElP, [s]), Handle) then Exit;
  CfgEnter;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    en := Cfg.EncryptedNodes[i];
    if CompareAddrs(r.A, en.Addr) = 0 then
    begin
      Cfg.EncryptedNodes.AtFree(i);
      Break;
    end;
  end;
  CfgLeave;
  if StoreConfig(Handle) then ProcessChanges else PostCloseMessage;
end;

procedure TNodeWizzardForm.bNewNodeClick(Sender: TObject);
var
  A: TFidoAddress;
  ps: Integer;
  wc: TNodeWizzardColl;
  r: TNodeWizzardRec;
begin
  if not InputSingleAddress(LngStr(rsNWNN), A, nil) then Exit;
  wc := Fwc;
  if wc.Search(@A, ps) then
  begin
    cbCurNode.ItemIndex := ps;
    cbCurNode.OnClick(Sender);
    DisplayInfoLng(rsNWNE, Handle);
    Exit;
  end;
  r := TNodeWizzardRec.Create;
  r.A := A;
  wc.AtInsert(ps, r);
  cbCurNode.Items.Insert(ps, Addr2Str(A));
  cbCurNode.ItemIndex := ps;
  cbCurNode.OnClick(Sender);
end;

function StrListToStrAnd(L: TStringList): string;
var
  s: string;
  i: Integer;
begin
  s := '';
  if L.Count > 0 then
  begin
    s := L[0];
    for i := 1 to L.Count-2 do s := s + ', ' + L[i];
    if L.Count > 1 then s := s + LngStr(rsNWand) + L[L.Count-1];
  end;
  Result := s;
end;

procedure TNodeWizzardForm.bDeleteNodeClick(Sender: TObject);
var
  L: TStringList;
  s: string;
  ps: Integer;
  r: TNodeWizzardRec;
  wc: TNodeWizzardColl;

procedure AddL(id: Integer);
begin
  L.Add(LngStr(id));
end;

begin
  L := TStringList.Create;
  if lbAtoms.Items.Count > 0 then AddL(rsNW_events);
  if lbDialRest.Items.Count > 0 then AddL(rsNW_dialrest);
  if lbIpRest.Items.Count > 0 then AddL(rsNW_iprest);
  if lbDialAKA.Items.Count > 0 then AddL(rsNW_dupaka);
  if lbIpAKA.Items.Count > 0 then AddL(rsNW_ipaka);
  if L.Count > 0 then
  begin
    s := StrListToStrAnd(L);
    FreeObject(L);
    DisplayError(FormatLng(rsNWRBfD, [s]), Handle);
    Exit;
  end;
  SaveFields;
  r := Fwr;
  if r = nil then Exit;
  if r.IsEncryptedLink then AddL(rsNW_enclink);
  if r.Password <> '' then AddL(rsNW_basicpwd);
  if r.DupOvr <> '' then AddL(rsNW_dupovr);
  if r.IpOvr <> '' then AddL(rsNW_ipovr);
  if r.FBoxIn <> '' then AddL(rsNW_infbox);
  if r.FBoxOut <> '' then AddL(rsNW_outfbox);
  if r.PollPer <> '' then AddL(rsNW_ppoll);
  if r.PollExt <> '' then AddL(rsNW_extpoll);
  if r.PostProc <> '' then AddL(rsNW_postp);
  wc := Fwc;
  if not wc.Search(@r.a, ps) then GlobalFail('TNodeWizzardForm.bDeleteNodeClick(%s) - node not found', [Addr2Str(r.A)]);
  if L.Count = 0 then
  begin
    FreeObject(L);
    wc.AtFree(ps);
    Fwr := nil;
    cbCurNode.Items.Delete(ps);
    cbCurNode.OnClick(Sender);
    Exit;
  end;
  s := StrListToStrAnd(L);
  FreeObject(L);
  if not YesNoConfirm(FormatLng(rsNWCfmDelNC, [Addr2Str(r.A), s]), Handle) then Exit;
  r.FinalizeStrs;
  r.IsEncryptedLink := False;
  SaveNodeWizzardColl(nil, r);
  wc.AtFree(ps);
  Fwr := nil;
  cbCurNode.Items.Delete(ps);
  cbCurNode.OnClick(Sender);
  if not StoreConfig(Handle) then PostCloseMessage;
end;

procedure TNodeWizzardForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  i: Integer;

procedure ClickIn;
begin
  CanClose := False;
  cbCurNode.ItemIndex := i;
  cbCurNode.OnClick(Sender);
end;

var
  wc: TNodeWizzardColl;
  r: TNodeWizzardRec;
  s, z: string;
  fb: TFileBoxCfg;
  fbdc: TFileBoxDirColl;
begin
  if ModalResult <> mrOK then Exit;
  SaveFields;
  wc := Fwc;
  fbdc := TFileBoxDirColl.Create;
  for i := 0 to wc.Count-1 do
  begin
    r := wc[i];
    if r.DupOvr <> '' then
    begin
      s := ValidOverride(r.DupOvr, True, z);
      if s <> '' then
      begin
        ClickIn;
        DisplayError(FormatLng(rsNWInvDupOvrI, [z, s]), Handle);
        Break;
      end;
    end;
    if r.IpOvr <> '' then
    begin
      s := ValidOverride(r.IpOvr, False, z);
      if s <> '' then
      begin
        ClickIn;
        DisplayError(FormatLng(rsNWInvIpOvrI, [z, s]), Handle);
        Break;
      end;
    end;
    if r.FBoxOut <> '' then
    begin
      s := r.FBoxOut;
      GetWrd(s, z, '|');
      if (s = '') or (z = '') then Continue;
      fb := TFileBoxCfg.Create;
      fb.FAddr := Addr2Str(r.A);
      fb.FStatus := Char2OutStatus(z[1]);
      fb.FDir := s;
      if not GetFileBoxDirColl(fb.FAddr, fb.Dir(Cfg.FileBoxes.DefaultDir, 0), fb.FStatus, fbdc, @s, nil, nil) then
      begin
        FreeObject(fb);
        ClickIn;
        DisplayError(s, Handle);
        Break;
      end;
      FreeObject(fb);
    end;
    if r.PollPer <> '' then
    begin
      s := ValidCronRecStr(r.PollPer);
      if s <> '' then
      begin
        ClickIn;
        DisplayError(s, Handle);
        Break;
      end;
    end;
  end;
  FreeObject(fbdc);
end;

procedure TNodeWizzardForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  SaveNodeWizzardColl(Fwc, nil);
  FreeObject(Fwc);
  if not StoreConfig(Handle) then PostCloseMessage;
end;

procedure TNodeWizzardForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsNodeWizzardForm); 
end;

procedure TNodeWizzardForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.


