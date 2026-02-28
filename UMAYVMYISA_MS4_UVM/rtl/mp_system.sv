/* mp_system.sv
* Minimal multi core system
*   IU -> MIU -> Cache -> Arb/Memory     
*/
import system_widths_pkg::*;

module mp_system #(parameter int N = 3) (
  input logic clk,
  input logic resetN,
  iu_miu_if iu2miu [N],	// expose directly for DV side to connect to

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

      cache u_cache (
        .clk(clk),
	.resetN(resetN),
	.miu_if(miu2cache[g]),
	.mem_if(cache2arb[g])
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