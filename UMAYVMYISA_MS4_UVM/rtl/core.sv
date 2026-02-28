/* core.sv
* Brints together IU + regfile+ ALU
*/
import system_widths_pkg::*;

module core #(
  parameter int CORE_INDEX   = 0,
  parameter int INSTR_COUNT  = 4
)(
  input logic clk,
  input logic resetN,
  iu_miu_if.iu miu_if,
  instr_if instr_in_if,

  // Debug visibility
  output logic [31:0] dbg_alu_result,
  output logic [4:0]  dbg_rf_raddr_a,
  output logic [4:0]  dbg_rf_raddr_b,
  output logic [31:0] dbg_rf_rdata_a,
  output logic [31:0] dbg_rf_rdata_b,
  output logic        dbg_rf_wen,
  output logic [4:0]  dbg_rf_waddr,
  output logic [31:0] dbg_rf_wdata
);

  // Used to hold instructions
  logic [31:0] entry [0:INSTR_COUNT-1];

// Test for NOPs
  initial begin
    for (int i = 0; i < INSTR_COUNT; i++) 
      entry[i] = 32'h0;
  end

  // *** Remove pc and entry if DV is only going to test design *** 
  // Keep for now
  int unsigned pc;

  logic        instr_valid;
  logic [31:0] instr_in;

  // IU <-> Regfile
  logic [4:0]  rf_addr_a, rf_addr_b, rf_write_addr;
  logic [31:0] rf_data_a, rf_data_b, rf_write_data;
  logic        rf_wen;

  // IU <-> ALU
  logic [3:0]  alu_op;
  logic [31:0] alu_a, alu_b, alu_result;
  logic        alu_done;

  // Flags
  logic core_ready_flag, alu_busy_flag, mem_busy_flag;
  logic instruction_done_flag, illegal_opcode_flag;

  //assign instr_in_if.ready = core_ready_flag && !instruction_done_flag;

  always_comb instr_in_if.ready = core_ready_flag && !instruction_done_flag;

  assign instr_in    = instr_in_if.instr;
  assign instr_valid = instr_in_if.valid && instr_in_if.ready;
  //assign instr_valid = instr_in_if.valid && instr_in_if.ready;

  // Export key ALU/regfile debug signals
  assign dbg_alu_result = alu_result;
  assign dbg_rf_raddr_a = rf_addr_a;
  assign dbg_rf_raddr_b = rf_addr_b;
  assign dbg_rf_rdata_a = rf_data_a;
  assign dbg_rf_rdata_b = rf_data_b;
  assign dbg_rf_wen     = rf_wen;
  assign dbg_rf_waddr   = rf_write_addr;
  assign dbg_rf_wdata   = rf_write_data;

// Comment out for testing
  // Increment pc when instruction finishes
//  always_ff @(posedge clk or negedge resetN) begin
  //  if (!resetN) pc <= 0;
    //else if (!instr_in_if.valid && instruction_done_flag) pc <= pc + 1;
  //end

  instruction_unit u_iu (
    .clk(clk),
    .resetN(resetN),
    .instr_valid(instr_valid),
    .instr_in(instr_in),

    .core_ready_flag(core_ready_flag),
    .alu_busy_flag(alu_busy_flag),
    .mem_busy_flag(mem_busy_flag),
    .instruction_done_flag(instruction_done_flag),
    .illegal_opcode_flag(illegal_opcode_flag),

    .rf_addr_a(rf_addr_a),
    .rf_addr_b(rf_addr_b),
    .rf_data_a(rf_data_a),
    .rf_data_b(rf_data_b),
    .rf_wen(rf_wen),
    .rf_write_addr(rf_write_addr),
    .rf_write_data(rf_write_data),

    .alu_op(alu_op),
    .alu_a(alu_a),
    .alu_b(alu_b),
    .alu_result(alu_result),
    .alu_done(alu_done),

    .miu(miu_if)
  );

  regfile u_rf (
    .clk(clk),
    .resetN(resetN),
    .raddr_a(rf_addr_a),
    .raddr_b(rf_addr_b),
    .rdata_a(rf_data_a),
    .rdata_b(rf_data_b),
    .wen(rf_wen),
    .waddr(rf_write_addr),
    .wdata(rf_write_data)
  );

  alu u_alu (
    .alu_op(alu_op),
    .alu_a(alu_a),
    .alu_b(alu_b),
    .alu_result(alu_result),
    .alu_done(alu_done)
  );

endmodule
