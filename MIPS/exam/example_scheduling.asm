
;pseudocode:
;for (i=1000; i>0; i=i-1) 
;  x[i] = x[i] + s;

;architecture:
;add.d to add.d : 3 cycle delay
;l.d to add.d : 1 cycle delay 
;add.d to s.d : 2 cycle delay

; 1) no optimization
loop:
l.d f0,0(r1)    ;FDEMW 1   
add.d f4,f0,f2  ; FDssEMW 4 (load to FP: 1 cycle delay after load mem stage)
s.d f4,0(r1)    ;  FssDEsMW 6 (FP to store: 2 cycle delay after add.d execution stage) (execute stage calculate the address, then wait for f4 ready after 2 cycle its execution)
daddi r1,r1,-8  ;   ssFDsEMW 7
bne,r1,r2,loop  ;    ssFssD--- 9 (occupies 1 more clock waiting for r1)

;total cycle: 9*1000 = 9000

; 2) rescheduling inserting during stall instructino with no data dependencies
; in this case the "daddi" is the only instruction that does not have data dependency
; warning! notice that the s.d instruction need to be modified to move the daddi instruction
loop:
l.d f0,0(r1)    ;FDEMW 1  
daddi r1,r1,-8  ; FDEMW 2
add.d f4,f0,f2  ;  FDsEMW 4 (1 cycle delay after l.d memory)
s.d f4,8(r1)    ;   FDEssMW 6 (2 cycle delay after add.d execute)
bne,r1,r2,loop  ;    FD--- 
