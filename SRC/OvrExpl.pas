unit OvrExpl;

interface

uses
  Forms, xBase, xFido, Controls, mGrids, Classes, StdCtrls;

type
  TOvrExplainForm = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    gOvr: TAdvGrid;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    LC, C: TColl;
    Activated, Dialup: Boolean;
    procedure SetData;
    function Valid: Boolean;
  public
  end;

function EditOverrideEx(C: TColl; Dialup: Boolean; const AAddr: TFidoAddress): Boolean;


implementation uses LngTools, SysUtils, Windows;

{$R *.DFM}

function EditOverrideEx;
const
  CH: array[Boolean] of Integer = (rsOvEdIp, rsOvEdDup);
var
  OvrExplainForm: TOvrExplainForm;
begin
  OvrExplainForm := TOvrExplainForm.Create(Application);
  OvrExplainForm.Caption := FormatLng(CH[Dialup], [Addr2Str(AAddr)]);
  OvrExplainForm.C := C;
  OvrExplainForm.Dialup := Dialup;
  OvrExplainForm.SetData;
  Result := OvrExplainForm.ShowModal = mrOK;
  FreeObject(OvrExplainForm);
end;

procedure TOvrExplainForm.SetData;
var
  i: Integer;
  O: TOvrData;
  s, z: string;
  S1, S2, S3, SC: TStringColl;
  t: TFSC62Time;
begin
  S1 := TStringColl.Create;
  S2 := TStringColl.Create;
  S3 := TStringColl.Create;
  for i := 0 to CollMax(C) do
  begin
    O := C[i];
    s := O.PhoneDirect;
    if s = '' then s := Addr2Str(O.PhoneNodelist);
    S1.Add(s);
    s := O.Flags;
    t := NodeFSC62Local(s);
    if (t = []) then z := '' else
    begin
      z := FSC62TimeToStr(t);
      SC := TStringColl.Create;
      SC.FillEnum(s, ',', False);
      PurgeTimeFlags(SC);
      s := SC.LongStringD(',');
      FreeObject(SC);
    end;
    S2.Add(s);
    S3.Add(z);
  end;
  gOvr.SetData([S1, S2, S3]);
  FreeObject(S1);
  FreeObject(S2);
  FreeObject(S2);
end;

function TOvrExplainForm.Valid: Boolean;
var
  err: Boolean;
  it: TOvrItemTyp;
  SC1, SC2, SC3, SC: TStringColl;
  PosU, i, j: Integer;
  s, s1, s2: string;
  O: TOvrData;
begin
  err := False;
  FreeObject(LC);
  SC1 := TStringColl.Create;
  SC2 := TStringColl.Create;
  SC3 := TStringColl.Create;
  gOvr.GetData([SC1, SC2, SC3]);
  for i := 0 to CollMax(SC1) do
  begin
    s1 := SC1[i];
    it := IdentOvrItem(s1, False, False);
    if Dialup then
    begin
      if (it <> oiAddress) and (it <> oiPhoneNum) then
      begin
        DisplayError(FormatLng(rsOvEdNotPhN, [s1]), Handle);
        err := True;
        Break;
      end;
    end else
    begin
      if (it <> oiAddress) and (it <> oiIpNum) and (it <> oiIpSym) then
      begin
        DisplayError(FormatLng(rsOvEdNotIP, [s1]), Handle);
        Err := True;
        Break;
      end;
    end;
//    if LC = nil then LC := TColl.Create;
    PosU := -1;
    s2 := Trim(SC2[i]);
    SC := TStringColl.Create;
    if s2 <> '' then
    begin
      SC.FillEnum(s2, ',', False);
      for j := 0 to CollMax(SC) do
      begin
        s := SC[j];
        if Copy(s, 1, 1) = '!' then Delete(s, 1, 1);
        if IdentOvrItem(s, False, True) <> oiFlag then
        begin
          DisplayError(FormatLng(rsOvEdNotFlag, [s]), Handle);
          FreeObject(SC);
          Err := True;
          Break;
        end;
        if (PosU = -1) and (UpperCase(s) = 'U') then PosU := j;
      end;
      if err then Break;
    end;
    s2 := Trim(SC3[i]);
    if s2 <> '' then
    begin
      s := HumanTime2UTxyL(s2, PosU = -1);
      if s = '' then
      begin
        DisplayError(FormatLng(rsOvEdNotTime, [s2]), Handle);
        FreeObject(SC);
        Err := True;
        Break;
      end;
      if PosU = -1 then j := SC.Count else j := PosU + Byte(s <> 'CM');
      SC.AtInsert(j, NewStr(StrAsg(s)));
    end;
    s2 := SC.LongStringD(',');
    FreeObject(SC);
    O := TOvrData.Create;
    case it of
      oiAddress: if not ParseAddress(s1, O.PhoneNodelist) then GlobalFail('%s', ['TOvrExplainForm.Valid (A)']);
      oiPhoneNum, oiIpNum, oiIpSym: O.PhoneDirect := s1;
      else GlobalFail('%s', ['TOvrExplainForm.Valid (B)'])
    end;
    O.Flags := s2;
    if LC = nil then LC := TColl.Create;
    LC.Add(O);
  end;
  if err then FreeObject(LC);
  Result := (CollCount(SC1) = 0) or (LC <> nil);
  FreeObject(SC1);
  FreeObject(SC2);
  FreeObject(SC2);
end;


procedure TOvrExplainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ModalResult <> mrOK then Exit;
  CanClose := False;
  if not Valid then Exit;
  CanClose := True;
end;

procedure TOvrExplainForm.FormDestroy(Sender: TObject);
begin
  FreeObject(LC);
end;

procedure TOvrExplainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  C.FreeAll;
  if LC <> nil then C.Concat(LC);
  FreeObject(LC);
end;

procedure TOvrExplainForm.FormActivate(Sender: TObject);
const
  C1H: array[Boolean] of Integer = (rsOvEdGIp, rsOvEdGPhN);
begin
  if Activated then Exit;
  Activated := True;
  gOvr.FillColTitles(['', LngStr(C1H[Dialup]), LngStr(rsOvEdGFlags), LngStr(rsOvEdGOT)]);
end;

procedure TOvrExplainForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TOvrExplainForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsOvrExplainForm);
end;

end.
