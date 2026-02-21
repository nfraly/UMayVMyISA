class monitor_in;
    virtual intf vif;
    mailbox mon_in2scb;

    function new(virtual intf vif, mailbox mon_in2scb);
        this.vif = vif;
        this.mon_in2scb = mon_in2scb;
    endfunction

    task main;
        $display("Monitor_in started");
        forever begin
            transaction tx = new();
            @(posedge vif.clk);
            if(vif.mem_req) begin
                tx.mem_we <= vif.mem_we;
                tx.mem_addr <= vif.mem_addr;
                tx.mem_write <= vif.mem_write;
                mon_in2scb.put(tx);
            end
            wait(vif.mem_done);
        end
    endtask
endclass
//Might have to do some timing things here so that we aren't blasting the mailbox while a request is beign served
