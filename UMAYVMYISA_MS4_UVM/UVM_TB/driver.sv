class driver extends uvm_driver #(trace#(3));
    `uvm_component_utils (driver);

    virtual intf vif;
    //sequenceitem
    trace#(3) testObj;



    function new (string name = "driver", uvm_component parent = null);
        super.new (name, parent);
    endfunction


    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        if(!(uvm_config_db #(virtual intf)::get(this, "*", "vif", vif))) begin
            `uvm_error("driver", "Failed to get VIF from config DB")
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    task run_phase (uvm_phase phase);
        super.run_phase(phase);

        forever begin
            testObj = trace#(3)::type_id::create("testObj");
            //`uvm_info (get_type_name(), $sformatf ("Waiting for data from sequencer"), UVM_LOW)
            seq_item_port.get_next_item (testObj);
            drive_item (testObj);
            seq_item_port.item_done();
        end
    endtask

    task drive_item (trace#(3) testObj);
        @(posedge vif.clk);
        if (vif.instr_ready) begin
            vif.targetCore <= testObj.targetCore;
            vif.instr_word <= testObj.instruction;
            vif.instr_valid <= '1;
        end
    endtask

endclass
