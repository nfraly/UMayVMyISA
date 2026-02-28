class driver extends uvm_driver #(trace#(3));
    `uvm_component_utils (driver);

    function new (string name = "driver", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    virtual intf vif;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
    endfunction

    virtual task run_phase (uvm_phase phase);
        super.run_phase(phase);

        forever begin
            trace#(3) testObj;
            `uvm_info (get_type_name(), $sformatf ("Waiting for data from sequencer"), UVM_LOW)
            seq_item_port.get_next_item (testObj);
            drive_item (testObj);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_item (trace#(3) testObj);
        @(posedge vif.clk);
        if (vif.instr_ready) begin
            vif.targetCore <= testObj.targetCore;
            vif.instr_word <= testObj.instruction;
            vif.instr_valid <= '1;
            repeat(5) @(negedge vif.clk);
            //if it's a load
            testObj.register <= vif.;
            testObj.address <= vif.mem_dbg_addr;
            testObj.data <= vif.mem_dbg_data;
            //if it's a store
            testObj.register <= vif.;
            testObj.address <= vif.;
            testObj.data <= vif.;
            //other alu stuff later
    endtask

endclass
