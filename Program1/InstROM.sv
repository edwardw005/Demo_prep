module InstROM (
  input [6:0] InstAddress,
  output logic [8:0] InstOut
);
  logic [8:0] rom [0:127];
  initial begin
    for (int i = 0; i <= 127; i++) rom[i] = 9'b000000000;
    rom[0] = 9'b100000000; // LDR R0, [0] (low)
    rom[1] = 9'b000001000; // ADD R1, R0, 0
    rom[2] = 9'b100000001; // LDR R0, [1] (high)
    rom[3] = 9'b000010000; // ADD R2, R0, 0
    rom[4] = 9'b010011000; // AND R3, R2, 0x80 (sign)
    rom[5] = 9'b011000001; // XOR R0, R1, R1 (low == 0)
    rom[6] = 9'b111000000; // BRZ 0 (to 15, trap)
    rom[7] = 9'b001000010; // SUB R0, R2, R2 (high == 0)
    rom[8] = 9'b111000000; // BRZ 0 (to 15, trap)
    rom[9] = 9'b001000010; // SUB R0, R2, 0x80 (max negative)
    rom[10] = 9'b111000000; // BRZ 0 (to 15, trap)
    rom[11] = 9'b100000100; // LDR R0, [4] (21 for exp)
    rom[12] = 9'b000100000; // ADD R4, R0, 0 (exp = 21)
    rom[13] = 9'b100000101; // LDR R0, [5] (15 for counter)
    rom[14] = 9'b000101000; // ADD R5, R0, 0 (counter = 15)
    // Trap zero/max negative
    rom[15] = 9'b100000000; // LDR R0, [0] (0)
    rom[16] = 9'b101000010; // STR [2], R0
    rom[17] = 9'b101000011; // STR [3], R0
    rom[18] = 9'b111000010; // BRZ 2 (halt)
    // Normalization loop
    rom[19] = 9'b010000010; // AND R0, R2, 0x40 (bit 14)
    rom[20] = 9'b111000011; // BRZ 3 (to 26)
    rom[21] = 9'b001101101; // SUB R5, R5, 1 (decrement counter)
    rom[22] = 9'b111000100; // BRZ 4 (to 26, max shifts)
    rom[23] = 9'b000001001; // ADD R1, R1, R1 (shift low)
    rom[24] = 9'b000010010; // ADD R2, R2, R2 (shift high)
    rom[25] = 9'b110000101; // BR 5 (to 19, loop)
    // Store result
    rom[26] = 9'b101000010; // STR [2], R1 (mant low)
    rom[27] = 9'b010000110; // AND R0, R4, 0x1F (exp)
    rom[28] = 9'b000000011; // ADD R0, R0, R3 (add sign)
    rom[29] = 9'b101000011; // STR [3], R0 (sign, exp, mant high)
    rom[30] = 9'b111000010; // BRZ 2 (halt)
  end
  always_comb InstOut = rom[InstAddress];
endmodule