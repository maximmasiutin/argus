unit RegExp;

// $Id: RegExp.pas,v 1.6 2001/02/16 17:39:46 max Exp $


// interface module to PCREv3

interface

uses Windows, Classes, SysUtils;

const
  // Exec-time and get-time error codes
  PCRE_ERROR_NOMATCH      = -1;
  PCRE_ERROR_BADREF       = -2;
  PCRE_ERROR_NULL         = -3;
  PCRE_ERROR_BADOPTION    = -4;
  PCRE_ERROR_BADMAGIC     = -5;
  PCRE_ERROR_UNKNOWN_NODE = -6;
  PCRE_ERROR_NOMEMORY     = -7;

  // Options defined by POSIX.
  REG_ICASE   = 1;
  REG_NEWLINE = 2;
  REG_NOTBOL  = 4;
  REG_NOTEOL  = 8;

  // Error values. Not all these are relevant or used by the wrapper.
  REG_ASSERT   =  1; // internal error ?
  REG_BADBR    =  2; // invalid repeat counts in {}
  REG_BADPAT   =  3; // pattern error
  REG_BADRPT   =  4; // ? * + invalid
  REG_EBRACE   =  5; // unbalanced {}
  REG_EBRACK   =  6; // unbalanced []
  REG_ECOLLATE =  7; // collation error - not relevant
  REG_ECTYPE   =  8; // bad class
  REG_EESCAPE  =  9; // bad escape sequence
  REG_EMPTY    = 10; // empty expression
  REG_EPAREN   = 11; // unbalanced ()
  REG_ERANGE   = 12; // bad range inside []
  REG_ESIZE    = 13; // expression too big
  REG_ESPACE   = 14; // failed to get memory
  REG_ESUBREG  = 15; // bad back reference
  REG_INVARG   = 16; // bad argument
  REG_NOMATCH  = 17; // match failed

type
  size_t = Integer;

  PVector = ^TVector;
  TVector = record
    Start, Next:Integer;
  end;
  PVecArray = ^TVecArray;
  TVecArray = array [0..1024*1024-1] of TVector;
  PByte = ^TByteArr;
  TByteArr = array[0..1024*1024-1] of Byte;

  TMallocProc = function(Size:size_t):Pointer; cdecl;
  TFreeProc = procedure(P:Pointer); cdecl;
  PMallocProc = ^TMallocProc;
  PFreeProc = ^TFreeProc;

  PPchar = ^PChar;
  PInteger = ^Integer;

  TPattOptions = set of (poAnchored, poCaseless, poDollarEndOnly,
    poDotAll, poExtended, poExtra, poMultiline, poUngreedy);
  TMatchOptions = set of (moNotBol, moNotEol);

  // The structure representing a compiled regular expression.
  pregex_t = ^regex_t;
  regex_t = packed record
    re_pcre:Pointer;
    re_nsub, re_erroffset:size_t;
  end;

  // The structure in which a captured offset is returned.
  regoff_t = Integer;

  pregmatch_t = ^regmatch_t;
  regmatch_t = packed record
    rm_so, rm_eo:regoff_t;
  end;

  TPcre = class
  private
    CS: TRTLCriticalSection;
    FPcre, FExtra:Pointer;
    FSubj, FErrMsg:String;
    FErrPtr:Integer;
    FVec:PVecArray;
    FMatchCount:Integer;
    FMatchesMax:Integer;
    FStart:Integer; // T úðúþóþ ¸øüòþûð ýð¢øýðª¹ ÿþø¸ú
    FPattOptions:TPattOptions;
    FMatchOptions:TMatchOptions;
    procedure SetPatt(const APatt:String);
    function PattOpt2Int:Integer;
    function MatchOpt2Int:Integer;
    procedure SetPattOptions(Opt:TPattOptions);
    procedure SetMatchOptions(Opt:TMatchOptions);
    procedure Compile;
    function GetMatch(I:Integer):String;
    function GetPos(I:Integer):Integer;
    function GetNext(I:Integer):Integer;
    function GetSize(I: Integer):Integer;
    procedure FindMatchCount;
  protected
  public
    Initializing: Boolean;
    FPatt: string;
    Owned,
    TriesLastTick,
    TriesTotal: Integer;
    procedure Lock;
    procedure Unlock;
    constructor Create;
//    constructor CreatePatt(const APattern:String; AStudy:Boolean);
    destructor Destroy; override;
//    function Study:Boolean;
    function Match(const S:String):Integer;
    function MatchAt(const S:String; StartPos:Integer):Integer;
    function MatchAtBuf(const ABuf; ABufSize: Integer):Integer;
    function Studied:Boolean;
    function Version:String;
    property ErrMsg:String read FErrMsg;
    property ErrPtr:Integer read FErrPtr;
    property MatchCount:Integer read FMatchCount;
    property Matches[I:Integer]:String read GetMatch; default;
    property MatchPos[I:Integer]:Integer read GetPos;
    property MatchNext[I:Integer]:Integer read GetNext;
    property MatchSize[I:Integer]:Integer read GetSize;
    property MatchesMax:Integer read FMatchesMax;
    property Pattern:String read FPatt write SetPatt;
    property PattOptions:TPattOptions read FPattOptions write SetPattOptions;
    property MatchOptions:TMatchOptions read FMatchOptions write SetMatchOptions;
  end;

implementation uses xBase;

function pcre_compile(Pattern:PChar; Options:Integer; Err:PPchar; Off:PInteger; Tables:PChar):Pointer; register; external;
function pcre_exec(Pcre:Pointer; Study:Pointer; Subj:PChar; Length, APos, Options:Integer; Vec:PVecArray; VecSize:Integer):Integer; register; external;
function pcre_info(Pcre:Pointer; Opt, FirstChar:PInteger):Integer; register; external;
//function pcre_study(Pcre:Pointer; Options:Integer; var Err:PChar):Pointer; register; external;
function pcre_version:PChar; register; external;
//function regcomp(preg:pregex_t; pattern:PChar; cflags:Integer):Integer; register; external;
//function regexec(preg:pregex_t; pstr:PChar; nmatch:size_t; pmatch:pregmatch_t; eflags:Integer):Integer; register; external;
//function regerror(errcode:Integer; preg:pregex_t; errbuf:PChar; errbuf_size:size_t):size_t; register; external;
//procedure regfree(preg:pregex_t); register; external;

const
  // Options
  PCRE_CASELESS       = $0001;
  PCRE_MULTILINE      = $0002;
  PCRE_DOTALL         = $0004;
  PCRE_EXTENDED       = $0008;
  PCRE_ANCHORED       = $0010;
  PCRE_DOLLAR_ENDONLY = $0020;
  PCRE_EXTRA          = $0040;
  PCRE_NOTBOL         = $0080;
  PCRE_NOTEOL         = $0100;
  PCRE_UNGREEDY       = $0200;
  PCRE_NOTEMPTY       = $0400;

{type
  PPcreTables = ^TPcreTables;
  TPcreTables = packed record
    lcc:array[0..255] of Char;
    fcc:array[0..255] of Char;
    cbits:array[0..8*12-1] of Byte;
    ctypes:array[0..255] of Char;
  end;}

function PCRE_MALLOC(Size: Integer): Pointer; register;
begin
  Result := nil;
  ReallocMem(Result, Size);
end;

procedure PCRE_FREE(p: Pointer); register;
begin
  ReallocMem(p, 0);
end;


//var
//  PcreTables:PPcreTables;

//var
//  CS: TRTLCriticalSection;

procedure TPcre.Lock;
begin
  EnterCS(CS);
end;

procedure TPcre.Unlock;
begin
  LeaveCS(CS);
end;

function TPcre.Version:String;
begin
  Result := pcre_version;
end;

constructor TPcre.Create;
begin
  Initializing := True;
  InitializeCriticalSection(CS);
  inherited Create;
  Pattern := '';
end;

{constructor TPcre.CreatePatt(const APattern:String; AStudy:Boolean);
begin
  inherited Create;
  Pattern := APattern;
  if AStudy then Study;
end;}

destructor TPcre.Destroy;
begin
  if FVec <> nil then PCRE_free(FVec);
  if FPcre <> nil then PCRE_free(FPcre);
  if FExtra <> nil then PCRE_free(FExtra);
  inherited Destroy;
  DeleteCriticalSection(CS);
end;

function TPcre.GetMatch(I:Integer):String;
begin
  if (I >= 0) and (I < FMatchCount) then
    with FVec^[I] do
      Result := Copy(FSubj, Start+FStart, Next-Start)
  else Result := '';
end;

function TPcre.GetPos(I:Integer):Integer;
begin
  if (I >= 0) and (I < FMatchCount) then
    Result := FVec^[I].Start+FStart
  else Result := 1;
end;

function TPcre.GetNext(I:Integer):Integer;
begin
  if (I >= 0) and (I < FMatchCount) then
    Result := FVec^[I].Next+FStart
  else Result := 0;
end;

function TPcre.GetSize(I: Integer):Integer;
begin
  if (I >= 0) and (I < FMatchCount) then
    Result := FVec^[I].Next-FVec^[I].Start
  else Result := 0;
end;

procedure TPcre.SetPattOptions(Opt:TPattOptions);
begin
  FPattOptions := Opt;
  Compile;
end;

procedure TPcre.SetMatchOptions(Opt:TMatchOptions);
begin
  FMatchOptions := Opt;
  Compile;
end;

procedure TPcre.FindMatchCount;
var
  I:Integer;
  C:Char;
  Prefix:Boolean;
begin
  Prefix := False;
  FMatchesMax := 1;
  for I := 1 to Length(FPatt) do begin
    C := FPatt[I];
    if (C = '(') and not Prefix then Inc(FMatchesMax);
    Prefix := C = '\';
  end;
end;

procedure TPcre.Compile;
var
  PErr:PChar;
  WasStudied:Boolean;
begin
  if Initializing then Exit;
  if FVec <> nil then PCRE_free(Pointer(FVec));
  WasStudied := FExtra <> nil;
  if FExtra <> nil then PCRE_free(FExtra);
  if FPcre <> nil then PCRE_free(FPcre);
  FPcre := pcre_compile(PChar(FPatt), PattOpt2Int, @PErr, @FErrPtr, nil{PcreTables^.lcc});
  if PErr = nil then begin
    FErrMsg := '';
    FindMatchCount;
//    if WasStudied then Study;
  end else begin
    FErrMsg := PErr;
    Inc(FErrPtr);
  end;
  FMatchCount := 0;
  TriesTotal := 0;
end;

procedure TPcre.SetPatt(const APatt:String);
begin
  FPatt := APatt;
  Compile;
end;

function TPcre.PattOpt2Int:Integer;
begin
  Result := 0;
  if poAnchored in FPattOptions then Inc(Result, PCRE_ANCHORED);
  if poCaseless in FPattOptions then Inc(Result, PCRE_CASELESS);
  if poDollarEndOnly in FPattOptions then Inc(Result, PCRE_DOLLAR_ENDONLY);
  if poDotAll in FPattOptions then Inc(Result, PCRE_DOTALL);
  if poExtended in FPattOptions then Inc(Result, PCRE_EXTENDED);
  if poMultiline in FPattOptions then Inc(Result, PCRE_MULTILINE);
  if poExtra in FPattOptions then Inc(Result, PCRE_EXTRA);
  if poUngreedy in FPattOptions then Inc(Result, PCRE_UNGREEDY);
end;

function TPcre.MatchOpt2Int:Integer;
begin
  Result := 0;
  if moNotBol in FMatchOptions then Inc(Result, PCRE_NOTBOL);
  if moNotEol in FMatchOptions then Inc(Result, PCRE_NOTEOL);
end;

(*function TPcre.Study:Boolean;
var
  PErr:PChar;
begin
  Result := FErrMsg = '';
  if FErrMsg <> '' then Exit;
  if FExtra <> nil then PCRE_free(FExtra);
  FExtra := pcre_study(FPcre, {StudyOpt2Int}0, PErr);
  Result := PErr = nil;
  if not Result then
    FErrMsg := PErr;
end;*)

function TPcre.Studied:Boolean;
begin
  Result := FExtra <> nil;
end;

function TPcre.Match(const S:String):Integer;
begin
  Result := MatchAt(S, 1);
end;

{
function TPcre.MatchAt(const S:String; StartPos:Integer):Integer;
var
  Size:Integer;
begin
  if FPcre = nil then
    raise Exception.Create('Regexp is wrong: '+ErrMsg);
  FSubj := S;
  FStart := StartPos;
  Size := FMatchesMax * SizeOf(Integer) * 3;
  if FVec <> nil then PCRE_free(Pointer(FVec));
  if Size <> 0 then FVec := PCRE_Malloc(Size);
  Result := pcre_exec(FPcre, FExtra, @S[StartPos], Length(S)-StartPos+1, 0,
    MatchOpt2Int, FVec, Size div SizeOf(Integer));
  FMatchCount := Result;
  Inc(TriesTotal);
end;
}

function TPcre.MatchAtBuf(const ABuf; ABufSize: Integer):Integer;
var
  Size:Integer;
begin
  if FPcre = nil then
    raise Exception.Create('Regexp is wrong: '+ErrMsg);
  Size := FMatchesMax * SizeOf(Integer) * 3;
  if FVec <> nil then PCRE_free(Pointer(FVec));
  if Size <> 0 then FVec := PCRE_Malloc(Size);
  Result := pcre_exec(FPcre, FExtra, @ABuf, ABufSize, 0, MatchOpt2Int, FVec, Size div SizeOf(Integer));
  FMatchCount := Result;
end;

function TPcre.MatchAt(const S:String; StartPos:Integer):Integer;
begin
  FSubj := S;
  FStart := StartPos;
  Result := MatchAtBuf(S[StartPos], Length(S)-StartPos+1);
end;

{$L PCRE.OBJ}


procedure __chkstk; begin end;

function _strncmp(a, b: Pointer; c: Integer): Integer;
begin
  Result := StrLComp(a, b, c);
end;

initialization
//  InitTables;
finalization
//  FreeMem(PcreTables);
end.






