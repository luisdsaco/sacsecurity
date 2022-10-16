;
; Module: keyfinder.asm
; Version: 0.0.1a
;
; Program to search for passwords in strings
;
; (C) 2017-2022 Luis Díaz Saco
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU Affero General Public License as published
;    by the Free Software Foundation, either version 3 of the License, or
;    any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU Affero General Public License for more details.
;
;    You should have received a copy of the GNU Affero General Public License
;    along with this program.  If not, see <https://www.gnu.org/licenses/>.

section		.data

NULL            equ	0
EXIT_SUCCESS    equ	0
SYS_exit        equ	60
SYS_read        equ	0
SYS_write       equ	1
SYS_open        equ	2
SYS_close       equ	3
SYS_lseek       equ	8

STDIN           equ	0
STDOUT          equ	1
STDERR          equ	2

O_RDONLY        equ	0

SEEK_END        equ	2

BUFF_SIZE       equ	128     ; size of i/o buffer

newLine         db	10, 0
key             db	'password', 0
msgFound        db	'Key found', 10, 0
msgNotFound     db	'Key not found', 10, 0
msgError        db	'Processing Error', 10, 0
msgInit         db	'Reading file ', 0
fileName        db	'from stdin', 10, 0

section         .bss


testData        resb	BUFF_SIZE + 8  ; reserve processing buffer

section         .text

global          main

; -----------------------------------------------------
; Function main
; Inputs: argc, argv
; In this program the function exit() is called directly
;   at the end


main:
        mov     rbp, rsp    ; for correct debugging

; read command line options
        mov     r11, rdi    ; argc
        mov     r12, rsi    ; argv
        mov     r13, STDIN  ; save default file descriptor in r13
	
; Set the last 8 bytes of the i/o buffer to 0

        xor     rax, rax    ; rax = 0
        mov     qword [testData + BUFF_SIZE], rax

; Determine if there are input parameteres

        cmp     r11, 2      ; if argc >= 2 then openFile
        jge     openFile
	
; print initial message and without opening a file

        ; printStr(msgInit,strlen(msgInit))
	mov 	rdi, msgInit
	call 	strlen
	call 	printStr

        ; printStr(fileName,strlen(fileName))
	mov	rdi, fileName
	call	strlen
	call	printStr

        ; opened file will be STDIN = 0	
	xor	rax, rax
	jmp	readFile		

openFile:
        ; printStr(msgInit,strlen(msgInit))
	mov	rdi, msgInit
	call	strlen
	call	printStr

        ; printStr(argv[1],strlen(argv[1]))
	mov	rdi, [r12 + 8]
	call 	strlen
	call	printStr	

        ; printStr(newLine,strlen(newLine))
	mov 	rdi, newLine
	call 	strlen
	call 	printStr

	
; Data acquisition
        ; rax = SYS_open(argv[1], O_RDONLY)
	mov	rax, SYS_open
	mov 	rdi, [r12 + 8]
	mov	rsi, O_RDONLY
	syscall
	
	cmp	rax, 0         ; if error then fileError
	jl	fileError
	mov	r13, rax       ; save file descriptor in r13

; read BUFF_SIZE bytes of data
readFile:
	mov	rdi, rax       ; set filedescriptor for SYS_read
readBuff:
        ; move the last 8 bytes of the processing buffer to the init 
	mov	rax, [testData + BUFF_SIZE]
	mov	[testData], rax

        ; read BUFF_SIZE bytes from the file
	mov	rax, SYS_read
	mov	rsi, testData + 8
	mov	rdx, BUFF_SIZE
	syscall
	
	cmp	rax, 0         ; if error then fileError
	jl	fileError
	

; exec algorithm rdx stores the word password in its 64 bits
	mov 	rdx, [key]
	call   keyfinder

; repeat until end of file
	cmp	rax, BUFF_SIZE ; if i/o buffer was filled then
	je	readBuff	       ; repeat

; when program exit the main loop process the end
printNotFound:
        ; printStr(msgNotFound,strlen(msgNotFound))
	mov 	rdi, msgNotFound
	call 	strlen
	call 	printStr

	
; close the file
closeFile:
        cmp     r13, 0          ; if filedescriptor is STDIN
        je      endProgram      ; then endProgram
        mov     rax, SYS_close  ; else close before end 
        mov     rdi, r13
        syscall

; exit without error
endProgram:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall

; -----------------------------------
; Functions
; -----------------------------------

; Function: keyfinder
; Description: search for the 64 bits key in the processing buffer
;   if found then print a message and end program
; Inputs: rdx = key, rax = number of read bytes,
;   r13 = file descriptor
; Outputs: None
; Start processing

keyfinder:
	mov 	rcx, 0    ; init index
	
; main loop	
mainloop:
	mov 	rbx, [testData + rcx]
	cmp 	rdx, rbx          ; if key is not found
	jne 	NotFound          ; then NotFound

	cmp	rax, BUFF_SIZE     ; if buffer is fully processed
	jl	printFound         ; then printFound
	cmp	r13, 0             ; else if filedescriptor = STDIN
	jne	printFound         ; then printFound
	call 	clearStdinBuffer   ; else clearStdinBuffer() first

; print found message and exit program
printFound:
        ; printStr(msgFound,strlen(msgFound)
	mov 	rdi, msgFound
	call 	strlen
	call 	printStr
        
        ; exit()
	jmp 	endProgram
	
NotFound:
	cmp 	rcx, rax      ; if all bytes are read
	je 	outLoop       ; then return	
	inc 	rcx           ; else repeat
	jmp 	mainloop	
outLoop:	
	ret

; ---------------------------------------------
; Function: printStr
; Description: print a string on SDTOUT
; Inputs: rcx = size, rdi = pointer

printStr:
	mov	rax, SYS_write
	mov	rsi, rdi
	mov	rdx, rcx
	mov	rdi, STDOUT
	syscall
	ret

; ----------------------------------------------
; Function: strlen
; Description: get the size of a string
; Inputs: rdi = pointer

strlen:
	mov 	rcx, 0
.localloop:
	cmp 	byte [rdi + rcx], 0
	je 	strret
	inc 	rcx
	jmp 	.localloop
strret:
	ret

;----------------------------------------------
; Function: clearStdinBuffer
; Description: read bytes from SDTIN until it is empty

clearStdinBuffer:
	mov 	rax, SYS_read
	mov 	rdi, STDIN
	mov 	rsi, testData
	mov 	rdx, 1
	syscall
	
	cmp	rax, 0
	je	clearStdinBufferRet
	mov	al, [testData]
	cmp	al, 10
	jne	clearStdinBuffer
clearStdinBufferRet:
	ret

; ---------------------------------------------------
; Error processing.
; Print and error message and exit program

fileError:
	mov	rdi, msgError
processError:
	call	strlen
	call	printStr
	jmp	endProgram

