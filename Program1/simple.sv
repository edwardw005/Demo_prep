module simple_tb();
  bit       clk;
  bit       reset = 1;
  bit       start;
  wire      done;
  logic [15:0] int_in = 16'h1234; // Test input: 0x1234
  logic [15:0] flt_out;           // Output from DUT

  // Instantiate the DUT
  TopLevel dut (
    .clk(clk),
    .start(start),
    .reset(reset),
    .done(done)
  );

  // Clock generation
  always begin
    #5ns clk = 1;
    #5ns clk = 0;
  end

  // Test sequence
  initial begin
    $display("Starting simulation at time=%0t", $time);

    // Reset sequence
    #10ns reset = 0;
    $display("Time=%0t: Reset deasserted", $time);

    // Load input into data memory
    dut.data_mem1.mem_core[1] = int_in[15:8]; // High byte
    dut.data_mem1.mem_core[0] = int_in[7:0];  // Low byte
    $display("Time=%0t: Loaded mem[1]=%h, mem[0]=%h", $time, dut.data_mem1.mem_core[1], dut.data_mem1.mem_core[0]);

    // Start the CPU
    #10ns start = 1;
    #10ns start = 0;
    $display("Time=%0t: Start pulse sent", $time);

    // Wait for done signal
    wait(done);
    #10ns;
    $display("Time=%0t: Done asserted", $time);

    // Read output from data memory
    flt_out = {dut.data_mem1.mem_core[3], dut.data_mem1.mem_core[2]};
    $display("Time=%0t: Output flt_out=%h (mem[3]=%h, mem[2]=%h)",
             $time, flt_out, dut.data_mem1.mem_core[3], dut.data_mem1.mem_core[2]);

    // Check if output matches input (for this simple copy program)
    if (flt_out === int_in)
      $display("Test PASS: Output matches input (0x%h)", int_in);
    else
      $display("Test FAIL: Expected 0x%h, got 0x%h", int_in, flt_out);

    #10ns $stop;
  end

  // Debug display for key signals
  always @(posedge clk) begin
    $display("Time=%0t: PC=%0d, Instruction=%b, RegWrite=%b, MemRead=%b, MemWrite=%b, Halt=%b",
             $time, dut.PC, dut.instruction, dut.reg_write, dut.mem_read, dut.mem_write, dut.halt);
    $display("Time=%0t: ALUOut=%h, MemOut=%h, RegDataIn=%h",
             $time, dut.alu_out, dut.mem_out, dut.reg_data_in);
  end
endmodule