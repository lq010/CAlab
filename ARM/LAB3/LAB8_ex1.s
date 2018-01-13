;/*****************************************************************************/
;/* STARTUP.S: Startup file for Philips LPC2000                               */
;/*****************************************************************************/
;/* <<< Use Configuration Wizard in Context Menu >>>                          */ 
;/*****************************************************************************/
;/* This file is part of the uVision/ARM development tools.                   */
;/* Copyright (c) 2005-2007 Keil Software. All rights reserved.               */
;/* This software may only be used under the terms of a valid, current,       */
;/* end user licence from KEIL for a compatible version of KEIL software      */
;/* development tools. Nothing else gives you the right to use this software. */
;/*****************************************************************************/


; Standard definitions of Mode bits and Interrupt (I & F) flags in PSRs

Mode_USR        EQU     0x10
Mode_FIQ        EQU     0x11
Mode_IRQ        EQU     0x12
Mode_SVC        EQU     0x13
Mode_ABT        EQU     0x17
Mode_UND        EQU     0x1B
Mode_SYS        EQU     0x1F

I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled
	
DIM  			      EQU		  0x80			      ; dimension of literal pool	(4x32bit)

UND_Stack_Size  EQU     0x00000080
SVC_Stack_Size  EQU     0x00000080
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000080
USR_Stack_Size  EQU     0x00000400
ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + FIQ_Stack_Size + IRQ_Stack_Size)

;Stack Area
                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size
Stack_Top


;Heap Area
Heap_Size       EQU     0x00000100
                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
Heap_Mem        SPACE   Heap_Size

                PRESERVE8                

; Code Area (Entry point)

                AREA    RESET, CODE, READONLY
                ARM

; Exception vector table handles every type of exceptions.
;  It is mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

;this vector table is fixed, implemented in hardware, each interrupt know how to jump in this table!
Vectors         LDR     PC, Reset_Addr		; reset - first instruction executed!        
                LDR     PC, Undef_Addr		; undefined instruction - load a non implemented instruction
                LDR     PC, SWI_Addr			; software interrupt
                LDR     PC, PAbt_Addr			; prefetch abort - the programm counter try to load an instruction in an invalid memory location
                LDR     PC, DAbt_Addr			; data abort - try to access a memory area for which we don't have privilege or does not exist
                NOP                             ; reserved vector 
                LDR     PC, IRQ_Addr			; IRQ
                LDR     PC, FIQ_Addr			; FIQ

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                      ; Reserved Address 
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler

literal1		DCD		0, 5, -10, 2147483648
literal2		DCD		0, 3, -3, 1

;SWI management
SWI_Handler	
  STMFD sp!,{r0-r12, lr} ;push instruction
	LDR r0,[lr, #-4]       ;load into r0 the caller instruction (in this case SWI)
	BIC r1,r0,#0xff000000  ;logical AND bitwise r0 and 0xff..!(negate) extrapolate from instruction cose the "immediate" (last 24 bits)
	CMP r1,#0x10           ;test the identification code of the interrupt (like switch-case)
	BNE second_swi
	;your action for routine 0x10 here 
second_swi		
  CMP r1,#0x20
	BNE 	end_swi
	;your action for routine 0x20 here
end_swi			
  LDMFD sp!,{r0-r12, pc}^ ;pop instruction, continue the code after the called SWI


Reset_Handler   
; Setup Stack for each mode
  LDR R0, =Stack_Top ;

  MSR CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit ;Undefined Instruction mode
  MOV SP, R0
  SUB R0, R0, #UND_Stack_Size

  MSR CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit ;Abort mode
  MOV SP, R0
  SUB R0, R0, #ABT_Stack_Size

  MSR CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit ;FIQ mode
  MOV SP, R0
  SUB R0, R0, #FIQ_Stack_Size

  MSR CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit ;IRQ mode
  MOV SP, R0
  SUB R0, R0, #IRQ_Stack_Size

  MSR CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit ;Supervisor ode
  MOV SP, R0
  SUB R0, R0, #SVC_Stack_Size

  MSR CPSR_c, #Mode_USR ;User mode
  MOV SP, R0
  SUB SL, SP, #USR_Stack_Size
   
; MAIN PROGRAMM:
start_main
  ;load literal pool addresses
  LDR r1,=literal1
  LDR r2,=literal2
				
scan_pool		
	LDR r1,[r1,#4]
	LDR r2,[r2,#4]
				
				
	SWI #0x10 
               
	B Reset_Handler

  END

;result area
				AREA RES, NOINIT, READWRITE, ALIGN=3				
result 			SPACE	DIM ;reserved space of diension DIM in which save the results
				END