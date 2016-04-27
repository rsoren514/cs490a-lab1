// Sound.c
// This module contains the SysTick ISR that plays sound
// Runs on LM4F120 or TM4C123
// Program written by: put your names here
// Date Created: 8/25/2014 
// Last Modified: 10/5/2014 
// Section 1-2pm     TA: Wooseok Lee
// Lab number: 6
// Hardware connections
// TO STUDENTS "REMOVE THIS LINE AND SPECIFY YOUR HARDWARE********

// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "dac.h"
#include "inc//tm4c123gh6pm.h"
#include "inc//systickints.h"

uint8_t sineWave[64] = 
{0x8,0x9,0xa,0xa,0xb,0xc,0xc,0xd,
0xe,0xe,0xf,0xf,0xf,0x10,0x10,0x10,
0x10,0x10,0x10,0x10,0xf,0xf,0xf,0xe,
0xe,0xd,0xc,0xc,0xb,0xa,0xa,0x9,
0x8,0x7,0x6,0x6,0x5,0x4,0x4,0x3,
0x2,0x2,0x1,0x1,0x1,0x0,0x0,0x0,
0x0,0x0,0x0,0x0,0x1,0x1,0x1,0x2,
0x2,0x3,0x4,0x4,0x5,0x6,0x6,0x7};

uint8_t current = 0;

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void); //Enable interrupts 

// **************Sound_Init*********************
// Initialize Systick periodic interrupts
// Called once, with sound initially off
// Input: interrupt period
//           Units to be determined by YOU
//           Maximum to be determined by YOU
//           Minimum to be determined by YOU
// Output: none
void Sound_Init(uint32_t period){
	current = 0;
	EnableInterrupts();
}


// **************Sound_Play*********************
// Start sound output, and set Systick interrupt period 
// Input: interrupt period
//           Units to be determined by YOU
//           Maximum to be determined by YOU
//           Minimum to be determined by YOU
//         input of zero disable sound output
// Output: none

void SysTick_Handler(void){
	DAC_Out(*(sineWave+current));
	if(++current > 63) current = 0;
}

void Sound_Play(uint32_t period){
	if(!period){ 
		DisableInterrupts();
		return;
	}
	SysTick_Init(period);   //needs adjustment
	EnableInterrupts();
	
	
}
