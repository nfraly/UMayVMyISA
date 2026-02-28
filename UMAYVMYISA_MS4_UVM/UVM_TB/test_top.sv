`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "interface.sv"
`include "sequenceItem.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
`include "agent.sv"
`include "environment.sv"
`include "test.sv"


module top;
    int halfPeriod = 5;

    logic clk;
    logic rst;
    intf vif (clk, rst);

    
    mp_top #(3) DUT (
        .clk(clk),
        .resetN(resetN),
        .instr_valid(vif.instr_valid),
        .instr_word(vif.instr_word),
        .instr_core_sel(vif.instr_core_sel),
        .instr_ready(vif.instr_ready),
        .core_ready_vec(vif.core_ready_vec),
        .core_alu_result_dbg(core_alu_result_dbg),
        .core_rf_raddr_a_dbg(core_rf_raddr_a_dbg),
        .core_rf_raddr_b_dbg(vif.core_rf_raddr_b_dbg),
        .core_rf_rdata_a_dbg(vif.core_rf_rdata_a_dbg),
        .core_rf_rdata_b_dbg(vif.core_rf_rdata_b_dbg),
        .core_rf_wen_dbg(vif.core_rf_wen_dbg),
        .core_rf_waddr_dbg(vif.core_rf_waddr_dbg),
        .core_rf_wdata_dbg(vif.core_rf_wdata_dbg),
        .core_iu_mem_req_dbg(vif.core_iu_mem_req_dbg),
        .core_iu_mem_we_dbg(vif.core_iu_mem_we_dbg),
        .core_iu_mem_addr_dbg(vif.core_iu_mem_addr_dbg),
        .core_iu_mem_wdata_dbg(vif.core_iu_mem_wdata_dbg),
        .core_iu_mem_done_dbg(vif.core_iu_mem_done_dbg),
        .core_iu_mem_rdata_dbg(vif.core_iu_mem_rdata_dbg),
        .core_cache_req_valid_dbg(vif.core_cache_req_valid_dbg),
        .core_cache_req_we_dbg(vif.core_cache_req_we_dbg),
        .core_cache_req_addr_dbg(vif.core_cache_req_addr_dbg),
        .core_cache_req_wdata_dbg(vif.core_cache_req_wdata_dbg),
        .mem_req_valid_dbg(vif.mem_req_valid_dbg),
        .mem_req_ready_dbg(vif.mem_req_valid_dbg),
        .mem_req_we_dbg(vif.mem_req_we_dbg),
        .mem_req_addr_dbg(vif.mem_req_addr_dbg),
        .mem_req_wdata_dbg(vif.mem_req_wdata_dbg),
        .mem_resp_valid_dbg(vif.mem_resp_valid_dbg),
        .mem_resp_data_dbg(vif.mem_resp_data_dbg),
        .mem_dbg_addr(vif.mem_dbg_addr),
        .mem_dbg_data(mem_dbg_data));


    //interface and dut instantiation go here
    
    initial begin
        uvm_config_db #(virtual intf)::set(null, "*", "vif", vif);
    end
    
    initial begin
        run_test("");
    end
    
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    
    //watchdog timer here later
    
endmodule
