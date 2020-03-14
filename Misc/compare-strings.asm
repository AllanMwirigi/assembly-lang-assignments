.data
  str1 db 'GLSICT' 
  strlen1 db $-str1
  str2 db 'GLSICT'
  strlen2 db $-str2
  streq db "Strings are Equal$"
  struneq db "Strings are Unequal$"

.code
    mov ax, data
    mov ds, ax
    mov es, ax
    lea si, str1   
    lea di, str2
    mov cx, 6
    mov al, strlen1
    mov bl, strlen2
    cmp al, bl
    jne Not_Equal

    repe cmpsb
    jne Not_Equal
    jmp Equal

    Not_Equal:
       mov ah, 09h
       lea dx, struneq
       int 21h
       jmp Exit
    Equal:
       mov ah, 09h
       lea dx, streq
       int 21h
    Exit:
       mov ax, 4c00h
       int 21h