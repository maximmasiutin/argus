object RestrictCfgForm: TRestrictCfgForm
  Left = 21
  Top = 88
  HelpContext = 1100
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Dialling Restrictions Scheme'
  ClientHeight = 183
  ClientWidth = 574
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object llName: TLabel
    Left = 408
    Top = 8
    Width = 68
    Height = 13
    Alignment = taRightJustify
    Caption = 'Scheme name'
  end
  object lName: TEdit
    Left = 408
    Top = 22
    Width = 155
    Height = 21
    TabOrder = 1
  end
  object bOK: TButton
    Left = 408
    Top = 54
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object bCancel: TButton
    Left = 408
    Top = 82
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object bHelp: TButton
    Left = 488
    Top = 82
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 5
    OnClick = bHelpClick
  end
  object p: TPageControl
    Left = 0
    Top = 0
    Width = 401
    Height = 183
    ActivePage = tsRequired
    Align = alLeft
    TabOrder = 0
    TabPosition = tpBottom
    object tsRequired: TTabSheet
      Caption = 'Required'
      object gReqd: TAdvGrid
        Left = 1
        Top = 0
        Width = 391
        Height = 152
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
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
          338)
      end
    end
    object tsForbidden: TTabSheet
      Caption = 'Forbidden'
      object gForb: TAdvGrid
        Left = 1
        Top = 0
        Width = 391
        Height = 152
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
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
          338)
      end
    end
  end
  object bExplain: TButton
    Left = 488
    Top = 54
    Width = 75
    Height = 23
    Caption = 'Explain...'
    TabOrder = 3
    OnClick = bExplainClick
  end
end
