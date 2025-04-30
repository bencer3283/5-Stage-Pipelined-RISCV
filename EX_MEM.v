module EX_MEM(
    input clk,
    input reset,
    input [31:0] aluResult_in,
    input [31:0] rs2Data_in,
	 input [31:0] pc_in,
    input [4:0] rd_in,
    input memWrite_in, memToReg_in, regWrite_in, PCToReg_in,
    output reg [31:0] aluResult_out,
    output reg [31:0] rs2Data_out,
	 output reg [31:0] pc_out,
    output reg [4:0] rd_out,
    output reg memWrite_out, memToReg_out, regWrite_out, PCToReg_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        aluResult_out <= 0;
        rs2Data_out <= 0;
        rd_out <= 0;
        memWrite_out <= 0;
        memToReg_out <= 0;
        regWrite_out <= 0;
		  PCToReg_out <= 0;
		  pc_out <= 0;
    end else begin
        aluResult_out <= aluResult_in;
        rs2Data_out <= rs2Data_in;
        rd_out <= rd_in;
        memWrite_out <= memWrite_in;
        memToReg_out <= memToReg_in;
        regWrite_out <= regWrite_in;
		  PCToReg_out <= PCToReg_in;
		  pc_out <= pc_in;
    end
end

endmodule
