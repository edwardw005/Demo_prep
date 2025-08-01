module LUT (
  input [5:0] index,
  output logic [6:0] out
);
  logic [6:0] lut_mem [0:63];
  initial begin
    lut_mem = '{default: 7'b0};
    lut_mem[0] = 7'd10;  // PC 10 (trap zero)
    lut_mem[1] = 7'd13;  // PC 13 (trap max)
    lut_mem[2] = 7'd16;  // PC 16 (halt)
    lut_mem[3] = 7'd18;  // PC 18 (exit loop)
    lut_mem[4] = 7'd11;  // PC 11 (loop)
  end
  always_comb out = lut_mem[index];
endmodule