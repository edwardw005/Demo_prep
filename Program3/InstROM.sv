module InstROM (
  input [6:0] InstAddress,
  output logic [8:0] InstOut
);
  logic [8:0] rom [0:127];
  initial begin
    rom = '{default: 9'b0};
    // Initialize constants
    rom[0] = 9'b100000000; // LDR R0, [0] (0 for trap)
    rom[1] = 9'b101000000; // STR [0], R0
    rom[2] = 9'b100000001; // LDR R0, [1] (0x1F for exp mask)
    rom[3] = 9'b101000001; // STR [1], R0
    rom[4] = 9'b100000010; // LDR R0, [2] (0x80 for sign)
    rom[5] = 9'b101000010; // STR [2], R0
    rom[6] = 9'b100000011; // LDR R0, [3] (0x04 for hidden 1)
    rom[7] = 9'b101000011; // STR [3], R0
    rom[8] = 9'b100000100; // LDR R0, [4] (0x08 for overflow)
    rom[9] = 9'b101000100; // STR [4], R0
    // Load addend1: mem[8:9]
    rom[10] = 9'b100001000; // LDR R0, [8] (mant1 low)
    rom[11] = 9'b000001000; // ADD R1, R0, 0
    rom[12] = 9'b100001001; // LDR R0, [9] (sign1, exp1, mant1 high)
    rom[13] = 9'b000010000; // ADD R2, R0, 0
    // Load addend2: mem[10:11]
    rom[14] = 9'b100001010; // LDR R0, [10] (mant2 low)
    rom[15] = 9'b000011000; // ADD R3, R0, 0
    rom[16] = 9'b100001011; // LDR R0, [11] (sign2, exp2, mant2 high)
    rom[17] = 9'b000100000; // ADD R4, R0, 0
    // Check nil1, nil2
    rom[18] = 9'b010000010; // AND R0, R2, [1] (0x1F, exp1)
    rom[19] = 9'b111000000; // BRZ 0 (to 22)
    rom[20] = 9'b010000100; // AND R0, R4, [1] (0x1F, exp2)
    rom[21] = 9'b111000001; // BRZ 1 (to 22)
    // Trap: store 0
    rom[22] = 9'b100000000; // LDR R0, [0] (0)
    rom[23] = 9'b101000110; // STR [12], R0
    rom[24] = 9'b101000111; // STR [13], R0
    rom[25] = 9'b111000010; // BRZ 2 (to 25, halt)
    // Extract sign1, sign2, assume same
    rom[26] = 9'b010101000; // AND R5, R2, [2] (0x80, sign1)
    rom[27] = 9'b010110100; // AND R6, R4, [2] (0x80, sign2)
    rom[28] = 9'b000111000; // ADD R7, R5, 0 (sign3 = sign1)
    // Extract exp1, exp2
    rom[29] = 9'b010000010; // AND R0, R2, [1] (0x1F, exp1)
    rom[30] = 9'b000101000; // ADD R5, R0, 0 (exp3 = exp1)
    rom[31] = 9'b010000100; // AND R0, R4, [1] (0x1F, exp2)
    // diff = exp1 - exp2
    rom[32] = 9'b001000100; // SUB R0, R5, R0
    rom[33] = 9'b111000011; // BRZ 3 (to 40, equal)
    rom[34] = 9'b010000001; // AND R0, R0, [2] (0x80, sign of diff)
    rom[35] = 9'b111000100; // BRZ 4 (to 46, exp1 > exp2)
    // exp2 > exp1: flip diff, shift mant1
    rom[36] = 9'b001000100; // SUB R0, R0, R0
    rom[37] = 9'b001000100; // SUB R0, R0, R5 (exp2 - exp1)
    rom[38] = 9'b000101100; // ADD R5, R4, 0 (exp3 = exp2)
    rom[39] = 9'b000001001; // ADD R1, R1, R1 (shift mant1 low)
    rom[40] = 9'b000010010; // ADD R2, R2, R2 (shift mant1 high)
    rom[41] = 9'b001000001; // SUB R0, R0, 1
    rom[42] = 9'b111000101; // BRZ 5 (to 44)
    rom[43] = 9'b110000110; // BR 6 (to 39)
    // Equal or after shift: prepend hidden 1
    rom[44] = 9'b100000011; // LDR R0, [3] (0x04, 1 << 2)
    rom[45] = 9'b000010010; // ADD R2, R2, R0 (hidden 1 mant1)
    rom[46] = 9'b000100010; // ADD R4, R4, R0 (hidden 1 mant2)
    // Add mantissas
    rom[47] = 9'b000001011; // ADD R1, R1, R3 (low)
    rom[48] = 9'b010000001; // AND R0, R1, [2] (0x80, check carry)
    rom[49] = 9'b111000110; // BRZ 6 (to 51)
    rom[50] = 9'b000010001; // ADD R2, R2, 1 (carry to high)
    rom[51] = 9'b000010100; // ADD R2, R2, R4 (high)
    // Check overflow (mant3[11])
    rom[52] = 9'b010000010; // AND R0, R2, [4] (0x08)
    rom[53] = 9'b111000111; // BRZ 7 (to 59)
    // Overflow: shift right, exp3++
    rom[54] = 9'b000001001; // ADD R1, R1, R1 (shift low)
    rom[55] = 9'b000010010; // ADD R2, R2, R2 (shift high)
    rom[56] = 9'b000101001; // ADD R5, R5, 1
    rom[57] = 9'b110000111; // BR 7 (to 59)
    // Store result
    rom[58] = 9'b010000100; // AND R0, R5, [1] (0x1F, exp3)
    rom[59] = 9'b010000001; // AND R4, R2, 0x03 (mant [9:8])
    rom[60] = 9'b000100000; // ADD R4, R4, R0
    rom[61] = 9'b000100111; // ADD R4, R4, R7 (sign3 << 7)
    rom[62] = 9'b101000111; // STR [13], R4
    rom[63] = 9'b101000110; // STR [12], R1
    rom[64] = 9'b111000010; // BRZ 2 (halt)
  end
  always_comb InstOut = rom[InstAddress];
endmodule