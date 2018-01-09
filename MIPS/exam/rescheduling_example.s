;example: how reduce assembly code execution clock cycles 

;pseudocode 
;for (i=1000; i>0; i=i-1) 
; x[i] = x[i] + s;

;assembly
.data

V1: .double ;1000 float element

.text

DADDI R2,R0,0
DADDI R1,R0,8000 ;1000*8byte
ADD.D F2,F0,5 ; "s" constant

Loop: 
L.D F0,0(R1)    ;
ADD.D F4,F0,F2 
S.D F4,0(R1) 
DADDI R1,R1,-8 
BNE R1,R2,Loop

HALT