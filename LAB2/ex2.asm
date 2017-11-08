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
temp DB 4

.CODE
.STARTUP

ex1_readFromKey:
;init counter
MOV CX,4
MOV AH,1 ;instruct 21H ISR to read and save key value into AL
XOR BX,BX

read:
 PUSH CX
 MOV CX,MAXDIM ;init internal cycle
 XOR DI,DI
 readRow: 
  INT 21H ;wait interrupt (press key)
  CMP AL, RETURN ;if return character jump to check20
  JZ check20 ;control if are minimum 20
  MOV FIRST_ROW[BX][DI],AL ;the char (1byte) is saved into AL (21H ISR) (skipped if \n)
  INC DI  
 LOOP readRow
 exitRow:
 POP CX
 ADD BX,MAXDIM
LOOP read

check20:
CMP DI,20 ;if there are 20 chars continue to next row
JB readRow ;if <20 continue input
JMP exitRow

;ex2_countChar: 
; MOV CX,MAXDIM
; XOR DI,DI
; XOR BX,BX
; MOV BL,offset FIRST_ROW
; nextChar:
; MOV AL, FIRST_ROW[DI] ;select char
; CMP AL, RETURN ;check end
; CALL countChar
; INC DI
; LOOP nextChar

exit_label:
.EXIT

;is char already 

;how many times each char is present in a row?
; countChar PROC
; PUSH CX
; PUSH DI
; XOR SI,SI ;time counter
; countLoop:    
; CMP AL,BX[DI]
; JNZ endLoop ;if not equal does not increment SI
; INC SI
; endLoop:
; LOOP countLoop
; MOV var,SI
; POP DI
; POP CX
; countChar ENDP

END