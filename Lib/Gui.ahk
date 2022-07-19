/*
	Gui
*/
; カーソルを終端まで移動する
SetSel(hWnd, isSelected := False)
{
	If (isSelected)
	{
		SendMessage, 0xB1, 0, -1,, % "ahk_id" hWnd
	}
	Else
	{
		SendMessage, 0xB1, -2, -1,, % "ahk_id" hWnd
	}
}

; カーソル位置までスクロールする
ScrollCaret(hWnd)
{
	SendMessage 0xB7, 0, 0,, % "ahk_id" hWnd
}

; リストビューの指定した列の幅を自動調節する
LV_AdjustCol(columnNumbers*)
{
	If (columnNumbers.MaxIndex() == "")
	{
		columns := LV_GetCount("Column")
		Loop, % columns
		{
			LV_ModifyCol(A_Index, "AutoHdr")
		}
	}
	Else
	{
		For index, columnNumber In columnNumbers
		{
			If (columnNumber > 0)
			{
				LV_ModifyCol(columnNumber, "AutoHdr")
			}
		}
	}
}

; リストビューの指定した列をソートする
LV_SortCol(isReverse := False, columnNumbers*)
{
	option := isReverse ? "SortDesc" : "Sort"
	max := columnNumbers.MaxIndex()
	If (max == "" || (max == 1 && columnNumbers[1] <= 0))
	{
		columns := LV_GetCount("Column")
		Loop, % columns
		{
			index := max == "" ? columns - A_Index + 1 : A_Index
			LV_ModifyCol(index, option)
		}
		Return
	}
	For index, columnNumber In columnNumbers
	{
		If (columnNumber > 0)
		{
			LV_ModifyCol(columnNumber, option)
		}
	}
}

; リストビューの指定した行の内容を返す
LV_GetTextRow(rowNumber)
{
	items := []
	columns := LV_GetCount("Column")
	Loop, % columns
	{
		LV_GetText(item, rowNumber ? rowNumber : LV_GetNext(), A_Index)
		items[A_Index] := item
	}
	Return items
}

; リストビューの内容をドラッグアンドドロップで入れ替える
LV_DragAndDrop(dragType := "D", delay := 100)
{
	row := A_EventInfo
	hitRow := ""
	items := LV_GetTextRow(row)
	buttonName := ""
	If (dragType == "D")
	{
		buttonName := "LButton"
	}
	Else If (dragType == "d")
	{
		buttonName := "RButton"
	}
	CoordMode, Mouse, Client
	MouseGetPos,,,, hListView, 2
	ControlGetPos,, listViewTop,, listViewHeight,, % "ahk_id" hListView
	listViewBottom := listViewTop + listViewHeight
	SendMessage, 0x101F, 0, 0,, % "ahk_id" hListView
	hHeader := ErrorLevel
	ControlGetPos,, headerTop,, headerHeight,, % "ahk_id" hHeader
	headerBottom := headerTop + headerHeight
	While (GetKeyState(buttonName, "P"))
	{
		MouseGetPos, mousePosX, mousePosY,,, 2
		VarSetCapacity(RECT, 16, 0)
		NumPut(0, RECT, 0, "Int")
		SendMessage, 0x100E, 0, &RECT,, % "ahk_id" hListView
		rowTop := NumGet(RECT, 4, "Int")
		rowBottom := NumGet(RECT, 12, "Int")
		rowHeight := rowBottom - rowTop
		rowPosY := mousePosY - listViewTop
		If (rowPosY < 0)
		{
			SendMessage, 0x1014, 0, -rowHeight,, % "ahk_id" hListView
			Sleep, delay
		}
		Else If (rowPosY > (listViewBottom - headerBottom))
		{
			SendMessage, 0x1014, 0, rowHeight,, % "ahk_id" hListView
			Sleep, delay
		}
		VarSetCapacity(LVHITTESTINFO, 24, 0)
		NumPut(mousePosX, LVHITTESTINFO, 0, "Int")
		NumPut(rowPosY + headerHeight, LVHITTESTINFO, 4, "Int")
		SendMessage, 0x1012, 0, &LVHITTESTINFO,, % "ahk_id" hListView
		hitRow := NumGet(LVHITTESTINFO, 12, "Int") + 1
		If (row != hitRow && hitRow > 0)
		{
			LV_Delete(row)
			LV_Insert(hitRow, "Select", items*)
			row := hitRow
		}
	}
	Return row
}
