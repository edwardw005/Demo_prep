module toplevel_tb();
  bit clk;                     // Clock signal
  bit reset;                  // Reset signal
  bit start;                  // Start signal
  logic done;                 // Done signal
  int score = 0;              // Score for correct operations
  int count = 0;              // Number of test cases

  // Instantiate the TopLevel module
  TopLevel toplevel (
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done)
  );

  // Clock generation
  always begin
    #5ns clk = '1;
    #5ns clk = '0;
  end

  // Test sequence
  initial begin
    // Initialize signals
    reset = 1;
    start = 0;
    #10ns;
    reset = 0;

    // Test 1: Zero input (0x0000)
    $display("\nTest 1: Zero input (0x0000)");
    toplevel.data_mem1.mem_core[1] = 8'h00; // High byte
    toplevel.data_mem1.mem_core[0] = 8'h00; // Low byte
    toplevel.data_mem1.mem_core[4] = 8'h15; // Exp init (21)
    toplevel.data_mem1.mem_core[5] = 8'h0F; // Counter init (15)
    start = 1;
    #10ns;
    start = 0;
    wait(done);
    #10ns;
    if ({toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]} === 16'h0000) begin
      $display("PASS: Input=0x0000, Output=0x%h, expected 0x0000", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
      score++;
    end else begin
      $display("FAIL: Input=0x0000, Output=0x%h, expected 0x0000", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
    end
    count++;

    // Reset for next test
    reset = 1;
    #10ns;
    reset = 0;

    // Test 2: Positive input (0x0100 = 1.0 in 8.8 fixed-point)
    $display("\nTest 2: Positive input (0x0100)");
    toplevel.data_mem1.mem_core[1] = 8'h01; // High byte
    toplevel.data_mem1.mem_core[0] = 8'h00; // Low byte
    toplevel.data_mem1.mem_core[4] = 8'h15; // Exp init (21)
    toplevel.data_mem1.mem_core[5] = 8'h0F; // Counter init (15)
    start = 1;
    #10ns;
    start = 0;
    wait(done);
    #10ns;
    if ({toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]} === 16'h1500) begin
      $display("PASS: Input=0x0100, Output=0x%h, expected 0x1500", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
      score++;
    end else begin
      $display("FAIL: Input=0x0100, Output=0x%h, expected 0x1500", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
    end
    count++;

    // Reset for next test
    reset = 1;
    #10ns;
    reset = 0;

    // Test 3: Negative input (0xFF00 = -1.0 in 8.8 fixed-point)
    $display("\nTest 3: Negative input (0xFF00)");
    toplevel.data_mem1.mem_core[1] = 8'hFF; // High byte
    toplevel.data_mem1.mem_core[0] = 8'h00; // Low byte
    toplevel.data_mem1.mem_core[4] = 8'h15; // Exp init (21)
    toplevel.data_mem1.mem_core[5] = 8'h0F; // Counter init (15)
    start = 1;
    #10ns;
    start = 0;
    wait(done);
    #10ns;
    if ({toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]} === 16'h9500) begin
      $display("PASS: Input=0xFF00, Output=0x%h, expected 0x9500", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
      score++;
    end else begin
      $display("FAIL: Input=0xFF00, Output=0x%h, expected 0x9500", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
    end
    count++;

    // Reset for next test
    reset = 1;
    #10ns;
    reset = 0;

    // Test 4: Maximum negative input (0xFFFF)
    $display("\nTest 4: Maximum negative input (0xFFFF)");
    toplevel.data_mem1.mem_core[1] = 8'hFF; // High byte
    toplevel.data_mem1.mem_core[0] = 8'hFF; // Low byte
    toplevel.data_mem1.mem_core[4] = 8'h15; // Exp init (21)
    toplevel.data_mem1.mem_core[5] = 8'h0F; // Counter init (15)
    start = 1;
    #10ns;
    start = 0;
    wait(done);
    #10ns;
    if ({toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]} === 16'h0000) begin
      $display("PASS: Input=0xFFFF, Output=0x%h, expected 0x0000", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
      score++;
    end else begin
      $display("FAIL: Input=0xFFFF, Output=0x%h, expected 0x0000", 
               {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]});
    end
    count++;

    // Test 5: Random input
    $display("\nTest 5: Random input");
    for (int i = 0; i < 3; i++) begin
      logic [15:0] int_in, expected;
      logic sign;
      logic [4:0] exp;
      logic [9:0] mant;
      logic [14:0] half;
      reset = 1;
      #10ns;
      reset = 0;
      int_in = $random;
      sign = int_in[15];
      half = int_in[14:0];
      exp = 21;
      if (!half || int_in == 16'hFFFF) expected = 16'h0000; // Zero or max negative
      else begin
        while (!half[14]) begin
          half <<= 1;
          exp--;
        end
        mant = half[13:4];
        expected = {sign, exp, mant};
      end
      toplevel.data_mem1.mem_core[1] = int_in[15:8];
      toplevel.data_mem1.mem_core[0] = int_in[7:0];
      toplevel.data_mem1.mem_core[4] = 8'h15; // Exp init (21)
      toplevel.data_mem1.mem_core[5] = 8'h0F; // Counter init (15)
      start = 1;
      #10ns;
      start = 0;
      wait(done);
      #10ns;
      if ({toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]} === expected) begin
        $display("PASS: Input=0x%h, Output=0x%h, expected 0x%h", 
                 int_in, {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]}, expected);
        score++;
      } else begin
        $display("FAIL: Input=0x%h, Output=0x%h, expected 0x%h", 
       
                int_in, {toplevel.data_mem1.mem_core[3], toplevel.data_mem1.mem_core[2]}, expected);
      end
      count++;
    end

    // Final score
    #20ns;
    $display("\nFinal Scores: %0d/%0d tests passed", score, count);
    $stop;
  end

  // Monitor key signals
  always @(posedge clk) begin
    if (!reset) begin
      $display("Cycle %0d: PC=0x%h, Instruction=0x%b, R0=0x%h, R1=0x%h, R2=0x%h, R3=0x%h, R4=0x%h, R5=0x%h, R6=0x%h, Zero=%b, ALU_out=0x%h, branch=%b, branch_conditional=%b, target=0x%h, Mem[0]=0x%h, Mem[1]=0x%h, Mem[2]=0x%h, Mem[3]=0x%h",
               toplevel.cycle_ctr, toplevel.PC, toplevel.instruction, 
               toplevel.reg_file.regs[0], toplevel.reg_file.regs[1], toplevel.reg_file.regs[2], 
               toplevel.reg_file.regs[3], toplevel.reg_file.regs[4], toplevel.reg_file.regs[5], 
               toplevel.reg_file.regs[6], toplevel.zero, toplevel.alu_out, 
               toplevel.branch, toplevel.branch_conditional, toplevel.branch_target,
               toplevel.data_mem1.mem_core[0], toplevel.data_mem1.mem_core[1],
               toplevel.data_mem1.mem_core[2], toplevel.data_mem1.mem_core[3]);
    end
  end
endmodule