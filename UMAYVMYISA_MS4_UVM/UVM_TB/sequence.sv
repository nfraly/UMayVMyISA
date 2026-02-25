class gen_item_seq extends uvm_sequence;
    `uvm_object_utils(gen_item_seq);
    parameter N = 3;
    function new(string name = "gen_item_seq");
        super.new(name);
    endfunction

    

    int unsigned addr_base;
    int i, c;

virtual task body();
    for (c = 0; c < int`(N); c++) begin
        addr_base = (c * 16) % (1<<ADDR_W);

        for(i = 0; i < 4; i++) begin
            reg_item tx = reg_item::type_id::create("tx");
            start_item(tx);
            tx.randomize();
            tx.core_id = c;
            tx.we = 1'b1;
            tx.addr = logic`(addr_base + i);
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
            finish_item(tx);
        end

        for(i = 0; i < 4; i++) begin
            reg_item tx = reg_item::type_id::create("tx");
            start_item(tx);
            tx.randomize();
            tx.core_id = c;
            tx.we = 1'b0;
            tx.addr = logic`(addr_base + i);
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
            finish_item(tx);
        end
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", tx_count), UVM_LOW)
endtask

endclass


        
