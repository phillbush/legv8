Sincle-cycle CPU
================

This directory contains the module implementing a single-cycle LEGv8 CPU.

## FILES

* `datapath.v`: The datapath for the pipelined CPU.

## DESCRIPTION

A single-cycle processor is a processor that carries out one instruction in a single clock cycle.
Single-cycle processors are simple in terms of hardware requirements, and are easy to design.
But they tend to have poor data throughput,
and require long clock cycles (slow clock rate)
in order to perform all the necessary computations in time.

**Cycle Times.**
The length of the cycle must be long enough to accommodate the longest instruction.
This means that some instructions (typically the arithmetic instructions)
will complete quickly, and time will be wasted each cycle.
Other instructions (typically memory read or write instructions)
will have a much longer propagation delay.
