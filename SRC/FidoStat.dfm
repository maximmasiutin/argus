object FidoTemplateEditor: TFidoTemplateEditor
  Left = 139
  Top = 77
  HelpContext = 1070
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Edit station template'
  ClientHeight = 243
  ClientWidth = 442
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
  object lTplName: TLabel
    Left = 56
    Top = 180
    Width = 73
    Height = 13
    Alignment = taRightJustify
    Caption = 'Template name'
  end
  object bOK: TButton
    Left = 160
    Top = 208
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object bCancel: TButton
    Left = 240
    Top = 208
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object bHelp: TButton
    Left = 320
    Top = 208
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 4
    OnClick = bHelpClick
  end
  object lName: TEdit
    Left = 136
    Top = 176
    Width = 297
    Height = 21
    TabOrder = 1
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 442
    Height = 165
    ActivePage = tsEMSI
    Align = alTop
    TabOrder = 0
    object tsEMSI: TTabSheet
      Caption = 'EMSI'
      object gTpl: TAdvGrid
        Left = 6
        Top = 9
        Width = 422
        Height = 119
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clBlack
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
        TabOrder = 0
        ColWidths = (
          121
          295)
      end
    end
    object tsBanner: TTabSheet
      Caption = 'Banner'
      object eBan: TMemo
        Left = 6
        Top = 9
        Width = 422
        Height = 119
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
    object tsAKA: TTabSheet
      Caption = 'AKA'
      object gAKA: TAdvGrid
        Left = 6
        Top = 8
        Width = 422
        Height = 119
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
          165
          202)
      end
    end
  end
end
