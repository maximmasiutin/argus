unit PathName;

{$I DEFINE.INC}


interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, mGrids, MClasses;

type
  TPathNamesForm = class(TForm)
    gSpec: TAdvGrid;
    gbHomeDir: TGroupBox;
    lHomeDir: TLabel;
    bChangeHomeDir: TButton;
    bBrowse: TButton;
    bOK: TButton;
    bCancel: TButton;
    bHelp: TButton;
    llSpecial: TLabel;
    llDefZone: TLabel;
    ZoneSpin: TxSpinEdit;
    procedure FormActivate(Sender: TObject);
    procedure bChangeHomeDirClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure bHelpClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Activated: Boolean;
    Crc32: DWORD;
    procedure SetData;
    procedure UpdateConfig;
  public
    { Public declarations }
  end;

function SetupPathNames: Boolean;

implementation uses xBase, SelDir, Recs, LngTools;

{$R *.DFM}

procedure TPathNamesForm.FormActivate(Sender: TObject);
begin
  if not Activated then
  begin
    GridFillRowLng(gSpec, rsPNgrid);
    Activated := True;
  end;
end;

procedure TPathNamesForm.bChangeHomeDirClick(Sender: TObject);
var
  s: string;                      
begin
  s := Trim(SelectDirectory(LngStr(rsPNchd), HomeDir, ''));
  if s = '' then Exit;
  s := ExpandFileName(s);
  if not SetRegHomeDir(s) then begin DisplayErrorLng(rsCantUpdateReg, Handle); Exit end;
  lHomeDir.Caption := s;
  if UpperCase(MakeNormName(s, '')) = UpperCase(MakeNormName(HomeDir, '')) then Exit;
  { And now exit! }
  UpdateConfig;
  DisplayInfoLng(rsPNHdc, Handle);
  PostCloseMessage;
end;


procedure TPathNamesForm.SetData;
begin
  lHomeDir.Caption := HomeDir;
  ZoneSpin.Value := Cfg.PathNames.DefaultZone;
  gSpec.SetData([Cfg.PathNames]);
  Crc32 := Cfg.PathNames.Crc32(CRC32_INIT) xor Cfg.PathNames.DefaultZone;
end;

function SetupPathNames;
var
  PathNamesForm: TPathNamesForm;
begin
  PathNamesForm := TPathNamesForm.Create(Application);
  PathNamesForm.SetData;
  Result := PathNamesForm.ShowModal = mrOK;
  FreeObject(PathNamesForm);
end;

procedure TPathNamesForm.UpdateConfig;
begin
  gSpec.GetData([Cfg.PathNames]);
  Cfg.PathNames.DefaultZone := ZoneSpin.Value;
  if Crc32 = Cfg.PathNames.Crc32(CRC32_INIT) xor Cfg.PathNames.DefaultZone then Exit;
  StoreConfig(Handle);
end;

procedure TPathNamesForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult <> mrOK then Exit;
  UpdateConfig;
end;

procedure TPathNamesForm.bHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TPathNamesForm.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsPathNamesForm);
end;

end.
