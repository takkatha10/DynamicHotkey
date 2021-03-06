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
	static unBindFunc := ObjBindMethod(HotkeyData, "UnBind")
	e_output := ""
	inputKey := ""
	windowName := ""
	processPath := ""
	winTitle := ""
	isDirect := ""
	doublePressTime := ""
	longPressTime := ""
	outputKey := ""
	runCommand := ""
	workingDir := ""
	function := ""
	isToggle := ""
	repeatTime := ""
	holdTime := ""
	isAdmin := ""
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
	__New(inputKey, windowName, processPath, isDirect, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, isToggle, repeatTime, holdTime, isAdmin)
	{
		this.inputKey := inputKey
		this.windowName := windowName
		this.processPath := processPath
		this.winTitle := processPath != "" ? (windowName != "" ? windowName " ahk_exe " processPath : "ahk_exe " processPath) : windowName
		this.isDirect := isDirect
		this.doublePressTime := doublePressTime
		this.longPressTime := longPressTime
		this.outputKey := outputKey
		this.runCommand := runCommand
		this.workingDir := workingDir
		this.function := function
		this.isToggle := isToggle
		this.repeatTime := repeatTime
		this.holdTime := holdTime
		this.isAdmin := isAdmin
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
		If (InStr(inputKey, "&") && StrContains(inputKey, "^", "~", "*", "<", "^", "+", "!", "#"))
		{
			this.SetPrefixKey(inputKey)
			this.SetCombinationKey(inputKey)
			this.expression := ObjBindMethod(this, "GetPrefixKeyState")
		}
		this.SetWaitKey(inputKey)
	}

	; Public methods
	EnableHotkey()
	{
		func := this.func
		If (this.expression)
		{
			expression := this.expression
			Hotkey, If, % expression

			Hotkey, % this.combinationKey, % func, UseErrorLevel On

			Hotkey, If

		}
		Else If (this.winTitle != "")
		{
			If (this.isDirect)
			{
				Hotkey, IfWinExist, % this.winTitle

				Hotkey, % this.inputKey, % func, UseErrorLevel On

				Hotkey, IfWinExist

			}
			Else
			{
				Hotkey, IfWinActive, % this.winTitle

				Hotkey, % this.inputKey, % func, UseErrorLevel On

				Hotkey, IfWinActive

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
	}

	DisableHotkey()
	{
		this.StopFunc()
		If (this.expression)
		{
			expression := this.expression
			Hotkey, If, % expression

			Hotkey, % this.combinationKey, Off, UseErrorLevel

			Hotkey, If

		}
		Else If (this.winTitle != "")
		{
			If (this.isDirect)
			{
				Hotkey, IfWinExist, % this.winTitle

				Hotkey, % this.inputKey, Off, UseErrorLevel

				Hotkey, IfWinExist

			}
			Else
			{
				Hotkey, IfWinActive, % this.winTitle

				Hotkey, % this.inputKey, Off, UseErrorLevel

				Hotkey, IfWinActive

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
	}

	ToggleHotkey()
	{
		this.StopFunc()
		If (this.expression)
		{
			expression := this.expression
			Hotkey, If, % expression

			Hotkey, % this.combinationKey, Toggle, UseErrorLevel

			Hotkey, If

		}
		Else If (this.winTitle != "")
		{
			If (this.isDirect)
			{
				Hotkey, IfWinExist, % this.winTitle

				Hotkey, % this.inputKey, Toggle, UseErrorLevel

				Hotkey, IfWinExist

			}
			Else
			{
				Hotkey, IfWinActive, % this.winTitle

				Hotkey, % this.inputKey, Toggle, UseErrorLevel

				Hotkey, IfWinActive

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
		Return this.isEnabled := !this.isEnabled
	}

	UnBindHotkey()
	{
		this.StopFunc()
		unBindFunc := HotkeyData.unBindFunc
		If (this.expression)
		{
			expression := this.expression
			Hotkey, If, % expression

			Hotkey, % this.combinationKey, % unBindFunc, UseErrorLevel Off

			Hotkey, If

		}
		Else If (this.winTitle != "")
		{
			If (this.isDirect)
			{
				Hotkey, IfWinExist, % this.winTitle

				Hotkey, % this.inputKey, % unBindFunc, UseErrorLevel Off

				Hotkey, IfWinExist

			}
			Else
			{
				Hotkey, IfWinActive, % this.winTitle

				Hotkey, % this.inputKey, % unBindFunc, UseErrorLevel Off

				Hotkey, IfWinActive

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
	}

	Clear()
	{
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
		this.doublePressTime := ""
		this.longPressTime := ""
		this.outputKey := ""
		this.runCommand := ""
		this.workingDir := ""
		this.function := ""
		this.isToggle := ""
		this.repeatTime := ""
		this.holdTime := ""
		this.isAdmin := ""
		this.func := ""
		this.funcStop := ""
		this.expression := ""
		this.prefixes := ""
		this.prefixKey := ""
		this.combinationKey := ""
		this.waitKey := ""
		this.isEnabled := ""
		this.isActive := ""
	}

	; Private methods
	KeyAddOption(key, option)
	{
		matchPos := InStr(key, " & ")
		leftKey := SubStr(key, 1, matchPos - 1)
		rightKey := StrReplace(SubStr(key, matchPos), " & ")
		Return matchPos ? leftKey A_Space option " & " rightKey A_Space option : leftKey rightKey A_Space option
	}

	ToSendKey(key)
	{
		matchPos := RegExMatch(key, "[^\^\+\!\#]")
		Return SubStr(key, 1, matchPos - 1) "{" StrReplace(SubStr(key, matchPos), " & " , "}{") "}"
	}

	SetWaitKey(key)
	{
		key := RegExReplace(key, "[\~\*\<\>\^\+\!\#]")
		matchPos := InStr(key, " & ")
		this.waitKey := matchPos ? StrReplace(SubStr(key, matchPos), " & ") : key
	}

	SetPrefixKey(key)
	{
		matchPos := RegExMatch(key, "[^\~\*\<\^\+\!\#]")
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
				prefixes[A_Index] := StrReplace(prefixes[A_Index], "+", "Shift")
				prefixes[A_Index] := StrReplace(prefixes[A_Index], "!", "Alt")
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
		matchPos := RegExMatch(key, "[^\~\*\<\^\+\!\#]")
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

	ControlSendKey(key)
	{
		ControlSend,, % key, % this.winTitle
	}

	ControlSendMouse(key, options)
	{
		ControlClick,, % this.winTitle,, % key,, % options
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
		this.isActive[key].toggle := !this.isActive[key].toggle
		If (this.isActive[key].toggle)
		{
			funcDown.Call()
		}
		Else
		{
			funcUp.Call()
		}
		KeyWait, % this.waitKey
	}

	RepeatFunc(func, key)
	{
		this.isActive[key].repeat := True
		SetTimer, % func, % this.repeatTime[key] * 1000
		func.Call()
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
		If (this.isActive[key].toggle)
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
						arguments := StrReplace(SubStr(runCommand, matchPos), A_Space,,, 1)
						runCommand := SubStr(runCommand, 1, matchPos - 1)
					}
					func := ObjBindMethod(this, "RunCmd", runCommand, arguments, this.workingDir[key], this.isAdmin[key])
				}
				Else If (this.function[key] != "")
				{
					func := GetPluginFunc(this.function[key])
				}
				Else
				{
					If (this.winTitle != "" && this.isDirect)
					{
						If (StrContains(outputKey, "Button", "Wheel"))
						{
							outputKey := StrReplace(outputKey, "Button")
							func := ObjBindMethod(this, "ControlSendMouse", outputKey, "NA")
							funcDown := ObjBindMethod(this, "ControlSendMouse", outputKey, "NA D")
							funcUp := ObjBindMethod(this, "ControlSendMouse", outputKey, "NA U")
						}
						Else
						{
							func := ObjBindMethod(this, "ControlSendKey", this.ToSendKey(outputKey))
							funcDown := ObjBindMethod(this, "ControlSendKey", this.ToSendKey(outputKeyDown))
							funcUp := ObjBindMethod(this, "ControlSendKey", this.ToSendKey(outputKeyUp))
						}
					}
					Else
					{
						func := ObjBindMethod(this, "SendKey", this.ToSendKey(outputKey))
						funcDown := ObjBindMethod(this, "SendKey", this.ToSendKey(outputKeyDown))
						funcUp := ObjBindMethod(this, "SendKey", this.ToSendKey(outputKeyUp))
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
	CreateHotkey(inputKey, windowName, processPath, isDirect, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, isToggle, repeatTime, holdTime, isAdmin)
	{
		key := RegExReplace(inputKey, "[\~\*\<]") windowName processPath isDirect
		If (this.hotkeys.HasKey(key))
		{
			Return "ERROR"
		}
		this.hotkeys[key] := New HotkeyData(inputKey, windowName, processPath, isDirect, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, isToggle, repeatTime, holdTime, isAdmin)
		this.hotkeys[key].EnableHotkey()
		Return key
	}

	DeleteHotkey(key)
	{
		If (!this.hotkeys.HasKey(key))
		{
			Return False
		}
		this.hotkeys[key].Clear()
		Return this.hotkeys.Delete(key)
	}

	ToggleHotkey(key)
	{
		If (!this.hotkeys.HasKey(key))
		{
			Return "ERROR"
		}
		Return this.hotkeys[key].ToggleHotkey()
	}

	EnableAllHotkeys()
	{
		If (!this.hotkeys.Count())
		{
			Return False
		}
		For key In this.hotkeys
		{
			this.hotkeys[key].EnableHotkey()
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
			this.hotkeys[key].DisableHotkey()
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
			this.DeleteHotkey(key)
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
			If (this.hotkeys[key].isEnabled)
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
		For key, value In keys
		{
			If (this.hotkeys.HasKey(value))
			{
				this.hotkeys[value].EnableHotkey()
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
	funcCheckLinkData := ""
	linkData := []
	winEventForeGround := ""
	winEventMinimizeEnd := ""
	listViewNum := ""
	listViewKey := ""
	profiles := ""
	nowProfile := ""
	absoluteProfiles := {}
	selectLinkNum := ""
	selectLinkData := ""
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
	hIsWild := ""
	hIsPassThrough := ""
	hIsDirect := ""
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
		hIsToggle := ""
		hIsRepeat := ""
		hRepeatTime := ""
		hRepeat := ""
		hIsHold := ""
		hHoldTime := ""
		hHold := ""
		hIsAdmin := ""

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
	}

	; Constructor
	__New()
	{
		DynamicHotkey.instance := this
		this.e_output := New OutputType()
		this.LoadLinkData()
		this.funcCheckLinkData := ObjBindMethod(this, "CheckLinkData")
		this.winEventForeGround := New WinEventHook(this.funcCheckLinkData, WinEventHook.EVENT_SYSTEM_FOREGROUND)
		this.winEventMinimizeEnd := New WinEventHook(this.funcCheckLinkData, WinEventHook.EVENT_SYSTEM_MINIMIZEEND)
		If (!FileExist(A_ScriptDir "\Config"))
		{
			FileCreateDir, % A_ScriptDir "\Config"
		}
		If (!FileExist(this.profileDir))
		{
			FileCreateDir, % this.profileDir
		}
		defaultProfile := this.profileDir "\Default.ini"
		If (FileExist(defaultProfile))
		{
			this.LoadProfile("Default")
		}
		Else
		{
			IniWrite, 0, % defaultProfile, Total, Num
		}
		IniRead, isOpen, % this.configFile, DynamicHotkey, IsOpenAtLaunch
		IniRead, isTop, % this.configFile, DynamicHotkey, IsAlwaysOnTop
		IniRead, isSwitch, % this.configFile, DynamicHotkey, IsAutoSwitch
		IniRead, capsLockType, % this.configFile, DynamicHotkey, CapsLockState
		IniRead, numLockType, % this.configFile, DynamicHotkey, NumLockState
		IniRead, scrollLockType, % this.configFile, DynamicHotkey, ScrollLockState
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
		this.plugins := GetPluginFuncNames(GetPluginNames(this.pluginFile))
		this.GuiCreate()
		this.CreateMenu()
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Start()
			this.winEventMinimizeEnd.Start()
		}
		If (this.isOpenAtLaunch)
		{
			this.GuiOpen()
		}
	}

	; Static method
	Quit()
	{
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
		Gui, DynamicHotkey:Show
	}

	; Gui methods
	GuiCreate()
	{
		If (WinExist("DynamicHotkey ahk_class AutoHotkeyGUI"))
		{
			Return
		}
		Gui, DynamicHotkey:New, +LabelDynamicHotkey.Gui, DynamicHotkey
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
		Gui, DynamicHotkey:Add, CheckBox, x+160 y+40 HwndhIsOpen GDynamicHotkey.GuiChangeIsOpen, Open a window at launch
		this.hIsOpen := hIsOpen
		Gui, DynamicHotkey:Add, CheckBox, xp+0 yp+30 HwndhIsTop GDynamicHotkey.GuiChangeIsTop, Keep a window always on top
		this.hIsTop := hIsTop
		Gui, DynamicHotkey:Add, CheckBox, xp+0 yp+30 HwndhIsSwitch GDynamicHotkey.GuiChangeIsSwitch, Auto switching profiles
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
		this.profiles := []
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
		this.IsOpen := this.isOpenAtLaunch
		this.IsTop := this.isAlwaysOnTop
		this.IsSwitch := this.isAutoSwitch
		Gui, DynamicHotkey:Show, Hide
	}

	CreateMenu()
	{
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

	GuiDelete()
	{
		this.listViewNum := ""
		this.listViewKey := ""
		this.profiles := ""
		this.hTab := ""
		this.hListView := ""
		this.hSelectedProfile := ""
		this.hIsOpen := ""
		this.hIsTop := ""
		this.hIsSwitch := ""
		this.hCapsLockState := ""
		this.hNumLockState := ""
		this.hScrollLockState := ""
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
		Gui, NewHotkey:Add, Button, xs+0 y+6 w358 HwndhWindowInfo GDynamicHotkey.NewHotkeyGuiWindowInfo, Get window info
		this.hWindowInfo := hWindowInfo
		Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h230
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+91 HwndhIsWild, Wild card
		this.hIsWild := hIsWild
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsPassThrough, Pass through
		this.hIsPassThrough := hIsPassThrough
		Gui, NewHotkey:Add, CheckBox, y+6 HwndhIsDirect GDynamicHotkey.NewHotkeyGuiChangeIsDirect Disabled, Direct send
		this.hIsDirect := hIsDirect
		key := this.e_output[1]
		Gui, NewHotkey:Add, GroupBox, xm+0 y+97 w376 h132, Output
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
		Gui, NewHotkey:Add, DropDownList, xs+0 yp+0 w358 HwndhFunctionSingle Hidden Disabled
		this.hOutputs[key].hFunction := hFunctionSingle
		Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputSingle GDynamicHotkey.NewHotkeyGuiBindOutputSingle Disabled, Bind
		this.hOutputs[key].hBindOutput := hBindOutputSingle
		Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputSingle2nd GDynamicHotkey.NewHotkeyGuiBindOutputSingle2nd Disabled, Bind
		this.hOutputs[key].hBindOutput2nd := hBindOutputSingle2nd
		Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectorySingle Hidden Disabled, Working directory
		this.hOutputs[key].hDirectory := hDirectorySingle
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirSingle Hidden Center Disabled
		this.hOutputs[key].hWorkingDir := hWorkingDirSingle
		Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsToggleSingle Section Disabled, Toggle
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
		Gui, NewHotkey:Add, CheckBox, xs+0 yp-40 HwndhIsAdminSingle Hidden Disabled, Run as admin
		this.hOutputs[key].hIsAdmin := hIsAdminSingle
		key := this.e_output[2]
		Gui, NewHotkey:Add, GroupBox, xm+0 y+50 w376 h132
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
		Gui, NewHotkey:Add, DropDownList, xs+0 yp+0 w358 HwndhFunctionDouble Hidden Disabled
		this.hOutputs[key].hFunction := hFunctionDouble
		Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputDouble GDynamicHotkey.NewHotkeyGuiBindOutputDouble Disabled, Bind
		this.hOutputs[key].hBindOutput := hBindOutputDouble
		Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputDouble2nd GDynamicHotkey.NewHotkeyGuiBindOutputDouble2nd Disabled, Bind
		this.hOutputs[key].hBindOutput2nd := hBindOutputDouble2nd
		Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectoryDouble Hidden Disabled, Working directory
		this.hOutputs[key].hDirectory := hDirectoryDouble
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirDouble Hidden Center Disabled
		this.hOutputs[key].hWorkingDir := hWorkingDirDouble
		Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsToggleDouble Section Disabled, Toggle
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
		Gui, NewHotkey:Add, CheckBox, xs+0 yp-40 HwndhIsAdminDouble Hidden Disabled, Run as admin
		this.hOutputs[key].hIsAdmin := hIsAdminDouble
		key := this.e_output[3]
		Gui, NewHotkey:Add, GroupBox, xm+0 y+50 w376 h132
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
		Gui, NewHotkey:Add, DropDownList, xs+0 yp+0 w358 HwndhFunctionLong Hidden Disabled
		this.hOutputs[key].hFunction := hFunctionLong
		Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputLong GDynamicHotkey.NewHotkeyGuiBindOutputLong Disabled, Bind
		this.hOutputs[key].hBindOutput := hBindOutputLong
		Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputLong2nd GDynamicHotkey.NewHotkeyGuiBindOutputLong2nd Disabled, Bind
		this.hOutputs[key].hBindOutput2nd := hBindOutputLong2nd
		Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectoryLong Hidden Disabled, Working directory
		this.hOutputs[key].hDirectory := hDirectoryLong
		Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirLong Hidden Center Disabled
		this.hOutputs[key].hWorkingDir := hWorkingDirLong
		Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
		Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsToggleLong Section Disabled, Toggle
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
		Gui, NewHotkey:Add, CheckBox, xs+0 yp-40 HwndhIsAdminLong Hidden Disabled, Run as admin
		this.hOutputs[key].hIsAdmin := hIsAdminLong
		If (listViewKey != "" && isEdit)
		{
			Gui, NewHotkey:Add, Button, xm+8 w237 GDynamicHotkey.NewHotkeyGuiButtonOKEdit, OK
		}
		Else
		{
			Gui, NewHotkey:Add, Button, xm+8 w237 GDynamicHotkey.NewHotkeyGuiButtonOKNew, OK
		}
		Gui, NewHotkey:Add, Button, x+4 w237 GDynamicHotkey.NewHotkeyGuiClose, Cancel
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
			inputKey := this.GetFirstKey(this.hotkeys[listViewKey].inputKey)
			inputKey2nd := this.GetSecondKey(this.hotkeys[listViewKey].inputKey)
			this.InputKey := this.ToDisplayKey(inputKey)
			this.InputKey2nd := this.ToDisplayKey(inputKey2nd)
			this.WindowName := this.hotkeys[listViewKey].windowName
			this.ProcessPath := this.hotkeys[listViewKey].processPath
			this.IsWild := InStr(inputKey, "*") ? True : False
			this.IsPassThrough := InStr(inputKey, "~") ? True : False
			this.IsDirect := this.hotkeys[listViewKey].isDirect ? True : False
			doublePressTime := this.hotkeys[listViewKey].doublePressTime
			doublePressTime := InStr(doublePressTime, ".") ? Format("{:0.1f}", doublePressTime) : Format("{:d}", doublePressTime)
			this.DoublePress := doublePressTime ? doublePressTime : 0.2
			longPressTime := this.hotkeys[listViewKey].longPressTime
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
			For key In this.e_output
			{
				outputKey := this.GetFirstKey(this.hotkeys[listViewKey].outputKey[key])
				outputKey2nd := this.GetSecondKey(this.hotkeys[listViewKey].outputKey[key])
				If (outputKey != "" || this.hotkeys[listViewKey].runCommand[key] != "" || this.hotkeys[listViewKey].function[key] != "")
				{
					this.hOutputs[key].IsOutputType := True
					this.hOutputs[key].OutputKey := this.ToDisplayKeyAlt(this.ToDisplayKey(outputKey))
					this.hOutputs[key].OutputKey2nd := this.ToDisplayKey(outputKey2nd)
					this.hOutputs[key].RadioKey := (outputKey != "")
					this.hOutputs[key].RadioCmd := (this.hotkeys[listViewKey].runCommand[key] != "")
					this.hOutputs[key].RadioFunc := (this.hotkeys[listViewKey].function[key] != "")
					this.hOutputs[key].RunCommand := this.hotkeys[listViewKey].runCommand[key]
					this.hOutputs[key].WorkingDir := this.hotkeys[listViewKey].workingDir[key]
					If (function := InArray(this.plugins, this.hotkeys[listViewKey].function[key]))
					{
						GuiControl, NewHotkey:Choose, % this.hOutputs[key].hFunction, % function
					}
					this.hOutputs[key].IsToggle := this.hotkeys[listViewKey].isToggle[key] ? True : False
					this.hOutputs[key].IsRepeat := this.hotkeys[listViewKey].repeatTime[key] ? True : False
					this.hOutputs[key].RepeatTime := this.hotkeys[listViewKey].repeatTime[key]
					this.hOutputs[key].IsHold := this.hotkeys[listViewKey].holdTime[key] ? True : False
					this.hOutputs[key].HoldTime := this.hotkeys[listViewKey].holdTime[key]
					this.hOutputs[key].IsAdmin := this.hotkeys[listViewKey].isAdmin[key] ? True : False
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
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRadioFunc
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
					GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
					this.hOutputs[key].RadioKey := True
					this.hOutputs[key].OutputKey2nd := ""
					this.hOutputs[key].BindOutput2nd := "Bind"
				}
				Else
				{
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioCmd
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioFunc
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey2nd
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput2nd
				}
				this.ChangeOutput(key)
			}
		}
	}

	CheckToggleKey()
	{
		If (StrContains(this.ToInputKey(this.InputKey), "sc029", "sc03A", "sc070") || StrContains(this.ToInputKey(this.InputKey2nd), "sc029", "sc03A", "sc070"))
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
			If (!this.IsDirect)
			{
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioCmd
				GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioFunc
			}
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hWorkingDir
			If (key == "Single")
			{
				If (!StrContains(this.ToInputKey(this.InputKey), "sc029", "sc03A", "sc070") && !StrContains(this.ToInputKey(this.InputKey2nd), "sc029", "sc03A", "sc070"))
				{
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsToggle
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsRepeat
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsHold
				}
			}
			Else
			{
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
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hFunction
			this.hOutputs[key].RadioKey := True
			this.hOutputs[key].RadioCmd := False
			this.hOutputs[key].RadioFunc := False
			this.hOutputs[key].OutputKey := ""
			this.hOutputs[key].OutputKey2nd := ""
			this.hOutputs[key].RunCommand := ""
			this.hOutputs[key].WorkingDir := ""
			this.hOutputs[key].IsAdmin := False
			this.hOutputs[key].IsToggle := False
			this.hOutputs[key].IsRepeat := False
			this.hOutputs[key].RepeatTime := 0
			this.hOutputs[key].IsHold := False
			this.hOutputs[key].HoldTime := 0
		}
	}

	ChangeOutput(key)
	{
		If (this.hOutputs[key].RadioKey)
		{
			If (key == "Single")
			{
				If (!StrContains(this.ToInputKey(this.InputKey), "sc029", "sc03A", "sc070") && !StrContains(this.ToInputKey(this.InputKey2nd), "sc029", "sc03A", "sc070"))
				{
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsToggle
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsRepeat
					GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsHold
				}
			}
			Else
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
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hFunction
			this.hOutputs[key].RunCommand := ""
			this.hOutputs[key].WorkingDir := ""
			this.hOutputs[key].IsAdmin := False
		}
		Else If (this.hOutputs[key].RadioCmd)
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hFunction
			this.hOutputs[key].OutputKey := ""
			this.hOutputs[key].OutputKey2nd := ""
			this.hOutputs[key].BindOutput2nd := "Bind"
			this.hOutputs[key].IsToggle := False
			this.hOutputs[key].IsRepeat := False
			this.hOutputs[key].RepeatTime := 0
			this.hOutputs[key].IsHold := False
			this.hOutputs[key].HoldTime := 0
		}
		Else
		{
			GuiControl, NewHotkey:Enable, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
			GuiControl, NewHotkey:Disable, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Show, % this.hOutputs[key].hFunction
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRunCommand
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hDirectory
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hWorkingDir
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsAdmin
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hOutputKey2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hBindOutput2nd
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsToggle
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeatTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hRepeat
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hIsHold
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHoldTime
			GuiControl, NewHotkey:Hide, % this.hOutputs[key].hHold
			this.hOutputs[key].OutputKey := ""
			this.hOutputs[key].OutputKey2nd := ""
			this.hOutputs[key].BindOutput2nd := "Bind"
			this.hOutputs[key].IsToggle := False
			this.hOutputs[key].IsRepeat := False
			this.hOutputs[key].RepeatTime := 0
			this.hOutputs[key].IsHold := False
			this.hOutputs[key].HoldTime := 0
			this.hOutputs[key].RunCommand := ""
			this.hOutputs[key].WorkingDir := ""
			this.hOutputs[key].IsAdmin := False
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
		isWild := this.IsWild
		isPassThrough := this.IsPassThrough
		isDirect := this.IsDirect
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
		isToggle := {}
		repeatTime := {}
		holdTime := {}
		isLong := {}
		isAdmin := {}
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
				isToggle[key] := this.hOutputs[key].IsToggle
				repeatTime[key] := this.hOutputs[key].RepeatTime
				holdTime[key] := this.hOutputs[key].HoldTime
				isLong[key] := this.hOutputs[key].IsLong
				isAdmin[key] := this.hOutputs[key].IsAdmin
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
		If (StrIn(RegExReplace(inputKey, "[\^\+\!\#]"), inputKey2nd) && inputKey2nd != "")
		{
			DisplayToolTip("Input key is duplicated")
			Return
		}
		If (inputKey2nd != "")
		{
			inputKey .= " & " inputKey2nd
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
				}
				Else If (radioCmd[key] && runCommand[key] == "")
				{
					DisplayToolTip("No run command entered")
					Return
				}
				Else If (radioFunc[key] && !InArray(this.plugins, function[key]))
				{
					DisplayToolTip("Function is invalid")
					Return
				}
				outputKey[key] := this.ToInputKey(outputKey[key])
				outputKey2nd[key] := this.ToInputKey(outputKey2nd[key])
				If (isDirect && StrContains(outputKey[key], "Button", "Wheel") && RegExMatch(outputKey[key], "[\^\+\!\#]"))
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
			}
		}
		If (StrIn(outputKey["Single"], "!Tab", "+!Tab"))
		{
			prefixLength := StrLen(RegExReplace(inputKey, "[^\^\+\!\#]"))
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
			If (!this.hotkeys.HasKey(key) || key == this.listViewKey)
			{
				this.GuiListButtonDelete(,,, True)
			}
		}
		key := this.CreateHotkey(inputKey, windowName, processPath, isDirect, doublePressTime, longPressTime, outputKey, runCommand, workingDir, function, isToggle, repeatTime, holdTime, isAdmin)
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
		this.hIsWild := ""
		this.hIsPassThrough := ""
		this.hIsDirect := ""
		this.hDoublePress := ""
		this.hSecondDouble := ""
		this.hLongPress := ""
		this.hSecondLong := ""
		this.hSecret := ""
		For key In this.e_output
		{
			this.hOutputs[key].hRadioKey := ""
			this.hOutputs[key].hRadioCmd := ""
			this.hOutputs[key].hRadioFunc := ""
			this.hOutputs[key].hOutputKey := ""
			this.hOutputs[key].hBindOutput := ""
			this.hOutputs[key].hOutputKey2nd := ""
			this.hOutputs[key].hBindOutput2nd := ""
			this.hOutputs[key].hRunCommand := ""
			this.hOutputs[key].hDirectory := ""
			this.hOutputs[key].hWorkingDir := ""
			this.hOutputs[key].hFunction := ""
			this.hOutputs[key].hIsToggle := ""
			this.hOutputs[key].hIsRepeat := ""
			this.hOutputs[key].hRepeatTime := ""
			this.hOutputs[key].hRepeat := ""
			this.hOutputs[key].hIsHold := ""
			this.hOutputs[key].hHoldTime := ""
			this.hOutputs[key].hHold := ""
			this.hOutputs[key].hIsAdmin := ""
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

	GuiContextMenu()
	{
		this := DynamicHotkey.instance
		If (A_GuiControlEvent == "RightClick")
		{
			MouseGetPos,,,, mHwnd, 2
			If (mHwnd == this.hListView)
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
			Else If (mHwnd == this.hSelectedProfile)
			{
				MouseClick
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
		newProfile := this.NewProfile
		If (newProfile == "")
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
			selectedProfile := this.SelectedProfile
			this.RenameProfile(selectedProfile, newProfile)
			ArrayReplace(this.profiles, selectedProfile, newProfile)
		}
		Else
		{
			If (isCopy)
			{
				this.DeleteAllHotkeys()
				this.LoadProfile(this.SelectedProfile)
				this.RefreshListView()
			}
			this.SaveProfile(newProfile)
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
		selectedProfile := this.SelectedProfile
		If (selectedProfile == "Default")
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
		selectedProfile := this.SelectedProfile
		If (selectedProfile != "")
		{
			this.GuiProfileButtonCreate(,,, selectedProfile, False)
		}
	}

	GuiProfileButtonDelete()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		selectedProfile := this.SelectedProfile
		If (selectedProfile == "Default")
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
		selectedProfile := this.SelectedProfile
		If (selectedProfile != "")
		{
			this.SaveProfile(selectedProfile)
			DisplayToolTip("Profile saved")
		}
	}

	GuiProfileButtonLoad()
	{
		Gui, DynamicHotkey:Default
		this := DynamicHotkey.instance
		selectedProfile := this.SelectedProfile
		If (selectedProfile != "")
		{
			this.DeleteAllHotkeys()
			this.LoadProfile(selectedProfile)
			this.RefreshListView()
			DisplayToolTip("Profile loaded")
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

	LinkProfileGuiContextMenu()
	{
		this := DynamicHotkey.instance
		If (A_GuiControlEvent == "RightClick")
		{
			MouseGetPos,,,, mHwnd, 2
			If (mHwnd == this.hLinkListView)
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
		Gui, NewLinkData:Add, Button, xs+0 y+8 w400 HwndhNewLinkWindowInfo GDynamicHotkey.NewLinkDataGuiWindowInfo, Get window info
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

	GuiChangeIsOpen()
	{
		this := DynamicHotkey.instance
		this.isOpenAtLaunch := this.IsOpen
		IniWrite, % this.isOpenAtLaunch, % this.configFile, DynamicHotkey, IsOpenAtLaunch
	}

	GuiChangeIsTop()
	{
		this := DynamicHotkey.instance
		this.isAlwaysOnTop := this.IsTop
		If (this.isAlwaysOnTop)
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
		this.isAutoSwitch := this.IsSwitch
		If (this.isAutoSwitch)
		{
			this.winEventForeGround.Start()
			this.winEventMinimizeEnd.Start()
		}
		Else
		{
			this.winEventForeGround.Stop()
			this.winEventMinimizeEnd.Stop()
		}
		IniWrite, % this.isAutoSwitch, % this.configFile, DynamicHotkey, IsAutoSwitch
	}

	GuiChangeCapsLock()
	{
		this := DynamicHotkey.instance
		this.capsLockType := this.CapsLockState
		Switch this.capsLockType
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
		this.numLockType := this.NumLockState
		Switch this.numLockType
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
		this.scrollLockType := this.ScrollLockState
		Switch this.scrollLockType
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
		matchPos := InStr(replacedKey, search)
		If (matchPos)
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
		matchPos := RegExMatch(inputKey, "[^\~\*\<\^\+\!\#]")
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
		replacedKey := StrReplace(replacedKey, "Shift + ", "+")
		replacedKey := StrReplace(replacedKey, "Alt + ", "!")
		replacedKey := StrReplace(replacedKey, "Win + ", "#")
		matchPos := RegExMatch(replacedKey, "[^\^\+\!\#]")
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
		matchPos := InStr(key, " & ")
		Return matchPos ? SubStr(key, 1, matchPos - 1) : key
	}

	GetSecondKey(key)
	{
		matchPos := InStr(key, " & ")
		Return matchPos ? StrReplace(SubStr(key, matchPos), " & ") : ""
	}

	KeyWaitCombo(options := "")
	{
		ih := InputHook(options)
		If (!InStr(options, "V"))
		{
			ih.VisibleNonText := false
		}
		ih.KeyOpt("{All}", "E")
		ih.KeyOpt("{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{sc178}{vkFF}", "-E")
		ih.Start()
		ih.Wait()
		Return ih.EndKey
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
		this.wheelState := RegExReplace(A_ThisHotkey, "[\~\*\<\>\^\+\!\#]")
	}

	DoNothing()
	{
		Return
	}

	KeyBind(hwndEdit, hwndButton, isEnablePrefix := True)
	{
		key := ""
		getWheelStateFunc := ObjBindMethod(this, "GetWheelState")
		doNothingFunc := DynamicHotkey.doNothingFunc
		GuiControl, Focus, % hwndEdit
		GuiControl,, % hwndButton, Press any key
		GuiControl, Disable, % hwndButton
		Hotkey, *WheelDown, % getWheelStateFunc, UseErrorLevel On
		Hotkey, *WheelUp, % getWheelStateFunc, UseErrorLevel On
		Hotkey, *WheelLeft, % getWheelStateFunc, UseErrorLevel On
		Hotkey, *WheelRight, % getWheelStateFunc, UseErrorLevel On
		Loop
		{
			If (key == "")
			{
				key := this.KeyWaitCombo("T0.1")
			}
			If (key == "")
			{
				key := this.GetKeyListState(,, "LButton", "RButton", "MButton", "XButton1", "XButton2")
			}
			If (key == "" && this.wheelState)
			{
				key := this.wheelState
			}
			If (key != "")
			{
				If (isEnablePrefix)
				{
					prefix := this.GetKeyListState(True, "P", "Ctrl", "Shift", "Alt", "Win")
					key := prefix ? prefix " + " key : key
					key := this.ToInputKey(key)
				}
				Break
			}
		}
		Hotkey, *WheelDown, % doNothingFunc, UseErrorLevel Off
		Hotkey, *WheelUp, % doNothingFunc, UseErrorLevel Off
		Hotkey, *WheelLeft, % doNothingFunc, UseErrorLevel Off
		Hotkey, *WheelRight, % doNothingFunc, UseErrorLevel Off
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
		inputKey := this.ToDisplayKey(this.hotkeys[key].inputKey)
		isEnabled := this.hotkeys[key].isEnabled ? "✓" : "✗"
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
		For key2 In this.e_output
		{
			If (this.hotkeys[key].outputKey.HasKey(key2))
			{
				outputs[key2] := this.ToDisplayKey(this.hotkeys[key].outputKey[key2]) this.hotkeys[key].runCommand[key2] this.hotkeys[key].function[key2]
				If (key2 == "Double")
				{
					outputs[key2] .= ", Interval:" (InStr(this.hotkeys[key].doublePressTime, ".") ? Format("{:0.1f}", this.hotkeys[key].doublePressTime) : Format("{:d}", this.hotkeys[key].doublePressTime))
				}
				Else If (key2 == "Long")
				{
					outputs[key2] .= ", Interval:" (InStr(this.hotkeys[key].longPressTime, ".") ? Format("{:0.1f}", this.hotkeys[key].longPressTime) : Format("{:d}", this.hotkeys[key].longPressTime))
				}
				If (this.hotkeys[key].workingDir[key2])
				{
					outputs[key2] .= ", Working directory:" this.hotkeys[key].workingDir[key2]
				}
				If (this.hotkeys[key].isToggle[key2])
				{
					outputs[key2] .= ", Toggle"
				}
				If (this.hotkeys[key].repeatTime[key2])
				{
					outputs[key2] .= ", Repeat:" this.hotkeys[key].repeatTime[key2]
				}
				If (this.hotkeys[key].holdTime[key2])
				{
					outputs[key2] .= ", Hold:" this.hotkeys[key].holdTime[key2]
				}
				If (this.hotkeys[key].isAdmin[key2])
				{
					outputs[key2] .= ", Run as admin"
				}
			}
			Else
			{
				outputs[key2] := ""
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
			this.ListViewAdd(key)
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
		LV_GetText(inputKey, listViewNum, 2)
		LV_GetText(windowName, listViewNum, 3)
		LV_GetText(processPath, listViewNum, 4)
		LV_GetText(options, listViewNum, 5)
		isDirect := InStr(options, "Direct send") ? True : False
		Return this.ToInputKey(inputKey) windowName processPath isDirect
	}

	SaveProfile(profile)
	{
		this.nowProfile := profile
		profileName := this.profileDir "\" profile ".ini"
		FileDelete, % profileName
		IniWrite, % this.hotkeys.Count(), % profileName, Total, Num
		For key In this.hotkeys
		{
			index := A_Index
			IniWrite, % this.hotkeys[key].inputKey, % profileName, % index, InputKey
			IniWrite, % this.hotkeys[key].windowName, % profileName, % index, WindowName
			IniWrite, % this.hotkeys[key].processPath, % profileName, % index, ProcessPath
			IniWrite, % this.hotkeys[key].isDirect, % profileName, % index, IsDirect
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
				IniWrite, % this.hotkeys[key].isToggle[key2], % profileName, % index, % "IsToggle" key2
				IniWrite, % this.hotkeys[key].repeatTime[key2], % profileName, % index, % "RepeatTime" key2
				IniWrite, % this.hotkeys[key].holdTime[key2], % profileName, % index, % "HoldTime" key2
				IniWrite, % this.hotkeys[key].isAdmin[key2], % profileName, % index, % "IsAdmin" key2
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
				isToggles := {}
				repeatTimes := {}
				holdTimes := {}
				isAdmins := {}
				IniRead, inputKey, % profileName, % index, InputKey
				IniRead, windowName, % profileName, % index, WindowName
				IniRead, processPath, % profileName, % index, ProcessPath
				IniRead, isDirect, % profileName, % index, IsDirect
				IniRead, doublePressTime, % profileName, % index, DoublePressTime
				IniRead, longPressTime, % profileName, % index, LongPressTime
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
					IniRead, isToggle, % profileName, % index, % "IsToggle" key
					IniRead, repeatTime, % profileName, % index, % "RepeatTime" key
					IniRead, holdTime, % profileName, % index, % "HoldTime" key
					IniRead, isAdmin, % profileName, % index, % "IsAdmin" key
					If (outputKey == "ERROR" || runCommand == "ERROR" || function == "ERROR" || (outputKey == "" && runCommand == "" && function == ""))
					{
						Continue
					}
					outputKeys[key] := outputKey
					runCommands[key] := runCommand
					workingDirs[key] := workingDir
					functions[key] := function
					isToggles[key] := isToggle
					repeatTimes[key] := repeatTime
					holdTimes[key] := holdTime
					isAdmins[key] := isAdmin
				}
				this.CreateHotkey(inputKey, windowName, processPath, isDirect, doublePressTime, longPressTime, outputKeys, runCommands, workingDirs, functions, isToggles, repeatTimes, holdTimes, isAdmins)
			}
		}
	}

	RenameProfile(selectedProfile, newProfile)
	{
		selectedProfileName := this.profileDir "\" selectedProfile ".ini"
		newProfileName := this.profileDir "\" newProfile ".ini"
		FileMove, % selectedProfileName, % newProfileName
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
				key := RegExReplace(inputKey, "[\~\*\<]") windowName processPath isDirect
				keys[key] := {}
				keys[key].outputKeys := {}
				keys[key].runCommands := {}
				keys[key].workingDirs := {}
				keys[key].functions := {}
				keys[key].isToggles := {}
				keys[key].repeatTimes := {}
				keys[key].holdTimes := {}
				keys[key].isAdmins := {}
				For key2 In this.e_output
				{
					IniRead, outputKey, % profileName, % index, % "OutputKey" key2
					IniRead, runCommand, % profileName, % index, % "RunCommand" key2
					IniRead, workingDir, % profileName, % index, % "WorkingDir" key2
					IniRead, function, % profileName, % index, % "Function" key2
					IniRead, isToggle, % profileName, % index, % "IsToggle" key2
					IniRead, repeatTime, % profileName, % index, % "RepeatTime" key2
					IniRead, holdTime, % profileName, % index, % "HoldTime" key2
					IniRead, isAdmin, % profileName, % index, % "IsAdmin" key2
					If (outputKey == "ERROR" || runCommand == "ERROR" || function == "ERROR" || (outputKey == "" && runCommand == "" && function == ""))
					{
						Continue
					}
					keys[key].outputKeys[key2] := outputKey
					keys[key].runCommands[key2] := runCommand
					keys[key].workingDirs[key2] := workingDir
					keys[key].functions[key2] := function
					keys[key].isToggles[key2] := isToggle
					keys[key].repeatTimes[key2] := repeatTime
					keys[key].holdTimes[key2] := holdTime
					keys[key].isAdmins[key2] := isAdmin
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
			keys[key] := ""
		}
		For index, profile In this.absoluteProfiles
		{
			For key, value In this.GetProfileKeys(profile)
			{
				If (keys.HasKey(key))
				{
					isMatch := True
					For key2 In this.e_output
					{
						If (value.outputKeys.HasKey(key2) || value.runCommands.HasKey(key2))
						{
							If ((value.outputKeys[key2] != this.hotkeys[key].outputKey[key2])
									|| (value.runCommands[key2] != this.hotkeys[key].runCommand[key2])
								|| (value.workingDirs[key2] != this.hotkeys[key].workingDir[key2])
								|| (value.function[key2] != this.hotkeys[key].function[key2])
								|| (value.isToggles[key2] != this.hotkeys[key].isToggle[key2])
								|| (value.repeatTimes[key2] != this.hotkeys[key].repeatTime[key2])
								|| (value.holdTimes[key2] != this.hotkeys[key].holdTime[key2])
							|| (value.isAdmins[key2] != this.hotkeys[key].isAdmin[key2]))
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
		key := InArray(this.linkData, linkData)
		Return key ? this.linkData.RemoveAt(key) : False
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
