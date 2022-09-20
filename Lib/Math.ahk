/*
	Math
	# Required file
	# Utility.ahk
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
	Return (dotPos := InStr(num, ".")) ? ((decimal := SubStr(num, dotPos + 1)) ? Format("{:." StrLen(RTrim(decimal, "0")) "f}", num) : Format("{:d}", num)) : Format("{:d}", num)
}

; 数式を評価する
EvalNumber(num)
{
	num := RegExReplace(num, "[^\+\-\*\/\d\.]")
	RegExMatch(num, "(.*)(\+|\-)(.*)", n)
	If (n != "" && !IsType(SubStr(n, 0), "Number"))
	{
		Return num
	}
	If (n1 != "" && !IsType((e1 := SubStr(n1, 0)), "Number") && ((e2 := SubStr(n2, 0)) == "-"))
	{
		n1 := SubStr(n1, 1, -1)
		n2 := e1
		n3 := e2 n3
	}
	If (n1 != "" && !IsType(SubStr(n1, 0), "Number"))
	{
		Return num
	}
	tempFormatFloat := A_FormatFloat
	SetFormat, Float, % "0.15"
	Switch n2
	{
		Case "+": num := FormatNumber(EvalNumber(n1)) + FormatNumber(EvalNumber(n3))
		Case "-": num := FormatNumber(EvalNumber(n1)) - FormatNumber(EvalNumber(n3))
	}
	RegExMatch(num, "(.*)(\*|\/)(.*)", n)
	Switch n2
	{
		Case "*": num := FormatNumber(EvalNumber(n1)) * FormatNumber(EvalNumber(n3))
		Case "/": num := FormatNumber(EvalNumber(n1)) / FormatNumber(EvalNumber(n3))
	}
	SetFormat, Float, % tempFormatFloat
	Return InStr(num, ".") ? RTrim(FormatNumber(num), "0") : num
}
