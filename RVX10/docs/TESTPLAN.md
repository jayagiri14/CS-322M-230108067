


# RISC-V (RVX10_extended) Processor Test Plan

## Overview

This test plan covers the RISC-V processor with RVX10 extension support.

### Standard RISC-V Instructions Tested
- `add`, `sub`, `and`, `or`, `slt`, `addi`, `lw`, `sw`, `beq`, `jal`

### RVX10 Extension Instructions Tested
- `andn`, `orn`, `xnor`, `abs`, `ror`, `rol`, `min`, `minu`, `max`, `maxu`

## Expected Result

If successful, the processor should write the value **25** to address **100**.

## Test Program



| Address | Machine Code | RISC-V Assembly        | Description                           |
|---------|--------------|------------------------|---------------------------------------|
| 0       | 00500113     | `addi x2, x0, 5`       | x2 = 0 + 5                           |
| 4       | 00C00193     | `addi x3, x0, 12`      | x3 = 0 + 12                          |
| 8       | FF718393     | `addi x7, x3, -9`      | x7 = x3 - 9                          |
| C       | 0023E233     | `xor  x4, x7, x2`      | x4 = x7 ^ x2                         |
| 10      | 0041F2B3     | `and  x5, x3, x4`      | x5 = x3 & x4                         |
| 14      | 004282B3     | `add  x5, x5, x4`      | x5 = x5 + x4                         |
| 18      | 02728863     | `bne  x5, x7, 34`      | if(x5!=x7) PC+=34 (misaligned)       |
| 1C      | 0041A233     | `slt  x4, x3, x4`      | x4 = (x3 < x4)                       |
| 20      | 00020463     | `beq  x4, x0, around`  | if(x4==x0) PC+=8                     |
| 24      | 00000293     | `addi x5, x0, 0`       | x5 = 0                               |
| 28      | 0023A233     | `slt  x4, x7, x2`      | x4 = (x7 < x2)                       |
| 2C      | 005203B3     | `add  x7, x4, x5`      | x7 = x4 + x5                         |
| 30      | 402383B3     | `sub  x7, x7, x2`      | x7 = x7 - x2                         |
| 34      | 0471AA23     | `sw   x14, 149(x3)`    | memory[x3+149] = x14                 |
| 38      | 06002103     | `lw   x2, 96(x0)`      | x2 = memory[0+96]                    |
| 3C      | 005104B3     | `add  x9, x2, x5`      | x9 = x2 + x5                         |
| 40      | 008001EF     | `jal  x3, end`         | x3=PC+4; PC+=16                      |
| 44      | 00100113     | `addi x2, x0, 1`       | x2 = 0 + 1                           |
| 48      | 00910133     | `add  x2, x2, x9`      | x2 = x2 + x9                         |
| 4C      | 0291380B     | `maxu x16, x2, x9`     | x16 = max(x2,x9) (unsigned)          |
| 50      | 00200293     | `addi x5, x0, 2`       | x5 = 0 + 2                           |
| 54      | 0451088B     | `rol  x17, x2, x5`     | x17 = rotate left x2 by x5           |
| 58      | 0091260B     | `xorn x12, x2, x9`     | x12 = x2 ^ (~x9)                     |
| 5C      | 0291068B     | `min  x13, x2, x9`     | x13 = min(x2,x9) (signed)            |
| 60      | 0091158B     | `orn  x11, x2, x9`     | x11 = x2 | (~x9)                     |
| 64      | 06060C8B     | `abs  x12, x12`        | x12 = absolute value of x12          |
| 68      | 0291278B     | `minu x15, x2, x9`     | x15 = min(x2,x9) (unsigned)          |
| 6C      | 0091050B     | `andn x10, x2, x9`     | x10 = x2 & (~x9)                     |
| 70      | 0291170B     | `max  x14, x2, x9`     | x14 = max(x2,x9) (signed)            |
| 74      | 04049A0B     | `ror  x20, x9, x0`     | x20 = rotate right x9 by 0           |
| 78      | 00910033     | `add  x0, x2, x9`      | result discarded                     |
| 7C      | 0221A023     | `sw   x2, 66(x3)`      | memory[x3+66] = x2                   |
| 80      | 00210063     | `beq  x2, x2, 0`       | infinite loop (branches to self)     |
		
		