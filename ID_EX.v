module ID_EX(
    input clk,
    input reset,
    input stall, // for future use, optional
    // Inputs from ID stage
    input [31:0] PC_in,
    input [31:0] rs1Data_in,
    input [31:0] rs2Data_in,
    input [31:0] imm_in,
    input [4:0] rs1_in, rs2_in, rd_in,
    input [2:0] ALUOp_in,
    input memWrite_in, memToReg_in, regWrite_in, ALUSrc_in,
    input BR_in, bne_in, PCToReg_in, aluToPC_in, // New control signals added
    // Outputs to EX stage
    output reg [31:0] PC_out,
    output reg [31:0] rs1Data_out,
    output reg [31:0] rs2Data_out,
    output reg [31:0] imm_out,
    output reg [4:0] rs1_out, rs2_out, rd_out,
    output reg [2:0] ALUOp_out,
    output reg memWrite_out, memToReg_out, regWrite_out, ALUSrc_out,
    output reg BR_out, bne_out, PCToReg_out, aluToPC_out //  Corresponding outputs
);

initial begin
	BR_out = 1'b0;
	aluToPC_out = 1'b0;
	ALUOp_out = 3'b000;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        PC_out <= 0;
        rs1Data_out <= 0;
        rs2Data_out <= 0;
        imm_out <= 0;
        rs1_out <= 0;
        rs2_out <= 0;
        rd_out <= 0;
        ALUOp_out <= 0;
        memWrite_out <= 0;
        memToReg_out <= 0;
        regWrite_out <= 0;
        ALUSrc_out <= 0;
        BR_out <= 0; //  reset value
        PCToReg_out <= 0; //  reset value
        aluToPC_out <= 0; //  reset value
		  bne_out <= 0;
    end else begin
        PC_out <= PC_in;
        rs1Data_out <= rs1Data_in;
        rs2Data_out <= rs2Data_in;
        imm_out <= imm_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out <= rd_in;
        ALUOp_out <= ALUOp_in;
        memWrite_out <= memWrite_in;
        memToReg_out <= memToReg_in;
        regWrite_out <= regWrite_in;
        ALUSrc_out <= ALUSrc_in;
        BR_out <= BR_in; //  propagate control
        PCToReg_out <= PCToReg_in; // propagate control
        aluToPC_out <= aluToPC_in; //  propagate control
		  bne_out <= bne_in;
    end
end

endmodule
