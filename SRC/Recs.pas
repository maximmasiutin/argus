unit Recs;

{$I DEFINE.INC}


interface uses Dialogs, Windows, Messages, xBase, StdCtrls, xFido, Classes, xDES;

const
  mlProductCode    = $7FF;

  RegistryFName    = 'SOFTWARE\RIT\ARGUS\CurrentVersion\IniFile.ini';
  rvnHomePath      = 'HomePath';
  rvnHelpLng       = 'HelpLng';
  rvnInterfaceLng  = 'InterfaceLng';
  rvnAppMode       = 'AppMode';
  CfgFName         = 'config.bin';
  IntegersFName    = 'config.int';
  HisFName         = 'history.bin';
  BWZLogFName      = 'badwazoo.lst';
  BWZFmt           = 'badwazoo.%.3x';
  cFaxInbound      = 'INFAX';

  DefBPS           = 57600;

var
  icvMainFormL : Integer;
  icvMainFormT : Integer;
  icvMainFormW : Integer;
  icvMainFormH : Integer;

  icvThreadsFormL : Integer;
  icvThreadsFormT : Integer;
  icvThreadsFormW : Integer;
  icvThreadsFormH : Integer;


type
  TPathnameColl = class(TStringColl)
    DefaultZone: DWORD;
    property InSecure     : string index 0 read GetString;
    property InCommon     : string index 1 read GetString;
    property InTemp       : string index 2 read GetString;
    property Outbound     : string index 3 read GetString;
    property Log          : string index 4 read GetString;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
  end;

  TElementClass = class of TElement;

  TElement = class(TAdvCpObject)
    Id: Integer;
    function Name: string; virtual; abstract;
    procedure SetDefault; virtual; abstract;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    constructor Create; virtual;
  end;

  TElementOnly = class(TElement)
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
    procedure SetDefault; override;
    function Name: string; override;
  end;

  TElementColl = class(TColl)
    DefaultId: Integer;
    constructor Create;
    procedure InvalidateID;
    procedure SetDefaultRec(ARec: TElement);
    procedure SetDefaultIdx(AIdx: Integer);
    function GetDefaultIdx: Integer;
    function GetDefaultRec: TElement;
    function GetRecById(AId: Integer): TElement;
    function GetIdxById(AId: Integer): Integer;
    function GetUnusedId: Integer;
    property DefaultIdx: Integer read GetDefaultIdx write SetDefaultIdx;
    property DefaultRec: TElement read GetDefaultRec write SetDefaultRec;
    procedure AppendTo(AColl: TElementColl);
    procedure FillCombo(cb: TComboBox; LngId, Id: Integer);
    function GetIdCombo(cb: TComboBox): Integer;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
  end;


  TMainCfgColl = class(TColl)
     function GetElement(Idx: Integer): TElementColl;
     property Lines        : TElementColl index 0 read GetElement;
     property Station      : TElementColl index 1 read GetElement;
     property Ports        : TElementColl index 2 read GetElement;
     property Modems       : TElementColl index 3 read GetElement;
     property Restrictions : TElementColl index 4 read GetElement;
     property dLines       : TElementColl index 5 read GetElement;
     property dStation     : TElementColl index 6 read GetElement;
     property dPorts       : TElementColl index 7 read GetElement;
     property dModems      : TElementColl index 8 read GetElement;
     property dRestictions : TElementColl index 9 read GetElement;
  end;

  TModemStdRespIdx = (mrpRing, mrpConnect, mrpOK, mrpBusy, mrpNoCarrier, mrpNoDial, mrpError, mrpVoice, mrpRinging, mrpNone);
  TModemStdRespIdxSet = set of TModemStdRespIdx;

  TModemStdResp = class(TStringColl)
    property Ring          : string index Integer(mrpRing)      read GetString;
    property Connect       : string index Integer(mrpConnect)   read GetString;
    property OK            : string index Integer(mrpOK)        read GetString;
    property Busy          : string index Integer(mrpBusy)      read GetString;
    property NoCarrier     : string index Integer(mrpNoCarrier) read GetString;
    property NoDial        : string index Integer(mrpNoDial)    read GetString;
    property Err           : string index Integer(mrpError)     read GetString;
    property Voice         : string index Integer(mrpVoice)     read GetString;
    property Ringing       : string index Integer(mrpRinging)   read GetString;
  end;

  TModemCmdsColl = class(TStringColl)
    property Init          : string index 0 read GetString;
    property Answer        : string index 1 read GetString;
    property Prefix        : string index 2 read GetString;
    property Suffix        : string index 3 read GetString;
    property Hangup        : string index 4 read GetString;
    property Exit          : string index 5 read GetString;
  end;

  TInPortsColl = class(TStringColl)
    property ifcico        : string index 0 read GetString;
    property Telnet        : string index 1 read GetString;
    property BinkP         : string index 2 read GetString;
  end;

  TNamed = class(TElement)
    FName: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Name: string; override;
  end;

  TStartupRec = class(TAdvObject)
    IdAutoOpenLines: PIntArray;
    CntAutoOpenLines: Integer;
    Options: Byte;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    constructor Create;
    destructor Destroy; override;
  end;

  TPortData = record
    Port: Byte;
    BPS: Integer;
    Hflow, Sflow: Boolean;
    Data, Parity, Stop: Byte;
  end;

  TPortRec = class(TElement)
    d: TPortData;
    procedure SetDefault; override;
    function Name: string; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
    function FlowStr: string;
    constructor Create; override;
  end;

  TModemOption = (moUseExternal, moSwitchDTE);

  TModemOptions = set of TModemOption;

  TModemRec = class(TNamed)
    StdResp: TModemStdResp;
    Cmds: TModemCmdsColl;
    Options: TModemOptions;
    FlagsA, FlagsB: TStringColl;
    FaxApp: string;
    procedure SetDefault; override;
    constructor Create; override;
    destructor Destroy; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
  end;

  TModemRec_v3040 = class(TNamed)
    StdResp: TModemStdResp;
    Cmds: TModemCmdsColl;
    FlagsA, FlagsB: TStringColl;
    FaxApp: string;
    constructor Load(Stream: TxStream); override;
    function Upgrade: TModemRec;
    destructor Destroy; override;
  end;


  TLineOption = (loAbsolete);
  TLineOptionSet = set of TLineOption;

  TLineData = record
    Options: TLineOptionSet;
    StationId,
    PortId,
    ModemId,
    RestrictId: Integer;
  end;

  TLineRec = class(TNamed)
    d: TLineData;
    FaxIn,
    LogFName: string;
    EvtIds: Pointer;
    EvtCnt: DWORD;
    constructor Create; override;
    destructor Destroy; override;
    procedure SetDefault; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
  end;

  TLineRec_v3011 = class(TNamed)
    d: TLineData;
    LogFName: string;
    EvtIds: Pointer;
    EvtCnt: DWORD;
    constructor Load(Stream: TxStream); override;
    function Upgrade: TLineRec;
    procedure SetDefault; override;
    function Copy: Pointer; override;
  end;


  TLineRec_v3010 = class(TNamed)
    d: TLineData;
    LogFName: string;
    constructor Load(Stream: TxStream); override;
    function Upgrade: TLineRec_v3011;
  end;


  TStationRec = class(TNamed)
    Data: TStationDataColl;
    Banner: string;
    AkaA, AkaB: TStringColl;
    procedure SetDefault; override;
    constructor Create; override;
    destructor Destroy; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
  end;

  TStationRec_v3021 = class(TNamed)
    Data: TStationDataColl;
    Banner: string;
    constructor Load(Stream: TxStream); override;
    function Upgrade: TStationRec;
  end;


  TStationRec_v3020 = class(TNamed)
    Data: TStationDataColl;
    constructor Load(Stream: TxStream); override;
    function Upgrade: TStationRec;
  end;

  TRestrictionData = class(TAdvCpObject)
    Required, Forbidden: TStringColl;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
    constructor Create;
    destructor Destroy; override;
  end;

  TRestrictionRec = class(TNamed)
    Data: TRestrictionData;
    procedure SetDefault; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
    constructor Create; override;
    destructor Destroy; override;
  end;

  TRestrictionRec_v3050 = class(TNamed)
    Required, Forbidden: string;
    constructor Load(Stream: TxStream); override;
    function Upgrade: TRestrictionRec;
  end;

  TNodelistData = class(TAdvObject)
    SrcPfx, DstPfx, Files: TStringColl;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    constructor Create;
    destructor Destroy; override;
  end;

  TAddrListRec = class(TAdvCpObject)
    AddrList: TFidoAddrColl;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    constructor Create;
    destructor Destroy; override;
  end;

  TAddrListRecNCP = class(TAddrListRec)
    function Copy: Pointer; override;
  end;

  TPasswordRec = class(TAddrListRecNCP)
    PswStr: string;
    AuxStr: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
  end;

  TPerPollRec = class(TAddrListRec)
    Cron: string;
    CronRec: TCronRecord;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
    destructor Destroy; override;
  end;

  TOldIPRestriction = class
    Required, Forbidden: string;
  end;


  TIPRecOption = (ioAbsolete);
  TIPRecOptionSet = set of TIPRecOption;

  TIPRec = class(TAdvObject)
    InPorts: TInPortsColl;
    StationData: TStationDataColl;
    Restriction: TRestrictionData;
    Speed, InC, OutC: DWORD;
    Banner: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    constructor Create;
    destructor Destroy; override;
  end;

  TIPRec_v3075 = class(TAdvObject)
    InPorts: TInPortsColl;
    StationData: TStationDataColl;
    Restriction: TOldIPRestriction;
    Speed, InC, OutC: Integer;
    Options: TIPRecOptionSet;
    Banner: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    destructor Destroy; override;
    function Upgrade: TIPRec;
  end;


  TIPRec_v3074 = class(TAdvObject)
    InPorts: TInPortsColl;
    StationData: TStationDataColl;
    Restriction: TOldIPRestriction;
    InC, OutC: Integer;
    Options: TIPRecOptionSet;
    constructor Load(Stream: TxStream); override;
    function Upgrade: TIPRec_v3075;
  end;

  TLineColl     = class(TElementColl)
    constructor Load(Stream: TxStream); override;
  end;

  TStationColl  = class(TElementColl)
    constructor Load(Stream: TxStream); override;
  end;

  TPortColl     = class(TElementColl)
    constructor Load(Stream: TxStream); override;
  end;

  TModemColl    = class(TElementColl)
    constructor Load(Stream: TxStream); override;
  end;

  TRestrictColl = class(TElementColl)
    constructor Load(Stream: TxStream); override;
  end;

  TAbsNodeOvrColl_Old  = class(TColl)
  end;

  TAbsNodeOvrColl = class(TColl)
    AuxFile: string;
    function Crc32Item(Item: Pointer; Crc32: DWORD): DWORD; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Crc32(Init: DWORD): DWORD; override;
  end;

  TDialupNodeOvrColl = class(TAbsNodeOvrColl)
    constructor Load(Stream: TxStream); override;
  end;

  TIPNodeOvrColl = class(TAbsNodeOvrColl)
    constructor Load(Stream: TxStream); override;
  end;

  TDialupNodeOvrColl_v130 = class(TAbsNodeOvrColl_Old)
    function Upgrade: TDialupNodeOvrColl;
    constructor Load(Stream: TxStream); override;
  end;

  TIPNodeOvrColl_v135 = class(TAbsNodeOvrColl_Old)
    function Upgrade: TIpNodeOvrColl;
    constructor Load(Stream: TxStream); override;
  end;


  TNodeOvr = class(TAdvObject)
    Addr: TFidoAddress;
    Ovr: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
  end;

  TExtCollA        = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TExtCollB        = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TDrsCollA        = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TDrsCollB        = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TCrnCollA        = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TCrnCollB        = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TIpAkaCollA      = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TIpAkaCollB      = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TPerPollsCollA_3240 = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TPerPollsCollB_3250 = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TIpDomCollA = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TIpDomCollB = class(TStringColl)
    constructor Load(Stream: TxStream); override;
  end;

  TExtPollColl = class(TColl)
    function Crc32Item(Item: Pointer; Crc32: DWORD): DWORD; override;
    constructor Load(Stream: TxStream); override;
  end;

  TPasswordColl = class(TColl)
    AuxFile: string;
    function Password(Addr: TFidoAddress): string;
    function Crc32Item(Item: Pointer; Crc32: DWORD): DWORD; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Crc32(Init: DWORD): DWORD; override;
  end;

  TPerPollColl = class(TColl)
    function Crc32Item(Item: Pointer; Crc32: DWORD): DWORD; override;
    constructor Load(Stream: TxStream); override;
  end;


  TPasswordColl_v120 = class(TColl)
    function Upgrade: TPasswordColl;
    constructor Load(Stream: TxStream); override;
  end;


  TFreqOption = (foDisable, foRecursive, foMasks, foRealTime, foSRIF);
  TFreqOptions = set of TFreqOption;

  TFreqData = class(TColl)
    Options : TFreqOptions;
    function GetSC(Index: Integer): TStringColl;
    property pnPaths : TStringColl index 0 read GetSC;
    property pnPsw   : TStringColl index 1 read GetSC;
    property alNames : TStringColl index 2 read GetSC;
    property alPaths : TStringColl index 3 read GetSC;
    property alPsw   : TStringColl index 4 read GetSC;
    property Misc    : TStringColl index 5 read GetSC;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    constructor Create;
    destructor Destroy; override;
    function Copy: Pointer; override;
  end;

  TIpEvtIds = class(TAdvObject)
    EvtIds: PIntArray;
    EvtCnt: DWORD;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    destructor Destroy; override;
  end;

  TEventColl = class(TElementColl)
    constructor Load(Stream: TxStream); override;
  end;

  TPollOptionFlag = (pofHold, pofDirAsNormal);
  TPollOptionFlags = set of TPollOptionFlag;

  TPollOptionsDataRec = record
    Busy, NoC, Fail, Retry, Standoff: DWORD;
    Flags: TPollOptionFlags;
  end;

  TPollOptionsData = class(TAdvCpObject)
    d: TPollOptionsDataRec;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
  end;

  TEncryptedNodeData = class(TAdvCpObject)
    Addr: TFidoAddress;
    Key: TdesBlock;
    function Copy: Pointer; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
  end;

  TEncryptedNodeColl = class(TSortedColl)
    function KeyOf(Item: Pointer): Pointer; override;
    function Compare(Key1, Key2: Pointer): Integer; override;
    function Copy: Pointer; override;
    constructor Load(Stream: TxStream); override;
  end;

  TECBEncryptedCfgBlock = class(TAdvObject)
    FStream: TxMemoryStream;
    constructor Load(Stream: TxStream); override;
    destructor Destroy; override;
  end;

  TCBCEncryptedCfgBlock = class(TAdvObject)
    FStream: TxMemoryStream;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    destructor Destroy; override;
  end;

  TProxyData = class(TAdvObject)
    Enabled: Boolean;
    Addr: string;
    Port: DWORD;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
  end;

  TInstallRec = class(TAdvObject)
    InstallDay: DWORD;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
  end;

  TFileBoxCfgColl = class(TColl)
    Copied: Boolean;
    DefaultDir: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
  end;

  TCfgContainer = class
    InstallRec: TInstallRec;
    MasterKey: TdesBlock;
    MasterKeyChk: Word;
    RegWarnShown: Boolean;
    CS: TRTLCriticalSection;
    UpgStrings: TStringColl;
    StartupData: TStartupRec;
    FreqData: TFreqData;
    NodeList: TNodelistData;
    Lines: TLineColl;
    Station: TStationColl;
    Ports: TPortColl;
    Modems: TModemColl;
    Restrictions: TRestrictColl;
    PathNames: TPathnameColl;
    Passwords: TPasswordColl;
    PerPolls: TPerPollColl;
    DialupNodeOverrides: TDialupNodeOvrColl;
    IPNodeOverrides: TIPNodeOvrColl;
    IPData: TIPRec;
    ExtCollA: TExtCollA;
    ExtCollB: TExtCollB;
    DrsCollA: TDrsCollA;
    DrsCollB: TDrsCollB;
    CrnCollA: TCrnCollA;
    CrnCollB: TCrnCollB;
    IpDomA: TIpDomCollA;
    IpDomB: TIpDomCollB;
    IpAkaCollA: TIpAkaCollA;
    IpAkaCollB: TIpAkaCollB;
    Events: TEventColl;
    IpEvtIds: TIpEvtIds;
    PollOptions: TPollOptionsData;
    EncryptedNodes: TEncryptedNodeColl;
    FileBoxes: TFileBoxCfgColl;
    ExtPolls: TExtPollColl;
    Proxy: TProxyData;
    FreeLastLoadObj: Boolean;
    PerPollsA_3240: TPerPollsCollA_3240;
    PerPollsB_3250: TPerPollsCollB_3250;
    class procedure SetObj(ap: Pointer; ao: TAdvObject);
    constructor Create;
    destructor Destroy; override;
    procedure AddUpgStringLng(i: Integer);
    function DoLoad(Stream: TxStream): Boolean;
    procedure DoStore(Stream: TxStream);
    procedure PutObjects(s: TxStream);
    procedure ReFill;
    procedure Enter;
    procedure Leave;
  end;

  TBWZRec = class
    FName: string;
    BWZNo,
    FSize,
    FTime,
    TmpSize,
    Prot: DWORD;
    Addr: TFidoAddress;
    Locked: Boolean;
    function GetBWZFName: string;
    function Toss(var s: string; var Overwritten: Boolean): Boolean;
    destructor Destroy; override;
  end;

  TBWZColl = class(TColl)
  private
    FHandle: THandle;
    FName: string;
    LastS: string;
    function NIdx(N: DWORD): Integer;
    function InternalUpdate: Boolean;
  public
    LastToss: EventTimer;
    procedure Update;
    destructor Destroy; override;
  end;

  TReqFile = class
    Info: TFileInfo;
    FName: string;
  end;

  TReqTyp = (rtParseError, rtOK, rtNormal, rtNewer, rtUpTo);
  TReqRec = class
    Typ: TReqTyp;
    S: string;
    Psw: string;
    Upd: DWORD;
    Files: TColl;
    SRPs: TStringColl;
    procedure Add(const FName, APsw: string; Info: TFileInfo);
    procedure AddSRP(const AStr, APsw: string);
    destructor Destroy; override;
  end;

  TImportRec = class
    Addr: TFidoAddress;
    DialupOverrides, IPOverrides, Password: string;
  end;

  TAlienCfgType = (actNone, actBinkD, actBinkPlus, actTMail, actXenia, actFrontDoor, actMainDoor, actTMailSubst, actTMailSecutiry);


{ Events }

type
  TEventParamTyp = (eptUnk, eptVoid, eptString, eptCombo, eptSpin, eptBool, eptDStr, eptDMemo, eptGrid);

  TEventAtom = class(TAdvCpObject)
    Typ: Integer;
    function Params: string; virtual; abstract;
    function Name: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
  end;

  TEvParVoid = class(TEventAtom)
    function Copy: Pointer; override;
    function Params: string; override;
  end;


  TEvParString = class(TEventAtom)
    s: string;
    function Copy: Pointer; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Params: string; override;
  end;

  TEvParDStr = class(TEventAtom)
    StrA, StrB: string;
    function Copy: Pointer; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Params: string; override;
  end;

  TEvParDMemo = class(TEventAtom)
    MemoA, MemoB: string;
    function Copy: Pointer; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Params: string; override;
  end;

  TEvParGrid = class(TEventAtom)
    s: string;
    L: TColl;
    constructor Create;
    function Copy: Pointer; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Params: string; override;
    destructor Destroy; override;
  end;

  RUVData = record
    case Integer of
      0: (PointerData: Pointer);
      1: (DwordData: DWORD);
      2: (ByteData: Byte);
      3: (BooleanData: Boolean);
  end;

  TEvParUV = class(TEventAtom)
    d: RUVData;
    function Copy: Pointer; override;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Params: string; override;
  end;

  TEventContainer = class(TNamed)
    Cron: string;
    Len: DWORD;
    Atoms: TColl;
    Permanent: Boolean;
    UTC: Boolean;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
    procedure SetDefault; override;
    constructor Create; override;
    destructor Destroy; override;
  end;


  TEventContainer_v3310 = class(TNamed)
    Cron: string;
    Len: DWORD;
    Atoms: TColl;
    constructor Load(Stream: TxStream); override;
    destructor Destroy; override;
    function Upgrade: TEventContainer;
  end;

  TExtPoll = class(TAdvCpObject)
    FAddrs, FOpts, FCmd: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
  end;

  TFileBoxCfg = class(TAdvCpObject)
    FStatus: TOutStatus;
    FAddr, FDir: string;
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    function Copy: Pointer; override;
    function Dir(const ADef: string; I: Integer): string;
    function KillAction: TKillAction;
  end;

  TNodeWizzardRec = class
    A: TFidoAddress;
    EvtIds, DialRestIds, AkaStationIds: TColl;
    DupOvr, IpOvr, Password, FBoxOut, FBoxIn, PollPer, PollExt, PostProc: string;
    IsDaemonRest, IsDaemonAKA, IsEncryptedLink, Found: Boolean;
    procedure FreeIds;
    procedure FinalizeStrs;
    destructor Destroy; override;
  end;

  TNodeWizzardColl = class(TSortedColl)
    function Compare(Key1, Key2: Pointer): Integer; override;
    function KeyOf(Item: Pointer): Pointer; override;
  end;

var
  Cfg: TCfgContainer;
  AuxPwdsCS: TRTLCriticalSection;
  AuxPwds: TPasswordColl;

  AuxDialupNodeOverrides: TDialupNodeOvrColl;
  AuxDialupNodeOverridesCS: TRTLCriticalSection;

{$IFDEF WS}
  AuxIPNodeOverrides: TIPNodeOvrColl;
  AuxIPNodeOverridesCS: TRTLCriticalSection;
{$ENDIF}

  BWZColl: TBWZColl;
  StoreConfigAfter,
  ExitNow: Boolean;
  GlobalEvtUpdateTick: DWORD;

type
  TRestrictionScope  = (rspUndef, rspDialup, rspIP, rspBoth);

function HomeDir: string;
procedure UpdateGlobalEvtUpdateFlag;
function FullPath(const Dir: string): string;
procedure RegisterConfig;
procedure LoadConfig;
function StoreConfig(Handle: DWORD): Boolean;
procedure LoadIntegers;
procedure StoreIntegers;

function SetRegBoolean(const AKey: string; AValue: Boolean): Boolean;
function SetRegHelpLng(const S: string): Boolean;
function GetRegHelpLng: string;
function SetRegInterfaceLng(I: Integer): Boolean;
function GetRegInterfaceLng: Integer;
function SetRegHomeDir(const S: string): Boolean;
function GetRegHomeDir: string;
function GetRegStringDef(const AKeyName, ADefault: string): string;
function GetRegIntegerDef(const AKeyName: string; ADefault: Integer): Integer;
function GetRegBooleanDef(const AKeyName: string; ADefault: Boolean): Boolean;
function SetRegBin(const rvn: string; Bin: Pointer; Sz: Integer): Boolean;
function GetRegBin(const rvn: string; Bin: Pointer; Sz: Integer): Boolean;
function ReadAppMode: Integer;
function WriteAppMode(AMode: Integer): Boolean;

function ComName(I: Integer): string;
function GetLineBits(D, P, S: Byte): string;
function  FindNo(N: Integer; L: TColl): Integer;
function  GetFreeNo(const L: array of TColl): Integer;
procedure LoadHistory;
procedure StoreHistory;
function dOutbound: string;
function dLog: string;
function NDLPath: string;

function OpenBWZLog: Boolean;
procedure CloseBWZLog;
function GetBWZ(const FName: string; FSize, FTime: DWORD; Addr: TFidoAddress; AddrList: TFidoAddrColl): TBWZRec;
function AddBWZ(const FName: string; FSize, FTime, Prot: DWORD; Addr: TFidoAddress): TBWZRec;
procedure FreeBWZ(var Rec: TBWZRec);
function ParseREQ(var ASC: TStringColl): TColl;
procedure ScanREQ(Coll: TColl);
function DialAllowed(AR: TRestrictionData; Flags, Phone: string; Addr: TFidoAddress; var AExpl: string): Boolean;
function PatchPhoneNumber(const Number: string; AddPrefix: Boolean): string;

function ValidRestrictEntry(const Entry: string; AMsgs: TStringColl;  AScope: TRestrictionScope): Boolean;
function NodeOvrValid(AOvr: TAbsNodeOvrColl; APgOvr: Pointer; AHandle: THandle; Dialup: Boolean): Boolean;
procedure SetNodeOvr(AOvr: TAbsNodeOvrColl; APgOvr: Pointer);

function ValidPortsList(const s: string): Boolean;
function ParsePortsList(A: PvIntArr; s: string): Boolean;
function IsAutoStartLine(Id: Integer): Boolean;
function WithinIntArr(Id: Integer; IA: PIntArray; IC: Integer): Boolean;
procedure FreeCfgContainer;
function GetNodeOvrData(Addr: TFidoAddress; {$IFDEF WS}Dialup: Boolean; {$ENDIF}ALNode: TFidoNode): TColl;
procedure InsUA(var C: TColl; AN: TAdvNodeData);
procedure PostCloseMessage;
procedure ImportAlienCfg(const FName: string; Coll: TColl; Typ: TAlienCfgType);
procedure FillGridPswOvr(AColl, AGrid: Pointer; APwd: Boolean);
procedure DoImportOp(AColl, AGrid: Pointer; APsw, ADialup: Boolean);
function CronGridValid(AG: Pointer): Boolean;
function GetEventParamTyp(i: Integer): TEventParamTyp;
procedure TossItems(CA, CB: TColl; Items: TElementColl; var A: PIntArray; var Cnt: Integer);
procedure FillListBoxNamed(l: TListBox; c: TColl);
function _OvrSort(Item1, Item2: Pointer): Integer;
function EncNodeSort(p1, p2: Pointer): Integer;
function ValidDialupRestrictionData(AR: TRestrictionData; Handle: DWORD): Boolean;
function ValidRestrictionColl(SC: TStringColl; var AMsgs: TStringColl; AScope: TRestrictionScope): Boolean;
function ValidAKAGrid(A: Pointer): Boolean;
function ConfigFName: string;

procedure CfgEnter;
procedure CfgLeave;

function GetInboundDir(const Addr: TFidoAddress; const FName: string; APasswordProtected: Boolean; var APutKind: TInboundPutKind): string;
function ExpandSuperMask(const AMask: string): string;
function DefaultZone: Integer;
function MoveFileSmart(const S1: string; var S2: string; ReplaceExisting: Boolean; var Overwritten: Boolean): Boolean;

type
  TReplaceMacroOp = (rmkUnk, rmkTime, rmkAddr, rmkStatus, rmkOnce);
  TReplaceMacroOpSet = set of TReplaceMacroOp;
  PDirMacro = ^TDirMacro;
  TDirMacro = (dmYEAR, dmMONTHN, dmMONTHA, dmMONTHS, dmDAY, dmHOUR, dmMINUTE, dmSECOND, dmDOWN, dmDOWA, dmDOWS,
  dmZONE, dmNET, dmNODE, dmPOINT, dmHZONE, dmHNET, dmHNODE, dmHPOINT,
  dmXZONE, dmXNET, dmXNODE, dmXPOINT, dmSTATUS, dmTSTATUS);

function ReplaceDirMacro(const AStr: string; Addr: PFidoAddress; AStatus: POutStatus; AOps: TReplaceMacroOpSet; AResultMacro: PDirMacro): string;
procedure ReportRestrictionData(Strs: TStringColl; AData: TRestrictionData);
procedure BuildNodeWizzardColl(FColl: TNodeWizzardColl; ABuildStrings: Boolean);
procedure SaveNodeWizzardColl(AColl: TNodeWizzardColl; ARec: TNodeWizzardRec);

function ReportDuplicateAddrs(AColl: TColl; AGrid: Pointer; AMsg: Integer): Boolean;

var
  SimpleBSY: Boolean;
  sEMSI_CR: ShortString;
  CloseBWZFile: Boolean;
  ForceAddFaxPage: Boolean;
  ODBC_Logging: Boolean;
  IncrementArcmail: Boolean;

procedure InitHelp;
  

implementation uses Forms, SysUtils, MClasses, Credits, mGrids, {xKey, }LngTools, NdlUtil, xIP, Import, Controls, SinglPwd, StartWiz;
          

function DefaultZone: Integer;
begin
  CfgEnter;
  Result := Cfg.PathNames.DefaultZone;
  CfgLeave;
end;



type
  TStarter = class(TAdvObject)
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    destructor Destroy; override;
  end;

  TTerminator = class(TAdvObject)
    constructor Load(Stream: TxStream); override;
    procedure Store(Stream: TxStream); override;
    destructor Destroy; override;
  end;

constructor TNodelistData.Load(Stream: TxStream);
begin
  SrcPfx := Stream.Get;
  DstPfx := Stream.Get;
  Files  := Stream.Get;
  Cfg.SetObj(@Cfg.Nodelist, Self);
end;

procedure TNodelistData.Store(Stream: TxStream);
begin
  Stream.Put(SrcPfx);
  Stream.Put(DstPfx);
  Stream.Put(Files);
end;

constructor TNodelistData.Create;
begin
  SrcPfx := TStringColl.Create;
  DstPfx := TStringColl.Create;
  Files  := TStringColl.Create;
end;

destructor TNodelistData.Destroy;
begin
  FreeObject(SrcPfx);
  FreeObject(DstPfx);
  FreeObject(Files);
  inherited Destroy;
end;

class procedure TCfgContainer.SetObj(ap: Pointer; ao: TAdvObject);
var
  p: PAdvObject;
begin
  p := PAdvObject(ap);
  if p^ <> nil then GlobalFail('TCfgContainer.SetObj - %s is already set', [p.ClassName]);
  p^ := ao;
end;
                         

procedure TCfgContainer.AddUpgStringLng;
var
  s: string;
begin
  s := LngStr(i);
  if UpgStrings = nil then UpgStrings := TStringColl.Create;
  if not UpgStrings.Found(s) then UpgStrings.Ins(s);
end;


procedure TCfgContainer.Enter;
begin
  EnterCS(CS);
end;

procedure TCfgContainer.Leave;
begin
  LeaveCS(CS);
end;

function TCfgContainer.DoLoad(Stream: TxStream): Boolean;
begin
  Result := False;
  repeat
    Stream.Get;
    if not Stream.GotStarter then Break;
    if Stream.GotTerminator then begin Result := True; Break end;
    if (Stream.Position >= Stream.Size) then Break;
  until False;
end;

procedure PutStarter(Stream: TxStream);
var
  o: TAdvObject;
begin
  o := TStarter.Create; Stream.Put(o); FreeObject(o);
end;

procedure PutTerminator(Stream: TxStream);
var
  o: TAdvObject;
begin
  o := TTerminator.Create; Stream.Put(o); FreeObject(o);
end;

procedure TCfgContainer.PutObjects(s: TxStream);
begin
  PutStarter(s);
  s.Put(StartupData);
  s.Put(NodeList);
  s.Put(Pathnames);
  s.Put(Lines);
  s.Put(Station);
  s.Put(Ports);
  s.Put(Modems);
  s.Put(Restrictions);
  s.Put(Passwords);
  s.Put(FreqData);
  s.Put(DialupNodeOverrides);
  s.Put(IPNodeOverrides);
  s.Put(IPData);
  s.Put(ExtCollA);
  s.Put(ExtCollB);
  s.Put(DrsCollA);
  s.Put(DrsCollB);
  s.Put(CrnCollA);
  s.Put(CrnCollB);
  s.Put(IpAkaCollA);
  s.Put(IpAkaCollB);
  s.Put(IpDomA);
  s.Put(IpDomB);
  s.Put(Events);
  s.Put(IpEvtIds);
  s.Put(PollOptions);
  s.Put(EncryptedNodes);
  s.Put(ExtPolls);
  s.Put(Proxy);
  s.Put(InstallRec);
  s.Put(FileBoxes);
  s.Put(PerPolls);
  PutTerminator(s);
end;


procedure TCfgContainer.DoStore(Stream: TxStream);
var
  s: TxMemoryStream;
  b: TCBCEncryptedCfgBlock;
begin
  if MasterKey = 0 then PutObjects(Stream) else
  begin
    s := GetMemoryStream;
    PutObjects(s);
    b := TCBCEncryptedCfgBlock.Create;
    b.FStream := s;
    PutStarter(Stream);
    Stream.Put(b);
    FreeObject(b);
    PutTerminator(Stream);
  end;  
end;

procedure TCfgContainer.Refill;

procedure CreatePorts;
var
  d: TPortRec;
  p: Byte;
begin
  Ports := TPortColl.Create;
  d := TPortRec.Create;
  d.Id := -1;
  d.SetDefault;
  p := 1;
  if StartWizDialProps <> nil then p := StartWizDialProps.ComPortIndex;
  d.d.Port   := p;
  Ports.Insert(d);
  Ports.InvalidateId;
end;

procedure CreateLines;
var
  l: TLineRec;
begin
  Lines := TLineColl.Create;
  l := TLineRec.Create;
  l.id := -1;
  l.FName := LngStr(rsRecsLine);
  l.SetDefault;
  {$IFNDEF WS}
  l.d.Options := [];
  {$ENDIF}
  Lines.Insert(l);
  Lines.InvalidateId;
end;

procedure CreateStation;
var
  s: TStationRec;
begin
  Station := TStationColl.Create;
  s := TStationRec.Create;
  s.id := -1;
  s.FName := LngStr(rsRecsStation);
  s.Data.Fill([
    'New Year BBS',
    '1:2/3.4@frostnet 5:6/7.8@xmasnet',
    'Santa Claus',
    'Laplandia, Suomi',
    '+123-4-567-890',
    'MO,CM,ZYX'
   ]);
  s.Banner := 'Welcome to New Year BBS'#13#10#13#10+
              'Processing mail only - please hangup';
  Station.Insert(s);
  Station.InvalidateId;
end;

procedure UpgradeLines;
var
  i: Integer;
  t: TObject;
begin
  for i := 0 to Lines.Count-1 do
  begin
    t := Lines[i];
    if t is TLineRec_v3010 then
    begin
      Lines[i] := TLineRec_v3010(t).Upgrade;
      FreeObject(t);
      t := Lines[i];
    end;
    if t is TLineRec_v3011 then
    begin
      Lines[i] := TLineRec_v3011(t).Upgrade;
      FreeObject(t);
    end;
  end;
end;

procedure UpgradeModems;
var
  i: Integer;
  t: TObject;
begin
  for i := 0 to Modems.Count-1 do
  begin
    t := Modems[i];
    if t is TModemRec_v3040 then
    begin
      Modems[i] := TModemRec_v3040(t).Upgrade;
      FreeObject(t);
    end;
  end;
end;

procedure UpgradeStation;
var
  i: Integer;
  t: TObject;
begin
  for i := 0 to Station.Count-1 do
  begin
    t := Station[i];
    if t is TStationRec_v3020 then
    begin
      Station[i] := TStationRec_v3020(t).Upgrade;
    end else
    if t is TStationRec_v3021 then
    begin
      Station[i] := TStationRec_v3021(t).Upgrade;
    end else Continue;
    FreeObject(t);
  end;
end;

procedure UpgradeRestrictions;
var
  i: Integer;
  t: TObject;
begin
  for i := 0 to Restrictions.Count-1 do
  begin
    t := Restrictions[i];
    if t is TRestrictionRec_v3050 then
    begin
      Restrictions[i] := TRestrictionRec_v3050(t).Upgrade;
    end else Continue;
    FreeObject(t);
  end;
end;


procedure UpgradeEvents;
var
  i: Integer;
  t: TObject;
begin
  for i := 0 to Events.Count-1 do
  begin
    t := Events[i];
    if t is TEventContainer_v3310 then
    begin
      Events[i] := TEventContainer_v3310(t).Upgrade;
    end else Continue;
    FreeObject(t);
  end;
end;


procedure CreateModems;
var
  m: TModemRec;
begin
  Modems := TModemColl.Create;
  m := TModemRec.Create;
  m.id := -1;
  m.FName := LngStr(rsRecsModem);
  m.SetDefault;
  Modems.Insert(m);
  Modems.InvalidateId;
end;

procedure CreateRestictions;
var
  r: TRestrictionRec;
begin
  Restrictions := TRestrictColl.Create;
  r := TRestrictionRec.Create;
  r.id := -1;
  r.FName := LngStr(rsRecsRestriction);
  if (StartWizDialProps <> nil) and
     (StartWizDialProps.SetRestrict) and
     (StartWizDialProps.AreaCode <> '') then
  begin
    r.Data.Required.Add(StartWizDialProps.AreaCode+'-');
  end;
  Restrictions.Insert(r);
  Restrictions.InvalidateId;
end;

procedure CreateNodelist;
begin
  NodeList := TNodelistData.Create;
  if StartWizDialProps = nil then Exit;
  NodeList.SrcPfx.Add(StartWizDialProps.AreaCode + '-');
  NodeList.DstPfx.Add(StartWizDialProps.LocalPrefix + '-');
  NodeList.SrcPfx.Add('-');
  NodeList.DstPfx.Add(StartWizDialProps.LongDistPrefix+ '-');
end;

procedure CreatePathNames;
begin
  PathNames := TPathNameColl.Create;
  PathNames.Fill(['IN','INSEC','INTMP','OUT','LOG']);
  PathNames.DefaultZone := 2;
end;

procedure UpgradePerPolls;
var
  i: Integer;
  r: TPerPollRec;
  a: TFidoAddrColl;
  c: string;
begin
  for i := 0 to MinI(PerPollsA_3240.Count, PerPollsB_3250.Count)-1 do
  begin
    c := PerPollsA_3240[i];
    if not ValidCronRec(c) then Continue;
    a := CreateAddrColl(PerPollsB_3250[i]);
    if a = nil then Continue;
    r := TPerPollRec.Create;
    r.Cron := c;
    XChg(r.AddrList, a); FreeObject(a);
    PerPolls.Add(r);
  end;
  Cfg.AddUpgStringLng(rsRecsCronCmb);
end;

procedure CreatePerPolls;
begin
  PerPolls := TPerPollColl.Create;
  if (PerPollsA_3240 <> nil) and (PerPollsB_3250 <> nil) then UpgradePerPolls;
  FreeObject(PerPollsA_3240);
  FreeObject(PerPollsB_3250);
end;

procedure CreatePasswords;
begin
  Passwords := TPasswordColl.Create;
end;

procedure CreateFreqs;
begin
  FreqData := TFreqData.Create;
  FreqData.Options := [foDisable]
end;

procedure CreateDialupNodeOvr;
begin
  DialupNodeOverrides := TDialupNodeOvrColl.Create;
end;

procedure CreateIPNodeOvr;
begin
  IPNodeOverrides := TIPNodeOvrColl.Create;
end;

procedure CreateIPData;
begin
  IPData := TIPRec.Create;
  IPData.InPorts.Fill(['60179', '23 60177', '24554']);
  IPData.StationData.Fill(['New Year IP Server',
    '1:2/3.4 5:6/7.8',
    'Santa Claus',
    'Laplandia, Suomi',
    '192.168.0.2',
    'MO,CM,TCP,IFC,TEL,VMP,BND']);

  IPData.InC := 16;
  IPData.OutC := 4;
  IPData.Speed := 600;
  IPData.Banner := 'Welocome to New Year IP Server'#13#10#13#10+
                   'Processing mail only - disconnect please';
end;



procedure CreateStartupData;
var
  o: Byte;
begin
  StartupData := TStartupRec.Create;
  o := stoFastLog;
  {$IFDEF WS}
  if StartWizAutoStartDaemon then o := o or stoRunIpDaemon;
  {$ENDIF}
  StartupData.Options := o;
end;

procedure CreateExtCollA;
begin
  ExtCollA := TExtCollA.Create;
end;

procedure CreateExtCollB;
begin
  ExtCollB := TExtCollB.Create;
end;

procedure CreateDrsCollA;
begin
  DrsCollA := TDrsCollA.Create;
end;

procedure CreateDrsCollB;
begin
  DrsCollB := TDrsCollB.Create;
end;

procedure CreateCrnCollA;
begin
  CrnCollA := TCrnCollA.Create;
end;

procedure CreateCrnCollB;
begin
  CrnCollB := TCrnCollB.Create;
end;

procedure CreateIpAkaCollA;
begin
  IpAkaCollA := TIpAkaCollA.Create;
end;

procedure CreateIpAkaCollB;
begin
  IpAkaCollB := TIpAkaCollB.Create;
end;

procedure CreateIpDomCollA;
begin
  IpDomA := TIpDomCollA.Create;
  IpDomA.Add('1:*/* 2:*/* 3:*/* 4:*/* 5:*/* 6:*/* 7:*/*');
end;

procedure CreateIpDomCollB;
begin
  IpDomB := TIpDomCollB.Create;
  IpDomB.Add('fidonet.net');
end;

procedure CreateEvents;
begin
  Events := TEventColl.Create;
end;

procedure CreateIpEvtIds;
begin
  IpEvtIds := TIpEvtIds.Create;
end;

procedure CreateProxy;
begin
  Proxy := TProxyData.Create;
  Proxy.Port := 1080;
end;

procedure CreateInstallRec;
begin
  InstallRec := TInstallRec.Create;
  InstallRec.InstallDay := uGetSystemTime;
  if Passwords <> nil then StoreConfigAfter := True;
end;

procedure RefillFreqData;
begin
  while Cfg.FreqData.Misc.Count < 1 do Cfg.FreqData.Misc.Add('');
end;

procedure CreatePollOptions;
const
  DialStandoffTimeout = 20;  // minutes
  DialRetryTimeout = 60; // seconds
  MaxBusyTries = 9;
  MaxNoConnectTries = 6;
  MaxSessionAbortedTries = 4;
begin
  PollOptions := TPollOptionsData.Create;
  with PollOptions.d do
  begin
    Busy := MaxBusyTries;
    NoC := MaxNoConnectTries;
    Fail := MaxSessionAbortedTries;
    Retry := DialRetryTimeout;
    Standoff := DialStandoffTimeout;
  end;
end;

procedure CreateEncryptedNodes;
begin
  EncryptedNodes := TEncryptedNodeColl.Create;
end;

procedure CreateExtPolls;
begin
  ExtPolls := TExtPollColl.Create;
end;

function InvC(C: TColl): Pointer;
begin
  Result := C;
  if CollCount(Result) = 0 then FreeObject(Result);
end;

procedure CreateFileBoxes;
begin
  FileBoxes := TFileBoxCfgColl.Create;
end;

begin
  if InstallRec = nil then CreateInstallRec;
  if Passwords = nil then CreatePasswords;
  if StartupData = nil then CreateStartupData;
  if NodeList = nil then CreateNodelist;
  if InvC(Lines) = nil then CreateLines else UpgradeLines;
  if InvC(Station) = nil then CreateStation else UpgradeStation;
  if InvC(Ports) = nil then CreatePorts;
  if InvC(Modems) = nil then CreateModems else UpgradeModems;
  if InvC(Restrictions) = nil then CreateRestictions else UpgradeRestrictions;
  if PathNames = nil then CreatePathNames;
  if FreqData = nil then CreateFreqs;
  if DialupNodeOverrides = nil then CreateDialupNodeOvr;
  if IPNodeOverrides = nil then CreateIPNodeOvr;
  if IPData = nil then CreateIPData;
  if ExtCollA = nil then CreateExtCollA;
  if ExtCollB = nil then CreateExtCollB;
  if DrsCollA = nil then CreateDrsCollA;
  if DrsCollB = nil then CreateDrsCollB;
  if CrnCollA = nil then CreateCrnCollA;
  if CrnCollB = nil then CreateCrnCollB;
  if IpDomA = nil then CreateIpDomCollA;
  if IpDomB = nil then CreateIpDomCollB;
  if IpAkaCollA = nil then CreateIpAkaCollA;
  if IpAkaCollB = nil then CreateIpAkaCollB;
  if Events = nil then CreateEvents else UpgradeEvents;
  if IpEvtIds = nil then CreateIpEvtIds;
  if PollOptions = nil then CreatePollOptions;
  if EncryptedNodes = nil then CreateEncryptedNodes;
  if ExtPolls = nil then CreateExtPolls;
  if Proxy = nil then CreateProxy;
  if FileBoxes = nil then CreateFileBoxes;
  if PerPolls = nil then CreatePerPolls;
  RefillFreqData;
end;

constructor TCfgContainer.Create;
begin
  inherited Create;
  InitializeCriticalSection(CS);
end;


destructor TCfgContainer.Destroy;
begin
  DeleteCriticalSection(CS);
  FreeObject(StartupData);
  FreeObject(FreqData);
  FreeObject(NodeList);
  FreeObject(Lines);
  FreeObject(Station);
  FreeObject(Ports);
  FreeObject(Modems);
  FreeObject(Restrictions);
  FreeObject(PathNames);
  FreeObject(Passwords);
  FreeObject(DialupNodeOverrides);
  FreeObject(IPNodeOverrides);
  FreeObject(IPData);
  FreeObject(ExtCollA);
  FreeObject(ExtCollB);
  FreeObject(DrsCollA);
  FreeObject(DrsCollB);
  FreeObject(CrnCollA);
  FreeObject(CrnCollB);
  FreeObject(PerPolls);
  FreeObject(IpAkaCollA);
  FreeObject(IpAkaCollB);
  FreeObject(IpDomA);
  FreeObject(IpDomB);
  FreeObject(Events);
  FreeObject(IpEvtIds);
  FreeObject(PollOptions);
  FreeObject(EncryptedNodes);
  FreeObject(ExtPolls);
  FreeObject(Proxy);
  FreeObject(InstallRec);
  FreeObject(FileBoxes);
  inherited Destroy;
end;

procedure FreeCfgContainer;
begin
  FreeObject(Cfg);
end;

const
  ridStarter       =   12;
  ridTerminator    =   13;
  ridHistoryItem   =   15;
  ridNodelist      =   20;
  ridPasswordRec   =   22;
  ridPerPollRec    =   23;
  ridNodeOvr       =   24;
  ridExtPoll       =   25;

  ridFidoAddrColl  =   40;

  ridEncryptedNode =   50;
  ridFileBoxCfg    =   53;

  ridColl                  =  100;
  ridExtPollColl           =  102;
  ridStringColl            =  110;
  ridPasswordColl_v120     =  120;
  ridPasswordColl          =  121;
  ridDupNodeOvrC_v130      =  130;
  ridDupNodeOvrC           =  131;
  ridIPNodeOvrColl_v135    =  135;
  ridIPNodeOvrColl         =  136;
  ridFileBoxCfgColl        =  140;
  ridPerPollColl           =  150;

  ridHistoryID     =  200;

  ridLineColl      = 1031;
  ridStationColl   = 1040;
  ridPortColl      = 1050;
  ridModemColl     = 1062;
  ridRestrictColl  = 1070;
  ridPathnameColl  = 1082;

  ridModemStdResp  = 2010;
  ridModemCmdsColl = 2020;
  ridStatDataColl  = 2030;
  ridHistoryColl   = 2040;
  ridInPortsColl   = 2050;

  ridPollOptsData  = 2060;
  ridEncNodeColl   = 2070;

  ridLineRec_v3010 = 3010;
  ridLineRec_v3011 = 3011;
  ridLineRec       = 3012;
  ridSR_v3020      = 3020;
  ridSR_v3021      = 3021;
  ridStationRec    = 3022;
  ridPortRec       = 3030;
  ridModemRec_v3040= 3040;
  ridModemRec      = 3041;
  ridRR_v3050      = 3050;
  ridRestrictRec   = 3051;
  ridRestrictData  = 3055;
  ridFreqData      = 3060;
  ridIPRec_v3074   = 3074;
  ridIPRec_v3075   = 3075;
  ridIPRec         = 3076;
  ridStartupRec    = 3090;
  ridExtCollA      = 3200;
  ridExtCollB      = 3210;
  ridDrsCollA      = 3220;
  ridDrsCollB      = 3230;
  ridCrnCollA      = 3232;
  ridCrnCollB      = 3236;
  ridPerPollsCollA_v3240 = 3240;
  ridPerPollsCollB_v3250 = 3250;
  ridIpAkaCollA    = 3260;
  ridIpAkaCollB    = 3270;
  ridIpDomCollA    = 3280;
  ridIpDomCollB    = 3290;
  ridEventColl     = 3300;
  ridEvtContainer_v3310  = 3310;
  ridEvtContainer  = 3311;
  ridEvParVoid     = 3320;
  ridEvParString   = 3330;
  ridIpEvtIds      = 3340;
  ridEvParUV       = 3350;
  ridEvParDStr     = 3360;
  ridEvParDMemo    = 3370;
  ridEvParGrid     = 3380;

  ridECBEncCfgBlock   = 3400;
  ridCBCEncCfgBlock   = 3401;

  ridProxyData     = 3500;
  ridInstallRec    = 3600;

var
  FHomeDir: ShortString;

function HomeDir: string;
begin
  Result := FHomeDir;
end;

procedure RegisterConfig;
var
  S: string;
begin
  S := GetRegHomeDir;
  if S = '' then
  begin
    S := MakeNormName(ExtractFilePath(WindowsDirectory), 'ARGUS');
    if not FileExists(MakeNormName(S, 'config.bin')) then
    begin
      StoreConfigAfter := True;
      S := ExtractFileDir(ParamStr(0));
    end;
    if not SetRegHomeDir(S) then
    begin
      DisplayErrorLng(rsCantUpdateReg,0);
      Application.Terminate;
      Exit;
    end;
  end;
  FHomeDir := ExtractDir(S);
  if DirExists(HomeDir)=0 then
  begin
    if not CreateDirInheritance(HomeDir) then
    begin
      DisplayErrorFmtLng(rsRecsCAHD, [HomeDir], 0);
      Halt
    end;
  end;

  RegisterIoRec(TStarter, ridStarter);
  RegisterIoRec(TTerminator, ridTerminator);
  RegisterIoRec(TNodelistData, ridNodelist);
  RegisterIoRec(TColl, ridColl);
  RegisterIoRec(TStringColl, ridStringColl);
  RegisterIoRec(TLineColl, ridLineColl);
  RegisterIoRec(TStationColl, ridStationColl);
  RegisterIoRec(TPortColl, ridPortColl);
  RegisterIoRec(TModemColl, ridModemColl);
  RegisterIoRec(TRestrictColl, ridRestrictColl);
  RegisterIoRec(TModemStdResp, ridModemStdResp);
  RegisterIoRec(TModemCmdsColl, ridModemCmdsColl);
  RegisterIoRec(TStationDataColl, ridStatDataColl);
  RegisterIoRec(TPathnameColl, ridPathnameColl);
  RegisterIoRec(TInPortsColl, ridInPortsColl);
  RegisterIoRec(TEncryptedNodeColl, ridEncNodeColl);
  RegisterIoRec(TPollOptionsData, ridPollOptsData);
  RegisterIoRec(TExtPoll, ridExtPoll);
  RegisterIoRec(TExtPollColl, ridExtPollColl);
  RegisterIoRec(TFileBoxCfgColl, ridFileBoxCfgColl);

  RegisterIoRec(TLineRec_v3010, ridLineRec_v3010);
  RegisterIoRec(TLineRec_v3011, ridLineRec_v3011);
  RegisterIoRec(TLineRec, ridLineRec);
  RegisterIoRec(TStationRec_v3020, ridSR_v3020);
  RegisterIoRec(TStationRec_v3021, ridSR_v3021);
  RegisterIoRec(TStationRec, ridStationRec);
  RegisterIoRec(TPortRec, ridPortRec);
  RegisterIoRec(TModemRec_v3040, ridModemRec_v3040);
  RegisterIoRec(TModemRec, ridModemRec);
  RegisterIoRec(TRestrictionRec_v3050, ridRR_v3050);
  RegisterIoRec(TRestrictionRec, ridRestrictRec);
  RegisterIoRec(TRestrictionData, ridRestrictData);

  RegisterIoRec(THistoryColl, ridHistoryColl);
  RegisterIoRec(THistoryItem, ridHistoryItem);
  RegisterIoRec(THistoryID, ridHistoryID);

  RegisterIoRec(TPasswordRec, ridPasswordRec);
  RegisterIoRec(TPerPollRec, ridPerPollRec);
  RegisterIoRec(TPasswordColl_v120, ridPasswordColl_v120);
  RegisterIoRec(TPasswordColl, ridPasswordColl);
  RegisterIoRec(TFidoAddrColl, ridFidoAddrColl);
  RegisterIoRec(TPerPollColl, ridPerPollColl);

  RegisterIoRec(TEncryptedNodeData, ridEncryptedNode);
  RegisterIoRec(TFileBoxCfg, ridFileBoxCfg);

  RegisterIoRec(TNodeOvr, ridNodeOvr);
  RegisterIoRec(TDialupNodeOvrColl_v130, ridDupNodeOvrC_v130);
  RegisterIoRec(TDialupNodeOvrColl, ridDupNodeOvrC);

  RegisterIoRec(TIPNodeOvrColl_v135, ridIPNodeOvrColl_v135);
  RegisterIoRec(TIPNodeOvrColl, ridIPNodeOvrColl);

  RegisterIoRec(TFreqData, ridFreqData);
  RegisterIoRec(TIPRec, ridIPRec);
  RegisterIoRec(TIPRec_v3074, ridIPRec_v3074);
  RegisterIoRec(TIPRec_v3075, ridIPRec_v3075);

  RegisterIoRec(TStartupRec, ridStartupRec);

  RegisterIoRec(TExtCollA, ridExtCollA);
  RegisterIoRec(TExtCollB, ridExtCollB);
  RegisterIoRec(TDrsCollA, ridDrsCollA);
  RegisterIoRec(TDrsCollB, ridDrsCollB);
  RegisterIoRec(TCrnCollA, ridCrnCollA);
  RegisterIoRec(TCrnCollB, ridCrnCollB);
  RegisterIoRec(TPerPollsCollA_3240, ridPerPollsCollA_v3240);
  RegisterIoRec(TPerPollsCollB_3250, ridPerPollsCollB_v3250);
  RegisterIoRec(TIpDomCollA, ridIpDomCollA);
  RegisterIoRec(TIpDomCollB, ridIpDomCollB);

  RegisterIoRec(TIpAkaCollA, ridIpAkaCollA);
  RegisterIoRec(TIpAkaCollB, ridIpAkaCollB);

  RegisterIoRec(TEventColl, ridEventColl);

  RegisterIoRec(TEventContainer, ridEvtContainer);
  RegisterIoRec(TEventContainer_v3310, ridEvtContainer_v3310);
  RegisterIoRec(TEvParVoid, ridEvParVoid);
  RegisterIoRec(TEvParString, ridEvParString);
  RegisterIoRec(TEvParDStr, ridEvParDStr);
  RegisterIoRec(TevParDMemo, ridEvParDMemo);
  RegisterIoRec(TIpEvtIds, ridIpEvtIds);
  RegisterIoRec(TEvParUV, ridEvParUV);
  RegisterIoRec(TEvParGrid, ridEvParGrid);

  RegisterIoRec(TECBEncryptedCfgBlock, ridECBEncCfgBlock);
  RegisterIoRec(TCBCEncryptedCfgBlock, ridCBCEncCfgBlock);

  RegisterIoRec(TProxyData, ridProxyData);
  RegisterIoRec(TInstallRec, ridInstallRec);

  Cfg := TCfgContainer.Create;

end;

procedure LoadConfig;
var
  s: TxMemoryStream;
  d: TDosStream;
  p: Pointer;
  sz: Integer;
begin
  d := OpenRead(ConfigFName);
  if d = nil then
  begin
    if not AcceptLicence then Halt;
    StartupWizzard;
  end else
  begin
    s := GetMemoryStream;
    sz := d.Size;
    GetMem(p, sz);
    d.Read(p^, sz);
    s.Write(p^,sz);
    s.Position := 0;
    FreeMem(p, sz);
    FreeObject(d);
    if not Cfg.DoLoad(s) then GlobalFail('%s', ['Failed to load config']);
    FreeObject(s);
  end;
  Cfg.Refill;

  UpdateGlobalEvtUpdateFlag;
end;

function StoreConfig(Handle: DWORD): Boolean;
var
  s: TxMemoryStream;
begin
  StoreConfigAfter := False;
  repeat
    s := GetMemoryStream;
    Cfg.DoStore(s);
    Result := s.SaveToFile(ConfigFName);
    FreeObject(s);
    if Result then Break else
    begin
      if WinDlgCap(GetErrorMsg, MB_RETRYCANCEL or MB_ICONERROR, Handle, LngStr(rsRecsCntWrtCfg)) = idCancel then Break;
    end;
  until False;
end;

const
  iccSOF       = 1;
  iccEOF       = 2;
  iccMainFormL = 10;
  iccMainFormT = 11;
  iccMainFormW = 12;
  iccMainFormH = 13;
  iccThreadsFormL = 14;
  iccThreadsFormT = 15;
  iccThreadsFormW = 16;
  iccThreadsFormH = 17;

procedure LoadIntegers;
var
  s: TxStream;
  i: Integer;
begin
  s := OpenRead(MakeNormName(HomeDir, IntegersFName));
  if s = nil then Exit;
  if s.ReadDword <> iccSOF then Exit;
  while s.Position < s.Size do
  begin
    i := s.ReadInteger;
    case s.ReadDword of
      iccEOF :
        Break;
      iccMainFormL:
        icvMainFormL := i;
      iccMainFormT:
        icvMainFormT := i;
      iccMainFormW:
        icvMainFormW := i;
      iccMainFormH:
        icvMainFormH := i;
      iccThreadsFormL:
        icvThreadsFormL := i;
      iccThreadsFormT:
        icvThreadsFormT := i;
      iccThreadsFormW:
        icvThreadsFormW := i;
      iccThreadsFormH:
        icvThreadsFormH := i;
     end;
  end;
  FreeObject(s);
end;

procedure StoreIntegers;
var
  s: TDosStream;

procedure WD(a: Integer; b: DWORD);
begin
  S.WriteInteger(a); S.WriteDword(b);
end;

begin
  s := OpenWrite(MakeNormName(HomeDir, IntegersFName));
  if s = nil then Exit;
  SetEndOfFile(s.Handle);
  s.WriteDWORD(iccSOF);
  WD(icvMainFormL, iccMainFormL);
  WD(icvMainFormT, iccMainFormT);
  WD(icvMainFormW, iccMainFormW);
  WD(icvMainFormH, iccMainFormH);
  WD(icvThreadsFormL, iccThreadsFormL);
  WD(icvThreadsFormT, iccThreadsFormT);
  WD(icvThreadsFormW, iccThreadsFormW);
  WD(icvThreadsFormH, iccThreadsFormH);
  WD(iccEOF, iccEOF);
  FreeObject(s);
end;

{ TTerminator }

constructor TTerminator.Load(Stream: TxStream);
begin
  Stream.GotTerminator := True;
  Stream.FreeLastLoaded := True;
end;

procedure TTerminator.Store(Stream: TxStream); begin end;
destructor TTerminator.Destroy; begin inherited Destroy end;

{ TStarter }

constructor TStarter.Load(Stream: TxStream);
begin
  Stream.GotStarter := True;
  Stream.FreeLastLoaded := True;
end;

procedure TStarter.Store(Stream: TxStream); begin end;
destructor TStarter.Destroy; begin inherited Destroy end;

function DoReadAppMode: Integer;
var
  Key: HKey;
begin
  Result := -1;
  Key := OpenRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  Result := ReadRegInt(Key, rvnAppMode);
  RegCloseKey(Key);
end;

function ReadAppMode: Integer;
begin
  Result := DoReadAppMode;
  if Result = -1 then Result := 0;
end;

function WriteAppMode(AMode: Integer): Boolean;
var
  Key: HKey;
begin
  Result := False;
  Key := CreateRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  if not WriteRegInt(Key, rvnAppMode, AMode) then Exit;
  RegCloseKey(Key);
  Result := True;
end;

function SetRegHomeDir(const S: string): Boolean;
var
  Key: HKey;
begin
  Result := False;
  Key := CreateRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  if not WriteRegString(Key, rvnHomePath, S) then Exit;
  RegCloseKey(Key);
  Result := True;
end;

function SetRegBoolean(const AKey: string; AValue: Boolean): Boolean;
var
  Key: HKey;
begin
  Result := False;
  Key := CreateRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  if not WriteRegInt(Key, AKey, Integer(AValue)) then Exit;
  RegCloseKey(Key);
  Result := True;
end;


function GetRegHomeDir: string;
var
  Key: HKEY;
begin
  Result := '';
  Key := OpenRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  Result := ReadRegString(Key, rvnHomePath);
  RegCloseKey(Key);
end;

function GetRegStringDef(const AKeyName, ADefault: string): string;
var
  Key: HKEY;
begin
  Result := '';
  Key := OpenRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  Result := ReadRegString(Key, AKeyName);
  RegCloseKey(Key);
  if Result = '' then Result := ADefault;
end;


function GetRegIntegerDef(const AKeyName: string; ADefault: Integer): Integer;
var
  Key: HKEY;
begin
  Result := -1;
  Key := OpenRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  Result := ReadRegInt(Key, AKeyName);
  RegCloseKey(Key);
  if Result = -1 then Result := ADefault;
end;

function GetRegBooleanDef(const AKeyName: string; ADefault: Boolean): Boolean;
begin
  Result := Boolean(GetRegIntegerDef(AKeyName, Integer(ADefault)));
end;

function SetRegHelpLng(const S: string): Boolean;
var
  Key: HKey;
begin
  Result := False;
  Key := CreateRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  if not WriteRegString(Key, rvnHelpLng, S) then Exit;
  RegCloseKey(Key);
  Result := True;
end;

function GetRegHelpLng: string;
var
  Key: HKey;
begin
  Result := '';
  Key := OpenRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  Result := ReadRegString(Key, rvnHelpLng);
  RegCloseKey(Key);
end;


function SetRegInterfaceLng(I: Integer): Boolean;
var
  Key: HKey;
begin
  Result := False;
  Key := CreateRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  if not WriteRegInt(Key, rvnInterfaceLng, I) then Exit;
  RegCloseKey(Key);
  Result := True;
end;

function GetRegInterfaceLng: Integer;
var
  Key: DWORD;
  I: Integer;
begin
  Result := idlEnglish;
  Key := OpenRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  I := ReadRegInt(Key, rvnInterfaceLng);
  RegCloseKey(Key);
  case I of
{$IFDEF LNG_SPANISH}     idlSpanish, {$ENDIF}
{$IFDEF LNG_RUSSIAN}     idlRussian, {$ENDIF}
{$IFDEF LNG_DUTCH}       idlDutch,   {$ENDIF}
{$IFDEF LNG_GERMAN}      idlGerman,  {$ENDIF}
{$IFDEF LNG_DANISH}      idlDanish,  {$ENDIF}
    idlEnglish : Result := I;
  end;
end;



function SetRegBin(const rvn: string; Bin: Pointer; Sz: Integer): Boolean;
var
  Key: HKey;
begin
  Result := False;
  Key := CreateRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  Result := WriteRegBin(Key, rvn, Bin, Sz);
  RegCloseKey(Key);
end;

function GetRegBin(const rvn: string; Bin: Pointer; Sz: Integer): Boolean;
var
  Key: HKEY;
begin
  Result := False;
  Key := OpenRegKey(RegistryFName);
  if Key = INVALID_HANDLE_VALUE then Exit;
  Result := ReadRegBin(Key, rvn, Bin, Sz);
  RegCloseKey(Key);
end;


function FullPath(const Dir: string): string;
begin
  Result := MakeFullDir(HomeDir, Dir);
end;


constructor TNamed.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  FName := Stream.ReadStr;
end;

procedure TNamed.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(FName);
end;

function TNamed.Name: string;
begin
  Result := FName;
end;

constructor TPortRec.Create;
begin
  inherited Create;
end;


procedure TPortRec.SetDefault;
begin
  with d do
  begin
    Port   := 0; {Com1}
    BPS    := DefBPS;
    Hflow  := True;
    Sflow  := False;
    Data   := 8;
    Parity := NOPARITY;
    Stop   := ONESTOPBIT;
  end;
end;

function TPortRec.FlowStr;
begin
  Result := '';
  if d.hFlow then Result := 'CTS/RTS';
  if d.sFlow then
  begin
    if Result <> '' then Result := Result + ', ';
    Result := Result + 'xOn/xOff';
  end;                                        
end;

function TPortRec.Name: string;
begin
  Result := Format('COM%d, %d, %s, %s', [d.Port+1, d.BPS, FlowStr, GetLineBits(d.Data, d.Parity, d.Stop)]);
end;

constructor TPortRec.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Stream.Read(d, SizeOf(d));
end;

procedure TPortRec.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.Write(d, SizeOf(d));
end;

function TPortRec.Copy;
var
  r: TPortRec;
begin
  r := TPortRec.Create;
  r.id := id;
  r.d := d;
  Result := r;
end;

function TElementColl.Copy;
var
  r: TElementColl;
begin
  r := TElementColl.Create;
  AppendTo(r);
  Result := r;
end;

procedure TElementColl.AppendTo(AColl: TElementColl);
begin
  CopyItemsTo(AColl);
  AColl.DefaultId := DefaultId;
end;

procedure TModemRec.SetDefault;
const
  DialPrefixes: array[Boolean] of string = ('ATDP', 'ATDT');
var
  ToneDial: Boolean;
begin
  FName := LngStr(rsNewModem);
  StdResp.Fill(['RING RING_1 RING_2 RING_3 RING_4','CONNECT','OK','BUSY', 'NO_CARRIER NO_ANSWER', 'NO_DIAL_TONE NO_DIALTONE', 'ERROR', 'VOICE', 'RINGING']);
  if StartWizDialProps <> nil then ToneDial := StartWizDialProps.ToneDial else ToneDial := False;
  Cmds.Fill(['^`ATZ|','ATA!',DialPrefixes[ToneDial],'!','!`v~~^`!!`','']);
  Options := [moSwitchDTE];
end;

constructor TModemRec_v3040.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  StdResp := Stream.Get;
  Cmds := Stream.Get;
  if Cmds.Count = 7 then
  begin
    FaxApp := Cmds[6];
    Cmds.AtFree(6);
  end;
  FlagsA := Stream.Get;
  FlagsB := Stream.Get;
end;

function TModemRec_v3040.Upgrade;
var
  r: TModemRec;
begin
  r := TModemRec.Create;
  r.Id := Id;
  r.FName := FName;
  XChg(Integer(r.StdResp), Integer(StdResp));
  XChg(Integer(r.Cmds), Integer(Cmds));
  r.FaxApp := FaxApp;
  r.Options := [moSwitchDTE];
  if Trim(FaxApp) <> '' then Include(r.Options, moUseExternal);
  XChg(Integer(r.FlagsA), Integer(FlagsA));
  XChg(Integer(r.FlagsB), Integer(FlagsB));
  Cfg.AddUpgStringLng(rsRecsFaxInt);
  Result := r;
end;


constructor TModemRec.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  StdResp := Stream.Get;
  Cmds := Stream.Get;
  FaxApp := Stream.ReadStr;
  Stream.Read(Options, SizeOf(Options));
  FlagsA := Stream.Get;
  FlagsB := Stream.Get;
end;


procedure TModemRec.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.Put(StdResp);
  Stream.Put(Cmds);
  Stream.WriteStr(FaxApp);
  Stream.Write(Options, SizeOf(Options));
  Stream.Put(FlagsA);
  Stream.Put(FlagsB);
end;

function TModemRec.Copy;
var
  r: TModemRec;
begin
  r := TModemRec.Create;
  r.id := id;
  r.FName := StrAsg(FName);
  r.FaxApp := StrAsg(FaxApp);
  r.Options := Options;
  StdResp.AppendTo(r.StdResp);
  Cmds.AppendTo(r.Cmds);
  FlagsA.AppendTo(r.FlagsA);
  FlagsB.AppendTo(r.FlagsB);
  Result := r;
end;

constructor TModemRec.Create;
begin
  inherited Create;
  StdResp := TModemStdResp.Create;
  Cmds := TModemCmdsColl.Create;
  FlagsA := TStringColl.Create;
  FlagsB := TStringColl.Create;
end;

destructor TModemRec.Destroy;
begin
  FreeObject(StdResp);
  FreeObject(Cmds);
  FreeObject(FlagsA);
  FreeObject(FlagsB);
  inherited Destroy;
end;

destructor TModemRec_v3040.Destroy;
begin
  FreeObject(StdResp);
  FreeObject(Cmds);
  FreeObject(FlagsA);
  FreeObject(FlagsB);
  inherited Destroy;
end;

procedure TLineRec.SetDefault;
begin
  FName := LngStr(rsNewLine);
  with d do
  begin
    StationId := 0; // Default station
    PortId    := 0; // Default port
    ModemId   := 0; // Default modem
    RestrictId:= 0; // Default restrictions
    Options := [];
  end;
  LogFName := 'NEW_LINE.LOG';
  FaxIn    := 'INFAX';
end;

constructor TLineRec.Create;
begin
  inherited Create;
end;

destructor TLineRec.Destroy;
begin
  if EvtIds <> nil then FreeMem(EvtIds, EvtCnt*SizeOf(Integer));
  inherited Destroy;
end;

procedure LoadEvts(Stream: TxStream; var EvtCnt: DWORD; var EvtIds: Pointer);
begin
  EvtCnt := Stream.ReadDWORD;
  if EvtCnt > 0 then
  begin
    GetMem(EvtIds, EvtCnt*SizeOf(Integer));
    Stream.Read(EvtIds^, EvtCnt*SizeOf(Integer));
  end;
end;

procedure TLineRec_v3011.SetDefault;
begin
  GlobalFail('%s', ['TLineRec_v3011.SetDefault'])
end;

function TLineRec_v3011.Copy: Pointer;
begin
  Result := nil;
  GlobalFail('%s', ['TLineRec_v3011.Copy'])
end;


constructor TLineRec_v3011.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Stream.Read(d, SizeOf(d));
  LogFName := Stream.ReadStr;
  LoadEvts(Stream, EvtCnt, EvtIds)
end;

constructor TLineRec.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Stream.Read(d, SizeOf(d));
  LogFName := Stream.ReadStr;
  FaxIn := Stream.ReadStr;
  LoadEvts(Stream, EvtCnt, EvtIds)
end;


procedure TLineRec.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.Write(d, SizeOf(d));
  Stream.WriteStr(LogFName);
  Stream.WriteStr(FaxIn);
  Stream.WriteDword(EvtCnt);
  if EvtCnt > 0 then
  begin
    Stream.Write(EvtIds^, EvtCnt*SizeOf(Integer));
  end;
end;

function TLineRec.Copy;
var
  r: TLineRec;
begin
  r := TLineRec.Create;
  r.id := id;
  r.FName := StrAsg(FName);
  r.LogFName := StrAsg(LogFName);
  r.FaxIn := StrAsg(FaxIn);
  r.d := d;
  r.EvtCnt := EvtCnt;
  GetMem(r.EvtIds, EvtCnt*SizeOf(Integer));
  Move(EvtIds^, r.EvtIds^, EvtCnt*SizeOf(Integer));
  Result := r;
end;


constructor TLineRec_v3010.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Stream.Read(d, SizeOf(d));
  LogFName := Stream.ReadStr;
end;

function TLineRec_v3010.Upgrade: TLineRec_v3011;
begin
  Result := TLineRec_v3011.Create;
  Result.Id := Id;
  Result.FName := FName;
  Result.d := d;
  Result.LogFName := LogFName;
  Cfg.AddUpgStringLng(rsRecsDupEvt);
end;

function TLineRec_v3011.Upgrade: TLineRec;
begin
  Result := TLineRec.Create;
  Result.Id := Id;
  Result.FName := FName;
  Result.d := d;
  Result.LogFName := LogFName;
  XChg(Integer(Result.EvtIds), Integer(EvtIds));
  XChg(Integer(Result.EvtCnt), Integer(EvtCnt));
  Result.FaxIn := cFaxInbound;
  Cfg.AddUpgStringLng(rsRecsFaxIn);
end;


procedure TStationRec.SetDefault;
begin
  FName := LngStr(rsNewStation);
end;



constructor TStationRec.Create;
begin
  inherited Create;
  Data := TStationDataColl.Create;
  AkaA := TStringColl.Create;
  AkaB := TStringColl.Create;
end;

destructor TStationRec.Destroy;
begin
  FreeObject(Data);
  FreeObject(AkaA);
  FreeObject(AkaB);
  inherited Destroy;
end;

constructor TStationRec.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Data := Stream.Get;
  if Data.Count <> 6 then GlobalFail('TStationRec.Load Data.Count=%d', [Data.Count]);
  Banner := Stream.ReadStr;
  AkaA := Stream.Get;
  AkaB := Stream.Get;
end;

procedure TStationRec.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.Put(Data);
  Stream.WriteStr(Banner);
  Stream.Put(AkaA);
  Stream.Put(AkaB);
end;

function TStationRec.Copy;
var
  r: TStationRec;
begin
  r := TStationRec.Create;
  r.id := id;
  r.Banner := StrAsg(Banner);
  r.FName := StrAsg(FName);
  Data.AppendTo(r.Data);
  AkaA.AppendTo(r.AkaA);
  AkaB.AppendTo(r.AkaB);
  Result := r;
end;

constructor TStationRec_v3020.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Data := Stream.Get;
  if Data.Count = 7 then Data.AtFree(6);
end;

function CreateDefaultStation(Id: Integer; const FName, Banner: string): TStationRec;
begin
  Result := TStationRec.Create;
  Result.Id := Id;
  Result.FName := FName;
  Result.Banner := Banner;
end;

function TStationRec_v3020.Upgrade: TStationRec;
begin
  Result := CreateDefaultStation(Id, FName, Format('Welcome to %s'#13#10#13#10'Processing mail only - please hangup', [Data.Station]));
  XChg(Integer(Result.Data), Integer(Data));
  FreeObject(Data);
  Cfg.AddUpgStringLng(rsRecsDSB);
end;


constructor TStationRec_v3021.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Data := Stream.Get;
  if Data.Count = 7 then GlobalFail('TStationRec_v3021.Load Data.Count = %d', [Data.Count = 7]);
  Banner := Stream.ReadStr;
end;

function TStationRec_v3021.Upgrade: TStationRec;
begin
  Result := CreateDefaultStation(Id, FName, Banner);
  XChg(Integer(Result.Data), Integer(Data));
  FreeObject(Data);
  Cfg.AddUpgStringLng(rsRecsDSB);
end;


constructor TRestrictionRec.Create;
begin
  inherited Create;
  Data := TRestrictionData.Create;
end;

destructor TRestrictionRec.Destroy;
begin
  FreeObject(Data);
  inherited Destroy;
end;


procedure TRestrictionRec.SetDefault;
begin
  FName := LngStr(rsNewRestriction); 
end;


constructor TRestrictionRec.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Data := Stream.Get;
end;

procedure TRestrictionRec.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.Put(Data);
end;

function TRestrictionRec.Copy;
var
  r: TRestrictionRec;
begin
  r := TRestrictionRec.Create;
  r.id := id;
  r.FName := StrAsg(FName);
  Data.Required.CopyItemsTo(r.Data.Required);
  Data.Forbidden.CopyItemsTo(r.Data.Forbidden);
  Result := r;
end;

function GetLineBits(D, P, S: Byte): string;
const
  StopBits    : array[0..2] of string = ('1', '1.5', '2');
  Parity      : array[0..4] of char = 'NOEMS';
begin
  Result := Format('%d%s%s', [D, Parity[P], StopBits[S]]);
end;

procedure TElementColl.InvalidateID;
var
  i: Integer;
begin
  for i := 0 to Count-1 do with TElement(At(i)) do if Id = -1 then id := GetUnusedId;
  if (DefaultId = -1) or (GetDefaultIdx = -1) then SetDefaultIdx(0);
end;

procedure TElementColl.SetDefaultRec(ARec: TElement);
begin
  DefaultId := ARec.Id;
end;

procedure TElementColl.SetDefaultIdx(AIdx: Integer);
begin
  DefaultId := TElement(At(AIdx)).Id;
end;

function TElementColl.GetDefaultIdx: Integer;
begin
  Result := GetIdxById(DefaultId);
end;

function TElementColl.GetDefaultRec: TElement;
begin
  Result := GetRecById(DefaultId);
end;

function TElementColl.GetRecById;
begin
  Result := At(GetIdxById(AId));
end;

function TElementColl.GetIdxById(AId: Integer): Integer;
begin
  if AId = 0 then AId := DefaultId;
  Result := FindNo(AId, Self);
  if Result = -1 then Result := FindNo(DefaultId, Self);
end;

function TElementColl.GetUnusedId: Integer;
begin
  Result := GetFreeNo([Self]);
end;

function  GetFreeNo;

function Chk(A: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to High(L)-1 do
  begin
    if FindNo(A, L[I]) <> -1 then Exit;
  end;
  Result := True;
end;

begin
  repeat
    Result := GetTickCount;
  until Chk(Result);
end;

function FindNo;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to L.Count-1 do if TElement(L[I]).Id = N then
  begin
    Result := I;
    Exit;
  end;
end;

function TElementColl.GetIdCombo(cb: TComboBox): Integer;
var
  i: Integer;
begin
  i := cb.ItemIndex;
  if i = 0 then Result := 0 else Result := TElement(At(i-1)).Id;
end;


procedure TElementColl.FillCombo;
var
  i,ii: Integer;
  e: TElement;
begin
  cb.Items.Clear;
  cb.Items.Add(FormatLng(LngId, [DefaultRec.Name]));
  ii := 0;
  for i := 0 to Count-1 do
  begin
    e := At(i);
    cb.Items.Add(e.Name);
    if e.Id = Id then ii := i+1;
  end;
  cb.ItemIndex := ii;
end;

function TMainCfgColl.GetElement(Idx: Integer): TElementColl;
begin
  Result := At(Idx);
end;

constructor TElementColl.Create;
begin
  inherited Create;
  DefaultId := -1;
end;

constructor TElementColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  DefaultId := Stream.ReadInteger;
end;

procedure TElementColl.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteInteger(DefaultId);
end;

constructor TElementOnly.Load(Stream: TxStream); begin GlobalFail('%s', ['TElementOnly.Load']) end;
procedure TElementOnly.Store(Stream: TxStream); begin GlobalFail('%s', ['TElementOnly.Store']) end;
function TElementOnly.Copy: Pointer; begin GlobalFail('%s', ['TElementOnly.Copy']); Result := nil end;
procedure TElementOnly.SetDefault; begin GlobalFail('%s', ['TElementOnly.SetDefault']); end;
function TElementOnly.Name: string; begin GlobalFail('%s', ['TElementOnly.Name']); end;


constructor TElement.Create;
begin
  inherited Create;
end;

constructor TElement.Load(Stream: TxStream);
begin
  Id := Stream.ReadInteger;
end;

procedure TElement.Store(Stream: TxStream);
begin
  Stream.WriteInteger(Id);
end;

procedure LoadHistory;
var
  s: TxStream;
begin
  FreeObject(HistoryColl);
  s := OpenRead(MakeNormName(HomeDir, HisFName));
  if s = nil then Exit;
  HistoryColl := S.Get;
  FreeObject(s);
end;

procedure StoreHistory;
var
  s: TDosStream;
begin
  if HistoryColl = nil then Exit;
  s := OpenWrite(MakeNormName(HomeDir, HisFName));
  if s = nil then Exit;
  SetEndOfFile(s.Handle);
  s.Put(HistoryColl);
  FreeObject(HistoryColl);
  FreeObject(s);
end;

function ComName(I: Integer): string;
begin
  Result := Format('COM%d', [I+1]);
end;

function dLog: string;
begin
  CfgEnter;
  Result := StrAsg(FullPath(Cfg.Pathnames.Log));
  CfgLeave;
end;

function dOutbound: string;
begin
  CfgEnter;
  Result := StrAsg(FullPath(Cfg.Pathnames.Outbound));
  CfgLeave;
end;

function NDLPath: String;
begin
  Result := MakeNormName(HomeDir, 'nodelist.bin');
end;

constructor TAddrListRec.Load(Stream: TxStream);
begin
  AddrList := Stream.Get;
end;

procedure TAddrListRec.Store(Stream: TxStream);
begin
  Stream.Put(AddrList);
end;

constructor TAddrListRec.Create;
begin
  inherited Create;
  AddrList := TFidoAddrColl.Create;
end;

destructor TAddrListRec.Destroy;
begin
  FreeObject(AddrList);
  inherited Destroy;
end;

function TAddrListRecNCP.Copy: Pointer;
begin
  Result := nil;
  GlobalFail('%s.Copy - not implemented', [ClassName]);
end;

constructor TPasswordRec.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  PswStr := Stream.ReadStr;
end;

procedure TPasswordRec.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(PswStr);
end;

function TPerPollRec.Copy: Pointer;
var
  r: TPerPollRec;
  i: Integer;
begin
  r := TPerPollRec.Create;
  for i := 0 to AddrList.Count-1 do r.AddrList.Add(AddrList[i]);
  r.Cron := StrAsg(Cron);
  Result := r;
end;

destructor TPerPollRec.Destroy;
begin
  FreeObject(CronRec);
  inherited Destroy;
end;


constructor TPerPollRec.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cron := Stream.ReadStr;
end;

procedure TPerPollRec.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(Cron);
end;

function TDialupNodeOvrColl_v130.Upgrade: TDialupNodeOvrColl;
var
  r: TDialupNodeOvrColl;
begin
  r := TDialupNodeOvrColl.Create;
  r.Concat(Self);
  Cfg.AddUpgStringLng(rsRecsAuxDupOvr);
  Result := r;
end;

constructor TDialupNodeOvrColl_v130.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.DialupNodeOverrides, Upgrade);
  Stream.FreeLastLoaded := True;
end;

function TIPNodeOvrColl_v135.Upgrade: TIpNodeOvrColl;
var
  r: TIpNodeOvrColl;
begin
  r := TIpNodeOvrColl.Create;
  r.Concat(Self);
  Cfg.AddUpgStringLng(rsRecsAuxIpOvr);
  Result := r;
end;

constructor TIPNodeOvrColl_v135.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.IpNodeOverrides, Upgrade);
  Stream.FreeLastLoaded := True;
end;

function TPasswordColl.Crc32(Init: DWORD): DWORD;
begin
  Result := inherited Crc32(Init);
  Result := Crc32Str(AuxFile, Result);
end;

function TAbsNodeOvrColl.Crc32(Init: DWORD): DWORD;
begin
  Result := inherited Crc32(Init);
  Result := Crc32Str(AuxFile, Result);
end;

function TAbsNodeOvrColl.Crc32Item(Item: Pointer; Crc32: DWORD): DWORD;
begin
  with TNodeOvr(Item) do
  begin
    Result := Crc32Str(Ovr, Crc32Block(Addr, SizeOf(Addr), Crc32));
  end;
end;

constructor TAbsNodeOvrColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  AuxFile := Stream.ReadStr;
end;

procedure TAbsNodeOvrColl.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(AuxFile);
end;

function TPasswordColl_v120.Upgrade: TPasswordColl;
var
  r: TPasswordColl;
begin
  r := TPasswordColl.Create;
  r.Concat(Self);
  Cfg.AddUpgStringLng(rsRecsAuxPwd);
  Result := r;
end;

constructor TPasswordColl_v120.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.Passwords, Upgrade);
  Stream.FreeLastLoaded := True;
end;

constructor TPerPollColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.PerPolls, Self);
end;

function TPerPollColl.Crc32Item(Item: Pointer; Crc32: DWORD): DWORD;
begin
  with TPerPollRec(Item) do
  begin
    Result := Crc32Str(Cron, AddrList.Crc32(Crc32));
  end;
end;

function TPasswordColl.Crc32Item(Item: Pointer; Crc32: DWORD): DWORD;
begin
  with TPasswordRec(Item) do
  begin
    Result := Crc32Str(PswStr, AddrList.Crc32(Crc32));
  end;
end;

function TExtPollColl.Crc32Item(Item: Pointer; Crc32: DWORD): DWORD;
begin
  with TExtPoll(Item) do
  begin
    Result := Crc32Str(FAddrs,
              Crc32Str(FOpts,
              Crc32Str(FCmd, Crc32)));
  end;
end;

constructor TExtPollColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.ExtPolls, Self);
end;

constructor TPasswordColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  AuxFile := Stream.ReadStr;
  Cfg.SetObj(@Cfg.Passwords, Self);
end;

procedure TPasswordColl.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(AuxFile);
end;

function TPasswordColl.Password(Addr: TFidoAddress): string;
var
  i, j: Integer;
  p: TPasswordRec;
begin
  Result := '';
  for i := 0 to Count-1 do
  begin
    p := At(i);
    for j := 0 to p.AddrList.Count-1 do if CompareAddrs(p.AddrList[j],Addr)=0 then
    begin
      Result := p.PswStr;
      Exit;
    end;
  end;
end;

{ --- BadWaZOO }

procedure TBWZColl.Update;
begin
  if not InternalUpdate then GlobalFail('TBWZColl.Update %s', [GetErrorMsg]);
end;


function TBWZColl.NIdx;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count-1 do if TBWZRec(At(i)).BWZNo = N then
  begin
    Result := i;
    Exit;
  end;
end;

procedure OpenBWZFile(const s: string; var FHandle: THandle; var DoReadFile: Boolean; FirstRun: Boolean);
var
  Err: DWORD;
begin
  DoReadFile := False;
  if FirstRun then FHandle := _CreateFile(s, [cRead, cWrite, cExisting, cWriteThrough])
              else FHandle := _CreateFile(s, [cWrite, cExisting, cWriteThrough]);
  if FHandle = INVALID_HANDLE_VALUE then
  begin
    Err := GetLastError;
    FHandle := _CreateFile(s, [cWrite, cEnsureNew, cWriteThrough]);
    if FHandle = INVALID_HANDLE_VALUE then
    begin
      if FirstRun then DisplayError(FormatLng(rsRecsCantAcc, [s])+#13#10#13#10+SysErrorMessage(Err), 0);
      GlobalFail('OpenBWZLog (%s) Error %d (%s)', [s, Err, SysErrorMessage(Err)]);
    end;
  end else
  begin
    DoReadFile := True;
  end;
end;


function TBWZColl.InternalUpdate;
var
  i: Integer;
  SLEN, Actually: DWORD;
  s: string;
  r: TBWZRec;
  Dummy: Boolean;
begin
  Result := False;
  s := '; Do not modify this file while Argus is running, your changes may be overwritten'#13#10#13#10;
  for i := 0 to Count-1 do
  begin
    r := At(i);
    s := s + Format('%.3x %s %d %d %d %d %s'#13#10, [r.BWZNo, PackRFC1945(r.FName, ' '), r.FSize, r.FTime, r.TmpSize, r.Prot, Addr2Str(r.Addr)]);
  end;
  if LastS = s then
  begin
    Result := True;
    Exit;
  end;
  LastS := s;
  ClearErrorMsg;
  if BWZColl.FHandle = 0 then OpenBWZFile(FName, FHandle, Dummy, False);
  if SetFilePointer(FHandle, 0, nil, FILE_BEGIN) <> 0 then begin SetErrorMsg(FName); Exit end;
  SLEN := Length(s);
  if SLEN > 0 then
  begin
    SetLastError(0);
    if (not WriteFile(FHandle, s[1], SLEN, Actually, nil)) or (SLen <> Actually) then
    begin
      SetErrorMsg(Format('%s (%d of %d)', [FName, Actually, SLEN]));
      Exit;
    end;
  end;
  if not SetEndOfFile(FHandle) then
  begin
    SetErrorMsg(FName);
    Exit;
  end;
  if not FlushFileBuffers(FHandle) then
  begin
    SetErrorMsg(FName);
    Exit;
  end;
  if CloseBWZFile then ZeroHandle(FHandle);
  Result := True;
end;

destructor TBWZColl.Destroy;
begin
  ZeroHandle(FHandle);
  inherited Destroy;
end;


function OpenBWZLog: Boolean;
const
  MaxBWZAge = 3 * 24 * 60 * 60;
var
  T: TTextReader;
  FName, TmpDir, S, Z, FNM: string;
  R: TBWZRec;
  N: DWORD;
  Nfo: TFileInfo;
  DoReadFile: Boolean;
  FHandle: THandle;
  FStream: TDosStream;
begin
  Result := False;
  CfgEnter;
  TmpDir := StrAsg(FullPath(Cfg.Pathnames.InTemp));
  CfgLeave;
  BWZColl := TBWZColl.Create;
  s := MakeNormName(HomeDir, BWZLogFName);
  OpenBWZFile(s, FHandle, DoReadFile, True);
  BWZColl.FName := s;
  BWZColl.FHandle := FHandle;
  if DoReadFile then
  begin
    FStream := TDosStream.Create(FHandle);
    T := CreateTextReaderByStream(FStream);
    if T = nil then GlobalFail('OpenBWZLog (%s) CreateTextReaderByStream (Error %d ??)', [BWZColl.FName, GetLastError]);
    while not T.Eof do
    begin
      S := T.GetStr;
      BWZColl.LastS := BWZColl.LastS + S + #13#10;
      if S = '' then Continue;
      if S[1] = ';' then Continue;
      GetWrd(S, Z, ' ');
      N := VlH(Z);
      if N = INVALID_VALUE then Continue;
      FName := MakeNormName(TmpDir, Format(BWZFmt, [N]));
      if not GetFileNfo(FName, Nfo, False) then Continue;
      GetWrd(S, Z, ' ');
      FNM := Z;
      if not UnpackRFC1945(FNM) then Continue;
      R := TBWZRec.Create;
      R.BWZNo := N;
      R.FName := FNM;
      GetWrd(S, Z, ' ');
      R.FSize := Vl(Z);
      GetWrd(S, Z, ' ');
      R.FTime := Vl(Z);
      GetWrd(S, Z, ' ');
      R.TmpSize := Vl(Z);
      GetWrd(S, Z, ' ');
      R.Prot := Vl(Z);
      GetWrd(S, Z, ' ');
      ParseAddress(Z, R.Addr);

      if ((R.FSize = INVALID_VALUE) or
         (R.FTime = INVALID_VALUE) or
         (R.TmpSize = INVALID_VALUE) or
         (R.Prot = INVALID_VALUE)) or
      (R.TmpSize <> R.FSize) and (Nfo.Time + MaxBWZAge < uGetSystemTime) then
      begin
        FreeObject(R);
        DeleteFile(FName);
      end else
      begin
        BWZColl.Insert(R);
      end;

    end;
    FreeObject(T);
    FreeObject(FStream);
  end;
  if CloseBWZFile then ZeroHandle(BWZColl.FHandle);
  Result := True;
end;


function GetBWZ;
var
  i: Integer;
  uf: string;
  r: TBWZRec;
  j: Integer;

function Match: Boolean;
begin
  Result := (UpperCase(r.FName) = uf) and (r.FSize = FSize) and (r.FTime = FTime);
end;

begin
  uf := UpperCase(FName);
  r := nil;
  BWZColl.Enter;
  for i := 0 to BWZColl.Count-1 do
  begin
    r := BWZColl.At(i);
    if Match and (CompareAddrs(r.Addr, Addr)=0) then Break else r := nil;
  end;
  if (r = nil) and (CollMax(AddrList) >=0) then
  for i := 0 to BWZColl.Count-1 do
  begin
    r := BWZColl.At(i);
    if Match and (AddrList.Search(@Addr, j)) then Break else r := nil;
  end;
  BWZColl.Leave;
  Result := r;
end;

procedure FreeBWZ(var Rec: TBWZRec);
begin
  BWZColl.Enter;
  BWZColl.Delete(Rec);
  FreeObject(Rec);
  BWZColl.Leave;
end;

destructor TBWZRec.Destroy;
begin
  inherited Destroy;
end;


function MoveFileSmart(const S1: string; var S2: string; ReplaceExisting: Boolean; var Overwritten: Boolean): Boolean;

procedure DoIt;
var
  dr, nm, ex: string;
  TN: string;
  AlreadExists: Boolean;
begin
  Overwritten := False;

  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    Result := MoveFileEx(PChar(S1), PChar(S2), 0);
  end else
  begin
    Result := MoveFile(PChar(S1), PChar(S2));
  end;
  if Result then Exit;
  if not ReplaceExisting then
  begin
    if IncrementArcmail then
    begin
      FSplit(S2, dr, nm, ex);
      if (Length(ex) = 4) and (IsArcmailExt(ex)) then
      begin
        case ex[4] of
          '0'..'8',
          'a'..'y', 'A'..'Y':
            Inc(ex[4]);
          '9':
            ex[4] := 'a';
          else Result := False;
        end;
        S2 := dr+nm+ex;
        Result := MoveFileSmart(S1, S2, ReplaceExisting, Overwritten);
      end;
    end;
    Exit;
  end;
  case GetLastError of
    ERROR_FILE_EXISTS,
    ERROR_ALREADY_EXISTS: AlreadExists := True;
    else AlreadExists := False;
  end;
  if (not AlreadExists) and (FileExists(S1)) and (FileExists(S2)) then AlreadExists := True;
  if AlreadExists then
  begin
    if (Win32Platform = VER_PLATFORM_WIN32_NT) then
    begin
      Result := MoveFileEx(PChar(S1), PChar(S2), MOVEFILE_REPLACE_EXISTING);
      if Result then Overwritten := True;
    end else
    begin
      TN := Format('%s%x.%x', [ExtractFilePath(S2), GetTickCount xor xRandom32, xRandom32 and $FFF]);
      if not MoveFile(PChar(S2), PChar(TN)) then Exit;
      Overwritten := True;
      Result := MoveFile(PChar(S1), PChar(S2));
      if Result then
      begin
        DeleteFile(TN);
      end else
      begin
        MoveFile(PChar(TN), PChar(S2));
      end;
    end;
  end;
end;

begin
  Result := False;
  if (S1 = '') or (S2 = '') then Exit;
  DoIt;
  if not Result then
  begin
    case GetLastError of
      ERROR_FILE_EXISTS,
      ERROR_ALREADY_EXISTS:;
      else
      begin
        SetErrorMsg(Format('%s -> %s', [S1, S2]));
      end;
    end;
  end;
end;

function TBWZRec.Toss;
var
  PutKind: TInboundPutKind;
  SrcFile, DstDir: string;
begin
  Overwritten := False;
  Result := False;
  ClearErrorMsg;
  DstDir := GetInboundDir(Addr, FName, Prot=1, PutKind);
  s := MakeNormName(DstDir, FName);
  if not CreateDirInheritance(DstDir) then Exit;
  SrcFile := GetBWZFname;
  Result := MoveFileSmart(SrcFile, s, PutKind = ipkOverwrite, Overwritten);
  if Result then uSetFileTime(s, FTime);
end;

function TBWZRec.GetBWZFname: string;
begin
  CfgEnter;
  Result := StrAsg(MakeNormName(FullPath(Cfg.Pathnames.InTemp), Format(BWZFmt, [BWZNo])));
  CfgLeave;
end;

function AddBWZ;
var
  i: Integer;
begin
  i := xRandom($100);
  BWZColl.Enter;
  while BWZColl.NIdx(i)<>-1 do Inc(i, xRandom($10));
  Result := TBWZrec.Create;
  Result.FName := StrAsg(FName);
  Result.BWZNo := i;
  Result.FSize := FSize;
  Result.FTime := FTime;
  Result.Prot  := Prot;
  Result.Addr  := Addr;
  BWZColl.Insert(Result);
  BWZColl.Leave;
end;

procedure CloseBWZLog;
begin
  BWZColl.Update;
  FreeObject(BWZColl);
end;

type
  TFreqScanner = class
    CurPsw: string;
    SR: TuFindData;
    B: Boolean;
    FName: string;
    FixedColl: TColl;
    MaskedColl: TColl;
    I: Integer;
    FreqData: TFreqData;
    procedure ScanDir(Dir: string; ARecursive: Boolean);
    procedure SearchEntry;
    procedure SearchAliases(Coll: TColl);
  end;

procedure TFreqScanner.SearchEntry;
var
  i: Integer;
  s: string;
  r: TReqRec;
begin
  s := UpperCase(SR.FName);
  for i := 0 to FixedColl.Count-1 do
  begin
    r := FixedColl.At(i);
    if s = UpperCase(r.S) then r.Add(FName, CurPsw, SR.Info);
  end;
  for i := 0 to MaskedColl.Count-1 do
  begin
    r := MaskedColl.At(i);
    if _MatchMask(s, r.S, True) then r.Add(FName, CurPsw, SR.Info);
  end;
end;

procedure TFreqScanner.ScanDir;
var
  Handle: DWORD;
begin
  B := uFindFirst(MakeNormName(Dir, '*.*'), SR); if not B then Exit;
  while B do
  begin
    if SR.Info.Attr and FILE_ATTRIBUTE_HIDDEN = 0 then
    begin
      FName := MakeNormName(Dir, SR.FName);
      if SR.Info.Attr and FILE_ATTRIBUTE_DIRECTORY <> 0 then
      begin
        if ARecursive then
        if Copy(SR.FName,1,1)<>'.' then
        begin
          Handle := SR.Handle;
          ScanDir(FName, ARecursive);
          SR.Handle := Handle;
        end;
      end else
      begin
        SearchEntry;
      end;
    end;
    B := uFindNext(SR);
  end;
  uFindClose(SR);
end;

procedure TFreqScanner.SearchAliases(Coll: TColl);
var
  NewestTime,FirstThis: DWord;
  i,j,k: Integer;
  us, s1, s2, s3, z2, z3, z4: string;
  r: TReqRec;
  Match, IsRegEx, IsPercent, B: Boolean;
  SR: TuFindData;
  RunSRP, CalcTime: Boolean;
begin
  if Coll.Count = 0 then Exit;
  for i := 0 to FreqData.alNames.Count-1 do
  begin
    s1 := FreqData.alNames[i]; us := UpperCase(s1);
    s2 := FreqData.alPaths[i];
    s3 := FreqData.alPsw[i];
    for j := Coll.Count-1 downto 0 do
    begin
      r := Coll.At(j);
      if us = UpperCase(r.S) then
      begin
        z2 := s2;
        while z2 <> '' do
        begin
          CalcTime := False;
          RunSRP := False;
          case z2[1] of
            '>': CalcTime := True;
            '=': RunSRP := True;
          end;
          if RunSRP then
          begin
            r.AddSRP(CopyLeft(z2, 2), s3);
            Break;
          end else
          begin
            GetWrd(z2, z3, ' ');
            if CalcTime then
            begin
              DelFC(z3); NewestTime := 0; FirstThis := CollCount(r.Files)
            end else
            begin
              NewestTime := 0; FirstThis := 0; // to avoid 'uninitialized' warning
            end;
            z4 := z3;
            IsPercent := Pos('%', z4) > 0;
            IsRegEx := StrQuotePartEx(ExtractFileName(z4), '~', #3, #4) <> ExtractFileName(z4);
            if IsRegEx then
            begin
              z4 := '*.*';
            end else
            begin
              if IsPercent then Replace('%', '?', z4);
            end;
            B := uFindFirst(z4, SR);
            if B then
            begin
              while B do
              begin
                Match := False;
                if IsRegEx or IsPercent then
                begin
                  Match := _MatchMask(SR.FName, ExtractFileName(z3), True)
                end else
                begin
                  Match := True;
                end;
                if Match then
                begin
                  if SR.Info.Attr and (FILE_ATTRIBUTE_DIRECTORY or FILE_ATTRIBUTE_HIDDEN) = 0 then
                  begin
                    r.Add(ExtractFilePath(z3)+SR.FName, s3, SR.Info);
                    if CalcTime then NewestTime := MaxD(NewestTime, SR.Info.Time);
                  end;
                end;
                B := uFindNext(SR);
              end;
              uFindClose(SR);
            end else
            begin
              SetErrorMsg(z4);
            end;
            if CalcTime then
            begin
              for k := CollMax(r.Files) downto FirstThis do
              begin
                if TReqFile(r.Files[k]).Info.Time < NewestTime then r.Files.AtFree(k);
              end;
              if CollMax(r.Files) < 0 then FreeObject(r.Files);
            end;
          end;
        end;
        Coll.AtDelete(j);
      end;
    end;
  end;
end;

procedure ScanREQ(Coll: TColl);
var
  F: TFreqScanner;
  i: Integer;
  r: TReqRec;
begin
  F := TFreqScanner.Create;
  F.FixedColl := TColl.Create;
  F.MaskedColl := TColl.Create;
  if Coll <> nil then
  for i := 0 to Coll.Count-1 do
  begin
    r := Coll[i];
    if r.Typ < rtOK then Continue;
    if IsWild(r.S) then F.MaskedColl.Insert(r) else F.FixedColl.Insert(r);
  end;
  if (F.MaskedColl.Count>0) or (F.FixedColl.Count>0) then
  begin
    CfgEnter;
    F.FreqData := Cfg.FreqData.Copy;
    CfgLeave;
    F.SearchAliases(F.FixedColl);
    F.SearchAliases(F.MaskedColl);
  end;
  if (F.FreqData <> nil) and (not (foMasks in F.FreqData.Options)) then F.MaskedColl.DeleteAll;
  if (F.MaskedColl.Count>0) or (F.FixedColl.Count>0) then
  begin
    for i := 0 to F.FreqData.pnPaths.Count-1 do
    begin
      F.CurPsw := F.FreqData.pnPsw[i];
      F.ScanDir(F.FreqData.pnPaths[i], (foRecursive in F.FreqData.Options));
    end;
  end;
  FreeObject(F.FreqData);
  F.FixedColl.DeleteAll;
  F.MaskedColl.DeleteAll;
  FreeObject(F.FixedColl);
  FreeObject(F.MaskedColl);
  FreeObject(F);
end;


function ParseREQ(var ASC: TStringColl): TColl;
var
  e, i, j: Integer;
  OrgStr,s,w,FName,Psw,Upd: string;
  unk: Boolean;
  r: TReqRec;

procedure ParseErr;
begin
  r.Typ := rtParseError;
  r.S := OrgStr;
end;

begin
  Result := nil;
  for j := 0 to CollMax(ASC) do
  begin
    s := Trim(ASC[j]); if (s = '') or (Length(s) > MAX_PATH*2) then Continue;
    OrgStr := s;
    FName := ''; Psw := ''; Upd := ''; unk := False;
    for i := 0 to 2 do
    begin
      GetWrd(s,w,' '); if w = '' then Break;
      if i = 0 then
      begin
        FName := w;
        if not StrDeQuote(FName) then unk := True;
      end else
      case w[1] of
        '!' : if i = 1 then Psw := w else unk := True;
        '-', '+': if Upd = '' then Upd := w else unk := True;
        else unk := True;
      end;
    end;
    r := TReqRec.Create;
    repeat
      if (unk) or (Length(FName) > MAX_PATH) or (ExtractFileName(FName)<>FName) then ParseErr else
      begin
        if Upd = '' then r.Typ := rtNormal else
        begin
          Val(Upd, i, e);
          if e > 0 then begin ParseErr; Break end;
          if i > 0 then r.Typ := rtNewer else begin i := -i; r.Typ := rtUpTo end;
          r.Upd := i;
        end;
        r.S := FName;
        DelFC(Psw);
        r.Psw := Psw;
      end;
    until True;
    if Result = nil then Result := TColl.Create;
    Result.Insert(r);
  end;
  FreeObject(ASC);
end;

function TFreqData.Copy;
var
  f: TFreqData;
begin
  f := TFreqData.Create;
  CopyItemsTo(f);
  f.Options := Options;
  Result := f;
end;

constructor TFreqData.Load(Stream: TxStream);
var
  c: TStringColl;
begin
  inherited Load(Stream);
  Stream.Read(Options, SizeOf(Options));
  if Count = 5 then
  begin
    c := TStringColl.Create;
    c.Add('');
    Insert(c);
  end;
  Cfg.SetObj(@Cfg.FreqData, Self);
end;

procedure TFreqData.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.Write(Options, SizeOf(Options));
end;

constructor TFreqData.Create;
var
  i: Integer;
  C: TStringColl;
begin
  inherited Create;
  Options := [];
  for i := 0 to 4 do Insert(TStringColl.Create);
  C := TStringColl.Create;
  C.Add('');
  Insert(C);
end;

destructor TFreqData.Destroy;
begin
  inherited Destroy;
end;

function TFreqData.GetSC;
begin
  Result := At(Index);
end;

destructor TReqRec.Destroy;
begin
  FreeObject(SRPs);
  FreeObject(Files);
  inherited Destroy;
end;

procedure TReqRec.AddSRP(const AStr, APsw: string);
begin
  if (APsw <> '') and (APsw <> Psw) then Exit;
  if SRPs = nil then SRPs := TStringColl.Create;
  SRPs.Add(AStr);
end;


procedure TReqRec.Add(const FName, APsw: string; Info: TFileInfo);
var
  r: TReqFile;
begin
  if (APsw <> '') and (APsw <> Psw) then Exit;
  case Typ of
    rtNormal : ;
    rtNewer  : if Info.Time <= Upd then Exit;
    rtUpTo   : if Info.Time >Upd then Exit;
    else GlobalFail('TReqRec.Add("%s","%s",...) unknown Typ', [FName, APsw]);
  end;
  if Files = nil then Files := TColl.Create;
  r := TReqFile.Create;
  r.FName := FName;
  r.Info := Info;
  Files.Add(r);
end;

constructor TNodeOvr.Load(Stream: TxStream);
begin
  _GetAddress(Stream, Addr);
  Ovr := Stream.ReadStr;
end;

procedure TNodeOvr.Store(Stream: TxStream);
begin
  _PutAddress(Stream, Addr);
  Stream.WriteStr(Ovr);
end;

type
  TRestrictItem = class
    Typ: TOvrItemTyp;
    S: string;
    Addr: TFidoAddress;
  end;


function ParseRestrictStr(S: string; ErrItem: PString): TColl;
var
  L: TColl;

function Parsed: Boolean;
var
  Z: string;
  ri: TRestrictItem;
  t: TOvrItemTyp;
begin
  Result := False;
  while S <> '' do
  begin
    GetWrd(S, Z, ' ');
    t := IdentOvrItem(Z, True, True);
    if t = oiUnknown then
    begin
      if ErrItem <> nil then ErrItem^ := Z;
      Exit;
    end;
    ri := TRestrictItem.Create;
    ri.Typ := t;
    case t of
      oiAddress :
        ParseAddress(Z, ri.Addr);
      oiPhoneNum:
        ri.S := WipePhoneNumber(Z);
      else ri.S := Z;
    end;
    L.Insert(ri);
  end;
  Result := True;
end;

begin
  if ErrItem <> nil then ErrItem^ := '';
  L := TColl.Create;
  if (not Parsed) or (L.Count=0) then FreeObject(L);
  Result := L;
end;

function DialAllowed;
var
  FlagColl: TStringColl;

function Matches(S: string; AForb: Boolean): Boolean;
var
  L: TColl;
  ri: TRestrictItem;
  i: Integer;
  b: Boolean;
  es: string;
begin
  L := ParseRestrictStr(S, @es);
  if L = nil then Result := False else
  begin
    Result := True;
    for i := 0 to L.Count-1 do
    begin
      ri := L[i];
      case ri.Typ of
        oiAddress:
          b := CompareAddrs(Addr, ri.Addr) = 0;
        oiAddressMask:
          b := MatchMaskAddress(Addr, ri.S);
        oiFlag:
          b := FlagColl.Found(UpperCase(ri.S));
        oiPhoneNum:
          b := Pos(ri.S, Phone) = 1;
       else
         begin
           b := False;
//           b := Boolean(GlobalFail('%s', ['DialAllowed unknown Typ'])); // to avoid 'uninitialized' warning
         end;
      end;
      if not b then
      begin
        Result := False;
        Break;
      end;
    end;
    FreeObject(L);
  end;
end;

function SubItemFound(SC: TStringColl; Initial: Boolean): Boolean;
var
  i: Integer;
  s: string;
const
  Expl: array[Boolean] of Integer = (rsRecsRqdCndNS, rsRecsFrbCndS);
begin
  Result := Initial;
  for i := 0 to CollMax(SC) do
  begin
    s := Trim(SC[i]);
    if s = '' then Continue;
    Result := Matches(s, not Initial);
    if Result then Break;
  end;
  if Result <> Initial then AExpl := LngStr(Expl[not Initial]);
end;

begin
  FlagColl := TStringColl.Create;
  FlagColl.FillEnum(UpperCase(Flags), ',', True);
  Result := SubItemFound(AR.Required, True) and not SubItemFound(AR.Forbidden, False);
  FreeObject(FlagColl);
end;


function ValidRestrictEntry;
var
  L: TColl;
  es: string;


procedure AddFormatLng(Id: Integer; const Args: array of const);
begin
  if AMsgs <> nil then AMsgs.Add(FormatLng(Id, Args));
end;

function DoParse: Boolean;
var
  i: Integer;
  ri: TRestrictItem;
begin
  Result := False;
  if es <> '' then
  begin
    AddFormatLng(rsRecsRI0, [es]);
    Exit;
  end;
  if L <> nil then
  for i := 0 to L.Count-1 do
  begin
    ri := L[i];
    case ri.Typ of
      oiAddress: ;
      oiAddressMask :;
      oiFlag:;
      oiPhoneNum:
        case AScope of
          rspBoth: ;
          rspDialup: ;
          rspIP:
            begin
              AddFormatLng(rsRecsRI1, [ri.S]);
              Exit
            end;
          else
          begin
            GlobalFail('%s', ['TRestrictionScope???']);
          end;
        end;
      oiIPNum:
        begin
          if AScope = rspDialup then
          begin
            if DigitsOnly(ri.S) then AddFormatLng(rsRecsRI4, [ri.S, DivideDash(ri.S)]);
          end;
          AddFormatLng(rsRecsRI3, [ri.S]);
          Exit
        end;
      oiIPSym:
        begin
          AddFormatLng(rsRecsRI2, [ri.S]);
          Exit
        end;
      else GlobalFail('%s', ['ValidRestrictEntry unknown Typ'])
    end;
  end;
  Result := True;
end;


begin
  L := ParseRestrictStr(Entry, @es);
  Result := DoParse;
  FreeObject(L);
end;


function PatchPhoneNumber(const Number: string; AddPrefix: Boolean): string;
var
  I: Integer;
  Z: string;
  S: string;
begin
  S := WipePhoneNumber(Number);
  CfgEnter;
  for I := 0 to Cfg.Nodelist.SrcPfx.Count-1 do
  begin
    Z := WipePhoneNumber(_DelSpaces(Cfg.Nodelist.SrcPfx[I]));
    if Copy(S, 1, Length(Z)) = Z then
    begin
      Delete(S, 1, Length(Z));
      Z := _DelSpaces(Cfg.Nodelist.DstPfx[I]);
      if AddPrefix then S := WipePhoneNumber(Z) + S
                   else if Z <> '' then S := '...-' + S;
      Break;
    end;
  end;
  S := StrAsg(S);
  CfgLeave;
  Result := S;
end;

constructor TPathnameColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  DefaultZone := Stream.ReadDWORD;
  Cfg.SetObj(@Cfg.PathNames, Self)
end;

procedure TPathnameColl.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteDWORD(DefaultZone);
end;

constructor TIPRec.Load(Stream: TxStream);

function ReadnValidate: string;
begin
  Result := Stream.ReadStr;
  if not ValidRestrictEntry(Result, nil, rspIP) then Result := '';
end;

begin
  InPorts := Stream.Get;
  StationData := Stream.Get;
  Restriction := Stream.Get;
  InC := Stream.ReadDword;
  OutC := Stream.ReadDword;
  Speed := Stream.ReadDword;
  Banner := Stream.ReadStr;
  Cfg.SetObj(@Cfg.IPData, Self);
end;

procedure TIPRec.Store(Stream: TxStream);
begin
  Stream.Put(InPorts);
  Stream.Put(StationData);
  Stream.Put(Restriction);
  Stream.WriteDword(InC);
  Stream.WriteDword(OutC);
  Stream.WriteDword(Speed);
  Stream.WriteStr(Banner);
end;

constructor TIPRec.Create;
begin
  inherited Create;
  InPorts := TInPortsColl.Create;
  StationData := TStationDataColl.Create;
  Restriction := TRestrictionData.Create;
end;

destructor TIPRec.Destroy;
begin
  FreeObject(InPorts);
  FreeObject(StationData);
  FreeObject(Restriction);
  inherited Destroy;
end;

constructor TIPRec_v3074.Load(Stream: TxStream);
var
  IPData_v3075: TIPRec_v3075;
begin
  InPorts := Stream.Get;
  StationData := Stream.Get;
  Restriction := TOldIPRestriction.Create;
  Restriction.Required := Stream.ReadStr;
  Restriction.Forbidden := Stream.ReadStr;
  InC := Stream.ReadDword;
  OutC := Stream.ReadDword;
  Stream.Read(Options, SizeOf(Options));
  IPData_v3075 := Upgrade;
  Stream.FreeLastLoaded := True;
  Cfg.SetObj(@Cfg.IpData, IPData_v3075.Upgrade);
  FreeObject(IPData_v3075);
end;

function TIPRec_v3074.Upgrade: TIPRec_v3075;
begin
  Result := TIPRec_v3075.Create;
  Result.Banner := Format('Welcome to %s'#13#10#13#10'Processing mail only - please disconnect', [StationData.Station]);
  XChg(Integer(Result.InPorts), Integer(InPorts)); FreeObject(InPorts);
  XChg(Integer(Result.StationData), Integer(StationData)); FreeObject(StationData);
  XChg(Integer(Result.Restriction), Integer(Restriction)); FreeObject(Restriction);
  Result.InC := InC;
  Result.OutC := OutC;
  Result.Speed := 600;
  Result.Options := Options;
  Cfg.AddUpgStringLng(rsRecsTCPSB);
end;


procedure SetNodeOvr(AOvr: TAbsNodeOvrColl; APgOvr: Pointer);
var
  s1, s2: TStringColl;
  o: TNodeOvr;
  i: Integer;
  AgOvr: TAdvGrid absolute APgOvr;
begin
  s1 := TStringColl.Create;
  s2 := TStringColl.Create;
  for i := 0 to AOvr.Count-1 do
  begin
    o := AOvr[i];
    s1.Add(Addr2Str(o.Addr));
    s2.Add(o.Ovr);
  end;
  AgOvr.SetData([s1, s2]);
  FreeObject(s1);
  FreeObject(s2);
end;

function NodeOvrValid(AOvr: TAbsNodeOvrColl; APgOvr: Pointer; AHandle: THandle; Dialup: Boolean): Boolean;
var
  I: Integer;
  A: TFidoAddress;
  Item, Msg, S: string;
  O: TNodeOvr;
  AgOvr: TAdvGrid absolute APgOvr;
  C: TColl;
  R: TAddrListRecNCP;
begin
  Result := False;
  AOvr.FreeAll;
  for I := 1 to AgOvr.RowCount-1 do
  begin
    S := AgOvr[1,I];
    if S = '' then
    begin
      if AgOvr.RowCount = 2 then Result := True else
        DisplayError(FormatLng(rsRecsEmptyAdr, [I]), AHandle);
      Exit;
    end;
    if not ParseAddress(S, A) then
    begin
      DisplayError(FormatLng(rsRecsInvAdrLst, [S, I]), AHandle);
      Exit;
    end;
    S := AgOvr[2,I];
    if Trim(S) = '' then
    begin
      DisplayError(FormatLng(rsRecsEmpOvr, [I]), AHandle);
      Exit;
    end;
    Msg := ValidOverride(S, Dialup, Item);
    if Msg <> '' then
    begin
      WinDlgCap(Msg, MB_OK or MB_ICONERROR, AHandle, FormatLng(rsRecsInvOvr, [I, Item]));
      Exit;
    end;
    O := TNodeOvr.Create;
    O.Addr := A;
    O.Ovr := S;
    AOvr.Insert(O);
  end;
  C := TColl.Create;
  for i := 0 to AOvr.Count-1 do
  begin
    O := AOvr[i];
    R := TAddrListRecNCP.Create;
    R.AddrList.Add(O.Addr);
    C.Add(R);
  end;
  Result := ReportDuplicateAddrs(C, AgOvr, rsRecsOvrDup);
  FreeObject(C);
end;

function ParsePortsList(A: PvIntArr; s: string): Boolean;
var
  z: string;
  i: Integer;
  id: DWORD;
begin
  Result := False;
  if A <> nil then Clear(A^, SizeOf(A^));
  while s <> '' do
  begin
    GetWrd(s, z, ' ');
    id := Vl(z);
    if (id = INVALID_VALUE) or (id >= DWORD(MaxInt)) then Exit;
    i := id;
    if A <> nil then AddVIntArr(A^, i);
  end;
  Result := True;
end;

function ValidPortsList(const s: string): Boolean;
begin
  Result := ParsePortsList(nil, s);
end;

constructor TStartupRec.Load(Stream: TxStream);
begin
  CntAutoOpenLines := Stream.ReadDword;
  if CntAutoOpenLines > 0 then
  begin
    GetMem(IdAutoOpenLines, CntAutoOpenLines*SizeOf(Integer));
    Stream.Read(IdAutoOpenLines^, CntAutoOpenLines*SizeOf(Integer));
  end;
  Options := Stream.ReadByte;
  Cfg.SetObj(@Cfg.StartupData, Self);
end;

procedure TStartupRec.Store(Stream: TxStream);
begin
  Stream.WriteDword(CntAutoOpenLines);
  if CntAutoOpenLines > 0 then
  begin
    Stream.Write(IdAutoOpenLines^, CntAutoOpenLines*SizeOf(Integer));
  end;
  Stream.WriteByte(Options);
end;

constructor TStartupRec.Create;
begin
  inherited Create;
end;

destructor TStartupRec.Destroy;
begin
  if IdAutoOpenLines <> nil then FreeMem(IdAutoOpenLines, CntAutoOpenLines*SizeOf(Integer));
  inherited Destroy;
end;

function WithinIntArr(Id: Integer; IA: PIntArray; IC: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to IC-1 do
  begin
    if Id = IA^[i] then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function IsAutoStartLine(Id: Integer): Boolean;
begin
  Result := WithinIntArr(Id, Cfg.StartupData.IdAutoOpenLines, Cfg.StartupData.CntAutoOpenLines);
end;

procedure InsUA(var C: TColl; AN: TAdvNodeData);
begin
  if C = nil then C := TColl.Create;
  C.Insert(AN);
end;

function GetNodeOvrData(Addr: TFidoAddress; {$IFDEF WS}Dialup: Boolean; {$ENDIF}ALNode: TFidoNode): TColl;
var
  o: TNodeOvr;
  OC: TAbsNodeOvrColl;
  i,fcp: Integer;
  s,z,ss: string;
  fc: TStringColl;
  OvrColl: TColl;
  OvrData: TOvrData;
  dn: TFidoNode;
  an: TAdvNodeData;
  Msg, Item: string;

procedure DoAdd;
begin
  an := TAdvNodeData.Create;
  {$IFDEF WS}if not Dialup then an.IpAddr := s else{$ENDIF} an.Phone := s;
  an.Flags := z;
  InsUA(Result, an);
end;


begin
  dn := nil;
  Result := nil;
  s := '';

  if s = '' then
  begin
    {$IFDEF WS}if Dialup then{$ENDIF}
    begin
      EnterCS(AuxDialupNodeOverridesCS);
      OC := AuxDialupNodeOverrides;
    end
    {$IFDEF WS}
    else
    begin
      EnterCS(AuxIpNodeOverridesCS);
      OC := AuxIpNodeOverrides;
    end{$ENDIF};

    for i := 0 to CollMax(OC) do
    begin
      o := OC[i];
      if CompareAddrs(Addr, o.Addr) = 0 then begin s := o.Ovr; Break end;
    end;
    {$IFDEF WS}if Dialup then{$ENDIF}
    begin
      LeaveCS(AuxDialupNodeOverridesCS);
    end
    {$IFDEF WS}
    else
    begin
      LeaveCS(AuxIpNodeOverridesCS);
    end{$ENDIF};
  end;

  if s = '' then
  begin
    CfgEnter;
    if {$IFDEF WS}Dialup{$ELSE}True{$ENDIF} then OC := Cfg.DialupNodeOverrides {$IFDEF WS}else OC := Cfg.IPNodeOverrides{$ENDIF};
    for i := 0 to OC.Count-1 do
    begin
      o := OC[i];
      if CompareAddrs(Addr, o.Addr) = 0 then begin s := StrAsg(o.Ovr); Break end;
    end;
    CfgLeave;
  end;
  if s = '' then Exit;

  OvrColl := ParseOverride(s, Msg, Item, {$IFDEF WS}Dialup{$ELSE}True{$ENDIF});
  if OvrColl = nil then Exit;
  for i := 0 to OvrColl.Count-1 do
  begin
    OvrData := OvrColl[i];
    s := OvrData.PhoneDirect;
    if s = '' then
    begin
      dn := GetListedNode(OvrData.PhoneNodelist);
      if dn <> nil then s := dn.Phone;
    end;
    if s <> '' then
    begin
      if TransportMatch(s, {$IFDEF WS}Dialup{$ELSE}True{$ENDIF}) then
      begin
        if dn <> nil then ss := dn.Flags else
        if ALNode <> nil then ss := ALNode.Flags else ss := '';
        z := OvrData.Flags;
        fc := TStringColl.Create;
        if Pos(',!ALL,', ','+UpperCase(z)+',') = 0 then
        begin
          fc.FillEnum(ss, ',', False);
          if (Pos(',!CM,', ','+UpperCase(z)+',') <> 0) or
             (Pos(',CM,', ','+UpperCase(z)+',') <> 0) or
             (NodeFSC62Local(z) <> []) then
          begin
            PurgeTimeFlags(fc);
          end;
        end;
        while z <> '' do
        begin
          GetWrd(z, ss, ',');
          if ss = '' then Continue;
          if ss[1] = '!' then
          begin
            DelFC(ss);
            if UpperCase(ss) <> 'ALL' then
            begin
              fcp := fc.IdxOfUC(ss);
              if fcp <> -1 then fc.AtFree(fcp);
            end;
          end else
          begin
            if not fc.FoundUC(ss) then fc.Add(ss);
          end;
        end;
        z := fc.LongStringD(',');
        FreeObject(fc);
        if TransportFlagsMatch(s, z, {$IFDEF WS}Dialup{$ELSE}True{$ENDIF}) then DoAdd else
        begin
          if{$IFDEF WS}Dialup{$ELSE}True{$ENDIF} then
          begin
            fc := TStringColl.Create;
            fc.FillEnum(z, ',', False);
            PurgeIpFlags(fc);
            if TransportFlagsMatch(s, fc.LongStringD(','), {$IFDEF WS}Dialup{$ELSE}True{$ENDIF}) then DoAdd;
            FreeObject(fc);
          end;
        end;
      end;
    end;
  end;
  FreeObject(OvrColl);
end;

procedure PostCloseMessage;
begin
  if Application.MainForm <> nil then _PostMessage(Application.MainForm.Handle, WM_CLOSE, 0, 0);
  ExitNow := True;
end;

var
  zePos, rePos, nePos, pePos:byte;
  ImportMainAddr: TFidoAddress;

function GetEndCodes(var SAddr:ShortString):Boolean;assembler;
asm
             push   ebx
             push   esi
             push   edi
             mov    zePos,1
             mov    rePos,1
             mov    nePos,1
             mov    pePos,1
             mov    esi,eax
             push   esi
             xor    eax,eax
             lodsb
             mov    ebx,eax
             mov    [ebx+esi],ah
             pop    ebx
             lodsb
             cmp     al,'.'
             je      @@SetPoint
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
 @@0:
             lodsb
             cmp     al,':'
             je      @@ZoneEnd
             cmp     al,'/'
             je      @@RegEnd
             cmp     al,'.'
             je      @@SetPoint
             cmp     al,0
             jz      @@SetZeroPoint
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
             jmp     @@0
@@ZoneEnd:

             mov     eax,esi
             sub     eax,ebx
             mov     [zePos],al
             lodsb
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
 @@1:
             lodsb
             cmp     al,'/'
             je      @@RegEnd
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
             jmp     @@1
@@RegEnd:
             mov     eax,esi
             sub     eax,ebx
             mov     [rePos],al
             lodsb
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
 @@2:
             lodsb
             cmp     al,'.'
             je      @@SetPoint
             cmp     al,0
             jz      @@SetZeroPoint
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
             jmp     @@2

@@SetPoint:
             mov     eax,esi
             sub     eax,ebx
             mov     [nePos],al
             lodsb
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
 @@3:
             lodsb
             cmp     al,0
             jz      @@PointOK
             cmp     al,'0'
             jb      @@Err
             cmp     al,'9'
             ja      @@Err
             jmp     @@3
@@SetZeroPoint:
             mov     eax,esi
             sub     eax,ebx
             mov     [nePos],al
             jmp     @@OK
@@PointOK:
             mov     eax,esi
             sub     eax,ebx
             mov     [pePos],al
@@OK:        mov     al,1
             jmp     @@End
@@Err:       mov     al,0
@@End:       pop     edi
             pop     esi
             pop     ebx
end;

function _ValidFidoAddr(SAddr:string;var NAdr:TFidoAddress):Boolean;
const
  ValidAddrChrs=['0'..'9','a'..'z','A'..'Z','_',':','/','.','@'];
var
  s: string;
  ss: ShortString;
  p: Integer;
  ExFlg, ec: Boolean;

 function VVal(const s:string):word;
 var
   w : DWORD;
 begin
   w := Vl(s);
   ExFlg := ExFlg or (w = INVALID_VALUE) or (w > $FFFF);
   if ExFlg then w := 0;
   Result := w;
 end;

begin
  ec:=False;ExFlg:=False;
  repeat
  for p:=1 to Length(SAddr) do if not (SAddr[p] in ValidAddrChrs) then break;
  with NAdr do
  begin
    p:=Pos('@',SAddr);
    if p>0 then s:=Copy(SAddr,1,p-1) else s:=SAddr;
    ss := s; if not GetEndCodes(ss) then break;
    if zePos>1 then Zone:=VVal(Copy(s,1,zePos-2)) else Zone:=ImportMainAddr.Zone;
    if ExFlg then break;
    if rePos>1 then Net:=VVAl(Copy(s,zePos,rePos-zePos-1)) else Net:=ImportMainAddr.Net;
    if ExFlg then break;
    if SAddr[1]<>'.' then Node:=VVAl(Copy(s,rePos,nePos-rePos-1)) else Node:=ImportMainAddr.Node;
    if ExFlg then break;
    if pePos>1 then Point:=VVal(Copy(s,nePos,pePos-nePos-1)) else Point:=0;
    if ExFlg then break;
    ec:=True;
  end until True;
  Result := ec;
end;

function ImportName(const FName, IncFName: string): string;
begin
  if ExtractFilePath(IncFName) <> '' then Result := IncFName else
    Result := ExtractFilePath(FName) + IncFName;
end;

procedure InsertImportRec(Coll: TColl; const a: TFidoAddress; const ADialupOverrides, AIPOverrides, APassword: string);
var
  ir: TImportRec;
begin
  ir := TImportRec.Create;
  ir.Addr := a;
  ir.DialupOverrides := ADialupOverrides;
  ir.IPOverrides := AIPOverrides;
  if APassword <> '-' then ir.Password := APassword;
  Coll.Insert(ir);
end;

procedure ProcessImportStrBinkD(Coll: TColl; sc: TStringColl);
var
  a: TFidoAddress;
  Pwd, Addr: string;
begin
  if sc.Count < 3 then Exit;
  if UpperCase(sc[0]) <> 'NODE' then Exit;
  if not ParseAddress(sc[1], a) then Exit;
  Addr := sc[2];
  if not ValidInetAddr(Addr) then
  begin
    Addr := '"'+Addr+'"';
    if not ValidSymAddr(Addr) then Exit;
  end;
  if sc.Count > 3 then Pwd := sc[3] else Pwd := '';
  InsertImportRec(Coll, a, '', Addr+',CM,BND', Pwd);
end;

procedure ProcessImportStrBinkPlus(const FName: string; Coll: TColl; sc: TStringColl);
var
  us, s: string;
  a: TFidoAddress;
  i: Integer;
  Phone, Pwd, Flags: string;
  AddrOK, PhoneOK, PwdOK, FlagsOK: Boolean;


procedure DoInsert(Find: Boolean);

function Found: Boolean;
var
  i: Integer;
  r: TImportRec;
begin
  Result := False;
  for i := 0 to Coll.Count-1 do
  begin
    r := Coll[i];
    if (CompareAddrs(a, r.Addr) <> 0) or
       (r.DialupOverrides <> '') or
       (r.IpOverrides <> '') then Continue;
    Result := True;
    Break;
  end;
end;

begin
  if AddrOK and (PhoneOK or PwdOK) then
  begin
    if not PhoneOK then begin Phone := ''; if FlagsOK then Phone := Addr2Str(a) end;
    if not PwdOK then Pwd := '';
    if FlagsOK then Phone := Format('%s,%s', [Phone, Flags]);
    if Find and (not Found) then InsertImportRec(Coll, a, Addr2Str(a), '', '');
    InsertImportRec(Coll, a, Phone, '', Pwd);
  end;
end;

function _GetAddr: Boolean;
begin
  Result := _ValidFidoAddr(s, a);
  AddrOK := Result;
end;

function _GetPhone: Boolean;
begin
  if Pos('-', s) = 0 then s := DivideDash(s);
  Result := IdentOvrItem(s, False, False) = oiPhoneNum;
  if Result then Phone := s;
  PhoneOK := Result;
end;

function _GetPwd: Boolean;
begin
  Pwd := s;
  Result := True;
  PwdOK := Result;
end;

function _GetFlags: Boolean;
begin
  Result := (Pos('-',s) = 0) and (Pos('+', s) = 0);
  if Result then Flags := s;
  FlagsOK := Result;
end;

procedure Clr;
begin
  AddrOK := False;
  PhoneOK := False;
  PwdOK := False;
  FlagsOK := False;
end;

begin
  if sc.Count < 2 then Exit;
  us := UpperCase(sc[0]);
  if (ImportMainAddr.Node = -1) and
     (sc.Count=2) and
     (us = 'ADDRESS') and
     (_ValidFidoAddr(sc[1], a)) then ImportMainAddr := a else
  if (sc.Count=2) and
     (us = 'INCLUDE') then 
     ImportAlienCfg(ImportName(FName, sc[1]), Coll, actBinkPlus) else
  if (us = 'OVERRIDE') then
  begin
    Clr;
    for i := 1 to MinI(5, sc.Count-1) do
    begin
      s := sc[i];
      if s = '-' then Continue;
      case i of
        1: if not _GetAddr then Continue;
        2: if not _GetPhone then Continue;
        3: if not _GetPwd then Continue;
        4: Continue; // Ignore WorkTime
        5: if not _GetFlags then Continue;
      end;
      case i of
        1: AddrOK := True;
        2: PhoneOK := True;
        3: PwdOK := True;
        5: FlagsOK := True;
      end;
    end;
    DoInsert(False);
  end else
  if (us = 'HIDDEN') then
  begin
    Clr;
    for i := 1 to MinI(3, sc.Count-1) do
    begin
      s := sc[i];
      if s = '-' then Continue;
      case i of
        1: if not _GetAddr then Continue;
        2: if not _GetPhone then Continue;
        3: if not _GetFlags then Continue;
      end;
    end;
    DoInsert(True);
  end;
end;

procedure FlushLts(Coll: TColl); forward;

procedure ProcessImportStrTMail(const FName: string; Coll: TColl; sc: TStringColl);
var
  us: string;
  a: TFidoAddress;
begin
  if sc.Count <> 2 then Exit;
  us := UpperCase(sc[0]);
  if (ImportMainAddr.Node = -1) and
     (sc.Count>=2) and
     (us = 'ADDRESS') and
     (_ValidFidoAddr(sc[1], a)) then ImportMainAddr := a else
  if us = 'INCLUDE' then ImportAlienCfg(ImportName(FName, sc[1]), Coll, actTMail) else
  if us = 'SUBSTLIST' then
  begin
    ImportAlienCfg(ImportName(FName, sc[1]), Coll, actTMailSubst);
    FlushLts(Coll);
  end;
  if us = 'SECURITY' then ImportAlienCfg(ImportName(FName, sc[1]), Coll, actTMailSecutiry);
end;

procedure ProcessImportStrTMailSecurity(Coll: TColl; sc: TStringColl);
var
  s,z: string;
  a: TFidoAddress;
begin
  if sc.Count < 2 then Exit;
  if not _ValidFidoAddr(sc[0], a) then Exit;
  s := sc[1];
  GetWrd(s, z, ',');
  InsertImportRec(Coll, a, '', '', z);
end;


type
  TTmailSubstColl = class(TColl)
    Address: TFidoAddress;
    Password: string;
  end;

  TTmailSubstHidden = class
    Hidden, Time, Flags: string;
  end;

var
  lts: TTmailSubstColl;

procedure InsertIDovr(Coll: TColl; AAddress: TFidoAddress; const Astr: string); forward;

procedure FlushLts(Coll: TColl);
var
  i: Integer;
  h: TTmailSubstHidden;
  t, s: string;

begin
  if lts = nil then Exit;
  for i := 0 to lts.Count-1 do
  begin
    h := lts[i];
    s := h.Hidden;
    if h.Flags <> '' then
    begin
      if s <> '' then s := s + ',';
      s := s + h.Flags;
    end;
    if h.Time <> '' then
    begin
      t := HumanTime2UTxyL(h.Time, True);
      if t <> '' then
      begin
        if s <> '' then s := s + ',';
        s := s + t;
      end;
    end;
    if (s <> '') and (h.Hidden = '') then s := Addr2Str(lts.Address) + ',' + s;
    if s <> '' then InsertIDovr(Coll, lts.Address, s);
  end;
  if lts.Password <> '' then InsertImportRec(Coll, lts.Address, '', '', lts.Password);
  FreeObject(lts);
end;

procedure ProcessImportStrTMailSubst(Coll: TColl; sc: TStringColl);
var
  a: TFidoAddress;
  s1, s2: string;
  lh: TTmailSubstHidden;
begin
  s1 := sc[0];
  sc.AtFree(0);
  if s1 = '#' then
  begin
    if lts = nil then Exit;
  end else
  begin
    if not _ValidFidoAddr(s1, a) then Exit;
    FlushLts(Coll);
    lts := TTmailSubstColl.Create;
    lts.Address := a;
  end;
  lh := TTmailSubstHidden.Create;
  lts.Insert(lh);
  while sc.Count >=2 do
  begin
    s1 := UpperCase(sc[0]); sc.AtFree(0);
    s2 := sc[0]; sc.AtFree(0);
    if s1 = 'PASSWORD' then lts.Password := s2 else
    if s1 = 'PHONE' then lh.Hidden := s2 else
    if s1 = 'HIDDEN' then lh.Hidden := s2 else
    if s1 = 'HIDDEN_ADDRESS' then lh.Hidden := s2 else
    if s1 = 'TIME' then lh.Time := s2 else
    if s1 = 'FLAGS' then lh.Flags := s2 else
  end;
end;


procedure InsertIDovr(Coll: TColl; AAddress: TFidoAddress; const Astr: string);
var
  aa: TFidoAddress;
  s, z, dovr,iovr: string;
begin
  s := Astr;
  dovr := '';
  iovr := '';
  GetWrd(s, z, ',');
  if _ValidFidoAddr(z, aa) then
  begin
    if s = '' then
    begin
      iovr := AStr;
      dovr := AStr;
    end else
    if AreFlagsTCP(s) then iovr := AStr else dovr := AStr;
  end else
  begin
    if ValidInetAddr(z) then
    begin
      iovr := AStr;
      Replace('*', '.', iovr);
      if Pos('.', iovr)=0 then
      begin
        dovr := iovr;
        if not AreFlagsTCP(s) then iovr := '';
      end;
    end else
    case GetTransportType(z, s) of
      ttDialup : dovr := AStr;
      ttIP     : GlobalFail('%s', ['InsertIDovr - ttIP is not acceptable']);
      else
      begin
        if IdentOvrItem(z, False, False) = oiPhoneNum then dovr := AStr else
        if AreFlagsTCP(s) then iovr := '"'+z+'",'+s else
        begin
          if Pos('.', AStr) = 0 then dovr := AStr;
          iovr := '"'+z+'",'+s;
        end;
      end;
    end;
  end;
  InsertImportRec(Coll, AAddress, dovr, iovr, '');
end;

procedure ProcessImportStrXenia(const FName: string; Coll: TColl; sc: TStringColl);
var
  i: Integer;
  a: TFidoAddress;
  us: string;
begin
  if sc.Count = 0 then Exit;
  us := UpperCase(sc[0]);
  case sc.Count of
    2 :
      begin
        if us = 'INCLUDE' then ImportAlienCfg(ImportName(FName, sc[1]), Coll, actXenia);
      end;
    3..MaxInt:
      begin
        if us = 'PASSWORD' then
        begin
          for i := 2 to sc.Count-1 do
          begin
            if not ParseAddress(sc[i], a) then Exit;
            InsertImportRec(Coll, a, '', '', sc[1]);
          end;
        end else
        if us = 'PHONE' then
        begin
          if not ParseAddress(sc[1], a) then Exit;
          for i := 2 to sc.Count-1 do InsertIDovr(Coll, a, sc[i]);
        end;
      end;
  end;
end;

procedure ImportAlienCfg(const FName: string; Coll: TColl; Typ: TAlienCfgType);
var
  T: TTextReader;
  s: string;
  sc: TStringColl;
  i: Integer;
begin
  T := CreateTextReader(FName);
  if T = nil then Exit;
  sc := TStringColl.Create;
  while not T.EOF do
  begin
    s := Trim(T.GetStr);
    if s = '' then Continue;
    case Typ of
      actBinkPlus:
        begin
          if s[1]=';' then i := -1 else i := Pos('%;', s);
        end;
      else
        begin
          i := Pos(';', s);
        end;
    end;
    if i = -1 then Continue;
    if i>0 then s := Trim(Copy(s, 1, i-1));
    if s = '' then Continue;
    sc.FillEnum(s, ' ', False);
    case Typ of
      actTMail,
      actTMailSubst,
      actTMailSecutiry:
      begin
        s := sc[0];
        if (s[1] = '[') and (s[Length(s)]=']') then sc.AtFree(0);
        if sc.Count = 0 then Continue;
      end;
    end;

    case Typ of
      actBinkD: ProcessImportStrBinkD(Coll, sc);
      actBinkPlus: ProcessImportStrBinkPlus(FName, Coll, sc);
      actTMail: ProcessImportStrTMail(FName, Coll, sc);
      actTMailSubst: ProcessImportStrTMailSubst(Coll, sc);
      actTMailSecutiry: ProcessImportStrTMailSecurity(Coll, sc);
      actXenia: ProcessImportStrXenia(FName, Coll, sc);
      else GlobalFail('%s', ['ImportAlienCfg']);
    end;
    sc.FreeAll;
  end;
  FreeObject(sc);
  FreeObject(T);
end;


function xDoorPwd(const Buffer): string;
begin
  Result := ShortBuf2Str(Buffer, 8);
end;

procedure ImportFrontDoorPwd(const FName: string; Coll: TColl);

type
  TPwdRec = record
    zone, net, node, point: Word;         // System address
    password: array[1..9] of Char;        // NUL terminated
    status: Byte;
  end;

const
  PwdRecSize = SizeOf(TPwdRec);

var
  h: DWORD;
  Actually: DWORD;
  PwdRec: TPwdRec;
  r: TImportRec;
begin
  h := _CreateFile(FName, [cRead, cSequentialScan]);
  if h = INVALID_HANDLE_VALUE then Exit;
  repeat
    if not ReadFile(h, PwdRec, PwdRecSize, Actually, nil) then Break;
    if Actually <> PwdRecSize then Break;
    r := TImportRec.Create;
    r.Addr.Zone := PwdRec.Zone;
    r.Addr.Net := PwdRec.Net;
    r.Addr.Node := PwdRec.Node;
    r.Addr.Point := PwdRec.Point;
    r.Password := xDoorPwd(PwdRec.Password);
    Coll.Insert(r);
  until False;
  ZeroHandle(h);
end;

procedure ImportMainDoorPwd(const FName: string; Coll: TColl);
type
  TPwdRec = record
    zone, net, node, point: Word;         // System address
    password: array[1..8] of Byte;        // NUL terminated
  end;

const
  PwdRecSize = SizeOf(TPwdRec);

var
  i: Integer;
  PwdRec: TPwdRec;
  r: TImportRec;
  h, Actually: DWORD;
begin
  h := _CreateFile(FName, [cRead]);
  if h = INVALID_HANDLE_VALUE then Exit;
  if SetFilePointer(h, $4E, nil, File_Current) = INVALID_FILE_SIZE then Exit;
  repeat
    if not ReadFile(h, PwdRec, PwdRecSize, Actually, nil) then Break;
    if Actually <> PwdRecSize then Break;
    r := TImportRec.Create;
    r.Addr.Zone := PwdRec.Zone;
    r.Addr.Net := PwdRec.Net;
    r.Addr.Node := PwdRec.Node;
    r.Addr.Point := PwdRec.Point;
    for i := 1 to 8 do PwdRec.Password[i] := PwdRec.Password[i] xor ((PwdRec.Password[i] and $F) shl 4);
    r.Password := xDoorPwd(PwdRec.Password);
    Coll.Insert(r);
    if SetFilePointer(h, $F8, nil, File_Current) = INVALID_FILE_SIZE then Break;
  until False;
  ZeroHandle(h);
end;

procedure DoImportAlienCfg(const FName: string; Coll: TColl; Typ: TAlienCfgType);
begin
  case Typ of
    actBinkD,
    actBinkPlus,
    actTMail,
    actXenia: ImportAlienCfg(FName, Coll, Typ);
    actFrontDoor: ImportFrontDoorPwd(FName, Coll);
    actMainDoor: ImportMainDoorPwd(FName, Coll);
    else GlobalFail('%s', ['DoImportAlienCfg']);
  end;
end;

function SortOvr(Item1, Item2: Pointer): Integer;
begin
  Result := CompareAddrs(TNodeOvr(Item1).Addr, TNodeOvr(Item2).Addr);
end;

procedure FillGridPswOvr(AColl, AGrid: Pointer; APwd: Boolean);
var
  Coll: TColl absolute AColl;
  Grid: TAdvGrid absolute AGrid;
  s1, s2: TStringColl;
  ss1, ss2: string;
  i: Integer;
  p: TPasswordRec;
  o,onxt: TNodeOvr;
begin
  if not APwd then Coll.Sort(SortOvr);
  s1 := TStringColl.Create;
  s2 := TStringColl.Create;
  i := 0;
  while i<Coll.Count do
  begin
    if APwd then
    begin
      p := Coll[i];
      ss1 := p.AddrList.GetString;
      ss2 := p.PswStr;
    end else
    begin
      o := Coll[i];
      ss1 := Addr2Str(o.Addr);
      ss2 := o.Ovr;
      repeat
        if (i=Coll.Count-1) then Break;
        onxt := Coll[i+1];
        if CompareAddrs(o.Addr, onxt.Addr) <> 0 then Break;
        Inc(i);
        ss2 := ss2+' '+onxt.Ovr;
      until False;
    end;
    s1.Add(ss1);
    s2.Add(ss2);
    Inc(i);
  end;
  Grid.SetData([s1, s2]);
  FreeObject(s1);
  FreeObject(s2);
end;

function DoImport(AC, NI, AColl, AGrid: Pointer; APsw, ADialup: Boolean): Boolean;
var
  Grid: TAdvGrid absolute AGrid;

  Coll: TColl absolute AColl;

  c: TColl absolute AC;

  NewItems: TColl absolute NI;

  i,j,kkk,mr: Integer;
  ir: TImportRec;

  PwdR: TPasswordRec;
  OvrR: TNodeOvr;

  s1, s2: string;

  All: Boolean;
  Found: Boolean;

procedure InsertPsw;
var
  R: TPasswordRec;
  A: TFidoAddrColl;
  P: PFidoAddress;
begin
  P := New(PFidoAddress);
  P^ := ir.Addr;
  A := TFidoAddrColl.Create;
  A.Insert(P);
  R := TPasswordRec.Create;
  R.AddrList := A;
  R.PswStr := ir.Password;
  NewItems.Insert(R);
end;

procedure InsertOvr;
var
  O: TNodeOvr;
begin
  O := TNodeOvr.Create;
  O.Addr := ir.Addr;
  if ADialup then O.Ovr := ir.DialupOverrides else O.Ovr := ir.IPOverrides;
  NewItems.Insert(O);
end;

procedure Ins;
begin
  if APsw then InsertPsw else InsertOvr;
end;

function ItemMatches: Boolean;
var
  k: Integer;
begin
  if APsw then
  begin
    Result := False;
    for k := PwdR.AddrList.Count-1 downto 0 do
      if CompareAddrs(ir.Addr, PwdR.AddrList[k])=0 then
    begin
      kkk := k;
      Result := True;
      Exit
    end;
  end else
  begin
    Result := CompareAddrs(ir.Addr, OvrR.Addr) = 0;
  end;
end;

const
  CMsg: array[Boolean] of Integer = (rsRecsIMrovr, rsRecsIMrpwd);

begin
  Result := False;
  All := False;
  for i := 0 to c.Count-1 do
  begin
    Found := False;
    ir := c[i];
    if APsw then
    begin
      if ir.Password = '' then Continue;
    end else
    begin
      if ADialup then
      begin
        if ir.DialupOverrides = '' then Continue;
      end else
      begin
        if ir.IpOverrides = '' then Continue;
      end;
    end;
    for j := 0 to Coll.Count-1 do
    begin
      if APsw then PwdR := Coll[j] else OvrR := Coll[j];
      if not ItemMatches then Continue;
      Found := True;
      if APsw then
      begin
        if PwdR.PswStr = ir.Password then Continue;
      end else
      begin
        if ADialup then
        begin
          if OvrR.Ovr = ir.DialupOverrides then Continue;
        end else
        begin
          if OvrR.Ovr = ir.IpOverrides then Continue;
        end;
      end;
      if All then mr := mrYes else
      begin
        Grid.FocusCell(1, j+1, True);
        if APsw then
        begin
          s1 := PwdR.PswStr;
          s2 := ir.Password;
        end else
        begin
          s1 := OvrR.Ovr;
          if ADialup then s2 := ir.DialupOverrides else s2 := ir.IPOverrides;
        end;
        mr := MessageDlg(FormatLng(CMsg[APsw], [Addr2Str(ir.Addr), s1, s2]), Dialogs.mtWarning, [Dialogs.mbYes, Dialogs.mbNo, Dialogs.mbCancel, Dialogs.mbAll], 0);
      end;
      case mr of
        mrYes : ;
        mrNo: Continue;
        mrCancel: Exit;
        mrAll: All := True;
        else GlobalFail('DoImport mr = %d', [mr]);
      end;
      if APsw then PwdR.AddrList.AtFree(kkk) else FillChar(OvrR.Addr, SizeOf(OvrR.Addr), $FF);
      Ins;
    end;
    if not Found then Ins;
  end;
  Result := True;
end;

procedure ApplyImport(ANewItems, AColl, AGrid: Pointer; APsw, ADialup: Boolean);
var
  NewItems: TPasswordColl absolute ANewItems;
  Grid: TAdvGrid absolute AGrid;
  Coll: TColl absolute AColl;
  i: Integer;
  PswR: TPasswordRec;
  OvrR: TNodeOvr;

begin
  for i := Coll.Count-1 downto 0 do
  begin
    if APsw then
    begin
      PswR := Coll[i];
      OvrR := nil; // to avoid 'uninitialized' warning
    end else
    begin
      PswR := nil; // to avoid 'uninitialized' warning
      OvrR := Coll[i];
    end;
    if APsw then
    begin
      if PswR.AddrList.Count = 0 then Coll.AtFree(i);
    end else
    begin
      if OvrR.Addr.Zone = -1 then Coll.AtFree(i);
    end;
  end;
  Coll.Concat(NewItems);
  FillGridPswOvr(Coll, AGrid, APsw);
end;

procedure DoImportOp(AColl, AGrid: Pointer; APsw, ADialup: Boolean);
var
  c: TColl;
  Coll: TColl absolute AColl;
  Imported: Boolean;
  NewItems: TPasswordColl;
  nic: Integer;
  Typ: TAlienCfgType;
  s: string;
  OD: TOpenDialog;
  ii: Integer;
begin
  if APsw then s := LngStr(rsRecsIMdPwd) else if ADialup then s := LngStr(rsRecsIMdDN) else s := LngStr(rsRecsIMdTN);
  Typ := GetImportType(s, APsw);
  if Typ = actNone then Exit;
  OD := TOpenDialog.Create(Application);
  OD.Title := LngStr(rsRecsImpCfg);
  case Typ of
    actBinkD : ii := rsRecsImpBinkD;
    actBinkPlus : ii := rsRecsImpBinkPls;
    actXenia : ii := rsRecsImpXen;
    actTMail : ii := rsRecsImpTMail;
    actFrontDoor : ii := rsRecsImpFDoor;
    actMainDoor : ii := rsRecsImpMDoor;
    else ii := GlobalFail('%s', ['DoImportOp']); // to avoid unitialized warning
  end;

  OD.Options := [ofHideReadOnly];
  OD.Filter := LngStr(ii)+'|'+LngStr(rsAllFileMask);
  Imported := OD.Execute;
  s := OD.FileName;
  FreeObject(OD);
  if not Imported then Exit;
  ImportMainAddr.Zone := Cfg.Pathnames.DefaultZone;
  ImportMainAddr.Node := -1;
  c := TColl.Create;
  DoImportAlienCfg(s, c, Typ);
  NewItems := TPasswordColl.Create;
  Imported := DoImport(c, NewItems, AColl, AGrid, APsw, ADialup);
  FreeObject(c);
  nic := NewItems.Count;
  if Imported then ApplyImport(NewItems, AColl, AGrid, APsw, ADialup);
  Coll.FreeAll;
  FreeObject(NewItems);
  DisplayInformation(FormatLng(rsRecsNewCfgII, [nic]), TForm(TAdvGrid(AGrid).Owner).Handle);
end;

function CronGridValid(AG: Pointer): Boolean;
var
  g: TAdvGrid absolute AG;
  c: TStringColl;
  ErrLn: Integer;
  Msg: string;
begin
  c := TStringColl.Create;
  g.GetData([c]);
  Result := ValidCronColl(c, ErrLn, Msg);
  FreeObject(c);
  if not Result then DisplayError(FormatLng(rsRecsInvCRL, [ErrLn, Msg]), TForm(g.Owner).Handle);
end;

function TEvParVoid.Params: string;
begin
  Result := '';
end;

function TEvParVoid.Copy;
var
  r: TEvParVoid;
begin
  r := TEvParVoid.Create;
  r.Typ := Typ;
  Result := r;
end;

function TEvParString.Params: string;
begin
  Result := s;
end;

function TEvParString.Copy;
var
  r: TEvParString;
begin
  r := TEvParString.Create;
  r.Typ := Typ;
  r.s := StrAsg(s);
  Result := r;
end;

constructor TEvParString.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  s := Stream.ReadStr;
end;

procedure TEvParString.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(s);
end;

function TEvParDStr.Copy: Pointer;
var
  r: TEvParDStr;
begin
  r := TEvParDStr.Create;
  r.Typ := Typ;
  r.StrA := StrAsg(StrA);
  r.StrB := StrAsg(StrB);
  Result := r;
end;

constructor TEvParDStr.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  StrA := Stream.ReadStr;
  StrB := Stream.ReadStr;
end;

procedure TEvParDStr.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(StrA);
  Stream.WriteStr(StrB);
end;

function TEvParDStr.Params: string;
begin
  Result := StrA+' ('+StrB+')';
end;

constructor TEvParDMemo.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  MemoA := Stream.ReadStr;
  MemoB := Stream.ReadStr;
end;

procedure TEvParDMemo.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(MemoA);
  Stream.WriteStr(MemoB);
end;

function TEvParDMemo.Params: string;
begin
  Result := '';
end;

function TEvParDMemo.Copy: Pointer;
var
  r: TEvParDMemo;
begin
  r := TEvParDMemo.Create;
  r.Typ := Typ;
  r.MemoA := StrAsg(MemoA);
  r.MemoB := StrAsg(MemoB);
  Result := r;
end;

function TEvParGrid.Copy: Pointer;
var
  r: TEvParGrid;
  sl: TStringColl;
  i: Integer;
begin
  r := TEvParGrid.Create;
  r.Typ := Typ;
  r.s := StrAsg(s);
  for i := 0 to L.Count-1 do
  begin
    sl := L[i];
    r.L.Add(sl.Copy);
  end;
  Result := r;
end;

constructor TEvParGrid.Load(Stream: TxStream);
var
  i, cnt: Integer;
begin
  inherited Load(Stream);
  s := Stream.ReadStr;
  L := TColl.Create;
  cnt := Stream.ReadInteger;
  for i := 0 to cnt-1 do
  begin
    L.Add(TStringColl.Load(Stream))
  end;
end;

procedure TEvParGrid.Store(Stream: TxStream);
var
  i, cnt: Integer;
  sl: TStringColl;
begin
  inherited Store(Stream);
  Stream.WriteStr(s);
  cnt := L.Count;
  Stream.WriteInteger(cnt);
  for i := 0 to cnt-1 do
  begin
    sl := L[i];
    sl.Store(Stream);
  end;
end;

function TEvParGrid.Params: string;
begin
  Result := s;
end;

constructor TEvParGrid.Create;
begin
  inherited Create;
  L := TColl.Create;
end;

destructor TEvParGrid.Destroy;
begin
  FreeObject(L);
  inherited Destroy;
end;


function TEvParUV.Params: string;
var
  c: TElementColl;
begin
  case Typ of
    eiRplStation,
    eiRplModem,
    eiRplRestriction:
      begin
        case Typ of
          eiRplStation     : c := Cfg.Station;
          eiRplModem       : c := Cfg.Modems;
          eiRplRestriction : c := Cfg.Restrictions;
          else
          begin
            GlobalFail('TEvParUV(%s).Params unknown Typ on eiRplRestriction', [ClassName]);
            Exit; // to avoid 'uninitialized' warning
          end;
        end;
        Result := TNamed(c.GetRecById(d.DwordData)).Name;
      end;

    eiAccSpeedMin,
    eiTrsSpeedMin: Result := FormatLng(rsRecsEcBPS, [d.DwordData]);

    eiAccBPSEfMin,
    eiTrsBPSEfMin: Result := FormatLng(rsRecsEcPcMxBPS, [d.DwordData]);

    eiAccCPSMin,
    eiTrsCPSMin:   Result := FormatLng(rsRecsEcCPS, [d.DwordData]);

    eiNumRings : Result := Int2Str(d.DwordData);

    eiAccDurMax,
    eiTrsDurMax,
    
    eiFreqPwdDur,
    eiFreqPubDur: Result := FormatLng(rsRecsEcMinutes, [d.DwordData]);

    eiFreqPwdSz,
    eiFreqPubSz: Result := FormatLng(rsRecsEcKB, [d.DwordData]);

    eiFreqPwdCnt,
    eiFreqPubCnt: Result := FormatLng(rsRecsEcFiles, [d.DwordData]);


    eiAccNoFreqs,
    eiAccNoNiagara,
    eiTrsNoNiagara,
    eiAccNoHydra,
    eiTrsNoHydra,
    eiAccNoZmodem,
    eiTrsNoZmodem,
    eiAccNoEMSI,
    eiTrsNoEMSI,
    eiAccNoYooHoo,
    eiTrsNoYooHoo,
    eiAccNoFTS1,
    eiAccNoIncoming,
    eiModemDisaReinit,
    eiAccNoDummyZ,
    eiTrsNoDummyZ,
    eiAccProtected,
    eiAccListed,
    eiLogEMSI         : Result := LngStr(rsRecsEdDis);



    else GlobalFail('TEvParUV(%s).Params unknown typ', [ClassName]);
  end;
end;

function TEvParUV.Copy;
var
  r: TEvParUV;
begin
  r := TEvParUV.Create;
  r.Typ := Typ;
  r.d := d;
  Result := r;
end;

constructor TEvParUV.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Stream.Read(d, SizeOf(d));
end;

procedure TEvParUV.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.Write(d, SizeOf(d));
end;

procedure TEventContainer.SetDefault; begin GlobalFail('%s', ['TEventContainer.SetDefault']); end;


function TEventContainer_v3310.Upgrade: TEventContainer;
var
  r: TEventContainer;
begin
  r := TEventContainer.Create;
  r.Id := Id;
  r.FName := FName;
  r.Cron := Cron;
  r.Len := Len;
  XChg(Integer(r.Atoms), Integer(Atoms));
  Result := r;
  Cfg.AddUpgStringLng(rsRecsEvt);
end;

constructor TEventContainer_v3310.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cron := Stream.ReadStr;
  Len := Stream.ReadDword;
  Atoms := Stream.Get;
end;

const
  evPermanent = 1 shl 0;
  evUTC       = 1 shl 1;


constructor TEventContainer.Load(Stream: TxStream);
var
  Flags: Byte;
begin
  inherited Load(Stream);
  Cron := Stream.ReadStr;
  Len := Stream.ReadDword;
  Atoms := Stream.Get;
  Flags := Stream.ReadByte;
  Permanent := (Flags and evPermanent) <> 0;
  UTC := (Flags and evUTC) <> 0;
end;

procedure TEventContainer.Store(Stream: TxStream);
var
  Flags: Byte;
begin
  inherited Store(Stream);
  Stream.WriteStr(Cron);
  Stream.WriteDword(Len);
  Stream.Put(Atoms);
  Flags := 0;
  if Permanent then Flags := Flags or evPermanent;
  if UTC then Flags := Flags or evUTC;
  Stream.WriteByte(Flags);
end;

constructor TEventContainer.Create;
begin
  Atoms := TColl.Create;
end;


destructor TEventContainer.Destroy;
begin
  FreeObject(Atoms);
  inherited Destroy;
end;


destructor TEventContainer_v3310.Destroy;
begin
  FreeObject(Atoms);
  inherited Destroy;
end;


function TEventContainer.Copy;
var
  r: TEventContainer;
begin
  r := TEventContainer.Create;
  r.id := id;
  r.FName := StrAsg(FName);
  r.Cron := StrAsg(Cron);
  r.Len := Len;
  r.Permanent := Permanent;
  r.UTC := UTC;
  Atoms.CopyItemsTo(r.Atoms);
  Result := r;
end;

function GetEventParamTyp;
begin
  case i of
    eiModemErrExtApp,
    eiInputWdReset,
    eiModemCmdInit,
    eiModemCmdAnswer,
    eiModemCmdPrefix,
    eiModemCmdSuffix,
    eiModemCmdHangup,
    eiModemCmdExit,
    eiRestrictRqd,
    eiRestrictFrb,
    eiAccFilesRqd,
    eiAccFilesFrb,
    eiAccNodesRqd,
    eiAccNodesFrb,
    eiAccLinkRqd,
    eiAccLinkFrb,
    eiTrsFilesRqd,
    eiTrsFilesFrb,
    eiTrsNoCram
     : Result := eptString;

    eiResponseFormat,
    eiInputFormat       : Result := eptDMemo;

    eiInputWdExtApp,
    eiDoor,
    eiPassword          : Result := eptDStr;

    eiRplStation,
    eiRplModem,
    eiRplRestriction    : Result := eptCombo;

    eiAccDurMax,
    eiTrsDurMax,
    eiAccSpeedMin,
    eiTrsSpeedMin,
    eiAccBPSEfMin,
    eiTrsBPSEfMin,
    eiAccCPSMin,
    eiTrsCPSMin,
    eiNumRings,

    eiFreqPwdDur,
    eiFreqPwdSz,
    eiFreqPwdCnt,

    eiFreqPubDur,
    eiFreqPubSz,
    eiFreqPubCnt        : Result := eptSpin;

    eiAccNoFreqs,
    eiAccNoNiagara,
    eiTrsNoNiagara,
    eiAccNoHydra,
    eiTrsNoHydra,
    eiAccNoZmodem,
    eiTrsNoZmodem,
    eiAccNoEMSI,
    eiTrsNoEMSI,
    eiAccNoYooHoo,
    eiTrsNoYooHoo,
    eiAccNoFTS1,
    eiAccNoIncoming,
    eiModemDisaReinit,
    eiAccNoDummyZ,
    eiTrsNoDummyZ,
    eiAccProtected,
    eiAccListed,
    eiAccNoCram,
    eiLogEMSI            : Result := eptVoid;
    eiLoginScript        : Result := eptGrid;
    else
    begin
      GlobalFail('GetEventParamTyp i = %d', [i]);
      Result := eptVoid; // to avoid 'uninitialized' warning
    end;
  end;
end;



constructor TEventAtom.Load(Stream: TxStream);
begin
  Typ := Stream.ReadInteger;
end;

procedure TEventAtom.Store(Stream: TxStream);
begin
  Stream.WriteInteger(Typ);
end;

function TEventAtom.Name: string;
var
  s, z: string;
begin
  s := LngStr(Typ+LngEvtBase);
  GetWrd(s,z,'|');
  Result := z;
end;

procedure PurgeIdColl(Items: TElementColl; var A: PIntArray; var Cnt: Integer);
var
  ns, i, mvs: Integer;
begin
  ns := Cnt;
  for i := Cnt-1 downto 0 do
  begin
    if FindNo(A^[i], Items) = -1 then
    begin
      mvs := (ns-i-1)*SizeOf(Integer);
      if mvs>0 then Move(A^[i+1], A^[i], mvs);
      Dec(ns);
    end;
  end;
  if ns <> cnt then begin ReallocMem(A, ns*SizeOf(Integer)); Cnt := ns end;
end;

procedure TossItems(CA, CB: TColl; Items: TElementColl; var A: PIntArray; var Cnt: Integer);
var
  l: TLineRec;
  AR: array[Boolean] of TColl;
begin
  PurgeIdColl(Items, A, Cnt);
  AR[False] := CA;
  AR[True] := CB;
  while Items.Count > 0 do
  begin
    l := Items[0];
    AR[WithinIntArr(l.Id, A, Cnt)].Insert(l);
    Items.AtDelete(0);
  end;
  Items.Free;
end;

procedure FillListBoxNamed(l: TListBox; c: TColl);
var
  i,ii,li: Integer;
  r: TNamed;
begin
  ii := l.ItemIndex;
  l.Items.Clear;
  li := c.Count-1;
  for i := 0 to li do
  begin
    r := c[i];
    l.Items.Add(r.Name);
  end;
  if ii<>-1 then l.ItemIndex := MinI(ii, li);
end;

constructor TIpEvtIds.Load(Stream: TxStream);
begin
  EvtCnt := Stream.ReadDword;
  if EvtCnt > 0 then
  begin
    GetMem(EvtIds, EvtCnt*SizeOf(Integer));
    Stream.Read(EvtIds^, EvtCnt*SizeOf(Integer));
  end;
  Cfg.SetObj(@Cfg.IpEvtIds, Self);
end;

procedure TIpEvtIds.Store(Stream: TxStream);
begin
  Stream.WriteDword(EvtCnt);
  if EvtCnt > 0 then
  begin
    Stream.Write(EvtIds^, EvtCnt*SizeOf(Integer));
  end;
end;

destructor TIpEvtIds.Destroy;
begin
  if EvtIds <> nil then FreeMem(EvtIds, EvtCnt*SizeOf(Integer));
  inherited Destroy;
end;


function _OvrSort(Item1, Item2: Pointer): Integer;

function ar(i: Integer): string; begin Result := AddRightSpaces(IntToStr(i), 5) end;
function al(i: Integer): string; begin Result := AddLeftSpaces(IntToStr(i), 5) end;

var
  o1: TNodeOvr absolute Item1;
  o2: TNodeOvr absolute Item2;
  a1, a2: TFidoAddress;
begin
  a1 := o1.Addr;
  a2 := o2.Addr;
  Result := CompareStr(al(a1.Zone)+ar(a1.Net)+al(a1.Node)+al(a1.Point), al(a2.Zone)+ar(a2.Net)+al(a2.Node)+al(a2.Point));
end;

constructor TPollOptionsData.Load(Stream: TxStream);
begin
  Stream.Read(d, SizeOf(d));
  Cfg.SetObj(@Cfg.PollOptions, Self)
end;

procedure TPollOptionsData.Store(Stream: TxStream);
begin
  Stream.Write(d, SizeOf(d));
end;

function TPollOptionsData.Copy: Pointer;
var
  r: TPollOptionsData;
begin
  r := TPollOptionsData.Create;
  r.d := d;
  Result := r;
end;

constructor TEncryptedNodeData.Load(Stream: TxStream);
begin
  _GetAddress(Stream, Addr);
  Stream.Read(Key, SizeOf(Key));
end;

procedure TEncryptedNodeData.Store(Stream: TxStream);
begin
  _PutAddress(Stream, Addr);
  Stream.Write(Key, SizeOf(Key));
end;

procedure LoadEncStream(Stream: TxStream; cbc: Boolean; var FStream: TxMemoryStream);
var
  Len: DWORD;
  Chk: Word;
  Key: TDesBlock;
begin
  Len := Stream.ReadDWORD;
  Stream.Read(Chk, SizeOf(Chk));
  if Cfg.MasterKey = 0 then
  begin
    if AskSinglePassword(@Key, Chk) then
    begin
      Move(Key, Cfg.MasterKey, 8);
      Cfg.MasterKeyChk := Chk;
    end else Halt;
  end;
  FStream := GetMemoryStream;
  FStream.SetSize(Len);
  Stream.Read(FStream.Memory^, Len);
  if cbc then xdes_cbc_encrypt_block(FStream.Memory, Len, Cfg.MasterKey, False)
         else xdes_ecb_encrypt_block(FStream.Memory, Len, Cfg.MasterKey, False);

  if not Cfg.DoLoad(FStream) then Stream.GotStarter := False;
  Stream.FreeLastLoaded := True;
end;

constructor TECBEncryptedCfgBlock.Load(Stream: TxStream);
begin
  LoadEncStream(Stream, False, FStream);
end;

constructor TCBCEncryptedCfgBlock.Load(Stream: TxStream);
begin
  LoadEncStream(Stream, True, FStream);
end;

procedure TCBCEncryptedCfgBlock.Store(Stream: TxStream);
var
  zer: array[0..6] of Byte;
  m, Len: Integer;
  Chk: Word;
begin
  m := FStream.Size mod 8;
  if m <> 0 then
  begin
    m := 8-m;
    Clear(zer, m);
    FStream.Write(zer, m);
  end;
  Len := FStream.Size;
  Chk := xdes_md5_crc16(@Cfg.MasterKey, 8);
  Stream.WriteDWORD(Len);
  Stream.Write(Chk, SizeOf(Chk));
  xdes_cbc_encrypt_block(FStream.Memory, Len, Cfg.MasterKey, True);
  Stream.Write(FStream.Memory^, Len);
end;

destructor TECBEncryptedCfgBlock.Destroy;
begin
  FreeObject(FStream);
  inherited Destroy;
end;

destructor TCBCEncryptedCfgBlock.Destroy;
begin
  FreeObject(FStream);
  inherited Destroy;
end;


function TEncryptedNodeData.Copy: Pointer;
var
  r: TEncryptedNodeData;
begin
  r := TEncryptedNodeData.Create;
  r.Addr := Addr;
  r.key := Key;
  Result := r;
end;

function TEncryptedNodeColl.Copy;
var
  r: TEncryptedNodeColl;
begin
  r := TEncryptedNodeColl.Create;
  CopyItemsTo(r);
  Result := r;
end;


function TEncryptedNodeColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TEncryptedNodeData(Item).Addr;
end;

function TEncryptedNodeColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := CompareAddrs(PFidoAddress(Key1)^, PFidoAddress(Key2)^);
end;

function EncNodeSort(p1, p2: Pointer): Integer;
begin
  Result := CompareAddrs(TEncryptedNodeData(p1).Addr, TEncryptedNodeData(p2).Addr);
end;

constructor TRestrictionData.Create;
begin
  inherited Create;
  Required := TStringColl.Create;
  Forbidden := TStringColl.Create;
end;

constructor TRestrictionData.Load(Stream: TxStream);
begin
  Required := Stream.Get;
  Forbidden := Stream.Get;
end;

procedure TRestrictionData.Store(Stream: TxStream);
begin
  Stream.Put(Required);
  Stream.Put(Forbidden);
end;

function TRestrictionData.Copy: Pointer;
var
  r: TRestrictionData;
begin
  r := TRestrictionData.Create;
  Required.CopyItemsTo(r.Required);
  Forbidden.CopyItemsTo(r.Forbidden);
  Result := r;
end;

destructor TRestrictionData.Destroy;
begin
  FreeObject(Required);
  FreeObject(Forbidden);
  inherited Destroy;
end;

function ValidRestrictionColl;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to CollMax(SC) do
  begin
    if not ValidRestrictEntry(SC[i], AMsgs, AScope) then
    begin
      Result := False;
      Break;
    end;
  end;
end;

function ValidDialupRestrictionData;
var
  R, F: TStringColl;
  ValidReqd, ValidForbd: Boolean;
  s: string;
begin
  Result := False;
  R := TStringColl.Create;
  F := TStringColl.Create;
  ValidReqd := ValidRestrictionColl(AR.Required, R, rspDialup);
  ValidForbd := ValidRestrictionColl(AR.Forbidden, F, rspDialup);
  Result := ValidReqd and ValidForbd;
  if not Result then
  begin
    s := '';
    if not ValidReqd  then s := s + FormatLng(rsDRestInvReq, [Trim(R.LongString)])+#13#10#13#10;
    if not ValidForbd then s := s + FormatLng(rsDRestInvFrb, [Trim(F.LongString)])+#13#10#13#10;
    DisplayError(s, Handle);
  end;
  FreeObject(R);
  FreeObject(F);
end;

constructor TRestrictionRec_v3050.Load(Stream: TxStream);

function ReadnValidateDialup: string;
begin
  Result := Stream.ReadStr;
  if not ValidRestrictEntry(Result, nil, rspDialup) then
    Result := '';
end;

begin
  inherited Load(Stream);
  Required := ReadnValidateDialup;
  Forbidden := ReadnValidateDialup;
end;

procedure OldRestrictionStrs2NewData(const Required, Forbidden: string; AData: TRestrictionData);
var
  s, z: string;
begin
  AData.Required.Add(Trim(Required));
  s := Trim(Forbidden);
  while s <> '' do
  begin
    GetWrd(s, z, ' ');
    AData.Forbidden.Ins(z);
  end;
end;


function TRestrictionRec_v3050.Upgrade: TRestrictionRec;
begin
  Result := TRestrictionRec.Create;
  Result.FName := FName;
  Result.Id := Id;
  OldRestrictionStrs2NewData(Required, Forbidden, Result.Data);
  Cfg.AddUpgStringLng(rsRecsDupGR);
end;


function TIPRec_v3075.Upgrade: TIPRec;
begin
  Result := TIPRec.Create;
  Result.Banner := Banner;
  OldRestrictionStrs2NewData(Restriction.Required, Restriction.Forbidden, Result.Restriction);
  XChg(Integer(Result.InPorts), Integer(InPorts)); FreeObject(InPorts);
  XChg(Integer(Result.StationData), Integer(StationData)); FreeObject(StationData);
  Result.InC := InC;
  Result.OutC := OutC;
  Result.Speed := Speed;
  Cfg.AddUpgStringLng(rsRecsTCPGR);
end;

procedure TIPRec_v3075.Store(Stream: TxStream);
begin
  GlobalFail('%s', ['TIPRec_v3075.Store']);
end;



constructor TIPRec_v3075.Load(Stream: TxStream);

function ReadnValidate: string;
begin
  Result := Stream.ReadStr;
  if not ValidRestrictEntry(Result, nil, rspIP) then
    Result := '';
end;

begin
  InPorts := TInPortsColl(Stream.Get);
  StationData := TStationDataColl(Stream.Get);
  Restriction := TOldIPRestriction.Create;
  Restriction.Required := ReadnValidate;
  Restriction.Forbidden := ReadnValidate;
  InC := Stream.ReadDword;
  OutC := Stream.ReadDword;
  Speed := Stream.ReadDword;
  Stream.Read(Options, SizeOf(Options));
  Banner := Stream.ReadStr;
  Cfg.SetObj(@Cfg.IpData, Upgrade);
  Stream.FreeLastLoaded := True;
end;


destructor TIPRec_v3075.Destroy;
begin
  FreeObject(InPorts);
  FreeObject(StationData);
  FreeObject(Restriction);
  inherited Destroy;
end;

procedure UpdateGlobalEvtUpdateFlag;
begin
  GlobalEvtUpdateTick := TickCounter+1;
end;

constructor TExtPoll.Load(Stream: TxStream);
begin
  FAddrs := Stream.ReadStr;
  FOpts := Stream.ReadStr;
  FCmd := Stream.ReadStr;
end;

procedure TExtPoll.Store(Stream: TxStream);
begin
  Stream.WriteStr(FAddrs);
  Stream.WriteStr(FOpts);
  Stream.WriteStr(FCmd);
end;

function TExtPoll.Copy: Pointer;
var
  r: TExtPoll;
begin
  r := TExtPoll.Create;
  r.FAddrs := StrAsg(FAddrs);
  r.FOpts := StrAsg(FOpts);
  r.FCmd := StrAsg(FCmd);
  Result := r;
end;

function ValidAKAGrid(A: Pointer): Boolean;
var
  gAKA: TAdvGrid absolute A;
  i: Integer;
  s: string;
  Handle: THandle;
begin
  Result := False;
  Handle := TForm(gAKA.Owner).Handle;
  for I := 1 to gAKA.RowCount-1 do
  begin
    S := gAKA[1,I];
    if S = '' then
    begin
      if gAKA.RowCount = 2 then Result := True else DisplayErrorFmtLng(rsPswEmptyAdr, [I], Handle);
      Exit;
    end;
    if not ValidMaskAddressList(s, Handle) then Exit;
    if not ValidateAddrs(gAKA[2,I], Handle) then Exit;
  end;
  Result := True;
end;

function ConfigFName: string;
begin
  Result := MakeNormName(HomeDir, CfgFName);
end;

var
  CfgCCC: Integer;

procedure CfgEnter;
begin
  Cfg.Enter;
  Inc(CfgCCC);
end;

procedure CfgLeave;
begin
  Dec(CfgCCC);
  Cfg.Leave;
  if CfgCCC < 0 then
  GlobalFail('%s', ['Unexpected CfgLeave!']);
end;

function ExpandSuperMask(const AMask: string): string;
begin
  Result := AMask;
  ReplaceCI('%ARCMAIL%', '*.su? *.mo? *.tu? *.we? *.th? *.fr? *.sa?', Result);
  ReplaceCI('%FRIPMAIL%', '*.rip *.riz *.rif', Result);
end;

function ReplaceDirMacro(const AStr: string; Addr: PFidoAddress; AStatus: POutStatus; AOps: TReplaceMacroOpSet; AResultMacro: PDirMacro): string;
const
  SDirMacro: array[TDirMacro] of string = (
  'YEAR', 'MONTHN', 'MONTHA', 'MONTHS', 'DAY', 'HOUR', 'MINUTE', 'SECOND', 'DOWN', 'DOWA', 'DOWS',
  'ZONE', 'NET', 'NODE', 'POINT', 'HZONE', 'HNET', 'HNODE', 'HPOINT',
  'XZONE', 'XNET', 'XNODE', 'XPOINT', 'STATUS', 'TSTATUS');

var
  LT: TSystemTime;
  TimeGot: Boolean;

function GetValue(A: TDirMacro): string;
var
  s: string;
begin
  case A of
    dmYEAR..dmDOWS:
      begin
        if not TimeGot then
        begin
          TimeGot := True;
          GetLocalTime(LT);
        end;
        case A of
          dmYEAR    : s := Format('%d',     [LT.wYear]);
          dmMONTHN  : s := Format('%.2d',   [LT.wMonth]);
          dmMONTHA  : s := MonthE(           LT.wMonth);
          dmMONTHS  : s := MonthE2(          LT.wMonth);
          dmDAY     : s := Format('%.2d',   [LT.wDay]);
          dmHOUR    : s := Format('%.2d',   [LT.wHour]);
          dmMINUTE  : s := Format('%.2d',   [LT.wMinute]);
          dmSECOND  : s := Format('%.2d',   [LT.wSecond]);
          dmDOWN    : s := Format('%d',     [LT.wDayOfWeek]);
          dmDOWA    : s := DOWE(             LT.wDayOfWeek);
          dmDOWS    : s := DOWE2(            LT.wDayOfWeek);
          else
            GlobalFail('%s', ['Unexpected date macro in ReplaceDirMacro']);
        end;
      end;
    dmZONE..dmXPOINT:
      begin
        if Addr = nil then s := #1 else
        case A of
          dmZONE    : s := Format('%d',     [Addr.Zone] );
          dmNET     : s := Format('%d',     [Addr.Net]  );
          dmNODE    : s := Format('%d',     [Addr.Node] );
          dmPOINT   : s := Format('%d',     [Addr.Point]);
          dmHZONE   : s := Hex3(             Addr.Zone  );
          dmHNET    : s := Hex4(             Addr.Net   );
          dmHNODE   : s := Hex4(             Addr.Node  );
          dmHPOINT  : s := Hex4(             Addr.Point );
          dmXZONE   : s := H32_2(            Addr.Zone  );
          dmXNET    : s := H32_3(            Addr.Net   );
          dmXNODE   : s := H32_3(            Addr.Node  );
          dmXPOINT  : s := H32_2(            Addr.Point );
          else
            GlobalFail('%s', ['Unexpected address macro in ReplaceDirMacro']);
        end;
      end;
    else
      begin
        if AStatus = nil then s := #1 else
        case A of
          dmSTATUS  : s := OutStatus2Char(AStatus^);
          dmTSTATUS : s := OutStatus2StrTMail(AStatus^);
          else
            GlobalFail('%s', ['Unexpected macro in ReplaceDirMacro']);
        end;
      end;
   end;
   Result := s;
end;


var
  s: string;

function IntReplace(const APatternIdx: TDirMacro): Boolean;
var
  I, J, LP, LR: Integer;
  ReplaceString, Pattern: string;
  GotReplaceString: Boolean;

begin
  Result := False;
  GotReplaceString := False;
  J := 1;
  LR := 0;
  Pattern := '%'+SDirMacro[APatternIdx];
  LP := Length(Pattern);
  repeat
    I := Pos(Pattern, UpperCase(CopyLeft(S, J)));
    if I = 0 then Break;
    Delete(S, J+I-1, LP);
    if not GotReplaceString then
    begin
      GotReplaceString := True;
      ReplaceString := GetValue(APatternIdx);
      LR := Length(ReplaceString);
    end;
    Insert(ReplaceString, S, J+I-1);
    Result := True;
    if rmkOnce in AOps then Break;
    Inc(J, I + LR - 1);
  until False;
end;

var
  i: TDirMacro;
  j: Integer;
  Prefix, Suffix: string;
  IntReplaced: Boolean;
begin
  j := Pos('%', AStr);
  Prefix := '';
  Suffix := '';
  if j = 0 then
  begin
    Result := AStr;
    Exit;
  end;

  s := AStr;

  if rmkOnce in AOps then
  begin
    Prefix := Copy(s, 1, j-1);
    Delete(s, 1, j-1);
    j := Pos('%', CopyLeft(s, 2));
    if j > 0 then
    begin
      Suffix := CopyLeft(s, j+1);
      s := Copy(s, 1, j);
    end;
  end;

  IntReplaced :=
    ReplaceCI('%STMAIL', '%XZONE%XNET%XNODE.%XPOINT%TSTATUS', s) or
    ReplaceCI('%LTMAIL', '%ZONE.%NET.%NODE.%POINT~/\x2E{0,1}/%TSTATUS', s);


  TimeGot := False;

  if not (IntReplaced and (rmkOnce in AOps)) then
  for i := Low(TDirMacro) to High(TDirMacro) do
  begin
    case i of
      dmYEAR..dmDOWS:
        if not (rmkTime in AOps) then Continue;
      dmZONE..dmXPOINT:
        if not (rmkAddr in AOps) then Continue;
      dmSTATUS..dmTSTATUS:
        if not (rmkStatus in AOps) then Continue;
    end;
    if IntReplace(i) then
    begin
      if rmkOnce in AOps then
      begin
        if AResultMacro <> nil then AResultMacro^ := i;
        Break;
      end;
    end;
  end;
  Result := Prefix+s+Suffix;
end;

function GetInboundDir(const Addr: TFidoAddress; const FName: string; APasswordProtected: Boolean; var APutKind: TInboundPutKind): string;
var
  ca, cb: TStringColl;
  s, sb, z: string;
  i: Integer;
  Got: Boolean;
begin
  APutKind := ipkQueue;
  Got := False;
  ca := TStringColl.Create;
  cb := TStringColl.Create;
  CfgEnter;
  if APasswordProtected then Result := Cfg.PathNames.InSecure else
                             Result := Cfg.PathNames.InCommon;

  Cfg.ExtCollA.AppendTo(ca);
  Cfg.ExtCollB.AppendTo(cb);
  CfgLeave;

  for i := 0 to MinI(ca.Count, cb.Count)-1 do
  begin
    sb := Trim(cb[i]);
    if sb = '' then Continue;
    if sb[1] <> '&' then Continue;
    s := ExpandSuperMask(Trim(ca[i]));
    while (s <> '') and (not Got) do
    begin
      GetWrd(s, z, ' ');
      if ValidMaskAddress(z) then
      begin
        Got := (APasswordProtected or ValidAddress(z)) and MatchMaskAddress(Addr, z);
      end else
      begin
        Got := MatchMask(FName, z);
      end;
    end;
    if Got then Break;
  end;
  FreeObject(ca);
  FreeObject(cb);
  if Got then
  begin
    DelFC(sb);
    if (sb <> '') and (sb[1] = '^') then
    begin
      APutKind := ipkOverwrite;
      DelFC(sb);
    end;
    Result := ReplaceDirMacro(sb, @Addr, nil, [rmkTime, rmkAddr], nil);
  end;
  Result := FullPath(Result);
end;

constructor TProxyData.Load(Stream: TxStream);
begin
  Enabled := Stream.ReadBool;
  Addr := Stream.ReadStr;
  Port := Stream.ReadDword;
  Cfg.SetObj(@Cfg.Proxy, Self);
end;

procedure TProxyData.Store(Stream: TxStream);
begin
  Stream.WriteBool(Enabled);
  Stream.WriteStr(Addr);
  Stream.WriteDword(Port);
end;

constructor TInstallRec.Load(Stream: TxStream);
begin
  InstallDay := Stream.ReadDword;
  Cfg.SetObj(@Cfg.InstallRec, Self);
end;

procedure TInstallRec.Store(Stream: TxStream);
begin
  Stream.WriteDword(InstallDay);
end;

constructor TFileBoxCfg.Load(Stream: TxStream);
begin
  Stream.Read(FStatus, SizeOf(FStatus));
  FAddr := Stream.ReadStr;
  FDir := Stream.ReadStr;
end;

procedure TFileBoxCfg.Store(Stream: TxStream);
begin
  Stream.Write(FStatus, SizeOf(FStatus));
  Stream.WriteStr(FAddr);
  Stream.WriteStr(FDir);
end;

function TFileBoxCfg.Copy: Pointer;
var
  r: TFileBoxCfg;
begin
  r := TFileBoxCfg.Create;
  r.FAddr := StrAsg(FAddr);
  r.FStatus := FStatus;
  r.FDir := StrAsg(FDir);
  Result := r;
end;

function TFileBoxCfg.Dir(const ADef: string; I: Integer): string;
var
  s, z: string;
  J: Integer;
begin
  s := FDir;
  for J := 0 to I do GetWrd(s, z, '|');
  if z = '' then Result := '' else Result := MakeFullDir(ADef, z);
end;

function TFileBoxCfg.KillAction: TKillAction;
begin
  if Pos('|', FDir) > 0 then Result := kaFbMoveAfter else Result := kaFbKillAfter;
end;


constructor TFileBoxCfgColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  DefaultDir := Stream.ReadStr;
  Cfg.SetObj(@Cfg.FileBoxes, Self);
end;

procedure TFileBoxCfgColl.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteStr(DefaultDir);
end;

function TFileBoxCfgColl.Copy: Pointer;
var
  r: TFileBoxCfgColl;
begin
  r := TFileBoxCfgColl.Create;
  CopyItemsTo(r);
  r.DefaultDir := StrAsg(DefaultDir);
  Copied := True;
  Result := r;
end;

procedure ReportRestrictionColl(Strs, Rst: TStringColl; AFrb: Boolean);
const
  RReq: array[Boolean] of Integer = (rsRecsRepRReq, rsRecsRepRFrb);
var
  L: TColl;
  i, ii, j, k: Integer;
  ri: TRestrictItem;
  s: string;
begin
  ii := CollMax(Rst);
  for i := 0 to ii do
  begin
    if i = 0 then
    begin
      Strs.Add(LngStr(RReq[AFrb]));
      Strs.Add('');
    end;
    L := ParseRestrictStr(Rst[i], nil);
    k := CollMax(L);
    if k < 0 then Strs.Add(LngStr(rsRecsRepRNone)) else
    s := '';
    for j := 0 to k do
    begin
      ri := L[j];
      if s <> '' then s := s + LngStr(rsRecsRepRAnd);
      case ri.Typ of
        oiAddress:
          s := FormatLng(rsRecsRepRA, [s, Addr2Str(ri.Addr)]);
        oiAddressMask:
          s := FormatLng(rsRecsRepRAM, [s, ri.S]);
        oiFlag:
          s := FormatLng(rsRecsRepRFlg , [s, ri.S]);
        oiInvFlag:
          s := FormatLng(rsRecsRepRIFlg, [s, ri.S]);
        oiPhoneNum:
          s := FormatLng(rsRecsRepRPhnPfx, [s, ri.S]);
        oiIPNum:
          s := FormatLng(rsRecsRepRIpNum, [s, ri.S]);
        oiIPSym:
          s := FormatLng(rsRecsRepRIpSym, [s, ri.S]);
      end;
    end;
    FreeObject(L);
    if i < ii then s := s + LngStr(rsRecsRepROr);
    Strs.Add(s);
  end;
  Strs.Add('');
end;

procedure ReportRestrictionData(Strs: TStringColl; AData: TRestrictionData);
begin
  ReportRestrictionColl(Strs, AData.Required, False);
  ReportRestrictionColl(Strs, AData.Forbidden, True);
end;

function TNodeWizzardColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := CompareAddrs(TFidoAddress(Key1^), TFidoAddress(Key2^));
end;

function TNodeWizzardColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TNodeWizzardRec(Item).A;
end;

procedure FindAddrsInRestriction(AC: TStringColl; A: TFidoAddrColl);
var
  i, j, ps: Integer;
  C: TColl;
  ri: TRestrictItem;
begin
  for i := 0 to AC.Count-1 do
  begin
    C := ParseRestrictStr(AC[i], nil);
    for j := 0 to CollMax(C) do
    begin
      ri := C[j];
      if ri.Typ <> oiAddress then Continue;
      if not A.Search(@ri.Addr, ps) then A.AtInsert(ps, NewFidoAddr(ri.Addr));
    end;
    FreeObject(C);
  end;
end;

procedure FindAddrsInAKA(AC: TStringColl; A: TFidoAddrColl);
var
  aa: TFidoAddress;
  i, ps: Integer;
begin
  for i := 0 to AC.Count-1 do
  begin
    if not ParseAddress(AC[i], aa) then Continue;
    if not A.Search(@aa, ps) then A.AtInsert(ps, NewFidoAddr(aa));
  end;
end;

procedure BuildNodeWizzardColl;
var
  r: TNodeWizzardRec;

procedure MakeRec(const AAddr: TFidoAddress);
var
  ps: Integer;
begin
  if FColl.Search(@AAddr, ps) then r := FColl[ps] else
  begin
    r := TNodeWizzardRec.Create;
    r.A := AAddr;
    FColl.AtInsert(ps, r);
  end;
end;

var
  i, j, k: Integer;
  pr: TPasswordRec;
  al: TFidoAddrColl;
  no: TNodeOvr;
  en: TEncryptedNodeData;
  rr: TRestrictionRec;
  sr: TStationRec;
  ec: TEventContainer;
  ea: TEventAtom;
  sc: TStringColl;
  ep: TExtPoll;
  pp: TPerPollRec;
  fc: TFileBoxCfg;
  s: string;
begin

  if ABuildStrings then
  begin

    for i := 0 to Cfg.Passwords.Count-1 do
    begin
      pr := Cfg.Passwords[i];
      al := pr.AddrList;
      for j := 0 to al.Count-1 do
      begin
        MakeRec(al[j]);
        r.Password := pr.PswStr;
      end;
    end;
    for i := 0 to Cfg.DialupNodeOverrides.Count-1 do
    begin
      no := Cfg.DialupNodeOverrides[i];
      MakeRec(no.Addr);
      r.DupOvr := no.Ovr;
    end;
    for i := 0 to Cfg.IpNodeOverrides.Count-1 do
    begin
      no := Cfg.IpNodeOverrides[i];
      MakeRec(no.Addr);
      r.IpOvr := no.Ovr;
    end;
    for i := 0 to Cfg.PerPolls.Count-1 do
    begin
      pp := Cfg.PerPolls[i];
      al := pp.AddrList; //CreateAddrCollEx(Cfg.PerPollsB[i], True);
      if al = nil then Continue;
//      s := Cfg.PerPollsA[i];
      for j := 0 to al.Count-1 do
      begin
        MakeRec(al[j]);
        r.PollPer := pp.Cron;
      end;
    end;
    for i := 0 to Cfg.ExtPolls.Count-1 do
    begin
      ep := Cfg.ExtPolls[i];
      al := CreateAddrCollEx(ep.FAddrs, True);
      for j := 0 to CollMax(al) do
      begin
        MakeRec(al[j]);
        r.PollExt := ep.FOpts + '|' + ep.FCmd;
      end;
      FreeObject(al);
    end;
    for i := 0 to Cfg.ExtCollA.Count-1 do
    begin
      al := CreateAddrCollEx(Cfg.ExtCollA[i], True);
      if al = nil then Continue;
      s := Trim(Cfg.ExtCollB[i]);
      if s = '' then Continue;
      for j := 0 to al.Count-1 do
      begin
        MakeRec(al[j]);
        if s[1] = '&' then r.FBoxIn := CopyLeft(s, 2) else r.PostProc := s;
      end;
      FreeObject(al);
    end;
    for i := 0 to Cfg.Fileboxes.Count-1 do
    begin
      fc := Cfg.Fileboxes[i];
      al := CreateAddrCollEx(fc.FAddr, True);
      if al = nil then Continue;
      for j := 0 to al.Count-1 do
      begin
        MakeRec(al[j]);
        r.FBoxOut := OutStatus2Char(fc.FStatus) + '|' + fc.FDir;
      end;
      FreeObject(al);
    end;
  end else
  begin
    for i := 0 to FColl.Count-1 do
    begin
      r := FColl[i];
      r.FreeIds;
      r.IsDaemonRest := False;
      r.IsDaemonAKA := False;
      r.IsEncryptedLink := False;
    end;
  end;

  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    en := Cfg.EncryptedNodes[i];
    MakeRec(en.Addr);
    r.IsEncryptedLink := True;
  end;

  al := TFidoAddrColl.Create;
  FindAddrsInRestriction(Cfg.IpData.Restriction.Required, al);
  FindAddrsInRestriction(Cfg.IpData.Restriction.Forbidden, al);
  for i := 0 to al.Count-1 do
  begin
    MakeRec(al[i]);
    r.IsDaemonRest := True;
  end;
  FreeObject(al);

  for i := 0 to Cfg.Restrictions.Count-1 do
  begin
    rr := Cfg.Restrictions[i];
    al := TFidoAddrColl.Create;
    FindAddrsInRestriction(rr.Data.Required, al);
    FindAddrsInRestriction(rr.Data.Forbidden, al);
    for j := 0 to al.Count-1 do
    begin
      MakeRec(al[j]);
      if r.DialRestIds = nil then r.DialRestIds := TColl.Create;
      if r.DialRestIds.IndexOf(Pointer(rr.id)) < 0 then r.DialRestIds.Add(Pointer(rr.id));
      r.IsDaemonRest := True;
    end;
    FreeObject(al);
  end;

  al := TFidoAddrColl.Create;
  FindAddrsInAKA(Cfg.IpAkaCollA, al);
  for i := 0 to al.Count-1 do
  begin
    MakeRec(al[i]);
    r.IsDaemonAKA := True;
  end;

  for i := 0 to Cfg.Station.Count-1 do
  begin
    sr := Cfg.Station[i];
    al := TFidoAddrColl.Create;
    FindAddrsInAKA(sr.AkaA, al);
    for j := 0 to al.Count-1 do
    begin
      MakeRec(al[j]);
      if r.AkaStationIds = nil then r.AkaStationIds := TColl.Create;
      if r.AkaStationIds.IndexOf(Pointer(sr.id)) < 0 then r.AkaStationIds.Add(Pointer(sr.id));
    end;
    FreeObject(al);
  end;

  for i := 0 to Cfg.Events.Count-1 do
  begin
    ec := Cfg.Events[i];
    for j := 0 to ec.Atoms.Count-1 do
    begin
      ea := ec.Atoms[j];
      case ea.Typ of
        eiRestrictRqd,
        eiRestrictFrb:
          begin
            al := TFidoAddrColl.Create;
            sc := TStringColl.Create;
            sc.Add(TEvParString(ea).s);
            FindAddrsInRestriction(sc, al);
            FreeObject(sc);
          end;
        eiAccNodesRqd,
        eiAccNodesFrb:
          begin
            al := CreateAddrCollEx(TEvParString(ea).s, True);
          end;
//        eiNodeOverride,
        eiPassword:
          begin
            al := CreateAddrCollEx(TEvParDStr(ea).StrA, True);
          end;
      end;
      for k := 0 to CollMax(al) do
      begin
        MakeRec(al[k]);
        if r.EvtIds = nil then r.EvtIds := TColl.Create;
        if r.EvtIds.IndexOf(Pointer(ec.id)) < 0 then r.EvtIds.Add(Pointer(ec.id));
      end;
      FreeObject(al);
    end;
  end;
end;

procedure TNodeWizzardRec.FreeIds;
begin
  if EvtIds <> nil then begin EvtIds.DeleteAll; FreeObject(EvtIds) end;
  if DialRestIds <> nil then begin DialRestIds.DeleteAll; FreeObject(DialRestIds) end;
  if AkaStationIds <> nil then begin AkaStationIds.DeleteAll; FreeObject(AkaStationIds) end;
end;

destructor TNodeWizzardRec.Destroy;
begin
  FreeIds;
  FinalizeStrs;
  inherited Destroy;
end;


procedure SaveNodeWizzardColl(AColl: TNodeWizzardColl; ARec: TNodeWizzardRec);

var
  r: TNodeWizzardRec;

function MakeRec(const AAddr: TFidoAddress): Boolean;
var
  ps: Integer;
begin
  if ARec = nil then           
  begin
    if AColl.Search(@AAddr, ps) then r := AColl[ps] else r := nil;
  end else
  begin
    if CompareAddrs(AAddr, ARec.A) = 0 then r := ARec else r := nil;
  end;
  Result := r <> nil;
  if Result then r.Found := True;
end;

var
  pr: TPasswordRec;
  no: TNodeOvr;
  en: TEncryptedNodeData;
  ep: TExtPoll;
  fc: TFileBoxCfg;
  pp: TPerPollRec;
  a: TFidoAddress;
  i, j: Integer;
  al: TFidoAddrColl;
  s, z, w, v: string;

procedure CndAddPwd;
begin
  if r.Password = '' then Exit;
  pr := TPasswordRec.Create;
  pr.AddrList.Add(r.A);
  pr.PswStr := StrAsg(r.Password);
  Cfg.Passwords.Add(pr);
end;

procedure CndAddExtPoll;
begin
  s := r.PollExt;
  GetWrd(s, z, '|');
  if (Trim(z) = '') or (Trim(s) = '') then Exit;
  ep := TExtPoll.Create;
  ep.FAddrs := Addr2Str(r.a);
  ep.FOpts := z;
  ep.FCmd := s;
  Cfg.ExtPolls.Add(ep);
end;

procedure CndAddPerPoll;
begin
  if r.PollPer = '' then Exit;
  pp := TPerPollRec.Create;
  pp.AddrList.Add(r.a);
  pp.Cron := r.PollPer;
  Cfg.PerPolls.Add(pp);
end;

procedure CndAddPostProc;
begin
  if r.PostProc = '' then Exit;
  Cfg.ExtCollA.Add(Addr2Str(r.a));
  Cfg.ExtCollB.Add(r.PostProc);
end;

procedure CndAddFboxIn;
begin
  if r.FboxIn = '' then Exit;
  Cfg.ExtCollA.Add(Addr2Str(r.a));
  Cfg.ExtCollB.Add('&'+r.FboxIn);
end;


begin
  CfgEnter;

  for i := Cfg.Passwords.Count-1 downto 0 do
  begin
    pr := Cfg.Passwords[i];
    al := pr.AddrList;
    for j := al.Count-1 downto 0 do
    begin
      if not MakeRec(al[j]) then Continue;
      if r.Password = pr.PswStr then Continue;
      if al.Count = 1 then
      begin
        if r.Password = '' then
        begin
          Cfg.Passwords.AtFree(i);
        end else
        begin
          pr.PswStr := StrAsg(r.Password);
        end;
      end else
      begin
        al.AtFree(j);
        CndAddPwd;
      end;
    end;
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then r.Found := False else CndAddPwd;
  end;

  for i := Cfg.ExtPolls.Count - 1 downto 0 do
  begin
    ep := Cfg.ExtPolls[i];
    s := Trim(ep.FAddrs);
    if ParseAddress(s, a) then
    begin
      if not MakeRec(a) then Continue;
      s := r.PollExt;
      GetWrd(s, z, '|');
      if (Trim(z) = '') or (Trim(s) = '') then Cfg.ExtPolls.AtFree(i) else
      begin
        ep.FOpts := z;
        ep.FCmd := s;
      end;
    end else
    begin
      ep.FAddrs := '';
      while s <> '' do
      begin
        GetWrd(s, z, ' ');
        if ParseAddress(z, a) and
           MakeRec(a) and
           (ep.FOpts + '|' + ep.FCmd <> r.PollExt) then
        begin
          CndAddExtPoll;
        end else
        begin
          if ep.FAddrs <> '' then ep.FAddrs := ep.FAddrs + ' ';
          ep.FAddrs := ep.FAddrs + ' ' + z;
        end;
      end;
      if ep.FAddrs = '' then Cfg.ExtPolls.AtFree(i);
    end;
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then r.Found := False else CndAddExtPoll;
  end;

  for i := Cfg.PerPolls.Count-1 downto 0 do
  begin
    pp := Cfg.PerPolls[i];
//    al := CreateAddrCollEx(Cfg.PerPollsB[i], True);
    al := pp.AddrList;
    if al = nil then Continue;
    if al.Count = 1 then
    begin
      if not MakeRec(al[0]) then Continue;
      if r.PollPer = '' then
      begin
        Cfg.PerPolls.AtFree(i);
//        Cfg.PerPollsA.AtFree(i);
//        Cfg.PerPollsB.AtFree(i);
      end else
      begin
        pp.Cron := r.PollPer;
      end;
      Continue;
    end;
    s := pp.Cron;
    for j := al.Count-1 downto 0 do
    begin
      if (not MakeRec(al[j])) or (r.PollPer = s) then Continue;
      al.AtFree(j);
      CndAddPerPoll;
    end;
    if al.Count = 0 then
    begin
      Cfg.PerPolls.AtFree(i);
    end;
{    begin
      XChg(Integer(pp.AddrList), Integer(al));
    end;
    FreeObject(al);}
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then r.Found := False else CndAddPerPoll;
  end;

  for i := Cfg.FileBoxes.Count-1 downto 0 do
  begin
    fc := Cfg.FileBoxes[i];
    if (not ParseAddress(fc.FAddr, a)) or
       (not MakeRec(a)) or
       ((OutStatus2Char(fc.FStatus) + '|' + fc.FDir) = r.FBoxOut) then Continue;
    s := r.FBoxOut;
    GetWrd(s, z, '|');
    if (s = '') or (z = '') then
    begin
      Cfg.FileBoxes.AtFree(i);
      Continue;
    end;
    fc.FStatus := Char2OutStatus(z[1]);
    fc.FDir := s;
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then begin r.Found := False; Continue end;
    s := r.FBoxOut;
    GetWrd(s, z, '|');
    if (s = '') or (z = '') then Continue;
    fc := TFileBoxCfg.Create;
    fc.FAddr := Addr2Str(r.A);
    fc.FStatus := Char2OutStatus(z[1]);
    fc.FDir := s;
  end;
                 
  for i := Cfg.ExtCollA.Count-1 downto 0 do
  begin
    v := Trim(Cfg.ExtCollB[i]);
    if v = '' then Continue;
    if v[1] = '&' then Continue; // skip incoming fileboxes, need post-proc. only
    s := Cfg.ExtCollA[i];
    w := '';
    while s <> '' do
    begin
      GetWrd(s, z, ' ');
      if ParseAddress(z, a) and
         MakeRec(a) and
         (v <> r.PostProc) then
      begin
        CndAddPostProc;
      end else
      begin
        if w <> '' then w := w + ' ';
        w := w + z;
      end;
    end;
    if w = '' then
    begin
      Cfg.ExtCollA.AtFree(i);
      Cfg.ExtCollB.AtFree(i);
    end else
    begin
      Cfg.ExtCollA[i] := w;
    end;
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then r.Found := False else CndAddPostProc;
  end;


  for i := Cfg.ExtCollA.Count-1 downto 0 do
  begin
    v := Trim(Cfg.ExtCollB[i]);
    if v = '' then Continue;
    if v[1] <> '&' then Continue; // skip post-proc, need incoming fileboxes only
    DelFC(v);
    s := Cfg.ExtCollA[i];
    w := '';
    while s <> '' do
    begin
      GetWrd(s, z, ' ');
      if ParseAddress(z, a) and
         MakeRec(a) and
         (v <> r.FBoxIn) then
      begin
        CndAddFboxIn;
      end else
      begin
        if w <> '' then w := w + ' ';
        w := w + z;
      end;
    end;
    if w = '' then
    begin
      Cfg.ExtCollA.AtFree(i);
      Cfg.ExtCollB.AtFree(i);
    end else
    begin
      Cfg.ExtCollA[i] := w;
    end;
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then r.Found := False else CndAddFboxIn;
  end;


  for i := Cfg.DialupNodeOverrides.Count-1 downto 0 do
  begin
    no := Cfg.DialupNodeOverrides[i];
    MakeRec(no.Addr);
    if r = nil then Continue;
    r.Found := True;
    if r.DupOvr = no.Ovr then Continue;
    if r.DupOvr = '' then Cfg.DialupNodeOverrides.AtFree(i) else no.Ovr := StrAsg(r.DupOvr);
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then begin r.Found := False; Continue end;
    if r.DupOvr = '' then Continue;
    no := TNodeOvr.Create;
    no.Addr := r.A;
    no.Ovr := StrAsg(r.DupOvr);
    Cfg.DialupNodeOverrides.Add(no);
  end;

  for i := Cfg.IpNodeOverrides.Count-1 downto 0 do
  begin
    no := Cfg.IpNodeOverrides[i];
    MakeRec(no.Addr);
    if r = nil then Continue;
    r.Found := True;
    if r.IpOvr = no.Ovr then Continue;
    if r.IpOvr = '' then Cfg.IpNodeOverrides.AtFree(i) else no.Ovr := StrAsg(r.IpOvr);
  end;

  for i := 0 to CollMax(AColl) do
  begin
    r := AColl[i];
    if r.Found then begin r.Found := False; Continue end;
    if r.IpOvr = '' then Continue;
    no := TNodeOvr.Create;
    no.Addr := r.A;
    no.Ovr := StrAsg(r.IpOvr);
    Cfg.IpNodeOverrides.Add(no);
  end;

  for i := Cfg.EncryptedNodes.Count-1 downto 0 do
  begin
    en := Cfg.EncryptedNodes[i];
    MakeRec(en.Addr);
    if r = nil then Continue;
    if r.IsEncryptedLink then Continue;
    Cfg.EncryptedNodes.AtFree(i);
  end;

  if ARec <> nil then ARec.Found := False;

  CfgLeave;

end;

procedure TNodeWizzardRec.FinalizeStrs;
begin
  Finalize(DupOvr);
  Finalize(IpOvr);
  Finalize(Password);
  Finalize(FBoxOut);
  Finalize(FBoxIn);
  Finalize(PollPer);
  Finalize(PollExt);
  Finalize(PostProc);
end;

constructor TLineColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.Lines, Self);
end;

constructor TStationColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.Station, Self);
end;

constructor TPortColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.Ports, Self);
end;

constructor TModemColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.Modems, Self);
end;

constructor TRestrictColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.Restrictions, Self);
end;

constructor TDialupNodeOvrColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.DialupNodeOverrides, Self);
end;

constructor TIPNodeOvrColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.IPNodeOverrides, Self);
end;


constructor TExtCollA.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.ExtCollA, Self);
end;

constructor TExtCollB.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.ExtCollB, Self);
end;

constructor TDrsCollA.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.DrsCollA, Self);
end;

constructor TDrsCollB.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.DrsCollB, Self);
end;

constructor TCrnCollA.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.CrnCollA, Self);
end;

constructor TCrnCollB.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.CrnCollB, Self);
end;

constructor TIpAkaCollA.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.IpAkaCollA, Self);
end;

constructor TIpAkaCollB.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.IpAkaCollB, Self);
end;

constructor TPerPollsCollA_3240.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.PerPollsA_3240, Self);
end;

constructor TPerPollsCollB_3250.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.PerPollsB_3250, Self);
end;

constructor TIpDomCollA.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.IpDomA, Self);
end;

constructor TIpDomCollB.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.IpDomB, Self);
end;

constructor TEventColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.Events, Self);
end;

constructor TEncryptedNodeColl.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Cfg.SetObj(@Cfg.EncryptedNodes, Self);
end;

type
  TAddrI = class
    a: TFidoAddress;
    i: Integer;
  end;

  TAddrIColl = class(TSortedColl)
    function KeyOf(Item: Pointer): Pointer; override;
    function Compare(Key1, Key2: Pointer): Integer; override;
  end;

function TAddrIColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TAddrI(Item).a;
end;

function TAddrIColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := CompareAddrs(PFidoAddress(Key1)^, PFidoAddress(Key2)^);
end;

function ReportDuplicateAddrs;
var
  C: TAddrIColl;
  D: TAddrI;
  B: TFidoAddress;
  i, j, k: Integer;
  AC: TFidoAddrColl;
  Grid: TAdvGrid;
  R: TAddrListRec;
begin
  Result := True;
  Grid := AGrid;
  C := TAddrIColl.Create;
  for i := 0 to AColl.Count-1 do
  begin
    R := AColl[i];
    AC := R.AddrList;
    for j := 0 to AC.Count-1 do
    begin
      B := AC[j];
      if C.Search(@B, K) then
      begin
        Grid.Row := i+1;
        D := C[K];
        DisplayErrorFmtLng(AMsg, [Addr2Str(B), i+1, D.i+1], TForm(Grid.Owner).Handle);
        Result := False;
        Break;
      end else
      begin
        D := TAddrI.Create;
        D.a := B;
        D.i := i;
        C.AtInsert(K, D);
      end;
    end;
    if not Result then Break;
  end;
  FreeObject(C);
end;

procedure InitHelp;
var
  o,l: string;
begin
  o := GetRegHelpLng;
  RussianHelp := FileExists(GetHelpFile('rus'));
  EnglishHelp := FileExists(GetHelpFile('eng'));
  GermanHelp := FileExists(GetHelpFile('ger'));
  DanishHelp := FileExists(GetHelpFile('dan'));
  DutchHelp := FileExists(GetHelpFile('dut'));
  SpanishHelp := FileExists(GetHelpFile('spa'));
  if ((o = 'rus') and RussianHelp) or
     ((o = 'dut') and DutchHelp) or
     ((o = 'eng') and EnglishHelp) or
     ((o = 'spa') and SpanishHelp) or
     ((o = 'dan') and DanishHelp) or
     ((o = 'ger') and GermanHelp)
     then l := o else
  begin
    if EnglishHelp then l := 'eng' else
    if RussianHelp then l := 'rus' else
    if DutchHelp then l := 'dut' else
    if SpanishHelp then l := 'spa' else
    if DanishHelp then l := 'dan' else
    if GermanHelp then l := 'ger' else l := '';
    if o <> l then SetRegHelpLng(l);
  end;
  if l = 'spa' then
  begin
    HelpLanguageId := HelpLanguageSpanish;
    Application.HelpFile := GetHelpFile('spa');
  end else
  if l = 'dut' then
  begin
    HelpLanguageId := HelpLanguageDutch;
    Application.HelpFile := GetHelpFile('dut');
  end else
  if l = 'ger' then
  begin
    HelpLanguageId := HelpLanguageGerman;
    Application.HelpFile := GetHelpFile('ger');
  end else
  if l = 'dan' then
  begin
    HelpLanguageId := HelpLanguageDanish;
    Application.HelpFile := GetHelpFile('dan');
  end else
  if l = 'rus' then
  begin
    HelpLanguageId := HelpLanguageRussian;
    Application.HelpFile := GetHelpFile('rus');
  end else
  if l = 'eng' then
  begin
    HelpLanguageId := HelpLanguageEnglish;
    Application.HelpFile := GetHelpFile('eng');
  end else HelpLanguageId := 0;
end;


initialization
  icvMainFormL := High(icvMainFormL);
  icvMainFormT := High(icvMainFormT);
  icvMainFormW := High(icvMainFormW);
  icvMainFormH := High(icvMainFormH);

  icvThreadsFormL := High(icvThreadsFormL);
  icvThreadsFormT := High(icvThreadsFormT);
  icvThreadsFormW := High(icvThreadsFormW);
  icvThreadsFormH := High(icvThreadsFormH);

  InitializeCriticalSection(AuxPwdsCS);
  InitializeCriticalSection(AuxDialupNodeOverridesCS);
{$IFDEF WS}
  InitializeCriticalSection(AuxIPNodeOverridesCS);
{$ENDIF}
finalization
  FreeObject(AuxPwds);
  FreeObject(AuxDialupNodeOverrides);
{$IFDEF WS}
  FreeObject(AuxIPNodeOverrides);
  DeleteCriticalSection(AuxIPNodeOverridesCS);
{$ENDIF}
  DeleteCriticalSection(AuxDialupNodeOverridesCS);
  DeleteCriticalSection(AuxPwdsCS);
end.

