// mp_top.sv
// DV-friendly top:
// - Instantiates cores + shared mp_system fabric
// - Accepts one external instruction stream (instr_word + core select)
// - Exposes a simple memory debug read port
import system_widths_pkg::*;

module mp_top #(
  parameter int N = 3,
  parameter int INSTR_COUNT = 4,
  parameter int CORE_SEL_W = (N <= 1) ? 1 : $clog2(N)
) (
  input  logic                    clk,
  input  logic                    resetN,

  // DV instruction injection
  input  logic                    instr_valid,
  input  logic [31:0]             instr_word,
  input  logic [CORE_SEL_W-1:0]   instr_core_sel,
  output logic                    instr_ready,

  // Optional visibility for scoreboards/monitors
  output logic [N-1:0]            core_ready_vec,

  // Per-core ALU/register visibility
  output logic [N-1:0][31:0]      core_alu_result_dbg,
  output logic [N-1:0][4:0]       core_rf_raddr_a_dbg,
  output logic [N-1:0][4:0]       core_rf_raddr_b_dbg,
  output logic [N-1:0][31:0]      core_rf_rdata_a_dbg,
  output logic [N-1:0][31:0]      core_rf_rdata_b_dbg,
  output logic [N-1:0]            core_rf_wen_dbg,
  output logic [N-1:0][4:0]       core_rf_waddr_dbg,
  output logic [N-1:0][31:0]      core_rf_wdata_dbg,

  // Per-core IU->MIU memory intent visibility
  output logic [N-1:0]             core_iu_mem_req_dbg,
  output logic [N-1:0]             core_iu_mem_we_dbg,
  output logic [N-1:0][ADDR_W-1:0] core_iu_mem_addr_dbg,
  output logic [N-1:0][7:0]        core_iu_mem_wdata_dbg,
  output logic [N-1:0]             core_iu_mem_done_dbg,
  output logic [N-1:0][7:0]        core_iu_mem_rdata_dbg,

  // Per-core cache->arbiter visibility
  output logic [N-1:0]             core_cache_req_valid_dbg,
  output logic [N-1:0]             core_cache_req_we_dbg,
  output logic [N-1:0][ADDR_W-1:0] core_cache_req_addr_dbg,
  output logic [N-1:0][7:0]        core_cache_req_wdata_dbg,

  // Shared arbiter->memory visibility
  output logic                     mem_req_valid_dbg,
  output logic                     mem_req_ready_dbg,
  output logic                     mem_req_we_dbg,
  output logic [ADDR_W-1:0]        mem_req_addr_dbg,
  output logic [7:0]               mem_req_wdata_dbg,
  output logic                     mem_resp_valid_dbg,
  output logic [7:0]               mem_resp_data_dbg,

  // Memory debug readback
  input  logic [ADDR_W-1:0]       mem_dbg_addr,
  output logic [7:0]              mem_dbg_data
);

  iu_miu_if iu2miu [N] (.clk(clk));
  instr_if  instr_bus [N]();

  // Shared MIU/Cache/Arbiter/Memory fabric
  mp_system #(.N(N)) u_mp (
    .clk   (clk),
    .resetN(resetN),
    .iu2miu(iu2miu),
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
    .mem_resp_data_dbg(mem_resp_data_dbg)
  );

  // Core cluster
  genvar g;
  generate
    for (g = 0; g < N; g++) begin : G
      core #(.CORE_INDEX(g), .INSTR_COUNT(INSTR_COUNT)) u_core (
        .clk        (clk),
        .resetN     (resetN),
        .miu_if     (iu2miu[g]),
        .instr_in_if(instr_bus[g]),
        .dbg_alu_result(core_alu_result_dbg[g]),
        .dbg_rf_raddr_a(core_rf_raddr_a_dbg[g]),
        .dbg_rf_raddr_b(core_rf_raddr_b_dbg[g]),
        .dbg_rf_rdata_a(core_rf_rdata_a_dbg[g]),
        .dbg_rf_rdata_b(core_rf_rdata_b_dbg[g]),
        .dbg_rf_wen(core_rf_wen_dbg[g]),
        .dbg_rf_waddr(core_rf_waddr_dbg[g]),
        .dbg_rf_wdata(core_rf_wdata_dbg[g])
      );
    end
  endgenerate

  logic [N-1:0] sel_1hot;
  logic [N-1:0] sel_ready;
  genvar gi;

  // Decode selected core into one-hot
  always_comb begin
    sel_1hot = '0;
    for (int i = 0; i < N; i++) begin
      if (instr_core_sel == i[CORE_SEL_W-1:0]) sel_1hot[i] = 1'b1;
    end
  end

  // Route one external instruction stream and debug taps.
  // Use constant indices (generate) for interface arrays (Questa-friendly).
  generate
    for (gi = 0; gi < N; gi++) begin : DBG_ROUTE
      assign instr_bus[gi].instr  = instr_word;
      assign instr_bus[gi].valid  = instr_valid && sel_1hot[gi];
      assign sel_ready[gi]        = instr_bus[gi].ready;
      assign core_ready_vec[gi]   = instr_bus[gi].ready;

      assign core_iu_mem_req_dbg[gi]   = iu2miu[gi].mem_req;
      assign core_iu_mem_we_dbg[gi]    = iu2miu[gi].mem_we;
      assign core_iu_mem_addr_dbg[gi]  = iu2miu[gi].mem_addr;
      assign core_iu_mem_wdata_dbg[gi] = iu2miu[gi].mem_write;
      assign core_iu_mem_done_dbg[gi]  = iu2miu[gi].mem_done;
      assign core_iu_mem_rdata_dbg[gi] = iu2miu[gi].mem_read;
    end
  endgenerate

  // Ready reflects selected core's ready
  always_comb begin
    instr_ready = 1'b0;
    for (int i = 0; i < N; i++) begin
      if (sel_1hot[i]) instr_ready = sel_ready[i];
    end
  end

  // Direct memory visibility for DV
  assign mem_dbg_data = u_mp.u_mem.memory_size[mem_dbg_addr];

endmodule
