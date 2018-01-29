; Computer Architectures (02LSEOV)
; exam 20170904
; Simone Iammarino 29/12/2017

.MODEL small 

.STACK

.DATA 

N_SCHED EQU 12

; hour format 2byte: minute (LSBYTE), hour (MSBYTE)
A_SCHED DB 10,8,0,9,45,9,30,10,30,11,30,12,15,13,0,14,0,15,0,16,0,17,0,18
B_SCHED DB 10,7,15,8,5,9,40,10,0,11,0,14,30,14,0,15,30,15,15,16,45,16,15,17
C_SCHED DB 30,8,40,9,50,10,0,12,10,13,20,14,30,15,40,16,50,17,0,19,10,20,20,21
D_SCHED DB 0,7,40,8,40,9,40,10,40,11,30,12,30,13,0,15,30,16,30,18,30,20,0,21

A_TO_B  DB 16 ;max 255-60=195 otherwise OF can happen when computing H_SWAP time
B_TO_TP DB 29
C_TO_D  DB 4
D_TO_TP DB 45

H_LEAVE DW 110Fh ; 17:15
H_SWAP DW 0

;finded best departure times
A_LEAVE DW 0
B_LEAVE DW 0
C_LEAVE DW 0
D_LEAVE DW 0

;arrival times to destination
AB_ARRIVE_TIME DW 0
CD_ARRIVE_TIME DW 0

AB_TOT_TIME DW 0
CD_TOT_TIME DW 0

;time to wait in case of next day ride
TWND_AB DW 0
TWND_CD DW 0

.CODE 
.STARTUP
;---------------------------------
;---------- A to B trip ----------
;---------------------------------
;find nearest A bus departure
MOV AX, H_LEAVE
MOV BX, offset A_SCHED
CALL nextRide
MOV A_LEAVE, BX
;update overflow [if present]
ADD TWND_AB, AX

;arrival time to B
XOR AX, AX
MOV AL, A_TO_B
;MOV BX, A_LEAVE
CALL sumTime
MOV H_SWAP, BX

;find nearest B bus departure
MOV AX, H_SWAP
MOV BX, offset B_SCHED
CALL nextRide
MOV B_LEAVE, BX
;update overflow [if present]
MOV BX,TWND_AB
CALL sumTime
MOV TWND_AB, BX

;arrival time to destination:
XOR BX,BX 
MOV AX, B_LEAVE
MOV BL, B_TO_TP
CALL sumTime
MOV AB_ARRIVE_TIME, BX

;total time A-B
;if TWND_AB=0: no overflow problem
;else:
;end if 
MOV AX,H_LEAVE

.EXIT

;sums two time format data: BX=AX+BX
;parameters passed by registers
;input: AX,BX (two time data)
;output: BX (sum of the two time data)
sumTime PROC
ADD BL,AL ;add minute
ADD BH,AH ;add hour
;while minute > 59: subtract -60 to minute and add +1 to hours
  mtoh:
  CMP BL,59
  JBE skip_mtoh
  SUB BL,60
  ADD BH,1
  JMP mtoh
;end while(mtoh)
skip_mtoh:
RET
sumTime ENDP

;given a time and schedule, find the next scheduled ride
;parameters passed by registers
;input: AX (initial time), BX (pointer to the schedule vector), 
;output: BX (finded next ride time), AX (overflow time to next day [if any])
;!WARNING: to pass pointer we need to use BX!  
nextRide PROC
PUSH CX
;if AX(time) > BX[N_SCHED](last ride): too late, wait first bus of nex day
  MOV CL,[BX][N_SCHED*2-2]
  MOV CH,[BX][N_SCHED*2-1]
  CMP AX,CX
  JB scan_schedule
  ;save the first schedule of the next day
  MOV CL,BX[0]
  MOV CH,BX[1]
  ;compute time to wait until next day ride
  XOR BX,BX
  ADD BH,23
  ADD BL,59
  SUB BX,AX ;time up to the end of the day
  ADD BX,CX ;time to wait until next day first ride
  MOV AX,BX ;save overflow return value
  MOV BX,CX ;save departure time
  JMP end_nextRide
;else:
  scan_schedule:
  ;finding nearest scheduled bus departure
  PUSH SI
  XOR SI,SI
  ;while AX(time) > BX(schedule time)
    schedule_loop:
    MOV CL,BX[SI]
    INC SI
    MOV CH,BX[SI]
    INC SI
    CMP AX,CX
    JA schedule_loop
  ;end while (scan_schedule)
  MOV BX,CX
  XOR AX,AX ;return no overflow
  POP SI
;end if
end_nextRide:
POP CX
RET
nextRide ENDP


;convert time data to minutes only (unsigned integer value)
;parameters passed via register
;input: AX(time to be converted)
;output: AX(converted time in minutes)
toMinute PROC
PUSH CX
XOR CX,CX
;if AH(hours) == 0: do nothing 
  CMP AH,0 ;only minutes
  JE skip_toMinute
;else:
  MOV CL,AH ;cycle on hours
  XOR AH,AH ;reset hours
    h_to_m:
    ADD AX,60
    LOOP h_to_m
;end if
skip_toMinute:
POP CX
RET
toMinute ENDP

END