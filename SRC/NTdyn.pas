unit NTdyn;

interface uses Windows;

type
  T_NTdyn_SetProcessShutdownParameters = function(dwLevel, dwFlags: DWORD): BOOL; stdcall;
  T_NTdyn_PolyTextOut         = function(DC: HDC; const PolyTextArray; Strings: Integer): BOOL; stdcall;
  T_NTdyn_FindFirstFileEx     = function(lpFileName: PAnsiChar; fInfoLevelId: TFindexInfoLevels; lpFindFileData: Pointer; fSearchOp: TFindexSearchOps; lpSearchFilter: Pointer; dwAdditionalFlags: DWORD): THandle; stdcall;
  T_NTdyn_GetFileAttributesEx = function(lpFileName: PAnsiChar; fInfoLevelId: TGetFileExInfoLevels; lpFileInformation: Pointer): BOOL; stdcall;
  T_NTdyn_SignalObjectAndWait = function(hObjectToSignal: THandle; hObjectToWaitOn: THandle; dwMilliseconds: DWORD; bAlertable: BOOL): DWORD; stdcall;
  T_NTdyn_GetProcessTimes     = function(hProcess: THandle; var lpCreationTime, lpExitTime, lpKernelTime, lpUserTime: TFileTime): BOOL; stdcall;

var
  NTdyn_SetProcessShutdownParameters : T_NTdyn_SetProcessShutdownParameters;
  NTdyn_PolyTextOut         : T_NTdyn_PolyTextOut;
  NTdyn_FindFirstFileEx     : T_NTdyn_FindFirstFileEx;
  NTdyn_GetFileAttributesEx : T_NTdyn_GetFileAttributesEx;
  NTdyn_SignalObjectAndWait : T_NTdyn_SignalObjectAndWait;
  NTdyn_GetProcessTimes     : T_NTdyn_GetProcessTimes;

procedure LoadNTDyn;

implementation

procedure LoadNTDyn;
var
  KernelHandle: THandle;
  GDIHandle: THandle;
begin
  KernelHandle := GetModuleHandle('kernel32.dll');
  GDIHandle := GetModuleHandle('gdi32.dll');
  NTdyn_SetProcessShutdownParameters := GetProcAddress(KernelHandle, 'SetProcessShutdownParameters');
  NTdyn_PolyTextOut := GetProcAddress(GDIHandle, 'PolyTextOutA');
  NTdyn_FindFirstFileEx := GetProcAddress(KernelHandle, 'FindFirstFileExA');
  NTdyn_GetFileAttributesEx := GetProcAddress(KernelHandle, 'GetFileAttributesExA');
  NTdyn_SignalObjectAndWait := GetProcAddress(KernelHandle, 'SignalObjectAndWait');
  NTdyn_GetProcessTimes := GetProcAddress(KernelHandle, 'GetProcessTimes');
end;

end.

