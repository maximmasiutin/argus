unit SinglPwd;

interface

uses
  Forms, xDES, StdCtrls, Controls, Graphics, Classes, ExtCtrls;

type
  TSinglePasswordForm = class(TForm)
    Image1: TImage;
    lPwd: TEdit;
    bLogon: TButton;
    bCancel: TButton;
    Image2: TImage;
    procedure bLogonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FKey: PDesBlock;
    FChk: Word;
    Attempts: Integer;
  public
    { Public declarations }
  end;

function AskSinglePassword(AKey: PDesBlock; AChk: Word): Boolean;

implementation uses xBase, LngTools, Windows;

{$R *.DFM}

function AskSinglePassword;
var
  SinglePasswordForm: TSinglePasswordForm;
begin
  SinglePasswordForm := TSinglePasswordForm.Create(Application);
  SinglePasswordForm.FKey := AKey;
  SinglePasswordForm.FChk := AChk;
  Result := SinglePasswordForm.ShowModal = mrOK;
  FreeObject(SinglePasswordForm);
end;



procedure TSinglePasswordForm.bLogonClick(Sender: TObject);
var
  Key: TDesBlock;
  s: string;
  Valid: Boolean;
begin
  s := lPwd.Text;
  lPwd.Text := '';
  Valid := False;
  if s <> '' then
  begin
    xdes_str_to_key(@s[1], Length(s), Key);
    s := '';
    Valid := xdes_md5_crc16(@Key, 8) = FChk;
  end;
  if Valid then
  begin
    if FKey <> nil then FKey^ := Key;
    ModalResult := mrOK;
  end else
  begin
    Inc(Attempts);
    if Attempts > 4 then
    begin
      Screen.Cursor := crHourGlass;
      Sleep(10000);
      Screen.Cursor := crDefault;
    end;
    WinDlgCap(LngStr(rsSPwCntLgOn), MB_OK or MB_ICONWARNING, Handle, LngStr(rsSPwLgnMsg));
  end;
end;



procedure TSinglePasswordForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsSinglePasswordForm);
end;

end.
