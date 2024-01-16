unit MLineCfg;

interface

{$I DEFINE.INC}


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, ExtCtrls, Recs, xBase, ComCtrls, Buttons;

type
  TMailerLineCfgForm = class(TForm)
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    PageControl: TPageControl;
    pgGeneral: TTabSheet;
    pgAdvanced: TTabSheet;
    llStation: TLabel;
    llName: TLabel;
    llPort: TLabel;
    llModem: TLabel;
    llRestr: TLabel;
    llLog: TLabel;
    cbStation: TComboBox;
    lName: TEdit;
    cbPort: TComboBox;
    cbModem: TComboBox;
    cbRestrict: TComboBox;
    lLog: TEdit;
    lAvl: TListBox;
    lLnk: TListBox;
    bUP: TSpeedButton;
    bDN: TSpeedButton;
    bRight: TSpeedButton;
    bLeft: TSpeedButton;
    bEdit: TSpeedButton;
    labelAvl: TLabel;
    labelLinked: TLabel;
    llFaxIn: TLabel;
    lFaxIn: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure bRightClick(Sender: TObject);
    procedure bLeftClick(Sender: TObject);
    procedure lAvlClick(Sender: TObject);
    procedure bUPClick(Sender: TObject);
    procedure bDNClick(Sender: TObject);
    procedure lAvlKeyPress(Sender: TObject; var Key: Char);
    procedure lLnkKeyPress(Sender: TObject; var Key: Char);
    procedure lAvlDblClick(Sender: TObject);
    procedure lLnkDblClick(Sender: TObject);
  private
    { Private declarations }
    Line: TLineRec;
    C: TMainCfgColl;
    AvlEvts,
    LnkEvts: TEventColl;
    OrgEvtIds: PIntArray;
    OrgEvtCnt: Integer;
    CurEvtIds: PIntArray;
    CurEvtCnt: Integer;
    EvtChanged: Boolean;
    procedure UpdateLists;
    procedure UpdateEvt;
    procedure SetData;
    procedure RefillLists;
    procedure UpdateButtons;
  public
    { Public declarations }
  end;

function EditMailerLine(Line, C: Pointer; var EvtChanged: Boolean): Boolean;

implementation uses Events, LngTools;

{$R *.DFM}

function EditMailerLine;
var
  MailerLineCfgForm: TMailerLineCfgForm;
begin
  MailerLineCfgForm := TMailerLineCfgForm.Create(Application);
  MailerLineCfgForm.Line := Line;
  MailerLineCfgForm.C := C;
  MailerLineCfgForm.SetData;
  Result := MailerLineCfgForm.ShowModal = mrOK;
  EvtChanged := MailerLineCfgForm.EvtChanged;
  FreeObject(MailerLineCfgForm);
end;

procedure TMailerLineCfgForm.SetData;
begin
  lName.Text := Line.Name;
  lLog.Text := Line.LogFName;
  lFaxIn.Text := Line.FaxIn;
  C.Station.FillCombo(cbStation, rsRecsDefaultS, Line.d.StationId);
  C.Ports.FillCombo(cbPort, rsRecsDefaultP, Line.d.PortId);
  C.Modems.FillCombo(cbModem, rsRecsDefaultM, Line.d.ModemId);
  C.Restrictions.FillCombo(cbRestrict, rsRecsDefaultR, Line.d.RestrictId);
  CurEvtCnt := Line.EvtCnt;
  OrgEvtCnt := Line.EvtCnt;
  GetMem(CurEvtIds, CurEvtCnt*SizeOf(Integer));
  GetMem(OrgEvtIds, OrgEvtCnt*SizeOf(Integer));
  Move(Line.EvtIds^, CurEvtIds^, CurEvtCnt*SizeOf(Integer));
  Move(Line.EvtIds^, OrgEvtIds^, OrgEvtCnt*SizeOf(Integer));
  RefillLists;
end;

procedure TMailerLineCfgForm.UpdateEvt;
var
  i: Integer;
begin
  CurEvtCnt := LnkEvts.Count;
  ReallocMem(CurEvtIds, CurEvtCnt*SizeOf(Integer));
  for i := 0 to CurEvtCnt-1 do
  begin
    CurEvtIds^[i] := TElement(LnkEvts[i]).Id;
  end;
end;



procedure TMailerLineCfgForm.FormClose(Sender: TObject; var Action: TCloseAction);

procedure StoreGeneral;
var
  O: TLineOptionSet;
begin
  Line.FName := lName.Text;
  Line.LogFName := lLog.Text;
  Line.FaxIn := lFaxIn.Text;
  Line.d.StationId := C.Station.GetIdCombo(cbStation);
  Line.d.PortId := C.Ports.GetIdCombo(cbPort);
  Line.d.ModemId := C.Modems.GetIdCombo(cbModem);
  Line.d.RestrictId := C.Restrictions.GetIdCombo(cbRestrict);
  O := [];
  Line.D.Options := O;
end;

procedure StoreEvents;
var
  i: Integer;
begin
  UpdateEvt;
  if Line.EvtCnt>0 then FreeMem(Line.EvtIds, Line.EvtCnt*SizeOf(Integer));

  if not EvtChanged then
  begin
    if CurEvtCnt <> OrgEvtCnt then EvtChanged := True else
    begin
      for i := 0 to CurEvtCnt-1 do
      begin
        if CurEvtIds^[i] <> OrgEvtIds^[i] then
        begin
          EvtChanged := True;
          Break;
        end;
      end;
    end;
  end;

  Line.EvtCnt := CurEvtCnt; CurEvtCnt := 0;
  Line.EvtIds := CurEvtIds; CurEvtIds := nil;

end;

begin
  if ModalResult <> mrOK then Exit;
  StoreGeneral;
  StoreEvents;
end;

procedure TMailerLineCfgForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TMailerLineCfgForm.bEditClick(Sender: TObject);
begin
  UpdateEvt;
  if SetupEvents then
  begin
    RefillLists;
    EvtChanged := True;
  end;
end;

procedure TMailerLineCfgForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsMailerLineCfgForm);
  AvlEvts := TEventColl.Create;
  LnkEvts := TEventColl.Create;
end;

procedure TMailerLineCfgForm.FormDestroy(Sender: TObject);
begin
  FreeObject(AvlEvts);
  FreeObject(LnkEvts);
  if CurEvtIds <> nil then FreeMem(CurEvtIds, CurEvtCnt*SizeOf(Integer));
  if OrgEvtIds <> nil then FreeMem(OrgEvtIds, OrgEvtCnt*SizeOf(Integer));
end;

procedure TMailerLineCfgForm.UpdateLists;
begin
  FillListBoxNamed(lAvl, AvlEvts);
  FillListBoxNamed(lLnk, LnkEvts);
  UpdateButtons;
end;

procedure TMailerLineCfgForm.UpdateButtons;
begin
  bRight.Enabled := AvlEvts.Count>0;
  bLeft.Enabled := LnkEvts.Count>0;
  bUP.Enabled := lLnk.ItemIndex > 0;
  bDN.Enabled := (lLnk.ItemIndex<>-1) and (lLnk.ItemIndex<lLnk.Items.Count-1);
end;

procedure TMailerLineCfgForm.RefillLists;
begin
  AvlEvts.FreeAll;
  LnkEvts.FreeAll;
  TossItems(AvlEvts, LnkEvts, Pointer(Cfg.Events.Copy), CurEvtIds, CurEvtCnt);
  UpdateLists;
end;

procedure TMailerLineCfgForm.bRightClick(Sender: TObject);
begin
  MoveColl(AvlEvts, LnkEvts, lAvl.ItemIndex);
  UpdateLists;
end;

procedure TMailerLineCfgForm.bLeftClick(Sender: TObject);
begin
  MoveColl(LnkEvts, AvlEvts, lLnk.ItemIndex);
  UpdateLists;
end;

procedure TMailerLineCfgForm.lAvlClick(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TMailerLineCfgForm.bUPClick(Sender: TObject);
begin
  {}
end;

procedure TMailerLineCfgForm.bDNClick(Sender: TObject);
begin
  {}
end;




procedure TMailerLineCfgForm.lAvlKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then bRight.Click;
end;

procedure TMailerLineCfgForm.lLnkKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = ' ' then bLeft.Click;
end;

procedure TMailerLineCfgForm.lAvlDblClick(Sender: TObject);
begin
  bRight.Click;
end;

procedure TMailerLineCfgForm.lLnkDblClick(Sender: TObject);
begin
  bLeft.Click;
end;

end.
