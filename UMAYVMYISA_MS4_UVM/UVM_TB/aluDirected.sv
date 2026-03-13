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
        for(logic [corewidth-1:0]  j = 0; j < CORES; j++) begin
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
        `uvm_info("SEQ", $sformatf("Generated a directed Store test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedLoad();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize());
        tx.instruction[31:28] = 4'b0101;
        `uvm_info("SEQ", $sformatf("Generated a directed Load test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    
    task correctStore();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize());
        tx.instruction[31:28] = 4'b0110;
        tx.instruction[10:0] = 11'b000011010; //arbitrary memory destination
        `uvm_info("SEQ", $sformatf("Generated a very directed Store test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task correctLoad();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize());
        tx.instruction[31:28] = 4'b0101;
        tx.instruction[10:0] = 11'b000011010; // Load from memory address that was previously stored to
        `uvm_info("SEQ", $sformatf("Generated a very directed Load test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedRightShift();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == '0; opCode == 4'b0111;});
        `uvm_info("SEQ", $sformatf("Generated a directed Right Shift test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedLeftShift();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0; opCode == 4'b1000;});
        `uvm_info("SEQ", $sformatf("Generated a directed Left Shift test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction1();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0;});
        tx.instruction[31:28] = 4'b1001;
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function1 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction2();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0;});
        tx.instruction[31:28] = 4'b1010;
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function2 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction3();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0;});
        tx.instruction[31:28] = 4'b1011;
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function3 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction4();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0;});
        tx.instruction[31:28] = 4'b1100;
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function4 test"), UVM_HIGH)
        finish_item(tx);
    endtask
    
    task directedSpecialFunction5();
        trace#(3) tx = trace#(3)::type_id::create("tx");
        start_item(tx);
        assert(tx.randomize() with {rst == 0;});
        tx.instruction[31:28] = 4'b1101;
        `uvm_info("SEQ", $sformatf("Generated a directed Special Function5 test"), UVM_HIGH)
        finish_item(tx);
    endtask

endclass 
