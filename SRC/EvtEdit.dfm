object EvtEditForm: TEvtEditForm
  Left = 190
  Top = 26
  HelpContext = 1900
  BorderStyle = bsDialog
  Caption = 'Edit Event'
  ClientHeight = 284
  ClientWidth = 373
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object llName: TLabel
    Left = 16
    Top = 8
    Width = 28
    Height = 13
    Caption = '&Name'
    FocusControl = iName
  end
  object llCron: TLabel
    Left = 16
    Top = 52
    Width = 22
    Height = 13
    Caption = '&Cron'
    FocusControl = iCron
  end
  object llAtoms: TLabel
    Left = 16
    Top = 96
    Width = 29
    Height = 13
    Caption = 'A&toms'
  end
  object iName: TEdit
    Left = 8
    Top = 24
    Width = 241
    Height = 21
    TabOrder = 0
  end
  object iCron: TEdit
    Left = 8
    Top = 68
    Width = 241
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Fixedsys'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object llL: TGroupBox
    Left = 264
    Top = 8
    Width = 97
    Height = 113
    Caption = 'Duration'
    TabOrder = 3
    object llD: TLabel
      Left = 42
      Top = 25
      Width = 24
      Height = 13
      Caption = '&Days'
      FocusControl = iiD
    end
    object llH: TLabel
      Left = 42
      Top = 53
      Width = 28
      Height = 13
      Caption = '&Hours'
      FocusControl = iiH
    end
    object llM: TLabel
      Left = 42
      Top = 81
      Width = 37
      Height = 13
      Caption = '&Minutes'
      FocusControl = iiM
    end
    object iiH: TEdit
      Left = 10
      Top = 49
      Width = 24
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object iiD: TEdit
      Left = 10
      Top = 21
      Width = 24
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object iiM: TEdit
      Left = 10
      Top = 77
      Width = 24
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Fixedsys'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
    end
  end
  object bOK: TButton
    Left = 280
    Top = 184
    Width = 81
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 8
  end
  object bCancel: TButton
    Left = 280
    Top = 216
    Width = 81
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 9
  end
  object bHelp: TButton
    Left = 280
    Top = 248
    Width = 81
    Height = 23
    Caption = 'Help'
    TabOrder = 10
    OnClick = bHelpClick
  end
  object bAddAtom: TButton
    Left = 11
    Top = 248
    Width = 75
    Height = 23
    Caption = '&Add'
    TabOrder = 5
    OnClick = bAddAtomClick
  end
  object bDelete: TButton
    Left = 171
    Top = 248
    Width = 75
    Height = 23
    Caption = 'De&lete'
    TabOrder = 7
    OnClick = bDeleteClick
  end
  object bEdit: TButton
    Left = 91
    Top = 248
    Width = 75
    Height = 23
    Caption = '&Edit'
    TabOrder = 6
    OnClick = bEditClick
  end
  object lb: TListView
    Left = 8
    Top = 112
    Width = 241
    Height = 129
    Columns = <
      item
        Caption = 'Type'
        Width = 120
      end
      item
        Caption = 'Parameters'
        Width = -2
        WidthType = (
          -2)
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 2
    ViewStyle = vsReport
    OnChange = lbChange
    OnClick = lbClick
    OnDblClick = bEditClick
  end
  object cbPermanent: TCheckBox
    Left = 272
    Top = 128
    Width = 89
    Height = 21
    Caption = '&Permanent'
    TabOrder = 4
    OnClick = cbPermanentClick
  end
  object cbUTC: TCheckBox
    Left = 272
    Top = 152
    Width = 89
    Height = 21
    Caption = '&UTC'
    TabOrder = 11
    OnClick = cbPermanentClick
  end
end
