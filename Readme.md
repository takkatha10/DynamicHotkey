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

さらに、プラグインを追加することで機能を拡張できます。

### [ダウンロード](https://github.com/takkatha10/DynamicHotkey/releases)

## 使用方法

### 起動

- `DynamicHotkey.exe`もしくは[AutoHotkey](https://www.autohotkey.com)がインストール済みであれば`DynamicHotkey.ahk`から実行できます。
- Windowsの起動時に実行したい場合は、スタートアップに登録してください。  
管理者権限が必要な場合は、タスクスケジューラでタスクを作成し、`最上位の特権で実行する`にチェックを入れてください。

### ホットキーの作成･編集･削除

- メインウィンドウの`List`タブにある`Create`ボタンを押すと表示される作成ウィンドウに必要な情報を入力するとホットキーを作成できます。
- ホットキーを選択した状態で`Edit`ボタンを押すと表示される編集ウィンドウからホットキーを編集できます。
- ホットキーを選択した状態で`Copy`ボタンを押すと選択したキーを元にホットキーを作成できます。
- ホットキーを選択した状態で`Delete`ボタンを押すか右ダブルクリックするとホットキーを削除できます。
- `Delete all`ボタンを押すとすべてのホットキーを削除できます。

#### ホットキーの作成･編集の詳細

- 作成･編集ウィンドウには入力設定項目と出力設定項目があり、  
  出力には`Single press（単押し）`、`Double press（二度押し）`、`Long press（長押し）`の三種類を設定できます。  
  ※一部のキーは単押し以外に対応していません。
- 各項目にある`Bind`ボタンを押すと入力受付状態になり、その状態でキーかマウスのボタンを押すことでキーが設定されます。  
  ※ゲームパッドには対応していません。
- 各項目にキーは2個まで設定可能で、1個目のキーが設定されると2個目のキーが入力可能になります。  
  ただし、オプションの`Direct send`が指定されていると2個目のキーは設定出来なくなります。
- 1個目のキーのみ`Control`,`Shift`,`Alt`,`Windows`の各キーと組み合わせることができます。
- 入力設定項目のウィンドウ名入力欄にウィンドウ名か実行ファイル名入力欄に実行ファイル名が指定されていると、そのウィンドウに対して機能するホットキーを作成できます。
- ウィンドウ名に`a`か`A`を指定すると、アクティブなウィンドウに対して機能するホットキーを作成できます。
- 実行ファイル名にはフルパスも指定可能です。
- 実行ファイル名の末尾に`.exe`が含まれていない場合は、自動で追加されます。
- `Get window info`ボタンを押してから他のウィンドウをクリックすると、そのウィンドウのウィンドウ名とフルパスを取得します。
- 出力を`Run command`に切り替えると作業ディレクトリ指定してファイルを実行したりフォルダーやURLを開いたりできます。  
  ファイル名の後に半角スペースを開けて二重引用符で囲まれた文字列を入力することで引数を渡すことができます。  
  複数の引数を渡す場合は、引数ごとに半角スペースを開けて二重引用符で囲む必要があります。  
  ただし、2つ目以降の引数かつ文字列内に半角スペースが含まれていない場合は、二重引用符がなくても動作します。
  コマンド実行時すでに該当ファイルが開かれている場合は、そのウィンドウをアクティブにします。
- 出力を`Function`に切り替えるとプラグインで定義した関数を使用できます。  
  `Argument`にコンマ区切りで文字列を入力することでを引数を渡すこともできます。
- オプションの詳細
  - `Double press`  
    ホットキーの二度押しの受付時間
  - `Long press`  
    ホットキーの長押しの受付時間
  - `Wild card`  
    `Control`,`Shift`,`Alt`,`Windows`の各キーの状態にかかわらず入力キーが押されたらホットキーを出力します。  
    ※入力キーが2つ設定されている場合には対応していません。
  - `Pass through`  
    入力キーを無効化せずに出力します。
  - `Direct send`  
    ウィンドウに対して直接出力します。このオプションの有効時は2個目のキーとコマンドと通常の関数が設定できません。  
    さらに、マウスの座標モードも`Window`固定になります。
  - `Blind`  
    キーが出力される時に押されている修飾キーも出力します。
    ※`Direct send`が有効で出力キーにマウスが設定されている場合は使用不可。
  - `Toggle`  
    出力キーの状態が入力キーを押す度切り替わるようにします。  
    ※一部のキーは対応していません。
  - `Repeat`  
    出力キーを設定した間隔でリピートするようにします。  
    ※一部のキーは対応していません。
  - `Hold`  
    出力キーを設定した時間ホールドするようにします。  
    ※一部のキーは対応していません。
  - `X`  
    マウスのX座標  
    ※出力キーにマウスが設定されている時のみ使用可能。
  - `Y`  
    マウスのY座標  
    ※出力キーにマウスが設定されている時のみ使用可能。
  - `Coord mode`  
    マウスの座標モード  
    ※出力キーにマウスが設定されている時のみ使用可能。Direct sendの有効時はWindow固定。
    - `Window`  
      アクティブウィンドウの左上からの相対座標
    - `Client`  
      アクティブウィンドウのクライアント領域の左上からの相対座標
    - `Screen`  
      スクリーン上での絶対座標
    - `Relative`  
      現在のカーソル位置からの相対座標
  - `Run as admin`  
    管理者権限でコマンドを実行するようにします。

#### ホットキーの仕様

- キーの優先度はアクティブウィンドウ、アクティブではないウィンドウ、すべてのウィンドウの順番です。  
  ただし、新たに作成したキーはすでに作成されているキーよりも優先度が高くなるため、意図した優先度にならない場合があります。  
  その場合は、一度プロファイルへ保存した後に再起動するか、作成する順番を上記の優先度順で行う必要があります。
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

- ホットキーを選択した状態で`On/Off`ボタンを押すとホットキーの有効･無効を切り替えることができます。
- `Enable all`ボタンを押すとすべてのホットキーを有効できます。
- `Disable all`ボタンを押すとすべてのホットキーを無効できます。

### プロファイル･リンクデータについて

- プロファイルは有効にするホットキーの情報一覧を保存したものです。
- リンクデータはプロファイルとウィンドウを関連付け、条件に一致したプロファイルを読み込むためのものです。

### プロファイルの作成･削除･保存･読み込み･関連付け

- メインウィンドウの`Profile`タブにある`Create`ボタンを押すと表示される作成ウィンドウへプロファイル名を入力すると新規プロファイルを作成できます。
- プロファイルを選択した状態で`Rename`ボタンを押すと選択したプロファイルの名前を変更できます。
- プロファイルを選択した状態で`Copy`ボタンを押すと選択したプロファイルを元に新規プロファイルを作成できます。
- プロファイルを選択した状態で`Delete`ボタンを押すとプロファイルを削除できます。
- プロファイルを選択した状態で`Save`ボタンを押すと現在登録されているホットキーをプロファイルに上書き保存します。
- プロファイルを選択した状態で`Load`ボタンを押すかダブルクリックするとプロファイルを読み込みます。
- `Link`ボタンを押すとプロファイルとウィンドウを関連付けるリンクデータの設定ウィンドウを表示します。

#### プロファイルの仕様

- `Default`プロファイルは起動時に自動で読み込まれます。存在しない場合は、自動的に作成されます。
- `Default`プロファイルは`Delete`ボタンを押すとリセットできます。
- プロファイルは実行ファイルのあるディレクトリの`Profiles`フォルダーに指定した名前で保存されます。
- プロファイル名は重複できません。

### リンクデータの作成･編集･削除

- リンクデータウィンドウの`Create`ボタンを押すと表示される作成ウィンドウに必要なデータを入力すると新規リンクデータを作成できます。
- リンクデータを選択した状態で`Edit`ボタンを押すかダブルクリックすると表示される編集ウィンドウからデータを編集できます。
- リンクデータを選択した状態で`Copy`ボタンを押すと選択したリンクデータを元に新規リンクデータを作成できます。
- リンクデータを選択した状態で`Delete`ボタンを押すか右ダブルクリックするとデータを削除できます。
- ドラッグアンドドロップで読み込み優先度を変更できます。

#### リンクデータの作成･編集の詳細

- 作成･編集ウィンドウにはプロファイル名選択欄とウィンドウ名入力欄と実行ファイル名入力欄とモード選択欄があり、  
  指定ウィンドウが指定モード時に指定プロファイルを読み込むという情報を設定し、プロファイルとウィンドウを関連付けることができます。
- 実行ファイル名にはフルパスも指定可能です。
- 実行ファイル名の末尾に`.exe`が含まれていない場合は、自動で追加されます。
- `Get window info`ボタンを押してから他のウィンドウをクリックすると、そのウィンドウのウィンドウ名とフルパスを取得します。
- モードの詳細
  - `Active`  
    指定したウィンドウがアクティブな時、読み込むようにします。
  - `Exist`  
    指定したウィンドウが非アクティブな時でも、アクティブウィンドウへ関連付けられた他のプロファイルがなければ読み込むようにします。
  - `Absolute`  
    指定したウィンドウが存在する時、他のウィンドウへ関連付けられたプロファイルがあっても読み込むようにします。  
    他のウィンドウへ関連付けられたプロファイルが存在した場合は、`Absolute`に設定されたプロファイルと重複していない部分のみ読み込みます。

#### リンクデータの仕様

- リンクされたプロファイルは`Absolute`に関連付けられたプロファイル、`Active`に関連付けられたプロファイル、`Exist`に関連付けられたプロファイル、デフォルトプロファイルの順番で読み込まれます。
- 複数のプロファイルが読み込み条件に一致している時は、優先度順（リンクデータ一覧の上から順）で読み込まれます。
- ウィンドウ名と実行ファイル名は部分一致で検索されます。
- リンクデータは実行ファイルのあるディレクトリの`Config`フォルダーに`Link.dat`として保存されます。
- リンクデータが存在しない場合は、自動的に作成されます。

## 設定

- `Open a window at launch`  
  起動時にウィンドウを表示するかどうか
- `Keep a window always on top`  
  ウィンドウを常に最前面表示するかどうか
- `Auto profile switching`  
  リンクデータを元にプロファイルを自動で切り替えるかどうか
- `CapsLock state`  
  CapsLockの状態設定
- `NumLock state`  
  NumLockの状態設定
- `ScrollLock state`  
  ScrollLockの状態設定
- 設定ファイルは実行ファイルのあるディレクトリの`Config`フォルダーに`DynamicHotkey.ini`として保存されます。
- 設定ファイルが存在しない場合は、自動的に作成されます。

## 特殊ホットキー

キーボードのDキー、Hキー、Kキーを押しながら特定のキーを押すことでサスペンド（ホットキーの無効化）時でも入力可能なホットキーを設定しています。

- `D`+`H`+`K`+`O` - ウィンドウの表示
- `D`+`H`+`K`+`S` - サスペンド有効･無効
- `D`+`H`+`K`+`R` - 再起動
- `D`+`H`+`K`+`Q` - 終了

## プラグインについて

- 実行ファイルのあるディレクトリの`Plugins`フォルダーにAutoHotkeyスクリプトを追加すると起動時にロードされます。
- `Plugins`フォルダーが起動時に存在しない場合は、自動的に作成されます。
- プラグインはファイル名を関数名とした関数を定義するか、ファイル名をクラス名としたクラスを定義し、そこに変数や関数を実装していく形で作成します。
- クラス定義時、クラス内でのみ使用する関数は名前に`Private_`という接頭辞をつける必要があります。  
  それ以外の関数は実際に使用する関数とみなされます。
- `Direct send`で使用したい関数は名前に`Direct_`という接頭辞をつける必要があります。
- 接頭辞は先にある方のみ判定されるため、1つしか使用できません。
- ホットキーの作成、削除、有効化、無効化が行われた時にメッセージが発行されます。  
  (`HotkeyData.KM_NEW`,`HotkeyData.KM_DELETE`,`HotkeyData.KM_ENABLE`,`HotkeyData.KM_DISABLE`)  
  それらをプラグインのコンストラクターなどの関数内で`OnMessage`によって受け取る設定をすると、メッセージ発行時にプラグイン関数を実行できます。
- ホットキーの作成時、関数は新規のインスタンスになるため、キーが有効な間は変数などが保持されます。  
  別のキー間では別のインスタンスであるため、変数の共有などをする場合は、`global`変数にしたり、`static`変数を使ってクラス変数にしたり、インスタンスを同一にしたりする必要があります。
- その他スクリプト仕様などについては[AutoHotkey公式ドキュメント](https://www.autohotkey.com/docs/AutoHotkey.htm)を確認してください。

## ライセンス

[GPLv2](https://github.com/takkatha10/DynamicHotkey/blob/main/LICENSE)
