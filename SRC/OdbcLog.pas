unit OdbcLog;

interface

procedure OdbcLogAdd(const AName: string; C: Char; t: Integer; const CurStr: string);
procedure OdbcLogInitialize;
procedure OdbcLogDone;
function OdbcLogCheckInit(const AErrLogFName: string): Boolean;

implementation uses xBase, OdbcSQL, Windows, SysUtils, Classes;

type
  TOdbcLogRec = class
    AName: ShortString;
    ANameLen: SQLINTEGER;
    C: array[0..1] of Char;
    ACLen: SQLINTEGER;
    t: Integer;
    dsOpenDate: SQL_TIMESTAMP_STRUCT;
    OpenDateLen: SQLINTEGER;
    CurStr: ShortString;
    CurStrLen: SQLINTEGER;
  end;

  TOdbcLogThread = class(T_Thread)
    OdbcLogRecs: TColl;
    ErrLines: TStringColl;
    LogErrFName: string;
    LogErrFHandle: THandle;
    henv: SQLHENV;
    hdbc: SQLHDBC;
    hstmt: SQLHSTMT;
    Again: Boolean;
    oInitialized: THandle;
    oSleep: THandle;
    SuccessExec,
    Connected: Boolean;
    BoundRec: TOdbcLogRec;
    constructor Create;
    procedure InvokeExec; override;
    procedure InvokeDone; override;
    function TryConnect: Boolean;
    destructor Destroy; override;
    procedure AddRecords;
    class function ThreadName: string; override;
    procedure LogErrorMsgs;
    function SqlSuccess(r: SQLRETURN; const FName: string; Fatal: Boolean; HandleType: SQLSMALLINT; Handle: SQLHANDLE): Boolean;
    procedure SQLZeroHandle(HandleType:SQLSMALLINT; var Handle:SQLHANDLE);
  end;

var
  LogThr: TOdbcLogThread;

procedure TOdbcLogThread.LogErrorMsgs;
var
  i: Integer;
  L: TStringColl;
begin
  L := nil;
  ErrLines.Enter;
  if LogErrFName <> '' then
  begin
    for i := 0 to ErrLines.Count-1 do
    begin
      if L = nil then L := TStringColl.Create;
      L.Add(ErrLines[i]);
    end;
    ErrLines.DeleteAll;
  end;
  ErrLines.Leave;
  if L <> nil then
  begin
    for i := 0 to L.Count-1 do
    begin
      if _LogOK(LogErrFName, LogErrFHandle) then _LogWriteStr(L[i], LogErrFHandle);
    end;
    FreeObject(L);
  end;
end;

function TOdbcLogThread.SqlSuccess(r: SQLRETURN; const FName: string; Fatal: Boolean; HandleType: SQLSMALLINT; Handle: SQLHANDLE): Boolean;
var
  s: string;
  rd: SQLRETURN;
  SQLState: array[0..5] of Char;
  SQLStateStr: string;
  NativeError: SQLINTEGER;
  MessageText: array[0..500] of Char;
  MessageTextStr: string;
  TextLength: SQLSMALLINT;
begin
  Result := (r = SQL_SUCCESS) or (r = SQL_SUCCESS_WITH_INFO);
  if not Result then
  begin
    s := Format('! %s %s()=%d', [uFormat(uGetLocalTime), FName, r]);
    if Handle <> SQL_NULL_HANDLE then
    begin
      rd := SQLGetDiagRec(HandleType, Handle, 1, SQLState, NativeError, MessageText, SizeOf(MessageText)-1, TextLength);
      case rd of
        SQL_SUCCESS,
        SQL_SUCCESS_WITH_INFO:
          begin
            SetString(MessageTextStr, MessageText, TextLength);
            SetString(SQLStateStr, SQLState, 5);
            s := s + Format('; SQLSTATE=%s, NativeError=%d, MessageText=%s', [SQLStateStr, NativeError, MessageTextStr]);
          end;
      end;
    end;
    ErrLines.Add(s);
    if Fatal then
    begin
      LogErrorMsgs;
      GlobalFail('%s', [s]);
    end;
  end;
end;

procedure TOdbcLogThread.SQLZeroHandle(HandleType:SQLSMALLINT; var Handle:SQLHANDLE);
begin
  if Handle = 0 then Exit;
  if not SqlSuccess(SQLFreeHandle(HandleType, Handle), 'SQLFreeHandle', True, SQL_NULL_HANDLE, SQL_NULL_HANDLE) then Exit;
  Handle := 0;
end;

procedure OdbcLogAdd(const AName: string; C: Char; t: Integer; const CurStr: string);
var
  r: TOdbcLogRec;
begin
  if LogThr = nil then Exit;
  r := TOdbcLogRec.Create;
  r.AName := AName;
  r.C[0] := C;
  r.t := t;
  r.CurStr := CurStr;
  LogThr.OdbcLogRecs.Enter;
  LogThr.OdbcLogRecs.Add(r);
  LogThr.OdbcLogRecs.Leave;
  SetEvent(LogThr.oSleep);
end;

function TOdbcLogThread.TryConnect: Boolean;
begin
  Result := False;
  if not LoadODBC then Exit;
  if not SqlSuccess(SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, henv), 'SQLAllocHandle', False, SQL_NULL_HANDLE, SQL_NULL_HANDLE) then Exit;
  if not SqlSuccess(SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, SQLPOINTER(SQL_OV_ODBC3), 0), 'SQLSetEnvAttr', False, SQL_HANDLE_ENV, henv) then Exit;
  if not SqlSuccess(SQLAllocHandle(SQL_HANDLE_DBC, henv, hdbc), 'SQLAllocHandle', False, SQL_HANDLE_ENV, henv) then Exit;
  if not SqlSuccess(SQLConnect(hdbc, 'ArgusLog', SQL_NTS, nil, 0, nil, 0), 'SQLConnect', False, SQL_HANDLE_DBC, hdbc) then Exit;
  Connected := True;
  if not SqlSuccess(SQLAllocHandle(SQL_HANDLE_STMT, hdbc, hstmt), 'SQLAllocHandle', False, SQL_HANDLE_DBC, hdbc) then Exit;
  if not SqlSuccess(SQLPrepare(hstmt, 'INSERT INTO LogStrings (Logger, RecTag, RecTime, RecMsg) VALUES (?, ?, ?, ?)', SQL_NTS), 'SQLPrepare', False, SQL_HANDLE_STMT, hstmt) then Exit;
  BoundRec := TOdbcLogRec.Create;
  BoundRec.ANameLen := SQL_NTS;
  BoundRec.ACLen := SQL_NTS;
  BoundRec.C[1] := #0;
  BoundRec.OpenDateLen := 0;
  BoundRec.CurStrLen := SQL_NTS;
  if not SqlSuccess(SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 255, 0, @BoundRec.AName[1], 0, @BoundRec.ANameLen), 'SQLBindParameter', False, SQL_HANDLE_STMT, hstmt) then Exit;
  if not SqlSuccess(SQLBindParameter(hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 1, 0, @BoundRec.C[0],     0, @BoundRec.ACLen), 'SQLBindParameter', False, SQL_HANDLE_STMT, hstmt) then Exit;
  if not SqlSuccess(SQLBindParameter(hstmt, 3, SQL_PARAM_INPUT, SQL_C_TYPE_TIMESTAMP, SQL_TYPE_TIMESTAMP, 0, 0, @BoundRec.dsOpenDate, 0, @BoundRec.OpenDateLen), 'SQLBindParameter', False, SQL_HANDLE_STMT, hstmt) then Exit;
  if not SqlSuccess(SQLBindParameter(hstmt, 4, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR, 255, 0, @BoundRec.CurStr[1], 0, @BoundRec.CurStrLen), 'SQLBindParameter', False, SQL_HANDLE_STMT, hstmt) then Exit;
  Result := True;
end;

procedure TOdbcLogThread.AddRecords;
var
  Local: TColl;
  i: Integer;
  r: TOdbcLogRec;
  ST: TSystemTime;
begin
  Local := nil;
  OdbcLogRecs.Enter;
  for i := 0 to OdbcLogRecs.Count-1 do
  begin
    r := OdbcLogRecs[i];
    if Local = nil then Local := TColl.Create;
    Local.Add(r);
  end;
  OdbcLogRecs.DeleteAll;
  OdbcLogRecs.Leave;
  if Local = nil then Exit;
  for i := 0 to Local.Count-1 do
  begin
    r := Local[i];
    BoundRec.AName := r.AName;
    BoundRec.AName[MinI(254, Length(BoundRec.AName)+1)] := #0;
    BoundRec.C[0] := r.c[0];
    uNix2WinTime(r.T, ST);
    BoundRec.dsOpenDate.Year     := ST.wYear;
    BoundRec.dsOpenDate.Month    := ST.wMonth;
    BoundRec.dsOpenDate.Day      := ST.wDay;
    BoundRec.dsOpenDate.Hour     := ST.wHour;
    BoundRec.dsOpenDate.Minute   := ST.wMinute;
    BoundRec.dsOpenDate.Second   := ST.wSecond;
    BoundRec.dsOpenDate.Fraction := 0;
    BoundRec.CurStr := r.CurStr;
    BoundRec.CurStr[MinI(254, Length(BoundRec.CurStr)+1)] := #0;
    if SqlSuccess(SqlExecute(hstmt), 'SqlExecute', False, SQL_HANDLE_STMT, hstmt) then SuccessExec := True else
    begin
      LogErrorMsgs;
      if not SuccessExec then Terminated := True;
    end;
  end;
  FreeObject(Local);
end;


procedure TOdbcLogThread.InvokeExec;
begin
  if not Again then
  begin
    if not TryConnect then Terminated := True;
    Again := True;
    SetEvt(oInitialized);
  end else
  begin
    WaitEvtInfinite(oSleep);
    AddRecords;
  end;
end;

procedure TOdbcLogThread.InvokeDone;
begin
  SQLZeroHandle(SQL_HANDLE_STMT, hstmt);
  FreeObject(BoundRec);
  if Connected then
  begin
    Connected := False;
    if not SqlSuccess(SQLDisconnect(hdbc), 'SQLDisconnect', True, SQL_HANDLE_DBC, hdbc) then Exit;
  end;
  SQLZeroHandle(SQL_HANDLE_DBC, hdbc);
  SQLZeroHandle(SQL_HANDLE_ENV, henv);
  UnloadODBC;
end;

destructor TOdbcLogThread.Destroy;
begin
  LogErrorMsgs;
  ZeroHandle(oInitialized);
  ZeroHandle(oSleep);
  ZeroHandle(LogErrFHandle);
  FreeObject(OdbcLogRecs);
  FreeObject(ErrLines);
  inherited Destroy;
end;

constructor TOdbcLogThread.Create;
begin
  inherited Create;
  oInitialized := CreateEvtA;
  oSleep := CreateEvtA;
  OdbcLogRecs := TColl.Create;
  ErrLines := TStringColl.Create;
  Priority := tpLower;
end;

procedure OdbcLogDone;
begin
  if LogThr = nil then Exit;
  LogThr.Terminated := True;
  SetEvent(LogThr.oSleep);
  LogThr.WaitFor;
  FreeObject(LogThr);
end;

procedure OdbcLogInitialize;
begin
  LogThr := TOdbcLogThread.Create;
  LogThr.Suspended := False;
end;

function OdbcLogCheckInit(const AErrLogFName: string): Boolean;
begin
  if LogThr <> nil then
  begin
    LogThr.ErrLines.Enter;
    LogThr.LogErrFName := StrAsg(AErrLogFName);
    LogThr.ErrLines.Leave;
    WaitEvtInfinite(LogThr.oInitialized);
    if LogThr.Terminated then
    begin
      LogThr.WaitFor;
      FreeObject(LogThr);
    end;
  end;
  Result := LogThr <> nil;
end;

class function TOdbcLogThread.ThreadName: string;
begin
  Result := 'ODBC Logger';
end;

{
create table LogStrings (
  RecId   counter NOT NULL CONSTRAINT RecIdIndex PRIMARY KEY,
  Logger  char(20) NOT NULL,
  RecTag  char(1) NOT NULL,
  RecTime date NOT NULL,
  RecMsg  char(250) NOT NULL);
}

end.


