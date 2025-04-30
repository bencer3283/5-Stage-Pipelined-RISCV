module CycleCounter(
    input clk,
    input reset,
    input halt,
    output reg [31:0] cycleCount
);

// Initialize cycleCount to 0
initial begin
    cycleCount = 0;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        cycleCount <= 0;
    end else if (!halt) begin
        cycleCount <= cycleCount + 1;
    end
end

endmodule
