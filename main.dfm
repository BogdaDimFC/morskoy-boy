object Form1: TForm1
  Left = 240
  Top = 217
  Width = 558
  Height = 341
  Caption = #1052#1086#1088#1089#1082#1086#1081' '#1073#1086#1081
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Shape1: TShape
    Left = 144
    Top = 56
    Width = 17
    Height = 17
    Visible = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 274
    Width = 550
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
  object MainMenu1: TMainMenu
    Left = 16
    Top = 8
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N8: TMenuItem
        Caption = #1053#1086#1074#1072#1103' '#1080#1075#1088#1072
        OnClick = N8Click
      end
      object N2: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        OnClick = N2Click
      end
    end
    object N3: TMenuItem
      Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080
      object N4: TMenuItem
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1082#1083#1080#1077#1085#1090#1072
        OnClick = N4Click
      end
      object N5: TMenuItem
        Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1080' '#1089#1077#1088#1074#1077#1088#1072
        OnClick = N5Click
      end
      object N6: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1080#1075#1088#1091
        Enabled = False
        OnClick = N6Click
      end
      object N7: TMenuItem
        Caption = #1055#1086#1076#1082#1083#1102#1095#1080#1090#1100#1089#1103' '#1082' '#1080#1075#1088#1077
        Enabled = False
        OnClick = N7Click
      end
    end
  end
end
