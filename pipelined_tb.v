`timescale 1ns / 1ps

module PipelinedProcessor_tb;

  // Inputs
  reg CLK_50 = 0;
  reg CLKS_50 = 0;
  reg reset = 0;

  // Outputs
  wire [31:0] finalPC;

  // if there is  a halt signal
  wire halted;

  // Instantiate the Unit Under Test (UUT)
  PipelinedProcessor uut (
    .CLOCK_50(CLK_50),
	 //.clkMem(CLKS_50),
    //.reset(reset),
    .finalPC(finalPC)
    // .halt(halted) // Uncomment this if the  processor exposes a halt signal
  );

  // Clock generation: 50 MHz
	always @* begin 
		#10 CLK_50 = ~CLK_50;
	   #5 CLKS_50 <= ~CLKS_50;
		#5 CLK_50 <= ~CLK_50; CLKS_50 <= ~CLKS_50;
	end

	initial begin
		#0 CLK_50=1'b0; CLKS_50=1'b0;
    // Initial reset
    #0 reset = 0;

    // Wait 
//    integer timeout = 0;
//    while (uut.memory[1] == 0 && timeout < 10000) begin
//      #10 timeout = timeout + 10;
//    end

    // Report memory contents
    $display("Simulation finished at time: %0dns", $time);
    $display("Final PC: %d", finalPC);
    //$display("Factorial Result (memory[0]): %d", uut.memory[0]);
    //$display("Cycle Count     (memory[1]): %d", uut.memory[1]);

    // Stop simulation
    //$stop;
  end

endmodule


