// Lab6.c
// Runs on LM4F120 or TM4C123
// Use SysTick interrupts to implement a 4-key digital piano
// MOOC lab 13 or EE319K lab6 starter
// Program written by: put your names here
// Date Created: 1/24/2015 
// Last Modified: 1/24/2015 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 6
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********


#include <stdint.h>
#include "inc//tm4c123gh6pm.h"
#include "Sound.h"
#include "Piano.h"
#include "TExaS.h"

// basic functions defined at end of startup.s
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts


int main(void){      
  TExaS_Init(SW_PIN_PE3210,DAC_PIN_PB3210,ScopeOn);    // bus clock at 80 MHz 
	Piano_Init();
  Sound_Init(0);
  // other initialization
  EnableInterrupts();
	//Sound_Play(5000); //test
  uint8_t last = 0;
	uint8_t current = 0;
	while(1){
		current = (uint8_t)Piano_In();
		if(current != last){
			if(current & 0x08){
				Sound_Play(393);
			}else if( current & 0x04){
				Sound_Play(473);
			}else if(current & 0x02){
				Sound_Play(541);
			}else if(current & 0x01) {
				Sound_Play(397);
			}else{
				Sound_Play(0);
			}
			last = current;
		}
  }         
}


