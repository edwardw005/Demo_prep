module InstROM (
  input [6:0] InstAddress,
  output logic [8:0] InstOut
);
  logic [8:0] rom [0:127];
  initial begin
    rom = '{default: 9'b0};
    // Load input: mem[4:5]
    rom[0] = 9'b100000100; // LDR R0, [4] (low)
    rom[1] = 9'b000001000; // ADD R1, R0, 0
    rom[2] = 9'b100000101; // LDR R0, [5] (high)
    rom[3] = 9'b000010000; // ADD R2, R0, 0
    // Extract sign to R3
    rom[4] = 9'b010011000; // AND R3, R2, 0x80
    // Check nil (exp == 0)
    rom[5] = 9'b010000010; // AND R0, R2, 0x1F
    rom[6] = 9'b111000000; // BRZ 0 (lut[0] = 10, trap zero)
    // Check exp > 22 (exp - 22 > 0)
    rom[7] = 9'b001000010; // SUB R0, R0, 22
    rom[8] = 9'b010000001; // AND R0, R0, 0x80 (check sign)
    rom[9] = 9'b111000001; // BRZ 1 (lut[1] = 13, trap max)
    // Prepend hidden bit to mant (if exp != 0)
    rom[10] = 9'b000010001; // ADD R2, R2, 0x04 (hidden bit)
    // Shift mant left by exp (loop)
    rom[11] = 9'b000001001; // ADD R1, R1, R1 (shift low)
    rom[12] = 9'b000010010; // ADD R2, R2, R2 (shift high)
    rom[13] = 9'b001000001; // SUB R0, R0, 1
    rom[14] = 9'b111000011; // BRZ 3 (lut[3] = 18, exit loop)
    rom[15] = 9'b110000100; // BR 4 (lut[4] = 11, loop)
    // Store result
    rom[16] = 9'b101000110; // STR [6], R1 (low)
    rom[17] = 9'b101000111; // STR [7], R2 (high)
    rom[18] = 9'b111000010; // BRZ 2 (halt)
    // Trap max
    rom[19] = 9'b100000011; // LDR R0, [3] (0xFF)
    rom[20] = 9'b101000111; // STR [7], R0
    rom[21] = 9'b101000110; // STR [6], R0
    rom[22] = 9'b111000010; // BRZ 2 (halt)
  end
  always_comb InstOut = rom[InstAddress];
endmodule