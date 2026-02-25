class driver extends uvm_driver;
    `uvm_component_utils (driver);

    function new (string name = "driver", uvm_component parent = null);
        super.new (name, parent);
    endfunction

    virtual intf vif;

    virtual function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        if (!uvm_config_db #(vif)::get(this, null, "vif" vif)) begin
            `uvm_fatal(get_type_name(), "Didn't get handle to interface vif");
        end
    endfunction

    virtual task run_phase (uvm_phase phase);
        super.run_phase(phase);

        forever begin
            reg_item testObj;
            `uvm_info (get_type_name(), $sformatf ("Waiting for data from sequencer", UVM_LOW);
            seq_item_port.get_next_item (testObj);
            drive_item (testObj);
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_item (reg_item testObj);
        //Use bus protocol to drive
    endtask

endclass
