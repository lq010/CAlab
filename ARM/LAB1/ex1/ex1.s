	AREA MYCODE, CODE, READONLY

ENTRY

; initialization of registers r0-r7 (hexadecimal values)

	MOV r0, #1 
	MOV r1, #2
	MOV r2, #3
	MOV r3, #3
	MOV r4, #5
	MOV r5, #6
	MOV r6, #7
	MOV r7, #8

;compute means if different, product if equal

	CMP R0, R1
	ADDNE R8, R0, R1
	LSRNE R8, #1
	MULEQ R8, R0, R1
	
	CMP R2, R3
	ADDNE R9, R2, R3
	LSRNE R9, #1
	MULEQ R9, R2, R3
	
	CMP R4, R5
	ADDNE R10, R4, R5
	LSRNE R10, #1
	MULEQ R10, R4, R5
	
	CMP R6, R7
	ADDNE R11, R6, R7
	LSRNE R11, #1
	MULEQ R11, R6, R7

	END