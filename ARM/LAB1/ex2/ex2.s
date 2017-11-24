	AREA MYCODE, CODE, READONLY

ENTRY

	MOV r0, #3 
	MOV r1, #2
	MOV r2, #1

	CMP r0, r1 ;if R0 > R1 -> swap registers (use r3 as temporary register)
	MOVHI R3, R0
	MOVHI R0, R1
	MOVHI R1, R3
	
	CMP r0, r2 
	MOVHI R3, R0 
	MOVHI R0, R2
	MOVHI R2, R3
	
	CMP r1, r2
	MOVHI R3, R1 
	MOVHI R1, R2
	MOVHI R2, R3

	MOV r3, r0
	MOV r7,#0
	MOV r6,#0
loop1
	ADD r4,r0,r3
    MOV r0,r4	
	CMP r4,r1 ;compare with second bigger element
	ADD r6,r7,#1 ;increment counter
	BLO loop1 
	MOVNE r4,#0
		
	MOV r7,#0 ;reset counter
	MOV r6,#0
loop2
	ADD r5,r0,r3
	MOV r0,r5
	CMP r5,r2 ;compare with first bigger element
	ADD r6,r7,#1 ;increment counter
	BLO loop2
	MOVNE r5,#0























;reset_handler
	;MOV R0, #200
	;;MOV R1, #1001 ; IT GIVES AN ERROR
	;LDR R1, =1001
	;; R2 = [R0 - R1]

	;CMP R0, R1
	;BLO islower
	;sub r2,r0,r1
	;B next
	
;islower
	;sub r2,r1,r0
	
;next
	;B reset_handler
	
	
	END