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

; 比較
Compare(a, b, comparator := "equal")
{
    Switch comparator
    {
        Case "case insensitive equal", "insensitive": Return a = b
        Case "equal": Return a == b
        Case "not equal", "not": Return a != b
        Case "less": Return a < b
        Case "less equal": Return a <= b
        Case "greater": Return a > b
        Case "greater equal": Return a >= b
        Default: Return "error"
    }
}

; 値の型を返す
/*
	Integer		小数点を含まない10進数値や、 0xで始まる16進数値。
				前後に半角スペースを含むものもや+符号で始まるものも可能。
	Float		小数点を含む10進数値。
				前後に半角スペースを含むものや、+符号で始まるもの、小数点から始まるものも可能。
	String		上記に該当しない文字列。
	Object		下記に該当しないオブジェクト。
	Array		配列オブジェクト。
	Associative	連想配列オブジェクト。
	Class		クラスオブジェクト。クラス名を返す。
	Exception	Exceptionオブジェクト。
	Enumerator	Enumeratorオブジェクト。
	File		Fileオブジェクト。
	Func		Funcオブジェクト。
	BoundFunc	BoundFuncオブジェクト。
	Match		Matchオブジェクト。
*/
TypeOf(value)
{
    static types := ["Integer", "Float", "String", "Array", "Exception", "Associative", "Class", "Enumerator", "File", "Func", "BoundFunc", "Match", "Object"]
    For index, varType In types
    {
        If (IsType(value, varType))
        {
            Return varType == "Class" ? obj.__Class : varType
        }
    }
}

; 値が指定の型かチェックする
/*
	Integer		小数点を含まない10進数値や、 0xで始まる16進数値。
				前後に半角スペースを含むものもや+符号で始まるものも可能。
	Float		小数点を含む10進数値。
				前後に半角スペースを含むものや、+符号で始まるもの、小数点から始まるものも可能。
	Number		IntegerかFloatに該当するもの。
	Digit		0...9のみで構成される数字。前後の空白も許される。
	Xdigit		0...9a...fで構成される16進数値。大文字でも小文字でもよい。前後の空白も許される。
	Alpha		a...zA...Zからなるアルファベット列。
	Upper		A...Zからなる大文字アルファベット列。
	Lower		a...zからなる小文字アルファベット列。
	Alnum		a...zA...z0...9の英数字列。
	Space		半角スペースかTab文字、改行(CRやLF)などの空白文字のみ。
	Time		YYYYMMDDHH24MISSのタイムスタンプ形式として正しい14桁までの数字列。
				2004のような途中までの値でも可能。
				MMの部分が01..12の範囲でないなど日付時刻として誤っているものは不可。
				タイムスタンプとみなされる範囲は、1601年から9999年まで。
				time以外の形式は、内容が空でも一致とみなされる。
	String		Numberに該当しない文字列。
	Function	存在する関数の名前。
	Label		存在するラベルの名前。
	Object		オブジェクト。
	Array		配列オブジェクト。
	Associative	連想配列オブジェクト。
	Class		クラスオブジェクト。クラス名を指定することも可能。
	Exception	Exceptionオブジェクト。
	Enumerator	Enumeratorオブジェクト。
	File		Fileオブジェクト。
	Func		Funcオブジェクト。
	BoundFunc	BoundFuncオブジェクト。
	Match		Matchオブジェクト。
*/
IsType(value, varType, className := "")
{
    Switch varType
    {
        Case "String": Return IsString(value)
        Case "Function": Return IsFunc(value)
        Case "Label": Return IsLabel(value)
        Case "Object": Return IsObject(value)
        Case "Array": Return IsArray(value)
        Case "Associative": Return IsAssociative(value)
        Case "Class": Return IsClass(value, className)
        Case "Exception": Return IsExceptionObj(value)
        Case "Enumerator": Return IsEnumeratorObj(value)
        Case "File": Return IsFileObj(value)
        Case "Func": Return IsFuncObj(value)
        Case "BoundFunc": Return IsBoundFuncObj(value)
        Case "Match": Return IsMatchObj(value)
        Default: Return IsVarType(value, varType)
    }
}

; If var is typeのラッパー
IsVarType(value, varType)
{
    If value Is % varType
    {
        Return True
    }
    Return False
}

; 値が文字列かどうかをチェックする
IsString(value)
{
    Return !IsObject(value) && (ObjGetCapacity([value + 0], 1) != "")
}

; オブジェクトが配列かどうかをチェックする
IsArray(obj)
{
    Return (obj.SetCapacity(0) != "") && (obj.SetCapacity(0) == (obj.MaxIndex() - obj.MinIndex() + 1))
}

; オブジェクトが連想配列かどうかをチェックする
IsAssociative(obj)
{
    Return (obj.SetCapacity(0) != "") && !obj.MaxIndex() && !IsObject(obj.base)
}

; オブジェクトがクラスかどうかをチェックする
IsClass(obj, className := "")
{
    Return className != "" ? (IsObject(obj.base) && (obj.__Class = className)) : IsObject(obj.base)
}

; オブジェクトがExceptionオブジェクトかどうかをチェックする
IsExceptionObj(obj)
{
    Switch obj.SetCapacity(0)
    {
        Case 3: Return obj.HasKey("Message") && obj.HasKey("File") && obj.HasKey("Line")
        Case 4: Return obj.HasKey("Message") && obj.HasKey("What") && obj.HasKey("File") && obj.HasKey("Line")
        Case 5: Return obj.HasKey("Message") && obj.HasKey("What") && obj.HasKey("Extra") && obj.HasKey("File") && obj.HasKey("Line")
        Default: Return False
    }
}

; オブジェクトがEnumeratorオブジェクトかどうかをチェックする
IsEnumeratorObj(obj)
{
    static enumeratorObj := Object()._NewEnum()
    Return NumGet(&enumeratorObj) == NumGet(&obj)
}

; オブジェクトがFileオブジェクトかどうかをチェックする
IsFileObj(obj)
{
    static fileObj := FileOpen("NUL", "r"), cache := fileObj.Close()
    Return NumGet(&fileObj) == NumGet(&obj)
}

; オブジェクトがFuncオブジェクトかどうかをチェックする
IsFuncObj(obj)
{
    static funcObj := Func("IsFuncObj")
    Return NumGet(&funcObj) == NumGet(&obj)
}

; オブジェクトがBoundFuncオブジェクトかどうかをチェックする
IsBoundFuncObj(obj)
{
    static boundFuncObj := Func("IsBoundFuncObj").Bind()
    Return NumGet(&boundFuncObj) == NumGet(&obj)
}

; オブジェクトがMatchオブジェクトかどうかをチェックする
IsMatchObj(obj)
{
    static matchObj, cache := RegExMatch("", "O)", matchObj)
    Return NumGet(&matchObj) == NumGet(&obj)
}

; アプリケーションの起動
Run(file, arguments := "", directory := "", isRunAsAdmin := False)
{
    file := !InStr(file, Chr(34)) ? Chr(34) file Chr(34) : file
    arguments := (arguments != "" && !InStr(arguments, Chr(34))) ? A_Space Chr(34) arguments Chr(34) : arguments
    If (A_IsAdmin && !isRunAsAdmin)
    {
        Return ShellRun(file, arguments, directory)
    }
    file := isRunAsAdmin ? "*RunAs" A_Space file : file
    arguments := arguments != "" ? A_Space arguments : ""
    Run % file arguments, % directory, UseErrorLevel, PID
    Return PID
}

; https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createprocesswithtokenw
ShellRun(file, arguments := "", directory := "")
{
    DllCall("GetWindowThreadProcessId", "Ptr", DllCall("GetShellWindow"), "UInt*", shellPID)
    hShellProcess := DllCall("OpenProcess", "UInt", 0x0400, "Int", False, "UInt", shellPID)
    DllCall("Advapi32\OpenProcessToken", "Ptr", hShellProcess, "Int", 2, "Ptr*", hShellProcessToken)
    DllCall("Advapi32\DuplicateTokenEx", "Ptr", hShellProcessToken, "Int", 395, "Ptr", 0, "Int", 2, "Int", 1, "Ptr*", hPrimaryToken)
    cbSize := (A_PtrSize == 4 ? 68 : 104)
    VarSetCapacity(STARTUPINFO, cbSize)
    NumPut(cbSize, STARTUPINFO)
    VarSetCapacity(PROCESS_INFORMATION, (A_PtrSize == 4 ? 16 : 24))
    DllCall("Advapi32\CreateProcessWithTokenW", "Ptr", hPrimaryToken, "UInt", 0, "Ptr", 0, "WStr", file arguments, "Int", 0, "Ptr", 0, (directory != "" ? "WStr" : "Ptr"), (directory != "" ? directory : 0), "Str", STARTUPINFO, "Str", PROCESS_INFORMATION)
    PID := NumGet(PROCESS_INFORMATION, (A_PtrSize << 1), "UInt")
    DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, 0))
    DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize))
    DllCall("CloseHandle", "Ptr", hPrimaryToken)
    DllCall("CloseHandle", "Ptr", hShellProcessToken)
    DllCall("CloseHandle", "Ptr", hShellProcess)
    Return PID
}

; プロセス名と引数からプロセスIDを返す
GetPID(pName, arguments := "")
{
    For item In ComObjGet("winmgmts:").ExecQuery("Select * From Win32_Process Where Name = " "'" SubStr(pName, InStr(pName, "\",, 0) + 1) "'")
    {
        If (Trim(arguments, Chr(34)) = Trim(StrReplace(StrReplace(item.CommandLine, Chr(34)), pName,,, 1), A_Space))
        {
            Return item.ProcessID
        }
    }
    Return False
}
