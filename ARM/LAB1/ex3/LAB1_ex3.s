size_32 EQU 0x00000004	

	AREA MYDATA, NOINIT, READWRITE, ALIGN=3
mean SPACE size_32
max_differ SPACE size_32
max_value SPACE size_32
min_value SPACE size_32
	
	AREA MYCODE, CODE, READONLY
	ENTRY
	MOV R0,#0 ;(otherwise give the error "Entry point does not point to an instruction")	
;sequence DCD 8,7,6,5,50,4,-1,-5 ;no monotonic
sequence DCD -3,-2,-1,2,3,5,10,15 ;increasing
;sequence DCD 8,7,6,5,5,4,-1,-5 ;decreasing
	
	;check increasing
	MOV R1,#0x80000000 ;lowest possible value at start (signed)
	LDR R0,=sequence ;pointer to sequence
increasing_loop
	LDR R2,[R0],#4 ;load value (post-addressing mode)
	CMP R2,R1
	BLT decreasing ;exit directly if found R2 < R1
	MOVNE R1,R2 ;update previous value (if not equal)
	ADD R4,R4,#1
	CMP R4,#8
	BNE increasing_loop
   
	;compute mean value
sum_loop
	LDR R2,[R0,#-4]! ;reload the vector starting from the end
	ADD R3,R3,R2 ;R3 contains the sum of all the values
	SUB R4,R4,#1
	CMP R4,#0
	BNE sum_loop		
	LSR R3,R3,#3 ;dividing R3 by 8 by shifting
	LDR R0,=mean
	STR R3,[R0]
	B end_programm

	;check decreasing
decreasing
	MOV R4,#0
	MOV R1,#0x7fffffff ;highest possible value at start (signed)
	LDR R0,=sequence ;pointer to sequence
decreasing_loop
	LDR R2,[R0],#4 ;load value (post-addressing mode)
	CMP R2,R1
	BGT monotonic ;exit directly if found R2 > R1
	MOVNE R1,R2 ;update previous value (if not equal)
	ADD R4,R4,#1
	CMP R4,#8
	BNE decreasing_loop

	;larger absolute difference between two consecutive numbers
	LDR R0,=sequence
	MOV R1,#0
	MOV R2,#0
	MOV R4,#0 ;max absolute difference temp register
lad_loop
  LDR R1,[R0],#4
  LDR R2,[R0]
  SUB R1,R2,R1
  ;invert if negative (absolute value) using Bit Clear
  CMP R1,#0
  BICLT R1,R5,R1 ;R5=0
  ADD R1,R1,#1
  CMP R1,R4
  MOVGT R4,R1
  ADD R6,R6,#1
  CMP R6,#7 ;one less than array lenght in this case (otherwise go after array the last element)
  BNE lad_loop

  LDR R0,=max_differ
  STR R4,[R0]
  B end_programm

	;monotonic sequence, find min and max value
monotonic
  LDR R0,=sequence
  MOV R1,#0 ;temp register
  MOV R2,#0 ;temp for maximum
  MOV R3,#0 ;temp for minimum
  MOV R4,#0 ;counter register
min_max_loop
  LDR R1,[R0],#4
  CMP R1,R2
  MOVGT R2,R1 ;update max
  CMP R1,R3
  MOVLT R3,R1 ;update min
  ADD R4,R4,#1
  CMP R4,#8
  BNE min_max_loop
 
  ;store result in memory
  LDR R0,=max_value
  STR R2,[R0]
  LDR R0,=min_value
  STR R3,[R0]

end_programm
	 
  END