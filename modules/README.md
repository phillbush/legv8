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


## MEMORIES

To simplify the design, this CPU uses the Harvard memory architecture.
This architecture uses two memories:
one for the program itself (the program memory),
and another for the data the program uses (the data memory).
There are thus one module for each memory:
the *Program Memory module* and the *Data Memory module*.
Both memory modules are sequential circuits that receives the clock and reset signals
and that are initialized to the contents of a previously assembled program.

**Program Memory.**
The program memory cannot be written.
One can only read one data at a time on the address provided.
The address to be read is provided by the *Program Counter module*.

**Data Memory.**
The data memory can be either read or written, but not both at the same time.
The address to be read or written to is provided by the *ALU*.
The operation (that is, whether the memory will be read or written) is defined by the *Control Unit*.


## REGISTERS

The processor has some internally used registers implemented as sequential circuit modules.
All internally used registers receive as input the clock and reset signals.

**Program Counter.**
This module maintains a single 64-bit register called *program counter*,
that is used as the address of the program memory to fetch the current instruction from.
This module receives a control signal called `branch`
that defines whether the program counter should point to another instruction
rather than to the next one.
It also receives an offset to be added into the program counter in case of branch.

**Register File.**
This module maintains an array of 32 registers of 64 bits each;
this array is indexed by a 5-bit index.
This module can read two registers and write into another at the same time.
It receives a control signal defining whether the write will occur
(the reads will always occur, but the write will only occur when this control signal is on).
It also receives the indices of the registers to be read,
the index of the register to be written to,
and the 64-bit data to be written.

**Flag Register.**
This module maintain a 4-bit register of flags.
Flags are output by the *ALU* and are used by certain branch instructions to define whether to breanch.
This module receives the flags to be written,
and a control signal defining whether to write or not.
This module always output the current flags.


## SIGN EXTENSION UNIT

The sign extension unit is a module that extends part of the instruction according to its opcode.
The extended signal, called *extended*, is used both as a offset to be added to the *PC*,
or as an immediate to be used as operand on the *ALU* or *MOV* modules.


## OPERATIONAL UNITS

The processor uses two operational units to perform operations on data:
the *Arithmetic Logic Unit* (*ALU*) and the *Movement Unit* (*MOV*).

**Move Unit.**
This module receives two operands
and a control signal that defines how the bits of both operand will be merged one into the other.
The data result from the move unit can then be written back into the register file,
depending on the control signals.

**Arithmetic Logic Unit (ALU).**
This module receives three operands
and a 6-bit control signal that defines which operation must be realized upon the operands.
The operands can be data read from the register file,
or data output by the sign extension module.
The ALU outputs both the result of the operation,
and the four flags that can be written into the flags register.
Each of the six bits that define the operation to be realized is explained below.


## CONTROL UNITS

The processor uses two control units that output control signals,
which will be used by other modules and by multiplexors through the datapath.
There is the *Main Control Unit* (often abbreviated to *Control Unit*),
and the *Branch Control Unit*.

**Main Control Unit.**
This module receives the opcode as input,
and outputs every control signal that are used by other modules
to control multiplexors and whether data are written or read.
The following control signals are output by this module.

* **`REG1LOC`:**
  Controls the mux deciding whether
  the first register index to be read from the register file
  is the `Rn` part of the instruction or the register `X31`.
* **`REG2LOC`:**
  Controls the mux deciding whether
  the second register index to be read from the register file
  is the `Rm` part of the instruction or the `Rt` part of the instruction.
* **`USEMOV`:**
  Controls the mux deciding whether
  to use the result of the *MOV* rather than the result of the *ALU*.
* **`ALU1SRC`:**
  Controls the mux deciding whether
  the first operand of the *ALU* is the first register read from the register file
  or the address at the *PC* register.
* **`ALU2SRC`:**
  Controls the mux deciding whether
  the second operand of the *ALU* is the second register read from the register file
  or the data extended by the sign extension module.
* **`SETFLAGS`:**
  Controls whether the flags output by the *ALU* should be written into the flags register.
* **`MEMREAD`:**
  Controls whether the data memory should be read.
* **`MEMWRITE`:**
  Controls whether the data memory should be written.
* **`REGWRITE`:**
  Controls whether a given data should be written back into the register file.
* **`PCTOREG`:**
  Controls the mux deciding whether
  the data to be written back into the register file is the current address at the *PC* register.
* **`MEMTOREG`:**
  Controls the mux deciding whether
  the data to be written back into the register file is the data read from memory.

**Branch Control Unit.**
This module receives the instruction's opcode,
the second data read from the registers,
the `Rd` part of the instruction,
and the flags read from the flags register.
All this data input to the Branch Control Unit is used to determine whether
the *PC* should be updated to the address output by the *ALU*
(this address is the current *PC* added to an offset).
