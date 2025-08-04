module cpu_debug_tb;
  logic clk = 0, reset = 1, start = 0;
  logic done;
  // Instantiate your CPU
  TopLevel dut(
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done)
  );
  // Clock generation: 10ns period
  always #5 clk = ~clk;
  integer cycle = 0;
  // Stimulus and monitoring
  initial begin
    $display("=== CSE141L Debug Testbench ===");
    #20 reset = 0; // Deassert reset after 2 cycles
    start = 1;
    #10 start = 0;
    forever begin
      @(posedge clk);
      cycle += 1;
      // Print key state
      $display("[Cycle %0d] PC=%0d, Instr=%b, opcode=%b, done=%b, halt?=%b, R0=%h, R1=%h, R2=%h, R3=%h, R4=%h, R5=%h, R6=%h, R7=%h, mem[10]=%h",
        cycle, dut.PC, dut.instruction, dut.opcode, done, dut.halt,
        dut.reg_file.regs[0], dut.reg_file.regs[1], dut.reg_file.regs[2],
        dut.reg_file.regs[3], dut.reg_file.regs[4], dut.reg_file.regs[5],
        dut.reg_file.regs[6], dut.reg_file.regs[7], dut.data_mem1.mem_core[10]);
      if (done) begin
        $display("SUCCESS: CPU halted at cycle %0d, PC=%0d, instruction=%b", cycle, dut.PC, dut.instruction);
        $finish;
      end
      if (cycle > 1000) begin
        $display("ERROR: CPU never halted in 1000 cycles! PC=%0d instr=%b halt?=%b", dut.PC, dut.instruction, dut.halt);
        $stop;
      end
    end
  end
endmodule