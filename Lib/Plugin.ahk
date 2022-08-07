/*
	Plugin
	# Required files
	# String.ahk
	# Utility.ahk
*/
; プラグインをチェックし、変更があれば読み込み用スクリプトを更新する
CheckPlugins(pluginDir, pluginFile)
{
	If (pluginDir == "" || pluginFile == "")
	{
		Return False
	}
	If (!FileExist(pluginDir))
	{
		FileCreateDir, % pluginDir
	}
	plugins := ""
	writeDir := ""
	If (InStr(pluginDir, A_ScriptDir))
	{
		writeDir := StrReplace(pluginDir, A_ScriptDir, "%A_ScriptDir%")
	}
	Else
	{
		writeDir := pluginDir
	}
	Loop, % pluginDir "\*.ahk"
	{
		plugins .= "#Include *i " writeDir "\" A_LoopFileName "`n"
	}
	file := FileOpen(pluginFile, "r `n", "UTF-8")
	If (IsFileObj(file))
	{
		pluginsData := file.Read(file.Length)
		file.Close()
		If (pluginsData == plugins)
		{
			Return False
		}
		Else If (plugins == "")
		{
			file := FileOpen(pluginFile, "w `n", "UTF-8")
			file.Close()
			Return True
		}
	}
	file := FileOpen(pluginFile, "w `n", "UTF-8")
	If (!IsFileObj(file))
	{
		Return False
	}
	file.Write(plugins)
	file.Close()
	Return True
}

; 現在有効なプラグインの名前一覧を返す
GetPluginNames(pluginFile)
{
	file := FileOpen(pluginFile, "r", "UTF-8")
	If (!IsFileObj(file))
	{
		Return False
	}
	pluginNames := []
	While (!file.AtEOF)
	{
		If (line := file.ReadLine())
		{
			line := StrReplace(line, "`r`n")
			matchPos := InStr(line, "\",, 0)
			line := matchPos ? SubStr(line, matchPos + 1) : SubStr(line, 13)
			If (SubStr(line, -3) == ".ahk")
			{
				pluginNames.Push(StrReplace(line, ".ahk"))
			}
		}
	}
	file.Close()
	Return pluginNames.Length() ? pluginNames : False
}

; プラグインの関数一覧を返す
GetPluginFuncNames(pluginNames)
{
	funcNames := []
	For index, plugin In pluginNames
	{
		If (IsFunc(plugin))
		{
			funcNames.Push(plugin)
		}
		Else If (IsClassName(plugin))
		{
			For key, value In %plugin%
			{
				If (!StrContains(key, "__", "Private_") && IsFuncObj(value))
				{
					funcNames.Push(value.Name)
				}
			}
		}
	}
	Return funcNames.Length() ? funcNames : False
}

; プラグインの関数オブジェクトを返す
GetPluginFunc(funcName, args)
{
	If (!IsFunc(funcName))
	{
		Return False
	}
	func := Func(funcName)
	argCnt := args.Length()
	If (matchPos := InStr(funcName, "."))
	{
		className := SubStr(funcName, 1, matchPos - 1)
		funcName := SubStr(funcName, matchPos + 1)
		Return (argCnt && (argCnt >= (func.MinParams - 1)) && (func.MaxParams || func.IsVariadic)) ? ObjBindMethod(New %className%(), funcName, args*) : ObjBindMethod(New %className%(), funcName)
	}
	Return (argCnt && (argCnt >= func.MinParams) && (func.MaxParams || func.IsVariadic)) ? func.Bind(args*) : func
}
