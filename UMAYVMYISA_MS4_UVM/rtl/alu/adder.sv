// adder.sv
module adder #(
  parameter int WIDTH = 32
) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  input  logic             cin,
  output logic [WIDTH-1:0] sum,
  output logic             cout
);

  logic [WIDTH:0] carry;
  assign carry[0] = cin;
  assign cout = carry[WIDTH];

  genvar i;
  generate
    for (i = 0; i < WIDTH; ++i) begin
      fullAdder u_fa (
        .A(a[i]),
        .B(b[i]),
        .Cin(carry[i]),
        .Cout(carry[i+1]),
        .Sum(sum[i])
      );
    end
  endgenerate

endmodule: adder
