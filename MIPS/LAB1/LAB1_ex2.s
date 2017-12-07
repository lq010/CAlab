.data

V1: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V2: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V3: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V4: .double 1.5,2.5,3.5,4.5,5.5,6.5,7.5,8.5,9.5,10.5
V5: .space 80
V6: .space 80
V7: .space 80

.code
	
daddu r8, r0, r0  ;counter
daddui r9, r0, 80 ;condition to exit the loop

loop:
		l.d f1, V1(r8)
		l.d f2, V2(r8)
		l.d f3, V3(r8)
		l.d f4, V4(r8)
		mul.d f5, f1, f2
		div.d f6, f2, f3
		add.d f7, f1, f4
		s.d f5, V5(r8)
		s.d f6, V6(r8)
		s.d f7, V7(r8)
		daddui r8, r8, 8
		bne r8, r9, loop	
HALT

