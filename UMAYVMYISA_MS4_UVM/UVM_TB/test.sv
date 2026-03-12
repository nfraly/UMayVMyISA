class coreTest extends uvm_test;
    `uvm_component_utils(coreTest);

    function new(string name = "coreTest", uvm_component parent=null);
        super.new(name, parent);
        `uvm_info("TEST", "Test Constructor", UVM_HIGH)
    endfunction

    env e0;
    aluDirected#(3) seq; 
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
        //apply_reset(); //define reset pattern
        seq = aluDirected#(3)::type_id::create("seq");
        seq.start(e0.a0.s0); //define this
        //repeat(SOMEAMOUNTOFTIME);
        #5000;
        phase.drop_objection(this);
    endtask

    virtual task apply_reset();
        vif.rst = 1;
    endtask

endclass
