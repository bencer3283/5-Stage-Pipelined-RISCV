module instructionMemory(
    input [31:0] PC,
    output reg [31:0] ins
);

reg [31:0] memory[0:1023];  // 4KB instruction memory

always @* begin
    ins = memory[PC[11:2]];  // Word-aligned fetch
end

initial begin
	$monitor("instruction q: %h %b", ins, ins);
	// double data hazard
//	memory[0] = 32'h00000033; // noop add x0, x0, x0
//	memory[1] = 32'h00500513; // addi a0, x0, 5
//	memory[2] = 32'h00650513; // addi a0, a0, 6
//	memory[3] = 32'h00750513; // addi a0, a0, 7
//	memory[4] = 32'h00850513; // addi a0, a0, 8
//	memory[5] = 32'h00a02223; // sw a0, 4(x0)
//	memory[6] = 32'hffffffff;
	// load use hazard
//	memory[0] = 32'h00000033; // noop
//	memory[1] = 32'h00000033; // noop
//	memory[2] = 32'h00002503; // lw a0, 0(x0)
//	memory[3] = 32'h000505b3; // add a1, a0, x0
//	memory[4] = 32'h00b02223; // sw a1, 4(x0)
//	memory[5] = 32'hffffffff;
	// IRF test
//	memory[0] = 32'h00000033; // noop
//	memory[1] = 32'h00000033; // noop
//	memory[2] = 32'h00500513; // addi a0, x0, 5
//	memory[3] = 32'h00000033; // noop
//	memory[4] = 32'h00000033; // noop
//	memory[5] = 32'h00a02223; // sw a0, 4(x0)
//	memory[6] = 32'hffffffff;
	// branch and jump
//	memory[0] = 32'h00000033; // noop
//	memory[1] = 32'h00002503; // lw a0, 0(x0)
//	memory[2] = 32'h00100593; // addi a1, x0, 1
//	memory[3] = 32'h00b51663; // bne a0, a1, 12
//	memory[4] = 32'h00000223; // sw x0, 4(x0)
//	memory[5] = 32'h008000ef; // jal ra, 8
//	memory[6] = 32'h00a02223; // sw a0, 4(x0)
//	memory[7] = 32'hffffffff;
	
	// Test program 2
//	memory[0] = 32'h00800293;
//	memory[1] = 32'h00800293;
//	memory[2] = 32'h00F00313; 
//	memory[3] = 32'h0062A023; 
//	memory[4] = 32'h005303B3; 
//	memory[5] = 32'h40530E33; 
//	memory[6] = 32'h03C384B3; 
//	memory[7] = 32'h00428293; 
//	memory[8] = 32'hFFC2A903; 
//	memory[9] = 32'h41248933; 
//	memory[10] = 32'h00291913;
//	memory[11] = 32'h0122A023;
//	memory[12] = 32'h0000007F;
//	// Test program 3
	memory[0] = 32'h00000033;
	memory[1] = 32'h00600513;
	memory[2] = 32'h00C000EF;
	memory[3] = 32'h00A02023;
	memory[4] = 32'h0000007F;
	memory[5] = 32'hFF810113;
	memory[6] = 32'h00112223;
	memory[7] = 32'h00A12023;
	memory[8] = 32'h00100293;
	memory[9] = 32'h00551863;
	memory[10] = 32'h00100513;
	memory[11] = 32'h00810113;
	memory[12] = 32'h00008067;
	memory[13] = 32'hFFF50513;
	memory[14] = 32'hFDDFF0EF;
	memory[15] = 32'h00012303;
	memory[16] = 32'h00412083;
	memory[17] = 32'h00810113;
	memory[18] = 32'h02650533;
	memory[19] = 32'h00008067;
end

endmodule