Modules
=======

This directory contains the header files that should be included in the modules.
These header files define constants such as bus sizes, opcodes bitmasks, memory sizes, etc.


## FILES

* `aluop.vh`:           Definitions of ALU operations.
* `bus.vh`:             Definitions of bus sizes.
* `control.vh`:         Definitions of control signals.
* `memory.vh`:          Definitions of memory sizes.
* `movop.vh`:           Definitions of MOV operations.
* `opcode.vh`:          Definitions of opcode bitmasks and bitsets.
* `registers.vh`:       Definitions of internally used register addresses.


## Description

**aluop.vh**
This header defines the size of the control signal that defines
the operation to be performed by the Arithmetic Logic Unit (ALU)
and which operation they perform.

**bus.vh**
This header defines bus sizes in bits used by different signals through the CPU.
For example, `BYTESIZE` is the size of a byte (8 bits);
`INSTSIZE` is the size of a LEGv8 instruction (32 bits);
and `WORDSIZE` is the size of a LEGv8 word (64 bits).

**control.vh**
This header defines the size of the control bus that
controls the datapath, and the bits of each control signal.
It also defines constants to test where the writeback data
(that is, the data to be written back on the register file)
comes from.

**memory.vh**
This header defines memory sizes in bytes.
Both the program memory (also known as instruction memory) and the data memory
are defined to be 64 bytes.

**aluop.vh**
This header defines the size of the control signal that defines
the operation to be performed by the Move Unit.
and which operation they perform.

**opcode.vh**
This header defines the bitmasks and bitsets of different formats of opcodes.
For example, a LDUR instruction has the opcode matched by the regular expression
`/..1_1100_0010/`, so the bitmask for a instruction of this format is `..1_1111_1111`,
and the bitset is `001_1100_0010`.

**registers.vh**
This header defines commonly used register addresses,
such as the register `XLR`, which contains the return address saved by `BL` instructions,
and `XZR`, which contains only zeros.
