# Register assignments
# r0 = accumulator (acc)
# r1 = low byte of fixed-point input (fractional part)
# r2 = high byte of fixed-point input (integer part, includes sign)
# r3 = sign bit (0x00 or 0x80)
# r4 = exponent (initially 21, adjusted during normalization)
# r5 = shift counter (initially 15)
# r6 = temporary/constant (e.g., 1 for decrement, carry)
# r7 = temporary for constructing output (mantissa and exponent)
# r9 = temporary for masks (e.g., 0x80, 0x40, 0x1F, 0x30)
# r10 = temporary for carry check and quotient in division
# r11-r15 = not used

# Memory constants (pre-loaded)
# [4] = 0x15 (21 for initial exponent)
# [5] = 0x0F (15 for shift counter)
# [6] = 0x80 (sign mask and carry check)
# [7] = 0x7F (magnitude mask)
# [8] = 0x40 (bit 14 mask for normalization)
# [9] = 0x01 (one for decrement/add)
# [10] = 0x1F (exponent mask)
# [11] = 0x30 (mantissa high mask for >>4)
# [12] = 0x0F (low nibble mask)
# [13] = 0x10 (for divide by 16)
# [14] = 0xF0 (high nibble mask for low mantissa)

    # Load fixed-point input: low byte (fractional) and high byte (integer + sign)
    lookup 0
    load r0
    put r1          # r1 = mem[0] (low byte)

    lookup 1
    load r0
    put r2          # r2 = mem[1] (high byte)

    # Extract sign bit (high[7])
    lookup 6
    load r0
    put r9          # r9 = 0x80
    take r2
    nand r9
    put r3          # r3 = high & 0x80

    # Clear sign bit from high byte
    lookup 7
    load r0
    put r9          # r9 = 0x7F
    take r2
    nand r9
    put r2          # r2 = high & 0x7F

    # Check for zero input (low == 0 && high == 0)
    take r1
    eql r0
CHECK_HIGH:
    b0 CHECK_HIGH
    take r2
    eql r0
TRAP_ZERO:
    b0 TRAP_ZERO
NORMAL:
    b0 NORMAL

CHECK_HIGH:
    # Initialize exponent and counter
    lookup 4
    load r0
    put r4          # r4 = 21 (exponent)

    lookup 5
    load r0
    put r5          # r5 = 15 (counter)

    # Normalization loop: shift {r2, r1} left until bit 14 is 1 or counter reaches 0
LOOP:
    lookup 8
    load r0
    put r9          # r9 = 0x40
    take r2
    nand r9
    b0 SHIFT
STORE:
    b0 STORE

SHIFT:
    # Check for carry from low to high
    lookup 6
    load r0
    put r9          # r9 = 0x80
    take r1
    nand r9
    put r10         # r10 = low & 0x80

    # Shift low byte left
    take r1
    shl r0
    put r1

    # Shift high byte left
    take r2
    shl r0
    put r2

    # Add carry if present
    take r10
    eql r0
NO_CARRY:
    b0 NO_CARRY
    lookup 9
    load r0
    take r2
    add r0
    put r2

NO_CARRY:
    # Decrement exponent and counter
    lookup 9
    load r0
    put r6          # r6 = 1
    take r4
    sub r6
    put r4          # r4 = exp - 1

    take r5
    sub r6
    put r5          # r5 = counter - 1

    take r5
    eql r0
    b0 LOOP

STORE:
    # Construct high byte: sign | (exp & 0x1F) | (mantissa[9:8] >> 4)
    lookup 10
    load r0
    put r9          # r9 = 0x1F
    take r4
    nand r9
    shl r0
    shl r0
    put r7          # r7 = (exp & 0x1F) << 2

    lookup 11
    load r0
    put r9          # r9 = 0x30
    take r2
    nand r9
    put r10         # r10 = high & 0x30

    # Divide mantissa[9:8] by 16
    lookup 0
    put r6          # r6 = quotient
DIVIDE_HIGH:
    lookup 13
    load r0
    put r9          # r9 = 0x10
    take r10
    sub r9
    put r10
    take r10
    nand r9
    b0 NO_BORROW_H
    lookup 9
    load r0
    take r6
    add r0
    put r6
    b0 DIVIDE_HIGH

NO_BORROW_H:
    take r7
    add r6
    take r3
    add r0
    put r7          # r7 = sign | (exp << 2) | (mantissa[9:8] >> 4)
    lookup 3
    store r7        # mem[3] = high byte

    # Construct low byte: mantissa[7:0]
    lookup 12
    load r0
    put r9          # r9 = 0x0F
    take r2
    nand r9
    shl r0
    shl r0
    shl r0
    shl r0
    put r7          # r7 = (high & 0x0F) << 4

    lookup 14
    load r0
    put r9          # r9 = 0xF0
    take r1
    nand r9
    put r10         # r10 = low & 0xF0

    lookup 0
    put r6          # r6 = quotient
DIVIDE_LOW:
    lookup 13
    load r0
    put r9          # r9 = 0x10
    take r10
    sub r9
    put r10
    take r10
    nand r9
    b0 NO_BORROW_L
    lookup 9
    load r0
    take r6
    add r0
    put r6
    b0 DIVIDE_LOW

NO_BORROW_L:
    take r7
    add r6
    put r7          # r7 = low byte
    lookup 2
    store r7        # mem[2] = low byte

    halt
TRAP_ZERO:
    lookup 0
    put r0
    lookup 2
    store r0
    lookup 3
    store r0
    halt