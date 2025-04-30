module ExecuteStage(
    input [31:0] rs1Data,           // Register source 1
    input [31:0] rs2Data,           // Register source 2
    input [31:0] imm,               // Immediate value (from decode stage)
    input [31:0] PC_in,             // PC at current stage
    input [2:0] ALUOp,              // ALU control from control unit
    input ALUSrc,                   // Whether to use immediate or reg2 for operandB
	 input ALUToPC,
    input [1:0] forwardA, forwardB, // Forwarding control signals
    input [31:0] forwardDataMEM,    // Data from MEM stage for forwarding
    input [31:0] forwardDataWB,     // Data from WB stage for forwarding
    output [31:0] aluResult,        // ALU computation result
    output [31:0] branchTarget,    // PC + imm result, used for jump/branch targets
    output [31:0] operandB_raw_out, // Raw operandB for use in MEM stage
    output zero                     // NEW: zero flag for branch decision
);

    reg [31:0] operandA, operandB_raw;
    wire [31:0] operandB, PCPlusImm;
	 
	 

    // -------------------- Forwarding Logic --------------------
    // Select operandA based on forwardA signal
    always @* begin
        case (forwardA)
            2'b00: operandA = rs1Data;
            2'b10: operandA = forwardDataMEM;
            2'b01: operandA = forwardDataWB;
            default: operandA = rs1Data;
        endcase

        case (forwardB)
            2'b00: operandB_raw = rs2Data;
            2'b10: operandB_raw = forwardDataMEM;
            2'b01: operandB_raw = forwardDataWB;
            default: operandB_raw = rs2Data;
        endcase
    end

    // -------------------- ALU Operand B Selection --------------------
    assign operandB = ALUSrc ? imm : operandB_raw;  // Choose imm or register value
    assign operandB_raw_out = operandB_raw;         // Pass raw B operand to MEM stage

    // -------------------- Branch Target Address --------------------
    assign PCPlusImm = PC_in + (imm << 1);  // Used by jal, branch, jalr
	 assign branchTarget = ALUToPC ? aluResult : PCPlusImm;

    // -------------------- ALU Execution --------------------
    alu ALU (
        .A(operandA),
        .B(operandB),
        .ALUOp(ALUOp),
        .result(aluResult),
        .zero(zero) // NEW: needed for beq/bne branch control
    );

endmodule
