unit SelDir;

{$I DEFINE.INC}


interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, FileCtrl; 

type
  TSelectDirDialog = class(TForm)
    DirBox: TDirectoryListBox;
    DriveBox: TDriveComboBox;
    bOK: TButton;
    bCancel: TButton;
    llDrive: TLabel;
    llDirs: TLabel;
    eDir: TEdit;
    llSelect: TLabel;
    procedure DirBoxChange(Sender: TObject);
    procedure eDirChange(Sender: TObject);
    procedure eDirKeyPress(Sender: TObject; var Key: Char);
    procedure bOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  SelectDirDialog: TSelectDirDialog;

function SelectDirectory(const Title, Default, HomeDir: String): String;

implementation
uses xBase, Recs, LngTools;

{$R *.DFM}

function SelectDirectory;

function FullPath(const Dir: string): string;
begin
  Result := MakeFullDir(HomeDir, Dir);
end;

  var D:  TSelectDirDialog;
      S: string;
begin
  Result := '';
  D := TSelectDirDialog.Create(Application);
  if Default <> '' then
  begin
    S := Copy(FullPath(Default),1,1);
    D.DriveBox.Drive := S[1];
    if (DirExists(FullPath(Default))=1) or CreateDirInheritance(FullPath(Default)) then
      D.DirBox.Directory := FullPath(Default); 
  end;
  D.eDir.Text := D.DirBox.Directory;
  if Title <> '' then D.Caption := Title;
  if D.ShowModal = mrOK then Result := D.eDir.Text;
  S := ExtractDir(HomeDir);
  if Copy(Result, 1, Length(S)) = S then Delete(Result, 1, Length(S));
  D.Free;
end;

procedure TSelectDirDialog.DirBoxChange(Sender: TObject);
begin
  eDir.Text := DirBox.GetItemPath(DirBox.ItemIndex);
end;

procedure TSelectDirDialog.eDirChange(Sender: TObject);
  var S: String;
begin
  S := eDir.Text;
  bOK.Enabled := (S <> '') and (S[Length(S)] <> ':');
end;

procedure TSelectDirDialog.eDirKeyPress(Sender: TObject; var Key: Char);
  var S: String;
      L: Integer;
begin
  if Key = #13 then
   begin
     S := eDir.Text;
     L := Length(S);
     if (S[2] = ':') and (GetDriveType(PChar(S[1]+':\')) in [0,1]) then
       begin
         DisplayErrorLng(rsSDidn, Handle);
         Key := #0;
         Exit;
       end;
     if (L = 2) and (S[2] = ':') then
       begin
         DriveBox.Drive := S[1];
         Key := #0;
         Exit
       end;
     if (L = 3) and (Copy(S, 2, 2)=':\') then Exit;
     case DirExists(S) of
       0: if not CreateDirInheritance(S) then Key := #0;
      -1: begin
            DisplayErrorLng(rsSDidn, Handle);
            Key := #0;
          end;
     end;
   end;
end;

procedure TSelectDirDialog.bOKClick(Sender: TObject);
  var C: Char;
begin
  C := #13;
  eDirKeyPress(Sender, C);
  if C = #0 then ModalResult := mrNone;
end;

procedure TSelectDirDialog.FormCreate(Sender: TObject);
begin
  FillForm(Self, rsSelectDirDialog);
end;

end.

//pathname
