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

key		db	"password", 00
msgFound	db	"Key found", 10, 00
msgNotFound	db	"Key not found", 10, 00
testData	db	"Hi guys, my name is Luis and my password is 1234", 00

section		.text

global _start

_start:

; Init Key
	mov 	rcx, 0
	mov 	rax, [key]
	
; main loop	
loop:
	mov 	rbx, [testData + rcx]
	cmp 	rax, rbx
	jne 	NotFound

; print found message and exit program	
	mov 	rdi, msgFound
	call 	strlen
	call 	printStr
	jmp 	out
	
NotFound:
	cmp 	bl, 0
	je 	printNotFound
	
	inc 	rcx
	jmp 	loop	
printNotFound:	
	mov 	rdi, msgNotFound
	call 	strlen
	call 	printStr	
	
out:
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
.loop:
	cmp 	byte [rdi + rcx], 0
	je 	strret
	inc 	rcx
	jmp 	.loop
strret:
	ret
	
