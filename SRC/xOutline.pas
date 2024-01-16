
{*******************************************************}
{                                                       }
{       Delphi Visual Component Library                 }
{                                                       }
{       Copyright (c) 1995,97 Borland International     }
{                                                       }
{*******************************************************}

unit xOutline;

{$R-}

interface


uses Windows, Messages, Forms, Classes, Graphics, Menus, StdCtrls, MGrids,
  Controls, SysUtils;

type
  OutlineError = class(TObject); { Raised by GetNodeAtIndex }
  EOutlineError = class(Exception);
  TOutlineNodeCompare = (ocLess, ocSame, ocGreater, ocInvalid);
  TAttachMode = (oaAdd, oaAddChild, oaInsert);
  TChangeRange = -1..1;
  TCustomOutline = class;

{ TOutlineNode }

{ The TOutlineNode is an encapsulation of an outliner item.  Access
  to a TOutlineNode is via the container class TOutline.  Each
  TOutlineNode contains user defined text and data.
  An item is also capable of containing up to 16368 sub-items.
  TOutlineNodes are also persistent.

  A TOutlineNode item can be interrogated about its current state :
    Expanded
      Whether the node is open or closed.
    Index
      The current Index of the node.  This changes as items are inserted and
      deleted.  The index will range from 1..n
    Level
      The current depth of the node with 1 being the top level
    HasItems
      Whether the item contains items
    IsVisible
      Whether the item is capable of being displayed. This value is only
      True if all its parent items are visible
    TopItem
      Obtains the parent of the item that resides at level 1
    FullPath
      Returns the fully qualified name of the item starting from its
      level 1 parent.  Each item is separated by the separator string
      specified in the TOutline Container
    Text
      Used to set and get the items text value
    Data
      Used to get and set the items data }

  TOutlineNode = class(TPersistent)
  private
    FList: TList;
    FText: string;
    FData: Pointer;
    FParent: TOutlineNode;
    FIndex: LongInt;
    FState: Boolean;
    FOutline: TCustomOutline;
    FExpandCount: LongInt;
    procedure ChangeExpandedCount(Value: LongInt);
    procedure CloseNode;
    procedure Clear;
    procedure Error(const ErrorString: string);
    function GetExpandedNodeCount: LongInt;
    function GetFullPath: string;
    function GetIndex: LongInt;
    function GetLastIndex: LongInt;
    function GetLevel: Cardinal;
    function GetList: TList;
    function GetMaxDisplayWidth(Value: Cardinal): Cardinal;
    function GetNode(Index: LongInt): TOutlineNode;
    function GetTopItem: Longint;
    function GetVisibleParent: TOutlineNode;
    function HasChildren: Boolean;
    function HasVisibleParent: Boolean;
    function IsEqual(Value: TOutlineNode): Boolean;
    procedure ReIndex(StartNode, EndNode: TOutlineNode; NewIndex: LongInt;
      IncludeStart: Boolean);
    procedure Repaint;
    function Resync(var NewIndex: LongInt; EndNode: TOutlineNode): Boolean;
    procedure SetExpandedState(Value: Boolean);
    procedure SetGoodIndex;
    procedure SetHorzScrollBar;
    procedure SetLevel(Level: Cardinal);
    procedure SetText(const Value: string);
  protected
    constructor Create(AOwner: TCustomOutline);
    function GetVisibleNode(TargetCount: LongInt): TOutlineNode;
    function AddNode(Value: TOutlineNode): LongInt;
    function InsertNode(Index: LongInt; Value: TOutlineNode): LongInt;
    function GetNodeAtIndex(TargetIndex: LongInt): TOutlineNode;
    function GetDataItem(Value: Pointer): LongInt;
    function GetTextItem(const Value: string): LongInt;
    function HasAsParent(Value: TOutlineNode): Boolean;
    function GetRowOfNode(TargetNode: TOutlineNode;
      var RowCount: Longint): Boolean;
    procedure InternalRemove(Value: TOutlineNode; Index: Integer);
    procedure Remove(Value: TOutlineNode);
    procedure WriteNode(Buffer: PChar; Stream: TStream);
    property Outline: TCustomOutline read FOutline;
    property List: TList read GetList;
    property ExpandCount: LongInt read FExpandCount;
    property Items[Index: LongInt]: TOutlineNode read GetNode; default;
  public
    destructor Destroy; override;
    procedure ChangeLevelBy(Value: TChangeRange);
    procedure Collapse;
    procedure Expand;
    procedure FullExpand;
    function GetDisplayWidth: Integer;
    function GetFirstChild: LongInt;
    function GetLastChild: LongInt;
    function GetNextChild(Value: LongInt): LongInt;
    function GetPrevChild(Value: LongInt): LongInt;
    procedure MoveTo(Destination: LongInt; AttachMode: TAttachMode);
    property Parent: TOutlineNode read FParent;
    property Expanded: Boolean read FState write SetExpandedState;
    property Text: string read FText write SetText;
    property Data: Pointer read FData write FData;
    property Index: LongInt read GetIndex;
    property Level: Cardinal read GetLevel write SetLevel;
    property HasItems: Boolean read HasChildren;
    property IsVisible: Boolean read HasVisibleParent;
    property TopItem: Longint read GetTopItem;
    property FullPath: string read GetFullPath;
  end;

{ TCustomOutline }

{ The TCustomOutline object is a container class for TOutlineNodes.
  All TOutlineNodes contained within a TOutline are presented
  to the user as a flat array of TOutlineNodes, with a parent
  TOutlineNode containing an index value that is one less than
  its first child (if it has any children).

  Interaction with a TOutlineNode is typically accomplished through
  the TCustomOutline using the following properties:
    CurItem
      Reads and writes the current item
    ItemCount
      Returns the total number of TOutlineNodes with the TCustomOutline.
      Note this can be computationally expensive as all indexes will
      be forced to be updated!!
    Items
      Allows Linear indexing into the hierarchical list of TOutlineNodes
    SelectedItem
      Returns the Index of the TOutlineNode which has the focus or 0 if
      no TOutlineNode has been selected

  The TCustomOutline has a number of properties which will affect all
  TOutlineNodes owned by the TCustomOutline:
    OutlineStyle
      Sets the visual style of the outliner
    ItemSeparator
      Sets the delimiting string for all TOutlineNodes
    PicturePlus, PictureMinus, PictureOpen, PictureClosed, PictureLeaf
      Sets custom bitmaps for these items }

  TBitmapArrayRange = 0..4;
  EOutlineChange = procedure (Sender: TObject; Index: LongInt) of object;
  TOutlineStyle = (osText, osPlusMinusText, osPictureText,
    osPlusMinusPictureText, osTreeText, osTreePictureText);
  TOutlineBitmap = (obPlus, obMinus, obOpen, obClose, obLeaf);
  TOutlineBitmaps = set of TOutlineBitmap;
  TBitmapArray = array[TBitmapArrayRange] of TBitmap;
  TOutlineType = (otStandard, otOwnerDraw);
  TOutlineOption = (ooDrawTreeRoot, ooDrawFocusRect, ooStretchBitmaps);
  TOutlineOptions = set of TOutlineOption;


  TCustomOutline = class(TAdvCustomGrid)
  private
    FBlockInsert: Boolean;
    FRootNode: TOutlineNode;
    FGoodNode: TOutlineNode;
    UpdateCount: Integer;
    FCurItem: TOutlineNode;
    FSeparator: string;
    FFontSize: Integer;
    FStrings: TStrings;
    FUserBitmaps: TOutlineBitmaps;
    FOldBitmaps: TOutlineBitmaps;
    FPictures: TBitmapArray;
    FOnExpand: EOutlineChange;
    FOnCollapse: EOutlineChange;
    FOutlineStyle: TOutlineStyle;
//    FMaskColor: TColor;
    FItemHeight: Integer;
    FStyle: TOutlineType;
    FOptions: TOutlineOptions;
    FIgnoreScrollResize: Boolean;
    FSelectedItem: TOutlineNode;
    FOnDrawItem: TDrawItemEvent;
    FSettingWidth: Boolean;
    FSettingHeight: Boolean;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    function GetItemCount: LongInt;
    function AttachNode(Index: LongInt; Str: string;
      Ptr: Pointer; AttachMode: TAttachMode): LongInt;
    function Get(Index: LongInt): TOutlineNode;
    function GetSelectedItem: LongInt;
    procedure SetSelectedItem(Value: Longint);
    function CompareNodes(Value1, Value2: TOutlineNode): TOutlineNodeCompare;
    procedure Error(const ErrorString: string);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    function ResizeGrid: Boolean;
    procedure DoExpand(Node: TOutlineNode);
    procedure Init;
    procedure MoveNode(Destination, Source: LongInt;
      AttachMode: TAttachMode);
    procedure ClearBitmap(var Bitmap: TBitmap; Kind: TOutlineBitmap);
    procedure ChangeBitmap(Value: TBitmap; Kind: TOutlineBitmap);
    procedure SetRowHeight;
    procedure SetCurItem(Value: LongInt);
    procedure CreateGlyph;
    procedure SetStrings(Value: TStrings);
    function GetStrings: TStrings;
    function IsCurItem(Value: LongInt): Boolean;
    procedure SetPicture(Index: Integer; Value: TBitmap);
    function GetPicture(Index: Integer): TBitmap;
    procedure DrawPictures(BitMaps: array of TBitmap; ARect: TRect);
    procedure DrawText(Node: TOutlineNode; Rect: TRect);
    procedure SetOutlineStyle(Value: TOutlineStyle);
    procedure DrawTree(ARect: TRect; Node: TOutlineNode);
//    procedure SetMaskColor(Value: TColor);
    procedure SetItemHeight(Value: Integer);
    procedure SetStyle(Value: TOutlineType);
    procedure SetOutlineOptions(Value: TOutlineOptions);
    function StoreBitmap(Index: Integer): Boolean;
    procedure ReadBinaryData(Stream: TStream);
    procedure WriteBinaryData(Stream: TStream);
    procedure SetHorzScrollBar;
    procedure ResetSelectedItem;
    procedure SetRowFromNode(Node: TOutlineNode);
  protected
    procedure Loaded; override;
    procedure Click; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    function SetGoodIndex(Value: TOutlineNode): TOutlineNode;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TxGridDrawState); override;
    procedure DblClick; override;
    procedure SetLevel(Node: TOutlineNode; CurLevel, NewLevel: Cardinal);
    function BadIndex(Value: TOutlineNode): Boolean;
    procedure DeleteNode(Node: TOutlineNode; CurIndex: LongInt);
    procedure Expand(Index: LongInt); dynamic;
    procedure Collapse(Index: LongInt); dynamic;
    procedure DefineProperties(Filer: TFiler); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Move(Destination, Source: LongInt; AttachMode: TAttachMode);
    procedure SetDisplayWidth(Value: Integer);
    property Lines: TStrings read GetStrings write SetStrings;
    property OutlineStyle: TOutlineStyle read FOutlineStyle write SetOutlineStyle default osTreePictureText;
    property OnExpand: EOutlineChange read FOnExpand write FOnExpand;
    property OnCollapse: EOutlineChange read FOnCollapse write FOnCollapse;
    property Options: TOutlineOptions read FOptions write SetOutlineOptions
      default [ooDrawTreeRoot, ooDrawFocusRect];
    property Style: TOutlineType read FStyle write SetStyle default otStandard;
    property ItemHeight: Integer read FItemHeight write SetItemHeight;
    property OnDrawItem: TDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property ItemSeparator: string read FSeparator write FSeparator;
    property PicturePlus: TBitmap index 0 read GetPicture write SetPicture stored StoreBitmap;
    property PictureMinus: TBitmap index 1 read GetPicture write SetPicture stored StoreBitmap;
    property PictureOpen: TBitmap index 2 read GetPicture write SetPicture stored StoreBitmap;
    property PictureClosed: TBitmap index 3 read GetPicture write SetPicture stored StoreBitmap;
    property PictureLeaf: TBitmap index 4 read GetPicture write SetPicture stored StoreBitmap;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Add(Index: LongInt; const Text: string): LongInt;
    function AddChild(Index: LongInt; const Text: string): LongInt;
    function AddChildObject(Index: LongInt; const Text: string; const Data: Pointer): LongInt;
    function AddObject(Index: LongInt; const Text: string; const Data: Pointer): LongInt;
    function Insert(Index: LongInt; const Text: string): LongInt;
    function InsertObject(Index: LongInt; const Text: string; const Data: Pointer): LongInt;
    procedure Delete(Index: LongInt);
    function GetDataItem(Value: Pointer): Longint;
    function GetItem(X, Y: Integer): LongInt;
    function GetNodeDisplayWidth(Node: TOutlineNode): Integer;
    function GetTextItem(const Value: string): Longint;
    function GetVisibleNode(Index: LongInt): TOutlineNode;
    procedure FullExpand;
    procedure FullCollapse;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure SetUpdateState(Value: Boolean);
    procedure Clear;
    property ItemCount: LongInt read GetItemCount;
    property Items[Index: LongInt]: TOutlineNode read Get; default;
    property SelectedItem: Longint read GetSelectedItem write SetSelectedItem;
    property Row;
    property Canvas;
  end;

  TOutline = class(TCustomOutline)
  published
    property Lines;
    property OutlineStyle;
    property OnExpand;
    property OnCollapse;
    property Options;
    property Style;
    property ItemHeight;
    property OnDrawItem;
    property Align;
    property Enabled;
    property Font;
    property Color;
    property ParentColor;
    property ParentCtl3D;
    property Ctl3D;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property DragMode;
    property DragCursor;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnStartDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDblClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property BorderStyle;
    property ItemSeparator;
    property PicturePlus;
    property PictureMinus;
    property PictureOpen;
    property PictureClosed;
    property PictureLeaf;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property PopupMenu;
    property ScrollBars;
  end;

implementation

uses Consts;

const
  MaxLevels = 255;
  TAB = Chr(9);
  InvalidIndex = -1;
  BitmapWidth = 14;
  BitmapHeight = 14;

type

{ TOutlineStrings }

  TOutlineStrings = class(TStrings)
  private
    Outline: TCustomOutline;
    procedure ReadData(Reader: TReader);
    procedure WriteData(Writer: TWriter);
  protected
    procedure DefineProperties(Filer: TFiler); override;
    function Get(Index: Integer): string; override;
    function GetCount: Integer; override;
  public
    function Add(const S: string): Integer; override;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure PutObject(Index: Integer; AObject: TObject); override;
    function GetObject(Index: Integer): TObject; override;
  end;

function GetBufStart(Buffer: PChar; var Level: Cardinal): PChar;
begin
  Level := 0;
  while Buffer^ in [' ', #9] do
  begin
    Inc(Buffer);
    Inc(Level);
  end;
  Result := Buffer;
end;

function PutString(BufPtr: PChar; const S: string): PChar;
var
  I: Integer;
begin
  for I := 1 to Length(S) do
  begin
    BufPtr^ := S[I];
    Inc(BufPtr);
  end;
  Word(Pointer(BufPtr)^) := $0A0D;
  Inc(BufPtr, 2);
  Result := BufPtr;
end;


{TOutlineNode}

constructor TOutlineNode.Create(AOwner: TCustomOutline);
begin
  FOutline := AOwner;
end;

destructor TOutlineNode.Destroy;
var
  CurIndex: LongInt;
  LastNode: Boolean;
begin
  with Outline do
    if FRootNode = Self then FIgnoreScrollResize := True;
  try
    CurIndex := 0;
    if Parent <> nil then CurIndex := Outline.FCurItem.Index;
    if FList <> nil then Clear;
    if Outline.FSelectedItem = Self then Outline.ResetSelectedItem;
    if Parent <> nil then
    begin
      LastNode := Parent.List.Last = Self;
      Parent.Remove(Self);
      if Parent.List.Count = 0 then
        Outline.SetRowFromNode(Parent)
      else if LastNode then
        Outline.SetRowFromNode(TOutlineNode(Parent.List.Last));
      Outline.DeleteNode(Self, CurIndex);
    end;
  finally
    with Outline do
      if FRootNode = Self then FIgnoreScrollResize := False;
  end;
  inherited Destroy;
end;

procedure TOutlineNode.Clear;
var
  I: Integer;
  Node: TOutlineNode;
begin
  for I := 0 to FList.Count - 1 do
  begin
    Node := FList.Items[I];
    Node.FParent := nil;
    Node.Destroy;
  end;
  FList.Destroy;
  FList := nil;
end;

procedure TOutlineNode.SetHorzScrollBar;
begin
  if (Parent <> nil) and Parent.Expanded then
    Outline.SetHorzScrollBar;
end;

function TOutlineNode.GetList: TList;
begin
  if FList = nil then FList := TList.Create;
  Result := FList;
end;

function TOutlineNode.GetNode(Index: LongInt): TOutlineNode;
begin
  Result := List[Index];
end;

function TOutlineNode.GetLastIndex: LongInt;
begin
  if List.Count <> 0 then
    Result := TOutlineNode(List.Last).GetLastIndex
  else
    Result := Index;
end;

procedure TOutlineNode.SetText(const Value: string);
var
 NodeRow: LongInt;
begin
  FText := Value;
  if not Assigned(FParent) then Exit;

  if Parent.Expanded then
  begin
    NodeRow := 0;
    with Outline do
    begin
      FRootNode.GetRowOfNode(Self, NodeRow);
      InvalidateCell(0, NodeRow - 2);
    end;
  end;
  SetHorzScrollBar;
end;

procedure TOutlineNode.ChangeExpandedCount(Value: LongInt);
begin
  if not Expanded then Exit;
  Inc(FExpandCount, Value);
  if Parent <> nil then Parent.ChangeExpandedCount(Value);
end;

function TOutlineNode.GetIndex: LongInt;
begin
  if Outline.BadIndex(Self) then SetGoodIndex;
  Result := FIndex;
end;

function TOutlineNode.GetLevel: Cardinal;
var
  Node: TOutlineNode;
begin
  Result := 0;
  Node := Parent;
  while Node <> nil do
  begin
    Inc(Result);
    Node := Node.Parent;
  end;
end;

procedure TOutlineNode.SetLevel(Level: Cardinal);
var
  CurLevel: Cardinal;
begin
  CurLevel := GetLevel;
  if Level = CurLevel then Exit;
  Outline.SetLevel(Self, CurLevel, Level);
end;

procedure TOutlineNode.ChangeLevelBy(Value: TChangeRange);
begin
  Level := Level + DWORD(Value);
end;

function TOutlineNode.GetDisplayWidth: Integer;
begin
  Result := Outline.GetNodeDisplayWidth(Self);
end;

function TOutlineNode.HasVisibleParent: Boolean;
begin
  Result := (Parent <> nil) and (Parent.Expanded);
end;

function TOutlineNode.GetVisibleParent: TOutlineNode;
begin
  Result := Self;
  while (Result.Parent <> nil) and not Result.Parent.Expanded do
    Result := Result.Parent;
end;

function TOutlineNode.GetFullPath: string;
begin
  if Parent <> nil then
    if Parent.Parent <> nil then
      Result := Parent.GetFullPath + Outline.ItemSeparator + Text
    else
      Result := Text
  else Result := EmptyStr;
end;

function TOutlineNode.HasAsParent(Value: TOutlineNode): Boolean;
begin
  if Self = Value then
    Result := True
  else if Parent <> nil then Result := Parent.HasAsParent(Value)
  else Result := False;
end;

function TOutlineNode.GetTopItem: Longint;
var
  Node: TOutlineNode;
begin
  Result := 0;
  if Parent = nil then Exit;
  Node := Self;
  while Node.Parent <> nil do
  begin
    if Node.Parent.Parent = nil then
      Result := Node.FIndex;
    Node := Node.Parent;
  end;
end;

function TOutlineNode.GetFirstChild: LongInt;
begin
  if List.Count > 0 then Result := Items[0].Index
  else Result := InvalidIndex;
end;

function TOutlineNode.GetLastChild: LongInt;
begin
  if List.Count > 0 then Result := Items[List.Count - 1].Index
  else Result := InvalidIndex;
end;

function TOutlineNode.GetNextChild(Value: LongInt): LongInt;
var
 I: Integer;
begin
  Result := InvalidIndex;
  for I := 0 to List.Count - 1 do
  begin
    if Items[I].Index = Value then
    begin
      if I < List.Count - 1 then Result := Items[I + 1].Index;
      Break;
    end;
  end;
end;

function TOutlineNode.GetPrevChild(Value: LongInt): LongInt;
var
 I: Integer;
begin
  Result := InvalidIndex;
  for I := List.Count - 1 downto 0 do
  begin
    if Items[I].Index = Value then
    begin
      if I > 0 then Result := Items[I - 1].Index;
      Break;
    end;
  end;
end;

procedure TOutlineNode.MoveTo(Destination: LongInt; AttachMode: TAttachMode);
begin
  Outline.Move(Destination, Index, AttachMode);
end;

procedure TOutlineNode.FullExpand;
var
  I: Integer;
begin
  if HasItems then
  begin
    Expanded := True;
    for I := 0 to List.Count - 1 do
      Items[I].FullExpand;
  end;
end;

function TOutlineNode.GetRowOfNode(TargetNode: TOutlineNode;
  var RowCount: Longint): Boolean;
var
  I: Integer;
begin
  Inc(RowCount);
  if TargetNode = Self then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  if not Expanded then Exit;

  for I := 0 to List.Count - 1 do
  begin
    Result := Items[I].GetRowOfNode(TargetNode, RowCount);
    if Result then Exit
  end;
end;

function TOutlineNode.GetVisibleNode(TargetCount: LongInt): TOutlineNode;
var
  I, J: Integer;
  ExpandedCount, NodeCount, NodesParsed: LongInt;
  Node: TOutlineNode;
  Count: Integer;
begin
  if TargetCount = 0 then
  begin
    Result := Self;
    Exit;
  end;

  Result := nil;
  Count := List.Count;
  NodesParsed := 0;

  { Quick exit if we are lucky }
  if ExpandCount = Count then
  begin
    Result := Items[TargetCount - 1];
    Exit;
  end;

  I := 0;
  while I <= Count - 1 do
  begin
    for J := I to Count - 1 do
      if Items[J].Expanded then Break;

    if J > I then
    begin
      if J - I >= TargetCount then
      begin
        Result := Items[I + TargetCount - 1];
        Break;
      end;
      Dec(TargetCount, J - I);
    end;

    Node := Items[J];
    NodeCount := Node.ExpandCount + 1;
    ExpandedCount := NodeCount + J - I;

    Inc(NodesParsed, ExpandedCount);
    if NodeCount >= TargetCount then
    begin
      Result := Node.GetVisibleNode(Pred(TargetCount));
      Break;
    end
    else if ExpandCount - NodesParsed = Count - (J + 1) then
    begin
      Result := Items[TargetCount - NodeCount + J];
      Exit;
    end
    else begin
      Dec(TargetCount, NodeCount);
      I := J;
    end;
    Inc(I);
  end;
  if Result = nil then Error(SOutlineIndexError);
end;

function TOutlineNode.GetNodeAtIndex(TargetIndex: LongInt): TOutlineNode;
var
  I: Integer;
  Node: TOutlineNode;
  Lower: Integer;
  Upper: Integer;

  function RecurseNode: TOutlineNode;
  begin
    if Node.Index = TargetIndex then
      Result := Node
    else
      Result := Node.GetNodeAtIndex(TargetIndex);
  end;

begin
  if TargetIndex = Index then
  begin
    Result := Self;
    Exit;
  end;

  Lower := 0;
  Upper := List.Count - 1;
  Result := nil;
  while Upper >= Lower do
  begin
    I := (Lower + Upper) div 2;
    Node := Items[I];
    if Lower = Upper then
    begin
      Result := RecurseNode;
      Break;
    end
    else if Node.Index > TargetIndex then Upper := Pred(I)
    else if (Node.Index < TargetIndex) and (I < Upper) and
      (Items[I + 1].Index <= TargetIndex) then Lower := Succ(I)
    else begin
      Result := RecurseNode;
      Break;
    end;
  end;
  if Result = nil then Raise OutlineError.Create;
end;

function TOutlineNode.GetDataItem(Value: Pointer): LongInt;
var
  I: Integer;
begin
  if Value = Data then
  begin
    Result := Index;
    Exit;
  end;

  Result := 0;
  for I := 0 to List.Count - 1 do
  begin
    Result := Items[I].GetDataItem(Value);
    if Result <> 0 then Break;
  end;
end;

function TOutlineNode.GetTextItem(const Value: string): LongInt;
var
  I: Integer;
begin
  if Value = Text then
  begin
    Result := Index;
    Exit;
  end;

  Result := 0;
  for I := 0 to List.Count - 1 do
  begin
    Result := Items[I].GetTextItem(Value);
    if Result <> 0 then Break;
  end;
end;

procedure TOutlineNode.Expand;
begin
  Expanded := True;
end;

procedure TOutlineNode.Collapse;
begin
  Expanded := False;
end;

procedure TOutlineNode.SetExpandedState(Value: Boolean);
var
  ParentNode: TOutlineNode;
begin
  if FState <> Value then
  begin
    if Value then
    begin
      ParentNode := Self.Parent;
      while ParentNode <> nil do
      begin
        if not ParentNode.Expanded then Error(SOutlineExpandError);
        ParentNode := ParentNode.Parent;
      end;
      Outline.Expand(Index);
      FState := True;
      ChangeExpandedCount(List.Count);
    end
    else begin
      CloseNode;
      if List.Count > 0 then ChangeExpandedCount(-List.Count);
      if Outline.ResizeGrid then Outline.Invalidate;
      Outline.Collapse(Index);
      FState := False;
    end;
    SetHorzScrollBar;
    Repaint;
  end;
end;

procedure TOutlineNode.CloseNode;
var
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
    Items[I].CloseNode;
  if List.Count > 0 then ChangeExpandedCount(-List.Count);
  FState := False;
end;

procedure TOutlineNode.Repaint;
begin
  if Outline <> nil then
    if Outline.ResizeGrid then Outline.Invalidate;
end;

procedure TOutlineNode.SetGoodIndex;
var
  StartNode: TOutlineNode;
  ParentNode: TOutlineNode;
begin
  StartNode := Outline.SetGoodIndex(Self);
  ParentNode := StartNode.Parent;
  if ParentNode <> nil then
    ParentNode.ReIndex(StartNode, Self, StartNode.FIndex, True)
  else if Self <> Outline.FRootNode then
    FIndex := Succ(StartNode.FIndex);
  Outline.FGoodNode := Self;
end;

function TOutlineNode.AddNode(Value: TOutlineNode): LongInt;
begin
  List.Add(Value);
  Value.FParent := Self;
  ChangeExpandedCount(Value.ExpandCount + 1);
  if not Outline.FBlockInsert then Value.SetGoodIndex;
  with Value do
  begin
    Result := FIndex;
    SetHorzScrollBar;
  end;
end;

function TOutlineNode.InsertNode(Index: LongInt; Value: TOutlineNode): LongInt;
var
  CurIndex: LongInt;
  I: Integer;
begin
  for I := 0 to List.Count - 1 do
  begin
    CurIndex := Items[I].FIndex;
    if CurIndex = Index then
    begin
      List.Insert(I, Value);
      Value.FParent := Self;
      Break;
    end;
  end;
  ChangeExpandedCount(Value.ExpandCount + 1);
  if not Outline.FBlockInsert then Value.SetGoodIndex;
  with Value do
  begin
    Result := FIndex;
    SetHorzScrollBar;
  end;
end;

procedure TOutlineNode.InternalRemove(Value: TOutlineNode; Index: Integer);
begin
  if Index <> 0 then
    Outline.SetGoodIndex(Items[Index - 1]) else
    Outline.SetGoodIndex(Self);
  List.Delete(Index);
  ChangeExpandedCount(-(Value.ExpandCount + 1));
  if (List.Count = 0) and (Parent <> nil) then Expanded := False;
  SetHorzScrollBar;
end;

procedure TOutlineNode.Remove(Value: TOutlineNode);
begin
  InternalRemove(Value, List.IndexOf(Value));
end;

procedure TOutlineNode.ReIndex(StartNode, EndNode: TOutlineNode;
  NewIndex: LongInt; IncludeStart: Boolean);
var
  I: Integer;
begin
  for I := List.IndexOf(StartNode) to List.Count - 1 do
  begin
    if IncludeStart then
    begin
      if Items[I].Resync(NewIndex, EndNode) then Exit;
    end
    else
      IncludeStart := True;
  end;

  if Parent <> nil then
    Parent.ReIndex(Self, EndNode, NewIndex, False);
end;

function TOutlineNode.Resync(var NewIndex: LongInt; EndNode: TOutlineNode): Boolean;
var
  I: Integer;
begin
  FIndex := NewIndex;
  if EndNode = Self then
  begin
    Result := True;
    Exit;
  end;

  Result := False;
  Inc(NewIndex);
  for I := 0 to List.Count - 1 do
  begin
    Result := Items[I].Resync(NewIndex, EndNode);
    if Result then Exit;
  end;
end;

function TOutlineNode.GetExpandedNodeCount: LongInt;
var
  I : Integer;
begin
  Result := 1;
  if Expanded then
    for I := 0 to List.Count - 1 do
      Inc(Result, Items[I].GetExpandedNodeCount);
end;


function TOutlineNode.GetMaxDisplayWidth(Value: Cardinal): Cardinal;
var
  I : Integer;
  Width: Cardinal;
begin
  Width := GetDisplayWidth;
  if Width > Value then Result := Width
  else Result := Value;
  if Expanded then
    for I := 0 to List.Count - 1 do
      Result := Items[I].GetMaxDisplayWidth(Result);
end;

procedure TOutlineNode.Error(const ErrorString: string);
begin
  raise EOutlineError.Create(ErrorString);
end;

function TOutlineNode.HasChildren: Boolean;
begin
  Result := List.Count > 0;
end;

procedure TOutlineNode.WriteNode(Buffer: PChar; Stream: TStream);
var
  BufPtr: PChar;
  NodeLevel: Word;
  I: Integer;
begin
  if Parent <> nil then
  begin
    BufPtr := Buffer;
    NodeLevel := Level;
    while NodeLevel > 1 do
    begin
      BufPtr^ := Tab;
      Dec(NodeLevel);
      Inc(BufPtr);
    end;
    BufPtr := PutString(BufPtr, Text);
    Stream.WriteBuffer(Buffer[0], BufPtr - Buffer);
  end;
  for I := 0 to List.Count - 1 do
    Items[I].WriteNode(Buffer, Stream);
end;

function TOutlineNode.IsEqual(Value: TOutlineNode): Boolean;
begin
  Result := (Text = Value.Text) and (Data = Value.Data) and
    (ExpandCount = Value.ExpandCount);
end;

{ TOutlineStrings }

function TOutlineStrings.Get(Index: Integer): string;
var
  Node: TOutlineNode;
  Level: Word;
  I: Integer;
begin
  Node := Outline[Index + 1];
  Level := Node.Level;
  Result := EmptyStr;
  for I := 0 to Level - 2 do
    Result := Result + TAB;
  Result := Result + Node.Text;
end;

function TOutlineStrings.GetCount: Integer;
begin
  Result := Outline.ItemCount;
end;

procedure TOutlineStrings.Clear;
begin
  Outline.Clear;
end;

procedure TOutlineStrings.DefineProperties(Filer: TFiler);

  function WriteNodes: Boolean;
  var
    I: Integer;
    Ancestor: TOutlineStrings;
  begin
    Ancestor := TOutlineStrings(Filer.Ancestor);
    if (Ancestor <> nil) and (Ancestor.Outline.ItemCount = Outline.ItemCount) and
      (Ancestor.Outline.ItemCount > 0) then
    begin
      Result := False;
      for I := 1 to Outline.ItemCount - 1 do
      begin
        Result := not Outline[I].IsEqual(Ancestor.Outline[I]);
        if Result then Break;
      end
    end else Result := Outline.ItemCount > 0;
  end;

begin
  Filer.DefineProperty('Nodes', ReadData, WriteData, WriteNodes);
end;

procedure TOutlineStrings.ReadData(Reader: TReader);
var
  StringList: TStringList;
  MemStream: TMemoryStream;
begin
  Reader.ReadListBegin;
  StringList := TStringList.Create;
  try
    while not Reader.EndOfList do StringList.Add(Reader.ReadString);
    MemStream := TMemoryStream.Create;
    try
      StringList.SaveToStream(MemStream);
      MemStream.Position := 0;
      Outline.LoadFromStream(MemStream);
    finally
      MemStream.Free;
    end;
  finally
    StringList.Free;
  end;
  Reader.ReadListEnd;
end;

procedure TOutlineStrings.WriteData(Writer: TWriter);
var
  I: Integer;
  MemStream: TMemoryStream;
  StringList: TStringList;
begin
  Writer.WriteListBegin;
  MemStream := TMemoryStream.Create;
  try
    Outline.SaveToStream(MemStream);
    MemStream.Position := 0;
    StringList := TStringList.Create;
    try
      StringList.LoadFromStream(MemStream);
      for I := 0 to StringList.Count - 1 do
        Writer.WriteString(StringList.Strings[I]);
    finally
      StringList.Free;
    end;
  finally
    MemStream.Free;
  end;
  Writer.WriteListEnd;
end;

function TOutlineStrings.Add(const S: string): Integer;
var
  Level, OldLevel, I: Cardinal;
  NewStr: string;
  NumNodes: LongInt;
  LastNode: TOutlineNode;
begin
  NewStr := GetBufStart(PChar(S), Level);
  NumNodes := Outline.ItemCount;
  if NumNodes > 0 then LastNode := Outline[Outline.ItemCount]
  else LastNode := Outline.FRootNode;
  OldLevel := LastNode.Level;
  if (Level > OldLevel) or (LastNode = Outline.FRootNode) then
  begin
    if Level - OldLevel > 1 then Outline.Error(SOutlineFileLoad);
  end
  else begin
    for I := OldLevel downto Level + 1 do
    begin
      LastNode := LastNode.Parent;
      if not Assigned(LastNode) then Outline.Error(SOutlineFileLoad);
    end;
  end;
  Result := Outline.AddChild(LastNode.Index, NewStr) - 1;
end;

procedure TOutlineStrings.Delete(Index: Integer);
begin
  Outline.Delete(Index + 1);
end;

procedure TOutlineStrings.Insert(Index: Integer; const S: string);
begin
  Outline.Insert(Index + 1, S);
end;

procedure TOutlineStrings.PutObject(Index: Integer; AObject: TObject);
var
  Node: TOutlineNode;
begin
  Node := Outline[Index + 1];
  Node.Data := Pointer(AObject);
end;

function TOutlineStrings.GetObject(Index: Integer): TObject;
begin
  Result := TObject(Outline[Index + 1].Data);
end;


{TCustomOutline}

const
  Images: array[TBitmapArrayRange] of PChar = ('PLUS', 'MINUS', 'OPEN', 'CLOSED', 'LEAF');

constructor TCustomOutline.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 121;
  Height := 97;
  Color := clWindow;
  ParentColor := False;
  SetRowHeight;
  RowCount := 0;
  ColCount := 1;
  FixedCols := 0;
  FixedRows := 0;
  DefaultDrawing := False;
  Init;
  FStrings := TOutlineStrings.Create;
  TOutlineStrings(FStrings).Outline := Self;
  inherited Options := [];
  Options := [ooDrawTreeRoot, ooDrawFocusRect];
  ItemSeparator := '\';
  FOutlineStyle := osTreePictureText;
  CreateGlyph;
end;

destructor TCustomOutline.Destroy;
var
  I: Integer;
begin
  FStrings.Free;
  FRootNode.Free;
  for I := Low(FPictures) to High(FPictures) do FPictures[I].Free;
  inherited Destroy;
end;

procedure TCustomOutline.Init;
begin
  if FRootNode = nil then FRootNode := TOutlineNode.Create(Self);
  FRootNode.FState := True;
  ResetSelectedItem;
  FGoodNode := FRootNode;
  FCurItem := FRootNode;
  FBlockInsert := False;
  UpdateCount := 0;
  ResizeGrid;
end;

procedure TCustomOutline.CreateGlyph;
var
  I: Integer;
begin
  FUserBitmaps := [];
  FOldBitmaps := [];
  for I := Low(FPictures) to High(FPictures) do
  begin
    FPictures[I] := TBitmap.Create;
    FPictures[I].Handle := LoadBitmap(HInstance, Images[I]);
  end;
end;

procedure TCustomOutline.SetRowHeight;
var
  ScreenDC: HDC;
begin
  if Style <> otOwnerDraw then
  begin
    ScreenDC := GetDC(0);
    try
      FFontSize := MulDiv(Font.Size, GetDeviceCaps(ScreenDC, LOGPIXELSY), 72);
      DefaultRowHeight := MulDiv(FFontSize, 120, 100);
      FItemHeight := DefaultRowHeight;
    finally
      ReleaseDC(0, ScreenDC);
    end;
  end
end;

procedure TCustomOutline.Clear;
begin
  FRootNode.Destroy;
  FRootNode := nil;
  Init;
end;

procedure TCustomOutline.DefineProperties(Filer: TFiler);

  function WriteOutline: Boolean;
  var
    Ancestor: TCustomOutline;
  begin
    Ancestor := TCustomOutline(Filer.Ancestor);
    if Ancestor <> nil then
      Result := (Ancestor.FUserBitmaps <> []) and
        (Ancestor.FUserBitmaps - FUserBitmaps <> [])
    else Result := FUserBitmaps <> [];
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', ReadBinaryData, WriteBinaryData,
    WriteOutline);
end;

procedure TCustomOutline.ReadBinaryData(Stream: TStream);
begin
  Stream.ReadBuffer(FOldBitmaps, SizeOf(FOldBitmaps));
end;

procedure TCustomOutline.WriteBinaryData(Stream: TStream);
begin
  Stream.WriteBuffer(FuserBitmaps, SizeOf(FUserBitmaps));
end;

function TCustomOutline.IsCurItem(Value: LongInt): Boolean;
begin
  Result := Value = FCurItem.Index;
end;

function TCustomOutline.GetItemCount: LongInt;
begin
  Result := FRootNode.GetLastIndex;
end;

procedure TCustomOutline.MoveNode(Destination, Source: LongInt;
  AttachMode: TAttachMode);
var
  SourceNode: TOutlineNode;
  DestNode: TOutLineNode;
  OldParent: TOutlineNode;
  OldIndex: Integer;
begin
  if Destination = Source then Exit;
  DestNode := FCurItem;
  if not IsCurItem(Destination) then
    try
      DestNode := FRootNode.GetNodeAtIndex(Destination);
    except
      on OutlineError do Error(SOutlineIndexError);
    end;

  SourceNode := FCurItem;
  if not IsCurItem(Source) then
    try
      SourceNode := FRootNode.GetNodeAtIndex(Source);
    except
      on OutlineError do Error(SOutlineIndexError);
    end;

  if DestNode.HasAsParent(SourceNode) then Exit;

  if DestNode.GetLevel > MaxLevels then Error(SOutlineMaxLevels);
  if (FGoodNode = FRootNode) and (FRootNode.List.Count <> 0) then
    TOutlineNode(FRootNode[0]).SetGoodIndex;
  OldParent := SourceNode.Parent;
  OldIndex := -1;
  case AttachMode of
    oaInsert:
      begin
        if DestNode.Parent = OldParent then
        begin
          OldIndex := OldParent.List.IndexOf(SourceNode);
          if OldParent.List.IndexOf(DestNode) < OldIndex then
            OldIndex := OldIndex + 1 else
            OldIndex := -1;
        end;
        DestNode.Parent.InsertNode(DestNode.Index, SourceNode);
      end;
    oaAddChild: DestNode.AddNode(SourceNode);
    oaAdd: DestNode.Parent.AddNode(SourceNode);
  end;
  if OldIndex <> -1 then
    OldParent.InternalRemove(SourceNode, OldIndex) else
    OldParent.Remove(SourceNode);
  if not DestNode.Expanded then SourceNode.Expanded := False;
  if (FGoodNode = FRootNode) and (FRootNode.List.Count <> 0) then
    TOutlineNode(FRootNode[0]).SetGoodIndex;
  ResizeGrid;
  Invalidate;
end;

function TCustomOutline.AttachNode(Index: LongInt; Str: string;
  Ptr: Pointer; AttachMode: TAttachMode): LongInt;
var
  NewNode: TOutlineNode;
  CurrentNode: TOutLineNode;
begin
  Result := 0;
  NewNode := TOutlineNode.Create(Self);
  with NewNode do
  begin
    Text := Str;
    Data := Ptr;
    FIndex := InvalidIndex;
  end;
  try
    CurrentNode := FCurItem;
    if not IsCurItem(Index) then
      try
        CurrentNode := FRootNode.GetNodeAtIndex(Index);
      except
        on OutlineError do Error(SOutlineIndexError);
      end;

    if AttachMode = oaAdd then
    begin
      CurrentNode := CurrentNode.Parent;
      if CurrentNode = nil then Error(SOutlineError);
      AttachMode := oaAddChild;
    end;

    with CurrentNode do
    begin
      case AttachMode of
        oaInsert: Result := Parent.InsertNode(Index, NewNode);
        oaAddChild:
          begin
             if GetLevel > MaxLevels then Error(SOutlineMaxLevels);
             Result := AddNode(NewNode);
          end;
      end;
    end;
    if ResizeGrid then Invalidate;
  except
    NewNode.Destroy;
    Application.HandleException(Self);
  end;
end;

function TCustomOutline.Get(Index: LongInt): TOutlineNode;
begin
  Result := FCurItem;
  if not IsCurItem(Index) then
    try
      Result := FRootNode.GetNodeAtIndex(Index);
    except
      on OutlineError do Error(SOutlineIndexError);
    end;
  if Result = FRootNode then Error(SOutlineError);
end;

function TCustomOutline.GetSelectedItem: LongInt;
begin
  if FSelectedItem <> FRootNode then
  begin
    if not FSelectedItem.IsVisible then
      FSelectedItem := FSelectedItem.GetVisibleParent;
  end
  else if FRootNode.List.Count > 0 then
    FSelectedItem := FRootNode.GetVisibleNode(Row + 1);
  Result := FSelectedItem.Index
end;

procedure TCustomOutline.ResetSelectedItem;
begin
  FSelectedItem := FRootNode;
end;

procedure TCustomOutline.SetRowFromNode(Node: TOutlineNode);
var
  RowValue: LongInt;
begin
  if Node <> FRootNode then
  begin
    RowValue := 0;
    FRootNode.GetRowOfNode(Node, RowValue);
    Row := RowValue - 2;
  end;
end;

procedure TCustomOutline.SetSelectedItem(Value: Longint);
var
  Node: TOutlineNode;
begin
  if FBlockInsert then Exit;
  if (Value = 0) and (FRootNode.List.Count > 0) then Value := 1;
  if Value > 0 then
  begin
    Node := FSelectedItem;
    if Value <> FSelectedItem.Index then
    try
      Node := FRootNode.GetNodeAtIndex(Value);
    except
      on OutlineError do Error(SOutlineIndexError);
    end;
    if not Node.IsVisible then Node := Node.GetVisibleParent;
    FSelectedItem := Node;
    SetRowFromNode(Node);
  end
  else Error(SOutlineSelection);
end;

function TCustomOutline.Insert(Index: LongInt; const Text: string): LongInt;
begin
  Result := InsertObject(Index, Text, nil);
end;

function TCustomOutline.InsertObject(Index: LongInt; const Text: string; const Data: Pointer): LongInt;
begin
  Result := -1;
  if Index > 0 then Result := AttachNode(Index, Text, Data, oaInsert)
  else if Index = 0 then Result := AddChildObject(Index, Text, Data)
  else Error(SOutlineError);
  SetCurItem(Index);
end;

function TCustomOutline.Add(Index: LongInt; const Text: string): LongInt;
begin
  Result := AddObject(Index, Text, nil);
end;

function TCustomOutline.AddObject(Index: LongInt; const Text: string; const Data: Pointer): LongInt;
begin
  Result := -1;
  if Index > 0 then Result := AttachNode(Index, Text, Data, oaAdd)
  else If Index = 0 then Result := AddChildObject(Index, Text, Data)
  else Error(SOutlineError);
  SetCurItem(Index);
end;

function TCustomOutline.AddChild(Index: LongInt; const Text: string): LongInt;
begin
  Result := AddChildObject(Index, Text, nil);
end;

function TCustomOutline.AddChildObject(Index: LongInt; const Text: string; const Data: Pointer): LongInt;
begin
  Result := -1;
  if Index >= 0 then Result := AttachNode(Index, Text, Data, oaAddChild)
  else Error(SOutlineError);
  SetCurItem(Index);
end;

procedure TCustomOutline.Delete(Index: LongInt);
begin
  if Index > 0 then
  begin
    try
      FRootNode.GetNodeAtIndex(Index).Free;
    except
      on OutlineError do Error(SOutlineIndexError);
    end;
  end
  else Error(SOutlineError);
end;

procedure TCustomOutline.Move(Destination, Source: LongInt; AttachMode: TAttachMode);
begin
  if (AttachMode = oaAddChild) or (Destination > 0) then
    MoveNode(Destination, Source, AttachMode)
  else Error(SOutlineError);
end;

procedure TCustomOutline.DeleteNode(Node: TOutlineNode; CurIndex: LongInt);
begin
  if (FGoodNode = FRootNode) and (FRootNode.List.Count <> 0) then
    FRootNode[0].SetGoodIndex;
  try
    FCurItem := FRootNode.GetNodeAtIndex(CurIndex);
  except
    on OutlineError do FCurItem := FRootNode;
  end;
  if (FSelectedItem = FRootNode) and (Node <> FRootNode) then
    GetSelectedItem;
  if ResizeGrid then Invalidate;
end;

procedure TCustomOutline.SetLevel(Node: TOutlineNode; CurLevel, NewLevel: Cardinal);
var
  NumLevels: Integer;

  procedure MoveUp(Node: TOutlineNode; NumLevels: Cardinal);
  var
    Parent: TOutlineNode;
    I: Cardinal;
    Index: Integer;
  begin
    Parent := Node;
    for I := NumLevels downto 1 do
      Parent := Parent.Parent;
    Index := Parent.Parent.GetNextChild(Parent.Index);
    if Index = InvalidIndex then Node.MoveTo(Parent.Parent.Index, oaAddChild)
    else Node.MoveTo(Index, oaInsert);
  end;

  procedure MoveDown(Node: TOutlineNode; NumLevels: Cardinal);
  var
    Parent: TOutlineNode;
    I: Cardinal;
  begin
    while NumLevels > 0 do
    begin
      Parent := Node.Parent;
      for I := Parent.List.Count - 1 downto 0 do
        if Parent.Items[I].Index = Node.Index then Break;
      if I > 0 then
      begin
        Parent := Parent.Items[I - 1];
        Node.MoveTo(Parent.Index, oaAddChild);
      end else Error(SOutlineBadLevel);
      Dec(NumLevels);
    end;
  end;

begin
  NumLevels := CurLevel - NewLevel;
  if (NewLevel > 0) then
  begin
    if (NumLevels > 0) then MoveUp(Node, NumLevels)
    else MoveDown(Node, ABS(NumLevels));
  end
  else Error(SOutlineBadLevel);
end;

procedure TCustomOutline.Click;
begin
  if FRootNode.List.Count > 0 then
    SelectedItem := FRootNode.GetVisibleNode(Row + 1).Index;
  inherited Click;
end;

procedure TCustomOutline.WMSize(var Message: TWMSize);
begin
  inherited;
  if FSettingWidth or FSettingHeight then Exit;
  if (ScrollBars in [ssNone, ssVertical]) or
    ((Style = otOwnerDraw) and Assigned(FOnDrawItem)) then
    DefaultColWidth := ClientWidth
  else SetHorzScrollBar;
end;

procedure TCustomOutline.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  if FSelectedItem <> FRootNode then
    case Key of
      '+': FSelectedItem.Expanded := True;
      '-': FSelectedItem.Expanded := False;
      '*': FSelectedItem.FullExpand;
    end;
end;

procedure TCustomOutline.KeyDown(var Key: Word; Shift: TShiftState);
var
  Node: TOutlineNode;
begin
  inherited KeyDown(Key, Shift);
  if FRootNode.List.Count = 0 then Exit;
  Node := FRootNode.GetVisibleNode(Row + 1);
  case Key of
    VK_HOME:
      begin
        SelectedItem := TOutlineNode(FRootNode.List.First).Index;
        Exit;
      end;
    VK_END:
      begin
        Node := TOutlineNode(FRootNode.List.Last);
        while Node.Expanded and Node.HasItems do
          Node := TOutlineNode(Node.List.Last);
        SelectedItem := Node.Index;
        Exit;
      end;
    VK_RETURN:
      begin
        Node.Expanded := not Node.Expanded;
        Exit;
      end;
    VK_MULTIPLY:
      begin
        if ssCtrl in Shift then
        begin
          FullExpand;
          Exit;
        end;
      end;
    VK_RIGHT:
      begin
        if (not Node.HasItems) or (not Node.Expanded) then MessageBeep(0)
        else SelectedItem := SelectedItem + 1;
        Exit;
      end;
    VK_LEFT:
      begin
        if Node.Parent = FRootNode then MessageBeep(0)
        else SelectedItem := Node.Parent.Index;
        Exit;
      end;
    VK_UP:
      if ssCtrl in Shift then
      begin
        with Node.Parent do
        begin
          if List.First = Node then MessageBeep(0)
          else SelectedItem := Items[List.IndexOf(Node) - 1].Index;
        end;
        Exit;
      end;
    VK_DOWN:
      if ssCtrl in Shift then
      begin
        with Node.Parent do
        begin
          if List.Last = Node then MessageBeep(0)
          else SelectedItem := Items[List.IndexOf(Node) + 1].Index;
        end;
        Exit;
      end;
  end;
  SelectedItem := FRootNode.GetVisibleNode(Row + 1).Index;
end;

procedure TCustomOutline.DblClick;
var
  Node: TOutlineNode;
begin
  inherited DblClick;
  Node := FSelectedItem;
  if Node <> FRootNode then DoExpand(Node);
end;

procedure TCustomOutline.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  ResetSelectedItem;
  GetSelectedItem;
end;

procedure TCustomOutline.FullExpand;
begin
  FRootNode.FullExpand;
end;

procedure TCustomOutline.FullCollapse;
var
  I: Integer;
begin
  for I := 0 to FRootNode.List.Count - 1 do
    FRootNode.Items[I].Expanded := False;
end;

procedure TCustomOutline.SetHorzScrollBar;
begin
  if (ScrollBars in [ssHorizontal, ssBoth]) and
    (UpdateCount <= 0) and not FIgnoreScrollResize and
    not ((Style = otOwnerDraw) and Assigned(FOnDrawItem)) then
    SetDisplayWidth(FRootNode.GetMaxDisplayWidth(0));
end;

procedure TCustomOutline.DoExpand(Node: TOutlineNode);
begin
  with Node do
    Expanded := not Expanded;
end;

procedure TCustomOutline.BeginUpdate;
begin
  if UpdateCount = 0 then SetUpdateState(True);
  Inc(UpdateCount);
end;

procedure TCustomOutline.EndUpdate;
begin
  Dec(UpdateCount);
  if UpdateCount = 0 then SetUpdateState(False);
end;

procedure TCustomOutline.SetUpdateState(Value: Boolean);
begin
  if FBlockInsert <> Value then
  begin
    FBlockInsert := Value;
    if not FBlockInsert then
    begin
      if ResizeGrid then Invalidate;
      if FRootNode.List.Count > 0 then
        TOutlineNode(FRootNode.List.First).SetGoodIndex
      else
        FRootNode.SetGoodIndex;
      SetHorzScrollBar;
    end;
  end;
end;

function TCustomOutline.ResizeGrid: Boolean;
var
  OldRowCount: LongInt;
begin
  Result := False;
  if not FBlockInsert then
  begin
    OldRowCount := RowCount;
    FSettingHeight := True;
    try
      RowCount := FRootNode.ExpandCount;
    finally
      FSettingHeight := False;
    end;
    Result := RowCount <> OldRowCount;
    if FSelectedItem <> FRootNode then SelectedItem := FSelectedItem.Index;
  end;
end;

function TCustomOutline.BadIndex(Value: TOutlineNode): Boolean;
begin
  Result := CompareNodes(Value, FGoodNode) = ocGreater;
end;

function TCustomOutline.SetGoodIndex(Value: TOutlineNode): TOutlineNode;
var
  ParentNode: TOutlineNode;
  Index: Integer;
  Compare: TOutlineNodeCompare;
begin
  Compare := CompareNodes(FGoodNode, Value);

  case Compare of
    ocLess,
    ocSame:
      Result := FGoodNode;
    ocGreater:
      begin
        ParentNode := Value.Parent;
        Index := ParentNode.List.IndexOf(Value);
        if Index <> 0 then
          Result := ParentNode[Index - 1]
        else
          Result := ParentNode;
      end;
    ocInvalid:
      Result := FRootNode;
  else
    Result := FRootNode;    
  end;

  FGoodNode := Result;
end;

function TCustomOutline.CompareNodes(Value1, Value2: TOutlineNode): TOutlineNodeCompare;
var
  Level1: Integer;
  Level2: Integer;
  Index1: Integer;
  Index2: Integer;
  Value1ParentNode: TOutlineNode;
  Value2ParentNode: TOutlineNode;
  CommonNode: TOutlineNode;

  function GetParentNodeAtLevel(Value: TOutlineNode; Level: Integer): TOutlineNode;
  begin
    while Level > 0 do
    begin
      Value := Value.Parent;
      Dec(Level);
    end;
  Result := Value;
  end;

begin
  if Value1 = Value2 then
  begin
    Result := ocSame;
    Exit;
  end;

  Value1ParentNode := Value1;
  Value2ParentNode := Value2;

  Level1 := Value1.GetLevel;
  Level2 := Value2.GetLevel;

  if Level1 > Level2 then
    Value1ParentNode := GetParentNodeAtLevel(Value1, Level1 - Level2)
  else if Level2 > Level1 then
    Value2ParentNode := GetParentNodeAtLevel(Value2, Level2 - Level1);

  while Value1ParentNode.Parent <> Value2ParentNode.Parent do
  begin
    Value1ParentNode := Value1ParentNode.Parent;
    Value2ParentNode := Value2ParentNode.Parent;
  end;

  CommonNode := Value1ParentNode.Parent;
  if CommonNode <> nil then
  begin
    Index1 := CommonNode.List.IndexOf(Value1ParentNode);
    Index2 := CommonNode.List.IndexOf(Value2ParentNode);
    if Index1 < Index2 then Result := ocLess
    else if Index2 < Index1 then Result := ocGreater
    else begin
      if Level1 > Level2 then Result := ocGreater
      else if Level1 = Level2 then Result := ocSame
      else Result := ocLess;
    end
  end
  else
    Result := ocInvalid;
end;

function TCustomOutline.GetDataItem(Value: Pointer): Longint;
begin
  Result := FRootNode.GetDataItem(Value);
end;

function TCustomOutline.GetItem(X, Y: Integer): LongInt;
var
  Value: TxGridCoord;
begin
  Result := -1;
  Value := MouseCoord(X, Y);
  with Value do
   if (Y > 0) or (FRootNode.List.Count > 0) then
     Result := FRootNode.GetVisibleNode(Y + 1).Index;
end;

function TCustomOutline.GetTextItem(const Value: string): Longint;
begin
  Result := FRootNode.GetTextItem(Value);
end;

procedure TCustomOutline.SetCurItem(Value: LongInt);
begin
  if Value < 0 then Error(SInvalidCurrentItem);
  if not IsCurItem(Value) then
    try
      FCurItem := FRootNode.GetNodeAtIndex(Value);
    except
      on OutlineError do Error(SOutlineIndexError);
    end;
end;

procedure TCustomOutline.SetOutlineStyle(Value: TOutlineStyle);
begin
  if FOutlineStyle <> Value then
  begin
    FOutlineStyle := Value;
    SetHorzScrollBar;
    Invalidate;
  end;
end;

procedure TCustomOutline.CMFontChanged(var Message: TMessage);
begin
  inherited;
  SetRowHeight;
  SetHorzScrollBar;
end;

procedure TCustomOutline.SetDisplayWidth(Value: Integer);
begin
  FSettingWidth := True;
  try
    if DefaultColWidth <> Value then DefaultColWidth := Value;
  finally
    FSettingWidth := False;
  end;
end;

function TCustomOutline.GetNodeDisplayWidth(Node: TOutlineNode): Integer;
var
  Delta: Integer;
  TextLength: Integer;
begin
  Result := 0;
  Delta := (DefaultRowHeight - FFontSize) div 2;

  with Canvas do
  begin
    Font := Self.Font;
    TextLength := TextWidth(Node.Text) + 1;
  end;

  case OutlineStyle of
    osText: Inc(Result, DefaultRowHeight * (Integer(Node.Level) - 1));
    osPlusMinusPictureText: Inc(Result, DefaultRowHeight * (Integer(Node.Level) + 1));
    osPlusMinusText,
    osPictureText: Inc(Result, DefaultRowHeight * Integer(Node.Level));
    osTreeText:
      begin
        Inc(Result, DefaultRowHeight * (Integer(Node.Level) - 1) - Delta);
        if ooDrawTreeRoot in Options then Inc(Result, DefaultRowHeight);
      end;
    osTreePictureText:
      begin
        Inc(Result, DefaultRowHeight * (Integer(Node.Level)) - Delta);
        if ooDrawTreeRoot in Options then Inc(Result, DefaultRowHeight);
      end;
  end;
  Inc(Result, TextLength);
  if Result < 0 then Result := 0;
end;

function TCustomOutline.GetVisibleNode(Index: LongInt): TOutlineNode;
begin
  Result := FRootNode.GetVisibleNode(Index + 1);
end;

procedure TCustomOutline.DrawCell(ACol, ARow: Longint; ARect: TRect; AState: TxGridDrawState);
var
  Node: TOutlineNode;
  Expanded: Boolean;
  HasChildren: Boolean;
  IndentLevel: Word;
  Bitmap1, Bitmap2: TBitmap;
  TextLength: Integer;
  Delta: Integer;
  InitialLeft: Integer;

  function GetBitmap(Value: TOutlineBitmap): TBitmap;
  begin
    Result := FPictures[Ord(Value)];
  end;

  procedure DrawFocusCell;
  begin
    Inc(ARect.Right, TextLength);
    if (Row = ARow) and (Node.Text <> '') then
      Canvas.FillRect(ARect);
  end;

  procedure DrawTheText;
  begin
    Inc(ARect.Left, DefaultRowHeight * (IndentLevel - 1));
    ARect.Right := ARect.Left;
    DrawFocusCell;
    DrawText(Node, ARect);
  end;

  procedure DrawPlusMinusPicture;
  begin
    Inc(ARect.Left, DefaultRowHeight * (IndentLevel - 1));
    if HasChildren then
    begin
      if Expanded then
      begin
        Bitmap1 := GetBitmap(obMinus);
        Bitmap2 := GetBitmap(obOpen);
      end
      else begin
        Bitmap1 := GetBitmap(obPlus);
        Bitmap2 := GetBitmap(obClose);
      end;
    end
    else begin
      Bitmap1 := nil;
      Bitmap2 := GetBitmap(obLeaf);
    end;
    ARect.Left := ARect.Left + DefaultRowHeight * 2;
    ARect.Right := ARect.Left;
    DrawFocusCell;
    DrawText(Node, ARect);
    Dec(ARect.Left, DefaultRowHeight * 2);
    DrawPictures([Bitmap1, Bitmap2], ARect);
  end;

  procedure DrawPictureText;
  var
    Style: TOutlineBitmap;
  begin
    Inc(ARect.Left, DefaultRowHeight * (IndentLevel - 1));
    if HasChildren then
    begin
      if Expanded then Style := obOpen
      else Style := obClose
    end
    else Style := obLeaf;
    Bitmap1 := GetBitmap(Style);
    ARect.Left := ARect.Left + DefaultRowHeight;
    ARect.Right := ARect.Left;
    DrawFocusCell;
    DrawText(Node, ARect);
    Dec(ARect.Left, DefaultRowHeight);
    DrawPictures([Bitmap1], ARect);
  end;

  procedure DrawPlusMinusText;
  var
    Style: TOutlineBitmap;
  begin
    Inc(ARect.Left, DefaultRowHeight * IndentLevel);
    ARect.Right := ARect.Left;
    DrawFocusCell;
    DrawText(Node, ARect);
    if HasChildren then
    begin
      if Expanded then Style := obMinus
      else Style := obPlus;
      Bitmap1 := GetBitmap(Style);
      Dec(ARect.Left, DefaultRowHeight);
      DrawPictures([Bitmap1], ARect);
    end;
  end;

  procedure DrawTheTree;
  begin
    DrawTree(ARect, Node);
    Inc(ARect.Left, DefaultRowHeight * (IndentLevel - 1) - Delta);
    if ooDrawTreeRoot in Options then Inc(ARect.Left, DefaultRowHeight);
    ARect.Right := ARect.Left + Delta;
    DrawFocusCell;
    Inc(ARect.Left, Delta);
    DrawText(Node, ARect);
  end;

  procedure DrawTreePicture;
  var
    Style: TOutlineBitmap;
  begin
    DrawTree(ARect, Node);
    Inc(ARect.Left, DefaultRowHeight * (IndentLevel - 1) - Delta);
    if ooDrawTreeRoot in Options then Inc(ARect.Left, DefaultRowHeight);
    ARect.Left := ARect.Left + DefaultRowHeight;
    ARect.Right := ARect.Left + Delta;
    DrawFocusCell;
    DrawText(Node, ARect);
    Dec(ARect.Left, DefaultRowHeight - Delta);
    if HasChildren then
    begin
      if Expanded then Style := obOpen
      else Style := obClose;
    end
    else Style := obLeaf;
    Bitmap1 := GetBitmap(Style);
    DrawPictures([Bitmap1], ARect);
  end;

begin
  if FRootNode.List.Count = 0 then
  begin
    with Canvas do
    begin
      Brush.Color := Color;
      FillRect(ARect);
    end;
    Exit;
  end;

  if (Style = otOwnerDraw) and Assigned(FOnDrawItem) then
  begin
    if Row = ARow then
    begin
      if GetFocus = Self.Handle then
      begin
        FOnDrawItem(Self, ARow, ARect, [odFocused, odSelected]);
        if ooDrawFocusRect in Options then
          DrawFocusRect(Canvas.Handle, ARect);
      end
      else FOnDrawItem(Self, ARow, ARect, [odSelected])
    end
    else OnDrawItem(Self, ARow, ARect, []);
    Exit;
  end;

  InitialLeft := ARect.Left;
  Node := GetVisibleNode(ARow);
  Delta := (ARect.Bottom - ARect.Top - FFontSize) div 2;

  with Canvas do
  begin
    Font := Self.Font;
    Brush.Color := Color;
    FillRect(ARect);
    TextLength := TextWidth(Node.Text) + 1;
    if Row = ARow then
    begin
      Brush.Color := clHighlight;
      Font.Color := clHighlightText;
    end;
  end;

  Expanded := Node.Expanded;
  HasChildren := Node.HasItems;
  IndentLevel := Node.GetLevel;
  case OutlineStyle of
    osText: DrawTheText;
    osPlusMinusText: DrawPlusMinusText;
    osPlusMinusPictureText: DrawPlusMinusPicture;
    osPictureText: DrawPictureText;
    osTreeText: DrawTheTree;
    osTreePictureText: DrawTreePicture;
  end;

  if (Row = ARow) and (Node.Text <> '') then
  begin
    ARect.Left := InitialLeft + DefaultRowHeight * (IndentLevel - 1);
    if OutlineStyle >= osTreeText then
    begin
      Dec(ARect.Left, Delta);
      if ooDrawTreeRoot in Options then Inc(ARect.Left, DefaultRowHeight);
    end;
    if (OutlineStyle <> osText) and (OutlineStyle <> osTreeText) then
      Inc(ARect.Left, DefaultRowHeight);
    if OutlineStyle = osPlusMinusPictureText then
      Inc(ARect.Left, DefaultRowHeight);
    if (GetFocus = Self.Handle) and (ooDrawFocusRect in Options) then
      DrawFocusRect(Canvas.Handle, ARect);
  end;
end;

procedure TCustomOutline.DrawTree(ARect: TRect; Node: TOutlineNode);
var
  Offset: Word;
  Height: Word;
  OldPen: TPen;
  I: Integer;
  ParentNode: TOutlineNode;
  IndentLevel: Integer;
begin
  Offset := DefaultRowHeight div 2;
  Height := ARect.Bottom;
  IndentLevel := Node.GetLevel;
  I := IndentLevel - 3;
  if ooDrawTreeRoot in Options then Inc(I);
  OldPen := TPen.Create;
  try
    OldPen.Assign(Canvas.Pen);
    with Canvas do
    begin
      Pen.Color := clBlack;
      Pen.Width := 1;
      try
        ParentNode := Node.Parent;
        while (ParentNode.Parent <> nil) and
          ((ooDrawTreeRoot in Options) or
          (ParentNode.Parent.Parent <> nil)) do
        begin
          with ParentNode.Parent do
          begin
            if List.IndexOf(ParentNode) < List.Count - 1 then
            begin
              Canvas.MoveTo(ARect.Left + DefaultRowHeight * I + Offset, ARect.Top);
              Canvas.LineTo(ARect.Left + DefaultRowHeight * I + Offset, Height);
            end;
          end;
          ParentNode := ParentNode.Parent;
          Dec(I);
        end;

        with Node.Parent do
          if List.IndexOf(Node) = List.Count - 1 then
            Height := ARect.Top + Offset;

        if (ooDrawTreeRoot in Options) or (IndentLevel > 1) then
        begin
          if not (ooDrawTreeRoot in Options) then Dec(IndentLevel);
          with ARect do
          begin
            Inc(Left, DefaultRowHeight * (IndentLevel - 1));
            MoveTo(Left + Offset, Top);
            LineTo(Left + Offset, Height);
            MoveTo(Left + Offset, Top + Offset);
            LineTo(Left + Offset + FFontSize div 2, Top + Offset);
          end;
        end;
      finally
        Pen.Assign(OldPen);
      end;
    end;
  finally
    OldPen.Destroy;
  end;
end;

procedure TCustomOutline.DrawPictures(BitMaps: array of TBitmap; ARect: TRect);
var
  I: Word;
  Rect: TRect;
  Value: TBitmap;
  Offset: Word;
  Delta: Integer;
  OldTop: Integer;
  OldColor: TColor;
begin
  OldColor := Canvas.Brush.Color;
  Canvas.Brush.Color := Color;
  Offset := (DefaultRowHeight - FFontSize) div 2;
  Rect.Top := ARect.Top + Offset;
  Rect.Bottom := Rect.Top + FFontSize;
  for I := Low(Bitmaps) to High(Bitmaps) do
  begin
    Value := BitMaps[I];
    Rect.Left := ARect.Left + Offset - 1;
    Rect.Right := Rect.Left + FFontSize;
    Inc(ARect.Left, DefaultRowHeight);
    if Value <> nil then
    begin
      if not (ooStretchBitmaps in Options) then
      begin
        if Rect.Top + Value.Height < Rect.Bottom then
          Rect.Bottom := Rect.Top + Value.Height;
        if Rect.Left + Value.Width < Rect.Right then
          Rect.Right := Rect.Left + Value.Width;
        Delta := (FFontSize - (Rect.Bottom - Rect.Top)) div 2;
        if Delta > 0 then
        begin
          Delta := (DefaultRowHeight - (Rect.Bottom - Rect.Top)) div 2;
          OldTop := Rect.Top;
          Rect.Top := ARect.Top + Delta;
          Rect.Bottom := Rect.Bottom - OldTop + Rect.Top;
        end;
        Canvas.BrushCopy(Rect, Value,
          Bounds(0, 0, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top),
          Value.TransparentColor);
      end else
        Canvas.BrushCopy(Rect, Value,
          Bounds(0, 0, Value.Width, Value.Height),
          Value.TransparentColor);
    end;
  end;
  Canvas.Brush.Color := OldColor;
end;

procedure TCustomOutline.DrawText(Node: TOutlineNode; Rect: TRect);
begin
  Windows.DrawText(Canvas.Handle, PChar(Node.Text), Length(Node.Text), Rect,
    DT_LEFT or DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX);
end;

function TCustomOutline.StoreBitmap(Index: Integer): Boolean;
begin
  Result := TOutlineBitmap(Index) in FUserBitmaps;
end;

procedure TCustomOutline.ClearBitmap(var Bitmap: TBitmap; Kind: TOutlineBitmap);
begin
  if Bitmap <> nil then
  begin
    Bitmap.Free;
    Bitmap := nil;
  end;
end;

procedure TCustomOutline.ChangeBitmap(Value: TBitmap; Kind: TOutlineBitmap);
var
  Bitmap: ^TBitmap;
begin
  Bitmap := @FPictures[Ord(Kind)];
  Include(FUserBitmaps, Kind);
  if Value = nil then ClearBitmap(Bitmap^, Kind)
  else Bitmap^.Assign(Value);
  Invalidate;
end;

procedure TCustomOutline.SetPicture(Index: Integer; Value: TBitmap);
begin
  ChangeBitmap(Value, TOutlineBitmap(Index));
end;

function TCustomOutline.GetPicture(Index: Integer): TBitmap;
begin
  if csLoading in ComponentState then
    Include(FUserBitmaps, TOutlineBitmap(Index));
  Result := FPictures[Index];
end;

procedure TCustomOutline.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

{procedure TCustomOutline.SetMaskColor(Value: TColor);
begin
  FMaskColor := Value;
  Invalidate;
end;}

procedure TCustomOutline.SetItemHeight(Value: Integer);
begin
  FItemHeight := Value;
  if Style <> otOwnerDraw then SetRowHeight
  else begin
    DefaultRowHeight := ItemHeight;
    FFontSize := MulDiv(ItemHeight, 100, 120);
    Invalidate;
  end;
end;

procedure TCustomOutline.SetStyle(Value: TOutlineType);
begin
  if Style <> Value then
  begin
    FStyle := Value;
    if Value = otStandard then SetRowHeight;
  end;
end;

procedure TCustomOutline.SetOutlineOptions(Value: TOutlineOptions);
begin
  if Value <> FOptions then
  begin
    FOptions := Value;
    Invalidate;
  end;
end;

function LineStart(Buffer, BufPos: PChar): PChar;
begin
  if BufPos - Buffer - 2 > 0 then
  begin
    Dec(BufPos, 2);
    while (BufPos^ <> #$0D) and (BufPos > Buffer) do Dec(BufPos);
    if BufPos > Buffer then
    begin
      Inc(BufPos);
      if BufPos^ = #$0A then Inc(BufPos);
    end;
    Result := BufPos;
  end
  else Result := Buffer;
end;

function GetString(BufPtr: PChar; var S: string): PChar;
var
  Start: PChar;
begin
  Start := BufPtr;
  while not (BufPtr^ in [#13, #26]) do Inc(BufPtr);
  SetString(S, Start, Integer(BufPtr - Start));
  if BufPtr^ = #13 then Inc(BufPtr);
  if BufPtr^ = #10 then Inc(BufPtr);
  Result := BufPtr;
end;

procedure TCustomOutline.LoadFromStream(Stream: TStream);
const
  EOF = Chr($1A);
  BufSize = 4096;
var
  Count: Integer;
  Buffer, BufPtr, BufEnd, BufTop: PChar;
  ParentNode, NewNode: TOutlineNode;
  Str: string;
  Level, OldLevel: Cardinal;
  I: Integer;
begin
  GetMem(Buffer, BufSize);
  try
    OldLevel := 0;
    Clear;
    ParentNode := FRootNode;
    BufEnd := Buffer + BufSize;
    BufTop := BufEnd;
    repeat
      Count := BufEnd - BufTop;
      if Count <> 0 then System.Move(BufTop[0], Buffer[0], Count);
      BufTop := Buffer + Count;
      Inc(BufTop, Stream.Read(BufTop[0], BufEnd - BufTop));
      if BufTop < BufEnd then BufTop[0] := EOF else
      begin
        BufTop := LineStart(Buffer, BufTop);
        if BufTop = Buffer then Error(SOutlineLongLine);
      end;
      BufPtr := Buffer;
      while (BufPtr < BufTop) and (BufPtr[0] <> EOF) do
      begin
        BufPtr := GetBufStart(BufPtr, Level);
        BufPtr := GetString(BufPtr, Str);
        NewNode := TOutlineNode.Create(Self);
        try
          NewNode.Text := Str;
          if (Level > OldLevel) or (ParentNode = FRootNode) then
          begin
            if Level - OldLevel > 1 then Error(SOutlineFileLoad);
          end
          else
          begin
            for I := OldLevel downto Level do
            begin
              ParentNode := ParentNode.Parent;
              if ParentNode = nil then Error(SOutlineFileLoad);
            end;
          end;
          ParentNode.List.Add(NewNode);
          NewNode.FParent := ParentNode;
          ParentNode := NewNode;
          OldLevel := Level;
        except
          NewNode.Free;
          Raise;
        end;
      end;
    until (BufPtr < BufEnd) and (BufPtr[0] = EOF);
  finally
    FreeMem(Buffer, BufSize);
    if not (csLoading in ComponentState) then Loaded;
  end;
end;

procedure TCustomOutline.Loaded;
var
  Item: TOutlineBitmap;
begin
  inherited Loaded;
  with FRootNode do
  begin
    FExpandCount := List.Count;
    Row := 0;
    ResetSelectedItem;
    if ResizeGrid then Invalidate;
    if List.Count > 0 then
    begin
      TOutlineNode(List.First).SetGoodIndex;
      FSelectedItem := List.First;
    end;
    if csDesigning in ComponentState then FullExpand;
  end;
  for Item := obPlus to obLeaf do
    if (Item in FOldBitmaps) and not (Item in FUserBitmaps) then
      ChangeBitmap(nil, Item);
  FOldBitmaps := [];
  SetHorzScrollBar;
end;

procedure TCustomOutline.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCustomOutline.SaveToStream(Stream: TStream);
const
  BufSize = 4096;
var
  Buffer: PChar;
begin
  GetMem(Buffer, BufSize);
  try
    FRootNode.WriteNode(Buffer, Stream);
  finally
    FreeMem(Buffer, BufSize);
  end;
end;

procedure TCustomOutline.SetStrings(Value: TStrings);
begin
  FStrings.Assign(Value);
  if csDesigning in ComponentState then FRootNode.FullExpand;
  SetHorzScrollBar;
end;

function TCustomOutline.GetStrings: TStrings;
begin
  Result := FStrings;
end;

procedure TCustomOutline.Error(const ErrorString: string);
begin
  Raise EOutlineError.Create(ErrorString);
end;

procedure TCustomOutline.Expand(Index: LongInt);
begin
  if Assigned(FOnExpand) then FOnExpand(Self, Index);
end;

procedure TCustomOutline.Collapse(Index: LongInt);
begin
  if Assigned(FOnCollapse) then FOnCollapse(Self, Index);
end;

end.
