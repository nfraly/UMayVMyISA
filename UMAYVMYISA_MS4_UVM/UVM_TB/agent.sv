class coreAgent extends uvm_agent;
    `uvm_component_utils(coreAgent);

    driver d0;
    monitor m0;
    sequencer s0; //might need to do fancy stuff because custom sequencer

    function new (string name = "coreAgent", uvm_component parent = null);
        super.new(name,parent);
        `uvm_info("AGENT", "Constructing Agent", UVM_HIGH)
    endfunction


    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("AGENT", "Agent build_phase", UVM_HIGH)
        s0 = sequencer::type_id::create("s0", this);
        d0 = driver::type_id::create("d0", this);
        m0 = monitor::type_id::create("m0", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("AGENT", "Agent connect_phase", UVM_HIGH)
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction
    
    task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("AGENT", "Agent run_phase", UVM_HIGH)
    endtask

endclass
