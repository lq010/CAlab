; Computer Architectures (02LSEOV)
; Lab n.1
; Simone Iammarino 15/11/2017

.MODEL small 

.STACK

.DATA 
A DW -24
B DW -30
RES DW 1 DUP(?)
.CODE 
.STARTUP

;Product between two 16bit value
;pen-and-paper multiplication methods of binary number

MOV AX, A
MOV BX, B

;for(SI=0, SI<AX, SI++)
multiply_signed: ;DX = AX x BX (uses CX, SI)
XOR DX, DX
XOR CX, CX
XOR SI, SI

;if AX=1 or BX=1 do nothing 
  CMP BX, 1 
  JE skip_multiply_signed_B
  CMP AX, 1 
  JE skip_multiply_signed_A
;else:
  ;while(SI < 16)
    nextbit: 
    ;if shifted out AX bit is zero (CF=0) the partial sum of this step is zero   
      SAR AX, 1  
      JNC nosum
    ;else the partial sum is BX shifted left by actual position of AX bit (saved in DI)
      MOV CX, SI
      PUSH BX
      SAL BX, CL ;shift only using immediate or CL!
      ADD DX, BX ;update result
      POP BX
    nosum:
    INC SI
    CMP SI, 16;check end
    JNE nextbit
  ;end while (nextbit)
  JMP exit_multiply_signed  

;BX=1 -> DX=AX
skip_multiply_signed_B:
MOV DX, AX
JMP exit_multiply_signed

;AX=1 -> DX=BX
skip_multiply_signed_A:
MOV DX, BX

exit_multiply_signed:
  
MOV RES, DX
          
.EXIT
END