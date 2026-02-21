interface intf (input logic clk, rst);
    localparam int ADDR_W = 11;
    localparam int DATA_W = 8;
    logic mem_req;
    logic mem_we;
    logic [ADDR_W-1:0] mem_addr;
    logic [DATA_W-1:0] mem_read;
    logic [DATA_W-1:0] mem_write;
    logic mem_done;
endinterface: intf

