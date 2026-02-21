`include "interface.sv"
`include "env.sv"
module tb;

bit clk;
bit resetN;

initial begin
    clk = 0;
    resetN = 0;
    #10 resetN = 1;
end

initial 
    forever
        #5 clk = ~clk;


environment env;

initial begin
    env = new(intf_top);

    env.run();
end


intf intf_top(clk, resetN);

mp_system DUT (intf_top.clk, intf_top.resetN);

iu_miu_if.iu (.mem_req(intf_top.mem_req), .mem_we(intf_top.mem_we), .mem_addr(intf_top.mem_addr),
              .mem_write(intf_top.mem_write), .mem_read(intf_top.mem_read), .mem_done(intf_top.mem_done));



endmodule


