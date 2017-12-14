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

XOR AX,AX
XOR BX,BX
MOV DX,portC
wait_portC_LSB:
  IN AL,DX ;read portC
  AND AL,00000001b ;selects only LSB 
  ;if AL=1: 
    CMP AL,1
    JNE skip1
    ;if BX=0: previous value was 0, call routines
      CMP BX,0
      JNE skip2
      CALL readA
      MOV BX,1 ;"routine called" flag
      JMP skip2
    ;else: do nothing
  ;else AL=0: reset flag
  skip1:
  MOV BX,0 ;reset flag
  skip2:
JMP wait_portC_LSB

.exit    

init_8255 PROC
  MOV DX, control ;select control register of 8255
  MOV AL, 10011001b ;8255 control word: mode0 PortA/PortC input, PortB output
  OUT DX, AL ;DX placed on address bus, AL to data bus 
  RET
init_8255 ENDP

;read portA: if lowercase ASCII character write into portB the uppercase value
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