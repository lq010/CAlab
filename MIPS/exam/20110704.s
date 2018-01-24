.data

V1: .word ;"100 value"
V2: .word ;"100 value"
V3: .word ;"100 value"
V4: .word ;"100 value"

.text

main: 
daddui r1,r0,0    ;FDEMW 5
daddui r2,r0,100  ;sFDEMW 6
loop: 
l.d f1,v1(r1)     ;ssFDEMW 7
l.d f2,v2(r1)     ;sssFDEMW 8
l.d f3,v3(r1)     ;ssssFDEMW 9
l.d f4,v4(r1)     ;sssssFDEMW 10
div.d f6,f3,f4    ;ssssssFDsddddddddMW 19 (wait f4 after mem)
div.d f7,f1,f2    ;sssssssFsDsssssssddddddddMW 27 (wait divider unit)
mul.d f5,f6,f7    ;sssssssssFsssssssDsssssssXXXXXXXXMW 35
s.d f5,v5(r1)     ;sssssssssssssssssFsssssssDEsssssssMW 36
daddui r1,r1,8    ;sssssssssssssssssssssssssFDsssssssEMW 37
daddi r2,r2,-1    ;ssssssssssssssssssssssssssFsssssssDEMW 38
bnez r2,loop      ;ssssssssssssssssssssssssssssssssssFD--- 39
HALT              ;sssssssssssssssssssssssssssssssssssF---- 40
;l.d f1,v1(r1)    ;ssssssssssssssssssssssssssssssssssssFDEMW 41

;total clock cycles: (41-6)*100+6 = 3506 