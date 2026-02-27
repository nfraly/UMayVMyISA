class sequencer extends uvm_sequencer #(trace#(3));

    `uvm_component_utils(sequencer)

    function new(string name="sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("seqr_class", "build_phase for sequencer", UVM_MEDIUM)
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("seqr_class", "connect_phase for sequencer", UVM_MEDIUM)
    endfunction

endclass
