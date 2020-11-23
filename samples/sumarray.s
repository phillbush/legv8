.eqv N 80

.data
array: .word 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

.text

/*
 * sum elements from array into X3
 * used registers:
 *      X0 - address of the array
 *      X1 - size of the array
 *      X2 - current element
 *      X3 - accumulation
 */
main:
	LDA     X0, array       /* load address of array into X0 */
	ADDI    X1, XZR, N      /* make X1 = N */
	MOV     X3, XZR         /* clean X3 */
loop_beg:
	CBZ     X1, loop_end
	LDUR    X2, [X0, 0]
	ADD     X3, X3, X2
	SUBI    X1, X1, 8
	ADDI    X0, X0, 8
	B       loop_beg
loop_end:
	/*
	 * FIXME:
	 * We need to have at least three instructions after a branch
	 * instruction for the branch signal to be interpreted by the
	 * pipelined CPU.  The single-cycle CPU works ok though.
	 */
	 ADD    XZR, XZR, XZR
	 ADD    XZR, XZR, XZR
	 ADD    XZR, XZR, XZR
