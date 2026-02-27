`timescale 1ns/1ns

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../rtl/*.sv"
`include "../rtl/alu/*.sv"
`include "../rtl/arbiter/*.sv"

`include "sequenceItem.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "agent.sv"
`include "environment.sv"
`include "test.sv"
`include "monitor.sv"
//`include "scoreboard.sv"


module top;
    `define PERIOD 10

    logic clk;

    //interface and dut instantiation go here
    
    initial begin
        uvm_config_db #(interface or something)::set(null, "*", "vif", intf);
    end
    
    initial begin
        run_test("");
    end
    
    initial begin
        clock = 0;
        forever begin
            #PERIOD/2 clock = ~clock;
        end
    end
    
    //watchdog timer here later
    
endmodule
