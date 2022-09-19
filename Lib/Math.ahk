/*
	Math
*/
; 2を底とする対数を求める
Log2(num)
{
	Return Ln(num) / 0.6931471805599453
}

; 数値の小数点以下桁数を求める
DecimalCount(num)
{
	Return (dotPos := InStr(num, ".")) ? StrLen(SubStr(num, dotPos + 1)) : 0
}

