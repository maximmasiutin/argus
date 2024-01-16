unit FidoPwd;

{$I DEFINE.INC}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  ComCtrls, mGrids, StdCtrls;

type
  TPwdForm = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    gPsw: TAdvGrid;
    bImportPwd: TButton;
    bSort: TButton;
    lAuxPwds: TLabel;
    eAuxPwds: TEdit;
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure bSortClick(Sender: TObject);
    procedure bImportPwdClick(Sender: TObject);
  private
    Activated: Boolean;
    Psw: Pointer;
    Crc32: DWORD;
    procedure SetData;
    procedure SetPsw(APsw: Pointer);
    function PswValid: Boolean;
  end;


function SetupPasswords: Boolean;

implementation uses xBase, xFido, NdlUtil, LngTools, Recs;

{$R *.DFM}

procedure TPwdForm.SetPsw(APsw: Pointer);
begin
  FillGridPswOvr(APsw, gPsw, True);
end;


procedure TPwdForm.FormActivate(Sender: TObject);
begin
  if not Activated then
  begin
    gPsw.PasswordCol := 2;
    GridFillColLng(gPsw, rsPswGrid);
    Activated := True;
  end;
end;

function SetupPasswords;
var
  PwdForm: TPwdForm;
begin
  PwdForm := TPwdForm.Create(Application);
  PwdForm.SetData;
  Result := PwdForm.ShowModal = mrOK;
  FreeObject(PwdForm);
end;

function TPwdForm.PswValid: Boolean;
var
  I: Integer;
  A: TFidoAddrColl;
  S: string;
  R: TPasswordRec;
begin
  Result := False;
  TPasswordColl(Psw).FreeAll;
  for I := 1 to gPsw.RowCount-1 do
  begin
    S := gPsw[1,I];
    if S = '' then
    begin
      if gPsw.RowCount = 2 then Result := True else DisplayErrorFmtLng(rsPswEmptyAdr, [I], Handle);
      Exit;
    end;
    A := CreateAddrColl(S);
    if A = nil then
    begin
      DisplayErrorFmtLng(rsPswInvAdrLst, [S, I], Handle);
      Exit;
    end;
    S := Trim(gPsw[2,I]);
    if S = '' then
    begin
      DisplayErrorFmtLng(rsPswEmptyPwd, [I], Handle);
      Exit;
    end;
    R := TPasswordRec.Create;
    XChg(R.AddrList, A); FreeObject(A);
    R.PswStr := S;
    TPasswordColl(Psw).Insert(R);
  end;
  TPasswordColl(Psw).AuxFile := Trim(eAuxPwds.Text);
  Result := ReportDuplicateAddrs(Psw, gPsw, rsPswDup);
end;

procedure TPwdForm.SetData;
begin
  SetPsw(Cfg.Passwords);
  TPasswordColl(Psw).AuxFile := Cfg.Passwords.AuxFile;
  eAuxPwds.Text := Trim(TPasswordColl(Psw).AuxFile);
  Crc32 := Cfg.Passwords.Crc32(CRC32_INIT);
end;

procedure TPwdForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOK then CanClose := True else CanClose := PswValid;
end;

procedure TPwdForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  if TPasswordColl(Psw).Crc32(CRC32_INIT) <> Crc32 then
  begin
    CfgEnter;
    Xchg(Integer(Cfg.Passwords), Integer(Psw));      
    CfgLeave;
    StoreConfig(Handle);
    PostMsg(WM_IMPORTPWDL);
  end;
end;

procedure TPwdForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsPwdForm);
  Psw := TPasswordColl.Create;
end;

procedure TPwdForm.FormDestroy(Sender: TObject);
begin
  FreeObject(Psw);
end;

procedure TPwdForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

function PswSort(Item1, Item2: Pointer): Integer;

function ar(i: Integer): string;
begin
  Result := AddRightSpaces(IntToStr(i), 5);
end;

function al(i: Integer): string;
begin
  Result := AddLeftSpaces(IntToStr(i), 5);
end;

var
  n1: TPasswordRec absolute Item1;
  n2: TPasswordRec absolute Item2;
  a1, a2: TFidoAddress;
begin
  if n1.AuxStr = '' then begin a1 := n1.AddrList[0]; n1.AuxStr := al(a1.Zone)+ar(a1.Net)+al(a1.Node)+al(a1.Point) end;
  if n2.AuxStr = '' then begin a2 := n2.AddrList[0]; n2.AuxStr := al(a2.Zone)+ar(a2.Net)+al(a2.Node)+al(a2.Point) end;
  Result := CompareStr(n1.AuxStr, n2.AuxStr);
end;

procedure TPwdForm.bSortClick(Sender: TObject);
begin
  if not PswValid then Exit;
  TPasswordColl(Psw).Sort(PswSort);
  SetPsw(Psw);
end;

procedure TPwdForm.bImportPwdClick(Sender: TObject);
begin
  if not PswValid then Exit;
  DoImportOp(Psw, gPsw, True, True);
end;

end.
