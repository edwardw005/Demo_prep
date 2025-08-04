#!/usr/bin/env python3
"""
Very small two-pass assembler for the adapted 9-bit CSE141L ISA.
Reads `new_fix2flt.asm` and writes `instrom_init.txt`
(one 9-bit binary word per line, max 64 lines).
"""

import sys, re

OPC = {
    'ADD': '000', 'SUB': '001', 'AND': '010',
    'LDI': '011', 'LDR': '100', 'STR': '101',
    'BRZ': '110', 'JMP': '111', 'HALT': '111'
}

REG = {f'R{i}': f'{i:03b}' for i in range(8)}

def parse(src):
    code, labels = [], {}
    for line in src:
        line = line.split(';')[0].strip()
        if not line:
            continue
        if line.endswith(':'):          # label only line
            labels[line[:-1]] = len(code)
        else:
            code.append(line)
    return code, labels

def encode(instr, pc, labels):
    toks = instr.replace(',', ' ').split()
    mnem = toks[0].upper()
    if mnem == 'HALT':
        return '111000000'
    if mnem in ('ADD', 'SUB', 'AND', 'LDR', 'STR'):
        rd, rs = REG[toks[1]], REG[toks[2]]
        return OPC[mnem] + rd + rs
    if mnem == 'LDI':
        rd = REG[toks[1]]
        imm = int(toks[2]) & 0b111
        return OPC[mnem] + rd + f'{imm:03b}'
    if mnem in ('BRZ', 'JMP'):
        addr = labels[toks[1]] if not toks[1].isdigit() else int(toks[1])
        return OPC[mnem] + f'{addr:06b}'
    raise ValueError(f"Unknown instruction at pc {pc}: {instr}")

def main():
    asm_in = open('new_fix2flt.asm')
    code, labels = parse(asm_in)
    out = [encode(c, pc, labels) for pc, c in enumerate(code)]
    with open('instrom_init.txt', 'w') as f:
        f.write('\n'.join(out))
    print(f"Wrote {len(out)} words to instrom_init.txt")

if __name__ == '__main__':
    main()
