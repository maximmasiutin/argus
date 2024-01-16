object EventsForm: TEventsForm
  Left = 282
  Top = 59
  HelpContext = 1900
  BorderStyle = bsDialog
  Caption = 'Events Configuration'
  ClientHeight = 258
  ClientWidth = 416
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object lv: TListView
    Left = 6
    Top = 6
    Width = 325
    Height = 204
    Columns = <
      item
        Caption = 'Name'
        Width = 120
      end
      item
        Caption = 'Cron'
        Width = 100
      end
      item
        Caption = 'Duration'
        Width = 55
      end
      item
        Caption = 'Atoms'
        Width = 46
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvChange
    OnClick = lvClick
    OnDblClick = bEditClick
  end
  object bNew: TButton
    Left = 340
    Top = 8
    Width = 64
    Height = 23
    Caption = '&New'
    TabOrder = 1
    OnClick = bNewClick
  end
  object bEdit: TButton
    Left = 340
    Top = 36
    Width = 64
    Height = 23
    Caption = '&Edit'
    TabOrder = 2
    OnClick = bEditClick
  end
  object bCopy: TButton
    Left = 340
    Top = 64
    Width = 64
    Height = 23
    Caption = '&Copy'
    TabOrder = 3
    OnClick = bCopyClick
  end
  object bDelete: TButton
    Left = 340
    Top = 92
    Width = 64
    Height = 23
    Caption = 'Dele&te'
    TabOrder = 4
    OnClick = bDeleteClick
  end
  object bOK: TButton
    Left = 88
    Top = 218
    Width = 72
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 5
  end
  object bCancel: TButton
    Left = 168
    Top = 218
    Width = 72
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object bHelp: TButton
    Left = 248
    Top = 218
    Width = 72
    Height = 23
    Caption = 'Help'
    TabOrder = 7
    OnClick = bHelpClick
  end
  object PopupMenu: TPopupMenu
    Left = 354
    Top = 176
    object ppNew: TMenuItem
      Caption = '&New'
      ShortCut = 16462
      OnClick = bNewClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ppEdit: TMenuItem
      Caption = '&Edit'
      ShortCut = 16453
      OnClick = bEditClick
    end
    object ppCopy: TMenuItem
      Caption = '&Copy'
      ShortCut = 16451
      OnClick = bCopyClick
    end
    object ppDelete: TMenuItem
      Caption = 'Dele&te'
      ShortCut = 16452
      OnClick = bDeleteClick
    end
    object mPopup: TMenuItem
      Caption = 'Popup'
      ShortCut = 32889
      Visible = False
      OnClick = mPopupClick
    end
  end
end
