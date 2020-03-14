.model small
.stack 100h
.data

range db 25
i db 0                  ;iterator

row0 db 15 dup(0)        ; an array
row1 db 15 dup(0)
row2 db 15 dup(0)
row3 db 15 dup(0)
row4 db 15 dup(0)
row5 db 15 dup(0)
row6 db 15 dup(0)
row7 db 15 dup(0)
row8 db 15 dup(0)
row9 db 15 dup(0)

.code
   mov ax,@data
   mov ds,ax

   mov bx,offset arr    ;getting the adress of the arr in bx
    L1:

    mov ah,2ch      
    int 21h

    mov ah,0  
    mov al,dl            ;using dl by seeing  2ch details
    div range            ; so the number is in range


    mov [bx],ah          ;ah has remainder as using 8 bits div and  
    inc bx               ;moving to the next index

    inc i
    cmp i,100
    jbe L1


mov ah,4ch               ;returning control
int 21h 
end