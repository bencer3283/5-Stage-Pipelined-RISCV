module PipelinedProcessor(
    input CLOCK_50,
//	 input clkMem,
    //input reset,
    output [31:0] finalPC
);

reg reset = 0;
wire clk, clks, clkMem;
assign clkMem = clk;

PLL pllClk(
  	.refclk(CLOCK_50),
  	.rst(reset),
  	.outclk_0(clk)
);
//assign clk = CLOCK_50;

wire [4:0] MEMWB_rd;
wire MEMWB_regWrite;
wire [31:0] writeBackData;
wire [31:0] cycleCount;

// ======================= New Wires Added =======================
wire ID_BR, ID_PCToReg, ID_aluToPC;
wire IDEX_BR, IDEX_PCToReg, IDEX_aluToPC;
wire EX_zero;
reg branchTaken;
wire [31:0] branchTarget;
wire flush;
wire stall;
// ==============================================================


// --------------------- IF Stage ---------------------
wire [31:0] IDEX_PC, IDEX_rs1Data, IDEX_rs2Data, IDEX_imm;
wire [4:0] IDEX_rs1, IDEX_rs2, IDEX_rd;
wire [2:0] IDEX_ALUOp;
wire IDEX_memWrite, IDEX_memToReg, IDEX_regWrite, IDEX_ALUSrc;

wire [31:0] EX_aluResult;

wire [31:0] IF_PC, IF_instruction;
wire [31:0] IFID_PC, IFID_instruction;

InstructionFetchStage IF_stage (
    .clk(clk),
    .reset(reset),
	 .stall(stall),
    .branchTaken(branchTaken),
    //.aluToPC(IDEX_aluToPC),
    .halt(1'b0),
    .branchTarget(branchTarget),
    .aluResult(EX_aluResult),
    .PC_out(IF_PC),
    .instruction_out(IF_instruction)
    //.flush(flush) // new connection
);

IF_ID if_id_reg (
    .clk(clk),
    .reset(reset),
    .stall(stall),
	 .branchTaken(branchTaken),
    .flush(flush),
    .PC_in(IF_PC),
    .instruction_in(IF_instruction),
    .PC_out(IFID_PC),
    .instruction_out(IFID_instruction)
);

// --------------------- ID Stage ---------------------
wire [31:0] ID_rs1Data, ID_rs2Data, ID_imm;
wire [4:0] ID_rs1, ID_rs2, ID_rd;
wire [2:0] ID_ALUOp;
wire ID_memWrite, ID_memToReg, ID_regWrite, ID_ALUSrc, ID_bne, IDEX_bne;

InstructionDecodeStage ID_stage (
    .clk(clk),
    .reset(reset),
	 .stall(stall),
    .PC_in(IFID_PC),
    .instruction(IFID_instruction),
    .writeBackData(writeBackData),
    .writeBackReg(MEMWB_rd),
    .regWriteWB(MEMWB_regWrite),
    .rs1Data_out(ID_rs1Data),
    .rs2Data_out(ID_rs2Data),
    .imm_out(ID_imm),
    .rs1_out(ID_rs1),
    .rs2_out(ID_rs2),
    .rd_out(ID_rd),
    .ALUOp_out(ID_ALUOp),
    .memWrite_out(ID_memWrite),
    .memToReg_out(ID_memToReg),
    .regWrite_out(ID_regWrite),
    .ALUSrc_out(ID_ALUSrc),
    .BR_out(ID_BR),
    .PCToReg_out(ID_PCToReg),
    .aluToPC_out(ID_aluToPC),
	 .bne(ID_bne)
);

// --------------------- Hazard Detection Unit ---------------------
HazardDetectionUnit hazard_unit (
    .ID_rs1(ID_rs1),
    .ID_rs2(ID_rs2),
    .EX_rd(IDEX_rd),
    .EX_memRead(IDEX_memToReg),
	 .branchTaken(branchTaken),
    .stall(stall)
);

// --------------------- ID/EX Register ---------------------

ID_EX id_ex_reg (
    .clk(clk),
    .reset(reset),
    .stall(stall),
    .PC_in(IFID_PC),
    .rs1Data_in(ID_rs1Data),
    .rs2Data_in(ID_rs2Data),
    .imm_in(ID_imm),
    .rs1_in(ID_rs1),
    .rs2_in(ID_rs2),
    .rd_in(ID_rd),
    .ALUOp_in(ID_ALUOp),
    .memWrite_in(ID_memWrite),
    .memToReg_in(ID_memToReg),
    .regWrite_in(ID_regWrite),
    .ALUSrc_in(ID_ALUSrc),
    .BR_in(ID_BR),
	 .bne_in(ID_bne),
    .PCToReg_in(ID_PCToReg),
    .aluToPC_in(ID_aluToPC),
    .PC_out(IDEX_PC),
    .rs1Data_out(IDEX_rs1Data),
    .rs2Data_out(IDEX_rs2Data),
    .imm_out(IDEX_imm),
    .rs1_out(IDEX_rs1),
    .rs2_out(IDEX_rs2),
    .rd_out(IDEX_rd),
    .ALUOp_out(IDEX_ALUOp),
    .memWrite_out(IDEX_memWrite),
    .memToReg_out(IDEX_memToReg),
    .regWrite_out(IDEX_regWrite),
    .ALUSrc_out(IDEX_ALUSrc),
    .BR_out(IDEX_BR),
	 .bne_out(IDEX_bne),
    .PCToReg_out(IDEX_PCToReg),
    .aluToPC_out(IDEX_aluToPC)
);

// --------------------- Forwarding Unit ---------------------
wire [1:0] forwardA, forwardB;
wire [4:0] EXMEM_rd;
wire EXMEM_memWrite, EXMEM_memToReg, EXMEM_regWrite, EXMEM_PCToReg;

ForwardingUnit FU (
    .EX_rs1(IDEX_rs1),
    .EX_rs2(IDEX_rs2),
    .MEM_rd(EXMEM_rd),
    .WB_rd(MEMWB_rd),
    .MEM_regWrite(EXMEM_regWrite),
    .WB_regWrite(MEMWB_regWrite),
    .forwardA(forwardA),
    .forwardB(forwardB)
);

// --------------------- EX Stage ---------------------
wire [31:0] EX_rs2;
wire [31:0] EXMEM_aluResult, EXMEM_rs2Data, EX_memAddr;

ExecuteStage EX_stage (
    .rs1Data(IDEX_rs1Data),
    .rs2Data(IDEX_rs2Data),
    .PC_in(IDEX_PC),
    .imm(IDEX_imm),
    .ALUOp(IDEX_ALUOp),
    .ALUSrc(IDEX_ALUSrc),
	 .ALUToPC(IDEX_aluToPC),
    .forwardA(forwardA),
    .forwardB(forwardB),
    .forwardDataMEM(EXMEM_aluResult),
    .forwardDataWB(writeBackData),
    .aluResult(EX_aluResult),
    .operandB_raw_out(EX_rs2),
    .branchTarget(branchTarget),
    .zero(EX_zero) // added zero output
);

// --------------------- Branch Decision ---------------------
//assign branchTaken = (IDEX_BR == 1'b1) ? (IDEX_ALUOp == 3'b001 ? EX_zero : ~EX_zero) : 1'b0;
always @* begin
	if(IDEX_PCToReg == 1'b1) begin
		branchTaken = 1'b1;
	end else if(IDEX_BR == 1'b1) begin
		if (IDEX_bne) branchTaken = IDEX_ALUOp == 3'b001 ? ~EX_zero : EX_zero;
		else branchTaken = IDEX_ALUOp == 3'b001 ? EX_zero : ~EX_zero;
	end else branchTaken = 1'b0;
end
// assign flush = branchTaken || IDEX_PCToReg || IDEX_aluToPC;
assign EX_memAddr = IDEX_PCToReg ? (IDEX_PC + 4) : EX_aluResult;

// --------------------- EX/MEM Register ---------------------
wire [31:0] EXMEM_PC;
EX_MEM ex_mem_reg (
    .clk(clk),
    .reset(reset),
    .aluResult_in(EX_memAddr),
    .rs2Data_in(EX_rs2),
	 .pc_in(IDEX_PC),
    .rd_in(IDEX_rd),
    .memWrite_in(IDEX_memWrite),
    .memToReg_in(IDEX_memToReg),
    .regWrite_in(IDEX_regWrite),
	 .PCToReg_in(IDEX_PCToReg),
    .aluResult_out(EXMEM_aluResult),
    .rs2Data_out(EXMEM_rs2Data),
	 .pc_out(EXMEM_PC),
    .rd_out(EXMEM_rd),
    .memWrite_out(EXMEM_memWrite),
    .memToReg_out(EXMEM_memToReg),
    .regWrite_out(EXMEM_regWrite),
	 .PCToReg_out(EXMEM_PCToReg)
);

// --------------------- MEM Stage ---------------------
wire [31:0] MEM_memOut;



MemoryStage MEM_stage (
    .clk(clk),
    .clkMem(clkMem),
    .memWrite(IDEX_memWrite),
    .aluResult(EX_memAddr),
    .rs2Data(EX_rs2),
    .cycleCount(cycleCount),
    .memOut(MEM_memOut)
);

// --------------------- MEM/WB Register ---------------------
wire [31:0] MEMWB_memData, MEMWB_aluResult;
wire MEMWB_memToReg;

MEM_WB mem_wb_reg (
    .clk(clk),
    .reset(reset),
    .memData_in(MEM_memOut),
    .aluResult_in(EXMEM_aluResult),
    .rd_in(EXMEM_rd),
    .memToReg_in(EXMEM_memToReg),
    .regWrite_in(EXMEM_regWrite),
    .memData_out(MEMWB_memData),
    .aluResult_out(MEMWB_aluResult),
    .rd_out(MEMWB_rd),
    .memToReg_out(MEMWB_memToReg),
    .regWrite_out(MEMWB_regWrite)
);

// --------------------- WB Stage ---------------------
WriteBackStage WB_stage (
    .memData(MEMWB_memData),
    .aluResult(MEMWB_aluResult),
    .memToReg(MEMWB_memToReg),
    .writeBackData(writeBackData)
);

// --------------------- Cycle Counter ---------------------
wire halt_signal; // Wire to carry the halt signal from ID stage
assign halt_signal = (IFID_instruction[6:0] == 7'b1111111); // Check for HALT opcode

CycleCounter cycle_counter (
    .clk(clk),
    .reset(reset),
    .halt(halt_signal),
    .cycleCount(cycleCount)
);

// Final output for testing/debug
assign finalPC = IF_PC;

endmodule
