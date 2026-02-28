// full_adder.sv
module fullAdder (
  input  logic A,
  input  logic B,
  input  logic Cin,
  output logic Cout,
  output logic Sum
);

  assign Sum  = A ^ B ^ Cin;
  assign Cout = (A & B) | ((A ^ B) & Cin);

endmodule: fullAdder