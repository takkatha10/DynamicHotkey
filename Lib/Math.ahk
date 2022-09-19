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

; 数値を小数点以下に合わせて整形する
FormatNumber(num)
{
	Return (dotPos := InStr(num, ".")) ? ((decimal := SubStr(num, dotPos + 1)) ? Format("{:." StrLen(decimal) "f}", num) : Format("{:d}", num)) : Format("{:d}", num)
}

