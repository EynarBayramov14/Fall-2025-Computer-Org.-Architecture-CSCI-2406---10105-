.global _start
_start:
    @ --- Initialization ---
    
    @ Instruction 1: e3a01000 -> MOV r1, #0
    @ Initialize Register R1 to 0. 
    @ (Cond: AL, Op: Data, Cmd: MOV, Rd: 1, Imm: 0)
    mov r1, #0

    @ Instruction 2: e3a0200a -> MOV r2, #10
    @ Initialize Register R2 to 10 (0x0a). 
    @ (Cond: AL, Op: Data, Cmd: MOV, Rd: 2, Imm: 10)
    mov r2, #10

    @ Instruction 3: e3a03000 -> MOV r3, #0
    @ Initialize Register R3 to 0. 
    @ (Cond: AL, Op: Data, Cmd: MOV, Rd: 3, Imm: 0)
    mov r3, #0

    @ Instruction 4: e3a04005 -> MOV r4, #5
    @ Initialize Register R4 to 5. 
    @ (Cond: AL, Op: Data, Cmd: MOV, Rd: 4, Imm: 5)
    mov r4, #5

    @ --- Loop 1 Start ---
loop1:
    @ Instruction 5: e0535004 -> SUBS r5, r3, r4
    @ Subtract R4 from R3 and store in R5. Update Flags (S bit).
    @ (Cond: AL, Op: Data, Cmd: SUB, S: 1, Rn: 3, Rd: 5, Rm: 4)
    subs r5, r3, r4

    @ Instruction 6: b0800002 -> ADDLT r0, r0, r2
    @ If Less Than (LT), Add R2 to R0.
    @ (Cond: LT, Op: Data, Cmd: ADD, Rn: 0, Rd: 0, Rm: 2)
    addlt r0, r0, r2

    @ Instruction 7: b2833001 -> ADDLT r3, r3, #1
    @ If Less Than (LT), Add 1 to R3 (Increment counter).
    @ (Cond: LT, Op: Data, Cmd: ADD, Rn: 3, Rd: 3, Imm: 1)
    addlt r3, r3, #1

    @ Instruction 8: bafffffb -> BLT loop1
    @ Branch if Less Than (LT) back to loop1.
    @ (Cond: LT, Op: Branch, Offset: -5 instructions)
    blt loop1

    @ --- Transition ---
    
    @ Instruction 9: ebffffff -> BL next_instruction
    @ Branch with Link to the next line. Sets LR = PC + 4.
    @ (Cond: AL, Op: Branch, Link: Yes, Offset: -1 -> Next instruction)
    bl _next

_next:
    @ --- Loop 2 Start (The Crash Loop) ---
loop2:
    @ Instruction 10: e52de004 -> STR lr, [sp, #-4]!
    @ Store Link Register to Stack. Pre-index subtract 4 from SP. Write-back.
    @ CAUSE OF CRASH: This pushes to stack infinitely until overflow.
    @ (Cond: AL, Op: Memory, P: 1, U: 0, W: 1, L: 0, Rn: SP, Rd: LR)
    str lr, [sp, #-4]!

    @ Instruction 11: e3a0400f -> MOV r4, #15
    @ Move 15 into R4.
    @ (Cond: AL, Cmd: MOV, Rd: 4, Imm: 15)
    mov r4, #15

    @ Instruction 12: e3a0500a -> MOV r5, #10
    @ Move 10 into R5.
    @ (Cond: AL, Cmd: MOV, Rd: 5, Imm: 10)
    mov r5, #10

    @ Instruction 13: e0856004 -> ADD r6, r5, r4
    @ Add R5 and R4, store in R6.
    @ (Cond: AL, Cmd: ADD, Rn: 5, Rd: 6, Rm: 4)
    add r6, r5, r4

    @ Instruction 14: e0535004 -> SUBS r5, r3, r4
    @ Subtract R4 from R3, store in R5. Update Flags.
    @ (Matches Instruction 5)
    subs r5, r3, r4

    @ Instruction 15: eafffff9 -> B loop2
    @ Unconditional Branch back to loop2.
    @ (Cond: AL, Op: Branch, Offset: -7 instructions -> Jump to STR instruction)
    b loop2
