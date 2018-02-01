;/*****************************************************************************
; * @file:    startup_LPC17xx.s
; * @purpose: CMSIS Cortex-M3 Core Device Startup File 
; *           for the NXP LPC17xx Device Series 
; * @version: V1.01
; * @date:    21. December 2009
; *------- <<< Use Configuration Wizard in Context Menu >>> ------------------
; *
; * Copyright (C) 2009 ARM Limited. All rights reserved.
; * ARM Limited (ARM) is supplying this software for use with Cortex-M3 
; * processor based microcontrollers.  This file can be freely distributed 
; * within development tools that are supporting such ARM based processors. 
; *
; * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
; * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
; * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
; * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
; *
; *****************************************************************************/


; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00000200

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp


; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00000000

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     MemManage_Handler         ; MPU Fault Handler
                DCD     BusFault_Handler          ; Bus Fault Handler
                DCD     UsageFault_Handler        ; Usage Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     DebugMon_Handler          ; Debug Monitor Handler
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                ; External Interrupts
                DCD     WDT_IRQHandler            ; 16: Watchdog Timer
                DCD     TIMER0_IRQHandler         ; 17: Timer0
                DCD     TIMER1_IRQHandler         ; 18: Timer1
                DCD     TIMER2_IRQHandler         ; 19: Timer2
                DCD     TIMER3_IRQHandler         ; 20: Timer3
                DCD     UART0_IRQHandler          ; 21: UART0
                DCD     UART1_IRQHandler          ; 22: UART1
                DCD     UART2_IRQHandler          ; 23: UART2
                DCD     UART3_IRQHandler          ; 24: UART3
                DCD     PWM1_IRQHandler           ; 25: PWM1
                DCD     I2C0_IRQHandler           ; 26: I2C0
                DCD     I2C1_IRQHandler           ; 27: I2C1
                DCD     I2C2_IRQHandler           ; 28: I2C2
                DCD     SPI_IRQHandler            ; 29: SPI
                DCD     SSP0_IRQHandler           ; 30: SSP0
                DCD     SSP1_IRQHandler           ; 31: SSP1
                DCD     PLL0_IRQHandler           ; 32: PLL0 Lock (Main PLL)
                DCD     RTC_IRQHandler            ; 33: Real Time Clock
                DCD     EINT0_IRQHandler          ; 34: External Interrupt 0
                DCD     EINT1_IRQHandler          ; 35: External Interrupt 1
                DCD     EINT2_IRQHandler          ; 36: External Interrupt 2
                DCD     EINT3_IRQHandler          ; 37: External Interrupt 3
                DCD     ADC_IRQHandler            ; 38: A/D Converter
                DCD     BOD_IRQHandler            ; 39: Brown-Out Detect
                DCD     USB_IRQHandler            ; 40: USB
                DCD     CAN_IRQHandler            ; 41: CAN
                DCD     DMA_IRQHandler            ; 42: General Purpose DMA
                DCD     I2S_IRQHandler            ; 43: I2S
                DCD     ENET_IRQHandler           ; 44: Ethernet
                DCD     RIT_IRQHandler            ; 45: Repetitive Interrupt Timer
                DCD     MCPWM_IRQHandler          ; 46: Motor Control PWM
                DCD     QEI_IRQHandler            ; 47: Quadrature Encoder Interface
                DCD     PLL1_IRQHandler           ; 48: PLL1 Lock (USB PLL)
				DCD		USBActivity_IRQHandler    ; USB Activity interrupt to wakeup
				DCD		CANActivity_IRQHandler    ; CAN Activity interrupt to wakeup


                IF      :LNOT::DEF:NO_CRP
                AREA    |.ARM.__at_0x02FC|, CODE, READONLY
CRP_Key         DCD     0xFFFFFFFF
                ENDIF

;AREA storing data for exercise 3
size_32 EQU 0x00000004	

				AREA MYDATA, NOINIT, READWRITE, ALIGN=3
mean SPACE size_32
max_differ SPACE size_32
max_value SPACE size_32
min_value SPACE size_32

                AREA    |.text|, CODE, READONLY


; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
                IMPORT  __main
				IMPORT SystemInit
                LDR     R0, =SystemInit
                BX      R0
				;branch to HardFault_Handler after doing SystemInit
                ENDP
				

; Dummy Exception Handlers (infinite loops which can be modified)                

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
                EXPORT  HardFault_Handler         [WEAK]

;-----------------------------------------------------------------
;exercise 1 ------------------------------------------------------
;-----------------------------------------------------------------
				MOV R0, #1 
				MOV R1, #2
				MOV R2, #3
				MOV R3, #4
				MOV R4, #5
				MOV R5, #6
				MOV R6, #7
				MOV R7, #7

;compute means if different, product if equal

				CMP R0, R1
				ADDNE R8, R0, R1
				LSRNE R8, #1
				MULEQ R8, R0, R1
				
				CMP R2, R3
				ADDNE R9, R2, R3
				LSRNE R9, #1
				MULEQ R9, R2, R3
				
				CMP R4, R5
				ADDNE R10, R4, R5
				LSRNE R10, #1
				MULEQ R10, R4, R5
				
				CMP R6, R7
				ADDNE R11, R6, R7
				LSRNE R11, #1
				MULEQ R11, R6, R7

;-----------------------------------------------------------------
;exercise 2 ------------------------------------------------------
;-----------------------------------------------------------------

				MOV r0, #15 
				MOV r1, #5
				MOV r2, #21
			
;swap registers if the first is higher than the second (R3 temporary register)
				CMP r0, r1 
				MOVHI R3, R0
				MOVHI R0, R1
				MOVHI R1, R3
				
				CMP r0, r2 
				MOVHI R3, R0 
				MOVHI R0, R2
				MOVHI R2, R3
				
				CMP r1, r2
				MOVHI R3, R1 
				MOVHI R1, R2
				MOVHI R2, R3

;checking if R1 and R2 are multiple of R0 (multiple subtractions)

loop1
				SUB R1,R1,R0
				CMP R1,#0 
				ADDGE R4,R4,#1 ;Signed Greater or Equal because if the result is negative it will be interpreted as positive in unsigned notation
				BGT loop1
				MOVNE R4,#0 ;if result of division not zero, dont save
		
loop2
				SUB R2,R2,R0
				CMP R2,#0 
				ADDGE R5,R5,#1
				BGT loop2
				MOVNE R5,#0

;-----------------------------------------------------------------
;exercise 3 ------------------------------------------------------
;-----------------------------------------------------------------
				MOV R0,#0 ;(otherwise give the error "Entry point does not point to an instruction")	
;sequence DCD 8,7,6,5,50,4,-1,-5 ;no monotonic
sequence DCD -3,-2,-1,2,3,5,10,15 ;increasing
;sequence DCD 8,7,6,5,5,4,-1,-5 ;decreasing
	
				;check increasing
				MOV R1,#0x80000000 ;lowest possible value at start (signed)
				LDR R0,=sequence ;pointer to sequence
increasing_loop
				LDR R2,[R0],#4 ;load value (post-addressing mode)
				CMP R2,R1
				BLT decreasing ;exit directly if found R2 < R1
				MOVNE R1,R2 ;update previous value (if not equal)
				ADD R4,R4,#1
				CMP R4,#8
				BNE increasing_loop
   
;compute mean value
sum_loop
				LDR R2,[R0,#-4]! ;reload the vector starting from the end
				ADD R3,R3,R2 ;R3 contains the sum of all the values
				SUB R4,R4,#1
				CMP R4,#0
				BNE sum_loop		
				LSR R3,R3,#3 ;dividing R3 by 8 by shifting
				LDR R0,=mean
				STR R3,[R0]
				B end_programm

;check decreasing
decreasing
				MOV R4,#0
				MOV R1,#0x7fffffff ;highest possible value at start (signed)
				LDR R0,=sequence ;pointer to sequence
decreasing_loop
				LDR R2,[R0],#4 ;load value (post-addressing mode)
				CMP R2,R1
				BGT monotonic ;exit directly if found R2 > R1
				MOVNE R1,R2 ;update previous value (if not equal)
				ADD R4,R4,#1
				CMP R4,#8
				BNE decreasing_loop

				;larger absolute difference between two consecutive numbers
				LDR R0,=sequence
				MOV R1,#0
				MOV R2,#0
				MOV R4,#0 ;max absolute difference temp register
lad_loop
			    LDR R1,[R0],#4
			    LDR R2,[R0]
			    SUB R1,R2,R1
			  	;invert if negative (absolute value) using Bit Clear
			  	CMP R1,#0
			  	BICLT R1,R5,R1 ;R5=0
			 	ADD R1,R1,#1
			  	CMP R1,R4
			  	MOVGT R4,R1
			  	ADD R6,R6,#1
			  	CMP R6,#7 ;one less than array lenght in this case (otherwise go after array the last element)
			  	BNE lad_loop

			  	LDR R0,=max_differ
			  	STR R4,[R0]
			  	B end_programm

;monotonic sequence, find min and max value
monotonic
			  	LDR R0,=sequence
			  	MOV R1,#0 ;temp register
			  	MOV R2,#0 ;temp for maximum
			  	MOV R3,#0 ;temp for minimum
			  	MOV R4,#0 ;counter register
min_max_loop
			  	LDR R1,[R0],#4
			  	CMP R1,R2
			  	MOVGT R2,R1 ;update max
			  	CMP R1,R3
			  	MOVLT R3,R1 ;update min
			  	ADD R4,R4,#1
			  	CMP R4,#8
			  	BNE min_max_loop
			 
			  	;store result in memory
			  	LDR R0,=max_value
			  	STR R2,[R0]
			  	LDR R0,=min_value
			  	STR R3,[R0]

end_programm
                B       .
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler         [WEAK]
                B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler          [WEAK]
                B       .
                ENDP
UsageFault_Handler\
                PROC
                EXPORT  UsageFault_Handler        [WEAK]
                B       .
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                B       .
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler          [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
                EXPORT  SysTick_Handler           [WEAK]
                B       .
                ENDP

Default_Handler PROC

                EXPORT  WDT_IRQHandler            [WEAK]
                EXPORT  TIMER0_IRQHandler         [WEAK]
                EXPORT  TIMER1_IRQHandler         [WEAK]
                EXPORT  TIMER2_IRQHandler         [WEAK]
                EXPORT  TIMER3_IRQHandler         [WEAK]
                EXPORT  UART0_IRQHandler          [WEAK]
                EXPORT  UART1_IRQHandler          [WEAK]
                EXPORT  UART2_IRQHandler          [WEAK]
                EXPORT  UART3_IRQHandler          [WEAK]
                EXPORT  PWM1_IRQHandler           [WEAK]
                EXPORT  I2C0_IRQHandler           [WEAK]
                EXPORT  I2C1_IRQHandler           [WEAK]
                EXPORT  I2C2_IRQHandler           [WEAK]
                EXPORT  SPI_IRQHandler            [WEAK]
                EXPORT  SSP0_IRQHandler           [WEAK]
                EXPORT  SSP1_IRQHandler           [WEAK]
                EXPORT  PLL0_IRQHandler           [WEAK]
                EXPORT  RTC_IRQHandler            [WEAK]
                EXPORT  EINT0_IRQHandler          [WEAK]
                EXPORT  EINT1_IRQHandler          [WEAK]
                EXPORT  EINT2_IRQHandler          [WEAK]
                EXPORT  EINT3_IRQHandler          [WEAK]
                EXPORT  ADC_IRQHandler            [WEAK]
                EXPORT  BOD_IRQHandler            [WEAK]
                EXPORT  USB_IRQHandler            [WEAK]
                EXPORT  CAN_IRQHandler            [WEAK]
                EXPORT  DMA_IRQHandler            [WEAK]
                EXPORT  I2S_IRQHandler            [WEAK]
                EXPORT  ENET_IRQHandler           [WEAK]
                EXPORT  RIT_IRQHandler            [WEAK]
                EXPORT  MCPWM_IRQHandler          [WEAK]
                EXPORT  QEI_IRQHandler            [WEAK]
                EXPORT  PLL1_IRQHandler           [WEAK]
				EXPORT  USBActivity_IRQHandler    [WEAK]
				EXPORT  CANActivity_IRQHandler    [WEAK]

WDT_IRQHandler           
TIMER0_IRQHandler         
TIMER1_IRQHandler         
TIMER2_IRQHandler         
TIMER3_IRQHandler         
UART0_IRQHandler          
UART1_IRQHandler          
UART2_IRQHandler          
UART3_IRQHandler          
PWM1_IRQHandler           
I2C0_IRQHandler           
I2C1_IRQHandler           
I2C2_IRQHandler           
SPI_IRQHandler            
SSP0_IRQHandler           
SSP1_IRQHandler           
PLL0_IRQHandler           
RTC_IRQHandler            
EINT0_IRQHandler          
EINT1_IRQHandler          
EINT2_IRQHandler          
EINT3_IRQHandler          
ADC_IRQHandler            
BOD_IRQHandler            
USB_IRQHandler            
CAN_IRQHandler            
DMA_IRQHandler          
I2S_IRQHandler            
ENET_IRQHandler       
RIT_IRQHandler          
MCPWM_IRQHandler             
QEI_IRQHandler            
PLL1_IRQHandler           
USBActivity_IRQHandler
CANActivity_IRQHandler

                B       .

                ENDP


                ALIGN


; User Initial Stack & Heap

                IF      :DEF:__MICROLIB
                
                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit
                
                ELSE
                
                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap
__user_initial_stackheap

                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR

                ALIGN

                ENDIF


                END
