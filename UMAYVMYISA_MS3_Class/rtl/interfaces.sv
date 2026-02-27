// interfaces.sv
package system_widths_pkg;
  localparam int INSTR_W = 32;
  localparam int ADDR_W = 11;
  localparam int REG_W = 32;
endpackage

import system_widths_pkg::*;

// Instruction interface
interface instr_if;
  logic valid, ready;
  logic [31:0] instr;
endinterface

// Instruction Unit and Memory Interface Unit
interface iu_miu_if (input logic clk);
  logic mem_req;		// Request in progress 
  logic mem_we;			// Read = 0, Write = 1
  logic [ADDR_W-1:0] mem_addr;  // Address to access
  logic [7:0] mem_read;		// Read byte
  logic [7:0] mem_write;	// Write byte 
  logic mem_done;		// Transaction complete
  
  // IU drives request fields and write data
  modport iu (
    input clk,
    output mem_req, mem_we, mem_addr, mem_write,
    input mem_read, mem_done
  );

  // MIU accepts request, returns read data and completion
  modport miu (
    input clk,
    input mem_req, mem_we, mem_addr, mem_write,
    output mem_read, mem_done
  );

endinterface

// Memory Interface Unit and Cache
interface miu_cache_if (input logic clk);
  logic cache_req_valid;		// MIU has request pending
  logic cache_req_ready;		// Cache is ready to accept request
  logic cache_req_we;			// Read = 0, Write = 1
  logic [ADDR_W-1:0] cache_req_addr;	// Address to target  
  logic [7:0] cache_req_write;		// Write byte 
  logic [7:0] cache_resp_data;		// Read byte
  logic cache_resp_valid;		// Response is valid -> request done

  // MIU drives request
  modport master (
    output cache_req_valid, cache_req_we, cache_req_addr, cache_req_write,
    input cache_req_ready, cache_resp_valid, cache_resp_data
  );

  // Cache accepts request, drives ready/response
  modport slave (
    input cache_req_valid, cache_req_we, cache_req_addr, cache_req_write,
    output cache_req_ready, cache_resp_valid, cache_resp_data
  );

endinterface

// Cache, Arbiter and Main Memory 
interface cache_mem_if (input logic clk);
  logic mem_req_valid;			// Cache has request pending
  logic mem_req_ready;			// Arbiter/Memory ready to accept
  logic mem_req_we;			// Read = 0, Write = 1
  logic [ADDR_W-1:0] mem_req_addr;	// Address to target
  logic [7:0] mem_req_write;		// Write byte
  logic [7:0] mem_resp_data;		// Read byte
  logic mem_resp_valid;			// Response is valid -> request done 

  // Cache drives request
  modport master (
    output mem_req_valid, mem_req_we, mem_req_addr, mem_req_write,
    input mem_req_ready, mem_resp_valid, mem_resp_data
  );

  // Arbiter/Memory accepts request, drives ready/response
  modport slave (
    input mem_req_valid, mem_req_we, mem_req_addr, mem_req_write,
    output mem_req_ready, mem_resp_valid, mem_resp_data
  );

endinterface

// Snoop Signals
interface snoop_if (input logic clk);
  logic snoop_valid;			// Snoop valid this cycle 
  logic [1:0] snoop_core;		// Indicate which core initiated access
  logic snoop_cmd;			// Read = 0, RFO = 1
  logic [ADDR_W-1:0] snoop_addr;	// The address being snooped

  // Each cache listens for snoop messages
  modport listener (
    input snoop_valid, snoop_core, snoop_cmd, snoop_addr
  ); 

  // Drives snoop messages onto snooping bus 
  modport driver (
    output snoop_valid, snoop_core, snoop_cmd, snoop_addr
  );

endinterface
