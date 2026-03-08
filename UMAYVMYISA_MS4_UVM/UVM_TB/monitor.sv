class monitor extends uvm_monitor;
    `uvm_component_utils (monitor)

    virtual intf vif;
    trace#(3) testObj;

    uvm_analysis_port #(trace#(3)) mon_analysis_port;

    function new (string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
        `uvm_info("Monitor",  "Inside contstructor", UVM_HIGH)
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port = new("mon_analaysis_port", this);

        if(!(uvm_config_db #(virtual intf)::get(this, "*", "vif", vif))) begin
            `uvm_error("Monitor", "Failed to get VIF from config DB")
        end
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("mon_class", "connect_phase monitor", UVM_MEDIUM)
    endfunction

    /*
        TODO:ALU operations take 5 clock cycles, monitor must grab inputs and then grab the outputs 5 clock cycles later
    */


     task run_phase (uvm_phase phase);
        super.run_phase(phase);
        testObj = trace#(3)::type_id::create("testObj");
        forever begin
            @(posedge vif.instr_ready); //processor ready for a new instruction
            testObj.instruction = vif.instruction; //grab the input for the DUT
            testObj.targetCore = vif.targetCore;
            //testobj.outmembers = vif.outmembers; //grab the DUT output -- none right now
            repeat(5) @(posedge vif.clk);
            testObj.data <= vif.mem_dbg_data;
            testObj.address <= vif.mem_dbg_addr;
            testObj.register <= vif.mem_req_addr_dbg;


            mon_analysis_port.write(testObj);
        end
    endtask
endclass
