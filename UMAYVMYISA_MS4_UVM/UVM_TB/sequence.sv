class traceItem #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(traceItem#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "traceItem");
        super.new(name);
        `uvm_info("SEQ", "Sequence constructor", UVM_MEDIUM)
    endfunction

    


    int unsigned addr_base;
    int i, c;
    trace#(3) tx;

    task body();
    tx = trace#(3)::type_id::create("trace"); 
    //start_item(tx);
    //assert(tx.randomize());
    //directedTestCases();
    reset();
    directedRightShift();
    //finish_item(tx);
/*        for (c = 0; c < int`(N); c++) begin
            addr_base = (c * 16) % (1<<ADDR_W);

            for(i = 0; i < 4; i++) begin
                trace#(3) tx = trace::type_id::create("tx");
                start_item(tx);
                assert(tx.randomize());
                tx.core_id = c;
                tx.we = 1'b1;
                tx.addr = logic`(addr_base + i);
                `uvm_info("SEQ", $sformatf("Generate new item: "), UVM_LOW)
                finish_item(tx);
            end

            for(i = 0; i < 4; i++) begin
                trace#(3) tx = trace::type_id::create("tx");
                start_item(tx);
                assert(tx.randomize());
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

task directedTestCases();
    for(logic [corewidth-1:0]  j = 0; j < CORES; j++) begin
        //directedStore(j);
        //directedLoad(j);
        //correctStore(j);
        //correctLoad(j);
        directedRightShift();
        directedLeftShift();
        directedSpecialFunction1();
        directedSpecialFunction2();
        directedSpecialFunction3();
        directedSpecialFunction4();
        directedSpecialFunction5();
    end
endtask

task directedStore();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize());
    tx.instruction[31:28] = 4'b0110;
    `uvm_info("SEQ", $sformatf("Generated a directed Store test"), UVM_LOW)
    finish_item(tx);
endtask

task directedLoad();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize());
    tx.instruction[31:28] = 4'b0101;
    `uvm_info("SEQ", $sformatf("Generated a directed Load test"), UVM_LOW)
    finish_item(tx);
endtask


task correctStore();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize());
    tx.instruction[31:28] = 4'b0110;
    tx.instruction[10:0] = 11'b000011010; //arbitrary memory destination
    `uvm_info("SEQ", $sformatf("Generated a very directed Store test"), UVM_LOW)
    finish_item(tx);
endtask

task correctLoad();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize());
    tx.instruction[31:28] = 4'b0101;
    tx.instruction[10:0] = 11'b000011010; // Load from memory address that was previously stored to
    `uvm_info("SEQ", $sformatf("Generated a very directed Load test"), UVM_LOW)
    finish_item(tx);
endtask

task directedRightShift();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 0;});
    tx.instruction[31:28] = 4'b0111;
    `uvm_info("SEQ", $sformatf("Generated a directed Righ Shift test"), UVM_LOW)
    finish_item(tx);
endtask

task directedLeftShift();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 0;});
    tx.instruction[31:28] = 4'b1000;
    `uvm_info("SEQ", $sformatf("Generated a directed Left Shit test"), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction1();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 0;});
    tx.instruction[31:28] = 4'b1001;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function1 test"), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction2();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 0;});
    tx.instruction[31:28] = 4'b1010;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function2 test"), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction3();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 0;});
    tx.instruction[31:28] = 4'b1011;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function3 test"), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction4();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 0;});
    tx.instruction[31:28] = 4'b1100;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function4 test"), UVM_LOW)
    finish_item(tx);
endtask

task directedSpecialFunction5();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 0;});
    tx.instruction[31:28] = 4'b1101;
    `uvm_info("SEQ", $sformatf("Generated a directed Special Function5 test"), UVM_LOW)
    finish_item(tx);
endtask

task reset();
    trace#(3) tx = trace#(3)::type_id::create("tx");
    start_item(tx);
    assert(tx.randomize() with {rst == 1;});
    finish_item(tx);
endtask
endclass 
