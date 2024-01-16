object RTFForm: TRTFForm
  Left = 92
  Top = 80
  BorderStyle = bsDialog
  ClientHeight = 310
  ClientWidth = 472
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Info: TRichEdit
    Left = 4
    Top = 5
    Width = 463
    Height = 257
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    WantReturns = False
  end
  object BtnNb: TNotebook
    Left = 0
    Top = 265
    Width = 472
    Height = 45
    Align = alBottom
    TabOrder = 0
    object TPage
      Left = 0
      Top = 0
      Caption = 'Default'
      object bOK: TButton
        Left = 200
        Top = 8
        Width = 75
        Height = 23
        Cancel = True
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'License'
      object bAgree: TButton
        Left = 144
        Top = 8
        Width = 81
        Height = 25
        ModalResult = 6
        TabOrder = 0
      end
      object bDisagree: TButton
        Left = 240
        Top = 8
        Width = 81
        Height = 25
        Cancel = True
        ModalResult = 7
        TabOrder = 1
      end
    end
  end
end
