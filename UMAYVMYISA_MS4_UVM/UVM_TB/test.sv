class coreTest extends uvm_test;
    `uvm_component_utils(coreTest);

    function new(string name = "coreTest", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info("TEST", "Test Constructor", UVM_HIGH)
    endfunction

    env e0;
    aluDirected#(3) aluSeq; 
    fillClean#(3) fillCleanSeq;
    testClean#(3) testCleanSeq;
    fillDirty#(3) fillDirtySeq;
    testDirty#(3) testDirtySeq;
    resetSequence#(3) resetSeq;
    virtual intf vif;

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TEST", "Test build phase", UVM_HIGH)

        e0 = env::type_id::create("e0", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("TEST", "Test connect phase", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("TEST", "Test run phase", UVM_HIGH)
        phase.raise_objection(this);

        resetSeq = resetSequence#(3)::type_id::create("resetSequence");
        resetSeq.start(e0.a0.s0);
        aluSeq = aluDirected#(3)::type_id::create("aluSeq");
        aluSeq.start(e0.a0.s0);
        fillCleanSeq = fillClean#(3)::type_id::create("fillCleanSeq");
        fillCleanSeq.start(e0.a0.s0);
        testCleanSeq = testClean#(3)::type_id::create("testCleanSeq");
        testCleanSeq.start(e0.a0.s0);
        fillDirtySeq = fillDirty#(3)::type_id::create("fillDirtySeq");
        fillDirtySeq.start(e0.a0.s0);
        testDirtySeq = testDirty#(3)::type_id::create("testDirtySeq");
        testDirtySeq.start(e0.a0.s0);
        #2000;
        phase.drop_objection(this);
    endtask

endclass
