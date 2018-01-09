.data

v1: double ;100 value
v2: double ;100 value
v3: double ;100 value
v4: double ;100 value
v5: double ;100 value
v6: double ;100 value
v7: double ;100 value

.text

main:  
daddui r1,r0,0        ;FDEMW 5
daddui r2,r0,100      ; FDEMW 6

loop: 
  l.d  f1,v1(r1)      ;  FDEMW 7 
  l.d  f2,v2(r1)      ;   FDEMW 8
  div.d  f7,f1,f2     ;    FDsddddddddMW 17 
  l.d  f3,v3(r1)      ;     FsDEMW 0
  mul.d  f8,f7,f3     ;      sFDssssssXXXXXXXXMW 25
  l.d  f4,v4(r1)      ;       sFssssssDEMW 0
  l.d  f5,v5(r1)      ;        sssssssFDEMW 0
  mul.d  f9,f4,f5     ;         sssssssFDsXXXXXXXXMW 29
  l.d  f6,v6(r1)      ;          sssssssFsDEMW 0
  mul.d  f10,f9,f6    ;           ssssssssFDssssssXXXXXXXXMW 37
  add.d  f11,f8,f10   ;            ssssssssFssssssDsssssssAAMW 39
  s.d  f11,v7(r1)     ;             ssssssssssssssFsssssssDEsMW 40
  daddi  r2,r2,-1     ;              sssssssssssssssssssssFDsEMW 41
  daddui  r1,r1,8     ;               sssssssssssssssssssssFsDEMW 42 
  bnez  r2,loop       ;                ssssssssssssssssssssssFDEMW 43

HALT                  ;                 ssssssssssssssssssssssFDEMW 44

;the HALT instruction is loaded each time instead of the first instruction
;of the loop due the branch delay slot enabled.

;loop total cycle: (44-6)*100 = 3800
;TOTAL CLOCK CYCLES: 3800+6 = 3806