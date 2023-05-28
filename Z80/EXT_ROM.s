;2023.5.22 �L�[�X�L�������[�`����WAIT��ǉ�
;2023.5.28 _SBLOAD(,R)�A_GOTO�R�}���h����̃��^�[������HL���W�X�^�𕜋A���Ă��Ȃ������o�O���C��
;           _GOTO�R�}���h�Ő��l�ȗ����Ƀ}���`�X�e�[�g�����g�ɑΉ����Ă��Ȃ������o�O���C��
;            �}�V���ꎩ�����s�p���[�N�G���A����

CHGET		EQU		009FH			;1��������
CHPUT		EQU		00A2H			;1�����\��
BEEP		EQU		00C0H			;BEEP
SNSMAT		EQU		0141H			;�L�[�}�g���b�N�X�X�L����
KILBUF		EQU		0156H			;�L�[�{�[�h�o�b�t�@����ɂ���

BUF			EQU		0F55EH			;�s�o�b�t�@
TXTTAB		EQU		0F676H			; BASIC�e�L�X�g�G���A�̐擪�Ԓn
VARTAB		EQU		0F6C2H			; �P���ϐ��G���A�̊J�n�Ԓn
ARYTAB		EQU		0F6C4H			; �z��e�[�u���G���A�̊J�n�Ԓn
STREND		EQU		0F6C6H			; �e�L�X�g�G���A��ϐ��G���A�Ƃ��Ďg�p���ł��郁�����̍Ō�̔Ԓn(�t���[�G���A)
HLSAVE		EQU		0F7C5H			;Math-pack�p���[�N�G���A�𗬗p�@HL���W�X�^�ޔ�p
SADRS		EQU		HLSAVE+2		;Math-pack�p���[�N�G���A�𗬗p�@LOAD�ASAVE�X�^�[�g�A�h���X
EADRS		EQU		HLSAVE+4		;Math-pack�p���[�N�G���A�𗬗p�@LOAD�ASAVE�G���h�A�h���X
GADRS		EQU		HLSAVE+6		;Math-pack�p���[�N�G���A�𗬗p�@�}�V������s�A�h���X
LBUF		EQU		HLSAVE+8		;Math-pack�p���[�N�G���A�𗬗p�@�s�o�b�t�@�y�ю������s������i�[��
EXEFLG		EQU		0FB04H			;RS-232C�p���[�N�G���A�𗬗p�@�}�V���ꎩ�����s�p
PROCNM		EQU		0FD89H			;CALL�R�}���h������

;MSX
PPI_A		EQU		038H
PPI_B		EQU		PPI_A+1
PPI_C		EQU		PPI_A+2
PPI_R		EQU		PPI_A+3

;MSX
;8255 PORT �A�h���X 3CH�`3FH
;07CH PORTA ���M�f�[�^(����4�r�b�g)
;07DH PORTB ��M�f�[�^(8�r�b�g)
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
;3FH �R���g���[�����W�X�^

;_SDIR				41H
;_SETL				42H
;_SETS				43H
;_SLOAD				44H
;_SBLOAD			45H
;_SSAVE				46H
;_SBSAVE			47H

        ORG		4000H

		DB		'A','B'				;�g��ROM�F���R�[�h
		DW		INIT				;INIT
		DW		SRCH				;STATEMENT
		DW		0000H				;DEVICE
		DW		0000H				;TEXT
		DW		0000H				;RESERVE
		DW		0000H
		DW		0000H

INIT:
;**** 8255������ ****
;PORTC����BIT��OUTPUT�A���BIT��INPUT�APORTB��INPUT�APORTA��OUTPUT
		LD		A,8AH
		OUT		(PPI_R),A
;�o��BIT�����Z�b�g
		XOR		A					;PORTA <- 0
		OUT		(PPI_A),A
		OUT		(PPI_C),A			;PORTC <- 0

		RET

SRCH:
		LD		(HLSAVE),HL			;HL�ޔ�
		LD		DE,PROCNM
		LD		A,(DE)
		CP		'D'
		JR		Z,DUMP				;_DUMP�R�}���h
		CP		'E'
		JP		Z,EDIT				;_EDIT�R�}���h
		CP		'G'
		JP		Z,GOTO				;_GOTO�R�}���h
		CP		'S'
		JR		NZ,SEND
		INC		DE
		LD		A,(DE)
		CP		'B'
		JR		Z,PROCSB
		CP		'D'
		JP		Z,PSDIR				;_SDIR�R�}���h
		CP		'E'
		JR		Z,PROCSE
		CP		'L'
		JP		Z,PSLOAD			;_SLOAD�R�}���h
		CP		'S'
		JP		Z,PSSAVE			;_SSAVE�R�}���h
		JR		SEND

PROCSB:	INC		DE
		LD		A,(DE)
		CP		'L'
		JP		Z,PSBLOAD			;_SBLOAD�R�}���h
		CP		'S'
		JP		Z,PSBSAVE			;_SBSAVE�R�}���h
SEND:
		LD		HL,(HLSAVE)			;HL���A
		SCF							;CALL�R�}���h�s��v
		RET

PROCSE:	INC		DE
		LD		A,(DE)
		CP		'T'
		JR		NZ,SEND
		INC		DE
		LD		A,(DE)
		CP		'L'
		JP		Z,PSETL				;_SETL�R�}���h
		CP		'S'
		JP		Z,PSETS				;_SETS�R�}���h
		JR		SEND

SRET:
		LD		HL,(HLSAVE)			;HL���A
		XOR		A					;����I��
		RET

;*********************************** MEMORY DUMP ********************************
DUMP:
		LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		CALL	GETNUM				;HL <- ���l
		PUSH	AF
DP3:	LD		A,(DE)				;00H���́u:�v�ȊO�͓ǂݔ�΂�
		CP		3AH					;�u:�v
		JR		Z,DP5
		CP		00H
		JR		Z,DP5
		INC		DE
		JR		DP3
DP5:	LD		(HLSAVE),DE			;�����擪�ʒu��ޔ�
		POP		AF
		JP		C,SEND				;���l���擾�ł��Ȃ�������ERROR�ŏI��

		LD		C,10H				;16�s���[�v
DP6		LD		A,H
		CALL	MONBHX				;�A�h���X�\��
		LD		A,L
		CALL	MONBHX
		LD		B,08H				;��8Byte�����[�v
DP7:	LD		A,20H
		CALL	CHPUT
		LD		A,(HL)
		CALL	MONBHX				;���������e��\��
		INC		HL
		DJNZ	DP7
		CALL	MONCLF				;���s
		DEC		C
		JR		NZ,DP6
		LD		(GADRS),HL			;�I���A�h���X+1��ޔ��@�p�����[�^����_DUMP�R�}���h�ő�����\��
		JP		SRET

;********************* (DE)����̐��l���擾����HL�Ɋi�[ CF=0�A��Ȃ�HL <- (SADRS) CF=0�A���l�łȂ���� CF=1
GETNUM:	LD		A,(DE)
		CP		0CH					;16�i��
		JR		Z,GN1
		CP		0FH					;10�`255�̐���
		JR		Z,GN01
		CP		1CH					;256�`32767�̐���
		JR		Z,GN1
		CP		00H					;�p�����[�^�Ȃ�
		JR		Z,GN0
		CP		3AH					;�p�����[�^�Ȃ�
		JR		Z,GN0
		CP		11H					;11H�`1BH�Ȃ�0�`9�̐���
		JR		C,GN00				;���l�̎��ʃR�[�h�Ȃ���
		CP		1BH
		JR		C,GN02
GN00:	SCF							;���l�̎��ʃR�[�h�Ȃ� CF=1
		JR		GN2
GN0:	LD		HL,(GADRS)			;HL <- (GADRS)�@_DUMP�p�p�����[�^�����Ȃ瑱���A�h���X���Z�b�g
		DEC		DE
		JR		GN11
		
GN01:	INC		DE					;10�`255�̐���
		LD		A,(DE)
		LD		L,A
		LD		H,00H
		JR		GN11
		
GN02:	SUB		11H					;11H�`1BH�Ȃ�0�`9�̐��� A-11H
		LD		L,A
		LD		H,00H
		JR		GN11
		
GN1:	INC		DE					;16�i������256�`32767�̐���
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
		LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		CALL	GETNUM				;HL <- ���l
		PUSH	AF
ED3:	LD		A,(DE)				;00H���́u:�v�ȊO�͓ǂݔ�΂�
		CP		3AH					;�u:�v
		JR		Z,ED5
		CP		00H
		JR		Z,ED5
		INC		DE
		JR		ED3
ED5:	LD		(HLSAVE),DE			;�����擪�ʒu��ޔ�
		POP		AF
		JP		C,ED91				;���l���擾�ł��Ȃ�������ERROR�ŏI��

ED51:	LD		A,H					;�A�h���X�\��
		CALL	MONBHX
		LD		A,L
		CALL	MONBHX
		LD		A,20H
		CALL	CHPUT

		CALL	00AEH				;1�s����
		LD		DE,BUF				;�s�o�b�t�@

		CALL	HLHEX				;�A�h���X�Ď擾
		JR		C,ED91
		
ED6:	LD		A,(DE)
		AND		A					;�A�h���X�݂̂Ȃ�I��
		JR		Z,ED91
		CP		20H					;�X�y�[�X�ǂݔ�΂�
		JR		NZ,ED7
		INC		DE
		JR		ED6

ED7:	CALL	TWOHEX				;�f�[�^�擾
		JR		C,ED9				;16�i���łȂ����1�s�I��
		LD		(HL),A				;�擾����16�i������������
		INC		HL

ED8:	LD		A,(DE)				;���f�[�^�擾
		AND		A					;�f�[�^���������1�s�I��
		JR		Z,ED9
		CP		20H					;�X�y�[�X�ǂݔ�΂�
		JR		NZ,ED7
		INC		DE
		JR		ED8					;00H���擾����܂Ń��[�v

ED9:	JR		ED51				;���s��

ED91:	JP		SRET				;�I��

;**** DE�����4Byte��16�i����\���A�X�L�[�R�[�h�ł����16�i���ɕϊ�����HL�ɑ�� **************
HLHEX:
		LD		HL,0000H
		LD		B,04H
HLHEX1:	LD		A,(DE)
		INC		DE
		CALL	AZLCNV				;�啶���֕ϊ�
		CALL	HEXCHK				;16�i����\��ASCII�������`�F�b�N
		JP		C,HLHEX2			;�������CF=1�ŏI��
		CALL	BINCV4				;16�i���֕ϊ�
		DJNZ	HLHEX1				;4���������[�v
HLHEX2:	RET

;*********************** 16�i�R�[�h�E�`�F�b�N ****************************
HEXCHK:
		CP		30H					;30H�`39H
		JR		C,HC04
		CP		3AH
		JR		NC,HC02
		JR		HC03
HC02:	CP		41H					;41H�`46H
		JR		C,HC04
		CP		47H
		JR		NC,HC04
HC03:	OR		A
		JR		HC05
HC04:	SCF
HC05:	RET

;********************** 16�i�R�[�h����o�C�i���`���ւ̕ϊ� ********************
BINCV4:
		PUSH	AF
		CP		3AH
		JR		NC,BC01
		SUB		30H					;30H�`39H�Ȃ�30H������
		JR		BC02
BC01:	SUB		37H					;41H�`46H�Ȃ�37H������
BC02:	SLA		A					;����4��V�t�g
		SLA		A
		SLA		A
		SLA		A

		RLA							;A���W�X�^�AHL���W�X�^���܂Ƃ߂č���4��V�t�g
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

;**** DE�����2Byte��16�i����\���A�X�L�[�R�[�h�ł����16�i���ɕϊ�����A�ɑ�� **************
TWOHEX:	PUSH	HL
		LD		HL,0000H
		LD		B,02H
TWHEX1:	LD		A,(DE)
		INC		DE
		CALL	AZLCNV				;�啶���֕ϊ�
		CALL	HEXCHK				;16�i����\��ASCII�������`�F�b�N
		JP		C,TWHEX2			;�������CF=1�ŏI��
		CALL	BINCV4				;16�i���֕ϊ�
		DJNZ	TWHEX1				;2���������[�v
		XOR		A
		LD		A,L
TWHEX2:
		POP		HL
		RET

;*********************************** GOTO ********************************
GOTO:
		LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		CALL	GETNUM				;HL <- ���l
		PUSH	AF
GT3:
		LD		A,(DE)				;00H���́u:�v�ȊO�͓ǂݔ�΂�
		CP		3AH					;�u:�v
		JR		Z,GT5
		CP		00H
		JR		Z,GT5
		INC		DE
		JR		GT3
GT5:	LD		(HLSAVE),DE			;�����擪�ʒu��ޔ�
		POP		AF
		JP		C,SEND				;���l���擾�ł��Ȃ�������ERROR�ŏI��

		PUSH	HL
		LD		DE,EXEFLG
		LD		HL,EXEST
		LD		BC,EXEEND-EXEST
		LDIR
		POP		HL
		LD		(EXEFLG+8),HL		;���s�A�h���X���Z�b�g
		
		LD		HL,4000H			;�y�[�W1(4000H�`7FFFH)�����C��ROM�Ɠ����X���b�g�ɂ���
		LD		A,(0FCC1H)
		AND		03H
		JP		EXEFLG				;�W�����v

EXEST:
		CALL	0024H				;�X���b�g��؂�ւ��Ď��s����p
		LD		HL,(HLSAVE)
		PUSH	HL
		CALL	0000H
		POP		HL
		XOR		A
		RET
EXEEND:

PSDIR:
;************ F�R�}���h DIRLIST **********************
STLT:	LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		CALL	DIRLIST				;DIRLIST�{�̂��R�[��
		AND		A					;00�ȊO�Ȃ�ERROR
		CALL	NZ,SDERR
		JP		SRET


;**** DIRLIST�{�� (HL=�s���ɕt�����镶����̐擪�A�h���X BC=�s���ɕt�����镶����̒���) ****
;****              �߂�l A=�G���[�R�[�h ****
DIRLIST:
		LD		A,41H				;DIRLIST�R�}���h41H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		
		PUSH	BC
		LD		B,21H				;�t�@�C���l�[������������33�������𑗐M
STLT1:	LD		A,(DE)
		AND		A
		JR		NZ,STLT2
		XOR		A
STLT2:
		CALL	AZLCNV				;�啶���ɕϊ�
		CP		22H					;�_�u���R�[�e�[�V�����ǂݔ�΂�
		JR		Z,STLT22
		CP		28H					;�J�b�R(�ǂݔ�΂�
		JR		Z,STLT22
		CP		29H					;�J�b�R)�ǂݔ�΂�
		JR		Z,STLT22
		CP		3AH
		JR		NZ,STLT3			;�u:�v�ł���΃}���`�X�e�[�g�����g�A00H�ɒu������
		LD		A,00H
		JR		STLT3				;1�������M��
		
STLT22:	INC		DE					;DE���C���N�������g���ēǂݔ�΂�����
		JR		STLT1
STLT3:	PUSH	AF
		CALL	SNDBYTE				;�t�@�C���l�[������������𑗐M
		POP		AF
		CP		00H					;00H�ȊO�Ȃ�DE���C���N�������g
		JR		Z,STLT4
		INC		DE
STLT4:	DJNZ	STLT1					;33���������[�v
		POP		BC
		LD		(HLSAVE),DE			;���I���ʒu(00H)���́u:�v�̈ʒu��ޔ�
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

DL1:	LD		HL,LBUF
DL2:	CALL	RCVBYTE				;'00H'����M����܂ł���s�Ƃ���
		AND		A
		JR		Z,DL3
		CP		0FFH				;'0FFH'����M������I��
		JR		Z,DL4
		CP		0FDH				;'0FDH'��M�ŕ�������擾����SETL�������Ƃ�\��
		JR		Z,DL9
		CP		0FEH				;'0FEH'����M������ꎞ��~���Ĉꕶ�����͑҂�
		JR		Z,DL5
		LD		(HL),A
		INC		HL
		JR		DL2
DL3:	LD		(HL),00H
		LD		HL,LBUF				;'00H'����M�������s����\�����ĉ��s
		CALL	STRPR
DL33:	CALL	MONCLF
		JR		DL1
DL4:	CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		JR		DLRET

DL9:	LD		HL,LBUF				;�I�������t�@�C���l�[�����ēx�擾
DL91:	CALL	RCVBYTE
		LD		(HL),A
		CP		00H
		INC		HL
		JR		NZ,DL91
		LD		HL,LBUF				;�擾�����t�@�C���l�[����\��
		CALL	STRPR
		LD		HL,MSG3				;�uLOAD FILE SET OK!�v��\��
		CALL	STRPR
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)�ǂݔ�΂�
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)�ǂݔ�΂�
		JR		DLRET

DL5:	LD		HL,MSG_KEY1			;HIT ANT KEY�\��
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
		CP		1BH					;ESC�őł��؂�
		JR		Z,DL7
		CP		30H					;����0�`9�Ȃ炻�̂܂�Arduino�֑��M����SETL������
		JR		C,DL61
		CP		3AH
		JR		C,DL8
DL61:	CP		1EH					;�J�[�\�����őł��؂�
		JR		Z,DL7
		CP		42H					;�uB�v�őO�y�[�W
		JR		Z,DL8
		XOR		A					;����ȊO�Ōp��
		JR		DL8
DL7:	LD		A,0FFH				;0FFH���f�R�[�h�𑗐M
DL8:	CALL	SNDBYTE
		JP		DL1
		
DLRET:	RET

		
;****************************** �Ǎ��t�@�C���ݒ� *********************************
PSETL:	LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		LD		A,42H				;SETL�R�}���h42H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		CALL	CMDFN				;�t�@�C���l�[�����M
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

		LD		HL,MSG3				;�uLOAD FILE SET OK!�v��\��
		CALL	STRPR
		JP		SRET

;*************************** �t�@�C���l�[�����M *********************
CMDFN:	PUSH	BC
		LD		B,21H				;�t�@�C���l�[������������33�������𑗐M
CMDFN1:	LD		A,(DE)
		AND		A
		JR		NZ,CMDFN2
		XOR		A
CMDFN2:
;		CALL	AZLCNV				;�啶���ɕϊ�
		CP		22H					;�_�u���R�[�e�[�V�����ǂݔ�΂�
		JR		Z,CMDFN22
		CP		28H					;�J�b�R(�ǂݔ�΂�
		JR		Z,CMDFN22
		CP		29H					;�J�b�R)�ǂݔ�΂�
		JR		Z,CMDFN22
		CP		2CH					;�u,�v�ł���΃p�����[�^��؂�A00H�ɒu������
		JR		Z,CMDFN21
		CP		3AH					;�u:�v�ł���΃}���`�X�e�[�g�����g�A00H�ɒu������
		JR		NZ,CMDFN3
CMDFN21:LD		A,00H
		JR		CMDFN3				;1�������M��
		
CMDFN22:INC		DE					;DE���C���N�������g���ēǂݔ�΂�����
		JR		CMDFN1
CMDFN3:	PUSH	AF
		CALL	SNDBYTE				;�t�@�C���l�[������������𑗐M
		POP		AF
		CP		00H					;00H�ȊO�Ȃ�DE���C���N�������g
		JR		Z,CMDFN4
		
CMDFN33:INC		DE
CMDFN4:	DJNZ	CMDFN1				;33���������[�v
		POP		BC
		LD		(HLSAVE),DE			;���I���ʒu(00H)���́u:�v�̈ʒu��ޔ�
		RET

;****************************** �����t�@�C���ݒ� *********************************
PSETS:	LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		LD		A,43H				;SETS�R�}���h43H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		CALL	CMDFN				;�t�@�C���l�[�����M
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

		LD		HL,MSG5				;�uSAVE FILE SET OK!�v��\��
		CALL	STRPR
		JP		SRET

;*********************** BASIC�v���O�������[�h **************************
PSLOAD:	LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		LD		A,44H				;SLOAD�R�}���h44H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		CALL	CMDFN				;�t�@�C���l�[�����M
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

		LD		B,06H
		LD		HL,LBUF				;�t�@�C���l�[��6�������擾
PSL5:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSL5
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG4				;�uLoading �v��\��
		CALL	STRPR
		LD		HL,LBUF				;�t�@�C���l�[����\��
		CALL	STRPR
		CALL	MONCLF
		
		LD		DE,(TXTTAB)			;DE <- BASIC�t���[�G���A�擪�A�h���X
		
PSL51:	CALL	RCVBYTE				;1�s�̕��������擾
		LD		L,A
		LD		H,00H
		CP		00H					;������0�Ȃ�I��
		JR		Z,PSL53
		PUSH	HL					;�������ޔ�
		INC		HL
		INC		HL
		ADD		HL,DE				;�����N�|�C���^���v�Z HL=������(HL)+1�s�O�̃����N�|�C���^�l(DE)
		LD		A,L
		LD		(DE),A				;�����N�|�C���^��������
		INC		DE
		LD		A,H
		LD		(DE),A
		POP		HL					;���������A
		INC		DE
PSL52:	CALL	RCVBYTE				;�������擾
		LD		(DE),A				;��������������
		INC		DE
		DEC		L
		JR		NZ,PSL52			;��������1�s�����擾�A�������݂����[�v
		JR		PSL51				;������0����M����܂Ń��[�v

PSL53:
		XOR		A
		LD		(DE),A				;�G���h�}�[�N00Hx2��������
		INC		DE
		LD		(DE),A
		INC		DE

		LD		(VARTAB),DE			;�G���h�}�[�N+1�̃A�h���X��VARTAB�ɃZ�b�g
		LD		(ARYTAB),DE			;�G���h�}�[�N+1�̃A�h���X��ARYTAB�ɃZ�b�g
		LD		(STREND),DE			;�G���h�}�[�N+1�̃A�h���X��STREND�ɃZ�b�g

		JP		SRET

;*********************** BASIC�v���O�����Z�[�u **************************
PSSAVE:	LD		DE,(TXTTAB)			;DE <- BASIC�t���[�G���A�擪�A�h���X
		LD		A,(DE)
		INC		DE
		LD		B,A
		LD		A,(DE)
		OR		B
		JR		Z,PSS7				;�v���O������������ΏI��

		LD		HL,(HLSAVE)
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL
		EX		DE,HL
		LD		A,46H				;SSAVE�R�}���h46H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		CALL	CMDFN				;�t�@�C���l�[�����M
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

		LD		B,06H
		LD		HL,LBUF				;�t�@�C���l�[��6�������擾
PSS5:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSS5
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG6				;�uSaving �v��\��
		CALL	STRPR
		LD		HL,LBUF				;�t�@�C���l�[����\��
		CALL	STRPR
		CALL	MONCLF
		
		LD		DE,(TXTTAB)			;DE <- BASIC�t���[�G���A�擪�A�h���X
		
PSS51:	LD		A,(DE)				;���s�A�h���X�|�C���^�擾
		LD		L,A
		INC		DE
		LD		A,(DE)
		INC		DE
		LD		H,A
		OR		L
		JR		Z,PSS6				;���s�A�h���X�|�C���^��0000H�Ȃ�BASIC�v���O����END

		PUSH	HL
		XOR		A
		SBC		HL,DE				;���s�A�h���X����P�s���̃o�C�g�����v�Z�����M
		LD		A,L
		LD		B,L
		CALL	SNDBYTE
		POP		HL

		LD		A,L
		CALL	SNDBYTE				;���s�A�h���X�|�C���^�𑗐M
		LD		A,H
		CALL	SNDBYTE

PSS52:	LD		A,(DE)				;�P�s����BASIC�v���O�����𑗐M
		CALL	SNDBYTE
		INC		DE
		DJNZ	PSS52
		JR		PSS51				;���s�A�h���X�|�C���^��0000H�ɂȂ�܂Ń��[�v

PSS6:
		XOR		A
		CALL	SNDBYTE
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		JP		SRET

PSS7:
		LD		HL,MSG7				;NO PROGRAM��\��
		CALL	STRPR
		JP		SRET

;*********************************** �}�V���ꃍ�[�h ********************************
PSBLOAD:LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		LD		A,45H				;SBLOAD�R�}���h45H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		
		PUSH	BC
		LD		B,21H				;�t�@�C���l�[������������33�������𑗐M
		LD		HL,EXEFLG			;�u,R�v�I�v�V�����p��EXEFLG���N���A
		XOR		A
		LD		(HL),A
PSBL1:	LD		A,(DE)
		AND		A
		JR		NZ,PSBL2
;		XOR		A
PSBL2:
;		CALL	AZLCNV				;�啶���ɕϊ�
		CP		22H					;�_�u���R�[�e�[�V�����ǂݔ�΂�
		JR		Z,PSBL22
		CP		28H					;�J�b�R(�ǂݔ�΂�
		JR		Z,PSBL22
		CP		29H					;�J�b�R)�ǂݔ�΂�
		JR		Z,PSBL22
		CP		3AH
		JR		NZ,PSBL3			;�u:�v�ł���΃}���`�X�e�[�g�����g�A00H�ɒu������
		LD		A,00H
		JR		PSBL3				;1�������M��

PSBL22:	INC		DE					;DE���C���N�������g���ēǂݔ�΂�����
		JR		PSBL1
PSBL3:	
		CP		2CH					;�u,�v���������當����I���Ƃ���00H�𑗐M
		JR		NZ,PSBL32
		XOR		A
		CALL	SNDBYTE
		INC		DE
		DEC		B
		LD		A,(DE)
		CP		52H					;�u,R�v���́u,r�v�������玩�����s���Z�b�g
		JR		Z,PSBL31
		CP		72H
		JR		NZ,PSBL32
PSBL31:	LD		A,01H
		LD		HL,EXEFLG			;�������s����Ȃ�EXEFLG�Ɂu01�v�A���Ȃ��Ȃ�u00�v
		LD		(HL),A
		XOR		A
		CALL	SNDBYTE
		JR		PSBL33
PSBL32:	PUSH	AF
		CALL	SNDBYTE				;�t�@�C���l�[������������𑗐M
		POP		AF
		CP		00H					;00H�ȊO�Ȃ�DE���C���N�������g
		JR		Z,PSBL4
		
PSBL33:	INC		DE
PSBL4:	DJNZ	PSBL1				;33���������[�v
		POP		BC
		LD		(HLSAVE),DE			;���I���ʒu(00H)���́u:�v�̈ʒu��ޔ�
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

		LD		B,06H
		LD		HL,LBUF				;�t�@�C���l�[��6�������擾
PSBL5:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSBL5
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG4				;�uLoading �v��\��
		CALL	STRPR
		LD		HL,LBUF				;�t�@�C���l�[����\��
		CALL	STRPR
		LD		A,','
		CALL	CHPUT
		
		LD		HL,SADRS			;SADRS�AEADRS�AGADRS���擾
		LD		B,06H
PSBL55:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSBL55
		
		LD		A,(SADRS+1)			;SADRS�\��
		CALL	MONBHX
		LD		A,(SADRS)
		CALL	MONBHX
		LD		A,','
		CALL	CHPUT
		LD		A,(EADRS+1)			;EADRS�\��
		CALL	MONBHX
		LD		A,(EADRS)
		CALL	MONBHX
		LD		A,','
		CALL	CHPUT
		LD		A,(GADRS+1)			;GADRS�\��
		CALL	MONBHX
		LD		A,(GADRS)
		CALL	MONBHX
		CALL	MONCLF

		LD		HL,(EADRS)
		LD		DE,(SADRS)
PSBL6:	CALL	RCVBYTE				;1Byte��M
		LD		(DE),A				;(SADRS) <- A�ASADRS+1
		PUSH	HL
		XOR		A
		SBC		HL,DE				;EADSR = SADRS�܂Ń��[�v
		POP		HL
		INC		DE
		JR		NZ,PSBL6
		LD		HL,EXEFLG
		LD		A,(HL)
		CP		01H				;EXEFLG���u01�v�Ȃ�GADRS����������
		JR		NZ,PSBL61			;�łȂ���ΏI��

		LD		DE,EXEFLG
		LD		HL,EXEST
		LD		BC,EXEEND-EXEST
		LDIR
		LD		HL,(GADRS)
		LD		(EXEFLG+8),HL		;�������s�A�h���X���Z�b�g
		
		LD		HL,4000H			;�y�[�W1(4000H�`7FFFH)�����C��ROM�Ɠ����X���b�g�ɂ���
		LD		A,(0FCC1H)
		AND		03H
		JP		EXEFLG				;(GADRS)�փW�����v

PSBL61:	JP		SRET

;*********************************** �}�V����Z�[�u ********************************
PSBSAVE:LD		HL,(HLSAVE)			;HL���A
		CALL	STFN				;�X�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R������
		LD		(HLSAVE),HL			;HL�ޔ�
		EX		DE,HL
		LD		A,47H				;SBSAVE�R�}���h47H�𑗐M
		CALL	STCD				;�R�}���h�R�[�h���M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,DLRET
		CALL	CMDFN				;�t�@�C���l�[�����M

		CALL	NUMSET
		LD		(SADRS),HL			;�X�^�[�g�A�h���X���擾�A���l���擾�ł��Ȃ���΃G���[�I��
		JP		C,PSBS7
		
		CALL	NUMSET
		LD		(EADRS),HL			;�G���h�A�h���X���擾�A���l���擾�ł��Ȃ���΃G���[�I��
		JP		C,PSBS7
		
		PUSH	HL
		PUSH	DE
		LD		DE,(SADRS)
		XOR		A
		SBC		HL,DE
		POP		DE
		POP		HL
		JP		C,PSBS7				;�G���h�A�h���X>=�X�^�[�g�A�h���X�łȂ���΃G���[�I��

		CALL	NUMSET
		LD		(GADRS),HL			;���s�A�h���X���擾�A���l���擾�ł��Ȃ���΃G���[�I��
		JP		C,PSBS7

		XOR		A
		CALL	SNDBYTE				;�t�@�C���l�[���A�e���l������Ɏ擾�o�����瑱�s�w��

		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR

PSBS1:	LD		A,(DE)				;00H���́u:�v�ȊO�͓ǂݔ�΂�
		CP		3AH					;�u:�v
		JR		Z,PSBS2
		CP		00H
		JR		Z,PSBS2
		INC		DE
		JR		PSBS1
PSBS2:	LD		(HLSAVE),DE			;�����擪�ʒu��ޔ�
		

		LD		B,06H
		LD		HL,LBUF				;�t�@�C���l�[��6�������擾
PSBS22:	CALL	RCVBYTE
		LD		(HL),A
		INC		HL
		DJNZ	PSBS22
		LD		A,00H
		LD		(HL),A
		LD		HL,MSG6				;�uSaving �v��\��
		CALL	STRPR
		LD		HL,LBUF				;�t�@�C���l�[����\��
		CALL	STRPR
		CALL	MONCLF
		
		LD		B,06H
		LD		HL,SADRS			;�X�^�[�g�A�h���X�A�G���h�A�h���X�A���s�A�h���X�𑗐M
PSBS23:	LD		A,(HL)
		CALL	SNDBYTE
		INC		HL
		DJNZ	PSBS23

		LD		DE,(SADRS)
PSBS3:	LD		HL,(EADRS)
		LD		A,(DE)
		CALL	SNDBYTE				;�X�^�[�g�A�h���X����G���h�A�h���X�܂ł̃f�[�^��ǂݏo���đ��M
		XOR		A
		SBC		HL,DE
		INC		DE
		LD		A,H
		OR		L
		JR		NZ,PSBS3

PSBS6:
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		JP		SRET

PSBS7:
		LD		A,0FFH				;�G���[�I���A�ł��؂���w��
		CALL	SNDBYTE
		JP		SDERR

;********************* (DE)���琔�l���擾����HL�փZ�b�g�A�擾�ł��Ȃ����CF=1
NUMSET:	LD		A,(DE)
		CP		2CH					;�R���}�ǂݔ�΂�
		JP		NZ,NUMST1
		INC		DE
		LD		A,(DE)
		CP		00H					;00H�Ȃ琔�l����
		JP		Z,NUMST1
		CALL	GETNUM				;���l���擾
		JP		C,NUMST1
		RET
NUMST1:
		SCF							;�G���[�I��
		RET

;**** �R�}���h���M (IN:A �R�}���h�R�[�h)****
STCD:	CALL	SNDBYTE				;A���W�X�^�̃R�}���h�R�[�h�𑗐M
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		RET

;**** �R�}���h�A�t�@�C�������M (IN:A �R�}���h�R�[�h HL:�t�@�C���l�[���̐擪)****
STCMD:	INC		HL
		CALL	STFN				;�󔒏���
		PUSH	HL
		CALL	STCD				;�R�}���h�R�[�h���M
		POP		HL
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		CALL	STFS				;�t�@�C���l�[�����M
		AND		A					;00�ȊO�Ȃ�ERROR
		JP		NZ,SDERR
		RET

;**** �t�@�C���l�[�����M(IN:HL �t�@�C���l�[���̐擪) ******
STFS:	LD		B,20H
STFS1:	LD		A,(HL)				;FNAME���M
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
		CALL	RCVBYTE				;��Ԏ擾(00H=OK)
		RET

;****** FILE NAME���擾�ł���܂ŃX�y�[�X�A�_�u���R�[�e�[�V�����A�J�b�R��ǂݔ�΂� (IN:HL �R�}���h�����̎��̕��� OUT:HL �t�@�C���l�[���̐擪)*********
STFN:	PUSH	AF
STFN1:	LD		A,(HL)
		CP		20H
		JR		Z,STFN2
		CP		22H
		JR		Z,STFN2
		CP		28H
		JR		NZ,STFN3
STFN2:	INC		HL					;�t�@�C���l�[���܂ŃX�y�[�X�ǂݔ�΂�
		JR		STFN1
STFN3:	POP		AF
		RET

DEFDIR:
		DB		'_SETL '
DEND:

;************** �G���[���e�\�� *****************************
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
		LD		HL,MSG99			;���̑�ERROR
ERRMSG:	CALL	STRPR
		CALL	MONCLF
		CALL	BEEP
		POP		AF
		JP		SRET

;************** A���W�X�^�̒l��16�i���Ƃ��ĕ\��
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

;************ A���W�X�^�̃A���t�@�x�b�g��������啶���ɕϊ�
AZLCNV:	CP		61H
		JR		C,AZ1
		CP		7BH
		JR		NC,AZ1
		SUB		20H
AZ1:	RET

;************ �L�[�{�[�h�X�L����
;������Ă��Ȃ���� A <- 00H�AZ=1
;������Ă����     A <- ASCII�R�[�h(KTBL����擾)
KSCAN:	LD		C,00H				;�}�g���b�N�X�s�����l
KS1:	LD		A,C					;A <- �}�g���b�N�X�s
		CALL	SNSMAT				;�X�L����
		CP		0FFH
		JR		NZ,KS2				;����������Ă����KS2��
		LD		A,C
		INC		A					;�}�g���b�N�X�s+1
		LD		C,A
		CP		0BH					;10��̃X�L�������I���܂�KS1��
		JR		NZ,KS1
		XOR		A					;����������Ă��Ȃ�������A <- 00H�Ń��^�[��
		RET
KS2:	LD		B,00H
KS3:	SLA		A					;�r�b�g���o�C�g�ɕϊ����ĉ��Z
		JR		NC,KS4
		INC		B
		JR		KS3
KS4:	LD		HL,KTBL				;KTBL+�}�g���b�N�X�s*8+�r�b�g����o�C�g�֕ϊ��������l�Ōv�Z����
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
		DB		0DH,8EH,42H,1BH,8BH,1BH,89H,88H		;�uBS�v���uB�v�ɕύX
		DB		1CH,1FH,1EH,1DH,7FH,92H,0BH,20H
		DB		34H,33H,32H,31H,30H,9AH,99H,98H
		DB		2CH,2EH,2DH,39H,38H,37H,36H,35H

;************* ���s��\��
MONCLF:	PUSH	HL
		LD		HL,CRLF
		CALL	STRPR
		POP		HL
		RET

;************* (HL)����̕������00H�܂ŕ\��
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
		
;**** 1BYTE��M ****
;��MDATA��A���W�X�^�ɃZ�b�g���ă��^�[��
RCVBYTE:
		CALL	F1CHK 				;PORTC BIT7��1�ɂȂ�܂�LOOP
		IN		A,(PPI_B)			;PORTB -> A
		PUSH 	AF
		LD		A,05H
		OUT		(PPI_R),A			;PORTC BIT2 <- 1
		CALL	F2CHK				;PORTC BIT7��0�ɂȂ�܂�LOOP
		LD		A,04H
		OUT		(PPI_R),A			;PORTC BIT2 <- 0
		POP 	AF
		RET
		
;**** 1BYTE���M ****
;A���W�X�^�̓��e��PORTA����4BIT��4BIT�����M
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

;**** 4BIT���M ****
;A���W�X�^����4�r�b�g�𑗐M����
SND4BIT:
		OUT		(PPI_A),A
		LD		A,05H
		OUT		(PPI_R),A			;PORTC BIT2 <- 1
		CALL	F1CHK				;PORTC BIT7��1�ɂȂ�܂�LOOP
		LD		A,04H
		OUT		(PPI_R),A			;PORTC BIT2 <- 0
		CALL	F2CHK
		RET
		
;**** BUSY��CHECK(1) ****
; 82H BIT7��1�ɂȂ�܂�LOP
F1CHK:	IN		A,(PPI_C)
		AND		80H					;PORTC BIT7 = 1?
		JR		Z,F1CHK
		RET

;**** BUSY��CHECK(0) ****
; 82H BIT7��0�ɂȂ�܂�LOOP
F2CHK:	IN		A,(PPI_C)
		AND		80H					;PORTC BIT7 = 0?
		JR		NZ,F2CHK
		RET

		END
