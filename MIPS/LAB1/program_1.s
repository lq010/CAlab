; Computer Architectures (02LSEOV)
; MIPS - Lab n.1
; Simone Iammarino 16/11/2017

.data

numbers: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ; .word = 64bit word
max: .word 0

.text
;store first element into max value
ld R1,numbers(R0)
sd R1,max(R0)
 
daddi R1,R0,#0 ;init R1=0
next_number:
ld R2,numbers(R1)
;slt R4,R2,R3
daddi R1,R0,#8 ;next number
j next_number

halt
	