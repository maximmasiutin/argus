object ModemCmdForm: TModemCmdForm
  Left = 241
  Top = 183
  HelpContext = 2180
  BorderStyle = bsDialog
  Caption = 'Send Modem Commands'
  ClientHeight = 101
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lModemCommand: TLabel
    Left = 16
    Top = 8
    Width = 85
    Height = 13
    Caption = 'Modem Command'
  end
  object eModemCommand: THistoryLine
    Left = 16
    Top = 24
    Width = 305
    Height = 24
    HistoryID = 333
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    OnChange = eModemCommandChange
  end
  object bSend: TButton
    Left = 84
    Top = 64
    Width = 75
    Height = 23
    Caption = '&Send'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = bSendClick
  end
  object bClose: TButton
    Left = 164
    Top = 64
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 244
    Top = 64
    Width = 75
    Height = 23
    HelpContext = 1220
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
end
