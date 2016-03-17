;****************** main.s ***************
; Program written by:
;   Stephen Chavez
;   Alan Peters
;   Randy Sorensen
; Date Created: 3/15/2016 
; Section: 2016 Spring CS490A - Tues/Thurs 6:00 - 7:50 PM
; Instructor: Iliya Georgiev
; Lab number: 2
; Brief description of the program
; The overall objective of this system an interactive alarm
; Hardware connections
;  PF4 is switch input  (1 means SW1 is not pressed, 0 means SW1 is pressed)
;  PF3 is LED output (1 activates green LED) 
; The specific operation of this system 
;    1) Make PF3 an output and make PF4 an input (enable PUR for PF4). 
;    2) The system starts with the LED OFF (make PF3 =0). 
;    3) Delay for about 100 ms
;    4) If the switch is pressed (PF4 is 0), then toggle the LED once, else turn the LED OFF. 
;    5) Repeat steps 3 and 4 over and over

GPIO_PORTF_DATA_R       EQU     0x400253FC
GPIO_PORTF_DIR_R        EQU     0x40025400
GPIO_PORTF_AFSEL_R      EQU     0x40025420
GPIO_PORTF_PUR_R        EQU     0x40025510
GPIO_PORTF_DEN_R        EQU     0x4002551C
GPIO_PORTF_AMSEL_R      EQU     0x40025528
GPIO_PORTF_PCTL_R       EQU     0x4002552C
SYSCTL_RCGCGPIO_R       EQU     0x400FE608

        AREA    |.text|, CODE, READONLY, ALIGN=2
        THUMB
        EXPORT  Start


Start
        BL      Init                            ; initialize
        BL      Main                            ; run program (forever)

        B       Done                            ; shouldn't be reached


;
; Function: Init()
; Description: Initialization ritual from Lecture 3 / Slide 23
; Notes: clears R3, R4, R5, R6
;
Init
        ; Set bit 5 of GPIO clock register (Port F)
        LDR     R3, =0x20                       ; Port F mask
        LDR     R4, =SYSCTL_RCGCGPIO_R          ; clock reg address
        LDR     R5, [R4]                        ; load clock reg
        ORR     R5, R5, R3                      ; set Port F bit
        STRB    R5, [R4]                        ; write to clock reg
        
        ; Wait 4 clocks before writing to Port F regs
        NOP                                     ; 1 cycle
        NOP                                     ; 2 cycles
        
        ; Clear Port F AMSEL
        LDR     R6, =0x00                       ; 3 cycles / AMSEL disable mask
        LDR     R4, =GPIO_PORTF_AMSEL_R         ; 4 cycles / PF AMSEL address
        STRB    R6, [R4]                        ; analog mode disabled
        
        ; Clear Port F PCTL
        LDR     R4, =GPIO_PORTF_PCTL_R          ; PF PCTL address
        STRB    R6, [R4]                        ; clear port function

        ; Set DIRection of pin 3 (output) and pin 4 (input)
        LDR     R3, =0x10                       ; SW0 / PF4 mask
        EOR     R7, R3, #0xFF                   ; input=0, output=1
        LDR     R4, =GPIO_PORTF_DIR_R           ; PF DIR address
        STRB    R7, [R4]                        ; write DIR reg

        ; Clear Port F AFSEL
        LDR     R4, =GPIO_PORTF_AFSEL_R         ; Port F AFSEL address
        STRB    R6, [R4]                        ; analog function disabled
        
        ; Enable pull-up on PF4
        LDR     R4, =GPIO_PORTF_PUR_R           ; PF PUR address
        STRB    R3, [R4]                        ; enable PF4 pullup

        ; Set Digital ENable for relevant pins
        LDR     R3, =0x18                       ; mask pins 3 & 4
        LDR     R4, =GPIO_PORTF_DEN_R           ; Port F DEN address
        STRB    R3, [R4]                        ; enable pins 3 & 4
        
        ; Return
        BX      LR                              ; Initialization complete


;
; Function: Delay()
; Description: Delay function. Stalls the clock for a
;              predetermined amount of time.
; Notes:
;
;       * The following initial values correspond to 100ms in the
;         noted environments:       
;               0x4FFFF - Keil simulator
;
;       * Wipes out R7.
;
Delay
        LDR		R7, =0x4FFFF                    ; Initial value
	  
decr
        ; Decrement until 0
        SUB		R7, R7, #1                      ; decrement R7
        TEQ		R7, #0                          ; compare R7 to 0
        BNE		decr                            ; loop if not 0
        BX		LR                              ; return if 0
        
        ; Not Reached!

;
; Function: Main()
; Description: Run the main program.
; Notes: Delay() uses R7 so it shouldn't be used here.
;
Main
        LDR     R3, =0x00                       ; zero
        LDR     R4, =0x08                       ; PF3 / LED output mask
        LDR     R5, =0x10                       ; PF4 / switch input mask
        LDR     R6, =GPIO_PORTF_DATA_R          ; Port F DATA register address

led_off
        ; Turn LED off for 100ms
        STRB    R3, [R6]                        ; turn LED off
        BL      Delay                           ; elapse 100ms
        
        ; Check switch status - because it uses negative logic,
        ; PF4 is 0 when the switch is DOWN and 1 when the switch
        ; is UP
        LDR     R8, [R6]                        ; load Port F DATA into R8
        STRB    R4, [R6]
        AND     R8, R5                          ; test switch / PF4 bit
        TEQ     R8, R3                          ;       "
        BNE     led_off                         ; SW=off -> LED=off for 100ms

        ; SW=on -> LED=on for 100ms
        STRB    R4, [R6]                        ; turn LED on
        BL      Delay                           ; elapse 100ms
        B       led_off
        
        ; Not reached


;
; Function: Done()
; Description: Return from the program.
;
Done
        NOP
        ALIGN                                   ; make sure the end of
                                                ;       this section is aligned
        END                                     ; end of file
       