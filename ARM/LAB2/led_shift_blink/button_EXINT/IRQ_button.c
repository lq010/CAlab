#include "button.h"
#include "lpc17xx.h"

char temp_led = 0x08; //LED8 ON at reset

void EINT0_IRQHandler (void)	  
{
	temp_led = 0x08;
	LPC_GPIO2->FIOPIN = temp_led;
  LPC_SC->EXTINT |= (1 << 0);     /* clear pending interrupt         */
}


void EINT1_IRQHandler (void)	  
{
	if(temp_led != 0x80){ //otherwise overflow of the 1 bit
		temp_led = temp_led << 1;
		LPC_GPIO2->FIOPIN = temp_led;
	}
	LPC_SC->EXTINT |= (1 << 1);     /* clear pending interrupt         */
}

void EINT2_IRQHandler (void)	  
{
	if(temp_led != 0x01){
		temp_led = temp_led >> 1;
		LPC_GPIO2->FIOPIN = temp_led;
	}
  LPC_SC->EXTINT |= (1 << 2);     /* clear pending interrupt         */    
}


