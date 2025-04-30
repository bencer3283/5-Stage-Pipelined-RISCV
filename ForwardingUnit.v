module ForwardingUnit(
    input [4:0] EX_rs1, EX_rs2,
    input [4:0] MEM_rd, WB_rd,
    input MEM_regWrite, WB_regWrite,
    output reg [1:0] forwardA,
    output reg [1:0] forwardB
);
    always @* begin
        // Default: no forwarding
        forwardA = 2'b00;
        forwardB = 2'b00;

        // Forward from MEM stage
        if (MEM_regWrite && MEM_rd != 0 && MEM_rd == EX_rs1)
            forwardA = 2'b10;
        if (MEM_regWrite && MEM_rd != 0 && MEM_rd == EX_rs2)
            forwardB = 2'b10;

        // Forward from WB stage
        if (WB_regWrite && WB_rd != 0 && WB_rd == EX_rs1 && forwardA == 2'b00)
            forwardA = 2'b01;
        if (WB_regWrite && WB_rd != 0 && WB_rd == EX_rs2 && forwardB == 2'b00)
            forwardB = 2'b01;
    end
endmodule
