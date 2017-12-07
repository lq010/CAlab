.data
;input vectors
V1: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V2: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V3: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V4: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
;output vector
V5: .space 80 ;10 double precision float (64bit) = 10*8byte = 80 entry  
.code

daddui r10,r0,80 ;loop counter limit

;for(r1=0,r1<10,r1++): V5[r1] = (V1[r1]/V2[r1] + V4[r1]/V3[r1] + V4[r1]);
loop:
	;this code has NO optimization
	l.d f1,V1(r1)
	l.d f2,V2(r1)
	l.d f3,V3(r1)
	l.d f4,V4(r1)

	div.d f5,f1,f2
	div.d f6,f4,f3
	add.d f7,f5,f6
	add.d f7,f7,f4

	s.d f7,V5(r1)
	
	daddui r1,r1,8
bne r1,r10,loop
;end for (loop)
nop ;otherwise branch delay slot load HALT
HALT