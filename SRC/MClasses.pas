{$H+}
unit MClasses;

{$I DEFINE.INC}


interface uses Consts, SysUtils, Windows, Messages, StdCtrls, ExtCtrls, Forms, xBase, Controls, Classes, Graphics, Menus, ShellAPI, xOutline, ImgList, Buttons, NTdyn;


type
  TTrayIcon = class(TComponent)
  private
    {Properties}
    fActive:Boolean;
    fHint:String;
    fIcon:TIcon;
    fPopupMenu:TPopupMenu;
    fSeparateIcon:Boolean;

    {events}
    fOnClick:TNotifyEvent;
    fOnDblClick:TNotifyEvent;
    fOnRightClick:TMouseEvent;
    fOnMinimize:TNotifyEvent;
    fOnRestore:TNotifyEvent;

    {Internal variables}
    fData:TNotifyIconData;
    fWindowHandle:hwnd;
    fMinimized:Boolean;

  protected
    procedure SetActive(Value:Boolean);
    procedure SetHint(Value:String);
    procedure SetIcon(Icon:TIcon);
    procedure SetSeparateIcon(Value:Boolean);

    procedure RemoveIconFromTray;
    procedure UpdateTrayIcon;
    procedure WndProc(var Msg:TMessage);
    procedure HandleRightClick(Sender:TObject);
    procedure HandleMinimize(Sender:TObject);
    procedure HandleRestore(Sender:TObject);

  public
    fNoTrayIcon:Boolean;
    procedure AddIconToTray;
    constructor Create(Owner:TComponent); override;
    destructor Destroy; override;
    procedure DoRightClick(Sender: TObject);

  published
    property Minimized: Boolean read fMinimized;
    property Active:Boolean read fActive write SetActive;
    property Hint:string read fHint write SetHint;
    property Icon:TIcon read fIcon write SetIcon;
    property PopupMenu:TPopupmenu read fPopupMenu write fPopupMenu;
    property SeparateIcon:Boolean read fSeparateIcon write SetSeparateIcon;

    property OnClick:TNotifyEvent read fOnClick write fOnClick;
    property OnDblClick:TNotifyEvent read fOnDblClick write fOnDblClick;
    property OnRightClick:TMouseEvent read fOnRightClick write fOnRightClick;
    property OnMinimize:TNotifyEvent read fOnMinimize write fOnMinimize;
    property OnRestore:TNotifyEvent read fOnRestore write fOnRestore;
  end;


     THistoryLine = class(TCustomComboBox)
     private
       { Private declarations }
       pvHistoryID: Word;
       procedure WMCreate(var Msg: TWMCreate); message WM_Create;
       procedure WMDestroy(var Msg: TWMDestroy); message WM_Destroy;
     protected
       { Protected declarations }
     public
       { Public declarations }
       property Items;
     published
       property HistoryID: Word read pvHistoryID write pvHistoryID default 0;
       property Color;
       property Ctl3D;
       property DragMode;
       property DragCursor;
       property Enabled;
       property Font;
       property MaxLength;
       property ParentColor;
       property ParentCtl3D;
       property ParentFont;
       property ParentShowHint;
       property ShowHint;
       property TabOrder;
       property TabStop;
       property Text;
       property Visible;
       property OnChange;
       property OnClick;
       property OnDblClick;
       property OnDragDrop;
       property OnDragOver;
       property OnDropDown;
       property OnEndDrag;
       property OnEnter;
       property OnExit;
       property OnKeyDown;
       property OnKeyPress;
       property OnKeyUp;
       { Published declarations }
     end;

      THistoryItem = class(TAdvObject)
        Marked: Boolean;
        S: string;
        constructor Create(const Str: String);
        constructor Load(Stream: TxStream); override;
        procedure Store(Stream: TxStream); override;
      end;

      THistoryColl = class(TColl)
      end;

      THistoryID = class(TColl)
        ID: Word;
        constructor Create(AnID: Word);
        procedure AddStr(const S: String);
        function GetStr(Idx: Integer): String;
        constructor Load(Stream: TxStream); override;
        procedure Store(Stream: TxStream); override;
      end;

      TModemLampKind = (mlkRed, mlkGreen, mlkBlue);

      TModemLamp = class(TGraphicControl)
      private
        FKind: TModemLampKind;
        FLit: Boolean;
        procedure SetLit(Value: Boolean);
        procedure SetKind(Value: TModemLampKind);
      published
        property Kind: TModemLampKind read FKind write SetKind default mlkGreen;
        property Lit: Boolean read FLit write SetLit default False;
        property Width default 8;
        property Height default 8;
      public
        constructor Create(AOwner: TComponent); override;
        procedure Paint; override;
      end;

      TTermData = class
      private
        FCharsX, FCharsY,
        CurX, CurY,
        FWidth, FHeight: Integer;
        PrevCR: Boolean;
        Image: TBitmap;
        function Scroll: TRect;
      public
        function Volume: Integer;
        function Clear: TRect;
        function PutChar(C: Char; AHL: Boolean; ACrLf: Boolean): TRect;
        constructor Create(W, H: Integer);
        destructor Destroy; override;
      end;

      TMicroTerm = class(TCustomControl)
      public
        Data: TTermData;
        constructor Create(AOwner: TComponent); override;
        procedure CreateParams(var Params: TCreateParams); override;
        procedure WndProc(var M: TMessage); override;
      end;




      TxGaugeKind = (gkText, gkHorizontalBar, gkVerticalBar, gkPie, gkNeedle);

      TxGauge = class(TGraphicControl)
      private
        FMinValue: Integer;
        FMaxValue: Integer;
        FCurValue: Integer;
        FKind: TxGaugeKind;
        FShowText: Boolean;
        FShowSize: Boolean;
        FBorderStyle: TBorderStyle;
        FForeColor: TColor;
        FBackColor: TColor;
        procedure PaintBackground(AnImage: TBitmap);
        procedure PaintAsText(AnImage: TBitmap; PaintRect: TRect);
        procedure PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
        procedure PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
        procedure PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
        procedure PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
        procedure SeTxGaugeKind(Value: TxGaugeKind);
        procedure SetShowText(Value: Boolean);
        procedure SetShowSize(Value: Boolean);
        procedure SetBorderStyle(Value: TBorderStyle);
        procedure SetForeColor(Value: TColor);
        procedure SetBackColor(Value: TColor);
        procedure SetMinValue(Value: Integer);
        procedure SetMaxValue(Value: Integer);
        procedure SetProgress(Value: Integer);
        function GetPercentDone: Integer;
      protected
        procedure Paint; override;
      public
        constructor Create(AOwner: TComponent); override;
        procedure AddProgress(Value: Integer);
        property PercentDone: Integer read GetPercentDone;
      published
        property Align;
        property Color;
        property Enabled;
        property Kind: TxGaugeKind read FKind write SeTxGaugeKind default gkHorizontalBar;
        property ShowText: Boolean read FShowText write SetShowText default True;
        property ShowSize: Boolean read FShowSize write SetShowSize default True;
        property Font;
        property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
        property ForeColor: TColor read FForeColor write SetForeColor default clBlack;
        property BackColor: TColor read FBackColor write SetBackColor default clWhite;
        property MinValue: Integer read FMinValue write SetMinValue default 0;
        property MaxValue: Integer read FMaxValue write SetMaxValue default 100;
        property ParentColor;
        property ParentFont;
        property ParentShowHint;
        property PopupMenu;
        property Progress: Integer read FCurValue write SetProgress;
        property ShowHint;
        property Visible;
      end;


const
  InitRepeatPause = 400;  { pause before repeat timer (ms) }
  RepeatPause     = 100;  { pause before hint window displays (ms)}

type

  TTimerSpeedButton = class;

{ TxSpinButton }

  TxSpinButton = class (TWinControl)
  private
    FUpButton: TTimerSpeedButton;
    FDownButton: TTimerSpeedButton;
    FFocusedButton: TTimerSpeedButton;
    FFocusControl: TWinControl;
    FOnUpClick: TNotifyEvent;
    FOnDownClick: TNotifyEvent;
    function CreateButton: TTimerSpeedButton;
    function GetUpGlyph: TBitmap;
    function GetDownGlyph: TBitmap;
    procedure SetUpGlyph(Value: TBitmap);
    procedure SetDownGlyph(Value: TBitmap);
    procedure BtnClick(Sender: TObject);
    procedure BtnMouseDown (Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetFocusBtn (Btn: TTimerSpeedButton);
    procedure DoAdjustSize (var W: Integer; var H: Integer);
    procedure WMSize(var Msg: TWMSize);  message WM_SIZE;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
  protected
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
  published
    property Align;
    property Ctl3D;
    property DownGlyph: TBitmap read GetDownGlyph write SetDownGlyph;
    property DragCursor;
    property DragMode;
    property Enabled;
    property FocusControl: TWinControl read FFocusControl write FFocusControl;
    property ParentCtl3D;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property UpGlyph: TBitmap read GetUpGlyph write SetUpGlyph;
    property Visible;
    property OnDownClick: TNotifyEvent read FOnDownClick write FOnDownClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnUpClick: TNotifyEvent read FOnUpClick write FOnUpClick;
  end;

{ TxSpinEdit }

  TxSpinEdit = class(TCustomEdit)
  private
    FMinValue: LongInt;
    FMaxValue: LongInt;
    FIncrement: LongInt;
    FButton: TxSpinButton;
    FEditorEnabled: Boolean;
    function GetMinHeight: Integer;
    function GetValue: LongInt;
    function CheckValue (NewValue: LongInt): LongInt;
    procedure SetValue (NewValue: LongInt);
    procedure SetEditRect;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure CMEnter(var Msg: TCMGotFocus); message CM_ENTER;
    procedure CMExit(var Msg: TCMExit);   message CM_EXIT;
    procedure WMPaste(var Msg: TWMPaste);   message WM_PASTE;
    procedure WMCut(var Msg: TWMCut);   message WM_CUT;
    procedure WMMouseWheel(var M: TMessage); message WM_MouseWheel;
    procedure MouseWheel(fwKeys, zDelta, xPos, yPos: SmallInt);
  protected
//    procedure GetChildren(Proc: TGetChildProc); override;
    function IsValidChar(Key: Char): Boolean; virtual;
    procedure UpClick (Sender: TObject); virtual;
    procedure DownClick (Sender: TObject); virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Button: TxSpinButton read FButton;
  published
    property AutoSelect;
    property AutoSize;
    property Color;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property EditorEnabled: Boolean read FEditorEnabled write FEditorEnabled default True;
    property Enabled;
    property Font;
    property Increment: LongInt read FIncrement write FIncrement default 1;
    property MaxLength;
    property MaxValue: LongInt read FMaxValue write FMaxValue;
    property MinValue: LongInt read FMinValue write FMinValue;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Value: LongInt read GetValue write SetValue;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

{ TTimerSpeedButton }

  TTimeBtnState = set of (tbFocusRect, tbAllowTimer);

  TTimerSpeedButton = class(TSpeedButton)
  private
    FRepeatTimer: TTimer;
    FTimeBtnState: TTimeBtnState;
    procedure TimerExpired(Sender: TObject);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    destructor Destroy; override;
    property TimeBtnState: TTimeBtnState read FTimeBtnState write FTimeBtnState;
  end;

  TLogger = class(TCustomControl)
  private
    JustChanged,
    AutoScroll: Boolean;
    ScrollData: TScrollData;
    FLines: TStringColl;
    FCharWidth, FCharHeight,
    FCols, FRows,
    FX, FY: Integer;
    b: TBitmap;
    procedure ModifyScrollBar(AScrollBar, AScrollCode, APos: Cardinal);
    procedure WMHScroll(var M: TWMScroll); message WM_HSCROLL;
    procedure WMVScroll(var M: TWMScroll);  message WM_VSCROLL;
    procedure WMSetFocus(var M: TMessage); message WM_SetFocus;
    procedure WMKillFocus(var M: TMessage); message WM_KillFocus;
    procedure WMMouseWheel(var M: TMessage); message WM_MouseWheel;
    procedure SetLines(V: TStringColl);
    function UpdateScrollers: Boolean;
    procedure MouseWheel(fwKeys, zDelta, xPos, yPos: SmallInt);
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
  published
    property Align;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop;
  public
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CalcBounds: Boolean;
    property Lines: TStringColl write SetLines;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure CreateParams(var Params: TCreateParams); override;
  end;

  TNavyGauge = class(TCustomControl)
  public
    PrevCW, PrevCH: DWORD;
    Value: DWORD;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure DoPaint;
//    procedure InvSize;
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
  end;

  TxOutlin = class(TOutLine)
  private
    FOnApiDropFiles: TNotifyEvent;
    procedure WMDropFiles(var Msg: TMessage); message WM_DROPFILES;
  public
    DroppedFiles: TStringColl;
    DropPoint: TPoint;
  published
    property OnApiDropFiles:TNotifyEvent read FOnApiDropFiles write FOnApiDropFiles;
  end;


  TNavyGraph = class(TCustomControl)
  public
    GridStep: Integer;
    Data: array[0..TCPIP_GrDataSz] of Integer;
    PrevCW, PrevCH: DWORD;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Paint; override;
    procedure DoPaint;
//    procedure InvSize;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override; 
  published
    property Align;
  end;

var
    MaxHistorySize: Integer;
    HistoryColl: THistoryColl;

function HistoryCount(ID: Word): Integer;
function HistoryStr(ID, Number: Word): String;
procedure HistoryAdd(ID: Word; const S: String);
procedure DoneMClasses;

procedure Register;

implementation uses FileCtrl;

const CheckWidth  = 14;
      CheckBWidth = 12;

procedure Register;
begin
  RegisterComponents('Argus', [THistoryLine, TModemLamp, TMicroTerm, TxGauge, TxSpinButton, TxSpinEdit, TLogger, TNavyGauge, TNavyGraph, TxOutlin, TNoteBook, TDirectoryListBox, TDriveComboBox]);
end;


{Create the Component}
constructor TTrayIcon.Create(Owner:TComponent);
var Hint:String;
//    OSVerInfo:TOSVersionInfo;
    WindowPlacement:TWindowPlacement;
begin
     {Call inherited create method}
     Inherited Create(Owner);

     {Create the fIcon object, and assign the Application Icon to it}
     fIcon:=TIcon.Create;

     fNoTrayIcon:=True;

     if not (csDesigning in ComponentState)
     then
         {At RunTime *only*, perform the following:}
         begin
              FillChar(fData, SizeOf(fData), 0);

              fWindowHandle:=AllocateHWnd(WndProc);

              fData.cbSize:=SizeOf(fData);
              fData.wnd:=fWindowHandle;
              fData.uID := 0;
              fData.hIcon:=fIcon.Handle;
              fData.uFlags:=NIF_Icon OR NIF_Message;
              fData.uCallbackMessage:=WM_TrayCallBack_Message;

              if fHint = ''
              then
                  Hint:=Application.Title
              else
                  Hint:=fHint;

              if Hint <> ''
              then
                  begin
                       fData.uFlags:=fData.uFlags OR NIF_Tip;
                       StrPLCopy(fData.szTip,Hint,SizeOf(fData.szTip)-1);
                  end;

              Application.OnMinimize:=HandleMinimize;
              Application.OnRestore:=HandleRestore;

              FillChar(WindowPlacement,SizeOf(WindowPlacement),0);
              WindowPlacement.length:=SizeOf(WindowPlacement);
              GetWindowPlacement(Application.Handle,@WindowPlacement);
              if WindowPlacement.showCmd = SW_ShowMinimized
              then
                  fMinimized:=True
              else
                  fMinimized:=False;

              if fActive and fMinimized
              then
                  AddIconToTray;
         end;
end;

{Destroy the Component}
destructor TTrayIcon.Destroy;
begin
  if fActive and (not fNoTrayIcon) then RemoveIconFromTray;
  if not (csDesigning in ComponentState) then DeAllocateHWnd(FWindowHandle);
  fIcon.Free;
  inherited Destroy;
end;

procedure TTrayIcon.SetSeparateIcon(Value:Boolean);
begin
  if fSeparateIcon <> Value then fSeparateIcon:=Value;

  if not (csDesigning in ComponentState) then
    case fSeparateIcon of
      False:if fActive and (NOT fMinimized) then RemoveIconFromTray;
      True:if fActive then AddIconToTray;
    end;
end;

procedure TTrayIcon.SetActive(Value:Boolean);
begin
  if fActive = Value then Exit;
  fActive:=Value;
  if not (csDesigning in ComponentState) then
  begin
    if fActive and (fMinimized xor fSeparateIcon) then
    begin
      if fNoTrayIcon then AddIconToTray;
    end else
    begin
      if not fNoTrayIcon then RemoveIconFromTray;
    end;
  end;
end;

procedure TTrayIcon.SetHint(Value:String);
begin
     if fHint <> Value
     then
         begin
              fHint:=Value;

              if not (csDesigning in ComponentState)
              then
                  begin
                       StrPLCopy(fData.szTip,fHint,SizeOf(fData.szTip)-1);
                       if fHint <> ''
                       then
                           fData.uFlags:=fData.uFlags OR NIF_Tip
                       else
                           fData.uFlags:=fData.uFlags AND NOT NIF_Tip;
                       UpdateTrayIcon;
                  end;
         end;
end;

procedure TTrayIcon.SetIcon(Icon:TIcon);
begin
     if fIcon <> Icon
     then
         begin
              fIcon.Assign(Icon);
              fData.hIcon:=Icon.Handle;
              UpdateTrayIcon;
         end;
end;

procedure TTrayIcon.AddIconToTray;
begin
  if fActive  AND fNoTrayIcon then
  begin
    if Integer(Shell_NotifyIcon(NIM_Add,@fData)) = 0 then
    begin
//      GlobalFail('%s', ['AddIconToTray: Shell_NotifyIcon Error']);
    end else
    begin
      fNoTrayIcon:=False;
    end;
  end;
end;

procedure TTrayIcon.RemoveIconFromTray;
begin
  if Integer(Shell_NotifyIcon(NIM_Delete,@fData)) = 0 then
  begin
//    GlobalFail('%s', ['RemoveIconFromTray: Shell_NotifyIcon Error']);
  end;
  fNoTrayIcon:=True;
end;

procedure TTrayIcon.UpdateTrayIcon;
begin
  if (fActive) AND not (csDesigning in ComponentState) then
  begin
    if Integer(Shell_NotifyIcon(NIM_Modify,@fData)) = 0 then
    begin
//      GlobalFail('%s', ['UpdateTrayIcon: Shell_NotifyIcon Error']);
    end;
  end;
end;

procedure TTrayIcon.WndProc(var Msg:TMessage);
begin
     with Msg
     do
       begin
            if msg = WM_TrayCallBack_Message
            then
                case lParam
                of
                  WM_LButtonDblClk : if Assigned(fOnDblClick) then fOnDblClick(Self);
                  WM_LButtonUp     : if Assigned(fOnClick) then fOnClick(Self);
                  WM_RButtonUp     : HandleRightClick(Self);
                end
            else
                Result:=DefWindowProc(fWindowHandle,Msg,wParam,lParam);
       end;
end;

procedure TTrayIcon.HandleRightClick(Sender: TObject);
begin
  PostMessage(TForm(Owner).Handle, WM_TRAYRC, 0, Integer(Sender));
end;

procedure TTrayIcon.DoRightClick(Sender: TObject);
var CursorPos:TPoint;
begin
     if Assigned(fPopupMenu) AND ((NOT IsWindowVisible(Application.Handle) OR fSeparateIcon))
     then
         begin
            GetCursorPos(CursorPos);
            fPopupMenu.Popup(CursorPos.X,CursorPos.Y);
         end;
     if Assigned(fOnRightClick)
     then
         fOnRightClick(Sender,mbRight,[],CursorPos.X,CursorPos.Y);
end;

procedure TTrayIcon.HandleMinimize(Sender:TObject);
begin
  ApplicationDowned := True;
  if fActive then
  begin
    ShowWindow(Application.Handle,SW_Hide);
    if fNoTrayIcon then AddIconToTray;
  end;
  fMinimized:=True;
  if Assigned(fOnMinimize) then fOnMinimize(Sender);
end;

procedure TTrayIcon.HandleRestore(Sender:TObject);
begin
  if fActive then
  begin
    ShowWindow(Application.Handle,SW_Restore);
    if not fSeparateIcon then RemoveIconFromTray;
  end;
  if Assigned(fOnRestore) then fOnRestore(Sender);
  fMinimized:=False;
  ApplicationDowned := False;
end;


{     --- History & Co ---     }

constructor THistoryItem.Create;
begin
  inherited Create;
  S := Str;
  Marked := False;
end;

constructor THistoryID.Create;
begin
  inherited Create;
  ID := AnID;
end;

procedure THistoryID.AddStr;
  var I: Integer;
      P: THistoryItem;
begin
  if S = '' then Exit;
  I := 0;
  while I < Count do
    begin
      P := At(I);
      if (P <> nil) and (P.S <> '') and (P.S = S) then
        begin
          MoveTo(I, 0);
          Exit;
        end;
      Inc(I);
    end;
  I := Count-1;
  while (I>=0) and (Count >= MaxHistorySize) do
    begin
      P := At(I);
      if P.Marked then Dec(I)
        else begin
               P.S := S;
               MoveTo(I, 0);
               Exit;
             end;
    end;
  AtInsert(0, THistoryItem.Create(S))
end;

function THistoryID.GetStr;
  var P: THistoryItem;
begin
  GetStr := '';
  if (Idx >= 0) and (Idx < Count) then
     begin
       P := At(Idx);
       if (P <> nil) and (P.S <> '') then GetStr := P.S
     end;
end;

function GetHistoryID(ID: Integer; Create: Boolean): THistoryID;
  label 1;

  function DoFind(P: THistoryID): Boolean;
  begin
    DoFind := (P <> nil) and (P.ID = ID);
  end;

var
  i,c: Integer;
  p: THistoryId;
begin
  GetHistoryID := nil;
  if (HistoryColl = nil) then
   begin
     if Create then
      begin
        HistoryColl := THistoryColl.Create;
        Result := THistoryID.Create(ID);
        HistoryColl.Insert(Result);
      end;
     Exit;
   end;
  Result := nil;
  c := HistoryColl.Count-1;
  for i := 0 to c do
  begin
    p := HistoryColl.At(i);
    if DoFind(p) then begin Result := p; Break end;
  end;
  if Result = nil then
    if Create then
    begin
      Result := THistoryID.Create(ID);
      HistoryColl.Insert(Result);
    end;
end;

procedure HistoryAdd(ID: Word; const S: String);
  var HID: THistoryID;
begin
  HID := GetHistoryID(ID, True);
  if HID = nil then Exit;
  HID.AddStr(S);
end;

function HistoryStr(ID, Number: Word): String;
  var HID: THistoryID;
begin
  HistoryStr := '';
  HID := GetHistoryID(ID, False);
  if HID = nil then Exit;
  HistoryStr := HID.GetStr(Number);
end;

function HistoryCount(ID: Word): Integer;
  var HID: THistoryID;
begin
  HistoryCount := 0;
  HID := GetHistoryID(ID, False);
  if HID <> nil then HistoryCount := HID.Count;
end;

procedure THistoryLine.WMCreate;
  var I: Integer;
      S: string;
begin
  inherited;
  for I := 0 to HistoryCount(HistoryID)-1 do
  begin
    S := HistoryStr(HistoryID, I);
    if I = 0 then Text := S;
    Items.Add(S);
  end;
end;

procedure THistoryLine.WMDestroy;
begin
   if (Text <> '') then HistoryAdd(HistoryID, Text);
   inherited;
end;

constructor THistoryId.Load(Stream: TxStream);
begin
  inherited Load(Stream);
  Id := Stream.ReadDword;
end;

procedure THistoryId.Store(Stream: TxStream);
begin
  inherited Store(Stream);
  Stream.WriteDword(Id);
end;

constructor THistoryItem.Load(Stream: TxStream);
begin
  Marked := Stream.ReadBool;
  S := Stream.ReadStr;
end;

procedure THistoryItem.Store(Stream: TxStream);
begin
  Stream.WriteBool(Marked);
  Stream.WriteStr(S);
end;

constructor TModemLamp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  SetBounds(Left, Top, 8, 8);
  FKind := mlkGreen;
  FLit := False;
end;

procedure TModemLamp.SetKind(Value: TModemLampKind);
begin
  if FKind = Value then Exit;
  FKind := Value;
  Invalidate;
end;

procedure TModemLamp.SetLit(Value: Boolean);
begin
  if FLit = Value then Exit;
  FLit := Value;
  Invalidate;
end;

var
  LampsBitmap: TBitmap;

procedure TModemLamp.Paint;
var
  x: Integer;
begin
  if LampsBitmap = nil then
  begin
    LampsBitmap := TBitmap.Create;
    LampsBitmap.LoadFromResourceName(HInstance, 'MODEM_LAMPS');
  end;
  x := Byte(FLit or (csDesigning in ComponentState))*(1+Byte(FKind))*8;
  Canvas.CopyRect(Rect(0, 0, 8, 8), LampsBitmap.Canvas, Rect(x, 0, x+8, 8));
end;


{ --- TTermData --- }

const
  ox = 2;
  oy = 2;
  CharWidth = 8;
  CharHeight = 12;           

var
  WorkBmp: TBitmap;
  BmpChr: array[0..3] of TImageList;

function TTermData.Volume: Integer;
begin
  Result := FCharsX * FCharsY;
end;


function TTermData.PutChar(C: Char; AHL: Boolean; ACrLf: Boolean): TRect;

procedure PutC;
begin
  PrevCR := False;
  Result.Left := ox+CurX*CharWidth;
  Result.Top := oy+CurY*CharHeight;
  Result.Right := Result.Left + CharWidth;
  Result.Bottom := Result.Top + CharHeight;
  BmpChr[(Integer(C) shr 7)+Integer(AHL)*2].Draw(Image.Canvas, Result.Left, Result.Top, (Integer(C) and $7F));
  Inc(CurX); if CurX = FCharsX then begin CurX := 0; Result := Scroll end;
end;


begin
  xBase.Clear(Result, SizeOf(Result));
  if not ACrLf then PutC else
  case C of
    #13:
    begin
      if PrevCR then Exit;
      CurX := 0; Result := Scroll;
      PrevCR := True;
    end;
    #10: ;
    else PutC;
  end;
end;

function TTermData.Clear: TRect;
begin
  Result := Rect(0, 0, Image.Width, Image.Height);
  Image.Canvas.FillRect(Result);
  CurX := 0;
  CurY := 0;
end;

function TTermData.Scroll;
var
  Src, Dst: TRect;
begin
  xBase.Clear(Result, SizeOf(Result));
  if CurY<FCharsY-1 then Inc(CurY) else
  begin
    Src := Rect(ox, oy+CharHeight, ox+FCharsX*CharWidth, oy+FCharsY*CharHeight);
    Dst := Rect(ox, oy, ox+FCharsX*CharWidth, oy+(FCharsY-1)*CharHeight);
    Image.Canvas.CopyRect(Dst, Image.Canvas, Src);
    Dst := Rect(ox, oy+(FCharsY-1)*CharHeight, ox+FCharsX*CharWidth, oy+FCharsY*CharHeight);
    Image.Canvas.FillRect(Dst);
    Result := Rect(0, 0, Image.Width, Image.Height);
  end;
end;

constructor TTermData.Create;
begin
  inherited Create;
  Image := TBitmap.Create;
  Image.Canvas.Brush.Color := clBtnFace;
  if BmpChr[0] = nil then
  begin
    WorkBmp := TBitmap.Create;
    WorkBmp.Width := CharWidth;
    WorkBmp.Height := CharHeight;
    BmpChr[0] := TImageList.CreateSize(CharWidth, CharHeight);
    BmpChr[1] := TImageList.CreateSize(CharWidth, CharHeight);
    BmpChr[2] := TImageList.CreateSize(CharWidth, CharHeight);
    BmpChr[3] := TImageList.CreateSize(CharWidth, CharHeight);
    BmpChr[0].ResourceLoad(rtBitmap, 'TERMINAL_BLACK_A', $C0C0C0);
    BmpChr[1].ResourceLoad(rtBitmap, 'TERMINAL_BLACK_B', $C0C0C0);
    BmpChr[2].ResourceLoad(rtBitmap, 'TERMINAL_BLUE_A', $C0C0C0);
    BmpChr[3].ResourceLoad(rtBitmap, 'TERMINAL_BLUE_B', $C0C0C0);
  end;

  FWidth  := W; Image.Width  := W;
  FHeight := H; Image.Height := H;
  FCharsX := (W - ox*2) div CharWidth;
  FCharsY := (H - oy*2) div CharHeight;

end;

destructor TTermData.Destroy;
begin
  FreeObject(Image);
  inherited Destroy;
end;



{ --- MicroTerm --- }

constructor TMicroTerm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
end;


procedure TMicroTerm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle or WS_EX_CLIENTEDGE;
  end;
end;

procedure TMicroTerm.WndProc(var M: TMessage);

procedure DoPaint;
var
  P: TPaintStruct;
  dc: DWORD;
  R: TRect;
begin
  dc := BeginPaint(Handle, P);
  R := P.rcPaint;
  if (Data <> nil) and (not _EmptyRect(R)) then BitBlt(dc, R.Left, R.Top, R.Right-R.Left, R.Bottom-R.Top, Data.Image.Canvas.Handle, R.Left, R.Top, SRCCOPY);
  EndPaint(Handle, P);
  M.Result := 0;
end;

begin
  if (M.Msg = WM_PAINT) and not (csDesigning in ComponentState) then DoPaint
    else inherited WndProc(M);
end;

type
  TBltBitmap = class(TBitmap)
    procedure MakeLike(ATemplate: TBitmap);
  end;

{ TBltBitmap }

procedure TBltBitmap.MakeLike(ATemplate: TBitmap);
begin
  Width := ATemplate.Width;
  Height := ATemplate.Height;
  Canvas.Brush.Color := clWindowFrame;
  Canvas.Brush.Style := bsSolid;
  Canvas.FillRect(Rect(0, 0, Width, Height));
end;

{ This function solves for x in the equation "x is y% of z". }
function SolveForX(Y, Z: Integer): Integer;
begin
  Result := Trunc( Z * (Y * 0.01) );
end;

{ This function solves for y in the equation "x is y% of z". }
function SolveForY(X, Z: Integer): Integer;
begin
  if Z = 0 then Result := 0 else
  begin
    LowerPrec(X, Z, 9);
    Result := Trunc( (X * 100.0) / Z );
  end;
end;

{ TxGauge }

constructor TxGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csFramed, csOpaque];
  { default values }
  FMinValue := 0;
  FMaxValue := 100;
  FCurValue := 0;
  FKind := gkHorizontalBar;
  FShowText := True;
  FShowSize := True;
  FBorderStyle := bsSingle;
  FForeColor := clBlack;
  FBackColor := clWhite;
  Width := 100;
  Height := 100;
end;

function TxGauge.GetPercentDone: Integer;
begin
  Result := SolveForY(FCurValue - FMinValue, FMaxValue - FMinValue);
end;

procedure TxGauge.Paint;
var
  TheImage: TBitmap;
  OverlayImage: TBltBitmap;
  PaintRect: TRect;
begin
  with Canvas do
  begin
    TheImage := TBitmap.Create;
    try
      TheImage.Height := Height;
      TheImage.Width := Width;
      PaintBackground(TheImage);
      PaintRect := ClientRect;
      if FBorderStyle = bsSingle then _InflateRect(PaintRect, -1, -1);
      OverlayImage := TBltBitmap.Create;
      try
        OverlayImage.MakeLike(TheImage);
        PaintBackground(OverlayImage);
        case FKind of
          gkText: PaintAsNothing(OverlayImage, PaintRect);
          gkHorizontalBar, gkVerticalBar: PaintAsBar(OverlayImage, PaintRect);
          gkPie: PaintAsPie(OverlayImage, PaintRect);
          gkNeedle: PaintAsNeedle(OverlayImage, PaintRect);
        end;
        TheImage.Canvas.CopyMode := cmSrcInvert;
        TheImage.Canvas.Draw(0, 0, OverlayImage);
        TheImage.Canvas.CopyMode := cmSrcCopy;
        if ShowText then PaintAsText(TheImage, PaintRect);
      finally
        OverlayImage.Free;
      end;
      Canvas.CopyMode := cmSrcCopy;
      Canvas.Draw(0, 0, TheImage);
    finally
      TheImage.Destroy;
    end;
  end;
end;

procedure TxGauge.PaintBackground(AnImage: TBitmap);
var
  ARect: TRect;
begin
  with AnImage.Canvas do
  begin
    CopyMode := cmBlackness;
    ARect := Rect(0, 0, Width, Height);
    CopyRect(ARect, Animage.Canvas, ARect);
    CopyMode := cmSrcCopy;
  end;
end;

procedure TxGauge.PaintAsText(AnImage: TBitmap; PaintRect: TRect);
var
  S: string;
  X, Y: Integer;
  OverRect: TBltBitmap;
begin
  OverRect := TBltBitmap.Create;
  try
    OverRect.MakeLike(AnImage);
    PaintBackground(OverRect);
    if FShowSize then S := Int2StrK(MaxValue) else S := Format('%d%%', [PercentDone]);
    with OverRect.Canvas do
    begin
      Brush.Style := bsClear;
      Font := Self.Font;
      Font.Color := clWhite;
      with PaintRect do
      begin
        X := (Right - Left + 1 - TextWidth(S)) div 2;
        Y := (Bottom - Top + 1 - TextHeight(S)) div 2;
      end;
      TextRect(PaintRect, X, Y, S);
    end;
    AnImage.Canvas.CopyMode := cmSrcInvert;
    AnImage.Canvas.Draw(0, 0, OverRect);
  finally
    OverRect.Free;
  end;
end;

procedure TxGauge.PaintAsNothing(AnImage: TBitmap; PaintRect: TRect);
begin
  with AnImage do
  begin
    Canvas.Brush.Color := BackColor;
    Canvas.FillRect(PaintRect);
  end;
end;

procedure TxGauge.PaintAsBar(AnImage: TBitmap; PaintRect: TRect);
var
  FillSize: Integer;
  W, H: Integer;
begin
  W := PaintRect.Right - PaintRect.Left + 1;
  H := PaintRect.Bottom - PaintRect.Top + 1;
  with AnImage.Canvas do
  begin
    Brush.Color := BackColor;
    FillRect(PaintRect);
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Brush.Color := ForeColor;
    case FKind of
      gkHorizontalBar:
        begin
          FillSize := SolveForX(PercentDone, W);
          if FillSize > W then FillSize := W;
          if FillSize > 0 then FillRect(Rect(PaintRect.Left, PaintRect.Top,
            FillSize, H));
        end;
      gkVerticalBar:
        begin
          FillSize := SolveForX(PercentDone, H);
          if FillSize >= H then FillSize := H - 1;
          FillRect(Rect(PaintRect.Left, H - FillSize, W, H));
        end;
    end;
  end;
end;

procedure TxGauge.PaintAsPie(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX, MiddleY: Integer;
  Angle: Double;
  W, H: Integer;
begin
  W := PaintRect.Right - PaintRect.Left;
  H := PaintRect.Bottom - PaintRect.Top;
  if FBorderStyle = bsSingle then
  begin
    Inc(W);
    Inc(H);
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Ellipse(PaintRect.Left, PaintRect.Top, W, H);
    if PercentDone > 0 then
    begin
      Brush.Color := ForeColor;
      MiddleX := W div 2;
      MiddleY := H div 2;
      Angle := (Pi * ((PercentDone / 50) + 0.5));
      Pie(PaintRect.Left, PaintRect.Top, W, H, Round(MiddleX * (1 - Cos(Angle))),
        Round(MiddleY * (1 - Sin(Angle))), MiddleX, 0);
    end;
  end;
end;

procedure TxGauge.PaintAsNeedle(AnImage: TBitmap; PaintRect: TRect);
var
  MiddleX: Integer;
  Angle: Double;
  X, Y, W, H: Integer;
begin
  with PaintRect do
  begin
    X := Left;
    Y := Top;
    W := Right - Left;
    H := Bottom - Top;
    if FBorderStyle = bsSingle then
    begin
      Inc(W);
      Inc(H);
    end;
  end;
  with AnImage.Canvas do
  begin
    Brush.Color := Color;
    FillRect(PaintRect);
    Brush.Color := BackColor;
    Pen.Color := ForeColor;
    Pen.Width := 1;
    Pie(X, Y, W, H * 2 - 1, X + W, PaintRect.Bottom - 1, X, PaintRect.Bottom - 1);
    MoveTo(X, PaintRect.Bottom);
    LineTo(X + W, PaintRect.Bottom);
    if PercentDone > 0 then
    begin
      Pen.Color := ForeColor;
      MiddleX := Width div 2;
      MoveTo(MiddleX, PaintRect.Bottom - 1);
      Angle := (Pi * ((PercentDone / 100)));
      LineTo(Round(MiddleX * (1 - Cos(Angle))), Round((PaintRect.Bottom - 1) *
        (1 - Sin(Angle))));
    end;
  end;
end;

procedure TxGauge.SeTxGaugeKind(Value: TxGaugeKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetShowText(Value: Boolean);
begin
  if Value <> FShowText then
  begin
    FShowText := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetShowSize(Value: Boolean);
begin
  if Value <> FShowSize then
  begin
    FShowSize := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetBorderStyle(Value: TBorderStyle);
begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetForeColor(Value: TColor);
begin
  if Value <> FForeColor then
  begin
    FForeColor := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetBackColor(Value: TColor);
begin
  if Value <> FBackColor then
  begin
    FBackColor := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetMinValue(Value: Integer);
begin
  if Value <> FMinValue then
  begin
    if Value > FMaxValue then
    begin
      GlobalFail('TxGauge InvalidOp SOutOfRange [%d..%d]',[-MaxInt, FMaxValue - 1]);
    end;
    FMinValue := Value;
    if FCurValue < Value then FCurValue := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetMaxValue(Value: Integer);
begin
  if Value <> FMaxValue then
  begin
    if Value < FMinValue then
    begin
      GlobalFail('TxGauge InvalidOp SOutOfRange [%d..%d]',[FMinValue + 1, MaxInt]);
    end;
    FMaxValue := Value;
    if FCurValue > Value then FCurValue := Value;
    Refresh;
  end;
end;

procedure TxGauge.SetProgress(Value: Integer);
var
  TempPercent: Integer;
begin
  TempPercent := GetPercentDone;  { remember where we were }
  if Value < FMinValue then
    Value := FMinValue
  else if Value > FMaxValue then
    Value := FMaxValue;
  if FCurValue <> Value then
  begin
    FCurValue := Value;
    if TempPercent <> GetPercentDone then { only refresh if percentage changed }
      Refresh;
  end;
end;

procedure TxGauge.AddProgress(Value: Integer);
begin
  Progress := FCurValue + Value;
  Refresh;
end;

{ TxSpinButton }

constructor TxSpinButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption] +
    [csFramed, csOpaque];

  FUpButton := CreateButton;
  FDownButton := CreateButton;
  UpGlyph := nil;
  DownGlyph := nil;

  Width := 20;
  Height := 25;
  FFocusedButton := FUpButton;
end;

function TxSpinButton.CreateButton: TTimerSpeedButton;
begin
  Result := TTimerSpeedButton.Create (Self);
  Result.OnClick := BtnClick;
  Result.OnMouseDown := BtnMouseDown;
  Result.Visible := True;
  Result.Enabled := True;
  Result.TimeBtnState := [tbAllowTimer];
  Result.NumGlyphs := 1;
  Result.Parent := Self;
end;

procedure TxSpinButton.DoAdjustSize (var W: Integer; var H: Integer);
begin
  if (FUpButton = nil) or (csLoading in ComponentState) then Exit;
  if W < 15 then W := 15;
  FUpButton.SetBounds (0, 0, W, H div 2);
  FDownButton.SetBounds (0, FUpButton.Height - 1, W, H - FUpButton.Height + 1);
end;

procedure TxSpinButton.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  W, H: Integer;
begin
  W := AWidth;
  H := AHeight;
  DoAdjustSize (W, H);
  inherited SetBounds (ALeft, ATop, W, H);
end;

procedure TxSpinButton.WMSize(var Msg: TWMSize);
var
  W, H: Integer;
begin
  inherited;

  { check for minimum size }
  W := Width;
  H := Height;
  DoAdjustSize (W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds(Left, Top, W, H);
  Msg.Result := 0;
end;

procedure TxSpinButton.WMSetFocus(var Msg: TWMSetFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure TxSpinButton.WMKillFocus(var Msg: TWMKillFocus);
begin
  FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
  FFocusedButton.Invalidate;
end;

procedure TxSpinButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_UP:
      begin
        SetFocusBtn (FUpButton);
        FUpButton.Click;
      end;
    VK_DOWN:
      begin
        SetFocusBtn (FDownButton);
        FDownButton.Click;
      end;
    VK_SPACE:
      FFocusedButton.Click;
  end;
end;

procedure TxSpinButton.BtnMouseDown (Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
  begin
    SetFocusBtn (TTimerSpeedButton (Sender));
    if (FFocusControl <> nil) and FFocusControl.TabStop and
        FFocusControl.CanFocus and (GetFocus <> FFocusControl.Handle) then
      FFocusControl.SetFocus
    else if TabStop and (GetFocus <> Handle) and CanFocus then
      SetFocus;
  end;
end;

procedure TxSpinButton.BtnClick(Sender: TObject);
begin
  if Sender = FUpButton then
  begin
    if Assigned(FOnUpClick) then FOnUpClick(Self);
  end
  else
    if Assigned(FOnDownClick) then FOnDownClick(Self);
end;

procedure TxSpinButton.SetFocusBtn (Btn: TTimerSpeedButton);
begin
  if TabStop and CanFocus and  (Btn <> FFocusedButton) then
  begin
    FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState - [tbFocusRect];
    FFocusedButton := Btn;
    if (GetFocus = Handle) then
    begin
       FFocusedButton.TimeBtnState := FFocusedButton.TimeBtnState + [tbFocusRect];
       Invalidate;
    end;
  end;
end;

procedure TxSpinButton.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  Msg.Result := DLGC_WANTARROWS;
end;

procedure TxSpinButton.Loaded;
var
  W, H: Integer;
begin
  inherited Loaded;
  W := Width;
  H := Height;
  DoAdjustSize (W, H);
  if (W <> Width) or (H <> Height) then
    inherited SetBounds (Left, Top, W, H);
end;

function TxSpinButton.GetUpGlyph: TBitmap;
begin
  Result := FUpButton.Glyph;
end;

procedure TxSpinButton.SetUpGlyph(Value: TBitmap);
begin
  if Value <> nil then
    FUpButton.Glyph := Value
  else
  begin
    FUpButton.Glyph.Handle := LoadBitmap(HInstance, 'SpinUp');
    FUpButton.NumGlyphs := 1;
    FUpButton.Invalidate;
  end;
end;

function TxSpinButton.GetDownGlyph: TBitmap;
begin
  Result := FDownButton.Glyph;
end;

procedure TxSpinButton.SetDownGlyph(Value: TBitmap);
begin
  if Value <> nil then
    FDownButton.Glyph := Value
  else
  begin
    FDownButton.Glyph.Handle := LoadBitmap(HInstance, 'SpinDown');
    FDownButton.NumGlyphs := 1;
    FDownButton.Invalidate;
  end;
end;

{ TxSpinEdit }

constructor TxSpinEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FButton := TxSpinButton.Create (Self);
  FButton.Width := 15;
  FButton.Height := 17;
  FButton.Visible := True;
  FButton.Parent := Self;
  FButton.FocusControl := Self;
  FButton.OnUpClick := UpClick;
  FButton.OnDownClick := DownClick;
  Text := '0';
  ControlStyle := ControlStyle - [csSetCaption];
  FIncrement := 1;
  FEditorEnabled := True;
end;

destructor TxSpinEdit.Destroy;
begin
  FButton := nil;
  inherited Destroy;
end;

procedure TxSpinEdit.WMMouseWheel(var M: TMessage);
begin
  MouseWheel(SmallInt(M.wParam and $FFFF), SmallInt((M.wParam shr 16) and $FFFF), SmallInt(M.lParam and $FFFF), SmallInt((M.lParam shr 16) and $FFFF))
end;

procedure TxSpinEdit.MouseWheel(fwKeys, zDelta, xPos, yPos: SmallInt);
var
  ScrollCode, i, Count, Key: Integer;
  wKey: Word;
begin
  GetWheelCommands(zDelta, ScrollCode, Count);
  case ScrollCode of
    SB_LINEDOWN : Key := VK_DOWN;
    SB_LINEUP   : Key := VK_UP;
    SB_PAGEDOWN : Key := VK_PRIOR;
    SB_PAGEUP   : Key := VK_NEXT;
    else Exit;
  end;
  for i := 1 to Count do begin wKey := Key; KeyDown(wKey, []) end;
end;


procedure TxSpinEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_UP) or (Key = VK_NEXT) then UpClick (Self)
  else if (Key = VK_DOWN) or (Key = VK_PRIOR) then DownClick (Self);
  inherited KeyDown(Key, Shift);
end;

procedure TxSpinEdit.KeyPress(var Key: Char);
begin
  if not IsValidChar(Key) then
  begin
    Key := #0;
    MessageBeep(0)
  end;
  if Key <> #0 then inherited KeyPress(Key);
end;

function TxSpinEdit.IsValidChar(Key: Char): Boolean;
begin
  Result := (Key in [DecimalSeparator, '+', '-', '0'..'9']) or
    ((Key < #32) and (Key <> Chr(VK_RETURN)));
  if not FEditorEnabled and Result and ((Key >= #32) or
      (Key = Char(VK_BACK)) or (Key = Char(VK_DELETE))) then
    Result := False;
end;

procedure TxSpinEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  Params.Style := Params.Style and not WS_BORDER;  }
  Params.Style := Params.Style or ES_MULTILINE or WS_CLIPCHILDREN;
end;

procedure TxSpinEdit.CreateWnd;
begin
  inherited CreateWnd;
  SetEditRect;
end;

procedure TxSpinEdit.SetEditRect;
var
  Loc: TRect;
begin
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));
  Loc.Bottom := ClientHeight + 1;  {+1 is workaround for windows paint bug}
  Loc.Right := ClientWidth - FButton.Width - 2;
  Loc.Top := 0;
  Loc.Left := 0;
  SendMessage(Handle, EM_SETRECTNP, 0, LongInt(@Loc));
  SendMessage(Handle, EM_GETRECT, 0, LongInt(@Loc));  {debug}
end;

procedure TxSpinEdit.WMSize(var Msg: TWMSize);
var
  MinHeight: Integer;
begin
  inherited;
  MinHeight := GetMinHeight;
    { text edit bug: if size to less than minheight, then edit ctrl does
      not display the text }
  if Height < MinHeight then
    Height := MinHeight
  else if FButton <> nil then
  begin
    if NewStyleControls then
      FButton.SetBounds(Width - FButton.Width - 5, 0, FButton.Width, Height - 5)
    else FButton.SetBounds (Width - FButton.Width, 0, FButton.Width, Height);
    SetEditRect;
  end;
end;

function TxSpinEdit.GetMinHeight: Integer;
var
  DC: HDC;
  SaveFont: HFont;
  I: Integer;
  SysMetrics, Metrics: TTextMetric;
begin
  DC := GetDC(0);
  GetTextMetrics(DC, SysMetrics);
  SaveFont := SelectObject(DC, Font.Handle);
  GetTextMetrics(DC, Metrics);
  SelectObject(DC, SaveFont);
  ReleaseDC(0, DC);
  I := SysMetrics.tmHeight;
  if I > Metrics.tmHeight then I := Metrics.tmHeight;
  Result := Metrics.tmHeight + I div 4 + GetSystemMetrics(SM_CYBORDER) * 4 + 2;
end;

procedure TxSpinEdit.UpClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value + FIncrement;
end;

procedure TxSpinEdit.DownClick (Sender: TObject);
begin
  if ReadOnly then MessageBeep(0)
  else Value := Value - FIncrement;
end;

procedure TxSpinEdit.WMPaste(var Msg: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TxSpinEdit.WMCut(var Msg: TWMPaste);
begin
  if not FEditorEnabled or ReadOnly then Exit;
  inherited;
end;

procedure TxSpinEdit.CMExit(var Msg: TCMExit);
begin
  inherited;
  if CheckValue (Value) <> Value then
    SetValue (Value);
end;

function TxSpinEdit.GetValue: LongInt;
begin
  try
    Result := StrToInt (Text);
  except
    Result := FMinValue;
  end;
end;

procedure TxSpinEdit.SetValue (NewValue: LongInt);
begin
  Text := IntToStr (CheckValue (NewValue));
end;

function TxSpinEdit.CheckValue (NewValue: LongInt): LongInt;
begin
  Result := NewValue;
  if (FMaxValue <> FMinValue) then
  begin
    if NewValue < FMinValue then
      Result := FMinValue
    else if NewValue > FMaxValue then
      Result := FMaxValue;
  end;
end;

procedure TxSpinEdit.CMEnter(var Msg: TCMGotFocus);
begin
  if AutoSelect and not (csLButtonDown in ControlState) then
    SelectAll;
  inherited;
end;

{TTimerSpeedButton}

destructor TTimerSpeedButton.Destroy;
begin
  if FRepeatTimer <> nil then
    FRepeatTimer.Free;
  inherited Destroy;
end;

procedure TTimerSpeedButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown (Button, Shift, X, Y);
  if tbAllowTimer in FTimeBtnState then
  begin
    if FRepeatTimer = nil then
      FRepeatTimer := TTimer.Create(Self);

    FRepeatTimer.OnTimer := TimerExpired;
    FRepeatTimer.Interval := InitRepeatPause;
    FRepeatTimer.Enabled  := True;
  end;
end;

procedure TTimerSpeedButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
                                  X, Y: Integer);
begin
  inherited MouseUp (Button, Shift, X, Y);
  if FRepeatTimer <> nil then
    FRepeatTimer.Enabled  := False;
end;

procedure TTimerSpeedButton.TimerExpired(Sender: TObject);
begin
  FRepeatTimer.Interval := RepeatPause;
  if (FState = bsDown) and MouseCapture then
  begin
    try
      Click;
    except
      FRepeatTimer.Enabled := False;
      raise;
    end;
  end;
end;

procedure TTimerSpeedButton.Paint;
var
  R: TRect;
begin
  inherited Paint;
  if tbFocusRect in FTimeBtnState then
  begin
    R := Bounds(0, 0, Width, Height);
    _InflateRect(R, -3, -3);
    if FState = bsDown then _OffsetRect(R, 1, 1);
    DrawFocusRect(Canvas.Handle, R);
  end;
end;

constructor TLogger.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  TabStop := True;
  b := TBitmap.Create;
end;

destructor TLogger.Destroy;
begin
  inherited Destroy;
  FreeObject(b);
end;

procedure TLogger.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if ssCtrl in Shift then
    case Key of
      VK_UP:   ModifyScrollBar(SB_VERT, SB_PAGEUP, 0);
      VK_DOWN: ModifyScrollBar(SB_VERT, SB_PAGEDOWN, 0);
      VK_PRIOR,
      VK_HOME: ModifyScrollBar(SB_VERT, SB_BOTTOM, 0);
      VK_NEXT,
      VK_END: ModifyScrollBar(SB_VERT, SB_TOP, 0);
    end
  else
    case Key of
      VK_UP: ModifyScrollBar(SB_VERT, SB_LINEUP, 0);
      VK_DOWN: ModifyScrollBar(SB_VERT, SB_LINEDOWN, 0);
      VK_NEXT: ModifyScrollBar(SB_VERT, SB_PAGEDOWN, 0);
      VK_PRIOR: ModifyScrollBar(SB_VERT, SB_PAGEUP, 0);
      VK_HOME: ModifyScrollBar(SB_VERT, SB_BOTTOM, 0);
      VK_END: ModifyScrollBar(SB_VERT, SB_TOP, 0);
    end;    
end;

procedure TLogger.WMGetDlgCode(var Msg: TWMGetDlgCode);
begin
  Msg.Result := DLGC_WANTARROWS;
end;


procedure TLogger.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  SetFocus;
end;

procedure TLogger.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;


procedure TLogger.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    Style := Style or WS_VSCROLL or WS_HSCROLL;
  end;
end;

function TLogger.UpdateScrollers: Boolean;
var
  LC,MW,I: Integer;
begin
  if FLines = nil then begin LC := 0; MW := 0 end else
  begin
    LC := FLines.Count;
    MW := 0;
    for I := 0 to FLines.Count-1 do MW := MaxI(MW, Length(FLines[I]));
  end;
  with ScrollData do
  begin
    if AutoScroll then
    begin
      h.rPos := 0;
      v.rPos := MaxI(0, LC - FRows+1);
    end;
    h.rMin  := 0;
    h.rMax  := MW;
    h.rPage := MinI(FCols, h.rMax+1);

    v.rMin  := 0;
    v.rMax  := LC;
    v.rPage := MinI(FRows, v.rMax+1);
  end;
  Result := UpdateScrollBars(ScrollData, Handle);
end;


procedure TLogger.WMSetFocus(var M: TMessage);
begin
  inherited;
  AutoScroll := False;
  Invalidate;
end;

procedure TLogger.WMKillFocus(var M: TMessage);
begin
  inherited;
  AutoScroll := True;
  Invalidate;
end;

procedure TLogger.ModifyScrollBar(AScrollBar, AScrollCode, APos: Cardinal);
var
  D: PScrollRec;
begin
  AutoScroll := False;
  if AScrollBar = SB_HORZ then D := @ScrollData.H else D := @ScrollData.V;
  with D^ do MakeScroll(AScrollCode, APos, AScrollBar, Handle, rMin, rMax, rPage, Integer(rPos));
  UpdateScrollers;
  Invalidate;
end;


procedure TLogger.WMHScroll;
begin
  ModifyScrollBar(SB_HORZ, M.ScrollCode, M.Pos);
end;


procedure TLogger.WMVScroll;
begin
  ModifyScrollBar(SB_VERT, M.ScrollCode, M.Pos);
end;

procedure TLogger.Paint;

procedure GetFont(dc: DWORD);
var
  Extent: TSize;
  C: Char;
begin
  C := ' ';
  if not GetTextExtentPoint32(dc, @C, 1, Extent) then
  begin
    GlobalFail('TLogger GetTextExtentPoint32 Error %d', [GetLastError]);
  end;
  FCharWidth := Extent.cX;
  FCharHeight := Extent.cY;
end;

var
  bh: DWORD;

procedure DoIt;
var
  i, j: Integer;
  s: string;
type
  PPolyTextArray = ^TPolyTextArray;
  TPolyTextArray = array[0..(MaxInt-1) div (SizeOf(TPolyText)+1)] of TPolyText;
var
  PT: TPolyText;
  PTA: PPolyTextArray;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    GetMem(PTA, FRows*SizeOf(TPolyText));
  end else
  begin
    PTA := nil; // to avoid uninitialized warning
  end;
  for i := 0 to FRows-1 do
  begin
    j := i + ScrollData.v.rPos;
    if j >= FLines.Count then s := '' else s := Copy(FLines[j], 1+ScrollData.h.rPos, FCols);
    s := AddRightSpaces(s, FCols);
    if Win32Platform <> VER_PLATFORM_WIN32_NT then
    begin
      Windows.TextOut(bh, 0, i*FCharHeight, PChar(s), Length(s));
    end else
    begin
      PT.x := 0;
      PT.y := i*FCharHeight;
      PT.PAnsiChar := StrNew(PChar(s));
      PT.n := Length(s);
      FillChar(PT.rcl, SizeOf(PT.rcl), 0);
      PT.uiFlags := 0;
      PT.pdx := nil;
      PTA^[i] := PT;
    end;
  end;
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    if not NTdyn_PolyTextOut(bh, PTA^, FRows) then
    begin
      GlobalFail('PolyTextOut Error %d', [GetLastError]);
    end;
    for i := 0 to FRows-1 do
    begin
      StrDispose(PTA^[i].PAnsiChar);
    end;
    FreeMem(pta, FRows*SizeOf(TPolyText));
  end;
end;

begin
  if FLines = nil then Exit;

  FX := ClientWidth;
  FY := ClientHeight;

  if (b.Width <> FX) or (B.Height <> FY) then
  begin
    b.Width := FX;
    b.Height := FY;
    b.Canvas.Font := Font;
    b.Canvas.Brush.Color := clBtnFace;
  end;
  bh := b.Canvas.Handle;
  if FCharWidth = 0 then GetFont(bh);

  if CalcBounds then
  begin
    bh := b.Canvas.Handle;
  end;
  DoIt;
  if Focused then
  begin
    if not Windows.DrawFocusRect(bh, Rect(0,0,FX,FY)) then
    begin
      GlobalFail('TLogger DrawFocusRect Error %d', [GetLastError]);
    end;
  end;

  if not BitBlt(Canvas.Handle, 0, 0, FX, FY, bh, 0, 0, SRCCOPY) then
  begin
    GlobalFail('TLogger BitBlt Error %d', [GetLastError]);
  end;

  if JustChanged then
  begin
    JustChanged := False;
    AutoScroll := not Focused;
  end;
end;

procedure TLogger.MouseWheel(fwKeys, zDelta, xPos, yPos: SmallInt);
var
  ScrollCode, i, Count: Integer;
begin
  GetWheelCommands(zDelta, ScrollCode, Count);
  for i := 1 to Count do ModifyScrollBar(SB_VERT, ScrollCode, 0);
end;

procedure TLogger.WMMouseWheel(var M: TMessage);
begin
  MouseWheel(SmallInt(M.wParam and $FFFF), SmallInt((M.wParam shr 16) and $FFFF), SmallInt(M.lParam and $FFFF), SmallInt((M.lParam shr 16) and $FFFF))
end;


function TLogger.CalcBounds: Boolean;
begin
  Result := False;
  if FCharWidth = 0 then Exit;
  FCols := (FX+FCharWidth-1) div FCharWidth;
  FRows := (FY+FCharHeight-1) div FCharHeight;
  Result := UpdateScrollers;
end;

procedure TLogger.SetLines(V: TStringColl);
begin
  if FLines = V then Exit;
  FLines := V;
  AutoScroll := True;
  JustChanged := True;
  Invalidate;
end;

procedure TNavyGauge.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle or WS_EX_CLIENTEDGE;
  end;
end;


var
  GaugeCache, GaugeA, GaugeB, Digits: TBitmap;


procedure LoadGauge;
begin
  if GaugeA <> nil then Exit;
  GaugeA := TBitmap.Create;
  GaugeB := TBitmap.Create;
  Digits := TBitmap.Create;
//  GaugeCache := TBitmap.Create;
  GaugeA.LoadFromResourceName(HInstance, 'GAUGE_A');
  GaugeB.LoadFromResourceName(HInstance, 'GAUGE_B');
  Digits.LoadFromResourceName(HInstance, 'DIGITS');
end;

function MagicString(j: DWORD): string;
begin
  case j of
    0..999:
      Result := IntToStr(j)+'<';
    1000..999999:
      Result := IntToStr(j div 1000)+';';
    1000000..High(j):
      Result := IntToStr(j div 1000000)+':';
  end;
  while Length(Result)<4 do Result := '<'+Result;
end;

function MagicFormula(j: DWORD): DWORD;
begin
  Result := Round(Ln(j/10+1)*6);
end;

procedure TNavyGauge.DoPaint;
const
  yo = 6;
  cLevelHeight = 3;
  wd = 8;
  ds = 6;
  nd = 4;

var
  cNumLevels: DWORD;
  i, de, dh, xp, xo, l, v, bw: DWORD;
  s: string;

procedure PutDigit(DigitIdx, Pos: DWORD);
begin
  if DigitIdx = 12 then Exit;
  BitBlt(GaugeCache.Canvas.Handle, xp+Pos*wd, de+l+ds, wd, dh, Digits.Canvas.Handle, DigitIdx*wd, 0, SRCCOPY);
end;

begin
  dh := Digits.Height;
  cNumLevels := (PrevCH-yo-dh-ds-4) div 3;
  v := cNumLevels-MinD(MagicFormula(Value) div 6, cNumLevels);
  bw := GaugeA.Width;
  xo := (PrevCW-bw) div 2;
  xp := (PrevCW-wd*nd) div 2;
  Windows.FillRect(GaugeCache.Canvas.Handle, Rect(0, 0, PrevCW, PrevCH), COLOR_3DDKSHADOW+1);
  BitBlt(GaugeCache.Canvas.Handle, xo, yo, bw, v*cLevelHeight, GaugeA.Canvas.Handle, 0, 0, SRCCOPY);
  l := (cNumLevels-v)*cLevelHeight;
  de := yo+v*cLevelHeight;
  if l > 0 then
  BitBlt(GaugeCache.Canvas.Handle, xo, de, bw, l, GaugeB.Canvas.Handle, 0, 0, SRCCOPY);
  s := MagicString(Value div TCPIP_Round);
  for i := Length(s) downto 1 do
  begin
    PutDigit(Ord(s[i])-Ord('0'), i-1);
  end;
  BitBlt(Canvas.Handle, 0, 0, PrevCW, PrevCH, GaugeCache.Canvas.Handle, 0, 0, SRCCOPY);
end;

{procedure TNavyGauge.InvSize;
var
  r: TRect;
begin
  r := GetClientRect;
  if (r.Right <> PrevCW) or
     (r.Bottom <> PrevCH) then
  begin
    PrevCW := r.Right;
    PrevCH := r.Bottom;
    GaugeCache.Width := PrevCW;
    GaugeCache.Height := PrevCH;
  end;
end;}

procedure SetCacheSize(const R: TRect; var PrevCW, PrevCH: DWORD);
begin
  if GaugeCache = nil then GaugeCache := TBitmap.Create;
  PrevCW := R.Right;
  PrevCH := R.Bottom;
  if GaugeCache.Width < Integer(PrevCW) then GaugeCache.Width := Integer(PrevCW);
  if GaugeCache.Height < Integer(PrevCH) then GaugeCache.Height := Integer(PrevCH);
end;


procedure TNavyGauge.Paint;
begin
  if csDesigning in ComponentState then Exit;
  LoadGauge;
  SetCacheSize(GetClientRect, PrevCW, PrevCH);
  DoPaint;
end;

constructor TNavyGauge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
end;

destructor TNavyGraph.Destroy;
begin
  inherited Destroy;
end;


procedure TNavyGraph.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    ExStyle := ExStyle or WS_EX_CLIENTEDGE;
  end;
end;

procedure TNavyGraph.Paint;
begin
  if csDesigning in ComponentState then Exit;
  LoadGauge;
  SetCacheSize(GetClientRect, PrevCW, PrevCH);
  DoPaint;
end;

type
  TPointArray = array[0..(MaxInt) div SizeOf(TPoint) div 2] of TPoint;
  PPointArray = ^TPointArray;

var
  ngPoints: PPointArray;
  ngPointsNum: Integer;
  ngSizes: PIntArray;
  ngSizesNum: Integer;
  ngCurPoints, ngPointsIdx, ngSizesIdx: Integer;


procedure AddPoint(P: TPoint);
const
  IncStep = 32;
begin
  if ngPointsNum = ngPointsIdx then
  begin
    Inc(ngPointsNum, IncStep);
    ReallocMem(ngPoints, ngPointsNum*SizeOf(TPoint));
  end;
  ngPoints^[ngPointsIdx] := P;
  Inc(ngPointsIdx);
  Inc(ngCurPoints);
end;

procedure EndPoly;
const
  IncStep = 32;
begin
  if ngSizesNum = ngSizesIdx then
  begin
    Inc(ngSizesNum, IncStep);
    ReallocMem(ngSizes, ngSizesNum*SizeOf(Integer));
  end;
  ngSizes^[ngSizesIdx] := ngCurPoints; ngCurPoints := 0;
  Inc(ngSizesIdx);
end;

procedure EndPolies(HDC: DWORD);
begin
  PolyPolyLine(HDC, ngPoints^, ngSizes^, ngSizesIdx);
  ngPointsIdx := 0;
  ngSizesIdx := 0;
end;

procedure TNavyGraph.DoPaint;
const
  gcell = 12;
var
  k: DWORD;
  i, j: Integer;
begin 
  Windows.FillRect(GaugeCache.Canvas.Handle, Rect(0, 0, PrevCW, PrevCH), COLOR_3DDKSHADOW+1);
  GaugeCache.Canvas.Pen.Color := clGreen;
// vertical lines
  i := (gcell - 1) - (GridStep mod gcell);
  while i < Integer(PrevCW) do begin AddPoint(Point(i, 0)); AddPoint(Point(i, PrevCH)); EndPoly; Inc(i, gcell);  end;
// horizontal lines
  i := PrevCH;
  while i > 0 do begin Dec(i, gcell); AddPoint(Point(0, i)); AddPoint(Point(PrevCW, i)); EndPoly end;
  EndPolies(GaugeCache.Canvas.Handle);
  GaugeCache.Canvas.Pen.Color := $00FF00;
  k := TCPIP_GrDataSz - PrevCW;
  if PrevCW > 0 then
  for i := 0 to PrevCW-1 do
  begin
    j := Data[k]; Inc(k);
    if j= -1 then Continue;
    AddPoint(Point(i, PrevCH-2-MinD(MagicFormula(j),PrevCH-3)));
  end;
  EndPoly;
  EndPolies(GaugeCache.Canvas.Handle);
  BitBlt(Canvas.Handle, 0, 0, PrevCW, PrevCH, GaugeCache.Canvas.Handle, 0, 0, SRCCOPY);
end;

constructor TNavyGraph.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
end;

procedure TxOutlin.WMDropFiles(var Msg: TMessage);
begin
  DragQueryPoint(Msg.wParam, DropPoint);
  DroppedFiles := GetAPIDroppedFiles(Msg.wParam);
  OnApiDropFiles(Self);
  Msg.Result := 0;
end;


procedure DoneMClasses;
begin
  ReallocMem(ngSizes, 0);
  ReallocMem(ngPoints, 0);
  FreeObject(LampsBitmap);
  FreeObject(WorkBmp);
  FreeObject(BmpChr[0]);
  FreeObject(BmpChr[1]);
  FreeObject(BmpChr[2]);
  FreeObject(BmpChr[3]);
  FreeObject(GaugeA);
  FreeObject(GaugeB);
  FreeObject(Digits);
  FreeObject(GaugeCache);
end;

initialization
  MaxHistorySize := 30;
  HistoryColl := nil;
end.

