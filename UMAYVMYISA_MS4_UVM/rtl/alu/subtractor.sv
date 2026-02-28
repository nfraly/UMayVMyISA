// subtractor.sv
// Two's complement subtract: diff = a - b = a + (~b) + 1.
module subtractor #(
  parameter int WIDTH = 32
) (
  input  logic [WIDTH-1:0] a,
  input  logic [WIDTH-1:0] b,
  output logic [WIDTH-1:0] diff,
  output logic             borrow_out
);

  logic carry_out;

  adder #(.WIDTH(WIDTH)) twos_comp (
    .a(a),
    .b(~b),
    .cin(1'b1),
    .sum(diff),
    .cout(carry_out)
  );

  assign borrow_out = ~carry_out;

endmodule: subtractor
