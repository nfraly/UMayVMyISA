/* mem_arbiter.sv
* Wrapper for rr_arbiter. Arbitrate N cache ports onto single shared memory port
* Behavior - 
*
*  1) Collect each cache's request signals
*  2) rr_arbiter will produce a one hot grant vector from req_valid
*  3) When not busy, send the granted request to the shared memory port
*  4) Make sure only one transaction is servicsed at a time
*      Lock granted request to owner when accepted
*      Stall all other requests
*      Route memory response back only to the owner
*      Clear busy when response arrives
*/
import system_widths_pkg::*;

module mem_arbiter #(parameter int N = 3) (
  input logic clk,
  input logic resetN,
  cache_mem_if.slave cache_to_arbiter[N],
  cache_mem_if.master arbiter_to_mem
);

  logic [N-1:0] req_valid, req_we, req_ready, resp_valid;
  logic [ADDR_W-1:0] req_addr [N];
  logic [7:0] req_wdata [N];
  logic [7:0] resp_data [N]; 

  // Unpacks each cache's signals into arrays so we can mux them
  // Variable indexing into interface instances is illegal, so we need to do it this way
  genvar g;
  generate
    for (g = 0; g < N; ++g) begin
      // Requests
      assign req_valid[g] = cache_to_arbiter[g].mem_req_valid;
      assign req_we[g] = cache_to_arbiter[g].mem_req_we;
      assign req_addr[g] = cache_to_arbiter[g].mem_req_addr;
      assign req_wdata[g] = cache_to_arbiter[g].mem_req_write;

      // Ready/response 
      assign cache_to_arbiter[g].mem_req_ready = req_ready[g];
      assign cache_to_arbiter[g].mem_resp_valid = resp_valid[g];
      assign cache_to_arbiter[g].mem_resp_data = resp_data[g];
    end
  endgenerate


  // Round robin will select one requesting cache
  rr_if #(N) rr_bus(.clk(clk));
  assign rr_bus.resetN = resetN;

  logic [N-1:0] grant_signal;
  assign rr_bus.req = req_valid;
  assign grant_signal = rr_bus.grant;

  rr_arbiter #(.N(N)) rr(rr_bus);

  // Lock grant to specific core
  // busy = 0 -> can accept new request 
  // busy = 1 -> blocks new requests
  logic busy;
  logic [$clog2(N)-1:0] owner;

  // Return an index from one hot grant
  function automatic logic [$clog2(N)-1:0] onehot_to_index (input logic [N-1:0] one_hot);
    onehot_to_index = '0;
    
    for (int i = 0; i < N; ++i) begin
      if (one_hot[i]) begin
        onehot_to_index = i[$clog2(N)-1:0];
	      break;
      end
    end
  endfunction

  // Used to mux the granted cache request onto arbiter_to_mem 
  logic [$clog2(N)-1:0] sel_index;
  assign sel_index = onehot_to_index(grant_signal);
  logic [$clog2(N)-1:0] arb_owner_sel;

  // Bug injection: Pin arbiter to core 0, starving others
  `ifdef BUG_ARBITER_PIN_CORE0
     assign arb_owner_sel = '0;
  `else
     assign arb_owner_sel = sel_index;
  `endif 

  // Drive granted request onto memory port if not busy
  always_comb begin
  `ifdef BUG_ARBITER_PIN_CORE0
    arbiter_to_mem.mem_req_valid = (!busy) && req_valid[0];
  `else
    arbiter_to_mem.mem_req_valid = (!busy) && (grant_signal != '0);
  `endif
    arbiter_to_mem.mem_req_we = req_we[arb_owner_sel];
    arbiter_to_mem.mem_req_addr = req_addr[arb_owner_sel];
    arbiter_to_mem.mem_req_write = req_wdata[arb_owner_sel];
  end

  // Initially set ready/valid low so only selected cache gets serviced
  // If not busy: granted cache can send request to memory
  // If busy: all new requests wait
  always_comb begin
    for (int i = 0; i < N; ++i) begin
      req_ready[i] = 1'b0;
      resp_valid[i] = 1'b0;
      resp_data[i] = arbiter_to_mem.mem_resp_data;
    end

    if (!busy) begin
    `ifdef BUG_ARBITER_PIN_CORE0
      req_ready[0] = arbiter_to_mem.mem_req_ready;
    `else
      for (int i = 0; i < N; ++i) begin
        if (grant_signal[i]) req_ready[i] = arbiter_to_mem.mem_req_ready;
      end
    `endif
    end
    else begin
      resp_valid[owner] = arbiter_to_mem.mem_resp_valid;
    end
  end

  // Only enable request when the shared port accepts a request (iff valid AND ready) 
  wire enable_req = arbiter_to_mem.mem_req_valid && arbiter_to_mem.mem_req_ready;
  wire enable_resp = arbiter_to_mem.mem_resp_valid;

  // Lock owner when request is accepted. Clear busy when response arrives
  always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
      busy <= 1'b0;
      owner <= '0;
    end
    else begin
      if (enable_req) begin
        busy <= 1'b1;
	  owner <= arb_owner_sel;
	    //owner <= sel_index;
      end
      if (enable_resp) begin
	    busy <= 1'b0;
      end
    end
  end


endmodule: mem_arbiter
