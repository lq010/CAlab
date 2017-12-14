.data

V1: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V2: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V3: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V4: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V5: .space 80
V6: .space 80
V7: .space 80

.code

;NO OPTIMIZED code
;used for clock cycle calulation 
;FP multiplier (X) : 8  (pipelined)
;FP division   (d) : 12 (not pipelined)
;FP arithmetic (A) : 4  (pipelined)
;forwarding enabled
;branch 
daddu r8, r0, r0      ;FDEMW 5   
daddui r9, r0, 80     ; FDEMW 6
loop:		
		l.d f1, V1(r8)    ;  FDEMW 7
		l.d f2, V2(r8)    ;   FDEMW 8 
		l.d f3, V3(r8)    ;    FDEMW 9
		l.d f4, V4(r8)    ;     FDEMW 10
		mul.d f5, f1, f2  ;      FDXXXXXXXXMW 18  
		div.d f6, f2, f3  ;       FDddddddddddddMW 23 
		add.d f7, f1, f4  ;        FDAAAAMW 0
		s.d f5, V5(r8)    ;         FDEsssssMW 0 (compute address in E then wait f5 (data hzd))
		s.d f6, V6(r8)    ;          FDsssssEssssMW 24 (E structural hzs, wait f6 data hzd, wait M (structural hzd))
		s.d f7, V7(r8)    ;           FsssssDssssEMW 25 (structural hzd in M stage with previous add.d)
		daddui r8, r8, 8  ;                 FssssDEMW 26 (various structural hzd)
		bne r8, r9, loop	;                      FDEMW 27      
HALT                  ; loop total clock cycle: (27-7)*10=200
                      ; total clock cycle: 170+6 = 206
                      ; #instructions: 2+(12*10)=122
                      ; CPI(Cycle per Instruction): 206/122 = 1.6885
                      
;NOTE: to more accurate evaluation, we need to take into account that
;      in the first cycle, the first instructions can be executed
;      with a different schedule w.r.t to the next time after the branch! 
;      (depends on the dependences between the last and first instruction of the cycle)   