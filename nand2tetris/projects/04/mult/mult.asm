// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Mult.asm

// Multiplies R0 and R1 and stores the result in R2.
// (R0, R1, R2 refer to RAM[0], RAM[1], and RAM[2], respectively.)

// Put your code here.

// initialize R2 = 0
@R2
M=0

//  for i in range(a):
//      for i in range(b):
//          prod = prod + 1
//  R2 = prod

(LOOP)
    // if R0 = 0, end loop
    @R0
    D=M
    @END
    D;JEQ
    
    // i = i - 1
    @R0
    M=D-1

    // else, R2 = R2 + R1
    @R2
    D=M
    @R1
    D=D+M
    @R2
    M=D

    // restart LOOP
    @LOOP
    0;JMP

(END)
    @END
    0;JMP
