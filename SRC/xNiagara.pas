unit xNiagara;

interface

function AddNiagara(CP: Pointer; AOriginator: Boolean): Pointer;
procedure RemoveNiagara(var CP: Pointer);


implementation uses xBase, xMisc, SysUtils, Windows;

const
  cNiagaraOutQueueSize = PortOutBufSize;
  cNiagaraInQueueSize  = PortInBufSize*2;
  cNiagaraMaxOutBlkNum = 31;
  cNiagaraMaxInBlkNum  = 31;

type
  TNiagaraInState = (
    nsNone,
    nsSync,
    nsCollLEN,
    nsCollACK,
    nsCollSEQ,
    nsCollData
  );

  TNiagaraByteResult = (
    nbrNone,
    nbrNothing,
    nbrGotGood,
    nbrGotBad
  );

  PNiagaraPacket = ^TNiagaraPacket;
  TNiagaraPacket = packed record
    Used,
    Sent: Boolean;
    LEN: DWORD;
    SEQ: Integer;
    Buf: array[Byte] of Byte;
  end;

  TNiagaraPort = class(TMapPort)
  private
    ErrorStrColl: TStringColl;
    InACK,
    LastInACK,
    InQueuePos,
    LastSentACK,
    OutBlkNum,
    OutQueueLen,
    OutBlkPos,             // position of block to send
    InQueueLen,
    InSEQ,
    OutSEQ,
    NeedInSEQ: Integer;
    Originator: Boolean;
    TimerIdleACK: EventTimer;
    TCPStrOK,
    NegativeACK,
    PushAllowed,
    NeedEscape: Boolean;
    CRC: DWORD;
    State: TNiagaraInState;
    InBlkNum,
    SynCnt,
    InPktPos,
    InLEN,
    AcksInRow : DWORD;
    InXor,
    OutXor: Byte;
    OutBlkPtrs: array[0..cNiagaraMaxOutBlkNum-1] of PNiagaraPacket;
    OutBlkSlots: array[0..cNiagaraMaxOutBlkNum-1] of TNiagaraPacket;
    InBlkPtrs: array[0..cNiagaraMaxInBlkNum-1] of PNiagaraPacket;
    InBlkSlots: array[0..cNiagaraMaxInBlkNum-1] of TNiagaraPacket;
    InPkt: array[0..259] of Byte;
    OutQueueBuf: array[0..cNiagaraOutQueueSize-1] of Byte;
    InQueueBuf: array[0..cNiagaraInQueueSize-1] of Byte;
    procedure PurgeInQueueBuf;
    function ProcessByte(B: Byte): TNiagaraByteResult;
    function GetAvailSlotOut: PNiagaraPacket;
    function GetAvailSlotIn: PNiagaraPacket;
    procedure TossInPkts(L, R: Integer);
    procedure InsertGoodInBlk;
    procedure ProcessInACK;
    procedure PushOutPkt(LEN: DWORD; SEQ: Integer; D: PxByteArray);
    procedure PushOutPkts;
    procedure PushOutQueue;
    procedure PullInPort;
    procedure ForcedLifeCycle;
  public
    function  GetChar(var C: Byte): Boolean;            override;
    function  CharReady: Boolean;                       override;
    procedure PutChar(C: Byte);                         override;
    procedure Flsh;                                     override;
    function  Write(const Buf; Size: DWORD): DWORD; override;
    function  OutUsed: DWORD;                         override;
    constructor Create(ADevicePort: TDevicePort; AOriginator: Boolean);
    destructor Destroy;                                 override;
  public
    function  GetErrorStrColl: TStringColl;             override;
  end;

function AddNiagara;
begin
  Result := TNiagaraPort.Create(CP, AOriginator);
end;

procedure RemoveNiagara(var CP: Pointer);
var
  MP: TMapPort;
begin
  MP := CP;
  CP := MP.ExtractPort;
  FreeObject(MP);
end;



{

  B  LEN
  B  ACK
  B  SEQ
   ...
  D  CRC

}


const
  cSyn = 24;
  SynLen = 5;

function TNiagaraPort.ProcessByte(B: Byte): TNiagaraByteResult;
begin
  Result := nbrNothing;
  B := B xor InXor;
  if B <> cSyn then SynCnt := 0 else
  begin
    Inc(SynCnt);
    NeedEscape := SynCnt < SynLen;
    if not NeedEscape then
    begin
      SynCnt := 0;
      if State = nsCollData then
      begin
        ErrorStrColl.Add('Block data unexpected end, seq byte = '+Hex2(InSeq)+'??');
      end;
      State := nsCollLEN;
    end;
    Exit;
  end;
  if NeedEscape then
  begin
    B := B xor $40;
    NeedEscape := False;
  end;

  case State of
    nsSync : ; // do nothing, continue waiting
    nsCollLEN:
      begin
        InPktPos := 0;
        CRC := CRC32_INIT;
        CRC := UpdateCRC32(B, CRC);
        InLEN := B;
        State := nsCollACK;
      end;
    nsCollACK:
      begin
        CRC := UpdateCRC32(B, CRC);
        InACK := B;
        State := nsCollSEQ;
      end;
    nsCollSEQ:
      begin
        CRC := UpdateCRC32(B, CRC);
        InSEQ := B;
        State := nsCollData;
      end;
    nsCollData:
      begin
        CRC := UpdateCRC32(B, CRC);
        InPkt[InPktPos] := B;
        Inc(InPktPos);
        if InPktPos = InLEN + SizeOf(CRC) then
        begin
          if CRC <> CRC32_TEST then
          begin
            ErrorStrColl.Add('Block data CRC error, seq byte = '+Hex2(InSeq)+'??');
            Result := nbrGotBad;
          end else
          begin
            TCPStrOK := True;
            Result := nbrGotGood;
          end;
          State := nsSync;
        end;
      end;
    else GlobalFail('%s', ['Niagara State ??']);
  end;
end;

function TNiagaraPort.GetAvailSlotOut: PNiagaraPacket;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to cNiagaraMaxOutBlkNum-1 do
  begin
    if not OutBlkSlots[i].Used then
    begin
      Result := @OutBlkSlots[i];
      Result.Used := True;
      Result.Sent := False;
      Break;
    end;
  end;
  if Result = nil then GlobalFail('%s', ['TNiagaraPort.GetAvailSlotOut']);
end;

function TNiagaraPort.GetAvailSlotIn: PNiagaraPacket;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to cNiagaraMaxInBlkNum-1 do
  begin
    if not InBlkSlots[i].Used then
    begin
      Result := @InBlkSlots[i];
      Result.Used := True;
      Break;
    end;
  end;
  if Result = nil then GlobalFail('%s', ['TNiagaraPort.GetAvailSlotIn']);
end;


procedure TNiagaraPort.PushOutQueue;
var
  cLen: DWORD;
  Slot: PNiagaraPacket;
begin
  // optimize here

//  if OutQueueLen = 0 then Exit;

  while (OutBlkNum < cNiagaraMaxOutBlkNum-1) and (OutQueueLen > 0) do
  begin
    cLen := MinD(OutQueueLen, 255);
    if cLen = 0 then GlobalFail('%s', ['Niagara cLen = 0']);
    Slot := GetAvailSlotOut;
    OutBlkPtrs[OutBlkNum] := Slot;
    Inc(OutBlkNum);
    Slot.LEN := cLen;
    OutSEQ := (OutSEQ+1) and $7F;
    Slot.SEQ := OutSEQ;
    Dec(OutQueueLen, cLen);
    Move(OutQueueBuf, Slot.Buf, cLen);
    if OutQueueLen > 0 then Move(OutQueueBuf[cLen], OutQueueBuf, OutQueueLen);
  end;

end;

function CmpSeq(a,b: Integer): Integer; assembler;
asm
  mov  ecx, eax
  sub  ecx, edx
  jns  @@1
  neg  ecx
@@1:
  cmp  ecx, 20h
  jb   @@2
  cmp  eax, edx
  ja   @@3
  sub  edx, $80
  add  eax, $80
@@3:
  add  edx, $80
@@2:
  sub  eax, edx
end;


procedure TNiagaraPort.PushOutPkts;

var
  Sent: Boolean;

procedure SendACK;
begin
  PushOutPkt(0, 0, nil);
  Sent := True;
end;

procedure Push;
var
  p: PNiagaraPacket;
begin
  while (OutBlkPos < OutBlkNum) and (DevicePort.OutUsed < 1024) do
  begin
    p := OutBlkPtrs[OutBlkPos];
    if not p.Sent then
    begin
      PushOutPkt(p.LEN, p.SEQ, @p.Buf);
      p.Sent := True;
      Sent := True;
    end;
    Inc(OutBlkPos);
  end;
end;

begin
  Sent := False;
  if OutBlkPos > OutBlkNum then GlobalFail('Niagara OutBlkPos(%d) > OutBlkNum(%d)', [OutBlkPos, OutBlkNum]);
  Push;
  if NegativeACK then SendACK;
  if (PushAllowed) and (not Sent) and (OutBlkNum>0) and (OutBlkPtrs[0].SEQ = LastInACK) and (TimerExpired(TimerIdleACK)) and (DevicePort.OutUsed = 0) then
  begin
//    ErrorStrColl.Add('Resending idle block data, seq byte = '+Hex2(OutBlkPtrs[0].SEQ));
    PushAllowed := False;
    OutBlkPos := 0;
    OutBlkPtrs[0].Sent := False;
    Push;
  end;
  if (not Sent) and (NeedInSEQ <> LastSentACK) then SendACK;
  if (not Sent) and (TimerExpired(TimerIdleACK)) and (DevicePort.OutUsed < 512) then SendACK;
  if Sent then DevicePort.Flsh;
end;


procedure TNiagaraPort.PushOutPkt(LEN: DWORD; SEQ: Integer; D: PxByteArray);
const
  ACKs: array[Boolean] of Integer = (0, $80);
var
  CRC: DWORD;
  i: Integer;

procedure DevicePortPutChar(C: Byte);
begin
  DevicePort.PutChar(C xor OutXor);
end;

procedure PutCharEscaped(B: Byte);
begin
  case B of
    cSyn:
      begin
        DevicePortPutChar(cSyn);
        DevicePortPutChar(B xor $40)
      end;
    else DevicePortPutChar(B)
  end;
end;

procedure OutByte(B: Byte);
begin
  CRC := UpdateCRC32(B, CRC);
  PutCharEscaped(B);
end;

begin
  if not TCPStrOK then
  begin
    if Originator then DevicePort.SendString(EMSI_TZP) else DevicePort.SendString(EMSI_PZT);
  end;
  for i := 0 to SynLen-1 do DevicePortPutChar(cSyn);
  CRC := CRC32_INIT;
  OutByte(LEN);
  LastSentACK := NeedInSEQ;
  OutByte(NeedInSEQ or ACKs[NegativeACK]);
  NegativeACK := False;
  OutByte(SEQ);
  if LEN > 0 then for i := 0 to LEN-1 do OutByte(D[i]);
  CRC := CRC32Post(CRC);
  PutCharEscaped((CRC shr 00) and $FF);
  PutCharEscaped((CRC shr 08) and $FF);
  PutCharEscaped((CRC shr 16) and $FF);
  PutCharEscaped((CRC shr 24) and $FF);
  NewTimer(TimerIdleACK, 20);
end;

procedure TNiagaraPort.PurgeInQueueBuf;
begin
  Dec(InQueueLen, InQueuePos);
  if InQueueLen > 0 then Move(InQueueBuf[InQueuePos], InQueueBuf, InQueueLen);
  InQueuePos := 0;
end;


procedure TNiagaraPort.InsertGoodInBlk;
var
  Slot: PNiagaraPacket;
  i: Integer;
begin
  i := CmpSeq(InSEQ, NeedInSeq);
  if i < 0 then Exit;
  if InBlkNum > 0 then for i := 0 to InBlkNum-1 do if InBlkPtrs[i].SEQ = InSEQ then Exit;
  Slot := GetAvailSlotIn;
  InBlkPtrs[InBlkNum] := Slot;
  Inc(InBlkNum);
  Slot.LEN := InLEN;
  Slot.SEQ := InSEQ;
  if InLen > 0 then Move(InPkt, Slot.Buf, InLEN);
  TossInPkts(0, InBlkNum-1);
  while (InQueueLen < cNiagaraInQueueSize-255) and
        (InBlkNum>0) and
        (InBlkPtrs[0].SEQ = NeedInSeq) do
  begin
    Move(InBlkPtrs[0].Buf, InQueueBuf[InQueueLen], InBlkPtrs[0].LEN);
    Inc(InQueueLen, InBlkPtrs[0].LEN);
    NeedInSeq := (NeedInSeq+1) and $7F;
    InBlkPtrs[0].Used := False;
    Dec(InBlkNum);
    if InBlkNum > 0 then Move(InBlkPtrs[1], InBlkPtrs, InBlkNum*SizeOf(Pointer));
  end;
end;

procedure TNiagaraPort.ProcessInACK;
var
  Positive: Boolean;
  i, ACK: Integer;
begin
  // optimize here
  PushAllowed := True;
  if LastInACK = InACK then Inc(AcksInRow) else AcksInRow := 0;
  LastInACK := InACK;
  Positive := InACK < $80;
  ACK := InACK and $7F;
  while (OutBlkNum > 0) and (CmpSeq(OutBlkPtrs[0].SEQ, ACK) < 0) do
  begin
    AcksInRow := 0;
    PushAllowed := False;
    Dec(OutBlkPos); if OutBlkPos < 0 then OutBlkPos := 0;
    OutBlkPtrs[0].Used := False;
    Dec(OutBlkNum);
    if OutBlkNum > 0 then Move(OutBlkPtrs[1], OutBlkPtrs, OutBlkNum*SizeOf(Pointer));
  end;

  if OutBlkNum > 0 then
  begin
    if (AcksInRow >= 3) and (DevicePort.OutUsed = 0) then
    begin
      PushAllowed := False;
      AcksInRow := 0;
      OutBlkPos := 0;
      for i := 0 to MinI(2, OutBlkNum-1) do OutBlkPtrs[i].Sent := False;
    end else
    if (not Positive) then
    begin
      PushAllowed := False;
      OutBlkPos := 0;
      for i := 0 to OutBlkNum-1 do
      begin
        if CmpSeq(OutBlkPtrs[i].SEQ, ACK) = 0 then
        begin
          OutBlkPtrs[i].Sent := False;
          ErrorStrColl.Add('Resending block data, seq byte = '+Hex2(OutBlkPtrs[i].SEQ));
        end;
      end;
    end;
  end;
end;


procedure TNiagaraPort.PullInPort;
var
  C: Byte;
begin
  while DevicePort.GetChar(C) do
  begin
{    case Random(300) of
      1: Continue;
      2: C := C xor 12;
    end;}
    case ProcessByte(C) of       
      nbrNothing: ;
      nbrGotGood:
        begin
          if InLEN > 0 then InsertGoodInBlk;
          ProcessInACK;
        end;
      nbrGotBad:
        begin
          NegativeACK := True;
        end;
      else GlobalFail('%s', ['Niagara ProcessByte ??']);
    end;
  end;
  if InBlkNum = 0 then NegativeAck := False;
end;

procedure TNiagaraPort.TossInPkts(L, R: Integer);
var
  SEQ, I, J: Integer;
begin
  repeat
    I := L;
    J := R;
    SEQ := InBlkPtrs[(L + R) shr 1].SEQ;
    repeat
      while CmpSeq(InBlkPtrs[I].SEQ, SEQ) < 0 do Inc(I);
      while CmpSeq(InBlkPtrs[J].SEQ, SEQ) > 0 do Dec(J);
      if I <= J then
      begin
        XChg(Integer(InBlkPtrs[I]), Integer(InBlkPtrs[J]));
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then TossInPkts(L, J);
    L := I;
  until I >= R;
end;


// Overriden routines ===============================================

function TNiagaraPort.Write(const Buf; Size: DWORD): DWORD;
begin
  Result := MaxD(0, MinD(Size, cNiagaraOutQueueSize - OutQueueLen));
  if Result <> Size
  then GlobalFail('TNiagaraPort.Write Requested=%d Writen=%d', [Size, Result]);
  if Result <> 0 then
  begin
    Move(Buf, OutQueueBuf[OutQueueLen], Result);
    Inc(OutQueueLen, Result);
  end;
  ForcedLifeCycle;
end;

function TNiagaraPort.GetChar(var C: Byte): Boolean;
begin
  Result := CharReady;
  if Result then
  begin
    C := InQueueBuf[InQueuePos];
    Inc(InQueuePos);
  end;
end;

function TNiagaraPort.CharReady: Boolean;
begin
  Result := InQueuePos < InQueueLen;
  if not Result then
  begin
    PurgeInQueueBuf;
    Result := InQueuePos < InQueueLen;
  end;
end;

procedure TNiagaraPort.PutChar(C: Byte);
begin
  if OutQueueLen >= cNiagaraOutQueueSize then GlobalFail('TNiagaraPort.PutChar(%d) OutQueueLen(%d) >= cNiagaraOutQueueSize(%d)', [C, OutQueueLen, cNiagaraOutQueueSize]);
  OutQueueBuf[OutQueueLen] := Byte(C);
  Inc(OutQueueLen);
end;

procedure TNiagaraPort.Flsh;
begin
  DevicePort.Flsh;
  ForcedLifeCycle;
end;

function TNiagaraPort.OutUsed: DWORD;
begin
  Result := OutQueueLen + OutBlkNum*256 {+ DevicePort.OutUsed};
end;

constructor TNiagaraPort.Create(ADevicePort: TDevicePort; AOriginator: Boolean);
const
  xors: array[Boolean] of byte = ($10, $80);
begin
  inherited Create(ADevicePort);
  ErrorStrColl := TStringColl.Create;
  Originator := AOriginator;
  InXor  := xors[AOriginator];
  OutXor := xors[not AOriginator];
  State := nsSync;
  NeedInSeq := 1;
end;

procedure TNiagaraPort.ForcedLifeCycle;
begin
  PullInPort;
  PurgeInQueueBuf;
  PushOutQueue;
  PushOutPkts;
end;

destructor TNiagaraPort.Destroy;
begin
  FreeObject(ErrorStrColl);
  inherited Destroy;
end;

function TNiagaraPort.GetErrorStrColl: TStringColl;
begin
  Result := ErrorStrColl;
end;


end.
