object FReqDlg: TFReqDlg
  Left = 219
  Top = 109
  HelpContext = 2170
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Make/Edit File Request'
  ClientHeight = 170
  ClientWidth = 322
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
  object gFiles: TAdvGrid
    Left = 0
    Top = 0
    Width = 225
    Height = 170
    FixedFont.Charset = DEFAULT_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'MS Sans Serif'
    FixedFont.Style = []
    Align = alLeft
    ColCount = 3
    DefaultRowHeight = 18
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goThumbTracking, goDigitalRows]
    ParentFont = False
    TabOrder = 0
    ColWidths = (
      30
      90
      83)
  end
  object bOK: TButton
    Left = 239
    Top = 14
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 239
    Top = 42
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 239
    Top = 70
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
end
