object ModemEditor: TModemEditor
  Left = 235
  Top = 55
  HelpContext = 1090
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Modem configuration'
  ClientHeight = 263
  ClientWidth = 468
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
    Left = 216
    Top = 232
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 296
    Top = 232
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 376
    Top = 232
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
  object pg: TPageControl
    Left = 0
    Top = 0
    Width = 468
    Height = 225
    ActivePage = General
    Align = alTop
    TabOrder = 0
    object General: TTabSheet
      Caption = 'General'
      object llName: TLabel
        Left = 12
        Top = 7
        Width = 28
        Height = 13
        Caption = '&Name'
        FocusControl = lName
      end
      object llCmds: TLabel
        Left = 12
        Top = 52
        Width = 52
        Height = 13
        Caption = '&Commands'
        FocusControl = gCmd
      end
      object lName: TEdit
        Left = 8
        Top = 23
        Width = 209
        Height = 21
        TabOrder = 0
      end
      object gCmd: TAdvGrid
        Left = 8
        Top = 68
        Width = 445
        Height = 117
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
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
        TabOrder = 1
        ColWidths = (
          77
          363)
      end
    end
    object Responses: TTabSheet
      Caption = 'Responses'
      object gStd: TAdvGrid
        Left = 8
        Top = 12
        Width = 445
        Height = 174
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
        ColCount = 2
        DefaultRowHeight = 18
        RowCount = 9
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing, goFixedNumCols]
        ParentFont = False
        TabOrder = 0
        RightMargin = 12
        ColWidths = (
          62
          378)
      end
    end
    object Flags: TTabSheet
      Caption = 'Flags'
      object gFlg: TAdvGrid
        Left = 8
        Top = 12
        Width = 445
        Height = 173
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
        TabOrder = 0
        ColWidths = (
          31
          158
          234)
      end
    end
    object tsFax: TTabSheet
      Caption = 'Fax'
      object gbIntFax: TGroupBox
        Left = 8
        Top = 124
        Width = 443
        Height = 49
        Caption = '&Internal receiver settings'
        TabOrder = 2
        object cbDTE: TCheckBox
          Left = 12
          Top = 20
          Width = 141
          Height = 17
          Caption = 'Switch &DTE to 19.2 Kbps'
          TabOrder = 0
        end
      end
      object gbExt: TGroupBox
        Left = 8
        Top = 56
        Width = 443
        Height = 61
        Caption = 'External Receiver settings'
        TabOrder = 1
        object lExtR: TLabel
          Left = 18
          Top = 24
          Width = 66
          Height = 13
          Alignment = taRightJustify
          Caption = '&Command line'
          FocusControl = lFax
        end
        object lFax: TEdit
          Left = 88
          Top = 20
          Width = 342
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
      object rgExt: TRadioGroup
        Left = 8
        Top = 4
        Width = 185
        Height = 45
        Caption = '&Fax receiver'
        Columns = 2
        Items.Strings = (
          'E&xternal'
          'I&nternal')
        TabOrder = 0
        OnClick = rgExtClick
      end
    end
  end
end
