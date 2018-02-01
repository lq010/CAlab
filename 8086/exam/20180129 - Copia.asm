.MODEL small
.STACK

.DATA
;OBJ_PRICES DW 50 DUP(?)
N DB 4
OBJ_PRICES DW 3500,745,21,4 ;decreasing ordered
N_BUY DB ? ;#products bought
ITEMS DW 2 DUP(?) ;ID number of products

;text strings
ASK_ITEM_1 DB "Insert item1 ID number: $"
ASK_ITEM_2 DB "Insert item2 ID number: $"
ASK_NUMBER DB "Insert number of items: $"
STR_DISC DB " save: $"
STR_PRICE DB "Total price: $"
STR_ITA DB "ItemA: $"
STR_ITB DB "ItemB: $"
OUTSTR DB 6 DUP(?) ;integer to ascii string (max 5 characters x 16bit integer number +1 for sign)

.CODE
.STARTUP

;input: number of items (1 to 2)
ask_item_number:
LEA DX,ASK_NUMBER
MOV AH,09h
INT 21h
MOV AH,1
INT 21h
SUB AL,48 ;ascii to integer
MOV N_BUY,AL
MOV AH,2
MOV DL,0Ah ;new line
INT 21h
MOV DL,0Dh ;carriage return
INT 21h
MOV AL,N_BUY
CMP AL,2
JA ask_item_number
CMP AL,0
JE ask_item_number

;input: product 1
XOR AX,AX
XOR BX,BX
XOR CX,CX

prod1_input:
;print string
LEA DX,ASK_ITEM_1
MOV AH,09h
INT 21h
;ask first char
MOV AH,1
INT 21h
SUB AL,48
MOV DL,AL
;ask second char
INT 21h
CMP AL,13 ;if CR
JE prod1_end
SUB AL,48
MOV CL,AL
MOV AL,DL
MOV BL,10
MUL BL
ADD AX,CX
MOV DL,AL 
prod1_end:
MOV byte ptr ITEMS[0],DL ;save prod1
MOV AH,2
MOV DL,0Ah 
INT 21h
MOV DL,0Dh
INT 21h
;check in range
MOV AL,byte ptr ITEMS[0]
MOV BL,N ;(max index N-1)
CMP AL,BL
JAE prod1_input 


;-----------------------------
;only one product: no discount
;-----------------------------

MOV AL,N_BUY
CMP AL,2
JAE more_than_one

MOV DI,ITEMS[0]
ADD DI,DI
MOV CX,OBJ_PRICES[DI]

;print price
MOV DX,CX
XOR CX,CX
CALL printPrice
JMP end_programm

;------------------------------------
;more than one (= two) products case:
;------------------------------------

more_than_one:

;input: product 2
prod2_input:
LEA DX,ASK_ITEM_2
MOV AH,09h
INT 21h
;ask first char
MOV AH,1
INT 21h
SUB AL,48
MOV DL,AL
;ask second char
INT 21h
CMP AL,13 ;if CR
JE prod2_end
SUB AL,48
MOV CL,AL
MOV AL,DL
MOV BL,10
MUL BL
ADD AX,CX
MOV DL,AL 
prod2_end:
MOV byte ptr ITEMS[2],DL ;save prod1
MOV AH,2
MOV DL,0Ah 
INT 21h
MOV DL,0Dh
INT 21h
;check in range
MOV AL,byte ptr ITEMS[2]
MOV BL,N ;(max index N-1)
CMP AL,BL
JAE prod2_input 

;order the two product by ID (descending)
MOV AL,byte ptr ITEMS[0]
MOV AH,byte ptr ITEMS[2]
CMP AL,AH
JAE no_order
MOV byte ptr ITEMS[0],AH
MOV byte ptr ITEMS[2],AL
no_order:

;CX = discount
;DX = total cost with discount

;---------------
;     itemA
;---------------

XOR DI,DI
XOR CX,CX

MOV DI,ITEMS[0]
ADD DI,DI
ADD CX,OBJ_PRICES[DI] ;load less expensive
MOV DX,CX
SHR DX,1 ;50% discount

MOV DI,ITEMS[2]
ADD DI,DI
ADD CX,OBJ_PRICES[DI] ;update total without discount
ADD DX,OBJ_PRICES[DI] ;no discount for more expensive

SUB CX,DX ;total discount = full price - discount price

;print price
PUSH DX
MOV AH,09h
LEA DX,STR_ITA
INT 21h
POP DX
CALL printPrice 

;---------------
;     itemB
;---------------

XOR CX,CX
XOR DX,DX

MOV DI,ITEMS[0]
ADD DI,DI
ADD CX,OBJ_PRICES[DI]
;DX=0 because less expensive is free in this case

MOV DI,ITEMS[2]
ADD DI,DI
ADD CX,OBJ_PRICES[DI]
ADD DX,OBJ_PRICES[DI]
SHR DX,2 ;25% of the price
ADD DX,OBJ_PRICES[DI] ;125% more expensive

SUB CX,DX ;can go negative!

;print price
PUSH DX
MOV AH,09h
LEA DX,STR_ITB
INT 21h
POP DX
CALL printPrice

end_programm:

.EXIT

;putpose: ask for item product ID and checks correctness
;input: AX = max value , BX = pointer to store variable 
;       DX = pointer to string to print
;output: N/A (store into global variable the input pointed by BX)
askItem PROC
PUSH AX
PUSH BX
PUSH CX
PUSH DX

prod_input:
PUSH AX ;max value
;print string
MOV AH,09h
INT 21h
;ask first char
PUSH DX ;save string pointer
XOR DX,DX
MOV AH,1
INT 21h
SUB AL,48
MOV DL,AL
;ask second char
INT 21h
CMP AL,13 ;if CR
JE prod_end
SUB AL,48
MOV CL,AL
MOV AL,DL
MOV BL,10
MUL BL
ADD AX,CX
MOV DX,AX 
prod_end:
MOV BX[0],DX ;save prod1
MOV AH,2
MOV DL,0Ah 
INT 21h
MOV DL,0Dh
INT 21h
POP DX ;retrieve string pointer
;check in range
MOV CX,BX[0]
POP AX ;max value in CX 
CMP CX,AX
JAE prod_input

POP DX
POP CX
POP BX
POP AX
RET      
askItem ENDP


;purpose: print the price and total discount   
;parameters passed by register
;input: DX = total price, CX = discount
;output: N/A
printPrice PROC
PUSH AX
PUSH BX
PUSH CX
PUSH DX
PUSH SI

;"total price" string
PUSH DX
MOV AH,09h
LEA DX,STR_PRICE
INT 21h
POP DX

;convert and print total price
MOV AX,DX
CALL toAscii

MOV SI,6
MOV AH,2
print_loop2:
MOV DL,OUTSTR[SI-1]
INT 21h
DEC SI
CMP SI,0
JA print_loop2

;reset OUTSTR
MOV SI,6
res_loop:
MOV OUTSTR[SI-1],0
DEC SI
CMP SI,0
JA res_loop

;"save" string
MOV AH,09h
LEA DX,STR_DISC
INT 21h

;convert and print discount price
MOV AX,CX
CALL toAscii

MOV SI,6
MOV AH,2
print_loop_2:
MOV DL,OUTSTR[SI-1]
INT 21h
DEC SI
CMP SI,0
JA print_loop_2

;reset OUTSTR
MOV SI,6
res_loop2:
MOV OUTSTR[SI-1],0
DEC SI
CMP SI,0
JA res_loop2

MOV DL,0Ah 
INT 21h
MOV DL,0Dh
INT 21h

POP SI
POP DX
POP CX
POP BX
POP AX
RET         
printPrice ENDP

;purpose: trasform integer number into ascii string
;input: AX = integer number 16 bit
;output: OUTSTR = ascii string of the number
toAscii PROC
PUSH AX
PUSH BX
PUSH CX
PUSH DX
PUSH SI    

XOR DX,DX
MOV BX,10

;if AX negative: 2's complement and insert minus sign
CMP AX,0
JGE division_loop
NEG AX
MOV OUTSTR[5],02Dh ;minus character 

division_loop:
DIV BX
ADD DX,48 ;convert remainder to ascii 
MOV OUTSTR[SI],DL
XOR DX,DX
INC SI
CMP AX,0
JA division_loop

POP SI    
POP DX
POP CX
POP BX
POP AX
RET   
toAscii ENDP

END