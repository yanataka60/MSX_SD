;MSX
PPI_A		EQU		038H
PPI_B		EQU		PPI_A+1
PPI_C		EQU		PPI_A+2
PPI_R		EQU		PPI_A+3

			ORG		0FDEFH

TAPION:		JP		READHEAD			;00E1H
TAPIN:		JP		READ1BYTE			;00E4H
TAPOON:		JP		0000H				;00EAH
TAPOUT:		JP		0000H				;00EDH
TAPOOF:		JP		0000H				;00F0H
TDIR:		JP		0000H


READHEAD:
			DI
			LD		A,48H
			CALL	STCD
			XOR		A
			RET
			
READ1BYTE:
			LD		A,49H				;READ1BYTE コマンド49Hを送信
			CALL	SNDBYTE
			CALL	RCVBYTE				;1Byteのみ受信
			OR		A
			RET


;**** コマンド送信 (IN:A コマンドコード)****
STCD:	CALL	SNDBYTE				;Aレジスタのコマンドコードを送信
		CALL	RCVBYTE				;状態取得(00H=OK)
		RET

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
