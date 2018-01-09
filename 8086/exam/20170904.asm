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

H_LEAVE DW 0C1Eh ; 12:30
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
TWND DW 0

.CODE 
.STARTUP
 
;if H_LEAVE > A_SCHED[N_SCHED]: too late, first bus of nex day
  MOV AL,A_SCHED[N_SCHED*2-2]
  MOV AH,A_SCHED[N_SCHED*2-1]
  CMP H_LEAVE,AX
  JB find_a
  ;save the first schedule of the next day
  MOV AL,A_SCHED[0]
  MOV AH,A_SCHED[1]
  MOV A_LEAVE,AX
  ;compute time to wait until next day ride
  ;(time up to the end of the day + time to wait until next day first ride)
  XOR CX,CX
  XOR DX,DX
  ADD CH,23
  ADD CL,59
  SUB CX,H_LEAVE
  ADD CX,A_LEAVE
  MOV TWND,CX
  JMP skip_find_a
;else:
  ;finding nearest A bus departure
  ;while H_LEAVE > A_SCHED
    find_a:
    MOV AL,A_SCHED[SI]
    INC SI
    MOV AH,A_SCHED[SI]
    INC SI
    CMP H_LEAVE,AX
    JA find_a
  ;end while (find_a)
  MOV A_LEAVE,AX
;end if

skip_find_a:
;arrival time to B
;MOV AX, A_LEAVE
MOV BL, A_TO_B
CALL sumTime
MOV H_SWAP,BX 

;finding nearest B bus departure
XOR AX,AX
XOR SI,SI
;while H_SWAP(BX) > B_SCHED
  find_b:
  MOV AL,B_SCHED[SI]
  INC SI
  MOV AH,B_SCHED[SI]
  INC SI
  CMP BX,AX
  JA find_b
;end while (find_b)
MOV B_LEAVE,AX

;arrival time to destination:
XOR BX,BX 
;MOV AX,B_LEAVE
MOV BL, B_TO_TP
CALL sumTime
MOV AB_ARRIVE_TIME,BX


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
;input: AX (pointer to the schedule vector), BX (initial time)
;output: AX (finded next ride time)
nextRide PROC
nextRide ENDP


;convert time data to minutes only (unsigned integer value)
;parameters passed via register
;input: AX(time to be converted)
;output: AX(converted time in minutes)
toMinute PROC
PUSH CX
XOR CX,CX
MOV CL,AH ;cycle on hours
XOR AH,AH ;reset hours
h_to_m:
ADD AX,60
LOOP h_to_m
POP CX
RET
toMinute ENDP

END