import sys
from bitstring import Bits

opcode = {
    'take': 0,
    'put': 1,
    'load': 2,
    'store': 3,
    'xor': 4,
    'nand': 5,
    'shl': 6,
    'shr': 7,
    'lookup': 8,
    'lsn': 9,
    'eql': 10,
    'add': 11,
    'sub': 12,
    'of0': 13,
    'halt': 14,
    'tba': 15
}

registers = {
    'r0': 0, 'r1': 1, 'r2': 2, 'r3': 3,
    'r4': 4, 'r5': 5, 'r6': 6, 'r7': 7,
    'r8': 8, 'r9': 9, 'r10': 10, 'r11': 11,
    'r12': 12, 'r13': 13, 'r14': 14, 'r15': 15
}

LookUp = {
    '0': 0, '1': 1, '2': 2, '3': 3, '4': 4,
    '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
    '10': 10, '11': 11, '12': 12, '13': 13, '14': 14, '15': 15
}

label_table = {}

if __name__ == "__main__":
    args = sys.argv
    if len(args) != 3:
        print("invalid input, correct format: \n\tpython assembler.py <assembly file> <machine_code file>")
        sys.exit(0)

    print("Assembler Launching...")

    # First pass: record label positions
    with open(args[1], 'r') as inFile:
        lineCount = 1
        effective_lineCount = 0
        label = ''
        stored_label = ''
        for line in inFile:
            print(f"Assembling line {lineCount}: {line.strip()}")
            line = line.split('#', 1)[0].strip()  # Remove comments and trailing whitespace
            if ':' in line:
                label = line.split(':', 1)[0].strip()
                instr = line.split(':', 1)[1].strip() if len(line.split(':', 1)) > 1 else ''
            else:
                label = ''
                instr = line

            if label:
                stored_label = label

            words = instr.split()
            print(f"Line {lineCount}: words = {words}")  # Debug output

            if len(words) == 0:
                pass
            elif len(words) == 1:
                if words[0] not in ['halt', 'tba', 'of0']:
                    print(f"invalid instruction format at line {lineCount}: expected 'halt', 'tba', or 'of0'")
                    sys.exit(0)
                effective_lineCount += 1
                if label:
                    label_table[label] = effective_lineCount
                    stored_label = ''
                elif stored_label:
                    label_table[stored_label] = effective_lineCount
                    stored_label = ''
            elif len(words) == 2:
                if words[0] not in ['b0', 'take', 'put', 'load', 'store', 'xor', 'nand', 'shl', 'shr', 'lookup', 'lsn', 'eql', 'add', 'sub']:
                    print(f"invalid instruction format at line {lineCount}: unknown instruction '{words[0]}'")
                    sys.exit(0)
                if words[0] == 'lookup':
                    if words[1] not in LookUp:
                        print(f"invalid instruction format at line {lineCount}: lookup expects 0-15, got '{words[1]}'")
                        sys.exit(0)
                    effective_lineCount += 1
                    if label:
                        label_table[label] = effective_lineCount
                        stored_label = ''
                    elif stored_label:
                        label_table[stored_label] = effective_lineCount
                        stored_label = ''
                elif words[0] == 'b0':
                    effective_lineCount += 1
                    if label:
                        label_table[label] = effective_lineCount
                        stored_label = ''
                    elif stored_label:
                        label_table[stored_label] = effective_lineCount
                        stored_label = ''
                else:
                    if words[1] not in registers:
                        print(f"invalid instruction format at line {lineCount}: expected register r0-r15, got '{words[1]}'")
                        sys.exit(0)
                    effective_lineCount += 1
                    if label:
                        label_table[label] = effective_lineCount
                        stored_label = ''
                    elif stored_label:
                        label_table[stored_label] = effective_lineCount
                        stored_label = ''
            else:
                print(f"invalid instruction format at line {lineCount}: too many arguments")
                sys.exit(0)
            lineCount += 1
        print(f"Label table: {label_table}")

    # Second pass: generate machine code
    with open(args[1], 'r') as theInputFile, open(args[2], 'w') as theOutputFile:
        lineCount = 1
        effective_lineCount = 0
        for line in theInputFile:
            print(f"Assembling line {lineCount}: {line.strip()}")
            line = line.split('#', 1)[0].strip()
            if ':' in line:
                instr = line.split(':', 1)[1].strip() if len(line.split(':', 1)) > 1 else ''
            else:
                instr = line

            words = instr.split()
            print(f"Line {lineCount}: words = {words}")  # Debug output

            if len(words) == 0:
                pass
            elif len(words) == 1:
                effective_lineCount += 1
                op = opcode[words[0]]
                theOutputFile.write(f"0_{format(op, 'b').zfill(4)}_{format(0, 'b').zfill(4)} // {' '.join(words)}\n")
            elif len(words) == 2:
                if words[0] == 'lookup':
                    effective_lineCount += 1
                    op = opcode[words[0]]
                    reg = LookUp[words[1]]
                    theOutputFile.write(f"0_{format(op, 'b').zfill(4)}_{format(reg, 'b').zfill(4)} // {' '.join(words)}\n")
                elif words[0] == 'b0':
                    effective_lineCount += 1
                    if words[1] not in label_table:
                        print(f"Label not exist at line {lineCount}: '{words[1]}'")
                        sys.exit(0)
                    offset = label_table[words[1]] - effective_lineCount
                    if offset < -128 or offset > 127:
                        print(f"Branch offset out of range at line {lineCount}: offset = {offset}")
                        sys.exit(0)
                    theOutputFile.write(f"1_{(Bits(int=offset, length=8).bin)} // {' '.join(words)}\n")
                else:
                    effective_lineCount += 1
                    if words[1] not in registers:
                        print(f"invalid instruction format at line {lineCount}: expected register r0-r15, got '{words[1]}'")
                        sys.exit(0)
                    op = opcode[words[0]]
                    reg = registers[words[1]]
                    theOutputFile.write(f"0_{format(op, 'b').zfill(4)}_{format(reg, 'b').zfill(4)} // {' '.join(words)}\n")
            else:
                print(f"invalid instruction format at line {lineCount}: too many arguments")
                sys.exit(0)
            lineCount += 1

    print("\nAssembler successfully terminated")