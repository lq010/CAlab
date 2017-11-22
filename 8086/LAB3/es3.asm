;addresses of pheripheral registers
portA EQU 80h
portB EQU portA+1
portC EQU portA+2
control EQU portA+3

#start=8255.exe# ;load model of the pheripheral 8259
.model small
.data
.stack
.code
.startup
     
CLI ;Clear Interrupt Flag (ignore all interrupts)     
CALL init_8255
STI ;Enable interrupt after write the coresponding routines

CALL readA

.exit    

init_8255 PROC
  MOV DX, control ;select control register of 8255
  MOV AL, 10011001b ;8255 control word: mode0 PortA/PortC input, PortB output
  OUT DX, AL ;DX placed on address bus, AL to data bus 
  RET
init_8255 ENDP

readA PROC
PUSH AX
PUSH DX
XOR AX,AX
MOV DX,portA
IN AL,DX
;lowercase characters from ASCII 097
;if AL>=97: lowercase, capitalize and write on portB 
CMP AL,97
JB skip_readA
SUB AL,32 ;the offset between lowercase and uppercase ASCII characters is 32 
MOV DX,portB
OUT DX,AL
;else: do nothing
skip_readA:
POP DX
POP AX
RET
readA ENDP
   
end