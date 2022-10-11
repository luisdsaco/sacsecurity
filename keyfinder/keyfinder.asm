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

NULL		equ	0
EXIT_SUCCESS	equ	0
SYS_exit	equ	60
SYS_read	equ	0
SYS_write	equ	1
SYS_open	equ	2
SYS_close	equ	3
SYS_lseek	equ	8

STDIN		equ	0
STDOUT		equ	1
STDERR		equ	2

O_RDONLY	equ	0

SEEK_END	equ	2

BUFF_SIZE	equ	128

newLine		db	10, 0
key		db	'password', 0
msgFound	db	'Key found', 10, 0
msgNotFound	db	'Key not found', 10, 0
msgError	db	'Processing Error', 10, 0
msgInit		db	'Reading file ', 0
fileName	db	'from stdin', 10, 0

section		.bss

testData	resb	BUFF_SIZE + 8

section		.text

global main

main:

; read command line options
	mov 	r11, rdi	; argc
	mov 	r12, rsi	; argv
	mov	r13, 0
	
; init dynamic data
 
 	xor 	rax, rax
	mov 	qword [testData + BUFF_SIZE], rax

	cmp	r11, 2
	jge	openFile
	
; initial message

	mov 	rdi, msgInit
	call 	strlen
	call 	printStr

	mov	rdi, fileName
	call	strlen
	call	printStr
	
	xor	rax, rax
	jmp	readFile		

openFile:
	mov	rdi, msgInit
	call	strlen
	call	printStr

	mov	rdi, [r12 + 8]
	call 	strlen
	call	printStr	

	mov 	rdi, newLine
	call 	strlen
	call 	printStr

	
; Data acquisition
; open file
	mov	rax, SYS_open
	mov 	rdi, [r12 + 8]
	mov	rsi, O_RDONLY
	syscall
	
	cmp	rax, 0
	jl	fileError
	mov	r13, rax	; file descriptor

; read BUFF_SIZE bytes of data
readFile:
	mov	rdi, rax
readBuff:
	mov	rax, [testData + BUFF_SIZE]
	mov	[testData], rax
	mov	rax, SYS_read
	mov	rsi, testData + 8
	mov	rdx, BUFF_SIZE
	syscall
	
	cmp	rax, 0
	jl	fileError
	

; exec algorithm
	mov 	rdx, [key]
	call keyfinder

; repeat until end of file
	cmp	rax, BUFF_SIZE
	je	readBuff	

printNotFound:	
	mov 	rdi, msgNotFound
	call 	strlen
	call 	printStr

	
; close the file
closeFile:
	cmp	r13, 0
	je	endProgram
	mov	rax, SYS_close
	mov	rdi, r13
	syscall


endProgram:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall


; Start processing

keyfinder:
	mov 	rcx, 0
	
; main loop	
mainloop:
	mov 	rbx, [testData + rcx]
	cmp 	rdx, rbx
	jne 	NotFound

	cmp	rax, BUFF_SIZE
	jl	printFound
	cmp	r13, 0
	jne	printFound
	call 	clearStdinBuffer

; print found message and exit program
printFound:
	mov 	rdi, msgFound
	call 	strlen
	call 	printStr

	jmp 	endProgram
	
NotFound:
	cmp 	rcx, rax
	je 	outLoop
	
	inc 	rcx
	jmp 	mainloop	
outLoop:	
	ret

printStr:
	mov	rax, SYS_write
	mov	rsi, rdi
	mov	rdx, rcx
	mov	rdi, STDOUT
	syscall
	ret

strlen:
	mov 	rcx, 0
.localloop:
	cmp 	byte [rdi + rcx], 0
	je 	strret
	inc 	rcx
	jmp 	.localloop
strret:
	ret

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

fileError:
	mov	rdi, msgError
processError:
	call	strlen
	call	printStr
	jmp	endProgram

