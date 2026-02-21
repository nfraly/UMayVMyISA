// memory.sv
// Byte addressable 2KB memory model 
import system_widths_pkg::*;

module memory (
  input logic clk,
  input logic resetN,
  cache_mem_if.slave mem_if
);

  // Calculate memory size 
  localparam int DEPTH = (1 << ADDR_W);
  // Byte addressable memory of size DEPTH
  logic [7:0] memory_size [0:DEPTH-1];

  // Currently always ready (need to eventually update to reflect if memory is busy)
  assign mem_if.mem_req_ready = 1;


  // Register the response 
  logic [7:0] resp_data_r;
  logic resp_valid_r;

  assign mem_if.mem_resp_data = resp_data_r;
  assign mem_if.mem_resp_valid = resp_valid_r;

  // 1 cycle response for Loads/Stores
  always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
      // Clear memory on reset
      for (int i = 0; i < DEPTH; ++i) memory_size[i] <= '0;
      resp_data_r <= '0;
      resp_valid_r <= 0;
    end
    else begin 
      resp_valid_r <= 0;
      if (mem_if.mem_req_valid && mem_if.mem_req_ready) begin
	    if (!mem_if.mem_req_we) begin
	      // Load Branch 
	      resp_data_r <= memory_size[mem_if.mem_req_addr];
	      resp_valid_r <= 1;
	    end
	    else begin
 	      memory_size[mem_if.mem_req_addr] <= mem_if.mem_req_write;
   	      // Store Branch
	      resp_data_r <= '0;	// Don't care for stores
	      resp_valid_r <= 1;
	    end
      end
    end
  end


endmodule: memory