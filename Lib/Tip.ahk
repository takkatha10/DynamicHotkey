/*
	Tip
*/
; ツールチップ表示
DisplayToolTip(str, x := "", y := "", coord := "Window", displayTime := 1000)
{
	CoordMode, ToolTip, % coord
	ToolTip, % str, x, y
	SetTimer, RemoveToolTip, % displayTime
}

; ツールチップ非表示
RemoveToolTip()
{
	SetTimer, RemoveToolTip, Delete
	ToolTip
}

; トレイチップ表示
DisplayTrayTip(str, title := "", options := 0, displayTime := 7000)
{
	If (isHidden := A_IconHidden)
	{
		Menu, Tray, Icon
	}
	TrayTip, % title, % str,, % options
	If (displayTime)
	{
		If (isHidden)
		{
			SetTimer, RemoveTrayTipHide, % displayTime
		}
		Else
		{
			SetTimer, RemoveTrayTip, % displayTime
		}
	}
}

; トレイチップ非表示（トレイアイコン表示）
RemoveTrayTip()
{
	SetTimer, RemoveTrayTip, Delete
	TrayTip
	Menu, Tray, NoIcon
	Menu, Tray, Icon
}

; トレイチップ非表示（トレイアイコン非表示）
RemoveTrayTipHide()
{
	SetTimer, RemoveTrayTip, Delete
	TrayTip
	Menu, Tray, NoIcon
}
