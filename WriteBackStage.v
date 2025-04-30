module WriteBackStage(
    input [31:0] memData,
    input [31:0] aluResult,
    input memToReg,
    output [31:0] writeBackData
);

    assign writeBackData = memToReg ? memData : aluResult;

endmodule
