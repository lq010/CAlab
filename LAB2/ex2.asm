; Computer Architectures (02LSEOV)
; Lab n.2
; Simone Iammarino 06/11/2017

MAXDIM EQU 50
RETURN EQU 0dh ;binary value of return character \n

.MODEL small
.STACK

.DATA
FIRST_ROW  DB MAXDIM DUP(?)
SECOND_ROW DB MAXDIM DUP(?)
THIRD_ROW  DB MAXDIM DUP(?)
FOURTH_ROW DB MAXDIM DUP(?)
var DW 0

.CODE
.STARTUP

ex1_readFromKey:
MOV CX,MAXDIM
XOR DI,DI
MOV AH,1 ;instruct 21H ISR to read and save key value into AL

firstRow: 
INT 21H ;wait interrupt (press key)
MOV FIRST_ROW[DI],AL ;the char (1byte) is saved into AL (21H ISR)
CMP AL, RETURN ;if return character jump to second row
JZ secondRowInit ;jump if are equal
INC DI
LOOP firstRow

secondRowInit: ;reset variable
MOV CX,MAXDIM
XOR DI,DI
secondRow:
INT 21H
MOV SECOND_ROW[DI],AL
CMP AL, RETURN
JZ thirdRowInit
INC DI
LOOP secondRow

thirdRowInit:
MOV CX,MAXDIM
XOR DI,DI
thirdRow:
INT 21H
MOV THIRD_ROW[DI],AL
CMP AL, RETURN
JZ fourthRowInit
INC DI
LOOP thirdRow

fourthRowInit:
MOV CX,MAXDIM
XOR DI,DI
fourthRow:
INT 21H
MOV FOURTH_ROW[DI],AL
CMP AL, RETURN
JZ ex2_countChar
INC DI
LOOP fourthRow

ex2_countChar: 
MOV CX,MAXDIM
XOR DI,DI
XOR BX,BX
MOV BL,offsetFIRST_ROW
nextChar:
MOV AL, FIRST_ROW[DI] ;select char
;CMP AL, RETURN ;check end
CALL countChar
INC DI
LOOP nextChar


.EXIT

;is char already 

;how many times each char is present in a row?
countChar PROC
PUSH CX
PUSH DI
XOR SI,SI ;time counter
countLoop:    
CMP AL,BX[DI]
JNZ endLoop ;if not equal does not increment SI
INC SI
endLoop:
LOOP countLoop
MOV var,SI
POP DI
POP CX
countChar ENDP

END