module CTRL (
  input [8:0] instruction,
  output logic [2:0] alu_op,
  output logic reg_write, mem_read, mem_write, branch, branch_conditional
);
  always_comb begin
    // Extract opcode
    logic [2:0] opcode;
    opcode = instruction[8:6];
    
    // Initialize outputs
    alu_op = 3'b000;
    reg_write = 0;
    mem_read = 0;
    mem_write = 0;
    branch = 0;
    branch_conditional = 0;
    
    // Decode opcode
    case (opcode)
      3'b000: begin // ADD
        alu_op = 3'b000;
        reg_write = 1;
      end
      3'b001: begin // SUB
        alu_op = 3'b001;
        reg_write = 1;
      end
      3'b010: begin // AND
        alu_op = 3'b010;
        reg_write = 1;
      end
      3'b011: begin // XOR
        alu_op = 3'b011;
        reg_write = 1;
      end
      3'b100: begin // LDR
        mem_read = 1;
        reg_write = 1;
      end
      3'b101: begin // STR
        mem_write = 1;
      end
      3'b110: begin // BR
        branch = 1;
      end
      3'b111: begin // BRZ
        branch = 1;
        branch_conditional = 1;
      end
      default: begin
        alu_op = 3'b000;
        reg_write = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        branch_conditional = 0;
      end
    endcase
    
//    $display("Instruction = %b, Opcode = %b", instruction, opcode);
  end
endmodule