Pipelined CPU with Hazard Detection and Forwarding
==================================================

This directory contains the modules implementing a five-stage pipelined LEGv8 CPU
with hazard detection and data forwarding.
This implementation does not do branch prediction.

## FILES

* `datapath.v`: The datapath for the pipelined CPU.
* `forward.v`:  The data forwarding module.
* `hazard.v`:   The hazard detection module.
* `ifid.v`:     The IF/ID register.
* `idex.v`:     The ID/EX register.
* `exmem.v`:    The EX/MEM register.
* `memwb.v`:    The MEM/WB register.

## DESCRIPTION

Pipelining, or *instruction pipelining*, is a technique for implementing
instruction-level parallelism within a single processor.
In a pipelined CPU, instructions are divided into a series of sequential stages
performed by different processor units.
Instructions are executed in parallel,
and every part of the processor is busy processing one stage of a instruction.

**Classic RISC Pipeline.**
This implementation follows the classic RISC pipeline architecture.
In this architecture, there are five stages:
* **Instruction fetch (IF):**   Fetch instruction from instruction memory.
* **Instruction decode (ID):**  Decode the instruction and read registers.
* **Execution (EX):**           Execute the operation or calculate an address.
* **Memory access (MEM):**      Access (read or write) the data memory, if necessary.
* **Write back (MEM):**         Write data into a register, if necessary.

**Pipeline Registers.**
A pipelined CPU has *pipeline registers* between stages.
Each pipeline register saves the data used by a processor unit at some instruction stage
to be used by the next stage of the same instruction.
On the classic RISC pipeline there are four pipeline registers.
* **IF/ID register:**   The register between the IF and ID stages.
* **ID/EX register:**   The register between the ID and EX stages.
* **EX/MEM register:**  The register between the EX and MEM stages.
* **MEM/WB register:**  The register between the MEM and WB stages.

**Hazards.**
In a pipelined CPU, a instruction begins before the previous one completes;
a situation where this behavior is problematic is known as *hazard*.
A hazard occurs when there is data dependence between instructions, that is,
when a instruction must wait for the previous one to complete
because it is required data computed by this previous instruction.
One technique to overcome hazards is to *stall*, or cease scheduling new instructions,
until the required data is available, and thus the dependency is resolved.
This results in empty slots in the pipeline, or *bubbles*, in which no work is performed.
Hazards are detected by the hazard detection module.

**Forwarding.**
Another technique to overcome hazards is to forward data.
When data forwarding is used, data is forwarded from a pipeline register
to a unit that uses that data as soon as it is available,
before the instruction that generates the data completes.
Data forwarding is controlled by the data forwarding module.


## SEE ALSO

[Wikipedia: Instruction pipelining](https://en.wikipedia.org/wiki/Instruction_pipelining).

[Wikipedia: Classic RISC pipeline](https://en.wikipedia.org/wiki/Classic_RISC_pipeline).

[Wikipedia: Hazard](https://en.wikipedia.org/wiki/Hazard_(computer_architecture)).

[Wikipedia: Pipeline stall](https://en.wikipedia.org/wiki/Pipeline_stall).

[Wikipedia: Operand forwarding](https://en.wikipedia.org/wiki/Operand_forwarding).
