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
;init read cycle
MOV CX,4
MOV AH,1 ;instruct 21H ISR to read and save key value into AL
XOR BX,BX
read:
 PUSH CX ;do a push of counter cycle each nested cycle
 ;init readRow cycle
 MOV CX,MAXDIM 
 XOR DI,DI
 readRow: 
  INT 21H ;wait interrupt (press key)
  ;A: if \n jump to check20
  CMP AL, RETURN
  JZ check20
  ;else save the character
    MOV FIRST_ROW[BX][DI],AL ;the char (1byte) is saved into AL (21H ISR) (skipped if \n)
                             ;the row are saved sequentially in the memory so the starting address can be FIRST_ROW
    INC DI
    JMP skipCheck20 ;(must terminate skipping the other condition code)
  check20: ; A: code
    CMP DI,20
    ;if number of char inserted < 20 continue input row (without update CX or DI)
    JB readRow
    ;else jump to next row 
    JMP exitRow
  skipCheck20:  
 LOOP readRow
 exitRow:
 POP CX
 ADD BX,MAXDIM ;offset for next row
LOOP read

ex2_countChar:
;init nextRow cycle
MOV CX,4
XOR BX,BX
nextRow: ;foreach row
 PUSH CX
 ;init nextChar cycle
 MOV CX,MAXDIM 
 XOR DI,DI
 XOR AX,AX
 nextChar: ;foreach char
  PUSH CX
  PUSH DI ;position of current char
  MOV AL,FIRST_ROW[BX][DI] ;select char
  MOV CX,MAXDIM 
   scan:  
    CMP AL,FIRST_ROW[BX][CX] ;compare char
    ;if not equal try next element of array
    JNE notFind
    ;else increment counter
    INC DI ;number of time founded
    notFind:
   LOOP scan 
     
 LOOP readRow
 exitRow:
 POP CX
 ADD BX,MAXDIM
LOOP read
 
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