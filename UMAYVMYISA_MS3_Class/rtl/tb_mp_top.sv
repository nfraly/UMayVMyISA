// tb_mp_top.sv
// Simple smoke TB for mp_top DV-facing interface.
module tb_mp_top;
  import system_widths_pkg::*;
  import opcode_pkg::*;

  localparam int N = 3;
  localparam int CORE_SEL_W = (N <= 1) ? 1 : $clog2(N);

  logic clk;
  logic resetN;

  logic                  instr_valid;
  logic [31:0]           instr_word;
  logic [CORE_SEL_W-1:0] instr_core_sel;
  logic                  instr_ready;

  logic [N-1:0]            core_ready_vec;
  logic [N-1:0][31:0]      core_alu_result_dbg;
  logic [N-1:0][4:0]       core_rf_raddr_a_dbg;
  logic [N-1:0][4:0]       core_rf_raddr_b_dbg;
  logic [N-1:0][31:0]      core_rf_rdata_a_dbg;
  logic [N-1:0][31:0]      core_rf_rdata_b_dbg;
  logic [N-1:0]            core_rf_wen_dbg;
  logic [N-1:0][4:0]       core_rf_waddr_dbg;
  logic [N-1:0][31:0]      core_rf_wdata_dbg;
  logic [N-1:0]            core_iu_mem_req_dbg;
  logic [N-1:0]            core_iu_mem_we_dbg;
  logic [N-1:0][ADDR_W-1:0] core_iu_mem_addr_dbg;
  logic [N-1:0][7:0]       core_iu_mem_wdata_dbg;
  logic [N-1:0]            core_iu_mem_done_dbg;
  logic [N-1:0][7:0]       core_iu_mem_rdata_dbg;

  logic [N-1:0]            core_cache_req_valid_dbg;
  logic [N-1:0]            core_cache_req_we_dbg;
  logic [N-1:0][ADDR_W-1:0] core_cache_req_addr_dbg;
  logic [N-1:0][7:0]       core_cache_req_wdata_dbg;

  logic                     mem_req_valid_dbg;
  logic                     mem_req_ready_dbg;
  logic                     mem_req_we_dbg;
  logic [ADDR_W-1:0]        mem_req_addr_dbg;
  logic [7:0]               mem_req_wdata_dbg;
  logic                     mem_resp_valid_dbg;
  logic [7:0]               mem_resp_data_dbg;

  logic [ADDR_W-1:0]        mem_dbg_addr;
  logic [7:0]               mem_dbg_data;

  mp_top #(.N(N)) dut (
    .clk(clk),
    .resetN(resetN),
    .instr_valid(instr_valid),
    .instr_word(instr_word),
    .instr_core_sel(instr_core_sel),
    .instr_ready(instr_ready),
    .core_ready_vec(core_ready_vec),
    .core_alu_result_dbg(core_alu_result_dbg),
    .core_rf_raddr_a_dbg(core_rf_raddr_a_dbg),
    .core_rf_raddr_b_dbg(core_rf_raddr_b_dbg),
    .core_rf_rdata_a_dbg(core_rf_rdata_a_dbg),
    .core_rf_rdata_b_dbg(core_rf_rdata_b_dbg),
    .core_rf_wen_dbg(core_rf_wen_dbg),
    .core_rf_waddr_dbg(core_rf_waddr_dbg),
    .core_rf_wdata_dbg(core_rf_wdata_dbg),
    .core_iu_mem_req_dbg(core_iu_mem_req_dbg),
    .core_iu_mem_we_dbg(core_iu_mem_we_dbg),
    .core_iu_mem_addr_dbg(core_iu_mem_addr_dbg),
    .core_iu_mem_wdata_dbg(core_iu_mem_wdata_dbg),
    .core_iu_mem_done_dbg(core_iu_mem_done_dbg),
    .core_iu_mem_rdata_dbg(core_iu_mem_rdata_dbg),
    .core_cache_req_valid_dbg(core_cache_req_valid_dbg),
    .core_cache_req_we_dbg(core_cache_req_we_dbg),
    .core_cache_req_addr_dbg(core_cache_req_addr_dbg),
    .core_cache_req_wdata_dbg(core_cache_req_wdata_dbg),
    .mem_req_valid_dbg(mem_req_valid_dbg),
    .mem_req_ready_dbg(mem_req_ready_dbg),
    .mem_req_we_dbg(mem_req_we_dbg),
    .mem_req_addr_dbg(mem_req_addr_dbg),
    .mem_req_wdata_dbg(mem_req_wdata_dbg),
    .mem_resp_valid_dbg(mem_resp_valid_dbg),
    .mem_resp_data_dbg(mem_resp_data_dbg),
    .mem_dbg_addr(mem_dbg_addr),
    .mem_dbg_data(mem_dbg_data)
  );

  initial clk = 1'b0;
  always #5 clk = ~clk;

  task automatic do_reset;
    begin
      resetN = 1'b0;
      repeat (5) @(posedge clk);
      resetN = 1'b1;
      repeat (2) @(posedge clk);
    end
  endtask

  function automatic logic [31:0] make_r(
    input opcode_t op,
    input logic [4:0] rt,
    input logic [4:0] ra,
    input logic [4:0] rb
  );
    logic [31:0] w;
    w = 32'h0;
    w[31:28] = op;
    w[27:23] = rt;
    w[22:18] = ra;
    w[17:13] = rb;
    return w;
  endfunction

  function automatic logic [31:0] make_i(
    input opcode_t op,
    input logic [4:0] rt,
    input logic [ADDR_W-1:0] addr
  );
    logic [31:0] w;
    w = 32'h0;
    w[31:28] = op;
    w[27:23] = rt;
    w[ADDR_W-1:0] = addr;
    return w;
  endfunction

  task automatic send_instr(
    input logic [CORE_SEL_W-1:0] core_sel,
    input logic [31:0] w
  );
    begin
      instr_core_sel = core_sel;
      instr_word = w;
      instr_valid = 1'b1;
      do @(negedge clk); while (instr_ready !== 1'b1);
      @(posedge clk);
      instr_valid = 1'b0;

      $display("[%0t] SEND core=%0d w=0x%08h op=%0b addr=0x%0h",
               $time, core_sel, w, w[31:28], w[ADDR_W-1:0]);
    end
  endtask

  int unsigned ld_count, st_count, mem_txn_count, reg_wr_count;
  bit saw_add_operands, saw_alu_12;

  always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
      ld_count <= 0;
      st_count <= 0;
      mem_txn_count <= 0;
      reg_wr_count <= 0;
      saw_add_operands <= 1'b0;
      saw_alu_12 <= 1'b0;
    end else begin
      if (core_rf_raddr_a_dbg[0] == 5'd1 &&
          core_rf_raddr_b_dbg[0] == 5'd2 &&
          core_rf_rdata_a_dbg[0] == 32'd5 &&
          core_rf_rdata_b_dbg[0] == 32'd7) begin
        saw_add_operands <= 1'b1;
      end

      if (core_alu_result_dbg[0] == 32'd12) saw_alu_12 <= 1'b1;

      if (core_rf_wen_dbg[0]) begin
        reg_wr_count <= reg_wr_count + 1;
        case (reg_wr_count)
          0: if (core_rf_waddr_dbg[0] != 5'd1 || core_rf_wdata_dbg[0] != 32'd5)
               $fatal(1, "REG WRITE[0] mismatch waddr=%0d wdata=%0d",
                      core_rf_waddr_dbg[0], core_rf_wdata_dbg[0]);
          1: if (core_rf_waddr_dbg[0] != 5'd2 || core_rf_wdata_dbg[0] != 32'd7)
               $fatal(1, "REG WRITE[1] mismatch waddr=%0d wdata=%0d",
                      core_rf_waddr_dbg[0], core_rf_wdata_dbg[0]);
          2: if (core_rf_waddr_dbg[0] != 5'd3 || core_rf_wdata_dbg[0] != 32'd12)
               $fatal(1, "REG WRITE[2] mismatch waddr=%0d wdata=%0d",
                      core_rf_waddr_dbg[0], core_rf_wdata_dbg[0]);
          3: if (core_rf_waddr_dbg[0] != 5'd4 || core_rf_wdata_dbg[0] != 32'd12)
               $fatal(1, "REG WRITE[3] mismatch waddr=%0d wdata=%0d",
                      core_rf_waddr_dbg[0], core_rf_wdata_dbg[0]);
          default: ;
        endcase
      end

      if (mem_req_valid_dbg && mem_req_ready_dbg) begin
        case (mem_txn_count)
          0: if (mem_req_we_dbg !== 1'b0 || mem_req_addr_dbg !== 11'h000)
               $fatal(1, "MEM_REQ[0] mismatch we=%0b addr=0x%0h",
                      mem_req_we_dbg, mem_req_addr_dbg);
          1: if (mem_req_we_dbg !== 1'b0 || mem_req_addr_dbg !== 11'h001)
               $fatal(1, "MEM_REQ[1] mismatch we=%0b addr=0x%0h",
                      mem_req_we_dbg, mem_req_addr_dbg);
          2: if (mem_req_we_dbg !== 1'b1 || mem_req_addr_dbg !== 11'h010 || mem_req_wdata_dbg !== 8'h0c)
               $fatal(1, "MEM_REQ[2] mismatch we=%0b addr=0x%0h wdata=0x%0h",
                      mem_req_we_dbg, mem_req_addr_dbg, mem_req_wdata_dbg);
          3: if (mem_req_we_dbg !== 1'b0 || mem_req_addr_dbg !== 11'h010)
               $fatal(1, "MEM_REQ[3] mismatch we=%0b addr=0x%0h",
                      mem_req_we_dbg, mem_req_addr_dbg);
          default: ;
        endcase
        mem_txn_count <= mem_txn_count + 1;

        if (mem_req_we_dbg) st_count <= st_count + 1;
        else                ld_count <= ld_count + 1;

        $display("[%0t] MEM_REQ we=%0b addr=0x%0h wdata=0x%0h",
                 $time, mem_req_we_dbg, mem_req_addr_dbg, mem_req_wdata_dbg);
      end
      if (mem_resp_valid_dbg) begin
        $display("[%0t] MEM_RSP data=0x%0h", $time, mem_resp_data_dbg);
      end
    end
  end

  initial begin : MAIN
    int unsigned timeout;

    instr_valid = 1'b0;
    instr_word = 32'h0;
    instr_core_sel = '0;
    mem_dbg_addr = '0;

    do_reset();

    mem_dbg_addr = 11'h000;
    @(posedge clk);
    if (mem_dbg_data !== 8'h05)
      $fatal(1, "INIT FAIL: mem[0x000]=0x%0h expected 0x05", mem_dbg_data);

    mem_dbg_addr = 11'h001;
    @(posedge clk);
    if (mem_dbg_data !== 8'h07)
      $fatal(1, "INIT FAIL: mem[0x001]=0x%0h expected 0x07", mem_dbg_data);

    // Program on core0:
    //   r1 = MEM[0x000] (5)
    //   r2 = MEM[0x001] (7)
    //   r3 = r1 + r2    (12)
    //   MEM[0x010] = r3
    //   r4 = MEM[0x010] (12)
    //   NOP
    send_instr('0, make_i(LDR, 5'd1, 11'h000));
    send_instr('0, make_i(LDR, 5'd2, 11'h001));
    send_instr('0, make_r(ADD, 5'd3, 5'd1, 5'd2));
    send_instr('0, make_i(STR, 5'd3, 11'h010));
    send_instr('0, make_i(LDR, 5'd4, 11'h010));
    send_instr('0, 32'h0000_0000);

    timeout = 0;
    while ((timeout < 2000) && (ld_count < 3 || st_count < 1)) begin
      @(posedge clk);
      timeout++;
    end

    if (ld_count < 3 || st_count < 1)
      $fatal(1, "FAIL: expected ld>=3 st>=1 got ld=%0d st=%0d", ld_count, st_count);
    if (mem_txn_count < 4)
      $fatal(1, "FAIL: expected >=4 memory bus transactions, got %0d", mem_txn_count);
    if (!saw_add_operands)
      $fatal(1, "FAIL: did not observe expected ADD operand register values on debug ports");
    if (!saw_alu_12)
      $fatal(1, "FAIL: did not observe ALU result 12 on debug port");
    if (reg_wr_count < 4)
      $fatal(1, "FAIL: expected >=4 register writes, got %0d", reg_wr_count);

    mem_dbg_addr = 11'h010;
    @(posedge clk);
    if (mem_dbg_data !== 8'h0c)
      $fatal(1, "FAIL: mem[0x010]=0x%0h expected 0x0c", mem_dbg_data);

    repeat (5) @(posedge clk);

    if (dut.G[0].u_core.u_rf.regs[1] !== 32'd5)  $fatal(1, "r1 mismatch");
    if (dut.G[0].u_core.u_rf.regs[2] !== 32'd7)  $fatal(1, "r2 mismatch");
    if (dut.G[0].u_core.u_rf.regs[3] !== 32'd12) $fatal(1, "r3 mismatch");
    if (dut.G[0].u_core.u_rf.regs[4] !== 32'd12) $fatal(1, "r4 mismatch");

    $display("PASS tb_mp_top: r1=%0d r2=%0d r3=%0d r4=%0d ld=%0d st=%0d mem_txn=%0d reg_wr=%0d",
             dut.G[0].u_core.u_rf.regs[1],
             dut.G[0].u_core.u_rf.regs[2],
             dut.G[0].u_core.u_rf.regs[3],
             dut.G[0].u_core.u_rf.regs[4],
             ld_count, st_count, mem_txn_count, reg_wr_count);
    $finish;
  end

endmodule
