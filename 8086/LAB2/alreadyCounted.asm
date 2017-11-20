; Computer Architectures (02LSEOV)
; Lab n.2
; Simone Iammarino 17/11/2017

.MODEL small
.STACK

.DATA
CHKCHR DB 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0
TEST1 DB 0
TEST2 DB 0
.CODE
.STARTUP

; TEST procedure "alreadyChk"

MOV AL,4
CALL alreadyCounted
MOV TEST1,AH ;should be 1
MOV AL,10
CALL alreadyCounted
MOV TEST2,AH ;should be 0

.EXIT

;checks if the character is already counted in that row
;character passed into AL
;result writed into: AH=1 -> counted, AH=0 -> not counted
alreadyCounted PROC
PUSH SI
XOR AH,AH
XOR SI,SI

;while CHKCHR > 0
check_loop:
  ;if present: AH=1
    CMP AL,CHKCHR[SI]
    JE set_high
  ;else: AH=0
    CMP CHKCHR[SI],0
    JE set_low
    INC SI
JMP check_loop
;end wile (check_loop)
  
set_high:
ADD AH,1
set_low:
POP SI
RET
alreadyCounted ENDP

END