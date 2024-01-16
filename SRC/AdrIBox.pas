unit AdrIBox;

interface

{$I DEFINE.INC}


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, xBase, xFido, MClasses, ExtCtrls;

type
  TFidoAddressInput = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    AddressBox: TGroupBox;
    lAddress: THistoryLine;
    bBrowse: TButton;
    bHelp: TButton;
    procedure bBrowseClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    Activated,
    Multi: Boolean;
    AddrColl: TFidoAddrColl;
  public
    OA: PFidoAddress;
  end;

var
  FidoAddressInput: TFidoAddressInput;

function InputFidoAddress(const Caption: string; AMulti: Boolean; ADefault: PFidoAddress): TFidoAddrColl;
function InputSingleAddress(const Caption: string; var Addr: TFidoAddress; ADefault: PFidoAddress): Boolean;

implementation

uses LngTools, NodeBrws;

{$R *.DFM}

function InputSingleAddress;
var
  A: TFidoAddrColl;
begin
  Result := False;
  A := InputFidoAddress(Caption, False, ADefault);
  case CollCount(A) of
    0 : ;
    1 : begin Addr := A[0]; Result := True end;
    else GlobalFail('InputSingleAddress, CollCount = %d', [CollCount(A)]);
  end;
  FreeObject(A);
end;

function InputFidoAddress;
var
  D: TFidoAddressInput;
begin
  Result := nil;
  D := TFidoAddressInput.Create(Application);
  D.OA := ADefault;
  if Caption <> '' then D.Caption := Caption;
  D.Multi := AMulti;
  if D.ShowModal = mrOK then Result := D.AddrColl;
  FreeObject(D);
end;

procedure AddToHistory(L: TStringColl; const S: String);
  var I: Integer;
begin
  if S = '' then Exit;
  I := L.IdxOf(S);
  if I >= 0 then L.AtFree(I);
  L.AtIns(0, S);
end;

{ ----------------------------- Init/Finis ------------------------- }


procedure TFidoAddressInput.bBrowseClick(Sender: TObject);
var
  Addr: TFidoAddress;
  s: string;
begin
  if SelectNode(Addr) then
  begin
    if not Multi then lAddress.Text := Addr2Str(Addr) else
    begin
      s := lAddress.Text; if s <> '' then AddStr(s, ' ');
      s := s + Addr2Str(Addr);
      lAddress.Text := s;
    end;
  end;
end;

procedure TFidoAddressInput.FormActivate(Sender: TObject);
var
  i: Integer;
begin
  if Activated then Exit;
  if OA <> nil then lAddress.Text := Addr2Str(OA^);
  if Multi then AddressBox.Caption := LngStr(rsAdrInAdrLst) else
  begin
    AddressBox.Caption := LngStr(rsAdrInAdr);
    for i := lAddress.Items.Count-1 downto 0 do
    begin
      if Pos(' ', Trim(lAddress.Items[i]))>0 then lAddress.Items.Delete(i);
    end;
    if Pos(' ', Trim(lAddress.Text))>0 then lAddress.Text := '';
  end;
  Activated := True;
end;

procedure TFidoAddressInput.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
  CanClose := False;
  AddrColl := CreateAddrColl(lAddress.Text);
  if AddrColl = nil then
  begin
    DisplayErrorLng(rsAdrInNoValidAdr, Handle);
    Exit;
  end;
  if (not Multi) and (AddrColl.Count > 1) then
  begin
    DisplayErrorFmtLng(rsAdrInNoMulti, [Caption], Handle);
    Exit;
  end;
  CanClose := True;
end;

procedure TFidoAddressInput.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsFidoAddressInput);
end;

procedure TFidoAddressInput.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.


