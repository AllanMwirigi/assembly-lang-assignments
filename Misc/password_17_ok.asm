name    password model
; Microprocessor example

include 'emu8086.inc'


.model small

.stack  100h

.data

;Testpass TABLE testdata:word:10
        testdata    db  'loap'
                    db  'rest'
                    db  'fool'
                    db  'iill'
                    db  'rewa'
                    db  'jkty'
                    db  'reta'
                    db  'gear'
                    db  'near'
                    db  'fear'
                    
inp     db  13,10,'enter four letter password',13,10,00
opt     db  13,10,'you emtered.$'
tryagn  db  13,10,'try again',13,10,'$'
thk     db  13,10,'Thank you',13,10,'$'

buffer_pos   DB 5,?,5 dup (?)

;Notice the mode used to reserve memory locations, maximum characters to key-in, actual and duplication 
;of character NULL in locations reserved. CRET should be counted as one of the characters keyed-in for 
;this particular interrupt module (ah=0aH, INT 21H)  

.code

main:

;setting the segments
        
        mov ax,@data
        mov ds,ax
        mov es,ax

        
       

mainloop:       
        mov dx,offset inp
        call display
        
;key_in characters and setting the storage location
 
        ;mov cx,4
        
        mov dx,offset buffer_pos
        mov ah,0aH
        int 21H
        call delay
        mov si, offset testdata 
        mov cx,0aH

;Initialize index pointers       
       
        mov di,0000H
        push di
        mov si,0000h
        push si
        

minloop:
;Monitor the memory and the stack as this module is executed        
;Observe how the skipping from one password to the other.        
;It is important to obsreve how the microprocessor uses the
;stack in a LIFO basis        
        mov di, offset buffer_pos +2
        
        
        push cx
        mov cx,4
        repe cmpsb
        je equals
        pop cx
        pop si
        pop di
        inc di
        push di
        push si
        mov ax,di
        mov bl,4
        mul bl
        add si,ax
        loop minloop
        
;incorrect password        
         
              
        mov dx, offset tryagn
       
        call display
        loop mainloop
        
equals:

            
        mov dx, offset thk
        call display
        jmp ending
        
;VDU display module
        
display proc    near
           
        mov ah,9
        int 21h
        ret
        
        display endp


;Timer module   
       

delay proc near 
       
        mov     cx,001EH
        mov     dx,8480H
        mov     ah,86H
        int     15H 
        ret
delay   endp
        
        
;exit from dos        
                
ending:
 
        mov ah,4ch
        int 21h
        
        end main
        
        
        