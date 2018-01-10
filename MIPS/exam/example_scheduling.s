
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

;total cycles: 9*1000 = 9000

; 2) RESCHEDULING inserting during stall instructino with no data dependencies
; in this case the "daddi" is the only instruction that does not have data dependency
; warning! notice that the s.d instruction need to be modified to move the daddi instruction
loop:
l.d f0,0(r1)    ;FDEMW 1  
daddi r1,r1,-8  ; FDEMW 2
add.d f4,f0,f2  ;  FDsEMW 4 (1 cycle delay after l.d memory stage)
s.d f4,8(r1)    ;   FDEssMW 6 (2 cycle delay after add.d execute stage)
bne,r1,r2,loop  ;    FD--- 0
;l.d f0,0(r1)   ;     FDsEMW 1 (no more delay next loop cycles) 
 
;total cycles: 6*1000 = 6000

; 3) LOOP UNROLLING: only 3 instruction out of 5 are usefull for computation, the others are used for the loop
; because 1000 is multiple of 4 we can unroll the loop by 4, obtaining 1000/4 = 250 iterations
loop:
l.d f0,0(r1)    ; FDEMW 1  
add.d f4,f0,f2  ;  FDssEMW 4  
s.d f4,0(r1)    ;   FssDEsMW 6
daddi r1,r1,-8  ;    ssFDsEMW 7
l.d f0,0(r1)    ;     ssFsDEMW 8 (stall for r1!)
add.d f4,f0,f2  ;      ssFsDssEMW 11
s.d f4,0(r1)    ;       sssFssDEsMW 13
daddi r1,r1,-8  ;        sssssFDsEMW 14
l.d f0,0(r1)    ;         sssssFsDEMW 15
add.d f4,f0,f2  ;          ssssssFDssEMW 18
s.d f4,0(r1)    ;           ssssssFssDEsMW 20
daddi r1,r1,-8  ;            ssssssssFDsEMW 21
l.d f0,0(r1)    ;             ssssssssFsDEMW 22
add.d f4,f0,f2  ;              sssssssssFDssEMW 25
s.d f4,0(r1)    ;               sssssssssFssDEsMW 27
daddi r1,r1,-8  ;                sssssssssssFDsEMW 28
bne,r1,r2,loop  ;                 sssssssssssFssD--- 30 (cause a delay of 2 clock cycles before loading first instruction of the next loop)
;l.d f0,0(r1)   ;                  sssssssssssssFDEMW (OK, no hazards or dependencies with previous loop, the loop start in the same way)

;total cycles: 30*250 = 7500  
;(>6000 of the compressed loop, because daddi produces data dependencies and cannot be moved like the previous scheduling due to data dependencies that will occour with the subsequent s.d instruction)

;4) OFFSET PRE-CALCULATION: instead of increase each time r1, we can pre calculate the offsets in this way:
loop:
l.d f0,0(r1)    ; FDEMW 1
add.d f4,f0,f2  ;  FDssEMW 4
s.d f4,0(r1)    ;   FssDEsMW 6
l.d f0,-8(r1)   ;    ssFDsEMW 7 
add.d f4,f0,f2  ;     ssFsDssEMW 10
s.d f4,-8(r1)   ;      sssFssDEsMW 12
l.d f0,-16(r1)  ;       sssssFDsEMW 13
add.d f4,f0,f2  ;        sssssFsD
s.d f4,-16(r1)  ;
l.d f0,-24(r1)  ;
add.d f4,f0,f2  ;
s.d f4,-24(r1)  ;
daddi r1,r1,-32 ;
bne,r1,r2,loop  ;
;l.d f0,0(r1)   ;