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

STDIN		equ	0
STDOUT		equ	1
STDERR		equ	2

key		db	'password', 0
msgFound	db	'Key found', 10, 0
msgNotFound	db	'Key not found', 10, 0
testData	db	'Hi guys, I am a politician and my password is 1234. '
		db	'I am putting all the defense infrastructure at risk. '
		db	'Because I am not very clever nobody should vote for me.', 0

section		.text

global _start

_start:

; Init Key
	mov 	rcx, 0
	mov 	rax, [key]
	
; main loop	
mainloop:
	mov 	rbx, [testData + rcx]
	cmp 	rax, rbx
	jne 	NotFound

; print found message and exit program	
	mov 	rdi, msgFound
	call 	strlen
	call 	printStr
	jmp 	endProgram
	
NotFound:
	cmp 	bl, 0
	je 	printNotFound
	
	inc 	rcx
	jmp 	mainloop	
printNotFound:	
	mov 	rdi, msgNotFound
	call 	strlen
	call 	printStr	
	
endProgram:
	mov	rax, SYS_exit
	mov	rdi, EXIT_SUCCESS
	syscall

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
	
