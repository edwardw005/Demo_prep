module ALU (
  input  logic [7:0] in1,
  input  logic [7:0] in2,
  input  logic [2:0] op,
  input  logic [5:0] imm6,
  input  logic       imm_mode,
  output logic [7:0] out,
  output logic       zero
);
  logic [7:0] src2;
  assign src2 = imm_mode ? {5'b00000, imm6[2:0]} : in2; // Zero-extend 3-bit imm for LDI

  always_comb begin
    case (op)
      3'b000: out = in1 + src2;   // ADD
      3'b001: out = in1 - src2;   // SUB
      3'b010: out = in1 & src2;   // AND
      3'b011: out = src2;         // LDI
      default: out = 8'b0;
    endcase
    zero = (out == 8'b0);
  end
endmodule