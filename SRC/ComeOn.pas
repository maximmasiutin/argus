unit ComeOn;

interface

{$I DEFINE.INC}

procedure Come_On;

implementation

uses
  WSock,
  NTdyn,
  StartWiz, LngTools,
  xDES, MlrForm, MlrThr,
  Forms, SysUtils,
  FTS1, Messages,
  classes,
  NdlUtil, MClasses, 
  xBase, xFido, xIP, xMisc, Recs,

{$IFDEF GRAB}
  Controls, Menus, StdCtrls, ExtCtrls, ComCtrls, MdmCmd,
  Import, AtomEdit, MlineCfg, FreqCfg, DevCfg, LineBits,
  ModemCfg, SelDir, PathName, NodelCfg, FidoPwd, DialRest,
  Attach, DupCfg, StupCfg, Extrnls, Events,
  EvtEdit, TracePl, EncLinks, FidoStat, FileBox, IpCfg,
  FreqEdit, PwdInput, NodeWiz, OvrExpl, PollCfg, SinglPwd,

{$ENDIF}

{$IFDEF SVC}
  AService,
{$ENDIF}

  NodeBrws,

  AdrIBox, OutBound, Windows, OdbcLog;


{$IFDEF GRAB}

{$I Grab.PAS}

procedure GrabForms;

procedure Grab(var Reference; FormClass: TFormClass);
begin
  Application.CreateForm(FormClass, Reference); GrabForm(TForm(Reference){, Format('..\LNG\ENG_%.2d.LNG', [AN])});
end;

var
   ImportForm          : TImportForm;
   AtomEditorForm      : TAtomEditorForm;
   MailerLineCfgForm   : TMailerLineCfgForm;
   FreqCfgForm         : TFreqCfgForm;
   DeviceConfig        : TDeviceConfig;
   FidoAddressInput    : TFidoAddressInput;
   NodelistCompiler    : TNodelistCompiler;
   LineBitsEditor      : TLineBitsEditor;
   ModemEditor         : TModemEditor;
   SelectDirDialog     : TSelectDirDialog;
   PathNamesForm       : TPathNamesForm;
   NodeListCfgForm     : TNodeListCfgForm;
   PwdForm             : TPwdForm;
   RestrictCfgForm     : TRestrictCfgForm;
   MailerForm          : TMailerForm;
   AttachStatusForm    : TAttachStatusForm;
   MainConfigForm      : TMainConfigForm;
   StartupConfigForm   : TStartupConfigForm;
   RegInputForm        : TRegInputForm;
   ExternalsForm       : TExternalsForm;
   UnregForm           : TUnregForm;
   EventsForm          : TEventsForm;
   EvtEditForm         : TEvtEditForm;
   NodelistBrowser     : TNodelistBrowser;
   DisplayInfoForm     : TDisplayInfoForm;
   EncryptedLinksForm  : TEncryptedLinksForm;
   FidoTemplateEditor  : TFidoTemplateEditor;
   FileBoxesForm       : TFileBoxesForm;
   FReqDlg             : TFReqDlg;
   ModemCmdForm        : TModemCmdForm;
   NewPwdInputForm     : TNewPwdInputForm;
   NodeWizzardForm     : TNodeWizzardForm;
   OvrExplainForm      : TOvrExplainForm;
   PollSetupForm       : TPollSetupForm;
   SinglePasswordForm  : TSinglePasswordForm;
   StartWizzardForm    : TStartWizzardForm;
   IPcfgForm           : TIPcfgForm;
begin
  Grab(ImportForm          , TImportForm                     );
  Grab(AtomEditorForm      , TAtomEditorForm                 );
  Grab(MailerLineCfgForm   , TMailerLineCfgForm              );
  Grab(FreqCfgForm         , TFreqCfgForm                    );
  Grab(DeviceConfig        , TDeviceConfig                   );
  Grab(FidoAddressInput    , TFidoAddressInput               );
  Grab(NodelistCompiler    , TNodelistCompiler               );
  Grab(LineBitsEditor      , TLineBitsEditor                 );
  Grab(ModemEditor         , TModemEditor                    );
  Grab(SelectDirDialog     , TSelectDirDialog                );
  Grab(PathNamesForm       , TPathNamesForm                  );
  Grab(NodeListCfgForm     , TNodeListCfgForm                );
  Grab(PwdForm             , TPwdForm                        );
  Grab(RestrictCfgForm     , TRestrictCfgForm                );
  Grab(MailerForm          , TMailerForm                     );
  Grab(AttachStatusForm    , TAttachStatusForm               );
  Grab(MainConfigForm      , TMainConfigForm                 );
  Grab(StartupConfigForm   , TStartupConfigForm              );
  Grab(RegInputForm        , TRegInputForm                   );
  Grab(ExternalsForm       , TExternalsForm                  );
  Grab(UnregForm           , TUnregForm                      );
  Grab(EventsForm          , TEventsForm                     );
  Grab(EvtEditForm         , TEvtEditForm                    );
  Grab(NodelistBrowser     , TNodelistBrowser                );
  Grab(DisplayInfoForm     , TDisplayInfoForm                );
  Grab(EncryptedLinksForm  , TEncryptedLinksForm             );
  Grab(FidoTemplateEditor  , TFidoTemplateEditor             );
  Grab(FileBoxesForm       , TFileBoxesForm                  );
  Grab(FReqDlg             , TFReqDlg                        );
  Grab(ModemCmdForm        , TModemCmdForm                   );
  Grab(NewPwdInputForm     , TNewPwdInputForm                );
  Grab(NodeWizzardForm     , TNodeWizzardForm                );
  Grab(OvrExplainForm      , TOvrExplainForm                 );
  Grab(PollSetupForm       , TPollSetupForm                  );
  Grab(SinglePasswordForm  , TSinglePasswordForm             );
  Grab(StartWizzardForm    , TStartWizzardForm               );
  Grab(IpCfgForm           , TIpCfgForm                      );
  StoreGrabbed;
    ExitProcess(0);
end;

{$ENDIF}

procedure Stop(const a, b: string);
begin
  Windows.MessageBox(0, PChar(A), PChar(B), MB_SETFOREGROUND or MB_TASKMODAL or MB_ICONSTOP or MB_OK);
end;

procedure AnotherArgus;
begin
  Stop('Another instance is already running', ProductName);
  Halt;
end;


procedure InitHelp;
var
  o,l: string;
begin
  o := GetRegHelpLng;
  RussianHelp := FileExists(GetHelpFile('rus'));
  EnglishHelp := FileExists(GetHelpFile('eng'));
  GermanHelp := FileExists(GetHelpFile('ger'));
  DanishHelp := FileExists(GetHelpFile('dan'));
  DutchHelp := FileExists(GetHelpFile('dut'));
  SpanishHelp := FileExists(GetHelpFile('spa'));
  if ((o = 'rus') and RussianHelp) or
     ((o = 'dut') and DutchHelp) or
     ((o = 'eng') and EnglishHelp) or
     ((o = 'spa') and SpanishHelp) or
     ((o = 'dan') and DanishHelp) or
     ((o = 'ger') and GermanHelp)
     then l := o else
  begin
    if EnglishHelp then l := 'eng' else
    if RussianHelp then l := 'rus' else
    if DutchHelp then l := 'dut' else
    if SpanishHelp then l := 'spa' else
    if DanishHelp then l := 'dan' else
    if GermanHelp then l := 'ger' else l := '';
    if o <> l then SetRegHelpLng(l);
  end;
  if l = 'spa' then
  begin
    HelpLanguageId := HelpLanguageSpanish;
    Application.HelpFile := GetHelpFile('spa');
  end else
  if l = 'dut' then
  begin
    HelpLanguageId := HelpLanguageDutch;
    Application.HelpFile := GetHelpFile('dut');
  end else
  if l = 'ger' then
  begin
    HelpLanguageId := HelpLanguageGerman;
    Application.HelpFile := GetHelpFile('ger');
  end else
  if l = 'dan' then
  begin
    HelpLanguageId := HelpLanguageDanish;
    Application.HelpFile := GetHelpFile('dan');
  end else
  if l = 'rus' then
  begin
    HelpLanguageId := HelpLanguageRussian;
    Application.HelpFile := GetHelpFile('rus');
  end else
  if l = 'eng' then
  begin
    HelpLanguageId := HelpLanguageEnglish;
    Application.HelpFile := GetHelpFile('eng');
  end else HelpLanguageId := 0;
end;


procedure TestAnotherArgus;
var
  H: THandle;
begin
  SetLastError(0);
  hMutex := CreateMutex(nil, False, aMutexName);
  if (hMutex = 0) then AnotherArgus;
  if (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    ZeroHandle(hMutex);
    H := OpenEvent(EVENT_MODIFY_STATE, False, aActivateEventName);
    if H = INVALID_HANDLE_VALUE then AnotherArgus else
    begin
      SetEvent(H);
      ZeroHandle(H);
      Halt;
    end;
  end;
end;


function GetEMSICR: string;
var
  s: string;
begin
  s := GetRegStringDef('EMSI_CR', '%0D');
  UnpackRFC1945(s);
  Result := s;
end;

procedure DoComeOn;
begin
//  fShowExceptionCallback := ShowExceptionCallback;

  ThrTimesLog := (Win32Platform = VER_PLATFORM_WIN32_NT) and (GetRegBooleanDef('LogThreadTimes', False));
  DisableWinsockTraps := GetRegBooleanDef('DisableWinsockTraps', False);

  IsHtmlHelp := not GetRegBooleanDef('DisableHtmlHelp', False);

  xBaseInit;

  ODBC_Logging := GetRegBooleanDef('ODBC Logging', False);

  if ODBC_Logging then OdbcLogInitialize;

  InitMsgDispatcher;

  SetLanguage(GetRegInterfaceLng);

  Application.Initialize;

  Application.ShowHint := True;
  RegisterConfig;

  LoadConfig;
  StartupOptions := Cfg.StartupData.Options;

  SimpleBSY := GetRegBooleanDef('SimpleBSY', False);
  CloseBWZFile := GetRegBooleanDef('CloseBWZFile', False);
  ForceAddFaxPage := GetRegBooleanDef('ForceFaxPage', False);
  sEMSI_CR := GetEMSICR;
{$IFDEF IgnoreEndSession}
  IgnoreEndSession := GetRegBooleanDef('IgnoreEndSession', False);
{$ENDIF}
  IncrementArcmail := GetRegBooleanDef('IncrementArcmail', False);
  WinSockVersion := GetRegIntegerDef('WinSockVersion', 0);


  TrapLogFName := MakeNormName(dLog, 'traps.log');

  ThreadsLogFName := MakeNormName(dLog, 'threads.txt');

  LoadIntegers;

  InitTickTimer;

  InitFidoOut;
  InitNdlUtil;

  InitMailers;

  LoadHistory;

  OpenBWZlog;

  InitHelp;

  PurgeActiveFlags;


  {$IFDEF GRAB}
  GrabForms;
  {$ENDIF}

  OpenMailerForm(PanelOwnerPolls, False);

  OdbcLogCheckInit(MakeNormName(dLog, 'odbcerr.log'));

  {$IFDEF WS}
  if StartupOptions and stoRunIpDaemon <> 0 then _RunDaemon;
  {$ENDIF}

  OpenAutoStartLines;

  PostMsg(WM_UPDATEMENUS);

  Sleep(100);

  Application.ProcessMessages;

  TMailerForm(Application.MainForm).SuperShow;

  Application.Run;
  Application.MainForm.Free;

  if StoreConfigAfter then StoreConfig(0);

  Application.ProcessMessages;
  FreeAllLines;
  FreeAllPolls(pdnShutDown, True);
  Application.ProcessMessages;

  DoneMailers;
  DoneFidoOut;                  

  FreeNodeController;
  DoneNdlUtil;
  CloseBWZlog;
  StoreHistory;
  StoreIntegers;
  FreeCfgContainer;
  OdbcLogDone;
  xBaseDone;
  DoneMClasses;
  DoneMsgDispatcher;
  LanguageDone;
  ZeroHandle(hMutex);

  ApplicationDone := True;
end;


procedure DoGetStartupInfo;
var
  S: TStartupInfo;
begin
  Clear(S, SizeOf(S));
  S.cb := SizeOf(S);
  GetStartupInfo(S);
  if S.dwFlags and STARTF_USESHOWWINDOW <> 0 then
    FStartMinimized := (S.wShowWindow = SW_MINIMIZE) or
                       (S.wShowWindow = SW_SHOWMINIMIZED) or
                       (S.wShowWindow = SW_SHOWMINNOACTIVE);
end;


procedure Come_On;
begin
  DoGetStartupInfo;
  CurrentProcessHandle := GetCurrentProcess;
  CurrentThreadHandle := GetCurrentThread;
  if ParamStr(1) = 'DELAY' then Sleep(5000);
  TestAnotherArgus;
  DoComeOn;
end;

end.

