
.model small
include 'emu8086.inc'
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS

.data
	balance	dw 1400 
	inputAmountArr db 5,0,0
	inputAmount dw 0
	inputCounter dw 3
	numGenCounter dw 0
	numGenCounterDec dw 0
	
	rem dw 0
	
.code
	mov ax, @data
	mov ds, ax
	
	mov dx, inputCounter
	mov numGenCounterDec, dx
	
	lNumFromArr:
		mov bx, numGenCounter
		mov al, inputAmountArr[bx]
		mov ah, 0h		; MUL DX multiplies AX by DX so the result is wrong if AH already has a value (only interested in the value in AL ftom the array)
			;So clear it before multiplication
		
		cmp numGenCounterDec, 5
		je l5Mult
		cmp numGenCounterDec, 4
		je l4Mult
		cmp numGenCounterDec, 3
		je l3Mult
		cmp numGenCounterDec, 2
		je l2Mult
		cmp numGenCounterDec, 1
		je l1Mult
		
		l5Mult:
			mov dx, 10000
			mul dx
			add inputAmount, ax
			jmp lAmntTerm
		l4Mult: 
			mov dx, 1000
			mul dx
			add inputAmount, ax
			jmp lAmntTerm
		l3Mult:
			mov dx, 100
			mul dx
			add inputAmount, ax
			jmp lAmntTerm
		l2Mult:
			mov dx, 10
			mul dx
			add inputAmount, ax
			jmp lAmntTerm
		l1Mult:
			mov dx, 1
			mul dx
			add inputAmount, ax
			jmp lAmntTerm
		
		lAmntTerm:
			inc numGenCounter
			dec numGenCounterDec
			mov dx, inputCounter
			cmp numGenCounter, dx
			jb lNumFromArr
			
	; mov dx, balance
	; sub dx, inputAmount
	; mov ax, dx
	
	mov ax, inputAmount
	; mov ax, number
	cmp ax, 10
	jb lDigits1
	cmp ax, 100
	jb lDigits2
	cmp ax, 1000
	jb lDigits3
	cmp ax, 10000
	jb lDigits4
	jge lDigits5
	
	lDigits1:
		mov dl, al
		add dl,48
		mov ah, 02h
		int 21h
		jmp finishPrint
	
	lDigits2:
		mov cx, 2
		jmp printDigit
	
	lDigits3:
		mov cx, 3
		jmp printDigit
		
	lDigits4:
		mov cx, 4
		jmp printDigit
		
	lDigits5:
		mov cx, 5
		jmp printDigit
		
	printDigit:     
	    push cx

		cmp cx, 5
		je divBy10k
		
		cmp cx, 4
		je divBy1k
		
		cmp cx, 3
		je divByHun
		
		cmp cx, 2
		je divByTen
		
		cmp cx, 1
		je divByOne
		
		divBy10k:
			mov bx, 10000
			jmp division
		
		divBy1k:
			mov bx, 1000
			jmp division
		
		divByHun:
			mov bx, 100
			jmp division
		
		divByTen:
			mov bx, 10
			jmp division
		
		divByOne:
			mov dx,rem 
			add dx,48
			mov ah,02h
			int 21h
			jmp finishPrint
			
		division:
			cmp rem, 0
			je divCont
			
		    mov ax, rem
			
			divCont:
				xor dx, dx
				div bx      ;ax/bx --> quotient in AX, reminder in DX
				mov rem, dx   ;move reminder to rem
				
				mov dl,al     ;AX is the qoutient but the result is a single digit, will be stored in AL
				add dl,48
				mov ah,02h
				int 21h
		 
		mov ax, 0h  ;clear AX
		pop cx
	loop printDigit
	
	finishPrint:
		mov ah, 4ah
		int 21h

; MOV AH, 4CH                  ; return control to DOS
; INT 21H
	
end
	
	
	