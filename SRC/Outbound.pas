{$H+}
unit Outbound;

{$I DEFINE.INC}


interface
uses Windows, Classes, SysUtils, xBase, xFido;

type

     TOutStatusSet = Set of TOutStatus;

     TFileInfoColl = class(TColl)
       procedure FreeItem(Item: Pointer); override;
     end;

     TOutFileColl = class(TColl)
       function Copy: Pointer; override;
       function GetNamesColl: TStringColl;
       function FoundFName(const FName: string): Boolean;
       procedure PurgeDuplicates;
     end;

     TOutItem = class(TAdvCpOnlyObject)
       Caption: string;
       GlyphIndex: Integer;
       Address: TFidoAddress;
       Name: string;
       Nfo: TFileInfo;
       function Status: TOutStatus; virtual; abstract;
       function StatusSet: TOutStatusset; virtual; abstract;
       function StatusString: string; virtual; abstract;
       function ActionString: string; virtual; abstract;
       procedure PrepareNfo; virtual; abstract;
       function AgeString: string;
     end;

     TOutNode = class(TOutItem)
       FStatus: TOutStatusSet;
       Files: TOutFileColl;
       function Copy: Pointer; override;
       destructor Destroy; override;
       function Status: TOutStatus; override;
       function StatusSet: TOutStatusset; override;
       function StatusString: string; override;
       function ActionString: string; override;
       procedure PrepareNfo; override;
     end;

     TOutNodeColl = class(TSortedColl)
       function Compare(Key1, Key2: Pointer): Integer; override;
       function KeyOf(Item: Pointer): Pointer; override;
       function Copy: Pointer; override;
       constructor Create;
     end;

     TOutFile = class(TOutItem)
       FStatus: TOutStatus;
       Error: Integer;
       KillAction: TKillAction;
       MoveTo: string;
       function Copy: Pointer; override;
       function Status: TOutStatus; override;
       function StatusSet: TOutStatusset; override;
       function StatusString: string; override;
       function ActionString: string; override;
       procedure PrepareNfo; override;
       function OutAttType: TOutAttType;
     end;

     TLockFile = class
       FName: string;
       FHandle: DWORD;
       FCompatibleDelete: Boolean;
       constructor Create(const AFName: string; ACompatibleDelete: Boolean);
       procedure Finish; virtual;
       destructor Destroy; override;
     end;

     TBusyFlag = class(TLockFile)
//       FName: string;
       Address: TFidoAddress;
//       Handle: DWORD;
       Time: EventTimer;
       procedure Finish; override;
     end;

     TOutbound = class
       private
         FFileBoxes: Pointer;
         LastRescan: EventTimer;
         CacheCS: TRTLCriticalSection;
         OutCache: TOutNodeColl;
         BusyFlags: TColl;
         function _GetOutColl: TOutNodeColl;
         function _GetOutCollP(Single, AFull: Boolean; const Addr: TFidoAddress): TOutNodeColl;
       public
         ForcedRescan: Boolean;
         constructor Create;
         function AttachFiles(const Address: TFidoAddress; Files: TStringColl; Status: TOutStatus; KillAction: TKillAction): Boolean;
         procedure FinalizeSession(const Address: TFidoAddress; KillREQ: Boolean);
         procedure RewriteFREQ(const Address: TFidoAddress; Files: TStringColl);
         function DeleteFile(const Address: TFidoAddress; const AFName: string; Status: TOutStatus): Boolean;
         function ChangeAttachStatusFile(const Address: TFidoAddress; const AFName: string; OldStatus, NewStatus: TOutStatus): Boolean;
         function MoveFiles(AFNames: TStringColl; SrcAddr, DstAddr: PFidoAddress; SrcStat, DstStat: POutStatus; HardCore, Purge, Unlink: Boolean): Boolean;
         function  GetOutbound(const Address: TFidoAddress; const Status: TOutStatusSet; AC: TOutFileColl; AFileNames: TStringColl; AFileInfos: TFileInfoColl; ALock: Boolean): TOutFileColl;
         function  Lock(const Address: TFidoAddress): Boolean;
         function  LockEx(const Address: TFidoAddress; var Local: Boolean): Boolean;
         procedure Unlock(const Address: TFidoAddress);
         destructor Destroy; override;
         function GetOutColl(AFull: Boolean): TOutNodeColl;
         function GetOutNode(const Addr: TFidoAddress): TOutNode;
     end;

function FtnToStr(Zone, Net, Node, Point: Integer): String;
function NormalizeAddress(const Address, Template: String): String;
function GetOutFileName(const Addr: TFidoAddress; Status: TOutStatus): String;
procedure InitFidoOut;
procedure DoneFidoOut;
function DeleteOutFile(const FName: string): Boolean;

var FidoOut: TOutbound;

const
    SKillActionA : array[TKillAction] of string = ('', '^', '#', '', '');
    SKillActionB : string = '^#';
    SAttachExt : array[TOutStatus] of string = (
    '', '.BSY',
    '.CUT', '.DUT', '.OUT', '.HUT',
    '.CLO', '.DLO', '.FLO', '.HLO', '.HRQ',
    '.REQ', '');




type
  TFileBoxDirRecord = class
    Addr: TFidoAddress;
    Status: TOutStatus;
    Path: string;
    MoveTo: string;
    KillAction: TKillAction;
  end;

  TFileBoxDirColl = class(TSortedColl)
    function Compare(Key1, Key2: Pointer): Integer; override;
    function KeyOf(Item: Pointer): Pointer; override;
  end;

function GetFileBoxDirColl(const AAddr, ADir: string; AStatus: TOutStatus; AColl: TFileBoxDirColl; PErrorMsg: PString; AMoveTo: PString; AKillAction: PKillAction): Boolean;

implementation uses Recs, NdlUtil, LngTools, RegExp;

const
  FAttachDisallowedAttr =
    FILE_ATTRIBUTE_DIRECTORY or
    FILE_ATTRIBUTE_HIDDEN or
    FILE_ATTRIBUTE_SYSTEM or
    FILE_ATTRIBUTE_READONLY;

function FtnToStr(Zone, Net, Node, Point: Integer): String;
begin
  if (Zone = 0) then Result := Format('%d/%d.%d', [Net, Node, Point])
                else Result := Format('%d:%d/%d.%d', [Zone, Net, Node, Point])
end;

function A4sToAddrStr(const a: Ta4s): string;
begin
   Result := Format('%s:%s/%s.%s', [a[1], a[2], a[3], a[4]])
end;


function NormalizeAddress(const Address, Template: String): String;
var
  Addr: TFidoAddress;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  ParseAddress(Template, Addr);
  ParseAddress(Address, Addr);
  Result := Addr2Str(Addr);
end;

function GetBinkFileName(var S: String): TKillAction;
begin
  S := Trim(S); if Length(S)<2 then begin Result := kaBsoNothingAfter; S := ''; Exit end;
  Result := TKillAction(Pos(S[1], SKillActionB));
  if Result <> kaBsoNothingAfter then DelFC(S);
  case S[1] of ';', '~': begin S := ''; Exit end end;
end;

function GetOutFileName;
var
  S,D,N,X: String;
begin
  S := dOutbound;
  if (Addr.Zone = 0) or (Addr.Zone = DefaultZone) then
    begin
      if S[Length(S)] <> '\' then AddStr(S, '\');
    end else
      begin
        if S[Length(S)] = '\' then SetLength(S, Length(S)-1);
        FSplit(S, D, N, X);
        S := Format('%s%s.%3.3x\', [D, N, Addr.Zone]);
      end;
  S := Format('%s%4.4x%4.4x', [S, Addr.Net, Addr.Node]);
  if Addr.Point <> 0 then S := S + '.PNT\'+Hex8(Addr.Point);
  Result := S + SAttachExt[Status];
end;

{ TOutBound }

constructor TOutBound.Create;
begin
  inherited Create;
  BusyFlags := TColl.Create;
  InitializeCriticalSection(CacheCS);
end;

destructor TOutBound.Destroy;
begin
  FreeObject(FFileBoxes);
  FreeObject(OutCache);
  FreeObject(BusyFlags);
  DeleteCriticalSection(CacheCS);
  inherited Destroy;
end;

procedure TOutBound.FinalizeSession;

  function KillEmpty(const FName: string): Boolean;
  var
    fs: DWORD;
    T: TTextReader;
    s: string;
  begin
    Result := False;
    fs := _GetFileSize(FName);
    if fs = INVALID_FILE_SIZE then Exit;
    if fs = 0 then begin Result := True; Exit end;
    T := CreateTextReader(FName);
    if T = nil then Exit;
    Result := True;
    while not T.EOF do
    begin
      s := T.GetStr; GetBinkFileName(s);
      if s <> '' then begin Result := False; Break end;
    end;
    FreeObject(T);
  end;

  procedure KillZero(const FName: string);
  begin if KillEmpty(FName) then SysUtils.DeleteFile(FName) end;

var S: string;

  procedure Kill(Status: TOutStatus);
  begin KillZero(S + SAttachExt[Status]) end;

begin
  S := GetOutFileName(Address, osNone);
  Kill(os_Crash);
  Kill(os_Direct);
  Kill(osNormal);
  Kill(osHold);
  Kill(osHReq);
  if KillREQ then SysUtils.DeleteFile(S + SAttachExt[osRequest]);
  DeleteEmptyDirInheritance(ExtractFileDir(S), dOutbound);
  ForcedRescan := True;
end;

function TOutBound.DeleteFile;
var
  sc: TStringColl;
begin
  Result := False;
  case Status of
    os_Crash, os_Direct, osNormal, osHold, osHReq: ;
    else Exit;
  end;
  sc := TStringColl.Create;
  sc.Add(AFName);
  Result := MoveFiles(sc, @Address, nil, @Status, nil, False, False, False);
  FreeObject(sc);
end;

function TOutBound.ChangeAttachStatusFile(const Address: TFidoAddress; const AFName: string; OldStatus, NewStatus: TOutStatus): Boolean;
var
  sc: TStringColl;
begin
  sc := TStringColl.Create;
  sc.Add(AFName);
  Result := MoveFiles(sc, @Address, @Address, @OldStatus, @NewStatus, False, False, False);
  FreeObject(sc);
end;


function TOutBound.MoveFiles;
var
  FOutbound, SrcFName, DstFName, s: string;
  DS, AuxS: TDosStream;
  AC, L: TStringColl;
  FHandle: DWORD;
  SLN, I, Files: Integer;
  OK: Boolean;
  os: TOutStatus;
  ka: TKillAction;

function Moved: Boolean;
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    Result := MoveFileEx(PChar(SrcFName), PChar(s), 0);
  end else
  begin
    Result := MoveFile(PChar(SrcFName), PChar(s));
  end;
end;

begin
  ClearErrorMsg;
  FOutbound := dOutbound;
  AC := nil;
  DS := nil;
  AuxS := nil;
  Result := CollCount(AFNames) = 0;
  if Result then Exit;
  SrcFName := GetOutFileName(SrcAddr^, SrcStat^);
  if DstStat <> nil then
  begin
    if HardCore or Purge then GlobalFail('%s', ['TOutBound.MoveFiles, HardCore / Purge']);
    if (CompareAddrs(SrcAddr^, DstAddr^) = 0) then
    begin
      if (SrcStat^ = osRequest) or
         (SrcStat^ = osHReq) or
         (SrcStat^ = DstStat^) then
      begin
        Result := True;
        Exit;
      end;
    end;
    if SrcStat^ = osRequest then os := osRequest else
    case DstStat^ of
      os_Crash, os_Direct, osNormal, osHold, osHReq : os := DstStat^;
      os_CrashMail : os := os_Crash;
      os_DirectMail : os := os_Direct;
      osNormalMail : os := osNormal;
      osHoldMail : os := osHold;
      else begin GlobalFail('%s', ['TOutBound.MoveFiles, DstStat^ ??']); Exit end;
    end;
    DstFName := GetOutFileName(DstAddr^, os);
  end;
  case SrcStat^ of
    os_Crash, os_Direct, osNormal, osHold, osHReq : ;
    else
    begin
      if Purge then begin Result := True; Exit end;
      if CollCount(AFNames) <> 1 then GlobalFail('TOutBound.MoveFiles CollCount(AFNames) = %d', [CollCount(AFNames)]);
      if DstAddr = nil then
      begin
        if not HardCore then Result := True else
        begin
          Result := Windows.DeleteFile(PChar(SrcFName));
          if not Result then SetErrorMsg(SrcFName);
        end;
      end else
      begin
        DS := CreateDosStream(DstFName, [cWrite]);
        if DS = nil then Exit;
        if SeekEOF(DS.Handle) = INVALID_FILE_SIZE then
        begin
          FreeObject(DS);
          SetErrorMsg(DstFName);
          Exit;
        end;
        case SrcStat^ of
          os_CrashMail, os_DirectMail, osNormalMail, osHoldMail :
          begin
            if GetPktFileType(SrcFName) = pftP2K then s := '%s%.8x.P2K' else s := '%s%.8x.PKT';
            s := Format(s, [ExtractFilePath(SrcFName), xRandom32]);
            if not DS.WriteLn('^'+s) then
            begin
              FreeObject(DS);
              SetErrorMsg(DstFName);
              Exit;
            end;
            FreeObject(DS);
            i := 0;
            repeat
              Inc(i);
              if Moved then
              begin
                Result := True;
                Break;
              end else
              begin
                SetErrorMsg(Format('%s -> %s', [SrcFName, s]));
                case GetLastError of
                  ERROR_ALREADY_EXISTS,
                  ERROR_FILE_EXISTS:
                  else Break;
                end;
              end;
            until i < $1000;
          end;
          osRequest:
          begin
            AuxS := CreateDosStream(SrcFName, [cRead]);
            if AuxS = nil then
            begin
              FreeObject(DS);
              SetErrorMsg(SrcFName);
              Exit;
            end;
            DS.CopyFrom(AuxS, 0);
            FreeObject(AuxS);
            FreeObject(DS);
            if not Windows.DeleteFile(PChar(SrcFName)) then SetErrorMsg(SrcFName);
            Result := True;
          end;
          else GlobalFail('%s', ['TOutBound.MoveFiles SrcStat^ ??']);
        end;
      end {DstAddr <> nil};
      Exit;
    end {non-list};
  end {case};
  Files := 0;
  if DstAddr <> nil then
  begin
    AuxS := CreateDosStream(DstFName, [cWrite]);
    if AuxS = nil then Exit;
    if SeekEOF(AuxS.Handle) = INVALID_FILE_SIZE then
    begin
      FreeObject(AuxS);
      SetErrorMsg(DstFName);
      Exit;
    end;
  end;
  DS := CreateDosStream(SrcFName, [cRead, cWrite, cExisting]);
  if DS = nil then
  begin
    FreeObject(AuxS);
    Exit;
  end;
  L := TStringColl.Create;
  if not L.LoadFromStream(DS) then
  begin
    FreeObject(DS);
    FreeObject(AuxS);
    FreeObject(L);
    Exit;
  end;
  for i := L.Count-1 downto 0 do
  begin
    s := L[i];
    ka := GetBinkFileName(s);
    if s = '' then Continue;
    s := MakeFullDir(FOutbound, s);
    Inc(Files);
    if AFNames.Found(s) then
    begin
      if DstAddr <> nil then
      begin
        if AC = nil then AC := TStringColl.Create;
        AC.AtInsert(0, NewStr(L[i]));
      end;
      if Purge and (FileExists(s)) then Continue;
      L.AtFree(i);
      if HardCore then
      begin
        case ka of
          kaBsoKillAfter:
            DeleteOutFile(s);
          kaBsoTruncateAfter:
            begin
              FHandle := _CreateFile(s, [cTruncate, cEnsureNew]);
              if FHandle <> INVALID_HANDLE_VALUE then ZeroHandle(FHandle);
            end;
          kaBsoNothingAfter: ;
        end;
      end;
    end;
  end;
  if AC <> nil then
  begin
    s := AC.LongString;
    FreeObject(AC);
    SLN := Length(s);
    if SLN > 0 then AuxS.Write(s[1], SLN);
  end;
  FreeObject(AuxS);
  i := L.Count;
  DS.Position := 0;
  OK := L.SaveToStream(DS);
  FreeObject(L);
  OK := DS.Truncate and OK;
  FreeObject(DS);
  if ((Unlink or Purge or HardCore or (DstAddr <> nil)) and ((i = 0) or (Files = 0))) or
     ((not Purge) and (not HardCore) and (DstAddr <> nil) and (Files = 0)) then
  begin
    if not Windows.DeleteFile(PChar(SrcFName)) then
    begin
      SetErrorMsg(SrcFName);
      OK := False;
    end;
  end;
  ForcedRescan := True;
  Result := OK;
end;

function TOutBound.AttachFiles(const Address: TFidoAddress; Files: TStringColl; Status: TOutStatus; KillAction: TKillAction): Boolean;
var
  FOutbound, S, US: String;
  DS: TDosStream;
  L, FoundFiles: TStringColl;
  I: Integer;
  AddNew: Boolean;
begin
  Result := False;
  FOutbound := dOutbound;
  ClearErrorMsg;
  if Files.Count = 0 then Exit;
  S := GetOutFileName(Address, Status);
  DS := CreateDosStreamDir(S, [cRead, cWrite]);
  if DS = nil then Exit;
  L := TStringColl.Create;
  L.LoadFromStream(DS);
  FoundFiles := TStringColl.Create;
  AddNew := False;
  for i := 0 to L.Count-1 do
  begin
    S := L[i];
    GetBinkFileName(S);
    if S = '' then Continue;
    S := MakeFullDir(FOutbound, S);
    FoundFiles.Ins(UpperCase(S));
  end;
  for i := 0 to Files.Count-1 do
  begin
    S := Files[i]; US := UpperCase(S);
    if FoundFiles.Found(US) then Continue;
    AddNew := True;
    L.Add(SKillActionA[KillAction]+S);
  end;
  FreeObject(FoundFiles);
  if AddNew then
  begin
    DS.Position := 0;
    L.SaveToStream(DS);
    DS.Truncate;
  end;
  FreeObject(L);
  FreeObject(DS);
  ForcedRescan := True;
  Result := True;
end;


procedure TOutBound.RewriteFREQ;
  var FN: String;
begin
  FN := GetOutFileName(Address, osRequest);
  Windows.DeleteFile(PChar(FN));
  if (Files <> nil) and (Files.Count > 0) then
     try
       CreateDirInheritance(ExtractFilePath(FN));
       Files.SaveToFile(FN)
     except end;
end;


function ScanBinkAttach(const Status: TOutStatus; const Address: TFidoAddress; const FName, FOutbound: string; L: TOutFileColl; AFileNames: TStringColl; AFileInfos: TFileInfoColl): Boolean;
var
  T: TTextReader;
  S: String;
  Nfo: TFileInfo;
  ks: TKillAction;
  F: TOutFile;
  e: Integer;
  b: Boolean;
begin
  Result := True;
  T := CreateTextReader(FName + SAttachExt[Status]);
  if T = nil then
  begin
    if GetLastError = ERROR_FILE_NOT_FOUND then ClearErrorMsg;
    Exit;
  end;

  while not T.EOF do
  begin
    S := T.GetStr;
    ks := GetBinkFileName(S);
    if S = '' then Continue;
    S := MakeFullDir(FOutbound, S);

    if (AFileNames = nil) or (AFileInfos = nil) then b := False else
    begin
      b := AFileNames.Search(@S, e);
      if b then Nfo := PFileInfo(AFileInfos[e])^;
    end;
    if not b then b := GetFileNfo(S, Nfo, False);
    if b then
    begin
      F := TOutFile.Create;
      F.Error := 0;
      F.Name := StrAsg(S);
      F.Nfo := Nfo;
      F.KillAction := ks;
      F.Address := Address;
      F.FStatus := Status;
      L.Insert(F);
    end else
    begin
      e := GetLastError;
      SetErrorMsg(S);
      F := TOutFile.Create;
      F.Error := e;
      F.Name := StrAsg(S);
      F.Address := Address;
      F.FStatus := Status;
      L.Insert(F);
    end;
  end;
  FreeObject(T);
  Result := False;
end;


procedure AddFile(A: TOutStatus; KA: TKillAction; const Address: TFidoAddress; L: TOutFileColl; const FName: string; AFileNames: TStringColl; AFileInfos: TFileInfoColl);
var
  Nfo: TFileInfo;
  s: string;
  F: TOutFile;
  b: Boolean;
  e: Integer;
begin
  s := FName + SAttachExt[A];

  if (AFileNames = nil) or (AFileInfos = nil) then b := False else
  begin
    b := AFileNames.Search(@S, e);
    if b then Nfo := PFileInfo(AFileInfos[e])^;
  end;
  if not b then b := GetFileNfo(S, Nfo, False);

  if b then
  begin
    F := TOutFile.Create;
    F.Name := StrAsg(s);
    F.Nfo := Nfo;
    F.KillAction := KA;
    F.Address := Address;
    F.FStatus := A;
    L.Insert(F);
  end;
end;


procedure DoGetOutbound(const FName, FOutbound: string; L: TOutFileColl; const Address: TFidoAddress; const Status: TOutStatusSet; AFileNames: TStringColl; AFileInfos: TFileInfoColl);
const
  osa: array[0..9] of record a: TOutStatus; b: Boolean; c: TKillAction end = (
  (a: os_CrashMail;   b: True;  c: kaBsoKillAfter),
  (a: os_DirectMail;  b: True;  c: kaBsoKillAfter),
  (a: osNormalMail;   b: True;  c: kaBsoKillAfter),
  (a: osHoldMail;     b: True;  c: kaBsoKillAfter),
  (a: os_Crash;       b: False; c: kaBsoNothingAfter),
  (a: os_Direct;      b: False; c: kaBsoNothingAfter),
  (a: osNormal;       b: False; c: kaBsoNothingAfter),
  (a: osHold;         b: False; c: kaBsoNothingAfter),
  (a: osHreq;         b: False; c: kaBsoNothingAfter),
  (a: osRequest;      b: True;  c: kaBsoNothingAfter));
var
  i: Integer;
begin
  for i := Low(osa) to High(osa) do if osa[i].a in Status then
  begin
    if osa[i].b then
    begin
      AddFile(osa[i].a, osa[i].c, Address, L, FName, AFileNames, AFileInfos);
    end else
    begin
      ScanBinkAttach(osa[i].a, Address, FName, FOutbound, L, AFileNames, AFileInfos);
    end;
  end;
end;

type
  TgfbPosMacro = class
    FPos: Integer;
    FDirMacro: TDirMacro;
  end;

  TFileBoxUnparsedRecord = class
    a: Ta4s;
    Status: TOutStatus;
    Name: string;
  end;

function GetFileBoxDirColl(const AAddr, ADir: string; AStatus: TOutStatus; AColl: TFileBoxDirColl; PErrorMsg: PString; AMoveTo: PString; AKillAction: PKillAction): Boolean;
var
  re: TPcre;
  Match, NeedPass2, IsRegExp: Boolean;
  CopyRE: Integer;
  LoChar, c: Char;
  v: DWORD;
  AuxAddr, a, aa: Ta4s;
  m: TDirMacro;
  Mask, SearchMask, s, z, k, n: string;
  r: TFileBoxDirRecord;
  FStatus: TOutStatus;
  Addr: TFidoAddress;
  i, j: Integer;
  IdxFirst, IdxLast: Integer;
  MPcoll: TColl;
  MPrec: TgfbPosMacro;
  SR: TuFindData;
  FbuR: TFileBoxUnparsedRecord;
  FbuC: TColl;

procedure AE(const s: string);
begin
  if PErrorMsg = nil then Exit;
  if PErrorMsg^ <> '' then PErrorMsg^ := PErrorMsg^+', ';
  PErrorMsg^ := PErrorMsg^ + s;
end;


function Add: Boolean;
begin
  Result := True;
  if AColl.Search(@s, I) then
  begin
    if PErrorMsg <> nil then
    begin
      r := AColl[I];
      PErrorMsg^ := FormatLng(rsOutbSameFBox, [AAddr, OutStatus2Char(AStatus), Addr2Str(r.Addr), OutStatus2Char(r.Status), s]);
    end;
    Result := False;
  end else
  begin
    if not A4s2Addr(a, Addr) then
    begin
      if PErrorMsg <> nil then
      begin
        PErrorMsg^ := '';
        if a[1] = '*' then AE('zone');
        if a[2] = '*' then AE('net');
        if a[3] = '*' then AE('node');
        if a[4] = '*' then AE('point');
        if PErrorMsg <> nil then PErrorMsg^ := FormatLng(rsOutbNoMacroX, [PErrorMsg^]);
      end;
      Result := False;
      Exit;
    end;
    if (AStatus = osNone) then
    begin
      if PErrorMsg <> nil then PErrorMsg^ := LngStr(rsOutbNoMacroS);
      Result := False;
      Exit;
    end;
    r := TFileBoxDirRecord.Create;
    r.Addr := Addr;
    r.Status := AStatus;
    r.Path := s;
    if AMoveTo <> nil then r.MoveTo := AMoveTo^;
    if AKillAction <> nil then r.KillAction := AKillAction^;
    AColl.AtInsert(I, r);
  end;
end;

begin
  IdxLast := 0;   // to avoid uninitialized
  IdxFirst := 0;  // to avoid warning
  LoChar := #0;   // to avoid warning
  Result := False;
  IsRegExp := False;
  MPColl := nil;
  RE := nil;
  if not SplitAddress(AAddr, a, True) then Exit;
  repeat
    NeedPass2 := False;
    s := StrQuotePartEx(ADir, '~', #3, #4);
    if (not IsRegExp) and (s <> ADir) then
    begin
      IsRegExp := True;
      Continue;
    end;

    z := s;
    repeat
      s := ReplaceDirMacro(z, nil, nil, [rmkAddr, rmkStatus, rmkOnce], @m);
      if s = z then
      begin
        Result := Add;
        Exit;
      end;
      z := s;
      s := StrQuotePartEx(s, '~', #3, #4);
      if (not IsRegExp) and (s <> z) then
      begin
        IsRegExp := True;
        NeedPass2 := True;
        Break;
      end;
      z := s;
      i := Pos(#1, s);
      IdxFirst := i;
      while (IdxFirst > 0) and (s[IdxFirst] <> '\') do Dec(IdxFirst);
    until IdxFirst > 0;
    if NeedPass2 then Continue;
    IdxLast := i;
    while (IdxLast <= Length(s)) and (s[IdxLast] <> '\') do Inc(IdxLast);
    z := Copy(s, IdxFirst+1, IdxLast - IdxFirst-1);
    if not IsRegExp then IsRegExp := Pos('*', z) > 0;

    repeat
      case m of
        dmZONE,
        dmNET,
        dmNODE,
        dmPOINT:
          begin
            case m of
              dmZONE:  j := 1;
              dmNET:   j := 2;
              dmNODE:  j := 3;
              {dmPOINT:} else j := 4;  // to avoid uninitialized warning
            end;
            Mask := a[j];
            if (Mask = '*') and (z[Length(z)] <> #1) then
            begin
              if not IsRegExp then
              begin
                IsRegExp := True;
                if CollCount(MpColl) > 0 then
                begin
                  FreeObject(MPColl);
                  NeedPass2 := True;
                  Break;
                end;
              end;
            end;
          end;
        dmXZONE:
          if a[1] = '*' then Mask := '??' else Mask := H32_2(Vl(a[1]));
        dmXPOINT:
          if a[4] = '*' then Mask := '??' else Mask := H32_2(Vl(a[4]));
        dmHZONE:
          if a[1] = '*' then Mask := '???' else Mask := Hex3(Vl(a[1]));
        dmXNET:
          if a[2] = '*' then Mask := '???' else Mask := H32_3(Vl(a[2]));
        dmXNODE:
          if a[3] = '*' then Mask := '???' else Mask := H32_3(Vl(a[3]));
        dmHNET:
          if a[2] = '*' then Mask := '????' else Mask := Hex4(Vl(a[2]));
        dmHNODE:
          if a[3] = '*' then Mask := '????' else Mask := Hex4(Vl(a[3]));
        dmHPOINT:
          if a[4] = '*' then Mask := '????' else Mask := Hex4(Vl(a[4]));
        dmSTATUS:
          if AStatus = osNone then Mask := '?' else Mask := OutStatus2Char(AStatus);
        dmTSTATUS:
          if AStatus = osNone then
          begin
            if (z[Length(z)] <> #1) then
            begin
              if PErrorMsg <> nil then
              begin
                PErrorMsg^ := LngStr(rsOutbVlSm);
              end;
              Exit;
            end;
            Mask := '*';
          end else Mask := OutStatus2StrTMail(AStatus);
      end;

      j := Pos(#1, z);
      Delete(z, j, 1);

      if (Mask = '*') or (Pos('?', Mask) > 0) then
      begin
        if IsRegExp then Mask := #2;
        MPrec := TgfbPosMacro.Create;
        MPrec.FPos := j;
        MPRec.FDirMacro := m;
        if MPColl = nil then MPColl := TColl.Create;
        MPColl.Add(MPrec);
      end;

      Insert(Mask, z, j);

      i := 0;
      repeat
        k := ReplaceDirMacro(z, nil, nil, [rmkAddr, rmkStatus, rmkOnce], @m);
        if k = z then Break;
        i := Pos(#1, k);
        z := k;
      until i > 0;

    until i = 0;

  until not NeedPass2;

  k := Copy(s, 1, IdxFirst);

  FbuC := TColl.Create;

  if CollCount(MPColl) = 0 then
  begin
    FBuR := TFileBoxUnparsedRecord.Create;
    FBuR.a := a;
    FBuR.Status := AStatus;
    FBuR.Name := z;
    FBuC.Add(FBuR);
  end else
  begin
    if not IsRegExp then SearchMask := z else
    begin
      CopyRE := 0;
      SearchMask := '$'; // Match the end of the line
      j := CollMax(MPColl);
      for i := Length(z) downto 1 do
      begin
        c := z[i];
        case CopyRE of
          0:
            begin
              n := '';
              case c of
                #4: SearchMask := '~' + SearchMask;
                #3: CopyRE := 3;
                #2:
                   begin
                    MPRec := MPColl[j]; Dec(j);
                    case MPREc.FDirMacro of
                      dmZONE,
                      dmNET,
                      dmNODE,
                      dmPOINT:  n := '\d{1,5}';
                      dmXZONE,
                      dmXPOINT: n := '[a-vA-V0-9]{2}';
                      dmHZONE:  n := '[a-fA-F0-9]{3}';
                      dmXNET,
                      dmXNODE:  n := '[a-vA-V0-9]{3}';
                      dmHNET,
                      dmHNODE,
                      dmHPOINT: n := '[a-fA-F0-9]{4}';
                      dmSTATUS: n := '[CDNHcdnh]';
                      dmTSTATUS: n := '[CDNHcdnh]{0,1}';
                    end;
                    //if Pos('(', n) = 0 then
                    n := '('+n+')';
                  end;
                '*': n := '.*';
                '?': n := '.';
                'a'..'z', 'A'..'Z', '0'..'9': n := c;
                else n := '\x'+Hex2(Byte(c));
              end;
              SearchMask := n + SearchMask;
            end;
{          1:
            begin
              HiChar := c; CopyRE := 2;
            end;}
          2:
            begin
              SearchMask := Char(VlH(c+LoChar)) + SearchMask; CopyRE := 3;
            end;
          3:
            begin
              if c = #3 then
              CopyRE := 0
              else begin LoChar := c; CopyRe := 2 end;
            end;
        end;
      end;
      z := '(?i)^'+SearchMask;
      SearchMask := '*.*';
    end;
    if uFindFirstEx(k+SearchMask, SR, FindExSearchLimitToDirectories) then
    begin
      repeat
        v := INVALID_VALUE; if SR.Info.Attr and FILE_ATTRIBUTE_DIRECTORY <> 0 then
        begin
          n := SR.FName;
          if (n <> '.') and (n <> '..') then
          begin
            Match := True;
            if IsRegExp then
            begin
              if RE = nil then RE := GetRegExpr(z);
              Match := (RE.ErrPtr = 0) and (RE.Match(n) > 0) and (RE[0] <> '');
            end;
            if Match then
            begin            
              aa := a;
              FStatus := AStatus;
              for i := 0 to CollMax(MPColl) do
              begin
                MPRec := MPColl[i];
                m := MPRec.FDirMacro;
                if IsRegExp then Mask := RE[i+1] else
                begin
                  j := MPRec.FPos;
                  case m of
                    dmZONE, dmNET, dmNODE, dmPOINT:
                      Mask := CopyLeft(n, j);
                    dmSTATUS, dmTSTATUS:
                      Mask := Copy(n, j, 1);
                    dmXZONE, dmXPOINT:
                      Mask := Copy(n, j, 2);
                    dmHZONE, dmXNET, dmXNODE:
                      Mask := Copy(n, j, 3);
                    dmHNET, dmHNODE, dmHPOINT:
                      Mask := Copy(n, j, 4);
                  end;
                end;
                v := INVALID_VALUE;
                case m of
                  dmSTATUS:
                    begin
                      if Mask = '' then FStatus := osError else FStatus := Char2OutStatus(Mask[1]);
                      if FStatus = osError then Break else v := 0;
                    end;
                  dmTSTATUS:
                    begin
                      if Mask = '' then FStatus := osNormal else
                      begin
                        FStatus := Char2OutStatus(Mask[1]);
                        if FStatus = osNormal then FStatus := osError;
                      end;
                      if FStatus = osError then Break else v := 0;
                    end;
                  dmZONE..dmXPOINT:
                    begin
                      case m of
                        dmZONE, dmNET, dmNODE, dmPOINT:
                          v := Vl(Mask);
                        dmHZONE, dmHNET, dmHNODE, dmHPOINT:
                          v := VlH(Mask);
                        dmXZONE, dmXNET, dmXNODE, dmXPOINT:
                          v := VlX(Mask);
                      end;
                      if v = INVALID_VALUE then Break;
                      case m of
                        dmZONE, dmHZONE, dmXZONE:
                          j := 1;
                        dmNET, dmHNET, dmXNET:
                          j := 2;
                        dmNODE, dmHNODE, dmXNODE:
                          j := 3;
                        dmPOINT, dmHPOINT, dmXPOINT:
                          j := 4;
                        else
                        begin
                          j := GlobalFail('%s', ['GetFileBoxDirColl'])
                        end;
                      end;
                      aa[j] := IntToStr(v);
                    end;
                end;
              end;
              if (v <> INVALID_VALUE) and SplitAddress(A4sToAddrStr(aa), AuxAddr, True) and PureAddressMasks(AuxAddr) then
              begin
                FBuR := TFileBoxUnparsedRecord.Create;
                FBuR.a := aa;
                FBuR.Status := FStatus;
                FBuR.Name := n;
                FBuC.Add(FBuR);
              end;
            end;
          end;
        end;
      until not uFindNext(SR);
      uFindClose(SR);
    end;
    if RE <> nil then
    begin
      RE.Unlock;
      RE := nil;
    end;
//    FreeObject(RE);
  end;
  FreeObject(MPColl);
  Mask := CopyLeft(s, IdxLast);
  Result := True;
  for i := 0 to FBuC.Count-1 do
  begin
    FBuR := FBuC[i];
    if not GetFileBoxDirColl(A4sToAddrStr(FBuR.a), k+FBuR.Name+Mask, FBuR.Status, AColl, PErrorMsg, AMoveTo, AKillAction) then
    begin
      Result := False;
      Break;
    end;
  end;
  FreeObject(FBuC);
end;


function TFileBoxDirColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Compare := CompareStr(PString(Key1)^, PString(Key2)^);
end;

function TFileBoxDirColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TFileBoxDirRecord(Item).Path;
end;


function TOutBound.GetOutbound;

var
  L: TOutFileColl;

procedure ScanBinkleyOutboud;
var
  FName: string;
  FOutbound: string;
begin
  FName := GetOutFileName(Address, osNone);
  FOutbound := dOutbound;
  case DirExists(ExtractFilePath(FName)) of
   -1 : SetErrorMsg(ExtractFilePath(FName));
    0 : ;
    1 : DoGetOutbound(FName, FOutbound, L, Address, Status, AFileNames, AFileInfos);
  end;
end;

procedure ScanFileBoxes;

procedure CheckStatus(AStatus: TOutStatus; const APath, AMoveToDir: string; AKillAction: TKillAction);
var
  SR: TuFindData;
  F: TOutFile;
begin
  if not (AStatus in Status) then Exit;
  if not uFindFirst(MakeNormName(APath, '*.*'), SR) then Exit;
  repeat
    if SR.Info.Attr and FAttachDisallowedAttr = 0 then
    begin
      F := TOutFile.Create;
      F.Name := MakeNormName(APath, SR.FName);
      F.Nfo := SR.Info;
      F.KillAction := AKillAction;
      F.Address := Address;
      F.FStatus := AStatus;
      F.MoveTo := StrAsg(AMoveToDir);
      L.Insert(F);
    end;
  until not uFindNext(SR);
  uFindClose(SR);
end;

var
  fbdc: TFileBoxDirColl;
  fbdr: TFileBoxDirRecord;
  fbc: TFileBoxCfgColl;
  fb: TFileBoxCfg;
  i: Integer;
  FMoveTo: string;
  ka: TKillAction;
begin
  CfgEnter;
  if not Cfg.FileBoxes.Copied then
  begin
    FreeObject(FFileBoxes);
    FFileBoxes := Cfg.FileBoxes.Copy;
  end;
  CfgLeave;
  fbc := FFileBoxes;

  fbdc := TFileBoxDirColl.Create;

  for i := 0 to fbc.Count-1 do
  begin
    fb := fbc[i];
    if (not MatchMaskAddress(Address, fb.FAddr)) then Continue;
    FMoveTo := fb.Dir(fbc.DefaultDir, 1);
    ka := fb.KillAction;
    GetFileBoxDirColl(Addr2Str(Address), fb.Dir(fbc.DefaultDir, 0), fb.FStatus, fbdc, nil, @FMoveTo, @ka);
  end;

  for i := 0 to fbdc.Count-1 do
  begin
    fbdr := fbdc[i];
    CheckStatus(fbdr.Status, fbdr.Path, fbdr.MoveTo, fbdr.KillAction);
  end;
  FreeObject(fbdc);

end;

var
  Local, Locked, ScanAllowed: Boolean;

begin
  ClearErrorMsg;
  if AC = nil then L := TOutFileColl.Create else L := AC;
  ScanAllowed := True;
  Locked := False;
  if ALock then
  begin
    Locked := LockEx(Address, Local);
    if (not Local) then ScanAllowed := False;
  end;
  if ScanAllowed then
  begin
    ScanBinkleyOutboud;
    ScanFileBoxes;
  end;
  if Locked then Unlock(Address);
  if (AC = nil) and (L.Count = 0) then FreeObject(L);
  Result := L;
end;

function CompareOutNodes(P1, P2: Pointer): Integer;
begin
  Result := CompareAddrs(TOutNode(P1).Address, TOutNode(P2).Address);
end;


function  TOutbound.Lock(const Address: TFidoAddress): Boolean;
var
  Local: Boolean;
begin
  Result := LockEx(Address, Local);
end;

function  TOutbound.LockEx(const Address: TFidoAddress; var Local: Boolean): Boolean;
var
  Count: Integer;
  b: TBusyFlag;
begin
  ClearErrorMsg;
  Result := False;
  Local := False;
  BusyFlags.Enter;
  for Count := BusyFlags.Count-1 downto 0 do
  begin
    b := BusyFlags[Count];
    if CompareAddrs(b.Address, Address) = 0 then
    begin
      if TimerInstalled(b.Time) and TimerExpired(b.Time) then
      begin
        BusyFlags.AtFree(Count);
        Break
      end else
      begin
        BusyFlags.Leave;
        Local := b.FHandle <> INVALID_HANDLE_VALUE;
        Exit
      end;
    end;
  end;

  b := TBusyFlag.Create(GetOutFileName(Address, osBusy), SimpleBSY);
  b.Address := Address;
  if b.FHandle = INVALID_HANDLE_VALUE then
  begin
    if GetLastError <> ERROR_FILE_EXISTS then SetErrorMsg(b.FName);
    NewTimerSecs(b.Time, 5);
  end else
  begin
    ClearTimer(b.Time);
    Local := True;
    Result := True;
  end;

//  b.Handle := Handle;
  BusyFlags.Insert(b);
  BusyFlags.Leave;

end;

procedure TOutbound.Unlock(const Address: TFidoAddress);

procedure DoUnlock;
var
  h: Integer;
  b: TBusyFlag;
begin
  for h := 0 to BusyFlags.Count-1 do
  begin
    b := BusyFlags[h];
    if CompareAddrs(b.Address, Address) = 0 then
    begin
      b.Finish;
      BusyFlags.FFree(b);
      Exit;
    end;
  end;
end;

begin
  BusyFlags.Enter;
  DoUnlock;
  BusyFlags.Leave;
end;

procedure InitFidoOut;
begin
  FidoOut := TOutbound.Create;
end;

procedure DoneFidoOut;
begin
  FreeObject(FidoOut);
end;

constructor TLockFile.Create;
const
  Flags: array[Boolean] of TCreateFileModeSet = ([cFlag], [cEnsureNew, cShareDenyRead]);
begin
  inherited Create;
  FName := AFName;
  FCompatibleDelete := ACompatibleDelete;
  FHandle := _CreateFileDir(FName, Flags[FCompatibleDelete]);
end;

procedure TLockFile.Finish;
begin
  if FHandle = INVALID_HANDLE_VALUE then Exit;
  ZeroHandle(FHandle);
  if FCompatibleDelete then Windows.DeleteFile(PChar(FName));
end;

procedure TBusyFlag.Finish;
begin
  inherited Finish;
  DeleteEmptyDirInheritance(ExtractFileDir(FName), dOutbound);
end;

destructor TLockFile.Destroy;
begin
  Finish;
  inherited Destroy;
end;


procedure TFileInfoColl.FreeItem(Item: Pointer);
begin
  Dispose(PFileInfo(Item));
end;

procedure TOutFileColl.PurgeDuplicates;
var
  SC: TStringColl;
  f: TOutFile;
  i, j: Integer;
begin
  SC := TStringColl.Create;
  SC.IgnoreCase := True;
  for i := 0 to Count - 1 do
  begin
    f := At(i);
    if SC.Search(@f.Name, j) then
    begin
      FreeObject(f);
      AtPut(i, nil);
    end else SC.AtInsert(j, NewStr(f.Name));
  end;
  FreeObject(SC);
  Pack;
end;


function TOutFileColl.Copy: Pointer;
begin
  Result := TOutFileColl.Create;
  CopyItemsTo(TOutFileColl(Result));
end;


function TOutFileColl.FoundFName(const FName: string): Boolean;
var
  us: string;
  i: Integer;
  r: TOutFile;
begin
  us := UpperCase(FName);
  Result := False;
  for i := 0 to Count-1 do
  begin
    r := At(i);
    if us = UpperCase(r.Name) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TOutFileColl.GetNamesColl: TStringColl;
var
  i: Integer;
begin
  if Count = 0 then Result := nil else
  begin
    Result := TStringColl.Create;
    for i := 0 to Count-1 do Result.Add(StrAsg(TOutFile(At(i)).Name));
  end;
end;


function GetOutStatus(const Xt: string): TOutStatus;
var
  US: string;
  S: TOutStatus;
begin
  Result := osNone;
  US := UpperCase(Xt);
  for S := Succ(Low(TOutStatus)) to Pred(High(TOutStatus)) do
   if US = SAttachExt[S] then
   begin
     Result := S;
     Exit;
   end;
end;

constructor TOutNodeColl.Create;
begin
  inherited Create;
  Duplicates := True;
end;


function TOutNodeColl.Copy;
begin
  Result := TOutNodeColl.Create;
  CopyItemsTo(TOutNodeColl(Result));
end;


procedure AddAddrOutNode(const Addr: TFidoAddress; A: TOutStatus; AOutColl: TOutNodeColl; ASize, ATime: DWORD);
var
  I: Integer;
  T: TOutNode;
begin
  if AOutColl.Search(@Addr, I) then
  begin
    T := AOutColl[I];
    T.Nfo.Size := ASize + T.Nfo.Size;
    T.Nfo.Time := MaxD(ATime, T.Nfo.Time);
    Include(T.FStatus, A);
  end else
  begin
    T := TOutNode.Create;
    T.Address := Addr;
    T.Nfo.Size := ASize;
    T.Nfo.Time := ATime;
    GetListedNode(Addr);
    T.FStatus := [A];
    AOutColl.AtInsert(I, T);
  end;
end;

procedure DoAddOutNode(const Path, FName: string; S: TOutStatus; Zone, Net, Node: Integer; Point: Boolean; OutColl: TOutNodeColl; AErase: Boolean; ASize, ATime: DWORD);
var
  I: DWORD;
begin
  I := VlH(Copy(FName, 1, 8)); if (I = INVALID_VALUE) then Exit;
  if AErase then
  begin
    Windows.DeleteFile(PChar(MakeNormName(Path, FName)));
  end else
  begin
    if Point then
    begin
      if I > $FFFF then Exit;
    end else
    begin
      Net := I shr 16;
      Node := I and $FFFF;
      I := 0;
    end;
    AddAddrOutNode(FidoAddress(Zone, Net, Node, I and $FFFF), S, OutColl, ASize, ATime);
  end;
end;



function TOutbound._GetOutColl: TOutNodeColl;
var
  OutColl: TOutNodeColl;
  CurTime: DWORD;
  Net, Node: Integer;
  FileNames: TStringColl;
  FileInfos: TFileInfoColl;

procedure ScanDir(const Path: string; Zone: Integer; Point: Boolean);
var
  SR: TuFindData;
  ss, Dr, Nm, Xt: string;
  Nfo: PFileInfo;
  S: TOutStatus;
  II: Integer;
  I: DWORD;

procedure _Add(MaxAge: DWORD);
var
  k: Boolean;
begin
  k := (MaxAge <> INVALID_FILE_SIZE) and (SR.Info.Time + MaxAge < CurTime);
  DoAddOutNode(Path, SR.FName, S, Zone, Net, Node, Point, OutColl, k, SR.Info.Size, SR.Info.Time);
end;

begin
  if uFindFirst(MakeNormName(Path,'*.*'), SR) then
  begin
    repeat
      FSplit(SR.FName, Dr, Nm, Xt);
      if SR.Info.Attr and FILE_ATTRIBUTE_DIRECTORY = 0 then
      begin
        S := GetOutStatus(Xt);
        case S of
          osBusy :
            _Add(6*3600);
          osHReq :
            _Add(3*24*3600);
          os_Crash, os_Direct, osNormal, osHold:
            _Add(INVALID_FILE_SIZE);
          osRequest:
            _Add(INVALID_FILE_SIZE);
          os_CrashMail, os_DirectMail, osNormalMail, osHoldMail:
            _Add(INVALID_FILE_SIZE);
          osNone:
            begin
              ss := MakeNormName(Path, SR.FName);
              FileNames.Search(@ss, II);
              FileNames.AtInsert(II, NewStr(StrAsg(ss)));
              New(Nfo); Nfo^ := SR.Info;
              FileInfos.AtInsert(II, Nfo);
            end;
          else
          GlobalFail('TOutbound._GetOutColl | ScanDir("%s", %d, ...)', [Path, Zone]);
        end;
      end else
      if (not Point) and (UpperCase(Xt)='.PNT') then
      begin
        I := VlH(Copy(SR.FName, 1, 8));
        if I = INVALID_VALUE then Continue;
        Net := I shr 16;
        Node := I and $FFFF;
        ScanDir(MakeNormName(Path, SR.FName), Zone, True);
      end;

    until not uFindNext(SR);
    uFindClose(SR);
  end;
end;

var
  S, Dr, Nm, Xt: string;
  SR: TuFindData;
  i: DWORD;
  ii: Integer;
  n: TOutNode;
  Nfo: TFileInfo;
  fbc: TFileBoxCfgColl;
  fb: TFileBoxCfg;
  fbdc: TFileBoxDirColl;
  fbdr: TFileBoxDirRecord;
begin
  CurTime := uGetSystemTime;
  ClearErrorMsg;
  OutColl := TOutNodeColl.Create;

  FileNames := TStringColl.Create;
  FileNames.IgnoreCase := True;
  FileInfos := TFileInfoColl.Create;

  S := ExtractDir(dOutbound);
  FSplit(S, Dr, Nm, Xt);
  if DirExists(S) <> 1 then SetErrorMsg(S) else
  begin
    ScanDir(S, DefaultZone, False);
    if uFindFirstEx(Dr+Nm+'.???', SR, FindExSearchLimitToDirectories) then
    begin
      repeat
        if SR.Info.Attr and FILE_ATTRIBUTE_DIRECTORY <> 0 then
        begin
          I := VlH(Copy(SR.FName, Length(Nm)+2, 3));
          if I <> INVALID_VALUE then ScanDir(Dr+SR.FName, I, False);
        end;
      until not uFindNext(SR);
      uFindClose(SR);
    end;
  end;

  for ii := 0 to FileNames.Count-1 do
  begin
    s := FileNames[ii];
    Nfo := PFileInfo(FileInfos[ii])^;
    n := TOutNode.Create;
    n.Address.Zone := -1;
    n.Nfo.Size := Nfo.Size;
    n.Nfo.Time := Nfo.Time;
    n.Name := StrAsg(s);
    n.FStatus := [osNone];
    OutColl.AtInsert(0, n);
  end;

  FreeObject(FileNames);
  FreeObject(FileInfos);

  {}
  fbdc := TFileBoxDirColl.Create;

  fbc := FFileBoxes;
  for ii := 0 to fbc.Count-1 do
  begin
    fb := fbc[ii];
    GetFileBoxDirColl(fb.FAddr, fb.Dir(fbc.DefaultDir, 0), fb.FStatus, fbdc, nil, nil, nil);
  end;

  for ii := 0 to fbdc.Count-1 do
  begin
    fbdr := fbdc[ii];
    if uFindFirst(MakeNormName(fbdr.Path, '*.*'), SR) then
    begin
      repeat
        if SR.Info.Attr and FAttachDisallowedAttr = 0 then
        begin
          AddAddrOutNode(fbdr.Addr, fbdr.Status, OutColl, SR.Info.Size, SR.Info.Time);
        end;
      until not uFindNext(SR);
      uFindClose(SR);
    end;
  end;

  FreeObject(fbdc);

  if OutColl.Count = 0 then FreeObject(OutColl);
  Result := OutColl;
end;

function TOutNodeColl.Compare(Key1, Key2: Pointer): Integer;
begin
  Result := CompareAddrs(TFidoAddress(Key1^), TFidoAddress(Key2^));
end;

function TOutNodeColl.KeyOf(Item: Pointer): Pointer;
begin
  Result := @TOutNode(Item).Address;
end;

destructor TOutNode.Destroy;
begin
  FreeObject(Files);
  inherited Destroy;
end;

function TOutNode.Copy;
var
  n: TOutNode;
begin
  n := TOutNode.Create;
  n.Address := Address;
  n.Nfo.Size := Nfo.Size;
  n.Nfo.Time := Nfo.Time;
  n.FStatus := FStatus;
  n.Name := StrAsg(Name);
  if Files <> nil then n.Files := Files.Copy;
  Result := n;
end;


function TOutbound.GetOutNode(const Addr: TFidoAddress): TOutNode;
var
  n: TOutNodeColl;
begin
  Result := nil;
  n := _GetOutCollP(True, False, Addr);
  if n <> nil then
  begin
    if n.Count <> 1 then GlobalFail('TOutbound.GetOutNode(%s) n.Count=%d', [Addr2Str(Addr), n.Count]);
    Result := n[0];
    n.DeleteAll;
    FreeObject(n);
  end;
end;

function TOutbound.GetOutColl;
begin
  Result := _GetOutCollP(False, AFull, FidoAddress(-1, 0, 0, 0));
end;

function TOutbound._GetOutCollP(Single, AFull: Boolean; const Addr: TFidoAddress): TOutNodeColl;

function GetIt: TOutNodeColl;
var
  i: Integer;
  n: TOutNode;
begin
  if OutCache = nil then Result := nil else
  begin
    if AFull then Result := OutCache.Copy else
    begin
      Result := TOutNodeColl.Create;
      for i := 0 to OutCache.Count-1 do
      begin
        n := OutCache[i];
        if Single and (CompareAddrs(Addr, n.Address) <> 0) then Continue;
        if n.FStatus <> [osNone] then
        Result.AtInsert(Result.Count, n.Copy);
      end;
    end;
  end;
end;


begin
  CfgEnter;
  if not Cfg.FileBoxes.Copied then
  begin
    FreeObject(FFileBoxes);
    FFileBoxes := Cfg.FileBoxes.Copy;
  end;
  CfgLeave;
  EnterCS(CacheCS);
  if (not ForcedRescan) and (TimerInstalled(LastRescan)) and (not TimerExpired(LastRescan)) then
  begin
    Result := GetIt;
  end else
  begin
    ForcedRescan := False;
    FreeObject(OutCache);
    OutCache := _GetOutColl;
    Result := GetIt;
    NewTimerSecs(LastRescan, 20);
  end;
  LeaveCS(CacheCS);
end;

function TOutFile.OutAttType: TOutAttType;
begin
  Result := GetOutAttTypeByKillAction(KillAction);
end;


function TOutFile.Copy: Pointer;
var
  f: TOutFile;
begin
  f := TOutFile.Create;
  f.Error := Error;
  f.Name := StrAsg(Name);
  f.MoveTo := StrAsg(MoveTo);
  f.Nfo.Size := Nfo.Size;
  f.Nfo.Time := Nfo.Time;
  f.KillAction := KillAction;
  f.FStatus := FStatus;
  f.Address := Address;
  Result := f;
end;


function TOutNode.Status: TOutStatus;
begin
  GlobalFail('OutNode %s Status', [Name]);
  Result := osNone;
end;

function TOutNode.StatusSet: TOutStatusset;
begin
  Result := FStatus;
end;

function TOutNode.StatusString: string;
var
  a: string;
  s: TOutStatus;
begin
  SetLength(a, 6); FillChar(a[1], 6, ' ');
  for s := Low(s) to High(s) do
  begin
    if s in FStatus then
    case s of
      osError                  : a[1] := 'E';
      osBusy                   : a[2] := 'B';
      os_CrashMail,  os_Crash  : a[3] := 'C';
      os_DirectMail, os_Direct : a[4] := 'D';
      osNormalMail,  osNormal  : a[5] := 'N';
      osHoldMail,    osHold    : a[6] := 'H';
    end;
  end;
  Result := DelRight(a);
end;

function GetAge(Time: DWORD): string;
var
  SysTime, Age: DWORD;
begin
  if Time = 0 then
  begin
    Result := '';
    Exit;
  end;
  SysTime := uGetSystemTime;
  if SysTime >= Time then
  begin
    Age := SysTime - Time;
    if Age > 2*60*60*24 then Result := Format('%d days', [Age div (60*60*24)]) else
    begin
      Age := Age div 60;
      Result := Format('%2.2d:%2.2d', [Age div 60, Age mod 60]);
    end;
  end else Result := '?';
end;

function OutAttachWeight(S: TOutStatusSet): Integer;
var
  A: Integer;
begin
  A := 0;
  if osError        in S then A := A or $10000;
  if osBusy         in S then A := A or $08000;
  if os_CrashMail   in S then A := A or $04000;
  if os_Crash       in S then A := A or $02000;
  if os_DirectMail  in S then A := A or $01000;
  if os_Direct      in S then A := A or $00800;
  if osRequest      in S then A := A or $00400;
  if osNormalMail   in S then A := A or $00200;
  if osNormal       in S then A := A or $00100;
  if osHReq         in S then A := A or $00080;
  if osHoldMail     in S then A := A or $00040;
  if osHold         in S then A := A or $00020;
  Result := A;
end;

procedure TOutNode.PrepareNfo;
var
  i: Integer;
  Time, Size: DWORD;
  f: TOutFile;
  s: TOutStatusSet;
  os: TOutStatus;
begin
  s := [];
  Time := Nfo.Time;
  Size := 0;
  for i := 0 to CollMax(Files) do
  begin
    f := Files[i];
    Include(s, f.FStatus);
    if f.Error <> 0 then Include(FStatus, osError) else
    begin
      if f.KillAction <> kaBsoNothingAfter then Time := MinD(Time, f.Nfo.Time);
      Inc(Size, f.Nfo.Size);
    end;
  end;
  for os := Low(TOutStatus) to High(TOutStatus) do
  begin
    if (os in FStatus) and (not (os in s)) then
    case os of
      osBusy,
      osError : ;
      else
        if not (osBusy in FStatus) then
        begin
          f := TOutFile.Create;
          f.Address := Address;
          f.FStatus := os;
          if Files = nil then Files := TOutFileColl.Create;
          Files.Add(f);
        end;
     end;
  end;
  Nfo.Time := Time;
  Nfo.Size := Size;
  Nfo.Attr := OutAttachWeight(FStatus);
end;

function TOutNode.ActionString: string;
begin
  Result := '';
end;

function TOutFile.Status: TOutStatus;
begin
  Result := FStatus;
end;

function TOutFile.StatusSet: TOutStatusset;
begin
  GlobalFail('OutFile %s StatusSet', [Name]);
end;

function TOutFile.StatusString: string;
begin
  case FStatus of
    os_CrashMail,  os_Crash  : Result := 'Crash';
    os_DirectMail, os_Direct : Result := 'Direct';
    osNormalMail,  osNormal  : Result := 'Normal';
    osHoldMail,    osHold    : Result := 'Hold';
    else Result := '';
  end;
end;

function TOutFile.ActionString: string;
begin
  case KillAction of
    kaBsoNothingAfter  : Result := '';
    kaBsoKillAfter     : Result := 'O/Kill';
    kaBsoTruncateAfter : Result := 'O/Trunc';
    kaFbKillAfter      : Result := 'F/Kill';
    kaFbMoveAfter      : Result := 'F/Move';
    else Result := '';
  end;
end;

procedure TOutFile.PrepareNfo;
begin
  // Nfo is already prepared
end;

function TOutItem.AgeString: string;
begin
  Result := GetAge(Nfo.Time);
end;

function DeleteOutFile;
var
  s: string;
begin
  s := dOutbound;
  Result := Windows.DeleteFile(PChar(FName));
  if not Result then Exit;
  if StrBegsU(s, UpperCase(FName)) then
  begin
    DeleteEmptyDirInheritance(ExtractFileDir(FName), s);
  end;
end;

end.

