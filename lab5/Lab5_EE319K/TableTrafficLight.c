// ***** 0. Documentation Section *****
// TableTrafficLight.c for (Lab 10 edX), Lab 5 EE319K
// Runs on LM4F120/TM4C123
// Program written by: put your names here
// Date Created: 1/24/2015 
// Last Modified: 1/24/2015 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 5
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********
// east/west red light connected to PB5
// east/west yellow light connected to PB4
// east/west green light connected to PB3
// north/south facing red light connected to PB2
// north/south facing yellow light connected to PB1
// north/south facing green light connected to PB0
// pedestrian detector connected to PE2 (1=pedestrian present)
// north/south car detector connected to PE1 (1=car present)
// east/west car detector connected to PE0 (1=car present)
// "walk" light connected to PF3 (built-in green LED)
// "don't walk" light connected to PF1 (built-in red LED)

// ***** 1. Pre-processor Directives Section *****
#include <stdint.h>
#include "TExaS.h"
#include "inc//tm4c123gh6pm.h"

// ***** 2. Global Declarations Section *****

// FUNCTION PROTOTYPES: Each subroutine defined
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts

// ***** 3. Subroutines Section *****

int main(void){ 
  TExaS_Init(SW_PIN_PE210, LED_PIN_PB543210); // activate grader and set system clock to 80 MHz
 
  
  EnableInterrupts();
  while(1){
     
  }
}

