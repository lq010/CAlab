add8255PortA EQU 80h
add8255PortB EQU add8255PortA+1
add8255PortC EQU add8255PortA+2
add8255control EQU add8255PortA+3
add8259controlReg0 EQU 40h
add8259controlReg1 EQU add8259controlReg0+1
MAXCHAR EQU 20
#start=8259.exe

.MODEL small
.DATA
myWord DB MAXCHAR DUP(?) ;stores read characters
.STACK

.CODE

.STARTUP

CLI ;disable interrupt
;initialize peripherals
CALL init_8255                      
CALL init_8259
CALL init_ivt
STI ;enable interrupt

;main code
main:
JMP main


.EXIT

init_8255 PROC
MOV DX, add8255control ;select control port of 8255
MOV AL, 10110000b ;control word: portA input, mode 1
OUT DX, AL ;put address/data to address_bus/data_bus 
init_8255 ENDP

init_8259 PROC
;ICW1
MOV DX, add8259control
MOV AL, 00010011b ;single mode, edge triggered, ICW4 present
OUT DX, AL
    
;ICW2
MOV DX, add8259control + 1
MOV AL, 00100000b ;interrupt vector starts at 04h (bit 7 downto 3)
OUT DX, AL
    
;ICW4
MOV AL, 00000011b ;8086 mode, AEOI(reset ISR) 
OUT DX, AL
    
;OCW1
MOV AL, 01101111b ;enable only ch7 (8255 INTRa) and ch4 (8255 INTRb), mask the others
OUT DX, AL            
RET              
init_8259 ENDP

init_ivt PROC
init_ivt ENDP


    




                                                                      