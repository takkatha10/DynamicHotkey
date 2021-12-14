/*
	Tip
*/
; ツールチップ表示
DisplayToolTip(str, displayTime := -1000)
{
    If (displayTime > 0)
    {
        displayTime := -displayTime
    }
    ToolTip, % str
    SetTimer, RemoveToolTip, % displayTime
}

; ツールチップ非表示
RemoveToolTip()
{
    SetTimer, RemoveToolTip, Delete
    ToolTip
}

; トレイチップ表示
DisplayTrayTip(str, title := "", options := 0, displayTime := -7000)
{
    If (displayTime > 0)
    {
        displayTime := -displayTime
    }
    TrayTip, % title, % str,, % options
    SetTimer, RemoveTrayTip, % displayTime
}

; トレイチップ非表示
RemoveTrayTip()
{
    SetTimer, RemoveTrayTip, Delete
    TrayTip
    Menu, Tray, NoIcon
    Menu, Tray, Icon
}
