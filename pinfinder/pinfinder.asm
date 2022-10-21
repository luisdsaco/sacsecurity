;
; Module: pinfinder.asm
; Version: 0.0.1a
;
; Program to search for passwords in strings
;
; (C) 2022 Luis Díaz Saco
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
key             db	'1234', 0
msgFound        db	'Key found', 10, 0
msgNotFound     db	'Key not found', 10, 0
msgError        db	'Processing Error', 10, 0
msgInit         db	'Reading file ', 0
noFileName      db	'from stdin', 10, 0

cmdlinePin      db      '-pin', 0

section         .bss


testData        resb	BUFF_SIZE + 4  ; reserve processing buffer

section         .text

global          main

; -----------------------------------------------------
; Function main
; Inputs: argc, argv
; In this program the function exit() is called directly
;   at the end


main:
        push    rbp
        mov     rbp, rsp    ; for correct debugging

        push    r12         ; reserved for cmdline index
        push    r13         ; reserved for file descriptor
        push    r14         ; reserved for argc
        push    r15         ; reserved for argv
        push    rbx
        
; read command line options
        mov     r14, rdi    ; argc
        mov     r15, rsi    ; argv
        mov     r13, STDIN  ; save default file descriptor in r8
	
; Set the last 8 bytes of the i/o buffer to 0

        xor     eax, eax    ; eax = 0
        mov     dword [testData + BUFF_SIZE], eax

; Determine if there are input parameters

        mov     rax, 0
        mov     rcx, 1
        cmp     r14, rcx
        jle     .notCommand
        ; if argc > 1 then search for -pin
        ; compare argv[1] with -pin  if not rax <> 0 and return
        mov     eax, dword [cmdlinePin]
        ; rbx = argv[1]
        mov     rbx, [r15 + 8*rcx]
        mov     edx, dword [rbx]
        cmp     eax, edx
        jne     .notCommand
        ; make sure -pin is 4 bytes long
        mov     al, [rbx + 4]
        cmp     al, 0
        jne     fileError   ; command has more than 4 characters
        ; if -pin exists and argc == 2 then error
        ; rbx = argv [2]
        inc     rcx
        cmp     r14, 3
        jl      fileError
        ; if -pin exists argc == 2 but pin size is not 4 then error
        mov     rbx, [r15 +8*rcx]
        cmp     byte [rbx + 4] , 0
        jne     fileError   ; pin has more than 4 characters
        ; check the pin for numbers
        push    rcx
        mov     rcx, 4
.cmploop:
        cmp     byte [rbx + rcx -1], 0x30
        jl      fileError
        cmp     byte [rbx + rcx -1], 0x39
        jg      fileError
        loop    .cmploop

        pop     rcx
        inc     rcx

        ; return the pin in edx and exit with status in eax
        mov     eax, [rbx]
        mov     [key], eax
              
        mov     rax, 0
        cmp     r14, 4
        jl     .notCommand
        mov     eax, 1
        mov     rbx, [r15 +8*rcx]
               
        
.notCommand:

;-------------------------------------------------------------

        mov     r12, rcx
        cmp     eax, 0      ; if there is a filename then openFile
        jne     openFile
	
; print initial message and without opening a file

        ; printStr(msgInit,strlen(msgInit))
	mov 	rdi, msgInit
	call 	strlen
	call 	printStr

        ; printStr(noFileName,strlen(noFileName))
	mov	rdi, noFileName
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

        ; printStr(argv[x],strlen(argv[x]))
	mov	rdi, rbx
	call 	strlen
	call	printStr	

        ; printStr(newLine,strlen(newLine))
	mov 	rdi, newLine
	call 	strlen
	call 	printStr

	
; Data acquisition
        ; rax = SYS_open(argv[x], O_RDONLY)
        mov	rax, SYS_open
        mov     rdi, rbx
        mov	rsi, O_RDONLY
        syscall
	
        cmp	rax, 0         ; if error then fileError
        je	fileError
        mov	r13, rax       ; save file descriptor in r8

; read BUFF_SIZE bytes of data
readFile:
	mov	rdi, rax       ; set filedescriptor for SYS_read
readBuff:
        ; move the last 8 bytes of the processing buffer to the init 
	mov	rax, [testData + BUFF_SIZE]
	mov	[testData], rax

        ; read BUFF_SIZE bytes from the file
	mov	rax, SYS_read
	mov	rsi, testData + 4
	mov	rdx, BUFF_SIZE
	syscall
	
	cmp	rax, 0         ; if error then fileError
	jl	fileError
	

; exec algorithm rdx stores the word password in its 64 bits
	mov 	edx, [key]
	call   pinfinder
        cmp     rbx, 0
        je      closeFile

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
        
        inc     r12
        cmp     r14, r12
        jle     endProgram
        mov     rbx, [r15 +8*r12]
        jmp     openFile

; exit without error
endProgram:
; restore the preserved registers, return value to rax and exit
        pop     rbx
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        
        xor     rax,rax
        leave
        ret

; -----------------------------------
; Functions
; -----------------------------------

; Function: pinfinder
; Description: search for the 64 bits key in the processing buffer
;   if found then print a message and end program
; Inputs: edx = key, rax = number of read bytes,
;   r13 = file descriptor
; Outputs: rbx = 0 if pin found else rbx = 1
; Start processing

pinfinder:
	mov 	rcx, 0    ; init index
	
; main loop	
        lea     rbx, testData
.mainloop:
        cmp     edx, [rbx + rcx]    ; if key is not found
        jne     .NotFound            ; then NotFound

	cmp	rax, BUFF_SIZE     ; if buffer is fully processed
	jl	.printFound         ; then printFound
	cmp	r13, 0             ; else if filedescriptor = STDIN
	jne	.printFound         ; then printFound
	call 	clearStdinBuffer   ; else clearStdinBuffer() first

; print found message and exit program
.printFound:
        ; printStr(msgFound,strlen(msgFound)
	mov 	rdi, msgFound
	call 	strlen
	call 	printStr
        
        ; return
        xor     rbx, rbx
        ret
	
.NotFound:
	cmp 	rcx, rax      ; if all bytes are read
	je 	.outLoop       ; then return	
	inc 	rcx           ; else repeat
	jmp 	.mainloop	
.outLoop:	
        mov     rbx, 1
	ret

; ---------------------------------------------
; Function: printStr
; Description: print a string on SDTOUT
; Inputs: rcx = size, rdi = pointer
; Outputs: None

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
; Outputs: rcx = string size

strlen:
	mov 	rcx, 0
.localloop:
	cmp 	byte [rdi + rcx], 0
	je 	.strret
	inc 	rcx
	jmp 	.localloop
.strret:
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
	je	.clearStdinBufferRet
	mov	al, [testData]
	cmp	al, 10
	jne	clearStdinBuffer
.clearStdinBufferRet:
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

