module HazardDetectionUnit(
    input [4:0] ID_rs1, ID_rs2,    // Source regs in Decode
    input [4:0] EX_rd,             // Dest reg in Execute
    input EX_memRead,             // Is current EX instruction a load?
	 input branchTaken,
    output reg stall
);

initial begin
	stall = 1'b0;
end

always @(*) begin
    if (EX_memRead && ((EX_rd == ID_rs1) || (EX_rd == ID_rs2))) begin
        stall = 1'b1;  // Hazard detected
    end 
	 else if(branchTaken) begin
		stall = 1'b1;
	end else begin
        stall = 1'b0;
    end
end

endmodule