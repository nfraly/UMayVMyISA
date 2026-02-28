/* miu.sv
* IU <-> MIU <-> Cache
* MIU takes a request from the IU and turns it into a cache request 
* The cache response is then redirected back to the IU via MIU
*/

import system_widths_pkg::*;

module miu (
  input  logic clk,
  input  logic resetN,
  iu_miu_if.miu iu_if,
  miu_cache_if.master cache_if
);

  // FSM to manage one request 
  typedef enum logic [1:0] {IDLE, SEND, WAIT_RESP} state_t;
  state_t state;

  // Saves IU request information while waiting on cache
  logic we_r;
  logic [ADDR_W-1:0] addr_r;
  logic [7:0] wdata_r;
  logic req_holdoff_r;

  always_ff @(posedge clk or negedge resetN) begin
    // On reset, start idle with no current requests and responses
    if (!resetN) begin
      state <= IDLE;

      we_r <= 1'b0;
      addr_r <= '0;
      wdata_r <= '0;
      req_holdoff_r <= 1'b0;

      iu_if.mem_done <= 1'b0;
      iu_if.mem_read <= '0;

      cache_if.cache_req_valid <= 1'b0;
      cache_if.cache_req_we <= 1'b0;
      cache_if.cache_req_addr <= '0;
      cache_if.cache_req_write <= '0;
    end 
    else begin
      // Deassert mem_done and assert only on completion
      iu_if.mem_done <= 1'b0;

      case (state)
        IDLE: begin
          cache_if.cache_req_valid <= 1'b0;

          // Allows a. new request only after mem_req goes low
          if (!iu_if.mem_req) req_holdoff_r <= 1'b0;

          // Accept only fully-known requests. 
          // Otherwise LDR/STR can sample X 
          if (iu_if.mem_req && !req_holdoff_r &&
              ((iu_if.mem_we === 1'b0) || (iu_if.mem_we === 1'b1)) &&
              (^iu_if.mem_addr !== 1'bx) &&
              (^iu_if.mem_write !== 1'bx)) begin
            // Save IU request
            we_r <= iu_if.mem_we;
            addr_r <= iu_if.mem_addr;
            wdata_r <= iu_if.mem_write;
            req_holdoff_r <= 1'b1;

            // Drive cache request fields from IU vals
            cache_if.cache_req_we <= iu_if.mem_we;
            cache_if.cache_req_addr <= iu_if.mem_addr;
            cache_if.cache_req_write <= iu_if.mem_write;

            // Begin cache request. SEND waits for accept
            cache_if.cache_req_valid <= 1'b1;
            state <= SEND;
          end
        end

        SEND: begin
          // Need to maintain valid until handshake finishes
          cache_if.cache_req_valid <= 1'b1;

          // Hold we/addr/write stable for request
          cache_if.cache_req_we <= we_r;
          cache_if.cache_req_addr <= addr_r;
          cache_if.cache_req_write <= wdata_r;

	      // Cache accepted request
          if (cache_if.cache_req_ready && cache_if.cache_req_valid) begin
            cache_if.cache_req_valid <= 1'b0;
            state <= WAIT_RESP;
          end
        end

        WAIT_RESP: begin
          cache_if.cache_req_valid <= 1'b0;

          if (cache_if.cache_resp_valid) begin
            // Loads only update mem_read, ignores stores
            if (!we_r) iu_if.mem_read <= cache_if.cache_resp_data;
	        // Indicate we're done
            iu_if.mem_done <= 1'b1;
            state <= IDLE;
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule: miu