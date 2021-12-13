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
