class testClean #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(testClean#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "testClean");
        super.new(name);
        `uvm_info("TESTCLEAN", "TESTCLEAN constructor", UVM_HIGH)
    endfunction

    logic [corewidth-1:0] core;

    task body();
        for (core = 0; core < CORES; core++) begin
            loadHit(core);
            loadMiss(core);
            storeHit(core);
            storeMiss(core);
        end
    endtask

    task loadHit(logic [corewidth-1:0] core);
            trace#(CORES) tx = trace#(CORES)::type_id::create("tx");
            start_item(tx);
            assert(tx.randomize() with {rst == 0; opCode == 4'b0101; targetCore == 0; tag == 1; offset == 2'b01; targetCore == core;});
            `uvm_info("TESTCLEAN", "Testing loads with clean cache", UVM_HIGH)
            finish_item(tx);
    endtask

    task loadMiss(logic [corewidth-1:0] core);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0101; tag == 6; offset == 2'b01; targetCore == core;});
        `uvm_info("TESTCLEAN", "Testing load miss iwht clean cache", UVM_HIGH)
        finish_item(tx);
    endtask

    task storeHit(logic [corewidth-1:0] core);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0110; tag == 2; offset == 2'b01; targetCore == core;});
        `uvm_info("TESTCLEAN", "Testing store hit with clean cache", UVM_HIGH)
        finish_item(tx);
    endtask

    task storeMiss(logic [corewidth-1:0] core);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0110; tag == 6; offset == 2'b01; targetCore == core;});
        `uvm_info("TESTCLEAN", "Testing store miss with clean cache", UVM_HIGH)
        finish_item(tx);
    endtask

endclass
