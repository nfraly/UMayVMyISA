class scoreboard;
    mailbox mon_in2scb;
    mailbox mon_out2scb;
    virtual intf vif; 

    byte unsigned ref_mem[10:0];



    function new(virtual intf vif, mailbox mon_in2scb, mailbox mon_out2scb);
        this.mon_in2scb = mon_in2scb;
        this.mon_out2scb = mon_out2scb;
        this.vif = vif;
    endfunction

    function bit comp(byte A, byte B);
        if (A != B)
            return 0;
        else 
            return 1;
    endfunction

    task main;
        fork
            storeData();
            readData();
        join_none
    endtask

    task storeData;
        transaction tx;
        mon_in2scb.get(tx);
        ref_mem[tx.mem_addr] = tx.mem_write;
    endtask

    task readData;
        byte unsigned dataR;
        transaction tx;
        mon_in2scb.get(tx);
        mon_out2scb.get(tx);
        dataR = ref_mem[tx.mem_addr];
        if(!comp(dataR, tx.mem_read)
            $display("Memory Error");
    endtask
endclass
        
        


