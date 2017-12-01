.data

X: .byte 19

.code

daddui r1,r0,0 ;cycle counter
daddui r4,r0,0 ;init 1's counter
daddui r10,r0,7 ;cycle limit
daddui r11,r11,1 ;value 1 register

daddui r5,r0,0 ;reset parity register
lb r2,X(r1)
parity_loop:
	dsll r2,r2,1
	daddu r3,r0,r2 ;save into r3 for not modify shifted value after applying the mask
	andi r3,r3,256 ;mask to select only shifted bit (9th bit)
	daddu r4,r4,r3 ;add using 15downto8 bits, at the end shift to obtain correct decimal value
	bne r1,r10,parity_loop
;check parity with r4
;if even (LSB=0) parity = 0
dsrlv r4,8 ;shift counter to bit 8downto0
andi r4,r4,1 ;check LSB if 1 or 0
movn r5,r11,r4 ;if odd (r4 LSB=1) then parity = 1 (r5=1)
;save parity bit into X MSB
ori r2,r2,128
sb r2,X(r1)

HALT
