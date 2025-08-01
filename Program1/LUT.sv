module LUT (
  input [5:0] index,
  output logic [6:0] out  // 7-bit target PC
);
  logic [6:0] lut_mem [0:63];
  initial $readmemb("lut.mem", lut_mem);  // Load branch targets
  always_comb out = lut_mem[index];
endmodule
