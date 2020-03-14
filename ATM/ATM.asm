
.model medium

.data

	;Account Numbers
	account1 db 1
	account2 db 2
	account3 db 3
	account4 db 4
	account5 db 5
	account6 db 6
	account7 db 7
	account8 db 8
	account9 db 9
	account10 db 10
	
	inputAccNo db 0
	
	;Passwords
	pin1 db 2,4,6,8
	pin2 db 1,3,5,7
	inputPin db 4 dup(?)
	var     db  ? 
	passwdCounter dw 0
	
	AccountNo_Prompt db "Enter Account Number$"
	WrongAccNo_Prompt db "Unrecognized Acc No$"
	Pin_Prompt db "Enter PIN$"
	Wrong_PIN_Prompt  	db "Wrong PIN$"
	PIN_Accepted_Prompt db "PIN Accepted$"
	Welcome_Prompt db "Welcome$"
	Goodbye_Prompt db "GoodBye$"
	NewBalancePrompt db "New Balance:$"
	WithdrawAmountPrompt db "Withdraw Amount:$"
	DepositAmountPrompt db "Deposit Amount:$"
	InsufficientFundsPrompt db "Insufficient Funds$"
	AccountLimitPrompt db "Account Limit Exceeded$"
	
	Amount1kTag db "1 - 1000$"
	Amount2kTag db "2 - 2000$"
	Amount5kTag db "3 - 5000$"
	Amount8kTag db "4 - 8000$"
	Amount10kTag db "5 - 10000$"
	
	1zero  db "0$"
	2zeros db "00$"
	3zeros db "000$"
	4zeros db "0000$"

	selectedAmount dw 0
	
	;Balances
	member1Balance dw 17000
	member2Balance dw 15000
	num dw ?
	rem dw 0
	numToPrint dw ?
	
	inputAmountArr db 5 dup(0)
	inputAmount dw 0
	inputCounter dw 0
	numGenCounter dw 0
	numGenCounterDec dw 0
	
	;Menu
	Enter_Tag           db "ENTER:$"  
    Withdraw_Tag    	db "1-Withdraw$"
    Balance_Tag     	db "2-Balance$"
    Deposit_Tag     	db "3-Deposit$"
    Quit_Tag      		db "4-Quit$"
	Withdraw_Option		db 1
	Balance_Option		db 2
	Deposit_Option		db 3
	Quit_Option			db 4
	inputMenuOption		db 0
	
	;Port values
    PORTA_VAL DB 0
    PORTB_VAL DB 0
    PORTC_VAL DB 0
    KEY       DB ? 
    
;Port Addresses     
    PORTA EQU 00H 	
	PORTB EQU 02H 	
	PORTC EQU 04H
	PCW   EQU 06H
	
.STACK 128 

;macro to set cursor position on the LCD
GOTO_XY macro x,y     
    MOV DL,y
   MOV DH,x
   CALL LCD_SET_CUR     
endm

.code
main:
	mov ax,@data
	mov ds,ax
	mov es,ax     

	;Send Control word to PPI
	mov dx,PCW
	mov al,10001000b ; control word, mode 0
	out dx,al

	call LCD_INIT     ;Initialize LCD   
	call ATM_Begin
	
proc ATM_Begin

	mov bx, offset inputPin
	
	;prompt for account number
	GOTO_XY 1,1
	lea SI,AccountNo_Prompt
	call LCD_PRINTSTR
	
	;read account no.
	GOTO_XY 1,2
	CALL get_KeyPress
	mov al, var
	mov inputAccNo, al
	
	CALL LCD_CLEAR

	GOTO_XY 1,1
	lea SI,Pin_Prompt
	call LCD_PRINTSTR
	GOTO_XY 1,2
	;read 1st digit
	CALL get_KeyPress
	mov al, var
	mov [bx], al
	;read 2nd digit
	CALL get_KeyPress
	inc bx
	mov al, var
	mov [bx], al
	;read 3rd digit
	CALL get_KeyPress
	inc bx
	mov al, var
	mov [bx], al
	;read 4th digit
	CALL get_KeyPress
	inc bx
	mov al, var
	mov [bx], al
	
	call checkPIN
	
endp



proc checkPIN
	iterate:
		mov bx, passwdCounter		; bx used for indexing array ;for some reason indexing can only be done with a 16-bit register
		checkAccNo:
			;check account no.
			mov al, inputAccNo
			cmp al, 1
			je lAcc1
			cmp al, 2
			je lAcc2
			jg lWrongAccNo
			
			;match the pin to check for in checkPin proc
			lAcc1:
				mov al, pin1[bx]
				jmp compareElem
			lAcc2:
				mov al, pin2[bx]
				jmp compareElem
			lWrongAccNo:
				CALL LCD_CLEAR  ;clear screen
				GOTO_XY 1,1  
				LEA SI, WrongAccNo_Prompt
				jmp errorCheckPIN
		
		compareElem:
			cmp al, inputPin[bx]
			je next
			jne lNotEqual
				
			lNotEqual:
				CALL LCD_CLEAR  ;clear screen
				GOTO_XY 1,1  	
				LEA SI, Wrong_PIN_Prompt
				jmp errorCheckPIN
				
			next:
				inc passwdCounter
				cmp passwdCounter, 4
				jb iterate
	
	jmp successCheckPIN
		
	errorCheckPIN:
		CALL LCD_PRINTSTR
		mov CX, 60000
		call DELAY
		mov CX, 60000
		call DELAY
		mov CX, 60000
		call DELAY
		call resetScreen
		
	successCheckPIN:
		CALL LCD_CLEAR  ;clear screen
		GOTO_XY 1,1  	
		LEA SI, PIN_Accepted_Prompt
		CALL LCD_PRINTSTR
		GOTO_XY 1,2  	
		LEA SI, Welcome_Prompt
		CALL LCD_PRINTSTR
		mov CX, 60000
		call DELAY
		mov CX, 60000
		call DELAY
		call displayMenu
		
endp

proc displayMenu
	Menu_Display:
   	CALL LCD_CLEAR
	
	GOTO_XY 1,1	
	LEA SI,Enter_Tag
	CALL LCD_PRINTSTR 
	
	GOTO_XY 1,2	
	LEA SI,Withdraw_Tag
	CALL LCD_PRINTSTR 
	
	GOTO_XY 1,3	
	LEA SI,Balance_Tag
	CALL LCD_PRINTSTR
	
	GOTO_XY 1,4	
	LEA SI,Deposit_Tag
	CALL LCD_PRINTSTR

    GOTO_XY 14,2
    LEA SI, Quit_Tag
    CALL LCD_PRINTSTR
	
	;read selected menu option
	GOTO_XY 1,2
	CALL get_KeyPress
	mov al, var
	
	call menuAction
	
endp

proc resetScreen
	mov [inputAccNo], 0h
	
	;reset input pin buffer
	xor al, al
	; lea di, inputPin
	mov di, offset inputPin
	mov cx, 4
	cld
	rep stosb
	
	CALL LCD_CLEAR
	call ATM_Begin

endp

proc menuAction
	call LCD_CLEAR
	cmp al, 1
	je	lWithdraw
	cmp al, 2
	je	lBalance
	cmp al, 3
	je	lDeposit
	cmp al, 4
	je	lQuit
	
	lWithdraw:
		lea SI, WithdrawAmountPrompt
		call LCD_PRINTSTR
		call readAmountsV2
	
		call LCD_CLEAR
		GOTO_XY 1,1
		lea SI, NewBalancePrompt
		call LCD_PRINTSTR
		
		mov al, inputAccNo
		cmp al, 1
		je lWithdraw1
		cmp al, 2
		je lWithdraw2
		
		lWithdraw1:
			mov dx, member1Balance
			cmp dx, selectedAmount
			jb withdrawFailed
			sub dx, selectedAmount
			mov member1Balance, dx
			mov num, dx
			GOTO_XY 1,2
			call printNum
			jmp finishOption
				
		lWithdraw2:
			mov dx, member2Balance
			cmp dx, selectedAmount
			jb withdrawFailed
			sub dx, selectedAmount
			mov member2Balance, dx
			mov num, dx
			GOTO_XY 1,2
			call printNum
			jmp finishOption
			
		withdrawFailed:
			call LCD_CLEAR
			GOTO_XY 1,2
			lea SI, InsufficientFundsPrompt
			call LCD_PRINTSTR
			jmp finishOption
		
	lBalance:
		lea SI, Balance_Tag
		call LCD_PRINTSTR
		
		mov al, inputAccNo
		cmp al, 1
		je lBalance1
		cmp al, 2
		je lBalance2
		
		lBalance1:
			;mov ax, member1Balance
			mov dx, member1Balance
			mov	num, dx
			GOTO_XY 1,2
			call printNum
			jmp finishOption
		lBalance2:
			; mov ax, member2Balance
			mov dx, member2Balance
			mov	num, dx
			GOTO_XY 1,2
			call printNum
			jmp finishOption
			
	lDeposit:
		lea SI, DepositAmountPrompt
		call LCD_PRINTSTR
		call readAmountsV2
		
		call LCD_CLEAR
		GOTO_XY 1,1
		lea SI, NewBalancePrompt
		call LCD_PRINTSTR
		
		mov al, inputAccNo
		cmp al, 1
		je lDeposit1
		cmp al, 2
		je lDeposit2
		
		lDeposit1:
			mov dx, member1Balance
			; cmp dx, 50000
			; jg depositFailed
			add dx, selectedAmount
			mov member1Balance, dx
			mov num, dx
			GOTO_XY 1,2
			call printNum
			jmp finishOption
		lDeposit2:
			mov dx, member2Balance
			; cmp dx, 50000
			; jg depositFailed
			add dx, selectedAmount
			mov member2Balance, dx
			mov num, dx
			GOTO_XY 1,2
			call printNum
			jmp finishOption
			
		depositFailed:
			call LCD_CLEAR
			GOTO_XY 1,1
			lea SI, AccountLimitPrompt
			call LCD_PRINTSTR
			jmp finishOption
		
	lQuit:
		lea SI, Goodbye_Prompt
		call LCD_PRINTSTR
		mov cx, 60000
		call DELAY
		mov cx, 60000
		call DELAY
		call resetScreen
		
	finishOption:
		xor cx, cx
		mov cx, 60000
		call DELAY
		mov cx, 60000
		call DELAY
		mov cx, 60000
		call DELAY
		call displayMenu
		ret
endp

proc readAmountsV2
	GOTO_XY 1,2	
	LEA SI,	Amount1kTag
	CALL LCD_PRINTSTR 
	
	GOTO_XY 1,3	
	LEA SI,	Amount2kTag
	CALL LCD_PRINTSTR
	
	GOTO_XY 1,4	
	LEA SI,	Amount5kTag
	CALL LCD_PRINTSTR

    GOTO_XY 11,2
    LEA SI,	Amount8kTag
    CALL LCD_PRINTSTR
	
	GOTO_XY 11,3
    LEA SI,	Amount10kTag
    CALL LCD_PRINTSTR
	
	;read selected amount option
	GOTO_XY 11,4
	CALL get_KeyPress
	mov al, var
	
	cmp al, 1
	je l1k
	cmp al, 2
	je l2k
	cmp al, 3
	je l5k
	cmp al, 4
	je l8k
	cmp al, 5
	je l10k
	
	l1k:
		mov selectedAmount, 1000
		jmp finishreadV2
	l2k:
		mov selectedAmount, 2000
		jmp finishreadV2
	l5k:
		mov selectedAmount, 5000
		jmp finishreadV2
	l8k:
		mov selectedAmount, 8000
		jmp finishreadV2
	l10k:
		mov selectedAmount, 10000
		jmp finishreadV2
	
	finishreadV2:
	ret
	
endp

proc myPrintNum
	mov ax, numToPrint
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
		add al,48
		mov ah, al
		call LCD_WRITE_CHAR  ;input is required in AH
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
			mov ax,rem 
			add al,48
			mov ah, al
			call LCD_WRITE_CHAR
			jmp finishPrint
			
		division:
			cmp rem, 0
			je divCont
			
		    mov ax, rem
			
			divCont:
				xor dx, dx
				div bx      ;ax/bx --> quotient in AX, reminder in DX
				mov rem, dx   ;move reminder to rem
				 
				add al,48	;AX is the qoutient but the result is a single digit, will be stored in AL
				mov ah,al    
				call LCD_WRITE_CHAR
		 
		mov ax, 0h  ;clear AX
		pop cx
	loop printDigit
	
	finishPrint:
	ret
endp
	   

proc printNum 
    mov ax,num    
    cmp ax,10000    
    jae g1  ;greater or equal
    cmp num,10000
    jb  n1 ;less 
;-------------------------------------
     g1:mov bx,10000 
        xor dx,dx
        div bx
        push dx
        add al,30h   ;convert to ascii     
        mov ah,al
	    call LCD_WRITE_CHAR
    	
    	jmp n11   
    	
   n1 :mov ax,num
       jmp a
   n11: 
       pop dx
       mov ax,dx     ;move remainder to ax
       a: cmp ax,0
       je 4zeros
       jne n111
        4zeros: 
        
          LEA SI,4zeros
	      CALL LCD_PRINTSTR
    	  ret
         n111:
          mov bx,1000
          xor dx,dx
          div bx 
          push dx
          add al,30h   ;convert to ascii     
          mov ah,al
	      call LCD_WRITE_CHAR
    	  jmp n22
   
 ;------------------------------------
  n2 :mov ax,num
       jmp b
   n22: 
       pop dx
       mov ax,dx     ;move remainder to ax
       b: cmp ax,0
       je 3zeros
       jne n222
        3zeros: 
        
          LEA SI,3zeros
	      CALL LCD_PRINTSTR
    	  ret
         n222:
          mov bx,100
          xor dx,dx
          div bx 
          push dx
          add al,30h   ;convert to ascii     
          mov ah,al
	      call LCD_WRITE_CHAR
    	  jmp n33
    ;---------------------------------  
   n3 :mov ax,num
       jmp c
   n33: 
       pop dx
       mov ax,dx     ;move remainder to ax
       c: cmp ax,0
       je 2zeros
       jne n333
        2zeros: 
        
          LEA SI,2zeros
	      CALL LCD_PRINTSTR  
    	  ret
         n333:
          mov bx,10
          xor dx,dx
          div bx
          push dx 
          add al,30h   ;convert to ascii     
          mov ah,al
	      call LCD_WRITE_CHAR  
    	  jmp n44
 ;-------------------------------------  
     n4 :mov ax,num
       jmp d
   n44: 
       pop dx
       mov ax,dx     ;move remainder to ax
       d: cmp ax,0
       je 1zeros
       jne n444
        1zeros: 
        
          LEA SI,1zero
	      CALL LCD_PRINTSTR 
    	  ret
         n444:
          mov bx,1
          xor dx,dx
          div bx 
          add al,30h   ;convert to ascii     
    	  mov ah,al
	      call LCD_WRITE_CHAR  
    	   
      ret
endp	   
   
;----------------------------------
;-----------------------------------------------;
;                                               ;
;        KEY PRESS FUNCTION                     ; 
;                                               ; 
;-----------------------------------------------; 
proc get_KeyPress  
    push cx
    keypad:
    MOV CX,00FFH            ; fill in the value of CX with 00ffH
    MOV AL,11111110b        ; value = 1111 1110, set column 0 low
    MOV DX,PORTC            ; mov PORTC to DX
    OUT DX,AL               ;Give this value to PORTA
     
    COLUMN0: 
	 ;Check ROW0
     IN AL,PORTC            ; Get PORTC value 
     MOV KEY,AL    
     CMP KEY,11101110b      ; If PORTC =1111 1110 - button 1 Keypad is pressed?
     JNE ROW1               ; If not, go to ROW1   
     MOV CX,20000           ; delay abit
     CALL DELAY
     MOV AH,'1'             ; Output '1' 
     CALL LCD_WRITE_CHAR 
	 MOV AH,1 
	 MOV VAR,AH             ;store the key pressed
     JMP GOE                 ; continue loop

     ROW1: 
     CMP AL,11011110B       ; Is PORTC == 11011110B  or (4)Keypad button pressed?
     JNE ROW2               ; If not, go to ROW2 of column 1
     MOV CX,20000
	 CALL DELAY
     MOV AH,'4'
	 CALL LCD_WRITE_CHAR
     MOV AH,4 
	 MOV VAR,AH 
     JMP GOE                 ; Continue looop
     
     ROW2: 
     CMP AL,10111110B       ; Is PORTB == 10111110B or 7 Keypad button pressed?
     JNE ROW3               ; If not, go to ROW3
     MOV CX,20000
	 CALL DELAY
	 MOV AH,'7'
	 CALL LCD_WRITE_CHAR
     MOV AH,7 
	 MOV VAR,AH 
     JMP GOE                 ; Go to GO
     
     ROW3: 
     CMP AL,01111110B           ; Is PORTB == 01111110B or keypad star button pressed?
     JNE GO                 ; continue loop
     MOV CX,20000
	 CALL DELAY
     MOV AH,'*'
     CALL LCD_WRITE_CHAR
     MOV AH,11 
	 MOV VAR,AH 
	 JMP GOE
     
     GO:
    ;LOOP COLUMN0             ; Looping to COLUMN1 is CX
    
    MOV CX,00FFH            ; Initialize counter
    MOV AL,11111101B             ; value = 1111 1101, set column 1 low
    MOV DX,PORTC            ; enter PORTA to DX
    OUT DX,AL               ; Give this value to PORTA
     
    COLUMN1: 
                            
     IN AL,PORTC  
     MOV KEY,AL
     CMP KEY,11101101B      ; Is PORTB == 11101101B or 2 Keypad button pressed?           
     JNE ROW11             ; If not, go to ROW12
     MOV CX,20000
	 CALL DELAY  
     MOV AH,'2'
	 CALL LCD_WRITE_CHAR 
	 MOV AH,2
	 MOV VAR,AH 
     JMP GOE
     
     ROW11: 
     CMP AL,0FDH            ; Is PORTB == 0FDH or 5 Keypad button pressed?
     CMP KEY,11011101B
     JNE ROW21              ; If not, go to ROW22
     MOV CX,20000
	 CALL DELAY
	 MOV AH,'5'
	 CALL LCD_WRITE_CHAR
	 MOV AH,5 
	 MOV VAR,AH
     JMP GOE       
      
     ROW21: 
     CMP AL,10111101B            ; Is PORTB == 0F10111101BBH or keypad 8 keypad being pressed?
     JNE ROW31             ;If not, go to ROW32
     MOV CX,20000
	 CALL DELAY
	 MOV AH,'8'
	 CALL LCD_WRITE_CHAR
	 MOV AH,8 
	 MOV VAR,AH
     JMP GOE                ; continue loop
     
     ROW31:               
     CMP AL,01111101B           ; Is PORTB == 01111101B or keypad 0 keypad being pressed?
     JNE GO2                ; If not, go to GO2
     MOV CX,20000
	 CALL DELAY
	 MOV AH,'0'
	 CALL LCD_WRITE_CHAR
	 MOV AH,0 
	 MOV VAR,AH
     JMP GOE 
     
     GO2:                   
    ;LOOP COLUMN1            ; Looping to COLUMN2 is CX
     
    MOV CX,00FFH            ; fill in the value of CX with 00ffH 
    MOV AL,11111011B             ; value = 1111 1011, set column 2 low
    MOV DX,PORTC            ; enter PORTC to DX
    OUT DX,AL               ; Give this value to PORTC
    
     COLUMN2: 
    
     IN AL,PORTC            ; Get PORTB value
     MOV KEY,AL
     CMP KEY,11101011B      ; Is PORTB == 11101011B or button 3 Keypad is pressed?
     JNE ROW12             ; If not, go to ROW13
     MOV CX,20000
	 CALL DELAY
	 MOV AH,'3'
	 CALL LCD_WRITE_CHAR
	 MOV AH,3 
	 MOV VAR,AH
     JMP GOE                ; Continue loop
     
     ROW12: 
     CMP KEY,11011011B    ; Is PORTB == 11011011B or 6 Keypad button pressed?
     JNE ROW22            ;If not, go to ROW23
     MOV CX,20000
	 CALL DELAY
	 MOV AH,'6'
	 CALL LCD_WRITE_CHAR
	 MOV AH,6 
	 MOV VAR,AH
     JMP GOE                ; continue loop
     
     ROW22: 
     CMP KEY,10111011B     ; Is PORTB == 10111011B or keypad 9 key pressed?
     JNE ROW32             ; If not, go to ROW33
     MOV CX,20000
	 CALL DELAY
	 MOV AH,'9'
	 CALL LCD_WRITE_CHAR
	 MOV AH,9 
	 MOV VAR,AH
     JMP GOE                ; Continue loop
     
      ROW32:               ; Is PORTB == 0F7H or Keypad # button pressed?
     CMP KEY,01111011B           
     JNE GO3                
     MOV CX,20000
     CALL DELAY
     MOV AL,VAR
     ;PUSH AX
     MOV AH,22
     MOV VAR,AH
     JMP GOE      
     
     GO3:
    ;LOOP COLUMN2            ; Looping to COLUMN2 by CX    
    JMP keypad               ; Repeat the program again  
    
    GOE:
    ;CMP VAR,22
    ;JNE keypad
    ;POP AX
    ;MOV VAR,AL   
    pop cx
    ret
endp   
   
   
   
   
   
;---------------------------------------------------------------------;    
;--------------------------------------------------------------------- ;
;DELAY Procedure
proc DELAY
;input: CX, this value controls the delay. CX=50 means 1ms
;output: none
	JCXZ @DELAY_END
	@DEL_LOOP:
	LOOP @DEL_LOOP	
	@DELAY_END:
	RET
endp DELAY  
;-------------------------------------------------------
;sends data to output port and saves them in a variable
;------------------------------------------------------
;input: AL
;output: PORTA_VAL
PROC OUT_A
	PUSH DX
	MOV DX,PORTA
	OUT DX,AL
	MOV PORTA_VAL,AL
	POP DX
	RET	
ENDP OUT_A
;----------------------------------
;input: AL
;output: PORTB_VAL
PROC OUT_B	
	PUSH DX
	MOV DX,PORTB
	OUT DX,AL
	MOV PORTB_VAL,AL
	POP DX
	RET
ENDP OUT_B
;---------------------------------
;Punction to output value in port C
;input: AL
;output: PORTC_VAL
proc OUT_C	
	PUSH DX
	MOV DX,PORTC
	OUT DX,AL
	MOV PORTC_VAL,AL
	POP DX
	RET
endp OUT_C   
   
   
   
;-----------------------------------------------;
;                                               ;
;        LCD LIBRARY FUNCTIONS                  ;
;                                               ;
;-----------------------------------------------;
;-----------------------------------------------------
; LCD INITIALIZATION    
;input: none
;output: none
PROC LCD_INIT
;make RS=En=RW=0
	MOV AL,0
	CALL OUT_B
;delay 20ms
	MOV CX,1000
	CALL DELAY
;reset sequence
	MOV AH,30H
	CALL LCD_CMD
	MOV CX,250
	CALL DELAY
	
	MOV AH,30H
	CALL LCD_CMD
	MOV CX,50
	CALL DELAY
	
	MOV AH,30H
	CALL LCD_CMD
	MOV CX,500
	CALL DELAY
	
;function set
	MOV AH,38H                ;8 BIT 2 LINE 5*7 DOTS
	CALL LCD_CMD
	                          ;DISPLAY ON CUSOR OFF
	MOV AH,0CH
	CALL LCD_CMD
	
	MOV AH,01H                ;CLEAR DISPLAY
	CALL LCD_CMD
	
	MOV AH,06H                ;ENTRY MODE
	CALL LCD_CMD
	
	RET	
ENDP LCD_INIT

;-----------------------------------------------
;SEND COMMAND to LCD
;input: AH = command code
;output: none
PROC LCD_CMD
;save registers
	PUSH DX
	PUSH AX
;make rs=0
	MOV AL,PORTB_VAL
	AND AL,0FDH		;En-RS-RW   ;DATA TO SELECT INSTRUCTION REGISTER BY MAKING RS 0 AND RW 1(READ)
	CALL OUT_B
;set out data pins
	MOV AL,AH
	CALL OUT_A
;make En=1
	MOV AL,PORTB_VAL
	OR	AL,100B		;En-RS-RW   ;DATA TO MAKE ENABLE 1
	CALL OUT_B
;delay 1ms
	MOV CX,50
	CALL DELAY
;make En=0
	MOV AL,PORTB_VAL
	AND AL,0FBH		;En-RS-RW   ;DATA TO MAKE ENABLE 0 AND SELECT DATA REGISTER BY MAKING RS 1 AND RW 1(READ)
	CALL OUT_B
;delay 1ms
	MOV CX,50
	CALL DELAY
;restore registers
	POP AX
	POP DX	
	RET
ENDP LCD_CMD


;----------------------------------------------
;CLEAR DISPLAY
PROC LCD_CLEAR
	MOV AH,1             ; CLEAR DISPLAY
	CALL LCD_CMD
	RET	
ENDP LCD_CLEAR

;--------------------------------------------
;WRITE A CHARACTER on current cursor position 
;input: AH
;output: none
PROC LCD_WRITE_CHAR
;save registers
	PUSH AX
;set RS=1                ;DATA REG
	MOV AL,PORTB_VAL
	OR	AL,10B		;EN-RS-RW
	CALL OUT_B
;set out the data pins
	MOV AL,AH
	CALL OUT_A
;set En=1
	MOV AL,PORTB_VAL
	OR	AL,100B		;EN-RS-RW
	CALL OUT_B
;delay 1ms
	MOV CX,50
	CALL DELAY
;set En=0
	MOV AL,PORTB_VAL
	AND	AL,0FBH		;EN-RS-RW
	CALL OUT_B
;return
	POP AX
	RET	
ENDP LCD_WRITE_CHAR

;--------------------------------------
;PRINT STRING on current cursor position
;input: SI=string address, string should end with '$'
;output: none
PROC LCD_PRINTSTR
;save registers
	PUSH SI
	PUSH AX
;read and write character
	@LCD_PRINTSTR_LT:
		LODSB
		CMP AL,'$'
		JE @LCD_PRINTSTR_EXIT
		MOV AH,AL
		CALL LCD_WRITE_CHAR	
	JMP @LCD_PRINTSTR_LT
	
;return
	@LCD_PRINTSTR_EXIT:
	POP AX
	POP SI
	RET	
ENDP LCD_PRINTSTR

;-------------------------------------
;SET CURSOR 
;input: DL=ROW, DH=COL
;		DL = 1, means upper row
;		DL = 2, means lower row
;		DH = 1-8, 1st column is 1
;output: none
PROC LCD_SET_CUR
;save registers
	PUSH AX
;LCD uses 0 based column index
	DEC DH
;select case	
	CMP DL,1
	JE	@ROW1
	CMP DL,2
	JE	@ROW2
    CMP DL,3
	JE	@ROW3
    CMP DL,4
	JE	@ROW4
	JMP @LCD_SET_CUR_END
	
;if DL==1 then
	@ROW1:
		MOV AH,80H
	JMP @LCD_SET_CUR_ENDCASE
	
;if DL==2 then
	@ROW2:
		MOV AH,0C0H
	JMP @LCD_SET_CUR_ENDCASE

    @ROW3:
		MOV AH,94H
	JMP @LCD_SET_CUR_ENDCASE

    @ROW4:
		MOV AH,0D4H
	JMP @LCD_SET_CUR_ENDCASE
		
;execute the command
	@LCD_SET_CUR_ENDCASE:	
	ADD AH,DH
	CALL LCD_CMD
	
;exit from procedure
	@LCD_SET_CUR_END:
	POP AX
	RET
ENDP LCD_SET_CUR

;----------------------------------
;CUSOR BLINKING
;input: none
;output: none
PROC LCD_SHOW_CUR
	PUSH AX
	MOV AH,0FH      ;DISPLAY ON CUSOR BLINKING
	CALL LCD_CMD
	POP AX
	RET
ENDP LCD_SHOW_CUR


;-----------------------------------
;Function to turn Cursor OFF
;input: none
;output: none
PROC LCD_HIDE_CUR
	PUSH AX
	MOV AH,0CH       ;DISPLAY ON CUSOR OFF
	CALL LCD_CMD
	POP AX
	RET
ENDP LCD_HIDE_CUR
;----------------------------------

end main; End of program  
                 
	