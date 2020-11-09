.data
a: .word 1
b: .word 2

.text

// sum a (1) and b (2) into X0
main:
	// load a into X0
	LDA     X0, a
	LDUR    X0, [X0, #0]

	// load b into X1
	LDA     X1, b
	LDUR    X1, [X1, #0]

	// put a+b into X0
	ADD     X0, X0, X1
