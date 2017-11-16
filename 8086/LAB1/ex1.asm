; Computer Architectures (02LSEOV)
; Lab n.1
; Simone Iammarino 15/11/2017

DIMS EQU 9   ;define constant
ROWS EQU 9
CLMS EQU 9

.MODEL small ;directive to assembler (code size)

.STACK

.DATA ;puts following in data segment
A_ARRAY DB -1,-2,-3,-4,-5,6,7,8,9,10 ;define array of byte
B_ARRAY DW DIMS DUP(?) ;destination of sums (? means not initialize array)
MINA DB 1 DUP(?) ;minimum value element of A_ARRAY 
MINB DW 1 DUP(?) ;minimum value element of B_ARRAY
MATX DW ROWS*CLMS DUP(?) ;matrix 9x9 of word
.CODE ;puts following in code segment
.STARTUP

EX1: 
MOV CX, 9   ;initialize loop counter
XOR SI, SI  ;SI=0 (faster way than MOV or ADD)
XOR DI, DI 

CYCLE:  	
  MOV AL, A_ARRAY[SI]    ;load first addend
	CBW                    ;extend AL to AH signed to prevent overflow
	MOV B_ARRAY[DI], AX    ;save to destination S
	INC SI                 ;select next addend
	MOV AL, A_ARRAY[SI]    ;load next addend
	CBW                    ;extend second addend
	ADD B_ARRAY[DI], AX    ;sum with previous addend directly into destination
	ADD DI, 2              ;+2 because the sum is a word array (two byte)
LOOP CYCLE               ;equal to CMP CX,0 JNZ CYCLE

EX2:
MOV CX, 9
XOR SI, SI
XOR AX, AX               ;initialize AX = 0
MOV MINA, 127            ;max value (8 bit signed, choose 255 if unsigned)

;compare each data of array to last minimum, if lower update minimum
MIN_LOOP_A:
  MOV AL, A_ARRAY[SI]    ;select data element
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
  MOV AX, B_ARRAY[SI]    ;select data element
  CMP AX, MINB           ;compare to last minimum
  JGE GreatB             ;A>B no new minimum, for SIGNED element
  ;JAE Great             ;for UNSIGNED element (update also MINB)
  MOV MINB, AX           ;A<B NEW minimum
  GreatB:
  ADD SI, 2
LOOP MIN_LOOP_B

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
;         to move through its element correctly! Otherwise we read/write
;         different location


;e.g : selecting the element 2:2 of a 4row x 2cols 2byte element matrix
;    MOV BX, 8  select second column offset (2byte x 4)
;    MOV SI, 4  select second element in column (row) (2byte)
;    MOV AX, MATX[BX][SI] -> select element MATX[2][2]


;NOTE: we can't index MATX with DI and SI, (use BX and SI).
;      we can't index arrays with loop register CX
;      we can shift only with immediate or CL

EX3:

MOV CX, 9
XOR DI, DI ;index A elements
XOR BX, BX ;index MATX columns
A_LOOP:
  MOV AL, A_ARRAY[DI]
  CBW
  PUSH CX
  MOV CX, 9 
  XOR SI, SI ;index B elements
  B_LOOP: ;multiply AxB and save into matrix MATX[BX][SI]
    PUSH AX
    PUSH BX
    MOV BX, B_ARRAY[SI]
    PUSH CX
    PUSH SI
    CALL multiply_signed
    POP SI
    POP CX
    POP BX
    POP AX
    MOV MATX[BX][SI], DX   
    ADD SI,2 ;B_ARRAY is 2byte element
  LOOP B_LOOP
  POP CX
  ADD BX, 18 ;next column 8*2byte
  INC DI     ;next A_ARRAY element
LOOP A_LOOP          
          
EX4:
;max value on signed 16bit: -32768 to -32767
;(max value in B = A+A = -256)
;127*255= 32385 (no OVF)
;-128*255= -32640 (no OVF)
;127*-256= -32512 (no OVF)
;-128*-256= 32768 (OVF!!!)		  
		  
.EXIT

;DX = AX x BX (uses AX, BX, CX, DX, SI)
multiply_signed PROC 
XOR DX, DX
XOR CX, CX
XOR SI, SI

;if AX=1 or BX=1 do nothing 
  CMP BX, 1 
  JE skip_multiply_signed_B
  CMP AX, 1 
  JE skip_multiply_signed_A
;else:
  ;while(SI < 16)
    nextbit: 
    ;if shifted out AX bit is zero (CF=0) the partial sum of this step is zero   
      SAR AX, 1  
      JNC nosum
    ;else the partial sum is BX shifted left by actual position of AX bit (saved in DI)
      MOV CX, SI
      PUSH BX
      SAL BX, CL ;shift only using immediate or CL!
      ADD DX, BX ;update result
      POP BX
    nosum:
    INC SI
    CMP SI, 16;check end
    JNE nextbit
  ;end while (nextbit)
  JMP exit_multiply_signed 

;BX=1 -> DX=AX
skip_multiply_signed_B:
MOV DX, AX
JMP exit_multiply_signed

;AX=1 -> DX=BX
skip_multiply_signed_A:
MOV DX, BX

exit_multiply_signed:
RET
multiply_signed ENDP

END