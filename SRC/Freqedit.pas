unit FreqEdit;

interface

{$I DEFINE.INC}


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, MClasses, xBase, xFido, mGrids;
                                                             
type
  TFReqDlg = class(TForm)
    gFiles: TAdvGrid;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
  private
    FName: string;
    Activated: Boolean;
    Stream: TDosStream;
    function SetData(const AFName: string): Boolean;
    procedure FreeStream;
  public
  end;

var
  FReqDlg: TFReqDlg;

function EditRequests(const A: TFidoAddress): Boolean;

implementation
uses Outbound, AdrIBox, Recs, LngTools;

{$R *.DFM}

function EditRequests(const A: TFidoAddress): Boolean;
var
  Dlg: TFreqDlg;
  FName: string;
begin
  Result := False;
  Dlg := TFreqDlg.Create(Application);
  Dlg.Caption := FormatLng(rsFeListFR, [Addr2Str(A)]);
  FName := GetOutFileName(A, osRequest);
  if Dlg.SetData(FName) then Result := (Dlg.ShowModal = mrOK) and (Dlg.FName <> '');
  Dlg.FreeStream;
  FreeObject(Dlg);
end;

procedure TFreqDlg.FreeStream;
var
  Sz: Integer;
begin
  if Stream = nil then Exit;
  Sz := Stream.Size;
  FreeObject(Stream);
  if Sz = 0 then DeleteFile(FName);
end;

procedure TFReqDlg.FormActivate(Sender: TObject);
begin
  if Activated then Exit;
  GridFillColLng(gFiles, rsFreqEGrid);
  Activated := False;
end;


function TFReqDlg.SetData(const AFName: string): Boolean;
var
  ReqLines: TColl;
  SC: TStringColl;
  i: Integer;
  rr: TReqRec;
  GI: Integer;
begin
  FName := AFName;
  Result := False;
  ClearErrorMsg;
  Stream := CreateDosStream(FName, [cRead, cWrite, cShareDenyRead, cExisting]);
  if Stream = nil then
  begin
    Stream := CreateDosStreamDir(FName, [cWrite, cEnsureNew, cShareDenyRead]);
    if Stream = nil then
    begin
      SetErrorMsg(FName);
      Exit;
    end;
  end else
  begin
    SC := TStringColl.Create;
    SC.LoadFromStream(Stream);
    Stream.Position := 0;
    ReqLines := ParseReq(SC);
    if ReqLines <> nil then
    begin
      GI := 1;
      for i := 0 to ReqLines.Count-1 do
      begin
        rr := ReqLines[i];
        if rr.Typ < rtOK then Continue;
        gFiles[1, GI] := rr.S;
        gFiles[2, GI] := rr.psw;
        Inc(GI);
        gFiles.RowCount := GI;
      end;
      FreeObject(ReqLines);
    end;  
  end;
  gFiles.RenumberRows;
  Result := True;
end;

procedure TFReqDlg.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i, RC: Integer;
  s, s1, s2: string;

function sq: string;
begin
  if Pos(' ', s1) = 0 then Result := s1 else Result := StrQuote(s1);
end;

begin
  if ModalResult <> mrOK then Exit;
  RC := gFiles.RowCount-1;
  for i := 1 to RC do
  begin
    s1 := Trim(gFiles[1, i]);
    s2 := Trim(gFiles[2, i]);
    if s2 = '' then s := sq else s := Format('%s !%s', [sq, s2]);
    Stream.WriteLn(s);
  end;
  if (RC = 1) and (s = '') then
  begin
    FreeObject(Stream);
    DeleteFile(FName);
    FName := '';
  end else
  begin
    Stream.Truncate;
    FreeStream;
  end;
end;

procedure TFReqDlg.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsFReqDlg);
end;

procedure TFReqDlg.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
