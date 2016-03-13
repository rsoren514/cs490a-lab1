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
		; Turn on clock for Port E
		LDR			R3, =0x10
		LDR			R4, =SYSCTL_RCGCGPIO_R
		LDR			R5, [R4]
		ORR			R5, R5, R3
		STR			R5, [R4]
		
		; Wait 4 cycles
		NOP
		NOP
		NOP
		NOP

loop
		; Set direction flags for input mask
		LDR			R3, =0x38
		LDR			R4, =GPIO_PORTE_DIR_R
		STR			R3, [R4]
		
		; Set DEN flags for input mask
		LDR			R4, =GPIO_PORTE_DEN_R
		STR			R3, [R4]
		
		; Load input pins from Port E
		LDR			R4, =GPIO_PORTE_DATA_R
		LDR			R5, [R4]
		B			loop


      ALIGN        ; make sure the end of this section is aligned
      END          ; end of file
