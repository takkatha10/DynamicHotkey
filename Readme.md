<p align="center">
  <a href="https://github.com/takkatha10/DynamicHotkey/releases">
    <img src="https://user-images.githubusercontent.com/41630838/148679122-6d019aab-786e-40b6-90bb-f690d5e0bdc3.png" width="128"/>
  </a>
</p>

<h1 align="center">DynamicHotkey</h1>

DynamicHotkeyは、さまざまなアプリケーションで動作するホットキーを作成できるツールです。

- キー割り当ての変更
- フォルダー･URLを開く
- ファイル･アプリケーションの実行
- 特定のウィンドウ･アプリケーションでのみ動作するホットキーの作成
- ホットキーの設定を保存するプロファイルの作成
- ウィンドウ･アプリケーション毎に自動でプロファイルを切り替え

などのことができます。

### [ダウンロード](https://github.com/takkatha10/DynamicHotkey/releases)

## 使用方法

### 起動

- `DynamicHotkey.exe`もしくは[AutoHotkey](https://www.autohotkey.com)がインストール済みであれば`DynamicHotkey.ahk`から実行できます。
- Windowsの起動時に実行したい場合はスタートアップに登録してください。  
管理者権限が必要な場合はタスクスケジューラでタスクを作成し、`最上位の特権で実行する`にチェックを入れてください。

### ホットキーの作成･編集･削除

- メインウィンドウの`List`タブにある`Create`ボタンを押すと表示される作成ウィンドウに必要な情報を入力するとホットキーを作成できます。
- ホットキーを選択した状態で`Edit`ボタンを押すと表示される編集ウィンドウからホットキーを編集できます。
- ホットキーを選択した状態で`Delete`ボタンを押すか右ダブルクリックするとホットキーを削除できます。
- `Delete all`ボタンを押すとすべてのホットキーを削除できます。

#### ホットキーの作成･編集の詳細

- 作成･編集ウィンドウには入力設定項目と出力設定項目があり、  
  出力には`Single press（単押し）`、`Double press（二度押し）`、`Long press（長押し）`の三種類を設定できます。
- 各項目にある`Bind`ボタンを押すと入力受付状態になり、その状態でキーかマウスのボタンを押すことでキーが設定されます。  
  ※ゲームパッドには対応していません。
- 各項目にキーは2個まで設定可能で、1個目のキーが設定されると2個目のキーが入力可能になります。  
  ただし、オプションの`Direct send`が指定されていると2個目のキーは設定出来なくなります。
- 1個目のキーのみ`Control`,`Shift`,`Alt`,`Windows`の各キーと組み合わせることができます。
- 入力設定項目のウィンドウ名入力欄にウィンドウ名か実行ファイル名入力欄に実行ファイル名が指定されていると、そのウィンドウに対して機能するホットキーを作成できます。
- ウィンドウ名に`a`か`A`を指定すると、アクティブなウィンドウに対して機能するホットキーを作成できます。
- 実行ファイル名にはフルパスも指定可能です。
- 実行ファイル名の末尾に`.exe`が含まれていない場合は自動で追加されます。
- `Get window info`ボタンを押してから他のウィンドウをクリックすると、そのウィンドウのウィンドウ名とフルパスを取得します。
- 各種出力はキーからコマンドに切り替えることができます。  
  コマンドは作業ディレクトリ指定してファイルを実行したりフォルダーやURLを開いたりできます。  
  ファイル名の後に半角スペースを開けて二重引用符で囲まれた文字列を入力することで引数を渡すことができます。
- オプションの詳細
  - `Wild card` - `Control`,`Shift`,`Alt`,`Windows`の各キーの状態にかかわらず入力キーが押されたらホットキーを出力します。
  - `Pass through` - 入力キーを無効化せずに出力します。
  - `Direct send` - ウィンドウに対して直接出力します。このオプションの有効時は2個目のキーとコマンドが設定できません。
  - `Toggle` - 出力キーの状態が入力キーを押す度切り替わるようにします。
  - `Repeat` - 出力キーを設定した間隔でリピートするようにします。
  - `Hold` - 出力キーを設定した時間ホールドするようにします。
  - `Run as admin` - 管理者権限でコマンドを実行するようにします。

#### ホットキーの仕様

- キーの優先度はアクティブウィンドウ、アクティブではないウィンドウ、すべてのウィンドウの順番です。
- ウィンドウ名と実行ファイル名は部分一致で検索されます。
- `入力キー`+`ウィンドウ名`+`実行ファイル名`+`Direct sendの有無`の組み合わせが一致していない限り、同じ入力キーのホットキーは複数存在できます。
- 入力キーに`Control`,`Shift`,`Alt`,`Windows`のいずれかとオプションの`Pass through`のないホットキーは、1つ目の入力キーの元の機能は無効化されます。  
  そのため、最悪の場合操作不能になります。  
  そうなった時は末尾で紹介している特殊ホットキーでサスペンドか終了をしてから該当ホットキー･プロファイルの無効化や削除などを行ってください。
- 二度押しまたは長押しが有効なホットキーは、単押しがキーリピートされなくなります。
- 出力キーが`Alt`+`Tab`または`Shift`+`Alt`+`Tab`の場合、画面切り替えが一度しか実行されません。  
  ですが、入力キーに`Control`,`Shift`,`Alt`,`Windows`のいずれか1つ以上が含まれていて、  
  出力キーが単押しの`Alt`+`Tab`または`Shift`+`Alt`+`Tab`でオプションが設定されていない場合のみ、通常の画面切り替えと同じように使うことができます。

### ホットキーの有効･無効の切り替え

- ホットキーを選択した状態で`On/Off`ボタンを押すかダブルクリックするとホットキーの有効･無効を切り替えることができます。
- `Enable all`ボタンを押すとすべてのホットキーを有効できます。
- `Disable all`ボタンを押すとすべてのホットキーを無効できます。

### プロファイルの作成･削除･保存･読み込み･関連付け

- メインウィンドウの`Profile`タブにある`Create`ボタンを押すと表示される作成ウィンドウへプロファイル名を入力すると新規プロファイルを作成できます。
- プロファイルを選択した状態で`Delete`ボタンを押すとプロファイルを削除できます。
- プロファイルを選択した状態で`Save`ボタンを押すと現在登録されているホットキーをプロファイルに上書き保存します。
- プロファイルを選択した状態で`Load`ボタンを押すかダブルクリックするとプロファイルを読み込みます。
- `Link`ボタンを押すとプロファイルとウィンドウを関連付けるリンクデータの設定ウィンドウを表示します。

#### プロファイルの仕様

- `Default`プロファイルは起動時に自動で読み込まれます。存在しない場合は自動的に作成されます。
- `Default`プロファイルは`Delete`ボタンを押すとリセットできます。
- プロファイルは実行ファイルのあるディレクトリの`Profiles`フォルダーに指定した名前で保存されます。
- プロファイル名は重複できません。

### リンクデータの作成･編集･削除

- リンクデータウィンドウの`Create`ボタンを押すと表示される作成ウィンドウに必要なデータを入力すると新規リンクデータを作成できます。
- リンクデータを選択した状態で`Edit`ボタンを押すかダブルクリックすると表示される編集ウィンドウからデータを編集できます。
- リンクデータを選択した状態で`Delete`ボタンを押すか右ダブルクリックするとデータを削除できます。

#### リンクデータの作成･編集の詳細

- 作成･編集ウィンドウにはプロファイル名選択欄とウィンドウ名入力欄と実行ファイル名入力欄とモード選択欄があり、  
  指定ウィンドウが指定モード時に指定プロファイルを読み込むという情報を設定し、プロファイルとウィンドウを関連付けることができます。
- ウィンドウ名に`a`か`A`を指定すると、アクティブなウィンドウを指定できます。
- 実行ファイル名にはフルパスも指定可能です。
- 実行ファイル名の末尾に`.exe`が含まれていない場合は自動で追加されます。
- `Get window info`ボタンを押してから他のウィンドウをクリックすると、そのウィンドウのウィンドウ名とフルパスを取得します。

#### リンクデータの仕様

- リンクされたプロファイルはアクティブウィンドウに関連付けられたプロファイル、アクティブではないウィンドウに関連付けられたプロファイル、デフォルトプロファイルの順番で読み込まれます。
- ウィンドウ名と実行ファイル名は部分一致で検索されます。
- リンクデータは実行ファイルのあるディレクトリに`Link.dat`として保存されます。
- リンクデータが存在しない場合は自動的に作成されます。

## 設定

- `Open a window at launch` - 起動時にウィンドウを表示するかどうか
- `Keep a window always on top` - ウィンドウを最前面表示するかどうか
- `Auto switching profiles` - リンクデータを元にプロファイルを自動で切り替えるかどうか
- `Double press time` - ホットキーの二度押しの受付時間
- `Long press time` - ホットキーの長押しの受付時間
- 設定ファイルは実行ファイルのあるディレクトリに`DynamicHotkey.ini`として保存されます。
- 設定ファイルが存在しない場合は自動的に作成されます。

## 特殊ホットキー

キーボードのDキー、Hキー、Kキーを押しながら特定のキーを押すことでサスペンド（ホットキーの無効化）時でも入力可能なホットキーを設定しています。

- `D`+`H`+`K`+`O` - ウィンドウの表示
- `D`+`H`+`K`+`S` - サスペンド有効･無効
- `D`+`H`+`K`+`R` - 再起動
- `D`+`H`+`K`+`Q` - 終了

## ライセンス

[MIT](https://github.com/takkatha10/DynamicHotkey/blob/main/LICENSE)
