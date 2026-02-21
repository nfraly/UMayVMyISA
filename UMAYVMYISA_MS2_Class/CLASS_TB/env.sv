`include "generator.sv"
`include "driver.sv"
`include "monitor_in.sv"
`include "monitor_out.sv"
`include "scoreboard.sv"

class environment;
    generator gen;
    driver driv;
    monitor_in mon_in;
    monitor_out mon_out;
    scoreboard scb;

    mailbox gen2driv;
    mailbox mon_in2scb;
    mailbox mon_out2scb;

    virtual intf vif;

    function new(virtual intf vif, mailbox gen2driv, mailbox mon_in2scb, mailbox mon_out2scb);
        this.vif = vif;
        this.gen2driv = gen2driv;
        this.mon_in2scb = mon_in2scb;
        this.mon_out2scb = mon_out2scb;

        gen = new(this.gen2driv);
        driv = new(this.vif, this.gen2driv);
        mon_in = new(this.vif, this.mon_in2scb);
        mon_out = new(this.vif, this.mon_out2scb);
        scb = new(this.vif, this.mon_in2scb, this.mon_out2scb);
    endfunction


    task pre_test();
        driv.reset();
    endtask

    task test();
        fork
            gen.main();
            driv.main();
            mon_in.main();
            mon_out.main();
            scb.main();
        join_none
    endtask

    task post_test();
        //Termination condition placeholder
        repeat(10) @(posedge vif.clk);
        wait(gen2driv.num() == '0);
        wait(mon_in2scb.num() == '0);
        wait(mon_out2scb.num() == '0);
    endtask

    task run;
        pre_test();
        test();
        post_test();
        do while(0);
        $stop;
    endtask
endclass
