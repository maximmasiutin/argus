object OvrExplainForm: TOvrExplainForm
  Left = 20
  Top = 117
  HelpContext = 2100
  BorderStyle = bsDialog
  BorderWidth = 6
  ClientHeight = 214
  ClientWidth = 568
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object bOK: TButton
    Left = 296
    Top = 180
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object bCancel: TButton
    Left = 376
    Top = 180
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object bHelp: TButton
    Left = 456
    Top = 180
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 2
    OnClick = bHelpClick
  end
  object gOvr: TAdvGrid
    Left = 0
    Top = 0
    Width = 568
    Height = 169
    FixedFont.Charset = DEFAULT_CHARSET
    FixedFont.Color = clWindowText
    FixedFont.Height = -11
    FixedFont.Name = 'MS Sans Serif'
    FixedFont.Style = []
    Align = alTop
    ColCount = 4
    DefaultRowHeight = 18
    RowCount = 2
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowMoving, goColMoving, goEditing, goDigitalRows]
    ParentFont = False
    TabOrder = 3
    ColWidths = (
      31
      154
      151
      209)
  end
end
