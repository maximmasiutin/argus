unit p_BinkP;

interface

function CreateBinkPProtocol(CP: Pointer): Pointer;

implementation uses xMisc, xBase, xDES, Windows, SysUtils;

type
  TBinkPState = (
    bdNone,
    bdInit,
    bdStartWaitFirstMsg,
    bdWaitFirstMsg,
    bdStartWaitPwd,
    bdWaitPwd,
    bdGetInKey,
    bdStartWaitOK,
    bdWaitOK,
    bdWaitDoneOK,
    bdSendPwd,
    bdSendOKPwd,
    bdSendBadPwd,
    bdAllAkasBusy,

    bdStartTransfer,
    bdTransfer,
    bdUnrec,
    bdGotErr,
    bdFinishFail,
    bdStartDrain,
    bdDrain,
    bdFinishOK,
    bd_Done,
    bdDone
  );

  TBinkPPktRx = (
    bdprxNone,
    bdprxHdrHi,
    bdprxHdrLo,
    bdprxData
  );

  TBinkPtx = (
    bdtxInit,
    bdtxGetNextFile,
    bdtxStartFile,
    bdtxGotM_GET,
    bdtxReadNextBlock,
    bdtxReadBlock,
    bdtxTransmit,
    bdtxWait_M_GOT,
    bdtxSendEOB,
    bdtxCheckSendEOB,
    bdtxDone
  );

  TBinkPrx = (
    bdrxInit,
    bdrxStartWaitFile,
    bdrxWaitFile,
    bdrxStartFile,
    bdrxStartReceData,
    bdrxStartWaitFileSync,
    bdrxWaitFileSync,
    bdrxGotFileSync,
    bdrx_ReceData,
    bdrxReceData,
    bdrxGot_M_EOB,
    bdrx_Done,
    bdrxDone
  );

const
  MaxSndBlkSz   = $1000;
  StartSndBlkSz = $100;
  DuplexBlkSz   = $400;
  SubBlkSz      = $400;

type
  TBinkPArray = array[0..bdK32-1] of Byte;
  TBinkPOutA  = array[0..MaxSndBlkSz-1] of Byte;

  TGetCharFunc = function(var C: Byte): Boolean of object;
  TWriteProc = procedure(const Buf; i: DWORD) of object;
  TPutCharProc = procedure(C: Byte) of object;
  TCharReadyFunc = function: Boolean of object;

  TBinkP = class(TBiDirProtocol)
    function GetStateStr: string;                               override;
    constructor Create(ACP: TPort);
    procedure ReportTraf(txMail, txFiles: DWORD);               override;
    destructor Destroy;                                         override;
    function TimeoutValue: DWORD;                               override;
    procedure Cancel;                                           override;
    function NextStep: boolean;                                 override;
    procedure Start({RX}AAcceptFile: TAcceptFile;
                        AFinishRece: TFinishRece;
                    {TX}AGetNextFile: TGetNextFile;
                        AFinishSend: TFinishSend
                     ); override;
  private
    CRAM: Boolean;
    ChallengePtr: PByteArray;
    ChallengeSize: Integer;
    SendDummies, AddrGot, PwdGot, OptGot, SupEncDesCBC: Boolean;
    DesOutPos, DesOuts, DesInCollectPos, DesInGivePos: DWORD;
    DesInBuf, DesOutBuf: TDesBlock;
    ivIn, ivOut, DesKey: TDesBlock;
    DesKeySchedule: TdesKeySchedule;
    GetCharFunc: TGetCharFunc;
    WriteProc: TWriteProc;
    CharReadyFunc: TCharReadyFunc;
    PutCharProc: TPutCharProc;
    Timeout: EventTimer;
    OutMsgsColl,
    M_SKIP_Coll,
    M_GOT_Coll,
    M_GET_Coll: TStringColl;
    ReceSyncStr, ReceFileStr: string;
    InMsg: string;
    aOut: TBinkPOutA;
    aIn: TBinkPArray;
    InHdrHi,
    InHdrLo: Byte;
    InCur, InRep: DWORD;
    OnceAgain,
//    WaitDrain,
    InData: Boolean;
    OldState, OldOldState, OldOldOldState,
    State: TBinkPState;
    tx: TBinkPtx;
    rx: TBinkPrx;
    PktRx: TBinkPPktRx;
    CurPkt: DWORD;
    TxBlkSize, TxBlkPos: DWORD;
    OutMsgsLocked: Boolean;
    UniqStr: string;
    function MakePwdStr(const AStr: string): string;
    procedure FreeChallenge;
    function RxPktKnown: Boolean;
    procedure LogPortErrors;
    procedure SetDesOut;
    procedure SetDesIn;
    function GetRxPktName: string;
    procedure SendMsg(Id: Byte; const Msg: string);
    procedure SendId(Id: Byte);
    procedure SendDataHdr(Sz: DWORD);
    procedure DoTx;
    procedure DoRx;
    procedure DoStep;
    function RxPkt: DWORD;
    procedure FlushPkt;
    procedure FlushOutMsgs;
    procedure LogNul;
    procedure CheckOpt;
    procedure ChkPwd;
    procedure GetAdr;
    procedure SetTimeout;
    function GetCharPlain(var C: Byte): Boolean;
    function GetCharDES(var C: Byte): Boolean;
    procedure WritePlain(const Buf; i: DWORD);
    procedure WriteDES(const Buf; i: DWORD);
    procedure PutCharDES(c: Byte);
    procedure PutCharPlain(c: Byte);
    function CharReadyDES: Boolean;
    function CharReadyPlain: Boolean;
    procedure GetOctetDES;
    procedure SendDummy;
    function KeySum: Word;
    function GetUniqStr: string;
    procedure SetChallengeStr(const AStr: string);
  end;

const
  M_Names : array[0..10] of string = (
    'M_NUL', 'M_ADR', 'M_PWD', 'M_FILE', 'M_OK', 'M_EOB',
    'M_GOT', 'M_ERR', 'M_BSY', 'M_GET', 'M_SKIP'
  );

  BinkPStateMsg : array[TBinkPState] of string = (
     'None',
     'Init',
     'StartWaitFirstMsg',
     'WaitFirstMsg',
     'StartWaitPwd',
     'WaitPwd',
     'GetInKey',
     'StartWaitOK',
     'WaitOK',
     'WaitDoneOK',
     'SendPwd',
     'SendOKPwd',
     'SendBadPwd',
     'AllAKAsBusy',

     'StartTransfer',
     'Transfer',
     'Unrec',
     'GotErr',
     'FinishFail',
     'StartDrain',
     'Drain',
     'FinishOK',
     'PreDone',
     'Done'
  );

  BinkPPktRxMsg : array[TBinkPPktRx] of string = (
    'None',
    'HdrHi',
    'HdrLo',
    'Data'
  );

  BinkPtxMsg : array[TBinkPtx] of string = (
    'Init',
    'GetNextFile',
    'StartFile',
    'GotM_GET',
    'ReadNextBlock',
    'ReadBlock',
    'Transmit',
    'Wait_M_GOT',
    'SendEOB',
    'CheckSendEOB',
    'Done'
  );

  BinkPrxMsg : array[TBinkPrx] of string = (
    'Init',
    'StartWaitFile',
    'WaitFile',
    'StartFile',
    'StartReceData',
    'StartWaitFileSync',
    'WaitFileSync',
    'GotFileSync',
    '_ReceData',
    'ReceData',
    'Got_M_EOB',
    '_Done',
    'Done'
  );


  pktData    = $FFFFFFFF;
  pktNone    = $FFFFFFFE;

  pktDCD     = $FFFFFFFD;
  pktAbort   = $FFFFFFFC;
  pktTimeout = $FFFFFFFB;

  MinErr     = pktTimeout;
  MaxErr     = pktDCD;

function FileStr(B: TBatch; NeedOfs: Boolean): string;
begin
  with B.D do
  if NeedOfs then Result := Format('%s %d %d %d', [StrQuote(FName), FSize, FTime, FOfs]) else
    Result := Format('%s %d %d', [StrQuote(FName), FSize, FTime]);
end;

procedure TBinkP.SetTimeout;
begin
  NewTimerSecs(Timeout, BinkPTimeout);
end;

destructor TBinkP.Destroy;
begin
  FreeObject(M_SKIP_Coll);
  FreeObject(M_GOT_Coll);
  FreeObject(M_GET_Coll);
  FreeObject(OutMsgsColl);
  FreeChallenge;
  inherited Destroy;
end;


procedure TBinkP.SendDummy;
var
  s: string;
  i: DWORD;
begin
  if not SendDummies then Exit;
  i := xRandom(4)+5;
  s := '| ';
  while i > 0 do begin s := s + Char(xRandom(126-32)+33); Dec(i) end;
  SendMsg(M_NUL, s);
end;

procedure TBinkP.LogPortErrors;
var
  Coll: TStringColl;
  i, j: Integer;
begin
  Coll := CP.GetErrorStrColl;
  j := CollMax(Coll);
  if j < 0 then Exit;
  for i := 0 to j do
  begin
    CustomInfo := Coll[i];
    FLogFile(Self, lfBinkPNiaE);
  end;
  Coll.FreeAll;
end;

function TBinkP.RxPkt: DWORD;
var
  C: Byte;

procedure Acc;
var
  I: Integer;
  CC: Byte;
begin
  InMsg := '';
  if InRep > 1 then
  begin
    for i := 1 to InRep-1 do
    begin
      CC := aIn[I];
      if CC = 0 then Exit;
      InMsg := InMsg+Char(CC);
    end;
  end;
end;


procedure GotSomth;
begin
  InCur := 0;
  PktRx := bdprxHdrHi;
  if InData then Result := pktData else
  begin
    Acc;
    Result := DWORD(aIn[0]);
  end;
end;

begin
  Result := CurPkt;
  if Result <> pktNone then Exit;
  if not CharReadyFunc then
  begin
    if CancelRequested then Result := pktAbort else
    if TimerExpired(Timeout) then Result := pktTimeout else
    if CP.DCD <> CP.Carrier then
    begin
      CP.Carrier := not CP.Carrier;
      Result := pktDCD;
    end;
  end else
  begin
    OnceAgain := True;
    SetTimeout;
    while GetCharFunc(C) do
    begin
      case PktRx of
        bdprxHdrHi:
          begin
            InHdrHi := C;
            PktRx := bdprxHdrLo;
          end;
        bdprxHdrLo:
          begin
            InCur := 0;
            InHdrLo := C;
            InRep := ((Word(InHdrHi) shl 8) + Word(InHdrLo)) and (bdK32-1);
            R.D.BlkLen := InRep;
            InData := InHdrHi<$80;
            if InRep >= bdK32 then
            begin
              State := bdUnrec;
              Break;
            end;
            PktRx := bdprxData;
            if InCur = InRep then
            begin
              GotSomth;
              Break;
            end;
          end;
        bdprxData:
          begin
            if (InCur = bdK32) or (InCur = InRep) then
            begin
              GlobalFail('bdprxData InCur=%d InRep=%d', [InCur, InRep]); // Debug-only
            end;
            aIn[InCur] := C;
            Inc(InCur);
            if InCur = InRep then
            begin
              GotSomth;
              Break;
            end;
          end;
      end;
    end;
  end;
  CurPkt := Result;
  LogPortErrors;
end;

procedure TBinkP.FlushPkt;
begin
  CurPkt := pktNone;
end;

procedure TBinkP.FlushOutMsgs;
var
  i,j: Integer;
  s: string;
begin
  if OutMsgsLocked then Exit;
  for i := 0 to OutMsgsColl.Count-1 do
  begin
    s := OutMsgsColl[i];
//    CustomInfo := s;
//    FLogFile(Self, lfBinkPNiaE);
    for j := 1 to Length(s) do PutCharProc(Byte(s[j]));
  end;
  OutMsgsColl.FreeAll;
end;


constructor TBinkP.Create(ACP: TPort);
begin
  inherited Create(ACP);
  M_GOT_Coll := TStringColl.Create;
  M_GET_Coll := TStringColl.Create;
  M_SKIP_Coll := TStringColl.Create;
  OutMsgsColl := TStringColl.Create;
  GetCharFunc := GetCharPlain;
  WriteProc := WritePlain;
  PutCharProc := PutCharPlain;
  CharReadyFunc := CharReadyPlain;
end;

function TBinkP.TimeoutValue: DWORD;
begin
  Result := MultiTimeout([Timeout]);
  if DesKey <> 0 then Result := MinD(Result, 1000); // sleep no more than a second if ecrypted
end;

procedure TBinkP.Cancel;
begin
  FreeObject(CP);
end;

procedure TBinkP.SetChallengeStr(const AStr: string);
var
  sl: Integer;
  d: DWORD;
begin
  sl := Length(AStr);
  if (sl = 0) or Odd(sl) then
  begin
    State := bdFinishFail;
    SendMsg(M_ERR, Format('Invalid length of challenge string (%d chars)', [sl]));
    Exit;
  end;
  ChallengeSize := sl div 2;
  GetMem(ChallengePtr, ChallengeSize);
  for sl := 0 to ChallengeSize-1 do
  begin
    d := VlH(Copy(AStr, sl*2+1, 2));
    if (d = INVALID_VALUE) or (d > $FF) then
    begin
      State := bdFinishFail;
      SendMsg(M_ERR, Format('Invalid challenge string (%s)', [AStr]));
      Exit;
    end;
    ChallengePtr^[sl] := Byte(d);
  end;
end;

procedure TBinkP.CheckOpt;
var
  s, z, k: string;
begin
  s := InMsg;
  GetWrd(s, z, ' ');
  if UpperCase(z) <> 'OPT' then Exit;
  OptGot := True;
  while s <> '' do
  begin
    GetWrd(s, z, ' ');
    GetWrd(z, k, '-');
    k := UpperCase(k);
    if k = 'CRAM' then
    begin
      GetWrd(z, k, '-');
      if Pos('MD5', k) > 0 then
      begin
        GetWrd(z, k, '-');
        if not CramDisabled then SetChallengeStr(k);
      end;
    end else
    begin
      if k = 'ENC' then
      begin
        GetWrd(z, k, '-');
        if k = 'DES' then
        begin
          GetWrd(z, k, '-');
          if k = 'CBC' then SupEncDesCBC := True;
        end;
      end;
    end;
  end;
end;


procedure TBinkP.LogNul;
begin
  CheckOpt;
  CustomInfo := InMsg;
  FLogFile(Self, lfBinkPNul);
  FlushPkt;
end;

procedure TBinkP.GetAdr;
begin
  CustomInfo := InMsg;
  FLogFile(Self, lfBinkPAddr);
  if CustomInfo <> '' then
  begin
    State := bdFinishFail;
    if Length(CustomInfo) = 1 then
    case CustomInfo[1] of
       #1: SendMsg(M_ERR, 'Invalid addrs: '+InMsg);
       #3: State := bdSendBadPwd;
       #4: State := bdAllAkasBusy;
    end;
  end;
  FlushPkt;
end;

procedure TBinkP.ChkPwd;
begin
  CustomInfo := UniqStr+' '+InMsg;
  Finalize(UniqStr);
  FLogFile(Self, lfBinkPPwd);
  FlushPkt;
  if CustomInfo = cBadPwd then State := bdSendBadPwd else
  if CustomInfo = #4 then State := bdAllAkasBusy; 
end;

procedure TBinkP.ReportTraf(txMail, txFiles: DWORD);
begin
  SendMsg(M_NUL, Format('TRF %d %d', [txMail, txFiles]));
  SendDummy;
end;

function TBinkP.GetRxPktName: string;
begin
  case CurPkt of
    0..10: Result := M_Names[CurPkt];
    else Result := Hex8(CurPkt)
  end;
end;

function TBinkP.KeySum: Word;
var
  k: TDesBlockI;
begin
  k[0] := $61C74D21;
  k[1] := $D06AB18C;
  xdes_ecb_encrypt_block(@k, SizeOf(k), DesKey, True);
  Result := xdes_md5_crc16(@k, 8);
end;

var
  UniqCounter: Integer;

function TBinkP.GetUniqStr: string;
var
  r: packed record
    FT: TFileTime;
    TC: DWORD;
    MC: Integer;
    UC: Integer;
    PN: Integer;
    PI: Integer;
    RI: DWORD;
    C1: Integer;
  end;
  D: TMD5Byte16;
  C: TMD5Ctx;
  ci: string;
  cil: Integer;
begin
  GetSystemTimeAsFileTime(r.FT);
  r.MC := AllocMemCount;
  r.TC := GetTickCount;
  r.UC := InterlockedIncrement(UniqCounter);
  r.PN := CP.PortNumber;
  r.PI := CP.PortIndex;
  r.RI := xRandom32;
  MD5Init(C);
  MD5Update(C, r, SizeOf(r));
  ci := CP.CallerId; cil := Length(ci);
  if cil > 0 then MD5Update(C, ci[1], cil);
  MD5Final(D, C);
  UniqStr := DigestToStr(D);
  Result := UniqStr;                                
end;

procedure TBinkP.DoStep;

procedure DoTransfer;
var
  ctx : TBinkPtx;
  crx : TBinkPrx;
begin
  repeat
    ctx := tx;
    DoTx;
//    if State <> bdTransfer then Exit;
  until (ctx = tx);
  repeat
    crx := rx;
    DoRx;
//    if State <> bdTransfer then Exit;
  until (crx = rx);
  if (tx = bdtxDone) and (rx = bdrxDone) then
  begin
    State := bdStartDrain;
    OutFlow := True;
  end;
end;

procedure SendAddr;
begin
  FLogFile(Self, lfBinkPgAddr);
  SendMsg(M_ADR, CustomInfo);
  SendDummy;
end;

procedure ParseOK_M_ERR;
var
  s, z: string;
begin
  State := bdGotErr;
  if DesKey = 0 then Exit;
  s := InMsg;
  GetWrd(s, z, ' ');
  if z <> 'ENC' then Exit;
  GetWrd(s, z, ' ');
  if z <> 'OK' then Exit;
  SetDesIn;
  State := bdStartWaitOK;
end;

procedure ParsePwd_M_ERR;
var
  s, z: string;
  i, j: DWORD;
begin                 
  State := bdGotErr;
  if not AddrGot then Exit;
  s := InMsg;
  GetWrd(s, z, ' ');
  if z <> 'ENC' then Exit;
  GetWrd(s, z, ' ');
  if z <> 'DES/CBC' then Exit;
  GetWrd(s, z, ' ');
  i := Vl(z);
  if i = INVALID_VALUE then Exit;
  if (i > $FFFF) then Exit;
  j := KeySum;
  if i <> j then
  begin
    CustomInfo := Format('%d %d', [i, j]);
    FLogFile(Self, lfBinkPBadKey);
    Exit;
  end;
  State := bdStartWaitPwd;
  SendMsg(M_ERR, 'ENC OK');
  CP.Flsh;
  SetDesIn;
  SetDesOut;
  xdes_set_key(DesKey, DesKeySchedule);
  SendDummy;
  SendAddr;
  SendDummy;
end;

function GetCramStr: string;
begin
  if CramDisabled then Result := '' else Result := ' CRAM-MD5-'+GetUniqStr;
end;

begin
  case State of
    bdInit:
      begin
        if not Originator then SendMsg(M_NUL, 'OPT ENC-DES-CBC'+GetCramStr);
        SendMsg(M_NUL, 'SYS ' +Station.Station);
        SendMsg(M_NUL, 'ZYZ ' +Station.Sysop);
        SendMsg(M_NUL, 'LOC ' +Station.Location);
        SendMsg(M_NUL, 'PHN ' +Station.Phone);
        SendMsg(M_NUL, 'NDL ' +Station.Flags);
        SendMsg(M_NUL, 'TIME '+RFCDateStr);
        SendMsg(M_NUL, 'VER ' +ProductName+'/'+ProductVersion+'/'+CustomInfo+' binkp/1.0');
        if Originator then
        begin
          SendAddr;
          State := bdStartWaitFirstMsg;
        end else State := bdStartWaitPwd;
      end;
    bdStartWaitFirstMsg:
      State := bdWaitFirstMsg;
    bdWaitFirstMsg:
      case RxPkt of
        pktNone : ;
        MinErr..MaxErr : ;
        Integer(M_ADR) : if AddrGot then State := bdUnrec else begin AddrGot := True; State := bdStartWaitFirstMsg; GetAdr end;
        Integer(M_ERR) : begin ParseOK_M_ERR; FlushPkt end;
        Integer(M_NUL) : begin State := bdStartWaitFirstMsg; LogNul; if State = bdStartWaitFirstMsg then State := bdSendPwd end;
        else if RxPktKnown then State := bdUnrec else begin FlushPkt; State := bdStartWaitFirstMsg end;
      end;
    bdStartWaitPwd:
      State := bdWaitPwd;
    bdWaitPwd:
      case RxPkt of
        pktNone : ;
        MinErr..MaxErr : ;
        Integer(M_ADR) : if AddrGot then State := bdUnrec else begin AddrGot := True; State := bdGetInKey; GetAdr end;
        Integer(M_PWD) : if PwdGot then State := bdUnrec else begin PwdGot := True; State := bdSendOkPwd; ChkPwd end;
        Integer(M_ERR) : begin ParsePwd_M_ERR; FlushPkt end;
        Integer(M_NUL) : begin LogNul; State := bdStartWaitPwd end;
        else if RxPktKnown then State := bdUnrec else begin FlushPkt; State := bdStartWaitPwd end;
      end;
    bdGetInKey:
      begin
        State := bdStartWaitPwd;
        FLogFile(Self, lfBinkPgInKey);
        Move(CustomInfo[1], DesKey, 8);
        if DesKey = 0 then SendAddr else
        begin
          if PwdGot then State := bdUnrec;
        end;
      end;
    bdSendPwd:
      begin
        FLogFile(Self, lfBinkPgOutKey);
        Move(CustomInfo[1], DesKey, 8);
        if DesKey <> 0 then
        begin
          SendMsg(M_ERR, Format('ENC DES/CBC %d (Encrypted session not supported)', [KeySum]));
          CP.Flsh;
          SetDesOut;
          xdes_set_key(DesKey, DesKeySchedule);
          SendDummy;
        end;
        FLogFile(Self, lfBinkPgPwd);
        if CustomInfo[1] <> ' ' then SendMsg(M_NUL, 'FREQ');
        DelFC(CustomInfo);
        SendMsg(M_PWD, MakePwdStr(CustomInfo));
        if CRAM then FLogFile(Self, lfBinkPCRAM);
        SendDummy;
        State := bdWaitOK;
      end;
    bdStartWaitOK :
      State := bdWaitOK;
    bdWaitOK :
      case RxPkt of
        pktNone : ;
        MinErr..MaxErr : ;
        Integer(M_ADR) : if AddrGot then State := bdUnrec else begin AddrGot := True; if Originator then begin State := bdStartWaitOK; GetAdr end else State := bdUnrec end;
        Integer(M_OK)  : State := bdWaitDoneOK;
        Integer(M_ERR) : begin ParseOK_M_ERR; FlushPkt  end;
        Integer(M_NUL) : begin LogNul; State := bdStartWaitOK end;
        else if RxPktKnown then State := bdUnrec else begin FlushPkt; State := bdStartWaitOK end;
      end;
    bdWaitDoneOK :
      begin
        FlushPkt;
        State := bdStartTransfer;
      end;
    bdSendOKPwd :
      begin
        SendId(M_OK);
        SendDummy;
        State := bdStartTransfer;
      end;
    bdAllAkasBusy:
      begin
        SendMsg(M_ERR, 'All AKAs are busy');
        State := bdFinishFail;
      end;
    bdSendBadPwd :
      begin
        SendMsg(M_ERR, 'Bad password');
        State := bdFinishFail;
      end;
    bdGotErr :
      begin
        CustomInfo := InMsg;
        FLogFile(Self, lfBinkPErr);
        State := bdFinishFail;
      end;
    bdUnrec :
      begin
        if InData then CustomInfo := 'Data Block' else
        begin
          CustomInfo := M_Names[CurPkt];
          if InMsg <> '' then CustomInfo := Format('%s "%s" st=%s tx=%s rx=%s blk=%s', [CustomInfo, InMsg, BinkPStateMsg[OldOldState], BinkPtxMsg[tx], BinkPrxMsg[rx], BinkPPktRxMsg[PktRx]]);
        end;
        SendMsg(M_ERR, 'Unrecognized packet '+CustomInfo);
        FLogFile(Self, lfBinkPUnrec);
        State := bdFinishFail;
      end;
    bdStartDrain: State := bdDrain;
    bdDrain:
      if (CP.OutUsed = 0) then State := bdFinishOK else
      case RxPkt of
        pktNone: {Sleep(100)};
        MinErr..MaxErr : ;
        else
        begin
          FlushPkt;
          State := bdStartDrain;
        end;
      end;
    bdFinishOK :
      begin
        State := bd_Done;
      end;

    bdFinishFail :
      begin
        if ProtocolError = ecOK then ProtocolError := ecTooManyErrors;
        State := bd_Done;
      end;

    bdStartTransfer :
      begin
        tx := bdtxInit;
        rx := bdrxInit;
        State := bdTransfer;
      end;
    bdTransfer:
      DoTransfer;
    bd_Done:
      begin
        Sleep(100);
        State := bdDone;
      end;
    bdDone: ;
   end;
end;


procedure TBinkP.DoTx;

function GotM_GET: Boolean;
var
  s1,s2,z1,z2: string;
  jd: DWORD;
begin
  if M_GET_Coll.Count = 0 then Result := False else
  begin
    Result := True;
    s1 := M_GET_COll[0];
    s2 := FileStr(T,False);
    z1 := ''; z2 := '';
    for jd := 0 to 3 do
    begin
      if UpperCase(z1) <> UpperCase(z2) then
      begin
        SendMsg(M_ERR, Format('File names mismatch: %s / %s', [z1, z2]));
        State := bdFinishFail;
        Exit;
      end;
      GetWrd(s1, z1, ' ');
      GetWrd(s2, z2, ' ');
    end;
    jd := Vl(z1);
    if (jd = INVALID_VALUE) or (jd >= DWORD(MaxInt)) then
    begin
      SendMsg(M_ERR, Format('Invalid file position value: %s', [z1]));
      State := bdFinishFail;
      Exit
    end;

    T.D.FPos := jd;
    T.D.FOfs := jd;
    FLogFile(Self, lfSendSync);

    if T.Stream.Seek(T.D.FPos, FILE_BEGIN) = INVALID_FILE_SIZE then
    begin
      FFinishSend(Self, aaSysError);
      State := bdFinishFail;
      Exit
    end;
    M_GET_COll.AtFree(0);
    tx := bdTxGotM_GET;
  end;
end;

function CanSend: Boolean;
begin
  Result := (CP.OutUsed < T.D.BlkLen * 4);
end;

procedure Got__(Coll: TStringColl; Action: TTransferFileAction);
begin
  if UpperCase(Coll[0]) <> UpperCase(FileStr(T,False)) then
  State := bdFinishFail else
  begin
    Coll.AtFree(0);
    FFinishSend(Self, Action);
    tx := bdtxGetNextFile;
  end;
end;

var
  i: DWORD;
begin
  case tx of
    bdtxDone : ;
    bdtxInit : tx := bdtxGetNextFile;
    bdtxGetNextFile :
      begin
        OutFlow := True;
        T.ClearFileInfo;
        FGetNextFile(Self);
        if T.D.FName = '' then tx := bdtxCheckSendEOB else tx := bdtxStartFile;
      end;
    bdtxStartFile:
      begin
        SendMsg(M_FILE, FileStr(T, True));
        SendDummy;
        CP.Flsh;
//        WaitDrain := True;
        T.D.BlkLen := StartSndBlkSz;
        tx := bdtxReadBlock;
      end;
    bdTxGotM_GET:
      begin
        if T.D.FOfs = T.D.FSize then
        begin
          FFinishSend(Self, aaRefuse);
          tx := bdtxGetNextFile;
        end else
        begin
          SendMsg(M_FILE, FileStr(T, True));
          if rx = bdrxDone then i := MaxSndBlkSz else i := DuplexBlkSz;
          T.D.BlkLen := i;
          tx := bdtxReadBlock;
        end;
      end;
    bdTxReadNextBlock:
      begin
        if rx = bdrxDone then i := MaxSndBlkSz else i := DuplexBlkSz;
        T.D.BlkLen := MinD(i, T.D.BlkLen * 2);
        tx := bdtxReadBlock;
      end;
    bdtxReadBlock:
      if not GotM_GET then
      if M_GOT_Coll.Count > 0 then Got__(M_GOT_Coll, aaRefuse) else
      if M_SKIP_Coll.Count > 0 then Got__(M_SKIP_Coll, aaAcceptLater) else
      begin
        i := MinD(T.D.BlkLen, T.D.FSize - T.D.FPos);
        SetLastError(0);
        if (T.Stream.Read(aOut, i) <> i) or (GetLastError <> 0) then
        begin
          FFinishSend(Self, aaSysError);
          State := bdFinishFail;
        end else
        begin
          TxBlkSize := i;
          TxBlkPos  := 0;
          tx := bdtxTransmit;
        end;
      end;
    bdtxTransmit:
      if CanSend then
      begin
        if TxBlkPos = 0 then
        begin
          OutMsgsLocked := True;
          SendDataHdr(TxBlkSize);
        end;
        i := MinD(TxBlkSize-TxBlkPos, SubBlkSz);
        SetTimeout;
        WriteProc(aOut[TxBlkPos], i);
        Inc(T.D.FPos, i);
        if T.D.FPos = T.D.FSize then
        begin
          SendDataHdr(0);
          OutMsgsLocked := False;
          SendDummy;
          FlushOutMsgs;
          OutFlow := False;
          tx := bdtxWait_M_GOT;
        end else
        begin
          Inc(TxBlkPos, i);
          if TxBlkPos = TxBlkSize then
          begin
            tx := bdTxReadNextBlock;
            OutMsgsLocked := False;
            FlushOutMsgs;
          end;
        end;
      end;
    bdtxWait_M_GOT :
      if not GotM_GET then
      if M_GOT_Coll.Count > 0 then Got__(M_GOT_Coll, aaOK) else
      if M_SKIP_Coll.Count > 0 then Got__(M_SKIP_Coll, aaAcceptLater);


    bdtxCheckSendEOB :
      begin
        FLogFile(Self, lfBinkPCanEOB);
        case CustomInfo[1] of
          'a' : OutFlow := False;
          'b' : tx := bdtxSendEOB;
          'c' : tx := bdtxGetNextFile;
        end;
        { CustomInfo := 'EOB/'+CustomInfo[1]; FLogFile(Self, lfDebug);}
      end;
    bdtxSendEOB :
      begin
        OutFlow := False;
        FLogFile(Self, lfBatchSendEnd);
        SendId(M_EOB);
        SendDummy;
        tx := bdtxDone;
      end;
    else
      GlobalFail('%s', ['bdtx']);
  end;
end;


procedure TBinkP.DoRx;

function ParseFileData(AStr: String): Boolean;
var
  s: string;

procedure DoGet; begin GetWrd(AStr, s, ' ') end;

var
  i: DWORD;
begin
  Result := False;
  DoGet;
  if not StrDeQuote(s) then Exit;
  R.D.FName := s;
  DoGet;
  i := Vl(s); if i = INVALID_VALUE then Exit;
  R.D.FSize := i;
  DoGet;
  i := Vl(s); if i = INVALID_VALUE then Exit;
  R.D.FTime := i;
  DoGet;
  if (s = '') or (AStr <> '') then Exit;
  i := Vl(s); if i = INVALID_VALUE then Exit;
  R.D.FOfs := i;
  Result := True;
end;

procedure Add_M_GOT;
begin
  M_GOT_Coll.Add(InMsg);
  FlushPkt;
end;

procedure Add_M_GET;
begin
  M_GET_Coll.Add(InMsg);
  FlushPkt;
end;

procedure Add_M_SKIP;
begin
  M_SKIP_Coll.Add(InMsg);
  FlushPkt;
end;

function Skip: Boolean;

procedure Snd(C: Byte);
begin
  SendMsg(C, FileStr(R, False));
  SendDummy;
end;

begin
  Result := FileRefuse or FileSkip;
  if not Result then Exit;
  if FileSkip then
  begin
    Snd(M_SKIP);
    FFinishRece(Self, aaAcceptLater);
  end else
  if FileRefuse then
  begin
    Snd(M_GOT);
    FFinishRece(Self, aaRefuse);
  end;
  rx := bdrxWaitFile;
end;


begin
  case rx of
    bdrxInit :
      rx := bdrxStartWaitFile;
    bdrxStartWaitFile:
      rx := bdrxWaitFile;
    bdrxWaitFile :
      case RxPkt of
        pktNone : ;
        pktData : begin FlushPkt; rx := bdrxStartWaitFile end;
        MinErr..MaxErr : ;
        Integer(M_ERR) : State := bdGotErr;
        Integer(M_GOT) : begin Add_M_GOT; rx := bdrxStartWaitFile end;
        Integer(M_GET) : begin Add_M_GET; rx := bdrxStartWaitFile end;
        Integer(M_SKIP): begin Add_M_SKIP; rx := bdrxStartWaitFile end;
        Integer(M_NUL) : begin LogNul; rx := bdrxStartWaitFile end;
        Integer(M_EOB) : rx := bdrxGot_M_EOB;
        Integer(M_FILE): begin R.ClearFileInfo; rx := bdrxStartFile end;
        else if RxPktKnown then State := bdUnrec else begin FlushPkt; rx := bdrxStartWaitFile end;
      end;
    bdrxStartFile:
      if not ParseFileData(InMsg) then
      State := bdUnrec
      else
      begin
        ReceFileStr := FileStr(R, False);
        case FAcceptFile(Self) of
          aaOK : rx := bdrxStartReceData;
          aaRefuse :
            begin
              SendMsg(M_GOT, ReceFileStr);
              SendDummy;
              rx := bdrxWaitFile;
            end;
          aaAcceptLater :
            begin
              SendMsg(M_SKIP, ReceFileStr);
              SendDummy;
              rx := bdrxWaitFile;
            end;
          aaAbort :
          State := bdFinishFail;
        end;
        FlushPkt;
      end;
    bdrxStartReceData:
      if R.D.FOfs = 0 then rx := bdrxReceData else
      begin
        ReceSyncStr := FileStr(R, True);
        SendMsg(M_GET, ReceSyncStr);
        SendDummy;
        rx := bdrxWaitFileSync;
      end;
    bdrxStartWaitFileSync:
      rx := bdrxWaitFileSync;
    bdrxWaitFileSync:
      case RxPkt of
        pktNone : ;
        pktData : begin FlushPkt; rx := bdrxStartWaitFileSync; end;
        MinErr..MaxErr  : ;
        Integer(M_ERR)  : State := bdGotErr;
        Integer(M_GOT)  : begin Add_M_GOT; rx := bdrxStartWaitFileSync; end;
        Integer(M_GET)  : begin Add_M_GET; rx := bdrxStartWaitFileSync; end;
        Integer(M_SKIP) : begin Add_M_SKIP; rx := bdrxStartWaitFileSync; end;
        Integer(M_NUL)  : begin LogNul; rx := bdrxStartWaitFileSync; end;
        Integer(M_FILE) : rx := bdrxGotFileSync;
        else if RxPktKnown then State := bdUnrec else begin FlushPkt; rx := bdrxStartWaitFileSync; end;
      end;
    bdrxGotFileSync:
      begin
        if UpperCase(InMsg) = UpperCase(ReceSyncStr) then rx := bdrxReceData
          else State := bdUnrec;
        FlushPkt;
      end;
    bdrx_ReceData:
      begin
        rx := bdrxReceData;
      end;
    bdrxReceData:
      if not Skip then
      case RxPkt of
        pktNone : ;
        pktData :
          begin
            rx := bdrx_ReceData;
            SetLastError(0);
            if (R.Stream.Write(aIn, InRep) <> InRep) or (GetLastError <> 0) then
            begin
              FFinishRece(Self, aaSysError);
              State := bdFinishFail;
            end else
            begin
              Inc(R.D.FPos, InRep);
              if R.D.FPos > R.D.FSize then
              begin
                // Received data after eof
                State := bdFinishFail;
              end else
              if R.D.FPos = R.D.FSize then
              begin
                FFinishRece(Self, aaOK);
                SendMsg(M_GOT, ReceFileStr);
                SendDummy;
                rx := bdrxWaitFile;
              end;
            end;
            FlushPkt;
          end;
        MinErr..MaxErr : ;
        Integer(M_ERR) : State := bdGotErr;
        Integer(M_GOT) : begin Add_M_GOT; rx := bdrx_ReceData end;
        Integer(M_GET) : begin Add_M_GET; rx := bdrx_ReceData end;
        Integer(M_SKIP): begin Add_M_SKIP; rx := bdrx_ReceData end;
        Integer(M_NUL) : begin LogNul; rx := bdrx_ReceData end;
        else if RxPktKnown then State := bdUnrec else begin FlushPkt; rx := bdrx_ReceData end;
      end;
    bdrxGot_M_EOB:
      begin
        FLogFile(Self, lfBatchReceEnd);
        FlushPkt;
        rx := bdrxDone;
      end;
    bdrx_Done:
      rx := bdrxDone;
    bdrxDone :
      case RxPkt of
        pktNone : ;
        MinErr..MaxErr : ;
        Integer(M_ERR) : State := bdGotErr;
        Integer(M_GOT) : begin Add_M_GOT; rx := bdrx_Done end;
        Integer(M_GET) : begin Add_M_GET; rx := bdrx_Done end;
        Integer(M_SKIP): begin Add_M_SKIP; rx := bdrx_Done end;
        Integer(M_NUL) : begin LogNul; rx := bdrx_Done end;
        else if RxPktKnown then State := bdUnrec else begin FlushPkt; rx := bdrx_Done end;
      end;
  end;
end;

function TBinkP.NextStep: boolean;
begin
  repeat
    repeat
      OnceAgain := False;
      OldOldOldState := OldOldState;
      OldOldState := OldState;
      OldState := State;
      DoStep;
    until (OldState = State) and (not OnceAgain);
    FlushOutMsgs;
    Result := (ProtocolError <> ecOK) or (State = bdDone);
    if not Result then
    case RxPkt of
      pktNone: Break;
      pktDCD:
        begin
          if (rx <> bdrxDone) or (tx <> bdtxDone) then ProtocolError := ecAbortNoCarrier;
          Result := True;
        end;
      pktAbort:
        begin
          ProtocolError := ecAbortByLocal;
          Result := True;
        end;
      pktTimeout:
        begin
          ProtocolError := ecTimeout;
          Result := True;
        end;
    end;
    if Result then
    begin
      if not RxClosed then
      begin
        FFinishRece(Self,aaAbort);
      end;
      if not TxClosed then
      begin
        FFinishSend(Self,aaAbort);
      end;
    end;
  until Result;
  if (R <> nil) and (rx <> bdrxWaitFileSync) then R.D.Part := InCur else R.D.Part := 0;
end;

procedure TBinkP.Start({RX}AAcceptFile: TAcceptFile; AFinishRece: TFinishRece;
                       {TX}AGetNextFile: TGetNextFile; AFinishSend: TFinishSend);
begin
  inherited Start(AAcceptFile, AFinishRece, AGetNextFile, AFinishSend);
  State := bdInit;
  PktRx := bdprxHdrHi;
  CurPkt := pktNone;
  InCur := 0;
  T.D.BlkLen := 0;
  R.D.BlkLen := 0;
  M_GOT_Coll.FreeAll;
  M_GET_Coll.FreeAll;
  M_SKIP_Coll.FreeAll;
  OutMsgsColl.FreeAll;
  OutMsgsLocked := False;
  SetTimeout;
end;

procedure TBinkP.SendId(Id: Byte);
var
  s: string;
begin
  s := #$80#$01+Char(Id);
  OutMsgsColl.Add(s);
  FlushOutMsgs;
end;

procedure TBinkP.SendMsg(Id: Byte; const Msg: string);
begin
  OutMsgsColl.Add(FormatBinkPMsg(Id, Msg));
  FlushOutMsgs;
end;

procedure TBinkP.SendDataHdr(Sz: DWORD);
begin
  PutCharProc(Hi(Sz));
  PutCharProc(Lo(Sz));
end;

function TBinkP.GetStateStr: string;
begin
  Result := Format('%s st=%s/%s/%s/%s tx=%s rx=%s blk=%s', [GetRxPktName, BinkPStateMsg[OldOldOldState], BinkPStateMsg[OldOldState], BinkPStateMsg[OldState], BinkPStateMsg[State], BinkPtxMsg[tx], BinkPrxMsg[rx], BinkPPktRxMsg[PktRx]]);
end;

function TBinkP.GetCharPlain(var C: Byte): Boolean;
begin
  Result := CP.GetChar(C);
end;


procedure TBinkP.GetOctetDES;
var
  B: Byte;
  P: PByteArray;
begin
  P := @DesInBuf;
  while (DesInCollectPos < 8) do
  begin
    if not CP.GetChar(B) then Break;
    P^[DesInCollectPos] := B;
    Inc(DesInCollectPos);
  end;
  if DesInCollectPos = 8 then
  begin
    xdes_cbc_encrypt(DesInBuf, DesKeySchedule, ivIn, False);
    DesInCollectPos := 9;
    DesInGivePos := 0;
  end;
end;

function TBinkP.GetCharDES(var C: Byte): Boolean;
var
  P: PByteArray;
begin
  Result := False;
  GetOctetDES;
  if DesInCollectPos = 9 then
  begin
    Result := True;
    P := @DesInBuf;
    C := P^[DesInGivePos];
    Inc(DesInGivePos);
    if DesInGivePos = 8 then DesInCollectPos := 0;
  end;
end;

procedure TBinkP.WritePlain(const Buf; i: DWORD);
var
  p: PByteArray;
  c: DWORD;
begin
  if i = 0 then Exit;
  p := @Buf;
  for c := 0 to i-1 do CP.PutChar(p^[c]);
end;

procedure TBinkP.WriteDES(const Buf; i: DWORD);
var
  c: Integer;
begin
  if i > 0 then
  begin
    for c := 0 to i-1 do PutCharDES(PxByteArray(@Buf)^[c]);
  end;  
end;

procedure TBinkP.PutCharPlain(c: Byte);
begin
  CP.PutChar(c);
end;

procedure TBinkP.PutCharDES(c: Byte);
var
  j: Integer;
  P: PByteArray;
begin
  P := @DesOutBuf;
  P^[DesOutPos] := c;
  Inc(DesOutPos);
  if DesOutPos = 8 then
  begin
    xdes_cbc_encrypt(DesOutBuf, DesKeySchedule, ivOut, True);
    for j := 0 to 7 do CP.PutChar(P^[j]);
    Inc(DesOuts);
    if DesOuts > 32 then
    begin
      CP.Flsh;
      DesOuts := 0;
    end;
    DesOutPos := 0;
  end;
end;

function TBinkP.CharReadyPlain: Boolean;
begin
  Result := CP.CharReady;
end;

function TBinkP.CharReadyDES: Boolean;
begin
  Result := DesInCollectPos = 9;
  if (not Result) and (CP.CharReady) then
  begin
    GetOctetDES;
    Result := CharReadyDES;
  end;
end;

procedure TBinkP.SetDesOut;
begin
  SendDummies := True;
  WriteProc := WriteDES;
  PutCharProc := PutCharDES;
  DesOutPos := 0;
end;

procedure TBinkP.SetDesIn;
begin
  GetCharFunc := GetCharDES;
  CharReadyFunc := CharReadyDES;
  DesInCollectPos := 0
end;

function TBinkP.RxPktKnown: Boolean;
begin
  case RxPkt of
    M_NUL,
    M_ADR,
    M_PWD,
    M_FILE,
    M_OK,
    M_EOB,
    M_GOT,
    M_ERR,
    M_BSY,
    M_GET,
    M_SKIP: Result := True
    else Result := False;
  end;
end;

procedure TBinkP.FreeChallenge;
begin
  if ChallengePtr = nil then Exit;
  FreeMem(ChallengePtr, ChallengeSize);
  ChallengePtr := nil;
end;

function TBinkP.MakePwdStr(const AStr: string): string;
begin
  if ChallengePtr = nil then begin Result := AStr; Exit end;
  Result := 'CRAM-MD5-'+KeyedMD5(AStr[1], Length(AStr), ChallengePtr^, ChallengeSize);
  CRAM := True;
  FreeChallenge;
end;

function CreateBinkPProtocol(CP: Pointer): Pointer;
begin
  Result := TBinkP.Create(CP);
end;


end.


