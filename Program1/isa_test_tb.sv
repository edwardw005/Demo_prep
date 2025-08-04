module isa_test_tb;

  logic clk, reset, start, done;
  TopLevel dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .done(done)
  );

  always #5 clk = ~clk;

 initial begin
  clk = 0;
  reset = 1;
  start = 0;
  // Test LDR
  $display("Testing LDR");
  dut.data_mem1.mem_core[4] = 8'hbb;  // Preload before reset
  #10 reset = 0;
  dut.inst_rom.rom[0] = 9'b011000100;  // LDI R0,4
  dut.inst_rom.rom[1] = 9'b100001000;  // LDR R1,R0
  dut.inst_rom.rom[2] = 9'b111000000;  // HALT
  for (int i = 3; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
  #10 start = 1;
  #10 start = 0;
  wait(done);
  if (dut.reg_file.regs[1] == 8'hbb) $display("LDR PASS");
  else $display("LDR FAIL: R1 = %h", dut.reg_file.regs[1]);
    #10 reset = 1;
    #10 reset = 0;

    // Test ADD
    $display("Testing ADD");
    dut.inst_rom.rom[0] = 9'b011000011;  // LDI R0,3
    dut.inst_rom.rom[1] = 9'b011001100;  // LDI R1,4
    dut.inst_rom.rom[2] = 9'b000000001;  // ADD R0,R1
    dut.inst_rom.rom[3] = 9'b111000000;  // HALT
    for (int i = 4; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
    start = 1;
    #10 start = 0;
    wait(done);
    if (dut.reg_file.regs[0] == 8'h07) $display("ADD PASS");
    else $display("ADD FAIL: R0 = %h", dut.reg_file.regs[0]);
    #10 reset = 1;
    #10 reset = 0;

    // Test SUB
    $display("Testing SUB");
    dut.inst_rom.rom[0] = 9'b011000101;  // LDI R0,5
    dut.inst_rom.rom[1] = 9'b011001010;  // LDI R1,2
    dut.inst_rom.rom[2] = 9'b001000001;  // SUB R0,R1
    dut.inst_rom.rom[3] = 9'b111000000;  // HALT
    for (int i = 4; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
    start = 1;
    #10 start = 0;
    wait(done);
    if (dut.reg_file.regs[0] == 8'h03) $display("SUB PASS");
    else $display("SUB FAIL: R0 = %h", dut.reg_file.regs[0]);
    #10 reset = 1;
    #10 reset = 0;

    // Test AND
    $display("Testing AND");
    dut.inst_rom.rom[0] = 9'b011000111;  // LDI R0,7
    dut.inst_rom.rom[1] = 9'b011001011;  // LDI R1,3
    dut.inst_rom.rom[2] = 9'b010000001;  // AND R0,R1
    dut.inst_rom.rom[3] = 9'b111000000;  // HALT
    for (int i = 4; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
    start = 1;
    #10 start = 0;
    wait(done);
    if (dut.reg_file.regs[0] == 8'h03) $display("AND PASS");
    else $display("AND FAIL: R0 = %h", dut.reg_file.regs[0]);
    #10 reset = 1;
    #10 reset = 0;

    // Test LDR
    $display("Testing LDR");
    dut.data_mem1.mem_core[4] = 8'hbb;  // Preload mem[4]
    dut.inst_rom.rom[0] = 9'b011000100;  // LDI R0,4
    dut.inst_rom.rom[1] = 9'b100001000;  // LDR R1,R0
    dut.inst_rom.rom[2] = 9'b111000000;  // HALT
    for (int i = 3; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
    start = 1;
    #10 start = 0;
    wait(done);
    if (dut.reg_file.regs[1] == 8'hbb) $display("LDR PASS");
    else $display("LDR FAIL: R1 = %h", dut.reg_file.regs[1]);
    #10 reset = 1;
    #10 reset = 0;

    // Test STR
    $display("Testing STR");
    dut.inst_rom.rom[0] = 9'b011000100;  // LDI R0,4
    dut.inst_rom.rom[1] = 9'b011001101;  // LDI R1,5
    dut.inst_rom.rom[2] = 9'b101001000;  // STR R1,R0
    dut.inst_rom.rom[3] = 9'b111000000;  // HALT
    for (int i = 4; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
    start = 1;
    #10 start = 0;
    wait(done);
    if (dut.data_mem1.mem_core[4] == 8'h05) $display("STR PASS");
    else $display("STR FAIL: mem[4] = %h", dut.data_mem1.mem_core[4]);
    #10 reset = 1;
    #10 reset = 0;

    // Test BRZ
    $display("Testing BRZ");
    dut.inst_rom.rom[0] = 9'b011000000;  // LDI R0,0
    dut.inst_rom.rom[1] = 9'b000000000;  // ADD R0,R0
    dut.inst_rom.rom[2] = 9'b110000101;  // BRZ 5
    dut.inst_rom.rom[3] = 9'b011001001;  // LDI R1,1
    dut.inst_rom.rom[4] = 9'b111000000;  // HALT
    dut.inst_rom.rom[5] = 9'b011001000;  // LDI R1,0
    dut.inst_rom.rom[6] = 9'b111000000;  // HALT
    for (int i = 7; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
    start = 1;
    #10 start = 0;
    wait(done);
    if (dut.reg_file.regs[1] == 8'h00) $display("BRZ PASS");
    else $display("BRZ FAIL: R1 = %h", dut.reg_file.regs[1]);
    #10 reset = 1;
    #10 reset = 0;

    // Test JMP
    $display("Testing JMP");
    dut.inst_rom.rom[0] = 9'b111000011;  // JMP 3
    dut.inst_rom.rom[1] = 9'b011001001;  // LDI R1,1
    dut.inst_rom.rom[2] = 9'b111000000;  // HALT
    dut.inst_rom.rom[3] = 9'b011001000;  // LDI R1,0
    dut.inst_rom.rom[4] = 9'b111000000;  // HALT
    for (int i = 5; i < 128; i++) dut.inst_rom.rom[i] = 9'b0;
    start = 1;
    #10 start = 0;
    wait(done);
    if (dut.reg_file.regs[1] == 8'h00) $display("JMP PASS");
    else $display("JMP FAIL: R1 = %h", dut.reg_file.regs[1]);
    #10;

    $display("All ISA instructions tested.");
    $finish;
  end

endmodule