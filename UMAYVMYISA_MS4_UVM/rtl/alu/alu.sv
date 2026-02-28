// alu.sv
// Structural ALU (no + - * / operators in ALU ops).
import opcode_pkg::*;

module alu (
  input  logic [3:0]  alu_op,
  input  logic [31:0] alu_a,
  input  logic [31:0] alu_b,
  output logic [31:0] alu_result,
  output logic        alu_done
);

  logic [31:0] mul_ab;
  logic [63:0] mul2acc_w;
  logic [31:0] sp_res;
  logic [31:0] add_res;
  logic [31:0] sub_res;
  logic [31:0] lsl_res;
  logic [31:0] lsr_res;
  logic [4:0]  shamt_1;

  adder #(.WIDTH(32)) u_add (
    .a(alu_a),
    .b(alu_b),
    .cin(1'b0),
    .sum(add_res),
    .cout()
  );

  subtractor #(.WIDTH(32)) u_sub (
    .a(alu_a),
    .b(alu_b),
    .diff(sub_res),
    .borrow_out()
  );

  assign shamt_1 = 5'd1;

  // Current ALU is combinational (no clock/reset ports)
  boothmul #(.WIDTH(32)) u_mul (
    .w2mul(alu_a),
    .x2mul(alu_b),
    .mul2acc(mul2acc_w)
  );

  assign mul_ab = mul2acc_w[31:0];


  BarrelShifter #(.nBITS(32)) u_shl (
    .In(alu_a),
    .ShiftAmount(shamt_1),
    .ShiftIn(1'b0),
    .Out(lsl_res)
  );

  BarrelShifter #(.nBITS(32)) u_lsr (
    .In(alu_a),
    .ShiftAmount(shamt_1),
    .ShiftIn(1'b1),
    .Out(lsr_res)
  );

  special_functions u_special (
    .op(alu_op),
    .a(alu_a),
    .b(alu_b),
    .mul_ab(mul_ab),
    .result(sp_res)
  );

  always_comb begin
    unique case (opcode_t'(alu_op))
      NOP: alu_result = 32'h0;
      ADD: alu_result = add_res;
      SUB: alu_result = sub_res;
      AND: alu_result = alu_a & alu_b;
      LSL: alu_result = lsl_res;
      LSR: alu_result = lsr_res;

      MUL: alu_result = mul_ab;

      // Special Functions
      SP1, SP2, SP3, SP4, SP5: alu_result = sp_res;

      // Reserved
      RES1, RES2: alu_result = 32'h0;

      default: alu_result = 32'h0;
    endcase

    // Combinational ALU model remains single-cycle visible to IU.
    alu_done = 1'b1;
  end

endmodule
