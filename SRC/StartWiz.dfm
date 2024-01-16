object StartWizzardForm: TStartWizzardForm
  Left = 245
  Top = 86
  BorderStyle = bsDialog
  BorderWidth = 6
  ClientHeight = 212
  ClientWidth = 524
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 232
    Top = 96
    Width = 65
    Height = 17
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 232
    Top = 96
    Width = 65
    Height = 17
    Caption = 'Label2'
  end
  object Pages: TPageControl
    Left = 0
    Top = 0
    Width = 524
    Height = 197
    ActivePage = tsDialProps
    Align = alTop
    RaggedRight = True
    Style = tsButtons
    TabOrder = 0
    TabWidth = 100
    object tsTransport: TTabSheet
      Caption = 'Transport Type'
      ImageIndex = 2
      TabVisible = False
      object gbConn: TGroupBox
        Left = 0
        Top = 0
        Width = 516
        Height = 161
        Align = alTop
        Caption = 'What connection do you use'
        TabOrder = 0
        object cbDUP: TCheckBox
          Left = 16
          Top = 28
          Width = 489
          Height = 17
          Caption = 
            'Modem for direct dial-up FTS/FSC connections with destination no' +
            'des'
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = cbDUPClick
        end
        object cbIP: TCheckBox
          Left = 16
          Top = 56
          Width = 489
          Height = 17
          Caption = 'TCP/IP connections with destination nodes'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
      end
    end
    object tsDialProps: TTabSheet
      Caption = 'Dialling Properties'
      TabVisible = False
      object gbDialProps: TGroupBox
        Left = 0
        Top = 0
        Width = 516
        Height = 161
        Align = alTop
        Caption = 'Dialling properties'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object lAreaCode: TLabel
          Left = 215
          Top = 24
          Width = 49
          Height = 13
          Alignment = taRightJustify
          Caption = 'Area code'
          FocusControl = eAreaCode
        end
        object lLocalPrefix: TLabel
          Left = 57
          Top = 52
          Width = 207
          Height = 13
          Alignment = taRightJustify
          Caption = 'To access an outside line, for local calls dial'
          FocusControl = eLocalPrefix
        end
        object lLongDistPrefix: TLabel
          Left = 16
          Top = 80
          Width = 248
          Height = 13
          Alignment = taRightJustify
          Caption = 'To access an outside line, for long-distance calls dial'
          FocusControl = eLongDistPrefix
        end
        object lComPort: TLabel
          Left = 368
          Top = 88
          Width = 46
          Height = 13
          Alignment = taRightJustify
          Caption = 'COM &Port'
          FocusControl = cbCom
        end
        object eAreaCode: TEdit
          Left = 272
          Top = 20
          Width = 57
          Height = 21
          TabOrder = 0
        end
        object eLocalPrefix: TEdit
          Left = 272
          Top = 48
          Width = 57
          Height = 21
          TabOrder = 1
        end
        object eLongDistPrefix: TEdit
          Left = 272
          Top = 76
          Width = 57
          Height = 21
          TabOrder = 2
        end
        object rgTonePulse: TRadioGroup
          Left = 344
          Top = 16
          Width = 159
          Height = 57
          Caption = 'Dial Using'
          ItemIndex = 1
          Items.Strings = (
            'Tone dial'
            'Pulse dial')
          TabOrder = 3
        end
        object cbSetRestrict: TCheckBox
          Left = 16
          Top = 112
          Width = 489
          Height = 17
          Caption = 
            'Set restriction scheme to prevent from occasional long-distance ' +
            'call'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object cbCom: TComboBox
          Left = 422
          Top = 84
          Width = 81
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 5
          Items.Strings = (
            'COM1'
            'COM2'
            'COM3'
            'COM4'
            'COM5'
            'COM6'
            'COM7'
            'COM8'
            'COM9'
            'COM10'
            'COM11'
            'COM12'
            'COM13'
            'COM14'
            'COM15'
            'COM16'
            'COM17'
            'COM18'
            'COM19'
            'COM20'
            'COM21'
            'COM22'
            'COM23'
            'COM24'
            'COM25'
            'COM26'
            'COM27'
            'COM28'
            'COM29'
            'COM30'
            'COM31'
            'COM32')
        end
      end
    end
  end
  object bPrev: TButton
    Left = 184
    Top = 180
    Width = 90
    Height = 25
    Caption = '<<  &Previous'
    TabOrder = 1
    OnClick = bPrevClick
  end
  object bNext: TButton
    Left = 280
    Top = 180
    Width = 90
    Height = 25
    Caption = '&Next  >>'
    Default = True
    TabOrder = 2
    OnClick = bNextClick
  end
  object bCancel: TButton
    Left = 376
    Top = 180
    Width = 90
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
