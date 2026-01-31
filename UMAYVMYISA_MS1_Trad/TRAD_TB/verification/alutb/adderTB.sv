module top;
logic A,B,Sum,Cout,Cin;

fullAdder dut (.A(A), .B(B), .Sum(Sum), .Cout(Cout), .Cin(Cin));
int i;

initial begin
for (i = 0; i < 8; i++) begin
  {A,B,Cin} = i;
#10;

$display ("A is %b B is %b Cin is %b Sum is %b Cout is %b", A, B, Cin, Sum, Cin);
end
end
endmodule


