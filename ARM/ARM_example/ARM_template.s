; STACK Configuration

USR_Stack_Size  EQU     0x00000400

                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size 	; reserving a 
Stack_Top


; Heap Configuration

Heap_Size       EQU     0x00004000		 ; 16KB RAM

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
var
Heap_Mem        SPACE   Heap_Size
__heap_limit

				PRESERVE8

; Area Definition and Entry Point
;  Startup Code must be linked first at Address at which it expects to run.


                AREA    RESET, CODE, READONLY
                ARM


; Exception Vectors
;  Mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

Vectors         LDR     PC, Reset_Addr         
                LDR     PC, Undef_Addr
                LDR     PC, SWI_Addr
                LDR     PC, PAbt_Addr
                LDR     PC, DAbt_Addr
                NOP                            ; Reserved Vector 
;               LDR     PC, IRQ_Addr
                LDR     PC, [PC, #-0x0FF0]     ; Vector from VicVectAddr
                LDR     PC, FIQ_Addr

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address 
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
SWI_Handler     B       SWI_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler

; Literal pool definition              
Constant_Values	DCD	1,2,3,4,5,6,7,8,9,1,2,3,4,5,6,7,8,1,2,3,4

; Reset Handler          
Reset_Handler   				
				LDR LR, =Reset_Handler   ; the operator = is used to copy the address of a label 
				;equivalent to 
				;ADR 	LR, Reset_Handler

				LDR SP, =Stack_Top
			
			
				; my code

				LDR r4, =Constant_Values
				LDR r5, [r4]

				movs r0, #1
				moveq r1, #1
				mvn r2, #0

				ldr r3, =var
				str r2,	[r3,#4]
				ldr r2, =0x11223344
				mov r1, #4
				str r2,	[r3,r1]!
				ldr r2, =0x55667788
				str r2, [r3],#4

				ldr r1, =0x80000000
				ldr r0, =0x80000000
				adds r2, r1, r0				
				addeqs r0, r2, r1
				
				ldr r0, =0x01001000
				ldr r1, =0x00001001
				ldr r2, =0x00001000
				bic r1, r2
				tst r0, r1

				BEQ	LABEL	
				LDR R3, =0xFFFFFFFF
LABEL						   	
				; equivalent to
				LDRNE R3, =0xFFFFFFFF

				BL next
				nop
next
				mov r1, #4224
				ldr r2, =4225
				


				;MOV PC,	LR
				; equivalent to
				BX LR				           

				END