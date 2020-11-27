/* control bits output by the control unit */
`define CONTROLSIZE             11
`define REG1LOC                 10
`define REG2LOC                 9

/* control bits passed from ID stage to EX stage */
`define IDEX_CONTROLSIZE        9
`define USEMOV                  8
`define ALU1SRC                 7
`define ALU2SRC                 6

/* control bits passed from EX stage to MEM stage */
`define EXMEM_CONTROLSIZE       6
`define SETFLAGS                5
`define MEMREAD                 4
`define MEMWRITE                3

/* control bits passed from MEM stage to WB stage */
`define MEMWB_CONTROLSIZE       3
`define REGWRITE                2
`define PCTOREG                 1
`define MEMTOREG                0
