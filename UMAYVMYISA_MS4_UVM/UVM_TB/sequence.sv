class traceItem extends uvm_sequence;
    `uvm_object_utils(traceItem);
    parameter N = 3;
    function new(string name = "traceItem");
        super.new(name);
    endfunction

    

    int unsigned addr_base;
    int i, c;

    task body();
        for (c = 0; c < int`(N); c++) begin
            addr_base = (c * 16) % (1<<ADDR_W);

            for(i = 0; i < 4; i++) begin
                trace tx = trace::type_id::create("tx");
                start_item(tx);
                tx.randomize();
                tx.core_id = c;
                tx.we = 1'b1;
                tx.addr = logic`(addr_base + i);
                `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
                finish_item(tx);
            end

            for(i = 0; i < 4; i++) begin
                trace tx = trace::type_id::create("tx");
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

task directedStore(logic [corewidth-1:0] targetCore);
    trace tx = trace::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[3:0] = 4'b0110;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Store test to core %d", targetCore, UVM_LOW);
endtask

task directedLoad(logic [corewidth-1:0] targetCore);
    trace tx = trace::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[3:0] = 4'b0101;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Load test to core %d", targetCore, UVM_LOW);
endtask



endclass


        
