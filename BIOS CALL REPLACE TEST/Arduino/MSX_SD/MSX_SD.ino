//2024. 3.13 sd-card再挿入時の初期化処理を追加
//2024. 5.18 エラー処理が通常版と異なっていた部分を修正
//
#include "SdFat.h"
#include <SPI.h>
SdFat SD;
unsigned long r_count=0;
unsigned long f_length=0;
char m_name[40];
char f_name[40];
char w_name[40];
char c_name[40];
char sdir[10][40];
File file_r,file_w;
unsigned int s_adrs,e_adrs,g_adrs,s_adrs1,s_adrs2;
boolean eflg;

#define CABLESELECTPIN  (10)
#define CHKPIN          (15)
#define PB0PIN          (2)
#define PB1PIN          (3)
#define PB2PIN          (4)
#define PB3PIN          (5)
#define PB4PIN          (6)
#define PB5PIN          (7)
#define PB6PIN          (8)
#define PB7PIN          (9)
#define FLGPIN          (14)
#define PA0PIN          (16)
#define PA1PIN          (17)
#define PA2PIN          (18)
#define PA3PIN          (19)
// ファイル名は、ロングファイルネーム形式対応

void sdinit(void){
  // SD初期化
  if( !SD.begin(CABLESELECTPIN,8) )
  {
////    Serial.println("Failed : SD.begin");
    eflg = true;
  } else {
////    Serial.println("OK : SD.begin");
    eflg = false;
  }
////    Serial.println("START");
}

void setup(){
////    Serial.begin(9600);
// CS=pin10
// pin10 output

  pinMode(CABLESELECTPIN,OUTPUT);
  pinMode( CHKPIN,INPUT);  //CHK
  pinMode( PB0PIN,OUTPUT); //送信データ
  pinMode( PB1PIN,OUTPUT); //送信データ
  pinMode( PB2PIN,OUTPUT); //送信データ
  pinMode( PB3PIN,OUTPUT); //送信データ
  pinMode( PB4PIN,OUTPUT); //送信データ
  pinMode( PB5PIN,OUTPUT); //送信データ
  pinMode( PB6PIN,OUTPUT); //送信データ
  pinMode( PB7PIN,OUTPUT); //送信データ
  pinMode( FLGPIN,OUTPUT); //FLG

  pinMode( PA0PIN,INPUT_PULLUP); //受信データ
  pinMode( PA1PIN,INPUT_PULLUP); //受信データ
  pinMode( PA2PIN,INPUT_PULLUP); //受信データ
  pinMode( PA3PIN,INPUT_PULLUP); //受信データ

  digitalWrite(PB0PIN,LOW);
  digitalWrite(PB1PIN,LOW);
  digitalWrite(PB2PIN,LOW);
  digitalWrite(PB3PIN,LOW);
  digitalWrite(PB4PIN,LOW);
  digitalWrite(PB5PIN,LOW);
  digitalWrite(PB6PIN,LOW);
  digitalWrite(PB7PIN,LOW);
  digitalWrite(FLGPIN,LOW);

  delay(500);

//SETSコマンドでSAVE用ファイル名を指定なくSAVEされた場合のデフォルトファイル名を設定
  strcpy(w_name,"default.cas");

  sdinit();
}

//4BIT受信
byte rcv4bit(void){
//HIGHになるまでループ
  while(digitalRead(CHKPIN) != HIGH){
  }
//受信
  byte j_data = digitalRead(PA0PIN)+digitalRead(PA1PIN)*2+digitalRead(PA2PIN)*4+digitalRead(PA3PIN)*8;
//FLGをセット
  digitalWrite(FLGPIN,HIGH);
//LOWになるまでループ
  while(digitalRead(CHKPIN) == HIGH){
  }
//FLGをリセット
  digitalWrite(FLGPIN,LOW);
  return(j_data);
}

//1BYTE受信
byte rcv1byte(void){
  byte i_data = 0;
  i_data=rcv4bit()*16;
  i_data=i_data+rcv4bit();
  return(i_data);
}

//1BYTE送信
void snd1byte(byte i_data){
//下位ビットから8ビット分をセット
  digitalWrite(PB0PIN,(i_data)&0x01);
  digitalWrite(PB1PIN,(i_data>>1)&0x01);
  digitalWrite(PB2PIN,(i_data>>2)&0x01);
  digitalWrite(PB3PIN,(i_data>>3)&0x01);
  digitalWrite(PB4PIN,(i_data>>4)&0x01);
  digitalWrite(PB5PIN,(i_data>>5)&0x01);
  digitalWrite(PB6PIN,(i_data>>6)&0x01);
  digitalWrite(PB7PIN,(i_data>>7)&0x01);
  digitalWrite(FLGPIN,HIGH);
//HIGHになるまでループ
  while(digitalRead(CHKPIN) != HIGH){
  }
  digitalWrite(FLGPIN,LOW);
//LOWになるまでループ
  while(digitalRead(CHKPIN) == HIGH){
  }
}

//小文字->大文字
char upper(char c){
  if('a' <= c && c <= 'z'){
    c = c - ('a' - 'A');
  }
  return c;
}

//ファイル名の最後が「.cas」でなければ付加
void addcas(char *f_name,char *m_name){
  unsigned int lp1=0;
  while (f_name[lp1] != 0x00){
    m_name[lp1] = f_name[lp1];
    lp1++;
  }
  if (f_name[lp1-4]!='.' ||
    ( f_name[lp1-3]!='c' &&
      f_name[lp1-3]!='C' ) ||
    ( f_name[lp1-2]!='a'  &&
      f_name[lp1-3]!='A' ) ||
    ( f_name[lp1-1]!='s' &&
      f_name[lp1-1]!='S' ) ){
         m_name[lp1++] = '.';
         m_name[lp1++] = 'c';
         m_name[lp1++] = 'a';
         m_name[lp1++] = 's';
  }
  m_name[lp1] = 0x00;
}

//比較文字列取得 32+1文字まで取得、ただしダブルコーテーションは無視する
void receive_name(char *f_name){
char r_data;
  unsigned int lp2 = 0;
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    r_data = rcv1byte();
    if (r_data != 0x22){
      f_name[lp2] = r_data;
      lp2++;
    }
  }
}

//比較文字列取得 32+1文字まで取得し先頭の6文字をファイルネームとする、ただしダブルコーテーションは無視する
void receive_name6(char *f_name){
char r_data;
  unsigned int lp2 = 0;
  for (unsigned int lp1 = 0;lp1 <= 32;lp1++){
    r_data = rcv1byte();
    if (lp2 < 6){
      if (r_data != 0x22){
        f_name[lp2] = r_data;
        lp2++;
      }
    }else{
      f_name[lp2] = 0x00;
      lp2++;
    }
  }
}

//f_nameとc_nameをc_nameに0x00が出るまで比較
//FILENAME COMPARE
boolean f_match(char *f_name,char *c_name){
  boolean flg1 = true;
  unsigned int lp1 = 0;
  while (lp1 <=32 && c_name[0] != 0x00 && flg1 == true){
    if (upper(f_name[lp1]) != c_name[lp1]){
      flg1 = false;
    }
    lp1++;
    if (c_name[lp1]==0x00){
      break;
    }
  }
  return flg1;
}

// SD-CARDのFILELIST
void dirlist(void){
//比較文字列取得 32+1文字まで
  receive_name(c_name);
//
  File file2 = SD.open( "/" );
  if( file2 == true ){
//状態コード送信(OK)
    snd1byte(0x00);

    File entry =  file2.openNextFile();
    int cntl2 = 0;
    unsigned int br_chk =0;
    int page = 1;
//全件出力の場合には10件出力したところで一時停止、キー入力により継続、打ち切りを選択
    while (br_chk == 0) {
      if(entry){
        entry.getName(f_name,36);
        unsigned int lp1=0;
//一件送信
//比較文字列でファイルネームを先頭から比較して一致するものだけを出力
        if (f_match(f_name,c_name)){
//sdir[]にf_nameを保存
          strcpy(sdir[cntl2],f_name);
          snd1byte(0x30+cntl2);
          snd1byte(0x20);
          while (lp1<=36 && f_name[lp1]!=0x00){
          snd1byte(upper(f_name[lp1]));
          lp1++;
          }
          snd1byte(0x0D);
          snd1byte(0x00);
          cntl2++;
        }
      }
// CNTL2 > 表示件数-1
      if (!entry || cntl2 > 9){
//継続・打ち切り選択指示要求
        snd1byte(0xfe);

//選択指示受信(0:継続 B:前ページ 以外:打ち切り)
        br_chk = rcv1byte();
//前ページ処理
        if (br_chk==0x42){
//先頭ファイルへ
          file2.rewindDirectory();
//entry値更新
          entry =  file2.openNextFile();
//もう一度先頭ファイルへ
          file2.rewindDirectory();
          if(page <= 2){
//現在ページが1ページ又は2ページなら1ページ目に戻る処理
            page = 0;
          } else {
//現在ページが3ページ以降なら前々ページまでのファイルを読み飛ばす
            page = page -2;
            cntl2=0;
//page*表示件数
            while(cntl2 < page*10){
              entry =  file2.openNextFile();
              if (f_match(f_name,c_name)){
                cntl2++;
              }
            }
          }
          br_chk=0;
        }
//1～0までの数字キーが押されたらsdir[]から該当するファイル名を送信
        if(br_chk>=0x30 && br_chk<=0x39){
          file_r = SD.open( sdir[br_chk-0x30], FILE_READ );
          if( file_r == true ){
//f_length設定、r_count初期化
            f_length = file_r.size();
            r_count = 0;
            unsigned int lp2=0;
            snd1byte(0xFD);
            while (lp2<=36 && sdir[br_chk-0x30][lp2]!=0x00){
              snd1byte(upper(sdir[br_chk-0x30][lp2]));
              lp2++;
            }
            snd1byte(0x0A);
            snd1byte(0x0D);
            snd1byte(0x00);
          }
        }
        page++;
        cntl2 = 0;
      }
//ファイルがまだあるなら次読み込み、なければ打ち切り指示
      if (entry){
        entry =  file2.openNextFile();
      }else{
        br_chk=1;
      }
    }
//処理終了指示
    snd1byte(0xFF);
    snd1byte(0x00);
  }else{
    snd1byte(0xf1);
  }
}

// LOADFILEOPEN 読み込み用のファイル名を設定する
void loadopen(void){
  boolean flg = false;
//DOSファイル名取得
  receive_name(m_name);
  addcas(m_name,f_name);
//ファイルが存在しなければERROR
  if (SD.exists(f_name) == true){
//ファイルオープン
    file_r = SD.open( f_name, FILE_READ );

    if( true == file_r ){
//f_length設定、r_count初期化
      f_length = file_r.size();
      r_count = 0;
//状態コード送信(OK)
      snd1byte(0x00);
      flg = true;
    } else {
      snd1byte(0xf2);
      sdinit();
      flg = false;
    }
  }else{
    snd1byte(0xf1);
    sdinit();
    flg = false;
  }
}

// SAVEFILEOPEN 書き込み用のファイル名を設定する
void saveopen(void){
  boolean flg = false;
//DOSファイル名取得
  receive_name(m_name);
  addcas(m_name,f_name);
  strcpy(w_name,f_name);
//ファイルオープン
  if(file_w==true){
    file_w.close();
  }
  file_w = SD.open( w_name, FILE_WRITE );
//状態コード送信(OK)
  snd1byte(0x00);
}

// sloadコマンド
void sload(void){
  boolean flg = false;
  int wk1 =0;
  unsigned char rdata;
  unsigned int lp1 =0;
//比較文字列取得 32+1文字まで
  receive_name6(c_name);
  if (file_r == true){
    snd1byte(0x00);
//0xd3が10個連続するまで読み飛ばし、読み飛ばしでファイルエンドになってしまったらエラー終了
    while (flg == false && f_length >= r_count){
      rdata=file_r.read();
      r_count++;
      if (rdata == 0xd3){
          wk1++;
        } else{
          wk1=0;
      }
      if (wk1 >= 10 ){
        flg = true;
      }
//ファイルネームが指定された場合、読み出したファイルネームが一致するまで読み飛ばし
      if (flg == true){
        for(lp1=0; lp1 <= 5;lp1++){
          f_name[lp1]=file_r.read();
          r_count++;
        }
        f_name[6]=0x00;
        if (c_name[0]!=0x00){
          if (f_match(f_name,c_name) == false){
            flg = false;
          }
        }
      }
    }
    if(flg == true){
      snd1byte(0x00);
//ファイルネームを送信
      for(lp1=0; lp1 <= 5;lp1++){
        snd1byte(f_name[lp1]);
      }
//ヘッダを読み飛ばし
      for(lp1=1; lp1 <= 8;lp1++){
        rdata=file_r.read();
        r_count++;
      }
//次行アドレスポインタから1行Byte数を計算し送信、1行Byte数分の実データも読み出して送信
      s_adrs2=file_r.read();
      r_count++;
      s_adrs1=file_r.read();
      r_count++;
      e_adrs = s_adrs1*256+s_adrs2;
      if (e_adrs != 0){
        wk1=s_adrs2-3;
        snd1byte(wk1);
        s_adrs =e_adrs;
        for (lp1=1;lp1 <= wk1;lp1++){
          rdata=file_r.read();
          r_count++;
          snd1byte(rdata);
        }
      }
//2行目以降処理
//次行アドレスポインタから1行Byte数を計算し送信、1行Byte数分の実データも読み出して送信
      while (e_adrs != 0){
        s_adrs2=file_r.read();
        r_count++;
        s_adrs1=file_r.read();
        r_count++;
        e_adrs = s_adrs1*256+s_adrs2;
        if (e_adrs != 0){
          wk1 = e_adrs-s_adrs-2;
          s_adrs =e_adrs;
          snd1byte(wk1);
          for (lp1=1;lp1 <= wk1;lp1++){
            rdata=file_r.read();
            r_count++;
            snd1byte(rdata);
          }
        }
      }
      snd1byte(0x00);
    } else{
      snd1byte(0xf1);
      sdinit();
      r_count = 0;
    }
  } else{
    snd1byte(0xf1);
    sdinit();
    r_count = 0;
  }
}

// sbloadコマンド
void sbload(void){
  boolean flg = false;
  int wk1 =0;
  unsigned char rdata;
  unsigned int lp1 =0;
//比較文字列取得 32+1文字まで
  receive_name6(c_name);
  if (file_r == true){
    snd1byte(0x00);
//0xd0を10個連続するまで読み飛ばし、読み飛ばしでファイルエンドになってしまったらエラー終了
    while (flg == false && f_length >= r_count){
      rdata=file_r.read();
      r_count++;
      if (rdata == 0xd0){
          wk1++;
        } else{
          wk1=0;
      }
      if (wk1 >= 10 ){
        flg = true;
      }
//ファイルネームが指定された場合、読み出したファイルネームが一致するまで読み飛ばし
      if (flg == true){
        for(lp1=0; lp1 <= 5;lp1++){
          f_name[lp1]=file_r.read();
          r_count++;
        }
        f_name[6]=0x00;
        if (c_name[0]!=0x00){
          if (f_match(f_name,c_name) == false){
            flg = false;
          }
        }
      }
    }
    if(flg == true){
      snd1byte(0x00);
//ファイルネームを送信
      for(lp1=0; lp1 <= 5;lp1++){
        snd1byte(f_name[lp1]);
      }
//ヘッダを読み飛ばし
      for(lp1=1; lp1 <= 8;lp1++){
        rdata=file_r.read();
        r_count++;
      }
//スタートアドレスを読み出して送信
      s_adrs2=file_r.read();
      r_count++;
      s_adrs1=file_r.read();
      r_count++;
      s_adrs = s_adrs1*256+s_adrs2;
      snd1byte(s_adrs2);
      snd1byte(s_adrs1);
//エンドアドレスを読み出して送信
      s_adrs2=file_r.read();
      r_count++;
      s_adrs1=file_r.read();
      r_count++;
      e_adrs = s_adrs1*256+s_adrs2;
      snd1byte(s_adrs2);
      snd1byte(s_adrs1);
//実行アドレスを読み出して送信
      s_adrs2=file_r.read();
      r_count++;
      s_adrs1=file_r.read();
      r_count++;
      g_adrs = s_adrs1*256+s_adrs2;
      snd1byte(s_adrs2);
      snd1byte(s_adrs1);
//スタートアドレスからエンドアドレスまでのデータを読み出して送信
      for(lp1=s_adrs; lp1 <= e_adrs;lp1++){
        rdata=file_r.read();
        snd1byte(rdata);
        r_count++;
      }
    } else{
      snd1byte(0xf1);
      sdinit();
      r_count = 0;
    }
  } else{
    snd1byte(0xf1);
    sdinit();
    r_count = 0;
  }
}

//ヘッダ書き込み
void header_write(void){
        file_w.write(char(0x1f));
        file_w.write(char(0xa6));
        file_w.write(char(0xde));
        file_w.write(char(0xba));
        file_w.write(char(0xcc));
        file_w.write(char(0x13));
        file_w.write(char(0x7d));
        file_w.write(char(0x74));
}

//ファイルヘッダ書き込み
void file_header(char hdata){
  unsigned int lp1 =0;
//ロングヘッダ書き込み
  header_write();
//hdata x 10
  for(lp1=1; lp1 <= 10;lp1++){
    file_w.write(hdata);
  }
//ファイルネーム送信及び書き込み
  for(lp1=0; lp1 <= 5;lp1++){
    snd1byte(c_name[lp1]);
    file_w.write(c_name[lp1]);
  }
//ショートヘッダ書き込み
      header_write();
}

// ssaveコマンド
void ssave(void){
  boolean flg = false;
  unsigned int wk1 =0;
  unsigned char rdata;
  unsigned int lp1 =0;
//比較文字列取得 32+1文字まで
  receive_name6(c_name);
//ファイルネームが指定されていなければエラー
  if (c_name[0] != 0x00){
//w_nameでファイルオープン
    if(file_w==true){
      file_w.close();
    }
    file_w = SD.open( w_name, FILE_WRITE );
    if(file_w==true){
      snd1byte(0x00);
//ファイルヘッダ書き込み
      file_header(char(0xd3));
      wk1=rcv1byte();
//1行Byte数が0になるまでループ
      while(wk1!=0){
//次行プログラムポインタを受信して書き込み
        rdata=rcv1byte();
        file_w.write(rdata);
        rdata=rcv1byte();
        file_w.write(rdata);
//1行分のデータを受信して書き込み
          for(lp1=1; lp1 <= wk1;lp1++){
            rdata=rcv1byte();
            file_w.write(rdata);
          }
        wk1=rcv1byte();
      }
//終了マークを書き込み
      for(lp1=1; lp1 <= 12;lp1++){
        file_w.write(char(0x00));
      }
      file_w.close();
      snd1byte(0x00);
    }else{
      snd1byte(0xf1);
      sdinit();
    }
  }else{
    snd1byte(0xf1);
    sdinit();
  }
}  

// sbsaveコマンド
void sbsave(void){
  boolean flg = false;
  unsigned int wk1 =0;
  unsigned char rdata;
  unsigned int lp1 =0;
//比較文字列取得 32+1文字まで
  receive_name6(c_name);
//パラメータ正常フラグが送られてきたら処理継続
  rdata = rcv1byte();
  if (rdata == 0x00){
//ファイルネームが指定されていなければエラー終了
    if (c_name[0] != 0x00){
//w_nameでファイルオープン
      if(file_w==true){
        file_w.close();
      }
      file_w = SD.open( w_name, FILE_WRITE );
      if(file_w==true){
        snd1byte(0x00);
//ファイルヘッダ書き込み
      file_header(char(0xd0));
//スタートアドレス受信及び書き込み
        s_adrs1=rcv1byte();
        file_w.write(s_adrs1);
        s_adrs2=rcv1byte();
        file_w.write(s_adrs2);
        s_adrs = s_adrs2*256+s_adrs1;
//エンドアドレス受信及び書き込み
        s_adrs1=rcv1byte();
        file_w.write(s_adrs1);
        s_adrs2=rcv1byte();
        file_w.write(s_adrs2);
        e_adrs = s_adrs2*256+s_adrs1;
//実行アドレス受信及び書き込み
        s_adrs1=rcv1byte();
        file_w.write(s_adrs1);
        s_adrs2=rcv1byte();
        file_w.write(s_adrs2);
        g_adrs = s_adrs2*256+s_adrs1;
//スタートアドレスからエンドアドレスまでのデータを受信して書き込み
        for(lp1=0; lp1 <= (e_adrs-s_adrs);lp1++){
          rdata=rcv1byte();
          file_w.write(rdata);
        }
        file_w.close();
        snd1byte(0x00);
      }else{
        snd1byte(0xf1);
        sdinit();
      }
    }else{
      snd1byte(0xf1);
      sdinit();
    }
  }
}

//READ HEADER
void readheader(void){
  unsigned int rdata;
  int hflg=0;
////  Serial.print(" hflg:");
////  Serial.println(hflg);
  while (hflg <= 7){
    rdata = file_r.read();
////  Serial.print(" hflg:");
////  Serial.print(hflg);
////  Serial.print(" rdata:");
////  Serial.println(rdata,HEX);
    switch (hflg){
      case 0:
        if (rdata == 0x1f){hflg++;}
        break;
      case 1:
        if (rdata == 0xa6){hflg++;}else {hflg = 0;}
        break;
      case 2:
        if (rdata == 0xde){hflg++;}else {hflg = 0;}
        break;
      case 3:
        if (rdata == 0xba){hflg++;}else {hflg = 0;}
        break;
      case 4:
        if (rdata == 0xcc){hflg++;}else {hflg = 0;}
        break;
      case 5:
        if (rdata == 0x13){hflg++;}else {hflg = 0;}
        break;
      case 6:
        if (rdata == 0x7d){hflg++;}else {hflg = 0;}
        break;
      case 7:
        if (rdata == 0x74){hflg++;}else {hflg = 0;}
        break;
    }
  }
}

//READ ONE BYTE、OPENしているファイルの続きから1Byteを読み込み、送信
void read1byte(void){
  int rdata = file_r.read();
  r_count++;
  snd1byte(rdata);

////  Serial.print("f_length:");
////  Serial.print(f_length);
////  Serial.print(" r_count:");
////  Serial.print(r_count);
////  Serial.print(" rdata:");
////  Serial.println(rdata,HEX);

//ファイルエンドまで達していればFILE CLOSE
  if (f_length == r_count){
    file_r.close();
  }      
}

void loop()
{
  digitalWrite(PB0PIN,LOW);
  digitalWrite(PB1PIN,LOW);
  digitalWrite(PB2PIN,LOW);
  digitalWrite(PB3PIN,LOW);
  digitalWrite(PB4PIN,LOW);
  digitalWrite(PB5PIN,LOW);
  digitalWrite(PB6PIN,LOW);
  digitalWrite(PB7PIN,LOW);
  digitalWrite(FLGPIN,LOW);
//コマンド取得待ち
////    Serial.println("COMMAND WAIT");
  byte cmd = rcv1byte();
////    Serial.println(cmd,HEX);
  if (eflg == false){
    switch(cmd) {
//41hでファイルリスト出力
      case 0x41:
////    Serial.println("FILE LIST START");
//状態コード送信(OK)
        snd1byte(0x00);
        sdinit();
        dirlist();
        break;
//42hでLOADFILEOPEN
      case 0x42:
////    Serial.println("LOADFILEOPEN");
//状態コード送信(OK)
        snd1byte(0x00);
        loadopen();
        break;
//43hでSAVEFILEOPEN
      case 0x43:
////    Serial.println("SAVEFILEOPEN");
//状態コード送信(OK)
        snd1byte(0x00);
        saveopen();
        break;
//44h:sload
      case 0x44:
////    Serial.println("sload START");
//状態コード送信(OK)
        snd1byte(0x00);
        sload();
////  delay(1500);
        break;
//45h:sbload
      case 0x45:
////    Serial.println("sbload START");
//状態コード送信(OK)
        snd1byte(0x00);
        sbload();
////  delay(1500);
        break;
//46h:ssave
      case 0x46:
////    Serial.println("ssave START");
//状態コード送信(OK)
        snd1byte(0x00);
        ssave();
////  delay(1500);
        break;
//47h:sbload
      case 0x47:
////    Serial.println("sbsave START");
//状態コード送信(OK)
        snd1byte(0x00);
        sbsave();
////  delay(1500);
        break;
//48h:READ HEADER FROM CMT
      case 0x48:
////    Serial.println("READ HEADER START");
//  delay(1);
//状態コード送信(OK)
        snd1byte(0x00);
        readheader();
        break;
//49h:READ ONE BYTE FROM CMT
      case 0x49:
////    Serial.println("READ 1BYTE START");
//  delay(1);
//状態コード送信(OK)
//        snd1byte(0x00);
        read1byte();
        break;

      default:
//状態コード送信(CMD ERROR)
        snd1byte(0xF4);
    }
  } else {
//状態コード送信(ERROR)
    snd1byte(0xF0);
    sdinit();
  }
}
