class coreAgent extends uvm_agent;
    `uvm_component_utils(coreAgent);

    function new (string name = "coreAgent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    driver d0;
    monitor m0;
    sequencer s0; //might need to do fancy stuff because custom sequencer

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        s0 = sequencer::type_id::create("s0", this);
        d0 = driver::type_id::create("d0", this);
        m0 = monitor::type_id::create("m0", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        d0.seq_item_port.connect(s0.seq_item_export);
    endfunction

    if (get_is_active()) begin
        coreSeqr = sequencer#(gen_item_seq)::type_id::create("coreSeqr", this);
        coreDriv = driver::type_id::create("coreDriv", this);
    end

    coreMon = monitor::type_id::create("coreMon", this);

    virtual function void connect_phase(uvm_phase phase);
        if (get_is_active())
            coreDriv.seq_item_port_connect(coreSeqr.seq_item_export);
    endfunction
endclass
