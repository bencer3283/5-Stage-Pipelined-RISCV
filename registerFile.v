

////////REGISTER FILE /////////////////////
module registerFile(
    input [4:0] rs1, rs2, rd,      // Register addresses
    input [31:0] writeData,        // Data to write
    input regWrite,                // Write enable
    input clk,                     // Clock
    output reg [31:0] readData1, readData2  // Read data
);

reg [31:0] RF[0:31];  // 32 registers, each 32 bits wide


// combinational read with internal register forwarding
always @* begin
	if(!regWrite) begin
		readData1 = RF[rs1];
	end else if(rd == rs1 && rd != 5'd0) begin
		readData1 = writeData;
	end else readData1 = RF[rs1];
	
	if(!regWrite) begin
		readData2 = RF[rs2];
	end else if(rd == rs2 && rd != 5'd0) begin
		readData2 = writeData;
	end else readData2 = RF[rs2];
end

// Write logic. Sequential on negative clk edge
always @(posedge clk) begin
    if (regWrite && rd != 5'b0)  // Prevent writing to x0 (always 0)
        RF[rd] <= writeData;
end

// Ensure x0 is always 0 // TO-DO: initialize all register
initial begin
   RF[0] = 32'd0;
	RF[10] = 32'd0;
	RF[11] = 32'd0;
	RF[1] = 32'd0;
	RF[2] = 32'd1023;
end

endmodule