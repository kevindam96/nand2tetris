// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// eq
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@EQ0
D;JEQ
@NEQ0
0;JMP
(EQ0)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_EQ0
0;JMP
(NEQ0)
@0
D=A
@SP
A=M
A=A-1
A=A-1
M=D
@SP
M=M-1
(END_EQ0)
// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
// eq
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@EQ1
D;JEQ
@NEQ1
0;JMP
(EQ1)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_EQ1
0;JMP
(NEQ1)
@0
D=A
@SP
A=M
A=A-1
A=A-1
M=D
@SP
M=M-1
(END_EQ1)
// push constant 16
@16
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 17
@17
D=A
@SP
A=M
M=D
@SP
M=M+1
// eq
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@EQ2
D;JEQ
@NEQ2
0;JMP
(EQ2)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_EQ2
0;JMP
(NEQ2)
@0
D=A
@SP
A=M
A=A-1
A=A-1
M=D
@SP
M=M-1
(END_EQ2)
// push constant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@LT0
D;JLT
@NLT0
0;JMP
(LT0)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_LT0
0;JMP
(NLT0)
@0
D=A
@SP
A=M
A=A-1
A=A-1
M=D
@SP
M=M-1
(END_LT0)
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 892
@892
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@LT1
D;JLT
@NLT1
0;JMP
(LT1)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_LT1
0;JMP
(NLT1)
@0
D=A
@SP
A=M
A=A-1
A=A-1
M=D
@SP
M=M-1
(END_LT1)
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 891
@891
D=A
@SP
A=M
M=D
@SP
M=M+1
// lt
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@LT2
D;JLT
@NLT2
0;JMP
(LT2)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_LT2
0;JMP
(NLT2)
@0
D=A
@SP
A=M
A=A-1
A=A-1
M=D
@SP
M=M-1
(END_LT2)
// push constant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// gt
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@GT0
D;JGT
@NGT0
0;JMP
(GT0)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_GT0
0;JMP
(NGT0)
@SP
A=M
A=A-1
A=A-1
M=0
@SP
M=M-1
(END_GT0)
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 32767
@32767
D=A
@SP
A=M
M=D
@SP
M=M+1
// gt
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@GT1
D;JGT
@NGT1
0;JMP
(GT1)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_GT1
0;JMP
(NGT1)
@SP
A=M
A=A-1
A=A-1
M=0
@SP
M=M-1
(END_GT1)
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 32766
@32766
D=A
@SP
A=M
M=D
@SP
M=M+1
// gt
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
@GT2
D;JGT
@NGT2
0;JMP
(GT2)
@SP
A=M
A=A-1
A=A-1
M=-1
@SP
M=M-1
@END_GT2
0;JMP
(NGT2)
@SP
A=M
A=A-1
A=A-1
M=0
@SP
M=M-1
(END_GT2)
// push constant 57
@57
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 31
@31
D=A
@SP
A=M
M=D
@SP
M=M+1
// push constant 53
@53
D=A
@SP
A=M
M=D
@SP
M=M+1
// add
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D+M
A=A-1
M=D
@SP
M=M-1
// push constant 112
@112
D=A
@SP
A=M
M=D
@SP
M=M+1
// sub
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D-M
A=A-1
M=D
@SP
M=M-1
// neg
@SP
A=M
A=A-1
M=-M
// and
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D&M
A=A-1
M=D
@SP
M=M-1
// push constant 82
@82
D=A
@SP
A=M
M=D
@SP
M=M+1
// or
@SP
A=M
A=A-1
A=A-1
D=M
A=A+1
D=D|M
A=A-1
M=D
@SP
M=M-1
// not
@SP
A=M
A=A-1
M=!D
