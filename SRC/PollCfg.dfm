object PollSetupForm: TPollSetupForm
  Left = 139
  Top = 125
  HelpContext = 1950
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Polls Set-up'
  ClientHeight = 273
  ClientWidth = 532
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
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 532
    Height = 233
    ActivePage = tsPeriodical
    Align = alTop
    TabOrder = 0
    object tsPeriodical: TTabSheet
      BorderWidth = 6
      Caption = 'Periodical'
      object gPeriodical: TAdvGrid
        Left = 0
        Top = 0
        Width = 512
        Height = 193
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
          232
          226)
      end
    end
    object tsOptions: TTabSheet
      Caption = 'Options'
      object gbTry: TGroupBox
        Left = 12
        Top = 12
        Width = 157
        Height = 125
        Caption = 'Try counters'
        TabOrder = 0
        object lBysy: TLabel
          Left = 71
          Top = 28
          Width = 23
          Height = 13
          Alignment = taRightJustify
          Caption = '&Busy'
          FocusControl = sBusy
        end
        object lNoC: TLabel
          Left = 68
          Top = 60
          Width = 26
          Height = 13
          Alignment = taRightJustify
          Caption = '&No c.'
          FocusControl = sNoC
        end
        object lFail: TLabel
          Left = 78
          Top = 92
          Width = 16
          Height = 13
          Alignment = taRightJustify
          Caption = '&Fail'
          FocusControl = sFail
        end
        object sBusy: TxSpinEdit
          Left = 100
          Top = 24
          Width = 41
          Height = 22
          MaxLength = 3
          MaxValue = 99
          MinValue = 1
          TabOrder = 0
          Value = 7
        end
        object sNoC: TxSpinEdit
          Left = 100
          Top = 56
          Width = 41
          Height = 22
          MaxLength = 3
          MaxValue = 99
          MinValue = 1
          TabOrder = 1
          Value = 5
        end
        object sFail: TxSpinEdit
          Left = 100
          Top = 88
          Width = 41
          Height = 22
          MaxLength = 3
          MaxValue = 99
          MinValue = 1
          TabOrder = 2
          Value = 3
        end
      end
      object gbTO: TGroupBox
        Left = 188
        Top = 12
        Width = 237
        Height = 125
        BiDiMode = bdLeftToRight
        Caption = 'Time-outs'
        ParentBiDiMode = False
        TabOrder = 1
        object lRetry: TLabel
          Left = 94
          Top = 24
          Width = 68
          Height = 13
          Alignment = taRightJustify
          Caption = '&Retry seconds'
          FocusControl = sRetry
        end
        object lStandOff: TLabel
          Left = 80
          Top = 56
          Width = 82
          Height = 13
          Alignment = taRightJustify
          Caption = '&Stand-off minutes'
          FocusControl = sStandOff
        end
        object sStandOff: TxSpinEdit
          Left = 168
          Top = 52
          Width = 56
          Height = 22
          MaxLength = 5
          MaxValue = 2880
          MinValue = 1
          TabOrder = 1
          Value = 1
        end
        object sRetry: TxSpinEdit
          Left = 168
          Top = 20
          Width = 56
          Height = 22
          MaxLength = 6
          MaxValue = 14400
          MinValue = 10
          TabOrder = 0
          Value = 10
        end
      end
      object cbTransmitHold: TCheckBox
        Left = 12
        Top = 152
        Width = 413
        Height = 17
        Caption = '&Transmit '#39'Hold'#39' on outgoing'
        TabOrder = 2
      end
      object cbDirectAsNormal: TCheckBox
        Left = 12
        Top = 176
        Width = 413
        Height = 17
        Caption = 'Prevent '#39'Direct'#39' from initiating a poll'
        TabOrder = 3
      end
    end
    object tsExternal: TTabSheet
      BorderWidth = 6
      Caption = 'External'
      object gExternal: TAdvGrid
        Left = 0
        Top = 0
        Width = 512
        Height = 193
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
        Align = alClient
        ColCount = 4
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
          134
          140
          184)
      end
    end
  end
  object bOK: TButton
    Left = 272
    Top = 243
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 352
    Top = 243
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 432
    Top = 243
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
end
