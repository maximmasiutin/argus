unit DevCfg;

interface

{$I DEFINE.INC}


uses
   Forms, Recs, xBase, StdCtrls, Controls, Classes, ExtCtrls;

type
  TDeviceConfig = class(TForm)
    lComPort: TLabel;
    lRate: TLabel;
    cbCom: TComboBox;
    cbSpeed: TComboBox;
    gFlow: TGroupBox;
    cbCTS_RTS: TCheckBox;
    cbXon_Xoff: TCheckBox;
    bBits: TButton;
    llBits: TLabel;
    lBits: TLabel;
    Bevel1: TBevel;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    procedure bBitsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbSpeedKeyPress(Sender: TObject; var Key: Char);
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fData, fParity, fStop: Integer;
    Port: TPortRec;
    procedure SetData;
    procedure UpdateLineBits;
  end;


function EditPort(Port: Pointer): Boolean;

implementation uses LineBits, LngTools, SysUtils, Windows;

{$R *.DFM}

procedure TDeviceConfig.bBitsClick(Sender: TObject);
begin
  EditLineBits(fData, fParity, fStop);
  UpdateLineBits;
end;

function EditPort(Port: Pointer): Boolean;
var
  DeviceConfig: TDeviceConfig;
begin
  DeviceConfig := TDeviceConfig.Create(Application);
  DeviceConfig.Port := Port;
  DeviceConfig.SetData;
  Result := DeviceConfig.ShowModal = mrOK;
  FreeObject(DeviceConfig);
end;

procedure TDeviceConfig.SetData;
begin
  cbCOM.ItemIndex := Port.d.Port;
  cbSpeed.Text := IntToStr(Port.d.BPS);
  cbCTS_RTS.Checked := Port.d.hFlow;
  cbXon_Xoff.Checked := Port.d.sFlow;
  fData := Port.d.Data;
  fParity := Port.d.Parity;
  fStop := Port.d.Stop;
  UpdateLineBits;
end;

procedure TDeviceConfig.UpdateLineBits;
begin
  lBits.Caption := GetLineBits(fData, fParity, fStop);
end;

procedure TDeviceConfig.FormClose(Sender: TObject; var Action: TCloseAction);
var
  D: DWORD;
begin
  if ModalResult <> mrOK then Exit;
  Port.d.Port := cbCOM.ItemIndex;
  D := Vl(cbSpeed.Text);
  if D = INVALID_VALUE then Port.d.BPS := DefBPS else Port.d.BPS := D;
  Port.d.hFlow := cbCTS_RTS.Checked;
  Port.d.sFlow := cbXon_Xoff.Checked;
  Port.d.Data := fData;
  Port.d.Parity := fParity;
  Port.d.Stop := fStop;
end;

procedure TDeviceConfig.cbSpeedKeyPress(Sender: TObject; var Key: Char);
begin
  case Key of
     #8, '0'..'9' :;
    else Key := #0;
  end;
end;

procedure TDeviceConfig.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TDeviceConfig.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsDeviceConfig);
end;

end.


