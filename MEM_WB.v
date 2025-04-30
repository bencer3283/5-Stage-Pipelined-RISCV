module MEM_WB(
    input clk,
    input reset,
    input [31:0] memData_in,
    input [31:0] aluResult_in,
    input [4:0] rd_in,
    input memToReg_in, regWrite_in,
    output reg [31:0] memData_out,
    output reg [31:0] aluResult_out,
    output reg [4:0] rd_out,
    output reg memToReg_out, regWrite_out
);

initial begin
	memData_out = 0;
	aluResult_out = 0;
	rd_out = 0;
	memToReg_out = 0;
	regWrite_out = 0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        memData_out <= 0;
        aluResult_out <= 0;
        rd_out <= 0;
        memToReg_out <= 0;
        regWrite_out <= 0;
    end else begin
        memData_out <= memData_in;
        aluResult_out <= aluResult_in;
        rd_out <= rd_in;
        memToReg_out <= memToReg_in;
        regWrite_out <= regWrite_in;
    end
end

endmodule
