object ExternalsForm: TExternalsForm
  Left = 159
  Top = 68
  HelpContext = 1880
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Externals'
  ClientHeight = 225
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bOK: TButton
    Left = 208
    Top = 191
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object bCancel: TButton
    Left = 288
    Top = 191
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object bHelp: TButton
    Left = 368
    Top = 191
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 4
    OnClick = bHelpClick
  end
  object bImportPwd: TButton
    Left = 44
    Top = 191
    Width = 75
    Height = 23
    Caption = 'Import...'
    TabOrder = 1
    Visible = False
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 472
    Height = 183
    ActivePage = tsPP
    TabOrder = 0
    object tsPP: TTabSheet
      Caption = 'Postprocessors'
      object gExt: TAdvGrid
        Left = 7
        Top = 7
        Width = 449
        Height = 137
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
          190
          206)
      end
    end
    object tsDrs: TTabSheet
      Caption = 'Doors'
      object gDrs: TAdvGrid
        Left = 7
        Top = 7
        Width = 449
        Height = 137
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
          60
          336)
      end
    end
    object tsCron: TTabSheet
      Caption = 'Cron'
      object gCrn: TAdvGrid
        Left = 7
        Top = 7
        Width = 449
        Height = 137
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
          190
          206)
      end
    end
  end
end
