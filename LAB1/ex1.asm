; Computer Architectures (02LSEOV)
; Lab n.1
; Simone Iammarino 02/11/2017

DIMS EQU 9   ;define constant
ROWS EQU 9
CLMS EQU 9

.MODEL small ;directive to assembler (code size)

.STACK

.DATA ;puts following in data segment
A_ARRAY DB -128,-64,-32,-16,0,16,32,64,127,10 ;define array of byte
B_ARRAY DW DIMS DUP(?) ;destination of sums (? means not initialize array)
MINA DB 1 DUP(?) ;minimum value element of A_ARRAY 
MINB DW 1 DUP(?) ;minimum value element of B_ARRAY
MATX DW ROWS*CLMS DUP(?) ;matrix 9x9 of word
indexRowA DW 1 DUP(?) ;increment by 1 each time (element 1 byte)
indexColA DW 1 DUP(?) ;increment by 9 each time (9row x 1 byte)
indexRowB DW 1 DUP(?) ;increment by 2 each time (element 2 byte)
indexColB DW 1 DUP(?) ; increment by 18 each time (9row x 2byte)
.CODE ;puts following in code segment
.STARTUP

EX1: 
PUSH AX     ;because this code can be used as procedure
PUSH CX     ;for good programming is better to save all 
PUSH SI     ;the register used
PUSH DI

MOV CX, 9   ;initialize loop counter
XOR SI, SI  ;SI=0 (faster way than MOV or ADD)
XOR DI, DI 

CYCLE:  	
  MOV AL, A_ARRAY[SI]   ;load first addend
	CBW                    ;extend AL to AH signed to prevent overflow
	MOV B_ARRAY[DI], AX  ;save to destination S
	INC SI                 ;select next addend
	MOV AL, A_ARRAY[SI] ;load next addend
	CBW                    ;extend second addend
	ADD B_ARRAY[DI], AX  ;sum with previous addend directly into destination
	ADD DI, 2              ;+2 because the sum is a word array (two byte)
  LOOP CYCLE               ;equal to CMP CX,0 JNZ CYCLE

POP DI
POP SI 
POP CX
POP AX

EX2:
;initialization
PUSH AX
PUSH CX
PUSH SI

MOV CX, 9
XOR SI, SI
XOR AX, AX               ;initialize AX = 0
MOV MINA, 127            ;max value (8 bit signed, choose 255 if unsigned)

;compare each data of array to last minimum, if lower update minimum
MIN_LOOP_A:
  MOV AL, A_ARRAY[SI] ;select data element
  CMP AL, MINA           ;compare to last minimum
  JGE GreatA             ;A>B no new minimum, for SIGNED element
  ;JAE GreatA            ;for UNSIGNED element (update also MINA)
  MOV MINA, AL           ;A<B NEW minimum
  GreatA:
  INC SI
  LOOP MIN_LOOP_A

;initialization
MOV CX, 8                ;B_ARRAY has 9 element
XOR SI, SI
XOR AX, AX
MOV MINB, 32767          ;max value (16 bit signed, choose 65536 if unsigned)

;equal to previous case but now we have DW (16bit) so SI is incremented by 2
MIN_LOOP_B:
  MOV AX, B_ARRAY[SI]  ;select data element
  CMP AX, MINB           ;compare to last minimum
  JGE GreatB             ;A>B no new minimum, for SIGNED element
  ;JAE Great             ;for UNSIGNED element (update also MINB)
  MOV MINB, AX           ;A<B NEW minimum
  GreatB:
  ADD SI, 2
  LOOP MIN_LOOP_B

POP SI
POP CX
POP AX


;How to index a matrix:
;a matrix is a simple vector of 8bit element in memory
;indexed by an address (e.g MATX)
;we can move through columns and rows using index (e.g SI and BX)
;that simply are the offset from MATX address.

;e.g MOV BX, 0
;    MOV SI, 3
;    MOV MATX[BX][SI], 1
;    set the value of MATX[0][3]=1

;WARNING: we must know how many byte is each element of the matrix 
;         to move through its element correctly! 


;e.g : selecting the element 2:2 of a 4row x 2cols 2byte element matrix
;    MOV BX, 8  select second column offset (2byte x 4)
;    MOV SI, 4  select second element in column (row) (2byte)
;    MOV AX, MATX[BX][SI] -> select element MATX[2][2]

EX3:

MOV CX, CLMS
XOR AX, AX 
XOR BX, BX ;used to index columns

;reset index
MOV indexColA, 0
MOV indexRowA, 0
MOV indexColB, 0
MOV indexRowB, 0

COL_LOOP: PUSH CX ;using CX for every loop 
          MOV CX, ROWS ;update for row loop

ROW_LOOP: MOV BX, indexColA
          MOV SI, indexRowA
          MOV AL, A_ARRAY[BX][SI] ;take element of A array
          CBW ;extend sign
          MOV BX, indexColB
          MOV SI, indexRowB
          MOV DX, B_ARRAY[BX][SI] ;take element of B array
          ADD AX, DX
          MOV MATX[BX][SI], AX ;save in the new matrix
          INC indexRowA ;move by byte   
          ADD indexRowB, 2 ;move by word      
          LOOP ROW_LOOP
          
          MOV indexRowA, 0 ;reset row index
          MOV indexRowB, 0
          
          ADD indexColA, CLMS
          ADD indexColB, CLMS*2
          POP CX
          LOOP COL_LOOP

.EXIT
END