LEGv8 Program Samples
=====================

This directory contain simple programs written in LEGv8 assembly.
These programs are made to be compiled with the assembler in
`../tools/asm`, and used to simulate the CPUs in `../cpu-*`.

## FILES

* `sumtwo.s`:   A program that sum two integers.
* `sumarray.s`: A program that sum the elements of an array.


## SUMTWO.S

The program `sumtwo.s` reads two values from memory into the registers
`X0` and `X1', and then sums the values in those registers into the
register `X0'.

Although being simple, this program tests several features of the
CPUs and the assembler:

* It tests the capacity of the assembler to convert the pseudo instruction
  LDA into actual LEGv8 instructions.
* It tests the capacity of the CPU to access data from memory.
* It tests the CPU's Arithmetic Logic Unit (ALU).
* It tests the usage of registers, both to read and to write into them.


## SUMARRAY.S

The program `sumarray.s` reads ten 8-byte elements from the memory into
`X2` and sum them up into `X3`.  `X0` is a pointer to the current element
of the array, and `X1` is the size of the array.

In addition to the tests performed by `sumtwo.s`,
this program tests the capacity of the CPU to branch with the CBZ instruction.
