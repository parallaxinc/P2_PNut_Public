object ComForm: TComForm
  Left = 19
  Top = 2302
  Anchors = []
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'COM Port'
  ClientHeight = 90
  ClientWidth = 170
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnActivate = FormActivate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 59
    Top = 10
    Width = 90
    Height = 31
    Alignment = taCenter
    AutoSize = False
    Color = clScrollBar
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object ComLabel: TLabel
    Left = 59
    Top = 15
    Width = 90
    Height = 21
    Alignment = taCenter
    AutoSize = False
    Caption = 'COM'
    Color = clScrollBar
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clDefault
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentColor = False
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = 59
    Top = 10
    Width = 90
    Height = 31
  end
  object OKButton: TButton
    Left = 59
    Top = 49
    Width = 90
    Height = 31
    Cancel = True
    Caption = 'OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    TabStop = False
  end
  object PortUpDown: TUpDown
    Left = 10
    Top = 10
    Width = 40
    Height = 70
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
