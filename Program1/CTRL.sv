module CTRL (
  input  logic [8:0] instruction,
  output logic reg_write,
  output logic mem_read,
  output logic mem_write,
  output logic branch_zero,
  output logic branch_always,
  output logic halt
);
  logic [2:0] opcode;
  assign opcode = instruction[8:6];

  always_comb begin
    reg_write    = 0;
    mem_read     = 0;
    mem_write    = 0;
    branch_zero  = 0;
    branch_always = 0;
    halt         = 0;
    case (opcode)
      3'b000: reg_write = 1;           // ADD
      3'b001: reg_write = 1;           // SUB
      3'b010: reg_write = 1;           // AND
      3'b011: reg_write = 1;           // LDI
      3'b100: begin                    // LDR
        reg_write = 1;
        mem_read  = 1;
      end
      3'b101: mem_write = 1;           // STR
      3'b110: branch_zero = 1;         // BRZ
      3'b111: begin                    // JMP/HALT
        if (instruction[5:0] == 6'b000000)
          halt = 1;
        else
          branch_always = 1;
      end
      default: ;
    endcase
  end
endmodule