interface intf(input bit clk, rst);
    parameter CORES = 3;
    parameter ADDR_W = 32;
    localparam corewidth = $clog2(CORES);
   // logic [31:0] instruction;
    logic [corewidth-1:0] targetCore;

    logic instr_valid;
    logic [31:0] instr_word;
    logic [corewidth-1:0] instr_core_sel;
    logic instr_ready;

    logic [CORES-1:0] core_ready_vec;
    logic [CORES-1:0][31:0] core_alu_result_dbg;
    logic [CORES-1:0][4:0] core_rf_raddr_a_dbg;
    logic [CORES-1:0][4:0] core_rf_raddr_b_dbg;
    logic [CORES-1:0][31:0] core_rf_rdata_a_dbg;
    logic [CORES-1:0] core_rf_wen_dbg;
    logic [CORES-1:0][4:0] core_rf_waddr_dbg;
    logic [CORES-1:0][31:0] core_rf_wdata_dbg;
    logic [CORES-1:0] core_iu_mem_req_dbg;
    logic [CORES-1:0] core_iu_mem_we_dbg;
    logic [CORES-1:0][ADDR_W-1:0] core_iu_mem_addr_dbg;
    logic [CORES-1:0][7:0] core_iu_mem_wdata_dbg;
    logic [CORES-1:0] core_iu_mem_done_req;
    logic [CORES-1:0][7:0] core_iu_mem_rdata_dbg;

    logic [CORES-1:0] core_cache_req_valid_dbg;
    logic [CORES-1:0] core_cache_req_we_dbg;
    logic [CORES-1:0][ADDR_W-1:0] core_cache_req_addr_dbg;
    logic [CORES-1:0][7:0] core_cache_req_wdata_dbg;

    logic mem_req_valid_dbg;
    logic mem_req_ready_dbg;
    logic mem_req_we_dbg;
    logic [ADDR_W-1:0] mem_req_addr_dbg;
    logic [7:0] mem_req_wdata_dbg;
    logic mem_resp_valid_dbg;
    logic [7:0] mem_resp_data_dbg;

    logic [ADDR_W-1:0] mem_dbg_addr;
    logic [7:0] mem_dbg_data;




endinterface: intf
