; Computer Architectures (02LSEOV)
; Lab n.2
; Simone Iammarino 06/11/2017

MAXDIM EQU 10
MINDIM EQU 5
RETURN EQU 0dh ;binary value of return character \n

.MODEL small
.STACK

.DATA
FIRST_ROW  DB MAXDIM DUP(?)
SECOND_ROW DB MAXDIM DUP(?)
THIRD_ROW  DB MAXDIM DUP(?)
FOURTH_ROW DB MAXDIM DUP(?)
CKDCHR DB 26 DUP(0)
.CODE
.STARTUP

ex1_readFromKey:
MOV CX,4 ;init row cycle
MOV AH,1 ;instruct 21H ISR to read and save key value into AL
XOR BX,BX
;for(CX=4,CX=0,CX--)
row_loop:
PUSH CX ;push counter each nested cycle
MOV CX,MAXDIM ;init char cycle 
XOR DI,DI
  ;for(CX=MAXDIM,CX=0,CX--)
  char_loop: 
    INT 21H ;wait interrupt (press key)
    ;if char = \n check exit condition
      CMP AL, RETURN
      JE check20
    ;else save the character
      MOV FIRST_ROW[BX][DI],AL ;rows saved sequentially in memory, we can reach all starting from FIRST_ROW
      INC DI
      JMP skipCheck20 ;(must terminate skipping the other condition code)
    check20:
    ;if number of chars < 20 continue input (without update CX or DI)
      CMP DI,MINDIM
      JB char_loop
    ;else jump to next row 
      JMP new_row
    skipCheck20:  
  LOOP char_loop
  ;end for (char_loop)
new_row:
POP CX
ADD BX,MAXDIM ;offset for next row
LOOP row_loop
;end for (row_loop)

ex2_countChar:
MOV CX,4
XOR BX,BX
XOR SI,SI
;for(CX=4,CX=0,CX--)
row_loop_2:
  PUSH CX
  MOV CX,MAXDIM
  ;for(CX=MAXDIM,CX=0,CX--)
  char_loop_2:
    MOV AL, FIRST_ROW[BX][SI]
    CALL alreadyChecked
    ;if BX=1: char already checked, skip to next char
    ;else: count the time that appares in the row
    INC SI
  LOOP char_loop_2
  ;end for (char_loop_2)
  XOR SI,SI
  ADD BX,MAXDIM
LOOP row_loop_2
;end for (row_loop_2)

.EXIT

;checks if the character is already counted in that row
;character passed into AL
;result writed into: AH=0 -> counted, AH=0 -> not counted
alreadyChk PROC
PUSH SI
XOR AH,AH
XOR SI,SI

;if CHKCHR empty set AH=0 and return
  CMP CHKCHR[0],0
  JE skip_empty
;else
  ;while EOS CHKCHR (End Of String) 
  check_loop:
    ;if present: AH=1
      CMP AL,CHKCHR[SI]
    ;else: AH=0
    ;end wile (check_loop)
skip_empty:
MOV AH,0  
POP SI
RET
alreadyChecked ENDP

END