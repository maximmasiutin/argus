unit Attach;

{$I DEFINE.INC}


interface

uses
  Forms, xFido, StdCtrls, Classes, Controls, ExtCtrls;

type
  TAttachStatusForm = class(TForm)
    bAttach: TRadioGroup;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    bOnSent: TRadioGroup;
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function GetAttachStatusEx(var Status: TOutStatus; var Poll: Boolean; Action: PKillAction): Boolean;

implementation uses xBase, Windows, LngTools;

{$R *.DFM}

function GetAttachStatus(Action: PKillAction): Integer;
var
  AttachStatusForm: TAttachStatusForm;
begin
  AttachStatusForm := TAttachStatusForm.Create(Application);
  if Action = nil then
  begin
    AttachStatusForm.ClientHeight := AttachStatusForm.bOnSent.Top;
    FreeObject(AttachStatusForm.bOnSent);
  end;
  if AttachStatusForm.ShowModal <> mrOK then Result := -1 else
  begin
    if Action <> nil then Action^ := TKillAction(AttachStatusForm.bOnSent.ItemIndex);
    Result := AttachStatusForm.bAttach.ItemIndex;
  end;
  FreeObject(AttachStatusForm);
end;

function GetAttachStatusEx(var Status: TOutStatus; var Poll: Boolean; Action: PKillAction): Boolean;
var
  I: Integer;
begin
  Result := False;
  Status := osError;
  Poll := False;
  I := GetAttachStatus(Action);
  case I of
   -1 : Exit;
    0 : Status := osHold;
    1 : Status := osNormal;
    2 : Status := os_Direct;
    3 : Status := os_Crash;
    4 : begin Status := os_Crash; Poll := True end;
    else GlobalFail('GetAttachStatusEx=%d', [I]);
  end;
  Result := True;
end;


procedure TAttachStatusForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsAttachStatusForm);
end;

procedure TAttachStatusForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
