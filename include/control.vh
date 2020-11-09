/* last two bits of ALU operation code */
`define CONTROLSIZE     9
`define REG1LOC         8
`define REG2LOC         7
`define MEMREAD         6
`define MEMWRITE        5
`define SETFLAGS        4
`define ALUSRC          3
`define REGWRITE        2
`define REGSRC1         1
`define REGSRC0         0

/* where the data to be written on the registers come from */
`define REGSRC_PC       2'b11
`define REGSRC_MOV      2'b10
`define REGSRC_MEM      2'b01
`define REGSRC_ALU      2'b00
