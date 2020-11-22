/* mask and bitset of opcodes for shift instructions */
`define SHIFT_MASK      'b111_1111_1110
`define SHIFT_BITSET    'b110_1001_1010

/* mask and bitset of opcodes for R-format instructions */
`define R_MASK          'b100_1111_0001
`define R_BITSET        'b100_0101_0000

/* mask and bitset of opcodes for I-format instructions */
`define I_MASK          'b100_1110_0110
`define I_BITSET        'b100_1000_0000

/* mask and bitset of opcodes for offset branch instructions */
`define B_MASK          'b011_1110_0000
`define B_BITSET        'b000_1010_0000

/* mask and bitset of opcodes for register branch instructions */
`define BR_MASK         'b111_1111_1111
`define BR_BITSET       'b110_1011_0000

/* mask and bitset of opcodes for conditional branch instructions */
`define CB_MASK         'b111_1111_0000
`define CB_BITSET       'b101_1010_0000

/* mask and bitset of opcodes for flag-based branch instructions */
`define BFLAG_MASK      'b111_1111_1000
`define BFLAG_BITSET    'b010_1010_0000

/* mask and bitset of opcodes for all branch-related instructions */
`define BRANCH_MASK     'b000_1110_0000
`define BRANCH_BITSET   'b000_1010_0000

/* mask and bitset of opcodes for memory-load instructions */
`define LDUR_MASK       'b001_1111_1111
`define LDUR_BITSET     'b001_1100_0010

/* mask and bitset of opcodes for memory-store instructions */
`define STUR_MASK       'b001_1111_1111
`define STUR_BITSET     'b001_1100_0000

/* mask and bitset of opcodes for register moving instructions */
`define MOV_MASK        'b110_1111_1100
`define MOV_BITSET      'b110_1001_0100
