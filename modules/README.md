Modules
=======

This directory contains the modules shared by the datapaths of the CPUs.

The datapath instantiates all modules in this directory,
and then guides the data through them.
The datapath begins with the program counter, or PC,
which maintains the address of the next instruction on the program memory.
The program memory outputs the instruction given the output of PC.
The instruction is decoded by the Control Unit and the Branch Control Unit modules.
These two modules controls whether data are written or read,
and where datas goes from and goes to.
The Register File module reads a register from the register file;
and the Sign Extension extends a certain part of the instruction.
The data read from the register file and the data extended by the sign extension
can be used by the Arithmetic Logic Unit (ALU) or by the Move Unit modules to generate
another data, that can be then written into the data memory,
or written back into register file.
The flags register may also be set according to the result of the ALU.
The instruction cycle restarts by setting the Program Counter to point to a new instruction.

Since I consider the (ab)use of `always` blocks to implement combinational circuits
to be a bad hardware description practice,
all the combinational circuits are described using only plain combinational assignments.


## FILES

* `alu.v`:              The Arithmetic Logic Unit (ALU).
* `controlunit.v`:      The Control Unit module.
* `flagsreg.v`:         The Flags Register module.
* `memdata.v`:          The Data Memory module.
* `memprog.v`:          The Program Memory module.
* `mov.v`:              The Move Unit.
* `programcounter.v`:   The Program Counter module.
* `registerfile.v`:     The Register File module.
* `signextension.v`:    The Sign Extension module.


## Description

**The Program Counter Module.**
The program counter module is a sequential circuit
that maintains the program counter register,
that is used to fetch the current instruction.
In addition to the clock and reset inputs,
this module receives a control signal called *branch*
that defines whether the program counter will point to the next instruction
or will “jump” to another instruction.

**The Program Memory Module.**
The program memory module is a sequential circuit
that maintains the program memory, also known as instruction memory.
In addition to the clock and reset inputs,
this module receives an address from the program counter and outputs the instruction at this address.
This instruction is decomposed by the datapath in five parts:
the opcode, the shamt, and three register address (called *Rm*, *Rn*, and *Rd*).

**The Control Unit Module.**
The control unit module receives the opcode as input,
and outputs every control signal that are used by other modules
to control whether data are written or read.
The control signals are also used by the datapath
to control the flow of the data and whether
the program counter “jumps” to another instruction.

**The Sign Extension Module.**
The sign extension module extends part of the instruction according to the opcode.
The extended signal, called *extended*, is directed both to the program counter module
(indicating the offset of the next instruction to be jumped to),
and to the ALU (indicating a immediate operand).

**The Register File Module.**
The register file module is a sequential circuit
that maintains the register file, also known as register bank,
an array of 32 registers of 64 bits each.
In addition to the clock and reset inputs,
this module receives three register addresses, a data to be written,
and a control signal defining whether this data should be written into the register file.
This module outputs two data values read from the register file.

**The Arithmetic Logic Unit (ALU).**
The Arithmetic Logic Unit (ALU) receives three operands
and a control signal that defines which operation must be realized upon the operands.
The operands can be data read from the register file,
or data output by the sign extension module.
The ALU also outputs four flags that can be written into the flags register.
The data result from the operation can be then written back into the register file,
or can be written into the memory,
depending on the control signals.

**The Move Unit**
The move unit receives two operands
and a control signal that defines how the bits of both operand will be merged one into the other.
The data result from the move unit can then be written back into the register file,
depending on the control signals.

**The Flag Register Module.**
The flag register module is a sequential circuit
that maintains the flag register,
a register used by conditional branch instructions.
In addition to the clock and reset inputs,
this module receives the flags to be written,
and a control signal that defines whether those flags must be written into the flags register.
This module outputs the flags stored in the flag register.

**The Data Memory Module.**
The data memory module is a sequential circuit
that maintains the data memory, which contains the data used by the program.
In addition to the clock and reset inputs,
this module receives an address of the data to be written into or read from the data memory,
and a data to be written.
It also receives two control signals thad defines whether data should be read or written.
This module outputs the data read from the data memory.
