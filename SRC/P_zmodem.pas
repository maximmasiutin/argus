unit p_Zmodem;

{$I DEFINE.INC}

interface

type
  TZmodemOption = (zmDirect, zm8k{, zmForceZRQInit});
  TZmodemOptionSet = set of TZmodemOption;

function CreateZModemProtocol(CP: Pointer; Opt: TZmodemOptionSet): Pointer;

implementation uses Windows, SysUtils, xMisc, xBase;

const
  StrandardHandshake = True;

type
  TFinishReason = (frUnk, frOK, frDelay, frRefuse);

  {Main Zmodem state table}
  TZmodemState = (
    {Transmit states}
    tzInitial,       {Allocates buffers, sends zrqinit}
    tzSendZRQI,
    tzHandshake,     {Wait for hdr (zrinit), rsend zrqinit on timout}
    tzStartFile,
    tzGetFile,       {Call NextFile, build ZFile packet}
    tzSendFile,      {Send ZFile packet}
    tzCheckFile,     {Wait for hdr (zrpos), set next state to tzData}
    tzStartData,     {Send ZData and next data subpacket}
    tzEscapeData,    {Check for header, escape next block}
    tzSendData,      {Wait for free space in buffer, send escaped block}
    tzWaitAck,       {Wait for Ack on ZCRCW packets}
    tzSendEof,       {Send eof}
    tzDrainEof,      {Wait for output buffer to drain}
//    tzFinDelay,      {Delay before finishing}
//    tzFinDelayDone,
    tzCheckEof,      {Wait for hdr (zrinit)}
    tzSendFinish,    {Send zfin}
    tzCheckFinish,   {Wait for hdr (zfin)}
    tzError,         {Cleanup after errors}
    tzCleanup,       {Release buffers and other cleanup}
    tzDone,          {Signal end of protocol}

    {Receive states}
    rzRqstFile,      {Send zrinit}
//    rzDelay,         {Delay handshake for Telix}
//    rzDelayDone,
//    rzFinDelay,      {Delay before finishing}
//    rzFinDelayDone,
    rzWaitFile,      {Waits for hdr (zrqinit, zrfile, zsinit, etc)}
    rzCollectFile,   {Collect file info into work block}
    rzSendInit,      {Extract send init info}
    rzSendBlock,     {Collect sendinit block}
    rzSync,          {Send ZrPos with current file position}
    rzStartFile,     {Extract file info, prepare writing, etc., put zrpos}
    rzStartData,     {Wait for hdr (zrdata)}
    rzCollectData,   {Collect data subpacket}
    rzGotData,       {Got dsp, put it}
    rzWaitEof,       {Wait for hdr (zreof)}
    rzEndOfFile,     {Close file, log it, etc}
    rzSendFinish,    {Send ZFin, go to rzWaitOO}
//    rzCollectFinish, {Check for OO, go to rzFinish}
//    rzGotOO,
    rzDrainFIN,
    rzError,         {Handle errors while file was open}
    rzWaitCancel,    {Wait for the cancel to leave the outbuffer}
    rzCleanup,       {Clean up buffers, etc.}
    rzDone);         {Signal end of protocol}

  {General header collection states}
  THeaderState = (
    hsNone,          {Not currently checking for a header}
    hsGotZPad,       {Got initial or second asterisk}
    hsGotZDle,       {Got ZDle}
    hsGotZBin,       {Got start of binary header}
    hsGotZBin32,     {Got start of binary 32 header}
    hsGotZHex,       {Got start of hex header}
    hsGotHeader);    {Got complete header}

  {Hex header collection states}
  HexHeaderStates = (
    hhFrame,         {Processing frame type char}
    hhPos1,          {Processing 1st position info byte}
    hhPos2,          {Processing 2nd position info byte}
    hhPos3,          {Processing 3rd position info byte}
    hhPos4,          {Processing 4th position info byte}
    hhCrc1,          {Processing 1st CRC byte}
    hhCrc2);         {Processing 2nd CRC byte}

  {Binary header collection states}
  BinaryHeaderStates = (
    bhFrame,         {Processing frame type char}
    bhPos1,          {Processing 1st position info byte}
    bhPos2,          {Processing 2nd position info byte}
    bhPos3,          {Processing 3rd position info byte}
    bhPos4,          {Processing 1th position info byte}
    bhCrc1,          {Processing 1st CRC byte}
    bhCrc2,          {Processing 2nd CRC byte}
    bhCrc3,          {Processing 3rd CRC byte}
    bhCrc4);         {Processing 4th CRC byte}

  {Only two states possible when receiving blocks}
  ReceiveBlockStates = (
    rbData,          {Receiving data bytes}
    rbCrc);          {Receiving block check bytes}

const
  {Zmodem file management options}
  zfWriteNewerLonger = 1;          {Transfer if new, newer or longer}
  zfWriteCrc         = 2;          {Not supported, same as WriteNewer}
  zfWriteAppend      = 3;          {Transfer if new, append if exists}
  zfWriteClobber     = 4;          {Transfer regardless}
  zfWriteNewer       = 5;          {Transfer if new or newer}
  zfWriteDifferent   = 6;          {Transfer if new or diff dates/lens}
  zfWriteProtect     = 7;          {Transfer only if new}


  MaxAttentionLen = 32;            {Maximum length of attention string}



type
     TZmodem = class(TOneWayProtocol)
     public
       function GetStateStr: string;                               override;
       procedure ReportTraf(txMail, txFiles: DWORD);             override;
       constructor Create(ACP : TPort; AOptions: TZmodemOptionSet);
       destructor Destroy; override;

    {Control}
       procedure PrepareReceive(AAcceptFile: TAcceptFile; AFinishRece: TFinishRece); override;
       procedure PrepareTransmit(AGetNextFile: TGetNextFile; AFinishSend: TFinishSend); override;
       procedure SetHandshakeTimer;
       procedure SetFinishTimer;
       procedure SetTransTimer;
       procedure Set1secTimer;

       function  Receive: Boolean; override;
       function  Transmit : Boolean; override;


     private
        TxFinishReason,
        RxFinishReason   : TFinishReason;
        GotZrQInit,
        FGotZrPos       : Boolean;
        {General}
        HandshakeDone   : Boolean;
        SaveStatus      : TProtocolStatus;
        LastFrame       : Byte;            {Holds last frame type for status}
        Terminator      : Byte;            {Current block type}
        ZmodemState     : TZmodemState;    {Current Zmodem state}
        HeaderState     : THeaderState;    {General header state}
        HexHdrState     : HexHeaderStates; {Current hex header state}
        BinHdrState     : BinaryHeaderStates; {Current binary header state}
        RcvBlockState   : ReceiveBlockStates; {Current receive block state}
        FileMgmtOverride: Boolean;            {True to override senders file mg opts}
        ReceiverRecover : Boolean;            {True to force file recovery}
        UseCrc32        : Boolean;            {True when using 32bit CRCs}
        CanCrc32        : Boolean;            {True when Crc32 capable}
        HexPending      : Boolean;            {True for next char in hex pair}
        EscapePending   : Boolean;            {True for next char in esc pair}
        EscapeAll       : Boolean;            {Escaping all ctl chars}   {!!.01}
        ControlCharSkip : Boolean;            {True to skip all ctrl chars} {!!.03}
        FileMgmtOpts    : DWORD;            {File mgmt opts rqst by sender}
        WorkSize        : DWORD;            {Index into working buffer}
        CanCount        : DWORD;            {Track contiguous <cancels>}
        HexChar         : DWORD;            {Saved hex value}
        CrcCnt          : DWORD;            {Number of CRC bytes rcv'd}
        LastFileOfs     : DWORD;         {File position reported by remote}
        AttentionStr    : array[1..MaxAttentionLen] of Byte; {Attn string value}

        {For controlling autoadjustment of block size}
        Options         : TZmodemOptionSet;
        GoodAfterBad    : DWORD;            {Holds count of good blocks}

        {Working buffers}
        DataBlockLen    : DWORD;            {Count of valid data in DataBlock}
        DataInTransit   : DWORD;         {Amount of unacked data in transit}
        WorkBlock       : PWorkBlock;      {Holds fully escaped data block}

        {Receiving...}
        RcvFrame        : Byte;            {Type of last received frame}
        RcvHeader       : TPosFlags;       {Received header}

        {Transmitting...}
        RcvBuffLen      : DWORD;         {Size of receiver's buffer}
        LastChar        : Byte;            {Last character sent}
        TransHeader     : TPosFlags;       {Header to transmit}
        MaxProtocolBlock: DWORD;
        ZModemTimeout   : DWORD;


       procedure FinishRece(Action: TTransferFileAction);
       procedure FinishSend(Action: TTransferFileAction);

       procedure GotZNak;
       procedure DoZSkip;
       procedure DoZFErr;

       procedure DeallocBuffers;
       procedure AllocBuffers;
       procedure InitData;

       procedure PutCharEscaped(AC : Byte);
       procedure UpdateBlockCheck(CurByte: Byte);
       procedure SendBlockCheck;
       function  VerifyBlockCheck : Boolean;
       procedure Cancel; override;
       function  GotCancel : Boolean;
       function  GetCharStripped(var C : Byte) : Boolean;
       procedure PutAttentionString;
       procedure PutCharHex(C : Byte);
       procedure PutHexHeader(FrameType : Byte);
       procedure PutBinaryHeader(FrameType : Byte);
       function  EscapeChar(C : Byte; var EC: Byte) : Boolean;
       procedure EscapeBlock(var Block : TDataBlock; BLen : DWORD);
       procedure GetCharEscaped(var C : Byte);
       procedure GetCharHex(var C : Byte);
       function  CollectHexHeader : Boolean;
       function  CollectBinaryHeader(Crc32 : Boolean) : Boolean;
       procedure CheckForHeader;
       function  BlockError(OkState, ErrorState : TZmodemState; MaxErrors : DWORD) : Boolean;
       function  ReceiveBlock(var Block : TDataBlock) : Boolean;
       function  ReceiveBlock_(var Block : TDataBlock) : Boolean;
       procedure ExtractFileInfo;
       procedure InsertFileInfo;
       procedure WriteDataBlock;

       function SendSync: Boolean;

       procedure TransmitBlock;
       procedure ExtractReceiverInfo;
       procedure GotZrPos(Err: Boolean);
       procedure ProcessHeader;
       procedure CheckCancel(AState: TZmodemState);

     end;


const
  ZmodemStateNames: array[TZmodemState] of string = (
    'ZModemTxInitial',
    'ZModemTxSendZRQI',
    'ZModemTxHandshake',
    'ZModemTxStartFile',
    'ZModemTxGetFile',
    'ZModemTxSendFile',
    'ZModemTxCheckFile',
    'ZModemTxStartData',
    'ZModemTxEscapeData',
    'ZModemTxSendData',
    'ZModemTxWaitAck',
    'ZModemTxSendEof',
    'ZModemTxDrainEof',
//    'ZModemTxFinDelay',
//    'ZModemTxFinDelayDone',
    'ZModemTxCheckEof',
    'ZModemTxSendFinish',
    'ZModemTxCheckFinish',
    'ZModemTxError',
    'ZModemTxCleanup',
    'ZModemTxDone',

    'ZModemRxRqstFile',
//    'ZModemRxDelay',
//    'ZModemRxDelayDone',
//    'ZModemRxFinDelay',
//    'ZModemRxFinDelayDone',
    'ZModemRxWaitFile',
    'ZModemRxCollectFile',
    'ZModemRxSendInit',
    'ZModemRxSendBlock',
    'ZModemRxSync',
    'ZModemRxStartFile',
    'ZModemRxStartData',
    'ZModemRxCollectData',
    'ZModemRxGotData',
    'ZModemRxWaitEof',
    'ZModemRxEndOfFile',
    'ZModemRxSendFinish',
//    'ZModemRxCollectFinish',
//    'ZModemRxGotOO',
    'ZModemRxDrainFIN',
    'ZModemRxError',
    'ZModemRxWaitCancel',
    'ZModemRxCleanup',
    'ZModemRxDone');

  ZModemCmdNames : array[0..18] of string = (
    'ZrQinit',
    'ZrInit',
    'ZsInit',
    'ZAck',
    'ZFile',
    'ZSkip',
    'ZNak',
    'ZAbort',
    'ZFin',
    'ZRpos',
    'ZData',
    'ZEof',
    'ZFerr',
    'ZCrc',
    'ZChallenge',
    'ZCompl',
    'ZCan',
    'ZFreeCnt',
    'ZCommand');

  {Compile-time constants}
  MinBlockSize = 64;              {Minimum data bytes on one zmodem frame}
  MaxHandshakeWait = 60;          {Secs to wait for first hdr }
  MaxBadBlocks = 20;              {Quit if this many bad blocks}
  DefFinishWaitZM = 30;           {Wait time for ZFins, 30 secs}

  {For estimating protocol transfer times}

  {For checking max block sizes}
  ZMaxBlock : array[Boolean] of DWORD = (1024, 8192);

  {Zmodem constants}
  ZPad       = Ord('*');                  {Pad}
  ZDle       = cCan;                 {Data link escape}
  ZBin       = Ord('A');                  {Binary header using Crc16}
  ZHex       = Ord('B');                  {Hex header using Crc16}
  ZBin32     = Ord('C');                  {Binary header using Crc32}

  {Zmodem frame types}
  ZrQinit    = 0;                   {Request init (to receiver)}
  ZrInit     = 1;                   {Init (to sender)}
  ZsInit     = 2;                   {Init (to receiver) (optional)}
  ZAck       = 3;                   {Acknowledge last frame}
  ZFile      = 4;                   {File info frame (to receiver)}
  ZSkip      = 5;                   {Skip to next file (to receiver)}
  ZNak       = 6;                   {Error receiving last data subpacket}
  ZAbort     = 7;                   {Abort protocol}
  ZFin       = 8;                   {Finished protocol}
  ZRpos      = 9;                   {Resume from this file position}
  ZData      = 10;                  {Data subpacket(s) follows}
  ZEof       = 11;                  {End of current file}
  ZFerr      = 12;                  {Error reading or writing file}
  ZCrc       = 13;                  {Request for file CRC (to receiver)}
  ZChallenge = 14;                  {Challenge the sender}
  ZCompl     = 15;                  {Complete}
  ZCan       = 16;                  {Cancel requested (to either)}
  ZFreeCnt   = 17;                  {Request diskfree}
  ZCommand   = 18;                  {Execute this command (to receiver)}

  {For various hex char manipulations}
  HexDigits : array[0..15] of Char = '0123456789abcdef';

  {For manipulating file management masks}
  FileMgmtMask = $07;              {Isolate file mgmnt values}
  FileSkipMask = $80;              {Skip file if dest doesn't exist}

  {Only supported conversion option}
  FileRecover = $03;               {Resume interrupted file transfer}

  {Data subpacket terminators}
  ZCrcE      = Ord('h');                {End  - last data subpacket of file}
  ZCrcG      = Ord('i');                {Go   - no response necessary}
  ZCrcQ      = Ord('j');                {Ack  - requests ZACK or ZRPOS}
  ZCrcW      = Ord('k');                {Wait - sender waits for answer}

  {Translate these escaped sequences}
  ZRub0      = Ord('l');                {Translate to $7F}
  ZRub1      = Ord('m');                {Translate to $FF}

  cDel       = $7F;
  cDelHi     = $FF;

  {Byte offsets for pos/flag bytes}
  ZF0 = 3;                         {Flag byte 3}
  ZF1 = 2;                         {Flag byte 2}
  ZF2 = 1;                         {Flag byte 1}
  ZF3 = 0;                         {Flag byte 0}
  ZP0 = 0;                         {Position byte 0}
  ZP1 = 1;                         {Position byte 1}
  ZP2 = 2;                         {Position byte 1}
  ZP3 = 3;                         {Position byte 1}

  {Bit masks for ZrInit}
  CanFdx  = $0001;           {Can handle full-duplex}
  CanOvIO = $0002;           {Can do disk and serial I/O overlaps}
  CanBrk  = $0004;           {Can send a break}
  CanCry  = $0008;           {Can encrypt/decrypt, not supported}
  CanLzw  = $0010;           {Can LZ compress, not supported}
  CanFc32 = $0020;           {Can use 32 bit CRC}
  EscAll  = $0040;           {Escapes all control chars, not supported}
  Esc8    = $0080;           {Escapes the 8th bit, not supported}

  {Bit masks for ZsInit}
  TESCtl  = $0040;           {Sender asks for escaped ctl chars, not supported}
  TESC8   = $0080;           {Sender asks for escaped hi bits, not supported}

  {Character constants}
  cDleHi  = cDle + $80;
  cXonHi  = cXon + $80;
  cXoffHi = cXoff + $80;

procedure TZModem.Set1secTimer;
begin
  NewTimerSecs(TimeoutTimer, 1);
end;

procedure TZModem.SetTransTimer;
begin
  NewTimerSecs(TimeoutTimer, ZModemTimeout * (2 + DWORD(zm8k in Options)));
end;


procedure TZmodem.SetHandshakeTimer;
begin
  NewTimerSecs(TimeoutTimer, ZModemTimeout * 2);
end;

procedure TZModem.SetFinishTimer;
begin
  NewTimerSecs(TimeoutTimer, ZModemTimeout);
end;

procedure TZmodem.DeallocBuffers;
  {-Release block and work buffers}
begin
  FreeMem(DataBlock, MaxProtocolBlock);
  FreeMem(WorkBlock, MaxProtocolBlock*2);
end;

procedure TZmodem.AllocBuffers;
begin
  MaxProtocolBlock := ZMaxBlock[zm8k in Options];
  GetMem(DataBlock, MaxProtocolBlock);
  GetMem(WorkBlock, MaxProtocolBlock*2);
end;

procedure TZmodem.InitData;
  {-Init the protocol data}
begin
    CheckType := bcCrc32;
    FillChar(AttentionStr, MaxAttentionLen, 0);
    UseCrc32 := True;
    CanCrc32 := True;

    BlockErrors := 0;
    TotalErrors := 0;
    ProtocolStatus := psOK;
    ProtocolError := ecOK;
    LastFileOfs := 0;

    FileMgmtOpts := zfWriteNewer;
    FileMgmtOverride := False;
    GoodAfterBad := 0;
    EscapePending := False;
    HexPending := False;
    EscapeAll := False;

end;

constructor TZmodem.Create;
begin
  inherited Create(ACP);
  Options := AOptions;
  AllocBuffers;
  InitData;
end;

destructor TZmodem.Destroy;
  {-Dispose of Zmodem}
begin
  DeallocBuffers;
  inherited Destroy;
end;


procedure TZmodem.PutCharEscaped(AC : Byte);
var
  EC: Byte;
begin
  if not EscapeChar(AC, EC) then LastChar := AC else
  begin
    {This character needs escaping, stuff a ZDle and escape it}
    CP.PutChar(ZDle);
    LastChar := EC;
  end;

  {Stuff the character}
  CP.PutChar(LastChar);
end;


procedure TZmodem.UpdateBlockCheck(CurByte: Byte);
  {-Updates the block check character (whatever it is)}
begin
    if UseCrc32 then
      BlockCheck := UpdateCrc32(CurByte, BlockCheck)
    else
      BlockCheck := UpdateCrc16Usd(CurByte, BlockCheck);
end;

procedure TZModem.SendBlockCheck;
  {-Makes final adjustment and sends the aBlockCheck character}
type
  QB = array[1..4] of Byte;
var
  I : Byte;
begin
    if UseCrc32 then begin
      {Complete and send a 32 bit CRC}
      BlockCheck := not BlockCheck;
      for I := 1 to 4 do
        PutCharEscaped(QB(BlockCheck)[I]);
    end else begin
      {Complete and send a 16 bit CRC}
      UpdateBlockCheck(0);
      UpdateBlockCheck(0);
      PutCharEscaped(Hi(BlockCheck));
      PutCharEscaped(Lo(BlockCheck));
    end;
end;

function TZmodem.VerifyBlockCheck : Boolean;
  {-checks the block check value}
begin
    {Assume a block check error}
    VerifyBlockCheck := False;

    if UseCrc32 then begin
      if BlockCheck <> CRC32_TEST then
        Exit
    end else begin
      UpdateBlockCheck(0);
      UpdateBlockCheck(0);
      if BlockCheck <> CRC16USD_TEST then
        Exit;
    end;

    {If we get here, the block check value is ok}
    VerifyBlockCheck := True;
end;

procedure TZModem.ReportTraf(txMail, txFiles: DWORD);
begin
  GlobalFail('TZModem.ReportTraf(%d,%d)', [txMail, txFiles]);
end;


procedure TZModem.Cancel;
  {-Sends the cancel string}
const
  {Cancel string is 8 CANs followed by 8 Backspaces}
  CancelStr : array[0..16] of Char =
    #24#24#24#24#24#24#24#24#8#8#8#8#8#8#8#8#0;

begin
//  TDevicePort(CP).Purge([TX]);
  {Send the cancel string}
  CP.Write(CancelStr, SizeOf(CancelStr));
  ProtocolStatus := psAbortByLocal;
end;

function TZmodem.GotCancel : Boolean;
  {-Return True if CanCount >= 5}
begin
    Inc(CanCount);
    if CanCount >= 5 then begin
      ProtocolStatus := psAbortByRemote;
      GotCancel := True;
    end else
      GotCancel := False;
end;

function TZmodem.GetCharStripped(var C : Byte) : Boolean;
  {-Get next char, strip hibit, discard Xon/Xoff, return False for no char}
begin
    {Get a character, discard Xon and Xoff}
    repeat

      if not CP.GetChar(C) then
      begin
        Result := False;
        Exit;
      end;

    until (zmDirect in Options) or ((C <> cXon) and (C <> cXoff));

    {Strip the high-order bit}
    C := C and $7F;

    {Handle cancels}
    if (C = cCan) then begin
      if GotCancel then begin
        Result := False;
        Exit
      end;
    end else
      CanCount := 0;

  Result := True;
end;

procedure TZmodem.PutAttentionString;
  {-Puts a string (#221 = Break, #222 = Delay)}
var
  I  : DWORD;
begin
    CP.Flsh;
    I := 1;
    while AttentionStr[I] <> 0 do begin
      case AttentionStr[I] of
        $DD : {Remote wants Break as his attention signal}
          {CP.SetBreak};
        $DE : {Remote wants us to pause for one second}
          Sleep(1000);
        else   {Remote wants us to send a normal char}
          CP.Write(AttentionStr[I], 1);
      end;
      Inc(I);
    end;
end;

procedure TZmodem.PutCharHex(C : Byte);
  {-Sends C as two hex ascii digits}
var
  B : Byte absolute C;
begin
    CP.PutChar(Byte(HexDigits[B shr 4]));
    CP.PutChar(Byte(HexDigits[B and $0F]));
end;

procedure TZModem.PutHexHeader(FrameType : Byte);
  {-Sends a hex header}
var
  SaveCrc32 : Boolean;
  Check     : DWORD;
  I         : Byte;
  C         : Byte;
begin
    {Initialize the aBlockCheck value}
    SaveCrc32 := UseCrc32;
    UseCrc32 := False;
    BlockCheck := CRC16USD_INIT;

    {Send the header and the frame type}
    CP.PutChar(ZPad);
    CP.PutChar(ZPad);
    CP.PutChar(ZDle);
    CP.PutChar(ZHex);
    PutCharHex(FrameType);
    UpdateBlockCheck(FrameType);

    {Send the position/flag bytes}
    for I := 0 to SizeOf(TransHeader)-1 do begin
      PutCharHex(TransHeader[I]);
      UpdateBlockCheck(TransHeader[I]);
    end;

    {Update Crc16 and send it (hex encoded)}
    UpdateBlockCheck(0);
    UpdateBlockCheck(0);
    Check := DWORD(BlockCheck);
    PutCharHex(Hi(Check));
    PutCharHex(Lo(Check));

    {End with a carriage return, hibit line feed}
    CP.PutChar(cCR);
    C := cLF or $80;
    CP.PutChar(C);

    {Conditionally send Xon}
    if (not (zmDirect in Options)) and ((FrameType <> ZFin) and (FrameType <> ZAck)) then
      CP.PutChar(cXon);

    {Note frame type for status}
    LastFrame := FrameType;

    {Restore crc type}
    UseCrc32 := SaveCrc32;
end;

procedure TZmodem.GetCharEscaped(var C : Byte);
  {-Get a character (handle data link escaping)}
begin
    ControlCharSkip := False;

    {Go get escaped char if we already have the escape}
    if not EscapePending then
    begin
      {Get a character}
      CP.GetChar(C);

      {Process char}
      if not (zmDirect in Options) then
      case C of
        cXon,
        cXoff,
        cXonHi,
        cXoffHi : begin
                    {unescaped control char, ignore it}
                    ControlCharSkip := True;
                    Exit;
                  end;
      end;

      {If not data link escape or cancel then just return the character}
      if (C <> ZDle) then begin
        CanCount := 0;
        Exit;
      end else if GotCancel then
        {Got 5 cancels, ZDle's, in a row}
        Exit;
    end;
    {Need another character, get it or say we're pending}
    if CP.CharReady then begin
      EscapePending := False;
      CP.GetChar(C);

      {If cancelling make sure we get at least 5 of them}
      if (C = cCan) then
      begin
        if GotCancel then Exit;
      end else
      begin
        {Must be an escaped character}
        CanCount := 0;
        case C of
          ZCrcE : {Last DataSubpacket of file}
            ProtocolStatus := psGotCrcE;
          ZCrcG : {Normal DataSubpacket, no response necessary}
            ProtocolStatus := psGotCrcG;
          ZCrcQ : {ZAck or ZrPos requested}
            ProtocolStatus := psGotCrcQ;
          ZCrcW : {DataSubpacket contains file information}
            ProtocolStatus := psGotCrcW;
          ZRub0 :         {Ascii delete}
            C := cDel;
          ZRub1 :         {Hibit Ascii delete}
            C := cDelHi;
          else            {Normal escaped character}
            C := C xor $40;
        end;
      end;
    end else
      EscapePending := True;
end;

procedure TZmodem.GetCharHex(var C : Byte);
  {-Return a character that was transmitted in hex}

  function NextHexNibble : Byte;
    {-Gets the next char, returns it as a hex nibble}
  var
    C : Byte;
  begin
      {Get the next char, assume it's ascii hex character}
      CP.GetChar(C);

      {Handle cancels}
      if (C = cCan) then begin
        if GotCancel then begin
          NextHexNibble := 0;
          Exit;
        end;
      end else
        CanCount := 0;

      {Ignore errors, they'll eventually show up as bad blocks}
      NextHexNibble := Pos(Char(C), HexDigits) - 1;
  end;

begin
    if not HexPending then HexChar := NextHexNibble shl 4;
    if CP.CharReady then begin
      HexPending := False;
      Inc(HexChar, NextHexNibble);
      C := HexChar;
    end else
      HexPending := True;
end;

function TZmodem.CollectHexHeader : Boolean;
  {-Gets the data and trailing portions of a hex header}
var
  C : Byte;
begin
    {Assume the header isn't ready}
    CollectHexHeader := False;

    GetCharHex(C);
    if HexPending or (ProtocolStatus = psAbortByRemote) then
      Exit;

    {Init block check on startup}
    if HexHdrState = hhFrame then begin
      BlockCheck := CRC16USD_INIT;
      UseCrc32 := False;
    end;

    {Always update the block check}
    UpdateBlockCheck(C);

    {Process this character}
    case HexHdrState of
      hhFrame :
        RcvFrame := C;
      hhPos1..hhPos4 :
        RcvHeader[Ord(HexHdrState)-1] := C;
      hhCrc1 :
        {just keep going} ;
      hhCrc2 :
        if not VerifyBlockCheck then begin
          ProtocolStatus := psBlockCheckError;
          IncTotalErrors;
          FLogFile(Self, lfBadCRC);
          HeaderState := hsNone;
        end else begin
          {Say we got a good header}
          CollectHexHeader := True;
        end;
    end;

    {Go to next state}
    if HexHdrState <> hhCrc2 then
      Inc(HexHdrState)
    else
      HexHdrState := hhFrame;                                       
end;

function TZmodem.CollectBinaryHeader(Crc32 : Boolean) : Boolean;
  {-Collects a binary header, returns True when ready}
var
  C : Byte;
begin
    {Assume the header isn't ready}
    CollectBinaryHeader := False;

    {Get the waiting character}
    GetCharEscaped(C);
    if EscapePending or (ProtocolStatus = psAbortByRemote) then
      Exit;
    if ControlCharSkip then
      Exit;

    {Init block check on startup}
    if BinHdrState = bhFrame then begin
      UseCrc32 := Crc32;
      if UseCrc32 then BlockCheck := CRC32_INIT
                  else BlockCheck := CRC16USD_INIT;
    end;

    {Always update the block check}
    UpdateBlockCheck(C);

    {Process this character}
    case BinHdrState of
      bhFrame :
        RcvFrame := C;
      bhPos1..bhPos4 :
        RcvHeader[Ord(BinHdrState)-1] := C;
      bhCrc2 :
        if not UseCrc32 then begin
          if not VerifyBlockCheck then begin
            ProtocolStatus := psBlockCheckError;
            IncTotalErrors;
            FLogFile(Self, lfBadCRC);
            HeaderState := hsNone;
          end else begin
            {Say we got a good header}
            CollectBinaryHeader := True;
          end;
        end;
      bhCrc4 :
        {Check the Crc value}
        if not VerifyBlockCheck then begin
          ProtocolStatus := psBlockCheckError;
          IncTotalErrors;
          FLogFile(Self, lfBadCRC);
          HeaderState := hsNone;
        end else begin
          {Say we got a good header}
          CollectBinaryHeader := True;
        end;
    end;

    {Go to next state}
    if BinHdrState <> bhCrc4 then
      Inc(BinHdrState)
    else
      BinHdrState := bhFrame;                                       
end;

procedure TZmodem.CheckForHeader;
  {-Samples input_stream for start of header}
var
  C : Byte;
begin
    {Assume no header ready}
    ProtocolStatus := psNoHeader;

    {Process potential header characters}
    while CP.CharReady do begin

      {Only get the next char if we don't know the header type yet}
      case HeaderState of
        hsNone, hsGotZPad, hsGotZDle :
          if not GetCharStripped(C) then
            Exit;
      end;

      {Try to accumulate the start of a header}
      ProtocolStatus := psNoHeader;
      case HeaderState of
        hsNone :
          if C = ZPad then
            HeaderState := hsGotZPad;
        hsGotZPad :
          case C of
            ZPad : ;
            ZDle : HeaderState := hsGotZDle;
            else   HeaderState := hsNone;
          end;
        hsGotZDle :
          case C of
            ZBin   :
              begin
                HeaderState := hsGotZBin;
                BinHdrState := bhFrame;
                EscapePending := False;
              end;
            ZBin32 :
              begin
                HeaderState := hsGotZBin32;
                BinHdrState := bhFrame;
                EscapePending := False;
              end;
            ZHex   :
              begin
                HeaderState := hsGotZHex;
                HexHdrState := hhFrame;
                HexPending := False;
              end;
            else
              HeaderState := hsNone;
          end;
        hsGotZBin :
          if CollectBinaryHeader(False) then
            HeaderState := hsGotHeader;
        hsGotZBin32 :
          if CollectBinaryHeader(True) then
            HeaderState := hsGotHeader;
        hsGotZHex :
          if CollectHexHeader then
            HeaderState := hsGotHeader;
      end;

      {If we just got a header, note file pos and frame type}
      if HeaderState = hsGotHeader then begin
        ProtocolStatus := psGotHeader;
        case LastFrame of
          ZrPos, ZAck, ZData, ZEof :
            {Header contained a reported file position}
            LastFileOfs := Integer(RcvHeader);
        end;

        {Note frame type for status}
        LastFrame := RcvFrame;

        {...and leave}
        Exit;
      end;

      {Also leave if we got any errors or we got a cancel request}
      if (ProtocolError <> ecOK) or
         (ProtocolStatus = psAbortByRemote) then
        Exit;
    end;
end;

function TZmodem.BlockError(OkState, ErrorState : TZmodemState; MaxErrors : DWORD) : Boolean;
  {-Handle routine block/timeout errors, return True if error}
begin
    IncBlockErrors;
    IncTotalErrors;
    if BlockErrors > MaxErrors then begin
      BlockError := True;
      Cancel;
      ProtocolError := ecTooManyErrors;
      ZmodemState := ErrorState;
    end else begin
      BlockError := False;
      ZmodemState := OkState;
    end;
end;


function TZmodem.ReceiveBlock(var Block : TDataBlock) : Boolean;
begin
  Result := ReceiveBlock_(Block);
  if Result then begin R.D.BlkLen := DataBlockLen end;
end;

function TZmodem.ReceiveBlock_(var Block : TDataBlock) : Boolean;
  {-Get a binary data subpacket, return True when block complete (or error)}
var
  C : Byte;
begin
    {Assume the block isn't ready}
    Result := False;

    while CP.CharReady do begin
      {Handle first pass}
      if (DataBlockLen = 0) and (RcvBlockState = rbData) then
      begin
        if UseCrc32 then BlockCheck := CRC32_INIT
                    else BlockCheck := CRC16USD_INIT;
      end;

      {Get the waiting character}
      ProtocolStatus := psOK;
      GetCharEscaped(C);
      if EscapePending or (ProtocolStatus = psAbortByRemote) then
        Exit;
      if ControlCharSkip then
        Exit;                                                        

      {Always update the block check}
      UpdateBlockCheck(C);

      case RcvBlockState of
        rbData :
          case ProtocolStatus of
            psOK :     {Normal character}
              begin
                {Check for a long block}
                Inc(DataBlockLen);
                if DataBlockLen > MaxProtocolBlock then begin
                  FLogFile(Self, lfBadPkt);
                  ProtocolStatus := psLongPacket;
                  IncTotalErrors;
                  IncBlockErrors;
                  Result := True;
                  Exit;
                end;

                {Store the character}
                Block[DataBlockLen] := C;
              end;

            psGotCrcE,
            psGotCrcG,
            psGotCrcQ,
            psGotCrcW : {End of DataSubpacket - get/check CRC}
              begin
                RcvBlockState := rbCrc;
                CrcCnt := 0;
                SaveStatus := ProtocolStatus;
              end;
          end;

        rbCrc :
          begin
            Inc(CrcCnt);
            if (UseCrc32 and (CrcCnt = 4)) or
               (not UseCrc32 and (CrcCnt = 2)) then begin
              if not VerifyBlockCheck then begin
                ProtocolStatus := psBlockCheckError;
                IncBlockErrors;
                IncTotalErrors;
                FLogFile(Self, lfBadCRC);
              end else
                {Show proper status}
                ProtocolStatus := SaveStatus;

              {Say block is ready for processing}
              Result := True;
              Exit;
            end;
          end;
      end;
    end;
end;


procedure TZmodem.ExtractFileInfo;
  {-Extracts file information into fields}
var
  BlockPos  : Integer;
  I         : Integer;
  S         : string;
  S1        : string;
  S1Len     : Integer;
begin
    {Extract the file name from the data block}
    BlockPos := 1; S := '';
    while (DataBlock^[BlockPos] <> 0) and (BlockPos < 255) do begin
      S := S + Char(DataBlock^[BlockPos]);
      if S[BlockPos] = '/' then S[BlockPos] := '\';
      Inc(BlockPos);
    end;
    {Set Pathname}
    R.D.FName := S;

    {Extract the file size}
    I := 1;
    Inc(BlockPos);
    S1 := '';
    while (DataBlock^[BlockPos] <> 0) and
          (DataBlock^[BlockPos] <> Ord(' ')) and
          (I <= 255) do begin
      S1 := S1 + Char(DataBlock^[BlockPos]);
      Inc(I); Inc(BlockPos);
    end;
    Dec(I);
    S1Len := I;
    if S1Len = 0 then R.D.FSize := 0 else
    begin
      R.D.FSize := Vl(S1);
      if R.D.FSize = INVALID_FILE_SIZE then R.D.FSize := 0; {Invalid date format, just ignore}
    end;

    {Extract the file date/time stamp}
    I := 1;
    Inc(BlockPos);
    S1 := '';
    while (DataBlock^[BlockPos] <> 0) and
          (DataBlock^[BlockPos] <> Ord(' ')) and
          (I <= 255) do begin
      S1 := S1 + Char(DataBlock^[BlockPos]);
      Inc(I);
      Inc(BlockPos);
    end;
    S1 := TrimZeros(S1);
    if S1 = '' then
      R.D.FTime := uGetSystemTime
    else
      R.D.FTime := OctalStr2Long(S1);
end;

procedure TZmodem.WriteDataBlock;
  {-Call WriteProtocolBlock for the last received DataBlock}
begin
  if DataBlockLen > 0 then
  begin
    DataBlockLen := MinD(DataBlockLen, R.D.FSize - DWORD(R.D.FPos));
    SetLastError(0);
    if (DataBlockLen > 0) and (R.Stream.Write(DataBlock^, DataBlockLen) = DataBlockLen) and (GetLastError = 0) then
    begin
      Inc(R.D.FPos, DataBlockLen);
    end else
    begin
      FinishRece(aaSysError);
      ProtocolError := ecTooManyErrors;
    end;
    DataBlockLen := 0;
  end;
end;

procedure TZmodem.PrepareReceive;
  {-Prepare to receive Zmodem parts}
begin
    RxFinishReason := frOK;
    FAcceptFile := AAcceptFile;
    FFinishRece := AFinishRece;

    R.Clear;

    InitData;

    R.D.Start := 0;
    R.D.BlkLen := 0;
    CalcTimeout(ZModemTimeout, 120, 5);

    {Flush input buffer}
//    TDevicePort(CP).Purge([RX]);

    GotZrQInit := (BatchNo = 0) {and (not (zmForceZRQInit in Options))};
    ZmodemState := rzWaitFile;
    Set1secTimer;
    HeaderState := hsNone;
end;

function TZModem.Receive: Boolean;

procedure DoRefuse;
begin
  R.D.FPos := R.D.FSize;
  R.D.FOfs := R.D.FSize;
  LastFileOfs := R.D.FSize;
  RxFinishReason := frRefuse;
  ZmodemState := rzSync;
end;

procedure DoSkip;
begin
  PutHexHeader(ZFerr);
  ProtocolStatus := psSkipFile;
  FinishRece(aaAcceptLater);
  ZmodemState := rzRqstFile;
end;

function Skip: Boolean;
begin
  Result := FileRefuse or FileSkip;
  if not Result then Exit;
//  TDevicePort(CP).Purge([RX]);
  if FileSkip then
  begin
    DoSkip;
  end else
  if FileRefuse then
  begin
    DoRefuse;
  end;
end;

var
  Finished  : Boolean;

  NewData   : Boolean;
begin

    CheckCancel(rzError);

    NewData := CP.CharReady;

    repeat


      {Preprocess header requirements}
      case ZmodemState of
        rzWaitFile,
        rzStartData,
        rzWaitEof :
            {Header might be present, try to get one}
            if NewData then begin
              CheckForHeader;
              if ProtocolStatus = psAbortByRemote then
                ZmodemState := rzError;
            end else if Timeout then
            {Timed out waiting for something, let state machine handle it}
            ProtocolStatus := psTimeout
            else
            {Indicate that we don't have a header}
            ProtocolStatus := psNoHeader;
      end;

      {Main state processor}
      case ZmodemState of

        rzRqstFile :
          begin
            CanCount := 0;

            {Init pos/flag bytes to zero}
            Integer(TransHeader) := 0;

            {Set our receive options}
            TransHeader[ZF0] := CanFdx or     {Full duplex}
                                CanOvIO or    {Overlap I/O}
                          //    CanBrk or     {Can send break}
                                CanFc32;      {Use Crc32 on frames}

            {Send the header}
            PutHexHeader(ZrInit);

            ZmodemState := rzWaitFile;
            HeaderState := hsNone;
            SetHandshakeTimer;
          end;

        rzSendBlock :
          if NewData then
          begin
            {Collect the data subpacket}
            if ReceiveBlock(DataBlock^) then
              if (ProtocolStatus = psBlockCheckError) or
                 (ProtocolStatus = psLongPacket) then
                {Error receiving block, go try again}
                ZmodemState := rzRqstFile
              else
                {Got block OK, go process}
                ZmodemState := rzSendInit
            else if ProtocolStatus = psAbortByRemote then
              ZmodemState := rzError;
          end else if Timeout then begin
            {Timed out waiting for block...}
            FLogFile(Self, lfTimeout);
            IncBlockErrors;
            IncTotalErrors;
            if BlockErrors < DefHandshakeRetry then begin
              PutHexHeader(ZNak);
              SetHandshakeTimer;
              ZmodemState := rzWaitFile;
              HeaderState := hsNone;
            end else
              ZmodemState := rzCleanup;
          end;


        rzSendInit :
          begin
            {Save attention string}
            Move(DataBlock^, AttentionStr, MaxAttentionLen);

            {Turn on escaping if transmitter requests it}
            EscapeAll := (RcvHeader[ZF0] and EscAll) = EscAll;

            {Needs an acknowledge}
            PutHexHeader(ZAck);
            {Go wait for ZFile packet}
            ZmodemState := rzWaitFile;
            SetHandshakeTimer;
          end;

        rzWaitFile :
          case ProtocolStatus of
            psGotHeader :
              begin
                case RcvFrame of
                  ZrQInit : {Go send ZrInit}
                  begin
                    GotZrQInit := True;
                    ZmodemState := rzRqstFile;
                  end;
                  ZFile : {Beginning of file transfer attempt}
                    begin
                      {Save file mgmt options (if not overridden)}
                      if not FileMgmtOverride then
                        FileMgmtOpts := RcvHeader[ZF1];

                      {Set file mgmt default if none specified}
                      if FileMgmtOpts = 0 then
                        FileMgmtOpts := zfWriteProtect;

                      {Start collecting the ZFile's data subpacket}
                      ZmodemState := rzCollectFile;
                      BlockErrors := 0;
                      DataBlockLen := 0;
                      RcvBlockState := rbData;
                      SetHandshakeTimer;
                    end;

                  ZSInit :  {Sender's transmission options}
                    begin
                      {Start collecting ZSInit's data subpacket}
                      BlockErrors := 0;
                      DataBlockLen := 0;
                      RcvBlockState := rbData;
                      SetHandshakeTimer;
                      ZmodemState := rzSendBlock;
                    end;

                  ZFreeCnt : {Sender is requesting a count of our freespace}
                    begin
                      PutHexHeader(ZNak);
                    end;

                  ZCommand : {Commands not implemented}
                    begin
                      PutHexHeader(ZNak);
                    end;

                  ZCompl,
                  ZFin:      {Finished}
                    if not GotZRQInit then
                    begin
                      GotZRQInit := True;
                      ZmodemState := rzRqstFile;
                    end else
                    begin
                      ZmodemState := rzSendFinish;
                      BlockErrors := 0;
                    end;
                end;
                SetHandshakeTimer;
              end;
            psNoHeader :
              {Keep waiting for a header} ;
            psBlockCheckError,
            psTimeout :
              begin
                BlockError(rzRqstFile, rzCleanup, DefHandshakeRetry);
                if BlockErrors > 2 then FLogFile(Self, lfTimeout);
              end;
          end;

        rzCollectFile :
           if NewData then
           begin
            {Collect the data subpacket}
            if ReceiveBlock(DataBlock^) then
              if (ProtocolStatus = psBlockCheckError) or
                 (ProtocolStatus = psLongPacket) then
                {Error getting block, go try again}
                ZmodemState := rzRqstFile
              else
                {Got block OK, go extract file info}
                ZmodemState := rzStartFile
            else if ProtocolStatus = psAbortByRemote then
              ZmodemState := rzError;
           end else if Timeout then begin
            {Timeout collecting block}
            FLogFile(Self, lfTimeout);
            IncBlockErrors;
            IncTotalErrors;
            if BlockErrors < DefHandshakeRetry then begin
              PutHexHeader(ZNak);
              SetHandshakeTimer;
            end else
              ZmodemState := rzCleanup;
           end;


        rzStartFile :
          begin

            R.ClearFileInfo;
            {Got the data subpacket to the ZFile, extract the file info}
            ExtractFileInfo;

            {Call user's LogFile function}
            ProtocolStatus := psOK;

            {Accept this file}

            FGotZrPos := False;

            case FAcceptFile(Self) of
              aaOK :
                begin                   
                  {Go send the initial ZrPos}
                  ZmodemState := rzSync;
                end;
              aaRefuse:
                DoRefuse;
              aaAcceptLater:
                DoSkip;
              aaAbort:
                begin
                  Cancel;
                  ZmodemState := rzError;
                end;
              else GlobalFail('%s', ['ZModem FAcceptFile(Self) unknown state']);
            end;
          end;

        rzSync :
          begin
            {Incoming data will just get discarded so flush inbuf now}
//            TDevicePort(CP).Purge([RX]);

            {Insert file size into header and send to remote}
            Integer(TransHeader) := R.D.FPos;
            PutHexHeader(ZrPos);

            {Set status info}
            ZmodemState := rzStartData;
            HeaderState := hsNone;
            SetHandshakeTimer;
          end;

        rzStartData :
          case ProtocolStatus of
            psGotHeader :
              case RcvFrame of
                ZData :  {One or more data subpackets follow}
                  begin
                    if R.D.FPos <> LastFileOfs then begin
                      FLogFile(Self, lfBadPkt);
                      IncBlockErrors;
                      IncTotalErrors;
                      if BlockErrors > MaxBadBlocks then begin
                        Cancel;
                        ProtocolError := ecTooManyErrors;
                        ZmodemState := rzError;
                      end else
                      begin
                        PutAttentionString;
                        ZmodemState := rzSync;
                      end;  
                    end else begin
                      ZmodemState := rzCollectData;
                      DataBlockLen := 0;
                      RcvBlockState := rbData;
                      SetHandshakeTimer;
                   end;
                 end;
                ZNak : {Nak received}
                  begin
                    GotZNak;
                    if BlockErrors > MaxBadBlocks then begin
                      Cancel;
                      ProtocolError := ecTooManyErrors;
                      ZmodemState := rzError;
                    end else
                      {Resend ZrPos}
                      ZmodemState := rzSync;
                  end;
                ZFile : {File frame}
                  {Already got a File frame, just go send ZrPos again}
                  ZmodemState := rzSync;                             
                ZEof : {End of current file}
                  begin
                    ProtocolStatus := psEndFile;
                    ZmodemState := rzEndOfFile;
                  end;
                else begin
                  {Error during GetHeader}
                  FLogFile(Self, lfBadHdr);
                  IncTotalErrors;
                  IncBlockErrors;
                  if BlockErrors > MaxBadBlocks then begin
                    Cancel;
                    ProtocolError := ecTooManyErrors;
                    ZmodemState := rzError;
                  end else
                  begin
                    PutAttentionString;
                    ZmodemState := rzSync;
                  end;  
                end;
              end;
            psNoHeader :
              {Just keep waiting for header} ;
            psBlockCheckError,
            psTimeout :
              begin
                BlockError(rzSync, rzError, DefHandshakeRetry);
                FLogFile(Self, lfTimeout);
              end;
          end;

        rzCollectData :
          if not Skip then
          if NewData then
          begin
            SetHandshakeTimer;

            {Collect the data subpacket}
            if ReceiveBlock(DataBlock^) then begin

              {Block is okay -- process it}
              case ProtocolStatus of
                psAbortByRemote : {Cancel requested}
                  ZmodemState := rzError;
                psGotCrcW : {Send requests a wait}
                  begin
                    {Write this block}
                    WriteDataBlock;
                    if ProtocolError = ecOK then begin
                      {Acknowledge with the current file position}
                      Integer(TransHeader) := R.D.FPos;
                      PutHexHeader(ZAck);
                      ZmodemState := rzStartData;
                      HeaderState := hsNone;
                    end else begin
                      Cancel;
                      ZmodemState := rzError;
                    end;
                  end;
                psGotCrcQ : {Ack requested}
                  begin
                    {Write this block}
                    WriteDataBlock;
                    if ProtocolError = ecOK then begin
                      Integer(TransHeader) := R.D.FPos;
                      PutHexHeader(ZAck);
                      {Don't change state - will get next data subpacket}
                    end else begin
                      Cancel;
                      ZmodemState := rzError;
                    end;
                  end;
                psGotCrcG : {Normal subpacket - no response necessary}
                  begin
                    {Write this block}
                    WriteDataBlock;
                    if ProtocolError <> ecOK then begin
                      Cancel;
                      ZmodemState := rzError;
                    end;
                  end;
                psGotCrcE : {Last data subpacket}
                  begin
                    {Write this block}
                    WriteDataBlock;
                    if ProtocolError = ecOK then begin
                      ZmodemState := rzWaitEof;
                      HeaderState := hsNone;
                      BlockErrors := 0;
                    end else begin
                      Cancel;
                      ZmodemState := rzError;
                    end;
                  end;
                else begin
                  {Error in block}
                  if BlockErrors < MaxBadBlocks then begin
                    PutAttentionString;
                    ZmodemState := rzSync;
                  end else begin
                    Cancel;
                    ProtocolError := ecTooManyErrors;
                    ZmodemState := rzError;
                  end;
                end;
              end;

              {Prepare to collect next block}
              if ZmodemState <> rzError then
              begin
                DataBlockLen := 0;
                RcvBlockState := rbData;
              end; 
            end else if ProtocolStatus = psAbortByRemote then
              ZmodemState := rzError

          end else if Timeout then begin
            {Timeout collecting datasubpacket}
            FLogFile(Self, lfTimeout);
            IncBlockErrors;
            IncTotalErrors;
            if BlockErrors < MaxBadBlocks then begin
              PutAttentionString;
              ZmodemState := rzSync;
            end else begin
              Cancel;
              ZmodemState := rzError;
            end;
          end;

        rzWaitEof :
          case ProtocolStatus of
            psGotHeader :
              case RcvFrame of
                ZEof : {End of current file}
                  begin
                    ProtocolStatus := psEndFile;
                    FinishRece(aaOK);
                    {Go get the next file}
                    ZmodemState := rzRqstFile;
                  end;
                else begin
                  {Error during GetHeader}
                  FLogFile(Self, lfBadHdr);
                  IncTotalErrors;
                  IncBlockErrors;
                  if BlockErrors > MaxBadBlocks then begin
                    Cancel;
                    ProtocolError := ecTooManyErrors;
                    ZmodemState := rzError;
                  end else
                  begin
                    PutAttentionString;
                    ZmodemState := rzSync;
                  end;
                end;
              end;
            psNoHeader :
              {Just keep collecting rest of header} ;
            psBlockCheckError,
            psTimeout :
              begin
                BlockError(rzSync, rzError, DefHandshakeRetry);
                FLogFile(Self, lfTimeout);
              end;
          end;

        rzEndOfFile :
          if R.D.FPos = LastFileOfs then
          begin
            FinishRece(aaOK);
            ZmodemState := rzRqstFile;
          end else
          begin
            ZmodemState := rzSync;
          end;

        rzSendFinish :
          begin
            {Insert file position into header}
            Integer(TransHeader) := R.D.FPos;
            PutHexHeader(ZFin);
            FLogFile(Self, lfBatchReceEnd);
            SetFinishTimer;
            ZModemState := rzDrainFIN;
          end;

        rzDrainFIN:
          if (CP.OutUsed = 0) or Timeout then ZmodemState := rzCleanup {else Sleep(100)};

        rzError :
          begin
            FinishRece(aaAbort);

            {Wait for cancel to go out}
            if (CP.OutUsed > 0) then
            begin
              SetTransTimer;
              ZmodemState := rzWaitCancel;
            end else
              ZmodemState := rzCleanup;
          end;

        rzWaitCancel :
          {Cancel went out or we timed out, doesn't matter which}
          ZmodemState := rzCleanup;

        rzCleanup :
          begin
//            TDevicePort(CP).Purge([RX]);
            ZmodemState := rzDone;
            SignalFinish;
          end;
      end;
 
      {Stay in state machine or leave?}
      case ZmodemState of
        {Stay in state machine for these states}
        rzRqstFile,
        rzSendInit,
        rzSync,
        rzStartFile,
        rzGotData,
        rzEndOfFile,
        rzSendFinish,
//        rzGotOO,
        rzError,
//        rzDelayDone,
//        rzFinDelayDone,
        rzCleanup            : Finished := False;

        {Stay in state machine only if more data ready}
        rzSendBlock,
        rzWaitFile,
        rzWaitEof,
        rzCollectData,
        rzStartData,
//        rzCollectFinish,
        rzCollectFile        : Finished := not CP.CharReady;

        {Exit state machine on these states (waiting for trigger hit)}
        rzDrainFIN,
//        rzDelay,
//        rzFinDelay,
        rzWaitCancel,
        rzDone               : Finished := True;
        else                   Finished := True;
      end;

      {Clear header state if we just processed a header}
      if (ProtocolStatus = psGotHeader) or
         (ProtocolStatus = psNoHeader) then
        ProtocolStatus := psOK;
      if HeaderState = hsGotHeader then
        HeaderState := hsNone;

      CP.Flsh;
      NewData := True;
    until Finished;

  if ZModemState = rzCollectData then R.D.Part := DataBlockLen else R.D.Part := 0;
  OutFlow := ZmodemState = rzDrainFIN;
  Result := ZModemState = rzDone;
end;

procedure TZmodem.PutBinaryHeader(FrameType : Byte);
  {-Sends a binary header (Crc16 or Crc32)}
var
  I : Integer;
begin
    UseCrc32 := CanCrc32;

    {Send '*'<DLE>}
    CP.PutChar(ZPad);
    CP.PutChar(ZDle);

    {Send frame identifier}
    if UseCrc32 then begin
      CP.PutChar(ZBin32);
      BlockCheck := CRC32_INIT;
    end else begin
      CP.PutChar(ZBin);
      BlockCheck := CRC16USD_INIT;
    end;

    {Send frame type}
    PutCharEscaped(FrameType);
    UpdateBlockCheck(FrameType);

    {Put the position/flags data bytes}
    for I := 0 to 3 do begin
      PutCharEscaped(TransHeader[I]);
      UpdateBlockCheck(TransHeader[I]);
    end;

    {Put the Crc bytes}
    SendBlockCheck;

    {Note frame type for status}
    LastFrame := FrameType;
end;

function TZmodem.EscapeChar(C : Byte; var EC: Byte) : Boolean;
  {-Return True if C needs to be escaped}
var
  C1 : Byte;
  C2 : Byte;
begin
  if zmDirect in Options then
  begin
    Result := C = zDle;
    if Result then EC := C xor $40;
  end else
  begin
    {Might need escaping}
    if EscapeAll and ((C and $60) = 0) then begin
      {Definitely needs escaping}
      EC := C xor $40;
      Result := True;
    end else
    case C of
      cXon, cXoff, cDle,        {Escaped control chars}
      cXonHi, cXoffHi, cDleHi,  {Escaped hibit control chars}
      ZDle :                    {Escape the escape char}
        begin
          EC := C xor $40;
          Result := True;
        end;
      else begin
        C1 := C and $7F;
        C2 := LastChar and $7F;
        Result := ((C1 = cCR) and (C2 = Ord('@')));
        if Result then EC := C xor $40;
      end;
    end;
  end;
end;

procedure TZmodem.EscapeBlock(var Block : TDataBlock; BLen : DWORD);
  {-Escape data from Block into zWorkBlock}
var
  I : Integer;
  C, EC : Byte;
begin
    {Initialize aBlockCheck}
    if CanCrc32 then begin
      UseCrc32 := True;
      BlockCheck := CRC32_INIT;
    end else begin
      UseCrc32 := False;
      BlockCheck := CRC16USD_INIT;
    end;

    {Escape the data into zWorkBlock}
    WorkSize := 1;
    for I := 1 to BLen do begin
      {Escape the entire block}
      C := Block[I];
      UpdateBlockCheck(C);
      if EscapeChar(C, EC) then begin
        {This character needs escaping, stuff a ZDle and escape it}
        WorkBlock^[WorkSize] := zDle;
        Inc(WorkSize);
        C := EC;
      end;

      {Stuff the character}
      WorkBlock^[WorkSize] := C;
      Inc(WorkSize);
      LastChar := C;
    end;
    Dec(WorkSize);
end;

procedure TZmodem.TransmitBlock;
    {-Transmits one data subpacket from Block}
begin
    if WorkSize <> 0 then
      CP.Write(WorkBlock^, WorkSize);

    {Send the frame type}
    UpdateBlockCheck(Terminator);
    CP.PutChar(ZDle);
    CP.PutChar(Terminator);

    {Send the block check characters}
    SendBlockCheck;

    {Follow CrcW subpackets with an Xon}
    if (not (zmDirect in Options)) and (Terminator = ZCrcW) then
      CP.PutChar(cXon);

    {Update status vars}
    Inc(T.D.FPos, DataBlockLen);
end;

procedure TZModem.ExtractReceiverInfo;
  {-Extract receiver info from last ZrInit header}
const
  Checks : array[Boolean] of TBlockCheckType = (bcCrc16, bcCrc32);
begin
    {Extract info from received ZrInit}
    RcvBuffLen := RcvHeader[ZP0] + ((RcvHeader[ZP1]) shl 8);
    CanCrc32   := (RcvHeader[ZF0] and CanFC32) = CanFC32;
    CheckType  := Checks[CanCrc32];
    EscapeAll  := (RcvHeader[ZF0] and EscAll) = EscAll;             
end;

procedure TZmodem.InsertFileInfo;
  {-Build a ZFile data subpacket}
var
  I    : Integer;
  C    : Byte;
  S    : String;
  Len  : Integer;
begin
    {Make a file header record}
    Clear(DataBlock^, 1024);

    { change '\' to '/'}
    Len := Length(T.D.FName);
    for I := 1 to Len do begin
      C := Byte(T.D.FName[I]);
      if C = Ord('\') then C := Ord('/');
      DataBlock^[I] := C;
    end;

    {Fill in file size}
    Str(T.D.FSize, S);
    Move(S[1], DataBlock^[Len+2], Length(S));
    Inc(Len, Length(S)+1);

    {Convert time stamp to Ymodem format and stuff in aDataBlock}
    if T.D.FTime <> 0 then begin
      S := ' ' + OctalStr(T.D.FTime);
      Move(S[1], DataBlock^[Len+1], Length(S));
      Inc(Len, Length(S)+1);
    end;

    {Save the length of the file info string for the ZFile header}
    DataBlockLen := Len;

    {Take care of status information}
end;

procedure TZmodem.PrepareTransmit;
var
  A: DWORD;
begin
    TxFinishReason := frOK;

    FGetNextFile := AGetNextFile;
    FFinishSend := AFinishSend;

    {Reset status vars}
    T.Clear;
    BlockErrors := 0;
    TotalErrors := 0;
    ProtocolStatus := psOK;
    ProtocolError := ecOK;

    T.D.Start := 0;

    CalcBlockSize(A, T.D.BlkLen, MaxProtocolBlock, MinBlockSize);
    CalcTimeout(ZModemTimeout, 120, 5);

    {State machine inits}
    HandshakeDone := False;
    HeaderState := hsNone;
    ZmodemState := tzInitial;
end;


procedure TZmodem.GotZrPos(Err: Boolean);
  {-Got an unsolicited ZRPOS, must be due to bad block}
var
  I: Integer;
  D: DWORD;
begin
  if (Err) or (BlockErrors > 0) then BlockError(ZModemState, tzError, DefHandshakeRetry);

  if T.Stream = nil then IncBlockErrors else
  begin
    I := Integer(RcvHeader);
    if I < 0 then D := T.D.FSize else D := I;    // T-Mail/Brake skip
    if D > T.D.FPos then T.D.FOfs := D;
    T.D.FPos := D;
    if (FGotZrPos or (D > 0)) and (T.D.FOfs < T.D.FSize) then FLogFile(Self, lfSendSeek);
    FGotZrPos := True;
    if T.D.BlkLen > 256 then T.D.BlkLen := T.D.BlkLen shr 1;
    GoodAfterBad := 0;
    if not SendSync then
    begin
      ProtocolError := ecTooManyErrors;
      ZmodemState := tzError;
    end;
  end;
  if ZmodemState <> tzError then ZModemState := tzStartData;

//  TDevicePort(CP).Purge([TX]);

end;

procedure TZmodem.GotZNak;
begin
  FLogFile(Self, lfNAK);
  IncTotalErrors;
  IncBlockErrors;
end;

procedure TZmodem.DoZSkip;
begin
  ProtocolStatus := psSkipFile;

  FinishSend(aaRefuse);

  {Go look for another file}
  ZmodemState := tzGetFile;
end;


procedure TZmodem.DoZFerr;
begin
  ProtocolStatus := psSkipFile;

  FinishSend(aaAcceptLater);

  {Go look for another file}
  ZmodemState := tzGetFile;

end;

procedure TZmodem.ProcessHeader;
  {-Process a header}
begin
    case ProtocolStatus of
      psGotHeader :
        case RcvFrame of
          ZNak: GotZNak;
          ZFErr: DoZFErr;
          ZSkip: DoZSkip;
          ZCan, ZAbort : {Receiver says quit}
            begin
              ProtocolStatus := psAbortByRemote;
              ZmodemState := tzError;
            end;
          ZAck :
            ZmodemState := tzStartData;
          ZrPos :        {Receiver is sending its desired file position}
            GotZrPos(True);
          else begin
            {Garbage, send Nak}
            PutBinaryHeader(ZNak);
          end;
        end;
      psBlockCheckError,
      psTimeout :
        begin
          BlockError(tzStartData, tzError, MaxBadBlocks);
          FLogFile(Self, lfTimeout);
        end;
    end;
end;

function TZmodem.Transmit: Boolean;

procedure SendZRQI;
begin
  {Send ZrQinit header (requests receiver's ZrInit)}
  Integer(TransHeader) := 0;
  PutHexHeader(ZrQInit);
  BlockErrors := 0;
  SetHandshakeTimer;
  HeaderState := hsNone;
end;

  {-Performs one increment of a Zmodem transmit}
const
  RZcommand : array[0..3] of Char = 'rz'+Char(cCr);
  FreeMargin = 30;
var
  Finished    : Boolean;
  NewData     : Boolean;
begin
    NewData := CP.CharReady;

    CheckCancel(tzError);

    repeat

      {Preprocess header requirements}
      case ZmodemState of
        tzHandshake,
        tzCheckFile,
        tzCheckEOF,
        tzDrainEof,
        tzCheckFinish,
        tzSendData,
        tzWaitAck :
          if NewData then
          begin
            {Header might be present, try to get one}
            CheckForHeader;
            if ProtocolStatus = psAbortByRemote then
              ZmodemState := tzError;
          end else if Timeout then
            {Timeout, let state machine handle it}
            ProtocolStatus := psTimeout
          else
            {Indicate no header yet}
            ProtocolStatus := psNoHeader;
      end;

      {Process the current state}
      case ZmodemState of
        tzInitial :
          begin
            CanCount := 0;

            {Send RZ command (via the attention string)}
            FillChar(AttentionStr, SizeOf(AttentionStr), 0);
            Move(RZcommand, AttentionStr, SizeOf(RZcommand));
            PutAttentionString;
            FillChar(AttentionStr, SizeOf(AttentionStr), 0);
            if StrandardHandshake then ZmodemState := tzSendZRQI else ZmodemState := tzGetFile;
          end;

        tzSendZRQI:
          begin
            SendZRQI;
            ZmodemState := tzHandshake;
          end;

        tzHandshake :
          case ProtocolStatus of
            psGotHeader :
              case RcvFrame of
                ZrInit :     {Got ZrInit, extract info}
                  begin
                    ExtractReceiverInfo;
                    if StrandardHandshake then ZmodemState := tzGetFile else ZmodemState := tzStartFile;
                  end;
                ZChallenge : {Receiver is challenging, respond with same number}
                  begin
                    TransHeader := RcvHeader;
                    PutHexHeader(ZAck);
                  end;
                ZCommand :   {Commands not supported}
                  PutHexHeader(ZNak);
                ZrQInit :    {Remote is trying to transmit also, do nothing}
                  ;
                else
                begin
                  PutHexHeader(ZNak); {Unexpected reply, nak it}
//                  PutHexHeader(ZrQInit); {!}
                end;
              end;
            psNoHeader :
              {Keep waiting for header} ;
            psBlockCheckError,
            psTimeout  : {Send another ZrQinit}
              begin
                if not BlockError(tzHandshake,
                                    tzError, DefHandshakeRetry) then begin
                  PutHexHeader(ZrQInit);
                  SetHandshakeTimer;
                end;
                FLogFile(Self, lfTimeout);
              end;
            end;

        tzGetFile :
          begin
            {Get the next file to send}
            T.ClearFileInfo;
            FGetNextFile(Self);
            if T.D.FName = '' then ZmodemState := tzSendFinish else
            begin
              if StrandardHandshake then
              begin
                ZmodemState := tzStartFile;
              end else
              begin
                if HandshakeDone then ZmodemState := tzStartFile else ZmodemState := tzSendZRQI;
              end;
            end;
            HandshakeDone := True;
          end;

          tzStartFile:
            begin
              {Build the header data area}
              Integer(TransHeader) := 0;
              TransHeader[ZF1] := FileMgmtOpts;
              if ReceiverRecover then
                TransHeader[ZF0] := FileRecover;

              {Insert file information into header}
              InsertFileInfo;
              ZmodemState := tzSendFile;
            end;

        tzSendFile:
          begin
            {Send the ZFile header and data subpacket with file info}
            PutBinaryHeader(ZFile);
            Terminator := ZCrcW;
            EscapeBlock(DataBlock^, DataBlockLen);
            TransmitBlock;

            {Go wait for response}
            BlockErrors := 0;
            SetHandshakeTimer;
            ZmodemState := tzCheckFile;
            HeaderState := hsNone;
          end;

        tzCheckFile :
          case ProtocolStatus of
            psGotHeader :
              case RcvFrame of
                ZrInit : {Got an extra ZrInit, ignore it}
                  ;
                ZNak: GotZNak;
                ZSkip : DoZSkip;
                ZFErr : DoZFerr;
                ZrPos : GotZrPos(False);
              end;
            psNoHeader : {Keep waiting for header}
              ;
            psBlockCheckError,
            psTimeout :  {Timeout waiting for response to ZFile}
              begin
                if not BlockError(tzCheckFile, tzError, DefHandshakeRetry) then begin
                  {Resend ZFile}
                  if (CP.OutUsed <= T.D.BlkLen) then
                  begin
                    PutBinaryHeader(ZFile);
                    TransmitBlock;
                  end;
                 SetHandshakeTimer;
               end;
               FLogFile(Self, lfTimeout);
             end;
          end;

        tzStartData :
          begin
            {Drain trailing chars from inbuffer...}
            {...and kill whatever might still be in the output buffer}
//            TDevicePort(CP).Purge([TX, RX]);

            {Get ready}
            DataInTransit := 0;

            LastBlock := T.D.FPos >= T.D.FSize;
            if LastBlock then
            begin
              TxFinishReason := frRefuse;
//              FinishSend(aaRefuse);
              ZmodemState := tzSendEOF;
            end else
            begin
              {Send ZData header}

              BlockErrors := 0;

              Integer(TransHeader) := T.D.FPos;
              PutBinaryHeader(ZData);

              ZmodemState := tzEscapeData;
            end;
          end;

        tzEscapeData :
          begin
            {Get a block to send}
            Inc(GoodAfterBad);
            if GoodAfterBad > 8 then
            begin
              GoodAfterBad := 0;
              T.D.BlkLen := MinD(MaxProtocolBlock, T.D.BlkLen * 2);
            end;
            DataBlockLen := T.D.BlkLen;
            SetLastError(0);
            DataBlockLen := T.Stream.Read(DataBlock^, DataBlockLen);
            if (GetLastError <> 0) or (DataBlockLen <= 0) then
            begin
              FinishSend(aaSysError);
              Cancel;
              ZmodemState := tzError;
            end else
            begin
              LastBlock := T.D.FPos + DataBlockLen >= T.D.FSize;

              {Show the new data on the way}
              if RcvBuffLen <> 0 then
                Inc(DataInTransit, DataBlockLen);

              {Set the terminator}
              if LastBlock then
                {Tell receiver its the last subpacket}
                Terminator := ZCrcE
              else if (RcvBuffLen <> 0) and
                      (DataInTransit >= RcvBuffLen) then begin
                {Receiver's buffer is nearly full, wait for acknowledge}
                Terminator := ZCrcW;
              end else
                {Normal data subpacket, no special action}
                Terminator := ZCrcG;

              {Escape this data into zWorkBlock}
              EscapeBlock(DataBlock^, DataBlockLen);

              ZmodemState := tzSendData;

              SetTransTimer;
            end;
          end;

        tzSendData :
          if (ProtocolStatus = psGotHeader) then ProcessHeader else
          if (CP.OutUsed <= T.D.BlkLen) then
          begin
            TransmitBlock;
            if LastBlock then
            begin
              ZmodemState := tzSendEof;
            end else
            if Terminator = ZCrcW then
            begin
              SetTransTimer;
              ZmodemState := tzWaitAck;
            end else
              ZmodemState := tzEscapeData;
          end;

        tzWaitAck :
            ProcessHeader;

        tzSendEof :
          begin
            {Send the eof}
            Integer(TransHeader) := T.D.FPos;
            PutBinaryHeader(ZEof);
            ZmodemState := tzDrainEof;
            SetTransTimer;
          end;

        tzDrainEof :
          if NewData then begin
            case ProtocolStatus of
              psGotHeader :
                case RcvFrame of
                  ZCan, ZAbort : {Receiver says quit}
                    begin
                      ProtocolStatus := psAbortByRemote;
                      ZmodemState := tzError;
                    end;
                  ZrPos :        {Receiver is sending its file position}
                    GotZrPos(True);
                  ZAck :         {Response to last CrcW data subpacket}
                    ;
                  ZNak: GotZNak;
                  ZSkip: DoZSkip;
                  ZFErr: DoZFErr;
                  ZrInit : {Finished with this file}
                    begin
                      FinishSend(aaOK);
                      ZmodemState := tzGetFile;
                    end;
                  else begin
                    {Garbage, send Nak}
                    PutBinaryHeader(ZNak);
                  end;
                end;

              psBlockCheckError,
              psTimeout :
                begin
                  BlockError(tzStartData, tzError, MaxBadBlocks);
                  FLogFile(Self, lfTimeout);
                end;
            end
          end else if (CP.OutUsed = 0) then begin
            ZmodemState := tzCheckEof;
            HeaderState := hsNone;
            SetFinishTimer;
          end else if Timeout then begin
            ProtocolError := ecTimeout;
            ZmodemState := tzError;
          end {else Sleep(100)};


        tzCheckEof :
          case ProtocolStatus of
            psGotHeader :
              begin
                case RcvFrame of
                  ZCan, ZAbort : {Receiver says quit}
                    begin
                      ProtocolStatus := psAbortByRemote;
                      ZmodemState := tzError;
                    end;
                  ZrPos :        {Receiver is sending its desired file position}
                    GotZrPos(True);
                  ZAck :         {Response to last CrcW data subpacket}
                    ;
                  ZNak: GotZNak;
                  ZFErr: DoZFErr;
                  ZSkip: DoZSkip;
                  ZrInit : {Finished with this file}
                    begin
                      FinishSend(aaOK);
                      ZmodemState := tzGetFile;
                    end;
                  else begin
                    {Garbage, send Nak}
                    PutBinaryHeader(ZNak);
                  end;
                end;
              end;
            psNoHeader :
              {Keep waiting for header} ;
            psBlockCheckError,
            psTimeout :
              begin
                BlockError(tzSendEof, tzError, MaxBadBlocks);
                FLogFile(Self, lfTimeout);
              end;
          end;

        tzSendFinish :
          begin
            Integer(TransHeader) := T.D.FPos;
            PutHexHeader(ZFin);
            SetFinishTimer;
            BlockErrors := 0;
            ZmodemState := tzCheckFinish;
            HeaderState := hsNone;
          end;

        tzCheckFinish :
          case ProtocolStatus of
            psGotHeader :
              case RcvFrame of
                ZFin:
                  begin
                    FLogFile(Self, lfBatchSendEnd);
                    CP.PutChar(Ord('O'));
                    CP.PutChar(Ord('O'));
                    ZmodemState := tzCleanup;
                  end;
                ZRInit:
                  begin
                    ZmodemState := tzSendFinish;
                  end;
              end;
            psNoHeader :
              {Keep waiting for header} ;
            psBlockCheckError,
            psTimeout :
              begin
                ProtocolError := ecOK;
                ZmodemState := tzCleanup;
              end;
          end;

        tzError :
          begin
            {Cleanup on aborted or canceled protocol}
            FinishSend(aaAbort);
            ZmodemState := tzCleanup;
//            if ProtocolStatus <> psAbortByLocal then TDevicePort(CP).Purge([TX]);
          end;

        tzCleanup :
          begin
            {Flush last few chars from last received header}
//            TDevicePort(CP).Purge([RX]);

            {apShowLastStatus(P);}
            ZmodemState := tzDone;
            SignalFinish;
          end;
      end;

      {Stay in state machine or exit?}
      case ZmodemState of
        {Leave state machine}
        tzHandshake,
        tzSendData,
        tzWaitAck,
        tzDrainEof,
        tzDone            : Finished := True;

        {Stay in state machine only if data available}
        tzCheckFinish,
        tzCheckEof,
        tzCheckFile       : Finished := not CP.CharReady;

        {Stay in state machine}
        tzInitial,
        tzSendZRQI,
        tzGetFile,
        tzSendFile,
        tzEscapeData,
        tzStartData,
        tzSendEof,
        tzSendFinish,
        tzError,
        tzCleanup         : Finished := False;
        else                Finished := True;
      end;

      {Clear header state if we just processed a header}
      if (ProtocolStatus = psGotHeader) or
         (ProtocolStatus = psNoHeader) then
         ProtocolStatus := psOK;
      if HeaderState = hsGotHeader then
        HeaderState := hsNone;

      {If staying in state machine for a check for data}
      CP.Flsh;
      NewData := True;

    until Finished;

  OutFlow := ZmodemState = tzSendData;
  Result := ZModemState = tzDone;
end;


procedure TZmodem.CheckCancel(AState: TZmodemState);
begin
  if ProtocolStatus <> psAbortByLocal then
  begin
    if CancelRequested then
    begin
      Cancel;
      ZmodemState := AState;
    end else
    {if not CP.CharReady then}
    if CP.DCD <> CP.Carrier then
    begin
      CP.Carrier := not CP.Carrier;
      ZmodemState := AState;
      ProtocolStatus := psAbortNoCarrier;
    end;
  end;
end;

function TZModem.SendSync;
begin
  Result := T.Stream.Seek(T.D.FPos, FILE_BEGIN) <> INVALID_FILE_SIZE;
  if not Result then FinishSend(aaSysError);
end;

function TZModem.GetStateStr: string;
begin
  Result := ZmodemStateNames[ZmodemState];
end;

procedure TZModem.FinishRece(Action: TTransferFileAction);
begin
  if Action = aaOK then
  case RxFinishReason of
    frDelay  : Action := aaAcceptLater;
    frRefuse : Action := aaRefuse;
  end;
  FFinishRece(Self, Action);
  RxFinishReason := frOK;
end;

procedure TZModem.FinishSend(Action: TTransferFileAction);
begin
  if Action = aaOK then
  case TxFinishReason of
    frDelay  : Action := aaAcceptLater;
    frRefuse : Action := aaRefuse;
  end;
  FFinishSend(Self, Action);
  TxFinishReason := frOK;
end;

function CreateZModemProtocol(CP: Pointer; Opt: TZmodemOptionSet): Pointer;
begin
  Result := TZModem.Create(CP, Opt);
end;

end.


