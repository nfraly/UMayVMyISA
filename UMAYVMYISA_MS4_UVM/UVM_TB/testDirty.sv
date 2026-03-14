class testDirty #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(testDirty#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "testDirty");
        super.new(name);
        `uvm_info("DRTTST", "DRTTST constructor", UVM_HIGH)
    endfunction

    logic [corewidth:0] targ;
/*
    task body();
        for (targ = 0; targ < CORES; targ++) begin
            storeHit(targ);
            loadHit(targ);
            storeMiss(targ);
            loadMiss(targ);
        end    
    endtask
*/

    task body();
        //for (targ = 0; targ < 2; targ++) begin
            primeStoreReg(0, 5'd1, 11'h000); // load 0x05 into r1
            storeHit(0, 5'd1);
            loadHit(0);
            //primeStoreReg(targ, 5'd2, 11'h001); // load 0x07 into r2
            primeStoreReg(0, 5'd2, 11'h049);
            storeMiss(0, 5'd2);
            loadMiss(0);
            primeStoreReg(1, 5'd1, 11'h000); // load 0x05 into r1
            storeHit(1, 5'd1);
            loadHit(1);
            //primeStoreReg(targ, 5'd2, 11'h001); // load 0x07 into r2
            primeStoreReg(1, 5'd2, 11'h049);
            storeMiss(1, 5'd2);
            loadMiss(1);
            primeStoreReg(2, 5'd1, 11'h000); // load 0x05 into r1
            storeHit(2, 5'd1);
            loadHit(2);
            //primeStoreReg(targ, 5'd2, 11'h001); // load 0x07 into r2
            primeStoreReg(2, 5'd2, 11'h049);
            storeMiss(2, 5'd2);
            loadMiss(2);

        //end    
    endtask

    task primeStoreReg(logic [corewidth-1:0] target, logic [4:0] reg_id, logic [10:0] addr11);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        logic [5:0] t;
        logic [2:0] i;
        logic [1:0] o;
        t = addr11[10:5];
        i = addr11[4:2];
        o = addr11[1:0];
        start_item(tx);
        assert(tx.randomize() with {
            rst == 0; opCode == 4'b0101; targetCore == target;
            rt == reg_id; tag == t; index == i; offset == o;
        });
        finish_item(tx);
        `uvm_info("DRTTST", $sformatf("Priming r%0d from addr 0x%03h", reg_id, addr11), UVM_HIGH)
    endtask

    task storeHit(logic [corewidth-1:0] target, logic [4:0] src_reg);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0110; tag == 2; index == 3'd2; rt == src_reg; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", $sformatf("Testing hits with cache dirty (src r%0d)", src_reg), UVM_HIGH)
    endtask

    task storeMiss(logic [corewidth-1:0] target, logic [4:0] src_reg);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0110; tag == 5; index == 3'd5; rt == src_reg; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", $sformatf("Testing misses with cache dirty (src r%0d)", src_reg), UVM_HIGH)
    endtask

    task loadHit(logic [corewidth-1:0] target);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0101; tag == 2; index == 3'd2; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", "Testing hits with cache dirty", UVM_HIGH)
    endtask

    task loadMiss(logic [corewidth-1:0] target);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b0101; tag == 5; index == 3'd5; targetCore == target;});
        finish_item(tx);
        `uvm_info("DRTTST", "Testing misses with cache dirty", UVM_HIGH)
    endtask

endclass
