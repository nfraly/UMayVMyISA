class testDirty #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(testDirty#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "testDirty");
        super.new(name);
        `uvm_info("DRTTST", "DRTTST constructor", UVM_HIGH)
    endfunction

    logic [corewidth:0] targ;

    task body();
        for (targ = 0; targ < CORES; targ++) begin
            storeHit(targ);
            loadHit(targ);
            storeMiss(targ);
            loadMiss(targ);
        end    
    endtask

    task storeHit(logic [corewidth-1:0] target);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0110; tag == 2; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", "Testing hits with cache dirty", UVM_HIGH)
    endtask

    task storeMiss(logic [corewidth-1:0] target);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0110; tag == 5; offset == 2'b01; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", "Testing misses with cache dirty", UVM_HIGH)
    endtask

    task loadHit(logic [corewidth-1:0] target);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0101; tag == 2; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", "Testing hits with cache dirty", UVM_HIGH)
    endtask

    task loadMiss(logic [corewidth-1:0] target);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0101; tag == 5; offset == 2'b01; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", "Testing misses with cache dirty", UVM_HIGH)
    endtask

endclass

