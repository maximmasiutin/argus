unit MlrForm;

{$I DEFINE.INC}

interface

uses
  Classes, Menus, Forms, xOutline, MClasses, ComCtrls, ExtCtrls, mGrids,
  Controls, StdCtrls, Windows, xFido, MlrThr, Outbound,
  Graphics, xMisc, Messages, xBase, Grids, Outline, SysUtils, Buttons;

type
  Twcb = (
    wcb_lSndSize,
    wcb_llSndSize,
    wcb_lSndCPS,
    wcb_llSndCPS,
    wcb_lRcvSize,
    wcb_llRcvSize,
    wcb_lRcvCPS,
    wcb_llRcvCPS,
    wcb_SndTot,
    wcb_RcvTot,
    wcbSndBar,
    wcbRcvBar,
    wcbLampsPanel,
    wcbTimeoutBox,

    wcb_mlClose,
    wcb_mlAbortOperation,
    wcb_mlResetTimeout,
    wcb_mlIncTimeout,

    wcb_mpReset,
    wcb_bResetPoll,
    wcb_ppResetPoll,

    wcb_mpTrace,
    wcb_bTracePoll,
    wcb_ppTracePoll,

    wcb_mpDelete,
    wcb_bDeletePoll,
    wcb_ppDeletePoll,

    wcb_mpDeleteAll,
    wcb_bDeleteAllPolls,
    wcb_ppDeleteAllPolls,

    wcb_mlSkip,
    wcb_bSkip,
    wcb_mlRefuse,
    wcb_bRefuse,

    wcb_mlAnswer,
    wcb_bAnswer,

    wcb_TopPage0,
    wcb_TopPage1,
    wcb_TopPage2,
    wcb_TopPage3,
    wcb_TopPage4,

    wcb_BtmPage0,
    wcb_BtmPage1,
    wcb_BtmPage2,
    wcb_BtmPage3,

    wcb_Rescan,

    wcb_MasterKeyCreate,
    wcb_MasterKeyChange,
    wcb_MasterKeyRemove,

    wcb_OutSmartMenu,

    wcb_mlSendMdmCmds


  );

  Twci = (
    wciSndTotCur,
    wciSndTotMax,
    wciSndFilCur,
    wciSndFilMax,
    wciRcvTotCur,
    wciRcvTotMax,
    wciRcvFilCur,
    wciRcvFilMax
  );

  Twcs = (
    wcsStatus,
    wcsTimeout,

    wcsGrd1,
    wcsGrd2,
    wcsGrd3,
    wcsGrd4,
    wcsGrd5,
    wcsGrd6,
    wcsGrd7,
    wcsGrd8,

    wcsSndFile,
    wcsSndCPS,
    wcsSndSize,

    wcsRcvFile,
    wcsRcvCPS,
    wcsRcvSize,

    wcsErr,
    wcsProtName,

    wcsPurgeFile,
    wcsPurgeNode

  );

  TOutMgrOpCode = (omoUnk, omoReaddr, omoKill, omo_Crash, omo_Direct, omo_Normal, omo_Hold, omoUnlink, omoPurge);

  TOutMgrGroupInfo = record
    AreBroken, CanUnLink: Boolean;
    OutAttTypesFound: TOutAttTypeSet;
    StatusesFound: TOutStatusSet;
  end;

  TMailerForm = class(TForm)
    MainTabControl: TTabControl;
    MainPanel: TPanel;
    MainMenu: TMainMenu;
    mSystem: TMenuItem;
    mLine: TMenuItem;
    mHelp: TMenuItem;
    mlAbortOperation: TMenuItem;
    mlResetTimeout: TMenuItem;
    mlIncTimeout: TMenuItem;
    mwClose: TMenuItem;
    N2: TMenuItem;
    mwCreateMirror: TMenuItem;
    mfExit: TMenuItem;
    msLineB: TMenuItem;
    mConfig: TMenuItem;
    mTool: TMenuItem;
    mtBrowseNodelist: TMenuItem;
    mtCompileNodelist: TMenuItem;
    mPoll: TMenuItem;
    mpCreate: TMenuItem;
    mpDelete: TMenuItem;
    mpReset: TMenuItem;
    mpDeleteAll: TMenuItem;
    N1: TMenuItem;
    mlClose: TMenuItem;
    N6: TMenuItem;
    mhLicence: TMenuItem;
    mcPasswords: TMenuItem;
    msOpenDialup: TMenuItem;
    mfRunIPDaemon: TMenuItem;
    N8: TMenuItem;
    mhAbout: TMenuItem;
    LogBox: TLogger;
    mcDialup: TMenuItem;
    mcDaemon: TMenuItem;
    mcPathnames: TMenuItem;
    mcStartup: TMenuItem;
    mcNodelist: TMenuItem;
    mhContents: TMenuItem;
    N9: TMenuItem;
    mhWebSite: TMenuItem;
    mpTrace: TMenuItem;
    mhLanguage: TMenuItem;
    hlRussian: TMenuItem;
    hlEnglish: TMenuItem;
    hlRomainian: TMenuItem;
    PollPopupMenu: TPopupMenu;
    ppCreatePoll: TMenuItem;
    N11: TMenuItem;
    ppTracePoll: TMenuItem;
    ppResetPoll: TMenuItem;
    ppDeletePoll: TMenuItem;
    ppDeleteAllPolls: TMenuItem;
    maExternals: TMenuItem;
    maFileRequests: TMenuItem;
    N7: TMenuItem;
    mtEditFileRequest: TMenuItem;
    msLineA: TMenuItem;
    msInterfaceLanguage: TMenuItem;
    ilEnglishUK: TMenuItem;
    ilRussian: TMenuItem;
    ilRomanian: TMenuItem;
    maEvents: TMenuItem;
    N12: TMenuItem;
    mlSkip: TMenuItem;
    mlRefuse: TMenuItem;
    mlAnswer: TMenuItem;
    TopNotebookPanel: TPanel;
    PollsListPanel: TPanel;
    PollsListView: TListView;
    DaemonPanel: TPanel;
    MainDaemonPanel: TPanel;
    Panel7: TPanel;
    Panel9: TPanel;
    DaemonPI: TPanel;
    Panel16: TPanel;
    gInput: TNavyGauge;
    Panel12: TPanel;
    DaemonPIH: TPanel;
    Panel18: TPanel;
    gInputGraph: TNavyGraph;
    Panel6: TPanel;
    Panel8: TPanel;
    DaemonPO: TPanel;
    Panel111: TPanel;
    gOutput: TNavyGauge;
    Panel10: TPanel;
    DaemonPOH: TPanel;
    Panel17: TPanel;
    gOutputGraph: TNavyGraph;
    Panel19: TPanel;
    Panel20: TPanel;
    Panel21: TPanel;
    MailerAPanel: TPanel;
    TermsPanel: TPanel;
    TermTx: TMicroTerm;
    TermRx: TMicroTerm;
    DialupInfoPanel: TPanel;
    StatusCarrier: TPanel;
    StatusBox: TGroupBox;
    TimeoutBox: TPanel;
    lTimeout: TLabel;
    bAdd: TSpeedButton;
    bStart: TSpeedButton;
    Panel1: TPanel;
    MailerBPanel: TPanel;
    Panel2: TPanel;
    SndBox: TGroupBox;
    lSndFile: TLabel;
    llSndCPS: TLabel;
    lSndCPS: TLabel;
    llSndSize: TLabel;
    lSndSize: TLabel;
    SndTot: TxGauge;
    SndBar: TProgressBar;
    RcvBox: TGroupBox;
    lRcvFile: TLabel;
    llRcvCPS: TLabel;
    lRcvCPS: TLabel;
    llRcvSize: TLabel;
    lRcvSize: TLabel;
    RcvTot: TxGauge;
    RcvBar: TProgressBar;
    Panel3: TPanel;
    SessionNfoPnl: TPanel;
    gTitles: TAdvGrid;
    gNfo: TAdvGrid;
    BottomPanel: TPanel;
    MailerBtnPanel: TPanel;
    bAbort: TSpeedButton;
    bRefuse: TSpeedButton;
    bSkip: TSpeedButton;
    bAnswer: TSpeedButton;
    LampsPanelCarrier: TPanel;
    LampsPanel: TPanel;
    mlRXD: TModemLamp;
    lRXD: TLabel;
    mlTXD: TModemLamp;
    lTXD: TLabel;
    mlCTS: TModemLamp;
    lCTS: TLabel;
    lDSR: TLabel;
    mlDSR: TModemLamp;
    mlDCD: TModemLamp;
    lDCD: TLabel;
    PollBtnPanel: TPanel;
    DaemonBtnPanel: TPanel;
    OutMgrPopup: TPopupMenu;
    OutMgrPanel: TPanel;
    OutMgrHeader: THeaderControl;
    OutMgrBevel: TBevel;
    OutMgrOutline: TxOutlin;
    ilGerman: TMenuItem;
    hlGerman: TMenuItem;
    lStatus: TLabel;
    ilMitky: TMenuItem;
    hlMitky: TMenuItem;
    OutMgrBtnPanel: TPanel;
    bReread: TSpeedButton;
    bDeleteAllPolls: TSpeedButton;
    bTracePoll: TSpeedButton;
    bResetPoll: TSpeedButton;
    bDeletePoll: TSpeedButton;
    bNewPoll: TSpeedButton;
    TrayPopupMenu: TPopupMenu;
    tpRestore: TMenuItem;
    tpExit: TMenuItem;
    hlDutch: TMenuItem;
    ilDutch: TMenuItem;
    ilSpanish: TMenuItem;
    hlSpanish: TMenuItem;
    N5: TMenuItem;
    tpCreatePoll: TMenuItem;
    tpBrowseNodelist: TMenuItem;
    maEncryptedLinks: TMenuItem;
    tpCancel: TMenuItem;
    N3: TMenuItem;
    N10: TMenuItem;
    tpEditFileRequest: TMenuItem;
    mcMasterPassword: TMenuItem;
    N15: TMenuItem;
    N16: TMenuItem;
    mcMasterPwdCreate: TMenuItem;
    mcMasterPwdChange: TMenuItem;
    mcMasterPwdRemove: TMenuItem;
    N17: TMenuItem;
    ompCur: TMenuItem;
    ompName: TMenuItem;
    ompExt: TMenuItem;
    ompStat: TMenuItem;
    ompAll: TMenuItem;
    opmCrash: TMenuItem;
    opmDirect: TMenuItem;
    opmNormal: TMenuItem;
    opmHold: TMenuItem;
    N19: TMenuItem;
    opmPurge: TMenuItem;
    opmReaddress: TMenuItem;
    opmFinalize: TMenuItem;
    ompEntire: TMenuItem;
    N21: TMenuItem;
    N18: TMenuItem;
    N20: TMenuItem;
    N22: TMenuItem;
    ompAttach: TMenuItem;
    ompPoll: TMenuItem;
    ompBrowseNL: TMenuItem;
    opmUnlink: TMenuItem;
    ompEditFreq: TMenuItem;
    mtAttachFiles: TMenuItem;
    mtOutSmartMenu: TMenuItem;
    mtBrowseNodelistAt: TMenuItem;
    mcPolls: TMenuItem;
    ompOpen: TMenuItem;
    ompCreateFlag: TMenuItem;
    ompCfCrash: TMenuItem;
    ompCfDirect: TMenuItem;
    ompCfNormal: TMenuItem;
    ompCfHold: TMenuItem;
    mtCreateFlag: TMenuItem;
    mlSendMdmCmds: TMenuItem;
    mtCompileNodelistInv: TMenuItem;
    N13: TMenuItem;
    mcFileBoxes: TMenuItem;
    N14: TMenuItem;
    ompRescan: TMenuItem;
    N23: TMenuItem;
    maNodes: TMenuItem;
    N24: TMenuItem;
    ompHelp: TMenuItem;
    N25: TMenuItem;
    ilDanish: TMenuItem;
    hlDanish: TMenuItem;
    procedure MainTabControlChange(Sender: TObject);
    procedure bAbortClick(Sender: TObject);
    procedure bStartClick(Sender: TObject);
    procedure bAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mcPathnamesClick(Sender: TObject);
    procedure mwCreateMirrorClick(Sender: TObject);
    procedure mcDialupClick(Sender: TObject);
    procedure NodesPasswords1Click(Sender: TObject);
    procedure mlCloseClick(Sender: TObject);
    procedure bNewPollClick(Sender: TObject);
    procedure PollsListViewChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure PollsListViewClick(Sender: TObject);
    procedure bDeletePollClick(Sender: TObject);
    procedure mfExitClick(Sender: TObject);
    procedure mtBrowseNodelistClick(Sender: TObject);
    procedure mwCloseClick(Sender: TObject);
    procedure mhAboutClick(Sender: TObject);
    procedure bResetPollClick(Sender: TObject);
    procedure bDeleteAllPollsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mhLicenceClick(Sender: TObject);
    procedure mfRunIPDaemonClick(Sender: TObject);
    procedure mcStartupClick(Sender: TObject);
    procedure mtCompileNodelistClick(Sender: TObject);
    procedure mcNodelistClick(Sender: TObject);
    procedure mcDaemonClick(Sender: TObject);
    procedure mhContentsClick(Sender: TObject);
    procedure mhWebSiteClick(Sender: TObject);
    procedure mhHelpClick(Sender: TObject);
    procedure bTracePollClick(Sender: TObject);
    procedure mcExternalsClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure hlRussianClick(Sender: TObject);
    procedure hlEnglishClick(Sender: TObject);
    procedure mclEnglishUKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure maEventsClick(Sender: TObject);
    procedure bSkipClick(Sender: TObject);
    procedure bRefuseClick(Sender: TObject);
    procedure maFileRequestsClick(Sender: TObject);
    procedure mtEditFileRequestClick(Sender: TObject);
    procedure bAnswerClick(Sender: TObject);
    procedure OutMgrOutlineDrawItem(Control: TWinControl; Index: Integer; R: TRect; State: TOwnerDrawState);
    procedure FormResize(Sender: TObject);
    procedure OutMgrOutlineMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OutMgrOutlineDblClick(Sender: TObject);
    procedure OutMgrHeaderSectionClick(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure OutMgrHeaderSectionResize(HeaderControl: THeaderControl;
      Section: THeaderSection);
    procedure hlGermanClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure ilDutchClick(Sender: TObject);
    procedure hlSpanishClick(Sender: TObject);
    procedure maEncryptedLinksClick(Sender: TObject);
    procedure tpRestoreClick(Sender: TObject);
    procedure tpCreatePollClick(Sender: TObject);
    procedure tpBrowseNodelistClick(Sender: TObject);
    procedure tpEditFileRequestClick(Sender: TObject);
    procedure msAdministrativeModeClick(Sender: TObject);
    procedure mcMasterPwdCreateClick(Sender: TObject);
    procedure mcMasterPwdChangeClick(Sender: TObject);
    procedure mcMasterPwdRemoveClick(Sender: TObject);
    procedure bRereadClick(Sender: TObject);
    procedure opmReaddressClick(Sender: TObject);
    procedure opmFinalizeClick(Sender: TObject);
    procedure opmCrashClick(Sender: TObject);
    procedure opmDirectClick(Sender: TObject);
    procedure opmNormalClick(Sender: TObject);
    procedure opmHoldClick(Sender: TObject);
    procedure opmPurgeClick(Sender: TObject);
    procedure OutMgrPopupPopup(Sender: TObject);
    procedure ompAttachClick(Sender: TObject);
    procedure ompPollClick(Sender: TObject);
    procedure ompBrowseNLClick(Sender: TObject);
    procedure opmUnlinkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure OutMgrOutlineApiDropFiles(Sender: TObject);
    procedure ompEditFreqClick(Sender: TObject);
    procedure mtAttachFilesClick(Sender: TObject);
    procedure mtOutSmartMenuClick(Sender: TObject);
    procedure mtBrowseNodelistAtClick(Sender: TObject);
    procedure ompOpenClick(Sender: TObject);
    procedure OutMgrOutlineKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ompCfCrashClick(Sender: TObject);
    procedure ompCfDirectClick(Sender: TObject);
    procedure ompCfNormalClick(Sender: TObject);
    procedure ompCfHoldClick(Sender: TObject);
    procedure PollPopupMenuPopup(Sender: TObject);
    procedure PollsListViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PollsListViewDblClick(Sender: TObject);
    procedure mtCreateFlagClick(Sender: TObject);
    procedure mcPollsClick(Sender: TObject);
    procedure hlDutchClick(Sender: TObject);
    procedure mlSendMdmCmdsClick(Sender: TObject);
    procedure mhHowRegClick(Sender: TObject);
    procedure mcFileBoxesClick(Sender: TObject);
    procedure maNodesClick(Sender: TObject);
    procedure ompHelpClick(Sender: TObject);
    procedure hlDanishClick(Sender: TObject);
    function FormHelp(Command: Word; Data: Integer;
      var CallHelp: Boolean): Boolean;
{1}private
    aOutbound: TAnimate;
    uTaskbarRestart: DWORD;
    _Closed: Boolean;
    OutMgrSelectedItemInstead: Integer;
    OutMgrSelectedItemAddr: TFidoAddress;
    OutMgrSelectedItemName: string;
    OutMgrNodeSort: Integer;
    OutMgrdLast: TPoint;
    OutMgrBM: TBitmap;
    OutMgrBmps: array[0..2] of TBitmap;
    StartSize: TPoint;
    ListUpd: Integer;
    Activated, Shown: Boolean;
    ActiveLine: TMailerThread;
    wcs : array[Twcs] of string;
    wci : array[Twci] of Integer;
    wcb : set of Twcb;
    TopPagePanels: array[wcb_TopPage0..wcb_TopPage4] of TPanel;
    BtmPagePanels: array[wcb_BtmPage0..wcb_BtmPage3] of TPanel;
    OutMgrExpanded: TFidoAddrColl;
    OutMgrNodes: TOutNodeColl;
    FirstOutMgrNode,
    LastOutMgrNode: TOutItem;
    TrayIcon: TTrayIcon;
    procedure ExceptionEvent(Sender: TObject; E: Exception);
    procedure UpdatePollOptions;
    procedure UpdateViewOutMgr;
    procedure OutMgrRefillExpanded;
    procedure LoadOutMgrBmp(i: Integer; const AName: string; AColor: TColor);
    procedure UpdateBoundsOutMgrBM;
    procedure UpdateOutboundManager;
    procedure SetTopPageIndex(Idx: Integer);
    procedure SetBtmPageIndex(Idx: Integer);
    procedure LineOpenClick(Sender: TObject);
    procedure PrepareGtitles;
    procedure SetLabel(L: TObject; c: TWcs; const s: string);
    procedure SetVisible(L: TControl; c: TWcb; V: Boolean);
    procedure SetEnabledO(L: TObject; c: TWcb; V: Boolean);
    procedure UpdateDial(const D: TDisplayData; const DS: TDisplayStringData);
    procedure UpdateProt(const D: TDisplayData; const DS: TDisplayStringData; T, R: TBatch; AOutUsed: DWORD; var Btns: Boolean);
    procedure SetBar(B: TProgressBar; C, M: Integer; CI, MI: Twci);
    procedure SetGauge(G: TxGauge; C, M: Integer; CI, MI: Twci);
    procedure InsertPollAddress(const A: TFidoAddress);
    function PollAnyway(an: TAdvNode): Boolean;
    procedure WMGetMinMaxInfo(var AMsg: TWmGetMinMaxInfo); message WM_GETMINMAXINFO;
    procedure WMStartMdmCmd(var M: TMessage); message WM_STARTMDMCMD;
    procedure WMTrayRC(var M: TMessage); message WM_TRAYRC;
    procedure WMAppMinimize(var M: TMessage); message WM_APPMINIMIZE;
    procedure UpdateView;
    procedure UpdateTabs;
    procedure UpdateLog;
    procedure UpdateLamps;
    procedure InvalidateLabels;
    procedure RestoreFromTray;
    procedure NewPoll;
    procedure EditFileRequest;
    procedure EditFileRequestEx(const AA: TFidoAddress);
    procedure RereadOutbound;
    function OutMgrSelectedItem: TOutItem;
    procedure InvokeOutMgrSmartMenu;
    procedure UpdateOutboundCommands;
    function GetOutFileColl(FileMask: PString; NodeAdrr: PFidoAddress; OutStatus: POutStatus; var AInfo: TOutMgrGroupInfo): TOutFileColl;
    procedure FillOutMgrSubMenu(AMenu: TMenuItem; C: TOutFileColl; const AInfo: TOutMgrGroupInfo);
    function GetOutCollByTag(ATag: Integer; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
    procedure PerformOutboundOperations(FileLists: TColl; DestAddr: PFidoAddress; OpCode: TOutMgrOpCode);
    procedure OutOp(Sender: TObject; OpCode: TOutMgrOpCode);
    procedure OutOpTag(OpCode: TOutMgrOpCode; t: Integer);
    procedure AttachFiles(SC: TStringColl; const A: TFidoAddress);
    procedure AttachFilesQuery(const A: TFidoAddress);
    procedure BrowseNodelistAt(const Addr: TFidoAddress);
    procedure CreateOutFileFlag(const AA: TFidoAddress; Status: TOutStatus);
    procedure ompCreateFileFlag(os: TOutStatus);
{4}public
    procedure SuperShow;
    procedure InsertEvt(Evt: Pointer);
    procedure WndProc(var M: TMessage); override;
  end;

procedure InitMsgDispatcher;
procedure DoneMsgDispatcher;
procedure OpenMailerForm(AThread: TMailerThread; DoShow: Boolean);
procedure UpdateLampsAll;
procedure UpdateTerm(Struc: Integer);
procedure ClearTerms(AThr: Integer);
procedure OpenAutoStartLines;
function OpenMailer(LineId: DWORD; Handle: DWORD): TMailerThread;
procedure FreeAllLines;
procedure FreeAllPolls(Action: TPollDone; All: Boolean);
procedure SwitchDaemon(Handle: DWORD);
procedure PurgeActiveFlags;


var
  LocalExit: Boolean;

implementation

uses
  igHHint,
  MdmCmd, Recs, NdlUtil, FileBox, NodeWiz,
  xIP, LngTools, PathName,
  DupCfg, FidoPwd, NodeBrws, About, Credits, StupCfg, NodeLCfg,

  {$IFDEF WS}
  IPCfg,
  {$ENDIF}

  ShellAPI, TracePl, Extrnls, PollCfg, Events, FreqCfg,
  SinglPwd, EncLinks, AdrIBox, FreqEdit, Attach, xDES, PwdInput, Dialogs


  ;

{$R *.DFM}

const
  ioFolders    = 0;
  ioLines      = 1;

  olfLastItem  = 1;
  olfLastLevel = 2;


procedure UpdateMenus;
var
  l: TLineRec;
  m, n, f: TMenuItem;
  i,j: Integer;
  mf: TMailerForm;
  MT: TStringColl;
begin
  if MailerForms = nil then Exit;
  MT := TStringColl.Create;
  for j := 0 to MailerThreads.Count-1 do MT.Ins(TMailerThread(MailerThreads[j]).Name);
  for j := 0 to MailerForms.Count-1 do
  begin
    mf := MailerForms[j];
    m := mf.msOpenDialup;
    with m do while Count>0 do
    begin
      f := Items[0];
      Remove(f);
      FreeObject(f);
    end;
    for i := 0 to Cfg.Lines.Count-1 do
    begin
      l := Cfg.Lines[i];
      n := TMenuItem.Create(m);
      n.Caption := l.Name;
      if MT.Found(l.Name) then
      begin
        n.Checked := True;
        n.Enabled := False;
      end else
      begin
        n.Tag := l.id;
        n.OnClick := mf.LineOpenClick;
      end;
      m.Add(n);
    end;
  end;
  FreeObject(MT);
end;

procedure OpenAutoStartLines;
var
  i: Integer;
  Lines: TLineColl;
  LR: TLineRec;
begin
  CfgEnter;
  Lines := Pointer(Cfg.Lines.Copy);
  CfgLeave;
  for i := 0 to Lines.Count-1 do
  begin
    LR := Lines[i];
    if IsAutoStartLine(LR.Id) then OpenMailer(LR.Id, 0);
  end;
  FreeObject(Lines);
end;

procedure TabChangeAll;
var
  i: Integer;
begin
  if MailerForms <> nil then for i := 0 to MailerForms.Count-1 do TMailerForm(MailerForms.At(i)).MainTabControlChange(nil);
end;

procedure UpdateTabsAll;
var
  i: Integer;
begin
  if MailerForms <> nil then for i := 0 to MailerForms.Count-1 do TMailerForm(MailerForms.At(i)).UpdateTabs;
end;

procedure UpdateViewAll;
var
  i: Integer;
begin
  if MailerForms <> nil then for i := 0 to MailerForms.Count-1 do TMailerForm(MailerForms.At(i)).UpdateView;
end;



////////////////////////////////////////////////////////////////////////
//                                                                    //
//                            Utilities                               //
//                                                                    //
////////////////////////////////////////////////////////////////////////


procedure InvalidateLogBox(ActiveLine: Pointer);
var
  I: Integer;
  mf: TMailerForm;
begin
  for I := 0 to MailerForms.Count-1 do
  begin
    mf := MailerForms[I];
    if mf.ActiveLine = ActiveLine then mf.LogBox.Invalidate
  end;
end;

procedure __CloseLine(AM: Integer);
var
  M: TMailerThread absolute AM;
  I: Integer;
begin
  if MailerThreads = nil then GlobalFail('%s', ['MailerThreads = nil']);
  I := MailerThreads.IndexOf(M);
  if I = -1 then GlobalFail('%s', ['_CloseLine not found']);
  MailerThreads.Enter;
  MailerThreads.AtDelete(I);
  MailerThreads.Leave;
  SendMsg(WM_UPDATETABS);
  SendMsg(WM_TABCHANGE);
  M.WaitFor;
  PostMsg(WM_UPDATEMENUS);
  FreeObject(M);
end;

procedure AddSpcLogStr(APStr: Integer; p: Pointer);
var
  ps: TStringHolder absolute APStr;
  L: TStringColl;
  s: string;
begin
  s := StrAsg(ps.s);
  FreeObject(ps);
  case Integer(p) of
    Integer(PanelOwnerPolls)  : L := FidoPolls.Log.Strings;
{$IFDEF WS}
    Integer(PanelOwnerDaemon) : L := IpPolls.LogContainer.Strings;
{$ENDIF}    
    else begin GlobalFail('Unk AddSpcLogStr(%s)', [s]); Exit end;
  end;
  L.Add(S);
  while L.Count > MaxLogStrings do L.AtFree(0);
  if MailerForms <> nil then InvalidateLogBox(p);
end;


procedure ImportPwdList;
var
  sp, i: Integer;
  l: TStringColl;
  FName, s, z, k: string;
  LogStrs: TStringColl;
  A: TFidoAddrColl;
  PC: TPasswordColl;
  R: TPasswordRec;
  Files: TStringColl;
begin
  CfgEnter;
  s := StrAsg(Trim(Cfg.Passwords.AuxFile));
  CfgLeave;
  if s = '' then Exit;
  FName := MakeNormName(HomeDir, s);
  if not FileExists(FName) then Exit;
  PC := TPasswordColl.Create;
  logstrs := TStringColl.Create;
  l := TStringColl.Create;
  l.KeepOnLoad := True;
  Files := TStringColl.Create;
  Files.Add(FName);
  Files.IgnoreCase := True;
  l.LoadFromFile(FName);
  i := 0;
  while i <= CollMax(l) do
  begin
    s := Trim(l[i]); Inc(i);
    if s = '' then Continue;
    case s[1] of
      ';', '#': Continue;
    end;
    if StrBegsU('INCLUDE ', s) then
    begin
      GetWrd(s, z, ' ');
      s := FullPath(s);
      if not Files.Search(@s, sp) then
      begin
        Files.AtInsert(sp, NewStr(s));
        if not l.LoadFromFile(s) then
        begin
          logstrs.Add(GetErrorMsg);
          ClearErrorMsg;
        end;
      end;
      Continue;
    end;
    GetWrd(s, z, '|'); if not UnpackRFC1945(z) then Continue;
    GetWrd(s, k, '|'); if not UnpackRFC1945(k) then Continue;
    z := Trim(z);
    k := Trim(k);
    if (z = '') or (k = '') then Continue;
    A := CreateAddrCollMsg(z, s);
    if A = nil then
    begin
      logstrs.Add(s);
      Continue;
    end;
    R := TPasswordRec.Create;
    XChg(Integer(R.AddrList), Integer(A));
    FreeObject(A);
    R.PswStr := k;
    PC.Insert(R);
  end;
  FreeObject(l);
  LogStrs.Add(Format('%d password(s) imported from %s', [PC.Count, Files.LongStringS(', ')]));
  FreeObject(Files);
  for i := 0 to LogStrs.Count-1 do
  begin
    s := LogStrs[i];
    FidoPolls.Log.LogSelf('PWD-IMPORT: '+s);
  end;
  FreeObject(LogStrs);
  EnterCS(AuxPwdsCS);
  XChg(Integer(AuxPwds), Integer(PC));
  LeaveCS(AuxPwdsCS);
  FreeObject(PC);
end;

procedure ImportOvrList(C: TAbsNodeOvrColl; const AName: string; ADialup: Boolean);
const
  SDialup : array[Boolean] of string = ('TCP/IP', 'dial-up');
var
  os, s, z, k, FName: string;
  l, Files, LogStrs: TStringColl;
  sp, i: Integer;
  A: TFidoAddress;
  O: TNodeOvr;
begin
  if AName = '' then Exit;
  FName := MakeNormName(HomeDir, AName);
  if not FileExists(FName) then Exit;
  logstrs := TStringColl.Create;
  l := TStringColl.Create;
  l.KeepOnLoad := True;
  Files := TStringColl.Create;
  Files.Add(FName);
  Files.IgnoreCase := True;
  l.LoadFromFile(FName);
  i := 0;
  while i <= CollMax(l) do
  begin
    s := Trim(l[i]); Inc(i);
    if s = '' then Continue;
    os := s;
    case s[1] of
      ';', '#': Continue;
    end;
    if StrBegsU('INCLUDE ', s) then
    begin
      GetWrd(s, z, ' ');
      s := FullPath(s);
      if not Files.Search(@s, sp) then
      begin
        Files.AtInsert(sp, NewStr(s));
        if not l.LoadFromFile(s) then
        begin
          logstrs.Add(GetErrorMsg);
          ClearErrorMsg;
        end;
      end;
      Continue;
    end;
    GetWrd(s, z, '|'); if not UnpackRFC1945(z) then Continue;
    GetWrd(s, k, '|'); if not UnpackRFC1945(k) then Continue;
    z := Trim(z);
    k := Trim(k);
    if (z = '') or (k = '') then Continue;
    if not ParseAddressMsg(z, A, s) then
    begin
      logstrs.Add(s);
      Continue;
    end;
    s := ValidOverride(k, ADialup, z);
    if s <> '' then
    begin
      logstrs.Add(Format('%s - %s (%s)', [os, s, z]));
      Continue;
    end;
    O := TNodeOvr.Create;
    O.Addr := A;
    O.Ovr := k;
    C.Insert(O);
  end;
  FreeObject(l);
  LogStrs.Add(Format('%d %s node override(s) imported from %s', [C.Count, SDialup[ADialup], Files.LongStringS(', ')]));
  FreeObject(Files);
  for i := 0 to LogStrs.Count-1 do
  begin
    s := LogStrs[i];
    FidoPolls.Log.LogSelf('OVR-IMPORT: '+s);
  end;
  FreeObject(LogStrs);
end;

procedure ImportDupOvrList;
var
  C: TDialupNodeOvrColl;
  s: string;
begin
  C := TDialupNodeOvrColl.Create;
  CfgEnter;
  s := StrAsg(Cfg.DialupNodeOverrides.AuxFile);
  CfgLeave;
  ImportOvrList(C, s, True);
  EnterCS(AuxDialupNodeOverridesCS);
  XChg(Integer(AuxDialupNodeOverrides), Integer(C));
  LeaveCS(AuxDialupNodeOverridesCS);
  FreeObject(C);
end;

{$IFDEF WS}
procedure ImportIpOvrList;
var
  C: TIPNodeOvrColl;
  s: string;
begin
  C := TIPNodeOvrColl.Create;
  CfgEnter;
  s := StrAsg(Cfg.IpNodeOverrides.AuxFile);
  CfgLeave;
  ImportOvrList(C, s, False);
  EnterCS(AuxIpNodeOverridesCS);
  XChg(Integer(AuxIpNodeOverrides), Integer(C));
  LeaveCS(AuxIpNodeOverridesCS);
  FreeObject(C);
end;
{$ENDIF}

var
  VCompilingNodelist: Integer;

procedure VCompileNodelist(AAuto: Boolean);
var
  D: TNodelistCompiler;
begin
  if VCompilingNodelist <> 0 then Exit;
  Inc(VCompilingNodelist);
  D := TNodelistCompiler.Create(Application);
  D.Auto := AAuto;
  D.ShowModal;
  D.Free;
  PurgeAdvNodeCache;
  InvalidatePollAddrs;
  _RecalcPolls;
  Dec(VCompilingNodelist);
end;

procedure UpdateOutboundManagers;
var
  i: Integer;
begin
  if MailerForms <> nil then for i := 0 to MailerForms.Count-1 do TMailerForm(MailerForms.At(i)).UpdateOutboundManager;
end;

procedure ClearTerms;
var
  i: Integer;
  m: TMailerForm;
  t: TMailerThread absolute AThr;
begin
  if (MailerForms = nil) or (MailerForms = nil) then Exit;
  if MailerThreads.IndexOf(t) = -1 then Exit;
  t.TermTxData.Clear; t.TermRxData.Clear;
  for i := 0 to MailerForms.Count-1 do
  begin
    m := MailerForms[i];
    if m.ActiveLine <> t then Continue;
    m.TermTx.Invalidate;
    m.TermRx.Invalidate;
  end;
end;

procedure UpdateTerm(Struc: Integer);
var
  s: TUpdateTermStruc absolute Struc;

procedure DoIt;
var
  i: Integer;
  RR, R: TRect;
  u: Boolean;
  m: TMailerForm;
  mth: DWORD;
  mtd: TTermData;
  ss: string;
begin
  if (MailerForms = nil) or (MailerThreads = nil) then Exit;
  if MailerThreads.IndexOf(s.Thr) = -1 then Exit;
  ss := StrAsg(s.Str);
  u := False;
  RR.Left := High(RR.Left);
  RR.Top := High(RR.Top);
  RR.Right := -High(RR.Right);
  RR.Bottom := -High(RR.Bottom);
  for i := 1 to Length(ss) do
  begin
    if s.Top then mtd := s.Thr.TermTxData else mtd := s.Thr.TermRxData;
    R := mtd.PutChar(ss[i], s.Lit, s.CrL);
    if _EmptyRect(R) then Continue;
    RR.Left := MinI(RR.Left, R.Left);
    RR.Top := MinI(RR.Top, R.Top);
    RR.Right := MaxI(RR.Right, R.Right);
    RR.Bottom := MaxI(RR.Bottom, R.Bottom);
    u := True;
  end;
  if u then for i := 0 to MailerForms.Count-1 do
  begin
    m := MailerForms[i];
    if m.ActiveLine <> s.Thr then Continue;
    if s.Top then mth := m.TermTx.Handle else mth := m.TermRx.Handle;
    InvalidateRect(mth, @RR, False);
  end;
end;
begin
  DoIt;
  s.Free;
end;

procedure UpdateLampsAll;
var
  i: Integer;
begin
  if MailerForms <> nil then for i := 0 to MailerForms.Count-1 do TMailerForm(MailerForms.At(i)).UpdateLamps;
end;

type
  TMsgDispatcher = class
    constructor Create;
    destructor Destroy; override;
    procedure WndProc(var Msg: TMessage);
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
  end;

var
  MsgDispatcher: TMsgDispatcher;


constructor TMsgDispatcher.Create;
const
  CTimerTick = 1000;
begin
  inherited Create;
  MainWinHandle := AllocateHWnd(WndProc);
  SetTimer(MainWinHandle, 1, CTimerTick, nil);
end;

procedure TMsgDispatcher.AppMessage(var Msg: TMsg; var Handled: Boolean);
begin
  IncLong(AppThrInvoked);
end;

destructor TMsgDispatcher.Destroy;
begin
  DeallocateHWnd(MainWinHandle);
  inherited Destroy;
end;


procedure GetTermBounds(var cw, ch: Integer);
begin
  if Application.MainForm = nil then begin cw := 0; ch := 0 end else
  with TMailerForm(Application.MainForm).TermTx do begin cw := ClientWidth; ch := ClientHeight end;
end;

{$IFDEF WS}
procedure NewIPLine(APort: Pointer; AIpPort: Integer; AProt: TProtCore);
var
  ILD: TNewIpLineData;
  cw, ch: Integer;
begin
  ILD := TNewIpLineData.Create;
  ILD.Poll := nil;
  ILD.IpPort := AIpPort;
  ILD.Prot := AProt;
  GetTermBounds(cw, ch);
  OpenMailerThread(APort, 0, ILD, cw, ch);
  PostMsg(WM_UPDATETABS);
end;

procedure NewInIPLine(l: Integer);
var
  NI: TNewIpInLine absolute l;
begin
  NewIpLine(NI.Port, NI.IpPort, NI.Prot); 
  NI.Free;
end;

procedure OutConnRes(A: Integer);
var
  cr: TWSAConnectResult absolute A;
  s, z: string;
  ILD: TNewIpLineData;
  cw, ch: Integer;
  p: TFidoPoll;
begin
  if cr.Error then
  begin
    z := TFidoPoll(cr.p).IPAddr;
    if (cr.ResolvedAddr = INADDR_NONE) then s := 'Unresolved' else s := Addr2Inet(cr.ResolvedAddr);
    if z <> s then s := Format('%s (%s) #%d', [z, s, cr.IpPort]);
    z := Addr2Str(TFidoPoll(cr.p).Node.Addr);
    if cr.Terminated then s := Format('%s  Terminated  %s', [z, s]) else
      s := Format('%s  WS%.5d (%s)  %s', [z, cr.Res, WSAErrMsg(cr.Res),  s]);
    IPPolls.Logger.Log(ltInfo, s);
    TFidoPoll(cr.p).IncNoConnectTries;
    p := cr.p;
    RollPoll(p);
    cr.p := p;
  end else
  begin
    if (DaemonStarted) and (cr.Port <> nil) then
    begin
      ILD := TNewIpLineData.Create;
      ILD.Poll := cr.p;
      ILD.IpPort := cr.IpPort;
      ILD.Prot := cr.Prot;
      GetTermBounds(cw, ch);
      OpenMailerThread(cr.Port, 0, ILD, cw, ch);
      PostMsg(WM_UPDATETABS);
    end;
  end;
  FreeObject(cr);
end;
{$ENDIF}

var
  FlFlgTimer: EventTimer;

var
  ThrLogTimer: EventTimer;

procedure UpdThrLog;
begin
  if TimerInstalled(ThrLogTimer) and not TimerExpired(ThrLogTimer) then Exit;
  NewTimerSecs(ThrLogTimer, 5);
  UpdateThreadsLog;
end;


procedure CheckFileFlags;

var
  reload: Boolean;

  {$IFDEF WS}
procedure CheckDaemon;
var
  open, close: Boolean;
  FOpen, FClose: string;
begin
  FOpen := MakeNormName(HomeDir, 'open.ip');
  FClose := MakeNormName(HomeDir, 'close.ip');

  open  := FileExists(FOpen);
  close := FileExists(FClose);

  if open then
  begin
    if not DaemonStarted then SwitchDaemon(INVALID_HANDLE_VALUE);
  end else
  if close then
  begin
    if DaemonStarted then SwitchDaemon(INVALID_HANDLE_VALUE);
  end;

  if open then DeleteFile(FOpen);
  if close then DeleteFile(FClose);

end;
  {$ENDIF}

procedure CheckLineFlags;
var
  t: TMailerThread;
  i, j: Integer;
  Lines: TLineColl;
  LR: TLineRec;
  open, close: Boolean;
  FOpen, FClose: string;
begin
  CfgEnter;
  Lines := Pointer(Cfg.Lines.Copy);
  CfgLeave;
  for i := 0 to Lines.Count-1 do
  begin
    LR := Lines[i];
    FOpen := MakeNormName(HomeDir, 'open.'+LR.Name);
    FClose := MakeNormName(HomeDir, 'close.'+LR.Name);

    open  := FileExists(FOpen);
    close := FileExists(FClose);

    if open then
    begin
      t := OpenMailer(LR.Id, INVALID_HANDLE_VALUE);
      if t <> nil then reload := True;
    end else
    if close then
    begin
      MailerThreads.Enter;
      for j := 0 to MailerThreads.Count-1 do
      begin
        t := MailerThreads[j];
        if Integer(t.LineId) = LR.Id then
        begin
          t.InsertEvt(TMlrEvtFlagTerminate.Create);
          reload := True;
        end;
      end;
      MailerThreads.Leave;
    end;

    if open then DeleteFile(FOpen);
    if close then DeleteFile(FClose);


  end;
  FreeObject(Lines);
end;

procedure CheckSingleFlags;
var
  s: string;
begin
  s := MakeNormName(HomeDir, 'EXIT.NOW');
  if FileExists(s) then
  begin
    DeleteFile(s);
    FidoPolls.Log.LogSelf(Format('Detected %s - exiting', [s]));
    PostCloseMessage;
  end;

  s := MakeNormName(HomeDir, 'NODELIST.OK');
  if FileExists(s) then
  begin
    DeleteFile(s);
    FidoPolls.Log.LogSelf(Format('Detected %s - forced nodelist compilation', [s]));
    PostMsg(WM_COMPILENL);
  end;

  s := MakeNormName(HomeDir, 'PASSWORD.OK');
  if FileExists(s) then
  begin
    DeleteFile(s);
    FidoPolls.Log.LogSelf(Format('Detected %s - forced password list import', [s]));
    PostMsg(WM_IMPORTPWDL);
  end;

  s := MakeNormName(HomeDir, 'DUPOVR.OK');
  if FileExists(s) then
  begin
    DeleteFile(s);
    FidoPolls.Log.LogSelf(Format('Detected %s - forced dial-up nodes list import', [s]));
    PostMsg(WM_IMPORTDUPOVRL);
  end;

{$IFDEF WS}
  s := MakeNormName(HomeDir, 'IPOVR.OK');
  if FileExists(s) then
  begin
    DeleteFile(s);
    FidoPolls.Log.LogSelf(Format('Detected %s - forced TCP/IP nodes list import', [s]));
    PostMsg(WM_IMPORTIPOVRL);
  end;
{$ENDIF}
end;


begin
  reload := False;
  FileFlags.Enter;
  CheckSingleFlags;
  CheckLineFlags;
  {$IFDEF WS}
  CheckDaemon;
  {$ENDIF}
  FileFlags.Leave;
  if reload then
  begin
    PostMsg(WM_UPDATETABS);
    PostMsg(WM_TABCHANGE);
    PostMsg(WM_UPDATEMENUS);
  end;
end;


procedure ChkFlFlg;
begin
  if TimerInstalled(FlFlgTimer) and not TimerExpired(FlFlgTimer) then Exit;
  NewTimerSecs(FlFlgTimer, 60);
  CheckFileFlags;
end;

procedure PurgeActiveFlags;
var
  Lines: TLineColl;
  LR: TLineRec;
  i: Integer;
  s: string;
begin
  CfgEnter;
  Lines := Pointer(Cfg.Lines.Copy);
  CfgLeave;
  for i := 0 to Lines.Count-1 do
  begin
    LR := Lines[i];
    s := MakeNormName(HomeDir, 'active.'+LR.Name);
    if FileExists(s) then DeleteFile(s);
  end;
  FreeObject(Lines);
  s := MakeNormName(HomeDir, 'active.ip');
  if FileExists(s) then DeleteFile(s);
  s := MakeNormName(HomeDir, 'current.ip');
  if FileExists(s) then DeleteFile(s);
end;


procedure SetupOK;
begin
  PurgeAdvNodeCache;
  InvalidatePollAddrs;
  _RecalcPolls;
  PostMsg(WM_UPDATEMENUS);
end;


procedure TMsgDispatcher.WndProc(var Msg: TMessage);
var
  DummyMsg: TMsg;
begin
{$IFDEF IgnoreEndSession}
  if (Msg.Msg = WM_QUERYENDSESSION) and (not IgnoreEndSession) then
  begin
    if Application.MainForm <> nil then PostMessage(Application.MainForm.Handle, WM_CLOSE, 0, 0);
    Msg.Result := 1;
    Exit;
  end;
{$ENDIF}
  if Cfg = nil then Exit;
  try
    if ExitNow then PostCloseMessage;
    case Msg.Msg of
      WM_UPDOUTMGR,
      WM_UPDATEMENUS,
      WM_UPDATEVIEW,
      WM_UPDATETABS,
      WM_TABCHANGE,
      WM_UPDATELAMPS:
        repeat
          if not PeekMessage(DummyMsg, MainWinHandle, Msg.Msg, Msg.Msg, PM_REMOVE) then
          begin
            Break;
          end;
        until False;
    end;

    case Msg.Msg of
      WM_NULL         : ;
      WM_COMPILENL    : if not ExitNow then VCompileNodelist(True);
      WM_IMPORTPWDL   : if not ExitNow then ImportPwdList;
      WM_IMPORTDUPOVRL: if not ExitNow then ImportDupOvrList;
{$IFDEF WS}
      WM_IMPORTIPOVRL : if not ExitNow then ImportIpOvrList;
{$ENDIF}
      WM_TIMER        : if Application.MainForm <> nil then begin PostMsg(WM_UPDATEVIEW); if ThrTimesLog then UpdThrLog; ChkFlFlg end;
      WM_UPDATEMENUS  : UpdateMenus;
      WM_UPDATEVIEW   : UpdateViewAll;
      WM_UPDATETABS   : UpdateTabsAll;
      WM_TABCHANGE    : TabChangeAll;
      WM_UPDATELAMPS  : UpdateLampsAll;
      WM_UPDATETERM   : UpdateTerm(Msg.lParam);
      WM_ADDPOLLSLOG  : AddSpcLogStr(Msg.lParam, PanelOwnerPolls);
      WM_CLEARTERMS   : ClearTerms(Msg.lParam);
      WM_CLOSELINE    : __CloseLine(Msg.lParam);
      WM_UPDOUTMGR    : UpdateOutboundManagers;
      WM_RESTORE_EVT  : begin Application.Restore; Application.BringToFront end;
      WM_SETUPOK      : if not ExitNow then SetupOK;
    {$IFDEF WS}
      WM_RESOLVE..WM_RESOLVE+WM__NUMRESOLVE-1: HostResolveComplete(Msg.Msg-WM_RESOLVE, Msg.lParam);
      WM_ADDDAEMONLOG: AddSpcLogStr(Msg.lParam, PanelOwnerDaemon);
      WM_NEWSOCKPORT : NewInIPLine(Msg.lParam);
      WM_CONNECTRES  : OutConnRes(Msg.lParam);
    {$ENDIF}
      else
        begin
          Msg.Result := DefWindowProc(MainWinHandle, Msg.Msg, Msg.wParam, Msg.lParam);
          Exit;
        end;
    end;
    Msg.Result := 0;
  except on E: Exception do ProcessTrap(E.Message, 'MainVCL');
  end;
end;


procedure TMailerForm.OutMgrRefillExpanded;
var
  sitem, i: Integer;
  ONode: TOutlineNode;
  n: TOutItem;
  pa: PFidoAddress;
begin
  FreeObject(OutMgrExpanded);

  OutMgrSelectedItemAddr.Zone := -1;

  sitem := OutMgrOutline.SelectedItem;
  for i := 1 to OutMgrOutLine.ItemCount do
  begin
    ONode := OutMgrOutline[i];
    n := ONode.Data;
    if (OutMgrSelectedItemInstead = -1) and (i = sitem) then
    begin
      OutMgrSelectedItemAddr := n.Address;
      OutMgrSelectedItemName := n.Name;
    end;
    if not ONode.Expanded then Continue;
    New(pa);
    pa^ := n.Address;
    if OutMgrExpanded = nil then OutMgrExpanded := TFidoAddrColl.Create;
    OutMgrExpanded.Insert(pa);
  end;
end;

procedure TMailerForm.UpdateOutboundManager;
var
  i: Integer;
  n: TOutNode;
  E: Boolean;
begin
  OutMgrRefillExpanded;
  FreeObject(OutMgrNodes);
  EnterCS(OutMgrThread.NodesCS);
  if OutMgrThread.Nodes <> nil then OutMgrNodes := OutMgrThread.Nodes.Copy;
  LeaveCS(OutMgrThread.NodesCS);
  E := False;
  for i := 0 to CollMax(OutMgrNodes) do
  begin
    n := OutMgrNodes[i];
    if n.Files <> nil then n.Files.PurgeDuplicates;
    n.PrepareNfo;
    E := E or (osError in n.FStatus);
  end;
  UpdateViewOutMgr;
  SetEnabledO(bReread, wcb_Rescan, True);
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    aOutbound.Visible := False;
    aOutbound.Active := False;
  end;  
end;

procedure TMailerForm.SetTopPageIndex(Idx: Integer);
var
  i: Twcb;
  j: Integer;
begin
  j := 0;
  for i := wcb_TopPage0 to wcb_TopPage4 do
  begin
    SetVisible(TopPagePanels[i], i, j = Idx);
    Inc(j);
  end;
end;

procedure TMailerForm.SetBtmPageIndex(Idx: Integer);
var
  i: Twcb;
  j: Integer;
begin
  j := 0;
  for i := wcb_BtmPage0 to wcb_BtmPage3 do
  begin
    SetVisible(BtmPagePanels[i], i, j = Idx);
    Inc(j);
  end;
end;

procedure TMailerForm.SuperShow;
var
  p: Pointer;
begin
  if MailerThreads.Count>0 then p := MailerThreads[0] else p := PanelOwnerPolls;
  ActiveLine := p;
  UpdateTabs;
  MainTabControlChange(nil);
  Show;
end;

procedure TMailerForm.InsertEvt(Evt: Pointer);
var
  a: TMailerThread;
  i: Integer;
begin
  a := ActiveLine;
  for i := 0 to MailerThreads.Count-1 do if a = MailerThreads[i] then a.InsertEvt(Evt);
end;

procedure TMailerForm.InvalidateLabels;
begin
  lSndSize.Left := llSndSize.Left+llSndSize.Width+6;
  lRcvSize.Left := llRcvSize.Left+llRcvSize.Width+6;
end;

procedure BackupConfig(Handle: DWORD);
var
  D: TSaveDialog;
  B: Boolean;
  Dst, Src: string;
begin
  D := TSaveDialog.Create(Application);
  D.Title := LngStr(rsMMBackUpCfgC);
  D.Filter := LngStr(rsMMBackUpCfgF);
  D.Options := [ofHideReadOnly, ofNoReadOnlyReturn, ofOverwritePrompt];
  B := D.Execute;
  Dst := D.FileName;
  FreeObject(D);
  if not B then Exit;
  Src := ConfigFName;
  if not CopyFile(PChar(Src), PChar(Dst), False) then DisplayError(FormatErrorMsg(Format('%s -> %s', [Src, Dst]), GetLastError), Handle);
end;

procedure OpenMailerForm;
var
  MailerForm: TMailerForm;
begin
  Application.CreateForm(TMailerForm, MailerForm);
  MailerForm.ActiveLine := AThread;
  MailerForm.UpdateTabs;
  MailerForm.MainTabControlChange(nil);
  MailerForms.Insert(MailerForm);
  if DoShow then
  begin
    MailerForm.MainTabControlChange(nil);
    MailerForm.Show;
  end;
  if Cfg.UpgStrings <> nil then
  begin
    if WinDlgCap(FormatLng(rsMMNewCfgItems, [ProductNameFull, ProductVersion, Cfg.UpgStrings.LongString]), MB_YESNO or MB_ICONQUESTION, MailerForm.Handle, LngStr(rsMMCfgUpd)) = idYes then BackupConfig(MailerForm.Handle);
    FreeObject(Cfg.UpgStrings);
    StoreConfig(MailerForm.Handle);
  end;
end;

procedure InitMsgDispatcher;
begin
  MsgDispatcher := TMsgDispatcher.Create;
  Application.OnMessage := MsgDispatcher.AppMessage;
end;

////////////////////////////////////////////////////////////////////////
//                                                                    //
//                             Mailer Form                            //
//                                                                    //
////////////////////////////////////////////////////////////////////////

procedure TMailerForm.UpdateTabs;
var
  i, ti, ic, c: Integer;
  m: TMailerThread;

procedure DoAdd(const s: string);
begin
  if c < ic then MainTabControl.Tabs[c] := s else MainTabControl.Tabs.Add(s);
  Inc(c);
end;

begin
  ti := -1;
  c := 0;
  ic := MainTabControl.Tabs.Count;
  for i := 0 to MailerThreads.Count-1 do          
  begin
    m := MailerThreads.At(i);
  {$IFDEF WS}
    if not m.DialupLine then Continue;
  {$ENDIF}
    if ActiveLine = m then ti := c;
    DoAdd(m.Name);
  end;
  if ti = -1 then ti := c;                       
  if ActiveLine = PanelOwnerPolls then ti := c;
  DoAdd(LngStr(rsMMTabPolls));
  if ActiveLine = PanelOwnerOutMgr then ti := c;
  DoAdd(LngStr(rsMMTabOutbound));
{$IFDEF WS}
  if DaemonStarted then
  begin
  if ActiveLine = PanelOwnerDaemon then ti := c;
    DoAdd(LngStr(rsMMTabDaemon));
    for i := 0 to MailerThreads.Count-1 do
    begin
      m := MailerThreads.At(i);
      if m.DialupLine then Continue;
      if ActiveLine = m then ti := c;
      DoAdd(m.Name);
    end;
  end;
{$ENDIF}
  while ic > c do begin Dec(ic); MainTabControl.Tabs.Delete(ic) end;
  MainTabControl.TabIndex := ti;
end;

procedure TMailerForm.SetBar(B: TProgressBar; C, M: Integer; CI, MI: Twci);
begin
  if wci[MI] <> M then
  begin
    wci[MI] := M;
    B.Max := M;
  end;
  if wci[CI] <> C then
  begin
    wci[CI] := C;
    B.Position := C;
  end;
end;

procedure TMailerForm.SetGauge(G: TxGauge; C, M: Integer; CI, MI: Twci);
begin
  if wci[MI] <> M then
  begin
    wci[MI] := M;
    G.MaxValue := M;
  end;

  if wci[CI] <> C then
  begin
    wci[CI] := C;
    G.Progress := C;
  end;
end;

procedure TMailerForm.SetLabel(L: TObject; c: TWcs; const s: string);
var
  Lbl: TLabel absolute L;
  Mnu: TMenuItem absolute L;
begin
  if wcs[c] = s then Exit;
  wcs[c] := s;
  if L is TLabel then
  begin
    Lbl.Caption := s;
    if Lbl.ShowHint then Lbl.Hint := s;
  end else
  if L is TMenuItem then Mnu.Caption := s else
  GlobalFail('TMailerForm.SetLabel(%s,...,"%s")', [L.ClassName, s]);
end;


procedure TMailerForm.SetEnabledO(L: TObject; c: TWcb; V: Boolean);
begin
  if V = (c in wcb) then Exit;
  if V then Include(wcb, c) else Exclude(wcb, c);
  if L is TControl then with L as TControl do Enabled := V else
  if L is TMenuItem then with L as TMenuItem do Enabled := V else GlobalFail('TMailerForm.SetEnabled for %s', [L.ClassName]);
end;

procedure TMailerForm.SetVisible;
begin
  if V = (c in wcb) then Exit;
  if V then Include(wcb, c) else Exclude(wcb, c);
  L.Visible := V;
end;

procedure TMailerForm.UpdateProt;
const
  bsMsg: array[TBatchState] of Integer = (rsMMbsInit, rsMMbsDummy, rsMMbsEnd, rsMMbsIdle, rsMMbsWait);

var
  ela, a,b: Integer;
  bs: TBatchState;

procedure SetSndSize(B: Boolean);
begin
  SetVisible(lSndSize, wcb_lSndSize, B);
  SetVisible(llSndSize, wcb_llSndSize, B);
  SetVisible(SndBar, wcbSndBar, B);
end;

procedure SetRcvSize(B: Boolean);
begin
  SetVisible(lRcvSize, wcb_lRcvSize, B);
  SetVisible(llRcvSize, wcb_llRcvSize, B);
  SetVisible(RcvBar, wcbRcvBar, B);
  Btns := B;
end;

procedure SetSndCPS(B: Boolean);
begin
  SetVisible(lSndCPS, wcb_lSndCPS, B);
  SetVisible(llSndCPS, wcb_llSndCPS, B);
end;

procedure SetRcvCPS(B: Boolean);
begin
  SetVisible(lRcvCPS, wcb_lRcvCPS, B);
  SetVisible(llRcvCPS, wcb_llRcvCPS, B);
end;

procedure DoFill(const Strs: array of string);
var
  i: Integer;
  s: string;
  c: Twcs;
begin
  for i := Low(Strs) to High(Strs) do
  begin
    c := TWcs(i + Integer(wcsGrd1));
    s := Strs[i];
    if wcs[c] = s then Continue;
    wcs[c] := s;
    gNfo[0,i] := s;
  end;
end;

procedure SetSndTot(const B: Boolean);
begin
  SetVisible(SndTot, wcb_SndTot, B);
end;

procedure SetRcvTot(const B: Boolean);
begin
  SetVisible(RcvTot, wcb_RcvTot, B);
end;

procedure SetSndBar(C, M: Integer);
begin
  SetBar(SndBar, C, M, wciSndFilCur, wciSndFilMax);
end;

procedure SetRcvBar(C, M: Integer);
begin
  SetBar(RcvBar, C, M, wciRcvFilCur, wciRcvFilMax);
end;

procedure SetSndGauge(C, M: Integer);
begin
  SetGauge(SndTot, C, M, wciSndTotCur, wciSndTotMax);
end;

procedure SetRcvGauge(C, M: Integer);
begin
  SetGauge(RcvTot, C, M, wciRcvTotCur, wciRcvTotMax);
end;

var
  s: string;
  fpos, rxAdd, txAdd: DWORD;
  i: Integer;
begin

  with DS do DoFill([ConnectString, rmtStationName, rmtAddressList, rmtSysopName, rmtLocation, rmtPhone, rmtFlags, rmtSoft]);

  txAdd := 0;
  rxAdd := 0;

  if T = nil then
  begin
    SetSndSize(False);
    SetSndCPS(False);
    bs := bsIdle;
  end else
  begin
    if T.D.Start = 0 then
    begin
      SetSndSize(False);
      SetSndBar(0, 0);
      SetSndCPS(False);
      case T.D.State of
        bsInit, bsEnd: bs := T.D.State;
        else bs := bsWait;
      end;
    end else
    begin
      fpos := T.D.FPos;
      if AOutUsed < fpos then Dec(fpos, AOutUsed);
      ela := uGetSystemTime - T.D.Start;
      bs := bsActive;
      a := T.D.FSize;  b := fpos; LowerPrec(a, b, 7);
                                                      
      SetSndBar(b, a);

      txAdd := fpos;

      if fpos < T.D.FOfs then a := 0 else a := fpos - T.D.FOfs;
      SetLabel(lSndSize, wcsSndSize, Format('%s / %s', [Int2Str(MinD(fpos, T.D.FSize)), Int2Str(T.D.FSize)]));
      SetSndSize(True);
      if (ela < CPS_MinSecs) or (a < CPS_MinBytes) then
      begin
        SetSndCPS(False);
      end else
      begin
        i := a div ela;
        SetLabel(lSndCPS, wcsSndCPS, Int2Str(i));
        SetSndCPS(True);
      end;
    end;
  end;
  if bs = bsActive then s := T.D.FName
                   else s := LngStr(bsMsg[bs]);

  SetLabel(lSndFile, wcsSndFile, s);

  if R = nil then
  begin
    SetRcvSize(False);
    SetRcvCPS(False);
    bs := bsIdle;
  end else
  begin
    if R.D.Start = 0  then
    begin
      SetRcvSize(False);
      SetRcvBar(0, 0);

      SetRcvCPS(False);
      case R.D.State of
        bsInit, bsEnd: bs := R.D.State;
        else bs := bsWait;
      end;
    end else
    begin
      ela := uGetSystemTime - R.D.Start;
      bs := bsActive;

      a := R.D.FSize;  b := R.D.FPos + R.D.Part; LowerPrec(a, b, 7);

      SetRcvBar(b, a);

      rxAdd := R.D.FPos + R.D.Part;

      a := R.D.FPos + R.D.Part - R.D.FOfs;
      SetLabel(lRcvSize, wcsRcvSize, Format('%s / %s', [Int2Str(MinD(R.D.FPos+R.D.Part, R.D.FSize)), Int2Str(R.D.FSize)]));
      SetRcvSize(True);
      if (ela < CPS_MinSecs) or (a < CPS_MinBytes) then
      begin
        SetRcvCPS(False);
      end else
      begin
        i := a div ela;
        SetLabel(lRcvCPS, wcsRcvCPS, Int2Str(i));
        SetRcvCPS(True);
      end;
    end;
  end;

  if bs = bsActive then s := R.D.FName
                   else s := LngStr(bsMsg[bs]);

  SetLabel(lRcvFile, wcsRcvFile, s);


  a := D.TxTot; b := D.txBytes + txAdd;
  if (a=0) or (a<b) then
  begin
    SetSndTot(False)
  end else
  begin
    SetSndTot(True);
    SetSndGauge(b, a);
  end;

  a := D.rmtForUs; b := D.rxBytes + rxAdd;
  if (a=0) or (a<b) then
  begin
    SetRcvTot(False);
  end else
  begin
    SetRcvTot(True);
    SetRcvGauge(b, a);
  end;

  SetTopPageIndex(1);

end;

procedure TMailerForm.UpdateDial;
var               
  e: DWORD;
  s: string;
begin
  e := RemainingTimeSecs(D.TmrPublic);
  if e = High(e) then SetVisible(TimeoutBox, wcbTimeoutBox, False) else
  begin
    SetLabel(lTimeout, wcsTimeout, IntToStr(e));
    SetVisible(TimeoutBox, wcbTimeoutBox, True)
  end;
  if DS.StatusParam = '' then s := LngStr(D.StatusMsg) else s := FormatLng(D.StatusMsg, [DS.StatusParam]);
  SetLabel(lStatus, wcsStatus, s);
  SetTopPageIndex(0);
end;


procedure TMailerForm.UpdateLog;
var
  I: Integer;
  S, Z: string;
  TL: Boolean;
begin
  EnterCS(ActiveLine.LogCS);
  S := StrAsg(ActiveLine.NewLogStr); ActiveLine.NewLogStr := '';
  TL := ActiveLine.TruncateLog;
  ActiveLine.TruncateLog := False;
  LeaveCS(ActiveLine.LogCS);
  if TL then ActiveLine.LogStrings.FreeAll;
  if S = '' then Exit;
  while S <> '' do
  begin
    i := Pos(#13#10, S);
    Z := Copy(S, 1, i-1);
    Delete(S, 1, i+1);
    ActiveLine.LogStrings.Add(Z);
  end;
  while ActiveLine.LogStrings.Count > MaxLogStrings do ActiveLine.LogStrings.AtFree(0);
  InvalidateLogBox(ActiveLine);
end;

procedure TMailerForm.UpdateLamps;
var
  j: Integer;
  OK: Boolean;
begin
  if (ActiveLine = PanelOwnerPolls) or
     (ActiveLine = PanelOwnerOutMgr)
      {$IFDEF WS} or (ActiveLine = PanelOwnerDaemon) {$ENDIF}
  or (MailerThreads.IndexOf(ActiveLine) = -1) then Exit;
  EnterCS(ActiveLine.CP_CS);
  OK := ActiveLine.CP <> nil;
  if OK then j := ActiveLine.CP.LineStatus else j := 0;
  LeaveCS(ActiveLine.CP_CS);
  if not OK then Exit;
  mlDCD.Lit := j and MS_RLSD_ON <> 0;
  mlDSR.Lit := j and MS_DSR_ON <> 0;
  mlCTS.Lit := j and MS_CTS_ON <> 0;
  mlTXD.Lit := j and MS_TXD_ON <> 0;
  mlRXD.Lit := j and MS_RXD_ON <> 0;
end;


function SortPollsByDate(Item1, Item2: Pointer): Integer;
var
  P1: TFidoPoll absolute Item1;
  P2: TFidoPoll absolute Item2;
begin
  if P1.Birth = P2.Birth then Result := 0 else
  if P1.Birth < P2.Birth then Result := 1 else Result := -1;
end;


var
  OutMgrNodeCC: Integer;


function DoOutMgrNodeSort(Item1, Item2: Pointer): Integer;
  var C: Integer;
      N1: TOutItem absolute Item1;
      N2: TOutItem absolute Item2;
      N1F: TOutFile absolute Item1;
      N2F: TOutFile absolute Item2;

procedure Cmp0;
begin
  if N1 is TOutNode then C := CompareAddrs(N1.Address, N2.Address) else
     C := CompareText(N1.Name, N2.Name);
end;

begin
  case Abs(OutMgrNodeCC)-1 of
    0: Cmp0;
    1: begin
         if N1.Nfo.Size = N2.Nfo.Size then Cmp0 else
         if N1.Nfo.Size < N2.Nfo.Size then C := 1 else C := -1;
       end;
    2: if N1 is TOutFile then
       begin
         C := Integer(N1F.Status) - Integer(N2F.Status);
         if C = 0 then Cmp0;
       end else
       begin
         if N1.Nfo.Attr = N2.Nfo.Attr then Cmp0 else
         if N1.Nfo.Attr < N2.Nfo.Attr then C := 1 else C := -1;
       end;
    3: if N1 is TOutFile then
       begin
         C := Integer(N1F.KillAction) - Integer(N2F.KillAction);
         if C = 0 then Cmp0
       end else Cmp0;
    4: begin
         if N1.Nfo.Time = N2.Nfo.Time then Cmp0 else
         if N1.Nfo.Time < N2.Nfo.Time then C := 1 else C := -1;
       end;
    else GlobalFail('DoOutMgrNodeSort ... %d', [Abs(OutMgrNodeCC)-1]);
  end;
  if OutMgrNodeCC < 0 then C := -C;
  Result := C;
end;


procedure TMailerForm.UpdateViewOutMgr;
var
  i,j,k,cc,ccc,sitem: Integer;
  n: TOutNode;
  f: TOutFile;
  nn: TOutlineNode;
begin
  cc := CollMax(OutMgrNodes);
  OutMgrNodeCC := OutMgrNodeSort;
  if cc >=0 then OutMgrNodes.Sort(DoOutMgrNodeSort);
  for I := 0 to cc do
  begin
    n := OutMgrNodes[I];
    if n.Files <> nil then n.Files.Sort(DoOutMgrNodeSort);
  end;
  OutMgrOutline.BeginUpdate;
  OutMgrOutline.Clear;
  for i := 0 to cc do
  begin
    n := OutMgrNodes[i];
    j := OutMgrOutline.AddObject(0, Addr2Str(n.Address), n);
    if i = 0 then FirstOutMgrNode := n else
    if i = cc then LastOutMgrNode := n;
    ccc := CollMax(n.Files);
    for k := 0 to ccc do
    begin
      f := n.Files[k];
      with f.Nfo do
      begin
        Attr := 0;
        if i = cc then Attr := Attr or olfLastLevel;
        if k = ccc then Attr := Attr or olfLastItem;
      end;
      OutMgrOutline.AddChildObject(j, f.Name, f);
    end;
  end;
  if OutMgrSelectedItemInstead = -1 then sitem := -1 else
  begin
    sitem := MinI(OutMgrSelectedItemInstead, OutMgrOutline.ItemCount);
    OutMgrSelectedItemInstead := -1;
  end;
  for i := 1 to OutMgrOutline.ItemCount do
  begin
    nn := OutMgrOutline[i];
    n := nn.Data;
    if (sitem = -1) and
       (CompareAddrs(OutMgrSelectedItemAddr, n.Address) = 0) and
       (n.Name = OutMgrSelectedItemName) then
    begin
      sitem := i;
      if OutMgrExpanded = nil then Continue;
    end;
    if not nn.HasItems then Continue;
    if (OutMgrExpanded <> nil) and (OutMgrExpanded.Search(@n.Address, cc)) then nn.Expanded := True;
  end;
  if sitem > 0 then OutMgrOutline.SelectedItem := sitem;
  OutMgrOutline.EndUpdate;
end;




procedure TMailerForm.UpdateView;

procedure UpdateMlr;
var
  D: TDisplayData;
  DS: TDisplayStringData;
  T, R: TBatch;
  CPOutUsed: Integer;
  B: Boolean;
begin
  UpdateLog;
  EnterCS(ActiveLine.DisplayDataCS);
  D := ActiveLine.PublicD;
  DS := ActiveLine.PublicDS;
  if ActiveLine.PubBatchT <> nil then T := ActiveLine.PubBatchT.Copy else T := nil;
  if ActiveLine.PubBatchR <> nil then R := ActiveLine.PubBatchR.Copy else R := nil;
  LeaveCS(ActiveLine.DisplayDataCS);
  if not D.Initialised then Exit;
  CPOutUsed := D.CPOutUsed;
  SetVisible(LampsPanel, wcbLampsPanel, not (D.ExtApp or D.NoCP));
  B := False; 
  if (T = nil) and (R = nil) then UpdateDial(D, DS) else UpdateProt(D, DS, T, R, CPOutUsed, B);
  FreeObject(T);
  FreeObject(R);
  if D.SkipIs then B := False;
  SetEnabledO(mlSkip, wcb_mlSkip, B);
  SetEnabledO(mlRefuse, wcb_mlRefuse, B);
  SetEnabledO(bSkip, wcb_bSkip, B);
  SetEnabledO(bRefuse, wcb_bRefuse, B);
  SetEnabledO(mlAnswer, wcb_mlAnswer, D.CanAnswer);
  SetEnabledO(bAnswer, wcb_bAnswer, D.CanAnswer);
end;

procedure UpdatePolls;
const
  PT: array[TPollType] of Integer = (-1, rsMMptAuto, rsMMptCron, rsMMptManual);
var
  C: TColl;
  S: TStringColl;
  I, N: Integer;
  P: TFidoPoll;
  Z: string;
  PC: TPollColl;

begin
  C := TColl.Create;
  PC := TPollColl.Create;
  EnterFidoPolls;
  for I := 0 to FidoPolls.Count-1 do PC.Insert(FidoPolls[I]);
  PC.Sort(SortPollsByDate);
  for I := 0 to PC.Count-1 do
  begin
    P := PC[I];
    S := TStringColl.Create;
    S.Add(Addr2Str(P.Node.Addr));  // Node
    S.Add(NodeDataStr(P.Node, False));  // Phones & Flags
    case Integer(P.Owner) of
      Integer(nil):
        Z := LngStr(rsMMptNone);
      Integer(PollOwnerExtApp):
        Z := LngStr(rsMMptExtApp);
      {$IFDEF WS}
      Integer(PollOwnerDaemon):
        Z := LngStr(rsMMptDaemon);
      {$ENDIF}
      else Z := P.Owner.Name;
    end;
    S.Add(Z);  // Owner
    if (P.Owner = nil) or (P.Owner = PollOwnerExtApp) then N := rsMMpsIdle else
    {$IFDEF WS}
    if P.Owner = PollOwnerDaemon then N := rsMMpsConnect else
    {$ENDIF}
    case
      P.Owner.State of

        msDialling              : N := rsMMpsDialling;
        msRinging               : N := rsMMpsRinging;
        __FirstCN..__LastCN     : N := rsMMpsConnect;
        __FirstHSh..__LastHSh   : N := rsMMpsHSh;
        __FirstEMSI..__LastEMSI : N := rsMMpsEMSI;
        __FirstWZ..__LastWZ     : N := rsMMpsWZ;
        __FirstExtApp..__LastExtApp : N := rsMMpsExtrnl;
        else N := rsMMpsUnk;
    end;

    S.Add(LngStr(N)); // State
    S.Add(P.STryBusy);
    S.Add(P.STryNoC);
    S.Add(P.STryFail);
    S.Add(LngStr(PT[P.Typ]));  // Type
    C.Insert(S);
  end;
  LeaveFidoPolls;
  PC.DeleteAll;
  FreeObject(PC);
  Inc(ListUpd);
  UpdateDetailsBox(PollsListView, C);
  Dec(ListUpd);
  FreeObject(C);
end;

procedure SetLineCommands(B: Boolean);
var
  Z: Boolean;
begin
  SetEnabledO(mlClose, wcb_mlClose, B);
  SetEnabledO(mlAbortOperation,  wcb_mlAbortOperation, B);
  {$IFDEF WS}
  if (not B) or (not ActiveLine.DialupLine) then SetEnabledO(mlSendMdmCmds, wcb_mlSendMdmCmds, False) else
  {$ENDIF}
  SetEnabledO(mlSendMdmCmds, wcb_mlSendMdmCmds, B and (AllowedMdmCmdState(ActiveLine.State) and (ActiveLine.CP <> nil)));
  if B then
  begin
    if (ActiveLine = PanelOwnerPolls) or
       (ActiveLine = PanelOwnerOutMgr)
    {$IFDEF WS} or (ActiveLine = PanelOwnerDaemon) {$ENDIF}
     then GlobalFail('%s', ['SetLineCommands']);
    Z := TimerInstalled(ActiveLine.D.TmrPublic)
  end else Z := False;
  SetEnabledO(mlResetTimeout, wcb_mlResetTimeout, Z);
  SetEnabledO(mlIncTimeout, wcb_mlIncTimeout, Z);
  if B then Z := False else Z := PollsListView.ItemFocused <> nil;

  SetEnabledO(mpTrace, wcb_mpTrace, Z);
  SetEnabledO(bTracePoll, wcb_bTracePoll, Z);
  SetEnabledO(ppTracePoll, wcb_ppTracePoll, Z);

  SetEnabledO(mpReset, wcb_mpReset, Z);
  SetEnabledO(bResetPoll, wcb_bResetPoll, Z);
  SetEnabledO(ppResetPoll, wcb_ppResetPoll, Z);

  SetEnabledO(mpDelete, wcb_mpDelete, Z);
  SetEnabledO(bDeletePoll, wcb_bDeletePoll, Z);
  SetEnabledO(ppDeletePoll, wcb_ppDeletePoll, Z);

  Z := FidoPolls.Count > 0;
  SetEnabledO(mpDeleteAll, wcb_mpDeleteAll, Z);
  SetEnabledO(bDeleteAllPolls, wcb_bDeleteAllPolls, Z);
  SetEnabledO(ppDeleteAllPolls, wcb_ppDeleteAllPolls, Z);
end;

  {$IFDEF WS}
procedure UpdateDaemon;
begin
  EnterCS(TCPIP_GrCS);
  Move(TCPIP_OutGr, gOutputGraph.Data, SizeOf(gOutputGraph.Data));
  Move(TCPIP_InGr, gInputGraph.Data, SizeOf(gInputGraph.Data));
  gOutputGraph.GridStep := TCPIP_GrStep;
  gInputGraph.GridStep := TCPIP_GrStep;
  gOutput.Value := TCPIP_OutR;
  gInput.Value := TCPIP_InR;
  LeaveCS(TCPIP_GrCS);
  gOutput.Invalidate;
  gInput.Invalidate;
  gOutputGraph.Invalidate;
  gInputGraph.Invalidate;
end;
  {$ENDIF}

procedure SetMasterKeyCommands(B: Boolean);
begin
  SetEnabledO(mcMasterPwdCreate, wcb_MasterKeyCreate, B);
  B := not B;
  SetEnabledO(mcMasterPwdChange, wcb_MasterKeyChange, B);
  SetEnabledO(mcMasterPwdRemove, wcb_MasterKeyRemove, B);
end;

var
  ClearMlr, B, OutMgrTab: Boolean;
begin
  if ApplicationDowned then Exit;
  ClearMlr := True;
  B := False;
  OutMgrTab := False;
  case Integer(ActiveLine) of
  {$IFDEF WS}
    Integer(PanelOwnerDaemon): UpdateDaemon;
  {$ENDIF}
    Integer(PanelOwnerOutMgr): OutMgrTab := True; // OutMgr needs no updating
    Integer(PanelOwnerPolls): UpdatePolls;
    else
    begin
      if MailerThreads.IndexOf(ActiveLine) = -1 then GlobalFail('%s', ['TMailerForm.UpdateView, MailerThreads.IndexOf(ActiveLine) = -1']);
      UpdateMlr;
      B := True;
      ClearMlr := False;
    end;
  end;
  SetEnabledO(mtOutSmartMenu, wcb_OutSmartMenu, OutMgrTab);
  SetLineCommands(B);
  if ClearMlr then
  begin
    SetEnabledO(mlSkip, wcb_mlSkip, False);
    SetEnabledO(mlRefuse, wcb_mlRefuse, False);
    SetEnabledO(bSkip, wcb_bSkip, False);
    SetEnabledO(bRefuse, wcb_bRefuse, False);
    SetEnabledO(mlAnswer, wcb_mlAnswer, False);
    SetEnabledO(bAnswer, wcb_bAnswer, False);
  end;
  SetMasterKeyCommands(Cfg.MasterKey = 0);
  {$IFDEF WS}
  mfRunIPDaemon.Checked := DaemonStarted;
  {$ENDIF}
end;

procedure TMailerForm.MainTabControlChange(Sender: TObject);

procedure GetActiveLine;
var
  i: Integer;
{$IFDEF WS}
  j, ch: Integer;
  m: TMailerThread;
{$ENDIF}
begin
  ActiveLine := nil;
  i := MainTabControl.TabIndex;
{$IFDEF WS}
  ch := 0;
  for j := 0 to MailerThreads.Count-1 do
  begin
    m := MailerThreads[j];
    if not m.DialupLine then Continue;
    if ch = i then begin ActiveLine := m; Exit end;
    Inc(ch);
  end;
  if ch = i then begin ActiveLine := PanelOwnerPolls; Exit end;
  Inc(ch);
  if ch = i then begin ActiveLine := PanelOwnerOutMgr; Exit end;
  Inc(ch);
  if ch = i then begin ActiveLine := PanelOwnerDaemon; Exit end;
  Inc(ch);
  for j := 0 to MailerThreads.Count-1 do
  begin
    m := MailerThreads[j];
    if m.DialupLine then Continue;
    if ch = i then begin ActiveLine := m; Exit end;
    Inc(ch);
  end;

{$ELSE}
  case MainTabControl.Tabs.Count-i of
    1 : ActiveLine := PanelOwnerOutMgr;
    2 : ActiveLine := PanelOwnerPolls;
    else ActiveLine := MailerThreads[i]
  end;
{$ENDIF}
  if ActiveLine = nil then ActiveLine := PanelOwnerPolls;
end;

var
  s,z: string;
  DoClearTerms: Boolean;

begin
  DoClearTerms := True;
  GetActiveLine;
  case Integer(ActiveLine) of
    Integer(PanelOwnerOutMgr):
    begin
      SetTopPageIndex(4);
      SetBtmPageIndex(3);
      s := LngStr(rsMMwcOutMgr);
      LogBox.Lines := nil;
    end;
    Integer(PanelOwnerPolls):
    begin
      SetTopPageIndex(2);
      SetBtmPageIndex(1);
      LogBox.Lines := FidoPolls.Log.Strings;
      s := LngStr(rsMMwcPollMgr);
    end;
  {$IFDEF WS}
    Integer(PanelOwnerDaemon):
    begin
      SetTopPageIndex(3);         
      SetBtmPageIndex(2);
      LogBox.Lines := IPPolls.LogContainer.Strings;
      s := LngStr(rsMMwcDaemon);
    end;
  {$ENDIF}
    else
    begin
      SetBtmPageIndex(0);
      LogBox.Lines := ActiveLine.LogStrings;
      UpdateLamps;
      TermTx.Data := ActiveLine.TermTxData;
      TermRx.Data := ActiveLine.TermRxData;
      TermTx.Invalidate;
      TermRx.Invalidate;
      DoClearTerms := False;
      s := ActiveLine.Name;
    end;
  end;
  if Application.MainForm = Self then z := LngStr(rsMMwcMain) else z := FormatLng(rsMMwcMirror,[MailerForms.IndexOf(Self)]);
  Caption := FormatLng(rsMMwcArgus, [z, s]);
  if DoClearTerms then
  begin
    TermTx.Data := nil;
    TermRx.Data := nil;
  end;
  UpdateView;
end;

procedure TMailerForm.bAbortClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtChStatus.Create(msCancel));
end;

procedure TMailerForm.bStartClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtClearTmrPublic.Create);
end;

procedure TMailerForm.bAddClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtIncTmrPublic.Create);
end;

procedure FreeAllLines;
var
  i: Integer;
begin
  {$IFDEF WS}
  if DaemonStarted then _ShutdownDaemon;
  {$ENDIF}
  for i := 0 to MailerThreads.Count-1 do TMailerThread(MailerThreads[i]).InsertEvt(TMlrEvtShutdownTerminate.Create);
  for i := 0 to MailerThreads.Count-1 do TMailerThread(MailerThreads[i]).WaitFor;
  while MailerThreads.Count > 0 do Application.ProcessMessages;
end;

procedure FreeAllForms;
var
  i: Integer;
  f: TForm;
begin
  for i := MailerForms.Count - 1 downto 0 do
  begin
    f := MailerForms[i]; f.Free;
  end;
  PurgeZombies;
end;

procedure FreeAllPolls(Action: TPollDone; All: Boolean);
var
  i: Integer;
  p: TFidoPoll;
begin
  EnterFidoPolls;
  for i := FidoPolls.Count-1 downto 0 do
  begin
    p := FidoPolls[i];
    if All or (p.Owner = PollOwnerExtApp) or (p.Owner = nil) then
    begin
      p.Done := Action;
      FidoPolls.AtFree(i);
    end;
  end;
  LeaveFidoPolls;
end;

procedure TMailerForm.FormDestroy(Sender: TObject);
begin
  FreeObject(TrayIcon);
  FreeObject(OutMgrExpanded);
  FreeObject(OutMgrBM);
  FreeObject(OutMgrBmps[0]);
  FreeObject(OutMgrBmps[1]);
  FreeObject(OutMgrBmps[2]);
  FreeObject(OutMgrNodes);
  MailerForms.Delete(Self);
  if Application.MainForm <> Self then PostMsg(WM_TABCHANGE) else FreeAllForms;
end;

var
  HelpDone,
  HelpInitialized: Boolean;

procedure TMailerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  if _Closed then Exit;
  _Closed := True;
  Inc(ListUpd);
  if Application.MainForm = Self then
  begin
    if HelpInitialized then
    begin
      HelpInitialized := False;
      HelpDone := True;
      HtmlHelp(0, '', HH_UNINITIALIZE, 0);
    end;
    SetEvt(oShutdown);
    if not KillTimer(MainWinHandle, 1) then GlobalFail('KillTimer Error %d', [GetLastError]);
    icvMainFormL := Left;
    icvMainFormT := Top;
    icvMainFormW := Width;
    icvMainFormH := Height;
  end;
end;

procedure TMailerForm.mcPathnamesClick(Sender: TObject);
begin
  SetupPathNames;
end;

procedure TMailerForm.mwCreateMirrorClick(Sender: TObject);
begin
  OpenMailerForm(ActiveLine, True);
  PostMsg(WM_UPDOUTMGR);
  PostMsg(WM_UPDATEMENUS);
end;

procedure TMailerForm.mcDialupClick(Sender: TObject);
begin
  DialupSetup(0);
end;

procedure TMailerForm.NodesPasswords1Click(Sender: TObject);
begin
  SetupPasswords;
end;

function OpenMailer(LineId: DWORD; Handle: DWORD): TMailerThread;

var
  r: TPortRec;

procedure DoOpen;
var
  cw, ch, i,j: Integer;
  m: TMailerThread;
  p: TPort;
begin
  m := nil;
  j := -1;
  for i := 0 to MailerThreads.Count - 1 do
  begin
    m := MailerThreads[i];
    if m.LineId = LineId then
    begin
      j := i;
      if Handle <> INVALID_HANDLE_VALUE then DisplayErrorLng(rsMMAlrAct, Handle);
      Break
    end;
  end;
  if j = -1 then
  begin
    r := GetPortRec(LineId);
    p := OpenSerialPort(r);
    if p = nil then
    begin
      if Handle <> INVALID_HANDLE_VALUE then DisplayErrorFmtLng(rsMMCantOpenPort, [ComName(R.d.Port)], Handle);
      Exit;
    end;
    GetTermBounds(cw, ch);
    m := OpenMailerThread(p, LineId {$IFDEF WS}, nil{$ENDIF}, cw, ch);
  end;
  Result := m;
end;

begin
  Result := nil;
  r := nil;
  DoOpen;
  FreeObject(r);
end;

procedure TMailerForm.LineOpenClick(Sender: TObject);
var
  mt: TMailerThread;
begin
  mt := OpenMailer(TMenuItem(Sender).Tag, Handle);
  if mt <> nil then ActiveLine := mt;
  PostMsg(WM_UPDATETABS);
  PostMsg(WM_TABCHANGE);
  PostMsg(WM_UPDATEMENUS);
end;

procedure TMailerForm.mlCloseClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtOperatorTerminate.Create);
end;

function TMailerForm.PollAnyway(an: TAdvNode): Boolean;
begin
  case an.PrefixFlag of
    nfPvt, nfHold, nfDown:
      begin
        Result := YesNoConfirm(Format('Node %s (%s from %s) has %s status in the nodelist. Create poll anyway?', [Addr2Str(an.Addr), an.Sysop, an.Location, cNodePrefixFlag[an.PrefixFlag]]), Handle)
      end;
    else
    Result := True;
  end;

end;

procedure TMailerForm.InsertPollAddress(const A: TFidoAddress);
var
  an: TAdvNode;
begin
  an := FindNode(A);
  if an = nil then
  begin
    DisplayErrorFmtLng(rsMMUnlistedNode, [Addr2Str(A)], Handle);
  end else
  begin
    if PollAnyway(an) then InsertPoll(an, ptpManual);
  end;
end;

procedure TMailerForm.bNewPollClick(Sender: TObject);
begin
  NewPoll;
end;

procedure TMailerForm.PollsListViewChange(Sender: TObject; Item: TListItem;
  Change: TItemChange);
begin
  Inc(ListUpd);
  if ListUpd = 1 then MainTabControlChange(nil);
  Dec(ListUpd);
end;

procedure TMailerForm.PollsListViewClick(Sender: TObject);
begin
  Inc(ListUpd);
  if ListUpd = 1 then MainTabControlChange(nil);
  Dec(ListUpd);
  UpdateView;
end;

procedure TMailerForm.mfExitClick(Sender: TObject);
begin
  _PostMessage(Application.MainForm.Handle, WM_CLOSE, 0, 0);
end;

procedure TMailerForm.mtBrowseNodelistClick(Sender: TObject);
begin
  BrowseNodes;
end;

procedure TMailerForm.mwCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TMailerForm.mhAboutClick(Sender: TObject);
begin
  ShowAbout;
end;

procedure TMailerForm.bDeletePollClick(Sender: TObject);
var
  p: TFidoPoll;
  li: TListItem;
  i: Integer;
  CantDelete: Boolean;
  s: string;
  a: TFidoAddress;
begin
  CantDelete := False;
  li := PollsListView.ItemFocused;
  if li <> nil then
  begin
    s := li.Caption;
    if not ParseAddress(s, a) then GlobalFail('TMailerForm.bDeletePollClick, failed to parse "%s"', [s]);
    EnterFidoPolls;
    for i := 0 to FidoPolls.Count-1 do
    begin
      p := FidoPolls[i];
      if CompareAddrs(a, p.Node.Addr) = 0 then
      begin
        if (p.Owner = PollOwnerExtApp) or (p.Owner = nil) then
        begin
          p.Done := pdnDeleted;
          FidoPolls.AtFree(i);
        end else
        begin
          CantDelete := True;
          s := FormatLng(rsMMCDBP, [PollOwnerName(p)]);
        end;
        Break;
      end;
    end;
    LeaveFidoPolls;
  end;
  PostMsg(WM_UPDATEVIEW);
  if CantDelete then DisplayError(s, Handle);
end;

procedure TMailerForm.bResetPollClick(Sender: TObject);
var
  p: TFidoPoll;
  li: TListItem;
  i: Integer;
  s: string;
  a: TFidoAddress;
begin
  li := PollsListView.ItemFocused;
  if li <> nil then
  begin
    s := li.Caption;
    if not ParseAddress(s, a) then GlobalFail('TMailerForm.bResetPollClick, failed to parse "%s"', [s]);
    EnterFidoPolls;
    for i := 0 to FidoPolls.Count-1 do
    begin
      p := FidoPolls[i];
      if CompareAddrs(a, p.Node.Addr) = 0 then
      begin
        p.Reset;
        Break;
      end;
    end;
    LeaveFidoPolls;
  end;
  PostMsg(WM_UPDATEVIEW);
end;

procedure TMailerForm.bDeleteAllPollsClick(Sender: TObject);
begin
  FreeAllPolls(pdnDeleteAll, False);
  PostMsg(WM_UPDATEVIEW);
end;

procedure TMailerForm.PrepareGtitles;
var
  gw, i: Integer;
  Extent: TSize;
  s: string;
begin
  GridFillRowLng(gTitles, rsMMTitlesGrid);
  gTitles.Canvas.Font := gTitles.FixedFont;
  gw := 0;
  for i := 0 to gTitles.RowCount-1 do
  begin
    s := gTitles[0, i] + 'M';
    GetTextExtentPoint32(gTitles.Canvas.Handle, @s[1], Length(s), Extent);
    gw := MaxI(gw, Extent.cX);
  end;
  gTitles.Width := gw;
  gTitles.DefaultColWidth := gw-1;
end;

procedure TMailerForm.LoadOutMgrBmp(i: Integer; const AName: string; AColor: TColor);
var
  B,C: TBitmap;
  R: TRect;
begin
  FreeObject(OutMgrBmps[i]);
  B := TBitmap.Create;
  B.LoadFromResourceName(hInstance, AName);
  R := Rect(0, 0, B.Width, B.Height);
  C := TBitmap.Create;
  C.Width  := R.Right;
  C.Height := R.Bottom;
  C.Canvas.Brush.Color := OutMgrOutline.Color;
  C.Canvas.BrushCopy(R, B, R, AColor);
  OutMgrBmps[i] := C;
  FreeObject(B);
end;


procedure TMailerForm.ExceptionEvent(Sender: TObject; E: Exception);
var
  s, em: string;
begin
  if Sender = nil then s := 'Application' else
  begin
    s := 'App/'+Sender.ClassName;
    if Sender is TComponent then s := s+'/'+TComponent(Sender).Name;
  end;
  if TObject(E) is Exception then em := E.Message else em := 'UnkExpt';
  ProcessTrap(em, s);
end;


procedure TMailerForm.FormCreate(Sender: TObject);

procedure InitOutMgrPopup;
var
  i,j: Integer;
  m,k,n: TMenuItem;
begin
  for i := 0 to OutMgrPopup.Items.Count-1 do
  begin
    m := OutMgrPopup.Items[i];
    if m.Tag > 1 then
    begin
      for j := 0 to ompCur.Count-1 do
      begin
        k := ompCur.Items[j];
        n := TMenuItem.Create(m);
        n.Caption := k.Caption;
        n.OnClick := k.OnClick;
        m.Add(n);
      end;
    end;
  end;
end;


begin

  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    aOutbound := nil;
    try
      aOutbound := TAnimate.Create(Self);
      aOutbound.Align := alRight;
      aOutbound.Width := 78;
      aOutbound.Center := True;
      OutMgrBtnPanel.InsertControl(aOutbound);
    except
      FreeObject(aOutbound);
    end;
  end;

  OutMgrSelectedItemInstead := -1;
  OutMgrNodeSort := 1;
  OutMgrBM := TBitmap.Create;
  UpdateBoundsOutMgrBM;

  LoadOutMgrBmp(ioFolders, 'FOLDERS', clAqua);
  LoadOutMgrBmp(ioLines,   'LINES',   clWhite);

  TopPagePanels[wcb_TopPage0] := MailerAPanel;
  TopPagePanels[wcb_TopPage1] := MailerBPanel;
  TopPagePanels[wcb_TopPage2] := PollsListPanel;
  TopPagePanels[wcb_TopPage3] := DaemonPanel;
  TopPagePanels[wcb_TopPage4] := OutMgrPanel;

  BtmPagePanels[wcb_BtmPage0] := MailerBtnPanel;
  BtmPagePanels[wcb_BtmPage1] := PollBtnPanel;
  BtmPagePanels[wcb_BtmPage2] := DaemonBtnPanel;
  BtmPagePanels[wcb_BtmPage3] := OutMgrBtnPanel;

  FillForm(Self, rsMailerForm);
  StartSize.X := Width;
  StartSize.Y := Height;

  {$IFDEF WS}
  mfRunIPDaemon.Enabled := True;
  {$ELSE}
  msLineA.Free;
  mfRunIPDaemon.Free;
  mcDaemon.Free;
  DaemonPanel.Free;
  {$ENDIF}

  if Application.MainForm = nil then
  begin
    Application.OnException := ExceptionEvent;
    Application.OnHelp := FormHelp;

    if (icvMainFormL <> High(icvMainFormL)) and
       (icvMainFormT <> High(icvMainFormT)) and
       (icvMainFormW <> High(icvMainFormW)) and
       (icvMainFormH <> High(icvMainFormH))
     then SetBounds(icvMainFormL, icvMainFormT, icvMainFormW, icvMainFormH);
  end;
  hlRussian.Enabled := RussianHelp;
  hlEnglish.Enabled := EnglishHelp;
  hlGerman.Enabled := GermanHelp;
  hlDanish.Enabled := DanishHelp;
  hlSpanish.Enabled := SpanishHelp;
  hlDutch.Enabled := DutchHelp;
  case HelpLanguageId of
    HelpLanguageRussian: hlRussian.Checked := True;
    HelpLanguageEnglish: hlEnglish.Checked := True;
    HelpLanguageGerman: hlGerman.Checked := True;
    HelpLanguageSpanish: hlSpanish.Checked := True;
    HelpLanguageDutch: hlDutch.Checked := True;
    HelpLanguageDanish: hlDanish.Checked := True;
  end;
  if HelpLanguageId = 0 then
  begin
    mhContents.Enabled := False;
    mhLanguage.Enabled := False;
  end;
  InitOutMgrPopup;
end;

procedure TMailerForm.WMStartMdmCmd(var M: TMessage);
var
  ModemCmdForm: TModemCmdForm;
  r: TModalResult;
  P: TPoint;
begin
  repeat
    ModemCmdForm := TModemCmdForm.Create(Self);
    P.X := StatusBox.Left;
    P.Y := StatusBox.Top+StatusBox.Height;
    P := StatusBox.ClientToScreen(P);
    ModemCmdForm.Left := P.X-32;
    ModemCmdForm.Top := P.Y+8;
    ModemCmdForm.P := Self;
    r := ModemCmdForm.ShowModal;
    FreeObject(ModemCmdForm);
  until r <> mrOK;
  InsertEvt(TMlrEvtChStatus.Create(msInit));
end;

procedure TMailerForm.WMGetMinMaxInfo(var AMsg: TWMGetMinMaxInfo);
var
  MM: TMinMaxInfo;
begin
  MM := AMsg.MinMaxInfo^;
  MM.ptMinTrackSize := StartSize;
  AMsg.MinMaxInfo^ := MM;
end;

procedure TMailerForm.WMTrayRC;
begin
  SetForegroundWindow(Handle);
  TrayIcon.DoRightClick(TObject(M.lParam));
end;

procedure TMailerForm.WMAppMinimize;
begin
  Application.Minimize;
end;

procedure TMailerForm.mhLicenceClick(Sender: TObject);
begin
  ShowLicence;
end;

procedure SwitchDaemon(Handle: DWORD);
begin
{$IFDEF WS}
  if DaemonStarted then
  begin
    if (Handle = INVALID_HANDLE_VALUE) or (OkCancelConfirmLng(rsMMcloseDaemon, Handle)) then _ShutdownDaemon else Exit;
  end else
  begin
    _RunDaemon;
  end;
  PostMsg(WM_UPDATETABS);
  PostMsg(WM_TABCHANGE);
  PostMsg(WM_UPDATEMENUS);
  {$ELSE}
  GlobalFail('%s', ['mfRunIPDaemonClick']);
  {$ENDIF}
end;

procedure TMailerForm.mfRunIPDaemonClick(Sender: TObject);
begin
  SwitchDaemon(Handle);
end;

procedure DoneMsgDispatcher;
begin
  FreeObject(MsgDispatcher);
end;

procedure TMailerForm.mcStartupClick(Sender: TObject);
begin
  StartupConfiguration;
end;

procedure TMailerForm.mtCompileNodelistClick(Sender: TObject);
begin
  if YesNoConfirmLng(rsMMokCompileNdl,Handle) then VCompileNodelist(False);
end;

procedure TMailerForm.mcNodelistClick(Sender: TObject);
begin
  SetupNodelist;
end;

procedure TMailerForm.mcDaemonClick(Sender: TObject);
begin
  {$IFDEF WS}
  SetupIP(0);
  {$ENDIF}
end;

procedure TMailerForm.mhContentsClick(Sender: TObject);
begin
  _PostMessage(Application.Handle, CM_INVOKEHELP, HELP_CONTENTS, 0);
end;

procedure TMailerForm.mhWebSiteClick(Sender: TObject);
begin
  ShellExecute(Handle, { handle to parent window }
               nil,    { pointer to string that specifies operation to perform }
               'http://www.ritlabs.com/argus/',
               nil,    { pointer to string that specifies executable-file parameters }
               nil,    { pointer to string that specifies default directory }
               SW_SHOWNORMAL);
end;

procedure TMailerForm.mhHelpClick(Sender: TObject);
begin
  _PostMessage(Application.Handle, CM_INVOKEHELP, HELP_HELPONHELP, 0);
end;

procedure TMailerForm.bTracePollClick(Sender: TObject);
var
  SC, LC: TStringColl;
  p: TFidoPoll;
  li: TListItem;
  i: Integer;
  TQ: TFSC62Quant;
  m: TMailerThread;
  AV: Boolean;


procedure AddHdr;
var
  s: string;
begin
  case p.Node.PrefixFlag of
    nfPvt, nfHold, nfDown: s := Format(' (%s)', [cNodePrefixFlag[p.Node.PrefixFlag]]);
  end;

  if P.Node.Location = '' then SC.Add(FormatLng(rsMMStationHdrA,[Addr2Str(p.Node.Addr)])+s) else
  begin
    SC.Add(FormatLng(rsMMStationHdrB, [p.Node.Station, Addr2Str(p.Node.Addr)])+s);
    SC.Add(FormatLng(rsMMSysopHdr, [p.Node.Sysop, p.Node.Location]));
  end;                                              
  SC.Add('');
end;


procedure ChkPS(a, b: Pointer);
begin
  if AV then
  begin
    case GetPollState(a, P, False, b, LC, TQ) of
      plsAVL : FidoOut.Unlock(p.Node.Addr);
      plsFRB :;
      else AV := False;
    end;
  end;
end;

const
  PtpTyp: array[TPollType] of Integer = (0, rsMMptpiOutb, rsMMptpiCron, rsMMptpiManual);

var
  s: string;
  a: TFidoAddress;
  ii: Integer;
begin
  li := PollsListView.ItemFocused;
  if li <> nil then
  begin
    s := li.Caption;
    if not ParseAddress(s, a) then GlobalFail('TMailerForm.bTracePollClick, failed to parse "%s"', [s]);
    EnterFidoPolls;
    for i := 0 to FidoPolls.Count-1 do
    begin
      p := FidoPolls[i];
      if CompareAddrs(a, p.Node.Addr) = 0 then
      begin
        AV := True;
        SC := TStringColl.Create;
        LC := TStringColl.Create;
        TQ := CurFSC62Quant;
        AddHdr;

        {$IFDEF WS}
        if DaemonStarted then
        begin
          ChkPS(IPPolls.OwnPolls, PollOwnerDaemon);
          if AV then
          begin
            LC.Ins0('--- TCP/IP Daemon');
            LC.Ins0('');
          end;
          SC.Concat(LC);
        end;
        {$ENDIF}

        for ii := 0 to MailerThreads.Count-1 do
        begin
          m := MailerThreads[ii];
          {$IFDEF WS}
          if not m.DialupLine then Continue;
          {$ENDIF}
          ChkPS(m.OwnPolls, m);
          if AV then
          begin
            LC.Ins0((Format('--- %s', [m.Name])));
            LC.Ins0('');
          end;
          SC.Concat(LC);
        end;
        FreeObject(LC);
        if AV then
        begin
          SC.Ins0('');
          SC.Ins0(LngStr(PtpTyp[p.typ]));
        end;
        LeaveFidoPolls;
        DisplayInfoFormEx(FormatLng(rsMMPollNfoC, [Addr2Str(a)]), SC);
        FreeObject(SC);
        Exit;
      end;
    end;
    LeaveFidoPolls;
  end;
end;

procedure TMailerForm.mcExternalsClick(Sender: TObject);
begin
  if ConfigureExternals then CronThr.Recalc := True;
end;

procedure TMailerForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  c, i: Integer;
begin
  case Key of
    VK_TAB: if ssCtrl in Shift then
      begin
        i := MainTabControl.TabIndex;
        c := MainTabControl.Tabs.Count;
        if ssShift in Shift then
        begin
          Dec(i); if i < 0 then i := c-1;
        end else
        begin
          Inc(i); if i = c then i := 0;
        end;
        MainTabControl.TabIndex := i;
        MainTabControlChange(nil);
      end;   
  end;    
end;

procedure TMailerForm.hlRussianClick(Sender: TObject);
begin
  Application.HelpFile := GetHelpFile('rus');
  hlRussian.Checked := True;
  HelpLanguageId := HelpLanguageRussian;
  SetRegHelpLng('rus');
end;

procedure TMailerForm.hlEnglishClick(Sender: TObject);
begin
  Application.HelpFile := GetHelpFile('eng');
  hlEnglish.Checked := True;
  HelpLanguageId := HelpLanguageEnglish;
  SetRegHelpLng('eng');
end;

procedure TMailerForm.hlGermanClick(Sender: TObject);
begin
  Application.HelpFile := GetHelpFile('ger');
  hlGerman.Checked := True;
  HelpLanguageId := HelpLanguageGerman;
  SetRegHelpLng('ger');
end;


procedure TMailerForm.mclEnglishUKClick(Sender: TObject);
var
  i: Integer;
  f: TMailerForm;
begin
  if MailerForms = nil then Exit;
  for i := 0 to MailerForms.Count-1 do with TMailerForm(MailerForms.At(i)) do
  begin
    Shown := False;
    Hide;
  end;
  i := TComponent(Sender).Tag;
  if not SetRegInterfaceLng(i) then
  begin
    DisplayErrorLng(rsCantUpdateReg, Handle);
    Exit;
  end;
  SetLanguage(i);
  for i := 0 to MailerForms.Count-1 do
  begin
    f := MailerForms.At(i);
    FillForm(f, rsMailerForm);
    f.UpdateView;
  end;
  UpdateTabsAll;
  TabChangeAll;
  for i := 0 to MailerForms.Count-1 do with TMailerForm(MailerForms.At(i)) do Show;
end;

procedure TMailerForm.FormShow(Sender: TObject);
begin
  if Shown then Exit;
  Shown := True;
  case CurrentLng of
    idlEnglish: ilEnglishUK.Checked := True;
    {$IFDEF LNG_RUSSIAN} idlRussian: ilRussian.Checked := True; {$ENDIF}
    {$IFDEF LNG_GERMAN}  idlGerman : ilGerman.Checked := True;  {$ENDIF}
    {$IFDEF LNG_SPANISH} idlSpanish: ilSpanish.Checked := True; {$ENDIF}
    {$IFDEF LNG_DUTCH}   idlDutch  : ilDutch.Checked := True;   {$ENDIF}
    {$IFDEF LNG_DANISH}  idlDanish : ilDanish.Checked := True;   {$ENDIF}
  end;
  InvalidateLabels;
  PrepareGtitles;
end;

procedure TMailerForm.maEventsClick(Sender: TObject);
begin
  SetupEvents;
end;

procedure TMailerForm.bSkipClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtSkip.Create);
end;

procedure TMailerForm.bRefuseClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtRefuse.Create);
end;

procedure TMailerForm.bAnswerClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtAnswer.Create);
end;

procedure TMailerForm.maFileRequestsClick(Sender: TObject);
begin
  SetupFileRequests;
end;

procedure TMailerForm.mtEditFileRequestClick(Sender: TObject);
begin
  EditFileRequest;
end;

///////////////////////////////////////////////////////////////////////
//                                                                   //
//                      OUTBOUND MANAGER                             //
//                                                                   //
///////////////////////////////////////////////////////////////////////


procedure TMailerForm.OutMgrOutlineDrawItem(Control: TWinControl; Index: Integer; R: TRect; State: TOwnerDrawState);
var
  I: Integer;
  F: TOutItem;
  N: TOutlineNode;
  zzz, S: string;
  R1,RR: TRect;

procedure DrawStr(AFlags: DWORD; const AStr: string);
begin
  if R.Left < R.Right then DrawText(OutMgrBM.Canvas.Handle, PChar(AStr), Length(AStr), R, DT_END_ELLIPSIS or DT_NOCLIP or DT_NOPREFIX or AFlags);
end;

begin
  N := OutMgrOutline.GetVisibleNode(Index);
  if OutMgrBM.Height < R.Bottom - R.Top then OutMgrBM.Height := R.Bottom - R.Top;
  if OutMgrBM.Width < R.Right - R.Left then OutMgrBM.Width := R.Right - R.Left;
  RR := R;
  R := Rect(0, 0, RR.Right-RR.Left, RR.Bottom - R.Top);
  with OutMgrBM.Canvas do
    begin
      Brush.Color := clWindow;
      Font.Color := clWindowText;
      FillRect(Rect(R.Left, R.Top, R.Left+(Integer(N.Level)+1)*16, R.Bottom));
      F := N.Data;
      if N.Level = 1 then
      begin
        if f = FirstOutMgrNode then I := 2 else
        if f = LastOutMgrNode then I := 1 else I := 0;
        if N.HasItems then
        begin
          Inc(I, 3);
          if N.Expanded then Inc(I, 3);
        end;
      end else
      begin
        if (f.Nfo.Attr and olfLastItem = 0) then I := 0 else I := 1;
        if (f.Nfo.Attr and olfLastLevel = 0) then BitBlt(Handle, R.Left, R.Top, 16, 16, OutMgrBmps[ioLines].Canvas.Handle, 144, 0, SRCCOPY);
        Inc(R.Left, 16);
      end;

      BitBlt(Handle, R.Left, R.Top, 16, 16, OutMgrBmps[ioLines].Canvas.Handle, I*16, 0, SRCCOPY);

      if F is TOutNode  then
      begin
        Font.Style := [fsBold]; I := 0;
        if N.Expanded then Inc(I);
        if osBusy in F.StatusSet then
        begin
          Inc(I, 7);
          s := FormatLng(rsMMOutNBusy, [Addr2Str(F.Address)]);
        end else
        begin
          s := Addr2Str(F.Address);
        end;
      end else
      begin
        Font.Style := [];
        if (TOutFile(F).Error <> 0) or (F.Status = osError) then
        begin
          s := FormatLng(rsMMOutNBrkLnk, [f.Name]);
          I := 9;
        end else
        case F.Status of
          os_CrashMail, os_DirectMail, osNormalMail, osHoldMail:
          begin
            I := 2;
          end;
          os_Crash, os_Direct, osNormal, osHold:
          begin
            zzz := ExtractFileExt(f.Name);
	    if f.Name = '' then
            begin
              s := FormatLng(rsMMOutNFlag, [f.StatusString]);
              I := 10;
            end else
            if IsArcMailExt(zzz) then
            begin
              I := 4;
              s := ExtractFileName(f.Name);
            end else
            if (UpperCase(zzz) = '.PKT') or (UpperCase(zzz) = '.P2K') then
            begin
              I := 2;
            end else
            begin
              I := 3;
              s := f.Name;
            end;
          end;
          osHReq:
            begin
              s := f.Name;
              I := 6;
            end;
          osRequest:
            begin
              I := 5;
              s := FormatLng(rsMMOutNFreq, [ExtractFileName(f.Name)]);
            end;
        end;
      end;
      if I = 2 then
      begin
        s := FormatLng(rsMMOutNMailPkt, [ExtractFileName(f.Name)]);
      end;
      Inc(R.Left, 16);
      BitBlt(Handle, R.Left, R.Top, 16, 16, OutMgrBmps[ioFolders].Canvas.Handle, I*16, 0, SRCCOPY);
      Inc(R.Left, 16);
      if ([odSelected,odFocused,odChecked]*State <> [])
         {or F.Selected} then
        begin
          Brush.Color := clHighlight;
          Font.Color := clHighlightText;
        end;
      R1 := R;
      FillRect(R1);
      Inc(R.Left, 4);
      R.Right := OutMgrHeader.Sections[0].Width-4;
      DrawStr(0, S);
      Inc(R.Left, OutMgrHeader.Sections[0].Width-R.Left);
      if F.Nfo.Size > 0 then
        begin
          R.Right := R.Left + OutMgrHeader.Sections[1].Width-4;
          DrawStr(DT_RIGHT, Format('%.0n', [F.Nfo.Size+0.0]));
        end;
      Inc(R.Left, OutMgrHeader.Sections[1].Width); R.Right := R.Left + OutMgrHeader.Sections[2].Width-4;
      DrawStr(0, F.StatusString);
      Inc(R.Left, OutMgrHeader.Sections[2].Width); R.Right := R.Left + OutMgrHeader.Sections[3].Width-4;
      DrawStr(0, F.ActionString);
      Inc(R.Left, OutMgrHeader.Sections[3].Width); R.Right := R.Left + OutMgrHeader.Sections[4].Width-4;
      DrawStr(0, F.AgeString);
      if odFocused in State then DrawFocusRect(R1);
    end;
  R := Rect(0, 0, RR.Right-RR.Left, RR.Bottom - RR.Top);
  OutMgrOutline.Canvas.CopyRect(RR, OutMgrBM.Canvas, R);
end;

procedure TMailerForm.UpdateBoundsOutMgrBM;
begin
  if OutMgrBM = nil then Exit;
  OutMgrBM.Width := OutMgrOutline.Width;
  OutMgrBM.Height := OutMgrOutline.ItemHeight;
  OutMgrBM.Canvas.Font := OutMgrOutline.Font;
end;

procedure TMailerForm.FormResize(Sender: TObject);
begin
  UpdateBoundsOutMgrBM;
  OutMgrPanel.Width := MainPanel.ClientWidth;
  OutMgrPanel.Height := BottomPanel.Top - OutMgrPanel.Top;
end;

procedure TMailerForm.OutMgrOutlineMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  N: TOutlineNode;
begin
  I := OutMgrOutline.GetItem(X, Y); OutMgrdLast := Point(X,Y);
  if I > 0 then
    begin
      OutMgrOutline.SelectedItem := I;
      N := OutMgrOutline[OutMgrOutline.SelectedItem];
      if {N.HasItems and} (X < Integer(N.Level) * 16) then N.Expanded := not N.Expanded;
    end;
end;

procedure TMailerForm.OutMgrOutlineDblClick(Sender: TObject);
var
  P: TPoint;
begin
  GetCursorPos(P);
  Windows.ScreenToClient(OutMgrOutline.Handle, P);
  OutMgrOutlineMouseDown(Sender, mbLeft, [], P.X, P.Y);
  ompOpenClick(nil);
end;

procedure TMailerForm.OutMgrHeaderSectionClick(HeaderControl: THeaderControl; Section: THeaderSection);
var
  i: Integer;
begin
  i := Section.Index+1;
  if OutMgrNodeSort = i then OutMgrNodeSort := -i else OutMgrNodeSort := i;
  OutMgrRefillExpanded;
  UpdateViewOutMgr;
end;

procedure TMailerForm.OutMgrHeaderSectionResize(HeaderControl: THeaderControl; Section: THeaderSection);
begin
  OutMgrRefillExpanded;
  UpdateViewOutMgr;
end;

procedure TMailerForm.RereadOutbound;
begin
  OutMgrThread.ForcedUpdate:= True;
  FidoOut.ForcedRescan := True;
  SetEvt(OutMgrThread.oEvt);
  SetEnabledO(bReread, wcb_Rescan, False);
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
  begin
    if aOutbound.CommonAVI <> aviFindFolder then aOutbound.CommonAVI := aviFindFolder;
    aOutbound.Visible := True;
    aOutbound.Active := True;
  end;
end;

procedure TMailerForm.TrayIconDblClick(Sender: TObject);
begin
  RestoreFromTray;
end;

procedure TMailerForm.ilDutchClick(Sender: TObject);
begin
  Application.HelpFile := GetHelpFile('dut');
  hlDutch.Checked := True;
  HelpLanguageId := HelpLanguageDutch;
  SetRegHelpLng('dut');
end;

procedure TMailerForm.hlSpanishClick(Sender: TObject);
begin
  Application.HelpFile := GetHelpFile('spa');
  hlSpanish.Checked := True;
  HelpLanguageId := HelpLanguageSpanish;
  SetRegHelpLng('spa');
end;

function ReloginFailed: Boolean;
begin
  Result := not AskSinglePassword(nil, Cfg.MasterKeyChk);
  if Result then PostCloseMessage;
end;


procedure TMailerForm.maEncryptedLinksClick(Sender: TObject);
begin
  if (Cfg.MasterKey <> 0) and (ReloginFailed) then Exit;
  SetupEncryptedLinks;
end;

procedure TMailerForm.tpRestoreClick(Sender: TObject);
begin
  RestoreFromTray;
end;

procedure TMailerForm.RestoreFromTray;
begin
  Application.Restore;
  Application.RestoreTopmosts;
  SetForegroundWindow(Application.MainForm.Handle);
  TMailerForm(Application.MainForm).RereadOutbound;
end;

procedure TMailerForm.NewPoll;
var
  A: TFidoAddrColl;
  I: Integer;
begin
  A := InputFidoAddress(LngStr(rsMMpollNodes), True, nil);
  if A = nil then Exit;
  for I := 0 to A.Count-1 do InsertPollAddress(A[I]);
  _RecalcPolls;
  PostMsg(WM_UPDATEVIEW);
  FreeObject(A);
end;


procedure TMailerForm.tpCreatePollClick(Sender: TObject);
begin
  RestoreFromTray;
  NewPoll;
  Application.Minimize;
end;

procedure TMailerForm.tpBrowseNodelistClick(Sender: TObject);
begin
  RestoreFromTray;
  BrowseNodes;
  Application.Minimize;
end;

procedure TMailerForm.CreateOutFileFlag(const AA: TFidoAddress; Status: TOutStatus);
var
  S: string;
  I: DWORD;
begin
  S := GetOutFileName(AA, Status);
  I := _CreateFileDir(S, [cWrite, cEnsureNew]);
  if I <> INVALID_HANDLE_VALUE then ZeroHandle(I) else
  begin
    if GetLastError <> ERROR_FILE_EXISTS then
    begin
      DisplayWarning(FormatErrorMsg(S, GetLastError), Handle);
    end;
  end;
end;

procedure TMailerForm.EditFileRequestEx(const AA: TFidoAddress);
var
  S: string;
  B: Boolean;
  DoPoll: Boolean;
  Status: TOutStatus;
begin
  B := EditRequests(AA);
  S := GetErrorMsg;
  if S <> '' then DisplayError(S, Handle);
  if not B then Exit;
  if not GetAttachStatusEx(Status, DoPoll, nil) then Exit;
  CreateOutFileFlag(AA, Status);
  if DoPoll then InsertPollAddress(AA);
  _RecalcPolls;
  RereadOutbound;
end;

procedure TMailerForm.EditFileRequest;
var
  AA: TFidoAddress;
begin
  if not InputSingleAddress(LngStr(rsMMeditFReq), AA, nil) then Exit;
  EditFileRequestEx(AA);
end;

procedure TMailerForm.tpEditFileRequestClick(Sender: TObject);
begin
  RestoreFromTray;
  EditFileRequest;
  Application.Minimize;
end;

procedure TMailerForm.msAdministrativeModeClick(Sender: TObject);
begin
  MailerForms.FreeAll;
end;

function InputMasterPassword(Handle: DWORD): Boolean;
var
  Key: TDesBlock;
begin
  Result := False;
  if not InputNewPwd(Key, LngStr(rsMMMPEntrNew), False, IDH_MASTPWD) then Exit;
  Cfg.MasterKeyChk := xdes_md5_crc16(@Key, 8);
  Cfg.MasterKey := Key;
  Result := StoreConfig(Handle);
  if not Result then PostCloseMessage;
end;

procedure TMailerForm.mcMasterPwdCreateClick(Sender: TObject);
begin
  if WinDlgCapHlp(LngStr(rsMMMPCreate), MB_YESNO or MB_HELP or MB_ICONWARNING, Handle, LngStr(rsMMMPStUpCap), IDH_MASTPWD) <> mrYes then Exit;
  if InputMasterPassword(Handle) then DisplayInfoLng(rsMMMPStUpOK, Handle);
end;

procedure TMailerForm.mcMasterPwdChangeClick(Sender: TObject);
begin
  if WinDlgCap(LngStr(rsMMMPCfmChange), MB_YESNO or MB_ICONWARNING, Handle, LngStr(rsMMMPChgCap)) <> mrYes then Exit;
  if ReloginFailed then Exit;
  if InputMasterPassword(Handle) then DisplayInfoLng(rsMMMPChgOK, Handle);
end;

procedure TMailerForm.mcMasterPwdRemoveClick(Sender: TObject);
begin
  if WinDlgCap(LngStr(rsMMMPCfmRemove), MB_YESNO or MB_ICONWARNING, Handle, LngStr(rsMMMPRemoveCap)) <> mrYes then Exit;
  if ReloginFailed then Exit;
  Cfg.MasterKey := 0;
  Cfg.MasterKeyChk := 0;
  if StoreConfig(Handle) then DisplayInfoLng(rsMMMPRemovedOK, Handle);
end;

function TMailerForm.OutMgrSelectedItem: TOutItem;
var
  ONode: TOutlineNode;
  sitem: Integer;
begin
  Result := nil;
  sitem := OutMgrOutline.SelectedItem;
  if sitem < 1 then Exit;
  ONode := OutMgrOutline[sitem];
  if ONode = nil then GlobalFail('%s', ['TMailerForm.OutMgrSelectedItem ONode = nil']);
  Result := ONode.Data;
end;

type
  TOutFileList = class(TStringColl)
    DestAddr,
    Addr: TFidoAddress;
    Stat: TOutStatus;
    Lock,
    Unlock: Boolean;
  end;

function OutFileColl2OutFileLists(AC: TOutFileColl): TColl;
var
  i: Integer;
  F: TOutFile;
  PrevAddr: TFidoAddress;
  PrevStat: TOutStatus;
  PrevColl, CurColl: TOutFileList;
  NewAddr: Boolean;
begin
  PrevColl := nil;
  CurColl := nil;
  Result := nil;
  PrevAddr.Zone := -1;
  PrevStat := osNone;
  for i := 0 to CollMax(AC) do
  begin
    F := AC[i];
    NewAddr := CompareAddrs(F.Address, PrevAddr) <> 0;
    if NewAddr or (F.FStatus <> PrevStat) then
    begin
      CurColl := TOutFileList.Create;
      CurColl.IgnoreCase := True;
      CurColl.Addr := F.Address; PrevAddr := F.Address;
      CurColl.Stat := F.FStatus; PrevStat := F.Status;
      if Result = nil then Result := TColl.Create;
      Result.Insert(CurColl);
      if NewAddr then
      begin
        CurColl.Lock := True;
        if PrevColl <> nil then PrevColl.Unlock := True;
        PrevColl := CurColl;
      end;
    end;
    if CurColl = nil then GlobalFail('%s', ['OutFileColl2OutFileLists CurColl = nil']) else CurColl.Ins(F.Name);
  end;
  if PrevColl <> nil then PrevColl.Unlock := True;
end;

function OutboundOpChStat(C:TOutFileList; S: TOutStatus): string;
begin
  if FidoOut.MoveFiles(C, @C.Addr, @C.Addr, @C.Stat, @S, False, False, False) then Result := '' else Result := GetErrorMsg;
end;

function OutboundOpReaddress(C: TOutFileList): string;
begin
  if FidoOut.MoveFiles(C, @C.Addr, @C.DestAddr, @C.Stat, @C.Stat, False, False, False) then Result := '' else Result := GetErrorMsg;
end;

function OutboundOpKill(C: TOutFileList): string;
begin
  if FidoOut.MoveFiles(C, @C.Addr, nil, @C.Stat, nil, True, False, False) then Result := '' else Result := GetErrorMsg;
end;

function OutboundOp_Crash(C: TOutFileList): string;
begin
  Result := OutboundOpChStat(C, os_Crash);
end;

function OutboundOp_Direct(C: TOutFileList): string;
begin
  Result := OutboundOpChStat(C, os_Direct);
end;

function OutboundOp_Normal(C: TOutFileList): string;
begin
  Result := OutboundOpChStat(C, osNormal);
end;


function OutboundOp_Hold(C: TOutFileList): string;
begin
  Result := OutboundOpChStat(C, osHold);
end;

function OutboundOpUnlink(C: TOutFileList): string;
begin
  if FidoOut.MoveFiles(C, @C.Addr, nil, @C.Stat, nil, False, False, True) then Result := '' else Result := GetErrorMsg;
end;


function OutboundOpPurge(C: TOutFileList): string;
begin
  if FidoOut.MoveFiles(C, @C.Addr, nil, @C.Stat, nil, True, True, False) then Result := '' else Result := GetErrorMsg;
end;


function PerformOutboundOp(C: TOutFileList; OpCode: TOutMgrOpCode; var s: string): Boolean;
type
  TOutboundOpFunc = function(C: TOutFileList): string;
const
  OutboundOpFuncs : array[TOutMgrOpCode] of TOutboundOpFunc =
    (nil,
     OutboundOpReaddress,
     OutboundOpKill,
     OutboundOp_Crash,
     OutboundOp_Direct,
     OutboundOp_Normal,
     OutboundOp_Hold,
     OutboundOpUnlink,
     OutboundOpPurge
     );
var
  ErrStr: string;
begin
  ErrStr := OutboundOpFuncs[OpCode](C);
  Result := ErrStr = '';
  if not Result then s := ErrStr;
end;

procedure TMailerForm.PerformOutboundOperations(FileLists: TColl; DestAddr: PFidoAddress; OpCode: TOutMgrOpCode);
var
  i: Integer;
  C: TOutFileList;
  OK, Ignore: Boolean;
  s: string;
begin
  Ignore := False;
  for i := 0 to CollMax(FileLists) do
  begin
    C := FileLists[i];
    if (C.Lock) and ((DestAddr = nil) or (CompareAddrs(DestAddr^, C.Addr)<>0)) then
    begin
      Ignore := False;
      repeat
        if FidoOut.Lock(C.Addr) then Break;
        case WinDlg(FormatLng(rsMMOutIsBusy, [Addr2Str(C.Addr)]), MB_ICONWARNING or MB_ABORTRETRYIGNORE, Handle) of
          idAbort  : Exit;
          idIgnore : begin Ignore := True; Break end;
        end; // assume idRetry elsewhere
      until False;
    end;
    if Ignore then Continue; // looking for a next node
    if DestAddr <> nil then C.DestAddr := DestAddr^;
    OK := PerformOutboundOp(C, OpCode, s);
    if ((not OK) or (C.Unlock)) and ((DestAddr = nil) or (CompareAddrs(DestAddr^, C.Addr)<>0)) then FidoOut.Unlock(C.Addr);
    if (not OK) then
    begin
      Ignore := True;
      if WinDlg(s, MB_ICONWARNING or MB_OKCANCEL, Handle) = idCancel then Exit;
    end;
  end;
end;

procedure TMailerForm.UpdateOutboundCommands;
var
  Found, f: Boolean;
  h,oo: string;
  o: TOutItem;
  m: TMenuItem;
  i: Integer;
  c: TOutFileColl;
  oe: Boolean;
  Info: TOutMgrGroupInfo;
begin
  f := True;
  o := OutMgrSelectedItem;
  Found := o <> nil;
  ompAttach.Enabled := Found;
  ompPoll.Enabled := Found;
  ompBrowseNL.Enabled := Found;
  ompEditFreq.Enabled := Found;
  ompCreateFlag.Enabled := Found;
  if Found then h := Addr2Str(o.Address) else h := LngStr(rsMMOutCurNode);
  ompAttach.Caption := FormatLng(rsMMOutAttTo, [h]);
  ompPoll.Caption := FormatLng(rsMMOutPoll, [h]);
  ompBrowseNL.Caption := FormatLng(rsMMOutBrwsAt, [h]);
  ompEditFreq.Caption := FormatLng(rsMMOutEdFrq, [h]);
  ompCreateFlag.Caption := FormatLng(rsMMOutCrtFlg, [h]);
  for i := 0 to OutMgrPopup.Items.Count-1 do
  begin
    m := OutMgrPopup.Items[i];
    if m.Tag < 1 then Continue;
    c := GetOutCollByTag(m.Tag, o, h, Info);
    if (c <> nil) and (m.Tag <> 1) then h := FormatLng(rsMMOutDoNItems, [h, c.Count]);
    m.Caption := h;
    if f then
    begin
      f := False;
      oe := (c <> nil) and xIsReg(ExtractFileExt(h));
      if oe then oo := h else oo := LngStr(rsMMOutCurFile);
      ompOpen.Caption := FormatLng(rsMMOutOpemItem, [oo]);
      ompOpen.Enabled := oe;
    end;
    FillOutMgrSubMenu(m, c, Info);
    CollDeleteAll(c);
    FreeObject(c);
  end;
end;

function TMailerForm.GetOutFileColl(FileMask: PString; NodeAdrr: PFidoAddress; OutStatus: POutStatus; var AInfo: TOutMgrGroupInfo): TOutFileColl;
var
  R: TOutFileColl;
  i, j: Integer;
  N: TOutNode;
  F: TOutFile;
begin
  AInfo.StatusesFound := [];
  AInfo.OutAttTypesFound := [];
  AInfo.AreBroken := False;
  AInfo.CanUnlink := False;
  R := nil;
  for i := 0 to CollMax(OutMgrNodes) do
  begin
    N := OutMgrNodes[i];
    if (OutStatus <> nil) and (not (OutStatus^ in N.FStatus)) then Continue;
    if (NodeAdrr <> nil) and (CompareAddrs(N.Address, NodeAdrr^) <> 0) then Continue;
    for j := 0 to CollMax(N.Files) do
    begin
      F := N.Files[j];
      if (OutStatus <> nil) and (OutStatus ^ <> F.FStatus) then Continue;
      if (FileMask <> nil) and (not MatchMask(F.Name, FileMask^)) then Continue;
      AInfo.AreBroken := AInfo.AreBroken or (F.Error <> 0);
      Include(AInfo.OutAttTypesFound, F.OutAttType);
      case F.FStatus of
        os_Crash, os_CrashMail : Include(AInfo.StatusesFound, os_Crash);
        os_Direct, os_DirectMail : Include(AInfo.StatusesFound, os_Direct);
        osNormal, osNormalMail : Include(AInfo.StatusesFound, osNormal);
        osHold, osHoldMail : Include(AInfo.StatusesFound, osHold);
      end;
      if not AInfo.CanUnlink then
      case F.FStatus of
        os_Crash,
        os_Direct,
        osNormal,
        osHold : AInfo.CanUnLink := True;
      end;
      if R = nil then R := TOutFileColl.Create;
      R.Add(F);
    end;
  end;
  Result := R;
end;


function GetCollCurrentFile(AForm: TMailerForm; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
var
  F: TOutFile absolute Item;
begin
  Result := nil;
  if (Item = nil) or (Item is TOutNode) then
  begin
    Caption := LngStr(rsMMOutCurOfCur);
  end else
  if not (Item is TOutFile) then GlobalFail('%s', ['GetCollCurrentFile']) else
  begin
    if F.Name = '' then Caption := FormatLng(rsMMOutNFlag, [F.StatusString])
                   else Caption := ExtractFileName(F.Name);
    Result := AForm.GetOutFileColl(@F.Name, @F.Address, @F.FStatus, AInfo);
  end;
end;

function GetCollByName(AForm: TMailerForm; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
var
  F: TOutFile absolute Item;
  Path, Name, Ext, s: string;
begin
  if (Item = nil) or (not(Item is TOutFile)) or (F.Name = '') then
  begin
    Caption := LngStr(rsMMOutSameFNm);
    Result := nil;
  end else
  begin
    FSplit(F.Name, Path, Name, Ext);
    s := Name + '.*';
    Caption := FormatLng(rsMMOutNofN, [s, Addr2Str(F.Address)]);
    s := Path + s;
    Result := AForm.GetOutFileColl(@s, @F.Address, nil, AInfo);
  end
end;

function GetCollByExt(AForm: TMailerForm; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
var
  F: TOutFile absolute Item;
  Path, Name, Ext, s: string;
begin
  Caption := '';
  Result := nil;
  if (Item <> nil) and (Item is TOutFile) and (F.Name <> '') then
  case F.FStatus of
    os_Crash, os_Direct, osNormal, osHold:
      begin
        FSplit(F.Name, Path, Name, Ext);
        if IsArcMailExt(Ext) then s := '*' + Copy(Ext, 1, 3) + '?' else s := '*' + Ext;
        Caption := FormatLng(rsMMOutNofN, [s, Addr2Str(F.Address)]);
        s := Path + s;
        Result := AForm.GetOutFileColl(@s, @F.Address, nil, AInfo);
      end
  end;
  if Caption = '' then Caption := LngStr(rsMMOutSameFXt);
end;

function GetCollByStatus(AForm: TMailerForm; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
var
  F: TOutFile absolute Item;
begin
  Caption := '';
  Result := nil;
  if (Item <> nil) and (Item is TOutFile) then
  case F.FStatus of
    os_Crash, os_Direct, osNormal, osHold:
      begin
        Caption := FormatLng(rsMMOutNFofN, [F.StatusString, Addr2Str(F.Address)]);
        Result := AForm.GetOutFileColl(nil, @F.Address, @F.FStatus, AInfo);
      end;
  end;
  if Caption = '' then Caption := LngStr(rsMMOutSameSt);
end;

function GetCollByNode(AForm: TMailerForm; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
begin
  if Item = nil then
  begin
    Caption := LngStr(rsMMOutEntrNode);
    Result := nil;
  end else
  begin
    Caption := FormatLng(rsMMOutNAofN, [Addr2Str(Item.Address)]);
    Result := AForm.GetOutFileColl(nil, @Item.Address, nil, AInfo);
  end
end;

function GetCollEntireOutbound(AForm: TMailerForm; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
begin
  Caption := LngStr(rsMMOutEntire);
  Result := AForm.GetOutFileColl(nil, nil, nil, AInfo);
end;

function TMailerForm.GetOutCollByTag(ATag: Integer; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;
type
  TGetOutCollFunc = function (AForm: TMailerForm; Item: TOutItem; var Caption: string; var AInfo: TOutMgrGroupInfo): TOutFileColl;

const
  GetCollFuncs: array[0..6] of TGetOutCollFunc =
    (nil,
     GetCollCurrentFile,
     GetCollByName,
     GetCollByExt,
     GetCollByStatus,
     GetCollByNode,
     GetCollEntireOutbound);
begin
  AInfo.AreBroken := False;
  AInfo.CanUnlink := False;
  AInfo.StatusesFound := [];
  Result := GetCollFuncs[ATag](Self, Item, Caption, AInfo);
end;


procedure TMailerForm.FillOutMgrSubMenu(AMenu: TMenuItem; C: TOutFileColl; const AInfo: TOutMgrGroupInfo);
const
  idxReaddr   = 0;
  idxFinalize = 1;
  idxCrash    = 3;
  idxDirect   = 4;
  idxNormal   = 5;
  idxHold     = 6;
  idxUnlink   = 8;
  idxPurge    = 9;

var
  B: Boolean;
  I: Integer;

procedure SetEnabledO(AE: Boolean);
begin
  AMenu.Items[i].Enabled := AE;
end;

procedure SetEnabledA(S: TOutStatus);
begin
  SetEnabledO(B and ([S] <> AInfo.StatusesFound) and (AInfo.StatusesFound <> []));
end;

begin
  B := (C <> nil) and (oatBSO in AInfo.OutAttTypesFound);
  AMenu.Enabled := B;
 // if not B then Exit;
  for i := 0 to AMenu.Count-1 do
  begin
    case i of
     idxReaddr,
     idxFinalize : SetEnabledO(B);
     idxCrash    : SetEnabledA(os_Crash);
     idxDirect   : SetEnabledA(os_Direct);
     idxNormal   : SetEnabledA(osNormal);
     idxHold     : SetEnabledA(osHold);
     idxUnlink   : SetEnabledO(B and AInfo.CanUnLink);
     idxPurge    : SetEnabledO(B and AInfo.AreBroken);
    end;
  end;
end;

procedure TMailerForm.bRereadClick(Sender: TObject);
begin
  RereadOutbound;
end;

procedure TMailerForm.opmReaddressClick(Sender: TObject);
begin
  OutOp(Sender, omoReaddr);
end;

procedure TMailerForm.opmFinalizeClick(Sender: TObject);
begin
  OutOp(Sender, omoKill);
end;

procedure TMailerForm.opmCrashClick(Sender: TObject);
begin
  OutOp(Sender, omo_Crash);
end;

procedure TMailerForm.opmDirectClick(Sender: TObject);
begin
  OutOp(Sender, omo_Direct);
end;

procedure TMailerForm.opmNormalClick(Sender: TObject);
begin
  OutOp(Sender, omo_Normal);
end;

procedure TMailerForm.opmHoldClick(Sender: TObject);
begin
  OutOp(Sender, omo_Hold);
end;

procedure TMailerForm.opmPurgeClick(Sender: TObject);
begin
  OutOp(Sender, omoPurge);
end;

procedure TMailerForm.OutMgrPopupPopup(Sender: TObject);
begin
  UpdateOutboundCommands;
end;

procedure TMailerForm.OutOp(Sender: TObject; OpCode: TOutMgrOpCode);
begin
  OutOpTag(OpCode, TMenuItem(Sender).Parent.Tag);
end;


procedure TMailerForm.OutOpTag(OpCode: TOutMgrOpCode; t: Integer);
var
  a: TFidoAddress;
  h: string;
  o: TOutItem;
  c: TOutFileColl;
  f: TColl;
  p: PFidoAddress;
  i: Integer;
  Info: TOutMgrGroupInfo;
begin
  o := OutMgrSelectedItem;
  if o = nil then Exit;
  OutMgrSelectedItemInstead := OutMgrOutline.SelectedItem;
  c := GetOutCollByTag(t, o, h, Info);
  i := CollCount(c);
  f := OutFileColl2OutFileLists(c);
  CollDeleteAll(c);
  FreeObject(c);
  if OpCode <> omoReaddr then p := nil else
  begin
    if not InputSingleAddress(FormatLng(rsMMOutOpRAdr, [i]), a, nil) then Exit;
    p := @a;
    repeat
      if FidoOut.Lock(p^) then Break;
      if WinDlg(FormatLng(rsMMOutIsBusy, [Addr2Str(p^)]), MB_ICONWARNING or MB_RETRYCANCEL, Handle) = idCancel then
      begin
        FreeObject(f);
        Exit;
      end;
    until False;
  end;
  if (t <> 6) or (YesNoConfirm(FormatLng(rsMMOutOpCmfEnt, [i]), Handle)) then PerformOutboundOperations(f, p, OpCode);
  if p <> nil then FidoOut.Unlock(p^);
  FreeObject(f);
  RereadOutbound;
end;

procedure TMailerForm.AttachFiles;
var
  DoPoll: Boolean;
  Status: TOutStatus;
  K: TKillAction;
  s: string;
begin
  if not GetAttachStatusEx(Status, DoPoll, @K) then Exit;
  repeat
    if FidoOut.Lock(A) then Break;
    if WinDlg(FormatLng(rsMMOutIsBusy, [Addr2Str(A)]), MB_ICONWARNING or MB_RETRYCANCEL, Handle) = idCancel then Exit;
  until False;
  if FidoOut.AttachFiles(A, SC, Status, K) then s := '' else s := GetErrorMsg;
  FidoOut.Unlock(A);
  OutMgrSelectedItemInstead := OutMgrOutline.SelectedItem;
  if s <> '' then DisplayError(s, Handle);
  if DoPoll then InsertPollAddress(A);
  _RecalcPolls;
  RereadOutbound;
end;

procedure TMailerForm.AttachFilesQuery(const A: TFidoAddress);
var
  D: TOpenDialog;
  SC: TStringColl;
  i: Integer;
begin
  D := TOpenDialog.Create(Application);
  D.Title := LngStr(rsMMAttachCap);
  D.Filter := GetCompleteFilter;
  D.FilterIndex := CompleteFilterIndex;
  D.Options := [ofAllowMultiSelect, ofFileMustExist, ofPathMustExist, ofHideReadOnly];
  SC := nil;
  if (D.Execute) and (D.Files.Count>0) then
  begin
    SC := TStringColl.Create;
    for i := 0 to D.Files.Count-1 do SC.Add(D.Files[i]);
  end;
  FreeObject(D);
  if SC = nil then Exit;
  AttachFiles(SC, A);
  FreeObject(SC);
end;

procedure TMailerForm.ompAttachClick(Sender: TObject);
var
  A: TFidoAddress;
  o: TOutItem;
begin
  o := OutMgrSelectedItem;
  if o = nil then Exit;
  A := o.Address;
  AttachFilesQuery(A);
end;

procedure TMailerForm.ompPollClick(Sender: TObject);
var
  o: TOutItem;
  a: TFidoAddress;
begin
  o := OutMgrSelectedItem;
  if o = nil then Exit;
  a := o.Address;
  InsertPollAddress(a);
  _RecalcPolls;
end;

procedure TMailerForm.BrowseNodelistAt(const Addr: TFidoAddress);
begin
  if not BrowseAtNode(Addr) then DisplayError(FormatLng(rsMMNodeUndNdl, [Addr2Str(Addr)]), Handle);
end;

procedure TMailerForm.ompBrowseNLClick(Sender: TObject);
var
  o: TOutItem;
  a: TFidoAddress;
begin
  o := OutMgrSelectedItem;
  if o = nil then Exit;
  a := o.Address;
  BrowseNodelistAt(a);
end;

procedure TMailerForm.opmUnlinkClick(Sender: TObject);
begin
  OutOp(Sender, omoUnlink);
end;

procedure TMailerForm.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  DragAcceptFiles(OutMgrOutline.Handle, True);
  Activated := True;
  if Application.MainForm = Self then
  begin
    SendMsg(WM_IMPORTDUPOVRL);
  {$IFDEF WS}
    SendMsg(WM_IMPORTIPOVRL);
  {$ENDIF}
    TrayIcon := TTrayIcon.Create(Self);
    TrayIcon.Hint := 'Argus';
    TrayIcon.Icon := Application.Icon;
    TrayIcon.PopupMenu := TrayPopupMenu;
    TrayIcon.SeparateIcon := False;
    TrayIcon.OnDblClick := TrayIconDblClick;
    TrayIcon.Active := True;
    if FStartMinimized then PostMessage(Handle, WM_APPMINIMIZE, 0, 0);
    PostMsg(WM_IMPORTPWDL);
    uTaskbarRestart := RegisterWindowMessage('TaskbarCreated');
  end;
end;

procedure TMailerForm.OutMgrOutlineApiDropFiles(Sender: TObject);
var
  A, OA: TFidoAddress;
  o: TOutItem;
  p: PFidoAddress;
  i: Integer;
begin
  SetForegroundWindow(Handle);
  if OutMgrOutline.DroppedFiles = nil then Exit;
  i := OutMgrOutline.GetItem(OutMgrOutline.DropPoint.X, OutMgrOutline.DropPoint.Y);
  if i <> -1 then OutMgrOutline.SelectedItem := i;
  o := OutMgrSelectedItem;
  if o = nil then p := nil else begin OA := o.Address; p := @OA end;
  if not InputSingleAddress(FormatLng(rsMMAttachIA, [OutMgrOutline.DroppedFiles.Count]), A, p) then Exit;
  AttachFiles(OutMgrOutline.DroppedFiles, A);
  FreeObject(OutMgrOutline.DroppedFiles);
end;

procedure TMailerForm.ompEditFreqClick(Sender: TObject);
var
  o: TOutItem;
  a: TFidoAddress;
begin
  o := OutMgrSelectedItem;
  if o = nil then Exit;
  a := o.Address;
  EditFileRequestEx(a);
end;

procedure TMailerForm.mtAttachFilesClick(Sender: TObject);
var
  AA: TFidoAddress;
begin
  if not InputSingleAddress(LngStr(rsMMAttachTA), AA, nil) then Exit;
  AttachFilesQuery(AA);
end;

procedure TMailerForm.InvokeOutMgrSmartMenu;
begin
  OutMgrOutline.PopupMenu.Popup(Screen.Width div 4, Screen.Height div 4);
end;

procedure TMailerForm.mtOutSmartMenuClick(Sender: TObject);
begin
  InvokeOutMgrSmartMenu;
end;

procedure TMailerForm.mtBrowseNodelistAtClick(Sender: TObject);
var
  AA: TFidoAddress;
begin
  if not InputSingleAddress(LngStr(rsMMBrsNdlAt), AA, nil) then Exit;
  BrowseNodelistAt(AA);
end;

procedure TMailerForm.ompOpenClick(Sender: TObject);
var
  o: TOutItem;
  s: string;
begin
  o := OutMgrSelectedItem;
  if (o = nil) or (not (o is TOutFile)) then Exit;
  if o.Status = osRequest then
  begin
    EditFileRequestEx(o.Address);
    Exit;
  end;
  s := o.Name;
  if not xIsReg(ExtractFileExt(s)) then Exit;
  ShellExecute(Handle, { handle to parent window }
               nil,    { pointer to string that specifies operation to perform }
               PChar(s),
               nil,    { pointer to string that specifies executable-file parameters }
               nil,    { pointer to string that specifies default directory }
               SW_SHOWNORMAL);

end;



procedure TMailerForm.OutMgrOutlineKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN: ompOpenClick(nil);
    VK_DELETE: OutOpTag(omoKill, 1); // 1 means current file
  end;
end;

procedure TMailerForm.ompCreateFileFlag(os: TOutStatus);
var
  o: TOutItem;
  Addr: TFidoAddress;
begin
  o := OutMgrSelectedItem;
  if o = nil then Exit;
  Addr := o.Address;
  CreateOutFileFlag(Addr, os);
  _RecalcPolls;
  RereadOutbound;
end;

procedure TMailerForm.ompCfCrashClick(Sender: TObject);
begin
  ompCreateFileFlag(os_Crash);
end;

procedure TMailerForm.ompCfDirectClick(Sender: TObject);
begin
  ompCreateFileFlag(os_Direct);
end;

procedure TMailerForm.ompCfNormalClick(Sender: TObject);
begin
  ompCreateFileFlag(osNormal);
end;

procedure TMailerForm.ompCfHoldClick(Sender: TObject);
begin
  ompCreateFileFlag(osHold);
end;

procedure TMailerForm.PollPopupMenuPopup(Sender: TObject);
begin
  UpdateView;
end;

procedure TMailerForm.PollsListViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_RETURN : bTracePollClick(nil);
    VK_DELETE: bDeletePollClick(nil);
  end;
end;

procedure TMailerForm.PollsListViewDblClick(Sender: TObject);
begin
  bTracePoll.Click;
end;

procedure TMailerForm.mtCreateFlagClick(Sender: TObject);
var
  Status: TOutStatus;
  DoPoll: Boolean;
  L: TFidoAddrColl;
  i: Integer;
  A: TFidoAddress;
begin
  L := InputFidoAddress(LngStr(rsMMCrtFF), True, nil);
  if L = nil then Exit;
  if not GetAttachStatusEx(Status, DoPoll, nil) then
  begin
    FreeObject(L);
    Exit;
  end;
  for i := 0 to CollMax(L) do
  begin
    A := L[i];
    CreateOutFileFlag(A, Status);
    if DoPoll then InsertPollAddress(A);
  end;
  _RecalcPolls;
  RereadOutbound;
end;

procedure TMailerForm.WndProc(var M: TMessage);
begin
  if csDesigning in ComponentState then
  begin
    inherited WndProc(M);
    Exit;
  end;
  if (Application.MainForm = Self) and (M.Msg = uTaskbarRestart) then
  begin
    TrayIcon.fNoTrayIcon := True;
    TrayIcon.AddIconToTray;
    Exit;
  end;
  inherited WndProc(M);
end;


procedure TMailerForm.UpdatePollOptions;
var
  r: TPollOptionsData;
begin
  CfgEnter;
  r := Cfg.PollOptions.Copy;
  CfgLeave;
  EnterFidoPolls;
  Xchg(Integer(FidoPolls.Options), Integer(r));
  LeaveFidoPolls;
  FreeObject(r);
end;


procedure TMailerForm.mcPollsClick(Sender: TObject);
begin
  if ConfigurePolls then
  begin
    CronThr.Recalc := True;
    UpdatePollOptions;
  end;
end;

procedure TMailerForm.hlDutchClick(Sender: TObject);
begin
  Application.HelpFile := GetHelpFile('dut');
  hlDutch.Checked := True;
  HelpLanguageId := HelpLanguageDutch;
  SetRegHelpLng('dut');
end;

procedure TMailerForm.hlDanishClick(Sender: TObject);
begin
  Application.HelpFile := GetHelpFile('dan');
  hlDanish.Checked := True;
  HelpLanguageId := HelpLanguageDanish;
  SetRegHelpLng('dan');
end;


procedure TMailerForm.mlSendMdmCmdsClick(Sender: TObject);
begin
  InsertEvt(TMlrEvtEnterMdmCmds.Create(Handle));
end;

procedure TMailerForm.mhHowRegClick(Sender: TObject);
begin
  ShellExecute(Handle, { handle to parent window }
               nil,    { pointer to string that specifies operation to perform }
               'http://www.ritlabs.com/argus/register.html',
               nil,    { pointer to string that specifies executable-file parameters }
               nil,    { pointer to string that specifies default directory }
               SW_SHOWNORMAL);
end;


procedure TMailerForm.mcFileBoxesClick(Sender: TObject);
begin
  SetupFileBoxes;
end;


procedure TMailerForm.maNodesClick(Sender: TObject);
begin
  InvokeNodeWizzard;
end;

procedure TMailerForm.ompHelpClick(Sender: TObject);
begin
  Application.HelpContext(OutMgrPopup.HelpContext);
end;


procedure DoHelp(Handle: THandle; Command, Data: DWORD);
var
  R: Integer;
begin
  if IsHtmlHelp and (not HtmlHelpLibError) then
  begin
    R := 0;
    if not HelpInitialized then
    begin
      HelpInitialized := True;
      R := HtmlHelp(Handle, '', HH_INITIALIZE, 0);
    end;
    if R = 0 then
    case Command of
      HELP_CONTENTS :
      begin
        R := HtmlHelp(Handle, Application.HelpFile, HH_DISPLAY_TOC, 0);
      end;
      HELP_CONTEXT  :
      begin
        R := HtmlHelp(Handle, Application.HelpFile, HH_HELP_CONTEXT, Data)
      end;
    end;
    if (R = -1) and (HtmlHelpLibError) then
    begin
      InitHelp;
      DoHelp(Handle, Command, Data);
    end;
  end else
  begin
    WinHelp(Handle, PChar(Application.HelpFile), Command, Data);
  end;
end;

function TMailerForm.FormHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
begin
  if not HelpDone then DoHelp(0, Command, Data);
  CallHelp := False;
  Result := True;
end;

end.



