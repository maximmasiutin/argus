unit DUPCfg;

{$I DEFINE.INC}


interface              


 
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, ComCtrls, Recs, xBase, mGrids, Menus, ImgList;

type

  TMainConfigForm = class(TForm)
    pg: TPageControl;
    tsLines: TTabSheet;
    tsPorts: TTabSheet;
    tsModems: TTabSheet;
    tsRestrictions: TTabSheet;
    tsStation: TTabSheet;
    bNew: TButton;
    bEdit: TButton;
    bCopy: TButton;
    bDefault: TButton;
    bDelete: TButton;
    bUndelete: TButton;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    lLines: TListView;
    lStation: TListView;
    lPorts: TListView;
    lModems: TListView;
    lRestrictions: TListView;
    Img: TImageList;
    lNodes: TTabSheet;
    gOvr: TAdvGrid;
    bImport: TButton;
    PopupMenu: TPopupMenu;
    ppNew: TMenuItem;
    ppEdit: TMenuItem;
    ppCopy: TMenuItem;
    ppDelete: TMenuItem;
    ppUndelete: TMenuItem;
    ppDefault: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    bSort: TButton;
    bEditNode: TButton;
    lAuxNodes: TLabel;
    eAuxNode: TEdit;
    mPopup: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure UpdBtns(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure pgChange(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bNewClick(Sender: TObject);
    procedure bCopyClick(Sender: TObject);
    procedure bDefaultClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure bUndeleteClick(Sender: TObject);
    procedure lClick(Sender: TObject);
    procedure lChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure bImportClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure bSortClick(Sender: TObject);
    procedure bEditNodeClick(Sender: TObject);
    procedure mPopupClick(Sender: TObject);
  private
    { Private declarations }
    Crc: DWORD;
    C: TMainCfgColl;
    Changed: Boolean;
    Activated: Boolean;
    Ovr: TDialupNodeOvrColl;
    EvtChanged: Boolean;
    procedure SetData;
    procedure UpdatePage(No: Integer);
    procedure UpdateAll;
    function  List(No: Integer): TListView;
    procedure UpdateButtons;
    function  CurNo: Integer;
    function NdOvrVld: Boolean;
  public
    { Public declarations }
  end;

var
  MainConfigForm: TMainConfigForm;

function DialupSetup(APageIndex: Integer): Boolean;

implementation uses MLineCfg, DevCfg, ModemCfg, DialRest, FidoStat, xFido, LngTools, OvrExpl;

{$R *.DFM}


function DialupSetup;
var
  MainConfigForm: TMainConfigForm;
begin
  MainConfigForm := TMainConfigForm.Create(Application);
  case APageIndex of
    1: MainConfigForm.pg.ActivePage := MainConfigForm.tsStation;
    4: MainConfigForm.pg.ActivePage := MainConfigForm.tsRestrictions;
  end;
  MainConfigForm.SetData;
  Result := MainConfigForm.ShowModal = mrOK;
  if Result and MainConfigForm.EvtChanged then
  begin
    RecalcEvents := True;
    SetEvt(oRecalcEvents);
  end;
  FreeObject(MainConfigForm);
  if Result then PostMsg(WM_SETUPOK);
end;

function TMainConfigForm.NdOvrVld: Boolean;
begin
  Result := NodeOvrValid(Ovr, gOvr, Handle, True);
end;

procedure TMainConfigForm.SetData;
begin
  Cfg.Lines.AppendTo(C.Lines);
  Cfg.Station.AppendTo(C.Station);
  Cfg.Ports.AppendTo(C.Ports);
  Cfg.Modems.AppendTo(C.Modems);
  Cfg.Restrictions.AppendTo(C.Restrictions);
  eAuxNode.Text := Trim(Cfg.DialupNodeOverrides.AuxFile);
  SetNodeOvr(Cfg.DialupNodeOverrides, gOvr);
  Crc := Cfg.DialupNodeOverrides.Crc32(CRC32_INIT);
  UpdateAll;
end;


procedure TMainConfigForm.UpdateAll;
var
  i: Integer;
begin
  for i := 0 to 4 do UpdatePage(i);
  UpdateButtons;
end;

procedure TMainConfigForm.UpdatePage(No: Integer);

procedure UpdateLines;
var
  i: Integer;
  l: TLineRec;
begin
  lLines.Items.Clear;
//  di := C.Lines.DefaultIdx;
  for i := 0 to C.Lines.Count-1 do
  begin
    l := C.Lines[I];
    with lLines.Items.Add do
    begin
      Caption := l.Name;
      SubItems.Add(C.Station.GetRecById(l.d.StationId).Name);
      SubItems.Add(ComName(TPortRec(C.Ports.GetRecById(l.d.PortId)).d.Port));
      SubItems.Add(C.Modems.GetRecById(l.d.ModemId) .Name);
    end;
  end;
end;

procedure UpdateStations;
var
  i,di: Integer;
  s: TStationRec;
begin
  lStation.Items.Clear;
  di := C.Station.DefaultIdx;
  for i := 0 to C.Station.Count-1 do
  begin
    s := C.Station[I];
    with lStation.Items.Add do
    begin
      Caption := s.Name;
      if i = di then ImageIndex := 1;
      SubItems.Add(s.Data.Station);
      SubItems.Add(s.Data.Address);
    end;
  end;
end;

procedure UpdatePorts;
var
  i,di: Integer;
  p: TPortRec;
begin
  lPorts.Items.Clear;
  di := C.Ports.DefaultIdx;
  for i := 0 to C.Ports.Count-1 do
  begin
    p := C.Ports[I];
    with lPorts.Items.Add do
    begin
      Caption := ComName(p.d.Port);
      if i = di then ImageIndex := 1;
      SubItems.Add(IntToStr(p.d.BPS));
      SubItems.Add(p.FlowStr);
      SubItems.Add(GetLineBits(p.d.Data, p.d.Parity, p.d.Stop));
    end;
  end;
end;

procedure UpdateModems;
var
  i,di: Integer;
  m: TModemRec;
begin
  lModems.Items.Clear;
  di := C.Modems.DefaultIdx;
  for i := 0 to C.Modems.Count-1 do
  begin
    m := C.Modems[I];
    with lModems.Items.Add do
    begin
      Caption := m.Name;
      if i = di then ImageIndex := 1;
    end;
  end;
end;

procedure UpdateRestrictions;
var
  i,di: Integer;
  r: TRestrictionRec;
begin
  lRestrictions.Items.Clear;
  di := C.Restrictions.DefaultIdx;
  for i := 0 to C.Restrictions.Count-1 do
  begin
    r := C.Restrictions[I];
    with lRestrictions.Items.Add do
    begin
      Caption := r.Name;
      if i = di then ImageIndex := 1;
      SubItems.Add(FormatLng(rsDCItems, [r.Data.Required.Count]));
      SubItems.Add(FormatLng(rsDCItems, [r.Data.Forbidden.Count]));
    end;
  end;
end;



begin
  case No of
    0 : UpdateLines;
    1 : UpdateStations;
    2 : UpdatePorts;
    3 : UpdateModems;
    4 : UpdateRestrictions;
  end;
end;


procedure TMainConfigForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  Ovr.AuxFile := Trim(eAuxNode.Text);
  if (not Changed) and (Ovr.Crc32(CRC32_INIT) = Crc) then Exit;
  CfgEnter;
  XChg(Integer(C.FList^[0]), Integer(Cfg.Lines));
  XChg(Integer(C.FList^[1]), Integer(Cfg.Station));
  XChg(Integer(C.FList^[2]), Integer(Cfg.Ports));
  XChg(Integer(C.FList^[3]), Integer(Cfg.Modems));
  XChg(Integer(C.FList^[4]), Integer(Cfg.Restrictions));
  Xchg(Integer(Cfg.DialupNodeOverrides), Integer(Ovr));
  CfgLeave;
  StoreConfig(Handle);
  PostMsg(WM_IMPORTDUPOVRL);
end;

procedure TMainConfigForm.FormCreate(Sender: TObject);
  procedure Ins(P: Pointer); begin C.Insert(P) end;
var i: Integer;
begin
  FillForm(Self, rsMainConfigForm);
  C := TMainCfgColl.Create;
  for i := 0 to 1 do
  begin
    Ins(TLineColl.Create);
    Ins(TStationColl.Create);
    Ins(TPortColl.Create);
    Ins(TModemColl.Create);
    Ins(TRestrictColl.Create);
  end;
  Img.ResourceLoad(rtBitmap, 'MARK_DEFAULT', clLtGray);
  Ovr := TDialupNodeOvrColl.Create;
end;


procedure TMainConfigForm.FormDestroy(Sender: TObject);
begin
  FreeObject(C);
  FreeObject(Ovr);
end;

function TMainConfigForm.List;
begin
  case No of
    0: Result := lLines;
    1: Result := lStation;
    2: Result := lPorts;
    3: Result := lModems;
    4: Result := lRestrictions;
    else Result := Pointer(GlobalFail('TMainConfigForm.List (%d)', [No]));
  end;
end;

procedure TMainConfigForm.UpdateButtons;
var
  IsDef, s: Boolean;
  cn: Integer;
  p: TListItem;

procedure SetAllVisible(V: Boolean);
begin
  bImport.Visible := not V;
  bSort.Visible := not V;
  bEditNode.Visible := not V;
  bNew.Visible := V;
  bEdit.Visible := V;
  bCopy.Visible := V;
  bDefault.Visible := V;
  bDelete.Visible := V;
  bUndelete.Visible := V;
  bDefault.Visible := V;
end;

begin
  if C = nil then Exit;
  cn := CurNo;
  if cn = 5 then SetAllVisible(False) else
  begin
    SetAllVisible(True);
    p := List(cn).ItemFocused;
    s := p <> nil;
    bEdit.Enabled := s;
    ppEdit.Enabled := s;
    bCopy.Enabled := s;
    ppCopy.Enabled := s;
    IsDef := s;
    if cn > 0 then IsDef := IsDef and (C.GetElement(cn).GetDefaultIdx <> p.Index);
    s := IsDef and (cn>0);
    bDefault.Enabled := s;
    ppDefault.Enabled := s;
    if cn=0 then IsDef := IsDef and (C.GetElement(cn).Count>1);
    bDelete.Enabled := IsDef;
    ppDelete.Enabled := IsDef;
    s := C.GetElement(cn+5).Count>0;
    bUndelete.Enabled := s;
    ppUndelete.Enabled := s;
  end;
end;

function TMainConfigForm.CurNo: Integer;
begin
  Result := pg.ActivePage.PageIndex;
end;

procedure TMainConfigForm.UpdBtns(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  UpdateButtons;
end;

procedure TMainConfigForm.pgChange(Sender: TObject);
begin
  UpdateButtons;
end;

{function NewDUPCfg(i: Integer): string;
begin
  Result := LngStr(rsNewLine+i);
end;}


procedure TMainConfigForm.bNewClick(Sender: TObject);

const
  ec: array[0..4] of TElementClass = (TLineRec, TStationRec, TPortRec, TModemRec, TRestrictionRec);

var
  cn: Integer;
  cl: TElementColl;
  ne: TElement;
  b, evc: Boolean;
begin
  cn := CurNo;
  cl := C[cn];
  ne := ec[cn].Create;
  ne.SetDefault;
  ne.Id := GetFreeNo([cl, C[cn+5]]);
  cl.Insert(ne);
  evc := False;
  case CurNo of
    0 : b := EditMailerLine(ne, C, evc);
    1 : b := EditStation(ne);
    2 : b := EditPort(ne);
    3 : b := EditModem(ne);
    4 : b := EditRestriction(ne);
    else b := Boolean(GlobalFail('TMainConfigForm.bNewClick CurNo=%d', [CurNo]));
  end;
  EvtChanged := EvtChanged or evc;
  if b then
  begin
    Changed := True;
    UpdatePage(CurNo); if CurNo <> 0 then UpdatePage(0);
    UpdateButtons;
  end else
  begin
    cl.Delete(ne);
    FreeObject(ne);
  end;
end;

procedure TMainConfigForm.bEditClick(Sender: TObject);
var
  evc, b: Boolean;
begin
  if not bEdit.Enabled then Exit;
  evc := False;
  case CurNo of
    0 : b := EditMailerLine(C.Lines[lLines.ItemFocused.Index], C, evc);
    1 : b := EditStation(C.Station[lStation.ItemFocused.Index]);
    2 : b := EditPort(C.Ports[lPorts.ItemFocused.Index]);
    3 : b := EditModem(C.Modems[lModems.ItemFocused.Index]);
    4 : b := EditRestriction(C.Restrictions[lRestrictions.ItemFocused.Index]);
    else b := Boolean(GlobalFail('TMainConfigForm.bEditClick CurNo=%d', [CurNo]));
  end;
  EvtChanged := EvtChanged or evc;
  if b then
  begin
    Changed := True;
    UpdatePage(CurNo); if CurNo <> 0 then UpdatePage(0);
    UpdateButtons;
  end;
end;


procedure TMainConfigForm.bCopyClick(Sender: TObject);
var
  cn: Integer;
  cl: TElementColl;
  ne: TElement;
begin
  cn := CurNo;
  cl := C[cn];
  ne := TAdvCpObject(cl[List(cn).ItemFocused.Index]).Copy;
  ne.Id := GetFreeNo([cl, C[cn+5]]);
  cl.Insert(ne);
  UpdatePage(cn); if cn <> 0 then UpdatePage(0);
  UpdateButtons;
end;

procedure TMainConfigForm.bDefaultClick(Sender: TObject);
var
  cl: TElementColl;
  cn: Integer;
begin
  Changed := True;
  cn := CurNo;
  cl := C[cn];
  cl.SetDefaultIdx(List(cn).ItemFocused.Index);
  UpdatePage(cn); if cn <> 0 then UpdatePage(0);
  UpdateButtons;
end;

procedure TMainConfigForm.bDeleteClick(Sender: TObject);
var
  fi,cn: Integer;
  cl: TElementColl;
begin
  Changed := True;
  cn := CurNo;
  cl := C[cn];
  fi := List(cn).ItemFocused.Index;
  C.GetElement(cn+5).Insert(cl[fi]);
  cl.AtDelete(fi);
  cl.InvalidateId;
  UpdatePage(cn); if cn <> 0 then UpdatePage(0);
  UpdateButtons;
end;

procedure TMainConfigForm.bUndeleteClick(Sender: TObject);
var
  i, cn: Integer;
  cl: TElementColl;
begin
  cn := CurNo;
  cl := C[cn+5];
  for i := 0 to cl.Count-1 do
  begin
    C.GetElement(cn).Insert(cl[i]);
  end;
  cl.DeleteAll;
  UpdatePage(cn); if cn <> 0 then UpdatePage(0);
  UpdateButtons;
end;

procedure TMainConfigForm.lClick(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TMainConfigForm.lChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  UpdateButtons;
end;

procedure TMainConfigForm.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  GridFillColLng(gOvr, rsDupGrid);
  Activated := True;
end;

procedure TMainConfigForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult <> mrOK then CanClose := True else CanClose := NdOvrVld;
end;

procedure TMainConfigForm.bImportClick(Sender: TObject);
begin
  if not NdOvrVld then Exit;
  DoImportOp(Ovr, gOvr, False, True);
end;

procedure TMainConfigForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TMainConfigForm.bSortClick(Sender: TObject);
begin
  if not NdOvrVld then Exit;
  Ovr.Sort(_OvrSort);
  SetNodeOvr(Ovr, gOvr);
end;

procedure TMainConfigForm.bEditNodeClick(Sender: TObject);
var
  C: TColl;
  Msg, Item: string;
  Idx: Integer;
begin
  if not NdOvrVld then Exit;
  Idx := gOvr.Row-1;
  if (Idx < 0) or (Idx >= Ovr.Count) then Exit;
  C := ParseOverride(TNodeOvr(Ovr[Idx]).Ovr, Msg, Item, True);
  if CollCount(C) > 0 then
  begin
    if EditOverrideEx(C, True, TNodeOvr(Ovr[Idx]).Addr) then gOvr[2, gOvr.Row] := OvrColl2Str(C);
  end;
  FreeObject(C);
end;

procedure TMainConfigForm.mPopupClick(Sender: TObject);
var
  cn: Integer;
  p: TPoint;
  li: TListItem;
  lv: TListView;
begin
  cn := CurNo;
  lv := List(cn);
  li := lv.Selected;
  if li = nil then begin p.x := 0; p.y := 0 end else p := li.Position;
  p := lv.ClientToScreen(p);
  PopupMenu.Popup(p.x+16, p.y+20);
end;

end.


