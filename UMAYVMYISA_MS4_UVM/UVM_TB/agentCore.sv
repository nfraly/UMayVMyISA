class coreAgent extends uvm_agent;
    `uvm_component_utils(coreAgent);

    function new (string name = "coreAgent", uvm_component parent = null);
        super.new(name,parent);
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
