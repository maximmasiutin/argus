unit xDES;

interface uses Windows, SysUtils;

type
  TdesBlockB = array[0..7] of Byte;
  TdesBlock = Int64;
  PdesBlock = ^TdesBlock;
  PdesBlockI = ^TdesBlockI;
  TdesBlockI = array[0..1] of DWORD;
  TdesKeySchedule = array[0..127] of Byte;
  TMD5Byte64 = array[0..63] of Byte;
  TMD5Byte16 = array[0..15] of Byte;
  TMD5Int16  = array[0..15] of DWORD;
  TMD5Int4 = array[0..3] of DWORD;
  TMD5Int2 = array[0..1] of DWORD;
  TMD5Ctx = record
    State: TMD5Int4;
    Count: TMD5Int2;
    Buffer: TMD5Byte64;
    BLen: DWORD;
  end;


procedure xdes_ecb_encrypt_block(Buf: Pointer; Size: Integer; const Key: TdesBlock; Encrypt: Boolean);
procedure xdes_cbc_encrypt_block(Buf: Pointer; Size: Integer; const Key: TdesBlock; Encrypt: Boolean);
procedure xdes_ecb_encrypt(var Buf: TdesBlock; const ks: TdesKeySchedule; Encrypt: Boolean);
procedure xdes_cbc_encrypt(var Buf: TdesBlock; const ks: TdesKeySchedule; var iv: TdesBlock; Encrypt: Boolean);
procedure xdes_set_key(const Data: TdesBlock; var ks: TdesKeySchedule);
procedure xdes_set_odd_parity(var Key: TdesBlock);
procedure xdes_str_to_key(Buf: Pointer; Size: Integer; var Key: TDesBlock);
function xdes_md5_crc16(Buf: Pointer; Size: Integer): Word;
function KeyedMD5(const ASecret; ASecretSize: Integer; const AText; ATextSize: Integer): String;
procedure xCalcMD5(Input: Pointer; InputLen: Integer; var Digest: TMD5Byte16);
function DigestToStr(const D: TMD5Byte16): String;
procedure MD5Init(var Context: TMD5ctx);
procedure MD5Update(var Context: TMD5ctx; const ChkBuf; Len: DWORD);
procedure MD5Final(var Digest: TMD5Byte16; var Context: TMD5ctx);

//procedure TestxDES;
//procedure TestMD5;

implementation


// MD5 =======================================================================

procedure Transform(var Accu; const Buf); register; external; {$L md5_386.obj}

procedure MD5Init(var Context: TMD5ctx);
begin
  Context.BLen := 0;
  Context.Count[0] := 0;
  Context.Count[1] := 0;
  {Load magic initialization constants.}
  Context.State[0]:= $67452301;
  Context.State[1]:= $efcdab89;
  Context.State[2]:= $98badcfe;
  Context.State[3]:= $10325476;
end;

procedure MD5Update(var Context: TMD5ctx; const ChkBuf; Len: DWORD);
var
  BufPtr: ^Byte;
  Left: Cardinal;
Begin
  If Context.Count[0] + DWORD(Integer(Len) shl 3) < Context.Count[0] then Inc(Context.Count[1]);
  Inc(Context.Count[0], Integer(Len) shl 3);
  Inc(Context.Count[1], Integer(Len) shr 29);

  BufPtr:= @ChkBuf;
  if Context.bLen>0 then
  begin
    Left:= 64-Context.bLen; if Left>Len then Left:= Len;
    Move(BufPtr^, Context.Buffer[Context.bLen], Left);
    Inc(Context.bLen, Left); Inc(BufPtr, Left);
    If Context.bLen<64 then Exit;
    Transform(Context.State, Context.Buffer);
    Context.bLen:= 0;
    Dec(Len, Left)
  end;
  while Len>=64 do
  begin
    Transform(Context.State, BufPtr^);
    Inc(BufPtr, 64);
    Dec(Len, 64)
  end;
  if Len>0 then begin
    Context.bLen:= Len;
    Move(BufPtr^, Context.Buffer[0], Context.bLen)
  end
end;

procedure MD5Final(var Digest: TMD5Byte16; var Context: TMD5ctx);
var
  WorkBuf: TMD5Byte64;
  WorkLen: Cardinal;
begin
  Digest := TMD5Byte16(Context.State);
  Move(Context.Buffer, WorkBuf, Context.bLen); {make copy of buffer}
  {pad out to block of form (0..55, BitLo, BitHi)}
  WorkBuf[Context.bLen]:= $80;
  WorkLen:= Context.bLen+1;
  if WorkLen>56 then begin
    FillChar(WorkBuf[WorkLen], 64-WorkLen, 0);
    TransForm(Digest, WorkBuf);
    WorkLen:= 0
  end;
  FillChar(WorkBuf[WorkLen], 56-WorkLen, 0);
  TMD5Int16(WorkBuf)[14]:= Context.Count[0];
  TMD5Int16(WorkBuf)[15]:= Context.Count[1];
  Transform(Digest, WorkBuf);
  FillChar(Context, SizeOf(Context), 0);
end;

procedure xCalcMD5(Input: Pointer; InputLen: Integer; var Digest: TMD5Byte16);
var
  Context: TMD5CTX;
begin
  MD5Init(Context);
  MD5Update(Context, Input^, InputLen);
  MD5Final(Digest, Context);
end;

function DigestToStr(const D: TMD5Byte16): String;
const
  HexChars: string[16] = '0123456789abcdef';
var
  I: Integer;
begin
  SetLength(Result, 32);
  for I := 0 to 15 do
    begin
      Result[1+I*2] := HexChars[1+D[I] shr 4];
      Result[2+I*2] := HexChars[1+D[I] and 15];
    end;
end;


function KeyedMD5(const ASecret; ASecretSize: Integer; const AText; ATextSize: Integer): String;
  var key, ipad, opad: Array[0..63] of Byte;
      D: TMD5Byte16;
      C: TMD5Ctx;
      KeyLen, I: Integer;
begin
  if ASecretSize > 64 then
  begin
    MD5Init(C);
    MD5Update(C, ASecret, ASecretSize);
    MD5Final(D, C);
    Move(D, Key, 16);
    KeyLen := 16;
  end else
  begin
    Move(ASecret, key, ASecretSize);
    KeyLen := ASecretSize;
  end;
  FillChar(opad, SizeOf(opad), 0);
  FillChar(ipad, SizeOf(ipad), 0);
  Move(Key, opad, KeyLen);
  Move(Key, ipad, KeyLen);
  for I := 0 to 63 do
  begin
    ipad[I] := ipad[I] xor $36;
    opad[I] := opad[I] xor $5C;
  end;
  MD5Init(C);
  MD5Update(C, ipad, 64);
  if ATextSize > 0 then MD5Update(C, AText, ATextSize);
  MD5Final(D, C);
  MD5Init(C);
  MD5Update(C, opad, 64);
  MD5Update(C, D, 16);
  MD5Final(D, C);
  Result := DigestToStr(D);
end;

// DES =======================================================================


procedure des_encrypt(var Data: TdesBlock; const ks: TdesKeySchedule; Encrypt: BOOL); register; external; {$L des_enc.obj}
procedure des_ncbc_encrypt(Input: PdesBlock; Output: PdesBlock; const ks: TdesKeySchedule; iv: PdesBlock; Encrypt: BOOL); register; external; {$L sp_trans.obj}
procedure des_set_key(Data: PdesBlock; var ks: TdesKeySchedule); register; external; {$L set_key.obj}

procedure xdes_ecb_encrypt_block(Buf: Pointer; Size: Integer; const Key: TdesBlock; Encrypt: Boolean);
var
  TargetPtr: Integer;
  ks: TdesKeySchedule;
  b: Integer;
begin
  b := Integer(Buf);
  TargetPtr := b + Size;
  xdes_set_key(Key, ks);
  while b < TargetPtr do
  begin
    des_encrypt(PdesBlock(b)^, ks, Encrypt);
    Inc(b,8)
  end;
end;

procedure xdes_cbc_encrypt_block(Buf: Pointer; Size: Integer; const Key: TdesBlock; Encrypt: Boolean);
var
  TargetPtr: Integer;
  ks: TdesKeySchedule;
  b: Integer;
  iv: TdesBlock;
begin
  iv := 0;
  b := Integer(Buf);
  TargetPtr := b + Size;
  xdes_set_key(Key, ks);
  while b < TargetPtr do begin xdes_cbc_encrypt(PdesBlock(b)^, ks, iv, Encrypt); Inc(b,8) end;
end;

procedure xdes_set_key(const Data: TdesBlock; var ks: TdesKeySchedule);
begin
  des_set_key(@Data, ks);
end;

procedure xdes_set_odd_parity(var Key: TdesBlock);
const
  OddParity: array[Byte] of Byte = (
    1,  1,  2,  2,  4,  4,  7,  7,  8,  8, 11, 11, 13, 13, 14, 14,
   16, 16, 19, 19, 21, 21, 22, 22, 25, 25, 26, 26, 28, 28, 31, 31,
   32, 32, 35, 35, 37, 37, 38, 38, 41, 41, 42, 42, 44, 44, 47, 47,
   49, 49, 50, 50, 52, 52, 55, 55, 56, 56, 59, 59, 61, 61, 62, 62,
   64, 64, 67, 67, 69, 69, 70, 70, 73, 73, 74, 74, 76, 76, 79, 79,
   81, 81, 82, 82, 84, 84, 87, 87, 88, 88, 91, 91, 93, 93, 94, 94,
   97, 97, 98, 98,100,100,103,103,104,104,107,107,109,109,110,110,
  112,112,115,115,117,117,118,118,121,121,122,122,124,124,127,127,
  128,128,131,131,133,133,134,134,137,137,138,138,140,140,143,143,
  145,145,146,146,148,148,151,151,152,152,155,155,157,157,158,158,
  161,161,162,162,164,164,167,167,168,168,171,171,173,173,174,174,
  176,176,179,179,181,181,182,182,185,185,186,186,188,188,191,191,
  193,193,194,194,196,196,199,199,200,200,203,203,205,205,206,206,
  208,208,211,211,213,213,214,214,217,217,218,218,220,220,223,223,
  224,224,227,227,229,229,230,230,233,233,234,234,236,236,239,239,
  241,241,242,242,244,244,247,247,248,248,251,251,253,253,254,254);
var
  i: Integer;
begin
  for i := 0 to SizeOf(Key)-1 do TDesBlockB(Key)[i] := OddParity[TDesBlockB(Key)[i]];
end;


procedure xdes_str_to_key(Buf: Pointer; Size: Integer; var Key: TDesBlock);
var
  digest: array[0..1] of TDesBlock;
  ks: TdesKeySchedule;
begin
  xCalcMD5(Buf, Size, TMD5Byte16(digest));
  xdes_set_odd_parity(digest[1]);
  xdes_set_key(digest[1], ks);
  des_encrypt(digest[0], ks, True);
  xdes_set_odd_parity(digest[0]);
  Key := digest[0];
end;

function xdes_md5_crc16(Buf: Pointer; Size: Integer): Word;
var
  R: TDesBlockI;
begin
  xdes_str_to_key(Buf, Size, TDesBlock(R));
  Result := R[0] and $FFFF;
end;


procedure xdes_ecb_encrypt(var Buf: TdesBlock; const ks: TdesKeySchedule; Encrypt: Boolean);
begin
  des_encrypt(Buf, ks, Encrypt);
end;

procedure xdes_cbc_encrypt(var Buf: TdesBlock; const ks: TdesKeySchedule; var iv: TdesBlock; Encrypt: Boolean);
var
  PInput: PdesBlockI;
  Output: TdesBlockI;
begin
  des_ncbc_encrypt(@Buf, @TDesBlock(Output), ks, @iv, Encrypt);
  PInput := @Buf;
  PInput^[0] := Output[0];
  PInput^[1] := Output[1];
end;

procedure __chkstk; begin end;





(*

MD5 test suite:                                                           
MD5 ("") = d41d8cd98f00b204e9800998ecf8427e                               
MD5 ("a") = 0cc175b9c0f1b6a831c399e269772661
MD5 ("abc") = 900150983cd24fb0d6963f7d28e17f72                            
MD5 ("message digest") = f96b697d7cb7938d525a2f31aaf161d0                 
MD5 ("abcdefghijklmnopqrstuvwxyz") = c3fcd3d76192e4007dfb496cca67e13b
MD5 ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789") =
d174ab98d277d9f5a5611c2c9f419d9f                                          
MD5 ("123456789012345678901234567890123456789012345678901234567890123456  
78901234567890") = 57edf4a22be3c955ac49da2e2107b67a

*)

procedure TestMD5;
var
  s: string;
  digest: TMD5Byte16;
begin
//  s := 'message digest';
  s := '12345678901234567890123456789012345678901234567890123456789012345678901234567890';
  xCalcMD5(@s[1], Length(s), digest);
end;

(*

0000000000000000 0000000000000000 8ca64de9c1b123a7
0101010101010101 0000000000000000 8ca64de9c1b123a7
ffffffffffffffff ffffffffffffffff 7359b2163e4edc58
fefefefefefefefe ffffffffffffffff 7359b2163e4edc58
fefefefefefefefe 9823873621837678 173c550deced7865
1111111111111111 1111111111111111 f40379ab9e0ec533
2222222222222222 2222222222222222 0f8adffb11dc2784
7be9c1bd088aa102 3d38509b746b9fbe 31192bac9ab287c7
2d04417f775d4351 53c48d9602b26e0b a52f7709aa856d9a
418fedcf19dbc19e 78512adb1a1f5e2b 09a47b72bc881c4d
307d77616584c1f0 24e3c36f2232310f 443c1bdfb8ca3db5
2dac5ceb106e8b5a 5a05a9385e6392b6 ee418cdbf3299030
66b9034875264901 4174f402618b18a4 716b0b27a0449e09
3a6ab4bf3c4bc289 2657a9a94e68589b df3d3e4874ac16b3
09648aa63fc489bb 1c1b715c054e4c63 95cafb6f3378a566
484f2abd5953c1f8 79b9ec2275536c3d 414b829106e93f36
50b105494d7e79b8 7805da481240f318 2419cf991c045461
675a3b5670570523 2c60514317d7b2b7 092c9dd1a50eecc4
55dbc713514414b2 3a09e3c7038823ff 4eb1f44535a1ee54
61b2a00c140f8cff 61ebb6b5486ba354 651168ba4fd10a1a
0935d6002360aab8 29f6bbf843a08abf 2c0d4e4288a247c7
5fac6d41504e65a2 1208e35b6910f7e7 f436fedd0195eb70

*)

procedure TestDES_ECB;
var
  k, d: TdesBlock;
  ks: TdesKeySchedule;
begin
  FillChar(k, SizeOf(k), 0);
  FillChar(d, SizeOf(d), 0);
  xdes_set_key(k, ks);
  xdes_ecb_encrypt(d, ks, True);
end;

procedure TestDES_CBC;
var
  g,v: array[0..$100] of Byte;
  k, d, t, iv: TdesBlock;
  ks: TdesKeySchedule;
begin
  FillChar(k, SizeOf(k), $11);
  FillChar(d, SizeOf(d), $11);
  FillChar(t, SizeOf(t), 0);
  FillChar(iv, SizeOf(iv), 0);
  xdes_set_key(k, ks);
  xdes_cbc_encrypt(d, ks, iv, True);
  xdes_cbc_encrypt(t, ks, iv, True);

  FillChar(iv, SizeOf(iv), 0);
  xdes_cbc_encrypt(d, ks, iv, False);
  xdes_cbc_encrypt(t, ks, iv, False);

  FillChar(g, $100, 0);
  FillChar(v, $100, 0);

  xdes_cbc_encrypt_block(@g, $100, k, True);
  xdes_ecb_encrypt_block(@v, $100, k, True);
end;

procedure TestxDES;
begin
  TestDES_ECB;
  TestDES_CBC;
  TestMD5;
end;

end.
