;addresses of pheripheral registers
portA EQU 80h
portB EQU portA+1
portC EQU portA+2
control EQU portA+3

#start=8255.exe# ;load model of the pheripheral 8259
.model small
.data
res DB ?
.stack
.code
.startup
     
CLI ;Clear Interrupt Flag (ignore all interrupts)     
CALL init_8255
STI ;Enable interrupt after write the coresponding routines

es4:
XOR AX,AX
XOR BX,BX
;res = NOT(portA XOR portB)
MOV DX,portA
IN AL,DX
MOV BL,AL
MOV DX,portB
IN AL,DX
XOR BL,AL
NOT BL
MOV res, BL

;store res in portC register via "Single Bit Set/Reset" of 8255
XOR SI,SI
MOV AL,BL
MOV DX,portC
;for(SI=0;SI<8;SI++)
setbit:
  ;if CF=1: set corrispective portC bit to 1
    SAR AL,1
    JC set1
    set0:
    PUSH SI
    SAL SI,1
    OR AX,SI
    POP SI
    JMP skip_set
  ;else: set portC bit to 0
    ;create a mask for CW that will set the correct bit in portC
    set1:
    PUSH SI
    SAL SI,1
    OR AX,SI
    OR AL,00000001b
    POP SI
  skip_set:
  ;write portC bit
  OUT DX,AL
  XOR AX,AX
  INC SI
  CMP SI,7
JE setbit
;end for (setbit)

.exit    

init_8255 PROC
  MOV DX, control ;select control register of 8255
  MOV AL, 10010010b ;8255 control word: mode0 PortA/PortB input, PortC output
  OUT DX, AL ;DX placed on address bus, AL to data bus 
  RET
init_8255 ENDP

   
end