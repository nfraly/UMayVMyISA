class monitor extends uvm_monitor;
    `uvm_component_utils (monitor)

    virtual intf vif;
    trace#(3) testObj;

    uvm_analysis_port #(trace#(3)) mon_analysis_port;

    function new (string name = "monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        mon_analysis_port = new("mon_analaysis_port", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info("mon_class", "connect_phase monitor", UVM_MEDIUM)
    endfunction

    virtual task run_phase (uvm_phase phase);
        super.run_phase(phase);
        testObj = trace#(3)::type_id::create("testObj");
        forever begin
            @(posedge vif.clk); //whatever signifies a new event
            testobj.instruction = vif.instruction; //grab the input for the DUT
            //testobj.outmembers = vif.outmembers; //grab the DUT output -- none right now

            mon_analysis_port.write(testObj);
        end
    endtask
endclass
