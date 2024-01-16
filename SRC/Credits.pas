unit Credits;

{$I DEFINE.INC}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ComCtrls, ExtCtrls;

type
  TRTFForm = class(TForm)
    Info: TRichEdit;
    BtnNb: TNotebook;
    bOK: TButton;
    bAgree: TButton;
    bDisagree: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure ShowLicence;
function AcceptLicence: Boolean;
procedure ShowCredits;


implementation uses xBase, LngTools;

{$R *.DFM}


function ShowForm(const AData: string; APageIndex: Integer; ACaption: Integer): Integer;
var
  RTFForm: TRTFForm;
  R: TResourceStream;
//  A: Classes.TStream;
begin
  RTFForm := TRTFForm.Create(Application);
  RTFForm.Caption := LngStr(ACaption);
  RTFForm.BtnNb.PageIndex := APageIndex;
  if APageIndex = 1 then
  begin
    RTFForm.bAgree.Caption := LngStr(rsCFagree);
    RTFForm.bDisagree.Caption := LngStr(rsCFdisagree);
  end;
  R := TResourceStream.Create(hInstance, AData, RT_RCDATA);
  RTFForm.Info.Lines.LoadFromStream(R);
  R.Free;
  Result := RTFForm.ShowModal;
  FreeObject(RTFForm);
end;

function _ShowLicence(A: Integer): Boolean;
begin
  case CurrentLng of
    MaxInt: Result := False;
(*
{$IFDEF LNG_RUSSIAN} idlRussian : Result := ShowForm(dLicRus, A, rsCFlicence) = mrYes;  {$ENDIF}
{$IFDEF LNG_GERMAN}  idlGerman  : Result := ShowForm(dLicGer, A, rsCFlicence) = mrYes;  {$ENDIF}
{$IFDEF LNG_SPANISH} idlSpanish : Result := ShowForm(dLicence, A, rsCFlicence) = mrYes; {$ENDIF}
{$IFDEF LNG_DUTCH}   idlDutch   : Result := ShowForm(dLicence, A, rsCFlicence) = mrYes; {$ENDIF}
{$IFDEF LNG_DANISH}  idlDanish  : Result := ShowForm(dLicence, A, rsCFlicence) = mrYes; {$ENDIF}
*)
    else Result := ShowForm('IDR_LICENCE', A, rsCFlicence) = mrYes;
  end;
end;

procedure ShowLicence;
begin
  _ShowLicence(0);
end;

function AcceptLicence: Boolean;
begin
  Result := _ShowLicence(1);
end;

procedure ShowCredits;
begin
  ShowForm('IDR_CREDITS', 0, rsCFcredits);
end;

procedure TRTFForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = VK_ESCAPE) or ((key = VK_RETURN) and (bOK.Focused)) then PostMessage(Handle, WM_CLOSE, 0, 0);
end;

end.


