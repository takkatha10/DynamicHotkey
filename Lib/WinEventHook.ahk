/*
    WinEventHook
	# Required file
	# Utility.ahk
    # Event constants
    # 0x8012 : EVENT_OBJECT_ACCELERATORCHANGE
    # 0x8017 : EVENT_OBJECT_CLOAKED
    # 0x8015 : EVENT_OBJECT_CONTENTSCROLLED
    # 0x8000 : EVENT_OBJECT_CREATE
    # 0x8011 : EVENT_OBJECT_DEFACTIONCHANGE
    # 0x800D : EVENT_OBJECT_DESCRIPTIONCHANGE
    # 0x8001 : EVENT_OBJECT_DESTROY
    # 0x8021 : EVENT_OBJECT_DRAGSTART
    # 0x8022 : EVENT_OBJECT_DRAGCANCEL
    # 0x8023 : EVENT_OBJECT_DRAGCOMPLETE
    # 0x8024 : EVENT_OBJECT_DRAGENTER
    # 0x8025 : EVENT_OBJECT_DRAGLEAVE
    # 0x8026 : EVENT_OBJECT_DRAGDROPPED
    # 0x80FF : EVENT_OBJECT_END
    # 0x8005 : EVENT_OBJECT_FOCUS
    # 0x8010 : EVENT_OBJECT_HELPCHANGE
    # 0x8003 : EVENT_OBJECT_HIDE
    # 0x8020 : EVENT_OBJECT_HOSTEDOBJECTSINVALIDATED
    # 0x8028 : EVENT_OBJECT_IME_HIDE
    # 0x8027 : EVENT_OBJECT_IME_SHOW
    # 0x8029 : EVENT_OBJECT_IME_CHANGE
    # 0x8013 : EVENT_OBJECT_INVOKED
    # 0x8019 : EVENT_OBJECT_LIVEREGIONCHANGED
    # 0x800B : EVENT_OBJECT_LOCATIONCHANGE
    # 0x800C : EVENT_OBJECT_NAMECHANGE
    # 0x800F : EVENT_OBJECT_PARENTCHANGE
    # 0x8004 : EVENT_OBJECT_REORDER
    # 0x8006 : EVENT_OBJECT_SELECTION
    # 0x8007 : EVENT_OBJECT_SELECTIONADD
    # 0x8008 : EVENT_OBJECT_SELECTIONREMOVE
    # 0x8009 : EVENT_OBJECT_SELECTIONWITHIN
    # 0x8002 : EVENT_OBJECT_SHOW
    # 0x800A : EVENT_OBJECT_STATECHANGE
    # 0x8030 : EVENT_OBJECT_TEXTEDIT_CONVERSIONTARGETCHANGED
    # 0x8014 : EVENT_OBJECT_TEXTSELECTIONCHANGED
    # 0x8018 : EVENT_OBJECT_UNCLOAKED
    # 0x800E : EVENT_OBJECT_VALUECHANGE
    # 0x0002 : EVENT_SYSTEM_ALERT
    # 0x8016 : EVENT_SYSTEM_ARRANGMENTPREVIEW
    # 0x0009 : EVENT_SYSTEM_CAPTUREEND
    # 0x0008 : EVENT_SYSTEM_CAPTURESTART
    # 0x000D : EVENT_SYSTEM_CONTEXTHELPEND
    # 0x000C : EVENT_SYSTEM_CONTEXTHELPSTART
    # 0x0020 : EVENT_SYSTEM_DESKTOPSWITCH
    # 0x0011 : EVENT_SYSTEM_DIALOGEND
    # 0x0010 : EVENT_SYSTEM_DIALOGSTART
    # 0x000F : EVENT_SYSTEM_DRAGDROPEND
    # 0x000E : EVENT_SYSTEM_DRAGDROPSTART
    # 0x00FF : EVENT_SYSTEM_END
    # 0x0003 : EVENT_SYSTEM_FOREGROUND
    # 0x0007 : EVENT_SYSTEM_MENUPOPUPEND
    # 0x0006 : EVENT_SYSTEM_MENUPOPUPSTART
    # 0x0005 : EVENT_SYSTEM_MENUEND
    # 0x0004 : EVENT_SYSTEM_MENUSTART
    # 0x0017 : EVENT_SYSTEM_MINIMIZEEND
    # 0x0016 : EVENT_SYSTEM_MINIMIZESTART
    # 0x000B : EVENT_SYSTEM_MOVESIZEEND
    # 0x000A : EVENT_SYSTEM_MOVESIZESTART
    # 0x0013 : EVENT_SYSTEM_SCROLLINGEND
    # 0x0012 : EVENT_SYSTEM_SCROLLINGSTART
    # 0x0001 : EVENT_SYSTEM_SOUND
    # 0x0015 : EVENT_SYSTEM_SWITCHEND
    # 0x0014 : EVENT_SYSTEM_SWITCHSTART
*/
class WinEventHook
{
    ; Variables
    hWinEventHook := ""
    event := ""
    hwnd := ""
    idObject := ""
    idChild := ""
    dwEventThread := ""
    dwmsEventTime := ""
    eventMin := ""
    eventMax := ""
    func := ""

    ; Constructor
    __New(eventMin := 0x0003, eventMax := 0x0003, func := "")
    {
        this.SetEvent(eventMin, eventMax)
        this.SetFunc(func)
    }

    ; Destructor
    __Delete()
    {
        MsgBox,,, Hook Deleted, 3
    }

    ; Public methods
    CheckStart()
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

    CheckStop()
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

    SetEvent(eventMin := "", eventMax := "")
    {
        If (!IsType(eventMin, "Xdigit"))
        {
            Return False
        }
        If (!IsType(eventMax, "Xdigit"))
        {
            Return False
        }
        this.eventMin := eventMin
        this.eventMax := eventMax
        Return True
    }

    SetFunc(func := "")
    {
        If (!IsObject(func) && func != "")
        {
            Return False
        }
        this.func := func
        Return True
    }

    Clear()
    {
        this.CheckStop()
        this.SetEvent()
        this.SetFunc()
    }

    ; Private method
    WinEventHandler(event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime)
    {
        this := Object(A_EventInfo)
        this.event := event
        this.hwnd := hwnd
        this.idObject := idObject
        this.idChild := idChild
        this.dwEventThread := dwEventThread
        this.dwmsEventTime := dwmsEventTime
        this.func.Call()
    }
}
