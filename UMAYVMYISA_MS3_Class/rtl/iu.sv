/* iu.sv
* Instruction Unit that defines the following behavior - 
* 
* Handles one 32 bit instruction at a time. Decodes the opcode
* and register fields and executes either 
*   NOP, ALU op, LDR/STR, or Reserved
* 
* Regfile interface
*   Drives read addresses for opernds and performs writeback on done
*
* Memory interface (iu_miu_if.iu)
*    Asserts mem_req for LDR/STR and waits for mem_done
* 32 bit instruction, parameterized core, 32 bit width instruction, clk, rst, 
*/
import system_widths_pkg::*;
import opcode_pkg::*;

module instruction_unit (
  input logic clk, 
  input logic resetN,
  input logic instr_valid,
  input logic [31:0] instr_in,

  // Flags
  output logic core_ready_flag,
  output logic alu_busy_flag,
  output logic mem_busy_flag,
  output logic instruction_done_flag,
  output logic illegal_opcode_flag,

  // Regfile signals
  output logic [4:0] rf_addr_a, 
  output logic [4:0] rf_addr_b,
  input logic [31:0] rf_data_a, 
  input logic [31:0] rf_data_b,
  output logic rf_wen,
  output logic [4:0] rf_write_addr, 
  output logic [31:0] rf_write_data,

  // ALU signals 
  output logic [3:0] alu_op,
  output logic [31:0] alu_a,
  output logic [31:0] alu_b,
  input logic [31:0] alu_result,
  input logic alu_done,

  iu_miu_if.iu miu
);

// #################################################################################

  // Simple FSM to handle one instruction (issue mem/ALU -> wait -> done) 
  typedef enum logic [2:0] {IDLE, ISSUE_MEM, WAIT_MEM, ISSUE_ALU, WAIT_ALU, DONE} state_t;
  state_t state;

  // Fields for the current instruction  
  opcode_t op_r;
  logic [4:0] rt_r, ra_r, rb_r;
  logic [ADDR_W-1:0] addr_r;

  // Writeback info (valid/dest/data) when instruction finishes 
  logic wb_valid_r;
  logic [4:0] wb_addr_r;
  logic [31:0] wb_data_r;

  // Used to track if we need to assert illegal op flag on done
  logic illegal_pending_r;

// #################################################################################
// Helpers to determine opcode type

  function automatic bit is_mem_op (opcode_t op);
    return (op == LDR) || (op == STR);
  endfunction

  function automatic bit is_alu_op(opcode_t op);
    return (op inside {ADD, AND, SUB, MUL, LSR, LSL, SP1, SP2, SP3, SP4, SP5});
  endfunction
 
  function automatic bit is_illegal_op (opcode_t op);
    return (op inside {RES1, RES2});
  endfunction

// #################################################################################
// Determines which registers the regfile should read
// Drive ALU inputs, generate flags
// and handles writeback enable

  always_comb begin
    rf_addr_a = 5'd0;
    rf_addr_b = 5'd0;
    rf_wen = 1'b0;
    rf_write_addr = wb_addr_r;
    rf_write_data = wb_data_r;

    alu_op = 4'h0;
    alu_a = 32'h0;
    alu_b = 32'h0;

    core_ready_flag = state == IDLE;
    mem_busy_flag = state inside {ISSUE_MEM, WAIT_MEM};
    alu_busy_flag = state inside {ISSUE_ALU, WAIT_ALU};

    // Regfile and ALU control for operations
    if (state inside {ISSUE_ALU, WAIT_ALU}) begin
      rf_addr_a = ra_r;
      rf_addr_b = rb_r;
      alu_op = op_r;
      alu_a = rf_data_a;
      alu_b = rf_data_b;
    end

    // For STR, select source register directly from instr_in while in IDLE
    // so rf_data_a is ready before a memory request is issued
    if (state == IDLE && instr_valid) begin
      if (opcode_t'(instr_in[31:28]) == STR) rf_addr_a = instr_in[27:23];
    end

    // Set writeback enable only when finished
    if (state == DONE) begin
      rf_wen = wb_valid_r;
    end
  end

// #################################################################################
// Instruction execution state machine

  always_ff @(posedge clk or negedge resetN) begin
    
    // Set signals to 0 regardless of reset
    instruction_done_flag <= 1'b0;
    illegal_opcode_flag <= 1'b0;
    miu.mem_req <= 1'b0;

    // Reset behavior
    if (!resetN) begin
      state <= IDLE;

      op_r <= NOP;
      rt_r <= '0;
      ra_r <= '0;
      rb_r <= '0;
      addr_r <= '0;

      wb_valid_r <= 1'b0;
      wb_addr_r <= 5'd0;
      wb_data_r <= 32'h0;

      illegal_pending_r <= 1'b0;

      miu.mem_we <= 1'b0;
      miu.mem_addr <= '0;
      miu.mem_write <= 8'h00;
    end 
    else begin
  

      case (state)
        IDLE: begin
          wb_valid_r <= 1'b0;
          illegal_pending_r <= 1'b0;

          if (instr_valid) begin
            opcode_t op;
            op = opcode_t'(instr_in[31:28]);

            op_r <= op;
            rt_r <= instr_in[27:23];
            ra_r <= instr_in[22:18];
            rb_r <= instr_in[17:13];
            addr_r <= instr_in[ADDR_W-1:0];

            if (op == NOP) state <= DONE;
           
            else if (is_illegal_op(op)) begin
              illegal_pending_r <= 1'b1;
              state <= DONE;
            end 
	    else if (is_mem_op(op)) begin
              miu.mem_we <= (op == STR);
              miu.mem_addr <= instr_in[ADDR_W-1:0];
              miu.mem_write <= rf_data_a[7:0];
              state <= ISSUE_MEM;
            end 
	    else if (is_alu_op(op)) state <= ISSUE_ALU;
	    else begin
              // Treat any other input as illegal
              illegal_pending_r <= 1'b1;
              state <= DONE;
            end
          end
        end

        ISSUE_MEM: begin
          miu.mem_req <= 1'b1;
          state <= WAIT_MEM;
        end

        WAIT_MEM: begin
	  miu.mem_req <= 1'b1;		// added to test
          if (miu.mem_done) begin
	    miu.mem_req <= 1'b0;	 // added to test
            if (op_r == LDR) begin
              wb_valid_r <= 1'b1;
              wb_addr_r <= rt_r;
	      // Zero pad upper mem_read bits
              wb_data_r <= {24'h0, miu.mem_read};
            end
            state <= DONE;
          end
        end

	// Placeholder if need to wait 1 cycle before WAIT_ALU
        ISSUE_ALU: state <= WAIT_ALU;

        WAIT_ALU: begin
          if (alu_done) begin
            wb_valid_r <= 1'b1;
            wb_addr_r <= rt_r;       
            wb_data_r <= alu_result;
            state <= DONE;
          end
        end

        DONE: begin
          instruction_done_flag <= 1'b1;
          if (illegal_pending_r) illegal_opcode_flag <= 1'b1;
          state <= IDLE;
        end

        default: state <= IDLE;
      endcase
    end
  end


endmodule: instruction_unit
