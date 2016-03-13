;****************** main.s ***************
; Program written by:
;     Stephen Chavez
;     Alan Peters
;     Randy Sorensen
; Date Created: 3/10/2016
; Last Modified: 3/10/2016 
; CS490A
; Instructor: Iliya Georgiev
; Lab number: 1
; Brief description of the program
; The overall objective of this system is a digital lock
; Hardware connections
;  PE3 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE4 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE5 is switch input  (1 means switch is not pressed, 0 means switch is pressed)
;  PE2 is LED output (0 means door is locked, 1 means door is unlocked) 
; The specific operation of this system is to 
;   unlock if all three switches are pressed

GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608

      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
Start
      ;Enable porte clock
      LDR         R3, =0x10
      LDR         R4, =SYSCTL_RCGCGPIO_R
      LDR         R5, [R4]
      ORR         R5, R5, R3
      STRB        R5, [R4]  ; need to wait 4 clocks before modifying other PORTE
      
      LDR         R8, =0x04 ;LED Bit      ;1 clk
      
      ;invert LED Bit AKA NOT LED Bit
      LDR         R9, =0xFFFFFFFF         ;2 clk
      EOR         R9, R9, R8;             ;3 clk
      
      ; set port direction out for LED pin
      LDR         R4, =GPIO_PORTE_DIR_R   ;4 clk
      STRB        R8, [R4]
      
      ;enable needed digital IO pins
      LDR         R3, =0x3C ; 0b 0011 1100
      LDR         R4, =GPIO_PORTE_DEN_R
      STRB        R3, [R4]
      
      ;for comparison in loop
      LDR         R10, =0x38
      LDR         R6, =0x00 
      
      ;clear AMSEL & AFSEL & PCTL
      LDR         R4, =GPIO_PORTE_AMSEL_R
      STRB        R6, [R4]
      LDR         R4, =GPIO_PORTE_AFSEL_R
      STRB        R6, [R4]
      LDR         R4, =GPIO_PORTE_PCTL_R
      STRB        R6, [R4]
loop
      LDR         R4, =GPIO_PORTE_DATA_R
      LDR         R5, [R4]
      AND         R7, R5, R10
      TEQ         R7, R6
      ORREQ       R5, R8 ;if equal then turn on LED
      ANDNE       R5, R9 ;if not equal then turn off LED
      STRB        R5, [R4]
      
      B   loop


      ALIGN        ; make sure the end of this section is aligned
      END          ; end of file
