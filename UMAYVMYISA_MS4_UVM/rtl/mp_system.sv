/* mp_system.sv
* Minimal multi core system
*   IU -> MIU -> Cache -> Arb/Memory     
*/
import system_widths_pkg::*;

module mp_system #(parameter int N = 3) (
  input logic clk,
  input logic resetN,
  iu_miu_if iu2miu [N], // expose directly for DV side to connect to

  // Debug/visibility: per-core cache->arbiter request view
  output logic [N-1:0]             core_cache_req_valid_dbg,
  output logic [N-1:0]             core_cache_req_we_dbg,
  output logic [N-1:0][ADDR_W-1:0] core_cache_req_addr_dbg,
  output logic [N-1:0][7:0]        core_cache_req_wdata_dbg,

  // Debug/visibility: shared arbiter->memory port view
  output logic                     mem_req_valid_dbg,
  output logic                     mem_req_ready_dbg,
  output logic                     mem_req_we_dbg,
  output logic [ADDR_W-1:0]        mem_req_addr_dbg,
  output logic [7:0]               mem_req_wdata_dbg,
  output logic                     mem_resp_valid_dbg,
  output logic [7:0]               mem_resp_data_dbg
);
  // Per core interface instances
  // MIU <-> Cache
  miu_cache_if miu2cache [N] (.clk(clk));
  // Cache <-> Arbiter
  cache_mem_if cache2arb [N] (.clk(clk));
  // Arbiter <-> Memory
  cache_mem_if arb2mem(.clk(clk));
  // Snoop bus (cache-to-cache invalidation broadcast)
  snoop_if snoop_bus(.clk(clk));

  logic [N-1:0]               snoop_req_valid;
  logic [N-1:0]               snoop_req_cmd;
  logic [N-1:0][ADDR_W-1:0]   snoop_req_addr;
  logic [N-1:0]               snoop_req_grant;
  logic [N-1:0]               snoop_req_done;
  logic [N-1:0]               snoop_proc_busy;
  logic [N-1:0]               snoop_grant_1hot;
  logic                       snoop_any;
  logic [$clog2(N)-1:0]       snoop_grant_idx;
  logic [$clog2(N)-1:0]       snoop_rr_ptr;
  logic                       snoop_txn_active;
  logic                       snoop_wait_capture_r;
  logic [$clog2(N)-1:0]       snoop_txn_owner;
  logic                       snoop_peers_idle;

  // RR snoop grant over cache invalidation requests
  always_comb begin
    int cand;
    snoop_grant_1hot = '0;
    snoop_any = 1'b0;
    snoop_grant_idx = '0;

    if (!snoop_txn_active) begin
      for (int step = 1; step <= N; ++step) begin
        // Check each core as next snoop target  
        cand = (int'(snoop_rr_ptr) + step) % N;

        if (!snoop_any && snoop_req_valid[cand]) begin
          snoop_grant_1hot[cand] = 1'b1;
          snoop_grant_idx = cand[$clog2(N)-1:0];
          snoop_any = 1'b1;
        end
      end
    end
  end

  assign snoop_req_grant = snoop_grant_1hot;

  // Broadcast one snoop command when granted (read or RFO)
  always_comb begin
    snoop_bus.snoop_valid = snoop_any;
    snoop_bus.snoop_core  = snoop_grant_idx[1:0];
    snoop_bus.snoop_cmd   = 1'b1; // default RFO
    snoop_bus.snoop_addr  = '0;

    for (int i = 0; i < N; ++i) begin
      if (snoop_grant_1hot[i]) begin
        snoop_bus.snoop_cmd = snoop_req_cmd[i];
        snoop_bus.snoop_addr = snoop_req_addr[i];
      end
    end
  end

  // Track whether peers are done processing the active snoop transaction
  always_comb begin
    snoop_peers_idle = 1'b1;
    for (int i = 0; i < N; ++i) begin
      if ((snoop_txn_active) && (i[$clog2(N)-1:0] != snoop_txn_owner) && snoop_proc_busy[i]) begin
        snoop_peers_idle = 1'b0;
      end
    end
  end

  // Advance RR pointer on each granted snoop
  always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
      snoop_rr_ptr <= '0;
      snoop_txn_active <= 1'b0;
      snoop_wait_capture_r <= 1'b0;
      snoop_txn_owner <= '0;
      snoop_req_done <= '0;
    end
    else begin
      snoop_req_done <= '0;

      if (!snoop_txn_active) begin
        if (snoop_any) begin
          snoop_rr_ptr <= snoop_grant_idx;
          snoop_txn_active <= 1'b1;
          snoop_wait_capture_r <= 1'b1;
          snoop_txn_owner <= snoop_grant_idx;
        end
      end
      else begin
        // Give listeners 1 cycle to start snoop handling
        if (snoop_wait_capture_r) begin
          snoop_wait_capture_r <= 1'b0;
        end
        else if (snoop_peers_idle) begin
          snoop_req_done[snoop_txn_owner] <= 1'b1;
          snoop_txn_active <= 1'b0;
        end
      end
    end
  end


  genvar g;
  // Create MIU/Cache for each core 
  generate 
    for (g = 0; g < N; ++g) begin
      miu u_miu (
        .clk(clk),
        .resetN(resetN),
        .iu_if(iu2miu[g]),
        .cache_if(miu2cache[g])
      );

      cache #(.CORE_ID(g)) u_cache (
        .clk(clk),
        .resetN(resetN),
        .miu_if(miu2cache[g]),
        .mem_if(cache2arb[g]),
        .snoop(snoop_bus),
        .snoop_req_valid(snoop_req_valid[g]),
        .snoop_req_addr(snoop_req_addr[g]),
        .snoop_req_cmd(snoop_req_cmd[g]),
        .snoop_req_grant(snoop_req_grant[g]),
        .snoop_req_done(snoop_req_done[g]),
        .snoop_proc_busy(snoop_proc_busy[g])
      );

      // Per-core debug taps at cache->arbiter boundary
      assign core_cache_req_valid_dbg[g] = cache2arb[g].mem_req_valid;
      assign core_cache_req_we_dbg[g]    = cache2arb[g].mem_req_we;
      assign core_cache_req_addr_dbg[g]  = cache2arb[g].mem_req_addr;
      assign core_cache_req_wdata_dbg[g] = cache2arb[g].mem_req_write;
    end
  endgenerate

  mem_arbiter #(.N(N)) u_mem_arb (
    .clk(clk),
    .resetN(resetN),
    .cache_to_arbiter(cache2arb),
    .arbiter_to_mem(arb2mem)
  );

  memory u_mem (
    .clk(clk),
    .resetN (resetN),
    .mem_if (arb2mem)
  );

  // Shared-port debug taps
  assign mem_req_valid_dbg = arb2mem.mem_req_valid;
  assign mem_req_ready_dbg = arb2mem.mem_req_ready;
  assign mem_req_we_dbg    = arb2mem.mem_req_we;
  assign mem_req_addr_dbg  = arb2mem.mem_req_addr;
  assign mem_req_wdata_dbg = arb2mem.mem_req_write;
  assign mem_resp_valid_dbg = arb2mem.mem_resp_valid;
  assign mem_resp_data_dbg  = arb2mem.mem_resp_data;


endmodule: mp_system
