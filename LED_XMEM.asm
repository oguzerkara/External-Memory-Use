.MACRO INITSTACK
ldi R16, high(ramend)
out SPH, R16
ldi R16, low(ramend)
out SPL, R16
.ENDMACRO
.equ offset = 0x2000 ;Beginning of the memory is set just after the SRAM memory (0x1FFF)
.equ userfriend = 0x55
.org 0x0000
;Since the External Memory is mapped after the Internal Memory , only 60 Kbyte of External Memory is available by default
;It is needed to activate XMEM for 2K storage:
start:
INITSTACK
call init_XMEM
ldi R16, 0xFF
out ddrA, R16
out ddrD, R16
out ddrE, R16
call ld_XMEM
call rd_XMEM
RJMP start
ld_XMEM:
ldi ZH, high(offset)
ldi ZL, low( offset)
ldi R18, userfriend
ldi R16, 8
L2:
ldi R17, 128 ;128*8 =2K times load value
L1:
st Z+, R18
dec R17
brne L1
dec R16
brne L2
ret
rd_XMEM:
ldi ZH, high(offset)
ldi ZL, low( offset)
ldi R16, 8
LA:
ldi R17, 128 ;128*8 =2K times read value
LB:
ld R18, Z+
call LED
call delay_80mS
dec R17
brne LB
dec R16
brne LA
ret
LED:
out porte, ZL
out portd, ZH
out porta, R18
ret
init_XMEM:
ldi r16, 0xFF
out DDRC, r16 ;enable portC
ldi r16, 0x00
out PORTC, r16 ;clear all the pins on PORTC
ldi R16, 0x80 ;(1<<SRE)
sts MCUCR, R16 ;By setting SRE (R16=0x80 or 1<<SRE) we enable our XMEM to use. A15 PC is released manually. So there IRAM and XRAM will be separated each other. This is default actually.
;ldi R16, 0
;sts XMCRA, R16; ;sector limit is not seperated.
ldi R16, (1<<XMM1)|(1<<XMM0); each PC pin controls 2 bit address lines. In our case we need 2K =2^12, so 12/2 = 6 bits. Therefore we will use PC0-PC5.
;So we can release PC5-PC7 by setting XMM2=0, XMM1=1, XMM0=1 (011), as making them regular PORTC pins.
sts XMCRB, R16
ret
;------------------------------DELAY SUBROUTINE-----------------------------------------------
delay_80mS:
ldi R20, 80
S1:
call delay1mS ; delay for 1 mS
dec R20 ; update the delay counter
brne S1
ret
delay1mS: ; counter is not zero
push YL ; [2] preserve registers
push YH ; [2]
ldi YL, low (1996) ; [1] delay counter
ldi YH, high(1996) ; [1]
delay1mS_01:
sbiw YH:YL, 1 ; [2] update the the delay counter
brne delay1mS_01 ; [2] delay counter is not zero
; arrive here when delay counter is zero
pop YH ; [2] restore registers
pop YL ; [2]
ret
