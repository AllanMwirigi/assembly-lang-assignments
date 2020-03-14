
.model medium
include emu8086.inc ; defines some of the macros directive used
    
.stack 100h


.data
	range db 98                  ;range of random numbers 0 - 98
	rowCounter db 0                  ;iterator
	
	matrixRowCounter db 0
	matrixIndexCounter dw 0
	matrixCursorX db 10
	matrixRow db 10 dup(?)
	xPos db 20
	yPos db 6

	row0 db 10 dup(0)        ; an array
	row1 db 10 dup(0)
	row2 db 10 dup(0)
	row3 db 10 dup(0)
	row4 db 10 dup(0)
	row5 db 10 dup(0)
	row6 db 10 dup(0)
	row7 db 10 dup(0)
	row8 db 10 dup(0)
	row9 db 10 dup(0)
	 
     rem db 0

     setCoordinates MACRO row, col     
          mov dl, row
          mov bx, col  
          call selectElement
     endm
          
.code
     mov ax, @data
     mov ds, ax
	
	mov cx, 10   ;cannot count from 9 to 0 because loop will not iterate at 0
	colLoop:  			; loops rows 0-9
	    push cx 
	    mov rowCounter, 0
	    
		cmp cx, 1
		je setRow0
		cmp cx, 2
		je setRow1
		cmp cx, 3 
		je setRow2
		cmp cx, 4
		je setRow3
		cmp cx, 5
		je setRow4
		cmp cx, 6 
		je setRow5
		cmp cx, 7
		je setRow6
		cmp cx, 8
		je setRow7
		cmp cx, 9
		je setRow8
		cmp cx, 10
		je setRow9 
		
		setRow0:
			mov bx,offset row0    ;getting the adress of the arr in bx
			jmp rowLoop
		setRow1:
			mov bx,offset row1
			jmp rowLoop
		setRow2:
			mov bx,offset row2
			jmp rowLoop
		setRow3:
			mov bx,offset row3
			jmp rowLoop
		setRow4:
			mov bx,offset row4
			jmp rowLoop
		setRow5:
			mov bx,offset row5
			jmp rowLoop
		setRow6:
			mov bx,offset row6
			jmp rowLoop
		setRow7:
			mov bx,offset row7
			jmp rowLoop
		setRow8:
			mov bx,offset row8
			jmp rowLoop
		setRow9:
			mov bx,offset row9
			jmp rowLoop
		
		rowLoop:						; generates each random number at index`
			mov ah,2ch      			; system time
			int 21h

			mov ah,0  
			mov al,dl            ;using dl by seeing  2ch details
			div range            ; so the number is in range
			
			mov [bx],ah          ;ah has remainder as using 8 bits div and  
			inc bx               ;moving to the next index

			inc rowCounter
			cmp rowCounter,9 
			
		jbe rowLoop
		pop cx
	loop colLoop
	
	call displayMatrix

	GOTOXY 0,0             ;top-left
	setCoordinates 6,5 
	mov cx, 300
	call DELAY
	
	GOTOXY 77,0				;top-right
	setCoordinates 9,1 	
	mov cx, 300	
	call DELAY
	
	; GOTOXY 40,12			;centre
	; setCoordinates 0,3 
	; mov cx, 300
	; call DELAY
	
	GOTOXY 0,23				;bottom-left
	setCoordinates 3,6 
	mov cx, 300
	call DELAY
	
	GOTOXY 77,23			;bottom-right
	setCoordinates 7,9 
     
	 MOV AH, 4CH                  ; return control to DOS
	 INT 21H
     

proc selectElement
	cmp dl, 0
	je lrow0
	cmp dl, 1
    je lrow1
    cmp dl, 2
    je lrow2
    cmp dl, 3
    je lrow3
    cmp dl, 4
    je lrow4
    cmp dl, 5
    je lrow5
    cmp dl, 6
    je lrow6
    cmp dl, 7
    je lrow7
    cmp dl, 8
    je lrow8
    cmp dl, 9
    je lrow9

    lrow0: 
		mov al, row0[bx]
		jmp finish
	lrow1: 
		mov al, row1[bx]
		jmp finish
	lrow2: 
		mov al, row2[bx]
		jmp finish
	lrow3: 
		mov al, row3[bx]
		jmp finish
	lrow4: 
		mov al, row4[bx]
		jmp finish
	lrow5: 
		mov al, row5[bx]
		jmp finish
	lrow6: 
		mov al, row6[bx]
		jmp finish
	lrow7: 
		mov al, row7[bx]
		jmp finish
	lrow8: 
		mov al, row8[bx]
		jmp finish
	lrow9: 
		mov al, row9[bx]
		jmp finish
	
	finish:
		call printElem
    ret
endp  

PROC DELAY
;input: CX, this value controls the delay. CX=50 means 1ms
;output: none
	JCXZ @DELAY_END
	@DEL_LOOP:
	LOOP @DEL_LOOP	
	@DELAY_END:
	RET
ENDP DELAY


proc printElem ;prints 2 digit number
    mov ah,00  ;clear AH to use for reminder
	xor dx, dx
    mov bl,10   ;take bl=10
    div bl      ;al/bl --> twodigit number/10 = decemel value
    mov rem,ah   ;move reminder to rim
    
    mov dl,al     ;to print (al) we move al to dl
    add dl,48
    mov ah,02h
    int 21h

    ;to print the reminder
    mov dl,rem
    add dl,48
    mov ah,02h
    int 21h
    ret
endp

proc displayMatrix
	mLoop:
		GOTOXY xPos, yPos
		disp:
			GOTOXY xPos, yPos
			setCoordinates matrixRowCounter,matrixIndexCounter
			xor dx, dx
			xor ax, ax
			xor bx, bx
			add xPos, 3
			inc matrixIndexCounter
			cmp matrixIndexCounter, 10
			je finishRow
			jmp disp
			
		finishRow:
			mov xPos, 20
			inc yPos
			mov matrixIndexCounter, 0
			inc matrixRowCounter
			cmp matrixRowCounter, 10
			je endLoop
			jmp mLoop
			
		endLoop:
			ret
			
displayMatrix endp
  
end

     


