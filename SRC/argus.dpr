program Argus;

{$IMAGEBASE $400000}

{$R 'folders.res' 'folders.rc'}
{$R 'main.res' 'main.rc'}
{$R 'xOutline.res' 'xOutline.rc'}
{$R 'xSPIN.res' 'xSPIN.rc'}
{$R 'credits.res' 'credits.rc'}
{$R 'licence.res' 'licence.rc'}

uses
  ComeOn in 'ComeOn.pas',
  DevCfg in 'DevCfg.pas' {DeviceConfig},
  FidoStat in 'FidoStat.pas' {FidoTemplateEditor},
  NdlUtil in 'NdlUtil.pas' {NodelistCompiler},
  FreqEdit in 'Freqedit.pas' {FReqDlg},
  LineBits in 'LineBits.pas' {LineBitsEditor},
  MClasses in 'MClasses.pas',
  ModemCfg in 'ModemCfg.pas' {ModemEditor},
  Outbound in 'Outbound.pas',
  SelDir in 'SelDir.pas' {SelectDirDialog},
  p_Hydra in 'p_Hydra.pas',
  xBase in 'xBase.pas',
  xMisc in 'xMisc.pas',
  Credits in 'Credits.pas' {RTFForm},
  PathName in 'PathName.pas' {PathNamesForm},
  Mgrids in 'Mgrids.pas',
  mlinecfg in 'mlinecfg.pas' {MailerLineCfgForm},
  FreqCfg in 'FreqCfg.pas' {FreqCfgForm},
  NodeLCfg in 'NodeLCfg.pas' {NodeListCfgForm},
  Recs in 'Recs.pas',
  DialRest in 'DialRest.pas' {RestrictCfgForm},
  MlrForm in 'MlrForm.pas' {MailerForm},
  xFido in 'xFido.pas',
  p_Zmodem in 'P_zmodem.pas',
  About in 'About.pas' {AboutBox},
  Attach in 'Attach.pas' {AttachStatusForm},
  xIP in 'xIP.pas',
  DUPCfg in 'DUPCfg.pas' {MainConfigForm},
  stupcfg in 'stupcfg.pas' {StartupConfigForm},
  TracePl in 'TracePl.pas' {DisplayInfoForm},
  Extrnls in 'Extrnls.pas' {ExternalsForm},
  LngTools in 'LngTools.pas',
  NodeBrws in 'NodeBrws.pas' {NodelistBrowser},
  Import in 'Import.pas' {ImportForm},
  Events in 'Events.pas' {EventsForm},
  EvtEdit in 'EvtEdit.pas' {EvtEditForm},
  AtomEdit in 'AtomEdit.pas' {AtomEditorForm},
  xNiagara in 'xNiagara.pas',
  p_BinkP in 'p_BinkP.pas',
  xDES in 'xDES.pas',
  EncLinks in 'EncLinks.pas' {EncryptedLinksForm},
  PwdInput in 'PwdInput.pas' {NewPwdInputForm},
  SinglPwd in 'SinglPwd.pas' {SinglePasswordForm},
  MlrThr in 'MlrThr.pas',
  OvrExpl in 'OvrExpl.pas' {OvrExplainForm},
  FidoPwd in 'FidoPwd.pas' {PwdForm},
  AdrIBox in 'AdrIBox.pas' {FidoAddressInput},
  Grids in 'Grids.pas',
  Outline in 'Outline.pas',
  FTS1 in 'FTS1.pas',
  PollCfg in 'PollCfg.pas' {PollSetupForm},
  MdmCmd in 'MdmCmd.pas' {ModemCmdForm},
  FileBox in 'FileBox.pas' {FileBoxesForm},
  NodeWiz in 'NodeWiz.pas' {NodeWizzardForm},
  StartWiz in 'StartWiz.pas' {StartWizzardForm},
  RegExp in 'RegExp.pas',
  odbcsql in 'Odbcsql.pas',
  OdbcLog in 'OdbcLog.pas',
  igHHInt in 'igHHInt.pas',
  wsock in 'wsock.pas',
  NTdyn in 'NTdyn.pas';

{$R *.RES}


begin
  Come_On;
end.


