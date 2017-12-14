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

	;checking if R1 and R2 are multiple of R0 by multiple addition
	MOV r6,#0 ;reset counter
loop1
	ADD r4,r4,r0	
	CMP r4,r1 
	ADDLS r6,r6,#1 ;increment counter (how many times R0 is in R1)
	BLO loop1 ;exit loop if R4 > R1 (not divisible)
	MOVEQ r4,r6 ;save the quotient if divisible
		
	MOV r6,#0
loop2
	ADD r5,r5,r0	
	CMP r5,r2 
	ADDLS r6,r6,#1 
	BLO loop2 
	MOVEQ r5,r6
	
	END