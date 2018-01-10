
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
s.d f4,8(r1)    ;   FsDEsMW 6 (2 cycle delay after add.d execute stage)
bne,r1,r2,loop  ;    FsD--- 0
;l.d f0,0(r1)   ;     sFDsEMW 2 (the second loop take 7 clock cycle to execute
 
;total cycles: 6*1 + 7*999 = 6999

; 3) LOOP UNROLLING: only 3 instruction out of 5 are usefull for computation, the others are used for the loop
; because 1000 is multiple of 4 we can unroll the loop by 4, obtaining 1000/4 = 250 iterations
loop:
l.d f0,0(r1)    ; FDEMW 1  
add.d f4,f0,f2  ;  FDssEMW 4  
s.d f4,0(r1)    ;   FssDEsMW 6
daddi r1,r1,-8  ;    ssFDsEMW 7
l.d f0,0(r1)    ;     ssFsDEMW 8 (stall for r1!)
add.d f4,f0,f2  ;      sssFDssEMW 11
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
;(>6999 of the compressed loop, because daddi instruction cannot be moved like the previous scheduling due to data dependencies that will occour w.r.t the subsequent s.d instruction)

;4) OFFSET PRE-CALCULATION: instead of increase each time r1, we can pre calculate the offsets in this way:
loop:
l.d f0,0(r1)    ; FDEMW 1
add.d f4,f0,f2  ;  FDssEMW 4
s.d f4,0(r1)    ;   FssDEsMW 6
l.d f0,-8(r1)   ;    ssFDsEMW 7 
add.d f4,f0,f2  ;     ssFsDssEMW 10
s.d f4,-8(r1)   ;      sssFssDEsMW 12
l.d f0,-16(r1)  ;       sssssFDsEMW 13
add.d f4,f0,f2  ;        sssssFsDssEMW 16
s.d f4,-16(r1)  ;         ssssssFssDEsMW 18
l.d f0,-24(r1)  ;          ssssssssFDsEMW 19
add.d f4,f0,f2  ;           ssssssssFsDssEMW 21
s.d f4,-24(r1)  ;            sssssssssFssDEsMW 23
daddi r1,r1,-32 ;             sssssssssssFDsEMW 24
bne,r1,r2,loop  ;              sssssssssssFssD--- 26
;l.d f0,0(r1)   ;               sssssssssssssFDEMW (OK, the same as previous loop)

;total cycles: 26*250 = 6500 (500 cycle less than non optimized scheduling)

;5) REGISTER RENAMING: recheduling doing all together the l.d at the beginning and the s.d at the end relying on different registers, parallelizing the operations:
loop:
l.d f0,0(r1)    ; FDEMW 1
l.d f6,-8(r1)   ;  FDEMW 2
l.d f10,-16(r1) ;   FDEMW 3
l.d f14,-24(r1) ;    FDEMW 4
add.d f4,f0,f2  ;     FDEMW 5
add.d f8,f6,f2  ;      FDEMW 6
add.d f12,f10,f2;       FDEMW 7
add.d f16,f14,f2;        FDEMW 8 
s.d f4,-0(r1)   ;         FDEMW 9
s.d f8,-8(r1)   ;          FDEMW 10
daddi r1,r1,-32 ;           FDEMW 11
s.d f12,-16(r1) ;            FDEMW 12
s.d f16,-24(r1) ;             FDEMW 13
bne,r1,r2,loop  ;              FD--- 14
;l.d f0,0(r1)   ;

;total cycles: 14*250 = 3500 (best performance, technique limited by the maximum number of registers)
