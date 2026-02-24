class gen_item_seq extends uvm_sequence;
    `uvm_object_utils(gen_item_seq);

    function new(string name = "gen_item_seq");
        super.new(name);
    endfunction



    virtual task body();
        repeat(tx_count);
            reg_item tx = reg_item::type_id::create("tx");
            start_item(tx);
            tx.randomize();
            `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
            tx.print();
            finish_item(tx);
        end
        `uvm_info("SEQ", $sformatf("Done generation of %0d items", tx_count), UVM_LOW)
    endtask
endclass


        
