sys_exit	equ	1
sys_read	equ	3
sys_write	equ	4
stdin		equ	0 ; default keyboard
stdout		equ	1 ; default terminal screen
stderr		equ	3

section .data		;used to declare constants	
	userMsg		db      'Enter an integer(less than 32,765): '
	lenUserMsg	equ	$-userMsg
	displayMsg	db	'You entered: '
	lenDisplayMsg	equ	$-displayMsg
	newline		db	0xA 	; 0xA 0xD is ASCII <LF><CR>

	Ten             DW      10  ;Used in converting to base ten.

	printTempchar	db	'Tempchar = : '
	lenprintTempchar	equ 	$-printTempchar


	Result          db      'Ans = '
	ResultValue	db	'aaaaa'
			db	0xA		
	ResultEnd       equ 	$-Result    ; $=> here, subtract address Result

	num		times 6 db 'ABCDEF'
	numEnd		equ	$-num
M DW 7
N DW 85
lit16 DW 16
; Start of user variable area    ----------------------------------------------

section	.bss		;used to declare uninitialized variables

	TempChar        RESB    1              ;temp space for use by GetNextChar
	testchar        RESB    1	
	ReadInt         RESW    1              ;Temporary storage GetAnInteger.	
	tempint         RESW	1              ;Used in converting to base ten.
	negflag         RESB    1              ;P=positive, N=negative	
X RESW 1
Y RESW 1
Z RESW 1
A RESW 1
T0 RESW 1
T1 RESW 1
T2 RESW 1
	global _start
section .text

_start:	nop
	; prompt user for positive number	

Again:
call PrintString
call GetAnInteger
mov ax, [ReadInt]
mov [A], ax
mov ax,[M]
add ax,[lit16]
mov [T1], ax
mov ax, [T1]
mov [Y], ax
mov ax,[Y]
add ax,[A]
mov [T1], ax
mov ax, [T1]
mov [X], ax
mov ax,[X]
add ax,[Y]
mov [T1], ax
mov ax,[T1]
add ax,[N]
mov [T2], ax
mov ax, [T2]
mov [Z], ax
mov ax, [Y]
call ConvertIntegerToString
mov eax, 4
mov ebx, 1
mov ecx, Result
mov edx, ResultEnd
int 80h
mov ax, [X]
call ConvertIntegerToString
mov eax, 4
mov ebx, 1
mov ecx, Result
mov edx, ResultEnd
int 80h
mov ax, [Z]
call ConvertIntegerToString
mov eax, 4
mov ebx, 1
mov ecx, Result
mov edx, ResultEnd
int 80h
; exit code
fini:
	mov eax,sys_exit ;terminate, sys_exit = 1
	xor ebx,ebx	;successfully, zero in ebx indicates success
	int 80h

;	END PgmIO1.asm

;
;       Subroutine to print a string on the display
;
; Input:
;       DS:BX = pointer to the string to print
;
; Output: None
;
; Registers destroyed: none
;
;PrintString     PROC
PrintString:
	push    ax              ;Save registers;
	push    dx
; subpgm:
	; prompt user	
	mov eax, 4		;Linux print device register conventions
	mov ebx, 1		; print default output device
	mov ecx, userMsg	; pointer to string
	mov edx, lenUserMsg	; arg1, where to write, screen
	int	80h		; interrupt 80 hex, call kernel
	pop     dx              ;Restore registers.
	pop     ax
	ret
;PrintString     ENDP

;%NEWPAGE

;

; Subroutine to get an integer (character string) from the keyboard buffer
;    and convert it to a 16 bit binary number.
;
; Input: none
;
; Output: The integer is returned in the AX register as well as the global
;         variable ReadInt .
;
; Registers Destroyed: AX, BX, CX, DX, SI
;
; Globals Destroyed: ReadInt, TempChar, tempint, negflag
;
;GetAnInteger    PROC

GetAnInteger:	;Get an integer as a string
	;get response
	mov eax,3	;read
	mov ebx,2	;device
	mov ecx,num	;buffer address
	mov edx,6	;max characters
	int 0x80

	;print number    ;works
	mov edx,eax 	; eax contains the number of character read including <lf>
	mov eax, 4
	mov ebx, 1
	mov ecx, num
	int 80h

ConvertStringToInteger:
	mov ax,0	;hold integer
	mov [ReadInt],ax ;initialize 16 bit number to zero
	mov ecx,num	;pt - 1st or next digit of number as a string 
			;terminated by <lf>.
	mov bx,0	
	mov bl, byte [ecx] ;contains first or next digit
Next:	sub bl,'0'	;convert character to number
	mov ax,[ReadInt]
	mov dx,10
	mul dx		;eax = eax * 10
	add ax,bx
	mov [ReadInt], ax

	mov bx,0
	add ecx,1 	;pt = pt + 1
	mov bl, byte[ecx]

	cmp bl,0xA	;is it a <lf>
	jne Next	; get next digit   &&&&&&&&&&&&&&&&&&&&&&&7
	ret
;	ENDP GetAnInteger



;%NEWPAGE
;
; Subroutine to convert a 16 bit integer to a text string
;
; input:
;       AX = number to convert
;       DS:BX = pointer to end of string to store text
;       CX = number of digits to convert
;
; output: none
;
; Registers destroyed: AX, BX, CX, DX, SI
; Globals destroyed negflag 
;
;ConvertIntegerToString PROC

ConvertIntegerToString:
	mov ebx, ResultValue + 4   ;Store the integer as a five
	                    ;digit char string at Result for printing

ConvertLoop:
	sub dx,dx  ; repeatedly divide dx:ax by 10 to obtain last digit of number
	mov cx,10  ; as the remainder in the DX register.  Quotient in AX.
	div cx
	add dl,'0' ; Add '0' to dl to convert from binary to character.
	mov [ebx], dl
	dec ebx
	cmp ebx,ResultValue
	jge ConvertLoop

	ret

;ConvertIntegerToString  ENDP
