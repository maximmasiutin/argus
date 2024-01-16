unit Events;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  ComCtrls, Menus, StdCtrls, Recs;

type
  TEventsForm = class(TForm)
    lv: TListView;
    bNew: TButton;
    bEdit: TButton;
    bCopy: TButton;
    bDelete: TButton;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    PopupMenu: TPopupMenu;
    ppNew: TMenuItem;
    N1: TMenuItem;
    ppEdit: TMenuItem;
    ppCopy: TMenuItem;
    ppDelete: TMenuItem;
    mPopup: TMenuItem;
    procedure bEditClick(Sender: TObject);
    procedure bNewClick(Sender: TObject);
    procedure bCopyClick(Sender: TObject);
    procedure bDeleteClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure lvClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure mPopupClick(Sender: TObject);
  private
    Events: TEventColl;
    procedure RefillList;
    procedure UpdateButtons;
    procedure SetData;
  public
  end;

function SetupEvents: Boolean;

implementation uses EvtEdit, xBase, LngTools, MlrThr;

{$R *.DFM}

function SetupEvents: Boolean;
var
  EventsForm: TEventsForm;
begin
  EventsForm := TEventsForm.Create(Application);
  EventsForm.SetData;
  Result := EventsForm.ShowModal = mrOK;
  RecalcEvents := Result;
  FreeObject(EventsForm);
  if RecalcEvents then SetEvt(oRecalcEvents);
end;

procedure TEventsForm.SetData;
begin
  Cfg.Events.AppendTo(Events);
  RefillList;
end;

procedure TEventsForm.bNewClick(Sender: TObject);
var
  e: TEventContainer;
begin
  e := TEventContainer.Create;
  if not EditEvent(e) then FreeObject(e) else
  begin
    e.Id := Events.GetUnusedId;
    Events.Insert(e);
    RefillList;
    if Events.Count = 1 then DisplayInfoLng(rsLinkEvt, Handle);
  end;
end;

procedure TEventsForm.bEditClick(Sender: TObject);
var
  oe, ne: TEventContainer;
  i: Integer;
begin
  if not bEdit.Enabled then Exit;
  i := lv.ItemFocused.Index;
  oe := Events[i];
  ne := Pointer(oe.Copy);
  if not EditEvent(ne) then FreeObject(ne) else
  begin
    Events[i] := ne;
    FreeObject(oe);
    RefillList;
  end;
end;

procedure TEventsForm.bCopyClick(Sender: TObject);
var
  e: TEventContainer;
begin
  e := TAdvCpObject(Events[lv.ItemFocused.Index]).Copy;
  e.Id := Events.GetUnusedId;
  Events.Insert(e);
  RefillList;
end;

procedure TEventsForm.bDeleteClick(Sender: TObject);
begin
  Events.AtFree(lv.ItemFocused.Index);
  RefillList;
end;

procedure TEventsForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsEventsForm);
  Events := TEventColl.Create;
end;

procedure TEventsForm.FormDestroy(Sender: TObject);
begin
  FreeObject(Events);
end;

procedure TEventsForm.RefillList;
var
  i: Integer;
  e: TEventContainer;
begin
  lv.Items.Clear;
  for i := 0 to Events.Count-1 do
  begin
    e := Events[i];
    with lv.Items.Add do
    begin
      Caption := e.FName;
      SubItems.Add(e.Cron);
      SubItems.Add(EvtLenDesc(e.Len, e.Permanent));
      SubItems.Add(IntToStr(e.Atoms.Count));
    end;
  end;
  UpdateButtons;
end;


procedure TEventsForm.UpdateButtons;
var
  e: Boolean;
begin
  e := lv.ItemFocused <> nil;
  bEdit.Enabled := e;
  bCopy.Enabled := e;
  bDelete.Enabled := e; 
end;

procedure TEventsForm.lvChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  UpdateButtons;
end;

procedure TEventsForm.lvClick(Sender: TObject);
begin
  UpdateButtons;
end;

procedure TEventsForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  CfgEnter;
  XChg(Integer(Cfg.Events),Integer(Events)); 
  CfgLeave;
  StoreConfig(Handle);
end;

procedure TEventsForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TEventsForm.mPopupClick(Sender: TObject);
var
  p: TPoint;
  li: TListItem;
begin
  li := lv.Selected;
  if li = nil then begin p.x := 0; p.y := 0 end else p := li.Position;
  p := lv.ClientToScreen(p);
  PopupMenu.Popup(p.x+16, p.y+20);  
end;

end.
