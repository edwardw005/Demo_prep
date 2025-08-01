module CTRL (
  input [8:0] instruction,
  output logic [2:0] alu_op,
  output logic reg_write, mem_read, mem_write, branch, branch_conditional
);
  logic [2:0] opcode;
  assign opcode = instruction[8:6];
  always_comb begin
    alu_op = 3'b000;
    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    branch = 0;
    branch_conditional = 0;
    case (opcode)
      3'b000: begin alu_op = 3'b000; reg_write = 1; end  // ADD
      3'b001: begin alu_op = 3'b001; reg_write = 1; end  // SUB
      3'b010: begin alu_op = 3'b010; reg_write = 1; end  // AND
      3'b011: begin alu_op = 3'b011; reg_write = 1; end  // XOR
      3'b100: begin mem_read = 1; reg_write = 1; end     // LDR
      3'b101: begin mem_write = 1; end                   // STR
      3'b110: begin branch = 1; end                      // BR
      3'b111: begin branch = 1; branch_conditional = 1; end  // BRZ
    endcase
  end
endmodule
