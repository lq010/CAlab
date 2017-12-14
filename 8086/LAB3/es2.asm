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

;init loop registers
MOV CX,128
MOV SI,255
;for(CX=255;CX=0;CX--)
decreasing_loop:
  ;write A
  MOV AX,SI ;AH will not be written because SI<=255
  MOV DX,portA
  OUT DX,AL
  ;write B
  DEC SI
  MOV AX,SI
  MOV DX,portB
  OUT DX,AL
  DEC SI
LOOP decreasing_loop
   
.exit    

init_8255 PROC
  MOV DX, control ;select control register of 8255
  MOV AL, 10001001b ;8255 control word: PortA/PortB mode0 input, PortC output
  OUT DX, AL ;DX placed on address bus, AL to data bus 
  RET
init_8255 ENDP
             
end