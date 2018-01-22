.MODEL small
.STACK
.DATA
FIRSTROLL DB 10 DUP(?)
SECROLL DB 10 DUP(?)
FRAMEPOINT DB 10 DUP(?)
SSCNT DB 10 DUP(?)
TOTALPOINT DB ?
.CODE
.STARTUP

;for(SI=0;SI<8;SI++)
  frame_loop:
  MOV AH,1
  INT 21h
  MOV FIRSTROLL,AL
  ADD FRAMEPOINT[SI],AL
  ;if(FIRSTROLL==8): strike
    CMP AL,8
    JNE no_strike
    MOV SSCNT[SI],2
  ;else: second roll
    no_strike:
    INT 21h
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
  ADD TOTALPOINT[SI],FRAMEPOINT[SI]
  CALL updatePoint
  INC SI
  CMP SI,8
  JB frame_loop
;end for (frame_loop)

END
;purpose: update the strike and spare point
;input: SI (frame number, passed via register)
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
  ADD FRAMEPOINT[SI-1],FRAMEPOINT[SI]
  ADD TOTALPOINT,FRAMEPOINT[SI]
  SUB SSCNT[SI-1],1 ;decrement update flag
;end if
;if(SI>2 && SSCNT[SI-1]!=0): check and update only second strike
  CMP SI,2
  JB end_update
  MOV AL,SSCNT[SI-2] ;two previous frame point need to be updated?
  CMP AL,0
  JE end_update
  ADD FRAMEPOINT[SI-2],FRAMEPOINT[SI]
  ADD TOTALPOINT,FRAMEPOINT[SI]
  SUB SSCNT[SI-2],1
;end if
end_update:
POP AX
RET
updatePoint ENDP

;purpose: print the score on screen
displayFrame PROC
displayFrame ENDP

.EXIT