interface intf(input bit clk, rst);
    parameter CORES = 3;
    localparam corewidth = $clog2(CORES);
    logic [31:0] instruction;
    logic [corewidth-1:0] targetCore;

endinterface: intf
