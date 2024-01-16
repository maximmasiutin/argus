object LineBitsEditor: TLineBitsEditor
  Left = 218
  Top = 122
  HelpContext = 1770
  BorderStyle = bsDialog
  Caption = 'Line bits settings'
  ClientHeight = 139
  ClientWidth = 293
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object cData: TRadioGroup
    Left = 104
    Top = 8
    Width = 89
    Height = 57
    Caption = 'Data bits'
    Columns = 2
    Items.Strings = (
      '&8'
      '&7'
      '&6'
      '&5')
    TabOrder = 0
  end
  object cParity: TRadioGroup
    Left = 8
    Top = 8
    Width = 89
    Height = 121
    Caption = 'Parity'
    Items.Strings = (
      '&None'
      '&Odd'
      '&Even'
      '&Mark'
      '&Space')
    TabOrder = 1
  end
  object cStop: TRadioGroup
    Left = 104
    Top = 72
    Width = 89
    Height = 57
    Caption = 'Stop bits'
    Columns = 2
    Items.Strings = (
      '&1'
      '1.5'
      '&2')
    TabOrder = 2
  end
  object bOK: TButton
    Left = 208
    Top = 12
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object bCancel: TButton
    Left = 208
    Top = 40
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object bHelp: TButton
    Left = 208
    Top = 68
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 5
    OnClick = bHelpClick
  end
end
