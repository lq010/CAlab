; Computer Architectures (02LSEOV)
; MIPS - Lab n.1
; Simone Iammarino 29/11/2017

.data

vector: .word 1, 2, 3, 4, 5, 4, 3, 2, 1, 10 ;.word = 64bit word
result: .word 0

.text

;r0 is always 0
;at start max value is first element
ld r3,vector(r0)

daddui r5,r0,80 ;init cycle counter
;while(r1<80):
scan_for_max:
  ld r2,vector(r1)
  ;if r2>r3: update with r2
  slt r4,r2,r3 ;if r2<r3: r4=1 else r4=0
  movz r3,r2,r4 ;move r2 -> r3 if r4=0
  daddui r1,r1,8 ;next vector element (.word data saved as 8x8bit = 64bit)
bne r1,r5,scan_for_max
;end while(scan_for_max)

sd r3,result(r0)
halt
	