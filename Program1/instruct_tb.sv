module inst_testbench;
  logic clk = 0, reset = 1, start = 1;
  logic done;
  integer cycle;
  // Instantiate your design (TopLevel)
  TopLevel dut(
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done)
  );
  
  // Simple clock
  always #5 clk = ~clk;
  
  // Cycle counter for display
  initial cycle = 0;
  always @(posedge clk) cycle = cycle + 1;
  
  // Initialize test memory if needed
  initial begin
    // Optional: preload memory here
    // dut.data_mem1.mem[0] = 0;
    // Reset pulse
    #12 reset = 0;
  end
  
  // Display
  always @(posedge clk) begin
    $display("Cycle %0d: PC=%02x | R0=%02x R1=%02x R2=%02x R3=%02x R4=%02x R5=%02x R6=%02x R7=%02x", 
      cycle, 
      dut.prog_ctrl.PC, 
      dut.reg_file.regs[0], dut.reg_file.regs[1], dut.reg_file.regs[2], dut.reg_file.regs[3], 
      dut.reg_file.regs[4], dut.reg_file.regs[5], dut.reg_file.regs[6], dut.reg_file.regs[7]);
    $display("    Mem[0]=%02x Mem[1]=%02x Mem[2]=%02x Mem[3]=%02x", 
      dut.data_mem1.mem_core[0], dut.data_mem1.mem_core[1], dut.data_mem1.mem_core[2], dut.data_mem1.mem_core[3]);
    if (done) begin
      $display("HALT detected at cycle %0d", cycle);
      $stop;
    end
  end
endmodule
