module CTRL (
  input [8:0] instruction,
  output logic [2:0] alu_op,
  output logic reg_write, mem_read, mem_write, branch, branch_conditional
);
  logic [2:0] opcode = instruction[8:6];
  always_comb begin
    alu_op = 3'b000;
    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    branch = 0;
    branch_conditional = 0;
    case (opcode)
      3'b000: {alu_op, reg_write} = {3'b000, 1'b1};  // ADD
      3'b001: {alu_op, reg_write} = {3'b001, 1'b1};  // SUB
      3'b010: {alu_op, reg_write} = {3'b010, 1'b1};  // AND
      3'b011: {alu_op, reg_write} = {3'b011, 1'b1};  // XOR
      3'b100: {mem_read, reg_write} = {1'b1, 1'b1};  // LDR
      3'b101: mem_write = 1'b1;  // STR
      3'b110: branch = 1'b1;  // BR
      3'b111: {branch, branch_conditional} = {1'b1, 1'b1};  // BRZ
    endcase
  end
endmodule