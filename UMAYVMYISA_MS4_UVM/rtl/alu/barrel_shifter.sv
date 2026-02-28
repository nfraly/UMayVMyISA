// barrel_shifter.sv
module BarrelShifter(In, ShiftAmount, ShiftIn, Out);
  parameter nBITS = 32;
  input [nBITS-1:0] In;
  input [$clog2(nBITS)-1:0] ShiftAmount;
  input ShiftIn;
  output [nBITS-1:0] Out;

//   ShiftIn=0 -> logical left shift
//   ShiftIn=1 -> logical right shift
  assign Out = ShiftIn ? (In >> ShiftAmount) : (In << ShiftAmount);

endmodule: BarrelShifter

module TwoToOneMux(A, B, Select, Output);
  parameter nBITS = 32;
  input [nBITS-1:0]A, B;
  input Select;
  output [nBITS-1:0]Output;
  assign Output = Select ? A: B;

endmodule: TwoToOneMux