unit EncLinks;

interface

uses
  Forms, xFido, StdCtrls, Classes, Controls, Menus;

type
  TEncryptedLinksForm = class(TForm)
    lb: TListBox;
    bAdd: TButton;
    bRemove: TButton;
    bChange: TButton;
    bClose: TButton;
    bHelp: TButton;
    bSort: TButton;
    Popup: TPopupMenu;
    mAdd: TMenuItem;
    mChange: TMenuItem;
    mRemove: TMenuItem;
    mSort: TMenuItem;
    mPopup: TMenuItem;
    procedure bAddClick(Sender: TObject);
    procedure bChangeClick(Sender: TObject);
    procedure bRemoveClick(Sender: TObject);
    procedure bSortClick(Sender: TObject);
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure mPopupClick(Sender: TObject);
  private
    procedure RefillNodes;
    procedure AddLink;
    procedure ChangeLink(A: TFidoAddress);
  public
  end;

function SetupEncryptedLinks: Boolean;


implementation uses xBase, xDES, Recs, AdrIBox, PwdInput, LngTools, SysUtils, Windows;

{$R *.DFM}

function SetupEncryptedLinks: Boolean;
var
  EncryptedLinksForm: TEncryptedLinksForm;
begin
  EncryptedLinksForm := TEncryptedLinksForm.Create(Application);
  EncryptedLinksForm.RefillNodes;
  EncryptedLinksForm.ShowModal;
  FreeObject(EncryptedLinksForm);
  Result := True;
end;

procedure TEncryptedLinksForm.RefillNodes;
var
  cc: Integer;
  C: TFidoAddrColl;
  oi, i: Integer;
  N: TEncryptedNodeData;
  B: Boolean;
begin
  C := TFidoAddrColl.Create;
  CfgEnter;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    N := Cfg.EncryptedNodes[i];
    C.Add(N.Addr);
  end;
  CfgLeave;
  oi := lb.ItemIndex;
//  if oi < 0 then Exit; //GlobalFail('TEncryptedLinksForm.RefillNodes, oi = %d', [oi]);
  lb.Items.Clear;
  cc := C.Count-1;
  for i := 0 to cc do
  begin
    lb.Items.Add(Addr2Str(C[i]));
  end;
  FreeObject(C);
  B := cc >= 0;
  if B then lb.ItemIndex := MinI(MaxI(0, oi), cc);
  bChange.Enabled := B;
  bRemove.Enabled := B;
  B := B and (cc > 0);
  bSort.Enabled := B;
end;

procedure TEncryptedLinksForm.ChangeLink(A: TFidoAddress);
var
  Key: TDesBlock;
  i: Integer;
  en: TEncryptedNodeData;
begin
  if not InputNewPwd(Key, FormatLng(rsElChPwd, [Addr2Str(a)]), True, IDH_BINKPENC) then Exit;
  CfgEnter;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    en := Cfg.EncryptedNodes[i];
    if CompareAddrs(A, en.Addr) = 0 then
    begin
      en.Key := Key;
      Break;
    end;
  end;
  CfgLeave;
  if not StoreConfig(Handle) then PostCloseMessage;
end;

procedure TEncryptedLinksForm.AddLink;
var
  AA: TFidoAddress;
  i: Integer;
  en: TEncryptedNodeData;
  Duplicate: Boolean;
  s: string;
begin
  if not InputSingleAddress(LngStr(rsElNewL), AA, nil) then Exit;
  CfgEnter;
  Duplicate := False;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    en := Cfg.EncryptedNodes[i];
    if CompareAddrs(AA, en.Addr) = 0 then
    begin
      Duplicate := True;
      Break;
    end;
  end;
  CfgLeave;
  s := Addr2Str(AA);
  if Duplicate then
  begin
    if WinDlg(FormatLng(rsElAlr, [s, s]), MB_YESNO or MB_ICONWARNING, Handle) = idYes then ChangeLink(AA);
    Exit;
  end;
  en := TEncryptedNodeData.Create;
  en.Addr := AA;
  if not InputNewPwd(en.Key, FormatLng(rsElSetUp, [s]), True, IDH_BINKPENC) then FreeObject(en) else
  begin
    CfgEnter;
    Cfg.EncryptedNodes.Insert(en);
    CfgLeave;
    if StoreConfig(Handle) then RefillNodes else PostCloseMessage;
  end;
end;



procedure TEncryptedLinksForm.bAddClick(Sender: TObject);
begin
  AddLink;
end;

procedure TEncryptedLinksForm.bChangeClick(Sender: TObject);
var
  i: Integer;
  A: TFidoAddress;
begin
  i := lb.ItemIndex;
  if i = -1 then Exit;
  if not ParseAddress(lb.Items[i], A) then Exit;
  ChangeLink(A);
end;

procedure TEncryptedLinksForm.bRemoveClick(Sender: TObject);
var
  i: Integer;
  A: TFidoAddress;
  en: TEncryptedNodeData;
begin
  i := lb.ItemIndex;
  if i = -1 then Exit;
  if not ParseAddress(lb.Items[i], A) then Exit;
  if not YesNoConfirm(FormatLng(rsElCfmRemove, [Addr2Str(A)]), Handle) then Exit;
  CfgEnter;
  for i := 0 to Cfg.EncryptedNodes.Count-1 do
  begin
    en := Cfg.EncryptedNodes[i];
    if CompareAddrs(A, en.Addr) = 0 then
    begin
      Cfg.EncryptedNodes.AtFree(i);
      Break;
    end;
  end;
  CfgLeave;
  if StoreConfig(Handle) then RefillNodes else PostCloseMessage;
end;

procedure TEncryptedLinksForm.bSortClick(Sender: TObject);
begin
  CfgEnter;
  Cfg.EncryptedNodes.Sort(EncNodeSort);
  CfgLeave;
  if StoreConfig(Handle) then RefillNodes else PostCloseMessage;
end;

procedure TEncryptedLinksForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TEncryptedLinksForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsEncryptedLinksForm);
end;

procedure TEncryptedLinksForm.mPopupClick(Sender: TObject);
var
  p: TPoint;
begin
  p := lb.ClientToScreen(Point(16, (lb.ItemIndex+1)*lb.ItemHeight+4));
  Popup.Popup(p.x, p.y);
end;

end.

