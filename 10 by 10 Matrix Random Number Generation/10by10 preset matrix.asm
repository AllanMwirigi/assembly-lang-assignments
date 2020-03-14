
.model small
org 100h 
include emu8086.inc ; defines some of the macros directive used

.data
     row0 db 1,2,3,4,5,6,7,8,9,10
     row1 db 11,12,13,14,15,16,17,18,19,20
     row2 db 21,22,23,24,25,26,27,28,29,30
     row3 db 31,32,33,34,35,36,37,38,39,40
     row4 db 41,42,43,44,45,46,47,48,49,50
     row5 db 51,52,53,54,55,56,57,58,59,60
     row6 db 61,62,63,64,65,66,67,68,69,70
     row7 db 71,72,73,74,75,76,77,78,79,80
     row8 db 81,82,83,84,85,86,87,88,89,90
     row9 db 91,92,93,94,95,96,97,98,99
	 
     rem db 0

     setCoordinates MACRO row, col     
          mov dl, row
          mov bx, col  
          call selectElement
     endm
          
.code
     mov ax, @data
     mov ds, ax

	GOTOXY 0,0             ;top-left
	setCoordinates 5,5 
	mov cx, 300
	call DELAY
	
	GOTOXY 77,0				;top-right
	setCoordinates 5,5 	
	mov cx, 300	
	call DELAY
	
	GOTOXY 40,12			;centre
	setCoordinates 5,5 
	mov cx, 300
	call DELAY
	
	GOTOXY 0,23				;bottom-left
	setCoordinates 5,5 
	mov cx, 300
	call DELAY
	
	GOTOXY 77,23			;bottom-right
	setCoordinates 5,5 
     
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


proc printElem 
    mov ah,00  ;clear AH to use for reminder
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
  
end

     


