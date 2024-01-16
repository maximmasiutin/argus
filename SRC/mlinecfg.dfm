object MailerLineCfgForm: TMailerLineCfgForm
  Left = 211
  Top = 58
  HelpContext = 1060
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Mailer line configuration'
  ClientHeight = 269
  ClientWidth = 400
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
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object bOK: TButton
    Left = 148
    Top = 238
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 228
    Top = 238
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 308
    Top = 238
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 400
    Height = 229
    ActivePage = pgGeneral
    Align = alTop
    TabOrder = 0
    object pgGeneral: TTabSheet
      Caption = 'General'
      object llStation: TLabel
        Left = 4
        Top = 40
        Width = 81
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '&Station'
        FocusControl = cbStation
      end
      object llName: TLabel
        Left = 4
        Top = 16
        Width = 83
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Line &name'
        FocusControl = lName
      end
      object llPort: TLabel
        Left = 4
        Top = 64
        Width = 81
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '&Port'
        FocusControl = cbPort
      end
      object llModem: TLabel
        Left = 4
        Top = 88
        Width = 81
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '&Modem'
        FocusControl = cbModem
      end
      object llRestr: TLabel
        Left = 4
        Top = 112
        Width = 81
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '&Restrictions'
        FocusControl = cbRestrict
      end
      object llLog: TLabel
        Left = 4
        Top = 140
        Width = 81
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '&Log file'
        FocusControl = lLog
      end
      object llFaxIn: TLabel
        Left = 4
        Top = 168
        Width = 81
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = '&Fax inbound'
        FocusControl = lFaxIn
      end
      object cbStation: TComboBox
        Left = 92
        Top = 36
        Width = 289
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
      end
      object lName: TEdit
        Left = 92
        Top = 12
        Width = 289
        Height = 21
        TabOrder = 0
      end
      object cbPort: TComboBox
        Left = 92
        Top = 60
        Width = 289
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 2
      end
      object cbModem: TComboBox
        Left = 92
        Top = 84
        Width = 289
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
      end
      object cbRestrict: TComboBox
        Left = 92
        Top = 108
        Width = 289
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
      end
      object lLog: TEdit
        Left = 92
        Top = 136
        Width = 289
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 5
      end
      object lFaxIn: TEdit
        Left = 92
        Top = 164
        Width = 289
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 6
      end
    end
    object pgAdvanced: TTabSheet
      Caption = 'Events'
      object bUP: TSpeedButton
        Left = 360
        Top = 28
        Width = 25
        Height = 25
        Hint = 'Move Up'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000333
          3333333333777F33333333333309033333333333337F7F333333333333090333
          33333333337F7F33333333333309033333333333337F7F333333333333090333
          33333333337F7F33333333333309033333333333FF7F7FFFF333333000090000
          3333333777737777F333333099999990333333373F3333373333333309999903
          333333337F33337F33333333099999033333333373F333733333333330999033
          3333333337F337F3333333333099903333333333373F37333333333333090333
          33333333337F7F33333333333309033333333333337373333333333333303333
          333333333337F333333333333330333333333333333733333333}
        NumGlyphs = 2
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = bUPClick
      end
      object bDN: TSpeedButton
        Left = 360
        Top = 56
        Width = 25
        Height = 25
        Hint = 'Move Down'
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
          333333333337F33333333333333033333333333333373F333333333333090333
          33333333337F7F33333333333309033333333333337373F33333333330999033
          3333333337F337F33333333330999033333333333733373F3333333309999903
          333333337F33337F33333333099999033333333373333373F333333099999990
          33333337FFFF3FF7F33333300009000033333337777F77773333333333090333
          33333333337F7F33333333333309033333333333337F7F333333333333090333
          33333333337F7F33333333333309033333333333337F7F333333333333090333
          33333333337F7F33333333333300033333333333337773333333}
        NumGlyphs = 2
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = bDNClick
      end
      object bRight: TSpeedButton
        Left = 168
        Top = 28
        Width = 25
        Height = 25
        Hint = 'Add'
        Caption = '&>'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = bRightClick
      end
      object bLeft: TSpeedButton
        Left = 168
        Top = 56
        Width = 25
        Height = 25
        Hint = 'Delete'
        Caption = '&<'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = bLeftClick
      end
      object bEdit: TSpeedButton
        Left = 168
        Top = 156
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
      object labelAvl: TLabel
        Left = 12
        Top = 8
        Width = 43
        Height = 13
        Caption = '&Available'
        FocusControl = lAvl
      end
      object labelLinked: TLabel
        Left = 204
        Top = 8
        Width = 32
        Height = 13
        Caption = '&Linked'
        FocusControl = lLnk
      end
      object lAvl: TListBox
        Left = 8
        Top = 24
        Width = 154
        Height = 165
        ItemHeight = 13
        TabOrder = 0
        OnClick = lAvlClick
        OnDblClick = lAvlDblClick
        OnKeyPress = lAvlKeyPress
      end
      object lLnk: TListBox
        Left = 200
        Top = 24
        Width = 154
        Height = 165
        ItemHeight = 13
        TabOrder = 1
        OnClick = lAvlClick
        OnDblClick = lLnkDblClick
        OnKeyPress = lLnkKeyPress
      end
    end
  end
end
