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
				PRESERVE8 ;preserve 8byte aligment of the stack

;Heap Area
Heap_Size       EQU     0x00000100
                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
Heap_Mem        SPACE   Heap_Size                

;result area
DIM  			EQU		0x00000080 ; dimension of literal pool	(4x32bit)
				AREA 	data, NOINIT, READWRITE, ALIGN=3				
result 			SPACE	DIM ;reserved space of diension DIM in which save the results

				

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
                LDR     PC, SWI_Addr		; software interrupt
                LDR     PC, PAbt_Addr		; prefetch abort - the programm counter try to load an instruction in an invalid memory location
                LDR     PC, DAbt_Addr		; data abort - try to access a memory area for which we don't have privilege or does not exist
                NOP                         ; reserved vector 
                LDR     PC, IRQ_Addr		; IRQ
                LDR     PC, FIQ_Addr		; FIQ

Reset_Addr      DCD     Reset_Handler
Undef_Addr      DCD     Undef_Handler
SWI_Addr        DCD     SWI_Handler
PAbt_Addr       DCD     PAbt_Handler
DAbt_Addr       DCD     DAbt_Handler
                DCD     0                   ; Reserved Address 
IRQ_Addr        DCD     IRQ_Handler
FIQ_Addr        DCD     FIQ_Handler

Undef_Handler   B       Undef_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler

literal1		DCD		5, -5, 0x70000000, 0x80000000
literal2		DCD		3, -3, 0x20000000, 0xf0000000

;SWI management
SWI_Handler	
  STMFD sp!,{r0-r1, lr} ;push registers and return address (link register)
  LDR r0,[lr,#-4]        ;load into r0 the caller instruction (in this case SWI)
  BIC r1,r0,#0xff000000  ;(Bit Clear) logical AND bitwise r0 and 0xff..!(negate) extrapolate from instruction code the "immediate" field (last 24 bits) where identification code for SWI is stored
  CMP r1,#0x10           ;test the identification code of the SWI ("switch-case" like)
  BNE second_swi
  ;code for routine 0x10 
  LDR r6,=0x7fffffff
second_swi		
  CMP r1,#0x20
  BNE end_swi
  ;code for routine 0x20
  LDR r6,=0x80000000
end_swi			
  LDMFD sp!,{r0-r1, pc}^ ;pop instruction, continue the code after the called SWI

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

  MSR CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit ;Supervisor mode
  MOV SP, R0
  SUB R0, R0, #SVC_Stack_Size

  MSR CPSR_c, #Mode_USR ;User mode
  MOV SP, R0
  SUB SL, SP, #USR_Stack_Size
   
; MAIN PROGRAMM:

  ;load literal pool addresses
  LDR r0,=result
  LDR r1,=literal1
  LDR r2,=literal2
  LDR r10,=4
  
  ;sum each pair of value
scan_pool
  LDR r3,[r1],#4 ;post index addressing
  LDR r4,[r2],#4
  ADD r5,r3,r4

  ;creating overflow pattern
  AND r3,r3,#0x80000000
  AND r4,r4,#0x80000000
  AND r8,r5,#0x80000000
  LSR r3,r3,#2
  LSR r4,r4,#1
  ORR r8,r8,r3
  ORR r8,r8,r4

  ;if both positive and result negative 
  CMP r8,#0x80000000
  BNE skip_sw1
  SWI #0x10
  STR r6,[r0],#4
  B skip_store
skip_sw1 
  
  ;if both negative and result positive
  CMP r8,#0x60000000
  BNE skip_sw2
  SWI #0x20
  STR r6,[r0],#4
  B skip_store
skip_sw2  
  
  STR r5,[r0],#4

skip_store
  ADD r7,r7,r10
  CMP r7,#16 
  BNE scan_pool

do_nothing
  B do_nothing   
               
  END

