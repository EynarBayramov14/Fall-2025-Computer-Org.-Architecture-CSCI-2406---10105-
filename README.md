# Homework 2: Reverse Engineering Report

## Methodology

The decoding process utilized the ARM32 instruction formats defined in the class lecture notes. The instructions were identified by analyzing the **Opcode (op)** field (bits 27:26) :

* **00**: Data-processing instructions.


* **01**: Memory instructions (LDR/STR).


* **10**: Branch instructions.



Each instruction was then broken down into its binary fields (`cond`, `funct`, `Rn`, `Rd`, `Src2`, etc.) to determine the operation, registers, and immediate values.

---

## Detailed Instruction Decoding

### 1. `e3a01000`

* **Binary**: `1110 00 1 1101 0 0000 0001 000000000000`

* **Analysis**:

  **Cond (31:28)**: `1110` = **AL** (Always).

  **Op (27:26)**: `00` = Data Processing.

  **I (25)**: `1` = Operand 2 is an **Immediate**.

  **Cmd (24:21)**: `1101` = **MOV** (Move).

  **S (20)**: `0` = Do not update flags.

  **Rn (19:16)**: `0000` (Ignored for MOV).

  **Rd (15:12)**: `0001` = **R1**.

  **Src2 (11:0)**: `0000 00000000` = Immediate **0**.

* **Assembly**: `MOV r1, #0`

### 2. `e3a0200a`

* **Binary**: `1110 00 1 1101 0 0000 0010 000000001010`

* **Analysis**:

 **Cond**: `1110` (AL).

 **Op**: `00` (Data).

 **Cmd**: `1101` (MOV).

 **Rd**: `0010` (**R2**).

 **Src2**: `0000 00001010` = Immediate **10** (0xA).


* **Assembly**: `MOV r2, #10`

### 3. `e3a03000`

* **Binary**: `1110 00 1 1101 0 0000 0011 000000000000`

* **Analysis**:

 **Cond**: `1110` (AL). 
 
 **Cmd**: `1101` (MOV). 
 
 **Rd**: `0011` (**R3**).

 **Src2**: Immediate **0**.


* **Assembly**: `MOV r3, #0`

### 4. `e3a04005`

* **Binary**: `1110 00 1 1101 0 0000 0100 000000000101`

* **Analysis**:

 **Cond**: `1110` (AL).

 **Cmd**: `1101` (MOV).

 **Rd**: `0100` (**R4**).

 **Src2**: Immediate **5**.


* **Assembly**: `MOV r4, #5`

### 5. `e0535004`

* **Binary**: `1110 00 0 0010 1 0011 0101 000000000100`

* **Analysis**:

 **Cond**: `1110` (AL).

 **Op**: `00` (Data).
 
 **I (25)**: `0` = Operand 2 is a **Register**.
 
 **Cmd (24:21)**: `0010` = **SUB**.
 
 **S (20)**: `1` = Set Condition Flags (Append 'S').

 **Rn (19:16)**: `0011` = **R3** (1st Source).

 **Rd (15:12)**: `0101` = **R5** (Destination).

 **Src2 (11:0)**: `000000000100` -> **Rm**=`0100` (**R4**) (Shift=0).


* **Assembly**: `SUBS r5, r3, r4`

### 6. `b0800002`

* **Binary**: `1011 00 0 0100 0 0000 0000 000000000010`

* **Analysis**:

 **Cond (31:28)**: `1011` = **LT** (Less Than).

 **Op**: `00` (Data).

 **Cmd**: `0100` = **ADD**.

 **S**: `0` (No flag update).

 **Rn**: `0000` (**R0**). **Rd**: `0000` (**R0**).

 **Src2**: `0000...0010` = **Rm**=`0010` (**R2**).


* **Assembly**: `ADDLT r0, r0, r2`

### 7. `b2833001`

* **Binary**: `1011 00 1 0100 0 0011 0011 000000000001`

* **Analysis**:

 **Cond**: `1011` (**LT**).

 **I (25)**: `1` (Immediate).

 **Cmd**: `0100` = **ADD**.

 **Rn**: `0011` (**R3**). **Rd**: `0011` (**R3**).

 **Src2**: Immediate **1**.


* **Assembly**: `ADDLT r3, r3, #1`

### 8. `bafffffb`

* **Binary**: `1011 10 10 111111111111111111111011`
* **Analysis**:

 **Cond**: `1011` (**LT**).

 **Op (27:26)**: `10` = Branch Instruction.

 **Funct (25:24)**: `10` -> L=`0` = **B** (Branch).
 
 **Imm24**: `0xFFFFFB`.
 
  This is a negative number (starts with 1).
  
  Sign-extended value: -5.
  
  Branch Target Address = (PC + 8) + (-5 × 4) = PC - 12 bytes.
  
  This jumps back 3 instructions (to `SUBS`).



* **Assembly**: `BLT loop1`

### 9. `ebffffff`

* **Binary**: `1110 10 11 111111111111111111111111`

* **Analysis**:

 **Cond**: `1110` (AL).

 **Op**: `10` (Branch).

 **Funct (25:24)**: `11` -> L=`1` = **BL** (Branch with Link).

 **Imm24**: `0xFFFFFF` (-1).

 Target = (PC + 8) + (-1 × 4) = PC + 4.

 This branches to the very next instruction but sets the LR (Link Register).


* **Assembly**: `BL next_instruction`

### 10. `e52de004`

* **Binary**: `1110 01 0 1 0 0 1 0 1101 1110 000000000100`
* **Analysis**:

 **Cond**: `1110` (AL).

 **Op (27:26)**: `01` = Memory Instruction.

 **I-bar (25)**: `0` = Immediate Offset.

 **P (24)**: `1` = **Pre-index** addressing.

 **U (23)**: `0` = **Subtract** offset (Down).

 **B (22)**: `0` = Word transfer.

 **W (21)**: `1` = **Write-back** enabled (`!`).

 **L (20)**: `0` = **STR** (Store).

 **Rn (19:16)**: `1101` = **SP** (Stack Pointer/R13).

 **Rd (15:12)**: `1110` = **LR** (Link Register/R14).

 **Src2 (11:0)**: `000000000100` = Immediate **4**.

* **Assembly**: `STR lr, [sp, #-4]!`

### 11. `e3a0400f`

* **Binary**: `1110 00 1 1101 0 0000 0100 000000001111`

* **Analysis**:

 **Cmd**: `1101` (MOV).

 **Rd**: `0100` (**R4**).

 **Src2**: Immediate **15** (0xF).

* **Assembly**: `MOV r4, #15`

### 12. `e3a0500a`

* **Binary**: `1110 00 1 1101 0 0000 0101 000000001010`

* **Analysis**:

 **Cmd**: `1101` (MOV).

 **Rd**: `0101` (**R5**).

 **Src2**: Immediate **10** (0xA).


* **Assembly**: `MOV r5, #10`

### 13. `e0856004`

* **Binary**: `1110 00 0 0100 0 0101 0110 000000000100`

* **Analysis**:

 **Op**: `00` (Data).

 **Cmd**: `0100` = **ADD**.

 **S**: `0` (No flags).

 **Rn**: `0101` (**R5**).

 **Rd**: `0110` (**R6**).

 **Src2**: Rm=`0100` (**R4**).


* **Assembly**: `ADD r6, r5, r4`

### 14. `e0535004`

* **Binary**: `1110 00 0 0010 1 0011 0101 000000000100`

* **Analysis**:

 Matches Instruction 5 exactly.


* **Assembly**: `SUBS r5, r3, r4`

### 15. `eafffff9`

* **Binary**: `1110 10 10 111111111111111111111001`

* **Analysis**:

 **Cond**: `1110` (AL).

 **Op**: `10` (Branch).

 **Funct**: `10` = **B** (Branch).

 **Imm24**: `0xFFFFF9` (-7).
 
 Target = (PC + 8) + (-7 × 4) = PC - 20 bytes.
 
 This jumps back 5 instructions to address `0x24` (Instruction 10, the `STR` instruction).


* **Assembly**: `B loop2`




## Logical Reconstruction of the Program

The reverse-engineered assembly reveals a program structured into two distinct loops. The first loop performs a calculation based on a comparison, while the second loop is an infinite loop that leads to a system crash.

### 1. Loop 1: The "Count Up" Loop

The program begins by initializing registers `R1` through `R4`.

* **Initialization**: `R3` is set to `0` and `R4` is set to `5`.
* **Comparison**: The instruction `SUBS r5, r3, r4` subtracts `R4` (5) from `R3` (starts at 0). Because the `S` bit is set, this updates the **CPSR flags** (Negative, Zero, etc.).
* **Branch Logic**: The instruction `BLT loop1` (Branch Less Than) checks the flags set by the `SUBS` instruction.

     * As long as `R3 < R4`, the result is negative, and the program branches back to the start of the loop.

     * Inside the loop, `ADDLT r3, r3, #1` increments `R3` by 1.


* **Termination**: The loop continues until `R3` reaches 5. At that point, `5 - 5 = 0`. The result is no longer "Less Than" (it is Equal), so the `BLT` branch is not taken, and execution proceeds.

### 2. The Transition

* The instruction `BL next_instruction` is a **Branch with Link**. It jumps to the next line of code but crucially stores the address of the *following* instruction into the Link Register (`LR`).



### 3. Loop 2: The "Crash" Loop

The program enters a second label (which I have named `loop2` or `_next`).

* **Infinite Loop**: The final instruction `B loop2` is an unconditional branch that jumps back to the start of this second loop. There is no exit condition for this loop.



### 4. Reason for the Crash

The specific cause of the crash is a **Stack Overflow** leading to a memory access violation.

1. **The Faulty Instruction**: `STR lr, [sp, #-4]!`.


   * This is a **Store Register** instruction using **Pre-indexed** addressing with **Write-back** (`!`).


   * It subtracts 4 from the **Stack Pointer (SP)** and then stores the Link Register (`LR`) value at that new location.


2. **The Mechanism**: Because this instruction is inside the infinite `loop2`:
   * The loop executes the `STR` instruction repeatedly.
   * Every iteration decrements the address in `SP` by 4 bytes.
   * The stack grows downwards endlessly in memory.


3. **The Crash**: Eventually, the Stack Pointer value becomes so low that it crosses out of the valid RAM allocated for the stack and attempts to write into a restricted memory region (such as the Interrupt Controller or unmapped memory). This triggers a hardware fault, causing the simulator to halt with an error.
