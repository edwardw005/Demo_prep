module progctrl_tb;
  logic clk, reset, branch, branch_conditional, zero;
  logic [6:0] target, PC;
  ProgCtrl progctrl (.clk, .reset, .branch, .branch_conditional, .zero, .target, .PC);

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  initial begin
    $display("Testing ProgCtrl module");
    
    // Initialize inputs to avoid x states
    reset = 0;
    branch = 0;
    branch_conditional = 0;
    zero = 0;
    target = 7'h00;

    // Test reset
    reset = 1; #10; // Assert reset, wait for posedge clk
    reset = 0; #2;  // Deassert reset, check PC after stabilization
    assert (PC == 7'h00) else $error("Reset failed: PC=%h, expected 00", PC);
    $display("After reset: PC=%h", PC);

    // Test PC increment
    #8; // Wait for next posedge clk (total 10 ns since last check)
    assert (PC == 7'h01) else $error("Increment failed: PC=%h, expected 01", PC);
    $display("After increment: PC=%h", PC);

    // Test unconditional branch
    branch = 1; branch_conditional = 0; target = 7'h0F; #10;
    assert (PC == 7'h0F) else $error("Branch failed: PC=%h, expected 0F", PC);
    $display("After branch: PC=%h", PC);

    // Test conditional branch (BRZ, taken)
    branch = 1; branch_conditional = 1; zero = 1; target = 7'h14; #10;
    assert (PC == 7'h14) else $error("BRZ taken failed: PC=%h, expected 14", PC);
    $display("BRZ taken: PC=%h", PC);

    // Test conditional branch (BRZ, not taken)
    branch = 1; branch_conditional = 1; zero = 0; target = 7'h14; #10;
    assert (PC == 7'h15) else $error("BRZ not taken failed: PC=%h, expected 15", PC);
    $display("BRZ not taken: PC=%h", PC);

    $display("ProgCtrl test completed");
    $finish;
  end

  // Debug logging after each clock edge
  always @(posedge clk) begin
    #1; // Small delay to ensure PC has updated
    $display("Cycle: Branch=%b, Branch_conditional=%b, Zero=%b, Target=%h, Current PC=%h",
             branch, branch_conditional, zero, target, PC);
  end
endmodule