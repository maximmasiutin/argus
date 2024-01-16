unit MlrThr;

{$I DEFINE.INC}

interface

uses
  Windows, xBase, xFido, xMisc, Outbound,
  Recs, xDES, mClasses, Messages, RegExp

  {$IFDEF WS}
  ,xIP
  {$ENDIF}

  ;

const
  cFaxInBufSize = $1000;

  MaxProcesses = 32;
  BBSAllowed = True;
  FAXAllowed = True;

  ecOurOptions   = [{ecNRQ,} ecARC, ecXMA, ecHFR {,ecFNC}];
  ecOurProtocols = [ecHYD, ecDZA, ecZAP, ecZMO {, ecYMO}];

  EMSI_CR_d   =  1;   {$IFDEF WS} EMSI_CR_i   =  10; {$ENDIF}
  EMSI_S3_d   =  5;   {$IFDEF WS} EMSI_S3_i   =  20; {$ENDIF}
  EMSI_Bl_d   = 20;   {$IFDEF WS} EMSI_Bl_i   =  60; {$ENDIF}
  EMSI_Tm_d   = 60;   {$IFDEF WS} EMSI_Tm_i   = 300; {$ENDIF}

{$IFNDEF WS}
  toEMSI_CR      = EMSI_CR_d;
  toEMSI_S3      = EMSI_S3_d;
  toEMSI_Block   = EMSI_Bl_d;
  toEMSI_Timeout = EMSI_Tm_d;
{$ENDIF}

  MaxLogStrings = 200;
{$IFDEF WS}
  PollOwnerDaemon  = Pointer($FFFFFFFC);
  PanelOwnerDaemon = Pointer($FFFFFFFD);
{$ENDIF}
  PollOwnerExtApp  = Pointer($FFFFFFFE);
  PanelOwnerPolls  = Pointer($FFFFFFFF);

  PanelOwnerOutMgr = Pointer($FFFFFFFB);


type
  TLogContainer = class
    Strings: TStringColl;
    FMsg: Integer;
    FHandle: DWORD;
    FName: string;
    FTag: TLogTag;
    CS: TRTLCriticalSection;
    constructor Create;
    destructor Destroy; override;
    function FormatSelf(const S: string): string;
    procedure Log(S: string);
    procedure LogSelf(const S: string);
  end;


  TPollColl = class(TColl)
    Log: TLogContainer;
    Options: TPollOptionsData;
    constructor Create;
    destructor Destroy; override;
  end;

  TStringHolder = class
    S: string;
  end;


  TFidoPoll = class;

  {$IFDEF WS}
  TNewIpLineData = class
    Poll: TFidoPoll;
    IpPort: DWORD;
    Prot: TProtCore;
  end;
  {$ENDIF}

  TFaxMode = (fmdNone, fmdFAX);

  TMailerState = (
     msNone,

     __FirstExtApp,
     msExtApp_0,
     msExtApp_1,
     msExtApp_2,
     msExtAppWait,
     msExtAppWaitOK,
     __LastExtApp,

     __FirstCN,
     msCN_ConnectStringTmr,
     msCN_ConnectStringDCD,
     msCN_ConnectString,
     msCN_ConnectString_A,
     msCN_GetSpeed,
     msCN_HandshakeDelay,
     msCN_HandshakeOK,
     msCN_HandshakeStart,
     msCN_ConnectDCD,
     msCN_ConnectDCD_A,
     msCN_ConnectDCD_w,
     __LastCN,

     __FirstMisc,
     msCheckOut,
     msError,
     msModemStatx,
     msInit,
     msDone,
     msStart,
     msInitOK,
     msInitOK_,
     msInitFreeCP,
     msStillHigh,
     msInitModem_I,
     msInitModem,
     msInitModemA,
     msHangup,
     msRingAfterIdle,
     msGotNextRing,
     msStartWaitNextRing,
     msWaitNextRing,
     msRingTimerExpired,
     msStartIdle,
     msIdle,
     msIdleA,
     msIdleA_Expired,
     msModemCmdIdle,
     msStartAnswer,
     msAnswerFailed,
     msAnswering,
     msCarrierLost,
     msHandshakeTimeout,
     msStartDial,
     msStartExtPoll,
     msStartDialPhone,
     msStartDialOK,
     msStartDialFailed,
     msTryOpenSer,
     msTryOpenSerW,
     msTryOpenSerAgain,
     msDialling,
     msRinging,
     msDialTimeout,
     msCancel,
     ms_NoValidAddr,
     ms_WrongOutDial,
     msSE_Busy,
     msSE_NoConnect,
     msSE_SessionAborted,
     msSE_OK,
     msSE_OKa,
     msSE_OKb,
     msSE_OKc,
     __LastMisc,

     __FirstHSh,
     msHSh_s1,  // Calling system

     msHSh_Login_1,
     msHSh_Login_2,
     msHSh_Login_2_matched,
     msHSh_Login_3,
     msHSh_Login_4,

     msHSh_s1c,
     msHSh_s1t,
     msHSh_swz,
     msHSh_sw,
     msHSh_s3,
     msHSh_s3c,
     msHSh_sES,
     msHSh_sES2,
     msHSh_sYh,

     msHSh_r1,  // Answering system
     msHSh_r2z,
     msHSh_r2,
     msHSh_TCP,
     __LastHSh,

     __FirstEMSI,
       // EMSI receive data
     msEMSI_h2,
     msEMSI_h3,
     msEMSI_h4z,
     msEMSI_h4,
     msEMSI_h5,
     msEMSI_parsed,
     msEMSI_h5_0,
     msEMSI_h5a,
     msEMSI_h5b,
     msEMSI_h5calc,
     msEMSI_c1z,
     msEMSI_c1,  // EMSI send data
     msEMSI_c2,
     msEMSI_c2a,
     msEMSI_c3,
     msEMSI_c4req,
     msEMSI_c4nak,
     msEMSI_c4_,
     msEMSI_c4,
     msEMSI_c5,
     msEMSI_FailPkt,
     msEMSI_Timeout,
     msEMSI_FailTries,
     msEMSI_PswVio,
     msEMSI_DCD,
     __LastEMSI,

     __FirstWZ,
     msStartBinkP,
     msStartWZ,
     msStartFTS1,
     msStartYooHoo,
     msSendYooHoo,
     msWaitYooHooAck,
     msWaitYooHooEnq,
     msInitYooHoo,
     msParseYooHoo,
     msWaitYooHooPkt,
     msFinishWZ,
     msOneWayStartTxBatch1,
     msOneWayTxBatch1,
     msOneWayStartRxBatch2,
     msOneWayRxBatch2,
     msOneWayStartTxBatch3,
     msOneWayTxBatch3,
     msBiDirStartBatch1,
     msBiDirBatch1,
     msBiDirStartBatch2,
     msBiDirBatch2,
     msWZOK,
     __LastWZ,
     __FirstFax,
     msFaxBegin,
     msFaxStartRece,
     msFaxTimeout,
     msFaxRecePage_,
     msFaxRecePage,
     msFaxError,
     msFaxDCD,
     msFaxHangup,
     msFaxOK,
     msFaxWaitCN_,
     msFaxWaitCN,
     msFaxGood,
     msFaxReadG3,
     msFaxEndPage,
     msFaxWaitFet_,
     msFaxWaitFet,
     msFaxPageGood,
     msFaxEnd,
     __LastFax
  );



  TAbstractEventProcessor = class
    UpdateTick: DWORD;
    EvtIds: PIntArray;
    EvtCnt: Integer;
    procedure Refill; virtual; abstract;
    procedure RefillEx(AEvtCnt: Integer; AEvtIds: Pointer);
    function  BoolValueD(ATyp: Integer; ADefault: Boolean): Boolean;
    function  FindAtom(ATyp: Integer): Pointer;
    function  GetAtomListEx(ATyp: Integer; Single: Boolean): Pointer;
    function  GetAtomList(ATyp: Integer): Pointer;
    function  DwordValueD(ATyp: Integer; ADefault: DWORD): DWORD;
//    function  PtrValueD(ATyp: Integer; P: Pointer): Pointer;
    function  StrValue(ATyp: Integer): string;
    function  StrValueD(ATyp: Integer; const ADefault: string): string;
    function  VoidFound(ATyp: Integer): Boolean;
//    function GridValue(ATyp: Integer): TColl;
    procedure FreeIds;
    destructor Destroy; override;
  end;

  TMailerThreadEventProcessor = class(TAbstractEventProcessor)
    LineId: Integer;
    procedure Refill; override;
  end;

{$IFDEF WS}
  TDaemonEventProcessor = class(TAbstractEventProcessor)
    CS: TRTLCriticalSection;
    constructor Create;
    destructor Destroy; override;
    procedure Refill; override;
  end;
{$ENDIF}

  TMailerThread = class;
  TCronThread = class;

  TAbstractLogger = class
    function  ChkErrMsg: Boolean;
    function  GetProcessColl: Pointer; virtual; abstract;
    procedure LeaveProcesses;
    procedure Log(CurTag: TLogTag; const CurStr: string); virtual; abstract;
    procedure LogFmt(CurTag: TLogTag; const FmtStr: string; const Args: array of const);
    procedure LogTermination(PI: TProcessInformation; PostProcess: Boolean; const ProcessName: string);
    procedure TestRunningProcesses;
  end;

  TMailerThreadLogger = class(TAbstractLogger)
    MailerThread: TMailerThread;
    procedure Log(CurTag: TLogTag; const CurStr: string); override;
    function GetProcessColl: Pointer; override;
  end;

  TCronThreadLogger = class(TAbstractLogger)
    procedure Log(CurTag: TLogTag; const CurStr: string); override;
    function GetProcessColl: Pointer; override;
  end;

  {$IFDEF WS}
  TDaemonThreadLogger = class(TAbstractLogger)
    LogCS: TRTLCriticalSection;
    procedure Log(CurTag: TLogTag; const CurStr: string); override;
    function GetProcessColl: Pointer; override;
    constructor Create;
    destructor Destroy; override;
  end;
  {$ENDIF}

  TMlrEvt = class
    procedure Execute(T: TMailerThread); virtual; abstract;
  end;

  TMlrEvtNop = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtSkip = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtRefuse = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtAnswer = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtClearTmrPublic = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtIncTmrPublic = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtOperatorTerminate = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtFlagTerminate = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtShutdownTerminate = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtPollsRecalc = class(TMlrEvt)
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtChStatus = class(TMlrEvt)
    FStatus: TMailerState;
    constructor Create(AStatus: TMailerState);
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtEnterMdmCmds = class(TMlrEvt)
    FWndHandle: DWORD;
    constructor Create(AWndHandle: DWORD);
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtSendMdmCmd = class(TMlrEvt)
    FString: string;
    constructor Create(const AString: string);
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtLogAndExtApp = class(TMlrEvt)
    FExtApp: string;
    FLogStr: string;
    constructor Create(const AExtApp, ALogStr: string);
    procedure Execute(T: TMailerThread); override;
  end;

  TMlrEvtLogAndCancel = class(TMlrEvt)
    FLogStr: string;
    constructor Create(const ALogStr: string);
    procedure Execute(T: TMailerThread); override;
  end;


  TPollDone = (pdnUnknown, pdnShutDown, pdnOK, pdnDeleted, pdnDeleteAll, pdnAttachLost, pdnNodeDestroyed);
  TPollType = (ptpUnknown, ptpOutb, ptpCron, ptpManual);

  TFidoPoll = class
    FileSendDelayed: Boolean;
    Birth: DWORD;
    DataIdx: DWORD;
    Done: TPollDone;
    LastTry: EventTimer;
    Node: TAdvNode;
    Owner: TMailerThread;
    Revalidate: Boolean;
    TryBusy,
    TryNoConnect,
    TrySessionAborted: DWORD;
    Typ: TPollType;
    constructor Create;
    destructor Destroy; override;
    function  DialupFlags: string;
    function  DialupPhone: string;
    function  IPAddr: string;
    function  IPFlags: string;
    function  _Flags(Coll: TColl): string;
    function  Flags(Dialup: Boolean): string;
    procedure Release;
    procedure Reset;
    procedure IncNoConnectTries;
    procedure IncBusyTries(const AReason: string);
    procedure IncAbortedTries;
    function ExtSleepMSecs: DWORD;
    function ExtTimeoutExitCode: DWORD;
    function STryBusy: string;
    function STryFail: string;
    function STryNoC: string;
    function CountersExceeded: Boolean;
  end;

  TPollPtr = class
    Poll: TFidoPoll;
    Idx: DWORD;
  end;

  TDisplayStringData = record
    ConnectString,
    ProtName,
    StatusParam,
    rmtAddressList,
    rmtFlags,
    rmtLocation,
    rmtPhone,
    rmtSoft,
    rmtStationName,
    rmtSysOpName: string;
  end;

  TDisplayData = record
    Initialised,
    CanAnswer,
    ExtApp,
    NoCP,
    SkipIs: Boolean;
    CPOutUsed,
    ProtTotalErrors,
    rmtForUs,
    StatusMsg,
    rxBytes,
    txBytes,
    txTot: DWORD;
    TmrPublic: EventTimer;
  end;


  TRemoteMailerFlag = (
    rmfNoFileDelay,
    {rmfForceZRQInit,}
    rmfHFR, // Argus HFR-flavour is supported
    rmfNRQ, // No file requests accepted by this system (EMSI compatibility code)
    rmfPUA, // Pickup mail for all presented addresses (EMSI link code)
    rmfPUP, // Pickup mail for primary address only (EMSI link code)
    rmfNPU, // No mail pickup desired (EMSI link code)
    rmfHAT, // Hold ALL traffic (EMSI link code)
    rmfHXT, // Hold compressed mail traffic (EMSI link code)
    rmfHRQ  // Hold file requests, not processed at this time (EMSI link code)
    );
  TRemoteMailerFlags = set of TRemoteMailerFlag;


  // A T.30 DIS frame, as sent by the remote fax machine

    TFaxT30Params = record

       vr,  // VR = Vertical Res :
            //     0 Normal, 98 lpi
            //     1 Fine, 196 lpi

       br,  // BR = Bit Rate :    br * 2400BPS

       wd,  // Page Width :
            //     0 1728 pixels in 215 mm
            //     1 2048 pixels in 255 mm
            //     2 2432 pixels in 303 mm

       ln,  // Page Length :
            //     0 A4, 297 mm
            //     1 B4, 364 mm
            //     2 unlimited

       df,  // Data compression format :
            //     0 1-D modified Huffman
            //     1 2-D modified ReAd
            //     2 2-D unompressed mode (?)

       ec,  // Error Correction :
            //     0 disable ECM
            //     1 enable ECM 64 bytes/frame
            //     2 enable CM 256B/frame

       bf,  // Binary File Transfer
            //     0 disable BFT
            //     1 enable BFT

       st   // Scan Time (ms) :
            //     VR   Normal  Fine
            //     0    0       0 ms
            //     1    5       5
            //     2    10      5
            //     3    10      10
            //     4    20      10
            //     5    20      20
            //     6    40      20
            //     7    40      40

          : DWORD;
  end;

  TFaxmodem = class
    Pages: TColl;
    PageTime, PageNo: DWORD;
    RemoteIdReported: Boolean;
    FirstByteGot: Boolean;
    InBuf: array[0..cFaxInBufSize-1] of Byte;
    InBufPos: DWORD;
    WasDLE: Boolean;
    FStream: TxMemoryStream;
    FName,
    RemoteId       // +FCSI remote id
       : string;
    Hangup    ,   // +FHNG code
    PostPageResp, // +FPTS code
    PostPageMsg,  // +FET code
    pts_lc, pts_blc, pts_cblc
       : DWORD;
    ReadyT30,
    class20,
    fco,
    fcon,         // if +FCON  seen
    connect,      // if CONNECT msg seen
    ok,           // if OK seen
    error         // if ERROR or NO CARRIER seen
       : Boolean;

          // Session params; parsed from +FDCS

    T30: TFaxT30Params;
    destructor Destroy; override;
  end;

  TYooHooPacketData = packed record
    signal: Word;                     (* always 'o'     (0x6f)                   *)
    hello_version: Word;              (* currently 1    (0x01)                   *)
    product: Word;                    (* product code                            *)
    product_maj: Word;                (* major revision of the product           *)
    product_min: Word;                (* minor revision of the product           *)
    my_name: Array[1..60] of Char;    (* Other end's name                        *)
    sysop: Array[1..20] of Char;      (* sysop's name                            *)
    my_zone: Word;                    (* 0== not supported                       *)
    my_net: Word;                     (* out primary net number                  *)
    my_node: Word;                    (* our primary node number                 *)
    my_point: Word;                   (* 0== not supported                       *)
    my_password: Array[1..8] of Char; (* This is not necessarily null-terminated *)
    reserved2: Array[1..8] of Char;   (* reserved by Opus                        *)
    capabilities: Word;               (* see below                               *)
    reserved3: Array[1..12] of Char;  (* for non-Opus systems with "approval"    *)
                                      (*          total size 128 bytes           *)
  end;

  TYooHooPacket = class
    d, outd: TYooHooPacketData;
  end;

  TReStreamScanner = class
    Pos: Integer;
    RE: TPCRE;
    constructor Create(const APattern: string);
    procedure Matched; virtual; abstract;
    function Scan(const s: string): Boolean;
    procedure DecPos(i: Integer);
    destructor Destroy; override;
  end;

  TResponseFormatHolder = class(TReStreamScanner)
    FFormat: string;
    FLogger: TAbstractLogger;
    constructor Create(const APattern, AFormat: string; ALogger: TAbstractLogger);
    procedure Matched; override;
  end;

  TReWdResetHolder = class(TReStreamScanner)
    FMailer: TMailerThread;
    constructor Create(const APattern: string; AMailer: TMailerThread);
    procedure Matched; override;
  end;

  TReWdExtAppHolder = class(TReStreamScanner)
    FMailer: TMailerThread;
    FExtApp: string;
    constructor Create(const APattern, AExtApp: string; AMailer: TMailerThread);
    procedure Matched; override;
  end;

  TReLoginHolder = class(TReStreamScanner)
    FMailer: TMailerThread;
    constructor Create(const APattern: string; AMailer: TMailerThread);
    procedure Matched; override;
  end;


  TRemoteListedFlag = (rmtUnknown, rmtListed, rmtUnlisted);

  TMailerThreadInitData = class
    StateDeltaDCD,
    StateTmrPublic,
    StateTmr1: TMailerState;

  // Classes
    YooHooPkt: TYooHooPacket;
    Faxmodem: TFaxmodem;
    ReqLines: TColl;
    HReqDelete,
    EMSI_Addons: TStringColl;
    rmtAddrs: TFidoAddrColl;
    PostEMSILogErrors: TStringColl;

    AuxTmr,
    HShRLast,
    LastModemUpd: EventTimer;

    SentFiles,
    OutFiles: TOutFileColl;
    LoggedStrs,
    DisabledFiles: TStringColl;

    Prot: TBaseProtocol;
    ModemRec: TModemRec;

    LoginScript: TColl;

    RespFmtREs: TColl;  // contains a list of   TRespFmtREHolder
    InputFmtREs: TColl;
    InputWdResetREs: TColl;
    InputWdExtAppREs: TColl;
    LoginWdREs: TColl;

//  Class pointers

    ActivePoll: TFidoPoll;
    WzRec: TBWZRec;
 // Temporary classes

    AkaB,
    AkaA,
    RcvdNames: TStringColl;
    Station: TStationDataColl;
    rmtPrimaryAddr: TFidoAddress;
    rmtLinkCodes: TEMSILinkCodes;
    rmtEMSICompat: TEMSICapabilities;

    DesiredProtocol: TEMSICapability;
    ExtAppProcessNfo: TProcessInformation;
    rmtMailerFlags: TRemoteMailerFlags;
    rmtEMSILinkCodes: TEMSILinkCodes;
    OurProtocols: TEMSICapabilities;

    TmrReInit,
    Tmr1: EventTimer;

    rmtPwdAddr: TFidoAddress;

    SessionKeyAddr: TFidoAddress;
    SessionKey: TDesBlock;

 { --- string }

    LastCallerID,
    ModemInfoString,
    LastSentString,
    LastModemInitString,
    rmtMailerName,
    rmtMailerCode,
    rmtMailerVersion,
    rmtMailerSerialNo,
    InB, InC,
    rmtTime,
    rmtUnkCompat,
    rmtUnkLinkCodes,
    rmtTrafInfo,
    rmtPassword,
    locPassword,
    LogonBanner,
    LastResponse,
    ExtAppStr,
    OutAddrs
    : string;

 { --- integers }

    OpenSerTries,
    FTS1Count,
    cTxBytes, cRxBytes,
    FilesReceived,
    FilesSent,
    rmtTRX,
    RingCount,
    txMail, txFiles,
    ConnectStart,
    SessionStart,
    ConnectSpeed,
    RingsToAnswer,
    RingsDone: DWORD;

    YooHooCount,
    Tries,
    TriesA,

    LoginStep

    : Integer;

 { --- enumerations }

    RemoteListed: TRemoteListedFlag;

 { --- booleans }
    ConnectRegExp,
    ConnectSpeedGot,
    DirtyInC,
    AtomDisconnected,
    CramMD5,
    SendDummyPkt,
    AnswerAfterInit,
    ReportedLogOK,
    YooHooAcked,
    SkipInMem,
    NiagaraAllowed,
    FTS1NeedRmtAddr,
    MayFTS1,
    MayYooHoo,
    DummyZFrb,
    MayEMSI,
    EMSI_Logged,
    NeedModemStatx,
    InitModemLogged,
    HandshakeTimeLogged,
    FReqProcessed,
    DelayEOB,
    rmtPrimaryAddrSet,
    rmtPwdAddrSet,
    ExtPoll,
    FaxConnection,
    AcceptReq,
    SessionOK,
    NoCrLf,
    ExtAppCloseSerial,
    HstLink,
    SkipHangup,
    WasHangup,
    PasswordProtected,
    WeHaveReported,
    GotNak,
    BadPassword,
    Accumulate,
    Accumulated,
    LogEntireModemInput,
    KillSentREQ,
    AnswerRequest,
    FileRefuse, FileSkip,
    NiagaraSession : Boolean;
    SessionCore: TSessionCore;
    destructor Destroy; override;
  end;



  TMailerThread = class(TCommThread)
  private
    NextNeedModemStatx: Boolean;
  {$IFDEF WS}
    toEMSI_CR,
    toEMSI_S3,
    toEMSI_Block,
    toEMSI_Timeout: DWORD;
    IpPort: DWORD;
    IpIdx: DWORD;
    CurrentIPFlag: TLockFile;
  {$ENDIF}
    ProtCore: TProtCore;
    __FName: string;
    __LineNumber: DWORD;
    RestoreBPS: Boolean;

    TmrNextDial: EventTimer;

    ForceDisplayData: DWORD;

    WaitEvts: array[0..2+MaxProcesses] of DWORD;

    EP: TMailerThreadEventProcessor;

  // Classes

    ActiveFile: TLockFile;
    Logger: TMailerThreadLogger;

    ProcessColl,
    EvtQueue: TColl;

    SelfTerminate : Boolean;


 // Critical Sections

    EvtCS: TRTLCriticalSection;

 // Win32 handles

    oEvt: DWORD;


 { --- display data }

    DS: TDisplayStringData;

 { --- mailer states }

    PrevState,
    OldState   : TMailerState;

    {---}

    LogFHandle: DWORD;

    LogFName: string;

    FaxInbound: string;

    EvtNew: Boolean;

    procedure LogOverwritten(const FName: string);
    procedure LogMoved(const FName: string);
    procedure PollDone;
    procedure DoRestoreSerial;
    procedure RestoreSerial;
    procedure GetFaxFName(const Aext: string);
    procedure ReportT30(var t: TFaxT30Params);
    procedure ParseFaxResponse(const Astr: string);
    procedure LogHandshakeStart;
    procedure LogPostEMSIErr(const Msg: string);
    procedure Log(CurTag: TLogTag; const CurStr: string);
    procedure LogOnce(CurTag: TLogTag; const CurStr: string);
    procedure LogFmt(CurTag: TLogTag; const FmtStr: string; const Args: array of const);
    procedure FlushLog;
    function SendModemInitString: Boolean;
    function ModemInitString: string;
    procedure GetStationData;
    procedure LogEMSIData;
    procedure Initialize;
    procedure UpdateModem;

    procedure SetTmrPublic(TimeoutSecs: DWORD; NewStatus: TMailerState);
    procedure SetTmr1(TimeoutSecs: DWORD; NewStatus: TMailerState);
    procedure SetTmr1Msec(TimeoutMSecs: DWORD; NewStatus: TMailerState);

    procedure ClearTmrPublic;
    procedure ClearTmr1;

    function LineNumber: DWORD;
    procedure GetConnectSpeed;
    procedure DoPollsRecalc;
    procedure LetsSleep;
    procedure DoEvt;
    procedure DoAccumulate;
    procedure DoConnect;
    procedure DoMisc;
    procedure DoHSh;
    procedure DoEMSI;
    procedure DoWZ;
    procedure DoExtApp;
    procedure DoFax;
    function LockAKAs: Boolean;
    procedure SendEMSIData(const Password: string; Cap: TEMSICapabilities);
    procedure ParseEMSIData;
    function CheckPasswords: Boolean;
    procedure DisplayData;
    procedure DoDisplayData;
    function AcceptFile(P: TBaseProtocol): TTransferFileAction;
    procedure GetNextFile(P: TBaseProtocol);
    procedure FinishRece(P: TBaseProtocol; Action: TTransferFileAction);
    procedure FinishSend(P: TBaseProtocol; Action: TTransferFileAction);
    procedure ScanOut;
    procedure LogFile(P: TBaseProtocol; AStatus: TLogFileStatus);
    function SendModemString(const AStr: string): boolean;
    procedure ReportReq;
    procedure ProcessSRPs(C: TStringColl);
    procedure AttachERPFiles(SC1, SC2, SC3: TStringColl);
    procedure UpdateData;
    procedure TossBWZ;
    procedure LogComError;
    function GetCPS(AStart, ASize: DWORD): string;
    procedure CheckCPS;
    procedure CheckDuration;
    function GetCPSInt(AStart, ASize: DWORD): Integer;
    function GotExtApp: Boolean;
    function ModemResponse: TModemStdRespIdx;
    function ModemResponseMask(AMask: TModemStdRespIdxSet): TModemStdRespIdx;
    procedure RespGotMatch(j: Integer; const W: string; i: TModemStdRespIdx);
    function ModemResponseCn: TModemStdRespIdx;
    procedure PostTermStr(const AStr: string; ATop, ACrLf, ALit: Boolean);
    function ChkErrMsg: Boolean;
    function LockAddr(const Addr: TFidoAddress): Boolean;
    procedure SendStr(const S: string);
    function HangupModem: Boolean;
//    procedure ChkFileFlags;
    procedure LogPoll(const S: string);
    {$IFDEF WS}
    procedure LogDaemon(const S: string);
    {$ENDIF}
    procedure LogBinkPNul(const S: string);
    function ChkNonEmsiPwd(P: TBaseProtocol): Boolean;
    function ChkBinkPAdr(const S: string; P: TBaseProtocol): Boolean;
    function GetBinkPPwd(A: TFidoAddress): string;
    function  SetBinkPCanEOB: Char;
    {$IFDEF WS}
    procedure CopyIpStation;
    {$ENDIF}
    procedure DoCopyDialupStation;
    procedure GetAddrs(const S: string);
    function GetPortName: string;
    procedure DoSE_NoConnect;
    procedure DoSE_Busy;
    procedure DoSE_SessionAborted;
    procedure FreeCP;
    function GetTraf(sTRAF: string; Hex: Boolean): Boolean;
    procedure LogTrafInfo;
    function DoConnectStart: Boolean;
    procedure FilterProtocols(const AFlags: string);
    procedure LogConnect;
    procedure LogUnexpEMSI(Seq: TEMSISeq);
    function TossSingleBWZ(BWZ: TBWZRec; var s: string): Boolean;
    procedure RunPostProcessors;
    procedure SetStatusMsg(Id: DWORD; const Param: string);
    function NoAnyValidAddrs: Boolean;
    function GetOutAKAs(const Addr: TFidoAddress): string;
    function GetInAKAs: string;
    procedure CreateStation;
    function ValidConnection: Boolean;
    procedure ProcessSRIF(var ASC: TStringColl; const AExeFName, ATmpDir: string);
    procedure ProcessRequestFTS(var ASC: TStringColl);
    procedure CommonStatx;
    procedure DeleteFile(const FName: string);
    procedure StartEMSI_Receiver(AState: TMailerState);
    procedure FreeHReqDelete(ALog: Boolean);
    procedure SetSessionKey(const A: TFidoAddress);
    function ValidEncryptedAKAs: Boolean;
    function __EMSI_REQ: string;
    procedure DoRemoveNiagara;
    function ChkAddrStr(const S: string): Boolean;
    procedure DoInvokeExec;
    function ChkFax: Boolean;
    procedure AddFaxPage;
    procedure WriteTIFF;
    procedure FreeSD;
    procedure FreeFaxModem;
    function RemoteListed: Boolean;
{2}public
    {$IFDEF WS}
    DialupLine: Boolean;
    {$ENDIF}
    CP_CS: TRTLCriticalSection;

    PubBatchT,
    PubBatchR: TBatch;

    State: TMailerState;
    OwnPolls: TColl;

    AnswerAfterInit,
    PortReloaded: Boolean;

    SD: TMailerThreadInitData;
    D,
    PublicD: TDisplayData;
    PublicDS: TDisplayStringData;
    LogStrings: TStringColl;
    LineId: DWORD;
    TermTxData,
    TermRxData: TTermData;
    LogCS: TRTLCriticalSection;
    TruncateLog: Boolean;
    DisplayDataCS: TRTLCriticalSection;

    LastLogStr: string;
    NewLogStr: string;
    function GetThrErrorMsg: string; override;
    procedure InvokeDone; override;
    function Name: string;
    procedure InsertEvt(E: TMlrEvt);
    procedure InvokeExec; override;
    destructor Destroy; override;
    function EMSI_CR: string;
    class function ThreadName: string; override;
  end;

  TCronBaseThread = class(T_Thread)
    oEvt: THandle;
    Again: Boolean;
    LastTimeLocal, LastTimeUTC: TSystemTime;
    function NextMinute: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  TCronThread = class(TCronBaseThread)
    WaitEvts: array[0..1+MaxProcesses] of DWORD;
    ProcsLogger: TCronThreadLogger;
    ProcsLogFName: string;
    ProcsLogFHandle: DWORD;
    ProcessColl: TColl;
    Recalc: Boolean;
    //PollsCron, PollsAddrs,
    PerPolls: TPerPollColl;
    ProcsCron: TColl;
    ProcsStrs: TStringColl;
    procedure DoRecalc;
    procedure InvokeDone; override;
    procedure InvokeExec; override;
    constructor Create;
    destructor Destroy; override;
    procedure CheckPolls;
    procedure CheckProcesses;
    procedure DoCheck;
    class function ThreadName: string; override;
  end;

  TEventsThread = class(TCronBaseThread)
    Events: TColl;
    constructor Create;
    destructor Destroy; override;
    procedure DoRecalc;
    procedure InvokeExec; override;
    procedure Check;
    class function ThreadName: string; override;
  end;

  TOlEventContainer = class(TElementOnly)
    CronRec: TCronRecord;
    Len, Age: DWORD;
    Atoms: TColl;
    function Active: Boolean;
    procedure TimeSync(lt: DWORD);
    destructor Destroy; override;
  end;

  TUpdateTermStruc = class
    CrL,
    Top: Boolean;
    Lit: Boolean;
    Thr: TMailerThread;
    Str: string;
  end;


  TOutMgrThread = class(T_Thread)
    oEvt: DWORD;
    Nodes: TOutNodeColl;
    NodesCS: TRTLCriticalSection;
    ForcedUpdate: Boolean;
    OldNodes: TOutNodeColl;
    constructor Create;
    destructor Destroy; override;
    procedure InvokeExec; override;
    class function ThreadName: string; override;
  end;

  TPollState = (plsUNK, plsBSY, plsAVL, plsN_A, plsPUB, plsFRB);


{$IFDEF WS}
  TIPPollsThread = class(T_Thread)
    oSleep: DWORD;
    DaemonExtPollThreads: TColl;
    LogContainer: TLogContainer;
    Logger: TDaemonThreadLogger;
    OwnPolls: TColl;
    Again: Boolean;
    constructor Create;
    procedure InvokeDone; override;
    procedure InvokeExec; override;
    destructor Destroy; override;
    procedure BurnOutLine(p: TFidoPoll);
    class function ThreadName: string; override;
  end;
{$ENDIF}

const
  yhY_DIETIFNA = $0001;
  yhFTB_USER   = $0002;
  yhZED_ZIPPER = $0004;
  yhZED_ZAPPER = $0008;
  yhDOES_IANUS = $0010;
  yhDOES_Hydra = $0020;
  yhDO_DOMAIN  = $4000;
  yhWZ_FREQ    = $8000;

var
  FileFlags: TColl;
  FidoPolls: TPollColl;
  MailerThreads,
  MailerForms: TColl;
  OutMgrThread: TOutMgrThread;
  CronThr: TCronThread;
{$IFDEF WS}
  IPPolls: TIPPollsThread;
{$ENDIF}

function OpenMailerThread(APort: TPort; ALineId: DWORD{$IFDEF WS}; NI: TNewIPLineData{$ENDIF}; ACW, ACH: Integer): TMailerThread;
procedure _RecalcPolls;
procedure InitMailers;
procedure DoneMailers;
{$IFDEF WS}
procedure _RunDaemon;
procedure _ShutdownDaemon;
{$ENDIF}
function NodeDataStr(ANode: TAdvNode; AddFlags: Boolean): string;
procedure PurgeZombies;
function GetPortRec(LineId: DWORD): TPortRec;
function OpenSerialPort(R: TPortRec): TPort;
procedure InsertPoll(ANode: TAdvNode; ATyp: TPollType);
function PollOwnerName(p: TFidoPoll): string;
function GetPollState(AOwnPolls: TColl; P: TFidoPoll; PubInst: Boolean; Mlr: TMailerThread; SC: TStringColl; TQ: TFSC62Quant): TPollState;
procedure RollPoll(var ActivePoll: TFidoPoll);
procedure EnterFidoPolls;
procedure LeaveFidoPolls;
function FormatLogStr(CurTag: TLogTag; const CurStr, AName: string): string;
procedure InvalidatePollAddrs;
function ConvertFaxPage(T30_wd: DWORD; Stream: TxMemoryStream): Pointer;
function AllowedMdmCmdState(AState: TMailerState): Boolean;


implementation

uses
  NTdyn,
  LngTools, OdbcLog,
  SysUtils, Classes, NdlUtil, Forms,
  p_Zmodem, p_Hydra, p_Binkp, FTS1, xNiagara;


type

  TProcessNfo = class
    PI: TProcessInformation;
    Name: string;
  end;


  TCommonLog = class
    accessFName: string;
    accessFHandle: DWORD;
    agentFName: string;
    agentFHandle: DWORD;
    CS: TRtlCriticalSection;
    procedure Add(const Addr: TFidoAddress; FName: string; Get: Boolean; FSize: DWORD; const Mailer: string);
    constructor Create;
    destructor Destroy; override;
  end;

  TCommonStatx = packed record
    Zone,		
    Net,
    Node,
    Point: Word;
    TimeBeg,           // UNIX-style time of session start
    TimeLen,           // session duration (sec)
    BytesRcv,          // sum of sizes of files received (bytes)
    BytesSnt: DWORD;   // sum of sizes of files sent (bytes) 
    FilesRcv,          // number of files received during a session
    FilesSnt: Byte;    // number of files sent during a session 
    Typ: Word;
  end;


const

  cUsingLogFile = 'Using log file %s';
  CReinitTime = 120;


  VirtualCD = True;

  cstIncoming   = $01;
  cstOutgoing   = $02;
  cstSuccessful = $04;
  cstProtected  = $08;
  cstIP         = $10;

  MlrThreadStateName: array[TMailerState] of string = (
     'msNone',
     '__FirstExtApp',
     'msExtApp_0',
     'msExtApp_1',
     'msExtApp_2',
     'msExtAppWait',
     'msExtAppWaitOK',
     '__LastExtApp',
     '__FirstCN',
     'msCN_ConnectStringTmr',
     'msCN_ConnectStringDCD',
     'msCN_ConnectString',
     'msCN_ConnectString_A',
     'msCN_GetSpeed',
     'msCN_HandshakeDelay',
     'msCN_HandshakeOK',
     'msCN_HandshakeStart',
     'msCN_ConnectDCD',
     'msCN_ConnectDCD_A',
     'msCN_ConnectDCD_w',
     '__LastCN',
     '__FirstMisc',
     'msCheckOut',
     'msError',
     'msModemStatx',
     'msInit',
     'msDone',
     'msStart',
     'msInitOK',
     'msInitOK_',
     'msInitFreeCP',
     'msStillHigh',
     'msInitModem_I',
     'msInitModem',
     'msInitModemA',
     'msHangup',
     'msRingAfterIdle',
     'msGotNextRing',
     'msStartWaitNextRing',
     'msWaitNextRing',
     'msRingTimerExpired',
     'msStartIdle',
     'msIdle',
     'msIdleA',
     'msIdleA_Expired',
     'msModemCmdIdle',
     'msStartAnswer',
     'msAnswerFailed',
     'msAnswering',
     'msCarrierLost',
     'msHandshakeTimeout',
     'msStartDial',
     'msStartExtPoll',
     'msStartDialPhone',
     'msStartDialOK',
     'msStartDialFailed',
     'msTryOpenSer',
     'msTryOpenSerW',
     'msTryOpenSerAgain',
     'msDialling',
     'msRinging',
     'msDialTimeout',
     'msCancel',
     'ms_NoValidAddr',
     'ms_WrongOutDial',
     'msSE_Busy',
     'msSE_NoConnect',
     'msSE_SessionAborted',
     'msSE_OK',
     'msSE_OKa',
     'msSE_OKb',
     'msSE_OKc',
     '__LastMisc',
     '__FirstHSh',
     'msHSh_s1',  // Calling system
     'msHSh_Login_1',
     'msHSh_Login_2',
     'msHSh_Login_2_matched',
     'msHSh_Login_3',
     'msHSh_Login_4',
     'msHSh_s1c',
     'msHSh_s1t',
     'msHSh_swz',
     'msHSh_sw',
     'msHSh_s3',
     'msHSh_s3c',
     'msHSh_sES',
     'msHSh_sES2',
     'msHSh_sYh',

     'msHSh_r1',  // Answering system
     'msHSh_r2z',
     'msHSh_r2',
     'msHSh_TCP',
     '__LastHSh',
     '__FirstEMSI',
     'msEMSI_h2',
     'msEMSI_h3',
     'msEMSI_h4z',
     'msEMSI_h4',
     'msEMSI_h5',
     'msEMSI_parsed',
     'msEMSI_h5_0',
     'msEMSI_h5a',
     'msEMSI_h5b',
     'msEMSI_h5calc',
     'msEMSI_c1z',
     'msEMSI_c1',  // EMSI send data
     'msEMSI_c2',
     'msEMSI_c2a',
     'msEMSI_c3',
     'msEMSI_c4req',
     'msEMSI_c4nak',
     'msEMSI_c4_',
     'msEMSI_c4',
     'msEMSI_c5',
     'msEMSI_FailPkt',
     'msEMSI_Timeout',
     'msEMSI_FailTries',
     'msEMSI_PswVio',
     'msEMSI_DCD',
     '__LastEMSI',
     '__FirstWZ',
     'msStartBinkP',
     'msStartWZ',
     'msStartFTS1',
     'msStartYooHoo',
     'msSendYooHoo',
     'msWaitYooHooAck',
     'msWaitYooHooEnq',
     'msInitYooHoo',
     'msParseYooHoo',
     'msWaitYooHooPkt',
     'msFinishWZ',
     'msOneWayStartTxBatch1',
     'msOneWayTxBatch1',
     'msOneWayStartRxBatch2',
     'msOneWayRxBatch2',
     'msOneWayStartTxBatch3',
     'msOneWayTxBatch3',
     'msBiDirStartBatch1',
     'msBiDirBatch1',
     'msBiDirStartBatch2',
     'msBiDirBatch2',
     'msWZOK',
     '__LastWZ',
     '__FirstFax',
     'msFaxBegin',
     'msFaxStartRece',
     'msFaxTimeout',
     'msFaxRecePage_',
     'msFaxRecePage',
     'msFaxError',
     'msFaxDCD',
     'msFaxHangup',
     'msFaxOK',
     'msFaxWaitCN_',
     'msFaxWaitCN',
     'msFaxGood',
     'msFaxReadG3',
     'msFaxEndPage',
     'msFaxWaitFet_',
     'msFaxWaitFet',
     'msFaxPageGood',
     'msFaxEnd',
     '__LastFax');

// --- Variables

var
  CommonStatxCS: TRTLCriticalSection;
  CommonStatxFName: string;
  CommonStatxHandle: DWORD;
  CommonLog: TCommonLog;
  EventsThr: TEventsThread;
  Zombies: TColl;
  LastZombiesPurged: EventTimer;
{$IFDEF WS}
  DaemonEvents: TDaemonEventProcessor;
  DaemonActiveFlag: TLockFile;
{$ENDIF}


// --- Service routines

procedure FidoPollsLog(const s: string);
begin
  FidoPolls.Log.LogSelf(s);
end;

procedure FinalizePollOK(var P: TFidoPoll);
begin
  FidoPollsLog(Format('%s - session complete', [Addr2Str(P.Node.Addr)]));
  if P.FileSendDelayed then
  begin
    NewTimerSecs(p.LastTry, FidoPolls.Options.d.Standoff*60);
    FidoPollsLog(Format('%s - file send delayed, stand-off timeout (%d minutes) has started', [Addr2Str(p.Node.Addr), FidoPolls.Options.d.Standoff]));
  end else
  begin
    P.Done := pdnOK;
    EnterFidoPolls;
    FidoPolls.Delete(P);
    LeaveFidoPolls;
    FreeObject(P);
  end;
end;


procedure _RecalcPolls;
var
  i: Integer;
begin
  if MailerThreads <> nil then for i := 0 to MailerThreads.Count-1 do TMailerThread(MailerThreads[i]).InsertEvt(TMlrEvtPollsRecalc.Create);
  {$IFDEF WS}
  if IPPolls <> nil then SetEvt(IPPolls.oSleep);
  {$ENDIF}
end;


{function ArrMatch(v: Byte; p: PxByteArray; c: Byte): Boolean;
var
  i,j: Integer;
begin
  Result := True;
  if c > 0 then
  begin
    j := c;
    for i := 0 to j-1 do if p^[i]=v then Exit;
    Result := False;
  end;
end;}


function CronMatchEx(const t: TSystemTime; const c: TCronRecord; AllowPermanent: Boolean): Boolean;
const
  DowXlt: array[0..6] of Byte = (6,0,1,2,3,4,5);
var
  i: Integer;
begin
  if c.IsPermanent then
  begin
    Result := True;
    if not AllowPermanent then GlobalFail('assert(%s)', [AllowPermanent]);
  end else
  begin
      Result := False;
    for i := 0 to c.Count-1 do
    begin 
      Result := (t.wMinute in c.p^[i].Minutes) and
                (t.wHour in c.p^[i].Hours) and
                (t.wDay-1 in c.p^[i].Days) and
                (t.wMonth-1 in c.p^[i].Months) and
                (DowXlt[t.wDayOfWeek] in c.p^[i].Dows);
      if Result then Exit;
    end;

              {     getsystemtime
              ArrMatch(t.wMinute, @c.Minutes, c.NumMinutes) and
              ArrMatch(t.wHour, @c.Hours, c.NumHours) and
              ArrMatch(t.wDay, @c.Days, c.NumDays) and
              ArrMatch(t.wMonth, @c.Months, c.NumMonths) and
              ArrMatch(DowXlt[t.wDayOfWeek], @c.Dows, c.NumDows);
              }
  end;
end;

function CronMatch(const t: TSystemTime; const c: TCronRecord): Boolean;
begin
  Result := CronMatchEx(t, c, False);
end;

function CronMatchP(const t: TSystemTime; const c: TCronRecord): Boolean;
begin
  Result := CronMatchEx(t, c, True);
end;


function PollOwnerName(p: TFidoPoll): string;
begin
  {$IFDEF WS}
  if p.Owner = PollOwnerDaemon then Result := 'TCP/IP Daemon' else
  {$ENDIF}
  if p = nil then GlobalFail('%s', ['PollOwnerName']) else Result := p.Owner.Name;
end;

function GetPollPtr(OwnPolls: TColl; P: TFidoPoll): TPollPtr;
   // must be called within FidoPolls Critical Section
var
  i: Integer;
  PP: TPollPtr;
begin
  Result := nil;
  for i := OwnPolls.Count-1 downto 0 do
  begin
    PP := OwnPolls[i];
    if P = PP.Poll then
    begin
      Result := PP;
      Exit;
    end;
  end;
end;

procedure EnterEvents;
begin
  EventsThr.Events.Enter;
end;

procedure LeaveEvents;
begin
  EventsThr.Events.Leave;
end;

function PreparePoll(P: TFidoPoll; PP: TPollPtr; var NI: DWORD; TQ: TFSC62Quant; Restriction: TRestrictionData; SC: TStringColl {$IFDEF WS}; Dialup: Boolean{$ENDIF}): Boolean;
var
  k: Integer;
  idx: DWORD;
  d: TAdvNodeData;
  dc: TColl;
  s,m: string;
  t: TFSC62Time;

procedure LogThis(c: Char; const s: string);
var
  z: string;
begin
  {$IFDEF WS} if not Dialup then z := d.IPAddr else {$ENDIF}z := d.Phone;
  SC.Add(Format(' %s %s,%s - %s', [c, z, d.Flags, s]));
end;

procedure LogOK;
begin
  LogThis('+', LngStr(rsMMpiOK));
end;

begin
  Result := False;
  // find our poll
  if SC = nil then NI := PP.Idx else NI := 0;
  {$IFDEF WS}if not Dialup then dc := P.Node.IPData else {$ENDIF} dc := P.Node.DialupData;
  if dc = nil then
  begin
    if P.Node.Ext = nil then
    begin
      if SC <> nil then SC.Add(' ? '+LngStr(rsMMpiNoData));
    end else
    begin
      if SC <> nil then LogOK;
      Result := True;
    end;
    Exit;
  end;
  for k := 0 to dc.Count-1 do
  begin
    idx := NI mod DWORD(dc.Count);
    d := dc[idx];
    Inc(NI);
    {$IFDEF WS}
    if not Dialup then s := d.IPAddr else
    {$ENDIF}
    s := WipePhoneNumber(d.Phone);
    if not DialAllowed(Restriction, d.Flags, s, P.Node.Addr, m) then
    begin
      if SC <> nil then LogThis('*', FormatLng(rsMMpiRA, [m]));
      Continue;
    end;
    if (P.Typ<>ptpManual) then
    begin
      t := NodeFSC62TimeEx(d.Flags, P.Node.Addr, False);
      if not (TQ in t) then
      begin
        if SC <> nil then LogThis('!', Format('%s (%s UTC / %s Local)', [LngStr(rsMMpiNWT), FSC62TimeToStr(t), FSC62TimeToStr(NodeFSC62TimeEx(d.Flags, P.Node.Addr, True))]));
        Continue;
      end;
    end;
    Result := True;
    if SC = nil then
    begin
      P.DataIdx := idx;
      Break
    end else
    begin
      LogOK;
    end;
  end;
end;


function GetPollState(AOwnPolls: TColl; P: TFidoPoll; PubInst: Boolean; Mlr: TMailerThread; SC: TStringColl; TQ: TFSC62Quant): TPollState;
var
  RR: TRestrictionData;

procedure DoIt;
var
  R, F: TColl;
  PP: TPollPtr;
  EP: TAbstractEventProcessor;
  NI: DWORD;
  II: Integer;
  lRestrictions, lLines: TElementColl;
begin
  Result := plsN_A;
  if (p.Owner = PollOwnerExtApp) and (not PubInst) then p.Owner := nil;
  if p.Owner <> nil then
  begin
    if SC <> nil then
    begin
      SC.Add(FormatLng(rsMMobl, [PollOwnerName(p)]));
    end;
    Exit;
  end;
  if p.Typ <> ptpManual then
  begin
    case p.Node.PrefixFlag of
      nfPvt, nfHold, nfDown:
        begin
          if SC <> nil then SC.Add(Format('The node has %s status in the nodelist. Use manual poll to connect anyway.', [cNodePrefixFlag[p.Node.PrefixFlag]]));
          Exit;
        end;
    end;
  end;
  if (p.Typ <> ptpManual) and ((p.CountersExceeded) or (p.FileSendDelayed)) then
  begin
    if TimerInstalled(p.LastTry) and TimerExpired(p.LastTry) then
    begin
      FidoPollsLog(Format('%s - stand-off timeout expired', [Addr2Str(p.Node.Addr)]));
      p.Reset;
    end else
    begin
      if not TimerInstalled(p.LastTry) then NewTimerSecs(p.LastTry, FidoPolls.Options.d.Standoff*60);
      if p.FileSendDelayed then
      begin
        if SC <> nil then SC.Add(Format('File send delayed, stand-off: %d minutes left. Busy[%s], NoConn[%s], Aborted[%s]', [MaxD(1, RemainingTimeSecs(p.LastTry) div 60), p.STryBusy, p.STryNoC, p.STryFail]));
      end else
      begin
        if SC <> nil then SC.Add(Format('Try counter exceeded, stand-off: %d minutes left. Busy[%s], NoConn[%s], Aborted[%s]', [MaxD(1, RemainingTimeSecs(p.LastTry) div 60), p.STryBusy, p.STryNoC, p.STryFail]));
      end;
      Exit;
    end;
  end;
  Result := plsFRB;

  PP := GetPollPtr(AOwnPolls, P);
  if PP = nil then GlobalFail('%s', ['GetPollPtr=nil']);

  {$IFDEF WS}
  if Mlr = PollOwnerDaemon then
  begin
    CfgEnter;
    RR := Cfg.IPData.Restriction.Copy;
    CfgLeave;
    EP := DaemonEvents;
  end else
  {$ENDIF}
  begin
    CfgEnter;
    lRestrictions := Cfg.Restrictions.Copy;
    lLines := Cfg.Lines.Copy;
    CfgLeave;
    EP := Mlr.EP;
    RR := TRestrictionRec(lRestrictions.GetRecById(EP.DwordValueD(eiRplRestriction, TLineRec(lLines.GetRecById(Mlr.LineId)).d.RestrictId))).Data.Copy;
    FreeObject(lRestrictions);
    FreeObject(lLines);
  end;
  R := EP.GetAtomList(eiRestrictRqd);
  F := EP.GetAtomList(eiRestrictFrb);
  for II := 0 to CollMax(R) do RR.Required.Add(TEvParString(R[II]).s);
  for II := 0 to CollMax(F) do RR.Forbidden.Add(TEvParString(F[II]).s);
  FreeObject(R);
  FreeObject(F);

  if not PreparePoll(p, PP, NI, TQ, RR, SC {$IFDEF WS}, Mlr <> PollOwnerDaemon{$ENDIF}) then Exit;

  if PubInst then
  begin
    Result := plsPUB;
    Exit;
  end;

  if not FidoOut.Lock(p.Node.Addr) then
  begin
    p.Owner := PollOwnerExtApp;
    Result := plsBSY;
    Exit;
  end;

  Result := plsAVL;
  if SC = nil then
  begin
    PP.Idx := NI;
    LeaveFidoPolls;
    p.Owner := Mlr;
    NewTimerSecs(p.LastTry, FidoPolls.Options.d.Standoff*60);
{    if (p.Typ <> ptpManual) and (p.CountersExceeded) then
    begin
      FidoPollsLog(Format('%s - stand-off timeout (%d minutes) has started', [Addr2Str(p.Node.Addr), FidoPolls.Options.d.Standoff]));
    end;}
  end;
end;

begin
  RR := nil;
  DoIt;
  FreeObject(RR);
end;


function GetAvailPoll(AOwnPolls: TColl; var PubInst: Boolean; Mlr: TMailerThread; var AP: TFidoPoll; ALogger: TAbstractLogger): Boolean;

procedure LocLog(const S: string);
begin
  ALogger.Log(ltGlobalErr, S);
end;

var
  i: Integer;
  p: TFidoPoll;
  TQ: TFSC62Quant;
  s: string;
  SC: TStringColl;
begin
  SC := nil;
  Result := False;
  AP := nil;
  TQ := CurFSC62Quant;
  for i := 0 to FidoPolls.Count-1 do
  begin
    p := FidoPolls[i];
    case GetPollState(AOwnPolls, P, PubInst, Mlr, SC, TQ) of
      plsBSY :
        begin
          if SC <> nil then SC.Add(LngStr(rsMMOwnByExt)) else
          begin
            s := GetErrorMsg;
            if s <> '' then
            begin
              LocLog(s);
            end;
            s := Format('Address %s is busy', [Addr2Str(p.Node.Addr)]);
            if p.Typ = ptpManual then
            begin
              LocLog(s);
            end;
          end;
        end;
      plsAVL :
        begin
          AP := p;
          PubInst := False;
          Result := True;
          Exit;
        end;
      plsN_A : ;
      plsFRB : ;
      plsPUB :
        begin
          if SC <> nil then SC.Add('Skoro pozvonim');
          AP := p;
          Result := False;
          Exit;
        end;
      else GlobalFail('%s', ['GetAvailPoll GetPollState ??']);
    end;
  end;
  PubInst := False;
end;

function NodeDataStr(ANode: TAdvNode; AddFlags: Boolean): string;

procedure iStr(C: TColl; Dialup: Boolean);
var
  J: Integer;
  d: TAdvNodeData;
begin
  if C = nil then Exit;
  for J := 0 to C.Count-1 do
  begin
    D := C[J];
    if Result <> '' then Result := Result + '; ';
    if Dialup then Result := Result + PatchPhoneNumber(D.Phone, False) else
      Result := Result + D.IPAddr;
    if (AddFlags) and (D.Flags <> '') then Result := Result + ',' + D.Flags;
  end;
end;

begin
  Result := '';
  iStr(ANode.IPData, False);
  iStr(ANode.DialupData, True);
end;

procedure InsertOwnPoll(AOwnPolls: TColl; ap: TFidoPoll);
var
  PP: TPollPtr;
begin
  PP := TPollPtr.Create;
  PP.Poll := ap;
  AOwnPolls.Insert(PP);
end;


procedure InsertPoll(ANode: TAdvNode; ATyp: TPollType);
var
  OldTyp, NewTyp: TPollType;
  P, AP: TFidoPoll;
  I: Integer;
const
  CTyp: array[TPollType] of string=('???', 'Outb','Cron','Manual');
begin
  EnterFidoPolls;
  AP := nil;
  for I := 0 to FidoPolls.Count-1 do
  begin
    P := FidoPolls[i];
    if CompareAddrs(ANode.Addr, p.Node.Addr) = 0 then
    begin
      AP := P;
      Break;
    end;
  end;

  if AP <> nil then
  begin
    OldTyp := AP.Typ;
    NewTyp := TPollType(MaxD(DWORD(OldTyp), DWORD(ATyp)));
    if OldTyp <> NewTyp then
    begin
      AP.Typ := NewTyp;
      AP.Reset;
    end;
    FreeObject(ANode);
  end else
  begin
    FidoPollsLog(Format('+Poll/%s  %s  (%s)', [CTyp[ATyp], Addr2Str(ANode.Addr), NodeDataStr(ANode, True)]));
    P := TFidoPoll.Create;
    P.Node := ANode;
    P.Typ := ATyp;
    FidoPolls.AtInsert(0, P);
    MailerThreads.Enter;
    for I := 0 to MailerThreads.Count-1 do InsertOwnPoll(TMailerThread(MailerThreads[I]).OwnPolls, P);
    {$IFDEF WS}
    if IPPolls <> nil then InsertOwnPoll(IPPolls.OwnPolls, P);
    {$ENDIF}
    MailerThreads.Leave;
  end;
  LeaveFidoPolls;
end;


function OutDial(A: TOutStatusSet; DirAsNormal: Boolean): Boolean;
begin
  Result := (os_Crash in A) or
            (os_CrashMail in A);
  if (not Result) and (not DirAsNormal) then
  Result := (os_Direct in A) or
            (os_DirectMail in A);
end;


procedure RecreatePolls(c: TOutNodeColl);
var
  i,j: Integer;
  p: TFidoPoll;
  n: TOutNode;
  an: TAdvNode;

procedure FreePoll_I_P;
begin
  p.Done := pdnAttachLost;
  FidoPolls.AtFree(i);
end;

var
  DirAsNormal: Boolean;
begin
  EnterFidoPolls;
  DirAsNormal := pofDirAsNormal in FidoPolls.Options.d.Flags;
  LeaveFidoPolls;
  for i := FidoPolls.Count-1 downto 0 do
  begin
    p := FidoPolls[i];
    if (p.Owner = nil) or (p.Owner = PollOwnerExtApp) then
    begin
      if c.Search(@p.Node.Addr, j) then
      begin
        n := c[j];
        if (p.Typ = ptpOutb) and (not OutDial(n.FStatus, DirAsNormal)) then FreePoll_I_P;
        c.AtFree(j);
      end else
      begin
        if p.Typ = ptpOutb then FreePoll_I_P;
      end;
    end;
  end;
  for i := 0 to c.Count-1 do
  begin
    n := c[i];
    if OutDial(n.FStatus, DirAsNormal) then
    begin
      an := FindNode(n.Address);
      if (an = nil) or ((an.DialupData = nil) and (an.IPData = nil)) then
      begin
        FreeObject(an)
      end else
      begin
        InsertPoll(an, ptpOutb);
      end;
    end;
  end;
end;


{$IFDEF WS}
function IdxFound(idx: DWORD): Boolean;
var
  i: Integer;
  m: TMailerThread;
begin
  Result := False;
  for i := 0 to MailerThreads.Count-1 do
  begin
    m := MailerThreads[i];
    if m.DialupLine then Continue;
    if m.IpIdx = idx then
    begin
      Result := True;
      Exit;
    end;
  end;
end;
{$ENDIF}

function _LinkRestrictionMatches(C: TStringColl; s: string; Single: Boolean): Boolean;
var
  z: string;
  b: Boolean;
begin
  Result := True;
  repeat
    GetWrd(s, z, ' ');
    if z = '' then Break;
    b := C.Found(z);
    if b = Single then
    begin
      Result := False;
      Exit;
    end;
  until False;
end;

function LinkRestrictionMatches(const ConnectStr, Rqd, Frb: string): Boolean;
var
  us: string;
  C: TStringColl;
begin
  us := UpperCase(ConnectStr);
  Replace('/', ' ', us);
  C := TStringColl.Create;
  C.FillEnum(us, ' ', True);
  Result := _LinkRestrictionMatches(C, UpperCase(Rqd), False) and
            _LinkRestrictionMatches(C, UpperCase(Frb), True);
  FreeObject(C);
end;


function GetPortRec(LineId: DWORD): TPortRec;
var
  l: TLineRec;
begin
  CfgEnter;
  l := Pointer(Cfg.Lines.GetRecById(LineId));
  Result := Pointer(Cfg.Ports.GetRecById(l.d.PortId).Copy);
  CfgLeave;
end;

const
  IDet : array[Boolean] of DWORD = (0, DETACHED_PROCESS);


procedure _AddToExec(const s: string; ALogger: TAbstractLogger; PriorityClass: DWORD; Detached: Boolean; ShowMode: TExecShowMode);

function CmdPattern: string;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    Result := '%s /C "%s"';
  end else
  begin
    Result := '%s /C %s';
  end;
end;

function SDet: string;
const
  FShowMode : array[TExecShowMode] of string = ('Hidden', 'Minimised', 'Normal');
begin
  if Detached then Result := 'Detached' else Result := FShowMode[ShowMode];
end;

var
  Dir, ComSpec, es, ff, pclass: string;
  PDir: Pointer;
  PI: TProcessInformation;
  ProcNfo: TProcessNfo;
  ProcessColl: TColl;

begin    //                                command /C "dir & pause"
  case PriorityClass of
    REALTIME_PRIORITY_CLASS: pclass := 'Real-time';
    HIGH_PRIORITY_CLASS: pclass := 'High';
    NORMAL_PRIORITY_CLASS: pclass := 'Normal';
    IDLE_PRIORITY_CLASS: pclass := 'Low';
    else GlobalFail('_AddToExex PriorityClass=%d', [PriorityClass]);
  end;
  ProcessColl := ALogger.GetProcessColl;
  if ProcessColl.Count >= MaxProcesses then
  begin
    ALogger.LogFmt(ltGlobalErr, 'Too many processes are running - cannot execute "%s"', [s]);
    Exit;
  end;
  ComSpec := GetEnvVariable('COMSPEC');
  es := s;
  PDir := nil;
  GetWrd(es, ff, ' ');
  if MatchMask(ff, '*.exe') then
  begin
    Dir := ExtractFileDir(ff);
    ff := 'Executing program "%s" %s/%s (PID=%x)';
    if DirExists(Dir) = 1 then PDir := PChar(Dir);
    es := s
  end else
  begin
    ff := 'Executing command "%s" %s/%s (PID=%x)';
    es := Format(CmdPattern, [Comspec, s]);
  end;
  if not ExecProcess(es, PI, nil, Pdir, False, IDet[Detached] or PriorityClass or CREATE_SUSPENDED, ShowMode) then
  begin
    ALogger.ChkErrMsg;
  end else
  begin
    ALogger.LogFmt(ltInfo, ff, [s, SDet, pclass, PI.dwProcessId]);
    ProcNfo := TProcessNfo.Create;
    ProcNfo.PI := PI;
    ProcNfo.Name := s;
    ProcessColl.Insert(ProcNfo);
    ResumeThread(PI.hThread);
  end;
end;

function __CheckExecPrefixes(var s: string; var Priority: DWORD; var Detached: Boolean; var ShowMode: TExecShowMode): Boolean;

function cl: string;
begin
  Result := CopyLeft(s, 2);
end;

var
  C: DWORD;
begin
  Result := False;
  if s = '' then Exit;
  case s[1] of
    '?': if (ShowMode = swHide) and (not Detached) then
         begin
           ShowMode := swMinimize;
           Detached := True;
           s := cl;
           Result := __CheckExecPrefixes(s, Priority, Detached, ShowMode);
         end else
         begin
           Result := True;
         end;
    '<', '+', '*':
      begin
        case s[1] of
          '<': C := IDLE_PRIORITY_CLASS;
          '+': C := HIGH_PRIORITY_CLASS;
          '*': C := REALTIME_PRIORITY_CLASS;
          else begin GlobalFail('__CheckPrefixes("%s",...) s[1]="%s"', [s, s[1]]); Exit end;
        end;
        s := cl;
        Priority := C;
        Result := True;
      end;
    else
      Result := True;
  end;
end;

function CheckExecPrefixes(var s: string; var Priority: DWORD; var Detached: Boolean; var ShowMode: TExecShowMode; var SetFlag: Boolean): Boolean;

function cl: string;
begin
  Result := CopyLeft(s, 2);
end;

function cp: Boolean;
begin
  Result := __CheckExecPrefixes(s, Priority, Detached, ShowMode);
end;

begin
  Result := False;
  Detached := False;
  ShowMode := swMinimize;
  SetFlag := False;
  Priority := NORMAL_PRIORITY_CLASS;
  if s = '' then Exit;
  case s[1] of
    '>': begin Result := True; SetFlag := True; s := cl end;
    '?': begin ShowMode := swHide; s := cl; Result := cp end;
    '!': begin ShowMode := swShow; s := cl; Result := cp end;
    else Result := cp;
  end;
end;

function SetFileFlag(const s: string): Boolean;
var
  h: DWORD;
begin
  h := _CreateFile(s, [cEnsureNew]);
  Result := h <> INVALID_HANDLE_VALUE;
  if Result then Result := ZeroHandle(h);
end;

function AddToExec(const AStr: string; ALogger: TAbstractLogger): Boolean;
var
  Priority: DWORD;
  Detached, SetFlag: Boolean;
  ShowMode: TExecShowMode;
  ss: string;
begin
  ss := AStr;
  Result := CheckExecPrefixes(ss, Priority, Detached, ShowMode, SetFlag);
  if not Result then
  begin
    ALogger.LogFmt(ltGlobalErr, 'AttToExec(%s) failed', [AStr]);
    Exit;
  end;
  if SetFlag then
  begin
    ALogger.LogFmt(ltInfo, 'Setting file-flag %s', [ss]);
    if not SetFileFlag(ss) then
    begin
      SetErrorMsg(ss);
      ALogger.ChkErrMsg;
    end;
  end else
  begin
    _AddToExec(ss, ALogger, Priority, Detached, ShowMode);
  end;
end;


procedure PurgeZombies;
var
  i: Integer;
  pi: TProcessNfo;
  Code: DWORD;
begin
  Zombies.Enter;
  if (not TimerInstalled(LastZombiesPurged)) or (TimerExpired(LastZombiesPurged)) then
  begin
    NewTimerSecs(LastZombiesPurged, 120);
    for i := Zombies.Count-1 downto 0 do
    begin
      pi := Zombies[i];
      if not GetExitCodeProcess(pi.pi.hProcess, Code) then Code := 0;
      if Code = STILL_ACTIVE then Continue;
      ZeroHandle(pi.pi.hThread);
      ZeroHandle(pi.pi.hProcess);
      Zombies.AtFree(i);
    end;
  end;
  Zombies.Leave;
end;


function CreateTransferProtocol(Typ: TProtocolType; CP: TPort; Flags: TRemoteMailerFlags; var IsZModem: Boolean): TBaseProtocol;
var
  zmo: TZmodemOptionSet;
begin
  IsZModem := False;
  case Typ of
    piBinkP      : Result := CreateBinkPProtocol(CP);
    piFTS1       : Result := CreateFTS1Protocol(CP);
    piZmodem,
    piZmodem8K,
    piZmodem8KD:
      begin
        zmo := [];
//        if rmfForceZRQInit in Flags then Include(zmo, zmForceZRQInit);
        if (Typ = piZmodem8K) or (Typ = piZmodem8KD) then Include(zmo, zm8K);
        if Typ = piZmodem8KD then Include(zmo, zmDirect);
        IsZModem := True;
        Result := CreateZModemProtocol(CP, zmo);
      end;
    piHydra      : Result := CreateHydraProtocol(CP, []);
    else begin Result := nil; GlobalFail('%s', ['CreateTransferProtocol ??']) end;
  end;
  if Result = nil then Exit;
  Result.ID := Typ;
end;

function OpenSerialPort(R: TPortRec): TPort;
var
  P: TPort;

function OpenSerial: Boolean;
var
  H: DWORD;

function CreatePort(const AFormat: string): DWORD;
var
  Security: TSecurityAttributes;
begin
  with Security do
  begin
    nLength := SizeOf(TSecurityAttributes);
    lpSecurityDescriptor := nil;
    bInheritHandle := True;
  end;
  Result := _CreateFileSecurity(Format(AFormat, [R.d.Port+1]), [cRead, cWrite, cExisting, cShareAllowWrite, {cShareDenyRead,} cOverlapped], @Security);
end;

begin
  Result := False;
  H := CreatePort('\\.\COM%d');
  if H = INVALID_HANDLE_VALUE then H := CreatePort('COM%d');
  if H = INVALID_HANDLE_VALUE then Exit;
  with R.D do if not SetCommParams(H, Bps, Data, Parity, Stop, hFlow, sFlow) then Exit;
  P := TSerialPort.Create(H);
  P.DTE := R.D.BPS;
  P.PortIndex := R.D.Port;
  P.PortNumber := R.D.Port+1;
  Result := True;
end;

begin
  P := nil;
  if not OpenSerial then;
  Result := P;
end;




{function _FileRestrictionMatches(const FName: string; s: string; Single: Boolean): Boolean;
var
  z: string;
  b: Boolean;
begin
  Result := True;
  repeat
    GetWrd(s, z, ' ');
    if z = '' then Break;
    b := MatchMask(FName, z);
    if b = Single then
    begin
      Result := False;
      Exit;
    end;
  until False;
end;

function FileRestrictionMatches(const FName, Rqd, Frb: string): Boolean;
begin
  Result := _FileRestrictionMatches(FName, Rqd, False) and
            _FileRestrictionMatches(FName, Frb, True);
end;
}

function GetPasswordAux(const Addr: TFidoAddress): string;
begin
  EnterCS(AuxPwdsCS);
  if AuxPwds <> nil then Result := StrAsg(AuxPwds.Password(Addr)) else Result := '';
  LeaveCS(AuxPwdsCS);
end;

function GetPasswordGrid(const Addr: TFidoAddress): string;
begin
  CfgEnter;
  Result := StrAsg(Cfg.Passwords.Password(Addr));
  CfgLeave;
end;

function GetPasswordEvt(const Addr: TFidoAddress; EP: TMailerThreadEventProcessor): string;
var
  R: TColl;
  i, j: Integer;
  ds: TEvParDStr;
  A: TFidoAddrColl;
  AA: TFidoAddress;
begin
  Result := '';
  R := EP.GetAtomList(eiPassword);
  for i := 0 to CollMax(R) do
  begin
    ds := R[i];
    A := CreateAddrColl(ds.StrA);
    for j := 0 to CollMax(A) do
    begin
      AA := A[j];
      if CompareAddrs(Addr, AA) = 0 then
      begin
        Result := StrAsg(ds.StrB);
        Break;
      end;
    end;
    FreeObject(A);
    if Result <> '' then Break;
  end;
  FreeObject(R);
end;


function GetPassword(const Addr: TFidoAddress; EP: TMailerThreadEventProcessor): string;
begin
  Result := GetPasswordEvt(Addr, EP);
  if Result = '' then Result := GetPasswordAux(Addr);
  if Result = '' then Result := GetPasswordGrid(Addr);
end;

(*
function _AddrRestrictionMatches(C: TFidoAddrColl; const Addrs: string; Single: Boolean): Boolean;
var
  b: Boolean;
//  r: TFidoAddrColl;
  i, j: Integer;
  a: TFidoAddress;
  Found: Boolean;
begin
  Result := True;
  Found := False;
//  r := CreateAddrColl(Addrs);
//  if r = nil then Exit;
  for i := 0 to C.Count-1 do
  begin
    a := C[i];
    for j := 0 to r.Count-1 do
    begin
      b := CompareAddrs(a, r[j]) = 0;
      if b then Found := True;
      if b = Single then
      begin
        Result := False;
        if Single then Break;
      end;
    end;
  end;
  FreeObject(r);
  if not Single then Result := Result or Found;
end;
*)

function AddrRestrictionMatches(C: TFidoAddrColl; const Rqd, Frb: string): Boolean;
begin
  Result := False;
  if (Rqd <> '') and (not MatchMaskAddressListMultiple(C, Rqd)) then Exit;
  if (Frb <> '') and (    MatchMaskAddressListMultiple(C, Frb)) then Exit;
  Result := True;
end;



// --- fido polls


procedure RollPoll(var ActivePoll: TFidoPoll);
var
  an: TAdvNode;
begin
  EnterFidoPolls;
  FidoPolls.Delete(ActivePoll);
  if ActivePoll.Revalidate then
  begin
    ActivePoll.Revalidate := False;
    an := FindNode(ActivePoll.Node.Addr);
    if an = nil then
    begin
      ActivePoll.Done := pdnNodeDestroyed;
      FreeObject(ActivePoll);
    end else
    begin
      XChg(ActivePoll.Node, an);
      FreeObject(an);
      ActivePoll.Reset;
    end;
  end;
  if ActivePoll <> nil then
  begin
    FidoPolls.Insert(ActivePoll);
    ActivePoll.Release;
  end;
  LeaveFidoPolls;
end;

function GetOwnPolls: TColl;
var
  i: Integer;
  PP: TPollPtr;
begin
  Result := TColl.Create;
  EnterFidoPolls;
  for i := 0 to FidoPolls.Count-1 do
  begin
    PP := TPollPtr.Create;
    PP.Poll := FidoPolls[I];
    Result.Insert(PP);
  end;
  LeaveFidoPolls;
end;





procedure FreeOwnPoll(AOwnPolls: TColl; ap: TFidoPoll);
var
  j: Integer;
  p: TPollPtr;
begin
  for j := AOwnPolls.Count-1 downto 0 do
  begin
    p := AOwnPolls[j];
    if p.Poll = ap then AOwnPolls.AtFree(j);
  end;
end;

function OpenMailerThread;
var
  m: TMailerThread;

{$IFDEF WS}
procedure DoInsert;
var
  i: Integer;
  t: TMailerThread;
begin
  for i := 0 to MailerThreads.Count-1 do
  begin
    t := MailerThreads[i];
    if t.DialupLine then Continue;
    if m.IpIdx < t.IpIdx then
    begin
      MailerThreads.AtInsert(i, m);
      Exit;
    end;
  end;
  MailerThreads.Insert(m);
end;
{$ENDIF}


begin
  m := TMailerThread.Create;
  InitializeCriticalSection(m.CP_CS);
  m.TermTxData := TTermData.Create(Acw, Ach);
  m.TermRxData := TTermData.Create(Acw, Ach);
  m.CP := APort;
  if APort is TSerialPort then
  begin
    {$IFDEF WS}
    m.DialupLine := True;
    {$ENDIF}
  end;
  m.LineId := ALineId;
  {$IFDEF WS}
  if NI <> nil then
  begin
    m.IpPort := NI.IpPort;
    m.ProtCore := NI.Prot;
    m.CP.DTE := Cfg.IpData.Speed;
    m.CP.PortNumber := NI.IpPort;
    m.CP.PortIndex := NI.IpPort;
  end else
  {$ENDIF}
  begin
    m.ProtCore := ptDialup;
  end;
  m.SD := TMailerThreadInitData.Create;
  {$IFDEF WS}
  if (NI <> nil) and (NI.Poll <> nil) then
  begin
    NI.Poll.Owner := m;
    m.SD.ActivePoll := NI.Poll;
  end;
  FreeObject(NI);
  {$ENDIF WS}

  m.Initialize;
  m.DisplayData;

  EnterFidoPolls;
  MailerThreads.Enter;
  {$IFDEF WS} DoInsert {$ELSE} MailerThreads.Insert(m) {$ENDIF} ;
  {$IFDEF WS} if not m.DialupLine then m.OwnPolls := TColl.Create else {$ENDIF} m.OwnPolls := GetOwnPolls;
  MailerThreads.Leave;
  LeaveFidoPolls;

  m.Suspended := False;
  Result := m;
end;



// --- EventProcessor

destructor TAbstractEventProcessor.Destroy;
begin
  FreeIds;
  inherited Destroy;
end;


procedure TAbstractEventProcessor.FreeIds;
begin
  if EvtCnt > 0 then FreeMem(EvtIds, EvtCnt*SizeOf(Integer));
  EvtCnt := 0;
  EvtIds := nil;
end;


function TAbstractEventProcessor.GetAtomListEx(ATyp: Integer; Single: Boolean): Pointer;
var
  i,j,k: Integer;
  ol: TOlEventContainer;
  a: TEventAtom;
begin
  Result := nil;
  for k := 0 to EvtCnt-1 do
  begin
    i := FindNo(EvtIds^[k], EventsThr.Events);
    if i = -1 then Continue;
    ol := EventsThr.Events[i];
    if not ol.Active then Continue;
    for j := 0 to ol.Atoms.Count-1 do
    begin
      a := ol.Atoms[j];
      if a.Typ <> ATyp then Continue;
      if Single then
      begin
        Result := a;
        Exit;
      end;
      if Result = nil then Result := TColl.Create;
      TColl(Result).Add(a.Copy);
    end;
  end;
end;

function TAbstractEventProcessor.FindAtom(ATyp: Integer): Pointer;
begin
  Result := GetAtomListEx(ATyp, True);
end;

function TAbstractEventProcessor.GetAtomList(ATyp: Integer): Pointer;
begin
  Refill;
  EnterEvents;
  Result := GetAtomListEx(ATyp, False);
  LeaveEvents;
end;

(*
function TAbstractEventProcessor.GridValue(ATyp: Integer): TColl;
var
  a: TEvParGrid;
  sl: TStringColl;
  i: Integer;
begin
  Refill;
  EnterEvents;
  a := FindAtom(ATyp);
  if a = nil then Result := nil else
  begin
    Result := TColl.Create;
    for i := 0 to a.L.Count-1 do
    begin
      sl := a.L[i];
      Result.Add(sl.Copy);
    end;
  end;
  LeaveEvents;
end;
*)

function TAbstractEventProcessor.StrValue(ATyp: Integer): string;
var
  a: TEvParString;
begin
  Refill;
  EnterEvents;
  a := FindAtom(ATyp);
  if a = nil then Result := '' else Result := StrAsg(a.s);
  LeaveEvents;
end;

function TAbstractEventProcessor.VoidFound(ATyp: Integer): Boolean;
begin
  Refill;
  EnterEvents;
  Result := FindAtom(ATyp) <> nil;
  LeaveEvents;
end;

function TAbstractEventProcessor.BoolValueD(ATyp: Integer; ADefault: Boolean): Boolean;
var
  a: TEvParUV;
begin
  Refill;
  EnterEvents;
  a := FindAtom(ATyp);
  if a = nil then Result := ADefault else Result := a.d.BooleanData;
  LeaveEvents;
end;

function TAbstractEventProcessor.StrValueD(ATyp: Integer; const ADefault: string): string;
var
  a: TEvParString;
begin
  Refill;
  EnterEvents;
  a := FindAtom(ATyp);
  if a = nil then Result := ADefault else Result := a.s;
  LeaveEvents;
end;

function TAbstractEventProcessor.DwordValueD(ATyp: Integer; ADefault: DWORD): DWORD;
var
  a: TEvParUV;
begin
  Refill;
  EnterEvents;
  a := FindAtom(ATyp);
  if a = nil then Result := ADefault else Result := a.d.DwordData;
  LeaveEvents;
end;

procedure DoRefillEx(var EvtCnt: Integer; var EvtIds: PIntArray; AEvtCnt: Integer; AEvtIds: Pointer);
begin
  if AEvtCnt = 0 then Exit;
  EvtCnt := AEvtCnt;
  GetMem(EvtIds, AEvtCnt*SizeOf(Integer));
  Move(AEvtIds^, EvtIds^, AEvtCnt*SizeOf(Integer));
end;

procedure TAbstractEventProcessor.RefillEx;
begin
  DoRefillEx(EvtCnt, EvtIds, AEvtCnt, AEvtIds);
end;

procedure TMailerThreadEventProcessor.Refill;
var
  l: TLineRec;
  i: DWORD;
begin
  repeat
    i := GlobalEvtUpdateTick;
    if i = UpdateTick then Break;
    UpdateTick := i;
    FreeIds;
    CfgEnter;
    if LineId = 0 then RefillEx(Cfg.IpEvtIds.EvtCnt, Cfg.IpEvtIds.EvtIds) else
    begin
      l := Pointer(Cfg.Lines.GetRecById(LineId));
      if l.Id <> LineId then GlobalFail('%s', ['TMailerThreadEventProcessor.Refill']);
      RefillEx(l.EvtCnt, l.EvtIds);
    end;
    CfgLeave;
  until False;
end;

{$IFDEF WS}
constructor TDaemonEventProcessor.Create;
begin
  inherited Create;
  InitializeCriticalSection(CS);
end;

destructor TDaemonEventProcessor.Destroy;
begin
  DeleteCriticalSection(CS);
  inherited Destroy;
end;

procedure TDaemonEventProcessor.Refill;
var
  i: DWORD;
  ec: Integer;
  ei: PIntArray;
begin
  EnterCS(CS);
  repeat
    i := GlobalEvtUpdateTick;
    if i = UpdateTick then Break;
    UpdateTick := i;
    ec := 0;
    ei := nil;
    CfgEnter;
    DoRefillEx(ec, ei, Cfg.IpEvtIds.EvtCnt, Cfg.IpEvtIds.EvtIds);
    CfgLeave;
    EnterEvents;
    FreeIds;
    EvtCnt := ec;
    EvtIds := ei;
    LeaveEvents;
  until False;
  LeaveCS(CS);
end;
{$ENDIF}

// --- Loggers

procedure TAbstractLogger.TestRunningProcesses;
var
  i: Integer;
  ProcNfo: TProcessNfo;
  ProcessColl: TColl;
  Code: DWORD;
begin
  ProcessColl := GetProcessColl;
  for i := ProcessColl.Count-1 downto 0 do
  begin
    ProcNfo := ProcessColl[i];
    if not GetExitCodeProcess(ProcNfo.PI.hProcess, Code) then Code := 0;
    if Code = STILL_ACTIVE then Continue;
    LogTermination(ProcNfo.PI, True, ProcNfo.Name);
    Zombies.Enter;
    Zombies.Insert(ProcNfo);
    Zombies.Leave;
    ProcessColl.AtDelete(i);
  end;
end;

procedure TAbstractLogger.LeaveProcesses;
var
  i: Integer;
  ProcNfo: TProcessNfo;
  ProcessColl: TColl;
begin
  TestRunningProcesses;
  ProcessColl := GetProcessColl;
  Zombies.Enter;
  for i := 0 to ProcessColl.Count-1 do
  begin
    ProcNfo := ProcessColl[i];
    LogFmt(ltInfo, 'Process "%s" (PID=%x) is leaving in background', [ProcNfo.Name, ProcNfo.PI.dwProcessId]);
    Zombies.Insert(ProcNfo);
  end;
  Zombies.Leave;
  ProcessColl.DeleteAll;
end;


function TAbstractLogger.ChkErrMsg;
var
  S: string;
begin
  S := GetErrorMsg;
  Result := S <> '';
  if Result then Log(ltGlobalErr, S);
end;

procedure TAbstractLogger.LogTermination(PI: TProcessInformation; PostProcess: Boolean; const ProcessName: string);
var
  ExitCode: DWORD;
var
  lCreationTime, // when the process was created
  lExitTime,     // when the process exited
  lKernelTime,   // time the process has spent in kernel mode
  lUserTime:     // time the process has spent in user mode
      TFileTime;
  a, b, c: DWORD;
begin
  if not GetExitCodeProcess(PI.hProcess, ExitCode) then
  begin
    SetErrorMsg(Format('PID %x', [PI.dwProcessId]));
    Exit;
  end;

  if ExitCode = STILL_ACTIVE then
  begin
    LogFmt(ltGlobalErr, 'PID %x is still active', [PI.dwProcessId]);
    Exit;
  end;
    if (Win32Platform = VER_PLATFORM_WIN32_NT) and
       NTdyn_GetProcessTimes(PI.hProcess, lCreationTime, lExitTime, lKernelTime, lUserTime) then
    begin
      SubLong(lExitTime, lCreationTime);
      a := FileTimeToMsecs(lExitTime);
      b := FileTimeToMsecs(lUserTime);
      c := FileTimeToMsecs(lKernelTime);
      if PostProcess then
      begin
        LogFmt(ltInfo, '"%s" (PID=%x) exit code = %d. Times (run/user/kernel) = %s/%s/%s msec.',[ProcessName, PI.dwProcessId, ExitCode, Int2Str(a), Int2Str(b), Int2Str(c)]);
      end else
      begin
        LogFmt(ltInfo, 'Exit code = %d. Times (run/user/kernel) = %s/%s/%s msec.',[ExitCode, Int2Str(a), Int2Str(b), Int2Str(c)]);
      end;
    end else
    begin
      if PostProcess then
      begin
        LogFmt(ltInfo, '"%s" (PID=%x) exit code = %d',[ProcessName, PI.dwProcessId, ExitCode]);
      end else
      begin
        LogFmt(ltInfo, 'Exit code = %d', [ExitCode]);
      end;
    end;
end;



procedure TAbstractLogger.LogFmt(CurTag: TLogTag; const FmtStr: string; const Args: array of const);
begin
  Log(CurTag, Format(FmtStr, Args));
end;

procedure TMailerThreadLogger.Log(CurTag: TLogTag; const CurStr: string);
begin
  MailerThread.LastLogStr := MailerThread.LastLogStr + FormatLogStr(CurTag, CurStr, MailerThread.Name) + #13#10;
end;

function TMailerThreadLogger.GetProcessColl: Pointer;
begin
  Result := MailerThread.ProcessColl;
end;

procedure TCronThreadLogger.Log(CurTag: TLogTag; const CurStr: string);
begin
  if _LogOK(CronThr.ProcsLogFName, CronThr.ProcsLogFHandle) then _LogWriteStr(FormatLogStr(CurTag, CurStr, 'Cron'), CronThr.ProcsLogFHandle);
end;

function TCronThreadLogger.GetProcessColl: Pointer;
begin
  Result := CronThr.ProcessColl;
end;

{$IFDEF WS}

constructor TDaemonThreadLogger.Create;
begin
  inherited Create;
  InitializeCriticalSection(LogCS);
end;

destructor TDaemonThreadLogger.Destroy;
begin
  DeleteCriticalSection(LogCS);
  inherited Destroy;
end;


procedure TDaemonThreadLogger.Log(CurTag: TLogTag; const CurStr: string);
begin
  EnterCS(LogCS);
  IpPolls.LogContainer.Log(FormatLogStr(CurTag, CurStr, 'Daemon'));
  LeaveCS(LogCS);
end;

function TDaemonThreadLogger.GetProcessColl: Pointer;
begin
  GlobalFail('%s', ['TDaemonThreadLogger.GetProcessColl']); Result := nil;
end;

{$ENDIF}

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                           Command Events                           //
//                                                                    //
////////////////////////////////////////////////////////////////////////

procedure TMlrEvtNop.Execute(T: TMailerThread);
begin
  T.Log(ltInfo, T.GetThrErrorMsg);
  {no operation}
end;

procedure TMlrEvtSkip.Execute(T: TMailerThread);
begin
  T.SD.FileSkip := True;
  T.D.SkipIs := True;
  T.Log(ltInfo, 'Skipping');
end;

procedure TMlrEvtRefuse.Execute(T: TMailerThread);
begin
  T.SD.FileRefuse := True;
  T.D.SkipIs := True;
  T.Log(ltInfo, 'Rejecting');
end;

procedure TMlrEvtAnswer.Execute(T: TMailerThread);
begin
  T.SD.AnswerRequest := True;
end;

procedure TMlrEvtClearTmrPublic.Execute(T: TMailerThread);
begin
  NewTimer(T.D.TmrPublic, 0);
  T.DisplayData;
end;

procedure TMlrEvtIncTmrPublic.Execute(T: TMailerThread);
begin
  NewTimerSecs(T.D.TmrPublic, MinD(999, RemainingTimeSecs(T.D.TmrPublic)+30));
  NewTimerSecs(T.SD.TmrReinit, RemainingTimeSecs(T.D.TmrPublic)+5);
  T.DisplayData;
end;

procedure TMlrEvtOperatorTerminate.Execute(T: TMailerThread);
begin
  T.InsertEvt(TMlrEvtChStatus.Create(msCancel));
  T.Log(ltGlobalErr, 'Closed by system operator');
  T.SelfTerminate := True;
end;

procedure TMlrEvtFlagTerminate.Execute(T: TMailerThread);
begin
  T.InsertEvt(TMlrEvtChStatus.Create(msCancel));
  T.Log(ltGlobalErr, 'Closed by file-flag');
  T.SelfTerminate := True;
end;


procedure TMlrEvtShutdownTerminate.Execute(T: TMailerThread);
begin
  T.InsertEvt(TMlrEvtChStatus.Create(msCancel));
  T.Log(ltGlobalErr, 'Closed by Argus shutdown');
  T.SelfTerminate := True;
end;

procedure TMlrEvtPollsRecalc.Execute(T: TMailerThread);
begin
  if T.State = msIdle then
  begin
    T.State := msCheckOut;
    ClearTimer(T.TmrNextDial);
    ClearTimer(T.D.TmrPublic);
  end;
end;

constructor TMlrEvtChStatus.Create(AStatus: TMailerState);
begin
  inherited Create;
  FStatus := AStatus;
end;

procedure TMlrEvtChStatus.Execute(T: TMailerThread);
begin
  if T.SD.Prot <> nil then T.SD.Prot.CancelRequested := True else T.State := FStatus;
end;


constructor TMlrEvtEnterMdmCmds.Create(AWndHandle: DWORD);
begin
  inherited Create;
  FWndHandle := AWndHandle;
end;

procedure TMlrEvtEnterMdmCmds.Execute(T: TMailerThread);
begin
  if (not AllowedMdmCmdState(T.State)) or (T.CP = nil) then Exit;
  T.State := msModemCmdIdle;
  PostMessage(FWndHandle, WM_STARTMDMCMD, 0, Integer(T));
  T.ClearTmr1;
  T.ClearTmrPublic;
  T.SetStatusMsg(rs_s, 'Command Mode');
end;

constructor TMlrEvtSendMdmCmd.Create(const AString: string);
begin
  inherited Create;
  FString := StrAsg(AString); 
end;

procedure TMlrEvtSendMdmCmd.Execute(T: TMailerThread);
begin
  T.SendModemString(StrAsg(FString));
end;

constructor TMlrEvtLogAndExtApp.Create(const AExtApp, ALogStr: string);
begin
  inherited Create;
  FExtApp := StrAsg(AExtApp);
  FLogStr := StrAsg(ALogStr);
end;

procedure TMlrEvtLogAndExtApp.Execute(T: TMailerThread);
begin
  case T.State of
    __FirstExtApp..__LastExtApp : Exit;
  end;
  T.SD.ExtAppStr := StrAsg(FExtApp);
  T.State := msExtApp_0;
  T.Log(ltInfo, StrAsg(FLogStr));
end;

constructor TMlrEvtLogAndCancel.Create(const ALogStr: string);
begin
  inherited Create;
  FLogStr := StrAsg(ALogStr);
end;

procedure TMlrEvtLogAndCancel.Execute(T: TMailerThread);
begin
  T.InsertEvt(TMlrEvtChStatus.Create(msCancel));
  T.Log(ltInfo, FLogStr);
end;



// --- TFidoPoll

constructor TFidoPoll.Create;
begin
  inherited Create;
  Birth := uGetSystemTime;
end;

function TFidoPoll.CountersExceeded: Boolean;
begin
  Result := ((TryBusy >= FidoPolls.Options.d.Busy) or
             (TryNoConnect >= FidoPolls.Options.d.NoC) or
             (TrySessionAborted >= FidoPolls.Options.d.Fail));
end;

function TFidoPoll.STryNoC: string;
begin
  if Typ = ptpManual then Result := Format('%d+', [TryNoConnect]) else
  begin
    EnterFidoPolls;
    Result := Format('%d/%d', [TryNoConnect, FidoPolls.Options.d.NoC]);
    LeaveFidoPolls;
  end;
end;

function TFidoPoll.STryBusy: string;
begin
  if Typ = ptpManual then Result := Format('%d+', [TryBusy]) else
  begin
    EnterFidoPolls;
    Result := Format('%d/%d', [TryBusy, FidoPolls.Options.d.Busy]);
    LeaveFidoPolls;
  end;
end;

function TFidoPoll.STryFail: string;
begin
  if Typ = ptpManual then Result := Format('%d+', [TrySessionAborted]) else
  begin
    EnterFidoPolls;
    Result := Format('%d/%d', [TrySessionAborted, FidoPolls.Options.d.Fail]);
    LeaveFidoPolls;
  end;
end;


procedure TFidoPoll.Reset;
begin
  FileSendDelayed := False;
  if (Owner = nil) or (Owner = PollOwnerExtApp) then ClearTimer(LastTry);
  TryBusy := 0;
  TryNoConnect := 0;
  TrySessionAborted := 0;
end;

procedure TFidoPoll.IncNoConnectTries;
begin
  Inc(TryNoConnect);
  FidoPollsLog(Format('%s - no connect [%s]', [Addr2Str(Node.Addr), STryNoC]));
end;


function TFidoPoll.ExtSleepMSecs: DWORD;
var
  s, z: string;
  i: DWORD;
begin
  s := Node.Ext.Opts;
  for i := 0 to 3 do GetWrd(s, z, ' ');
  Result := PollSleepMSecs(s);
end;

function TFidoPoll.ExtTimeoutExitCode: DWORD;
var
  s, z: string;
  i: Integer;
begin
  s := Node.Ext.Opts;
  for i := 0 to 4 do GetWrd(s, z, ' ');
  Result := PollTimeoutExitCode(s);
end;


procedure TFidoPoll.IncAbortedTries;
begin
  Inc(TrySessionAborted);
  FidoPollsLog(Format('%s - session aborted [%s]', [Addr2Str(Node.Addr), STryFail]));
end;


procedure TFidoPoll.IncBusyTries(const AReason: string);
begin
  Inc(TryBusy);
  FidoPollsLog(Format('%s - %s [%s]', [Addr2Str(Node.Addr), AReason, STryBusy]));
end;


function TFidoPoll.DialupPhone: string;
begin
  Result := PatchPhoneNumber(TAdvNodeData(Node.DialupData[DataIdx]).Phone, True);
end;

function TFidoPoll._Flags(Coll: TColl): string;
begin
  Result := TAdvNodeData(Coll[DataIdx]).Flags;
end;

function TFidoPoll.Flags(Dialup: Boolean): string;
begin
  if Dialup then Result := DialupFlags else Result := IpFlags;
end;

function TFidoPoll.DialupFlags: string;
begin
  Result := _Flags(Node.DialupData);
end;

function TFidoPoll.IPAddr: string;
begin
  Result := TAdvNodeData(Node.IPData[DataIdx]).IpAddr;
end;

function TFidoPoll.IPFlags: string;
begin
  Result := _Flags(Node.IPData);
end;

destructor TFidoPoll.Destroy;
var
  i: Integer;
const
  Msg: array[TPollDone] of string = ('???', 'SysShutDown', 'OK', 'Deleted', 'Deleted(all)', 'AttachLost', 'Node destroyed');

begin
  FidoPollsLog(Format('-Poll/%s  %s', [Msg[Done], Addr2Str(Node.Addr)]));
  MailerThreads.Enter;
  for i := 0 to MailerThreads.Count-1 do FreeOwnPoll(TMailerThread(MailerThreads[I]).OwnPolls, Self);
  {$IFDEF WS}
  if IPPolls <> nil then FreeOwnPoll(IPPolls.OwnPolls, Self);
  {$ENDIF}
  MailerThreads.Leave;
  Release;
  FreeObject(Node);
  inherited Destroy;
end;

procedure TFidoPoll.Release;
begin                                          
  if (Owner = nil) or (Owner = PollOwnerExtApp) then Exit;
  FidoOut.UnLock(Node.Addr);
  Owner := nil;
end;

// --- TMailerThreadInitData

destructor TMailerThreadInitData.Destroy;
var
  i: Integer;
begin
  if (ActivePoll <> nil) then
  begin
    EnterFidoPolls;
    ActivePoll.Release;
    LeaveFidoPolls;
    ActivePoll := nil;
  end;

  for i := 0 to CollMax(rmtAddrs) do FidoOut.Unlock(rmtAddrs[I]);
  FreeObject(rmtAddrs);

  FreeObject(PostEMSILogErrors);
  FreeObject(YooHooPkt);
  FreeObject(AkaA);
  FreeObject(AkaB);
  FreeObject(Station);
  FreeObject(OutFiles);
  FreeObject(SentFiles);
  FreeObject(DisabledFiles);
  FreeObject(LoggedStrs);
  FreeObject(EMSI_Addons);
  FreeObject(ReqLines);
  FreeObject(Prot);
  FreeObject(ModemRec);
  FreeObject(HReqDelete);
  FreeObject(RcvdNames);
  FreeObject(LoginScript);
  FreeObject(RespFmtREs);
  FreeObject(InputFmtREs);
  FreeObject(InputWdResetREs);
  FreeObject(InputWdExtAppREs);
  FreeObject(LoginWdREs);

  if Faxmodem <> nil then GlobalFail('%s', ['Faxmodem is not freed']);
  ZeroHandle(ExtAppProcessNfo.hThread);
  ZeroHandle(ExtAppProcessNfo.hProcess);

end;

// --- TMailerThread

class function TMailerThread.ThreadName: string;
begin
  Result := 'Mailer';
end;

function TMailerThread.EMSI_CR: string;
begin
  Result := sEMSI_CR;
end;


function TMailerThread.__EMSI_REQ: string;

function cREQ: string;
begin
  if SD.MayEMSI then Result := EMSI_REQ + EMSI_CR + EMSI_REQ + EMSI_CR else Result := '';
end;

begin
  if SD.NiagaraAllowed then
  begin
    Result := cREQ + EMSI_PZT + EMSI_CR;
  end else
  begin
    Result := cREQ;
  end;
end;

procedure TMailerThread.LogHandshakeStart;
begin
  LogEMSIData;
  if SD.HandshakeTimeLogged then Exit;
  SD.HandshakeTimeLogged := True;
  LogFmt(ltInfo, 'Handshake time - %d seconds', [SD.SessionStart - SD.ConnectStart]);
end;

procedure TMailerThread.SetSessionKey(const A: TFidoAddress);
var
  en: TEncryptedNodeData;
  i: Integer;
begin
  SD.SessionKeyAddr := A;
  CfgEnter;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    en := Cfg.EncryptedNodes[i];
    if CompareAddrs(A, en.Addr) = 0 then
    begin
      SD.SessionKey := en.Key;
      Break;
    end;
  end;
  CfgLeave;
end;

procedure TMailerThread.LogPostEMSIErr(const Msg: string);
begin
  if SD.EMSI_Logged then
  begin
    Log(ltGlobalErr, Msg);
  end else
  begin
    if SD.PostEMSILogErrors = nil then SD.PostEMSILogErrors := TStringColl.Create;
    SD.PostEMSILogErrors.Add(Msg);
  end;
end;


procedure TMailerThread.GetAddrs(const S: string);


procedure GetPrimaryAddr;
begin
  if SD.rmtAddrs <> nil then
  begin
    if SD.ActivePoll <> nil then
    begin
      SD.rmtPrimaryAddr := SD.ActivePoll.Node.Addr;
    end else
    begin
      SD.rmtPrimaryAddr := SD.rmtAddrs[0];
    end;
    SD.rmtPrimaryAddrSet := True;
    DS.rmtAddressList := SD.rmtAddrs.GetString;
  end;
end;


var
  InvAddrs: TStringColl;
  i: Integer;
begin
  FreeObject(SD.rmtAddrs);
  InvAddrs := TStringColl.Create;
  SD.rmtAddrs := CreateAddrCollInvAddrs(S, InvAddrs);
  for i := 0 to InvAddrs.Count-1 do
  begin
    if i = 0 then
    begin
      LogPostEMSIErr(Format('Remote presented the following list that has invalid address(es): "%s"', [s]));
    end;
    LogPostEMSIErr(Format('Invalid (unparsed) address "%s" - removed from AKA list', [InvAddrs[i]]));
  end;
  FreeObject(InvAddrs);
  if (SD.ActivePoll = nil) and (SD.rmtAddrs <> nil) then
  begin
    if not AddrRestrictionMatches(SD.rmtAddrs, Trim(EP.StrValue(eiAccNodesRqd)), Trim(EP.StrValue(eiAccNodesFrb))) then
    begin
      GetPrimaryAddr;
      LogEMSIData;
      Log(ltGlobalErr, 'Address restriction applied');
      FreeObject(SD.rmtAddrs);
      Exit;
    end;
  end;
  GetPrimaryAddr;
end;

function TMailerThread.HangupModem: Boolean;
begin
  Result := True;
  if SD.SkipHangup then SD.SkipHangup := False else
  begin
    {$IFDEF WS}
    if not DialupLine then
    begin
      Sleep(500); // wait to drain out
      FreeCP
    end else
    {$ENDIF}
    begin
      Sleep(200); // wait to drain out
      DoRemoveNiagara;
      UpdateModem;
      Result := SendModemString(EP.StrValueD(eiModemCmdHangup, SD.ModemRec.Cmds.Hangup));
      SD.WasHangup := True;
      TDevicePort(CP).Purge([RX]);
    end;
  end;
end;

procedure TMailerThread.SendStr(const S: string);
begin
  CP.SendString(S);
  PostTermStr(S, True, False, False);
end;

function TMailerThread.LockAddr(const Addr: TFidoAddress): Boolean;
begin
  Result := FidoOut.Lock(Addr);
  if not Result then ChkErrMsg;
end;

function TMailerThread.ChkErrMsg: Boolean;
begin
  Result := Logger.ChkErrMsg;
end;

procedure TMailerThread.LogPoll(const S: string);
begin
  FidoPolls.Log.Log(FormatLogStr(ltPolls, S, Name));
end;

{$IFDEF WS}
procedure TMailerThread.LogDaemon(const S: string);
begin
  IpPolls.Logger.Log(ltInfo, S);
end;
{$ENDIF}

procedure TMailerThread.SetStatusMsg(Id: DWORD; const Param: string);
begin
  D.StatusMsg := Id;
  DS.StatusParam := Param;
  DisplayData;
end;

procedure TMailerThread.DoInvokeExec;

begin
  PrevState := OldState;
  OldState := State;
  case State of
    __FirstMisc   .. __LastMisc    : DoMisc;
    __FirstHSh    .. __LastHSh     : DoHSh;
    __FirstEMSI   .. __LastEMSI    : DoEMSI;
    __FirstWZ     .. __LastWZ      : DoWZ;
    __FirstExtApp .. __LastExtApp  : DoExtApp;
    __FirstCN     .. __LastCN      : DoConnect;
    __FirstFax    .. __LastFax     : DoFax;
    else GlobalFail('%s', ['TMailerThread.ThreadExec unknown state']);
  end;
  if Terminated then Exit;
  if CP <> nil then CP.Flsh;
  FlushLog;
  DoDisplayData;
  LetsSleep;
end;

procedure TMailerThread.InvokeExec;
begin
  try
    DoInvokeExec;
  except
    on E: Exception do
    begin
      Log(ltGlobalErr, '************* v'+ProductVersion+' '+GetThrErrorMsg + ' "' + E.Message+'"');
      FlushLog;
      ZeroHandle(LogFHandle);
      ProcessTrap(GetThrErrorMsg + ' ' + E.Message, ClassName);
    end;
  end;
end;

procedure TMailerThread.InvokeDone;
begin
  Logger.LeaveProcesses;
  Log(ltInfo, 'End');
  FlushLog;
  FreeCP;
  PostMsgP(WM_CLOSELINE, Self);
end;

function TMailerThread.SendModemString(const AStr: string): boolean;

  procedure Dly(a: Integer);
  var
    i: Integer;
  begin
    CP.Flsh;
    for i := 1 to a do
    begin
      Sleep(100);
      DoAccumulate;
    end;
  end;

  procedure PutC(AC: Char); begin CP.PutChar(Byte(AC)); PostTermStr(AC, True, True, False) end;
  procedure PutS(AC: Char); begin PostTermStr(AC, True, True, True) end;

var
  CC: Char;
  I, SL: Integer;
  DT: EventTimer;
  ToSleep: DWORD;
begin
  DoAccumulate;
  SD.InB := '';
  SD.LastSentString := AStr;
  Result := False;
  SL := Length(AStr);
  if SL > 0 then
  begin
    I := 1;
    while I <= SL do
    begin
      DoAccumulate;
      CC := AStr[I];
      case CC of
        '`', '~', '^', 'v':
          begin
            PutS(CC);
            case CC of
              '`' : Dly(1);       // 0.1 Second Delay
              '~' : Dly(5);       // 0.5 Second Delay
              '^' : begin CP.Flsh; TSerialPort(CP).DTR := True end;
              'v' : begin CP.Flsh; TSerialPort(CP).DTR := False end;
            end;
          end;
        '!':
          begin
            PutS(CC);
            PutC(ccCR);
          end;
        '\' :
          if I<SL then begin Inc(I); PutC(AStr[I]) end;
        '|' : begin
                CP.Flsh;
                DoAccumulate;
                SD.InB := '';
                PutS(CC);
                PutC(ccCR);
                CP.Flsh;
                NewTimerSecs(DT, 3);
                repeat
                  ToSleep := RemainingTimeMsecs(DT);
                  if ToSleep = 0 then
                  begin
                    Result := False;
                    Exit;
                  end;
                  DoAccumulate;
                  case ModemResponse of
                    mrpOK: Break;
                    mrpRing: Log(ltWarning, SD.LastResponse);
                    mrpNone: Sleep(100);
                    else
                    begin
                      Log(ltWarning, SD.LastResponse);
                      Exit;
                    end;
                  end;
                  WaitEvt(CP.oDataAvail, ToSleep);
                until False;
              end;
        else PutC(CC);
      end;
      Inc(I);
    end;
    CP.Flsh;
  end;
  Result := True;
end;

procedure TMailerThread.LogBinkPNul(const S: string);
var
  A: string;

procedure DoTrf;
begin
  LogEMSIData;
  GetTraf(A, False);
  LogTrafInfo;
end;

procedure ChkSoft;
var
  s, z: string;
begin
  s := a;
  GetWrd(s, z, ' ');
  s := z;
  GetWrd(s, z, '/');
  if z <> CProductName then Exit;
  while s <> '' do GetWrd(s, z, '/');
  s := z;
  GetWrd(s, z, '#');
  GetWrd(s, z, '#');
  SD.rmtMailerSerialNo := z;
end;

var
  B: string;
begin
  A := S;
  GetWrd(A, B, ' ');
  B := UpperCase(B);
  Replace('_', ' ', A);
  with DS do
  if B = '|' then else
  if B = 'SYS'  then rmtStationName := A else
  if B = 'ZYZ'  then rmtSysOpName := A else
  if B = 'LOC'  then rmtLocation := A else
  if B = 'PHN'  then rmtPhone := A else
  if B = 'NDL'  then rmtFlags := A else
  if B = 'VER'  then begin rmtSoft := A; ChkSoft end else
  if B = 'TIME' then SD.rmtTime := A else
  if B = 'FREQ' then SD.DelayEOB := True else
  if B = 'TRF'  then DoTRF else
  if B = 'ARGUS/REG' then LogFmt(ltInfo, '%s : %s', [AddLeftSpaces(B, 10), A]) else
    LogFmt(ltInfo, '%s : %s', [AddLeftSpaces('M_NUL', 10), S])
end;

function TMailerThread.ChkNonEmsiPwd(P: TBaseProtocol): Boolean;
var
  AkasLocked: Boolean;
begin
  Result := True;
  LogEMSIData;
  SD.BadPassword := not ValidEncryptedAKAs;
  SD.BadPassword := SD.BadPassword or (not CheckPasswords);
  AkasLocked := LockAKAs;
  if not AkasLocked then
  begin
    P.CustomInfo := #4;
  end else
  begin
    if P <> nil then
    begin
      if SD.BadPassword then P.CustomInfo := cBadPwd else P.CustomInfo := '';
    end;
  end;
  Result := AkasLocked and (not SD.BadPassword);
end;

function TMailerThread.ValidEncryptedAKAs: Boolean;
var
  i, j: Integer;
  ra: TFidoAddrColl;
  pa: PFidoAddress;
  a: TFidoAddress;
  e: TEncryptedNodeData;
begin
  Result := True;
  ra := TFidoAddrColl.Create;
  for i := 0 to CollMax(SD.rmtAddrs) do
  begin
    a := SD.rmtAddrs[i];
    if CompareAddrs(a, SD.SessionKeyAddr) = 0 then Continue;
    New(pa);
    pa^ := a;
    ra.Insert(pa);
  end;
  CfgEnter;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    e := Cfg.EncryptedNodes[i];
    a := e.Addr;
    if ra.Search(@a, j) then
    begin
      Result := False;
      Break;
    end;
  end;
  CfgLeave;
  FreeObject(ra);
  if not Result then LogFmt(ltGlobalErr, 'Unauthorized AKA %s', [Addr2Str(a)]);
end;

function TMailerThread.ChkAddrStr(const S: string): Boolean;
begin
  GetAddrs(S);
  Result := not (NoAnyValidAddrs or ((SD.ActivePoll <> nil) and not ValidConnection));
end;

function TMailerThread.ChkBinkPAdr(const S: string; P: TBaseProtocol): Boolean;
begin
  Result := ChkAddrStr(S);
  if not Result then
  begin
    P.CustomInfo := #1; // no any valid addressed
    Exit;
  end;
  if SD.ActivePoll <> nil then
  begin
    LogEMSIData;
    if not ValidEncryptedAKAs then Result := False else
    begin
      SD.rmtPassword := GetPassword(SD.ActivePoll.Node.Addr, EP);
      Result := CheckPasswords;
      SD.BadPassword := not Result;
      if not Result then P.CustomInfo := #3;
    end;
    if not LockAKAs then
    begin
      P.CustomInfo := #4;
      Result := False;
    end;
  end;
end;

function TMailerThread.GetBinkPPwd(A: TFidoAddress): string;
var
  Files: TOutFileColl;
begin
  Result := GetPassword(A, EP);
  Files := FidoOut.GetOutbound(A, [osRequest], nil, nil, nil, False);
  ChkErrMsg;
  if Result = '' then Result := '-';
  Result := Chr(Ord(' ')+Ord(Files <> nil)) + Result;
  FreeObject(Files);
end;

function TMailerThread.SetBinkPCanEOB: Char;
begin
  if not SD.DelayEOB then Result := 'b' else
  begin
    if not SD.FreqProcessed then Result := 'a' else
    begin
      SD.DelayEOB := False;
      Result := 'c'
    end;
  end;
end;

procedure TMailerThread.LogFile(P: TBaseProtocol; AStatus: TLogFileStatus);

const
  cNULL = '*NULL*';

function RFPos: string;
begin
  if P.R = nil then Result := cNULL else Result := Int2Str(P.R.D.FPos);
end;

function TFPos: string;
begin
  if P.T = nil then Result := cNULL else Result := Int2Str(P.T.D.FPos);
end;

function RBlkLen: string;
begin
  if P.R = nil then Result := cNULL else Result := IntToStr(P.R.D.BlkLen);
end;

function TBlkLen: string;
begin
  if P.T = nil then Result := cNULL else Result := IntToStr(P.T.D.BlkLen);
end;

procedure LogBinkPBadKey;
var
  his, ours, s, z: string;
begin
  s := P.CustomInfo;
  GetWrd(s, z, ' ');
  his := z;
  GetWrd(s, z, ' ');
  ours := z;
  LogEMSIData; LogFmt(ltWarning, 'Invalid remote encryption key checksum (his: %s, ours: %s)', [his, ours]);
end;

procedure BinkPGetKey;
begin
  SetLength(P.CustomInfo, 8); Move(SD.SessionKey, P.CustomInfo[1], 8);
end;

procedure BinkPGetInKey;
var
  i,j: Integer;
  EncNodes: TEncryptedNodeColl;
  EncNode: TEncryptedNodeData;
  a: TFidoAddress;
begin
  CfgEnter;
  EncNodes := Cfg.EncryptedNodes.Copy;
  CfgLeave;
  EncNodes.Sort(EncNodeSort);
  for i := 0 to CollMax(SD.rmtAddrs) do
  begin
    a := SD.rmtAddrs[i];
    if EncNodes.Search(@a, j) then
    begin
      EncNode := EncNodes[j];
      SD.SessionKey := EncNode.Key;
      SD.SessionKeyAddr := EncNode.Addr;
      Break;
    end;
  end;
  FreeObject(EncNodes);
end;

procedure CheckBinkPpwd;
var
  OurDig, OurPwd, Uniq: string;
  i: Integer;
const
  cCRAM = 'CRAM-MD5-';
begin
  GetWrd(P.CustomInfo, Uniq, ' ');
  if StrBegsU(cCRAM, P.CustomInfo) then
  begin
    Delete(P.CustomInfo, 1, Length(cCRAM));
    if not SD.rmtPrimaryAddrSet then begin P.CustomInfo := cBadPwd; Exit end;
    OurPwd := GetBinkPPwd(SD.rmtPrimaryAddr);
    DelFC(OurPwd);

    for i := 0 to 15 do Uniq[i+1] := Char(VlH(Copy(Uniq, i*2+1, 2)));

    OurDig := KeyedMD5(OurPwd[1], Length(OurPwd), Uniq[1], 16);
    SD.CramMD5 := True;
    if UpperCase(OurDig) <> UpperCase(P.CustomInfo) then
    begin
      LogEMSIData;
      LogFmt(ltGlobalErr, 'Remote presented invalid password (auth=CRAM-MD5) when "%s" is required for %s', [OurPwd, Addr2Str(SD.rmtPrimaryAddr)]);
      P.CustomInfo := cBadPwd;
      Exit;
    end;
    P.CustomInfo := OurPwd;
  end;
  if P.CustomInfo = '-' then SD.rmtPassword := '' else SD.rmtPassword := P.CustomInfo;
  ChkNonEmsiPwd(P);
end;

begin
  case AStatus of
          lfNAK:    Log(ltFileErr, 'NAK received');
       lfBadHdr:    Log(ltFileErr, 'Invalid block header');
      lfTimeout:    Log(ltFileErr, 'Protocol time-out');
       lfBadPkt: LogFmt(ltFileErr, 'Bad packet at %s (newblklen=%s)', [RFPos, RBlkLen]);
       lfBadEOF: LogFmt(ltFileErr, 'Bad EOF at %s', [RFPos]);
       lfBadCRC:    Log(ltFileErr, 'Block CRC error');
     lfSendSync: LogFmt(ltInfo,    'Transmitting from offset %s', [TFPos]);
     lfSendSeek: LogFmt(ltFileErr, 'Resending from offset %s (newblklen=%s)', [TFPos, TBlkLen]);
  lfBatchesDone: LogFmt(ltInfo,    '%s transfer protocol complete', [P.Name]);
 lfBatchSendEnd:  begin
                    P.T.D.State := bsEnd;
                    LogHandshakeStart;
                    Log(ltInfo,    'SEND: End of batch');
                  end;
 lfBatchReceEnd:  begin
                    P.R.D.State := bsEnd;
                    LogHandshakeStart;
                    Log(ltInfo,    'RECE: End of batch');
                  end;
         lf1Prog: begin
                    SD.rmtMailerName := P.CustomInfo;
                    DS.rmtSoft := P.CustomInfo;
                    DisplayData;
                  end;
        lf1Addr:  begin
                    SD.FTS1NeedRmtAddr := False;
                    if ChkAddrStr(P.CustomInfo) then P.CustomInfo := '' else P.CustomInfo := #1; // no any valid addressed
                  end;
         lf1Pwd:  begin
                    SD.rmtPassword := P.CustomInfo;
                    ChkNonEmsiPwd(P);
                  end;
       lf1PCode:  begin
                    SD.rmtMailerCode := P.CustomInfo;
                  end;
     lfHydraNfo:  Log(ltHydraNfo, P.CustomInfo);
        lfDebug:  Log(ltDebug, P.CustomInfo);
    lfBinkPNiaE:  Log(ltWarning, P.CustomInfo);
    lfBinkPCRAM:  SD.CramMD5 := True;
  lfBinkPBadKey:  LogBinkPBadKey;
 lfBinkPgOutKey:  BinkPGetKey;
  lfBinkPgInKey:  begin BinkPGetInKey; BinkPGetKey end;
     lfBinkPNul:  LogBinkPNul(P.CustomInfo);
     lfBinkPErr:  begin LogEMSIData; Log(ltWarning, 'Err: '+P.CustomInfo) end;
   lfBinkPUnrec:  Log(ltWarning, 'Unrec: '+P.CustomInfo);
   lfBinkPgAddr:  begin
                    if SD.ActivePoll <> nil then SD.OutAddrs := GetOutAKAs(SD.ActivePoll.Node.Addr) else SD.OutAddrs := GetInAKAs;
                    P.CustomInfo := SD.OutAddrs;
                  end;
     lfBinkPgPwd: P.CustomInfo := GetBinkPPwd(SD.ActivePoll.Node.Addr);
      lfBinkPPwd: CheckBinkPpwd;
     lfBinkPAddr: if ChkBinkPAdr(Trim(P.CustomInfo), P) then P.CustomInfo := '';
   lfBinkPCanEOB: P.CustomInfo := SetBinkPCanEOB;
     else
     GlobalFail('%s', ['TMailerThread.LogFile']);
  end;
end;

procedure TMailerThread.ScanOut;
  var II, I, J, K, L, M, N, P: Integer;
      ok: Boolean;
      PI: PInteger;
      A: array [1..10] of TOutStatus;
      TransmitHold: Boolean;
      TransmitRequired,
      TransmitForbidden: TStringColl;
      S: TOutStatus;
      tof: TOutFile;
      RqdMatched, FrbMatched: Boolean;
      sss,
      STrsFilesRqd,
      STrsFilesFrb: string;

  procedure Add(S: TOutStatus);
  begin
    Inc(N);
    A[N] := S;
  end;

  procedure AddFreq;
  begin
    Add(osRequest);
  end;

begin
  N := 0;
  TransmitHold := SD.ActivePoll = nil;
  if not TransmitHold then
  begin
    EnterFidoPolls;
    TransmitHold := pofHold in FidoPolls.Options.d.Flags;
    LeaveFidoPolls;
  end;
  if rmfHFR in SD.rmtMailerFlags then AddFReq;
  Add(os_CrashMail);
  Add(os_DirectMail);
  Add(osNormalMail);
  if TransmitHold then Add(osHoldMail);
  Add(os_Crash);
  Add(os_Direct);
  Add(osNormal);
  if TransmitHold then
  begin
    Add(osHold);
    Add(osHreq);
  end;
  if not (rmfHFR in SD.rmtMailerFlags) then AddFReq;

  STrsFilesRqd := EP.StrValue(eiTrsFilesRqd);
  STrsFilesFrb := EP.StrValue(eiTrsFilesFrb);

  if SD.ActivePoll = nil then
  begin
     TransmitRequired := TStringColl.Create;
     TransmitForbidden := TStringColl.Create;
     TransmitRequired.FillEnum(ExpandSuperMask(STrsFilesRqd), ' ', True);
     TransmitForbidden.FillEnum(ExpandSuperMask(STrsFilesFrb), ' ', True);
     if TransmitRequired.Count = 0 then FreeObject(TransmitRequired);
     if TransmitForbidden.Count = 0 then FreeObject(TransmitForbidden);
  end else
  begin
    TransmitRequired := nil;
    TransmitForbidden := nil;
    if (STrsFilesRqd <> '') or (STrsFilesFrb <> '') then
    begin
      LogOnce(ltInfo, Format('Transmit files restrictions are ignored on outgoing sessions (Required="%s"; Forbidden="%s")', [STrsFilesRqd, STrsFilesFrb]));
    end;
  end;

  for I := 0 to CollMax(SD.rmtAddrs) do
  begin
    for K := 1 to N do
    begin
      S := A[K];
      J := SD.OutFiles.Count;
      SD.OutFiles := FidoOut.GetOutbound(SD.rmtAddrs[I], [S], SD.OutFiles, nil, nil, False);
      ChkErrMsg;
      L := SD.OutFiles.Count-1;
      if L<J then Continue;
      case S of
        os_CrashMail, os_DirectMail, osNormalMail, osHoldMail : PI := @SD.TxMail;
        osRequest:
        begin
          PI := nil;
        end;
        else PI := @SD.TxFiles;
      end;
      for M := L downto J do
      begin
        tof := SD.OutFiles[M];
        for P := 0 to SD.SentFiles.Count-1 do
        begin
          if tof.Name = TOutFile(SD.SentFiles[P]).Name then
          begin
            SD.OutFiles.AtFree(M);
            tof := nil;
            Break;
          end;
        end;

        if tof = nil then Continue;

        ok := True;

        if ok and (rmfNPU in SD.rmtMailerFlags) then
        begin
          LogOnce(ltInfo, Format('"%s" not sent - reason is no mail pickup desired by caller', [tof.Name]));
          ok := False;
        end;

        if ok and (rmfHAT in SD.rmtMailerFlags) then
        begin
          LogOnce(ltInfo, Format('"%s" not sent - reason is answering system set to hold all traffic', [tof.Name]));
          ok := False;
        end;

        if ok and (I >= 1) and (rmfPUP in SD.rmtMailerFlags) then
        begin
          LogOnce(ltInfo, Format('"%s" not sent - reason is caller set to pickup mail for primary address only', [tof.Name]));
          ok := False;
        end;

        if ok and (rmfHXT in SD.rmtMailerFlags) then
        begin
         case S of
           os_CrashMail, os_DirectMail, osNormalMail, osHoldMail : ;
           else
           begin
             LogOnce(ltInfo, Format('"%s" not sent - reason is answering system set to hold all traffic except uncompressed mail', [tof.Name]));
             ok := False;
           end;
         end;
        end;

        if not ok then
        begin
          SD.OutFiles.AtDelete(M);
          SD.SentFiles.Insert(tof);
          if SD.ActivePoll <> nil then SD.ActivePoll.FileSendDelayed := True;
          tof := nil;
        end;

        if tof = nil then Continue;

        case S of
          osRequest,
          os_Crash,
          os_CrashMail :
          begin
            if (STrsFilesRqd <> '') or (STrsFilesFrb <> '') then
            begin
              LogOnce(ltInfo, Format('Transmit files restrictions are ignored for Crash attachments (Required="%s"; Forbidden="%s")', [STrsFilesRqd, STrsFilesFrb]));
            end;
          end;
          else
          begin
            RqdMatched := TransmitRequired = nil;
            if not RqdMatched then
            begin
              for II := 0 to CollMax(TransmitRequired) do
              begin
                sss := TransmitRequired[II];
                if MatchMask(tof.Name, sss) then
                begin
                  LogOnce(ltInfo, Format('"%s" matches "%s"', [tof.Name, sss]));
                  RqdMatched := True;
                  Break;
                end;
              end;
            end;

            if not RqdMatched then
            begin
              LogOnce(ltInfo, Format('"%s" not sent, reason is "%s" required', [tof.Name, STrsFilesRqd]));
              SD.OutFiles.AtDelete(M);
              SD.SentFiles.Insert(tof);
              if SD.ActivePoll <> nil then SD.ActivePoll.FileSendDelayed := True;
              tof := nil;
              if tof = nil then Continue;
            end;

            FrbMatched := False;
            for II := 0 to CollMax(TransmitForbidden) do
            begin
              sss := TransmitForbidden[II];
              if MatchMask(tof.Name, sss) then
              begin
                FrbMatched := True;
                Break;
              end;
            end;

            if FrbMatched then
            begin
              Log(ltInfo, Format('"%s" not sent, reason is "%s" forbidden, matched "%s"', [tof.Name, STrsFilesFrb, sss]));
              SD.OutFiles.AtDelete(M);
              SD.SentFiles.Insert(tof);
              if SD.ActivePoll <> nil then SD.ActivePoll.FileSendDelayed := True;
              tof := nil;
              if tof = nil then Continue;
            end;
          end;
        end;

        case tof.Error of
          0 : begin
                if PI <> nil then Inc(PI^, tof.Nfo.Size);
              end;
          ERROR_FILE_NOT_FOUND:
              begin
                if FidoOut.DeleteFile(tof.Address, tof.Name, tof.FStatus) then
                begin
                  LogOnce(ltGlobalErr, Format('Outbound %s - unlinked', [FormatErrorMsg(tof.Name, tof.Error)]));
                end;
                SD.OutFiles.AtDelete(M);
                SD.SentFiles.Insert(tof)
              end;
           else
              begin
                case tof.FStatus of
                  os_CrashMail,
                  os_DirectMail,
                  os_Crash,
                  os_Direct:
                  begin
                    if FidoOut.ChangeAttachStatusFile(tof.Address, tof.Name, tof.FStatus, osNormal) then
                    begin
                      LogOnce(ltGlobalErr, Format('Outbound %s - changed attach status to Normal', [FormatErrorMsg(tof.Name, tof.Error)]));
                    end;
                  end;
                end;
                SD.OutFiles.AtDelete(M);
                SD.SentFiles.Insert(tof);
              end;
        end;
      end;
    end;
  end;

  FreeObject(TransmitRequired);
  FreeObject(TransmitForbidden);


  if not SD.WeHaveReported then
  begin
    SD.WeHaveReported := True;
    if (SD.txMail=0) and (SD.txFiles=0) then Log(ltInfo, 'Nothing for them') else
    begin
      LogFmt(ltInfo,'We have %sb of mail and %sb of files for them', [Int2Str(SD.txMail), Int2Str(SD.txFiles)]);
      if ProtCore = ptBinkP then SD.Prot.ReportTraf(SD.txMail, SD.txFiles);
    end;
  end;
end;

function TMailerThread.AcceptFile(P: TBaseProtocol): TTransferFileAction;

function DoAccept(P: TBaseProtocol): TTransferFileAction;

procedure ReturnMemoryStream(AInStreamType: TTransferStreamType);
begin
  P.R.Stream := TxMemoryStream.Create;;
  P.R.D.StreamType := AInStreamType;
  Result := aaOK;
end;

var
  osss, ss, sss, fp, fn, fe, ib, ufe: string;
  Match: Boolean;
  Info: TFileInfo;
  s: TxStream;
  tof: TOutFile;
  d: DWORD;
  k: Integer;
  cs: TCharSet;
  BadFName: Boolean;
  PutKind: TInboundPutKind;
begin
  P.R.D.State := bsActive;

  sss := Trim(P.R.D.FName);
  if sss <> P.R.D.FName then
  begin
    LogFmt(ltWarning, '''%s'' contains invalid characters around - trimmed', [P.R.D.FName]);
    P.R.D.FName := sss;
  end;

  FSplit(P.R.D.FName, fp, fn, fe);
  ufe := UpperCase(fe);

  BadFName := False;
  if fp <> '' then BadFName := True;
  if not BadFName then
  begin
    FillCharSet(P.R.D.FName, cs);
    if (cs * [#0..#31, '/', '\', '*', '?', #127, ':']) <> [] then BadFName := True;
  end;
  if BadFName then
  begin
    Log(ltGlobalErr, 'Invalid file name');
    Result := aaRefuse;
    Exit;
  end;

  ss := ExpandSuperMask(EP.StrValue(eiAccFilesRqd));
  if ss <> '' then
  begin
    osss := ss;
    Match := False;
    while ss <> '' do
    begin
      GetWrd(ss, sss, ' ');
      if MatchMask(P.R.D.FName, sss) then
      begin
        LogFmt(ltInfo, '"%s" matches "%s"', [P.R.D.FName, sss]);
        Match := True;
        Break;
      end;
    end;
    if not Match then
    begin
      LogFmt(ltWarning, '"%s" will be accepted later, reason is "%s" required', [P.R.D.FName, osss]);
      Result := aaAcceptLater;
      Exit;
    end;
  end;

  ss := ExpandSuperMask(EP.StrValue(eiAccFilesFrb));
  if ss <> '' then
  begin
    osss := ss;
    Match := False;
    while ss <> '' do
    begin
      GetWrd(ss, sss, ' ');
      if MatchMask(P.R.D.FName, sss) then
      begin
        Match := True;
        Break;
      end;
    end;
    if Match then
    begin
      LogFmt(ltWarning, '"%s" will be accepted later, reason is "%s" forbidden, matched "%s"', [P.R.D.FName, osss, sss]);
      Result := aaAcceptLater;
      Exit;
    end;
  end;

  if (SD.FTS1NeedRmtAddr) then
  begin
    if (P.R.D.FSize < 60) or (ufe <> '.PKT') then
    begin
      Log(ltWarning, 'FTS-0001 remote info requred');
      Result := aaAcceptLater;
      Exit;
    end;
    if ((P.R.D.FSize = 60) or (P.R.D.FSize = 61)) then
    begin
      ReturnMemoryStream(xstInMemPKT);
      Exit;
    end;
  end;

  if ufe = '.REQ' then
  begin
    if SD.AcceptReq then
    for k := 0 to CollMax(SD.OutFiles) do
    begin
      tof := SD.OutFiles[k];
      if tof.FStatus = osHreq then
      begin
        SD.AcceptReq := False;
        Break;
      end;
    end;
    if (P.R.D.FSize > $10000) then
    begin
      LogFmt(ltWarning, 'Size of "%s" is too large (%s) - refusing', [P.R.D.FName, Int2Str(P.R.D.FSize)]);
      Result := aaRefuse;
    end else
    if (not SD.AcceptReq) or (SD.ActivePoll <> nil) then
    begin
      Log(ltWarning, 'Requests are not acceptable');
      SD.SkipInMem := True;
    end;
    ReturnMemoryStream(xstInMemREQ);
    if Result <> aaOK then SD.FreqProcessed := True;
    Exit;
  end;

  ib := GetInboundDir(SD.rmtPrimaryAddr, P.R.D.FName, SD.PasswordProtected, PutKind);
  if not CreateDirInheritance(ib) then
  begin
    ChkErrMsg;
    Result := aaAcceptLater;
    Exit;
  end;

  if GetFileNfo(MakeNormName(ib, P.R.D.FName), Info, False) and
     (P.R.D.FTime = Info.Time) and
     (P.R.D.FSize = Info.Size) then
  begin
    Result := aaRefuse;
    Exit;
  end;

  SD.WzRec := GetBWZ(P.R.D.FName, P.R.D.FSize, P.R.D.FTime, SD.rmtPrimaryAddr, SD.rmtAddrs);
  if SD.WzRec <> nil then
  begin
    if SD.WzRec.Locked then
    begin
      Log(ltInfo, Format('Already processing ''%s''', [SD.WzRec.GetBwzFName]));
      Result := aaAcceptLater;
      SD.WzRec := nil;
      Exit;
    end else
    begin
      s := CreateDosStream(SD.WzRec.GetBWZFName, [cWrite, cExisting]);
      if s <> nil then
      begin
        d := s.Seek(0,FILE_END);
        if d = INVALID_FILE_SIZE then
        begin
          SetErrorMsg(SD.WzRec.GetBWZFName);
          ChkErrMsg;
        end else
        if d = P.R.D.FSize then
        begin
          // got completely but can''t move it to inbound
          Result := aaRefuse;
          FreeObject(s);
          SD.WzRec := nil;
          Exit;
        end else
        begin
          if d = SD.WZRec.TmpSize then
          begin
            SD.WZRec.Locked := True;
            P.R.D.FOfs := d;
            P.R.Stream := s;
            Result := aaOK;
            P.R.D.StreamType := xstInDiskFileAppend;
            Exit;
          end else
          begin
            LogFmt(ltInfo, 'Complete File Size/Time: Saved[%s/%d], Got[%s/%d]',
              [Int2Str(SD.WZRec.FSize), SD.WZRec.FTime,
               Int2Str(P.R.D.FSize), P.R.D.FTime]);
            LogFmt(ltInfo, 'BadWaZOO Size Real: %s, Listed: %s',
             [Int2Str(d), Int2Str(SD.WZRec.TmpSize)]);
          end;
        end;
        FreeObject(s);
        Log(ltInfo, Format('Deleting invalid ''%s''', [SD.WzRec.GetBwzFName]));
        DeleteFile(SD.WzRec.GetBWZFName);
      end else
      begin
        Log(ltWarning, Format('Can''t open ''%s''', [SD.WzRec.GetBwzFName]));
      end;
      FreeBWZ(SD.WzRec);
    end;
  end;

  SD.WzRec := AddBWZ(P.R.D.FName, P.R.D.FSize, P.R.D.Ftime, Integer(SD.PasswordProtected), SD.rmtPrimaryAddr);
  SD.WzRec.Locked := True;
  fn := SD.WzRec.GetBWZFName;

  if not CreateDirInheritance(ExtractFileDir(fn)) then
  begin
    ChkErrMsg;
    Result := aaAcceptLater;
    if SD.WzRec.TmpSize = 0 then FreeBWZ(SD.WzRec) else SD.WzRec.Locked := False;
    Exit;
  end;

  s := CreateDosStream(fn, [cTruncate]);
  if s = nil then
  begin
    SetErrorMsg(fn);
    ChkErrMsg;
    Result := aaAcceptLater;
    if SD.WzRec.TmpSize = 0 then FreeBWZ(SD.WzRec) else SD.WzRec.Locked := False;
    Exit;
  end;
  SetEndOfFile(TDosStream(s).Handle);
  P.R.Stream := s;
  P.R.D.StreamType := xstInDiskFileNew;
  Result := aaOK;
end;

begin
  {$IFDEF WS}LogHandshakeStart;{$ENDIF}
  BWZColl.Enter;
  Result := DoAccept(P);
  case Result of
    aaOK           :
      begin
        Log(ltInfo, Format('Receiving ''%s'' (%sb)',[P.R.D.FName, Int2Str(P.R.D.FSize)]));
        P.R.D.FPos := P.R.D.FOfs;
        if P.R.D.FPos <> 0 then
        begin
          LogFmt(ltInfo, 'Receiving from offset %s', [Int2Str(P.R.D.FPos)]);
          P.R.Stream.Seek(P.R.D.FPos, FILE_BEGIN);
        end;
        P.R.D.Start := uGetSystemTime;
        DisplayData;
      end;
    aaRefuse       : Log(ltInfo, Format('Refusing ''%s''',[P.R.D.FName]));
    aaAcceptLater  :
      begin
        Log(ltInfo, Format('Delaying ''%s''',[P.R.D.FName]));
        if rmfNoFileDelay in SD.rmtMailerFlags then
        begin
          Log(ltWarning, 'Remote mailer doesn''t support Delay File Capability - disconnecting');
          Result := aaAbort;
        end;
      end;
  end;
  BWZColl.Leave;
end;


procedure TMailerThread.ReportReq;
const
  eiDur: array[Boolean] of Integer = (eiFreqPubDur, eiFreqPwdDur);
  eiSz : array[Boolean] of Integer = (eiFreqPubSz , eiFreqPwdSz );
  eiCnt: array[Boolean] of Integer = (eiFreqPubCnt, eiFreqPwdCnt);
var
  i,j: Integer;
  r: TReqRec;
  f: TReqFile;
  s: TStringColl;
  ss: string;
  etr, esr, ecr: Boolean;
  MaxMinutes, TotCount, TotSize, MaxCount, MaxSizeA, MaxSizeB: DWORD;
  b: Boolean;


procedure lg(const AStr: string);
begin
  LogFmt(ltInfo, AStr, [f.FName, Int2Str(f.Info.Size), uFormat(f.Info.Time)]);
end;

begin
  b := SD.PasswordProtected;
  MaxCount := EP.DwordValueD(eiCnt[b], High(MaxCount));
  MaxSizeA := EP.DwordValueD(eiDur[b], High(MaxSizeA)); MaxMinutes := MaxSizeA;
  MaxSizeB := EP.DwordValueD( eiSz[b], High(MaxSizeB));
  if MaxSizeA < High(MaxSizeA) then MaxSizeA := (MaxSizeA * SD.ConnectSpeed * 60) div 8;
  if MaxSizeB < High(MaxSizeB) then MaxSizeB := MaxSizeB * 1024;
  TotCount := 0;
  TotSize := 0;
  etr := False;
  esr := False;
  ecr := False;

  s := TStringColl.Create;
  if SD.ReqLines <> nil then
  for i := 0 to SD.ReqLines.Count-1 do
  begin
    r := SD.ReqLines[i];
    if r.Typ < rtOK then
    begin
      LogFmt(ltWarning, 'Unrecognized request line "%s"', [Copy(r.s, 1, MAX_PATH)]);
      Continue;
    end;
    if r.Files = nil then
    begin
      if r.SRPs <> nil then ProcessSRPs(r.SRPs) else
      begin
        if r.Psw = '' then ss := '' else ss := Format('password-equipped ("%s") ', [r.Psw]);
        case r.Typ of
          rtNormal:
              LogFmt(ltInfo, 'Can''t fulfill %sfile request "%s"', [ss, r.s]);
          rtNewer:
              LogFmt(ltInfo, 'Can''t fulfill %supdate request "%s", newer than %s', [ss, r.s, Int2Str(r.Upd)]);
          rtUpTo:
              LogFmt(ltInfo, 'Can''t fulfill %supdate request "%s", up to date %s', [ss, r.s, Int2Str(r.Upd)]);
          else GlobalFail('%s', ['TMailerThread.ReportReq t.Typ(A) ??'])
        end;
      end;
      Continue;
    end;

    case r.Typ of
      rtNormal:
          LogFmt(ltInfo, 'File request "%s" processed', [r.s]);
      rtNewer:
          LogFmt(ltInfo, 'File update request "%s" processed, newer than %s', [r.s, Int2Str(r.Upd)]);
      rtUpTo:
          LogFmt(ltInfo, 'File update request "%s" processed, up to date %s', [r.s, Int2Str(r.Upd)]);
        else GlobalFail('%s', ['TMailerThread.ReportReq t.Typ(B) ??'])
    end;

    for j := 0 to r.Files.Count-1 do
    begin
      if j mod 100 = 99 then FlushLog;
      f := r.Files[j];
      if SD.OutFiles.FoundFName(f.FName) or
         SD.SentFiles.FoundFName(f.FName) or
         s.FoundUC(f.FName) then
      begin
        lg(' already attached %s (%sb, %s) - skipping');
      end else
      begin
        if TotCount >= MaxCount then
        begin
          lg(' %s (%sb, %s) exceeds by count');
          if not ecr then
          begin
            ecr := True;
            LogFmt(ltInfo, 'Maximum of %d files is allowed', [MaxCount]);
          end;
          Continue;
        end;
        if TotSize + f.Info.Size > MaxSizeA then
        begin
          lg(' %s (%sb, %s) exceeds by duration');
          if not etr then
          begin
            etr := True;
            LogFmt(ltInfo, 'Maximum of %d minutes (%s KB on %d BPS) is allowed', [MaxMinutes, Int2Str(MaxSizeA div 1024), SD.ConnectSpeed]);
          end;
          Continue;
        end;
        if TotSize + f.Info.Size > MaxSizeB then
        begin
          lg(' %s (%sb, %s) exceeds by size');
          if not esr then
          begin
            esr := True;
            LogFmt(ltInfo, 'Maximum of %s KB is allowed', [Int2Str(MaxSizeB div 1024)]);
          end;
          Continue;
        end;
        lg(' %s (%sb, %s) attached');
        s.Add(f.FName);
        if MaxCount < High(MaxCount) then Inc(TotCount);
        if (MaxSizeA < High(MaxSizeA)) or (MaxSizeB < High(MaxSizeB)) then Inc(TotSize, f.Info.Size);
      end;
    end;
  end;
  FidoOut.AttachFiles(SD.rmtPrimaryAddr, S, osHReq, kaBsoNothingAfter);
  ChkErrMsg;
  if S.Count > 0 then LogFmt(ltInfo, 'Total %d requested file(s) attached', [S.Count]);
  FreeObject(S);
end;

function TMailerThread.GetCPSInt(AStart, ASize: DWORD): Integer;
var
  ela: DWORD;
begin
  Result := -1;
  if AStart <> 0 then
  begin
    ela := uGetSystemTime-AStart;
    if (ela >= CPS_MinSecs) and (ASize >= CPS_MinBytes) then Result := ASize div ela;
  end;
end;

function TMailerThread.GetCPS(AStart, ASize: DWORD): string;
var
  i: Integer;
begin
  i := GetCPSInt(AStart, ASize);
  if i < 0 then Result := '' else Result := Format('%d CPS, ', [i]);
end;
            
procedure TMailerThread.ProcessRequestFTS;
begin
  SD.ReqLines := ParseReq(ASC);
  ScanReq(SD.ReqLines);
  ChkErrMsg;
  ReportReq;
  FreeObject(SD.ReqLines);
end;

function DoCreateSRIFProcess(const AStr: string; ALogger: TAbstractLogger; var PI: TProcessInformation): Boolean;
var
  Priority: DWORD;
  Detached, SetFlag: Boolean;
  ShowMode: TExecShowMode;
  ss: string;
begin
  ss := AStr;
  Result := CheckExecPrefixes(ss, Priority, Detached, ShowMode, SetFlag);
  if not Result then
  begin
    ALogger.LogFmt(ltGlobalErr, 'DoCreateSRIFProcess(%s) failed', [AStr]);
    Exit;
  end;
  if SetFlag then
  begin
    ALogger.Log(ltGlobalErr, 'File-flags are not allower for SRIF');
  end else
  begin
    Result := ExecProcess(ss, PI, nil, nil, False, IDet[Detached] or Priority or CREATE_SUSPENDED, ShowMode);
  end;
end;


procedure TMailerThread.ProcessSRIF;
var
  s, z, k, RequestList, ResponseList, SRIF: string;
  h: DWORD;
  SC1, SC2, SC3: TStringColl;
  PI: TProcessInformation;
  T: TTextReader;
  fa: TFidoAddress;

const
  c = #13#10;
  cProt: array[Boolean] of string = ('UNPROTECTED', 'PROTECTED');
  cList: array[Boolean] of string = ('UNLISTED', 'LISTED');

procedure WriteS;
var
  Actually: DWORD;
begin
  WriteFile(h, s[1], Length(s), Actually, nil);
end;

procedure Add(SC: TStringColl);
begin
  DelFC(S); SC.Add(S);
  LogFmt(ltInfo, 'Attached "%s"', [S]);
end;

function AkaStr(const a: TFidoAddress): string;
begin
  Result := Format('AKA %s'+c, [Addr2Str(a)]);
end;

procedure DeleteTmps;
begin
  DeleteFile(SRIF);
  Windows.DeleteFile(PChar(RequestList));
  DeleteFile(ResponseList);
end;

var
  Code: DWORD;
  i: Integer;

const
  Cores: array[TSessionCore] of string = ('???', 'FTS-0001', 'EMSI', 'BinkP');

begin
  for i := 0 to ASC.Count-1 do
  begin
    LogFmt(ltInfo, 'Requested "%s"', [ASC[i]]);
  end;
  DisplayData;
  s := ASC.LongString;
  FreeObject(ASC);

  h := CreateTempFile(ATmpDir, 'req', RequestList);
  WriteS;
  ZeroHandle(h);

  ResponseList := TempFileName(ATmpDir, 'rsp');

  s := AkaStr(SD.rmtPrimaryAddr);
  for i := 0 to CollMax(SD.rmtAddrs) do
  begin
    fa := SD.rmtAddrs[i];
    if CompareAddrs(SD.rmtPrimaryAddr, fa) = 0 then Continue;
    s := s + AkaStr(fa);
  end;


  k := Format(
    'Baud %d'+c+            // effective baud rate, not the fixed DTE rate
    'Time -1'+c+            // time till next event which does not allow file requests. Use -1 if no limits
    'RequestList %s'+c+     // filename of the list containing requested files
    'ResponseList %s'+c+    // '+' do not erase the file after sent
    'RemoteStatus %s'+c+    // <PROTECTED or UNPROTECTED>
    'SystemStatus %s'+c+    // <LISTED or UNLISTED>
    'SessionProtocol %s'+c+ // eg. ZAP,ZMO,XMA
    'Site %s'+c+            // The site info as given e.g. in EMSI handshake
    'Location %s'+c+
    'Phone %s'+c+
    'DTE %d'+c+
    'PORT %d'+c+            // COM Port from 1 to 8
    'Mailer %s'+c+          // Remote's mailer
    'MailerCode %s'+c+
    'SerialNumber %s'+c+
    'Version %s'+c+
    'SessionType %s'+c,
   [
     SD.ConnectSpeed,
     RequestList,
     ResponseList,
     CProt[SD.PasswordProtected],
     CList[RemoteListed],
     SEMSICapabilities[SD.DesiredProtocol],
     DS.rmtStationName,
     DS.rmtLocation,
     DS.rmtPhone,
     CP.DTE,
     CP.PortNumber,
     SD.rmtMailerName,
     SD.rmtMailerCode,
     SD.rmtMailerSerialNo,
     SD.rmtMailerVersion,
     Cores[SD.SessionCore] // SessionType
  ]);

  s := Format('Sysop %s'+c, [DS.rmtSysOpName]) + s + k;

  k := SD.OutAddrs;
  while k <> '' do
  begin
    GetWrd(k, z, ' ');
    s := s +Format('OurAKA %s'+c, [z]);
  end;
  if SD.rmtTRX <> 0 then s := s + 'TRANX '+Hex8(SD.rmtTRX)+c;

  if SD.PasswordProtected then s := s + Format('Password %s'+c, [SD.rmtPassword]);
  h := CreateTempFile(ATmpDir, 'srf', SRIF);
  WriteS;
  ZeroHandle(h);
  s := AExeFName;
  Replace('%SRIF%', SRIF, s);
  if not DoCreateSRIFProcess(s, Logger, PI) then
  begin
    ChkErrMsg;
    DeleteTmps;
    Exit;
  end;
  LogFmt(ltInfo, 'Executing SRIF ERP "%s" (PID=%x)', [s, PI.dwProcessId]);
  D.ExtApp := True;
  DisplayData;
  ResumeThread(PI.hThread);
  WaitEvtInfinite(PI.hProcess);
  if not GetExitCodeProcess(PI.hProcess, Code) then Code := 0;
  D.ExtApp := False;
  Logger.LogTermination(PI, False, '');
  ZeroHandle(PI.hThread);
  ZeroHandle(PI.hProcess);

  SC1 := TStringColl.Create;
  SC2 := TStringColl.Create;
  SC3 := TStringColl.Create;

  T := CreateTextReader(ResponseList);
  if T <> nil then
  while not T.EOF do
  begin
    s := DelRight(T.GetStr);
    if s = '' then Continue;
    case s[1] of
      '=' :  //  erase file if sent successfully
        Add(SC1);
      '+' : //   do not erase the file after sent
        Add(SC2);
      '-' : //   erase the file in any case after session
        Add(SC3);
      else
        LogFmt(ltWarning, 'Unrecognized SRIF response "%s"', [s]);
    end;
  end;
  FreeObject(T);

  DeleteTmps;

  AttachERPFiles(SC1, SC2, SC3);

  FreeObject(SC1);
  FreeObject(SC2);
  FreeObject(SC3);
end;

procedure TMailerThread.FinishRece(P: TBaseProtocol; Action: TTransferFileAction);
var
  fp, fn, fe, ufe: string;
  ss: DWORD;
  InStream: Boolean;
  PutKind: TInboundPutKind;
  IsSRIF: Boolean;
  TmpDir, ExtSRIF: string;
  FreqSC: TStringColl;

function CompleteFile: Boolean;
begin
  Result := ss = P.R.D.FSize;
end;

function KillFile: Boolean;
begin
  Result := (SD.SessionCore = scFTS1) or (P.R.Stream.Size < $4000) or (ufe = '.PKT') or (ufe = '.P2K');
end;

procedure DoFinish;
var
  cps: string;

procedure DoKillFile;
var
  dn: string;
begin
  FreeObject(P.R.Stream);
  dn := SD.WzRec.GetBWZFName;
  Log(ltWarning, Format('%sFailed to receive ''%s'', deleting ''%s''',[CPS, P.R.D.FName, dn]));
  DeleteFile(dn);
  FreeBWZ(SD.WzRec);
end;

begin
  P.FileRefuse := False;
  P.FileSkip := False;
  SD.FileRefuse := False;
  SD.FileSkip := False;
  D.SkipIs := False;
  if Action = aaSysError then
  begin
    SetErrorMsg(P.R.D.FName);
    ChkErrMsg;
  end;
  DisplayData;
  ss := P.R.Stream.Size;
  CPS := GetCPS(P.R.D.Start, P.R.D.FPos - P.R.D.FOfs);
  FSplit(P.R.D.FName, fp, fn, fe);
  ufe := UpperCase(fe);

  case P.R.D.StreamType of
    xstInMemREQ, xstInMemPKT:
      InStream := True;
    else
      InStream := False;
   end;

  if Action = aaRefuse then
  begin
    Log(ltInfo, 'Receiving file was rejected by local operator');
    DoKillFile;
  end else
  begin
    if Action = aaAcceptLater then
    begin
      Log(ltInfo, 'Receiving file was skipped by local operator');
    end;
    if not CompleteFile then
    begin
      if InStream then FreeObject(P.R.Stream) else
      if KillFile then DoKillFile else
      begin
        Log(ltWarning, Format('%sPart of ''%s'' (%sb) is temporarily stored as ''%s''',[CPS, P.R.D.FName, Int2Str(P.R.Stream.Size), SD.WzRec.GetBWZFname]));
        SD.WzRec.TmpSize := ss;
        FreeObject(P.R.Stream);
        SD.WzRec.Locked := False;
        SD.WzRec := nil;
      end;
    end else
    begin
      case P.R.D.StreamType of
        xstInMemREQ:
          begin
            if not SD.SkipInMem then
            begin
              CfgEnter;
              IsSRIF := foSRIF in Cfg.FreqData.Options;
              ExtSRIF := Cfg.FreqData.Misc[0];
              TmpDir := FullPath(Cfg.Pathnames.InTemp);
              CfgLeave;
              P.R.Stream.Position := 0;
              FreqSC := TStringColl.Create;
              FreqSC.LoadFromStream(P.R.Stream);
              FreeObject(P.R.Stream);
            end;
            FreeObject(P.R.Stream);
          end;
        xstInMemPkt: FreeObject(P.R.Stream); // it was FTS-0001 session info packet
        xstInDiskFileAppend,
        xstInDiskFileNew:
          begin
            // file received completely - try to store it to inbound
            Inc(SD.FilesReceived);
            SD.WzRec.TmpSize := ss;
            CommonLog.Add(SD.rmtPrimaryAddr, MakeNormName(GetInboundDir(SD.rmtPrimaryAddr, P.R.D.FName, SD.PasswordProtected, PutKind), SD.WzRec.FName), False, ss, DS.rmtSoft);
            FreeObject(P.R.Stream);
            if TossSingleBWZ(SD.WzRec, fn) then
            begin
              Log(ltInfo, Format('%sReceived ''%s''',[CPS, fn]));
              FreeBWZ(SD.WzRec);
            end else
            begin
              ChkErrMsg;
              Log(ltInfo, Format('%sReceived/queued ''%s''',[CPS, SD.WzRec.GetBWZFname]));
              SD.WzRec.Locked := False;
              SD.WzRec := nil;
            end;
          end;
        else GlobalFail('%s', ['TMailerThread.FinishRece P.R.D.StreamType']);
      end;
    end;
  end;
end;

begin
  FreqSC := nil;
  if P.R.Stream = nil then
  begin
    Exit;
  end;
  BWzColl.Enter;
  DoFinish;
  BWzColl.Leave;
  if FreqSC <> nil then
  begin
    if IsSRIF then ProcessSRIF(FreqSC, ExtSRIF, TmpDir) else ProcessRequestFTS(FreqSC);
    SD.FReqProcessed := True;
    if (ProtCore = ptBinkP) and (P.TxClosed) then ScanOut;
  end;
  Inc(D.rxBytes, P.R.D.FSize);
  Inc(SD.cRxBytes, P.R.D.FPos - P.R.D.FOfs);
  P.R.ClearFileInfo;
end;

procedure TMailerThread.FinishSend(P: TBaseProtocol; Action: TTransferFileAction);
var
  r: TOutFile;
  sss, MoveTo, CPS: string;
  i: Integer;
  OK, Overwritten: Boolean;
  st: TOutStatus;

const
  KAS : array[TKillAction] of string = ('', ' deleted', ' truncated', '/delete', '/move');
  KAR : array[TKillAction] of string = ('', ' - deleted', ' - truncated', ' - delete', ' - move');

begin
  if P.T.Stream = nil then
  begin
    Exit;
  end;
  if Action = aaSysError then
  begin
    SetErrorMsg(P.T.D.FName);
    ChkErrMsg;
  end;

  CPS := GetCPS(P.T.D.Start, P.T.D.FPos - P.T.D.FOfs);
  DisplayData;
  if P.T.Stream is TxMemoryStream then r := nil else
  begin
    r := SD.OutFiles[0];
    if (UpperCase(ExtractFileExt(r.Name)) = '.REQ') then
    begin
      if rmfHFR in SD.rmtMailerFlags then r.KillAction := kaBsoKillAfter
                                        else SD.KillSentREQ := True;
    end;
  end;

  case Action of
    aaOK, aaRefuse:
      begin
        Inc(SD.FilesSent);
        if r = nil then FreeObject(P.T.Stream) else
        case r.KillAction of
          kaBsoNothingAfter :
            begin
              FreeObject(P.T.Stream);
            end;
          kaBsoKillAfter :
            begin
              FreeObject(P.T.Stream);
              if SD.HReqDelete <> nil then
              begin
                if SD.HReqDelete.Search(@r.Name, I) then SD.HReqDelete.AtFree(I);
              end;
              DeleteOutFile(r.Name);
            end;
          kaBsoTruncateAfter:
            begin
              P.T.Stream.Seek(0, FILE_BEGIN);
              SetEndOfFile(TDosStream(P.T.Stream).Handle);
              FreeObject(P.T.Stream);
            end;
          kaFbKillAfter:
            begin
              FreeObject(P.T.Stream);
              if not Windows.DeleteFile(PChar(r.Name)) then
              begin
                LogFmt(ltWarning, 'Cannot delete %s (%s)', [r.Name, SysErrorMessage(GetLastError)]);
              end;
            end;           
          kaFbMoveAfter:
            begin
              FreeObject(P.T.Stream);
              st := r.Status;
              MoveTo := ReplaceDirMacro(r.MoveTo, @r.Address, @st, [rmkTime, rmkAddr, rmkStatus], nil);
              if not CreateDirInheritance(MoveTo) then
              begin
                ChkErrMsg;
              end else
              begin
                sss := MakeNormName(MoveTo, ExtractFileName(r.Name));
                ok := MoveFileSmart(r.Name, sss, True, Overwritten);
                if Overwritten then LogOverwritten(sss);
                if not ok then ChkErrMsg else
                begin
                  if not Overwritten then LogMoved(sss);
                end
              end;
            end;
          else
            begin
              GlobalFail('%s', ['FinishSend - Unhandled aAction']);
            end;
        end;
        if r <> nil then FidoOut.DeleteFile(r.Address, r.Name, r.FStatus);
        case Action of
          aaOK:
            begin
              if r = nil then sss := '' else sss := KAS[r.KillAction];
              LogFmt(ltInfo, '%sSent%s ''%s''', [CPS, sss, P.T.D.FName]);
              if r = nil then sss := P.T.D.FName else sss := r.Name;
              if r = nil then i := P.T.D.FSize else i := r.Nfo.Size;
              CommonLog.Add(SD.rmtPrimaryAddr, sss, True, i, DS.rmtSoft);
            end;
          aaRefuse:
            begin
              if r = nil then sss := '' else sss := KAR[r.KillAction];
              LogFmt(ltInfo, 'Remote refused ''%s''%s', [P.T.D.FName, sss]);
            end;
        end;
      end
    else
      begin
        case Action of
          aaAcceptLater:
            begin
              LogFmt(ltWarning, 'Remote will accept ''%s'' later', [P.T.D.FName]);
              if SD.ActivePoll <> nil then SD.ActivePoll.FileSendDelayed := True;
            end;
          aaSysError:;
          aaAbort:
            LogFmt(ltWarning, 'Protocol aborted while sending ''%s''', [P.T.D.FName]);
        end;
        FreeObject(P.T.Stream);
      end;
  end;
  if r <> nil then
  begin
    SD.OutFiles.AtDelete(0);
    SD.SentFiles.Insert(r);
  end;
  Inc(D.txBytes, P.T.D.FSize);
  Inc(SD.cTxBytes, P.T.D.FPos - P.T.D.FOfs);
  P.T.ClearFileInfo;
end;

procedure TMailerThread.GetNextFile(P: TBaseProtocol);
var
  s: TxStream;
  f: TOutFile;
  Info: TFileInfo;
  Cf: TCreateFileModeSet;
  PTDFName, zzz, ss: string;
  i: Integer;
  ph: TFSC39PktHdr;
  aa: TFidoAddress;
  ST: TSystemTime;

procedure Fre0;
begin
  Inc(D.TxBytes, F.Nfo.Size);
  if SD.DisabledFiles = nil then SD.DisabledFiles := TStringColl.Create;
  SD.DisabledFiles.Ins(UpperCase(f.Name));
  SD.OutFiles.AtFree(0);
end;

begin
  {$IFDEF WS}LogHandshakeStart;{$ENDIF}
  P.T.D.State := bsActive;
  P.T.D.ErrPos := 0;
  P.T.D.FName := '';
  repeat
    PTDFName := '';
    if (SD.OutFiles.Count = 0) then ScanOut;
    if SD.DisabledFiles <> nil then
    begin
      for i := SD.OutFiles.Count-1 downto 0 do
      begin
        f := SD.OutFiles[i];
        if SD.DisabledFiles.Found(UpperCase(f.Name)) then SD.OutFiles.AtFree(i);
      end;
    end;
    if (SD.OutFiles.Count = 0) then
    begin
      if not SD.SendDummyPkt then Exit;
      SD.SendDummyPkt := False;
      if (SD.SentFiles.Count > 0) then Exit;
      ss := SD.OutAddrs;
      GetWrd(ss, zzz, ' ');
      if not ParseAddress(zzz, aa) then aa := SD.rmtPrimaryAddr;
      Clear(ph, SizeOf(ph));
      ph.OrigNode := aa.Node;
      ph.DestNode := SD.rmtPrimaryAddr.Node;
      GetSystemTime(ST);
      ph.Year := ST.wYear - 1900;
      ph.Month := ST.wMonth - 1; 
      ph.Day := ST.wDay;
      ph.Hour := ST.wHour;
      ph.Minute := ST.wMinute;
      ph.Second := ST.wSecond;
      ph.Rate := SD.ConnectSpeed;
      ph.Version := 2;
      ph.OrigNet := aa.net;
      ph.DestNet := SD.rmtPrimaryAddr.Net;
      ph.ProductLow := Lo(mlProductCode);
      ph.ProdRevLow := CProductMinorVersion;
      if (SD.rmtPassword <> '') and (Length(SD.rmtPassword) <= 8) then Move(SD.rmtPassword[1], ph.Password, Length(SD.rmtPassword));
      ph.OrigZoneIgnore := ph.OrigZone;
      ph.DestZoneIgnore := ph.DestZone;
      ph.CapValid := $100;
      ph.ProductHi := 0;
      ph.ProdRevHi := CProductMajorVersion;
      ph.CapWord := 1;
      ph.OrigZone := aa.Zone;
      ph.DestZone := SD.rmtPrimaryAddr.Zone;
      ph.OrigPoint := aa.Point;
      ph.DestPoint := SD.rmtPrimaryAddr.Point;
      s := TxMemoryStream.Create;
      s.Write(ph, SizeOf(ph));
      i := 0;
      s.Write(i, 2);
      s.Position := 0;
      P.T.D.FTime := uGetSystemTime;
      P.T.D.FSize := s.Size;
      P.T.D.Start := uGetSystemTime;
      P.T.D.FName := Format('%.8x.PKT', [GetTickCount xor xRandom32]);
      P.T.Stream := s;
      Log(ltInfo,Format('Sending dummy ''%s'' (%sb)',[P.T.D.FName, Int2Str(P.T.D.FSize)]));
      DisplayData;
      Exit;
    end;

    f := SD.OutFiles[0];
    if (f.FStatus = osRequest) and ((rmfNRQ in SD.rmtMailerFlags) or (rmfHRQ in SD.rmtMailerFlags))then
    begin
      LogFmt(ltWarning, 'Remote refuses file requests - %s not sent', [f.Name]);
      SD.OutFiles.AtDelete(0);
      SD.SentFiles.Insert(f);
      Continue;
    end;

    ss := ExtractFileName(f.Name);
    PTDFName := ss;
    case f.FStatus of
      osRequest:
        if SD.rmtPrimaryAddr.Point <> 0 then
          PTDFName := Format('%.4x%.4x.REQ', [SD.rmtPrimaryAddr.Net, SD.rmtPrimaryAddr.Node]);
      os_CrashMail, os_DirectMail, osNormalMail, osHoldMail :
        begin
          if GetPktFileType(f.Name) = pftP2K then zzz := '%.8x.P2K' else zzz := '%.8x.PKT';
          PTDFName := Format(zzz, [GetTickCount xor xRandom32]);
        end;
    end;

    cf := [cRead, cExisting];
    case f.KillAction of
      kaBsoTruncateAfter,
      kaFbKillAfter,
      kaFbMoveAfter:
      Include(cf, cWrite);
    end;
    s := CreateDosStream(f.Name, cf);
    if s = nil then
    begin
      SetErrorMsg(f.Name);
      ChkErrMsg;
      Fre0;
      Continue;
    end;
    if not GetFileNfoByHandle(TDosStream(s).Handle, Info) then
    begin
      SetErrorMsg(f.Name);
      ChkErrMsg;
      FreeObject(s);
      Fre0;
      Continue;
    end;
    Break;
  until False;
  P.T.D.FTime := Info.Time;
  P.T.D.FSize := Info.Size;
  P.T.Stream := s;
  if ss = PTDFName then ss := '' else ss := Format(' -> ''%s''', [PTDFName]);
  Log(ltInfo,Format('Sending ''%s''%s (%sb)',[f.Name,ss, Int2Str(P.T.D.FSize)]));
  P.T.D.Start := uGetSystemTime;
  P.T.D.FName := PTDFName;
  DisplayData;
end;

function TMailerThread.GetThrErrorMsg: string;
begin
  Result := Name;
  Result := Format('%s: %s', [Name, MlrThreadStateName[State]]);
  if SD.Prot <> nil then Result := Format('%s (%s)', [Result, SD.Prot.GetStateStr]);
end;

procedure TMailerThread.CheckCPS;
var
  L, InCPS, OutCPS: Integer;
  VlD, EfD: DWORD;
  s: string;
  error: Boolean;
const
  ACPSVlMin: array[Boolean] of Integer = (eiAccCPSMin, eiTrsCPSMin);
  ACPSEfMin: array[Boolean] of Integer = (eiAccBPSEfMin, eiTrsBPSEfMin);
begin
  if SD.AtomDisconnected then Exit;
  if (SD.Prot = nil) or (CP = nil) then Exit;
  if SD.Prot.R = nil then InCPS := -1 else InCPS := SD.Prot.R.CPS(CP.OutUsed);
  if SD.Prot.T = nil then OutCPS := -1 else OutCPS := SD.Prot.T.CPS(CP.OutUsed);
  if (InCPS = -1) and (OutCPS = -1) then Exit;
  error := False;

  repeat
    VlD := EP.DwordValueD(ACPSVlMin[SD.ActivePoll <> nil], DWORD(MaxInt));
    if VlD = DWORD(MaxInt) then Break;
    L := 0;
    if ((InCPS >= 0) and (DWORD(InCPS) < VlD)) then Inc(L);
    if ((OutCPS >= 0) and (DWORD(OutCPS) < VlD)) then Inc(L, 2);
    if L = 0 then Break;
    case L of
      1: s := Format('RX CPS too low (%d), should be at least %d - disconnecting', [InCPS, VlD]);
      2: s := Format('TX CPS too low (%d), should be at least %d - disconnecting', [OutCPS, VlD]);
      3: s := Format('RX/TX CPS too low (%d/%d), should be at least %d - disconnecting', [InCPS, OutCPS, VlD]);
      else GlobalFail('%s', ['TMailerThread.CheckCPS']);
    end;
    error := True;
  until True;

  if not error then
  repeat
    if SD.ConnectSpeed <= 0 then Break;
    EfD := EP.DwordValueD(ACPSEfMin[SD.ActivePoll <> nil], DWORD(MaxInt));
    if EfD = DWORD(MaxInt) then Break;
    L := 0;
    if ((InCPS >= 0) and (DWORD(InCPS) * 8 * 100 < EfD * SD.ConnectSpeed)) then Inc(L);
    if ((OutCPS >= 0) and (DWORD(OutCPS) * 8 * 100 < EfD * SD.ConnectSpeed)) then Inc(L, 2);
    if L = 0 then Break;
    case L of
      1: s := Format('RX Efficiency %d%% (%d of %d BPS) is too low, should be at least %d%% (%d of %d BPS) - disconnecting', [(DWORD(InCPS) * 8 * 100) div SD.ConnectSpeed, InCPS * 8, SD.ConnectSpeed, EfD, (EfD * SD.ConnectSpeed) div 100, SD.ConnectSpeed]);
      2: s := Format('TX Efficiency %d%% (%d of %d BPS) is too low, should be at least %d%% (%d of %d BPS) - disconnecting', [(DWORD(OutCPS) * 8 * 100) div SD.ConnectSpeed, OutCPS * 8, SD.ConnectSpeed, EfD, (EfD * SD.ConnectSpeed) div 100, SD.ConnectSpeed]);
      3: s := Format('RX/TX Efficiency %d%% (%d of %d BPS) / %d%% (%d of %d BPS) is too low, should be at least %d%% (%d of %d BPS) - disconnecting', [(DWORD(InCPS) * 8 * 100) div SD.ConnectSpeed, InCPS * 8, SD.ConnectSpeed, (DWORD(OutCPS) * 8 * 100) div SD.ConnectSpeed, OutCPS * 8, SD.ConnectSpeed, EfD, (EfD * SD.ConnectSpeed) div 100, SD.ConnectSpeed]);
      else GlobalFail('%s', ['TMailerThread.CheckCPS']);
    end;
    error := True;
  until True;

  if error then
  begin
    Log(ltGlobalErr, s);
    InsertEvt(TMlrEvtChStatus.Create(msCancel));
    SD.AtomDisconnected := True;
  end;
end;


procedure TMailerThread.DoDisplayData;
var
  i: Integer;
begin
  i := 0;
  XChg(ForceDisplayData, i);
  if i = 0 then Exit;
  UpdateData;
  PostMsg(WM_UPDATEVIEW);
end;

procedure TMailerThread.DisplayData;
begin
  ForceDisplayData := 1;
end;


procedure TMailerThread.GetStationData;
begin
//  if LineId = -1 then GlobalFail('%s', ['TMailerThread.GetStationData LineId = -1']);
  CreateStation;
  {$IFDEF WS}
  if not DialupLine then
  begin
    CfgEnter;
    CopyIpStation;
    SD.LogonBanner := Cfg.IpData.Banner;
    CfgLeave;
  end else
  {$ENDIF}
  begin
    DoCopyDialupStation;
  end;
end;

procedure TMailerThread.DoCopyDialupStation;
var
  r: TStationRec;
  lL, lS: TElementColl;
begin
  CfgEnter;
  lL := Pointer(Cfg.Lines.Copy);
  lS := Pointer(Cfg.Station.Copy);
  CfgLeave;
  r := Pointer(TStationRec(lS.GetRecById(EP.DwordValueD(eiRplStation, TLineRec(lL.GetRecById(LineId)).d.StationId))).Copy);
  FreeObject(lL);
  FreeObject(lS);
  r.Data.AppendTo(SD.Station);
  r.AkaA.AppendTo(SD.AkaA);
  r.AkaB.AppendTo(SD.AkaB);
  SD.LogonBanner := r.Banner;
  FreeObject(r);
end;

function TMailerThread.CheckPasswords: Boolean;
var
  RmtPwd, RmtPwdU, s: string;
  a: TFidoAddress;
  i: Integer;
begin
  Result := False;
  RmtPwd := SD.rmtPassword;
  if (RmtPwd = cBadPwd) or (RmtPwd = cNoPwd) then
  begin
    if SD.ActivePoll = nil then LogFmt(ltWarning, 'Remote presented reserved word "%s"', [RmtPwd])
                           else Log(ltWarning, 'Remote reported password failure');
    Exit;
  end;
  RmtPwdU := UpperCase(rmtPwd);
  for i := 0 to CollMax(SD.rmtAddrs) do
  begin
    a := SD.rmtAddrs[I];
    s := GetPassword(a, EP);
    if s = '' then Continue;
    SD.locPassword := s;
    if UpperCase(s) = RmtPwdU then
    begin
      if not SD.rmtPwdAddrSet then
      begin
        SD.rmtPwdAddrSet := True;
        SD.rmtPwdAddr := a;
      end;
    end else
    begin
      if RmtPwdU = '' then Log(ltWarning, Format('Remote presented no password when "%s" required for %s', [SD.locPassword, Addr2Str(a)]))
                      else Log(ltWarning, Format('Remote presented "%s" when "%s" required for %s', [RmtPwd, SD.locPassword, Addr2Str(a)]));
      Exit;
    end;
  end;
  if SD.rmtPwdAddrSet then SD.rmtPrimaryAddr := SD.rmtPwdAddr;
  if SD.SessionKey <> 0 then
  begin
    LogFmt(ltInfo, 'Encrypted (%s) session', [Addr2Str(SD.SessionKeyAddr)]);
    SD.PasswordProtected := True;
  end else
  if SD.locPassword <> '' then
  begin
    if SD.CramMD5 then Log(ltInfo, 'Password-protected session (auth=CRAM-MD5)') else Log(ltInfo, 'Password-protected session (auth=plain)');
    SD.PasswordProtected := True;
  end else
  begin
    if RmtPwd <> '' then Log(ltWarning, Format('Remote proposes password "%s"', [RmtPwd]));
    Log(ltInfo,'Non-password session');
  end;

  if (SD.ActivePoll = nil) and (not SD.PasswordProtected) and (EP.BoolValueD(eiAccProtected, False)) then
  begin
    Log(ltWarning,'Incoming non-password sessions are forbidden by atom "Accept Nodes Only Pwd-Prot"');
    Exit;
  end;

  if (SD.ActivePoll = nil) and (not RemoteListed) and (EP.BoolValueD(eiAccListed, False)) then
  begin
    Log(ltWarning,'Incoming sessions with unlisted nodes are forbidden by atom "Accept Nodes Only Listed"');
    Exit;
  end;

  Result := True;
end;


procedure TMailerThread.LogUnexpEMSI;
begin
  LogFmt(ltWarning, 'Unexpected EMSI sequence: %s', [EMSI_Seq[seq].S]);
end;

function TMailerThread.GetTraf(sTRAF: string; Hex: Boolean): Boolean;

function V(const s: string): DWORD;
begin
  if Hex then Result := VlH(s) else Result := Vl(s);
end;

var
  s: string;
  m,f: DWORD;
begin
  Result := False;
  GetWrd(sTRAF, S, ' ');
  m := V(S); if m = INVALID_VALUE then Exit;
  f := V(sTRAF); if f = INVALID_VALUE then Exit;
  D.rmtForUs := m+f;
  if D.rmtForUs > 0 then SD.rmtTrafInfo := Format('Remote has %sb of mail and %sb of files for us', [Int2Str(m), Int2Str(f)]);
  Result := True;
end;

procedure TMailerThread.ParseEMSIData;
var
  L: TStringColl;
  EMSI: TEMSIColl;

procedure DoParse;
var
  sTRAF, sMOH, s, s2, s3, s4, spd: string;
  C: TEMSICapabilities;
  DP: TEMSICapability;
  i: Integer;
begin
  State := msEMSI_FailPkt;
  sTRAF := '';
  sMOH := '';
  S := ExtractEMSI(SD.InB);
  if EP.VoidFound(eiLogEMSI) then Log(ltEMSI, '< '+S);
  if not ParseEMSILine(S, EMSI, '}') then Exit;
  if EMSI.Count < 9 then Exit;
  S := EMSI.FingerPrint;
  if not Hex2EMSI(S) then Exit;
  if (UpperCase(S)<>'EMSI') then Exit;
  S := EMSI.AddressList;
  if not Hex2EMSI(S) then Exit;

  GetAddrs(S);

  s := EMSI.MlrName;
  s2 := EMSI.MlrProductCode;
  s3 := EMSI.MlrVersion;
  s4 := EMSI.MlrSerialNo;
  if not Hex2EMSI(s) or
     not Hex2EMSI(s2) or
     not Hex2EMSI(s3) or
     not Hex2EMSI(s4) then Exit;

//  if s = 'ifcico' then Include(SD.RemoteMailerFlags, rmfForceZRQInit);
  if s = 'Bink/+' then Include(SD.rmtMailerFlags, rmfNoFileDelay);

  SD.rmtMailerName := s;
  SD.rmtMailerCode := s2;
  SD.rmtMailerVersion := s3;
  SD.rmtMailerSerialNo := s4;
  DS.rmtSoft := Format('%s/%s/%s', [s, s3, s4]);

  while EMSI.Count > 10 do
  begin
    S := EMSI[10];
    S2 := EMSI[9];
    if not Hex2EMSI(S2) then Exit;
    case IdentEMSIAddon(S2) of
      eaIDENT:
        begin
          ParseEMSILine(S, L, ']');
          for I := MinI(5, L.Count-1) downto 0 do
          begin
            S := L[I];
            if not Hex2EMSI(S) then Exit;
            case I of
              0: DS.rmtStationName := S;
              1: DS.rmtLocation := S;
              2: DS.rmtSysOpName := S;
              3: DS.rmtPhone := S;
              4: spd := S;
              5: DS.rmtFlags := S;
            end;
          end;
          DS.rmtFlags := spd+','+DS.rmtFlags;
        end;
      eaTraf:
        sTRAF := S;
      eaMOH:
        sMOH := S;
      eaTRX:
        begin
          ParseEMSILine(S, L, ']');
          if L.Count <> 1 then Exit;
          S := L[0];
          if not Hex2EMSI(S) then Exit;
          SD.rmtTRX := VlH(S);
          if SD.rmtTRX = INVALID_VALUE then Exit;
          SD.rmtTime := uFormat(SD.rmtTRX);
        end;
      eaCustom:
        begin
          if not Hex2EMSI(S) then Exit;
          if SD.EMSI_Addons = nil then SD.EMSI_Addons := TStringColl.Create;
          SD.EMSI_Addons.Add(Format('EMSI Addon : %s %s', [S2, S]));
        end;
      else GlobalFail('IdentEMSIAddon("%s") ??', [S2]);
    end;
    EMSI.AtFree(9); EMSI.AtFree(9);
  end;

  if sTRAF <> '' then
  begin
    if not Hex2EMSI(sTRAF) then Exit;
    if not GetTraf(sTraf, True) then Exit;
  end else
  if sMOH <> '' then
  begin
    if not Hex2EMSI(sMOH) then Exit;
    D.rmtForUs := VlH(Copy(sMOH, 2, Length(sMOH)-2));
    if D.rmtForUs = INVALID_VALUE then Exit;
    if D.rmtForUs > 0 then SD.rmtTrafInfo := Format('Remote has %sb for us', [Int2Str(D.rmtForUs)]);
  end;

  S := EMSI.Password; if not Hex2EMSI(S) then Exit;
  SD.rmtPassword := S;
  S := EMSI.LinkCodes; if not Hex2EMSI(S) then Exit;
  SD.rmtUnkLinkCodes := S;
  SD.rmtLinkCodes := ParseEMSILinkCodes(SD.rmtUnkLinkCodes);
  S := EMSI.Compatibility; if not Hex2EMSI(S) then Exit;
  SD.rmtUnkCompat := S;
  SD.rmtEMSICompat := ParseEMSICapabilities(SD.rmtUnkCompat);

  if ecNRQ in SD.rmtEMSICompat then Include(SD.rmtMailerFlags, rmfNRQ) else
  if ecHFR in SD.rmtEMSICompat then Include(SD.rmtMailerFlags, rmfHFR);

  if SD.ActivePoll <> nil then
  begin
    if elPUA in SD.rmtLinkCodes then Include(SD.rmtMailerFlags, rmfPUA) else
    if elPUP in SD.rmtLinkCodes then Include(SD.rmtMailerFlags, rmfPUP) else
    if elNPU in SD.rmtLinkCodes then Include(SD.rmtMailerFlags, rmfNPU);
  end else
  begin
    if elHAT in SD.rmtLinkCodes then Include(SD.rmtMailerFlags, rmfHAT) else
    begin
      if elHXT in SD.rmtLinkCodes then Include(SD.rmtMailerFlags, rmfHXT);
      if elHRQ in SD.rmtLinkCodes then Include(SD.rmtMailerFlags, rmfHRQ);
    end;
  end;

  C := SD.rmtEMSICompat * SD.OurProtocols;

  if ecHYD in C then DP := ecHYD else
  if ecJAN in C then DP := ecJAN else
  if ecKER in C then DP := ecKER else
  if ecDZA in C then DP := ecDZA else
  if ecZAP in C then DP := ecZAP else
  if ecZMO in C then DP := ecZMO else
  if ecYMO in C then DP := ecYMO else
    DP := ecNCP;

  SD.DesiredProtocol := DP;

  State := msEMSI_parsed;
end;

begin
  L := TStringColl.Create;
  EMSI := TEMSIColl.Create;
  DoParse;
  FreeObject(EMSI);
  FreeObject(L);
end;

procedure TMailerThread.SendEMSIData(const Password: string; Cap: TEMSICapabilities);
var
    I, BP: Integer;
    B, S: String;
    CRC: Word;

  procedure Add(C: Char);
  begin
    B[BP] := C; Inc(BP);
  end;

  procedure Put(C: Char; const S: String);
    var I: Integer;
  begin
    case C of
      '{','[': begin B[BP] := C; Inc(BP); end;
      ' ',',': if (BP > 0) and not (B[BP-1] in ['}', '{', ']', '[']) then
             begin B[BP] := C; Inc(BP); end;
    end;
    for I := 1 to Length(S) do
        case S[I] of
          #0..#31, '\', '{','}', '[', ']', #127..#255:
             begin
               B[BP+0] := '\';
               B[BP+1] := rrLoHexChar[Byte(S[I]) shr 4];
               B[BP+2] := rrLoHexChar[Byte(S[I]) and 15];
               Inc(BP, 3);
             end;
          else
             begin
               B[BP] := S[I];
               Inc(BP);
             end;
        end;
    case C of
      '{': begin B[BP] := '}'; Inc(BP); end;
      '[': begin B[BP] := ']'; Inc(BP); end;
    end;
  end;

procedure PutAddon(Typ: TEMSIAddonType; C: Char; const S: string);
begin
  Put('{', SEMSIAddons[Typ]);
  Add('{');
  Put(C, S);
  Add('}');
end;

var
  LinkCodes: TEMSILinkCodes;

begin
  if not SD.AcceptReq then Include(Cap, ecNRQ);
  if SD.Station = nil then GetStationData;
  if SD.ActivePoll <> nil then SD.OutAddrs := GetOutAKAs(SD.ActivePoll.Node.Addr);
  SetLength(B, 4096); BP := 1;
  Put(#0, '**EMSI_DATxxxx');
  Put('{', 'EMSI'); Add('{');
  Put(#0, SD.OutAddrs);
  Add('}');
  Put('{', Password);

  LinkCodes := [el8N1];
//  if SD.ActivePoll <> nil then Include(LinkCodes, elPUA);

  Put('{', BuildEMSILinkCodes(LinkCodes));
  Put('{', BuildEMSICapabilities(Cap));
  Put('{', Int2Hex(mlProductCode));
  Put('{', ProductName);
  Put('{', ProductVersion);
  Put('{', '0');

  if not SD.BadPassword then
  begin
    Put('{', SEMSIAddons[eaIDENT]);
    Add('{');
    Put('[', SD.Station.Station);
    Put('[', SD.Station.Location);
    Put('[', SD.Station.Sysop);
    if SD.Station.Phone <> '' then S := SD.Station.Phone else S := '-Unpublished-';
    Put('[', S);
    S := IntToStr(SD.ConnectSpeed);
    Put('[', S);
    if SD.Station.Flags <> '' then S := SD.Station.Flags else S := 'XA';
    Put('[', S);
    Add('}');
    PutAddon(eaTRX, '[', Int2Hex(uGetLocalTime));
    if SD.ActivePoll = nil then
    begin
      if (SD.txMail>0) or (SD.txFiles>0) then
      begin
        PutAddon(eaTRAF, #0, Format('%s %s', [Int2Hex(SD.txMail), Int2Hex(SD.txFiles)]));
        PutAddon(eaMOH, '[', Int2Hex(SD.txMail+SD.txFiles));
      end;
    end;
    Put('{', 'XDATETIME');
    Add('{');
    Put('[', RFCDateStr);
    Add('}');
  end;

  S := UpperCase(Hex4(BP-15));
  Move(S[1], B[11], 4);
  CRC := CRC16USD_INIT;
  for I := 3 to BP-1 do CRC := UpdateCrc16Usd(Byte(B[I]), CRC);
  CRC := UpdateCrc16Usd(0, CRC);
  CRC := UpdateCrc16Usd(0, CRC);
  SetLength(B, BP-1);
  if EP.VoidFound(eiLogEMSI) then Log(ltEMSI, '> '+CopyLeft(B, 15));
  if (not SD.GotNak) and (SD.ActivePoll <> nil) then B := EMSI_INQ+EMSI_CR+B;
  if (SD.NiagaraAllowed) and (SD.ActivePoll <> nil) then B := EMSI_TZP+EMSI_CR+B;
  SendStr(B);
// It is recommended by FTS-56 that the inbound data buffer should
// be purged between transmission of the <data_pkt> and <crc16> fields
// to prevent accidental EMSI_NAK sequences, etc.
// But we dont beleive it's a good idea, especially over TCP/IP :-)
  B := Hex4(CRC)+EMSI_CR;
  SendStr(B);
end;

function TMailerThread.GotExtApp: Boolean;
var
  ca, cb: TStringColl;
  s: string;
  i: Integer;
  ds: TEvParDStr;
  R: TColl;
begin
  Result := False;
  if not BBSAllowed then Exit;
  ca := TStringColl.Create;
  cb := TStringColl.Create;
  CfgEnter;
  Cfg.DrsCollA.AppendTo(ca);
  Cfg.DrsCollB.AppendTo(cb);
  CfgLeave;
  R := EP.GetAtomList(eiDoor);
  for i := 0 to CollMax(R) do
  begin
    ds := R[i];
    ca.Add(ds.StrA);
    cb.Add(ds.StrB);
  end;
  FreeObject(R);
  for i := 0 to ca.Count-1 do
  begin
    s := ca[i];
    Replace('\', #27, s);
    if Pos(s, SD.InB) > 0 then
    begin
      SD.ExtAppStr := _DelSpaces(cb[i]);
      Result := True;
      Break;
    end;
  end;
  FreeObject(ca);
  FreeObject(cb);
end;

procedure TMailerThread.StartEMSI_Receiver(AState: TMailerState);
begin
  SetTmrPublic(MaxD(RemainingTimeSecs(D.TmrPublic), toEMSI_Timeout), msEMSI_Timeout);
  Log(ltInfo, 'EMSI data receive');
  SD.Tries := 0;
  SetTmr1(toEMSI_Block, msEMSI_h2);
  State := AState;
end;

procedure TMailerThread.DoHSh;

function CheckYooHooChar: Boolean;
var
  YC, I: Integer;
  C: Char;
begin
  if SD.ActivePoll = nil then C := ccYooHoo else C := ccENQ;
  Result := False;
  if SD.MayYooHoo then
  begin
    I := Pos(C, SD.InB);
    if I > 0 then
    begin
      SD.MayFTS1 := False;
      repeat
        Delete(SD.InB, 1, I);
        I := Pos(C, SD.InB);
      until I = 0;
      Inc(SD.YooHooCount);
      YC := 4;
      if not SD.MayEMSI then Dec(YC);
      if C = ccENQ then Dec(YC);
      if SD.YooHooCount >= YC then
      begin
        State := msStartYooHoo;
        Result := True;
      end;
    end;
  end;
end;

procedure ChkCR;
var
  I: Integer;
  AreCR: Boolean;
begin
  if TimerInstalled(SD.HShRLast) and (ElapsedTime(SD.HShRLast)<10) then Exit;
  NewTimer(SD.HShRLast, 0); 
  AreCR := Pos(ccCR, SD.InB) > 0;

//-- Chkeck YooHoo
  if not CheckYooHooChar then
  begin
//-- Chkeck FTS-0001
    if SD.MayFTS1 then
    begin
      I := Pos(ccTSync, SD.InB);
      if I > 0 then
      begin
        repeat
          Delete(SD.InB, 1, I);
          I := Pos(ccTSync, SD.InB);
        until I = 0;
        Inc(SD.FTS1Count);
        if SD.FTS1Count = 3 then
        begin
          State := msStartFTS1;
          Exit;
        end;
      end;
    end;
  end;

  if AreCR then
  begin
    I := Pos(ccCR, SD.InB);
    if I > 0 then
    begin
      repeat
        Delete(SD.InB, 1, I);
        I := Pos(ccCR, SD.InB);
      until I = 0;
    end;
    SendStr(__EMSI_REQ);
  end;

end;

var
  seq: TEMSIseq;

procedure SUnExp;
begin
  LogUnexpEMSI(seq);
  State := msHSh_swz;
end;

procedure RUnExp;
begin
  LogUnexpEMSI(seq);
  State := msHSh_r2z;
end;


const
  cHSh_S_Tries = 4;

var
  FCP: TPort;
  sc: TStringColl;
  dw: DWORD;
  s: string;
  L: TColl;
  eg: TEvParGrid;
  i: Integer;
begin

//===  Hanshake  ( Sender )  ===//
  case State of
    msHSh_s1:
      begin
        SD.Tries := cHSh_S_Tries;
        L := EP.GetAtomList(eiLoginScript);
        State := msHSh_s1c;
        if L <> nil then
        begin
          for i := 0 to L.Count-1 do
          begin
            eg := L[i];
            if MatchMaskAddressListSingle(SD.ActivePoll.Node.Addr, eg.s) then
            begin
              SD.LoginScript := eg.L.Copy;
              Break;
            end;
          end;
          FreeObject(L);
        end;


        if (SD.LoginScript = nil) or (TStringColl(SD.LoginScript[0]).Count <= 0) then
        begin
          State := msHSh_s1c;
        end else
        begin
          State := msHSh_Login_1;
        end;
      end;
    msHSh_Login_1:
      begin
        sc := SD.LoginScript[0];
        SendModemString(sc[SD.LoginStep]);
        State := msHSh_Login_2;
      end;

    msHSh_Login_2:
      begin
        sc := SD.LoginScript[1];
        FreeObject(SD.LoginWdREs);
        SD.LoginWdREs := TColl.Create;
        SD.LoginWdREs.Add(TReLoginHolder.Create(sc[SD.LoginStep], Self));
        sc := SD.LoginScript[2];
        dw := Vl(sc[SD.LoginStep]);
        SetTmr1(dw, msHSh_Login_4);
        State := msHSh_Login_3;
      end;

    msHSh_Login_2_matched:
      begin
        FreeObject(SD.LoginWdREs);
        sc := SD.LoginScript[3];
        Inc(SD.LoginStep);
        if SD.LoginStep >= sc.Count then State := msHSh_s1c else State := msHSh_Login_1;
      end;

    msHSh_Login_3:
      begin
      end;

    msHSh_Login_4:
      begin
        // timeout
        sc := SD.LoginScript[3];
        s := sc[SD.LoginStep];
        if s = '' then
        begin
          if SD.LoginStep > 0 then Dec(SD.LoginStep);
          State := msHSh_Login_1;
        end else
        begin
          SendModemString(s);
          State := msHSh_Login_2;
        end;
      end;

    msHSh_s1c:
      begin
        SetTmr1(toEMSI_CR, msHSh_s1t);
        if SD.MayEMSI then SendStr(EMSI_CR) else
        if SD.MayYooHoo then SendStr(ccYooHoo);
        State := msHSh_sw;
      end;
    msHSh_swz:
      State := msHSh_sw;
    msHSh_sw:
      begin
        seq := IdentEMSISeq(SD.InB);
        case seq of
          es_None:
            begin
              if not (TimerInstalled(SD.HShRLast) and (ElapsedTime(SD.HShRLast)>=10)) then
              begin
                NewTimer(SD.HShRLast, 0);
                CheckYooHooChar;
              end;
            end;
          es_REQ: if SD.MayEMSI then State := msEMSI_c1z else SUnExp;
          es_PZT: if SD.NiagaraAllowed then State := msHSh_TCP else SUnExp;
          else SUnExp;
        end;
      end;
    msHSh_s1t:
      begin
        Dec(SD.Tries);
        if SD.Tries < 0 then
        begin
          SD.Tries := 0;
          NewTimer(SD.HShRLast, 0);
          State := msHSh_s3;
        end else
        begin
          State := msHSh_s1c;
        end;
      end;
    msHSh_s3:
      begin
        if SD.MayEMSI then SetTmr1(toEMSI_S3, msHSh_s3) else SetTmr1(toEMSI_CR, msHSh_s3);
        State := msHSh_s3c;
      end;
    msHSh_s3c:
      begin
        if SD.MayEMSI then State := msHSh_sES else State := msHSh_sYh;
      end;
    msHSh_sES:
      begin
        // Some dial-up servers may need a pause after sending a user name followed by CR
        // 200 msecs should be sufficient
        SendStr(EMSI_INQ+EMSI_CR);
        SetTmr1Msec(200, msHSh_sES2);
        State := msHSh_sw;
      end;
    msHSh_sES2:
      begin
        // send EMSI_INQ once more, also take a 200-msecs pause
        SendStr(EMSI_INQ+EMSI_CR);
        SetTmr1Msec(200, msHSh_sYh);
        State := msHSh_sw;
      end;
     msHSh_sYh:
      begin
        if SD.MayYooHoo then SendStr(ccYooHoo+ccYooHoo);
        State := msHSh_sw;
      end;

//===  Handshake  ( Receiver )  ===//
    msHSh_r1:
      begin
        ClearTmr1;
        SendStr(__EMSI_REQ);
        if SD.Station = nil then GetStationData;
        SendStr(SD.LogonBanner);
        State := msHSh_r2;
      end;
    msHSh_r2z:
      State := msHSh_r2;
    msHSh_r2:
      begin
        seq := IdentEMSISeq(SD.InB);
        if seq = es_None then
        begin
          if GotExtApp then State := msExtApp_0 else ChkCR;
        end else
        begin
          if SD.MayEMSI then
          begin
            SD.MayFTS1 := False;
            SD.MayYooHoo := False;
          end;
          case seq of
            es_TZP: if SD.NiagaraAllowed then State := msHSh_TCP else RUnExp;
            es_INQ,
            es_DATerror : if SD.MayEMSI then StartEMSI_Receiver(msEMSI_h2) else RUnExp;
            es_DAT: begin SD.NiagaraAllowed := False; StartEMSI_Receiver(msEMSI_h5) end;
            else RUnExp;
          end;
        end;
      end;
    msHSh_TCP:
      begin
        if SD.Station = nil then GetStationData;
        ProtCore := ptBinkP;
        FCP := AddNiagara(CP, SD.ActivePoll <> nil);
        EnterCS(CP_CS);
        CP := FCP;
        LeaveCS(CP_CS);
        SD.NiagaraSession := True;
        State := msStartWZ;
      end;
    else GlobalFail('%s', ['TMailerThread.DoHSh UnkState']);
  end;
end;

procedure TMailerThread.LogEMSIData;
const
  CNone = Pointer($FFFFFFFF);
var
  i: Integer;
  Node: TFidoNode;

function ObtainNode: Boolean;
begin
  if Node = nil then Result := False else
  begin
    if Node = CNone then
    begin
      Node := GetListedNode(SD.rmtPrimaryAddr);
      if Node <> nil then Log(ltEMSI, 'Displaying info from the nodelist');
    end;
    Result := Node <> nil;
  end;
end;

begin
  if SD.EMSI_Logged then Exit;

  SD.EMSI_Logged := True;
  SD.NeedModemStatx := True;

  Node := CNone;


  if (not SD.rmtPrimaryAddrSet) and (SD.ActivePoll <> nil) then
  begin
    SD.rmtPrimaryAddrSet := True;
    SD.rmtPrimaryAddr := SD.ActivePoll.Node.Addr;
    if SD.rmtAddrs = nil then SD.rmtAddrs := TFidoAddrColl.Create;
    SD.rmtAddrs.Add(SD.ActivePoll.Node.Addr);
    DS.rmtAddressList := Addr2Str(SD.rmtPrimaryAddr);
  end;

  if SD.rmtPrimaryAddrSet then
  begin
    if (DS.rmtStationName = '') and ObtainNode then DS.rmtStationName := Node.Station;
    if (DS.rmtSysopName = '') and ObtainNode then DS.rmtSysopName := Node.Sysop;
    if (DS.rmtLocation = '') and ObtainNode then DS.rmtLocation := Node.Location;
    if (DS.rmtPhone = '') and ObtainNode then DS.rmtPhone := Node.Phone;
    if (DS.rmtFlags = '') and ObtainNode then DS.rmtFlags := Node.Flags;
  end;

  if (SD.SessionCore = scEmsiWz) or (DS.rmtStationName <> '') then
  Log(ltEMSI,   '   Station : '+DS.rmtStationName);
  if (SD.SessionCore = scEmsiWz) or (DS.rmtAddressList <> '') then
  Log(ltEMSI,   '   Address : '+DS.rmtAddressList);
  if (SD.SessionCore = scEmsiWz) or ((DS.rmtSysOpName <> '') and (DS.rmtLocation <> '')) then
  Log(ltEMSI_1, Format(
                '     SysOp : %s from %s', [DS.rmtSysOpName, DS.rmtLocation]));
  if (SD.SessionCore = scEmsiWz) or (DS.rmtPhone <> '') then
  Log(ltEMSI_1, '    Number : '+DS.rmtPhone);
  if (SD.SessionCore = scEmsiWz) or (DS.rmtFlags <> '') then
  Log(ltEMSI_1, Format(
                '     Flags : %s', [DS.rmtFlags]));
  if (SD.SessionCore = scEmsiWz) or (DS.rmtSoft<> '') then
  Log(ltEMSI_1, '    Mailer : '+DS.rmtSoft);
  if SD.EMSI_Addons <> nil then
  begin
    for i := 0 to SD.EMSI_Addons.Count-1 do Log(ltEMSI_1, SD.EMSI_Addons[i]);
    FreeObject(SD.EMSI_Addons);
  end;
  if SD.rmtTime <> '' then LogFmt(ltEMSI, '      Time : %s', [SD.rmtTime]);
  LogTrafInfo;
  if SD.PostEMSILogErrors <> nil then
  begin
    for i := 0 to SD.PostEMSILogErrors.Count-1 do
    begin
      Log(ltGlobalErr, SD.PostEMSILogErrors[i]);
    end;
    FreeObject(SD.PostEMSILogErrors);
  end;
end;

procedure TMailerThread.LogConnect;
begin
  Log(ltConnect, 'CONNECT '+DS.ConnectString);
end;

procedure TMailerThread.FilterProtocols(const AFlags: string);

  procedure eDZA; begin Exclude(SD.OurProtocols, ecDZA) end;
  procedure eZAP; begin Exclude(SD.OurProtocols, ecZAP) end;
  procedure eZMO; begin Exclude(SD.OurProtocols, ecZMO) end;

var
  s, z: string;
begin
  s := AFlags;
  while s <> '' do
  begin
    GetWrd(s, z, ','); z:= UpperCase(z);
    if (z = 'NOHYD') then Exclude(SD.OurProtocols, ecHYD) else
    if (z = 'NOZM' ) then begin eDZA; eZAP; eZMO; end else
    if (z = 'NODZA') then begin eDZA;             end else
    if (z = 'NOZAP') then begin       eZAP;       end else
    if (z = 'NOZMO') then begin             eZMO; end else
    if (z = 'NONIAGARA') then SD.NiagaraAllowed := False else
    if (z = 'NOEMSI') then SD.MayEMSI := False else
    if (z = 'NOYOOHOO') then SD.MayYooHoo := False else
    if (z = 'NODUMMYZ') then SD.DummyZFrb := True;
  end;
end;

function TMailerThread.DoConnectStart: Boolean;
const
  eiNiagara: array[Boolean] of Integer = (eiAccNoNiagara, eiTrsNoNiagara);
  eiEMSI:    array[Boolean] of Integer = (eiAccNoEMSI, eiTrsNoEMSI);
  eiYooHoo:  array[Boolean] of Integer = (eiAccNoYooHoo, eiTrsNoYooHoo);
  eiHydra:   array[Boolean] of Integer = (eiAccNoHydra,   eiTrsNoHydra);
  eiZModem:  array[Boolean] of Integer = (eiAccNoZModem,  eiTrsNoZModem);
  eiDummyZ:  array[Boolean] of Integer = (eiAccNoDummyZ,  eiTrsNoDummyZ);
var
  OutPoll: Boolean;
begin
  Result := True;
  OutPoll := SD.ActivePoll <> nil;
  SD.ConnectStart := uGetSystemTime;
  LogConnect;
  CfgEnter;
  SD.AcceptReq := not (foDisable in Cfg.FreqData.Options);
  CfgLeave;
  SD.AcceptReq := SD.AcceptReq and (not EP.VoidFound(eiAccNoFreqs));
  SD.OutFiles := TOutFileColl.Create;
  SD.SentFiles := TOutFileColl.Create;
  if OutPoll then SetSessionKey(SD.ActivePoll.Node.Addr);

  if ProtCore <> ptBinkP then
  begin
    if SD.SessionKey = 0 then
    begin
      SD.MayEMSI := True;
      SD.MayYooHoo := True;
      SD.NiagaraAllowed := True;
      SD.OurProtocols := ecOurProtocols;
      if EP.VoidFound(eiHydra[OutPoll]) then Exclude(SD.OurProtocols, ecHYD);
      if EP.VoidFound(eiZmodem[OutPoll]) then
      begin
        Exclude(SD.OurProtocols, ecDZA);
        Exclude(SD.OurProtocols, ecZAP);
        Exclude(SD.OurProtocols, ecZMO);
      end;
      if EP.VoidFound(eiDummyZ[OutPoll]) then SD.DummyZFrb := True;
      if OutPoll then
      begin
        FilterProtocols(SD.ActivePoll.Flags({$IFDEF WS}DialupLine{$ELSE}True{$ENDIF}));
      end else
      begin
        SD.MayFTS1 := not EP.VoidFound(eiAccNoFTS1);
      end;
      SD.NiagaraAllowed := SD.NiagaraAllowed and ({$IFDEF WS}(DialupLine) and {$ENDIF} (not EP.VoidFound(eiNiagara[OutPoll])));
      SD.MayEMSI := SD.MayEMSI and (not EP.VoidFound(eiEMSI[OutPoll]));
      SD.MayYooHoo := SD.MayYooHoo and (not EP.VoidFound(eiYooHoo[OutPoll]));
    end else
    begin
      {$IFDEF WS}
      if not DialupLine then
      begin
        Result := False;
        LogFmt(ltGlobalErr, 'Failed to initiate encrypted session with %s', [Addr2Str(SD.ActivePoll.Node.Addr)]);
        Log(ltWarning, 'Encrypted sessions are possible on BinkP only');
        State := msSE_SessionAborted;
      end else
      {$ENDIF}
      begin
        SD.NiagaraAllowed := True;
        SD.OurProtocols := [];
      end;
    end;
  end;
end;

procedure TMailerThread.LogTrafInfo;
begin
  if SD.rmtTrafInfo = '' then Exit;
  Log(ltInfo, SD.rmtTrafInfo);
  SD.rmtTrafInfo := '';
end;


function TMailerThread.LockAKAs: Boolean;
var
  i, j: Integer;
  a: TFidoAddress;
begin
  Result := True;
  j := CollMax(SD.rmtAddrs);
  if j = -1 then
  begin
    Result := False;
    Exit;
  end;
  for i := j downto 0 do
  begin
    a := SD.rmtAddrs[i];
    if (SD.ActivePoll <> nil) and (CompareAddrs(SD.ActivePoll.Node.Addr, a)=0) then Continue;
    if not LockAddr(a) then
    begin
      Log(ltWarning, Format('Address %s is busy - removed from AKA list', [Addr2Str(a)]));
      SD.rmtAddrs.AtFree(i);
    end;
  end;
  if CollCount(SD.rmtAddrs) = 0 then
  begin
    Log(ltWarning, 'All AKAs are busy - disconnecting');
    FreeObject(SD.rmtAddrs);
    Result := False;
  end;
end;

procedure TMailerThread.CommonStatx;
var
  c: TCommonStatx;
  t: Integer;
  Actually: DWORD;
begin
  if not SD.rmtPrimaryAddrSet then Exit;
  t := 0;
  if SD.ActivePoll = nil then t := t or cstIncoming else t := t or cstOutgoing;
  if SD.SessionOK then t := t or cstSuccessful;
  if SD.PasswordProtected then t := t or cstProtected;
  {$IFDEF IP}
  if not SD.Dialup then t := t or cstIP;
  {$ENDIF}
  c.Typ   := t;
  c.Zone  := SD.rmtPrimaryAddr.Zone;
  c.Net   := SD.rmtPrimaryAddr.Net;
  c.Node  := SD.rmtPrimaryAddr.Node;
  c.Point := SD.rmtPrimaryAddr.Point;
  c.TimeBeg := SD.SessionStart;
  c.TimeLen := uGetSystemTime - SD.SessionStart;
  c.BytesRcv := SD.cRxBytes;
  c.BytesSnt := SD.cTxBytes;
  c.FilesRcv := SD.FilesReceived;
  c.FilesSnt := SD.FilesSent;
  EnterCS(CommonStatxCS);
  if _LogOK(CommonStatxFName, CommonStatxHandle) then
  begin
    WriteFile(CommonStatxHandle, c, SizeOf(c), Actually, nil);
    if StartupOptions and stoFastLog = 0 then ZeroHandle(CommonStatxHandle);
  end;
  LeaveCS(CommonStatxCS);
end;



procedure TMailerThread.DoWZ;

procedure BatchStart;
begin
  if (SD.OutFiles.Count = 0) and
     (CollMax(SD.RmtAddrs) >= 0) and
     (SD.SessionCore <> scFTS1) then ScanOut;
end;

function _CreateProtocol(Typ: TProtocolType): TBaseProtocol;
var
  IsZModem: Boolean;
begin
  Result := CreateTransferProtocol(Typ, CP, SD.rmtMailerFlags, IsZModem);
  if not IsZModem then Exit;
  if SD.DummyZFrb then Exit;
  SD.SendDummyPkt := True;
end;

procedure CheckYooHooPkt;
var
  I: Integer;
  crc: Word;
  SendEnq: Boolean;
  c: Char;
begin
  SendEnq := False;
  while SD.InB <> '' do
  begin
    c := SD.InB[1];
    if c = ccYooHooHdr then Break else
    begin
      if c = ccYooHoo then SendEnq := True;
      Delete(SD.InB, 1, 1);
    end;
  end;

  while (Length(SD.InB) > 128+2) and (SD.InB[1] = ccYooHooHdr) do Delete(SD.InB, 1, 1);

  if Length(SD.InB) < 128+2{CRC} then
  begin
    if SendEnq then CP.SendString(ccENQ);
    Exit;
  end;

  crc := CRC16USD_INIT;
  for i := 1 to 130 do crc := UpdateCrc16Usd(Byte(SD.InB[i]), crc);
  crc := UpdateCrc16Usd(0, crc);
  crc := UpdateCrc16Usd(0, crc);
  if crc = CRC16USD_TEST then
  begin
    SD.YooHooPkt := TYooHooPacket.Create;
    Move(SD.InB[1], SD.YooHooPkt.d, 128);
  end;
  if crc <> CRC16USD_TEST then
  begin
    SD.InB := '';
    CP.SendString('?');
  end else
  begin
    Delete(SD.InB, 1, 130);
    State := msParseYooHoo;
    CP.SendString(ccACK);
  end;
end;

function ParseYooHooPkt: Boolean;
var
  Addr: TFidoAddress;
  DP: TEMSICapability;
  i: Integer;
begin
  Result := False;
  if SD.YooHooPkt.d.signal <> $6F then Exit;

  SD.rmtMailerVersion := Format('%d.%d', [SD.YooHooPkt.d.product_maj, SD.YooHooPkt.d.product_min]);
  DS.rmtStationName := ShortBuf2Str(SD.YooHooPkt.d.my_name, 60);
  DS.rmtSysopName := ShortBuf2Str(SD.YooHooPkt.d.sysop, 20);
  SD.rmtPassword := ShortBuf2Str(SD.YooHooPkt.d.my_password, 8);
  i := SD.YooHooPkt.d.product;
  SD.rmtMailerCode := Int2Hex(i);
  if (i <= MaxProductCode) and (i >= 0) then SD.rmtMailerName := SProdCodes[i] else SD.rmtMailerName := SD.rmtMailerCode;
  DS.rmtSoft := Format('%s/%s', [SD.rmtMailerName, SD.rmtMailerVersion]);

  Addr.Zone  := SD.YooHooPkt.d.my_zone;
  Addr.Net   := SD.YooHooPkt.d.my_net;
  Addr.Node  := SD.YooHooPkt.d.my_node;
  Addr.Point := SD.YooHooPkt.d.my_point;
  if not ChkAddrStr(Addr2Str(Addr)) then Exit;
  if not ChkNonEmsiPwd(nil) then Exit;
  if SD.BadPassword then Exit;

  if SD.YooHooPkt.d.hello_version <> 1 then Exit;

  i := SD.YooHooPkt.d.capabilities;
  if (i and yhDOES_Hydra <> 0) and (ecHYD in SD.OurProtocols) then DP := ecHYD else
  if (i and yhZED_ZAPPER <> 0) and (ecZAP in SD.OurProtocols) then DP := ecZAP else
  if (i and yhZED_ZIPPER <> 0) and (ecZMO in SD.OurProtocols) then DP := ecZMO else
    DP := ecNCP;

  SD.DesiredProtocol := DP;
  SD.SessionCore := scEmsiWz;
  LogEMSIData;
  Result := True;
end;

procedure SendYooHooPkt;

function BuildPkt(var Pkt: TYooHooPacketData): Boolean;
var
  Password: string;
  s, z: string;
  a: TFidoAddress;
  OurProts: TEMSICapabilities;
  i: Integer;
  D: DWORD;
begin
  Result := False;
  ClearTmr1;
  Log(ltInfo, 'Building YooHoo packet');
  FillChar(Pkt, SizeOf(Pkt), 0);
  Pkt.Signal := $6f;
  Pkt.Hello_Version := 1;
  Pkt.Product := mlProductCode;
  Pkt.Product_Maj := CProductMajorVersion;
  Pkt.Product_Min := CProductMinorVersion;

  if SD.Station = nil then GetStationData;
  if SD.ActivePoll <> nil then Password := GetPassword(SD.ActivePoll.Node.Addr, EP) else Password := SD.locPassword;
  if SD.ActivePoll <> nil then SD.OutAddrs := GetOutAKAs(SD.ActivePoll.Node.Addr) else SD.OutAddrs := GetInAKAs;
  s := SD.OutAddrs;
  GetWrd(s, z, ' ');
  if not ParseAddress(z, a) then Exit;
  Pkt.My_Zone  := a.Zone;
  Pkt.My_Net   := a.Net ;
  Pkt.My_Node  := a.Node;
  Pkt.My_Point := a.Point;

  D := MinD(8, Length(Password)); if D > 0 then Move(Password[1], Pkt.My_Password, D);
  D := MinD(20, Length(SD.Station.Sysop)); if D > 0 then Move(SD.Station.Sysop[1], Pkt.SysOp, D);
  if SD.ActivePoll = nil then OurProts := [SD.DesiredProtocol] * SD.OurProtocols else OurProts := SD.OurProtocols;
  i := yhWZ_FREQ;
  if ecHYD in OurProts then i := i or yhDOES_Hydra;
  if ecZAP in OurProts then i := i or yhZED_ZAPPER;
  if ecZMO in OurProts then i := i or yhZED_ZIPPER;
  Pkt.Capabilities := i;
  Result := False;
end;

procedure DoSendPkt(const Pkt: TYooHooPacketData);
var
  crc: Word;
  i: Integer;
  s: string;
begin
  CP.SendString(ccYooHooHdr);
  CRC := CRC16USD_INIT;
  for I := 0 to 127 do
  begin
    crc := UpdateCrc16Usd(PxByteArray(@pkt)^[i], crc);
  end;
  crc := UpdateCrc16Usd(0, CRC);
  crc := UpdateCrc16Usd(0, CRC);
  SetLength(s, 128);
  Move(Pkt, s[1], 128);
  CP.SendString(s);
  CP.SendString(Char(Hi(CRC)));
  CP.SendString(Char(Lo(CRC)));
end;

begin
  if SD.YooHooPkt = nil then SD.YooHooPkt := TYooHooPacket.Create;
  if SD.YooHooPkt.outd.Signal = 0 then
  begin
    if BuildPkt(SD.YooHooPkt.outd) then
    begin
      State := msFinishWZ;
      Exit;
    end;
  end;
  DoSendPkt(SD.YooHooPkt.OutD);
  Log(ltInfo, 'YooHoo packet sent');
end;

procedure CheckYooHooAck;
var
  c: Char;
begin
  while SD.InB <> '' do
  begin
    c := SD.InB[1];
    case c of
      ccACK:
        begin
          Log(ltInfo, 'YooHoo - got ACK');
          if SD.ActivePoll = nil then State := msStartWZ else
          begin
            SD.InB := '';
            if SD.YooHooAcked then State := msStartWZ else
            begin
              SD.YooHooAcked := True;
              State := msWaitYooHooPkt;
            end;
          end;
          Exit;
        end;
      '?':
        begin
          State := msSendYooHoo;
          Exit;
        end;
    end;
    Delete(SD.InB, 1, 1);
  end;
end;

procedure CheckYooHooEnq;
var
  c: Char;
begin
  while SD.InB <> '' do
  begin
    c := SD.InB[1];
    if c = ccENQ then
    begin
      Log(ltInfo, 'YooHoo - got ENQ');
      SD.InB := '';
      State := msSendYooHoo;
      Exit;
    end;
    Delete(SD.InB, 1, 1);
  end;
end;


procedure CheckTrsCram;
var
  s: string;
begin
  s := EP.StrValue(eiTrsNoCram);
  if s = '' then Exit;
  if MatchMaskAddressListSingle(SD.ActivePoll.Node.Addr, s) then SD.Prot.CramDisabled := True;
end;

begin
  case State of
    msStartBinkP:
      begin
        SD.DesiredProtocol := ecBND;
        CreateStation;
        {$IFDEF WS}
        if not DialupLine then
        begin
          CfgEnter;
          CopyIpStation;
          CfgLeave;
        end else
        {$ENDIF}
        begin
          DoCopyDialupStation;
        end;
        if DoConnectStart then
        begin
          SD.SessionStart := uGetSystemTime;
          SD.rmtMailerFlags := [rmfHFR];
          State := msStartWZ;
        end;  
      end;
    msStartYooHoo:
      if SD.ActivePoll = nil then
      begin
        SD.InB := '';
        CP.SendString(ccENQ);
        State := msWaitYooHooPkt;
        Log(ltInfo, 'YooHooStart (receiver)');
      end else
      begin
        State := msSendYooHoo;
        Log(ltInfo, 'YooHooStart (sender)');
      end;
    msSendYooHoo:
      begin
        ClearTmr1;
        SD.InB := '';
        State := msWaitYooHooAck;
        SendYooHooPkt;
      end;
    msInitYooHoo:
      begin
        SetTmr1(5, msInitYooHoo);
        CP.SendString(ccYooHoo);
        State := msWaitYooHooEnq;
      end;
    msWaitYooHooAck:
      CheckYooHooAck;
    msWaitYooHooEnq:
      CheckYooHooEnq;
    msWaitYooHooPkt:
      begin
        ClearTmr1;
        CheckYooHooPkt;
      end;
    msParseYooHoo:
      if not ParseYooHooPkt then
      begin
        Log(ltWarning, 'Invalid YooHoo packed');
        State := msFinishWZ;
      end else
      begin
        if SD.ActivePoll <> nil then State := msStartWZ else State := msInitYooHoo;
      end;
    msStartFTS1:
      begin
        SD.FTS1NeedRmtAddr := True;
        SD.SessionCore := scFTS1;
        State := msStartWZ;
      end;
    msStartWZ:
      begin
        SD.SessionOK := False;
        SD.Accumulate := False;
        Priority := tpNormal;
        SD.SessionStart := uGetSystemTime;
        if ProtCore = ptBinkP then SD.SessionCore := scBinkP else 
        begin
          LogHandshakeStart;
          TDevicePort(CP).SetHoldStr(SD.InB);
          SD.InB := '';
        end;
        SD.StateDeltaDCD := msNone;
        ClearTmrPublic;
        ClearTmr1;
        case SD.SessionCore of
          scBinkP: SD.Prot := _CreateProtocol(piBinkP);
          scFTS1: SD.Prot := _CreateProtocol(piFTS1);
          scEmsiWz:
          case SD.DesiredProtocol of
            ecHYD : SD.Prot := _CreateProtocol(piHydra);
            ecZMO : SD.Prot := _CreateProtocol(piZModem);
            ecZAP : SD.Prot := _CreateProtocol(piZModem8K);
            ecDZA : SD.Prot := _CreateProtocol(piZModem8KD);
            else
            begin
              Log(ltGlobalErr, 'No compatible protocols - disconnecting');
              State := msFinishWZ;
            end;
          end;
        end;
        if SD.Prot = nil then State := msFinishWZ else
        begin
          LogFmt(ltInfo, 'Establishing %s transfer protocol', [SD.Prot.Name]);
          if SD.SessionCore = scBinkP then
          begin
            {$IFDEF WS}
            if not DialupLine then SD.Prot.BinkPTimeout := 360 else
            {$ENDIF}
              SD.Prot.BinkPTimeout := 60;
          end;
          if SD.Prot.IsBiDir then State := msBiDirStartBatch1 else
          begin
            if SD.ActivePoll <> nil then State := msOneWayStartTxBatch1
                                    else State := msOneWayStartRxBatch2;
          end;
          SD.Prot.FLogFile := LogFile;
          SD.Prot.Speed := SD.ConnectSpeed;
          SD.Prot.Station := SD.Station;
          SD.Prot.Originator := SD.ActivePoll <> nil;
          DisplayData;
          if SD.ActivePoll = nil then
          begin
            if EP.VoidFound(eiAccNoCram) then SD.Prot.CramDisabled := True;
          end else
          begin
            CheckTrsCram;
          end;
        end;
      end;
    msFinishWZ:
      begin
        CommonStatx;
        if SD.SessionCore <> scEmsiWz then LogEMSIData;
        PostMsgP(WM_CLEARTERMS, Self);
        if (not SD.SessionOK) and (SD.Prot <> nil) then Log(ltInfo, SProtocolError[SD.Prot.ProtocolError]);
        FreeObject(SD.Prot);
        {$IFDEF WS}
        if DialupLine then
        {$ENDIF}
        Priority := tpLower;
        if SD.SessionOK then State := msSE_OK else
        begin
          State := msSE_SessionAborted;
          if (not SD.EMSI_Logged) and (NoAnyValidAddrs) then State := ms_NoValidAddr else
          if ((SD.ActivePoll <> nil) and not ValidConnection) then State := ms_WrongOutDial;
        end;
      end;
    msWZOK:
      begin
        SD.SessionOK := True;
        State := msFinishWZ;
      end;
    msOneWayStartTxBatch1,
    msOneWayStartTxBatch3:
      begin
        BatchStart;
        SD.Prot.Start(nil, nil, GetNextFile, FinishSend);
        State := Succ(State);
      end;
    msOneWayStartRxBatch2:
      begin
        BatchStart;
        SD.Prot.Start(AcceptFile, FinishRece, nil, nil);
        State := Succ(State);
      end;
    msBiDirStartBatch1,
    msBiDirStartBatch2:
      begin
        BatchStart;
        SD.Prot.Start(AcceptFile, FinishRece, GetNextFile, FinishSend);
        State := Succ(State);
      end;
    msOneWayTxBatch1,
    msOneWayRxBatch2,
    msOneWayTxBatch3,
    msBiDirBatch1,
    msBiDirBatch2:
      begin
         // protocol checks for an abort by local console (Prot.CancelRequested)
         // and carrier (CP.DCD)
        if SD.FileRefuse then begin SD.Prot.FileRefuse := True; SD.FileRefuse := False end;
        if SD.FileSkip then begin SD.Prot.FileSkip := True; SD.FileSkip := False end;
        if SD.Prot.NextStep then
        begin
          if SD.Prot.ProtocolError <> ecOK then State := msFinishWZ else
          begin
            if ProtCore = ptBinkP then State := msWZOK else
            case State of
              msOneWayRxBatch2: if SD.ActivePoll <> nil then State := msWZOK;
              msOneWayTxBatch3: if SD.ActivePoll = nil then State := msWZOK else GlobalFail('%s', ['Batch  765 ???']);
              msBiDirBatch2: State := msWZOK;
            end;
            if State <> msWZOK then
            begin
              State := Succ(State);
              Inc(SD.Prot.BatchNo);
            end;
          end;
        end;

      end;
    else GlobalFail('%s', ['TMailerThread.DoWZ ??']);
  end;
end;



function TMailerThread.ValidConnection: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to CollMax(SD.rmtAddrs) do if CompareAddrs(SD.rmtAddrs[i], SD.ActivePoll.Node.Addr) = 0 then
  begin
    Result := True;
    Exit;
  end;
end;

procedure TMailerThread.DoEMSI;
var
  seq: TEMSISeq;

procedure UnExpC4Q;
begin
  LogUnexpEMSI(seq);
  if TimerExpired(SD.AuxTmr) then
  begin
    NewTimerSecs(SD.AuxTmr, 5);
    State := msEMSI_c2
  end else
  begin
    State := msEMSI_c4_;
  end;
end;


procedure UnExpH4;
begin
  LogUnexpEMSI(seq);
  State := msEMSI_h4z;
end;



begin
//=== EMSI handshake - receive ===//
  case State of
    msEMSI_h2:
      begin
        Inc(SD.Tries);
        if SD.Tries > 6 then State := msEMSI_FailTries;
        if SD.ActivePoll <> nil then
        begin
          if SD.Tries > 1 then
          begin
            LogFmt(ltWarning, 'EMSI retry %d', [SD.Tries-1]);
            SendStr(EMSI_NAK+EMSI_CR);
            State := msEMSI_h3;
          end else State := msEMSI_h4;
        end else
        begin
          if SD.Tries > 1 then Log(ltWarning, 'EMSI retry');
          SendStr(EMSI_REQ + EMSI_CR);
          State := msEMSI_h3;
        end;
      end;
    msEMSI_h3:
      begin
        SetTmr1(toEMSI_Block, msEMSI_h2);
        State := msEMSI_h4;
      end;
    msEMSI_h4z:
      State := msEMSI_h4;
    msEMSI_h4:
      begin
        seq := IdentEMSISeq(SD.InB);
        case seq of
          es_None: ;
          es_TZP : if (SD.NiagaraAllowed) and (SD.ActivePoll = nil) then State := msHSh_TCP else UnExpH4;
          es_PZT : if (SD.NiagaraAllowed) and (SD.ActivePoll <> nil) then State := msHSh_TCP else UnExpH4;
          es_DATerror:  begin SD.NiagaraAllowed := False; State := msEMSI_h2 end;
          es_HBT:       State := msEMSI_h3;
          es_DAT:       begin SD.NiagaraAllowed := False; State := msEMSI_h5 end;
          es_ACK:       begin SD.NiagaraAllowed := False; State := msEMSI_h4z end;
          es_INQ:       State := msEMSI_h4z;
          else UnExpH4;
        end;
     end;
    msEMSI_h5:
      begin
        ClearTmr1;
        SendStr(EMSI_ACK+EMSI_ACK+EMSI_CR);
        ParseEMSIData;
      end;
    msEMSI_parsed:
      begin
        LogEMSIData;
        if NoAnyValidAddrs then State := ms_NoValidAddr else State := msEMSI_h5_0;
      end;
    msEMSI_h5_0:
      if (SD.ActivePoll = nil) or (ValidConnection) then State := msEMSI_h5a else State := ms_WrongOutDial;
    msEMSI_h5a:
      if (SD.rmtPassword = cBadPwd) or (SD.rmtPassword = cNoPwd) then
      begin
        if SD.ActivePoll = nil then LogFmt(ltWarning, 'Remote presented reserved word "%s"', [SD.rmtPassword])
                            else Log(ltWarning, 'Remote reported password failure');
        State := msEMSI_PswVio;
      end else
      begin
        State := msEMSI_h5b
      end;
    msEMSI_h5b:
      begin
        if SD.ActivePoll = nil then SD.OutAddrs := GetInAKAs;
        SD.BadPassword := (not ValidEncryptedAKAs) or (not CheckPasswords);
        if LockAKAs then
        begin
          if SD.ActivePoll = nil then State := msEMSI_h5calc else State := msStartWZ;
        end else
        begin
          State := msSE_SessionAborted;
        end;
      end;
    msEMSI_h5calc:
      begin
        ScanOut;
        State := msEMSI_c1;
      end;

//=== EMSI handshake - send ===//

    msEMSI_c1z:
      begin
        ClearTimer(SD.HShRLast);

        SendStr(EMSI_INQ+EMSI_CR);

        if SD.NiagaraAllowed then
        begin
          if SD.ActivePoll = nil then SendStr(EMSI_PZT+EMSI_CR);
        end;

        State := msEMSI_c1;
      end;
    msEMSI_c1:
      begin
        ClearTmr1;
        SetTmrPublic(MaxD(RemainingTimeSecs(D.TmrPublic), toEMSI_Timeout), msEMSI_Timeout);
        NewTimerSecs(SD.AuxTmr, 5);
        Log(ltInfo, 'EMSI data send');
        SD.StateDeltaDCD := msEMSI_DCD;
        SD.Tries := 0;
        State := msEMSI_c2;
      end;
    msEMSI_c2:
      begin
        Inc(SD.Tries);
        if SD.Tries > 6 then State := msEMSI_FailTries else
        begin
          if SD.Tries > 1 then LogFmt(ltWarning, 'EMSI data send - retry %d', [SD.Tries-1]);
          State := msEMSI_c2a;
        end;
      end;
    msEMSI_c2a:
      begin
        if SD.BadPassword then
        begin
          if SD.rmtPassword = '' then SendEMSIData(cNoPwd, ecOurOptions+[SD.DesiredProtocol])
                              else SendEMSIData(cBadPwd, ecOurOptions+[SD.DesiredProtocol]);
        end else
        begin
          if SD.ActivePoll <> nil then SendEMSIData(GetPassword(SD.ActivePoll.Node.Addr, EP), ecOurOptions+SD.OurProtocols)
                               else SendEMSIData(SD.locPassword, ecOurOptions + [SD.DesiredProtocol]);
        end;
        State := msEMSI_c3;
      end;
    msEMSI_c3:
      begin
        SetTmr1(toEMSI_Block, msEMSI_c2);
        State := msEMSI_c4;
      end;
    msEMSI_c4req:
      State := msEMSI_c4;
    msEMSI_c4nak:
      begin
        SD.GotNak := True;
        State := msEMSI_c2;
      end;
    msEMSI_c4_:
      State := msEMSI_c4;
    msEMSI_c4:
      begin
        seq := IdentEMSISeq(SD.InB);
        case seq of
          es_None: ;
          es_TZP : if (SD.NiagaraAllowed) and (SD.ActivePoll = nil) then State := msHSh_TCP else UnExpC4Q;
          es_PZT : if (SD.NiagaraAllowed) and (SD.ActivePoll <> nil) then State := msHSh_TCP else UnExpC4Q;
          es_REQ : State := msEMSI_c4req;
          es_ACK : begin SD.NiagaraAllowed := False; State := msEMSI_c5 end;
          es_NAK :
            begin
              Log(ltWarning, 'Got EMSI_NAK');
              // we ignore additional EMSI_NAKs came in a same second
              if (not TimerInstalled(SD.HshrLast)) or TimerExpired(SD.HshrLast) then
              begin
                NewTimerSecs(SD.HshrLast, 1);
                State := msEMSI_c4nak;
              end;
            end;
          es_DAT, es_DATerror:
            begin
              SD.NiagaraAllowed := False;
              LogUnexpEMSI(seq);
              if SD.ActivePoll = nil then
              begin
                case seq of
                  es_DAT:
                    SendStr(EMSI_ACK+EMSI_ACK+EMSI_CR);
                  es_DATerror:
                    SendStr(EMSI_NAK+EMSI_CR);
                end;
              end;
              State := msEMSI_c4nak;
            end;
          else UnExpC4Q;
        end;
      end;
    msEMSI_c5:
      if SD.ActivePoll <> nil then StartEMSI_Receiver(msEMSI_h2) else
      begin
        if SD.BadPassword then State := msEMSI_PswVio else State := msStartWZ;
      end;
    msEMSI_FailPkt:
      begin
        Log(ltGlobalErr, 'Invalid EMSI packet - handshake failure - disconnecting');
        State := msSE_SessionAborted;
      end;
    msEMSI_Timeout:
      begin
        Log(ltGlobalErr, 'EMSI timed out - disconnecting');
        State := msSE_SessionAborted;
      end;
    msEMSI_FailTries:
      begin
        Log(ltWarning, 'EMSI handshake failure - too many tries - disconnecting');
        State := msSE_SessionAborted;
      end;
    msEMSI_PswVio:
      begin
        Log(ltWarning, 'Password security violation - disconnecting');
        State := msSE_SessionAborted;
      end;
    msEMSI_DCD:
      begin
        LogEMSIData;
        Log(ltInfo, 'Password failure?');
        State := msCarrierLost;
      end;
    else GlobalFail('%s', ['TMailerThread.DoEMSI ??']);
  end;
end;

type
  TAddrStringColl = class(TStringColl)
    Addr: TFidoAddress;
  end;

function FindAddrStringColl(L: TColl; const A: TFidoAddress): TAddrStringColl;
var
  i: Integer;
  C: TAddrStringColl;
begin
  Result := nil;
  for i := 0 to CollMax(L) do
  begin
    C := L[i];
    if CompareAddrs(A, C.Addr) = 0 then
    begin
      Result := C;
      Break;
    end;
  end;
end;




procedure RunPostProcessorsEx(ARcvdNames: TStringColl; const APrimaryAddr: TFidoAddress; ALogger: TAbstractLogger);
var
  ca, cb, pa, pb, en: TStringColl;
  cbi, s, z: string;
  i, j: Integer;
begin
  en := TStringColl.Create;
  ca := TStringColl.Create;
  cb := TStringColl.Create;
  pa := TStringColl.Create;
  pb := TStringColl.Create;
  CfgEnter;
  Cfg.ExtCollA.AppendTo(ca);
  Cfg.ExtCollB.AppendTo(cb);
  CfgLeave;
  for i := 0 to ca.Count - 1 do
  begin
    s := ExpandSuperMask(Trim(ca[i]));
    cbi := Trim(cb[i]);
    if (cbi = '') then Continue;
    case (cbi[1]) of
      '&': Continue; // inbound redirection
    end;
    Replace(';', ' ', s);
    Replace(',', ' ', s);
    while s <> '' do
    begin
      GetWrd(s, z, ' ');
      if ValidMaskAddress(z) then
      begin
        if MatchMaskAddress(APrimaryAddr, z) then
        if not en.Found(cbi) then en.Ins(cbi);
      end else
      begin
        pa.Add(z);
        pb.Add(cbi);
      end;
    end;
  end;
  FreeObject(ca);
  FreeObject(cb);
  for i := 0 to CollMax(ARcvdNames) do
  begin
    cbi := ARcvdNames[i];
    for j := 0 to pa.Count-1 do
    begin
      if MatchMask(cbi, pa[j]) then
      begin
        s := pb[j];
        if not en.Found(s) then en.Ins(s);
      end;
    end;
  end;
  FreeObject(pa);
  FreeObject(pb);
  for i := 0 to en.Count-1 do AddToExec(en[i], ALogger);
  FreeObject(en);
end;

procedure TMailerThread.RunPostProcessors;
begin
  RunPostProcessorsEx(SD.RcvdNames, SD.rmtPrimaryAddr, Logger);
  FreeObject(SD.RcvdNames);
end;

procedure TMailerThread.TossBWZ;
var
  Pending, i: Integer;
  r: TBWZRec;
  s, Msg: string;
  L: TColl;
  AL: TAddrStringColl;
  FLog: Boolean;
begin
  L := nil;
  FLog := StartupOptions and stoSkipLogWZ = 0;
  Msg := '';
  BWZColl.Enter;
  BWZColl.Update;
  if (not TimerInstalled(BWZColl.LastToss)) or (TimerExpired(BWZColl.LastToss)) then
  begin
    Pending := 0;
    for i := BWZColl.Count-1 downto 0 do
    begin
      r := BWZColl[i];
      if r.Locked or (r.FSize <> r.TmpSize) then Continue;
      if TossSingleBWZ(r, s) then
      begin
        if L = nil then L := TColl.Create;
        AL := FindAddrStringColl(L, r.Addr);
        if AL = nil then
        begin
          AL := TAddrStringColl.Create;
          AL.Addr := r.Addr;
          L.Add(AL);
        end;
        AL.Add(r.FName);
        LogFmt(ltInfo, '[WZ] ''%s'' extracted from WaZoo queue', [s]);
        BWZColl.AtFree(i);
      end else
      begin
        if (not ChkErrMsg) and (FLog) then LogFmt(ltWarning, '%s is still pending', [s]);
        Inc(Pending)
      end;
    end;
    if FLog then
    begin
      i := BWZColl.Count-Pending;
      if (Pending <> 0 ) or (i <> 0) then Msg := Format('[WZ] pending: %d, incomplete: %d', [Pending, i]);
    end;
    NewTimerSecs(BWZColl.LastToss, 120);
  end;
  BWZColl.Update;
  BWZColl.Leave;
  if Msg <> '' then Log(ltInfo, Msg);
  PurgeZombies;
  for i := 0 to CollMax(L) do
  begin
    AL := L[i];
    RunPostProcessorsEx(AL, AL.Addr, Logger);
  end;
  FreeObject(L);
end;

procedure TMailerThread.LogOverwritten(const FName: string);
begin
  LogFmt(ltWarning, '''%s'' is overwritten', [FName]);
end;

procedure TMailerThread.LogMoved(const FName: string);
begin
  LogFmt(ltWarning, 'Moved to ''%s''', [FName]);
end;


function TMailerThread.TossSingleBWZ(BWZ: TBWZRec; var s: string): Boolean;
var
  Overwritten: Boolean;
begin
  Result := BWZ.Toss(s, Overwritten);
  if Overwritten then LogOverwritten(s);
  if not Result then Exit;
  if SD.RcvdNames = nil then SD.RcvdNames := TStringColl.Create;
  SD.RcvdNames.Add(BWZ.FName);
end;

function DoCreateExtAppProcess(const AExtAppStr: string; var AExtAppProcessNfo: TProcessInformation; const EnvStr: PChar; ALogger: TAbstractLogger; InheritHandles: Boolean): Boolean;
var
  Priority: DWORD;
  Detached, SetFlag: Boolean;
  ShowMode: TExecShowMode;
  s, ss, dir: string;
  pdir: PChar;
begin
  ss := AExtAppStr;
  Result := CheckExecPrefixes(ss, Priority, Detached, ShowMode, SetFlag);
  if not Result then
  begin
    ALogger.LogFmt(ltGlobalErr, 'DoCreateExtAppProcess(%s) failed', [AExtAppStr]);
    Exit;
  end;
  if SetFlag then
  begin
    ALogger.Log(ltGlobalErr, 'File-flags are not allower for Doors-ExtApps');
    Result := False;
  end else
  begin
    s := ss;
    GetWrd(s, dir, ' ');
    dir := ExtractFilePath(dir);
    if Dir = '' then pdir := nil else pdir := PChar(dir);
    ALogger.LogFmt(ltInfo, 'Starting "%s"', [ss]);
    Result := ExecProcess(ss, AExtAppProcessNfo, EnvStr, Pdir, InheritHandles, IDet[Detached] or Priority or CREATE_SUSPENDED, ShowMode);
  end;
end;

//function RunExtApp(Mlr: TMailerThread; ALogger: TAbstractLogger; const AName: string; APoll: TFidoPoll; AExtPoll: Boolean; var AExtAppStr: string; var AExtAppProcessNfo: TProcessInformation): Boolean;

function RunExtApp(Mlr: TMailerThread; ALogger: TAbstractLogger; const AName: string; APoll: TFidoPoll; ANode: TAdvNode; var AExtAppStr: string; var AExtAppProcessNfo: TProcessInformation; PAuxStr: Pstring; APassHandleSupported: Boolean): Boolean;
var
  EnvStr,
  _DCE,
  _DTE,
  _CONNECT,
  _CONTROL,
  _NAME,
  _LINE,
  _HANDLE,
  _NUMBER,
  _INDEX,

  _NODE,
  _STATION,
  __LOCATION,
  _STATUS,
  _SYSOP,
  _PHONE,
  _FLAGS,
  _SPEED : string;

procedure Add(const s1, s2: string);
begin
  EnvStr := EnvStr+Format('ARGUS_%s=%s'#0, [s1, s2])
end;

procedure PrepareEnvVars;
var
  p: PxByteArray;
  li: Integer;
  ad: TAdvNodeData;
//  n: TAdvNode;
begin
  _NAME := AName; Replace(' ', '_', _NAME);

  if Mlr <> nil then
  begin
    _DCE := IntToStr(Mlr.SD.ConnectSpeed);
    if Mlr.CP = nil then _DTE := '' else _DTE := IntToStr(Mlr.CP.DTE);
    _CONNECT := Mlr.DS.ConnectString; Replace(' ', '_', _CONNECT);
    {$IFDEF WS}
    if not Mlr.DialupLine then _CONTROL := 'TCP/IP' else
    {$ENDIF}
    if (Pos('MNP', _CONNECT) > 0) or
       (Pos('ARQ', _CONNECT) > 0) or
       (Pos('REL', _CONNECT) > 0) then _CONTROL := 'MNP' else _CONTROL := '';
    _LINE := IntToStr(Mlr.LineNumber);
    if (Mlr.CP = nil) or (not APassHandleSupported) then _HANDLE := '' else _HANDLE := IntToStr(Mlr.CP.Handle);
    if Mlr.CP = nil then _NUMBER := '' else _NUMBER := IntToStr(Mlr.CP.PortNumber);
    if Mlr.CP = nil then _INDEX := '' else _INDEX := IntToStr(Mlr.CP.PortIndex);
  end;

  if ANode <> nil then
  begin
//    n := APoll.Node;
    _NODE := Addr2Str(ANode.Addr);
    _STATION := ANode.Station;
    __LOCATION := ANode.Location;
    _STATUS := cNodePrefixFlag[ANode.PrefixFlag];
    _SYSOP := ANode.Sysop;
    _SPEED := IntToStr(ANode.Speed);
    {$IFDEF WS}
    if Mlr = nil then
    begin
      if (APoll <> nil) and (ANode.IpData <> nil) then
      begin
        ad := ANode.IpData[APoll.DataIdx];
        _PHONE := ad.IPAddr;
        _FLAGS := ad.Flags;
      end;
    end else
    {$ENDIF}
    begin
      if (APoll <> nil) and (ANode.DialupData <> nil) then
      begin
         ad := ANode.DialupData[APoll.DataIdx];
        _PHONE := ad.Phone;
        _FLAGS := ad.Flags;
      end;
    end;
  end;
  p := Pointer(GetEnvironmentStrings);
  li := 0; while (p^[li]<>0) or (p^[li+1]<>0) do Inc(li);
  Inc(li);
  SetLength(EnvStr, li);
  Move(p^, EnvStr[1], li);
  FreeEnvironmentStrings(Pointer(p));
  Add('DCE', _DCE);
  Add('DTE', _DTE);
  Add('CONNECT', _CONNECT);
  Add('CONTROL', _CONTROL);
  Add('NAME', _NAME);
  Add('LINE', _LINE);
  if APassHandleSupported then Add('HANDLE', _HANDLE);
  Add('NUMBER', _NUMBER);
  Add('INDEX', _INDEX);
  if ANode <> nil then
  begin
    Add('NODE', _NODE);
    Add('STATION', _STATION);
    Add('LOCATION', __LOCATION);
    Add('STATUS', _STATUS);
    Add('SYSOP', _SYSOP);
    Add('PHONE', _PHONE);
    Add('FLAGS', _FLAGS);
    Add('SPEED', _SPEED);
  end;
  EnvStr := EnvStr+#0;
end;

var
  s: string;
  InheritHandles, B: Boolean;

function Rpl(c: Char; const a: string): Boolean;
begin
  Result := Replace('%'+c, a, s);
  if PAuxStr <> nil then Replace('%'+c, a, PAuxStr^);
end;

begin
  PrepareEnvVars;
  s := AExtAppStr;
  Rpl('B', _DCE);
  Rpl('b', _DTE);
  Rpl('e', _CONNECT);
  Rpl('E', _CONTROL);
  Rpl('L', _NAME);
  Rpl('n', _LINE);
  if APassHandleSupported then Rpl('h', _HANDLE);
  Rpl('C', _NUMBER);
  Rpl('p', _INDEX);
  Rpl('w', _NODE);
  Rpl('x', _STATION);
  Rpl('v', __LOCATION);
  Rpl('X', _SYSOP);
  Rpl('y', _PHONE);
  Rpl('Y', _FLAGS);
  Rpl('W', _SPEED);
  if not APassHandleSupported then
  begin
    InheritHandles := False;
  end else
  begin
    B := Rpl('Z', '');
    if Mlr = nil then
    begin
      InheritHandles := False;
    end else
    begin
      Mlr.SD.ExtAppCloseSerial := B;
      {$IFDEF WS} if not Mlr.DialupLine then Mlr.SD.ExtAppCloseSerial := False; {$ENDIF}

      if Mlr.CP = nil then
      begin
        InheritHandles := False;
      end else
      begin
        if Mlr.SD.ExtAppCloseSerial then Mlr.FreeCP else TDevicePort(Mlr.CP).SleepDown;
        InheritHandles := not B;
      end;
    end;
  end;

  Result := DoCreateExtAppProcess(Trim(s), AExtAppProcessNfo, PChar(EnvStr), ALogger, InheritHandles);
end;


procedure FinalizeExtPoll(var P: TFidoPoll; ExitCode: DWORD);
var
  s: string;

function Next: Boolean;
begin
  Result := NextPollOptionMatches(s, ExitCode);
end;

procedure OK;
begin
  FidoOut.FinalizeSession(P.Node.Addr, False);
  FinalizePollOK(P);
end;

begin
  s := P.Node.Ext.Opts;
  if Next then OK else
  if Next then P.IncBusyTries('BUSY') else
  if Next then P.IncNoConnectTries else
  if Next then P.IncAbortedTries else OK;
end;

procedure FinalizeExtApp(var Nfo: TProcessInformation; Logger: TAbstractLogger; var ExtPoll: TFidoPoll);
var
  ExitCode: DWORD;
begin
  if not GetExitCodeProcess(Nfo.hProcess, ExitCode) then ExitCode := 0;
  if (ExtPoll <> nil) and (ExtPoll.Node.Ext <> nil) then FinalizeExtPoll(ExtPoll, ExitCode);
  Logger.LogTermination(Nfo, False, '');
  ZeroHandle(Nfo.hThread);
  ZeroHandle(Nfo.hProcess);
end;

procedure WaitForExtProcess(hProcess: DWORD; var APoll: TFidoPoll; ALogger: TAbstractLogger);
var
  i, ToSleep, ExitCode: DWORD;
begin
  if (APoll = nil) or (APoll.Node.Ext = nil) then ToSleep := INFINITE else ToSleep := APoll.ExtSleepMSecs;
  i := WaitEvts([hProcess, oShutdown], ToSleep);
  ExitCode := 1;
  case i of
    WAIT_OBJECT_0+0:
      Exit;
    WAIT_OBJECT_0+1:
      begin
        ALogger.Log(ltInfo, 'Terminated by Argus shutdown');
      end;
    WAIT_TIMEOUT:
      begin
        ALogger.Log(ltInfo, 'External Poll Timeout');
        ExitCode := APoll.ExtTimeoutExitCode;
        if ExitCode = INVALID_VALUE then ExitCode := 0;
      end;
  end;
  if not TerminateProcess(hProcess, ExitCode) then Exit;
  WaitForSingleObject(hProcess, 1000);
end;

procedure TMailerThread.PollDone;
begin
  if SD.ActivePoll <> nil then
  begin
    RollPoll(SD.ActivePoll);
    EnterFidoPolls;
    NewTimerAvg(TmrNextDial, FidoPolls.Options.d.Retry);
    LeaveFidoPolls;
    SD.ActivePoll := nil;
  end;
end;

procedure TMailerThread.DoRestoreSerial;
var
  r: TPortRec;
  FCP: TPort;
begin
  r := GetPortRec(LineId);
  FCP := OpenSerialPort(r);
  FreeObject(r);
  EnterCS(CP_CS);
  CP := FCP;
  LeaveCS(CP_CS);
end;

procedure TMailerThread.RestoreSerial;
begin
  DoRestoreSerial;
  if CP = nil then
  begin
    Log(ltGlobalErr, 'Failed to open port - shutting down line');
    SelfTerminate := True;
  end;
end;


procedure TMailerThread.DoExtApp;
var
  n: TAdvNode;
begin
  case State of
     msExtApp_0:
       begin
         ClearTmrPublic;
         if SD.FaxConnection then
         begin
           Log(ltInfo, 'Fax connection');
           SD.ExtAppStr := SD.ModemRec.FaxApp;
         end else
         if SD.ExtPoll then
         begin
           Log(ltInfo, 'External poll');
           SD.ExtAppStr := SD.ActivePoll.Node.Ext.Cmd;
         end;
         State := msExtApp_1;
       end;
     msExtApp_1:
       begin
         if SD.ActivePoll = nil then n := nil else n := SD.ActivePoll.Node;
         if RunExtApp(Self, Logger, Name, SD.ActivePoll, n, SD.ExtAppStr, SD.ExtAppProcessNfo, nil, True) then
         begin
           State := msExtApp_2;
         end else
         begin
           ChkErrMsg;
           Log(ltGlobalErr, 'Error starting application');
           if SD.ExtAppCloseSerial then RestoreSerial else TDevicePort(CP).WakeUp;
           State := msSE_SessionAborted;
         end;
         Sleep(300);
       end;
     msExtApp_2:
     begin
       SetStatusMsg(rsMMExtApp, '');
       D.ExtApp := True;
       DisplayData;
       ResumeThread(SD.ExtAppProcessNfo.hThread);
       State := msExtAppWait;
     end;
     msExtAppWait:
     begin
       WaitForExtProcess(SD.ExtAppProcessNfo.hProcess, SD.ActivePoll, Logger);
       State := msExtAppWaitOK;
     end;
     msExtAppWaitOK:
     begin
       if CP <> nil then
       begin
         if SD.ExtAppCloseSerial then RestoreSerial else TDevicePort(CP).WakeUp;
       end;
       D.ExtApp := False;
       FinalizeExtApp(SD.ExtAppProcessNfo, Logger, SD.ActivePoll);
       State := msInit;
     end;
  end;
end;


procedure TMailerThread.GetConnectSpeed;
const
  ASpeedMin: array[Boolean] of Integer = (eiAccSpeedMin, eiTrsSpeedMin);
var
  CS: DWORD;
  s,z: string;
  LinkOK: Boolean;
  I, J: Integer;
begin
  if SD.ConnectSpeedGot then GlobalFail('%s', ['Duplicate GetConnectSpeed call']);
  SD.ConnectSpeedGot := True;

  if not SD.ConnectRegExp then
  begin
    I := Pos(#13, SD.InB);
    J := Pos(#10, SD.InB);
    if I=J then DS.ConnectString := '' else
    begin
      ClearTmr1;
      if I < J then XChg(I, J);
      if J > 0 then XChg(I, J) else J := I;
      s := Copy(SD.InB, 2, I-2);
      DS.ConnectString := s;
      Delete(SD.InB, 1, J);
    end;
//    if SD.ModemRec <> nil then DS.ConnectString := SD.ModemRec.StdResp[Integer(mrpConnect)]+' '+DS.ConnectString;
  end;

  ClearTmr1;
  s := DS.ConnectString;
  SD.ConnectSpeed := GetSpeed(S);
  LinkOK := LinkRestrictionMatches(S, EP.StrValue(eiAccLinkRqd), EP.StrValue(eiAccLinkFrb));

  while (s <> '') and (not SD.HstLink) and (not SD.FaxConnection) do
  begin
    GetWrd(s, z, '/');
    if z = 'HST' then SD.HstLink := True;
    if z = 'FAX' then SD.FaxConnection := True;
  end;
//    Delete(SD.InB, 1, J);
  if SD.FaxConnection then State := msFaxBegin else
  begin
    if LinkOK then
    begin
      CS := EP.DwordValueD(ASpeedMin[SD.ActivePoll <> nil], 0);
      if CS > SD.ConnectSpeed then
      begin
        LogConnect;
        LogFmt(ltWarning, 'Connection BPS rate is too low (%d), should be at least %d - disconnecting', [SD.ConnectSpeed, CS]);
        State := msInit;
      end else
      begin
        State := msCN_HandshakeStart;
      end;
    end else
    begin
      Log(ltWarning, 'Unacceptable link codes - disconnecting');
      State := msInit;
    end;
  end;
end;


procedure TMailerThread.DoConnect;
begin
  case State of
    msCN_ConnectString:
      begin
//        DS.ConnectString := SD.LastResponse;
        SD.StateDeltaDCD := msCN_ConnectStringDCD;
        SetTmr1(1, msCN_ConnectStringTmr);
        State := msCN_HandshakeDelay;
      end;
    msCN_ConnectStringDCD:
      begin
        SD.StateDeltaDCD := msCarrierLost;
        SetTmr1(1, msCN_HandshakeStart);
        State := msCN_GetSpeed;
      end;
    msCN_ConnectStringTmr:
      begin
        // DCD signal did not asserted during 1 second since getting 'CONNECT'
        // Ignore DCD, get connection speed and run session
        SD.StateDeltaDCD := msNone;
        State := msCN_HandshakeStart;
        GetConnectSpeed;
      end;
    msCN_ConnectString_A:
      begin
//        DS.ConnectString := SD.LastResponse;
        SetTmrPublic(180, msInit);
        Log(ltInfo, 'Carrier detected by CONNECT string');
        State := msCN_ConnectString;
      end;
    msCN_ConnectDCD_A:
      begin
        SetTmrPublic(180, msInit);
        Log(ltInfo, 'Carrier detected by DCD');
        State := msCN_ConnectDCD;
      end;
    msCN_ConnectDCD:
      begin
        DS.ConnectString := 'CONNECT DCD/???';
        SD.StateDeltaDCD := msCarrierLost;
        SetTmr1(10, msCN_HandshakeStart);
        State := msCN_ConnectDCD_w;
      end;
    msCN_ConnectDCD_w:
      if not ChkFax then
      case ModemResponse of
        mrpNone: ;
        mrpConnect:
          begin
//            DS.ConnectString := SD.LastResponse;
            ClearTmr1;
            State := msCN_GetSpeed;
          end;
        else
          begin
            LogFmt(ltWarning, 'Unexpected modem response (%s) - disconnecting', [SD.LastResponse]);
            State := msSE_NoConnect;
          end;
      end;
    msCN_GetSpeed:
      GetConnectSpeed;
    msCN_HandshakeStart:
      begin
        SD.LogEntireModemInput := False;
        SD.StateDeltaDCD := msCarrierLost;
        if SD.HstLink then Exclude(SD.OurProtocols, ecHYD);
        if SD.ActivePoll = nil then
          SetStatusMsg(rsMMngIn, '') else
          SetStatusMsg(rsMMngOut, Addr2Str(SD.ActivePoll.Node.Addr));
        SD.NoCrLf := True;
        ClearTmr1;

        if DoConnectStart then
        begin
          SetTmrPublic(MaxD(RemainingTimeSecs(D.TmrPublic), toEMSI_Timeout), msHandshakeTimeout);
          {$IFDEF WS}
          if not DialupLine then State := msCN_HandshakeOK else
          {$ENDIF}
          begin
            SetTmr1(1, msCN_HandshakeOK);
            NewTimer(SD.Tmr1, 1); //1/20 sec
            State := msCN_HandshakeDelay;
          end;
        end;
      end;
    msCN_HandshakeDelay: ;
    msCN_HandshakeOK:
      if SD.ActivePoll <> nil then State := msHSh_s1 else State := msHSh_r1;
  end;
end;

function TMailerThread.ModemResponseCn: TModemStdRespIdx;
var
  i: TModemStdRespIdxSet;
begin
  i := [Low(TModemStdRespIdx)..High(TModemStdRespIdx)];
  if not VirtualCD then Exclude(i, mrpConnect);
  Result := ModemResponseMask(i);
end;

function TMailerThread.ModemResponse: TModemStdRespIdx;
begin
  Result := ModemResponseMask([Low(TModemStdRespIdx)..High(TModemStdRespIdx)]);
end;

function TMailerThread.ChkFax: Boolean;
begin
  Result := Pos('+FCO', SD.InB) > 0;
  if Result then
  begin
    SD.FaxConnection := True;
    State := msFaxBegin;
  end;
end;


function ReScanColl(const s: string; const ac: array of TColl): Boolean;
var
  i,j: Integer;
  r: TReStreamScanner;
  c: TColl;
begin
  Result := False;
  for j := Low(ac) to High(ac) do
  begin
    c := ac[j];
    for i := 0 to CollMax(c) do
    begin
      r := c[i];
      if r.Scan(s) then Result := True;
    end;
  end;
end;

procedure ReScannerDecColl(AValue: Integer; const ac: array of TColl);
var
  r: TReStreamScanner;
  i, j: Integer;
  c: TColl;
begin
  for j := Low(ac) to High(ac) do
  begin
    c := ac[j];
    for i := 0 to CollMax(c) do
    begin
      r := c[i];
      r.DecPos(AValue);
    end;
  end;
end;

procedure TMailerThread.RespGotMatch(j: Integer; const W: string; i: TModemStdRespIdx);
var
  k, jj: Integer;
  zz: string;
  C: TStringColl;
begin
  SD.LastResponse := Copy(SD.InB, j, Length(W));
  if i = mrpConnect then
  begin
    DS.ConnectString := SD.LastResponse;
  end;
  k := j+Length(W)-1;
  if SD.LogEntireModemInput then
  begin
    zz := Copy(SD.InB, 1, k);
    if ReScanColl(zz, [SD.RespFmtREs]) then
    begin
      ReScannerDecColl(MaxInt-1, [SD.RespFmtREs]);
    end else
    begin
      C := TStringColl.Create;
      C.LoadFromString(zz);
      for jj := CollMax(C) downto 0 do if Trim(C[jj]) = '' then C.AtFree(jj);
      for jj := 0 to CollMax(C) do
      begin
        if (Pos(C[jj], SD.LastSentString) = 0) and
           ((C[jj] <> W) or (i <> mrpConnect)) then Log(ltWarning, C[jj]);
      end;
      FreeObject(C)
    end;
  end;
  Delete(SD.InB, 1, k);
end;


function TMailerThread.ModemResponseMask(AMask: TModemStdRespIdxSet): TModemStdRespIdx;
const
  cConnectSP = 'CONNECT ';
var
  i: TModemStdRespIdx;
  LE, US, W, Z, l: string;
  j, k: Integer;
  cc, HiC: Char;
  GotUS, GotLE: Boolean;
  RE: TPCRE;
begin
  SD.LastResponse := '';
  Result := mrpNone;
  if SD.InB = '' then Exit;
  GotUS := False;
  GotLE := False;
  UpdateModem;
  HiC := #0; // to avoid "uninitialized" warning
  for i := Low(TModemStdRespIdx) to Pred(mrpNone) do
  begin
    if not (i in AMask) then Continue;
    Z := SD.ModemRec.StdResp[Integer(I)];
    while Z <> '' do
    begin
      GetWrd(Z, W, ' ');
      W := StrQuotePartEx(W, '~', #3, #4);
      if Pos(#3, W) <= 0 then
      begin
        for j := 1 to Length(W) do case W[j] of
          '_': W[j] := ' ';
           #4: W[j] := '~';
        end;
        if not GotUS then
        begin
          GotUS := True;
          US := UpperCase(SD.InB);
        end;
        if i = mrpConnect then j := Pos(W, US) else
        begin
          j := Pos(W+ccCR, US); if j = 0 then j := Pos(W+ccLF, US);
        end;
        if (j > 1) and (US[j-1] <> #13) and (US[j-1] <> #10) then j := 0;
        if j <> 0 then
        begin
          RespGotMatch(j, w, i);
          Result := i;
          Exit;
        end;
      end else
      begin
        L := '(?m)';
        j := 0;
        for k := 1 to Length(W) do
        begin
          cc := W[k];
          case j of
            0:
              case cc of
                 #3: j := 3;
                 #4: L := L + '~';
                '*': L := L + '.*';
                '?': L := L + '.';
                '0'..'9', 'a'..'z', 'A'..'Z': L := L + cc;
                else L := L + '\x'+Hex2(Byte(cc));
              end;
{            1:
              begin
                HiC := cc;
                j := 2;
              end;}
            2:
              begin
                L := L + Char(VlH(HiC+cc));
                j := 3;
              end;
            3:
              begin
                if cc = #3 then j := 0 else begin HiC := cc; j := 2 end;
              end;
          end;
        end;
        RE := GetRegExpr(L);
        if not GotLE then
        begin
          GotLE := True;
          LE := SD.InB;
          Replace(#13#10, #10, LE);
          Replace(#13, #10, LE);
          SD.InB := LE;
          US := UpperCase(SD.InB);
        end;
        if (RE.ErrPtr <>0) or (RE.Match(LE) <= 0) then begin RE.Unlock; Continue end;
        W := StrAsg(RE[0]);
        j := RE.MatchPos[0];
        RE.Unlock;
        RespGotMatch(j, w, i);
        if i = mrpConnect then
        begin
          SD.ConnectRegExp := True;
          if StrBegsF(cConnectSP, Length(cConnectSP), DS.ConnectString, Length(DS.ConnectString)) then
          begin
            Delete(DS.ConnectString, 1, Length(cConnectSP));
          end;
        end;
        Result := i;
        Exit;
      end;
    end;
  end;
end;

procedure TMailerThread.DoSE_SessionAborted;
begin
  if SD.ActivePoll <> nil then SD.ActivePoll.IncAbortedTries;
end;

procedure TMailerThread.DoSE_Busy;
begin
  Log(ltInfo, SD.LastResponse);
  if SD.ActivePoll <> nil then SD.ActivePoll.IncBusyTries(SD.LastResponse);
end;

procedure TMailerThread.DoSE_NoConnect;
begin
  if SD.ActivePoll <> nil then SD.ActivePoll.IncNoConnectTries;
end;

function TMailerThread.GetPortName: string;
var
  r: TPortRec;
  i: Integer;
begin
  r := GetPortRec(LineId);
  i := r.d.Port;
  FreeObject(r);
  Result := ComName(i);
end;

function TMailerThread.ModemInitString: string;
begin
  Result := EP.StrValueD(eiModemCmdInit, SD.ModemRec.Cmds.Init)
end;

function TMailerThread.SendModemInitString: Boolean;
begin
  SD.LastModemInitString := ModemInitString;
  Result := SendModemString(SD.LastModemInitString);
end;

procedure TMailerThread.DoMisc;

procedure DialPhone(NodePhone, NodeFlags: string);
var
  i: Integer;
  Prefix, Suffix, Preinit, w, z: string;
  FlagsColl: TStringColl;
  Listed: Boolean;

function Found(s: string): Boolean;
begin
  Result := False; if s = '' then Exit;
  while s <> '' do
  begin
    GetWrd(s, w, ',');
    if not FlagsColl.Found(w) then Exit;
  end;
  Result := True;
end;

function Send: Boolean;
begin
  Result := False;
  if PreInit <> '' then
  begin
    if not SendModemString(Preinit) then Exit;
  end;
  if not SendModemString(Prefix+NodePhone+Suffix) then Exit;
  Result := True;
end;

function GetPfx: string;
begin
  Result := EP.StrValueD(eiModemCmdPrefix, SD.ModemRec.Cmds.Prefix);
end;

function GetSfx: string;
begin
  Result := EP.StrValueD(eiModemCmdSuffix, SD.ModemRec.Cmds.Suffix);
end;

begin
  FlagsColl := TStringColl.Create;
  while NodeFlags <> '' do
  begin
    GetWrd(NodeFlags, w, ',');
    FlagsColl.Ins(UpperCase(w));
  end;
  Listed := False;
  i := 0;
  while (not Listed) and (i < SD.ModemRec.FlagsA.Count) do
  begin
    z := UpperCase(SD.ModemRec.FlagsA[i]);
    while z <> '' do
    begin
      GetWrd(z, w, ' ');
      if Found(w) then
      begin
        w := SD.ModemRec.FlagsB[i];
        Listed := True;
        Break;
      end;
    end;
    Inc(i);
  end;
  FreeObject(FlagsColl);
  if Listed and (w <> '') then
  begin
    GetWrd(w, Preinit, '/'); if Preinit = '.' then PreInit := '';
    if w = '' then
    begin
      Prefix := GetPfx;
      Suffix  := GetSfx;
    end else
    begin
      GetWrd(w, Prefix, '/'); if Prefix = '.' then Prefix := GetPfx;
      if w = '' then Suffix := GetSfx else
      begin
        GetWrd(w, Suffix, '/'); if Suffix = '.' then Suffix := GetSfx
      end;
    end;
  end else
  begin
    PreInit := '';
    Prefix  := GetPfx;
    Suffix  := GetSfx;
  end;
  if not Send then State := msError;
end;

procedure CheckAnswerRequest;
begin
  if not SD.AnswerRequest then Exit;
  SD.AnswerRequest := False;
  if CP = nil then
  begin
    AnswerAfterInit := True;
    State := msInit;
  end else
  begin
    State := msStartAnswer;
  end;
end;

procedure DoIdle;
var
  cn: TModemStdRespIdx;
  z: string;
begin
  cn := ModemResponseCn;
  case cn of
    mrpNone: CheckAnswerRequest;
    mrpRing:
    begin
      ClearTmr1;
      Log(ltInfo, SD.LastResponse);
      State := msRingAfterIdle;
    end;
    mrpConnect: State := msCN_ConnectString_A;
    else
    begin
      if cn <> mrpOK then z := '' else z := ', possibly caused by improperly choosed init string';
      LogFmt(ltWarning, 'Unexpected modem response (%s)%s - initialising again', [SD.LastResponse, z]);
      State := msInit;
    end;
  end;
end;


function ModemInfoString: string;
begin
  Result := EP.StrValueD(eiModemCmdExit, SD.ModemRec.Cmds.Exit);
end;

procedure DoFinalize;
var
  i: Integer;
begin
  for i := 0 to CollMax(SD.rmtAddrs) do FidoOut.FinalizeSession(SD.rmtAddrs[i], SD.KillSentREQ);
end;

procedure LogModemInit;
begin
  Log(ltInfo, 'Initialising modem');
  SD.InitModemLogged := True;
end;

{$IFDEF WS}
procedure LogDaemonStatus;
const
  BStatus: array[Boolean] of string = ('Aborted', 'Complete');
var
  s: string;
begin
  if (CP = nil) then s := SD.LastCallerId else s := CP.CallerId;
  s := Format('DISCONNECT From %s - %s', [s, BStatus[SD.SessionOK]]);
  if SD.rmtPrimaryAddrSet then s := s + Format(' (%s)', [Addr2Str(SD.rmtPrimaryAddr)]);
  LogDaemon(s);
end;
{$ENDIF WS}



begin
  UpdateModem;
  case State of
    msCheckOut:
      begin
        DoPollsRecalc;
      end;
    msError:
      begin
        if PrevState = msError then State := msInit else
        begin
          if not PortReloaded then
          begin
            PortReloaded := True;
            FreeCP;
            Sleep(2000);
            RestoreSerial;
            State := msInit;
          end else
          begin
            SD.ExtAppStr := Trim(EP.StrValue(eiModemErrExtApp));
            if SD.ExtAppStr = '' then
            begin
              State := msError;
              SetTmr1(CReinitTime, msInit);
              SetStatusMsg(rsMMErrInitMdm, '');
              Log(ltGlobalErr, 'Error initialising modem');
            end else
            begin
              Log(ltGlobalErr, 'Error initialising modem - executing Error Ext.App.');
              State := msExtApp_0;
            end;
          end;
        end;
      end;
    msStart:
      begin
        Log(ltInfo, 'Begin v'+ProductVersion);
        TossBWZ;
        State := msInit;
      end;
    msModemStatx:
      begin
        SD.ModemInfoString := ModemInfoString;
        if SD.ModemInfoString <> '' then
        begin
          SD.LogEntireModemInput := True;
          SendModemString(SD.ModemInfoString);
          SD.LogEntireModemInput := False;
        end;
        State := msInitModemA;
      end;
    msInit:
      begin
        SetStatusMsg(rsMMInit, '');
        if RestoreBPS and (CP <> nil) and (CP is TSerialPort) then
        begin
          RestoreBPS := False;
          TSerialPort(CP).SetBPS(CP.DTE);
        end;
        FreeHReqDelete(True);
        PollDone;
        RunPostProcessors;
        {$IFDEF WS}
        if not DialupLine then LogDaemonStatus;
        {$ENDIF}
        DoRemoveNiagara;
        NextNeedModemStatx := SD.NeedModemStatx;
        FreeSD;
        Clear(D, SizeOf(D));
        D.StatusMsg := rsMMInit;
        Finalize(DS);

        EnterCS(DisplayDataCS);
        FreeObject(PubBatchT);
        FreeObject(PubBatchR);
        LeaveCS(DisplayDataCS);

        SD := TMailerThreadInitData.Create;
        UpdateModem;
        SD.NeedModemStatx := NextNeedModemStatx and (ModemInfoString <> '');
        NextNeedModemStatx := False;
        SD.AnswerAfterInit := AnswerAfterInit;
        AnswerAfterInit := False;
        ClearTmrPublic;
        ClearTmr1;
        SD.StateDeltaDCD := msNone;
        {$IFDEF WS}
        if not DialupLine then
        begin
          TossBWZ;
          SelfTerminate := True
        end else
        {$ENDIF}
        begin
          State := msInitModem_I;
          ProtCore := ptDialup;
          SD.SessionCore := scEmsiWz;
        end;
        if SelfTerminate then Terminated := True;
        if Terminated then
          State := msDone;
      end;
    msDone: GlobalFail('%s', ['msDone']);
    msInitModem_I:
      begin
        SD.Accumulate := True;
        if not SD.NeedModemStatx then LogModemInit;
        SD.ReportedLogOK := False;
        SD.Tries := 3;
        State := msInitModem;
      end;
    msInitModem:
      begin
        if CP = nil then DoRestoreSerial;
        if CP = nil then State := msStartDialFailed else
        begin
          if CP.DCD then State := msHangup else State := msInitModemA;
        end;
      end;
   msHangup:
      begin
        HangupModem;
        State := msInitModemA;
      end;
    msInitModemA:
      begin
        if CP = nil then DoRestoreSerial;
        if CP = nil then State := msStartDialFailed else
        begin
          if SD.NeedModemStatx then
          begin
            SD.NeedModemStatx := False;
            State := msModemStatx;
          end else
          begin
            if not SD.InitModemLogged then LogModemInit;
            if SendModemInitString then State := msInitOK else
            begin
              if not SD.WasHangup then State := msHangup else
              begin
                Dec(SD.Tries);
                if SD.Tries < 0 then State := msError else State := msInitModem;
              end;
            end;
          end;
        end;
      end;
    msInitOK:
      begin
        CP.Carrier := CP.DCD;
        if CP.Carrier then State := msStillHigh else State := msInitOK_;
      end;
    msStillHigh:
      begin
        Inc(SD.TriesA);
        if SD.TriesA > 3 then State := msError else
        begin
          Log(ltGlobalErr, 'Carrier is still high!');
          State := msInitModem;
        end;
      end;
    msInitOK_:
      begin
        PortReloaded := False;
        NewTimerAvg(SD.TmrReInit, CReinitTime);
        TossBWZ;
        SD.StateDeltaDCD := msCN_ConnectDCD_A;
        if not SD.ReportedLogOK then
        begin
          SD.ReportedLogOK := True;
          Log(ltInfo, 'OK');
        end;
        SetTmr1(2, msIdleA_Expired);
        ClearTmrPublic;
        if SD.AnswerAfterInit then State := msStartAnswer else
        begin
          if EP.VoidFound(eiAccNoIncoming) then State := msInitFreeCP else State := msIdleA;
        end;
      end;
    msInitFreeCP:
      begin
        Log(ltInfo, 'Releasing serial port');
        FreeCP;
        SD.LastModemInitString := #1;
        State := msIdleA_Expired;
      end;
    msIdleA:
      DoIdle;
    msIdleA_Expired:
      begin
        ClearTmr1;
        State := msCheckOut;
        if (not TimerInstalled(TmrNextDial)) or (TimerExpired(TmrNextDial)) then
        begin
          ClearTmrPublic;
        end else
        begin
          SetTmrPublic(RemainingTimeSecs(TmrNextDial), msCheckOut);
        end;
      end;
    msRingAfterIdle:
      begin
        SD.RingsToAnswer := EP.DwordValueD(eiNumRings, 1);
        SD.RingsDone := 0;
        if SD.RingsToAnswer = 0 then
        begin
          if TimerInstalled(D.TmrPublic) then State := msIdleA else
          begin
            ClearTmrPublic;
            State := msInitOK;
          end;
        end else
        begin
          ClearTmrPublic;
          State := msGotNextRing;
        end;
      end;
    msGotNextRing:
      begin
        Inc(SD.RingsDone);
        if SD.RingsDone >= SD.RingsToAnswer then
        begin
          State := msStartAnswer;
        end else
        begin
          State := msStartWaitNextRing;
        end;
      end;
    msStartWaitNextRing:
      begin
        SetStatusMsg(rsMMRingN, Format('%d / %d', [SD.RingsDone, SD.RingsToAnswer]));
        SetTmr1(10, msRingTimerExpired);
        State := msWaitNextRing;
      end;
    msWaitNextRing:
      case ModemResponseCn of
        mrpNone: CheckAnswerRequest;
        mrpRing: State := msGotNextRing;
        else
        begin
          Log(ltInfo, SD.LastResponse);
          State := msInit;
        end;
      end;
    msRingTimerExpired:
      begin
        Log(ltInfo, 'Not enough rings to answer');
        State := msInitModemA;
      end;
    msStartIdle:
      begin
        ClearTmr1;
        State := msIdle;
      end;
    msIdle: // waiting for a call
      if not TimerInstalled(SD.TmrReInit) then GlobalFail('%s', ['TmrReinit not installed']) else
      if not TimerExpired(SD.TmrReInit) then DoIdle else
      begin
        if (EP.VoidFound(eiAccNoIncoming)) or
           ((EP.VoidFound(eiModemDisaReinit)) and (ModemInitString = SD.LastModemInitString)) then
        begin
          NewTimerAvg(SD.TmrReInit, CReinitTime);
          TossBWZ;
          State := msIdleA_Expired;
        end else
        begin
          SD.Tries := 3;
          State := msInitModemA;
        end;
      end;
    msModemCmdIdle:
      begin
      end;
    msStartDial:
      begin
        ClearTmr1;
        LogFmt(ltInfo, 'Calling %s', [Addr2Str(SD.ActivePoll.Node.Addr)]);
        if SD.ActivePoll.Node.Ext = nil then State := msStartDialPhone else State := msStartExtPoll;
      end;
    msStartExtPoll:
      begin
        SD.ExtPoll := True;
        State := msExtApp_0;
      end;
    msStartDialPhone:
      begin
        if CP = nil then
        begin
          DoRestoreSerial;
          if CP <> nil then
          begin
            HangupModem;
            SendModemInitString;
          end;
        end;
        if CP = nil then State := msStartDialFailed else State := msStartDialOK;
      end;
    msStartDialOK:
      begin
        SD.InB := '';
        SetTmrPublic(180, msDialTimeout);
        SetStatusMsg(rsMMCalling, Addr2Str(SD.ActivePoll.Node.Addr));
        Log(ltInfo, Format('Dialling %s', [SD.ActivePoll.DialupPhone]));
        LogPoll(Format('Dialling  %s  (%s)', [Addr2Str(SD.ActivePoll.Node.Addr), SD.ActivePoll.DialupPhone]));
        State := msDialling;
        SD.RingCount := 0;
        SD.StateDeltaDCD := msCN_ConnectDCD;
        DialPhone(SD.ActivePoll.DialupPhone, SD.ActivePoll.DialupFlags);
      end;
    msStartDialFailed:
      begin
        Log(ltWarning, 'Failed to restore serial port - trying');
        ClearTmrPublic;
        ClearTmr1;
        ClearTimer(SD.TmrReinit);
        PollDone;
        State := msTryOpenSer;
      end;
    msTryOpenSer:
      begin
        Inc(SD.OpenSerTries);
        SetStatusMsg(rs_s, Format(LngStr(rsMMwaitsp), [GetPortName, SD.OpenSerTries]));
        SetTmrPublic(10, msTryOpenSerAgain);
        State := msTryOpenSerW;
      end;
    msTryOpenSerW:;
    msTryOpenSerAgain:
      begin
        DoRestoreSerial;
        if CP = nil then State := msTryOpenSer else
        begin
          LogFmt(ltInfo, 'Serial port restored OK, %d attempts', [SD.OpenSerTries]);
          State := msInit;
        end;
      end;
    msDialTimeout:
      begin
        Log(ltWarning, 'Dialling timed out');
        State := msSE_NoConnect;
      end;
    msAnswerFailed:
      begin
        Log(ltInfo, 'Failed to restore serial - answer failed');
        State := msInit;
      end;
    msStartAnswer:
      begin
        SD.InB := '';
        Log(ltInfo, 'Answering call');
        SD.StateDeltaDCD := msCN_ConnectDCD;
        SetTmrPublic(180, msInit);
        ClearTmr1;
        State := msAnswering;
        SetStatusMsg(rsMMAnswering, '');
        if SendModemString(EP.StrValueD(eiModemCmdAnswer, SD.ModemRec.Cmds.Answer)) then
        begin
          SD.LogEntireModemInput := True;
        end else
        begin
          State := msError;
        end;
      end;
    msRinging,
    msDialling:
      case ModemResponseCn of
        mrpNone: ;
        mrpConnect:
          State := msCN_ConnectString;
        mrpBusy:
          State := msSE_Busy;
        mrpRinging:
          begin
            Inc(SD.RingCount);
            Log(ltInfo, SD.LastResponse);
            State := msRinging
          end;
        else
          begin
            Log(ltWarning, SD.LastResponse);
            State := msSE_NoConnect;
          end;        
      end;
    msAnswering:
      if not ChkFax then
      case ModemResponseCn of
        mrpNone: ;
        mrpRing: ;
        mrpConnect:
          State := msCN_ConnectString;
        else
          State := msSE_NoConnect;
      end;
    msCarrierLost:
      begin
        Log(ltWarning, 'Carrier lost');
        State := msSE_SessionAborted;
      end;
    msHandshakeTimeout:
      begin
        Log(ltWarning, 'Handshake time-out - disconnecting');
        State := msSE_SessionAborted;
      end;
    msCancel:
      begin
        Log(ltWarning, 'Cancel requested');
        State := msInit;
      end;
    msSE_OK:
      begin
        State := msSE_OKa;
        if CP.DCD then begin HangupModem; SD.SkipHangup := True end;
      end;
    msSE_OKa:
      begin
        DoFinalize;
        State := msSE_OKb;
      end;
    msSE_OKb:
      begin
        if SD.ActivePoll <> nil then FinalizePollOK(SD.ActivePoll);
        State := msSE_OKc;
      end;
   msSE_OKc:
      begin
        Log(ltWarning, 'Session completed successfully');
        State := msInit;
      end;
    msSE_SessionAborted:
      begin
        Log(ltWarning, 'Session aborted');
        DoSE_SessionAborted;
        State := msInit;
      end;
    ms_WrongOutDial:
      begin
        DS.rmtAddressList := Trim(DS.rmtAddressList);
        if DS.rmtAddressList <> '' then LogFmt(ltGlobalErr, 'Session with %s when dialled %s - disconnecting', [DS.rmtAddressList, Addr2Str(SD.ActivePoll.Node.Addr)]);
        State := msSE_SessionAborted;
      end;
    ms_NoValidAddr:
      begin
        Log(ltGlobalErr, 'Remote presented no valid addresses - disconnecting');
        State := msSE_SessionAborted;
      end;
    msSE_Busy:
      begin
        DoSE_Busy;
        State := msInit;
      end;
    msSE_NoConnect:
      begin
        DoSE_NoConnect;
        State := msInit;
      end;
    else GlobalFail('%s', ['TMailerThread.DoMisc ??']);
  end;
end;

procedure TMailerThread.PostTermStr;
var
  us: TUpdateTermStruc;
begin
  us := TUpdateTermStruc.Create;
  us.Thr := Self;
  us.Str := StrAsg(AStr);
  us.Top := ATop;
  us.CrL := ACrLf;
  us.Lit := ALit;
  PostMsgP(WM_UPDATETERM, us);
end;

procedure TMailerThread.DoAccumulate;
var
  AddStr: string;

procedure Get;
var
  S: ShortString;
  sl: byte absolute S;
  C: Byte;
begin
  repeat
    S := '';
    while CP.GetChar(C) do
    begin
      Inc(sl);
      s[sl] := Char(C);
      if sl = 255 then Break;
    end;
    AddStr := AddStr + s;
  until not CP.CharReady;
end;

var
  I: Integer;
begin
  SD.Accumulated := (CP <> nil) and (CP.CharReady);
  if not SD.Accumulated then Exit;
  AddStr := '';
  Get;
  SD.InB := SD.InB + AddStr;
  SD.InC := SD.InC + AddStr;
  SD.DirtyInC := True;
  i := Length(AddStr) - TermTxData.Volume;
  if i > 0 then Delete(AddStr, 1, i);
  PostTermStr(AddStr, False, not SD.NoCrLf, False);
  ReScanColl(SD.InC, [SD.InputFmtREs, SD.InputWdResetREs, SD.InputWdExtAppREs, SD.LoginWdREs]);
  i := Length(SD.InC);
  if i > 5000 then
  begin
    Dec(i, 4000);
    Delete(SD.InC, 1, i);
    ReScannerDecColl(i, [SD.InputFmtREs, SD.InputWdResetREs, SD.InputWdExtAppREs, SD.LoginWdREs]);
  end;
end;

procedure TMailerThread.UpdateModem;

procedure CollFromAtom(var C: TColl; EvtIdx: Integer);
var
  dm: TEvParDMemo;
  R: TColl;
  i: Integer;
begin
  FreeObject(C);
  C := TColl.Create;
  R := EP.GetAtomList(EvtIdx);
  for i := 0 to CollMax(R) do
  begin
    dm := R[i];
    Replace(#13, '', dm.MemoA);
    Replace(#10, '', dm.MemoA);
    C.Add(TResponseFormatHolder.Create(StrAsg(dm.MemoA), StrAsg(dm.MemoB), Logger));
  end;
  FreeObject(R);
end;

procedure CreateInputWdExtAppREs;
var
  ds: TEvParDStr;
  R: TColl;
  i: Integer;
begin
  FreeObject(SD.InputWdExtAppREs);
  SD.InputWdExtAppREs := TColl.Create;
  R := EP.GetAtomList(eiInputWdExtApp);
  for i := 0 to CollMax(R) do
  begin
    ds := R[i];
    SD.InputWdExtAppREs.Add(TReWdExtAppHolder.Create(StrAsg(ds.StrA), StrAsg(ds.StrB), Self));
  end;
  FreeObject(R);
end;


procedure CreateInputWdResetREs;
var
  ds: TEvParString;
  R: TColl;
  i: Integer;
begin
  FreeObject(SD.InputWdResetREs);
  SD.InputWdResetREs := TColl.Create;
  R := EP.GetAtomList(eiInputWdReset);
  for i := 0 to CollMax(R) do
  begin
    ds := R[i];
    Replace(#13, '', ds.s);
    Replace(#10, '', ds.s);
    SD.InputWdResetREs.Add(TReWdResetHolder.Create(ds.s, Self));
  end;
  FreeObject(R);
end;


var
  Modems, Lines: TElementColl;
begin
  if SD = nil then Exit;
  if (SD.ModemRec <> nil) and TimerInstalled(SD.LastModemUpd) and (not TimerExpired(SD.LastModemUpd)) then Exit;
  NewTimerSecs(SD.LastModemUpd, 10);
  FreeObject(SD.ModemRec);
  CfgEnter;
  Modems := Pointer(Cfg.Modems.Copy);
  Lines := Pointer(Cfg.Lines.Copy);
  CfgLeave;
  SD.ModemRec := Modems.GetRecById(EP.DwordValueD(eiRplModem, TLineRec(Lines.GetRecById(LineId)).d.ModemId)).Copy;
  FreeObject(Modems);
  FreeObject(Lines);
  if SD.DirtyInC then SD.DirtyInC := False else
  begin
    SD.InC := '';
    CollFromAtom(SD.RespFmtREs, eiResponseFormat);
    CollFromAtom(SD.InputFmtREs, eiInputFormat);
    CreateInputWdResetREs;
    CreateInputWdExtAppREs;
  end;
end;


procedure TMailerThread.Initialize;
var
  lr: TLineRec;
  s: string;
begin
  EP := TMailerThreadEventProcessor.Create;
  EP.LineId := LineId;
  D.StatusMsg := rsMMInit;
  if ProtCore <> ptBinkP then Priority := tpLower;

  {$IFDEF WS}
  if not DialupLine then
  begin
    Inc(IpIdx); while IdxFound(IpIdx) do Inc(IpIdx);
    __FName := Format('TCP/IP %d', [IpIdx]);
    CurrentIPFlag := TLockFile.Create(MakeNormName(HomeDir, 'current.ip'), SimpleBSY);
  end else
  {$ENDIF}
  begin
    CfgEnter;
    __FName := StrAsg(Cfg.Lines.GetRecById(LineId).Name);
    CfgLeave;
  end;




  case ProtCore of
    ptDialup, ptifcico, ptTelnet:
      SD.SessionCore := scEmsiWz;
    ptBinkP:
      SD.SessionCore := scBinkP;
    else GlobalFail('%s', ['TMailerThread.Initialize ProtCore ??']);
  end;

  Logger := TMailerThreadLogger.Create;
  Logger.MailerThread := Self;

  EvtQueue := TColl.Create;
  oEvt := CreateEvt(False);
  EvtNew := False;
  InitializeCriticalSection(EvtCS);
  InitializeCriticalSection(DisplayDataCS);

  {$IFDEF WS} if DialupLine then
  begin
    toEMSI_CR      := EMSI_CR_d;
    toEMSI_S3      := EMSI_S3_d;
    toEMSI_Block   := EMSI_Bl_d;
    toEMSI_Timeout := EMSI_Tm_d;
  end;
  if not DialupLine then
  begin
    toEMSI_CR      := EMSI_CR_i;
    toEMSI_S3      := EMSI_S3_i;
    toEMSI_Block   := EMSI_Bl_i;
    toEMSI_Timeout := EMSI_Tm_i;
    if SD.ActivePoll = nil then DS.ConnectString := 'From %s #%d' else DS.ConnectString := 'To %s #%d';
    DS.ConnectString := Format(DS.ConnectString, [CP.CallerId, IpPort]);
    if SD.ActivePoll = nil then DS.rmtPhone := CP.CallerId else DS.rmtPhone := SD.ActivePoll.IPAddr;
    SD.ConnectSpeed := CP.DTE;
    if ProtCore = ptBinkP then
    begin
      State := msStartBinkP;
    end else
    begin
      State := msCN_HandshakeStart;
      SD.StateDeltaDCD := msCarrierLost;
      SetTmrPublic(300, msHandshakeTimeout);
      SD.Accumulate := True;
    end;
    s := Format('CONNECT %s', [DS.ConnectString]);
    if SD.ActivePoll <> nil then s := s + Format(' (%s)', [Addr2Str(SD.ActivePoll.Node.Addr)]);
    LogDaemon(s);
  end else
  {$ENDIF} State := msStart;

  CP.SetDeltaDCDNotify(oEvt);
  CP.SetCommErrorNotify(oEvt);

  ProcessColl := TColl.Create;

  LogStrings := TStringColl.Create;
  InitializeCriticalSection(LogCS);

  {$IFDEF WS}
  if not DialupLine then LogFName := Format('IP_%d.LOG', [IpIdx]) else
  {$ENDIF}
  begin
    CfgEnter;
    lr := Pointer(Cfg.Lines.GetRecById(LineId));
    LogFName := StrAsg(lr.LogFName);
    CfgLeave;
  end;

  if LogFName = '' then
  begin
    Log(ltInfo, 'No log file specified for current line');
  end else
  begin
    LogFName := MakeFullDir(dLog, LogFName);
    LogFmt(ltInfo, cUsingLogFile, [LogFName]);
    if _LogOK(LogFName, LogFHandle) then
    begin
      if StartupOptions and stoFastLog = 0 then ZeroHandle(LogFHandle);
    end else
    begin
      SetErrorMsg(LogFName);
      ChkErrMsg;
      Log(ltWarning, 'File logging disabled');
    end;
  end;


  {$IFDEF WS}
  if not DialupLine then __LineNumber := IpIdx else
  {$ENDIF}
  begin
    CfgEnter;
    __LineNumber := Cfg.Lines.GetIdxById(LineId) + 1;
    CfgLeave;
  end;

  ActiveFile := TLockFile.Create(MakeNormName(HomeDir, 'active.'+Name), SimpleBSY);
end;


procedure TMailerThread.ClearTmr1;
begin
  ClearTimer(SD.Tmr1);
  SD.StateTmr1 := msNone;
end;

procedure TMailerThread.SetTmr1(TimeoutSecs: DWORD; NewStatus: TMailerState);
begin
  NewTimerSecs(SD.Tmr1, TimeoutSecs);
  SD.StateTmr1 := NewStatus;
end;

procedure TMailerThread.SetTmr1Msec(TimeoutMSecs: DWORD; NewStatus: TMailerState);
begin
  NewTimerMSecs(SD.Tmr1, TimeoutMSecs);
  SD.StateTmr1 := NewStatus;
end;


procedure TMailerThread.SetTmrPublic(TimeoutSecs: DWORD; NewStatus: TMailerState);
begin
  NewTimerSecs(D.TmrPublic, TimeoutSecs);
  SD.StateTmrPublic  := NewStatus;
  DisplayData;
end;

procedure TMailerThread.ClearTmrPublic;
begin
  ClearTimer(D.TmrPublic);
  SD.StateTmrPublic := msNone;
  DisplayData;
end;


procedure TMailerThread.DoEvt;
const
  EvtPerPass = 1;
var
  ExitNow: Boolean;
  MlrEvt: TMlrEvt;
  Count: Integer;
begin
  Count := 0; ExitNow := False;
  repeat
    EnterCS(EvtCS);
    if (EvtQueue.Count = 0) or (Count >= EvtPerPass)  then
    begin
      if EvtQueue.Count = 0 then
      begin
        ResetEvt(oEvt);
        EvtNew := False;
      end;
      MlrEvt := nil;
      ExitNow := True;
    end else
    begin
      MlrEvt := EvtQueue[0];
      EvtQueue.AtDelete(0);
      Inc(Count);
    end;
    LeaveCS(EvtCS);
    if MlrEvt <> nil then MlrEvt.Execute(Self);
    FreeObject(MlrEvt);
  until ExitNow;
end;

procedure TMailerThread.CheckDuration;
const
  ADurMax: array[Boolean] of Integer = (eiAccDurMax, eiTrsDurMax);
var
  D: DWORD;
  I: Integer;
begin
  if SD.AtomDisconnected then Exit;
  if SD.Prot = nil then Exit;
  D := EP.DwordValueD(ADurMax[SD.ActivePoll <> nil], DWORD(MaxInt));
  if D = DWORD(MaxInt) then Exit;
  I := uGetSystemTime - SD.SessionStart;
  if I < 0 then Exit;
  if (DWORD(I) < D*60) then Exit;
  LogFmt(ltGlobalErr, 'Session duration excceeds %d minute(s) - disconnecting', [D]);
  InsertEvt(TMlrEvtChStatus.Create(msCancel));
  SD.AtomDisconnected := True;
end;

procedure TMailerThread.UpdateData;
begin
  CheckCPS;
  CheckDuration;
  EnterCS(DisplayDataCS);
  D.Initialised := True;
  PublicD := D;
  PublicDS := DS;
  case State of
    msIdle,
    msIdleA,
    msWaitNextRing: PublicD.CanAnswer := True;
    else PublicD.CanAnswer := False;
  end;
  if CP = nil then
  begin
    PublicD.NoCP := True;
    PublicD.CPOutUsed := 0;
  end else
  begin
    PublicD.NoCP := False;
    PublicD.CPOutUsed := CP.OutUsed;
  end;
  PublicD.txTot := SD.txMail + SD.TxFiles;
  FreeObject(PubBatchT);
  FreeObject(PubBatchR);
  if SD.Prot <> nil then
  begin
    PublicD.ProtTotalErrors := SD.Prot.TotalErrors;
    PublicDS.ProtName := SD.Prot.Name;
    if SD.Prot.T <> nil then PubBatchT := SD.Prot.T.Copy;
    if SD.Prot.R <> nil then PubBatchR := SD.Prot.R.Copy;
  end;
  LeaveCS(DisplayDataCS);
end;

procedure TMailerThread.LogComError;

procedure LogSerial;
var
  ee: TComError;
  j: Integer;
  z: string;
begin
  z := '';
  ee := CP.ComErrorColl[0];
  for j := 0 to CE_MsgNum-1 do
  begin
    if ee.Err and CE_Msg[j].i <> 0 then
    begin
      if z <> '' then AddStr(z, '|');
      z := z + CE_Msg[j].s;
    end;
  end;
  LogFmt(ltWarning, 'ComError %s, In=%sb, OutB=%sb', [z, Int2Str(ee.cs.cbInQue), Int2Str(ee.cs.cbOutQue)]);
end;

{$IFDEF WS}
procedure LogSock;
var
  ee: TComError;
  S: string;
begin
  ee := CP.ComErrorColl[0];
  S := Format('SockError WS%.5d (%s)', [ee.Err, WSAErrMsg(ee.Err)]);
  Log(ltWarning, S);
  LogDaemon(S);
end;
{$ENDIF}

begin
  CP.EnterCommErrorCS;
  while CP.ComErrorColl.Count > 0 do
  begin
    {$IFDEF WS} if not DialupLine then LogSock else {$ENDIF}
    LogSerial;
    CP.ComErrorColl.AtFree(0);
  end;
  CP.LeaveCommErrorCS;
end;


procedure TMailerThread.LetsSleep;
var
  Actually, NumEvents, ToSleep: DWORD;
  Count: Integer;
begin
  if EvtNew then DoEvt else
  if (OldState = State) then
  begin
    if SD.Accumulate then DoAccumulate else SD.Accumulated := False;
    if not SD.Accumulated then
    begin
      UpdateData;
      if TimerInstalled(D.TmrPublic) and TimerExpired(D.TmrPublic) then
      begin
        State := SD.StateTmrPublic;
        ClearTmrPublic;
      end else
      if TimerInstalled(SD.Tmr1) and (TimerExpired(SD.Tmr1)) then
      begin
        State := SD.StateTmr1;
        ClearTmr1;
      end else
      if (SD.StateDeltaDCD <> msNone) and (CP <> nil) and (CP.DCD <> CP.Carrier) then
      begin
        CP.Carrier := not CP.Carrier;
        State := SD.StateDeltaDCD;
        SD.StateDeltaDCD := msNone;
      end else
      if (CP = nil) or (not CP.CharReady) then
      begin
        ToSleep := MultiTimeout([D.TmrPublic, SD.Tmr1]);
        if State = msIdle then ToSleep := MinD(ToSleep, MultiTimeout([SD.TmrReInit]));
        if SD.Prot <> nil then ToSleep := MinD(ToSleep, SD.Prot.TimeoutValue);
        if ToSleep > 0 then
        begin
          NumEvents := 1;
          WaitEvts[0] := oEvt;
          if SD.NiagaraSession then ToSleep := 20 else
          begin
            if CP <> nil then
            begin
              WaitEvts[NumEvents] := CP.oDataAvail; Inc(NumEvents);
              if ((SD.Prot <> nil) and SD.Prot.OutFlow) or (CP.OutUsed > 0) then
              begin
                WaitEvts[NumEvents] := CP.oOutDrained;
                Inc(NumEvents);
              end;
            end;
          end;
          for Count := 0 to ProcessColl.Count-1 do
          begin
            WaitEvts[NumEvents] := TProcessNfo(ProcessColl[Count]).PI.hProcess;
            Inc(NumEvents);
          end;
          if (ToSleep) < (MaxInt div 2) then Inc(ToSleep, MinD(2000, ToSleep div 8));
          ToSleep := MaxD(25, ToSleep);
          Actually := WaitEvtA(NumEvents, @WaitEvts, ToSleep);
          if Actually = WAIT_FAILED then GlobalFail('%s', ['TMailerThread.LetsSleep WaitFailed']);
          if Actually < WAIT_ABANDONED_0 then
          begin
            if Actually = 0 then
            begin
              if (CP <> nil) and (CP.ComErrorColl.Count <> 0) then LogComError;
              DoEvt;
            end else
            if Actually + DWORD(ProcessColl.Count) >= NumEvents then
            begin
              Logger.TestRunningProcesses;
              FlushLog;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TMailerThread.DoRemoveNiagara;
var
  P: Pointer;
begin
  if not SD.NiagaraSession then Exit;
  SD.NiagaraSession := False;
  P := nil;
  EnterCS(CP_CS);
  XChg(Integer(CP), Integer(P));
  LeaveCS(CP_CS);
  if P = nil then Exit;
  RemoveNiagara(P);
  EnterCS(CP_CS);
  CP := P;
  LeaveCS(CP_CS);
end;

procedure TMailerThread.FreeCP;
var
  P: Pointer;
begin
  EnterCS(CP_CS);
  P := CP;
  CP := nil;
  LeaveCS(CP_CS);
  if P = nil then Exit;
  if SD <> nil then SD.LastCallerID := TPort(P).CallerId;
  if (P <> nil) and (SD<>nil) and (SD.NiagaraSession) then
  begin
    RemoveNiagara(P);
    SD.NiagaraSession := False;
  end;
  FreeObject(P);
end;

procedure TMailerThread.FreeHReqDelete(ALog: Boolean);
var
  i: Integer;
  s: string;
begin
  for i := 0 to CollMax(SD.HReqDelete) do
  begin
    s := SD.HReqDelete[i];
    if ALog then LogFmt(ltInfo, 'Deleting ERP "%s"', [s]);
    FidoOut.DeleteFile(SD.rmtPrimaryAddr, s, osNormal);
    DeleteFile(s);
  end;
  FreeObject(SD.HReqDelete);
end;

procedure TMailerThread.FreeFaxModem;
begin
  if SD.FaxModem = nil then Exit;
  if ForceAddFaxPage then AddFaxPage;
  WriteTIFF;
  FreeObject(SD.FaxModem);
end;

procedure TMailerThread.FreeSD;
begin
  if SD <> nil then
  begin
    FreeFaxModem;
    FreeObject(SD);
  end;
end;

destructor TMailerThread.Destroy;
begin
  FreeHReqDelete(False);
  FreeSD;
  FreeObject(EP);

// Free Classes
  FreeObject(Logger);
  FreeObject(ProcessColl);
  FreeObject(EvtQueue);
  FreeObject(OwnPolls);

  FreeObject(TermTxData);
  FreeObject(TermRxData);

  FreeObject(PubBatchT);
  FreeObject(PubBatchR);
  FreeObject(ActiveFile);

// Close Handles

  ZeroHandle(oEvt);

// Delete critical sections

  DeleteCriticalSection(EvtCS);
  DeleteCriticalSection(DisplayDataCS);
  DeleteCriticalSection(LogCS);
  DeleteCriticalSection(CP_CS);


  ZeroHandle(LogFHandle);
  FreeObject(LogStrings);
  {$IFDEF WS}
  FreeObject(CurrentIPFlag);
  {$ENDIF}

  inherited Destroy;
end;

procedure TMailerThread.DoPollsRecalc;
var
  c: TOutNodeColl;
  p: TFidoPoll;
  PubInst: Boolean;
begin
  State := msStartIdle;
  if NodelistCompilation then
  begin
    Log(ltInfo, 'Nodelist is compiling - poll calculation skipped');
    ClearTmrPublic;
    ClearTimer(TmrNextDial);
    SetStatusMsg(rsMMIdle, '');
    Exit;
  end;
  SetStatusMsg(rsMMOutChk, '');
  c := FidoOut.GetOutColl(False);
  ChkErrMsg;
  EnterFidoPolls;
  if c <> nil then
  begin
    RecreatePolls(c);
    FreeObject(c);
  end;
  PubInst := TimerInstalled(D.TmrPublic);
  if GetAvailPoll(OwnPolls, PubInst, Self, p, Logger) then
  begin
    SD.ActivePoll := p;
    State := msStartDial;
  end else
  begin
    LeaveFidoPolls;
    if PubInst then
    begin
      SetStatusMsg(rsMMWaitDial, Addr2Str(p.Node.Addr));
      if TimerInstalled(D.TmrPublic) then NewTimerSecs(SD.TmrReinit, RemainingTimeSecs(D.TmrPublic)+5) else GlobalFail('%s', ['DoPollsRecalc/TimerInstalled']);
    end else
    begin
      ClearTmrPublic;
      ClearTimer(TmrNextDial);
      SetStatusMsg(rsMMIdle, '');
    end;
  end;
end;

function TMailerThread.Name: string;
begin
  Result := StrAsg(__FName);
end;

function TMailerThread.LineNumber: DWORD;
begin
  Result := __LineNumber;
end;

procedure TMailerThread.InsertEvt(E: TMlrEvt);
begin
  EnterCS(EvtCS);
  EvtQueue.Insert(E);
  SetEvt(oEvt); EvtNew := True;
  LeaveCS(EvtCS);
end;


procedure TMailerThread.CreateStation;
begin
  SD.Station := TStationDataColl.Create;
  SD.AkaA := TStringColl.Create;
  SD.AkaB := TStringColl.Create;
end;

{$IFDEF WS}
procedure TMailerThread.CopyIPStation;
begin
  Cfg.IpData.StationData.AppendTo(SD.Station);
  Cfg.IpAkaCollA.AppendTo(SD.AkaA);
  Cfg.IpAkaCollB.AppendTo(SD.AkaB);
end;
{$ENDIF}


function TMailerThread.GetInAKAs: string;
var
  i: Integer;
begin
  for i := 0 to CollMax(SD.rmtAddrs) do
  begin
    Result := GetOutAKAs(SD.rmtAddrs[i]);
    if Result <> SD.Station.Address then Exit;
  end;
end;

function TMailerThread.GetOutAKAs(const Addr: TFidoAddress): string;
var
  i: Integer;
begin
  Result := SD.Station.Address;
  for i := 0 to SD.AkaA.Count-1 do
  begin
    if MatchMaskAddressListSingle(Addr, SD.AkaA[i]) then
    begin
      Result := SD.AkaB[i];
      Exit;
    end;
  end;
end;


function TMailerThread.NoAnyValidAddrs: Boolean;
begin                                                 
  Result := (SD.rmtAddrs = nil) or (SD.rmtAddrs.Count = 0);
end;

procedure TMailerThread.LogFmt(CurTag: TLogTag; const FmtStr: string; const Args: array of const);
begin
  Logger.LogFmt(CurTag, FmtStr, Args)
end;

procedure TMailerThread.Log;
begin
  Logger.Log(CurTag, CurStr)
end;

procedure TMailerThread.LogOnce;
var
  i: Integer;
begin
  if SD.LoggedStrs = nil then SD.LoggedStrs := TStringColl.Create;
  if not SD.LoggedStrs.Search(@CurStr, i) then
  begin
    SD.LoggedStrs.AtInsert(i, NewStr(CurStr));
    Logger.Log(CurTag, CurStr);
  end;
end;


procedure TMailerThread.FlushLog;
var
  I: Integer;
  Actually: DWORD;
begin
  if LastLogStr = '' then Exit;
  if _LogOK(LogFName, LogFHandle) then
  begin
    I := Length(LastLogStr);
    WriteFile(LogFHandle, LastLogStr[1], I, Actually, nil);
    if StartupOptions and stoFastLog = 0 then ZeroHandle(LogFHandle);
  end;
  EnterCS(LogCS);
  if Length(NewLogStr) > $4000 then
  begin
    NewLogStr := '';
    TruncateLog := True;
  end;
  NewLogStr := StrAsg(NewLogStr + LastLogStr);
  LeaveCS(LogCS);
  LastLogStr := '';
end;


procedure TMailerThread.DeleteFile(const FName: string);
begin
  if not Windows.DeleteFile(PChar(FName)) then begin SetErrorMsg(FName); ChkErrMsg end;
end;

class function TCronThread.ThreadName: string;
begin
  Result := 'Cronner';
end;

procedure TCronThread.DoCheck;
begin
  CheckPolls;
  CheckProcesses;
end;


function TCronBaseThread.NextMinute: Boolean;
var
  Time: TSystemTime;
begin
  GetSystemTime(Time);
  Result := (Time.wMinute <> LastTimeUTC.wMinute) or (Time.wHour <> LastTimeUTC.wHour);
  if Result then
  begin
    LastTimeUTC := Time;
    GetLocalTime(LastTimeLocal);
  end;
end;

procedure TCronThread.DoRecalc;

procedure RecalcPolls;
var
  pp: TPerPollRec;
  i: Integer;
  Err: string;
begin
  FreeObject(PerPolls);
  CfgEnter;
  PerPolls := Pointer(Cfg.PerPolls.Copy);
  CfgLeave;
  for i := 0 to CollMax(PerPolls) do
  begin
    pp := PerPolls[i];
    pp.CronRec := ParseCronRec(pp.Cron, False, False, Err);
    if pp.CronRec = nil then GlobalFail('TCronThread.DoRecalc, ParseCronRec=nil; Error=%s', [Err]);
  end;
end;

procedure RecalcProcs;
var
  c: TStringColl;
begin
  FreeObject(ProcsStrs);
  FreeObject(ProcsCron);
  CfgEnter;
  c := Pointer(Cfg.CrnCollA.Copy);
  ProcsStrs := Pointer(Cfg.CrnCollB.Copy);
  CfgLeave;
  ProcsCron := ParseCronColl(c);
  FreeObject(c);
  if ProcsCron = nil then FreeObject(ProcsStrs) else
  if ProcsCron.Count <> ProcsStrs.Count then GlobalFail('TCronThread.DoRecalc RecalcProcs ProcsCron.Count(%d) <> ProcsStrs.Count(%d)', [ProcsCron.Count, ProcsStrs.Count]);
end;

begin
  Recalc := False;
  RecalcPolls;
  RecalcProcs;
  GetSystemTime(LastTimeUTC);
end;

procedure TCronThread.CheckProcesses;
var
  i: Integer;
  r: TCronRecord;
  m: Boolean;
begin
  for i := 0 to CollMax(ProcsCron) do
  begin
    r := ProcsCron[i];
    if r.IsUTC then m := CronMatch(LastTimeUTC, r) else m := CronMatch(LastTimeLocal, r);
    if m then AddToExec(ProcsStrs[i], ProcsLogger);
  end;
end;


procedure TCronThread.CheckPolls;
var
  i,j: Integer;
  c: TFidoAddrColl;
  an: TAdvNode;
  a: TFidoAddress;
  p: TPerPollRec;
  m: Boolean;
begin
  for i := 0 to CollMax(PerPolls) do
  begin
    p := PerPolls[i];
    if p.CronRec.IsUTC then m := CronMatch(LastTimeUTC, p.CronRec) else m := CronMatch(LastTimeLocal, p.CronRec);
    if m then
    begin
      c := p.AddrList; //PollsAddrs[i];
      for j := 0 to c.Count-1 do
      begin
        a := c[j];
        an := FindNode(A);
        if an = nil then Continue;
        InsertPoll(an, ptpCron);
      end;
    end;
  end;
end;

procedure TCronThread.InvokeDone;
begin
  ProcsLogger.LeaveProcesses;
end;

procedure TEventsThread.InvokeExec;
begin
  if not Again then
  begin
    Again := True;
    GetLocalTime(LastTimeLocal);
    GetSystemTime(LastTimeUTC);
    DoRecalc;
    Check;
  end;
  WaitEvts([oEvt, oRecalcEvents], 20000);
  if Terminated then Exit;
  if RecalcEvents then DoRecalc;
  if NextMinute then Check;
end;


procedure TCronThread.InvokeExec;
var
  i: Integer;
begin
  if not Again then
  begin
    Again := True;
    DoRecalc;
    DoCheck;
    WaitEvts[0] := oEvt;
  end;
  for i := 1 to ProcessColl.Count do
  begin
    WaitEvts[i] := TProcessNfo(ProcessColl[i-1]).PI.hProcess;
  end;
  if WaitEvtA(ProcessColl.Count+1, @WaitEvts, 10000) = WAIT_FAILED then GlobalFail('%s', ['TCronThread.InvokeExec WaitFailed']);
  if Terminated then Exit;
  ProcsLogger.TestRunningProcesses;
  if Recalc then DoRecalc else
  begin
    if NextMinute then DoCheck else PurgeZombies;
  end;
end;

constructor TCronBaseThread.Create;
begin
  inherited Create;
  oEvt := CreateEvtA;
end;

destructor TCronBaseThread.Destroy;
begin
  ZeroHandle(oEvt);
  inherited Destroy;
end;

constructor TCronThread.Create;
begin
  inherited Create;
  ProcsLogger := TCronThreadLogger.Create;
  Priority := tpLowest;
  ProcessColl := TColl.Create;
  ProcsLogFName := MakeNormName(dLog, 'cronapps.log');
end;

destructor TCronThread.Destroy;
begin
  FreeObject(ProcsCron);
  FreeObject(ProcsStrs);
  FreeObject(ProcessColl);
//  FreeObject(PollsCron);
//  FreeObject(PollsAddrs);
  FreeObject(PerPolls);
  FreeObject(ProcsLogger);
  ZeroHandle(ProcsLogFHandle);
  inherited Destroy;
end;

class function TEventsThread.ThreadName: string;
begin
  Result := 'Events';
end;

constructor TEventsThread.Create;
begin
  inherited Create;
  Priority := tpLowest;
  Events := TColl.Create;
end;

destructor TEventsThread.Destroy;
begin
  FreeObject(Events);
  inherited Destroy;
end;

procedure TEventsThread.DoRecalc;
var
  nc, c: TColl;
  i, ltUTC, ltLocal: Integer;
  oc: TOlEventContainer;
  e: TEventContainer;
  Err: string;
begin
  RecalcEvents := False;
  CfgEnter;
  c := Pointer(Cfg.Events.Copy);
  CfgLeave;
  nc := TColl.Create;
  for i := 0 to c.Count-1 do
  begin
    e := c[i];
    oc := TOlEventContainer.Create;
    oc.CronRec := ParseCronRec(e.Cron, e.Permanent, e.UTC, Err);
    if oc.CronRec = nil then GlobalFail('TEventsThread.DoRecalc, ParseCronRec=nil; Error=%s', [Err]);
    oc.Id := e.Id;
    oc.Len := e.Len;
    oc.Atoms := e.Atoms;
    e.Atoms := nil;
    nc.Insert(oc);
  end;
  FreeObject(c);
  ltUTC := uWin2NixTime(LastTimeUTC) div 60;
  ltLocal := uWin2NixTime(LastTimeLocal) div 60;
  for i := 0 to nc.Count-1 do
  begin
    oc := nc[i];
    if oc.CronRec.IsUTC then oc.TimeSync(ltUTC) else oc.TimeSync(ltLocal);
  end;
  Events.Enter;
  Events.FreeAll;
  Events.Concat(nc);
  Events.Leave;
  FreeObject(nc);
  UpdateGlobalEvtUpdateFlag;
end;

procedure TEventsThread.Check;
var
  i: Integer;
  oc: TOlEventContainer;
  m: Boolean;
begin
  for i := 0 to Events.Count-1 do
  begin
    oc := Events[i];
    if oc.CronRec.IsUTC then m := CronMatchP(LastTimeUTC, oc.CronRec) else m := CronMatchP(LastTimeLocal, oc.CronRec);
    if m then oc.Age := 0 else Inc(oc.Age);
  end;
end;


destructor TOlEventContainer.Destroy;
begin
  FreeObject(CronRec);
  FreeObject(Atoms);
  inherited Destroy;
end;

function TOlEventContainer.Active: Boolean;
begin
  Result := (CronRec.IsPermanent) or (Age<Len);
end;

procedure TOlEventContainer.TimeSync(lt: DWORD);
var
  i: DWORD;
  T: TSystemTime;
begin
  if CronRec.IsPermanent then Exit;
  i := lt - (Len+1);
  Age := High(Age) div 2;
  while i <= lt do
  begin
    uNix2WinTime(i*60, T);
    if CronMatch(T, CronRec) then Age := 0 else Inc(Age);
    Inc(i);
  end;
end;




{$IFDEF WS}

const
  DaemonMemSize = 4;

  NiagaraTestPort = 60179;

class function TIPPollsThread.ThreadName: string;
begin
  Result := 'Daemon Polls';
end;


constructor TIPPollsThread.Create;
begin
  inherited Create;
  DaemonExtPollThreads := TColl.Create;
  Priority := tpLower;
  oSleep := CreateEvtA;
  LogContainer := TLogContainer.Create;
  LogContainer.FTag := ltDaemon;
  LogContainer.FName := MakeNormName(dLog, 'ipdaemon.log');
  LogContainer.FMsg := WM_ADDDAEMONLOG;
  Logger := TDaemonThreadLogger.Create;
  OwnPolls := GetOwnPolls;
end;

destructor TIPPollsThread.Destroy;
begin
  FreeObject(OwnPolls);
  FreeObject(LogContainer);
  FreeObject(Logger);
  ZeroHandle(oSleep);
  inherited Destroy;
end;

function SetPortTyp(Addr, Flags: string; var Port: DWORD; var Prot: TProtCore): Boolean;
var
  sc: TStringColl;
  c: TColl;
  CurPort: DWORD;
  CurProt: TProtCore;
  i: Integer;
begin
  Result := False;
  sc := TStringColl.Create;
  sc.FillEnum(Uppercase(Flags), ',', True);
  c := TColl.Create;
  for i := 0 to sc.Count-1 do c.Add(Pointer(CRC32Str(sc[i], CRC32_INIT)));
  FreeObject(sc);
  CurPort := INVALID_VALUE;
  CurProt := ptUndefined;
  for i := 0 to c.Count-1 do
  begin
    case DWORD(c[i]) of
      kwBINKP,
      kwBINKD,
      kwBND,
      kwBNP,
      kwIBN:
        begin
          CurPort := 24554;
          CurProt := ptBinkP;
          Break;
        end;
    end;
  end;
  if CurPort = INVALID_VALUE then
  begin
    for i := 0 to c.Count-1 do
    begin
      case DWORD(c[i]) of
        kwIFC:
          begin
            CurPort := 60179;
            CurProt := ptifcico;
            Break;
          end;
      end;
    end;
  end;
  if CurPort = INVALID_VALUE then
  begin
    for i := 0 to c.Count-1 do
    begin
      case DWORD(c[i]) of
        kwTEL,
        kwTCP,
        kwVMP,
        kwIVM,
        kwIP:
          begin
            CurPort := 23;
            CurProt := ptTelnet;
            Break;
          end;
      end;
    end;
  end;
  c.DeleteAll;
  FreeObject(c);
  if CurPort = INVALID_VALUE then Exit;
  if ValidInetAddr(Addr) then
  begin
    Inet2Port(Addr, CurPort);
  end else
  if ValidSymAddr(Addr) then
  begin
    Sym2Port(Addr, CurPort);
  end else Exit;
  Port := CurPort;
  Prot := CurProt;
  Result := True;
end;

type
  TDaemonExtPollThread = class(T_Thread)
    p: TFidoPoll;
    procedure InvokeExec; override;
    class function ThreadName: string; override;
  end;

class function TDaemonExtPollThread.ThreadName: string;
begin
  Result := 'Daemon ExtPolls';
end;

procedure TDaemonExtPollThread.InvokeExec;
var
  Nfo: TProcessInformation;
  AppStr: string;
begin
  Sleep(100);
  AppStr := p.Node.Ext.Cmd;
  if RunExtApp(nil, IpPolls.Logger, 'TCP/IP Daemon', p, p.Node, AppStr, Nfo, nil, False) then
  begin
    ResumeThread(Nfo.hThread);
    WaitForExtProcess(Nfo.hProcess, p, IpPolls.Logger);
    FinalizeExtApp(Nfo, IpPolls.Logger, p);
  end else
  begin
    IpPolls.Logger.ChkErrMsg;
    if (p <> nil) and (p.Node.Ext <> nil) then FinalizeExtPoll(p, 0);
  end;
  Terminated := True;
end;


procedure TIPPollsThread.BurnOutLine(p: TFidoPoll);
var
  Prot: TProtCore;
  Port: DWORD;
  Thr: TDaemonExtPollThread;
begin
  if p.Node.Ext <> nil then
  begin
    Thr := TDaemonExtPollThread.Create;
    DaemonExtPollThreads.Enter;
    DaemonExtPollThreads.Insert(Thr);
    DaemonExtPollThreads.Leave;
    Thr.Priority := tpLower;
    Thr.p := p;
    Thr.Suspended := False;
    Exit;
  end;
  if SetPortTyp(p.IPAddr, p.IPFlags, Port, Prot) then
  _WSAConnect(p.IPAddr, p, Prot, Port);
end;

procedure TIPPollsThread.InvokeDone;
var
  i: Integer;
  t: TDaemonExtPollThread;
begin
  Logger.Log(ltInfo, 'End');
  for i := 0 to DaemonExtPollThreads.Count-1 do
  begin
    t := DaemonExtPollThreads[i];
    t.WaitFor;
    FreeObject(t);
  end;
  DaemonExtPollThreads.DeleteAll;
  FreeObject(DaemonExtPollThreads);
end;

procedure TIPPollsThread.InvokeExec;
var
  c: TOutNodeColl;
  PubInst: Boolean;
  p: TFidoPoll;
  i, mpc, pc: Integer;
  tt: TDaemonExtPollThread;
begin
  if not Again then
  begin
    Again := True;
    Logger.Log(ltInfo, 'Begin');
    Sleep(2000);
  end;

  if NodelistCompilation then
  begin
    Logger.Log(ltInfo, 'Nodelist is compiling - poll calculation skipped');
  end else
  begin
    c := FidoOut.GetOutColl(False);
    EnterFidoPolls;

    if c <> nil then
    begin
      RecreatePolls(c);
      FreeObject(c);
    end;

    DaemonExtPollThreads.Enter;
    for i := DaemonExtPollThreads.Count-1 downto 0 do
    begin
      tt := DaemonExtPollThreads[i];
      if tt.Terminated then begin tt.WaitFor; DaemonExtPollThreads.AtFree(i) end;
    end;
    DaemonExtPollThreads.Leave;

    pc := 0;
    mpc := FidoPolls.Count*2; // Trace no more than twice

    repeat
      if pc = mpc then
      begin
        LeaveFidoPolls;
        Break;
      end;
      Inc(pc);
      PubInst := False;
      if (OutConnsAvail > 0) and (not Terminated) and (GetAvailPoll(OwnPolls, PubInst, PollOwnerDaemon, p, Logger)) then
      begin
        BurnOutLine(p);
        EnterFidoPolls;
        Continue;
      end else
      begin
        LeaveFidoPolls;
        Break;
      end;
    until False;
  end;

  PurgeConnThrs;
  WaitEvt(oSleep, GetHalfAvg(60*1000));
end;


procedure _RunDaemon;
var
  D: TDaemonParams;
  OK: Boolean;
begin
  CfgEnter;
  ProxyEnabled := Cfg.Proxy.Enabled;
  ProxyAddr := StrAsg(Cfg.Proxy.Addr);
  ProxyPort := Cfg.Proxy.Port;
  CfgLeave;
  if (not ParsePortsList(@D.ifcico,Cfg.IPData.InPorts.ifcico)) or
     (not ParsePortsList(@D.Telnet,Cfg.IPData.InPorts.Telnet)) or
     (not ParsePortsList(@D.BinkP, Cfg.IPData.InPorts.BinkP)) then GlobalFail('%s', ['_RunDaemon ParsePortsList ??']);
  D.InConns := Cfg.IpData.InC;
  D.OutConns := Cfg.IpData.OutC;
  OK := RunDaemon(D);
  FreeVIntArr(D.ifcico);
  FreeVIntArr(D.telnet);
  FreeVIntArr(D.BinkP);
  if not OK then Exit;
  DaemonEvents := TDaemonEventProcessor.Create;
  IPPolls := TIpPollsThread.Create;
  IPPolls.Suspended := False;
  DaemonStarted := True;
  PurgeAdvNodeCache;
  InvalidatePollAddrs;
  _RecalcPolls;
  DaemonActiveFlag := TLockFile.Create(MakeNormName(HomeDir, 'active.ip'), SimpleBSY);
end;

{$ENDIF}


////////////////////////////////////////////////////////////////////////
//                                                                    //
//                           Common Logs                              //
//                                                                    //
////////////////////////////////////////////////////////////////////////


constructor TCommonLog.Create;
begin
  inherited Create;
  InitializeCriticalSection(CS);
end;

destructor TCommonLog.Destroy;
begin
  DeleteCriticalSection(CS);
  ZeroHandle(accessFHandle);
  ZeroHandle(agentFHandle);
  inherited Destroy;
end;

procedure TCommonLog.Add(const Addr: TFidoAddress; FName: string; Get: Boolean; FSize: DWORD; const Mailer: string);
const
  CGet: array[Boolean] of string = ('PUT', 'GET');
var
  s: string;
  b: Integer;
  Actually: DWORD;
begin
  EnterCS(CS);
  if _LogOK(accessFName, accessFHandle) then
  begin
    Replace(':', '', FName);
    Replace('\', '/', FName);
    s := uFormatDateTime('dd"/"mmm"/"yyyy:hh:nn:ss ', uGetSystemTime);
    GetBias;
    b := TimeZoneBias;
    if b < 0 then begin b := -b; s := s+'+' end else s := s + '-';
    b := b div 60;
    s := Format('%s - - [%s%.2d%.2d] "%s /%s" 200 %d'#13#10, [Addr2Str(Addr), s, b div 60, b mod 60, CGet[Get], LowerCase(FName), FSize]);
    WriteFile(accessFHandle, s[1], Length(s), Actually, nil);
    if StartupOptions and stoFastLog = 0 then ZeroHandle(accessFHandle);
  end;
  if _LogOK(agentFName, agentFHandle) then
  begin
    s := Mailer + #13#10;
    WriteFile(agentFHandle, s[1], Length(s), Actually, nil);
    if StartupOptions and stoFastLog = 0 then ZeroHandle(agentFHandle);
  end;
  LeaveCS(CS);
end;

procedure InitMailers;
begin
  CommonLog := TCommonLog.Create;
  CommonLog.accessFName := MakeNormName(dLog, GetRegStringDef('access_log', 'access_log'));
  CommonLog.agentFName := MakeNormName(dLog, GetRegStringDef('agent_log', 'agent_log'));
  PortsColl := TDevicePortColl.Create; PortsColl.Enter; PortsColl.Leave;
  FidoPolls := TPollColl.Create; FidoPolls.Enter; FidoPolls.Leave;
  MailerThreads := CreateTCollEL;
  MailerForms := CreateTCollEL;
  Zombies := CreateTCollEL;
  FileFlags := CreateTCollEL;
  CronThr := TCronThread.Create;
  EventsThr := TEventsThread.Create;
  OutMgrThread := TOutMgrThread.Create;
  CronThr.Suspended := False;
  EventsThr.Suspended := False;
  OutMgrThread.Suspended := False;
  InitializeCriticalSection(CommonStatxCS);
  CommonStatxFName := MakeNormName(dLog, GetRegStringDef('binary_log', 'binary_log'));
end;



procedure DoneMailers;
begin
  CronThr.Terminated := True; SetEvt(CronThr.oEvt);
  EventsThr.Terminated := True; SetEvt(EventsThr.oEvt);
  OutMgrThread.Terminated := True; SetEvt(OutMgrThread.oEvt);
  if (MailerThreads.Count > 0) or
     (MailerForms.Count > 0) or
     (FidoPolls.Count > 0) or
     (PortsColl.Count > 0) then GlobalFail('DoneMailers, MailerThreads.Count=%d, MailerForms.Count=%d, FidoPolls.Count=%d, PortsColl.Count=%d', [MailerThreads.Count, MailerForms.Count, FidoPolls.Count, PortsColl.Count]);
  FreeObject(MailerThreads);
  FreeObject(MailerForms);
  FreeObject(FidoPolls);
  FreeObject(FileFlags);
  FreeObject(PortsColl);
  FreeObject(CommonLog);
  CronThr.WaitFor; EventsThr.WaitFor; OutMgrThread.WaitFor;
  FreeObject(CronThr); FreeObject(EventsThr); FreeObject(OutMgrThread);
  FreeObject(Zombies);
  DeleteCriticalSection(CommonStatxCS);
  ZeroHandle(CommonStatxHandle);
end;

class function TOutMgrThread.ThreadName: string;
begin
  Result := 'Outbound Manager';
end;

constructor TOutMgrThread.Create;
begin
  inherited Create;
  ForcedUpdate := True;
  InitializeCriticalSection(NodesCS);
  oEvt := CreateEvtA;
  Priority := tpLower;
end;

destructor TOutMgrThread.Destroy;
begin
  FreeObject(OldNodes);
  FreeObject(Nodes);
  ZeroHandle(oEvt);
  DeleteCriticalSection(NodesCS);
  inherited Destroy;
end;


procedure TOutMgrThread.InvokeExec;
var
  FileNames: TStringColl;
  FileInfos: TFileInfoColl;
  NewNodes, StackNodes: TOutNodeColl;
  i, j: Integer;
  o, n: TOutNode;
  nfo: PFileInfo;
  Update: Boolean;
begin
  Update := ForcedUpdate;
  ForcedUpdate := False;
  NewNodes := FidoOut.GetOutColl(True);
  FileNames := TStringColl.Create;
  FileNames.IgnoreCase := True;
  FileInfos := TFileInfoColl.Create;
  for i := CollMax(NewNodes) downto 0 do
  begin
    n := NewNodes[i];
    if n.StatusSet = [osNone] then
    begin
      FileNames.AtInsert(FileNames.Count, NewStr(StrAsg(n.Name)));
      New(Nfo);
      Nfo^ := n.Nfo;
      FileInfos.AtInsert(FileInfos.Count, Nfo);
      NewNodes.AtFree(i);
    end;
  end;
  for i := 0 to CollMax(NewNodes) do
  begin
    n := NewNodes[i];
    if (OldNodes <> nil) and (OldNodes.Search(OldNodes.KeyOf(n), j)) then
    begin
      o := OldNodes[j];
      if (o.Nfo.Time   = n.Nfo.Time) and
         (o.Nfo.Size   = n.Nfo.Size) and
         (o.FStatus    = n.FStatus) then
      begin
        Xchg(Integer(o.Files), Integer(n.Files));
        OldNodes.AtFree(j);
        Continue;
      end;
      OldNodes.AtFree(j);
    end;
    Update := True;
    n.Files := FidoOut.GetOutbound(n.Address, n.StatusSet, nil, FileNames, FileInfos, True);
  end;
  FreeObject(FileNames);
  FreeObject(FileInfos);
  if CollCount(OldNodes) > 0 then Update := True;
  if Update then
  begin
    if NewNodes = nil then StackNodes := nil else StackNodes := NewNodes.Copy;
    EnterCS(NodesCS);
    Xchg(Integer(Nodes), Integer(StackNodes));
    LeaveCS(NodesCS);
    PostMsg(WM_UPDOUTMGR);
    FreeObject(StackNodes);
  end;
  FreeObject(OldNodes);
  XChg(Integer(OldNodes), Integer(NewNodes));
  repeat
    WaitEvt(oEvt, 10000);
  until (not ApplicationDowned) or (Terminated);
end;

{$IFDEF WS}
procedure _ShutdownDaemon;
var
  I: Integer;
begin
  IPMon.Terminated := True;
  IPPolls.Terminated := True;
  SetEvt(IPPolls.oSleep);
  FreeObject(DaemonEvents);
  EndSockMgr;
  IPPolls.WaitFor;
  EndIpThreads;
  Application.ProcessMessages;
  for i := 0 to MailerThreads.Count-1 do if not TMailerThread(MailerThreads[i]).DialupLine then TMailerThread(MailerThreads[i]).InsertEvt(TMlrEvtShutdownTerminate.Create);
  for i := 0 to MailerThreads.Count-1 do if not TMailerThread(MailerThreads[i]).DialupLine then TMailerThread(MailerThreads[i]).WaitFor;
  Application.ProcessMessages;
  MailerThreads.Enter;
  for i := MailerThreads.Count-1 downto 0 do if not TMailerThread(MailerThreads[i]).DialupLine then MailerThreads.AtFree(i);
  ShutdownDaemon;
  FreeObject(IPPolls);
  MailerThreads.Leave;
  IPMon.WaitFor;
  FreeObject(IPMon);
  DaemonStarted := False;
  PurgeAdvNodeCache;
  InvalidatePollAddrs;
  _RecalcPolls;
  FreeObject(DaemonActiveFlag);
end;
{$ENDIF}

procedure InvalidatePollAddrs;
var
  i: Integer;
  p: TFidoPoll;
  an: TAdvNode;
begin
  if FidoPolls.Count = 0 then Exit;
  FidoPollsLog('Revalidating polls');
  EnterFidoPolls;
  for i := FidoPolls.Count-1 downto 0 do
  begin
    p := FidoPolls[i];
    if p.Owner <> nil then
    begin
      p.Revalidate := True;
    end else
    begin
      an := FindNode(p.Node.Addr);
      if an = nil then
      begin
        p.Done := pdnNodeDestroyed;
        FidoPolls.AtFree(i);
      end else
      begin
        XChg(Integer(p.Node), Integer(an));
        FreeObject(an);
        p.Reset;
      end;
    end;
  end;
  LeaveFidoPolls;
end;


constructor TLogContainer.Create;
begin
  inherited Create;
  InitializeCriticalSection(CS);
  Strings := TStringColl.Create;
  FHandle := 0;
end;

destructor TLogContainer.Destroy;
begin
  DeleteCriticalSection(CS);
  ZeroHandle(FHandle);
  FreeObject(Strings);
  inherited Destroy;
end;

function  LogGetTag(t: TLogTag; var S: string; const AName: string): char;
var
  c: char;
begin
  case t of
    ltGlobalErr   : c := '!';
    ltWarning     : c := '*';
    ltInfo        : c := ' ';
    ltConnect     : c := '^';
    ltNoConnect   : c := '-';
    ltEvent       : c := 'e';
    ltEMSI        : c := '=';
    ltEMSI_1      : c := ':';
    ltDial        : c := '&';
    ltRing        : c := '#';
    ltTime        : c := '%';
    ltCost        : c := '$';
    ltFileOK      : c := '+';
    ltFileErr     : c := '?';
    ltPolls       :
      begin
        c := ' ';
        S := Format('[%s]', [AName]);
      end;
    {$IFDEF WS}
    ltDaemon      :
      begin
        c := ' ';
        S := Format('[%s]', [AName]);
      end;
    {$ENDIF}
    ltHydraNfo    : begin c := '['; S := 'Hyd:'; end;
    ltHydraMsg    : begin c := ']'; S := 'Mgs:'; end;
    ltDebug       : begin c := '@'; S := 'Dbg:'; end;
    else c := '_';
  end;
  Result := c;
end;


function FormatLogStr(CurTag: TLogTag; const CurStr, AName: string): string;
var
  Z: string;
  t: Integer;
  C: Char;
begin
  t := uGetLocalTime;
  C := LogGetTag(CurTag, Z, AName);
  Result := C+' '+uFormat(t) + ' '+Z;
  if Z <> '' then Result := Result + ' ';
  Result := Result + CurStr;
  OdbcLogAdd(AName, C, t, CurStr);
end;


function TLogContainer.FormatSelf(const S: string): string;
begin
  Result := FormatLogStr(FTag, S, 'PollMgr');
end;

procedure TLogContainer.Log(S: string);

procedure Add(const S: string);
var
  P: TStringHolder;
begin
  P := TStringHolder.Create;
  P.S := StrAsg(S);
  PostMsgP(FMsg, P);
end;


begin
  Add(S);
  EnterCS(CS);
  if _LogOK(FName, FHandle) then _LogWriteStr(S, FHandle);
  LeaveCS(CS);
end;

procedure TLogContainer.LogSelf(const S: string);
begin
  Log(FormatSelf(S));
end;

constructor TPollColl.Create;
begin
  inherited Create;
  Log := TLogContainer.Create;
  Log.FTag := ltPolls;
  Log.FName := MakeNormName(dLog, 'polls.log');
  Log.FMsg := WM_ADDPOLLSLOG;
  CfgEnter;
  Options := Cfg.PollOptions.Copy;
  CfgLeave;
end;

destructor TPollColl.Destroy;
begin
  FreeObject(Log);
  FreeObject(Options);
  inherited Destroy;
end;

procedure EnterFidoPolls;
begin
  FidoPolls.Enter;
end;

procedure LeaveFidoPolls;
begin
  FidoPolls.Leave;
end;



const

(********************************************************
 * Class 2 session parameters                           *

 * Set desired transmission params with +FDT=DF,VR,WD,LN
 * DF = Data Format :   0  1-d huffman
 *                      *1 2-d modified Read
 *                      *2 2-d uncompressed mode
 *                      *3 2-d modified modified Read
 *
 * VR = Vertical Res :  0 Normal, 98 lpi
 *                      1 Fine, 196 lpi
 *
 * WD = width :         0  1728 pixels in 215 mm
 *                      *1 2048 pixels in 255 mm
 *
 * LN = page length :   0 A4, 297 mm
 *                      1 B4, 364 mm
 *                      2  Unlimited
 *
 * EC = error correction :      0 disable ECM
 *
 * BF = binary file transfer :  0 disable BFT
 *
 * ST = scan time/line :        VR = normal     VR = fine
 *                         0    0 ms            0 ms
 *
 *)

 // data format

  FAX_DF_1DHUFFMAN  = 0;
  FAX_DF_2DMREAD    = 1;
  FAX_DF_2DUNCOMP   = 2;
  FAX_DF_2DMMREAD   = 3;

 // vertical resolution

  FAX_VR_NORMAL = 0;
  FAX_VR_FINE   = 1;

 // width

  FAX_WD_1728 = 0;
  FAX_WD_2048 = 1;
  FAX_WD_2432 = 2;
  FAX_WD_1216 = 3;
  FAX_WD_0864 = 4;


 // page length

  FAX_LN_A4        = 0;
  FAX_LN_B4        = 1;
  FAX_LN_UNLIMITED = 2;

 // Baud rate

  FAX_BR_2400 = 0;
  FAX_BR_4800 = 1;
  FAX_BR_7200 = 2;
  FAX_BR_9600 = 3;


  htre: array[0..1] of array[0..107] of array[0..1] of Integer = (
// white tree

  ((1, 96), (2, 58), (3, 40), (4, 30), (5, 27), (6, 25), (7, 24), (8,
  12), (9, -89992), (10, -89991), (11, -89990), (-89988, -89989), (13,
  19), (14, 16), (-98208, 15), (-98016, -97952), (17, 18), (-97888,
  -97824), (-97760, -97696), (20, 21), (-98144, -98080), (22, 23),
  (-97632, -97568), (-97504, -97440), (-99971, -99970), (26, -99978),
  (-99955, -99954), (28, -99987), (-99977, 29), (-99953, -99952), (31,
  37), (32, 34), (-99980, 33), (-99967, -99966), (35, 36), (-99965,
  -99964), (-99963, -99962), (38, -99999), (-99981, 39), (-99969,
  -99968), (41, 51), (42, 45), (-99988, 43), (44, -99974), (-99947,
  -99946), (46, 49), (47, 48), (-99961, -99960), (-99959, -99958),
  (50, -99979), (-99957, -99956), (52, -99990), (53, 55), (-99972,
  54), (-99939, -99938), (56, 57), (-99937, -90000), (-99680, -99616),
  (59, 78), (60, 68), (-99989, 61), (62, 64), (-99973, 63), (-99941,
  -99940), (65, -99982), (66, 67), (-98528, -98464), (-98400, -98272),
  (69, 74), (70, 72), (-99976, 71), (-99951, -99950), (73, -99975),
  (-99949, -99948), (75, -99808), (76, 77), (-99945, -99944), (-99943,
  -99942), (79, -99998), (80, 85), (-98336, 81), (82, 83), (-99552,
  -99488), (84, -99360), (-99296, -99232), (86, 92), (87, 89),
  (-99424, 88), (-99168, -99104), (90, 91), (-99040, -98976), (-98912,
  -98848), (93, -99744), (94, 95), (-98784, -98720), (-98656, -98592),
  (97, 103), (98, 100), (-99997, 99), (-99872, -99992), (101, -99996),
  (-99991, 102), (-99984, -99983), (104, 107), (-99995, 105), (106,
  -99936), (-99986, -99985), (-99994, -99993)),

// black tree

  ((1, 107), (2, 106), (3, 105), (4, 103), (5, 82), (6, 57), (7, 24),
  (8, 12), (9, -89992), (10, -89991), (11, -89990), (-89988, -89989),
  (13, 19), (14, 16), (-98208, 15), (-98016, -97952), (17, 18),
  (-97888, -97824), (-97760, -97696), (20, 21), (-98144, -98080), (22,
  23), (-97632, -97568), (-97504, -97440), (25, 41), (26, 32),
  (-99982, 27), (28, 30), (-99948, 29), (-99360, -99296), (31,
  -99945), (-99232, -99168), (33, 38), (34, 36), (-99944, 35),
  (-98720, -98656), (37, -99941), (-98592, -98528), (39, -99976),
  (-99940, 40), (-98464, -98400), (42, 50), (43, 46), (-99975, 44),
  (45, -99680), (-98336, -98272), (47, 48), (-99616, -99552), (49,
  -99947), (-99488, -99424), (51, -99936), (52, 54), (-99946, 53),
  (-99104, -99040), (55, 56), (-98976, -98912), (-98848, -98784), (58,
  70), (-99987, 59), (60, 66), (61, 63), (-99977, 62), (-99950,
  -99949), (64, 65), (-99956, -99955), (-99954, -99953), (67, -99984),
  (68, 69), (-99943, -99942), (-99939, -99744), (71, -99986), (72,
  76), (-99983, 73), (74, 75), (-99952, -99951), (-99938, -99937),
  (77, 80), (78, 79), (-99970, -99969), (-99968, -99967), (81,
  -99978), (-99960, -99959), (83, 84), (-99990, -99989), (85, -99988),
  (86, 93), (-99985, 87), (88, 91), (89, 90), (-99872, -99808),
  (-99974, -99973), (92, -99981), (-99972, -99971), (94, 100), (95,
  97), (-99980, 96), (-99966, -99965), (98, 99), (-99964, -99963),
  (-99962, -99961), (101, -90000), (-99979, 102), (-99958, -99957),
  (104, -99993), (-99991, -99992), (-99994, -99995), (-99999, -99996),
  (-99997, -99998)
));



type
  TFaxPage = class
    T30: TFaxT30Params;
    FStream: TxMemoryStream;
    Time, BadLines, cBadLines, x, y: DWORD;
    Id: string;
    destructor Destroy; override;
  end;

const
  MaxPageWidth = 4;
  PageWidths : array[0..MaxPageWidth] of Integer = (1728, 2048, 2432, 1216, 0864);


function ConvertFaxPage(T30_wd: DWORD; Stream: TxMemoryStream): Pointer;
var
  EOLcnt, ZCnt, StartPos, EndPos, FSize, PageWidth, cBadLines, MaxcBadLines, BadLines, strlen, c,
  ip, lines, i, j: Integer;
  P: PxbyteArray;
  b: Byte;
  FirstEOL, SeekEOL: Boolean;
  g: TFaxPage;

procedure Reset;
begin
  strlen := 0;
  ip := 0;
  c := 0;
end;

procedure NewLine;
begin
  Inc(lines);
  EOLcnt := 0;
  Reset;
end;

procedure SetEOL;
begin
  if FirstEOL then
  begin
    FirstEOL := False;
    StartPos := i - 1;
    if j < 4 then Dec(StartPos);
  end;
  if strlen > 0 then
  begin
    if strlen = PageWidth then cbadlines := 0;
    NewLine;
  end else Reset;
  Inc(EOLcnt);
  if EOLcnt = 5 then
  begin
    EndPos := i;
    i := FSize;
  end;
end;

procedure ErrorCode;
begin
  NewLine;
  Inc(BadLines);
  Inc(cbadlines);
  maxcbadlines := MaxI(maxcbadlines, cbadlines);
  SeekEOL := True;
end;


procedure IsLine(len: Integer);
begin
  Inc(strlen, len);
  if len < 64 then
  begin
    c := 1 - c; // invert color
  end;
  if StrLen > PageWidth then ErrorCode;
end;

begin

  if (T30_wd = INVALID_VALUE) or
     (T30_wd > MaxPageWidth) then
  begin
    PageWidth := MaxInt;
  end else
  begin
    PageWidth := PageWidths[T30_wd];
  end;

  FirstEOL := True;

  FSize := Stream.Size;

  StartPos := 0;
  EndPos := FSize;

  P := Stream.Memory;
  badlines := 0;
  cbadlines := 0;
  maxcbadlines := 0;
  lines := -1;

  ip := 0;
  strlen := 0;
  c := 0; // white first
  EOLcnt := 0;

  i := -1;
  zcnt := 0;
  while i < Integer(FSize) do
  begin
    Inc(i);
    b := P^[i];
    j := 0;
    while j < 8 do
    begin
      inc(j);

      if SeekEOL then
      begin
        if (b and 1) = 0 then Inc(Zcnt) else
        begin
          if Zcnt >= 11 then
          begin
            SetEOL;
            SeekEOL := False
          end;
          Zcnt := 0;
        end;
      end else
      begin
        ip := htre[c][ip][b and 1];
        if ip < 0 then
        begin
          Inc(ip, 100000);
          case ip of
            10000: IsLine(0);
            10008,
            10009,
            10010:
              begin
                ErrorCode;
              end;
            10011:
              begin
                SetEOL;
              end;
            10012:
              begin
                Zcnt := 12;
                SeekEOL := True;
              end;
            else
              IsLine(ip);
          end;
          ip := 0;
        end;
      end;
      b := b shr 1;
    end;
  end;

  g := TFaxPage.Create;
  g.FStream := TxMemoryStream.Create;
  if EndPos > StartPos then g.FStream.Write(P^[StartPos], EndPos - StartPos);
  if PageWidth = MaxInt then g.x := INVALID_VALUE else g.x := PageWidth;
  if Lines <= 0 then g.y := INVALID_VALUE else g.y := Lines;
  g.BadLines := BadLines;
  g.cBadLines := MaxcBadLines;
  Result := g;
end;


procedure TMailerThread.AddFaxPage;

function DoConvert: TFaxPage;
begin
  Result := ConvertFaxPage(SD.FaxModem.T30.wd, SD.FaxModem.FStream);
  Result.Id := SD.Faxmodem.RemoteId;
  Result.T30 := SD.Faxmodem.T30;
  Result.Time := SD.Faxmodem.PageTime;
end;

var
  pd, pr: TFaxPage;
begin
  if SD.Faxmodem.FStream = nil then Exit;
  if SD.Faxmodem.FStream.Size = 0 then
  begin
    Log(ltWarning, 'Empty page');
  end else
  begin
    pd := DoConvert;
    BlockRBO(SD.Faxmodem.FStream.Memory^, SD.Faxmodem.FStream.Size);
    pr := DoConvert;
    if pd.BadLines > pr.BadLines then XChg(Integer(pd), Integer(pr));
    FreeObject(pr);
    if SD.Faxmodem.Pages = nil then SD.Faxmodem.Pages := TColl.Create;
    SD.Faxmodem.Pages.Insert(pd);
  end;
  FreeObject(SD.Faxmodem.FStream);
end;


procedure TMailerThread.ParseFaxResponse(const Astr: string);
var
  sl: Integer;
  s, z: string;

// Look for +FCON, +FDCS, +FDIS, +FHNG, +FHS, +FPTS, +FK, +FTSI

function Begs(const SubStr: string): Boolean;
var
  ll: Integer;
begin
  ll := Length(SubStr);
  Result :=  StrBegsF(SubStr, ll, s, sl);
  if Result then
  begin
    Delete(s, 1, ll);
    Dec(sl, ll);
  end;
end;

procedure GW(var i: DWORD);
begin
  GetWrd(s, z, ',');
  i := Vl(z);
end;

begin
  s := AStr;
  sl := Length(s);

  Log(ltInfo, s);

  if Begs('AT') then Exit; // local echo

  if Begs('+F') then
  begin
    // Got facsimile response
    if s = 'CON' then // DCE response, Fax connection made
    begin
      SD.Faxmodem.fcon := True;
      Exit;
    end;
    if s = 'CO' then // Class 2.0
    begin
      SD.Faxmodem.fco := True;
      Exit;
    end;
    if Begs('DCS:') or  // Current session parameter
       Begs('CS:') then // Class 2.0
    begin
      SD.Faxmodem.ReadyT30 := True;
      with SD.Faxmodem.T30 do
      begin
        GW(vr);
        GW(br);
        GW(wd);
        GW(ln);
        GW(df);
        GW(ec);
        GW(bf);
        GW(st);
      end;
      Exit;
    end;
    if Begs('HNG:') or  // Call termination status response
       Begs('HS:') then // Class 2.0
    begin
      GetWrd(s, z, ',');
      SD.Faxmodem.Hangup := Vl(z);
      Exit;
    end;

    if Begs('PTS:') or   // Page transfer status // +FPTS:<ppr>,<lc>[,<blc>,<cblc>]
       Begs('PS:') then  // Class 2.0
    begin
      GW(SD.Faxmodem.PostPageResp);
      GW(SD.Faxmodem.pts_lc);
      GW(SD.Faxmodem.pts_blc);
      GW(SD.Faxmodem.pts_cblc);
      Exit;
    end;

    if Begs('TSI:') or  // Report remote ID response TSI
       Begs('CI:') then // Class 2.0
    begin
      if BothKVC(s) then begin DelFC(z); DelLC(z) end;
      SD.Faxmodem.RemoteId := Trim(s);
      Exit;
    end;

    if Begs('ET:') then // End the page or document command
    begin
      GW(SD.Faxmodem.PostPageMsg);
      Exit;
    end;

   Exit;  // Unexpected +F response :-)

  end;

  if Begs('CONNECT') then
  begin
    SD.Faxmodem.Connect := True;
    Exit;
  end;

  if Begs('NO CARRIER') or Begs('ERROR') then
  begin
    SD.Faxmodem.Error := True;
    Exit;
  end;

  if Begs('OK') then
  begin
    SD.Faxmodem.OK := True;
    Exit;
  end;

end;

procedure TMailerThread.GetFaxFName(const Aext: string);
var
  ST: TSystemTime;
  FT: TuFindData;
  s: string;
  MaxN: DWORD;
  D: DWORD;
begin
  GetLocalTime(ST);
  MaxN := 0;
  s := MakeNormName(FaxInbound, Format('%.2d%s???.'+Aext, [ST.wDay, ShortMonthNames[ST.wMonth]]));
  if uFindFirst(s, FT) then
  begin
    repeat
      s := Copy(FT.FName, 6, 3);
      D := Vl(s);
      if D <> INVALID_VALUE then MaxN := MaxD(MaxN, D);
    until not uFindNext(FT);
    uFindClose(FT);
  end;
  Inc(MaxN);
  SD.Faxmodem.FName := MakeNormName(FaxInbound, Format('%.2d%s%.3d.'+Aext, [ST.wDay, ShortMonthNames[ST.wMonth], MaxN]));
end;

procedure TMailerThread.ReportT30(var t: TFaxT30Params);
const
  ast: array[0..1] of array[0..7] of Byte = (
    (0, 5, 10, 10, 20, 20, 40, 40),
    (0, 5,  5, 10, 10, 20, 20, 40)
  );
var
  svr, sbr, swd, sln, sdf, sec, sbf, sst: string;
begin
  case t.vr of
    FAX_VR_NORMAL : svr := 'Normal, 98 LPI';
    FAX_VR_FINE   : svr := 'Fine, 196 LPI';
    else svr := Format('VR(%d)', [t.vr]);
  end;
  sbr := Format('%d BPS', [t.br * 2400]);
  case t.wd of
    FAX_WD_1728 : swd := '1728 pixels in 215 mm';
    FAX_WD_2048 : swd := '2048 pixels in 255 mm';
    FAX_WD_2432 : swd := '2432 pixels in 303 mm';
    FAX_WD_1216 : swd := '1216 pixels in 151 mm';
    FAX_WD_0864 : swd :=  '864 pixels in 107 mm';
    else swd := Format('WD(%d)', [t.wd]);
  end;
  case t.ln of
    FAX_LN_A4        : sln := 'A4, 297 mm';
    FAX_LN_B4        : sln := 'B4, 364 mm';
    FAX_LN_UNLIMITED : sln := 'unlimited';
    else sln := Format('LN(%d)', [t.ln]);
  end;
  case t.df of
    FAX_DF_1DHUFFMAN : sdf := '1-D modified Huffman';
    FAX_DF_2DMREAD   : sdf := '2-D modified Read';
    FAX_DF_2DUNCOMP  : sdf := '2-D uncompressed mode';
    else sdf := Format('DF(%d)', [t.df]);
  end;
  case t.ec of
    0 : sec := 'Off';
    1 : sec := 'ECM 64 bytes/frame';
    2 : sec := 'ECM 128 bytes/frame';
    else sec := Format('EC(%d)', [t.ec]);
  end;
  case t.bf of
    0 : sbf := 'Off';
    1 : sbf := 'On';
    else sbf := Format('BF(%d)', [t.bf]);
  end;
  if ((t.vr = 0) or (t.vr = 1)) and
     ((t.st <> INVALID_VALUE) and (t.st <= 7)) then
  begin
    sst := Format('%d ms', [ast[t.vr, t.st]]);
  end else
  begin
    sst := Format('ST(%d)', [t.st])
  end;
  Log(ltEMSI_1, '  V. resolution : '+svr);
  Log(ltEMSI_1, '       Bit rate : '+sbr);
  Log(ltEMSI_1, '     Page width : '+swd);
  Log(ltEMSI_1, '    Page length : '+sln);
  if t.df <> INVALID_VALUE then
  Log(ltEMSI_1, '    Compression : '+sdf);
  if t.ec <> INVALID_VALUE then
  Log(ltEMSI_1, '     Correction : '+sec);
  if t.bf <> INVALID_VALUE then Log(ltEMSI_1, 'Binary transfer : '+sbf);
  Log(ltEMSI_1, '      Scan time : '+sst);

end;

procedure TMailerThread.DoFax;

procedure SaveFaxBuf;
var
  i: Integer;
begin
  i := SD.Faxmodem.InBufPos;
  if i = 0 then Exit;
  SD.Faxmodem.InBufPos := 0;
  SD.Faxmodem.FStream.Write(SD.Faxmodem.InBuf, i);
end;

function ExtractNewLine(var S: string): string;
var
  I, J: Integer;
begin
  repeat
    I := Pos(#13, S);
    J := Pos(#10, S);
    if I=J then Exit; // neither CR nor LF found - return '', leave S unmodified
    if I < J then XChg(I, J);
    if J > 0 then XChg(I, J);
    Result := Copy(S, 1, I-1);
    Delete(S, 1, I);
    if Result <> '' then Break;
  until False;
end;

procedure ReportHangupCode;
const
  NumHangupCodes = 40;
  HangupCodes : array[0..NumHangupCodes-1] of record i: DWORD; s: string end = (
    (i:  0; s: 'Normal and proper end of connection'),
    (i:  1; s: 'Ring Detect without successful handshake'),
    (i:  2; s: 'Call aborted, from +FK or AN'),
    (i:  3; s: 'No Loop Current'),
    (i: 10; s: 'Unspecified Phase A error'),
    (i: 11; s: 'No Answer (T.30 T1 timeout)'),
    (i: 20; s: 'Unspecified Transmit Phase B error'),
    (i: 21; s: 'Remote cannot receive or send'),
    (i: 22; s: 'COMREC error in transmit Phase B'),
    (i: 23; s: 'COMREC invalid command received'),
    (i: 24; s: 'RSPEC error'),
    (i: 25; s: 'DCS sent three times without response'),
    (i: 26; s: 'DIS/DTC received 3 times; DCS not recognized'),
    (i: 27; s: 'Failure to train at 2400 bps or +FMINSP value'),
    (i: 28; s: 'RSPREC invalid response received'),
    (i: 40; s: 'Unspecified Transmit Phase C error'),
    (i: 43; s: 'DTE to DCE data underflow'),
    (i: 50; s: 'Unspecified Transmit Phase D error'),
    (i: 51; s: 'RSPREC error'),
    (i: 52; s: 'No response to MPS repeated 3 times'),
    (i: 53; s: 'Invalid response to MPS'),
    (i: 54; s: 'No response to EOP repeated 3 times'),
    (i: 55; s: 'Invalid response to EOM'),
    (i: 56; s: 'No response to EOM repeated 3 times'),
    (i: 57; s: 'Invalid response to EOM'),
    (i: 58; s: 'Unable to continue after PIN or PIP'),
    (i: 70; s: 'Unspecified Receive Phase B error'),
    (i: 71; s: 'RSPREC error'),
    (i: 72; s: 'COMREC error'),
    (i: 73; s: 'T.30 T2 timeout, expected page not received'),
    (i: 74; s: 'T.30 T1 timeout after EOM received'),
    (i: 90; s: 'Unspecified Receive Phase C error'),
    (i: 91; s: 'Missing EOL after 5 seconds'),
    (i: 92; s: 'Unused code'),
    (i: 93; s: 'DCE to DTE buffer overflow'),
    (i: 94; s: 'Bad CRC or frame (ECM or BFT modes)'),
    (i:100; s: 'Unspecified Receive Phase D errors'),
    (i:101; s: 'RSPREC invalid response received'),
    (i:102; s: 'COMREC invalid response received'),
    (i:103; s: 'Unable to continue after PIN or PIP')
  );
var
  a: Integer;
  j: DWORD;
  z: string;
begin
  j := SD.Faxmodem.Hangup;
  if j = INVALID_VALUE then GlobalFail('%s', ['Unexpected Fax Hangup']);
  for a := 0 to NumHangupCodes-1 do if HangupCodes[a].i = j then
  begin
    z := HangupCodes[a].s;
    Break;
  end;
  if z = '' then z := Format('HNG(%d)', [j]);
  LogFmt(ltInfo, 'Fax session finished - %s', [z]);
end;



procedure SwitchBPS;
var
  DTE: Integer;
begin
  if not (moSwitchDTE in SD.ModemRec.Options) then DTE := CP.DTE else
  begin
    DTE := 19200;
    TSerialPort(CP).SetBPS(DTE);
    RestoreBPS := True;
  end;
  LogFmt(ltInfo, 'DTE rate is %d BPS', [DTE]);
end;

var
  s: string;
  c: Byte;
  lr: TLineRec;
begin
  case State of
    msFaxBegin:
      begin
        Log(ltConnect, 'Initiating Fax reception');
        ClearTmrPublic;
        if ProtCore <> ptDialup then
        begin
          Log(ltGlobalErr, 'Fax connections are supported over dial-up only!');
          State := msInit;
        end else
        begin
          if moUseExternal in SD.ModemRec.Options then State := msExtApp_0 else
          begin
            SD.Faxmodem := TFaxmodem.Create;
            SD.Faxmodem.Hangup := INVALID_VALUE;
            SD.Faxmodem.ReadyT30 := False;
            SetStatusMsg(rsMMFaxRcv, '');
            State := msFaxStartRece;
          end;
        end;
      end;
    msFaxStartRece:                    // We wait until a string "OK" is seen
      begin                            // or a "+FHNG"
        SetTmr1(20, msFaxTimeout);     // or a "ERROR" or "NO CARRIER"
        State := msFaxRecePage;        // or until 10 seconds for a response.
      end;
    msFaxTimeout:
      begin
        // report timeout
        Log(ltGlobalErr, 'Fax timeout');
        State := msFaxError;
      end;
    msFaxRecePage_:
      State := msFaxRecePage;
    msFaxRecePage:
      begin
        s := ExtractNewLine(SD.InB);
        if s <> '' then
        begin
          State := msFaxRecePage_;
          ParseFaxResponse(s);
          if SD.Faxmodem.fcon then
          begin
            SD.Faxmodem.fcon := False;
            SwitchBPS;
          end;
          if SD.Faxmodem.fco then
          begin
            SD.Faxmodem.fco := False;
            SD.Faxmodem.Class20 := True;
            SwitchBPS;
          end;
          if (not SD.Faxmodem.RemoteIdReported) and (SD.Faxmodem.RemoteId <> '') then
          begin
            SD.Faxmodem.RemoteIdReported := True;
            Log(ltEMSI, '     Station ID : '+SD.Faxmodem.RemoteId);
          end;
          if SD.Faxmodem.ReadyT30 then
          begin
            SD.Faxmodem.ReadyT30 := False;
            ReportT30(SD.Faxmodem.T30);
          end;
          if SD.Faxmodem.Hangup <> INVALID_VALUE then State := msFaxHangup;
          if SD.Faxmodem.Error then State := msFaxError;
          if SD.Faxmodem.OK then
          begin
            SD.Faxmodem.OK := False;
            State := msFaxOK;
          end;
        end;
      end;
    msFaxError:
      begin
        Log(ltGlobalErr, 'Modem reported error on Fax command');
        State := msFaxEnd;
      end;
    msFaxDCD:
      begin
        Log(ltWarning, 'Fax carrier lost');
        State := msFaxEnd;
      end;
    msFaxHangup:
      begin
        ReportHangupCode;
        State := msFaxEnd;
      end;
    msFaxOK:
      begin
        SD.Faxmodem.WasDLE := False;
        SD.Faxmodem.connect := False;
        SD.Faxmodem.OK := False;
        CfgEnter;
        lr := Pointer(Cfg.Lines.GetRecById(LineId));
        FaxInbound := lr.FaxIn;
        if FaxInbound = '' then FaxInbound := Cfg.PathNames.InSecure;
        FaxInbound := StrAsg(FullPath(FaxInbound));
        CfgLeave;
        SD.Faxmodem.FStream := TxMemoryStream.Create;
        SD.StateDeltaDCD := msNone;
        SendModemString('AT+FDR!');   // We wait until either a string "CONNECT" is seen
        SetTmr1(20, msFaxTimeout);    // or a "+FHNG"
        State := msFaxWaitCN;         // or until 10 seconds for a response.
      end;
    msFaxWaitCN_:
      State := msFaxWaitCN;
    msFaxWaitCN:
      begin
        s := ExtractNewLine(SD.InB);
        if s <> '' then
        begin
          State := msFaxWaitCN_;
          ParseFaxResponse(s);
          if SD.Faxmodem.Connect then State := msFaxGood;
          if SD.Faxmodem.Hangup <> INVALID_VALUE then State := msFaxHangup;
          if SD.Faxmodem.Error then State := msFaxError;
        end;
      end;
    msFaxGood:
      begin
        // Send DC2 to start phase C data stream
        SetTmr1(20, msFaxTimeout); // 10 seconds to wait for the first char
        SendStr(Char(cDC2));
        SD.Accumulate := False;
        SD.Faxmodem.PostPageResp := INVALID_VALUE;
        SD.Faxmodem.PostPageMsg := INVALID_VALUE;
        Inc(SD.Faxmodem.PageNo);
        SetStatusMsg(rsMMFaxRcvPg, IntToStr(SD.Faxmodem.PageNo));
        SD.Faxmodem.PageTime := uGetSystemTime;
        State := msFaxReadG3;
      end;
    msFaxReadG3:
      while CP.GetChar(C) do
      begin
        if not SD.Faxmodem.FirstByteGot then
        begin
          SD.Faxmodem.FirstByteGot := True;
          CP.Carrier := CP.DCD;
          if not CP.Carrier then Log(ltWarning, 'FAX modem doesn''t assert DCD');
          SD.StateDeltaDCD := msFaxDCD;
        end;
        // 10 seconds for each 256 byte-block
        if SD.Faxmodem.InBufPos mod $100 = 0 then SetTmr1(20, msFaxTimeout);
        if SD.Faxmodem.WasDLE then
        begin
          SD.Faxmodem.WasDLE := False;
          case c of                        // DLE DLE gives DLE. We don't know what to do if it
            cETX :                         // isn't ETX (above) or DLE. So we'll just always treat
              begin                        // DLE (not ETX) as (not ETX).
                State := msFaxEndPage;
                Break;
              end;
            cDLE : ;
            else Continue;
          end;
        end else
        begin
          if C = cDLE then
          begin
            SD.Faxmodem.WasDLE := True;
            Continue;
          end;
        end;
        SD.Faxmodem.InBuf[SD.Faxmodem.InBufPos] := C;
        Inc(SD.Faxmodem.InBufPos);
        if SD.Faxmodem.InBufPos = cFaxInBufSize then SaveFaxBuf;
      end;
    msFaxEndPage:
      begin
        SaveFaxBuf;
        SD.Accumulate := True;
        SetTmr1(20, msFaxTimeout); // 10 seconds to wait for +FET & OK
        State := msFaxWaitFet;
      end;
    msFaxWaitFet_:
      State := msFaxWaitFet;
    msFaxWaitFet:
      begin
        s := ExtractNewLine(SD.InB);
        if s <> '' then
        begin
          State := msFaxWaitFet_;
          ParseFaxResponse(s);
          if SD.Faxmodem.Hangup <> INVALID_VALUE then State := msFaxHangup;
          if SD.Faxmodem.Error then State := msFaxError;
          if SD.Faxmodem.OK then
          begin
            SD.Faxmodem.OK := False;
            State := msFaxPageGood;
          end;
          if SD.Faxmodem.PostPageResp <> INVALID_VALUE then
          begin
            AddFaxPage;
            case SD.Faxmodem.PostPageResp of
              0 : s := 'Partial page errors';
              1 : s := 'Page Good';
              2 : s := 'Page bad, retrain requested';
              3 : s := 'Page good, retrain requested';
              4 : s := 'Page bad, interrupt requested';
              5 : s := 'Page good, interrupt requested';
              else s := Format('PTS(%d)', [SD.Faxmodem.PostPageResp]);
            end;
            LogFmt(ltInfo, '%s  [%d/%d/%d/%d]', [s, SD.Faxmodem.PostPageResp, SD.Faxmodem.pts_lc, SD.Faxmodem.pts_blc, SD.Faxmodem.pts_cblc]);
            SD.Faxmodem.PostPageResp := INVALID_VALUE;
          end;
          if SD.Faxmodem.PostPageMsg <> INVALID_VALUE then
          begin
            case SD.Faxmodem.PostPageMsg of
              0: s := 'More pages follow; same document';
              1: s := 'End of document; another document follows';
              2: s := 'No more pages or documents';
              4: s := 'Procedure interrupt: another page follows';
              5: s := 'Procedure interrupt: end of document, another document follows';
              6: s := 'Procedure interrupt: end of document';
              else s := Format('ET(%d)', [SD.Faxmodem.PostPageMsg]);
            end;
            Log(ltInfo, s);
            SD.Faxmodem.PostPageMsg := INVALID_VALUE;
          end;
        end;
      end;
    msFaxPageGood:
      begin
        State := msFaxOK;
      end;
    msFaxEnd:
      begin
        FreeFaxModem;
        State := msInit;
      end;
    else GlobalFail('%s', ['TMailerThread.DoFax Unknown State']);
  end;
end;

destructor TFaxmodem.Destroy;
begin
  FreeObject(FStream);
  FreeObject(Pages);
  inherited Destroy;
end;

const
// TIFF data types

  TIFFBYTE	     =	1;
  TIFFASCII	     =	2;
  TIFFSHORT	     =	3;
  TIFFLONG	     =	4;
  TIFFRATIONAL	     =  5;
  TIFFSIGNED	     =	6;
  TIFFFLOAT	     =	32768;  // manufactured type -- not found in TIFF file

  // TIFF tag constants

  TGNEWSUBFILETYPE		     =	254;
  TGOLDSUBFILETYPE		     =	255;
  TGIMAGEWIDTH			     =	256;
  TGIMAGELENGTH			     =	257;
  TGBITSPERSAMPLE		     =	258;
  TGCOMPRESSION			     =	259;

  TGPHOTOMETRICINTERPRETATION	     =  262;
  TGTHRESHHOLDING		     =	263;
  TGCELLWIDTH			     =	264;
  TGCELLLENGTH			     =	265;
  TGFILLORDER			     =	266;

  TGDOCUMENTNAME		     = 	269;
  TGIMAGEDESCRIPTION		     =	270;
  TGMAKE			     =	271;
  TGMODEL			     =	272;
  TGSTRIPOFFSETS		     =	273;
  TGORIENTATION			     =	274;

  TGSAMPLESPERPIXEL		     =	277;
  TGROWSPERSTRIP		     =	278;
  TGSTRIPBYTECOUNTS		     =	279;
  TGMINSAMPLEVALUE		     =	280;
  TGMAXSAMPLEVALUE		     =	281;
  TGXRESOLUTION			     =	282;
  TGYRESOLUTION			     =	283;
  TGPLANARCONFIGURATION		     =  284;
  TGPAGENAME			     =	285;
  TGXPOSITION			     =	286;
  TGYPOSITION			     =	287;
  TGFREEOFFSETS			     =	288;
  TGFREEBYTECOUNTS		     =	289;
  TGGRAYUNIT			     =	290;
  TGGRAYCURVE			     =	291;

  TGGroup3Options                    =  292;

  TGRESOLUTIONUNIT		     =	296;
  TGPAGENUMBER			     =	297;

  TGCOLORRESPONSECURVES		     =  301;

  TGSOFTWARE			     =	305;
  TGDATETIME			     =	306;

  TGARTIST			     =	315;
  TGHOSTCOMPUTER		     =	316;

  TGPREDICTOR			     =	317;
  TGWHITEPOINT			     =	318;
  TGPRIMARYCHROMATICITIES	     =  319;
  TGCOLORMAP			     =	320;

  TGBadFaxLines                       =  326;
  TGCleanFaxData                      =  327;
  TGConsecutiveBadFaxLines            =  328;


type
  TTiffTagAbstract = class
    Tag: Integer;
    procedure Store(D, T: TxStream); virtual; abstract;
  end;

  TTiffTagString = class(TTiffTagAbstract)
    s: string;
    procedure Store(D, T: TxStream); override;
    constructor Create(ATag: Integer; const AStr: string; Tags: TColl);
  end;

  TTiffTagInt = class(TTiffTagAbstract)
    Typ: Byte;
    i: DWORD;
    procedure Store(D, T: TxStream); override;
    constructor Create(ATag: Integer; AInt: DWORD; ATyp: Integer; Tags: TColl);
  end;

  TTiffTagRational = class(TTiffTagAbstract)
    Fraction,
    Denominator: DWORD;
    procedure Store(D, T: TxStream); override;
    constructor Create(ATag: Integer; AFraction, ADenominator: DWORD; Tags: TColl);
  end;

  TTIFFhdr = packed record
    ByteOrder,
    Version: Word;
    IFDoffset: Integer;
  end;

  TIFDEntry = packed record
    Tag,
    Typ: Word;
    Cnt,
    Ofs: Integer;
  end;

constructor TTiffTagString.Create(ATag: Integer; const AStr: string; Tags: TColl);
begin
  Tag := ATag;
  s := AStr;
  Tags.Insert(Self);
end;

procedure TTiffTagString.Store(D, T: TxStream);
var
  ss: string;
  lss: Integer;
  e: TIFDEntry;
begin
  ss := s + #0;
  lss := Length(ss);
  e.Tag := Tag;
  e.Typ := TIFFASCII;
  e.Cnt := lss;
  if Length(ss) > 4 then
  begin
    D.WriteA4(ss[1], lss);
    e.Ofs := Integer(D.Position)-lss;
  end else
  begin
    e.Ofs := 0;
    Move(ss[1], e.Ofs, lss);
  end;
  T.Write(e, SizeOf(e));
end;


constructor TTiffTagInt.Create(ATag: Integer; AInt: DWORD; ATyp: Integer; Tags: TColl);
begin
  Tag := ATag;
  i := AInt;
  Typ := ATyp;
  Tags.Insert(Self);
end;

procedure TTiffTagInt.Store(D, T: TxStream);
var
  e: TIFDEntry;
begin
  e.Tag := Tag;
  e.Typ := Typ;
  e.Cnt := 1;
  e.Ofs := i;
  T.Write(e, SizeOf(e));
end;

constructor TTiffTagRational.Create(ATag: Integer; AFraction, ADenominator: DWORD; Tags: TColl);
begin
  Tag := ATag;
  Fraction := AFraction;
  Denominator := ADenominator;
  Tags.Insert(Self);
end;

procedure TTiffTagRational.Store(D, T: TxStream);
var
  e: TIFDEntry;
  r: packed record f, d: DWORD end;
begin
  r.f := fraction;
  r.d := denominator;
  e.Tag := Tag;
  e.Typ := TIFFRATIONAL;
  e.Cnt := 1;
  D.WriteA4(r, SizeOf(r));
  e.Ofs := D.Position - SizeOf(r);
  T.Write(e, SizeOf(e));
end;


function CreateTags(AWidth, ALength, AOfs, ASz, ABl, ACBl, AYRes: DWORD; const AMake, AComputer, ASoft, ADocName, ADateTime: string): TColl;
var
  t: TColl;
begin
  t := TColl.Create;
  TTiffTagInt.Create(TGNEWSUBFILETYPE,              2,       TIFFLONG,   t);
  TTiffTagInt.Create(TGOLDSUBFILETYPE,              1,       TIFFSHORT,  t);
  if AWidth <> INVALID_VALUE then
  TTiffTagInt.Create(TGIMAGEWIDTH,                  AWidth,  TIFFLONG,   t);
  if ALength <> INVALID_VALUE then
  TTiffTagInt.Create(TGIMAGELENGTH,                 ALength, TIFFLONG,   t);
  TTiffTagInt.Create(TGBITSPERSAMPLE,               1,       TIFFSHORT,  t);
  TTiffTagInt.Create(TGCOMPRESSION,                 3,       TIFFSHORT,  t);
  TTiffTagInt.Create(TGPHOTOMETRICINTERPRETATION,   0,       TIFFSHORT,  t);
  TTiffTagInt.Create(TGFILLORDER,                   2,       TIFFSHORT,  t);
  TTiffTagString.Create(TGDOCUMENTNAME,             ADocName,            t);
  TTiffTagString.Create(TGIMAGEDESCRIPTION,         'FAX',               t);
  TTiffTagString.Create(TGMAKE,                     AMake,               t);
  TTiffTagInt.Create(TGSTRIPOFFSETS,                AOfs,    TIFFLONG,   t);
  TTiffTagInt.Create(TGORIENTATION,                 1,       TIFFSHORT,  t);
  TTiffTagInt.Create(TGSAMPLESPERPIXEL,             1,       TIFFSHORT,  t);
  if ALength <> INVALID_VALUE then
  TTiffTagInt.Create(TGROWSPERSTRIP,                ALength, TIFFLONG,   t);
  TTiffTagInt.Create(TGSTRIPBYTECOUNTS,             ASz,     TIFFLONG,   t);
  TTiffTagRational.Create(TGXRESOLUTION,            204,1,             t);
  if AYRes <> INVALID_VALUE then
  TTiffTagRational.Create(TGYRESOLUTION,            AYRes,1,             t);
  TTiffTagInt.Create(TGGroup3Options,               4,       TIFFLONG,   t);
  TTiffTagInt.Create(TGRESOLUTIONUNIT,              2,       TIFFSHORT,  t);
  TTiffTagString.Create(TGSOFTWARE,                 ASoft,               t);
  TTiffTagString.Create(TGDATETIME,                 ADateTime,           t);
  if AComputer <> '' then
  TTiffTagString.Create(TGHostComputer,             AComputer,           t);
  TTiffTagInt.Create(TGBadFaxLines,                 ABl,     TIFFLONG,   t);
  TTiffTagInt.Create(TGConsecutiveBadFaxLines,      ACBl,    TIFFLONG,   t);
  Result := t;
end;


procedure TMailerThread.WriteTIFF;
var
  w: Word;
  Tags: TColl;
  t: TTiffTagAbstract;
  xPos,
  YRes, fl: DWORD;
  g: TFaxPage;
  x: TDosStream;
  hdr: TTIFFhdr;
  OfsOfs: Integer;
  cs: TxMemoryStream;
  i, j, m: Integer;
  s, d, n, e: string;
begin
  m := CollMax(SD.Faxmodem.Pages);
  if m < 0 then Exit;
  GetFaxFName('tif');
  if not CreateDirInheritance(ExtractFileDir(SD.Faxmodem.FName)) then
  begin
    ChkErrMsg;
    Exit;
  end;
  LogFmt(ltInfo, 'Writing Fax document to ''%s''', [SD.Faxmodem.FName]);
  x := CreateDosStream(SD.FaxModem.FName, [cWrite, cEnsureNew]);
  if x = nil then begin ChkErrMsg; Exit end;
  hdr.ByteOrder := $4949;
  hdr.Version := $2A;
  hdr.IFDoffset := 0;
  x.Write(hdr, SizeOf(hdr));
  OfsOfs := 4;
  xPos := SizeOf(hdr);
  UpdateModem;
  for i := 0 to m do
  begin
    g := SD.Faxmodem.Pages[i];
    case g.T30.vr of
      FAX_VR_NORMAL : YRes := 98;
      FAX_VR_FINE   : YRes := 196;
      else YRes := INVALID_VALUE;
    end;
// Create tags collection
    Tags := CreateTags(g.x, g.y, xPos, g.FStream.Size, g.BadLines, g.cBadLines, YRes, SD.ModemRec.Name, _GetComputerName, CProductNameVer, g.Id, uFormatDateTime('yyyy:mm:dd hh:nn:ss', g.Time));
// write image strip data
    x.WriteA4(g.FStream.Memory^, g.FStream.Size);
// create control stream for Image File Directory (IFD)
    cs := TxMemoryStream.Create; 
// write 2-byte number of tags (entries)
    w := Tags.Count;
    cs.Write(w, SizeOf(w));
// store tags to control stream
    for j := 0 to Tags.Count-1 do
    begin
      t := Tags[j];
      t.Store(x, cs);
    end;
    FreeObject(Tags);
// Append 4 bytes to control stream. Reserve place for offset of the next IFD
    fl := 0;
    cs.Write(fl, SizeOf(fl));
// Flush control stream to file
    x.WriteA4(cs.Memory^, cs.Size);
// Update xPos
    xPos := x.Position;
// Set 'fl' to the beginning of current IFD
    fl := xPos - cs.Size;
    FreeObject(cs);
// Seek to previous IFD (or header) to set the offset of current IFD
    x.Position := OfsOfs;
// Update OfsOfs to point to the last four bytes of current IFD
    OfsOfs := xPos - SizeOf(Integer);
// Write offset
    x.Write(fl, SizeOf(fl));
    x.Position := xPos;
  end;
  FreeObject(x);
  s := Trim(SD.ModemRec.FaxApp);
  if s = '' then Exit;
  FSplit(SD.FaxModem.FName, d, n, e);
  Replace('%PATHNAME%', SD.FaxModem.FName, s);
  Replace('%PATH%', d, s);
  Replace('%NAME%', n, s);
  Replace('%EXT%', e, s);
  AddToExec(s, Logger);
end;

destructor TFaxPage.Destroy;
begin
  FreeObject(FStream);
  inherited Destroy;
end;

function AllowedMdmCmdState(AState: TMailerState): Boolean;
begin
  case AState of
    msIdle,
    msInitModem,
    msInitModemA,
    msHangup,
    msError:
      Result := True;
    else
      Result := False;
  end;
end;

constructor TReStreamScanner.Create(const APattern: string);
begin
  inherited Create;
  Pos := 1;
  RE := GetRegExpr(APattern);
  Inc(RE.Owned);
  RE.Unlock;
end;

function TReStreamScanner.Scan(const s: string): Boolean;
var
  NewPos: Integer;
begin
  Result := False;
  RE.Lock;
  NewPos := -1;
  while (NewPos <> Pos) and (RE.MatchAt(s, Pos) > 0) do
  begin
    Result := True;
    NewPos := RE.MatchNext[0];
    Pos := NewPos;
    Matched;
  end;
  RE.Unlock;
end;

procedure TReStreamScanner.DecPos;
begin
  Pos := MaxI(1, Pos-i);
end;

destructor TReStreamScanner.Destroy;
begin
  RE.Lock;
  Dec(RE.Owned);
  RE.Unlock;
  inherited Destroy;
end;


constructor TResponseFormatHolder.Create(const APattern, AFormat: string; ALogger: TAbstractLogger);
begin
  inherited Create(APattern);
  FFormat := AFormat;
  FLogger := ALogger;
end;

procedure TResponseFormatHolder.Matched;
var
  REP: TPCRE;
  C: TStringColl;
  StartPos: Integer;
  NewOutput: string;
  j: Integer;
begin
  REP := GetRegExpr('(?s)\$(\d+)');
  StartPos := 1;
  NewOutput := FFormat;
  while (REP.ErrPtr = 0) and (StartPos < Length(NewOutput)) do
  begin
    if REP.MatchAt(NewOutput, StartPos) <> 2 then Break;
    Delete(NewOutput, REP.MatchPos[0], REP.MatchSize[0]);
    j := Vl(REP[1]);
    Insert(RE[j], NewOutput, REP.MatchPos[0]);
    StartPos := REP.MatchPos[0] + RE.MatchSize[j];
  end;
  REP.Unlock;
  C := TStringColl.Create;
  C.LoadFromString(NewOutput);
  for j := 0 to CollMax(C) do if Trim(C[j]) <> '' then FLogger.Log(ltInfo, C[j]);
  FreeObject(C);
end;

constructor TReWdResetHolder.Create(const APattern: string; AMailer: TMailerThread);
begin
  inherited Create(APattern);
  FMailer := AMailer;
end;

procedure TReWdResetHolder.Matched;
begin
  FMailer.InsertEvt(TMlrEvtLogAndCancel.Create('Reset WatchDog matched'));
end;

constructor TReWdExtAppHolder.Create(const APattern, AExtApp: string; AMailer: TMailerThread);
begin
  inherited Create(APattern);
  FMailer := AMailer;
  FExtApp := AExtApp;
end;

procedure TReWdExtAppHolder.Matched;
begin
  FMailer.InsertEvt(TMlrEvtLogAndExtApp.Create(StrAsg(FExtApp), 'ExtApp WatchDog matched'));
end;

constructor TReLoginHolder.Create(const APattern: string; AMailer: TMailerThread);
begin
  inherited Create(APattern);
  FMailer := AMailer;
end;

procedure TReLoginHolder.Matched;
begin
  FMailer.State := msHSh_Login_2_matched;
end;


function TMailerThread.RemoteListed: Boolean;
var
  Listed: Boolean;
  i: Integer;
  fa: TFidoAddress;
  n: TFidoNode;
begin
  if SD.RemoteListed = rmtUnknown then
  begin
    Listed := SD.PasswordProtected;
    if not Listed then
    begin
      for i := 0 to CollMax(SD.rmtAddrs) do
      begin
        fa := SD.rmtAddrs[i];
        n := GetListedNode(fa);
        if n <> nil then
        begin
          Listed := True;
          Break;
        end;
      end;
    end;
    if Listed then SD.RemoteListed := rmtListed else SD.RemoteListed := rmtUnlisted;
  end;
  Result := SD.RemoteListed = rmtListed;
end;

procedure TMailerThread.ProcessSRPs(C: TStringColl);
var
  SRPFName, FileMask, s, z: string;
  i: Integer;
  Nfo: TProcessInformation;
  p: TFidoPoll;
  MC, SC1, SC2, SC3: TStringColl;
  B: Boolean;
  SR: TuFindData;
  n: TAdvNode;
begin
  p := nil;
  for i := 0 to CollMax(C) do
  begin
    s := C[i];
    GetWrd(s, z, '^');
    SRPFName := Trim(z);
    FileMask := Trim(s);
    n := TAdvNode.Create;
    n.Station := DS.rmtStationName;
    n.Sysop := DS.rmtSysOpName;
    n.Location := DS.rmtLocation;
    n.Addr := SD.rmtPrimaryAddr;
    B := RunExtApp(Self, Logger, Name, nil, n, SRPFName, Nfo, @FileMask, False);
    FreeObject(n);
    if not B then
    begin
      ChkErrMsg;
      Log(ltGlobalErr, 'Error starting SRP');
      Continue;
    end;
    ResumeThread(Nfo.hThread);
    FlushLog;
    WaitForExtProcess(Nfo.hProcess, p, Logger);
    FinalizeExtApp(Nfo, Logger, p);
    if FileMask = '' then Continue;
    SC1 := TStringColl.Create;
    SC2 := TStringColl.Create;
    SC3 := TStringColl.Create;
    case FileMask[1] of
      '=' :  //  erase file if sent successfully
        MC := SC1;
      '+' : //   do not erase the file after sent
        MC := SC2;
      '-' : //   erase the file in any case after session
        MC := SC3;
        else
          MC := nil;
    end;
    if MC <> nil then DelFC(FileMask) else MC := SC1;
    LogFmt(ltInfo, 'Scanning "%s"', [FileMask]);
    B := uFindFirst(FileMask, SR);
    if B then
    begin
      while B do
      begin
        if SR.Info.Attr and (FILE_ATTRIBUTE_DIRECTORY or FILE_ATTRIBUTE_HIDDEN) = 0 then
        begin
          s := ExtractFilePath(FileMask)+SR.FName;
          LogFmt(ltInfo, 'Attached "%s"', [s]);
          MC.Add(s);
        end;
        B := uFindNext(SR);
      end;
      uFindClose(SR);
    end;
    AttachERPFiles(SC1, SC2, SC3);
    FreeObject(SC1);
    FreeObject(SC2);
    FreeObject(SC3);
  end;
end;

procedure TMailerThread.AttachERPFiles(SC1, SC2, SC3: TStringColl);

procedure Purge(SC: TStringColl);
var
  j: Integer;
  s: string;
begin
  for j := SC.Count-1  downto 0 do
  begin
    if j mod 100 = 99 then FlushLog;
    s := sc[j];
    if SD.OutFiles.FoundFName(s) or
       SD.SentFiles.FoundFName(s) then
    begin
      LogFmt(ltInfo, ' already attached %s - skipping', [s]);
      sc.AtFree(j);
    end;
  end;
end;

begin
  Purge(SC1);
  Purge(SC2);
  Purge(SC3);

  FidoOut.AttachFiles(SD.rmtPrimaryAddr, SC1, osHold, kaBsoKillAfter);
  FidoOut.AttachFiles(SD.rmtPrimaryAddr, SC2, osHReq, kaBsoNothingAfter);
  FidoOut.AttachFiles(SD.rmtPrimaryAddr, SC3, osNormal, kaBsoKillAfter);

  if SD.HReqDelete = nil then SD.HReqDelete := TStringColl.Create;
  SD.HReqDelete.Concat(SC3);
end;

end.

