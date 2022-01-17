/*
	WinEventHook
	# Required files
	# Utility.ahk
	# Math.ahk
	# Array.ahk
*/
class WinEventHook
{
    ; Event constants
    static EVENT_OBJECT_ACCELERATORCHANGE := 0x8012
    static EVENT_OBJECT_CLOAKED := 0x8017
    static EVENT_OBJECT_CONTENTSCROLLED := 0x8015
    static EVENT_OBJECT_CREATE := 0x8000
    static EVENT_OBJECT_DEFACTIONCHANGE := 0x8011
    static EVENT_OBJECT_DESCRIPTIONCHANGE := 0x800D
    static EVENT_OBJECT_DESTROY := 0x8001
    static EVENT_OBJECT_DRAGSTART := 0x8021
    static EVENT_OBJECT_DRAGCANCEL := 0x8022
    static EVENT_OBJECT_DRAGCOMPLETE := 0x8023
    static EVENT_OBJECT_DRAGENTER := 0x8024
    static EVENT_OBJECT_DRAGLEAVE := 0x8025
    static EVENT_OBJECT_DRAGDROPPED := 0x8026
    static EVENT_OBJECT_END := 0x80FF
    static EVENT_OBJECT_FOCUS := 0x8005
    static EVENT_OBJECT_HELPCHANGE := 0x8010
    static EVENT_OBJECT_HIDE := 0x8003
    static EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED := 0x8020
    static EVENT_OBJECT_IME_HIDE := 0x8028
    static EVENT_OBJECT_IME_SHOW := 0x8027
    static EVENT_OBJECT_IME_CHANGE := 0x8029
    static EVENT_OBJECT_INVOKED := 0x8013
    static EVENT_OBJECT_LIVEREGIONCHANGED := 0x8019
    static EVENT_OBJECT_LOCATIONCHANGE := 0x800B
    static EVENT_OBJECT_NAMECHANGE := 0x800C
    static EVENT_OBJECT_PARENTCHANGE := 0x800F
    static EVENT_OBJECT_REORDER := 0x8004
    static EVENT_OBJECT_SELECTION := 0x8006
    static EVENT_OBJECT_SELECTIONADD := 0x8007
    static EVENT_OBJECT_SELECTIONREMOVE := 0x8008
    static EVENT_OBJECT_SELECTIONWITHIN := 0x8009
    static EVENT_OBJECT_SHOW := 0x8002
    static EVENT_OBJECT_STATECHANGE := 0x800A
    static EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED := 0x8030
    static EVENT_OBJECT_TEXTSELECTIONCHANGED := 0x8014
    static EVENT_OBJECT_UNCLOAKED := 0x8018
    static EVENT_OBJECT_VALUECHANGE := 0x800E
    static EVENT_SYSTEM_ALERT := 0x0002
    static EVENT_SYSTEM_ARRANGMENTPREVIEW := 0x8016
    static EVENT_SYSTEM_CAPTUREEND := 0x0009
    static EVENT_SYSTEM_CAPTURESTART := 0x0008
    static EVENT_SYSTEM_CONTEXTHELPEND := 0x000D
    static EVENT_SYSTEM_CONTEXTHELPSTART := 0x000C
    static EVENT_SYSTEM_DESKTOPSWITCH := 0x0020
    static EVENT_SYSTEM_DIALOGEND := 0x0011
    static EVENT_SYSTEM_DIALOGSTART := 0x0010
    static EVENT_SYSTEM_DRAGDROPEND := 0x000F
    static EVENT_SYSTEM_DRAGDROPSTART := 0x000E
    static EVENT_SYSTEM_END := 0x00FF
    static EVENT_SYSTEM_FOREGROUND := 0x0003
    static EVENT_SYSTEM_MENUPOPUPEND := 0x0007
    static EVENT_SYSTEM_MENUPOPUPSTART := 0x0006
    static EVENT_SYSTEM_MENUEND := 0x0005
    static EVENT_SYSTEM_MENUSTART := 0x0004
    static EVENT_SYSTEM_MINIMIZEEND := 0x0017
    static EVENT_SYSTEM_MINIMIZESTART := 0x0016
    static EVENT_SYSTEM_MOVESIZEEND := 0x000B
    static EVENT_SYSTEM_MOVESIZESTART := 0x000A
    static EVENT_SYSTEM_SCROLLINGEND := 0x0013
    static EVENT_SYSTEM_SCROLLINGSTART := 0x0012
    static EVENT_SYSTEM_SOUND := 0x0001
    static EVENT_SYSTEM_SWITCHEND := 0x0015
    static EVENT_SYSTEM_SWITCHSTART := 0x0014

    ; Variables
    hWinEventHook := ""
    event := ""
    hwnd := ""
    idObject := ""
    idChild := ""
    dwEventThread := ""
    dwmsEventTime := ""
    events := ""
    eventMin := ""
    eventMax := ""
    func := ""

    ; Constructor
    __New(func := "", events*)
    {
        this.SetEvent(events*)
        this.SetFunc(func)
    }

    ; Public methods
    Start()
    {
        If (this.hWinEventHook != "" || (!IsType(this.eventMin, "Xdigit") || this.eventMin == "") || (!IsType(this.eventMax, "Xdigit") || this.eventMax == ""))
        {
            Return False
        }
        this.hWinEventHook := DllCall("SetWinEventHook"
            , "UInt", this.eventMin
            , "UInt", this.eventMax
            , "Ptr", 0
            , "Ptr", RegisterCallback(this.WinEventHandler,,, &this)
            , "UInt", 0
            , "UInt", 0
        , "UInt", 0x0000|0x0002) ; OutOfContext|SkipOwnProcess
        Return True
    }

    Stop()
    {
        If (this.hWinEventHook == "")
        {
            Return False
        }
        DllCall("UnhookWinEvent", "Ptr", this.hWinEventHook)
        this.hWinEventHook := ""
        this.event := ""
        this.hwnd := ""
        this.idObject := ""
        this.idChild := ""
        this.dwEventThread := ""
        this.dwmsEventTime := ""
        Return True
    }

    SetEvent(events*)
    {
        If (events.MaxIndex() == "")
        {
            this.events := this.eventMin := this.eventMax := ""
            Return False
        }
        Else If (!IsArray(this.events))
        {
            this.events := []
        }
        For index, event In events
        {
            If (IsType(event, "Xdigit") && !InArray(this.events, event))
            {
                this.events.Push(event)
            }
        }
        If (!this.events.Length())
        {
            this.events := this.eventMin := this.eventMax := ""
            Return False
        }
        minIndex := this.events.MinIndex()
        maxIndex := this.events.MaxIndex()
        Sort(this.events, minIndex, maxIndex)
        this.eventMin := this.events[minIndex]
        this.eventMax := this.events[maxIndex]
        Return True
    }

    SetFunc(func := "")
    {
        If (!IsFuncObj(func) && !IsBoundFuncObj(func) && func != "")
        {
            Return False
        }
        this.func := func
        Return True
    }

    Clear()
    {
        this.Stop()
        this.SetEvent()
        this.SetFunc()
    }

    ; Private method
    WinEventHandler(event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
    {
        this := Object(A_EventInfo)
        If (!InArray(this.events, event))
        {
            Return
        }
        this.event := event
        this.hwnd := hwnd
        this.idObject := idObject
        this.idChild := idChild
        this.dwEventThread := dwEventThread
        this.dwmsEventTime := dwmsEventTime
        this.func.Call()
    }
}
