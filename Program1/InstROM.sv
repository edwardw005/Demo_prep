module InstROM (
  input [6:0] InstAddress,  // 7-bit PC
  output logic [8:0] InstOut
);
  logic [8:0] rom [0:127];
  initial $readmemb("program.mem", rom);  // Load machine code file
  always_comb InstOut = rom[InstAddress];
endmodule
