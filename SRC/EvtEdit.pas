unit EvtEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, ExtCtrls, xBase, Recs, ComCtrls;

type
  TEvtEditForm = class(TForm)
    iName: TEdit;
    iCron: TEdit;
    llName: TLabel;
    llCron: TLabel;
    llL: TGroupBox;
    iiH: TEdit;
    iiD: TEdit;
    iiM: TEdit;
    llD: TLabel;
    llH: TLabel;
    llM: TLabel;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    llAtoms: TLabel;
    bAddAtom: TButton;
    bDelete: TButton;
    bEdit: TButton;
    lb: TListView;
    cbPermanent: TCheckBox;
    cbUTC: TCheckBox;
    procedure bAddAtomClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure lbChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure lbClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure cbPermanentClick(Sender: TObject);
  private
    Event: TEventContainer;
    Length: Integer;
    procedure SetData;
    procedure RefillListBox;
    procedure SetButtons;
    procedure InvalidatePermanent;
  public
    { Public declarations }
  end;

function EditEvent(Event: Pointer): Boolean;
function EvtLenDesc(Len: Integer; Permanent: Boolean): string;

implementation uses LngTools, AtomEdit, xFido;  

{$R *.DFM}

procedure ParseLen(Len: Integer; var d, h, m: string; Opt: Boolean);
var
  dd, hh, mm: Integer;
begin
  dd  := Len div (60 * 24);
  Len := Len mod (60 * 24);
  hh  := Len div 60;
  Len := Len mod 60;
  mm  := Len;
  if Opt and (dd = 0) then d := '' else d := IntToStr(dd);
  if Opt and (hh = 0) then h := '' else h := IntToStr(hh);
  if Opt and (mm = 0) then m := '' else m := IntToStr(mm);
end;


function EditEvent;
var
  EvtEditForm: TEvtEditForm;
begin
  EvtEditForm := TEvtEditForm.Create(Application);
  EvtEditForm.Event := Event;
  EvtEditForm.SetData;
  Result := EvtEditForm.ShowModal = mrOK;
  FreeObject(EvtEditForm);
end;

procedure TEvtEditForm.bAddAtomClick(Sender: TObject);
var
  a: TEventAtom;
begin
  a := EditAtom(nil);
  if a <> nil then
  begin
    Event.Atoms.Insert(a);
    RefillListBox;
  end;
end;

procedure TEvtEditForm.SetData;
var
  d, h, m: string;
begin
  iName.Text := Event.Name;
  iCron.Text := Event.Cron;
  ParseLen(Event.Len, d, h, m, True);
  iiD.Text := d;
  iiH.Text := h;
  iiM.Text := m;
  RefillListBox;
  cbPermanent.Checked := Event.Permanent;
  cbUTC.Checked := Event.UTC;
  InvalidatePermanent;
end;

procedure TEvtEditForm.RefillListBox;
var
  i: Integer;
  a: TEventAtom;
begin
  lb.Items.Clear;
  for i := 0 to Event.Atoms.Count-1 do
  begin
    a := Event.Atoms[i];
    with lb.Items.Add do
    begin
      Caption := a.Name;
      SubItems.Add(a.Params);
    end;
  end;
  SetButtons;
end;

procedure TEvtEditForm.bEditClick(Sender: TObject);
var
  ao, an: TEventAtom;
  i: Integer;
  li: TListItem;
begin
  if not bEdit.Enabled then Exit;
  li := lb.ItemFocused;
  if li = nil then Exit;
  i := li.Index;
  ao := Event.Atoms[i];
  an := EditAtom(ao);
  if an <> nil then
  begin
    Event.Atoms[i] := an;
    FreeObject(ao);
    RefillListBox;
  end;  
end;

procedure TEvtEditForm.bDeleteClick(Sender: TObject);
var
  i: Integer;
  li: TListItem;
begin
  li := lb.ItemFocused;
  if li = nil then Exit;
  i := li.Index;
  Event.Atoms.AtFree(i);
  RefillListBox;
end;

procedure TEvtEditForm.lbChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  SetButtons;
end;

procedure TEvtEditForm.lbClick(Sender: TObject);
begin
  SetButtons;
end;

procedure TEvtEditForm.SetButtons;
var
  b: Boolean;
begin
  b := lb.ItemFocused <> nil;
  bEdit.Enabled := b;
  bDelete.Enabled := b;
end;


procedure TEvtEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Event.FName := iName.Text;
  Event.Cron  := iCron.Text;
  Event.Len   := Length;
  Event.Permanent := cbPermanent.Checked;
  Event.UTC := cbUTC.Checked;
end;

function EvtLenDesc(Len: Integer; Permanent: Boolean): string;
var
  d, h, m: string;
begin
  if Permanent then Result := LngStr(rsEvEdPerm) else
  begin
    ParseLen(Len, d, h, m, False);
    if d <> '0' then Result := FormatLng(rsEvEdNdays, [d]) else Result := '';
    if h <> '0' then Result := Result + FormatLng(rsEvEdNhours, [h]);
    if (m <> '0') or (Result = '') then Result := Result + FormatLng(rsEvEdNmins, [m]);
  end;
end;

procedure TEvtEditForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);

function Get(var AVl: Integer; e: TEdit; Mx: Integer): Boolean;
var
  s: string;
  D: DWORD;
begin
  Result := False;
  if Trim(iName.Text) = '' then
  begin
    iName.SetFocus;
    DisplayErrorLng(rsEvNmBlnk, Handle);
    Exit;
  end;
  s := e.Text;
  if s = '' then AVl := 0 else
  begin
    D := Vl(s);
    if (D = INVALID_VALUE) or (D > DWORD(MaxInt)) then
    begin
      DisplayError(FormatLng(rsEvNotNum, [s]),Handle);
      Exit
    end;
    AVl := D;
  end;
  if (AVl > Mx) or (AVl<0) then
  begin
    DisplayError(FormatLng(rsEvNumRange, [AVl, 0, Mx]), Handle);
    Exit;
  end;
  Result := True;
end;

var
  d,h,m: Integer;
begin
  if ModalResult <> mrOK then Exit;
  CanClose := False;
  if not ValidCronRecDlg(iCron.Text, Handle, cbPermanent.Checked) then Exit;
  if not Get(d, iiD, 600) or
     not Get(h, iiH, 23) or
     not Get(m, iiM, 59) then Exit;
  Length := m +
            h * 60 +
            d * 24 * 60;
  CanClose := True;
end;

procedure TEvtEditForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsEvtEditForm);
end;

procedure TEvtEditForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;


procedure TEvtEditForm.cbPermanentClick(Sender: TObject);
begin
  InvalidatePermanent;
end;

procedure TEvtEditForm.InvalidatePermanent;
var
  B: Boolean;
begin
  B := not cbPermanent.Checked;
  llD.Enabled := B;
  iiD.Enabled := B;
  llH.Enabled := B;
  iiH.Enabled := B;
  llM.Enabled := B;
  iiM.Enabled := B;
  llL.Enabled := B;
  llCron.Enabled := B;
  iCron.Enabled := B;
  cbUTC.Enabled := B;
end;

end.


