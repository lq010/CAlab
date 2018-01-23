.MODEL small
.STACK

.DATA

FIRSTROLL  DB 8 DUP(?)
SECROLL    DB 8 DUP(?)
BONUSROLL  DB ?
FRAMEPOINT DB 8 DUP(?)
SSCNT      DB 8 DUP(?)
TOTALPOINT DB ?

.CODE
.STARTUP

;for(SI=0;SI<8;SI++)
  frame_loop:
  MOV AH,1
  INT 21h
  SUB AL,48
  MOV FIRSTROLL[SI],AL
  ADD FRAMEPOINT[SI],AL
  ;if(FIRSTROLL==8): strike
    CMP AL,8
    JNE no_strike
    MOV SSCNT[SI],2
    JMP no_spare
  ;else: second roll
    no_strike:
    INT 21h
    SUB AL,48
    MOV SECROLL[SI],AL
    ADD FRAMEPOINT[SI],AL
    ;if(FRAMEPOINT==8): spare
        MOV AL,FRAMEPOINT[SI]
        CMP AL,8
        JNE no_spare
        MOV SSCNT[SI],1
    ;end if
    no_spare:
  ;end if
  MOV BL,FRAMEPOINT[SI]
  ADD TOTALPOINT,BL
  CALL updatePoint
  INC SI
  CMP SI,7
  JB frame_loop
;end for (frame_loop)

;ask for last frame (outside the loop for simplicity)
;first roll
INT 21h
SUB AL,48
MOV FIRSTROLL[SI],AL
ADD FRAMEPOINT[SI],AL
;second roll
INT 21h
SUB AL,48
MOV SECROLL[SI],AL
ADD FRAMEPOINT[SI],AL

;bonus roll
MOV AL,FIRSTROLL[SI]
;if(FIRSTROLL==8): strike
  CMP AL,8
  JNE no_bonus
  INT 21h 
  SUB AL,48
  MOV BONUSROLL,AL
  XOR BX,BX
  ADD BL,AL ;bonus roll point to the frame
  ADD BL,AL ;add second roll points for strike
  ADD BL,AL ;add bonus roll point for strike
  ADD FRAMEPOINT[SI],BL ;update total frame point
;end if
no_bonus:



.EXIT

;purpose: update the strike and spare point
;input: SI (frame number, passed via register), BL (framepoint[SI])
;output: nothing
updatePoint PROC
PUSH AX
XOR AX,AX
;if(SI>1 && SSCNT[SI-1]!=0): check and update first strike or spare
  CMP SI,1
  JB end_update
  MOV AL,SSCNT[SI-1] ;previous frame point need to be updated?
  CMP AL,0
  JE end_update
  ADD FRAMEPOINT[SI-1],BL
  ADD TOTALPOINT,BL
  SUB SSCNT[SI-1],1 ;decrement update flag
;end if
;if(SI>2 && SSCNT[SI-1]!=0): check and update only second strike
  CMP SI,2
  JB end_update
  MOV AL,SSCNT[SI-2] ;two previous frame point need to be updated?
  CMP AL,0
  JE end_update
  ADD FRAMEPOINT[SI-2],BL
  ADD TOTALPOINT,BL
  SUB SSCNT[SI-2],1
;end if
end_update:
POP AX
RET
updatePoint ENDP

;purpose: print the score on screen
;displayFrame PROC
;displayFrame ENDP

END
