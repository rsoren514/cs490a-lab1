;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 3
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 2, with six changes:
;1-  the pin to which we connect the switch is moved to PE1, 
;2-  you will have to remove the PUR initialization because pull up is no longer needed. 
;3-  the pin to which we connect the LED is moved to PE0, 
;4-  the switch is changed from negative to positive logic, and 
;5-  you should increase the delay so it flashes about 8 Hz.
;6-  the LED should be on when the switch is not pressed
; Operation
;   1) Make PE0 an output and make PE1 an input. 
;   2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over


GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_AFSEL_R      EQU   0x40024420
GPIO_PORTE_DEN_R        EQU   0x4002451C
GPIO_PORTE_AMSEL_R      EQU   0x40024528
GPIO_PORTE_PCTL_R       EQU   0x4002452C
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
       IMPORT  TExaS_Init
       AREA    |.text|, CODE, READONLY, ALIGN=2
       THUMB
       EXPORT  Start
Start
 ; TExaS_Init sets bus clock at 80 MHz
      BL  TExaS_Init ; voltmeter, scope on PD3
; you initialize PE1 PE0


      CPSIE  I    ; TExaS voltmeter, scope runs on interrupts


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
        LDR     R3, =0x10                       ; Port E mask
        LDR     R4, =SYSCTL_RCGCGPIO_R          ; clock reg address
        LDR     R5, [R4]                        ; load clock reg
        ORR     R5, R5, R3                      ; set Port E bit
        STRB    R5, [R4]                        ; write to clock reg
        
        ; Wait 4 clocks before writing to Port F regs
        NOP                                     ; 1 cycle
        NOP                                     ; 2 cycles
        
        ; Clear Port E AMSEL
        LDR     R6, =0x00                       ; 3 cycles / AMSEL disable mask
        LDR     R4, =GPIO_PORTE_AMSEL_R         ; 4 cycles / PE AMSEL address
        STRB    R6, [R4]                        ; analog mode disabled
        
        ; Clear Port E PCTL
        LDR     R4, =GPIO_PORTE_PCTL_R          ; PE PCTL address
        STRB    R6, [R4]                        ; clear port function

        ; Set DIRection of pin 0 (output) and pin 1 (input)
        LDR     R3, =0x02                       ; PE0 mask
        EOR     R7, R3, #0xFF                   ; input=0, output=1
        LDR     R4, =GPIO_PORTE_DIR_R           ; PF DIR address
        STRB    R7, [R4]                        ; write DIR reg

        ; Clear Port E AFSEL
        LDR     R4, =GPIO_PORTE_AFSEL_R         ; Port E AFSEL address
        STRB    R6, [R4]                        ; analog function disabled
        
        ; Enable pull-up on PF4
;        LDR     R4, =GPIO_PORTF_PUR_R           ; PF PUR address
;        STRB    R3, [R4]                        ; enable PF4 pullup

        ; Set Digital ENable for relevant pins
        LDR     R3, =0x03                       ; mask pins 0 & 1
        LDR     R4, =GPIO_PORTE_DEN_R           ; Port E DEN address
        STRB    R3, [R4]                        ; enable pins 0 & 1
        
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
;               0x63FFE - TI board
;       * Wipes out R7.
;
Delay
;        LDR     R7, =0x63FFE
        LDR		R7, =0xE9FFB                    ; Initial value
	  
decr
        ; Decrement until 0
pz        SUB		R7, R7, #1                      ; decrement R7
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
        LDR     R4, =0x01                       ; PE0 / LED output mask
        LDR     R5, =0x02                       ; PE1 / switch input mask
        LDR     R6, =GPIO_PORTE_DATA_R          ; Port E DATA register address

led_off
        ; Turn LED off for 100ms
        STRB    R4, [R6]                        ; turn LED off
        BL      Delay                           ; elapse 100ms
        
        ; Check switch status - because it uses negative logic,
        ; PF4 is 0 when the switch is DOWN and 1 when the switch
        ; is UP
        LDR     R8, [R6]                        ; load Port E DATA into R8
        AND     R8, R5                          ; test switch / PE1 bit
        TEQ     R8, R3                          ;       "
        BEQ     led_off                         ; SW=off -> LED=off for 100ms

        ; SW=on -> LED=on for 100ms
        STRB    R3, [R6]                        ; turn LED on
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
