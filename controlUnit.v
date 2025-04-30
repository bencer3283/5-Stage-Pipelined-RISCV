module controlUnit(
	input [6:0] opcode,                  // Opcode field from instruction
	input [2:0] func3,                   // func3 field from instruction
	input [6:0] func7,                   // func7 field from instruction
	output reg BR, memToReg, memWrite,  // Branch flag, memory read flag, memory write flag
	output reg ALUSrc, regWrite,        // ALU source mux, register write enable
	output reg PCToReg, aluToPC,        // PC+4 to register (for jal/jalr), aluResult to PC (for jalr)
	output reg halt,                    // Custom halt instruction
	output reg [2:0] ALUOp              // ALU operation control
);

initial begin
	halt = 0;
end

always @* begin
	// Decode based on opcode
	if(opcode == 7'b0110011) begin // R-type: ADD, SUB, MUL, AND, OR, SLL
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b0, 1'b0, 1'b0, 1'b0, 1'b1, 1'b0, 1'b0, 1'b0};
		
		// Determine ALUOp based on func3 & func7
		if(func3 == 3'b000) begin
			case(func7)
				7'b0000000: ALUOp = 3'b000; // ADD
				7'b0100000: ALUOp = 3'b001; // SUB
				7'b0000001: ALUOp = 3'b010; // MUL
				default:    ALUOp = 3'bxxx;
			endcase
		end
		else if(func3 == 3'b111) ALUOp = 3'b011; // AND
		else if(func3 == 3'b110) ALUOp = 3'b100; // OR
		else if(func3 == 3'b001) ALUOp = 3'b101; // SLL
		else ALUOp = 3'bxxx;
	end

	else if(opcode == 7'b0010011) begin // I-type: ADDI, SLLI
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0};
		
		case(func3)
			3'b000: ALUOp = 3'b000; // ADDI
			3'b001: ALUOp = 3'b101; // SLLI
			default: ALUOp = 3'bxxx;
		endcase
	end

	else if(opcode == 7'b0000011) begin // LW
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b0, 1'b1, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0};
		ALUOp = 3'b000; // ADD to calculate address
	end

	else if(opcode == 7'b0100011) begin // SW
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0, 1'b0, 1'b0};
		ALUOp = 3'b000; // ADD to calculate address
	end

	else if(opcode == 7'b1100011) begin // Branch: BEQ, BNE
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
		ALUOp = 3'b001; // SUB to compare for BEQ/BNE
	end

	else if(opcode == 7'b1101111) begin // JAL
		// Write PC+4 to rd, jump to PC + imm
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b1, 1'b0, 1'b0, 1'b0, 1'b1, 1'b1, 1'b0, 1'b0};
		ALUOp = 3'bxxx; // ALUOp not used
	end

	else if(opcode == 7'b1100111) begin // JALR
		// Write PC+4 to rd, jump to rs1 + imm
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b1, 1'b0, 1'b0, 1'b1, 1'b1, 1'b1, 1'b1, 1'b0};
		ALUOp = 3'b000; // ADD rs1 + imm
	end

	else if(opcode == 7'b1111111) begin // Custom HALT instruction
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b1};
		ALUOp = 3'bxxx; // Not needed
	end

	else begin // Unknown instruction
		{BR, memToReg, memWrite, ALUSrc, regWrite, PCToReg, aluToPC, halt} = 
            {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
		ALUOp = 3'bxxx; // Unknown operation
	end
end

endmodule
