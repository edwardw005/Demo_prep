# Register assignments
# r0 = accumulator (acc)
# r1 = mantissa (full, after combining low and high parts)
# r2 = high byte of float input (sign, exp, mantissa[9:8])
# r3 = sign bit (0x00 or 0x80)
# r4 = exponent (extracted and unbiased)
# r5 = shift counter (for right shifts)
# r6 = temporary/constant (e.g., 1 for decrement, carry)
# r7 = temporary for constructing output
# r9 = temporary for masks (e.g., 0x80, 0x1F, 0x03)
# r10 = temporary for carry check
# r11 = not used
# r12 = temporary for high byte construction
# r13 = not used
# r14 = not used
# r15 = not used
# r16 = overflow bit (not used)

# Memory constants (pre-loaded)
# [4] = 0x0F (15 for exponent bias)
# [5] = 0x0F (15 for shift counter)
# [6] = 0x80 (sign mask)
# [7] = 0x1F (exponent mask)
# [8] = 0x03 (mantissa high mask)
# [9] = 0x01 (one for decrement/add)
# [10] = 0x04 (implicit 1 position)

    # Load float input: low byte (mantissa[7:0]) and high byte (sign, exp, mantissa[9:8])
    lookup 0        # acc = 0 (address for low byte)
    load r0         # acc = mem[0]
    put r1          # r1 = low byte (mantissa[7:0])

    lookup 1        # acc = 1 (address for high byte)
    load r0         # acc = mem[1]
    put r2          # r2 = high byte

    # Extract sign bit (high[7])
    lookup 6        # acc = 6 (address for 0x80)
    load r0         # acc = 0x80
    put r9          # r9 = 0x80 (sign mask)
    take r2         # acc = high byte
    nand r9         # acc = high nand 0x80
    nand r0         # acc = high & 0x80
    put r3          # r3 = sign bit (0x80 or 0x00)

    # Extract exponent (high[6:2])
    lookup 7        # acc = 7 (address for 0x1F)
    load r0         # acc = 0x1F
    put r9          # r9 = 0x1F (exp mask)
    take r2         # acc = high byte
    nand r9         # acc = high nand 0x1F
    nand r0         # acc = high & 0x1F
    put r4          # r4 = exponent

    # Extract mantissa high bits (high[1:0])
    lookup 8        # acc = 8 (address for 0x03)
    load r0         # acc = 0x03
    put r9          # r9 = 0x03 (mantissa high mask)
    take r2         # acc = high byte
    nand r9         # acc = high nand 0x03
    nand r0         # acc = high & 0x03
    shl r0          # acc = (high & 0x03) << 1
    shl r0          # acc = (high & 0x03) << 2
    shl r0          # acc = (high & 0x03) << 3
    shl r0          # acc = (high & 0x03) << 4
    put r7          # r7 = mantissa[9:8] << 4
    take r1         # acc = low byte (mantissa[7:0])
    add r7          # acc = mantissa[9:0]
    put r1          # r1 = full mantissa

    # Add implicit 1 (at bit 10)
    lookup 10       # acc = 10 (address for 0x04)
    load r0         # acc = 0x04 (1 << 2, representing 1 << 10 in full mantissa)
    take r1         # acc = mantissa
    add r0          # acc = mantissa + implicit 1
    put r1          # r1 = mantissa with implicit 1

    # Check for zero exponent (subnormal or zero)
    lookup 0        # acc = 0
    take r4         # acc = exponent
    eql r0          # acc = 1 if exp == 0, else 0
    b0 NORMAL       # jump to normal processing if exp != 0

    # Trap zero/subnormal: output 0 to [2] and [3]
    lookup 0        # acc = 0
    put r0          # acc = 0
    lookup 2        # acc = 2
    store r0        # mem[2] = 0
    lookup 3        # acc = 3
    store r0        # mem[3] = 0
    halt            # done

NORMAL:
    # Adjust exponent: exp - 15
    lookup 4        # acc = 4 (address for 0x0F)
    load r0         # acc = 0x0F (bias)
    put r9          # r9 = 0x0F
    take r4         # acc = exponent
    sub r9          # acc = exp - 15
    put r4          # r4 = unbiased exponent

    # Initialize shift counter
    lookup 5        # acc = 5 (address for 0x0F)
    load r0         # acc = 0x0F
    put r5          # r5 = shift counter (15)

    # Check if exponent is negative (right shift needed)
    lookup 0        # acc = 0
    take r4         # acc = exp - 15
    eql r0          # acc = 1 if exp < 0 (borrow set), else 0
    b0 LEFT_SHIFT   # jump to left shift if exp >= 0

RIGHT_SHIFT:
    # Shift mantissa right
    lookup 9        # acc = 9 (address for 0x01)
    load r0         # acc = 0x01
    put r6          # r6 = 1
    take r1         # acc = mantissa
    shr r6          # acc = mantissa >> 1
    put r1          # r1 = shifted mantissa

    # Increment exponent, decrement counter
    take r4         # acc = exponent
    add r6          # acc = exp + 1
    put r4          # r4 = exp + 1
    take r5         # acc = counter
    sub r6          # acc = counter - 1
    put r5          # r5 = counter - 1

    take r5         # acc = counter
    eql r0          # acc = 1 if counter == 0, else 0
    b0 RIGHT_SHIFT  # loop back if counter != 0
    lookup 0        # acc = 0
    b0 STORE        # jump to store

LEFT_SHIFT:
    # Shift mantissa left if exponent > 0
    lookup 9        # acc = 9 (address for 0x01)
    load r0         # acc = 0x01
    put r6          # r6 = 1
    take r1         # acc = mantissa
    shl r0          # acc = mantissa << 1
    put r1          # r1 = shifted mantissa

    # Decrement exponent, counter
    take r4         # acc = exponent
    sub r6          # acc = exp - 1
    put r4          # r4 = exp - 1
    take r5         # acc = counter
    sub r6          # acc = counter - 1
    put r5          # r5 = counter - 1

    take r5         # acc = counter
    eql r0          # acc = 1 if counter == 0, else 0
    b0 LEFT_SHIFT   # loop back if counter != 0

STORE:
    # Construct fixed-point output: sign | magnitude
    take r1         # acc = mantissa (shifted)
    put r7          # r7 = magnitude low
    take r3         # acc = sign
    put r12         # r12 = sign (0x80 or 0x00)
    take r7         # acc = magnitude low
    shr r6          # acc = magnitude >> 1
    shr r6          # acc = magnitude >> 2
    shr r6          # acc = magnitude >> 3
    shr r6          # acc = magnitude >> 4
    add r12         # acc = sign | (magnitude >> 4)
    put r12         # r12 = high byte

    # Store results
    lookup 2        # acc = 2
    store r7        # mem[2] = low byte
    lookup 3        # acc = 3
    store r12       # mem[3] = high byte

    halt            # done
