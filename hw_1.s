.global _start         

_start:
    MOV     r0, #3          // starting value m
    MOV     r1, #8          // our upper bound n
    MOV     r2, #0          // result, sum
    MOV     r3, #4          // bytes per word

    
    MOV     r4, #-20        // compute offset

    LDR     r5, =LOOP       // load adress of the label
    MOV     pc, r5          // control transfer

LOOP:
    ADD     r2, r2, r0      // accumulate starting value 
    ADD     r0, r0, #1      // we'll consider the next integer the next time

    CMP     r0, r1          // compare staring m and n. m<=n
    ADDLE   r5, pc, r4      //compute adress for the next loop
    MOVLE   pc, r5          // brancing

END:
    B       END
	
	 // 1st loop visit: r2=3, r0=4
	 // 2nd loop visit: r2=7, r0=5
	 // 3rd loop visit: r2=12, r0=6
	 // 4th loop visit: r2=18, r0=7
	 // 5th loop visit: r2=25, r0=8
	 // 6th loop visit: r2=33, r0=9  which shows LE is wrong and we continue with END
	 
