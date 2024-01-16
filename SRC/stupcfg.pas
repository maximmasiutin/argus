unit stupcfg;

{$I DEFINE.INC}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, ExtCtrls, Recs, Buttons;

type
  TStartupConfigForm = class(TForm)
    gbLines: TGroupBox;
    llManual: TLabel;
    lbManual: TListBox;
    lRight: TSpeedButton;
    lLeft: TSpeedButton;
    llAuto: TLabel;
    lbAuto: TListBox;
    cbDaemon: TCheckBox;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    cbFastLog: TCheckBox;
    cbLogWZ: TCheckBox;
    cbODBCLog: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lRightClick(Sender: TObject);
    procedure lLeftClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure lbManualKeyPress(Sender: TObject; var Key: Char);
    procedure lbAutoKeyPress(Sender: TObject; var Key: Char);
    procedure lbManualDblClick(Sender: TObject);
    procedure lbAutoClick(Sender: TObject);
  private
    ManualLines, AutoLines: TLineColl;
    procedure SetData;
    procedure UpdateLines;
  public
  end;

function StartupConfiguration: Boolean;

implementation uses xBase, LngTools;

{$R *.DFM}

function StartupConfiguration: Boolean;
var
  StartupConfigForm: TStartupConfigForm;
begin
  StartupConfigForm := TStartupConfigForm.Create(Application);
  StartupConfigForm.SetData;
  Result := StartupConfigForm.ShowModal = mrOK;
  FreeObject(StartupConfigForm);
end;

procedure TStartupConfigForm.SetData;
var
  o: Byte;
begin
  o := Cfg.StartupData.Options;
  cbDaemon.Checked := o and stoRunIpDaemon <> 0;
  cbFastLog.Checked := o and stoFastLog <> 0;
  cbLogWZ.Checked := not (o and stoSkipLogWZ <> 0);
  cbODBCLog.Checked := ODBC_Logging;
  TossItems(ManualLines, AutoLines, Pointer(Cfg.Lines.Copy), Cfg.StartupData.IdAutoOpenLines, Cfg.StartupData.CntAutoOpenLines);
  UpdateLines;
end;

procedure TStartupConfigForm.UpdateLines;
begin
  FillListBoxNamed(lbAuto, AutoLines);
  FillListBoxNamed(lbManual, ManualLines);
end;

procedure TStartupConfigForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsStartupConfigForm);
  {$IFDEF WS}
  cbDaemon.Visible := True;
  {$ENDIF}
  ManualLines := TLineColl.Create;
  AutoLines := TLineColl.Create;
end;

procedure TStartupConfigForm.FormDestroy(Sender: TObject);
begin
  FreeObject(ManualLines);
  FreeObject(AutoLines);
end;

procedure TStartupConfigForm.lRightClick(Sender: TObject);
begin
  MoveColl(ManualLines, AutoLines, lbManual.ItemIndex);
  UpdateLines;
end;

procedure TStartupConfigForm.lLeftClick(Sender: TObject);
begin
  MoveColl(AutoLines, ManualLines, lbAuto.ItemIndex);
  UpdateLines;
end;

procedure TStartupConfigForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i: Integer;
begin
  if ModalResult <> mrOK then Exit;
  CfgEnter;
  FreeMem(Cfg.StartupData.IdAutoOpenLines, Cfg.StartupData.CntAutoOpenLines*SizeOf(Integer));
  Cfg.StartupData.CntAutoOpenLines := AutoLines.Count;
  GetMem(Cfg.StartupData.IdAutoOpenLines, Cfg.StartupData.CntAutoOpenLines*SizeOf(Integer));
  for i := 0 to AutoLines.Count-1 do
  begin
    Cfg.StartupData.IdAutoOpenLines^[i] := TLineRec(AutoLines[i]).Id;
  end;
  i := 0;
  if cbDaemon.Checked then i := i or stoRunIpDaemon;
  if cbFastLog.Checked then i := i or stoFastLog;
  if not cbLogWZ.Checked then i := i or stoSkipLogWZ;
  Cfg.StartupData.Options := i;
  CfgLeave;
  StoreConfig(Handle);
  if cbODBCLog.Checked <> ODBC_Logging then
  begin
    ODBC_Logging := not ODBC_Logging;
    SetRegBoolean('ODBC Logging', ODBC_Logging);
  end;
end;

procedure TStartupConfigForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TStartupConfigForm.lbManualKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then lRight.Click;
end;

procedure TStartupConfigForm.lbAutoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = ' ' then lLeft.Click;
end;

procedure TStartupConfigForm.lbManualDblClick(Sender: TObject);
begin
  lRight.Click;
end;

procedure TStartupConfigForm.lbAutoClick(Sender: TObject);
begin
  lLeft.Click;
end;

end.
