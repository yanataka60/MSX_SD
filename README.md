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
### FM-7_SD Rev1.1基板
|番号|品名|数量|備考|
| ------------ | ------------ | ------------ | ------------ |
|J1|2x25Pinコネクタ|1|秋月電子通商 PH-2x40RGなど|
||J4、J5のいずれか(注1)|||
|J4|Micro_SD_Card_Kit|1|秋月電子通商 AE-microSD-LLCNV (注2)|
|J5|MicroSD Card Adapter|1|Arduino等に使われる5V電源に対応したもの (注5)|
|U1|74LS04|1||
|U2|74LS30|1||
|U3|8255|1||
|U4|Arduino_Pro_Mini_5V|1|(注3)|
|U5|74LS00|1||
|C1 C3 C4 C6|積層セラミックコンデンサ 0.1uF|4||
|C2|電解コンデンサ 16v100uF|1||
||本体内BOOT-ROMを差し替える場合|||
||ROM 2716又は2732|1|AT28C16、M2732Aなど|
||2732変換基板又は24PinICソケット|1|2732を使った場合の切り替え用|
||3Pトグルスイッチ|1|2732を使った場合の切り替え用|

### FM-7_SD Rev2.0基板
|番号|品名|数量|備考|
| ------------ | ------------ | ------------ | ------------ |
|J1|FCN-365P032-AU又はOMRON XC5A-3282-1|1|(注4)|
||J4、J5のいずれか(注1)|||
|J4|Micro_SD_Card_Kit|1|秋月電子通商 AE-microSD-LLCNV (注2)|
|J5|MicroSD Card Adapter|1|Arduino等に使われる5V電源に対応したもの (注5)|
|U1|74LS04|1||
|U2|74LS30|1||
|U3|8255|1||
|U4|Arduino_Pro_Mini_5V|1|(注3)|
|U5|74LS00|1||
|C1 C3 C4 C6|積層セラミックコンデンサ 0.1uF|4||
|C2|電解コンデンサ 16v100uF|1||
||本体内BOOT-ROMを差し替える場合|||
||ROM 2716又は2732|1|AT28C16、M2732Aなど|
||2732変換基板又は24PinICソケット|1|2732を使った場合の切り替え用|
||3Pトグルスイッチ|1|2732を使った場合の切り替え用|

### FM-7_SD Rev3.0基板
|番号|品名|数量|備考|
| ------------ | ------------ | ------------ | ------------ |
|J1|2x25Pinコネクタ|1|秋月電子通商 PH-2x40RGなど|
||J4、J5のいずれか(注1)|||
|J4|Micro_SD_Card_Kit|1|秋月電子通商 AE-microSD-LLCNV (注2)|
|J5|MicroSD Card Adapter|1|Arduino等に使われる5V電源に対応したもの (注5)|
|U1 U7|74LS04|2||
|U2 U6|74LS30|2||
|U3|8255|1||
|U4|Arduino_Pro_Mini_5V|1|(注3)|
|U5|74LS00|1||
|C1 C3 C4 C5 C6 C7|積層セラミックコンデンサ 0.1uF|6||
|C2|電解コンデンサ 16v100uF|1||
||本体内BOOT-ROMを差し替える場合|||
||ROM 2716又は2732|1|AT28C16、M2732Aなど|
||2732変換基板又は24PinICソケット|1|2732を使った場合の切り替え用|
||3Pトグルスイッチ|1|2732を使った場合の切り替え用|

　　　注1)J4又はJ5のどちらかを選択して取り付けてください。

　　　注2)秋月電子通商　AE-microSD-LLCNVのJ1ジャンパはショートしてください。

　　　注3)Arduino Pro MiniはA4、A5ピンも使っています。

　　　注4)FCN-365P032-AUは入手困難、OMRON XC5A-3282-1は加工が必要

　　　　　OMRON XC5A-3282-1は、ハウジング内の凸型に出っ張ている部分を台形に近付けるように削ってください。

![OMRON XC5A32821](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/OMRON%20XC5A32821.JPG)

　　　注5)MicroSD Card Adapterを使う場合

　　　　　J5に取り付けます。

　　　　　MicroSD Card Adapterについているピンヘッダを除去してハンダ付けするのが一番確実ですが、J5の穴にMicroSD Card Adapterをぴったりと押しつけ、裏から多めにハンダを流し込むことでハンダ付けをする方法もあります。なお、この方法の時にはしっかりハンダ付けが出来たかテスターで導通を確認しておいた方が安心です。

ハンダ付けに自信のない方はJ4の秋月電子通商　AE-microSD-LLCNVをお使いください。AE-microSD-LLCNVならパワーLED、アクセスLEDが付いています。

![MicroSD Card Adapter1](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/MicroSD%20Card%20Adapter.JPG)

![MicroSD Card Adapter2](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/MicroSD%20Card%20Adapter2.JPG)

![MicroSD Card Adapter3](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/MicroSD%20Card%20Adapter3.JPG)

## BOOT-ROMの差し替えを選択した場合
　FM-8、FM-7、FM-NEW7でBOOT-ROMの差し替えを選択した場合には、programフォルダ内bootromフォルダにある「FM-7_BOOTROM_SD.bin」を使いますが、Disk-Basicを使うか、使わないかでROMの差し替え方法が変わります。

　FM-8は「FM-7_BOOTROM_SD.bin」をbootrom_FM8フォルダにある「FM-8_BOOTROM_SD.bin」に読み替えてください。

#### 2023.2.17修正 DOS-MODEからの起動は出来ませんでした。運用方法は２通りとなります。

　1)FM-7_SDとCMTだけが使えればよい。(DISK-BASIC、DOS-MODEは使わない)

　　　元のBOOT-ROMを読み出す必要はありません。FM-7_BOOTROM_SD.binをROMライター(TL866II Plus等)を使ってROM 2716のアドレス$0000～$01FFに書き込んでBOOT-ROMのICソケットに装着します。

　2)FM-7_SDとCMTに加えてDISK-BASICは使いたい又は、FM-7_SD、CMT、DISK-BASIC、DOS-MODEのすべてを使いたい。

　　　ROM 2732の前半に元のBOOT-ROMの内容、後半の$0800～$09FFにFM-7_BOOTROM_SD.binとしたバイナリをROMライター(TL866II Plus等)を使って書き込みます。2732変換基板又は24PinICソケットの21Pinを曲げてスイッチで5VとGNDを切り替えられるようにしてBOOT-ROMのICソケットに装着します。

### FM-7 BOOT-ROMの場所
![boot-rom1](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/FM-7_BOOT-ROM_1.JPG)

![boot-rom2](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/FM-7_BOOT-ROM_2.JPG)

### FM-NEW7 BOOT-ROMの場所
![boot-rom3](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/NEW-7_BOOT-ROM_1.JPG)

![boot-rom4](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/NEW-7_BOOT-ROM_2.JPG)

### FM-8 BOOT-ROMの場所
電源ユニットの下です。
![boot-rom5](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/FM8_BOOT-ROM_1.JPG)

![boot-rom6](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/FM8_BOOT-ROM_2.JPG)

## SD-CARDアクセス初期設定プログラム
### BOOT-ROMを差し替えた場合
　programフォルダ内boot_iplフォルダの「@BOOT_IPL_FM-7.bin」をSD-CARDにコピーしてください。

　FM-8の場合は、boot_ipl_FM8フォルダ内の「@BOOT_IPL_FM-8.bin」をSD-CARDにコピーします。なお、「@BOOT_IPL_FM-7.bin」と「@BOOT_IPL_FM-8.bin」の両方がSD-CARDにコピーしてあっても大丈夫です。

　FM-7起動後に「EXEC &HFE02」(又は「EXEC -510」)を実行することでSD-CARDから「@BOOT_IPL_FM-7.bin」がテキストエリアの最初に読み込まれSD-CARDが使えるようBASICコマンドの追加、BIOSへのパッチあて、テキストエリアの再設定が行われます。

### BOOT-ROMを差し替えない場合
#### FDから起動
　DISKBASICフォルダのSDINIT_FM7.D77ディスクイメージをFDに書き込むか、SDINIT_FM7.binをFDに書き込んでください。

#### CMTから起動
　CMTLOADフォルダのSDINIT_FM7.wav(FM8は、SDINIT_FM8.wav)をCMTからロードして実行します。

## Arduinoプログラム
　Arduino IDEを使ってArduinoフォルダのFM-7_SDフォルダ内FM-7_SD.inoを書き込みます。FM-8も共通のプログラムを使用しています。

　SdFatライブラリを使用しているのでArduino IDEメニューのライブラリの管理からライブラリマネージャを立ち上げて「SdFat」をインストールしてください。

　「SdFat」で検索すれば見つかります。「SdFat」と「SdFat - Adafruit Fork」が見つかりますが「SdFat」のほうを使っています。

注)Arduinoを基板に直付けしていてもFM-7本体から外していれば書き込めます。

#### 電源が入ったFM-7本体とFM-7_SDを繋げたままArduinoを書き込む場合には、Arduinoに繋ぐシリアルコンバータから絶対に電源を供給しないでください。最悪FM-7本体が破壊される場合があります。

## 接続
　Rev1.1、Rev3.0をFM-8、FM-7、FM-NEW7で使う場合には本体後ろの50Pin拡張端子から50Pinフラットケーブルで接続します。

![connect1](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/CONNECT_1.JPG)

![connect2](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/CONNECT_2.JPG)

　50Pinフラットケーブルは、コネクタのボッチとケーブルの返しが両方上になる側のコネクタを本体に嵌めます。

![Cable3](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/Cable3.JPG)

![Cable3](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/Cable1.JPG)

　逆側のコネクタを本体に嵌めると一見嵌っているように見えてもケーブルの返しが基板に当たっていてちゃんと嵌っておらず接触不良を起こしていることがあります。

#### 悪い例です
![Cable3](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/Cable2.JPG)

　Rev1.1をFM-77以降、Rev3.0をFM-77で使う場合にはアンフェノール フルピッチへ変換するケーブルの自作が必要です。

　接続ピンは、はせりんさんのサイトが参考になります。

　http://haserin09.la.coocan.jp/difference.html

## SD-CARD
　FAT16又はFAT32が認識できます。

　ルートに置かれた拡張子が「.BIM」のCMTベタ形式ファイルのみLOAD、SAVEできます。(以外のファイル、フォルダも表示されますが読み書き出来ません)

　ファイル名は拡張子を除いて32文字まで、ただし半角カタカナ、及び一部の記号はArduinoが認識しないので使えません。パソコンでファイル名を付けるときはアルファベット、数字および空白でファイル名をつけてください。

## T77ファイルの扱い方
　T77ファイルはそのまま使えません。

　Apolloさんが公開してくださっている「T77DEC」を使ってCMTベタ形式に変換して使います。

　http://retropc.net/apollo/

　変換例)T77DEC TEST.T77 -d[CR]

　を実行するとFULLDUMP.BINというファイルが出来上がるので拡張子を.bimに変えて使います。

![batch_file](https://github.com/yanataka60/FM-7_SD/blob/main/jpeg/batch_file.jpg)

　こんなバッチファイルを作ると便利です。

　bimファイルをT77に戻すにはBET2T77フォルダ内の「BET2T77.exe」を使います。

　「BET2T77.exe」を起動し、開いたウィンドウにbimファイルをドロップすればT77ファイルが作成されます。

## 起動手順
### ROM-BASIC(BOOT-ROM差し替え済の場合)
　1　電源を入れます。

　2　この時点ではCMTが使えるROM-BASICが起動しています。

　3　「EXEC &HFE02」(又は「EXEC -510」)を実行します。

　4　「FM-7_SD READY OK!」と表示されたらSD-CARDにアクセスできます。BASICのフリーエリアは947Byte程減少します。

### DISK-BASIC
　1　電源を入れ、DISK-BASICを起動します。

　2　作成したFDの中にある「SDINIT」をロードし、実行します。

　　　LOADM"SDINIT"してからEXEC &H6000又はLOADM"SDINIT",,R

　3　「FM-7_SD READY OK!」と表示されたらSD-CARDにアクセスできます。

　4　LOADM"SDINIT",,RをSTARTUPとして保存し、AUTOUTYで自動実行を設定すれば手間が省けます。

　5　SDからLOAD、SAVEする場合にはファイルデスクリプタ「CAS0:」が必ず必要になります。

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
