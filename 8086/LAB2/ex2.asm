; Computer Architectures (02LSEOV)
; 8086 - Lab n.2
; Simone Iammarino 06/11/2017

MAXDIM EQU 10  ;must be multiple of 2!
MINDIM EQU 5
RETURN EQU 0dh ;binary value of return character \n

.MODEL small
.STACK

.DATA
FIRST_ROW  DB MAXDIM DUP(?)
SECOND_ROW DB MAXDIM DUP(?)
THIRD_ROW  DB MAXDIM DUP(?)
FOURTH_ROW DB MAXDIM DUP(?)

CHARLIST1 DB MAXDIM*2 DUP(?) ;contains pair #occurrence(LSB)-char(MSB) (2byte)
CHARLIST2 DB MAXDIM*2 DUP(?)
CHARLIST3 DB MAXDIM*2 DUP(?)
CHARLIST4 DB MAXDIM*2 DUP(?)

CHARLIST_POS DW 0 ;point to next free space in char list
CHARLIST_NUM DW 0 ;point to current char list (offset from CHARLIST1)

tempCount DB 0 ;used for counteng characters
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
    CALL alreadyCounted
    ;if result=1: char already counted, skip to next char
      CMP AH,1
      JE next_char
    ;else: count the time that appares in the row
      CALL countTime
    next_char:
    XOR AH,AH
    INC SI
  LOOP char_loop_2
  ;end for (char_loop_2)
ADD CHARLIST_NUM,MAXDIM*2 ;next charlist
MOV CHARLIST_POS,0 ;reset for next row
XOR SI,SI
ADD BX,MAXDIM ;next row
POP CX
LOOP row_loop_2
;end for (row_loop_2)

;print characters that appear MAXDIM/2 times
MOV CX,4
XOR BX,BX
XOR SI,SI
XOR AX,AX
XOR DX,DX
MOV AH,2 ;print on int 21h enabled
;for(CX=4,CX=0,CX--)
half_max_time:
  ;while CHARLIST[BX][SI]=0: means no other characters
  charlist_scan:
    ;if end charlist: next charlist
      MOV DL,CHARLIST1[BX][SI]
      CMP DL,0
      JE skip_scan
    ;else: scan charlist
      ;if character=MAXDIM/2: print
        CMP DL,MAXDIM/2
        JE print_char
      ;else: next character
        ADD SI,2
        JMP charlist_scan
      print_char:
      INC SI
      MOV DL,CHARLIST1[BX][SI] ;selects character
      INT 21H
      INC SI
  JMP charlist_scan
  ;end while (charlist_scan)
  skip_scan:
  XOR SI,SI
  ADD BX, MAXDIM*2 ;next charlist
LOOP half_max_time
;end for (half_max_time)

.EXIT

;---------------------------------------------------------
;checks if the character is already counted in that row
;character passed into AL
;result written into: AH=1 -> counted, AH=0 -> not counted
alreadyCounted PROC
PUSH SI
PUSH BX
XOR BX,BX
XOR AH,AH
MOV SI,1 ;character contained each 2byte starting from the second
MOV BX,CHARLIST_NUM
;while CHARLIST > 0
check_loop:
  ;if present: AH=1
    CMP AL, CHARLIST1[BX][SI]
    JE set_high
  ;else: AH=0
    CMP CHARLIST1[BX][SI],0
    JE set_low
    ADD SI,2
JMP check_loop
;end wile (check_loop)
  
set_high:
ADD AH,1
set_low:
POP BX
POP SI
RET
alreadyCounted ENDP

;---------------------------------------------------------
;count the number of time one character is present in a row
;starting from current character (SI) (scans only the element that follow current character)
;character passed into AL, row are distinguished by passed BX offset
;result written into tempCount
countTime PROC
PUSH SI ;is not resetted
MOV tempCount,0
;while(SI<MAXDIM)
char_loop_3:
  ;if AL = character: increase counter
    CMP AL,FIRST_ROW[BX][SI]
    JNE no_find
  ;else
    ADD tempCount,1
  no_find:
  INC SI ;next char
  CMP SI,MAXDIM
JBE char_loop_3
;end while (char_loop_3)

;save tempCount to CHARLISTx
MOV SI, CHARLIST_POS ;next free position (#occurrence) in CHARLIST
PUSH BX
MOV BX, CHARLIST_NUM
PUSH DX
MOV DL, tempCount
MOV CHARLIST1[BX][SI],DL
POP DX
INC SI ;next free position (character) in CHARLIST
MOV CHARLIST1[BX][SI],AL
ADD CHARLIST_POS,2
POP BX
POP SI
RET
countTime ENDP

END