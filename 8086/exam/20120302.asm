.MODEL small
.STACK
.DATA

;RECORDS DB 3 DUP (?) 
RECORDS   DB 74,42,211      ;start: 20:50, stop:  9:10
RATES     DW 0A9C5h, 0B941h ;start: 10:00, stop: 14:00, cost1:5 cost2:1 
DURATION_OF_CONNECTION DW ?
;COST_TO_BE_CHARGED DW (?) 
CALLTIME  DW 2 DUP(?) ;start(16bit LSB) - stop(16bit MSB)
RATE1     DW 2 DUP(?,?) ;start(16bit LSB) - stop(16bit MSB)
RATE2     DW 2 DUP(?) ;start(16bit LSB) - stop(16bit MSB)
R1COST    DB ?
R2COST    DB ?

;1 01010 01110 00101 : 10 14 5
;1 01110 01010 00001 : 14 10 1
.CODE
.STARTUP

;Extrapolate data
;input:
;RECORDS
;output:
;AH = start_h
;AL = start_m
;BH = stop_h
;BL = stop_m
;DL = pass_day

;stop time
MOV DH,RECORDS[1]
MOV DL,RECORDS[0]
MOV BL,DL
AND BL,00111111b
SHL DX,2
MOV BH,DH
AND BH,00011111b
;start time
MOV DH,RECORDS[2]
MOV DL,RECORDS[1]
MOV AH,DH
AND AH,01111111b
SHR AH,2
SHR DX,4
MOV AL,DL
AND AL,00111111b
;save day
XOR DX,DX
MOV DL,RECORDS[1]
SHR DL,3
AND DL,1

;convert call time to minutes
PUSH AX
PUSH BX
CALL timeToInteger
MOV CALLTIME[0],AX ;start time
MOV AX,BX
CALL timeToInteger
MOV CALLTIME[1],AX ;stop time
POP BX
POP AX

;duration of connection
;input:
;AX = start time
;BX = stop time 
;output:
;AH = final_h
;AL = final_m

XOR CX,CX
;if(start_m > stop_m)
  CMP AL,BL
  JB min_lower
  SUB AL,BL
  JMP hours
;else
  min_lower:
  ADD CL,60
  SUB CL,BL
  ADD CL,AL
  MOV AL,CL
  ADD CH,1 ;CH = carry to hours
;end if

;if(start_h > stop_h && day == 0)
  hours:
  CMP AH,BH
  JB hr_lower
  CMP DL,0 ;DL = 1 means next day
  JNE hr_lower
  SUB AH,BH
  SUB AH,CH ;carry to minute
  JMP cost_of_connection
;else
  hr_lower:
  MOV CL,24
  SUB CL,AH
  ADD CL,BH
  SUB CL,CH ;carry to minute
  MOV AH,CL
;end if

MOV DURATION_OF_CONNECTION,AX

;extrapolate RATES data and convert it to minute
;input: RATES DW 2 (time format)
;output: RATE1, RATE2 DW 2 (minutes)

;rate1 time
XOR AX,AX
MOV DX,RATES[0]
MOV AL,DL
AND AL,00011111b ;cost field
ADD R1COST,AL
XOR AX,AX
SHR DX,2
MOV AH,DH
AND AH,00011111b ;start hour field
CALL timeToInteger
MOV RATE1[0],AX  ;start hour in minute
XOR AX,AX 
SHR DX,3
MOV AH,DL
AND AH,00011111b ;stop hour field
CALL timeToInteger
MOV RATE1[2],AX  ;stop hour in minute  

;rate2 time

;COST OF THE CALL
cost_of_connection:

;check start RATE
;if(rate1_s < start_t <= rate1_e): start in rate1
;else: start in rate2


.EXIT

;purpose: converts time format to integer
;parameters passed by register
;input: AH,AL(hh,mm) = time
;output: AX = minutes (integer)
timeToInteger PROC
PUSH BX
PUSH CX
XOR BX,BX
XOR CX,CX
MOV CL,AL ;save minutes
ADD BL,60 ;set operand
MOV AL,AH ;swap hour
MUL BL ;AX=AL*BL
ADD AX,CX
POP CX
POP BX
RET
timeToInteger ENDP

;purpose: tell if a time is in a particular RATES range
;parameters passed by register
;input: 
;AX = time to verify (in minute);
;BX = pointer to a structure (2 DW) that contains start (LSB 16bit) and stop (MSB 16bit) time (in minute)
;output: BL (0 = out-of-range, 1 = in-range)
isInRange PROC
PUSH CX
PUSH DX
MOV CX,BX[0] ;select start time
MOV DX,BX[1] ;select stop time
XOR BX,BX
;if(start_t < time <= stop_t): is in range
  CMP AX,CX
  JBE out_range 
  CMP AX,DX
  JA out_range
  ADD BL,1 ;in_range
;end if
out_range:
POP DX
POP CX
RET
isInRange ENDP


END
