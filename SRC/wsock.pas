// This unit was originally taken from Delphi5 source
// directory (SOURCE/RTL/WIN/WINSOCK.PAS) and modified by
// Max Masyutin to dinamically import WinSocket (v1/v2)
// functions.


{*******************************************************}
{                                                       }
{       Borland Delphi Runtime Library                  }
{       Win32 sockets API Interface Unit                }
{                                                       }
{       Copyright (C) 1996,99 Inprise Corporation       }
{                                                       }
{*******************************************************}

unit WSock;

interface

uses Windows;

{ HPPEMIT '#include <windows.h>'}

type
  u_char = Char;
  u_short = Word;
  u_int = Integer;
  u_long = Longint;

{ The new type to be used in all
  instances which refer to sockets. }
  TSocket = THandle;

const
  FD_SETSIZE     =   64;

type
// the following emits are a workaround to the name conflict with
// procedure FD_SET and struct fd_set in winsock.h
(*$HPPEMIT '#include <winsock.h>'*)
(*$HPPEMIT 'namespace Winsock'*)
(*$HPPEMIT '{'*)
(*$HPPEMIT 'typedef fd_set *PFDSet;'*) // due to name conflict with procedure FD_SET
(*$HPPEMIT 'typedef fd_set TFDSet;'*)  // due to name conflict with procedure FD_SET
(*$HPPEMIT '}'*)

  {$NODEFINE PFDSet}
  PFDSet = ^TFDSet;
  {$NODEFINE TFDSet}
  TFDSet = record
    fd_count: u_int;
    fd_array: array[0..FD_SETSIZE-1] of TSocket;
  end;

  PTimeVal = ^TTimeVal;
  timeval = record
    tv_sec: Longint;
    tv_usec: Longint;
  end;
  TTimeVal = timeval;

const
  IOCPARM_MASK = $7f;
  IOC_VOID     = $20000000;
  IOC_OUT      = $40000000;
  IOC_IN       = $80000000;
  IOC_INOUT    = (IOC_IN or IOC_OUT);

  FIONREAD     = IOC_OUT or { get # bytes to read }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 127;
  FIONBIO      = IOC_IN or { set/clear non-blocking i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 126;
  FIOASYNC     = IOC_IN or { set/clear async i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 125;

type
  PHostEnt = ^THostEnt;
  hostent = record
    h_name: PChar;
    h_aliases: ^PChar;
    h_addrtype: Smallint;
    h_length: Smallint;
    case Byte of
      0: (h_addr_list: ^PChar);
      1: (h_addr: ^PChar)
  end;
  THostEnt = hostent;

  PNetEnt = ^TNetEnt;
  netent = record
    n_name: PChar;
    n_aliases: ^PChar;
    n_addrtype: Smallint;
    n_net: u_long;
  end;
  TNetEnt = netent;

  PServEnt = ^TServEnt;
  servent = record
    s_name: PChar;
    s_aliases: ^PChar;
    s_port: Word;
    s_proto: PChar;
  end;
  TServEnt = servent;

  PProtoEnt = ^TProtoEnt;
  protoent = record
    p_name: PChar;
    p_aliases: ^Pchar;
    p_proto: Smallint;
  end;
  TProtoEnt = protoent;

const

{ Protocols }

  IPPROTO_IP     =   0;             { dummy for IP }
  IPPROTO_ICMP   =   1;             { control message protocol }
  IPPROTO_IGMP   =   2;             { group management protocol }
  IPPROTO_GGP    =   3;             { gateway^2 (deprecated) }
  IPPROTO_TCP    =   6;             { tcp }
  IPPROTO_PUP    =  12;             { pup }
  IPPROTO_UDP    =  17;             { user datagram protocol }
  IPPROTO_IDP    =  22;             { xns idp }
  IPPROTO_ND     =  77;             { UNOFFICIAL net disk proto }

  IPPROTO_RAW    =  255;            { raw IP packet }
  IPPROTO_MAX    =  256;

{ Port/socket numbers: network standard functions}

  IPPORT_ECHO    =   7;
  IPPORT_DISCARD =   9;
  IPPORT_SYSTAT  =   11;
  IPPORT_DAYTIME =   13;
  IPPORT_NETSTAT =   15;
  IPPORT_FTP     =   21;
  IPPORT_TELNET  =   23;
  IPPORT_SMTP    =   25;
  IPPORT_TIMESERVER  =  37;
  IPPORT_NAMESERVER  =  42;
  IPPORT_WHOIS       =  43;
  IPPORT_MTP         =  57;

{ Port/socket numbers: host specific functions }

  IPPORT_TFTP        =  69;
  IPPORT_RJE         =  77;
  IPPORT_FINGER      =  79;
  IPPORT_TTYLINK     =  87;
  IPPORT_SUPDUP      =  95;

{ UNIX TCP sockets }

  IPPORT_EXECSERVER  =  512;
  IPPORT_LOGINSERVER =  513;
  IPPORT_CMDSERVER   =  514;
  IPPORT_EFSSERVER   =  520;

{ UNIX UDP sockets }

  IPPORT_BIFFUDP     =  512;
  IPPORT_WHOSERVER   =  513;
  IPPORT_ROUTESERVER =  520;

{ Ports < IPPORT_RESERVED are reserved for
  privileged processes (e.g. root). }

  IPPORT_RESERVED    =  1024;

{ Link numbers }

  IMPLINK_IP         =  155;
  IMPLINK_LOWEXPER   =  156;
  IMPLINK_HIGHEXPER  =  158;

type
  SunB = packed record
    s_b1, s_b2, s_b3, s_b4: u_char;
  end;

  SunW = packed record
    s_w1, s_w2: u_short;
  end;

  PInAddr = ^TInAddr;
  in_addr = record
    case integer of
      0: (S_un_b: SunB);
      1: (S_un_w: SunW);
      2: (S_addr: u_long);
  end;
  TInAddr = in_addr;

  PSockAddrIn = ^TSockAddrIn;
  sockaddr_in = record
    case Integer of
      0: (sin_family: u_short;
          sin_port: u_short;
          sin_addr: TInAddr;
          sin_zero: array[0..7] of Char);
      1: (sa_family: u_short;
          sa_data: array[0..13] of Char)
  end;
  TSockAddrIn = sockaddr_in;

const
  INADDR_ANY       = $00000000;
  INADDR_LOOPBACK  = $7F000001;
  INADDR_BROADCAST = $FFFFFFFF;
  INADDR_NONE      = $FFFFFFFF;

  WSADESCRIPTION_LEN     =   256;
  WSASYS_STATUS_LEN      =   128;

type
  PWSAData = ^TWSAData;
  WSAData = record // !!! also WSDATA
    wVersion: Word;
    wHighVersion: Word;
    szDescription: array[0..WSADESCRIPTION_LEN] of Char;
    szSystemStatus: array[0..WSASYS_STATUS_LEN] of Char;
    iMaxSockets: Word;
    iMaxUdpDg: Word;
    lpVendorInfo: PChar;
  end;
  TWSAData = WSAData;

  PTransmitFileBuffers = ^TTransmitFileBuffers;
  _TRANSMIT_FILE_BUFFERS = record
      Head: Pointer;
      HeadLength: DWORD;
      Tail: Pointer;
      TailLength: DWORD;
  end;
  TTransmitFileBuffers = _TRANSMIT_FILE_BUFFERS;
  TRANSMIT_FILE_BUFFERS = _TRANSMIT_FILE_BUFFERS;


const
  TF_DISCONNECT           = $01;
  TF_REUSE_SOCKET         = $02;
  TF_WRITE_BEHIND         = $04;

{ Options for use with [gs]etsockopt at the IP level. }

  IP_OPTIONS          = 1;
  IP_MULTICAST_IF     = 2;           { set/get IP multicast interface   }
  IP_MULTICAST_TTL    = 3;           { set/get IP multicast timetolive  }
  IP_MULTICAST_LOOP   = 4;           { set/get IP multicast loopback    }
  IP_ADD_MEMBERSHIP   = 5;           { add  an IP group membership      }
  IP_DROP_MEMBERSHIP  = 6;           { drop an IP group membership      }
  IP_TTL              = 7;           { set/get IP Time To Live          }
  IP_TOS              = 8;           { set/get IP Type Of Service       }
  IP_DONTFRAGMENT     = 9;           { set/get IP Don't Fragment flag   }


  IP_DEFAULT_MULTICAST_TTL   = 1;    { normally limit m'casts to 1 hop  }
  IP_DEFAULT_MULTICAST_LOOP  = 1;    { normally hear sends if a member  }
  IP_MAX_MEMBERSHIPS         = 20;   { per socket; must fit in one mbuf }

{ This is used instead of -1, since the
  TSocket type is unsigned.}

  INVALID_SOCKET		= TSocket(NOT(0));
  SOCKET_ERROR			= -1;

{ Types }

  SOCK_STREAM     = 1;               { stream socket }
  SOCK_DGRAM      = 2;               { datagram socket }
  SOCK_RAW        = 3;               { raw-protocol interface }
  SOCK_RDM        = 4;               { reliably-delivered message }
  SOCK_SEQPACKET  = 5;               { sequenced packet stream }

{ Option flags per-socket. }

  SO_DEBUG        = $0001;          { turn on debugging info recording }
  SO_ACCEPTCONN   = $0002;          { socket has had listen() }
  SO_REUSEADDR    = $0004;          { allow local address reuse }
  SO_KEEPALIVE    = $0008;          { keep connections alive }
  SO_DONTROUTE    = $0010;          { just use interface addresses }
  SO_BROADCAST    = $0020;          { permit sending of broadcast msgs }
  SO_USELOOPBACK  = $0040;          { bypass hardware when possible }
  SO_LINGER       = $0080;          { linger on close if data present }
  SO_OOBINLINE    = $0100;          { leave received OOB data in line }

  SO_DONTLINGER  =   $ff7f;

{ Additional options. }

  SO_SNDBUF       = $1001;          { send buffer size }
  SO_RCVBUF       = $1002;          { receive buffer size }
  SO_SNDLOWAT     = $1003;          { send low-water mark }
  SO_RCVLOWAT     = $1004;          { receive low-water mark }
  SO_SNDTIMEO     = $1005;          { send timeout }
  SO_RCVTIMEO     = $1006;          { receive timeout }
  SO_ERROR        = $1007;          { get error status and clear }
  SO_TYPE         = $1008;          { get socket type }

{ Options for connect and disconnect data and options.  Used only by
  non-TCP/IP transports such as DECNet, OSI TP4, etc. }

  SO_CONNDATA     = $7000;
  SO_CONNOPT      = $7001;
  SO_DISCDATA     = $7002;
  SO_DISCOPT      = $7003;
  SO_CONNDATALEN  = $7004;
  SO_CONNOPTLEN   = $7005;
  SO_DISCDATALEN  = $7006;
  SO_DISCOPTLEN   = $7007;

{ Option for opening sockets for synchronous access. }

  SO_OPENTYPE     = $7008;

  SO_SYNCHRONOUS_ALERT    = $10;
  SO_SYNCHRONOUS_NONALERT = $20;

{ Other NT-specific options. }

  SO_MAXDG        = $7009;
  SO_MAXPATHDG    = $700A;
  SO_UPDATE_ACCEPT_CONTEXT     = $700B;
  SO_CONNECT_TIME = $700C;

{ TCP options. }

  TCP_NODELAY     = $0001;
  TCP_BSDURGENT   = $7000;

{ Address families. }

  AF_UNSPEC       = 0;               { unspecified }
  AF_UNIX         = 1;               { local to host (pipes, portals) }
  AF_INET         = 2;               { internetwork: UDP, TCP, etc. }
  AF_IMPLINK      = 3;               { arpanet imp addresses }
  AF_PUP          = 4;               { pup protocols: e.g. BSP }
  AF_CHAOS        = 5;               { mit CHAOS protocols }
  AF_IPX          = 6;               { IPX and SPX }
  AF_NS           = 6;               { XEROX NS protocols }
  AF_ISO          = 7;               { ISO protocols }
  AF_OSI          = AF_ISO;          { OSI is ISO }
  AF_ECMA         = 8;               { european computer manufacturers }
  AF_DATAKIT      = 9;               { datakit protocols }
  AF_CCITT        = 10;              { CCITT protocols, X.25 etc }
  AF_SNA          = 11;              { IBM SNA }
  AF_DECnet       = 12;              { DECnet }
  AF_DLI          = 13;              { Direct data link interface }
  AF_LAT          = 14;              { LAT }
  AF_HYLINK       = 15;              { NSC Hyperchannel }
  AF_APPLETALK    = 16;              { AppleTalk }
  AF_NETBIOS      = 17;              { NetBios-style addresses }
  AF_VOICEVIEW    = 18;              { VoiceView }
  AF_FIREFOX      = 19;              { FireFox }
  AF_UNKNOWN1     = 20;              { Somebody is using this! }
  AF_BAN          = 21;              { Banyan }

  AF_MAX          = 22;

type
  { Structure used by kernel to store most addresses. }

  PSOCKADDR = ^TSockAddr;
  TSockAddr = sockaddr_in;


  { Structure used by kernel to pass protocol information in raw sockets. }
  PSockProto = ^TSockProto;
  sockproto = record
    sp_family: u_short;
    sp_protocol: u_short;
  end;
  TSockProto = sockproto;

const
{ Protocol families, same as address families for now. }

  PF_UNSPEC       = AF_UNSPEC;
  PF_UNIX         = AF_UNIX;
  PF_INET         = AF_INET;
  PF_IMPLINK      = AF_IMPLINK;
  PF_PUP          = AF_PUP;
  PF_CHAOS        = AF_CHAOS;
  PF_NS           = AF_NS;
  PF_IPX          = AF_IPX;
  PF_ISO          = AF_ISO;
  PF_OSI          = AF_OSI;
  PF_ECMA         = AF_ECMA;
  PF_DATAKIT      = AF_DATAKIT;
  PF_CCITT        = AF_CCITT;
  PF_SNA          = AF_SNA;
  PF_DECnet       = AF_DECnet;
  PF_DLI          = AF_DLI;
  PF_LAT          = AF_LAT;
  PF_HYLINK       = AF_HYLINK;
  PF_APPLETALK    = AF_APPLETALK;
  PF_VOICEVIEW    = AF_VOICEVIEW;
  PF_FIREFOX      = AF_FIREFOX;
  PF_UNKNOWN1     = AF_UNKNOWN1;
  PF_BAN          = AF_BAN;

  PF_MAX          = AF_MAX;

type
{ Structure used for manipulating linger option. }
  PLinger = ^TLinger;
  linger = record
    l_onoff: u_short;
    l_linger: u_short;
  end;
  TLinger = linger;

const
{ Level number for (get/set)sockopt() to apply to socket itself. }

  SOL_SOCKET      = $ffff;          {options for socket level }

{ Maximum queue length specifiable by listen. }

  SOMAXCONN       = 5;

  MSG_OOB         = $1;             {process out-of-band data }
  MSG_PEEK        = $2;             {peek at incoming message }
  MSG_DONTROUTE   = $4;             {send without using routing tables }

  MSG_MAXIOVLEN   = 16;

  MSG_PARTIAL     = $8000;          {partial send or recv for message xport }

{ Define constant based on rfc883, used by gethostbyxxxx() calls. }

  MAXGETHOSTSTRUCT        = 1024;

{ All Windows Sockets error constants are biased by WSABASEERR from the "normal" }

  WSABASEERR              = 10000;

{ Windows Sockets definitions of regular Microsoft C error constants }

  WSAEINTR                = (WSABASEERR+4);
  WSAEBADF                = (WSABASEERR+9);
  WSAEACCES               = (WSABASEERR+13);
  WSAEFAULT               = (WSABASEERR+14);
  WSAEINVAL               = (WSABASEERR+22);
  WSAEMFILE               = (WSABASEERR+24);

{ Windows Sockets definitions of regular Berkeley error constants }

  WSAEWOULDBLOCK          = (WSABASEERR+35);
  WSAEINPROGRESS          = (WSABASEERR+36);
  WSAEALREADY             = (WSABASEERR+37);
  WSAENOTSOCK             = (WSABASEERR+38);
  WSAEDESTADDRREQ         = (WSABASEERR+39);
  WSAEMSGSIZE             = (WSABASEERR+40);
  WSAEPROTOTYPE           = (WSABASEERR+41);
  WSAENOPROTOOPT          = (WSABASEERR+42);
  WSAEPROTONOSUPPORT      = (WSABASEERR+43);
  WSAESOCKTNOSUPPORT      = (WSABASEERR+44);
  WSAEOPNOTSUPP           = (WSABASEERR+45);
  WSAEPFNOSUPPORT         = (WSABASEERR+46);
  WSAEAFNOSUPPORT         = (WSABASEERR+47);
  WSAEADDRINUSE           = (WSABASEERR+48);
  WSAEADDRNOTAVAIL        = (WSABASEERR+49);
  WSAENETDOWN             = (WSABASEERR+50);
  WSAENETUNREACH          = (WSABASEERR+51);
  WSAENETRESET            = (WSABASEERR+52);
  WSAECONNABORTED         = (WSABASEERR+53);
  WSAECONNRESET           = (WSABASEERR+54);
  WSAENOBUFS              = (WSABASEERR+55);
  WSAEISCONN              = (WSABASEERR+56);
  WSAENOTCONN             = (WSABASEERR+57);
  WSAESHUTDOWN            = (WSABASEERR+58);
  WSAETOOMANYREFS         = (WSABASEERR+59);
  WSAETIMEDOUT            = (WSABASEERR+60);
  WSAECONNREFUSED         = (WSABASEERR+61);
  WSAELOOP                = (WSABASEERR+62);
  WSAENAMETOOLONG         = (WSABASEERR+63);
  WSAEHOSTDOWN            = (WSABASEERR+64);
  WSAEHOSTUNREACH         = (WSABASEERR+65);
  WSAENOTEMPTY            = (WSABASEERR+66);
  WSAEPROCLIM             = (WSABASEERR+67);
  WSAEUSERS               = (WSABASEERR+68);
  WSAEDQUOT               = (WSABASEERR+69);
  WSAESTALE               = (WSABASEERR+70);
  WSAEREMOTE              = (WSABASEERR+71);

  WSAEDISCON              = (WSABASEERR+101);

{ Extended Windows Sockets error constant definitions }

  WSASYSNOTREADY          = (WSABASEERR+91);
  WSAVERNOTSUPPORTED      = (WSABASEERR+92);
  WSANOTINITIALISED       = (WSABASEERR+93);

{ Error return codes from gethostbyname() and gethostbyaddr()
  (when using the resolver). Note that these errors are
  retrieved via WSAGetLastError() and must therefore follow
  the rules for avoiding clashes with error numbers from
  specific implementations or language run-time systems.
  For this reason the codes are based at WSABASEERR+1001.
  Note also that [WSA]NO_ADDRESS is defined only for
  compatibility purposes. }

{ Authoritative Answer: Host not found }

  WSAHOST_NOT_FOUND       = (WSABASEERR+1001);
  HOST_NOT_FOUND          = WSAHOST_NOT_FOUND;

{ Non-Authoritative: Host not found, or SERVERFAIL }

  WSATRY_AGAIN            = (WSABASEERR+1002);
  TRY_AGAIN               = WSATRY_AGAIN;

{ Non recoverable errors, FORMERR, REFUSED, NOTIMP }

  WSANO_RECOVERY          = (WSABASEERR+1003);
  NO_RECOVERY             = WSANO_RECOVERY;

{ Valid name, no data record of requested type }

  WSANO_DATA              = (WSABASEERR+1004);
  NO_DATA                 = WSANO_DATA;

{ no address, look for MX record }

  WSANO_ADDRESS           = WSANO_DATA;
  NO_ADDRESS              = WSANO_ADDRESS;

{ Windows Sockets errors redefined as regular Berkeley error constants.
  These are commented out in Windows NT to avoid conflicts with errno.h.
  Use the WSA constants instead. }

  EWOULDBLOCK        =  WSAEWOULDBLOCK;
  EINPROGRESS        =  WSAEINPROGRESS;
  EALREADY           =  WSAEALREADY;
  ENOTSOCK           =  WSAENOTSOCK;
  EDESTADDRREQ       =  WSAEDESTADDRREQ;
  EMSGSIZE           =  WSAEMSGSIZE;
  EPROTOTYPE         =  WSAEPROTOTYPE;
  ENOPROTOOPT        =  WSAENOPROTOOPT;
  EPROTONOSUPPORT    =  WSAEPROTONOSUPPORT;
  ESOCKTNOSUPPORT    =  WSAESOCKTNOSUPPORT;
  EOPNOTSUPP         =  WSAEOPNOTSUPP;
  EPFNOSUPPORT       =  WSAEPFNOSUPPORT;
  EAFNOSUPPORT       =  WSAEAFNOSUPPORT;
  EADDRINUSE         =  WSAEADDRINUSE;
  EADDRNOTAVAIL      =  WSAEADDRNOTAVAIL;
  ENETDOWN           =  WSAENETDOWN;
  ENETUNREACH        =  WSAENETUNREACH;
  ENETRESET          =  WSAENETRESET;
  ECONNABORTED       =  WSAECONNABORTED;
  ECONNRESET         =  WSAECONNRESET;
  ENOBUFS            =  WSAENOBUFS;
  EISCONN            =  WSAEISCONN;
  ENOTCONN           =  WSAENOTCONN;
  ESHUTDOWN          =  WSAESHUTDOWN;
  ETOOMANYREFS       =  WSAETOOMANYREFS;
  ETIMEDOUT          =  WSAETIMEDOUT;
  ECONNREFUSED       =  WSAECONNREFUSED;
  ELOOP              =  WSAELOOP;
  ENAMETOOLONG       =  WSAENAMETOOLONG;
  EHOSTDOWN          =  WSAEHOSTDOWN;
  EHOSTUNREACH       =  WSAEHOSTUNREACH;
  ENOTEMPTY          =  WSAENOTEMPTY;
  EPROCLIM           =  WSAEPROCLIM;
  EUSERS             =  WSAEUSERS;
  EDQUOT             =  WSAEDQUOT;
  ESTALE             =  WSAESTALE;
  EREMOTE            =  WSAEREMOTE;

// function getpeername(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer; stdcall;
// function getsockname(s: TSocket; var name: TSockAddr; var namelen: Integer): Integer; stdcall;
// function getsockopt(s: TSocket; level, optname: Integer; optval: PChar; var optlen: Integer): Integer; stdcall;
// function htonl(hostlong: u_long): u_long; stdcall;
// function inet_ntoa(inaddr: TInAddr): PChar; stdcall;
// function ntohl(netlong: u_long): u_long; stdcall;
// function ntohs(netshort: u_short): u_short; stdcall;
// function recvfrom(s: TSocket; var Buf; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
// function select(nfds: Integer; readfds, writefds, exceptfds: PFDSet; timeout: PTimeVal): Longint; stdcall;
// function sendto(s: TSocket; var Buf; len, flags: Integer; var addrto: TSockAddr; tolen: Integer): Integer; stdcall;
// function gethostbyaddr(addr: Pointer; len, Struct: Integer): PHostEnt; stdcall;
// function gethostbyname(name: PChar): PHostEnt; stdcall;
// function gethostname(name: PChar; len: Integer): Integer; stdcall;
// function getservbyport(port: Integer; proto: PChar): PServEnt; stdcall;
// function getservbyname(name, proto: PChar): PServEnt; stdcall;
// function getprotobynumber(proto: Integer): PProtoEnt; stdcall;
// function getprotobyname(name: PChar): PProtoEnt; stdcall;
// procedure WSASetLastError(iError: Integer); stdcall;
// function WSAIsBlocking: BOOL; stdcall;
// function WSAUnhookBlockingHook: Integer; stdcall;
// function WSASetBlockingHook(lpBlockFunc: TFarProc): TFarProc; stdcall;
// function WSACancelBlockingCall: Integer; stdcall;
// function WSAAsyncGetServByName(HWindow: HWND; wMsg: u_int;  name, proto, buf: PChar; buflen: Integer): THandle; stdcall;
// function WSAAsyncGetServByPort( HWindow: HWND; wMsg, port: u_int; proto, buf: PChar; buflen: Integer): THandle; stdcall;
// function WSAAsyncGetProtoByName(HWindow: HWND; wMsg: u_int; name, buf: PChar; buflen: Integer): THandle; stdcall;
// function WSAAsyncGetProtoByNumber(HWindow: HWND; wMsg: u_int; number: Integer; buf: PChar; buflen: Integer): THandle; stdcall;
// function WSAAsyncGetHostByAddr(HWindow: HWND; wMsg: u_int; addr: PChar; len, Struct: Integer; buf: PChar; buflen: Integer): THandle; stdcall;
// function WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer; stdcall;
// function WSARecvEx(s: TSocket; var buf; len: Integer; var flags: Integer): Integer; stdcall;
// function __WSAFDIsSet(s: TSocket; var FDSet: TFDSet): Bool; stdcall;
// function TransmitFile(hSocket: TSocket; hFile: THandle; nNumberOfBytesToWrite: DWORD; nNumberOfBytesPerSend: DWORD; lpOverlapped: POverlapped; lpTransmitBuffers: PTransmitFileBuffers; dwReserved: DWORD): BOOL; stdcall;
// function AcceptEx(sListenSocket, sAcceptSocket: TSocket; lpOutputBuffer: Pointer; dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD; var lpdwBytesReceived: DWORD; lpOverlapped: POverlapped): BOOL; stdcall;
// procedure GetAcceptExSockaddrs(lpOutputBuffer: Pointer; dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD; var LocalSockaddr: TSockAddr; var LocalSockaddrLength: Integer; var RemoteSockaddr: TSockAddr; var RemoteSockaddrLength: Integer); stdcall;
// function WSAMakeSyncReply(Buflen, Error: Word): Longint;
// function WSAMakeSelectReply(Event, Error: Word): Longint;
// function WSAGetAsyncBuflen(Param: Longint): Word;
// function WSAGetAsyncError(Param: Longint): Word;
// function WSAGetSelectEvent(Param: Longint): Word;
// function WSAGetSelectError(Param: Longint): Word;
// procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
// function FD_ISSET(Socket: TSocket; var FDSet: TFDSet): Boolean;
// procedure FD_SET(Socket: TSocket; var FDSet: TFDSet); // renamed due to conflict with fd_set (above)
// procedure FD_ZERO(var FDSet: TFDSet);


type
  TWSAEvent = THandle;

Const
  SD_RECEIVE  = $00;
  SD_SEND     = $01;
  SD_BOTH     = $02;


  MAX_PROTOCOL_CHAIN = 7;
  BASE_PROTOCOL = 1;
  LAYERED_PROTOCOL = 0;
  WSAPROTOCOL_LEN = 255;

  WSA_FLAG_OVERLAPPED = $01;
  WSA_FLAG_MULTIPOINT_C_ROOT = $02;
  WSA_FLAG_MULTIPOINT_C_LEAF = $04;
  WSA_FLAG_MULTIPOINT_D_ROOT = $08;
  WSA_FLAG_MULTIPOINT_D_LEAF = $10;

  WSA_IO_PENDING = ERROR_IO_PENDING;

  FD_READ_BIT    =  0;
  FD_READ        =  (1 shl FD_READ_BIT);

  FD_WRITE_BIT   =  1;
  FD_WRITE       =  (1 shl  FD_WRITE_BIT);

  FD_OOB_BIT     =  2;
  FD_OOB         =  (1 shl  FD_OOB_BIT);

  FD_ACCEPT_BIT  =  3;
  FD_ACCEPT      =  (1 shl  FD_ACCEPT_BIT);

  FD_CONNECT_BIT =  4;
  FD_CONNECT     =  (1 shl  FD_CONNECT_BIT);

  FD_CLOSE_BIT   =  5;
  FD_CLOSE       =  (1 shl  FD_CLOSE_BIT);

  FD_QOS_BIT     =  6;
  FD_QOS         =  (1 shl  FD_QOS_BIT);

  FD_GROUP_QOS_BIT = 7;
  FD_GROUP_QOS     = (1 shl  FD_GROUP_QOS_BIT);

  FD_MAX_EVENTS  =  8;
  FD_ALL_EVENTS  =  ((1 shl  FD_MAX_EVENTS) - 1);

  CF_ACCEPT  = 0;
  CF_REJECT  = 1;
  CF_DEFER   = 2;

  WSA_INVALID_HANDLE      = ERROR_INVALID_HANDLE;
  WSA_INVALID_PARAMETER   = ERROR_INVALID_PARAMETER;
  WSA_NOT_ENOUGH_MEMORY   = ERROR_NOT_ENOUGH_MEMORY;
  WSA_OPERATION_ABORTED   = ERROR_OPERATION_ABORTED;

  WSA_INVALID_EVENT       = TWSAEVENT(0);
  WSA_MAXIMUM_WAIT_EVENTS = MAXIMUM_WAIT_OBJECTS;
  WSA_WAIT_FAILED         = DWORD(-1);
  WSA_WAIT_EVENT_0        = WAIT_OBJECT_0;
  WSA_WAIT_IO_COMPLETION  = WAIT_IO_COMPLETION;
  WSA_WAIT_TIMEOUT        = WAIT_TIMEOUT;
  WSA_INFINITE            = INFINITE;


type
 PWSABuf = ^TWSABuf;
 TWSABuf =
   record
    Len: DWORD;
    Buf: Pointer;
   end;

  TGUID = record
    Data1: DWORD;
    Data2: Word;
    Data3: Word;
    Data4: array[0..8-1] of Byte;
  end;


 TWSAProtocolChain =
   record
     ChainLen: Integer;
     ChainEntries: array[0..MAX_PROTOCOL_CHAIN-1] of DWORD;
   end;


  PWSAProtocolInfo = ^TWSAProtocolInfo;
  TWSAProtocolInfo = record
    dwServiceFlags1,
    dwServiceFlags2,
    dwServiceFlags3,
    dwServiceFlags4,
    dwProviderFlags: DWORD;
    ProviderId: TGUID;
    dwCatalogEntryId: DWORD;
    ProtocolChain: TWSAProtocolChain;
    iVersion: Integer;
    iAddressFamily: Integer;
    iMaxSockAddr: Integer;
    iMinSockAddr: Integer;
    iSocketType: Integer;
    iProtocol: Integer;
    iProtocolMaxOffset: Integer;
    iNetworkByteOrder: Integer;
    iSecurityScheme: Integer;
    dwMessageSize: DWORD;
    dwProviderReserved: DWORD;
    szProtocol: array[0..WSAPROTOCOL_LEN+1-1] of Char;
  end;


  PWSANetworkEvents = ^TWSANetworkEvents;
  TWSANetworkEvents = record
    lNetworkEvents: DWORD;
    iErrorCode: array[0..FD_MAX_EVENTS-1] of Integer;
  end;


{ Socket function prototypes }

function  accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket;
function  bind(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer;
function  closesocket(s: TSocket): Integer;
function  connect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer;
function  ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer;
function  htons(hostshort: u_short): u_short;
function  inet_addr(cp: PChar): u_long;
function  listen(s: TSocket; backlog: Integer): Integer;
function  recv(s: TSocket; var Buf; len, flags: Integer): Integer;
function  send(s: TSocket; var Buf; len, flags: Integer): Integer;
function  setsockopt(s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer;
function  shutdown(s: TSocket; how: Integer): Integer;
function  socket(af, Struct, protocol: Integer): TSocket;
function  WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer;
function  WSACleanup: Integer;
function  WSAGetLastError: Integer;
function  WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name, buf: PChar; buflen: Integer): THandle;
function  WSACancelAsyncRequest(hAsyncTaskHandle: THandle): Integer;
function  WSACreateEvent: TWSAEvent;
function  WSASocket(af: Integer; typ: Integer; protocol: Integer; lpProtocolInfo: PWSAProtocolInfo; g: DWORD; dwFlags: DWORD): TSocket;
function  WSAConnect(s: TSocket; const name: TSockAddr; namelen: Integer; lpCallerData: Pointer; lpCalleeData: Pointer; lpSQOS: Pointer; lpGQOS: Pointer): Integer;
function  WSAAccept(s: TSocket; var addr: TSockAddr; var addrlen: Integer; lpfnCondition: Pointer; CallbackData: DWORD): TSocket;
function  WSARecv(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD; var lpNumberOfBytesRecvd: DWORD; var Flags: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: FARPROC): Integer;
function  WSASend(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD; var lpNumberOfBytesSent: DWORD; Flags: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: FARPROC): Integer;
function  WSAGetOverlappedResult(s: TSocket; const lpOverlapped: TOverlapped; var lpcbTransfer: DWORD; bWait: BOOL; var lpdwFlags: DWORD): BOOL;
function  WSAEventSelect(s: TSocket; hEventObject: TWSAEvent; lNetworkEvents: Integer): Integer;
function  WSAEnumNetworkEvents(s: TSocket; hEventObject: TWSAEvent; lpNetworkEvents: PWSANetworkEvents): Integer;

var
  WinSock2: Boolean;
  WinSockVersion: Integer;

implementation uses SysUtils;

var
  ModuleHandle: Integer;
  ModuleLoaded: Boolean;

procedure DoLoadLibrary;
const
  ModuleName: array[Boolean] of string = ('wsock32.dll', 'ws2_32.dll');
var
  v2: Boolean;
begin
  case WinSockVersion of
    1: v2 := False;
    2: v2 := True
    else
      v2 := Win32Platform = VER_PLATFORM_WIN32_NT;
  end;
  ModuleHandle := LoadLibrary(PChar(ModuleName[v2]));
  if ModuleHandle <> 0 then WinSock2 := v2;
end;


function __Load(A: PChar): Pointer;
begin
  Result := nil;
  if not ModuleLoaded then
  begin
    ModuleLoaded := True;
    DoLoadLibrary;
  end;
  if ModuleHandle <> 0 then Result := GetProcAddress(ModuleHandle, A);
end;


type
  T_accept                    = function(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket; stdcall;
  T_bind                      = function(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer; stdcall;
  T_closesocket               = function(s: TSocket): Integer; stdcall;
  T_connect                   = function(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;
  T_ioctlsocket               = function(s: TSocket; cmd: DWORD; var arg: u_long): Integer; stdcall;
  T_htons                     = function(hostshort: u_short): u_short; stdcall;
  T_inet_addr                 = function(cp: PChar): u_long; stdcall;
  T_listen                    = function(s: TSocket; backlog: Integer): Integer; stdcall;
  T_recv                      = function(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
  T_send                      = function(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
  T_setsockopt                = function(s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer; stdcall;
  T_shutdown                  = function(s: TSocket; how: Integer): Integer; stdcall;
  T_socket                    = function(af, Struct, protocol: Integer): TSocket; stdcall;
  T_WSAStartup                = function(wVersionRequired: word; var WSData: TWSAData): Integer; stdcall;
  T_WSACleanup                = function: Integer; stdcall;
  T_WSAGetLastError           = function: Integer; stdcall;
  T_WSAAsyncGetHostByName     = function(HWindow: HWND; wMsg: u_int; name, buf: PChar; buflen: Integer): THandle; stdcall;
  T_WSACancelAsyncRequest     = function(hAsyncTaskHandle: THandle): Integer; stdcall;
  T_WSACreateEvent            = function: TWSAEvent; stdcall;
  T_WSASocket                 = function(af: Integer; typ: Integer; protocol: Integer; lpProtocolInfo: PWSAProtocolInfo; g: DWORD; dwFlags: DWORD): TSocket; stdcall;
  T_WSAConnect                = function(s: TSocket; const name: TSockAddr; namelen: Integer; lpCallerData: Pointer; lpCalleeData: Pointer; lpSQOS: Pointer; lpGQOS: Pointer): Integer; stdcall;
  T_WSAAccept                 = function(s: TSocket; var addr: TSockAddr; var addrlen: Integer; lpfnCondition: Pointer; CallbackData: DWORD): TSocket; stdcall;
  T_WSARecv                   = function(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD; var lpNumberOfBytesRecvd: DWORD; var Flags: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: FARPROC): Integer; stdcall;
  T_WSASend                   = function(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD; var lpNumberOfBytesSent: DWORD; Flags: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: FARPROC): Integer; stdcall;
  T_WSAGetOverlappedResult    = function(s: TSocket; const lpOverlapped: TOverlapped; var lpcbTransfer: DWORD; bWait: BOOL; var lpdwFlags: DWORD): BOOL; stdcall;
  T_WSAEventSelect            = function(s: TSocket; hEventObject: TWSAEvent; lNetworkEvents: Integer): Integer; stdcall;
  T_WSAEnumNetworkEvents      = function(s: TSocket; hEventObject: TWSAEvent; lpNetworkEvents: PWSANetworkEvents): Integer; stdcall;

var
  F_accept                    : T_accept;
  F_bind                      : T_bind;
  F_closesocket               : T_closesocket;
  F_connect                   : T_connect;
  F_ioctlsocket               : T_ioctlsocket;
  F_htons                     : T_htons;
  F_inet_addr                 : T_inet_addr;
  F_listen                    : T_listen;
  F_recv                      : T_recv;
  F_send                      : T_send;
  F_setsockopt                : T_setsockopt;
  F_shutdown                  : T_shutdown;
  F_socket                    : T_socket;
  F_WSAStartup                : T_WSAStartup;
  F_WSACleanup                : T_WSACleanup;
  F_WSAGetLastError           : T_WSAGetLastError;
  F_WSAAsyncGetHostByName     : T_WSAAsyncGetHostByName;
  F_WSACancelAsyncRequest     : T_WSACancelAsyncRequest;
  F_WSACreateEvent            : T_WSACreateEvent;
  F_WSASocket                 : T_WSASocket;
  F_WSAConnect                : T_WSAConnect;
  F_WSAAccept                 : T_WSAAccept;
  F_WSARecv                   : T_WSARecv;
  F_WSASend                   : T_WSASend;
  F_WSAGetOverlappedResult    : T_WSAGetOverlappedResult;
  F_WSAEventSelect            : T_WSAEventSelect;
  F_WSAEnumNetworkEvents      : T_WSAEnumNetworkEvents;

function accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket;
begin
  if not Assigned(F_accept) then F_accept := __Load('accept');
// If no error occurs, accept returns a value of type SOCKET which is a descriptor for the accepted socket.
// Otherwise, a value of INVALID_SOCKET is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_accept) then Result := F_accept(s, addr, addrlen) else Result := INVALID_SOCKET;
end;

function bind(s: TSocket; var addr: TSockAddr; namelen: Integer): Integer;
begin
  if not Assigned(F_bind) then F_bind := __Load('bind');
// If no error occurs, bind returns zero.
// Otherwise, it returns SOCKET_ERROR, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_bind) then Result := F_bind(s, addr, namelen) else Result := SOCKET_ERROR;
end;

function closesocket(s: TSocket): Integer;
begin
  if not Assigned(F_closesocket) then F_closesocket := __Load('closesocket');
// If no error occurs, closesocket returns zero.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_closesocket) then Result := F_closesocket(s) else Result := SOCKET_ERROR;
end;

function connect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer;
begin
  if not Assigned(F_connect) then F_connect := __Load('connect');
// If no error occurs, connect returns zero.
// Otherwise, it returns SOCKET_ERROR, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_connect) then Result := F_connect(s, name, namelen) else Result := SOCKET_ERROR;
end;

function ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer;
begin
  if not Assigned(F_ioctlsocket) then F_ioctlsocket := __Load('ioctlsocket');
// Upon successful completion, the ioctlsocket returns zero.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_ioctlsocket) then Result := F_ioctlsocket(s, cmd, arg) else Result := SOCKET_ERROR;
end;

function htons(hostshort: u_short): u_short;
begin
  if not Assigned(F_htons) then F_htons := __Load('htons');
  if Assigned(F_htons) then Result := F_htons(hostshort) else Result := 0;
end;

function inet_addr(cp: PChar): u_long;
begin
  if not Assigned(F_inet_addr) then F_inet_addr := __Load('inet_addr');
// If no error occurs, inet_addr returns an unsigned long containing a suitable binary representation of the Internet address given.
// If the passed-in string does not contain a legitimate Internet address, for example if a portion of an "a.b.c.d" address exceeds 255, inet_addr returns the value INADDR_NONE.
  if Assigned(F_inet_addr) then Result := F_inet_addr(cp) else Result := u_long(INADDR_NONE);
end;

function listen(s: TSocket; backlog: Integer): Integer;
begin
  if not Assigned(F_listen) then F_listen := __Load('listen');
// If no error occurs, listen returns zero.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_listen) then Result := F_listen(s, backlog) else Result := SOCKET_ERROR;
end;

function recv(s: TSocket; var Buf; len, flags: Integer): Integer;
begin
  if not Assigned(F_recv) then F_recv := __Load('recv');
// If no error occurs, recv returns the number of bytes received.
// If the connection has been gracefully closed, the return value is zero.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_recv) then Result := F_recv(s, Buf, len, flags) else Result := SOCKET_ERROR;
end;

function send(s: TSocket; var Buf; len, flags: Integer): Integer;
begin
  if not Assigned(F_send) then F_send := __Load('send');
// If no error occurs, send returns the total number of bytes sent.
// (Note that this can be less than the number indicated by len.)
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_send) then Result := F_send(s, Buf, len, flags) else Result := SOCKET_ERROR;
end;

function setsockopt(s: TSocket; level, optname: Integer; optval: PChar; optlen: Integer): Integer;
begin
  if not Assigned(F_setsockopt) then F_setsockopt := __Load('setsockopt');
// If no error occurs, setsockopt returns zero.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_setsockopt) then Result := F_setsockopt(s, level, optname, optval, optlen) else Result := SOCKET_ERROR;
end;

function shutdown(s: TSocket; how: Integer): Integer;
begin
  if not Assigned(F_shutdown) then F_shutdown := __Load('shutdown');
// If no error occurs, shutdown returns zero.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_shutdown) then Result := F_shutdown(s, how) else Result := SOCKET_ERROR;
end;

function socket(af, Struct, protocol: Integer): TSocket;
begin
  if not Assigned(F_socket) then F_socket := __Load('socket');
// If no error occurs, socket returns a descriptor referencing the new socket.
// Otherwise, a value of INVALID_SOCKET is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_socket) then Result := F_socket(af, Struct, protocol) else Result := INVALID_SOCKET;
end;

function WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer;
begin
  if not Assigned(F_WSAStartup) then F_WSAStartup := __Load('WSAStartup');
  if Assigned(F_WSAStartup) then Result := F_WSAStartup(wVersionRequired, WSData) else Result := -1;
end;

function WSACleanup: Integer;
begin
  if not Assigned(F_WSACleanup) then F_WSACleanup := __Load('WSACleanup');
  if Assigned(F_WSACleanup) then Result := F_WSACleanup else Result := -1;
end;

function WSAGetLastError: Integer;
begin
  if not Assigned(F_WSAGetLastError) then F_WSAGetLastError := __Load('WSAGetLastError');
// WSAStartup returns zero if successful.
// Otherwise, it returns one of the error codes listed below.
// Note that the normal mechanism whereby the application calls WSAGetLastError to determine the error code cannot be used, since the Windows Sockets DLL may not have established the client data area where the "last error" information is stored.
  if Assigned(F_WSAGetLastError) then Result := F_WSAGetLastError else Result := WSASYSNOTREADY;
end;

function WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int; name, buf: PChar; buflen: Integer): THandle;
begin
  if not Assigned(F_WSAAsyncGetHostByName) then F_WSAAsyncGetHostByName := __Load('WSAAsyncGetHostByName');
// If the asynchronous operation could not be initiated, WSAAsyncGetHostByName returns a zero value, and a specific error number can be retrieved by calling WSAGetLastError.
  if Assigned(F_WSAAsyncGetHostByName) then Result := F_WSAAsyncGetHostByName(HWindow, wMsg, name, buf, buflen) else Result := 0;
end;

function WSACancelAsyncRequest(hAsyncTaskHandle: THandle): Integer;
begin
  if not Assigned(F_WSACancelAsyncRequest) then F_WSACancelAsyncRequest := __Load('WSACancelAsyncRequest');
// The value returned by WSACancelAsyncRequest is zero if the operation was successfully canceled. Otherwise, the value SOCKET_ERROR is returned, and a specific error number may be retrieved by calling WSAGetLastError.
  if Assigned(F_WSACancelAsyncRequest) then Result := F_WSACancelAsyncRequest(hAsyncTaskHandle) else Result := SOCKET_ERROR;
end;

function WSACreateEvent: TWSAEvent;
begin
  if not Assigned(F_WSACreateEvent) then F_WSACreateEvent := __Load('WSACreateEvent');
// If the function succeeds, the return value is the handle of the event object.
// If the function fails, the return value is WSA_INVALID_EVENT.
// To get extended error information, call WSAGetLastError.
  if Assigned(F_WSACreateEvent) then Result := F_WSACreateEvent else Result := WSA_INVALID_EVENT;
end;

function WSASocket(af: Integer; typ: Integer; protocol: Integer; lpProtocolInfo: PWSAProtocolInfo; g: DWORD; dwFlags: DWORD): TSocket;
begin
  if not Assigned(F_WSASocket) then F_WSASocket := __Load('WSASocketA');
// If no error occurs, WSASocket returns a descriptor referencing the new socket.
// Otherwise, a value of INVALID_SOCKET is returned, and a specific error code may be retrieved by calling WSAGetLastError.
  if Assigned(F_WSASocket) then Result := F_WSASocket(af, typ, protocol, lpProtocolInfo, g, dwFlags) else Result := INVALID_SOCKET;
end;

function WSAConnect(s: TSocket; const name: TSockAddr; namelen: Integer; lpCallerData: Pointer; lpCalleeData: Pointer; lpSQOS: Pointer; lpGQOS: Pointer): Integer;
begin
  if not Assigned(F_WSAConnect) then F_WSAConnect := __Load('WSAConnect');
// If no error occurs, WSAConnect returns zero.
// Otherwise, it returns SOCKET_ERROR, and a specific error code may be retrieved by calling WSAGetLastError.
  if Assigned(F_WSAConnect) then Result := F_WSAConnect(s, name, namelen, lpCallerData, lpCalleeData, lpSQOS, lpGQOS) else Result := SOCKET_ERROR;
end;

function WSAAccept(s: TSocket; var addr: TSockAddr; var addrlen: Integer; lpfnCondition: Pointer; CallbackData: DWORD): TSocket;
begin
  if not Assigned(F_WSAAccept) then F_WSAAccept := __Load('WSAAccept');
// If no error occurs, WSAAccept returns a value of type SOCKET which is a descriptor for the accepted socket.
// Otherwise, a value of INVALID_SOCKET is returned, and a specific error code can be retrieved by calling WSAGetLastError.
  if Assigned(F_WSAAccept) then Result := F_WSAAccept(s, addr, addrlen, lpfnCondition, CallbackData) else Result := INVALID_SOCKET;
end;

function WSARecv(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD; var lpNumberOfBytesRecvd: DWORD; var Flags: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: FARPROC): Integer;
begin
  if not Assigned(F_WSARecv) then F_WSARecv := __Load('WSARecv');
// If no error occurs and the receive operation has completed immediately, WSARecv returns zero.
// Note that in this case, the completion routine will have already been scheduled, and to be called once the calling thread is in the alertable state.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code may be retrieved by calling WSAGetLastError.
  if Assigned(F_WSARecv) then Result := F_WSARecv(s, lpBuffers, dwBufferCount, lpNumberOfBytesRecvd, Flags, lpOverlapped, lpCompletionRoutine) else Result := SOCKET_ERROR;
end;

function WSASend(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD; var lpNumberOfBytesSent: DWORD; Flags: DWORD; lpOverlapped: POverlapped; lpCompletionRoutine: FARPROC): Integer;
begin
  if not Assigned(F_WSASend) then F_WSASend := __Load('WSASend');
// If no error occurs and the send operation has completed immediately, WSASend returns zero.
// Note that in this case, the completion routine will have already been scheduled, and to be called once the calling thread is in the alertable state.
// Otherwise, a value of SOCKET_ERROR is returned, and a specific error code may be retrieved by calling WSAGetLastError.
  if Assigned(F_WSASend) then Result := F_WSASend(s, lpBuffers, dwBufferCount, lpNumberOfBytesSent, Flags, lpOverlapped, lpCompletionRoutine) else Result := SOCKET_ERROR;
end;

function WSAGetOverlappedResult(s: TSocket; const lpOverlapped: TOverlapped; var lpcbTransfer: DWORD; bWait: BOOL; var lpdwFlags: DWORD): BOOL;
begin
  if not Assigned(F_WSAGetOverlappedResult) then F_WSAGetOverlappedResult := __Load('WSAGetOverlappedResult');
// If WSAGetOverlappedResult succeeds, the return value is TRUE.
// This means that the overlapped operation has completed successfully and that the value pointed to by lpcbTransfer has been updated.
// If WSAGetOverlappedResult returns FALSE, this means that either the overlapped operation has not completed or the overlapped operation completed but with errors, or that completion status could not be determined due to errors in one or more parameters to WSAGetOverlappedResult.
  if Assigned(F_WSAGetOverlappedResult) then Result := F_WSAGetOverlappedResult(s, lpOverlapped, lpcbTransfer, bWait, lpdwFlags) else Result := FALSE;
end;

function WSAEventSelect(s: TSocket; hEventObject: TWSAEvent; lNetworkEvents: Integer): Integer;
begin
  if not Assigned(F_WSAEventSelect) then F_WSAEventSelect := __Load('WSAEventSelect');
// The return value is zero if the application's specification of the network events and the associated event object was successful.
// Otherwise, the value SOCKET_ERROR is returned, and a specific error number may be retrieved by calling WSAGetLastError.
  if Assigned(F_WSAEventSelect) then Result := F_WSAEventSelect(s, hEventObject, lNetworkEvents) else Result := SOCKET_ERROR;
end;

function WSAEnumNetworkEvents(s: TSocket; hEventObject: TWSAEvent; lpNetworkEvents: PWSANetworkEvents): Integer;
begin
  if not Assigned(F_WSAEnumNetworkEvents) then F_WSAEnumNetworkEvents := __Load('WSAEnumNetworkEvents');
// The return value is zero if the operation was successful.
// Otherwise, the value SOCKET_ERROR is returned, and a specific error number may be retrieved by calling WSAGetLastError.
  if Assigned(F_WSAEnumNetworkEvents) then Result := F_WSAEnumNetworkEvents(s, hEventObject, lpNetworkEvents) else Result := SOCKET_ERROR;
end;


(*

function WSAMakeSyncReply;
begin
  WSAMakeSyncReply:= MakeLong(Buflen, Error);
end;

function WSAMakeSelectReply;
begin
  WSAMakeSelectReply:= MakeLong(Event, Error);
end;

function WSAGetAsyncBuflen;
begin
  WSAGetAsyncBuflen:= LOWORD(Param);
end;

function WSAGetAsyncError;
begin
  WSAGetAsyncError:= HIWORD(Param);
end;

function WSAGetSelectEvent;
begin
  WSAGetSelectEvent:= LOWORD(Param);
end;

function WSAGetSelectError;
begin
  WSAGetSelectError:= HIWORD(Param);
end;

procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
var
  I: Integer;
begin
  I := 0;
  while I < FDSet.fd_count do
  begin
    if FDSet.fd_array[I] = Socket then
    begin
      while I < FDSet.fd_count - 1 do
      begin
        FDSet.fd_array[I] := FDSet.fd_array[I + 1];
        Inc(I);
      end;
      Dec(FDSet.fd_count);
      Break;
    end;
    Inc(I);
  end;
end;

function FD_ISSET(Socket: TSocket; var FDSet: TFDSet): Boolean;
begin
  Result := __WSAFDIsSet(Socket, FDSet);
end;

procedure FD_SET(Socket: TSocket; var FDSet: TFDSet);
begin
  if FDSet.fd_count < FD_SETSIZE then
  begin
    FDSet.fd_array[FDSet.fd_count] := Socket;
    Inc(FDSet.fd_count);
  end;
end;

procedure FD_ZERO(var FDSet: TFDSet);
begin
  FDSet.fd_count := 0;
end;
*)

end.
