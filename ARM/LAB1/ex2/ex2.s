	AREA MYCODE, CODE, READONLY

	ENTRY

	MOV r0, #15 
	MOV r1, #5
	MOV r2, #21

	;swap registers if the first is higher than the second (R3 temporary register)
	CMP r0, r1 
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

	;checking if R1 and R2 are multiple of R0 (multiple subtractions)

loop1
	SUB R1,R1,R0
	CMP R1,#0 
	ADDGE R4,R4,#1 ;Signed Greater or Equal because if the result is negative it will be interpreted as positive in unsigned notation
	BGT loop1
	MOVNE R4,#0 ;if result of division not zero, dont save
		
loop2
	SUB R2,R2,R0
	CMP R2,#0 
	ADDGE R5,R5,#1
	BGT loop2
	MOVNE R5,#0
	
	END