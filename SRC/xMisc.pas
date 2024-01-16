unit xMisc;

{$I DEFINE.INC}


interface uses Windows, Classes, xBase;


const
  {Convenient character constants (and aliases)}
  cNul = 0;
  cSoh = 1;
  cStx = 2;
  cEtx = 3;
  cEot = 4;
  cEnq = 5;        ccEnq = Char(cEnq);
  cAck = 6;        ccAck = Char(cAck);
  cBel = 7;
  cBS  = 8;
  cTab = 9;
  cLF  = 10;       ccLF = #10;
  cVT  = 11;
  cFF  = 12;
  cCR  = 13;       ccCR = #13;
  cSO  = 14;
  cSI  = 15;
  cDle = 16;
  cDC1 = 17;       cXon  = 17;
  cDC2 = 18;
  cDC3 = 19;       cXoff = 19;
  cDC4 = 20;
  cNak = 21;
  cSyn = 22;
  cEtb = 23;
  cCan = 24;
  cEM  = 25;
  cSub = 26;
  cEsc = 27;
  cFS  = 28;
  cGS  = 29;
  cRS  = 30;
  cUS  = 31;

  cYooHooHdr = $1f; ccYooHooHdr = Char(cYooHooHdr);
  cYooHoo = $f1; ccYooHoo = Char(cYooHoo);
  cTSync  = $ae; ccTSync = Char(cTSync);

  CPS_MinBytes = $4000;
  CPS_MinSecs = 10; // 10 seconds

  ZAutoStr = ^X'B00';

  DefHandshakeRetry = 10;   {Number of times to retry handshake}


  ModemTraceMask = EV_CTS or EV_DSR or EV_RING {$IFNDEF RLSD}or EV_RLSD{$ENDIF};

  { Additional modem status bits }
   MS_TXD_ON = DWORD($0100);
   MS_RXD_ON = DWORD($0200);

   FadeTicks = 5;


  CE_MsgNum = 11;
  CE_Msg : array[0..CE_MsgNum-1] of record i: Integer; s: string end = (
    (i:CE_BREAK;    s:'CE_BREAK'),    // The hardware detected a break condition.
    (i:CE_DNS;      s:'CE_DNS'),      // Windows 95 only: A parallel device is not selected.
    (i:CE_FRAME;    s:'CE_FRAME'),    // The hardware detected a framing error.
    (i:CE_IOE;      s:'CE_IOE'),      // An I/O error occurred during communications with the device.
    (i:CE_MODE;     s:'CE_MODE'),     // The requested mode is not supported, or the hFile parameter is invalid. If this value is specified, it is the only valid error.
    (i:CE_OOP;      s:'CE_OOP'),      // Windows 95 only: A parallel device signaled that it is out of paper.
    (i:CE_OVERRUN;  s:'CE_OVERRUN'),  // A character-buffer overrun has occurred. The next character is lost.
    (i:CE_PTO;      s:'CE_PTO'),      // Windows 95 only: A time-out occurred on a parallel device.
    (i:CE_RXOVER;   s:'CE_RXOVER'),   // An input buffer overflow has occurred. There is either no room in the input buffer, or a character was received after the end-of-file (EOF) character.
    (i:CE_RXPARITY; s:'CE_RXPARITY'), // The hardware detected a parity error.
    (i:CE_TXFULL;   s:'CE_TXFULL')    // The application tried to transmit a character, but the output buffer
  );
type

  TComError = class
    Err: DWORD;
    cs: TComStat;
  end;

  TProtocolError = (
    ecOK,
    ecTimeout,               {Fatal time out}
    ecAbortNoCarrier,        {Aborting due to carrier loss}
    ecAbortByRemote,         {Transfer aborted by remote console}
    ecAbortByLocal,          {Transfer aborted by local console}
    ecIncompatibleLink,      {Incompatible protocol options on this link}
    ecTooManyErrors          {Too many errors during protocol}
  );

const
  SProtocolError : array[TProtocolError] of string = (
   'OkiDoki',
   'Fatal time out',
   'Aborting due to carrier loss',
   'Transfer aborted by remote',
   'Transfer aborted',
   'Incompatible protocol options on this link',
   'Disconnect reason is fatal error'
  );

type
  TTransferStreamType = (
    xstUndefined,
    xstUnknown,
    xstOut,
    xstInDiskFileNew,
    xstInDiskFileAppend,
    xstInMemREQ,
    xstInMemPKT
  );


  TTransferFileAction = (aaOK , aaRefuse, aaAcceptLater, aaSysError, aaAbort);

  TLogTag = (
     ltGlobalErr,
     ltPolls,
     {$IFDEF WS}
     ltDaemon,
     {$ENDIF}
     ltWarning,
     ltInfo,
     ltConnect,
     ltNoConnect,
     ltEvent,
     ltEMSI,
     ltEMSI_1,
     ltDial,
     ltRing,
     ltTime,
     ltCost,
     ltFileOK,
     ltFileErr,
     ltHydraNfo,
     ltHydraMsg,
     ltDebug
  );

  TDialState = (dsUnknown, dsIdle, dsDialling, dsRinging, dsAnswering, dsConnected);

  TSignalType = (stRead, stWrite);
  TSignalTypeSet = set of TSignalType;

  {For specifying log file calls}
  TLogFileStatus = (
    lfUndefined,

  { file i/o }
    lfBadPkt,            // Bad packet received
    lfBadEOF,            // Bad EOF received
    lfBadCRC,            // Bad CRC received

    lfSendSync,          // Transmit resuming file (...transmitting from ofs)
    lfSendSeek,          // ...resending from offset

  { batch }
    lfBatchSendEnd,
    lfBatchReceEnd,

  { session }
    lfBatchesDone,

{$IFDEF BINKP}
  { BinkP }
    lfBinkPBadKey,
    lfBinkPgInKey,
    lfBinkPgOutKey,
    lfBinkPCanEOB,
    lfBinkPgAddr,
    lfBinkPgPwd,
    lfBinkPNul,
    lfBinkPErr,
    lfBinkPUnrec,
    lfBinkPPwd,
    lfBinkPAddr,
    lfBinkPNiaE,
    lfBinkPCRAM,
{$ENDIF}

  { hydra }
    lfHydraNfo,
    lfHydraMsg,

  { debug }
    lfDebug,

    lfTimeout,
    lfNAK,
    lfBadHdr,

    lf1Prog,
    lf1Addr,
    lf1PCode,
    lf1Pwd

  );

  TProtocolStatus = (
    psOK                 ,  {Protocol is ok}
    psProtocolHandshake  ,  {Protocol handshaking in progress}
    psInvalidDate        ,  {Bad date/time stamp received and ignored}
    psFileRejected       ,  {Incoming file was rejected}
    psFileRenamed        ,  {Incoming file was renamed}
    psSkipFile           ,  {Incoming file was skipped}
    psFileDoesntExist    ,  {Incoming file doesn't exist locally, skipped}
    psCantWriteFile      ,  {Incoming file skipped due to Zmodem options}
    psTimeout            ,  {Timed out waiting for something}
    psBlockCheckError    ,  {Bad checksum or CRC}
    psLongPacket         ,  {Block too long}
    psDuplicateBlock     ,  {Duplicate block received and ignored}    {!!.02}
    psProtocolError      ,  {Error in protocol}
    psAbortByRemote      ,  {Cancel requested}
    psAbortByLocal       ,  {Cancel requested}
    psEndFile            ,  {At end of file}
    psResumeBad          ,  {B+ host refused resume request}
    psSequenceError      ,  {Block was out of sequence}
    psAbortNoCarrier     ,  {Aborting on carrier loss}
    {Specific to certain protocols}
    psGotCrcE            ,  {Got CrcE packet (Zmodem)}
    psGotCrcG            ,  {Got CrcG packet (Zmodem)}
    psGotCrcW            ,  {Got CrcW packet (Zmodem)}
    psGotCrcQ            ,  {Got CrcQ packet (Zmodem)}
    psTryResume          ,  {B+ is trying to resume a download}
    psHostResume         ,  {B+ host is resuming}
    psWaitAck            ,  {Waiting for B+ ack (internal)}

    {Internal}
    psNoHeader           , {Protocol is waiting for header (internal)}
    psGotHeader          , {Protocol has header (internal)}
    psGotData            , {Protocol has data packet (internal)}
    psNoData               {Protocol doesn't have data packet yet (internal)}
  );

  {Constants for supported protocol types}
type
  TProtocolType = (
                   piAscii,
                   piBinkP,
                   piBPlus,
                   piFTS1,
                   piHydra,
                   piJanus,
                   piKermit,
                   piNiagara,
                   piXmodem,
                   piXmodemCRC,
                   piXmodem1K,
                   piXmodem1KG,
                   piYmodem,
                   piYmodemG,
                   piZmodem,
                   piZmodem8K,
                   piZmodem8KD,
                   piError
                   );

  {Block check codes}
  TBlockCheckType = (bcNone,             {No block checking}
                     bcChecksum1,        {Basic checksum}
                     bcChecksum2,        {Two byte checksum}
                     bcCrc16,            {16 bit Crc}
                     bcCrc32,            {32 bit Crc}
                     bcCrcK);            {Kermit style Crc}


const
  PortMinBufRead      =  $200;
  PortInBufSize       = $1000;
  PortOutBufSize      = $8000;
  PortWriteBlockSize  = $0400;
  PortChrBufSize      = $0800;

  CheckTypeStrs : array[TBlockCheckType] of string = (
    'None', 'Checksum', 'Checksum2', 'Crc16', 'Crc32', 'CrcKermit'
  );

  ProtocolNames : array[TProtocolType] of string = (
    'Ascii',
    'BinkP',
    'B+',
    'FTS-0001',
    'Hydra',
    'Janus',
    'Kermit',
    'Niagara',
    'Xmodem',
    'XmodemCRC',
    'Xmodem1K',
    'Xmodem1KG',
    'Ymodem',
    'YmodemG',
    'ZedZip (Zmodem/1K)',
    'ZedZap (Zmodem/8K)',
    'DirZap (Zmodem/8K/Direct)',
    '*** error ***'
  );

type

  {For storing received and transmitted blocks}
  PDataBlock = ^TDataBlock;
  TDataBlock = array[1..MaxInt] of Byte;

  {Describes working buffer for expanding a standard buffer with escapes}
  PWorkBlock = ^TWorkBlock;
  TWorkBlock = array[1..MaxInt] of Byte;

  {Describes data area of headers}
  TPosFlags = array[0..3] of Byte;

  TDevicePortInBuf  = array[0..PortInBufSize-1] of Byte;
  TDevicePortOutBuf = array[0..PortOutBufSize-1] of Byte;
  TDevicePortOutBlk = array[0..PortWriteBlockSize-1] of Byte;
  TDevicePortChrBuf = array[0..PortChrBufSize-1] of Byte;

  TTxRx = (TX, RX);
  TTxRxSet = set of TTxRx;

  TPort = class;
  TDevicePort = class;
  TSerialPort = class;

  TBaseProtocol = class;

  TLogFileProc = procedure(P: TBaseProtocol; AStatus: TLogFileStatus) of object;

  TAcceptFile = function (P: TBaseProtocol): TTransferFileAction of object;
  TGetNextFile = procedure (P: TBaseProtocol) of object;
  TFinishRece = procedure (P: TBaseProtocol; Action: TTransferFileAction) of object;
  TFinishSend = procedure (P: TBaseProtocol; Action: TTransferFileAction) of object;

  TBatchState = (bsInit, bsActive, bsEnd, bsIdle, bsWait);

  TBatchData = record
    FPos,                         // current position in files
    Start,                        // time we started this file
    FSize,                        // file length
    FOfs,                         // offset in file we begun
    FTime,                        // unix file time
    BlkLen,                       // length of last block
    Part           : DWORD;
    ErrPos         : Integer;
    State          : TBatchState;
    StreamType     : TTransferStreamType;
    FName          : ShortString;
  end;

  TBatch = class
    d: TBatchData;
    Stream: TxStream;                // file stream
    procedure Clear;
    procedure ClearFileInfo;
    function Copy: TBatch;
    function CPS(AOutUsed: DWORD): Integer;
  end;


  TBaseProtocol = class
  protected
     CP                  : TPort;
     FAcceptFile         : TAcceptFile;
     FGetNextFile        : TGetNextFile;
     FFinishRece         : TFinishRece;
     FFinishSend         : TFinishSend;

     procedure CalcTimeout(var VTimeout: DWORD; AMax, AMin: DWORD);
     procedure CalcBlockSize(var VMax, VCur: DWORD; AMax, AMin: DWORD);
     procedure DbgLog(const s: string);
     procedure DbgLogFmt(const Fmt: string; const Args: array of const);
     constructor Create(ACP : TPort);
     procedure Finish; virtual;
     procedure Cancel; virtual; abstract;
     procedure IncTotalErrors;
  private
     procedure DoStart;
  public
     CramDisabled,
     Debug,
     OutFlow             : Boolean;
     TotalErrors         : DWORD;
     ProtocolError       : TProtocolError;         {Holds last error}
     Station             : TStationDataColl;
     Speed,
     BatchNo,
     BinkPTimeout        : DWORD;
     FileRefuse,
     FileSkip,
     Originator          : Boolean;                // Are we the orig side?
     CustomInfo          : string;
     T, R                : TBatch;
     ID                  : TProtocolType;
     CancelRequested     : Boolean;
     FLogFile            : TLogFileProc;
     function TimeoutValue: DWORD; virtual; abstract;
     procedure Start({RX}AAcceptFile: TAcceptFile;
                         AFinishRece: TFinishRece;
                     {TX}AGetNextFile: TGetNextFile;
                         AFinishSend: TFinishSend
                     ); virtual; abstract;
     function  TxClosed: Boolean;
     function  RxClosed: Boolean;
     function GetStateStr: string; virtual; abstract;
     procedure ReportTraf(txMail, txFiles: DWORD); virtual; abstract;
     function Name: string;
     destructor Destroy; override;
     function IsBiDir: Boolean; virtual; abstract;
     function NextStep: Boolean; virtual; abstract;
  end;

  TBiDirProtocol = class(TBaseProtocol)
  public
     function IsBiDir: Boolean;                                 override;
     procedure Start({RX}AAcceptFile: TAcceptFile;
                         AFinishRece: TFinishRece;
                     {TX}AGetNextFile: TGetNextFile;
                         AFinishSend: TFinishSend );            override;
  end;

  TOneWayProtocol = class(TBaseProtocol)
  protected
     TimeoutTimer        : EventTimer;
     BlockErrors         : DWORD;
     DataBlock           : PDataBlock;      {Working data block}
     CheckType           : TBlockCheckType; {Code for block check type}
     BlockCheck          : DWORD;         {Block check value}
     ProtocolStatus      : TProtocolStatus; {Holds last status}
     LastBlock           : Boolean;         {True at eof}

     procedure PrepareReceive(AAcceptFile: TAcceptFile;
                              AFinishRece: TFinishRece); virtual; abstract;
     procedure PrepareTransmit(NextFunc: TGetNextFile;
                         AFinishSend: TFinishSend); virtual; abstract;

     function  Timeout: Boolean;
     procedure IncBlockErrors;

     constructor Create(ACP : TPort);

     function  Receive: Boolean; virtual; abstract;
     function  Transmit : Boolean; virtual; abstract;

     procedure SignalFinish;
   public
     function IsBiDir: Boolean;                                 override;
     function TimeoutValue: DWORD; override;
     function NextStep: Boolean; override;
     procedure Start({RX}AAcceptFile: TAcceptFile;
                         AFinishRece: TFinishRece;
                     {TX}AGetNextFile: TGetNextFile;
                         AFinishSend: TFinishSend );            override;

   end;

   TFadeThread = class(T_Thread)
     oFade: DWORD;
     constructor Create;
     procedure InvokeExec; override;
     destructor Destroy; override;
     class function ThreadName: string; override;
   end;

   TInThreadClass = class of TInThread;
   TInThread = class(T_Thread)
     Actually: DWORD;
     ReadState: Boolean;
     CP: TDevicePort;
     ReadBuf: TDevicePortInBuf;     { Used by ReadFile }
     procedure InvokeExec; override;
     function Read(var Buf; Size: DWORD): DWORD; virtual; abstract;
     class function ThreadName: string; override;
   end;

   TSerialInThread = class(TInThread)
     function Read(var Buf; Size: DWORD): DWORD; override;
   end;

   TOutThreadClass = class of TOutThread;
   TOutThread = class(T_Thread)
     OutFlow: Boolean;
     CP: TDevicePort;
     WriteBuf: TDevicePortOutBlk;
     Purge: Boolean;
     procedure InvokeExec; override;
     function Write(const Buf; Size: DWORD): DWORD; virtual; abstract;
     class function ThreadName: string; override;
   end;

   TSerialOutThread = class(TOutThread)
     function Write(const Buf; Size: DWORD): DWORD; override;
   end;

   TPort = class
   protected
     procedure SetCarrier(B: Boolean);               virtual; abstract;
     function  GetCarrier: Boolean;                  virtual; abstract;
     procedure SetCallerId(const S:string);          virtual; abstract;
     procedure SetPortNumber(V: Integer);            virtual; abstract;
     procedure SetPortIndex(V: Integer);             virtual; abstract;
     procedure SetDTE(V: Integer);                   virtual; abstract;
     function  GetCallerId: string;                  virtual; abstract;
     function  GetPortNumber: Integer;               virtual; abstract;
     function  GetPortIndex: Integer;                virtual; abstract;
     function  GetDTE: Integer;                      virtual; abstract;
  public
   // mapped routines
     procedure SetDeltaDCDNotify(h: DWORD);          virtual; abstract;
     procedure SetCommErrorNotify(h: DWORD);         virtual; abstract;
     function  ComErrorColl: TColl;                  virtual; abstract;
     procedure EnterCommErrorCS;                     virtual; abstract;
     procedure LeaveCommErrorCS;                     virtual; abstract;
     function  LineStatus: DWORD;                    virtual; abstract;
     function  Handle: DWORD;                        virtual; abstract;
     function  oDataAvail: DWORD;                    virtual; abstract;
     function  oOutDrained: DWORD;                   virtual; abstract;
     function  OutUsed: DWORD;                       virtual; abstract;
     function  Write(const Buf; Size: DWORD): DWORD; virtual; abstract;
     function  CharReady: Boolean;                   virtual; abstract;
     procedure Flsh;                                 virtual; abstract;
     procedure PutChar(C: Byte);                     virtual; abstract;
     function  GetChar(var C: Byte): Boolean;        virtual; abstract;
     function  DCD: Boolean;                         virtual; abstract;
     function  GetErrorStrColl: TStringColl;         virtual; abstract;
     procedure SendString(const S: string);
     property Carrier: Boolean read GetCarrier write SetCarrier;
     property CallerId: string read GetCallerId write SetCallerId;
     property PortNumber: Integer read GetPortNumber write SetPortNumber;
     property PortIndex: Integer read GetPortIndex write SetPortIndex;
     property DTE: Integer read GetDTE write SetDTE;
   end;

   TMapPort = class(TPort)
   protected
     DevicePort: TDevicePort;
     procedure SetCarrier(B: Boolean);                 override;
     function  GetCarrier: Boolean;                    override;
     procedure SetCallerId(const S:string);            override;
     procedure SetPortNumber(V: Integer);              override;
     procedure SetPortIndex(V: Integer);               override;
     procedure SetDTE(V: Integer);                     override;
     function GetCallerId: string;                     override;
     function GetPortNumber: Integer;                  override;
     function GetPortIndex: Integer;                   override;
     function GetDTE: Integer;                         override;
   public
     procedure SetDeltaDCDNotify(h: DWORD);            override;
     procedure SetCommErrorNotify(h: DWORD);           override;
     function  ComErrorColl: TColl;                    override;
     procedure EnterCommErrorCS;                       override;
     procedure LeaveCommErrorCS;                       override;
     function  LineStatus: DWORD;                      override;
     function  Handle: DWORD;                          override;
     function  oOutDrained: DWORD;                     override;
     function  oDataAvail: DWORD;                      override;
     constructor Create(ADevicePort: TDevicePort);
     function ExtractPort: TDevicePort;
     destructor Destroy; override;
     function  DCD: Boolean;                           override;
   end;

   TDevicePort = class(TPort)
   protected
   // constant options
     FCallerId,
     HoldStr: string;
     FPortNumber,
     FPortIndex,
     FDTE,                      { Baudrate port have been locked }
     SzWrite,
     SzWriteNow,
     PtrReadA, SzReadA,
     SzReadB,
     HoldPos,
     HoldLen,
     FLineStatus,
     SzOutChars,

     oFreeReadB,      { Signaled on free ReadB }
     oNewOutData,     { To wake up writing thread }
     oReadDowned,
     oStatusDowned,
     oTempDown: DWORD;

     LastRead, LastWrite: EventTimer;

     SignalTimeouts: array[TSignalType] of EventTimer;

     ReadA,                 { API-free, used by GetChar }
     ReadB: TDevicePortInBuf;     { Shared by ReadFile and GetChar }

     WriteBuf: TDevicePortOutBuf;

     OutChars: TDevicePortChrBuf;

     ReadThr: TInThread;
     WriteThr: TOutThread;

     ReadCS, WriteCS: TRTLCriticalSection;

     FCarrier,
     HoldKept,
     bNewData,
     PurgeRX,
     FRI,
     FCTS,
     FDSR,
     FDTR,
     FRTS,
     FTXD,
     FRXD,
     FDCD: Boolean;

     StatCS  : TRTLCriticalSection;
     StatOL  : TOverLapped;

     procedure Reload;
     procedure CloseHW_A;                              virtual; abstract;
     procedure CloseHW_B;                              virtual; abstract;
     procedure HWPurge(Typ: TTxRxSet);                 virtual; abstract;
     procedure SaveParams;                             virtual; abstract;
     procedure RestoreParams;                          virtual; abstract;
     procedure SetCarrier(B: Boolean);                 override;
     function  GetCarrier: Boolean;                    override;
     procedure SetCallerId(const S:string);            override;
     procedure SetPortNumber(V: Integer);              override;
     procedure SetPortIndex(V: Integer);               override;
     procedure SetDTE(V: Integer);                     override;
     function GetCallerId: string;                     override;
     function GetPortNumber: Integer;                  override;
     function GetPortIndex: Integer;                   override;
     function GetDTE: Integer;                         override;
   public
     ComErrorCS: TRTLCriticalSection;
     FComErrorColl: TColl;
     FHandle,
     FoDeltaDCDNotify,
     FoComErrorNotify,
     FoDataAvail,                                      { Signaled on Input Data available }
     FoOutDrained: DWORD;                              { Signaled on Output Buffer drained }
     TempDown: Boolean;
     ReadOL, WriteOL : TOverLapped;
     function  oOutDrained: DWORD;                     override;
     function  oDataAvail: DWORD;                      override;
     procedure EnterCommErrorCS;                       override;
     procedure LeaveCommErrorCS;                       override;
     function  ComErrorColl: TColl;                    override;
     procedure SetDeltaDCDNotify(h: DWORD);            override;
     procedure SetCommErrorNotify(h: DWORD);           override;
     procedure SetHoldStr(const S: string);
     procedure InsComErr(ee: TComError);
     procedure EnterWriteCS;
     procedure LeaveWriteCS;
     function ReadNow: Integer;                        virtual; abstract;
     procedure WakeThreads;
     function LineStatus: DWORD;                       override;
     procedure UpdateLineStatus;

     function  GetChar(var C: Byte): Boolean;          override;
     function  CharReady: Boolean;                     override;
     function  _GetChar: Byte;

     function  Write(const Buf; Size: DWORD): DWORD;   override;
     procedure PutChar(C: Byte);                       override;
     procedure Flsh;                                   override;
     function  GetErrorStrColl: TStringColl;           override;

     procedure Purge(Typ: TTxRxSet);

     constructor Create(InClass: TInThreadClass; OutClass: TOutThreadClass);
     destructor Destroy; override;
     function  Handle: DWORD;                          override;

     function OutUsed: DWORD;                          override;
     function DCD: Boolean;                            override;
     procedure SleepDown;                              virtual; abstract;
     procedure WakeUp;                                 virtual; abstract;
   end;


   TSerialStatusThr = class;

   TSerialPort = class(TDevicePort)
   public
     OrgTimeouts,
     DefTimeouts: TCommTimeouts;
     StatThr : TSerialStatusThr;

     procedure SetExitTimeouts;
     procedure SetMask(Arg: Integer);
     procedure SetBPS(I: Integer);
     function ReadNow: Integer; override;
     procedure SleepDown; override;
     procedure WakeUp; override;

     function ChkAbort: Integer;
     function RealDCD: Boolean; 
     procedure CloseHW_A; override;
     procedure CloseHW_B; override;
     procedure HWPurge(Typ: TTxRxSet); override;
     procedure ReadStatus;
     procedure SetDTR(Value: Boolean);
     procedure SetRTS(Value: Boolean);
     property DTR: Boolean write SetDTR;
     property RTS: Boolean write SetRTS;

     constructor Create(AHandle: DWORD);
     destructor Destroy; override;
     procedure SaveParams; override;
     procedure RestoreParams; override;
     procedure SetLine(AOptions: Integer);
     procedure SetTimeouts(T: TCommTimeouts);
   end;

   TSerialStatusThr = class(T_Thread)
   private
     EvtMask: DWORD;
     Again: Boolean;
     CP: TSerialPort;
   public
     procedure InvokeExec; override;
     class function ThreadName: string; override;
   end;

   TCommThread = class(T_Thread)
     CP: TPort;
     class function ThreadName: string; override;
   end;

   TLampsProc = procedure(AComThr: TCommThread);

   TLampsThread = class(T_Thread)
     oStatusChange: DWORD;   { Signaled on Modem Status change }
     class function ThreadName: string; override;
     constructor Create;
     procedure InvokeExec; override;
     destructor Destroy; override;
   end;

  TDevicePortColl = class(TColl)
    LampsThr: TLampsThread;
    FadeThr: TFadeThread;
    constructor Create;
    destructor Destroy; override;
  end;

function SetCommParams(AHandle, ASpeed: DWORD;
                       ADataBits, AParityType, AStopBits: Byte;
                       ACTS_RTS,  AxOn_xOff: Boolean): Boolean;

var
  PortsColl: TDevicePortColl;

implementation uses SysUtils, NTdyn;

{ --- In Thread }


class function TInThread.ThreadName: string;
begin
  Result := 'Interface Input';
end;


procedure TInThread.InvokeExec;
type
  TToDo = (_ReadAgain, _WaitB);

function ToDo: TToDo;

var
  SetDataAvail: Boolean;

procedure MakeChoice;
begin

  ToDo := _ReadAgain;

  if CP.PurgeRX then
  begin
    ResetEvt(CP.FoDataAvail);
    CP.PurgeRX := False;
  end else
    if Actually <> 0 then
    begin
      if Actually > PortInBufSize - CP.SzReadB then ToDo := _WaitB else
      begin
        if CP.SzReadB = 0 then
        begin
          ResetEvt(CP.oFreeReadB); { Set to nonsignaled }
          if CP.SzReadA = 0 then SetDataAvail := True;
        end;
        Move(ReadBuf, CP.ReadB[CP.SzReadB], Actually);
        Inc(CP.SzReadB, Actually);
      end;
    end;

end;

begin
  SetDataAvail := False;
  EnterCS(CP.ReadCS);
  MakeChoice;
  if SetDataAvail then SetEvt(CP.FoDataAvail);
  LeaveCS(CP.ReadCS);
end;


begin
  if not ReadState then
  begin
    if CP is TSerialPort then
    begin
      if not TimerExpired(CP.LastRead) then Sleep(10);
      NewTimer(CP.LastRead, 1);
    end;

    if not CP.TempDown then
    Actually := Read(ReadBuf, CP.ReadNow);

    if Terminated then Exit;

    if CP.TempDown then
    begin
      if Win32Platform = VER_PLATFORM_WIN32_NT then
      begin
        if NTdyn_SignalObjectAndWait(CP.oReadDowned, CP.oTempDown, INFINITE, False) <> WAIT_OBJECT_0 then GlobalFail('%s', ['SignalObjectAndWait oReadDowned']);
      end else
      begin
        SetEvt(CP.oReadDowned);
        WaitEvtInfinite(CP.oTempDown);
      end;
      SetEvt(CP.oReadDowned);
      CP.RestoreParams;
      Exit;
    end;

    EnterCS(CP.StatCS);
    CP.FRxD := True;
    CP.UpdateLineStatus;
    NewTimer(CP.SignalTimeouts[stRead], FadeTicks);
    SetEvt(PortsColl.FadeThr.oFade);
    LeaveCS(CP.StatCS);

    if Terminated then Exit;

    ReadState := True;
  end;

  if ReadState then
  begin
    case ToDo of
      _ReadAgain: ReadState := False;
      _WaitB: WaitEvtInfinite(CP.oFreeReadB);
    end;
  end;
end;

{ --- Out Thread }

class function TOutThread.ThreadName: string;
begin
  Result := 'Interface Output';
end;


procedure TOutThread.InvokeExec;

procedure PrepareFlow;
var
  SetOutDrained: Boolean;
begin
  CP.EnterWriteCS;
  CP.SzWriteNow := 0;
  CP.LeaveWriteCS;
  WaitEvtInfinite(CP.oNewOutData);
  if Terminated then Exit;
  SetOutDrained := False;
  CP.EnterWriteCS;
  if not Terminated then
  begin
    CP.SzWriteNow := MinD(CP.SzWrite, PortWriteBlockSize);
    Move(CP.WriteBuf, WriteBuf, CP.SzWriteNow);
    Dec(CP.SzWrite, CP.SzWriteNow);
    if CP.SzWrite = 0 then
    begin
      CP.bNewData := False;
      SetOutDrained := True;
      ResetEvt(CP.oNewOutData);
    end else
      Move(CP.WriteBuf[CP.SzWriteNow], CP.WriteBuf, CP.SzWrite);
  end;
  if SetOutDrained then SetEvt(CP.FoOutDrained);
  CP.LeaveWriteCS;

  if Terminated then Exit;
  if CP.SzWriteNow > 0 then OutFlow := True;
end;


procedure DoOutFlow;
var
  SzWriteActual: DWORD;
begin
  EnterCS(CP.StatCS);
  CP.FTxD := True;
  CP.UpdateLineStatus;
  NewTimer(CP.SignalTimeouts[stWrite], FadeTicks);
  SetEvt(PortsColl.FadeThr.oFade);
  LeaveCS(CP.StatCS);

  if CP is TSerialPort then
  begin
    if not TimerExpired(CP.LastWrite) then Sleep(10);
    NewTimer(CP.LastWrite, 1);
  end;

  SzWriteActual := Write(WriteBuf, CP.SzWriteNow);

  if Terminated then Exit;

  CP.EnterWriteCS;
  if CP.SzWriteNow = 0 then SzWriteActual := 0;
  if (CP.SzWriteNow = SzWriteActual) then
  begin
    CP.LeaveWriteCS;
    OutFlow := False;
    Exit;
  end;
  if SzWriteActual > 0 then
  begin
    Dec(CP.SzWriteNow, SzWriteActual);
    Move(WriteBuf[SzWriteActual], WriteBuf, CP.SzWriteNow)
  end;
  CP.LeaveWriteCS;
end;

begin
  if not OutFlow then PrepareFlow;
  if OutFlow then DoOutFlow;
end;

{ --- Fade Thread }

class function TFadeThread.ThreadName: string;
begin
  Result := 'Lamps Fader';
end;


constructor TFadeThread.Create;
begin
  inherited Create;
//  FreeOnTerminate := True;
  Priority := tpLower;
  oFade := CreateEvtA;
end;

procedure TFadeThread.InvokeExec;
var
  t: TSignalType;
  CP: TDevicePort;

procedure CndChk(var b: Boolean);
var
  e: PEventTimer;
begin
  e := @CP.SignalTimeouts[t];
  if TimerInstalled(e^) and TimerExpired(e^) then
  begin
    b := False;
    ClearTimer(e^);
  end;
end;

var
  i: Integer;
  ToSleep: DWORD;
  e: EventTimer;
begin
  ToSleep := High(ToSleep);

  PortsColl.Enter;
  for i := 0 to PortsColl.Count-1 do
  begin
    CP := PortsColl[i];
    EnterCS(CP.StatCS);
    for t := Low(TSignalType) to High(TSignalType) do
    begin
      e := CP.SignalTimeouts[t];
      if TimerInstalled(e) then ToSleep := MinD(ToSleep, RemainingTimeMSecs(e));
      if ToSleep = 0 then Break;
    end;
    LeaveCS(CP.StatCS);
  end;
  PortsColl.Leave;

  if ToSleep = High(ToSleep) then ToSleep := INFINITE;
  WaitEvt(oFade, MaxD(50, ToSleep));

  if Terminated then Exit;

  PortsColl.Enter;
  for i := 0 to PortsColl.Count-1 do
  begin
    CP := PortsColl[i];
    EnterCS(CP.StatCS);
    t := Low(TSignalType);
    CndChk(CP.FRxD);
    t := Succ(t);
    CndChk(CP.FTxD);
    CP.UpdateLineStatus;
    LeaveCS(CP.StatCS);
  end;
  PortsColl.Leave;
end;

destructor TFadeThread.Destroy;
begin
  ZeroHandle(oFade);
  inherited Destroy;
end;

{ --- Ports collection }

constructor TDevicePortColl.Create;
begin
  inherited Create;
  LampsThr := TLampsThread.Create;
  FadeThr := TFadeThread.Create;

  LampsThr.Suspended := False;
  FadeThr.Suspended := False;
end;

destructor TDevicePortColl.Destroy;
begin
  LampsThr.Suspended := True;
  FadeThr.Suspended := True;
  LampsThr.Terminated := True;
  FadeThr.Terminated := True;
  SetEvt(LampsThr.oStatusChange);
  SetEvt(FadeThr.oFade);
  LampsThr.Suspended := False;
  FadeThr.Suspended := False;
  LampsThr.WaitFor; FreeObject(LampsThr);
  FadeThr.WaitFor; FreeObject(FadeThr);
  inherited Destroy;
end;

{ --- Map port }


procedure TMapPort.SetCallerId(const S:string);
begin
  DevicePort.CallerId := S;
end;

procedure TMapPort.SetPortNumber(V: Integer);
begin
  DevicePort.PortNumber := V;
end;

procedure TMapPort.SetPortIndex(V: Integer);
begin
  DevicePort.PortIndex := V;
end;

procedure TMapPort.SetDTE(V: Integer);
begin
  DevicePort.DTE := V;
end;

function TMapPort.GetCallerId: string;
begin
  Result := DevicePort.CallerId;
end;

function TMapPort.GetPortNumber: Integer;
begin
  Result := DevicePort.PortNumber;
end;

function TMapPort.GetPortIndex: Integer;
begin
  Result := DevicePort.PortIndex;
end;

function TMapPort.GetDTE: Integer;
begin
  Result := DevicePort.DTE;
end;

function TMapPort.oOutDrained: DWORD;
begin
  Result := DevicePort.FoOutDrained;
end;

function TMapPort.oDataAvail: DWORD;
begin
  Result := DevicePort.FoDataAvail;
end;


constructor TMapPort.Create(ADevicePort: TDevicePort);
begin
  inherited Create;
  DevicePort := ADevicePort;
end;

function TMapPort.ExtractPort: TDevicePort;
begin
  Result := DevicePort;
  DevicePort := nil;
end;

destructor TMapPort.Destroy;
begin
  FreeObject(DevicePort);
  inherited Destroy;
end;

procedure TMapPort.SetCarrier(B: Boolean);
begin
  DevicePort.FCarrier := B;
end;

function  TMapPort.GetCarrier: Boolean;
begin
  Result := DevicePort.FCarrier;
end;



function  TMapPort.DCD: Boolean;
begin
  Result := DevicePort.DCD;
end;

function  TMapPort.Handle: DWORD;
begin
  Result := DevicePort.FHandle;
end;

procedure TMapPort.SetDeltaDCDNotify(h: DWORD);
begin
  DevicePort.SetDeltaDCDNotify(h);
end;

procedure TMapPort.SetCommErrorNotify(h: DWORD);
begin
  DevicePort.SetCommErrorNotify(h);
end;


function  TMapPort.ComErrorColl: TColl;
begin
  Result := DevicePort.ComErrorColl;
end;

procedure TMapPort.EnterCommErrorCS;
begin
  DevicePort.EnterCommErrorCS;
end;

procedure TMapPort.LeaveCommErrorCS;
begin
  DevicePort.LeaveCommErrorCS;
end;

function  TMapPort.LineStatus: DWORD;
begin
  Result := DevicePort.LineStatus;
end;

{ --- Abstract Device port }

function TDevicePort.GetErrorStrColl;
begin
  Result := nil;
end;


procedure TDevicePort.SetCallerId(const S:string);
begin
  FCallerId := S;
end;

procedure TDevicePort.SetPortNumber(V: Integer);
begin
  FPortNumber := V;
end;


procedure TDevicePort.SetPortIndex(V: Integer);
begin
  FPortIndex := V;
end;

procedure TDevicePort.SetDTE(V: Integer);
begin
  FDTE := V;
end;

function TDevicePort.GetCallerId: string;
begin
  Result := FCallerId;
end;

function TDevicePort.GetPortNumber: Integer;
begin
  Result := FPortNumber;
end;

function TDevicePort.GetPortIndex: Integer;
begin
  Result := FPortIndex;
end;

function TDevicePort.GetDTE: Integer;
begin
  Result := FDTE;
end;

function TDevicePort.Handle: DWORD;
begin
  Result := FHandle;
end;


procedure TDevicePort.SetCarrier(B: Boolean);
begin
  FCarrier := B;
end;

function  TDevicePort.GetCarrier: Boolean;
begin
  Result := FCarrier;
end;


function  TDevicePort.LineStatus: DWORD;
begin
  Result := FLineStatus;
end;

function  TDevicePort.oOutDrained: DWORD;
begin
  Result := FoOutDrained;
end;


function  TDevicePort.oDataAvail: DWORD;
begin
  Result := FoDataAvail;
end;

procedure TDevicePort.EnterCommErrorCS;
begin
  EnterCS(ComErrorCS);
end;

procedure TDevicePort.LeaveCommErrorCS;
begin
  LeaveCS(ComErrorCS);
end;


function TDevicePort.ComErrorColl: TColl;
begin
  Result := FComErrorColl;
end;

function TDevicePort.OutUsed: DWORD;
begin
  Result := {SzOutChars +} SzWrite;
end;

function TDevicePort.DCD: Boolean;
begin
  Result := FDCD;
end;


procedure TDevicePort.InsComErr(ee: TComError);
begin
  EnterCS(ComErrorCS);
  FComErrorColl.Insert(ee);
  if FoComErrorNotify <> INVALID_HANDLE_VALUE then SetEvent(FoComErrorNotify);
  LeaveCS(ComErrorCS);
end;

procedure TDevicePort.EnterWriteCS;
begin
  EnterCS(WriteCS);
end;

procedure TDevicePort.LeaveWriteCS;
begin
  LeaveCS(WriteCS);
end;

procedure TDevicePort.UpdateLineStatus;
var
  s: DWORD;
  PulseDeltaDCD: Boolean;
begin
  PulseDeltaDCD := False;
  s := FLineStatus;
  if FRI  then s := s or MS_RING_ON  else s := s and not MS_RING_ON;
  if FCTS then s := s or MS_CTS_ON  else s := s and not MS_CTS_ON;
{$IFNDEF RLSD}  if FDCD then s := s or MS_RLSD_ON else s := s and not MS_RLSD_ON; {$ENDIF}
  if FDSR then s := s or MS_DSR_ON else s := s and not MS_DSR_ON;
  if FTXD then s := s or MS_TXD_ON else s := s and not MS_TXD_ON;
  if FRXD then s := s or MS_RXD_ON else s := s and not MS_RXD_ON;
  if s <> FLineStatus then
  begin
    {$IFNDEF RLSD}
    if (s and MS_RLSD_ON) <> (FLineStatus and MS_RLSD_ON) then
    begin
      if FoDeltaDCDNotify <> INVALID_HANDLE_VALUE then PulseDeltaDCD := True;
    end;
    {$ENDIF}
    FLineStatus := s;
    SetEvt(PortsColl.LampsThr.oStatusChange);
    if PulseDeltaDCD then SetEvt(FoDeltaDCDNotify);
  end;
end;

procedure TDevicePort.Purge;
begin
  Exit;
  if TX in Typ then
  begin
    EnterWriteCS;
    SzWrite := 0;
    SzWriteNow := 0;
    SzOutChars := 0;
    if HoldKept then
    begin
      HoldPos := 0;
      HoldKept := False;
      HoldStr  := '';
    end;
  end;
  if RX in Typ then
  begin
    EnterCS(ReadCS);
    PurgeRX := True;
    PtrReadA := 0;
    SzReadA := 0;
    SzReadB := 0;
  end;

  HWPurge(Typ);

  if RX in Typ then LeaveCS(ReadCS);
  if TX in Typ then LeaveWriteCS;

end;

procedure TDevicePort.WakeThreads;
begin
  ReadThr.Suspended := False;
  WriteThr.Suspended := False;
end;

{function TDevicePort.OutEmpty: Boolean;
begin
  Flsh;
  Result := not bNewData;
end;}

procedure TDevicePort.PutChar(C: Byte);
begin
  OutChars[SzOutChars] := C;
  Inc(SzOutChars);
  if SzOutChars = PortChrBufSize then
  Flsh;
end;

procedure TDevicePort.Flsh;
var
  Sz, Actual: Integer;
begin
{  sz := GetCurrentThreadID;
  if hhTT = 0 then hhTT := sz;
  if hhTT <> sz then
  GlobalFail;}
  while SzOutChars > 0 do
  begin
    Sz := SzOutChars; SzOutChars := 0;
    Actual := Write(OutChars, Sz);
    SzOutChars := Sz - Actual;
    if Sz > Actual then
    begin
      Move(OutChars[Actual], OutChars, SzOutChars);
      WaitEvtInfinite(oNewOutData);
    end;
  end;
end;



{function TDevicePort.Read(var Buf; Size: Integer): Integer;
var
  A: TCharArray absolute Buf;
begin
  Result := 0; while GetChar(A[Result]) do Inc(Result);
end;}


function TDevicePort.Write(const Buf; Size: DWORD): DWORD;
var
  SetNewData : Boolean;
begin
  SetNewData := False;
  Flsh;
  EnterWriteCS;
  Result := MaxD(0, MinD(Size, PortOutBufSize - SzWrite));
  if Result <> Size then GlobalFail('Port Output Buffer Overflow (PortOutBufSize=%d, SzWrite=%d)', [PortOutBufSize, SzWrite]);
  if Result <> 0 then
  begin
    if SzWrite = 0 then
    begin
      SetNewData := True;
      bNewData := True;
      ResetEvt(FoOutDrained);
    end;
    Move(Buf, WriteBuf[SzWrite], Result);
    Inc(SzWrite, Result);
  end;
  LeaveWriteCS;
  if SetNewData then SetEvt(oNewOutData);
end;

constructor TDevicePort.Create;
begin
  inherited Create;
{--- Critical Sections}
  InitializeCriticalSection(ReadCS);
  InitializeCriticalSection(StatCS);
  InitializeCriticalSection(WriteCS);
  InitializeCriticalSection(ComErrorCS);

{--- Semaphore Events }
  oFreeReadB   := CreateEvt(True);
  FoDataAvail   := CreateEvt(False);
  oNewOutData  := CreateEvt(False);
  FoOutDrained  := CreateEvt(True);
  oTempDown    := CreateEvt(False);
  oReadDowned := CreateEvt(False);
  oStatusDowned := CreateEvt(False);

  ReadOL.hEvent := CreateEvt(False);
  StatOL.hEvent := CreateEvt(False);
  WriteOL.hEvent := CreateEvt(False);

{--- In Thread}
  ReadThr := InClass.Create;
  with ReadThr do
  begin
    CP := Self;
    Priority := tpHigher;
  end;

{--- Out Thread}
  WriteThr := OutClass.Create;
  with WriteThr do
  begin
    CP := Self;
    Priority := tpHigher;
  end;

  FoDeltaDCDNotify := INVALID_HANDLE_VALUE;
  FoComErrorNotify := INVALID_HANDLE_VALUE;
  FComErrorColl := TColl.Create;

  PortsColl.Enter;
  PortsColl.Insert(Self);
  PortsColl.Leave;

  NewTimer(LastRead, 0);
  NewTimer(LastWrite, 0);

end;

destructor TDevicePort.Destroy;
begin

  PortsColl.Enter;
  PortsColl.Delete(Self);
  PortsColl.Leave;

  ReadThr.Terminated := True;
  WriteThr.Terminated := True;

  SetEvt(oFreeReadB);
  SetEvt(oNewOutData);
  SetEvt(StatOL.hEvent);
  SetEvt(ReadOL.hEvent);
  SetEvt(WriteOL.hEvent);

  CloseHW_A;

  ReadThr.WaitFor; FreeObject(ReadThr);
  WriteThr.WaitFor; FreeObject(WriteThr);

  CloseHW_B;

  FreeObject(FComErrorColl);

  ZeroHandle(oFreeReadB);
  ZeroHandle(FoDataAvail);
  ZeroHandle(oNewOutData);
  ZeroHandle(FoOutDrained);
  ZeroHandle(ReadOL.hEvent);
  ZeroHandle(WriteOL.hEvent);
  ZeroHandle(StatOL.hEvent);
  ZeroHandle(oTempDown);
  ZeroHandle(oReadDowned);
  ZeroHandle(oStatusDowned);

  DeleteCriticalSection(ReadCS);
  DeleteCriticalSection(StatCS);
  DeleteCriticalSection(WriteCS);
  DeleteCriticalSection(ComErrorCS);

  inherited Destroy;
end;

procedure TDevicePort.SetDeltaDCDNotify(h: DWORD);
begin
  FoDeltaDCDNotify := h;
end;

procedure TDevicePort.SetCommErrorNotify(h: DWORD);
begin
  FoComErrorNotify := h;
end;

procedure TDevicePort.SetHoldStr(const S: string);
begin
  if S = '' then Exit;
  HoldStr := HoldStr + S;
  HoldLen := Length(HoldStr);
  HoldKept := True;
end;

function TDevicePort.GetChar(var C: Byte): Boolean;
begin
  if HoldKept then
  begin
    Result := True;
    Inc(HoldPos);
    if HoldPos > HoldLen then GlobalFail('TDevicePort.GetChar HoldPos(%d) > HoldLen(%d)', [HoldPos, HoldLen]);
    C := Byte(HoldStr[HoldPos]);
    if HoldPos = HoldLen then
    begin
      HoldKept := False;
      HoldStr := '';
      HoldPos := 0;
    end;
  end else
  begin
    Reload; if SzReadA = 0 then Result := False else
    begin
      Result := True;
      C := ReadA[PtrReadA]; Inc(PtrReadA);
    end;
  end;
end;

function TDevicePort._GetChar: Byte;
begin
  GetChar(Result);
end;


function TDevicePort.CharReady: Boolean;
begin
  if HoldKept then Result := True else
  begin
    Reload; Result := SzReadA > 0;
  end;
end;


procedure TDevicePort.Reload;
begin
  if (SzReadA = 0) and (SzReadB = 0) then Exit;
  if PtrReadA <> SzReadA then Exit;
  EnterCS(ReadCS);
  PtrReadA := 0; SzReadA := SzReadB;
  if SzReadB = 0 then
  ResetEvt(FoDataAvail)
  else
  begin
    Move(ReadB, ReadA, SzReadB);
    SzReadB := 0;
    SetEvt(oFreeReadB);
  end;
  LeaveCS(ReadCS);
end;

procedure TPort.SendString(const S: string);
var
  i: Integer;
begin
  for i := 1 to Length(S) do PutChar(Byte(S[I]));
end;

procedure TSerialPort.SetBPS(I: Integer);
var
  DCB: TDCB;

procedure GetCS;
var
  j: Integer;
begin
  j := 0;
  while not GetCommState(Handle, DCB) do
  begin
    Inc(j); if j = 10 then GlobalFail('TSerialPort.SetBPS GetCommState Error %d', [GetLastError]);
    ChkAbort;
  end;
end;

procedure SetCS;
var
  j: Integer;
begin
  j := 0;
  while not SetCommState(Handle, DCB) do
  begin
    Inc(j); if j = 10 then GlobalFail('TSerialPort.SetBPS SetCommState Error %d', [GetLastError]);
    ChkAbort;
  end;
end;

begin
  SleepDown;
  GetCS;
  DCB.Baudrate := I;
  SetCS;
  WakeUp;
end;

{ --- Serial Port }

function SetCommParams;

const
  fBinary            = $1;          // binary mode, no EOF check
  fParity            = $2;          // enable parity checking
  fOutxCtsFlow       = $4;          // CTS output flow control
  fOutxDsrFlow       = $8;          // DSR output flow control
  fDtrControlMask    = $10 + $20;   // DTR flow control type
  fDsrSensitivity    = $40;         // DSR sensitivity
  fTXContinueOnXoff  = $80;         // XOFF continues Tx
  fOutX              = $100;        // XON/XOFF out flow control
  fInX               = $200;        // XON/XOFF in flow control
  fErrorChar         = $400;        // enable error replacement
  fNull              = $800;        // enable null stripping
  fRtsControlMask    = $1000+$2000; // RTS flow control
  fAbortOnError      = $4000;       // abort reads/writes on error

  { DTR Control Flow Values. }
  fDtrDisable        =   0;
  fDtrEnable         = $10;
  fDtrHandShake      = $20;

  { RTS Control Flow Values}
  fRtsDisable        =     0;
  fRtsEnable         = $1000;
  fRtsHandshake      = $2000;
  fRtsToggle         = $3000;

var
  DCB: TDCB;
  f: LongInt;

begin
  Result := False;
  if not GetCommState(AHandle, DCB) then Exit;

  f := fBinary +
       fAbortOnError +
       fParity +
       fDtrEnable ;

  if ACTS_RTS      then Inc(f, fOutxCtsFlow + fRtsHandshake) else Inc(f, fRtsEnable);
  if AxOn_xOff     then Inc(f, fOutX + fInX);

  with DCB do
  begin
    Flags    := f;
    BaudRate := ASpeed;
    ByteSize := ADataBits;
    Parity   := AParityType;
    StopBits := AStopBits;
  end;

  if not SetCommState(AHandle, DCB) then Exit;

  Result := True;
end;


procedure FillDefaultTimeouts(var T: TCommTimeouts);
begin
  T.ReadIntervalTimeout :=          50;  // MaxDWord;
  T.ReadTotalTimeoutMultiplier  :=  0;
  T.ReadTotalTimeoutConstant :=     MaxDWord;
  T.WriteTotalTimeoutMultiplier :=  0; //     MaxDWord;
  T.WriteTotalTimeoutConstant :=    0; //     MaxDWord-1;
end;

procedure FillExitTimeouts(var T: TCommTimeouts);
begin
  T.ReadIntervalTimeout :=          MaxDWord;
  T.ReadTotalTimeoutMultiplier  :=  0;
  T.ReadTotalTimeoutConstant :=     0;
  T.WriteTotalTimeoutMultiplier :=  0; //     MaxDWord;
  T.WriteTotalTimeoutConstant :=    0; //     MaxDWord-1;
end;

procedure TSerialPort.SetExitTimeouts;
var
  T: TCommTimeouts;
begin
  FillExitTimeouts(T);
  SetTimeouts(T);
end;


procedure TSerialPort.SaveParams;
begin
  SetTimeouts(OrgTimeouts);
end;

procedure TSerialPort.RestoreParams;
begin
  SetTimeouts(DefTimeouts);
end;

procedure TSerialPort.SetTimeouts(T: TCommTimeouts);
var
  j: Integer;
begin
  j := 0;
  while not SetCommTimeouts(FHandle, T) do
  begin
    Inc(j); if j = 10 then GlobalFail('TSerialPort.SetTimeouts SetCommTimeouts Error %d', [GetLastError]);
    ChkAbort;
  end;
end;

procedure TSerialPort.ReadStatus;
var
  j: Integer;
  CommStatus: DWORD;
begin
  j := 0;
  while not GetCommModemStatus(FHandle, CommStatus) do
  begin
    Inc(j); if j = 10 then GlobalFail('TSerialPort.ReadStatus GetCommModemStatus Error %d', [GetLastError]);
    ChkAbort;
  end;
  FCTS := CommStatus and MS_CTS_ON <> 0;
  FDSR := CommStatus and MS_DSR_ON <> 0;
{$IFNDEF RLSD}  FDCD := CommStatus and MS_RLSD_ON <> 0; {$ENDIF}
  FRI := CommStatus and MS_RING_ON <> 0;
end;


function TSerialPort.ReadNow: Integer;
begin
  Result := MaxD(MinD(PortInBufSize, ChkAbort), PortMinBufRead);
end;

procedure TSerialPort.SleepDown;
begin
  ResetEvt(oTempDown);
  TempDown := True;


  SetEvt(ReadOL.hEvent);
  SetEvt(StatOL.hEvent);

  SetMask(EV_TXEMPTY);
  SetExitTimeouts;

  WaitEvtsAll([oReadDowned, oStatusDowned], INFINITE);

  ResetEvt(oReadDowned);
  ResetEvt(oStatusDowned);

  SaveParams;

end;

procedure TSerialPort.WakeUp;
begin
  FCarrier := RealDCD;
  TempDown := False;
  SetEvt(oTempDown);

  WaitEvtsAll([oReadDowned, oStatusDowned], INFINITE);

  ResetEvt(oReadDowned);
  ResetEvt(oStatusDowned);
end;

procedure TSerialPort.CloseHW_A;
begin
  StatThr.WaitFor;
  FreeObject(StatThr);
end;

procedure TSerialPort.CloseHW_B;
begin
  ZeroHandle(FHandle);
end;


procedure TSerialPort.HWPurge;
var
  AV: Integer;
begin
  AV := 0;
  if TX in Typ then Inc(AV, PURGE_TXCLEAR or PURGE_TXABORT);
  if RX in Typ then Inc(AV, PURGE_RXCLEAR or PURGE_RXABORT);

  PurgeComm(FHandle, AV);
end;

destructor TSerialPort.Destroy;
begin
  StatThr.Terminated := True;
  SetEvt(WriteOL.hEvent);
  SetMask(EV_TXEMPTY);
  ReadThr.Terminated := True;
  SetExitTimeouts;
  inherited Destroy;
end;

constructor TSerialPort.Create;
var
  j: Integer;
begin

  inherited Create(TSerialInThread, TSerialOutThread);

  FHandle := AHandle;

{--- Status Thread}
  StatThr := TSerialStatusThr.Create;
  with StatThr do
  begin
    CP := Self;
    Priority := tpLower;
  end;

{--- Timeouts}
  j := 0;
  while not GetCommTimeouts(FHandle, OrgTimeouts) do
  begin
    Inc(j);
    if (j = 10) or (GetLastError <> ERROR_OPERATION_ABORTED) then GlobalFail('TSerialPort.Create GetCommTimeouts Error', [GetLastError]);
    ChkAbort;
  end;
  FillDefaultTimeouts(DefTimeouts);
  SetTimeouts(DefTimeouts);

{--- Escape Funcitons}
  SetLine(Windows.CLRDTR); FDTR := False;

  ReadStatus;
  UpdateLineStatus;

  StatThr.Suspended := False;
  WakeThreads;
  FCarrier := RealDCD;
end;

function TSerialPort.RealDCD: Boolean;
begin
  EnterCS(StatCS);
  ReadStatus;
  UpdateLineStatus;
  LeaveCS(StatCS);
  Result := FDCD;
end;

procedure TSerialPort.SetLine(AOptions: Integer);
var
  j: Integer;
begin
  j := 0;
  while not EscapeCommFunction(FHandle, AOptions) do
  begin
    Inc(j);
    if (j = 10) or (GetLastError <> ERROR_OPERATION_ABORTED) then GlobalFail('TSerialPort.SetLine EscapeCommFunction Error', [GetLastError]);
    ChkAbort;
  end;
end;

procedure TSerialPort.SetDTR(Value: Boolean);
const
  Cmd_DTR : array[Boolean] of Integer = (Windows.CLRDTR, Windows.SETDTR);
begin
  EnterCS(StatCS);
  if Value <> FDTR then
  begin
    SetLine(Cmd_DTR[Value]);
    FDTR := Value;
    UpdateLineStatus;
  end;
  LeaveCS(StatCS);
end;

procedure TSerialPort.SetRTS(Value: Boolean);
const
  Cmd_RTS : array[Boolean] of Integer = (Windows.CLRRTS, Windows.SETRTS);
begin
  GlobalFail('%s', ['SetRTS?']);
  EnterCS(StatCS);
  if Value <> FRTS then
  begin
    SetLine(Cmd_RTS[Value]);
    FRTS := Value;
    UpdateLineStatus;
  end;
  LeaveCS(StatCS);
end;

function TSerialPort.ChkAbort;
var
 e: DWORD;
 cs: TComStat;
 ee: TComError;
begin
  ClearCommError(FHandle, e, @cs);
  Result := cs.cbInQue;
  if e <> 0 then
  begin
    ee := TComError.Create;
    ee.Err := e;
    ee.cs := cs;
    InsComErr(ee);
  end;
end;


procedure TSerialPort.SetMask(Arg: Integer);
var
  j: Integer;
begin
  j := 0;
  while not SetCommMask(FHandle, Arg) do
  begin
    Inc(j);
    if (j = 10) or (GetLastError <> ERROR_OPERATION_ABORTED) then GlobalFail('TSerialStatusThr.ThreadExec SetCommMask Error %d', [GetLastError]);
    ChkAbort;
  end;
end;

class function TSerialStatusThr.ThreadName: string;
begin
  Result := 'Serial Port Status';
end;

procedure TSerialStatusThr.InvokeExec;


procedure DoTempDown;
begin
  CP.SetMask(0);
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    if NTdyn_SignalObjectAndWait(CP.oStatusDowned, CP.oTempDown, INFINITE, False) <> WAIT_OBJECT_0 then GlobalFail('%s', ['SignalObjectAndWait oStatusDowned']);
  end else
  begin
    SetEvt(CP.oStatusDowned);
    WaitEvtInfinite(CP.oTempDown);
  end;
  SetEvt(CP.oStatusDowned);
  Again := False;
end;

procedure DoGeneric;
var
  Actually: DWORD;
  b: Boolean;
begin
  EnterCS(CP.StatCS);
  CP.ReadStatus;
  CP.UpdateLineStatus;
  LeaveCS(CP.StatCS);


  b := WaitCommEvent(CP.FHandle, EvtMask, @CP.StatOL);

  if not b then
  begin
    case GetLastError of
      ERROR_IO_PENDING :
        begin
          b := GetOverLappedResult(CP.FHandle, CP.StatOL, Actually, not (CP.TempDown or Terminated));

          if not b then
          begin
            case GetLastError of
              ERROR_NOACCESS,
              ERROR_IO_INCOMPLETE,
              ERROR_OPERATION_ABORTED : CP.ChkAbort;
              else
              GlobalFail('TSerialStatusThr.ThreadExec GetOverLappedResult Error %d', [GetLastError]);
            end;
          end;
        end;
      ERROR_NOACCESS,
      ERROR_OPERATION_ABORTED: CP.ChkAbort;
      else
      GlobalFail('TSerialStatusThr.ThreadExec WaitCommEvent Error %d', [GetLastError]);
    end;
  end;
end;

begin
  if not Again then
  begin
    Again := True;
    CP.SetMask(ModemTraceMask);
  end;
  if CP.TempDown then DoTempDown else DoGeneric;
end;

function TSerialOutThread.Write(const Buf; Size: DWORD): DWORD;
var
  OL : POverlapped;
  r: Boolean;
begin
  OL := @TSerialPort(CP).WriteOL;
  r := WriteFile(CP.FHandle, Buf, Size, Result, OL);
  if not r then
  begin
    case GetLastError of
      ERROR_IO_PENDING :
        if GetOverLappedResult(CP.FHandle, OL^, Result, True) <> TRUE then
        begin
          case GetLastError of
            ERROR_NOACCESS,
            ERROR_OPERATION_ABORTED :TSerialPort(CP).ChkAbort;
            else
            GlobalFail('TSerialOutThread.Write GetOverLappedResult Error %d', [GetLastError]);
          end;
        end;
      ERROR_NOACCESS,
      ERROR_OPERATION_ABORTED: TSerialPort(CP).ChkAbort;
      else
      GlobalFail('TSerialOutThread.Write WriteFile Error %d', [GetLastError]);
    end;
  end;
end;

function TSerialInThread.Read(var Buf; Size: DWORD): DWORD;
var
  OL : POverlapped;
  r: Boolean;
begin
  OL := @CP.ReadOL;
  r := ReadFile(CP.FHandle, Buf, Size, Result, OL);
  if not r then
  begin
    case GetLastError of
      ERROR_IO_PENDING :
        if GetOverLappedResult(CP.FHandle, OL^, Result, not (CP.TempDown or Terminated)) <> TRUE then
        case GetLastError of
          ERROR_NOACCESS,
          ERROR_IO_INCOMPLETE,
          ERROR_OPERATION_ABORTED : TSerialPort(CP).ChkAbort;
          else
          GlobalFail('TSerialInThread.Read GetOverLappedResult Error %d', [GetLastError]);
        end;
      ERROR_NOACCESS,
      ERROR_OPERATION_ABORTED: TSerialPort(CP).ChkAbort;
      else
      GlobalFail('TSerialInThread.Read ReadFile Error %d', [GetLastError]);
    end;
  end;
end;







/////////////////////////////////////////////////////////////////////////
//                                                                     //
//                       FILE TRANSFER PROTOCOLS                       //
//                                                                     //
/////////////////////////////////////////////////////////////////////////


function  TOneWayProtocol.Timeout: Boolean;
begin
  if TimerExpired(TimeoutTimer)
  then
    Result := True
  else
    Result := False;
end;

function TBaseProtocol.TxClosed: Boolean;
begin
  Result := (T = nil) or (T.Stream = nil);
end;

function TBaseProtocol.RxClosed: Boolean;
begin
  Result := (R = nil) or (R.Stream = nil);
end;

procedure TBaseProtocol.CalcTimeout(var VTimeout: DWORD; AMax, AMin: DWORD);
begin
  VTimeOut := 81920 div MaxD(Speed, 300);
  If (VTimeOut < AMin) then VTimeOut := AMax else
    If (VTimeOut > AMax) then VTimeOut := AMax;
end;

procedure TBaseProtocol.CalcBlockSize(var VMax, VCur: DWORD; AMax, AMin: DWORD);
begin
  VMax := (MaxD(Speed, 300)*128) div 300;

  if VMax < AMin * 4 then VMax := AMin * 4 else
    if VMax > AMax then VMax := AMax;

  VCur := VMax div 4;
  if VCur < AMin then VCur := AMin;

  VMax := AMax;

  VCur := MinD(VMax, 1 shl (NumBits(VCur)-1));


end;

procedure TBaseProtocol.DbgLog(const s: string);
begin
  CustomInfo := s;
  FLogFile(Self, lfDebug);
end;

procedure TBaseProtocol.DbgLogFmt(const Fmt: string; const Args: array of const);
begin
  DbgLog(Format(Fmt, Args));
end;

procedure TBaseProtocol.Finish;
begin
  FreeObject(T);
  FreeObject(R);
end;

procedure TBaseProtocol.IncTotalErrors;
begin
  Inc(TotalErrors);
end;

procedure TOneWayProtocol.IncBlockErrors;
begin
  Inc(BlockErrors);
end;

constructor TBaseProtocol.Create;
begin
  inherited Create;
  CP := ACP;
end;

constructor TOneWayProtocol.Create;
begin
  inherited Create(ACP);
end;

destructor TBaseProtocol.Destroy;
begin
  if T <> nil then FreeObject(T.Stream);
  if R <> nil then FreeObject(R.Stream);
  Finish;
  inherited Destroy;
end;


function TBaseProtocol.Name: string;
begin
  Name := ProtocolNames[ID];
end;

function TOneWayProtocol.TimeoutValue: DWORD;
begin
  TimeoutValue := MultiTimeout([TimeoutTimer]);
end;

procedure TOneWayProtocol.SignalFinish;
begin
  if ProtocolError = ecOk then begin
    case ProtocolStatus of
      psAbortByLocal   : ProtocolError := ecAbortByLocal;
      psAbortByRemote  : ProtocolError := ecAbortByRemote;
      psTimeout        : ProtocolError := ecTimeout;
      psAbortNoCarrier : ProtocolError := ecAbortNoCarrier;
    end;
  end;
end;

function TOneWayProtocol.IsBiDir: Boolean;
begin
  Result := False;
end;

function TBiDirProtocol.IsBiDir: Boolean;
begin
  Result := True;
end;

procedure TBiDirProtocol.Start;
begin
  FAcceptFile := AAcceptFile;
  FFinishRece := AFinishRece;
  FGetNextFile := AGetNextFile;
  FFinishSend := AFinishSend;
  DoStart;
  T := TBatch.Create;
  R := TBatch.Create;
end;

procedure TBaseProtocol.DoStart;
begin
  ProtocolError := ecOK;
  TotalErrors := 0;
end;

procedure TOneWayProtocol.Start;
begin
  FAcceptFile := nil;
  FGetNextFile := nil;
  if Assigned(AAcceptFile) then
  begin
    R := TBatch.Create;
    PrepareReceive(AAcceptFile, AFinishRece)
  end else
  if Assigned(AGetNextFile) then
  begin
    T := TBatch.Create;
    PrepareTransmit(AGetNextFile, AFinishSend);
  end;
  DoStart;
end;

function TOneWayProtocol.NextStep: Boolean;
begin
  if Assigned(FAcceptFile) then Result := Receive else
  if Assigned(FGetNextFile) then Result := Transmit else
  begin
    Result := False;
    GlobalFail('%s', ['TOneWayProtocol.NextStep both FAcceptFile and FGetNextFile are unassigned']);
  end;
  if Result then Finish;
end;

class function TLampsThread.ThreadName: string;
begin
  Result := 'Lamps Watcher';
end;


constructor TLampsThread.Create;
begin
  inherited Create;
//  FreeOnTerminate := True;
  Priority := tpLower;
  oStatusChange := CreateEvtA;
end;

procedure TLampsThread.InvokeExec;
begin
  WaitEvtInfinite(oStatusChange);
  if Terminated then Exit;
  SendMessage(MainWinHandle, WM_UPDATELAMPS, 0, 0);
end;

destructor TLampsThread.Destroy;
begin
  ZeroHandle(oStatusChange);
  inherited Destroy;
end;

function TBatch.CPS;
var
  ela, a, i: Integer;
  fpos: DWORD;
begin
  i := -1;
  ela := uGetSystemTime - D.Start;
  fpos := D.FPos;
  if AOutUsed < fpos then Dec(fpos, AOutUsed);
  if fpos < D.FOfs then a := 0 else a := fpos - D.FOfs;
  if (ela > CPS_MinSecs) and (a > CPS_MinBytes) then i := a div ela;
  Result := i;
end;


procedure TBatch.ClearFileInfo;
begin
  D.FPos  := 0;
  D.Start := 0;
  D.FSize := 0;
  D.FOfs  := 0;
  D.Part  := 0;
  D.FTime := 0;
  D.ErrPos:= 0;
  D.StreamType := xstUnknown;
  D.FName := '';
end;

procedure TBatch.Clear;
begin
  FillChar(d, SizeOf(d), 0);
end;

function TBatch.Copy: TBatch;
begin
  Result := TBatch.Create;
  Result.D := D;
end;

class function TCommThread.ThreadName: string;
begin
  Result := 'Abstract Comm';
end;


end.


