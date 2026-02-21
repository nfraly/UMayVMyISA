class monitor_out;
    int tx_count = 0;
    virtual intf vif;
    mailbox mon_out2scb;

    function new(virtual intf vif, mailbox mon_out2scb);
        this.vif = vif;
        this.mon_out2scb = mon_out2scb;
    endfunction

    task main;
        $display("Monitor_out started");
        forever begin
            transaction tx = new();
            @(posedge vif.clk);
            wait(vif.mem_done);
            tx.mem_read;
            mon_out2scv.put(tx);
            tx_count++;
        end
    endtask
endclass

