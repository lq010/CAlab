#start=8259.exe

add8255PortA EQU 80h
add8255PortB EQU add8255PortA+1
add8255PortC EQU add8255PortA+2
add8255control EQU add8255PortA+3
add8259intPort EQU 40h ;8259 has only one port

.CODE

.STARTUP

cli ;disable interrupt
;initialize pheripheral
call init_8255                      
call init_8259
call init_ivt
sti ;enable interrupt

;main code
main:
JMP main


.EXIT

init_8255 PROC
MOV DX, add8255control ;select control port of 8255
MOV AL, 10110000b      ;portA input, mode 1
OUT DX, AL
init_8255 ENDP

init_8259 PROC
init_8259 ENDP

init_ivt PROC
init_ivt ENDP


    




                                                                      