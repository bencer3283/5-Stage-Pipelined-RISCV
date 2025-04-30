# 5-Stage Pipelined RISC-V Processor

This repository contains an implementation of a 5-stage pipelined RISC-V processor. The processor is designed with a classic RISC pipeline architecture consisting of instruction fetch, instruction decode, execute, memory access, and write-back stages, along with hazard detection and data forwarding capabilities.

## Architecture Overview

The processor implements a 5-stage pipeline architecture:

1. **Instruction Fetch (IF)**: Fetches the next instruction from instruction memory using the current program counter (PC).
2. **Instruction Decode (ID)**: Decodes the instruction, reads register operands, and generates control signals.
3. **Execute (EX)**: Performs ALU operations, calculates branch targets, and resolves branch conditions.
4. **Memory (MEM)**: Accesses data memory for load and store operations.
5. **Write Back (WB)**: Writes results back to the register file.

Each stage is separated by pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB) to hold intermediate values between pipeline stages.

## Supported Instructions

The processor supports the following RISC-V instructions:

### R-type Instructions
- **ADD**: Addition (rd = rs1 + rs2)
- **SUB**: Subtraction (rd = rs1 - rs2)
- **MUL**: Multiplication (rd = rs1 * rs2)
- **AND**: Bitwise AND (rd = rs1 & rs2)
- **OR**: Bitwise OR (rd = rs1 | rs2)
- **SLL**: Shift Left Logical (rd = rs1 << rs2)

### I-type Instructions
- **ADDI**: Add Immediate (rd = rs1 + imm)
- **SLLI**: Shift Left Logical Immediate (rd = rs1 << imm)
- **LW**: Load Word (rd = Memory[rs1 + imm])

### S-type Instructions
- **SW**: Store Word (Memory[rs1 + imm] = rs2)

### B-type Instructions
- **BEQ**: Branch if Equal (if rs1 == rs2, PC += imm)
- **BNE**: Branch if Not Equal (if rs1 != rs2, PC += imm)

### J-type Instructions
- **JAL**: Jump and Link (rd = PC+4; PC += imm)
- **JALR**: Jump and Link Register (rd = PC+4; PC = rs1 + imm)

### Special Instructions
- **HALT**: Custom instruction to stop execution (opcode: 7'b1111111)

## Pipeline Hazard Handling

The processor implements several mechanisms to handle pipeline hazards:

### Data Hazards
1. **Forwarding Unit**: Detects and resolves data dependencies by forwarding results from later pipeline stages back to the Execute stage when needed.
   - Forwards data from MEM stage to EX stage
   - Forwards data from WB stage to EX stage

2. **Hazard Detection Unit**: Detects load-use hazards (when an instruction depends on the result of a load instruction immediately before it) and stalls the pipeline as needed.

### Control Hazards
1. **Branch Prediction**: The processor uses a simple scheme where branches are resolved in the Execute stage.
2. **Pipeline Flushing**: When a branch is taken, the processor flushes the instructions in the pipeline that were fetched after the branch.
3. **Branch Target Calculation**: The branch target is calculated in the Execute stage.

## Implementation Details

### Key Components
- **ALU**: Supports operations such as ADD, SUB, MUL, AND, OR, and SLL
- **Register File**: 32 x 32-bit registers
- **Instruction Memory**: Stores the program instructions
- **Data Memory**: Stores data for load/store operations
- **Control Unit**: Generates control signals based on instruction opcode
- **Forwarding Unit**: Detects and resolves data hazards
- **Hazard Detection Unit**: Detects situations requiring pipeline stalls
- **Immediate Generator**: Generates immediate values from instruction fields
- **Pipeline Registers**: Store data between pipeline stages

### Performance Monitoring
- A cycle counter tracks the number of clock cycles during program execution

## Design Goals
This implementation aims to balance performance with hardware complexity by including essential features of modern processor design:
- Full forwarding paths to minimize stalls
- Early branch resolution to reduce control hazard penalties
- Clean separation of pipeline stages for maintainability
- Comprehensive instruction support for a variety of programs

This pipelined design allows for higher throughput compared to a single-cycle processor, as multiple instructions can be processed simultaneously in different pipeline stages.