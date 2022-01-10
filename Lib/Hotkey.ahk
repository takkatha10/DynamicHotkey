/*
	Hotkey
	# Include in the auto-execute section
	# Required files
	# Tip.ahk
	# Utility.ahk
	# Math.ahk
	# Array.ahk
	# String.ahk
	# Gui.ahk
	# Enum.ahk
	# WinEventHook.ahk
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
    static doublePressTime := 0.2
    static longPressTime := 0.3
    e_output := ""
    inputKey := ""
    windowName := ""
    processPath := ""
    winTitle := ""
    isDirect := ""
    outputKey := ""
    runCommand := ""
    workingDir := ""
    isToggle := ""
    repeatTime := ""
    holdTime := ""
    isAdmin := ""
    func := ""
    funcs := {}
    expression := ""
    prefixes := ""
    prefixKey := ""
    combinationKey := ""
    isEnabled := False
    isActive := {}

    ; Constructor
    __New(inputKey, windowName, processPath, isDirect, outputKey, runCommand, workingDir, isToggle, repeatTime, holdTime, isAdmin)
    {
        this.inputKey := inputKey
        this.windowName := windowName
        this.processPath := processPath
        this.winTitle := processPath != "" ? (windowName != "" ? windowName " ahk_exe " processPath : "ahk_exe " processPath) : windowName
        this.isDirect := isDirect
        this.outputKey := outputKey
        this.runCommand := runCommand
        this.workingDir := workingDir
        this.isToggle := isToggle
        this.repeatTime := repeatTime
        this.holdTime := holdTime
        this.isAdmin := isAdmin
        this.e_output := New OutputType()
        For key In this.e_output
        {
            If (this.outputKey.HasKey(key))
            {
                this.isActive[key] := False
            }
            Else
            {
                this.e_output.Delete(key)
            }
        }
        this.DetermineFunc()
        this.DetermineCombinationKey()
    }

    ; Public methods
    EnableHotkey()
    {
        func := this.func
        If (this.expression)
        {
            expression := this.expression
            Hotkey, If, % expression

            Hotkey, % this.combinationKey, % func, On

            Hotkey, If

        }
        Else If (this.winTitle != "")
        {
            If (this.isDirect)
            {
                Hotkey, IfWinExist, % this.winTitle

                Hotkey, % this.inputKey, % func, On

                Hotkey, IfWinExist

            }
            Else
            {
                Hotkey, IfWinActive, % this.winTitle

                Hotkey, % this.inputKey, % func, On

                Hotkey, IfWinActive

            }
        }
        Else
        {
            Hotkey, % this.inputKey, % func, On
            If (InStr(this.inputKey, "<"))
            {
                Hotkey, % StrReplace(this.inputKey, "<" , ">"), % func, On
            }
        }
        this.isEnabled := True
    }

    DisableHotkey()
    {
        For key In this.e_output
        {
            If (this.isActive[key])
            {
                this.funcs[key].Call()
            }
        }
        If (this.expression)
        {
            expression := this.expression
            Hotkey, If, % expression

            Hotkey, % this.combinationKey, Off

            Hotkey, If

        }
        Else If (this.winTitle != "")
        {
            If (this.isDirect)
            {
                Hotkey, IfWinExist, % this.winTitle

                Hotkey, % this.inputKey, Off

                Hotkey, IfWinExist

            }
            Else
            {
                Hotkey, IfWinActive, % this.winTitle

                Hotkey, % this.inputKey, Off

                Hotkey, IfWinActive

            }
        }
        Else
        {
            Hotkey, % this.inputKey, Off
            If (InStr(this.inputKey, "<"))
            {
                Hotkey, % StrReplace(this.inputKey, "<" , ">"), Off
            }
        }
        this.isEnabled := False
    }

    ToggleHotkey()
    {
        For key In this.e_output
        {
            If (this.isActive[key])
            {
                this.funcs[key].Call()
            }
        }
        If (this.expression)
        {
            expression := this.expression
            Hotkey, If, % expression

            Hotkey, % this.combinationKey, Toggle

            Hotkey, If

        }
        Else If (this.winTitle != "")
        {
            If (this.isDirect)
            {
                Hotkey, IfWinExist, % this.winTitle

                Hotkey, % this.inputKey, Toggle

                Hotkey, IfWinExist

            }
            Else
            {
                Hotkey, IfWinActive, % this.winTitle

                Hotkey, % this.inputKey, Toggle

                Hotkey, IfWinActive

            }
        }
        Else
        {
            Hotkey, % this.inputKey, Toggle
            If (InStr(this.inputKey, "<"))
            {
                Hotkey, % StrReplace(this.inputKey, "<" , ">"), Toggle
            }
        }
        Return this.isEnabled := !this.isEnabled
    }

    UnBindHotkey()
    {
        For key In this.e_output
        {
            If (this.isActive[key])
            {
                this.funcs[key].Call()
            }
        }
        unBindFunc := HotkeyData.unBindFunc
        If (this.expression)
        {
            expression := this.expression
            Hotkey, If, % expression

            Hotkey, % this.combinationKey, % unBindFunc, Off

            Hotkey, If

        }
        Else If (this.winTitle != "")
        {
            If (this.isDirect)
            {
                Hotkey, IfWinExist, % this.winTitle

                Hotkey, % this.inputKey, % unBindFunc, Off

                Hotkey, IfWinExist

            }
            Else
            {
                Hotkey, IfWinActive, % this.winTitle

                Hotkey, % this.inputKey, % unBindFunc, Off

                Hotkey, IfWinActive

            }
        }
        Else
        {
            Hotkey, % this.inputKey, % unBindFunc, Off
            If (InStr(this.inputKey, "<"))
            {
                Hotkey, % StrReplace(this.inputKey, "<" , ">"), % unBindFunc, Off
            }
        }
        this.isEnabled := False
    }

    Clear()
    {
        this.UnBindHotkey()
        For key In this.e_output
        {
            this.funcs.Delete(key)
            this.isActive.Delete(key)
        }
        this.e_output := ""
        this.inputKey := ""
        this.windowName := ""
        this.processPath := ""
        this.winTitle := ""
        this.isDirect := ""
        this.outputKey := ""
        this.runCommand := ""
        this.workingDir := ""
        this.isToggle := ""
        this.repeatTime := ""
        this.holdTime := ""
        this.isAdmin := ""
        this.func := ""
        this.funcs := ""
        this.expression := ""
        this.prefixes := ""
        this.prefixKey := ""
        this.combinationKey := ""
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

    ExtractPrefixKey(key)
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
        Return prefixKey
    }

    ExtractInputKey(key)
    {
        matchPos := RegExMatch(key, "[^\~\*\<\^\+\!\#]")
        inputKey := SubStr(key, matchPos)
        If (InStr(key, "~"))
        {
            prefix := RegExReplace(SubStr(key, 1, matchPos - 1), "[\~\*\<]")
            matchPos := InStr(inputKey, " & ")
            inputKey := matchPos ? StrReplace(SubStr(inputKey, matchPos), " & ") : inputKey
            inputKey := prefix inputKey
        }
        Return inputKey
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

    GetWaitKey()
    {
        key := RegExReplace(A_ThisHotkey, "[\~\*\<\>\^\+\!\#]")
        matchPos := InStr(key, " & ")
        Return matchPos ? StrReplace(SubStr(key, matchPos), " & ") : key
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

    RunCmd(runCommand, workingDir, isAdmin)
    {
        If (isAdmin)
        {
            Run, % "*RunAs " runCommand, % workingDir
        }
        Else
        {
            Run, % runCommand, % workingDir
        }
    }

    ToggleFunc(funcDown, funcUp, key)
    {
        this.isActive[key] := !this.isActive[key]
        If (this.isActive[key])
        {
            funcDown.Call()
        }
        Else
        {
            funcUp.Call()
        }
        waitKey := this.GetWaitKey()
        KeyWait, % waitKey
    }

    RepeatFunc(func, key)
    {
        this.isActive[key] := !this.isActive[key]
        If (this.isActive[key])
        {
            SetTimer, % func, % this.repeatTime[key] * 1000
            func.Call()
        }
        Else
        {
            SetTimer, % func, Delete
        }
        waitKey := this.GetWaitKey()
        KeyWait, % waitKey
    }

    HoldFunc(funcDown, funcUp, key)
    {
        funcDown.Call()
        Sleep, this.holdTime[key] * 1000
        funcUp.Call()
        waitKey := this.GetWaitKey()
        KeyWait, % waitKey
    }

    DoubleFunc(funcDouble, funcSingle := "")
    {
        key := this.GetWaitKey()
        KeyWait, % key
        KeyWait, % key, % "D" "T" HotkeyData.doublePressTime
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
        key := this.GetWaitKey()
        KeyWait, % key, % "T" HotkeyData.longPressTime
        If (ErrorLevel)
        {
            funcLong.Call()
            KeyWait, % key
        }
        Else If (funcSingle)
        {
            funcSingle.Call()
        }
    }

    DoubleLongFunc(funcDouble, funcLong, funcSingle := "")
    {
        key := this.GetWaitKey()
        KeyWait, % key, % "T" HotkeyData.longPressTime
        If (ErrorLevel)
        {
            funcLong.Call()
            KeyWait, % key
        }
        Else
        {
            KeyWait, % key, % "D" "T" HotkeyData.doublePressTime
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

    DetermineFunc()
    {
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
                    func := ObjBindMethod(this, "RunCmd", this.runCommand[key], this.workingDir[key], this.isAdmin[key])
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
                    If (this.isToggle[key])
                    {
                        func := ObjBindMethod(this, "ToggleFunc", funcDown, funcUp, key)
                    }
                    Else
                    {
                        If (this.holdTime[key])
                        {
                            func := ObjBindMethod(this, "HoldFunc", funcDown, funcUp, key)
                        }
                        If (this.repeatTime[key])
                        {
                            func := ObjBindMethod(this, "RepeatFunc", func, key)
                        }
                    }
                }
            }
            this.funcs[key] := func
        }
        If (this.funcs.HasKey("Double") && this.funcs.HasKey("Long"))
        {
            If (this.funcs.HasKey("Single"))
            {
                this.func := ObjBindMethod(this, "DoubleLongFunc", this.funcs["Double"], this.funcs["Long"], this.funcs["Single"])
            }
            Else
            {
                this.func := ObjBindMethod(this, "DoubleLongFunc", this.funcs["Double"], this.funcs["Long"])
            }
        }
        Else If (this.funcs.HasKey("Double"))
        {
            If (this.funcs.HasKey("Single"))
            {
                this.func := ObjBindMethod(this, "DoubleFunc", this.funcs["Double"], this.funcs["Single"])
            }
            Else
            {
                this.func := ObjBindMethod(this, "DoubleFunc", this.funcs["Double"])
            }
        }
        Else If (this.funcs.HasKey("Long"))
        {
            If (this.funcs.HasKey("Single"))
            {
                this.func := ObjBindMethod(this, "LongFunc", this.funcs["Long"], this.funcs["Single"])
            }
            Else
            {
                this.func := ObjBindMethod(this, "LongFunc", this.funcs["Long"])
            }
        }
        Else If (this.funcs.HasKey("Single"))
        {
            this.func := this.funcs["Single"]
        }
    }

    DetermineCombinationKey()
    {
        If (InStr(this.inputKey, "&"))
        {
            this.prefixKey := this.ExtractPrefixKey(this.inputKey)
            this.combinationKey := this.ExtractInputKey(this.inputKey)
            this.expression := ObjBindMethod(this, "GetPrefixKeyState")
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
    CreateHotkey(inputKey, windowName, processPath, isDirect, outputKey, runCommand, workingDir, isToggle, repeatTime, holdTime, isAdmin)
    {
        key := RegExReplace(inputKey, "[\~\*\<]") windowName processPath isDirect
        If (this.hotkeys.HasKey(key))
        {
            Return "ERROR"
        }
        this.hotkeys[key] := New HotkeyData(inputKey, windowName, processPath, isDirect, outputKey, runCommand, workingDir, isToggle, repeatTime, holdTime, isAdmin)
        this.hotkeys[key].EnableHotkey()
        Return key
    }

    DeleteHotkey(key)
    {
        Return this.hotkeys.HasKey(key) ? this.DeleteKey(key) : False
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
            this.DeleteKey(key)
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

    ; Private method
    DeleteKey(key)
    {
        this.hotkeys[key].Clear()
        Return this.hotkeys.Delete(key)
    }
}

class DynamicHotkey extends HotkeyManager
{
    ; Variables
    static instance := ""
    static doNothingFunc := ObjBindMethod(DynamicHotkey, "DoNothing")
    profileDir := A_ScriptDir "\Profiles"
    configFile := A_ScriptDir "\DynamicHotkey.ini"
    linkDataFile := A_ScriptDir "\Link.dat"
    e_output := ""
    funcCheckLinkData := ""
    linkData := {}
    winEvent := ""
    listViewNum := ""
    listViewKey := ""
    profiles := ""
    nowProfile := ""
    selectLinkNum := ""
    selectLinkData := ""
    isOpenAtLaunch := ""
    isAlwaysOnTop := ""
    isAutoSwitch := ""
    doublePressTime := ""
    longPressTime := ""
    enableKeys := ""
    wheelState := ""
    hTab := ""
    hListView := ""
    hSelectedProfile := ""
    hIsOpen := ""
    hIsTop := ""
    hIsSwitch := ""
    hDoublePress := ""
    hLongPress := ""
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

    NewProfile
    {
        get
        {
            GuiControlGet, value,, % this.hNewProfile
            Return value
        }
    }

    LinkListView
    {
        get
        {
            GuiControlGet, value,, % this.hLinkListView
            Return value
        }
        set
        {
            GuiControl,, % this.hLinkListView, % value
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
        hOutputKey := ""
        hBindOutput := ""
        hOutputKey2nd := ""
        hBindOutput2nd := ""
        hRunCommand := ""
        hDirectory := ""
        hWorkingDir := ""
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
        this.winEvent := New WinEventHook(,, this.funcCheckLinkData)
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
        IniRead, doublePress, % this.configFile, DynamicHotkey, DoublePressTime
        IniRead, longPress, % this.configFile, DynamicHotkey, LongPressTime
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
        If (doublePress == "ERROR")
        {
            doublePress := 0.2
            IniWrite, % doublePress, % this.configFile, DynamicHotkey, DoublePressTime
        }
        If (longPress == "ERROR")
        {
            longPress := 0.3
            IniWrite, % longPress, % this.configFile, DynamicHotkey, LongPressTime
        }
        this.isOpenAtLaunch := isOpen
        this.isAlwaysOnTop := isTop
        this.isAutoSwitch := isSwitch
        HotkeyData.doublePressTime := this.doublePressTime := doublePress
        HotkeyData.longPressTime := this.longPressTime := longPress
        If (this.isOpenAtLaunch)
        {
            this.GuiOpen()
        }
        If (this.isAutoSwitch)
        {
            this.winEvent.Start()
        }
    }

    ; Static method
    Quit()
    {
        this.winEvent.Clear()
        this.funcCheckLinkData := ""
        DynamicHotkey.instance := ""
    }

    ; Public method
    GuiOpen()
    {
        If (WinExist("Dynamic Hotkey ahk_class AutoHotkeyGUI"))
        {
            Return
        }
        Gui, DynamicHotkey:New, +LabelDynamicHotkey.Gui, Dynamic Hotkey
        If (this.isAlwaysOnTop)
        {
            Gui, DynamicHotkey:+AlwaysOnTop
        }
        Gui, DynamicHotkey:Add, Tab3, w503 h275 HwndhTab GDynamicHotkey.GuiChangeTab Choose1, List|Profile|Setting
        this.hTab := hTab
        Gui, DynamicHotkey:Tab, List
        Gui, DynamicHotkey:Add, ListView, x+10 w478 h208 HwndhListView GDynamicHotkey.GuiEventListView AltSubmit -LV0x10 -Multi, |Input key|Window name|Process path|Option|Single press|Double press|Long press
        this.hListView := hListView
        Gui, DynamicHotkey:Add, Button, xp-1 y+7 w66 GDynamicHotkey.GuiListButtonCreate, Create
        Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiListButtonEdit, Edit
        Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiListButtonDelete, Delete
        Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiListButtonDeleteAll, Delete all
        Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiListButtonOnOff, On/Off
        Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiListButtonEnableAll, Enable all
        Gui, DynamicHotkey:Add, Button, x+3 w66 GDynamicHotkey.GuiListButtonDisableAll, Disable all
        Gui, DynamicHotkey:Tab, Profile
        Gui, DynamicHotkey:Add, ListBox, x+10 w478 h208 HwndhSelectedProfile GDynamicHotkey.GuiEventListBox
        this.hSelectedProfile := hSelectedProfile
        Gui, DynamicHotkey:Add, Button, xp-1 y+7 w92 GDynamicHotkey.GuiProfileButtonCreate, Create
        Gui, DynamicHotkey:Add, Button, x+5 w92 GDynamicHotkey.GuiProfileButtonDelete, Delete
        Gui, DynamicHotkey:Add, Button, x+5 w92 GDynamicHotkey.GuiProfileButtonSave, Save
        Gui, DynamicHotkey:Add, Button, x+5 w92 GDynamicHotkey.GuiProfileButtonLoad, Load
        Gui, DynamicHotkey:Add, Button, x+5 w92 GDynamicHotkey.GuiProfileButtonLink, Link
        Gui, DynamicHotkey:Tab, Setting
        Gui, DynamicHotkey:Add, CheckBox, x+160 y+60 HwndhIsOpen GDynamicHotkey.GuiChangeIsOpen, Open a window at launch
        this.hIsOpen := hIsOpen
        Gui, DynamicHotkey:Add, CheckBox, xp+0 yp+30 HwndhIsTop GDynamicHotkey.GuiChangeIsTop, Keep a window always on top
        this.hIsTop := hIsTop
        Gui, DynamicHotkey:Add, CheckBox, xp+0 yp+30 HwndhIsSwitch GDynamicHotkey.GuiChangeIsSwitch, Auto switching profiles
        this.hIsSwitch := hIsSwitch
        Gui, DynamicHotkey:Add, Text, xp+0 yp+30 Section, Double press time
        Gui, DynamicHotkey:Add, Edit, x+2 yp-6 w44 HwndhDoublePress GDynamicHotkey.GuiEditDoublePress Limit3 Right, % this.doublePressTime
        this.hDoublePress := hDoublePress
        Gui, DynamicHotkey:Add, Text, x+2 yp+6, second
        Gui, DynamicHotkey:Add, Text, xs+0 yp+30, Long press time
        Gui, DynamicHotkey:Add, Edit, x+13 yp-6 w44 HwndhLongPress GDynamicHotkey.GuiEditLongPress Limit3 Right, % this.longPressTime
        this.hLongPress := hLongPress
        Gui, DynamicHotkey:Add, Text, x+2 yp+6, second
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
        Gui, DynamicHotkey:Show
        GuiControl, DynamicHotkey:Focus, % this.hTab
    }

    ; Gui methods
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
        Else If (tabName == "Setting")
        {
            If (this.DoublePress != this.doublePressTime)
            {
                this.DoublePress := this.doublePressTime
            }
            longPressTime := this.LongPress
            If (longPressTime != this.longPressTime || (StrLen(longPressTime) > 1 && (StrIn(SubStr(longPressTime, 1, 1), "0") || StrIn(SubStr(longPressTime, 0), "."))))
            {
                this.LongPress := this.longPressTime
            }
        }
        GuiControl, DynamicHotkey:Focus, % this.hTab
    }

    GuiEventListView()
    {
        Critical, On
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
        Else If (A_GuiControlEvent == "DoubleClick")
        {
            this.GuiListButtonOnOff()
        }
        Else If (A_GuiControlEvent == "R")
        {
            this.GuiListButtonDelete()
        }
        Critical, Off
    }

    GuiListButtonCreate(GuiEvent := "", EventInfo := "", ErrLevel := "", listViewKey := "")
    {
        If (WinExist("New Hotkey ahk_class AutoHotkeyGUI") || WinExist("Edit Hotkey ahk_class AutoHotkeyGUI"))
        {
            Return
        }
        this := DynamicHotkey.instance
        If (this.isAutoSwitch)
        {
            this.winEvent.Stop()
        }
        For key In this.e_output
        {
            this.hOutputs[key] := New this.OutputHwnd()
        }
        this.enableKeys := this.GetEnableKeys()
        this.DisableAllHotkeys()
        Gui, DynamicHotkey:+Disabled
        If (listViewKey != "")
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
        this.hOutputs[key].hRadioKey := hRadioKeySingle
        this.hOutputs[key].hRadioCmd := hRadioCmdSingle
        Gui, NewHotkey:Add, Edit, xs+0 w235 HwndhOutputKeySingle ReadOnly Center Disabled
        this.hOutputs[key].hOutputKey := hOutputKeySingle
        Gui, NewHotkey:Add, Edit, x+6 w117 HwndhOutputKeySingle2nd ReadOnly Center Disabled
        this.hOutputs[key].hOutputKey2nd := hOutputKeySingle2nd
        Gui, NewHotkey:Add, Edit, xs+0 yp+0 w358 HwndhRunCommandSingle Hidden Center Disabled
        this.hOutputs[key].hRunCommand := hRunCommandSingle
        Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputSingle GDynamicHotkey.NewHotkeyGuiBindOutputSingle Disabled, Bind
        this.hOutputs[key].hBindOutput := hBindOutputSingle
        Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputSingle2nd GDynamicHotkey.NewHotkeyGuiBindOutputSingle2nd Disabled, Bind
        this.hOutputs[key].hBindOutput2nd := hBindOutputSingle2nd
        Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectorySingle Hidden Disabled, Working directory
        this.hOutputs[key].hDirectory := hDirectorySingle
        Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirSingle Hidden Center Disabled
        this.hOutputs[key].hWorkingDir := hWorkingDirSingle
        Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
        Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsToggleSingle GDynamicHotkey.NewHotkeyGuiChangeIsToggleSingle Section Disabled, Toggle
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
        Gui, NewHotkey:Add, Radio, xs+0 yp+18 HwndhRadioKeyDouble GDynamicHotkey.NewHotkeyGuiChangeOutputDouble Checked Disabled, Key
        Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioCmdDouble GDynamicHotkey.NewHotkeyGuiChangeOutputDouble Disabled, Run command
        this.hOutputs[key].hRadioKey := hRadioKeyDouble
        this.hOutputs[key].hRadioCmd := hRadioCmdDouble
        Gui, NewHotkey:Add, Edit, xs+0 w235 HwndhOutputKeyDouble ReadOnly Center Disabled
        this.hOutputs[key].hOutputKey := hOutputKeyDouble
        Gui, NewHotkey:Add, Edit, x+6 w117 HwndhOutputKeyDouble2nd ReadOnly Center Disabled
        this.hOutputs[key].hOutputKey2nd := hOutputKeyDouble2nd
        Gui, NewHotkey:Add, Edit, xs+0 yp+0 w358 HwndhRunCommandDouble Hidden Center Disabled
        this.hOutputs[key].hRunCommand := hRunCommandDouble
        Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputDouble GDynamicHotkey.NewHotkeyGuiBindOutputDouble Disabled, Bind
        this.hOutputs[key].hBindOutput := hBindOutputDouble
        Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputDouble2nd GDynamicHotkey.NewHotkeyGuiBindOutputDouble2nd Disabled, Bind
        this.hOutputs[key].hBindOutput2nd := hBindOutputDouble2nd
        Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectoryDouble Hidden Disabled, Working directory
        this.hOutputs[key].hDirectory := hDirectoryDouble
        Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirDouble Hidden Center Disabled
        this.hOutputs[key].hWorkingDir := hWorkingDirDouble
        Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
        Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsToggleDouble GDynamicHotkey.NewHotkeyGuiChangeIsToggleDouble Section Disabled, Toggle
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
        Gui, NewHotkey:Add, Radio, xs+0 yp+18 HwndhRadioKeyLong GDynamicHotkey.NewHotkeyGuiChangeOutputLong Checked Disabled, Key
        Gui, NewHotkey:Add, Radio, x+4 yp+0 HwndhRadioCmdLong GDynamicHotkey.NewHotkeyGuiChangeOutputLong Disabled, Run command
        this.hOutputs[key].hRadioKey := hRadioKeyLong
        this.hOutputs[key].hRadioCmd := hRadioCmdLong
        Gui, NewHotkey:Add, Edit, xs+0 w235 HwndhOutputKeyLong ReadOnly Center Disabled
        this.hOutputs[key].hOutputKey := hOutputKeyLong
        Gui, NewHotkey:Add, Edit, x+6 w117 HwndhOutputKeyLong2nd ReadOnly Center Disabled
        this.hOutputs[key].hOutputKey2nd := hOutputKeyLong2nd
        Gui, NewHotkey:Add, Edit, xs+0 yp+0 w358 HwndhRunCommandLong Hidden Center Disabled
        this.hOutputs[key].hRunCommand := hRunCommandLong
        Gui, NewHotkey:Add, Button, xp-1 y+6 w237 h39 HwndhBindOutputLong GDynamicHotkey.NewHotkeyGuiBindOutputLong Disabled, Bind
        this.hOutputs[key].hBindOutput := hBindOutputLong
        Gui, NewHotkey:Add, Button, x+4 w119 h39 HwndhBindOutputLong2nd GDynamicHotkey.NewHotkeyGuiBindOutputLong2nd Disabled, Bind
        this.hOutputs[key].hBindOutput2nd := hBindOutputLong2nd
        Gui, NewHotkey:Add, Text, xs+0 yp+0 HwndhDirectoryLong Hidden Disabled, Working directory
        this.hOutputs[key].hDirectory := hDirectoryLong
        Gui, NewHotkey:Add, Edit, xs+0 y+6 w358 HwndhWorkingDirLong Hidden Center Disabled
        this.hOutputs[key].hWorkingDir := hWorkingDirLong
        Gui, NewHotkey:Add, GroupBox, x+8 ys-18 w120 h132
        Gui, NewHotkey:Add, CheckBox, xp+8 yp+20 HwndhIsToggleLong GDynamicHotkey.NewHotkeyGuiChangeIsToggleLong Section Disabled, Toggle
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
        If (listViewKey != "")
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
                this.hOutputs[key].RunCommand := this.hotkeys[listViewKey].runCommand[key]
                If (outputKey != "" || this.hOutputs[key].RunCommand != "")
                {
                    this.hOutputs[key].IsOutputType := True
                    this.hOutputs[key].OutputKey := this.ToDisplayKeyAlt(this.ToDisplayKey(outputKey))
                    this.hOutputs[key].OutputKey2nd := this.ToDisplayKey(outputKey2nd)
                    this.hOutputs[key].RadioKey := this.hotkeys[listViewKey].runCommand[key] == "" ? True : False
                    this.hOutputs[key].RadioCmd := this.hotkeys[listViewKey].runCommand[key] ? True : False
                    this.hOutputs[key].WorkingDir := this.hotkeys[listViewKey].workingDir[key]
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
                this.ChangeIsOutputType(key)
                this.ChangeOutput(key)
                this.ChangeIsToggle(key)
                this.ChangeIsRepeat(key)
                this.ChangeIsHold(key)
            }
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
        this.winEvent.SetFunc(ObjBindMethod(this, "DetectWindowInfo", "NewHotkey", guiHwnd, this.hWindowInfo, this.hWindowName, this.hProcessPath))
        this.winEvent.Start()
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
                    this.hOutputs[key].RadioKey := True
                    this.hOutputs[key].OutputKey2nd := ""
                    this.hOutputs[key].BindOutput2nd := "Bind"
                }
                Else
                {
                    GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRadioCmd
                    GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey2nd
                    GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput2nd
                }
                this.ChangeOutput(key)
            }
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
            }
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hOutputKey
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRunCommand
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hBindOutput
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hDirectory
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hWorkingDir
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsToggle
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsRepeat
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsHold
        }
        Else
        {
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRadioKey
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRadioCmd
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hOutputKey2nd
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRunCommand
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
            this.hOutputs[key].RadioKey := True
            this.hOutputs[key].RadioCmd := False
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
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsToggle
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsRepeat
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hIsHold
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
            this.hOutputs[key].RunCommand := ""
            this.hOutputs[key].WorkingDir := ""
            this.hOutputs[key].IsAdmin := False
        }
        Else
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
            this.hOutputs[key].OutputKey := ""
            this.hOutputs[key].OutputKey2nd := ""
            this.hOutputs[key].BindOutput2nd := "Bind"
            this.hOutputs[key].IsToggle := False
            this.hOutputs[key].IsRepeat := False
            this.hOutputs[key].RepeatTime := 0
            this.hOutputs[key].IsHold := False
            this.hOutputs[key].HoldTime := 0
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

    ChangeIsToggle(key)
    {
        If (this.hOutputs[key].IsToggle)
        {
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeatTime
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hRepeat
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHoldTime
            GuiControl, NewHotkey:Disable, % this.hOutputs[key].hHold
            this.hOutputs[key].IsRepeat := False
            this.hOutputs[key].RepeatTime := 0
            this.hOutputs[key].IsHold := False
            this.hOutputs[key].HoldTime := 0
        }
    }

    ChangeIsRepeat(key)
    {
        If (this.hOutputs[key].IsRepeat)
        {
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRepeatTime
            GuiControl, NewHotkey:Enable, % this.hOutputs[key].hRepeat
            this.hOutputs[key].IsToggle := False
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
            this.hOutputs[key].IsToggle := False
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
        Critical, On
        repeatTime := RegExNumber(this.hOutputs[key].RepeatTime, False)
        clampedRepeatTime := Clamp(repeatTime, 0, 3600)
        If (repeatTime != clampedRepeatTime)
        {
            this.hOutputs[key].RepeatTime := clampedRepeatTime
            SetSel(this.hOutputs[key].hRepeatTime)
        }
        Critical, Off
    }

    EditHoldTime(key)
    {
        Critical, On
        holdTime := RegExNumber(this.hOutputs[key].HoldTime, False)
        clampedHoldTime := Clamp(holdTime, 0, 3600)
        If (holdTime != clampedHoldTime)
        {
            this.hOutputs[key].HoldTime := clampedHoldTime
            SetSel(this.hOutputs[key].hHoldTime)
        }
        Critical, Off
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

    NewHotkeyGuiChangeIsToggleSingle()
    {
        this := DynamicHotkey.instance
        this.ChangeIsToggle("Single")
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

    NewHotkeyGuiChangeIsToggleDouble()
    {
        this := DynamicHotkey.instance
        this.ChangeIsToggle("Double")
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

    NewHotkeyGuiChangeIsToggleLong()
    {
        this := DynamicHotkey.instance
        this.ChangeIsToggle("Long")
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
        isOutputType := {}
        radioKey := {}
        outputKey := {}
        outputKey2nd := {}
        runCommand := {}
        workingDir := {}
        isAdmin := {}
        isToggle := {}
        repeatTime := {}
        holdTime := {}
        isLong := {}
        For key In this.e_output
        {
            isOutputType[key] := this.hOutputs[key].IsOutputType
            If (isOutputType[key])
            {
                radioKey[key] := this.hOutputs[key].RadioKey
                outputKey[key] := this.hOutputs[key].OutputKey
                outputKey2nd[key] := this.hOutputs[key].OutputKey2nd
                runCommand[key] := this.hOutputs[key].RunCommand
                workingDir[key] := this.hOutputs[key].WorkingDir
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
                Else If (runCommand[key] == "")
                {
                    DisplayToolTip("No run command entered")
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
        key := this.CreateHotkey(inputKey, windowName, processPath, isDirect, outputKey, runCommand, workingDir, isToggle, repeatTime, holdTime, isAdmin)
        If (key != "ERROR")
        {
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
        this.hSecret := ""
        For key In this.e_output
        {
            this.hOutputs[key].hRadioKey := ""
            this.hOutputs[key].hRadioCmd := ""
            this.hOutputs[key].hOutputKey := ""
            this.hOutputs[key].hBindOutput := ""
            this.hOutputs[key].hOutputKey2nd := ""
            this.hOutputs[key].hBindOutput2nd := ""
            this.hOutputs[key].hRunCommand := ""
            this.hOutputs[key].hDirectory := ""
            this.hOutputs[key].hWorkingDir := ""
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
        WinActivate, % "Dynamic Hotkey ahk_class AutoHotkeyGUI"
        If (this.isAutoSwitch)
        {
            this.winEvent.Start()
        }
    }

    GuiListButtonEdit()
    {
        this := DynamicHotkey.instance
        If (this.listViewNum != "" && this.listViewKey != "")
        {
            this.GuiListButtonCreate(,,, this.listViewKey)
        }
    }

    GuiListButtonDelete(GuiEvent := "", EventInfo := "", ErrLevel := "", isEdit := False)
    {
        this := DynamicHotkey.instance
        If (this.listViewNum != "" && this.listViewKey != "")
        {
            If (this.DeleteHotkey(this.listViewKey))
            {
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
        this := DynamicHotkey.instance
        If (this.DeleteAllHotkeys())
        {
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
        this := DynamicHotkey.instance
        If (this.EnableAllHotkeys())
        {
            LV_Modify(0, "", "✓")
            DisplayToolTip("All hotkeys enabled")
        }
    }

    GuiListButtonDisableAll()
    {
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
        If (A_GuiControlEvent == "DoubleClick")
        {
            this.GuiProfileButtonLoad()
        }
    }

    GuiProfileButtonCreate()
    {
        If (WinExist("New Profile ahk_class AutoHotkeyGUI"))
        {
            Return
        }
        this := DynamicHotkey.instance
        If (this.isAutoSwitch)
        {
            this.winEvent.Stop()
        }
        Gui, DynamicHotkey:+Disabled
        Gui, NewProfile:New, +LabelDynamicHotkey.NewProfileGui +OwnerDynamicHotkey -SysMenu, New Profile
        If (this.isAlwaysOnTop)
        {
            Gui, NewProfile:+AlwaysOnTop
        }
        Gui, NewProfile:Add, Edit, x+1 y+8 w200 r1 -VScroll HwndhNewProfile
        this.hNewProfile := hNewProfile
        Gui, NewProfile:Add, Button, xs-1 w100 Default GDynamicHotkey.NewProfileGuiButtonOK, OK
        Gui, NewProfile:Add, Button, x+2 w100 GDynamicHotkey.NewProfileGuiClose, Cancel
        Gui, NewProfile:Show
    }

    NewProfileGuiButtonOK()
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
        Else
        {
            this.SaveProfile(newProfile)
            this.profiles.Push(newProfile)
            Sort(this.profiles, this.profiles.MinIndex(), this.profiles.MaxIndex())
            this.profiles.RemoveAt(InArray(this.profiles, "Default"))
            this.profiles.InsertAt(1, "Default")
            this.SelectedProfile := "|"
            For key, value In this.profiles
            {
                this.SelectedProfile := value
            }
            DisplayToolTip("Profile created")
        }
        this.NewProfileGuiClose()
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
        WinActivate, Dynamic Hotkey ahk_class AutoHotkeyGUI
        If (this.isAutoSwitch)
        {
            this.winEvent.Start()
        }
    }

    GuiProfileButtonDelete()
    {
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
        this := DynamicHotkey.instance
        If (this.isAutoSwitch)
        {
            this.winEvent.Stop()
        }
        Gui, DynamicHotkey:+Disabled
        Gui, LinkData:New, +LabelDynamicHotkey.LinkProfileGui +OwnerDynamicHotkey -SysMenu, Link Data
        If (this.isAlwaysOnTop)
        {
            Gui, LinkData:+AlwaysOnTop
        }
        Gui, LinkData:Add, ListView, x+1 y+8 w404 h208 HwndhLinkListView GDynamicHotkey.LinkProfileGuiEventListView AltSubmit -LV0x10 -Multi, Profile name|Window name|Process path|Mode
        this.hLinkListView := hLinkListView
        Gui, LinkData:Add, Button, xs-1 w100 GDynamicHotkey.LinkProfileGuiButtonCreate, Create
        Gui, LinkData:Add, Button, x+2 w100 GDynamicHotkey.LinkProfileGuiButtonEdit, Edit
        Gui, LinkData:Add, Button, x+2 w100 GDynamicHotkey.LinkProfileGuiButtonDelete, Delete
        Gui, LinkData:Add, Button, x+2 w100 GDynamicHotkey.LinkProfileGuiClose, Close
        GuiControl, LinkData:-Redraw, % this.hLinkListView
        LV_Delete()
        For key, value In this.linkData
        {
            data := StrSplit(value, "|")
            LV_Add(, data[1], data[2], data[3], data[4])
        }
        this.SortLinkListView()
        GuiControl, LinkData:+Redraw, % this.hLinkListView
        Gui, LinkData:Show
    }

    LinkProfileGuiEventListView()
    {
        Critical, On
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
        Else If (A_GuiControlEvent == "DoubleClick")
        {
            this.LinkProfileGuiButtonEdit()
        }
        Else If (A_GuiControlEvent == "R")
        {
            this.LinkProfileGuiButtonDelete()
        }
        Critical, Off
    }

    LinkProfileGuiButtonCreate(GuiEvent := "", EventInfo := "", ErrLevel := "", selectLinkData := "")
    {
        If (WinExist("New Link Data ahk_class AutoHotkeyGUI") || WinExist("Edit Link Data ahk_class AutoHotkeyGUI"))
        {
            Return
        }
        this := DynamicHotkey.instance
        Gui, LinkData:+Disabled
        If (selectLinkData != "")
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
        If (selectLinkData != "")
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
        modes := ["Active", "Exist"]
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
        this.winEvent.SetFunc(ObjBindMethod(this, "DetectWindowInfo", "NewLinkData", guiHwnd, this.hNewLinkWindowInfo, this.hNewLinkWindow, this.hNewLinkProcess))
        this.winEvent.Start()
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
        If (InArray(this.linkData, newLinkProfile "|" newLinkWindow "|" newLinkProcess "|" newLinkMode))
        {
            DisplayToolTip("Link data already exists")
            Return
        }
        If (isEdit)
        {
            this.LinkProfileGuiButtonDelete(,,, True)
        }
        LV_Add(, newLinkProfile, newLinkWindow, newLinkProcess, newLinkMode)
        this.SetLinkData(newLinkProfile, newLinkWindow, newLinkProcess, newLinkMode)
        Sort(this.linkData, this.linkData.MinIndex(), this.linkData.MaxIndex())
        this.SaveLinkData()
        this.SortLinkListView()
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
            this.LinkProfileGuiButtonCreate(,,, this.selectLinkData)
        }
    }

    LinkProfileGuiButtonDelete(GuiEvent := "", EventInfo := "", ErrLevel := "", isEdit := False)
    {
        this := DynamicHotkey.instance
        If (this.selectLinkNum != "" && this.selectLinkData != "")
        {
            If (this.DeleteLinkData(this.selectLinkData))
            {
                LV_Delete(this.selectLinkNum)
                this.SaveLinkData()
                this.SortLinkListView()
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
        WinActivate, Dynamic Hotkey ahk_class AutoHotkeyGUI
        If (this.isAutoSwitch)
        {
            this.winEvent.Start()
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
            this.winEvent.Start()
        }
        Else
        {
            this.winEvent.Stop()
        }
        IniWrite, % this.isAutoSwitch, % this.configFile, DynamicHotkey, IsAutoSwitch
    }

    GuiEditDoublePress()
    {
        Critical, On
        this := DynamicHotkey.instance
        doublePressTime := RegExNumber(this.DoublePress, False)
        If (doublePressTime == Clamp(doublePressTime, 0.2, 0.5))
        {
            GuiControl, DynamicHotkey:+cBlack, % this.hDoublePress
            If (doublePressTime != this.doublePressTime)
            {
                HotkeyData.doublePressTime := this.doublePressTime := Format("{:0.1f}", doublePressTime)
                IniWrite, % this.doublePressTime, % this.configFile, DynamicHotkey, DoublePressTime
            }
        }
        Else
        {
            GuiControl, DynamicHotkey:+cRed, % this.hDoublePress
        }
        GuiControl, DynamicHotkey:MoveDraw, % this.hDoublePress
        Critical, Off
    }

    GuiEditLongPress()
    {
        Critical, On
        this := DynamicHotkey.instance
        longPressTime := RegExNumber(this.LongPress, False)
        If (longPressTime == Clamp(longPressTime, 0.2, 10))
        {
            GuiControl, DynamicHotkey:+cBlack, % this.hLongPress
            If (longPressTime != this.longPressTime)
            {
                HotkeyData.longPressTime := this.longPressTime := InStr(longPressTime, ".") ? Format("{:0.1f}", longPressTime) : Format("{:d}", longPressTime)
                IniWrite, % this.longPressTime, % this.configFile, DynamicHotkey, LongPressTime
            }
        }
        Else
        {
            GuiControl, DynamicHotkey:+cRed, % this.hLongPress
        }
        GuiControl, DynamicHotkey:MoveDraw, % this.hLongPress
        Critical, Off
    }

    GuiEscape()
    {
        this := DynamicHotkey.instance
        this.GuiClose()
    }

    GuiClose()
    {
        this := DynamicHotkey.instance
        this.listViewNum := ""
        this.listViewKey := ""
        this.profiles := ""
        this.hTab := ""
        this.hListView := ""
        this.hSelectedProfile := ""
        this.hIsOpen := ""
        this.hIsTop := ""
        this.hDoublePress := ""
        this.hLongPress := ""
        Gui, DynamicHotkey:Destroy
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
        Hotkey, *WheelDown, % getWheelStateFunc, On
        Hotkey, *WheelUp, % getWheelStateFunc, On
        Hotkey, *WheelLeft, % getWheelStateFunc, On
        Hotkey, *WheelRight, % getWheelStateFunc, On
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
        Hotkey, *WheelDown, % doNothingFunc, Off
        Hotkey, *WheelUp, % doNothingFunc, Off
        Hotkey, *WheelLeft, % doNothingFunc, Off
        Hotkey, *WheelRight, % doNothingFunc, Off
        this.wheelState := ""
        GuiControl,, % hwndEdit, % this.ToDisplayKey(key)
        GuiControl,, % hwndButton, Bind
        GuiControl, Enable, % hwndButton
    }

    SortListView()
    {
        LV_ModifyCol(2, "AutoHdr")
        LV_ModifyCol(3, "AutoHdr")
        LV_ModifyCol(4, "AutoHdr")
        LV_ModifyCol(5, "AutoHdr")
        LV_ModifyCol(6, "AutoHdr")
        LV_ModifyCol(7, "AutoHdr")
        LV_ModifyCol(8, "AutoHdr")
        LV_ModifyCol(8, "Sort")
        LV_ModifyCol(7, "Sort")
        LV_ModifyCol(6, "Sort")
        LV_ModifyCol(5, "Sort")
        LV_ModifyCol(4, "Sort")
        LV_ModifyCol(3, "Sort")
        LV_ModifyCol(2, "Sort")
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
                outputs[key2] := this.ToDisplayKey(this.hotkeys[key].outputKey[key2]) this.hotkeys[key].runCommand[key2]
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
        profilename := this.profileDir "\" profile ".ini"
        FileDelete, % profilename
        IniWrite, % this.hotkeys.Count(), % profilename, Total, Num
        For key In this.hotkeys
        {
            index := A_Index
            IniWrite, % this.hotkeys[key].inputKey, % profilename, % index, InputKey
            IniWrite, % this.hotkeys[key].windowName, % profilename, % index, WindowName
            IniWrite, % this.hotkeys[key].processPath, % profilename, % index, ProcessPath
            IniWrite, % this.hotkeys[key].isDirect, % profilename, % index, IsDirect
            For key2 In this.e_output
            {
                If (this.hotkeys[key].outputKey.HasKey(key2))
                {
                    IniWrite, % this.hotkeys[key].outputKey[key2], % profilename, % index, % "OutputKey" key2
                    IniWrite, % this.hotkeys[key].runCommand[key2], % profilename, % index, % "RunCommand" key2
                    IniWrite, % this.hotkeys[key].workingDir[key2], % profilename, % index, % "WorkingDir" key2
                    IniWrite, % this.hotkeys[key].isToggle[key2], % profilename, % index, % "IsToggle" key2
                    IniWrite, % this.hotkeys[key].repeatTime[key2], % profilename, % index, % "RepeatTime" key2
                    IniWrite, % this.hotkeys[key].holdTime[key2], % profilename, % index, % "HoldTime" key2
                    IniWrite, % this.hotkeys[key].isAdmin[key2], % profilename, % index, % "IsAdmin" key2
                }
            }
        }
    }

    LoadProfile(profile)
    {
        profilename := this.profileDir "\" profile ".ini"
        IniRead, totalKeys, % profilename, Total, Num
        If (totalKeys != "ERROR")
        {
            this.nowProfile := profile
            Loop, % totalKeys
            {
                index := A_Index
                outputKeys := {}
                runCommands := {}
                workingDirs := {}
                isToggles := {}
                repeatTimes := {}
                holdTimes := {}
                isAdmins := {}
                IniRead, inputKey, % profilename, % index, InputKey
                IniRead, windowName, % profilename, % index, WindowName
                IniRead, processPath, % profilename, % index, ProcessPath
                IniRead, isDirect, % profilename, % index, IsDirect
                For key In this.e_output
                {
                    IniRead, outputKey, % profilename, % index, % "OutputKey" key
                    IniRead, runCommand, % profilename, % index, % "RunCommand" key
                    IniRead, workingDir, % profilename, % index, % "WorkingDir" key
                    IniRead, isToggle, % profilename, % index, % "IsToggle" key
                    IniRead, repeatTime, % profilename, % index, % "RepeatTime" key
                    IniRead, holdTime, % profilename, % index, % "HoldTime" key
                    IniRead, isAdmin, % profilename, % index, % "IsAdmin" key
                    If (outputKey == "ERROR" || runCommand == "ERROR" || (outputKey == "" && runCommand == ""))
                    {
                        Continue
                    }
                    outputKeys[key] := outputKey
                    runCommands[key] := runCommand
                    workingDirs[key] := workingDir
                    isToggles[key] := isToggle
                    repeatTimes[key] := repeatTime
                    holdTimes[key] := holdTime
                    isAdmins[key] := isAdmin
                }
                this.CreateHotkey(inputKey, windowName, processPath, isDirect, outputKeys, runCommands, workingDirs, isToggles, repeatTimes, holdTimes, isAdmins)
            }
        }
    }

    CheckLinkData()
    {
        Gui, DynamicHotkey:Default
        WinGetTitle, activeWinTitle, % "ahk_id" this.winEvent.hwnd
        WinGet, activeWinProcessPath, ProcessPath, % "ahk_id" this.winEvent.hwnd
        If (profile := this.SearchLinkData(activeWinTitle, activeWinProcessPath, "Active"))
        {
            If (this.nowProfile != profile)
            {
                this.DeleteAllHotkeys()
                this.LoadProfile(profile)
                this.RefreshListView()
            }
            Return
        }
        DetectHiddenWindows, Off
        WinGet, winId, List
        DetectHiddenWindows, On
        Loop, % winId
        {
            winHwnd := winId%A_Index%
            If (winHwnd == this.winEvent.hwnd)
            {
                Continue
            }
            WinGetTitle, winTitle, % "ahk_id" winHwnd
            WinGet, winProcessPath, ProcessPath, % "ahk_id" winHwnd
            If (profile := this.SearchLinkData(winTitle, winProcessPath, "Exist"))
            {
                If (this.nowProfile != profile)
                {
                    this.DeleteAllHotkeys()
                    this.LoadProfile(profile)
                    this.RefreshListView()
                }
                Return
            }
        }
        If (this.nowProfile != "Default")
        {
            this.DeleteAllHotkeys()
            this.LoadProfile("Default")
            this.RefreshListView()
        }
    }

    SearchLinkData(windowName, processPath, mode)
    {
        profiles := []
        For key, value In this.linkData
        {
            data := StrSplit(value, "|")
            If (StrContains(windowName, data[2]) && StrContains(processPath, data[3]) && mode == data[4])
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

    SetLinkData(profileName, windowName, processPath, mode)
    {
        this.linkData.Push(profileName "|" windowName "|" processPath "|" mode)
    }

    DeleteLinkData(linkData)
    {
        key := InArray(this.linkData, linkData)
        Return key ? this.linkData.RemoveAt(key) : False
    }

    SortLinkListView()
    {
        LV_ModifyCol(1, "AutoHdr")
        LV_ModifyCol(2, "AutoHdr")
        LV_ModifyCol(3, "AutoHdr")
        LV_ModifyCol(4, "AutoHdr")
        LV_ModifyCol(4, "Sort")
        LV_ModifyCol(3, "Sort")
        LV_ModifyCol(2, "Sort")
        LV_ModifyCol(1, "Sort")
    }

    DetectWindowInfo(guiName, hwndGui, hwndButton, hwndWindowName, hwndProcessPath)
    {
        WinGetTitle, activeWinTitle, % "ahk_id" this.winEvent.hwnd
        WinGet, activeWinProcessPath, ProcessPath, % "ahk_id" this.winEvent.hwnd
        this.winEvent.Stop()
        this.winEvent.SetFunc(this.funcCheckLinkData)
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
