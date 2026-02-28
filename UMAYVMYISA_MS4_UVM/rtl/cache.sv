/* cache.sv
* Initial cache implementation will include 
*
*    Accept MIU reqeusts and pass to shared memory
*    Allow only one transaction at a time
*    Return memory response to MIU
*/

import system_widths_pkg::*;

module cache (
  input logic clk,
  input logic resetN,
  miu_cache_if.slave miu_if, 
  cache_mem_if.master mem_if
);

  logic busy;

  // Accept a new request if not busy and memory is ready
  assign miu_if.cache_req_ready = (!busy) && mem_if.mem_req_ready;

  // Drive MIU request to memory if not busy
  assign mem_if.mem_req_valid = (!busy) && miu_if.cache_req_valid;
  assign mem_if.mem_req_we = miu_if.cache_req_we;
  assign mem_if.mem_req_addr = miu_if.cache_req_addr;
  assign mem_if.mem_req_write = miu_if.cache_req_write;

  // Propagate memory response to MIU
  assign miu_if.cache_resp_valid = busy && mem_if.mem_resp_valid;
  assign miu_if.cache_resp_data = mem_if.mem_resp_data;

  // Handshake logic to accept requests and receive responses
  wire accept_req = (!busy) && miu_if.cache_req_valid && miu_if.cache_req_ready;
  wire got_resp = busy && mem_if.mem_resp_valid;

  // Control one request at a time. 
  // Set busy on accept, clear when memory response arrives
  always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
      busy <= 1'b0;
    end 
    else begin
      if (accept_req) busy <= 1'b1;
      if (got_resp) busy <= 1'b0;
    end
  end

endmodule: cache
