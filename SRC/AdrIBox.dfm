object FidoAddressInput: TFidoAddressInput
  Left = 124
  Top = 120
  HelpContext = 2150
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Input the address'
  ClientHeight = 118
  ClientWidth = 347
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
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bOK: TButton
    Left = 96
    Top = 80
    Width = 69
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object bCancel: TButton
    Left = 172
    Top = 80
    Width = 69
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object AddressBox: TGroupBox
    Left = 16
    Top = 12
    Width = 313
    Height = 57
    Caption = 'Address'
    TabOrder = 0
    object lAddress: THistoryLine
      Left = 12
      Top = 20
      Width = 209
      Height = 21
      HistoryID = 22
      TabOrder = 0
    end
    object bBrowse: TButton
      Left = 233
      Top = 17
      Width = 69
      Height = 23
      Caption = 'Browse'
      TabOrder = 1
      OnClick = bBrowseClick
    end
  end
  object bHelp: TButton
    Left = 248
    Top = 80
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 3
    OnClick = bHelpClick
  end
end
