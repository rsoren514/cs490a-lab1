;****************** main.s ***************
; Program written by: ***Your Names**update this***
; Date Created: 1/22/2016 
; Last Modified: 1/22/2016 
; Section ***Tuesday 1-2***update this***
; Instructor: ***Ramesh Yerraballi**update this***
; Lab number: 4
; Brief description of the program
;   If the switch is presses, the LED toggles at 8 Hz
; Hardware connections
;  PE1 is switch input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard) 
;Overall functionality of this system is the similar to Lab 3, with three changes:
;1-  initialize SysTick with RELOAD 0x00FFFFFF 
;2-  add a heartbeat to PF2 that toggles every time through loop 
;3-  add debugging dump of input, output, and time
; Operation
;	1) Make PE0 an output and make PE1 an input. 
;	2) The system starts with the LED on (make PE0 =1). 
;   3) Wait about 62 ms
;   4) If the switch is pressed (PE1 is 1), then toggle the LED once, else turn the LED on. 
;   5) Steps 3 and 4 are repeated over and over


SWITCH                  EQU 0x40024008  ;PE1
LED                     EQU 0x40024004  ;PE0
SYSCTL_RCGCGPIO_R       EQU 0x400FE608
SYSCTL_RCGC2_GPIOE      EQU 0x00000010   ; port E Clock Gating Control
SYSCTL_RCGC2_GPIOF      EQU 0x00000020   ; port F Clock Gating Control
GPIO_PORTE_DATA_R       EQU 0x400243FC
GPIO_PORTE_DIR_R        EQU 0x40024400
GPIO_PORTE_AFSEL_R      EQU 0x40024420
GPIO_PORTE_PUR_R        EQU 0x40024510
GPIO_PORTE_DEN_R        EQU 0x4002451C
GPIO_PORTF_DATA_R       EQU 0x400253FC
GPIO_PORTF_DIR_R        EQU 0x40025400
GPIO_PORTF_AFSEL_R      EQU 0x40025420
GPIO_PORTF_DEN_R        EQU 0x4002551C
NVIC_ST_CTRL_R          EQU 0xE000E010
NVIC_ST_RELOAD_R        EQU 0xE000E014
NVIC_ST_CURRENT_R       EQU 0xE000E018
           THUMB
           AREA    DATA, ALIGN=4
SIZE       EQU    50
;You MUST use these two buffers and two variables
;You MUST not change their names
;These names MUST be exported
           EXPORT DataBuffer  
           EXPORT TimeBuffer  
           EXPORT DataPt [DATA,SIZE=4] 
           EXPORT TimePt [DATA,SIZE=4]
DataBuffer SPACE  SIZE*4
TimeBuffer SPACE  SIZE*4
DataPt     SPACE  4
TimePt     SPACE  4

    
      ALIGN          
      AREA    |.text|, CODE, READONLY, ALIGN=2
      THUMB
      EXPORT  Start
      IMPORT  TExaS_Init


Start BL   TExaS_Init  ; running at 80 MHz, scope voltmeter on PD3
      

        CPSIE   I                               ; TExaS voltmeter, scope runs on interrupts

        BL      Init_PortE                      ; initialize Port E
        BL      Init_PortF                      ; initialize Port F
        BL      Debug_Init                      ; initialize debugging dump, including SysTick
      
        BL      Main                            ; run program (forever)
    
        BL      Done                            ; shouldn't be reached


;------------Init_PortE------------
; Initialization ritual from Lecture 3 / Slide 23
; Input: none
; Output: none
; Modifies: see notes
; Notes: clears R3, R4, R5, R6
;
Init_PortE
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



;------------Init_PortF------------
; Initializes Port F
; Input: none
; Output: none
; Modifies: none
; Notes:
Init_PortF

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



loop
        BL   Debug_Capture
;heartbeat
; Delay
;input PE1 test output PE0
        B    loop



;------------Debug_Init------------
; Initializes the debugging instrument
; Input: none
; Output: none
; Modifies: none
; Note: push/pop an even number of registers so C compiler is happy
Debug_Init
      
        BL  SysTick_Init                        ; init SysTick
        BX LR



;------------Debug_Capture------------
; Dump Port E and time into buffers
; Input: none
; Output: none
; Modifies: none
; Note: push/pop an even number of registers so C compiler is happy
Debug_Capture

      BX LR



;------------Done------------
; Halts execution.
; Input: none
; Output: none
; Modifies: none
; Notes: none
        NOP
        ALIGN                                   ; make sure the end of
                                                ;       this section is aligned
        END                                     ; end of file
