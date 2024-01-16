object ImportForm: TImportForm
  Left = 193
  Top = 159
  BorderStyle = bsDialog
  ClientHeight = 192
  ClientWidth = 344
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
  object rbBinkD: TRadioButton
    Left = 16
    Top = 16
    Width = 313
    Height = 17
    Caption = 'BinkD © Dima Maloff'
    Checked = True
    TabOrder = 0
    TabStop = True
  end
  object rbBinkPlus: TRadioButton
    Left = 16
    Top = 36
    Width = 313
    Height = 17
    Caption = 'Bink/+ © serge terekhov'
    TabOrder = 1
  end
  object rbTMail: TRadioButton
    Left = 16
    Top = 56
    Width = 313
    Height = 17
    Caption = 'T-Mail © Andy Elkin'
    TabOrder = 2
  end
  object rbXenia: TRadioButton
    Left = 16
    Top = 76
    Width = 313
    Height = 17
    Caption = 'Xenia © Arjen G. Lentz'
    TabOrder = 3
  end
  object bOK: TButton
    Left = 88
    Top = 152
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
  end
  object bCancel: TButton
    Left = 168
    Top = 152
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object bHelp: TButton
    Left = 248
    Top = 152
    Width = 75
    Height = 23
    Caption = 'Help'
    TabOrder = 8
    OnClick = bHelpClick
  end
  object rbFrontDoor: TRadioButton
    Left = 16
    Top = 96
    Width = 313
    Height = 17
    Caption = 'FrontDoor 2.12 © Joaquim Homrighausen (passwords only)'
    TabOrder = 4
  end
  object rbMainDoor: TRadioButton
    Left = 16
    Top = 116
    Width = 313
    Height = 17
    Caption = 'MainDoor 1.10 © Francisco Sedano Crippa (passwords only)'
    TabOrder = 5
  end
end
