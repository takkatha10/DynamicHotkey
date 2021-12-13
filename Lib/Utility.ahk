/*
	Utility
*/
; 変数の交換
Swap(ByRef var1, ByRef var2)
{
    temp := var1
    var1 := var2
    var2 := temp
}

; 数値を範囲内に収める
Clamp(var, min := "", max := "")
{
    If ((var < min) && (min != ""))
    {
        Return min
    }
    If ((var > max) && (max != ""))
    {
        Return max
    }
    Return var
}

; 変数の型をチェックする
/*
	integer	小数点を含まない10進数値や、 0xで始まる16進数値。
			前後に半角スペースを含むものもや+符号で始まるものも可能。
	float	小数点を含む10進数値。
			前後に半角スペースを含むものや、+符号で始まるもの、小数点から始まるものも可能。
	number	integerかfloatに該当するもの。
	digit	0...9のみで構成される数字。前後の空白も許される。
	xdigit	0...9a...fで構成される16進数値。大文字でも小文字でもよい。前後の空白も許される。
	alpha	a...zA...Zからなるアルファベット列。
	upper	A...Zからなる大文字アルファベット列。
	lower	a...zからなる小文字アルファベット列。
	alnum	a...zA...z0...9の英数字列。
	space	半角スペースかTab文字、改行(CRやLF)などの空白文字のみ。
	time	YYYYMMDDHH24MISSのタイムスタンプ形式として正しい14桁までの数字列。
			2004のような途中までの値でも可能。
			MMの部分が01..12の範囲でないなど日付時刻として誤っているものは不可。
			タイムスタンプとみなされる範囲は、1601年から9999年まで。
			time以外の形式は、内容が空でも一致とみなされる。
*/
IsType(var, varType)
{
    If var Is % varType
    {
        Return True
    }
    Return False
}
