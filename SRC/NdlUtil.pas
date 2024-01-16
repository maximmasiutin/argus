unit NdlUtil;

interface

{$I DEFINE.INC}


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, xBase, xFido;

type

  TNodelistCompiler = class(TForm)
    bStop: TButton;
    llStatus: TLabel;
    lStatus: TLabel;
    llNodes: TLabel;
    lNodes: TLabel;
    llNets: TLabel;
    lNets: TLabel;
    llCurFile: TLabel;
    lFile: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure TimerTimer(Sender: TObject);
  private
    Timer: TTimer;
  public
    C: T_Thread;
    Auto: Boolean;
    OK: Boolean;
    procedure WMSetOK(var Msg: TMessage); message WM_SETOK;
  end;


var
  NodelistCompiler: TNodelistCompiler;
  NodelistMissed,
  NodelistCompilation: Boolean;

type

     PNodePoint = ^TNodePoint;
     TNodePoint = record Node, Point: Integer end;

     TShortNodeIdx = packed record
       Len: Byte;
       Hub, Node, Point: Word;
     end;

     PShortNodeIdxArr = ^TShortNodeIdxArr;
     TShortNodeIdxArr = packed array[0..(MaxInt-3) div SizeOf(TShortNodeIdx)] of TShortNodeIdx;

     TNetNodeIdx = class
       Ofs, Hub: Integer;
       Addr: TNodePoint;
     end;

     TZoneContainer = class(TSortedColl)
       ZoneData: TFidoZoneData;
       Sz, NumNodes, MemPos: Integer;
       function Compare(Key1, Key2: Pointer): Integer; override;
       function KeyOf(Item: Pointer): Pointer; override;
     end;

     TTableColl = class(TSortedColl)
       CarePos: Boolean;
       function Compare(Key1, Key2: Pointer): Integer; override;
       function KeyOf(Item: Pointer): Pointer; override;
     end;

     TNodeController = class
       Table: TTableColl;
       Stream: TDosStream;
       Cache: TFidoNodeColl;
       ZonesBin: TxMemoryStream;
       constructor Create;
       function SearchNode(const Addr: TFidoAddress): TFidoNode;
       destructor Destroy; override;
       function SeekNet(Idx, Zone, Net: Integer): TZoneContainer;
       function SearchNodeOfNet(ZoneIdx: Integer; const Addr: TFidoAddress): TFidoNode;
       function GetNetIdx(Zone, Net: Integer): Integer;
     end;

function FindNode(const Addr: TFidoAddress): TAdvNode;
function GetListedNode(const Addr: TFidoAddress): TFidoNode;
procedure FreeNodeController;
procedure EnterNlCS;
procedure LeaveNlCS;
procedure InitNdlUtil;
procedure DoneNdlUtil;
procedure PurgeAdvNodeCache;


var
  NodeController: TNodeController;


implementation
uses Recs, xMisc, LngTools;

{$R *.DFM}

var
  NodeControllerCS: TRTLCriticalSection;
  NetTablePos: DWORD;


procedure EnterNlCS;
begin
  EnterCS(NodeControllerCS);
end;


procedure LeaveNlCS;
begin
  LeaveCS(NodeControllerCS);
end;


function TTableColl.Compare(Key1, Key2: Pointer): Integer;
var
  a: PFidoZoneData absolute Key1;
  b: PFidoZoneData absolute Key2;
begin
  Result := a^.Zone - b^.Zone;
  if Result = 0 then Result := a^.Net - b^.Net;
  if CarePos then if Result = 0 then Result := b^.Pos - a^.Pos;
end;

function TTableColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TZoneContainer(Item).ZoneData;
end;

var
  PhantomNodes: TColl;

procedure FreeNodeController;
begin
  FreeObject(NodeController);
  FreeObject(PhantomNodes);
end;

type
  TZoneOfsColl = class(TSortedColl)
    function Compare(Key1, Key2: Pointer): Integer; override;
    function KeyOf(Item: Pointer): Pointer; override;
  end;

function TZoneOfsColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := Integer(Key1^) - Integer(Key2^);
end;

function TZoneOfsColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TZoneContainer(Item).ZoneData.Pos;
end;


constructor TNodeController.Create;
var
  ZOC: TZoneOfsColl;

function DoCreate: Boolean;
var
  Actually: DWORD;
  I,J,N: Integer;
  ZC: TZoneContainer;
begin
  Result := False;
  if Stream.Read(i, 4) <> 4 then Exit; // version
  if i <> -10 then Exit;
  if Stream.Read(NetTablePos, 4) <> 4 then Exit;
  if (NetTablePos >= DWORD(MaxInt)) or (SetFilePointer(Stream.Handle, NetTablePos, nil, FILE_BEGIN) <> NetTablePos) then Exit;
  if Stream.Read(N, 4) <> 4 then Exit;
  if (N < 0) or (N > $FFFF) then Exit;
//  if N < 0 then GlobalFail('%s', ['TNodeController.Create']);
  for i := 1 to N do
  begin
    ZC := TZoneContainer.Create;
    ZC.MemPos := -1;
    if (not ReadFile(Stream.Handle, ZC.ZoneData, SizeOf(TFidoZoneData), Actually, nil)) or (SizeOf(TFidoZoneData)<>Actually) then Exit;
    Table.Insert(ZC);
    ZOC.Insert(ZC);
  end;
  for J := 0 to ZOC.Count-1 do
  begin
    ZC := ZOC[J];
    if J = ZOC.Count-1 then N := NetTablePos else N := TZoneContainer(ZOC[J+1]).ZoneData.Pos;
    Dec(N, ZC.ZoneData.Pos+4);
    ZC.Sz := N;
  end;
  ZOC.DeleteAll;
  Result := True;
end;

begin
  inherited Create;
  ZonesBin := GetMemoryStream;
  Cache := TFidoNodeColl.Create;
  Table := TTableColl.Create;
  Table.Duplicates := True;
  Table.CarePos := True;
  Stream := OpenRead(NDLPath);
  if Stream = nil then Exit;
  ZOC := TZoneOfsColl.Create;
  if not DoCreate then
  begin
    FreeObject(Stream);
    DeleteFile(PChar(NDLPath));
    Table.FreeAll;
    if not NodelistMissed then
    begin
//      DisplayErrorLng(rsNdlNoData, 0);
      NodelistMissed := True;
    end;
  end;
  FreeObject(ZOC);
  Table.CarePos := False;
end;

function TNodeController.SeekNet(Idx, Zone, Net: Integer): TZoneContainer;
var
  zc: TZoneContainer;
  nia: PShortNodeIdxArr;

procedure Look(Dir: Integer);
var
  I, J: Integer;
  P: Pointer;
  zca: TZoneContainer;
begin
  i := idx;
  repeat
    Inc(i, dir);
    if (i < 0) or (i>=Table.Count) then Break;
    zca := Table[i];
    if (zc.ZoneData.Zone <> zca.ZoneData.Zone) or (zc.ZoneData.Net <> zca.ZoneData.Net) then Break;
    if zca.MemPos <> -1 then GlobalFail('TNodeController.SeekNet(%d,%d,%d) zca.MemPos(%d) <> -1', [Idx, Zone, Net, zca.MemPos]);
    Stream.Position := zca.ZoneData.Pos;
    Stream.Read(J, 4);
    ReallocMem(nia, (zc.NumNodes+J)*SizeOf(TShortNodeIdx));
    Stream.Read(nia^[zc.NumNodes], J*SizeOf(TShortNodeIdx));
    Inc(zc.NumNodes, J);

    J := zca.Sz - J*SizeOf(TShortNodeIdx);
    GetMem(P, J);
    Stream.Read(P^, J);
    ZonesBin.Write(P^, J);
    FreeMem(P, J);
    Table.AtFree(i);
    Dec(i, dir);
  until False;
end;

var
  I, J, K: Integer;
  ni: TNetNodeIdx;
  P: Pointer;
  sni: TShortNodeIdx;
  zca: TZoneContainer;

begin
  zc := Table[Idx];
  if zc.MemPos = -1 then
  begin
    I := Idx;
    while I > 0 do
    begin
      Dec(i);
      zca := Table[i];
      if (zc.ZoneData.Zone <> zca.ZoneData.Zone) or (zc.ZoneData.Net <> zca.ZoneData.Net) then Break;
      zc := zca;
      if zc.MemPos <> -1 then GlobalFail('TNodeController.SeekNet(%d,%d,%d) zc.MemPos(%d) <> -1', [Idx, Zone, Net, zc.MemPos]);
      Idx := i;
    end;
    zc.MemPos := ZonesBin.Size;
    ZonesBin.Position := ZonesBin.Size;
    Stream.Position := zc.ZoneData.Pos;
    Stream.Read(zc.NumNodes, 4);
    J := zc.Sz - zc.NumNodes*SizeOf(TShortNodeIdx);
    nia := nil;
    ReallocMem(nia, zc.NumNodes*SizeOf(TShortNodeIdx));
    Stream.Read(nia^, zc.NumNodes*SizeOf(TShortNodeIdx));
    GetMem(P, J);
    Stream.Read(P^, J);
    ZonesBin.Write(P^, J);
    FreeMem(P, J);

//    Look(-1);
    Look(+1);

    J := zc.MemPos;
    for I := 0 to zc.NumNodes-1 do
    begin
      sni := nia^[I];
      ni := TNetNodeIdx.Create;
      ni.Ofs := J; Inc(J, sni.Len);
      ni.Hub := sni.Hub;
      ni.Addr.Node := sni.Node;
      ni.Addr.Point := sni.Point;
      if zc.Search(zc.KeyOf(ni), K) then FreeObject(ni) else zc.AtInsert(K, ni);
    end;
    ReallocMem(nia, 0);
    { J - prevnode, K - Hub }
    J := -1;
    for I := 0 to zc.Count-1 do
    begin
      ni := zc[I];
      if ni.Addr.Point = 0 then
      begin
        J := ni.Addr.Node;
        K := ni.Hub;
      end else
      begin
        if ni.Addr.Node = J then ni.Hub := K;
      end;
    end;
  end;
  Result := zc;
end;

function TNodeController.SearchNodeOfNet(ZoneIdx: Integer; const Addr: TFidoAddress): TFidoNode;
var
  TN: TFidoNode;
  I: Integer;
  zc: TZoneContainer;
  a: TNodePoint;
  ni: TNetNodeIdx;
begin
  Result := nil;
  zc := SeekNet(ZoneIdx, Addr.Zone, Addr.Net);
  a.Node := Addr.Node;
  a.Point := Addr.Point;
  if zc.Search(@a, I) then
  begin
    TN := TFidoNode.Create;
    ni := zc[I];
    ZonesBin.Position := ni.Ofs;
    TN.FillStream(Addr.Zone, Addr.Net, ZonesBin);
    TN.Hub := ni.Hub;
    if (TN.Addr.Point = 0) and (zc.Count>I+1) then
    begin
      ni := zc[I+1];
      TN.HasPoints := ni.Addr.Node = TN.Addr.Node;
    end;
    Result := TN;
  end;
end;


function TNodeController.GetNetIdx(Zone, Net: Integer): Integer;
var
  z: TFidoZoneData;
begin
  z.Zone := Zone;
  z.Net := Net;
  if not Table.Search(@z, Result) then Result := -1;
end;

function TNodeController.SearchNode;
var
  J: Integer;
begin
  Result := nil;
  if Cache.Search(@Addr, J) then
  begin
    Result := Cache[J]; Exit;
  end;
  J := GetNetIdx(Addr.Zone, Addr.Net);
  if J <> -1 then Result := SearchNodeOfNet(J, Addr);
  if Result <> nil then Cache.Insert(Result);
end;


destructor TNodeController.Destroy;
begin
  FreeObject(ZonesBin);
  FreeObject(Stream);
  if PhantomNodes = nil then PhantomNodes := TColl.Create;
  PhantomNodes.Concat(Cache);
  FreeObject(Cache);
  FreeObject(Table);
  NodeController := nil;
  inherited Destroy;
end;

type
   TZoneRoot = class
     Zone: Integer;
     FoundZC: Boolean;
   end;

   TZoneRootColl = class(TSortedColl)
     function Compare(Key1, Key2: Pointer): Integer; override;
     function KeyOf(Item: Pointer): Pointer; override;
   end;

   TCompileThread = class(T_Thread)
     SleepTimer: EventTimer;
     Addr: TFidoAddress;
     CompiledNodes,
     CompiledNets: Integer;
     Sorting: Boolean;
     D: TNodelistCompiler;
     CurFile: String;
     Error: String;
     ZCs: TZoneRootColl;
     constructor Create(AD: TNodelistCompiler);
     destructor Destroy; override;
     procedure InvokeExec; override;
     procedure UpdateStatus;
     class function ThreadName: string; override;
   end;

class function TCompileThread.ThreadName: string;
begin
  Result := 'Nodelist Compiler';
end;


constructor TCompileThread.Create;
begin
  inherited Create;
  NewTimer(SleepTimer, 1);
  ZCs := TZoneRootColl.Create;
  D := AD;
  FreeObject(NodeController);
  Resume;
end;

procedure TCompileThread.UpdateStatus;
begin
  D.TimerTimer(D.Timer);
end;

procedure TNodelistCompiler.WMSetOK;
begin
  if OK then Exit;
  OK := True;
  TCompileThread(C).UpdateStatus;
  FreeObject(Timer);
  if Auto then PostMessage(Handle, WM_CLOSE, 0, 0) else
  begin
    bStop.Caption := 'OK';
    lStatus.Caption := LngStr(rsNdlFinished);
    lFile.Caption := '';
  end;
end;

function CompareZones(P1, P2: Pointer): Integer;
  var K1, K2: String[10];
begin
  K1 := Format('%-5d%-5d', [TFidoZone(P1).d.Net, TFidoZone(P2).d.Net]);
  K2 := Copy(K1, 6, 5); K1[0] := #5;
  if TFidoZone(P1).d.Zone < TFidoZone(P2).d.Zone then Result := -1 else
    if TFidoZone(P1).d.Zone > TFidoZone(P2).d.Zone then Result := 1 else
       if K1 < K2 then Result := -1 else
       if K1 > K2 then Result := 1 else
           if TFidoZone(P1).d.Net < TFidoZone(P2).d.Net then Result := -1 else
           if TFidoZone(P1).d.Net > TFidoZone(P2).d.Net then Result := 1 else
       if TFidoZone(P1).d.First < TFidoZone(P2).d.First then Result := -1 else
           if TFidoZone(P1).d.First > TFidoZone(P2).d.First then Result := 1 else
              Result := 0;
end;

procedure TCompileThread.InvokeExec;

var
  S: ShortString;
  SL: Byte absolute S;
  PCCount: Integer;
  CurHub,
  OldZone, OldNet: Integer;
  ST: DWORD;
  Zones: TColl;
  PC: TFidoNet;
  MS: TxMemoryStream;
  Point: Boolean;

  procedure SetZC(Zone: Integer);
  var
    I: Integer;
    ZR: TZoneRoot;
  begin
    if not ZCs.Search(@Zone, I) then
    begin
      ZR := TZoneRoot.Create;
      ZR.Zone := Zone;
      ZCs.AtInsert(I, ZR);
    end;
  end;

  procedure NewNet;
    var P: TFidoZone;
        I, K: Integer;
        J, D: DWORD;
        TN: TFidoNode;
        SI: TShortNodeIdx;
        Actually: DWORD;
  begin
    if PCCount > 0 then
      begin
        SetZC(OldZone);
        P := TFidoZone.Create;
        P.d.Zone := OldZone;
        if OldNet = 0 then OldNet := OldZone;
        P.d.Net := OldNet;
        P.d.Pos := SetFilePointer(ST, 0, nil, FILE_CURRENT);
        P.d.First := 0;
        Zones.Add(P);
        D := PCCount;
        TN := PC[0];
        P.d.First := TN.Addr.Node;
        MS.Position := 0;
        MS.Write(D, 4);
        if MS.Capacity < SizeOf(TShortNodeIdx)*D*2 then MS.Capacity := SizeOf(TShortNodeIdx)*D*4;
        MS.Position := 4 + SizeOf(TShortNodeIdx)*D;
        for I := 0 to PCCount-1 do
        begin
          TN := PC[I];
          J := MS.Position;
          TN._Store(MS);
          DWORD(TN.TreeItem) := MS.Position - J;
        end;
        I := MS.Position;
        MS.Position := 4;
        for K := 0 to PCCount-1 do
        begin
          TN := PC[K];
          SI.Len := Integer(TN.TreeItem);
          SI.Hub := TN.Hub;
          SI.Node := TN.Addr.Node;
          SI.Point := TN.Addr.Point;
          MS.Write(SI, SizeOf(SI));
        end;
        WriteFile(ST, MS.Memory^, I, Actually, nil);
        Inc(CompiledNets);
        PCCount := 0;
      end;
    OldZone := Addr.Zone;
    OldNet := Addr.Net;
  end;

  function Add(var X: Integer; Flag: TNodePrefixFlag): TFidoNode;
    var I, J: Integer;
        P: TFidoNode;
        C: Char;
  begin
    Result := nil;
    I := 0;
    J := 1;
    while J < SL do
    begin
      C := S[J];
      if C = ',' then Break;
      I := (I * 10) + Ord(C)-Ord('0');
      if (I = 0) or (I > 65535) then Exit;
      Inc(J);
    end;
    X := I;
    if (OldZone <> Addr.Zone) or (OldNet <> Addr.Net) then NewNet;
    if PCCount<PC.Count then P := PC[PCCount] else P := TFidoNode.Create;
    P.FillNodelist(Addr, Copy(S,J+1,255), Flag);
    P.Hub := CurHub;
    Inc(CompiledNodes);
    if PCCount<PC.Count then PC.AtPut(PCCount, P) else PC.AtInsert(PCCount, P);
    Inc(PCCount);
    Result := P;
  end;

  function AddPoint(var X: Integer): TFidoNode;
  begin
    Result := Add(X, nfPoint);
  end;


  procedure AddNode(Flag: TNodePrefixFlag);
  begin
    Addr.Point := 0;
    Add(Addr.Node, Flag);
    if TimerExpired(SleepTimer) then
    begin
      Sleep(50);
      NewTimer(SleepTimer, 10);
    end;
  end;

  procedure AddHub;
  var
    N: TFidoNode;
  begin
    Addr.Point := 0;
    N := Add(Addr.Node, nfHub);
    if N <> nil then
    begin
      CurHub := Addr.Node;
      N.Hub := CurHub;
    end;
  end;


  procedure SetBoss;
  begin
    FillChar(Addr, SizeOf(Addr), 0);
    ParseAddress(S, Addr);
    Point := True;
  end;

  procedure SetNet;
  begin
    Addr.Node := 0; Addr.Point := 0; CurHub := 0;
    Add(Addr.Net, nfNet);
  end;

  procedure SetZone;
  var
    I: Integer;
    ZR: TZoneRoot;
  begin
    Addr.Net := 0; Addr.Node := 0; Addr.Point := 0; CurHub := 0;
    Add(Addr.Zone, nfZone);
    SetZC(Addr.Zone);
    if not ZCs.Search(@Addr.Zone, I) then GlobalFail('%s', ['TCompileThread.ThreadExec | SetZone']);
    ZR := ZCs[i];
    ZR.FoundZC := True;
  end;

  procedure CompileFile(FName: String);
    var SR: TSearchRec;
        Mask: String;
        I: Integer;
        DT: Integer;
        S1: ShortString;
        S1L: byte absolute S1;
        F: TTextReader;
        C: Char;
        SSR: String;
        IsRegEx: Boolean;
  begin
    FillChar(Addr, SizeOf(Addr), 0);
    CfgEnter;
    Addr.Zone := Cfg.PathNames.DefaultZone;
    CfgLeave;

    Mask := ExtractFileName(FName);
    IsRegEx := StrQuotePartEx(Mask, '~', #3, #4) <> Mask;
    S := ExtractFilePath(FName);
    if IsRegEx then FName := S+'*.*' else Replace('%', '?', FName);
    I := FindFirst(FName, faAnyFile, SR);
    FName := ''; DT := 0;
    while I = 0 do
      begin
        if _MatchMask(SR.Name, Mask, True ) and (Abs(DT) < SR.Time) and (SR.Attr and faDirectory = 0) then
          begin FName := S+SR.Name; DT := SR.Time end;
        I := FindNext(SR);
      end;
    FindClose(SR);
    if FName = '' then Exit;
    CurFile := FName;
    F := CreateTextReader(FName);
    if F = nil then Exit;
    while (not F.EOF) and (not Terminated) do
      begin
         SSR := F.GetStr;
         if (SSR <> '') and (SSR[1] <> ';') and (Length(SSR)<250) then
           begin
             S := SSR;
             I := 1;
             C := #0;
             while I <= SL do
             begin
               C := S[I];
               if C = ',' then Break;
               S1[I] := UpCase(C);
               Inc(I);
             end;
             if C <> ',' then Continue;
             S1L := I-1;
             Move(S[I+1], S[1], SL-I);
             Dec(SL, I);
             if (S1 = '') then
             begin
               if Point then AddPoint(Addr.Point) else AddNode(nfNormal)
             end else
             if S1 = 'POINT' then AddPoint(Addr.Point) else
             begin
               Point := False;
               if (S1 = 'HUB') then AddHub else
               if S1 = 'BOSS' then SetBoss else
               if (S1 = 'HOST') or (S1 = 'REGION') then SetNet else
               if S1 = 'ZONE' then SetZone else
               if S1 = 'PVT' then AddNode(nfPvt) else
               if S1 = 'HOLD' then AddNode(nfHold) else
               if S1 = 'DOWN' then AddNode(nfDown) else AddNode(nfUrec);
             end;
           end;
      end;
    FreeObject(F);
  end;

procedure FlushZCs;
var
  Z, I: Integer;
  ZR: TZoneRoot;
begin
  for I := 0 to ZCs.Count-1 do
  begin
    ZR := ZCs[I];
    if ZR.FoundZC then Continue;
    Z := ZR.Zone;
    S := Format('%d,%s,%s,%s,%s,%d,%s', [Z,'...','...','...','-Unpublished-',300,'XA']);
    SetZone;
  end;
end;

var
  I: Integer;
  Actually: DWORD;
begin
  Zones := nil;
  PC := nil; PCCount := 0;
  MS := TxMemoryStream.Create;
  St := _CreateFile(NDLPath, [cTruncate]);
  if St = INVALID_HANDLE_VALUE then Error := SysErrorMessage(GetLastError) else
    begin
      SetEndOfFile(ST);

      I := -10; // version
      WriteFile(ST, I, 4, Actually, nil);

      I := -3; // reserve space
      WriteFile(ST, I, 4, Actually, nil);
      Zones := TColl.Create;

      CfgEnter;
      OldZone := Cfg.PathNames.DefaultZone;
      CfgLeave;

      OldNet := 0; PC := TFidoNet.Create;
      for I := 0 to Cfg.Nodelist.Files.Count-1 do
      begin
        CompileFile(Cfg.Nodelist.Files[I]);
      end;
      NewNet;
      FlushZCs;
      NewNet;
      if not Terminated then
        begin
          I := SetFilePointer(ST, 0, nil, FILE_CURRENT);
          SetFilePointer(ST, 4, nil, FILE_BEGIN);
          WriteFile(ST, I, 4, Actually, nil);
          SetFilePointer(ST, I, nil, FILE_BEGIN);
          Zones.Sort(CompareZones);
          I := Zones.Count;
          MS.Position := 0;
          MS.Write(I,4);
          for I := 0 to Zones.Count-1 do
              MS.Write(TFidoZone(Zones[I]).d, SizeOf(TFidoZoneData));
          WriteFile(ST, MS.Memory^, MS.Position, Actually, nil);
          Zones.FreeAll;
        end;
    end;
  repeat
    _PostMessage(D.Handle, WM_SETOK, 0, 0);
    Sleep(100);
  until D.OK;
  ZeroHandle(ST);
  FreeObject(MS);
  FreeObject(Zones);
  FreeObject(PC);
  Terminated := True;
end;


procedure TNodelistCompiler.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsNodelistCompiler);
  NodelistCompilation := True;
  Timer := TTimer.Create(Self);
  Timer.OnTimer := TimerTimer;
  EnterNlCS;
  C := TCompileThread.Create(Self);
end;

procedure TNodelistCompiler.FormDestroy(Sender: TObject);
begin
  C.WaitFor; 
  FreeObject(C);
  FreeObject(NodeController);
  LeaveNlCS;
  NodelistCompilation := False;
end;

procedure TNodelistCompiler.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not OK {TCompileThread(C).Terminated} then
  begin
    CanClose := False;
    C.Terminated := True;
    Auto := True;

(*    C.Suspend;
    if True {YesNoConfirmLng(rsNdlOKtoCancel, 0)} then
    begin
      C.Resume;
      NodelistMissed := True;
      C.Terminated := True;
    end else
    begin
      CanClose := False;
      Visible := True;
      C.Resume;
    end;*)
  end;
end;


procedure TNodelistCompiler.TimerTimer(Sender: TObject);
begin
  with TCompileThread(C) do
    begin
      if Error <> '' then lStatus.Caption := StrAsg(Error) else
       if Sorting then lStatus.Caption := LngStr(rsNdlSorting)
                  else lStatus.Caption := FormatLng(rsNdlComp, [Addr.Zone, Addr.Net]);
      lNodes.Caption := Int2Str(CompiledNodes);
      lNets.Caption := Int2Str(CompiledNets);
      lFile.Caption := StrAsg(CurFile);
    end;
end;


function GetListedNode(const Addr: TFidoAddress): TFidoNode;
begin
  EnterNlCS;
  if NodeController = nil then NodeController := TNodeController.Create;
  if NodeController = nil then Result := nil else
                             Result := NodeController.SearchNode(Addr);
  LeaveNlCS;
end;

function FindDom(const Addr: TFidoAddress): TColl;
var
  i: Integer;
  Dom, s, z: string;
  ad: TAdvNodeData;
begin
  Result := nil;
  CfgEnter;
  for i := 0 to MinI(CollMax(Cfg.IpDomA), CollMax(Cfg.IpDomB)) do
  begin
    s := Cfg.IpDomA[i];
    if MatchMaskAddressListSingle(Addr, s) then
    begin
      Dom := StrAsg(Cfg.IpDomB[i]);
      Break;
    end;
  end;
  CfgLeave;
  if Dom = '' then Exit;
  ad := TAdvNodeData.Create;
  ad.Flags := 'CM,BNP';
  z := Format('"%sf%d.n%d.z%d.%s"', ['%s', Addr.Node, Addr.Net, Addr.Zone, Dom]);
  s := '';
  if Addr.Point <> 0 then s := Format('p%d.', [Addr.Point]);
  ad.IpAddr := Format(z, [s]);
  InsUA(Result, ad);
end;


function FindAdvNode(const Addr: TFidoAddress): TAdvNode;
var
  Nodes: array[Boolean] of TFidoNode;
  Base: Boolean;
  n: TFidoNode;
  DialupData, IPData: TColl;

function CAND(Dialup: Boolean): TColl;
var
  an: TAdvNodeData;
begin
  Result := nil;
  an := TAdvNodeData.Create;
  if Dialup then an.Phone := StrAsg(n.Phone) else an.IPAddr := StrAsg(n.Phone);
  an.Flags := StrAsg(n.Flags);
  InsUA(Result, an);
end;

var
  f: TNodePrefixFlag;
  over: Boolean;
begin
  Result := nil;
  over := False;
  f := nfOver;
  Base := False;
  Clear(Nodes, SizeOf(Nodes));
  n := GetListedNode(Addr);
  if n <> nil then
  case IdentOvrItem(n.Phone, False, False) of
    oiPhoneNum : begin Base := False; Nodes[False] := n end;
    oiIPSym, oiIpNum: begin Base := True; Nodes[False] := n end;
    else n := nil;
  end;
  DialupData := GetNodeOvrData(Addr, {$IFDEF WS}True,{$ENDIF} Nodes[Base]);
  IPData := GetNodeOvrData(Addr, {$IFDEF WS}False,{$ENDIF} Nodes[not Base]);
  if n <> nil then
  begin
    over := (DialupData <> nil) or (IPData <> nil);
    if ((Base=False) and (DialupData = nil)) then DialupData := CAND(True) else
    if ((Base=True) and (IPData = nil)) then IpData := CAND(False);
  end;
{$IFDEF WS}
  if DaemonStarted and (IPData = nil) then IpData := FindDom(Addr);
{$ENDIF}
  if (DialupData = nil) and (IPData = nil) then Exit;
  Result := TAdvNode.Create;
  if n <> nil then
  begin
    if not over then f := n.PrefixFlag;
    Result.Speed := n.Speed;
    Result.Station := StrAsg(n.Station);
    Result.Sysop := StrAsg(n.Sysop);
    Result.Location := StrAsg(n.Location);
  end;
  Result.PrefixFlag := f;
  Result.Addr := Addr;
  Result.DialupData := DialupData;
  Result.IPData := IPData;
end;

type
  TAdvNodeColl = class(TSortedColl)
    function Compare(Key1, Key2: Pointer): Integer; override;
    function KeyOf(Item: Pointer): Pointer; override;
  end;

function TAdvNodeColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := CompareAddrs(PFidoAddress(Key1)^, PFidoAddress(Key2)^);
end;

function TAdvNodeColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TAdvNode(Item).Addr;
end;

var
  AdvNodeCache: TAdvNodeColl;
  AdvNodeMissed: TFidoAddrColl;

function FindNode(const Addr: TFidoAddress): TAdvNode;
var
  i: Integer;
  p: TExtPoll;
  e: TAdvNodeExtData;
  f: Boolean;
begin
  Result := nil;
  AdvNodeMissed.Enter;
  f := AdvNodeMissed.Search(@Addr, I);
  AdvNodeMissed.Leave;
  if f then Exit;
  AdvNodeCache.Enter;
  f := AdvNodeCache.Search(@Addr, I);
  if f then Result := TAdvNode(AdvNodeCache[I]).Copy;
  AdvNodeCache.Leave;
  if f then Exit;
  Result := FindAdvNode(Addr);
  CfgEnter;
  for i := 0 to CollMax(Cfg.ExtPolls) do
  begin
    p := Cfg.ExtPolls[i];
    if not MatchMaskAddressListSingle(Addr, p.FAddrs) then Continue;
    e := TAdvNodeExtData.Create;
    e.Opts := StrAsg(p.FOpts);
    e.Cmd := StrAsg(p.FCmd);
    if Result = nil then
    begin
      Result := TAdvNode.Create;
      Result.Addr := Addr;
    end;
    Result.Ext := e;
    Break;
  end;
  CfgLeave;
  if Result = nil then
  begin
    AdvNodeMissed.Enter;
    if not AdvNodeMissed.Search(@Addr, I) then AdvNodeMissed.AtInsert(I, NewFidoAddr(Addr));
    AdvNodeMissed.Leave;
  end else
  begin
    AdvNodeCache.Enter;
    if not AdvNodeCache.Search(@Addr, I) then AdvNodeCache.AtInsert(I, Result.Copy);
    AdvNodeCache.Leave;
  end;
end;


destructor TCompileThread.Destroy;
begin
  FreeObject(ZCs);
  inherited Destroy;
end;

function TZoneContainer.Compare(Key1, Key2: Pointer): Integer;
var
  a: PNodePoint absolute Key1;
  b: PNodePoint absolute Key2;
begin
  Result := a^.Node - b^.Node;
  if Result = 0 then Result := a^.Point - b^.Point;
end;

function TZoneContainer.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TNetNodeIdx(Item).Addr;
end;

procedure InitNdlUtil;
begin
  InitializeCriticalSection(NodeControllerCS);
  AdvNodeCache := TAdvNodeColl.Create; AdvNodeCache.Enter; AdvNodeCache.Leave;
  AdvNodeMissed := TFidoAddrColl.Create; AdvNodeMissed.Enter; AdvNodeMissed.Leave;
end;

procedure DoneNdlUtil;
begin
  FreeObject(AdvNodeCache);
  FreeObject(AdvNodeMissed);
  DeleteCriticalSection(NodeControllerCS);
end;

procedure PurgeAdvNodeCache;
begin
  AdvNodeCache.Enter;
  AdvNodeCache.FreeAll;
  AdvNodeCache.Leave;
  AdvNodeMissed.Enter;
  AdvNodeMissed.FreeAll;
  AdvNodeMissed.Leave;
end;

function TZoneRootColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := PInteger(Key1)^ - PInteger(Key2)^;
end;

function TZoneRootColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TZoneRoot(Item).Zone;
end;



end.

