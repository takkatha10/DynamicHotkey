/*
	DynamicHotkey
*/
/*
	Auto-execute section
*/
; 初期設定
#Persistent															; 常駐化
#SingleInstance Ignore												; 複数プロセス禁止
#MaxThreads 255														; 最大スレッド数を255に設定
#NoEnv																; 環境変数無視
#InstallKeybdHook													; キーボードフック適応
#InstallMouseHook													; マウスフック適応
#UseHook															; 常にフックを使用
SetBatchLines, -1													; 自動Sleepなし
ListLines, Off														; スクリプトの実行履歴を取らない
SendMode, Input														; SendInput関数を使用
DetectHiddenWindows, On												; 非表示になっているウィンドウを検出対象にし、非アクティブでもキーを送れるようにする
SetTitleMatchMode, 2												; ウィンドウタイトルを部分一致で検索する
FileEncoding, UTF-8													; ファイルエンコーディングにUTF-8を使用する
Menu, Tray, Icon, % A_ScriptDir "\Resources\DynamicHotkey.ico",, 1	; タスクトレイアイコンの設定
Menu, Tray, Tip, DynamicHotkey										; タスクトレイアイコンのツールチップを設定
Menu, Tray, Click, 1												; メニューを開くために必要なクリック数を設定
Menu, Tray, NoStandard												; 標準メニュー項目を削除
Menu, Tray, Add, Open												; 項目オープンを追加
Menu, Tray, Default, Open											; 項目オープンをデフォルト項目に設定
Menu, Tray, Add, Suspend											; 項目サスペンドを追加
Menu, Tray, Add, Reload												; 項目リロードを追加
Menu, Tray, Add, Quit												; 項目終了を追加

; インクルード
#Include <Tip>
#Include <String>
#Include <Utility>
#Include <Math>
#Include <Array>
#Include <Enum>
#Include <WinEventHook>
#Include <Gui>
#Include <Hotkey>

; グローバル変数
dhk := New DynamicHotkey()

Return
; End of auto-execute section

/*
	Labels
*/
; メインウィンドウ表示
Open:
    dhk.GuiOpen()
Return

; ホットキー有効･無効
Suspend:
    Suspend
    If (A_Issuspended)
    {
        Menu, Tray, Icon, % A_ScriptDir "\Resources\DynamicHotkey_Suspend.ico"
        Menu, Tray, Check, Suspend
        DisplayToolTip("Suspend")
    }
    Else
    {
        Menu, Tray, Icon, % A_ScriptDir "\Resources\DynamicHotkey.ico"
        Menu, Tray, Uncheck, Suspend
        DisplayToolTip("Resume")
    }
Return

; 再読み込み
Reload:
    dhk.Quit()
    dhk := ""
    Reload
Return

; 終了
Quit:
    dhk.Quit()
    dhk := ""
ExitApp

; サスペンド時でも入力可能なホットキー
#If GetKeyState("d", "P") && GetKeyState("h", "P") && GetKeyState("k", "P")

; メインウィンドウ表示
o::
    Suspend, Permit
    Goto, Open
Return

; ホットキー有効･無効
s::
    Suspend, Permit
    Goto, Suspend
Return

; 再読み込み
r::
    Suspend, Permit
    Goto, Reload
Return

; 終了
q::
    Suspend, Permit
    Goto, Quit
Return

#If

; End of labels
