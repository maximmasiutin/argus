unit PollCfg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls, MClasses, mGrids;

type
  TPollSetupForm = class(TForm)
    PageControl: TPageControl;
    tsPeriodical: TTabSheet;
    tsOptions: TTabSheet;
    tsExternal: TTabSheet;
    gPeriodical: TAdvGrid;
    gbTry: TGroupBox;
    lBysy: TLabel;
    lNoC: TLabel;
    lFail: TLabel;
    sBusy: TxSpinEdit;
    sNoC: TxSpinEdit;
    sFail: TxSpinEdit;
    gbTO: TGroupBox;
    lRetry: TLabel;
    lStandOff: TLabel;
    sStandOff: TxSpinEdit;
    sRetry: TxSpinEdit;
    cbTransmitHold: TCheckBox;
    gExternal: TAdvGrid;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    cbDirectAsNormal: TCheckBox;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    C: Pointer;
    Activated: Boolean;
    crc: DWORD;
    OK: Boolean;
    PerPolls: Pointer;
    procedure SetData;
    function CalcCRC: DWORD;
    procedure SetDataPeriodical;
    procedure SetDataExternal;
    procedure SetDataOptions;
    function PeriodicalOK: Boolean;
    function OptionsOK: Boolean;
    function ExternalOK: Boolean;
    procedure UpdatePeriodical;
    procedure UpdateOptions;
    procedure UpdateExternal;
  public
  end;


function ConfigurePolls: Boolean;

implementation uses xBase, LngTools, Recs, xFido;

{$R *.DFM}

function ConfigurePolls: Boolean;
var
  PollSetupForm: TPollSetupForm;
begin
  PollSetupForm := TPollSetupForm.Create(Application);
  PollSetupForm.SetData;
  PollSetupForm.ShowModal;
  Result := PollSetupForm.OK;
  FreeObject(PollSetupForm);
end;

procedure TPollSetupForm.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  Activated := True;
  GridFillColLng(gPeriodical, rsPPgrid);
  GridFillColLng(gExternal, rsPPext);
  gPeriodical.RenumberRows;
end;

procedure TPollSetupForm.SetDataPeriodical;
var
  i: Integer;
  a, b: TStringColl;
  r: TPerPollRec;
begin
  a := TStringColl.Create;
  b := TStringColl.Create;
  CfgEnter;
  for i := 0 to Cfg.PerPolls.Count-1 do
  begin
    r := Cfg.PerPolls[i];
    a.Add(StrAsg(r.Cron));
    b.Add(r.AddrList.GetString);
  end;
  CfgLeave;
  gPeriodical.SetData([a, b]);
  FreeObject(a);
  FreeObject(b);
end;


procedure TPollSetupForm.SetDataOptions;
var
  r: TPollOptionsData;
begin
  CfgEnter;
  r := Cfg.PollOptions.Copy;
  CfgLeave;
  with r.d do
  begin
    sBusy.Value := Busy;
    sNoC.Value := NoC;
    sFail.Value := Fail;
    sRetry.Value := Retry;
    sStandOff.Value := StandOff;
    cbTransmitHold.Checked := pofHold in Flags;
    cbDirectAsNormal.Checked := pofDirAsNormal in Flags;
  end;
  FreeObject(r);
end;

procedure TPollSetupForm.SetDataExternal;
var
  S1, S2, S3: TStringColl;
  i: Integer;
  p: TExtPoll;
begin
  S1 := TStringColl.Create;
  S2 := TStringColl.Create;
  S3 := TStringColl.Create;
  CfgEnter;
  for i := 0 to CollMax(Cfg.ExtPolls) do
  begin
    p := Cfg.ExtPolls[i];
    S1.Add(p.FAddrs);
    S2.Add(p.FOpts);
    S3.Add(p.FCmd);
  end;
  CfgLeave;
  gExternal.SetData([S1, S2, S3]);
  FreeObject(S1);
  FreeObject(S2);
  FreeObject(S3);
end;

procedure TPollSetupForm.SetData;
begin
  crc := CalcCRC;
  SetDataPeriodical;
  SetDataOptions;
  SetDataExternal;
end;

function TPollSetupForm.CalcCRC: DWORD;
var
  d: TPollOptionsDataRec;
  Flags: Integer;
begin
  d := Cfg.PollOptions.d;
  Flags := 0;
  Move(d.Flags, Flags, MinD(SizeOf(d.Flags), SizeOf(Flags)));
  Result := Crc32Int(d.Busy,
            Crc32Int(d.NoC,
            Crc32Int(d.Fail,
            Crc32Int(d.Retry,
            Crc32Int(d.Standoff,
            Crc32Int(Flags,
            Cfg.PerPolls.Crc32(
            Cfg.ExtPolls.Crc32(CRC32_INIT))))))));
end;

function TPollSetupForm.PeriodicalOK: Boolean;
var
  i: Integer;
  s: string;
  A: TFidoAddrColl;
  R: TPerPollRec;
begin
  TPerPollColl(PerPolls).FreeAll;
  Result := False;
  if (gPeriodical.RowCount = 2) and (gPeriodical[1,1]='') and (gPeriodical[2,1]='') then begin Result := True; Exit end;
  if not CronGridValid(gPeriodical) then Exit;
  for I := 1 to gPeriodical.RowCount-1 do
  begin
    S := gPeriodical[2,I];
    A := CreateAddrColl(S);
    if A = nil then
    begin
      DisplayErrorFmtLng(rsPswInvAdrLst, [S, I], Handle);
      Exit;
    end;
    S := gPeriodical[1,I];
    R := TPerPollRec.Create;
    XChg(R.AddrList, A); FreeObject(A);
    R.Cron := S;
    TPerPollColl(PerPolls).Insert(R);
  end;
  Result := ReportDuplicateAddrs(PerPolls, gPeriodical, rsPerPollDup);
end;

{
var
  i: Integer;
  s: string;
  c: TFidoAddrColl;
begin
  Result := False;
  if (gPeriodical.RowCount = 2) and (gPeriodical[1,1]='') and (gPeriodical[2,1]='') then begin Result := True; Exit end;
  if not CronGridValid(gPeriodical, Handle) then Exit;
  for i := 1 to gPeriodical.RowCount-1 do
  begin
    c := CreateAddrCollMsg(gPeriodical[2,i], s);
    if c <> nil then begin FreeObject(c); Continue end;
    DisplayErrorFmtLng(rsPPline, [s, i], Handle);
    Exit;
  end;
  Result := True;
end;
}

function TPollSetupForm.OptionsOK: Boolean;
begin
  Result := True;
end;

function ValidExternalOptions(const s: string; Handle: DWORD): Boolean;
var
  z: string;
  i: Integer;
begin
  Result := False;
  z := s;
  for i := 0 to 3 do if not NextPollOptionValid(z, Handle) then Exit;
  if not PollSleepMSecsValid(z, Handle) then Exit;
  if not PollTimeoutExitCodeValid(z, Handle) then Exit;
  if z <> '' then begin DisplayError(FormatLng(rsPcUeD, [z]), Handle); Exit end;
  Result := True;
end;

function TPollSetupForm.ExternalOK: Boolean;
var
  S1, S2, S3: TStringColl;
  i: Integer;
  p: TExtPoll;
begin
  Result := False;
  FreeObject(C);
  C := TExtPollColl.Create;
  S1 := TStringColl.Create;
  S2 := TStringColl.Create;
  S3 := TStringColl.Create;
  gExternal.GetData([S1, S2, S3]);
  for i := 0 to CollMax(S1) do
  begin
    p := TExtPoll.Create;
    p.FAddrs := S1[i];
    p.FOpts := S2[i];
    p.FCmd := S3[i];
    TExtPollColl(C).Add(p);
  end;
  FreeObject(S1);
  FreeObject(S2);
  FreeObject(S3);
  for i := 0 to CollMax(C) do
  begin
    p := TExtPollColl(C)[i];
    if not ValidMaskAddressList(p.FAddrs, Handle) then Exit;
    if not ValidExternalOptions(p.FOpts, Handle) then Exit;
  end;
  Result := True;
end;

procedure TPollSetupForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
  CanClose := PeriodicalOK and OptionsOK and ExternalOK;
end;

procedure TPollSetupForm.UpdatePeriodical;
begin
  CfgEnter;
  XChg(Cfg.PerPolls, PerPolls);
  CfgLeave;
  TPerPollColl(PerPolls).FreeAll;
end;

procedure TPollSetupForm.UpdateOptions;
var
  r: TPollOptionsData;
begin
  r := TPollOptionsData.Create;
  with r.d do
  begin
    Busy := sBusy.Value;
    NoC := sNoC.Value;
    Fail := sFail.Value;
    Retry := sRetry.Value;
    StandOff := sStandOff.Value;
    Flags := [];
    if cbTransmitHold.Checked then Include(Flags, pofHold);
    if cbDirectAsNormal.Checked then Include(Flags, pofDirAsNormal);
  end;
  CfgEnter;
  Xchg(Integer(Cfg.PollOptions), Integer(r));
  CfgLeave;
  FreeObject(r);
end;

procedure TPollSetupForm.UpdateExternal;
begin
  CfgEnter;
  XChg(Integer(Cfg.ExtPolls), Integer(C));
  CfgLeave;
  FreeObject(C);
end;

procedure TPollSetupForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  UpdatePeriodical;
  UpdateOptions;
  UpdateExternal;
  if crc <> CalcCRC then
  begin
    OK := True;
    StoreConfig(Handle)
  end;
end;

procedure TPollSetupForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TPollSetupForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsPollSetupForm);
  PerPolls := TPerPollColl.Create;
end;

procedure TPollSetupForm.FormDestroy(Sender: TObject);
begin
  FreeObject(C);
  FreeObject(PerPolls);
end;

end.

