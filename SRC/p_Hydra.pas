unit p_Hydra;

{$I DEFINE.INC}

{.$DEFINE HYDRA_DEBUG}

interface

type
  THydraOpt = (
    HOPT_XONXOFF ,      // Escape XON/XOFF
    HOPT_TELENET ,      // Escape CR-'@'-CR (Telenet escape)
    HOPT_CTLCHRS ,      // Escape ASCII 0-31 and 127
    HOPT_HIGHCTL ,      // Escape above 3 with 8th bit too
    HOPT_HIGHBIT ,      // Escape ASCII 128-255 + strip high
   {HOPT_CANBRK  ,      // Can transmit a break signal}
    HOPT_CANASC  ,      // Can transmit/handle ASC packets
    HOPT_CANUUE  ,      // Can transmit/handle UUE packets
    HOPT_CRC32          // Packets with CRC-32 allowed
   {HOPT_DEVICE  ,      // DEVICE packets allowed}
   {HOPT_FPT            // Can handle filenames with paths}
  );
  THydraOptSet = set of THydraOpt;

function CreateHydraProtocol(CP: Pointer; AWantOptions: THydraOptSet): Pointer;

implementation uses xBase, xMisc, SysUtils, Windows;

const
  H_MAXBLKLEN   = 2048; //  Max. length of a HYDRA data block
  H_OVERHEAD    = 8;    //  Max. no. control bytes in a pkt
  H_MAXPKTLEN   = ((H_MAXBLKLEN + H_OVERHEAD + 5) * 3);  //  Encodsed pkt
  H_BUFLEN      = (H_MAXPKTLEN + 16); // Buffer sizes: max.enc.pkt + slack

{ What we can do }
  HCAN_OPTIONS  = [HOPT_XONXOFF,HOPT_TELENET,HOPT_CTLCHRS,HOPT_HIGHCTL,
                   HOPT_HIGHBIT,{HOPT_CANBRK,}HOPT_CANASC,HOPT_CANUUE,
                   HOPT_CRC32{,HOPT_DEVICE}];

{ Vital options if we ask for any; abort if other side doesn't support them }
  HNEC_OPTIONS  = [HOPT_XONXOFF,HOPT_TELENET,HOPT_CTLCHRS,HOPT_HIGHCTL,
                   HOPT_HIGHBIT];

{ Non-vital options; nice if other side supports them, but doesn't matter }
  HUNN_OPTIONS  = [HOPT_CANASC,HOPT_CANUUE,HOPT_CRC32{,HOPT_DEVICE}];

{ RxOptions during init (needs to handle ANY link yet unknown at that point }
   HRXI_OPTIONS = [HOPT_XONXOFF,HOPT_TELENET,HOPT_CTLCHRS,HOPT_HIGHCTL,
                   HOPT_HIGHBIT];

{ Ditto, but this time TxOptions }
   HTXI_OPTIONS = [];

type
// HYDRA Transmitter States--------------------------------------------------- }
  THydraTxState = (
    HTX_DONE     ,                  {  All over and done                  }
    HTX_START    ,                  {  Send start autostr + START pkt     }
    HTX_SWAIT    ,                  {  Wait for any pkt or timeout        }
    HTX_INIT     ,                  {  Send INIT pkt                      }
    HTX_INITACK  ,                  {  Wait for INITACK pkt               }
    HTX_RINIT    ,                  {  Wait for HRX_INIT -> HRX_FINFO     }
    HTX_NEXTFILE ,                  {  Prepare to send the next file}
    HTX_FINFO    ,                  {  Send FINFO pkt                     }
    HTX_FINFOACK ,                  {  Wait for FINFOACK pkt              }
    HTX_XDATA    ,                  {  Send next packet with file data    }
    HTX_DATAACK  ,                  {  Wait for DATAACK packet            }
    HTX_XWAIT    ,                  {  Wait for HRX_END                   }
    HTX_EOF      ,                  {  Send EOF pkt                       }
    HTX_EOFACK   ,                  {  End of file, wait for EOFACK pkt   }
    HTX_REND     ,                  {  Wait for HRX_END AND HTD_DONE      }
    HTX_END      ,                  {  Send END pkt (finish session)      }
    HTX_ENDACK   ,                  {  Wait for END pkt from other side   }
    HTX_DRAIN
  );

// HYDRA Receiver States------------------------------------------------------ }
  THydraRxState = (
    HRX_DONE  ,                           {  All over and done                  }
    HRX_INIT  ,                           {  Wait for INIT pkt                  }
    HRX_FINFO ,                           {  Wait for FINFO pkt of next file    }
    HRX_DATA                              {  Wait for next DATA pkt             }
  );

  THydra = class(TBiDirProtocol)
  public
    function GetStateStr: string;                               override;
    procedure ReportTraf(txMail, txFiles: DWORD);             override;
    procedure Cancel;                                           override;
    function NextStep: boolean;                                 override;
    function TimeoutValue: DWORD;                             override;
    constructor Create(ACP: TPort; AWantOptions: THydraOptSet);
    procedure Start({RX}AAcceptFile: TAcceptFile;
                         AFinishRece: TFinishRece;
                     {TX}AGetNextFile: TGetNextFile;
                         AFinishSend: TFinishSend
                     ); override;
  private
    FWantOptions,
    RemoteOptions,
    TxOptions,
    RxOptions    : THydraOptSet;           // HYDRA options (INIT seq)
    PktPrefix,
    TxPktPrefix  : string;                 // pkt prefix str they want
    HydraTxWindow,
    HydraRxWindow,
    TxWindow,
    RxWindow     : Integer;              // window size (0=streaming)
    BrainDead    : EventTimer;             // BrainDead timer
    TxLastC,                               // last byte put in txbuf
    RxDLE,                                 // count of received H_DLEs
    RxPktFormat  : byte;                   // format of pkt receiving
    RxBufMax,                              // highwatermark of RxBuf
    RxBufPtr     : Integer;                             // current position in RxBuf
    RxPktLen     : DWORD;                // length of last packet
    TxState      : THydraTxState;
    RxState      : THydraRxState;          // xmit/recv states
    TxMaxBlkLen  : DWORD;                // max block length allowed
    TxLastAck    : DWORD;                // last dataack received
    TxTimer,
    RxTimer      : EventTimer;             // retry timers
    TxRetries,
    RxRetries    : DWORD;                // retry counters
    RxLastSync,                            // filepos last sync retry
    TxSyncID,
    RxSyncID     : DWORD;                // id of last resync
    TxGoodNeeded,                          // to send before larger blk
    TxGoodBytes  : DWORD;                // no. sent at this blk size
    ChatTimer    : Integer;
    BatchesDone  : DWORD;                // No. HYDRA batches done
    HdxLink      : boolean;                // Hdx link & not orig side
    Options      : THydraOptSet;           // INIT options hydra_init()
    TimeOut      : DWORD;                // General TimeOut in secs
    ShowInfo     : Boolean;
    HdxSession   : Boolean;
    d            : array[0..H_BUFLEN*2-1] of byte;

    function  h_GetLong( Index : byte ) : DWORD;
    function  h_GetLongI( Index : byte ) : Integer;
    procedure h_PutLong( Index : byte; Value : DWORD);
    procedure h_PutLongI( Index : byte; Value : Integer);
    procedure h_PutHex( Offset : DWORD; Value : DWORD);
    function  h_GetHex( Offset : DWORD) : DWORD;
    procedure Put_BinByte( var Index : DWORD; Ch : byte );
    procedure TxPkt( Len : DWORD; PktType : char );
    function  RxPkt: integer;
    procedure AddToBuf(const S: string; var Count: DWORD; B: Byte);
    procedure Do_Tx;
    procedure Do_Rx;
    procedure Do_PostTx;
    procedure Init_Tx;
    procedure Init_Rx;
    procedure StartBrainDeadTimer;
  end;


const
  ofsTx   = 0;
  ofsTxIn = ofsTx + (H_MAXBLKLEN + H_OVERHEAD + 5) * 2;
  ofsRx   = H_BUFLEN;

  HydraTxStateName: array[THydraTxState] of string = (
    'HydraTxDone',
    'HydraTxStart',
    'HydraTxSWait',
    'HydraTxInit',
    'HydraTxInitAck',
    'HydraTxRInit',
    'HydraTxNextFile',
    'HydraTxFInfo',
    'HydraTxFInfoAck',
    'HydraTxXData',
    'HydraTxDataAck',
    'HydraTxXWait',
    'HydraTxEOF',
    'HydraTxEOFAck',
    'HydraTxREnd',
    'HydraTxEnd',
    'HydraTxEndAck',
    'HydraTxDrain');

  HydraRxStateName : array[THydraRxState] of string = (
    'HydraRxDone',
    'HydraRxInit',
    'HydraRxFInfo',
    'HydraRxData');


  { HYDRA Specification Revision/Timestamp-----------Revision----Date-------- }
  H_PKTPREFIX   = 31;                   (* Max length of pkt prefix string   *)

  H_REVSTAMP    = $2B1AAB00;                      {  001         01 Dec 1992  }
  H_REVISION    = 1;

  H_DLE         = 24;                   {  Ctrl-X (^X) HYDRA DataLinkEscape   }
  H_MINBLKLEN   = 64;                   {  Min. length of a HYDRA data block  }
  H_FLAGLEN     = 3;                    {  Length of a flag field             }
  H_RETRIES     = 10;                   {  No. retries in case of an error    }
  H_MINTIMER    = 10;                   {  Minimum timeout period             }
  H_MAXTIMER    = 120;                  {  Maximum timeout period             }
  H_START       = 5;                    {  Timeout for re-sending startstuff  }
  H_IDLE        = 20;                   {  Idle? TX IDLE pkt every 20 secs    }
  H_BRAINDEAD   = 120;                  {  Braindead in 2 mins (120 secs)     }

type

{ HYDRA Device Packet Transmitter States------------------------------------- }
THydraDevPktTxState = (
  HTD_DONE,                             {  No device data pkt to send         }
  HTD_DATA,                             {  Send DEVDATA pkt                   }
  HTD_DACK                              {  Wait for DEVDACK pkt               }
);

const
{ HYDRA Packet Types--------------------------------------------------------- }
  HPKT_START    = 'A';                  {  Startup sequence                   }
  HPKT_INIT     = 'B';                  {  Session initialisation             }
  HPKT_INITACK  = 'C';                  {  Response to INIT pkt               }
  HPKT_FINFO    = 'D';                  {  File info (name, size, time)       }
  HPKT_FINFOACK = 'E';                  {  Response to FINFO pkt              }
  HPKT_DATA     = 'F';                  {  File data packet                   }
  HPKT_DATAACK  = 'G';                  {  File data position ACK packet      }
  HPKT_RPOS     = 'H';                  {  Transmitter reposition packet      }
  HPKT_EOF      = 'I';                  {  End of file packet                 }
  HPKT_EOFACK   = 'J';                  {  Response to EOF packet             }
  HPKT_END      = 'K';                  {  End of session                     }
  HPKT_IDLE     = 'L';                  {  Idle - just saying I'm alive       }
(*
  HPKT_DEVDATA  = 'M';                  {  Data to specified device           }
  HPKT_DEVDACK  = 'N';                  {  Response to DEVDATA pkt            }
  HPKT_HIGHEST  = 'N';                  {  Highest known pkttype in this imp  }
*)


{ HYDRA Internal Pseudo Packet Types----------------------------------------- }
  H_NOPKT       =  0;                   (* No packet (yet)                   *)
  H_CANCEL      = -1;                   (* Received cancel sequence 5*Ctrl-X *)
  H_CARRIER     = -2;                   (* Lost carrier                      *)
  H_SYSABORT    = -3;                   (* Aborted by operator on this side  *)
  H_TXTIME      = -4;                   (* Transmitter timeout               *)
//  H_DEVTXTIME   = -5;                   (* Device transmitter timeout        *)
  H_BRAINTIME   = -6;                   (* Braindead timeout (quite fatal)   *)

const
{ HYDRA Packet Format: START[<data>]<type><crc>END -------------------------- }
  HCHR_PKTEND   = 'a';                  {  End of packet (any format)         }
  HCHR_BINPKT   = 'b';                  {  Start of binary packet             }
  HCHR_HEXPKT   = 'c';                  {  Start of hex encoded packet        }
  HCHR_ASCPKT   = 'd';                  {  Start of shifted 7bit encoded pkt  }
  HCHR_UUEPKT   = 'e';                  {  Start of uuencoded packet          }

type
  FuncType   = Procedure( var Data; Len : Integer );

type
  _h_Flags = record
               FSt  : string[3];
               FVl : THydraOpt;
             end;

const
  H_FLAGNUM = 7;
  h_Flags : array[0..h_FlagNum] of _h_Flags = (( FSt : 'XON'; FVl : HOPT_XONXOFF ),
                                               ( FSt : 'TLN'; FVl : HOPT_TELENET ),
                                               ( FSt : 'CTL'; FVl : HOPT_CTLCHRS ),
                                               ( FSt : 'HIC'; FVl : HOPT_HIGHCTL ),
                                               ( FSt : 'HI8'; FVl : HOPT_HIGHBIT ),
                                               {(FSt : 'BRK'; FVl : HOPT_CANBRK  ),}
                                               ( FSt : 'ASC'; FVl : HOPT_CANASC  ),
                                               ( FSt : 'UUE'; FVl : HOPT_CANUUE  ),
                                               ( FSt : 'C32'; FVl : HOPT_CRC32   )
                                              {( FSt : 'DEV'; FVl : HOPT_DEVICE  ),}
                                              {( FSt : 'FPT'; FVl : HOPT_FPT     )});


function h_Crc16Test( Crc : word ) : boolean;
begin h_Crc16Test := (Crc = CRC16PROP_TEST) end;


function h_Crc32Test( Crc : DWORD ) : boolean;
begin h_Crc32Test := (Crc = CRC32_TEST) end;


function THydra.h_GetLong( Index : byte ) : DWORD; // Index = 1 - 3
begin
  Move(d[ofsRx+(Index - 1) * SizeOf(Integer)],Result,SizeOf(Integer));
end;

function THydra.h_GetLongI( Index : byte ) : Integer; // Index = 1 - 3
begin
  Move(d[ofsRx+(Index - 1) * SizeOf(Integer)],Result,SizeOf(Integer));
end;


procedure THydra.h_PutLong( Index : byte; Value : DWORD); // Index = 1 - 3
begin
  Move(Value,d[ofsTxIn+(Index - 1) * SizeOf(Integer)],SizeOf(Value));
end;

procedure THydra.h_PutLongI( Index : byte; Value : Integer); // Index = 1 - 3
begin
  Move(Value,d[ofsTxIn+(Index - 1) * SizeOf(Integer)],SizeOf(Value));
end;


procedure THydra.h_PutHex( Offset : DWORD; Value : DWORD);
var
  Count : Integer;
begin
  Inc(Offset,8);
  For Count := 1 to 8 do
    begin
      Dec(Offset);
      d[ofsTxIn+Offset] := Ord(rrLoHexChar[byte(Value) and $0f]);
      Value := Value shr 4;
    end;
end;


Function THydra.h_GetHex( Offset : DWORD) : DWORD;
var
  Digit : Char;
  Count,
  Value : DWORD;
begin
  Value := 0;
  for Count := 1 to 8 do
  begin
    Digit := Char(d[ofsRx+Offset]);
    Inc(Offset);
    Value := Value shl 4;
    case Digit of
      '0'..'9' : Inc(Value, Ord(Digit) - Ord('0'));
      'A'..'F' : Inc(Value, Ord(Digit) - Ord('A') + 10);
      'a'..'f' : Inc(Value, Ord(Digit) - Ord('a') + 10);
      else
        begin
          Result := 0;
          Exit;
        end;
    end;
  end;
  Result := Value;
end;

function h_UUEnc( Ch : byte ) : byte;
begin Result := (Ch and $3f) + Ord('!') end;

function h_UUDec( Ch : byte ) : byte;
begin Result := (Ch - Ord('!')) and $3f end;

(*---------------------------------------------------------------------------*)
function FlagsStr(Value : THydraOptSet ) : string;
var
  Counter: Integer;
begin
  Result := '';
  for Counter := 0 to H_FLAGNUM do
  begin
    if (h_Flags[Counter].FVl in Value) then
    begin
      if Result <> '' then AddStr(Result, ',');
      Result := Result + h_Flags[Counter].FSt;
    end;
  end;
end;

function Put_Flags(var Buf; Value : THydraOptSet ) : integer;
var
  Buffer: TxByteArray absolute Buf;
  Count,
  Counter : integer;
begin
  Count := 0;

  For Counter := 0 to H_FLAGNUM do
    begin
      If (h_Flags[Counter].FVl in Value) then
        begin
          If Count > 0 then
            begin
              Buffer[Count] := byte(',');
              Inc(Count);
            end;
          Move(h_Flags[Counter].FSt[1], Buffer[Count], H_FLAGLEN);
          Inc(Count,H_FLAGLEN);
        end;
    end;

  Buffer[Count] := 0; (*Nul*)
  Inc(Count);
  Put_Flags := Count;
end; (*Put_Flags*)

(*---------------------------------------------------------------------------*)
Function Get_Flags(const Buf) : THydraOptSet;
var
  Len,
  Count : integer;
  //Value : Integer;
  //St   : array[1..3] of char;
  Flags: string;
  Buffer: TxByteArray absolute Buf;
begin
  Result := [];
  Len := NulSearch(Buffer);
  if Len>0 then
  begin
    SetLength(Flags, Len);
    Move(Buffer, Flags[1], Len); Flags := ','+Flags+',';
    for Count := 0 to H_FLAGNUM do
      if Pos(','+h_Flags[Count].FSt+',',Flags)>0 then Include(Result,h_Flags[Count].FVl);
  end;
end; (*Get_Flags*)

(*---------------------------------------------------------------------------*)
procedure THydra.Put_BinByte( var Index : DWORD; Ch : byte );
var
  N : byte;
begin
  N := Ch;
  If (HOPT_HIGHCTL in TxOptions) then
     N := N and $7f;

  If ((N = H_DLE) or
     ((HOPT_XONXOFF in TxOptions ) and ((N = cXon) or (N = cXoff)) ) or
     ((HOPT_TELENET in TxOptions ) and (N = 13) and (TxLastC = byte('@'))) or
     ((HOPT_CTLCHRS in TxOptions ) and ((N < 32) or (n = 127)))) then
    begin
      d[ofsTx+Index] := H_DLE;
      Inc(Index);
      Ch := Ch xor $40;
    end;

  d[ofsTx+Index] := Ch;
  Inc(Index);
  TxLastC := N;
end; (*Put_BinByte*)


(*---------------------------------------------------------------------------*)
Procedure THydra.TxPkt( Len : DWORD; PktType : char );
const
  z: Byte = 0;
var
  Format   : byte;
  C,
  N,
  CrcW,
  IndexIn,
  IndexOut,
  CrcL     : DWORD;
  Crc32    : boolean;


{$IFDEF HYDRA_DEBUG}
procedure Dbg;
var
  s1: string;
begin
  DbgLogFmt('>-> PKT (format="%s" type="%s"  crc=%d  len=%d)',
    [char(format), char(PktType), 16*((Byte(Crc32))+1), len-1]);

  case PktType of
    HPKT_START:    DbgLog(    '>   <autostr>START');
    HPKT_INIT:     DbgLog(    '>   INIT');
    HPKT_INITACK:  DbgLog(    '>   INITACK');
    HPKT_FINFO:    DbgLog(    '>   FINFO');
    HPKT_FINFOACK:
      begin
        if R.Stream <> nil then
        begin
          if R.D.FPos > 0 then s1 := 'RES' else s1 := 'BOF'
        end else
        if R.D.FPos = -1 then s1 := 'HAVE' else
        if R.D.FPos = -1 then s1 := 'SKIP' else s1 := 'EOB';
        DbgLogFmt('>   FINFOACK (pos=%d %s  rxstate=%d)', [R.D.FPos, s1, Integer(rxstate)]);
      end;
    HPKT_DATA:     DbgLogFmt( '>   DATA (ofs=%d  len=%d)', [Integer(d[ofsTxIn]), len-5]);
    HPKT_DATAACK:  DbgLogFmt( '>   DATAACK (ofs=%d)', [Integer(d[ofsTxIn])]);
    HPKT_RPOS:     DbgLogFmt( '>   RPOS (pos=%d  blklen=%d  syncid=%d)', [R.D.FPos, Integer(d[ofsTxIn+4]), rxsyncid]);
    HPKT_EOF:      DbgLogFmt( '>   EOF (ofs=%d)', [T.D.FPos]);
    HPKT_EOFACK:   DbgLog(    '>   EOFACK');
    HPKT_IDLE:     DbgLog(    '>   IDLE');
    HPKT_END:      DbgLog(    '>   END');
  end;
end;
{$ENDIF}


begin
  Crc32 := false;

  d[ofsTxIn+Len] := byte(PktType);
  Inc(Len);

  Case PktType of
    HPKT_START,
    HPKT_INIT,
    HPKT_INITACK,
    HPKT_END,
    HPKT_IDLE : Format := byte(HCHR_HEXPKT);
  else
    begin
      (* COULD do smart format selection depending on data and options! *)
      If (HOPT_HIGHBIT in TxOptions) then
        begin
         If ((HOPT_CTLCHRS in TxOptions) and (HOPT_CANUUE in TxOptions)) then
           Format := byte(HCHR_UUEPKT)
         else If (HOPT_CANASC in TxOptions) then
           Format := byte(HCHR_ASCPKT)
         else
           Format := byte(HCHR_HEXPKT);
        end
      else
        Format := byte(HCHR_BINPKT);
    end;
  end;

  If ((Format <> byte(HCHR_HEXPKT)) and (HOPT_CRC32 in TxOptions)) then
    Crc32 := true;

  {$IFDEF HYDRA_DEBUG}
  if Debug then Dbg;
  {$ENDIF}


  If Crc32 then
    begin
      CrcL := Crc32Post(Crc32Block(d[ofsTxIn],Len, CRC32_INIT));
      Move(CrcL, d[ofsTxIn+Len], SizeOf(Integer));
      Inc(Len,SizeOf(Integer));
    end
  else
    begin
      CrcW := Crc16Post(Crc16PropBlock(d[ofsTxIn],Len));
      Move(CrcW, d[ofsTxIn+Len], SizeOf(word));
      Inc(Len,SizeOf(word));
    end;

  IndexIn  := 0;
  IndexOut := 0;
  TxLastC  := 0;

  d[ofsTx+IndexOut] := H_DLE;
  Inc(IndexOut);
  d[ofsTx+IndexOut] := Format;
  Inc(IndexOut);

  Case char(Format) of
    HCHR_HEXPKT :
      begin
        While (Len > 0) do
          begin
            If (d[ofsTxIn+IndexIn] and $80) <> 0 then
              begin
                d[ofsTx+IndexOut] := byte('\');
                Inc(IndexOut);
                d[ofsTx+IndexOut] := Ord(rrLoHexChar[(d[ofsTxIn+IndexIn] shr 4) and $0f]);
                Inc(IndexOut);
                d[ofsTx+IndexOut] := Ord(rrLoHexChar[d[ofsTxIn+IndexIn] and $0f]);
                Inc(IndexOut);
              end
            else If (d[ofsTxIn+IndexIn] < 32) or (d[ofsTxIn+IndexIn] = 127) then
              begin
                d[ofsTx+IndexOut] := H_DLE;
                Inc(IndexOut);
                d[ofsTx+IndexOut] := d[ofsTxIn+IndexIn] xor $40;
                Inc(IndexOut);
              end
            else If d[ofsTxIn+IndexIn] = byte('\') then
              begin
                d[ofsTx+IndexOut] := byte('\');
                Inc(IndexOut);
                d[ofsTx+IndexOut] := byte('\');
                Inc(IndexOut);
              end
            else
              begin
                d[ofsTx+IndexOut] := d[ofsTxIn+IndexIn];
                Inc(IndexOut);
              end;

            Inc(IndexIn);
            Dec(Len);
          end;
      end;

    HCHR_BINPKT:
      begin
        While (Len > 0) do
          begin
            Put_BinByte(IndexOut,d[ofsTxIn+IndexIn]);
            Inc(IndexIn);
            Dec(Len);
          end;
      end;

    HCHR_ASCPKT:
      begin
        N := 0;
        C := 0;
        While (Len > 0) do
          begin
            C := C or (d[ofsTxIn+IndexIn] shl N);
            Put_BinByte(IndexOut,(byte(C) and $7f));
            C := C shr 7;
            Inc(N);
            If (N >= 7) then
              begin
                Put_BinByte(IndexOut,(byte(C) and $7f));
                N := 0;
                C := 0;
              end;

            Inc(IndexIn);
            Dec(Len);
          end;
        If (N > 0) then
          Put_BinByte(IndexOut,(byte(C) and $7f));
      end;

    HCHR_UUEPKT:
      begin
        While (Len >= 3) do
          begin
            d[ofsTx+IndexOut]     := h_UUEnc(d[ofsTxIn+IndexIn] shr 2);
            d[ofsTx+IndexOut + 1] := h_UUEnc( ((d[ofsTxIn+IndexIn] shl 4) and $30) or
                                             ((d[ofsTxIn+IndexIn + 1] shr 4) and $0f) );
            d[ofsTx+IndexOut + 2] := h_UUEnc( ((d[ofsTxIn+IndexIn + 1] shl 2) and $3c) or
                                             ((d[ofsTxIn+IndexIn + 2] shr 6) and $03) );
            d[ofsTx+IndexOut + 3] := h_UUEnc(d[ofsTxIn+IndexIn + 2] and $3f);

            Inc(IndexOut,4);
            Inc(IndexIn,3);
            Dec(Len,3);
          end;

        If (Len > 0) then
          begin
            d[ofsTx+IndexOut]     := h_UUEnc(d[ofsTxIn+IndexIn] shr 2);
            d[ofsTx+IndexOut + 1] := h_UUEnc(((d[ofsTxIn+IndexIn] shl 4) and $30) or ((d[ofsTxIn+IndexIn + 1] shr 4) and $0f));
            Inc(IndexOut,2);
            If (Len = 2) then
              begin
                d[ofsTx+IndexOut] := h_UUEnc((d[ofsTxIn+IndexIn + 1] shl 2) and $3c);
                Inc(IndexOut);
              end;
          end;
      end;
  end;

  d[ofsTx+IndexOut]     := H_DLE;
  d[ofsTx+IndexOut + 1] := byte(HCHR_PKTEND);
  Inc(IndexOut,2);

  If (PktType <> HPKT_DATA) and (Format <> byte(HCHR_BINPKT)) then
    begin
      d[ofsTx+IndexOut]     := 13; (*CR*)
      d[ofsTx+IndexOut + 1] := 10; (*LF*)
      Inc(IndexOut,2);
    end;

  If Length(TxPktPrefix) > 0 then
    For N := 1 to Length(TxPktPrefix) do
      begin
        Case Ord(TxPktPrefix[N]) of
          $DD : begin Sleep(1000) end;  // Transmit break signal for one second
          $DE : begin Sleep(1000) end;
          $DF : begin CP.Write(z,1) end;
        else
          CP.Write(TxPktPrefix[N],1);
        end;
      end;

  if PktType = HPKT_DATA then CP.Write(d[ofsTx],IndexOut) else
  begin
    N := ofsTx+IndexOut;
    if N > 0 then
    begin
      for C := ofsTx to N-1 do CP.PutChar(d[C]);
    end;
  end;
end; (*TxPkt*)


(*---------------------------------------------------------------------------*)
function THydra.RxPkt : integer;
var
  C: Byte;
  N,
  I,
  Count,
  Index : integer;
  OK,
  Done  : boolean;

{$IFDEF HYDRA_DEBUG}
procedure Dbg;
begin
  DbgLogFmt('><- PKT (format="%s" type="%s"  len=%d)',
   [char(rxpktformat), Char(d[ofsRx+rxpktlen]), rxpktlen]);

  case Char(d[ofsRx+rxpktlen]) of
    HPKT_START:    DbgLog(    '<   START');
    HPKT_INIT:     DbgLog(    '<   INIT');
    HPKT_INITACK:  DbgLog(    '<   INITACK');
    HPKT_FINFO:    DbgLogFmt( '<   FINFO (rxstate=%d)', [Integer(RxState)]);
    HPKT_FINFOACK: DbgLogFmt( '<   FINFOACK (pos=%d  txstate=%d)', [h_GetLong(1), Integer(TxState)]);
    HPKT_DATA:     DbgLogFmt( '<   DATA (rxstate=%d  pos=%d  len=%d)', [Integer(RxState), h_GetLong(1), Integer(rxpktlen - Sizeof (Integer))]);
    HPKT_DATAACK:  DbgLogFmt( '<   DATAACK (rxstate=%d  pos=%ld)', [Integer(RxState), h_GetLong(1)]);
    HPKT_RPOS:     DbgLogFmt( '<   RPOS (pos=%d  blklen=%d->%d  syncid=%d  txstate=%d)', [h_GetLong(1), T.D.BlkLen, h_GetLong(2), h_GetLong(3), Integer(TxState)]);
    HPKT_EOF:      DbgLogFmt( '<   EOF (rxstate=%d  pos=%d)', [Integer(RxState), h_GetLong(1)]);
    HPKT_EOFACK:   DbgLogFmt( '<   EOFACK (txstate=%d)', [Integer(TxState)]);
    HPKT_IDLE:     DbgLog(    '<   IDLE');
    HPKT_END:      DbgLog(    '<   END');
else
                   DbgLogFmt( '<   Unkown pkttype %s (txstate=%d  rxstate=%d)', [Char(d[ofsRx+rxpktlen]), Integer(txstate), Integer(rxstate)]);
  end;
end;
{$ENDIF}

begin

  Index := 0;

  If CancelRequested then
    begin
      Result := H_SYSABORT;
      Exit;
    end;

  {If not CP.CharReady then}
    if CP.DCD <> CP.Carrier then
    begin
      CP.Carrier := not CP.Carrier;
      Result := H_CARRIER;
      Exit;
    end;

  If (TimerInstalled(BrainDead)) and (TimerExpired(BrainDead)) then
    begin
      {$IFDEF HYDRA_DEBUG}
      if Debug then DbgLog('<- BrainDead');
      {$ENDIF}
      ClearTimer(BrainDead);
      Result := H_BRAINTIME;
      Exit;
    end;

  If (TimerInstalled(TxTimer)) and (TimerExpired(TxTimer)) then
    begin
      {$IFDEF HYDRA_DEBUG}
      if Debug then DbgLog(' <- TxTimer');
      {$ENDIF}
      ClearTimer(TxTimer);
      Result := H_TXTIME;
      Exit;
    end;


  while CP.GetChar(C) do
  begin


    If (HOPT_HIGHBIT in RxOptions) then C := C and $7f;

    N := C;
    If (HOPT_HIGHCTL in RxOptions) then N := N and $7f;

    If ((N <> H_DLE) and
      (((HOPT_XONXOFF in RxOptions) and ((N = cXon) or (N = cXoff)))  or
       ((HOPT_CTLCHRS in RxOptions) and ((N < 32) or (N = 127))) ))
       then Continue;

    if (RxDLE > 0) or (C = H_DLE) then
    begin
      case char(C) of
        char(H_DLE) :
          begin
            Inc(RxDLE);
            if RxDLE >= 5 then
            begin
              Result := H_CANCEL;
              Exit;
            end;
          end;

        HCHR_PKTEND :
          begin
            if RxBufPtr <= 0 then c := H_NOPKT else

            case char(RxPktFormat) of
              HCHR_BINPKT :
                begin
                  Index := RxBufPtr;
                end;

              HCHR_HEXPKT :
                begin
                  Count := 0;
                  Index := 0;
                  Done  := false;
                  while (Count < RxBufPtr) and (not Done) do
                  begin
                    if (d[ofsRx+Count] = byte('\')) then
                    begin
                      Inc(Count);
                      If (d[ofsRx+Count] <> byte('\')) then
                      begin
                        I := d[ofsRx+Count];
                        N := d[ofsRx+Count + 1];
                        Inc(Count);
                        Dec(I,48);
                        If (I > 9) then Dec(I,39);
                        Dec(N,48);
                        If (N > 9) then Dec(N,39);
                        If (I and $FFF0 <> 0) or (N and $FFF0 <> 0) then
                          begin
                            C := H_NOPKT;
                            Done := true;
                          end;
                        d[ofsRx+Index] := (I shl 4) or N;
                        Inc(Index);
                      end else
                      begin
                        d[ofsRx+Index] := d[ofsRx+Count];
                        Inc(Index);
                      end;
                    end else
                    begin
                      d[ofsRx+Index] := d[ofsRx+Count];
                      Inc(Index);
                    end;
                    Inc(Count);
                  end {while};
                  If Count > RxBufPtr then C := H_NOPKT;
                end;

              HCHR_ASCPKT :
                begin
                  N := 0;
                  I := 0;
                  Count := 0;
                  Index := 0;
                  while Count < RxBufPtr do
                  begin
                    I := I or ((d[ofsRx+Count] and $7f) shl N);
                    Inc(N,7);
                    If N >= 8 then
                    begin
                      d[ofsRx+Index] := byte(I) and $FF;
                      Inc(Index);
                      I := I shr 8;
                      Dec(N,8);
                    end;
                    Inc(Count);
                  end {while};
                end;

              HCHR_UUEPKT :
                begin
                  N     := RxBufPtr;
                  Count := 0;
                  Index := 0;
                  Done  := false;
                  while (N >= 4) and (not Done) do
                  begin
                    If ((d[ofsRx+Count]     <= byte(' ')) or (d[ofsRx+Count]     >= byte('a'))  or
                        (d[ofsRx+Count + 1] <= byte(' ')) or (d[ofsRx+Count + 1] >= byte('a'))  or
                        (d[ofsRx+Count + 2] <= byte(' ')) or (d[ofsRx+Count + 2] >= byte('a'))  or
                        (d[ofsRx+Count + 3] <= byte(' ')) or (d[ofsRx+Count + 3] >= byte('a'))) then
                    begin
                      C := H_NOPKT;
                      Done := true;
                    end else
                    begin
                      d[ofsRx+Index]     := (h_uudec(d[ofsRx+Count]) shl 2) or (h_uudec(d[ofsRx+Count + 1]) shr 4);
                      d[ofsRx+Index + 1] := (h_uudec(d[ofsRx+Count + 1]) shl 4) or (h_uudec(d[ofsRx+Count + 2]) shr 2);
                      d[ofsRx+Index + 2] := (h_uudec(d[ofsRx+Count + 2]) shl 6) or h_uudec(d[ofsRx+Count + 3]);

                      Inc(Count,4);
                      Inc(Index,3);
                      Dec(N,4);
                    end;
                  end {while};

                  if (n >= 2) and (not Done) then
                  begin
                    if (d[ofsRx+Count]     <= byte(' ')) or (d[ofsRx+Count]     >= byte('a')) or
                       (d[ofsRx+Count + 1] <= byte(' ')) or (d[ofsRx+Count + 1] >= byte('a')) then
                    begin
                      C := H_NOPKT
                    end else
                    begin
                      d[ofsRx+Index] := (h_uudec(d[ofsRx+Count]) shl 2) or (h_uudec(d[ofsRx+Count + 1]) shr 4);
                      Inc(Index);
                      if (N = 3) then
                      begin
                        if (d[ofsRx+Count + 2] <= byte(' ')) or (d[ofsRx+Count + 2] >= byte('a')) then
                        begin
                          C := H_NOPKT
                        end else
                        begin
                          d[ofsRx+Index] := (h_uudec(d[ofsRx+Count + 1]) shl 4) or
                                            (h_uudec(d[ofsRx+Count + 2]) shr 2);
                          Inc(Index);
                        end;
                      end;
                    end;
                  end {if (n >= 2) and (not Done)};
                end;

            else (*CASE - This'd mean an internal fluke *)
              begin
                {$IFDEF HYDRA_DEBUG}
                if Debug then DbgLogFmt(' <- <PKTEND> (pktformat="%s" dec=%d)', [char(rxpktformat), rxpktformat]);
                {$ENDIF}
                IncTotalErrors;
                C := H_NOPKT;
              end;
            end; (*CASE RxPktFormat*)

            RxBufPtr := -1;

            if (c = H_NOPKT) then Continue;

            RxPktLen := Index;

            OK := False;

            if (RxPktFormat <> byte(HCHR_HEXPKT)) and (HOPT_CRC32 in RxOptions) then
            begin
              if (RxPktLen < 5) then
              begin
                C := H_NOPKT;
                Continue;
              end;
              if h_Crc32Test(Crc32Block(d[ofsRx],RxPktLen, CRC32_INIT)) then OK := True;
              Dec(RxPktLen, SizeOf(Integer)); (*Remove CRC-32*)
            end else
            begin
              if (RxPktLen < 3) then
              begin
                C := H_NOPKT;
                Continue;
              end;
              if h_Crc16Test(Crc16PropBlock(d[ofsRx], RxPktLen)) then OK := True;
              Dec(RxPktLen, SizeOf(word));  (*Remove CRC-16*)
            end;

            Dec(RxPktLen); (*Remove Pkt type*)

            {$IFDEF HYDRA_DEBUG}
            if Debug then Dbg;
            {$ENDIF}

            if OK then
            begin
              Result := integer(d[ofsRx+RxPktLen]);
              Exit;
            end; (*Good Pkt*)
            {$IFDEF HYDRA_DEBUG}
            if Debug then DbgLogFmt('>Bad CRC (format="%s"  type="%s"  len=%d)', [Char(RxPktFormat), Char(d[ofsRx+rxPktLen]), Integer(RxPktLen)]);
            {$ENDIF}
            IncTotalErrors;
            FLogFile(Self, lfBadCRC);
          end; (*HCHR_PKTEND*)

        HCHR_BINPKT,
        HCHR_HEXPKT,
        HCHR_ASCPKT,
        HCHR_UUEPKT :
          begin
            {$IFDEF HYDRA_DEBUG}
            if Debug then DbgLogFmt(' <- <PKTSTART> (pktformat="%s")', [Char(c)]);
            {$ENDIF}
            RxPktFormat := C;
            RxBufPtr    := 0;
            RxDLE       := 0;
          end;
      else
        begin
          if RxBufPtr >= 0 then
          begin
            if RxBufPtr < RxBufMax then
            begin
              d[ofsRx+RxBufPtr] := byte(C) xor $40;
              Inc(RxBufPtr);
            end else
            begin
              IncTotalErrors;
              {$IFDEF HYDRA_DEBUG}
              if Debug then DbgLog(' <- Pkt too long - discarded');
              {$ENDIF}
              RxBufPtr := -1;
            end;
          end {RxBufPtr >= 0};
          RxDLE := 0;
        end;
      end; (*CASE C*)
    end { if (RxDLE > 0) or (C = H_DLE) }
  else
  begin
    If RxBufPtr >= 0 then
      begin
        if (RxBufPtr < RxBufMax) then
        begin
          d[ofsRx+RxBufPtr] := byte(C);
          Inc(RxBufPtr);
        end
        else begin
          IncTotalErrors;
          {$IFDEF HYDRA_DEBUG}
          if Debug then DbgLog(' <- Pkt too long - discarded');
          {$ENDIF}
          RxBufPtr := -1;
        end;
      end;
    end {else (RxDLE > 0) or (C = H_DLE)};
  end {while};

  Result := H_NOPKT;
end; (*RxPkt*)

constructor THydra.Create;
begin
  inherited Create(ACP);
  FWantOptions := AWantOptions;
  TxWindow    := 0;
  RxWindow    := 0;
  Originator  := true;                        (*Are we the orig side?*)
  HdxSession  := false;
  ShowInfo    := True;
  {$IFDEF HYDRA_DEBUG}
  Debug := True;
  {$ENDIF}
end;

procedure THydra.Init_Tx;
begin
  StartBrainDeadTimer;
  TxState     := HTX_START;
  TxOptions   := HTXI_OPTIONS;
  TxPktPrefix := '';
  ClearTimer(TxTimer);
end;

procedure THydra.Init_Rx;
begin
  RxState   := HRX_INIT;
  RxOptions := HRXI_OPTIONS;
  RxDLE     := 0;
  RxBufPtr  := -1;
  ClearTimer(RxTimer);
end;

(*---------------------------------------------------------------------------*)
procedure THydra.Start;

begin
  inherited Start(AAcceptFile, AFinishRece, AGetNextFile, AFinishSend);

  RxBufMax := H_MAXPKTLEN;

  BatchesDone := 0;

  If Originator then HdxLink := false else
    If HdxSession then HdxLink := true;

  Options := (FWantOptions * HCAN_OPTIONS) - HUNN_OPTIONS;

  CalcBlockSize(TxMaxBlkLen, T.D.BlkLen, H_MAXBLKLEN, H_MINBLKLEN);
  CalcTimeout(Timeout, H_MAXTIMER, H_MINTIMER);

  R.D.BlkLen := T.D.BlkLen;

  TxGoodBytes  := 0;
  TxGoodNeeded := TxMaxBlkLen * 2;

  TxState := HTX_DONE;

  ChatTimer := -1;

  Init_Tx;

  Init_Rx;


end; (*Hydra_Init*)


procedure THydra.AddToBuf(const S: string; var Count: DWORD; B: Byte);
var
  Len: Integer;
begin
  Len := Length(S);
  if Len > 0 then Move(S[1], d[ofsTxIn+Count], Len);
  Inc(Count, Len);
  d[ofsTxIn+Count] := B;
  Inc(Count);
end;

procedure THydra.Do_Tx;
const
  AutoStr = 'hydra'#13;
var
  Actually, Count : DWORD;
  Counter: Integer;
begin
  (*-----------------------------------------------------------------------*)
  Case (TxState) of
    HTX_START :
      begin
        CP.SendString(AutoStr);
        TxPkt(0,HPKT_START);
        NewTimerSecs(TxTimer, H_START);
        TxState := HTX_SWAIT;
      end;

    (*---------------------------------------------------------------------*)
    HTX_INIT :
      begin
        Count := 0;
        h_PutHex(Count,H_REVSTAMP);
        Inc(Count,8);
        AddToBuf(ProductName, Count, 44);
        AddToBuf(ProductVersion, Count, 44);
        AddToBuf(CustomInfo, Count, 0);

        Inc(Count,Put_Flags(d[ofsTxIn+Count],HCAN_OPTIONS));    (*What we CAN do*)
        Inc(Count,Put_Flags(d[ofsTxIn+Count],Options));    (*What we WANT*)

        h_PutHex(Count,HydraTxWindow);
        Inc(Count,8);
        h_PutHex(Count,HydraRxWindow);
        Inc(Count,8);
        d[ofsTxIn+Count] := 0;
        Inc(Count);

        Counter := Length(PktPrefix);
        if Counter > 0 then Move(PktPrefix[1], d[ofsTxIn+Count], Counter);
        Inc(Count,Counter);

        d[ofsTxIn+Count] := 0;
        Inc(Count);

        TxOptions := HTXI_OPTIONS;
        TxPkt(Count, HPKT_INIT);
        TxOptions := RxOptions;
        NewTimerSecs(TxTimer, TimeOut shr 1);
        TxState   := HTX_INITACK;
      end;

    (*---------------------------------------------------------------------*)
    HTX_NEXTFILE:
      begin
        T.ClearFileInfo;
        ClearTimer(TxTimer);
        TxRetries := 0;

        (*-------------------------------------------------------------------------*)
        FGetNextFile(Self);
        if T.D.FName <> '' then
          begin
            TxSyncID := 0;
          end;
        TxState := HTX_FINFO;
      end;
  (*-------------------------------------------------------------------------*)
    HTX_FINFO :
      begin
        If not TxClosed then
          begin

            h_PutHex( 0,T.D.FTime);
            h_PutHex( 8,T.D.FSize);
            h_PutHex(16,0);
            h_PutHex(24,0);
            h_PutHex(32,0);
            Count := 5 * 8;

            AddToBuf(ExtractFileName(T.D.FName), Count, 0);
          end
        else
          begin
            If (TxRetries = 0) then FLogFile(Self, lfBatchSendEnd);
            d[ofsTxIn+0] := 0;
            Count := 1;
          end;

        TxPkt(Count,HPKT_FINFO);
        If TxRetries <> 0 then
          NewTimerSecs(TxTimer, TimeOut div 2)
        else
          NewTimerSecs(TxTimer, TimeOut);
        TxState := HTX_FINFOACK;
      end; (*HTX_FINFO*)

    (*---------------------------------------------------------------------*)
    HTX_XDATA :
      begin
        If (CP.OutUsed <= T.D.BlkLen) then
          begin
            If (T.D.ErrPos < 0) then Counter := -1 (*Skip*) else
            if T.D.FPos >= T.D.FSize then Counter := 0 else
            begin
              h_PutLong(1, T.D.FPos);
              Count := SizeOf(Integer);
              Actually := T.Stream.Read(d[ofsTxIn+Count], T.D.BlkLen);
              if Actually = 0 then
              begin
                FFinishSend(Self, aaSysError);
                Counter := -1;
                IncTotalErrors;
                T.D.ErrPos := -2; (*Skip*)
              end else
              begin
                Counter := Actually;
                Inc(Count, Actually);
                Inc(T.D.FPos, Actually);
              end;
            end;

            If (Counter > 0) then
              begin

                TxPkt(Count,HPKT_DATA);

                If (T.D.BlkLen < TxMaxBlkLen) then
                  begin
                    Inc(TxGoodBytes,Counter);
                    If (TxGoodBytes >= TxGoodNeeded) then
                      begin
                        T.D.BlkLen := T.D.BlkLen shl 1;
                        If (T.D.BlkLen >= TxMaxBlkLen) then
                          begin
                            T.D.BlkLen := TxMaxBlkLen;
                            TxGoodNeeded := 0;
                          end;
                        TxGoodBytes := 0;
                      end;
                  end;

                If (TxWindow > 0) and (T.D.FPos >= (TxLastAck + DWORD(TxWindow))) then
                  begin
                    If TxRetries <> 0 then
                      NewTimerSecs(TxTimer, TimeOut div 2)
                    else
                      NewTimerSecs(TxTimer, TimeOut);
                    TxState := HTX_DATAACK;
                  end;
              end
            else
             begin
               TxState := HTX_EOF; (*Fallthrough to HTX_EOF*)
             end;
          end;
      end; (*HTX_XDATA*)

    (*---------------------------------------------------------------------*)
    HTX_EOF :
      begin
        if T.D.ErrPos < 0 then h_PutLongI(1, T.D.ErrPos) else h_PutLong(1, T.D.FPos);
        TxPkt(SizeOf(Integer),HPKT_EOF);
        If TxRetries <> 0 then
          NewTimerSecs(TxTimer, TimeOut div 2)
        else
          NewTimerSecs(TxTimer, TimeOut);
        TxState := HTX_EOFACK;
      end;

    (*---------------------------------------------------------------------*)
    HTX_END :
      begin
        TxPkt(0,HPKT_END);
        TxPkt(0,HPKT_END);
        NewTimerSecs(TxTimer, TimeOut div 2);
        TxState := HTX_ENDACK;
      end;

    HTX_DRAIN :
      begin
        if CP.OutUsed = 0 then
        begin
          FLogFile(Self, lfBatchesDone);
          TxState := HTX_DONE; ///111
        end {else Sleep(100)};
      end;

  end; (*CASE TxState*)
end;

procedure THydra.Do_Rx;

function Skip: Boolean;
begin
  Result := FileRefuse or FileSkip;
  if not Result then Exit;
  if FileSkip then
  begin
    FFinishRece(Self, aaAcceptLater);
    R.D.ErrPos := -2;
  end else
  if FileRefuse then
  begin
    FFinishRece(Self, aaRefuse);
    R.D.ErrPos := -1;
  end;

  Inc(RxSyncID);
  h_PutLongI(1,R.D.ErrPos);
  h_PutLong(2,R.D.BlkLen);
  h_PutLong(3,RxSyncID);
  TxPkt(3 * SizeOf(Integer),HPKT_RPOS);

  RxState   := HRX_FINFO;
  StartBrainDeadTimer;

end;


var
  PktType: Integer;
//  St : string;
  A, Count, Counter, Index: Integer;

begin
  (*-----------------------------------------------------------------------*)
  PktType := RxPkt;

  (*-----------------------------------------------------------------------*)
  Case PktType of
    (*---------------------------------------------------------------------*)
    H_CARRIER,
    H_CANCEL,
    H_SYSABORT,
    H_BRAINTIME :
      begin
        Case PktType of
          H_CARRIER   : case TxState of
                          HTX_END,
                          HTX_ENDACK,
                          HTX_DRAIN :;
                          else ProtocolError := ecAbortNoCarrier;
                        end;
          H_CANCEL    : ProtocolError := ecAbortByRemote;
          H_SYSABORT  : ProtocolError := ecAbortByLocal;
          H_BRAINTIME : ProtocolError := ecTimeout;
        end;
        TxState := HTX_DONE;
      end; (*H_BRAINTIME*)

    (*---------------------------------------------------------------------*)
    H_TXTIME :
      begin
        If (TxState = HTX_XWAIT) or (TxState = HTX_REND) then
          begin
            TxPkt(0,HPKT_IDLE);
            NewTimerSecs(TxTimer, H_IDLE);
          end
        else
          begin
            IncTotalErrors;
            Inc(TxRetries);
            If (TxRetries > H_RETRIES) then
              begin
                ProtocolError := ecTooManyErrors;
                TxState := HTX_DONE;
                Exit;
              end;

            {$IFDEF HYDRA_DEBUG}
            if Debug then DbgLogFmt('-HSEND: Timeout - Retry %d', [txretries]);
            {$ENDIF}
            ClearTimer(TxTimer);
            FLogFile(Self, lfTimeout);

            Case (TxState) of
              HTX_SWAIT    : TxState := HTX_START;
              HTX_INITACK  : TxState := HTX_INIT;
              HTX_FINFOACK : TxState := HTX_FINFO;
              HTX_DATAACK  : TxState := HTX_XDATA;
              HTX_EOFACK   : TxState := HTX_EOF;
              HTX_ENDACK   : TxState := HTX_END;
              HTX_DRAIN    : TxState := HTX_DONE;
            end;
          end;
      end; (*H_TXTIME*)

    (*---------------------------------------------------------------------*)
    integer(HPKT_START) :
      begin
        If (TxState = HTX_START) or (TxState = HTX_SWAIT) then
          begin
            ClearTimer(TxTimer);
            TxRetries := 0;
            TxState   := HTX_INIT;
            StartBrainDeadTimer;
          end;
      end; (*HPKT_START*)

    (*---------------------------------------------------------------------*)
    integer(HPKT_INIT) :
      begin
        If (RxState = HRX_INIT) then
          begin
            Count := NulSearch(d[ofsRx]) + 1;
            Index := Count + NulSearch(d[ofsRx+Count]) + 1;
            RxOptions := Options + HUNN_OPTIONS;
            RemoteOptions := Get_Flags(d[ofsRx+Index]);
            RxOptions := RxOptions + RemoteOptions;
            RxOptions := RxOptions * Get_Flags(d[ofsRx+Count]);
            RxOptions := RxOptions * HCAN_OPTIONS;
            If (RxOptions + (Options * HNEC_OPTIONS)) <> (RxOptions) then
              begin
                ProtocolError := ecIncompatibleLink;
                TxState := HTX_DONE;
                Exit;
              end;

            Count := Index + NulSearch(d[ofsRx+Index]) + 1;
            If NulSearch(d[ofsRx+Count]) < 16 then
              begin
                TxWindow := 0;
                RxWindow := 0;
              end
            else
              begin
                TxWindow := h_GetHex(Count + 8);
                RxWindow := h_GetHex(Count);
              end;

            If (RxWindow < 0) then RxWindow := 0;
            If (HydraRxWindow <> 0) and ((RxWindow = 0) or (HydraRxWindow < RxWindow)) then
              RxWindow := HydraRxWindow;
            If (TxWindow < 0) then TxWindow := 0;
            If (HydraTxWindow <> 0) and ((TxWindow = 0) or (HydraTxWindow < TxWindow)) then
               TxWindow := HydraTxWindow;


            Index := Count + NulSearch(d[ofsRx+Count]) + 1;
            Count := NulSearch(d[ofsRx+Index]);
            If Count > H_PKTPREFIX then Count := H_PKTPREFIX;
            if Count = 0 then TxPktPrefix := '' else
            begin
              SetLength(TxPktPrefix, Count);
              Move(d[ofsRx+Index], TxPktPrefix[1], Count);
            end;

            If (BatchesDone = 0) then
              begin
                if ShowInfo then
                begin
                  Count := NulSearch(d[ofsRx+8]);
                  if Count = 0 then CustomInfo := '' else
                  begin
                    SetLength(CustomInfo, Count);
                    Move(d[ofsRx+8], CustomInfo[1], Count);
                  end;
                  CustomInfo := 'Other''s AppInfo="'+CustomInfo+'"';
                  FLogFile(Self, lfHydraNfo);
                  CustomInfo := 'Other''s HydraRev='+uFormatDateTime('dd-mmm-yyyy', h_GetHex(0))+
                  ', flags: '+FlagsStr(RxOptions);
                  if RemoteOptions-RxOptions <> [] then CustomInfo := CustomInfo+' ('+FlagsStr(RemoteOptions-RxOptions)+')';
                  FLogFile(Self, lfHydraNfo);
                  if (TxWindow>0) or (RxWindow>0) then
                  begin
                    CustomInfo := Format('Window tx=%d, rx=%d',[TxWindow, RxWindow]);
                    FLogFile(Self, lfHydraNfo);
                  end;
                  ShowInfo := False;
                end;
              end;

              ChatTimer := -2;

            TxOptions := RxOptions;
            RxState   := HRX_FINFO;
          end;

        TxPkt(0,HPKT_INITACK);
      end; (*HPKT_INIT*)

    (*---------------------------------------------------------------------*)
    integer(HPKT_INITACK) :
      begin
        If (TxState = HTX_INIT) or (TxState = HTX_INITACK) then
          begin
            StartBrainDeadTimer;
            ClearTimer(TxTimer);
            TxRetries := 0;
            TxState   := HTX_RINIT;
          end;
      end; (*HPKT_INITACK*)

    (*---------------------------------------------------------------------*)
    integer(HPKT_FINFO) :
      begin
        If (RxState = HRX_FINFO) then
          begin
            StartBrainDeadTimer;
            If (d[ofsRx+0] = 0) then
              begin
                FLogFile(Self, lfBatchReceEnd);
                R.D.FPos := 0;
                R.D.FOfs := 0;
                R.D.ErrPos := 0;
                RxState := HRX_DONE;
                Inc(BatchesDone);
              end
            else
              begin
                R.ClearFileInfo;
                R.D.FTime := h_GetHex(0); R.D.FSize := h_GetHex(8); Index := 5 * 8;
                Count   := NulSearch(d[ofsRx+Index]);
                if Count = 0 then R.D.FName := '' else
                begin
                  SetLength(R.D.FName, Count);
                  Move(d[ofsRx+Index], R.D.FName[1], Count);
                end;

                case FAcceptFile(Self) of
                  aaOK :
                    begin
                      ClearTimer(RxTimer);
                      RxRetries  := 0;
                      RxLastSync := 0;
                      RxSyncID   := 0;
                      RxState := HRX_DATA;
                    end;
                  aaRefuse : R.D.ErrPos := -1;
                  aaAcceptLater : R.D.ErrPos := -2;
                  aaAbort:
                    begin
                      ProtocolError := ecIncompatibleLink;
                      TxState := HTX_DONE;
                      Exit;
                    end;
                end;
              end;
          end
        else If (RxState = HRX_DONE) then
          begin
            If d[ofsRx+0] = 0 then
            begin
              R.D.ErrPos := 0;
              R.D.FPos := 0;
            end else
            begin
              R.D.ErrPos := -2;
            end;
          end;

        if R.D.ErrPos < 0 then h_PutLongI(1,R.D.ErrPos) else h_PutLong(1,R.D.FPos);
        TxPkt(SizeOf(Integer),HPKT_FINFOACK);
      end; (*HPKT_FINFO*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_FINFOACK) :
        begin
          If (TxState = HTX_FINFO) or (TxState = HTX_FINFOACK) then
            begin
              StartBrainDeadTimer;
              TxRetries := 0;
              If T.D.FName = '' then
                begin
                  NewTimerSecs(TxTimer, H_IDLE);
                  TxState := HTX_REND;
                end
              else
                begin
                  ClearTimer(TxTimer);
                  T.D.ErrPos := h_GetLongI(1);
                  If (T.D.ErrPos >= 0) then
                    begin
                      T.D.FPos := T.D.ErrPos;
                      T.D.FOfs  := T.D.FPos;
                      TxLastAck := T.D.FPos;
                      If (T.D.FPos > 0) then
                        begin
                          FLogFile(Self, lfSendSync);
                          SetLastError(0);
                          T.Stream.Position := T.D.FPos;
                          if GetLastError <> 0 then
                          begin
                            FFinishSend(Self, aaSysError);
                            T.D.ErrPos   := -2;
                            TxState := HTX_EOF;
                          end;
                        end;
                      TxState := HTX_XDATA;
                    end
                  else
                    begin
                      case T.D.ErrPos of
                        -1 : begin FFinishSend(Self, aaRefuse); TxState := HTX_NEXTFILE end;
                        -2 : begin FFinishSend(Self, aaAcceptLater); TxState := HTX_NEXTFILE end;
                        else
                          begin
                            CustomInfo := Format('Unknown FPos (%d', [T.D.ErrPos]);
                            FLogFile(Self, lfHydraNfo);
                            ProtocolError := ecTooManyErrors;
                            TxState := HTX_DONE;
                          end;
                      end;

                    end;
              end;
            end;
        end; (*HPKT_FINFOACK*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_DATA) :
        if not Skip then
        begin
          If (RxState = HRX_DATA) then
            begin
              If (h_GetLong(1) <> R.D.FPos) or (h_GetLongI(1) < 0) then
                begin
                  If (h_GetLong(1) <= RxLastSync) then
                    begin
                      ClearTimer(RxTimer);
                      RxRetries := 0;
                    end;
                  RxLastSync := h_GetLong(1);

                  If (not TimerInstalled(RxTimer)) or (TimerExpired(RxTimer)) then
                    begin
                      ClearTimer(RxTimer);
                      If (RxRetries > 4) then
                        begin
                          If (TxState < HTX_REND) and (not Originator) and (not HdxLink) then
                            begin
                              HdxLink   := true;
                              RxRetries := 0;
                            end;
                         end;
                      IncTotalErrors;
                      Inc(RxRetries);
                      If (RxRetries > H_RETRIES) then
                        begin
                          ProtocolError := ecTooManyErrors;
                          TxState := HTX_DONE;
                          Exit;
                        end;
                      If (RxRetries = 1) or (RxRetries = 4) then
                        Inc(RxSyncID);

                      Counter  := R.D.BlkLen shr 1;

                      A := H_MINBLKLEN;
                      while Counter > A do Inc(A, A);
                      Counter := A;
                      R.D.BlkLen := A;

                      FLogFile(Self, lfBadPkt);
                      h_PutLong(1,R.D.FPos);
                      h_PutLong(2,Integer(Counter));
                      h_PutLong(3,RxSyncID);
                      TxPkt(3 * SizeOf(Integer),HPKT_RPOS);
                      NewTimerSecs(RxTimer, TimeOut);
                    end;
                end
              else
                begin
                  StartBrainDeadTimer;
                  Dec(RxPktLen,SizeOf(Integer));
                  R.D.BlkLen := RxPktLen;
                  A := R.Stream.Write(d[ofsRx+SizeOf(Integer)], R.D.BlkLen);
                  if A <> Integer(R.D.BlkLen) then
                    begin
                      FFinishRece(Self, aaSysError);
                      R.D.ErrPos := -2;
                      RxRetries  := 1;
                      Inc(RxSyncID);
                      h_PutLongI(1,R.D.ErrPos);
                      h_PutLong(2,0);
                      h_PutLong(3,RxSyncID);
                      TxPkt(3 * SizeOf(Integer),HPKT_RPOS);
                      NewTimerSecs(RxTimer, TimeOut);
                      Exit;
                    end;

                  RxRetries  := 0;
                  ClearTimer(RxTimer);
                  RxLastSync := R.D.FPos;
                  Inc(R.D.FPos,RxPktLen);
                  If (RxWindow > 0) then
                    begin
                      h_PutLong(1,R.D.FPos);
                      TxPkt(SizeOf(Integer),HPKT_DATAACK);
                    end;
                end;
            end; (*RxState=HRX_DATA*)
        end; (*HPKT_DATA*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_DATAACK) :
        begin
          If (TxState = HTX_XDATA) or (TxState = HTX_DATAACK) or (TxState = HTX_XWAIT) or
             (TxState = HTX_EOF)   or (TxState = HTX_EOFACK) then
            begin
              If (TxWindow > 0) and (h_GetLong(1) > TxLastAck) then
                begin
                  TxLastAck := h_GetLong(1);
                  If (TxState = HTX_DATAACK) and (T.D.FPos < (TxLastAck + DWORD(TxWindow))) then
                    begin
                      TxState   := HTX_XDATA;
                      TxRetries := 0;
                      ClearTimer(TxTimer);
                    end;
                end;
            end;
        end; (*HPKT_DATAACK*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_RPOS) :
        begin
          If (TxState = HTX_XDATA) or (TxState = HTX_DATAACK) or (TxState = HTX_XWAIT) or
             (TxState = HTX_EOF)   or (TxState = HTX_EOFACK) then
            begin
              If (h_GetLong(3) <> TxSyncID) then
                begin
                  TxSyncID  := h_GetLong(3);
                  TxRetries := 1;
                end
              else
                begin
                  Inc(TxRetries);
                  If (TxRetries > H_RETRIES) then
                    begin
                      ProtocolError := ecTooManyErrors;
                      TxState := HTX_DONE;
                      Exit;
                    end;
                  If (TxRetries <> 4) then Exit;
                end;

              ClearTimer(TxTimer);

              A := h_GetLongI(1);
              if A > Integer(T.D.FPos) then T.D.FOfs := A;
              if A < 0 then T.D.ErrPos := A else begin T.D.FPos := A; T.D.ErrPos := 0 end;

              If (T.D.ErrPos < 0) then
                begin
                  case T.D.ErrPos of
                    -1, -2 : ;
                    else
                      begin
                        CustomInfo := Format('Unknown FPos (%d', [T.D.ErrPos]);
                        FLogFile(Self, lfHydraNfo);
                        ProtocolError := ecTooManyErrors;
                        TxState := HTX_DONE;
                        Exit;
                      end;
                  end;
                  If not TxClosed then
                    begin
                      if T.D.ErrPos = -1 then FFinishSend(Self, aaRefuse) else
                                         FFinishSend(Self, aaAcceptLater);
                      TxState := HTX_EOF;
                    end;
                  T.D.ErrPos := -2;
                  Exit;
                end;

              If (T.D.BlkLen > h_GetLong(2)) then
                T.D.BlkLen := h_GetLong(2)
              else
                T.D.BlkLen := T.D.BlkLen shr 1;

              A := H_MINBLKLEN;
              while Integer(T.D.BlkLen) > A do Inc(A, A);
              T.D.BlkLen := A;

              TxGoodBytes := 0;
              Inc(TxGoodNeeded, TxMaxBlkLen * 2);
              If (TxGoodNeeded > (TxMaxBlkLen * 8)) then
                TxGoodNeeded := (TxMaxBlkLen * 8);

              IncTotalErrors;
              FLogFile(Self, lfSendSeek);

              if T.Stream.Seek(T.D.FPos, FILE_BEGIN) = INVALID_FILE_SIZE then
                begin
                  FFinishSend(Self, aaSysError);
                  T.D.ErrPos   := -2;
                  TxState := HTX_EOF;
                  Exit;
                end;

              If (TxState <> HTX_XWAIT) then
                TxState := HTX_XDATA;
            end;
        end; (*HPKT_RPOS*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_EOF) :
        begin
          A := h_GetLongI(1); 
          If (RxState = HRX_DATA) then
            begin
              If (A < 0) then
                begin
                  case A of
                    -1, -2 :
                      begin
                        if A = -1 then FFinishRece(Self, aaRefuse) else
                                       FFinishRece(Self, aaAcceptLater);
                        RxState   := HRX_FINFO;
                        StartBrainDeadTimer;
                      end
                    else
                      begin
                        CustomInfo := Format('Unknown FPos (%d', [A]);
                        FLogFile(Self, lfHydraNfo);
                        ProtocolError := ecTooManyErrors;
                        TxState := HTX_DONE;
                      end;
                  end;
                end
              else If (A <> Integer(R.D.FPos)) then
                begin
                  If (A <= Integer(RxLastSync)) then
                    begin
                      ClearTimer(RxTimer);
                      RxRetries := 0;
                    end;
                  RxLastSync := A;

                  If (not TimerInstalled(RxTimer)) or (TimerExpired(RxTimer)) then
                    begin
                      ClearTimer(RxTimer);
                      Inc(RxRetries);
                      If (RxRetries > H_RETRIES) then
                        begin
                          ProtocolError := ecTooManyErrors;
                          TxState := HTX_DONE;
                          Exit;
                        end;
                      If (RxRetries = 1) or (RxRetries = 4) then
                        Inc(RxSyncID);

                      Counter  := R.D.BlkLen shr 1;

                      A := H_MINBLKLEN;
                      while Counter > A do Inc(A, A);
                      Counter := A;
                      R.D.BlkLen := A;

                      IncTotalErrors;
                      FLogFile(Self, lfBadEOF);
                      h_PutLong(1,R.D.FPos);
                      h_PutLong(2,Counter);
                      h_PutLong(3,RxSyncID);
                      TxPkt(3 * SizeOf(Integer),HPKT_RPOS);
                      NewTimerSecs(RxTimer, TimeOut);
                    end;
                end
              else
                begin
                  R.D.FSize := R.D.FPos;
                  FFinishRece(Self, aaOK);
                  RxState   := HRX_FINFO;
                  StartBrainDeadTimer;
                end;
            end; (*RxState=HRX_DATA*)

          If (RxState = HRX_FINFO) then
            TxPkt(0,HPKT_EOFACK);
        end; (*HPKT_EOF*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_EOFACK) :
        begin
          If (TxState = HTX_EOF) or (TxState = HTX_EOFACK) then
            begin
              StartBrainDeadTimer;
              If not TxClosed then
                begin
                  T.D.FSize := T.D.FPos;
                  FFinishSend(Self, aaOK);
                end;
              TxState := HTX_NEXTFILE;
            end;
        end; (*HPKT_EOFACK*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_IDLE) :
        begin
          If (TxState = HTX_XWAIT) then
            begin
              HdxLink   := false;
              ClearTimer(TxTimer);
              TxRetries := 0;
              TxState   := HTX_XDATA;
            end
          else If (TxState >= HTX_NEXTFILE) and (TxState < HTX_REND) then
            StartBrainDeadTimer;
        end; (*HPKT_IDLE*)

      (*-------------------------------------------------------------------*)
      integer(HPKT_END) :
        begin
          (* special for chat, other side wants to quit *)
          If (ChatTimer > 0 ) and (TxState = HTX_REND) then
            begin
              ChatTimer := -3;
              Exit;
            end;

          If (TxState = HTX_END) or (TxState = HTX_ENDACK) then
            begin
              TxPkt(0,HPKT_END);
              TxPkt(0,HPKT_END);
              TxPkt(0,HPKT_END);
              TxState := HTX_DRAIN;
            end;
        end; (*HPKT_END*)

  end; (*CASE PktType*)

end;

procedure THydra.Do_PostTx;
begin
  (*-----------------------------------------------------------------------*)
  Case (TxState) of
    HTX_START,
    HTX_SWAIT :
      begin
        If (RxState = HRX_FINFO) then
          begin
            ClearTimer(TxTimer);
            TxRetries := 0;
            TxState   := HTX_INIT;
          end;
      end;

    (*---------------------------------------------------------------------*)
    HTX_RINIT :
      begin
        If (RxState = HRX_FINFO) then
          begin
            ClearTimer(TxTimer);
            TxRetries := 0;
            TxState   := HTX_NEXTFILE;
          end;
      end;

    (*---------------------------------------------------------------------*)
    HTX_XDATA :
      begin
        If (RxState <> HRX_DONE) and (HdxLink) then
          begin
            NewTimerSecs(TxTimer, H_IDLE);
            TxState := HTX_XWAIT;
          end;
      end;

    (*---------------------------------------------------------------------*)
    HTX_XWAIT :
      begin
        If (RxState = HRX_DONE) then
          begin
            ClearTimer(TxTimer);
            TxRetries := 0;
            TxState   := HTX_XDATA;
          end;
      end;

    (*---------------------------------------------------------------------*)
    HTX_REND :
      begin
        If (RxState = HRX_DONE) {and (DevTxState = HTD_DONE)} then
          begin

            (*Special for chat, BrainDead will protect??????????*)
              If (ChatTimer <= 0) then
              begin
                If (ChatTimer = 0) Then ChatTimer := -3;
                ClearTimer(TxTimer);
                TxRetries := 0;
                TxState   := HTX_END;
              end;
          end;
      end;
  end; (*CASE TxState*)
end;

function THydra.NextStep: Boolean;
var
  InitTx: THydraTxState;
  InitRx: THydraRxState;
  ExitState: Boolean;
begin
  repeat
    InitTx := TxState;
    InitRx := RxState;
    Do_Tx;
    Do_Rx;
    Do_PostTx;
    ExitState := (InitTx = TxState) and (InitRx = RxState);
  until (ExitState) or (TxState = HTX_DONE);
  Result := TxState = HTX_DONE;
  if ProtocolError <> ecOK then
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
  case TxState of
    HTX_XDATA,
    HTX_DRAIN: OutFlow := True;
    else OutFlow := False;
  end;  
  if Result then Finish;
  if R <> nil then
  begin
    if RxState = HRX_DATA then R.D.Part := MaxI(0, RxBufPtr) else R.D.Part := 0;
  end;
end;

procedure THydra.ReportTraf(txMail, txFiles: DWORD);
begin
  GlobalFail('THydra.ReportTraf(%d,%d)', [txMail, txFiles]);
end;


procedure THydra.Cancel;
const
  AbortStr =  #24#24#24#24#24#24#24#24#24#8#8#8#8#8#8#8#8#8;
begin
  TDevicePort(CP).Purge([TX]);
  CP.SendString(AbortStr);
  Sleep(500);
  TDevicePort(CP).Purge([RX]);
end;

procedure THydra.StartBrainDeadTimer;
begin
  NewTimerSecs(BrainDead, H_BRAINDEAD);
end;

function THydra.TimeoutValue: DWORD;
begin
  TimeoutValue := MultiTimeout([BrainDead, TxTimer, RxTimer]);
end;

function THydra.GetStateStr: string;
begin
  Result := HydraTxStateName[TxState]+'/'+HydraRxStateName[RxState];
end;


function CreateHydraProtocol;
begin
  Result := THydra.Create(CP, AWantOptions);
end;

end.


