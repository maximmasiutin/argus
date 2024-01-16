unit Import;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,  Recs,
  StdCtrls;

type
  TImportForm = class(TForm)
    rbBinkD: TRadioButton;
    rbBinkPlus: TRadioButton;
    rbTMail: TRadioButton;
    rbXenia: TRadioButton;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    rbFrontDoor: TRadioButton;
    rbMainDoor: TRadioButton;
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetImportType(const ATitle: string; Passwords: Boolean): TAlienCfgType;

implementation uses xBase, LngTools;

{$R *.DFM}

function GetImportType(const ATitle: string; Passwords: Boolean): TAlienCfgType;
var
  ImportForm: TImportForm;
const
  FHelpCtx: array[Boolean] of Integer = (IDH_IMPORTNODES, IDH_IMPORTPWD);
begin
  Result := actNone;
  ImportForm := TImportForm.Create(Application);
  ImportForm.HelpContext := FHelpCtx[Passwords];
  ImportForm.Caption := ATitle;
  if not Passwords then
  begin
    ImportForm.rbFrontDoor.Enabled := False;
    ImportForm.rbMainDoor.Enabled := False;
  end;
  if ImportForm.ShowModal = mrOK then
  if ImportForm.rbBinkD.Checked then Result := actBinkD else
  if ImportForm.rbBinkPlus.Checked then Result := actBinkPlus else
  if ImportForm.rbTMail.Checked then Result := actTMail else
  if ImportForm.rbXenia.Checked then Result := actXenia else
  if ImportForm.rbFrontDoor.Checked then Result := actFrontDoor else
  if ImportForm.rbMainDoor.Checked then Result := actMainDoor;
  FreeObject(ImportForm);
end;

procedure TImportForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsImportForm);
end;



procedure TImportForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
