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

SWI_Handler		B		SWI_Handler
PAbt_Handler    B       PAbt_Handler
DAbt_Handler    B       DAbt_Handler
IRQ_Handler     B       IRQ_Handler
FIQ_Handler     B       FIQ_Handler
  

;Undefined Instructions handler
Undef_Handler	
  STMFD sp!,{r0-r11, lr} ;push registers and return address (link register)
  
  LDR r0,[lr,#-4] ;save into r0 caller instruction code
  BIC r1,r0,#0xf00fffff ;select user defined instruction type field	(in our case should be 0x7F)
  CMP r1,#0x07f00000 ;skip if is not a division instruction
  BNE no_division
  BIC r2,r0,#0xffff00ff ;store in r2 immediate field
  LSR r2,r2,#8 ;obtain correct immediate value (shift 8bit)
  BIC r3,r0,#0xfffffff0 ;store in r3 the number of source register
  LDR r4,[sp, r3, LSL #2] ;load from stack the value in the source register. Remember that is codified as 0xF? and we select ?, with LSL we multiply by 4 this value because the register are on 4byte into stack.
  
  LDR r12,=0
division_loop
  CMP r4,r2
  SUBHS r4,r4,r2 ;subtract if higher of the same
  ADDHS r12,r12,#1
  BHS division_loop

no_division  			
  LDMFD sp!,{r0-r11, pc}^ ;pop instruction (notice pushed lr now is loaded from the stack to pc)

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

  LDR r6,=16
DIVR6BY5 DCD 0xE7F005F6	;generates undefined exception

do_nothing
  B do_nothing   
               
  END

