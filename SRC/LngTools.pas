unit LngTools;

{$I DEFINE.INC}

interface uses Forms, Windows;

{$I ..\LNG\LNGC.INC}
{$I ..\LNG\CCONST.INC}
{$I ..\LNG\FCONST.INC}

const
     idlEnglish    =  0;
{$IFDEF LNG_RUSSIAN}   idlRussian    =  1; {$ENDIF}
{$IFDEF LNG_MITKY}     idlMitky      =  2; {$ENDIF}
{$IFDEF LNG_ROMANIAN}  idlRomanian   =  3; {$ENDIF}
{$IFDEF LNG_CHECH}     idlCzech      =  4; {$ENDIF}
{$IFDEF LNG_UKRAINIAN} idlUkrainian  =  5; {$ENDIF}
{$IFDEF LNG_BULGARIAN} idlBulgarian  =  6; {$ENDIF}
{$IFDEF LNG_POLISH}    idlPolish     =  7; {$ENDIF}
{$IFDEF LNG_GERMAN}    idlGerman     =  8; {$ENDIF}
{$IFDEF LNG_DUTCH}     idlDutch      =  9; {$ENDIF}
{$IFDEF LNG_SPANISH}   idlSpanish    = 10; {$ENDIF}
{$IFDEF LNG_DANISH}    idlDanish     = 11; {$ENDIF}

var
  ResLngBase: Integer;
  CurrentLng: Integer;

procedure GridFillColLng(AG: Pointer; Id: Integer);
procedure GridFillRowLng(AG: Pointer; Id: Integer);
procedure DisplayErrorLng(Id: Integer; Handle: DWORD);
procedure DisplayInfoLng(Id: Integer; Handle: DWORD);
procedure DisplayErrorFmtLng(Id: Integer; const Args: array of const; Handle: DWORD);
function  YesNoConfirmLng(Id: Integer; AHandle: DWORD): Boolean;
function  OkCancelConfirmLng(Id: Integer; AHandle: DWORD): Boolean;
function LngStr(i: Integer): string;
function FormatLng(Id: Integer; const Args: array of const): string;
procedure FillForm(f: TForm; Id: Integer);
procedure SetLanguage(Index: Integer);
procedure LanguageDone;

implementation

uses mGrids, xBase, SysUtils, Classes, Menus, StdCtrls, ExtCtrls, ComCtrls;

{$R ..\LNG\ENG.RES}

{$IFDEF LNG_GERMAN}
{$R ..\LNG\GER.RES}
{$ENDIF}

{$IFDEF LNG_RUSSIAN}
{$R ..\LNG\RUS.RES}
{$ENDIF}

{$IFDEF LNG_DUTCH}
{$R ..\LNG\DUT.RES}
{$ENDIF}

{$IFDEF LNG_DANISH}
{$R ..\LNG\DAN.RES}
{$ENDIF}


procedure GridFillColLng(AG: Pointer; Id: Integer);
var
  g: TAdvGrid absolute AG;
  s,z: string;
  i: Integer;
begin
  s := LngStr(Id);
  i := 0;
  while s <> '' do
  begin
    GetWrd(s, z, '|');
    g.Cells[I, 0] := ' '+z;
    Inc(i);
  end;
end;

procedure GridFillRowLng(AG: Pointer; Id: Integer);
var
  g: TAdvGrid absolute AG;
  s,z: string;
  i: Integer;
begin
  s := LngStr(Id);
  i := 0;
  while s <> '' do
  begin
    GetWrd(s, z, '|');
    g.Cells[0, I] := ' '+z;
    Inc(i);
  end;
end;


procedure DisplayErrorLng(Id: Integer; Handle: DWORD);
begin
  DisplayError(LngStr(Id), Handle);
end;

procedure DisplayInfoLng(Id: Integer; Handle: DWORD);
begin
  DisplayCustomInfo(LngStr(Id), Handle);
end;

procedure DisplayErrorFmtLng(Id: Integer; const Args: array of const; Handle: DWORD);
begin
  DisplayError(FormatLng(Id, Args), Handle);
end;

function LngStr(i: Integer): string;
const
  StrBufSize = $1000;
var
  Buf: array[0..StrBufSize] of Char;
  l: Integer;
begin              
//  SetThreadLocale(LANG_RUSSIAN);
  l := LoadString(HInstance,i+ResLngBase, @Buf, StrBufSize);
  if l = 0 then
  GlobalFail('LoadString Idx %d Error %d (ResLngBase=%d)', [i, GetLastError, ResLngBase]);
  SetLength(Result, l);
  Move(Buf, Result[1], l);
end;


function FormatLng(Id: Integer; const Args: array of const): string;
begin
  Result := Format(LngStr(Id), Args);
end;                 

function  YesNoConfirmLng(Id: Integer; AHandle: DWORD): Boolean;
begin
  Result := YesNoConfirm(LngStr(Id), AHandle);
end;

function  OkCancelConfirmLng(Id: Integer; AHandle: DWORD): Boolean;
begin
  Result := OkCancelConfirm(LngStr(Id), AHandle);
end;

procedure FillForm;
var
  s, z: string;
  L: TStringColl;
  i, j: Integer;
  C: TComponent;
begin
  L := TStringColl.Create;
  L.LoadFromString(LngStr(Id));
  F.Caption := L[0];
  for i := 1 to L.Count-1 do
  begin
    s := L[i];
    GetWrd(s, z, '|');
    C := F.FindComponent(z);
    if C = nil then Continue;
    GetWrd(s, z, '|');
    if C is TMenuItem then TMenuItem(C).Caption := z else
    if C is TLabel then TLabel(C).Caption := z else
    if C is TButton then TButton(C).Caption := z else
    if C is TCheckBox then TCheckBox(C).Caption := z else
    if C is TRadioButton then TRadioButton(C).Caption := z else
    if C is TGroupBox  then TGroupBox (C).Caption := z else
    if C is TPanel then TPanel(C).Caption := z else
    if C is TRadioGroup then
      begin
        TRadioGroup(C).Caption := z;
        j := 0;
        while s <> '' do
        begin
          GetWrd(s, z, '|');
          TRadioGroup(C).Items[j] := z;
          Inc(j);
        end;
      end else
    if C is TPageControl then
      begin
        TPageControl(C).Pages[0].Caption := z;
        j := 1;
        while s <> '' do
        begin
          GetWrd(s, z, '|');
          TPageControl(C).Pages[j].Caption := z;
          Inc(j);
        end;
      end else
    if C is TListView then
      begin
        TListView(C).Columns[0].Caption := z;
        j := 1;
        while s <> '' do
        begin
          GetWrd(s, z, '|');
          TListView(C).Columns[j].Caption := z;
          Inc(j);
        end;
      end else
    if C is THeaderControl then
      begin
        THeaderControl(C).Sections[0].Text := z;
        j := 1;
        while s <> '' do
        begin
          GetWrd(s, z, '|');
          THeaderControl(C).Sections[j].Text := z;
          Inc(j);
        end;
      end;
  end;
  FreeObject(L);
end;


procedure SetLanguage;
begin
  CurrentLng := Index;
  case Index of
    MaxInt :;
    {$IFDEF LNG_SPANISH} idlSpanish: ResLngBase := LngBaseSpanish; {$ENDIF}
    {$IFDEF LNG_DUTCH}   idlDutch:   ResLngBase := LngBaseDutch;   {$ENDIF}
    {$IFDEF LNG_GERMAN}  idlGerman:  ResLngBase := LngBaseGerman;  {$ENDIF}
    {$IFDEF LNG_DANISH}  idlDanish:  ResLngBase := LngBaseDanish;  {$ENDIF}
    {$IFDEF LNG_RUSSIAN} idlRussian: ResLngBase := LngBaseRussian; {$ENDIF}
    else
      begin
        CurrentLng := 0;
        ResLngBase := LngBaseEnglish;
      end;
  end;
end;

procedure LanguageDone;
begin
end;

initialization
 ResLngBase := LngBaseEnglish;
 CurrentLng := -1;
end.
