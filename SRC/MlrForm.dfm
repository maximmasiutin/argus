object MailerForm: TMailerForm
  Left = 245
  Top = 86
  Width = 610
  Height = 413
  HelpContext = 1500
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu
  OldCreateOrder = True
  Position = poDefaultPosOnly
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object MainTabControl: TTabControl
    Left = 0
    Top = 0
    Width = 602
    Height = 367
    Align = alClient
    HotTrack = True
    TabOrder = 0
    Tabs.Strings = (
      'Polls')
    TabIndex = 0
    OnChange = MainTabControlChange
    object MainPanel: TPanel
      Left = 4
      Top = 24
      Width = 594
      Height = 339
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsSingle
      TabOrder = 0
      object LogBox: TLogger
        Left = 0
        Top = 250
        Width = 590
        Height = 52
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Fixedsys'
        Font.Pitch = fpFixed
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TabStop = True
      end
      object BottomPanel: TPanel
        Left = 0
        Top = 302
        Width = 590
        Height = 33
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 2
        object DaemonBtnPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 33
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 2
          Visible = False
        end
        object MailerBtnPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 33
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          Visible = False
          object bAbort: TSpeedButton
            Left = 7
            Top = 3
            Width = 26
            Height = 26
            Hint = 'Abort & Reset'
            Flat = True
            Glyph.Data = {
              DE010000424DDE01000000000000760000002800000024000000120000000100
              0400000000006801000000000000000000001000000010000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333111111
              33333333333F7777773F33330000391331999999113333377F3733333377F333
              000039911999999999133337F7733FFFFF337F3300003999999FFFFF99913337
              F333F77777F337F30000399999F33333F9991337F33F7333337F337F00003999
              993333333F991337F33733333337F37F00003999999333333F991337FFFF7F33
              3337777300003FFFFFFF33333333333777777733333333330000333333333333
              333333333333333333FFFFFF000033333333333311111133FFFF333333777777
              00003F991333333F99999137777F333337F3333700003F9913333333F9999137
              F37F333333733337000033F991333331199991337337FFFFF7733337000033F9
              99111119999991337F3377777333FF370000333F9999999999FF913337FF3333
              33FF77F700003333FF999999FF33F3333377FFFFFF7733730000333333FFFFFF
              3333333333337777773333330000333333333333333333333333333333333333
              0000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bAbortClick
          end
          object bRefuse: TSpeedButton
            Left = 69
            Top = 3
            Width = 26
            Height = 26
            Hint = 'Reject file (delete on remote)'
            Enabled = False
            Flat = True
            Glyph.Data = {
              DE010000424DDE01000000000000760000002800000024000000120000000100
              0400000000006801000000000000000000001000000010000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00311116333331
              11133333FFFF333333FFFF330000339991333333291333337733F33333773F33
              0000333291633333291333333373F33333373F33000033329213333696633333
              33733F333373F33300003333991633629133333333373F333733F33300003333
              6991162916333333333733FF733F333300003333329922916333333333337333
              33F333330000333333699922613333333333373333F7FF330000331111669913
              6913333337FFF7733F373F3300003369921692136913333337733F733F373F33
              000033336921991129133333333733F33FF73F33000033333392992991333333
              333373333333F33300003333333229991333333333333733333F333300003333
              33332291333333333333337333F3333300003333333119133333333333333337
              3F333333000033333336921333333333333333733F3333330000333333369913
              33333333333333733F3333330000333333336663333333333333333777333333
              0000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bRefuseClick
          end
          object bSkip: TSpeedButton
            Left = 38
            Top = 3
            Width = 26
            Height = 26
            Hint = 'Skip file (receive later)'
            Enabled = False
            Flat = True
            Glyph.Data = {
              DE010000424DDE01000000000000760000002800000024000000120000000100
              0400000000006801000000000000000000001000000010000000000000000000
              80000080000000808000800000008000800080800000C0C0C000808080000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00344446333334
              44433333FFFF333333FFFF33000033AAA43333332A4333338833F33333883F33
              00003332A46333332A4333333383F33333383F3300003332A2433336A6633333
              33833F333383F33300003333AA463362A433333333383F333833F33300003333
              6AA4462A46333333333833FF833F33330000333332AA22246333333333338333
              33F3333300003333336AAA22646333333333383333F8FF33000033444466AA43
              6A43333338FFF8833F383F330000336AA246A2436A43333338833F833F383F33
              000033336A24AA442A433333333833F33FF83F330000333333A2AA2AA4333333
              333383333333F3330000333333322AAA4333333333333833333F333300003333
              333322A4333333333333338333F333330000333333344A433333333333333338
              3F333333000033333336A24333333333333333833F333333000033333336AA43
              33333333333333833F3333330000333333336663333333333333333888333333
              0000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bSkipClick
          end
          object bAnswer: TSpeedButton
            Left = 100
            Top = 3
            Width = 26
            Height = 26
            Hint = 'Answer call'
            Enabled = False
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000010000000000000000000
              800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
              333333333337FF3333333333330003333333333333777F333333333333080333
              3333333F33777FF33F3333B33B000B33B3333373F777773F7333333BBB0B0BBB
              33333337737F7F77F333333BBB0F0BBB33333337337373F73F3333BBB0F7F0BB
              B333337F3737F73F7F3333BB0FB7BF0BB3333F737F37F37F73FFBBBB0BF7FB0B
              BBB3773F7F37337F377333BB0FBFBF0BB333337F73F333737F3333BBB0FBF0BB
              B3333373F73FF7337333333BBB000BBB33333337FF777337F333333BBBBBBBBB
              3333333773FF3F773F3333B33BBBBB33B33333733773773373333333333B3333
              333333333337F33333333333333B333333333333333733333333}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bAnswerClick
          end
          object LampsPanelCarrier: TPanel
            Left = 456
            Top = 0
            Width = 134
            Height = 33
            Align = alRight
            BevelOuter = bvNone
            BorderWidth = 3
            TabOrder = 0
            object LampsPanel: TPanel
              Left = 3
              Top = 3
              Width = 128
              Height = 27
              Align = alClient
              BevelOuter = bvLowered
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -9
              Font.Name = 'Small Fonts'
              Font.Style = []
              ParentFont = False
              TabOrder = 0
              Visible = False
              object mlRXD: TModemLamp
                Left = 108
                Top = 4
                Kind = mlkBlue
              end
              object lRXD: TLabel
                Left = 103
                Top = 13
                Width = 18
                Height = 10
                Caption = 'RXD'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -8
                Font.Name = 'Small Fonts'
                Font.Style = []
                ParentFont = False
              end
              object mlTXD: TModemLamp
                Left = 84
                Top = 4
                Kind = mlkBlue
              end
              object lTXD: TLabel
                Left = 79
                Top = 13
                Width = 17
                Height = 10
                Caption = 'TXD'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -8
                Font.Name = 'Small Fonts'
                Font.Style = []
                ParentFont = False
              end
              object mlCTS: TModemLamp
                Left = 60
                Top = 4
              end
              object lCTS: TLabel
                Left = 56
                Top = 13
                Width = 16
                Height = 10
                Caption = 'CTS'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -8
                Font.Name = 'Small Fonts'
                Font.Style = []
                ParentFont = False
              end
              object lDSR: TLabel
                Left = 32
                Top = 13
                Width = 17
                Height = 10
                Caption = 'DSR'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -8
                Font.Name = 'Small Fonts'
                Font.Style = []
                ParentFont = False
              end
              object mlDSR: TModemLamp
                Left = 36
                Top = 4
              end
              object mlDCD: TModemLamp
                Left = 12
                Top = 4
                Kind = mlkRed
              end
              object lDCD: TLabel
                Left = 7
                Top = 13
                Width = 18
                Height = 10
                Caption = 'DCD'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -8
                Font.Name = 'Small Fonts'
                Font.Style = []
                ParentFont = False
              end
            end
          end
        end
        object PollBtnPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 33
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          Visible = False
          object bDeleteAllPolls: TSpeedButton
            Left = 131
            Top = 3
            Width = 25
            Height = 26
            Hint = 'Delete all Polls'
            Enabled = False
            Flat = True
            Glyph.Data = {
              DE010000424DDE01000000000000760000002800000024000000120000000100
              0400000000006801000000000000000000001000000010000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333337733333
              333333333333F3333333333300003333911733333973333333377F333333F333
              000033369111733391173333337F37F333F77F33000033919111173911117333
              337F337F3F7337F30000339119111171111173337F7F3337F733337F00003391
              11911111111733337F37F33373333F730000333911191111117333337F337F33
              3333F73300003333911111111733333337F337F3333373330000333339119111
              17333333337F337F333733330000333333191111173333333337F3733337F333
              000033333391117111733333333377333337F333000033333911171911173333
              333373337F337F330000333399117111911173333337F33737F337F300003339
              11913911191113333377FF7F337F337F00003339116333911191933337F37737
              F337FFF700003333913333391113333337FF73337F3377730000333333333333
              919333333377333337FFF3330000333333333333333333333333333333777333
              0000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bDeleteAllPollsClick
          end
          object bResetPoll: TSpeedButton
            Left = 69
            Top = 3
            Width = 25
            Height = 26
            Hint = 'Reset Poll'
            Enabled = False
            Flat = True
            Glyph.Data = {
              DE010000424DDE01000000000000760000002800000024000000120000000100
              0400000000006801000000000000000000001000000010000000000000000000
              80000080000000808000800000008000800080800000C0C0C000808080000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333444444
              33333333333F8888883F33330000324334222222443333388F3833333388F333
              000032244222222222433338F8833FFFFF338F3300003222222AAAAA22243338
              F333F88888F338F30000322222A33333A2224338F33F8333338F338F00003222
              223333333A224338F33833333338F38F00003222222333333A444338FFFF8F33
              3338888300003AAAAAAA33333333333888888833333333330000333333333333
              333333333333333333FFFFFF000033333333333344444433FFFF333333888888
              00003A444333333A22222438888F333338F3333800003A2243333333A2222438
              F38F333333833338000033A224333334422224338338FFFFF8833338000033A2
              22444442222224338F3388888333FF380000333A2222222222AA243338FF3333
              33FF88F800003333AA222222AA33A3333388FFFFFF8833830000333333AAAAAA
              3333333333338888883333330000333333333333333333333333333333333333
              0000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bResetPollClick
          end
          object bDeletePoll: TSpeedButton
            Left = 38
            Top = 3
            Width = 25
            Height = 26
            Hint = 'Delete Poll'
            Enabled = False
            Flat = True
            Glyph.Data = {
              DE010000424DDE01000000000000760000002800000024000000120000000100
              0400000000006801000000000000000000001000000010000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
              333333333333333333333333000033337733333333333333333F333333333333
              0000333D55733333D73333333377F333333F33330000333D5557333D55733333
              37F37F333F77F3330000333D555573D55557333337F337F3F7337F3300003333
              D55557555557333337F3337F733337F3000033333D55555555733333337F3337
              3333F7330000333333D55555573333333337F333333F73330000333333355555
              7333333333337F333337333300003333333D555573333333333337F333733333
              0000333333D555557333333333333733337F3333000033333D55575557333333
              33337333337F333300003333D55573D55573333333373337F337F33300003333
              D557333D55573333337F33737F337F33000033333D533333D5553333337FF733
              37F337F300003333333333333D5D333333377333337FFF730000333333333333
              3333333333333333333777330000333333333333333333333333333333333333
              0000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bDeletePollClick
          end
          object bNewPoll: TSpeedButton
            Left = 7
            Top = 3
            Width = 25
            Height = 26
            Hint = 'Create Poll'
            Flat = True
            Glyph.Data = {
              76010000424D7601000000000000760000002800000020000000100000000100
              0400000000000001000000000000000000001000000010000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003B3444444444
              443B37F77777777777F73BB4ECCCCCCCC4BB3777F3F3F3F3F7773CC4E8080808
              C4B33777F73737373773C334EEEEEEEEC4337F373F3F3F3F3733C3334E80808E
              43337F33737373737333C33334EEEEE433337FFFF7FFFFF7FFFFB4CCB4444444
              BBBB7777777777777777B4CCC4BBBBB4BBBB77F377777777777734CCC48BB333
              333337F337377F3FFFF334EECCCBB34C4433373F33777F77773F33CEEEC44C4C
              CC433373FFF77773337F333444EEEECEEE433337773FFFF33373333BB7C44CEE
              CC3333377377773FF7F333BB333BB74CCB33337733377F7777FF3BB3333BB333
              3BB3377333377F33377FBB33333BB33333BB7733333773333377}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bNewPollClick
          end
          object bTracePoll: TSpeedButton
            Left = 100
            Top = 3
            Width = 25
            Height = 26
            Hint = 'Poll Info'
            Enabled = False
            Flat = True
            Glyph.Data = {
              6E020000424D6E0200000000000076000000280000002A000000150000000100
              040000000000F801000000000000000000001000000010000000000000000000
              8000008000000080800080000000800080008080000080808000C0C0C0000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
              8888888888888888888888888888880000008888888888888888888888888888
              8888888888888800000088888888888888888888888888888888888888888800
              0000888888887444788888888888888888FFF888888888000000888888874444
              478888888888888888777F888888880000008888888444784488888888888888
              878877F888888800000088888884447887888888888888888788F77F88888800
              000088888887444888888888888888888788F888888888000000888888887447
              888888888888888888787F888888880000008888888874447888888888888888
              88787F888888880000008888888887447888888888888888888787F888888800
              000088888888884447888888888888888F88787F888888000000888888878874
              448888888888888887F8787F8888880000008888888448744488888888888888
              877F787F88888800000088888887444447888888888888888877777F88888800
              00008888888874447888888888888888888777F8888888000000888888888888
              8888888888888888888FF8888888880000008888888887447888888888888888
              88877F888888880000008888888884444888888888888888887887F888888800
              00008888888884444888888888888888887887F8888888000000888888888744
              788888888888888888877F88888888000000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bTracePollClick
          end
        end
        object OutMgrBtnPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 33
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 3
          Visible = False
          object bReread: TSpeedButton
            Left = 7
            Top = 3
            Width = 26
            Height = 26
            Hint = 'Rescan'
            Enabled = False
            Flat = True
            Glyph.Data = {
              DE010000424DDE01000000000000760000002800000024000000120000000100
              0400000000006801000000000000000000001000000010000000000000000000
              80000080000000808000800000008000800080800000C0C0C000808080000000
              FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333444444
              33333333333F8888883F33330000324334222222443333388F3833333388F333
              000032244222222222433338F8833FFFFF338F3300003222222AAAAA22243338
              F333F88888F338F30000322222A33333A2224338F33F8333338F338F00003222
              223333333A224338F33833333338F38F00003222222333333A444338FFFF8F33
              3338888300003AAAAAAA33333333333888888833333333330000333333333333
              333333333333333333FFFFFF000033333333333344444433FFFF333333888888
              00003A444333333A22222438888F333338F3333800003A2243333333A2222438
              F38F333333833338000033A224333334422224338338FFFFF8833338000033A2
              22444442222224338F3388888333FF380000333A2222222222AA243338FF3333
              33FF88F800003333AA222222AA33A3333388FFFFFF8833830000333333AAAAAA
              3333333333338888883333330000333333333333333333333333333333333333
              0000}
            NumGlyphs = 2
            ParentShowHint = False
            ShowHint = True
            OnClick = bRereadClick
          end
        end
      end
      object TopNotebookPanel: TPanel
        Left = 0
        Top = 0
        Width = 590
        Height = 250
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object DaemonPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 250
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 2
          Visible = False
          object MainDaemonPanel: TPanel
            Left = 8
            Top = 0
            Width = 574
            Height = 239
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
            object Panel7: TPanel
              Left = 0
              Top = 119
              Width = 574
              Height = 120
              Align = alBottom
              BevelOuter = bvNone
              TabOrder = 0
              object Panel9: TPanel
                Left = 0
                Top = 0
                Width = 91
                Height = 120
                Align = alLeft
                BevelOuter = bvNone
                BorderWidth = 8
                TabOrder = 0
                object DaemonPI: TPanel
                  Left = 8
                  Top = 8
                  Width = 75
                  Height = 16
                  Align = alTop
                  Alignment = taLeftJustify
                  BevelOuter = bvNone
                  Caption = ' Input'
                  TabOrder = 0
                end
                object Panel16: TPanel
                  Left = 8
                  Top = 24
                  Width = 75
                  Height = 88
                  Align = alClient
                  BorderWidth = 1
                  TabOrder = 1
                  object gInput: TNavyGauge
                    Left = 2
                    Top = 2
                    Width = 71
                    Height = 84
                    Align = alClient
                  end
                end
              end
              object Panel12: TPanel
                Left = 91
                Top = 0
                Width = 483
                Height = 120
                Align = alClient
                BevelOuter = bvNone
                BorderWidth = 8
                TabOrder = 1
                object DaemonPIH: TPanel
                  Left = 8
                  Top = 8
                  Width = 467
                  Height = 16
                  Align = alTop
                  Alignment = taLeftJustify
                  BevelOuter = bvNone
                  Caption = ' Input History'
                  TabOrder = 0
                end
                object Panel18: TPanel
                  Left = 8
                  Top = 24
                  Width = 467
                  Height = 88
                  Align = alClient
                  BorderWidth = 1
                  TabOrder = 1
                  object gInputGraph: TNavyGraph
                    Left = 2
                    Top = 2
                    Width = 463
                    Height = 84
                    Align = alClient
                  end
                end
              end
            end
            object Panel6: TPanel
              Left = 0
              Top = 0
              Width = 574
              Height = 119
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 1
              object Panel8: TPanel
                Left = 0
                Top = 0
                Width = 91
                Height = 119
                Align = alLeft
                BevelOuter = bvNone
                BorderWidth = 8
                TabOrder = 0
                object DaemonPO: TPanel
                  Left = 8
                  Top = 8
                  Width = 75
                  Height = 16
                  Align = alTop
                  Alignment = taLeftJustify
                  BevelOuter = bvNone
                  Caption = ' Output'
                  TabOrder = 0
                end
                object Panel111: TPanel
                  Left = 8
                  Top = 24
                  Width = 75
                  Height = 87
                  Align = alClient
                  BorderWidth = 1
                  TabOrder = 1
                  object gOutput: TNavyGauge
                    Left = 2
                    Top = 2
                    Width = 71
                    Height = 83
                    Align = alClient
                  end
                end
              end
              object Panel10: TPanel
                Left = 91
                Top = 0
                Width = 483
                Height = 119
                Align = alClient
                BevelOuter = bvNone
                BorderWidth = 8
                TabOrder = 1
                object DaemonPOH: TPanel
                  Left = 8
                  Top = 8
                  Width = 467
                  Height = 16
                  Align = alTop
                  Alignment = taLeftJustify
                  BevelOuter = bvNone
                  Caption = ' Output History'
                  TabOrder = 0
                end
                object Panel17: TPanel
                  Left = 8
                  Top = 24
                  Width = 467
                  Height = 87
                  Align = alClient
                  BorderWidth = 1
                  TabOrder = 1
                  object gOutputGraph: TNavyGraph
                    Left = 2
                    Top = 2
                    Width = 463
                    Height = 83
                    Align = alClient
                  end
                end
              end
            end
          end
          object Panel19: TPanel
            Left = 0
            Top = 239
            Width = 590
            Height = 11
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 1
          end
          object Panel20: TPanel
            Left = 582
            Top = 0
            Width = 8
            Height = 239
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 2
          end
          object Panel21: TPanel
            Left = 0
            Top = 0
            Width = 8
            Height = 239
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 3
          end
        end
        object PollsListPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 250
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          Visible = False
          object PollsListView: TListView
            Left = 0
            Top = 0
            Width = 590
            Height = 250
            Align = alClient
            AllocBy = 128
            BorderStyle = bsNone
            Columns = <
              item
                Caption = 'Node'
                Width = 100
              end
              item
                Caption = 'Numbers'
                Width = 170
              end
              item
                Caption = 'Owner'
                Width = 80
              end
              item
                Caption = 'State'
                Width = 60
              end
              item
                Caption = 'Busy'
                Width = 40
              end
              item
                Caption = 'No c.'
                Width = 40
              end
              item
                Caption = 'Fail'
                Width = 40
              end
              item
                Caption = 'Type'
                Width = 60
              end>
            ColumnClick = False
            ReadOnly = True
            RowSelect = True
            PopupMenu = PollPopupMenu
            TabOrder = 0
            ViewStyle = vsReport
            OnClick = PollsListViewClick
            OnDblClick = PollsListViewDblClick
            OnKeyDown = PollsListViewKeyDown
          end
        end
        object MailerAPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 250
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          Visible = False
          object TermsPanel: TPanel
            Left = 330
            Top = 0
            Width = 260
            Height = 250
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 0
            object TermTx: TMicroTerm
              Left = 8
              Top = 7
              Width = 248
              Height = 117
            end
            object TermRx: TMicroTerm
              Left = 8
              Top = 127
              Width = 248
              Height = 117
            end
          end
          object DialupInfoPanel: TPanel
            Left = 0
            Top = 0
            Width = 330
            Height = 250
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
            object StatusCarrier: TPanel
              Left = 0
              Top = 0
              Width = 330
              Height = 54
              Align = alTop
              BevelOuter = bvNone
              BorderWidth = 3
              TabOrder = 0
              object StatusBox: TGroupBox
                Left = 8
                Top = 3
                Width = 319
                Height = 48
                Align = alClient
                Caption = ' Status '
                TabOrder = 0
                object lStatus: TLabel
                  Left = 11
                  Top = 20
                  Width = 5
                  Height = 13
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWindowText
                  Font.Height = -12
                  Font.Name = 'MS Sans Serif'
                  Font.Style = [fsBold]
                  ParentFont = False
                  Transparent = True
                end
                object TimeoutBox: TPanel
                  Left = 225
                  Top = 15
                  Width = 92
                  Height = 31
                  Align = alRight
                  BevelOuter = bvNone
                  TabOrder = 0
                  Visible = False
                  object lTimeout: TLabel
                    Left = 58
                    Top = 4
                    Width = 5
                    Height = 16
                    Font.Charset = DEFAULT_CHARSET
                    Font.Color = clBlack
                    Font.Height = -15
                    Font.Name = 'MS Sans Serif'
                    Font.Style = [fsBold]
                    ParentFont = False
                  end
                  object bAdd: TSpeedButton
                    Left = 24
                    Top = 1
                    Width = 25
                    Height = 22
                    Glyph.Data = {
                      36010000424D3601000000000000760000002800000011000000100000000100
                      040000000000C000000000000000000000001000000010000000000000000000
                      80000080000000808000800000008000800080800000C0C0C000808080000000
                      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
                      333330000000333333333333333330000000333F333333333333300000003380
                      FF333333333330000000338000FF333333333000000033800000FF3333333000
                      00003380000000FF333330000000338000000000FF3330000000338000000000
                      88F3300000003380000000883333300000003380000088333333300000003380
                      0088333333333000000033808833333333333000000033883333333333333000
                      0000333333333333333330000000333333333333333330000000}
                    OnClick = bAddClick
                  end
                  object bStart: TSpeedButton
                    Left = 0
                    Top = 1
                    Width = 25
                    Height = 22
                    Glyph.Data = {
                      36010000424D3601000000000000760000002800000014000000100000000100
                      040000000000C000000000000000000000001000000010000000000000000000
                      80000080000000808000800000008000800080800000C0C0C000808080000000
                      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
                      333333330000333333333333333333330000338FF33333333333FF3300003380
                      F333333333FF0F3300003380F3333333FF000F3300003380F33333FF00000F33
                      00003380F333FF0000000F3300003380F33F000000000F3300003380F3880000
                      00000F3300003380F333880000000F3300003380F333338800000F3300003380
                      F333333388000F3300003380F333333333880F3300003388F333333333338F33
                      0000333333333333333333330000333333333333333333330000}
                    OnClick = bStartClick
                  end
                end
              end
              object Panel1: TPanel
                Left = 3
                Top = 3
                Width = 5
                Height = 48
                Align = alLeft
                BevelOuter = bvNone
                TabOrder = 1
              end
            end
          end
        end
        object MailerBPanel: TPanel
          Left = 0
          Top = 0
          Width = 590
          Height = 250
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 3
          Visible = False
          object Panel2: TPanel
            Left = 0
            Top = 0
            Width = 305
            Height = 250
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 0
            object SndBox: TGroupBox
              Left = 8
              Top = 8
              Width = 297
              Height = 85
              Caption = 'Sending'
              TabOrder = 0
              object lSndFile: TLabel
                Left = 16
                Top = 17
                Width = 113
                Height = 16
                AutoSize = False
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'Fixedsys'
                Font.Style = []
                ParentFont = False
                ParentShowHint = False
                ShowAccelChar = False
                ShowHint = True
              end
              object llSndCPS: TLabel
                Left = 188
                Top = 16
                Width = 21
                Height = 13
                Caption = 'CPS'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
                Visible = False
              end
              object lSndCPS: TLabel
                Left = 128
                Top = 16
                Width = 57
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
                Visible = False
              end
              object llSndSize: TLabel
                Left = 16
                Top = 60
                Width = 23
                Height = 13
                Caption = 'Size:'
                Visible = False
              end
              object lSndSize: TLabel
                Left = 45
                Top = 60
                Width = 5
                Height = 13
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
                Visible = False
              end
              object SndTot: TxGauge
                Left = 228
                Top = 16
                Width = 57
                Height = 57
                Kind = gkPie
                BorderStyle = bsNone
                Progress = 0
                Visible = False
              end
              object SndBar: TProgressBar
                Left = 12
                Top = 36
                Width = 203
                Height = 16
                Min = 0
                Max = 100
                TabOrder = 0
                Visible = False
              end
            end
            object RcvBox: TGroupBox
              Left = 8
              Top = 100
              Width = 297
              Height = 85
              Caption = 'Receiving'
              TabOrder = 1
              object lRcvFile: TLabel
                Left = 16
                Top = 17
                Width = 113
                Height = 16
                AutoSize = False
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'Fixedsys'
                Font.Style = []
                ParentFont = False
                ParentShowHint = False
                ShowAccelChar = False
                ShowHint = True
              end
              object llRcvCPS: TLabel
                Left = 188
                Top = 16
                Width = 21
                Height = 13
                Caption = 'CPS'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
                Visible = False
              end
              object lRcvCPS: TLabel
                Left = 128
                Top = 16
                Width = 57
                Height = 13
                Alignment = taRightJustify
                AutoSize = False
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
                Visible = False
              end
              object llRcvSize: TLabel
                Left = 16
                Top = 60
                Width = 23
                Height = 13
                Caption = 'Size:'
                Visible = False
              end
              object lRcvSize: TLabel
                Left = 45
                Top = 60
                Width = 5
                Height = 13
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentFont = False
                Visible = False
              end
              object RcvTot: TxGauge
                Left = 228
                Top = 16
                Width = 57
                Height = 57
                Kind = gkPie
                BorderStyle = bsNone
                Progress = 0
                Visible = False
              end
              object RcvBar: TProgressBar
                Left = 12
                Top = 36
                Width = 203
                Height = 16
                Min = 0
                Max = 100
                TabOrder = 0
                Visible = False
              end
            end
          end
          object Panel3: TPanel
            Left = 305
            Top = 0
            Width = 285
            Height = 250
            Align = alClient
            BevelOuter = bvNone
            BorderWidth = 12
            TabOrder = 1
            object SessionNfoPnl: TPanel
              Left = 12
              Top = 12
              Width = 261
              Height = 173
              Align = alTop
              BevelOuter = bvNone
              BorderStyle = bsSingle
              TabOrder = 0
              object gTitles: TAdvGrid
                Left = 0
                Top = 0
                Width = 60
                Height = 169
                FixedFont.Charset = DEFAULT_CHARSET
                FixedFont.Color = clBlack
                FixedFont.Height = -11
                FixedFont.Name = 'MS Sans Serif'
                FixedFont.Style = []
                Align = alLeft
                BorderStyle = bsNone
                Color = clBtnFace
                ColCount = 2
                DefaultColWidth = 59
                DefaultRowHeight = 18
                RowCount = 8
                FixedRows = 0
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'Fixedsys'
                Font.Style = []
                Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goFixedNumCols]
                ParentFont = False
                TabOrder = 0
              end
              object gNfo: TAdvGrid
                Left = 60
                Top = 0
                Width = 197
                Height = 169
                FixedFont.Charset = DEFAULT_CHARSET
                FixedFont.Color = clWindowText
                FixedFont.Height = -11
                FixedFont.Name = 'MS Sans Serif'
                FixedFont.Style = []
                Align = alClient
                BorderStyle = bsNone
                Color = clBtnFace
                ColCount = 1
                DefaultColWidth = 1000
                DefaultRowHeight = 18
                FixedCols = 0
                RowCount = 8
                FixedRows = 0
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clBlack
                Font.Height = -12
                Font.Name = 'Fixedsys'
                Font.Style = []
                Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goThumbTracking, goFixedNumCols]
                ParentFont = False
                TabOrder = 1
              end
            end
          end
        end
      end
      object OutMgrPanel: TPanel
        Left = 0
        Top = 0
        Width = 590
        Height = 25
        BevelOuter = bvNone
        TabOrder = 3
        Visible = False
        object OutMgrBevel: TBevel
          Left = 0
          Top = 23
          Width = 590
          Height = 2
          Align = alBottom
          Shape = bsBottomLine
        end
        object OutMgrHeader: THeaderControl
          Left = 0
          Top = 0
          Width = 590
          Height = 17
          DragReorder = False
          HotTrack = True
          Sections = <
            item
              ImageIndex = -1
              Text = 'Outbound'
              Width = 290
            end
            item
              Alignment = taRightJustify
              ImageIndex = -1
              Text = 'Size'
              Width = 100
            end
            item
              ImageIndex = -1
              Text = 'Type'
              Width = 60
            end
            item
              ImageIndex = -1
              Text = 'On sent'
              Width = 60
            end
            item
              ImageIndex = -1
              Text = 'Age'
              Width = 80
            end>
          OnSectionClick = OutMgrHeaderSectionClick
          OnSectionResize = OutMgrHeaderSectionResize
        end
        object OutMgrOutline: TxOutlin
          Left = 0
          Top = 17
          Width = 590
          Height = 6
          FixedFont.Charset = DEFAULT_CHARSET
          FixedFont.Color = clWindowText
          FixedFont.Height = -11
          FixedFont.Name = 'MS Sans Serif'
          FixedFont.Style = []
          OutlineStyle = osText
          Options = []
          Style = otOwnerDraw
          ItemHeight = 16
          OnDrawItem = OutMgrOutlineDrawItem
          Align = alClient
          Font.Charset = ANSI_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'MS Sans Serif'
          Font.Pitch = fpFixed
          Font.Style = []
          TabOrder = 1
          OnMouseDown = OutMgrOutlineMouseDown
          OnDblClick = OutMgrOutlineDblClick
          OnKeyDown = OutMgrOutlineKeyDown
          BorderStyle = bsNone
          ItemSeparator = '\'
          ParentFont = False
          PopupMenu = OutMgrPopup
          OnApiDropFiles = OutMgrOutlineApiDropFiles
          Data = {1F}
        end
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 208
    Top = 208
    object mSystem: TMenuItem
      Caption = '&System'
      HelpContext = 1560
      object msOpenDialup: TMenuItem
        Caption = 'Open Dial-up Line'
      end
      object mfRunIPDaemon: TMenuItem
        Caption = 'TCP/IP Daemon'
        Enabled = False
        OnClick = mfRunIPDaemonClick
      end
      object msLineA: TMenuItem
        Caption = '-'
      end
      object msInterfaceLanguage: TMenuItem
        Caption = 'Interface &Language'
        object ilDanish: TMenuItem
          Tag = 11
          Caption = 'D&anish'
          GroupIndex = 2
          RadioItem = True
          OnClick = mclEnglishUKClick
        end
        object ilDutch: TMenuItem
          Tag = 9
          Caption = '&Dutch'
          Enabled = False
          GroupIndex = 2
          RadioItem = True
          OnClick = mclEnglishUKClick
        end
        object ilEnglishUK: TMenuItem
          Caption = '&English (UK)'
          GroupIndex = 2
          RadioItem = True
          OnClick = mclEnglishUKClick
        end
        object ilGerman: TMenuItem
          Tag = 8
          Caption = '&German'
          GroupIndex = 2
          RadioItem = True
          OnClick = mclEnglishUKClick
        end
        object ilRomanian: TMenuItem
          Tag = 3
          Caption = 'Ro&manian'
          Enabled = False
          GroupIndex = 2
          RadioItem = True
        end
        object ilRussian: TMenuItem
          Tag = 1
          Caption = '&Russian'
          GroupIndex = 2
          RadioItem = True
          OnClick = mclEnglishUKClick
        end
        object ilMitky: TMenuItem
          Caption = 'Russian (Mitk&y)'
          Enabled = False
          GroupIndex = 2
          RadioItem = True
        end
        object ilSpanish: TMenuItem
          Tag = 10
          Caption = '&Spanish'
          Enabled = False
          GroupIndex = 2
          RadioItem = True
          OnClick = mclEnglishUKClick
        end
      end
      object msLineB: TMenuItem
        Caption = '-'
      end
      object mwCreateMirror: TMenuItem
        Caption = '&Mirror '
        ShortCut = 115
        OnClick = mwCreateMirrorClick
      end
      object mwClose: TMenuItem
        Caption = '&Close Window'
        ShortCut = 32883
        OnClick = mwCloseClick
      end
      object N17: TMenuItem
        Caption = '-'
      end
      object mfExit: TMenuItem
        Caption = 'E&xit'
        ShortCut = 32856
        OnClick = mfExitClick
      end
    end
    object mLine: TMenuItem
      Caption = '&Line'
      HelpContext = 1540
      object mlAbortOperation: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333331111133
          333391331999991133339911999999991333999999FFFF99913399999F3333F9
          991399999333333F991399999933333F9913FFFFFFF333333333333333333311
          1111F99133333F999991F991333333F999913F991333311999913F9991111999
          999133F999999999FF91333FF99999FF33F333333FFFFF333333}
        Caption = '&Reset'
        Enabled = False
        ShortCut = 27
        OnClick = bAbortClick
      end
      object mlAnswer: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
          33333333330003333333333333080333333333B33B000B33B333333BBB0B0BBB
          3333333BBB0F0BBB333333BBB0F7F0BBB33333BB0FB7BF0BB333BBBB0BF7FB0B
          BBB333BB0FBFBF0BB33333BBB0FBF0BBB333333BBB000BBB3333333BBBBBBBBB
          333333B33BBBBB33B3333333333B333333333333333B33333333}
        Caption = '&Answer Call'
        Enabled = False
        ShortCut = 16449
        OnClick = bAnswerClick
      end
      object N13: TMenuItem
        Caption = '-'
      end
      object mlSendMdmCmds: TMenuItem
        Caption = 'Send &Modem Commands'
        Enabled = False
        ShortCut = 120
        OnClick = mlSendMdmCmdsClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mlResetTimeout: TMenuItem
        Caption = '&Flush Timeout'
        Enabled = False
        ShortCut = 16418
        OnClick = bStartClick
      end
      object mlIncTimeout: TMenuItem
        Caption = 'Add to &Timeout'
        Enabled = False
        ShortCut = 16417
        OnClick = bAddClick
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object mlSkip: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00344446333334
          444333AAA43333332A433332A46333332A433332A2433336A66333336AA4462A
          4633333332AA222463333333336AAA22646333444466AA436A43336AA246A243
          6A4333336A24AA442A43333333322AAA43333333333322A43333333333344A43
          333333333336A243333333333336AA4333333333333366633333}
        Caption = 'Skip File (receive &later)'
        Enabled = False
        ShortCut = 16460
        OnClick = bSkipClick
      end
      object mlRefuse: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00311116333331
          1113339991333333291333329163333329133332921333369663333399163362
          9133333332992291633333333369992261333311116699136913336992169213
          6913333369219911291333333332299913333333333322913333333333311913
          3333333333369213333333333336991333333333333366633333}
        Caption = '&Reject File'
        Enabled = False
        ShortCut = 16466
        OnClick = bRefuseClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object mlClose: TMenuItem
        Caption = '&Close'
        Enabled = False
        ShortCut = 16498
        OnClick = mlCloseClick
      end
    end
    object mPoll: TMenuItem
      Caption = '&Poll'
      HelpContext = 1550
      object mpCreate: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003B3444444444
          44333BB4ECCCCCCCC4BB3CC4E8080808C4B3C334EEEEEEEEC433C3334E80808E
          4333C33334EEEEE43333B4CCB4444444BBBBB4CCC4BBBBB4BBBB34CCC48BB333
          333334EECCCBB34C443333CEEEC44C4CCC43333444EEEECEEE43333BB7C44CEE
          CC3333BB333BB74CCB333BB3333BB3333BB33B33333BB33333B3}
        Caption = '&Create'
        ShortCut = 116
        OnClick = bNewPollClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mpDelete: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00337733333333
          33333D55733333D733333D5557333D5573333D555573D555573333D555575555
          5733333D5555555573333333D55555573333333335555573333333333D555573
          33333333D55555733333333D55575557333333D55573D555733333D557333D55
          5733333D533333D5553333333333333D5D333333333333333333}
        Caption = '&Delete'
        Enabled = False
        ShortCut = 16500
        OnClick = bDeletePollClick
      end
      object mpReset: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333334444433
          333324334222224433332244222222224333222222AAAA22243322222A3333A2
          224322222333333A224322222233333A4443AAAAAAA333333333333333333344
          4444A44433333A222224A224333333A222243A224333344222243A2224444222
          222433A222222222AA24333AA22222AA33A333333AAAAA333333}
        Caption = '&Reset'
        Enabled = False
        ShortCut = 32884
        OnClick = bResetPollClick
      end
      object mpTrace: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888887444788
          8888888874444478888888884447844888888888444788788888888874447888
          8888888887444788888888888874478888888888788444788888888844874478
          8888888874444478888888888744478888888888888888888888888888744788
          8888888888444488888888888844448888888888887447888888}
        Caption = '&Info'
        Enabled = False
        ShortCut = 8308
        OnClick = bTracePollClick
      end
      object mpDeleteAll: TMenuItem
        Bitmap.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          0400000000008000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00339117333339
          7333369111733391173391911117391111739119111171111173911191111111
          1733391119111111733333911111111733333339119111173333333319111117
          3333333391117111733333391117191117333399117111911173391191391119
          1113391163339111919333913333391113333333333333919333}
        Caption = 'Delete &All'
        Enabled = False
        ShortCut = 24692
        OnClick = bDeleteAllPollsClick
      end
    end
    object mTool: TMenuItem
      Caption = '&Tool'
      HelpContext = 1570
      object mtCompileNodelist: TMenuItem
        Caption = '&Compile Nodelist'
        ShortCut = 8309
        OnClick = mtCompileNodelistClick
      end
      object mtCompileNodelistInv: TMenuItem
        Caption = '&Compile Nodelist'
        ShortCut = 32885
        Visible = False
      end
      object mtBrowseNodelist: TMenuItem
        Caption = '&Browse Nodelist'
        ShortCut = 117
        OnClick = mtBrowseNodelistClick
      end
      object mtBrowseNodelistAt: TMenuItem
        Caption = 'Browse Nodelist at...'
        ShortCut = 16501
        OnClick = mtBrowseNodelistAtClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mtEditFileRequest: TMenuItem
        Caption = 'Edit File &Request...'
        ShortCut = 118
        OnClick = mtEditFileRequestClick
      end
      object mtAttachFiles: TMenuItem
        Caption = 'Attach Files...'
        ShortCut = 119
        OnClick = mtAttachFilesClick
      end
      object mtCreateFlag: TMenuItem
        Caption = 'Create a Flag...'
        ShortCut = 16503
        OnClick = mtCreateFlagClick
      end
      object mtOutSmartMenu: TMenuItem
        Caption = 'Outbound SmartMenu™'
        Enabled = False
        ShortCut = 32
        OnClick = mtOutSmartMenuClick
      end
    end
    object mConfig: TMenuItem
      Caption = '&Config'
      HelpContext = 1520
      object mcMasterPassword: TMenuItem
        Caption = '&Master Password'
        object mcMasterPwdCreate: TMenuItem
          Caption = 'Set Up...'
          Enabled = False
          OnClick = mcMasterPwdCreateClick
        end
        object mcMasterPwdChange: TMenuItem
          Caption = 'Change...'
          Enabled = False
          OnClick = mcMasterPwdChangeClick
        end
        object mcMasterPwdRemove: TMenuItem
          Caption = 'Remove...'
          Enabled = False
          OnClick = mcMasterPwdRemoveClick
        end
      end
      object mcStartup: TMenuItem
        Caption = '&Start-up'
        HelpContext = 1040
        ShortCut = 16467
        OnClick = mcStartupClick
      end
      object mcPathnames: TMenuItem
        Caption = '&Paths'
        ShortCut = 16464
        OnClick = mcPathnamesClick
      end
      object mcNodelist: TMenuItem
        Caption = '&Nodelist'
        ShortCut = 16462
        OnClick = mcNodelistClick
      end
      object mcPasswords: TMenuItem
        Caption = 'Pass&words'
        ShortCut = 16471
        OnClick = NodesPasswords1Click
      end
      object N16: TMenuItem
        Caption = '-'
      end
      object mcDialup: TMenuItem
        Caption = '&Dial-up'
        ShortCut = 16452
        OnClick = mcDialupClick
      end
      object mcDaemon: TMenuItem
        Caption = '&TCP/IP Daemon'
        ShortCut = 16468
        OnClick = mcDaemonClick
      end
      object N15: TMenuItem
        Caption = '-'
      end
      object mcFileBoxes: TMenuItem
        Caption = 'File-&boxes'
        ShortCut = 16450
        OnClick = mcFileBoxesClick
      end
      object mcPolls: TMenuItem
        Caption = 'P&olls'
        ShortCut = 16463
        OnClick = mcPollsClick
      end
      object maFileRequests: TMenuItem
        Caption = '&File Requests'
        ShortCut = 16454
        OnClick = maFileRequestsClick
      end
      object maExternals: TMenuItem
        Caption = 'E&xternals'
        ShortCut = 16472
        OnClick = mcExternalsClick
      end
      object maEvents: TMenuItem
        Caption = 'E&vents'
        ShortCut = 16470
        OnClick = maEventsClick
      end
      object maEncryptedLinks: TMenuItem
        Caption = '&Encrypted Links'
        ShortCut = 16453
        OnClick = maEncryptedLinksClick
      end
      object N23: TMenuItem
        Caption = '-'
      end
      object maNodes: TMenuItem
        Caption = 'Node &Inspector'
        ShortCut = 16457
        OnClick = maNodesClick
      end
    end
    object mHelp: TMenuItem
      Caption = '&Help'
      HelpContext = 1530
      object mhContents: TMenuItem
        Caption = 'Help &Topics'
        ShortCut = 112
        OnClick = mhContentsClick
      end
      object mhLanguage: TMenuItem
        Caption = 'Help &Language'
        object hlDanish: TMenuItem
          Caption = 'D&anish'
          Enabled = False
          GroupIndex = 1
          OnClick = hlDanishClick
        end
        object hlDutch: TMenuItem
          Caption = '&Dutch'
          Enabled = False
          GroupIndex = 1
          RadioItem = True
          OnClick = hlDutchClick
        end
        object hlEnglish: TMenuItem
          Caption = '&English (UK)'
          Enabled = False
          GroupIndex = 1
          RadioItem = True
          OnClick = hlEnglishClick
        end
        object hlGerman: TMenuItem
          Caption = '&German'
          Enabled = False
          GroupIndex = 1
          RadioItem = True
          OnClick = hlGermanClick
        end
        object hlRomainian: TMenuItem
          Caption = 'Ro&manian'
          Enabled = False
          GroupIndex = 1
          RadioItem = True
        end
        object hlRussian: TMenuItem
          Caption = '&Russian'
          Enabled = False
          GroupIndex = 1
          RadioItem = True
          OnClick = hlRussianClick
        end
        object hlMitky: TMenuItem
          Caption = 'Russian (Mitk&y)'
          Enabled = False
          GroupIndex = 1
          RadioItem = True
        end
        object hlSpanish: TMenuItem
          Caption = '&Spanish'
          Enabled = False
          GroupIndex = 1
          RadioItem = True
          OnClick = hlSpanishClick
        end
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object mhWebSite: TMenuItem
        Caption = 'Argus &Web Site (on-line)'
        OnClick = mhWebSiteClick
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object mhLicence: TMenuItem
        Caption = '&Licence'
        OnClick = mhLicenceClick
      end
      object mhAbout: TMenuItem
        Caption = '&About'
        ShortCut = 32880
        OnClick = mhAboutClick
      end
    end
  end
  object PollPopupMenu: TPopupMenu
    OnPopup = PollPopupMenuPopup
    Left = 294
    Top = 210
    object ppCreatePoll: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003B3444444444
        44333BB4ECCCCCCCC4BB3CC4E8080808C4B3C334EEEEEEEEC433C3334E80808E
        4333C33334EEEEE43333B4CCB4444444BBBBB4CCC4BBBBB4BBBB34CCC48BB333
        333334EECCCBB34C443333CEEEC44C4CCC43333444EEEECEEE43333BB7C44CEE
        CC3333BB333BB74CCB333BB3333BB3333BB33B33333BB33333B3}
      Caption = '&Create'
      ShortCut = 116
      OnClick = bNewPollClick
    end
    object N11: TMenuItem
      Caption = '-'
    end
    object ppTracePoll: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888887444788
        8888888874444478888888884447844888888888444788788888888874447888
        8888888887444788888888888874478888888888788444788888888844874478
        8888888874444478888888888744478888888888888888888888888888744788
        8888888888444488888888888844448888888888887447888888}
      Caption = '&Info'
      Enabled = False
      ShortCut = 16500
      OnClick = bTracePollClick
    end
    object ppResetPoll: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333334444433
        333324334222224433332244222222224333222222AAAA22243322222A3333A2
        224322222333333A224322222233333A4443AAAAAAA333333333333333333344
        4444A44433333A222224A224333333A222243A224333344222243A2224444222
        222433A222222222AA24333AA22222AA33A333333AAAAA333333}
      Caption = '&Reset'
      Enabled = False
      ShortCut = 8308
      OnClick = bResetPollClick
    end
    object ppDeletePoll: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00337733333333
        33333D55733333D733333D5557333D5573333D555573D555573333D555575555
        5733333D5555555573333333D55555573333333335555573333333333D555573
        33333333D55555733333333D55575557333333D55573D555733333D557333D55
        5733333D533333D5553333333333333D5D333333333333333333}
      Caption = '&Delete'
      Enabled = False
      ShortCut = 32884
      OnClick = bDeletePollClick
    end
    object ppDeleteAllPolls: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00339117333339
        7333369111733391173391911117391111739119111171111173911191111111
        1733391119111111733333911111111733333339119111173333333319111117
        3333333391117111733333391117191117333399117111911173391191391119
        1113391163339111919333913333391113333333333333919333}
      Caption = 'Delete &All'
      Enabled = False
      ShortCut = 24692
      OnClick = bDeleteAllPollsClick
    end
  end
  object OutMgrPopup: TPopupMenu
    HelpContext = 2070
    OnPopup = OutMgrPopupPopup
    Left = 326
    Top = 210
    object ompHelp: TMenuItem
      Caption = 'Help on SmartMenu™'
      OnClick = ompHelpClick
    end
    object N25: TMenuItem
      Caption = '-'
    end
    object ompRescan: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333334444433
        333324334222224433332244222222224333222222AAAA22243322222A3333A2
        224322222333333A224322222233333A4443AAAAAAA333333333333333333344
        4444A44433333A222224A224333333A222243A224333344222243A2224444222
        222433A222222222AA24333AA22222AA33A333333AAAAA333333}
      Caption = 'Rescan Outbound'
      OnClick = bRereadClick
    end
    object N14: TMenuItem
      Caption = '-'
    end
    object ompPoll: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003B3444444444
        44333BB4ECCCCCCCC4BB3CC4E8080808C4B3C334EEEEEEEEC433C3334E80808E
        4333C33334EEEEE43333B4CCB4444444BBBBB4CCC4BBBBB4BBBB34CCC48BB333
        333334EECCCBB34C443333CEEEC44C4CCC43333444EEEECEEE43333BB7C44CEE
        CC3333BB333BB74CCB333BB3333BB3333BB33B33333BB33333B3}
      Caption = 'Poll 2:469/38'
      OnClick = ompPollClick
    end
    object ompAttach: TMenuItem
      Caption = 'Attach to 2:469/38'
      OnClick = ompAttachClick
    end
    object ompEditFreq: TMenuItem
      Caption = 'Edit file request for 2:469/38'
      OnClick = ompEditFreqClick
    end
    object ompBrowseNL: TMenuItem
      Caption = 'Browse nodelist at 2:469/38'
      OnClick = ompBrowseNLClick
    end
    object ompCreateFlag: TMenuItem
      Caption = 'Create Flag for 2:469/38'
      object ompCfCrash: TMenuItem
        Caption = 'Crash'
        OnClick = ompCfCrashClick
      end
      object ompCfDirect: TMenuItem
        Caption = 'Direct'
        OnClick = ompCfDirectClick
      end
      object ompCfNormal: TMenuItem
        Caption = 'Normal'
        OnClick = ompCfNormalClick
      end
      object ompCfHold: TMenuItem
        Caption = 'Hold'
        OnClick = ompCfHoldClick
      end
    end
    object N22: TMenuItem
      Caption = '-'
    end
    object ompOpen: TMenuItem
      Caption = 'Open Current File'
      OnClick = ompOpenClick
    end
    object ompCur: TMenuItem
      Tag = 1
      Caption = '000032e3.su2'
      object opmReaddress: TMenuItem
        Caption = 'Readdress'
        OnClick = opmReaddressClick
      end
      object opmFinalize: TMenuItem
        Caption = 'Finalise'
        OnClick = opmFinalizeClick
      end
      object N21: TMenuItem
        Caption = '-'
      end
      object opmCrash: TMenuItem
        Caption = 'Change to Crash'
        OnClick = opmCrashClick
      end
      object opmDirect: TMenuItem
        Caption = 'Change to Direct'
        OnClick = opmDirectClick
      end
      object opmNormal: TMenuItem
        Caption = 'Change to Normal'
        OnClick = opmNormalClick
      end
      object opmHold: TMenuItem
        Caption = 'Change to Hold'
        OnClick = opmHoldClick
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object opmUnlink: TMenuItem
        Caption = 'Unlink'
        OnClick = opmUnlinkClick
      end
      object opmPurge: TMenuItem
        Caption = 'Remove Broken Links'
        OnClick = opmPurgeClick
      end
    end
    object N20: TMenuItem
      Caption = '-'
    end
    object ompName: TMenuItem
      Tag = 2
      Caption = '000032e3.* of 2:469/38'
    end
    object ompExt: TMenuItem
      Tag = 3
      Caption = '*.su?  of 2:469/38'
    end
    object ompStat: TMenuItem
      Tag = 4
      Caption = 'All Hold Files of 2:469/38'
      Enabled = False
    end
    object ompAll: TMenuItem
      Tag = 5
      Caption = 'All Entries of 2:469/38'
    end
    object N18: TMenuItem
      Caption = '-'
    end
    object ompEntire: TMenuItem
      Tag = 6
      Caption = 'Entire Outbound'
    end
  end
  object TrayPopupMenu: TPopupMenu
    Left = 246
    Top = 210
    object tpRestore: TMenuItem
      Caption = '&Restore'
      OnClick = tpRestoreClick
    end
    object N10: TMenuItem
      Caption = '-'
    end
    object tpCreatePoll: TMenuItem
      Bitmap.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003B3444444444
        44333BB4ECCCCCCCC4BB3CC4E8080808C4B3C334EEEEEEEEC433C3334E80808E
        4333C33334EEEEE43333B4CCB4444444BBBBB4CCC4BBBBB4BBBB34CCC48BB333
        333334EECCCBB34C443333CEEEC44C4CCC43333444EEEECEEE43333BB7C44CEE
        CC3333BB333BB74CCB333BB3333BB3333BB33B33333BB33333B3}
      Caption = 'Create &Poll'
      OnClick = tpCreatePollClick
    end
    object N24: TMenuItem
      Caption = '-'
    end
    object tpEditFileRequest: TMenuItem
      Caption = 'Edit File Request'
      OnClick = tpEditFileRequestClick
    end
    object tpBrowseNodelist: TMenuItem
      Caption = '&Browse Nodelist'
      OnClick = tpBrowseNodelistClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object tpExit: TMenuItem
      Caption = 'E&xit'
      OnClick = mfExitClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object tpCancel: TMenuItem
      Caption = 'Cancel'
    end
  end
end
