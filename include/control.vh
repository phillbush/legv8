/* control bits output by the control unit */
`define CONTROLSIZE             10
`define REG1LOC                 9
`define REG2LOC                 8

/* control bits passed from ID stage to EX stage */
`define IDEX_CONTROLSIZE        8
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
`define REGSRC1                 1
`define REGSRC0                 0

/* where the data to be written on the registers come from */
`define REGSRC_PC               2'b11
`define REGSRC_MOV              2'b10
`define REGSRC_MEM              2'b01
`define REGSRC_ALU              2'b00
