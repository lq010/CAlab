;addresses of pheripheral registers
portA EQU 80h
portB EQU portA+1
portC EQU portA+2
control EQU portA+3

#start=8255.exe# ;load model of the pheripheral 8255
.model small
.data
reading DB ?
.stack
.code
.startup
     
CLI ;Clear Interrupt Flag (ignore all interrupts)     
CALL init_8255 ;programm 8255
STI ;Enable interrupt (after writing the coresponding routines)

;never ending loop
write_character: 
;write 'O' on PortA
MOV AL, 4Fh ;data
MOV DX, portA ;address
OUT DX,AL

;write 'K' on PortB
MOV AL, 4Bh ;data
MOV DX, portB ;address
OUT DX,AL

;read char on portC
MOV DX, portC
IN AL, DX
MOV reading,AL

.exit    

init_8255 PROC
  MOV DX, control ;select control register of 8255
  MOV AL, 10001001b ;8255 control word: PortA/PortB mode0 input, PortC output
  OUT DX, AL ;DX placed on address bus, AL to data bus 
  RET
init_8255 ENDP
            
end