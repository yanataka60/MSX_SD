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
　Z80フォルダ内のEXT_ROM.binをROMライター(TL866II Plus等)を使って2764又は28C64に書き込みます。

## Arduinoプログラム
　Arduino IDEを使ってArduinoフォルダのPC-6001mk2_SDフォルダ内PC-6001mk2_SD.inoを書き込みます。

　SdFatライブラリを使用しているのでArduino IDEメニューのライブラリの管理からライブラリマネージャを立ち上げて「SdFat」をインストールしてください。

　「SdFat」で検索すれば見つかります。「SdFat」と「SdFat - Adafruit Fork」が見つかりますが「SdFat」のほうを使っています。

注)Arduinoを基板に直付けしている場合、Arduinoプログラムを書き込むときは、カートリッジスロットから抜き、74LS04を外したうえで書き込んでください。

## 接続
　カートリッジスロットに挿入します。

![cartridge](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/cartridge.jpg)

　カートリッジスロットへの抜き差しに基板のみでは不便です。

　STLフォルダに基板を載せられるトレイの3Dデータを置いたので出力して使うと便利です。

![Tray](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/TRAY.JPG)

　PC-6601、PC-6601SRはドライブ数切替スイッチは0として使ってください。

![Drive](https://github.com/yanataka60/PC-6001mk2_SD/blob/main/JPEG/DRIVE.JPG)

### SD-CARD
　FAT16又はFAT32が認識できます。

　ルートに置かれた拡張子が「.P6T」又は「.CAS」の形式ファイルのみ認識できます。(以外のファイル、フォルダも表示されますがLOAD実行の対象になりません)

　ファイル名は拡張子を除いて32文字まで、ただし半角カタカナ、及び一部の記号はArduinoが認識しないので使えません。パソコンでファイル名を付けるときはアルファベット、数字および空白でファイル名をつけてください。

　起動直後の画面は横32文字表示です。拡張子を含めて27文字以下にしたほうが画面の乱れません。

## 使い方
　BASICから以下のコマンドが使えます。
### CMT[CR]
CMTを使いたい時に実行します。

BIOSのフックを元に戻してCMTが使えるようにします。ただし、SD-CARDアクセス用のプログラムは常駐したまま残っていますのでBASICのフリーエリアは減少したままです。

### SDON[CR]
CMTコマンドで戻してしまったBIOSのフックをSD-CARD用にフックし直します。

CMTコマンドと合わせて使えばCMTから読み込んでSD-CARDに保存することができます。

### SETL "DOSファイル名"[CR]
指定したDOSファイル名のファイルをSD-CARDからLOAD出来るようにセットします。ファイル名の前には必ずダブルコーテーションをつけてください。後ろのダブルコーテーションは有っても無くても構いません。

ファイル名の最後の「.bim」は有っても無くても構いません。

SETLを実行することでカセットテープをセットして読み込む準備をしたことになります。

### LOAD
F-BASICのLOADコマンドと同じ使い方になります。

#### 例)
　　LOAD[CR]

　　LOAD "TEST"[CR]

　　LOAD "CAS0:TEST"[CR]

　　LOAD "TEST",R[CR]

ROM-BASICの場合には、ファイルデスクリプタ「CAS0:」は有っても無くても構いません。DISK-BASICの場合にSDからLOADするには必ず必要です。

カセットテープと同じようにLOAD命令等で読み込みが行われる度にDOSファイル名で指定したファイルに保存されているプログラム又はデータが先頭から一つずつ読み込まれます。

カセットデッキのように巻き戻しは無いので戻りたい時にはもう一度SETLコマンドを実行すれば先頭のプログラム又はデータに戻ります。

### LOADM
F-BASICのLOADMコマンドと同じ使い方です。

### SETS "DOSファイル名"[CR]
指定したDOSファイル名のファイルをSD-CARDへSAVE出来るようにセットします。ファイル名の前には必ずダブルコーテーションをつけてください。後ろのダブルコーテーションは有っても無くても構いません。

ファイル名の最後の「.bim」は有っても無くても構いません。

指定したDOSファイル名のファイルがSD-ACRDに存在しない場合は新たに作成され、存在する場合にはそのファイルの続きに追記されます。

SETSを実行することでカセットテープをセットして書き込む準備をしたことになります。

なお、SETSを実行せずにSAVE、SAVEMコマンドを実行すると「DEFAULT.bim」というDOSファイル名のファイルに自動的に書き込まれます。

「DEFAULT.bim」でなく好きなDOSファイル名のファイルに書き込みたい時には事前にSETSコマンドを実行してください。

### SAVE
F-BASICのSAVEコマンドと同じ使い方になります。

#### 例)
　　SAVE "TEST"[CR]

　　SAVE "CAS0:TEST"[CR]

　　SAVE "TEST",A[CR]

　　SAVE "TEST",P[CR]

ROM-BASICの場合には、ファイルデスクリプタ「CAS0:」は有っても無くても構いません。DISK-BASICの場合にSDへSAVEするには必ず必要です。

### SAVEM
F-BASICのSAVEMコマンドと同じ使い方です。

### SDIR[CR] 又は SDIR "文字列"[CR]

文字列を指定するときは必ずダブルコーテーションをつけてください。後ろのダブルコーテーションは有っても無くても構いません。

文字列を入力せずにSDIR[CR]のみ入力するとSD-CARDルートディレクトリにあるファイルの一覧を表示します。

文字列を付けて入力すればSD-CARDルートディレクトリにあるその文字列から始まるファイルの一覧を表示します。

10件表示したところで指示待ちになるので打ち切るならESCを入力すると打ち切られ、Bキーで前の10件に戻ります。それ以外のキーで次の10件を表示します。

　行頭に0から9の数字を付加して表示してあるのでSETLしたいファイルの頭についている数字を入力するとSETLコマンドが実行されます。

　表示される順番は、登録順となりファイル名アルファベッド順などのソートした順で表示することはできません。

#### 例)
　　SDIR[CR]

　　SDIR "P"[CR]

### 操作上の注意
　「SD-CARD INITIALIZE ERROR」と表示されたときは、SD-CARDが挿入されているか確認し、FM-7本体をリセットしてください。Arduinoのみのリセットでは復旧しません。

　SD-CARDにアクセスしていない時に電源が入ったままで SD-CARDを抜いた後、再挿入しSD-CARDにアクセスすると「SD-CARD INITIALIZE ERROR」となる場合があります。再挿入した場合にはSD-CARDにアクセスする前にArduinoを必ずリセットしてください。

　SD-CARDの抜き差しは電源を切った状態で行うほうがより確実です。

## EXAS-FMコンパイラ起動プログラム
　月刊I/O '84/4月号に掲載されたEXAS-FMコンパイラをFM-7_SDから起動できるようにする起動プログラムです。

### EXAS-FMコンパイラSD起動用ファイルの作成
　まず、EXAS-FMコンパイラ本体のバイナリファイルを掲載のダンプリストどおりに打ち込みます。

　記事では「実際にROMに書き込むときには、8FFAの6バイトに次の物を入れ、8FFA-EFF9を書き込んでください。」となっています。この6バイトは付いていても付いていなくてもどちらでも構いません。

　バイナリエディタ等でEXAS-FM_BOOTフォルダにある「EXAS-FM_BOOT.bim」の後ろにEXAS-FMコンパイラ本体をくっつけ「EXAS-FM.bim」というファイル名で保存し、SD-CARDにコピーしてください。

　出来上がったEXAS-FMコンパイラSD起動用ファイルのサイズは、6バイトを付加していれば25304Byte、いなければ25298Byteとなるはずです。

### 起動方法
　FM-7を起動し、「EXEC&HFE02」を実行します。

　「clear,&h6FFF」でEXAS-FMコンパイラSD起動用プログラムの領域を確保します。

　「sdir」で「EXAS-FM」を選択します。

　「loadm」「exec&H7000」又は「loadm"EXAS-FM",,R」でEXAS-FMコンパイラが裏RAMに転送、実行されます。

　コンパイルでエラー等が発生し、ソースプログラムを修正したのちに再度コンパイルする場合には次の２通りの方法があります。

　　１　FM-7をSDモードで起動している場合には、「EXEC&HFFE8」でEXAS-FMコンパイラを起動できます。

　　２　DISK-BASICから起動してFM-7_SDを使っている場合には、「sdir」で「EXAS-FM」を選択後、「loadm」「exec&H7000」又は「loadm"EXAS-FM",,R」を再度実行してください。ただし、裏RAMにEXAS-FMコンパイラが既に転送されていますのでSDからEXAS-FMコンパイラの読み込みは行われずに起動します。

## 謝辞
　基板の作成に当たり以下のデータを使わせていただきました。ありがとうございます。

　Arduino Pro Mini

　　https://github.com/g200kg/kicad-lib-arduino

　AE-microSD-LLCNV

　　https://github.com/kuninet/PC-8001-SD-8kRAM

　Apollo様、公開していただいているソフトを使わせていただきました。ありがとうございます。

　はせりん様のサイトにあるインタフェース仕様表が大変参考になりました。ありがとうございます。

　　http://haserin09.la.coocan.jp/difference.html

　AIGOU Yoshiaki様に少しの加工でOMRON XC5A-3282-1がFCN-365P032-AUの代替に使えると教えていただきました。ありがとうございます。

## 追記
2023.2.11 @BOOT_IPL_FM-7.binをリロケータブルに修正

2023.2.13 FDからFM-7_SDの初期設定を行うプログラムを追加

　　　　　FM-77、FM-77AVにおける動作状況を追記しました。

2023.2.15 CMTから読み込む方法も追加しました。

2023.2.17 DOS-MODEからの起動は出来ませんでした。BOOT-ROMの差し替え方は２通りとなります。

2023.2.18 50Pinフラットケーブルの嵌め方を追記しました。

2023.2.21 機種、コネクタの違いから基板3種(Rev1.1、Rev2.0、Rev3.0)を用意したため、Documentを全面修正しました。

2023.4.12 EXAS-FMコンパイラ起動用プログラムを追加しました。
