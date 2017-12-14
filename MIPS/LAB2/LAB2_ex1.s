.data

X: .byte 1,2,3,4,5,6,7,8,9,10 ;the even parity of each byte will be 1 and 0 alternatively
							  ;expected results: 128(1000 0000)+X[1] when #ones odd
							  ;				     X[i] when #ones even
							  ;(expressed in hexadecimal in winMips)
.code

daddui r10,r0,7	 ;"scan byte" cycle limit
daddui r11,r0,10 ;"scan X" cycle limit 

;while (r1<10) : scans X vector 
scan_x: 
	daddui r5,r0,0 ;reset "ones counter"
	daddui r4,r0,0 ;reset "scan byte" cycle counter 

	lb r2,X(r1)
  daddu r7,r0,r2    ;temp copy
  ;while(r1<7) : scans X[r1] byte and compute parity bit
	scan_byte:
		andi r3,r7,1 	  ;save LSB into r3
    dsrl r7,r7,1   
		daddu r5,r3,r0 	;update "ones counter"
		daddui r4,r4,1 	;update cycle counter
	bne r4,r10,scan_byte
	;end while(scan_byte)

	;EVEN PARITY: if #ones odd (LSB=1) -> parity_bit=1
	andi r5,r5,1 ;select LSB
	dsll r5,r5,7 ;move to MSB
	or r2,r5,r2  ;save parity bit into X[r1] MSB
	sb r2,X(r1)  ;store result

	daddui r1,r1,1
bne r1,r11,scan_x
;end while(scan_x)

HALT
