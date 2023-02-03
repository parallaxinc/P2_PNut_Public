object InfoForm: TInfoForm
  Left = 5
  Top = 2084
  BorderStyle = bsSingle
  Caption = 'Object Info'
  ClientHeight = 405
  ClientWidth = 405
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
  object Bevel2: TBevel
    Left = 10
    Top = 276
    Width = 316
    Height = 119
    Style = bsRaised
  end
  object Bevel1: TBevel
    Left = 10
    Top = 10
    Width = 385
    Height = 257
    Style = bsRaised
  end
  object Label4: TLabel
    Left = 30
    Top = 138
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'Object :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label5: TLabel
    Left = 30
    Top = 167
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'Variable :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 30
    Top = 197
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'Stack / Free :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label7: TLabel
    Left = 30
    Top = 295
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'Clock Mode :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label8: TLabel
    Left = 30
    Top = 325
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'Clock Freq :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label1: TLabel
    Left = 30
    Top = 30
    Width = 80
    Height = 20
    AutoSize = False
    Caption = '$00000'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object HubTopLabel: TLabel
    Left = 295
    Top = 30
    Width = 80
    Height = 20
    Alignment = taRightJustify
    AutoSize = False
    Caption = '$7FFFF'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label3: TLabel
    Left = 30
    Top = 20
    Width = 345
    Height = 30
    Alignment = taCenter
    AutoSize = False
    Caption = 'Hub RAM Usage'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -20
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object FreqLabel: TLabel
    Left = 148
    Top = 325
    Width = 158
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Hz'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object ClockLabel: TLabel
    Left = 148
    Top = 295
    Width = 158
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Mode'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object StackLabel: TLabel
    Left = 148
    Top = 197
    Width = 168
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object VariableLabel: TLabel
    Left = 148
    Top = 167
    Width = 168
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object ProgramLabel: TLabel
    Left = 148
    Top = 138
    Width = 168
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object MapImage: TImage
    Left = 30
    Top = 59
    Width = 345
    Height = 31
  end
  object Label9: TLabel
    Left = 345
    Top = 138
    Width = 30
    Height = 21
    AutoSize = False
    Color = clRed
    ParentColor = False
  end
  object Label10: TLabel
    Left = 345
    Top = 167
    Width = 30
    Height = 21
    AutoSize = False
    Color = clYellow
    ParentColor = False
  end
  object Label11: TLabel
    Left = 345
    Top = 197
    Width = 30
    Height = 21
    AutoSize = False
    Color = clAqua
    ParentColor = False
  end
  object Bevel3: TBevel
    Left = 30
    Top = 59
    Width = 345
    Height = 31
  end
  object Bevel4: TBevel
    Left = 345
    Top = 138
    Width = 30
    Height = 21
  end
  object Bevel5: TBevel
    Left = 345
    Top = 167
    Width = 30
    Height = 21
  end
  object Bevel6: TBevel
    Left = 345
    Top = 197
    Width = 30
    Height = 21
  end
  object InputFreqLabel: TLabel
    Left = 148
    Top = 354
    Width = 158
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Hz'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label12: TLabel
    Left = 30
    Top = 354
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'XI Input Freq :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label13: TLabel
    Left = 30
    Top = 108
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'Interpreter :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object InterpreterLabel: TLabel
    Left = 148
    Top = 108
    Width = 168
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Bevel7: TBevel
    Left = 345
    Top = 108
    Width = 30
    Height = 21
  end
  object Label15: TLabel
    Left = 345
    Top = 108
    Width = 30
    Height = 21
    AutoSize = False
    Color = clWhite
    ParentColor = False
  end
  object Bevel8: TBevel
    Left = 345
    Top = 108
    Width = 30
    Height = 21
  end
  object Label2: TLabel
    Left = 30
    Top = 226
    Width = 119
    Height = 21
    AutoSize = False
    Caption = 'Debugger :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object DebuggerLabel: TLabel
    Left = 148
    Top = 226
    Width = 168
    Height = 21
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'bytes'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBtnText
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
  end
  object Label16: TLabel
    Left = 345
    Top = 226
    Width = 30
    Height = 21
    AutoSize = False
    Color = clBlack
    ParentColor = False
  end
  object Bevel9: TBevel
    Left = 345
    Top = 226
    Width = 30
    Height = 21
  end
  object OkButton: TButton
    Left = 335
    Top = 276
    Width = 60
    Height = 119
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
end
