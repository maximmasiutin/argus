unit StartWiz;

{$I DEFINE.INC}

interface

uses
  Forms, ExtCtrls, Controls, Classes, StdCtrls, ComCtrls;

type
  TStartWizzardForm = class(TForm)
    Pages: TPageControl;
    tsDialProps: TTabSheet;
    gbDialProps: TGroupBox;
    lAreaCode: TLabel;
    eAreaCode: TEdit;
    lLocalPrefix: TLabel;
    eLocalPrefix: TEdit;
    lLongDistPrefix: TLabel;
    eLongDistPrefix: TEdit;
    rgTonePulse: TRadioGroup;
    cbSetRestrict: TCheckBox;
    bPrev: TButton;
    bNext: TButton;
    bCancel: TButton;
    lComPort: TLabel;
    cbCom: TComboBox;
    tsTransport: TTabSheet;
    gbConn: TGroupBox;
    cbDUP: TCheckBox;
    cbIP: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormActivate(Sender: TObject);
    procedure bPrevClick(Sender: TObject);
    procedure bNextClick(Sender: TObject);
    procedure cbDUPClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    ap: Integer;
    Activated: Boolean;
    FNextCap: string;
    procedure SetActivePage(No: Integer);
    procedure InvalidateBtns;
  public
  end;

type
  TSartWizDialProps = class
    AreaCode,
    LocalPrefix,
    LongDistPrefix: string;
    ComPortIndex: Byte;
    ToneDial: Boolean;
    SetRestrict: Boolean;
  end;

var
{$IFDEF WS}
  StartWizAutoStartDaemon: Boolean;
{$ENDIF}
  StartWizDialProps: TSartWizDialProps;

procedure StartupWizzard;

implementation uses xBase, SysUtils, LngTools, xFido;

{$R *.DFM}

procedure StartupWizzard;
var
  StartWizzardForm: TStartWizzardForm;
begin
  StartWizzardForm := TStartWizzardForm.Create(Application);
  StartWizzardForm.ShowModal;
  FreeObject(StartWizzardForm);
end;


procedure TStartWizzardForm.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  Activated := True;
  {$IFNDEF WS}
  cbIP.Visible := False;
  {$ENDIF}
  FNextCap := bNext.Caption;
  SetActivePage(0);
  cbCom.ItemIndex := 1;
end;

procedure TStartWizzardForm.bPrevClick(Sender: TObject);
begin
  if ap > 0 then Dec(ap);
  SetActivePage(ap);
end;

procedure TStartWizzardForm.SetActivePage(No: Integer);
begin
  case No of
    0: Pages.ActivePage := tsTransport;
    1: begin Pages.ActivePage := tsDialProps; eAreaCode.SetFocus end;
  end;
  Caption := Pages.ActivePage.Caption;
  InvalidateBtns;
end;

procedure TStartWizzardForm.bNextClick(Sender: TObject);
begin
  if ap < 2 then Inc(ap);
  SetActivePage(ap);
end;

procedure TStartWizzardForm.InvalidateBtns;
begin
  if (ap = 1) or (not cbDUP.Checked) then
  begin
    bNext.Caption := LngStr(rsSWDoneCap);
    bNext.ModalResult := mrOK;
  end else
  begin
    bNext.Caption := FNextCap;
    bNext.ModalResult := mrNone;
  end;
  bPrev.Enabled := ap > 0;
end;

procedure TStartWizzardForm.cbDUPClick(Sender: TObject);
begin
  InvalidateBtns;
end;

procedure TStartWizzardForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsStartWizzardForm);
end;

procedure TStartWizzardForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

function CheckPrefix(const s: string; e: TEdit): Boolean;
begin
  Result := ValidPhnPrefix(s);
  if Result then Exit;
  Pages.ActivePage := tsDialProps;
  e.SetFocus;
  DisplayErrorFmtLng(rsDlPfxNVnl, [s], Handle);
end;

begin
  if ModalResult <> mrOK then Exit;
  {$IFDEF WS}
  StartWizAutoStartDaemon := cbIP.Checked;
  {$ENDIF}
  if not cbDUP.Checked then Exit;
  StartWizDialProps := TSartWizDialProps.Create;
  StartWizDialProps.AreaCode := Trim(eAreaCode.Text);
  StartWizDialProps.LocalPrefix := Trim(eLocalPrefix.Text);
  StartWizDialProps.LongDistPrefix := Trim(eLongDistPrefix.Text);
  StartWizDialProps.ComPortIndex := cbCom.ItemIndex;
  StartWizDialProps.ToneDial := rgTonePulse.ItemIndex = 0;
  StartWizDialProps.SetRestrict := cbSetRestrict.Checked;
  CanClose :=
    CheckPrefix(StartWizDialProps.AreaCode, eAreaCode) and
    CheckPrefix(StartWizDialProps.LocalPrefix, eLocalPrefix) and
    CheckPrefix(StartWizDialProps.LongDistPrefix, eLongDistPrefix);
  if not CanClose then FreeObject(StartWizDialProps);
end;

end.


