unit TracePl;

interface

uses
   Forms, StdCtrls, Classes, Controls, xBase;

type
  TDisplayInfoForm = class(TForm)
    bOK: TButton;
    Field: TMemo;
    procedure FormCreate(Sender: TObject);
  private
  public
  end;

procedure DisplayInfoFormEx(const ATitle: string; SC: TStringColl);

implementation uses LngTools;

{$R *.DFM}

procedure DisplayInfoFormEx(const ATitle: string; SC: TStringColl);
var
  DisplayInfoForm: TDisplayInfoForm;
begin
  DisplayInfoForm := TDisplayInfoForm.Create(Application);
  DisplayInfoForm.Caption := ATitle;
  DisplayInfoForm.Field.SetTextBuf(PChar(SC.LongString));
  DisplayInfoForm.Field.WordWrap := True;
  DisplayInfoForm.ShowModal;
  FreeObject(DisplayInfoForm);
end;

procedure TDisplayInfoForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsDisplayInfoForm);
end;

end.
