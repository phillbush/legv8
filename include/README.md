Include
=======

This directory contains the header files that should be included in the modules.
These header files define constants such as bus sizes, opcodes bitmasks, memory sizes, etc.

## FILES

All sizes are in bits, except in `memory.vh`, where sizes are in bytes.
* `aluop.vh`:     Size and constant values of the ALU operation control signal bus.
* `bus.vh`:       Various bus sizes (in bits).
* `control.vh`:   Size and bits of the control signal bus that controls the datapath.
* `flags.vh`:     Size and bits of the flags register.
* `forward.vh`:   Size and bits of forward control signal bus.
* `memory.vh`:    Size (in bytes) of the instruction and data memories.
* `movop.vh`:     Size and constant values of the MOV operation control signal.
* `opcode.vh`:    Constants for opcode bitmasks and bitsets.
* `registers.vh`: Constants for internally used register indices (eg, `XLR` and `XZR`).
