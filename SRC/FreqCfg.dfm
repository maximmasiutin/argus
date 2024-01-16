object FreqCfgForm: TFreqCfgForm
  Left = 189
  Top = 94
  HelpContext = 1030
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'File Request Configuration'
  ClientHeight = 358
  ClientWidth = 429
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
  PixelsPerInch = 96
  TextHeight = 13
  object bOK: TButton
    Left = 180
    Top = 320
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 260
    Top = 320
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 340
    Top = 320
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 429
    Height = 309
    ActivePage = pGeneral
    Align = alTop
    TabOrder = 0
    object pGeneral: TTabSheet
      Caption = 'General'
      object llSRIF: TLabel
        Left = 8
        Top = 8
        Width = 257
        Height = 13
        Caption = 'Standard Request Information File - &External Processor'
        FocusControl = lSRIF
      end
      object llGrid: TLabel
        Left = 8
        Top = 56
        Width = 103
        Height = 13
        Caption = 'Re&quested directories'
        FocusControl = gDirs
      end
      object gDirs: TAdvGrid
        Left = 8
        Top = 72
        Width = 405
        Height = 169
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
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
        TabOrder = 2
        ColWidths = (
          31
          249
          102)
      end
      object cbRecursive: TCheckBox
        Left = 152
        Top = 252
        Width = 129
        Height = 17
        Caption = '&Recursive paths'
        TabOrder = 4
      end
      object cbMasks: TCheckBox
        Left = 288
        Top = 252
        Width = 129
        Height = 17
        Caption = '&Allow masks'
        TabOrder = 5
      end
      object cbDisable: TCheckBox
        Left = 16
        Top = 252
        Width = 135
        Height = 17
        Caption = '&Disable all requests'
        TabOrder = 3
      end
      object cbSRIF: TCheckBox
        Left = 312
        Top = 24
        Width = 105
        Height = 17
        Caption = 'Use &SRIF'
        TabOrder = 1
        OnClick = cbSRIFClick
      end
      object lSRIF: TEdit
        Left = 8
        Top = 24
        Width = 297
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
    object Aliases: TTabSheet
      Caption = 'Aliases'
      object llAls: TLabel
        Left = 8
        Top = 4
        Width = 33
        Height = 13
        Caption = '&Aliases'
        FocusControl = gAls
      end
      object gAls: TAdvGrid
        Left = 8
        Top = 20
        Width = 405
        Height = 249
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
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
          72
          214
          64)
      end
    end
  end
end
