`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "interface.sv"
`include "sequenceItem.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "environment.sv"
`include "test.sv"
//`include "scoreboard.sv"


module top;
    int halfPeriod = 5;

    logic clk;
    logic rst;
    virtual intf vif;

    //interface and dut instantiation go here
    
    initial begin
        uvm_config_db #(vif)::set(null, "*", "vif", intf);
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
