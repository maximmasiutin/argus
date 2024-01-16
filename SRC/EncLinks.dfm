object EncryptedLinksForm: TEncryptedLinksForm
  Left = 258
  Top = 125
  HelpContext = 2040
  BorderStyle = bsDialog
  BorderWidth = 6
  Caption = 'Encrypted Links'
  ClientHeight = 234
  ClientWidth = 263
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lb: TListBox
    Left = 0
    Top = 0
    Width = 161
    Height = 234
    Align = alLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Fixedsys'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    PopupMenu = Popup
    TabOrder = 0
  end
  object bAdd: TButton
    Left = 178
    Top = 4
    Width = 75
    Height = 23
    Caption = '&Add'
    TabOrder = 1
    OnClick = bAddClick
  end
  object bRemove: TButton
    Left = 178
    Top = 60
    Width = 75
    Height = 23
    Caption = '&Remove'
    TabOrder = 3
    OnClick = bRemoveClick
  end
  object bChange: TButton
    Left = 178
    Top = 32
    Width = 75
    Height = 23
    Caption = '&Change'
    TabOrder = 2
    OnClick = bChangeClick
  end
  object bClose: TButton
    Left = 178
    Top = 148
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Close'
    Default = True
    ModalResult = 2
    TabOrder = 5
  end
  object bHelp: TButton
    Left = 178
    Top = 196
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 6
    OnClick = bHelpClick
  end
  object bSort: TButton
    Left = 178
    Top = 88
    Width = 75
    Height = 23
    Caption = '&Sort'
    TabOrder = 4
    OnClick = bSortClick
  end
  object Popup: TPopupMenu
    Left = 208
    Top = 120
    object mAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 16449
      OnClick = bAddClick
    end
    object mChange: TMenuItem
      Caption = '&Change'
      ShortCut = 16451
      OnClick = bChangeClick
    end
    object mRemove: TMenuItem
      Caption = '&Remove'
      ShortCut = 16466
      OnClick = bRemoveClick
    end
    object mSort: TMenuItem
      Caption = '&Sort'
      ShortCut = 16467
      OnClick = bSortClick
    end
    object mPopup: TMenuItem
      Caption = 'Popup'
      ShortCut = 32889
      Visible = False
      OnClick = mPopupClick
    end
  end
end
