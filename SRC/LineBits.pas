unit LineBits;

interface

{$I DEFINE.INC}


uses
  Forms, StdCtrls, Classes, Controls, ExtCtrls;

type
  TLineBitsEditor = class(TForm)
    cData: TRadioGroup;
    cParity: TRadioGroup;
    cStop: TRadioGroup;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  LineBitsEditor: TLineBitsEditor;

procedure EditLineBits(var Data, Parity, Stop: Integer);

implementation uses xBase, LngTools, Windows;

{$R *.DFM}

procedure EditLineBits;
  var D: TLineBitsEditor;
begin
     D := TLineBitsEditor.Create(Application);
     D.cData.ItemIndex := 8-Data;
     D.cStop.ItemIndex := Stop;
     D.cParity.ItemIndex := Parity;
     if D.ShowModal = mrOK then
       begin
         Data := 8-D.cData.ItemIndex;
         Stop := D.cStop.ItemIndex;
         Parity := D.cParity.ItemIndex;
       end;
     D.Free;
end;


procedure TLineBitsEditor.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TLineBitsEditor.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsLineBitsEditor);
end;

end.
