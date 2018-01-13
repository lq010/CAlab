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


;// <h> Stack Configuration (Stack Sizes in Bytes)
;//   <o0> Undefined Mode      <0x0-0xFFFFFFFF:8>
;//   <o1> Supervisor Mode     <0x0-0xFFFFFFFF:8>
;//   <o2> Abort Mode          <0x0-0xFFFFFFFF:8>
;//   <o3> Fast Interrupt Mode <0x0-0xFFFFFFFF:8>
;//   <o4> Interrupt Mode      <0x0-0xFFFFFFFF:8>
;//   <o5> User/System Mode    <0x0-0xFFFFFFFF:8>
;// </h>

UND_Stack_Size  EQU     0x00000080
SVC_Stack_Size  EQU     0x00000080
ABT_Stack_Size  EQU     0x00000000
FIQ_Stack_Size  EQU     0x00000000
IRQ_Stack_Size  EQU     0x00000080
USR_Stack_Size  EQU     0x00000400

ISR_Stack_Size  EQU     (UND_Stack_Size + SVC_Stack_Size + ABT_Stack_Size + \
                         FIQ_Stack_Size + IRQ_Stack_Size)

                AREA    STACK, NOINIT, READWRITE, ALIGN=3

Stack_Mem       SPACE   USR_Stack_Size
__initial_sp    SPACE   ISR_Stack_Size

Stack_Top


;// <h> Heap Configuration
;//   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF>
;// </h>

Heap_Size       EQU     0x00000100

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3

Heap_Mem        SPACE   Heap_Size




                PRESERVE8
                

; Area Definition and Entry Point
;  Startup Code must be linked first at Address at which it expects to run.

                AREA    RESET, CODE, READONLY
                ARM


; Exception vector table handles every type of exceptions.
;  It is mapped to Address 0.
;  Absolute addressing mode must be used.
;  Dummy Handlers are implemented as infinite loops which can be modified.

;this vector table is fixed, implemented in hardware, each interrupt know how to jump in this table!
Vectors         LDR     PC, Reset_Addr			; reset - first instruction executed!        
                LDR     PC, Undef_Addr			; undefined instruction - load a non implemented instruction
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

;SWI management
SWI_Handler	
				STMFD 	sp!, {r0-r12, lr} ;push instruction
				LDR r0, [lr, #-4] ; load into r0 the caller instruction (in this case SWI)
				BIC 	r1, r0, #0xff000000 ;logical AND bitwise r0 and 0xff..!(negate) extrapolate from instruction cose the "immediate" (last 24 bits)
				; test the identification code of the interrupt
				CMP 	r1, #0x10 ;switch case with the identification to find correct SWI ISR
				BNE 	end_swi

				; your action here 

end_swi			LDMFD 	sp!, {r0-r12, pc}^ ;pop instruction, continue the code after the called SWI


; Reset Handler
Reset_Handler   


; Initialise Interrupt System
;  ...


; Setup Stack for each mode

                LDR     R0, =Stack_Top ; !the code start here!

; Enter Undefined Instruction Mode and set its Stack Pointer
; MSR transfers the value of the immediate to the Program Status Register (CPSR).
; CPSR indicates the state of the machine: it contains condition code flags,
; interrupt enable flags, the current mode, and the current state.
; We change the mode by updating CPSR

                MSR     CPSR_c, #Mode_UND:OR:I_Bit:OR:F_Bit ;undefined instruction mode
                MOV     SP, R0
                SUB     R0, R0, #UND_Stack_Size

;  Enter Abort Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_ABT:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #ABT_Stack_Size

;  Enter FIQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_FIQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #FIQ_Stack_Size

;  Enter IRQ Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #IRQ_Stack_Size

;  Enter Supervisor Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_SVC:OR:I_Bit:OR:F_Bit
                MOV     SP, R0
                SUB     R0, R0, #SVC_Stack_Size

;  Enter User Mode and set its Stack Pointer
                MSR     CPSR_c, #Mode_USR
                MOV     SP, R0
                SUB     SL, SP, #USR_Stack_Size

              

; main program starts here.
; The interrupt service routine with identification code 10h is called
				
				SWI #0x10 
               
				B Reset_Handler


                END
