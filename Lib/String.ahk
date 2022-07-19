/*
	String
*/
; 列挙文字列を一つの文字列に変換
ToMatches(matchList*)
{
	matches := ""
	For index, str In matchList
	{
		matches .= matches ? "|" "\Q" str "\E" : "\Q" str "\E"
	}
	Return matches
}

; 文字列と列挙文字列内のいずれかが一致しているかどうかを返す
StrIn(str, matchList*)
{
	Return RegExMatch(str, "i)\A(" ToMatches(matchList*) ")\z")
}

; 文字列に列挙文字列内のいずれかが含まれているかどうかを返す
StrContains(str, matchList*)
{
	Return RegExMatch(str, "i)(" ToMatches(matchList*) ")")
}

; 文字列の正規表現に一致した箇所以降から検索文字列を削除する
RegExRemoveOnwards(str, search, regEx)
{
	matchPos := RegExMatch(str, regEx)
	Return matchPos ? SubStr(str, 1, matchPos) StrReplace(SubStr(str, matchPos + 1), search) : str
}

; 文字列を数値のみにする正規表現
RegExNumber(str, isSigned := True)
{
	replacedStr := isSigned ? RegExReplace(str, "[^\-\d\.]") : RegExReplace(str, "[^\d\.]")
	replacedStr := StrReplace(replacedStr, A_Space)
	replacedStr := StrReplace(replacedStr, "　")
	If (StrLen(str) == 1)
	{
		replacedStr := StrReplace(replacedStr, ".")
	}
	Else
	{
		replacedStr := RegExRemoveOnwards(replacedStr, "-", "\S.*\-")
		replacedStr := RegExRemoveOnwards(replacedStr, ".", "\-*\.")
		replacedStr := RegExRemoveOnwards(replacedStr, ".", "\..*\.")
	}
	Return replacedStr
}
