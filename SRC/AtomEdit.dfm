object AtomEditorForm: TAtomEditorForm
  Left = 193
  Top = 170
  HelpContext = 1890
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Edit Event Atom'
  ClientHeight = 294
  ClientWidth = 401
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel2: TBevel
    Left = 0
    Top = 0
    Width = 313
    Height = 63
    Shape = bsFrame
  end
  object llTyp: TLabel
    Left = 12
    Top = 7
    Width = 24
    Height = 13
    Caption = '&Type'
  end
  object cb: TComboBox
    Left = 9
    Top = 23
    Width = 294
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cbChange
  end
  object bOK: TButton
    Left = 320
    Top = 0
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object bCancel: TButton
    Left = 320
    Top = 28
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object bHelp: TButton
    Left = 320
    Top = 56
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 4
    OnClick = bHelpClick
  end
  object nb: TNotebook
    Left = 0
    Top = 61
    Width = 313
    Height = 220
    PageIndex = 7
    TabOrder = 1
    object TPage
      Left = 0
      Top = 0
      Caption = '0'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '1'
      object bvl1: TBevel
        Left = 0
        Top = 0
        Width = 313
        Height = 71
        Align = alTop
        Shape = bsFrame
      end
      object lString: TLabel
        Left = 12
        Top = 8
        Width = 3
        Height = 13
        FocusControl = iString
      end
      object iString: TEdit
        Left = 9
        Top = 24
        Width = 294
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
    object TPage
      Left = 0
      Top = 0
      Caption = '2'
      object bvl2: TBevel
        Left = 0
        Top = 0
        Width = 313
        Height = 71
        Align = alTop
        Shape = bsFrame
      end
      object lCombo: TLabel
        Left = 12
        Top = 8
        Width = 3
        Height = 13
        FocusControl = cbCombo
      end
      object cbCombo: TComboBox
        Left = 9
        Top = 24
        Width = 294
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnClick = cbComboClick
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '3'
      object bvl3: TBevel
        Left = 0
        Top = 0
        Width = 313
        Height = 53
        Align = alTop
        Shape = bsFrame
      end
      object lSpin: TLabel
        Left = 84
        Top = 19
        Width = 3
        Height = 13
        FocusControl = sSpin
      end
      object sSpin: TxSpinEdit
        Left = 9
        Top = 15
        Width = 68
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 0
        Value = 0
        OnChange = sSpinChange
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '4'
      object bvl4: TBevel
        Left = 0
        Top = 0
        Width = 313
        Height = 43
        Align = alTop
        Shape = bsFrame
      end
      object cbCheckBox: TCheckBox
        Left = 11
        Top = 13
        Width = 294
        Height = 17
        TabOrder = 0
        OnClick = cbCheckBoxClick
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '5'
      object bvl5: TBevel
        Left = 0
        Top = 0
        Width = 313
        Height = 113
        Align = alTop
        Shape = bsFrame
      end
      object lDstrA: TLabel
        Left = 12
        Top = 8
        Width = 3
        Height = 13
        FocusControl = iString
      end
      object lDstrB: TLabel
        Left = 12
        Top = 56
        Width = 3
        Height = 13
        FocusControl = iString
      end
      object iDstrA: TEdit
        Left = 9
        Top = 24
        Width = 294
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
      end
      object iDstrB: TEdit
        Left = 9
        Top = 72
        Width = 294
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '6'
      object bvl6: TBevel
        Left = 0
        Top = 0
        Width = 313
        Height = 209
        Align = alTop
        Shape = bsFrame
      end
      object MemoPageControl: TPageControl
        Left = 0
        Top = 2
        Width = 313
        Height = 207
        ActivePage = tsMemoA
        TabOrder = 0
        object tsMemoA: TTabSheet
          Caption = 'tsMemoA'
          object MemoA: TMemo
            Left = 0
            Top = 0
            Width = 305
            Height = 179
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Fixedsys'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            WordWrap = False
          end
        end
        object tsMemoB: TTabSheet
          Caption = 'tsMemoB'
          ImageIndex = 1
          object MemoB: TMemo
            Left = 0
            Top = 0
            Width = 305
            Height = 179
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Fixedsys'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            WordWrap = False
          end
        end
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '7'
      object bvl7: TBevel
        Left = 0
        Top = 0
        Width = 313
        Height = 212
        Align = alTop
        Shape = bsFrame
      end
      object lGrid: TLabel
        Left = 12
        Top = 8
        Width = 3
        Height = 13
        FocusControl = eGrid
      end
      object StringGrid: TAdvGrid
        Left = 0
        Top = 64
        Width = 313
        Height = 148
        FixedFont.Charset = DEFAULT_CHARSET
        FixedFont.Color = clWindowText
        FixedFont.Height = -11
        FixedFont.Name = 'MS Sans Serif'
        FixedFont.Style = []
        DefaultRowHeight = 18
        RowCount = 2
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goColSizing, goRowMoving, goEditing, goThumbTracking, goDigitalRows]
        ParentFont = False
        TabOrder = 0
        ColWidths = (
          30
          64
          64
          64
          64)
      end
      object eGrid: TEdit
        Left = 9
        Top = 24
        Width = 294
        Height = 24
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '8'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = '9'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'A'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'B'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'C'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'D'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'E'
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'F'
    end
  end
end
