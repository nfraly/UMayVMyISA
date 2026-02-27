/* mp_system.sv
* Minimal multi core system
*   IU -> MIU -> Cache -> Arb/Memory    
*/
module mp_system #(parameter int N = 3) (
  input logic clk,
  input logic resetN
);

  // Per core interface instances
  // IU <-> MIU
  iu_miu_if iu2miu [N] (.clk(clk));
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


endmodule: mp_system