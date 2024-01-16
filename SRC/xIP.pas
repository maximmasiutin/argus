unit xIP;

{$I DEFINE.INC}


interface uses
  Windows,

{$IFDEF WS}
  Classes,
{$ENDIF}
  xBase;


{$IFDEF WS}

var
  TCPIP_InR, TCPIP_OutR: DWORD;
  TCPIP_InGr, TCPIP_OutGr: array[0..TCPIP_GrDataSz] of Integer;
  TCPIP_GrStep: DWORD;
  TCPIP_GrCS: TRTLCriticalSection;
  ProxyEnabled: Boolean;
  ProxyAddr: string;
  ProxyPort: DWORD;

type
  TDaemonParams = record
    ifcico: TvIntArr;
    Telnet: TvIntArr;
    BinkP: TvIntArr;
    InConns, OutConns: DWORD;
  end;

  TNewIpInLine = class
    Port: Pointer;
    Prot: TProtCore;
    IpPort: DWORD;
  end;


  TWSAConnectResult = class
    p: Pointer;
    Res: Integer;
    Terminated,
    Error: Boolean;
    Port: Pointer;
    IpPort: DWORD;
    Prot: TProtCore;
    ResolvedAddr: DWORD;
  end;

function Addr2Inet(i: DWORD): string;
function RunDaemon(Params: TDaemonParams): Boolean;
procedure ShutdownDaemon;
procedure EndSockMgr;
procedure EndIpThreads;
procedure _WSAConnect(const Addr: string; p: Pointer; AProt: TProtCore; APort: DWORD);
function WSAErrMsg(Msg: Integer): string;
procedure PurgeConnThrs;
procedure HostResolveComplete(Idx, lParam: Integer);
var
  OutConnsAvail: DWORD;
  IPMon: T_Thread;
{$ENDIF}


function Inet2Addr(s: string): DWORD;
function Inet2Port(s: string; var Port: DWORD): DWORD;
function Sym2Port(s: string; var Port: DWORD): string;
function Sym2Addr(s: string): string;
function ValidInetAddr(const s: string): Boolean;
function ValidSymAddr(const s: string): Boolean;

const
  INADDR_NONE      = $FFFFFFFF;


implementation
uses

{$IFDEF WS}

wsock,

xMisc,
{$ENDIF}
SysUtils;


function InetAddr(const s: string): DWORD;
{$IFNDEF WS}
var
  a,b: string;
  i,e: Integer;
  r: array[0..3] of Int64;
{$ENDIF}
begin
 {$IFDEF WS}
   Result := inet_addr(PChar(s))
 {$ELSE}
   Result := INADDR_NONE;
   i := 0;
   a := s;
   while a <> '' do
   begin
     if i = 4 then Exit;
     GetWrd(a, b, '.');
     for e := 1 to Length(b) do
       case b[e] of
         '0'..'9' : ;
         else Exit;
       end;
     Val(b,r[i],e);
     if e <> 0 then Exit;
     Inc(i);
   end;
   for e := 0 to i-2 do
   begin
     if (r[e]<0) or (r[e]>$FF) then Exit;
   end;
   case i-1 of
     0 : begin
           if r[0] > MaxInt then Result := (r[0]-MaxInt)+MaxInt else
             Result := (r[0]);
         end;
     1 : begin
           if (r[1]<0) or (r[1]>$FFFFFF) then Exit;
           Result := ((r[0]) shl 24) or (r[1]);
         end;
     2 : begin
           if (r[2]<0) or (r[2]>$FFFF) then Exit;
           Result := ((r[0]) shl 24) or ((r[1]) shl 16) or ((r[2]));
         end;
     3 : begin
           if (r[3]<0) or (r[3]>$FF) then Exit;
           Result := ((r[0]) shl 24) or ((r[1]) shl 16) or ((r[2]) shl 8) or (r[3]);
         end;
     else GlobalFail('%s', ['InetAddr']);
   end;
 {$ENDIF}
end;

function Inet2Addr(s: string): DWORD;
var
  Port: DWORD;
begin
  Result := Inet2Port(s, Port);
end;

function Sym2Addr(s: string): string;
var
  Port: DWORD;
begin
  Result := Sym2Port(s, Port);
end;

function Sym2Port(s: string; var Port: DWORD): string;
var
  z: string;
  i,e: DWORD;
  c: Char;
begin
  Result := '';
  i := INADDR_NONE;
  if Pos('_',s) > 0 then C := '_' else C := ':';
  GetWrd(s, z, C);
  if s <> '' then
  begin
    Val(s, i, e);
    if e <> 0 then Exit;
  end;
  if not BothKVC(z) then Exit;
  if i <> INADDR_NONE then Port := i;
  DelFC(z); DelLC(z);
  Result := z;
end;


function Inet2Port(s: string; var Port: DWORD): DWORD;
var
  z: string;
  i: DWORD;
  C: Char;
begin
  Result := INADDR_NONE;
  i := INADDR_NONE;
  if Pos('_',s) > 0 then C := '_' else C := ':';
  GetWrd(s, z, C);
  if s <> '' then
  begin
    i := Vl(s);
    if i = INVALID_VALUE then Exit;
  end;
  Replace('*', '.', z);
  Result := InetAddr(z);
  if Result = INADDR_NONE then Exit;
  if i <> INADDR_NONE then Port := i;
end;

function ValidInetAddr(const s: string): Boolean;
begin
  Result := Inet2Addr(s) <> INADDR_NONE;
end;

function ValidSymAddr(const s: string): Boolean;
begin
  Result := Sym2Addr(s) <> '';
end;

{$IFDEF WS}

function _send(var AHandle: TSocket; const Buf; var Size: Integer; var Error: Boolean; OL: POverlapped): Integer; forward;
function _recv(var AHandle: TSocket; var Buf; var Size: Integer; var Error: Boolean; OL: POverlapped): Integer; forward;


const
  DaemonMemSize = TCPIP_Round;

type
  TIPMonThread = class(T_Thread)
    Again: Boolean;
    MemIn, MemOut: array[0..DaemonMemSize-1] of Integer;
    TCPIP_In, TCPIP_Out: DWORD;
    constructor Create;
    destructor Destroy; override;
    procedure InvokeExec; override;
    class function ThreadName: string; override;
  end;

  TResolveThread = class(T_Thread)
    Again: Boolean;
    CS: TRTLCriticalSection;
    oAsyncAvail, oStartResolve: THandle;
    InReq, OutReq, Resp, Async: TColl;
    procedure InvokeExec; override;
    constructor Create;
    destructor Destroy; override;
    function StartAsyncRequest(const HostName: string): Boolean;
    function ProcessRequests: Boolean;
    function AsyncIdxFound(Idx: Integer): Boolean;
    procedure HostResolveComplete(Idx, lParam: Integer);
    class function ThreadName: string; override;
  end;

  TResolveRequest = class
    HostName: string;
    oEvt: THandle;
  end;

  TResolveResponse = class
    HostName: string;
    Addr: DWORD;
    Error: Integer;
  end;

  TResolveAsyncStruc = class
    HostName: string;
    HostBuf: array[0..MAXGETHOSTSTRUCT] of Char;
    MsgIdx: Integer;
    Handle: TSocket;
  end;

class function TResolveThread.ThreadName: string;
begin
  Result := 'Host Resolver';
end;

procedure TResolveThread.HostResolveComplete(Idx, lParam: Integer);
var
  a: packed record buflen, err: word end absolute lParam;
  i,j: Integer;
  r: TResolveAsyncStruc;
  req: TResolveRequest;
  rsp: TResolveResponse;
  he: PHostEnt;
begin
  for i := 0 to Async.Count-1 do
  begin
    r := Async[i];
    if r.MsgIdx = Idx then
    begin
      for j := Resp.Count-1 downto 0 do
      begin
        rsp := Resp[j];
        if rsp.HostName = r.HostName then Resp.AtFree(j); 
      end;

      he := @r.HostBuf;

      Rsp := TResolveResponse.Create;
      Rsp.HostName := StrAsg(r.HostName);
      Rsp.Error := a.err;
      if a.err = 0 then
      begin
        if he^.h_addr_list <> nil then
        begin
          Rsp.Addr := PDwordArray(he^.h_addr_list^)^[0];
        end else
        begin
          Rsp.Error := -199;
        end;
      end;
      Resp.Insert(Rsp);

      for j := OutReq.Count-1 downto 0 do
      begin
        req := OutReq[j];
        if r.HostName = req.HostName then
        begin
          SetEvt(req.oEvt);
          OutReq.AtFree(j);
        end;
      end;
      if Async.Count = WM__NUMRESOLVE then SetEvt(oAsyncAvail);
      Async.AtFree(i);
      Break;
    end;
  end;
end;


function TResolveThread.AsyncIdxFound(Idx: Integer): Boolean;
var
  i: Integer;
  a: TResolveAsyncStruc;
begin
  Result := False;
  for i := 0 to Async.Count-1 do
  begin
    a := Async[i];
    if a.MsgIdx = Idx then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TResolveThread.StartAsyncRequest(const HostName: string): Boolean;
var
  i,j: Integer;
  r: TResolveAsyncStruc;
  found: Boolean;
begin
  Result := True;
  found := False;
  for i := 0 to Async.Count-1 do
  begin
    r := Async[i];
    if r.HostName = HostName then
    begin
      Found := True;
      Break;
    end;
  end;
  if (not Found) then
  begin
    if (Async.Count = WM__NUMRESOLVE) then
    Result := False
    else
    begin
      j := -1;
      for i := 0 to WM__NUMRESOLVE-1 do
      begin
        if not AsyncIdxFound(i) then begin j := i; Break end;
      end;
      if j = -1 then GlobalFail('%s', ['TResolveThread.StartAsyncRequest AsyncIdx Not Found']);
      r := TResolveAsyncStruc.Create;
      r.HostName := StrAsg(HostName);
      r.MsgIdx := j;
      r.Handle := WSAAsyncGetHostByName(MainWinHandle, WM_RESOLVE + r.MsgIdx, PChar(r.HostName), r.HostBuf, MAXGETHOSTSTRUCT);
      Async.Insert(r);
      if Async.Count = WM__NUMRESOLVE then ResetEvt(oAsyncAvail);
    end;
  end;
end;

function TResolveThread.ProcessRequests: Boolean;
var
  rreq: TResolveRequest;
  rres: TResolveResponse;
  i,k,j: Integer;
  AsyncStarted: Boolean;
begin
  Result := False;
  for k := InReq.Count-1 downto 0 do
  begin
    rreq := InReq[k];
    j := -1;
    for i := 0 to Resp.Count-1 do
    begin
      rres := Resp[i];
      if rres.HostName = rreq.HostName then
      begin
        j := i;
        Break;
      end;
    end;
    AsyncStarted := StartAsyncRequest(StrAsg(rreq.HostName));
    if (j = -1) then
    begin
      if not AsyncStarted then Exit;
      OutReq.Insert(rreq);
      InReq.AtDelete(k);
    end else
    begin
      SetEvt(rreq.oEvt);
      InReq.AtFree(k);
    end;
  end;
  Result := True;
end;

procedure TResolveThread.InvokeExec;
var
  DoWait: Boolean;
begin
  if not Again then
  begin
    Again := True;
    WaitEvtInfinite(oStartResolve);
  end;
  EnterCS(CS);
  DoWait := not ProcessRequests;
  LeaveCS(CS);
  if DoWait then WaitEvtInfinite(oAsyncAvail) else Again := False;
end;

//    HostName: string;
//    oEvt: Integer;


constructor TResolveThread.Create;
begin
  inherited Create;
  InitializeCriticalSection(CS);
  oStartResolve := CreateEvtA;
  oAsyncAvail := CreateEvt(True);
  InReq := TColl.Create;
  OutReq := TColl.Create;
  Resp := TColl.Create;
  Async := TColl.Create;
  Priority := tpLowest;
end;

var
  SocksAlloc: Integer;
  SkipCleanup,
  WSAStarted: Boolean;

destructor TResolveThread.Destroy;
var
  i: Integer;
  a: TResolveAsyncStruc;
begin
  for i := 0 to Async.Count-1 do
  begin
    a := Async[i];
    WSACancelAsyncRequest(a.Handle);
    SkipCleanup := True;
  end;
  FreeObject(InReq);
  FreeObject(OutReq);
  FreeObject(Resp);
  FreeObject(Async);
  DeleteCriticalSection(CS);
  ZeroHandle(oStartResolve);
  ZeroHandle(oAsyncAvail);
  inherited Destroy;
end;

const

WSA_ErrMsgMax = 65;
WSA_ErrMsg : array[0..WSA_ErrMsgMax] of record s: string; n: Integer end = (

  // Custom error codes
  (s:'No address (A) records available'; n:-199),

  // SOCKS4 error codes

  (s:'SOCKS request rejected or failed'; n:-91),
  (s:'SOCKS request rejected becasue SOCKS server cannot connect to identd on the client'; n:-92),
  (s:'SOCKS request rejected because the client program and identd report different user-ids'; n:-93),

  // Windows Sockets definitions of regular Microsoft C error constants

  (s:'WSAEINTR';n:                (WSABASEERR+4)),
  (s:'WSAEBADF';n:                (WSABASEERR+9)),
  (s:'WSAEACCES';n:               (WSABASEERR+13)),
  (s:'WSAEFAULT';n:               (WSABASEERR+14)),
  (s:'WSAEINVAL';n:               (WSABASEERR+22)),
  (s:'WSAEMFILE';n:               (WSABASEERR+24)),

  // Windows Sockets definitions of regular Berkeley error constants

  (s:'WSAEWOULDBLOCK';n:      (WSABASEERR+35)),
  (s:'WSAEINPROGRESS';n:         (WSABASEERR+36)),
  (s:'WSAEALREADY';n:            (WSABASEERR+37)),
  (s:'WSAENOTSOCK';n:            (WSABASEERR+38)),
  (s:'WSAEDESTADDRREQ';n:         (WSABASEERR+39)),
  (s:'WSAEMSGSIZE';n:             (WSABASEERR+40)),
  (s:'WSAEPROTOTYPE';n:           (WSABASEERR+41)),
  (s:'WSAENOPROTOOPT';n:          (WSABASEERR+42)),
  (s:'WSAEPROTONOSUPPORT';n:      (WSABASEERR+43)),
  (s:'WSAESOCKTNOSUPPORT';n:      (WSABASEERR+44)),
  (s:'WSAEOPNOTSUPP';n:           (WSABASEERR+45)),
  (s:'WSAEPFNOSUPPORT';n:         (WSABASEERR+46)),
  (s:'WSAEAFNOSUPPORT';n:         (WSABASEERR+47)),
  (s:'WSAEADDRINUSE';n:           (WSABASEERR+48)),
  (s:'WSAEADDRNOTAVAIL';n:        (WSABASEERR+49)),
  (s:'WSAENETDOWN';n:             (WSABASEERR+50)),
  (s:'WSAENETUNREACH';n:          (WSABASEERR+51)),
  (s:'WSAENETRESET';n:            (WSABASEERR+52)),
  (s:'WSAECONNABORTED';n:         (WSABASEERR+53)),
  (s:'WSAECONNRESET';n:           (WSABASEERR+54)),
  (s:'WSAENOBUFS';n:              (WSABASEERR+55)),
  (s:'WSAEISCONN';n:              (WSABASEERR+56)),
  (s:'WSAENOTCONN';n:             (WSABASEERR+57)),
  (s:'WSAESHUTDOWN';n:            (WSABASEERR+58)),
  (s:'WSAETOOMANYREFS';n:         (WSABASEERR+59)),
  (s:'WSAETIMEDOUT';n:            (WSABASEERR+60)),
  (s:'WSAECONNREFUSED';n:         (WSABASEERR+61)),
  (s:'WSAELOOP';n:                (WSABASEERR+62)),
  (s:'WSAENAMETOOLONG';n:         (WSABASEERR+63)),
  (s:'WSAEHOSTDOWN';n:            (WSABASEERR+64)),
  (s:'WSAEHOSTUNREACH';n:         (WSABASEERR+65)),
  (s:'WSAENOTEMPTY';n:            (WSABASEERR+66)),
  (s:'WSAEPROCLIM';n:             (WSABASEERR+67)),
  (s:'WSAEUSERS';n:               (WSABASEERR+68)),
  (s:'WSAEDQUOT';n:               (WSABASEERR+69)),
  (s:'WSAESTALE';n:               (WSABASEERR+70)),
  (s:'WSAEREMOTE';n:              (WSABASEERR+71)),

  // Extended Windows Sockets error constant definitions

  (s:'WSASYSNOTREADY';n:          (WSABASEERR+91)),
  (s:'WSAVERNOTSUPPORTED';n:      (WSABASEERR+92)),
  (s:'WSANOTINITIALISED';n:       (WSABASEERR+93)),
  (s:'WSAEDISCON';n:              (WSABASEERR+101)),
  (s:'WSAENOMORE';n:              (WSABASEERR+102)),
  (s:'WSAECANCELLED';n:           (WSABASEERR+103)),
  (s:'WSAEINVALIDPROCTABLE';n:    (WSABASEERR+104)),
  (s:'WSAEINVALIDPROVIDER';n:     (WSABASEERR+105)),
  (s:'WSAEPROVIDERFAILEDINIT';n:  (WSABASEERR+106)),
  (s:'WSASYSCALLFAILURE';n:       (WSABASEERR+107)),
  (s:'WSASERVICE_NOT_FOUND';n:    (WSABASEERR+108)),
  (s:'WSATYPE_NOT_FOUND';n:       (WSABASEERR+109)),
  (s:'WSA_E_NO_MORE';n:           (WSABASEERR+110)),
  (s:'WSA_E_CANCELLED';n:         (WSABASEERR+111)),
  (s:'WSAEREFUSED';n:             (WSABASEERR+112)),


  // Authoritative Answer: Host not found
  (s:'WSAHOST_NOT_FOUND';n:       (WSABASEERR+1001)),

  // Non-Authoritative: Host not found, or SERVERFAIL
  (s:'WSATRY_AGAIN';n:            (WSABASEERR+1002)),

  // Non-recoverable errors, FORMERR, REFUSED, NOTIMP
  (s:'WSANO_RECOVERY';n:          (WSABASEERR+1003)),

  // Valid name, no data record of requested type
  (s:'WSANO_DATA';n:              (WSABASEERR+1004))
);


function WSAErrMsg(Msg: Integer): string;
var
  i: Integer;
begin
  for i := 0 to WSA_ErrMsgMax do
  begin
    if Msg = WSA_ErrMsg[i].n then
    begin
      Result := WSA_ErrMsg[i].s;
      Exit;
    end;
  end;
  Result := FormatErrorMsg('', Msg);
end;


const
  TN_WILL = 251;
  TN_WONT = 252;
  TN_DO   = 253;
  TN_DONT = 254;
  TN_IAC  = 255;

  TN_TRANSMIT_BINARY = 0;
  TN_ECHO            = 1;
  TN_SUPPRESS_GA     = 3;






type

   TSockInThread = class(TInThread)
     GotChar: Boolean;
     function SubRead(var Buf; Size: Integer): Integer;
     function Read(var Buf; Size: DWORD): DWORD; override;
   end;

   TSockOutThread = class(TOutThread)
     AuxO: TDevicePortOutBlk;
     AuxSz: DWORD;
     More: Boolean;
     function SubWrite(const Buf; Size: Integer): Integer;
     function Write(const Buf; Size: DWORD): DWORD; override;
   end;

  TTelnetLast = (ttNone, ttIAC, ttWILL, ttWONT, ttDO, ttDONT, ttUnk);

  TTelnetFilter = class
    CP: TPort;
    TL: TTelnetLast;
    OutIAC: Boolean;
    procedure answer(Tag, Opt: Byte);
    procedure Init;
    function InFilter(B: Byte; var I: Byte): Boolean;
    function OutFilter(B: Byte; var O: Byte): Boolean;
  end;

  TSockPort = class(TDevicePort)
    OrigHandle: THandle;
    SockW: TRTLCriticalSection;
    IpPort: DWORD;
    Typ: TProtCore;
    Filter: TTelnetFilter;
    Incoming: Boolean;
    constructor Create(AHandle: DWORD; AFilter: TTelnetFilter; AIPPort: DWORD; ATyp: TProtCore);
    procedure CloseHW_A;                                override;
    procedure CloseHW_B;                                override;
    function ReadNow: Integer;                          override;
    procedure SleepDown;                                override;
    procedure WakeUp;                                   override;
    procedure SaveParams;                               override;
    procedure RestoreParams;                            override;
    procedure HWPurge(Typ: TTxRxSet);                   override;
    procedure DropDCD;
    procedure Err;
  end;

  TSockListen = class(T_Thread)
    Again: Boolean;
    Typ: TProtCore;
    IpPort: DWORD;
    SocketHandle: TSocket;
    oAccept: THandle;
    procedure TheEnd;
    procedure InvokeExec; override;
    destructor Destroy; override;
    function RecreateHandle: Boolean;
    class function ThreadName: string; override;
  end;

  TInSockMgr = class(T_Thread)
    SocksAvail: Integer;
    oNewSocks: DWORD;
    NewSocks: TColl;
    ListeningSocks: TColl;
    procedure InvokeExec; override;
    constructor Create;
    destructor  Destroy; override;
    class function ThreadName: string; override;
  end;

function __setblock(h: TSocket; p: u_long): Integer;
begin
  Result := ioctlsocket(h, FIONBIO, p);
end;

function __unblock(h: TSocket): Integer;
begin
  Result := WSAEventSelect(h, 0, 0);
  if Result = SOCKET_ERROR then Exit;
  Result := __setblock(h, 0);
end;

procedure __close(var h: TSocket);
var
  ls: TSocket;
  e: Integer;
begin
  ls := INVALID_SOCKET;
  XChg(h, ls);
  if (ls = INVALID_SOCKET) or (ls = 0) then Exit;
  if closesocket(ls) <> 0 then
  begin
    if not DisableWinsockTraps then
    begin
      e := WSAGetLastError;
      GlobalFail('closesocket error %d (%s)', [e, WSAErrMsg(e)]);
    end;
  end;
  Dec(SocksAlloc);
end;


function __socket: TSocket;
begin
  if WinSock2 then
  begin
    Result := WSASocket(PF_INET, SOCK_STREAM, IPPROTO_IP, nil, 0, WSA_FLAG_OVERLAPPED);
  end else
  begin
    Result := socket(PF_INET, SOCK_STREAM, 0);
  end;
  if Result <> INVALID_SOCKET then Inc(SocksAlloc);
end;

function __reuse(h: DWORD): Integer;
var
  bt: DWORD;
begin
  bt := 1;
  Result := setsockopt(h, SOL_SOCKET, SO_REUSEADDR, @bt, SizeOf(bt));
  if Result = SOCKET_ERROR then Exit;
end;

function __bind(AHandle, APort: DWORD; var Adr: TSockAddr): Integer;
begin
  Adr.sin_family      := AF_INET;
  Adr.sin_port        := htons(APort);
  Adr.sin_addr.s_addr := INADDR_ANY;
  Result := bind(AHandle, Adr, SizeOf(Adr));
end;





var
  SockMgr: TInSockMgr;

procedure TTelnetFilter.answer(Tag, Opt: Byte);
var
  a: array[0..2] of Byte;
begin
  EnterCS(TSockPort(CP).SockW);
  a[0] := TN_IAC;
  a[1] := Tag;
  a[2] := Opt;
  TSockOutThread(TSockPort(CP).WriteThr).SubWrite(a, 3);
  LeaveCS(TSockPort(CP).SockW);
end;

procedure TTelnetFilter.Init;
begin
  EnterCS(TSockPort(CP).SockW);
  answer(TN_DO, TN_SUPPRESS_GA);
  answer(TN_WILL, TN_SUPPRESS_GA);
  answer(TN_DO, TN_TRANSMIT_BINARY);
  answer(TN_WILL, TN_TRANSMIT_BINARY);
  answer(TN_DO, TN_ECHO);
  answer(TN_WILL, TN_ECHO);
  LeaveCS(TSockPort(CP).SockW);
end;

function TTelnetFilter.InFilter(B: Byte; var I: Byte): Boolean;
begin
  Result := False;
  case TL of
    ttNone:
      if B = TN_IAC then TL := ttIAC else begin I := B; Result := True end;
    ttIAC:
      case B of
        TN_IAC  : begin TL := ttNone; I := B; Result := True; end;
        TN_WILL : TL := ttWILL;
        TN_WONT : TL := ttWONT;
        TN_DO   : TL := ttDO;
        TN_DONT : TL := ttDONT;
        else TL := ttUnk;
      end;
    ttWILL,ttWONT,ttDO,ttDONT,ttUnk:
      begin
        case TL of
          ttWILL : if (B <> TN_TRANSMIT_BINARY) and (B <> TN_SUPPRESS_GA) and (B <> TN_ECHO) then answer(TN_DONT, B);
          ttWONT : ;
          ttDO   : if (B <> TN_TRANSMIT_BINARY) and (B <> TN_SUPPRESS_GA) and (B <> TN_ECHO) then answer(TN_WONT, B);
          ttDONT : ;
          ttUnk  : ;
          else GlobalFail('%s', ['TTelnetFilter unknown TL']);
        end;
        TL := ttNone;
      end;
    else GlobalFail('%s', ['TTelnetFilter unknown TL']);
  end;
end;

function TTelnetFilter.OutFilter(B: Byte; var O: Byte): Boolean;
begin
  if OutIAC then
  begin
    O := TN_IAC;
    OutIAC := False;
    Result := False;
  end else
  begin
    O := B;
    if B = TN_IAC then OutIAC := True;
    Result := OutIAC;
  end;
end;

function TSockPort.ReadNow: Integer;
begin
  Result := PortInBufSize;
end;

constructor TSockPort.Create;
var
  e: Integer;
begin
  inherited Create(TSockInThread, TSockOutThread);
  InitializeCriticalSection(SockW);
  FHandle := AHandle;
  if Win32Platform <> VER_PLATFORM_WIN32_NT then
  begin
    // workaround for socket handle inheritance bug of Win9x
    OrigHandle := FHandle;
    if not DuplicateHandle(GetCurrentProcess, OrigHandle, GetCurrentProcess, @FHandle, 0, True, DUPLICATE_SAME_ACCESS) then
    begin
      e := GetLastError;
      GlobalFail('Duplicate Socket Handle Failed, Error %d (%s)', [e, WSAErrMsg(e)]);
    end;
    Inc(SocksAlloc);
  end;
  FDCD := True;
  FCarrier := True;
  if AFilter <> nil then
  begin
    Filter := AFilter;
    Filter.CP := Self;
  end;
  IPPort := AIPPort;
  Typ := ATyp;
  WakeThreads;
end;

procedure __shutdown(FHandle: DWORD);
var
  e: Integer;
begin
  if shutdown(FHandle, 2) = SOCKET_ERROR then
  begin
    if not DisableWinsockTraps then
    begin
      e := WSAGetLastError;
      GlobalFail('shutdown failed, error %d. Try using WinSockVersion registry variable', [e, WSAErrMsg(e)]);
    end;
  end;
end;

procedure TSockPort.CloseHW_A;
begin
  if not WinSock2 then
  begin
    __shutdown(FHandle);
    __close(FHandle);
    if Win32Platform <> VER_PLATFORM_WIN32_NT then
    begin
      __close(OrigHandle);
    end;
  end;
end;

procedure TSockPort.CloseHW_B;
begin
  if WinSock2 then
  begin
    __close(TSocket(FHandle));
    if Win32Platform <> VER_PLATFORM_WIN32_NT then
    begin
      __close(OrigHandle);
    end;
  end;
  if Incoming then Inc(SockMgr.SocksAvail) else Inc(OutConnsAvail);
  DeleteCriticalSection(SockW);
  FreeObject(Filter);
end;

procedure TSockPort.Err;
var
  ee: TComError;
begin
  ee := TComError.Create;
  ee.Err := WSAGetLastError;
  InsComErr(ee);
end;

procedure TSockPort.DropDCD;
begin
  EnterCS(StatCS);
  FDCD := False;
  UpdateLineStatus;
  LeaveCS(StatCS);
end;

function _recv(var AHandle: TSocket; var Buf; var Size: Integer; var Error: Boolean; OL: POverlapped): Integer;
var
  B: TWSABuf;
  Flags: DWORD;
  i: Integer;
  Actually: DWORD;
begin
  if WinSock2 then
  begin
    Result := 0;
    B.Buf := @Buf;
    B.Len := Size;
    Flags := 0;
    Actually := 0;
    case WSARecv(AHandle, @B, 1, Actually, Flags, OL, nil) of
      0 : Result := Actually;
      SOCKET_ERROR:
        begin
          i := WSAGetLastError;
          case i of
            WSA_IO_PENDING:
              begin
                Flags := 0;
                Actually := 0;
                if WSAGetOverlappedResult(AHandle, OL^, Actually, True, Flags) then
                begin
                  Result := Actually;
                end else
                begin
                  Error := True;
                end
              end;
            else Error := True;
          end;
        end;
      else Error := True;
    end;
    if Error then Result := 0;
  end else
  begin
    Result := recv(AHandle, Buf, Size, 0);
    if Result = SOCKET_ERROR then begin Result := 0; Error := True end;
  end;
end;

function TSockInThread.SubRead(var Buf; Size: Integer): Integer;
var
  Error: Boolean;
  SockHandle: TSocket;
begin
  if Terminated then Result := 0 else
  begin
    Error := False;
    SockHandle := TSocket(CP.Handle);
    Result := _recv(SockHandle, Buf, Size, Error, @CP.ReadOL);
    if Error then
    begin
      TSockPort(CP).Err;
      Result := 0
    end;
    if Terminated then Result := 0 else
    if (Result=0) and (not CP.TempDown) then
    begin
      TSockPort(CP).DropDCD;
      Terminated := True
    end;
    Inc(TIPMonThread(IPMon).TCPIP_In, Result);
  end;
end;

function TSockInThread.Read(var Buf; Size: DWORD): DWORD;

var
  AuxSz: DWORD;

procedure ParseAux(var Arr: TxByteArray; var Rslt: DWORD);

var
  ofs: DWORD;

procedure DoIt;

function DoFilter(B: Byte; var I: Byte): Boolean;
begin
  Result := TSockPort(CP).Filter.InFilter(B, I);
end;


begin
  repeat
    GotChar := DoFilter(Arr[Ofs], Arr[Rslt]);
    if GotChar then Inc(Rslt);
    Inc(Ofs);
    if (Rslt = Size) or (Ofs = AuxSz) then Exit;
  until False;
end;

begin
  Rslt := 0;
  Ofs := 0;
  if AuxSz = 0 then Exit;
  DoIt;
end;

begin
  Result := 0;
  AuxSz := SubRead(Buf, Size);
  if Terminated then Exit;
  if TSockPort(CP).Filter = nil then Result := AuxSz else ParseAux(TxByteArray(Buf), Result);
end;

function _send(var AHandle: TSocket; const Buf; var Size: Integer; var Error: Boolean; OL: POverlapped): Integer;
var
  B: TWSABuf;
  Flags, Actually: DWORD;
  i: Integer;
begin
  if WinSock2 then
  begin
    Result := 0;
    B.Buf := @Buf;
    B.Len := Size;
    Actually := 0;
    i := WSASend(AHandle, @B, 1, Actually, 0, OL, nil);
    case i of
      0 : Result := Actually;
      SOCKET_ERROR:
        begin
          i := WSAGetLastError;
          case i of
            WSA_IO_PENDING:
              begin
                Actually := 0;
                if WSAGetOverlappedResult(AHandle, OL^, Actually, True, Flags) then
                begin
                  Result := Actually;
                end else
                begin
                  Error := True;
                end;
              end;
            else Error := True;
          end;
        end;
      else Error := True;
    end;
    if Error then Result := 0;
  end else
  begin
    Result := send(AHandle, (@Buf)^, Size, 0);
    if Result = SOCKET_ERROR then begin Error := True; Result := 0 end;
  end;
end;

function TSockOutThread.SubWrite(const Buf; Size: Integer): Integer;
var
  Error: Boolean;
  SockHandle: TSocket;
begin
  if Terminated then Result := 0 else
  begin
    Error := False;
    SockHandle := TSocket(CP.Handle);
    Result := _send(SockHandle, Buf, Size, Error, @CP.WriteOL);
    if Error then
    begin
      TSockPort(CP).Err;
      Result := 0
    end;
    if Terminated then Result := 0 else
    if (Result = 0) and (not CP.TempDown) then begin TSockPort(CP).DropDCD; Terminated := True end;
    Inc(TIPMonThread(IPMon).TCPIP_Out, Result);
  end;
end;



function TSockOutThread.Write(const Buf; Size: DWORD): DWORD;

procedure ParseAux(const Arr: TxByteArray; var Rslt: DWORD);

function DoFilter(B: Byte; var I: Byte): Boolean;
begin
  Result := TSockPort(CP).Filter.OutFilter(B, I);
end;

begin
  repeat
    while More do
    begin
      More := DoFilter(0, AuxO[AuxSz]);
      Inc(AuxSz); if AuxSz = Size then Exit;
    end;
    while not More do
    begin
      More := DoFilter(Arr[Rslt], AuxO[AuxSz]);
      Inc(Rslt); Inc(AuxSz);
      if (Rslt = Size) or (AuxSz = PortWriteBlockSize) then Exit;
    end;
  until Terminated;
end;

procedure Flsh;
var
  i: Integer;
begin
  if AuxSz > 0 then
  repeat
    i := SubWrite(AuxO, AuxSz);
    Dec(AuxSz, i);
    if AuxSz > 0 then
    begin
      Move(AuxO[i], AuxO[0], AuxSz);
      if Result = 0 then Break;
    end else Break;
  until Terminated;
end;

begin
  EnterCS(TSockPort(CP).SockW);
  if TSockPort(CP).Filter = nil then Result := SubWrite(Buf, Size) else
  begin
    Result := 0;
    Flsh;
    if AuxSz = 0 then
    begin
      ParseAux(TxByteArray(Buf), Result);
      Flsh;
    end;  
  end;  
  LeaveCS(TSockPort(CP).SockW);
end;



function OpenPort(AHandle: TSocket; Typ: TProtCore; IpPort: DWORD): TSockPort;
var
  F: TTelnetFilter;
begin
  if Typ = ptTelnet then F := TTelnetFilter.Create else F := nil;
  Result := TSockPort.Create(AHandle, F, IpPort, Typ);
  if F <> nil then F.Init;
end;


procedure TSockListen.TheEnd;
begin
  Terminated := True;
  if WinSock2 then
  begin
    SetEvt(oAccept);
  end else
  begin
    __close(SocketHandle);
  end;
end;

class function TSockListen.ThreadName: string;
begin
  Result := 'Socket Listener';
end;


function TSockListen.RecreateHandle: Boolean;
var
  LocalAdr: TSockAddr;
begin
  Result := False;
  SocketHandle := __socket;
  if SocketHandle = INVALID_SOCKET then Exit;
  if __reuse(SocketHandle) = SOCKET_ERROR then Exit;
  if __bind(SocketHandle, IpPort, LocalAdr) = SOCKET_ERROR then Exit;
  if WinSock2 then
  begin
    if __setblock(SocketHandle, 1) = SOCKET_ERROR then Exit;
  end;
  Result := True;
end;

destructor TSockListen.Destroy;
begin
  __close(SocketHandle);
  if WinSock2 then
  begin
    ZeroHandle(oAccept);
  end;
  inherited Destroy;
end;


procedure TSockListen.InvokeExec;

var
  RemoteAddr: TSockAddr;
  RemoteAddrLen: Integer;
  NewHandle: TSocket;
  dd: Integer;
  Thr: TSockPort;
  ne: TWSANetworkEvents;

procedure SendStr(const s: string);
begin
  if __setblock(NewHandle, 1) = SOCKET_ERROR then Exit;
  send(NewHandle, (@s[1])^, Length(s), 0);
  if __setblock(NewHandle, 0) = SOCKET_ERROR then Exit;
end;


begin
  if Terminated then Exit;
  if not Again then
  begin
    Again := True;
    listen(SocketHandle, 5);
  end;
  RemoteAddrLen := SizeOf(RemoteAddr);
  if WinSock2 then
  begin
    WSAEventSelect(SocketHandle, oAccept, FD_ACCEPT);
    WaitEvtInfinite(oAccept);
    if Terminated then Exit;
    Clear(ne, SizeOf(ne));
    dd := WSAEnumNetworkEvents(SocketHandle, oAccept, @ne);
    if dd = SOCKET_ERROR then begin Terminated := True; Exit end;
    if ne.iErrorCode[FD_ACCEPT_BIT] <> 0 then begin Terminated := True; Exit end;
    NewHandle := WSAAccept(SocketHandle, RemoteAddr, RemoteAddrLen, nil, 0);
  end else
  begin
    NewHandle := accept(SocketHandle, @RemoteAddr, @RemoteAddrLen);
  end;

  if NewHandle = INVALID_SOCKET then Terminated := True else
    Inc(SocksAlloc);
  if Terminated then
  begin
    __close(NewHandle);
    Exit;
  end;
  if WinSock2 then
  begin
    __unblock(NewHandle);
  end;
  SockMgr.NewSocks.Enter;
  if SockMgr.SocksAvail = 0 then
  begin
    case Typ of
      ptifcico, ptTelnet : SendStr('BUSY'+ccCR);
      ptBinkP: SendStr(FormatBinkPMsg(M_BSY, 'Too many servers are running'));
      else GlobalFail('%s', ['TSockListen.ThreadExec unknown "Typ"']);
    end;
    Sleep(500); // wait to drain out
    __close(NewHandle);
    SockMgr.NewSocks.Leave;
    Exit;
  end else
  begin
    Dec(SockMgr.SocksAvail);
    Thr := OpenPort(NewHandle, Typ, IpPort);
    Thr.CallerId := Addr2Inet(RemoteAddr.sin_addr.s_addr);
    Thr.Incoming := True;
    SockMgr.NewSocks.Insert(Thr);
    SockMgr.NewSocks.Leave;
    SetEvt(SockMgr.oNewSocks);
  end;
end;

class function TInSockMgr.ThreadName: string;
begin
  Result := 'Socket Acceptor';
end;


procedure TInSockMgr.InvokeExec;
var
  P: TSockPort;
  NL: TNewIpInLine;
begin
  WaitEvtInfinite(oNewSocks);
  if Terminated then Exit;
  NewSocks.Enter;
  while NewSocks.Count > 0 do
  begin
    P := NewSocks[0];
    NewSocks.AtDelete(0);
    NL := TNewIpInLine.Create;
    NL.Port := P;
    NL.Prot := P.Typ;
    NL.IpPort := P.IpPort;
    _PostMessage(MainWinHandle, WM_NEWSOCKPORT, 0, Integer(NL));
  end;
  NewSocks.Leave;
end;

constructor TInSockMgr.Create;
begin
  inherited Create;
  Priority := tpLower;
  oNewSocks := CreateEvtA;
  NewSocks := TColl.Create;
  ListeningSocks := TColl.Create;
end;

destructor  TInSockMgr.Destroy;
begin
  ZeroHandle(oNewSocks);
  FreeObject(ListeningSocks);
  FreeObject(NewSocks);
  inherited Destroy;
end;



procedure CreateListeningSocket(APort: Integer; ATyp: TProtCore);
var
  Thr: TSockListen;
begin
  Thr := TSockListen.Create;
  if WinSock2 then
  begin
    Thr.oAccept := CreateEvt(False);
  end;
  Thr.Typ := ATyp;
  Thr.IpPort := APort;
  Thr.Priority := tpLower;
  if Thr.RecreateHandle then
  begin
    Thr.Suspended := False;
    SockMgr.ListeningSocks.Insert(Thr);
  end else
  begin
    Thr.Terminated := True;
    __close(Thr.SocketHandle);
    Thr.Suspended := False;
    Thr.WaitFor;
    FreeObject(Thr);
  end;
end;

var
  ConnThrs: TColl;
  ResolveThr: TResolveThread;

procedure HostResolveComplete(Idx, lParam: Integer);
begin
  if (ResolveThr = nil) or (ResolveThr.Terminated) then Exit;
  EnterCS(ResolveThr.CS);
  ResolveThr.HostResolveComplete(Idx, lParam);
  LeaveCS(ResolveThr.CS);
end;



function RunDaemon;

procedure DoIt(var A: TvIntArr; Typ: TProtCore);
var
  i: Integer;
begin
  for i := 0 to A.Cnt-1 do CreateListeningSocket(A.Arr^[I], Typ);
end;

var
  d: TWSAData;
  i: Integer;

begin
  Result := False;
  if not WSAStarted then
  begin
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin
      i := WSAStartup(2, d);
    end else
    begin
      i := WSAStartup($101, d);
    end;
    if i <> 0 then
    begin
      DisplayError(Format('Can''t initialize sockets API, error #%d', [i]), 0);
      Exit;
    end;
    WSAStarted := True;
  end;
  ConnThrs := TColl.Create;
  ResolveThr := TResolveThread.Create;
  SockMgr := TInSockMgr.Create;
  SockMgr.SocksAvail := Params.InConns;
  OutConnsAvail := Params.OutConns;
  DoIt(Params.ifcico, ptifcico);
  DoIt(Params.Telnet, ptTelnet);
  DoIt(Params.BinkP, ptBinkP);
  ResolveThr.Suspended := False;
  SockMgr.Suspended := False;
  IPMon := TIpMonThread.Create;
  IPMon.Suspended := False;
  Result := True;
end;

type
  TWSAConnectThread = class(T_Thread)
    ReadOL, WriteOL : TOverLapped;
    SocketConnected: Boolean;
    Addr: string;
    cr: TWSAConnectResult;
    Port: DWORD;
    Prot: TProtCore;
    oBlk: THandle;
    FSocket: TSocket;
    procedure InvokeExec; override;
    constructor Create(const AAddr: string; p: Pointer; AProt: TProtCore; APort: Integer);
    destructor Destroy; override;
    class function ThreadName: string; override;
  public
    procedure TheEnd;
  end;

procedure EndSockMgr;
begin
  SockMgr.Terminated := True;
  ResolveThr.Terminated := True;
  SetEvt(SockMgr.oNewSocks);
  SetEvt(ResolveThr.oAsyncAvail);
  SetEvt(ResolveThr.oStartResolve);
  SockMgr.WaitFor;
  ResolveThr.WaitFor;
end;

procedure EndIpThreads;
var
  i: Integer;
  s: TSockListen;
  c: TWSAConnectThread;
begin
  for i := 0 to SockMgr.ListeningSocks.Count-1 do begin s := SockMgr.ListeningSocks[i]; s.TheEnd end;
  for i := 0 to ConnThrs.Count-1 do begin c := ConnThrs[i]; c.TheEnd end;
  for i := 0 to SockMgr.ListeningSocks.Count-1 do begin s := SockMgr.ListeningSocks[i]; s.WaitFor end;
  for i := 0 to ConnThrs.Count-1 do begin c := ConnThrs[i]; c.WaitFor end;
end;

procedure ShutdownDaemon;
var
  e: Integer;
begin
  ConnThrs.FreeAll;
  FreeObject(ConnThrs);
  SockMgr.ListeningSocks.FreeAll;
  FreeObject(SockMgr);
  FreeObject(ResolveThr);
  if SocksAlloc <> 0 then
  begin
    if not DisableWinsockTraps then GlobalFail('SocksAlloc = %d after ShutdownDaemon', [SocksAlloc]);
  end;
  if not SkipCleanup then
  begin
    e := WSACleanup;
    if e <> 0 then  GlobalFail('WSACleanUp Error %d (%s)', [e, WSAErrMsg(e)]);
    WSAStarted := False;
  end;
end;

procedure PurgeConnThrs;
var
  i: Integer;
  t: TWSAConnectThread;
begin
  ConnThrs.Enter;
  for i := ConnThrs.Count - 1 downto 0 do
  begin
    t := ConnThrs[i];
    if not t.Terminated then Continue;
    t.WaitFor;
    ConnThrs.AtFree(i);
  end;
  ConnThrs.Leave;
end;


function Addr2Inet(i: DWORD): string;
begin
  Result := Format('%d.%d.%d.%d', [
        (i shr  0) and $FF,
        (i shr  8) and $FF,
        (i shr 16) and $FF,
        (i shr 24) and $FF
        ]);
end;

class function TWSAConnectThread.ThreadName: string;
begin
  Result := 'Socket Connector';
end;

procedure TWSAConnectThread.TheEnd;
begin
  if WaitForSingleObject(FThreadHandle, 0) = WAIT_OBJECT_0 then begin Terminated := True; Exit end;
  Suspend;
  Terminated := True;
  SetEvt(oBlk);
  if WinSock2 then
  begin
    if ProxyEnabled then
    begin
      SetEvt(ReadOL.hEvent);
      SetEvt(WriteOL.hEvent);
    end;
  end else
  begin
    if ProxyEnabled then
    begin
      if (FSocket <> 0) and (FSocket <> INVALID_SOCKET) and SocketConnected then
      begin
        SocketConnected := False;
        __shutdown(FSocket);
      end;
    end;
  end;
  Resume;
end;

function CoolResolve(const Addr: string; oBlk: DWORD; var Error: Integer): DWORD;
var
  ia: DWORD;
  aa: string;
  req: TResolveRequest;
  rsp: TResolveResponse;
  i: Integer;
begin
  ia := Inet2Addr(Addr);
  if ia = INADDR_NONE then
  begin
    aa := Sym2Addr(Addr);
    req := TResolveRequest.Create;
    req.HostName := StrAsg(aa);
    req.oEvt := oBlk;
    EnterCS(ResolveThr.CS);
    ResolveThr.InReq.Insert(req);
    SetEvt(ResolveThr.oStartResolve);
    LeaveCS(ResolveThr.CS);
    WaitEvtInfinite(oBlk);
    ResetEvt(oBlk);
    EnterCS(ResolveThr.CS);
    for i := 0 to ResolveThr.Resp.Count-1 do
    begin
      rsp := ResolveThr.Resp[i];
      if rsp.HostName = aa then
      begin
        if rsp.Error = 0 then ia := rsp.Addr else
        begin
          ia := INADDR_NONE;
          Error := rsp.Error;
        end;
      end;
    end;
    LeaveCS(ResolveThr.CS);
  end;
  Result := ia;
end;

function ConnectProxy(AHandle, AAddr, APort: DWORD; ReadOL, WriteOL: POverlapped): Integer;
type
  TSocksRequest = packed record
    VN: Byte;
    CD: Byte;
    DstPort: Word;
    DstIP: DWORD;
  end;
const
  cszr = SizeOf(TSocksRequest);
var
  r: TSocksRequest;
  j, i: Integer;
  UserId: string;
  p: PxByteArray;
  Error: Boolean;
  szr: Integer;
begin
  szr := cszr;
  Error := False;
  UserId := 'ARGUS'#0;
  Clear(r, szr);
  r.VN := 4;
  r.CD := 1;
  r.DstPort := htons(APort);
  r.DstIP := AAddr;
  i := _send(AHandle, r, szr, Error, WriteOL);
  if Error then begin Result := WSAGetLastError; Exit end;
  if (i <> szr) then begin Result := -91; Exit end; //SOCKS request rejected or failed;
  j := Length(UserId);
  i := _send(AHandle, UserId[1], j, Error, WriteOL);
  if Error then begin Result := WSAGetLastError; Exit end;
  if i <> j then begin Result := -91; Exit end; //SOCKS request rejected or failed;
  p := @r;
  j := 0;
  repeat
    szr := cszr - j;
    i := _recv(AHandle, p^[j], szr, Error, ReadOL);
    if Error then begin Result := WSAGetLastError; Exit end;
    if i <= 0 then begin Result := -91; Exit end; //SOCKS request rejected or failed;
    Inc(j, i);
  until j >= cszr;
  if r.CD <> 90 then
  begin
    Result := -r.CD;
    Exit;
  end;
  Result := 0;
end;

procedure TWSAConnectThread.InvokeExec;

var
//  h: Integer;
 ia: DWORD;
 dd: Integer;

function DoIt: Integer;
var
  Adr: TSockAddr;
  ne: TWSANetworkEvents;
  FAddr, FPort: DWORD;
begin
  Result := -1;
  ia := CoolResolve(Addr, oBlk, Result);
  if ia = INADDR_NONE then Exit;
  cr.ResolvedAddr := ia;
  if Terminated then Exit;
  FSocket := __socket;
  if FSocket = INVALID_SOCKET then begin Result := WSAGetLastError; Exit end;
  if Terminated then Exit;

  if WinSock2 then
  begin
    __setblock(FSocket, 1);
  end;

  Adr.sin_family      := AF_INET;
  if ProxyEnabled then
  begin
    FPort := ProxyPort;
    FAddr := CoolResolve(ProxyAddr, oBlk, Result);
    if FAddr = INADDR_NONE then Exit;
  end else
  begin
    FPort := Port;
    FAddr := ia;
  end;

  Adr.sin_port        := htons(FPort);
  Adr.sin_addr.s_addr := FAddr;

  if WinSock2 then
  begin
    dd := WSAEventSelect(FSocket, oBlk, FD_CONNECT);
    if dd = SOCKET_ERROR then
    begin
      Result := WSAGetLastError; Exit
    end;
    dd := WSAConnect(FSocket, Adr, SizeOf(Adr), nil, nil, nil, nil);
    if (dd = SOCKET_ERROR) then
    begin
      Result := WSAGetLastError;
      if Result <> WSAEWOULDBLOCK then Exit;
      WaitEvtInfinite(oBlk);
      if Terminated then Exit;
      Clear(ne, SizeOf(ne));
      dd := WSAEnumNetworkEvents(FSocket, oBlk, @ne);
      if dd = SOCKET_ERROR then
      begin
        Result := WSAGetLastError; Exit
      end;
      Result := ne.iErrorCode[FD_CONNECT_BIT]; {!!!}
      if Result <> 0 then Exit;
    end;
  end else
  begin
    dd := connect(FSocket, Adr, SizeOf(Adr));
    if dd = SOCKET_ERROR then
    begin
      Result := WSAGetLastError; Exit
    end;
  end;

  if Terminated then Exit;

  SocketConnected := True;

  if ProxyEnabled then
  begin
    Result := ConnectProxy(FSocket, ia, Port, @ReadOL, @WriteOL);
    if Result <> 0 then Exit;
  end;

  if Terminated then Exit;

  if WinSock2 then
  begin
    __unblock(FSocket);
  end;

  Result := 0;
  cr.Prot := Prot;
  cr.Error := False;
end;

begin
  FSocket := INVALID_SOCKET;
  cr.Res := DoIt;
  cr.Terminated := Terminated;
  if (not cr.Terminated) and (not cr.Error) then cr.Port := OpenPort(FSocket, Prot, cr.IpPort);
  if (cr.Port = nil) then
  begin
    __close(FSocket);
    Inc(OutConnsAvail);
  end;
  if cr.Port <> nil then
  begin
    TDevicePort(cr.Port).CallerId := Addr2Inet(ia);
  end;
  _PostMessage(MainWinHandle, WM_CONNECTRES, 0, Integer(cr));
  Terminated := True;
end;

constructor TWSAConnectThread.Create;
begin
  inherited Create;
  if WinSock2 then
  begin
    if ProxyEnabled then
    begin
      ReadOL.hEvent := CreateEvt(False);
      WriteOL.hEvent := CreateEvt(False);
    end;
  end;
  cr := TWSAConnectResult.Create;
  cr.IpPort := APort;
  cr.p := p;
  cr.ResolvedAddr := INADDR_NONE;
  cr.Error := True;
  Port := APort;
  Prot := AProt;
  Priority := tpLowest;
  Addr := AAddr;
  oBlk := CreateEvt(False);
end;

destructor TWSAConnectThread.Destroy;
begin
  if WinSock2 then
  begin
    if ProxyEnabled then
    begin
      ZeroHandle(ReadOL.hEvent);
      ZeroHandle(WriteOL.hEvent);
    end;
  end;
  ZeroHandle(oBlk);
  inherited Destroy;
end;


procedure _WSAConnect;
var
  thr: TWSAConnectThread;
begin
  thr := TWSAConnectThread.Create(Addr, p, AProt, APort);
  ConnThrs.Enter;
  ConnThrs.Insert(thr);
  ConnThrs.Leave;
  Dec(OutConnsAvail);
  thr.Suspended := False;
end;

class function TIPMonThread.ThreadName: string;
begin
  Result := 'TCP/IP Monitor';
end;


constructor TIPMonThread.Create;
begin
  inherited Create;
  Priority := tpHighest;
  InitializeCriticalSection(TCPIP_GrCS);
end;

destructor TIPMonThread.Destroy;
begin
  DeleteCriticalSection(TCPIP_GrCS);
  inherited Destroy;
end;

procedure TIPMonThread.InvokeExec;
var
  _in, _out, i: Integer;
begin
  if not Again then
  begin
    Again := True;
    for i := 0 to TCPIP_GrDataSz-1 do
    begin
      TCPIP_OutGr[i] := -1;
      TCPIP_InGr[i] := -1;
    end;
  end;

  Move(MemOut[0], MemOut[1], (DaemonMemSize-1)*SizeOf(Integer));
  MemOut[0] := 0; XChg(TCPIP_Out, MemOut[0]);

  Move(MemIn[0], MemIn[1], (DaemonMemSize-1)*SizeOf(Integer));
  MemIn[0] := 0; XChg(TCPIP_In, MemIn[0]);

  Inc(TCPIP_GrStep);

  EnterCS(TCPIP_GrCS);
  _in := 0; for i := 0 to DaemonMemSize-1 do Inc(_in, MemIn[i]);
  _out := 0; for i := 0 to DaemonMemSize-1 do Inc(_out, MemOut[i]);

  Move(TCPIP_OutGr[1], TCPIP_OutGr[0], (TCPIP_GrDataSz-1)*SizeOf(Integer));
  TCPIP_OutGr[TCPIP_GrDataSz-1] := _out;
  TCPIP_OutR := _out;

  Move(TCPIP_InGr[1], TCPIP_InGr[0], (TCPIP_GrDataSz-1)*SizeOf(Integer));
  TCPIP_InGr[TCPIP_GrDataSz-1] := _in;
  TCPIP_InR := _in;

  LeaveCS(TCPIP_GrCS);

  Sleep(1000);
end;

procedure TSockPort.SleepDown;
begin
  ResetEvt(oTempDown);
  TempDown := True;
  SetEvt(ReadOL.hEvent);
  SetEvt(StatOL.hEvent);
end;

procedure TSockPort.WakeUp;
begin
  TempDown := False;
  SetEvt(oTempDown);
end;

procedure TSockPort.SaveParams;
begin
end;

procedure TSockPort.RestoreParams;
begin
end;

procedure TSockPort.HWPurge(Typ: TTxRxSet);
begin
end;



{$ENDIF}

end.
