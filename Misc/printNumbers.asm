
.model small

.data
	number dw 12345
	rem dw 0
	
.code
	mov ax, @data
	mov ds, ax
	
	mov ax, number
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
end