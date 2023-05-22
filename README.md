# MSXにSD-CARDからロード、セーブ機能

![TITLE](https://github.com/yanataka60/MSX_SD/blob/main/JPEG/TITLE1.jpg)
![TITLE2](https://github.com/yanataka60/MSX_SD/blob/main/JPEG/TITLE2.jpg)

　MSX、MSX2、MSX2+、MSXturboRでSD-CARDからロード、セーブ機能を実現するものです。

　ROM-BASIC、DISK-BASICのどちらからも使えますが、DISK-BASICのフリーエリアでは動かないカセット用プログラム(ゲーム)もあります。

　FDD内蔵機種でフリーエリアが足りない場合は、SHIFTキーを押しながら電源投入又はリセットしてFDDを切り離してください。

　CMTからの読み込み実行に数分掛かっていたゲームも数十秒で実行できます。

　なお、Arduino、ROMへ書き込むための機器が別途必要となります。

## 対応できないもの
　BASICにSD専用命令を追加することでSD-CARDへのアクセスを実現しています。

　機械語からBIOSをコール、又は独自ルーチンでCMTからLOADするソフトには対応していません。

　雑誌打ち込み系のLOAD、SAVEを想定しています。市販ソフトはLOAD出来ればラッキーくらいに思って活用してください。

## 回路図
　KiCadフォルダ内のMSX_SD.pdfを参照してください。

[回路図](https://github.com/yanataka60/MSX_SD/blob/main/Kicad/MSX_SD.pdf)

![MSX_SD](https://github.com/yanataka60/MSX_SD/blob/main/Kicad/MSX_SD_1.jpg)

## 部品
|番号|品名|数量|備考|
| ------------ | ------------ | ------------ | ------------ |
||J2、J3のいずれか(注1)|||
|J2|Micro_SD_Card_Kit|1|秋月電子通商 AE-microSD-LLCNV (注2)|
|J3|MicroSD Card Adapter|1|Arduino等に使われる5V電源に対応したもの (注4)|
|D1|1N4148|1||
|U1|74LS02|1||
|U2|74LS138|1||
|U3|27256相当品|1|29C256は可、28C256は不可|
|U4|8255|1||
|U5|Arduino_Pro_Mini_5V|1|(注3)|
|C1～C4|積層セラミックコンデンサ 0.1uF|4||
|C5|電解コンデンサ 16v100uF|1||

　　　注1)J2又はJ3のどちらかを選択して取り付けてください。

　　　注2)秋月電子通商　AE-microSD-LLCNVのJ1ジャンパはショートしてください。

　　　注3)Arduino Pro MiniはA4、A5ピンも使っています。

　　　注4)MicroSD Card Adapterを使う場合

　　　　　J3に取り付けます。

　　　　　MicroSD Card Adapterについているピンヘッダを除去してハンダ付けするのが一番確実ですが、J3の穴にMicroSD Card Adapterをぴったりと押しつけ、裏から多めにハンダを流し込むことでハンダ付けをする方法もあります。なお、この方法の時にはしっかりハンダ付けが出来たかテスターで導通を確認しておいた方が安心です。

![MicroSD Card Adapter1](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/MicroSD%20Card%20Adapter.JPG)

![MicroSD Card Adapter2](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/MicroSD%20Card%20Adapter2.JPG)

![MicroSD Card Adapter3](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/MicroSD%20Card%20Adapter3.JPG)

## ROMへの書込み
　Z80フォルダ内のEXT_ROM.binをROMライター(TL866II Plus等)を使って27256又は29C256のアドレス4000Hからに書き込みます。

## Arduinoプログラム
　Arduino IDEを使ってArduinoフォルダのMSX_SDフォルダ内MSX_SD.inoを書き込みます。

　SdFatライブラリを使用しているのでArduino IDEメニューのライブラリの管理からライブラリマネージャを立ち上げて「SdFat」をインストールしてください。

　「SdFat」で検索すれば見つかります。「SdFat」と「SdFat - Adafruit Fork」が見つかりますが「SdFat」のほうを使っています。

## 接続
　カートリッジスロットに挿入します。

![cartridge](https://github.com/yanataka60/MSX_SD/blob/main/JPEG/MSX%2016k.JPG)

### SD-CARD
　FAT16又はFAT32が認識できます。

　ルートに置かれた拡張子が「.CAS」形式ファイルのみ認識できます。(以外のファイル、フォルダも表示されますがLOAD実行の対象になりません)

　ファイル名は拡張子を除いて32文字まで、ただし半角カタカナ、及び一部の記号はArduinoが認識しないので使えません。パソコンでファイル名を付けるときはアルファベット、数字および空白でファイル名をつけてください。

## 使い方
　BASICから以下のコマンドが使えます。

　各コマンドでパラメータを指定する場合には必ず"("をつけてください。"("が無い場合には、MSXの仕様により入力した文字列のすべてがコマンド名として解釈されるため、パラメータを指定しなかったことになります。

### CALL SDIR[CR] 又は CALL SDIR("文字列")[CR]
### 【省略形】_SDIR[CR] 又は _SDIR("文字列")[CR]

文字列を指定するときは必ず"("をつけてください。後ろの")"は有っても無くても構いません。

ダブルコーテーションは有っても無くても構いません。

文字列を入力せずにSDIR[CR]のみ入力するとSD-CARDルートディレクトリにあるファイルの一覧を表示します。

文字列を付けて入力すればSD-CARDルートディレクトリにあるその文字列から始まるファイルの一覧を表示します。

10件表示したところで指示待ちになるので打ち切るならESCを入力すると打ち切られ、Bキーで前の10件に戻ります。それ以外のキーで次の10件を表示します。

　行頭に0から9の数字を付加して表示してあるのでSETLしたいファイルの頭についている数字を入力するとSETLコマンドが実行されます。

　表示される順番は、登録順となりファイル名アルファベッド順などのソートした順で表示することはできません。

#### 例)
　　CALL SDIR[CR]

　　CALL SDIR("P")[CR]

　　CALL SDIR(P)[CR]


### CALL SETL("DOSファイル名")[CR]
### 【省略形】_SETL("DOSファイル名")[CR]
指定したDOSファイル名のファイルをSD-CARDからLOAD出来るようにセットします。ファイル名の前には必ず"("をつけてください。後ろの")"は有っても無くても構いません。

ダブルコーテーションは有っても無くても構いません。

ファイル名の最後の「.cas」は有っても無くても構いません。

SETLを実行することでカセットテープをセットして読み込む準備をしたことになります。

#### 例)
　　CALL SETL("TEST")[CR]


### CALL SLOAD[CR] 又は CALL SLOAD("ファイル名")[CR]
### 【省略形】_SLOAD[CR] 又は _SLOAD("ファイル名")[CR]
CALL SDIR又はCALL SETLでセットしたDOSファイル名に記録されているBASICプログラムをロードします。

ファイル名の前には必ず"("をつけてください。

ダブルコーテーションは有っても無くても構いません。

ファイルデスクリプタ「CAS0:」は不要です。

ASCII形式のBASICプログラムには対応していません。

Rオプションには対応していません。LOAD後実行したい場合にはマルチステートメントでRUNを付け加え、CALL SLOAD:RUN[CR]又はCALL SLOAD("ファイル名"):RUN[CR]などとしてください。

ファイル名が指定されていなければ最初に見つけたBASICプログラムから、ファイル名を指定していれば入力したファイル名から始まるBASICプログラムが見つかるとロードが始まります。

#### 例)
　　CALL SLOAD[CR]

　　CALL SLOAD("TEST")[CR]

カセットテープと同じようにSLOAD命令等で読み込みが行われる度にDOSファイル名で指定したファイルに保存されているプログラムが先頭から一つずつ読み込まれます。

カセットデッキのように巻き戻しは無いので戻りたい時にはもう一度CALL SDIR又はCALL SETLコマンドを実行すれば先頭のプログラム又はデータに戻ります。


### CALL SBLOAD[CR]、CALL SBLOAD ("ファイル名")[CR]、CALL SBLOAD(,R)[CR] 又は CALL SBLOAD ("ファイル名",R)[CR]
### 【省略形】_SBLOAD[CR]、_SBLOAD ("ファイル名")[CR]、_SBLOAD(,R)[CR] 又は _SBLOAD ("ファイル名",R)[CR]
CALL SDIR又はCALL SETLでセットしたDOSファイル名に記録されている機械語プログラムをロードします。

ファイル名の前には必ず"("をつけてください。

ダブルコーテーションは有っても無くても構いません。

ファイルデスクリプタ「CAS0:」は不要です。

RオプションをつけることでLOAD後指定された実行開始アドレスから直ちに実行されます。

ファイル名が指定されていなければ最初に見つけた機械語プログラムから、ファイル名を指定していれば入力したファイル名から始まる機械語プログラムが見つかるとロードが始まります。

#### 例)
　　CALL SBLOAD[CR]

　　CALL SBLOAD("TEST")[CR]

　　CALL SBLOAD(,R)[CR]

　　CALL SBLOAD("TEST",R)[CR]

カセットテープと同じようにSBLOAD命令等で読み込みが行われる度にDOSファイル名で指定したファイルに保存されているプログラムが先頭から一つずつ読み込まれます。

カセットデッキのように巻き戻しは無いので戻りたい時にはもう一度CALL SDIR又はCALL SETLコマンドを実行すれば先頭のプログラム又はデータに戻ります。


### CALL SETS("DOSファイル名")[CR]
### 【省略形】_SETS("DOSファイル名")[CR]
SD-CARDへのSAVEが指定したDOSファイル名のファイルとなるようにセットします。ファイル名の前には必ず"("をつけてください。後ろの")"は有っても無くても構いません。

ダブルコーテーションは有っても無くても構いません。

ファイル名の最後の「.cas」は有っても無くても構いません。

指定したDOSファイル名のファイルがSD-CARDに存在しない場合は新たに作成され、存在する場合にはそのファイルの続きに追記されます。

SETSを実行することでカセットテープをセットして書き込む準備をしたことになります。

なお、SETSを実行せずにSSAVE、SBSAVEコマンドを実行すると「DEFAULT.cas」というDOSファイル名のファイルに自動的に書き込まれます。

「DEFAULT.cas」でなく好きなDOSファイル名のファイルに書き込みたい時には事前にSETSコマンドを実行してください。

#### 例)
　　CALL SETS("TEST")[CR]


### CALL SSAVE("ファイル名")[CR]
### 【省略形】_SSAVE("ファイル名")[CR]
CALL SETSでセットしたDOSファイル名のファイルにBASICプログラムをSAVEします。

ファイル名の前には必ず"("をつけてください。

ダブルコーテーションで必ず括る必要はありませんが、MSXの仕様上ダブルコーテーションで括った場合には文字列として判断され小文字はそのまま小文字ですが、括らなかった場合には変数名と判断され小文字はすべて大文字に変換されます。

ファイルデスクリプタ「CAS0:」は不要です。

ファイル名は省略できません。6文字以内でファイル名を指定してください。

#### 例)
　　CALL SSAVE("test")[CR]　　　:ファイル名testとしてSAVEされます。

　　CALL SSAVE("TEST")[CR]　　　:ファイル名TESTとしてSAVEされます。

　　CALL SSAVE(test)[CR]　　　　:ファイル名TESTとしてSAVEされます。

　　CALL SSAVE(TEST)[CR]　　　　:ファイル名TESTとしてSAVEされます。

カセットテープと同じようにSSAVE命令等で書き込みが行われる度にDOSファイル名で指定したファイルにBASICプログラムを追記します。


### CALL SBSAVE("ファイル名",開始アドレス,終了アドレス,実行開始アドレス)[CR]
### 【省略形】_SBSAVE("ファイル名",開始アドレス,終了アドレス,実行開始アドレス)[CR]
CALL SETSでセットしたDOSファイル名のファイルに開始アドレスから終了アドレスまでのメモリ上に置かれている機械語プログラムをSAVEします。

ファイル名の前には必ず"("をつけてください。

ダブルコーテーションで必ず括る必要はありませんが、MSXの仕様上ダブルコーテーションで括った場合には文字列として判断され小文字はそのまま小文字ですが、括らなかった場合には変数名と判断され小文字はすべて大文字に変換されます。

ファイルデスクリプタ「CAS0:」は不要です。

ファイル名、開始アドレス、終了アドレス、実行開始アドレスは省略できません。

6文字以内でファイル名を指定してください。

#### 例)
　　CALL SBSAVE("TEST",&HA000,&HAFFF,&HA000)[CR]

カセットテープと同じようにSBSAVE命令等で書き込みが行われる度にDOSファイル名で指定したファイルに機械語プログラムを追記します。


### CALL DUMP[CR] 又は CALL DUMP(開始アドレス)[CR]
### 【省略形】_DUMP[CR] 又は _DUMP(開始アドレス)[CR]
メモリの内容を開始アドレスから128Byte分表示します。

開始アドレスを指定する場合には"("をつけてください。

開始アドレスを省略した場合には直前にCALL SBLOADされた機械語プログラムの実行開始アドレス又はCALL DUMPで表示された続きを表示します。

#### 例)
　　CALL DUMP(&HA000)[CR]　　　:アドレスA000からメモリ内容を表示します。

　　直後にCALL DUMP[CR]　　　　:直前に表示したメモリ内容(&HA000～&HA07F)の続きとして&HA080～&HA0FFを表示します。

　　CALL SBLOADを実行した直後にCALL DUMP[CR]　　　　:直前にLOADされた機械語プログラムの実行開始アドレスからメモリ内容を表示します。


### CALL EDIT[CR] 又は CALL EDIT(開始アドレス)[CR]
### 【省略形】_EDIT[CR] 又は _EDIT(開始アドレス)[CR]
開始アドレスが表示されるのでその後ろに16進数を入力し最後に[CR]を押すことでメモリにデータを書き込むことができます。

開始アドレスを指定する場合には"("をつけてください。

開始アドレスを省略した場合には直前にCALL SBLOADされた機械語プログラムの実行開始アドレス又はCALL DUMPで表示された続きのアドレスが書き込み開始アドレスとなります。

#### 例)
　　CALL EDIT(&HA000)[CR]　　　:とすると改行してA000が表示されるので16進数を入力後[CR]を押す。

　　A000 12 34 56 78 90[CR]　　:アドレスA000から 12 34 56 78 90の5Byteが書き込まれ、次のアドレスA005が表示される。

　　A005 [CR]　　　　　　　　　:終了したい時はアドレス表示の後に[CR]だけ押せば終了となる。


### CALL GOTO[CR] 又は CALL GOTO(実行開始アドレス)[CR]
### 【省略形】_GOTO[CR] 又は _GOTO(実行開始アドレス)[CR]
実行開始アドレスの機械語プログラムを呼び出します。

開始アドレスを指定する場合には"("をつけてください。

開始アドレスを省略した場合には直前にCALL SBLOADされた機械語プログラムの実行開始アドレス又はCALL DUMPで表示された続きが実行開始アドレスとなります。

#### 例)
　　CALL GOTO(&HA000)[CR]　　　:アドレスA000からの機械語プログラムを呼び出します。

　　CALL SBLOADを実行した直後にCALL GOTO[CR]　　　:直前にLOADされた機械語プログラムの実行開始アドレスの機械語プログラムを呼び出します。CALL SBLOAD(,R)と同等の動作となります。


### 操作上の注意
　「SD-CARD INITIALIZE ERROR」と表示されたときは、SD-CARDが挿入されているか確認し、SD-CARDを挿入して再度実行してください。

　SD-CARDにアクセスしていない時に電源が入ったままで SD-CARDを抜いた後、再挿入しても動作します。もし、「SD-CARD INITIALIZE ERROR」となる場合には本体の電源を入れ直してください。

## 謝辞
　基板の作成に当たり以下のデータを使わせていただきました。ありがとうございます。

　Arduino Pro Mini

　　https://github.com/g200kg/kicad-lib-arduino

　AE-microSD-LLCNV

　　https://github.com/kuninet/PC-8001-SD-8kRAM

　にが様に多大なるご助言を頂きました。ありがとうございます。
