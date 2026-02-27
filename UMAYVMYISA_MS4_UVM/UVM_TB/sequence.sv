class traceItem #(parameter CORES = 3) extends uvm_sequence;
    `uvm_object_utils(traceItem)
    localparam corewidth = $clog2(CORES);
    function new(string name = "traceItem");
        super.new(name);
    endfunction

    


    int unsigned addr_base;
    int i, c;
    trace tx;

    task body();
        tx = trace#(3)::type_id::create("trace"); 
    start_item(tx);
    tx.randomize();
    directedStore(tx.targetCore);
    directedLoad(tx.targetCore);
    directedShiftRight(tx.targetCore);
    directedShiftLeft(tx.targetCore);   
    finish_item(tx);
/*        for (c = 0; c < int`(N); c++) begin
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

*/
    



endtask

task directedStore(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b0110;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Store test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedLoad(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b0101;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Load test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask


task correctStore(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b0110;
    tx.instruction[10:0] = 11'b000011010; //arbitrary memory destination
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a very directed Store test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task correctLoad(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b0101;
    tx.instruction[10:0] = 11'b000011010; // Load from memory address that was previously stored to
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a very directed Load test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedRightShift(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b0111;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Righ Shift test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedLeftShift(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b1000;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Left Shit test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction1(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b1001;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function1 test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction2(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b1010;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function2 test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction3(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b1011;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function3 test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction4(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b1100;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function4 test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction5(logic [corewidth-1:0] targetCore);
    trace tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    tx.randomize();
    tx.instruction[31:28] = 4'b1101;
    tx.targetCore = targetCore;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function5 test to core %d", targetCore), UVM_LOW)
    finish_item(tx);
endtask
endclass 
