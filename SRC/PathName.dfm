object PathNamesForm: TPathNamesForm
  Left = 276
  Top = 71
  HelpContext = 1670
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Path Names'
  ClientHeight = 246
  ClientWidth = 354
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object llSpecial: TLabel
    Left = 13
    Top = 88
    Width = 86
    Height = 13
    Caption = '&Special directories'
  end
  object llDefZone: TLabel
    Left = 185
    Top = 68
    Width = 108
    Height = 13
    Alignment = taRightJustify
    Caption = 'Outbound default zone'
  end
  object gSpec: TAdvGrid
    Left = 9
    Top = 104
    Width = 337
    Height = 98
    FixedFont.Charset = DEFAULT_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'MS Sans Serif'
    FixedFont.Style = []
    ColCount = 2
    DefaultRowHeight = 18
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goFixedNumCols]
    ParentFont = False
    TabOrder = 2
    ColWidths = (
      107
      224)
  end
  object gbHomeDir: TGroupBox
    Left = 0
    Top = 0
    Width = 354
    Height = 45
    Align = alTop
    Caption = '&Home directory'
    TabOrder = 0
    object lHomeDir: TLabel
      Left = 8
      Top = 18
      Width = 257
      Height = 17
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
    end
    object bChangeHomeDir: TButton
      Left = 272
      Top = 12
      Width = 76
      Height = 23
      Caption = '&Change...'
      TabOrder = 0
      OnClick = bChangeHomeDirClick
    end
  end
  object bBrowse: TButton
    Left = 12
    Top = 216
    Width = 75
    Height = 23
    Caption = '&Browse...'
    TabOrder = 3
    Visible = False
  end
  object bOK: TButton
    Left = 108
    Top = 216
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object bCancel: TButton
    Left = 188
    Top = 216
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object bHelp: TButton
    Left = 268
    Top = 216
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 6
    OnClick = bHelpClick
  end
  object ZoneSpin: TxSpinEdit
    Left = 300
    Top = 64
    Width = 53
    Height = 22
    MaxValue = 4095
    MinValue = 1
    TabOrder = 1
    Value = 2
  end
end
