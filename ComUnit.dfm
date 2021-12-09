object ComForm: TComForm
  Left = 672
  Top = 279
  Anchors = []
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'COM Port'
  ClientHeight = 73
  ClientWidth = 132
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 48
    Top = 8
    Width = 73
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Color = clScrollBar
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object ComLabel: TLabel
    Left = 48
    Top = 12
    Width = 73
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'COM'
    Color = clScrollBar
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 48
    Top = 8
    Width = 73
    Height = 25
  end
  object OKButton: TButton
    Left = 48
    Top = 40
    Width = 73
    Height = 25
    Cancel = True
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    TabStop = False
  end
  object PortUpDown: TUpDown
    Left = 8
    Top = 8
    Width = 33
    Height = 57
    AlignButton = udLeft
    ArrowKeys = False
    Min = 1
    Max = 99
    Position = 3
    TabOrder = 1
    Wrap = True
    OnClick = PortUpDownClick
  end
end
