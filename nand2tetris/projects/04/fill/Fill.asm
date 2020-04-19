// This file is part of www.nand2tetris.org
// and the book "The Elements of Computing Systems"
// by Nisan and Schocken, MIT Press.
// File name: projects/04/Fill.asm

// Runs an infinite loop that listens to the keyboard input.
// When a key is pressed (any key), the program blackens the screen,
// i.e. writes "black" in every pixel;
// the screen should remain fully black as long as the key is pressed. 
// When no key is pressed, the program clears the screen, i.e. writes
// "white" in every pixel;
// the screen should remain fully clear as long as no key is pressed.

// Put your code here.

// Infinite loop
(LOOP)

    // Initialize index i
    @i
    M=0
        
    // Probe keyboard
    @24576
    D=M

    // If KBD=0 goto @CLEARLOOP
    @CLEARLOOP
    D;JEQ

    // Else KBD!=0 goto @FILLLOOP
    @FILLLOOP
    0;JMP

    // Loop through screen memory map
    (CLEARLOOP)
    // if i==8193 goto LOOP
    @i
    D=M
    @8192
    D=D-A
    @LOOP
    D;JEQ

    // SCREEN[i] = 0
    @16384
    D=A
    @i
    A=D+M
    M=0

    // i++
    @i
    M=M+1

    // goto CLEARLOOP
    @CLEARLOOP
    0;JMP

    // Loop through screen memory map
    (FILLLOOP)
    // if (i==8192) goto LOOP
    @i
    D=M
    @8192
    D=D-A
    @LOOP
    D;JEQ
    
    // SCREEN[i] = 1
    @16384
    D=A
    @i
    A=D+M
    M=-1
    
    // i++
    @i
    M=M+1

    // goto FILLLOOP
    @FILLLOOP
    0;JMP
