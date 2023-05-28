;2023.5.22 キースキャンルーチンにWAITを追加
;2023.5.28 _SBLOAD(,R)、_GOTOコマンドからのリターン時にHLレジスタを復帰していなかったバグを修正
;           _GOTOコマンドで数値省略時にマルチステートメントに対応していなかったバグを修正
;            マシン語自動実行用ワークエリア調整

CHGET		EQU		009FH			;1文字入力
CHPUT		EQU		00A2H			;1文字表示
BEEP		EQU		00C0H			;BEEP
SNSMAT		EQU		0141H			;キーマトリックススキャン
KILBUF		EQU		0156H			;キーボードバッファを空にする

BUF			EQU		0F55EH			;行バッファ
TXTTAB		EQU		0F676H			; BASICテキストエリアの先頭番地
VARTAB		EQU		0F6C2H			; 単純変数エリアの開始番地
ARYTAB		EQU		0F6C4H			; 配列テーブルエリアの開始番地
STREND		EQU		0F6C6H			; テキストエリアや変数エリアとして使用中であるメモリの最後の番地(フリーエリア)
HLSAVE		EQU		0F7C5H			;Math-pack用ワークエリアを流用　HLレジスタ退避用
SADRS		EQU		HLSAVE+2		;Math-pack用ワークエリアを流用　LOAD、SAVEスタートアドレス
EADRS		EQU		HLSAVE+4		;Math-pack用ワークエリアを流用　LOAD、SAVEエンドアドレス
GADRS		EQU		HLSAVE+6		;Math-pack用ワークエリアを流用　マシン語実行アドレス
LBUF		EQU		HLSAVE+8		;Math-pack用ワークエリアを流用　行バッファ及び自動実行文字列格納先
EXEFLG		EQU		0FB04H			;RS-232C用ワークエリアを流用　マシン語自動実行用
PROCNM		EQU		0FD89H			;CALLコマンド文字列

;MSX
PPI_A		EQU		038H
PPI_B		EQU		PPI_A+1
PPI_C		EQU		PPI_A+2
PPI_R		EQU		PPI_A+3

;MSX
;8255 PORT アドレス 3CH～3FH
;07CH PORTA 送信データ(下位4ビット)
;07DH PORTB 受信データ(8ビット)
;07EH PORTC Bit

;7 IN  CHK
;6 IN
;5 IN
;4 IN 
;3 OUT
;2 OUT FLG
;1 OUT
;0 OUT
;
;3FH コントロールレジスタ

;_SDIR				41H
;_SETL				42H
;_SETS				43H
;_SLOAD				44H
;_SBLOAD			45H
;_SSAVE				46H
;_SBSAVE			47H

        ORG		4000H

		DB		'A','B'				;拡張ROM認識コード
		DW		INIT				;INIT
		DW		SRCH				;STATEMENT
		DW		0000H				;DEVICE
		DW		0000H				;TEXT
		DW		0000H				;RESERVE
		DW		0000H
		DW		0000H

INIT:
;**** 8255初期化 ****
;PORTC下位BITをOUTPUT、上位BITをINPUT、PORTBをINPUT、PORTAをOUTPUT
		LD		A,8AH
		OUT		(PPI_R),A
;出力BITをリセット
		XOR		A					;PORTA <- 0
		OUT		(PPI_A),A
		OUT		(PPI_C),A			;PORTC <- 0

		RET

SRCH:
		LD		(HLSAVE),HL			;HL退避
		LD		DE,PROCNM
		LD		A,(DE)
		CP		'D'
		JR		Z,DUMP				;_DUMPコマンド
		CP		'E'
		JP		Z,EDIT				;_EDITコマンド
		CP		'G'
		JP		Z,GOTO				;_GOTOコマンド
		CP		'S'
		JR		NZ,SEND
		INC		DE
		LD		A,(DE)
		CP		'B'
		JR		Z,PROCSB
		CP		'D'
		JP		Z,PSDIR				;_SDIRコマンド
		CP		'E'
		JR		Z,PROCSE
		CP		'L'
		JP		Z,PSLOAD			;_SLOADコマンド
		CP		'S'
		JP		Z,PSSAVE			;_SSAVEコマンド
		JR		SEND

PROCSB:	INC		DE
		LD		A,(DE)
		CP		'L'
		JP		Z,PSBLOAD			;_SBLOADコマンド
		CP		'S'
		JP		Z,PSBSAVE			;_SBSAVEコマンド
SEND:
		LD		HL,(HLSAVE)			;HL復帰
		SCF							;CALLコマンド不一致
		RET

PROCSE:	INC		DE
		LD		A,(DE)
		CP		'T'
		JR		NZ,SEND
		INC		DE
		LD		A,(DE)
		CP		'L'
		JP		Z,PSETL				;_SETLコマンド
		CP		'S'
		JP		Z,PSETS				;_SETSコマンド
		JR		SEND

SRET:
		LD		HL,(HLSAVE)			;HL復帰
		XOR		A					;正常終了
		RET

;*********************************** MEMORY DUMP ********************************
DUMP:
		LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		CALL	GETNUM				;HL <- 数値
		PUSH	AF
DP3:	LD		A,(DE)				;00H又は「:」以外は読み飛ばし
		CP		3AH					;「:」
		JR		Z,DP5
		CP		00H
		JR		Z,DP5
		INC		DE
		JR		DP3
DP5:	LD		(HLSAVE),DE			;次文先頭位置を退避
		POP		AF
		JP		C,SEND				;数値が取得できなかったらERRORで終了

		LD		C,10H				;16行ループ
DP6		LD		A,H
		CALL	MONBHX				;アドレス表示
		LD		A,L
		CALL	MONBHX
		LD		B,08H				;横8Byte分ループ
DP7:	LD		A,20H
		CALL	CHPUT
		LD		A,(HL)
		CALL	MONBHX				;メモリ内容を表示
		INC		HL
		DJNZ	DP7
		CALL	MONCLF				;改行
		DEC		C
		JR		NZ,DP6
		LD		(GADRS),HL			;終了アドレス+1を退避　パラメータ無し_DUMPコマンドで続きを表示
		JP		SRET

;********************* (DE)からの数値を取得してHLに格納 CF=0、空ならHL <- (SADRS) CF=0、数値でなければ CF=1
GETNUM:	LD		A,(DE)
		CP		0CH					;16進数
		JR		Z,GN1
		CP		0FH					;10～255の整数
		JR		Z,GN01
		CP		1CH					;256～32767の整数
		JR		Z,GN1
		CP		00H					;パラメータなし
		JR		Z,GN0
		CP		3AH					;パラメータなし
		JR		Z,GN0
		CP		11H					;11H～1BHなら0～9の整数
		JR		C,GN00				;数値の識別コードなしへ
		CP		1BH
		JR		C,GN02
GN00:	SCF							;数値の識別コードなし CF=1
		JR		GN2
GN0:	LD		HL,(GADRS)			;HL <- (GADRS)　_DUMP用パラメータ無しなら続きアドレスをセット
		DEC		DE
		JR		GN11
		
GN01:	INC		DE					;10～255の整数
		LD		A,(DE)
		LD		L,A
		LD		H,00H
		JR		GN11
		
GN02:	SUB		11H					;11H～1BHなら0～9の整数 A-11H
		LD		L,A
		LD		H,00H
		JR		GN11
		
GN1:	INC		DE					;16進数又は256～32767の整数
		LD		A,(DE)
		LD		L,A
		INC		DE
		LD		A,(DE)
		LD		H,A
GN11:	XOR		A
GN2:	INC		DE
		RET

;*********************************** MEMORY EDIT ********************************
EDIT:
		LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		CALL	GETNUM				;HL <- 数値
		PUSH	AF
ED3:	LD		A,(DE)				;00H又は「:」以外は読み飛ばし
		CP		3AH					;「:」
		JR		Z,ED5
		CP		00H
		JR		Z,ED5
		INC		DE
		JR		ED3
ED5:	LD		(HLSAVE),DE			;次文先頭位置を退避
		POP		AF
		JP		C,ED91				;数値が取得できなかったらERRORで終了

ED51:	LD		A,H					;アドレス表示
		CALL	MONBHX
		LD		A,L
		CALL	MONBHX
		LD		A,20H
		CALL	CHPUT

		CALL	00AEH				;1行入力
		LD		DE,BUF				;行バッファ

		CALL	HLHEX				;アドレス再取得
		JR		C,ED91
		
ED6:	LD		A,(DE)
		AND		A					;アドレスのみなら終了
		JR		Z,ED91
		CP		20H					;スペース読み飛ばし
		JR		NZ,ED7
		INC		DE
		JR		ED6

ED7:	CALL	TWOHEX				;データ取得
		JR		C,ED9				;16進数でなければ1行終了
		LD		(HL),A				;取得した16進数を書き込み
		INC		HL

ED8:	LD		A,(DE)				;次データ取得
		AND		A					;データが無ければ1行終了
		JR		Z,ED9
		CP		20H					;スペース読み飛ばし
		JR		NZ,ED7
		INC		DE
		JR		ED8					;00Hを取得するまでループ

ED9:	JR		ED51				;次行へ

ED91:	JP		SRET				;終了

;**** DEからの4Byteが16進数を表すアスキーコードであれば16進数に変換してHLに代入 **************
HLHEX:
		LD		HL,0000H
		LD		B,04H
HLHEX1:	LD		A,(DE)
		INC		DE
		CALL	AZLCNV				;大文字へ変換
		CALL	HEXCHK				;16進数を表すASCII文字かチェック
		JP		C,HLHEX2			;違ったらCF=1で終了
		CALL	BINCV4				;16進数へ変換
		DJNZ	HLHEX1				;4文字分ループ
HLHEX2:	RET

;*********************** 16進コード・チェック ****************************
HEXCHK:
		CP		30H					;30H～39H
		JR		C,HC04
		CP		3AH
		JR		NC,HC02
		JR		HC03
HC02:	CP		41H					;41H～46H
		JR		C,HC04
		CP		47H
		JR		NC,HC04
HC03:	OR		A
		JR		HC05
HC04:	SCF
HC05:	RET

;********************** 16進コードからバイナリ形式への変換 ********************
BINCV4:
		PUSH	AF
		CP		3AH
		JR		NC,BC01
		SUB		30H					;30H～39Hなら30Hを引く
		JR		BC02
BC01:	SUB		37H					;41H～46Hなら37Hを引く
BC02:	SLA		A					;左へ4回シフト
		SLA		A
		SLA		A
		SLA		A

		RLA							;Aレジスタ、HLレジスタをまとめて左へ4回シフト
		RL		L
		RL		H
		RLA
		RL		L
		RL		H
		RLA
		RL		L
		RL		H
		RLA
		RL		L
		RL		H
		
		POP		AF
		RET

;**** DEからの2Byteが16進数を表すアスキーコードであれば16進数に変換してAに代入 **************
TWOHEX:	PUSH	HL
		LD		HL,0000H
		LD		B,02H
TWHEX1:	LD		A,(DE)
		INC		DE
		CALL	AZLCNV				;大文字へ変換
		CALL	HEXCHK				;16進数を表すASCII文字かチェック
		JP		C,TWHEX2			;違ったらCF=1で終了
		CALL	BINCV4				;16進数へ変換
		DJNZ	TWHEX1				;2文字分ループ
		XOR		A
		LD		A,L
TWHEX2:
		POP		HL
		RET

;*********************************** GOTO ********************************
GOTO:
		LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		CALL	GETNUM				;HL <- 数値
		PUSH	AF
GT3:
		LD		A,(DE)				;00H又は「:」以外は読み飛ばし
		CP		3AH					;「:」
		JR		Z,GT5
		CP		00H
		JR		Z,GT5
		INC		DE
		JR		GT3
GT5:	LD		(HLSAVE),DE			;次文先頭位置を退避
		POP		AF
		JP		C,SEND				;数値が取得できなかったらERRORで終了

		PUSH	HL
		LD		DE,EXEFLG
		LD		HL,EXEST
		LD		BC,EXEEND-EXEST
		LDIR
		POP		HL
		LD		(EXEFLG+8),HL		;実行アドレスをセット
		
		LD		HL,4000H			;ページ1(4000H～7FFFH)をメインROMと同じスロットにする
		LD		A,(0FCC1H)
		AND		03H
		JP		EXEFLG				;ジャンプ

EXEST:
		CALL	0024H				;スロットを切り替えて実行する用
		LD		HL,(HLSAVE)
		PUSH	HL
		CALL	0000H
		POP		HL
		XOR		A
		RET
EXEEND:

PSDIR:
;************ Fコマンド DIRLIST **********************
STLT:	LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		CALL	DIRLIST				;DIRLIST本体をコール
		AND		A					;00以外ならERROR
		CALL	NZ,SDERR
		JP		SRET


;**** DIRLIST本体 (HL=行頭に付加する文字列の先頭アドレス BC=行頭に付加する文字列の長さ) ****
;****              戻り値 A=エラーコード ****
DIRLIST:
		LD		A,41H				;DIRLISTコマンド41Hを送信
		CALL	STCD				;コマンドコード送信
		AND		A					;00以外ならERROR
		JP		NZ,DLRET
		
		PUSH	BC
		LD		B,21H				;ファイルネーム検索文字列33文字分を送信
STLT1:	LD		A,(DE)
		AND		A
		JR		NZ,STLT2
		XOR		A
STLT2:
		CALL	AZLCNV				;大文字に変換
		CP		22H					;ダブルコーテーション読み飛ばし
		JR		Z,STLT22
		CP		28H					;カッコ(読み飛ばし
		JR		Z,STLT22
		CP		29H					;カッコ)読み飛ばし
		JR		Z,STLT22
		CP		3AH
		JR		NZ,STLT3			;「:」であればマルチステートメント、00Hに置き換え
		LD		A,00H
		JR		STLT3				;1文字送信へ
		
STLT22:	INC		DE					;DEをインクリメントして読み飛ばし処理
		JR		STLT1
STLT3:	PUSH	AF
		CALL	SNDBYTE				;ファイルネーム検索文字列を送信
		POP		AF
		CP		00H					;00H以外ならDEをインクリメント
		JR		Z,STLT4
		INC		DE
STLT4:	DJNZ	STLT1					;33文字分ループ
		POP		BC
		LD		(HLSAVE),DE			;文終了位置(00H)又は「:」の位置を退避
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

DL1:	LD		HL,LBUF
DL2:	CALL	RCVBYTE				;'00H'を受信するまでを一行とする
		AND		A
		JR		Z,DL3
		CP		0FFH				;'0FFH'を受信したら終了
		JR		Z,DL4
		CP		0FDH				;'0FDH'受信で文字列を取得してSETLしたことを表示
		JR		Z,DL9
		CP		0FEH				;'0FEH'を受信したら一時停止して一文字入力待ち
		JR		Z,DL5
		LD		(HL),A
		INC		HL
		JR		DL2
DL3:	LD		(HL),00H
		LD		HL,LBUF				;'00H'を受信したら一行分を表示して改行
		CALL	STRPR
DL33:	CALL	MONCLF
		JR		DL1
DL4:	CALL	RCVBYTE				;状態取得(00H=OK)
		JR		DLRET

DL9:	LD		HL,LBUF				;選択したファイルネームを再度取得
DL91:	CALL	RCVBYTE
		LD		(HL),A
		CP		00H
		INC		HL
		JR		NZ,DL91
		LD		HL,LBUF				;取得したファイルネームを表示
		CALL	STRPR
		LD		HL,MSG3				;「LOAD FILE SET OK!」を表示
		CALL	STRPR
		CALL	RCVBYTE				;状態取得(00H=OK)読み飛ばし
		CALL	RCVBYTE				;状態取得(00H=OK)読み飛ばし
		JR		DLRET

DL5:	LD		HL,MSG_KEY1			;HIT ANT KEY表示
		CALL	STRPR
		CALL	MONCLF
DL6:	CALL	KSCAN				;KEY SCAN
		
		PUSH	AF					;WAIT
		PUSH	DE
        LD      A,20H
LOP1:   LD      D,0FFH
LOP2:   DEC     D       
        JP      NZ,LOP2    
        DEC     A       
        JP      NZ,LOP1
		POP		DE
		POP		AF

		JR		Z,DL6
		CP		1BH					;ESCで打ち切り
		JR		Z,DL7
		CP		30H					;数字0～9ならそのままArduinoへ送信してSETL処理へ
		JR		C,DL61
		CP		3AH
		JR		C,DL8
DL61:	CP		1EH					;カーソル↑で打ち切り
		JR		Z,DL7
		CP		42H					;「B」で前ページ
		JR		Z,DL8
		XOR		A					;それ以外で継続
		JR		DL8
DL7:	LD		A,0FFH				;0FFH中断コードを送信
DL8:	CALL	SNDBYTE
		JP		DL1
		
DLRET:	RET

		
;****************************** 読込ファイル設定 *********************************
PSETL:	LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		LD		A,42H				;SETLコマンド42Hを送信
		CALL	STCD				;コマンドコード送信
		AND		A					;00以外ならERROR
		JP		NZ,DLRET
		CALL	CMDFN				;ファイルネーム送信
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

		LD		HL,MSG3				;「LOAD FILE SET OK!」を表示
		CALL	STRPR
		JP		SRET

;*************************** ファイルネーム送信 *********************
CMDFN:	PUSH	BC
		LD		B,21H				;ファイルネーム検索文字列33文字分を送信
CMDFN1:	LD		A,(DE)
		AND		A
		JR		NZ,CMDFN2
		XOR		A
CMDFN2:
;		CALL	AZLCNV				;大文字に変換
		CP		22H					;ダブルコーテーション読み飛ばし
		JR		Z,CMDFN22
		CP		28H					;カッコ(読み飛ばし
		JR		Z,CMDFN22
		CP		29H					;カッコ)読み飛ばし
		JR		Z,CMDFN22
		CP		2CH					;「,」であればパラメータ区切り、00Hに置き換え
		JR		Z,CMDFN21
		CP		3AH					;「:」であればマルチステートメント、00Hに置き換え
		JR		NZ,CMDFN3
CMDFN21:LD		A,00H
		JR		CMDFN3				;1文字送信へ
		
CMDFN22:INC		DE					;DEをインクリメントして読み飛ばし処理
		JR		CMDFN1
CMDFN3:	PUSH	AF
		CALL	SNDBYTE				;ファイルネーム検索文字列を送信
		POP		AF
		CP		00H					;00H以外ならDEをインクリメント
		JR		Z,CMDFN4
		
CMDFN33:INC		DE
CMDFN4:	DJNZ	CMDFN1				;33文字分ループ
		POP		BC
		LD		(HLSAVE),DE			;文終了位置(00H)又は「:」の位置を退避
		RET

;****************************** 書込ファイル設定 *********************************
PSETS:	LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		LD		A,43H				;SETSコマンド43Hを送信
		CALL	STCD				;コマンドコード送信
		AND		A					;00以外ならERROR
		JP		NZ,DLRET
		CALL	CMDFN				;ファイルネーム送信
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

		LD		HL,MSG5				;「SAVE FILE SET OK!」を表示
		CALL	STRPR
		JP		SRET

;*********************** BASICプログラムロード **************************
PSLOAD:	LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		LD		A,44H				;SLOADコマンド44Hを送信
		CALL	STCD				;コマンドコード送信
		AND		A					;00以外ならERROR
		JP		NZ,DLRET
		CALL	CMDFN				;ファイルネーム送信
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

		LD		B,06H
		LD		HL,LBUF				;ファイルネーム6文字を取得
PSL5:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSL5
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG4				;「Loading 」を表示
		CALL	STRPR
		LD		HL,LBUF				;ファイルネームを表示
		CALL	STRPR
		CALL	MONCLF
		
		LD		DE,(TXTTAB)			;DE <- BASICフリーエリア先頭アドレス
		
PSL51:	CALL	RCVBYTE				;1行の文字数を取得
		LD		L,A
		LD		H,00H
		CP		00H					;文字数0なら終了
		JR		Z,PSL53
		PUSH	HL					;文字数退避
		INC		HL
		INC		HL
		ADD		HL,DE				;リンクポインタを計算 HL=文字数(HL)+1行前のリンクポインタ値(DE)
		LD		A,L
		LD		(DE),A				;リンクポインタ書き込み
		INC		DE
		LD		A,H
		LD		(DE),A
		POP		HL					;文字数復帰
		INC		DE
PSL52:	CALL	RCVBYTE				;文字を取得
		LD		(DE),A				;文字を書き込み
		INC		DE
		DEC		L
		JR		NZ,PSL52			;文字数分1行分を取得、書き込みをループ
		JR		PSL51				;文字数0を受信するまでループ

PSL53:
		XOR		A
		LD		(DE),A				;エンドマーク00Hx2書き込み
		INC		DE
		LD		(DE),A
		INC		DE

		LD		(VARTAB),DE			;エンドマーク+1のアドレスをVARTABにセット
		LD		(ARYTAB),DE			;エンドマーク+1のアドレスをARYTABにセット
		LD		(STREND),DE			;エンドマーク+1のアドレスをSTRENDにセット

		JP		SRET

;*********************** BASICプログラムセーブ **************************
PSSAVE:	LD		DE,(TXTTAB)			;DE <- BASICフリーエリア先頭アドレス
		LD		A,(DE)
		INC		DE
		LD		B,A
		LD		A,(DE)
		OR		B
		JR		Z,PSS7				;プログラムが無ければ終了

		LD		HL,(HLSAVE)
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL
		EX		DE,HL
		LD		A,46H				;SSAVEコマンド46Hを送信
		CALL	STCD				;コマンドコード送信
		AND		A					;00以外ならERROR
		JP		NZ,DLRET
		CALL	CMDFN				;ファイルネーム送信
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

		LD		B,06H
		LD		HL,LBUF				;ファイルネーム6文字を取得
PSS5:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSS5
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG6				;「Saving 」を表示
		CALL	STRPR
		LD		HL,LBUF				;ファイルネームを表示
		CALL	STRPR
		CALL	MONCLF
		
		LD		DE,(TXTTAB)			;DE <- BASICフリーエリア先頭アドレス
		
PSS51:	LD		A,(DE)				;次行アドレスポインタ取得
		LD		L,A
		INC		DE
		LD		A,(DE)
		INC		DE
		LD		H,A
		OR		L
		JR		Z,PSS6				;次行アドレスポインタが0000HならBASICプログラムEND

		PUSH	HL
		XOR		A
		SBC		HL,DE				;次行アドレスから１行分のバイト数を計算し送信
		LD		A,L
		LD		B,L
		CALL	SNDBYTE
		POP		HL

		LD		A,L
		CALL	SNDBYTE				;次行アドレスポインタを送信
		LD		A,H
		CALL	SNDBYTE

PSS52:	LD		A,(DE)				;１行分のBASICプログラムを送信
		CALL	SNDBYTE
		INC		DE
		DJNZ	PSS52
		JR		PSS51				;次行アドレスポインタが0000Hになるまでループ

PSS6:
		XOR		A
		CALL	SNDBYTE
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR
		JP		SRET

PSS7:
		LD		HL,MSG7				;NO PROGRAMを表示
		CALL	STRPR
		JP		SRET

;*********************************** マシン語ロード ********************************
PSBLOAD:LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		LD		A,45H				;SBLOADコマンド45Hを送信
		CALL	STCD				;コマンドコード送信
		AND		A					;00以外ならERROR
		JP		NZ,DLRET
		
		PUSH	BC
		LD		B,21H				;ファイルネーム検索文字列33文字分を送信
		LD		HL,EXEFLG			;「,R」オプション用のEXEFLGをクリア
		XOR		A
		LD		(HL),A
PSBL1:	LD		A,(DE)
		AND		A
		JR		NZ,PSBL2
;		XOR		A
PSBL2:
;		CALL	AZLCNV				;大文字に変換
		CP		22H					;ダブルコーテーション読み飛ばし
		JR		Z,PSBL22
		CP		28H					;カッコ(読み飛ばし
		JR		Z,PSBL22
		CP		29H					;カッコ)読み飛ばし
		JR		Z,PSBL22
		CP		3AH
		JR		NZ,PSBL3			;「:」であればマルチステートメント、00Hに置き換え
		LD		A,00H
		JR		PSBL3				;1文字送信へ

PSBL22:	INC		DE					;DEをインクリメントして読み飛ばし処理
		JR		PSBL1
PSBL3:	
		CP		2CH					;「,」を見つけたら文字列終了として00Hを送信
		JR		NZ,PSBL32
		XOR		A
		CALL	SNDBYTE
		INC		DE
		DEC		B
		LD		A,(DE)
		CP		52H					;「,R」又は「,r」だったら自動実行をセット
		JR		Z,PSBL31
		CP		72H
		JR		NZ,PSBL32
PSBL31:	LD		A,01H
		LD		HL,EXEFLG			;自動実行するならEXEFLGに「01」、しないなら「00」
		LD		(HL),A
		XOR		A
		CALL	SNDBYTE
		JR		PSBL33
PSBL32:	PUSH	AF
		CALL	SNDBYTE				;ファイルネーム検索文字列を送信
		POP		AF
		CP		00H					;00H以外ならDEをインクリメント
		JR		Z,PSBL4
		
PSBL33:	INC		DE
PSBL4:	DJNZ	PSBL1				;33文字分ループ
		POP		BC
		LD		(HLSAVE),DE			;文終了位置(00H)又は「:」の位置を退避
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

		LD		B,06H
		LD		HL,LBUF				;ファイルネーム6文字を取得
PSBL5:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSBL5
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG4				;「Loading 」を表示
		CALL	STRPR
		LD		HL,LBUF				;ファイルネームを表示
		CALL	STRPR
		LD		A,','
		CALL	CHPUT
		
		LD		HL,SADRS			;SADRS、EADRS、GADRSを取得
		LD		B,06H
PSBL55:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSBL55
		
		LD		A,(SADRS+1)			;SADRS表示
		CALL	MONBHX
		LD		A,(SADRS)
		CALL	MONBHX
		LD		A,','
		CALL	CHPUT
		LD		A,(EADRS+1)			;EADRS表示
		CALL	MONBHX
		LD		A,(EADRS)
		CALL	MONBHX
		LD		A,','
		CALL	CHPUT
		LD		A,(GADRS+1)			;GADRS表示
		CALL	MONBHX
		LD		A,(GADRS)
		CALL	MONBHX
		CALL	MONCLF

		LD		HL,(EADRS)
		LD		DE,(SADRS)
PSBL6:	CALL	RCVBYTE				;1Byte受信
		LD		(DE),A				;(SADRS) <- A、SADRS+1
		PUSH	HL
		XOR		A
		SBC		HL,DE				;EADSR = SADRSまでループ
		POP		HL
		INC		DE
		JR		NZ,PSBL6
		LD		HL,EXEFLG
		LD		A,(HL)
		CP		01H				;EXEFLGが「01」ならGADRSを書き込む
		JR		NZ,PSBL61			;でなければ終了

		LD		DE,EXEFLG
		LD		HL,EXEST
		LD		BC,EXEEND-EXEST
		LDIR
		LD		HL,(GADRS)
		LD		(EXEFLG+8),HL		;自動実行アドレスをセット
		
		LD		HL,4000H			;ページ1(4000H～7FFFH)をメインROMと同じスロットにする
		LD		A,(0FCC1H)
		AND		03H
		JP		EXEFLG				;(GADRS)へジャンプ

PSBL61:	JP		SRET

;*********************************** マシン語セーブ ********************************
PSBSAVE:LD		HL,(HLSAVE)			;HL復帰
		CALL	STFN				;スペース、ダブルコーテーション、カッコを除去
		LD		(HLSAVE),HL			;HL退避
		EX		DE,HL
		LD		A,47H				;SBSAVEコマンド47Hを送信
		CALL	STCD				;コマンドコード送信
		AND		A					;00以外ならERROR
		JP		NZ,DLRET
		CALL	CMDFN				;ファイルネーム送信

		CALL	NUMSET
		LD		(SADRS),HL			;スタートアドレスを取得、数値を取得できなければエラー終了
		JP		C,PSBS7
		
		CALL	NUMSET
		LD		(EADRS),HL			;エンドアドレスを取得、数値を取得できなければエラー終了
		JP		C,PSBS7
		
		PUSH	HL
		PUSH	DE
		LD		DE,(SADRS)
		XOR		A
		SBC		HL,DE
		POP		DE
		POP		HL
		JP		C,PSBS7				;エンドアドレス>=スタートアドレスでなければエラー終了

		CALL	NUMSET
		LD		(GADRS),HL			;実行アドレスを取得、数値を取得できなければエラー終了
		JP		C,PSBS7

		XOR		A
		CALL	SNDBYTE				;ファイルネーム、各数値が正常に取得出来たら続行指示

		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR

PSBS1:	LD		A,(DE)				;00H又は「:」以外は読み飛ばし
		CP		3AH					;「:」
		JR		Z,PSBS2
		CP		00H
		JR		Z,PSBS2
		INC		DE
		JR		PSBS1
PSBS2:	LD		(HLSAVE),DE			;次文先頭位置を退避
		

		LD		B,06H
		LD		HL,LBUF				;ファイルネーム6文字を取得
PSBS22:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSBS22
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG6				;「Saving 」を表示
		CALL	STRPR
		LD		HL,LBUF				;ファイルネームを表示
		CALL	STRPR
		CALL	MONCLF
		
		LD		B,06H
		LD		HL,SADRS			;スタートアドレス、エンドアドレス、実行アドレスを送信
PSBS23:	LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		DJNZ	PSBS23

		LD		DE,(SADRS)
PSBS3:	LD		HL,(EADRS)
		LD		A,(DE)
		CALL	SNDBYTE				;スタートアドレスからエンドアドレスまでのデータを読み出して送信
		XOR		A
		SBC		HL,DE
		INC		DE
		LD		A,H
		OR		L
		JR		NZ,PSBS3

PSBS6:
		CALL	RCVBYTE				;状態取得(00H=OK)
		AND		A					;00以外ならERROR
		JP		NZ,SDERR
		JP		SRET

PSBS7:
		LD		A,0FFH				;エラー終了、打ち切りを指示
		CALL	SNDBYTE
		JP		SDERR

;********************* (DE)から数値を取得してHLへセット、取得できなければCF=1
NUMSET:	LD		A,(DE)
		CP		2CH					;コンマ読み飛ばし
		JP		NZ,NUMST1
		INC		DE
		LD		A,(DE)
		CP		00H					;00Hなら数値無し
		JP		Z,NUMST1
		CALL	GETNUM				;数値を取得
		JP		C,NUMST1
		RET
NUMST1:
		SCF							;エラー終了
		RET

;**** コマンド送信 (IN:A コマンドコード)****
STCD:	CALL	SNDBYTE				;Aレジスタのコマンドコードを送信
		CALL	RCVBYTE				;状態取得(00H=OK)
		RET

;**** コマンド、ファイル名送信 (IN:A コマンドコード HL:ファイルネームの先頭)****
STCMD:	INC		HL
		CALL	STFN				;空白除去
		PUSH	HL
		CALL	STCD				;コマンドコード送信
		POP		HL
		AND		A					;00以外ならERROR
		JP		NZ,SDERR
		CALL	STFS				;ファイルネーム送信
		AND		A					;00以外ならERROR
		JP		NZ,SDERR
		RET

;**** ファイルネーム送信(IN:HL ファイルネームの先頭) ******
STFS:	LD		B,20H
STFS1:	LD		A,(HL)				;FNAME送信
		CP		22H
		JR		Z,STFS11
		CP		28H
		JR		Z,STFS11
		CP		29H
		JR		NZ,STFS2
STFS11:	INC		HL
		JR		STFS1
STFS2:	PUSH	AF
		CALL	SNDBYTE
		POP		AF
		CP		00H
		JR		Z,STFS3
		INC		HL
STFS3:	DEC		B
		JR		NZ,STFS1
		LD		A,0DH
		CALL	SNDBYTE
		LD		(HLSAVE),HL
		CALL	RCVBYTE				;状態取得(00H=OK)
		RET

;****** FILE NAMEが取得できるまでスペース、ダブルコーテーション、カッコを読み飛ばし (IN:HL コマンド文字の次の文字 OUT:HL ファイルネームの先頭)*********
STFN:	PUSH	AF
STFN1:	LD		A,(HL)
		CP		20H
		JR		Z,STFN2
		CP		22H
		JR		Z,STFN2
		CP		28H
		JR		NZ,STFN3
STFN2:	INC		HL					;ファイルネームまでスペース読み飛ばし
		JR		STFN1
STFN3:	POP		AF
		RET

DEFDIR:
		DB		'_SETL '
DEND:

;************** エラー内容表示 *****************************
SDERR:
		PUSH	AF
		CP		0F0H
		JR		NZ,ERR3
		LD		HL,MSG_F0			;SD-CARD INITIALIZE ERROR
		JR		ERRMSG
ERR3:	CP		0F1H
		JR		NZ,ERR4
		LD		HL,MSG_F1			;NOT FIND FILE
		JR		ERRMSG
ERR4:	CP		0F3H
		JR		NZ,ERR99
		LD		HL,MSG_F3			;FILE EXIST
		JR		ERRMSG
ERR99:
		CALL	MONBHX
		LD		HL,MSG99			;その他ERROR
ERRMSG:	CALL	STRPR
		CALL	MONCLF
		CALL	BEEP
		POP		AF
		JP		SRET

;************** Aレジスタの値を16進数として表示
MONBHX:	PUSH	AF
		SRL		A
		SRL		A
		SRL		A
		SRL		A
		CALL	MH0
		CALL	CHPUT
		POP		AF
		AND		0FH
		CALL	MH0
		CALL	CHPUT
		RET

MH0:	CP		0AH
		JR		NC,MH1
		ADD		A,30H
		JR		MH2
MH1:	ADD		A,37H
MH2:	RET

;************ Aレジスタのアルファベット小文字を大文字に変換
AZLCNV:	CP		61H
		JR		C,AZ1
		CP		7BH
		JR		NC,AZ1
		SUB		20H
AZ1:	RET

;************ キーボードスキャン
;押されていなければ A <- 00H、Z=1
;押されていれば     A <- ASCIIコード(KTBLから取得)
KSCAN:	LD		C,00H				;マトリックス行初期値
KS1:	LD		A,C					;A <- マトリックス行
		CALL	SNSMAT				;スキャン
		CP		0FFH
		JR		NZ,KS2				;何か押されていればKS2へ
		LD		A,C
		INC		A					;マトリックス行+1
		LD		C,A
		CP		0BH					;10回のスキャンが終わるまでKS1へ
		JR		NZ,KS1
		XOR		A					;何も押されていなかったらA <- 00Hでリターン
		RET
KS2:	LD		B,00H
KS3:	SLA		A					;ビットをバイトに変換して加算
		JR		NC,KS4
		INC		B
		JR		KS3
KS4:	LD		HL,KTBL				;KTBL+マトリックス行*8+ビットからバイトへ変換した数値で計算する
		LD		DE,0008H
		LD		A,C
KS5:	CP		00H
		JR		Z,KS6
		ADD		HL,DE
		DEC		A
		JR		KS5
KS6:	LD		E,B
		LD		D,00H
		ADD		HL,DE
		CALL	CHGET
		LD		A,(HL)
		CP		00H
		RET

KTBL:	DB		37H,36H,35H,34H,33H,32H,31H,30H
		DB		3BH,5BH,40H,5CH,5EH,2DH,39H,38H
		DB		42H,41H,5FH,2FH,2EH,2CH,5DH,3AH
		DB		4AH,49H,48H,47H,46H,45H,44H,43H
		DB		52H,51H,50H,4FH,4EH,4DH,4CH,4BH
		DB		5AH,59H,58H,57H,56H,55H,54H,53H
		DB		87H,86H,85H,84H,83H,82H,81H,80H
		DB		0DH,8EH,42H,1BH,8BH,1BH,89H,88H		;「BS」を「B」に変更
		DB		1CH,1FH,1EH,1DH,7FH,92H,0BH,20H
		DB		34H,33H,32H,31H,30H,9AH,99H,98H
		DB		2CH,2EH,2DH,39H,38H,37H,36H,35H

;************* 改行を表示
MONCLF:	PUSH	HL
		LD		HL,CRLF
		CALL	STRPR
		POP		HL
		RET

;************* (HL)からの文字列を00Hまで表示
STRPR:	LD		A,(HL)
		CP		00H
		JR		Z,STRPR1
		CALL	CHPUT
		INC		HL
		JR		STRPR
STRPR1:	RET

MSG_KEY1:
		DB		'SEL:0-9 NXT:ANY BCK:B BRK:ESC'
		DB		00H

MSG3:
		DB		'LOAD FILE SET OK!',0DH,0AH,00H

MSG4:
		DB		'Loading ',00H

MSG5:
		DB		'SAVE FILE SET OK!',0DH,0AH,00H

MSG6:
		DB		'Saving ',00H

MSG7:
		DB		'NO PROGRAM',0DH,0AH,00H

CRLF:	DB		0DH,0AH,00H

MSG_F0:
		DB		'SD-CARD INITIALIZE ERROR'
		DB		00H
		
MSG_F1:
		DB		'NOT FIND FILE'
		DB		00H
		
MSG_F3:
		DB		'FILE EXIST'
		DB		00H
		
MSG99:
		DB		' ERROR'
		DB		00H
		
;**** 1BYTE受信 ****
;受信DATAをAレジスタにセットしてリターン
RCVBYTE:
		CALL	F1CHK 				;PORTC BIT7が1になるまでLOOP
		IN		A,(PPI_B)			;PORTB -> A
		PUSH 	AF
		LD		A,05H
		OUT		(PPI_R),A			;PORTC BIT2 <- 1
		CALL	F2CHK				;PORTC BIT7が0になるまでLOOP
		LD		A,04H
		OUT		(PPI_R),A			;PORTC BIT2 <- 0
		POP 	AF
		RET
		
;**** 1BYTE送信 ****
;Aレジスタの内容をPORTA下位4BITに4BITずつ送信
SNDBYTE:
		PUSH	AF
		RRA
		RRA
		RRA
		RRA
		AND		0FH
		CALL	SND4BIT
		POP		AF
		AND		0FH
		CALL	SND4BIT
		RET

;**** 4BIT送信 ****
;Aレジスタ下位4ビットを送信する
SND4BIT:
		OUT		(PPI_A),A
		LD		A,05H
		OUT		(PPI_R),A			;PORTC BIT2 <- 1
		CALL	F1CHK				;PORTC BIT7が1になるまでLOOP
		LD		A,04H
		OUT		(PPI_R),A			;PORTC BIT2 <- 0
		CALL	F2CHK
		RET
		
;**** BUSYをCHECK(1) ****
; 82H BIT7が1になるまでLOP
F1CHK:	IN		A,(PPI_C)
		AND		80H					;PORTC BIT7 = 1?
		JR		Z,F1CHK
		RET

;**** BUSYをCHECK(0) ****
; 82H BIT7が0になるまでLOOP
F2CHK:	IN		A,(PPI_C)
		AND		80H					;PORTC BIT7 = 0?
		JR		NZ,F2CHK
		RET

		END
