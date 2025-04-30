module IF_ID(
    input clk,
    input reset,
    input stall,              // From hazard detection unit — stall IF/ID update
	 input branchTaken,
    input flush,              // From control/hazard unit — used for flushing on branch/jump
    input [31:0] PC_in,       // Current PC from IF stage
    input [31:0] instruction_in, // Fetched instruction from IF stage
    output reg [31:0] PC_out,       // Registered PC value to send to ID stage
    output reg [31:0] instruction_out // Registered instruction to send to ID stage
);

    // On every clock edge (or reset), update the pipeline register contents
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset both PC and instruction to 0
            PC_out <= 32'd0;
            instruction_out <= 32'd0;
        end else if (branchTaken) begin
            // On flush (branch taken or jump), convert current instruction to NOP
            PC_out <= 32'd0;
            instruction_out <= 32'd0;
        end else if (!stall) begin
            // Normal case: update registers from IF stage unless stalled
            PC_out <= PC_in;
            instruction_out <= instruction_in;
        end
        // If stall is asserted, hold current state (no updates)
    end

endmodule
