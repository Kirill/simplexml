object TestForm: TTestForm
  Left = 267
  Top = 132
  Width = 696
  Height = 480
  Caption = 'TestForm'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 16
  object Button1: TButton
    Left = 40
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Open'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 40
    Top = 60
    Width = 361
    Height = 309
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Button2: TButton
    Left = 128
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Save'
    TabOrder = 2
    OnClick = Button2Click
  end
end
