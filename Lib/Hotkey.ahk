/*
	Hotkey
	# Required files
	# Tip.ahk
	# String.ahk
	# Utility.ahk
	# Math.ahk
	# Array.ahk
	# Enum.ahk
	# WinEventHook.ahk
	# Gui.ahk
	# Plugin.ahk
*/
class OutputType extends EnumObject
{
	; Constructor
	__New()
	{
		base.__New("Single", "Double", "Long")
	}
}

class HotkeyData
{
	; Variables
	static KM_NEW := 0x8000
	static KM_DELETE := 0x8001
	static KM_ENABLE := 0x8002
	static KM_DISABLE := 0x8003
	static unBindFunc := ObjBindMethod(HotkeyData, "UnBind")
	e_output := ""
	inputKey := ""
	windowName := ""
	processPath := ""
	winTitle := ""
	isDirect := ""
	isShowToolTip := ""
	comboKeyInstances := {}
	parentKey := ""
	waitTime := ""
	doublePressTime := ""
	longPressTime := ""
	outputKey := ""
	runCommand := ""
	workingDir := ""
	function := ""
	arg := ""
	isBlind := ""
	isToggle := ""
	repeatTime := ""
	holdTime := ""
	isAdmin := ""
	posX := ""
	posY := ""
	coord := ""
	func := ""
	funcStop := {}
	expression := ""
	prefixes := ""
	prefixKey := ""
	combinationKey := ""
	waitKey := ""
	isEnabled := False
	isActive := {}

	; Constructor
	__New(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
	{
		matchPos := InStr(inputKey, "->")
		this.inputKey := matchPos ? StrReplace(SubStr(inputKey, matchPos), "->") : inputKey
		this.parentKey := matchPos ? SubStr(inputKey, 1, matchPos - 1) : ""
		this.windowName := windowName
		this.processPath := processPath
		this.winTitle := processPath != "" ? (windowName != "" ? windowName " ahk_exe " processPath : "ahk_exe " processPath) : windowName
		this.isDirect := isDirect
		this.isShowToolTip := isShowToolTip
		this.waitTime := waitTime
		this.SetWaitKey(this.inputKey)
		If (InStr(this.inputKey, "&") && StrContains(this.inputKey, "^", "~", "*", "<", "^", "!", "+", "#"))
		{
			this.SetPrefixKey(this.inputKey)
			this.SetCombinationKey(this.inputKey)
			this.expression := ObjBindMethod(this, "GetPrefixKeyState")
		}
		If (comboKey != "")
		{
			this.AddComboKey(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
			this.func := ObjBindMethod(this, "ComboFunc")
		}
		Else
		{
			this.doublePressTime := doublePressTime
			this.longPressTime := longPressTime
			this.outputKey := outputKey
			this.runCommand := runCommand
			this.workingDir := workingDir
			this.function := function
			this.arg := arg
			this.isBlind := isBlind
			this.isToggle := isToggle
			this.repeatTime := repeatTime
			this.holdTime := holdTime
			this.isAdmin := isAdmin
			this.posX := posX
			this.posY := posY
			this.coord := coord
			this.e_output := New OutputType()
			For key In this.e_output
			{
				If (this.outputKey.HasKey(key) || this.runCommand.HasKey(key) || this.function.HasKey(key))
				{
					this.funcStop[key] := {}
					this.isActive[key] := {}
					this.isActive[key].toggle := False
					this.isActive[key].repeat := False
					this.isActive[key].hold := False
				}
				Else
				{
					this.e_output.Delete(key)
				}
			}
			this.DetermineFunc()
			SendMessage, % HotkeyData.KM_NEW, 0, &this,, % "ahk_id" A_ScriptHwnd
		}
	}

	; Public methods
	EnableHotkey(comboKey := "")
	{
		If (comboKey == "All")
		{
			For key In this.comboKeyInstances
			{
				this.EnableComboKey(key)
			}
		}
		Else If (comboKey != "")
		{
			isEnabled := True
			For key In this.comboKeyInstances
			{
				isEnabled &= this.comboKeyInstances[key].isEnabled
			}
			this.EnableComboKey(comboKey)
			If (isEnabled)
			{
				Return
			}
		}
		If (!this.isEnabled)
		{
			func := this.func
			If (this.expression)
			{
				expression := this.expression
				Hotkey, If, % expression
					; Adjust indent
				Hotkey, % this.combinationKey, % func, UseErrorLevel On
				Hotkey, If
					; Adjust indent
			}
			Else If (this.winTitle != "")
			{
				If (this.isDirect)
				{
					Hotkey, IfWinExist, % this.winTitle
						; Adjust indent
					Hotkey, % this.inputKey, % func, UseErrorLevel On
					Hotkey, IfWinExist
						; Adjust indent
				}
				Else
				{
					Hotkey, IfWinActive, % this.winTitle
						; Adjust indent
					Hotkey, % this.inputKey, % func, UseErrorLevel On
					Hotkey, IfWinActive
						; Adjust indent
				}
			}
			Else
			{
				Hotkey, % this.inputKey, % func, UseErrorLevel On
				If (InStr(this.inputKey, "<"))
				{
					Hotkey, % StrReplace(this.inputKey, "<" , ">"), % func, UseErrorLevel On
				}
			}
			this.isEnabled := True
			If (!this.comboKeyInstances.Count())
			{
				SendMessage, % HotkeyData.KM_ENABLE, 0, &this,, % "ahk_id" A_ScriptHwnd
			}
		}
	}

	DisableHotkey(comboKey := "")
	{
		If (comboKey == "All")
		{
			For key In this.comboKeyInstances
			{
				this.DisableComboKey(key)
			}
		}
		Else If (comboKey != "")
		{
			this.DisableComboKey(comboKey)
			isEnabled := False
			For key In this.comboKeyInstances
			{
				isEnabled |= this.comboKeyInstances[key].isEnabled
			}
			If (isEnabled)
			{
				Return
			}
		}
		If (this.isEnabled)
		{
			this.StopFunc()
			If (this.expression)
			{
				expression := this.expression
				Hotkey, If, % expression
					; Adjust indent
				Hotkey, % this.combinationKey, Off, UseErrorLevel
				Hotkey, If
					; Adjust indent
			}
			Else If (this.winTitle != "")
			{
				If (this.isDirect)
				{
					Hotkey, IfWinExist, % this.winTitle
						; Adjust indent
					Hotkey, % this.inputKey, Off, UseErrorLevel
					Hotkey, IfWinExist
						; Adjust indent
				}
				Else
				{
					Hotkey, IfWinActive, % this.winTitle
						; Adjust indent
					Hotkey, % this.inputKey, Off, UseErrorLevel
					Hotkey, IfWinActive
						; Adjust indent
				}
			}
			Else
			{
				Hotkey, % this.inputKey, Off, UseErrorLevel
				If (InStr(this.inputKey, "<"))
				{
					Hotkey, % StrReplace(this.inputKey, "<" , ">"), Off, UseErrorLevel
				}
			}
			this.isEnabled := False
			If (!this.comboKeyInstances.Count())
			{
				SendMessage, % HotkeyData.KM_DISABLE, 0, &this,, % "ahk_id" A_ScriptHwnd
			}
		}
	}

	ToggleHotkey(comboKey := "")
	{
		If (comboKey != "")
		{
			If (!this.comboKeyInstances[comboKey].isEnabled)
			{
				this.EnableHotkey(comboKey)
				Return True
			}
			Else
			{
				this.DisableHotkey(comboKey)
				Return False
			}
		}
		this.StopFunc()
		If (this.expression)
		{
			expression := this.expression
			Hotkey, If, % expression
				; Adjust indent
			Hotkey, % this.combinationKey, Toggle, UseErrorLevel
			Hotkey, If
				; Adjust indent
		}
		Else If (this.winTitle != "")
		{
			If (this.isDirect)
			{
				Hotkey, IfWinExist, % this.winTitle
					; Adjust indent
				Hotkey, % this.inputKey, Toggle, UseErrorLevel
				Hotkey, IfWinExist
					; Adjust indent
			}
			Else
			{
				Hotkey, IfWinActive, % this.winTitle
					; Adjust indent
				Hotkey, % this.inputKey, Toggle, UseErrorLevel
				Hotkey, IfWinActive
					; Adjust indent
			}
		}
		Else
		{
			Hotkey, % this.inputKey, Toggle, UseErrorLevel
			If (InStr(this.inputKey, "<"))
			{
				Hotkey, % StrReplace(this.inputKey, "<" , ">"), Toggle, UseErrorLevel
			}
		}
		If (this.isEnabled := !this.isEnabled)
		{
			SendMessage, % HotkeyData.KM_ENABLE, 0, &this,, % "ahk_id" A_ScriptHwnd
		}
		Else
		{
			SendMessage, % HotkeyData.KM_DISABLE, 0, &this,, % "ahk_id" A_ScriptHwnd
		}
		Return this.isEnabled
	}

	UnBindHotkey()
	{
		this.StopFunc()
		If (this.parentKey != "")
		{
			SendMessage, % HotkeyData.KM_DELETE, 0, &this,, % "ahk_id" A_ScriptHwnd
			Return
		}
		unBindFunc := HotkeyData.unBindFunc
		If (this.expression)
		{
			expression := this.expression
			Hotkey, If, % expression
				; Adjust indent
			Hotkey, % this.combinationKey, % unBindFunc, UseErrorLevel Off
			Hotkey, If
				; Adjust indent
		}
		Else If (this.winTitle != "")
		{
			If (this.isDirect)
			{
				Hotkey, IfWinExist, % this.winTitle
					; Adjust indent
				Hotkey, % this.inputKey, % unBindFunc, UseErrorLevel Off
				Hotkey, IfWinExist
					; Adjust indent
			}
			Else
			{
				Hotkey, IfWinActive, % this.winTitle
					; Adjust indent
				Hotkey, % this.inputKey, % unBindFunc, UseErrorLevel Off
				Hotkey, IfWinActive
					; Adjust indent
			}
		}
		Else
		{
			Hotkey, % this.inputKey, % unBindFunc, UseErrorLevel Off
			If (InStr(this.inputKey, "<"))
			{
				Hotkey, % StrReplace(this.inputKey, "<" , ">"), % unBindFunc, UseErrorLevel Off
			}
		}
		this.isEnabled := False
		If (GetFuncName(this.func) != "HotkeyData.ComboFunc")
		{
			SendMessage, % HotkeyData.KM_DELETE, 0, &this,, % "ahk_id" A_ScriptHwnd
		}
	}

	Clear(comboKey := "")
	{
		If (comboKey == "All")
		{
			For key In this.comboKeyInstances
			{
				this.comboKeyInstances[key].Clear()
			}
		}
		Else If (comboKey != "")
		{
			this.comboKeyInstances[comboKey].Clear()
			this.comboKeyInstances.Delete(comboKey)
			If (this.comboKeyInstances.Count())
			{
				Return False
			}
		}
		this.UnBindHotkey()
		For key In this.e_output
		{
			this.funcStop.Delete(key)
			this.isActive.Delete(key)
		}
		this.e_output := ""
		this.inputKey := ""
		this.windowName := ""
		this.processPath := ""
		this.winTitle := ""
		this.isDirect := ""
		this.isShowToolTip := ""
		this.comboKeyInstances := ""
		this.parentKey := ""
		this.waitTime := ""
		this.doublePressTime := ""
		this.longPressTime := ""
		this.outputKey := ""
		this.runCommand := ""
		this.workingDir := ""
		this.function := ""
		this.arg := ""
		this.isToggle := ""
		this.isBlind := ""
		this.repeatTime := ""
		this.holdTime := ""
		this.isAdmin := ""
		this.posX := ""
		this.posY := ""
		this.coord := ""
		this.func := ""
		this.funcStop := ""
		this.expression := ""
		this.prefixes := ""
		this.prefixKey := ""
		this.combinationKey := ""
		this.waitKey := ""
		this.isEnabled := ""
		this.isActive := ""
		Return True
	}

	GetKey()
	{
		Return this.parentKey != "" ? (RegExReplace(this.parentKey, "[\~\*\<]") this.windowName this.processPath this.isDirect "->" this.inputKey) : (RegExReplace(this.inputKey, "[\~\*\<]") this.windowName this.processPath this.isDirect)
	}

	AddComboKey(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
	{
		this.comboKeyInstances[comboKey] := New HotkeyData(inputKey "->" comboKey, windowName, processPath, isDirect, isShowToolTip, "", waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
	}

	; Private methods
	EnableComboKey(comboKey)
	{
		If (!this.comboKeyInstances[comboKey].isEnabled)
		{
			this.comboKeyInstances[comboKey].isEnabled := True
			SendMessage, % HotkeyData.KM_ENABLE, 0, &this.comboKeyInstances[comboKey],, % "ahk_id" A_ScriptHwnd
		}
	}

	DisableComboKey(comboKey)
	{
		If (this.comboKeyInstances[comboKey].isEnabled)
		{
			this.comboKeyInstances[comboKey].StopFunc()
			this.comboKeyInstances[comboKey].isEnabled := False
			SendMessage, % HotkeyData.KM_DISABLE, 0, &this.comboKeyInstances[comboKey],, % "ahk_id" A_ScriptHwnd
		}
	}

	KeyAddOption(key, option)
	{
		matchPos := InStr(key, " & ")
		leftKey := SubStr(key, 1, matchPos - 1)
		rightKey := StrReplace(SubStr(key, matchPos), " & ")
		Return matchPos ? leftKey A_Space option " & " rightKey A_Space option : leftKey rightKey A_Space option
	}

	KeyAddBlind(key, isBlind)
	{
		Return isBlind ? "{Blind}" key : key
	}

	ToSendKey(key)
	{
		matchPos := RegExMatch(key, "[^\^\!\+\#]")
		Return SubStr(key, 1, matchPos - 1) "{" StrReplace(SubStr(key, matchPos), " & " , "}{") "}"
	}

	ToSendMouseKey(key)
	{
		matchPos := RegExMatch(key, "[^\^\!\+\#]")
		prefix := SubStr(key, 1, matchPos - 1)
		key := SubStr(key, matchPos)
		matchPos := InStr(key, " & ")
		leftKey := matchPos ? SubStr(key, 1, matchPos - 1) : key
		rightKey := matchPos ? StrReplace(SubStr(key, matchPos), " & ") : ""
		isMouseL := StrContains(leftKey, "Button", "Wheel")
		isMouseR := StrContains(rightKey, "Button", "Wheel")
		leftKey := StrReplace(leftKey, "Button")
		rightKey := StrReplace(rightKey, "Button")
		If (rightKey != "")
		{
			If (isMouseL && !isMouseR)
			{
				Return prefix "{Click " leftKey "}" "{" rightKey "}"
			}
			Else If (!isMouseL && isMouseR)
			{
				Return prefix "{" leftKey "}" "{Click " rightKey "}"
			}
			Else
			{
				Return prefix "{Click " StrReplace(StrReplace(leftKey, " Down"), " Up") A_Space rightKey "}"
			}
		}
		Return prefix "{Click " leftKey "}"
	}

	SetWaitKey(key)
	{
		key := RegExReplace(key, "[\~\*\<\>\^\!\+\#]")
		this.waitKey := (matchPos := InStr(key, " & ")) ? StrReplace(SubStr(key, matchPos), " & ") : key
	}

	SetPrefixKey(key)
	{
		matchPos := RegExMatch(key, "[^\~\*\<\^\!\+\#]")
		prefixKey := ""
		prefixes := []
		If (InStr(key, "~"))
		{
			prefix := SubStr(key, matchPos)
			matchPos := InStr(prefix, " & ")
			If (matchPos)
			{
				prefix := SubStr(prefix, 1, matchPos - 1)
				prefixes.Push(prefix)
			}
		}
		Else
		{
			prefix := RegExReplace(SubStr(key, 1, matchPos - 1), "[\~\*\<]")
			While, prefix
			{
				prefixes[A_Index] := SubStr(prefix, 1, 1)
				prefix := StrReplace(prefix, prefixes[A_Index])
				prefixes[A_Index] := StrReplace(prefixes[A_Index], "^", "Ctrl")
				prefixes[A_Index] := StrReplace(prefixes[A_Index], "!", "Alt")
				prefixes[A_Index] := StrReplace(prefixes[A_Index], "+", "Shift")
				prefixes[A_Index] := StrReplace(prefixes[A_Index], "#", "Win")
			}
		}
		i := prefixes.Count()
		Loop % i
		{
			prefixKey .= (A_Index == i) ? prefixes[A_Index] : prefixes[A_Index] "|"
		}
		If (StrContains(prefixKey, "Ctrl", "Shift", "Alt", "Win"))
		{
			this.prefixes := ["Ctrl", "Shift", "Alt", "Win"]
			Loop, Parse, % prefixKey, |
			{
				ArrayReplace(this.prefixes, A_LoopField)
			}
		}
		this.prefixKey := prefixKey
	}

	SetCombinationKey(key)
	{
		matchPos := RegExMatch(key, "[^\~\*\<\^\!\+\#]")
		combinationKey := SubStr(key, matchPos)
		If (InStr(key, "~"))
		{
			prefix := RegExReplace(SubStr(key, 1, matchPos - 1), "[\~\*\<]")
			matchPos := InStr(combinationKey, " & ")
			combinationKey := matchPos ? StrReplace(SubStr(combinationKey, matchPos), " & ") : combinationKey
			combinationKey := prefix combinationKey
		}
		this.combinationKey := combinationKey
	}

	GetPrefixKeyState()
	{
		isPressed := True
		Loop, Parse, % this.prefixKey, |
		{
			isPressed &= InStr(A_LoopField, "Win") ? (GetKeyState("L" A_LoopField, "P") || GetKeyState("R" A_LoopField, "P")) : GetKeyState(A_LoopField, "P")
		}
		If (this.prefixes.Count() != 4 || this.prefixKey == "")
		{
			For key, value In this.prefixes
			{
				isPressed &= !GetKeyState(value, "P")
			}
		}
		Return this.winTitle != "" ? (this.isDirect ? isPressed && WinExist(this.winTitle) : isPressed && WinActive(this.winTitle)) : isPressed
	}

	SendKey(key)
	{
		Send, % key
	}

	SendMouse(key, posX, posY, coord)
	{
		If (posX == "" && posY == "")
		{
			Send, % key
		}
		Else
		{
			option := ""
			CoordMode, Mouse, % coord
			If (coord == "Relative")
			{
				option := A_Space posX A_Space posY A_Space coord
			}
			Else
			{
				If (posX == "")
				{
					MouseGetPos, posX
				}
				Else If (posY == "")
				{
					MouseGetPos,, posY
				}
				option := A_Space posX A_Space posY
			}
			tempKey := StrReplace(key, "{Blind}")
			If (InStr(tempKey, "}{") && !InStr(tempKey, "}{Click"))
			{
				tempKey := StrReplace(tempKey, "}{" , option "}{")
				Send, % InStr(key, "{Blind}") ? "{Blind}" tempKey : tempKey
			}
			Else
			{
				Send, % RTrim(key, "}") option "}"
			}
		}
	}

	ControlSendKey(key)
	{
		ControlSend,, % key, % this.winTitle
	}

	ControlSendMouse(key, posX, posY, options)
	{
		If (posX == "" && posY == "")
		{
			ControlClick,, % this.winTitle,, % key,, % options
		}
		Else
		{
			CoordMode, Mouse, Window
			If (posX == "")
			{
				MouseGetPos, posX
			}
			Else If (posY == "")
			{
				MouseGetPos,, posY
			}
			ControlClick, % "X" posX A_Space "Y" posY, % this.winTitle,, % key,, % options A_Space "Pos"
		}
	}

	RunCmd(runCommand, arguments, workingDir, isAdmin)
	{
		If (processID := GetPID(runCommand, arguments))
		{
			WinShow, % "ahk_pid" processID
			WinActivate, % "ahk_pid" processID
		}
		Else
		{
			Run(runCommand, arguments, workingDir, isAdmin)
		}
	}

	ToggleFunc(funcDown, funcUp, key)
	{
		If (this.isActive[key].toggle := !this.isActive[key].toggle)
		{
			funcDown.Call()
			If (this.isShowToolTip)
			{
				DisplayToolTip("Toggle enable : " this.outputKey[key])
			}
		}
		Else
		{
			funcUp.Call()
			If (this.isShowToolTip)
			{
				DisplayToolTip("Toggle disable : " this.outputKey[key])
			}
		}
		KeyWait, % this.waitKey
	}

	RepeatFunc(func, key)
	{
		this.isActive[key].repeat := True
		SetTimer, % func, % this.repeatTime[key] * 1000
		func.Call()
		If (this.isShowToolTip)
		{
			DisplayToolTip("Repeat enable : " this.outputKey[key])
		}
		KeyWait, % this.waitKey
		If (!this.isActive[key].toggle)
		{
			this.funcStop[key].repeat.Call()
		}
	}

	RepeatStop(func, key)
	{
		this.isActive[key].repeat := False
		SetTimer, % func, Delete
		If (this.isShowToolTip)
		{
			DisplayToolTip("Repeat disable : " this.outputKey[key])
		}
		If (this.isActive[key].hold)
		{
			this.funcStop[key].hold.Call()
		}
	}

	HoldFunc(funcDown, funcUp, key)
	{
		this.isActive[key].hold := True
		SetTimer, % funcUp, % this.holdTime[key] * -1000
		funcDown.Call()
		If (this.isShowToolTip)
		{
			DisplayToolTip("Hold enable : " this.outputKey[key])
		}
		If (!this.isActive[key].repeat)
		{
			KeyWait, % this.waitKey
			If (!this.isActive[key].toggle)
			{
				funcUp.Call()
			}
		}
	}

	HoldStop(funcUp, key)
	{
		this.isActive[key].hold := False
		funcStop := this.funcStop[key].hold
		SetTimer, % funcStop, Delete
		funcUp.Call()
		If (this.isShowToolTip)
		{
			DisplayToolTip("Hold disable : " this.outputKey[key])
		}
		If (this.isActive[key].toggle && !this.isActive[key].repeat)
		{
			this.isActive[key].toggle := False
		}
	}

	DoubleFunc(funcDouble, funcSingle := "")
	{
		KeyWait, % this.waitKey
		KeyWait, % this.waitKey, % "D T" this.doublePressTime
		If (!ErrorLevel)
		{
			funcDouble.Call()
			KeyWait, % this.waitKey
		}
		Else If (funcSingle)
		{
			funcSingle.Call()
		}
	}

	LongFunc(funcLong, funcSingle := "")
	{
		KeyWait, % this.waitKey, % "T" this.longPressTime
		If (ErrorLevel)
		{
			funcLong.Call()
			KeyWait, % this.waitKey
		}
		Else If (funcSingle)
		{
			funcSingle.Call()
		}
	}

	DoubleLongFunc(funcDouble, funcLong, funcSingle := "")
	{
		KeyWait, % this.waitKey, % "T" this.longPressTime
		If (ErrorLevel)
		{
			funcLong.Call()
			KeyWait, % this.waitKey
		}
		Else
		{
			KeyWait, % this.waitKey, % "D T" this.doublePressTime
			If (!ErrorLevel)
			{
				funcDouble.Call()
				KeyWait, % this.waitKey
			}
			Else If (funcSingle)
			{
				funcSingle.Call()
			}
		}
	}

	StopFunc()
	{
		For key In this.e_output
		{
			If (this.isActive[key].hold)
			{
				this.funcStop[key].hold.Call()
			}
			If (this.isActive[key].repeat)
			{
				this.funcStop[key].repeat.Call()
			}
			If (this.isActive[key].toggle)
			{
				this.funcStop[key].toggle.Call()
			}
		}
	}

	ComboFunc()
	{
		Suspend, On
		KeyWait, % this.waitKey
		If (this.isShowToolTip)
		{
			DisplayToolTip("Waiting for combo key input",,,, this.waitTime * 1000)
		}
		key := KeyWaitCombo("{All}", "{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{sc178}{vkFF}", this.waitTime ? "T" this.waitTime : "", True)
		If (this.comboKeyInstances.HasKey(key))
		{
			If (this.comboKeyInstances[key].isEnabled)
			{
				RemoveToolTip()
				this.comboKeyInstances[key].func.Call()
				Suspend, Off
				Return
			}
		}
		If (this.isShowToolTip)
		{
			DisplayToolTip("Cancel key combination")
		}
		Suspend, Off
	}

	DetermineFunc()
	{
		funcs := {}
		For key In this.e_output
		{
			func := ""
			funcDown := ""
			funcUp := ""
			outputKey := this.outputKey[key]
			outputKeyDown := this.KeyAddOption(outputKey, "Down")
			outputKeyUp := this.KeyAddOption(outputKey, "Up")
			If (InStr(outputKey, "AltTab"))
			{
				func := outputKey
			}
			Else
			{
				If (this.runCommand[key] != "")
				{
					runCommand := this.runCommand[key]
					arguments := ""
					If (matchPos := InStr(runCommand, A_Space Chr(34)))
					{
						arguments := SubStr(runCommand, matchPos + 1)
						runCommand := SubStr(runCommand, 1, matchPos - 1)
					}
					func := ObjBindMethod(this, "RunCmd", runCommand, arguments, this.workingDir[key], this.isAdmin[key])
				}
				Else If (this.function[key] != "")
				{
					args := []
					Loop, Parse, % this.arg[key], CSV
					{
						arg := A_LoopField
						args.Push(A_LoopField)
					}
					func := GetPluginFunc(this.function[key], args)
				}
				Else
				{
					If (this.winTitle != "" && this.isDirect)
					{
						If (StrContains(outputKey, "Button", "Wheel"))
						{
							outputKey := StrReplace(outputKey, "Button")
							func := ObjBindMethod(this, "ControlSendMouse", outputKey, this.posX[key], this.posY[key], "NA")
							funcDown := ObjBindMethod(this, "ControlSendMouse", outputKey, this.posX[key], this.posY[key], "NA D")
							funcUp := ObjBindMethod(this, "ControlSendMouse", outputKey, this.posX[key], this.posY[key], "NA U")
						}
						Else
						{
							func := ObjBindMethod(this, "ControlSendKey", this.KeyAddBlind(this.ToSendKey(outputKey), this.isBlind[key]))
							funcDown := ObjBindMethod(this, "ControlSendKey", this.KeyAddBlind(this.ToSendKey(outputKeyDown), this.isBlind[key]))
							funcUp := ObjBindMethod(this, "ControlSendKey", this.KeyAddBlind(this.ToSendKey(outputKeyUp), this.isBlind[key]))
						}
					}
					Else
					{
						If (StrContains(outputKey, "Button", "Wheel"))
						{
							func := ObjBindMethod(this, "SendMouse", this.KeyAddBlind(this.ToSendMouseKey(outputKey), this.isBlind[key]), this.posX[key], this.posY[key], this.coord[key])
							funcDown := ObjBindMethod(this, "SendMouse", this.KeyAddBlind(this.ToSendMouseKey(outputKeyDown), this.isBlind[key]), this.posX[key], this.posY[key], this.coord[key])
							funcUp := ObjBindMethod(this, "SendMouse", this.KeyAddBlind(this.ToSendMouseKey(outputKeyUp), this.isBlind[key]), this.posX[key], this.posY[key], this.coord[key])
						}
						Else
						{
							func := ObjBindMethod(this, "SendKey", this.KeyAddBlind(this.ToSendKey(outputKey), this.isBlind[key]))
							funcDown := ObjBindMethod(this, "SendKey", this.KeyAddBlind(this.ToSendKey(outputKeyDown), this.isBlind[key]))
							funcUp := ObjBindMethod(this, "SendKey", this.KeyAddBlind(this.ToSendKey(outputKeyUp), this.isBlind[key]))
						}
					}
					If (this.holdTime[key])
					{
						this.funcStop[key].hold := funcUp := ObjBindMethod(this, "HoldStop", funcUp, key)
						func := funcDown := ObjBindMethod(this, "HoldFunc", funcDown, funcUp, key)
					}
					If (this.repeatTime[key])
					{
						this.funcStop[key].repeat := funcUp := ObjBindMethod(this, "RepeatStop", func, key)
						func := funcDown := ObjBindMethod(this, "RepeatFunc", func, key)
					}
					If (this.isToggle[key])
					{
						this.funcStop[key].toggle := func := ObjBindMethod(this, "ToggleFunc", funcDown, funcUp, key)
					}
				}
			}
			funcs[key] := func
		}
		If (funcs.HasKey("Double") && funcs.HasKey("Long"))
		{
			If (funcs.HasKey("Single"))
			{
				this.func := ObjBindMethod(this, "DoubleLongFunc", funcs["Double"], funcs["Long"], funcs["Single"])
			}
			Else
			{
				this.func := ObjBindMethod(this, "DoubleLongFunc", funcs["Double"], funcs["Long"])
			}
		}
		Else If (funcs.HasKey("Double"))
		{
			If (funcs.HasKey("Single"))
			{
				this.func := ObjBindMethod(this, "DoubleFunc", funcs["Double"], funcs["Single"])
			}
			Else
			{
				this.func := ObjBindMethod(this, "DoubleFunc", funcs["Double"])
			}
		}
		Else If (funcs.HasKey("Long"))
		{
			If (funcs.HasKey("Single"))
			{
				this.func := ObjBindMethod(this, "LongFunc", funcs["Long"], funcs["Single"])
			}
			Else
			{
				this.func := ObjBindMethod(this, "LongFunc", funcs["Long"])
			}
		}
		Else If (funcs.HasKey("Single"))
		{
			this.func := funcs["Single"]
		}
	}

	UnBind()
	{
		Return
	}
}

class HotkeyManager
{
	; Variable
	hotkeys := {}

	; Destructor
	__Delete()
	{
		this.DeleteAllHotkeys()
		this.hotkeys := ""
	}

	; Public methods
	CreateHotkey(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
	{
		key := RegExReplace(inputKey, "[\~\*\<]") windowName processPath isDirect
		If (this.hotkeys.HasKey(key))
		{
			If (comboKey == "")
			{
				Return "ERROR"
			}
			If (!this.hotkeys[key].comboKeyInstances.Count())
			{
				Return "ERROR"
			}
			If (this.hotkeys[key].comboKeyInstances.HasKey(comboKey))
			{
				Return "ERROR"
			}
			this.hotkeys[key].inputKey := this.hotkeys[key].inputKey != inputKey ? inputKey : this.hotkeys[key].inputKey
			this.hotkeys[key].waitTime := this.hotkeys[key].waitTime != waitTime ? waitTime : this.hotkeys[key].waitTime
			this.hotkeys[key].isShowToolTip := this.hotkeys[key].isShowToolTip != isShowToolTip ? isShowToolTip : this.hotkeys[key].isShowToolTip
			this.hotkeys[key].AddComboKey(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
			this.hotkeys[key].EnableHotkey(comboKey)
			Return key "->" comboKey
		}
		this.hotkeys[key] := New HotkeyData(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
		this.hotkeys[key].EnableHotkey(comboKey)
		Return comboKey != "" ? key "->" comboKey : key
	}

	DeleteHotkey(key)
	{
		comboKey := ""
		If (matchPos := InStr(key, "->"))
		{
			comboKey := StrReplace(SubStr(key, matchPos), "->")
			key := SubStr(key, 1, matchPos - 1)
		}
		If (!this.hotkeys.HasKey(key))
		{
			Return False
		}
		If (this.hotkeys[key].Clear(comboKey))
		{
			this.hotkeys.Delete(key)
		}
		Return True
	}

	ToggleHotkey(key)
	{
		comboKey := ""
		If (matchPos := InStr(key, "->"))
		{
			comboKey := StrReplace(SubStr(key, matchPos), "->")
			key := SubStr(key, 1, matchPos - 1)
		}
		If (!this.hotkeys.HasKey(key))
		{
			Return "ERROR"
		}
		Return this.hotkeys[key].ToggleHotkey(comboKey)
	}

	EnableAllHotkeys()
	{
		If (!this.hotkeys.Count())
		{
			Return False
		}
		For key In this.hotkeys
		{
			this.hotkeys[key].EnableHotkey("All")
		}
		Return True
	}

	DisableAllHotkeys()
	{
		If (!this.hotkeys.Count())
		{
			Return False
		}
		For key In this.hotkeys
		{
			this.hotkeys[key].DisableHotkey("All")
		}
		Return True
	}

	DeleteAllHotkeys()
	{
		If (!this.hotkeys.Count())
		{
			Return False
		}
		For key In this.hotkeys.Clone()
		{
			this.DeleteHotkey(key "->All")
		}
		Return True
	}

	GetEnableKeys()
	{
		If (!this.hotkeys.Count())
		{
			Return False
		}
		enableKeys := []
		For key In this.hotkeys
		{
			If (this.hotkeys[key].comboKeyInstances.Count())
			{
				For comboKey In this.hotkeys[key].comboKeyInstances
				{
					If (this.hotkeys[key].comboKeyInstances[comboKey].isEnabled)
					{
						enableKeys.Push(key "->" comboKey)
					}
				}
			}
			Else If (this.hotkeys[key].isEnabled)
			{
				enableKeys.Push(key)
			}
		}
		Return enableKeys
	}

	EnableHotkeys(keys)
	{
		If (!this.hotkeys.Count())
		{
			Return False
		}
		i := 0
		For index, key In keys
		{
			comboKey := ""
			If (matchPos := InStr(key, "->"))
			{
				comboKey := StrReplace(SubStr(key, matchPos), "->")
				key := SubStr(key, 1, matchPos - 1)
			}
			If (this.hotkeys.HasKey(key))
			{
				this.hotkeys[key].EnableHotkey(comboKey)
				i++
			}
		}
		Return i
	}
}

class DynamicHotkey extends HotkeyManager
{
	; Variables
	static instance := ""
	static doNothingFunc := ObjBindMethod(DynamicHotkey, "DoNothing")
	profileDir := A_ScriptDir "\Profiles"
	configFile := A_ScriptDir "\Config\DynamicHotkey.ini"
	linkDataFile := A_ScriptDir "\Config\Link.dat"
	pluginFile := A_ScriptDir "\Config\Plugins.ahk"
	plugins := ""
	e_output := ""
	funcWM_WINDOWPOSCHANGED := ""
	funcCheckLinkData := ""
	linkData := []
	winEventForeGround := ""
	winEventMinimizeEnd := ""
	listViewNum := ""
	listViewKey := ""
	profiles := []
	nowProfile := ""
	absoluteProfiles := {}
	selectLinkNum := ""
	selectLinkData := ""
	isStartWithWindows := ""
	isOpenAtLaunch := ""
	isAlwaysOnTop := ""
	isAutoSwitch := ""
	capsLockType := ""
	numLockType := ""
	scrollLockType := ""
	enableKeys := ""
	wheelState := ""
	hTab := ""
	hListView := ""
	hSelectedProfile := ""
	hIsStart := ""
	hIsOpen := ""
	hIsTop := ""
	hIsSwitch := ""
	hCapsLockState := ""
	hNumLockState := ""
	hScrollLockState := ""
	hInputKey := ""
	hBindInput := ""
	hInputKey2nd := ""
	hBindInput2nd := ""
	hWindowName := ""
	hProcessPath := ""
	hWindowInfo := ""
	hIsCombination := ""
	hComboKey := ""
	hBindCombo := ""
	hWait := ""
	hWaitTime := ""
	hSecondWait := ""
	hIsWild := ""
	hIsPassThrough := ""
	hIsDirect := ""
	hIsShowToolTip := ""
	hDoublePress := ""
	hSecondDouble := ""
	hLongPress := ""
	hSecondLong := ""
	hSecret := ""
	hOutputs := {}
	hNewProfile := ""
	hLinkListView := ""
	hNewLinkProfile := ""
	hNewLinkWindow := ""
	hNewLinkProcess := ""
	hNewLinkMode := ""
	hNewLinkWindowInfo := ""

	; Getter/Setter
	TabName
	{
		get
		{
			GuiControlGet, value,, % this.hTab
			Return value
		}
	}

	SelectedProfile
	{
		get
		{
			GuiControlGet, value,, % this.hSelectedProfile
			Return value
		}
		set
		{
			GuiControl,, % this.hSelectedProfile, % value
			Return value
		}
	}

	IsStart
	{
		get
		{
			GuiControlGet, value,, % this.hIsStart
			Return value
		}
		set
		{
			GuiControl,, % this.hIsStart, % value
			Return value
		}
	}

	IsOpen
	{
		get
		{
			GuiControlGet, value,, % this.hIsOpen
			Return value
		}
		set
		{
			GuiControl,, % this.hIsOpen, % value
			Return value
		}
	}

	IsTop
	{
		get
		{
			GuiControlGet, value,, % this.hIsTop
			Return value
		}
		set
		{
			GuiControl,, % this.hIsTop, % value
			Return value
		}
	}

	IsSwitch
	{
		get
		{
			GuiControlGet, value,, % this.hIsSwitch
			Return value
		}
		set
		{
			GuiControl,, % this.hIsSwitch, % value
			Return value
		}
	}

	CapsLockState
	{
		get
		{
			GuiControlGet, value,, % this.hCapsLockState
			Return value
		}
	}

	NumLockState
	{
		get
		{
			GuiControlGet, value,, % this.hNumLockState
			Return value
		}
	}

	ScrollLockState
	{
		get
		{
			GuiControlGet, value,, % this.hScrollLockState
			Return value
		}
	}

	InputKey
	{
		get
		{
			GuiControlGet, value,, % this.hInputKey
			Return value
		}
		set
		{
			GuiControl,, % this.hInputKey, % value
			Return value
		}
	}

	InputKey2nd
	{
		get
		{
			GuiControlGet, value,, % this.hInputKey2nd
			Return value
		}
		set
		{
			GuiControl,, % this.hInputKey2nd, % value
			Return value
		}
	}

	BindInput2nd
	{
		set
		{
			GuiControl,, % this.hBindInput2nd, % value
			Return value
		}
	}

	WindowName
	{
		get
		{
			GuiControlGet, value,, % this.hWindowName
			Return value
		}
		set
		{
			GuiControl,, % this.hWindowName, % value
			Return value
		}
	}

	ProcessPath
	{
		get
		{
			GuiControlGet, value,, % this.hProcessPath
			Return value
		}
		set
		{
			GuiControl,, % this.hProcessPath, % value
			Return value
		}
	}

	WindowInfo
	{
		set
		{
			GuiControl,, % this.hWindowInfo, % value
			Return value
		}
	}

	IsCombination
	{
		get
		{
			GuiControlGet, value,, % this.hIsCombination
			Return value
		}
		set
		{
			GuiControl,, % this.hIsCombination, % value
			Return value
		}
	}

	ComboKey
	{
		get
		{
			GuiControlGet, value,, % this.hComboKey
			Return value
		}
		set
		{
			GuiControl,, % this.hComboKey, % value
			Return value
		}
	}

	WaitTime
	{
		get
		{
			GuiControlGet, value,, % this.hWaitTime
			Return value
		}
		set
		{
			GuiControl,, % this.hWaitTime, % value
			Return value
		}
	}

	IsWild
	{
		get
		{
			GuiControlGet, value,, % this.hIsWild
			Return value
		}
		set
		{
			GuiControl,, % this.hIsWild, % value
			Return value
		}
	}

	IsPassThrough
	{
		get
		{
			GuiControlGet, value,, % this.hIsPassThrough
			Return value
		}
		set
		{
			GuiControl,, % this.hIsPassThrough, % value
			Return value
		}
	}

	IsDirect
	{
		get
		{
			GuiControlGet, value,, % this.hIsDirect
			Return value
		}
		set
		{
			GuiControl,, % this.hIsDirect, % value
			Return value
		}
	}

	IsShowToolTip
	{
		get
		{
			GuiControlGet, value,, % this.hIsShowToolTip
			Return value
		}
		set
		{
			GuiControl,, % this.hIsShowToolTip, % value
			Return value
		}
	}

	DoublePress
	{
		get
		{
			GuiControlGet, value,, % this.hDoublePress
			Return value
		}
		set
		{
			GuiControl,, % this.hDoublePress, % value
			Return value
		}
	}

	SecondDouble
	{
		get
		{
			GuiControlGet, value,, % this.hSecondDouble
			Return value
		}
		set
		{
			GuiControl,, % this.hSecondDouble, % value
			Return value
		}
	}

	LongPress
	{
		get
		{
			GuiControlGet, value,, % this.hLongPress
			Return value
		}
		set
		{
			GuiControl,, % this.hLongPress, % value
			Return value
		}
	}

	SecondLong
	{
		get
		{
			GuiControlGet, value,, % this.hSecondLong
			Return value
		}
		set
		{
			GuiControl,, % this.hSecondLong, % value
			Return value
		}
	}

	NewProfile
	{
		get
		{
			GuiControlGet, value,, % this.hNewProfile
			Return value
		}
		set
		{
			GuiControl,, % this.hNewProfile, % value
			Return value
		}
	}

	NewLinkProfile
	{
		get
		{
			GuiControlGet, value,, % this.hNewLinkProfile
			Return value
		}
		set
		{
			GuiControl,, % this.hNewLinkProfile, % value
			Return value
		}
	}

	NewLinkWindow
	{
		get
		{
			GuiControlGet, value,, % this.hNewLinkWindow
			Return value
		}
		set
		{
			GuiControl,, % this.hNewLinkWindow, % value
			Return value
		}
	}

	NewLinkProcess
	{
		get
		{
			GuiControlGet, value,, % this.hNewLinkProcess
			Return value
		}
		set
		{
			GuiControl,, % this.hNewLinkProcess, % value
			Return value
		}
	}

	NewLinkMode
	{
		get
		{
			GuiControlGet, value,, % this.hNewLinkMode
			Return value
		}
		set
		{
			GuiControl,, % this.hNewLinkMode, % value
			Return value
		}
	}

	NewLinkWindowInfo
	{
		set
		{
			GuiControl,, % this.hNewLinkWindowInfo, % value
			Return value
		}
	}

	; Nested class
	class OutputHwnd
	{
		; Variables
		hIsOutputType := ""
		hRadioKey := ""
		hRadioCmd := ""
		hRadioFunc := ""
		hOutputKey := ""
		hBindOutput := ""
		hOutputKey2nd := ""
		hBindOutput2nd := ""
		hRunCommand := ""
		hDirectory := ""
		hWorkingDir := ""
		hFunction := ""
		hArgument := ""
		hArg := ""
		hIsBlind := ""
		hIsToggle := ""
		hIsRepeat := ""
		hRepeatTime := ""
		hRepeat := ""
		hIsHold := ""
		hHoldTime := ""
		hHold := ""
		hIsAdmin := ""
		hIsX := ""
		hPosX := ""
		hisY := ""
		hPosY := ""
		hCoordMode := ""
		hCoord := ""

		; Getter/Setter
		IsOutputType
		{
			get
			{
				GuiControlGet, value,, % this.hIsOutputType
				Return value
			}
			set
			{
				GuiControl,, % this.hIsOutputType, % value
				Return value
			}
		}

		RadioKey
		{
			get
			{
				GuiControlGet, value,, % this.hRadioKey
				Return value
			}
			set
			{
				GuiControl,, % this.hRadioKey, % value
				Return value
			}
		}

		RadioCmd
		{
			get
			{
				GuiControlGet, value,, % this.hRadioCmd
				Return value
			}
			set
			{
				GuiControl,, % this.hRadioCmd, % value
				Return value
			}
		}

		RadioFunc
		{
			get
			{
				GuiControlGet, value,, % this.hRadioFunc
				Return value
			}
			set
			{
				GuiControl,, % this.hRadioFunc, % value
				Return value
			}
		}

		OutputKey
		{
			get
			{
				GuiControlGet, value,, % this.hOutputKey
				Return value
			}
			set
			{
				GuiControl,, % this.hOutputKey, % value
				Return value
			}
		}

		OutputKey2nd
		{
			get
			{
				GuiControlGet, value,, % this.hOutputKey2nd
				Return value
			}
			set
			{
				GuiControl,, % this.hOutputKey2nd, % value
				Return value
			}
		}

		BindOutput2nd
		{
			set
			{
				GuiControl,, % this.hBindOutput2nd, % value
				Return value
			}
		}

		RunCommand
		{
			get
			{
				GuiControlGet, value,, % this.hRunCommand
				Return value
			}
			set
			{
				GuiControl,, % this.hRunCommand, % value
				Return value
			}
		}

		WorkingDir
		{
			get
			{
				GuiControlGet, value,, % this.hWorkingDir
				Return value
			}
			set
			{
				GuiControl,, % this.hWorkingDir, % value
				Return value
			}
		}

		Function
		{
			get
			{
				GuiControlGet, value,, % this.hFunction
				Return value
			}
			set
			{
				GuiControl,, % this.hFunction, % value
				Return value
			}
		}

		Arg
		{
			get
			{
				GuiControlGet, value,, % this.hArg
				Return value
			}
			set
			{
				GuiControl,, % this.hArg, % value
				Return value
			}
		}

		IsBlind
		{
			get
			{
				GuiControlGet, value,, % this.hIsBlind
				Return value
			}
			set
			{
				GuiControl,, % this.hIsBlind, % value
				Return value
			}
		}

		IsToggle
		{
			get
			{
				GuiControlGet, value,, % this.hIsToggle
				Return value
			}
			set
			{
				GuiControl,, % this.hIsToggle, % value
				Return value
			}
		}

		IsRepeat
		{
			get
			{
				GuiControlGet, value,, % this.hIsRepeat
				Return value
			}
			set
			{
				GuiControl,, % this.hIsRepeat, % value
				Return value
			}
		}

		RepeatTime
		{
			get
			{
				GuiControlGet, value,, % this.hRepeatTime
				Return value
			}
			set
			{
				GuiControl,, % this.hRepeatTime, % value
				Return value
			}
		}

		IsHold
		{
			get
			{
				GuiControlGet, value,, % this.hIsHold
				Return value
			}
			set
			{
				GuiControl,, % this.hIsHold, % value
				Return value
			}
		}

		HoldTime
		{
			get
			{
				GuiControlGet, value,, % this.hHoldTime
				Return value
			}
			set
			{
				GuiControl,, % this.hHoldTime, % value
				Return value
			}
		}

		IsAdmin
		{
			get
			{
				GuiControlGet, value,, % this.hIsAdmin
				Return value
			}
			set
			{
				GuiControl,, % this.hIsAdmin, % value
				Return value
			}
		}

		IsX
		{
			get
			{
				GuiControlGet, value,, % this.hIsX
				Return value
			}
			set
			{
				GuiControl,, % this.hIsX, % value
				Return value
			}
		}

		PosX
		{
			get
			{
				GuiControlGet, value,, % this.hPosX
				Return value
			}
			set
			{
				GuiControl,, % this.hPosX, % value
				Return value
			}
		}

		IsY
		{
			get
			{
				GuiControlGet, value,, % this.hIsY
				Return value
			}
			set
			{
				GuiControl,, % this.hIsY, % value
				Return value
			}
		}

		PosY
		{
			get
			{
				GuiControlGet, value,, % this.hPosY
				Return value
			}
			set
			{
				GuiControl,, % this.hPosY, % value
				Return value
			}
		}

		Coord
		{
			get
			{
				GuiControlGet, value,, % this.hCoord
				Return value
			}
			set
			{
				GuiControl,, % this.hCoord, % value
				Return value
			}
		}
	}

	; Constructor
	__New()
	{
		If (DynamicHotkey.instance)
		{
			Return DynamicHotkey.instance
		}
		DynamicHotkey.instance := this
		this.e_output := New OutputType()
		If (!FileExist(A_ScriptDir "\Config"))
		{
			FileCreateDir, % A_ScriptDir "\Config"
		}
		IniRead, isStart, % this.configFile, DynamicHotkey, IsStartWithWindows
		IniRead, isOpen, % this.configFile, DynamicHotkey, IsOpenAtLaunch
		IniRead, isTop, % this.configFile, DynamicHotkey, IsAlwaysOnTop
		IniRead, isSwitch, % this.configFile, DynamicHotkey, IsAutoSwitch
		IniRead, capsLockType, % this.configFile, DynamicHotkey, CapsLockState
		IniRead, numLockType, % this.configFile, DynamicHotkey, NumLockState
		IniRead, scrollLockType, % this.configFile, DynamicHotkey, ScrollLockState
		If (isStart == "ERROR")
		{
			isStart := False
			IniWrite, % isStart, % this.configFile, DynamicHotkey, IsStartWithWindows
		}
		If (isOpen == "ERROR")
		{
			isOpen := True
			IniWrite, % isOpen, % this.configFile, DynamicHotkey, IsOpenAtLaunch
		}
		If (isTop == "ERROR")
		{
			isTop := False
			IniWrite, % isTop, % this.configFile, DynamicHotkey, IsAlwaysOnTop
		}
		If (isSwitch == "ERROR")
		{
			isSwitch := True
			IniWrite, % isSwitch, % this.configFile, DynamicHotkey, IsAutoSwitch
		}
		If (capsLockType == "ERROR")
		{
			capsLockType := "Normal"
			IniWrite, % capsLockType, % this.configFile, DynamicHotkey, CapsLockState
		}
		If (numLockType == "ERROR")
		{
			numLockType := "Normal"
			IniWrite, % numLockType, % this.configFile, DynamicHotkey, NumLockState
		}
		If (scrollLockType == "ERROR")
		{
			scrollLockType := "Normal"
			IniWrite, % scrollLockType, % this.configFile, DynamicHotkey, ScrollLockState
		}
		this.isStartWithWindows := isStart
		this.isOpenAtLaunch := isOpen
		this.isAlwaysOnTop := isTop
		this.isAutoSwitch := isSwitch
		this.capsLockType := capsLockType
		this.numLockType := numLockType
		this.scrollLockType := scrollLockType
		Switch this.capsLockType
		{
			Case "Normal": SetCapsLockState
			Case "AlwaysOn": SetCapsLockState, AlwaysOn
			Case "AlwaysOff": SetCapsLockState, AlwaysOff
		}
		Switch this.numLockType
		{
			Case "Normal": SetNumLockState
			Case "AlwaysOn": SetNumLockState, AlwaysOn
			Case "AlwaysOff": SetNumLockState, AlwaysOff
		}
		Switch this.scrollLockType
		{
			Case "Normal": SetScrollLockState
			Case "AlwaysOn": SetScrollLockState, AlwaysOn
			Case "AlwaysOff": SetScrollLockState, AlwaysOff
		}
		If (!FileExist(this.profileDir))
		{
			FileCreateDir, % this.profileDir
		}
		If (FileExist(defaultProfile := this.profileDir "\Default.ini"))
		{
			this.LoadProfile("Default")
		}
		Else
		{
			IniWrite, 0, % defaultProfile, Total, Num
		}
		this.LoadLinkData()
		this.funcCheckLinkData := ObjBindMethod(this, "CheckLinkData")
		this.winEventForeGround := New WinEventHook(this.funcCheckLinkData, WinEventHook.EVENT_SYSTEM_FOREGROUND)
		this.winEventMinimizeEnd := New WinEventHook(this.funcCheckLinkData, WinEventHook.EVENT_SYSTEM_MINIMIZEEND)
		this.plugins := GetPluginFuncNames(GetPluginNames(this.pluginFile))
		this.GuiCreate()
		this.CreateMenu()
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Start()
			this.winEventMinimizeEnd.Start()
			Menu, Tray, Check, Auto profile switching
		}
		If (this.isOpenAtLaunch)
		{
			this.GuiOpen()
		}
		this.funcWM_WINDOWPOSCHANGED := ObjBindMethod(this, "WM_WINDOWPOSCHANGED")
		OnMessage(0x0047, this.funcWM_WINDOWPOSCHANGED)
	}

	; Static method
	Quit()
	{
		OnMessage(0x0047, this.funcWM_WINDOWPOSCHANGED, 0)
		this.funcWM_WINDOWPOSCHANGED := ""
		this.winEventForeGround.Clear()
		this.winEventMinimizeEnd.Clear()
		this.funcCheckLinkData := ""
		this.DeleteMenu()
		this.GuiDelete()
		DynamicHotkey.instance := ""
	}

	; Public method
	GuiOpen()
	{
		Gui, DynamicHotkey:Show, Center
	}

	; Gui methods
	GuiCreate()
	{
		If (WinExist("DynamicHotkey ahk_class AutoHotkeyGUI"))
		{
			Return
		}
		Gui, DynamicHotkey:New, -MaximizeBox -MinimizeBox +LabelDynamicHotkey.Gui, DynamicHotkey
		If (this.isAlwaysOnTop)
		{
			Gui, DynamicHotkey:+AlwaysOnTop
		}
		Gui, DynamicHotkey:Add, Tab3, w503 h275 HwndhTab GDynamicHotkey.GuiChangeTab Choose1, List|Profile|Setting
		this.hTab := hTab
		Gui, DynamicHotkey:Tab, List
		Gui, DynamicHotkey:Add, ListView, x+10 w478 h208 HwndhListView GDynamicHotkey.GuiEventListView AltSubmit -LV0x10 -Multi, |Input key|Window name|Process path|Option|Single press|Double press|Long press
		this.hListView := hListView
		Gui, DynamicHotkey:Add, Button, xp-1 y+7 w60 GDynamicHotkey.GuiListButtonCreate, Create
		Gui, DynamicHotkey:Add, Button, x+0 w60 GDynamicHotkey.GuiListButtonEdit, Edit
		Gui, DynamicHotkey:Add, Button, x+0 w60 GDynamicHotkey.GuiListButtonCopy, Copy
		Gui, DynamicHotkey:Add, Button, x+0 w60 GDynamicHotkey.GuiListButtonDelete, Delete
		Gui, DynamicHotkey:Add, Button, x+0 w60 GDynamicHotkey.GuiListButtonDeleteAll, Delete all
		Gui, DynamicHotkey:Add, Button, x+0 w60 GDynamicHotkey.GuiListButtonOnOff, On/Off
		Gui, DynamicHotkey:Add, Button, x+0 w60 GDynamicHotkey.GuiListButtonEnableAll, Enable all
		Gui, DynamicHotkey:Add, Button, x+0 w60 GDynamicHotkey.GuiListButtonDisableAll, Disable all
		Gui, DynamicHotkey:Tab, Profile
		Gui, DynamicHotkey:Add, ListBox, x+10 w478 h208 HwndhSelectedProfile GDynamicHotkey.GuiEventListBox
		this.hSelectedProfile := hSelectedProfile
		Gui, DynamicHotkey:Add, Button, xp-1 y+7 w66 GDynamicHotkey.GuiProfileButtonCreate, Create
		Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiProfileButtonRename, Rename
		Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiProfileButtonCopy, Copy
		Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiProfileButtonDelete, Delete
		Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiProfileButtonSave, Save
		Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiProfileButtonLoad, Load
		Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiProfileButtonLink, Link
		Gui, DynamicHotkey:Tab, Setting
		Gui, DynamicHotkey:Add, CheckBox, x+160 y+30 HwndhIsStart GDynamicHotkey.GuiChangeIsStart, Start with windows
		this.hIsStart := hIsStart
		Gui, DynamicHotkey:Add, CheckBox, xp+0 yp+30 HwndhIsOpen GDynamicHotkey.GuiChangeIsOpen, Open a window at launch
		this.hIsOpen := hIsOpen
		Gui, DynamicHotkey:Add, CheckBox, xp+0 yp+30 HwndhIsTop GDynamicHotkey.GuiChangeIsTop, Keep a window always on top
		this.hIsTop := hIsTop
		Gui, DynamicHotkey:Add, CheckBox, xp+0 yp+30 HwndhIsSwitch GDynamicHotkey.GuiChangeIsSwitch, Auto profile switching
		this.hIsSwitch := hIsSwitch
		Gui, DynamicHotkey:Add, Text, xp+0 yp+30 Section, CapsLock state
		Gui, DynamicHotkey:Add, DropDownList, x+15 yp-4 w82 HwndhCapsLockState GDynamicHotkey.GuiChangeCapsLock, Normal|AlwaysOn|AlwaysOff
		this.hCapsLockState := hCapsLockState
		GuiControl, DynamicHotkey:Choose, % hCapsLockState, % (this.capsLockType = "Normal" ? 1 : (this.capsLockType = "AlwaysOn" ? 2 : (this.capsLockType = "AlwaysOff" ? 3 : 1)))
		Gui, DynamicHotkey:Add, Text, xs+0 yp+34, NumLock state
		Gui, DynamicHotkey:Add, DropDownList, x+18 yp-4 w82 HwndhNumLockState GDynamicHotkey.GuiChangeNumLock, Normal|AlwaysOn|AlwaysOff
		this.hNumLockState := hNumLockState
		GuiControl, DynamicHotkey:Choose, % hNumLockState, % (this.numLockType = "Normal" ? 1 : (this.numLockType = "AlwaysOn" ? 2 : (this.numLockType = "AlwaysOff" ? 3 : 1)))
		Gui, DynamicHotkey:Add, Text, xs+0 yp+34, ScrollLock state
		Gui, DynamicHotkey:Add, DropDownList, x+12 yp-4 w82 HwndhScrollLockState GDynamicHotkey.GuiChangeScrollLock, Normal|AlwaysOn|AlwaysOff
		this.hScrollLockState := hScrollLockState
		GuiControl, DynamicHotkey:Choose, % hScrollLockState, % (this.scrollLockType = "Normal" ? 1 : (this.scrollLockType = "AlwaysOn" ? 2 : (this.scrollLockType = "AlwaysOff" ? 3 : 1)))
		this.RefreshListView()
		Loop, % this.profileDir "\*.ini"
		{
			profile := StrReplace(A_LoopFileName, ".ini")
			this.profiles.Push(profile)
		}
		this.profiles.RemoveAt(InArray(this.profiles, "Default"))
		this.profiles.InsertAt(1, "Default")
		For key, value In this.profiles
		{
			this.SelectedProfile := value
		}
		this.IsStart := this.isStartWithWindows
		this.IsOpen := this.isOpenAtLaunch
		this.IsTop := this.isAlwaysOnTop
		this.IsSwitch := this.isAutoSwitch
		Gui, DynamicHotkey:Show, Hide
	}

	CreateMenu()
	{
		func := ObjBindMethod(this, "MenuAutoSwitch")
		Menu, Tray, Insert, Open, Auto profile switching, % func
		Menu, Tray, Insert, Open

		func := ObjBindMethod(this, "GuiListButtonCreate")
		Menu, LVMenuNotExist, Add, Create, % func
		Menu, LVMenuExist, Add, Create, % func
		func := ObjBindMethod(this, "GuiListButtonEdit")
		Menu, LVMenuExist, Add, Edit, % func
		func := ObjBindMethod(this, "GuiListButtonCopy")
		Menu, LVMenuExist, Add, Copy, % func
		func := ObjBindMethod(this, "GuiListButtonDelete")
		Menu, LVMenuExist, Add, Delete, % func
		func := ObjBindMethod(this, "GuiListButtonOnOff")
		Menu, LVMenuExist, Add, On/Off, % func

		func := ObjBindMethod(this, "GuiProfileButtonCreate")
		Menu, LBMenuNotExist, Add, Create, % func
		Menu, LBMenuExist, Add, Create, % func
		func := ObjBindMethod(this, "GuiProfileButtonLink")
		Menu, LBMenuNotExist, Add, Link, % func
		Menu, LBMenuExist, Add, Link, % func
		func := ObjBindMethod(this, "GuiProfileButtonRename")
		Menu, LBMenuExist, Insert, Link, Rename, % func
		func := ObjBindMethod(this, "GuiProfileButtonCopy")
		Menu, LBMenuExist, Insert, Link, Copy, % func
		func := ObjBindMethod(this, "GuiProfileButtonDelete")
		Menu, LBMenuExist, Insert, Link, Delete, % func
		func := ObjBindMethod(this, "GuiProfileButtonSave")
		Menu, LBMenuExist, Insert, Link, Save, % func
		func := ObjBindMethod(this, "GuiProfileButtonLoad")
		Menu, LBMenuExist, Insert, Link, Load, % func

		func := ObjBindMethod(this, "LinkProfileGuiButtonCreate")
		Menu, LinkMenuNotExist, Add, Create, % func
		Menu, LinkMenuExist, Add, Create, % func
		func := ObjBindMethod(this, "LinkProfileGuiButtonEdit")
		Menu, LinkMenuExist, Add, Edit, % func
		func := ObjBindMethod(this, "LinkProfileGuiButtonCopy")
		Menu, LinkMenuExist, Add, Copy, % func
		func := ObjBindMethod(this, "LinkProfileGuiButtonDelete")
		Menu, LinkMenuExist, Add, Delete, % func
	}

	DeleteMenu()
	{
		Menu, Tray, Delete, Auto profile switching

		Menu, LVMenuNotExist, Delete, Create
		Menu, LVMenuExist, Delete, Create
		Menu, LVMenuExist, Delete, Edit
		Menu, LVMenuExist, Delete, Copy
		Menu, LVMenuExist, Delete, Delete
		Menu, LVMenuExist, Delete, On/Off

		Menu, LBMenuNotExist, Delete, Create
		Menu, LBMenuNotExist, Delete, Link
		Menu, LBMenuExist, Delete, Create
		Menu, LBMenuExist, Delete, Rename
		Menu, LBMenuExist, Delete, Copy
		Menu, LBMenuExist, Delete, Delete
		Menu, LBMenuExist, Delete, Save
		Menu, LBMenuExist, Delete, Load
		Menu, LBMenuExist, Delete, Link

		Menu, LinkMenuNotExist, Delete, Create
		Menu, LinkMenuExist, Delete, Create
		Menu, LinkMenuExist, Delete, Edit
		Menu, LinkMenuExist, Delete, Copy
		Menu, LinkMenuExist, Delete, Delete
	}

	MenuAutoSwitch()
	{
		this := DynamicHotkey.instance
		this.IsSwitch := this.isAutoSwitch := !this.isAutoSwitch
		this.GuiChangeIsSwitch()
	}

	WM_WINDOWPOSCHANGED()
	{
		Critical
		WinGet, windowStyle, ExStyle, % "DynamicHotkey ahk_class AutoHotkeyGUI"
		If (windowStyle & 0x00000008)
		{
			If (!this.isAlwaysOnTop)
			{
				this.IsTop := this.isAlwaysOnTop := True
				this.GuiChangeIsTop()
			}
		}
		Else If (this.isAlwaysOnTop)
		{
			this.IsTop := this.isAlwaysOnTop := False
			this.GuiChangeIsTop()
		}
	}

	GuiDelete()
	{
		this.e_output := ""
		this.plugins := ""
		this.linkData := ""
		this.listViewNum := ""
		this.listViewKey := ""
		this.profiles := ""
		this.absoluteProfiles := ""
		this.hTab := ""
		this.hListView := ""
		this.hSelectedProfile := ""
		this.hIsStart := ""
		this.hIsOpen := ""
		this.hIsTop := ""
		this.hIsSwitch := ""
		this.hCapsLockState := ""
		this.hNumLockState := ""
		this.hScrollLockState := ""
		this.hOutputs := ""
		Gui, DynamicHotkey:Destroy
	}

	GuiChangeTab()
	{
		this := DynamicHotkey.instance
		tabName := this.TabName
		If (tabName == "List")
		{
			GuiControl, DynamicHotkey:-Redraw, % this.hListView
			this.SortListView()
			LV_Modify(1, "Vis")
			LV_Modify(0, "-Select -Focus")
			GuiControl, DynamicHotkey:+Redraw, % this.hListView
		}
		Else If (tabName == "Profile")
		{
			GuiControl, DynamicHotkey:Choose, % this.hSelectedProfile, 0
		}
		GuiControl, DynamicHotkey:Focus, % this.hTab
	}

	GuiEventListView()
	{
		Critical
		this := DynamicHotkey.instance
		If (A_GuiControlEvent == "I")
		{
			If (InStr(ErrorLevel, "s", True))
			{
				this.listViewNum := ""
				this.listViewKey := ""
			}
			Else If (InStr(ErrorLevel, "S", True) && A_EventInfo > 0)
			{
				this.listViewNum := A_EventInfo
				this.listViewKey := this.GetListViewKey(this.listViewNum)
			}
		}
		If (A_GuiControlEvent == "D")
		{
			this.listViewNum := LV_DragAndDrop(A_GuiControlEvent)
			this.listViewKey := this.GetListViewKey(this.listViewNum)
		}
		If (A_GuiControlEvent == "DoubleClick")
		{
			this.GuiListButtonEdit()
		}
	}

	GuiListButtonCreate(GuiEvent := "", EventInfo := "", ErrLevel := "", listViewKey := "", isEdit := False)
	{
		If (WinExist("New Hotkey ahk_class AutoHotkeyGUI") || WinExist("Edit Hotkey ahk_class AutoHotkeyGUI"))
		{
			Return
		}
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Stop()
			this.winEventMinimizeEnd.Stop()
		}
		For key In this.e_output
		{
			this.hOutputs[key] := New this.OutputHwnd()
		}
		this.enableKeys := this.GetEnableKeys()
		this.DisableAllHotkeys()
		Gui, DynamicHotkey:+Disabled
		If (listViewKey != "" && isEdit)
		{
			Gui, NewHotkey:New, +LabelDynamicHotkey.NewHotkeyGui +OwnerDynamicHotkey -SysMenu, Edit Hotkey
		}
		Else
		{
			LV_Modify(0, "-Select -Focus")
			Gui, NewHotkey:New, +LabelDynamicHotkey.NewHotkeyGui +OwnerDynamicHotkey -SysMenu, New Hotkey
		}
		If (this.isAlwaysOnTop)
		{
			Gui, NewHotkey:+AlwaysOnTop
		}
		Gui, NewHotkey:Color, White
		Gui, NewHotkey:Add, GroupBox, w376 h230, Input
		Gui, NewHotkey:Add, Text, xp+9 yp+18 Section, key
		Gui, NewHotkey:Add, Edit, xs+0 w235 HwndhInputKey ReadOnly Center
		this.hInputKey := hInputKey
		Gui, NewHotkey:Add, Edit, x+6 w117 HwndhInputKey2nd ReadOnly Center Disabled
		this.hInputKey2nd := hInputKey2nd
		Gui, NewHotkey:Add, Button, xs-1 y+6 w237 h39 HwndhBindInput GDynamicHotkey.NewHotkeyGuiBindInput, Bind
		this.hBindInput := hBindInput
		Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindInput2nd GDynamicHotkey.NewHotkeyGuiBindInput2nd Disabled, Bind
		this.hBindInput2nd := hBindInput2nd
		Gui, NewHotkey:Add, Text, xs+0 y+6, Window name
		Gui, NewHotkey:Add, Edit, xs+0 w358 HwndhWindowName GDynamicHotkey.NewHotkeyGuiEditWinTitle Center
		this.hWindowName := hWindowName
		Gui, NewHotkey:Add, Text, xs+0 y+6, Process path
		Gui, NewHotkey:Add, Edit, xs+0 w358 HwndhProcessPath GDynamicHotkey.NewHotkeyGuiEditWinTitle Center
		this.hProcessPath := hProcessPath
		Gui, NewHotkey:Add, Button, xs-1 y+6 w360 HwndhWindowInfo GDynamicHotkey.NewHotkeyGuiWindowInfo, Get window info
		this.hWindowInfo := hWindowInfo
		Gui, NewHotkey:Add, GroupBox, x+7 ys-18 w239 h230
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+18 HwndhIsCombination GDynamicHotkey.NewHotkeyGuiChangeIsCombination Section, Combination
		this.hIsCombination := hIsCombination
		Gui, NewHotkey:Add, Edit, xs-1 y+6 w225 HwndhComboKey ReadOnly Center Disabled
		this.hComboKey := hComboKey
		Gui, NewHotkey:Add, Button, xs-2 y+6 w227 h39 HwndhBindCombo GDynamicHotkey.NewHotkeyGuiBindCombo Disabled, Bind
		this.hBindCombo := hBindCombo
		Gui, NewHotkey:Add, Text, xs+0 yp+45 HwndhWait Disabled, Wait time
		this.hWait := hWait
		Gui, NewHotkey:Add, Edit, xs-1 y+6 w48 HwndhWaitTime GDynamicHotkey.NewHotkeyGuiEditWaitTime Limit5 Disabled Right, 0
		this.hWaitTime := hWaitTime
		Gui, NewHotkey:Add, Text, x+2 yp+5 HwndhSecondWait Disabled, second
		this.hSecondWait := hSecondWait
		Gui, NewHotkey:Add, CheckBox, xs+0 y+9 HwndhIsWild, Wild card
		this.hIsWild := hIsWild
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsPassThrough, Pass through
		this.hIsPassThrough := hIsPassThrough
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsDirect GDynamicHotkey.NewHotkeyGuiChangeIsDirect Disabled, Direct send
		this.hIsDirect := hIsDirect
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsShowToolTip Disabled, Show tooltip
		this.hIsShowToolTip := hIsShowToolTip
		key := this.e_output[1]
		Gui, NewHotkey:Add, GroupBox, xm+0 y+18 w376 h132, Output
		Gui, NewHotkey:Add, CheckBox, xp+9 yp+18 HwndhIsSingle GDynamicHotkey.NewHotkeyGuiChangeIsSingle Section, Single press
		this.hOutputs[key].hIsOutputType := hIsSingle
		Gui, NewHotkey:Add, Radio, xs+0 yp+18 HwndhRadioKeySingle GDynamicHotkey.NewHotkeyGuiChangeOutputSingle Checked Disabled, Key
		Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioCmdSingle GDynamicHotkey.NewHotkeyGuiChangeOutputSingle Disabled, Run command
		Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioFuncSingle GDynamicHotkey.NewHotkeyGuiChangeOutputSingle Disabled, Function
		this.hOutputs[key].hRadioKey := hRadioKeySingle
		this.hOutputs[key].hRadioCmd := hRadioCmdSingle
		this.hOutputs[key].hRadioFunc := hRadioFuncSingle
		Gui, NewHotkey:Add, Edit, xs+0 w235 HwndhOutputKeySingle ReadOnly Center Disabled
		this.hOutputs[key].hOutputKey := hOutputKeySingle
		Gui, NewHotkey:Add, Edit, x+6 w117 HwndhOutputKeySingle2nd ReadOnly Center Disabled
		this.hOutputs[key].hOutputKey2nd := hOutputKeySingle2nd
		Gui, NewHotkey:Add, Edit, xs+0 yp+0 w358 HwndhRunCommandSingle Hidden Center Disabled
		this.hOutputs[key].hRunCommand := hRunCommandSingle
		Gui, NewHotkey:Add, DropDownList, xs+0 yp+0 w358 HwndhFunctionSingle GDynamicHotkey.NewHotkeyGuiChangeFunctionSingle Hidden Disabled
		this.hOutputs[key].hFunction := hFunctionSingle
		Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputSingle GDynamicHotkey.NewHotkeyGuiBindOutputSingle Disabled, Bind
		this.hOutputs[key].hBindOutput := hBindOutputSingle
		Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputSingle2nd GDynamicHotkey.NewHotkeyGuiBindOutputSingle2nd Disabled, Bind
		this.hOutputs[key].hBindOutput2nd := hBindOutputSingle2nd
		Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectorySingle Hidden Disabled, Working directory
		this.hOutputs[key].hDirectory := hDirectorySingle
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirSingle Hidden Center Disabled
		this.hOutputs[key].hWorkingDir := hWorkingDirSingle
		Gui, NewHotkey:Add, Text, xs+0 yp-18 HwndhArgumentSingle Hidden Disabled, Argument
		this.hOutputs[key].hArgument := hArgumentSingle
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhArgSingle GDynamicHotkey.NewHotkeyGuiEditArgumentSingle Hidden Center Disabled
		this.hOutputs[key].hArg := hArgSingle
		Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+12 HwndhIsBlindSingle Section Disabled, Blind
		this.hOutputs[key].hIsBlind := hIsBlindSingle
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsToggleSingle Section Disabled, Toggle
		this.hOutputs[key].hIsToggle := hIsToggleSingle
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsRepeatSingle GDynamicHotkey.NewHotkeyGuiChangeIsRepeatSingle Disabled, Repeat
		this.hOutputs[key].hIsRepeat := hIsRepeatSingle
		Gui, NewHotkey:Add, Edit, y+4 w48 HwndhRepeatTimeSingle GDynamicHotkey.NewHotkeyGuiEditRepeatTimeSingle Limit5 Disabled Right, 0
		this.hOutputs[key].hRepeatTime := hRepeatTimeSingle
		Gui, NewHotkey:Add, Text, x+2 yp+6 HwndhRepeatSingle Disabled, second
		this.hOutputs[key].hRepeat := hRepeatSingle
		Gui, NewHotkey:Add, CheckBox, x+-86 y+8 HwndhIsHoldSingle GDynamicHotkey.NewHotkeyGuiChangeIsHoldSingle Disabled, Hold
		this.hOutputs[key].hIsHold := hIsHoldSingle
		Gui, NewHotkey:Add, Edit, y+4 w48 HwndhHoldTimeSingle GDynamicHotkey.NewHotkeyGuiEditHoldTimeSingle Limit5 Disabled Right, 0
		this.hOutputs[key].hHoldTime := hHoldTimeSingle
		Gui, NewHotkey:Add, Text, x+2 yp+6 HwndhHoldSingle Disabled, second
		this.hOutputs[key].hHold := hHoldSingle
		Gui, NewHotkey:Add, CheckBox, xs+0 yp-50 HwndhIsAdminSingle Hidden Disabled, Run as admin
		this.hOutputs[key].hIsAdmin := hIsAdminSingle
		Gui, NewHotkey:Add, GroupBox, x+19 ys-30 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsXSingle GDynamicHotkey.NewHotkeyGuiChangeIsXSingle Section Disabled, X
		this.hOutputs[key].hIsX := hIsXSingle
		Gui, NewHotkey:Add, Edit, x+6 w68 HwndhPosXSingle GDynamicHotkey.NewHotkeyGuiEditPosXSingle Disabled Right, 0
		this.hOutputs[key].hPosX := hPosXSingle
		Gui, NewHotkey:Add, CheckBox, xs+0 y+10 HwndhIsYSingle GDynamicHotkey.NewHotkeyGuiChangeIsYSingle Disabled, Y
		this.hOutputs[key].hIsY := hIsYSingle
		Gui, NewHotkey:Add, Edit, x+6 w68 HwndhPosYSingle GDynamicHotkey.NewHotkeyGuiEditPosYSingle Disabled Right, 0
		this.hOutputs[key].hPosY := hPosYSingle
		Gui, NewHotkey:Add, Text, xs+0 y+9 HwndhCoordModeSingle Disabled, Coord mode
		this.hOutputs[key].hCoordMode := hCoordModeSingle
		Gui, NewHotkey:Add, DropDownList, xs+0 y+4 w103 HwndhCoordSingle GDynamicHotkey.NewHotkeyGuiChangeCoordModeSingle Disabled, Window||Client|Screen|Relative
		this.hOutputs[key].hCoord := hCoordSingle
		key := this.e_output[2]
		Gui, NewHotkey:Add, GroupBox, xm+0 y+9 w376 h132
		Gui, NewHotkey:Add, CheckBox, xp+9 yp+18 HwndhIsDouble GDynamicHotkey.NewHotkeyGuiChangeIsDouble Section, Double press
		this.hOutputs[key].hIsOutputType := hIsDouble
		Gui, NewHotkey:Add, Edit, x+2 yp-4 w44 HwndhDoublePress GDynamicHotkey.NewHotkeyGuiEditDoublePress Limit3 Right Disabled, 0.2
		this.hDoublePress := hDoublePress
		Gui, NewHotkey:Add, Text, x+2 yp+5 HwndhSecondDouble Disabled, second
		this.hSecondDouble := hSecondDouble
		Gui, NewHotkey:Add, Radio, xs+0 yp+17 HwndhRadioKeyDouble GDynamicHotkey.NewHotkeyGuiChangeOutputDouble Checked Disabled, Key
		Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioCmdDouble GDynamicHotkey.NewHotkeyGuiChangeOutputDouble Disabled, Run command
		Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioFuncDouble GDynamicHotkey.NewHotkeyGuiChangeOutputDouble Disabled, Function
		this.hOutputs[key].hRadioKey := hRadioKeyDouble
		this.hOutputs[key].hRadioCmd := hRadioCmdDouble
		this.hOutputs[key].hRadioFunc := hRadioFuncDouble
		Gui, NewHotkey:Add, Edit, xs+0 w235 HwndhOutputKeyDouble ReadOnly Center Disabled
		this.hOutputs[key].hOutputKey := hOutputKeyDouble
		Gui, NewHotkey:Add, Edit, x+6 w117 HwndhOutputKeyDouble2nd ReadOnly Center Disabled
		this.hOutputs[key].hOutputKey2nd := hOutputKeyDouble2nd
		Gui, NewHotkey:Add, Edit, xs+0 yp+0 w358 HwndhRunCommandDouble Hidden Center Disabled
		this.hOutputs[key].hRunCommand := hRunCommandDouble
		Gui, NewHotkey:Add, DropDownList, xs+0 yp+0 w358 HwndhFunctionDouble GDynamicHotkey.NewHotkeyGuiChangeFunctionDouble Hidden Disabled
		this.hOutputs[key].hFunction := hFunctionDouble
		Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputDouble GDynamicHotkey.NewHotkeyGuiBindOutputDouble Disabled, Bind
		this.hOutputs[key].hBindOutput := hBindOutputDouble
		Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputDouble2nd GDynamicHotkey.NewHotkeyGuiBindOutputDouble2nd Disabled, Bind
		this.hOutputs[key].hBindOutput2nd := hBindOutputDouble2nd
		Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectoryDouble Hidden Disabled, Working directory
		this.hOutputs[key].hDirectory := hDirectoryDouble
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirDouble Hidden Center Disabled
		this.hOutputs[key].hWorkingDir := hWorkingDirDouble
		Gui, NewHotkey:Add, Text, xs+0 yp-18 HwndhArgumentDouble Hidden Disabled, Argument
		this.hOutputs[key].hArgument := hArgumentDouble
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhArgDouble GDynamicHotkey.NewHotkeyGuiEditArgumentDouble Hidden Center Disabled
		this.hOutputs[key].hArg := hArgDouble
		Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+12 HwndhIsBlindDouble Section Disabled, Blind
		this.hOutputs[key].hIsBlind := hIsBlindDouble
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsToggleDouble Section Disabled, Toggle
		this.hOutputs[key].hIsToggle := hIsToggleDouble
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsRepeatDouble GDynamicHotkey.NewHotkeyGuiChangeIsRepeatDouble Disabled, Repeat
		this.hOutputs[key].hIsRepeat := hIsRepeatDouble
		Gui, NewHotkey:Add, Edit, y+4 w48 HwndhRepeatTimeDouble GDynamicHotkey.NewHotkeyGuiEditRepeatTimeDouble Limit5 Disabled Right, 0
		this.hOutputs[key].hRepeatTime := hRepeatTimeDouble
		Gui, NewHotkey:Add, Text, x+2 yp+6 HwndhRepeatDouble Disabled, second
		this.hOutputs[key].hRepeat := hRepeatDouble
		Gui, NewHotkey:Add, CheckBox, x+-86 y+8 HwndhIsHoldDouble GDynamicHotkey.NewHotkeyGuiChangeIsHoldDouble Disabled, Hold
		this.hOutputs[key].hIsHold := hIsHoldDouble
		Gui, NewHotkey:Add, Edit, y+4 w48 HwndhHoldTimeDouble GDynamicHotkey.NewHotkeyGuiEditHoldTimeDouble Limit5 Disabled Right, 0
		this.hOutputs[key].hHoldTime := hHoldTimeDouble
		Gui, NewHotkey:Add, Text, x+2 yp+6 HwndhHoldDouble Disabled, second
		this.hOutputs[key].hHold := hHoldDouble
		Gui, NewHotkey:Add, CheckBox, xs+0 yp-50 HwndhIsAdminDouble Hidden Disabled, Run as admin
		this.hOutputs[key].hIsAdmin := hIsAdminDouble
		Gui, NewHotkey:Add, GroupBox, x+19 ys-30 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsXDouble GDynamicHotkey.NewHotkeyGuiChangeIsXDouble Section Disabled, X
		this.hOutputs[key].hIsX := hIsXDouble
		Gui, NewHotkey:Add, Edit, x+6 w68 HwndhPosXDouble GDynamicHotkey.NewHotkeyGuiEditPosXDouble Disabled Right, 0
		this.hOutputs[key].hPosX := hPosXDouble
		Gui, NewHotkey:Add, CheckBox, xs+0 y+10 HwndhIsYDouble GDynamicHotkey.NewHotkeyGuiChangeIsYDouble Disabled, Y
		this.hOutputs[key].hIsY := hIsYDouble
		Gui, NewHotkey:Add, Edit, x+6 w68 HwndhPosYDouble GDynamicHotkey.NewHotkeyGuiEditPosXDouble Disabled Right, 0
		this.hOutputs[key].hPosY := hPosYDouble
		Gui, NewHotkey:Add, Text, xs+0 y+9 HwndhCoordModeDouble Disabled, Coord mode
		this.hOutputs[key].hCoordMode := hCoordModeDouble
		Gui, NewHotkey:Add, DropDownList, xs+0 y+4 w103 HwndhCoordDouble GDynamicHotkey.NewHotkeyGuiChangeCoordModeDouble Disabled, Window||Client|Screen|Relative
		this.hOutputs[key].hCoord := hCoordDouble
		key := this.e_output[3]
		Gui, NewHotkey:Add, GroupBox, xm+0 y+9 w376 h132
		Gui, NewHotkey:Add, CheckBox, xp+9 yp+18 HwndhIsLong GDynamicHotkey.NewHotkeyGuiChangeIsLong Section, Long press
		this.hOutputs[key].hIsOutputType := hIsLong
		Gui, NewHotkey:Add, Edit, x+13 yp-4 w44 HwndhLongPress GDynamicHotkey.NewHotkeyGuiEditLongPress Limit3 Right Disabled, 0.3
		this.hLongPress := hLongPress
		Gui, NewHotkey:Add, Text, x+2 yp+5 HwndhSecondLong Disabled, second
		this.hSecondLong := hSecondLong
		Gui, NewHotkey:Add, Radio, xs+0 yp+17 HwndhRadioKeyLong GDynamicHotkey.NewHotkeyGuiChangeOutputLong Checked Disabled, Key
		Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioCmdLong GDynamicHotkey.NewHotkeyGuiChangeOutputLong Disabled, Run command
		Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioFuncLong GDynamicHotkey.NewHotkeyGuiChangeOutputLong Disabled, Function
		this.hOutputs[key].hRadioKey := hRadioKeyLong
		this.hOutputs[key].hRadioCmd := hRadioCmdLong
		this.hOutputs[key].hRadioFunc := hRadioFuncLong
		Gui, NewHotkey:Add, Edit, xs+0 w235 HwndhOutputKeyLong ReadOnly Center Disabled
		this.hOutputs[key].hOutputKey := hOutputKeyLong
		Gui, NewHotkey:Add, Edit, x+6 w117 HwndhOutputKeyLong2nd ReadOnly Center Disabled
		this.hOutputs[key].hOutputKey2nd := hOutputKeyLong2nd
		Gui, NewHotkey:Add, Edit, xs+0 yp+0 w358 HwndhRunCommandLong Hidden Center Disabled
		this.hOutputs[key].hRunCommand := hRunCommandLong
		Gui, NewHotkey:Add, DropDownList, xs+0 yp+0 w358 HwndhFunctionLong GDynamicHotkey.NewHotkeyGuiChangeFunctionLong Hidden Disabled
		this.hOutputs[key].hFunction := hFunctionLong
		Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputLong GDynamicHotkey.NewHotkeyGuiBindOutputLong Disabled, Bind
		this.hOutputs[key].hBindOutput := hBindOutputLong
		Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputLong2nd GDynamicHotkey.NewHotkeyGuiBindOutputLong2nd Disabled, Bind
		this.hOutputs[key].hBindOutput2nd := hBindOutputLong2nd
		Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectoryLong Hidden Disabled, Working directory
		this.hOutputs[key].hDirectory := hDirectoryLong
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirLong Hidden Center Disabled
		this.hOutputs[key].hWorkingDir := hWorkingDirLong
		Gui, NewHotkey:Add, Text, xs+0 yp-18 HwndhArgumentLong Hidden Disabled, Argument
		this.hOutputs[key].hArgument := hArgumentLong
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhArgLong GDynamicHotkey.NewHotkeyGuiEditArgumentLong Hidden Center Disabled
		this.hOutputs[key].hArg := hArgLong
		Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+12 HwndhIsBlindLong Section Disabled, Blind
		this.hOutputs[key].hIsBlind := hIsBlindLong
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsToggleLong Section Disabled, Toggle
		this.hOutputs[key].hIsToggle := hIsToggleLong
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsRepeatLong GDynamicHotkey.NewHotkeyGuiChangeIsRepeatLong Disabled, Repeat
		this.hOutputs[key].hIsRepeat := hIsRepeatLong
		Gui, NewHotkey:Add, Edit, y+4 w48 HwndhRepeatTimeLong GDynamicHotkey.NewHotkeyGuiEditRepeatTimeLong Limit5 Disabled Right, 0
		this.hOutputs[key].hRepeatTime := hRepeatTimeLong
		Gui, NewHotkey:Add, Text, x+2 yp+6 HwndhRepeatLong Disabled, second
		this.hOutputs[key].hRepeat := hRepeatLong
		Gui, NewHotkey:Add, CheckBox, x+-86 y+8 HwndhIsHoldLong GDynamicHotkey.NewHotkeyGuiChangeIsHoldLong Disabled, Hold
		this.hOutputs[key].hIsHold := hIsHoldLong
		Gui, NewHotkey:Add, Edit, y+4 w48 HwndhHoldTimeLong GDynamicHotkey.NewHotkeyGuiEditHoldTimeLong Limit5 Disabled Right, 0
		this.hOutputs[key].hHoldTime := hHoldTimeLong
		Gui, NewHotkey:Add, Text, x+2 yp+6 HwndhHoldLong Disabled, second
		this.hOutputs[key].hHold := hHoldLong
		Gui, NewHotkey:Add, CheckBox, xs+0 yp-50 HwndhIsAdminLong Hidden Disabled, Run as admin
		this.hOutputs[key].hIsAdmin := hIsAdminLong
		Gui, NewHotkey:Add, GroupBox, x+19 ys-30 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsXLong GDynamicHotkey.NewHotkeyGuiChangeIsXLong Section Disabled, X
		this.hOutputs[key].hIsX := hIsXLong
		Gui, NewHotkey:Add, Edit, x+6 w68 HwndhPosXLong GDynamicHotkey.NewHotkeyGuiEditPosXLong Disabled Right, 0
		this.hOutputs[key].hPosX := hPosXLong
		Gui, NewHotkey:Add, CheckBox, xs+0 y+10 HwndhIsYLong GDynamicHotkey.NewHotkeyGuiChangeIsYLong Disabled, Y
		this.hOutputs[key].hIsY := hIsYLong
		Gui, NewHotkey:Add, Edit, x+6 w68 HwndhPosYLong GDynamicHotkey.NewHotkeyGuiEditPosXLong Disabled Right, 0
		this.hOutputs[key].hPosY := hPosYLong
		Gui, NewHotkey:Add, Text, xs+0 y+9 HwndhCoordModeLong Disabled, Coord mode
		this.hOutputs[key].hCoordMode := hCoordModeLong
		Gui, NewHotkey:Add, DropDownList, xs+0 y+4 w103 HwndhCoordLong GDynamicHotkey.NewHotkeyGuiChangeCoordModeLong Disabled, Window||Client|Screen|Relative
		this.hOutputs[key].hCoord := hCoordLong
		If (listViewKey != "" && isEdit)
		{
			Gui, NewHotkey:Add, Button, xm+8 w297 GDynamicHotkey.NewHotkeyGuiButtonOKEdit, OK
		}
		Else
		{
			Gui, NewHotkey:Add, Button, xm+8 w297 GDynamicHotkey.NewHotkeyGuiButtonOKNew, OK
		}
		Gui, NewHotkey:Add, Button, x+4 w297 GDynamicHotkey.NewHotkeyGuiClose, Cancel
		Gui, NewHotkey:Add, Radio, xp+0 yp+0 HwndhSecret Checked Hidden
		this.hSecret := hSecret
		For key In this.e_output
		{
			For index, plugin In this.plugins
			{
				this.hOutputs[key].Function := plugin
			}
			GuiControl, NewHotkey:Choose, % this.hOutputs[key].hFunction, 1
		}
		If (listViewKey != "")
		{
			matchPos := InStr(listViewKey, "->")
			comboKey := matchPos ? StrReplace(SubStr(listViewKey, matchPos), "->") : ""
			listViewKey := matchPos ? SubStr(listViewKey, 1, matchPos - 1) : listViewKey
			hotkeyInstance := matchPos ? this.hotkeys[listViewKey].comboKeyInstances[comboKey] : this.hotkeys[listViewKey]
			inputKey := this.GetFirstKey(this.hotkeys[listViewKey].inputKey)
			inputKey2nd := this.GetSecondKey(this.hotkeys[listViewKey].inputKey)
			this.InputKey := this.ToDisplayKey(inputKey)
			this.InputKey2nd := this.ToDisplayKey(inputKey2nd)
			this.WindowName := this.hotkeys[listViewKey].windowName
			this.ProcessPath := this.hotkeys[listViewKey].processPath
			this.IsCombination := matchPos ? True : False
			this.ComboKey := matchPos ? this.ToDisplayKey(comboKey) : ""
			waitTime := this.hotkeys[listViewKey].waitTime
			this.waitTime := InStr(waitTime, ".") ? Format("{:0.1f}", waitTime) : Format("{:d}", waitTime)
			this.IsWild := InStr(inputKey, "*") ? True : False
			this.IsPassThrough := InStr(inputKey, "~") ? True : False
			this.IsDirect := this.hotkeys[listViewKey].isDirect ? True : False
			this.IsShowToolTip := this.hotkeys[listViewKey].isShowToolTip
			doublePressTime := hotkeyInstance.doublePressTime
			doublePressTime := InStr(doublePressTime, ".") ? Format("{:0.1f}", doublePressTime) : Format("{:d}", doublePressTime)
			this.DoublePress := doublePressTime ? doublePressTime : 0.2
			longPressTime := hotkeyInstance.longPressTime
			longPressTime := InStr(longPressTime, ".") ? Format("{:0.1f}", longPressTime) : Format("{:d}", longPressTime)
			this.LongPress := longPressTime ? longPressTime : 0.3
			If (inputKey != "")
			{
				GuiControl, NewHotkey:Enable, % this.hInputKey2nd
				GuiControl, NewHotkey:Enable, % this.hBindInput2nd
			}
			If (inputKey2nd != "")
			{
				GuiControl, NewHotkey:Disable, % this.hIsWild
				this.BindInput2nd := "Clear"
			}
			If (comboKey != "")
			{
				GuiControl, NewHotkey:Enable, % this.hComboKey
				GuiControl, NewHotkey:Enable, % this.hBindCombo
				GuiControl, NewHotkey:Enable, % this.hWait
				GuiControl, NewHotkey:Enable, % this.hWaitTime
				GuiControl, NewHotkey:Enable, % this.hSecondWait
			}
			For key In this.e_output
			{
				outputKey := this.GetFirstKey(hotkeyInstance.outputKey[key])
				outputKey2nd := this.GetSecondKey(hotkeyInstance.outputKey[key])
				If (outputKey != "" || hotkeyInstance.runCommand[key] != "" || hotkeyInstance.function[key] != "")
				{
					this.hOutputs[key].IsOutputType := True
					this.hOutputs[key].OutputKey := this.ToDisplayKeyAlt(this.ToDisplayKey(outputKey))
					this.hOutputs[key].OutputKey2nd := this.ToDisplayKey(outputKey2nd)
					this.hOutputs[key].RadioKey := (outputKey != "")
					this.hOutputs[key].RadioCmd := (hotkeyInstance.runCommand[key] != "")
					this.hOutputs[key].RadioFunc := (hotkeyInstance.function[key] != "")
					this.hOutputs[key].RunCommand := hotkeyInstance.runCommand[key]
					this.hOutputs[key].WorkingDir := hotkeyInstance.workingDir[key]
					If (function := InArray(this.plugins, hotkeyInstance.function[key]))
					{
						GuiControl, NewHotkey:Choose, % this.hOutputs[key].hFunction, % function
					}
					this.hOutputs[key].Arg := hotkeyInstance.arg[key]
					this.hOutputs[key].IsBlind := hotkeyInstance.isBlind[key]
					this.hOutputs[key].IsToggle := hotkeyInstance.isToggle[key]
					this.hOutputs[key].IsRepeat := hotkeyInstance.repeatTime[key] ? True : False
					this.hOutputs[key].RepeatTime := hotkeyInstance.repeatTime[key]
					this.hOutputs[key].IsHold := hotkeyInstance.holdTime[key] ? True : False
					this.hOutputs[key].HoldTime := hotkeyInstance.holdTime[key]
					this.hOutputs[key].IsAdmin := hotkeyInstance.isAdmin[key] ? True : False
					this.hOutputs[key].IsX := (hotkeyInstance.posX[key] != "")
					this.hOutputs[key].PosX := hotkeyInstance.posX[key]
					this.hOutputs[key].IsY := (hotkeyInstance.posY[key] != "")
					this.hOutputs[key].PosY := hotkeyInstance.posY[key]
					If (coord := InArray(Array("Window", "Client", "Screen", "Relative"), hotkeyInstance.coord[key]))
					{
						GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, % coord
					}
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey2nd
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput2nd
				}
				If (outputKey2nd != "")
				{
					this.hOutputs[key].BindOutput2nd := "Clear"
				}
				this.ChangeOutput(key)
				this.ChangeIsOutputType(key)
				this.ChangeIsRepeat(key)
				this.ChangeIsHold(key)
				this.CheckMouseKey(key)
				this.ChangeIsX(key)
				this.ChangeIsY(key)
			}
			this.CheckToggleKey()
		}
		Gui, NewHotkey:Show
		GuiControl, NewHotkey:Focus, % this.hSecret
	}

	NewHotkeyGuiBindInput()
	{
		this := DynamicHotkey.instance
		Gui, NewHotkey:+Disabled
		this.KeyBind(this.hInputKey, this.hBindInput, True)
		Gui, NewHotkey:-Disabled
		GuiControl, NewHotkey:Enable, % this.hInputKey2nd
		GuiControl, NewHotkey:Enable, % this.hBindInput2nd
		GuiControl, NewHotkey:Focus, % this.hSecret
		this.CheckToggleKey()
	}

	NewHotkeyGuiBindInput2nd()
	{
		this := DynamicHotkey.instance
		If (this.InputKey2nd == "")
		{
			Gui, NewHotkey:+Disabled
			this.KeyBind(this.hInputKey2nd, this.hBindInput2nd, False)
			Gui, NewHotkey:-Disabled
			GuiControl, NewHotkey:Disable, % this.hIsWild
			GuiControl, NewHotkey:Focus, % this.hSecret
			this.BindInput2nd := "Clear"
			this.IsWild := False
		}
		Else
		{
			GuiControl, NewHotkey:Enable, % this.hIsWild
			this.InputKey2nd := ""
			this.BindInput2nd := "Bind"
		}
		this.CheckToggleKey()
	}

	NewHotkeyGuiEditWinTitle()
	{
		this := DynamicHotkey.instance
		If (this.WindowName != "" || this.ProcessPath != "")
		{
			GuiControl, NewHotkey:Enable, % this.hIsDirect
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hIsDirect
			this.IsDirect := False
			this.NewHotkeyGuiChangeIsDirect()
		}
	}

	NewHotkeyGuiWindowInfo()
	{
		this := DynamicHotkey.instance
		If (!this.isAlwaysOnTop)
		{
			Gui, NewHotkey:+AlwaysOnTop
		}
		this.WindowInfo := "Click other window"
		GuiControl, NewHotkey:Disable, % this.hWindowInfo
		GuiControl, NewHotkey:Focus, % this.hSecret
		Gui, NewHotkey:+Disabled
		WinGet, guiHwnd, ID, A
		funcDetectWindowInfo := ObjBindMethod(this, "DetectWindowInfo", "NewHotkey", guiHwnd, this.hWindowInfo, this.hWindowName, this.hProcessPath)
		this.winEventForeGround.SetFunc(funcDetectWindowInfo)
		this.winEventMinimizeEnd.SetFunc(funcDetectWindowInfo)
		this.winEventForeGround.Start()
		this.winEventMinimizeEnd.Start()
	}

	NewHotkeyGuiChangeIsCombination()
	{
		this := DynamicHotkey.instance
		If (this.IsCombination)
		{
			GuiControl, NewHotkey:Enable, % this.hComboKey
			GuiControl, NewHotkey:Enable, % this.hBindCombo
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hComboKey
			GuiControl, NewHotkey:Disable, % this.hBindCombo
			GuiControl, NewHotkey:Disable, % this.hWait
			GuiControl, NewHotkey:Disable, % this.hWaitTime
			GuiControl, NewHotkey:Disable, % this.hSecondWait
			this.ComboKey := ""
			this.WaitTime := 0
			this.CheckToggleKey()
		}
		this.CheckIsShowToolTip()
	}

	NewHotkeyGuiBindCombo()
	{
		this := DynamicHotkey.instance
		Gui, NewHotkey:+Disabled
		this.KeyBind(this.hComboKey, this.hBindCombo, True, False)
		Gui, NewHotkey:-Disabled
		GuiControl, NewHotkey:Enable, % this.hComboKey
		GuiControl, NewHotkey:Enable, % this.hBindCombo
		GuiControl, NewHotkey:Enable, % this.hWait
		GuiControl, NewHotkey:Enable, % this.hWaitTime
		GuiControl, NewHotkey:Enable, % this.hSecondWait
		GuiControl, NewHotkey:Focus, % this.hSecret
		this.CheckToggleKey()
		this.CheckIsShowToolTip()
	}

	NewHotkeyGuiEditWaitTime()
	{
		Critical
		this := DynamicHotkey.instance
		waitTime := this.WaitTime
		formatWaitTime := RegExNumber(waitTime)
		clampedWaitTime := Clamp(formatWaitTime, 0, 3600)
		If (waitTime == clampedWaitTime || waitTime == "")
		{
			GuiControl, NewHotkey:+cBlack, % this.hWaitTime
		}
		Else
		{
			GuiControl, NewHotkey:+cRed, % this.hWaitTime
			If (IsString(waitTime) && waitTime != "-")
			{
				this.WaitTime := formatWaitTime
				SetSel(this.hWaitTime)
			}
		}
		GuiControl, NewHotkey:MoveDraw, % this.hWaitTime
	}

	NewHotkeyGuiChangeIsDirect()
	{
		this := DynamicHotkey.instance
		For key In this.e_output
		{
			If (this.hOutputs[key].IsOutputType)
			{
				If (this.IsDirect)
				{
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRadioCmd
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoordMode
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoord
					GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, 1
					this.hOutputs[key].OutputKey2nd := ""
					this.hOutputs[key].BindOutput2nd := "Bind"
					If (this.hOutputs[key].RadioCmd)
					{
						this.hOutputs[key].RadioKey := True
					}
					Else If (this.hOutputs[key].RadioFunc)
					{
						If (!this.FindFunction(key))
						{
							this.hOutputs[key].RadioKey := True
						}
					}
				}
				Else
				{
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioCmd
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey2nd
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput2nd
					If (this.hOutputs[key].IsX || this.hOutputs[key].IsY)
					{
						GuiControl, NewHotkey:Enable, % this.hOutputs[key].hCoordMode
						GuiControl, NewHotkey:Enable, % this.hOutputs[key].hCoord
					}
				}
				this.ChangeOutput(key)
			}
		}
	}

	CheckIsShowToolTip()
	{
		If ((this.ComboKey != "") || (this.hOutputs["Single"].IsOutputType && this.hOutputs["Single"].RadioKey) || (this.hOutputs["Double"].IsOutputType && this.hOutputs["Double"].RadioKey) || (this.hOutputs["Long"].IsOutputType && this.hOutputs["Long"].RadioKey))
		{
			GuiControl, NewHotkey:Enable, % this.hIsShowToolTip
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hIsShowToolTip
			this.IsShowToolTip := False
		}
	}

	CheckToggleKey()
	{
		If (StrContains(this.ToInputKey(this.InputKey), "sc029", "sc03A", "sc070") || StrContains(this.ToInputKey(this.InputKey2nd), "sc029", "sc03A", "sc070") || StrContains(this.ToInputKey(this.ComboKey), "sc029", "sc03A", "sc070"))
		{
			GuiControl, NewHotkey:Disable, % this.hOutputs["Single"].hIsToggle
			GuiControl, NewHotkey:Disable, % this.hOutputs["Single"].hIsRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs["Single"].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs["Single"].hRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs["Single"].hIsHold
			GuiControl, NewHotkey:Disable, % this.hOutputs["Single"].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs["Single"].hHold
			this.hOutputs["Single"].IsToggle := False
			this.hOutputs["Single"].IsRepeat := False
			this.hOutputs["Single"].RepeatTime := 0
			this.hOutputs["Single"].IsHold := False
			this.hOutputs["Single"].HoldTime := 0
			this.hOutputs["Double"].IsOutputType := False
			this.hOutputs["Long"].IsOutputType := False
			GuiControl, NewHotkey:Disable, % this.hOutputs["Double"].hIsOutputType
			GuiControl, NewHotkey:Disable, % this.hOutputs["Long"].hIsOutputType
			this.ChangeIsOutputType("Double")
			this.ChangeIsOutputType("Long")
		}
		Else
		{
			If (this.hOutputs["Single"].IsOutputType)
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs["Single"].hIsToggle
				GuiControl, NewHotkey:Enable, % this.hOutputs["Single"].hIsRepeat
				GuiControl, NewHotkey:Enable, % this.hOutputs["Single"].hIsHold
			}
			GuiControl, NewHotkey:Enable, % this.hOutputs["Double"].hIsOutputType
			GuiControl, NewHotkey:Enable, % this.hOutputs["Long"].hIsOutputType
		}
	}

	ChangeIsOutputType(key)
	{
		If (this.hOutputs[key].IsOutputType)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioKey
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioFunc
			If (!this.IsDirect)
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioCmd
			}
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput
			If (key != "Single" || (key == "Single" && !StrContains(this.ToInputKey(this.InputKey), "sc029", "sc03A", "sc070") && !StrContains(this.ToInputKey(this.InputKey2nd), "sc029", "sc03A", "sc070")))
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsBlind
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsToggle
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsRepeat
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsHold
				If (key == "Double")
				{
					GuiControl, NewHotkey:Enable, % this.hDoublePress
					GuiControl, NewHotkey:Enable, % this.hSecondDouble
				}
				Else If (key == "Long")
				{
					GuiControl, NewHotkey:Enable, % this.hLongPress
					GuiControl, NewHotkey:Enable, % this.hSecondLong
				}
			}
		}
		Else
		{
			If (key == "Double")
			{
				GuiControl, NewHotkey:Disable, % this.hDoublePress
				GuiControl, NewHotkey:Disable, % this.hSecondDouble
				this.DoublePress := 0.2
			}
			Else If (key == "Long")
			{
				GuiControl, NewHotkey:Disable, % this.hLongPress
				GuiControl, NewHotkey:Disable, % this.hSecondLong
				this.LongPress := 0.3
			}
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRadioKey
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRadioCmd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRadioFunc
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hArgument
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hArg
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsBlind
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoord
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsBlind
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hCoord
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hArgument
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hArg
			this.hOutputs[key].RadioKey := True
			this.hOutputs[key].RadioCmd := False
			this.hOutputs[key].RadioFunc := False
			this.hOutputs[key].OutputKey := ""
			this.hOutputs[key].OutputKey2nd := ""
			this.hOutputs[key].RunCommand := ""
			this.hOutputs[key].WorkingDir := ""
			this.hOutputs[key].Arg := ""
			this.hOutputs[key].IsAdmin := False
			this.hOutputs[key].IsBlind := False
			this.hOutputs[key].IsToggle := False
			this.hOutputs[key].IsRepeat := False
			this.hOutputs[key].RepeatTime := 0
			this.hOutputs[key].IsHold := False
			this.hOutputs[key].HoldTime := 0
			this.hOutputs[key].IsX := False
			this.hOutputs[key].PosX := 0
			this.hOutputs[key].IsY := False
			this.hOutputs[key].PosY := 0
			GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, 1
		}
		this.CheckIsShowToolTip()
	}

	ChangeOutput(key)
	{
		If (this.hOutputs[key].RadioKey)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput
			If (this.WindowName != "" || this.ProcessPath != "")
			{
				GuiControl, NewHotkey:Enable, % this.hIsDirect
			}
			If (!this.IsDirect)
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsBlind
			}
			Else
			{
				GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
				GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
				If (!StrContains(this.hOutputs[key].OutputKey, "Button", "Wheel"))
				{
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsBlind
				}
				Else
				{
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsBlind
					this.hOutputs[key].IsBlind := False
				}
			}
			If (key != "Single" || (key == "Single" && !StrContains(this.ToInputKey(this.InputKey), "sc029", "sc03A", "sc070") && !StrContains(this.ToInputKey(this.InputKey2nd), "sc029", "sc03A", "sc070")))
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsToggle
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsRepeat
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsHold
			}
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsBlind
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hCoord
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hArgument
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hArg
			this.hOutputs[key].RunCommand := ""
			this.hOutputs[key].WorkingDir := ""
			this.hOutputs[key].Arg := ""
			this.hOutputs[key].IsAdmin := False
		}
		Else If (this.hOutputs[key].RadioCmd)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsBlind
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoord
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsBlind
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hArgument
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hArg
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hCoord
			this.hOutputs[key].OutputKey := ""
			this.hOutputs[key].OutputKey2nd := ""
			this.hOutputs[key].BindOutput2nd := "Bind"
			this.hOutputs[key].IsBlind := False
			this.hOutputs[key].IsToggle := False
			this.hOutputs[key].IsRepeat := False
			this.hOutputs[key].RepeatTime := 0
			this.hOutputs[key].IsHold := False
			this.hOutputs[key].HoldTime := 0
			this.hOutputs[key].IsX := False
			this.hOutputs[key].PosX := 0
			this.hOutputs[key].IsY := False
			this.hOutputs[key].PosY := 0
			this.hOutputs[key].Arg := ""
			GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, 1
		}
		Else
		{
			this.CheckFunction(key)
			If (this.IsDirect)
			{
				If (!this.FindFunction(key))
				{
					this.IsDirect := False
					this.NewHotkeyGuiChangeIsDirect()
				}
			}
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsBlind
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoord
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hArgument
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hArg
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsBlind
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hCoord
			this.hOutputs[key].OutputKey := ""
			this.hOutputs[key].OutputKey2nd := ""
			this.hOutputs[key].BindOutput2nd := "Bind"
			this.hOutputs[key].IsBlind := False
			this.hOutputs[key].IsToggle := False
			this.hOutputs[key].IsRepeat := False
			this.hOutputs[key].RepeatTime := 0
			this.hOutputs[key].IsHold := False
			this.hOutputs[key].HoldTime := 0
			this.hOutputs[key].RunCommand := ""
			this.hOutputs[key].WorkingDir := ""
			this.hOutputs[key].IsAdmin := False
			this.hOutputs[key].IsX := False
			this.hOutputs[key].PosX := 0
			this.hOutputs[key].IsY := False
			this.hOutputs[key].PosY := 0
			GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, 1
		}
		this.CheckIsShowToolTip()
	}

	CheckMouseKey(key)
	{
		If (StrContains(this.hOutputs[key].OutputKey, "Button", "Wheel") || StrContains(this.hOutputs[key].OutputKey2nd, "Button", "Wheel"))
		{
			If (this.IsDirect)
			{
				GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsBlind
				this.hOutputs[key].IsBlind := False
			}
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsY
		}
		Else
		{
			If (this.IsDirect)
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsBlind
			}
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosX
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosY
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoordMode
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoord
			this.hOutputs[key].IsX := False
			this.hOutputs[key].PosX := 0
			this.hOutputs[key].IsY := False
			this.hOutputs[key].PosY := 0
			GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, 1
		}
	}

	BindOutput(key)
	{
		Gui, NewHotkey:+Disabled
		this.KeyBind(this.hOutputs[key].hOutputKey, this.hOutputs[key].hBindOutput, True)
		Gui, NewHotkey:-Disabled
		GuiControl, NewHotkey:Focus, % this.hSecret
		If (!this.IsDirect)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput2nd
		}
		this.CheckMouseKey(key)
	}

	BindOutput2nd(key)
	{
		If (this.hOutputs[key].OutputKey2nd == "")
		{
			Gui, NewHotkey:+Disabled
			this.KeyBind(this.hOutputs[key].hOutputKey2nd, this.hOutputs[key].hBindOutput2nd, False)
			Gui, NewHotkey:-Disabled
			GuiControl, NewHotkey:Focus, % this.hSecret
			this.hOutputs[key].BindOutput2nd := "Clear"
		}
		Else
		{
			this.hOutputs[key].OutputKey2nd := ""
			this.hOutputs[key].BindOutput2nd := "Bind"
		}
		this.CheckMouseKey(key)
	}

	ChangeIsRepeat(key)
	{
		If (this.hOutputs[key].IsRepeat)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRepeat
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
			this.hOutputs[key].RepeatTime := 0
		}
	}

	ChangeIsHold(key)
	{
		If (this.hOutputs[key].IsHold)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hHold
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
			this.hOutputs[key].HoldTime := 0
		}
	}

	EditRepeatTime(key)
	{
		Critical
		repeatTime := this.hOutputs[key].RepeatTime
		formatRepeatTime := RegExNumber(repeatTime)
		clampedRepeatTime := Clamp(formatRepeatTime, 0, 3600)
		If (repeatTime == clampedRepeatTime || repeatTime == "")
		{
			GuiControl, NewHotkey:+cBlack, % this.hOutputs[key].hRepeatTime
		}
		Else
		{
			GuiControl, NewHotkey:+cRed, % this.hOutputs[key].hRepeatTime
			If (IsString(repeatTime) && repeatTime != "-")
			{
				this.hOutputs[key].RepeatTime := formatRepeatTime
				SetSel(this.hOutputs[key].hRepeatTime)
			}
		}
		GuiControl, NewHotkey:MoveDraw, % this.hOutputs[key].hRepeatTime
	}

	EditHoldTime(key)
	{
		Critical
		holdTime := this.hOutputs[key].HoldTime
		formatHoldTime := RegExNumber(holdTime)
		clampedHoldTime := Clamp(formatHoldTime, 0, 3600)
		If (holdTime == clampedHoldTime || holdTime == "")
		{
			GuiControl, NewHotkey:+cBlack, % this.hOutputs[key].hHoldTime
		}
		Else
		{
			GuiControl, NewHotkey:+cRed, % this.hOutputs[key].hHoldTime
			If (IsString(holdTime) && holdTime != "-")
			{
				this.hOutputs[key].HoldTime := formatHoldTime
				SetSel(this.hOutputs[key].hHoldTime)
			}
		}
		GuiControl, NewHotkey:MoveDraw, % this.hOutputs[key].hHoldTime
	}

	ChangeIsX(key)
	{
		If (this.hOutputs[key].IsX)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hPosX
			If (!this.IsDirect)
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hCoordMode
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hCoord
			}
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosX
			this.hOutputs[key].PosX := 0
			If (!this.hOutputs[key].IsY)
			{
				GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoordMode
				GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoord
				GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, 1
			}
		}
	}

	ChangeIsY(key)
	{
		If (this.hOutputs[key].IsY)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hPosY
			If (!this.IsDirect)
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hCoordMode
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hCoord
			}
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hPosY
			this.hOutputs[key].PosY := 0
			If (!this.hOutputs[key].IsX)
			{
				GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoordMode
				GuiControl, NewHotkey:Disable, % this.hOutputs[key].hCoord
				GuiControl, NewHotkey:Choose, % this.hOutputs[key].hCoord, 1
			}
		}
	}

	EditPosX(key)
	{
		Critical
		formatPosX := StrReplace(RegExNumber(posX := this.hOutputs[key].PosX), ".")
		If ((posX == formatPosX || posX == "") && !InStr(posX, "."))
		{
			If (this.hOutputs[key].Coord != "Relative" && InStr(posX, "-"))
			{
				GuiControl, NewHotkey:+cRed, % this.hOutputs[key].hPosX
			}
			Else
			{
				GuiControl, NewHotkey:+cBlack, % this.hOutputs[key].hPosX
			}
		}
		Else
		{
			GuiControl, NewHotkey:+cRed, % this.hOutputs[key].hPosX
			If ((IsString(posX) && posX != "-") || InStr(posX, "."))
			{
				this.hOutputs[key].PosX := formatPosX
				SetSel(this.hOutputs[key].hPosX)
			}
		}
		GuiControl, NewHotkey:MoveDraw, % this.hOutputs[key].hPosX
	}

	EditPosY(key)
	{
		Critical
		formatPosY := StrReplace(RegExNumber(posY := this.hOutputs[key].PosY), ".")
		If ((posY == formatPosY || posY == "") && !InStr(posY, "."))
		{
			If (this.hOutputs[key].Coord != "Relative" && InStr(posY, "-"))
			{
				GuiControl, NewHotkey:+cRed, % this.hOutputs[key].hPosY
			}
			Else
			{
				GuiControl, NewHotkey:+cBlack, % this.hOutputs[key].hPosY
			}
		}
		Else
		{
			GuiControl, NewHotkey:+cRed, % this.hOutputs[key].hPosY
			If ((IsString(posY) && posY != "-") || InStr(posY, "."))
			{
				this.hOutputs[key].PosY := formatPosY
				SetSel(this.hOutputs[key].hPosY)
			}
		}
		GuiControl, NewHotkey:MoveDraw, % this.hOutputs[key].hPosY
	}

	ChangeCoordMode(key)
	{
		this.EditPosX(key)
		this.EditPosY(key)
	}

	CheckFunction(key)
	{
		func := Func(this.hOutputs[key].Function)
		If ((InStr(func.Name, ".") ? func.MaxParams - 1 : func.MaxParams) || func.IsVariadic)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hArgument
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hArg
		}
		Else
		{
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hArgument
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hArg
			this.hOutputs[key].Arg := ""
		}
	}

	FindFunction(key)
	{
		func := Func(this.hOutputs[key].Function)
		funcName := (matchPos := InStr(func.Name, ".")) ? SubStr(func.Name, matchPos + 1) : func.Name
		If (SubStr(funcName, 1, 7) != "Direct_")
		{
			For index, value In this.plugins
			{
				matchPos := InStr(value, ".")
				funcName := matchPos ? SubStr(value, matchPos + 1) : value
				If (SubStr(funcName, 1, 7) = "Direct_")
				{
					GuiControl, NewHotkey:Choose, % this.hOutputs[key].hFunction, % index
					Return True
				}
			}
			Return False
		}
		Return True
	}

	ChangeFunction(key)
	{
		func := Func(this.hOutputs[key].Function)
		funcName := (matchPos := InStr(func.Name, ".")) ? SubStr(func.Name, matchPos + 1) : func.Name
		this.CheckFunction(key)
		If (SubStr(funcName, 1, 7) != "Direct_")
		{
			this.IsDirect := False
			this.NewHotkeyGuiChangeIsDirect()
		}
	}

	EditArgument(key)
	{
		Critical
		func := Func(this.hOutputs[key].Function)
		cnt := 0
		Loop, Parse, % this.hOutputs[key].Arg, CSV
		{
			cnt++
		}
		If ((cnt > (InStr(func.Name, ".") ? func.MaxParams - 1 : func.MaxParams)) && !func.IsVariadic)
		{
			GuiControl, NewHotkey:+cRed, % this.hOutputs[key].hArg
		}
		Else
		{
			GuiControl, NewHotkey:+cBlack, % this.hOutputs[key].hArg
		}
		GuiControl, NewHotkey:MoveDraw, % this.hOutputs[key].hArg
	}

	NewHotkeyGuiChangeIsSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeIsOutputType("Single")
	}

	NewHotkeyGuiChangeOutputSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeOutput("Single")
	}

	NewHotkeyGuiBindOutputSingle()
	{
		this := DynamicHotkey.instance
		this.BindOutput("Single")
	}

	NewHotkeyGuiBindOutputSingle2nd()
	{
		this := DynamicHotkey.instance
		this.BindOutput2nd("Single")
	}

	NewHotkeyGuiChangeIsRepeatSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeIsRepeat("Single")
	}

	NewHotkeyGuiChangeIsHoldSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeIsHold("Single")
	}

	NewHotkeyGuiEditRepeatTimeSingle()
	{
		this := DynamicHotkey.instance
		this.EditRepeatTime("Single")
	}

	NewHotkeyGuiEditHoldTimeSingle()
	{
		this := DynamicHotkey.instance
		this.EditHoldTime("Single")
	}

	NewHotkeyGuiChangeIsXSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeIsX("Single")
	}

	NewHotkeyGuiChangeIsYSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeIsY("Single")
	}

	NewHotkeyGuiEditPosXSingle()
	{
		this := DynamicHotkey.instance
		this.EditPosX("Single")
	}

	NewHotkeyGuiEditPosYSingle()
	{
		this := DynamicHotkey.instance
		this.EditPosY("Single")
	}

	NewHotkeyGuiChangeCoordModeSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeCoordMode("Single")
	}

	NewHotkeyGuiChangeFunctionSingle()
	{
		this := DynamicHotkey.instance
		this.ChangeFunction("Single")
	}

	NewHotkeyGuiEditArgumentSingle()
	{
		this := DynamicHotkey.instance
		this.EditArgument("Single")
	}

	NewHotkeyGuiChangeIsDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeIsOutputType("Double")
	}

	NewHotkeyGuiEditDoublePress()
	{
		Critical
		this := DynamicHotkey.instance
		doublePressTime := this.DoublePress
		formatDoublePressTime := RegExNumber(doublePressTime)
		clampedDoublePressTime := Clamp(formatDoublePressTime, 0.2, 1)
		If (doublePressTime == clampedDoublePressTime || doublePressTime == "")
		{
			GuiControl, NewHotkey:+cBlack, % this.hDoublePress
		}
		Else
		{
			GuiControl, NewHotkey:+cRed, % this.hDoublePress
			If (IsString(doublePressTime) && doublePressTime != "-")
			{
				this.DoublePress := formatDoublePressTime
				SetSel(this.hDoublePress)
			}
		}
		GuiControl, NewHotkey:MoveDraw, % this.hDoublePress
	}

	NewHotkeyGuiChangeOutputDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeOutput("Double")
	}

	NewHotkeyGuiBindOutputDouble()
	{
		this := DynamicHotkey.instance
		this.BindOutput("Double")
	}

	NewHotkeyGuiBindOutputDouble2nd()
	{
		this := DynamicHotkey.instance
		this.BindOutput2nd("Double")
	}

	NewHotkeyGuiChangeIsRepeatDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeIsRepeat("Double")
	}

	NewHotkeyGuiChangeIsHoldDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeIsHold("Double")
	}

	NewHotkeyGuiEditRepeatTimeDouble()
	{
		this := DynamicHotkey.instance
		this.EditRepeatTime("Double")
	}

	NewHotkeyGuiEditHoldTimeDouble()
	{
		this := DynamicHotkey.instance
		this.EditHoldTime("Double")
	}

	NewHotkeyGuiChangeIsXDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeIsX("Double")
	}

	NewHotkeyGuiChangeIsYDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeIsY("Double")
	}

	NewHotkeyGuiEditPosXDouble()
	{
		this := DynamicHotkey.instance
		this.EditPosX("Double")
	}

	NewHotkeyGuiEditPosYDouble()
	{
		this := DynamicHotkey.instance
		this.EditPosY("Double")
	}

	NewHotkeyGuiChangeCoordModeDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeCoordMode("Double")
	}

	NewHotkeyGuiChangeFunctionDouble()
	{
		this := DynamicHotkey.instance
		this.ChangeFunction("Double")
	}

	NewHotkeyGuiEditArgumentDouble()
	{
		this := DynamicHotkey.instance
		this.EditArgument("Double")
	}

	NewHotkeyGuiChangeIsLong()
	{
		this := DynamicHotkey.instance
		this.ChangeIsOutputType("Long")
	}

	NewHotkeyGuiEditLongPress()
	{
		Critical
		this := DynamicHotkey.instance
		longPressTime := this.LongPress
		formatLongPressTime := RegExNumber(longPressTime)
		clampedLongPressTime := Clamp(formatLongPressTime, 0.2, 10)
		If (longPressTime == clampedLongPressTime || longPressTime == "")
		{
			GuiControl, NewHotkey:+cBlack, % this.hLongPress
		}
		Else
		{
			GuiControl, NewHotkey:+cRed, % this.hLongPress
			If (IsString(longPressTime) && longPressTime != "-")
			{
				this.LongPress := formatLongPressTime
				SetSel(this.hLongPress)
			}
		}
		GuiControl, NewHotkey:MoveDraw, % this.hLongPress
	}

	NewHotkeyGuiChangeOutputLong()
	{
		this := DynamicHotkey.instance
		this.ChangeOutput("Long")
	}

	NewHotkeyGuiBindOutputLong()
	{
		this := DynamicHotkey.instance
		this.BindOutput("Long")
	}

	NewHotkeyGuiBindOutputLong2nd()
	{
		this := DynamicHotkey.instance
		this.BindOutput2nd("Long")
	}

	NewHotkeyGuiChangeIsRepeatLong()
	{
		this := DynamicHotkey.instance
		this.ChangeIsRepeat("Long")
	}

	NewHotkeyGuiChangeIsHoldLong()
	{
		this := DynamicHotkey.instance
		this.ChangeIsHold("Long")
	}

	NewHotkeyGuiEditRepeatTimeLong()
	{
		this := DynamicHotkey.instance
		this.EditRepeatTime("Long")
	}

	NewHotkeyGuiEditHoldTimeLong()
	{
		this := DynamicHotkey.instance
		this.EditHoldTime("Long")
	}

	NewHotkeyGuiChangeIsXLong()
	{
		this := DynamicHotkey.instance
		this.ChangeIsX("Long")
	}

	NewHotkeyGuiChangeIsYLong()
	{
		this := DynamicHotkey.instance
		this.ChangeIsY("Long")
	}

	NewHotkeyGuiEditPosXLong()
	{
		this := DynamicHotkey.instance
		this.EditPosX("Long")
	}

	NewHotkeyGuiEditPosYLong()
	{
		this := DynamicHotkey.instance
		this.EditPosY("Long")
	}

	NewHotkeyGuiChangeCoordModeLong()
	{
		this := DynamicHotkey.instance
		this.ChangeCoordMode("Long")
	}

	NewHotkeyGuiChangeFunctionLong()
	{
		this := DynamicHotkey.instance
		this.ChangeFunction("Long")
	}

	NewHotkeyGuiEditArgumentLong()
	{
		this := DynamicHotkey.instance
		this.EditArgument("Long")
	}

	NewHotkeyGuiButtonOKEdit()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		this.NewHotkeyGuiButtonOKNew(,,, True)
	}

	NewHotkeyGuiButtonOKNew(GuiEvent := "", EventInfo := "", ErrLevel := "", isEdit := False)
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		inputKey := this.InputKey
		inputKey2nd := this.InputKey2nd
		windowName := this.WindowName
		processPath := this.FormatProcessPath(this.ProcessPath)
		comboKey := this.ToInputKey(this.ComboKey)
		waitTime := ""
		isWild := this.IsWild
		isPassThrough := this.IsPassThrough
		isDirect := this.IsDirect
		isShowToolTip := this.IsShowToolTip
		doublePressTime := ""
		longPressTime := ""
		isOutputType := {}
		radioKey := {}
		radioCmd := {}
		radioFunc := {}
		outputKey := {}
		outputKey2nd := {}
		runCommand := {}
		workingDir := {}
		function := {}
		arg := {}
		isBlind := {}
		isToggle := {}
		repeatTime := {}
		holdTime := {}
		isLong := {}
		isAdmin := {}
		posX := {}
		posY := {}
		coord := {}
		For key In this.e_output
		{
			If (isOutputType[key] := this.hOutputs[key].IsOutputType)
			{
				radioKey[key] := this.hOutputs[key].RadioKey
				radioCmd[key] := this.hOutputs[key].RadioCmd
				radioFunc[key] := this.hOutputs[key].RadioFunc
				outputKey[key] := this.hOutputs[key].OutputKey
				outputKey2nd[key] := this.hOutputs[key].OutputKey2nd
				runCommand[key] := this.hOutputs[key].RunCommand
				workingDir[key] := this.hOutputs[key].WorkingDir
				function[key] := radioFunc[key] ? this.hOutputs[key].Function : ""
				arg[key] := this.hOutputs[key].Arg
				isBlind[key] := this.hOutputs[key].IsBlind
				isToggle[key] := this.hOutputs[key].IsToggle
				repeatTime[key] := this.hOutputs[key].RepeatTime
				holdTime[key] := this.hOutputs[key].HoldTime
				isLong[key] := this.hOutputs[key].IsLong
				isAdmin[key] := this.hOutputs[key].IsAdmin
				isX := this.hOutputs[key].IsX
				isY := this.hOutputs[key].IsY
				posX[key] := isX ? this.hOutputs[key].PosX : ""
				posY[key] := isY ? this.hOutputs[key].PosY : ""
				coord[key] := (isX | isY) ? this.hOutputs[key].Coord : ""
			}
		}
		If (inputKey == "")
		{
			DisplayToolTip("No input key entered")
			Return
		}
		Else If (InStr(inputKey, "vk"))
		{
			DisplayToolTip("Input key is invalid")
			Return
		}
		inputKey := this.ToInputKey(inputKey)
		inputKey2nd := this.ToInputKey(inputKey2nd)
		If (RegExReplace(inputKey, "[\^\!\+\#]") = inputKey2nd)
		{
			DisplayToolTip("Input key is duplicated")
			Return
		}
		If (inputKey2nd != "")
		{
			inputKey .= " & " inputKey2nd
		}
		If (comboKey != "")
		{
			waitTime := this.WaitTime
			If (waitTime != Clamp(waitTime, 0, 3600))
			{
				DisplayToolTip("Wait time is invalid")
				Return
			}
		}
		If (!isOutputType["Single"] && !isOutputType["Double"] && !isOutputType["Long"])
		{
			DisplayToolTip("Not all outputs are enabled")
			Return
		}
		If (isOutputType["Double"])
		{
			doublePressTime := this.DoublePress
			If (doublePressTime != Clamp(doublePressTime, 0.2, 1))
			{
				DisplayToolTip("Double press time is invalid")
				Return
			}
		}
		If (isOutputType["Long"])
		{
			longPressTime := this.LongPress
			If (longPressTime != Clamp(longPressTime, 0.2, 10))
			{
				DisplayToolTip("Long press time is invalid")
				Return
			}
		}
		For key In this.e_output
		{
			If (isOutputType[key])
			{
				If (radioKey[key])
				{
					If (outputKey[key] == "")
					{
						DisplayToolTip("No output key entered")
						Return
					}
					Else If (InStr(outputKey[key], "vk"))
					{
						DisplayToolTip("Output key is invalid")
						Return
					}
					outputKey[key] := this.ToInputKey(outputKey[key])
					outputKey2nd[key] := this.ToInputKey(outputKey2nd[key])
					If (isDirect && StrContains(outputKey[key], "Button", "Wheel") && RegExMatch(outputKey[key], "[\^\!\+\#]"))
					{
						DisplayToolTip("Output key is invalid")
						Return
					}
					If (outputKey2nd[key] != "")
					{
						outputKey[key] .= " & " outputKey2nd[key]
					}
					If (repeatTime[key] != Clamp(repeatTime[key], 0, 3600))
					{
						DisplayToolTip("Repeat time is invalid")
						Return
					}
					If (holdTime[key] != Clamp(holdTime[key], 0, 3600))
					{
						DisplayToolTip("Hold time is invalid")
						Return
					}
					If (coord[key] != "Relative")
					{
						If (InStr(posX[key], "-"))
						{
							DisplayToolTip("X is invalid")
							Return
						}
						If (InStr(posY[key], "-"))
						{
							DisplayToolTip("Y is invalid")
							Return
						}
					}
					Else
					{
						If (posX[key] == "")
						{
							posX[key] := 0
						}
						If (posY[key] == "")
						{
							posY[key] := 0
						}
					}
				}
				Else If (radioCmd[key] && runCommand[key] == "")
				{
					DisplayToolTip("No run command entered")
					Return
				}
				Else If (radioFunc[key])
				{
					If (!InArray(this.plugins, function[key]))
					{
						DisplayToolTip("Function is invalid")
						Return
					}
					func := Func(function[key])
					matchPos := InStr(func.Name, ".")
					cnt := 0
					Loop, Parse, % arg[key], CSV
					{
						cnt++
					}
					maxParams := matchPos ? func.MaxParams - 1 : func.MaxParams
					minParams := matchPos ? func.MinParams - 1 : func.MinParams
					If (((cnt > maxParams) && !func.IsVariadic) || ((cnt < minParams) && (!func.IsVariadic || func.IsVariadic && minParams)))
					{
						DisplayToolTip("Argument is invalid")
						Return
					}
					funcName := matchPos ? SubStr(func.Name, matchPos + 1) : func.Name
					If (SubStr(funcName, 1, 7) = "Direct_" && !isDirect)
					{
						DisplayToolTip("Function is direct send only")
						Return
					}
				}
			}
		}
		If (StrIn(outputKey["Single"], "!Tab", "+!Tab"))
		{
			prefixLength := StrLen(RegExReplace(inputKey, "[^\^\!\+\#]"))
			If ((prefixLength == 1 && inputKey2nd == "") || (prefixLength == 0 && inputKey2nd != ""))
			{
				If (windowName == "" && processPath == "" && !isWild && !isPassThrough && !isDirect && !isToggle["Single"] && !repeatTime["Single"] && !holdTime["Single"])
				{
					If (inputKey2nd == "")
					{
						inputKey := "<" inputKey
					}
					outputKey["Single"] := StrReplace(outputKey["Single"], "+", "Shift")
					outputKey["Single"] := StrReplace(outputKey["Single"], "!", "Alt")
				}
			}
		}
		If (isWild)
		{
			inputKey := "*" inputKey
		}
		If (isPassThrough)
		{
			inputKey := "~" inputKey
		}
		If (isEdit)
		{
			key := RegExReplace(inputKey, "[\~\*\<]") windowName processPath isDirect
			listViewKey := comboKey != "" ? key "->" comboKey : key
			If (hasKey := this.hotkeys.HasKey(key))
			{
				If (comboKey != "")
				{
					hasKey := this.hotkeys[key].comboKeyInstances.Count() ? this.hotkeys[key].comboKeyInstances.HasKey(comboKey) : True
				}
				Else If (this.hotkeys[key].comboKeyInstances.Count() == 1)
				{
					haskey := False
				}
			}
			If (!hasKey || listViewKey == this.listViewKey)
			{
				this.GuiListButtonDelete(,,, True)
			}
		}
		key := this.CreateHotkey(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, arg, isBlind, isToggle, repeatTime, holdTime, isAdmin, posX, posY, coord)
		If (key != "ERROR")
		{
			this.nowProfile := ""
			GuiControl, DynamicHotkey:-Redraw, % this.hListView
			this.ListViewAdd(key)
			this.SortListView()
			GuiControl, DynamicHotkey:+Redraw, % this.hListView
			this.NewHotkeyGuiClose()
			If (isEdit)
			{
				DisplayToolTip("Hotkey edited")
			}
			Else
			{
				DisplayToolTip("Hotkey created")
			}
		}
		Else
		{
			DisplayToolTip("Hotkey already exists")
		}
	}

	NewHotkeyGuiEscape()
	{
		this := DynamicHotkey.instance
		this.NewHotkeyGuiClose()
	}

	NewHotkeyGuiClose()
	{
		this := DynamicHotkey.instance
		this.EnableHotkeys(this.enableKeys)
		this.enableKeys := ""
		this.wheelState := ""
		this.hInputKey := ""
		this.hBindInput := ""
		this.hInputKey2nd := ""
		this.hBindInput2nd := ""
		this.hWindowName := ""
		this.hProcessPath := ""
		this.hWindowInfo := ""
		this.hIsCombination := ""
		this.hComboKey := ""
		this.hBindCombo := ""
		this.hWait := ""
		this.hWaitTime := ""
		this.hSecondWait := ""
		this.hIsWild := ""
		this.hIsPassThrough := ""
		this.hIsDirect := ""
		this.hIsShowToolTip := ""
		this.hDoublePress := ""
		this.hSecondDouble := ""
		this.hLongPress := ""
		this.hSecondLong := ""
		this.hSecret := ""
		For key In this.e_output
		{
			this.hOutputs.Delete(key)
		}
		Gui, NewHotkey:Destroy
		Gui, DynamicHotkey:-Disabled
		WinActivate, % "DynamicHotkey ahk_class AutoHotkeyGUI"
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Start()
			this.winEventMinimizeEnd.Start()
		}
	}

	GuiListButtonEdit()
	{
		this := DynamicHotkey.instance
		If (this.listViewNum != "" && this.listViewKey != "")
		{
			this.GuiListButtonCreate(,,, this.listViewKey, True)
		}
	}

	GuiListButtonCopy()
	{
		this := DynamicHotkey.instance
		If (this.listViewNum != "" && this.listViewKey != "")
		{
			this.GuiListButtonCreate(,,, this.listViewKey, False)
		}
	}

	GuiListButtonDelete(GuiEvent := "", EventInfo := "", ErrLevel := "", isEdit := False)
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.listViewNum != "" && this.listViewKey != "")
		{
			If (this.DeleteHotkey(this.listViewKey))
			{
				this.nowProfile := ""
				GuiControl, DynamicHotkey:-Redraw, % this.hListView
				LV_Delete(this.listViewNum)
				this.SortListView()
				GuiControl, DynamicHotkey:+Redraw, % this.hListView
				If (!isEdit)
				{
					DisplayToolTip("Hotkey deleted")
				}
			}
			Else If (!isEdit)
			{
				DisplayToolTip("Hotkey doesn't exist")
			}
			this.listViewNum := ""
			this.listViewKey := ""
		}
	}

	GuiListButtonDeleteAll()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.DeleteAllHotkeys())
		{
			this.nowProfile := ""
			GuiControl, DynamicHotkey:-Redraw, % this.hListView
			LV_Delete()
			this.SortListView()
			this.listViewNum := ""
			this.listViewKey := ""
			GuiControl, DynamicHotkey:+Redraw, % this.hListView
			DisplayToolTip("All hotkeys deleted")
		}
	}

	GuiListButtonOnOff()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.listViewNum != "" && this.listViewKey != "")
		{
			isEnabled := this.ToggleHotkey(this.listViewKey)
			If (isEnabled == "ERROR")
			{
				DisplayToolTip("Hotkey doesn't exist")
			}
			Else If (isEnabled)
			{
				LV_Modify(this.listViewNum, "", "✓")
				DisplayToolTip("Hotkey enabled")
			}
			Else If (!isEnabled)
			{
				LV_Modify(this.listViewNum, "", "✗")
				DisplayToolTip("Hotkey disabled")
			}
		}
	}

	GuiListButtonEnableAll()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.EnableAllHotkeys())
		{
			LV_Modify(0, "", "✓")
			DisplayToolTip("All hotkeys enabled")
		}
	}

	GuiListButtonDisableAll()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.DisableAllHotkeys())
		{
			LV_Modify(0, "", "✗")
			DisplayToolTip("All hotkeys disabled")
		}
	}

	GuiEventListBox()
	{
		Critical
		this := DynamicHotkey.instance
		If (A_GuiControlEvent == "Normal")
		{
			VarSetCapacity(RECT, 16, 0)
			NumPut(0, RECT, 0, "Int")
			SendMessage, 0x0198, 0, &RECT,, % "ahk_id" this.hSelectedProfile
			rowTop := NumGet(RECT, 4, "Int")
			rowBottom := NumGet(RECT, 12, "Int")
			rowHeight := rowBottom - rowTop
			SendMessage 0x018B, 0, 0,, % "ahk_id" this.hSelectedProfile
			listBoxCount := ErrorLevel
			itemsHeight := rowHeight * listBoxCount
			ControlGetPos,, listBoxPosY,, listBoxHeight,, % "ahk_id" this.hSelectedProfile
			MouseGetPos,, mousePosY,,, 2
			If (mousePosY > (listBoxPosY + itemsHeight))
			{
				GuiControl, DynamicHotkey:Choose, % this.hSelectedProfile, 0
			}
		}
		If (A_GuiControlEvent == "DoubleClick")
		{
			this.GuiProfileButtonLoad()
		}
	}

	GuiContextMenu(CtrlHwnd := "", EventInfo := "", IsRightClick := "", X := "", Y := "")
	{
		this := DynamicHotkey.instance
		If (IsRightClick)
		{
			If (CtrlHwnd == this.hListView)
			{
				If (this.listViewNum == "")
				{
					Menu, LVMenuNotExist, Show
				}
				Else
				{
					Menu, LVMenuExist, Show
				}
			}
			Else If (CtrlHwnd == this.hSelectedProfile)
			{
				ControlClick, x%X% y%Y%,,, Left,, NA Pos
				If (this.SelectedProfile == "")
				{
					Menu, LBMenuNotExist, Show
				}
				Else
				{
					Menu, LBMenuExist, Show
				}
			}
		}
	}

	GuiProfileButtonCreate(GuiEvent := "", EventInfo := "", ErrLevel := "", selectedProfile := "", isRename := False)
	{
		If (WinExist("New Profile ahk_class AutoHotkeyGUI") || WinExist("Rename Profile ahk_class AutoHotkeyGUI"))
		{
			Return
		}
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Stop()
			this.winEventMinimizeEnd.Stop()
		}
		this.enableKeys := this.GetEnableKeys()
		this.DisableAllHotkeys()
		Gui, DynamicHotkey:+Disabled
		If (selectedProfile != "" && isRename)
		{
			Gui, NewProfile:New, +LabelDynamicHotkey.NewProfileGui +OwnerDynamicHotkey -SysMenu, Rename Profile
		}
		Else
		{
			Gui, NewProfile:New, +LabelDynamicHotkey.NewProfileGui +OwnerDynamicHotkey -SysMenu, New Profile
		}
		If (this.isAlwaysOnTop)
		{
			Gui, NewProfile:+AlwaysOnTop
		}
		Gui, NewProfile:Add, Edit, x+1 y+8 w200 r1 -VScroll HwndhNewProfile
		this.hNewProfile := hNewProfile
		If (selectedProfile != "")
		{
			If (isRename)
			{
				Gui, NewProfile:Add, Button, xs-1 w100 Default GDynamicHotkey.NewProfileGuiButtonOKRename, OK
			}
			Else
			{
				Gui, NewProfile:Add, Button, xs-1 w100 Default GDynamicHotkey.NewProfileGuiButtonOKCopy, OK
			}
		}
		Else
		{
			Gui, NewProfile:Add, Button, xs-1 w100 Default GDynamicHotkey.NewProfileGuiButtonOKNew, OK
		}
		Gui, NewProfile:Add, Button, x+2 w100 GDynamicHotkey.NewProfileGuiClose, Cancel
		If (selectedProfile != "")
		{
			this.NewProfile := selectedProfile
		}
		Gui, NewProfile:Show
	}

	NewProfileGuiButtonOKRename()
	{
		this := DynamicHotkey.instance
		this.NewProfileGuiButtonOKNew(,,, True, False)
	}

	NewProfileGuiButtonOKCopy()
	{
		this := DynamicHotkey.instance
		this.NewProfileGuiButtonOKNew(,,, False, True)
	}

	NewProfileGuiButtonOKNew(GuiEvent := "", EventInfo := "", ErrLevel := "", isRename := False, isCopy := False)
	{
		this := DynamicHotkey.instance
		selectedProfile := this.SelectedProfile
		If ((newProfile := this.NewProfile) == "")
		{
			DisplayToolTip("No profile entered")
			Return
		}
		If (InArray(this.profiles, newProfile))
		{
			DisplayToolTip("Profile already exists")
			Return
		}
		If (isRename)
		{
			this.RenameProfile(selectedProfile, newProfile)
			ArrayReplace(this.profiles, selectedProfile, newProfile)
		}
		Else
		{
			If (isCopy)
			{
				this.CopyProfile(selectedProfile, newProfile)
			}
			Else
			{
				this.CreateProfile(newProfile)
			}
			this.profiles.Push(newProfile)
		}
		Sort(this.profiles, this.profiles.MinIndex(), this.profiles.MaxIndex())
		ArrayReplace(this.profiles, "Default")
		this.profiles.InsertAt(1, "Default")
		this.SelectedProfile := "|"
		For key, value In this.profiles
		{
			this.SelectedProfile := value
		}
		this.NewProfileGuiClose()
		If (isRename)
		{
			DisplayToolTip("Profile renamed")
		}
		Else
		{
			DisplayToolTip("Profile created")
		}
	}

	NewProfileGuiEscape()
	{
		this := DynamicHotkey.instance
		this.NewProfileGuiClose()
	}

	NewProfileGuiClose()
	{
		this := DynamicHotkey.instance
		this.EnableHotkeys(this.enableKeys)
		this.enableKeys := ""
		this.hNewProfile := ""
		Gui, NewProfile:Destroy
		Gui, DynamicHotkey:-Disabled
		WinActivate, DynamicHotkey ahk_class AutoHotkeyGUI
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Start()
			this.winEventMinimizeEnd.Start()
		}
	}

	GuiProfileButtonRename()
	{
		this := DynamicHotkey.instance
		If ((selectedProfile := this.SelectedProfile) == "Default")
		{
			DisplayToolTip("Default profile can't be renamed")
		}
		Else If (selectedProfile != "")
		{
			this.GuiProfileButtonCreate(,,, selectedProfile, True)
		}
	}

	GuiProfileButtonCopy()
	{
		this := DynamicHotkey.instance
		If ((selectedProfile := this.SelectedProfile) != "")
		{
			this.GuiProfileButtonCreate(,,, selectedProfile, False)
		}
	}

	GuiProfileButtonDelete()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If ((selectedProfile := this.SelectedProfile) == "Default")
		{
			FileDelete, % this.profileDir "\Default.ini"
			IniWrite, 0, % this.profileDir "\Default.ini", Total, Num
			DisplayToolTip("Reset default profile")
		}
		Else If (selectedProfile != "")
		{
			FileDelete, % this.profileDir "\" selectedProfile ".ini"
			ArrayReplace(this.profiles, selectedProfile)
			this.SelectedProfile := "|"
			For key, value In this.profiles
			{
				this.SelectedProfile := value
			}
			DisplayToolTip("Profile deleted")
		}
	}

	GuiProfileButtonSave()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If ((selectedProfile := this.SelectedProfile) != "")
		{
			Gui, DynamicHotkey:+Disabled
			this.SaveProfile(selectedProfile)
			DisplayToolTip("Profile saved")
			Gui, DynamicHotkey:-Disabled
		}
	}

	GuiProfileButtonLoad()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If ((selectedProfile := this.SelectedProfile) != "")
		{
			Gui, DynamicHotkey:+Disabled
			If (!this.absoluteProfiles.Count())
			{
				this.DeleteAllHotkeys()
			}
			Else
			{
				this.DeleteNotAbsoluteKeys()
			}
			this.LoadProfile(selectedProfile)
			this.RefreshListView()
			DisplayToolTip("Profile loaded")
			Gui, DynamicHotkey:-Disabled
		}
	}

	GuiProfileButtonLink()
	{
		If (WinExist("Link Data ahk_class AutoHotkeyGUI"))
		{
			Return
		}
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Stop()
			this.winEventMinimizeEnd.Stop()
		}
		Gui, DynamicHotkey:+Disabled
		Gui, LinkData:New, +LabelDynamicHotkey.LinkProfileGui +OwnerDynamicHotkey -SysMenu, Link Data
		If (this.isAlwaysOnTop)
		{
			Gui, LinkData:+AlwaysOnTop
		}
		Gui, LinkData:Add, ListView, x+1 y+8 w404 h208 HwndhLinkListView GDynamicHotkey.LinkProfileGuiEventListView AltSubmit NoSort -LV0x10 -Multi, Profile name|Window name|Process path|Mode
		this.hLinkListView := hLinkListView
		Gui, LinkData:Add, Button, xs-1 w78 GDynamicHotkey.LinkProfileGuiButtonCreate, Create
		Gui, LinkData:Add, Button, x+4 w78 GDynamicHotkey.LinkProfileGuiButtonEdit, Edit
		Gui, LinkData:Add, Button, x+4 w78 GDynamicHotkey.LinkProfileGuiButtonCopy, Copy
		Gui, LinkData:Add, Button, x+4 w78 GDynamicHotkey.LinkProfileGuiButtonDelete, Delete
		Gui, LinkData:Add, Button, x+4 w78 GDynamicHotkey.LinkProfileGuiClose, Close
		GuiControl, LinkData:-Redraw, % this.hLinkListView
		LV_Delete()
		For key, value In this.linkData
		{
			data := StrSplit(value, "|")
			LV_Add(, data[1], data[2], data[3], data[4])
		}
		LV_AdjustCol()
		GuiControl, LinkData:+Redraw, % this.hLinkListView
		Gui, LinkData:Show
	}

	LinkProfileGuiEventListView()
	{
		Critical
		this := DynamicHotkey.instance
		If (A_GuiControlEvent == "I")
		{
			If (InStr(ErrorLevel, "s", True))
			{
				this.selectLinkNum := ""
				this.selectLinkData := ""
			}
			Else If (InStr(ErrorLevel, "S", True) && A_EventInfo > 0)
			{
				this.selectLinkNum := A_EventInfo
				this.selectLinkData := this.GetLinkData(this.selectLinkNum)
			}
		}
		If (A_GuiControlEvent == "D")
		{
			this.selectLinkNum := LV_DragAndDrop(A_GuiControlEvent)
			this.selectLinkData := this.GetLinkData(this.selectLinkNum)
			If (this.selectLinkNum != A_EventInfo)
			{
				this.linkData.InsertAt(this.selectLinkNum, this.linkData.RemoveAt(A_EventInfo))
				this.SaveLinkData()
			}
		}
		If (A_GuiControlEvent == "DoubleClick")
		{
			this.LinkProfileGuiButtonEdit()
		}
	}

	LinkProfileGuiContextMenu(CtrlHwnd := "", EventInfo := "", IsRightClick := "", X := "", Y := "")
	{
		this := DynamicHotkey.instance
		If (IsRightClick)
		{
			If (CtrlHwnd == this.hLinkListView)
			{
				If (this.selectLinkNum == "")
				{
					Menu, LinkMenuNotExist, Show
				}
				Else
				{
					Menu, LinkMenuExist, Show
				}
			}
		}
	}

	LinkProfileGuiButtonCreate(GuiEvent := "", EventInfo := "", ErrLevel := "", selectLinkData := "", isEdit := False)
	{
		If (WinExist("New Link Data ahk_class AutoHotkeyGUI") || WinExist("Edit Link Data ahk_class AutoHotkeyGUI"))
		{
			Return
		}
		this := DynamicHotkey.instance
		this.enableKeys := this.GetEnableKeys()
		this.DisableAllHotkeys()
		Gui, LinkData:+Disabled
		If (selectLinkData != "" && isEdit)
		{
			Gui, NewLinkData:New, +LabelDynamicHotkey.NewLinkDataGui +OwnerDynamicHotkey -SysMenu, Edit Link Data
		}
		Else
		{
			LV_Modify(0, "-Select -Focus")
			Gui, NewLinkData:New, +LabelDynamicHotkey.NewLinkDataGui +OwnerDynamicHotkey -SysMenu, New Link Data
		}
		If (this.isAlwaysOnTop)
		{
			Gui, NewLinkData:+AlwaysOnTop
		}
		Gui, NewLinkData:Add, Text, y+8 Section, Profile
		Gui, NewLinkData:Add, DropDownList, xs+0 w198 HwndhNewLinkProfile
		this.hNewLinkProfile := hNewLinkProfile
		Gui, NewLinkData:Add, Text, x+4 ys+0, Mode
		Gui, NewLinkData:Add, DropDownList, xp+0 y+6 w198 HwndhNewLinkMode
		this.hNewLinkMode := hNewLinkMode
		Gui, NewLinkData:Add, Text, xs+0 y+8, Window name
		Gui, NewLinkData:Add, Edit, xs+0 w400 r1 -VScroll HwndhNewLinkWindow
		this.hNewLinkWindow := hNewLinkWindow
		Gui, NewLinkData:Add, Text, xs+0 y+8, Process path
		Gui, NewLinkData:Add, Edit, xs+0 w400 r1 -VScroll HwndhNewLinkProcess
		this.hNewLinkProcess := hNewLinkProcess
		Gui, NewLinkData:Add, Button, xs-1 y+8 w402 HwndhNewLinkWindowInfo GDynamicHotkey.NewLinkDataGuiWindowInfo, Get window info
		this.hNewLinkWindowInfo := hNewLinkWindowInfo
		If (selectLinkData != "" && isEdit)
		{
			Gui, NewLinkData:Add, Button, xs-1 w200 Default GDynamicHotkey.NewLinkDataGuiButtonOKEdit, OK
		}
		Else
		{
			Gui, NewLinkData:Add, Button, xs-1 w200 Default GDynamicHotkey.NewLinkDataGuiButtonOKNew, OK
		}
		Gui, NewLinkData:Add, Button, x+2 w200 GDynamicHotkey.NewLinkDataGuiClose, Cancel
		For key, value In this.profiles
		{
			this.NewLinkProfile := value
		}
		modes := ["Active", "Exist", "Absolute"]
		For key, value In modes
		{
			this.NewLinkMode := value
		}
		If (selectLinkData != "")
		{
			data := StrSplit(selectLinkData, "|")
			GuiControl, NewLinkData:Choose, % this.hNewLinkProfile, % InArray(this.profiles, data[1])
			this.NewLinkWindow := data[2]
			this.NewLinkProcess := data[3]
			GuiControl, NewLinkData:Choose, % this.hNewLinkMode, % InArray(modes, data[4])
		}
		Else
		{
			GuiControl, NewLinkData:Choose, % this.hNewLinkProfile, 1
			GuiControl, NewLinkData:Choose, % this.hNewLinkMode, 1
		}
		Gui, NewLinkData:Show
	}

	NewLinkDataGuiWindowInfo()
	{
		this := DynamicHotkey.instance
		If (!this.isAlwaysOnTop)
		{
			Gui, NewLinkData:+AlwaysOnTop
		}
		this.NewLinkWindowInfo := "Click other window"
		GuiControl, NewLinkData:Disable, % this.hNewLinkWindowInfo
		Gui, NewLinkData:+Disabled
		WinGet, guiHwnd, ID, A
		funcDetectWindowInfo := ObjBindMethod(this, "DetectWindowInfo", "NewLinkData", guiHwnd, this.hNewLinkWindowInfo, this.hNewLinkWindow, this.hNewLinkProcess)
		this.winEventForeGround.SetFunc(funcDetectWindowInfo)
		this.winEventMinimizeEnd.SetFunc(funcDetectWindowInfo)
		this.winEventForeGround.Start()
		this.winEventMinimizeEnd.Start()
	}

	NewLinkDataGuiButtonOKEdit()
	{
		Gui, LinkData:Default
		this := DynamicHotkey.instance
		this.NewLinkDataGuiButtonOKNew(,,, True)
	}

	NewLinkDataGuiButtonOKNew(GuiEvent := "", EventInfo := "", ErrLevel := "", isEdit := False)
	{
		Gui, LinkData:Default
		this := DynamicHotkey.instance
		newLinkProfile := this.NewLinkProfile
		newLinkWindow := this.NewLinkWindow
		newLinkProcess := this.FormatProcessPath(this.NewLinkProcess)
		newLinkMode := this.NewLinkMode
		If (newLinkProfile == "" || (newLinkWindow == "" && newLinkProcess == "") || newLinkMode == "")
		{
			DisplayToolTip("Link data is invalid")
			Return
		}
		For key, value In this.linkData
		{
			If (StrContains(value, isEdit ? newLinkProfile "|" newLinkWindow "|" newLinkProcess "|" newLinkMode : "|" newLinkWindow "|" newLinkProcess "|"))
			{
				DisplayToolTip("Link data already exists")
				Return
			}
		}
		If (isEdit)
		{
			selectLinkNum := this.selectLinkNum
			this.LinkProfileGuiButtonDelete(,,, True)
			LV_Insert(selectLinkNum,, newLinkProfile, newLinkWindow, newLinkProcess, newLinkMode)
			this.SetLinkData(newLinkProfile, newLinkWindow, newLinkProcess, newLinkMode, selectLinkNum)
		}
		Else
		{
			LV_Add(, newLinkProfile, newLinkWindow, newLinkProcess, newLinkMode)
			this.SetLinkData(newLinkProfile, newLinkWindow, newLinkProcess, newLinkMode)
		}
		this.SaveLinkData()
		LV_AdjustCol()
		this.NewLinkDataGuiClose()
		If (isEdit)
		{
			DisplayToolTip("Link data edited")
		}
		Else
		{
			DisplayToolTip("Link data created")
		}
	}

	NewLinkDataGuiEscape()
	{
		this := DynamicHotkey.instance
		this.NewLinkDataGuiClose()
	}

	NewLinkDataGuiClose()
	{
		this := DynamicHotkey.instance
		this.EnableHotkeys(this.enableKeys)
		this.enableKeys := ""
		this.absoluteProfiles.Delete(InArray(this.absoluteProfiles, this.NewLinkProfile))
		this.hNewLinkProfile := ""
		this.hNewLinkWindow := ""
		this.hNewLinkProcess := ""
		this.hNewLinkMode := ""
		this.hNewLinkWindowInfo := ""
		Gui, NewLinkData:Destroy
		Gui, LinkData:-Disabled
		WinActivate, Link Data ahk_class AutoHotkeyGUI
	}

	LinkProfileGuiButtonEdit()
	{
		this := DynamicHotkey.instance
		If (this.selectLinkNum != "" && this.selectLinkData != "")
		{
			this.LinkProfileGuiButtonCreate(,,, this.selectLinkData, True)
		}
	}

	LinkProfileGuiButtonCopy()
	{
		this := DynamicHotkey.instance
		If (this.selectLinkNum != "" && this.selectLinkData != "")
		{
			this.LinkProfileGuiButtonCreate(,,, this.selectLinkData, False)
		}
	}

	LinkProfileGuiButtonDelete(GuiEvent := "", EventInfo := "", ErrLevel := "", isEdit := False)
	{
		Gui, LinkData:Default
		this := DynamicHotkey.instance
		If (this.selectLinkNum != "" && this.selectLinkData != "")
		{
			If (this.DeleteLinkData(this.selectLinkData))
			{
				LV_Delete(this.selectLinkNum)
				this.SaveLinkData()
				LV_AdjustCol()
				If (!isEdit)
				{
					DisplayToolTip("Link data deleted")
				}
			}
			Else If (!isEdit)
			{
				DisplayToolTip("Link data doesn't exist")
			}
			this.selectLinkNum := ""
			this.selectLinkData := ""
		}
	}

	LinkProfileGuiEscape()
	{
		this := DynamicHotkey.instance
		this.LinkProfileGuiClose()
	}

	LinkProfileGuiClose()
	{
		this := DynamicHotkey.instance
		this.selectLinkNum := ""
		this.selectLinkData := ""
		this.hLinkListView := ""
		Gui, LinkData:Destroy
		Gui, DynamicHotkey:-Disabled
		WinActivate, DynamicHotkey ahk_class AutoHotkeyGUI
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Start()
			this.winEventMinimizeEnd.Start()
		}
	}

	GuiChangeIsStart()
	{
		this := DynamicHotkey.instance
		If (this.isStartWithWindows := this.IsStart)
		{
			MsgBox, 0x40024, DynamicHotkey, Do you want to launch DynamicHotkey as administrator on startup?
			IfMsgBox, Yes
			{
				If (RegisterTaskScheduler())
				{
					UnregisterStartup()
				}
				Else
				{
					this.IsStart := this.isStartWithWindows := False
				}
			}
			Else If (UnregisterTaskScheduler())
			{
				RegisterStartup(,,,,, A_ScriptDir "\Resources\DynamicHotkey.ico")
			}
			Else
			{
				this.IsStart := this.isStartWithWindows := False
			}
		}
		Else If (UnregisterTaskScheduler())
		{
			UnregisterStartup()
		}
		Else
		{
			this.IsStart := this.isStartWithWindows := True
		}
		IniWrite, % this.isStartWithWindows, % this.configFile, DynamicHotkey, IsStartWithWindows
	}

	GuiChangeIsOpen()
	{
		this := DynamicHotkey.instance
		this.isOpenAtLaunch := this.IsOpen
		IniWrite, % this.isOpenAtLaunch, % this.configFile, DynamicHotkey, IsOpenAtLaunch
	}

	GuiChangeIsTop()
	{
		this := DynamicHotkey.instance
		If (this.isAlwaysOnTop := this.IsTop)
		{
			Gui, DynamicHotkey:+AlwaysOnTop
		}
		Else
		{
			Gui, DynamicHotkey:-AlwaysOnTop
		}
		IniWrite, % this.isAlwaysOnTop, % this.configFile, DynamicHotkey, IsAlwaysOnTop
	}

	GuiChangeIsSwitch()
	{
		this := DynamicHotkey.instance
		If (this.isAutoSwitch := this.IsSwitch)
		{
			this.winEventForeGround.Start()
			this.winEventMinimizeEnd.Start()
			Menu, Tray, Check, Auto profile switching
		}
		Else
		{
			this.winEventForeGround.Stop()
			this.winEventMinimizeEnd.Stop()
			this.absoluteProfiles := {}
			Menu, Tray, UnCheck, Auto profile switching
		}
		IniWrite, % this.isAutoSwitch, % this.configFile, DynamicHotkey, IsAutoSwitch
	}

	GuiChangeCapsLock()
	{
		this := DynamicHotkey.instance
		Switch this.capsLockType := this.CapsLockState
		{
			Case "Normal": SetCapsLockState
			Case "AlwaysOn": SetCapsLockState, AlwaysOn
			Case "AlwaysOff": SetCapsLockState, AlwaysOff
		}
		IniWrite, % this.capsLockType, % this.configFile, DynamicHotkey, CapsLockState
	}

	GuiChangeNumLock()
	{
		this := DynamicHotkey.instance
		Switch this.numLockType := this.NumLockState
		{
			Case "Normal": SetNumLockState
			Case "AlwaysOn": SetNumLockState, AlwaysOn
			Case "AlwaysOff": SetNumLockState, AlwaysOff
		}
		IniWrite, % this.numLockType, % this.configFile, DynamicHotkey, NumLockState
	}

	GuiChangeScrollLock()
	{
		this := DynamicHotkey.instance
		Switch this.scrollLockType := this.ScrollLockState
		{
			Case "Normal": SetScrollLockState
			Case "AlwaysOn": SetScrollLockState, AlwaysOn
			Case "AlwaysOff": SetScrollLockState, AlwaysOff
		}
		IniWrite, % this.scrollLockType, % this.configFile, DynamicHotkey, ScrollLockState
	}

	GuiEscape()
	{
		this := DynamicHotkey.instance
		this.GuiClose()
	}

	GuiClose()
	{
		Gui, DynamicHotkey:Show, Hide
	}

	; Private methods
	FormatProcessPath(processPath)
	{
		Return processPath != "" ? (SubStr(processPath, -3) != ".exe" ? processPath ".exe" : processPath) : processPath
	}

	FormatKey(key, search, format)
	{
		keys := []
		replacedKey := StrReplace(key, A_Space)
		If (matchPos := InStr(replacedKey, search))
		{
			keys.Push(SubStr(replacedKey, 1, matchPos - 1))
			keys.Push(StrReplace(SubStr(replacedKey, matchPos), search))
		}
		Else
		{
			keys.Push(replacedKey)
		}
		Loop, % keys.Count()
		{
			If (StrLen(keys[A_Index]) == 1)
			{
				keys[A_Index] := Format(format, keys[A_Index])
			}
		}
		Return matchPos ? keys[1] A_Space search A_Space keys[2] : keys[1]
	}

	ToDisplayKey(inputKey)
	{
		matchPos := RegExMatch(inputKey, "[^\~\*\<\^\!\+\#]")
		prefix := SubStr(inputKey, 1, matchPos - 1)
		prefix := RegExReplace(prefix, "[\~\*\<]")
		prefix := StrReplace(prefix, "+", "Shift + ")
		prefix := StrReplace(prefix, "^", "Ctrl + ")
		prefix := StrReplace(prefix, "!", "Alt + ")
		prefix := StrReplace(prefix, "#", "Win + ")
		key := SubStr(inputKey, matchPos)
		key := this.FormatKey(key, "&", "{:U}")
		key := StrReplace(key, "&", "+")
		key := StrReplace(key, "sc029", "半角/全角")
		key := StrReplace(key, "sc03A", "英数")
		key := StrReplace(key, "sc070", "ひらがな")
		key := StrReplace(key, "sc07B", "無変換")
		key := StrReplace(key, "sc079", "変換")
		Return prefix key
	}

	ToDisplayKeyAlt(displayKey)
	{
		replacedKey := StrReplace(displayKey, "ShiftAltTab", "Shift + Alt + Tab")
		replacedKey := StrReplace(replacedKey, "AltTab", "Alt + Tab")
		Return replacedKey
	}

	ToInputKey(displayKey)
	{
		replacedKey := RegExReplace(displayKey, "[\~\*\<]")
		replacedKey := StrReplace(replacedKey, "Ctrl + ", "^")
		replacedKey := StrReplace(replacedKey, "Alt + ", "!")
		replacedKey := StrReplace(replacedKey, "Shift + ", "+")
		replacedKey := StrReplace(replacedKey, "Win + ", "#")
		matchPos := RegExMatch(replacedKey, "[^\^\!\+\#]")
		prefix := SubStr(replacedKey, 1, matchPos - 1)
		key := SubStr(replacedKey, matchPos)
		key := this.FormatKey(key, "+", "{:L}")
		key := StrReplace(key, "+", "&")
		key := StrReplace(key, "半角/全角", "sc029")
		key := StrReplace(key, "英数", "sc03A")
		key := StrReplace(key, "ひらがな", "sc070")
		key := StrReplace(key, "無変換", "sc07B")
		key := StrReplace(key, "変換", "sc079")
		Return prefix key
	}

	GetFirstKey(key)
	{
		Return (matchPos := InStr(key, " & ")) ? SubStr(key, 1, matchPos - 1) : key
	}

	GetSecondKey(key)
	{
		Return (matchPos := InStr(key, " & ")) ? StrReplace(SubStr(key, matchPos), " & ") : ""
	}

	GetKeyListState(isMulti := False, mode := "", keyList*)
	{
		key := ""
		For index, param In keyList
		{
			If (isMulti)
			{
				key .= (param == "Win" ? (GetKeyState("L" param, mode) || GetKeyState("R" param, mode)) : GetKeyState(param, mode)) ? (key ? " + " param : param) : ""
			}
			Else
			{
				key := (param == "Win" ? (GetKeyState("L" param, mode) || GetKeyState("R" param, mode)) : GetKeyState(param, mode)) ? param : ""
				If (key)
				{
					Break
				}
			}
		}
		Return key
	}

	GetWheelState()
	{
		this.wheelState := RegExReplace(A_ThisHotkey, "[\~\*\<\>\^\!\+\#]")
	}

	DoNothing()
	{
		Return
	}

	KeyBind(hwndEdit, hwndButton, isPrefixEnabled := True, isMouseEnabled := True)
	{
		key := ""
		getWheelStateFunc := ObjBindMethod(this, "GetWheelState")
		doNothingFunc := DynamicHotkey.doNothingFunc
		GuiControl, Focus, % hwndEdit
		GuiControl,, % hwndButton, Press any key
		GuiControl, Disable, % hwndButton
		If (isMouseEnabled)
		{
			Hotkey, *WheelDown, % getWheelStateFunc, UseErrorLevel On
			Hotkey, *WheelUp, % getWheelStateFunc, UseErrorLevel On
			Hotkey, *WheelLeft, % getWheelStateFunc, UseErrorLevel On
			Hotkey, *WheelRight, % getWheelStateFunc, UseErrorLevel On
		}
		Loop
		{
			If (key == "")
			{
				key := KeyWaitCombo("{All}", "{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{sc178}{vkFF}", "T0.1")
			}
			If (isMouseEnabled)
			{
				If (key == "")
				{
					key := this.GetKeyListState(,, "LButton", "RButton", "MButton", "XButton1", "XButton2")
				}
				If (key == "" && this.wheelState)
				{
					key := this.wheelState
				}
			}
			If (key != "")
			{
				If (isPrefixEnabled)
				{
					prefix := this.GetKeyListState(True, "P", "Ctrl", "Alt", "Shift", "Win")
					key := prefix ? prefix " + " key : key
					key := this.ToInputKey(key)
				}
				Break
			}
		}
		If (isMouseEnabled)
		{
			Hotkey, *WheelDown, % doNothingFunc, UseErrorLevel Off
			Hotkey, *WheelUp, % doNothingFunc, UseErrorLevel Off
			Hotkey, *WheelLeft, % doNothingFunc, UseErrorLevel Off
			Hotkey, *WheelRight, % doNothingFunc, UseErrorLevel Off
		}
		this.wheelState := ""
		GuiControl,, % hwndEdit, % this.ToDisplayKey(key)
		GuiControl,, % hwndButton, Bind
		GuiControl, Enable, % hwndButton
	}

	SortListView()
	{
		LV_AdjustCol()
		LV_SortCol(, 8, 7, 6, 5, 4, 3, 2)
	}

	ListViewAdd(key)
	{
		comboKey := (matchPos := InStr(key, "->")) ? StrReplace(SubStr(key, matchPos), "->") : ""
		key := matchPos ? SubStr(key, 1, matchPos - 1) : key
		If (comboKey == "All")
		{
			For index In this.hotkeys[key].comboKeyInstances
			{
				this.ListViewAdd(key "->" index)
			}
			Return
		}
		hotkeyInstance := matchPos ? this.hotkeys[key].comboKeyInstances[comboKey] : this.hotkeys[key]
		inputKey := this.ToDisplayKey(this.hotkeys[key].inputKey)
		inputKey := matchPos ? inputKey " -> " this.ToDisplayKey(comboKey) : inputKey
		isEnabled := hotkeyInstance.isEnabled ? "✓" : "✗"
		options := ""
		outputs := {}
		If (InStr(this.hotkeys[key].inputKey, "*"))
		{
			options .= "Wild card"
		}
		If (InStr(this.hotkeys[key].inputKey, "~"))
		{
			If (options)
			{
				options .= ", "
			}
			options .= "Pass through"
		}
		If (this.hotkeys[key].isDirect)
		{
			If (options)
			{
				options .= ", "
			}
			options .= "Direct send"
		}
		If (this.hotkeys[key].isShowToolTip)
		{
			If (options)
			{
				options .= ", "
			}
			options .= "Show tooltip"
		}
		If (this.hotkeys[key].comboKeyInstances.Count())
		{
			If (options)
			{
				options .= ", "
			}
			options .= "Wait:" (InStr(this.hotkeys[key].waitTime, ".") ? Format("{:0.1f}", this.hotkeys[key].waitTime) : Format("{:d}", this.hotkeys[key].waitTime)) "s"
		}
		For key2 In this.e_output
		{
			If (hotkeyInstance.outputKey.HasKey(key2))
			{
				outputs[key2] := this.ToDisplayKey(hotkeyInstance.outputKey[key2]) hotkeyInstance.runCommand[key2] hotkeyInstance.function[key2]
				If (key2 == "Double")
				{
					outputs[key2] .= ", Interval:" (InStr(hotkeyInstance.doublePressTime, ".") ? Format("{:0.1f}", hotkeyInstance.doublePressTime) : Format("{:d}", hotkeyInstance.doublePressTime)) "s"
				}
				Else If (key2 == "Long")
				{
					outputs[key2] .= ", Interval:" (InStr(hotkeyInstance.longPressTime, ".") ? Format("{:0.1f}", hotkeyInstance.longPressTime) : Format("{:d}", hotkeyInstance.longPressTime)) "s"
				}
				If (hotkeyInstance.workingDir[key2])
				{
					outputs[key2] .= ", Working directory:" hotkeyInstance.workingDir[key2]
				}
				If (hotkeyInstance.arg[key2])
				{
					outputs[key2] .= ", Argument:" hotkeyInstance.arg[key2]
				}
				If (hotkeyInstance.isBlind[key2])
				{
					outputs[key2] .= ", Blind"
				}
				If (hotkeyInstance.isToggle[key2])
				{
					outputs[key2] .= ", Toggle"
				}
				If (hotkeyInstance.repeatTime[key2])
				{
					outputs[key2] .= ", Repeat:" hotkeyInstance.repeatTime[key2] "s"
				}
				If (hotkeyInstance.holdTime[key2])
				{
					outputs[key2] .= ", Hold:" hotkeyInstance.holdTime[key2] "s"
				}
				If (hotkeyInstance.isAdmin[key2])
				{
					outputs[key2] .= ", Run as admin"
				}
				If (hotkeyInstance.coord[key2])
				{
					outputs[key2] .= ", Coord mode:" hotkeyInstance.coord[key2]
				}
				If (hotkeyInstance.posX[key2] != "")
				{
					outputs[key2] .= ", X:" hotkeyInstance.posX[key2]
				}
				If (hotkeyInstance.posY[key2] != "")
				{
					outputs[key2] .= ", Y:" hotkeyInstance.posY[key2]
				}
			}
			Else
			{
				outputs[key2] := ""
			}
		}
		If (this.hotkeys[key].comboKeyInstances.Count())
		{
			Loop % LV_GetCount()
			{
				If (InStr(this.GetListViewKey(A_Index), key))
				{
					LV_Modify(A_Index,,,,,, options)
				}
			}
		}
		LV_Add(, isEnabled, inputKey, this.hotkeys[key].windowName, this.hotkeys[key].processPath, options, outputs["Single"], outputs["Double"], outputs["Long"])
	}

	RefreshListView()
	{
		GuiControl, DynamicHotkey:-Redraw, % this.hListView
		LV_Delete()
		For key In this.hotkeys
		{
			cnt := this.hotkeys[key].comboKeyInstances.Count()
			this.ListViewAdd(this.hotkeys[key].comboKeyInstances.Count() ? key "->All" : key)
		}
		this.SortListView()
		GuiControl, DynamicHotkey:+Redraw, % this.hListView
	}

	GetListViewKey(listViewNum)
	{
		inputKey := ""
		windowName := ""
		processPath := ""
		options := ""
		comboKey := ""
		LV_GetText(inputKey, listViewNum, 2)
		LV_GetText(windowName, listViewNum, 3)
		LV_GetText(processPath, listViewNum, 4)
		LV_GetText(options, listViewNum, 5)
		isDirect := InStr(options, "Direct send") ? True : False
		If (matchPos := InStr(inputKey, " -> "))
		{
			comboKey := "->" this.ToInputKey(StrReplace(SubStr(inputKey, matchPos), " -> "))
			inputKey := SubStr(inputKey, 1, matchPos - 1)
		}
		Return this.ToInputKey(inputKey) windowName processPath isDirect comboKey
	}

	SaveProfile(profile)
	{
		this.nowProfile := profile
		profileName := this.profileDir "\" profile ".ini"
		FileDelete, % profileName
		cnt := this.hotkeys.Count()
		For key In this.hotkeys
		{
			comboCnt := this.hotkeys[key].comboKeyInstances.Count()
			cnt += comboCnt ? comboCnt - 1 : 0 
		}
		IniWrite, % cnt, % profileName, Total, Num
		index := 1
		For key In this.hotkeys
		{
			If (this.hotkeys[key].comboKeyInstances.Count())
			{
				For combokey, instance In this.hotkeys[key].comboKeyInstances
				{
					IniWrite, % this.hotkeys[key].inputKey "->" combokey, % profileName, % index, InputKey
					IniWrite, % this.hotkeys[key].windowName, % profileName, % index, WindowName
					IniWrite, % this.hotkeys[key].processPath, % profileName, % index, ProcessPath
					IniWrite, % this.hotkeys[key].isDirect, % profileName, % index, IsDirect
					IniWrite, % this.hotkeys[key].isShowToolTip, % profileName, % index, IsShowToolTip
					waitTime := (InStr(this.hotkeys[key].waitTime, ".") ? Format("{:0.1f}", this.hotkeys[key].waitTime) : Format("{:d}", this.hotkeys[key].waitTime))
					IniWrite, % waitTime, % profileName, % index, WaitTime
					If (instance.doublePressTime != "")
					{
						doublePressTime := InStr(instance.doublePressTime, ".") ? Format("{:0.1f}", instance.doublePressTime) : Format("{:d}", instance.doublePressTime)
						IniWrite, % doublePressTime, % profileName, % index, DoublePressTime
					}
					If (instance.longPressTime != "")
					{
						longPressTime := InStr(instance.longPressTime, ".") ? Format("{:0.1f}", instance.longPressTime) : Format("{:d}", instance.longPressTime)
						IniWrite, % longPressTime, % profileName, % index, LongPressTime
					}
					For key2 In this.e_output
					{
						If (!instance.outputKey.HasKey(key2) && !instance.runCommand.HasKey(key2) && !instance.function.HasKey(key2))
						{
							Continue
						}
						IniWrite, % instance.outputKey[key2], % profileName, % index, % "OutputKey" key2
						IniWrite, % instance.runCommand[key2], % profileName, % index, % "RunCommand" key2
						IniWrite, % instance.workingDir[key2], % profileName, % index, % "WorkingDir" key2
						IniWrite, % instance.function[key2], % profileName, % index, % "Function" key2
						IniWrite, % instance.arg[key2], % profileName, % index, % "Argument" key2
						IniWrite, % instance.isBlind[key2], % profileName, % index, % "IsBlind" key2
						IniWrite, % instance.isToggle[key2], % profileName, % index, % "IsToggle" key2
						IniWrite, % instance.repeatTime[key2], % profileName, % index, % "RepeatTime" key2
						IniWrite, % instance.holdTime[key2], % profileName, % index, % "HoldTime" key2
						IniWrite, % instance.isAdmin[key2], % profileName, % index, % "IsAdmin" key2
						IniWrite, % instance.posX[key2], % profileName, % index, % "PosX" key2
						IniWrite, % instance.posY[key2], % profileName, % index, % "PosY" key2
						IniWrite, % instance.coord[key2], % profileName, % index, % "CoordMode" key2
					}
					index++
				}
			}
			Else
			{
				IniWrite, % this.hotkeys[key].inputKey, % profileName, % index, InputKey
				IniWrite, % this.hotkeys[key].windowName, % profileName, % index, WindowName
				IniWrite, % this.hotkeys[key].processPath, % profileName, % index, ProcessPath
				IniWrite, % this.hotkeys[key].isDirect, % profileName, % index, IsDirect
				IniWrite, % this.hotkeys[key].isShowToolTip, % profileName, % index, IsShowToolTip
				If (this.hotkeys[key].doublePressTime != "")
				{
					doublePressTime := InStr(this.hotkeys[key].doublePressTime, ".") ? Format("{:0.1f}", this.hotkeys[key].doublePressTime) : Format("{:d}", this.hotkeys[key].doublePressTime)
					IniWrite, % doublePressTime, % profileName, % index, DoublePressTime
				}
				If (this.hotkeys[key].longPressTime != "")
				{
					longPressTime := InStr(this.hotkeys[key].longPressTime, ".") ? Format("{:0.1f}", this.hotkeys[key].longPressTime) : Format("{:d}", this.hotkeys[key].longPressTime)
					IniWrite, % longPressTime, % profileName, % index, LongPressTime
				}
				For key2 In this.e_output
				{
					If (!this.hotkeys[key].outputKey.HasKey(key2) && !this.hotkeys[key].runCommand.HasKey(key2) && !this.hotkeys[key].function.HasKey(key2))
					{
						Continue
					}
					IniWrite, % this.hotkeys[key].outputKey[key2], % profileName, % index, % "OutputKey" key2
					IniWrite, % this.hotkeys[key].runCommand[key2], % profileName, % index, % "RunCommand" key2
					IniWrite, % this.hotkeys[key].workingDir[key2], % profileName, % index, % "WorkingDir" key2
					IniWrite, % this.hotkeys[key].function[key2], % profileName, % index, % "Function" key2
					IniWrite, % this.hotkeys[key].arg[key2], % profileName, % index, % "Argument" key2
					IniWrite, % this.hotkeys[key].isBlind[key2], % profileName, % index, % "IsBlind" key2
					IniWrite, % this.hotkeys[key].isToggle[key2], % profileName, % index, % "IsToggle" key2
					IniWrite, % this.hotkeys[key].repeatTime[key2], % profileName, % index, % "RepeatTime" key2
					IniWrite, % this.hotkeys[key].holdTime[key2], % profileName, % index, % "HoldTime" key2
					IniWrite, % this.hotkeys[key].isAdmin[key2], % profileName, % index, % "IsAdmin" key2
					IniWrite, % this.hotkeys[key].posX[key2], % profileName, % index, % "PosX" key2
					IniWrite, % this.hotkeys[key].posY[key2], % profileName, % index, % "PosY" key2
					IniWrite, % this.hotkeys[key].coord[key2], % profileName, % index, % "CoordMode" key2
				}
				index++
			}
		}
	}

	LoadProfile(profile)
	{
		profileName := this.profileDir "\" profile ".ini"
		IniRead, totalKeys, % profileName, Total, Num
		If (totalKeys != "ERROR")
		{
			this.nowProfile := profile
			Loop, % totalKeys
			{
				index := A_Index
				outputKeys := {}
				runCommands := {}
				workingDirs := {}
				functions := {}
				args := {}
				isBlinds := {}
				isToggles := {}
				repeatTimes := {}
				holdTimes := {}
				isAdmins := {}
				posXs := {}
				posYs := {}
				coords := {}
				IniRead, inputKey, % profileName, % index, InputKey
				IniRead, windowName, % profileName, % index, WindowName
				IniRead, processPath, % profileName, % index, ProcessPath
				IniRead, isDirect, % profileName, % index, IsDirect
				IniRead, isShowToolTip, % profileName, % index, IsShowToolTip
				IniRead, waitTime, % profileName, % index, WaitTime
				IniRead, doublePressTime, % profileName, % index, DoublePressTime
				IniRead, longPressTime, % profileName, % index, LongPressTime
				If (inputKey == "ERROR")
				{
					Continue
				}
				comboKey := ""
				If (matchPos := InStr(inputKey, "->"))
				{
					comboKey := StrReplace(SubStr(inputKey, matchPos), "->")
					inputKey := SubStr(inputKey, 1, matchPos - 1)
				}
				If (windowName == "ERROR")
				{
					windowName := ""
				}
				If (processPath == "ERROR")
				{
					processPath := ""
				}
				If (isDirect == "ERROR")
				{
					isDirect := False
				}
				If (isShowToolTip == "ERROR")
				{
					isShowToolTip := False
				}
				If (waitTime == "ERROR")
				{
					waitTime := ""
				}
				If (doublePressTime == "ERROR")
				{
					doublePressTime := ""
				}
				If (longPressTime == "ERROR")
				{
					longPressTime := ""
				}
				For key In this.e_output
				{
					IniRead, outputKey, % profileName, % index, % "OutputKey" key
					IniRead, runCommand, % profileName, % index, % "RunCommand" key
					IniRead, workingDir, % profileName, % index, % "WorkingDir" key
					IniRead, function, % profileName, % index, % "Function" key
					IniRead, arg, % profileName, % index, % "Argument" key
					IniRead, isBlind, % profileName, % index, % "IsBlind" key
					IniRead, isToggle, % profileName, % index, % "IsToggle" key
					IniRead, repeatTime, % profileName, % index, % "RepeatTime" key
					IniRead, holdTime, % profileName, % index, % "HoldTime" key
					IniRead, isAdmin, % profileName, % index, % "IsAdmin" key
					IniRead, posX, % profileName, % index, % "PosX" key
					IniRead, posY, % profileName, % index, % "PosY" key
					IniRead, coord, % profileName, % index, % "CoordMode" key
					If (outputKey == "ERROR" || runCommand == "ERROR" || function == "ERROR" || (outputKey == "" && runCommand == "" && function == ""))
					{
						Continue
					}
					If (workingDir == "ERROR")
					{
						workingDir := ""
					}
					If (arg == "ERROR")
					{
						arg := ""
					}
					If (isBlind == "ERROR")
					{
						isBlind := False
					}
					If (isToggle == "ERROR")
					{
						isToggle := False
					}
					If (repeatTime == "ERROR")
					{
						repeatTime := 0
					}
					If (holdTime == "ERROR")
					{
						holdTime := 0
					}
					If (isAdmin == "ERROR")
					{
						isAdmin := False
					}
					If (posX == "ERROR")
					{
						posX := ""
					}
					If (posY == "ERROR")
					{
						posY := ""
					}
					If (coord == "ERROR")
					{
						coord := ""
					}
					outputKeys[key] := outputKey
					runCommands[key] := runCommand
					workingDirs[key] := workingDir
					functions[key] := function
					args[key] := arg
					isBlinds[key] := isBlind
					isToggles[key] := isToggle
					repeatTimes[key] := repeatTime
					holdTimes[key] := holdTime
					isAdmins[key] := isAdmin
					posXs[key] := posX
					posYs[key] := posY
					coords[key] := coord
				}
				this.CreateHotkey(inputKey, windowName, processPath, isDirect, isShowToolTip, comboKey, waitTime, doublePressTime, longPressTime, outputKeys, runCommands, workingDirs, functions, args, isBlinds, isToggles, repeatTimes, holdTimes, isAdmins, posXs, posYs, coords)
			}
		}
	}

	RenameProfile(selectedProfile, newProfile)
	{
		selectedProfileName := this.profileDir "\" selectedProfile ".ini"
		newProfileName := this.profileDir "\" newProfile ".ini"
		FileMove, % selectedProfileName, % newProfileName
	}

	CopyProfile(selectedProfile, newProfile)
	{
		selectedProfileName := this.profileDir "\" selectedProfile ".ini"
		newProfileName := this.profileDir "\" newProfile ".ini"
		FileCopy, % selectedProfileName, % newProfileName
	}

	CreateProfile(profile)
	{
		profileName := this.profileDir "\" profile ".ini"
		IniWrite, 0, % profileName, Total, Num
	}

	GetProfileKeys(profile)
	{
		keys := {}
		profileName := this.profileDir "\" profile ".ini"
		IniRead, totalKeys, % profileName, Total, Num
		If (totalKeys != "ERROR")
		{
			Loop, % totalKeys
			{
				index := A_Index
				IniRead, inputKey, % profileName, % index, InputKey
				IniRead, windowName, % profileName, % index, WindowName
				IniRead, processPath, % profileName, % index, ProcessPath
				IniRead, isDirect, % profileName, % index, IsDirect
				If (inputKey == "ERROR")
				{
					Continue
				}
				comboKey := ""
				If (matchPos := InStr(inputKey, "->"))
				{
					comboKey := SubStr(inputKey, matchPos)
					inputKey := SubStr(inputKey, 1, matchPos - 1)
				}
				If (windowName == "ERROR")
				{
					windowName := ""
				}
				If (processPath == "ERROR")
				{
					processPath := ""
				}
				If (isDirect == "ERROR")
				{
					isDirect := False
				}
				key := RegExReplace(inputKey, "[\~\*\<]") windowName processPath isDirect comboKey
				keys[key] := {}
				keys[key].outputKeys := {}
				keys[key].runCommands := {}
				keys[key].workingDirs := {}
				keys[key].functions := {}
				keys[key].args := {}
				keys[key].isBlinds := {}
				keys[key].isToggles := {}
				keys[key].repeatTimes := {}
				keys[key].holdTimes := {}
				keys[key].isAdmins := {}
				keys[key].posXs := {}
				keys[key].posYs := {}
				keys[key].coords := {}
				For key2 In this.e_output
				{
					IniRead, outputKey, % profileName, % index, % "OutputKey" key2
					IniRead, runCommand, % profileName, % index, % "RunCommand" key2
					IniRead, workingDir, % profileName, % index, % "WorkingDir" key2
					IniRead, function, % profileName, % index, % "Function" key2
					IniRead, arg, % profileName, % index, % "Argument" key2
					IniRead, isBlind, % profileName, % index, % "IsBlind" key2
					IniRead, isToggle, % profileName, % index, % "IsToggle" key2
					IniRead, repeatTime, % profileName, % index, % "RepeatTime" key2
					IniRead, holdTime, % profileName, % index, % "HoldTime" key2
					IniRead, isAdmin, % profileName, % index, % "IsAdmin" key2
					IniRead, posX, % profileName, % index, % "PosX" key
					IniRead, posY, % profileName, % index, % "PosY" key
					IniRead, coord, % profileName, % index, % "CoordMode" key
					If (outputKey == "ERROR" || runCommand == "ERROR" || function == "ERROR" || (outputKey == "" && runCommand == "" && function == ""))
					{
						Continue
					}
					If (workingDir == "ERROR")
					{
						workingDir := ""
					}
					If (arg == "ERROR")
					{
						arg := ""
					}
					If (isBlind == "ERROR")
					{
						isBlind := False
					}
					If (isToggle == "ERROR")
					{
						isToggle := False
					}
					If (repeatTime == "ERROR")
					{
						repeatTime := 0
					}
					If (holdTime == "ERROR")
					{
						holdTime := 0
					}
					If (isAdmin == "ERROR")
					{
						isAdmin := False
					}
					If (posX == "ERROR")
					{
						posX := ""
					}
					If (posY == "ERROR")
					{
						posY := ""
					}
					If (coord == "ERROR")
					{
						coord := ""
					}
					keys[key].outputKeys[key2] := outputKey
					keys[key].runCommands[key2] := runCommand
					keys[key].workingDirs[key2] := workingDir
					keys[key].functions[key2] := function
					keys[key].args[key2] := arg
					keys[key].isBlinds[key2] := isBlind
					keys[key].isToggles[key2] := isToggle
					keys[key].repeatTimes[key2] := repeatTime
					keys[key].holdTimes[key2] := holdTime
					keys[key].isAdmins[key2] := isAdmin
					keys[key].posXs[key2] := posX
					keys[key].posYs[key2] := posY
					keys[key].coords[key2] := coord
				}
			}
		}
		Return keys
	}

	DeleteNotAbsoluteKeys()
	{
		keys := {}
		For key In this.hotkeys
		{
			If (this.hotkeys[key].comboKeyInstances.Count())
			{
				For combokey In this.hotkeys[key].comboKeyInstances
				{
					keys[key "->" combokey] := ""
				}
			}
			Else
			{
				keys[key] := ""
			}
		}
		For index, profile In this.absoluteProfiles
		{
			For key, value In this.GetProfileKeys(profile)
			{
				If (keys.HasKey(key))
				{
					isMatch := True
					instance := (matchPos := InStr(key, "->")) ? this.hotkeys[SubStr(key, 1, matchPos - 1)].comboKeyInstances[StrReplace(SubStr(key, matchPos), "->")] : this.hotkeys[key]
					For key2 In this.e_output
					{
						If (value.outputKeys.HasKey(key2) || value.runCommands.HasKey(key2) || value.functions.HasKey(key2))
						{
							If ((value.outputKeys[key2] != instance.outputKey[key2])
									|| (value.runCommands[key2] != instance.runCommand[key2])
								|| (value.workingDirs[key2] != instance.workingDir[key2])
								|| (value.functions[key2] != instance.function[key2])
								|| (value.args[key2] != instance.arg[key2])
								|| (value.isBlinds[key2] != instance.isBlind[key2])
								|| (value.isToggles[key2] != instance.isToggle[key2])
								|| (value.repeatTimes[key2] != instance.repeatTime[key2])
								|| (value.holdTimes[key2] != instance.holdTime[key2])
								|| (value.isAdmins[key2] != instance.isAdmin[key2])
								|| (value.posXs[key2] != instance.posX[key2])
								|| (value.posYs[key2] != instance.posY[key2])
							|| (value.coords[key2] != instance.coord[key2]))
							{
								isMatch := False
							}
						}
					}
					If (isMatch)
					{
						keys.Delete(key)
					}
				}
			}
		}
		For key In keys
		{
			this.DeleteHotkey(key)
		}
	}

	CheckLinkData(eventParams)
	{
		Critical
		Gui, DynamicHotkey:Default
		If (this.absoluteProfiles.Count())
		{
			For key, value In this.absoluteProfiles.Clone()
			{
				If (!WinExist("ahk_id" key))
				{
					this.absoluteProfiles.Delete(key)
					If (this.nowProfile == "Default")
					{
						this.DeleteNotAbsoluteKeys()
						this.LoadProfile("Default")
						this.RefreshListView()
					}
				}
			}
		}
		DetectHiddenWindows, Off
		WinGet, winId, List
		DetectHiddenWindows, On
		Loop, % winId
		{
			winHwnd := winId%A_Index%
			WinGetTitle, winTitle, % "ahk_id" winHwnd
			WinGet, winProcessPath, ProcessPath, % "ahk_id" winHwnd
			If (profile := this.SearchLinkData(winTitle, winProcessPath, "Absolute"))
			{
				If (!this.absoluteProfiles.HasKey(winHwnd))
				{
					this.absoluteProfiles[winHwnd] := profile
					this.DeleteNotAbsoluteKeys()
					this.LoadProfile(profile)
					this.RefreshListView()
				}
			}
		}
		WinGetTitle, winTitle, % "ahk_id" eventParams.hwnd
		WinGet, winProcessPath, ProcessPath, % "ahk_id" eventParams.hwnd
		If (profile := this.SearchLinkData(winTitle, winProcessPath, "Active"))
		{
			If (this.nowProfile != profile && !this.absoluteProfiles.HasKey(eventParams.hwnd))
			{
				If (!this.absoluteProfiles.Count())
				{
					this.DeleteAllHotkeys()
				}
				Else
				{
					this.DeleteNotAbsoluteKeys()
				}
				this.LoadProfile(profile)
				this.RefreshListView()
			}
			Return
		}
		Loop, % winId
		{
			winHwnd := winId%A_Index%
			WinGetTitle, winTitle, % "ahk_id" winHwnd
			WinGet, winProcessPath, ProcessPath, % "ahk_id" winHwnd
			If (profile := this.SearchLinkData(winTitle, winProcessPath, "Exist"))
			{
				If (this.absoluteProfiles.HasKey(winHwnd))
				{
					Continue
				}
				If (this.nowProfile != profile)
				{
					If (!this.absoluteProfiles.Count())
					{
						this.DeleteAllHotkeys()
					}
					Else
					{
						this.DeleteNotAbsoluteKeys()
					}
					this.LoadProfile(profile)
					this.RefreshListView()
				}
				Return
			}
		}
		If (this.nowProfile != "Default")
		{
			If (!this.absoluteProfiles.Count())
			{
				this.DeleteAllHotkeys()
			}
			Else
			{
				this.DeleteNotAbsoluteKeys()
			}
			this.LoadProfile("Default")
			this.RefreshListView()
		}
	}

	SearchLinkData(windowName, processPath, mode)
	{
		For key, value In this.linkData
		{
			data := StrSplit(value, "|")
			If (StrContains(windowName, data[2]) && StrContains(processPath, data[3]) && (mode == data[4] || (mode == "Active" && data[4] != "Absolute")))
			{
				Return data[1]
			}
		}
		Return False
	}

	SaveLinkData()
	{
		FileDelete, % this.linkDataFile
		If (!this.linkData.Length())
		{
			FileAppend,, % this.linkDataFile
		}
		For key, value In this.linkData
		{
			FileAppend, % value "`n", % this.linkDataFile
		}
	}

	LoadLinkData()
	{
		If (!FileExist(this.linkDataFile))
		{
			FileAppend,, % this.linkDataFile
		}
		Loop, Read, % this.linkDataFile
		{
			this.linkData.Push(A_LoopReadLine)
		}
	}

	GetLinkData(selectLinkNum)
	{
		profileName := ""
		windowName := ""
		processPath := ""
		mode := ""
		LV_GetText(profileName, selectLinkNum, 1)
		LV_GetText(windowName, selectLinkNum, 2)
		LV_GetText(processPath, selectLinkNum, 3)
		LV_GetText(mode, selectLinkNum, 4)
		Return profileName "|" windowName "|" processPath "|" mode
	}

	SetLinkData(profileName, windowName, processPath, mode, key := "")
	{
		If (key == "")
		{
			this.linkData.Push(profileName "|" windowName "|" processPath "|" mode)
		}
		Else
		{
			this.linkData.InsertAt(key, profileName "|" windowName "|" processPath "|" mode)
		}
	}

	DeleteLinkData(linkData)
	{
		Return (key := InArray(this.linkData, linkData)) ? this.linkData.RemoveAt(key) : False
	}

	DetectWindowInfo(guiName, hwndGui, hwndButton, hwndWindowName, hwndProcessPath, eventParams)
	{
		Critical
		WinGetTitle, activeWinTitle, % "ahk_id" eventParams.hwnd
		WinGet, activeWinProcessPath, ProcessPath, % "ahk_id" eventParams.hwnd
		this.winEventForeGround.Stop()
		this.winEventMinimizeEnd.Stop()
		this.winEventForeGround.SetFunc(this.funcCheckLinkData)
		this.winEventMinimizeEnd.SetFunc(this.funcCheckLinkData)
		GuiControl,, % hwndWindowName, % activeWinTitle
		GuiControl,, % hwndProcessPath, % activeWinProcessPath
		Gui, %guiName%:-Disabled
		GuiControl, Enable, % hwndButton
		GuiControl,, % hwndButton, % "Get window info"
		If (!this.isAlwaysOnTop)
		{
			Gui, %guiName%:-AlwaysOnTop
		}
		Sleep, 10
		WinActivate, % "ahk_id" hwndGui
	}
}
