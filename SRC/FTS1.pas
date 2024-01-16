unit FTS1;

interface

function CreateFTS1Protocol(CP: Pointer): Pointer;

implementation uses xBase, xMisc, SysUtils, Windows, xFido, Recs;

type
  TFTS1State = (
    rEndOfBatch,
    rError,
    rTlWaitFile,
    rAcceptFile,
    rSendNAK,
    rTlRecStart,
    rWaitFirst,
    rGotTeLink,
    rWaitBlock,
    rWaitBlock_,
    rInvWaitBlock,
    rSendEOTAck,
    rEOTAckDelay);

  TFTS1Protocol = class(TOneWayProtocol)
  public
    function GetStateStr: string;                               override;
    procedure ReportTraf(txMail, txFiles: DWORD);             override;
    constructor Create(ACP : TPort);
    procedure PrepareReceive(AAcceptFile: TAcceptFile; AFinishRece: TFinishRece); override;
    procedure PrepareTransmit(AGetNextFile: TGetNextFile; AFinishSend: TFinishSend); override;
    destructor Destroy; override;
    procedure Cancel; override;
    function  Receive: Boolean; override;
    function  Transmit : Boolean; override;
  private
    BlkPos, Tries: DWORD;
    State: TFTS1State;
    DataBlk: TXModemBlk;
    GotPkt: Boolean;
    MailerGot: Boolean;
    BlkNum: DWORD;
    function ReceiveBlock: TFTS1BlkType;
    procedure SetError;
    procedure Error(ErrCode: TProtocolError);
    function ParsePkt: Boolean;
    procedure CheckCancel;
  end;

function ChecksumBlock(const Buf; Len: DWORD): Byte; assembler;
asm
   mov  ecx, eax
   xor  eax, eax
@@AG:
   add  al, [ecx]
   inc  ecx
   dec  edx
   jnz  @@AG
end;

function TFTS1Protocol.GetStateStr: string;
begin
  Result := 'FTS-0001 (unknown state)';
end;

procedure TFTS1Protocol.ReportTraf(txMail, txFiles: DWORD);
begin
  GlobalFail('FTS1.ReportTraf(%d,%d)', [txMail, txFiles]);
end;

constructor TFTS1Protocol.Create(ACP : TPort);
begin
  inherited Create(ACP);
end;

destructor TFTS1Protocol.Destroy;
begin
  inherited Destroy;
end;

procedure TFTS1Protocol.PrepareReceive(AAcceptFile: TAcceptFile; AFinishRece: TFinishRece);
begin
  FAcceptFile := AAcceptFile;
  FFinishRece := AFinishRece;
  State := rTlWaitFile;
end;

procedure TFTS1Protocol.PrepareTransmit(AGetNextFile: TGetNextFile; AFinishSend: TFinishSend);
begin
  FGetNextFile := AGetNextFile;
  FFinishSend := AFinishSend;
end;

function TFTS1Protocol.ReceiveBlock: TFTS1BlkType;
var
  C: Byte;
  CRC: Word;
begin
  Result := btEmpty;
  while CP.GetChar(C) do
  begin
    PxByteArray(@DataBlk)^[BlkPos] := C;
    Inc(BlkPos);
    case DataBlk.Header of
      cSOH:
        if BlkPos = SizeOf(TXmodemBlk) then
        begin
          BlkPos := 0;
          if (DataBlk.BlockNumA) <> (not DataBlk.BlockNumB) then
          begin
            Result := btErr;
            Break;
          end;
          begin
            CRC := CRC16UsdBlock(DataBlk.Data, 128);
            if (Hi(CRC) <> DataBlk.CrcHi) or
               (Lo(CRC) <> DataBlk.CrcLo) then
            begin
              Result := btErr;
              Break;
            end;
          end;
          Result := btData;
          Break;
        end;
      cSYN:
        if BlkPos = SizeOf(TXModemBlk) - 1 then
        begin
          BlkPos := 0;
          if (DataBlk.BlockNumA <> 0) or
             (DataBlk.BlockNumB <> $FF) then
          begin
            Result := btErr;
            Break;
          end;
          C := ChecksumBlock(DataBlk.Data, 128);
          if C <> DataBlk.CrcHi then
          begin
            Result := btErr;
            Break;
          end;
          Result := btTeLink;
        end;
      cEOT:
        begin
          BlkPos := 0;
          Result := btEOT;
        end;
      cTSync:
        begin
          BlkPos := 0;
          Result := btTSync;
        end;
      else
        begin
          BlkPos := 0;
          Result := btNone;
        end;
    end;
  end;
end;

function TFTS1Protocol.ParsePkt: Boolean;
var
  pkt0001: TFTS1PktHdr;
  pkt0039: TFSC39PktHdr absolute pkt0001;
  pkt0045: TFSC45PktHdr absolute pkt0001;
  a: TFidoAddress;
  Pwd: string;
  ProductCode: Integer;
begin
  Result := False;
  GotPkt := True;
  Move(DataBlk.Data, pkt0001, SizeOf(pkt0001));
  Clear(a, SizeOf(a));
  a.Node := pkt0001.OrigNode;
  a.Net  := pkt0001.OrigNet;
  if pkt0001.rate = 2 then
  begin // This is a FSC-0045 (type 2.2) packet!
    a.Zone  := pkt0045.OrigZone;
    a.Point := pkt0045.OrigPoint;
    ProductCode := pkt0045.Product;
  end else
  begin
    if Swap(pkt0039.CapValid) = pkt0039.CapWord then
    begin // This is a FSC-0039 packet!
      a.Zone := pkt0039.OrigZone;
      a.Point := pkt0039.OrigPoint;
      ProductCode := pkt0039.ProductLow + pkt0039.ProductHi * $100;
    end else
    begin // FTS-0001 or bullshitted packet.
      a.Zone  := pkt0001.OrigZone;
      a.Point := 0;
      ProductCode := pkt0001.Product;
    end;
  end;
  if a.Zone = 0 then
  begin
    CfgEnter;
    a.Zone := Cfg.Pathnames.DefaultZone;
    CfgLeave;
  end;
  Pwd := ShortBuf2Str(pkt0001.Password, 8);
  CustomInfo := IntToStr(ProductCode);
  FLogFile(Self, lf1PCode);
  CustomInfo := Addr2Str(a);
  FLogFile(Self, lf1Addr);
  if CustomInfo <> '' then Exit;
  CustomInfo := Pwd;
  FLogFile(Self, lf1Pwd);
  if (CustomInfo = cBadPwd) or ((Length(CustomInfo) = 1) and (CustomInfo[1] < ' ')) then Exit;
  Result := True;
end;

function TFTS1Protocol.Receive: Boolean;
var
  OldState: TFTS1State;
  C: Byte;
  I: DWORD;
  s: string;
begin
  Result := False;
  CheckCancel;
  repeat
    OldState := State;
    case State of
      rError:
        Result := True;
      rEndOfBatch:
        Result := True;
      rTlWaitFile:
        begin
          BlkNum := 0;
          Tries := 0;
          State := rTlRecStart;
        end;
      rTlRecStart:
        begin
          Inc(Tries);
          NewTimerSecs(TimeoutTimer, 3);
          CP.PutChar(Ord('C'));
          if Tries > 20 then Error(ecTooManyErrors) else State := rWaitFirst;
        end;
      rSendEOTAck:
        begin
          NewTimer(TimeoutTimer, 2);  // 0.1 secs
          State := rEOTAckDelay;
        end;
      rEOTAckDelay:
        if Timeout then
        begin
          CP.PutChar(cACK);
          State := rTlWaitFile;
        end else
        begin
          repeat until not CP.GetChar(C); // purge input
        end;
      rWaitFirst:
        case ReceiveBlock of
          btNone,
          btEmpty:
            if Timeout then State := rTlRecStart;
          btErr,
          btTSync: State := rTlRecStart;
          btEOT: State := rEndOfBatch;
          btTeLink:
          begin
            uDosDateTimeToFileTime(TTelinkBlk(DataBlk.Data).FileDate, TTelinkBlk(DataBlk.Data).FileTime, R.D.FTime);
            State := rGotTeLink;
          end;
          btData:
          begin
            if DataBlk.BlockNumA <> 0 then Error(ecIncompatibleLink) else
            begin
              R.D.FTime := uGetSystemTime;
              State := rGotTeLink;
            end;
          end;
          else
          GlobalFail('%s', ['FTS1 ReceiveBlock ???']);
        end;
      rGotTeLink:
        begin
          CP.PutChar(cACK);
          CP.Flsh;
          R.D.FSize := TTelinkBlk(DataBlk.Data).FileLen;
          s := ShortBuf2Str(TTelinkBlk(DataBlk.Data).FileName, 16);
          if s = '' then R.D.FName := '' else R.D.FName := ShortBuf2StrEx(s[1], Length(s), ' ');
          if not MailerGot then
          begin
            MailerGot := True;
            CustomInfo := Trim(ShortBuf2Str(TTelinkBlk(DataBlk.Data).ProgramName, 16));
            FLogFile(Self, lf1Prog);
          end;
          State := rAcceptFile;
        end;
      rAcceptFile:
        begin
          Tries := 0;
          BlkNum := 1;
          NewTimerSecs(TimeoutTimer, 10);
          case FAcceptFile(Self) of
            aaOK : State := rWaitBlock;
            aaRefuse,
            aaAcceptLater,
            aaAbort: Error(ecTooManyErrors);
            else GlobalFail('FTS1.FAcceptFile(%s) ???', [R.D.FName]);
          end;
        end;
      rSendNAK:
        begin
          Inc(Tries);
          NewTimerSecs(TimeoutTimer, 10);
          CP.PutChar(cNAK);
          if Tries > 10 then Error(ecTooManyErrors) else State := rWaitBlock;
        end;
      rInvWaitBlock:
        if ElapsedTime(TimeoutTimer) > 2 then State := rSendNAK else State := rWaitBlock;
      rWaitBlock_:
        State := rWaitBlock;
      rWaitBlock:
        case ReceiveBlock of
          btTSync: State := rInvWaitBlock;
          btNone: State := rWaitBlock_;
          btEmpty: if Timeout then State := rSendNAK;
          btErr: State := rSendNAK;
          btEOT:
            if R.D.FPos > R.D.FSize then GlobalFail('FTS1 btEOT R.D.FPos(%d) > R.D.FSize(%d)', [R.D.FPos, R.D.FSize]) else
            if R.D.FPos <> R.D.FSize then State := rInvWaitBlock else
            begin
              FFinishRece(Self, aaOK);
              State := rSendEOTAck;
            end;
          btTeLink:
            Error(ecIncompatibleLink);
          btData:
            begin
              NewTimerSecs(TimeoutTimer, 10);
              if DataBlk.BlockNumA <> BlkNum then State := rSendNAK else
              if R.D.FPos > R.D.FSize then GlobalFail('FTS1 btData R.D.FPos(%d) > R.D.FSize(%d)', [R.D.FPos, R.D.FSize]) else
              if R.D.FPos = R.D.FSize then Error(ecTooManyErrors) else
              begin
                CP.PutChar(cACK);
                CP.Flsh;
                BlkNum := (BlkNum + 1) and $FF;
                if not GotPkt then ParsePkt;
                Tries := 0;
                SetLastError(0);
                I := MinD(R.D.FSize - R.D.FPos, 128);
                if (R.Stream.Write(DataBlk.Data, I) = I) and (GetLastError = 0) then
                begin
                  Inc(R.D.FPos, I);
                  State := rWaitBlock_;
                end else
                begin
                  FFinishRece(Self, aaSysError);
                  Error(ecTooManyErrors);
                end;
              end;
            end;
          else
          GlobalFail('%s', ['FTS1 ReceiveBlock ??']);
        end;
      else
      GlobalFail('%s', ['State ??']);
    end;
  until (OldState = State) or (Result);
  if (Result) and (not RxClosed) then FFinishRece(Self, aaAbort);
end;

function TFTS1Protocol.Transmit : Boolean;
begin
  Result := True;
end;

function CreateFTS1Protocol(CP: Pointer): Pointer;
begin
  Result := TFTS1Protocol.Create(CP);
end;

procedure TFTS1Protocol.SetError;
begin
  State := rError;
end;

procedure TFTS1Protocol.Cancel;
begin
  Error(ecAbortByLocal);
end;

procedure TFTS1Protocol.Error(ErrCode: TProtocolError);
begin
  ProtocolError := ErrCode;
  SetError;
end;


procedure TFTS1Protocol.CheckCancel;
begin
  if ProtocolStatus <> psAbortByLocal then
  begin
    if CancelRequested then Cancel else
    if not CP.CharReady then
    if CP.DCD <> CP.Carrier then
    begin
      CP.Carrier := not CP.Carrier;
      if State <> rWaitFirst then Error(ecAbortNoCarrier) else State := rEndOfBatch;
    end;
  end;
end;


end.

