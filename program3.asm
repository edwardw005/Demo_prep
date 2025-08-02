# Register assignments
# r0 = accumulator (acc)
# r1 = mantissa1 (full, after combining low and high parts)
# r2 = high byte of float1 (sign, exp, mantissa[9:8])
# r3 = sign1 (0x00 or 0x80)
# r4 = exponent1
# r5 = mantissa2 (full)
# r6 = high byte of float2
# r7 = sign2 (0x00 or 0x80)
# r9 = exponent2
# r10 = temporary for masks, differences, and counters
# r11 = result mantissa
# r12 = result exponent
# r13 = result sign
# r14 = not used
# r15 = not used
# r16 = overflow bit (not used)

# Memory constants (pre-loaded)
# [6] = 0x80 (sign mask)
# [7] = 0x1F (exponent mask)
# [8] = 0x03 (mantissa high mask)
# [9] = 0x01 (one for increment/decrement)
# [10] = 0x04 (implicit 1 position)
# [11] = 0x0F (15 for shift counter)

    # Load first float: low byte (mantissa[7:0]) and high byte
    lookup 0        # acc = 0
    load r0         # acc = mem[0]
    put r1          # r1 = mantissa1 low

    lookup 1        # acc = 1
    load r0         # acc = mem[1]
    put r2          # r2 = high byte1

    # Extract sign1
    lookup 6        # acc = 6 (address for 0x80)
    load r0         # acc = 0x80
    put r10         # r10 = 0x80
    take r2         # acc = high byte1
    nand r10        # acc = high nand 0x80
    nand r0         # acc = high & 0x80
    put r3          # r3 = sign1

    # Extract exponent1
    lookup 7        # acc = 7 (address for 0x1F)
    load r0         # acc = 0x1F
    put r10         # r10 = 0x1F
    take r2         # acc = high byte1
    nand r10        # acc = high nand 0x1F
    nand r0         # acc = high & 0x1F
    put r4          # r4 = exponent1

    # Extract mantissa1 high bits
    lookup 8        # acc = 8 (address for 0x03)
    load r0         # acc = 0x03
    put r10         # r10 = 0x03
    take r2         # acc = high byte1
    nand r10        # acc = high nand 0x03
    nand r0         # acc = high & 0x03
    shl r0          # acc = (high & 0x03) << 1
    shl r0          # acc = (high & 0x03) << 2
    shl r0          # acc = (high & 0x03) << 3
    shl r0          # acc = (high & 0x03) << 4
    take r1         # acc = mantissa1 low
    add r0          # acc = mantissa1
    put r1          # r1 = mantissa1[9:0]

    # Add implicit 1 to mantissa1
    lookup 10       # acc = 10 (address for 0x04)
    load r0         # acc = 0x04
    take r1         # acc = mantissa1
    add r0          # acc = mantissa1 + implicit 1
    put r1          # r1 = mantissa1 with implicit 1

    # Load second float
    lookup 2        # acc = 2
    load r0         # acc = mem[2]
    put r5          # r5 = mantissa2 low

    lookup 3        # acc = 3
    load r0         # acc = mem[3]
    put r6          # r6 = high byte2

    # Extract sign2
    lookup 6        # acc = 6
    load r0         # acc = 0x80
    put r10         # r10 = 0x80
    take r6         # acc = high byte2
    nand r10        # acc = high nand 0x80
    nand r0         # acc = high & 0x80
    put r7          # r7 = sign2

    # Extract exponent2
    lookup 7        # acc = 7
    load r0         # acc = 0x1F
    put r10         # r10 = 0x1F
    take r6         # acc = high byte2
    nand r10        # acc = high nand 0x1F
    nand r0         # acc = high & 0x1F
    put r9          # r9 = exponent2

    # Extract mantissa2 high bits
    lookup 8        # acc = 8
    load r0         # acc = 0x03
    put r10         # r10 = 0x03
    take r6         # acc = high byte2
    nand r10        # acc = high nand 0x03
    nand r0         # acc = high & 0x03
    shl r0          # acc = (high & 0x03) << 1
    shl r0          # acc = (high & 0x03) << 2
    shl r0          # acc = (high & 0x03) << 3
    shl r0          # acc = (high & 0x03) << 4
    take r5         # acc = mantissa2 low
    add r0          # acc = mantissa2
    put r5          # r5 = mantissa2[9:0]

    # Add implicit 1 to mantissa2
    lookup 10       # acc = 10
    load r0         # acc = 0x04
    take r5         # acc = mantissa2
    add r0          # acc = mantissa2 + implicit 1
    put r5          # r5 = mantissa2 with implicit 1

    # Check for zero exponents
    lookup 0        # acc = 0
    take r4         # acc = exponent1
    eql r0          # acc = 1 if exp1 == 0
    b0 CHECK_EXP2   # branch if exp1 != 0

    lookup 0        # acc = 0
    put r0          # acc = 0
    lookup 4        # acc = 4
    store r0        # mem[4] = 0
    lookup 5        # acc = 5
    store r0        # mem[5] = 0
    halt            # done (zero result)

CHECK_EXP2:
    lookup 0        # acc = 0
    take r9         # acc = exponent2
    eql r0          # acc = 1 if exp2 == 0
    b0 ALIGN        # branch if exp2 != 0

    lookup 0        # acc = 0
    put r0          # acc = 0
    lookup 4        # acc = 4
    store r0        # mem[4] = 0
    lookup 5        # acc = 5
    store r0        # mem[5] = 0
    halt            # done (zero result)

ALIGN:
    # Align mantissas: shift smaller exponent's mantissa right
    take r4         # acc = exponent1
    sub r9          # acc = exp1 - exp2
    put r10         # r10 = exp1 - exp2
    take r10        # acc = exp1 - exp2
    eql r0          # acc = 1 if exp1 < exp2 (borrow set)
    b0 SHIFT_MANT2  # branch if exp1 >= exp2

    # exp1 < exp2: shift mantissa1 right
    lookup 11       # acc = 11 (address for 0x0F)
    load r0         # acc = 0x0F
    put r12         # r12 = counter
SHIFT_MANT1:
    take r1         # acc = mantissa1
    shr r0          # acc = mantissa1 >> 1
    put r1          # r1 = shifted mantissa1
    lookup 9        # acc = 9
    load r0         # acc = 0x01
    take r4         # acc = exponent1
    add r0          # acc = exp1 + 1
    put r4          # r4 = exp1 + 1
    take r12        # acc = counter
    sub r0          # acc = counter - 1
    put r12         # r12 = counter - 1
    take r12        # acc = counter
    eql r0          # acc = 1 if counter == 0
    b0 SHIFT_MANT1  # loop if counter != 0
    lookup 0        # acc = 0
    b0 ADD_MANT     # jump to addition

SHIFT_MANT2:
    # exp1 >= exp2: shift mantissa2 right
    lookup 11       # acc = 11
    load r0         # acc = 0x0F
    put r12         # r12 = counter
    take r9         # acc = exponent2
    sub r4          # acc = exp2 - exp1
    put r10         # r10 = exp2 - exp1
SHIFT_MANT2_LOOP:
    take r5         # acc = mantissa2
    shr r0          # acc = mantissa2 >> 1
    put r5          # r5 = shifted mantissa2
    lookup 9        # acc = 9
    load r0         # acc = 0x01
    take r9         # acc = exponent2
    add r0          # acc = exp2 + 1
    put r9          # r9 = exp2 + 1
    take r12        # acc = counter
    sub r0          # acc = counter - 1
    put r12         # r12 = counter - 1
    take r12        # acc = counter
    eql r0          # acc = 1 if counter == 0
    b0 SHIFT_MANT2_LOOP  # loop if counter != 0

ADD_MANT:
    # Add or subtract mantissas based on signs
    lookup 0        # acc = 0
    take r3         # acc = sign1
    eql r7          # acc = 1 if sign1 == sign2
    b0 SUB_MANT     # branch to subtract if signs differ

    # Signs same: add mantissas
    take r1         # acc = mantissa1
    add r5          # acc = mantissa1 + mantissa2
    put r11         # r11 = result mantissa
    take r4         # acc = exponent1
    put r12         # r12 = result exponent
    lookup 0        # acc = 0
    take r3         # acc = sign1
    put r13         # r13 = result sign
    b0 NORMALIZE    # jump to normalize

SUB_MANT:
    # Signs differ: subtract mantissas (larger - smaller)
    take r1         # acc = mantissa1
    sub r5          # acc = mantissa1 - mantissa2
    put r11         # r11 = result mantissa
    take r4         # acc = exponent1
    put r12         # r12 = result exponent
    lookup 0        # acc = 0
    take r3         # acc = sign1
    put r13         # r13 = result sign
    take r11        # acc = result mantissa
    eql r0          # acc = 1 if mantissa < 0 (borrow set)
    b0 NORMALIZE    # branch if mantissa >= 0

    # Negative result: flip sign, negate mantissa
    lookup 0        # acc = 0
    take r3         # acc = sign1
    eql r0          # acc = 1 if sign1 == 0
    b0 SET_SIGN2    # branch if sign1 != 0
    lookup 6        # acc = 6
    load r0         # acc = 0x80
    put r13         # r13 = sign (0x80)
    b0 NEGATE_MANT  # jump to negate
SET_SIGN2:
    lookup 0        # acc = 0
    put r13         # r13 = sign (0x00)
NEGATE_MANT:
    take r11        # acc = mantissa
    nand r0         # acc = ~mantissa
    put r11         # r11 = ~mantissa
    lookup 9        # acc = 9
    load r0         # acc = 0x01
    take r11        # acc = ~mantissa
    add r0          # acc = -mantissa
    put r11         # r11 = -mantissa

NORMALIZE:
    # Normalize result: shift left until bit 10 is 1 or counter reaches 0
    lookup 11       # acc = 11
    load r0         # acc = 0x0F
    put r10         # r10 = counter
    lookup 10       # acc = 10
    load r0         # acc = 0x04 (bit 10)
    put r9          # r9 = 0x04
NORM_LOOP:
    take r11        # acc = mantissa
    nand r9         # acc = mantissa nand 0x04
    nand r0         # acc = mantissa & 0x04
    b0 NORM_SHIFT   # branch if bit 10 == 0
    lookup 0        # acc = 0
    b0 STORE        # jump to store if bit 10 == 1
NORM_SHIFT:
    take r11        # acc = mantissa
    shl r0          # acc = mantissa << 1
    put r11         # r11 = shifted mantissa
    lookup 9        # acc = 9
    load r0         # acc = 0x01
    take r12        # acc = exponent
    sub r0          # acc = exp - 1
    put r12         # r12 = exp - 1
    take r10        # acc = counter
    sub r0          # acc = counter - 1
    put r10         # r10 = counter - 1
    take r10        # acc = counter
    eql r0          # acc = 1 if counter == 0
    b0 NORM_LOOP    # loop if counter != 0

STORE:
    # Construct high byte: sign | (exp & 0x1F) | (mantissa[9:8] >> 4)
    lookup 7        # acc = 7
    load r0         # acc = 0x1F
    put r10         # r10 = 0x1F
    take r12        # acc = exponent
    nand r10        # acc = exp nand 0x1F
    nand r0         # acc = exp & 0x1F
    shl r0          # acc = (exp & 0x1F) << 1
    shl r0          # acc = (exp & 0x1F) << 2
    put r12         # r12 = (exp & 0x1F) << 2

    lookup 8        # acc = 8
    load r0         # acc = 0x03
    put r10         # r10 = 0x03
    take r11        # acc = mantissa
    shr r0          # acc = mantissa >> 1
    shr r0          # acc = mantissa >> 2
    shr r0          # acc = mantissa >> 3
    shr r0          # acc = mantissa >> 4
    nand r10        # acc = (mantissa >> 4) nand 0x03
    nand r0         # acc = (mantissa >> 4) & 0x03
    take r12        # acc = (exp & 0x1F) << 2
    add r0          # acc = (exp << 2) | (mantissa[9:8] >> 4)
    take r13        # acc = sign
    add r0          # acc = sign | (exp << 2) | (mantissa[9:8] >> 4)
    put r12         # r12 = high byte

    # Construct low byte: mantissa[7:0]
    take r11        # acc = mantissa
    put r11         # r11 = low byte

    # Store results
    lookup 4        # acc = 4
    store r11       # mem[4] = low byte
    lookup 5        # acc = 5
    store r12       # mem[5] = high byte

    halt            # done
