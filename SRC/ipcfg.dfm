object IPcfgForm: TIPcfgForm
  Left = 146
  Top = 81
  HelpContext = 1240
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'TCP/IP Daemon  Configuration'
  ClientHeight = 288
  ClientWidth = 528
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
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object bOK: TButton
    Left = 447
    Top = 20
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 447
    Top = 48
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 447
    Top = 76
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
  object tb: TPageControl
    Left = 0
    Top = 0
    Width = 437
    Height = 288
    ActivePage = lGeneral
    Align = alLeft
    MultiLine = True
    TabOrder = 0
    OnChange = tbChange
    object lGeneral: TTabSheet
      BorderWidth = 6
      Caption = 'General'
      object bvlSOCKS: TBevel
        Left = 0
        Top = 185
        Width = 417
        Height = 63
        Align = alBottom
        Shape = bsFrame
      end
      object llInPorts: TLabel
        Left = 0
        Top = 0
        Width = 69
        Height = 13
        Caption = 'Incoming ports'
      end
      object llAssumeSpeed: TLabel
        Left = 338
        Top = 108
        Width = 69
        Height = 13
        Alignment = taRightJustify
        Caption = 'Assume speed'
        FocusControl = spSP
      end
      object llSocksAddr: TLabel
        Left = 22
        Top = 220
        Width = 38
        Height = 13
        Alignment = taRightJustify
        Caption = '&Address'
        FocusControl = lSocksAddr
      end
      object llSocksPort: TLabel
        Left = 333
        Top = 220
        Width = 19
        Height = 13
        Alignment = taRightJustify
        Caption = '&Port'
        FocusControl = lSocksPort
      end
      object gIn: TAdvGrid
        Left = 0
        Top = 21
        Width = 286
        Height = 80
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clBlack
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
        ColCount = 2
        DefaultRowHeight = 18
        RowCount = 4
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedNumCols]
        ParentFont = False
        TabOrder = 0
        ColWidths = (
          77
          203)
      end
      object llLimit: TGroupBox
        Left = 298
        Top = 11
        Width = 112
        Height = 89
        Caption = 'Max connections'
        TabOrder = 1
        object llCin: TLabel
          Left = 35
          Top = 24
          Width = 9
          Height = 13
          Alignment = taRightJustify
          Caption = '&In'
          FocusControl = spIn
        end
        object llCout: TLabel
          Left = 27
          Top = 56
          Width = 17
          Height = 13
          Alignment = taRightJustify
          Caption = '&Out'
          FocusControl = spOut
        end
        object spIn: TxSpinEdit
          Left = 52
          Top = 20
          Width = 49
          Height = 22
          Increment = 4
          MaxValue = 4096
          MinValue = 0
          TabOrder = 0
          Value = 16
        end
        object spOut: TxSpinEdit
          Left = 52
          Top = 52
          Width = 49
          Height = 22
          MaxValue = 1024
          MinValue = 0
          TabOrder = 1
          Value = 4
        end
      end
      object spSP: TxSpinEdit
        Left = 336
        Top = 124
        Width = 73
        Height = 22
        Increment = 300
        MaxLength = 9
        MaxValue = 99999999
        MinValue = 30
        TabOrder = 2
        Value = 99999999
      end
      object cbSOCKS: TCheckBox
        Left = 24
        Top = 194
        Width = 273
        Height = 17
        Caption = 'Use &SOCKS4 proxy for outgoing connections'
        TabOrder = 3
        OnClick = cbSOCKSClick
      end
      object lSocksAddr: TEdit
        Left = 72
        Top = 216
        Width = 249
        Height = 21
        TabOrder = 4
      end
      object lSocksPort: TEdit
        Left = 358
        Top = 216
        Width = 49
        Height = 21
        TabOrder = 5
      end
    end
    object lStation: TTabSheet
      BorderWidth = 6
      Caption = 'Station'
      object gTpl: TAdvGrid
        Left = 0
        Top = 0
        Width = 417
        Height = 118
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clBlack
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
        Align = alTop
        ColCount = 2
        DefaultRowHeight = 18
        RowCount = 6
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goFixedNumCols]
        ParentFont = False
        TabOrder = 0
        ColWidths = (
          105
          306)
      end
    end
    object lAKA: TTabSheet
      BorderWidth = 6
      Caption = 'AKA'
      object gAKA: TAdvGrid
        Left = 0
        Top = 0
        Width = 417
        Height = 248
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
        Align = alClient
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
          160
          202)
      end
    end
    object lBanner: TTabSheet
      BorderWidth = 6
      Caption = 'Banner'
      object eBan: TMemo
        Left = 0
        Top = 0
        Width = 417
        Height = 248
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
    end
    object lRestrict: TTabSheet
      Tag = 8767
      BorderWidth = 2
      Caption = 'Restrictions'
      object p: TPageControl
        Left = 0
        Top = 0
        Width = 425
        Height = 256
        ActivePage = tsRequired
        Align = alClient
        MultiLine = True
        TabOrder = 0
        TabPosition = tpBottom
        object tsRequired: TTabSheet
          BorderWidth = 6
          Caption = 'Required'
          object gReqd: TAdvGrid
            Left = 0
            Top = 0
            Width = 405
            Height = 216
            FixedFont.Charset = DEFAULT_CHARSET
            FixedFont.Color = clWindowText
            FixedFont.Height = -11
            FixedFont.Name = 'MS Sans Serif'
            FixedFont.Style = []
            Align = alClient
            ColCount = 2
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
              350)
          end
        end
        object tsForbidden: TTabSheet
          BorderWidth = 6
          Caption = 'Forbidden'
          object gForb: TAdvGrid
            Left = 0
            Top = 0
            Width = 405
            Height = 216
            FixedFont.Charset = DEFAULT_CHARSET
            FixedFont.Color = clWindowText
            FixedFont.Height = -11
            FixedFont.Name = 'MS Sans Serif'
            FixedFont.Style = []
            Align = alClient
            ColCount = 2
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
              350)
          end
        end
      end
    end
    object lEvents: TTabSheet
      BorderWidth = 6
      Caption = 'Events'
      object labelAvl: TLabel
        Left = 0
        Top = 0
        Width = 43
        Height = 13
        Caption = '&Available'
        FocusControl = lAvl
      end
      object labelLinked: TLabel
        Left = 228
        Top = 0
        Width = 32
        Height = 13
        Caption = '&Linked'
        FocusControl = lLnk
      end
      object bRight: TSpeedButton
        Left = 196
        Top = 32
        Width = 25
        Height = 25
        Hint = 'Add'
        Caption = '&>'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = bRightClick
      end
      object bLeft: TSpeedButton
        Left = 196
        Top = 60
        Width = 25
        Height = 25
        Hint = 'Delete'
        Caption = '&<'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = bLeftClick
      end
      object bEdit: TSpeedButton
        Left = 196
        Top = 128
        Width = 25
        Height = 25
        Hint = 'Edit Events'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000000
          000033333377777777773333330FFFFFFFF03FF3FF7FF33F3FF700300000FF0F
          00F077F777773F737737E00BFBFB0FFFFFF07773333F7F3333F7E0BFBF000FFF
          F0F077F3337773F3F737E0FBFBFBF0F00FF077F3333FF7F77F37E0BFBF00000B
          0FF077F3337777737337E0FBFBFBFBF0FFF077F33FFFFFF73337E0BF0000000F
          FFF077FF777777733FF7000BFB00B0FF00F07773FF77373377373330000B0FFF
          FFF03337777373333FF7333330B0FFFF00003333373733FF777733330B0FF00F
          0FF03333737F37737F373330B00FFFFF0F033337F77F33337F733309030FFFFF
          00333377737FFFFF773333303300000003333337337777777333}
        NumGlyphs = 2
        ParentShowHint = False
        ShowHint = True
        OnClick = bEditClick
      end
      object lAvl: TListBox
        Left = 0
        Top = 16
        Width = 188
        Height = 232
        ItemHeight = 13
        TabOrder = 0
        OnClick = lAvlClick
        OnDblClick = lAvlDblClick
        OnKeyPress = lAvlKeyPress
      end
      object lLnk: TListBox
        Left = 229
        Top = 16
        Width = 188
        Height = 232
        ItemHeight = 13
        TabOrder = 1
        OnClick = lAvlClick
        OnDblClick = lLnkDblClick
        OnKeyPress = lLnkKeyPress
      end
    end
    object lDNS: TTabSheet
      BorderWidth = 6
      Caption = 'DNS'
      object gDNS: TAdvGrid
        Left = 0
        Top = 0
        Width = 417
        Height = 248
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
        Align = alClient
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
          236
          127)
      end
    end
    object lNodes: TTabSheet
      Tag = 8769
      BorderWidth = 6
      Caption = 'Nodes'
      object lAuxNodes: TLabel
        Left = 45
        Top = 227
        Width = 86
        Height = 13
        Alignment = taRightJustify
        Caption = 'Auxiliary nodes file'
        FocusControl = eAuxNode
      end
      object gOvr: TAdvGrid
        Left = 0
        Top = 0
        Width = 417
        Height = 214
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
          100
          263)
      end
      object eAuxNode: TEdit
        Left = 137
        Top = 223
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
  end
  object bImport: TButton
    Left = 447
    Top = 140
    Width = 75
    Height = 23
    Caption = '&Import...'
    TabOrder = 5
    Visible = False
    OnClick = bImportClick
  end
  object bSort: TButton
    Left = 447
    Top = 168
    Width = 75
    Height = 23
    Caption = '&Sort'
    TabOrder = 6
    Visible = False
    OnClick = bSortClick
  end
  object bEditNode: TButton
    Left = 447
    Top = 112
    Width = 75
    Height = 23
    Caption = 'Edit'
    TabOrder = 4
    Visible = False
    OnClick = bEditNodeClick
  end
  object bExplain: TButton
    Left = 447
    Top = 112
    Width = 75
    Height = 23
    Caption = 'Explain...'
    TabOrder = 7
    Visible = False
    OnClick = bExplainClick
  end
end
