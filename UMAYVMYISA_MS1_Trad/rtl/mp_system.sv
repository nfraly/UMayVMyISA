/* mp_system.sv
* Very minimal system to connect cache ports, arbiter and memory model together for initial bring up
* Next steps include -
*    building out caches/MIU/cores to drive cache2arb with real traffic
*/
module mp_system #(parameter int N = 3) (
  input logic clk,
  input logic resetN
);

  cache_mem_if cache2arb [N] (.clk(clk));
  cache_mem_if arb2mem(.clk(clk));

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