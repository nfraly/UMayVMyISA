class driver extends uvm_driver #(trace#(3));
    `uvm_component_utils (driver);

    localparam logic [3:0] ADD = 4'b0001;

    virtual intf vif;
    //sequenceitem
    trace#(3) testObj;



    function new (string name = "driver", uvm_component parent = null);
        super.new (name, parent);
        `uvm_info("DRIVER", "Constructing Driver", UVM_HIGH)
    endfunction


    function void build_phase (uvm_phase phase);
        super.build_phase (phase);
        testObj = trace#(3)::type_id::create("testObj");
        `uvm_info("DRIVER", "Driver Build_phase", UVM_HIGH)
        if(!(uvm_config_db #(virtual intf)::get(this, "*", "vif", vif))) begin
            `uvm_error("DRIVER", "Failed to get VIF from config DB")
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
            `uvm_info("DRIVER", "Driver Connect_phase", UVM_HIGH)
    endfunction

    virtual task run_phase (uvm_phase phase);
        super.run_phase(phase);
        `uvm_info("DRIVER", "Driver Run_phase", UVM_HIGH)
        vif.rst = '1;
        repeat(2) @(negedge vif.clk);
        vif.rst = '0;
        repeat(2) @(negedge vif.clk);


        forever begin
            `uvm_info ("DRIVER", $sformatf ("Waiting for data from sequencer"), UVM_LOW)
            seq_item_port.get_next_item (testObj);
            `uvm_info ("DRIVER", $sformatf ("About to drive an item"), UVM_LOW)
            drive_item (testObj);
            `uvm_info ("DRIVER", $sformatf ("Drove an item"), UVM_LOW)
            seq_item_port.item_done();
        end
        `uvm_info("DRIVER", "Driver Run_phase Complete", UVM_HIGH)
    endtask

    task drive_item (trace#(3) testObj);
        `uvm_info ("DRIVER", $sformatf ("Waiting to drive an item"), UVM_LOW)
        wait(vif.instr_ready);
        `uvm_info ("DRIVER", $sformatf ("Driving an item"), UVM_LOW)
        vif.instr_word = testObj.instruction;
    endtask

endclass
