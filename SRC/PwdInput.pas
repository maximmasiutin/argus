unit PwdInput;

interface

uses
  Forms, xDES, StdCtrls, Controls, Graphics, ExtCtrls, Classes;

type
  TNewPwdInputForm = class(TForm)
    e2: TEdit;
    e1: TEdit;
    lNew: TLabel;
    lCfm: TLabel;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    iArgusLogo: TImage;
    iKeyA: TImage;
    iKeyB: TImage;
    procedure bOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    FKey: PDesBlock;
  public
  end;


function InputNewPwd(var Key: TDesBlock; ACaption: string; HideALogo: Boolean; AHelpContext: Integer): Boolean;

implementation uses xBase, LngTools;

{$R *.DFM}

function InputNewPwd(var Key: TDesBlock; ACaption: string; HideALogo: Boolean; AHelpContext: Integer): Boolean;
var
  NewPwdInputForm: TNewPwdInputForm;
begin
  NewPwdInputForm := TNewPwdInputForm.Create(Application);
  NewPwdInputForm.FKey := @Key;
  NewPwdInputForm.Caption := ACaption;
  NewPwdInputForm.HelpContext := AHelpContext;
  if HideALogo then NewPwdInputForm.iArgusLogo.Visible := False;
  Result := NewPwdInputForm.ShowModal = mrOK;
  FreeObject(NewPwdInputForm);
end;






procedure TNewPwdInputForm.bOKClick(Sender: TObject);
var
  p1, p2: string;
  l: Integer;
begin
  p1 := e1.Text; e1.Text := '';
  p2 := e2.Text; e2.Text := '';
  e1.SetFocus;
  if p1 <> p2 then
  begin
    DisplayErrorLng(rsPINCfm, Handle);
    Exit;
  end;
  l := Length(p1);
  if l < 6 then
  begin
    DisplayErrorLng(rsPITooShort, Handle);
    Exit;
  end;
  xdes_str_to_key(@p1[1], l, FKey^);
  ModalResult := mrOK;
end;

procedure TNewPwdInputForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsNewPwdInputForm);
end;

procedure TNewPwdInputForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
