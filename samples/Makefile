.SUFFIXES: .s .text .data

SRCS = sumtwo.s sumarray.s
TEXT = ${SRCS:.s=.text}
DATA = ${SRCS:.s=.data}

all: ${TEXT}

.s.text:
	../tools/asm $<

clean:
	-rm ${TEXT} ${DATA}

.PHONY: all clean
