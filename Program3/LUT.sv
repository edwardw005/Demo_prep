module LUT (
  input [5:0] index,
  output logic [6:0] out
);
  logic [6:0] lut_mem [0:63];
  initial begin
    lut_mem = '{default: 7'b0};
    lut_mem[0] = 7'd12;  // PC 12 (trap)
    lut_mem[1] = 7'd12;  // PC 12 (trap)
    lut_mem[2] = 7'd15;  // PC 15 (halt)
    lut_mem[3] = 7'd30;  // PC 30 (equal exp)
    lut_mem[4] = 7'd36;  // PC 36 (exp1 > exp2)
    lut_mem[5] = 7'd33;  // PC 33 (loop end)
    lut_mem[6] = 7'd28;  // PC 28 (loop)
    lut_mem[7] = 7'd48;  // PC 48 (no overflow)
  end
  always_comb out = lut_mem[index];
endmodule