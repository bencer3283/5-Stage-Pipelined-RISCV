module InstructionFetchStage(
    input clk,
    input reset,
	 input stall,
    input branchTaken,              // From branch logic in EX/MEM (e.g. BEQ, BNE resolved)
    //input aluToPC,                  // From control signal (for jalr, aluResult becomes new PC)
    input halt,                     // From control signal (halts PC update)
    input [31:0] branchTarget,      // From branch logic in EX (used for BEQ/BNE target)
    input [31:0] aluResult,         // From EX stage (used for jalr PC target)
    output reg [31:0] PC_out,       // Current PC value, sent to IF/ID
    output [31:0] instruction_out  // Fetched instruction
    //output flush                    // NEW: triggers IF/ID flush on branch or jump
);

    // Internal PC computation wires
    wire [31:0] PCPlusFour = PC_out + 32'd4;  // Normal PC increment
    wire [31:0] nextPC;                       // Selected next PC
    wire isHaltInstruction;                   // Internal signal to detect halt instruction

    // ------------------ Instruction Memory ------------------ //
    instructionMemory IM (
        .PC(PC_out),               // Use current PC to fetch instruction
        .ins(instruction_out)      // Output instruction
    );

    // ------------------ Decode if Current Instruction is HALT ------------------ //
    assign isHaltInstruction = (instruction_out[6:0] == 7'b1111111);
//	 assign bn = (instruction 14:12) == 

    // ------------------ Compute Next PC Based on Control Flow ------------------ //
    assign nextPC = branchTaken == 1'b1 ? branchTarget :  // For branches
                    //aluToPC == 1'b1     ? aluResult     :  // For jalr
                                          PCPlusFour;      // Default increment

    // ------------------ Output Flush Signal ------------------ //
    // This flushes IF/ID when we take a branch or jump (jal, jalr)
    // assign flush = branchTaken || aluToPC;

    // ------------------ Sequential PC Register Update ------------------ //
    always @(posedge clk or posedge reset) begin
        if (reset)
            PC_out <= 32'd0;              // Reset PC to 0
			else if(branchTaken)
				PC_out <= nextPC;
        else if (!halt && !isHaltInstruction && !stall)
            PC_out <= nextPC;             // Update PC unless halted
        // Else: hold PC on halt
    end
	 
	 // initialize pc so that testbench can run
	initial begin
		PC_out = 32'd0;
	end

endmodule
