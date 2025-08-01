module ALU (
  input [7:0] in1, in2,
  input [2:0] op,  // Reduced to 3 bits for the defined opcodes
  output logic [7:0] out,
  output logic zero
);
  always_comb begin
    case (op)
      3'b000: out = in1 + in2;  // ADD
      3'b001: out = in1 - in2;  // SUB
      3'b010: out = in1 & in2;  // AND
      3'b011: out = in1 ^ in2;  // XOR
      default: out = 8'b0;
    endcase
    zero = (out == 8'b0);
  end
endmodule
