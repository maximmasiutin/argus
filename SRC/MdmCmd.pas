unit MdmCmd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, MClasses;

type
  TModemCmdForm = class(TForm)
    eModemCommand: THistoryLine;
    bSend: TButton;
    bClose: TButton;
    lModemCommand: TLabel;
    bHelp: TButton;
    procedure eModemCommandChange(Sender: TObject);
    procedure bSendClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
  public
    P: Pointer;
  end;

implementation uses MlrThr, MlrForm, LngTools;

{$R *.DFM}

procedure TModemCmdForm.eModemCommandChange(Sender: TObject);
begin
  bSend.Enabled := eModemCommand.Text <> '';
end;

procedure TModemCmdForm.bSendClick(Sender: TObject);
var
  s: string;
  T: TMailerForm;
begin
  s := eModemCommand.Text;
  if s = '' then Exit;
  if s[Length(s)] <> '|' then s := s + '|';
  HistoryAdd(eModemCommand.HistoryID, s);
  T := P;
  T.InsertEvt(TMlrEvtSendMdmCmd.Create(s));
end;

procedure TModemCmdForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsModemCmdForm);
end;

procedure TModemCmdForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
