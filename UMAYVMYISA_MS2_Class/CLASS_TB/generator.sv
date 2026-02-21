`include "transaction.sv"

class generator;
    rand transaction tx;
    mailbox gen2driv;
    int tx_count;

    function new(mailbox gen2driv);
        this.gen2driv = gen2driv;
    endfunction

    task directedCaseWrite;
        tx = new();
        tx.mem_addr = 11'hF3;
        tx.mem_write = 8'hA5;
        tx.mem_we = 1'b1;
        gen2driv.put(tx);
    end

    task directedCaseRead;
        tx = new();
        tx.mem_addr = 11'hF3;
        tx.mem_write = '0;
        tx.mem_we = 1'b0;
        gen2driv.put(tx);
    end


    task main();
        $display("Generator started");
        directedCaseWrite;
        directedCaseRead;
        $display("Generator completed");
    endtask
endclass

