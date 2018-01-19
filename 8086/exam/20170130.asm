.MODEL small
.STACK

.DATA
CITATIONS DW 51 DUP(?)
MAX_TABLE DB 50 DUP(?)
T DB (?)

.CODE
.STARTUP
MOV DI,CITATIONS[0]
ADD SI,1
;for(SI=1;SI<T;SI++)
  max_loop:
  MOV AX,CITATIONS[SI]
  MOV BX,AX
  AND AX,3Fh ;select 6bit Sco field
  SHR BX,6
  AND BX,3Fh ;select 6bit WoS field
  ;if(WoS>=Sco): max = WoS (BL)
    CMP BL,AL
    JB is_sco
    MOV MAX_TABLE[SI],BL
    JMP no_sco
  ;else: max = Soc (AL)
    is_sco:
    MOV MAX_TABLE[SI],AL
  ;end if
  no_sco:
  INC SI
  CMP SI,DI
  JB max_loop
;end for (max_loop)

.EXIT
END
