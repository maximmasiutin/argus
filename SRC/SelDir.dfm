object SelectDirDialog: TSelectDirDialog
  Left = 234
  Top = 70
  BorderStyle = bsDialog
  Caption = 'Browse directories'
  ClientHeight = 280
  ClientWidth = 308
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object llDrive: TLabel
    Left = 8
    Top = 232
    Width = 28
    Height = 13
    Caption = 'Dri&ve:'
    FocusControl = DriveBox
  end
  object llDirs: TLabel
    Left = 8
    Top = 56
    Width = 50
    Height = 13
    Caption = '&Directories'
    FocusControl = DirBox
  end
  object llSelect: TLabel
    Left = 8
    Top = 8
    Width = 33
    Height = 13
    Caption = '&Select:'
  end
  object DirBox: TDirectoryListBox
    Left = 8
    Top = 72
    Width = 209
    Height = 153
    ItemHeight = 16
    TabOrder = 0
    OnChange = DirBoxChange
    OnClick = DirBoxChange
  end
  object DriveBox: TDriveComboBox
    Left = 8
    Top = 248
    Width = 209
    Height = 19
    DirList = DirBox
    TabOrder = 1
  end
  object bOK: TButton
    Left = 228
    Top = 24
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 2
    OnClick = bOKClick
  end
  object bCancel: TButton
    Left = 228
    Top = 52
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object eDir: TEdit
    Left = 8
    Top = 24
    Width = 209
    Height = 21
    TabOrder = 4
    OnChange = eDirChange
    OnKeyPress = eDirKeyPress
  end
end
