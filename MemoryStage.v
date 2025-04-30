module MemoryStage(
    input clk,
	 input clkMem,
    input memWrite,
    input [31:0] aluResult,
    input [31:0] rs2Data,      // Data to write (for store)
    input [31:0] cycleCount,   // New input to log runtime
    output [31:0] memOut
);

    wire [31:0] memReadData;

//    dataMemory DM (
//        .address(aluResult),
//        .writeData(rs2Data),
//        .memWrite(memWrite),
//        .memRead(1'b1),         // Always read
//        .clk(clk),
//        .readData(memReadData),
//        .cycleCount(cycleCount) // Pass to memory for logging into mem[1]
//    );
	
	ram DM(
		.address(aluResult[9:2]), // word-aligned
		.clock(clkMem),
		.data(rs2Data),
		.wren(memWrite),
		.q(memReadData)
	);	

    assign memOut = memReadData;

endmodule
