module InstructionDecodeStage(
    input clk,
    input reset,
	 input stall,
    input [31:0] PC_in,
    input [31:0] instruction,
    input [31:0] writeBackData,
    input [4:0] writeBackReg,
    input regWriteWB,
    output [31:0] rs1Data_out,
    output [31:0] rs2Data_out,
    output [31:0] imm_out,
    output [4:0] rs1_out, rs2_out, rd_out,
    output [2:0] ALUOp_out,
    output memWrite_out, memToReg_out, regWrite_out, ALUSrc_out,
	 output BR_out, PCToReg_out, aluToPC_out, bne 
	 
);

    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire [4:0] rd  = instruction[11:7];
	 
	 wire ALUSrc, BR, memWrite, regWrite, memToReg, PCToReg, aluToPC;
	 wire [2:0] ALUOp;

    // Register File
    registerFile RF (
        .rs1(rs1),
        .rs2(rs2),
        .rd(writeBackReg),
        .writeData(writeBackData),
        .regWrite(regWriteWB),
        .clk(clk),
        .readData1(rs1Data_out),
        .readData2(rs2Data_out)
    );

    // Immediate Generator
    immediateGenerator immGen (
        .ins(instruction),
        .imm(imm_out)
    );

    // Control Unit
    controlUnit CU (
        .opcode(instruction[6:0]),
        .func3(instruction[14:12]),
        .func7(instruction[31:25]),
        .BR(BR),               // Not used here
        .memToReg(memToReg),
        .memWrite(memWrite),
        .ALUSrc(ALUSrc),
        .regWrite(regWrite),
        .PCToReg(PCToReg),          // Not used here // how do we do jal without this?
        .aluToPC(aluToPC),          // Not used here
        .halt(),             // Not used here
        .ALUOp(ALUOp)
    );

    // Register outputs
    assign rs1_out = rs1;
    assign rs2_out = rs2;
    assign rd_out = rd;
	
	// control signal outputs
	assign memWrite_out = stall ? 1'b0 : memWrite;
	assign memToReg_out = stall ? 1'b0 : memToReg;
	assign regWrite_out = stall ? 1'b0 : regWrite;
	assign ALUSrc_out = stall ? 1'b0 : ALUSrc;
	assign BR_out = stall ? 1'b0 : BR;
	assign ALUOp_out = stall ? 3'b000 : ALUOp;
	assign PCToReg_out = stall ? 1'b0 : PCToReg;
	assign aluToPC_out = stall ? 1'b0 : aluToPC;
	assign bne = instruction[12];
endmodule
