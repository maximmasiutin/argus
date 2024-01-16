object StartupConfigForm: TStartupConfigForm
  Left = 197
  Top = 30
  HelpContext = 1320
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Start-up Configuration'
  ClientHeight = 325
  ClientWidth = 308
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object gbLines: TGroupBox
    Left = 0
    Top = 0
    Width = 308
    Height = 185
    Align = alTop
    Caption = '&Dial-up Lines'
    TabOrder = 0
    object llManual: TLabel
      Left = 20
      Top = 16
      Width = 62
      Height = 13
      Caption = '&Manual-open'
    end
    object lRight: TSpeedButton
      Left = 140
      Top = 40
      Width = 25
      Height = 25
      Caption = '&>'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      OnClick = lRightClick
    end
    object lLeft: TSpeedButton
      Left = 140
      Top = 76
      Width = 25
      Height = 25
      Caption = '&<'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      OnClick = lLeftClick
    end
    object llAuto: TLabel
      Left = 180
      Top = 16
      Width = 49
      Height = 13
      Caption = '&Auto-open'
    end
    object lbManual: TListBox
      Left = 12
      Top = 32
      Width = 120
      Height = 137
      ItemHeight = 13
      TabOrder = 0
      OnDblClick = lbManualDblClick
      OnKeyPress = lbManualKeyPress
    end
    object lbAuto: TListBox
      Left = 172
      Top = 32
      Width = 120
      Height = 137
      ItemHeight = 13
      TabOrder = 1
      OnDblClick = lbAutoClick
      OnKeyPress = lbAutoKeyPress
    end
  end
  object cbDaemon: TCheckBox
    Left = 8
    Top = 196
    Width = 289
    Height = 17
    Caption = 'Auto-run &TCP/IP Daemon'
    TabOrder = 1
    Visible = False
  end
  object bOK: TButton
    Left = 60
    Top = 284
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object bCancel: TButton
    Left = 144
    Top = 284
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object bHelp: TButton
    Left = 228
    Top = 284
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 6
    OnClick = bHelpClick
  end
  object cbFastLog: TCheckBox
    Left = 8
    Top = 216
    Width = 289
    Height = 17
    Caption = '&Fast logging'
    TabOrder = 2
  end
  object cbLogWZ: TCheckBox
    Left = 8
    Top = 236
    Width = 289
    Height = 17
    Caption = 'Log &WZ pending/incomplete'
    TabOrder = 3
  end
  object cbODBCLog: TCheckBox
    Left = 8
    Top = 256
    Width = 289
    Height = 17
    Caption = '&ODBC logging'
    TabOrder = 7
  end
end
