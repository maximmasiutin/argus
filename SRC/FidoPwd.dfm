object PwdForm: TPwdForm
  Left = 240
  Top = 172
  HelpContext = 1020
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Node Passwords'
  ClientHeight = 295
  ClientWidth = 448
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lAuxPwds: TLabel
    Left = 56
    Top = 222
    Width = 107
    Height = 13
    Alignment = taRightJustify
    Caption = 'Au&xiliary passwords file'
    FocusControl = eAuxPwds
  end
  object bOK: TButton
    Left = 208
    Top = 260
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object bCancel: TButton
    Left = 288
    Top = 260
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object bHelp: TButton
    Left = 368
    Top = 260
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 6
    OnClick = bHelpClick
  end
  object gPsw: TAdvGrid
    Left = 0
    Top = 0
    Width = 448
    Height = 209
    FixedFont.Charset = DEFAULT_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'MS Sans Serif'
    FixedFont.Style = []
    Align = alTop
    ColCount = 3
    DefaultRowHeight = 18
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowMoving, goEditing, goThumbTracking, goDigitalRows]
    ParentFont = False
    TabOrder = 0
    ColWidths = (
      31
      267
      127)
  end
  object bImportPwd: TButton
    Left = 12
    Top = 260
    Width = 75
    Height = 23
    Caption = 'Im&port...'
    TabOrder = 2
    OnClick = bImportPwdClick
  end
  object bSort: TButton
    Left = 92
    Top = 260
    Width = 75
    Height = 23
    Caption = '&Sort'
    TabOrder = 3
    OnClick = bSortClick
  end
  object eAuxPwds: TEdit
    Left = 168
    Top = 218
    Width = 280
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
end
