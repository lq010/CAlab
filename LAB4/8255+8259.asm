portA EQU 80h
portB EQU portA + 1
portC EQU portA + 2
control EQU portA + 3
pic EQU 40h

#start=8259.exe#

.model small
.data
myNumber DB ?
.stack

.code
.startup
; our code here
CLI
; 1) program 8259
CALL init_8259
; 2) program 8255
CALL init_8255
; 3) configure interrupt vector table
CALL init_IVT
STI

; 4) main program
MOV AX, 0
block:
    INC AX
    jmp block
    

.exit

init_IVT PROC
    PUSH DS
    
    ; writing the address of isr_pa_in on the IVT 
    MOV AX, 0
    MOV DS, AX
    MOV BX, 00100111b
    MOV CL, 2
    SHL BX, CL
    MOV AX, OFFSET isr_pa_in
    MOV DS:[BX], AX     ; same as MOV [BX], AX
    MOV AX, SEG isr_pa_in
    MOV DS:[BX + 2], AX
    
    ; writing the address of isr_pb_out on the IVT 
    MOV BX, 00100100b
    MOV CL, 2
    SHL BX, CL
    MOV AX, OFFSET isr_pb_out
    MOV DS:[BX], AX
    MOV AX, SEG isr_pb_out
    MOV DS:[BX + 2], AX
    
    POP DS
    RET
init_IVT ENDP


init_8259 PROC
    ; ICW1
    MOV DX, pic
    MOV AL, 00010011b
    OUT DX, AL
    
    ;ICW2
    MOV DX, pic + 1
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
              
init_8255 PROC
    MOV DX, control
    MOV AL, 10110100b
    OUT DX, AL 
    ; enabling interrupt for port A
    MOV AL, 00001001b
    OUT DX, AL
    ; enabling interrupt for port B
    MOV AL, 00000101b
    OUT DX, AL  
    RET
init_8255 ENDP              
              
; our interrupt service routines

isr_pa_in PROC
    PUSH AX
    PUSH DX
    MOV DX, portA
    IN AL, DX
    ; is it a digit?
    CMP AL, '0'
    JBE endPA    
    CMP AL, '9'
    JA endPA
    ; the character is a digit
    SUB AL, '0'
    MOV DX, portB
    OUT DX, AL
    
    DEC AL
    MOV myNumber, AL
    
endPA:
    POP DX
    POP AX
    IRET
isr_pa_in ENDP


isr_pb_out PROC
    PUSH AX
    PUSH DX
    
    MOV AL, myNumber
    CMP AL, 0
    JBE endPB
    MOV DX, portB
    OUT DX, AL
    DEC myNumber
    
endPB:
    POP DX
    POP AX
    IRET    
isr_pb_out ENDP
end