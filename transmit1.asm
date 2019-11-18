ORG 00H
LJMP MAIN
ORG 23H
LJMP SERIAL


MAIN:
MOV R0,#00h ;counter for what to send
MOV R1,#00H ;checksum storage
MOV DPH,#10h ;starting address
MOV DPL,#20h ;starting address
MOV R2,#10h ;final address
MOV R3,#32h ;final address
MOV R6,#00h
;Timer and Serial Setup
MOV TMOD,#20h
MOV TH1,#0FDh
MOV SCON,#40h
MOV IE,#90h
SETB TR1
SETB TI
BACK:

SJMP BACK


SERIAL:
	CJNE R6,#55h,EXEC
	RETI
	EXEC:
	CLR TI
	MOV A,R3 ;length calculation
	SUBB A,DPL
	MOV R5,A
	MOV A,R2
	SUBB A,DPH
	MOV R4,A
	CJNE R4,#00h,REMAINDER
	MOV A,R5
	JNZ SENDCOLON
	MOV R6,#33h
	JZ SENDCOLON
	REMAINDER:
		MOV R5,#0FFh ;set length of ihex as ff
	JNZ SENDCOLON
	RETI

SENDCOLON:
	CJNE R0,#00h,SENDLENGTH
	MOV A,#3Ah ; send colon
	MOV SBUF,A
	ADD A,R1
	MOV R1,A
	INC R0
	RETI

SENDLENGTH:
	CJNE R0,#01h,SENDADDRESSHIGHER
	MOV A,R5
	MOV SBUF,A
	MOV R7,A
	ADD A,R1
	MOV R1,A
	INC R0
	RETI

SENDADDRESSHIGHER:
	CJNE R0,#02h,SENDADDRESSLOWER
	MOV A,DPH
	MOV SBUF,A
	ADD A,R1
	MOV R1,A
	INC R0
	RETI

SENDADDRESSLOWER:
	CJNE R0,#03h,SENDRECORDTYPE
	MOV A,DPL
	MOV SBUF,A
	ADD A,R1
	MOV R1,A
	INC R0
	RETI



SENDRECORDTYPE:
	CJNE R0,#04h,SENDDATA
	CJNE R6,#33h,SENDENDRECORD
	MOV A,#01h
	MOV SBUF,A
	ADD A,R1
	MOV R1,A
	INC R0
	MOV R6,#55h
	RETI

SENDENDRECORD:
	MOV A,#00h
	MOV SBUF,A
	ADD A,R1
	MOV R1,A
	INC R0
	RETI

SENDDATA:
	MOV A,R7
	JZ SENDCHECKSUM
	MOVX A,@DPTR
	MOV SBUF,A
	DEC R7
	ADD A,R1
	MOV R1,A
	INC DPTR
	INC R0
	RETI

SENDCHECKSUM:

	MOV A,R1 ;taking 2's compilemnt of the sum
	CPL A
	ADD A,#01h
	MOV SBUF,A
	MOV R1,#00h
	MOV R0,#00h
	MOV A, DPH
	RETI
END:
	RETI




