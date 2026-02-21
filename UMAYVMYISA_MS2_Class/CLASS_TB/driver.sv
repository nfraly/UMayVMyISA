class driver;
    int tx_count1 = 0;
    int tx_count2 = 0;

    virtual intf vif;
    mailbox gen2driv;

    function new(virtual intf vif, mailbox gen2driv);
        this.vif = vif;
        this.gen2driv = gen2driv;
    endfunction

    task reset;
        wait(vif.rst);
        $display("Reset started");
        vif.mem_req <= '0;
        vif.mem_we <= '0;
        vif.mem_addr <= '0;
        vif.mem_write <= '0;
        wait(!vif.rst);
        $display("Reset ended");
    endtask


    task main();
        $display("Driver started");
        forever begin
            transaction tx;
            gen2driv.get(tx);
            @(negedge vif.clk);
            tx_count1++;
            vif.mem_we = tx.mem_we;
            vif.mem_addr = tx.mem_addr;
            vif.mem_write = tx.mem_write;
            vif.mem_req = 1'b1;
            repeat(1) @(negedge vif.clk);
            vif.mem_req = 1'b0;
            wait(vif.done);
        end
    endtask

endclass



