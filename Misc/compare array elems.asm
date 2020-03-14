.model small
include emu8086.inc
 
.data
	arr1 db '1','2','3','4'   	;arr1 db 1,2,3,4
	arr2 db '1','8','3','5'		;arr2 db 5,4,3,2
	counter dw 0
	
.code
	mov ax, @data
	mov ds, ax
	
	; mov bx, offset arr1
	; mov dx, offset arr2
	
	mov cx, 4
	compareElem:
		mov bx, counter		;bx used fr indexing array; for some reason indexing can only be done with a 16bit register
		mov al, arr1[bx]
		cmp al, arr2[bx]
		je lEqual
		jne lNotEqual
		
		lEqual:
			printN 'Equal '
			jmp next
			
		lNotEqual:
			printN 'Not Equal '
			
		next:
			inc counter
			cmp counter, 4
			jb compareElem
			
	MOV AH, 4CH                  ; return control to DOS
	INT 21H
