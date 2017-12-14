;addresses of pheripheral input (memory mapped)
;(defined between 8086 and 8255)
portA EQU 80h
portB EQU portA+1
portC EQU portA+2
control EQU portA+3
pic EQU 40h ;input port of 8559

#start=8259.exe# ;load model of the pheripheral 8259
.model small
.data
.stack

.code
.startup
     
CLI ;Clear Interrupt Flag (ignore all interrupts)     
     
; 1) programm 8259
CALL init_8259
; 2) programm 8255
CALL init_8255
; 3) configure Interrupt Vector Table
CALL init_IVT
; 4) main programm

STI ;Enable interrupt after write the coresponding routines

;do nothing
block: 
    jmp block
    
.exit    

init_8255 PROC
    
    MOV DX, control ;memory mapped I/O: select output port (80h = 8255)
    MOV AL, 10110100b ;programming control word for 8255
    OUT DX, AL
    
    ;enabling interrupt for portA
    MOV AL, 00001001b ;single bit set/reset
    OUT DX, AL
    
    ;enabling interrupt for portB
    MOV AL, 00000101b 
    OUT DX, AL
    
    RET
init_8255 ENDP

init_8259 PROC ;send initialization control words to the pheripheral
    
    ;ICW1
    MOV DX, pic  ;memory mapped I/O: select output port (40h = 8259)
    MOV AL, 00010011b
    OUT DX, AL
    
    ;ICW2
    MOV AL, 00100000b
    OUT DX, AL
    
    ;ICW4
    MOV AL, 00000011b
    OUT DX, AL
              
    ;OCW1
    MOV AL, 01101111b
    OUT DX, AL
    
    RET          
init_8259 ENDP

init_IVT PROC
    ; writing the address of ISR pa on the IVT
    MOV AX, 0
    MOV DS, AX
    MOV BX, 00100111b
    MOV CL, 2
    SHL BX, CL 
    MOV AX, OFFSET isr_pa_in 
    MOV DS:[BX], AX
    MOV AX, SEG isr_pa_in
    MOV DS:[BX+2], AX 
    
    ;for pb
    MOV BX, 00100111b
    MOV CL, 2
    SHL BX, CL 
    MOV AX, OFFSET isr_pb_out 
    MOV DS:[BX], AX
    MOV AX, SEG isr_pa_out
    MOV DS:[BX+2], AX
        
    RET
init_IVT ENDP
 
;ISR (Interrupt Service Routine) code
isr_pa_in PROC
    PUSH AX
    PUSH DX
    ;read byte from portA
    MOV DX, portA
    IN AL, DX 
    
    ;compare AL with character 0 and 9, end if true
    CMP AL, '0'
    JMP endPA
    CMP AL, '9'
    JMP endPA
    
    ;the character is a digit
    SUB AL, '0'
    MOV DX, portB
    OUT DX, AL
    
    DEC AL
    MOV myNumber, AL
    
endPA:
    POP DX
    POP AX
    IRET ;can happen that an interrupt arrives when we are inside a procedure
         ;so the CALL has saved its the return address in the stack.
         ;If we use RET here we read this address and return from CALL after interrupt    
isr_pa_in ENDP

isr_pb_out PROC
    PUSH AX
    PUSH DX
    
    MOV AL, myNumber
    CMP AL, 0
    JBE endPB
    MOV DX, portB
    OUT DX, AL
    DEC count
endPB:
    POP DX
    POP AX
    IRET    
isr_pb_out ENDP
            
end