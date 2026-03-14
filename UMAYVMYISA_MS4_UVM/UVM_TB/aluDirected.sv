class aluDirected #(parameter CORES = 3) extends uvm_sequence#(trace#(3));
    `uvm_object_utils(aluDirected#(3))
    localparam corewidth = $clog2(CORES);
    function new(string name = "aluDirected");
        super.new(name);
        `uvm_info("SEQ", "Sequence constructor", UVM_HIGH)
    endfunction

    


    int unsigned addr_base;
    int i, c;
    trace#(3) tx;

    task body();
        directedTestCases();
    endtask

    task directedTestCases();
        for(logic [corewidth:0] j = 0; j < CORES; j++) begin
            directedAdd(j);
            directedAnd(j);
            directedSub(j);
            directedMul(j);
            directedRightShift(j);
            directedLeftShift(j);
            directedSpecialFunction1(j);
            directedSpecialFunction2(j);
            directedSpecialFunction3(j);
            directedSpecialFunction4(j);
            directedSpecialFunction5(j);
        end
    endtask
    
    task directedAdd(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == '0; opCode == 4'b0001; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Add test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedAnd(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == '0; opCode == 4'b0010; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed And test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSub(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == '0; opCode == 4'b0011; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Subtraction test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedMul(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == '0; opCode == 4'b0100; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Multiplication test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedRightShift(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == '0; opCode == 4'b0111; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Right Shift test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedLeftShift(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b1000; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Left Shift test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction1(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b1001; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function1 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction2(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b1010; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function2 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction3(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b1011; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function3 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction4(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b1100; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function4 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction5(logic [corewidth:0] targ);
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b1101; targetCore == targ;});
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function5 test"), UVM_HIGH)
        finish_item(tx);
    endtask

endclass 
