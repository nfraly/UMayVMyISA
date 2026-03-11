class driver extends uvm_driver #(trace#(3));
    `uvm_component_utils (driver);

    localparam logic [3:0] ADD = 4'b0001;

    virtual intf vif;
    trace#(3) testObj;



    function new (string name = "driver", uvm_component parent = null);
        super.new (name, parent);
        `uvm_info("DRIVER", "Constructing Driver", UVM_LOW)
    endfunction


    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        testObj = trace#(3)::type_id::create("testObj");
        `uvm_info("DRIVER", "Driver Build_phase", UVM_LOW)
        if(!(uvm_config_db #(virtual intf)::get(this, "*", "vif", vif))) begin
            `uvm_error("DRIVER", "Failed to get VIF from config DB")
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
            `uvm_info("DRIVER", "Driver Connect_phase", UVM_LOW)
    endfunction

    virtual task run_phase (uvm_phase phase);
        string tmp_string;
        super.run_phase(phase);
        `uvm_info("DRIVER", "Driver Run_phase", UVM_LOW)


        forever begin
            `uvm_info ("DRIVER", $sformatf ("Waiting for data from sequencer"), UVM_HIGH)
            seq_item_port.get_next_item (testObj);
            `uvm_info ("DRIVER", $sformatf ("About to drive an item"), UVM_HIGH)
            drive_item (testObj);
            $swriteh(tmp_string,"%p",testObj.instruction);
            `uvm_info ("DRIVER", $sformatf ("Drove an item 0X%p", tmp_string), UVM_HIGH)
            seq_item_port.item_done();
        end
        `uvm_info("DRIVER", "Driver Run_phase Complete", UVM_HIGH)
    endtask

    task drive_item (trace#(3) testObj);
        `uvm_info ("DRIVER", $sformatf ("Driving an item"), UVM_HIGH)
        vif.instr_core_sel = testObj.targetCore;
        vif.instr_word = testObj.instruction;
        vif.instr_valid = 1'b1;
        repeat(1) @(negedge vif.clk);
        `uvm_info("DRIVER", "Releasing instr_valid", UVM_HIGH)
        vif.instr_valid = 1'b0;
        //wait(vif.instr_ready); vif.instr_valid = 1'b0;
    endtask

endclass
