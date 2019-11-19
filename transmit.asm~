;30h - lower order start addr
;31h - higher order start addr
;32h - lower order end addr
;33h - higher order end addr
;34h - baud rate (must do FF-@34h)
;35h - lower order result
;36h - higher order result
;37h - R3 + 5
;R1 - checksum
;R2 - ihex line counter (byte number for that ihex line)
;R3 - line length
;R4 - no of ihex lines with data length = 255
;R5 - length of last possibly non-255 length line

org 0h
ljmp main
org 23h
ljmp serial
main:		mov 33h, #10h
		mov 32h, #30h
		mov 31h, #10h
		mov 30h, #20h
		;acall length_calc
		;lcall baud_calc
		clr c
		mov A, 32h
		subb A, 30h
		mov 35h, A
		mov A, 33h
		subb A, 31h
		mov 36h, A
		mov R1, #00h ;checksum
		mov R2, #00h ;line counter
		mov R3, #00h ;line length (256 or 35h)
		mov R4, 36h ;no of ihex lines with data length = 255
		mov R5, 35h ;length of last possibly non-255 length line
		mov A, R5
		clr c
		clr 2eh ; This bit is used to check if all lines have been transmitted. If so, send EOF
		add A, R4
		mov R5, A
		mov A, #00h
		addc A, R4
		mov R4, A
		mov dph, 31h ;setting dptr to start addr
		mov dpl, 30h
		mov tmod, #20h ;timer 1, mode 2
		mov 34h, #0fdh
		mov th1, 34h ;input baud rate
		mov tl1, 34h
		mov scon, #40h ;8-bit UART with REN = 0
		mov ie, #90h ;enable serial interrupt
		setb tr1
		setb ti
		back:
		sjmp back

serial:		clr ti
		cond1:  cjne R2, #00h, cond2
			mov sbuf, #3ah
			sjmp exit
		cond2: cjne R2, #01h, cond3
				cjne R4, #00h, sub_cond2
					;if R4==0
					mov A, R5
					mov R3, A
					sjmp ex
					;if R4!=0
		        	sub_cond2:	mov R3, #0ffh
						dec R4
			ex:	mov A, R1
				add A, R3
				mov R1, A
				mov sbuf, R3
				sjmp exit
		cond3: cjne R2, #02h, cond4
				mov A, R1
				add A, 31h
				mov R1, A
				mov sbuf, 31h
				sjmp exit
		cond4: cjne R2, #03h, cond5
				mov A, R1
				add A, 30h
				mov R1, A
				mov sbuf, 30h
				sjmp exit
		cond5: cjne R2, #04h, cond6
				jb 2eh, eof
				mov sbuf, #00h
				sjmp exit
				eof:	mov sbuf, #01h
					clr 2eh
					ljmp 0000h
		;should always be executed
		cond6:  ;mov A, R2
			;clr c
			;subb A, R3
			cjne R3, #00h, cond7 ;if(R2-R3==5)
			;checksum
				mov A, R1
				cpl A
				add A, #01h
				mov sbuf, A
				mov R2, #0ffh
				mov R1, #00h
				mov 30h, DPL
				mov 31h, DPH
				cjne R4, #00h, not_last
				setb 2eh
				sjmp exit
				not_last:	sjmp exit
		;else
		cond7:  movx A, @dptr
			mov sbuf, A
			add A, R1
			mov R1, A
			inc dptr
			dec R3
		exit: 	inc R2
			clr c
		reti
;16 bit subtraction
;length_calc:	clr c
;		mov A, 32h
;		subb A, 30h
;		mov 35h, A
;		mov A, 33h
;		subb A, 31h
;		mov 36h, A
;		ret

;baud_calc:	mov A, #0ffh
;		subb A, 34h
;		mov 34h, A
;		ret