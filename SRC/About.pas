unit About;

{$I DEFINE.INC}

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    ProgramIcon: TImage;
    lCopyright: TLabel;
    lName: TLabel;
    lVersion: TLabel;
    Button1: TButton;
    bInfo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure bInfoClick(Sender: TObject);
  private
  public
  end;

procedure ShowAbout;

implementation uses xBase, Recs, LngTools, Credits;

{$R *.DFM}


procedure ShowAbout;
var
  AboutBox: TAboutBox;
begin
  AboutBox := TAboutBox.Create(Application);
  AboutBox.ShowModal;
  FreeObject(AboutBox);
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  lCopyright.Caption :=
  'Copyright © 1996-2001 RITLABS S.R.L. All rights reserved'#13#10#13#10+
  'Argus is written by Maxim Masiutin'#13#10#13#10+
  'Contains cryptographic software written by Eric Young';
  lName.Caption := ProductNameFull + ', ' +LngStr({$IFDEF WS}rsAboutTCP{$ELSE}rsAboutDialup{$ENDIF});;
  lVersion.Caption := FormatLng(rsAboutVersion, [ProductVersion]) + ', '+ProductDate;
end;


procedure TAboutBox.FormKeyPress(Sender: TObject; var Key: Char);
begin
  Close;
end;

procedure TAboutBox.bInfoClick(Sender: TObject);
begin
  ShowCredits;
end;

end.


