object NodelistBrowser: TNodelistBrowser
  Left = 195
  Top = 14
  HelpContext = 1970
  ActiveControl = eAddress
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Browse The Nodelist'
  ClientHeight = 445
  ClientWidth = 514
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Tree: TTreeView
    Left = 0
    Top = 0
    Width = 514
    Height = 284
    Align = alTop
    ChangeDelay = 50
    Indent = 19
    ReadOnly = True
    RightClickSelect = True
    TabOrder = 0
    OnChange = TreeChange
    OnClick = TreeClick
    OnCollapsed = TreeCollapsed
    OnExpanding = TreeExpanding
    OnExpanded = TreeExpanded
  end
  object pnInfo: TPanel
    Left = 1
    Top = 287
    Width = 512
    Height = 154
    BevelOuter = bvNone
    TabOrder = 1
    object llAddr: TLabel
      Left = 8
      Top = 8
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Address'
      FocusControl = lAddress
    end
    object llStat: TLabel
      Left = 8
      Top = 24
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Station'
      FocusControl = lStation
    end
    object llSysop: TLabel
      Left = 8
      Top = 40
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'SysOp'
      FocusControl = lSysop
    end
    object llSite: TLabel
      Left = 8
      Top = 56
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Location'
      FocusControl = lLocation
    end
    object llPhn: TLabel
      Left = 8
      Top = 72
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = #39'Phone'
      FocusControl = lPhone
    end
    object llSpd: TLabel
      Left = 8
      Top = 88
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Speed'
      FocusControl = lSpeed
    end
    object llFlags: TLabel
      Left = 8
      Top = 104
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Flags'
      FocusControl = lFlags
    end
    object llWrkTimeUTC: TLabel
      Left = 8
      Top = 120
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Time (UTC)'
      FocusControl = lWrkTimeUTC
    end
    object llAddrSearch: TLabel
      Left = 368
      Top = 0
      Width = 76
      Height = 13
      Caption = '&Address search'
      FocusControl = eAddress
    end
    object llWrlTimeLocal: TLabel
      Left = 8
      Top = 136
      Width = 90
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'Time (Local)'
      FocusControl = lWrkTimeLocal
    end
    object eAddress: TEdit
      Left = 368
      Top = 16
      Width = 140
      Height = 21
      DragCursor = crHandPoint
      TabOrder = 0
      OnChange = eAddressChange
      OnKeyPress = eAddressKeyPress
    end
    object lAddress: TEdit
      Left = 100
      Top = 8
      Width = 177
      Height = 13
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 1
    end
    object lStation: TEdit
      Left = 100
      Top = 24
      Width = 261
      Height = 13
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 2
    end
    object lSysop: TEdit
      Left = 100
      Top = 40
      Width = 261
      Height = 13
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 3
    end
    object lLocation: TEdit
      Left = 100
      Top = 56
      Width = 320
      Height = 13
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 4
    end
    object lPhone: TEdit
      Left = 100
      Top = 72
      Width = 320
      Height = 13
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 5
    end
    object lSpeed: TEdit
      Left = 100
      Top = 88
      Width = 320
      Height = 13
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 6
    end
    object lFlags: TEdit
      Left = 100
      Top = 104
      Width = 320
      Height = 13
      TabStop = False
      AutoSize = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 7
    end
    object lWrkTimeUTC: TEdit
      Left = 100
      Top = 120
      Width = 320
      Height = 13
      TabStop = False
      AutoSize = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 8
    end
    object lStatus: TEdit
      Left = 288
      Top = 8
      Width = 61
      Height = 13
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 9
    end
    object lWrkTimeLocal: TEdit
      Left = 100
      Top = 136
      Width = 320
      Height = 13
      TabStop = False
      AutoSize = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = True
      ParentFont = False
      ReadOnly = True
      TabOrder = 10
    end
  end
  object bOK: TButton
    Left = 432
    Top = 336
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object bCancel: TButton
    Left = 432
    Top = 364
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object bHelp: TButton
    Left = 432
    Top = 392
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 4
    OnClick = bHelpClick
  end
end
