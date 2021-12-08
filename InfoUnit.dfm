object InfoForm: TInfoForm
  Left = 854
  Top = 1048
  BorderStyle = bsSingle
  Caption = 'Object Info'
  ClientHeight = 329
  ClientWidth = 329
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
  object Bevel2: TBevel
    Left = 8
    Top = 224
    Width = 257
    Height = 97
    Style = bsRaised
  end
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 313
    Height = 209
    Style = bsRaised
  end
  object Label4: TLabel
    Left = 24
    Top = 112
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'Object :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 24
    Top = 136
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'Variable :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 24
    Top = 160
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'Stack / Free :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 24
    Top = 240
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'Clock Mode :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 24
    Top = 264
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'Clock Freq :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 65
    Height = 17
    AutoSize = False
    Caption = '$00000'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object HubTopLabel: TLabel
    Left = 240
    Top = 24
    Width = 65
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = '$7FFFF'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 24
    Top = 16
    Width = 281
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'Hub RAM Usage'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object FreqLabel: TLabel
    Left = 120
    Top = 264
    Width = 129
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Hz'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object ClockLabel: TLabel
    Left = 120
    Top = 240
    Width = 129
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Mode'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object StackLabel: TLabel
    Left = 120
    Top = 160
    Width = 137
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object VariableLabel: TLabel
    Left = 120
    Top = 136
    Width = 137
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object ProgramLabel: TLabel
    Left = 120
    Top = 112
    Width = 137
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object MapImage: TImage
    Left = 24
    Top = 48
    Width = 281
    Height = 25
  end
  object Label9: TLabel
    Left = 280
    Top = 112
    Width = 25
    Height = 17
    AutoSize = False
    Color = clRed
    ParentColor = False
  end
  object Label10: TLabel
    Left = 280
    Top = 136
    Width = 25
    Height = 17
    AutoSize = False
    Color = clYellow
    ParentColor = False
  end
  object Label11: TLabel
    Left = 280
    Top = 160
    Width = 25
    Height = 17
    AutoSize = False
    Color = clAqua
    ParentColor = False
  end
  object Bevel3: TBevel
    Left = 24
    Top = 48
    Width = 281
    Height = 25
  end
  object Bevel4: TBevel
    Left = 280
    Top = 112
    Width = 25
    Height = 17
  end
  object Bevel5: TBevel
    Left = 280
    Top = 136
    Width = 25
    Height = 17
  end
  object Bevel6: TBevel
    Left = 280
    Top = 160
    Width = 25
    Height = 17
  end
  object InputFreqLabel: TLabel
    Left = 120
    Top = 288
    Width = 129
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Hz'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label12: TLabel
    Left = 24
    Top = 288
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'XI Input Freq :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label13: TLabel
    Left = 24
    Top = 88
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'Interpreter :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object InterpreterLabel: TLabel
    Left = 120
    Top = 88
    Width = 137
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Bevel7: TBevel
    Left = 280
    Top = 88
    Width = 25
    Height = 17
  end
  object Label15: TLabel
    Left = 280
    Top = 88
    Width = 25
    Height = 17
    AutoSize = False
    Color = clWhite
    ParentColor = False
  end
  object Bevel8: TBevel
    Left = 280
    Top = 88
    Width = 25
    Height = 17
  end
  object Label2: TLabel
    Left = 24
    Top = 184
    Width = 97
    Height = 17
    AutoSize = False
    Caption = 'Debugger :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object DebuggerLabel: TLabel
    Left = 120
    Top = 184
    Width = 137
    Height = 17
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label16: TLabel
    Left = 280
    Top = 184
    Width = 25
    Height = 17
    AutoSize = False
    Color = clBlack
    ParentColor = False
  end
  object Bevel9: TBevel
    Left = 280
    Top = 184
    Width = 25
    Height = 17
  end
  object OkButton: TButton
    Left = 272
    Top = 224
    Width = 49
    Height = 97
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
end
