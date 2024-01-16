object DeviceConfig: TDeviceConfig
  Left = 284
  Top = 125
  HelpContext = 1080
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Port Configuration'
  ClientHeight = 122
  ClientWidth = 383
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 282
    Top = 11
    Width = 89
    Height = 56
    Shape = bsFrame
  end
  object lComPort: TLabel
    Left = 18
    Top = 16
    Width = 46
    Height = 13
    Alignment = taRightJustify
    Caption = 'COM &Port'
    FocusControl = cbCom
  end
  object lRate: TLabel
    Left = 22
    Top = 48
    Width = 42
    Height = 13
    Alignment = taRightJustify
    Caption = '&BPS rate'
    FocusControl = cbSpeed
  end
  object llBits: TLabel
    Left = 304
    Top = 18
    Width = 20
    Height = 13
    Alignment = taRightJustify
    Caption = 'Bits:'
  end
  object lBits: TLabel
    Left = 326
    Top = 18
    Width = 24
    Height = 13
    Caption = '8N1'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object cbCom: TComboBox
    Left = 72
    Top = 12
    Width = 81
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    Items.Strings = (
      'COM1'
      'COM2'
      'COM3'
      'COM4'
      'COM5'
      'COM6'
      'COM7'
      'COM8'
      'COM9'
      'COM10'
      'COM11'
      'COM12'
      'COM13'
      'COM14'
      'COM15'
      'COM16'
      'COM17'
      'COM18'
      'COM19'
      'COM20'
      'COM21'
      'COM22'
      'COM23'
      'COM24'
      'COM25'
      'COM26'
      'COM27'
      'COM28'
      'COM29'
      'COM30'
      'COM31'
      'COM32')
  end
  object cbSpeed: TComboBox
    Left = 72
    Top = 44
    Width = 81
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    OnKeyPress = cbSpeedKeyPress
    Items.Strings = (
      '9600'
      '14400'
      '19200'
      '38400'
      '56000'
      '57600'
      '115200'
      '128000'
      '256000')
  end
  object gFlow: TGroupBox
    Left = 164
    Top = 6
    Width = 105
    Height = 60
    Caption = '&Flow control'
    TabOrder = 2
    object cbCTS_RTS: TCheckBox
      Left = 8
      Top = 17
      Width = 73
      Height = 17
      Caption = 'CTS/&RTS'
      TabOrder = 0
    end
    object cbXon_Xoff: TCheckBox
      Left = 8
      Top = 37
      Width = 73
      Height = 17
      Caption = 'XOn/&XOff'
      TabOrder = 1
    end
  end
  object bBits: TButton
    Left = 293
    Top = 37
    Width = 69
    Height = 22
    Caption = '&Change...'
    TabOrder = 3
    OnClick = bBitsClick
  end
  object bOK: TButton
    Left = 128
    Top = 84
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object bCancel: TButton
    Left = 208
    Top = 84
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object bHelp: TButton
    Left = 288
    Top = 84
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 6
    OnClick = bHelpClick
  end
end
