// special_functions.sv
// Special ALU operations built from structural sub modules.
import opcode_pkg::*;

module special_functions (
  input  logic [3:0]  op,
  input  logic [31:0] a,
  input  logic [31:0] b,
  input  logic [31:0] mul_ab,
  output logic [31:0] result
);

  logic [31:0] sp1_res, sp2_res, sp3_res, sp4_res, sp5_res;
  logic [31:0] mul_shl2;
  logic [31:0] a_x2;
  logic [4:0]  shamt_2;

  assign shamt_2 = 5'd2;

  // SP1 = (a*b) - a
  subtractor #(.WIDTH(32)) u_sp1_sub (
    .a(mul_ab),
    .b(a),
    .diff(sp1_res),
    .borrow_out()
  );

  // SP2 = ((a*b) << 2) - a
  BarrelShifter #(.nBITS(32)) u_sp2_shl2 (
    .In(mul_ab),
    .ShiftAmount(shamt_2),
    .ShiftIn(1'b0),
    .Out(mul_shl2)
  );

  subtractor #(.WIDTH(32)) u_sp2_sub (
    .a(mul_shl2),
    .b(a),
    .diff(sp2_res),
    .borrow_out()
  );

  // SP3 = (a*b) + a
  adder #(.WIDTH(32)) u_sp3_add (
    .a(mul_ab),
    .b(a),
    .cin(1'b0),
    .sum(sp3_res),
    .cout()
  );

  // SP4 = (a*2) + a
  adder #(.WIDTH(32)) u_sp4_add0 (
    .a(a),
    .b(a),
    .cin(1'b0),
    .sum(a_x2),
    .cout()
  );

  adder #(.WIDTH(32)) u_sp4_add1 (
    .a(a_x2),
    .b(a),
    .cin(1'b0),
    .sum(sp4_res),
    .cout()
  );

  // SP5 = (a*b) + b
  adder #(.WIDTH(32)) u_sp5_add (
    .a(mul_ab),
    .b(b),
    .cin(1'b0),
    .sum(sp5_res),
    .cout()
  );

  always_comb begin
    unique case (opcode_t'(op))
      SP1: result = sp1_res;
      SP2: result = sp2_res;
      SP3: result = sp3_res;
      SP4: result = sp4_res;
      SP5: result = sp5_res;
      default: result = 32'h0;
    endcase
  end

endmodule: special_functions
