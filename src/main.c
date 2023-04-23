#include <avr/io.h>
#include <avr/cpufunc.h>
#include <util/delay.h>
#include "uart.h"
int main(){
    DDRB |= 1<<PB1;
    PORTB &= ~(1<<PB1);
    while(1){
        #ifdef DEBUG
        PORTB ^= (1<<PB1);
        _delay_ms(1000);
        
        #endif
    }
}