unit FileBox;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  mGrids, ComCtrls, StdCtrls;

type
  TFileBoxesForm = class(TForm)
    PageControl: TPageControl;
    tsNodes: TTabSheet;
    tsOptions: TTabSheet;
    gNodes: TAdvGrid;
    eRoot: TEdit;
    lRoot: TLabel;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    Activated: Boolean;
    procedure SetData;
    function GetData: Pointer;
  public
  end;


function SetupFileBoxes: Boolean;

implementation uses Recs, xBase, xFido, LngTools, Outbound;

{$R *.DFM}

function SetupFileBoxes;
var
  FileBoxesForm: TFileBoxesForm;
begin
  FileBoxesForm := TFileBoxesForm.Create(Application);
  FileBoxesForm.SetData;
  Result := FileBoxesForm.ShowModal = mrOK;
  FreeObject(FileBoxesForm);
end;


procedure TFileBoxesForm.SetData;
var
  S1, S2, S3: TStringColl;
  fb: TFileBoxCfg;
  i: Integer;
  sRoot: string;
begin
  S1 := TStringColl.Create;
  S2 := TStringColl.Create;
  S3 := TStringColl.Create;
  CfgEnter;
  for i := 0 to Cfg.FileBoxes.Count-1 do
  begin
    fb := Cfg.FileBoxes[i];
    S1.Add(fb.FAddr);
    S2.Add(OutStatus2Char(fb.fStatus));
    S3.Add(StrAsg(fb.FDir));
  end;
  sRoot := StrAsg(Cfg.FileBoxes.DefaultDir);
  CfgLeave;
  eRoot.Text := sRoot;
  gNodes.SetData([S1, S2, S3]);
  FreeObject(S1);
  FreeObject(S2);
  FreeObject(S3);
end;

function TFileBoxesForm.GetData: Pointer;
var
  S1, S2, S3: TStringColl;
  fbc: TFileBoxCfgColl;
  fb: TFileBoxCfg;
  i: Integer;
  a: Ta4s;
  o: TOutStatus;
  s: string;
  fbdc: TFileBoxDirColl;
begin
  Result := nil;
  S1 := TStringColl.Create;
  S2 := TStringColl.Create;
  S3 := TStringColl.Create;
  gNodes.GetData([S1, S2, S3]);
  fbc := TFileBoxCfgColl.Create;
  fbc.DefaultDir := eRoot.Text;
  for i := 0 to S1.Count-1 do
  begin
    if not SplitAddress(S1[i], a, True) then
    begin
      FreeObject(fbc);
      DisplayError(FormatLng(rsXfNoValidAOM, [S1[i]]), Handle);
      Break;
    end;
    if not PureAddressMasks(a) then
    begin
      FreeObject(fbc);
      DisplayError(FormatLng(rsFbNPAM, [S1[i]]), Handle);
      Break;
    end;
    s := Trim(S2[i]);
    if s = '' then o := osNormal else o := Char2OutStatus(s[1]);
    fb := TFileBoxCfg.Create;
    fb.FAddr := S1[i];
    fb.FStatus := o;
    fb.FDir := S3[i];
    fbc.Add(fb);
  end;
  FreeObject(S1);
  FreeObject(S2);
  FreeObject(S3);

  if fbc = nil then Exit;

  fbdc := TFileBoxDirColl.Create;

  for i := 0 to fbc.Count-1 do
  begin
    fb := fbc[i];
    if not GetFileBoxDirColl(fb.FAddr, fb.Dir(fbc.DefaultDir, 0), fb.FStatus, fbdc, @s, nil, nil) then
    begin
      FreeObject(fbc);
      DisplayError(s, Handle);
      Break;
    end;
  end;
  FreeObject(fbdc);

  Result := fbc;
end;

procedure TFileBoxesForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  FileBoxes: TFileBoxCfgColl;
begin
  if ModalResult <> mrOK then Exit;
  FileBoxes := GetData;
  if FileBoxes = nil then Exit;
  CfgEnter;
  Xchg(Integer(Cfg.FileBoxes), Integer(FileBoxes));
  CfgLeave;
  FreeObject(FileBoxes);
  StoreConfig(Handle);
end;

procedure TFileBoxesForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  FileBoxes: TFileBoxCfgColl;
begin
  if ModalResult <> mrOK then Exit;
  FileBoxes := GetData;
  CanClose := FileBoxes <> nil;
  FreeObject(FileBoxes);
end;

procedure TFileBoxesForm.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  Activated := True;
  GridFillColLng(gNodes, rsFbGT);
end;

procedure TFileBoxesForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsFileBoxesForm);
end;

procedure TFileBoxesForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
