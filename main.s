;****************** main.s ***************
; Program initially written by: Yerraballi and Valvano
; Author: Anthony Do
; Date Created: 1/15/2018 
; Last Modified: 1/17/2021 
; Brief description of the program: Solution to Lab1
; The objective of this system is to implement odd-bit counting system
; Hardware connections: 
;  Output is positive logic, 1 turns on the LED, 0 turns off the LED
;  Inputs are negative logic, meaning switch not pressed is 1, pressed is 0
;    PE0 is an input 
;    PE1 is an input 
;    PE2 is an input 
;    PE4 is the output
; Overall goal: 
;   Make the output 1 if there is an even number of switches pressed, 
;     otherwise make the output 0

; The specific operation of this system 
;   Initialize Port E to make PE0,PE1,PE2 inputs and PE4 an output
;   Over and over, read the inputs, calculate the result and set the output
; PE2  PE1 PE0  | PE4
; 0    0    0   |  0    3 switches pressed, odd 
; 0    0    1   |  1    2 switches pressed, even
; 0    1    0   |  1    2 switches pressed, even
; 0    1    1   |  0    1 switch pressed, odd
; 1    0    0   |  1    2 switches pressed, even
; 1    0    1   |  0    1 switch pressed, odd
; 1    1    0   |  0    1 switch pressed, odd
; 1    1    1   |  1    no switches pressed, even
;There are 8 valid output values for Port E: 0x00,0x11,0x12,0x03,0x14,0x05,0x06, and 0x17. 

; NOTE: Do not use any conditional branches in your solution. 
;       We want you to think of the solution in terms of logical and shift operations

GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_DEN_R   EQU 0x4002451C
SYSCTL_RCGCGPIO_R  EQU 0x400FE608

       THUMB
       AREA    DATA, ALIGN=2
;global variables go here
      ALIGN
      AREA    |.text|, CODE, READONLY, ALIGN=2
      EXPORT  Start
Start
     ;code to run once that initializes PE4,PE2,PE1,PE0
	;A. Turn on the clock on port E
	LDR R0, =SYSCTL_RCGCGPIO_R ;read
	LDRB R1, [R0]
	ORR R1, #0x10 ;modify
	STRB R1, [R0]
	;B. Wait for clock to stabalize
	NOP 
	NOP
	;C. Define Input and output (DIR)
	LDR R0, =GPIO_PORTE_DIR_R
	LDRB R1, [R0]
	AND R1, #0xF8
	ORR R1, #0x10
	STRB R1, [R0]
	;D. Digitally enable pins (DEN)
	LDR R0, =GPIO_PORTE_DEN_R
	LDRB R1, [R0]
	ORR R1, #0x17
	STRB R1, [R0]
loop
      ;code that runs over and over
	;Load Port E data using GPIO
	LDR R0, =GPIO_PORTE_DATA_R
	LDRB R1, [R0]
	;Isolate bits we care about by using AND ops
	AND R2, R1, #0x01
	AND R3, R1, #0x02
	;Logically shift for isolated bits to format for EOR
	LSR R3, #1
	AND R4, R1, #0x04
	LSR R4, #2
	;EOR for odd/even outputs
	EOR R2, R2, R3
	EOR R2, R2, R4
	LSL R2, #4
	;Put the result/output to the LED (PE4)
	STRB R2, [R0]
    B    loop

    
    ALIGN        ; make sure the end of this section is aligned
    END          ; end of file
          