■DynamicHotkey
DynamicHotkeyは、さまざまなアプリケーションで動作するホットキーを作成できるツールです。
・キー割り当ての変更
・フォルダーー･URLを開く
・ファイル･アプリケーションの実行
・特定のウィンドウ･アプリケーションでのみ動作するホットキーの作成
・ホットキーの設定を保存するプロファイルの作成
・ウィンドウ･アプリケーション毎に自動でプロファイルを切り替え
などのことができます。
さらに、プラグインを追加することで機能を拡張できます。

■使用方法
○起動
・DynamicHotkey.exeもしくはAutoHotkeyがインストール済みであればDynamicHotkey.ahkから実行できます。
・Windowsの起動時に実行したい場合は、スタートアップに登録してください。
  管理者権限が必要な場合は、タスクスケジューラでタスクを作成し、最上位の特権で実行するにチェックを入れてください。

○ホットキーの作成･編集･削除
・メインウィンドウのListタブにあるCreateボタンを押すと表示される作成ウィンドウに必要な情報を入力することでホットキーを作成できます。
・ホットキーを選択した状態でEditボタンを押すと表示される編集ウィンドウからホットキーを編集できます。
・ホットキーを選択した状態でCopyボタンを押すと選択したキーを元にホットキーを作成できます。
・ホットキーを選択した状態でDeleteボタンを押すか右ダブルクリックするとホットキーを削除できます。
・Delete allボタンを押すとすべてのホットキーを削除できます。

○ホットキーの作成･編集の詳細
・作成･編集ウィンドウには入力設定項目と出力設定項目があり、
  出力にはSingle press（単押し）、Double press（二度押し）、Long press（長押し）の三種類を設定できます。
  ※一部のキーは単押し以外に対応していません。
・各項目にあるBindボタンを押すと入力受付状態になり、その状態でキーかマウスのボタンを押すことでキーが設定されます。
  ※ゲームパッドには対応していません。
・各項目にキーは2個まで設定可能で、1個目のキーが設定されると2個目のキーが入力可能になります。
  ただし、オプションのDirect sendが指定されていると2個目のキーは設定できなくなります。
・1個目のキーのみControl,Shift,Alt,Windowsの各キーと組み合わせることができます。
・入力設定項目のウィンドウ名入力欄にウィンドウ名か実行ファイル名入力欄に実行ファイル名が指定されていると、そのウィンドウに対して機能するホットキーを作成できます。
・ウィンドウ名にaかAを指定すると、アクティブなウィンドウに対して機能するホットキーを作成できます。
・実行ファイル名にはフルパスも指定可能です。
・実行ファイル名の末尾に".exe"が含まれていない場合は、自動で追加されます。
・Get window infoボタンを押してから他のウィンドウをクリックすると、そのウィンドウのウィンドウ名とフルパスを取得します。
・出力をRun commandに切り替えると作業ディレクトリ指定してファイルを実行したりフォルダーやURLを開いたりできます。
  ファイル名の後に半角スペースを開けて二重引用符で囲まれた文字列を入力することで引数を渡すことができます。
  複数の引数を渡す場合は、引数ごとに半角スペースを開けて二重引用符で囲む必要があります。
  ただし、2つ目以降の引数かつ文字列内に半角スペースが含まれていない場合は、二重引用符がなくても動作します。
  コマンド実行時すでに該当ファイルが開かれている場合は、そのウィンドウをアクティブにします。
・出力をFunctionに切り替えるとプラグインで定義した関数を使用できます。
  Argumentにコンマ区切りで文字列を入力することでを引数を渡すこともできます。
・オプションの詳細
  ・Double press
    ホットキーの二度押しの受付時間
  ・Long press
    ホットキーの長押しの受付時間
  ・Combination
    ホットキー入力からさらにコンボキーを入力することで、出力を実行するようにします。
    コンボキーにはキーボード内の修飾キー以外のキー1つのみ設定できます。
    さらに、同じ入力キーに対して複数のコンボキーを設定できます。
    ただし、複数のコンボキーが設定されているものは入力関連のオプションが一括で変更されます。
    また、コンボキーが他のホットキーと被っていた場合はホットキーが優先されるため、コンボキーの入力を検知することができないので注意してください。
  ・Wait time
    コンボキーの受付時間
    0にするとキーが入力されるまで待ちます。
  ・Wild card
    Control,Shift,Alt,Windowsの各キーの状態にかかわらず入力キーが押されたらホットキーを出力します。
    ※入力キーが2つ設定されている場合には対応していません。
  ・Pass through
    入力キーを無効化せずに出力します。
  ・Direct send
    ウィンドウに対して直接出力します。このオプションの有効時は2個目のキーとコマンドと通常の関数が設定できません。
    さらに、マウスの座標モードもWindow固定になります。
  ・Show tooltip
    ホットキーの出力時などにツールチップを表示するようにします。
  ・Blind
    キーが出力される時に押されている修飾キーも出力します。
    ※Direct sendが有効で出力キーにマウスが設定されている場合は使用不可。
  ・Toggle
    出力キーの状態が入力キーを押す度切り替わるようにします。
    ※一部のキーは対応していません。
  ・Repeat
    出力キーを設定した間隔でリピートするようにします。
    ※一部のキーは対応していません。
  ・Hold
    出力キーを設定した時間ホールドするようにします。
    ※一部のキーは対応していません。
  ・X
    マウスのX座標
    ※出力キーにマウスが設定されている時のみ使用可能。
  ・Y
    マウスのY座標
    ※出力キーにマウスが設定されている時のみ使用可能。
  ・Coord mode
    マウスの座標モード
    ※出力キーにマウスが設定されている時のみ使用可能。Direct sendの有効時はWindow固定。
    ・Window
      アクティブウィンドウの左上からの相対座標
    ・Client
      アクティブウィンドウのクライアント領域の左上からの相対座標
    ・Screen
      スクリーン上での絶対座標
    ・Relative
      現在のカーソル位置からの相対座標
  ・Run as admin
    管理者権限でコマンドを実行するようにします。

○ホットキーの仕様
・キーの優先度はアクティブウィンドウ、アクティブではないウィンドウ、すべてのウィンドウの順番です。
  ただし、新たに作成したキーはすでに作成されているキーよりも優先度が高くなるため、意図した優先度にならない場合があります。
  その場合は、一度プロファイルへ保存した後に再起動するか、作成する順番を上記の優先度順で行う必要があります。
・ウィンドウ名と実行ファイル名は部分一致で検索されます。
・入力キー+ウィンドウ名+実行ファイル名+Direct sendの有無の組み合わせが一致していない限り、同じ入力キーのホットキーは複数存在できます。
・入力キーにControl,Shift,Alt,WindowsのいずれかとオプションのPass throughのないホットキーは、1つ目の入力キーの元の機能は無効化されます。
  そのため、最悪の場合操作不能になります。
  そうなった時は末尾で紹介している特殊ホットキーでサスペンドか終了をしてから該当ホットキー･プロファイルの無効化や削除などを行ってください。
・二度押しまたは長押しが有効なホットキーは、単押しがキーリピートされなくなります。
・出力キーがAlt+TabまたはShift+Alt+Tabの場合、画面切り替えが一度しか実行されません。
  ですが、入力キーにControl,Shift,Alt,Windowsのいずれか1つ以上が含まれていて、
  出力キーが単押しのAlt+TabまたはShift+Alt+Tabでオプションが設定されていない場合のみ、通常の画面切り替えと同じように使うことができます。

○ホットキーの有効･無効の切り替え
・ホットキーを選択した状態でOn/Offボタンを押すとホットキーの有効･無効を切り替えることができます。
・Enable allボタンを押すとすべてのホットキーを有効できます。
・Disable allボタンを押すとすべてのホットキーを無効できます。

○プロファイル･リンクデータについて
・プロファイルは有効にするホットキーの情報一覧を保存したものです。
・リンクデータはプロファイルとウィンドウを関連付け、条件に一致したプロファイルを読み込むためのものです。

○プロファイルの作成･削除･保存･読み込み･関連付け
・メインウィンドウのProfileタブにあるCreateボタンを押すと表示される作成ウィンドウへプロファイル名を入力することで新規プロファイルを作成できます。
・プロファイルを選択した状態でRenameボタンを押すと選択したプロファイルの名前を変更できます。
・プロファイルを選択した状態でCopyボタンを押すと選択したプロファイルを元に新規プロファイルを作成できます。
・プロファイルを選択した状態でDeleteボタンを押すとプロファイルを削除できます。
・プロファイルを選択した状態でSaveボタンを押すと現在登録されているホットキーをプロファイルに上書き保存します。
・プロファイルを選択した状態でLoadボタンを押すかダブルクリックするとプロファイルを読み込みます。
・Linkボタンを押すとプロファイルとウィンドウを関連付けるリンクデータの設定ウィンドウを表示します。

○プロファイルの仕様
・Defaultプロファイルは起動時に自動で読み込まれます。存在しない場合は、自動的に作成されます。
・DefaultプロファイルはDeleteボタンを押すとリセットできます。
・プロファイルは実行ファイルのあるディレクトリのProfilesフォルダーに指定した名前で保存されます。
・プロファイル名は重複できません。

○リンクデータの作成･編集･削除
・リンクデータウィンドウのCreateボタンを押すと表示される作成ウィンドウに必要なデータを入力することで新規リンクデータを作成できます。
・リンクデータを選択した状態でEditボタンを押すかダブルクリックすると表示される編集ウィンドウからデータを編集できます。
・リンクデータを選択した状態でCopyボタンを押すと選択したリンクデータを元に新規リンクデータを作成できます。
・リンクデータを選択した状態でDeleteボタンを押すか右ダブルクリックするとデータを削除できます。
・ドラッグアンドドロップで読み込み優先度を変更できます。

○リンクデータの作成･編集の詳細
・作成･編集ウィンドウにはプロファイル名選択欄とウィンドウ名入力欄と実行ファイル名入力欄とモード選択欄があり、
  指定ウィンドウが指定モード時に指定プロファイルを読み込むという情報を設定し、プロファイルとウィンドウを関連付けることができます。
・実行ファイル名にはフルパスも指定可能です。
・実行ファイル名の末尾に".exe"が含まれていない場合は、自動で追加されます。
・Get window infoボタンを押してから他のウィンドウをクリックすると、そのウィンドウのウィンドウ名とフルパスを取得します。
・モードの詳細
  ・Active
    指定したウィンドウがアクティブな時、読み込むようにします。
  ・Exist
    指定したウィンドウが非アクティブな時でも、アクティブウィンドウへ関連付けられた他のプロファイルがなければ読み込むようにします。
  ・Absolute
    指定したウィンドウが存在する時、他のウィンドウへ関連付けられたプロファイルがあっても読み込むようにします。
    他のウィンドウへ関連付けられたプロファイルが存在した場合は、`Absolute`に設定されたプロファイルと重複していない部分のみ読み込みます。

○リンクデータの仕様
・リンクされたプロファイルはAbsoluteに関連付けられたプロファイル、Activeに関連付けられたプロファイル、Existに関連付けられたプロファイル、デフォルトプロファイルの順番で読み込まれます。
・複数のプロファイルが読み込み条件に一致している時は、優先度順（リンクデータ一覧の上から順）で読み込まれます。
・ウィンドウ名と実行ファイル名は部分一致で検索されます。
・リンクデータは実行ファイルのあるディレクトリのConfigフォルダーにLink.datとして保存されます。
・リンクデータが存在しない場合は、自動的に作成されます。

■設定
・Open a window at launch
  起動時にウィンドウを表示するかどうか
・Keep a window always on top
  ウィンドウを常に最前面表示するかどうか
・Auto profile switching
  リンクデータを元にプロファイルを自動で切り替えるかどうか
・CapsLock state
  CapsLockの状態設定
・NumLock state
  NumLockの状態設定
・ScrollLock state
  ScrollLockの状態設定
・設定ファイルは実行ファイルのあるディレクトリのConfigフォルダーにDynamicHotkey.iniとして保存されます。
・設定ファイルが存在しない場合は、自動的に作成されます。

■特殊ホットキー
キーボードのDキー、Hキー、Kキーを押しながら特定のキーを押すことでサスペンド（ホットキーの無効化）時でも入力可能なホットキーを設定しています。
・D+H+K+O - ウィンドウの表示
・D+H+K+S - サスペンド有効･無効
・D+H+K+R - 再起動
・D+H+K+Q - 終了

■プラグインについて
・実行ファイルのあるディレクトリのPluginsフォルダーにAutoHotkeyスクリプトを追加すると起動時にロードされます。
・Pluginsフォルダーが起動時に存在しない場合は、自動的に作成されます。
・プラグインはファイル名を関数名とした関数を定義するか、ファイル名をクラス名としたクラスを定義し、そこに変数や関数を実装していく形で作成します。
・クラス定義時、クラス内でのみ使用する関数は名前にPrivate_という接頭辞をつける必要があります。
  それ以外の関数は実際に使用する関数とみなされます。
・Direct sendで使用したい関数は名前にDirect_という接頭辞をつける必要があります。
・接頭辞は先にある方のみ判定されるため、1つしか使用できません。
・ホットキーの作成、削除、有効化、無効化が行われた時にメッセージが発行されます。
  (HotkeyData.KM_NEW,HotkeyData.KM_DELETE,HotkeyData.KM_ENABLE,HotkeyData.KM_DISABLE)
  それらをプラグインのコンストラクターなどの関数内でOnMessageによって受け取る設定をすると、メッセージ発行時にプラグイン関数を実行できます。
・ホットキーの作成時、関数は新規のインスタンスになるため、キーが有効な間は変数などが保持されます。
  別のキー間では別のインスタンスであるため、変数の共有などをする場合は、global変数にしたり、static変数を使ってクラス変数にしたり、インスタンスを同一にしたりする必要があります。
・その他スクリプト仕様などについてはAutoHotkey公式ドキュメントを確認してください。

■免責事項
本ソフトウェアの使用によって生じた何らかの不具合や損害に関しましては、
制作者は一切責任を負わないものとします。

■ライセンス
GNU General Public License version 2.0

                    GNU GENERAL PUBLIC LICENSE
                       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Lesser General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.

                    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.

  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.

  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

                            NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
convey the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

Also add information on how to contact you by electronic and paper mail.

If the program is interactive, make it output a short notice like this
when it starts in an interactive mode:

    Gnomovision version 69, Copyright (C) year name of author
    Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, the commands you use may
be called something other than `show w' and `show c'; they could even be
mouse-clicks or menu items--whatever suits your program.

You should also get your employer (if you work as a programmer) or your
school, if any, to sign a "copyright disclaimer" for the program, if
necessary.  Here is a sample; alter the names:

  Yoyodyne, Inc., hereby disclaims all copyright interest in the program
  `Gnomovision' (which makes passes at compilers) written by James Hacker.

  <signature of Ty Coon>, 1 April 1989
  Ty Coon, President of Vice

This General Public License does not permit incorporating your program into
proprietary programs.  If your program is a subroutine library, you may
consider it more useful to permit linking proprietary applications with the
library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.
