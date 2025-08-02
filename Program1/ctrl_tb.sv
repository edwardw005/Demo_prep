module ctrl_tb;
  logic [8:0] instruction;
  logic [2:0] alu_op;
  logic reg_write, mem_read, mem_write, branch, branch_conditional;
  CTRL ctrl (.instruction, .alu_op, .reg_write, .mem_read, .mem_write, .branch, .branch_conditional);

  initial begin
    $display("Testing CTRL module");
    // Test ADD (opcode 000)
    instruction = 9'b000000000; #10;
    assert (alu_op == 3'b000 && reg_write == 1 && mem_read == 0 && mem_write == 0 && branch == 0 && branch_conditional == 0)
      else $error("ADD control signals incorrect");
    $display("ADD: alu_op=%b, reg_write=%b", alu_op, reg_write);

    // Test SUB (opcode 001)
    instruction = 9'b001000000; #10;
    assert (alu_op == 3'b001 && reg_write == 1) else $error("SUB control signals incorrect");
    $display("SUB: alu_op=%b, reg_write=%b", alu_op, reg_write);

    // Test LDR (opcode 100)
    instruction = 9'b100000000; #10;
    assert (mem_read == 1 && reg_write == 1) else $error("LDR control signals incorrect");
    $display("LDR: mem_read=%b, reg_write=%b", mem_read, reg_write);

    // Test STR (opcode 101)
    instruction = 9'b101000000; #10;
    assert (mem_write == 1) else $error("STR control signals incorrect");
    $display("STR: mem_write=%b", mem_write);

    // Test BRZ (opcode 111)
    instruction = 9'b111000000; #10;
    assert (branch == 1 && branch_conditional == 1) else $error("BRZ control signals incorrect");
    $display("BRZ: branch=%b, branch_conditional=%b", branch, branch_conditional);

    $display("CTRL test completed");
    $finish;
  end
endmodule