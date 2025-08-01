module LUT (
  input [5:0] index,
  output logic [6:0] out
);
  logic [6:0] lut_mem [0:63];
  initial begin
    lut_mem = '{default: 7'b0};
    lut_mem[0] = 7'd15;  // PC 15 (trap zero)
    lut_mem[1] = 7'd15;  // PC 15 (trap max negative)
    lut_mem[2] = 7'd18;  // PC 18 (halt)
    lut_mem[3] = 7'd26;  // PC 26 (store)
    lut_mem[4] = 7'd26;  // PC 26 (max shifts)
    lut_mem[5] = 7'd19;  // PC 19 (loop)
  end
  always_comb out = lut_mem[index];
endmodule