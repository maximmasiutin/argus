object FileBoxesForm: TFileBoxesForm
  Left = 228
  Top = 126
  HelpContext = 2130
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'File-boxes Configuration'
  ClientHeight = 257
  ClientWidth = 508
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 508
    Height = 209
    ActivePage = tsNodes
    Align = alTop
    TabOrder = 0
    object tsNodes: TTabSheet
      BorderWidth = 6
      Caption = 'Nodes'
      object gNodes: TAdvGrid
        Left = 0
        Top = 0
        Width = 488
        Height = 169
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
          131
          57
          240)
      end
    end
    object tsOptions: TTabSheet
      BorderWidth = 6
      Caption = 'Options'
      ImageIndex = 1
      object lRoot: TLabel
        Left = 8
        Top = 8
        Width = 66
        Height = 13
        Caption = 'Root directory'
      end
      object eRoot: TEdit
        Left = 4
        Top = 24
        Width = 471
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
    end
  end
  object bOK: TButton
    Left = 236
    Top = 224
    Width = 75
    Height = 23
    Caption = 'O&K'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 316
    Top = 224
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object bHelp: TButton
    Left = 396
    Top = 224
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
end
