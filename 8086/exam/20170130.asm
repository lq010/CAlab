.MODEL small
.STACK

.DATA
CITATIONS DW 0x000A,0011000001000001b,0011000010000010b,0011000001000010b,0011000010000011b,0011000010000011b,0011000011000100b,0011000101000101b,0011000100000110b,0011000011000101b,0011000001001000b
MAX_TABLE DB 50 DUP(?)
T DW ?
H_SCORE DB ?

.CODE
.STARTUP

;compute table of max(WoS,Sco)
MOV CX,CITATIONS[0]
MOV T,CX
ADD CX,CX ;#paper multiplied by 2 because CITATIONS is a vector of words
ADD SI,2
;for(SI=2;SI<CX;SI+2)
  max_loop:
  MOV AX,CITATIONS[SI]
  MOV BX,AX
  AND AX,3Fh ;select 6bit Sco field
  SHR BX,6
  AND BX,3Fh ;select 6bit WoS field
  ;if(WoS>=Sco): max = WoS (BL)
    CMP BL,AL
    JB is_sco
    MOV MAX_TABLE[DI],BL
    JMP no_sco
  ;else: max = Soc (AL)
    is_sco:
    MOV MAX_TABLE[DI],AL
  ;end if
  no_sco:
  INC DI
  ADD SI,2
  CMP SI,CX
  JBE max_loop
;end for (max_loop)

;compute h_score
XOR AX,AX
XOR BX,BX
XOR CX,CX
XOR SI,SI
XOR DI,DI

;for(DI=0;DI<T;DI++)
  paper_loop:
  ;for(SI=0;SI<T||BX=DI;SI++)
    scan_loop:
    MOV AL,MAX_TABLE[SI]
    ;if(citations(AL)>current_h(DI)): update #counted_paper(BX)
      CMP AX,DI
      JB next_loop
      ADD BX,1
      ;if(#counted_paper(BX) >= current_h(DI)): save current_h and skip to check next h_score
        CMP BX,DI
        JB next_loop
        MOV CX,DI ;update h_score
        JMP skip_loop
      ;end if
    ;end if  
    next_loop:
    INC SI
    CMP SI,T
    JB scan_loop
  ;end for (scan loop)
  skip_loop:
  XOR BX,BX ;reset #counted_paper per h_score
  XOR SI,SI ;reset cycle counter
  INC DI    ;test next h_score
  CMP DI,T
  JBE paper_loop
;end for (paper loop)

.EXIT
END

;citation values for simulation
;0011 000001 000001 (2014 1 1)
;0011 000010 000010 (2014 2 2) 
;0011 000001 000010 (2014 1 2)
;0011 000010 000011 (2014 2 3)
;0011 000010 000011 (2014 2 3)
;0011 000011 000100 (2014 3 4)
;0011 000101 000101 (2014 5 5)
;0011 000100 000110 (2014 4 6)
;0011 000011 000101 (2014 3 5)
;0011 000001 001000 (2014 1 8)
