class scoreboard;
    mailbox mon_in2scb;
    mailbox mon_out2scb;

    byte unsigned ref_mem[10:0];



    function new(mailbox mon_in2scb, mailbox mon_out2scb);
        this.mon_in2scb = mon_in2scb;
        this.mon_out2scb = mon_out2scb;
    endfunction

    function bit comp(byte A, byte B);
        if (A != B)
            return 0;
        else 
            return 1;
    endfunction

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
        
        


