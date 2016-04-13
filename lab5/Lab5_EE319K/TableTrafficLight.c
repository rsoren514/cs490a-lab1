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
#include "tm4c123gh6pm.h"
#include "SysTick.h"
// ***** 2. Global Declarations Section *****

// FUNCTION PROTOTYPES: Each subroutine defined
volatile unsigned long delay1;
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
// Global Variables
int currentState = 1;

uint8_t states[24][10] = {
	{1,1,1,1,2,2,2,2,0x4C,2}, //0
	{3,3,3,3,4,4,4,4,0x4C,2}, //1
	{4,4,4,4,4,4,4,4,0x4C,2}, //2
	{5,5,5,5,6,6,6,6,0x4C,2}, //3
	{6,6,6,6,6,6,6,6,0x4C,2}, //4
	{7,0,7,7,8,8,8,8,0x4C,2}, //5
	{8,8,8,8,8,8,8,8,0x4C,2}, //6
	{9,9,9,9,10,10,10,10,0x54,2}, //7
	{19,19,10,10,19,19,10,10,0x54,2}, //8
	{11,11,11,11,12,12,12,12,0x61,2}, //9
	{12,12,12,12,12,12,12,12,0x61,2}, //10
	{13,13,13,13,14,14,14,14,0x61,2}, //11
	{14,14,14,14,14,14,14,14,0x61,2}, //12
	{15,15,15,15,16,16,16,16,0x61,2}, //13
	{16,16,16,16,16,16,16,16,0x61,2}, //14
	{17,17,9,17,19,19,19,19,0x61,2}, //15
	{18,18,18,18,18,18,18,18,0x61,2}, //16
	{0,0,0,0,19,19,19,19,0x62,2}, //17
	{19,19,19,19,19,19,19,19,0x62,2}, //18
	{20,20,20,20,20,20,20,20,0xA4,5}, //19
	{21,21,21,21,21,21,21,21,0x24,1}, //20
	{22,22,22,22,22,22,22,22,0x64,1}, //21
	{23,23,23,23,23,23,23,23,0x24,1}, //22
	{9,9,0,0,9,9,0,0,0x64,1}  //23
};
//000,001,010,011,100,101,110,111

uint8_t portEMask = 0x07;
uint8_t portFMask = 0x0A;
// ***** 3. Subroutines Section *****

int main(void){ 
  TExaS_Init(SW_PIN_PE210, LED_PIN_PB543210); // activate grader and set system clock to 80 MHz
	SYSCTL_RCGC2_R |= 0x32;
	delay1 = SYSCTL_RCGC2_R;
	
	GPIO_PORTB_DEN_R = 0x3F;
	GPIO_PORTB_DIR_R = 0x3F;
	
	GPIO_PORTE_DEN_R = portEMask;
	GPIO_PORTE_DIR_R &= ~portEMask;
	
	GPIO_PORTF_DEN_R = portFMask;
	GPIO_PORTF_DIR_R = portFMask;
	
	SysTick_Init();
  
  EnableInterrupts();
  
	while(1){
		GPIO_PORTB_DATA_R = states[currentState][8];
		GPIO_PORTF_DATA_R = 4+(states[currentState][8] >> 5);
		SysTick_Wait10ms((states[currentState][9]*5));
		
		currentState = states[currentState][(GPIO_PORTE_DATA_R & portEMask)];
  }
}
