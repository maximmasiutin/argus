unit NodeBrws;

interface

{$I DEFINE.INC}


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  ComCtrls, StdCtrls, ExtCtrls, xFido, xBase;

type
  TNodelistBrowser = class(TForm)
    Tree: TTreeView;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    pnInfo: TPanel;
    llAddr: TLabel;
    llStat: TLabel;
    llSysop: TLabel;
    llSite: TLabel;
    llPhn: TLabel;
    llSpd: TLabel;
    llFlags: TLabel;
    llWrkTimeUTC: TLabel;
    llAddrSearch: TLabel;
    eAddress: TEdit;
    lAddress: TEdit;
    lStation: TEdit;
    lSysop: TEdit;
    lLocation: TEdit;
    lPhone: TEdit;
    lSpeed: TEdit;
    lFlags: TEdit;
    lWrkTimeUTC: TEdit;
    lStatus: TEdit;
    llWrlTimeLocal: TLabel;
    lWrkTimeLocal: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure TreeCollapsed(Sender: TObject; Node: TTreeNode);
    procedure TreeExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
    procedure TreeClick(Sender: TObject);
    procedure TreeChange(Sender: TObject; Node: TTreeNode);
    procedure eAddressKeyPress(Sender: TObject; var Key: Char);
    procedure eAddressChange(Sender: TObject);
    procedure TreeExpanded(Sender: TObject; Node: TTreeNode);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    { Private declarations }
    Activated: Boolean;
    StartText: string;
  public
    DataSorted: Boolean;
  end;


procedure BrowseNodes;
function BrowseAtNode(const Addr: TFidoAddress): Boolean;
function SelectNode(var Addr: TFidoAddress): Boolean;

implementation

uses Recs, NdlUtil, CommCtrl, LngTools;

{$R *.DFM}

function _SelectNode(var Addr: TFidoAddress; PBaseAddr: PFidoAddress): Boolean;
var
  D: TNodelistBrowser;
begin
  D := TNodelistBrowser.Create(Application);
  if PBaseAddr <> nil then D.StartText := Addr2Str(PBaseAddr^);
  Result := (D.ShowModal = mrOK) and (ParseAddress(D.lAddress.Text, Addr));
  FreeObject(D);
end;

function SelectNode(var Addr: TFidoAddress): Boolean;
begin
  Result := _SelectNode(Addr, nil);
end;

procedure BrowseNodes;
var a: TFidoAddress;
begin
  SelectNode(a);
end;

function BrowseAtNode(const Addr: TFidoAddress): Boolean;
var
  a: TFidoAddress;
begin
  Result := GetListedNode(Addr) <> nil;
  if Result then _SelectNode(a, @Addr);
end;


procedure AddMore(Tree: TTreeView; Carrier: TTreeNode; Node: TFidoNode);
begin
  case GetNodeType(Node) of
    fntPoint: Exit;
    fntNode: if not Node.HasPoints then Exit;
  end;
  Tree.Items.AddChild(Carrier, '');
end;

procedure AddNode(Tree: TTreeView; Carrier: TTreeNode; Node: TFidoNode);
var
  N: TTreeNode;
  s: string;
begin
  s := '';
  case GetNodeType(Node) of
    fntZone: s := Format('Zone %d, ', [Node.Addr.Zone]);
    fntRegion: s := Format('Region %d, ', [Node.Addr.Net]);
    fntNet: s := Format('Net %d, ', [Node.Addr.Net]);
    fntHub: s := Format('Hub %d, ', [Node.Addr.Node]);
    fntNode:
    begin
      case Node.PrefixFlag of
        nfPvt, nfHold, nfDown: s := Format(' (%s)', [cNodePrefixFlag[Node.PrefixFlag]]);
      end;
      s := Format('Node %d%s, ', [Node.Addr.Node, s]);
    end;
    fntPoint: s := Format('Point %d, ', [Node.Addr.Point]);
  end;
  N := Tree.Items.AddChildObject(Carrier, Format('%s%s, %s', [s, Node.Station, Node.Sysop]), Node);
  Node.TreeItem := N.ItemId;
  AddMore(Tree, N, Node);
end;

procedure AddPoints(Tree: TTreeView; Carrier: TTreeNode; Node: TFidoNode);
var
  Idx: Integer;
  ZC: TZoneContainer;
  i: Integer;
  ni: TNetNodeIdx;
  Addr: TFidoAddress;
begin
  EnterNlCs;
  Idx := NodeController.GetNetIdx(Node.Addr.Zone, Node.Addr.Net);
  ZC := NodeController.SeekNet(Idx, Node.Addr.Zone, Node.Addr.Net);
  Addr.Zone := Node.Addr.Zone;
  Addr.Net := Node.Addr.Net;
  for i := 0 to zc.Count-1 do
  begin
    ni := zc[i];
    if ni.Addr.Point = 0 then Continue;
    if ni.Addr.Node <> Node.Addr.Node then Continue;
    Addr.Node := ni.Addr.Node;
    Addr.Point := ni.Addr.Point;
    AddNode(Tree, Carrier, GetListedNode(Addr));
  end;
  LeaveNlCs;
end;


procedure AddNodes(Hubs: Boolean; Tree: TTreeView; Carrier: TTreeNode; Node: TFidoNode);
var
  Idx: Integer;
  ZC: TZoneContainer;
  I: Integer;
  ni: TNetNodeIdx;


procedure Add;
var
  a: TFidoAddress;
  N: TFidoNode;
begin
  a.Zone := Node.Addr.Zone;
  a.Net := Node.Addr.Net;
  a.Node := ni.Addr.Node;
  a.Point := ni.Addr.Point;
  N := GetListedNode(a);
  AddNode(Tree, Carrier, N);
end;

var
  J: Integer;

begin
  EnterNlCs;
  {if (not Hubs) and (GetNodeType(Node) = fntHub)then} AddPoints(Tree, Carrier, Node);
  Idx := NodeController.GetNetIdx(Node.Addr.Zone, Node.Addr.Net);
  ZC := NodeController.SeekNet(Idx, Node.Addr.Zone, Node.Addr.Net);
  for J := 0 to Integer(Hubs) do
  for I := 0 to zc.Count-1 do
  begin
    ni := zc[i];
    if ni.Addr.Node = 0 then Continue;
    if ni.Addr.Point <> 0 then Continue;
    if (ni.Hub = 0) or (ni.Hub = ni.Addr.Node) then
    begin
      if Hubs then
      begin
        if (ni.Hub = 0) = (J = 0) then Add;
      end;
    end else
    begin
      if (not Hubs) and (Node.Addr.Node = ni.Hub) then Add;
    end;
  end;
  LeaveNlCs;
end;



procedure AddNets(Regions: Boolean; Tree: TTreeView; Carrier: TTreeNode; Node: TFidoNode);
var
  i: Integer;
  Z: TZoneContainer;
  ZC, RC: TFidoNode;
  ZCA, RCA: TFidoAddress;
  ZCS: TColl;
  b: Boolean;
  s: string;
begin
  EnterNlCs;
  ZCS := TColl.Create;
  if NodeController <> nil then
  begin
    if Regions then
    begin
      // ??
    end else
    begin
      s := IntToStr(Node.Addr.Net);
    end;
    ZCA.Node := 0; ZCA.Point := 0;
    i := -1;
    while i < NodeController.Table.Count-1 do
    begin
      Inc(i);
      Z := NodeController.Table[i];
      if Z.ZoneData.Zone <> Node.Addr.Zone then Continue;
      if Regions then
      begin
        b := (Z.ZoneData.Net <> Z.ZoneData.Zone);
        if b then
        begin
          if Z.ZoneData.Net>99 then
          begin
            RCA.Zone := Z.ZoneData.Zone;
            RCA.Net := Z.ZoneData.Net; while RCA.Net > 99 do RCA.Net := RCA.Net div 10;
            RCA.Node := 0;
            RCA.Point := 0;
            RC := GetListedNode(RCA);
            b := RC = nil;
          end;
        end;
      end else
      begin
        b := (Z.ZoneData.Net > 99) and (s = Copy(IntToStr(Z.ZoneData.Net), 1, 2));
      end;
      if b then
      begin
        ZCA.Zone := Z.ZoneData.Zone;
        ZCA.Net := Z.ZoneData.Net;
        ZC := GetListedNode(ZCA);
        if ZC <> nil then ZCS.Insert(ZC);
      end;
    end;
  end;
  LeaveNlCs;
  if NodeController <> nil then
  begin
    AddPoints(Tree, Carrier, Node);
    // Add indnodes
    AddNodes(True, Tree, Carrier, Node);
    for i := 0 to ZCS.Count-1 do
    begin
      ZC := ZCS[i];
      AddNode(Tree, Carrier, ZC);
    end;
  end;
  ZCS.DeleteAll;
  FreeObject(ZCS);
end;

procedure AddSubNode(Tree: TTreeView; Carrier: TTreeNode; Node: TFidoNode);
begin
  case GetNodeType(Node) of
    fntZone:
      begin
        // Add regions of zone
        AddNets(True, Tree, Carrier, Node);
      end;
    fntRegion:
      begin
        // Add nets of regions
        AddNets(False, Tree, Carrier, Node);
      end;
    fntNet:
      begin
        AddNodes(True, Tree, Carrier, Node);
      end;
    fntHub:
      begin
        AddNodes(False, Tree, Carrier, Node);
      end;
    fntNode:
      begin
        AddPoints(Tree, Carrier, Node);
      end;
  end;
end;

procedure TNodelistBrowser.FormActivate(Sender: TObject);
var
  i: Integer;
  Z: TZoneContainer;
  ZC: TFidoNode;
  ZCA: TFidoAddress;
  ZCS: TColl;
begin
  if Activated then Exit;
  Activated := True;
  EnterNlCS;
  if NodeController = nil then NodeController := TNodeController.Create;
  ZCS := TColl.Create;
  if NodeController <> nil then
  begin
    ZCA.Net := 0; ZCA.Node := 0; ZCA.Point := 0;
    i := -1;
    while i < NodeController.Table.Count-1 do
    begin
      Inc(i);
      Z := NodeController.Table[i];
      if Z.ZoneData.Net = Z.ZoneData.Zone then
      begin
        ZCA.Zone := Z.ZoneData.Zone;
        ZCA.Net := Z.ZoneData.Net;
        ZC := GetListedNode(ZCA);
        if ZC <> nil then ZCS.Insert(ZC);
      end;
    end;
  end;
  LeaveNlCS;
  if (NodeController = nil) or (ZCS.Count = 0) then
  begin
    DisplayErrorLng(rsNBNoNdl, Handle);
    _PostMessage(Handle, WM_CLOSE, 0, 0);
  end else
  begin
    for i := 0 to ZCS.Count-1 do
    begin
      ZC := ZCS[i];
      AddNode(Tree, nil, ZC);
    end;
  end;
  ZCS.DeleteAll;
  FreeObject(ZCS);
  if StartText <> '' then eAddress.Text := StartText;
end;

procedure DeleteNode(Tree: TTreeView; Node: TTreeNode);
var
  N: TTreeNode;
  F: TFidoNode;
begin
  repeat
    N := Node.GetFirstChild;
    if N = nil then Break;
    DeleteNode(Tree, N);
  until False;
  F := Node.Data; if F <> nil then Integer(F.TreeItem) := 0;
  Tree.Items.Delete(Node);
end;

procedure TNodelistBrowser.TreeCollapsed(Sender: TObject; Node: TTreeNode);
var
  N: TTreeNode;
begin
  repeat
    N := Node.GetFirstChild;
    if N = nil then Break;
    DeleteNode(Tree, N);
  until False;
  AddMore(Tree, Node, TFidoNode(Node.Data));
end;

procedure TNodelistBrowser.TreeExpanding(Sender: TObject; Node: TTreeNode; var AllowExpansion: Boolean);
begin
  AllowExpansion := not Node.Expanded;
  if AllowExpansion then AddSubNode(Tree, Node, TFidoNode(Node.Data));
end;


procedure SetCap(L: TEdit; const S: String);
begin
  L.Text := S;
end;


procedure TNodelistBrowser.TreeClick(Sender: TObject);
var
  N: TTreeNode;
  D: TFidoNode;
begin
  N := Tree.Selected;
  if N = nil then Exit;
  D := N.Data;
  lAddress.Text := Addr2Str(D.Addr);
  SetCap(lStation, D.Station);
  SetCap(lSysop, D.Sysop);
  SetCap(lLocation, D.Location);
  SetCap(lPhone, D.Phone);
  SetCap(lFlags, D.Flags);
  SetCap(lWrkTimeUTC, FSC62TimeToStr(NodeFSC62TimeEx(D.Flags, D.Addr, False)));
  SetCap(lWrkTimeLocal, FSC62TimeToStr(NodeFSC62TimeEx(D.Flags, D.Addr, True)));
  SetCap(lStatus, cNodePrefixFlag[D.PrefixFlag]);
  lSpeed.Text := IntToStr(D.Speed);
end;

procedure TNodelistBrowser.TreeChange(Sender: TObject; Node: TTreeNode);
begin
  TreeClick(nil);
end;

procedure TNodelistBrowser.eAddressKeyPress(Sender: TObject; var Key: Char);
  var S: String;
      I1, I2, I3, I4, J: Integer;
      K: Char;
  label 1;
begin
  I1 := 0;
  I2 := 0;
  I3 := 0;
  S := eAddress.Text; K := Key; Key := #0;
  if K in [':', '/', '.'] then
    begin
      if Pos(K, S) > 0 then Exit;
      I4 := Length(S)+1;
      I1 := Pos(':', S);
      I2 := Pos('/', S);
      I3 := Pos('.', S);
      if I1 = 0 then I1 := I4;
      if I2 = 0 then I2 := I4;
      if I3 = 0 then I3 := I4;
    end;
  J := eAddress.SelStart;
  case K of
    #8,#27: ;
    '0'..'9': ;
    ':': if (I2 <= J) or (I3 <= J) then Exit;
    '/': if (I1 > J) or (I3 <= J) then Exit;
    '.': if (I1 > J) or (I2 > J) then Exit;
     else Exit;
  end;
  Key := K;
end;


procedure TNodelistBrowser.eAddressChange(Sender: TObject);
var
  Addr: TFidoAddress;
  I, L: Integer;
  ExitNow: Boolean;
  S: String;
  T: TNodeType;
  N: TFidoNode;
  TN: TTreeNode;
  HI: HTreeItem;

procedure Expand(Zone,Net,Node,Point: Integer);
var
  TmpAddr: TFidoAddress;
  NN: TFidoNode;
  HI: HTreeItem;
begin
  TmpAddr.Zone := Zone;
  TmpAddr.Net := Net;
  TmpAddr.Node := Node;
  TmpAddr.Point := Point;
  NN := GetListedNode(TmpAddr);
  if NN <> nil then
  begin
    HI := NN.TreeItem;
    if HI = nil then GlobalFail('%s', ['TNodelistBrowser.eAddressChange NN.TreeItem = nil']);
    TN := Tree.Items.GetNode(HI);
    if TN = nil then GlobalFail('%s', ['TNodelistBrowser.eAddressChange Tree.Items.GetNode(HI) = nil']);
    if not TN.Expanded then TN.Expand(False);
  end;
  ExitNow := CompareAddrs(Addr, TmpAddr) = 0;
  if ExitNow then TN.Selected := True;
end;

begin
  FillChar(Addr, SizeOf(Addr), 0);
  S := eAddress.Text; L := Length(S);
  if L = 0 then Exit;
  if S[L] = ':' then S := S + Copy(S, 1, L-1) + '/0.0' else
    if S[L] = '/' then S := S + '0.0' else
     if S[L] = '.' then S := S + '0';
  if Pos(':', S) = 0 then S := S + ':'+S+'/0.0' else
   if Pos('/', S) = 0 then S := S + '/0.0' else
    if Pos('.', S) = 0 then S := S + '.0';
  if not ParseAddress(S, Addr) then Exit;
  N := GetListedNode(Addr);
  if N = nil then Exit;
  HI := N.TreeItem;
  if Integer(HI) <> 0 then
  begin
    Tree.Selected := Tree.Items.GetNode(HI);
    Exit;
  end;

  EnterNlCS;
  for t := fntZone to fntPoint do
  begin
    case t of
      fntZone:
        Expand(Addr.Zone, Addr.Zone, 0, 0);
      fntRegion:
        begin
          I := Addr.Net; while i > 99 do i := i div 10;
          Expand(Addr.Zone, i, 0, 0);
        end;
      fntNet:
        Expand(Addr.Zone, Addr.Net, 0, 0);
      fntHub:
        Expand(Addr.Zone, Addr.Net, N.Hub, 0);
      fntNode:
        Expand(Addr.Zone, Addr.Net, Addr.Node, 0);
      fntPoint:
        Tree.Items.GetNode(N.TreeItem).Selected := True;
    end;
    if ExitNow then Break;
  end;
  LeaveNlCS;

end;

procedure TNodelistBrowser.TreeExpanded(Sender: TObject; Node: TTreeNode);
begin
  Tree.Items.Delete(Node.GetFirstChild);
end;

procedure TNodelistBrowser.FormDestroy(Sender: TObject);
var
  i, c: Integer;
  p: PItemList;
begin
  if NodeController = nil then Exit;
  EnterNlCS;
  p := NodeController.Cache.FList;
  c := NodeController.Cache.Count - 1;
  for i := 0 to c do Integer(TFidoNode(p^[i]).TreeItem) := 0;
  LeaveNlCS;
end;


procedure TNodelistBrowser.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsNodelistBrowser);
end;

procedure TNodelistBrowser.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.



